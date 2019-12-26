
###########################################################################################
########                                               ####################################
######## Catalogue de fonctions pour GéoMaestro        ####################################
########                                               ####################################
###########################################################################################

#############################################################################
## général (arrays):
##
##


function ArCopy(arr)		# permet de copier des arrays 
{
   if (typeof(arr) == "array")
   {
	brr = []
	
	for (i in arr)
	{
	    if (typeof(arr[i]) == "array")
	        brr[i] = ArCopy(arr[i])
	    else	   
		brr[i] = arr[i]
	}

	return (brr)
   }
   else
	return (arr)
}


function SupprimeIndex(ind,arr)  # supprime un index numérique (integer) 
				 # d'une série ordonnée SANS TROU
				 # en bouchant le trou et sans toucher au reste du tableau
{
	narr = []

	# gestion des indices entiers: 
	#  on supprime ind et on décale les suivants vers le bas

	if (0 in arr) idep = 0 else idep = 1
	lasti = idep
	while (lasti in arr) lasti +=1
	lasti -= 1				# dernière valeur entière de la liste

	for (i=idep; i<ind; i++)
	    narr[i] = ArCopy(arr[i])

	if (ind < lasti)
	   for ( i= ind+1; i <= lasti; i++)
	       narr[i-1] = ArCopy(arr[i])    


	# gestion des éventuels indices non entiers: 
	#  on les recopie tels quels

	for (ai in arr)
	   if (typeof(ai) != "integer") narr[ai] = ArCopy(arr[ai])

	return (narr)
}



#############################################################################
## général (strings):
##
##


function CoupeStr(str, arg2)	# arg2 integer ou string 
{
	len = sizeof(str)	
	if (typeof(arg2) == "string")
	{
		l2 = sizeof(arg2)
		if (substr(str,1,l2) == arg2)	n = 1
		else if (substr(str,Maximum(len-l2+1,1),l2) == arg2) n = len-l2+1
		else
		{
		   un = substr(arg2,1,1)
		   if (substr(str,1,1) == un) n = 1 else n = 0
		   ms = split(str,un)

		   if (!(1 in ms))
			return ([0= str])
		   else
		   {
			oui = 0
			n = n+sizeof(ms[0])+1
			for (i=1; (i<sizeof(ms)) && (oui==0); i++) 
			    if (un+substr(ms[i],1,l2-1) == arg2) 
			       {oui = 1; break}
			    else
			       n = sizeof(ms[i-1])+1

			if (oui==0) return  ([0= str])
		   }
		}
	}
	else n = arg2	

	if (n>1 && n<len)	   return( [0= substr(str,1,n-1), 1 = substr(str,n,len-n+1)] )
	else if (n==len)	   return ([0= substr(str,1,len-1), 1= substr(str,n,1)] )
	else if (n==1)		   return( [0= "", 1= str] )
}

function RemplaceInStr(sent, cha1, cha2)
{
	if (1 in CoupeStr(cha2,cha1))		# cas où cha1 est inclus dans cha2
	{
		sent = RemplaceInStr(sent, cha1, "£§µ")
		sent = RemplaceInStr(sent, "£§µ",cha2)
		return (sent)
	}

	lc1 = sizeof(cha1)
	fin = 0
	while (fin == 0)
	{
	  coupe = []
	  coupe = CoupeStr(sent,cha1)

	  if (1 in coupe) 
		sent = coupe[0]+cha2+substr(coupe[1],lc1+1,sizeof(sent)-lc1)
	  else fin=1
	}
	return (sent)
}


#############################################################################
## général (points):
##
##


function Setpolar(rr,ang)		# renvoie les coordonnées rectangulaires
{ 
  if (nargs() == 1)				# appel par (point) en polaires
     {rr = argv(0)["r"]; ang = argv(0)["theta"]}
  else { rr = argv(0) ; ang = argv(1) }		# appel par (rr,ang)

  a = ["x" = rr*cos(ang), "y" = rr*sin(ang)]
  return (a)
}


function Getpolar(...)			# renvoie les coordonnées polaires
{ 
  if (nargs() == 1)				# appel par (point) en rectangulaires
     {x = argv(0)["x"]; y = argv(0)["y"]}
  else { x = argv(0) ; y = argv(1) }		# appel par (x,y)

  a = ["r" = sqrt(x*x+y*y) ]
  if (a["r"] > 0)
  {
     if (y>=0) {a["theta"]= acos(x/a["r"])}
     else  {a["theta"] = 2*Pi-acos(x/a["r"])}            
  }
  else a["theta"] = 0
  return (a)
}



#############################################################################
## général (maths):
##
##


function Mod2Pi(angle)			# retourne angle modulo 2*Pi (exclu: 2Pi = 0)
{
	a = angle
	for (; a >= 2*Pi; a -= 2*Pi) {}
	for (; a < 0; a += 2*Pi) {}   
		
	return (a)
}
 


function Hexa(n)    	# retourne le nombre n (entre 0 et 255) en hexadecimal, format string
{
 	h1= integer(n/16.0)
	h2= n-16*h1

	return (Hexa16(h1)+Hexa16(h2))
} 

function Hexa16(n)    	# retourne le nombre n (entre 0 et 15) en hexadecimal, format string
{
	if (n < 10) return (ascii(n+48)) 
	else return (ascii(n+87))
} 



function Arrondi(x)
{
	if (x>=0)
	{	
		if (x-integer(x) > 0.5)
		   return (integer(x)+1)
		else
		   return (integer(x))
	}
	else
	{	
		if (integer(x)-x > 0.5)
		   return (integer(x)-1)
		else
		   return (integer(x))
	}
}


function EnvironEgal(x,y)
{
	return (Abs(x-y) < 0.001)
}



function Signe(x)
{
	if (x >= 0) {return (1)}
	else {return (-1)}
}


function Abs(x)
{	 return (x*Signe(x)) }


function Id(h,...) { return (h)}	# Identité: retourne le premier argument


function Minimum(a,b)
	 {if (a < b) {return (a)} else {return (b)}}


function Maximum(a,b)
	 {if (a < b) {return (b)} else {return (a)}}


function Dist(a, b)			# Distance entre deux points
{	return (sqrt(pow(a["x"]-b["x"],2)+pow(a["y"]-b["y"],2)))  }

function Thet(a,b)		        # Angle du vecteur (AB) avec l'axe Ox
{
	return (Getpolar(b["x"]-a["x"], b["y"]-a["y"])["theta"])
}

function Peri(cer)	                # Périmètre d'un cercle
{	return (2*Pi*cer["r"])		}





###########################################################################################
########			                       ####################################
######## Fonctions d'activation			       ####################################
########			                       ####################################
###########################################################################################


function ActiveCanal(ch)
{
	for (ne=1 ; ne<=Ev[ch][0] ; ne++)			
	{ Ev[ch][ne]["actif"] = 1 }

	return (ne)
}


function DesactiveCanal(ch)
{
	for (ne=1 ; ne<=Ev[ch][0] ; ne++)			
	{ Ev[ch][ne]["actif"] = 0 ; Ev[ch][ne]["s"] = 0 } 

	return (ne)
}


function ActiveTout()
{
	for (ch=1 ; ch <= NbCan; ch++)
	for (ne=1 ; ne<=Ev[ch][0] ; ne++)			
	{ Ev[ch][ne]["actif"] = 1 }

	return (ne)
}


function DesactiveTout()
{
	for (ch=1 ; ch <= NbCan; ch++)
	for (ne=1 ; ne<=Ev[ch][0] ; ne++)			
	{ Ev[ch][ne]["actif"] = 0 ; Ev[ch][ne]["s"] = 0 } 

	return (ne)
}


function ActiveRegion(reg)
{
	for (ch=1; ch <= NbCan; ch++)
	for (ne=1 ; ne<=Ev[ch][0] ; ne++)			
	{
	   x = Ev[ch][ne]["x"]
	   y = Ev[ch][ne]["y"]
	   
	   if (Region(x,y,ch,reg)) 
	      Ev[ch][ne]["actif"] = 1
	}
}

function DesactiveRegion(reg)
{
	for (ch=1; ch <= NbCan; ch++)
	for (ne=1 ; ne<=Ev[ch][0] ; ne++)			
	{
	   x = Ev[ch][ne]["x"]
	   y = Ev[ch][ne]["y"]
	   
	   if (Region(x,y,ch,reg))
	      { Ev[ch][ne]["actif"] = 0 ; Ev[ch][ne]["s"] = 0 } 
	}
}


function ActiveTest(test)  # test sur X,Y,N,C,S
{
	test = GereHistory(test, FIF)

	for (ch=1; ch <= NbCan; ch++)
	for (ne=1 ; ne<=Ev[ch][0] ; ne++)			
	{
	   X_ = Ev[ch][ne]["x"]
	   Y_ = Ev[ch][ne]["y"]
	   N_ = Ev[ch][ne]["nodur"]
	   S_ = Ev[ch][ne]["s"]
	   A_ = Ev[ch][ne]["actif"]
	   P_ = Ev[ch][ne]["script"]
	   L_ = Ev[ch][ne]["label"]
	   C_ = ch
	   
	   eval("T__ = ("+test+")")
	   if (T__)
	       Ev[ch][ne]["actif"] = 1
	}
}

function DesactiveTest(test)  # test sur X,Y,N,C,S
{
	test = GereHistory(test, FIF)

	for (ch=1; ch <= NbCan; ch++)
	for (ne=1 ; ne<=Ev[ch][0] ; ne++)			
	{
	   X_ = Ev[ch][ne]["x"]
	   Y_ = Ev[ch][ne]["y"]
	   N_ = Ev[ch][ne]["nodur"]
	   S_ = Ev[ch][ne]["s"]
	   A_ = Ev[ch][ne]["actif"]
	   P_ = Ev[ch][ne]["script"]
	   L_ = Ev[ch][ne]["label"]
	   C_ = ch
	   
	   eval("T__ = ("+test+")")
	   if (T__)
	     { Ev[ch][ne]["actif"] = 0 ; Ev[ch][ne]["s"] = 0 } 
	}
}




###########################################################################################
########                                               ####################################
######## Gestion des History: fonctions avancées       ####################################
########                                               ####################################
###########################################################################################


function GereHistory(str, hist) 
{
    if (substr(split(str," ")[0],1,1) == ":")		# mode indirect
    { 
       if (split(str," ")[0] == "::")			# rappel du dernier
	  str = hist[sizeof(hist)]
       else
       {
	 str = split("bof"+str,":")[1]
	 if (typeof(integer(str))=="integer")		# rappel d'un index
	     str = hist[integer(str)]
	 else						# évaluation d'une variable
	 {
	   eval("T__ = defined("+split(str, "[")[0]+")")
	   if (T__ == 0) return (-1)

	   RemVAR(split(str, "[")[0])			# et hop! dans GVARS

	   eval("G__ = string("+str+")") 
	   str = G__ 
         }
       }    
    }

	if (sizeof(split(str,"\"")) == 1)	# Pas de stockage si des "" sont présents, 
										#  car restore() ne pourrait pas les gérer.
	{
      t = 0
      if (shist = sizeof(hist)) 
       for (i=1; i<= shist; i++) 
	   if (str == hist[i])
	      { t = 1; oldplace = i } 

      if (!t || shist==0) hist[shist+1] = str
      else
       { hist[oldplace] = hist[shist] ; hist[shist] = str }
	}

    return (str)
}


