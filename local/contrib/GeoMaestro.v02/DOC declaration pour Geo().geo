
IMPORTANT: ne pas utiliser de tabulation !



hors section, on peut écrire ce qu'on veut...

section:
#tableau PT points

1 1 1
2 1 2
3 1 3
4 1 4
5 10 50
6 20 60

# dans une section, il faut le # (unique et suivi d'un espace)
# tableau: le premier nombre est l'index, aucune contrainte d'ordre

156 125 121.232

#fin 

#tableau P2 points (en polaires ou mode relatif, même syntaxe que simple points)

1 0 0 
p 2 1 Pi/2
> p 3 1 Pi/4
> p 4 1 Pi/4
> p 5 1 Pi/4



#fin

#points

Or 0 0
p II 1 0

AA 3 3
BB -3 -3

Chh -3 -7
Ch -2 -7
Ch2 3 -7

Z -10 5
> Z2 1 1
> Z3 1 -1
> p Zp 1 0

Loin -5 -7

#fin

#cercles

Cer3 Or 3
Cer05 Or 0.5
CBB4  BB 4
Ctest -5 5 48

#fin

#regions

# pour le moment, les points doivent être désignés par leur noms
# (donc avoir été définis dans la section #points, par exemple)

t Joe AA BB Ch2         # un triangle nommé Joe

d Jack Or 2             # disque

r John AA BB            # rectangle


t T1 Ch Chh BB          # T1 intersection de T1, T2 et T3
ET t T2 Ch Ch2 AA
ET t T3 AA BB Ch

d D2 Chh 1              # D2 réunion de D2 et D1
OU d D1 Ch 1

Jack                    # Jack devient la réunion de Jack et de D1
OU d D1 Ch 1
 
t- T1 Ch Chh BB         # les complémentaires sont: t-, d- et r-
ET t- T2 Ch Ch2 AA
ET t T3 AA BB Ch


Mecs : Joe              # Mecs est la réunion de Joe, John et Jack
OU John
OU Jack


#fin