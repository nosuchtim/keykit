function joyecho3file() {
	fn = browsefiles("MIDI file to joyecho3","*.mid",1)
	p = readmf(fn)
	joyecho3(p)
}
function joyecho3(fn) {

	joymapinit()

	if ( nargs() < 1 ) {
		# p = 'c,d,e,f,g,c,d,e,f,g'
		p = readmf("joy2.mid")
	} else if ( typeof(fn) == "string" ) {
		p = readmf(fn)
	} else if ( typeof(fn) == "phrase" ) {
		p = fn
	} else {
		print("Unexpected argument to joyecho3: ",fn)
		return()
	}
	p = onlynotes(p)
	Merge = 0
	s1 = new joyecho3er(p)
	t = new padmonitor()
	t.notify(s1)
	nw = Now
	Root.waitforconsolekey()
	deleteobject(t)
	s1.stop()
	Merge = 1;
}

class joyecho3er {
method init(ph) {
	$.qnt = 2b
	$.randamount = 0
	$.backamount = 0
	$.echoamount = 0

	$.midstepsize = 1b/4

	# Per-joystick things
	$.njoy = sizeof(joyinit())
	print("njoy=",$.njoy)
	if ( $.njoy < 4 ) {
		print("Hey, expected at least 4 pads to be connected!")
	}
	$.pos = -1
	$.riff = []
	$.necho = []
	$.realtid = []
	$.ch = []
	$.outport = []
	$.octshift = []
	$.totshift = []
	$.pause = []
	$.trill = []
	$.slower = 0
	$.pad = [0=[],1=[],2=[],3=[]]
	$.myloop = []

	butts = padbuttons()
	for ( j=0; j<4; j++ ) {
		$.pad[j] = []
		for ( s in butts ) {
			$.pad[j][s] = 0
		}
	}

	for ( n=0; n<$.njoy; n++ ) {
		$.riff[n] = ''
		$.necho[n] = 16
		$.realtid[n] = -1
		$.ch[n] = n+1
		$.outport[n] = 0
		$.octshift[n] = 0
		$.totshift[n] = 0
		$.pause[n] = 0
		$.trill[n] = 0
	}
	$.echoquant = 1b
	$.triggerquant = 1b/4
	
	tm = nextquant(Now+20,$.triggerquant)

	$.fout = open()

	$.arr = splitonstarts(ph,1b)
	$.arrsz = sizeof($.arr)

	$.mid1_tid = task $.middle_stepper(tm,1)
	$.mid2_tid = task $.middle_stepper(tm,2)
	$.mid3_tid = task $.middle_stepper(tm,3)

	$.final_tid = task $.final_stepper(tm)
}
method stop {
	kill($.mid1_tid)
	kill($.mid2_tid)
	kill($.mid3_tid)
	kill($.final_tid)
}
method next_input {
	lock($)
	$.pos++
	if ( $.pos >= $.arrsz ) {
		$.pos = 0
	}
	r = $.arr[$.pos]
	unlock($)
	return(r)

}
method delete {
	$.stop()
}
method trigger(j,doecho) {
	if ( nargs() < 1 )
		doecho = 0
	if ( ! (j in $.riff) ) {
		print("No j=",j," in $.riff")
		return()
	}
	tm = Now
	tm = nextquant(tm,$.triggerquant)
	if ( j in $.realtid ) {
		kill($.realtid[j])
	}
	$.realtid[j] = task $.steppertask(j,tm)
}

method middle_putloop(j) {
	n = $.myloop[j][$.looppos]
	n.chan = j
	n.time += tm
	put($.fout,n)
}

method middle_stepper(tm,j) {
	$.myloop[j] = []
	islooping = 0
	collecting = 0
	looppos = -1
	while ( 1 ) {
		sleeptill(tm-2)
		fsz = fifosize($.fout)
		if ( fsz > 1 ) {
			tm += $.midstepsize
			continue
		}

		if ( islooping ) {
			# If SQUARE is hit, it turns off looping
			if ( $.pad[j]["SQUARE"] == 1 ) {
print("Clearing loop for j=",j)
				$.myloop[j] = []
				islooping = 0
				looppos = -1
				collecting = 0
			} else {
				looppos++
				if ( looppos >= sizeof($.myloop[j]) )
					looppos = 0

				if ( ! (looppos in $.myloop[j]) ) {
					print("Hey, looppos=",looppos," not in myloop?")
					looppos = -1
				} else {
if(fifosize($.fout)>100){print("Hey, fifosize $.fout > 100!")}
					n = $.myloop[j][looppos]
					n.chan = j
					n.time += tm
					put($.fout,n)
				}
			}
		} else if ( collecting ) {
			# If we're collecting, look for release
			# of UP pad to stop collecting and start looping
			if ( $.pad[j]["UP"] == 0 ) {
				collecting = 0
				islooping = 1
				looppos = 0

				n = $.myloop[j][looppos]
				n.chan = j
				n.time += tm
				put($.fout,n)
			} else {
				# Add to loop
				n = $.next_input()
				$.myloop[j][sizeof($.myloop[j])] = n
print("myloop is now ",sizeof($.myloop[j])," big, fifosize of $.fout is ",fifosize($.fout))
				n.chan = j
				n.time += tm
				put($.fout,n)
			}
		} else if ( $.pad[j]["X"] && fsz < 1 ) {
			n = $.next_input()
			n.chan = j
			n.time += tm
			# if ( $.octshift[j] ) {
			# 	$.totshift[j] += $.octshift[j] * 12
			# 	n.pitch += $.totshift[j]
			# }
			put($.fout,n)
		} else if ( $.pad[j]["UP"] ) {
			# Add to loop
			n = $.next_input()
			$.myloop[j][sizeof($.myloop[j])] = n
print("myloop is now ",sizeof($.myloop[j])," big, looppos =",looppos)
			n.chan = j
			n.time += tm
			put($.fout,n)
			collecting = 1
print("COLLECTING ON!")
		} else {
			if ( fsz > 1000 ) {
				print("$.fout for j=",j," is > 1000")
			}
		}
		tm += $.midstepsize
	}
}

method final_stepper(tm) {
	last_note_time = 0
	last_note_dur = 0
	ch = 1
	pshift1 = 0
	pshift2 = 0
	pshift1pos = 0
	pshift2pos = 0
	shiftarr = [	0=0,
			1=5,
			2=2,
			3=5,
			4=-12,
			5=-12,
			6=12,
			7=12,
			8=-5,
			9=-2,
			10=-5,
			11=2
		]
	while ( 1 ) {
		if ( tm < Now ) {
			tm = nextquant(Now,$.triggerquant)
		}
		n = get($.fout)
		if ( n.time == last_note_time ) {
			# want to play it at the same time as last one
		} else {
			tm += last_note_dur
			sleeptill(tm-2)
		}
		last_note_time = n.time
		n.time -= n%1.time

		if ( $.pad[0]["X"] ) {
			n.pitch += 12
		}
		if ( $.pad[0]["UP"] ) {
			n = arpeggio(n)
		}
		if ( $.pad[0]["CIRCLE"] ) {
			for ( i=1; i<=sizeof(n); i++ ) {
				n%i.chan = ch++
				if ( ch > 3 )
					ch = 1
			}
		}
		if ( $.pad[0]["RIGHT"] ) {
			for ( i=1; i<=sizeof(n); i++ ) {
				if ( rand(2) == 0 ) 
					n%i = ''
			}
		}
		if ( $.pad[0]["DOWN"] ) {
			n = mono(n)
			n.length = latest(n)
		}

		if ( $.pad[0]["TRIANGLE"] ) {
			pshift1pos++
			if ( pshift1pos in shiftarr )
				pshift1 += shiftarr[pshift1pos]
			n.pitch += pshift1
		} else {
			pshift1 = 0
			pshift1pos = 0
		}

		if ( $.pad[0]["LEFT"] ) {
			pshift2pos++
			if ( pshift2pos in shiftarr )
				pshift2 += shiftarr[pshift2pos]
			n.pitch += pshift2
		} else {
			pshift2 = 0
			pshift2pos = 0
		}

		if ( $.pad[0]["SQUARE"] ) {
			result = ''
			for ( nt in n ) {
				if ( rand(3) == 0 ) { 
					nt = preecho(nt,2,1b/4,0.7)
				}
				result |= nt
			}
			n = result
			t1 = n%1.time
			if ( t1 < 0 ) {
				n.time -= t1
			}
			n.length = latest(n)
		}

		# print("FINAL STEPPER n=",n," tm=",tm)
		realtime(n,tm)
		last_note_dur = n.length
	}
}
method pad0changed(b,v) {
	print("Pad 0 ",b," ",v)
}
method padchanged(j,b,v) {

	j = JoyMap[j]

	$.pad[j][b] = v

	if ( j == 0 ) {
		$.pad0changed(b,v)
		return()
	}
	print("Pad j=",j," b=",b," v=",v)
}
method play(tm) {
}
}
