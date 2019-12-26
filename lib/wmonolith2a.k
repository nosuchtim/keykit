FakeLCD = 1
DebugMonolith = 0

# Global parameters:
# Fading
# Tempo
# Keychanges
# LoopLength

class wmonolith2a {
method init {
	$.w = new window()
	$.inherit($.w)

	$.tid = -1
	$.nextstep_tm = Now

	$.bpm_values = [0=50,1=80,2=100,3=120,4=150,5=200]
	$.bpm_index = 2
	$.set_tempo()

	$.gesturerows = 6
	$.gesturecols = 6
	$.triggerrows = 4
	$.triggercols = 4

	# On low-CPU-power machines (like the Atom-based eee box), this is
	# needed to avoid pops/clicks during excessive igesture activity
	mdep("priority","realtime")

	$.default_fade = 2

	$.default_autotrans = 0

	$.fade_index = $.default_fade
	$.autotrans = $.default_autotrans

	$.redrawlcd_time = [0=0,1=0]
	$.lcdtimeout = 1200   # milliseconds
	$.drum_voloffset = 20
	$.drum_pitch0 = 24
	$.nondrum_voloffset = 20
	$.lcd_index = [0=Lcd0,1=Lcd1]

	$.showbusy = 0

	$.transpose_current = 0
	$.transpose_loops = 8
	$.transpose_index = 0
	$.transpose_counter = 0
	$.transpose_sequence = [
		0=0, 1=7, 2=5, 3=3
		]
	$.side_fingersdown = [0=0,1=0]

	$.scale_names = []
	n = 0
	$.scale_names[n++] = "Japanese"     # good
	# $.scale_names[n++] = "Japanese2"
	# $.scale_names[n++] = "Japanese3"
	# $.scale_names[n++] = "Japanese4"
	$.scale_names[n++] = "Egyptian"
	# $.scale_names[n++] = "Egyptian2"
	$.scale_names[n++] = "Greek"
	# $.scale_names[n++] = "Greek1"
	# $.scale_names[n++] = "Greek3"
	$.scale_names[n++] = "Greek2"
	# $.scale_names[n++] = "Greek4"
	# $.scale_names[n++] = "Greek5"
	$.scale_names[n++] = "Chinese"
	# $.scale_names[n++] = "Javanese"
	# $.scale_names[n++] = "Ionian"
	# $.scale_names[n++] = "Dorian"
	$.scale_names[n++] = "Arabian"
	# $.scale_names[n++] = "Arabian2"
	# $.scale_names[n++] = "Arabian3"   # soso
	# $.scale_names[n++] = "Indian"
	$.scale_names[n++] = "WestAfrican"
	# $.scale_names[n++] = "Lydian"		# almost
	$.scale_names[n++] = "Mixolydian"
	# $.scale_names[n++] = "Aeolian"
	# $.scale_names[n++] = "Hungarian"	# almost
	$.scale_names[n++] = "Rwanda"
	$.scale_names[n++] = "New Age"
	$.scale_names[n++] = "Fifths"
	# $.scale_names[n++] = "Harminor"
	# $.scale_names[n++] = "Melminor"
	# $.scale_names[n++] = "Chromatic"

	$.scale_names = []
	n = 0
	$.scale_names[n++] = "Chinese"
	$.scale_names[n++] = "WestAfrican"
	$.scale_names[n++] = "New Age"
	# $.scale_names[n++] = "Fifths"
	$.scale_names[n++] = "Arabian"
	$.scale_names[n++] = "Rwanda"
	$.scale_names[n++] = "Japanese"
	# $.scale_names[n++] = "Mixolydian"
	$.scale_names[n++] = "Egyptian"
	$.scale_names[n++] = "Greek"
	# $.scale_names[n++] = "Greek2"

	$.scale_notes = [
		"Japanese" = 'p0,p3,p5,p8,p10',
		"Japanese2" = 'p0,p2,p3,p7,p8',
		"Japanese3" = 'p0,p1,p5,p7,p10',
		"Japanese4" = 'p0,p2,p3,p5,p7,p9',
		"Egyptian" = 'p0,p2,p3,p7,p8',
		"Egyptian2" = 'p0,p2,p3,p6,p7,p8,p11',
		"Greek" = 'p0,p1,p4,p7,p8,p10',
		"Greek1" = 'p0,p3,p4,p5,p7,p9,p11',
		"Greek2" = 'p0,p2,p3,p6,p7,p9,p10',
		"Greek3" = 'p0,p1,p3,p4,p7,p8,p10',
		"Greek4" = 'p0,p2,p3,p4,p7,p8,p10,p11',
		"Greek5" = 'p0,p3,p4,p5,p7,p8,p11',
		"Chinese" = 'p0,p2,p5,p7,p9',
		"Javanese" = 'p0,p2,p4,p5,p7,p9,p11',
		"Ionian" = 'p0,p2,p4,p5,p7,p9,p11',
		"Dorian" = 'p0,p2,p3,p5,p7,p9,p10',
		"Arabian" = 'p0,p1,p4,p5,p7,p8,p10',   # Phrygian
		"Arabian2" = 'p0,p1,p3,p6,p7,p8,p11',   # Blues?
		"Arabian3" = 'p0,p2,p3,p5,p7,p9,p10',
		"Indian" = 'p0,p1,p4,p6,p7,p8,p11',   # Purvi
		"WestAfrican" = 'p0,p3,p5,p7,p10',
		"Lydian" = 'p0,p2,p4,p6,p7,p9,p11',
		"Mixolydian" = 'p0,p2,p4,p5,p7,p9,p10',
		"Aeolian" = 'p0,p2,p3,p5,p7,p8,p10',
		"Hungarian" = 'p0,p2,p3,p5,p6,p8,p9',
		"Rwanda" = 'p0,p2,p3,p7,p10',
		"New Age" = 'p0,p3,p5,p7,p10',
		"Fifths" = 'p0,p7',
		"Harminor" = 'p0,p2,p3,p5,p7,p8,p11',
		"Melminor" = 'p0,p2,p3,p5,p7,p9,p11',
		"Chromatic" = 'p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11'
		]

	$.side_scale_index = [
		0=0,
		1=1
		]

	$.chord_notes = [
		"None"='p0',
		"Major"='p0 p4 p7',
		"Minor"='p0 p3 p7',
		"Maj7"='p0 p4 p7 p11',
		"Min7"='p0 p3 p7 p10',
		"Maj9"='p0 p4 p7 p11 p14',
		"Min9"='p0 p3 p7 p10 p14',
		"Sus"='p0 p5 p7',
		"Dim"='p0 p3 p6',
		"Aug"='p0 p4 p8',
		"Maj69"='p0 p4 p7 p9',
		"MajB769"='p0 p3 p5 p9 p10',
		"HalfDim"='p0 p3 p6 p10',
		"Dim9"='p0 p3 p6 p9 p14',
		"NModMaj1"='p0 p1 p4 p8',
		"NModMaj2"='p0 p4 p6 p9',
		"NModMaj3"='p0 p1 p3 p6',	
		"NModDom1"='p0 p1 p4 p7',	
		"NModDom2"='p0 p1 p4 p6',
		"NModDom3"='p0 p2 p6 p8',
		"NModDom4"='p0 p5 p8 p11',
		"ArtDim"='p0 p2 p5 p8',
		"AOVoic1"='p0 p7 p10 p12 p17',
		"AOVoic2"='p0 p1 p7 p12 p17',
		"AllMaj"='p0 p2 p5 p7 p11 p16 p21',
		"Res"='p0 p4 p7 p10 p14 p17 p20 p23',
		"Vitr1"='p0 p3 p6 p8 p14 p16 p19 p22',
		"Vitr2"='p0 p3 p5 p9 p13 p16 p19 p23',
		"Fourth"='p0 p5',
		"Fifth"='p0 p7',
		"Sequence1"='p0,p7',
		"Sequence2"='p0d48,p7,p5',
		"Fourths"='p0 p6 p11 p17 p22 p28',
		"Pr1"='p0 p2 p3 p5 p7 p11',
		"Pr2"='p0 p3 p5 p7 p11 p13',
		"Pr3"='p0 p5 p7 p11 p13 p14',
		"Pr4"='p0 p3 p5 p7 p11 p14 p17'
	]

	$.chord_names = []
	n=0
	$.chord_names[n++] = "None"
	$.chord_names[n++] = "Major"
	$.chord_names[n++] = "Minor"
	$.chord_names[n++] = "Maj7"
	$.chord_names[n++] = "Min7"
	$.chord_names[n++] = "Maj9"
	$.chord_names[n++] = "Min9"
	$.chord_names[n++] = "Sus"
	$.chord_names[n++] = "Dim"
	$.chord_names[n++] = "Aug"
	$.chord_names[n++] = "Maj69"
	$.chord_names[n++] = "MajB769"
	$.chord_names[n++] = "HalfDim"
	$.chord_names[n++] = "Dim9"
	$.chord_names[n++] = "NModMaj1"
	$.chord_names[n++] = "NModMaj2"
	$.chord_names[n++] = "NModMaj3"
	$.chord_names[n++] = "NModDom1"
	$.chord_names[n++] = "NModDom2"
	$.chord_names[n++] = "NModDom3"
	$.chord_names[n++] = "NModDom4"
	$.chord_names[n++] = "ArtDim"
	$.chord_names[n++] = "AOVoic1"
	$.chord_names[n++] = "AOVoic2"
	$.chord_names[n++] = "AllMaj"
	$.chord_names[n++] = "Res"
	$.chord_names[n++] = "Vitr1"
	$.chord_names[n++] = "Vitr2"
	$.chord_names[n++] = "Fourths"
	$.chord_names[n++] = "Pr1"
	$.chord_names[n++] = "Pr2"
	$.chord_names[n++] = "Pr3"
	$.chord_names[n++] = "Pr4"

	$.chord_names = []
	n=0
	$.chord_names[n++] = "None"
	$.chord_names[n++] = "Fourth"
	$.chord_names[n++] = "Fifth"
	$.chord_names[n++] = "Sus"
	$.chord_names[n++] = "AOVoic2"
	$.chord_names[n++] = "Maj7"
	$.chord_names[n++] = "Min7"
	# $.chord_names[n++] = "Min9"
	$.chord_names[n++] = "Dim9"
	$.chord_names[n++] = "NModMaj2"
	$.chord_names[n++] = "Fourths"
	$.chord_names[n++] = "Sequence1"
	$.chord_names[n++] = "Sequence2"

	$.side_chord_index = [
		0=0,
		1=0
		]

	$.noteset_trigger = [0=[],1=[]]
	$.noteset_gesture = [0=[],1=[]]

	$.make_noteset_scale(0)
	$.make_noteset_scale(1)

	$.fade_vals = [
		0 = 1.00,
		1 = 0.90,
		2 = 0.75,
		3 = 0.50,
		4 = 0.20
		]

	$.fade_message = [
		0 = "Notes will\nnever fade out.",
		1 = "Notes will fade out\nin 10 loops",
		2 = "Notes will fade out\nin 7 loops",
		3 = "Notes will fade out\nin 4 loops",
		4 = "Notes will fade out\nin 1 loop"
		]

	$.trigger_rowcol = [
		24 = ["row"=0,"col"=0],
		25 = ["row"=0,"col"=1],
		26 = ["row"=0,"col"=2],
		27 = ["row"=0,"col"=3],
		28 = ["row"=1,"col"=0],
		29 = ["row"=1,"col"=1],
		30 = ["row"=1,"col"=2],
		31 = ["row"=1,"col"=3],
		32 = ["row"=2,"col"=0],
		33 = ["row"=2,"col"=1],
		34 = ["row"=2,"col"=2],
		35 = ["row"=2,"col"=3],
		36 = ["row"=3,"col"=0],
		37 = ["row"=3,"col"=1],
		38 = ["row"=3,"col"=2],
		39 = ["row"=3,"col"=3]
		]

	$.vst_desc = [
	    0=[
		0=["name"="Bass 1a","type"="pitched"],
		1=["name"="Bass 2a","type"="pitched"],
		2=["name"="Bass 3a","type"="pitched"],
		3=["name"="Bass 4a","type"="pitched"],
		4=["name"="Lead 1a","type"="pitched"],
		5=["name"="Lead 2a","type"="pitched"],
		6=["name"="Lead 3a","type"="pitched"],
		7=["name"="Lead 4a","type"="pitched"],
		8=["name"="Pad 1a","type"="pitched"],
		9=["name"="Pad 2a","type"="pitched"],
		10=["name"="Pad 3a","type"="pitched"],
		11=["name"="Pad 4a","type"="pitched"],
		12=["name"="Drum 1a","type"="drum"],
		13=["name"="Drum 2a","type"="drum"],
		14=["name"="Drum 3a","type"="drum"],
		15=["name"="Drum 4a","type"="drum"]
	    ],
	    1=[
		0=["name"="Bass 1b","type"="pitched"],
		1=["name"="Bass 2b","type"="pitched"],
		2=["name"="Bass 3b","type"="pitched"],
		3=["name"="Bass 4b","type"="pitched"],
		4=["name"="Lead 1b","type"="pitched"],
		5=["name"="Lead 2b","type"="pitched"],
		6=["name"="Lead 3b","type"="pitched"],
		7=["name"="Lead 4b","type"="pitched"],
		8=["name"="Pad 1b","type"="pitched"],
		9=["name"="Pad 2b","type"="pitched"],
		10=["name"="Pad 3b","type"="pitched"],
		11=["name"="Pad 4b","type"="pitched"],
		12=["name"="Drum 1b","type"="drum"],
		13=["name"="Drum 2b","type"="drum"],
		14=["name"="Drum 3b","type"="drum"],
		15=["name"="Drum 4b","type"="drum"]
	    ]
	]

# 	$.gamebutton_name = [
# 		"A4"="CLR",
# 		"A3"="LNG",
# 		"A2"="NXT",
# 		"A1"="DSP",
# 		"M4"="XXX",
# 		"M3"="ENT",
# 		"M2"="NXT",
# 		"M1"="BCK",
# 		"T4"="RFF",
# 		"T3"="SND",
# 		"T2"="NTS",
# 		"T1"="REC",
# 		"G1"="NTS",
# 		"G2"="RPT",
# 		"G3"="EF1",
# 		"G4"="EF1"
# 		]
# 
# 	$.side_buttons = [
# 		"A4"=1,
# 		"A3"=1,
# 		"A2"=1,
# 		"A1"=1,
# 		"T4"=1,
# 		"T3"=1,
# 		"T2"=1,
# 		"T1"=1,
# 		"G1"=1,
# 		"G2"=1,
# 		"G3"=1,
# 		"G4"=1
# 		]

	$.nanokey_names = [
	    "L" = [
		72=["x"=1,"y"=0,"name"="Track 1"],
		71=["x"=1,"y"=2,"name"="Track 2"],
		70=["x"=0,"y"=3,"name"="Chng Snd"],
		69=["x"=1,"y"=4,"name"="Track 3"],
		68=["x"=0,"y"=5,"name"="Reset Snd"],
		67=["x"=1,"y"=6,"name"="Track 4"],
		66=["x"=0,"y"=7,"name"="Random Snds"],
		65=["x"=1,"y"=8,"name"="Octave Up"],
		64=["x"=1,"y"=10,"name"="Octave Down"],
		63=["x"=0,"y"=11,"name"="Fade Quicker"],
		62=["x"=1,"y"=12,"name"="Rec on/off"],
		61=["x"=0,"y"=13,"name"="Fade Slower"],
		60=["x"=1,"y"=14,"name"="AutoTrans"],
		59=["x"=1,"y"=16,"name"="Scale Nxt"],
		58=["x"=0,"y"=17,"name"="Fewer Nts"],
		57=["x"=1,"y"=18,"name"="Scale Reset"],
		56=["x"=0,"y"=19,"name"="Silnc Track"],
		55=["x"=1,"y"=20,"name"="Chord Nxt"],
		54=["x"=0,"y"=21,"name"="Silnc All"],
		53=["x"=1,"y"=22,"name"="Chord Reset"],
		52=["x"=1,"y"=24,"name"="Faster"],
		51=["x"=0,"y"=25,"name"="Longer Loop"],
		50=["x"=1,"y"=26,"name"="Slower"],
		49=["x"=0,"y"=27,"name"="Shorter Loop"],
		48=["x"=1,"y"=28,"name"="Reset All"]
		],
	    "R" = [
		72=["x"=1,"y"=0,"name"="X101"],
		71=["x"=1,"y"=2,"name"="X102"],
		70=["x"=0,"y"=3,"name"="x50"],
		69=["x"=1,"y"=4,"name"="x53"],
		68=["x"=0,"y"=5,"name"="x51"],
		67=["x"=1,"y"=6,"name"="X103"],
		66=["x"=0,"y"=7,"name"="x55"],
		65=["x"=1,"y"=8,"name"="X104"],
		64=["x"=1,"y"=10,"name"="x44"],
		63=["x"=0,"y"=11,"name"="PadMd Nxt"],
		62=["x"=1,"y"=12,"name"="x45"],
		61=["x"=0,"y"=13,"name"="PdMod Reset"],
		60=["x"=1,"y"=14,"name"="x46"],
		59=["x"=1,"y"=16,"name"="B4"],
		58=["x"=0,"y"=17,"name"="Load 1"],
		57=["x"=1,"y"=18,"name"="Save 1"],
		56=["x"=0,"y"=19,"name"="Load 2"],
		55=["x"=1,"y"=20,"name"="Save 2"],
		54=["x"=0,"y"=21,"name"="Load 3"],
		53=["x"=1,"y"=22,"name"="Save 3"],
		52=["x"=1,"y"=24,"name"="Reset Ptrns"],
		51=["x"=0,"y"=25,"name"="B12"],
		50=["x"=1,"y"=26,"name"="B13"],
		49=["x"=0,"y"=27,"name"="Reset"],
		48=["x"=1,"y"=28,"name"="Help"]
		]
	]

	$.track_vst = [
		0=[0=-1,1=-1,2=-1,3=-1],
		1=[0=-1,1=-1,2=-1,3=-1]
		]

	$.track_octave = [
		0=[0=0,1=0,2=0,3=0],
		1=[0=0,1=0,2=0,3=0]
		]

	$.octave_names = [
		0 = "not transposed",
		1 = "UP one octave",
		2 = "UP two octaves",
		3 = "UP three octaves",
		-1 = "DOWN one octave",
		-2 = "DOWN two octaves",
		-3 = "DOWN three octaves"
		]

	$.lcdbusy = [
		0=[0=0,1=0,2=0,3=0],
		1=[0=0,1=0,2=0,3=0]
		]

	$.current_down_phr = ["trigger"=[],"gesture"=[]]
	$.current_down_phr_notranspose = ["trigger"=[],"gesture"=[]]
	$.current_down_step = ["trigger"=[],"gesture"=[]]
	$.current_down_trk = ["trigger"=[],"gesture"=[]]

	tt = "trigger"
	for ( s=0; s<2; s++ ) {
		$.current_down_phr[tt][s] = []
		$.current_down_phr_notranspose[tt][s] = []
		$.current_down_step[tt][s] = []
		$.current_down_trk[tt][s] = []
		for ( row=0; row<$.triggerrows; row++ ) {
			$.current_down_phr[tt][s][row] = []
			$.current_down_phr_notranspose[tt][s][row] = []
			$.current_down_step[tt][s][row] = []
			$.current_down_trk[tt][s][row] = []
			for ( col=0; col<$.triggercols; col++ ) {
				$.current_down_phr[tt][s][row][col] = ''
				$.current_down_phr_notranspose[tt][s][row][col] = ''
				$.current_down_step[tt][s][row][col] = -1
				$.current_down_trk[tt][s][row][col] = -1
			}
		}
	}

	tt = "gesture"
	for ( s=0; s<2; s++ ) {
		$.current_down_phr[tt][s] = []
		$.current_down_phr_notranspose[tt][s] = []
		$.current_down_step[tt][s] = []
		$.current_down_trk[tt][s] = []
		for ( row=0; row<$.gesturerows; row++ ) {
			$.current_down_phr[tt][s][row] = []
			$.current_down_phr_notranspose[tt][s][row] = []
			$.current_down_step[tt][s][row] = []
			$.current_down_trk[tt][s][row] = []
			for ( col=0; col<$.gesturecols; col++ ) {
				$.current_down_phr[tt][s][row][col] = ''
				$.current_down_phr_notranspose[tt][s][row][col] = ''
				$.current_down_step[tt][s][row][col] = -1
				$.current_down_trk[tt][s][row][col] = -1
			}
		}
	}

	$.lcd_labels = [
		0=[0="one",1="two",2="three",3="four"],
		1=[0="oneB",1="twoB",2="threeB",3="fourB"]
		]

	# $.reset_button_history()

	$.default_is_recording = 1
	$.is_recording = [0=$.default_is_recording,1=$.default_is_recording]

	# $.is_selectingsound = [0=0,1=0]
	# $.is_selectingnotes = [0=0,1=0]
	# $.is_selectingriff = [0=0,1=0]

	$.vst_enabled = []
	$.side_effect = [0=0,1=0]
	$.neffects = 5

	$.padmode_message = [
		0 = "Right Pad will now\nplay notes"
		]

	for ( e=1; e<=$.neffects; e++ ) {
		$.padmode_message[e] = "Right pad will now\ndo effect "+string(e)
	}

	$.side_effect_ctrl = [
		0 = [
			0 = ["x"=113, "y"=114, "prox"=-1 ],
			1 = ["x"=113, "y"=114, "prox"=-1 ],
			2 = ["x"=113, "y"=114, "prox"=115 ],
			3 = ["x"=113, "y"=114, "prox"=115 ],
			4 = ["x"=113, "y"=114, "prox"=115 ],
			5 = ["x"=113, "y"=114, "prox"=115 ]
		],
		1 = [
			0 = ["x"=113, "y"=114, "prox"=-1 ],
			1 = ["x"=113, "y"=114, "prox"=-1 ],
			2 = ["x"=113, "y"=114, "prox"=115 ],
			3 = ["x"=113, "y"=114, "prox"=115 ],
			4 = ["x"=113, "y"=114, "prox"=115 ],
			5 = ["x"=113, "y"=114, "prox"=115 ]
		]
	]
	$.side_effect_ctrl_mix = [0=116,1=116]

	$.fing_is_down = []
	for ( s=0; s<2; s++ ) {
		$.fing_is_down[s] = []
		for ( f=0; f<20; f++ ) {
			$.fing_is_down[s][f] = 0
		}
	}

	port1 = lookforandopen("output","Yoke.*1",0)
	port2 = lookforandopen("output","Yoke.*2",0)
	$.side_port = [0=port1,1=port2]

	for ( s=0; s<2; s++ ) {
		$.vst_enabled[s] = []
		for ( e=0; e<16; e++ ) {
			$.vst_enabled[s][e] = 0
		}
	}

	# $.set_track_sound(0,0,3)
	# $.set_track_sound(0,1,5)
	# $.set_track_sound(0,2,10)
	# $.set_track_sound(0,3,15)

	$.set_track_sound(0,0,0)
	$.set_track_sound(0,1,4)
	$.set_track_sound(0,2,8)
	$.set_track_sound(0,3,12)

	$.set_track_sound(1,0,2)
	$.set_track_sound(1,1,4)
	$.set_track_sound(1,2,9)
	$.set_track_sound(1,3,14)

	$.update_vst_enabled(0)
	$.update_vst_enabled(1)
	$.sendenabled()

	$.menus = [
		0=[
			0=["label"="Save ...","submenu"=1],
			1=["label"="Load ...","submenu"=2],
			2=["label"="Dummy1 ...","submenu"=3],
			3=["label"="Dummy2 ...","submenu"=4]
		],
		1=[
			0=["label"="","cmd"=""],
			1=["label"="","cmd"=""],
			2=["label"="","cmd"=""],
			3=["label"="","cmd"=""]
		],
		2=[
			0=["label"="Menu 2.1","cmd"=""],
			1=["label"="Menu 2.2","cmd"=""],
			2=["label"="Menu 2.3","cmd"=""],
			3=["label"="Menu 2.4","cmd"=""]
		],
		3=[
			0=["label"="Menu 3.1","cmd"=""],
			1=["label"="Menu 3.2","cmd"=""],
			2=["label"="Menu 3.3","cmd"=""],
			3=["label"="Menu 3.4","cmd"=""]
		],
		4=[
			0=["label"="Menu 4.1","cmd"=""],
			1=["label"="Menu 4.2","cmd"=""],
			2=["label"="Menu 4.3","cmd"=""],
			3=["label"="Menu 4.4","cmd"=""]
		]
	]
	$.current_menu = 0
	$.current_menuitem = 0
	$.menu_history = []
	$.menu_history_level = -1

	$.c = []

	# $.c["masterlcd"] = new ktext("LCD text\n12345678901234567890\n3\n4")
	# $.c["masterlcd"].setjust("left")

	# mnames = [1="BCK",2="NXT",3="ENT",4="XXX"]
	# for ( n=1; n<=4; n++ ) {
	# 	anm = "M" + string(n)
	# 	nm = anm
	# 	$.c[nm] = new kmoment(mnames[n],$,"gamebutton",anm,99)
	# }

	for ( s=0; s<2; s++ ) {
		sn = string(s)

		# anames = [1="DSP",2="NXT",3="LNG",4="CLR"]
		# for ( n=1; n<=4; n++ ) {
		# 	anm = "A" + string(n)
		# 	nm = sn + anm
		# 	$.c[nm] = new kmoment(anames[n],$,"gamebutton",anm,s)
		# }
		# tnames = [1="REC",2="NTS",3="SND",4="RFF"]
		# gnames = [1="NTS",2="RPT",3="EF1",4="EF3"]
		# for ( n=1; n<=4; n++ ) {
		# 	anm = "T" + string(n)
		# 	nm = sn + anm
		# 	$.c[nm] = new kmoment(tnames[n],$,"gamebutton",anm,s)
		# 	anm = "G" + string(n)
		# 	nm = sn + anm
		# 	$.c[nm] = new kmoment(gnames[n],$,"gamebutton",anm,s)
		# }

		$.c[sn+"lcd"] = new ktext("LCD text\n12345678901234567890\n3\n4")
		gridname = sn + "grid"
		$.c[gridname] = new wgrid(4,4)
		$.c[gridname].setborder(1)
		$.c[gridname].setcallbackdown($,"faketriggerdown",s)
		$.c[gridname].setcallbackup($,"faketriggerup",s)
		gesturename = sn + "gesture"
		$.c[gesturename] = new wgrid(1,1)
		$.c[gesturename].setborder(1)
		$.c[gesturename].setcallbackdown($,"fakegesturedown",s)
		$.c[gesturename].setcallbackup($,"fakegestureup",s)
		$.c[gesturename].setcallbackdrag($,"fakegesturedrag",s)
	}

	$.make_keyboard($.nanokey_names["L"],0)
	$.make_keyboard($.nanokey_names["R"],0)
	$.make_keyboard($.nanokey_names["L"],1)
	$.make_keyboard($.nanokey_names["R"],1)

	for ( t in $.c )
		$.addchild($.c[t])

	$.miditid = task $.task_monolith_midi()
	$.joy = getjoymonitor()
	$.joy.notify($,-1)

	# gesturenotify($)
	$.gesture_rows = 4
	$.gesture_cols = 4
	gesturenotifyrc($,$.gesture_rows,$.gesture_cols)

	Offsetfilter = 0

	# tempo(500000)

	if ( ! defined(SalvationOutput) ) {
		SalvationOutput = -1
	}

	Gesturedragthreshold = 0.0
	GestureDraglimit = 60

	Gesturedragthreshold = 0.1
	GestureDraglimit = 20

	Gesturedragthreshold = 0.02
	GestureDraglimit = 20

	$.tid = -1
	$.defaultnsteps = 64
	$.maxnsteps = 256
	$.defaultntracks = 4
	$.steptm = 1b/4
	$.nsteps = []
	$.ntracks = []
	$.currstep = []
	$.currtrack = []
	$.stepvals = []
	for ( s=0; s<2; s++ ) {
		$.nsteps[s] = $.defaultnsteps
		$.ntracks[s] = $.defaultntracks
		$.currstep[s] = 0
		$.currtrack[s] = 0
		$.stepvals[s] = []
		for ( n=0; n<$.maxnsteps; n++ ) {
			$.stepvals[s][n] = []
			for ( t=0; t<$.ntracks[s]; t++ ) {
				$.stepvals[s][n][t] = ''
			}
		}
	}

	$.allupdatetracklabels()
	$.redrawlcds()
	# $.redrawcurrentmenu()

	$.start()

	# task $.playwav("moment.wav")

	# t.waittilldone()
	# t.stop()
}

method playwav(fn) {
	playwave(fn)
}

method make_keyboard(arr,side) {
	for ( k in arr ) {
		kk = arr[k]
		cnm = string(side)+kk["name"]
		km = new kmoment(kk["name"],$,"keyboardbutton",kk["name"],side)
		$.c[cnm] = km
	}
}
method resize_keyboard(sn,arr,x0,y0,x1,y1) {
	dx = (x1-x0)/2
	dy = (y1-y0)/30
	# print("Resizing keyboard, xy0=",x0,y0," xy1=",x1,y1," dxy=",dx,dy)
	th = $.textheight()
	tw = $.textwidth()
	for ( k in arr ) {
		kk = arr[k]
		x = x0 + kk["x"] * dx
		y = y0 + kk["y"] * dy
		cnm = sn+kk["name"]
		if ( ! (cnm in $.c) ) {
			print("Hey, cnm=",cnm," not in children?")
		} else {
			c = $.c[cnm]
			# print("cnm=",cnm," sz=",x,y,x+10,y+10)
			c.resize(xy(x,y,x+8*tw,y+1.2*th))
		}
	}
}

# method reset_button_history() {
# 	$.button_history = []
# 	for ( s=0; s<2; s++ ) {
# 		$.button_history[s] = []
# 		for ( b in $.side_buttons ) {
# 			$.button_history[s] = [0=0,1=0,2=0]
# 		}
# 	}
# }

method set_effect(s,eff) {
	eff = eff % ($.neffects + 1)
	$.side_effect[s] = eff
}
method set_track_sound(s,trk,vstnum) {
	$.track_vst[s][trk] = vstnum
	# print("Setting track_vst s=",s," trk=",trk," to vstnum=",vstnum)
}

method get_track_sound(s,trk) {
	return($.track_vst[s][trk])
}

method update_vst_enabled(side) {
	# zero them all out
	for ( vstnum=0; vstnum<16; vstnum++ ) {
		$.vst_enabled[side][vstnum] = 0
	}
	# then enable the vsts used in each track
	for ( t=0; t<4; t++ ) {
		vstnum = $.track_vst[side][t]
		$.vst_enabled[side][vstnum] = 1
	}
}

method allupdatetracklabels {
	for ( s=0; s<2; s++ ) {
		$.updatetracklabels(s)
	}
}
method updatetracklabels(s) {
	for ( t=0; t<4; t++ ) {
		$.updatetracklabel(s,t)
	}
}

method updatetracklabel(s,t) {
	v = $.track_vst[s][t]
	if ( v < 0 ) {
		vn = "Empty"
	} else {
		vn = $.vst_desc[s][v]["name"]
	}
	# print("v=",v," vn=",vn)
	# nn = $.valsintrack(s,t)
	# str = sprintf("T%1d %2d Snd=%7s ",t,nn,vn)
	str = sprintf("Trk=%1d Snd=%7s ",(t+1),vn)
	$.lcd_labels[s][t] = str
}
method redrawcurrentindicator(s) {
	t = $.currtrack[s]
	# to avoid flashing real lcd, just update << part
	for ( r=0; r<4; r++ ) {
		if ( t == r ) {
			cs = "<<"
		} else {
			cs = "  "
		}
		mdep("lcd","write",$.lcd_index[s],cs,r,18)
	}
	$.redrawfakelcd(s)
}

method redrawlcds {
	for ( s=0; s<2; s++ ) {
		$.redrawlcd(s)
	}
}

method trackline(s,t) {
	c = $.currtrack[s]
	if ( c == t ) {
		cs = "<<"
	} else {
		cs = "  "
	}
	lbl = $.lcd_labels[s][t]+cs
	return(lbl)
}

method redrawlcd(s) {
	$.redrawreallcd(s)
	$.redrawfakelcd(s)
}

method redrawlcdtrack(s,trk) {
	$.redrawfakelcd(s)  # just redraw all of them
	$.redrawreallcdtrack(s,trk)
}

method setfakelcd(s,lbl) {
	if ( FakeLCD == 0 )
		return()
	t = $.c[string(s)+"lcd"]
	t.set(lbl)
	t.redraw()
}

method redrawfakelcd(s) {
	lbl = $.trackline(s,0)+"\n"
		+$.trackline(s,1)+"\n"
		+$.trackline(s,2)+"\n"
		+$.trackline(s,3)
	$.setfakelcd(s,lbl)
}

# method redrawcurrentmenu {
# 	if ( FakeLCD == 0 )
# 		return()
# 	t = $.c["masterlcd"]
# 	m = $.menus[$.current_menu]
# 	lbl = ""
# 	for ( r=0; r<4; r++ ) {
# 		s = m[r]["label"]
# 		if ( r == $.current_menuitem )
# 			arrow = "<<"
# 		else
# 			arrow = "  "
# 		lbl += sprintf("  %-15s %2s",s,arrow)
# 		if ( r<3 )
# 			lbl += "\n"
# 	}
# 	t.set(lbl)
# 	t.redraw()
# 
# 	mdep("lcd","clear",$.lcd_index[2])
# 	mdep("lcd","backlight",$.lcd_index[2],$.backlight())
# 	for ( r=0; r<4; r++ ) {
# 		lbl = m[r]["label"]
# 		if ( r == $.current_menuitem )
# 			lbl += "<<"
# 		mdep("lcd","write",$.lcd_index[2],lbl,r,0)
# 	}
# }

method redrawreallcd(s) {
	mdep("lcd","clear",$.lcd_index[s])
	mdep("lcd","backlight",$.lcd_index[s],$.backlight())
	for ( r=0; r<4; r++ ) {
		$.redrawreallcdtrack(s,r)
	}
}

method backlight() {
	# should be time-dependent
	return(1)
}
method redrawreallcdtrack(s,trk) {
	mdep("lcd","write",$.lcd_index[s],$.trackline(s,trk),trk,0)
}

method delete {
	kill($.miditid)
	delete Midiin[$]
	$.joy.unnotify($,-1)
	gestureunnotify($)
	$.stop()
}

method sendenabled {
	for ( s=0; s<2; s++ ) {
		$.sendenabled_side(s)
	}
}

method adjusteffect_side(side,eff,onoff) {
	if ( onoff ) {
		v = 0
	} else {
		v = 127
	}
	p = controller(eff,112,v)
	# print("adjusteffect_side side=",side," eff=",eff," onoff=",onoff," v=",v)
	p.port = $.side_port[side]
	# print("ADJUSTEFFECT_SIDE p=",p)
	$.realtime_now(p)
}

method sendenabled_side(side) {
	$.sendenabled_side_effect(side)
	$.sendenabled_side_vst(side)
}
method sendenabled_side_effect(side) {
	eff = $.side_effect[side]
	# enable/disable the effect modules
	for ( e=1; e<=$.neffects; e++ ) {
		if ( e != eff ) {
			v = 40
		} else {
			v = 127
		}
		p = controller(e,112,v)
		p.port = $.side_port[side]
		$.realtime_now(p)
	}
	#change the audio switchers
	# Change the two audio switchers
	v = eff * 8 + 4
	p1 = controller(1,109,v)
	p2 = controller(1,110,v)
	p1.port = $.side_port[side]
	p2.port = $.side_port[side]
	$.realtime_now(p1)
	$.realtime_now(p2)
}

method sendenabled_side_vst(side) {
	for ( vstnum=0; vstnum<16; vstnum++ ) {
		if ( $.vst_enabled[side][vstnum] == 0 ) {
			v = 40
		} else {
			v = 0
		}
		# print("Sending v=",v," for side=",side," vstnum=",vstnum)
		p = controller(1 + vstnum,111,v)
		p.port = $.side_port[side]
		$.realtime_now(p)
	}
}

method redraw {
	$.w.redraw()
	methodbroadcast()
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)

	th = $.textheight()
	tw = $.textwidth()
	x00 = x0 = $.xmin()+2
	y00 = y0 = $.ymin()+2 + 5*th
	x01 = x1 = $.xmax()-2
	y01 = y1 = $.ymax()-2
	xmid = (x0+x1)/2
	ymid = (y00+y01)/2
	dx = (x1-x0) / 28
	dy = (y01-y00) / 24

	lcdx0 = xmid-11*tw
	lcdx1 = xmid+11*tw
	lcdy0 = $.ymin()+dy+4
	lcdy1 = $.ymin()+5*dy
	lcdym = (lcdy0+lcdy1)/2

	# for ( n=1; n<=2; n++ ) {
	# 	$.c["M"+string(n)].resize(xy(lcdx0-(3-n)*dx-2,lcdym-th,lcdx0-(2-n)*dx-2,lcdym+th))
	# }
	# for ( n=3; n<=4; n++ ) {
	# 	$.c["M"+string(n)].resize(xy(lcdx1+(n-3)*dx+2,lcdym-th,lcdx1+(n-2)*dx+2,lcdym+th))
	# }

	# $.c["masterlcd"].resize(xy(lcdx0,lcdy0,lcdx1,lcdy1))

	kwidth = 18 * tw
	for ( s=0; s<2; s++ ) {
		sn = string(s)
		if ( s == 0 ) {
			x0 = x00 + kwidth
			x1 = xmid-2 - kwidth
		} else {
			x0 = xmid+2 + kwidth
			x1 = x01 - kwidth
		}
		xm = (x0+x1)/2
		ym = (y0+y1)/2
		lcdx0 = xm-11*tw
		lcdx1 = xm+11*tw
		lcdy0 = y0+1*dy+4
		lcdy1 = y0+5*dy
		lcdym = (lcdy0+lcdy1)/2

		# for ( n=1; n<=2; n++ ) {
		# 	$.c[sn+"A"+string(n)].resize(xy(lcdx0-(3-n)*dx-2,lcdym-th,lcdx0-(2-n)*dx-2,lcdym+th))
		# }
		# for ( n=3; n<=4; n++ ) {
		# 	$.c[sn+"A"+string(n)].resize(xy(lcdx1+(n-3)*dx+2,lcdym-th,lcdx1+(n-2)*dx+2,lcdym+th))
		# }

		# for ( n=1; n<=4; n++ ) {
		# 	$.c[sn+"T"+string(n)].resize(xy(x0+4+(n-1)*dx,y1-2,x0+(n)*dx,y1-2-dy))
		# }

		# for ( n=1; n<=4; n++ ) {
		# 	$.c[sn+"G"+string(n)].resize(xy(x1-(5-n)*dx,y1-2,x1-4-(4-n)*dx,y1-2-dy))
		# }

		$.c[sn+"lcd"].resize(xy(lcdx0,y0+1*dy+4,lcdx1,y0+5*dy))
		$.c[sn+"grid"].resize(xy(x0+4,y0+7*dy+4,xm-1*tw,y1-4-dy))
		$.c[sn+"gesture"].resize(xy(xm+1*tw,y0+7*dy+4,x1-4,y1-4-dy))

		ky0 = y0 + 7*dy + 4
		ky1 = y1 - 4 - dy
		$.resize_keyboard(sn,$.nanokey_names["L"],x0-kwidth+2,ky0,x0,ky1)
		$.resize_keyboard(sn,$.nanokey_names["R"],x1,ky0,x1+kwidth-2,ky1)
	}

}
method dump {
	return([])
}
method restore(state) {
}

method set_tempo() {
	b = $.bpm_values[$.bpm_index]
	print("b=",b)
	bpm($.bpm_values[$.bpm_index])
}

method show_fade(side) {
	msg = $.fade_message[$.fade_index]
	$.lcd_message(side,msg)
}

method show_padmode(side) {
	msg = $.padmode_message[$.side_effect[side]]
	$.lcd_message(side,msg)
}

method show_tempo(side) {
	b = round(60/(tempo()/1000000.0))
	msg = sprintf("Tempo is now\n%d\nbeats per minute",b)
	$.lcd_message(side,msg)
}

method show_octave(side,trk) {
	oct = $.track_octave[side][trk]
	$.lcd_message(side,sprintf("Track %d\nis %s",(trk+1),$.octave_names[oct]))
}

method lcd_message(side,msg) {
	# print("LCD_MESSAGE!  msg=",msg," side=",side," lcd_index=",$.lcd_index[side])
	mdep("lcd","clear",$.lcd_index[side])
	lines = split(msg,"\n")
	nlines = sizeof(lines)
	if ( nlines < 3 )
		linenum = 1
	else
		linenum = 0
	for ( n=0; n in lines; n++ ) {
		str = lines[n]
		colnum = (20 - sizeof(str))/2
		if ( colnum < 0 )
			colnum = 0
		if ( linenum > 3 )
			linenum = 3
		# print("lcd_message write linenum=",linenum,"colnum=",colnum)
		mdep("lcd","write",$.lcd_index[side],str,linenum,colnum)
		linenum++
	}
	$.setfakelcd(side,msg)
}
method is_drum(side,trk) {
	v = $.track_vst[side][trk]
	vt = $.vst_desc[side][v]["type"]
	return ( vt == "drum" )
}
method keyboardbutton(v,bnm,side) {
	if ( v == 0 ) {
		$.redrawlcd_time[side] = milliclock() + $.lcdtimeout
		return()
	}
	if ( DebugMonolith ) {
		print("keyboardbutton v=",v," bnm=",bnm," side=",side)
	}
	trk = $.currtrack[side]
	if ( bnm == "Rec on/off" ) {
		if ( $.is_recording[side] != 0 )
			r = 0
		else {
			r = 1
		}
		$.is_recording[side] = r
		$.lcd_message(side,"Loop Recording \nis "+(r?"ON":"OFF"))
	# } else if ( bnm == "Rec off" ) {
	# 	$.is_recording[side] = 0
	# } else if ( bnm == "Pad Notes" ) {
	# 	$.side_pad_is_notes[side] = 1
	# } else if ( bnm == "Pad Effects" ) {
	# 	$.side_pad_is_notes[side] = 0
	} else if ( bnm == "Fade Quicker" ) {
		f = $.fade_index + 1
		sz = sizeof($.fade_vals)
		if ( f >= sz )
			f = sz-1
		$.fade_index = f
		print("fade_index = ",$.fade_index," val=",$.fade_vals[$.fade_index])
		$.show_fade(side)
	} else if ( bnm == "Fade Slower" ) {
		f = $.fade_index - 1
		if ( f < 0 )
			f = 0
		$.fade_index = f
		print("fade_index = ",$.fade_index," val=",$.fade_vals[$.fade_index])
		$.show_fade(side)
	} else if ( bnm == "AutoTrans" ) {
		$.autotrans = 1 - $.autotrans
		if ( $.autotrans ) {
			# always start back at first
			$.transpose_index = 0
			$.transpose_counter = 0
		} else {
			$.transpose_index = 0
			$.transpose_counter = 0
		}
		$.transpose_current = $.transpose_sequence[$.transpose_index]
		$.lcd_message(side,"Auto Key Changing\nis "+($.autotrans?"ON":"OFF"))
	# } else if ( bnm == "No AutoTrans" ) {
	# 	$.autotrans = 0
	# 	$.transpose_index = 0
	# 	$.transpose_current = 0
	# 	$.lcd_message(side,"Auto Key Changing\nis OFF")
	} else if ( bnm == "Faster" ) {
		$.bpm_index++
		sz = sizeof($.bpm_values) -1
		if ( $.bpm_index > sz )
			$.bpm_index = sz
		$.set_tempo()
		$.show_tempo(side)
	} else if ( bnm == "Slower" ) {
		$.bpm_index--
		if ( $.bpm_index < 0 )
			$.bpm_index = 0
		$.set_tempo()
		$.show_tempo(side)
	} else if ( bnm == "Chng Snd" ) {
		snd = $.get_track_sound(side,trk)
		snd++
		if ( snd >= 16 )
			snd = 0
		$.select_soundnum(side,trk,snd)
		v = $.track_vst[side][trk]
		vn = $.vst_desc[side][v]["name"]
		$.lcd_message(side,sprintf("Track %d\nhas the sound\n%s",trk+1,vn))
	} else if ( bnm == "Reset Snd" ) {
		$.select_soundnum(side,trk,0)
		v = $.track_vst[side][trk]
		vn = $.vst_desc[side][v]["name"]
		$.lcd_message(side,sprintf("Track %d\nsound is reset to\n%s",trk+1,vn))
	} else if ( bnm == "Random Snds" ) {
		ntrks = $.ntracks[side]
		for ( t=0; t<ntrks; t++ ) {
			sn = rand(16)
			$.select_soundnum(side,t,sn)
		}
		$.lcd_message(side,"All track sounds\nhave been\nrandomized")
		# $.updatetracklabels(side)
	} else if ( bnm == "Scale Nxt" ) {
		si = $.side_scale_index[side] + 1
		if ( si >= sizeof($.scale_names) ) {
			si = 0
		}
		$.side_scale_index[side] = si
		print("SCALE INDEX = ",si)
		$.lcd_message(side,sprintf("Scale = %s",$.scale_names[si]))
		$.make_noteset_scale(side)
	} else if ( bnm == "Scale Reset" ) {
		$.side_scale_index[side] = 0
		$.make_noteset_scale(side)
		$.lcd_message(side,sprintf("Scale = %s",$.scale_names[0]))
	} else if ( bnm == "Chord Nxt" ) {
		ci = $.side_chord_index[side] + 1
		if ( ci >= sizeof($.chord_names) )
			ci = 0
		$.side_chord_index[side] = ci
		$.lcd_message(side,sprintf("Chord = %s",$.chord_names[ci]))
		$.make_noteset_scale(side)
	} else if ( bnm == "Chord Reset" ) {
		$.side_chord_index[side] = 0
		$.make_noteset_scale(side)
		$.lcd_message(side,sprintf("Chord = %s",$.chord_names[0]))
	} else if ( bnm == "Longer Loop" ) {
		ntrks = $.ntracks[side]
		ns = $.nsteps[side]
		newns = $.nsteps[side] * 2
		if ( newns > $.maxnsteps )
			newns = $.maxnsteps
		# Duplicate existing loop to make it longer
		if ( newns != ns ) {
			for ( trk=0; trk<ntrks; trk++ ) {
				for ( n=0; n<ns; n++ ) {
					$.stepvals[side][ns+n][trk] = $.stepvals[side][n][trk]
				}
			}
		}
		$.nsteps[side] = newns
		$.lcd_message(side,sprintf("Loop is now %d steps",newns))
	} else if ( bnm == "Shorter Loop" ) {
		ns = $.nsteps[side] / 2
		if ( ns < 16 )
			ns = 16
		$.nsteps[side] = ns
		$.lcd_message(side,sprintf("Loop is now %d steps",ns))
	} else if ( bnm == "Fewer Nts" ) {
		nd = 0
		ns = $.nsteps[side]
		ntrks = $.ntracks[side]
		for ( trk=0; trk<ntrks; trk++ ) {
			for ( n=0; n<ns; n++ ) {
				p = $.stepvals[side][n][trk]
				if ( p != '' ) {
					if ( (n%4) == 0 )
						r = 16
					else
						r = 5
					if ( rand(r) == 0 ) {
print("Removing note n=",n," trk=",trk)
						$.stepvals[side][n][trk] = ''
						nd++
					}
				}
			}
		}
		$.lcd_message(side,sprintf("%d notes were deleted",nd))
		$.updatetracklabels(side)
	} else if ( bnm == "Octave Up" ) {
		o = $.track_octave[side][trk] + 1
		if ( o > 3 )
			o = 3
		$.track_octave[side][trk] = o
		$.show_octave(side,trk)
	} else if ( bnm == "Octave Down" ) {
		o = $.track_octave[side][trk] - 1
		if ( o < -3 )
			o = -3
		$.track_octave[side][trk] = o
		$.show_octave(side,trk)
	} else if ( bnm == "PadMd Nxt" ) {
		$.set_effect(side,1 + $.side_effect[side])
		$.sendenabled_side_effect(side)
		$.show_padmode(side)
	} else if ( bnm == "PdMod Reset" ) {
		$.set_effect(side,0)
		$.sendenabled_side_effect(side)
		$.show_padmode(side)
	} else if ( bnm == "Track 1" ) {
		$.settrack(side,0)
		$.redrawcurrentindicator(side)
	} else if ( bnm == "Track 2" ) {
		$.settrack(side,1)
		$.redrawcurrentindicator(side)
	} else if ( bnm == "Track 3" ) {
		$.settrack(side,2)
		$.redrawcurrentindicator(side)
	} else if ( bnm == "Track 4" ) {
		$.settrack(side,3)
		$.redrawcurrentindicator(side)
	} else if ( bnm == "Silnc Track" ) {
		$.clearonetrack(side,trk,0)
		$.lcd_message(side,sprintf("Track %d\nhas been cleared.",trk+1))
	} else if ( bnm == "Silnc All" ) {
		for ( t=0; t<4; t++ ) {
			$.clearonetrack(side,t,0)
		}
		$.transpose_index = 0
		$.transpose_counter = 0
		$.send_ano()
		$.lcd_message(side,"All Tracks\nhave been cleared!")
	} else if ( bnm == "Reset All" ) {
		$.lcd_message(side,"RESET ALL\nSound, Scale, Chord,\nLoop Length, etc.\nhave all been reset")
		$.send_ano()
		$.set_effect(side,0)
		$.sendenabled_side_effect(side)
		$.side_chord_index[side] = 0
		$.side_scale_index[side] = 0
		$.make_noteset_scale(side)
		$.is_recording[side] = $.default_is_recording

		$.nsteps[side] = $.defaultnsteps
		$.currstep[side] = 0
		$.currtrack[side] = 0

		$.side_fingersdown[side] = 0

		for ( t=0; t<4; t++ ) {
			$.track_octave[side][t] = 0
			$.clearonetrack(side,t,0)
			$.select_soundnum(side,t,4*t)
		}
		$.autotrans = $.default_autotrans
		$.transpose_index = 0
		$.transpose_counter = 0
	} else {
		$.lcd_message(side,"THAT BUTTON\nDOES NOTHING")
	}
}
# method gamebutton(v,bnm,side) {
# 
# 	nm = $.gamebutton_name[bnm]
# 	# print("gamebutton v=",v," bnm=",bnm," side=",side," nm=",nm)
# 
# 	v = (v!=0)  # make sure it's 1 or 0
# 
# 	if ( side == 99 ) {
# 		if ( v == 0 )
# 			return()
# 		# it's a master button
# 		print("Master button bnm=",bnm," nm=",nm)
# 		if ( nm == "BCK" ) {
# 			if ( $.menu_history_level >= 0 ) {
# 				$.menu_history_level--
# 				if ( $.menu_history_level < 0 )
# 					$.current_menu = 0
# 				else
# 					$.current_menu = $.menu_history[$.menu_history_level]
# 			}
# 			$.redrawcurrentmenu()
# 		} else if ( nm == "NXT" ) {
# 			while (1) {
# 				$.current_menuitem++
# 				if ( $.current_menuitem >= 4 )
# 					$.current_menuitem = 0
# 				if ( $.menus[$.current_menu][$.current_menuitem]["label"] != "" )
# 					break
# 			}
# 			$.redrawcurrentmenu()
# 		} else if ( nm == "ENT" ) {
# 			m = $.menus[$.current_menu][$.current_menuitem]
# 			print("m=",m)
# 			if ( "submenu" in m ) {
# 				$.menu_history_level++
# 				$.menu_history[$.menu_history_level] = $.current_menu
# 				$.current_menu = m["submenu"]
# 				$.redrawcurrentmenu()
# 			} else if ( "cmd" in m ) {
# 				cmd = m["cmd"]
# 				if ( cmd != "" )
# 					$.(cmd)()
# 			} else {
# 				print("No cmd or submenu !?")
# 			}
# 		}
# 		return()
# 	}
# 
# 	if ( nm == "REC" ) {
# 		$.is_recording[side] = v
# 		# print("is_recording = ",$.is_recording)
# 	} else if ( nm == "NTS" ) {
# 		$.is_selectingnotes[side] = v
# 	} else if ( nm == "SND" ) {
# 		$.is_selectingsound[side] = v
# 	} else if ( nm == "RFF" ) {
# 		$.is_selectingriff[side] = v
# 	}
# 
# 	if ( v == 0 )
# 		return()
# 
# 	# It's a side button, down
# 
# 	# hist = $.button_history[side]
# 	# hist[2] = hist[1]
# 	# hist[1] = hist[0]
# 	# hist[0] = Now
# 
# 	if ( nm == "CLR" ) {
# 		$.clearonetrack(side,$.currtrack[side])
# 	} else if ( nm == "NXT" ) {
# 		$.nexttrack(side)
# 		$.redrawcurrentindicator(side)
# 	}
# }
method clearonetrack(side,trk,doredraw) {
	# print("Clearing track=",trk," on side=",side)
	$.cleartrack(side,trk)
	$.updatetracklabel(side,trk)
	if ( doredraw ) {
		$.redrawlcdtrack(side,trk)
	}
}
method buttonchange(jn,nm,v) {
	print("button change jn=",jn," nm=",nm," v=",v)
}
method analogchange(jn,nm,v) {
	print("analog change jn=",jn," nm=",nm," v=",v)
}
method xy_to_rowcol(x,y,nrows,ncols) {
	row = 0
	col = 0
	while ( col < (ncols-1) && x > (1.0/ncols) * (col+1) )
		col++
	while ( row < (nrows-1) && y > (1.0/nrows) * (row+1) )
		row++
	# flip y direction
	row = (nrows-1) - row
	return(["row"=row,"col"=col])
}
method fakegesturedown(m,v,s) {
	fingid = 1
	prox = 1.5
	$.dogesturedown(fingid,m["relx"],m["rely"],s,prox)
}
method prox2vol(prox) {
	proxmode = 3
	v = 127
	if (proxmode == 0 ) {
		v = integer(prox * 50.0)
	} else if ( proxmode == 1 ) {
		v = integer((prox*prox) * 40.0)
	} else if ( proxmode == 2 ) {
		v = integer((prox+0.1) * 50.0)
	} else if ( proxmode == 3 ) {
		v = integer((((prox+1)*(prox+1))-1) * 20.0)
	}
	if ( v > 127 )
		v = 127
	# print("prox=",prox," v=",v)
	return(v)
}
method prox2ctrl(prox) {
	v = integer(prox * 60.0)
	if ( v > 127 )
		v = 127
	# print("prox2ctrl prox=",prox," v=",v)
	return(v)
}
method dogesturedown(fingid,relx,rely,side,prox) {
	$.side_fingersdown[side]++
	eff = $.side_effect[side]
	if ( eff == 0 ) {
		a = $.xy_to_rowcol(relx,rely,$.gesturerows,$.gesturerows)
		print("dogesturedown note row/col=",a["row"],a["col"])
		# print("typeof prox = ",typeof(prox))
		# print("prox = ",prox)
		vol = $.prox2vol(prox)
		$.fing_is_down[side][fingid] = a
		$.dogriddown(side,a["row"],a["col"],vol,$.noteset_gesture[side],"gesture")
	} else {
		# print("dogesturedown effect")
		if ( $.side_fingersdown[side] == 1 ) {
			# print("dogesturedown TURNING ON EFFECT")
			eff = $.side_effect[side]
			$.adjusteffect_side(side,eff,1)
			$.do_eff(eff,relx,rely,side,prox)
		}
	}
}
method fakegesturedrag(m,v,s) {
	fingid = 1
	prox = 1.5
	$.dogesturedrag(fingid,m["relx"],m["rely"],s,prox)
}

method do_eff(eff,relx,rely,side,prox) {

	ch = eff
	port = $.side_port[side]

	# print("dogesturedrag effect relxy=",relx,rely," prox=",prox)
	v1 = integer(relx * 128) % 128
	v2 = integer(rely * 128) % 128
	v3 = $.prox2ctrl(prox)

	ctrl1 = $.side_effect_ctrl[side][eff]["x"]
	if ( ctrl1 > 0 ) {
		p1 = controller(ch,ctrl1,v1)
		p1.port = port
		$.realtime_now(p1)
	}

	ctrl2 = $.side_effect_ctrl[side][eff]["y"]
	if ( ctrl2 > 0 ) {
		p2 = controller(ch,ctrl2,v2)
		p2.port = port
		$.realtime_now(p2)
	}

	ctrl3 = $.side_effect_ctrl[side][eff]["prox"]
	if ( ctrl3 > 0 ) {
		p3 = controller(ch,ctrl3,v3)
		p3.port = port
		$.realtime_now(p3)
	}

	# prox does both ctrl3 and mix.  Note mix is always ch 1
	ctrlmix = $.side_effect_ctrl_mix[side]
	pmix = controller(1,ctrlmix,v3)
	pmix.port = port
	$.realtime_now(pmix)
}

method dogesturedrag(fingid,relx,rely,side,prox) {
	eff = $.side_effect[side]
	if ( eff == 0 ) {
		a = $.xy_to_rowcol(relx,rely,$.gesturerows,$.gesturecols)
		# print("dogesturedrag note row/col=",a["row"],a["col"])
		olda = $.fing_is_down[side][fingid]
		if ( olda == 0 ) {
			print("Hey, olda is 0 for fingid = ",fingid)
			return()
		}
		if ( olda["row"] != a["row"] || olda["col"] != a["col"] ) {
			# print("NEW ROW/COL!")
			$.dogridup(side,olda["row"],olda["col"],"gesture")

			vol = $.prox2vol(prox)
			$.fing_is_down[side][fingid] = a
			$.dogriddown(side,a["row"],a["col"],vol,$.noteset_gesture[side],"gesture")
		}
	} else {
		$.do_eff(eff,relx,rely,side,prox)
	}
}
method fakegestureup(m,v,s) {
	fingid = 1
	prox = 0.0
	$.dogestureup(fingid,m["relx"],m["rely"],s,prox)
}
method dogestureup(fingid,relx,rely,side,prox) {

	fd = $.side_fingersdown[side] - 1
	if ( fd < 0 )
		fd = 0
	$.side_fingersdown[side] = fd

	eff = $.side_effect[side]
	if ( eff == 0 ) {
		olda = $.fing_is_down[side][fingid]
		# print("dogestureup note olda=",olda," side=",side)
		if ( olda == 0 ) {
			print("Hey, olda is 0 in dogestureup!?")
			return()
		}
		$.dogridup(side,olda["row"],olda["col"],"gesture")
		$.fing_is_down[side][fingid] = 0
	} else {
		if ( $.side_fingersdown[side] == 0 ) {

			# put mix all the way down (to dry)
			ctrlmix = $.side_effect_ctrl_mix[side]
			pmix = controller(1,ctrlmix,0)
			$.realtime_now(pmix)

			# print("dogestureup TURNING OFF EFFECT")
			eff = $.side_effect[side]
			$.adjusteffect_side(side,eff,0)
		}
	}
}
method chanfortrack(side,trk) {
	vstnum = $.get_track_sound(side,trk)
	return(1+vstnum)
}

method select_soundnum(side,trk,soundnum) {
	# print("Selecting sound = ",soundnum)

	$.set_track_sound(side,trk,soundnum)
	$.update_vst_enabled(side)
	$.sendenabled_side(side)

	$.updatetracklabel(side,trk)

	# $.sendenabled()
}

method faketriggerdown(m,mm,side) {
	vol = 20 + rand(80)
	$.dogriddown(side,3-m["row"],m["col"],vol,$.noteset_trigger[side],"trigger")
}
method faketriggerup(m,mm,side) {
	$.dogridup(side,3-m["row"],m["col"],"trigger")
}

method make_noteset_scale(side) {

	lock($)

	scaleindex = $.side_scale_index[side]
	sn = $.scale_names[scaleindex]
	sc = $.scale_notes[sn]
	print("MAKING SCALE index = ",scaleindex," name=",sn," notes=",sc)
	scsize = sizeof(sc)

	chordindex = $.side_chord_index[side]
	chord = $.chord_notes[$.chord_names[chordindex]]

	$.noteset_trigger[side] = []
	pitch0 = 'co2'.pitch
	octave = 0
	scpos = 0
	ncols = 4
	nrows = 4

	for (r=0; r<nrows; r++ ) {
		$.noteset_trigger[side][r] = []
		for (c=0; c<ncols; c++ ) {
			p = chord
			thispitch = pitch0+(octave*12)+(sc%(1+scpos))
			p.pitch += thispitch
			$.noteset_trigger[side][r][c] = p
			scpos++
			if ( scpos >= scsize ) {
				octave++
				scpos = 0
			}
		}
	}

	$.noteset_gesture[side] = []
	pitch0 = 'co2'.pitch
	octave = -1
	if ( scsize < 5 )
		octave = -2
	print("MAKE_NOTESET_SCALE Starting at octave = ",octave)
	scpos = 0
	ncols = $.gesturecols
	nrows = $.gesturerows

	for (r=0; r<nrows; r++ ) {
		$.noteset_gesture[side][r] = []
		for (c=0; c<ncols; c++ ) {
			p = chord
			thispitch = pitch0+(octave*12)+(sc%(1+scpos))
			p.pitch += thispitch
			$.noteset_gesture[side][r][c] = p
			scpos++
			if ( scpos >= scsize ) {
				octave++
				scpos = 0
			}
		}
	}
	unlock($)
	# print("NOTESET_TRIGGER = ",$.noteset_trigger[side])
	# print("NOTESET_GESTURE = ",$.noteset_gesture[side])
}

method dogriddown(side,row,col,vol,noteset,tt) {

	if ( DebugMonolith ) {
		print("dogriddown side/row/col=",side,row,col," noteset=",noteset)
	}
	if ( $.current_down_step[tt][side][row][col] >= 0 ) {
		# print("WARNING WARNING - simultaneous griddown row/col=",row,col," not yet supported!")
		return()
	}

	lock($)

	trk = $.currtrack[side]
	isdrum = $.is_drum(side,trk)

	cstep = $.currstep[side]
	ns = $.step_after(side,cstep)
	# print("fakedown rc=",row,col," step=",cstep," ns=",ns)

	# print("Setting paddown ns=",ns)

	if ( isdrum ) {
		p = makenote($.drum_pitch0 + row*4 + col)
	} else {
		p = noteset[row][col]
	}
	if ( ! isdrum ) {
		# non-drum sounds can be transposed
		p.pitch += 12*$.track_octave[side][trk]
	}
	p.vol = vol
	p.type = NOTEON

	if ( isdrum ) {
		transposed = p
		transposed.vol += $.drum_voloffset
	} else {
		transposed = $.dotranspose(p)
		# print("Griddown, Not drum, transposing")
		transposed.vol += $.nondrum_voloffset
	}


	if ( $.is_recording[side] ) {

		$.track_playnote_at(side,trk,transposed,$.nextstep_tm)

		if ( $.showbusy ) {
			# THIS SHOULD BE CHANGED TO JUST REDRAW NNOTES VALUE
			$.updatetracklabel(side,trk)
			$.redrawlcdtrack(side,trk)
		}
	} else {
		# print("Playing NOTEON transpose = ",transposed," pitch=",transposed.pitch)
		# print("Playing NOTEON at nextstep_tm=",$.nextstep_tm)
		$.track_playnote_at(side,trk,transposed,$.nextstep_tm)
	}
	$.current_down_phr[tt][side][row][col] = transposed
	# print("Setting current_triggerdown_phr to transposed=",transposed)
	$.current_down_phr_notranspose[tt][side][row][col] = p
	$.current_down_step[tt][side][row][col] = ns
	$.current_down_trk[tt][side][row][col] = trk

	unlock($)
}
method dogridup(side,row,col,tt) {

	lock($)

	downstep = $.current_down_step[tt][side][row][col]
	if ( downstep < 0 ) {
		# print("Hey! No paddown step value?")
		unlock($)
		return()
	}

	trk = $.current_down_trk[tt][side][row][col]
	if ( trk < 0 ) {
		# print("Hey! No paddown trk value?")
		unlock($)
		return()
	}

	nstep = $.nextstep(side)
	if ( downstep == nstep ) {
		# nstep = $.step_after(side,nstep)
		# print("updown same step, setting short dur")
		thisdur = $.steptm
		playofftm = $.nextstep_tm+thisdur
	} else {
		nsteps = nstep - downstep
		if ( nsteps < 0 ) {
			nsteps = $.nsteps[side] + nsteps
		}
		thisdur = $.steptm * nsteps
		# print("not same step, steptm=",$.steptm," nsteps=",nsteps)
		playofftm = $.nextstep_tm+2
	}
	# print("thisdur=",thisdur)

	p = $.current_down_phr[tt][side][row][col]
	p.type = NOTEOFF
	p.chan = $.chanfortrack(side,trk)
	p.port = $.side_port[side]

	# print("Playting NOTEOFF at playofftm=",playofftm)
	task $.realtime_at(p,playofftm)

	if ( $.is_recording[side] ) {

		p2 = $.current_down_phr_notranspose[tt][side][row][col]
		p2.type = NOTE
		p2.dur = thisdur
		# print("Setting dur A to ",thisdur)
		$.setstep(downstep,side,trk,p2)
	}

	$.current_down_phr_notranspose[tt][side][row][col] = ''
	$.current_down_phr[tt][side][row][col] = ''
	$.current_down_step[tt][side][row][col] = -1

	unlock($)
}
method track_playnote_at(side,trk,p,tm) {
	# print("track_playnote_at p.pitch=",p.pitch," p=",p," tm=",tm)

	p.chan = $.chanfortrack(side,trk)
	p.port = $.side_port[side]
	# print("track noteon p=",p)
	tid = task $.realtime_at(p,tm)
}
# method track_playnote(side,trk,p) {
# 	print("track_playNOTE p.pitch=",p.pitch)
# 	p.chan = $.chanfortrack(side,trk)
# 	p.port = $.side_port[side]
# 	p.type = NOTE
# 	p.dur = $.steptm/2
# 	# print("track note! p=",p)
# 	tid = task $.realtime_at(p,$.nextstep_tm)
# }
# method track_playnoteoff(side,trk) {
# 	print("track_playnoteoff is disabled!")
# 	return()
# 
# 	oldp.type = NOTEOFF
# 	# print("track noteoff! oldp=",oldp)
# 	tid = task $.realtime_at(oldp,$.nextstep_tm)
# }
method realtime_at(p,tm) {
	sleeptill(tm)
	# print("realtime_at tm=",tm," playing p=",p)
	realtime(p)
}

# method realtime_nextstep(p) {
# 	# print("realtime_nextstep p=",p," Now=",Now," nextstep_tm=",$.nextstep_tm," dt=",($.nextstep_tm - Now))
# 	sleeptill($.nextstep_tm)
# 	print("realtime_nextstep playing p=",p)
# 	realtime(p)
# }
# method realtime_nextstep1(p) {
# 	# print("realtime_nextstep p=",p," Now=",Now," nextstep_tm=",$.nextstep_tm," dt=",($.nextstep_tm - Now))
# 	sleeptill($.nextstep_tm+2)
# 	print("realtime_nextstep1 playing p=",p)
# 	realtime(p)
# }
method realtime_now(p) {
	return(realtime(p))
}
method realtime_now1(p) {
	return(realtime(p,Now+1b/8))
}
method gotgesture(d) {
	print("gotgesture d=",d)
}
method gotgesturerc(type,dev,f,r,c,prox,rawx,rawy) {
	rawy = 1.0 - rawy
	istop = 0
	if ( dev == Gesture0T || dev == Gesture0B ) {
		side = 0
		if ( dev == Gesture0T )
			istop = 1
	} else {
		side = 1
		if ( dev == Gesture1T )
			istop = 1
	}
	# print("gotgesturerc type=",type," dev=",dev," side=",side," f=",f," prox=",prox," rc=",r,c," rawx=",rawx," rawy=",rawy)
	# print("GOTGESTURE type=",type," side=",side," istop=",istop)
	if ( type == "fingerdown" ) {
		$.dogesturedown(f,rawx,rawy,side,prox)
	} else if ( type == "fingerdrag" ) {
		$.dogesturedrag(f,rawx,rawy,side,prox)
	} else if ( type == "fingerup" ) {
		$.dogestureup(f,rawx,rawy,side,prox)
	}
}
method task_monolith_midi() {
	Midiin[$] = f = open()
	while ( (nt=get(f)) != Eof ) {
		ntype = nt.type
		if ( ntype != NOTEON && ntype != NOTEOFF ) {
			continue
		}
		if ( nt.port == Nanokey0L ) {
			$.got_nanokey(0,"L",nt.pitch,ntype==NOTEON)
		} else if ( nt.port == Nanokey0R ) {
			$.got_nanokey(0,"R",nt.pitch,ntype==NOTEON)
		} else if ( nt.port == Trigger0 ) {
			$.got_trigger(0,nt.pitch,nt.vol,ntype==NOTEON)
		} else if ( nt.port == Nanokey1L ) {
			$.got_nanokey(1,"L",nt.pitch,ntype==NOTEON)
		} else if ( nt.port == Nanokey1R ) {
			$.got_nanokey(1,"R",nt.pitch,ntype==NOTEON)
		} else if ( nt.port == Trigger1 ) {
			$.got_trigger(1,nt.pitch,nt.vol,ntype==NOTEON)
		} else {
			print("IGNORING MIDI! nt=",nt)
		}
	}
}

method nanokey_name(lr,pitch) {
	if ( DebugMonolith ) {
		print("nanokey_name lr=",lr," pitch=",pitch)
	}
	return($.nanokey_names[lr][pitch]["name"])
}

method got_nanokey(side,lr,pitch,down) {
	if ( DebugMonolith ) {
		print("GOT NANOKEY, side=",side," lr=",lr," pitch=",pitch)
	}
	bnm = $.nanokey_name(lr,pitch)
	$.keyboardbutton(down,bnm,side)
}

method got_trigger(side,pitch,vol,down) {
	if ( DebugMonolith ) {
		print("GOT TRIGGER, side=",side," pitch=",pitch)
	}
	vol = 20 + vol * 1.5
	if ( vol > 127 )
		vol = 127
	if ( ! ( pitch in $.trigger_rowcol ) ) {
		print("Hey, pitch=",pitch," not in trigger_rowcol!?")
		return()
	}
	rc = $.trigger_rowcol[pitch]
	if ( down ) 
		$.dogriddown(side,rc["row"],rc["col"],vol,$.noteset_trigger[side],"trigger")
	else
		$.dogridup(side,rc["row"],rc["col"],"trigger")
}

method start() {
	$.savemerge = Merge
	Merge = 0
	if ( $.tid >= 0 ) {
		print("Can't start masterslooper twice!?")
		return()
	}
	$.keepgoing = 1
	$.tid = task $.playloop()
}
method stop() {
	kill($.tid)
	$.tid = -1
	Merge = $.savemerge

	$.send_ano()
}
method send_ano() {
	a = ano()
	a.port = $.side_port[0]
	realtime(a)
	a.port = $.side_port[1]
	realtime(a)
}
method playloop() {
	$.nextstep_tm = nextquant(Now,1b)
	while ( $.keepgoing ) {
		lock($)
		nn = 0
		for ( side=0; side<2; side++ ) {
			nn += $.play_nextstep(side)
		}
		$.nextstep_tm += $.steptm
		unlock($)
		# print("Now=",Now," nn=",nn)

		for ( side=0; side<2; side++ ) {
			rtm = $.redrawlcd_time[side]
			if ( rtm > 0 ) {
				mt = milliclock()
				if ( mt > rtm ) {
					$.redrawlcd(side)
					$.redrawlcd_time[side] = 0
				}
			}
		}
		sleeptill($.nextstep_tm-4)
	}
}

method cleartrack(side,trk) {
	lock($)
	for ( n=0; n<$.nsteps[side]; n++ ) {
		$.stepvals[side][n][trk] = ''
	}
	unlock($)

	ch = $.chanfortrack(side,$.currtrack[side])
	sleeptill(Now+$.steptm)
	p = ano(ch)
	p.port = $.side_port[side]
	$.realtime_now(p)
}

method nextstep(side) {
	return($.step_after(side,$.currstep[side]))
}

method step_after(side,s) {
	s++
	if ( s >= $.nsteps[side] )
		s = 0
	return(s)
}

method setstep(cstep,side,trk,p) {
	# print("setstep cstep=",cstep," trk=",trk," p=",p)
	$.stepvals[side][cstep][trk] = p
}

method dotranspose(p) {
	if ( $.transpose_current != 0 ) {
		# print("dotranspose applyting transpose_current")
		p.pitch += $.transpose_current
	}
	return(p)
}

method play_nextstep(side) {
	nnotes = 0
	ntrks = $.ntracks[side]

	$.currstep[side]++
	if ( $.currstep[side] >= $.nsteps[side] )
		$.currstep[side] = 0

	cstep = $.currstep[side]

	if ( cstep == 0 && $.autotrans && side == 0 ) {
		$.transpose_counter++
		if ( $.transpose_counter > $.transpose_loops ) {
			# print("STEP=0, current transpose_index = ",$.transpose_index)
			$.transpose_index++
			if ( $.transpose_index >= sizeof($.transpose_sequence) ) {
				$.transpose_index = 0
			}
			$.transpose_current = $.transpose_sequence[$.transpose_index]
			# print("Transposing transpose_index = ",$.transpose_index,"  transpose_current=",$.transpose_current)
			$.transpose_counter = 0
		} else {
			# print("Transpose counter = ",$.transpose_counter)
		}
	}

	# print("Playing step=",cstep)
	for ( trk=0; trk<ntrks; trk++ ) {
		p = $.stepvals[side][cstep][trk]
		if ( p != '' ) {
			isdrum = $.is_drum(side,trk)
			vol = p.vol
			busy = 0
			if ( p.type == NOTEON ) {
				print("HEY, There shouldn't be any NOTEON's in stepvals!? p=",p)
			} else if ( p.type == NOTEOFF ) {
				print("HEY, There shouldn't be any NOTEOFF's in stepvals!? p=",p)
			} else {
				# print("STEP ",cstep," has NOTE! p=",p)
				if ( ! isdrum ) {
					p = $.dotranspose(p)
					p.vol += $.nondrum_voloffset
				} else {
					p.vol += $.drum_voloffset
				}
				$.track_playnote_at(side,trk,p,$.nextstep_tm)
				busy = 1
				nnotes++
			}
			if ( $.showbusy && busy ) {
				if ( $.lcdbusy[side][trk] <= 0 ) {
					# print("Writing star Now=",Now)
					mdep("lcd","write",$.lcd_index[0],"*",trk,0)
				}
				$.lcdbusy[side][trk] = 3
			}
			f = $.fade_vals[$.fade_index]
			if ( f < 1.0 ) {
				p = $.stepvals[side][cstep][trk]
				v = round(p.vol * f)
				p.vol = v
				if ( v < 5 ) {
					# print("Faded DELETING trk=",trk," p=",p)
					p = ''
				}
				$.stepvals[side][cstep][trk] = p
			}
		} else {
			if ( $.showbusy && $.lcdbusy[side][trk] > 0 ) {
				$.lcdbusy[side][trk]--
				if ( $.lcdbusy[side][trk] == 0 ) {
					# print("Writing blank Now=",Now)
					mdep("lcd","write",$.lcd_index[0]," ",trk,0)
				}
			}
		}
	}
	return(nnotes)
}
method valsintrack(s,t) {
	nnotes = 0
	ns = $.nsteps[s]
	for ( st=0; st<ns; st++ ) {
		sv = $.stepvals[s][st][t]
		if ( sv != '' && sv.type != NOTEOFF ) {
			nnotes++
		}
	}
	return(nnotes)
}
method nexttrack(s) {
	$.settrack(s,$.currtrack[s] + 1)
}
method settrack(s,trk) {
	if ( trk >= $.ntracks[s] )
		trk= 0
	$.currtrack[s] = trk
}

}

