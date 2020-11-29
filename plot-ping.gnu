set xdata time
set timefmt "%Y-%m-%d_%H-%M-%S"
set xlabel "Time"
set style data lines  
set format x "%d. %m.\n%H:%M"                                                             
#set term png
#set output "ping.png"
#f(x) = a
#fit f(x) "ping.txt" using 1:3 via a
#plot "ping.txt" using 1:3 w lines t "loss [%]", "ping.txt" using 1:5 w points t "ping [ms]", f(x) t "mean loss [%]"
#plot "ping.txt" using 1:3 w lines t "loss [%]", "ping.txt" using 1:5 w points t "ping [ms]"
plot [][-10:110] "ping.txt" using 1:3 w lines t "loss [%]"
pause 30
