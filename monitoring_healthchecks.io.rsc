:global warnhc;
:set warnhc ($warnhc + 1);
:local result [/tool fetch mode=https url="https://hc-ping.com/6cb7d0cd-a1e1-45be-b1da-110bde19df6d" as-value output=user];

:if ($result->"status" = "finished") do={
    :set warnhc 0;
} else={
    :log warn "Failed to query healthchecks.io"
}