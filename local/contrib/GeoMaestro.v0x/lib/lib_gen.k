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
########                                               ####################################
######## Librairie de générateurs d'événements	       ####################################
########                                               ####################################
######## Events generators library		       ####################################
########                                               ####################################
###########################################################################################

function choice_of_generators() 
{
	GenPalette = []
	GenRegion = Tout

	# ENREGISTREZ ICI LES GENERATEURS QUE VOUS VOULEZ DANS LE GUI:
	# (REGISTER HERE YOUR CHOOSEN GENERATORS FOR THE GUI)

	return([	
			     0 = "RandPick",     
			     1 = "ModNodur",	     
			     2 = "Clavier",
			     3 = "RegRect",
			     4 = "RegDisk",
			     5 = "Hexagons",
			     6 = "EditScore"
	])
}

###############################################################################################
# Principe: chaque genérateur "Toto" peut être divisé en trois fonctions: 
#	    TotoDown(), TotoDrag() et TotoUp()
# qui gèrent ses actions respectives à la souris. Si elles sont absentes, "Toto" est simplement 
# appelé pour le Down, et rien n'arrive au Drag ni au Up

# TotoDrag() doit retourner un entier (mode) qui détermine l'affichage lors du drag:
#	     0: rien
#	     1: segment entre A et B
#	     2: rectangle entre A et B
#	     3: cercle centré en A
#	     4: cercle centré en B
#	     5: cercle centré sur le milieu de (A,B)
#	     6: lignes de repérages: croix en A + croix en B + droite (A,B)
#	     7: découpage du plan en 4 secteurs autour de A + segment AB
#	     8:			     8 secteurs
#	     9:			     16 secteurs
#	     10: découpage du plan en anneaux espacés de 1 et centrés en A + segment AB
#	     11:					 0.1
#	     12: palette 12 octaves (grille 12*12)				{pi: ni, nj}
#	     13: palette 100 (grille 10*10)					{pi: ni, nj}
#	     14: palette 36 (grille 6*6)					{pi: ni, nj}
#	     15: fond blanc, et ?
#
# .. évidemment il vaut mieux que ce mode ait un rapport avec l'action du TotoUp()...
# (le choix de ce mode détermine d'ailleurs la nature des 3 arguments pi passés à TotoUp()

# TotoUp() doit aussi retourner un string, qui a le sens suivant (plusieurs options sont possibles
#	   à condition de les séparer par un ";"):
#	  "" (ou absence de return() ):	   rien de spécial
#	  "NoRedraw"		      :	   le redraw() n'est pas effectué
#	  Nom de générateur	      :	   le relai passe à ce générateur, s'il est enregistré
#					   

# paramètres passés à TotoDown: xA,yA,cible,ch (x et y dans l'espace Géo, ch canal courant)
# paramètres passés à TotoDrag: xD,yD,cible
# paramètres passés à TotoUp: xB,yB,cible,p1,p2,p3 (les pi dépendent du mode du Drag)
#
# cible est un ev. ou un array vide [], selon le cas (voir $.cherche_cible dans winterface.k)
#
################################################################################################



#	AJOUTEZ VOS PROPRES GENERATEURS ICI !     //     ADD YOUR OWN GENERATORS HERE !



###########################################################################################
### RandPick	(sélection une événement sur 5, au hasard, dans une région rectangulaire)

function RandPickDown(x,y) 
{
	RandPick_Ax = x
	RandPick_Ay = y
}
function RandPickDrag(x,y) 
{
	return (2)
}
function RandPickUp(x,y) 
{
	PourToutEv(RandPick, RandPick_Ax, RandPick_Ay, x, y)
}
function RandPick(ev,xa,ya,xb,yb) 
{
	x0 = Minimum(xa,xb)
	x1 = Maximum(xa,xb)
	y0 = Minimum(ya,yb)
	y1 = Maximum(ya,yb)
	if ((ev["x"] >= x0) && (ev["x"] <= x1) && (ev["y"] >= y0) && (ev["y"] <= y1))
	   if (rand(5) > 3)
	      ev["s"] = 1
	
	return (ev)
}



###########################################################################################
### Clavier	(présente une palette de notes MIDI sur le canal courant)


function ClavierDown(x,y,cible,ch) {
	 GenPalette = []
	 for (i=0; i<=11; i++) 
	 { 
	   GenPalette[i] = []
	   for (j=0; j<=11; j++) 
	     if ((p = 12*j+i) <= 127)
	     {
	       nij = phrase("'p"+string(p)+"'")
	       GenPalette[i][j] = RemplaceInStr(string(nij),"'","")
	     }
	 }
	 Clavier_ch = ch
	 Clavier_A = xyd(x,y)
	 Clavier_sur_cible = 0
	 if ("nodur" in cible)
	 {
	    print("Nodur actuel: ",cible["nodur"])
	    Clavier_cible = ArCopy(cible)
	    Clavier_sur_cible = 1
	 }
}
function ClavierDrag() {
	 return (12)
}
function ClavierUp(x,y,cible,ni,nj) {
	 
     if ((x != Clavier_A["x"]) || (y != Clavier_A["y"]) )
     {
     	 nij = 12*nj+ni
	 if (nij <= 127)
	 {
	    if (Clavier_sur_cible)
	    {
		ch = Clavier_cible["ch"]
		ne = Clavier_cible["n"]		
		if (Ev[ch][ne]["nodur"] != '')
		   Ev[ch][ne]["nodur"].pitch = nij
		else
		   Ev[ch][ne]["nodur"] = phrase("'p"+string(nij)+"'")		   
		print("Nodur final: ",Ev[ch][ne]["nodur"])
	    }
	    else
	    {
		ch = Clavier_ch
		index = CreateNewEvent(Clavier_A["x"],Clavier_A["y"],ch, phrase("'p"+string(nij)+"'"))
		print("Nouvel ev (",ch,",",index,"):", Ev[ch][index]["nodur"])
	    }
	 }
     }
}


###########################################################################################
### ModNodur	(réglage ergonomique de la durée et du volume du nodur de la cible)

function ModNodurDown(x,y,cible) {
	 ModNodur_action = 0
	 if ("nodur" in cible)
	 {
		ModNodur_action = 1
		ModNodur_cible = ArCopy(cible)
		ModNodur_A = xyd(x,y)
		print("Nodur actuel: ",cible["nodur"])
	 }
	 else print("Pas d'événement ici !")
}
function ModNodurDrag(x,y,cible) {
	 if (ModNodur_action == 1)
	 {	
		print("Dur ->", Arrondi(CPCM*Dist(ModNodur_A,xyd(x,y))),"(",ModNodur_cible["nodur"].dur,")")
		print("Vol ->", Arrondi((127/(2*Pi))*Thet(ModNodur_A,xyd(x,y))),"(",ModNodur_cible["nodur"].vol,")")
		return (10)
	 }
	 else
		return (0)
}
function ModNodurUp(x,y,cible) {
	 if (ModNodur_action == 1)	 
	 {
		ch = ModNodur_cible["ch"]
		ne = ModNodur_cible["n"]
		Ev[ch][ne]["nodur"].dur = Dist(ModNodur_A,xyd(x,y))*CPCM
		Ev[ch][ne]["nodur"].vol = (127/(2*Pi))*Thet(ModNodur_A,xyd(x,y))
		Ev[ch][ne]["nodur"].length = latest(Ev[ch][ne]["nodur"])
		print("Nodur final: ",Ev[ch][ne]["nodur"])
	 }    
}


###########################################################################################
### RegRect	(définition de GenRegion comme rectangle)

function RegRectDown(x,y) 
{
	RegRect_A = xyd(x,y)
}
function RegRectDrag(x,y) 
{
	return (2)
}
function RegRectUp(x,y) 
{
	GenRegion = RRect(RegRect_A, xyd(x,y))
	print ("GenRegion définie (rectangle)")
}

###########################################################################################
### RegDisk	(définition de GenRegion comme Disque)

function RegDiskDown(x,y) 
{
	RegDisk_A = xyd(x,y)
}
function RegDiskDrag(x,y) 
{
	return (3)
}
function RegDiskUp(x,y) 
{
	GenRegion = RDisque(RegDisk_A, Dist(RegDisk_A,xyd(x,y)))
	print ("GenRegion définie (disque)")
}


###########################################################################################
### Hexagons	(création d'un maillage hexagonal dans la région  GenRegion)

function HexagonsDown(x,y,cible,ch) 
{
	Hexagons_A = xyd(x,y)
	Hexagons_ch = ch
	if (RegionPoint(Hexagons_A, GenRegion)) Hexagons_ok = 1 else Hexagons_ok = 0
}
function HexagonsDrag(x,y) 
{
	return (1)
}
function HexagonsUp(x,y) 
{
  if (Hexagons_ok)
  {
    if (GenRegion != Tout) 
    {
	cote = Dist(Hexagons_A, xyd(x,y))
	angle = Thet(Hexagons_A, xyd(x,y))
	germex = Hexagons_A["x"]
	germey = Hexagons_A["y"]
	print ("Calculating hexagons...")
	EvPlusCol(Maillage(MHexa(cote,angle), germex, germey, GenRegion, Hexagons_ch ))
	print (".. done.")
    }
    else print ("Il faut définir une GenRegion limitée !")
  }
  else print ("Le germe n'est pas dans GenRegion !")
}




###########################################################################################
### EditScore	(initialise ou modifie le champs "score" des événements)

function EditScoreDown(x,y,cible,ch) 
{
   		if (!defined(EditScore_ligne)) EditScore_ligne = 1			#ligne courante
		if (!defined(EditScore_pn)) EditScore_pn = 4	 			#pn courant
		if (!defined(EditScore_ch)) EditScore_ch = ch	 			#canal courant

		GenPalette = [0= [0="p1 !",1="p2 !",2="p3 !",3="p4",4="p5", 5="p6"],
			      1= [0="p7",1="p8",2="p9",3="p10",4="p11", 5="p12"],
			      2= [0="p13",1="p14",2="p15",3="p16",4="p17", 5="p18"],
			      3= [0="(kill)",1="",2="",3="",4="(!del!)", 5=""],
			      4= [0="(init)",1="(set)",2="(p=)",3="(p+=)",4="(save)", 5="(header)"],
			      5= [0="-> L"+string(EditScore_ligne),
				  1="-> p"+string(EditScore_pn),
				  2="(p=f..)",3="(p*=)",4="(read)",
				  5="Ch "+string(EditScore_ch)]]


	EditScore_action = 0
	if ("nodur" in cible)
	{
		EditScore_cible = cible
		EditScore_action = 1

		print("nodur: ",cible["nodur"])
		if (("score" in cible) && (cible["score"][0] > 0))
		{
			print ("score:")
			PrintScore(cible)
		}
		else print("pas de score")
	}
	else EditScore_action = 0
}
function EditScoreDrag(x,y,cible) 
{
		return(14)	# palette 6*6
}
function EditScoreUp(x,y,cible,ni,nj) 
{
	if (EditScore_action == 1)
	{
		ch = EditScore_cible["ch"]
		n = EditScore_cible["n"]
		if (!("score" in EditScore_cible)) Ev[ch][n]["score"]=[0=0]	
	}

		command = GenPalette[ni][nj]
		if ((command == "(init)")&& (EditScore_action == 1))
		{
		     l = EditScore_ligne
		     print("Initialisation/Réécriture de la ligne "+string(l)+" (n£ pour ligne n)")
		     h = getastr(string(l)+"> ", "")
		     if (h!="")
		     {
			if (h ~~ "£") 
			{
				l = integer(split(h, "£ ")[0])
				h = split(h, "£")[1]
			} 
			Ev[ch][n]["score"][l] = h
			if (Ev[ch][n]["score"][0] < l) Ev[ch][n]["score"][0] = l
			PrintScore(Ev[ch][n])
		     }
		}

		else if (command ~~ "-> L")		# ligne
			EditScore_ligne = integer(getastr("ligne n° > ", ""))

		else if (command ~~ "-> p")		# pn 
			EditScore_pn = integer(getastr("param. n° > ", ""))

		else if (ni <= 2)			# pn direct
		{
			EditScore_pn = integer(split(command,"p")[0])
			if ((EditScore_action == 1) && (EditScore_ligne in Ev[ch][n]["score"]))
			{
			  p = SCgetpn(Ev[ch][n]["score"][EditScore_ligne], EditScore_pn)
			  if (typeof(p) == "string")
			   print ("Error : l"+ string(EditScore_ligne)+" = "+Ev[ch][n]["score"][EditScore_ligne])
			  else
			   print ("l"+ string(EditScore_ligne)+"p"+string(EditScore_pn)+" = "+string(p))
			}
		}

		else if ((command == "(set)")&& (EditScore_action == 1))
		{
			r = getastr("l"+string(EditScore_ligne)+", p"+string(EditScore_pn)+" > ", "")
			if (r != "")
			  Ev[ch][n]["score"][EditScore_ligne] = SCpn(Ev[ch][n]["score"][EditScore_ligne], EditScore_pn, float(r))
			PrintScore(Ev[ch][n])
		}

		else if ((command ~~ "(p")&& (EditScore_action == 1))
		{
			h = getastr("l"+ string(EditScore_ligne)+"p"+string(EditScore_pn)+" "+command+" > ","")
			if (h != "")
			{
				if (h ~~ ";")
				{
					 np = integer(split(h,"; ")[0])
					 h = split(h,";")[1]
				}
				else 
				     np = EditScore_pn
				p = SCgetpn(Ev[ch][n]["score"][EditScore_ligne], np)
				if (typeof(p) == "string") print("Error!")
				else
				{
				    if (command == "(p=)")
   Ev[ch][n]["score"][EditScore_ligne] = SCpn(Ev[ch][n]["score"][EditScore_ligne], np, float(h))		    

				    else if (command == "(p*=)")				 
   Ev[ch][n]["score"][EditScore_ligne] = SCpn(Ev[ch][n]["score"][EditScore_ligne], np, p*float(h))		    

				    else if (command == "(p+=)")
   Ev[ch][n]["score"][EditScore_ligne] = SCpn(Ev[ch][n]["score"][EditScore_ligne], np, p+float(h))		    

				    else if (command == "(p=f..)")
				    {
				    eval("T_="+h)
   Ev[ch][n]["score"][EditScore_ligne] = SCpn(Ev[ch][n]["score"][EditScore_ligne], np, T_)		    
				    }
				}
				PrintScore(Ev[ch][n])
			}
		}

		else if ((command == "(kill)")&& (EditScore_action == 1))		
		{
		    h = getastr("delete line "+string(EditScore_ligne)+" from score > ","n")
		    if (h != "n") 
		    { 
		      if (h ~~ "-")
		      {
			li1 = integer(split(h,"- ")[0])
			li2 = integer(split(h,"- ")[1])
                      }
		      else if (typeof(integer(h)) == "integer") 
		      {
			li1 = integer(h) 
			li2 = integer(h)
		      }
		      else 
		      {
		        li1 = EditScore_ligne 
		        li2 = EditScore_ligne 
		      }
		      for (l = li2; l>= li1; l--) if (l in Ev[ch][n]["score"])
		      {
			  Ev[ch][n]["score"][0] -= 1
			  Ev[ch][n]["score"] = SupprimeIndex(l, Ev[ch][n]["score"])
		      }
		      PrintScore(Ev[ch][n])
		    }
		}	

		else if ((command == "(!del!)")&& (EditScore_action == 1))		
		{
		    if ((h = getastr("delete score for selected event > ","n")) != "n") 
		    { 
		         Ev[ch][n]["score"] = [0=0]
			 print("score deleted !")
		    }
		}	

		else if ((command == "(save)")&& (EditScore_action == 1))		
		{
		    if ((h = getastr("score to variable > ","")) != "") 
		    { 
		         T__ = ArCopy(Ev[ch][n]["score"])
			 eval (h+"=ArCopy(T__)")
		    }
		    else if ((h = getastr("score to file (.sco in DATA) > ","")) != "")   
			 ExScore(Ev[ch][n], DATA+h+".sco")
		}	

		else if ((command == "(read)")&& (EditScore_action == 1))		
		{
		    h = getastr("score from variable > ","")
		    if (h != "")
		    {
			eval("T__ = "+h)
			Ev[ch][n]["score"] = T__				
			PrintScore(Ev[ch][n])
		    }
		    else if ((h = getastr("score from file (.sco in DATA) > ","")) != "") 
		    {
		      Ev[ch][n]["score"] = ReadScore(DATA+h+".sco")
		      PrintScore(Ev[ch][n])
                    }
		}			

		else if (command == "(header)")		
		{
		    if ("score" in Ev[EditScore_ch])
		    {
			print("CScore score for ch."+string(EditScore_ch)+":")
			PrintScore(Ev[EditScore_ch]["score"])
		    }
		    else print (("No header for ch."+string(EditScore_ch)))
		    h = getastr("header from variable > ","")
		    if (h != "")
		    {
			eval("T__ = "+h)
			Ev[EditScore_ch]["score"] = T__				
			PrintScore(Ev[EditScore_ch]["score"])
		    }
		    else if ((h = getastr("header from file (.sco in DATA)> ","")) != "")
		    {
			Ev[EditScore_ch]["score"] = ReadScore(DATA+h+".sco")
		        PrintScore(Ev[EditScore_ch]["score"])
		    }
		}

		else if (command ~~ "Ch ")		
			EditScore_ch = integer(getastr("ch n°> ", ""))

		else if (EditScore_action == 0)
		        print ("You must select an ev. to work on !")	
}






###########################################################################################
########						       ############################
######## Fonctions pratiques pour l'écriture de générateurs    ############################
########						       ############################
###########################################################################################


function CreateNewEvent(x, y, ch, nodur) 
{

	 Ev[ch][0] += 1
	 Ev[ch][Ev[ch][0]] = ["x"= x, "y"= y, "nodur" = nodur, "actif"=1]

	 return (Ev[ch][0])
}

function PourToutEv(appli,...) 
{
	for (ch = 1; ch <= NbCan; ch++) if (Ev[ch][0] > 0)
	     for (n=1; n <= Ev[ch][0]; n++) if (Ev[ch][n]["actif"] == 1)	 
		 Ev[ch][n] = appli(Ev[ch][n],...)
}

function RemoveEv(ch,n)
{
   if ((ch <= NbCan) && (n <= Ev[ch][0]))
   {
	Ev[ch] = SupprimeIndex(n, Ev[ch])
	Ev[ch][0] -= 1
   }
}

function EvLabeled(label)
{
	for (ch = 1; ch <= NbCan; ch++) if (Ev[ch][0] > 0)
	     for (n=1; n <= Ev[ch][0]; n++) 	 
		 if (Ev[ch][n]["label"] == label) 
		 {
			res = ArCopy(Ev[ch][n])
			res["ch"] = ch
			res["n"] = n 
			return(res)
		 }
}


##### plutôt pour les scripts:

# tableau des compteurs: EVCOMPT

function Compteur(gvarname)
{
	eval("T_=defined("+gvarname+")")
	if (T_) eval(gvarname+"+=1")
	else eval(gvarname+"=1")

	if (defined(EVCOMPT)) EVCOMPT[gvarname] = N_ else EVCOMPT = [gvarname= N_]
	eval("N_="+gvarname)

	return(N_)
}

function ZeroCompteur(gvarname)
{
	eval("T_=defined("+gvarname+")")
	if (T_)
	   eval("N_="+gvarname)
	else
	   N_ = -1

	if (defined(EVCOMPT)) EVCOMPT[gvarname] = 0 else EVCOMPT = [gvarname= 0]
	eval(gvarname+"=0")

	return(N_)
}

function ZeroCOMPT()
{
	if (!defined(EVCOMPT)) EVCOMPT = []
	tampon = ArCopy(EVCOMPT)
	for (s in EVCOMPT)
	{
		EVCOMPT[s] = 0
		eval(s+"=0")
	}

	return (tampon)
}

