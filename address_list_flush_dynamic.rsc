#!rsc by RouterOS

:foreach list in=[/ip firewall address-list find dynamic=yes] do={  /ip firewall address-list remove $list } 