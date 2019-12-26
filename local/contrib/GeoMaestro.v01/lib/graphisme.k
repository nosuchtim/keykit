

###########################################################################################
########						   ################################
######## Graphisme (GNUplot)				   ################################
########						   ################################
###########################################################################################

# format d'une liste de plots:
#
# liste["xmax"]	
#      ["xmin"]
#      ["ymax"]
#      ["ymin"]		... intervalles d'affichage

# liste["fnom"]		nom complet (en.dat) du fichier de données
# liste[0]		nbe d'items 
# liste[n][0]		nbe de lignes de commandes de l'item n
#			(pour des segments, une par couple de points)
# liste[n][nl]		ligne de commande (partielle: voir GnuPlot() ) 
#			(format: "points@..." ou "lines@..." ou "[..:..]@..."
#			     ex: "points@using 1:2 "
#			         "lines@using 2:3 "
#			         "[0:2*pi]@ cos(t), sin(t)"    )
# liste[n]["leg"]	legende de l'item n
#

function InitList(fnom, ...)	# fnom: nom (racine) du fichier .dat associé
				# si (...) présent, l'ancien fichier s'il existe est écrasé
{
	if (nargs() == 2) 
	{ 
		f=open((nom = DEFDIR+fnom+".dat"), "w") 
		close(f) 
	}
	else nom = FichierN(fnom+".dat")

	return ([0=0, "fnom"= nom, "xmin"=0, "xmax"=0, "ymin"=0, "ymax"=0])
}



function ListColl(liste, coll, ...)	# ajoute collection à liste
{
	if (nargs() == 2) leg = coll["nom"] else leg = argv(2)
	n = (liste [0] += 1)

	liste[n]=[0 = 1]
	liste[n][1] = "points@using 1:2 "
	liste[n]["leg"] = leg



	f = open(liste["fnom"], "a")
	put(f, "\n\n")

	for (np = 1; np <= coll[0]; np++)
	{
		InBornes(liste, x = coll[np]["x"], y = coll[np]["y"])
		put(f, string(x)+" "+string(y)+"\n")  
	}
	close(f)
}



function ListScEv(liste, sev, ...)	# ajoute scène/Ev à liste
{
    if (nargs() == 2) leg = "c" else leg = argv(2)

    for (c = 1; c<= NbCan; c++) if (sev[c][0])
    {
	n = (liste [0] += 1)

	liste[n]=[0 = 1]
	liste[n][1] = "points@using 1:2 "
	liste[n]["leg"] = leg+string(c)

	f = open(liste["fnom"], "a")
	put(f, "\n\n")

	for (np = 1; np <= sev[c][0]; np++)
	{
		InBornes(liste, x = sev[c][np]["x"], y = sev[c][np]["y"])
		put(f, string(x)+" "+string(y)+"\n") 
	}   
	close(f)
    }

}



function ListGen(liste, gen, leg)	# ajoute une description issue d'un générateur
					# (in champs "inter" de la ligne résultat)
{
    f = open(liste["fnom"], "a")

    genid= gen["id"]	# identification du générateur


    if (genid == "Ecoute")
    {
       n = (liste[0] += 1)
       liste[n] = [0 = 1, "leg"= leg]

       liste[n][1] = "lines@using 1:2"
       a = gen["rac"]["A"]
       b = gen["rac"]["B"]	
       InBornes(liste, a["x"],a["y"]); InBornes(liste, b["x"],b["y"])
       put(f, "\n\n")
       put(f, string(a["x"])+" "+string(a["y"])+"\n") 
       put(f, string(b["x"])+" "+string(b["y"])+"\n") 
       
    }
    else if (genid == "EcouteC")
    {
       n = (liste[0] += 1)
       liste[n] = [0 = 1, "leg"= leg]

       rr = string(r = gen["rac"]["cer"]["r"])
       xx = "("+string(x = gen["rac"]["cer"]["c"]["x"])+")"
       yy = "("+string(y = gen["rac"]["cer"]["c"]["y"])+")"
       InBornes(liste, x+r, y+r); InBornes(liste, x-r, y-r)
       liste[n][1] = "[0:2*pi]@"+rr+"*cos(t)+"+xx+","+rr+"*sin(t)+"+yy+" "
           
    }
    else if ( (genid == "Spiro") || (genid == "Onde") )
    {
       n = (liste[0] += 1)
       liste[n] = [0 = gen["inter"][0], "leg"= leg]
       for (nl = 1; nl <= gen["inter"][0]; nl++)
       {
		rr = string(r = gen["inter"][nl]["cer"]["r"])
		xx = "("+string(x = gen["inter"][nl]["cer"]["c"]["x"])+")"
		yy = "("+string(y = gen["inter"][nl]["cer"]["c"]["y"])+")"
		InBornes(liste, x+r, y+r); InBornes(liste, x-r, y-r)
		liste[n][nl] = "[0:2*pi]@"+rr+"*cos(t)+"+xx+","+rr+"*sin(t)+"+yy+" "
       }		
    }

    else if ((genid=="Echelle")||(genid=="AversB")||(genid=="Brown")||(genid=="Helice")||(genid=="EntrePistes")||(genid=="CercleRythm")) 
    {
       n = (liste[0] += 1)
       liste[n] = [0 = gen["inter"][0], "leg"= leg]
       for (nl = 1; nl <= gen["inter"][0]; nl++)
       {
		liste[n][nl] = "lines@using 1:2"
		a = gen["inter"][nl]["A"]
		b = gen["inter"][nl]["B"]	
		InBornes(liste, a["x"],a["y"]); InBornes(liste, b["x"],b["y"])
		put(f, "\n\n")
		put(f, string(a["x"])+" "+string(a["y"])+"\n") 
		put(f, string(b["x"])+" "+string(b["y"])+"\n") 
       }	
    }

    else if (genid=="Vague")
    {
       n = (liste[0] += 1)
       liste[n] = [0 = gen["inter"][0], "leg"= leg]
       for (nl = 1; nl <= gen["inter"][0]; nl++)
       {
	   liste[n][nl] = "lines@using 1:2"
	   put(f, "\n\n")
           for (nl2 = 1; nl2 <= gen["inter"][nl][0]; nl2++)
	   {
		a = gen["inter"][nl][nl2]["A"]
		b = gen["inter"][nl][nl2]["B"]	
		InBornes(liste, a["x"],a["y"]); InBornes(liste, b["x"],b["y"])
		put(f, string(a["x"])+" "+string(a["y"])+"\n") 
		put(f, string(b["x"])+" "+string(b["y"])+"\n") 
	   }
       }	
    }

    close(f)
}



function ListGeo(liste, fnom)		# ajoute un fichier Geo() à liste
{
	Geo(fnom, liste)
}

function ListAjout(liste, ajout)	# ajoute la liste "ajout" à liste
{
	for (q = 1; q <= ajout[0]; q++)
	{
	   n = (liste[0] += 1)
	   liste[n] = [0= 1, 1= ajout[q][1], "leg"= ajout[q]["leg"]]
	}

	InBornes(liste, ajout["xmax"], ajout["ymax"])
	InBornes(liste, ajout["xmin"], ajout["ymin"])

	f = open(liste["fnom"], "a")
	fa = open(ajout["fnom"])

	while ((ligne = get(fa)) != Eof)
	   put(f, ligne)
	
	close(fa)
	close(f)
}


function ListSeg(liste, a, b, ...)		# ajoute le segment (a,b) à liste
{
	if (nargs() == 3) leg= "(-)" else leg= argv(3)

	f = open(liste["fnom"], "a")
	put(f, "\n\n")
	put(f, string(a["x"])+" "+string(a["y"])+"\n") 
	put(f, string(b["x"])+" "+string(b["y"])+"\n") 

	InBornes(liste, a["x"], a["y"])
	InBornes(liste, b["x"], b["y"])

	n = (liste[0] += 1)
	liste[n]= [0= 1, 1= "lines@using 1:2 ", "leg"= leg]
	close(f)
}



function ListCer(liste, c, r, ...)		# ajoute le cercle (c,r) à liste
{
	if (nargs() == 3) leg= "(o)" else leg= argv(3)

	x = "("+string(c["x"])+")"
	y = "("+string(c["y"])+")"

	InBornes(liste, c["x"]+r, c["y"]+r); InBornes(liste, c["x"]-r, c["y"]-r)

	r = string(r)

	n = (liste[0] += 1)
	liste[n]= [0= 1, 1="[0:2*pi]@"+r+"*sin(t)+"+x+","+r+"*cos(t)+"+y+" ", "leg"= leg]
}



function ListPiste(liste, piste, ...)	# ajoute piste à liste
{
	if (nargs() == 2) leg= "(..)" else leg= argv(2)

	f = open(liste["fnom"], "a")
	put(f, "\n\n")

	for (p = 1; p <= piste[0]; p++)
	{
	   put(f, string(piste[p]["x"])+" "+string(piste[p]["y"])+"\n")
	   InBornes(liste, piste[p]["x"], piste[p]["y"])
	}
	
	close(f)
	n = (liste[0] += 1)
	liste[n]= [0= 1, 1= "lines@using 1:2 ", "leg"= leg]
}


function InBornes(liste, x, y)		# mise à jour des intervalles
{
if (y>100) Bprint(">>>>>>> ",x,y)
	liste["xmax"] = Maximum(liste["xmax"], x)
	liste["xmin"] = Minimum(liste["xmin"], x)
	liste["ymax"] = Maximum(liste["ymax"], y)
	liste["ymin"] = Minimum(liste["ymin"], y)
}


function GnuPlot(liste, fnom,...)	# exporte les commandes Gnuplot
{							
	f = open(DATA+fnom+".gp","w") 
	Bprint(GMblah_gnuplot0+DATA+fnom+".gp") 

	noleg = 0
	xmin = liste["xmin"]-1
	xmax = liste["xmax"]+1
	ymin = liste["ymin"]-1
        ymax = liste["ymax"]+1

	if (nargs() == 3)	       
	{
	   if (typeof(argv(2)) == "array")	# (définition des intervalles))
	   {
		bo = argv(2)
		xmin = bo["x0"]
		xmax = bo["x1"]
		ymin = bo["y0"]
		ymax = bo["y1"]
	   }
	   else noleg = 1			# (pas de légende)
	}
	if (nargs() == 4) noleg = 1		# (id)

	xrange = "["+string(xmin)+":"+string(xmax)+"]" 
	yrange = "["+string(ymin)+":"+string(ymax)+"]"

	df = split(liste["fnom"],"/")
	datafnom = df[sizeof(df)-1]  	
	datadir = ""
	for (i = 0; i < sizeof(df)-1; i++) datadir = datadir+df[i]+"/"
	Bprint(GMblah_gnuplot1+datadir+datafnom)

	put(f, "cd '"+datadir+"'\n")
	put(f, "set multiplot\n")
	put(f, "set key spacing 0.5\n")
	put(f, "set size ratio -1\n")
	put(f, "set zeroaxis\n")
	put(f, "set key outside\n")
	put(f, "set pointsize 1\n")
	put(f, "set parametric\n")
	put(f, "set xrange "+xrange+"\n")
	put(f, "set yrange "+yrange+"\n")
	put(f, "set xtics 1\n")
	put(f, "set ytics 1\n")
	put(f, "set grid \n")

	index = 0
	dec = decpa = ""			# décalage pour couleurs !
	for (n = 1; n <= liste[0]; n++)
	{
	   if (noleg)
	      titre = " notitle"
	   else
	      titre = " title \""+liste[n]["leg"]+"__\"" 

	   for (nl = 1; nl <= liste[n][0]; nl++)
	   {
	      if (nl > 1) titre = " notitle"

	      li = split(liste[n][nl], "@")
	      comm = " "+li[1]+titre

	      if (li[0] == "points")
	      {
		 put(f, "\nset noparametric\n")
		 put(f, "set data style points\n")
		 put(f, "plot "+dec+"'"+datafnom+"' index "+string(index)+comm+"\n")   
		 index += 1
	      }

	      else if (li[0] == "lines")
	      {
		 put(f, "\nset noparametric\n")
		 put(f, "set data style lines\n")
		 put(f, "plot "+dec+"'"+datafnom+"' index "+string(index)+comm+"\n")   
		 index += 1
	      }

	      else	# paramétrique, li[0] est alors l'intervalle parcouru par t
	      {
		 put(f, "\nset parametric\n")
		 put(f, "plot " + li[0] + decpa + comm+"\n")
	      }
	      
	      if ((n == 1)&&(nl == 1))	# on ne fait ça qu'une fois...
	         put(f, "\nset nogrid \nset nozeroaxis\n")
	   }
	   dec = dec + "0 0,"
	   decpa = decpa + "0,0 not,"

	}
	
	put(f, "\nset nomultiplot\n")
	put(f,"pause -1")		# à activer si WGnuplot n'a pas l'option -noend

	close(f) 
}




