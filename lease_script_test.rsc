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

:log info ("DHCP-DNS: event bound=" . $"g-leaseBound" . \
           " host=" . $"g-leaseHostname" . \
           " fqdn=" . $fqdn . \
           " ip=" . $"g-leaseActIP" . \
           " mac=" . $"g-leaseActMAC" . \
           " server=" . $"g-leaseServerName");

:if ($"g-leaseHostname" = "") do={

    :log warning ("DHCP-DNS: client with IP " . $"g-leaseActIP" . \
                  " MAC " . $"g-leaseActMAC" . " did not provide a hostname");

} else={

    :local dhcpManaged [/ip dns static find where name=$fqdn and comment~"DHCP lease for"];
    :if ([:len $dhcpManaged] > 0) do={
        :log info ("DHCP-DNS: existing DHCP-managed DNS record found for " . $fqdn);
    }

    :local manualManaged [/ip dns static find where name=$fqdn and comment="manual"];
    :if ([:len $manualManaged] > 0) do={
        :log warning ("DHCP-DNS: DNS record for " . $fqdn . " is manually managed, skipping");

    } else={

        :if ($"g-leaseBound" = "1") do={

            :log info ("DHCP-DNS: processing BOUND event for " . $fqdn);

            # Remove old DHCP-managed record for this FQDN
            :local recByName [/ip dns static find where name=$fqdn and comment~"DHCP lease for"];
            :if ([:len $recByName] > 0) do={
                :log info ("DHCP-DNS: removing old DHCP DNS record by name for " . $fqdn);
                :do {
                    /ip dns static remove $recByName;
                } on-error={
                    :log warning ("DHCP-DNS: record(s) by name already removed for " . $fqdn);
                }
            } else={
                :log info ("DHCP-DNS: no old DHCP DNS record by name for " . $fqdn);
            }

            # Remove old DHCP-managed record for this IP
            :local recByAddr [/ip dns static find where address=$"g-leaseActIP" and comment~"DHCP lease for"];
            :if ([:len $recByAddr] > 0) do={
                :log info ("DHCP-DNS: removing old DHCP DNS record by address for " . $"g-leaseActIP");
                :do {
                    /ip dns static remove $recByAddr;
                } on-error={
                    :log warning ("DHCP-DNS: record(s) by address already removed for " . $"g-leaseActIP");
                }
            } else={
                :log info ("DHCP-DNS: no old DHCP DNS record by address for " . $"g-leaseActIP");
            }

            :local nowDate [/system clock get date];
            :local nowTime [/system clock get time];
            :local dnsComment ("DHCP lease for " . $"g-leaseActMAC" . " @ " . $nowDate . " " . $nowTime);

            :log info ("DHCP-DNS: creating DNS record " . $fqdn . \
                      " -> " . $"g-leaseActIP" . \
                      " comment=\"" . $dnsComment . "\"");

            :local existingByName [/ip dns static find where name=$fqdn];
            :if ([:len $existingByName] > 0) do={
                :log warning ("DHCP-DNS: DNS name already exists for " . $fqdn . ", skipping add");
            } else={
                :do {
                    /ip dns static add name=$fqdn address=$"g-leaseActIP" \
                        comment=$dnsComment disabled=no;
                    :log info ("DHCP-DNS: created DNS record for " . $fqdn);
                } on-error={
                    :log warning ("DHCP-DNS: failed to add DNS record for " . $fqdn . ", likely already exists");
                }
            }

        } else={

            :log info ("DHCP-DNS: processing UNBOUND event for " . $fqdn);

            :local recByName [/ip dns static find where name=$fqdn and comment~"DHCP lease for"];
            :if ([:len $recByName] > 0) do={
                :log info ("DHCP-DNS: removing DHCP DNS record by name for " . $fqdn);
                :do {
                    /ip dns static remove $recByName;
                } on-error={
                    :log warning ("DHCP-DNS: record(s) by name already removed for " . $fqdn);
                }
            } else={
                :log info ("DHCP-DNS: no DHCP DNS record by name to remove for " . $fqdn);
            }

            :local recByAddr [/ip dns static find where address=$"g-leaseActIP" and comment~"DHCP lease for"];
            :if ([:len $recByAddr] > 0) do={
                :log info ("DHCP-DNS: removing DHCP DNS record by address for " . $"g-leaseActIP");
                :do {
                    /ip dns static remove $recByAddr;
                } on-error={
                    :log warning ("DHCP-DNS: record(s) by address already removed for " . $"g-leaseActIP");
                }
            } else={
                :log info ("DHCP-DNS: no DHCP DNS record by address to remove for " . $"g-leaseActIP");
            }

            :log info ("DHCP-DNS: finished removing DNS record(s) for " . $fqdn);
        }
    }
}
