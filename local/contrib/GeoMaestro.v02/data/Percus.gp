set size ratio -1
set zeroaxis
set key outside
set pointsize 1
set xtics 1
set ytics 1
set grid 
plot [-12:5] [-8.9:7] '../Atelier/Data/Percus.dat' index 0 using 2:3 title "c1",  '../Atelier/Data/Percus.dat' index 1 using 2:3 title "c2",  '../Atelier/Data/Percus.dat' index 2 using 2:3 title "c3",  '../Atelier/Data/Percus.dat' index 3 using 2:3 title "c4", 0 0 
pause -1