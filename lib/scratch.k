function scratchfile() {
	fn = browsefiles("MIDI file to scratch","*.mid",1)
	p = readmf(fn)
	scratch(p)
}
function scratch(fn) {
	if ( nargs() < 1 ) {
		p = readmf("prelude.mid")
	} else if ( typeof(fn) == "string" ) {
		p = readmf(fn)
	} else if ( typeof(fn) == "phrase" ) {
		p = fn
	} else {
		print("Unexpected argument to scratch: ",fn)
		return()
	}
	p = onlynotes(p)
	Merge = 0
	s = new scratcher(p)
	t = task volmonitor([s=1],1)
	s.play()
	Root.waitforconsolekey()
	kill(t)
	s.stop()
	Merge = 1;
}

class scratcher {
method init(ph) {
	$.qnt = 2b
	$.tm0 = 0
	$.scaninc = 2b
	$.scanleng = 2b
	$.scalespeed = 1
	$.quant = 1b/16
	$.playinc = 2b
	$.looptid = -1
	$.realtid = -1
	$.ph = ph
}
method delete {
	kill($.looptid)
	kill($.realtid)
}
method map_0_127(v,v1,v2) {
	f1 = 0
	f2 = 127
	v = v1 + integer(  ((v-f1) * (v2-v1+1)) / (f2-f1+1) )
	return(v)

}
method volchanged(ch,v) {
	if ( ch == 1 ) {
		# We want scaninc to go in "nsteps" steps from -2b to 2b
		nsteps = 32
		lowval = -2b
		highval = 2b

		dval = (highval - lowval)/ nsteps
		nv = $.map_0_127(v,0,nsteps)
		$.scaninc = lowval + dval * nv
		print("nv=",nv," scaninc = ",$.scaninc)

	} else if ( ch == 2 ) {
		nv = $.map_0_127(v,0,4)
		if ( nv == 0 ) {
			$.scanleng = 2b
		} else if ( nv == 1 ) {
			$.scanleng = 1b
		} else if ( nv == 2 ) {
			$.scanleng = 1b/2
		} else if ( nv == 3 ) {
			$.scanleng = 1b/4
		} else if ( nv == 4 ) {
			$.scanleng = 1b/8
		}
		print("scanleng = ",$.scanleng)
	} else if ( ch == 3 ) {

		# dplay = 2b / 16
		# nv = $.map_0_127(v,1,16)
		# $.playinc = dplay * nv
		# print("playinc = ",$.playinc)

		nsteps = 32
		lowval = 1	# 1 click
		highval = 2b

		dval = (highval - lowval)/ nsteps
		nv = $.map_0_127(v,0,nsteps)
		$.playinc = lowval + dval * nv
		print("playinc = ",$.playinc)

	} else if ( ch == 4 ) {
		nv = $.map_0_127(v,0,4)
		if ( nv == 0 ) {
			$.scalespeed = 0.5
		} else if ( nv == 1 ) {
			$.scalespeed = 1
		} else if ( nv == 2 ) {
			$.scalespeed = 2
		} else if ( nv == 3 ) {
			$.scalespeed = 3
		} else if ( nv == 4 ) {
			$.scalespeed = 4
		}
		print("scalespeed = ",$.scalespeed)
	} else if ( ch == 5 ) {
		nv = $.map_0_127(v,0,4)
		if ( nv == 0 ) {
			$.quant = 1b/2
		} else if ( nv == 1 ) {
			$.quant = 1b/4
		} else if ( nv == 2 ) {
			$.quant = 1b/8
		} else if ( nv == 3 ) {
			$.quant = 1b/16
		} else if ( nv == 4 ) {
			$.quant = 1b/32
		}
		print("quant = ",$.quant)
	}
}
method play {
	$.looptid = task $.taskloop()
}
method stop {
	kill($.looptid)
	kill($.realtid)
	$.looptid = -1
	$.realtid = -1
}
method taskloop(tm) {
	$.tm = nextquant(Now,$.qnt)
	while ( 1 ) {
		sleeptill($.tm)
		p = cut($.ph,CUT_TIME,$.tm0,$.tm0+$.scanleng)
		p = strip(p)
		p = scatimes(p,1.0/$.scalespeed)
		p = arpeggio(p)
		p = step(p,$.quant)
		# p.time -= $.tm0
		kill($.realtid)
		$.realtid = realtime(p)
		$.tm0 += $.scaninc
		if ( $.tm0 < 0 ) {
print("at beginning of phrase")
			$.tm0 = 0
		} else if ( $.tm0 > $.ph.length ) {
print("at end of phrase, wrapping around $.ph.length=",$.ph.length," tm0=",$.tm0)
			# $.tm0 = $.ph.length
			$.tm0 = 0
		}
		$.tm += $.playinc
	}
}
}
