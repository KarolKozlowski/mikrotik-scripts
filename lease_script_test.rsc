# manage DNS records for DHCP leases
#
# Variables that are accessible for the event script:
#
#  leaseBound - set to "1" if bound, otherwise set to "0"
#  leaseServerName - DHCP server name
#  leaseActMAC - active mac address
#  leaseActIP - active IP address
#  lease-agent-circuit-id - lease agent circuit ID
#  lease-agent-remote-id - lease agent remote ID
#  lease-hostname - client hostname
#  lease-options - an array of received options

:global "g-leaseBound";
:global "g-leaseServerName";
:global "g-leaseActMAC";
:global "g-leaseActIP";
:global "g-leaseAgentCircuitID";
:global "g-leaseAgentRemoteID";
:global "g-leaseHostname";
:global "g-leaseOptions";

# :log info ("TEST dhcp script: leaseBound -> " . $"g-leaseBound");
# :log info ("TEST dhcp script: leaseServerName -> " . $"g-leaseServerName");
# :log info ("TEST dhcp script: leaseActMAC -> " . $"g-leaseActMAC");
# :log info ("TEST dhcp script: leaseActIP -> " . $"g-leaseActIP");
# :log info ("TEST dhcp script: leaseAgentCircuitID -> " . $"g-leaseAgentCircuitID");
# :log info ("TEST dhcp script: leaseAgentRemoteID -> " . $"g-leaseAgentRemoteID");
# :log info ("TEST dhcp script: leaseHostname -> " . $"g-leaseHostname");
# :log info ("TEST dhcp script: leaseOptions -> " . $"g-leaseOptions");

# additional globals
:global "g-zone"

# configure dns zone:
:local fqdn;
:set fqdn ($"g-leaseHostname" . "." . $"g-zone");

:if ($"g-leaseHostname" = "" ) do={

    :log info ("Client " . $lease . " did not provide a hostname");

} else={

    if ([/ip dns static find name=$fqdn comment~"DHCP lease for"] != "") do={
        :log info ("DNS A record for " . $fqdn . " is managed by DHCP.");
    }

    if ([/ip dns static find name=$fqdn comment="manual"] != "") do={
        :log info ("DNS A record for " . $fqdn . " is manually managed, skipping");

    }  else {

        :if ($"g-leaseBound" = "1") do={

            # Remove old DHCP-managed record for this FQDN
            :local recByName [/ip dns static find where name=$fqdn and comment~"DHCP lease for"];
            :if ([:len $recByName] > 0) do={
                :log info ("DNS A record for " . $fqdn . " already exists (DHCP), removing old record");
                /ip dns static remove $recByName;
            }

            :log info ("Creating DNS A record for " . $fqdn . " -> " . $"g-leaseActIP");

            # Remove old DHCP-managed record for this IP
            :local recByAddr [/ip dns static find where address=$"g-leaseActIP" and comment~"DHCP lease for"];
            :if ([:len $recByAddr] > 0) do={
                /ip dns static remove $recByAddr;
            }

            :local nowDate [/system clock get date];
            :local nowTime [/system clock get time];
            :local dnsComment ("DHCP lease for " . $"g-leaseActMAC" . " @ " . $nowDate . " " . $nowTime);

            # Now always add fresh DHCP record
            /ip dns static add name=$fqdn address=$"g-leaseActIP" \
                comment=$dnsComment disabled=no;

        } else={

            :log info ("Removing DNS A record for " . $fqdn);

            :local recByName [/ip dns static find where name=$fqdn and comment~"DHCP lease for"];
            :if ([:len $recByName] > 0) do={
                /ip dns static remove $recByName;
            }

            :local recByAddr [/ip dns static find where address=$"g-leaseActIP" and comment~"DHCP lease for"];
            :if ([:len $recByAddr] > 0) do={
                /ip dns static remove $recByAddr;
            }
        }
    }
}
