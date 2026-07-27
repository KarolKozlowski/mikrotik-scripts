:global gotifySource "np.dotnot.pl";
:global gotifyService "BestGo";
:global gotifyState;
:global primaryDebounceSeconds;
:global primaryDebug;  # Inherited from netwatch inline script, defaults to false

# Globals set by netwatch inline test-script
:global primaryElapsedSeconds;  # Calculated elapsed seconds since status change
:global primaryStatus;
:global primaryRttAvg;
:global primaryRttMax;
:global primaryThresholdLoss;

# If variables not provided (manual testing), assume defaults
:if ([:typeof $primaryElapsedSeconds] = "nothing") do={
    :set primaryElapsedSeconds 0;
};
:if ([:typeof $primaryStatus] = "nothing") do={
    :set primaryStatus "unknown";
};
:if ([:typeof $primaryRttAvg] = "nothing") do={
    :set primaryRttAvg "0ms";
};
:if ([:typeof $primaryRttMax] = "nothing") do={
    :set primaryRttMax "0ms";
};
:if ([:typeof $primaryThresholdLoss] = "nothing") do={
    :set primaryThresholdLoss "0";
};
:if ([:typeof $primaryDebug] = "nothing") do={
    :set primaryDebug false;
};

# Get current state: route enabled/disabled
:local primaryRoute [/ip route find comment="PRIMARY"];
:if ([:len $primaryRoute] = 0) do={
    :log error "primary_failover: PRIMARY route not found! Check route exists with comment='PRIMARY'";
    :return false;
};
:local routeDisabled [/ip route get $primaryRoute disabled];
:local currentState "DISABLED";
:if ($routeDisabled = false) do={
    :set currentState "ENABLED";
};

# Get desired state from netwatch status
:local desiredState "DISABLED";
:if ($primaryStatus = "up") do={
    :set desiredState "ENABLED";
};

:if ($primaryDebug = true) do={
    :log info ("primary_failover_decider: primaryStatus=" . $primaryStatus . " (comparing to 'up')");
    :log info ("primary_failover telemetry: current_state=" . $currentState . " desired_state=" . $desiredState . " elapsed=" . $primaryElapsedSeconds . "s debounce=" . $primaryDebounceSeconds . "s");
};

# If states match, nothing to do
:if ($currentState = $desiredState) do={
    :return true;
};

# States don't match - wait for debounce period
:if ($primaryElapsedSeconds < $primaryDebounceSeconds) do={
    :log warning ("primary_failover: SETTLE status=" . $primaryStatus . " elapsed=" . $primaryElapsedSeconds . "s rtt-avg=" . $primaryRttAvg . " rtt-max=" . $primaryRttMax . " loss=" . $primaryThresholdLoss . "% waiting=" . ($primaryDebounceSeconds - $primaryElapsedSeconds) . "s");
    :return true;
};

# Debounce expired - flip the route
:if ($desiredState = "DISABLED") do={
    :log error "PRIMARY interface DOWN. Disabling route and failing over.";

    /system script run beep_primary_down;

    # Disable primary route
    /ip route disable $primaryRoute;

    # Remove only connections using primary (via-bestgo)
    :local conns [/ip firewall connection find where connection-mark=via-bestgo];
    :if ([:len $conns] > 0) do={
        :foreach conn in=$conns do={
            :do {
                /ip firewall connection remove $conn;
            } on-error={
                :log debug "primary_failover_decider: connection $conn already gone, skipping";
            };
        };
    }

    :set gotifyState "DOWN";
    :delay 1000ms;
    /system script run gotify;
};

:if ($desiredState = "ENABLED") do={
    :log warning "PRIMARY interface UP. Enabling route and restoring.";

    /system script run beep_primary_up;

    # Enable primary route
    /ip route enable $primaryRoute;

    # Flush conntrack on restore so VPN/NAT sessions re-establish on primary
    :local restoreConns [/ip firewall connection find];
    :if ([:len $restoreConns] > 0) do={
        :foreach conn in=$restoreConns do={
            :do {
                /ip firewall connection remove $conn;
            } on-error={
                :log debug "primary_failover_decider: restore conn $conn already gone, skipping";
            };
        };
    }

    :set gotifyState "UP";
    :delay 1000ms;
    /system script run gotify;
};

# === ARCHITECTURE ===
# This script is the logic layer (heavy lifting).
# It expects these globals to be set by the caller (primary_failover_netwatch wrapper):
#   $primaryElapsedSeconds (calculated elapsed seconds, not raw timestamp)
#   $primaryStatus, $primaryRttAvg, $primaryRttMax, $primaryThresholdLoss
#
# For Netwatch integration, embed the test-script inline (see primary_failover_decider.md)
#
# For manual testing, set globals and run directly:
#   :global primaryDebounceSeconds 5;
#   :global primaryElapsedSeconds 2;
#   :global primaryStatus "fail";
#   :global primaryRttAvg "100ms";
#   :global primaryRttMax "150ms";
#   :global primaryThresholdLoss "0";
#   /system script run primary_failover_decider;