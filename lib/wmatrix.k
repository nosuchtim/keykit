# "Mouse Matrix" is an interactive playing mechanism - you press the
# mouse buttons and move the mouse, and chords are played.
# The chords played are determined by the mouse position and
# button pressed - a 'matrix' is imposed on the screen.

Mmstate = 0	# 1 if a note is currently playing
Mmode = 0
Mmnotes = ''
Mmpitches = ''
Mmquant = 0
if ( ! defined(Mmchan1) )
	Mmchan1 = Default_chan
if ( ! defined(Mmchan2) )
	Mmchan2 = 10

class wmatrix {

method init {
	c1 = 2 ; c2 = 5 ; cs = 20 ; p1 = 5 ; p2 = 7 ; ps = 20

	$.w = new window()
	$.inherit($.w)

	$.grid = new wgrid(cs,ps)
	$.addchild($.grid)
	$.butt1 = new kvalbutton([0="1 note",1="2 notes",2="3 notes",3="4 notes"],$,"nnoteschanged")
	$.addchild($.butt1)
	$.grid.setcallbackdown($,"gotdown")
	$.grid.setcallbackup($,"gotup")
	$.grid.setcallbackdrag($,"gotdrag")

	$.mmmake(integer(c1),integer(c2),integer(cs),
		integer(p1),integer(p2),integer(ps))
	$.nnotes = 1
}
method nnoteschanged(v) {
			$.nnotes = v+1
		}
method resize (sz) {
			if ( nargs() > 0 )
				$.w.resize(sz)
			$.dy = $.textheight() + 5
			tw = $.textwidth()
			$.grid.resize(xy($.xmin()+2,$.ymin()+$.dy,
					$.xmax()-2,$.ymax()-2))
			$.xm = ($.xmin()+$.xmax())/2
			if ( $.xm < ($.xmax()-9*tw) )
				$.xm = ($.xmax()-9*tw)
			$.butt1.resize(xy($.xm,$.ymin()+2,
					$.xmax()-2,$.ymin()+$.dy-2))
		}
method redraw {
			$.w.redraw()
			$.w.text("Mouse Matrix",xy($.xmin(),$.ymin(),
					$.xm,$.ymin()+$.dy))
			methodbroadcast()
		}
method gotdown (m,ms) { $.mmdown(m,ms) }
method gotup (m,ms) { $.mmoff(m,ms) }
method gotdrag (m,ms) { $.mmdrag(m,ms) }
method mmmake(c1,c2,cs,p1,p2,ps) {

	Mleng = cs
	Mheight = ps
	Mmmap = []
	sp = p1
	for ( c=0; c<=Mleng; c++ ) {
		thisp = sp
		for ( p=0; p<=Mheight; p++ ) {
			Mmmap[c*Mheight+p] = thisp
			if ( p%2 )
				thisp += p1
			else
				thisp += p2
		}
		if ( c%2 )
			sp += c1
		else
			sp += c2
	}
}
method mmmap(m,ms) {
	c = m["col"]
	p = m["row"]
	n1 = n2 = n3 = n4 = 'a'
	t = c*Mheight + p
	if ( Mmode == 0 ) {
		n1.pitch = Mmmap[t]
		n2.pitch = Mmmap[t+1]
		n3.pitch = Mmmap[t+2]
		n4.pitch = Mmmap[t+3]
	}
	else {
		n1.pitch = Mmmap[t]
		n2.pitch = Mmmap[t+Mleng]
		n3.pitch = Mmmap[t+2*Mleng]
		n4.pitch = Mmmap[t+3*Mleng]
	}
	if ( $.nnotes == 4 )
		p = n1|n2|n3|n4
	else if ( $.nnotes == 3 )
		p = n1|n2|n3
	else if ( $.nnotes == 2 )
		p = n1|n2
	else
		p = n1
	if ( ms["button"] == 2 )
		p.chan = Mmchan2
	else
		p.chan = Mmchan1
	return(p)
}

method mmon {
	Mmstate = 1
	Mmnotes = Mmpitches
	Mmnotes.type = NOTEON
	c = Now
	if ( Mmquant )
		c = nextquant(c,Mmquant)
	realtime(Mmnotes,c)
	if ( MatrixSnarf ) {
		Mmnotes.type = NOTE
		Snarf = Mmnotes
	}
}

method mmoff {
	if ( Mmstate ) {
		Mmstate = 0
		Mmnotes.type = NOTEOFF
		c = Now
		if ( Mmquant )
			c = nextquant(c,Mmquant)
		realtime(Mmnotes,c)
	}
}

method mmdown(m,ms) {
	$.mmoff()		# in case of multiple downs
	Mmpitches = $.mmmap(m,ms)
	$.mmon()
}
method mmdrag(m,ms) {
	newpitches = $.mmmap(m,ms)
	if ( newpitches != Mmpitches ) {
		$.mmoff()
		Mmpitches = newpitches
		$.mmon()
	}
}
}
