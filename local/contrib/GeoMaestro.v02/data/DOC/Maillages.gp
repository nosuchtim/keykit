set size ratio -1
set zeroaxis
set key outside
plot [-8.88969:6] [-10.8524:5.76314] 'C:/audio/KeyKit6.5e/Atelier/Data/Maillages.dat' index 0 using 2:3 title "c4",  'C:/audio/KeyKit6.5e/Atelier/Data/Maillages.dat' index 1 using 2:3 title "c17", 0 0 
pause -1