class grabplayer {
method init(arr,tm,ch,arrbegin) {
	$.tm = tm
	$.stopme = 0
	$.lastpos = arrbegin
	$.r = ''
	$.ch = ch
	$.tid = task $.grabtask(arr,arrbegin)
}
method delete {
	kill($.tid)
}
method grabtask(arr,arrbegin) {
	n = arrbegin
	tm0 = $.tm
	lng = 0
	rp2 = ''
	while ( (n in arr) && $.stopme == 0 ) {
		p = arr[n]
		p.chan = $.ch

		rp = p
		rp.time += ($.tm - tm0)
		rp2 |= rp
		rp2.length = $.tm - tm0 + latest(p)

		realtime(p,$.tm)
		dt = p.length
		$.tm += dt
		sleeptill($.tm-2)
		n++
	}
	$.r = rp2
	if ( n > arrbegin )
		$.lastpos = n - 1
}
method getlastpos {
	return($.lastpos)
}
method stopandgrab {
	$.stopme = 1
	wait($.tid)
	# print("stopandgrab $.r = ",$.r)
	return($.r)
}
}

##################################################

class loopplayer {
method init(p,tm,lng,ch,nloops,fadeamount) {
	if ( nargs() < 6 )
		fadeamount = 0
	$.tm = tm
	$.stopme = 0
	$.ch = ch
	$.fadeamount = fadeamount
	if ( typeof(p) == "object" ) {
		$.requestobj = p
	} else {
		$.requestobj = $0
		$.p = p
		$.lng = lng
	}
	$.nloops = nloops
	$.playquant = 1b/4
	$.step = 0
	$.steptm = 1b/4
	$.mute = 0
	$.pausing = 0
	$.shifty = 0
	$.pornament = ''
	$.resynctm = 0
	$.stopme = 0

	$.getnext()

	$.tid = task $.playtask()
}
method getnext {
	if ( $.requestobj != $0 ) {
		obj = $.requestobj
		$.p = obj.requestnext()
		# when there are no more phrases in the input, stop
		if ( $.p == 0 )
			$.stopme = 1
		else {
			$.lng = nextquant(latest($.p),$.playquant)
			if ( $.ch > 0 ) {
				p = $.p
				p.chan = $.ch
				$.p = p
			}
		}
	}
}
method delete {
	kill($.tid)
}
method setstep(s,tm) {
	$.step = s
	if ( nargs() > 1 )
		$.steptm = tm
}
method setmute(m) {
	$.mute = m
}
method pause(v) {
	$.pausing = v
}
method ornament(p) {
	$.pornament = p
}
method totshift(n) {
print("method shift n=",n)
	$.shifty = n
}
method resync(tm) {
	$.resynctm = tm
}
method playtask() {
	cnt = 0
	while ( $.stopme == 0 && ($.nloops <= 0 || cnt < $.nloops) ) {
		lasttm = ($.p)%1.time	# probably 0
		thislng = $.lng
		for ( n in $.p ) {

			if ( $.resynctm > 0 )
				break

			# the reason for this loop is to implement pausing
			forcestep = 0
			while (1) {
				if ( $.step || forcestep) {
					dt = $.steptm
				} else {
					dt = n.time - lasttm
				}
				$.tm += dt
				lasttm = n.time

				sleeptill($.tm-2)
				if ( ! $.pausing ) {
					break
				}
				# We're pausing, add another step and wait
				forcestep = 1
			}

			if ( $.resynctm > 0 )
				break

			n.time = 0
			if ( $.mute == 0 ) {
				if ( $.pornament != '' )
					n = ornament(n,$.pornament)
				if ( $.shifty != 0 )
					n.pitch += $.shifty
				realtime(n,$.tm)
			}
		}

		$.getnext();

		if ( $.resynctm > 0 ) {
			$.tm = $.resynctm
			$.resynctm = -1
		} else {
			if ( $.step ) {
				dt = 0
			} else {
				dt = $.lng - lasttm
			}

			$.tm += dt
		}
		if ( $.fadeamount != 0 ) {
			tmp = $.p
			tmp.vol -= $.fadeamount
			if ( tmp.vol == 0 )
				break
			$.p = tmp
		}
		sleeptill($.tm-2)
		cnt++
	}
}
}
##################################################

class plexplayer {
method init(ch,tm,notifyobj,nsteps,steptm,rhythmsets,
		riffsets,patchsets,drumriffsets,drumsets,initpatchtype) {

	if ( nargs() < 11 )
		initpatchtype = 0
	$.initpatchtype = initpatchtype

	$.ch = ch
	$.notifyobj = notifyobj
	$.initnsteps = nsteps
	$.nsteps = nsteps
	$.steptm = steptm
	$.maxnsteps = nsteps
	$.rhythmsets = rhythmsets
	$.riffsets = riffsets
	$.patchsets = patchsets
	$.patchtype = $.initpatchtype
	$.patchset = $.patchsets[$.patchtype]
	$.origdrumriffsets = drumriffsets
	$.drumsets = drumsets
	$.volinit = 110
	$.drumvolinit = 100
	$.volinc = 5
	$.voladjust = 0
	$.volmin = 30
	$.shiftmode = 0	# 1 is pitch shifting
	$.drumnotes = ''

	$.shifts = [
			0=-7,
			1=-5,
			2=-3,
			3=0,
			4=3,
			5=5,
			6=7,
			7=9
		]

	$.notes2play = [
			0=1,	# start out playing 1 note
			1=3,	# play 3 notes
			2=5,	# ...
			3=7,	#
			4=10,	#
			5=0	# play all notes
			]
	$.fullreset()

	$.tid = task $.playtask(tm)
}
method stop{
	$.stopme = 1
}
method louder {
	$.voladjust += 10
}
method softer {
	$.voladjust -= 10
}
method realclear {

	# This clears the current looping stuff

	$.currshift = 0
	$.pendingindex = -1
	$.lastadded = []
	$.nlastadded = 0
	$.pendingslower = 0
	$.pendingfaster = 0
	$.pendingshorterloop = 0
	$.pendinglongerloop = 0
	$.pendingreset = 0
	$.pendingclear = 0
	$.step = []
	$.stepvol = []
	$.nsteps = $.initnsteps
	for ( i=0; i<$.nsteps; i++ ) {
		$.step[i] = ''
		$.stepvol[i] = $.volinit
	}
}
method realreset {

	# This resets almost everything,
	# but leaves the riffsetindex alone

	$.realclear()
	$.notes2playindex = 0
	$.durtimes = 1
	$.octave = 0
	$.dorhythm = 1
	$.stopme = 0
	$.mute = 0
	$.recording = 1
	$.fading = 1
	$.patchindex = 0
	$.drumsetindex = 0
	$.playingdrums = 0
	$.arpeggiomode = 0
	$.voladjust = 0

	# Make sure the first patch change gets sent
	$.patchchange(0)
}
method fullreset {
	$.realreset()
	$.riffsetindex = 0
	$.drumriffsetindex = 0
	$.rhythmsetindex = 0
}
method togglerhythmmode {
	$.dorhythm = 1 - $.dorhythm
}
method togglearpeggiomode {
	$.arpeggiomode = 1 - $.arpeggiomode
}
method toggledrummode {
	$.realclear()
	$.playingdrums = 1 - $.playingdrums
	$.patchchange(0)
}
method togglepitchshift {
	$.shiftmode = 1 - $.shiftmode
}
method setrecording(v) {
	$.recording = v
}
method togglerecording {
	$.recording = 1 - $.recording
}
method togglefading {
	$.fading = 1 - $.fading
# print("fading=",$.fading)
}
method delete {
	kill($.tid)
}
method playindex(i) {
	if ( $.shiftmode == 0 ) {
		# Normal play mode
		$.pendingindex = i
	} else if ( $.shiftmode == 1 ) {
		# Pitch shift mode
		obj = $.notifyobj
		obj.shiftall($.shifts[i])
	}
}
method shiftit(v) {
	if ( v == 0 )
		$.currshift = 0
	else
		$.currshift += v
}

method morenotes(n) {
	$.notes2playindex++
	if ( ! $.notes2playindex in $.notes2play )
		$.notes2playindex = sizeof($.notes2play)-1
}
method fewernotes() {
	$.notes2playindex--
	if ( $.notes2playindex < 0 )
		$.notes2playindex = 0
}

method notesetchange() {
	if ( $.playingdrums == 0 ) {
		$.riffsetindex++
		if ( ! ( $.riffsetindex in $.riffsets ) ) {
			$.riffsetindex = 0
		}
		print("riffsetindex =",$.riffsetindex)
	} else {
		$.drumriffsetindex++
		if ( ! ( $.drumriffsetindex in $.drumriffsets ) ) {
			$.drumriffsetindex = 0
		}
		print("drumriffsetindex =",$.drumriffsetindex)
	}
}
method rhythmsetchange() {
	$.rhythmsetindex++
	if ( ! ( $.rhythmsetindex in $.rhythmsets ) ) {
		$.rhythmsetindex = 0
	}
}
method patchreset() {
	$.patchindex = 0
	$.drumsetindex = 0
	$.patchchange(0)
}
method applymapto(maparr,q) {
	r = ''
	for ( tn in q ) {
		if ( ! ( tn.pitch in maparr ) ) {
			print("Hey, pitch=",tn.pitch," isn't in maparr?")
		} else {
			tn.pitch = maparr[tn.pitch]
		}
		r |= tn
	}
	return(r)
}
method patchchangetype() {
	$.patchtype++
	if ( ! ( $.patchtype in $.patchsets ) ) {
		$.patchtype = 0
	}
	$.patchset = $.patchsets[$.patchtype]
	$.patchindex = 0
	$.patchchange(0)
}
method patchfix(v) {
	if ( $.playingdrums == 0 ) {
		$.patchindex = v
	} else {
		$.drumpatchindex = v
	}
	$.patchchange(0)
}
method patchchange(inc) {
	if ( nargs() < 1 )
		inc = 1
	if ( $.playingdrums == 0 ) {
		$.patchindex += inc
		if ( typeof($.patchset) != "array" ) {
			print("In plexplayer.patchchange, patchset is not array? ch=",$.ch);
			return()
		}
		if ( ! ( $.patchindex in $.patchset ) ) {
			$.patchindex = 0;
		}
		p = patchnamed($.patchset[$.patchindex],$.ch)
		print("Channel ",$.ch," Patch=",$.patchset[$.patchindex])
	} else {
		$.drumsetindex += inc
		if ( ! ( $.drumsetindex in $.drumsets["name"] ) ) {
			$.drumsetindex = 0;
		}
		print("Channel ",$.ch," drumset=",$.drumsets["name"][$.drumsetindex])
		p = patchnamed($.drumsets["name"][$.drumsetindex],$.ch)
		$.remapdrums()
	}
	if ( p != "" )
		realtime(p)
}

method remapdrums() {
	$.drumnotes = $.drumsets["notes"][$.drumsetindex]
print("    $.drumnotes=",$.drumnotes)
	dnotesz = sizeof($.drumnotes)

	# We're going to be changing the drumriffsets to match
	# the current drum patch, so create a separate
	# copy of the array
	$.drumriffsets = arraycopy($.origdrumriffsets)

	# Find the lowest and highest notes in the drumriffsets.
	# First just get a single phrase with all the drumriffsets.
	all = ''
	for ( n in $.drumriffsets ) {
		oneset = $.drumriffsets[n]
		for ( i in oneset ) {
			if ( typeof(oneset[i]) == "phrase" ) {
				all += oneset[i]
			}
		}
	}
	for ( i in $.step ) {
		if ( typeof($.step[i]) == "phrase" ) {
			all += $.step[i]
		}
	}
	pitchlow = lowest(all)
	pitchhigh = highest(all)
	# create a map which spreads the drum notes from the
	# lowest to the highest notes in the all phrase
	maparr = []
	for ( n=pitchlow; n<=pitchhigh; n++ ) {
		dnum = 1 + dnotesz * (n-pitchlow)/(pitchhigh-pitchlow+1) 
		maparr[n] = ($.drumnotes%dnum).pitch
# print("n=",n," dnum=",dnum," maparr[",n,"] = ",maparr[n])
		}
# print("maparr = ",maparr)
# print("$.drumnotes was ",$.drumnotes)

	# map all the notes in the drumnoteset
# print("patchchange inc=",inc," before map drumriffsets = ",$.drumriffsets)
	for ( n in $.drumriffsets ) {
		oneset = $.drumriffsets[n]
		for ( i in oneset ) {
# print("q=",q)
			$.drumriffsets[n][i]
				= $.applymapto(maparr,oneset[i])
# print("Mapped drumriffset n=",n," i=",i," = ",r)
		}
	}
	# map all the notes in the current playing riffs, too
	for ( i in $.step ) {
# print("Remapping step i from ",$.step[i])
		$.step[i] = $.applymapto(maparr,$.step[i])
# print("  TO ",$.step[i])
	}
}
method reset {
	$.pendingreset = 1
}
method clear {
	$.pendingclear = 1
}
method octaveup {
	$.octave++
}
method octavedown {
	$.octave--
}
method longerloop {
	$.pendinglongerloop = 1
}
method shorterloop {
	$.pendingshorterloop = 1
}
method faster {
	$.pendingfaster = 1
}
method slower {
	$.pendingslower = 1
}
method durlonger {
	$.durtimes *= 2.0
}
method durshorter {
	$.durtimes /= 2.0
}
method backspace {
	if ( $.nlastadded > 0 ) {
		i = $.lastadded[$.nlastadded-1]
		$.step[i] = ''
		$.nlastadded--
	}
}
method getstep(i) {
	s = $.step[i]
	if ( s == '' ) {
		return(s)
	}
	if ( typeof(s) != "phrase" ) {
		print("Hey, s is not a phrase for step i=",i);
		$.step[i] = ''
		return('')
	}

	if ( ! ( i in $.stepvol ) ) {
		print("Hey, i=",i," not in $.stepvol? ")
		$.stepvol[i] = $.volinit
		return(s);
	}

	if ( $.fading ) {
		$.stepvol[i] -= $.volinc
# printf("fading, getstep.vol=",$.stepvol[i])
	}

	s.vol = $.stepvol[i]
	if ( s.vol < $.volmin ) {
		$.step[i] = ''
		s = ''
	}
	return(s)
}

method applystuff(p) {
	if ( $.octave != 0 )
		p.pitch += ($.octave * 12)
	if ( $.durtimes != 1 )
		p = scatimes(p,$.durtimes)
	if ( $.voladjust != 0 )
		p.vol += $.voladjust
	return(p)
}

method getvolinit {
	if ( $.playingdrums == 1 ) {
		return($.drumvolinit)
	} else {
		return($.volinit)
	}
}

method playtask(tm) {
	stepi = 0

	while ( $.stopme == 0 ) {

		todo = ''
		sleeptill(tm-2)

		if ( $.pendingclear > 0 ) {
			$.pendingclear = 0
			$.realclear()
			stepi = 0
		}
		if ( $.pendingreset > 0 ) {
			$.pendingreset = 0
			$.realreset()
			stepi = 0
		}
		if ( $.pendingindex >= 0 ) {

# print("PENDING INDEX = ",$.pendingindex)
			if ( $.playingdrums == 0 ) {
				# Here's where we grab something to play/record
				todo= $.riffsets[$.riffsetindex][$.pendingindex]
			} else {
				todo= $.drumriffsets[$.drumriffsetindex][$.pendingindex]
# print("drum todo = ",todo)
			}

			n2play = $.notes2play[$.notes2playindex]
			if ( n2play > 0 ) {
				todo = head(todo,n2play)
			}

			# Apply the rhythmset value
			if ( $.arpeggiomode ) {
				todo = arpeggio(todo)
			}
			if ( $.dorhythm ) {
				rh = $.rhythmsets[$.rhythmsetindex][$.pendingindex]
				if ( rh != '' ) {
					todo = applyrhythm(todo,rh,1)
				}
			}
			todo.vol = $.getvolinit()
			todo.chan = $.ch
			$.pendingindex = -1
		} else {
			todo = ''
		}

		if ( $.recording ) {
			# If we're recording...
			if ( todo != '' ) {
				# New note to add to recording
				currstep = todo
				$.step[stepi] = todo
				$.stepvol[stepi] = $.getvolinit()
				if ( $.nlastadded < 10 ) {
					$.lastadded[$.nlastadded] = stepi
					$.nlastadded++
				}
			} else {
				# Adjust volume of existing step
				currstep = $.getstep(stepi)
			}
		} else {
			# If we're just playing...
			if ( todo != '' ) {
				if ( $.currshift != 0 )
					todo.pitch += $.currshift
				if ( $.playingdrums==0 )
					todo = $.applystuff(todo)
				realtime(todo,tm)
			}
			currstep = $.getstep(stepi)
		}

		if ( currstep != '' ) {
			if ( $.currshift != 0 )
				currstep.pitch += $.currshift
			if ( $.playingdrums==0 )
				currstep = $.applystuff(currstep)
			realtime(currstep,tm)
		}


		tm += $.steptm
		if ( ++stepi < $.nsteps )
			continue

		# We're at the end of a cycle
		stepi = 0
		if ( $.pendingslower ) {
			$.pendingslower = 0

			# Double the number of steps we're playing
			# and make the notes longer
			for ( i=$.nsteps-1; i>=0; i-- ) {
				twoi = 2*i
				twoi1 = 2*i+1
				$.step[twoi] = scatimes($.step[i],2)
				$.step[twoi1] = ''
				if ( i != 0 ) {
					$.step[i] = ''
				}
				$.stepvol[twoi] = $.stepvol[i]
				$.stepvol[twoi1] = 0
				if ( i != 0 ) {
					$.stepvol[i] = 0
				}
			}
			$.nsteps *= 2
			if ( $.nsteps > $.maxnsteps )
				$.maxnsteps = $.nsteps
		}
		if ( $.pendingfaster ) {
			$.pendingfaster = 0
print("PENDINGFASTER DISABLED!")
			# for ( k in $.step ) {
			# 	$.step[k] = scatimes($.step[k],0.5)
			# }
			# if ( $.steptm >= 1b/16) {
			# 	$.steptm *= 0.5
			# }
		}
		if ( $.pendinglongerloop ) {
			$.pendinglongerloop = 0
			# If we've never been this long before, 
			# duplicate steps to double length
			if ( $.maxnsteps <= $.nsteps ) {
				for ( t=0; t<$.nsteps; t++ ) {
					$.step[$.nsteps+t] = $.step[t]
					$.stepvol[$.nsteps+t] = $.stepvol[t]
				}
				$.maxnsteps = 2 * $.nsteps
			}
			$.nsteps *= 2
		}
		if ( $.pendingshorterloop) {
			$.pendingshorterloop = 0
			# half steps to half length
			$.nsteps /= 2
		}
	}
}
}
##################################################

class looprequestplayer {
method init(obj,tm,lng) {
	$.tm = tm
	$.stopme = 0
	$.p = p
	$.lng = lng
	$.step = 0
	$.steptm = 1b/4
	$.mute = 0
	$.pausing = 0
	$.shifty = 0
	$.pornament = ''
	$.resynctm = 0

	$.tid = task $.playtask()
}
method delete {
	kill($.tid)
}
method setstep(s,tm) {
	$.step = s
	if ( nargs() > 1 )
		$.steptm = tm
}
method setmute(m) {
	$.mute = m
}
method pause(v) {
	$.pausing = v
}
method ornament(p) {
	$.pornament = p
}
method totshift(n) {
	$.shifty = n
}
method resync(tm) {
	$.resynctm = tm
}
method playtask() {
	cnt = 0
	while (cnt < 20) {
		lasttm = ($.p)%1.time	# probably 0
		thislng = $.lng
		for ( n in $.p ) {

			if ( $.resynctm > 0 )
				break

			# the reason for this loop is to implement pausing
			forcestep = 0
			while (1) {
				if ( $.step || forcestep) {
					dt = $.steptm
				} else {
					dt = n.time - lasttm
				}
				$.tm += dt
				lasttm = n.time

				sleeptill($.tm-2)
				if ( ! $.pausing ) {
					break
				}
				# We're pausing, add another step and wait
				forcestep = 1
			}

			if ( $.resynctm > 0 )
				break

			n.time = 0
			if ( $.mute == 0 ) {
				if ( $.pornament != '' )
					n = ornament(n,$.pornament)
				if ( $.shifty != 0 )
					n.pitch += $.shifty
print("realtime n=",n)
				realtime(n,$.tm)
			}
		}

		if ( $.resynctm > 0 ) {
			$.tm = $.resynctm
			$.resynctm = -1
		} else {
			if ( $.step ) {
				dt = 0
			} else {
				dt = $.lng - lasttm
			}

			$.tm += dt
		}
		sleeptill($.tm-2)
		cnt++
	}
}
}

function applyrhythm(p,rh,mode) {
	if ( nargs() < 3 )
		mode = 1
	if ( mode == 0 ) {
		r = apply(p,rh, TIME | DURATION )
	} else {
		arr = splitonstarts(p,0,1)
# print("arr=",arr)
		rhi = 1
		rhsize = sizeof(rh)
		arrsize = sizeof(arr)
		r = ''
		t = 0
		for ( n=0; n<arrsize; n++ ) {
			if ( rhi > rhsize ) {
				t += rh.length
# print("Advancing t to t=",t)
				rhi = 1
			}
			p = arr[n]
			rhn = rh%rhi
# print("rhn=",rhn, " rhi=",rhi,"  rh=",rh)
			p.time = t + rhn.time
			p.dur = rhn.dur
# print("p (applied time and dur) = ",p)
			r |= p
			rhi++
		}
	}
	return(r)
}
