# 2026-04-28 15:19:15 by RouterOS 7.22.1
# software id = R472-0SQD
#
# model = RB760iGS
# serial number = A36A0BC2142A
/caps-man channel
add band=2ghz-b/g/n name=2.4Ghz
add band=5ghz-a/n/ac name=5Ghz
/interface bridge
add admin-mac=C4:AD:34:7A:9B:7E auto-mac=no comment=defconf name=bridge \
    port-cost-mode=short priority=0x1000
/interface ethernet
set [ find default-name=ether4 ] comment="Aux AP" name=ether.aux
set [ find default-name=ether1 ] comment=bestgo mac-address=30:5A:3A:C6:8B:10 \
    name=ether.bestgo
set [ find default-name=ether2 ] comment="Core Switch" name=ether.core
set [ find default-name=ether3 ] comment=--
set [ find default-name=ether5 ] comment=--
set [ find default-name=sfp1 ] advertise="10M-baseT-half,10M-baseT-full,100M-b\
    aseT-half,100M-baseT-full,1G-baseT-half,1G-baseT-full" comment=Orange
/interface wireguard
add listen-port=58242 mtu=1420 name=wireguard-client
add listen-port=13231 mtu=1420 name=wireguard-server
/interface vlan
add interface=bridge name=bridge.20-test vlan-id=20
add interface=bridge name=bridge.30-dev vlan-id=30
add interface=bridge name=bridge.80-iot vlan-id=80
add interface=bridge name=bridge.90-guest vlan-id=90
add arp=disabled interface=sfp1 name=sfp1.neostrada vlan-id=35
add interface=sfp1 name=sfp1.tv vlan-id=839
add interface=sfp1 name=sfp1.vod vlan-id=838
/caps-man datapath
add bridge=bridge name=default-datapath
/interface pppoe-client
add add-default-route=yes default-route-distance=10 disabled=no interface=\
    sfp1.neostrada max-mtu=1492 name=pppoe-neostrada user=\
    Q9H36Rb@neostrada.pl
add add-default-route=yes interface=sfp1.neostrada max-mtu=1492 name=\
    pppoe-neostrada-ipv6 user=Q9H36Rb@neostrada.pl/ipv6
/caps-man security
add authentication-types=wpa2-psk encryption=aes-ccm name=HypnoToad
/caps-man configuration
add channel=2.4Ghz channel.band=2ghz-b/g/n .control-channel-width=20mhz \
    datapath=default-datapath mode=ap name=2.4Ghz security=HypnoToad ssid=\
    HypnoToad
add channel=5Ghz channel.band=5ghz-a/n/ac datapath=default-datapath name=5GHz \
    security=HypnoToad ssid=HypnoToad_5G
/disk
add parent=sd1 partition-number=1 partition-offset=512 partition-size=\
    63864569344 type=partition
/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN
/interface lte apn
set [ find default=yes ] ip-type=ipv4 use-network-apn=no
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip dhcp-server option
add code=119 name=domain-search-option value="0x02'np'0x06'dotnot'0x02'pl'0x00\
    03'iot'0xC00305'guest'0xC00304'test'0xC003C003"
add code=252 force=yes name=wpad-url value=\
    "'http://intra.np.dotnot.pl/wpad.dat'"
/ip dhcp-server option sets
add name=default options=domain-search-option
add name="with proxy" options=domain-search-option,wpad-url
/ip firewall layer7-protocol
add comment="Block Torrents" name=torrent regexp="^(\\x13bittorrent protocol|a\
    zver\\x01\$|get /scrape\\\?info_hash=get /announce\\\?info_hash=|get /clie\
    nt/bitcomet/|GET /data\\\?fid=)|d1:ad2:id20:|\\x08'7P\\)[RP]"
add name=CVE-2023-28771 regexp=\
    ";bash -c \"curl [0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+\\/t \\| sh\";echo -n"
/ip ipsec mode-config
add address=172.16.9.2 address-prefix-length=32 name=vps01.cloud.dotnot.pl \
    split-include=172.16.0.0/16 static-dns=172.16.1.1 system-dns=no
add address=172.16.9.3 address-prefix-length=32 name=mikrus01.cloud.dotnot.pl \
    split-include=172.16.0.0/16 static-dns=172.16.1.1 system-dns=no
/ip ipsec peer
add exchange-mode=ike2 name=ikev2.dotnot.pl passive=yes send-initial-contact=\
    no
/ip ipsec policy group
set [ find default=yes ] name=ikev2.dotnot.pl
/ip ipsec profile
set [ find default=yes ] dpd-interval=2m dpd-maximum-failures=5 \
    enc-algorithm=aes-256,aes-192,aes-128 hash-algorithm=sha256 name=\
    ikev2.dotnot.pl proposal-check=strict
/ip ipsec proposal
set [ find default=yes ] auth-algorithms=sha256,sha1 enc-algorithms="aes-256-c\
    bc,aes-256-ctr,aes-256-gcm,aes-192-cbc,aes-192-ctr,aes-192-gcm,aes-128-cbc\
    ,aes-128-ctr,aes-128-gcm" pfs-group=modp2048
/ip pool
add name=default-dyn ranges=172.16.1.100-172.16.1.199
add name=default-static next-pool=default-dyn ranges=\
    172.16.1.200-172.16.1.254
add name=vpn-clients ranges=172.16.9.10-172.16.9.50
add name=vlan.20-test ranges=172.16.20.100-172.16.20.199
add name=vlan.90-guest ranges=172.16.90.100-172.16.90.199
add name=vlan.80-iot ranges=172.16.80.100-172.16.80.199
add name=vlan.30-dev ranges=172.16.30.100-172.16.30.199
add name=vlan.192-storage ranges=172.16.192.100-172.16.192.199
/ip dhcp-server
add address-pool=default-dyn dhcp-option-set=default interface=bridge \
    lease-script=":global \"g-zone\" \"np.dotnot.pl\";\
    \n\
    \n:global \"g-leaseBound\" \$\"leaseBound\";\
    \n:global \"g-leaseServerName\" \$\"leaseServerName\";\
    \n:global \"g-leaseActMAC\" \$\"leaseActMAC\";\
    \n:global \"g-leaseActIP\" \$\"leaseActIP\";\
    \n:global \"g-leaseAgentCircuitID\" \$\"lease-agent-circuit-id\";\
    \n:global \"g-leaseAgentRemoteID\" \$\"lease-agent-remote-id\";\
    \n:global \"g-leaseHostname\" \$\"lease-hostname\";\
    \n:global \"g-leaseOptions\" \$\"lease-options\";\
    \n\
    \n/system script run dhcp_lease_script\
    \n\
    \n" lease-time=1h name=dhcp
add address-pool=vlan.20-test dhcp-option-set=default interface=\
    bridge.20-test lease-script=":global \"g-zone\" \"test.dotnot.pl\";\
    \n\
    \n:global \"g-leaseBound\" \$\"leaseBound\";\
    \n:global \"g-leaseServerName\" \$\"leaseServerName\";\
    \n:global \"g-leaseActMAC\" \$\"leaseActMAC\";\
    \n:global \"g-leaseActIP\" \$\"leaseActIP\";\
    \n:global \"g-leaseAgentCircuitID\" \$\"lease-agent-circuit-id\";\
    \n:global \"g-leaseAgentRemoteID\" \$\"lease-agent-remote-id\";\
    \n:global \"g-leaseHostname\" \$\"lease-hostname\";\
    \n:global \"g-leaseOptions\" \$\"lease-options\";\
    \n\
    \n/system script run dhcp_lease_script_test\
    \n\
    \n" lease-time=1h name=vlan.20-test
add address-pool=vlan.80-iot dhcp-option-set=default interface=bridge.80-iot \
    lease-script=":global \"g-zone\" \"iot.dotnot.pl\";\
    \n\
    \n:global \"g-leaseBound\" \$\"leaseBound\";\
    \n:global \"g-leaseServerName\" \$\"leaseServerName\";\
    \n:global \"g-leaseActMAC\" \$\"leaseActMAC\";\
    \n:global \"g-leaseActIP\" \$\"leaseActIP\";\
    \n:global \"g-leaseAgentCircuitID\" \$\"lease-agent-circuit-id\";\
    \n:global \"g-leaseAgentRemoteID\" \$\"lease-agent-remote-id\";\
    \n:global \"g-leaseHostname\" \$\"lease-hostname\";\
    \n:global \"g-leaseOptions\" \$\"lease-options\";\
    \n\
    \n/system script run dhcp_lease_script\
    \n" lease-time=1h name=vlan.80-iot
add address-pool=vlan.90-guest dhcp-option-set=default interface=\
    bridge.90-guest lease-script=":global \"g-zone\" \"guest.dotnot.pl\";\
    \n\
    \n:global \"g-leaseBound\" \$\"leaseBound\";\
    \n:global \"g-leaseServerName\" \$\"leaseServerName\";\
    \n:global \"g-leaseActMAC\" \$\"leaseActMAC\";\
    \n:global \"g-leaseActIP\" \$\"leaseActIP\";\
    \n:global \"g-leaseAgentCircuitID\" \$\"lease-agent-circuit-id\";\
    \n:global \"g-leaseAgentRemoteID\" \$\"lease-agent-remote-id\";\
    \n:global \"g-leaseHostname\" \$\"lease-hostname\";\
    \n:global \"g-leaseOptions\" \$\"lease-options\";\
    \n\
    \n/system script run dhcp_lease_script\
    \n" lease-time=1h name=vlan.90-guest
add address-pool=vlan.30-dev dhcp-option-set=default interface=bridge.30-dev \
    lease-script=":global \"g-zone\" \"dev.dotnot.pl\";\
    \n\
    \n:global \"g-leaseBound\" \$\"leaseBound\";\
    \n:global \"g-leaseServerName\" \$\"leaseServerName\";\
    \n:global \"g-leaseActMAC\" \$\"leaseActMAC\";\
    \n:global \"g-leaseActIP\" \$\"leaseActIP\";\
    \n:global \"g-leaseAgentCircuitID\" \$\"lease-agent-circuit-id\";\
    \n:global \"g-leaseAgentRemoteID\" \$\"lease-agent-remote-id\";\
    \n:global \"g-leaseHostname\" \$\"lease-hostname\";\
    \n:global \"g-leaseOptions\" \$\"lease-options\";\
    \n\
    \n/system script run dhcp_lease_script_test\
    \n\
    \n" lease-time=1h name=vlan.30-dev
/ip ipsec mode-config
add address-pool=vpn-clients address-prefix-length=32 name=ikev2.dotnot.pl \
    split-include=0.0.0.0/0 static-dns=172.16.1.1 system-dns=no
/ip pool
add name=default-infra next-pool=default-static ranges=172.16.1.2-172.16.1.99
/ip smb users
set [ find default=yes ] disabled=yes
/ppp profile
set *FFFFFFFE dns-server=172.16.1.1 local-address=172.16.9.1 remote-address=\
    vpn-clients
/queue tree
add name=bridge-queue parent=bridge
add name=neostrada-queue parent=pppoe-neostrada
add max-limit=25M name=neostrada-guest-outgoing packet-mark=guest-outgoing \
    parent=neostrada-queue
add max-limit=10M name=neostrada-iot-outgoing packet-mark=iot-outgoing \
    parent=neostrada-queue
add max-limit=25M name=bridge-guest-incoming packet-mark=guest-incoming \
    parent=bridge-queue queue=ethernet-default
add name=bestgo-queue parent=ether.bestgo queue=ethernet-default
add disabled=yes name=bestgo-no-mark packet-mark=no-mark parent=bestgo-queue \
    priority=5 queue=pcq-upload-default
add max-limit=10M name=bestgo-iot-outgoing packet-mark=iot-outgoing parent=\
    bestgo-queue queue=ethernet-default
add max-limit=10M name=bridge-iot-incoming packet-mark=iot-incoming parent=\
    bridge-queue queue=ethernet-default
add disabled=yes name=neostrada-no-mark packet-mark=no-mark parent=\
    neostrada-queue priority=5 queue=pcq-upload-default
add disabled=yes name=bridge-no-mark packet-mark=no-mark parent=bridge-queue \
    priority=5 queue=pcq-download-default
add name=bridge-local packet-mark=local parent=bridge-queue priority=3 queue=\
    ethernet-default
add max-limit=25M name=bestgo-guest-outgoing packet-mark=guest-outgoing \
    parent=bestgo-queue queue=ethernet-default
/routing bgp template
set default disabled=no output.network=bgp-networks
/routing ospf instance
add disabled=no name=default-v2
/routing ospf area
add disabled=yes instance=default-v2 name=backbone-v2
/routing table
add disabled=no fib name=via_primary
add disabled=no fib name=via_failover
/system logging action
set 1 disk-file-count=10 disk-file-name=sd1-part1/log/disk \
    disk-lines-per-file=10000
set 3 remote=172.16.1.10
add disk-file-count=10 disk-file-name=sd1-part1/log/firewall \
    disk-lines-per-file=10000 name=firewall target=disk
add name=elk remote=172.16.1.10 remote-port=50001 target=remote
/system script
add dont-require-permissions=yes name=healthchecks.io owner=admin policy=\
    ftp,read,write,policy,test source=":global warnhc;\r\
    \n:set warnhc (\$warnhc + 1);\r\
    \n:local result [/tool fetch mode=https url=\"https://hc-ping.com/6cb7d0cd\
    -a1e1-45be-b1da-110bde19df6d\" as-value output=user];\r\
    \n\r\
    \n:if (\$result->\"status\" = \"finished\") do={\r\
    \n    :set warnhc 0;\r\
    \n} else={\r\
    \n    :log warn \"Failed to query healthchecks.io\"\r\
    \n}"
add dont-require-permissions=yes name=warnings owner=admin policy=\
    ftp,reboot,read,policy,test,password source=":delay 10s\r\
    \n\r\
    \n:global warnkuma;\r\
    \n:global warnhc;\r\
    \n\r\
    \n:local warnhcthr 10;\r\
    \n:local warnkumathr 1;\r\
    \n\r\
    \n:if ( \$warnhc != 0 and \$warnhc <= \$warnhcthr ) do={\r\
    \n    :log warn \"healthchecks.io check has failed (\$warnhc/\$warnhcthr).\
    \"\r\
    \n}\r\
    \n\r\
    \n:if ( \$warnkuma != 0 and \$warnkuma <= \$warnkumathr ) do={\r\
    \n    :log warn \"uptime kuma check has failed (\$warnkums/\$wankumathr).\
    \"\r\
    \n}\r\
    \n\r\
    \n:if (\$warnhc > \$warnhcthr ) do={\r\
    \n    :log warn \"Internet check has failed \$warnhc times, alerting.\"\r\
    \n    /system script run beep_no_net\r\
    \n}\r\
    \n\r\
    \n:if (\$warnkuma > \$warnkumathr) do={\r\
    \n    :log warn \"Internet check has failed \$warnkuma times, alerting.\"\
    \r\
    \n    /system script run beep_no_net\r\
    \n}\r\
    \n"
add dont-require-permissions=no name=address_list_flush_bad owner=admin \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=":foreach listname in={\"malicious\"; \"port_scanners\"; \"honey_po\
    t\"} do={\r\
    \n    :log warn \"Flushing address list: '\$listname'\"  \r\
    \n    :foreach list in=[/ip firewall address-list find list=\"\$listname\"\
    ] do {\r\
    \n      /ip firewall address-list remove \$list\r\
    \n    }\r\
    \n}\r\
    \n"
add dont-require-permissions=no name=address_list_defconf owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="/\
    ip firewall address-list\r\
    \n\r\
    \n  # IPv4 no forward\r\
    \n  add address=0.0.0.0/8 comment=\"defconf: RFC6890\" list=no_forward_ipv\
    4\r\
    \n  add address=169.254.0.0/16 comment=\"defconf: RFC6890\" list=no_forwar\
    d_ipv4\r\
    \n  add address=224.0.0.0/4 comment=\"defconf: multicast\" list=no_forward\
    _ipv4\r\
    \n  add address=255.255.255.255/32 comment=\"defconf: RFC6890\" list=no_fo\
    rward_ipv4\r\
    \n\r\
    \n  # IPv4 bad IP\r\
    \n  add address=127.0.0.0/8 comment=\"defconf: RFC6890\" list=bad_ipv4\r\
    \n  add address=192.0.0.0/24 comment=\"defconf: RFC6890\" list=bad_ipv4\r\
    \n  add address=192.0.2.0/24 comment=\"defconf: RFC6890 documentation\" li\
    st=bad_ipv4\r\
    \n  add address=198.51.100.0/24 comment=\"defconf: RFC6890 documentation\"\
    \_list=bad_ipv4\r\
    \n  add address=203.0.113.0/24 comment=\"defconf: RFC6890 documentation\" \
    list=bad_ipv4\r\
    \n  add address=240.0.0.0/4 comment=\"defconf: RFC6890 reserved\" list=bad\
    _ipv4\r\
    \n\r\
    \n  # IPv4 not global\r\
    \n  add address=0.0.0.0/8 comment=\"defconf: RFC6890\" list=not_global_ipv\
    4\r\
    \n  add address=10.0.0.0/8 comment=\"defconf: RFC6890\" list=not_global_ip\
    v4\r\
    \n  add address=100.64.0.0/10 comment=\"defconf: RFC6890\" list=not_global\
    _ipv4\r\
    \n  add address=169.254.0.0/16 comment=\"defconf: RFC6890\" list=not_globa\
    l_ipv4\r\
    \n  add address=172.16.0.0/12 comment=\"defconf: RFC6890\" list=not_global\
    _ipv4\r\
    \n  add address=192.0.0.0/29 comment=\"defconf: RFC6890\" list=not_global_\
    ipv4\r\
    \n  add address=192.168.0.0/16 comment=\"defconf: RFC6890\" list=not_globa\
    l_ipv4\r\
    \n  add address=198.18.0.0/15 comment=\"defconf: RFC6890 benchmark\" list=\
    not_global_ipv4\r\
    \n  add address=255.255.255.255/32 comment=\"defconf: RFC6890\" list=not_g\
    lobal_ipv4\r\
    \n\r\
    \n  # IPv4 bad source\r\
    \n  add address=224.0.0.0/4 comment=\"defconf: multicast\" list=bad_src_ip\
    v4\r\
    \n  add address=255.255.255.255/32 comment=\"defconf: RFC6890\" list=bad_s\
    rc_ipv4\r\
    \n  add address=0.0.0.0/8 comment=\"defconf: RFC6890\" list=bad_dst_ipv4\r\
    \n  add address=224.0.0.0/4 comment=\"defconf: RFC6890\" list=bad_dst_ipv4\
    \r\
    \n\r\
    \n  # local IP\r\
    \n  add address=172.16.0.0/12 comment=\"local subnets\" list=local"
add dont-require-permissions=no name=address_list_flush_dynamic owner=admin \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=":foreach list in=[/ip firewall address-list find dynamic=yes] do={\
    \_ /ip firewall address-list remove \$list } "
add dont-require-permissions=yes name=beep_no_net owner=admin policy=\
    read,policy,test,password,sensitive source=":local length 25ms;\r\
    \n\r\
    \n:for j from=1 to=4 step=1 do {\r\
    \n    :for k from=4000 to=3500 step=-10 do {\r\
    \n        :beep frequency=\$k length=\$length;\r\
    \n        :delay \$length;\r\
    \n    }\r\
    \n}"
add dont-require-permissions=yes name=beep_primary_down owner=admin policy=\
    read,policy,test,password,sensitive source="#!rsc by RouterOS\r\
    \n\r\
    \n:local length 250ms;\r\
    \n\r\
    \n# supress warnings between midnight and 8:00\r\
    \n:if ([/system clock get time] < [:totime \"8:00:00\"]) do={\r\
    \n  :put \"Warning supressed.\"\r\
    \n} else={\r\
    \n\r\
    \n  :for j from=1 to=1 step=1 do {\r\
    \n      :for k from=3400 to=3000 step=-200 do {\r\
    \n          :beep frequency=\$k length=\$length;\r\
    \n          :delay \$length;\r\
    \n      }\r\
    \n  }\r\
    \n}\r\
    \n"
add dont-require-permissions=yes name=beep_primary_up owner=admin policy=\
    read,policy,test,password,sensitive source=":local length 250ms;\r\
    \n\r\
    \n# supress warnings between midnight and 8:00\r\
    \n:if ([/system clock get time] < [:totime \"8:00:00\"]) do={\r\
    \n  :put \"Warning supressed.\"\r\
    \n} else={\r\
    \n\r\
    \n  :for j from=1 to=1 step=1 do {\r\
    \n      :for k from=3000 to=3400 step=200 do {\r\
    \n          :beep frequency=\$k length=\$length;\r\
    \n          :delay \$length;\r\
    \n      }\r\
    \n  }\r\
    \n}\r\
    \n"
add dont-require-permissions=yes name=kuma owner=admin policy=\
    ftp,read,write,policy,test source=":global warnkuma;\
    \n\
    \n:set warnkuma (\$warnkuma + 1);\
    \n\
    \n:local result [/tool fetch mode=https url=\"https://kuma.dotnot.pl/api/p\
    ush/0QnJgFJPNW\?status=up&msg=OK&ping=\" as-value output=user];\
    \n\
    \n:if (\$result->\"status\" = \"finished\") do={\
    \n    :set warnkuma 0;\
    \n} else={\
    \n    :log warn \"Failed to query kuma.dotnot.pl\"\
    \n}"
add dont-require-permissions=yes name=gotify owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
    local gotifyToken \"ANLpchZ8.Zko3sH\";\
    \n:local gotifyEndpointUrl \"https://push.dotnot.pl/message\";\
    \n\
    \n:global gotifySource \
    \n:global gotifyService\
    \n:global gotifyState\
    \n\
    \n# :global gotifySource \"defaultSource\";\
    \n# :global gotifyService \"defaultService\";\
    \n# :global gotifyState \"defaultState\";\
    \n# /system script run gotify\
    \n\
    \n:local httpData \"{ \\\"title\\\": \\\"\$gotifySource\\\", \\\"message\\\
    \": \\\"\$gotifyService is \$gotifyState\\\" }\";\
    \n/tool fetch url=\$gotifyEndpointUrl http-data=\"\$httpData\" \\\
    \n    http-header-field=\"X-Gotify-Key:\$gotifyToken,content-type:applicat\
    ion/json\" \\\
    \n    http-method=post mode=https output=none;"
add dont-require-permissions=no name=dhcp_lease_script owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    \_manage DNS records for DHCP leases\
    \n#\
    \n# Variables that are accessible for the event script:\
    \n#\
    \n#  leaseBound - set to \"1\" if bound, otherwise set to \"0\"\
    \n#  leaseServerName - DHCP server name\
    \n#  leaseActMAC - active mac address\
    \n#  leaseActIP - active IP address\
    \n#  lease-agent-circuit-id - lease agent circuit ID\
    \n#  lease-agent-remote-id - lease agent remote ID\
    \n#  lease-hostname - client hostname\
    \n#  lease-options - an array of received options\
    \n\
    \n:global \"g-leaseBound\";\
    \n:global \"g-leaseServerName\";\
    \n:global \"g-leaseActMAC\";\
    \n:global \"g-leaseActIP\";\
    \n:global \"g-leaseAgentCircuitID\";\
    \n:global \"g-leaseAgentRemoteID\";\
    \n:global \"g-leaseHostname\";\
    \n:global \"g-leaseOptions\";\
    \n\
    \n# :log info (\"TEST dhcp script: leaseBound -> \" . \$\"g-leaseBound\");\
    \n# :log info (\"TEST dhcp script: leaseServerName -> \" . \$\"g-leaseServ\
    erName\");\
    \n# :log info (\"TEST dhcp script: leaseActMAC -> \" . \$\"g-leaseActMAC\"\
    );\
    \n# :log info (\"TEST dhcp script: leaseActIP -> \" . \$\"g-leaseActIP\");\
    \n# :log info (\"TEST dhcp script: leaseAgentCircuitID -> \" . \$\"g-lease\
    AgentCircuitID\");\
    \n# :log info (\"TEST dhcp script: leaseAgentRemoteID -> \" . \$\"g-leaseA\
    gentRemoteID\");\
    \n# :log info (\"TEST dhcp script: leaseHostname -> \" . \$\"g-leaseHostna\
    me\");\
    \n# :log info (\"TEST dhcp script: leaseOptions -> \" . \$\"g-leaseOptions\
    \");\
    \n\
    \n# additional globals\
    \n:global \"g-zone\"\
    \n\
    \n# configure dns zone:\
    \n:local fqdn;\
    \n:set fqdn (\$\"g-leaseHostname\" . \".\" . \$\"g-zone\");\
    \n\
    \n:if (\$\"g-leaseHostname\" = \"\" ) do={\
    \n\
    \n    :log info (\"Client \" . \$lease . \" did not provide a hostname\");\
    \n\
    \n} else={\
    \n\
    \n    if ([/ip dns static find name=\$fqdn comment~\"DHCP lease for\"] != \
    \"\") do={\
    \n        :log info (\"DNS A record for \" . \$fqdn . \" is managed by DHC\
    P.\");\
    \n    }\
    \n\
    \n    if ([/ip dns static find name=\$fqdn comment=\"manual\"] != \"\") do\
    ={\
    \n        :log info (\"DNS A record for \" . \$fqdn . \" is manually manag\
    ed, skipping\");\
    \n\
    \n    }  else {\
    \n\
    \n        :if (\$\"g-leaseBound\" = \"1\") do={\
    \n\
    \n            if ([/ip dns static find name=\$fqdn] != \"\") do={\
    \n\
    \n                :log info (\"DNS A record for \" . \$fqdn . \" already e\
    xists, removing old record\");\
    \n\
    \n                /ip dns static remove [find name=\$fqdn];\
    \n\
    \n            }\
    \n\
    \n            :log info (\"Creating DNS A record for \" . \$fqdn . \" -> \
    \" . \$\"g-leaseActIP\");\
    \n            /ip dns static remove [find address=\$\"g-leaseActIP\"];\
    \n            /ip dns static add name=\$fqdn address=\$\"g-leaseActIP\" co\
    mment=(\"DHCP lease for \" . \$\"g-leaseActMAC\") disabled=no;\
    \n\
    \n        } else={\
    \n\
    \n            :log info (\"Removing DNS A record for \" . \$fqdn);\
    \n\
    \n            /ip dns static remove [find name=\$fqdn];\
    \n            /ip dns static remove [find address=\$\"g-leaseActIP\"];\
    \n\
    \n        }\
    \n    }\
    \n}\
    \n"
add dont-require-permissions=no name=dhcp_lease_script_test owner=admin \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source="# manage DNS records for DHCP leases\
    \n#\
    \n# Variables that are accessible for the event script:\
    \n#\
    \n#  leaseBound - set to \"1\" if bound, otherwise set to \"0\"\
    \n#  leaseServerName - DHCP server name\
    \n#  leaseActMAC - active mac address\
    \n#  leaseActIP - active IP address\
    \n#  lease-agent-circuit-id - lease agent circuit ID\
    \n#  lease-agent-remote-id - lease agent remote ID\
    \n#  lease-hostname - client hostname\
    \n#  lease-options - an array of received options\
    \n\
    \n:global \"g-leaseBound\";\
    \n:global \"g-leaseServerName\";\
    \n:global \"g-leaseActMAC\";\
    \n:global \"g-leaseActIP\";\
    \n:global \"g-leaseAgentCircuitID\";\
    \n:global \"g-leaseAgentRemoteID\";\
    \n:global \"g-leaseHostname\";\
    \n:global \"g-leaseOptions\";\
    \n\
    \n# :log info (\"TEST dhcp script: leaseBound -> \" . \$\"g-leaseBound\");\
    \n# :log info (\"TEST dhcp script: leaseServerName -> \" . \$\"g-leaseServ\
    erName\");\
    \n# :log info (\"TEST dhcp script: leaseActMAC -> \" . \$\"g-leaseActMAC\"\
    );\
    \n# :log info (\"TEST dhcp script: leaseActIP -> \" . \$\"g-leaseActIP\");\
    \n# :log info (\"TEST dhcp script: leaseAgentCircuitID -> \" . \$\"g-lease\
    AgentCircuitID\");\
    \n# :log info (\"TEST dhcp script: leaseAgentRemoteID -> \" . \$\"g-leaseA\
    gentRemoteID\");\
    \n# :log info (\"TEST dhcp script: leaseHostname -> \" . \$\"g-leaseHostna\
    me\");\
    \n# :log info (\"TEST dhcp script: leaseOptions -> \" . \$\"g-leaseOptions\
    \");\
    \n\
    \n# additional globals\
    \n:global \"g-zone\"\
    \n\
    \n# configure dns zone:\
    \n:local fqdn;\
    \n:set fqdn (\$\"g-leaseHostname\" . \".\" . \$\"g-zone\");\
    \n\
    \n:if (\$\"g-leaseHostname\" = \"\" ) do={\
    \n\
    \n    :log info (\"Client \" . \$lease . \" did not provide a hostname\");\
    \n\
    \n} else={\
    \n\
    \n    if ([/ip dns static find name=\$fqdn comment~\"DHCP lease for\"] != \
    \"\") do={\
    \n        :log info (\"DNS A record for \" . \$fqdn . \" is managed by DHC\
    P.\");\
    \n    }\
    \n\
    \n    if ([/ip dns static find name=\$fqdn comment=\"manual\"] != \"\") do\
    ={\
    \n        :log info (\"DNS A record for \" . \$fqdn . \" is manually manag\
    ed, skipping\");\
    \n\
    \n    }  else {\
    \n\
    \n        :if (\$\"g-leaseBound\" = \"1\") do={\
    \n\
    \n            if ([/ip dns static find name=\$fqdn] != \"\") do={\
    \n\
    \n                :log info (\"DNS A record for \" . \$fqdn . \" already e\
    xists, removing old record\");\
    \n\
    \n                /ip dns static remove [find name=\$fqdn];\
    \n\
    \n            }\
    \n\
    \n            :log info (\"Creating DNS A record for \" . \$fqdn . \" -> \
    \" . \$\"g-leaseActIP\");\
    \n            /ip dns static remove [find address=\$\"g-leaseActIP\"];\
    \n            /ip dns static add name=\$fqdn address=\$\"g-leaseActIP\" co\
    mment=(\"DHCP lease for \" . \$\"g-leaseActMAC\") disabled=no;\
    \n\
    \n        } else={\
    \n\
    \n            :log info (\"Removing DNS A record for \" . \$fqdn);\
    \n\
    \n            /ip dns static remove [find name=\$fqdn];\
    \n            /ip dns static remove [find address=\$\"g-leaseActIP\"];\
    \n\
    \n        }\
    \n    }\
    \n}\
    \n"
/caps-man manager
set enabled=yes
/caps-man manager interface
set [ find default=yes ] forbid=yes
add disabled=no interface=bridge
/caps-man provisioning
add action=create-dynamic-enabled master-configuration=2.4Ghz radio-mac=\
    C4:AD:34:29:EA:20
add action=create-dynamic-enabled master-configuration=5GHz radio-mac=\
    C4:AD:34:29:EA:1F
/certificate settings
set builtin-trust-store=untrusted
/interface bridge port
add bridge=bridge comment=defconf ingress-filtering=no interface=ether.core \
    internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=ether3 \
    internal-path-cost=10 path-cost=10
add bridge=bridge comment=defconf ingress-filtering=no interface=ether5 \
    internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether.aux
/interface bridge settings
set use-ip-firewall-for-vlan=yes
/ip neighbor discovery-settings
set discover-interface-list=LAN
/ip settings
set rp-filter=strict tcp-syncookies=yes
/ipv6 settings
set disable-ipv6=yes max-neighbor-entries=8192
/interface detect-internet
set internet-interface-list=WAN lan-interface-list=LAN wan-interface-list=WAN
/interface l2tp-server server
set authentication=mschap2 use-ipsec=yes
/interface list member
add comment=defconf interface=bridge list=LAN
add comment=bestgo interface=ether.bestgo list=WAN
add comment=orange interface=pppoe-neostrada list=WAN
add interface=bridge.20-test list=LAN
add interface=bridge.90-guest list=LAN
add interface=bridge.80-iot list=LAN
add interface=ether.core list=LAN
add interface=wireguard-client list=LAN
add interface=wireguard-server list=LAN
add interface=ether.aux list=LAN
/interface ovpn-server server
add auth=sha1,md5 mac-address=FE:BB:7E:21:9F:91 name=ovpn-server1
/interface wireguard peers
add allowed-address=172.17.1.211/32,::/0 client-address=172.17.1.211/0 \
    client-dns=172.16.1.1 client-endpoint=vpn.dotnot.pl comment=S21-Ultra \
    interface=wireguard-server name=S21-Ultra public-key=\
    "kXvX4iPu7rbgDaw2e/GUU3muJEZddrTAHvyRvzyHNi8="
add allowed-address=172.17.1.206/32,::/0 client-address=172.17.1.206/0 \
    client-dns=172.16.1.1 client-endpoint=vpn.dotnot.pl comment=X1-G10 \
    interface=wireguard-server name=X1-G10 public-key=\
    "sEZfpPUDrLuT3lzZMZWWhvW1XTKY5VF46TxNZGgx4Wc="
add allowed-address=172.16.11.0/24,::/0 client-address=172.16.11.2/24 \
    endpoint-address=vps01.cloud.dotnot.pl endpoint-port=51820 interface=\
    wireguard-client name=vps01.cloud.dotnot.pl public-key=\
    "o5bQfE3ysRVi83gAB7rZsaCiIe0L3nlLLlBOUB9x/3c="
add allowed-address=172.17.1.210/32,::/0 client-address=172.17.1.222/0 \
    client-dns=172.16.1.1 client-endpoint=vpn.dotnot.pl comment="S26 Ultra" \
    interface=wireguard-server name="S26 Ultra" public-key=\
    "pLyyw0FX9Zy/RQ8y8PGd6BdbZYc5oSblmHm9VQs6UTE="
/ip address
add address=172.16.1.1/24 comment=defconf interface=bridge network=172.16.1.0
add address=172.16.9.1 interface=bridge network=172.16.9.0
add address=172.17.1.1/24 interface=wireguard-server network=172.17.1.0
add address=172.16.11.1/24 interface=wireguard-client network=172.16.11.0
add address=172.16.20.1/24 interface=bridge.20-test network=172.16.20.0
add address=172.16.80.1/24 interface=bridge.80-iot network=172.16.80.0
add address=172.16.90.1/24 interface=bridge.90-guest network=172.16.90.0
add address=169.254.1.2/16 comment=APIPA interface=bridge network=169.254.0.0
add address=172.16.30.1/24 interface=bridge.30-dev network=172.16.30.0
/ip cloud
set ddns-enabled=yes ddns-update-interval=10m
/ip dhcp-client
add interface=ether.bestgo name=uplink-eth
/ip dhcp-server lease
add address=172.16.1.201 comment="Terra Intel 2.5G" mac-address=\
    D8:5E:D3:87:81:B9 server=dhcp
add address=172.16.1.203 comment="X1 G3 WiFi" mac-address=60:57:18:C2:77:0C \
    server=dhcp
add address=172.16.1.204 comment="X1 G3 ethernet" mac-address=\
    54:EE:75:44:E5:0B server=dhcp
add address=172.16.1.20 comment=RX-A2050 lease-time=1w mac-address=\
    00:A0:DE:D5:5A:55 server=dhcp
add address=172.16.1.4 comment="MiktoTik AP Aux" lease-time=1w mac-address=\
    C4:AD:34:29:EA:1E server=dhcp
add address=172.16.1.205 comment="X1 G3 Dock" mac-address=00:50:B6:70:DD:12 \
    server=dhcp
add address=172.16.1.70 comment="Brother HL-5250DN" mac-address=\
    00:80:77:89:48:1C server=dhcp
add address=172.16.1.19 client-id=1:f8:77:b8:e4:56:88 comment=TV mac-address=\
    F8:77:B8:E4:56:88 server=dhcp
add address=172.16.1.51 comment=forgejo-runner-1 mac-address=\
    52:54:00:05:09:CA server=dhcp
add address=172.16.1.11 comment="NAS secondary" mac-address=24:5E:BE:7D:6A:51 \
    server=dhcp
add address=172.16.1.211 comment="S21 Ultra" mac-address=FA:74:C8:45:20:5D \
    server=dhcp
add address=172.16.1.35 comment="BlueDMX (non-DHCP)" mac-address=\
    10:52:1C:4F:7C:81 server=dhcp
add address=172.16.1.31 comment="Home Assistant" mac-address=\
    7C:D3:0A:22:FD:B5 server=dhcp
add address=172.16.1.9 comment="TP-Link SW" mac-address=6C:5A:B0:37:B5:28 \
    server=dhcp
add address=172.16.1.32 comment="RM4 mini - Office" mac-address=\
    EC:0B:AE:0C:B1:17 server=dhcp
add address=172.16.1.33 comment="RM4 mini - Bedroom" mac-address=\
    EC:0B:AE:6A:8E:0F server=dhcp
add address=172.16.1.34 comment="RM4 mini - TEST" mac-address=\
    EC:0B:AE:0C:D6:51 server=dhcp
add address=172.16.1.36 client-id=1:8c:4b:14:85:14:f0 comment=NEXTUBE \
    mac-address=8C:4B:14:85:14:F0 server=dhcp
add address=172.16.1.206 client-id=1:8c:f8:c5:9b:98:12 comment="X1 G10 WiFi" \
    mac-address=8C:F8:C5:9B:98:12 server=dhcp
add address=172.16.1.208 client-id=1:4:7b:cb:64:48:ba comment="X1 G10 Dock" \
    mac-address=04:7B:CB:64:48:BA server=dhcp
add address=172.16.1.6 comment="MikroTik AP Office" lease-time=1w \
    mac-address=48:A9:8A:B8:BE:EA server=dhcp
add address=172.16.1.212 client-id=1:3c:21:9c:9a:84:c2 comment="Surface GO 3" \
    mac-address=3C:21:9C:9A:84:C2 server=dhcp
add address=172.16.1.202 client-id=1:68:54:5a:a4:30:d0 comment=\
    "Terra Intel WiFi" mac-address=68:54:5A:A4:30:D0 server=dhcp
add address=172.16.1.72 comment="Brother PT-E550WSP" mac-address=\
    38:D5:7A:9E:11:7D server=dhcp
add address=172.16.1.2 comment="Core SW" mac-address=84:78:48:68:AB:1C \
    server=dhcp
add address=172.16.1.7 comment="Zyxel SW Living Room" lease-time=1w \
    mac-address=D8:EC:E5:CB:CF:43 server=dhcp
add address=172.16.1.8 comment="Zyxel SW Office" lease-time=1w mac-address=\
    D8:EC:E5:A1:F3:F3
add address=172.16.1.10 comment="NAS (TVS-h674)" mac-address=\
    24:5E:BE:7D:6A:50 server=dhcp
add address=172.16.1.207 comment="X1 G10 Ethernet" mac-address=\
    9C:2D:CD:1B:29:F5 server=dhcp
add address=172.16.1.5 comment="MiktoTik AP Main" lease-time=1w mac-address=\
    48:A9:8A:CE:17:84 server=dhcp
add address=172.16.1.23 comment="WX-021 Kitchen" mac-address=\
    4C:22:F3:8F:64:AF server=dhcp
add address=172.16.1.22 comment="WX-021 Guest Room" mac-address=\
    AC:B6:87:FF:96:09 server=dhcp
add address=172.16.1.21 comment=WXC-50 mac-address=34:08:E1:27:CC:93 server=\
    dhcp
add address=172.16.1.45 comment=gitea-runner-01 mac-address=52:54:00:63:F0:E8 \
    server=dhcp
add address=172.16.1.25 comment="WXAD-10 Office" mac-address=\
    AC:44:F2:69:58:15 server=dhcp
add address=172.16.80.80 comment="Xiaomi Smart Fan" mac-address=\
    7C:C2:94:95:56:B1 server=vlan.80-iot
add address=172.16.1.24 comment="WX-021 AUX (wired)" mac-address=\
    4C:22:F3:8F:64:AE server=dhcp
add address=172.16.1.26 client-id=1:50:41:1c:ba:15:2e comment="AURGA viewer" \
    mac-address=50:41:1C:BA:15:2E server=dhcp
add address=172.16.80.85 comment="Venta AH535" mac-address=4C:EB:D6:70:85:00 \
    server=vlan.80-iot
add address=172.16.1.30 client-id=1:fc:b4:67:39:5a:40 comment="HA Watchdog" \
    mac-address=FC:B4:67:39:5A:40 server=dhcp
add address=172.16.1.61 comment=arma-reforger-server-1 disabled=yes \
    mac-address=02:42:BC:9E:22:DA server=dhcp
add address=172.16.1.62 comment=arma-reforger-server-2 disabled=yes \
    mac-address=02:42:BC:9E:22:DB server=dhcp
add address=172.16.1.37 client-id=1:0:bb:3a:8:c9:9b mac-address=\
    00:BB:3A:08:C9:9B server=dhcp
add address=172.16.80.91 mac-address=80:65:99:EB:95:7A server=vlan.80-iot
add address=172.16.1.3 comment="Aux SW" mac-address=94:2A:6F:4E:AA:AD server=\
    dhcp
add address=172.16.80.81 mac-address=EC:4D:3E:22:C5:C7 server=vlan.80-iot
add address=172.16.80.92 mac-address=84:F7:03:F5:20:92 server=vlan.80-iot
add address=172.16.1.50 comment=nextcloud-harp mac-address=52:54:00:E8:5B:75 \
    server=dhcp
add address=172.16.1.14 client-id=1:30:5a:3a:c6:8b:10 comment="RT-AC68U RPT" \
    mac-address=30:5A:3A:C6:8B:10 server=dhcp
add address=172.16.1.12 comment=EJBCA mac-address=DE:AD:BE:EF:AA:BB server=\
    dhcp
add address=172.16.20.4 comment="MiktoTik AP Aux" lease-time=1w mac-address=\
    C4:AD:34:29:EA:1F server=vlan.20-test
add address=172.16.20.6 comment="MikroTik AP Office" lease-time=1w \
    mac-address=48:A9:8A:B8:BE:EA server=vlan.20-test
add address=172.16.20.5 comment="MiktoTik AP Main" lease-time=1w mac-address=\
    48:A9:8A:CE:17:88 server=vlan.20-test
add address=172.16.80.6 comment="MikroTik AP Office" mac-address=\
    48:A9:8A:B8:BE:EA server=vlan.80-iot
add address=172.16.80.5 comment="MiktoTik AP Main" mac-address=\
    48:A9:8A:CE:17:88 server=vlan.80-iot
add address=172.16.90.6 comment="MikroTik AP Office" mac-address=\
    48:A9:8A:B8:BE:EA server=vlan.90-guest
add address=172.16.80.71 comment="Brother DCP-T500W" mac-address=\
    E8:9E:B4:17:6F:38 server=vlan.80-iot
add address=172.16.1.221 mac-address=5E:BB:F6:9E:EE:FA server=dhcp
add address=172.16.1.65 comment=starrupture-server disabled=yes mac-address=\
    02:42:BC:9E:22:DA server=dhcp
add address=172.16.1.13 comment=proxmox mac-address=8C:DC:D4:2F:BE:63 server=\
    dhcp
add address=172.16.80.60 comment=Nextube mac-address=8C:4B:14:85:14:F0 \
    server=vlan.80-iot
add address=172.16.1.210 comment="S26 Ultra" mac-address=9C:83:06:FF:9C:D8 \
    server=dhcp
/ip dhcp-server network
add address=172.16.1.0/24 boot-file-name=netboot.xyz.kpxe dhcp-option-set=\
    default dns-server=172.16.1.1 domain=np.dotnot.pl gateway=172.16.1.1 \
    netmask=24 next-server=172.16.1.10 ntp-server=172.16.1.1 wins-server=\
    172.16.1.10
add address=172.16.20.0/24 boot-file-name=netboot.xyz.kpxe dhcp-option-set=\
    default dns-server=172.16.20.1 domain=test.np.dotnot.pl gateway=\
    172.16.20.1 netmask=24 next-server=172.16.1.10 ntp-server=172.16.20.1 \
    wins-server=172.16.1.10
add address=172.16.30.0/24 boot-file-name=netboot.xyz.kpxe dhcp-option-set=\
    default dns-server=172.16.30.1 domain=dev.np.dotnot.pl gateway=\
    172.16.30.1 netmask=24 next-server=172.16.1.10 ntp-server=172.16.30.1 \
    wins-server=172.16.1.10
add address=172.16.80.0/24 boot-file-name=netboot.xyz.kpxe dhcp-option-set=\
    default dns-server=172.16.80.1 domain=iot.dotnot.pl gateway=172.16.80.1 \
    netmask=24 next-server=172.16.1.10 ntp-server=172.16.80.1 wins-server=\
    172.16.1.10
add address=172.16.90.0/24 boot-file-name=netboot.xyz.kpxe dhcp-option-set=\
    default dns-server=172.16.90.1 domain=guest.dotnot.pl gateway=172.16.90.1 \
    netmask=24 next-server=172.16.1.10 ntp-server=172.16.90.1 wins-server=\
    172.16.1.10
add address=172.16.192.0/24 boot-file-name=netboot.xyz.kpxe dhcp-option-set=\
    default dns-server=172.16.192.1 domain=storage.dotnot.pl gateway=\
    172.16.192.1 netmask=24 next-server=172.16.1.10 ntp-server=172.16.192.1 \
    wins-server=172.16.1.10
/ip dns
set allow-remote-requests=yes cache-max-ttl=1h cache-size=8192KiB \
    max-concurrent-queries=512 max-concurrent-tcp-sessions=64 \
    mdns-repeat-ifaces=bridge,bridge.20-test,bridge.80-iot,bridge.90-guest \
    query-server-timeout=1s query-total-timeout=5s servers=\
    1.1.1.1,1.0.0.1,208.67.220.220,208.67.222.222 verify-doh-cert=yes
/ip dns static
add address=172.16.1.1 name=router.np.dotnot.pl type=A
add cname=router.np.dotnot.pl name=time.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=ldap.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=tautulli.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=socks.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=intra.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=bazarr.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=spottarr.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=paperless.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=nexus.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=wpad.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=unifi.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=unifi type=CNAME
add cname=nas.np.dotnot.pl name=unifi-controller.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=esphome.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=plex.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=syslog.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=cloud.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=photos.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=syncthing.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=pihole.np.dotnot.pl type=CNAME
add cname=ldap.np.dotnot.pl name=ldap.dotnot.pl type=CNAME
add cname=ldap.np.dotnot.pl name=piper.np.dotnot.pl type=CNAME
add cname=ldap.np.dotnot.pl name=whisper.np.dotnot.pl type=CNAME
add address=172.16.1.60 regexp=".+\\.play\\.dotnot\\.pl" type=A
add cname=nas.np.dotnot.pl name=ampli.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=opensearch.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=registry.np.dotnot.pl type=CNAME
add cname=KarolKozlowski.np.dotnot.pl name=x1.np.dotnot.pl type=CNAME
add cname=BRWE89EB4176F38.np.dotnot.pl name=DCP-T500W.np.dotnot.pl type=CNAME
add address=172.16.11.2 name=vps01.vpn.dotnot.pl type=A
add cname=nas.np.dotnot.pl name=sonarr.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=radarr.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=logs.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=qbittorrent.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=semaphore.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=open-webui.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl disabled=yes name=chat.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=ollama.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=jellyfin.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=stash.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=kibana.np.dotnot.pl type=CNAME
add address=172.16.1.35 name=dmx.np.dotnot.pl type=A
add cname=home-assistant.np.dotnot.pl name=mqtt.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=prowlarr.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=sabnzbd.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=whisparr.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=wud.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=spotweb.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=kube.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=ruby.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=parsedmarc.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=tdarr.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=metube.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=komodo.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=postgres.np.dotnot.pl type=CNAME
add cname=influxdb2.np.dotnot.pl name=influxdb.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=influxdb2.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=influxdb3.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=influxdb-ui.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=proxy-manager.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=proxy.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=overseerr.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=homepage.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=iso.np.dotnot.pl type=CNAME
add cname=nas.np.dotnot.pl name=pxe.np.dotnot.pl type=CNAME
add address=172.30.0.1 name=nas.vpn.dotnot.pl type=A
add cname=nas.np.dotnot.pl name=stash-vr.np.dotnot.pl type=CNAME
add address=172.16.1.61 name=arma.play.dotnot.pl type=A
add address=172.16.1.36 comment="DHCP lease for 8C:4B:14:85:14:F0" name=\
    esp32-8514F0.np.dotnot.pl type=A
add address=172.16.1.85 comment="DHCP lease for 4C:EB:D6:70:85:00" name=\
    LWx5-device.np.dotnot.pl type=A
add address=172.16.1.143 comment="DHCP lease for EC:DA:3B:07:F3:4C" name=\
    airgradient-open-air-1.np.dotnot.pl type=A
add address=172.16.80.181 comment="DHCP lease for 8C:4B:14:85:14:F0" name=\
    esp32-8514F0.iot.dotnot.pl type=A
add address=172.16.1.196 comment="DHCP lease for 0C:DC:91:CF:C7:00" name=\
    amazon-a252f73283f73767.np.dotnot.pl type=A
add address=172.16.80.196 comment="DHCP lease for 24:D7:EB:0E:4C:2C" name=\
    BroadLink-Remote-6a-8e-0f.np.dotnot.pl type=A
add address=172.16.1.6 comment="DHCP lease for 48:A9:8A:B8:BE:EA" name=\
    tasmota-nspanel-kitchen-3116.iot.dotnot.pl type=A
add address=172.16.80.80 comment="DHCP lease for 7C:C2:94:95:56:B1" name=\
    dmaker-fan-p33_miap56B1.iot.dotnot.pl type=A
add cname=TVS-h674.np.dotnot.pl name=nas.np.dotnot.pl type=CNAME
add address=172.16.1.221 name=terra.wsl.dotnot.pl type=A
add address=172.16.1.4 comment="DHCP lease for C4:AD:34:29:EA:1E" name=\
    mt-ap-aux.np.dotnot.pl type=A
add address=172.16.1.70 comment="DHCP lease for 00:80:77:89:48:1C" name=\
    HL-5250DN.np.dotnot.pl type=A
add address=172.16.1.13 name=pve.np.dotnot.pl type=A
add address=172.16.80.71 comment="DHCP lease for E8:9E:B4:17:6F:38" name=\
    BRWE89EB4176F38.iot.dotnot.pl type=A
add address=172.16.80.194 comment="DHCP lease for 48:26:4C:1B:5C:8A" name=\
    bosch-dishwasher-015080544366012531.iot.dotnot.pl type=A
add address=172.16.80.91 comment="DHCP lease for 80:65:99:EB:95:7A" name=\
    esp32s2-EB957A.iot.dotnot.pl type=A
add address=172.16.80.189 comment="DHCP lease for 00:1F:7B:31:5B:AA" name=\
    Doppler-8ef2463f.iot.dotnot.pl type=A
add address=172.16.1.111 comment="DHCP lease for D8:3A:DD:AF:FA:87" name=\
    sdr.np.dotnot.pl type=A
add address=172.16.1.8 name=zx-sw2.np.dotnot.pl type=A
add address=172.16.1.197 comment="DHCP lease for 10:51:DB:09:48:A4" name=\
    "Perfume genie 3.np.dotnot.pl" type=A
add address=172.16.80.81 comment="DHCP lease for EC:4D:3E:22:C5:C7" name=\
    dmaker-fan-p33_miapC5C7.iot.dotnot.pl type=A
add address=172.16.1.104 comment="DHCP lease for F0:D4:15:10:1F:C6" name=\
    KKOZLOWSKI-NB.np.dotnot.pl type=A
add address=172.16.1.106 comment="DHCP lease for 24:A4:52:00:1D:96" name=\
    Karol-s-Tab-S11.np.dotnot.pl type=A
add address=172.16.80.92 comment="DHCP lease for 84:F7:03:F5:20:92" name=\
    wled-bedroom-1.iot.dotnot.pl type=A
add address=172.16.1.193 comment="DHCP lease for 2C:F7:F1:1D:18:56" name=\
    SenseCAP.np.dotnot.pl type=A
add address=172.16.1.7 comment="DHCP lease for D8:EC:E5:CB:CF:43" name=\
    zx-sw1.np.dotnot.pl type=A
add address=172.16.1.10 comment="DHCP lease for 24:5E:BE:7D:6A:50" name=\
    TVS-h674.np.dotnot.pl type=A
add address=172.16.80.193 comment="DHCP lease for 80:65:99:E9:46:4E" name=\
    airgradient-pro-1.iot.dotnot.pl type=A
add address=172.16.1.31 comment="DHCP lease for 7C:D3:0A:22:FD:B5" name=\
    home-assistant.np.dotnot.pl type=A
add address=172.16.80.195 comment="DHCP lease for A0:76:4E:AF:3A:BC" name=\
    flm-1200.iot.dotnot.pl type=A
add address=172.16.80.184 comment="DHCP lease for 90:15:06:F9:C8:A4" name=\
    bluetooth-proxy-1.iot.dotnot.pl type=A
add address=172.16.80.187 comment="DHCP lease for 08:3A:8D:CB:C4:4F" name=\
    rituals-genie-1.iot.dotnot.pl type=A
add address=172.16.1.50 comment="DHCP lease for 52:54:00:E8:5B:75" name=\
    nextcloud-harp.np.dotnot.pl type=A
add address=172.16.1.51 comment="DHCP lease for 52:54:00:05:09:CA" name=\
    forgejo-runner-1.np.dotnot.pl type=A
add address=172.16.80.199 comment="DHCP lease for 60:01:94:37:BE:45" name=\
    air-monitor-1.iot.dotnot.pl type=A
add address=172.16.1.2 comment="DHCP lease for 84:78:48:68:AB:1C" name=\
    USW-Flex-2.5G-5.np.dotnot.pl type=A
add address=172.16.80.188 comment="DHCP lease for 90:15:06:F9:C9:80" name=\
    bluetooth-proxy-3.iot.dotnot.pl type=A
add address=172.16.80.192 comment="DHCP lease for EC:DA:3B:07:F3:4C" name=\
    airgradient-open-air-1.iot.dotnot.pl type=A
add address=172.16.1.210 comment="DHCP lease for 9C:83:06:FF:9C:D8" name=\
    Karol-s-S26-Ultra.np.dotnot.pl type=A
add address=172.16.80.185 comment="DHCP lease for 24:9E:7D:6E:D7:06" name=\
    roborock-vacuum-a144.iot.dotnot.pl type=A
add address=172.16.1.201 comment="DHCP lease for D8:5E:D3:87:81:B9" name=\
    terra.np.dotnot.pl type=A
/ip firewall address-list
add address=0.0.0.0/8 comment="defconf: RFC6890" list=no_forward_ipv4
add address=169.254.0.0/16 comment="defconf: RFC6890" list=no_forward_ipv4
add address=224.0.0.0/4 comment="defconf: multicast" list=no_forward_ipv4
add address=255.255.255.255 comment="defconf: RFC6890" list=no_forward_ipv4
add address=127.0.0.0/8 comment="defconf: RFC6890" list=bad_ipv4
add address=192.0.0.0/24 comment="defconf: RFC6890" list=bad_ipv4
add address=192.0.2.0/24 comment="defconf: RFC6890 documentation" list=\
    bad_ipv4
add address=198.51.100.0/24 comment="defconf: RFC6890 documentation" list=\
    bad_ipv4
add address=203.0.113.0/24 comment="defconf: RFC6890 documentation" list=\
    bad_ipv4
add address=240.0.0.0/4 comment="defconf: RFC6890 reserved" list=bad_ipv4
add address=0.0.0.0/8 comment="defconf: RFC6890" list=not_global_ipv4
add address=10.0.0.0/8 comment="defconf: RFC6890" list=not_global_ipv4
add address=100.64.0.0/10 comment="defconf: RFC6890" list=not_global_ipv4
add address=169.254.0.0/16 comment="defconf: RFC6890" list=not_global_ipv4
add address=172.16.0.0/12 comment="defconf: RFC6890" list=not_global_ipv4
add address=192.0.0.0/29 comment="defconf: RFC6890" list=not_global_ipv4
add address=192.168.0.0/16 comment="defconf: RFC6890" list=not_global_ipv4
add address=198.18.0.0/15 comment="defconf: RFC6890 benchmark" list=\
    not_global_ipv4
add address=255.255.255.255 comment="defconf: RFC6890" list=not_global_ipv4
add address=224.0.0.0/4 comment="defconf: multicast" list=bad_src_ipv4
add address=255.255.255.255 comment="defconf: RFC6890" list=bad_src_ipv4
add address=0.0.0.0/8 comment="defconf: RFC6890" list=bad_dst_ipv4
add address=224.0.0.0/4 comment="defconf: RFC6890" list=bad_dst_ipv4
add address=172.16.0.0/12 comment="local/VPN subnets" list=local
add address=37.244.28.0/24 comment="Blizzard/Activision game servers" list=\
    blizzard
add address=37.244.54.0/24 comment="Blizzard/Activision game servers" list=\
    blizzard
add address=1.1.1.1 list=dns
add address=1.0.0.1 list=dns
add address=172.16.9.0/24 list=vpn
add address=213.5.40.41 list=dns
add address=213.5.40.45 list=dns
add address=8.8.8.8 list=dns
add address=8.8.4.4 list=dns
add address=172.241.112.0/24 comment=vpnunlimitedapp.com list=drop
add address=77.81.98.70 comment=ro.vpnunlimitedapp.com list=keepsolid
add address=185.144.83.13 comment=ro.vpnunlimitedapp.com list=keepsolid
add address=185.144.83.11 comment=ro.vpnunlimitedapp.com list=keepsolid
add list=allow-bittorrent
add address=87.239.92.78 disabled=yes list=allow_input
add address=95.217.193.20 disabled=yes list=allow_input
add address=195.136.68.11 list=WAN
add address=54.38.52.242 comment=vps01.cloud.dotnot.pl list=allowlist
add address=91.198.174.192 comment=wikimedia list=allowlist
add address=192.0.66.2 comment=wikimedia list=allowlist
add address=109.207.200.47 list=denylist
add address=167.248.133.38 list=denylist
add address=89.64.0.0/13 comment="Maciek (UPC)" list=plex_remote
add address=54.170.120.91 comment="plex discovery" list=plex_remote
add address=46.51.207.89 comment="plex discovery" list=plex_remote
add address=87.239.92.36 comment=Geez list=plex_remote
add address=54.38.52.242 comment=VPS list=plex_remote
add address=65.108.10.92 comment="uptime kuma" disabled=yes list=plex_remote
add address=172.17.0.0/16 list=vpn
add address=87.239.93.91 comment=Geez list=plex_remote
add address=178.43.0.0/16 comment="Michal (Orange)" list=plex_remote
add address=91.90.174.158 comment=Klez list=plex_remote
add address=172.16.1.10 comment="NAS (sabnzbd)" list=syn-protect-exception
add address=80.238.117.0/24 comment=Zonder list=plex_remote
add address=0.0.0.0/0 comment="CIDR ALL" list=plex_remote
add address=37.120.140.54 list=ro.vpnunlimitedapp.com
add address=91.199.50.36 list=ro.vpnunlimitedapp.com
add address=185.144.83.13 list=ro.vpnunlimitedapp.com
add address=185.144.83.11 list=ro.vpnunlimitedapp.com
add address=37.120.140.14 list=ro.vpnunlimitedapp.com
add address=37.120.140.10 list=ro.vpnunlimitedapp.com
add address=77.81.98.70 list=ro.vpnunlimitedapp.com
add address=91.199.50.34 list=ro.vpnunlimitedapp.com
add address=91.199.50.37 list=ro.vpnunlimitedapp.com
add address=172.16.1.201 comment=TERRA list=elevate_dscp_priority
add address=172.16.1.207 comment=X1G10 list=elevate_dscp_priority
add address=172.16.8.0/24 list=vpn
add address=172.16.11.0/24 list=vpn
add address=172.16.1.31 comment=home-assistant list=syn-protect-exception
add address=169.254.0.0/16 comment=APIPA list=apipa
add address=54.219.148.115 list=sandman-allow
/ip firewall filter
add action=accept chain=forward comment="FTP passive data" dst-address=\
    172.16.1.10 dst-port=40000-40010 log=yes log-prefix="FTP passive data" \
    protocol=tcp
add action=accept chain=forward comment=\
    "defconf: accept in that match IPSec policy" disabled=yes ipsec-policy=\
    in,ipsec log-prefix="accept in ipsec policy"
add action=accept chain=forward comment=\
    "defconf: accept out that match IPSec policy" disabled=yes ipsec-policy=\
    out,ipsec
add action=accept chain=forward comment="guest connection fasttrack bypass" \
    connection-mark=guest connection-state=established,related,untracked \
    disabled=yes
add action=accept chain=forward comment="drop traffic from sandman doppler" \
    disabled=yes dst-address-list=sandman-allow log=yes log-prefix=\
    "accpet sandman" out-interface-list=WAN src-address=172.16.80.190
add action=drop chain=forward comment="drop traffic from sandman doppler" \
    disabled=yes dst-address-list=sandman-drop log=yes log-prefix=\
    "drop sandman" out-interface-list=WAN src-address=172.16.80.190
add action=add-dst-to-address-list address-list=sandman-drop \
    address-list-timeout=none-dynamic chain=forward comment=\
    "record sandman outgoing" connection-mark=iot connection-state=\
    established,related,new,untracked disabled=yes dst-address-list=\
    !sandman-drop log=yes log-prefix="record sandman outgoing" \
    out-interface-list=WAN src-address=172.16.80.190
add action=add-src-to-address-list address-list=port_scanners \
    address-list-timeout=23h59m59s chain=forward comment=\
    "SYN Flood protect FTP" connection-state=new disabled=yes dst-port=21 \
    in-interface-list=WAN limit=100/1m,0:packet log=yes log-prefix=\
    "ban FTP scanner" protocol=tcp src-address-list=!allowlist tcp-flags=syn
add action=add-dst-to-address-list address-list=iot-outgoing \
    address-list-timeout=none-dynamic chain=forward comment=\
    "record IoT outgoing IP" connection-mark=iot connection-state=\
    established,related,new,untracked dst-address-list=!iot-outgoing log=yes \
    log-prefix="record IoT outgoing IP" out-interface-list=WAN
add action=accept chain=forward comment="iot connection fasttrack bypass" \
    connection-mark=iot connection-state=established,related,untracked
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" \
    connection-state=established,related,untracked
add action=accept chain=forward comment=\
    "defconf: accept established, related, untracked" connection-state=\
    established,related,untracked
add action=accept chain=forward comment="Allow established/related" \
    connection-state=established,related
add action=accept chain=forward comment="allow WireGuard traffic" \
    src-address-list=vpn
add action=jump chain=forward comment="SYN Flood protect" connection-state=\
    new jump-target=SYN-Protect log-prefix="SYN FLOOD" protocol=tcp \
    tcp-flags=syn
add action=accept chain=forward comment="allow forwarding dicovery" \
    dst-address=239.255.255.250 src-address-list=local
add action=accept chain=forward comment="allow forwarding local traffic" \
    dst-address-list=local src-address-list=local
add action=drop chain=forward comment="drop APIPA (no_forward_ipv4)" \
    disabled=yes dst-address-list=apipa log-prefix="drop APIPA"
add action=drop chain=forward comment="defconf: drop bad forward IPs" \
    dst-address-list=no_forward_ipv4 log-prefix="drop bad forward IPs DST"
add action=drop chain=forward comment="defconf: drop bad forward IPs" log=yes \
    log-prefix="drop bad forward IPs SRC" src-address-list=no_forward_ipv4
add action=drop chain=forward comment=\
    "defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat \
    connection-state=new in-interface-list=WAN log=yes log-prefix=\
    "drop all from WAN not DSTNATed"
add action=drop chain=forward comment="defconf: drop invalid http(s)" \
    connection-state=invalid dst-port=443,80 log-prefix=\
    "drop invalid http(s)" protocol=tcp
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid log-prefix="drop invalid"
add action=accept chain=output comment=\
    "Hurricane Electric IPv6 Tunnel Broker" protocol=ipv6-encap
add action=drop chain=input comment="drop denylist" connection-state=new \
    log-prefix="drop invalid" src-address-list=denylist
add action=accept chain=input comment="allow WireGuard traffic" \
    src-address-list=vpn
add action=accept chain=input comment="allow WireGuard" dst-port=13231 \
    protocol=udp
add action=accept chain=input comment="allow WireGuard traffic" src-address=\
    192.168.100.0/24
add action=accept chain=input comment="Hurricane Electric IPv6 Tunnel Broker" \
    protocol=ipv6-encap src-address=216.66.80.162
add action=accept chain=input comment=\
    "defconf: accept established, related, untracked" connection-state=\
    established,related,untracked
add action=accept chain=input comment="defconf: accept ICMP after RAW" \
    protocol=icmp
add action=accept chain=input comment="ipsec policy matcher" \
    in-interface-list=WAN ipsec-policy=in,ipsec
add action=accept chain=input comment="allow from VPN" connection-state=new \
    in-interface-list=WAN src-address-list=vpn
add action=accept chain=input comment="allow L2TP VPN (500/udp)" dst-port=500 \
    in-interface-list=WAN log=yes log-prefix=VPN protocol=udp
add action=accept chain=input comment="allow L2TP VPN (4500/udp)" dst-port=\
    4500 in-interface-list=WAN log=yes log-prefix=VPN protocol=udp
add action=accept chain=input comment="allow L2TP VPN (ipsec-esp)" \
    in-interface-list=WAN protocol=ipsec-esp
add action=accept chain=input comment="dude server" dst-address=172.16.1.1 \
    dst-port=8291 protocol=tcp src-address=172.16.1.1
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid log-prefix="drop invalid"
add action=reject chain=input comment="drop input from known dns servers" \
    in-interface-list=!LAN log-prefix="DNS callback" protocol=udp \
    reject-with=icmp-port-unreachable src-address-list=dns
add action=add-src-to-address-list address-list=malicious \
    address-list-timeout=23h59m59s chain=input comment="ban dns from WAN" \
    dst-port=53 in-interface-list=!LAN log=yes log-prefix="ban DNS from WAN" \
    protocol=udp psd=5,1m,1,1 src-address-list=!allowlist
add action=add-src-to-address-list address-list=malicious \
    address-list-timeout=10m chain=input comment="ban ssh from WAN" dst-port=\
    22 in-interface-list=!LAN log=yes log-prefix="ban SSH from WAN" protocol=\
    tcp src-address-list=!allowlist
add action=add-src-to-address-list address-list=malicious \
    address-list-timeout=10m chain=input comment="ban HTTP from WAN" \
    disabled=yes dst-port=80,443 in-interface-list=!LAN log=yes log-prefix=\
    "ban HTTP from WAN" protocol=tcp src-address-list=!allowlist
add action=add-src-to-address-list address-list=honey_pot \
    address-list-timeout=23h59m59s chain=input comment="ban tcp honey-pot" \
    connection-state=new dst-port=\
    1433,8080,21,5060,5061,5900,25,53,110,1723,1337,10000,5800,44443,16993 \
    in-interface-list=!LAN log=yes log-prefix="ban TCP honey pot" protocol=\
    tcp src-address-list=!allowlist
add action=add-src-to-address-list address-list=honey_pot \
    address-list-timeout=23h59m59s chain=input comment="ban udp honey-pot" \
    dst-port=123,5060,5061,3478 in-interface-list=!LAN log=yes log-prefix=\
    "ban UDP honey pot" protocol=udp src-address-list=!allowlist
add action=add-src-to-address-list address-list=port_scanners \
    address-list-timeout=23h59m59s chain=input comment=\
    "ban tcp port scanners (fast)" in-interface-list=!LAN log=yes log-prefix=\
    "ban TCP scanner" protocol=tcp psd=50,1m,10,1 src-address-list=!allowlist
add action=add-src-to-address-list address-list=port_scanners \
    address-list-timeout=23h59m59s chain=input comment=\
    "ban udp port scanners (fast)" in-interface-list=!LAN log=yes log-prefix=\
    "ban UDP scanner (fast)" protocol=udp psd=50,1m,10,1 src-address-list=\
    !allowlist
add action=add-src-to-address-list address-list=port_scanners \
    address-list-timeout=23h59m59s chain=input comment=\
    "ban tcp port scanners" in-interface-list=!LAN log=yes log-prefix=\
    "ban TCP scanner (fast)" protocol=tcp psd=150,5m,10,1 src-address-list=\
    !allowlist
add action=add-src-to-address-list address-list=port_scanners \
    address-list-timeout=23h59m59s chain=input comment=\
    "ban udp port scanners" in-interface-list=!LAN log=yes log-prefix=\
    "ban UDP scanner" protocol=udp psd=150,5m,10,1 src-address-list=\
    !allowlist
add action=drop chain=input comment="drop dns from WAN" dst-port=53 \
    in-interface-list=!LAN log=yes log-prefix="drop DNS from WAN" protocol=\
    udp src-address-list=!allowlist
add action=drop chain=input comment="silent drop from drop list" \
    in-interface-list=!LAN log=yes log-prefix="drop not from LAN" \
    src-address-list=drop
add action=drop chain=input comment="defconf: drop all not coming from LAN" \
    in-interface-list=!LAN log-prefix="drop all not coming from LAN" \
    src-address-list=!allowlist
add action=return chain=SYN-Protect comment="SYN Flood protect exception" \
    connection-state=new limit=10k,100:packet protocol=tcp src-address-list=\
    syn-protect-exception tcp-flags=syn
add action=return chain=SYN-Protect comment="SYN Flood protect regular" \
    connection-state=new limit=1k,10:packet protocol=tcp tcp-flags=syn
add action=accept chain=SYN-Protect comment="SYN Flood protect drop" \
    connection-state=new log=yes log-prefix="SYN-protect drop" protocol=tcp \
    tcp-flags=syn
add action=drop chain=SYN-Protect comment="SYN Flood protect drop" \
    connection-state=new log=yes log-prefix="SYN-protect drop" protocol=tcp \
    tcp-flags=syn
/ip firewall mangle
add action=mark-connection chain=forward connection-state=\
    established,related,new dst-address-list=local new-connection-mark=\
    via-local src-address-list=local
add action=mark-connection chain=postrouting connection-state=new \
    new-connection-mark=via-bestgo out-interface=ether.bestgo
add action=mark-connection chain=postrouting connection-state=new \
    new-connection-mark=via-neostrada out-interface=pppoe-neostrada
add action=mark-connection chain=postrouting comment="mark guest connections" \
    connection-state=new new-connection-mark=guest out-interface-list=WAN \
    src-address=172.16.90.0/24
add action=mark-connection chain=postrouting comment="mark iot connections" \
    connection-state=new new-connection-mark=iot out-interface-list=WAN \
    src-address=172.16.80.0/24
add action=mark-packet chain=forward comment="mark local packets" \
    dst-address-list=local new-packet-mark=local src-address-list=local
add action=mark-packet chain=prerouting comment="mark guest-outgoing" \
    connection-mark=guest in-interface-list=LAN new-packet-mark=\
    guest-outgoing passthrough=no
add action=mark-packet chain=prerouting comment="mark iot-outgoing" \
    connection-mark=iot in-interface-list=LAN new-packet-mark=iot-outgoing \
    passthrough=no
add action=mark-packet chain=prerouting comment="mark guest-incoming" \
    connection-mark=guest in-interface-list=WAN new-packet-mark=\
    guest-incoming passthrough=no
add action=mark-packet chain=prerouting comment="mark iot-incoming" \
    connection-mark=iot in-interface-list=WAN new-packet-mark=iot-incoming \
    passthrough=no
add action=sniff-tzsp chain=prerouting comment=FTP connection-state="" \
    disabled=yes dst-address-list=WAN dst-port=21 protocol=tcp sniff-target=\
    172.16.1.201 sniff-target-port=37008
add action=sniff-tzsp chain=postrouting comment=FTP connection-state="" \
    disabled=yes dst-address-list=local dst-port=21 protocol=tcp \
    sniff-target=172.16.1.201 sniff-target-port=37008
add action=sniff-tzsp chain=prerouting comment=FTP connection-state="" \
    disabled=yes protocol=tcp sniff-target=172.16.1.201 sniff-target-port=\
    37008 src-address-list=local src-port=21
add action=sniff-tzsp chain=postrouting comment=FTP connection-state="" \
    disabled=yes dst-address-list=WAN protocol=tcp sniff-target=172.16.1.201 \
    sniff-target-port=37008 src-port=21
add action=sniff-tzsp chain=input connection-state=invalid disabled=yes log=\
    yes log-prefix=sniff sniff-target=172.16.1.205 sniff-target-port=37008 \
    src-address=!54.38.52.242
add action=sniff-tzsp chain=forward connection-state=invalid disabled=yes \
    log=yes log-prefix=sniff sniff-target=172.16.1.205 sniff-target-port=\
    37008 src-address=!54.38.52.242
add action=change-dscp chain=prerouting comment="Default DSCP" disabled=yes \
    log-prefix=MW new-dscp=1 src-address=172.16.1.201
add action=change-dscp chain=postrouting comment=Torrent disabled=yes \
    dst-address-list=ro.vpnunlimitedapp.com log-prefix=MW new-dscp=0 \
    passthrough=no
add action=change-dscp chain=postrouting comment=Blizzard/Activision \
    disabled=yes dst-address-list=blizzard log-prefix=MW new-dscp=16
add action=change-dscp chain=postrouting comment="Elevate DCSP priority" \
    disabled=yes new-dscp=8 src-address-list=elevate_dscp_priority
/ip firewall nat
add action=accept chain=srcnat comment="VPN NAT bypass" dst-address=\
    172.16.9.0/24 log-prefix=VPN src-address=172.16.1.0/24
add action=accept chain=srcnat comment="VPN NAT bypass" dst-address-list=vpn \
    log-prefix=VPN src-address=172.16.1.0/24
add action=accept chain=srcnat comment=\
    "defconf: accept all that matches IPSec policy" ipsec-policy=out,ipsec
add action=masquerade chain=srcnat comment="defconf: masquerade" \
    out-interface=ether.bestgo
add action=masquerade chain=srcnat comment="defconf: masquerade" \
    out-interface=pppoe-neostrada
add action=masquerade chain=srcnat comment="Standing Fan 2 Pro Office" \
    dst-address=172.16.80.81
add action=masquerade chain=srcnat comment="Standing Fan 2 Pro Bedroom" \
    dst-address=172.16.80.80
add action=dst-nat chain=dstnat comment="Starship EVO: dstnat 7777/udp" \
    dst-port=7777 in-interface-list=WAN log=yes log-prefix="Starship EVO UDP" \
    protocol=udp to-addresses=172.16.1.201 to-ports=7777
add action=dst-nat chain=dstnat comment="Starship EVO: dstnat 7777/tcp" \
    dst-port=7777 in-interface-list=WAN log=yes log-prefix="Starship EVO TCP" \
    protocol=tcp to-addresses=172.16.1.201 to-ports=7777
add action=dst-nat chain=dstnat comment="StarRupture: dstnat 7777/udp" \
    disabled=yes dst-port=7777 in-interface-list=WAN protocol=udp \
    to-addresses=172.16.1.65 to-ports=7777
add action=dst-nat chain=dstnat comment=\
    "StarRupture: hairpin dstnat 7777/udp" disabled=yes dst-address=\
    195.136.68.11 dst-port=7777 protocol=udp to-addresses=172.16.1.65
add action=src-nat chain=srcnat comment=\
    "StarRupture: hairpin srcnat 7777/udp" disabled=yes dst-address=\
    172.16.1.65 dst-port=7777 protocol=udp to-addresses=172.16.1.1
add action=dst-nat chain=dstnat comment="StarRupture: dstnat 27015/udp" \
    dst-port=27015 in-interface-list=WAN protocol=udp to-addresses=\
    172.16.1.65 to-ports=27015
add action=dst-nat chain=dstnat comment=\
    "StarRupture: hairpin dstnat 27015/udp" dst-address=195.136.68.11 \
    dst-port=27015 protocol=udp to-addresses=172.16.1.65 to-ports=27015
add action=src-nat chain=srcnat comment=\
    "StarRupture: hairpin srcnat 27015/udp" dst-address=172.16.1.65 dst-port=\
    27015 protocol=udp to-addresses=172.16.1.1
add action=dst-nat chain=dstnat comment=Plex disabled=yes dst-port=32400 \
    in-interface-list=WAN log=yes log-prefix=plex-allow protocol=tcp \
    src-address-list=plex_remote to-addresses=172.16.1.10 to-ports=32400
add action=dst-nat chain=dstnat comment=Plex dst-port=32400 \
    in-interface-list=WAN log-prefix=plex-allow-TEMP protocol=tcp \
    to-addresses=172.16.1.10 to-ports=32400
add action=dst-nat chain=dstnat comment="Plex hairpin NAT" dst-address=\
    195.136.68.11 dst-address-type="" dst-port=32400 log-prefix=\
    "Plex hairpin dst-nat" protocol=tcp to-addresses=172.16.1.10
add action=src-nat chain=srcnat comment="Plex hairpin NAT" dst-address=\
    172.16.1.10 dst-address-type="" dst-port=32400 log-prefix=\
    "Plex hairpin src-nat" protocol=tcp to-addresses=172.16.1.1
add action=dst-nat chain=dstnat comment="FTP control + passive" dst-port=\
    21,40000-40010 in-interface-list=WAN log=yes log-prefix=\
    "FTP dst-nat public" protocol=tcp to-addresses=172.16.1.10
add action=dst-nat chain=dstnat comment="FTP control + passive hairpin NAT" \
    dst-address=195.136.68.11 dst-address-type="" dst-port=21,40000-40010 \
    log=yes log-prefix="FTP dst-nat" protocol=tcp to-addresses=172.16.1.10
add action=src-nat chain=srcnat comment="FTP control + passive hairpin NAT" \
    dst-address=172.16.1.10 dst-address-type="" dst-port=21,40000-40010 log=\
    yes log-prefix="FTP src-nat" protocol=tcp to-addresses=172.16.1.1
add action=dst-nat chain=dstnat comment="Arma Reforger 1" dst-port=2001,17777 \
    in-interface-list=WAN protocol=udp to-addresses=172.16.1.61
add action=dst-nat chain=dstnat comment="Arma Reforger 1 hairpin NAT" \
    dst-address=195.136.68.11 dst-address-type="" dst-port=2001,17777,19999 \
    log=yes log-prefix="HAIRPIN Reforger" protocol=udp to-addresses=\
    172.16.1.61
add action=src-nat chain=srcnat comment="Arma Reforger 1 hairpin NAT" \
    dst-address=172.16.1.61 dst-port=2001,17777,19999 log=yes log-prefix=\
    "HAIRPIN Reforger" protocol=udp to-addresses=172.16.1.1
add action=dst-nat chain=dstnat comment="Arma Reforger 2" dst-port=2002,17778 \
    in-interface-list=WAN protocol=udp to-addresses=172.16.1.62
add action=dst-nat chain=dstnat comment="Arma Reforger 2 hairpin NAT" \
    dst-address=195.136.68.11 dst-address-type="" dst-port=2002,17778 log=yes \
    log-prefix="HAIRPIN Reforger" protocol=udp to-addresses=172.16.1.62
add action=src-nat chain=srcnat comment="Arma Reforger 2 hairpin NAT" \
    dst-address=172.16.1.62 dst-port=2002,17778 log=yes log-prefix=\
    "HAIRPIN Reforger" protocol=udp to-addresses=172.16.1.1
add action=dst-nat chain=dstnat comment="CoD: Modern Warfare" dst-port=\
    3074,27014-27050 in-interface-list=WAN protocol=tcp to-addresses=\
    172.16.1.201
add action=dst-nat chain=dstnat comment="CoD: Modern Warfare" dst-port=\
    3074,3478,4379-4380,27000-27031,27036 in-interface-list=WAN protocol=udp \
    to-addresses=172.16.1.201
add action=dst-nat chain=dstnat comment=factorio disabled=yes \
    dst-address-type=local dst-port=34197 in-interface-list=WAN protocol=udp \
    to-addresses=172.16.1.61
/ip firewall raw
add action=accept chain=prerouting log=yes log-prefix=XXX protocol=icmp \
    src-address=54.38.52.242
add action=notrack chain=prerouting comment="VPN/local ConnTrack bypass" \
    disabled=yes dst-address-list=local src-address-list=local
add action=accept chain=prerouting comment=\
    "defconf: enable for transparent firewall" disabled=yes
add action=drop chain=prerouting comment="drop silent 255.255.255.255:48000" \
    disabled=yes dst-address=255.255.255.255 dst-port=48000 log-prefix=\
    "drop 255.255.255.255:48000" protocol=udp
add action=accept chain=prerouting comment="defconf: accept DHCP discover" \
    dst-address=255.255.255.255 dst-port=67 in-interface-list=LAN protocol=\
    udp src-address=0.0.0.0 src-port=68
add action=accept chain=prerouting comment="accept SSDP from LAN" \
    dst-address=239.255.255.250 dst-port=1900 in-interface-list=LAN \
    log-prefix="accept SSDP from LAN" protocol=udp
add action=drop chain=prerouting comment="drop SSDP from WAN" dst-address=\
    239.255.255.250 dst-port=1900 in-interface-list=WAN log-prefix=\
    "drop SSDP from WAN" protocol=udp
add action=drop chain=prerouting comment="block port scanners" \
    in-interface-list=WAN log-prefix="block port scanners" src-address-list=\
    port_scanners
add action=drop chain=prerouting comment="block malicious" in-interface-list=\
    WAN log-prefix="drop malicious" src-address-list=malicious
add action=drop chain=prerouting comment="block honey pot" in-interface-list=\
    WAN log-prefix="drop honey_pot" src-address-list=honey_pot
add action=drop chain=prerouting comment="defconf: drop bogon IP's" \
    in-interface-list=WAN log=yes log-prefix="drop bad_ipv4 src" \
    src-address-list=bad_ipv4
add action=drop chain=prerouting comment="defconf: drop bogon IP's" \
    dst-address-list=bad_ipv4 in-interface-list=WAN log=yes log-prefix=\
    "drop bad_ipv4 dst"
add action=drop chain=prerouting comment="defconf: drop bogon IP's" \
    in-interface-list=WAN log=yes log-prefix="drop bad_src_ipv4" \
    src-address-list=bad_src_ipv4
add action=drop chain=prerouting comment="defconf: drop bogon IP's" \
    dst-address-list=bad_dst_ipv4 in-interface-list=WAN log=yes log-prefix=\
    "drop bad_dst_ipv4"
add action=accept chain=prerouting comment="Allow from BestGO router" \
    dst-address=192.168.1.101 in-interface=ether.bestgo src-address=\
    192.168.1.100
add action=accept chain=prerouting comment="Allow decoded IPSec" disabled=yes \
    in-interface-list=WAN src-address-list=vpn
add action=accept chain=prerouting comment="accept UPNP 255.255.255.255:1900" \
    dst-address=255.255.255.255 dst-port=1900 in-interface-list=LAN log=yes \
    log-prefix="accpet UPNP" protocol=udp
add action=drop chain=prerouting comment="defconf: drop non global from WAN" \
    in-interface-list=WAN log=yes log-prefix="drop not_global_ipv4" \
    src-address-list=not_global_ipv4
add action=drop chain=prerouting comment=\
    "defconf: drop forward to local lan from WAN" dst-address-list=local \
    in-interface-list=WAN log=yes log-prefix="drop fwd lan from wan"
add action=drop chain=prerouting comment=\
    "defconf: drop local if not from default IP range" in-interface-list=LAN \
    log=yes log-prefix="drop local if not from default IP range" \
    src-address-list=!local
add action=drop chain=prerouting comment="defconf: drop bad UDP" log=yes \
    log-prefix="drop bad UDP" port=0 protocol=udp
add action=jump chain=prerouting comment="defconf: jump to ICMP chain" \
    jump-target=icmp4 protocol=icmp
add action=jump chain=prerouting comment="defconf: jump to TCP chain" \
    jump-target=bad_tcp protocol=tcp
add action=accept chain=prerouting comment=\
    "defconf: accept everything else from LAN" in-interface-list=LAN
add action=accept chain=prerouting comment=\
    "defconf: accept everything else from WAN" in-interface-list=WAN \
    log-prefix=accept
add action=drop chain=prerouting comment="defconf: drop the rest" log=yes \
    log-prefix="drop rest"
add action=drop chain=bad_tcp comment="defconf: TCP flag filter" log=yes \
    log-prefix="drop TCP flag filter" protocol=tcp tcp-flags=\
    !fin,!syn,!rst,!ack
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,syn
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,rst
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,!ack
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,urg
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=syn,rst
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=rst,urg
add action=drop chain=bad_tcp comment="defconf: TCP port 0 drop" port=0 \
    protocol=tcp
add action=accept chain=bad_tcp comment="defconf: TCP accept" protocol=tcp
add action=accept chain=icmp4 comment="defconf: echo" icmp-options=8:0 limit=\
    5,10:packet protocol=icmp
add action=accept chain=icmp4 comment="defconf: echo" icmp-options=8:0 limit=\
    5,10:packet protocol=icmp
add action=accept chain=icmp4 comment="defconf: port unreachable" \
    icmp-options=3:3 protocol=icmp
add action=accept chain=icmp4 comment="defconf: host unreachable" \
    icmp-options=3:1 protocol=icmp
add action=accept chain=icmp4 comment="defconf: net unreachable" \
    icmp-options=3:0 protocol=icmp
add action=accept chain=icmp4 comment="defconf: time exceeded " icmp-options=\
    11:0-255 protocol=icmp
add action=accept chain=icmp4 comment="defconf: echo reply" icmp-options=0:0 \
    limit=5,10:packet protocol=icmp
add action=accept chain=icmp4 comment="defconf: protocol unreachable" \
    icmp-options=3:2 protocol=icmp
add action=accept chain=icmp4 comment="defconf: fragmentation needed" \
    icmp-options=3:4 protocol=icmp
add action=accept chain=icmp4 comment="accept ICMP from allowlist" log=yes \
    log-prefix="accept ICMP from allowlist" protocol=icmp src-address-list=\
    allowlist
add action=accept chain=icmp4 comment="defconf: drop other icmp" log=yes \
    log-prefix=XXX protocol=icmp src-address=172.16.1.201
add action=drop chain=icmp4 comment="defconf: drop other icmp" log=yes \
    log-prefix="drop other ICMP" protocol=icmp
/ip firewall service-port
set ftp disabled=yes
set irc disabled=no
/ip ipsec identity
add auth-method=digital-signature certificate=vpn.dotnot.pl-2022 comment=\
    vps01.cloud.dotnot.pl generate-policy=port-strict match-by=certificate \
    mode-config=vps01.cloud.dotnot.pl peer=ikev2.dotnot.pl \
    remote-certificate=vps01.cloud.dotnot.pl-2022 remote-id=ignore
add auth-method=digital-signature certificate=vpn.dotnot.pl-2022 comment=X1G3 \
    generate-policy=port-strict match-by=certificate mode-config=\
    ikev2.dotnot.pl peer=ikev2.dotnot.pl remote-certificate=X1-2022
add auth-method=digital-signature certificate=vpn.dotnot.pl-2022 comment=\
    mikrus01.cloud.dotnot.pl generate-policy=port-strict match-by=certificate \
    mode-config=mikrus01.cloud.dotnot.pl peer=ikev2.dotnot.pl \
    remote-certificate=mikrus01.cloud.dotnot.pl-2022 remote-id=ignore
add auth-method=digital-signature certificate=vpn.dotnot.pl-2022 comment=S10+ \
    generate-policy=port-strict match-by=certificate mode-config=\
    ikev2.dotnot.pl peer=ikev2.dotnot.pl remote-certificate=S10p
add auth-method=digital-signature certificate=vpn.dotnot.pl-2022 comment=\
    S21Ultra generate-policy=port-strict match-by=certificate mode-config=\
    ikev2.dotnot.pl peer=ikev2.dotnot.pl remote-certificate=S21Ultra-2024
add auth-method=digital-signature certificate=vpn.dotnot.pl-2022 comment=\
    pluto generate-policy=port-strict match-by=certificate mode-config=\
    ikev2.dotnot.pl peer=ikev2.dotnot.pl remote-certificate=\
    pluto.vpn.dotnot.pl-2025
add auth-method=digital-signature certificate=vpn.dotnot.pl-2022 comment=\
    X1G10 generate-policy=port-strict match-by=certificate mode-config=\
    ikev2.dotnot.pl peer=ikev2.dotnot.pl remote-certificate=\
    x1g10.vpn.dotnot.pl-2022
/ip ipsec policy
set 0 disabled=yes dst-address=172.16.9.0/24 src-address=0.0.0.0/0
add disabled=yes dst-address=172.16.9.3/32 level=unique peer=ikev2.dotnot.pl \
    src-address=172.16.0.0/16 tunnel=yes
/ip route
add check-gateway=ping comment=PRIMARY disabled=no distance=1 dst-address=\
    0.0.0.0/0 gateway=192.168.1.100 routing-table=main scope=30 target-scope=\
    10
add check-gateway=ping comment=FAILOVER disabled=no distance=2 dst-address=\
    0.0.0.0/0 gateway=pppoe-neostrada routing-table=main scope=30 \
    target-scope=10 vrf-interface=pppoe-neostrada
add disabled=no distance=1 dst-address=0.0.0.0/0 gateway=192.168.1.100 \
    routing-table=via_primary scope=30 target-scope=10
add disabled=no distance=2 dst-address=0.0.0.0/0 gateway=pppoe-neostrada \
    routing-table=via_failover scope=30 target-scope=10
/ipv6 route
add disabled=no distance=1 dst-address=2000::/3 gateway=2001:470:70:22f::1 \
    routing-table=main scope=30 target-scope=10
/ip service
set api-ssl disabled=yes
/ip ssh
set strong-crypto=yes
/ip upnp
set enabled=yes
/ip upnp interfaces
add forced-ip=195.136.68.11 interface=ether.bestgo type=external
add interface=bridge type=internal
/ipv6 dhcp-client
add add-default-route=yes interface=*2E pool-name=neostrada-ipv6 \
    pool-prefix-length=56 request=prefix
/ipv6 firewall address-list
add address=::/128 comment="defconf: unspecified address" list=bad_ipv6
add address=::1/128 comment="defconf: lo" list=bad_ipv6
add address=fec0::/10 comment="defconf: site-local" list=bad_ipv6
add address=::ffff:0.0.0.0/96 comment="defconf: ipv4-mapped" list=bad_ipv6
add address=::/96 comment="defconf: ipv4 compat" list=bad_ipv6
add address=100::/64 comment="defconf: discard only " list=bad_ipv6
add address=2001:db8::/32 comment="defconf: documentation" list=bad_ipv6
add address=2001:10::/28 comment="defconf: ORCHID" list=bad_ipv6
add address=3ffe::/16 comment="defconf: 6bone" list=bad_ipv6
/ipv6 firewall filter
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="defconf: accept ICMPv6" protocol=\
    icmpv6
add action=accept chain=input comment="defconf: accept UDP traceroute" port=\
    33434-33534 protocol=udp
add action=accept chain=input comment=\
    "defconf: accept DHCPv6-Client prefix delegation." dst-port=546 protocol=\
    udp src-address=fe80::/10
add action=accept chain=input comment="defconf: accept IKE" dst-port=500,4500 \
    protocol=udp
add action=accept chain=input comment="defconf: accept ipsec AH" protocol=\
    ipsec-ah
add action=accept chain=input comment="defconf: accept ipsec ESP" protocol=\
    ipsec-esp
add action=accept chain=input comment=\
    "defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=input comment=\
    "defconf: drop everything else not coming from LAN" in-interface-list=\
    !LAN
add action=accept chain=forward comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=drop chain=forward comment=\
    "defconf: drop packets with bad src ipv6" src-address-list=bad_ipv6
add action=drop chain=forward comment=\
    "defconf: drop packets with bad dst ipv6" dst-address-list=bad_ipv6
add action=drop chain=forward comment="defconf: rfc4890 drop hop-limit=1" \
    hop-limit=equal:1 protocol=icmpv6
add action=accept chain=forward comment="defconf: accept ICMPv6" protocol=\
    icmpv6
add action=accept chain=forward comment="defconf: accept HIP" protocol=139
add action=accept chain=forward comment="defconf: accept IKE" dst-port=\
    500,4500 protocol=udp
add action=accept chain=forward comment="defconf: accept ipsec AH" protocol=\
    ipsec-ah
add action=accept chain=forward comment="defconf: accept ipsec ESP" protocol=\
    ipsec-esp
add action=accept chain=forward comment=\
    "defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
/ipv6 nd
set [ find default=yes ] advertise-dns=yes interface=bridge mtu=1420
/routing igmp-proxy interface
add interface=bridge upstream=yes
add interface=bridge.20-test
add interface=bridge.80-iot
add interface=bridge.90-guest
/routing rule
add action=lookup-only-in-table comment="via primary" disabled=yes \
    src-address=172.16.1.201/32 table=via_primary
add action=lookup-only-in-table comment="via failover" disabled=yes \
    src-address=172.16.1.201/32 table=via_failover
add action=lookup-only-in-table comment=netwatch disabled=no dst-address=\
    213.5.46.1/32 table=via_primary
add action=lookup-only-in-table comment=netwatch disabled=no dst-address=\
    88.220.36.153/32 table=via_primary
add action=lookup-only-in-table comment="primary dns via primary" disabled=no \
    dst-address=208.67.220.222/32 table=via_primary
add action=lookup-only-in-table comment="primary dns via primary" disabled=no \
    dst-address=1.1.1.1/32 table=via_primary
add action=lookup-only-in-table comment="secondary dns via failover" \
    disabled=no dst-address=208.67.222.123/32 table=via_failover
add action=lookup-only-in-table comment="secondary dns via failover" \
    disabled=no dst-address=1.0.0.1/32 table=via_failover
add action=lookup-only-in-table disabled=no src-address=::/0 table=main
add action=lookup-only-in-table comment="ddns via failover" disabled=no \
    dst-address=159.148.147.0/24 table=via_failover
/snmp
set enabled=yes
/system clock
set time-zone-name=Europe/Warsaw
/system identity
set name=mt-router
/system logging
set 0 action=disk topics=info,!firewall
set 1 action=disk
set 2 action=disk
add action=elk topics=ipsec,!debug
add action=firewall topics=firewall
add action=disk topics=critical
add action=elk topics=warning
add action=elk topics=info
add action=elk topics=error
add action=elk topics=critical
add action=elk topics=system
add disabled=yes topics=ipsec,!packet
/system ntp client
set enabled=yes
/system ntp server
set enabled=yes manycast=yes
/system ntp client servers
add address=tempus1.gum.gov.pl
add address=tempus2.gum.gov.pl
/system scheduler
add interval=1m name=healthchecks.io on-event=\
    "/system script run healthchecks.io" policy=ftp,read,write,policy,test \
    start-date=2020-01-01 start-time=00:00:00
add disabled=yes interval=1m name=warnings on-event=\
    "/system script run warnings" policy=read,write,policy,test start-date=\
    2020-01-01 start-time=00:00:00
add interval=1m name=kuma on-event="/system script run kuma" policy=\
    ftp,read,write,policy,test start-date=2020-01-01 start-time=00:00:00
add interval=1w name="weelky reboot" on-event="/system reboot" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2020-01-05 start-time=04:45:00
add disabled=yes interval=1d name=schedule1 on-event=\
    "/system/scheduler/disable warnings" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2025-01-13 start-time=23:59:59
/system watchdog
set automatic-supout=no watch-address=172.16.1.2 watchdog-timer=no
/tool bandwidth-server
set authenticate=no enabled=no
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
/tool netwatch
add disabled=no down-script="# Logging\
    \n:log error \"PRIMARY intreface DOWN.\"\
    \n\
    \n/system script run beep_primary_down\
    \n\
    \n/interface disable pppoe-neostrada\
    \n/interface enable pppoe-neostrada\
    \n\
    \n# disable primary route\
    \n/ip route disable [/ip route find comment=\"PRIMARY\"]\
    \n\
    \n# delete primary routes\
    \n/ip route remove  [/ip route find gateway=[/ip route get [/ip route find\
    \_comment=\"PRIMARY\" ] gateway ] dynamic=yes ] \
    \n\
    \n# flush connection tracking\
    \n/ip firewall connection remove [find]\
    \n\
    \n:global gotifySource \"np.dotnot.pl\";\
    \n:global gotifyService \"BestGo\";\
    \n:global gotifyState \"DOWN\";\
    \n:delay 10000ms;\
    \n/system script run gotify\
    \n" host=88.220.36.153 http-codes="" interval=5s name="" startup-delay=0s \
    test-script="" timeout=2s type=simple up-script="# Logging\
    \n\
    \n:log warning \"PRIMARY intreface UP.\"\
    \n/system script run beep_primary_up\
    \n# 192.168.1.100\
    \n# 178.216.40.86\
    \n# 213.5.46.1\
    \n# 88.220.36.153\
    \n# enable primary route\
    \n/ip route enable [/ip route find comment=\"PRIMARY\"]\
    \n\
    \n# flush connection tracking\
    \n/ip firewall connection remove [find]\
    \n\
    \n:global gotifySource \"np.dotnot.pl\";\
    \n:global gotifyService \"BestGo\";\
    \n:global gotifyState \"UP\";\
    \n/system script run gotify\
    \n"
/tool sms
set port=*8 receive-enabled=yes
/tool sniffer
set filter-dst-ip-address=!172.16.0.0/12 filter-interface=bridge.80-iot \
    streaming-enabled=yes streaming-server=172.16.1.201:5555
