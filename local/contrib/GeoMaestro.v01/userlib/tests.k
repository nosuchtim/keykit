

# Compositions GeoMaestro:
#
#  si des éléments géométriques sont définis dans un fichier externe,
#     commencer par un Geo(nom-de-fichier)
#     (le fichier doit être en .txt dans le répertoire /compos)
#
#  Geo("base") est automatiquement effectué à l'initialisation
#


function TPB()	# test du Pitch Bend (pas concluant...)
{
	Geo("Percus")
	LoadEv("Maillages")

	Z1C = ["x"= -5, "y"= -5]
	ZA1 = ["x"= -6.5, "y"= -5]
	ZB1 = ["x"= -3.5, "y"= -5]
	Zone1 = RDisque(Z1C, 2)

	Pit[3] = BasicPitch
	PB[3] = NoBend
	
	ExMIDI(B1 = Brown(ZA1, ZB1, 0.5, seconds(1)*30, 0, 0, Zone1), "B1")


	Pit[3] = BasicPitch
	PB[3] = PetitDoppler
	
	ExMIDI(B2 = Brown(ZA1, ZB1, 0.5, seconds(1)*30, 0, 0, Zone1), "B2")


	Pit[3] = DopplerLateral
	PB[3] = NoBend
	
	ExMIDI(B3 = Brown(ZA1, ZB1, 0.5, seconds(1)*30, 0, 0, Zone1), "B3")

}



function TMini() # test des maillages: initialisation
{
	Geo("Percus")

	Anneau = RegionET(RDisque(Or, 3, EnMoinsDe), RDisque(Or, 5) )

	Tamis = Maillage(MHexa(0.5,0), 4, 0, Anneau, 4)
	RandomNotes(Tamis, 40, 70, 96, 192, 40, 80)

	CExport(Tamis, "Tamis")

	Grille = Maillage(MRect(0.6,0.8,0.2*Pi), -5, -7, RDisque(Loin, 3), 17)
	Arti = ReadPatches("Arti")
	DansChoix(Grille, Arti, 2, 50)

	CExport(Grille, "Grille")

	ChoixScene(CreScen(Tamis, Grille))

	Ev[4]["PAC"] = Contrabass(4)

	EvPlot("Maillages")
	WriteEv("Maillages")

}
function TM()  # Test des maillages: musique !
{	
	LoadEv("Maillages")


	Heli2 = Helice(Or, 5, 0, 0.02*Pi, 1, 0)
	ExMIDI(Heli2, "champs")

	Geo("Percus")


	ExMIDI(Vers45 = AversB(CC,DD,0.5,Pi/4, 0), "brisee45")
	ExMIDI(Vers90 = AversB(CC,DD,0.5,Pi/2, 0), "brisee90")
	ExMIDI(Vers180 = AversB(CC,DD,0.5,Pi, 0), "brisee180")

}



function Percus()
{
	Geo("Percus")		# i.e. "Percus.txt" dans /compo

	LoadEv("Percus")	# i.e. "Percus.ev" dans /Data

	EvPlot("Percus")	# crée "Percus.gp" et "Percus.dat" dans /Data
	EvPlot("ZoomCh", xy(-4, -9, 0, -5))

	Bprint("go:")

	RD = RDisque(Ch, 2)
	ExMIDI(Heli = Helice(Ch, 1.8, 0, 0.04*Pi, 1, -0.1, 0, RD), "TroisNotes")

	ChA = xy(-1,-7)
	ChB = xy(-3,-7)
	ChC = xy(-1,-6)
	ChD = xy(-3,-8)
	ExMIDI(Seg1 = Ecoute(ChA, ChB), "Seg1", 0, 0, RD)
	ExMIDI(Seg2 = Ecoute(ChC, ChD), "Seg2", 0, 0, RD)	

	LDem0 = InitList("Demo0")
	ListGen(LDem0, Seg1, "s1")
	ListGen(LDem0, Seg2, "s2")
	ListScEv(LDem0, Ev)

	GnuPlot(LDem0, "Demo0", xy(-4, -9, 0, -5))

	LDem = InitList("Demo")
	ListGen(LDem, Heli, "H")
	ListScEv(LDem, Ev)
	ListGeo(LDem,"Percus")

	GnuPlot(LDem, "Demo", xy(-4, -9, 0, -5))


#	R1 = RRect(AA,["x"=0,"y"=-3])
#	RBrown = RRect(AA,BB)
#	RBrown = RegionOU(RBrown,RDisque(BB,2))

#	ExMIDI(Ech = Echelle(AA, Ch2, BB, Ch, 10, -5, 0, R1), "echelle")

#	ExMIDI(Heli = Helice(Chh, 1.8, 0, 0.02*Pi, 5, 0, 0, R1), "helice")

#	ExMIDI(Heli2 = Helice(Or, 5, 0, 0.02*Pi, 2, -2, 0, R1), "grande_helice")

#	ExMIDI(Bro = Brown(AA, BB ,1 ,5000, -5, 0, RBrown, R1),"brown")

#	ExMIDI(Cer = EcouteC(CBB4, AA, 1, -5, 0, R1),"cer")

#	ExMIDI(Spi = Spiro(Cer3, 1, 1, 0, 0.2*Pi, 10, AA, -5, 0, R1),"spiro")

#	ExMIDI(Ond = Onde(Cer05, Cer3, 10, 1, AA, -5),"onde")

#	ExMIDI(OndR = Onde(Cer05, Cer3, 10, 1, AA, -5, 0, R1),"onde-region")

}



function TestVague()
{
	LVag = InitList("TestVague")

	P1 = Piste("X= -5", "Y= K", -5, 5, 1)
	P2 = Piste("X= 5", "Y= 1.5*K", -5, 5, 1)
	Vag = Vague(P1, P2, 0.5, Pi/2)

	ListGen(LVag, Vag, "Vag")

	GnuPlot(LVag, "TestVague")
}



function TestList() # Toutes les méthodes d'affichage en un gros blob ! 
{
	TLis = InitList("TestList", 1)
	Tamis = CImport("Tamis")
	ListColl(TLis, Tamis, "Tam")
	Grille = CImport("Grille")
	ListColl(TLis, Grille, "Gri")
	ListScEv(TLis, Ev)
	ListGeo(TLis, "Percus")

	GenO = Onde(Cer05, CBB4, 5, 1, AA)	
	GenS = Spiro(Cer3,0.5,1,0,0.3*Pi,10,AA)
	GenE = Echelle(BB, AA, Ch, Ch2, 5)	
	GenA = AversB(Z,BB,1,Pi)
	GenH = Helice(Ch2, 1.8, 0, 0.02*Pi, 1)
	GenB = Brown(Chh, BB, 1, seconds(30))	


	ListGen(TLis, GenO, "GO")
	ListGen(TLis, GenS, "GS")
	ListGen(TLis, GenE, "GE")
	ListGen(TLis, GenA, "GA")
	ListGen(TLis, GenH, "GH")
	ListGen(TLis, GenB, "GB")

	ListSeg(TLis, BB, Z)
	ListCer(TLis, Loin, 3)

	ListPiste(TLis, Pst = Piste("X= (1+K/5)*cos(K)-5","Y= (1+K/5)*sin(K)", 0, 8*Pi, 0.04*Pi))
	ListPiste(TLis, Rot(Pst, Or, Pi/2))
	ListPiste(TLis, Pst2 = Sca(Trans(Pst, 5, 5), Or, 0.5))
	
	ListColl(TLis, Trans(ScaXY(Rot(Tamis, Or, Pi/12), 1.2, 0.8), -7, -2))

	Con = Convo(Piste("X= 3*sin(K)-4","Y= 3*cos(K)", 0, 2*Pi, Pi/2), Sca(Tamis, Or, 0.3)) 
	ListColl(TLis, Con)

	GenEP = EntrePistes(Pst, Pst2)
	ListGen(TLis, GenEP, "GP")

	GnuPlot(TLis, "TestList", -1)
	GnuPlot(TLis, "TestListGrosPlan", 0, -10, 5, -5)
}


function TCR()	# test du CercleRythm
{
	Omi = ["x"=-1, "y"=0]
	
	GenCR = CercleRythm(Oi, Omi, 10)
	L = InitList("TestCR")
	ListGen(L, GenCR, "bof")
	
	GnuPlot(L, "TestCR", -1)
}


function TestPart()	# test des Partitions
{
	Geo("Percus")
	LoadEv("Percus")

	Ev[15] = [0=2, 1=["x"= -4, "y"= -7, "nodur"= '">" "TEST N 7"', "actif"=1]]
	Ev[15][2] = ["x"= -4, "y"= -7, "nodur"= '">" "TEST N2 random 7"', "actif"=1]
	Ev[15]["PAC"] = Xylo(15)

	Ev[16][0] = 1
	Ev[16][1] = ["x"=-4, "y"=-7, "nodur"= '"*" "print N N2"', "actif"=1]

	AcVar["TEST"] = [1= 'a', 2= 'b', 3= 'c', 4= 'd', 5= 'e', 6= 'f', 7= 'g']
 
	Heli = Helice(Chh, 1.8, 0, 0.2*Pi, 1)

	ExMIDI(Heli, "TestPart")

}