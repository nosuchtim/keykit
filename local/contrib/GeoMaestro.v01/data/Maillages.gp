set size ratio -1
set zeroaxis
set key outside
set pointsize 1
set xtics 1
set ytics 1
set grid 
plot [-8.88969:6] [-10.8524:5.76314] '../Atelier/Data/Maillages.dat' index 0 using 2:3 title "c4",  '../Atelier/Data/Maillages.dat' index 1 using 2:3 title "c17", 0 0 
pause -1