# mikrotik-scripts

## init_defaults.rsc

Boot-time defaults for the scripts in this repository.

Use this when you want stable defaults for shared variables without repeating them in each script:

- `gotifySource`
- `gotifyService`
- `primaryConsecutiveDownThreshold`
- `primaryConsecutiveDownCount`
- `warnhc`
- `warnkuma`
- `warninet`

The companion file [init_defaults.md](init_defaults.md) explains the startup scheduler pattern and which values are intentionally left runtime-only.

## add_vlan_network.rsc

Reusable RouterOS script for provisioning VLAN network components with idempotent checks.

Convention used by this repository:

- VLAN interface name: `bridge.<vlan_id>-<canonic_name>`
- DHCP pool name: `vlan.<vlan_id>-<canonic_name>`
- DHCP server name: `vlan.<vlan_id>-<canonic_name>`
- Subnet: `172.16.<vlan_id>.0/24`
- Gateway: `172.16.<vlan_id>.1`

Objects created (if missing):

- `/interface vlan`
- `/ip address`
- `/ip pool`
- `/ip dhcp-server`
- `/ip dhcp-server network`
- `/interface list member` (optional, defaults to `LAN`)

How to use:

1. Open `add_vlan_network.rsc`.
2. Set variables at the top (`vlanID`, `canonicName`, `parentInterface`, pool range, etc.).
3. Import or paste into terminal.
4. Re-running is safe: existing objects are detected and skipped.

Example for VLAN 192 (`storage`):

- `vlanID=192`
- `canonicName="storage"`
- `parentInterface="bridge"`
- resulting subnet: `172.16.192.0/24`

This example completes the missing VLAN 192 parts in backup config where pool/network already exist but interface, gateway IP and DHCP server were absent.
