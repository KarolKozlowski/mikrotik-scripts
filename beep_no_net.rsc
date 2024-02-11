:local length 25ms;

:for j from=1 to=4 step=1 do {
    :for k from=4000 to=3500 step=-10 do {
        :beep frequency=$k length=$length;
        :delay $length;
    }
}