:local SSID "HypnoTest"
:local password "testzone"
:local wirelessMaster "5GHz"
:local ethernetMaster "ether1"
:local networkName "test"
:local vlanID 20
:local authenticationTypes "wpa2-psk,wpa3-psk"
:local encryption "ccmp,gcmp,ccmp-256,gcmp-256"

/interface vlan
add arp=enabled disabled=no interface=$ethernetMaster  name="$ethernetMaster.$vlanID-$networkName" vlan-id=$vlanID

/interface wifi security
add authentication-types=$authenticationTypes disabled=no encryption=$encryption ft=yes ft-over-ds=yes group-encryption=ccmp name=$SSID wps=disable passphrase=$password

/interface wifi configuration
add channel=5GHz-AX country=Poland disabled=no mode=ap name=$SSID security=$SSID ssid=$SSID

/interface wifi
add configuration=$SSID configuration.mode=ap disabled=no master-interface=$wirelessMaster name=$SSID security=$SSID


/interface bridge
add name="bridge.$vlanID-$networkName"

/interface bridge port
add bridge="bridge.$vlanID-$networkName" interface=$SSID pvid=$vlanID
add bridge="bridge.$vlanID-$networkName" interface="$ethernetMaster.$vlanID-$networkName"

/ip dhcp-client
add interface="bridge.$vlanID-$networkName" disabled=yes
