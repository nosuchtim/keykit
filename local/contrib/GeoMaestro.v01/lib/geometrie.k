
###########################################################################################
########			                       ####################################
######## Régions                                       ####################################
########			                       ####################################
###########################################################################################

# fonction d'évaluation (Region):
#
#  reg_test est une région, i.e. un tableau de tests (string)
#
#  reg_test[0] contient le nombre de tests
#  reg_test[n] doit être de la forme " (... test sur X_, Y_ et C_ ...)"
#	ex: "!( pow(X_-2,2)+pow(Y_+4,2)==9 )" ou "(C_ == 1)" 
#
#	ces expressions sont construites par les fonctions de région, qui
#	retournent une variable string de tests correspondant à la délimitation de
#	la région concernée (rem: eval() veut X_, Y_, C_ et Tok_ variables globales)
#
##  reg_test["a"]  ((((( non implémenté encore )))))
##  reg_test["b"]	     --> rectangle minimum englobant la région (xa<xb et ya<yb)
##  reg_test[n]["reg"]	     instructions pour $.affichepoints() de wfen (winterface.k)


function Region(X_,Y_,C_,reg_test)
{
   if (reg_test[0] != 0)
   {
	ok = 0
	for (t = 1; t<=reg_test[0]; t++)
	{
		init = "X_="+string(X_)+";Y_="+string(Y_)+";C_="+string(C_)
		eval(init+";Tok_ ="+reg_test[t])
		ok = ok || Tok_
	}
	return (ok) 
   }
   else return (1)						# region vide = tout !
}

function RegionPoint(a,reg)	# la même, avec une autre syntaxe, pour points seulement
				# (ne fonctionne qu'avec un reg sans condition de canal)
{	
	return (Region(a["x"],a["y"],1,reg))
}



##
#
# fonctions de région:
#
# paramètres: Rf( ..paramètres spécifiques..  [, op [, région à OU-compléter ]] )
#
#################################################################################


Tout = [0=0]	 # région vide (pas de calcul de région effectué)

EnPlusDe = ""	 # op pour ajouter (OU) la région
EnMoinsDe = "!"	 # op pour ajouter (OU) le négatif de la région
		 # pour ET, voir plus bas RegionET()

function RCanal(can, ...)
{
	 if (nargs() == 1) { op = "" ; reg = [0=0] }
	 else { op = argv(1) ; if (nargs() == 3) reg = argv(2) else reg= [0=0]}

	 reg[0] += 1
	 reg[reg[0]]= op+"( C_ == "+string(can)+")" 
	 return (reg)	
}


function RDisque(centre, rayon, ...)
{
	if (nargs() == 2) { op = "" ; reg = [0=0] }
	else { op = argv(2) ; if (nargs() == 4) reg = argv(3) else reg= [0=0]}

	cx = "("+string(centre["x"])+")"
	cy = "("+string(centre["y"])+")"	

	reg[0] += 1
	reg[reg[0]]= op+"( sqrt(pow(X_-"+cx+",2)+pow(Y_-"+cy+",2)) <= "+string(rayon)+")"
	return (reg)

	#GnuPlot#

	#Geo()#

	# reg["geo"]= "d"+op+" __ "+cx+" "+cy+" "+string(rayon)
}


function RRect(a, b, ...)
{
	if (nargs() == 2) { op = "" ; reg = [0=0] }
	else { op = argv(2) ; if (nargs() == 4) reg = argv(3) else reg= [0=0] }

	ax = string(Minimum(a["x"],b["x"]))
	ay = string(Minimum(a["y"],b["y"]))	
	bx = string(Maximum(a["x"],b["x"]))
	by = string(Maximum(a["y"],b["y"]))

	reg[0] += 1
	reg[reg[0]]= op+"((X_>="+ax+") && (Y_>="+ay+") && (Y_<="+by+") && (X_<="+bx+"))"
	return(reg)

	#GnuPlot#

	#Geo()#

	# reg["geo"]= "r"+op+" __ "+ax+" "+ay+" "+bx+" "+by
}


function RTri(a, b, c, ...)
{
	if (nargs() == 3) { op = "" ; reg = [0=0] }
	else { op = argv(3) ; if (nargs() == 5) reg = argv(4) else reg= [0=0] }

	ax = string(a["x"]) 
	ay = string(a["y"])
 	bx = string(b["x"]) 
	by = string(b["y"])
	cx = string(c["x"]) 
	cy = string(c["y"])

	reg[0] += 1
	reg[reg[0]]=op+"DansTriangle("+ax+","+ay+","+bx+","+by+","+cx+","+cy+")" 
	return(reg)

	#GnuPlot#

	#Geo()#

	# reg["geo"]= "t"+op+" __ "+ax+" "+ay+" "+bx+" "+by+" "+cx+" "+cy
}
function DansTriangle(ax,ay,bx,by,cx,cy)	
{
	p = 0.001	# precision (pour compenser les arrondis)

	am = Getpolar(ax-X_, ay-Y_)
	bm = Getpolar(bx-X_, by-Y_)
	cm = Getpolar(cx-X_, cy-Y_)

	amb = Mod2Pi(am["theta"]-bm["theta"])
	bmc = Mod2Pi(bm["theta"]-cm["theta"])	
	cma = Mod2Pi(cm["theta"]-am["theta"])

	tousinf = (amb <= Pi+p) && (bmc <= Pi+p) && (cma <= Pi+p)
	toussup = (amb >= Pi-p) && (bmc >= Pi-p) && (cma >= Pi-p)
	angles = (am["r"] == 0) || (bm["r"] == 0) || (cm["r"] == 0)

	return (tousinf || toussup || angles)
}

##
#
# intersection (ET) et union (OU) de deux régions:
#
# ex: anneau = RegionET(RDisque(centre, r1, EnMoinsDe), RDisque(centre, r2))

# ou encore mieux, un anneau ajouté à une région blob existante:
#   blob = RegionET(RDisque(centre, r1, EnMoinsDe), RDisque(centre, r2), EnPlusDe, blob)

# encore plus fort, l'intersection de deux anneaux:
#   anneau1 = RegionET(RDisque(centre1, r1, EnMoinsDe), RDisque(centre1, r2))
#   anneau2 = RegionET(RDisque(centre2, r3, EnMoinsDe), RDisque(centre2, r4))
#   inter = RegionET(anneau1,anneau2)

# ...et pour ajouter inter au blob:
#   blob = RegionOU(inter, blob)

# (en général le OU est implicite avec la construction par EnPlusDe, EnMoinsDe dans les 
# fonctions de régions particulières: Disque, Rect, Tri...)
#
# ATTENTION !
#
# RegionET() ne s'intéresse qu'au dernier item de ses deux premiers argument, et ne renvoie
# qu'un tableau à 1 test, (sauf si EnPlusDe/EnMoinsDe est employé...)
# Il a donc bien le format d'une fonction de région, qui ne fournit qu'une ligne dans
# la pile qui constitue une région
#
# à l'inverse, RegionOU() marie deux régions qui peuvent être de complexité arbitraire.
#
######################################################################################

function RegionET(reg1, reg2, ...)		
{
	if (nargs() == 2) { op = "" ; reg = [0=0] }
	else { op = argv(2) ; if (nargs() == 4) reg = argv(3) else reg= [0=0] }

	reg[0] += 1
	reg[reg[0]]= op+"("+reg1[reg1[0]]+") && ("+reg2[reg2[0]]+")" 
	return(reg)

	#GnuPlot#

	#Geo()#

	# reg1[geo]
	# ET reg2[geo]
	
	#reg["geo"]= "__: "+reg1["geo"]+"\nET "+reg2["geo"]
}

function RegionOU(reg1, reg2)		
{
	reg = []
	for (t=0; t<= reg1[0]; t++)
	    reg[t]= reg1[t] 
	for (t=1; t<= reg2[0]; t++)
	    reg[t+reg[0]]= reg2[t] 
	reg[0] += reg2[0]
	return(reg)

	#GnuPlot#

	#Geo()#

	# nomme Temp1: reg1[geo]
	# nomme Temp2: reg2[geo]
	# __ : Temp1 /n OU Temp2

	# reg["geo"]= "TTTT1:
}





