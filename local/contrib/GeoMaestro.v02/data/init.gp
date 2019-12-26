set size ratio -1
set zeroaxis
set key outside
set pointsize 1
set xtics 1
set ytics 1
set grid 
plot [-1.6:2] [-1:1] 'C:/audio/KeyKit6.5e/Atelier/Data/init.dat' index 0 using 2:3 title "c1", 0 0 
pause -1