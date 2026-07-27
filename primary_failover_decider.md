# Failover Logic

This is the main logic layer (heavy lifting) for PRIMARY failover decision-making with debounced failover logic.

## Architecture

**Two-layer design:**

- **Inline test-script** (embedded in Netwatch probe) — Captures Netwatch variables (`$since` timestamp, `$status`, ICMP metrics), calculates elapsed seconds, sets globals
- **`primary_failover_decider.rsc`** (this file, logic layer) — Receives telemetry as globals, decides failover/restore, executes actions

## How it works

1. Netwatch probes the PRIMARY endpoint at regular intervals (e.g., every 2 seconds)
2. After each probe, Netwatch executes the **inline test-script**
3. Inline script:
   - Captures Netwatch variables: `$since` (datetime), `$status`, ICMP metrics
   - **Calculates elapsed seconds** from the `$since` timestamp to current time
   - Sets globals: `primaryElapsedSeconds`, `primaryStatus`, `primaryRttAvg`, etc.
   - Calls `/system script run primary_failover_decider`
4. Main logic script receives telemetry as globals, queries actual route state, decides failover/restore

## Expected variables

This script expects the inline test-script to set these globals:

```routeros
:global primaryDebounceSeconds;     # Required: Debounce threshold in seconds (e.g., 5)
:global primaryElapsedSeconds;      # Set by inline script: calculated seconds since status change
:global primaryStatus;              # Set by inline script: "ok" or "fail"
:global primaryRttAvg;              # Set by inline script: ICMP RTT average (e.g., "10ms")
:global primaryRttMax;              # Set by inline script: ICMP RTT maximum (e.g., "15ms")
:global primaryThresholdLoss;       # Set by inline script: packet loss percentage (e.g., "0")

:global gotifySource;               # Optional: hostname for gotify notifications
:global gotifyService;              # Optional: service name for notifications
:global gotifyState;                # Set by script for notifications
```

## Setup

### 1. Set debounce parameter globally

```routeros
:global primaryDebounceSeconds 5;
```

### 2. Create Netwatch probe with embedded inline test-script

The test-script must be embedded directly in the Netwatch configuration (NOT a separate script file).

**Use WinBox GUI (easiest):**

1. Go to **Tools → Netwatch**
2. Create new or edit the PRIMARY-watch probe
3. In the **test-script** field, copy and paste the entire script content from `primary_failover_netwatch_inline.rsc` (lines between BEGIN and END markers)
4. Click OK

**Or use command line:**

First, open the `primary_failover_netwatch_inline.rsc` file and copy the entire script (between BEGIN and END markers). Then set it in Netwatch:

```routeros
/tool/netwatch set PRIMARY-watch test-script="[paste the entire script content here]"
```

## Connection mark cleanup

Removes only connections using the primary WAN (e.g., `connection-mark=via-bestgo`), leaving backup traffic intact.

## Debounce behavior

- Debounce period: configured via global `primaryDebounceSeconds` (must be set before script invocation)
- Netwatch runs probes every N seconds (e.g., 2s in the setup example)
- `primaryElapsedSeconds` = seconds since PRIMARY status last changed (calculated by inline script)
- When PRIMARY DOWN and `elapsed < threshold`: logs SETTLE telemetry with ICMP metrics (rtt-avg, rtt-max, loss)
- When PRIMARY DOWN and `elapsed >= threshold`: triggers failover
- When PRIMARY UP: restores routes, flushes all conntrack

Example scenario with 5s debounce and 2s probe interval:

- T=0: Netwatch detects PRIMARY down → inline script calculates elapsed=0 → SETTLE logs with rtt-avg, rtt-max, loss
- T=2: Next probe → inline script calculates elapsed=2 → SETTLE logs
- T=4: Next probe → inline script calculates elapsed=4 → SETTLE logs
- T=6: Next probe → inline script calculates elapsed=6 → debounce expires → failover triggers

## Testing

Manually trigger to observe debounce behavior by setting globals and calling the logic script:

```routeros
# Set required parameters
:global primaryDebounceSeconds 5;
:global gotifySource "test.local";
:global gotifyService "Test";

# Disable the PRIMARY route to simulate failure
/ip route disable [find comment="PRIMARY"]

# Simulate first Netwatch probe (elapsed=0, just went DOWN)
:global primaryElapsedSeconds 0;
:global primaryStatus "fail";
:global primaryRttAvg "150ms";
:global primaryRttMax "200ms";
:global primaryThresholdLoss "0";
/system script run primary_failover_decider;
# Expected log: "SETTLE status=fail elapsed=0s rtt-avg=150ms rtt-max=200ms loss=0% waiting=5s"

# Simulate second probe (elapsed=5, debounce expired)
:global primaryElapsedSeconds 5;
/system script run primary_failover_decider;
# Expected log: "PRIMARY interface considered DOWN. Performing failover."

# Re-enable PRIMARY route
/ip route enable [find comment="PRIMARY"]

# Simulate probe showing PRIMARY UP
:global primaryElapsedSeconds 0;
:global primaryStatus "ok";
:global primaryRttAvg "10ms";
:global primaryRttMax "15ms";
:global primaryThresholdLoss "0";
/system script run primary_failover_decider;
# Expected log: "PRIMARY interface considered UP. Restoring primary routes."
```

## Requirements

- A static default route in `main` with `comment="PRIMARY"`
- Connection-marking rules that mark new sessions by WAN:
  - `via-bestgo` for the primary uplink
  - `via-neostrada` for the backup uplink
- Optional notification scripts: `beep_primary_down`, `beep_primary_up`, `gotify`

## Telemetry

The script logs different types of messages at different frequencies:

- **Telemetry status line** (current_state, elapsed, debounce) — Logged **once per 60 seconds** to reduce noise
- **SETTLE logs** (during debounce wait) — Logged on every probe (every 2-5 seconds)
- **Action logs** (failover, restore) — Logged on state transition (once per DOWN→UP or UP→DOWN)
- **Connection cleanup logs** — Logged per action (once per failover/restore)

Example output showing 60-second telemetry throttling:

```log
2026-07-27 15:27:13 script,info primary_failover telemetry: current_state=DOWN elapsed=0s debounce=5s
2026-07-27 15:27:13 script,warning primary_failover: PRIMARY DOWN, elapsed=0s
2026-07-27 15:27:13 script,warning primary_failover: SETTLE status=fail elapsed=0s rtt-avg=150ms rtt-max=200ms loss=0% waiting=5s

2026-07-27 15:27:15 script,warning primary_failover: SETTLE status=fail elapsed=2s rtt-avg=160ms rtt-max=210ms loss=0% waiting=3s

2026-07-27 15:27:17 script,warning primary_failover: SETTLE status=fail elapsed=4s rtt-avg=160ms rtt-max=210ms loss=0% waiting=1s

2026-07-27 15:27:19 script,error PRIMARY interface considered DOWN. Performing failover.
2026-07-27 15:27:19 script,info primary_failover telemetry: failover_conntrack_marked=150
2026-07-27 15:27:20 script,info primary_failover telemetry: failover_conntrack_removed=150

[Later, at T+60s, telemetry line logs again]
2026-07-27 15:28:13 script,info primary_failover telemetry: current_state=DOWN elapsed=60s debounce=5s
2026-07-27 15:28:13 script,info primary_failover telemetry: failover_conntrack_marked=45

[More SETTLE logs every 2s, but no telemetry line until 60s later]
```
