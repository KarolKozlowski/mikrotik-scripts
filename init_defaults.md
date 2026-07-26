# init_defaults.rsc

This script sets the long-lived defaults used by the RouterOS scripts in this repository.

## What it initializes

- `gotifySource` with `np.dotnot.pl`
- `gotifyService` with `BestGo`
- `primaryConsecutiveDownThreshold` with `2`
- `primaryConsecutiveDownCount` with `0`
- `warnhc` with `0`
- `warnkuma` with `0`
- `warninet` with `0`

## What it does not set

These remain runtime variables and are set by the scripts that use them:

- `primaryState`
- `primaryAppliedState`
- `gotifyState`

## How to use

Run the script once at boot, typically from a scheduler entry with `start-time=startup`:

```routeros
/system scheduler add name=script-defaults-init start-time=startup on-event="/system script run init_defaults"
```

If you prefer to import the file manually, paste `init_defaults.rsc` into the terminal or import it from a file and then run it from a startup scheduler.
