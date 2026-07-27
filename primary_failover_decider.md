# Failover script

This script handles WAN failover by toggling the `PRIMARY` default route in the `main` routing table based on the state reported by Netwatch. When the primary path is marked `DOWN`, it disables the route commented as `PRIMARY`; when the primary path returns `UP`, it enables that route again. The script queries the current route state to ensure idempotency, so repeated Netwatch events do not re-run the same actions unnecessarily.

## Behavior

- Uses `primaryState` as the current desired state, typically set by Netwatch.
- Disables `/ip route` entries with `comment="PRIMARY"` when the primary uplink is down.
- Re-enables `/ip route` entries with `comment="PRIMARY"` when the primary uplink is back.
- Removes only connection-tracking entries marked as using the primary WAN, for example `connection-mark=via-bestgo`, so existing failover traffic is left alone [web:121].
- Triggers optional helper scripts such as `beep_primary_down`, `beep_primary_up`, and `gotify` for alerting and notifications.

## Why connection marks are used

Existing sessions do not automatically migrate to another WAN after a route change, because connection tracking keeps them tied to the path they were established on. To avoid flushing all connections, the router marks new sessions by egress WAN, such as `via-bestgo` for primary and `via-neostrada` for backup, and the failover script removes only the sessions that were using the failed primary link.

This is the practical RouterOS approach, because connection marks are stored in conntrack and can be matched later for selective removal, unlike routing marks which are used before route lookup and are not directly usable for conntrack cleanup.

## Expected variables

The script expects this global variable at runtime:

```routeros
:global primaryState;

:global gotifySource;
:global gotifyService;
:global gotifyState;
```

The script derives the current state of the primary route directly from the router configuration, so no persistent state tracking is needed. Netwatch only needs to set `primaryState` before calling the script.

Typical Netwatch usage:

```routeros
# Optional debounce tuning
:global primaryConsecutiveDownThreshold 3;

# DOWN script
:log info ("netwatch telemetry: host=" . $host . " status=" . $status . " rtt-avg=" . $"rtt-avg" . " rtt-min=" . $"rtt-min" . " rtt-max=" . $"rtt-max" . " packet-loss=" . $"packet-loss");
:global primaryState "DOWN";
/system script run primary_failover_decider;

# UP script
:log info ("netwatch telemetry: host=" . $host . " status=" . $status . " rtt-avg=" . $"rtt-avg" . " rtt-min=" . $"rtt-min" . " rtt-max=" . $"rtt-max" . " packet-loss=" . $"packet-loss");
:global primaryState "UP";
/system script run primary_failover_decider;
```

Debounce behavior:

- The script now requires `primaryConsecutiveDownThreshold` consecutive `DOWN` results before it actually disables the primary route.
- The default threshold is `2` if the variable is not set.
- The first `DOWN` is treated as a transient and only increments the internal streak counter.
- Any `UP` result resets the DOWN streak.

To tune it, define a global before calling the script:

```routeros
:global primaryConsecutiveDownThreshold 3;
```

For ICMP Netwatch checks, the telemetry fields above are the useful ones to log. The exact values available depend on probe type, but `rtt-avg`, `rtt-min`, `rtt-max`, and `packet-loss` are the main ones for path quality debugging.

## Requirements

- A static default route in `main` with `comment="PRIMARY"`.
- Connection-marking rules that mark new sessions by WAN, for example:
  - `via-bestgo` for the primary uplink.
  - `via-neostrada` for the backup uplink.
- Optional notification scripts if you want sound or push alerts.

Example selective cleanup:

```routeros
:local conns [/ip firewall connection find where connection-mark=via-bestgo];
:if ([:len $conns] > 0) do={
    /ip firewall connection remove $conns;
}
```

## Notes

- The script is idempotent: if the requested state is already applied, it exits without doing anything.
- Selective conntrack cleanup is preferred over `/ip firewall connection remove [find]`, because it preserves unaffected sessions.
- If no matching connections exist, guard the `remove` command with `[:len ...] > 0` to avoid `no such item` errors in Netwatch logs.
