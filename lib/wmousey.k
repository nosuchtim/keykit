# "Mousey" is an interactive playing mechanism - you press the
# mouse buttons and move the mouse, and chords are played.

class wmousey {

method init {

	$.w = new window()
	$.inherit($.w)

	$.ch = 1
	$.tid = -1
	$.height = 60
	$.width = 60
	$.grid = new wgrid($.width,$.height)
	$.addchild($.grid)
	$.more = new kmenubutton("More","mkmenu_mousey1",$)
	$.addchild($.more)
	$.onoffbutt = new ktoggle("On",$,"onoff")
	$.addchild($.onoffbutt)
	$.grid.setcallbackdown($,"gotdown")
	$.grid.setcallbackup($,"gotup")
	$.grid.setcallbackdrag($,"gotdrag")

	$.mpitches = ''
	$.randpercent = 100
	$.key = 'c'
	$.scale = "aeolian"
	$.gencells()
	$.nnotes = 1
	$.startquant = 4b
	$.stepsize = 1b/4
	$.play_fromindex = 0
	$.play_toindex = 0
	$.play_arr = []
	$.isdown = 0
}
method onoff(v) {
	if ( v ) {
		if ( $.tid >= 0 )
			kill($.tid)
		$.tid = task $.mouseytask()
	} else {
		kill($.tid)
		$.tid = -1
		$.isdown = 0
	}
}
method mouseytask {
	# print("mouseytask start")
	tm = Now
	tm = nextquant(tm,$.startquant)
	while ( 1 ) {
		sleeptill(tm-2)
		arr = $.popevent()
		if ( arr == 0 ) {
			tm += $.stepsize
			continue
		}
		if ( typeof(arr) != "array" ) {
			print("Hey, arr=",arr)
			tm += $.stepsize
			continue
		}
		t = arr["type"]
		if ( t == "note" ) {
			if ( "p" in arr ) {
				p = arr["p"]
				p.chan = $.ch
				realtime(p,tm)
				# print("realtime p=",p," tm=",tm," Now=",Now)
			} else {
				print("Hey, p not in arr")
			}
			if ( "time" in arr ) {
				tm += arr["time"]
			} else {
				print("Hey, time not in arr")
			}
		} else if ( t == "clear" ) {
			$.play_fromindex = 0
			$.play_toindex = 0
			$.play_arr = []
		}
	}
}
method delete {
	kill($.tid)
}
method resize (sz) {
			if ( nargs() > 0 )
				$.w.resize(sz)
			$.dy = $.textheight() + 5
			tw = $.textwidth()
			$.grid.resize(xy($.xmin()+2,$.ymin()+$.dy,
					$.xmax()-2,$.ymax()-2))
			$.xm = ($.xmin()+$.xmax())/2
			if ( $.xm < ($.xmax()-18*tw) )
				$.xm = ($.xmax()-18*tw)
			$.xm2 = ($.xmax() + $.xm)/2
			$.onoffbutt.resize(xy($.xm,$.ymin()+2,
				$.xm2-1,$.ymin()+$.dy-2))
			$.more.resize(xy($.xm2+1,$.ymin()+2,
				$.xmax()-2,$.ymin()+$.dy-2))
		}
method redraw {
			$.w.redraw()
			$.w.text("Mousey",xy($.xmin(),$.ymin(),
					$.xm,$.ymin()+$.dy))
			methodbroadcast()
		}
method gotdown (m,ms) {
	$.mmdown(m,ms)
	$.isdown = 1
}
method gotup (m,ms) {
	$.isdown = 0
	$.mmoff(m,ms)
	$.addevent("clear")
}
method gotdrag (m,ms) { $.mmdrag(m,ms) }

method gencells() {
	lock($)
	nts = completescale($.key,$.scale)
	$.mmap1 = []
	$.mmap2 = []
	for ( c=0; c<$.width; c++ ) {
		for ( r=0; r<$.height; r++ ) {
			p = (nts%(c+10))
			p.time = 0
			$.mmap1[r*$.width+c] = p

			p = (nts%(r+10))
			p.time = 0
			$.mmap2[r*$.width+c] = p
		}
	}
	unlock($)
}
method getcell(m,ms) {
	lock($)
	c = m["col"]
	r = m["row"]
	if ( ms["button"] == 1 )
		p = $.mmap1[r*$.width + c]
	else
		p = $.mmap2[r*$.width + c]
	unlock($)
	return(p)
}

method mmon {
	if ( $.mpitches != '' ) {
		n = $.mpitches
		n.type = NOTEON
		$.addevent("note",n,$.stepsize)
	}
}

method addevent(typ,p,tm) {
	if ( nargs() == 1 ) {
		arr = ["type"=typ]
	} else {
		arr = ["type"=typ,"p"=p,"time"=tm]
	}
	$.play_arr[$.play_toindex] = arr
	$.play_toindex++
}

method popevent {
	lock($)
	if ( $.play_toindex > $.play_fromindex ) {
		p = $.play_arr[$.play_fromindex]
		$.play_fromindex++
		unlock($)
		return(p)
	} else {
		$.play_fromindex = 0
		$.play_toindex = 0
		unlock($)
		return(0)
	}
}

method mmoff {
	lock($)
	if ( $.mpitches != '' ) {
		n = $.mpitches
		n.type = NOTEOFF
		$.addevent("note",n,0)
	}
	unlock($)
}

method mmdown(m,ms) {
	$.mmoff()		# in case of multiple downs
	$.mpitches = $.getcell(m,ms)
	$.mmon()
}
method mmdrag(m,ms) {
	newpitches = $.getcell(m,ms)
	if ( newpitches != $.mpitches ) {
		$.mmoff()
		if ( rand(100) < $.randpercent ) {
			$.mpitches = newpitches
			$.mmon()
		} else {
			$.mpitches = ''
		}
	}
}
method setstepsize(n) {
	$.onoff(0)
	$.stepsize = n
	$.onoff(1)
}
method setscale(s) {
	$.scale = s
	$.onoff(0)
	$.gencells()
	$.onoff(1)
}
method readfile() {
	fname = browsefiles("MIDI File (*.MID)","*.mid",0)
	if ( fname == "" ) {
		print("No file specified")
		return()
	}
	p = readmf(fname)
	arr = split(p)


	lock($)
	$.mmap1 = []
	$.mmap2 = []
	ai = 0

	ntofill = ($.width * $.height) / 5
	nleft = ntofill
	octshift = -3

	for ( c=0; c<$.width; c++ ) {
		for ( r=0; r<$.height; r++ ) {
			if ( ! ( ai in arr ) )
				ai = 0
			if ( --nleft <= 0 ) {
				nleft = ntofill
				octshift++
			}
			p = arr[ai]
			ai++
			p.pitch += (octshift * 12)
			p.time = 0
			$.mmap1[r*$.width+c] = p
			p = mono(p)
			$.mmap2[r*$.width+c] = p
		}
	}
	unlock($)
}
method setchan(c) {
	$.ch = c
}
}

function mkmenu_mousey1(o,po) {
	o.submenu("Channel   ->","mkmenu_mouseychan",po)
	o.submenu("Scale     ->","mkmenu_mouseyscale",po)
	o.submenu("Step Size ->","mkmenu_mouseysize",po)
	o.menucmd("Read File",po,"readfile")
}
function mkmenu_mouseychan(o,po) {
	for ( c=1; c<=16; c++ ) {
		o.menucmd(string(c),po,"setchan",c)
	}
}
function mkmenu_mouseyscale(o,po) {
	o.menucmd("Ionian",po,"setscale","ionian")
	o.menucmd("Dorian",po,"setscale","dorian")
	o.menucmd("Phrygian",po,"setscale","phrygian")
	o.menucmd("Lydian",po,"setscale","lydian")
	o.menucmd("Mixolydian",po,"setscale","mixolydian")
	o.menucmd("Aeolian",po,"setscale","aeolian")
	o.menucmd("Locrian",po,"setscale","locrian")
	o.menucmd("Newage",po,"setscale","newage")
	o.menucmd("Fifths",po,"setscale","fifths")
}
function mkmenu_mouseysize(o,po) {
	o.menucmd("1b",po,"setstepsize",1b)
	o.menucmd("1b/2",po,"setstepsize",1b/2)
	o.menucmd("1b/4",po,"setstepsize",1b/4)
	o.menucmd("1b/8",po,"setstepsize",1b/8)
	o.menucmd("1b/16",po,"setstepsize",1b/16)
}
