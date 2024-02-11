#!rsc by RouterOS

:local length 250ms;

# supress warnings between midnight and 8:00
:if ([/system clock get time] < [:totime "8:00:00"]) do={
  :put "Warning supressed."
} else={

  :for j from=1 to=1 step=1 do {
      :for k from=3400 to=3000 step=-200 do {
          :beep frequency=$k length=$length;
          :delay $length;
      }
  }
}
