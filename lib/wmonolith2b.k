FakeLCD = 1
DebugMonolith = 0

# Global parameters:
# Fading
# Tempo
# Keychanges
# LoopLength

class wmonolith2b {
method init {
	$.w = new window()
	$.inherit($.w)

	$.tid = -1
	$.nextstep_tm = Now

	$.reboot_last_time = 0
	$.total_reboot_count = 0

	$.last_played_tm = Now
	$.last_played_Now = Now
	$.last_quantize = [0=Now,1=Now]
	$.last_input = milliclock()
	$.last_button = milliclock()
	$.playedhal = 0

	$.bpm_values = [0=50,1=80,2=100,3=120,4=150,5=200]
	$.default_bpm_index = 2
	$.bpm_index = $.default_bpm_index
	$.set_tempo()

	$.neverfade = 1
	$.recalibrate = 0
	$.recalibrate_last_time = 0

	$.gesturerows = 6
	$.gesturecols = 6
	$.triggerrows = 4
	$.triggercols = 4

	# On low-CPU-power machines (like the Atom-based eee box), this is
	# needed to avoid pops/clicks during excessive igesture activity
	mdep("priority","realtime")

	$.value_names = [
		"Looping"=1,
		"Chord"=1,
		"Octave"=1,
		"Volume"=1,
		"Complexity"=1,
		"Style"=1,
		"Scale"=1,
		"Tempo"=1,
		"LoopLength"=1,
		"LoopFade"=1,
		"Automate"=1,
		# "Transpose"=1,
		"Effect"=1
		]

	$.default_lcdmode = "Sound"
	$.default_automate = 2    # transpose every 16 loops

	startup_autoplay = 1
	if ( startup_autoplay ) {
		$.default_autoplay = 1
		$.default_autoplaytype = 0   # drums=1, all=0
		$.initial_lcdmode = "AutoPlay"
	} else {
		$.default_autoplay = 0
		$.default_autoplaytype = 0   # 
		$.initial_lcdmode = "Sound"
	}
	$.default_auto_complexity = 2
	$.autoplay = [0=$.default_autoplay,1=$.default_autoplay]
	$.autoplaytype = [0=$.default_autoplaytype,1=$.default_autoplaytype]
	$.auto_complexity = [0=$.default_auto_complexity,1=$.default_auto_complexity]

	$.complexity_values = [0=0.01,1=0.04,2=0.08,3=0.18,4=0.5]
	$.complexity_names = [0="really sparse",1="sparse",2="normal",3="dense",4="really dense"]

	$.automate_index = [0=$.default_automate,1=$.default_automate]
	$.set_automate(0)
	$.set_automate(1)

	$.automate_names = [
		0="No automation",
		1="Automatically\ntranspose\nevery loop",
		1="Automatically\ntranspose\nevery 4 loops",
		2="Automatically\ntranspose\nevery 16 loops"
		]

	$.transpose_vals = [
		0=2,
		1=3,
		2=5,
		3=7
		]

	$.grid_to_transpose = [
		3 = [ 0=7,1=9,2=10,3=12 ],
		2 = [ 0=0,1=2,2=3,3=5 ],
		1 = [ 0=0,1=-2,2=-3,3=-5 ],
		0 = [ 0=-7,1=-9,2=-10,3=-12 ]
		]

	$.grid_to_hal = [
		3 = [ 0="Zarathustra.wav",1="stars.wav",2="better.wav",3="cantdo.wav" ],
		2 = [ 0="dave.wav",1="daisy.wav",2="decision.wav",3="difficult.wav" ],
		1 = [ 0="disconne.wav",1="error.wav",2="fault.wav",3="feelit.wav" ],
		0 = [ 0="game.wav",1="goodbye.wav",2="yourdiscovery.wav",3="hal9000.wav" ]
		]

	$.default_fade = 0
	$.min_vol = 4

	$.default_autotrans = 0
	$.total_reset_count = 0
	$.last_total_reset = 0

	Offsetfilter = 0

	Gesturedragthreshold = 0.0
	GestureDraglimit = 60

	Gesturedragthreshold = 0.1
	GestureDraglimit = 20

	Gesturedragthreshold = 0.02
	GestureDraglimit = 20

	$.tid = -1
	$.default_nsteps = 16
	$.default_nsteps = 32
	$.maxnsteps = 128
	$.minnsteps = 8
	$.defaultntracks = 5
	$.steptm = 1b/4
	$.clear_sleeptime = $.steptm / 8
	$.nsteps = []
	$.ntracks = []
	$.currstep = []
	$.currtrack = []
	$.stepvals = []
	$.fade_index = []
	$.button_state = []
	$.finger_state = []
	$.side_fingersdown = []

	for ( s=0; s<2; s++ ) {
		$.button_state[s] = []

		$.side_fingersdown[s] = 0
		$.finger_state[s] = [0=[],1=[]]  # 0=bottom, 1=top
		$.clear_finger_state(s)

		$.nsteps[s] = $.default_nsteps
		$.ntracks[s] = $.defaultntracks
		$.fade_index[s] = $.default_fade
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
	$.current_loop = [0=0,1=0]
	$.loop_next = [0=-1,1=-1]
	$.side_lcdmode = [0=$.default_lcdmode,1=$.default_lcdmode]
	print("INITIAL lcdmode= ",$.side_lcdmode)

	$.autotrans = $.default_autotrans

	$.redrawlcd_time = [0=0,1=0]
	$.lcdtimeout = 1200   # milliseconds
	$.hinttimeout = 4000   # milliseconds
	$.drum_voloffset = 20
	$.drum_pitch0 = 24
	$.nondrum_voloffset = 20
	$.lcd_index = [0=Lcd0,1=Lcd1]
	# print("lcd_index = ",$.lcd_index)

	$.showbusy = 0

	$.track_chan_range = [
		0 = ["min"=1,"max"=3],
		1 = ["min"=4,"max"=6],
		2 = ["min"=7,"max"=10],
		3 = ["min"=11,"max"=13],
		4 = ["min"=14,"max"=16]
		]

	$.dur_choices = [
		0 = $.steptm,
		1 = 2*$.steptm,
		2 = 4*$.steptm,
		3 = 8*$.steptm
		]

	$.autotranspose_current = 0
	$.autotranspose_index = 0
	$.autotranspose_loops = 0
	$.autotranspose_counter = 0
	$.autotranspose_sequence = [
		0=0, 1=7, 2=5, 3=3
		]

	$.manualtranspose_current = 0

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
	# $.scale_names[n++] = "New Age"
	$.scale_names[n++] = "Fifths"
	# $.scale_names[n++] = "Harminor"
	# $.scale_names[n++] = "Melminor"
	# $.scale_names[n++] = "Chromatic"

	$.scale_names = []
	n = 0
	$.scale_names[n++] = "Chinese"
	$.scale_names[n++] = "WestAfrican"
	# $.scale_names[n++] = "New Age"
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
		1=0
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

	$.volume_names = [
		0 = "quietest",
		1 = "quieter",
		2 = "normal",
		3 = "loud",
		4 = "loudest"
		]

	$.volume_default = 2

	$.volume_values = [
		0 = 60,
		1 = 70,
		2 = 80,
		3 = 90,
		4 = 100
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
	$.chord_names[n++] = "Min9"
	# $.chord_names[n++] = "Dim9"
	# $.chord_names[n++] = "NModMaj2"
	$.chord_names[n++] = "Fourths"
	# $.chord_names[n++] = "Sequence1"
	# $.chord_names[n++] = "Sequence2"

	$.auto_chord_choices = [0=0, 1=1, 2=2, 3=3]

	$.side_chord_index = [
		0=0,
		1=0
		]
	$.side_style_index = [
		0=0,
		1=0
		]
	$.side_style_params = [
		0 = ["repeat"=4,"time"=1b/4],
		1 = ["repeat"=4,"time"=1b/4]
		]

	$.side_volume_index = [
		0 = 2,
		1 = 2
		]

	$.noteset_trigger = [0=[],1=[]]
	$.noteset_gesture = [0=[],1=[]]

	$.make_noteset_scale_both()

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

	$.chan_desc = [
	    0=[
		1=["name"="Bells 1","type"="pitched","cat"="Lead"],
		2=["name"="Sawtooth","type"="pitched","cat"="Lead"],
		3=["name"="Electric Piano","type"="pitched","cat"="Lead"],
		4=["name"="Whip","type"="pitched","cat"="Bass"],
		5=["name"="Pure Square","type"="pitched","cat"="Bass"],
		6=["name"="Buzzy","type"="pitched","cat"="Bass"],
		7=["name"="Sawtooth Bell","type"="pitched","cat"="Pad"],
		8=["name"="Dreamy","type"="pitched","cat"="Pad"],
		9=["name"="Ether Organ","type"="pitched","cat"="Pad"],
		10=["name"="Raspy","type"="pitched","cat"="Pad"],
		11=["name"="Jazz","type"="drum","cat"="Drum"],
		12=["name"="Middle Eastern","type"="drum","cat"="Drum"],
		13=["name"="Glitch","type"="drum","cat"="Drum"],
		14=["name"="Garage Kit","type"="drum","cat"="Other"],
		15=["name"="Hand Drums","type"="drum","cat"="Other"],
		16=["name"="HAL","type"="drum","cat"="Other"]
	    ],
	    1=[
		1=["name"="Sharp Bell","type"="pitched","cat"="Lead"],
		2=["name"="Simple Square","type"="pitched","cat"="Lead"],
		3=["name"="Bottle Blow 3","type"="pitched","cat"="Lead"],
		4=["name"="Buzz","type"="pitched","cat"="Bass"],
		5=["name"="Wooden","type"="pitched","cat"="Bass"],
		6=["name"="Plucked","type"="pitched","cat"="Bass"],
		7=["name"="Angel Bell","type"="pitched","cat"="Pad"],
		8=["name"="Bowed String","type"="pitched","cat"="Pad"],
		9=["name"="Slow Sweep","type"="pitched","cat"="Pad"],
		10=["name"="Long Farewell","type"="pitched","cat"="Pad"],
		11=["name"="Jazz","type"="drum","cat"="Drum"],
		12=["name"="Middle Eastern","type"="drum","cat"="Drum"],
		13=["name"="Glitch","type"="drum","cat"="Drum"],
		14=["name"="Garage Kit","type"="drum","cat"="Other"],
		15=["name"="Hand Drums","type"="drum","cat"="Other"],
		16=["name"="HAL","type"="drum","cat"="Other"]
	    ]
	]

	$.HALfiles = []
	n = 0
	$.HALfiles[n++] = "better.wav"
	$.HALfiles[n++] = "cantdo.wav"
	$.HALfiles[n++] = "chess.wav"
	$.HALfiles[n++] = "daisy.wav"
	$.HALfiles[n++] = "dave.wav"
	# $.HALfiles[n++] = "dchandra.wav"
	$.HALfiles[n++] = "decision.wav"
	$.HALfiles[n++] = "difficult.wav"
	$.HALfiles[n++] = "disconne.wav"
	# $.HALfiles[n++] = "dream.wav"
	$.HALfiles[n++] = "error.wav"
	$.HALfiles[n++] = "fault.wav"
	$.HALfiles[n++] = "feelit.wav"
	$.HALfiles[n++] = "foolprf.wav"
	$.HALfiles[n++] = "game.wav"
	$.HALfiles[n++] = "goodbye.wav"
	$.HALfiles[n++] = "hal9000.wav"
	$.HALfiles[n++] = "hihal.wav"
	# $.HALfiles[n++] = "i_unders.wav"
	$.HALfiles[n++] = "ignition.wav"
	$.HALfiles[n++] = "info.wav"
	$.HALfiles[n++] = "leave.wav"
	$.HALfiles[n++] = "message.wav"
	$.HALfiles[n++] = "mission.wav"
	$.HALfiles[n++] = "moment.wav"
	# $.HALfiles[n++] = "morning.wav"
	$.HALfiles[n++] = "noquesti.wav"
	$.HALfiles[n++] = "nothing.wav"
	$.HALfiles[n++] = "odd.wav"
	# $.HALfiles[n++] = "open.wav"
	$.HALfiles[n++] = "operatio.wav"
	$.HALfiles[n++] = "personal.wav"
	$.HALfiles[n++] = "puzzlin.wav"
	# $.HALfiles[n++] = "sal-dream.wav"
	# $.HALfiles[n++] = "sal-hope.wav"
	# $.HALfiles[n++] = "sal-phoenix.wav"
	$.HALfiles[n++] = "silly.wav"
	$.HALfiles[n++] = "stars.wav"
	$.HALfiles[n++] = "stresspi.wav"
	$.HALfiles[n++] = "sure.wav"
	# $.HALfiles[n++] = "track.wav"
	$.HALfiles[n++] = "well.wav"
	$.HALfiles[n++] = "worry.wav"
	$.HALfiles[n++] = "yourdiscovery.wav"
	# $.HALfiles[n++] = "Zarathustra.wav"

	$.autoredraw_buttons = [
		"Fade Out"=1,
		"Help"=1,
		"HAL9000"=1,
		"Silnc Snd"=1,
		"Silnc Me"=1,
		"Mutate Notes"=1,
		"Mutate Sounds"=1,
		"Mutate Rhythm"=1,
		"Add To Sound"=1,
		"Add To All"=1,
		"Transpose"=1,
		"Remove Nts"=1,
		"Restart"=1,
		"Reboot"=1,
		"Play Lp1"=1,
		"Play Lp2"=1,
		"Play Lp3"=1,
		"Play Lp4"=1,
		"Save Lp1"=1,
		"Save Lp2"=1,
		"Save Lp3"=1,
		"Save Lp4"=1,
		"Reset This Side"=1
		]
	$.autoredraw_buttons_bothsides = [
		"Silnc Both Sides"=1,
		"Reset Both Sides"=1
		]
	$.helpfor = []
	$.helpfor["Fade Out"] = "The volume of all\nnotes will be reduced\na bit."
	$.helpfor["Lead"] = "Changes the\ncurrent sound to\na lead sound"
	$.helpfor["Bass"] = "Changes the\ncurrent sound to\na bass sound"
	$.helpfor["Pad"] = "Changes the\ncurrent sound to\na pad sound"
	$.helpfor["Drum"] = "Changes the\ncurrent sound to\na drum sound"
	$.helpfor["Other"] = "Changes the\ncurrent sound to\nan 'other' sound\n(drums and HAL)"
	$.helpfor["+"] = "Increases or changes\nthe value of the\ncurrently-displayed\nparameter"
	$.helpfor["-"] = "Decreases or changes\nthe value of the\ncurrently-displayed\nparameter"
	$.helpfor["Default"] = "Sets the\ncurrently-displayed\nparameter to its\ndefault value"
	$.helpfor["Add To All"] = "Randomly adds some\nnotes to the loop\nusing all of the\ntypes of sounds"
	$.helpfor["Add To Sound"] = "Randomly adds some\nnotes to the loop\nusing only the\ncurrent sound"
	$.helpfor["Mutate Rhythm"] = "Changes the rhythm\nof the\ncurrent loop"
	$.helpfor["Mutate Sounds"] = "Changes the sounds\nof the\ncurrent loop"
	$.helpfor["Mutate Duration"] = "Changes the\nduration of the\nnotes in the\ncurrent loop"
	$.helpfor["Quantize"] = "Quantizes the\ntiming of\nthe notes in the\ncurrent loop"
	$.helpfor["LoopLength"] = "Sets the number of\nsteps in the current\nloop, determining\nthe loop length)"
	$.helpfor["LoopFade"] = "Controls the way that\nnotes fade out\neach time through\na loop"
	$.helpfor["Fade Out"] = "Instantly reduces\nthe volume of\nthe current loop\nby a small amount"
	$.helpfor["Transpose"] = "Instantly transposes\n(changes the pitch\nof) the notes\nin the current loop"
	$.helpfor["Remove Nts"] = "Instantly removes\na few notes\nfrom the\ncurrent loop"
	$.helpfor["Chord"] = "Controls whether you\nare playing chords\nor single notes,\nand type of chord"
	$.helpfor["Octave"] = "Controls the octave\nof the current sound"
	$.helpfor["Volume"] = "Controls the relative\nvolume of the\ncurrent sound"
	$.helpfor["Style"] = "Controls the way\nin which notes\nare played"
	$.helpfor["Silnc Snd"] = "Stops and removes\nfrom the loop\nall notes in\nthe current sound"
	$.helpfor["Silnc Me"] = "Stops and removes\nfrom the loop\nall notes"
	$.helpfor["Silnc Both Sides"] = "Stops and removes\nall notes from\nfrom both sides"
	$.helpfor["Looping"] = "Controls whether\nthe notes you play\nwill be automatically\nlooped or not"
	$.helpfor["Restart"] = "Gets a completely\nclean start"
	$.helpfor["AutoDrums"] = "Instantly starts\nplaying drum\npatterns which\ncontinuously mutate"
	$.helpfor["AutoPlay"] = "Instantly starts\nplaying music which\ncontinuously mutates"
	$.helpfor["Complexity"] = "Controls the\ncomplexity of\n'Auto Play' and\n'Auto Drums'"
	$.helpfor["Play Lp1"] = "Plays the contents\nof Loop 1\n(which may be empty)"
	$.helpfor["Play Lp2"] = "Plays the contents\nof Loop 2\n(which may be empty)"
	$.helpfor["Play Lp3"] = "Plays the contents\nof Loop 3\n(which may be empty)"
	$.helpfor["Play Lp4"] = "Plays the contents\nof Loop 4\n(which may be empty)"
	$.helpfor["Save Lp1"] = "Saves the\ncurrently-playing\nloop in Loop 1"
	$.helpfor["Save Lp2"] = "Saves the\ncurrently-playing\nloop in Loop 2"
	$.helpfor["Save Lp3"] = "Saves the\ncurrently-playing\nloop in Loop 3"
	$.helpfor["Save Lp4"] = "Saves the\ncurrently-playing\nloop in Loop 4"
	$.helpfor["Reset This Side"] = "Sets all parameters\nfor this side\nto their\ndefault value"
	$.helpfor["Reset Both Sides"] = "Sets all parameters\nfor both sides\nto their\ndefault value"
	$.helpfor["Tempo"] = "Controls the\noverall tempo\nof both sides"
	$.helpfor["Effect"] = "Controls which\naudio effect you\ncan manipulate with\nthe lower pad"
	$.helpfor["Hints"] = "Displays suggestions\nand information\nabout using\nthe monolith"
	$.helpfor["Scale"] = "Controls the scale\n(the set of pitches)\nthat is used\nby both sides"
	$.helpfor["Automate"] = "Controls automatic\nperiodic\ntransposing"
	$.helpfor["HAL9000"] = "Plays the\nBest of HAL"

	$.nanokey_names = [
	    "L" = [
		72=["x"=1,"y"=0,"name"="Lead"],
		71=["x"=1,"y"=2,"name"="Bass"],
		70=["x"=0,"y"=3,"name"="+"],
		69=["x"=1,"y"=4,"name"="Pad"],
		68=["x"=0,"y"=5,"name"="-"],
		67=["x"=1,"y"=6,"name"="Drum"],
		66=["x"=0,"y"=7,"name"="Default"],
		65=["x"=1,"y"=8,"name"="Other"],
		64=["x"=1,"y"=10,"name"="Add To Sound"],
		63=["x"=0,"y"=11,"name"="Add To All"],
		62=["x"=1,"y"=12,"name"="Fade Out"],
		61=["x"=0,"y"=13,"name"="Remove Nts"],
		60=["x"=1,"y"=14,"name"="Quantize"],
		59=["x"=1,"y"=16,"name"="Chord"],
		58=["x"=0,"y"=17,"name"="Mutate Rhythm"],
		57=["x"=1,"y"=18,"name"="Octave"],
		56=["x"=0,"y"=19,"name"="Mutate Sounds"],
		55=["x"=1,"y"=20,"name"="Volume"],
		54=["x"=0,"y"=21,"name"="Mutate Durations"],
		53=["x"=1,"y"=22,"name"="Transpose"],
		52=["x"=1,"y"=24,"name"="Silnc Snd"],
		51=["x"=0,"y"=25,"name"="LoopLength"],
		50=["x"=1,"y"=26,"name"="Silnc Both Sides"],
		49=["x"=0,"y"=27,"name"="LoopFade"],
		48=["x"=1,"y"=28,"name"="Silnc Me"]
		],
	    "R" = [
		72=["x"=1,"y"=0,"name"="Play Lp1"],
		71=["x"=1,"y"=2,"name"="Play Lp2"],
		70=["x"=0,"y"=3,"name"="AutoPlay"],
		69=["x"=1,"y"=4,"name"="Play Lp3"],
		68=["x"=0,"y"=5,"name"="AutoDrums"],
		67=["x"=1,"y"=6,"name"="Play Lp4"],
		66=["x"=0,"y"=7,"name"="Complexity"],
		65=["x"=1,"y"=8,"name"="Save Lp1"],
		64=["x"=1,"y"=10,"name"="Save Lp2"],
		63=["x"=0,"y"=11,"name"="Tempo"],
		62=["x"=1,"y"=12,"name"="Save Lp3"],
		61=["x"=0,"y"=13,"name"="Looping"],
		60=["x"=1,"y"=14,"name"="Save Lp4"],
		59=["x"=1,"y"=16,"name"="HAL9000"],
		58=["x"=0,"y"=17,"name"="Effect"],
		57=["x"=1,"y"=18,"name"="Reboot"],
		56=["x"=0,"y"=19,"name"="Style"],
		55=["x"=1,"y"=20,"name"="Recalibrate"],
		54=["x"=0,"y"=21,"name"="Scale"],
		53=["x"=1,"y"=22,"name"="Automate"],
		52=["x"=1,"y"=24,"name"="Restart"],
		51=["x"=0,"y"=25,"name"="Hints"],
		50=["x"=1,"y"=26,"name"="Reset This Side"],
		49=["x"=0,"y"=27,"name"="Help"],
		48=["x"=1,"y"=28,"name"="Reset Both Sides"]
		]
	]

	$.hint_index = 0
	$.hints = []
	n = 0
	$.hints[n++] = "To play faster,\nadjust the Tempo"
	$.hints[n++] = "Try using Chord."
	$.hints[n++] = "Side 0 is the left\nside of the monolith,\nSide 1 is the right\nside of the monolith"

	# default sounds are set here
	$.track_default_chan = [
		0 = [
			0 = 3,
			1 = 4,
			2 = 7,
			3 = 11,
			4 = 14
			],
		1 = [
			0 = 1,
			1 = 6,
			2 = 8,
			3 = 13,
			4 = 15
			]
		]

	$.track_octave = [
		0=[0=0,1=0,2=0,3=0,4=0],
		1=[0=0,1=0,2=0,3=0,5=0]
		]

	$.octave_names = [
		0 = "is not transposed",
		1 = "is up one octave",
		2 = "is up two octaves",
		-1 = "is down one octave",
		-2 = "is down two octaves"
		]
	$.octave_min = -2
	$.octave_max = 2

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
	$.default_effect = [0=1, 1=2]
	$.side_effect = [0=$.default_effect[0],1=$.default_effect[1]]
	$.neffects = 5
	# $.style_names = [0="None",1="Stutter",2="Octaves",3="Bend",4="Transpose"]
	$.style_names = [0="None",1="Stutter",2="Octaves",3="Bend"]

	$.effect_message = [
		0 = "Lower Pad currently\nhas no effect"
		]

	for ( e=1; e<=$.neffects; e++ ) {
		$.effect_message[e] = "Lower pad now\ncontrols effect "+string(e)
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
			1 = ["x"=113, "y"=114, "prox"=-1, "nofade"=1 ],
			2 = ["x"=113, "y"=114, "prox"=115 ],
			3 = ["x"=113, "y"=114, "prox"=115 ],
			4 = ["x"=113, "y"=114, "prox"=115, "nofade"=1 ],
			5 = ["x"=113, "y"=114, "prox"=115 ]
		]
	]
	# assume the rest of the effects all take 113,114,115 controllers
	for ( e=5; e<=$.neffects; e++ ) {
		$.side_effect_ctrl[0][e] = ["x"=113, "y"=114, "prox"=115 ]
	}
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

	$.numvsts = 11

	$.chan_to_vstnum = [
		1 = 0,
		2 = 1,
		3 = 2,
		4 = 3,
		5 = 4,
		6 = 5,
		7 = 6,
		8 = 7,
		9 = 8,
		10 = 9,
		11 = 10,   # the last 6 channels are VST 10 - battery 3
		12 = 10,
		13 = 10,
		14 = 10,
		15 = 10,
		16 = 10
		]

	for ( s=0; s<2; s++ ) {
		$.vst_enabled[s] = []
		for ( e=0; e<$.numvsts; e++ ) {
			$.vst_enabled[s][e] = 0
		}
	}

	$.track_chan = []
	for ( side=0; side<2; side++ ) {
		ntracks = $.ntracks[side]
		$.track_chan[side] = []
		for ( t=0; t<ntracks; t++ ) {
			ch = $.track_default_chan[side][t]
			$.track_chan[side][t] = ch
		}
	}

	$.update_vst_enabled(0)
	$.update_vst_enabled(1)
	$.sendenabled()

	# save empty loops
	$.loop = []
	for ( side=0; side<2; side++ ) {
		$.loop[side] = []
		for ( loopnum=0; loopnum<4; loopnum++ ) {
			$.save_loop(side,loopnum,0)
		}
	}

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

	for ( s=0; s<2; s++ ) {
		sn = string(s)

		$.c[sn+"lcd"] = new ktext("LCD text\n12345678901234567890\n3\n4")
		gridname = sn + "grid"
		$.c[gridname] = new wgrid(4,4)
		$.c[gridname].setborder(1)
		$.c[gridname].setcallbackdown($,"faketriggerdown",s)
		$.c[gridname].setcallbackup($,"faketriggerup",s)

		gesturename = sn + "gestureTop"
		istop = 1
		$.c[gesturename] = new wgrid(1,1)
		$.c[gesturename].setborder(1)
		$.c[gesturename].setcallbackdown($,"fakegesturedown",["side"=s,"istop"=istop])
		$.c[gesturename].setcallbackup($,"fakegestureup",["side"=s,"istop"=istop])
		$.c[gesturename].setcallbackdrag($,"fakegesturedrag",["side"=s,"istop"=istop])

		gesturename = sn + "gestureBottom"
		istop = 0
		$.c[gesturename] = new wgrid(1,1)
		$.c[gesturename].setborder(1)
		$.c[gesturename].setcallbackdown($,"fakegesturedown",["side"=s,"istop"=istop])
		$.c[gesturename].setcallbackup($,"fakegestureup",["side"=s,"istop"=istop])
		$.c[gesturename].setcallbackdrag($,"fakegesturedrag",["side"=s,"istop"=istop])
	}

	$.make_keyboard($.nanokey_names["L"],0,"L")
	$.make_keyboard($.nanokey_names["R"],0,"R")
	$.make_keyboard($.nanokey_names["L"],1,"L")
	$.make_keyboard($.nanokey_names["R"],1,"R")

	for ( t in $.c )
		$.addchild($.c[t])

	$.miditid = task $.task_monolith_midi()
	$.failsafeid = task $.task_failsafe()
	$.joy = getjoymonitor()
	$.joy.notify($,-1)

	# gesturenotify($)
	$.gesture_rows = 4
	$.gesture_cols = 4
	gesturenotifyrc($,$.gesture_rows,$.gesture_cols)

	# tempo(500000)


	if ( ! defined(SalvationOutput) ) {
		SalvationOutput = -1
	}

	$.reset_all_side(0)
	$.reset_all_side(1)

	$.side_lcdmode = [0=$.initial_lcdmode,1=$.initial_lcdmode]

	$.send_ano_both()
	$.set_volume(0)
	$.set_volume(1)
	$.redrawlcds()

	$.wait_for_bidule()

	greeting = rand(2)
	day = $.dayperiod()
	for ( s=0; s<2; s++ ) {
		$.lcd_message(s,"Good "+day+" Dave,\nEverything's\nrunning smoothly.\nAnd you?")
		# $.lcd_message(s,"I'm completely oper\national, and all my\ncircuits are func\ntioning perfectly")
		$.redrawlcd_time[s] = milliclock() + 4*$.lcdtimeout
	}

	audiogreeting = 1
	greeting_sync = 1
	if ( audiogreeting ) {
		if ( greeting == 0 ) {
			fn =  "hihal.wav"
		} else {
			fn =  "operatio.wav"
		}
		if ( greeting_sync ) {
			playmonolithwave_sync("operatio.wav")
		} else {
			task playmonolithwave("operatio.wav")
		}
	}

	$.start()

	# print("Sleeping till wav play done...")
	# sleeptill(milliclock() + 4*$.lcdtimeout)
	# print("AFTER Sleeping till wav play done...")


	# t.waittilldone()
	# t.stop()
}

method wait_for_bidule() {
	$.lcd_message_both("Waiting for audio\nengine to start")
	starttm = milliclock()
	endtm = starttm + 300*1000
	sz = 0
	# endsz = 765
	endsz = 755
	while ( milliclock() < endtm && sz < endsz ) {
		sz = $.bidule_size()
		# print("sz=",sz)
		percent = round(100.0 * sz / endsz)
		$.lcd_message_both("Waiting for audio\nengine to start\n"+string(percent)+" %")
		millisleep(1000)
	}
}

method dayperiod() {
	f = open("c:\\tmp\\time.out")
	if ( f < 0 ) {
		print("time.out doesn't exist?  using 'evening'")
		return("evening")
	}
	s = get(f)
	close(f)
	if ( s ~~ "0[6789]:.*PM" ) {
		t = "evening"
	} else if ( s ~~ "1[01]:.*PM" ) {
		t = "evening"
	} else if ( s ~~ "12:.*AM" ) {
		t = "evening"
	} else if ( s ~~ "0[12345]:.*AM" ) {
		t = "evening"
	} else if ( s ~~ "0[6789]:.*AM" ) {
		t = "morning"
	} else if ( s ~~ "1[01]:.*AM" ) {
		t = "morning"
	} else if ( s ~~ "12:.*PM" ) {
		t = "afternoon"
	} else if ( s ~~ "0[12345]:.*PM" ) {
		t = "afternoon"
	} else {
		t = "whatever"
	}
	return(t)
}

method bidule_size() {
	cmd = "c:\\windows\\system32\\tasklist.exe > c:\\tmp\\tasklist.out"
	system(cmd)
	f = open("c:\\tmp\\tasklist.out")
	# print("tasklist.out f=",f)
	if ( f < 0 ) {
		return(-1)
	}
	while ( (line=get(f)) != Eof ) {
		if ( line ~~ "PlogueBidule.exe" ) {
			# print("line=",line)
			s = substr(line,61)
			# print("s=",s)
			sz = integer(s)
			return(sz)
		}
	}
	close(f)
	return(-1)
}

method clear_finger_state(s) {
	for ( f=1; f<10; f++ ) {
		$.finger_state[s][0][f] = 0
		$.finger_state[s][1][f] = 0
	}
	$.finger_state[s][0]["lastdown"] = 0
	$.finger_state[s][1]["lastdown"] = 0
	$.side_fingersdown[s] = 0
}

method make_keyboard(arr,side,LR) {
	for ( k in arr ) {
		kk = arr[k]
		kkname = kk["name"]
		cnm = string(side)+LR+kkname
		km = new kmoment(kkname,$,"keyboardbutton",kkname,side,LR)
		$.c[cnm] = km
	}
}
method resize_keyboard(sn,LR,arr,x0,y0,x1,y1) {
	dx = (x1-x0)/2
	dy = (y1-y0)/30
	# print("Resizing keyboard, xy0=",x0,y0," xy1=",x1,y1," dxy=",dx,dy)
	th = $.textheight()
	tw = $.textwidth()
	for ( k in arr ) {
		kk = arr[k]
		x = x0 + kk["x"] * dx
		y = y0 + kk["y"] * dy
		cnm = sn+LR+kk["name"]
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
	if ( eff < 0 )
		eff = $.neffects
	else if ( eff > $.neffects )
		eff = 0
	$.side_effect[s] = eff
}

method update_vst_enabled(side) {
	# zero them all out
	for ( vstnum=0; vstnum<$.numvsts; vstnum++ ) {
		$.vst_enabled[side][vstnum] = 0
	}
	# then enable the vsts used in each track
	ntracks = $.ntracks[side]
	for ( t=0; t<ntracks; t++ ) {
		ch = $.track_chan[side][t]
		vstnum = $.chan_to_vstnum[ch]
		if ( vstnum >= $.numvsts ) {
			print("HEY!  track t=",t," ch=",ch," vstnum=",vstnum," invalid vstnum!?")
		} else {
			$.vst_enabled[side][vstnum] = 1
		}
	}
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

method setfakelcd(s,lbl) {
	if ( FakeLCD == 0 )
		return()
	t = $.c[string(s)+"lcd"]
	t.set(lbl)
	t.redraw()
}

method redrawlcd(side) {

	mode = $.side_lcdmode[side]
	# print("redrawlcd mode=",mode)
	useplusminus = "Press +/- to change"

	mdep("lcd","clear",$.lcd_index[side])
	mdep("lcd","backlight",$.lcd_index[side],$.backlight())

	msg = ""
	if ( mode == "Sound" ) {
		trk = $.currtrack[side]
		ch = $.track_chan[side][trk]
		v = $.chan_to_vstnum[ch]
		if ( v < 0 ) {
			vn = "?????"
		} else {
			vn = $.chan_desc[side][ch]["name"]
		}
		lbl = "Sound = "+$.chan_desc[side][ch]["cat"]
		snd = vn
		msg = lbl+"\n"+snd+"\n \n"+useplusminus
	} else if ( mode == "Looping" ) {
		lbl = "Looping is "+(($.is_recording[side] != 0)?"on":"off")
		msg = lbl+"\n \n"+useplusminus
	} else if ( mode == "Tempo" ) {
		lbl = $.tempo_line()
		msg = lbl + "\n \n" + useplusminus
	} else if ( mode == "Scale" ) {
		si = $.side_scale_index[side]
		lbl = sprintf("Scale = %s",$.scale_names[si])
		msg = lbl + "\n \n" + useplusminus
	} else if ( mode == "Octave" ) {
		trk = $.currtrack[side]
		oct = $.track_octave[side][trk]
		ch = $.track_chan[side][trk]
		cat = $.chan_desc[side][ch]["cat"]
		lbl = sprintf("%s sound\n%s",cat,$.octave_names[oct])
		msg = lbl + "\n \n" + useplusminus
	} else if ( mode == "Chord" ) {
		ci = $.side_chord_index[side]
		lbl = sprintf("Chord = %s",$.chord_names[ci])
		msg = lbl + "\n \n" + useplusminus
	} else if ( mode == "Automate" ) {
		ci = $.automate_index[side]
		lbl = sprintf("%s",$.automate_names[ci])
		msg = lbl + "\n \n" + useplusminus
	} else if ( mode == "AutoPlay" ) {
		msg = "Auto Play\nis ON\nPress anything\nto turn it off"
	} else if ( mode == "AutoDrums" ) {
		msg = "Auto-Drums\nis ON\nPress anything\nto turn it off"
	} else if ( mode == "Volume" ) {
		ci = $.side_volume_index[side]
		lbl = sprintf("Volume = %s",$.volume_names[ci])
		msg = lbl + "\n \n" + useplusminus
	} else if ( mode == "Complexity" ) {
		ci = $.auto_complexity[side]
		print("Complexity = ",ci)
		lbl = sprintf("The complexity of\nautomatic things\nis %s",$.complexity_names[ci])
		msg = lbl + "\n \n" + useplusminus
	} else if ( mode == "Style" ) {
		ci = $.side_style_index[side]
		lbl = sprintf("Style = %s",$.style_names[ci])
		msg = lbl + "\n \n" + useplusminus
	} else if ( mode == "LoopLength" ) {
		ns = $.nsteps[side]
		lbl = sprintf("Loop Length\nis %d steps",ns)
		msg = lbl + "\n \n" + useplusminus
	# } else if ( mode == "Transpose" ) {
	# 	lbl = sprintf("Transpose = %d",$.manualtranspose_current)
	# 	msg = lbl + "\n \n" + useplusminus
	} else if ( mode == "LoopFade" ) {
		lbl = $.fade_message[$.fade_index[side]]
		msg = lbl + "\n \n" + useplusminus
	} else if ( mode == "Effect" ) {
		lbl = $.effect_message[$.side_effect[side]]
		msg = lbl + "\n \n" + useplusminus
	} else {
		print("redrawlcd can't handle mode ==",mode)
	}
	if ( msg != "" )
		$.lcd_message(side,msg)
}

method backlight() {
	# should be time-dependent
	return(1)
}

method delete {
	kill($.miditid)
	kill($.failsafeid)
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

method effect_onoff(side,eff,onoff) {
	if ( onoff ) {
		v = 0
	} else {
		v = 127
	}
	p = controller(eff,112,v)
	# print("effect_onoff side=",side," eff=",eff," onoff=",onoff," v=",v)
	p.port = $.side_port[side]
	# print("ADJUSTEFFECT_SIDE p=",p)
	realtime(p)
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
		realtime(p)
	}
	# Change the active audio output of the two audio switchers
	port = $.side_port[side]
	if ( eff > 0 ) {
		v = eff * 8 + 4
		p1 = controller(1,109,v)
		p2 = controller(1,110,v)
		p1.port = port
		p2.port = port
		realtime(p1)
		realtime(p2)
	} else {
		# print("sendenabled_side_effect is doing nothing to switchers, but is adjusting mix")
		ctrlmix = $.side_effect_ctrl_mix[side]
		pmix = controller(1,ctrlmix,0)
		pmix.port = port
		# print("dogestureup Sending mix, side=",side," v=0")
		realtime(pmix)
	}
}

method sendenabled_side_vst(side) {
	for ( vstnum=0; vstnum<$.numvsts; vstnum++ ) {
		if ( $.vst_enabled[side][vstnum] == 0 ) {
			v = 40
		} else {
			v = 0
		}
		# print("Sending v=",v," for side=",side," vstnum=",vstnum)
		p = controller(1 + vstnum,111,v)
		p.port = $.side_port[side]
		realtime(p)
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

		$.c[sn+"lcd"].resize(xy(lcdx0,y0+1*dy+4,lcdx1,y0+5*dy))
		$.c[sn+"grid"].resize(xy(x0+4,y0+7*dy+4,xm-1*tw,y1-4-dy))

		gymid = (y0+6*dy+y1)/2
		$.c[sn+"gestureTop"].resize(xy(xm+1*tw,y0+7*dy+4,x1-4,gymid-2))
		$.c[sn+"gestureBottom"].resize(xy(xm+1*tw,gymid+2,x1-4,y1-4-dy))

		ky0 = y0 + 7*dy + 4
		ky1 = y1 - 4 - dy
		$.resize_keyboard(sn,"L",$.nanokey_names["L"],x0-kwidth+2,ky0,x0,ky1)
		$.resize_keyboard(sn,"R",$.nanokey_names["R"],x1,ky0,x1+kwidth-2,ky1)
	}

}
method dump {
	return([])
}
method restore(state) {
}

method set_tempo() {
	b = $.bpm_values[$.bpm_index]
	bpm($.bpm_values[$.bpm_index])
}

method show_padmode(side) {
	msg = $.effect_message[$.side_effect[side]]
	$.lcd_message(side,msg)
}

method tempo_line() {
	b = round(60/(tempo()/1000000.0))
	msg = sprintf("Tempo is now\n%d\nbeats per minute",b)
	return(msg)
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
	ch = $.track_chan[side][trk]
	vt = $.chan_desc[side][ch]["type"]
	return ( vt == "drum" )
}
method keyboardbutton(v,bnm,side,LR) {
	$.last_input = milliclock()
	$.last_button = $.last_input
	# print("keyboardbutton v=",v," bnm=",bnm)
	$.button_state[side][bnm] = v

	if ( $.autoplay[side] != 0 && bnm != "+" && bnm != "-" && bnm != "AutoPlay" && bnm != "AutoDrums" ) {
		$.autoplay_off(side)
	}

	if ( bnm != "Help" && ("Help" in $.button_state[side]) ) {
		if ( $.button_state[side]["Help"] != 0 ) {
			if ( v ) {
				if ( bnm in $.helpfor ) {
					msg = $.helpfor[bnm]
				} else {
					msg = "That button is\n"+bnm
				}
				$.lcd_message(side,msg)
			}
			return()
		}
	}
	if ( bnm == "HAL9000" ) {
		print("HAL900 pressed, v=",v)
		if ( v == 0 ) {
			if ( $.playedhal ) {
				print("HAL was already played")
			} else {
				$.playhal(side)
			}
		} else {
			$.playedhal = 0
		}
		return()
	}
	if ( bnm == "Recalibrate" ) {
		if ( v == 1 ) {
			$.lcd_message(side,"If buttons are\nmisbehaving, press\nRecalibrate again,\nfollow instructions")
			return()
		} else {
			if ( $.recalibrate_last_time > (Now-milliclicks(2000)) ) {
				$.recalibrate = 1
				task $.recalibrate_start()
			}
			$.recalibrate_last_time = Now
		}
	}
	if ( v == 0 ) {
		if ( bnm in $.autoredraw_buttons ) {
			$.redrawlcd_time[side] = milliclock() + $.lcdtimeout
		} else if ( bnm in $.autoredraw_buttons_bothsides ) {
			t = milliclock() + $.lcdtimeout
			$.redrawlcd_time[0] = t
			$.redrawlcd_time[1] = t
		} else {
			$.redrawlcd_time[side] = 0
		}
		return()
	}
	if ( DebugMonolith ) {
		print("keyboardbutton v=",v," bnm=",bnm," side=",side," LR=",LR)
	}
	trk = $.currtrack[side]
	if ( bnm == "Rec on/off" ) {
		if ( $.is_recording[side] != 0 )
			r = 0
		else
			r = 1
		$.is_recording[side] = r
		$.lcd_message(side,"Loop Recording \nis "+(r?"ON":"OFF"))
	} else if ( bnm in $.value_names ) {
		$.side_lcdmode[side] = bnm
		# print("Setting lcdmode to ",$.side_lcdmode[side])
		$.redrawlcd(side)
	} else if ( bnm == "AutoTrans" ) {
		$.autotrans = 1 - $.autotrans
		if ( $.autotrans ) {
			# always start back at first
			$.autotranspose_index = 0
			$.autotranspose_counter = 0
		} else {
			$.autotranspose_index = 0
			$.autotranspose_counter = 0
		}
		$.autotranspose_current = $.autotranspose_sequence[$.autotranspose_index]
		$.lcd_message(side,"Auto Key Changing\nis "+($.autotrans?"ON":"OFF"))
	# } else if ( bnm == "No AutoTrans" ) {
	# 	$.autotrans = 0
	# 	$.autotranspose_index = 0
	# 	$.autotranspose_current = 0
	# 	$.lcd_message(side,"Auto Key Changing\nis OFF")
	} else if ( bnm == "+" ) {
		mode = $.side_lcdmode[side]
		doredraw = 1
		if ( mode == "Sound" ) {
			ch = $.track_chan[side][trk] + 1
			if ( ch > $.track_chan_range[trk]["max"] )
				ch = $.track_chan_range[trk]["min"]
			$.track_chan[side][trk] = ch
			$.select_vst(side,trk)
		} else if ( mode == "Looping" ) {
			$.is_recording[side] = 1
		} else if ( mode == "Tempo" ) {
			$.bpm_index++
			sz = sizeof($.bpm_values) - 1
			if ( $.bpm_index > sz )
				$.bpm_index = sz
			$.set_tempo()
		} else if ( mode == "Scale" ) {
			si = $.side_scale_index[side] + 1
			if ( si >= sizeof($.scale_names) ) {
				si = 0
			}
			# Set scale of both sides
			$.side_scale_index[side] = si
			$.side_scale_index[1-side] = si
			$.make_noteset_scale_both()
			$.rescale_steps_both()
		} else if ( mode == "Style" ) {
			si = $.side_style_index[side] + 1
			if ( si >= sizeof($.style_names) )
				si = 0
			$.side_style_index[side] = si
		} else if ( mode == "Chord" ) {
			ci = $.side_chord_index[side] + 1
			if ( ci >= sizeof($.chord_names) )
				ci = 0
			$.side_chord_index[side] = ci
			$.make_noteset_scale_both()
		} else if ( mode == "Octave" ) {
			v = $.track_octave[side][trk] + 1
			if ( v > $.octave_max )
				v = $.octave_max
			$.track_octave[side][trk] = v
		} else if ( mode == "Complexity" ) {
			v = $.auto_complexity[side] + 1
			if ( v >= sizeof($.complexity_values) )
				v = sizeof($.complexity_values) - 1
			$.auto_complexity[side] = v
		} else if ( mode == "Volume" ) {
			v = $.side_volume_index[side] + 1
			if ( v >= sizeof($.volume_names) )
				v = sizeof($.volume_names) - 1
			$.side_volume_index[side] = v
			$.set_volume(side)
		} else if ( mode == "LoopLength" ) {
			$.double_looplength(side)
		# } else if ( mode == "Transpose" ) {
		# 	v = $.manualtranspose_current + 1
		# 	if ( v > 12 )
		# 		v = 12
		# 	$.manualtranspose_current = v
		} else if ( mode == "Automate" ) {
			f = $.automate_index[side] + 1
			sz = sizeof($.automate_names)
			if ( f >= sz )
				f = 0
			$.automate_index[side] = f
			$.set_automate(side)
		} else if ( mode == "LoopFade" ) {
			f = $.fade_index[side] + 1
			sz = sizeof($.fade_vals)
			if ( f >= sz )
				f = sz-1
			$.fade_index[side] = f
		} else if ( mode == "Effect" ) {
			$.set_effect(side,$.side_effect[side]+1)
			$.sendenabled_side_effect(side)
		} else {
			print("+ is UNPREPARED TO HANDLE mode=",mode)
			doredraw = 0
		}
		if ( doredraw )
			$.redrawlcd(side)
	} else if ( bnm == "-" ) {
		mode = $.side_lcdmode[side]
		doredraw = 1
		if ( mode == "Sound" ) {
			ch = $.track_chan[side][trk] - 1
			if ( ch < $.track_chan_range[trk]["min"] )
				ch = $.track_chan_range[trk]["max"]
			$.track_chan[side][trk] = ch
			$.select_vst(side,trk)
		} else if ( mode == "Looping" ) {
			$.is_recording[side] = 0
		} else if ( mode == "Tempo" ) {
			$.bpm_index--
			if ( $.bpm_index < 0 )
				$.bpm_index = 0
			$.set_tempo()
		} else if ( mode == "Scale" ) {
			si = $.side_scale_index[side] - 1
			if ( si < 0 ) {
				si = sizeof($.scale_names) - 1
			}
			# Set scale of both sides
			$.side_scale_index[side] = si
			$.side_scale_index[1-side] = si
			$.make_noteset_scale_both()
			$.rescale_steps_both()
		} else if ( mode == "Style" ) {
			si = $.side_style_index[side] - 1
			if ( si < 0 )
				si = sizeof($.style_names) - 1
			$.side_style_index[side] = si
		} else if ( mode == "Chord" ) {
			ci = $.side_chord_index[side] - 1
			if ( ci < 0 ) {
				ci = sizeof($.chord_names) - 1
			}
			$.side_chord_index[side] = ci
			$.make_noteset_scale(side)
		} else if ( mode == "Octave" ) {
			v = $.track_octave[side][trk] - 1
			if ( v < $.octave_min )
				v = $.octave_min
			$.track_octave[side][trk] = v
		} else if ( mode == "Complexity" ) {
			v = $.auto_complexity[side] - 1
			if ( v < 0 ) {
				v = 0
			}
			$.auto_complexity[side] = v
		} else if ( mode == "Volume" ) {
			v = $.side_volume_index[side] - 1
			if ( v < 0 ) {
				v = 0
			}
			$.side_volume_index[side] = v
			$.set_volume(side)
		} else if ( mode == "LoopLength" ) {
			$.half_looplength(side)
		# } else if ( mode == "Transpose" ) {
		# 	v = $.manualtranspose_current - 1
		# 	if ( v < -12 )
		# 		v = -12
		# 	$.manualtranspose_current = v
		} else if ( mode == "Automate" ) {
			f = $.automate_index[side] - 1
			if ( f < 0 )
				f = sizeof($.automate_names) - 1
			$.automate_index[side] = f
			$.set_automate(side)
		} else if ( mode == "LoopFade" ) {
			f = $.fade_index[side] - 1
			if ( f < 0 )
				f = 0
			$.fade_index[side] = f
		} else if ( mode == "Effect" ) {
			$.set_effect(side,$.side_effect[side]-1)
			$.sendenabled_side_effect(side)
		} else {
			print("- is UNPREPARED TO HANDLE mode=",mode)
			doredraw = 0
		}
		if ( doredraw )
			$.redrawlcd(side)
	} else if ( bnm == "Default" ) {
		mode = $.side_lcdmode[side]
		doredraw = 1
		if ( mode == "Sound" ) {
			ch = $.track_default_chan[side][trk]
			$.track_chan[side][trk] = ch
			$.select_vst(side,trk)
		} else if ( mode == "Looping" ) {
			$.is_recording[side] = $.default_is_recording
		} else if ( mode == "Tempo" ) {
			$.bpm_index = $.default_bpm_index
			$.set_tempo()
		} else if ( mode == "Scale" ) {
			# Set scale of both sides
			$.side_scale_index[side] = 0
			$.side_scale_index[1-side] = 0
			$.make_noteset_scale_both()
			$.rescale_steps_both()
		} else if ( mode == "Style" ) {
			$.side_style_index[side] = 0
		} else if ( mode == "Chord" ) {
			$.side_chord_index[side] = 0
			$.make_noteset_scale(side)
		} else if ( mode == "Octave" ) {
			$.track_octave[side][trk] = 0
		} else if ( mode == "Complexity" ) {
			$.auto_complexity[side] = $.default_auto_complexity
		} else if ( mode == "Volume" ) {
			$.side_volume_index[side] = $.volume_default
			$.set_volume(side)
		} else if ( mode == "LoopLength" ) {
			$.nsteps[side] = $.default_nsteps
		} else if ( mode == "Automate" ) {
			$.automate_index[side] = $.default_automate
		} else if ( mode == "LoopFade" ) {
			$.fade_index[side] = $.default_fade
		} else if ( mode == "Effect" ) {
			$.set_effect(side,$.default_effect[side])
			$.sendenabled_side_effect(side)
		} else {
			print("- is UNPREPARED TO HANDLE mode=",mode)
			doredraw = 0
		}
		if ( doredraw )
			$.redrawlcd(side)
	} else if ( bnm == "Mutate Sounds" ) {
		$.mutate_sounds(side,1)
	} else if ( bnm == "Mutate Rhythm" ) {
		$.mutate_rhythm(side,1)
	} else if ( bnm == "Mutate Durations" ) {
		$.mutate_durations(side,1)
	} else if ( bnm == "Add To Sound" ) {
		ns = $.nsteps[side]
		trk = $.currtrack[side]
		isdrum = $.is_drum(side,trk)
		rc = $.get_gesture_rowcol(side,isdrum)
		rows = rc["rows"]
		cols = rc["cols"]
		noteset = $.noteset_gesture[side]
		toadd = 4
		nadded = 0
		nreallyadded = 0
		while ( nadded < toadd ) {
			p = $.make_one_note(side,noteset,rows,cols,isdrum)
			n = rand(ns)
			if ( $.stepvals[side][n][trk] = '' )
				nreallyadded++
			$.stepvals[side][n][trk] = p
			nadded++
		}
		after = $.notes_in_track(side,trk)
		ch = $.track_chan[side][trk]
		cat = $.chan_desc[side][ch]["cat"]
		$.lcd_message(side,sprintf("%d %s notes were\nadded or changed.\nThere are now %d\n%s notes",nadded,cat,after,cat))
	} else if ( bnm == "Add To All" ) {

		$.add_to_all(side,1)

	} else if ( bnm == "Mutate Notes" ) {
		nd = 0
		ns = $.nsteps[side]
		ntrks = $.ntracks[side]
		n1 = -1
		trk1 = -1
		n2 = -1
		trk2 = -1
		for ( trk=0; trk<ntrks; trk++ ) {
			for ( n=0; n<ns; n++ ) {
				p = $.stepvals[side][n][trk]
				if ( p != '' ) {
					if ( n1 < 0 ) {
						n1 = n
						trk1 = trk
					} else {
						n2 = n
						trk2 = trk
						t = $.stepvals[side][n1][trk1]
						$.stepvals[side][n1][trk1] = $.stepvals[side][n2][trk2]
						$.stepvals[side][n2][trk2] = t
						n1 = -1
						nd++
					}
				}
			}
		}
		$.lcd_message(side,sprintf("%d pairs of notes\nwere swapped.",nd))
	} else if ( bnm == "Remove Nts" ) {
		$.remove_notes(side,1)
	} else if ( bnm == "Transpose" ) {
		$.transpose_random(side,1)
	} else if ( bnm == "Hints" ) {
		h = $.hint_index++
		if ( $.hint_index >= sizeof($.hints) )
			$.hint_index = 0
		msg = $.hints[h]
		$.lcd_message(side,msg)
		$.redrawlcd_time[side] = milliclock() + $.hinttimeout
	} else if ( bnm == "AutoPlay" ) {
		$.autoplay[side] = 1
		$.autoplaytype[side] = 0
		$.silence_me(side)
		$.side_chord_index[side] = 0
		$.side_lcdmode[side] = "AutoPlay"
		# $.lcd_message(side,"Auto Play\nis ON\nPress anything\nto turn it off")
		$.autoplay_prep(side)
	} else if ( bnm == "AutoDrums" ) {
		$.autoplay[side] = 1
		$.autoplaytype[side] = 1
		$.silence_me(side)
		$.side_chord_index[side] = 0
		$.side_lcdmode[side] = "AutoDrums"
		# $.lcd_message(side,"Auto-Drums\nis ON\nPress anything\nto turn it off")
		$.autoplay_prep(side)
	} else if ( bnm == "Fade Out" ) {
		nd = 0
		ns = $.nsteps[side]
		ntrks = $.ntracks[side]
		for ( trk=0; trk<ntrks; trk++ ) {
			for ( n=0; n<ns; n++ ) {
				p = $.stepvals[side][n][trk]
				if ( p != '' ) {
					p.vol *= 0.80
					if ( p.vol < $.min_vol ) {
						# print("LoopFaded DELETING trk=",trk," p=",p)
						p = ''
					}
					$.stepvals[side][n][trk] = p
				}
			}
		}
		$.lcd_message(side,sprintf("Keep pressing\nFade Out\nto fade out\ncompletely."))
		# $.updatetracklabels(side)
	} else if ( bnm == "Save Lp1" ) {
		$.save_loop(side,0,1)
	} else if ( bnm == "Save Lp2" ) {
		$.save_loop(side,1,1)
	} else if ( bnm == "Save Lp3" ) {
		$.save_loop(side,2,1)
	} else if ( bnm == "Save Lp4" ) {
		$.save_loop(side,3,1)
	} else if ( bnm == "Play Lp1" ) {
		$.loop_next[side] = 0
	} else if ( bnm == "Play Lp2" ) {
		$.loop_next[side] = 1
	} else if ( bnm == "Play Lp3" ) {
		$.loop_next[side] = 2
	} else if ( bnm == "Play Lp4" ) {
		$.loop_next[side] = 3
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
		$.set_effect(side,$.default_effect[side])
		$.sendenabled_side_effect(side)
		$.show_padmode(side)
	} else if ( bnm == "Lead" ) {
		$.side_lcdmode[side] = "Sound"
		$.settrack(side,0)
		$.redrawlcd(side)
	} else if ( bnm == "Bass" ) {
		$.side_lcdmode[side] = "Sound"
		$.settrack(side,1)
		$.redrawlcd(side)
	} else if ( bnm == "Pad" ) {
		$.side_lcdmode[side] = "Sound"
		$.settrack(side,2)
		$.redrawlcd(side)
	} else if ( bnm == "Drum" ) {
		$.side_lcdmode[side] = "Sound"
		$.settrack(side,3)
		$.redrawlcd(side)
	} else if ( bnm == "Other" ) {
		$.side_lcdmode[side] = "Sound"
		$.settrack(side,4)
		$.redrawlcd(side)
	} else if ( bnm == "Quantize" ) {
		if ( (Now-$.last_quantize[side]) < milliclicks(1000) ) {
			qnt = 4
		} else {
			qnt = 2
		}
		# print("QUANTIZED to ",qnt)
		ntrks = $.ntracks[side]
		for ( t=0; t<ntrks; t++ ) {
			$.quantizetrack(side,t,qnt)
		}
		# $.print_loop(side)
		$.last_quantize[side] = Now
	} else if ( bnm == "Silnc Snd" ) {
		trk = $.currtrack[side]
		ch = $.track_chan[side][trk]
		$.cleartrack(side,trk)
		$.send_ano_side(side)
		vn = $.chan_desc[side][ch]["cat"]
		msg = sprintf("%s sound\nhas been cleared!",vn)
		$.lcd_message(side,msg)
	} else if ( bnm == "Silnc Me" ) {
		$.silence_me(side)
		$.lcd_message(side,"All Sounds\non this side\nhave been cleared!")
	} else if ( bnm == "Silnc Both Sides" ) {
		for ( s=0; s<2; s++ ) {
			ntrks = $.ntracks[s]
			for ( t=0; t<ntrks; t++ ) {
				$.cleartrack(s,t)
			}
			$.automate_index[s] = 0
			$.autoplay[s] = 0
		}
		$.autotranspose_index = 0
		$.autotranspose_counter = 0
		$.send_ano_both()
		$.lcd_message_both("All Sounds\non both sides\nhave been cleared!")
	} else if ( bnm == "Help" ) {
		$.lcd_message(side,"Hold down Help\nand press any button\nto find out\nwhat it does.")
	} else if ( bnm == "Reboot" ) {
		if ( $.reboot_last_time > (Now-milliclicks(500)) ) {
			$.total_reboot_count++
			if ( $.total_reboot_count >= 5 ) {
				$.lcd_message_both("REBOOT\nhas been initiated!")
				$.reboot()
			}
		} else {
			$.lcd_message(side,"Press REBOOT\nfive times quickly\nto do a REBOOT!\n(IT TAKES 3 MINUTES!)")
			$.total_reboot_count = 1
		}
		$.reboot_last_time = Now
	} else if ( bnm == "Restart" ) {
		if ( $.last_total_reset > (Now-milliclicks(500)) ) {
			$.total_reset_count++
			if ( $.total_reset_count >= 2 ) {
				$.lcd_message_both("Restart\nhas been initiated!")
				$.do_total_reset()
			}
		} else {
			$.lcd_message(side,"Press Restart\ntwo times quickly\nto do a\nquick restart!")
			$.total_reset_count = 1
		}
		$.last_total_reset = Now
	} else if ( bnm == "Reset This Side" ) {
		$.lcd_message(side,"Everything\non this side\nhas been reset!")

		$.send_ano_side(side)

		$.reset_all_side(side)

		$.autotrans = $.default_autotrans
		$.autotranspose_index = 0
		$.autotranspose_counter = 0
	} else if ( bnm == "Reset Both Sides" ) {
		$.lcd_message_both("Everything\nON BOTH SIDES\nhas been reset!")

		$.send_ano_both()

		$.reset_all_side(0)
		$.reset_all_side(1)

		$.bpm_index = $.default_bpm_index
		$.set_tempo()

		$.autotrans = $.default_autotrans
		$.autotranspose_index = 0
		$.autotranspose_counter = 0
	} else {
		$.lcd_message(side,"THAT BUTTON\n"+bnm+"\nDOES NOTHING")
	}
}

method set_automate(side) {
	a = $.automate_index[side]
	if ( a == 0 ) {
		$.autotranspose_counter = 0
		$.autotranspose_loops = 0
	} else if ( a == 1 ) {
		$.autotranspose_counter = 0
		$.autotranspose_loops = 1
	} else if ( a == 2 ) {
		$.autotranspose_counter = 0
		$.autotranspose_loops = 4
	} else if ( a == 2 ) {
		$.autotranspose_counter = 0
		$.autotranspose_loops = 16
	}
}

method recalibrate_start() {
	$.recalibrate_obj = new monolith_idobj($)
	print("RECALIBRATE_OBJ = ",$.recalibrate_obj)
	$.recalibrate_obj.doit()
}

method recalibrate_done() {
	$.recalibrate_last_time = 0
	delete $.recalibrate_obj
	$.lcd_message(0,"Doing total reset\nafter recalibration")
	$.lcd_message(1,"Doing total reset\nafter recalibration")
	$.do_total_reset()
}
method silence_me(side) {
	ntrks = $.ntracks[side]
	for ( t=0; t<ntrks; t++ ) {
		$.cleartrack(side,t)
	}
	$.autotranspose_index = 0
	$.autotranspose_counter = 0
	$.send_ano_side(side)
}

method half_looplength(side) {
	ns = $.nsteps[side] / 2
	if ( ns < $.minnsteps )
		ns = $.minnsteps
	$.nsteps[side] = ns
}

method double_looplength(side) {
	ntrks = $.ntracks[side]
	ns = $.nsteps[side]
	newns = $.nsteps[side] * 2
	if ( newns > $.maxnsteps )
		newns = $.maxnsteps
	# Duplicate existing loop to make it longer
	if ( newns != ns ) {
		for ( trk=0; trk<ntrks; trk++ ) {
			for ( n=0; n<ns; n++ ) {
				nsn = ns + n
				if (!(nsn in $.stepvals[side])){
					$.stepvals[side][ns+n] = []
				}
				$.stepvals[side][nsn][trk] = $.stepvals[side][n][trk]
			}
		}
	}
	$.nsteps[side] = newns
}

method mutate_rhythm(side,domessage) {
	nd = 0
	ns = $.nsteps[side]
	ntrks = $.ntracks[side]
	n1 = -1
	trk1 = -1
	n2 = -1
	trk2 = -1
	# print("Before randomize steps =")
	# $.print_stepvals($.stepvals[side],ns,ntrks)
	for ( trk=0; trk<ntrks; trk++ ) {
		for ( n=0; n<ns; n++ ) {
			p = $.stepvals[side][n][trk]
			if ( p != '' && ns > 1 ) {
				# swap with random note on same track
				n2 = n
				while (n2 == n) {
					n2 = rand(ns)
				}
				t = $.stepvals[side][n][trk]
				$.stepvals[side][n][trk] = $.stepvals[side][n2][trk]
				$.stepvals[side][n2][trk] = t
				nd++
			}
		}
	}
	# $.print_stepvals($.stepvals[side],ns,ntrks)
	if ( domessage ) {
		$.lcd_message(side,sprintf("Rhythm of notes\nhas been\nmutated."))
	}
}

method mutate_durations(side,domessage) {
	ns = $.nsteps[side]
	ntrks = $.ntracks[side]
	for ( trk=0; trk<ntrks; trk++ ) {
		for ( n=0; n<ns; n++ ) {
			p = $.stepvals[side][n][trk]
			if ( p != '' ) {
				p.dur = $.dur_choices[rand(sizeof($.dur_choices))]
				$.stepvals[side][n][trk] = p
			}
		}
	}
	# $.print_stepvals($.stepvals[side],ns,ntrks)
	if ( domessage ) {
		$.lcd_message(side,sprintf("Duration of notes\nhas been\nmutated."))
	}
}

method mutate_sounds(side,domessage) {
	ntrks = $.ntracks[side]
	for ( trk=0; trk<ntrks; trk++ ) {
		mx = $.track_chan_range[trk]["max"]
		# Don't include the "Other" channel
		if ( mx == 16 )
			mx = 15
		mn = $.track_chan_range[trk]["min"]
		currentch = $.track_chan[side][trk]
		ch = currentch
		while ( ch == currentch ) {
			ch = mn + rand(mx-mn+1)
		}
		$.track_chan[side][trk] = ch
		$.select_vst(side,trk)
	}
	if ( domessage ) {
		$.lcd_message(side,sprintf("Sounds\nhave been\nmutated."))
	}
}

method remove_notes(side,domessage) {
	ns = $.nsteps[side]
	ntrks = $.ntracks[side]
	nremoved = 0
	toremove = 4
	nts = []
	nnts = 0
	for ( trk=0; trk<ntrks; trk++ ) {
		for ( n=0; n<ns; n++ ) {
			p = $.stepvals[side][n][trk]
			if ( p != '' ) {
				nts[nnts++] = ["trk"=trk,"step"=n]
			}
		}
	}
	if ( nnts < toremove )
		toremove = nnts
	# print("nts=",nts," nnts=",nnts," toremove=",toremove)
	while ( nremoved < toremove ) {
		r = rand(sizeof(nts))
		# print("LOOP nts=",nts," r=",r)
		nnum = 0
		for ( nt in nts ) {
			if ( nnum == r ) {
				step = nts[nt]["step"]
				trk = nts[nt]["trk"]
				$.stepvals[side][step][trk] = ''
				# print("DELETING step=",step," trk=",trk)
				delete nts[nt]
				break
			}
			nnum++
		}
		nremoved++
	}
	nnotesleft = sizeof(nts)
	if ( domessage ) {
		if ( nnotesleft == 0 && toremove == 0 ) {
			$.lcd_message(side,"There are no more\nnotes to remove!")
		} else {
			$.lcd_message(side,sprintf("%d notes were removed,\nthere are %d left.",toremove,nnotesleft))
		}
	}
	return(nnotesleft)
}

method add_to_all(side,domessage,onlydrums) {
	ns = $.nsteps[side]
	noteset = $.noteset_gesture[side]
	nadded = 0
	toadd = 4
	if ( nargs() < 3 )
		onlydrums = 0
	while ( nadded < toadd ) {

		trk = rand($.ntracks[side])
		isdrum = $.is_drum(side,trk)

		if ( onlydrums > 0 && isdrum == 0 )
			continue

		rc = $.get_gesture_rowcol(side,isdrum)
		rows = rc["rows"]
		cols = rc["cols"]

		p = $.make_one_note(side,noteset,rows,cols,isdrum)
		n = rand(ns)
		$.stepvals[side][n][trk] = p
		nadded++
	}
	after = $.notes_in_all_tracks(side)
	if ( domessage ) {
		$.lcd_message(side,sprintf("%d notes were added\nor changed\nacross all sounds.\nTotal notes = %d",nadded,after))
	}
	return(after)
}

method rescale_steps_both() {
	$.rescale_steps(0)
	$.rescale_steps(1)
}

method rescale_steps(side) {

	ntrks = $.ntracks[side]
	nsteps = $.nsteps[side]

	for ( n=0; n<nsteps; n++ ) {
		for ( trk=0; trk<ntrks; trk++ ) {
			if ( $.is_drum(side,trk) )
				continue
			p = $.stepvals[side][n][trk]
			if ( p != '' ) {
				$.stepvals[side][n][trk] = $.closest_gesture_note(side,p)
			}
		}
	}
}
method transpose_random(side,domessage) {
	t = $.transpose_vals[rand(sizeof($.transpose_vals))]
	dir = rand(2)*2 - 1
	t *= dir
	$.manualtranspose_current += t
	if ( $.manualtranspose_current < -12 ) {
		$.manualtranspose_current += 12
		t += 12
	} else if ( $.manualtranspose_current > 12 ) {
		$.manualtranspose_current -= 12
		t -= 12
	}
	if ( domessage ) {
		if ( t < 0 )
			s = "down"
		else
			s = "up"
		$.lcd_message(side,sprintf("Everything has\nbeen transposed\n%s by %d",s,abs(t)))
	}
}

method closest_gesture_note(side,orignt) {
	ncols = $.gesturecols
	nrows = $.gesturerows
	bestdpitch = 9999
	bestnt = ''
	# print("CLOSEST start, orignt=",orignt)
	for (r=0; r<nrows; r++ ) {
		for (c=0; c<ncols; c++ ) {
			nt = $.noteset_gesture[side][r][c]
			# print("nt=",nt," orignt=",orignt)
			dpitch = abs(nt.pitch - orignt.pitch)
			if ( dpitch < bestdpitch ) {
				bestdpitch = dpitch
				bestnt = nt
				# print("New bestdpitch = ",bestdpitch," bestnt=",bestnt)
			}
		}
	}
	if ( bestnt == '' ) {
		bestnt = orignt
	}
	bestnt.vol = orignt.vol
	bestnt.dur = orignt.dur
	bestnt.length = orignt.length
	# print("final BESTNT = ",bestnt)
	return(bestnt)
}

method lcd_message_both(msg) {
	for ( s=0; s<2; s++ ) {
		$.lcd_message(s,msg)
	}
}

method do_total_reset() {
	millisleep(500)
	cmd = "c:\\local\\cygwin\\bin\\sh.exe -c \"c:/local/bin/monokey.bat & \""
	system(cmd)
}

method reboot() {
	millisleep(500)
	cmd = "c:\\local\\cygwin\\bin\\sh.exe -c \"c:/local/bin/qsd.exe -f -r\""
	print("Executing cmd=",cmd)
	system(cmd)
}

method notes_in_all_tracks(side) {
	tot = 0
	ntrks = $.ntracks[side]
	for ( trk=0; trk < ntrks; trk++ ) {
		tot += $.notes_in_track(side,trk)
	}
	return(tot)
}

method notes_in_track(side,trk) {
	nn = 0
	ns = $.nsteps[side]
	for ( n=0; n<ns; n++ ) {
		p = $.stepvals[side][n][trk]
		if ( p != '' ) {
			nn++
		}
	}
	return(nn)
}
method make_one_note(side,noteset,rows,cols,isdrum) {
	r = rand(rows)
	c = rand(cols)
	p = $.note_for_row_col(noteset,r,c,isdrum)
	p.vol = 47+rand(80)
	p.type = NOTE
	p.dur = $.dur_choices[rand(sizeof($.dur_choices))]
	# p = $.do_transpose_and_vol(side,p,isdrum)
	return(p)
}

method reset_all_side(side) {
	print("RESET_ALL_SIDE side=",side)
	$.set_effect(side,$.default_effect[side])
	$.sendenabled_side_effect(side)
	$.side_chord_index[side] = 0
	$.automate_index[side] = $.default_automate
	$.autoplay[side] = $.default_autoplay
	$.auto_complexity[side] = $.default_auto_complexity

	$.side_volume_index[side] = $.volume_default
	$.set_volume(side)

	$.side_style_index[side] = 0
	$.side_scale_index[side] = 0
	$.make_noteset_scale_both()
	$.is_recording[side] = $.default_is_recording
	$.side_lcdmode[side] = "Sound"

	$.nsteps[side] = $.default_nsteps
	$.currstep[side] = 0
	$.currtrack[side] = 0

	$.clear_finger_state(side)
	$.total_reset_count = 0
	$.last_total_reset = 0

	$.last_input = milliclock()
	$.last_button = $.last_input

	ntrks = $.ntracks[side]
	for ( t=0; t<ntrks; t++ ) {

		$.send_pitchbend(side,t,0)

		$.track_octave[side][t] = 0
		$.cleartrack(side,t)
		ch = $.track_default_chan[side][t]
		$.track_chan[side][t] = ch
		$.select_vst(side,t)
	}
}

method print_loop(side) {
	ntrks = $.ntracks[side]
	nsteps = $.nsteps[side]
	$.print_stepvals($.stepvals[side],nsteps,ntrks)
}

method print_stepvals(sv,nsteps,ntrks) {
	for ( n=0; n<nsteps; n++ ) {
		for ( trk=0; trk<ntrks; trk++ ) {
			p = sv[n][trk]
			if ( p != '' ) {
				print("step ",n," trk=",trk," p=",p)
			}
		}
	}
}

method save_loop(side,loopnum,msg) {
	shifted = []
	step = $.currstep[side]
	ntrks = $.ntracks[side]
	nsteps = $.nsteps[side]

	# print("Saving, currstep was ",step)

	while ( (step % 4) != 0 ) {
		step--
	}
	# print("step%4 is ",step)
	for ( n=0; n<nsteps; n++ ) {
		shifted[n] = []
		shiftn = n + step
		if ( shiftn >= nsteps )
			shiftn = shiftn - nsteps
		# print("step=",step," SHIFTN=",shiftn)
		for ( trk=0; trk<ntrks; trk++ ) {
			shifted[n][trk] = $.stepvals[side][shiftn][trk]
		}
	}

	# print("CURRENT stepvals:")
	# $.print_stepvals($.stepvals[side],nsteps,ntrks)
	# print("=====")
	# print("SHIFTED stepvals ")
	# $.print_stepvals(shifted,nsteps,ntrks)
	# print("=====")

	$.loop[side][loopnum] = [
		"stepvals" = arraycopy(shifted),
		# "stepvals" = arraycopy($.stepvals[side]),
		"nsteps" = $.nsteps[side],
		"ntracks" = $.ntracks[side],
		# "fade_index" = $.fade_index[side],
		"transpose" = $.manualtranspose_current,
		"track_chan" = arraycopy($.track_chan[side])
		]
	# print("stepvals=",$.stepvals[side])
	# print("shifted=",shifted)
	# print("nsteps=",$.nsteps[side])

	if ( msg ) {
		nnotes = $.note_count(side)
		$.lcd_message(side,"Saved in\nLoop "+string(loopnum+1)+"\n("+string(nnotes)+" notes)")
	}
}

method load_loop(side,loopnum) {
	lp = $.loop[side][loopnum]
	if ( ! ("stepvals" in lp) ) {
		$.lcd_message(side,"NOTHING IN\nTHAT LOOP")
		print("NOTHING IN THAT LOOP YET!")
		return()
	}
	$.stepvals[side] = arraycopy(lp["stepvals"])
	$.nsteps[side] = lp["nsteps"]
	$.ntracks[side] = lp["ntracks"]
	$.manualtranspose_current = lp["transpose"]
	# $.fade_index[side] = lp["fade_index"]
	$.track_chan[side] = arraycopy(lp["track_chan"])
	ntrks = $.ntracks[side]
	for ( trk=0; trk<ntrks; trk++ ) {
		$.select_vst(side,trk)
	}
	# $.currstep[side] = 0
	# $.currtrack[side] = 0
	nnotes = $.note_count(side)
	lns = string(loopnum+1)
	if ( nnotes == 0 ) {
		$.lcd_message(side,"Loop "+lns+"\nis currently empty!"+
			"\nUse \"Save Loop "+lns+"\" to\nsave something in it")
	} else {
		$.lcd_message(side,"Now Playing\nLoop "+lns+
			"\n("+string($.nsteps[side])+" steps, "+string(nnotes)+" notes)")
	}
}

method note_count(side) {
	ntrks = $.ntracks[side]
	sv = $.stepvals[side]
	count = 0
	for ( n=0; n<$.nsteps[side]; n++ ) {
		svn = sv[n]
		for ( trk=0; trk<ntrks; trk++ ) {
			count += sizeof(svn[trk])
		}
	}
	return(count)
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
	# print("XY-to x/y=",x,y)
	# print("XY-to-rowcol nrows/ncols=",nrows,ncols," returns row/col=",row,col)
	return(["row"=row,"col"=col])
}
method fakegesturedown(m,v,d) {
	side = d["side"]
	istop = d["istop"]
	fingid = 1
	prox = 1.5
	$.finger_state[side][istop][fingid] = 1
	$.finger_state[side][istop]["lastdown"] = fingid
	# print("FAKEGESTUREDOWN,  nargs=",nargs()," args=",argv(0,3))
	# print("FAKEGESTUREDOWN, setting lastdown of side=",side," istop=",istop," to fingid=",fingid)
	$.dogesturedown(fingid,m["relx"],m["rely"],side,prox,istop)
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
	} else if ( proxmode == 4 ) {
		v = integer((((prox+1)*(prox+1))-1) * 30.0)
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

method get_gesture_rowcol(side,isdrum) {
	if ( nargs() < 2 ) {
		isdrum = $.is_drum(side,$.currtrack[side])
	}
	if ( isdrum ) {
		gr = 4
		gc = 4
	} else {
		gr = $.gesturerows
		gc = $.gesturecols
	}
	return(["rows"=gr,"cols"=gc])
}

method dogesturedown(fingid,relx,rely,side,prox,istop) {
	$.last_input = milliclock()
	# lock("monolithgesture")
	$.side_fingersdown[side]++
	if ( istop ) {
		g = $.get_gesture_rowcol(side)
		a = $.xy_to_rowcol(relx,rely,g["rows"],g["cols"])
		# print("dogesturedown note row/col=",a["row"],a["col"])
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
			if ( eff > 0 ) {
				$.effect_onoff(side,eff,1)
				$.do_eff(eff,relx,rely,side,prox)
				# print("SHOULD BE SETTING MIX of effect?")
			}
		}
		$.dogesturedrag(fingid,relx,rely,side,prox,istop)
	}
	# unlock("monolithgesture")
}
method fakegesturedrag(m,v,d) {
	s = d["side"]
	istop = d["istop"]
	fingid = 1
	prox = 1.5
	$.dogesturedrag(fingid,m["relx"],m["rely"],s,prox,istop)
}

method do_eff(eff,relx,rely,side,prox) {

	ch = eff
	port = $.side_port[side]

	# print("do_eff eff=",eff," relxy=",relx,rely," prox=",prox)
	v1 = integer(relx * 128) % 128
	v2 = integer(rely * 128) % 128
	v3 = $.prox2ctrl(prox)

	ctrl1 = $.side_effect_ctrl[side][eff]["x"]
	if ( ctrl1 > 0 ) {
		p1 = controller(ch,ctrl1,v1)
		p1.port = port
		realtime(p1)
	}

	ctrl2 = $.side_effect_ctrl[side][eff]["y"]
	if ( ctrl2 > 0 ) {
		p2 = controller(ch,ctrl2,v2)
		p2.port = port
		realtime(p2)
	}

	ctrl3 = $.side_effect_ctrl[side][eff]["prox"]
	if ( ctrl3 > 0 ) {
		p3 = controller(ch,ctrl3,v3)
		p3.port = port
		realtime(p3)
	}

	# prox does both ctrl3 and mix.  Note mix is always ch 1
	ctrlmix = $.side_effect_ctrl_mix[side]

	if ( $.neverfade > 0 || "nofade" in ($.side_effect_ctrl[side][eff]) ) {
		if ( v3 > 0 ) {
			v3 = 127
		}
	}
	pmix = controller(1,ctrlmix,v3)
	pmix.port = port
	# print("do_eff Sending mix, side=",side," v3=",v3)
	realtime(pmix)
}

method get_lastdown(side,istop) {
	f = $.finger_state[side][istop]["lastdown"]
	if ( $.finger_state[side][istop][f] != 0 ) {
		# print("get_lastdown, returning f=",f)
		return(f)
	}
		
	# look for another one that's down, then
	for ( f in $.finger_state[side][istop] ) {
		if ( f == "lastdown" )
			continue
		if ( $.finger_state[side][istop][f] != 0 ) {
			$.finger_state[side][istop]["lastdown"] = f
			# print("NOW LASTDOWN f=",f)
			return(f)
		}
	}
	return(0)
}

method dogesturedrag(fingid,relx,rely,side,prox,istop) {

	# print("dogesturedrag(fingid=",fingid," relxy=",relx,rely," prox=",prox)
	$.last_input = milliclock()

	# lock("monolithgesture")
	if ( istop ) {
		g = $.get_gesture_rowcol(side)
		a = $.xy_to_rowcol(relx,rely,g["rows"],g["cols"])
		# print("dogesturedrag note row/col=",a["row"],a["col"])
		olda = $.fing_is_down[side][fingid]
		if ( olda == 0 ) {
			print("Hey, olda is 0 for fingid = ",fingid)
			# unlock("monolithgesture")
			return()
		}
		if ( olda["row"] != a["row"] || olda["col"] != a["col"] ) {
			# print("NEW ROW/COL for fing=",fingid," !  a=",a," olda=",olda)
			$.dogridup(side,olda["row"],olda["col"],"gesture")

			vol = $.prox2vol(prox)
			$.fing_is_down[side][fingid] = a
			$.dogriddown(side,a["row"],a["col"],vol,$.noteset_gesture[side],"gesture")
		}
	} else {
		# print("dogesturedrag, fingid = ",fingid)
		# print("   finger_status = ",$.finger_state[side][istop])
		# print("   LASTDOWN = ",$.get_lastdown(side,istop))
		lastdown = $.get_lastdown(side,istop)
		# print("lastdown=",lastdown,"  fingid=",fingid)
		if ( fingid != lastdown ) {
			# print("IGNORING fingid = ",fingid)
			# unlock("monolithgesture")
			return()
		}

		# print("Doing effect for fingid = ",fingid)

		eff = $.side_effect[side]
		if ( eff > 0 )
			$.do_eff(eff,relx,rely,side,prox)
		style = $.side_style_index[side]
		if ( style == 1 || style == 2 ) {
			a = $.xy_to_rowcol(relx,rely,$.gesturerows,$.gesturecols)
			$.side_style_params[side] = $.grid_to_style_params(a["row"],a["col"])
			print("DRAG style=",$.side_style_params[side])
		} else if ( style == 3 ) {
			if ( prox > 0.5 ) {
				trk = $.currtrack[side]
				v = round((prox-0.5) * 4000)
				if ( v > 8191 )
					v = 8191
				$.send_pitchbend(side,trk,v)
			}
		}
		# } else if ( style == 4 ) {
		# 	$.manualtranspose_current = round((relx-0.5) * 24.0)
		# 	print("style transpose = ",$.manualtranspose_current)
		# }
	}
	# unlock("monolithgesture")
}

method send_pitchbend(side,trk,v) {
	ch = $.track_chan[side][trk]
	pb = pitchbend(ch,v)
	pb.port = $.side_port[side]
	print("Sending PITCHBEND, ch=",ch," v=",v)
	realtime(pb)
}

method grid_to_style_params(row,col) {
	return ( ["repeat"=row+1,"time"=1b/8*(col+1)] )
}

method fakegestureup(m,v,d) {
	side = d["side"]
	istop = d["istop"]
	fingid = 1
	prox = 0.0
	$.finger_state[side][istop][fingid] = 0
	$.dogestureup(fingid,m["relx"],m["rely"],side,prox,istop)
}
method dogestureup(fingid,relx,rely,side,prox,istop) {

	$.last_input = milliclock()

	# lock("monolithgesture")
	fd = $.side_fingersdown[side] - 1
	if ( fd < 0 )
		fd = 0
	$.side_fingersdown[side] = fd

	if ( istop ) {
		olda = $.fing_is_down[side][fingid]
		# print("dogestureup note olda=",olda," side=",side)
		if ( olda == 0 ) {
			print("Hey, olda is 0 in dogestureup!?")
			# unlock("monolithgesture")
			return()
		}
		$.dogridup(side,olda["row"],olda["col"],"gesture")
		$.fing_is_down[side][fingid] = 0
	} else {
		if ( $.side_fingersdown[side] == 0 ) {

			eff = $.side_effect[side]

			if ( eff > 0 ) {
				# put mix all the way down (to dry)
				ctrlmix = $.side_effect_ctrl_mix[side]
				pmix = controller(1,ctrlmix,0)
				pmix.port = $.side_port[side]
				# print("dogestureup Sending mix, side=",side," v=0")
				realtime(pmix)

				# print("dogestureup TURNING OFF EFFECT")
				$.effect_onoff(side,eff,0)

			}
			si = $.side_style_index[side]
			if ( si == 3 ) {
				trk = $.currtrack[side]
				$.send_pitchbend(side,trk,0)
			} else if ( si == 4 ) {
				$.manualtranspose_current = 0
			}
		}
	}
	# unlock("monolithgesture")
}

method select_vst(side,trk) {
	$.update_vst_enabled(side)
	$.sendenabled_side(side)
}

method faketriggerdown(m,mm,side) {
	vol = 20 + rand(80)
	$.dogriddown(side,3-m["row"],m["col"],vol,$.noteset_trigger[side],"trigger")
}
method faketriggerup(m,mm,side) {
	$.dogridup(side,3-m["row"],m["col"],"trigger")
}

method make_noteset_scale_both() {
	$.make_noteset_scale(0)
	$.make_noteset_scale(1)
}

method make_noteset_scale(side) {

	lock($)

	scaleindex = $.side_scale_index[side]
	sn = $.scale_names[scaleindex]
	sc = $.scale_notes[sn]
	# print("MAKING SCALE index = ",scaleindex," name=",sn," notes=",sc)
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
	# print("NOTESET side=",side," scale=",$.noteset_trigger[side])

	$.noteset_gesture[side] = []
	pitch0 = 'co2'.pitch
	octave = -1
	if ( scsize < 5 )
		octave = -2
	# print("MAKE_NOTESET_SCALE Starting at octave = ",octave)
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
	# print("Noteset_gesture end of make_noteset_scale = ",$.noteset_gesture[side])
	# print("NOTESET_TRIGGER = ",$.noteset_trigger[side])
	# print("NOTESET_GESTURE = ",$.noteset_gesture[side])
}

method dogriddown(side,row,col,vol,noteset,tt) {

	if ( DebugMonolith ) {
		print("dogriddown side/row/col=",side,row,col," noteset=",noteset)
	}
	if ( $.autoplay[side] != 0 ) {
		$.autoplay_off(side)
	}
	if ( ("Transpose" in $.button_state[side]) && (tt == "trigger") ) {
		t = $.button_state[side]["Transpose"]
		if ( t != 0 ) {
			print("Transpose is down!  row/col=",row,col," t=",t)
			trans = $.grid_to_transpose[row][col]
			print("trans=",trans)
			$.manualtranspose_current = trans
			$.redrawlcd(side)
			return()
		}
	}

	if ( ("HAL9000" in $.button_state[side]) && (tt == "trigger") ) {
		if ( $.button_state[side]["HAL9000"] != 0 ) {
			f = $.grid_to_hal[row][col]
			$.playhal(side,f)
			$.playedhal = 1
			return()
		}
	}

	lock($)

	# print("dogriddown start row/col=",row,col)

	# simulstep = 0
	if ( $.current_down_step[tt][side][row][col] >= 0 ) {
		# print("WARNING WARNING - simultaneous griddown row/col=",row,col," not yet supported!")
		unlock($)
		return()
		# print("\n\nSIMULSTEP=1 !  griddown row/col=",row,col)
		# simulstep = 1
	}

	trk = $.currtrack[side]
	isdrum = $.is_drum(side,trk)

	cstep = $.currstep[side]
	ns = $.step_after(side,cstep)
	# print("fakedown rc=",row,col," step=",cstep," ns=",ns)

	# print("Setting paddown ns=",ns)

	p = $.note_for_row_col(noteset,row,col,isdrum)

	if ( ! isdrum ) {
		# non-drum sounds can be transposed
		p.pitch += 12*$.track_octave[side][trk]
	}
	p.vol = vol
	p.type = NOTEON

	transposed = $.do_transpose_and_vol(side,p,isdrum)

	si = $.side_style_index[side]
	if ( si == 1 ) {
		# params = $.side_style_params[side]
		# d = params["time"]
		# r = params["repeat"]
		d = 0
		if ( vol > 124 ) {
			d = 1b/16
			r = 3
		} else if ( vol > 100 ) {
			d = 1b/8
			r = 3
		} else if ( vol > 70 ) {
			d = 1b/4
			r = 3
		} else {
			# do nothing
		}
		if ( d > 0 ) {
			p.dur = d
			p.length = d
			transposed.dur = d
			transposed.length = d
			p = repeat(p,r)
			transposed = repeat(transposed,r)
		}
	} else if ( si == 2 ) {
		params = $.side_style_params[side]
		p = $.do_style(si,p,params)
		transposed = $.do_style(si,transposed,params)
	}

	$.track_playnote_at(side,trk,transposed,$.nextstep_tm)

	# if ( simulstep ) {
	# 	$.current_down_phr[tt][side][row][col] |= transposed
	# 	$.current_down_phr_notranspose[tt][side][row][col] |= p
	# 	$.current_down_step[tt][side][row][col] = ns
	# 	$.current_down_trk[tt][side][row][col] = trk
	# print("simulstep current_down = ",$.current_down_phr[tt][side][row][col])
	# }

	$.current_down_phr[tt][side][row][col] = transposed
	$.current_down_phr_notranspose[tt][side][row][col] = p
	$.current_down_step[tt][side][row][col] = ns
	$.current_down_trk[tt][side][row][col] = trk

	# print("dogriddown end row/col=",row,col)
	unlock($)
}

method do_style(si,p,params) {
	if ( si == 2 ) {
		tm = params["time"]
		if ( params["repeat"] < 3 ) {
			dpitch = -12
		} else {
			dpitch = 12
		}
		# tm = $.steptm / 4
		p1 = p
		p1.pitch += dpitch
		p1.time += tm
		p2 = p1
		p2.pitch += dpitch
		p2.time += tm
		p = p | p1 | p2
	}
	return(p)
}

method note_for_row_col(noteset,row,col,isdrum) {
	if ( isdrum ) {
		p = makenote($.drum_pitch0 + row*4 + col)
		# print("\nDRUM row/col=",row,col," pitch0=",$.drum_pitch0)
	} else {
		p = noteset[row][col]
		# print("P from noteset is ",p)
	}
	return(p)
}

method do_transpose_and_vol(side,p,isdrum) {
	if ( isdrum ) {
		t = p
		t.vol += $.drum_voloffset
	} else {
		t = $.dotranspose(p)
		t.vol += $.nondrum_voloffset
	}
	return(t)
}
method dogridup(side,row,col,tt) {

	lock($)
	# print("dogridup start row/col=",row,col," tt=",tt)

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
	p.chan = $.track_chan[side][trk]
	p.port = $.side_port[side]

	# print("Playing NOTEOFF at playofftm=",playofftm," p=",p)
	realtime(p,playofftm)

	if ( $.is_recording[side] ) {

		p2 = $.current_down_phr_notranspose[tt][side][row][col]
		p2.type = NOTE
		p2.dur = thisdur
		# print("Calling setstep A step=",downstep," p2=",p2)
		$.setstep(downstep,side,trk,p2)
	}

	$.current_down_phr_notranspose[tt][side][row][col] = ''
	$.current_down_phr[tt][side][row][col] = ''
	$.current_down_step[tt][side][row][col] = -1

	unlock($)
}
method track_playnote_at(side,trk,p,tm) {
	# print("track_playnote_at dNow=",(Now-$.last_played_tm)," p.pitch=",p.pitch," dtm=",(tm-$.last_played_tm))

	p.chan = $.track_chan[side][trk]
	p.port = $.side_port[side]
	# print("track noteon p=",p)
	realtime(p,tm)
	$.last_played_tm = tm
	$.last_played_Now = Now
}
# method realtime_at(p,tm) {
# 	# print("REALTIME_AT SLEEPING! p=",p," tm=",tm)
# 	# sleeptill(tm)
# 	# print("realtime_at tm=",tm," playing p=",p)
# 	realtime(p,tm)
# }

method realtime_now1(p) {
	return(realtime(p,Now+1b/8))
}
method gotgesture(d) {
	print("gotgesture d=",d)
}
method gotgesturerc(type,dev,f,r,c,prox,rawx,rawy) {
	# print("Got gesture, prox=",prox," rawxy=",rawx,rawy)
	if ( $.recalibrate ) {
		print("gotgesturerc ignoring due to recalibrate")
		return()
	}
	$.last_input = milliclock()
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
	if ( type == "fingerdown" ) {
		$.finger_state[side][istop][f] = 1
		$.finger_state[side][istop]["lastdown"] = f
		$.dogesturedown(f,rawx,rawy,side,prox,istop)
	} else if ( type == "fingerdrag" ) {
		$.dogesturedrag(f,rawx,rawy,side,prox,istop)
	} else if ( type == "fingerup" ) {
		$.finger_state[side][istop][f] = 0
		$.dogestureup(f,rawx,rawy,side,prox,istop)
	}
}

method task_failsafe() {
	idlesecs = 60 * 10  # 10 minutes
	delaysecs = 5
	checksecs = 1
	idledt = idlesecs * 1000
	idleshowsound = 10 * 1000  # 10 seconds
	while (1) {
		millisleep(checksecs*1000)
		mc = milliclock()
		if ( mc > ($.last_button + idleshowsound) ) {
			if ( $.autoplay[0] == 0 && $.side_lcdmode[0] != "Sound" ) {
				$.side_lcdmode[0] = "Sound"
				$.redrawlcd(0)
			}
			if ( $.autoplay[1] == 0 && $.side_lcdmode[1] != "Sound" ) {
				$.side_lcdmode[1] = "Sound"
				$.redrawlcd(1)
			}
		}

		if ( mc > ($.last_input + idledt) ) {
			print("failsafe idle!")
			for ( s=0; s<2; s++ ) {
				$.lcd_message(s,"About to restart\ndue to inactivity.\nDO SOMETHING!")
				$.redrawlcd_time[s] = milliclock()+1000*delaysecs
			}
			millisleep(delaysecs*1000+20)
			if ( milliclock() > ($.last_input + idledt) ) {
				for ( s=0; s<2; s++ ) {
					$.lcd_message(s,"RESTARTING DUE\nTO INACTIVITY!")
					$.redrawlcd_time[s] = milliclock()+2000
				}
				millisleep(1000)
				print("failsafe restarting!")
				$.do_total_reset()
			} else {
				for ( s=0; s<2; s++ ) {
					$.lcd_message(s,"WHEW!")
					$.redrawlcd_time[s] = milliclock()+1000
				}
				print("failsafe whew!")
			}
		}
	}
}

method task_monolith_midi() {
	Midiin[$] = f = open()
	while ( (nt=get(f)) != Eof ) {
		if ( $.recalibrate ) {
			print("task_monolith_midi ignoring nt=",nt," due to recalibrate")
			continue
		}
		$.last_input = milliclock()
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
	if ( ! (pitch in $.nanokey_names[lr]) ) {
		print("Pitch=",pitch," not it nanokey_names")
		return("unknown")
	} else {
		return($.nanokey_names[lr][pitch]["name"])
	}
}

method got_nanokey(side,lr,pitch,down) {
	if ( DebugMonolith ) {
		print("GOT NANOKEY, side=",side," lr=",lr," pitch=",pitch)
	}
	bnm = $.nanokey_name(lr,pitch)
	$.keyboardbutton(down,bnm,side,lr)
}

method autoplay_off(side) {
	$.autoplay[side] = 0
	$.nsteps[side] = $.default_nsteps
	$.silence_me(side)
	$.side_lcdmode[side] = "Sound"
	$.redrawlcd(side)
	# print("Turning Automate off for side=",side)
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

	$.send_ano_both()
}
method set_volume(side) {
	v0 = $.volume_values[$.side_volume_index[side]]
	p0 = controller(1,108,v0)
	p0.port = $.side_port[side]
	realtime(p0)
}
method send_ano_both() {
	$.send_ano_side(0)
	$.send_ano_side(1)
}
method send_ano_side(side) {
	a = ano()
	a.port = $.side_port[side]
	realtime(a)
}
method playloop() {
	$.nextstep_tm = nextquant(Now,1b)
	while ( $.keepgoing ) {
		if ( $.recalibrate ) {
			$.nextstep_tm += $.steptm
			sleeptill($.nextstep_tm-4)
			continue
		}
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
		for ( side=0; side<2; side++ ) {
			ns = $.nextstep(side)
			if ( (ns % 4) == 0 && $.loop_next[side] >= 0 ) {
				# print("WILL BE SWITCHING TO LOOP ",$.loop_next[side]," at ns=",ns)
				$.load_loop(side,$.loop_next[side])
				# $.print_loop(side)
				$.loop_next[side] = -1
			}
			if ( ns==0 && $.autoplay[side] == 1 ) {
				$.autoplay_prep(side)
				for ( kk=0; kk<4; kk++ ) {
					$.auto_dorand(side)
				}
				# $.lcd_message(side,"Auto Play\nis ON\nPress anything\nto turn it off")
			}

		}
		sleeptill($.nextstep_tm-4)
	}
}

method autoplay_prep(side) {


	targetnsteps = 64
	while ( $.nsteps[side] < targetnsteps ) {
		$.double_looplength(side)
	}
	while ( $.nsteps[side] > targetnsteps ) {
		$.half_looplength(side)
	}

	c = $.auto_complexity[side]
	if ( $.autoplaytype[side] == 1 ) {
		# drums only
		targetmin = integer(4 * $.nsteps[side] * $.complexity_values[c])
		targetmax = targetmin * 2
	} else {
		ntrks = $.ntracks[side]
		targetmin = integer(ntrks * $.nsteps[side] * $.complexity_values[c])
		targetmax = targetmin * 2
	}
	# print("AUTOPLAY_PREP, nsteps=",$.nsteps[side])
	# print("AUTOPLAY min=",targetmin," max=",targetmax)

	nnotes = $.notes_in_all_tracks(side)
	while ( nnotes < targetmin ) {
		if ( $.autoplaytype[side] == 1 )
			onlydrums = 1
		else
			onlydrums = 0
		nnotes = $.add_to_all(side,0,onlydrums)
	}
	while ( nnotes > targetmax ) {
		nnotes = $.remove_notes(side,0)
	}
}

method auto_dorand(side) {
	r = rand(10)
	# print("auto dorand r=",r)
	if ( r == 0 ) {
		$.transpose_random(side,0)
	} else if ( r == 1 || r == 2 ) {
		if ( $.autoplaytype[side] == 1 ) {
		} else {
			$.add_to_all(side,0)
		}
	} else if ( r == 3 || r == 4 ) {
		$.remove_notes(side,0)
	} else if ( r == 5 || r == 6 ) {
		r = rand(sizeof($.auto_chord_choices))
		ci = $.auto_chord_choices[r]
		$.side_chord_index[side] = ci
		$.make_noteset_scale_both()
	} else if ( r == 7 ) {
		$.mutate_sounds(side,0)
	} else if ( r == 8 ) {
		$.mutate_rhythm(side,0)
	} else if ( r == 9 ) {
		$.mutate_durations(side,0)
	}
}

method quantizetrack(side,trk,qnt) {
	lock($)
	for ( n=0; n<$.nsteps[side]; n++ ) {
		p = $.stepvals[side][n][trk]
		if ( p != '' ) {
			qn = n
			while ( ( qn%qnt ) != 0 ) {
				qn--
			}
			if ( qn != n ) {
				$.stepvals[side][n][trk] = ''
				$.stepvals[side][qn][trk] = p
			}
		}
	}
	unlock($)
}

method cleartrack(side,trk) {
	lock($)
	for ( n=0; n<$.nsteps[side]; n++ ) {
		$.stepvals[side][n][trk] = ''
	}
	unlock($)
	task $.cleartrack_task(side,trk)
}
method cleartrack_task(side,trk) {
	ch = $.track_chan[side][trk]
	# print("CLEARTRACK trk=",trk," ch=",ch," SLEEPING!")
	sleeptill(Now+$.clear_sleeptime)
	p = ano(ch)
	p.port = $.side_port[side]
	realtime(p)
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
	if ( $.autotranspose_current != 0 ) {
		# print("dotranspose applyting autotranspose_current")
		p.pitch += $.autotranspose_current
	}
	if ( $.manualtranspose_current != 0 ) {
		p.pitch += $.manualtranspose_current
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

	if ( cstep == 0 && $.autotranspose_loops>0 && side == 0 ) {
		$.autotranspose_counter++
		if ( $.autotranspose_counter > $.autotranspose_loops ) {
			$.transpose_random(side,0)
			$.autotranspose_counter = 0

			# print("STEP=0, current autotranspose_index = ",$.autotranspose_index)
			# $.autotranspose_index++
			# if ( $.autotranspose_index >= sizeof($.autotranspose_sequence) ) {
			# 	$.autotranspose_index = 0
			# }
			# $.autotranspose_current = $.autotranspose_sequence[$.autotranspose_index]
			print("Transposing autotranspose_index = ",$.autotranspose_index,"  autotranspose_current=",$.autotranspose_current)

		} else {
			# print("Transpose counter = ",$.autotranspose_counter)
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
				p = $.do_transpose_and_vol(side,p,isdrum)
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
			f = $.fade_vals[$.fade_index[side]]
			if ( f < 1.0 ) {
				p = $.stepvals[side][cstep][trk]
				v = round(p.vol * f)
				p.vol = v
				if ( v < $.min_vol ) {
					# print("LoopFaded DELETING trk=",trk," p=",p)
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
method playhal(side,f) {
	if ( nargs() < 2 ) {
		r = rand(sizeof($.HALfiles))
		f = $.HALfiles[r]
	}
	print("playhal, f=",f)
	$.lcd_message(side,"HAL 9000")
	$.redrawlcd_time[side] = milliclock()+2*$.lcdtimeout
	task playmonolithwave(f)
}

}

function get_noteoff(f) {
	m = ''
	while ( (m=get(f)) != Eof ) {
		if ( m.type == NOTEOFF ) {
			break
		}
	}
	return(m)
}

function monolith_id() {
	m = new monolith_idobj(0)
	m.doit()
	deleteobject(m)
}

class monolith_idobj {
method init(callbackobj) {

	$.callbackobj = callbackobj
}

method doit() {

	# make sure all USB.* devices are open
	midiin = midi("input","list")
	for ( num in midiin ) {
		nm = midiin[num]
		if ( nm ~~ "USB.*" ) {
			x = lookforandopen("input",nm,0)
			print("Opening ",nm," = ",x)
		}
	}

	mdep("lcd","clear",0)
	mdep("lcd","backlight",0,1)
	mdep("lcd","clear",1)
	mdep("lcd","backlight",1,0)

	Midiin[$] = f = open()
	gesturenotifyrc($,2,2)

##### side 0

	lcd_multiline(0,"This is side 0\nPress any button\non the left keyboard\nof side 0")
	m = get_noteoff(f)
	Nanokey0L = m.port

	lcd_multiline(0,"This is side 0\nPress any button\non right keyboard\nof side 0")
	m = get_noteoff(f)
	Nanokey0R = m.port

	lcd_multiline(0,"This is side 0\nTap any pad of\nthe 4x4 grid\nof side 0")
	m = get_noteoff(f)
	Trigger0 = m.port

	lcd_multiline(0,"This is side 0\nTouch the upper pad\nof side 0")
	d = $.wait_for_gesture_up()
	Gesture0T = d

	lcd_multiline(0,"This is side 0\nTouch the lower pad\nof side 0")
	d = $.wait_for_gesture_up()
	Gesture0B = d

##### side 1

	mdep("lcd","clear",0)
	mdep("lcd","backlight",0,0)
	mdep("lcd","clear",1)
	mdep("lcd","backlight",1,1)

	lcd_multiline(1,"This is side 1\nPress any button\non left keyboard\nof side 1")
	m = get_noteoff(f)
	Nanokey1L = m.port

	lcd_multiline(1,"This is side 1\nPress any button\non right keyboard\nof side 1")
	m = get_noteoff(f)
	Nanokey1R = m.port

	lcd_multiline(0,"This is side 1\nTap any pad of\nthe 4x4 grid\nof side 1")
	m = get_noteoff(f)
	Trigger1 = m.port

	lcd_multiline(1,"This is side 1\nTouch the upper pad\nof side 1")
	d = $.wait_for_gesture_up()
	Gesture1T = d

	lcd_multiline(1,"This is side 1\nTouch the lower pad\nof side 1")
	d = $.wait_for_gesture_up()
	Gesture1B = d

	ff = open("c:\\monolith_inputs.k","w")
	$.put_midi_input(ff,"Nanokey0R",midiin[Nanokey0R])
	$.put_midi_input(ff,"Nanokey0L",midiin[Nanokey0L])
	$.put_midi_input(ff,"Trigger0",midiin[Trigger0])
	put(ff,sprintf("Gesture0T = %d\n",Gesture0T))
	put(ff,sprintf("Gesture0B = %d\n",Gesture0B))
	put(ff,sprintf("Lcd0 = %d\n",0))

	$.put_midi_input(ff,"Nanokey1R",midiin[Nanokey1R])
	$.put_midi_input(ff,"Nanokey1L",midiin[Nanokey1L])
	$.put_midi_input(ff,"Trigger1",midiin[Trigger1])
	put(ff,sprintf("Gesture1T = %d\n",Gesture1T))
	put(ff,sprintf("Gesture1B = %d\n",Gesture1B))
	put(ff,sprintf("Lcd1 = %d\n",1))
	close(ff)

	closemidi($)
	gestureunnotify($)

	mdep("lcd","clear",0)
	mdep("lcd","clear",1)
	mdep("lcd","backlight",0,1)
	mdep("lcd","backlight",1,1)
	lcd_multiline(0,"Success!")
	lcd_multiline(1,"Success!")
	if ( $.callbackobj != 0 ) {
		o = $.callbackobj
		o.recalibrate_done()
	}
}
method put_midi_input(ff,nm,inname) {
	put(ff,sprintf("%s = lookforandopen(\"input\",\"%s\",0)\n",nm,inname))
}
method wait_for_gesture_up() {
	$.gotup = -1
	while (1) {
		millisleep(100)
		d = $.gotup
		if ( d >= 0 ) {
			return(d)
		}
	}
	
}
method gotgesturerc(ft,dev,f,r,c,prox,rawx,rawy) {
	if ( ft == "fingerup" ) {
		$.gotup = dev
	}
}
}

function playmonolithwave(fn) {
	print("PLAYING fn="+fn)
	cmd = "c:\\windows\\system32\\taskkill /F /IM gdputil.exe & \""
	system(cmd)
	cmd = "c:\\local\\cygwin\\bin\\sh.exe -c \"c:/local/bin/gdputil.exe -play c:/local/monolith2/sounds/" + fn+" & \""
	system(cmd)
}
function playmonolithwave_sync(fn) {
	print("PLAYING fn="+fn)
	cmd = "c:\\windows\\system32\\taskkill /F /IM gdputil.exe & \""
	system(cmd)
	cmd = "c:\\local\\cygwin\\bin\\sh.exe -c \"c:/local/bin/gdputil.exe -play c:/local/monolith2/sounds/" + fn+" \""
	system(cmd)
}
