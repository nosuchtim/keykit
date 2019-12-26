#
# This file contains works in progress for the "call for algorithmic shorts"
#

function shots_B(xval,seed,numgens) {
	return(shots_AA(xval,seed,numgens,"default.exp"))
}

function shots_AA(xval,seed,numgens,fname) {
	transforms = read_transforms(pathsearch(fname))
	if ( nargs() < 2 ) {
		seed = 12345
	}
	if ( nargs() < 3 ) {
		numgens = 9 + 1
	}
	rand(-seed)
	r = gen_expresso(transforms,numgens,xval)
	return(r)
}

function firstbars(a,bars) {
	r = cut(a,CUT_TIME,0,bars*4b)
	r.length = bars*4b
	return(r)
}

function shots_TZ(p) {
	stop()
	r = rand(9999999)
	print(r)
	Snarf = firstbars(shots_B(p,r,15),2)
	return(Snarf)
}

function SU() {
	return(shots_TZ('c f+ b'))
}

function RR() {
	rand(-currtime())
}

function shots() {
	u = 'c'
	u = 'c f+ b'
	ng = 15
	p =  '' 
		+firstbars(shots_B(u,2082481,ng),1)	# good (4 chords)
		+firstbars(shots_B(u,5190831,ng),1)	# good (4 chords)
		+firstbars(shots_B(u,5675877,ng),1)	# another (4 chords)
		+firstbars(shots_B(u,3005187,ng),1)	# good
		+firstbars(shots_B(u,1402518,ng),1)	# good
		+firstbars(shots_B(u,3846440,ng),1)	#
		+firstbars(shots_B(u,2226522,ng),1)	#
		+firstbars(shots_B(u,7071751,ng),1)	#
		+firstbars(shots_B(u,867315,ng),1)	# nice bass
		+firstbars(shots_B(u,7030760,ng),1)	# followup nice bass
		+firstbars(shots_B(u,829717,ng),2)	# great!
		+firstbars(shots_B(u,9195853,ng),2)	# bright!
		+firstbars(shots_B(u,3839497,ng),2)	# good
		+firstbars(shots_B(u,5681687,ng),1)	# good
		+firstbars(shots_B(u,4304526,ng),1)	#
		+firstbars(shots_B(u,5771437,ng),1)	# good - 3 chords/pause
		+firstbars(shots_B(u,8101228,ng),2)	# good
		+firstbars(shots_B(u,1901878,ng),2)	# good
		+firstbars(shots_B(u,5515156,ng),2)	# good
		+firstbars(shots_B(u,9422250,ng),2)	# new
		+firstbars(shots_B(u,4635838,ng),1)	# frantic
		+firstbars(shots_B(u,29423,ng),1)		# 
		+firstbars(shots_B(u,4004266,ng),1)	# end

	return(p)
}

