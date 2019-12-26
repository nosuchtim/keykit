

###########################################################################################
########			                       ####################################
######## Interpréteur de déclarations géométriques     ####################################
########			                       ####################################
###########################################################################################

function Geo(fname, ...)	# points, cercles et régions implémentés pour l'instant
				# (...) pour une éventuelle liste à compléter
				# et/ou un DIR de remplacement (défaut: COMPOS)
{
  geodir = COMPOS
  gplot = 0

  if ((narg = nargs())>1) for (n=1; n< narg; n++)
  {
     if (typeof(argv(n)) == "array")		# mode interpréteur GnuPlot
     {   
	  liste = argv(n) 
	  gplot = 1	
	  gp = open(liste["fnom"], "a") 
     }
     if (typeof(argv(n)) == "string")		# là, c'est un DIR
	  geodir = argv(n)
  }

  f = open(geodir+fname+".geo")		# nom du fichier source (en .geo)
	
  while ((ligne = get(f)) != Eof) 
  {
    ligne = split(ligne, "\r")[0]		# supression du "\r" éventuel

    section= (sli = split(substr(ligne,1,sizeof(ligne)-1)," "))[0]

    tab1 = tab2 = ""
    if (substr(section,1,8) == "#tableau")	# pour "tableau AA points"
    {						# ou "tableau CER cercles"
       tab1 = sli[1]+"["
       tab2 = "]"
       eval(sli[1]+"=[]")
       section = "#"+sli[2]
    }

    if (substr(section,1,6) == "#point")
    {
       x = y = "0"
       while (substr((p = split(substr(lu=split(get(f),"\r")[0],1,sizeof(lu))," "))[0],1,4) != "#fin")
       {
	 if (p[0]=="") {}				# (rien)	
         	
	 else if (p[0] == "p")				# polaire:   "p OI 1 0"
	 {
	   nom = tab1+p[1]+tab2
	   eval(nom+"=G__=Setpolar("+p[2]+","+p[3]+")")
	   x = string(G__["x"])
	   y = string(G__["y"])
	   Bprint("Point: "+nom+"=",G__)
	 }

	 else if ((p[0] == ">")	&& (p[1] == "p"))	# relatif et en polaires
	 {
	   eval("G__=Setpolar("+p[3]+","+p[4]+")")
	   x = string(G__["x"]+float(x))
	   y = string(G__["y"]+float(y))
	   nom = tab1+p[2]+tab2
           eval(nom+"=G__=[Xs="+x+",Ys="+y+"]")
	   Bprint("Point: "+nom+"=",G__)
	 }

	 else if (p[0] == ">")		# relatif au point précédent, rectangulaire
	 {
	   nom = tab1+p[1]+tab2
           eval(nom+"=G__=[Xs="+(x=p[2]+"+("+x+")")+",Ys="+(y=p[3]+"+("+y+")") +"]")
	   Bprint("Point: "+nom+"=",G__)
	 }

	 else				# ordinaire: "AA 12.23 56"
	 {
	   nom = tab1+p[0]+tab2
	   eval(nom+"=G__=[Xs= "+(x=p[1])+", Ys= "+(y=p[2])+"]")           
	   Bprint("Point: "+nom+"=",G__)
	 }    

	 if ((p[0] != "") && (gplot == 1))
	 {  
	   it = (liste[0] = liste[0]+1)
	   liste[it] = [0 = 1, 1 = "points@using 1:2 ", "leg" = nom]
	   put(gp, "\n\n"+x+" "+y+"\n")

	   liste["xmax"] = Maximum(liste["xmax"], float(x))
	   liste["xmin"] = Minimum(liste["xmin"], float(x))
	   liste["ymax"] = Maximum(liste["ymax"], float(y))
	   liste["ymin"] = Minimum(liste["ymin"], float(y))
	 }
       }
    }

    else if (substr(section,1,7) == "#cercle")
    {
      while (substr((p= split(substr(lu=split(get(f),"\r")[0],1,sizeof(lu))," "))[0],1,4) != "#fin")
      {
	if (1 in p) eval("G__=typeof("+p[1]+")")

	if (p[0]=="") {}				# (rien)	

	else if (G__ == "array")				# centre et rayon
	{
	  nom = tab1+p[0]+tab2
	  eval(nom+"=G__=[Cs="+p[1]+", Rs="+(r=p[2])+"]")
	  Bprint(GMblah_geo1+nom+"=",G__)

	  eval("X ="+p[1]+"[Xs]; Y ="+p[1]+"[Ys]")
	  x=string(X); y=string(Y)
        }

	else						# x, y et rayon
	{
	  nom = tab1+p[0]+tab2
Bprint(nom+"=G__=[Cs=[Xs="+(x=p[1])+",Ys="+(y=p[2])+"], Rs="+(r=p[3])+"]")
	  eval(nom+"=G__=[Cs=[Xs="+(x=p[1])+",Ys="+(y=p[2])+"], Rs="+(r=p[3])+"]")
	  Bprint(GMblah_geo1+nom+"=",G__)
	}

	if ((p[0] != "") && (gplot == 1))
	{  
	 it = (liste[0] = liste[0]+1)
	 com = "[0:2*pi]@(" + r + ")*cos(t)+(" + x + "), (" + r + ")*sin(t)+(" + y +  ") "
	 liste[it]= [0= 1, 1= com, "leg" = nom] 

	 liste["xmax"] = Maximum(liste["xmax"], float(x)+float(r))
	 liste["xmin"] = Minimum(liste["xmin"], float(x)-float(r))
	 liste["ymax"] = Maximum(liste["ymax"], float(y)+float(r))
	 liste["ymin"] = Minimum(liste["ymin"], float(y)-float(r))
	}
      }		
    }

    else if (substr(section,1,7) == "#region")
    {

      while (substr((p= split(substr(lu=split(get(f),"\r")[0],1,sizeof(lu))," "))[0],1,4) != "#fin")
      {
        if ((1 in p)&&(p[1] == ":"))	# nom d'une construction 
	{
	   nom_cons = tab1+p[0]+tab2
	   construction = 2
	   ind = 3
	}    
	else if (p[0] == "ET") {regtype = p[1]; construction = 1; ind = 2}
	else if (p[0] == "OU") {regtype = p[1]; construction = -1; ind = 2}
	else if (p != []) {regtype = p[0]; construction = 0; ind = 1}

	if (p[0]=="") {}				# (rien)	

	else
	{	
	 if ((!(ind in p))||(p[ind] == "#"))		# rappel d'un nom de région 
	 {     
           nom = tab1+p[ind-1]+tab2	   
	   eval("G1__="+nom)
	   regtype = nom
	 }  

	 else if ((regtype == "d")||(regtype == "d-"))			# disque
	 {
	  nom = tab1+p[ind]+tab2
	  if (regtype == "d-") regop = ", EnMoinsDe)" else regop =")"

	  if (typeof(p[ind+1])=="array") arg1 = p[indic = ind+1]
	     else arg1 = "[Xs="+p[ind+1]+",Ys="+p[indic = ind+2]+"]"

	  arg2 = p[indic+1]

	  eval(nom+"=G1__=RDisque("+arg1+", "+arg2+regop)
         }

	 else if ((regtype == "r")||(regtype == "r-"))			# rectangle
	 {
	  nom = tab1+p[ind]+tab2
	  if (regtype == "r-") regop = ", EnMoinsDe)" else regop =")"

	  if (typeof(p[ind+1])=="array") arg1 = p[indic = ind+1]
	     else arg1 = "[Xs="+p[ind+1]+",Ys="+p[indic = ind+2]+"]"

	  if (typeof(p[indic+1])=="array") arg2 = p[indic+1]
	     else arg2 = "[Xs="+p[indic+1]+",Ys="+p[indic+2]+"]" 

	  eval(nom+"=G1__=RRect("+arg1+", "+arg2+regop)
	 }

	 else if ((regtype == "t")||(regtype == "t-"))			# triangle
	 {
	  nom = tab1+p[ind]+tab2
	  if (regtype == "t-") regop = ", EnMoinsDe)" else regop =")"

	  if (typeof(p[ind+1])=="array") arg1 = p[indic = ind+1]
	     else arg1 = "[Xs="+p[ind+1]+",Ys="+p[indic = ind+2]+"]"

	  if (typeof(p[indic+1])=="array") arg2 = p[indic = indic+1]
	     else arg2 = "[Xs="+p[indic+1]+",Ys="+p[indic = indic+2]+"]" 

	  if (typeof(p[indic+1])=="array") arg3 = p[indic+1]
	     else arg3 = "[Xs="+p[indic+1]+",Ys="+p[indic+2]+"]" 

	  eval(nom+"=G1__=RTri("+arg1+", "+arg2+", "+arg3+regop)
	 }

	 if (construction == 2)
	    eval(nom_cons+"=G__=G1__")
	 else if (construction == 1)					# articulation OU/ET
	    eval(nom_cons+"=G__=RegionET(G1__, G__)") 
	 else if (construction == -1)
	    eval(nom_cons+"=G__=RegionOU(G1__, G__)")
	 else
	    { nom_cons = nom ; G__=G1__}
	 Bprint(GMblah_geo2+regtype+"): "+nom_cons+"=",G__)

	}
      }		

    }

  }
  close(f)
  if (gplot == 1) 
     {close(gp) ; return (liste)}
}




###########################################################################################
########			                       ####################################
######## Construction des fichiers MIDI rendus         ####################################
########			                       ####################################
###########################################################################################

function MIDI(phrase, fnom, ...)	# ... pour un événtuel autre répertoire de destination
					# que MDOP (par exemple: VRAC)
{
	if (nargs() == 3) dir = argv(2) else dir = MDOP

	writemf(Init16() + phrase, dir+fnom+".mid")
	if (Bavard) {print(GMblah_MIDI1,fnom+".mid")}
}


function ExMIDI(ligne, fnom, ...)	# ... pour un événtuel autre répertoire de destination
					# que MDOP (par exemple: VRAC)
{
	if (nargs() == 3) dir = argv(2) else dir = MDOP

	if ("tempo" in ligne) ltempo = ligne["tempo"] else ltempo = temponote(tempo())

	writemf(ltempo+ Init16() + ligne["ph"], dir+fnom+".mid")
	if (Bavard) {print(GMblah_MIDI1,fnom+".mid")}
}


function GrosMIDI(fnom, ...)	# la même avec autant de lignes qu'on veut
{
	res = ''
	for (n=1; n<=nargs()-1; n++) res |= argv(n)["ph"]
	writemf(Init16() + res, MDOP+fnom+".mid")
	if (Bavard) {print(GMblah_MIDI1,fnom+".mid")}	

	return (res)
}


# numéroteur de fichiers:	
#------------------------
# RacineN("bouh.gloup",Rep)
#				renvoie "bouh(258)" si 257 autres "bouh.gloup" sont
#				déjà présents dans le répertoire Rep (DEFDIR par défaut)
function RacineN(preums,...)
{
	if (nargs() == 2) dir= argv(1) else dir= DEFDIR

	n=1 
	fnom = fbase = split(preums,".")[0]
	ext = "."+split(preums,".")[1] 

	while (fileexists(dir+fnom+ext))
	      {	n += 1 ; fnom = fbase + "(" + string(n) + ")"	}

	return (fnom)
}
function FichierN(preums,...)	# le même, renvoyant le nom complet avec Path et extension
{
	if (nargs() == 2) dir= argv(1) else dir= DEFDIR

	n=0 
	fnom = fbase = split(preums,".")[0]
	ext = "."+split(preums,".")[1] 

	while (fileexists(dir+fnom+ext))
	      {	n += 1 ; fnom = fbase + "(" + string(n) + ")"	}

	return (dir+fnom+ext)
}




###########################################################################################
########			                       ####################################
######## Diverses fonctions pour se faciliter la vie   ####################################
########			                       ####################################
###########################################################################################



function Bprint(...)	# commentaire du mode bavard...
{
	if (Bavard) {print(...)}
}

function DEBUG(n, ...)	# commentaire si DebProf >= n
{
	if (DebProf >= n ) {print(...)}
}






###########################################################################################
########			                       ####################################
######## KK sur des nodurs sélectionnés		       ####################################
########			                       ####################################
###########################################################################################

# ceci est une fonction très puissante qui applique n'importe quelle
#      opération de KeyKit dont le résultat est une phrase à tous les
#      événements d'une scène donnée sur une région
#
# si l'input est le nodur initial, N_ doit remplacer le paramètre
# de phrase dans l'appel de la fonction KeyKit
#
# autres variables particulières: X_, Y_ et C_
#
# ex: KKSR(Ev, RDisque(Or,2), "N_ = transpose(N_, 1)")
# ou  KKSR(Scene, Tout, "N_ = makenote(rand(40,80))")
#
# ou, si on veut modifier les nodurs directement:
#     KKSR(Ev, RDisque(Or,2), "N_.vol += 10*X_")
#
# autres variables particulières: S_, P_, A_, L_
# ... à manipuler avec précaution !


function KKSR(ensemble, region, kkfunc)		# ensemble est une collection ou scène
{
    test = 0
    if (sfkk = sizeof(FKK)) for (i=1; i<= sfkk; i++) test = test||(kkfunc == FKK[i])
    if (!test) FKK[sfkk+1] = kkfunc

    if ("ch" in ensemble)				# ... ici on a affaire à une collection
    	for (ne=1 ; ne<=ensemble[0] ; ne++)	
	{
	      X_ = ensemble[ne]["x"]
	      Y_ = ensemble[ne]["y"]
	      C_ = ensemble["ch"]
	      N_ = ensemble[ne]["nodur"]
	      
	      if (Region(X_,Y_,C_,region)) 		   		
		eval(kkfunc)

	      ensemble[ne]["x"] = X_
	      ensemble[ne]["y"] = Y_
	      ensemble[ne]["nodur"] = N_
        }

    else for (ch = 1; ch <= NbCan; ch++) if (ensemble[ch][0])
	for (ne=1 ; ne<=ensemble[ch][0] ; ne++)	
	{
	      X_ = ensemble[ch][ne]["x"]
	      Y_ = ensemble[ch][ne]["y"]
	      N_ = ensemble[ch][ne]["nodur"]	      
	      C_ = ch
	      
	      if (Region(X_,Y_,ch,region)) 		 	
		eval(kkfunc)

	      ensemble[ch][ne]["x"] = X_
	      ensemble[ch][ne]["y"] = Y_
	      ensemble[ch][ne]["nodur"] = N_	
	      
        }
}


function KKSS(kkfunc)	# variante élaborée, sur la sélection (voir wgeom.k)
			#
			# kkfunc commence par ":", on prend la valeur de la suite de kkfunc 
			# (supposé être un string) comme valeur de kkfunc
			#  ex: si F="X_=X_+1" on peut appeler KKSS(":F") au lieu de KKSS(F)
			#
			# et en prime: KKSS gère les changements de canaux !
			#
			# plusieurs scripts peuvent se succéder s'ils sont séparés par "$"
{
  scripts=split(kkfunc,"$")
  for (i=0; i<sizeof(scripts); i++)
  {	
    kkfunc = GereHistory(scripts[i], FKK)      # si ":.." pour history et mode indirect

    modif_C = 0

    for (ch = 1; ch <= NbCan; ch++) if (Ev[ch][0])
	for (ne=1 ; ne<=Ev[ch][0] ; ne++) if (Ev[ch][ne]["s"] == 1)	
	{
	      X_ = Ev[ch][ne]["x"]
	      Y_ = Ev[ch][ne]["y"]
	      N_ = Ev[ch][ne]["nodur"]	      
	      C_ = ch
	      if ("s" in Ev[ch][ne]) S_ = Ev[ch][ne]["s"] else S_=0
	      if ("script" in Ev[ch][ne]) P_ = Ev[ch][ne]["script"] else P_=""
	      A_ = Ev[ch][ne]["actif"]	
	      if ("label" in Ev[ch][ne]) L_ = Ev[ch][ne]["label"] else L_=""
	 	
	      eval(kkfunc)

	      if (C_ == ch)	# pas de changement de canal
	      {
		Ev[ch][ne]["x"] = X_
		Ev[ch][ne]["y"] = Y_
		Ev[ch][ne]["nodur"] = N_	 
	        Ev[ch][ne]["s"] = S_     
#	        Ev[ch][ne]["script"] = P_
#	        Ev[ch][ne]["actif"] = A_
#	        Ev[ch][ne]["label"] = L_
              }
	      else if ((C_>= 1) && (C_<= NbCan))
	      {
	        modif_C = 1
		C_= Arrondi(C_)
		nn = (Ev[C_][0] += 1)
		Ev[C_][nn] = ["actif"= 1]
		Ev[C_][nn]["x"] = X_
		Ev[C_][nn]["y"] = Y_
		Ev[C_][nn]["nodur"] = N_	
	        Ev[C_][nn]["s"] = -S_		
#	        Ev[C_][nn]["script"] = P_
#	        Ev[C_][nn]["actif"] = A_
#	        Ev[C_][nn]["label"] = L_	

		Ev[ch] = SupprimeIndex(ne, Ev[ch])	
		Ev[ch][0] -= 1
		ne -= 1
	      }
	      
        }

    if (modif_C)
      for (ch = 1; ch <= NbCan; ch++) if (Ev[ch][0])
	for (ne=1 ; ne<=Ev[ch][0] ; ne++) if (Ev[ch][ne]["s"] == -1) Ev[ch][ne]["s"] = 1
  }
}



function OperationScript(script, ev, ch, ne)		# appel simple de base sur un évenement
{
	      X_ = ev["x"]
	      Y_ = ev["y"]
	      N_ = ev["nodur"]	      
	      C_ = ch
	      if ("s" in ev) S_ = ev["s"] else S_=0
	 	
	      eval(script)

	      if (C_ == ch)	# pas de changement de canal
	      {
	        ev["x"] = X_
	        ev["y"] = Y_
	        ev["nodur"] = N_	 
	        ev["s"] = S_    
              }
	      else if ((C_>= 1) && (C_<= NbCan))
	      {
	        modif_C = 1
		C_= Arrondi(C_)
		nn = (Ev[C_][0] += 1)
		Ev[C_][nn] = ArCopy(ev)
		Ev[C_][nn]["x"] = X_
		Ev[C_][nn]["y"] = Y_
		Ev[C_][nn]["nodur"] = N_	
	        Ev[C_][nn]["s"] = S_		

		Ev[ch] = SupprimeIndex(ne, Ev[ch])	
		Ev[ch][0] -= 1
	      }   
}



###########################################################################################
########			                       ####################################
######## Importation de fichiers MIDI et de phrases    ####################################
########  dans les Ev		                       ####################################
########			                       ####################################
###########################################################################################





function GetMIDIch(fnom, ch, dir) 
{
	if (nargs() == 2) dir=MDOP	# (dir optionnel)	

	return (onlynotes(cut(readmf(dir+fnom+".mid"), CUT_CHANNEL, ch)))
}


function Aligne(ph, a, b, ch)	# transpose la phrase sur un segment dans canal ch		
{
	ph = onlynotes(ph)
	ph.chan = 1		

	ech = pow(latest(ph),-1)
	ax = a["x"]
	lx = b["x"]-ax
	ay = a["y"]
	ly = b["y"]-ay
	

	n0 = Ev[ch][0]

	n = 1
	for (note in ph)
	{
		time = note.time
		Ev[ch][n0+n] = ["x" = ax + lx*time*ech]  
		Ev[ch][n0+n]["y"] = ay + ly*time*ech
		note.time = 0
		note.length = 1b
		Ev[ch][n0+n]["nodur"] = note
		Ev[ch][n0+n]["actif"] = 1
		
		n++
		if (n> sizeof(ph)) break
	}

	Ev[ch][0] += sizeof(ph)
}


function EnRond(ph, cen, ray, ch, theta0)       # transpose la phrase sur un cercle dans canal ch
{
	if (nargs()== 4) theta0 = 0		# (theta0 optionnel)

	ph = onlynotes(ph)
	ph.chan = 1		

	ech = (2*Pi)/latest(ph)
	cx = cen["x"]
	cy = cen["y"]

	n0 = Ev[ch][0]

	n = 1
	for (note in ph)
	{
		theta = note.time*ech

		np = Setpolar(ray, theta-theta0)
		
		Ev[ch][n0+n] = ["x" = cx + np["x"]]  
		Ev[ch][n0+n]["y"] = cy + np["y"]
		note.time = 0
		note.length = 1b
		Ev[ch][n0+n]["nodur"] = note
		Ev[ch][n0+n]["actif"] = 1
		
		n++
		if (n> sizeof(ph)) break
	}

	Ev[ch][0] += sizeof(ph)
}

