cd 'C:/audio/KeyKit6.5e/Atelier/Data/'
set multiplot
set key spacing 0.5
set size ratio -1
set zeroaxis
set key outside
set pointsize 1
set parametric
set xrange [-2:2.2]
set yrange [-2:2]
set xtics 1
set ytics 1
set grid 

set noparametric
set data style points
plot 'pourCR.dat' index 0 using 1:2  notitle

set nogrid 
set nozeroaxis

set noparametric
set data style points
plot 0 0,'pourCR.dat' index 1 using 1:2  notitle

set parametric
plot [0:2*pi]0,0 not,0,0 not, 1*sin(t)+(0),1*cos(t)+(0)  notitle

set nomultiplot
pause -1