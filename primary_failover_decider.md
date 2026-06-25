# Failover script

This script handles WAN failover by toggling the `PRIMARY` default route in the `main` routing table based on the state reported by Netwatch. When the primary path is marked `DOWN`, it disables the route commented as `PRIMARY`; when the primary path returns `UP`, it enables that route again. The script also keeps track of the last applied state in `primaryAppliedState` so repeated Netwatch events do not re-run the same actions unnecessarily [web:126].

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

The script expects these global variables to exist:

```routeros
:global primaryState;
:global primaryAppliedState;

:global gotifySource;
:global gotifyService;
:global gotifyState;
```

Typical Netwatch usage:

```routeros
# DOWN script
:global primaryState "DOWN";
/system script run primary_failover_decider;

# UP script
:global primaryState "UP";
/system script run primary_failover_decider;
```

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
