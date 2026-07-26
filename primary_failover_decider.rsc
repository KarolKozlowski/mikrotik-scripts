:global primaryState;
:global primaryAppliedState;

:global gotifySource "np.dotnot.pl";
:global gotifyService "BestGo";
:global gotifyState;
:global primaryConsecutiveDownCount;
:global primaryConsecutiveDownThreshold;

:if ([:typeof $primaryConsecutiveDownCount] = "nil") do={
    :set primaryConsecutiveDownCount 0;
};

:if ([:typeof $primaryConsecutiveDownThreshold] = "nil") do={
    :set primaryConsecutiveDownThreshold 2;
};

:log info ("primary_failover_decider telemetry: state=" . $primaryState . " applied=" . $primaryAppliedState);

# If we already applied this state, skip
:if ([:typeof $primaryAppliedState] != "nil") do={
    :if ($primaryAppliedState = $primaryState) do={
        :log debug "primary_failover_decider: state $primaryState already applied, skipping";
        :return true;
    };
};

:if ($primaryState = "DOWN") do={

    :set primaryConsecutiveDownCount ($primaryConsecutiveDownCount + 1);
    :log info ("primary_failover_decider telemetry: down_streak=" . $primaryConsecutiveDownCount);

    :if ($primaryConsecutiveDownCount < $primaryConsecutiveDownThreshold) do={
        :log warning ("primary_failover_decider: debounce active, waiting for " . ($primaryConsecutiveDownThreshold - $primaryConsecutiveDownCount) . " more DOWN result(s)");
        :return true;
    };

    :log error "PRIMARY interface considered DOWN. Performing failover.";

    /system script run beep_primary_down;

    # Disable primary route in main by comment
    /ip route disable [/ip route find comment="PRIMARY"];

    # Remove only connections using primary (via-bestgo)
    :local conns [/ip firewall connection find where connection-mark=via-bestgo];
    :log info ("primary_failover_decider telemetry: failover_conntrack_marked=" . [:len $conns]);
    :if ([:len $conns] > 0) do={
        :local removedCount 0;
        :foreach conn in=$conns do={
            :do {
                /ip firewall connection remove $conn;
                :set removedCount ($removedCount + 1);
            } on-error={
                :log debug "primary_failover_decider: connection $conn already gone, skipping";
            };
        };
        :log info ("primary_failover_decider telemetry: failover_conntrack_removed=" . $removedCount);
    }

    :set gotifyState $primaryState;
    :delay 1000ms;
    :log info ("primary_failover_decider telemetry: gotify_state=" . $gotifyState);
    /system script run gotify;

    :set primaryAppliedState "DOWN";
    :return true;
};

:if ($primaryState = "UP") do={

    :set primaryConsecutiveDownCount 0;

    :log warning "PRIMARY interface considered UP. Restoring primary routes.";

    /system script run beep_primary_up;

    # Enable primary route in main by comment
    /ip route enable [/ip route find comment="PRIMARY"];

    # Flush conntrack on restore so VPN/NAT sessions re-establish on primary
    :local restoreConns [/ip firewall connection find];
    :log info ("primary_failover_decider telemetry: restore_conntrack_total=" . [:len $restoreConns]);
    :if ([:len $restoreConns] > 0) do={
        :local restoreRemovedCount 0;
        :foreach conn in=$restoreConns do={
            :do {
                /ip firewall connection remove $conn;
                :set restoreRemovedCount ($restoreRemovedCount + 1);
            } on-error={
                :log debug "primary_failover_decider: restore conn $conn already gone, skipping";
            };
        };
        :log info ("primary_failover_decider telemetry: restore_conntrack_removed=" . $restoreRemovedCount);
    }

    :set gotifyState $primaryState;
    :log info ("primary_failover_decider telemetry: gotify_state=" . $gotifyState);
    /system script run gotify;

    :set primaryAppliedState "UP";
    :return true;
};

:log warning "primary_failover_decider: unknown primaryState '$primaryState'";
:return false;