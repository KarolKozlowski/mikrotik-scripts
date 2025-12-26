:delay 10s

:global warnkuma;
:global warnhc;

:local warnhcthr 10;
:local warnkumathr 1;

:if ( $warnhc != 0 and $warnhc <= $warnhcthr ) do={
    :log warn "healthchecks.io check has failed ($warnhc/$warnhcthr)."
}

:if ( $warnkuma != 0 and $warnkuma <= $warnkumathr ) do={
    :log warn "uptime kuma check has failed ($warnkums/$wankumathr)."
}

:if ($warnhc > $warnhcthr ) do={
    :log warn "Internet check has failed $warnhc times, alerting."
    /system script run beep_no_net
}

:if ($warnkuma > $warnkumathr) do={
    :log warn "Internet check has failed $warnkuma times, alerting."
    /system script run beep_no_net
}
