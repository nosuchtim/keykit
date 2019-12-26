# function plexdemo() {
# 	Plexquant = 1b
# 	t = bs202drumn(16b,16)
# 	dt = realtime(t,nextquant(Now,Plexquant))
# 	echoplex()
# 	kill(dt)
# }

function echoplex_reset() {
	Plextrans = 0
	Plexlength = -1
	Plexrec=''
	PlexPrimed = 0
}

function echoplex_drums() {
	return('')
}

function echoplex(gm) {

	# if ( nargs() == 0 || gm == 0 ) {
	# 	PlexDrumFunc = global(bs202drumn)
	# } else {
	# 	PlexDrumFunc = global(bsgmdrumn)
	# }
	PlexDrumFunc = global(echoplex_drums)
	# realtime(sc7turnoff(1,2,3,4,5,6,7,8,9,11,12,13,14,15,16))

	echoplex_reset()

	Plexslot = 0
	PlexMapped = 0
	PlexSpace = 4b

	# There are 10 slots - each one has a phrase
	# assigned to it.
	Plex = []
	PlexMute = []
	for ( n=0; n<10; n++ ) {
		Plex[n] = ''
		PlexMute[n] = 0
	}

	if ( ! defined(Plexquant) )
		Plexquant = 1

	drumchan = 10

	scale = chordnamed("MajB769")
	scale.pitch += canonic('c')

	print("GO!")

	# We only want to merge the drum channel -
	# all other channels will be "mapped"
	oldMergefilter = mergeonly(drumchan)
	t1 = task task_echoplex(scale,drumchan)

	Consecho = 0
	echoplex_console()
	Consecho = 1

	kill(t1)
	Mergefilter = oldMergefilter

	# togglemet()
	realtime(ano())

	print("Done.")
}

function echoplex_console(scale,drumchan) {

	loop1 = -1
	tids = []
	onexit(global(killtids),tids)

	PlexDrums = PlexDrumFunc(4b,1)
	dptid =  task task_echoplex_drumloop(Now)
	tids[dptid] = 1

	while ( (c=Root.waitforconsolekey()) != "" ) {
		tm = Now
		if ( c >= "0" && c <= "9" ) {
			Plexslot = ascii(c) - ascii("0")
			# We want 0 to be 10
			if ( Plexslot == 0 )
				Plexslot = 10
			else
				Plexslot--
			print("Switched to slot ",Plexslot)
			continue
		}
		if ( c == "g" ) {
			PlexMute[Plexslot] = 0
			# Add note-off's for any currently-held notes
			for ( nt in Current ) {
				nt.type = NOTEOFF
				nt.time = tm
				Plexrec |= nt
			}
			if ( Plexlength < 0 ) {

				# If there's nothing recorded yet, we
				# use the first one as the way of determining
				# the overall length.

				ep = lastbunch(Plexrec,PlexSpace)
				t1 = ep%1.time
				ep = strip(ep)

				if ( PlexMapped ) {
					# The pitch of "mapped" things is
					# already transposed, so we have
					# to undo it before saving it.
					ep.pitch -= Plextrans
				}

				ep.length = tm - t1
				ep.length = numquant(ep.length,Plexquant)
				PlexNextTime = tm
				Plexlength = ep.length
				Plex[Plexslot] = ep
				loop1 = task task_echoplex_loop(Plexlength)
				tids[loop1] = 1
			} else {
				eptime = PlexNextTime
				dt = tm-eptime
				if ( dt < -(Plexlength)/2 ) {
					# We got the trigger closer to
					# the start time of the
					# previous Eplex iteration,
					# so we want to deal with the
					# previous iteration.
					eptime -= Plexlength
					usingprev = 1
				} else {
					usingprev = 0
				}

				# eptime is now the ending time of
				# the time period that we're going
				# to grab and add to Eplex1

				tm1 = eptime-Plexlength
				addthis = cut(Plexrec,CUT_TIME,tm1,eptime)
				addthis.time -= tm1
				addthis.length = Plexlength
				if ( usingprev ) {
					# if we grab the previous
					# iteration, then the current
					# one is already going, and
					# even though we add addthis,
					# it's not going to play until
					# the next loop.  So we play
					# it ourselves.
					realtime(addthis,eptime)
				}
				Plex[Plexslot] = addthis
			}
		} else if ( c == "d" ) {
			if ( Plexlength > 0 ) {
				kill(dptid)
				delete tids[dptid]
				Plex[9] = PlexDrumFunc(Plexlength,1)
			}
		} else if ( c == "a" ) {
			realtime(ano())
		} else if ( c == "M" ) {
			PlexMapped = 1 - PlexMapped
		} else if ( c == "m" ) {
			PlexMute[Plexslot] = 1 - PlexMute[Plexslot]
		} else if ( c == "u" ) {
			Plex[Plexslot] = ''
		} else if ( c == "q" ) {
			Plex[Plexslot] = quantize(Plex[Plexslot],1b/4)
		} else if ( c == "c" ) {
			for ( n=0; n<10; n++ )
				Plex[n] = ''
			killtids(tids)
			tids = []
			realtime(ano())
			loop1 = -1

			PlexDrums = PlexDrumFunc(4b,1)
			dptid =  task task_echoplex_drumloop(Now)
			tids[dptid] = 1

			Plexlength = -1
			Plextrans = 0

		} else if ( c == "t" ) {
			PlexPrimed = 1
		}
	}
	killtids(tids)
	realtime(ano())
}

function task_echoplex(scale,drumchan) {

	Midiin[$] = f = open()
	onexit(global(closemidi),$)

	while ( (m=get(f)) != Eof ) {

		if ( m.chan == drumchan )
			continue

		m.chan = Plexslot + 1

		if ( m.type != NOTEON && m.type != NOTEOFF && m.type != NOTE ) {
			# It's not a pitchable thing,so we don't map it.
			if ( m.type == CONTROLLER || m.type == PITCHBEND )
				Plexrec |= m
			realtime(m,0)
			continue
		}

		if ( PlexPrimed == 1 ) {
			if ( m.type == NOTEOFF ) {
				PlexPrimed1 = m.pitch
				PlexPrimed = 2
			}
			continue
		} else if ( PlexPrimed == 2 ) {
			if ( m.type == NOTEOFF ) {
				PlexPrimed2 = m.pitch
				PlexPrimed = 0
				Plextrans = PlexPrimed2 - PlexPrimed1
			}
			continue
		}

		if ( PlexMapped ) {
			found = closest(m,scale)
			if ( found != '' ) {
				m.pitch = found.pitch
				m.pitch += Plextrans
				Plexrec |= m
				realtime(m,0)
			}
		} else {
			# not mapped, just add it
			m.pitch += Plextrans
			Plexrec |= m
			realtime(m,0)
		}
	}
}
function task_echoplex_loop(tm) {
	while ( 1 ) {
		p = ''
		for ( n=0; n<9; n++ ) {
			if ( PlexMute[n] == 0 ) {
				p |= Plex[n]
			}
		}
		p.pitch += Plextrans
		# We don't want to transpose the drums 10
		if ( PlexMute[9] == 0 ) {
			p |= Plex[9]
		}

		t1 = realtime(p,PlexNextTime)
		# print("Loop t=",PlexNextTime," next=",(PlexNextTime+tm))
		onexit(global(killtids),t1)
		PlexNextTime += tm
		sleeptill(PlexNextTime-4)
	}
}
function task_echoplex_drumloop(tm) {
	while ( 1 ) {
		t1 = realtime(PlexDrums,tm)
		tm += PlexDrums.length
		onexit(global(killtids),t1)
		sleeptill(tm-4)
	}
}
