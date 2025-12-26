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

            if ([/ip dns static find name=$fqdn] != "") do={

                :log info ("DNS A record for " . $fqdn . " already exists, removing old record");

                /ip dns static remove [find name=$fqdn];

            }

            :log info ("Creating DNS A record for " . $fqdn . " -> " . $"g-leaseActIP");
            /ip dns static remove [find address=$"g-leaseActIP"];
            /ip dns static add name=$fqdn address=$"g-leaseActIP" comment=("DHCP lease for " . $"g-leaseActMAC") disabled=no;

        } else={

            :log info ("Removing DNS A record for " . $fqdn);

            /ip dns static remove [find name=$fqdn];
            /ip dns static remove [find address=$"g-leaseActIP"];

        }
    }
}
