class lyre_player_playfile {
method init (burn) {
	$.inherit(new lyre_player(burn))
	$.tid = -1
	$.running = 0
	$.kadjust = 0
	$.skipblank = 0
	$.ls = Now
	$.scratching = 0
	$.times = []
	for ( n=0; n<5; n++ )
		$.times[n] = 0
	$.timei = 0
	$.times[0] = 0
	$.cnt = 0
		$.k = 0
	$.arr = []
}
method delete {
	kill($.tid)
}
method isrunning {
	return($.running && $.cnt != 0)
}
method activate {
	if ( sizeof($.arr) == 0 ) {
		$.initmusic()
	}
}
method musicchange {
	$.initmusic()
}
method initmusic {
	p = $.burn.getmusic()
	$.qnt = $.burn.getquant()
	$.burn.pitchrange(lowest(p),highest(p))
	$.arr = []
	$.inc = 1b/2
	$.adjustmult = 2
	$.na = 0
	last = latest(p)
	for ( t=0; t<last; t+=$.inc ) {
		tp = cut(p,CUT_TIME,t,t+$.inc)
		tp.time -= t
		tp.length = $.inc
		$.arr[$.na++] = tp
	}
	$.k = 0
}
method start {
	if ( $.isrunning() ) {
		print("playfile.start ignored, already running")
		return()
	}
	$.running = 1
	if ( $.cnt == 0 )
		$.cnt = -1	# infinite
	tm = nextquant(Now,$.qnt)
	$.tid = task $.run(tm)
}
method stop {
	$.cnt = 0
}
method adjustk(dk) {
	$.k += dk
	if ( $.k < 0 )
		$.k = 0
	if ( $.k >= $.na )
		$.k = 0
}
method run(t0) {
	tm = t0
	$.burn.notifystart(tm)
	if ( $.k >= $.na )
		$.k = 0
	for ( ; $.k<$.na; $.k++ ) {
		if ( $.cnt == 0 ) {
			break
		}
		if ( $.kadjust != 0 ) {
			$.adjustk($.kadjust)
			$.kadjust = 0
		}
		if ( $.skipblank ) {
			while ( $.arr[$.k] == '' && $.k > 0 && $.k < $.na ) {
				$.adjustk(1)
			}
			$.skipblank = 0
		}
		tp = $.arr[$.k]
		sleeptill(tm-1b/2)
		if ( $.cnt == 0 ) {
			break
		}
		$.burn.play(tp,tm)
		tm += $.inc
		if ( $.cnt > 0 )
			$.cnt--
	}
	$.running = 0
	if ( $.k >= $.na )
		$.burn.notifyend()
	else
		$.burn.notifystop()
}
method adjust(n) {
	$.kadjust = n * $.adjustmult
}
method playn(n) {
	$.cnt = n * $.adjustmult
	$.skipblank = 1
	$.start()
}
method pad_start(padnum) {

	# Two quick hits of the start button will restart
	# the file from the beginning
	if ( $.ls > 0 && millisince($.ls) < 1000 ) {

		$.stop()
		sleeptill(Now+1b)

		$.burn.restartmusicfile()

		$.k = 0
		$.start()
		$.ls = 0

		return()
	}

	$.ls = Now
	# otherwise, toggle it
	if ( $.isrunning() ) {
		$.stop()
	} else {
		$.cnt = -1	# infinite
		$.start()
	}
}
method pad_select(padnum) {
}
method pad_select2(padnum) {
	$.nextmusic(0)
}
method nextmusic(silent) {
	if ( nargs() < 1 )
		silent = 1
	$.stop()
	if ( ! silent )
		$.burn.feedback()
	sleeptill(Now+1b)	# just a little
	$.burn.nextmusicfile()
	$.start()
}
method pad_command(padnum,cmd,arg,cmode) {
	print("PAD_COMMAND_DO cmd=",cmd," arg=",arg," cmode=",cmode)
	if ( cmd == "TRIANGLE" ) {
		if ( arg in $.transitions ) {
			tr = $.transitions[arg]
			$.set_transitions(tr)
		}
	} else if ( cmd == "X" && arg == "X" ) {
		$.burn.switch()
	} else if ( cmd == "DOWN" && arg == "DOWN" ) {
		exit(0)
	}
}
method padfunc(padnum,nm,updown) {

	# Keep track of "time of last pad press" for
	# the last N presses. 
	if ( updown == 0 ) {
		dt = Now - $.times[$.timei]
		$.timei++
		if ( $.timei >= sizeof($.times) )
			$.timei = 0
		$.times[$.timei] = Now
		dsum = 0
		for ( i in $.times ) {
			dsum += (Now-$.times[i])
		}
		print("dsum = ",dsum)
		if ( dsum < milliclicks(6000) ) {
			$.burn.switch()
			return()
		}
	}

	if ( ! $.scratching )
		return()

	if ( nm == "X" && updown == 1 ) {
		if ( $.isrunning() ) {
			$.adjust(-1)
		} else {
			$.adjust(-2)
			$.playn(1)
		}
	} else if ( nm == "UP" && updown == 1 ) {
		if ( $.isrunning() ) {
			$.adjust(1)
		} else {
			$.playn(1)
		}
	} else if ( nm == "DOWN" && updown == 1 ) {
		if ( $.isrunning() ) {
			$.adjust(2)
		} else {
			$.playn(2)
		}
	} else if ( nm == "CIRCLE" && updown == 1 ) {
		if ( $.isrunning() ) {
			$.adjust(4)
		} else {
			$.playn(4)
		}
	} else if ( nm == "LEFT" && updown == 1 ) {
		if ( $.isrunning() ) {
			$.adjust(-2)
		} else {
			$.adjust(-4)
			$.playn(2)
		}
	} else if ( nm == "RIGHT" && updown == 1 ) {
		if ( $.isrunning() ) {
			$.adjust(8)
		} else {
			$.playn(8)
		}
	} else if ( nm == "TRIANGLE" && updown == 1 ) {
		if ( $.isrunning() ) {
			$.adjust(-4)
		} else {
			$.adjust(-8)
			$.playn(4)
		}
	} else if ( nm == "SQUARE" && updown == 1 ) {
		if ( $.isrunning() ) {
			$.adjust(16)
		} else {
			$.playn(16)
		}
	}
}
}
