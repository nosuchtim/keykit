function slotsfile() {
	fn = browsefiles("MIDI file to slots","*.mid",1)
	p = readmf(fn)
	slots(p)
}
function slots(fn) {
	if ( nargs() < 1 ) {
		p = readmf("joy2.mid")
	} else if ( typeof(fn) == "string" ) {
		p = readmf(fn)
	} else if ( typeof(fn) == "phrase" ) {
		p = fn
	} else {
		print("Unexpected argument to slots: ",fn)
		return()
	}
	p = onlynotes(p)
	Merge = 0
	s1 = new slotplayer(p)
	t = new padmonitor()
	t.notify(s1)
	s1.play()
	Consecho = 0
	esc = ascii(27)
	while ( (c=Root.waitforconsolekey()) != esc ) {
		if ( c == "q" )
			break;
		s1.add(c)
	}
	Consecho = 1
	deleteobject(t)
	s1.stop()
	Merge = 1;
}

class slotplayer {
method init(ph) {
	$.qnt = 2b
	$.randamount = 0
	$.backamount = 0
	$.preamount = 0
	$.echoamount = 0
	$.looptid = -1
	$.realtid = -1

	$.arr = splitonstarts(ph)
	$.arrsz = sizeof($.arr)

	$.slot = []
	$.slotdt = []
	$.slotpre = []
	$.slotecho = []
	$.slotchan = []
	$.nslot = 16
	$.arrpos = 0
	$.defdt = 1b/4
	$.maxdt = 1b
	for ( n=0 ; n<$.nslot; n++ ) {
		$.slotdt[n] = $.defdt
		$.slotpre[n] = 0
		$.slotecho[n] = 0
		$.slotchan[n] = 1
		# $.setslot(n,'')
		$.setslot(n,$.nextarr())
	}
	$.sloti = 0
}
method setslot(n,p) {
	$.slot[n] = p
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
method add(c) {
	if ( c == "1" ) {
		$.setslot($.sloti,$.nextarr())
	} else if ( c == "2" ) {
		for ( n=0; n<$.nslot; n++ ) {
			i = ($.sloti + n) % ($.nslot)
			$.setslot(i,$.nextarr())
		}
	} else if ( c == "3" ) {
		currdt = $.slotdt[$.sloti]
		if ( currdt < $.maxdt ) {
			# find a slot that has enough time to give up
			for ( n=1; n<$.nslot; n++ ) {
				tn = ($.sloti+n) % ($.nslot)
				if ( $.slotdt[tn] >= currdt ) {
print("Sub from tn=",tn)
					$.slotdt[tn] -= currdt
					break
				}
			}
			if ( n < $.nslot ) {
				# if we found one to give it up, we
				# can add it to this one
print("Add to sloti=",$.sloti)
				$.slotdt[$.sloti] += currdt
			}
		}
	} else if ( c == "4" ) {
		$.slotdt[$.sloti] = $.defdt
	} else if ( c == "5" ) {
		$.slotpre[$.sloti] = 1
	} else if ( c == "6" ) {
		ni = ($.sloti + 1 ) % ($.nslot)
print("echo ni=",ni)
		$.slot[ni] = $.slot[$.sloti]
	} else if ( c == "7" ) {
print("clear pre and echo")
		for ( i in $.slot ) {
			$.slotecho[i] = 0
			$.slotpre[i] = 0
		}
	} else if ( c == "8" ) {
		$.slotchan[$.sloti] = rand(4)+1
	} else if ( c == "9" ) {
print("clear chan")
		for ( i in $.slot ) {
			$.slotchan[i] = 1
		}
	} else if ( c == "s" )
		$.setslot($.sloti,'')
}
method nextarr {
	if ( $.arrpos >= $.arrsz )
		$.arrpos = 0
	return($.arr[$.arrpos++])
}
method padchanged(j,b,v) {
	print("method padchanged, joy=",j," but=",b," value=",v)
	if ( b == "START" && v == 1 ) {
print("START pressed! isplaying=",$.isplaying())
		if ( $.isplaying() )
			$.stop()
		else
			$.play()
	}
}
method play() {
	$.looptid = task $.taskloop()
}
method isplaying() {
	return ( $.looptid >= 0 )
}
method stop {
	kill($.looptid)
	kill($.realtid)
	$.looptid = -1
	$.realtid = -1
}
method taskloop() {
	$.tm = nextquant(Now,$.qnt)
	i = 0
	noback = 0
	$.sloti = 0
	while ( 1 ) {
		sleeptill($.tm-2)
		i = $.sloti
		p = $.slot[i]
		if ( $.slotpre[i] ) {
			p = p | preecho(p,3,1b/8,0.6)
			p.time -= p%1.time
		}
		if ( $.slotecho[i] )
			p = echo(p,2,1b/4,0.7)
		p.chan = $.slotchan[i]
		$.realtid = realtime(p,$.tm)
		$.tm += $.slotdt[i]
		$.sloti++
		if ( $.sloti >= $.nslot )
			$.sloti = 0
	}
}
}
