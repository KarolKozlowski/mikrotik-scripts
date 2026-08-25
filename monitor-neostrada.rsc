/system script add name=monitor-neostrada policy=read,write,reboot,policy,test source={
    :global gotifySource
    :global gotifyService
    :global gotifyState
    :global neostradaWasDown
    :global neostradaDownCount
    :global neostradaLastRebootDate

    :local pppoeName "pppoe-neostrada"
    :local failuresBeforeReboot 15
    :local rebootFromHour 2
    :local rebootToHour 8

    :if ([:typeof $neostradaWasDown] = "nothing") do={
        :set neostradaWasDown false
    }

    :if ([:typeof $neostradaDownCount] = "nothing") do={
        :set neostradaDownCount 0
    }

    :local pppoeId [/interface pppoe-client find where name=$pppoeName]

    :if ([:len $pppoeId] = 0) do={
        :log error ("PPPoE monitor: interface not found: " . $pppoeName)
        :error "PPPoE interface not found"
    }

    :local isRunning [/interface pppoe-client get $pppoeId running]

    :if ($isRunning) do={
        :if ($neostradaWasDown) do={
            :set gotifySource "MikroTik"
            :set gotifyService "Neostrada PPPoE"
            :set gotifyState "UP"
            /system script run gotify
            :log info "PPPoE monitor: pppoe-neostrada recovered"
        }

        :set neostradaWasDown false
        :set neostradaDownCount 0
    } else={
        :set neostradaDownCount ($neostradaDownCount + 1)

        :if (!$neostradaWasDown) do={
            :set gotifySource "MikroTik"
            :set gotifyService "Neostrada PPPoE"
            :set gotifyState ("DOWN (check " . $neostradaDownCount . ")")
            /system script run gotify
            :log warning "PPPoE monitor: pppoe-neostrada is down"
            :set neostradaWasDown true
        }

        :local currentTime [/system clock get time]
        :local currentDate [/system clock get date]
        :local currentHour [:tonum [:pick $currentTime 0 2]]
        :local withinMaintenanceWindow false

        :if (($currentHour >= $rebootFromHour) && ($currentHour < $rebootToHour)) do={
            :set withinMaintenanceWindow true
        }

        :if (($neostradaDownCount >= $failuresBeforeReboot) && $withinMaintenanceWindow && ($neostradaLastRebootDate != $currentDate)) do={
            :set gotifySource "MikroTik"
            :set gotifyService "Neostrada PPPoE"
            :set gotifyState ("DOWN for " . $neostradaDownCount . " minutes - rebooting now")
            /system script run gotify

            :log error ("PPPoE monitor: down for " . $neostradaDownCount . " minutes; rebooting during maintenance window")
            :set neostradaLastRebootDate $currentDate
            :delay 5s
            /system reboot
        }

        :if (($neostradaDownCount >= $failuresBeforeReboot) && !$withinMaintenanceWindow) do={
            :log warning ("PPPoE monitor: persistent outage (" . $neostradaDownCount . " min); reboot deferred until 02:00-08:00")
        }
    }
}