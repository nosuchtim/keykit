# Compositions GeoMaestro:
#
#  si des éléments géométriques sont définis dans un fichier externe,
#     commencer par un Geo(nom-de-fichier)
#     (le fichier doit être en .txt dans le répertoire /compos)
#
#  Geo("base") est automatiquement effectué à l'initialisation
#


#   Variations sur trois notes


function Main3()
{
#	LoadEv("3notes")

	Pit[17] = DopplerLateral

	Heli = []
	delta = 7*0.02*Pi
	for (n = 1 ; n <= 5; n++)
	{
	    Init3()
	    Heli[n] = Helice(Or, 1.5, 0, delta, 1)

#	    L3 = InitList("3notes")
#	    ListScEv(L3, Ev)
#	    ListGen(L3, Heli[n], "bof")
#	    GnuPlot(L3, "3n"+string(n))

	    ExMIDI(Heli[n], "3notes"+string(n))
	}    

}


function Init3()
{
	choix = ReadPatches("basses")

	Notes = [0= 3, "ch"= 17, "nom"= "3notes"]
	Notes[1]= [Xs= 1, Ys= 0, "nodur"= RandomMix(choix, 2, 10)]
	Notes[2]= [Xs= -0.2, Ys= 1, "nodur"= RandomMix(choix, 2, 10)]
	Notes[3]= [Xs= -0.5, Ys= -0.8, "nodur"= RandomMix(choix, 2, 10)]

	ChoixScene(CreScen(Notes))

	WriteEv("3notes")
	EvPlot("3notes")
}






########### Recherches rythmiques

function CR()	#  CercleRythm
{
	Omi = ["x"=-1, "y"=0]
	LoadEv("pourCR")
		
	EvOlution[18] = EvAffaibli

	GenCR = CercleRythm(Oi, Omi, 20, -0.2)

	ExMIDI(GenCR, "TestCR")
}



function InitCR()
{
	choix1 = ReadPatches("percussions")
	choix2 = ReadPatches("basses")

	NotesBase = [0= 7, "ch"= 17, "nom"= "pourCR"]

	NotesBase[1]= [Xs= 0.7, Ys= 0, "nodur"= RandomMix(choix1, 1, 92, 1)]
	NotesBase[2]= [Xs= 0.2, Ys= 0, "nodur"= RandomMix(choix1, 1, 10, 3)]
	NotesBase[3]= [Xs= -0.7, Ys= 0, "nodur"= RandomMix(choix1, 1, 92, 5)]

	NotesBase[4]= [Xs= 1, Ys= 0, "nodur"= RandomMix(choix1, 1, 10, 7)]
	NotesBase[5]= [Xs= 0, Ys= 0, "nodur"= RandomMix(choix1, 1, 10, 8)]
	NotesBase[6]= [Xs= -0.1, Ys= 0, "nodur"= RandomMix(choix1, 1, 10, 10)]
	NotesBase[7]= [Xs= -0.4, Ys= 0, "nodur"= RandomMix(choix1, 1, 10, 14)]

	scene = CreScen(NotesBase)

	NotesExt = [0= 7, "ch"= 18, "nom"= "pourCR"]

	NotesExt[1]= [Xs= 0.7, Ys= 0.3, "nodur"= RandomMix(choix2, 1, 92, 1)]
	NotesExt[2]= [Xs= 0.2, Ys= -0.2, "nodur"= RandomMix(choix2, 1, 10, 3)]
	NotesExt[3]= [Xs= -0.7, Ys= -0.5, "nodur"= RandomMix(choix2, 1, 92, 5)]

	NotesExt[4]= [Xs= 1, Ys= 1, "nodur"= RandomMix(choix2, 1, 10, 7)]
	NotesExt[5]= [Xs= 1.2, Ys= 0.9, "nodur"= RandomMix(choix2, 1, 10, 8)]
	NotesExt[6]= [Xs= -0.8, Ys= 1, "nodur"= RandomMix(choix2, 1, 10, 10)]
	NotesExt[7]= [Xs= -0.7, Ys= -1, "nodur"= RandomMix(choix2, 1, 10, 14)]

	PlusCol(scene, NotesExt)
	ChoixScene(scene)

	WriteEv("pourCR")

	L = InitList("pourCR")
	ListScEv(L, Ev)
	ListCer(L, Or, 1)
	GnuPlot(L, "pourCR", -1)
}

function ICR2()
{
	choix1 = ReadPatches("xyloandco")

	HM = Maillage(MHexa(0.5, 0), 1, 0, RDisque(Or, 1), 1)	
	DansChoix(HM, choix1, 1, 0)

	scene = CreScen(HM)

	ChoixScene(scene)

	WriteEv("pourCR2")

	L = InitList("pourCR2")
	ListScEv(L, Ev)
	ListCer(L, Or, 1)
	GnuPlot(L, "pourCR2", -1)
}



function CR2()	#  CercleRythm
{
	Omi = ["x"=-1, "y"=0]
	LoadEv("pourCR2")

	Volume[1] = MemeVol
	EvOlution[1] = EvRapprocheCentre
	Ev[1]["PAC"] = Xylo(1)		# Pourquoi est-ce nécessaire ?
	

	Ajustements = "N.vol= 100-90*Abs(Y); N.dur= Minimum(N.dur, 250)"
	KKSR(Ev, RDisque(Or, 1), Ajustements)	

	L = InitList("CaBouge")

	te = 0
	ResPh = ''
	for (n = 1; n <= 10; n++)
	{
		ListScEv(L, Ev, string(n))
		GenCR = CercleRythm(Oi, Omi, 20, -0.2, te)
		ListScEv(L, Ev, string(n))
		te = GenCR[1]
		ResPh = ResPh|GenCR["ph"]
	}

	MIDI(ResPh, "TestCR")
	GnuPlot(L, "CaBouge")
}




