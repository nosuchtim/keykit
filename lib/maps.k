# Note that the "num" value for each patch is 1-based, which is one greater
# than the value that will actually be sent as part of the patch-change
# message.  E.g. a Honky-Tonk patch change on channel 8 would send 'xc703'.

function patchmap() {
	return(Patchmap)
}

function default_port_for_channel(ch) {
	defouts = midi("portmap")[0]
	return(defouts[ch])
}

function patchmap_for_chan(ch) {
	out = default_port_for_channel(ch)
	if ( out in Port2Patchmap ) {
		return(Port2Patchmap[out])
	} else {
		return(patchmap_gm())
	}
}
function drummap_for_chan(ch) {
	out = default_port_for_channel(ch)
	if ( out in Port2Drummap ) {
		return(Port2Drummap[out])
	} else {
		return([])
	}
}

# These *types_for_chan functions return function references

function patchtypes_for_chan(ch) {
	out = default_port_for_channel(ch)
	if ( defined(Port2Patchtypes) && out in Port2Patchtypes ) {
		return(Port2Patchtypes[out])
	} else {
		return(global(patchmap_types_gm))
	}
}
function drumtypes_for_chan(ch) {
	out = default_port_for_channel(ch)
	if ( out in Port2Drumtypes ) {
		return(Port2Drumtypes[out])
	} else {
		return(global(patchmap_types_gm))
	}
}
function patchrandom(ch) {
	arr = patchmap_rand(ch)
	return(arr["patch"])
}
function patchnamed(nm,ch) {
	if ( nargs() < 2 )
		ch = 1
	pmap = patchmap_for_chan(ch)
	arr = patch_lookup(nm,ch,pmap)
	if ( sizeof(arr) == 0 )
		return('')
	else
		return(arr["patch"])
}

function patchnamed_msg(s,ch,pmap) {
	a = patch_lookup(s,ch,pmap)
	if ( sizeof(a) == 0 || ! ("patch" in a) ) {
		return('')
	} else {
		return(a["patch"])
	}
	
}

function patchnumed(num,ch,pmap) {
	a = patch_lookup_bynum(num,ch,pmap)
	if ( sizeof(a) == 0 || ! ("patch" in a) ) {
		return('')
	} else {
		return(a["patch"])
	}
	
}

function patch_lookup(s,ch,pmap) {
	if ( nargs() < 3 ) {
		print("usage: patch_lookup(string,chan,pmap)")
		return([])
	}
	for ( n in pmap ) {
		if ( pmap[n]["name"] ~~ s ) {
			m = pmap[n]
			p = patchmap_phrase(m,ch)
			arr = ["patch"=p,"name"=m["name"]]
			return(arr)
		}
	}
	return([])
}

function patch_lookup_bynum(num,ch,pmap) {
	if ( nargs() < 3 ) {
		print("usage: patch_lookup(string,chan,pmap)")
		return([])
	}
	for ( n in pmap ) {
		if ( ("num" in pmap[n]) && (pmap[n]["num"] == num) ) {
			m = pmap[n]
			p = patchmap_phrase(m,ch)
			arr = ["patch"=p,"name"=m["name"]]
			return(arr)
		}
	}
	return([])
}

function patchmap_types_gm(type) {
	n=0
	p = []
	if ( "pad" ~~ type ) {
		p[n++] = "Pad 1 (new age)"
		p[n++] = "Pad 2 (warm)"
		p[n++] = "Pad 3 (polysynth)"
		p[n++] = "Pad 4 (choir)"
		p[n++] = "Pad 5 (bowed)"
		p[n++] = "Pad 6 (metallic)"
		p[n++] = "Pad 7 (halo)"
		p[n++] = "Pad 8 (sweep)"
	}
	if ( "hard" ~~ type ) {
		p[n++] = "Clav"
	}
	if ( "bass" ~~ type ) {
		p[n++] = "Acous. Bass"
		p[n++] = "Elec. Bass,finger"
		p[n++] = "Elec. Bass,pick"
		p[n++] = "Fretless Bass"
		p[n++] = "Slap Bass 1"
		p[n++] = "Slap Bass 2"
		p[n++] = "Synth Bass 1"
		p[n++] = "Synth Bass 2"
	}
	if ( "perc" ~~ type ) {
		p[n++] = "Nylon Guitar"
	}
	if ( "drum" ~~ type ) {
		p[n++] = "Taiko Drum"
	}
	if ( "vocal" ~~ type ) {
		p[n++] = "Choir Aahs"
		p[n++] = "Voice Oohs"
		p[n++] = "Synth Voice"
	}

	return(p)
}


function patchmap_gm() {
	if ( ! defined(Gmpatchmap) )
		Gmpatchmap = patchmap_gm_real()
	return(Gmpatchmap)
}

function patchmap_gm_real() {
	return([
		0=["num"=1,"name"="Acoustic Grand"],
		1=["num"=2,"name"="Bright Acoustic"],
		2=["num"=3,"name"="Elec. Grand"],
		3=["num"=4,"name"="Honky-Tonk"],
		4=["num"=5,"name"="Elec. Piano 1"],
		5=["num"=6,"name"="Elec. Piano 2"],
		6=["num"=7,"name"="Harpsichord"],
		7=["num"=8,"name"="Clav"],
		8=["num"=9,"name"="Celesta"],
		9=["num"=10,"name"="Glockenspiel"],
		10=["num"=11,"name"="Music Box"],
		11=["num"=12,"name"="Vibraphone"],
		12=["num"=13,"name"="Marimba"],
		13=["num"=14,"name"="Xylophone"],
		14=["num"=15,"name"="Tubular Bells"],
		15=["num"=16,"name"="Dulcimer"],
		16=["num"=17,"name"="Drawbar Organ"],
		17=["num"=18,"name"="Percussive Organ"],
		18=["num"=19,"name"="Rock Organ"],
		19=["num"=20,"name"="Church Organ"],
		20=["num"=21,"name"="Reed Organ"],
		21=["num"=22,"name"="Accoridan"],
		22=["num"=23,"name"="Harmonica"],
		23=["num"=24,"name"="Tango Accordian"],
		24=["num"=25,"name"="Nylon Guitar"],
		25=["num"=26,"name"="Acous. Gtr(steel)"],
		26=["num"=27,"name"="Elec. Gtr(jazz)"],
		27=["num"=28,"name"="Elec. Gtr(clean)"],
		28=["num"=29,"name"="Elec. Gtr(muted)"],
		29=["num"=30,"name"="Overdriven Gtr"],
		30=["num"=31,"name"="Distortion Gtr"],
		31=["num"=32,"name"="Guitar Harmonics"],
		32=["num"=33,"name"="Acous. Bass"],
		33=["num"=34,"name"="Elec. Bass,finger"],
		34=["num"=35,"name"="Elec. Bass,pick"],
		35=["num"=36,"name"="Fretless Bass"],
		36=["num"=37,"name"="Slap Bass 1"],
		37=["num"=38,"name"="Slap Bass 2"],
		38=["num"=39,"name"="Synth Bass 1"],
		39=["num"=40,"name"="Synth Bass 2"],
		40=["num"=41,"name"="Violin"],
		41=["num"=42,"name"="Viola"],
		42=["num"=43,"name"="Cello"],
		43=["num"=44,"name"="Contrabass"],
		44=["num"=45,"name"="Tremolo Strings"],
		45=["num"=46,"name"="Pizzicato Strings"],
		46=["num"=47,"name"="Harp"],
		47=["num"=48,"name"="Timpani"],
		48=["num"=49,"name"="String Ensemble 1"],
		49=["num"=50,"name"="String Ensemble 2"],
		50=["num"=51,"name"="SynthStrings 1"],
		51=["num"=52,"name"="SynthStrings 2"],
		52=["num"=53,"name"="Choir Aahs"],
		53=["num"=54,"name"="Voice Oohs"],
		54=["num"=55,"name"="Synth Voice"],
		55=["num"=56,"name"="Orchestra Hit"],
		56=["num"=57,"name"="Trumpet"],
		57=["num"=58,"name"="Trombone"],
		58=["num"=59,"name"="Tuba"],
		59=["num"=60,"name"="Muted Trumpet"],
		60=["num"=61,"name"="French Horn"],
		61=["num"=62,"name"="Brass Section"],
		62=["num"=63,"name"="SynthBrass 1"],
		63=["num"=64,"name"="SynthBrass 2"],
		64=["num"=65,"name"="Soprano Sax"],
		65=["num"=66,"name"="Alto Sax"],
		66=["num"=67,"name"="Tenor Sax"],
		67=["num"=68,"name"="Baritone Sax"],
		68=["num"=69,"name"="Oboe"],
		69=["num"=70,"name"="English Horn"],
		70=["num"=71,"name"="Bassoon"],
		71=["num"=72,"name"="Clarinet"],
		72=["num"=73,"name"="Piccolo"],
		73=["num"=74,"name"="Flute"],
		74=["num"=75,"name"="Recorder"],
		75=["num"=76,"name"="Pan Flute"],
		76=["num"=77,"name"="Blown Bottle"],
		77=["num"=78,"name"="Skakuhachi"],
		78=["num"=79,"name"="Whistle"],
		79=["num"=80,"name"="Ocarina"],
		80=["num"=81,"name"="Lead 1 (square)"],
		81=["num"=82,"name"="Lead 2 (sawtooth)"],
		82=["num"=83,"name"="Lead 3 (calliope)"],
		83=["num"=84,"name"="Lead 4 (chiff)"],
		84=["num"=85,"name"="Lead 5 (charang)"],
		85=["num"=86,"name"="Lead 6 (voice)"],
		86=["num"=87,"name"="Lead 7 (fifths)"],
		87=["num"=88,"name"="Lead 8 (bass+lead)"],
		88=["num"=89,"name"="Pad 1 (new age)"],
		89=["num"=90,"name"="Pad 2 (warm)"],
		90=["num"=91,"name"="Pad 3 (polysynth)"],
		91=["num"=92,"name"="Pad 4 (choir)"],
		92=["num"=93,"name"="Pad 5 (bowed)"],
		93=["num"=94,"name"="Pad 6 (metallic)"],
		94=["num"=95,"name"="Pad 7 (halo)"],
		95=["num"=96,"name"="Pad 8 (sweep)"],
		96=["num"=97,"name"="FX 1 (rain)"],
		97=["num"=98,"name"="FX 2 (soundtrack)"],
		98=["num"=99,"name"="FX 3 (crystal)"],
		99=["num"=100,"name"="FX 4 (atmosphere)"],
		100=["num"=101,"name"="FX 5 (brightness)"],
		101=["num"=102,"name"="FX 6 (goblins)"],
		102=["num"=103,"name"="FX 7 (echoes)"],
		103=["num"=104,"name"="FX 8 (sci-fi)"],
		104=["num"=105,"name"="Sitar"],
		105=["num"=106,"name"="Banjo"],
		106=["num"=107,"name"="Shamisen"],
		107=["num"=108,"name"="Koto"],
		108=["num"=109,"name"="Kalimba"],
		109=["num"=110,"name"="Bagpipe"],
		110=["num"=111,"name"="Fiddle"],
		111=["num"=112,"name"="Shanai"],
		112=["num"=113,"name"="Tinkle Bell"],
		113=["num"=114,"name"="Agogo"],
		114=["num"=115,"name"="Steel Drums"],
		115=["num"=116,"name"="Woodblock"],
		116=["num"=117,"name"="Taiko Drum"],
		117=["num"=118,"name"="Melodic Tom"],
		118=["num"=119,"name"="Synth Drum"],
		119=["num"=120,"name"="Reverse Cymbal"],
		120=["num"=121,"name"="Guitar Fret Noise"],
		121=["num"=122,"name"="Breath Noise"],
		122=["num"=123,"name"="Seashore"],
		123=["num"=124,"name"="Bird Tweet"],
		124=["num"=125,"name"="Telephone Ring"],
		125=["num"=126,"name"="Helicopter"],
		126=["num"=127,"name"="Applause"],
		127=["num"=128,"name"="Gunshot"],
		128=["func"="","name"="None"]
	])
}

function patchmapnames(pmap) {
	if ( nargs() < 1 )
		pmap = Patchmap
	psz = sizeof(pmap)
	pname = []
	for ( n=0; n<psz; n++ ) {
		pname[n] = pmap[n]["name"]
	}
	return(pname)
}
function patchmapnums() {
	p = Patchmap
	psz = sizeof(p)
	pnums = []
	for ( n=0; n<psz; n++ ) {
		pnums[n] = p[n]["num"]
	}
	return(pnums)
}

function drummap() {
	return([
		0=["note"='p35c10',"name"="Acoustic Bass Drum"],
		1=["note"='p36c10',"name"="Bass Drum 1"],
		2=["note"='p37c10',"name"="Side Stick"],
		3=["note"='p38c10',"name"="Acoustic Snare"],
		4=["note"='p39c10',"name"="Hand Clap"],
		5=["note"='p40c10',"name"="Electric Snare"],
		6=["note"='p41c10',"name"="Low Floor Tom"],
		7=["note"='p42c10',"name"="Closed Hi-Hat"],
		8=["note"='p43c10',"name"="High Floor Tom"],
		9=["note"='p44c10',"name"="Pedal Hi-Hat"],
		10=["note"='p45c10',"name"="Low Tom"],
		11=["note"='p46c10',"name"="Open Hi-Hat"],
		12=["note"='p47c10',"name"="Low-Mid Tom"],
		13=["note"='p48c10',"name"="Hi-Mid Tom"],
		14=["note"='p49c10',"name"="Crash Cymbal 1"],
		15=["note"='p50c10',"name"="High Tom"],
		16=["note"='p51c10',"name"="Ride Cymbal 1"],
		17=["note"='p52c10',"name"="Chinese Cymbal"],
		18=["note"='p53c10',"name"="Ride Bell"],
		19=["note"='p54c10',"name"="Tambourine"],
		20=["note"='p55c10',"name"="Splash Cymbal"],
		21=["note"='p56c10',"name"="Cowbell"],
		22=["note"='p57c10',"name"="Crash Cymbal 2"],
		23=["note"='p58c10',"name"="Vibraslap"],
		24=["note"='p59c10',"name"="Ride Cymbal 2"],
		25=["note"='p60c10',"name"="Hi Bongo"],
		26=["note"='p61c10',"name"="Low Bongo"],
		27=["note"='p62c10',"name"="Mute Hi Conga"],
		28=["note"='p63c10',"name"="Open Hi Conga"],
		29=["note"='p64c10',"name"="Low Conga"],
		30=["note"='p65c10',"name"="High Timbale"],
		31=["note"='p66c10',"name"="Low Timbale"],
		32=["note"='p67c10',"name"="High Agogo"],
		33=["note"='p68c10',"name"="Low Agogo"],
		34=["note"='p69c10',"name"="Cabasa"],
		35=["note"='p70c10',"name"="Maracas"],
		36=["note"='p71c10',"name"="Short Whistle"],
		37=["note"='p72c10',"name"="Long Whistle"],
		38=["note"='p73c10',"name"="Short Guiro"],
		39=["note"='p74c10',"name"="Long Guiro"],
		40=["note"='p75c10',"name"="Claves"],
		41=["note"='p76c10',"name"="Hi Wood Block"],
		42=["note"='p77c10',"name"="Low Wood Block"],
		43=["note"='p78c10',"name"="Mute Cuica"],
		44=["note"='p79c10',"name"="Open Cuica"],
		45=["note"='p80c10',"name"="Mute Triangle"],
		46=["note"='p81c10',"name"="Open Triangle"]
		])
}

function gmdrumnamed(s) {
	if ( ! defined(Gmdrummap) )
		Gmdrummap = drummap()
	for ( i in Gmdrummap ) {
		if ( s == Gmdrummap[i]["name"] )
			return(Gmdrummap[i]["note"])
	}
	return('')
}

function patchmap_drums_rand(ch) {
	if ( ! defined(Patchmap_drums) ) {
		print("No definition for Patchmap_drums")
		return([])
	}
	return(patchmap_rand_real(ch,Patchmap_drums))
}

function patchmap_rand(ch) {
	pmap = patchmap_for_chan(ch)
	return(patchmap_rand_real(ch,pmap))
}
function drummap_rand(ch) {
	pmap = drummap_for_chan(ch)
	return(patchmap_rand_real(ch,pmap))
}

function patchmap_type(ch,t) {
	f = patchtypes_for_chan(ch)
	pmap = patchmap_for_chan(ch)
	names = f(t)
	nm = names[rand(sizeof(names))]
	arr = patch_lookup(nm,ch,pmap)
	return(arr)
}

function drummap_type(ch,t) {
	f = drumtypes_for_chan(ch)
	pmap = drummap_for_chan(ch)
	names = f(t)
	nm = names[rand(sizeof(names))]
	arr = patch_lookup(nm,ch,pmap)
	return(arr)
}

function patchmap_rand_real(ch,map) {
	if ( nargs() < 1 )
		ch = 1
	if ( sizeof(map) == 0 ) {
		return(["patch"='',"name"="NoPatchMapDefined"])
	}
	n = rand(sizeof(map))
	m = map[n]
	p = patchmap_phrase(m,ch)
	arr = ["patch"=p,"name"=m["name"]]
	return(arr)
}

function patchmap_bynum(n,ch) {
	if ( nargs() < 2 )
		ch = 1
	if ( ! (n in Patchmap) )
		n = 1
	arr = Patchmap[n]
	p = patchmap_phrase(arr,ch)
	arr = ["patch"=p,"name"=arr["name"]]
	return(arr)
}

function patchmap_bynum_pmap(n,ch,pmap) {
	if ( nargs() < 2 )
		ch = 1
	if ( ! (n in pmap) )
		n = 1
	arr = pmap[n]
	p = patchmap_phrase(arr,ch)
	arr = ["patch"=p,"name"=arr["name"]]
	return(arr)
}

function patchmap_phrase(arr,ch) {
	if ( "func" in arr ) {
		f = arr["func"]
		if ( f == "" ) {
			p = ''
		} else {
			CH = ch
			eval "PN__ = "+arr["func"]
			p = PN__
		}
	} else {
		p = progchange(arr["num"],ch)
	}
	return(p)
}
