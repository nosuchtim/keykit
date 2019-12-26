class whoops {
method init() {

	$.w = new window()
	$.inherit($.w)

	$.currchan = 1

	$.b1 = new kmenubutton("More","mkmenu_hoops1",$)
	$.addchild($.b1)
	$.b2 = new kbutton("Reset",$,"reset")
	$.addchild($.b2)
	$.b3 = new ktext("CH = "+string($.currchan))
	$.addchild($.b3)

	$.initstuff()

	$.oldshowbar = Showbar
	$.oldmerge = Merge
	Merge = 0

	$.existing = 0
	$.firstresize = 1
	if ( defined(Hoops) && Hoops != $0 && Hoops != $-1 ) {
		h = Hoops
		print("Using existing hoops object")
		$.existing = 1
	} else {
		h = new hoops1c_object()
		h.start(0)
		h.starttasks()
	}
	$.h = h

	h.setnotify($)

	j = getjoymonitor()
	j.notify($.h,-1)
	$.j = j

}

method initstuff () {
	$.ph = []
	$.butt_mute = []
	$.butt_chan = []
	$.phxy = []
	$.nph = 0
	$.maxbeats = 0
}

method updatechanbuttons() {
	for ( n=0; n<$.nph; n++ ) {
		ch = $.h.getchann(n+1)
		if ( ch == $.currchan ) {
			$.butt_chan[n].set(1)
		} else {
			$.butt_chan[n].set(0)
		}
		$.butt_chan[n].redraw()
	}
}
method notify_event(s,v1,v2) {
	if ( s == "firstloop" || s == "loopchange" ) {
		$.refresh()
		return()
	}
	if ( s == "chanchange" ) {
		$.b3.set("CH = "+string(v1))
		$.b3.redraw()
		$.currchan = v1
		$.updatechanbuttons()
	}
	if ( s == "newpulsetime" ) {
		$.refresh()
		return()
	}
	if ( s == "reset" ) {
		$.do_reset()
		return()
	}

	if ( $.nph < 1 ) {
		return()
	}
	if ( s == "mutechan" ) {
		for ( n=0; n<$.nph; n++ ) {
			ch = $.h.getchann(n+1)
			if ( ch == v1 ) {
				$.butt_mute[n].set(v2)
				$.butt_mute[n].redraw()
			}
		}
		return()
	}
	if ( s == "pulse" ) {
		$.resize()
		$.redraw()
		return()
	}
	if ( s == "quant" ) {
		$.refresh()
	}
}

method reset {
	$.h.reset()
}

method do_reset {
	$.getloops()
	$.initstuff()
	$.redraw()
}

method delete {
	$.j.unnotify($.h,-1)
	$.h.delete()
	$.h.waittilldone()
	Merge = $.oldmerge
	Showbar = $.oldshowbar
	print("Hoops done.")
}

method redraw {
	$.w.redraw()
	methodbroadcast()
	# $.w.rectangle(xy($.px0,$.py0,$.px1,$.py1))
	# if ( $.nph > 0 ) {
	# 	for ( n=0; n<$.nph; n++ ) {
	# 		$.ph[n].redraw()
	# 	}
	# }
	hack = 0
	$.w.line(xy($.midx-1-hack,$.py0,$.midx-1-hack,$.py1))
	$.w.line(xy($.midx-hack,$.py0,$.midx-hack,$.py1))
	$.w.line(xy($.midx+1-hack,$.py0,$.midx+1-hack,$.py1))
	lock($)
	for ( n=0; n<$.nph; n++ ) {
		if ( ! (n in $.phxy) ) {
			continue
		}
		arr = $.phxy[n]
		if ( typeof(arr) != "array" ) {
			print("Hey, phxy[n=",n,"] isn't an array")
			continue
		}
		ch = $.h.getchann(n+1)
		if ( ch == $.currchan ) {
			arr["x0"]--
			arr["y0"]--
			arr["x1"]++
			arr["y1"]++
			$.w.rectangle(arr)
		}
	}
	unlock($)
}


method mousedown (m) {
		mouseforward(m,"mousedown")
}
method dump {
	return ( [
		] )
}
method restore (state) {
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	dx = ($.xmax()-$.xmin()) / 3
	y0 = $.ymin()+2
	y0a = $.ymin() + $.textheight() + 4
	x0 = $.xmin() + 2
	x1 = $.xmax() - 2
	y1 = $.ymax() - 2
	# $.t2.resize(xy(x0+2*dx+1,y0,x1,y0a))

	$.nph = $.h.getnloops()
	$.px0 = x0 + $.textwidth()
	$.px1 = x1 - 10 * $.textwidth()
	$.px1b = x1 - $.textwidth()
	$.py0 = y0a + 4
	$.py1 = y1 - $.textheight()
	$.midx = ($.px0+$.px1)/2

	$.b1.resize(xy(x0,y0,x0+dx-1,y0a))
	$.b2.resize(xy(x0+dx+1,y0,x0+2*dx-1,y0a))
	$.b3.resize(xy(x0+2*dx+1,y0,x0+3*dx-1,y0a))

	if ( $.existing && $.firstresize ) {
		$.do_reset()
		$.firstresize = 0
	}

	$.reposition()

	lock($)
	for ( n=0; n<$.nph; n++ ) {
		arr = $.phxy[n]
		if ( typeof(arr) != "array" ) {
			print("Hey, phxy[n=",n,"] isn't an array")
			continue
		}
		dx = ($.px1b-$.px1)/5
		tx = $.px1 + 2
		$.butt_mute[n].resize(xy(tx,arr["y0"],tx+dx-2,arr["y1"]))
		tx += dx
		$.butt_chan[n].resize(xy(tx,arr["y0"],tx+2*dx-2,arr["y1"]))
		tx += 2*dx
	}
	unlock($)
}

method reposition() {
	# print("reposition nph=",$.nph," maxbeats=",$.maxbeats)
	if ( $.nph < 1 || $.maxbeats < 1 )
		return()
	lock($)
	dxbeat = ($.px1-$.px0)/($.maxbeats*2)
# print("midx=",$.midx," DXBEAT=",dxbeat,"  $.px01=",$.px0,$.px1)
	dy = ($.py1-$.py0)/$.nph
	py1 = $.py0 - 2
	for ( n=1; n<=$.nph; n++ ) {
		p = $.h.getloopn(n)
		nb = $.h.getbeatsn(n)
		currb = $.h.getcurrbeat(n)
		if ( currb < 0 )
			continue
		loopn = n-1
		if ( ! (loopn in $.ph) ) {
			print("REPOSITION is skipping loopn=",loopn)
			continue
		}
		hack = 0
		px0 = $.px0 + hack + $.maxbeats * dxbeat - currb * dxbeat
		px0 = $.midx - currb * dxbeat
# print("currb=",currb,"  nb=",nb," px0=",px0)
		px1a = px0 + nb * dxbeat
		# print("$.px1 = ",$.px1,"  px1a=",px1a)
		py0 = py1 + 2
		py1 = $.py1-($.nph-(n))*dy - 2
		$.phxy[loopn] = xy(px0,py0,px1a,py1)
		# print("p=",p," xy=",$.phxy[loopn]," wxy=",$.w.size())
		$.ph[loopn].resize($.phxy[loopn])
	}
	unlock($)
}

method setverbose(n) {
	$.h.setverbose(n)
}
method refresh {
	$.getloops()
	$.updatechanbuttons()
 	$.resize()
 	$.redraw()
}
method setmute(v,m,n) {
	ch = $.h.getchann(n+1)
	$.h.mutechan(ch)
}
method setchan(v,m,n) {
	ch = $.h.getchann(n+1)
	$.h.changechan(ch)
}
method getloops {
	$.nph = $.h.getnloops()
	$.pulse = $.h.getpulse()
	Showbar = $.pulse
	# print("getloops set nph to ",$.nph,"  sizeof $.ph is ",sizeof($.ph))
	while ( sizeof($.ph) < $.nph ) {
		w = new wphrase()
		n = sizeof($.ph)
		$.ph[n] = w
		$.addchild(w)

		m = new ktoggle("M",$,"setmute",n)
		$.butt_mute[n] = m
		$.addchild(m)

		ch = $.h.getchann(n+1)
		if ( ch == "" )
			ch = 1
		m = new ktoggle(string(ch),$,"setchan",n)
		m.setonly_do_on(1)
		$.butt_chan[n] = m
		$.addchild(m)
	}
	while ( sizeof($.ph) > $.nph ) {
		n = sizeof($.ph)-1
		w = $.ph[n]
		$.removechild(w)
		deleteobject(w)
		delete $.ph[n]

		b = $.butt_mute[n]
		$.removechild(b)
		deleteobject(b)
		delete $.butt_mute[n]

		b = $.butt_chan[n]
		$.removechild(b)
		deleteobject(b)
		delete $.butt_chan[n]
	}
	maxbeats = 0
	for ( n=0; n<sizeof($.ph); n++ ) {
		p = $.h.getloopn(n+1)
		nbeats = $.h.getbeatsn(n+1)
		if ( nbeats > maxbeats )
			maxbeats = nbeats
		$.ph[n].set(p)

		m = $.h.getmuten(n+1)
		$.butt_mute[n].set(m)

		ch = $.h.getchann(n+1)
		$.butt_chan[n].settext(string(ch))

		# This could be a lot more efficient
		$.ph[n].forceview(0,nbeats*$.pulse)
		$.ph[n].fitvert()
	}
	$.maxbeats = maxbeats
	# print("GETLOOPS done, maxbeats =",maxbeats,"  $.nph=",$.nph)
}
}

function mkmenu_hoops1(o,po) {
	o.menucmd("Refresh",po,"refresh")
	o.menucmd("Debug On",po,"setverbose",1)
	o.menucmd("Debug Off",po,"setverbose",0)
}
