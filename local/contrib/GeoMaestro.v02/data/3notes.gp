set size ratio -1
set zeroaxis
set key outside
set pointsize 1
set xtics 1
set ytics 1
set grid 
plot [-1.5:2] [-1.8:2] 'C:/audio/KeyKit6.5e/Atelier/Data/3notes.dat' index 0 using 2:3 title "c17", 0 0 
pause -1