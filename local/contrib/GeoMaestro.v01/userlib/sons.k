



function QuelquesSons(...)
{
	if (nargs() == 1) dir = argv(0) else dir = MDOP

	Arti = ReadPatches("Arti")

	ExMIDI(Sons = AleaSons(12, Arti, 3, 5, 50), fnom = RacineN("Sons.mid", dir), dir)

	f = open(dir+fnom+".txt", "w")
	put(f, Sons)
	close(f)
}


# Format d'un choix de patches:
#------------------------------
# Patch[0]		nbe de patches
# Patch[n]["LSB"]
# Patch[n]["ACn"]
# Patch[n]["low"]	note la plus basse	
# Patch[n]["hig"]	note la plus haute
# Patch[n]["dmin"]	durée minimale
# Patch[n]["dmax"]	durée maximale
# Patch[n]["vmin"]	volume minimal
# Patch[n]["vmax"]	volume maximal

function AleaSons(nbe, choix, np, esp, toffset)
#		  nbe de sons, choix d'instruments, polyphonie, espacement, offset maximum 
{
	res = [0= nbe, "ph"= '']
	for (n=1; n<= nbe; n++)
	{
	   temps = esp*(n-1)
	   res[temps] =  ''
	   for (m=1; m <= np; m++)		#	m <= 16 !
	   {
		ins = rand(1, choix[0])

		add = PourAC(choix[ins]["LSB"],choix[ins]["ACn"],m)+'p60'
		add.chan = m
		add.pitch = rand(choix[ins]["low"], choix[ins]["hig"])
		add.vol = rand(choix[ins]["vmin"], choix[ins]["vmax"])
		add.dur = rand(choix[ins]["dmin"], choix[ins]["dmax"])
		add.time = rand(100)*0.01*toffset
			
		res[temps] |= add    

		add.time += seconds(esp)*(n-1)
		res["ph"] |= add
	   }
	   
	}

	return (res)
}
 



