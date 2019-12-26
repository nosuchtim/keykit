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
########			                       ####################################
######## Petites fonctions pratiques pour la console   ####################################
########			                       ####################################
###########################################################################################


function EvPAC(ch, lsb, p)
{
	return( Ev[ch]["PAC"] = PourAC(lsb, p, ch))
}


function PlusP(a, b)		# addition vectorielle de deux points
{
	return(["x"= a["x"]+b["x"], "y"=a["y"]+b["y"]])
}

function Milieu(a,b)		# milieu du segment (a,b)
{
	return(["x"= 0.5*(a["x"]+b["x"]), "y"=0.5*(a["y"]+b["y"])])
}

function xyd(x,y,x1,y1)	# Attention ! le xy() de Keykit arrondi les arguments ! pas celui-ci..
{
	if (nargs() == 2)
	   return (["x"= x, "y"= y])
	else if (nargs() == 4)
	   return (["x0"= x, "y0"= y, "x1"= x1, "y1"= y1])
}

function Cerc(c, r)		# définition d'un cercle
{
	return ([Cs=[Xs= c["x"], Ys= c["y"]], Rs=r])
}

function Seg(a,b,x,y)	# définition d'un segment par deux points ou quatre coordonnées
{
	if (nargs() == 2)
	   return (xyd(a["x"],a["y"],b["x"],b["y"]))
	else if (nargs() == 4)
	   return (xyd(a,b,x,y))
}	  
function SegA(s)
{
	return (["x"= s["x0"], "y"= s["y0"]])
}
function SegB(s)
{
	return (["x"= s["x1"], "y"= s["y1"]])
}

function Snarph(arg1, arg2)		# pas d'argument: 
					#     ...liste les phrases stockées
					# arg1 = ligne ou phrase, {arg2 = commentaire }
					#     ...stocke
					# arg1 = integer, pas de arg2
					#     ...retourne la phrase numero arg1
					# arg1 < 0, arg2 < arg1
					#     ...supprime les phrases no -arg1 à - arg2	
{
    if (nargs() == 0)
    {
	Arraysort = 1
	for (i in SNARF)
	{
	    print ("---- ph "+string(i)+" ---- "+SNARF[i]["blah"])
	    print (" "+string(SNARF[i]["ph"]))
	}
	Arraysort = 0
    }

    else if ((typeof(arg1)=="integer") && (arg1 < 0))	
    {
	if (nargs() == 1) arg2 = arg1
	index = -arg1
	ni = -arg2-index+1
	for (i = 1; i<= ni; i++) if (index in SNARF) SNARF = SupprimeIndex(index, SNARF)
    }

    else if ((nargs() == 1) && (typeof(arg1)=="integer"))	# retourne la phrase
    {
	if (arg1 in SNARF)
	{
		Bprint(SNARF[arg1]["blah"])
		return(SNARF[arg1]["ph"])
	}
    }

    else
    {
	if (typeof(arg1)=="phrase") Snarf = arg1
	else Snarf = arg1["ph"]

	test = 0
	if (sft = sizeof(SNARF)) for (i=1; (i<= sft)&&(test==0); i++) 
	   test = (Snarf == SNARF[i]["ph"])
	if (!test) 
	{
		SNARF[sft+1] = ["ph" = Snarf]
		if (nargs() == 2)
		   SNARF[sft+1]["blah"] = arg2
	Bprint("Snarf Snarf "+string(sft+1)+" !!")
	}
	else if (i-1 != sft)
	{
		ts = ArCopy(SNARF[i-1])
		SNARF[i-1] = ArCopy(SNARF[sft])
		SNARF[sft] = ArCopy(ts)
	}
	return(arg1)
    }
}



function Sgeo(...)	# sauvegarde les points ou cercles données en arguments dans init.geo
			# arguments par couples: "nom", variable
			# (autre approche: RemVAR() et HardCodeVAR(), voir plus bas... )
{
	f = open(BASE+"init.geo", "a")

	put(f,"\n\n\n"+GEOCOMMENT+"\n")

	for (n=0; n<nargs(); n += 2)
	{
		nom = argv(n)
		gem = argv(n+1)
		if (("x" in gem) && (typeof(nom)== "string"))		# point
		{
			put(f, "#points\n")
			put(f, nom+" "+string(gem["x"])+" "+string(gem["y"])+"\n")
			put(f, "#fin\n")
		}
		else if (("c" in gem) && (typeof(nom)== "string"))	# cercle
		{
			put(f, "#cercles\n")
			put(f, nom+" "+string(gem["c"]["x"])+" "+string(gem["c"]["y"])+" "+string(gem["r"])+"\n")
			put(f, "#fin\n")
		}
	}
	close(f)
}




###### Histories : FT et FKK          


function FT_(...)  # supprime les items en argument
{
	n = 1
	newFT=[]

	arn = 0
	for (i=1; i<= sizeof(FT); i++)
	{
		if ((argv(arn) != i) || (arn > nargs())) { newFT[n] = FT[i]; n++}
		else arn += 1
	} 

	FT = newFT
}


function FKK_(...)  # supprime les items en argument
{
	n = 1
	newFKK=[]

	arn = 0
	for (i=1; i<= sizeof(FKK); i++)
	{
		if ((argv(arn) != i) || (arn > nargs())) { newFKK[n] = FKK[i]; n++}
		else arn += 1
	} 

	FKK = newFKK
}


function SNARF_(...)  # supprime les items en argument
{
	n = 1
	newSNF=[]

	arn = 0
	for (i=1; i<= sizeof(SNARF); i++)
	{
		if ((argv(arn) != i) || (arn > nargs())) { newSNF[n] = SNARF[i]; n++}
		else arn += 1
	} 

	SNARF = newSNF
}



############# gestion du LOG

function HLog(...)	# format, ex: HLog("1-15",18,22,"35-41")
{
	nar = nargs()
	i = sizeof(LOG)+1

	for (arn = 0; arn < nar; arn++)
	{
		arg = argv(arn)
		if (typeof(arg) == "integer")
		{
			LOG[i] = Hist[arg]
			i++
		}
		if (typeof(arg) == "string")
		{
			lim = split(arg,"-")
			for (n = integer(lim[0]); n <= integer(lim[1]); n++)
			{
				LOG[i] = Hist[n]
				i++
			}
		}
	}
}



function EvaLog(deb, fin)
{
	if (nargs()< 1) deb = 1 
	if (nargs()< 2) fin = sizeof(LOG)

	for (n=deb; n<= fin; n++)
	{
	    print(">>> "+(cmd = LOG[n]))	    
	    if (substr(cmd,1,1) == ":")
	       cmd = "print("+substr(cmd,2)+")"   
	    if (split(cmd, " ")[0]=="print")
	       cmd = "print("+substr(cmd,6)+")"

	    eval(cmd)
	}
}




function ExLog(foncn, filen)
{
	if (nargs()< 2) filen = BASE + "log.k" 
	if (nargs()< 2) foncn = "LastLog"

	f = open(filen, "a")

	put(f, "\n\n\nfunction "+foncn+"()\n{\n")

	for (n=1; n<= sizeof(LOG); n++)
	{
	    cmd = LOG[n]	    
	    if (substr(cmd,1,1) == ":")
	       cmd = "print("+substr(cmd,2)+")"   
	    if (split(cmd, " ")[0]=="print")
	       cmd = "print("+substr(cmd,6)+")"

	    put(f, "    "+cmd+"\n")
	}
	put(f,"}\n")
	close(f)
}


function DumpChantier(fnom) 
{
	if (nargs() == 0) fnom = BASE+"variables.dat"

	f = open(fnom, "w")
	
	put(f, LOG)
	put(f, "\n")    
	put(f, FT) 
	put(f, "\n") 
	put(f, FKK) 
	put(f, "\n") 
	put(f, SNARF) 
	put(f, "\n") 
	put(f, GVARS)
	put(f, "\n")  
	put(f, FIF)
	put(f, "\n")  

	close(f)
}

function RestoreChantier(fnom)
{
	if (nargs() == 0) fnom = BASE+"variables.dat"
	if (!fileexists(fnom)) return (-1)

	f = open(fnom)

	eval("LOG="+get(f))
	eval("FT="+get(f))
	eval("FKK="+get(f))
	eval("SNARF="+get(f))
	eval("GVARS="+get(f))
	ReVAR()
	eval("FIF="+get(f))

	close(f)
}


function RemVAR(listvar) 
{
	 warning = ""	 

	 vars = split(string(listvar),",")
	 for (i=0; i<sizeof(vars); i++)
	 {
		#test: commence par une majuscule
		initiale = substr(split(vars[i]," ")[0],1,1)
		if ((initiale >="A") && (initiale <="Z"))
		{
		  eval("T__= defined("+(vars[i]=split(vars[i],"[-+/*()].")[0])+")")
		  if (T__) eval("G__= (typeof("+vars[i]+") != "+"\""+"function"+"\""+")") 
		  if ((T__ == 1) && (G__ == 1))
		  {
		    eval("T__="+vars[i])
		    if ((typeof(T__)!="string") || (sizeof(split(T__,"\"")) == 1)) # pas de " interne
		    {
	              if (!(vars[i] in GVARS)) print(GMblah_GUI76,vars[i])
		      GVARS[vars[i]] = T__
		    }
		    else
		      print(GMblah_cons1+vars[i]+GMblah_cons2)
		  }
		  if (T__ == 0) warning = warning+vars[i]+" "
		}
	 }
	 return (warning)
}

function ReVAR()	# rétablit les valeurs des VAR d'après le contenu de GVARS 
{
	for (v in GVARS) 
	{
		if (typeof(GVARS[v]) == "string") val = "\""+GVARS[v]+"\""
		else val = GVARS[v]
		eval(v+"="+string(val))
	}
}

function UpdateVAR()	# l'opération inverse !  
{
	for (v in GVARS) RemVAR(v)
}

function HardCodeVAR(fnom, dir)		# crée la fonction fnom dans userlib/fnom.k
{
	 if (nargs() == 0) 
	 {
		fnom = "InitVAR"	# voir InitStatique() dans initialisations.k
		dir = BASE
	 }
	 if (nargs() == 1) dir = COMPOS

	 nomcomplet = dir+fnom+".k"
	 f = open(nomcomplet,"w")
	 put(f, "# généré par HardCodeVAR()\n\n")
	 put(f, "function "+fnom+"()\n")
	 put(f,"{\n")
	 for (v in GVARS)	
	 { 
		lico = "   "+string(v)+" = "+string(GVARS[v])+"\n"
		put(f,lico)
	 }
	 put(f,"}\n")
	 close(f)
}

###########################################################################################
########			                       ####################################
######## Notepad() et Padnote()                        ####################################
########			                       ####################################
###########################################################################################


function Notepad(tableau, nomf)		# pour l'édition manuelle d'un tableau de données
{
	if (nargs() == 1) nomf = TEMPFILE
	f = open(nomf, "w")

	tmp = Arraysort
	Arraysort = 1	

	specialtab = ["-->" = tableau]

	put(f, GMblah_NP1)
	put(f, GMblah_NP2)
	put(f, GMblah_NP3)
	put(f, "##------->\n")

	RecursifEtalage(specialtab, 0, f, 0)

	put(f, "##\n")	
	put(f, GMblah_NP4)	
	put(f, GMblah_NP5)
	put(f, "|\n")
	put(f, GMblah_NP6)	
	put(f, GMblah_NP7)		

	close(f)

	Arraysort = tmp

	system(NOTEPAD1+nomf+NOTEPAD2)
}
function RecursifEtalage(tab, indent, f, niveau)
{
	for (index in tab)
	{
	    typ = typeof(tab[index])
	    ilong = sizeof(CorStr(index))+2	    	

	    if (typ == "array")
	    {
	       put(f, "a"+string(niveau)+" ")
	       if (indent) for (n = 1; n<= indent; n++) put(f, " ")	
	       put(f, "["+CorStr(index)+"]\n")
	       RecursifEtalage(tab[index], indent+ilong, f, niveau+1)
            }
	    else
	    {
	        put(f, substr(typ, 1,1)+string(niveau)+" ")
		if (indent) for (n = 1; n<= indent; n++) put(f, " ")	
		put(f, "["+CorStr(index)+"]  ")
	        put(f,tab[index]) 
		put(f,"\n")
	    }
	} 
}
function CorStr(index)
{
	if (typeof(index) == "string")
	   return ("\""+index+"\"")
	else
	   return (string(index))
}


function Padnote(nomf)		# pour la récupération du sus-dit tableau édité manuellement
{
	if (nargs() == 0) nomf = TEMPFILE	
	f = open(nomf)
	
	get(f); get(f); get(f); get(f)

	index = ResType(split(split(get(f), "[")[1],"]")[0])		

	slurp = RecRecon(index, f, 0)

	close(f)

	return (slurp[1]["-->"])
}
function ResType(index)
{
	char = substr(index, 1, 1)

	if (char == "\"") return (substr(index, 2, sizeof(index)-2))
	else if (char == "'") return (phrase(index))
	else if (index == string(integer(index))) return (integer(index))
	else return (float(index))
}
function RecRecon(idep, f, niveau)
{
	typ = lu = ""
	tableau = [(icour = idep)= []]

	while (1)
	{
	   if (lu != "") li = lu else li = get(f)
	   lu = ""

	   if (substr(li,1,1) == "#") return ([0= li, 1= tableau])	

	   typ = substr(li,1,1)
	   niv = integer(substr(li,2,1))	

	   iv = split(split(li, "[")[1],"]")	
	   index = ResType(iv[0])

	   posval = sizeof(split(li, "]")[0])+4
	   strval = substr(li,posval,sizeof(li)-posval+1)	

	   if (typ == "a")
	   {
		if (niv < niveau) 
		   return ([0= li, 1= tableau])

		else if (niv == niveau) 
		{
		     icour = index
		     tableau[icour] = []
		}		     

		else if (niv > niveau)
		{
		     retour = RecRecon(index,f,niv)
		     lu = retour[0]

		     for (ir in retour[1])
		        tableau[icour][ir] = retour[1][ir]
		}
	   }

	   else if (niv == niveau)
		   return ([0= li, 1= tableau])

	   else if (typ == "s")
	 	tableau[icour][index] = strval
		
	   else if (typ == "f")
	 	tableau[icour][index] = float(strval)

	   else if (typ == "i")
	 	tableau[icour][index] = integer(strval)

	   else if (typ == "p")
	 	tableau[icour][index] = phrase(strval)	
	}
}
