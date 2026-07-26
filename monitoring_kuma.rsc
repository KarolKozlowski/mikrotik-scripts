#!rsc by RouterOS

:global warninet;
:set warninet ($warninet + 1);
:local result [/tool fetch mode=https url="https://kuma.dotnot.pl/api/push/8TdGnaAfnL?status=up&msg=OK&ping=" as-value output=user];

:if ($result->"status" = "finished") do={
    :set warninet 0;
} else={
    :log warn "Failed to query kuma.dotnot.pl"
}