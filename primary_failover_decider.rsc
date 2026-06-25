:global primaryState;
:global primaryAppliedState;

:global gotifySource "np.dotnot.pl";
:global gotifyService "BestGo";
:global gotifyState;

# If we already applied this state, skip
:if ([:typeof $primaryAppliedState] != "nil") do={
    :if ($primaryAppliedState = $primaryState) do={
        :log debug "primary_failover_decider: state $primaryState already applied, skipping";
        :return true;
    };
};

:if ($primaryState = "DOWN") do={

    :log error "PRIMARY interface considered DOWN. Performing failover.";

    /system script run beep_primary_down;

    # Disable primary route in main by comment
    /ip route disable [/ip route find comment="PRIMARY"];

    # Remove only connections using primary (via-bestgo)
    :local conns [/ip firewall connection find where connection-mark=via-bestgo];
    :if ([:len $conns] > 0) do={
        /ip firewall connection remove $conns;
    }

    :set gotifyState $primaryState;
    :delay 1000ms;
    /system script run gotify;

    :set primaryAppliedState "DOWN";
    :return true;
};

:if ($primaryState = "UP") do={

    :log warning "PRIMARY interface considered UP. Restoring primary routes.";

    /system script run beep_primary_up;

    # Enable primary route in main by comment
    /ip route enable [/ip route find comment="PRIMARY"];

    :set gotifyState $primaryState;
    /system script run gotify;

    :set primaryAppliedState "UP";
    :return true;
};

:log warning "primary_failover_decider: unknown primaryState '$primaryState'";
:return false;