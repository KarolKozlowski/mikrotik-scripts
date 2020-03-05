# Manage DNS records for DHCP leases

# configure dns zone:
:local zone;
:local fqdn;
:local create true;

:set zone "np.dotnot.pl";

/ip dns static;

:if ($"lease-hostname" = "" ) do={
	:log info ("Client " . $leaseActIP . " did not provide a hostname");
} else={
	:set fqdn ($"lease-hostname" . "." . $zone);

	:if ($leaseBound = 1) do={

		# iterate over all static DNS entries:
		:foreach n in [find] do={

			:if (([get $n name] = $"fqdn") and ([get $n address] = $leaseActIP)) do={
				# if a DNS entry with matching IP and name exists set a flag to avoid any action
				:set create false;
			} else={
				:if ([get $n name] = $"fqdn") do={
					:log info ("updating static DNS: " . [get $n name] .  " @ " . [get $n address] . " -> " . $leaseActIP);
					set $n address=$leaseActIP;
					# dns entry updated, creating new one is not necessary
					:set create false;
				}
			}
		}

		# Add new static DNS Entry if necessary
		:if ($create = true) do={
			:log info ("adding static DNS: " . $"fqdn" .  " @ " . $leaseActIP);
			add name=$fqdn address=$leaseActIP;
		}

	} else={
		# Remove DNS entry at DHCP release:
		:log info ("Removing static DNS entry at DHCP Release : " . $"fqdn" . " @ " . $leaseActIP);
		:foreach n in [find] do={
			:if (([get $n name] = $"fqdn") and ([get $n address] = $leaseActIP)) do={
				remove $n;
			}
		}
	}
}
