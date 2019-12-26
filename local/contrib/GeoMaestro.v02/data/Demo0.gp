cd '../Atelier/Data/'
set multiplot
set key spacing 0.5
set size ratio -1
set zeroaxis
set key outside
set pointsize 1
set parametric
set xrange [-4:0]
set yrange [-9:-5]
set xtics 1
set ytics 1
set grid 

set noparametric
set data style lines
plot 'Demo0(1).dat' index 0 using 1:2 title "s1__"

set nogrid 
set nozeroaxis

set noparametric
set data style lines
plot 0 0,'Demo0(1).dat' index 1 using 1:2 title "s2__"

set noparametric
set data style points
plot 0 0,0 0,'Demo0(1).dat' index 2 using 1:2  title "c1__"

set noparametric
set data style points
plot 0 0,0 0,0 0,'Demo0(1).dat' index 3 using 1:2  title "c2__"

set noparametric
set data style points
plot 0 0,0 0,0 0,0 0,'Demo0(1).dat' index 4 using 1:2  title "c3__"

set noparametric
set data style points
plot 0 0,0 0,0 0,0 0,0 0,'Demo0(1).dat' index 5 using 1:2  title "c4__"

set nomultiplot
pause -1