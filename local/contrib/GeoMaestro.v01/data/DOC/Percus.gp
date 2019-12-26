set size ratio -1
set zeroaxis
set key outside
plot [-12:5] [-8.9:7] 'C:/audio/KeyKit6.5e/Atelier/Data/Percus.dat' index 0 using 2:3 title "c1",  'C:/audio/KeyKit6.5e/Atelier/Data/Percus.dat' index 1 using 2:3 title "c2",  'C:/audio/KeyKit6.5e/Atelier/Data/Percus.dat' index 2 using 2:3 title "c3",  'C:/audio/KeyKit6.5e/Atelier/Data/Percus.dat' index 3 using 2:3 title "c4", 0 0 
pause -1