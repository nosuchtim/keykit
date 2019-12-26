function oldhappy(state) {

	joymapinit()

	p = readmf("joy3.mid")
	p = readmf("joy5.mid")
	p = readmf("joy6.mid")
	# p = 'a,b,c,d,e,f,e,f,a,b,c,d,e,f,e,f'

	# arr1 is 1-note (or chord) per item
	# arr1 = splitonstarts(p)

	initialpatches()
	initialcontrollers()

	padmon = new padmonitor()

	rhythmsets = happy_rhythmsets6()
	psets = happy_patchset6_all()
	# dpsets = happy_drumsets6()
	dpsets = happy_drumsets6soft()

	r = 0

	if ( nargs() < 1 ) {
		state = 3	# GOOD, NEEDS FAIR BIT OF WORK
		state = 4	# GOOD, NEEDS A BIT OF WORK (scratching)

		state = 5	# GREAT - FIRST PART
		state = 6	# GREAT
		# state = 66	#
		state = 7	# GREAT
		# state = 8	# GREAT
	}

	while ( r == 0 ) {
	if ( state == 1 ) {
		# USELESS, IT WAS A TEST
		print("Happy 1a")
		# arr1 = spliteven(p,4b)
		arr1 = spliteven(p,2b)
		r = happydo(global(happy1a),padmon,arr1)
	} else if ( state == 2 ) {
		# USELESS, IT WAS A TEST
		print("Happy 1b")
		# arr1 = spliteven(p,4b)
		arr1 = spliteven(p,1b)
		arr1 = splitonstarts(p,0,2)
		r = happydo(global(happy1b),padmon,arr1)
	} else if ( state == 3 ) {
		print("Happy 3a")
		arr1 = spliteven(p,2b)
		# arr1 = splitonstarts(p,0,2)
		# arr1 = spliteven(p,12b)
		r = happydo(global(happy3a),padmon,arr1)
	} else if ( state == 4 ) {
		print("Happy 3b")
		arr1 = spliteven(p,2b)
		r = happydo(global(happy3b),padmon,arr1)

	} else if ( state == 5 ) {
		# GOOD ONE, also try 3b rather than 6b
		print("Happy 4a")
		arr1 = splitonstarts(p,6b,0)
		# arr1 = splitonstarts(p,3b,0)
		r = happydo(global(happy4a),padmon,arr1)

	} else if ( state == 6 ) {
		# GREAT ONE
		print("Happy 5a")
		arr1 = splitonstarts(p,0,8)
		arr1 = splitonstarts(p,3b,0)
		arr1 = splitonstarts(p,3b/2,0)
		r = happydo(global(happy5a),padmon,arr1)
	} else if ( state == 66 ) {
		print("Happy 5a so so")
		arr1 = splitonstarts(p,0,3)
		# arr1 = splitonstarts(p,1b,0)
		r = happydo(global(happy5a),padmon,arr1)
	} else if ( state == 7 ) {
		print("Happy 6a")
		arr = splitonstarts(p,0,3)
		# arr = splitonstarts(p,3b,0)
		riffsets = setsfromjoy(arr)
		r = happydo(global(happy6a),padmon,
			rhythmsets,riffsets,psets,riffsets,dpsets)
	} else if ( state == 8 ) {
		print("Happy 6aa")
		arr = splitonstarts(p,3b,0)
		# arr = splitonstarts(p,3b,0)
		riffsets = setsfromjoy(arr)
		r = happydo(global(happy6a),padmon,
			rhythmsets,riffsets,psets,riffsets,dpsets)
	} else if ( state == 9 ) {
		print("Happy 6b")
		riffsets = happy_riffsets6()
		r = happydo(global(happy6a),padmon,
			rhythmsets,riffsets,psets,riffsets,dpsets)
	}
	}
	deleteobject(padmon)
}
