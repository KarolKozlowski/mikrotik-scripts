# Manage DNS records for DHCP leases

# configure dns zone:
:local zone;
:local fqdn;
:local create true;
:local lease $leaseActIP;

# :log info ("dhcp script");

:set zone "np.dotnot.pl";

/ip dns static;

:if ($"lease-hostname" = "" ) do={

	:log info ("Client " . $lease . " did not provide a hostname");

} else={

	:set fqdn ($"lease-hostname" . "." . $zone);

	:if ($"lease-hostname" = "TVS-h674" ) do={
		:log info ("Client " .$"lease-hostname" . " is static.");
	} else={


		:if ($leaseBound = 1) do={

			# iterate over all static DNS entries:
			:foreach n in [find] do={

				:if (([get $n name] = $"fqdn") and ([get $n address] = $lease)) do={
					# if a DNS entry with matching IP and name exists set a flag to avoid any action
					:set create false;
				} else={
					:if ([get $n name] = $"fqdn") do={
						:log info ("updating static DNS: " . [get $n name] .  " @ " . [get $n address] . " -> " . $lease);
						set $n address=$lease;
						# dns entry updated, creating new one is not necessary
						:set create false;
					}
				}
			}

			# Add new static DNS Entry if necessary
			:if ($create = true) do={
				:log info ("adding static DNS: " . $"fqdn" .  " @ " . $lease);
				add name=$fqdn address=$lease;
			}

		} else={
			# Remove DNS entry at DHCP release:
			:log info ("Removing static DNS entry at DHCP Release : " . $"fqdn" . " @ " . $lease);
			:foreach n in [find] do={
				:if (([get $n name] = $"fqdn") and ([get $n address] = $lease)) do={
					remove $n;
				}
			}
		}
	}
}
