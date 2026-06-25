# Generic VLAN provisioning script for current config convention:
# - VLAN interface name: bridge.<vlan_id>-<canonic_name>
# - DHCP pool/server name: vlan.<vlan_id>-<canonic_name>
# - Subnet: 172.16.<vlan_id>.0/24

:local vlanID 192
:local canonicName "storage"
:local parentInterface "bridge"

:local gatewayHost 1
:local poolStart 100
:local poolEnd 199
:local dhcpLeaseTime "1h"

:local addToInterfaceList true
:local interfaceListName "LAN"

:local dhcpOptionSet "default"
:local dnsServer "172.16.1.1"
:local domain ($canonicName . ".dotnot.pl")

:if (($vlanID < 1) or ($vlanID > 4094)) do={
    :error "vlanID must be in range 1..4094"
}

:if (($gatewayHost < 1) or ($gatewayHost > 254)) do={
    :error "gatewayHost must be in range 1..254"
}

:if (($poolStart < 2) or ($poolEnd > 254) or ($poolStart >= $poolEnd)) do={
    :error "invalid poolStart/poolEnd values"
}

:if ([:len [/interface find where name=$parentInterface]] = 0) do={
    :error ("parent interface not found: " . $parentInterface)
}

:local vlanInterfaceName ("bridge." . $vlanID . "-" . $canonicName)
:local poolName ("vlan." . $vlanID . "-" . $canonicName)
:local dhcpServerName $poolName

:local networkAddress ("172.16." . $vlanID . ".0")
:local subnetCidr ($networkAddress . "/24")
:local gatewayAddress ("172.16." . $vlanID . "." . $gatewayHost)
:local gatewayCidr ($gatewayAddress . "/24")
:local poolRange ("172.16." . $vlanID . "." . $poolStart . "-172.16." . $vlanID . "." . $poolEnd)

:if ([:len [/interface vlan find where name=$vlanInterfaceName]] = 0) do={
    /interface vlan add interface=$parentInterface name=$vlanInterfaceName vlan-id=$vlanID
    :put ("Created VLAN interface: " . $vlanInterfaceName)
} else={
    :put ("VLAN interface already exists: " . $vlanInterfaceName)
}

:if ([:len [/ip address find where interface=$vlanInterfaceName and address=$gatewayCidr]] = 0) do={
    /ip address add address=$gatewayCidr interface=$vlanInterfaceName network=$networkAddress
    :put ("Created gateway IP: " . $gatewayCidr)
} else={
    :put ("Gateway IP already exists: " . $gatewayCidr)
}

:if ([:len [/ip pool find where name=$poolName]] = 0) do={
    /ip pool add name=$poolName ranges=$poolRange
    :put ("Created DHCP pool: " . $poolName . " (" . $poolRange . ")")
} else={
    :put ("DHCP pool already exists: " . $poolName)
}

:if ([:len [/ip dhcp-server find where name=$dhcpServerName]] = 0) do={
    /ip dhcp-server add address-pool=$poolName dhcp-option-set=$dhcpOptionSet interface=$vlanInterfaceName lease-time=$dhcpLeaseTime name=$dhcpServerName
    :put ("Created DHCP server: " . $dhcpServerName)
} else={
    :put ("DHCP server already exists: " . $dhcpServerName)
}

:if ([:len [/ip dhcp-server network find where address=$subnetCidr]] = 0) do={
    /ip dhcp-server network add address=$subnetCidr dhcp-option-set=$dhcpOptionSet dns-server=$dnsServer domain=$domain gateway=$gatewayAddress
    :put ("Created DHCP network: " . $subnetCidr)
} else={
    :put ("DHCP network already exists: " . $subnetCidr)
}

:if ($addToInterfaceList = true) do={
    :if ([:len [/interface list find where name=$interfaceListName]] = 0) do={
        :error ("interface list not found: " . $interfaceListName)
    }

    :if ([:len [/interface list member find where list=$interfaceListName and interface=$vlanInterfaceName]] = 0) do={
        /interface list member add list=$interfaceListName interface=$vlanInterfaceName
        :put ("Added interface to list: " . $interfaceListName)
    } else={
        :put ("Interface already in list: " . $interfaceListName)
    }
}

:put ("Done: " . $vlanInterfaceName . " / " . $subnetCidr)