
function proj_infos() 
{

	 # paramètres:

ce = "Cr"	# cercle
pt = "Pt"	# point
ps = "Ps"	# piste
en = "In"	# integer
ft = "Ft"	# float
rg = "Rg"	# region
pj = "Pj"	# projecteur
la = "La"	# liste d'arguments


	 # champs:

nom = "nom"
d = "d"
t = "t"

	return([ 0= 13,
	
	1= [nom= "Ecoute", 0= 2,
		1= [d="A" , t= pt ], 
		2= [d="B" , t= pt ]],

	2= [nom= "EcouteC", 0= 3,
		1= [d="C" , t= ce ], 
		2= [d="A" , t= pt ],
		3= [d="nT" , t= en ]],

	3= [nom= "Spiro", 0= 7,
		1= [d="C" , t= ce ], 
		2= [d="r" , t= ft ],
		3= [d="s" , t= en ],
		4= [d="th0" , t= ft ],
		5= [d="dth" , t= ft ],
		6= [d="nC" , t= en ],
		7= [d="A" , t= pt ]],

	4= [nom= "Onde", 0= 5,
		1= [d="C1" , t= ce ], 
		2= [d="C2" , t= ce ],
		3= [d="nC" , t= en ],
		4= [d="s" , t= en ],
		5= [d="A" , t= pt ]],

	5= [nom= "Echelle", 0= 5,
		1= [d="A1" , t= pt ], 
		2= [d="A2" , t= pt ],
		3= [d="B1" , t= pt ],
		4= [d="B2" , t= pt ],
		5= [d="nb" , t= en ]],

	6= [nom= "Helice", 0= 5,
		1= [d="A" , t= pt ], 
		2= [d="r" , t= ft ],
		3= [d="th0" , t= ft ],
		4= [d="dth" , t= ft ],
		5= [d="nT" , t= en ]],

	7= [nom= "Brown", 0= 5,
		1= [d="A" , t= pt ], 
		2= [d="B" , t= pt ],
		3= [d="amp" , t= ft ],
		4= [d="dur" , t= ft ],
		5= [d="R" , t= rg ]],

	8= [nom= "AversB", 0= 4,
		1= [d="A" , t= pt ], 
		2= [d="B" , t= pt ],
		3= [d="len" , t= ft ],
		4= [d="ang" , t= ft ]],

	9= [nom= "Vague", 0= 4,
		1= [d="P1" , t= ps ], 
		2= [d="P2" , t= ps ],
		3= [d="len" , t= ft ],
		4= [d="ang" , t= ft ]],

	10= [nom= "CercleRythm", 0= 3,
		1= [d="A" , t= pt ], 
		2= [d="B" , t= pt ],
		3= [d="nS", t= en ]],

	11= [nom= "Scint", 0= 5,
		1= [d="A" , t= pt ], 
		2= [d="B" , t= pt ],
		3= [d="len" , t= ft ],
		4= [d="ang" , t= ft ],
		5= [d="nS", t= en ]],

	12= [nom= "MetaRails", 0= 4,
		1= [d="Pa" , t= ps ], 
		2= [d="Pb" , t= ps ],
		3= [d="Proj" , t= pj ],
		4= [d="Args" , t= la ]],

	13= [nom= "DiametreTournant", 0= 6,
		1= [d="C" , t= ce ], 
		2= [d="th0" , t= ft ],
		3= [d="dth" , t= ft ],
		4= [d="nT" , t= en ],
		5= [d="Proj" , t= pj ],
		6= [d="Args", t= la ]]
	
	 ])
}



#####################################  Projecteurs:
#
# après avoir défini un projo, compléter le tableau que retourne proj_infos() ci-dessus
# 
#######################################################################################

function Scint(a,b,long,ouvert,nS,...)	       # scintillement: nS fois AversB
{
	if (nargs()==5) {duree = 0} else {duree = argv(5)}	
	if (nargs()<7) {t0=0} else {t0=argv(6)}	
	if (nargs()<8) {region = Tout} else {region = argv(7)}	

	bars= NewLigne("Scint", t0)
	for (n=1; n<=nS; n++)
		bars = PlusInterLigne(bars, AversB(a,b,long,ouvert,duree,0,region))

	bars["paras"] = ["region" = region]

	return (bars)
}



function MetaRails(p1,p2,projecteur,...)  # devrait remplacer Vague, EntrePiste
{
	nb = Minimum(p1[0], p2[0])

	bars= NewLigne("MetaRails", t0)

	for (n=1; n<=nb; n++)
	{
		a = ["x"= p1[n]["x"], "y"= p1[n]["y"]]
		b = ["x"= p2[n]["x"], "y"= p2[n]["y"]]

		bars = PlusInterLigne(bars, efunction(projecteur)(a,b,...))
	}
	return (bars)
}

function DiametreTournant(cercle, theta0, deltath, nT, projecteur, ...)
{
	xc = cercle["c"]["x"]
	yc = cercle["c"]["y"]
	ray = cercle["r"]

	nb = integer(2*Pi*pow(deltath,-1))
	pa = [0= nb]
	pb = [0= nb]

	sens = Signe(nT)
	nT = Abs(nT)

	for (n=0; n<nb*nT; n++)		# calcul des pistes (plusieurs tours possibles)
	{
		theta = Mod2Pi(theta0 + sens*n*deltath)

		a = Setpolar(ray,theta)
		b = Setpolar(ray,Mod2Pi(theta + Pi))

		pa[n+1] = ["x" = xc + a["x"], "y" = yc + a["y"] ]
		pb[n+1] = ["x" = xc + b["x"], "y" = yc + b["y"] ]
	}

	ligne = MetaRails(pa,pb,projecteur,...)
	return(ligne)
}



