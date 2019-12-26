################################################################################
#
#    GeoMaestro v1.0
#    Copyright (C) 2000  Stéphane Rollandin (hepta@infonie.fr)
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA
#
################################################################################


###########################################################################################
########						   ################################
######## Scènes et collections				   ################################
########						   ################################
###########################################################################################


# format de collection (dont les maillages):
#-------------------------------------------
# coll["nom"]	nom 
# coll["ch"]	canal
# coll[0]	nbe d'événements
# coll[n]["x"]
#	 ["y"]
#	 ["nodur"]


function CExport(m, nomf, ...)	# écrit la collection dans un fichier compatible Gnuplot
{						      # (les ... pour un string de commentaire)
	filename = DATA+nomf+".dat"
	f = open(filename,"w") 

	if (nargs() == 3) {comm = argv(2)} else {comm = ""} 
	put(f,sprintf("# %s\n", comm)) 
	put(f,sprintf("# %s\n", m["nom"] ))
	put(f,sprintf("# canal %d\n", m["ch"] ))
	put(f,sprintf("# %d événements\n", m[0] ))

	for (n=1; n<= m[0]; n++)
	{
		put(f,sprintf("%d %f %f\n",n,m[n]["x"],m[n]["y"])) 
		put(f,sprintf("%p\n",m[n]["nodur"])) 
	}	

	close(f) 
}

function CImport(nomf)		# lit une collection et la retourne
{
	filename = DATA+nomf+".dat"
	f = open(filename)
	get(f)
	
	coll = ["nom"= split(get(f)," ")[1], "ch"= integer(split(get(f)," ")[2]), 0= integer(split(get(f)," ")[1])]
	n=0
	while ( (line=get(f)) != Eof ) 
	{      
	      arr = split(line," ")
	      n += 1
	      coll[n]=["x"= float(arr[1]), "y"= float(arr[2])]

	      merdoum = get(f)							 # merdoum !
	      while (substr(merdoum, sizeof(merdoum), 1) == "\\")		 #
		    merdoum = substr(merdoum, 1, sizeof(merdoum)-1) + get(f)	 #
								    		 #
	      coll[n]["nodur"] = phrase(merdoum)				 #
	      
	}
	close(f)

	return(coll)
}



###########################################################################################
########						   ################################
######## Collections: création et manipulations		   ################################
########						   ################################
###########################################################################################

# Convolution de deux collections:
# (on garde les notes du motif)
#
# idées: définir des options pout utiliser aussi les nodurs du support
#	 (bien que.. le support peut être une piste, sans nodur)
#
function Convo(support, motif, ...)		# (...) pour options sur le nodur 
{
	if (nargs() == 2) option = 0 else option = argv(2) 

	conv = [0 = support[0]*motif[0], "ch" = motif["ch"]]

	for (e = 1; e <= support[0]; e++)
	{
		xref = support[e]["x"]
		yref = support[e]["y"]

		for (em = 1; em <= motif[0]; em++)
		{
			n = em + motif[0]*(e-1)
			conv[n]= ["x" = motif[em]["x"]+xref ]
			conv[n]["y"] = motif[em]["y"]+yref

			if (option == 0)	# 0 : obligatoire si support est une piste
			   conv[n]["nodur"] = motif[em]["nodur"]

			else if (option == 1)   # 1 : fusion des nodurs
			   conv[n]["nodur"] = motif[em]["nodur"]|support[n]["nodur"]   

			else if (option == 2)   # 2 : support+motif
			   conv[n]["nodur"] = support[n]["nodur"]+motif[em]["nodur"]	   

			else if (option == 3)   # 2 : support donne le volume
			{  conv[n]["nodur"] = motif[em]["nodur"]	
			   conv[n]["nodur"].vol = support[n]["nodur"].vol  }

			# else etc...
		}

	}
	conv["nom"] = "{*}"

	return (conv)
}


function Rot(collec, centre, angle)	# collec : piste, collection ou scene
{
	coll = ArCopy(collec)
	xc = centre["x"]; yc = centre["y"]

	if ("ch" in coll)			# cas d'une piste/collection
	for (n = 1; n <= coll[0]; n++)
	{
		x = coll[n]["x"] ; y = coll[n]["y"]
		t1 = Getpolar(x-xc, y-yc)
		t1["theta"] += angle
		t2 = Setpolar(t1["r"], t1["theta"])
		coll[n]["x"] = t2["x"]+xc
		coll[n]["y"] = t2["y"]+yc
	}

	else					# cas d'une scène
	for (ch = 1; ch <= NbCan; ch++) if (coll[ch][0])
	for (n = 1; n <= coll[ch][0]; n++)
	{
		x = coll[ch][n]["x"] ; y = coll[ch][n]["y"]
		t1 = Getpolar(x-xc, y-yc)
		t1["theta"] += angle
		t2 = Setpolar(t1["r"], t1["theta"])
		coll[ch][n]["x"] = t2["x"]+xc
		coll[ch][n]["y"] = t2["y"]+yc
	}


	return (coll)
}

function Trans(collec, vx, vy)		# collec : piste, collection ou scene
{
	coll = ArCopy(collec)

	if ("ch" in coll)
	for (n = 1; n <= coll[0]; n++)
	{
		coll[n]["x"] += vx
		coll[n]["y"] += vy
	}

	else
	for (ch = 1; ch <= NbCan; ch++) if (coll[ch][0])
	for (n = 1; n <= coll[ch][0]; n++)
	{
		coll[ch][n]["x"] += vx
		coll[ch][n]["y"] += vy
	}

	return (coll)
}

function Sca(collec, centre, facteur)	# collec : piste, collection ou scene
{
	coll = ArCopy(collec)
	xc = centre["x"]; yc = centre["y"]

	if ("ch" in coll)
	for (n = 1; n <= coll[0]; n++)
	{
		x = coll[n]["x"] ; y = coll[n]["y"]
		t1 = Getpolar(x-xc, y-yc)
		t1["r"] *= facteur
		t2 = Setpolar(t1["r"], t1["theta"])
		coll[n]["x"] = t2["x"]+xc
		coll[n]["y"] = t2["y"]+yc
	}

	else
	for (ch = 1; ch <= NbCan; ch++) if (coll[ch][0])
	for (n = 1; n <= coll[ch][0]; n++)
	{
		x = coll[ch][n]["x"] ; y = coll[ch][n]["y"]
		t1 = Getpolar(x-xc, y-yc)
		t1["r"] *= facteur
		t2 = Setpolar(t1["r"], t1["theta"])
		coll[ch][n]["x"] = t2["x"]+xc
		coll[ch][n]["y"] = t2["y"]+yc
	}

	return (coll)
}

function ScaXY(collec, fx, fy)		# collec : piste, collection ou scene
{
	coll = ArCopy(collec)

	if ("ch" in coll)
	for (n = 1; n <= coll[0]; n++)
	{
		 coll[n]["x"] *= fx
		 coll[n]["y"] *= fy
	}

	else
	for (ch = 1; ch <= NbCan; ch++) if (coll[ch][0])
	for (n = 1; n <= coll[ch][0]; n++)
	{
		 coll[ch][n]["x"] *= fx
		 coll[ch][n]["y"] *= fy
	}

	return (coll)
}


#
# Fonctions de définition de collection:
#
#  1) avec nodurs
#
########################################


# ...


#
# Fonctions de définition de collection:
#
#  2) sans nodurs (géométriques)
#
########################################


# ...



# format de scène (ensemble de collections et d'instruments associés)
#--------------------------------------------------------------------
#
# facultatif (aucune fonction n'utilise ces champs:)
#
# scene[0] 		nbe de collections constituant la scène
# scene[-n]["nom"]	nom de la collection n
#	   [0]		nbe d'événements dans "nom"		
#	   ["ch"]	canal d'affectation de "nom"
# scene[ch][n]["nc"]	numéro de la collection d'origine de l'événement 	
#
# obligatoire:
#
# scene[ch][0]		nbe total d'événements dans le canal ch
# scene[ch][n]["x"]
#	      ["y"]
#             ["nodur"]	... les événements eux-mêmes
#	      ["nc"]	    (facultatif, voir ci-dessus)
# scene[ch]["PAC"]	phrase d'initialisation du canal: PourAC(LSB,patch,ch)
#			    (défaut de CreScen(): piano)
#          ["desc"]	description de l'instrument (facultatif)



function CreScen(...)	# crée une scene en assemblant des collections
{			
	s = [0=0]
	for (nc = 1; nc <= NbCan; nc++) 
	    {s[nc]=[0=0, "PAC"='', "desc"="canal vide"]}

	if (nargs() > 0) for (n=0; n <= nargs()-1; n++)
	    s = PlusCol(s, argv(n))

	return (s)
}

function PlusCol(s, col)	# ajoute la collection col à la scène s
{
   s[0] += 1
   ch = col["ch"]
   s[-s[0]] = ["nom"= col["nom"], "ch"= ch, 0= col[0]]
		
   nch = s[ch][0]
   for (e = 1; e <= col[0]; e++)
     s[ch][e+nch] = ["x"= col[e]["x"], "y"= col[e]["y"], "nodur" = col[e]["nodur"], "nc"= s[0]]

   s[ch][0] += col[0]

   return (s)
}

function EvPlusCol(col)		# ajoute la collection col à la scène pricipale Ev
{
   ch = col["ch"]
		
   nch = Ev[ch][0]
   for (e = 1; e <= col[0]; e++)
     Ev[ch][e+nch] = ["x"= col[e]["x"], "y"= col[e]["y"], "nodur" = col[e]["nodur"], "actif"= 1]

   Ev[ch][0] += col[0]
}


# inachevé! SaveScene ne sauvegarde pas les éléments facultatifs
#	    (est-il bien utile de le faire ?)
#
function SaveScene(scene, fnom, ...)	# sauvegarde scene (fnom en .s)
{					# ... pour éventuels commentaires
	filename = DATA+fnom+".s"
	f = open(filename,"w") 

	if (nargs() == 3) {comm = argv(2)} else {comm = ""} 
	put(f,sprintf("# %s\n", comm)) 

	for (ch= 1; ch<= NbCan; ch++)
	{
	   put(f, sprintf("%d \n", scene[ch][0]))
	   put(f, sprintf("%p \n", scene[ch]["PAC"]))
	   for (n= 1; n<= scene[ch][0]; n++)
	   {
	      put(f,sprintf("%f %f\n",scene[ch][n][Xs],scene[ch][n][Ys]))
	      put(f,sprintf("%p \n",scene[ch][n][Ph]))
	   }
	}
	close(f)
}

function ReadScene(nomf)		# lit une scene
{
	filename = DATA+nomf+".s"
	f = open(filename)
	get(f)				# (ligne de commentaire)

	s=[]
	for (ch= 1; ch<= NbCan; ch++)
	{
	   s[ch]=[0= integer(get(f))]
	   s[ch]["PAC"]=phrase(get(f))
	   if (s[ch][0] > 0) for (n= 1; n<= s[ch][0]; n++)
	   {
	      ligne = split(get(f)," ")
	      s[ch][n] = [Xs = float(ligne[0]), Ys = float(ligne[1])]

	      merdoum = get(f)							 # merdoum !
	      while (substr(merdoum, sizeof(merdoum), 1) == "\\")		 #
		    merdoum = substr(merdoum, 1, sizeof(merdoum)-1) + get(f)	 #
										 #
	      s[ch][n][Ph] = phrase(merdoum)					 #
	   }
	}


	close(f)

	return(s)
}


# Choix d'une scène à interpréter:
#---------------------------------

function ChoixScene(scene)
{
	f = open(RacineN("Ev.backup",DATA),"w")		# précaution...
	put(f, Ev)
	close(f)

	undefine Ev
	Ev = scene
	ActiveTout()
	AcVar = []
}


function Init16()	# renvoie la phrase initialisant les 16 canaux
{
	In16 = ''
	for (ch=1; ch<=16; ch++) 
	{
		In16 = In16 | Ev[ch]["PAC"]
	}
	return (In16)
}


function PlusScene(s)
{
 warning = 0
 for (ch=1; ch <= NbCan; ch++) if ((nch = s[ch][0]) > 0) 
 {
   for (n=1; n <= nch; n++)
   {
       Ev[ch][n+Ev[ch][0]]=[Xs= s[ch][n]["x"], Ys= s[ch][n]["y"], Ph= s[ch][n]["nodur"]]
       if ((Ev[ch]["PAC"] != s[ch]["PAC"]) && (s[ch][0] > 0))
	  warning = ch
   }
   Ev[ch][0] += nch
 }
 if (warning) Bprint(GMBlah_data0, warning,")")
 ActiveTout()
}


function EvPlot(fnom,...)			# exporte Ev au format Gnuplot
{						# assorti de son fichier de commandes
	filename = DEFDIR+fnom+".dat"
	f = open(filename,"w") 

	
	if (nargs() < 3) {grid = "grid"} else {grid = argv(2)} # option string: grid ou pas
	if (nargs() < 4) {size = 1} else {size = argv(3)}      # option float: taille des points


	xmin = xmax = ymin = ymax = 0
	for (ch=1; ch <=NbCan; ch++)
	{
	   put(f,sprintf("\n\n# canal %d\n", ch))
	   for (n=1; n<= Ev[ch][0]; n++)
	   {
	      xmin = Minimum(xmin, Ev[ch][n][Xs])
	      xmax = Maximum(xmax, Ev[ch][n][Xs])
	      ymin = Minimum(ymin, Ev[ch][n][Ys])
	      ymax = Maximum(ymax, Ev[ch][n][Ys])
	      put(f,sprintf("%d %f %f %p\n",n,Ev[ch][n][Xs],Ev[ch][n][Ys],Ev[ch][n][Ph])) 
	   }		
	}
	close(f) 
	range = "["+string(xmin-1)+":"+string(xmax+1)+"] ["+string(ymin-1)+":"+string(ymax+1)+"]"

	if (nargs() >= 2)
	{  
	   bo = argv(1)
	   xmin = bo["x0"]; xmax = bo["x1"]; ymin = bo["y0"]; ymax = bo["y1"] 
	   range = "["+string(xmin)+":"+string(xmax)+"] ["+string(ymin)+":"+string(ymax)+"]"
	}

	f = open(DATA+fnom+".gp","w") 

	put(f, "set size ratio -1\n")
	put(f, "set zeroaxis\n")
	put(f, "set key outside\n")
	put(f, "set pointsize "+string(size)+"\n")
	put(f, "set xtics 1\n")
	put(f, "set ytics 1\n")
	put(f, "set "+grid+" \n")
	put(f, "plot "+range)
	index = 0
	for (ch=1; ch <=NbCan; ch++) if (Ev[ch][0] >0)
	{
	   titre = "\"c"+string(ch)+"\""
	   put(f, " '"+filename+"' index "+string(index)+" using 2:3 title "+titre+", ")
	   index += 1
	}	
	put(f,"0 0 \n")
	put(f,"pause -1")
	close(f) 
}

function WriteDF(nomf, dir)
{
	if (nargs() == 1) dir = DEFDIR		

		f = open(dir+nomf+".df", "w")
		put(f, Volume) ; put(f, "\n")
		put(f, Pit) ; put(f, "\n")
		put(f, Dur) ; put(f, "\n")
		put(f, Pan) ; put(f, "\n")
		put(f, CScore) ; put(f, "\n")
		close(f)
}
function ReadDF(nomf, dir)
{
	if (nargs() == 1) dir = DEFDIR	

		f = open(dir+nomf+".df")
		T_ = get(f) ; eval("Volume = "+T_)
		T_ = get(f) ; eval("Pit = "+T_)
		T_ = get(f) ; eval("Dur = "+T_)
		T_ = get(f) ; eval("Pan = "+T_)
		T_ = get(f) ; eval("CScore = "+T_)
		close(f)

}


function WriteEv(nomf, dir)		# écrit les Ev dans dir (optionnel)
{
	if (nargs()==1) dir = DEFDIR

	filename = dir+nomf+".ev"
	f = open(filename, "w")

	put(f, Ev)
	close(f)
}


function LoadEv(fnom, dir)		# (dir optionnel)
{
	if (nargs()==1) dir = DEFDIR

	filename = dir+fnom+".ev"
	f = open(filename) 

	eval("Ev = "+get(f))

	close(f)
}


### Adressage des Ev par leur label:

function EvL(label) 
{
	for (ch = 1; ch <= NbCan; ch++) if (Ev[ch][0])
	    for (n=1; n<= Ev[ch][0]; n++)
		if (Ev[ch][n]["label"] == label) return (Ev[ch][n])
}


################################ Périmé :

function OldWriteEv(nomf, dir)		# écrit les Ev dans dir (optionnel)
{
	if (nargs()==1) dir = DEFDIR

	filename = dir+nomf+".ev"
	f = open(filename, "w")

	put(f, sprintf("%d \n", NbCan))	# nombre de canaux
	for (ch= 1; ch<= NbCan; ch++)
	{
	   put(f, sprintf("%d \n", Ev[ch][0]))
	   put(f, sprintf("%p \n", Ev[ch]["PAC"]))
	   for (n= 1; n<= Ev[ch][0]; n++)
	   {
	      put(f,sprintf("%f %f\n",Ev[ch][n][Xs],Ev[ch][n][Ys]))
	      put(f,sprintf("%p \n",Ev[ch][n][Ph]))
	   }
	}
	close(f)
}


function OldLoadEv(fnom, dir)	# (dir optionnel)
{
	if (nargs()==1) dir = DEFDIR

	filename = dir+fnom+".ev"
	f = open(filename) 

	Ev = []

	ncan = integer(get(f))
	if (ncan > NbCan) {
	   Bprint(GMBlah_data1, Nbcan+1, GMBlah_data2, ncan, GMBlah_data3) }
	
	for (ch= 1; ch<= ncan; ch++)
	{
	   Ev[ch]=[0= integer(get(f))]
	   Ev[ch]["PAC"]=phrase(get(f))
	   if (Ev[ch][0] > 0) for (n= 1; n<= Ev[ch][0]; n++)
	   {
	      ligne = split(get(f)," ")
	      Ev[ch][n] = [Xs = float(ligne[0]), Ys = float(ligne[1])]

	      merdoum = get(f)							 # merdoum !
	      while (substr(merdoum, sizeof(merdoum), 1) == "\\")		 #
		    merdoum = substr(merdoum, 1, sizeof(merdoum)-1) + get(f)	 #
										 #
	      Ev[ch][n][Ph] = phrase(merdoum)					 #
	   }
	   Bprint(GMBlah_data4,ch)
	}
	if (ncan < NbCan) for (ch= ncan+1; ch<= NbCan; ch++)
	{
	   Ev[ch]=[0=0, "PAC"='']
	   Bprint(GMBlah_data5,ch)
	}
	close(f)

	ActiveTout()
	AcVar = []
}

# pour en finir avec les merdoum ! (remplacements à faire...)
#
#  rappel du problème: KK sauvegarde les phrases en les coupant en
#	  segments de 78 caractères terminés par un \, d'où plusieurs
#	  lignes dans un fichier:
#	  get(f) ne ramène donc pas une phrase archivée par put(f,..)
#	  ... mais GetPhrase(f) si ! 
#	  (en plus, on a directement une variable phrase, et non string)
#
function GetPhrase(f)
{
	merdoum = get(f)						 
	while (substr(merdoum, sizeof(merdoum), 1) == "\\")   # "\\" représente un simple \
	    merdoum = substr(merdoum, 1, sizeof(merdoum)-1) + get(f)	 
									 
	return( phrase(merdoum) )					 
}


function NoEv()
{
	Ev = [0=0]
	for (ch = 1; ch <= NbCan; ch++) Ev[ch]=[0=0, "PAC"='']
	AcVar = []
}


###########################################################################################
########						   ################################
######## Maillage: géométrie				   ################################
########						   ################################
###########################################################################################


# Création d'un maillage:
#
#   Coincoin = Maillage(maille, xgerme, ygerme, reg, canal)
#
#	maille: fonction de maille, ex: MHexa(1.5, Pi/4)
#	xgerme, ygerme: point de départ (germe) de la construction
#	reg: région remplie par le maillage (le germe doit en faire partie !)
#	canal: canal attribué au maillage

function Maillage(maille, xgerme, ygerme, reg, canal)
{
	maillage = [0=0, "ch"= canal]
	DessineMaille(maille, xgerme, ygerme, 0, reg, maillage, canal)

	return (maillage)
}

function DessineMaille(maille, xref, yref, cote, reg, maillage, ch)
{
	if (cote == 0)			# maille complète (appel du germe)
	{
		nc = maille[0]
		sdep = 1
		cdep = 1
	}
	else				# maille partielle (voisin par cote)
	{
		nc = maille[0] - 1
		sdep = (cote + 2) %(maille[0]+1)
		if (sdep <= 1) {sdep +=1}
		cdep = (cote + 1) %(maille[0]+1)
		if (cdep == 0) {cdep = 1}
	}

	ok = 0
	for (v = 0; v < nc; v++)	#dessine la maille
	{	
		s = (sdep + v) %(maille[0]+1)	
		if (s < v) {s += 1}
					
		sommet = Setpolar(maille[s]["r"],maille[s]["theta"])

		xev = xref + sommet["x"]
		yev = yref + sommet["y"]

		dejala = 0				# ev. déjà là ?
		for (n = 1; n <= maillage[0]; n++)
		{  
		  if (EnvironEgal(maillage[n]["x"],xev) && EnvironEgal(maillage[n]["y"],yev)) 
		     	dejala = 1
		}

		if (Region(xev, yev, maillage["ch"],reg) && (dejala == 0))
		{
			ok += 1
			maillage[0] += 1		# nombre d'événements
			last = maillage[0]
			maillage[last] = ["nodur"= '']
			maillage[last]["x"] = xev		# coordonnées de l'événement
			maillage[last]["y"] = yev	
		}	
	}

	if (ok > 0)	# appels récursifs seulement si maille en partie dans région
	{
		for (v = 0; v < nc; v++)	# parcours le voisinage
		{	
			c = (cdep + v) %(maille[0]+1)
			if (c < v) {c+=1}
						
			voisin = Setpolar(maille[c]["vr"],maille[c]["vtheta"])				
			xv = xref + voisin["x"]
			yv = yref + voisin["y"]
		
			DessineMaille(maille, xv, yv, maille["adj"][c], reg, maillage)
		}
	}

	return (ok)	
	# ok= 0 si maille complètement hors région ou bien déjà tracée, pas d'appels
	# sinon, ok= nbe de sommets tracés, et la récursion continue
}


#
# Fonctions de définition de maille:
#
####################################

# format des mailles:
#--------------------
# maille[0]	nombre de côtés/sommets
#		       (ils seront numérotés dans le sens de l'horloge, le
#		        numéro d'un côté étant celui du sommet précédent)
# maille["adj"]	tableau contenant les paires de côtés adjacents dans le maillage
# maille[n]	tableau contenant la géométrie de la maille:
#	[n]["r"]	
#	[n]["theta"]	...position du sommet n 
#	[n]["vr"]	
#	[n]["vtheta"]	...position de la maille voisine côté n 
#			(la "position de la maille" est celle d'un point donné quelconque
#			 dans la maille, généralement le centre. La position des sommets est
#			 relative à ce point)

function MHexa(rayon, theta0)	# maille hexagonale
{
	hexa = [0=6, "adj"=[1=4, 2=5, 3=6, 4=1, 5=2, 6=3]]

	# le point de référence est le centre de l'hexagone

	for (n = 1; n <= 6; n++)
	{
		hexa[n] = []

		hexa[n]["r"] =	rayon			# position du sommet n
		hexa[n]["theta"] = Mod2Pi(theta0 + n*2*Pi/6)

		hexa[n]["vr"] =	2*rayon*cos(Pi/6)	# ref. du voisin n
		hexa[n]["vtheta"] = Mod2Pi(theta0 + (1+2*n)*Pi/6)
	}
	return (hexa)
}



function MRect(cx, cy, theta0)	# maille rectangulaire
{
	rect = [0=4, 1=[], 2=[], 3=[], 4=[], "adj"=[1=3, 2=4, 3=1, 4=2]]

	# le point de référence est le centre du rectangle

	demidiag = 0.5*sqrt(cx*cx+cy*cy)
	theta1 = acos(0.5*cx/demidiag)

	rect[1]["theta"] = theta1
	rect[2]["theta"] = 2*Pi - theta1
	rect[3]["theta"] = theta1 + Pi
	rect[4]["theta"] = Pi - theta1

	rect[1]["vr"] = cx
	rect[1]["vtheta"] = 0
	rect[2]["vr"] = cy
	rect[2]["vtheta"] = 0.5*Pi
	rect[3]["vr"] = cx
	rect[3]["vtheta"] = Pi
	rect[4]["vr"] = cy
	rect[4]["vtheta"] = 1.5*Pi

	for (n = 1; n <= 4; n++)
	{
		rect[n]["r"] = demidiag		
		rect[n]["theta"] = Mod2Pi(theta0 + rect[n]["theta"])
		rect[n]["vtheta"] = Mod2Pi(theta0 + rect[n]["vtheta"])
	}
	return (rect)
}



###########################################################################################
########						   ################################
######## Collection / Maillage: attribution des notes	   ################################
########						   ################################
###########################################################################################


function Idem(coll, nodur)			# une note/phrase pour tous !
{
	for (n=1; n<= coll[0]; n++)
	    coll[n]["nodur"] = nodur
}


function DansChoix(coll, choix, nb, dispersion)	# événements aléatoires de nb notes
						# (prendre un coll["ch"]>16)
{
	for (n=1; n<= coll[0]; n++)
	    coll[n]["nodur"] = RandomMix(choix, nb, dispersion)
}


function RandomNotes(coll,pmin,pmax,dmin,dmax,vmin,vmax) # ev. aléatoires en une note
{
	for (n=1; n<= coll[0]; n++)
	{
	   coll[n]["nodur"] =  makenote(rand(pmin, pmax), rand(dmin, dmax),rand(vmin, vmax)) 
	}
}



###########################################################################################
########						   ################################
######## Pistes						   ################################
########						   ################################
###########################################################################################

# Format de piste:
#
# piste[0]	nbe de points
# piste[n]["x"]
# piste[n]["y"]	... les points eux-mêmes



function Piste(xdek, ydek, kmin, kmax, deltak)	# renvoie des points sur la courbe x(k), y(k) 
						# pour deltak entre deux points
{
	if (sizeof(split(xdek, "=")) == 1) xdek = "X= "+xdek
	if (sizeof(split(ydek, "=")) == 1) ydek = "Y= "+ydek
	
	pis = [0= n = 0]
	for (K = kmin; K<= kmax; K += deltak)
	{
		n += 1
		eval(xdek)			# ex de xdek: "X= cos(K)"
		eval(ydek)			#       ydek: "Y= sin(K)"
		pis[n]= ["x"= X, "y"= Y]
	}
	pis[0] = n

	return (pis)
}


function WritePiste
{}

function ReadPiste
{}
