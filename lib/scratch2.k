function scratch2file() {
	fn = browsefiles("MIDI file to scratch2","*.mid",1)
	p = readmf(fn)
	scratch2(p)
}
function scratch2(fn) {
	if ( nargs() < 1 ) {
		p = readmf("joy.mid")
	} else if ( typeof(fn) == "string" ) {
		p = readmf(fn)
	} else if ( typeof(fn) == "phrase" ) {
		p = fn
	} else {
		print("Unexpected argument to scratch2: ",fn)
		return()
	}
	p = onlynotes(p)
	Merge = 0

	obj1 = new scratch2er(p,0)
	obj2 = new scratch2er(p,8)

	t = task volmonitor([obj1=1,obj2=2],1)

	obj1.play()
	obj2.play()

	Root.waitforconsolekey()
	kill(t)
	obj1.stop()
	obj2.stop()
	Merge = 1;
}

class scratch2er {
method init(ph,ch_offset) {
	$.ch_offset = ch_offset
	$.qnt = 2b
	$.scaninc = 2b
	$.scanleng = 2b
	$.scalespeed = 1
	$.quant = 1b/16
	$.playinc = 2b
	$.looptid = -1
	$.realtid = -1
	$.posinc = 1
	$.posinc_delay = 1
	$.posinc_delay_count = 0
	$.posinc_repeat = 1
	$.posinc_repeat_count = 0
	$.forcechan = 0
	$.set(ph)
}
method set(ph) {
	$.ph = []
	i=0
	for ( n in ph ) {
		$.ph[i++] = n
	}
	$.maxi = i
	$.i = 0
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
	if ( ch == (1+$.ch_offset) ) {
		nv = $.map_0_127(v,0,4)
		if ( nv == 0 ) {
			$.playinc = 1b/8
		} else if ( nv == 1 ) {
			$.playinc = 1b/4
		} else if ( nv == 2 ) {
			$.playinc = 1b/2
		} else if ( nv == 3 ) {
			$.playinc = 1b
		} else if ( nv == 4 ) {
			$.playinc = 2b
		}
		print("playinc = ",$.playinc)
	} else if ( ch == (2+$.ch_offset) ) {

		nv = $.map_0_127(v,0,8)
		$.posinc = nv - 4
		print("posinc = ",$.posinc)

	} else if ( ch == (3+$.ch_offset) ) {
		# This controls the number of notes we play
		# before doing the $.posinc thing
		nv = $.map_0_127(v,1,4)
		$.posinc_delay = nv
		print("posinc_delay = ",$.posinc_delay)
	} else if ( ch == (4+$.ch_offset) ) {
		# This controls the number of notes we repeat
		nv = $.map_0_127(v,1,4)
		$.posinc_repeat = nv
		print("posinc_repeat = ",$.posinc_repeat)
	} else if ( ch == (5+$.ch_offset) ) {
		# This controls the number of notes we repeat
		nv = $.map_0_127(v,0,16)
		$.forcechan = nv
		print("channel = ",$.forcechan)
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
method inc(amount) {
	if ( nargs() < 1 )
		amount = $.posinc
	if ( $.posinc_repeat > 1 ) {
		$.posinc_repeat_count++
		if ( $.posinc_repeat_count >= $.posinc_repeat ) {
print("POSINC_REPEAT hit")
			$.realinc(amount)
			$.posinc_repeat_count = 0
		} else {
			# don't increment, i.e. repeat
			$.posinc_repeat_count++
		}
	} else {
		$.realinc(amount)
	}
}
method realinc(amount) {
	$.i += amount
	if ( $.i >= $.maxi )
		$.i = 0
	else if ( $.i < 0 )
		$.i = $.maxi-1
	# print("i=",$.i)
}
method taskloop(tm) {
	$.tm = nextquant(Now,$.qnt)
	while ( 1 ) {
		sleeptill($.tm)

		p = $.ph[$.i]
		if ( $.forcechan > 0 )
			p.chan = $.forcechan

		# Advance i under the control of lots of sliders
		if ( $.posinc_delay > 1 ) {
			$.posinc_delay_count++
			if ( $.posinc_delay_count >= $.posinc_delay ) {
				$.posinc_delay_count = 0
				$.inc()
			} else {
				# For posinc_delay times,
				# we only increment by 12
				$.inc(1)
			}
		} else {
			$.inc()
		}

		p = strip(p)

		kill($.realtid)
		$.realtid = realtime(p)
		$.tm += $.playinc
	}
}
}
