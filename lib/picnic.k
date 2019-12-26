# NOTES:
#################
## FRIDAY HOLIDAY BASH
#################
#
#	This is for the State Machine/Hypercube medley.
#
#       NORD:
#            1 - Schuman Lead   427 or 901    MIDI channel 1
#            2 - percuss b3     178 or 902    MIDI channel 2
#            3 - Feedback Lead  118 or 903    MIDI channel 3
#            4 - square harp    189 or 904    MIDI channel 4
#
#        perform EFX source should be set to P6 (organ)
#
#        On channel 6, the output assign should be Eff
#        perform EFX source should be set to P6 (organ)
#        MAKE SURE CHANNEL ON NORD patch 2 is set to TWO (2), NOT 6
#
#        Run picnic2() to start it.  This will mute
#	channels 1,2,3,4 on the JV1010
#


#################
## PICNIC SET
#################
#    SET 1
#        Run picnic()
#        MAKE SURE CHANNEL ON NORD patch 2 is set to SIX (6), NOT 2
#
#        NORD:
#            1 - Schuman Lead   427 or 901
#            2 - percuss b3     178 or 902
#            3 - Feedback Lead  118 or 903
#            4 - square harp    189 or 904
#
#################
#    SET 2
#
#	This is for the State Machine/Hypercube medley.
#
#       NORD:
#            1 - Schuman Lead   427 or 901    MIDI channel 1
#            2 - percuss b3     178 or 902    MIDI channel 2
#            3 - Feedback Lead  118 or 903    MIDI channel 3
#            4 - square harp    189 or 904    MIDI channel 4
#
#        perform EFX source should be set to P6 (organ)
#
#        On channel 6, the output assign should be Eff
#        perform EFX source should be set to P6 (organ)
#        MAKE SURE CHANNEL ON NORD patch 2 is set to TWO (2), NOT 6
#
#        Run picnic2() to start it.  This will mute
#	channels 1,2,3,4 on the JV1010
#

function picnic() {
	HI = picnic_reset()
	realtime(HI)
}

function picnicmedley() {
	picnic2()
}

function picnic2() {

	tempo(545000)
	HI = picnic_reset()
	realtime(HI)

	dir = "c:\\tjt\\music\\picnic\\"

	# HA = readmf(dir+"hyper_a.mid")
	# HA = readmf(dir+"hyper_a2.mid")
	HA = readmf(dir+"hyper_a3.mid")
	# HB = readmf(dir+"hyper_b.mid")
	# The b2 one has the 1-step transpose in the middle
	HB = readmf(dir+"hyper_b2.mid")
	HBB = repeat(HB,6)

	HC = cut(readmf(dir+"hyper_c.mid"),CUT_TIME,0,16b,TRUNCATE)
	HC.length = 16b
	HC2 = cut(readmf(dir+"hyper_c2.mid"),CUT_TIME,0,16b,TRUNCATE)
	HC2.length = 16b
	HCC = repeat(HC|HC2,16)

	tm = nextquant(Now,8b)
	t1 = realtime(HA,tm)
	c = ""
	while ( c != "X" ) {
		print("press X when ready to transition...")
		c = Root.waitforconsolekey()
	}

	tm = nextquant(Now,8b)
	t2 = realtime(HBB,tm)
	sleeptill(tm)
	kill(t1)
	c = ""
	while ( c != "X" ) {
		print("press X when ready to fade out...")
		c = Root.waitforconsolekey()
	}

	tm = nextquant(Now,8b)
	t3 = realtime(HCC,tm)
	sleeptill(tm)
	kill(t2)
	c = ""
	while ( c != "X" ) {
		print("press X when ready to quit...")
		c = Root.waitforconsolekey()
	}
	kill(t3)
	# realtime(gmresetall())
	# realtime(ano())
}

function picnic_reset(set) {

	if ( nargs() < 1 )
		set = 0

	r = ''

	# Piano for State Machine
	r += jv_bank_patch(5,"A",9)

	# Organ
	r += jv_bank_patch(6,"A",55)

	# a reedy thing
	r += jv_bank_patch(7,"A",103)

	# strings
	r += jv_bank_patch(8,"C",61)

	# steel guitar
	r += jv_bank_patch(9,"A",111)

	# good dynamic piano
	r += jv_bank_patch(11,"A",18)

	# ethereal 
	r += jv_bank_patch(12,"S",111)

	if ( set == 1 ) {
		# Organ
		r += jv_bank_patch(2,"A",55)
	}

	# Bright E. Piano
	r += jv_bank_patch(7,"A",25)

	# Electronic Drums
	r += jv_bank_patch(10,"B",2)

	# Turn the Expresson (controller 11) down on first 4 channels
	# This doesn't affect the Nord - they're listening to controller 7
	r += controller(1,11,0)
	r.length++
	if ( set != 1 ) {
		r += controller(2,11,0)
		r.length++
	} else {
		r += controller(2,11,100)
		r.length++
	}
	r += controller(3,11,0)
	r.length++
	r += controller(4,11,0)
	r.length++

	# Adjust Nord sounds
	r += controller(1,7,100)
	r.length++
	r += controller(2,7,100)
	r.length++
	r += controller(3,7,100)
	r.length++
	r += controller(4,7,100)
	r.length++

	# Piano on JV1010
	r += controller(5,7,120)
	r.length++
	r += controller(5,11,127)
	r.length++

	# Organ on JV1010
	r += controller(6,7,65)
	r.length++
	r += controller(6,11,127)
	r.length++

	# Adjust the Expresson and volume on all other channels
	for ( c=7; c <= 16; c++ ) {
		r += controller(c,7,100)
		r.length++
		r += controller(c,11,100)
		r.length++
	}

	# Drums on JV1010
	r += controller(10,7,120)
	r.length++
	r += controller(10,11,127)
	r.length++

	return(r)
}
