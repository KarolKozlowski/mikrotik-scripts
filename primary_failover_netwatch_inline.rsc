# === INLINE TEST-SCRIPT FOR NETWATCH ===
# This script should be embedded directly in the netwatch probe's test-script parameter.
# It is NOT a separate script file - copy the content below into netwatch configuration.
#
# Instructions:
# 1. Copy the script content (lines between BEGIN and END markers below)
# 2. In Netwatch probe settings, paste into: test-script="..."
# 3. RouterOS will execute this inline after every probe test
#
# === BEGIN INLINE SCRIPT ===

# Initialize global parameters
:global primaryDebounceSeconds 5;
:global primaryDebug false;  # Set to true to enable debug logging

# Calculate elapsed seconds from $since timestamp
:local currentTime [/system clock get time];
:local currentDate [/system clock get date];
:local sinceTimestamp $since;

# Parse timestamps and calculate elapsed seconds
# $since format: "2026-07-27 15:21:08" (datetime when status last changed)
# Need to convert to seconds elapsed
:local elapsedSeconds 0;
:if ([:typeof $sinceTimestamp] != "nothing" and $sinceTimestamp != "") do={
    # Extract time portion from since timestamp (everything after the space)
    :local spacePos [:find $sinceTimestamp " "];
    :local sinceTimeStr [:pick $sinceTimestamp ($spacePos + 1) [:len $sinceTimestamp]];
    
    # Get current time (HH:MM:SS format)
    :local currentTimeStr [/system clock get time];
    
    # Parse since time: extract HH, MM, SS using :pick (positions 0-1, 3-4, 6-7)
    :local sinceHour [:tonum [:pick $sinceTimeStr 0 2]];
    :local sinceMin [:tonum [:pick $sinceTimeStr 3 5]];
    :local sinceSec [:tonum [:pick $sinceTimeStr 6 8]];
    :local sinceSeconds ($sinceHour * 3600 + $sinceMin * 60 + $sinceSec);
    
    # Parse current time
    :local currentHour [:tonum [:pick $currentTimeStr 0 2]];
    :local currentMin [:tonum [:pick $currentTimeStr 3 5]];
    :local currentSec [:tonum [:pick $currentTimeStr 6 8]];
    :local currentSeconds ($currentHour * 3600 + $currentMin * 60 + $currentSec);
    
    # Calculate elapsed seconds
    :set elapsedSeconds ($currentSeconds - $sinceSeconds);
    
    # Handle day wraparound (if current < since, add 24 hours = 86400 seconds)
    :if ($elapsedSeconds < 0) do={
        :set elapsedSeconds ($elapsedSeconds + 86400);
    };
};

# Set globals for main logic script
:global primaryElapsedSeconds $elapsedSeconds;
:global primaryStatus $status;
:global primaryRttAvg $"rtt-avg";
:global primaryRttMax $"rtt-max";
:global primaryThresholdLoss $"thr-loss-percent";

:if ($primaryDebug = true) do={
    :log info ("primary_failover_netwatch_inline: rawStatus=" . $status . " elapsed=" . $elapsedSeconds . "s");
};

# Call main logic script
/system script run primary_failover_decider;

# === END INLINE SCRIPT ===
