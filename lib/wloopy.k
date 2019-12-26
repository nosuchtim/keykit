
class wloopy {

method init {

	$.w = new window()
	$.inherit($.w)

	$.first = 0
	$.rows = 8
	$.cols = 8
	$.grid = new wgrid($.rows,$.cols)
	$.addchild($.grid)
	$.grid.setcallbackdown($,"gotdown")
	$.grid.setcallbackup($,"gotup")
	$.grid.setcallbackdrag($,"gotdrag")

	# General midi patchmap
	psz = sizeof(Patchmap)
	$.pname = []
	$.pnum = []
	for ( n=0; n<psz; n++ ) {
		$.pname[n] = Patchmap[n]["name"]
		$.pnum[n] = Patchmap[n]["num"]
	}
	$.lengths = []
	for ( n=0; n<16; n++ )
		$.lengths[n] = string(n+1)
	$.nnotes = []
	for ( n=0; n<16; n++ )
		$.nnotes[n] = string(n+1)
	$.chans = []
	for ( n=0; n<16; n++ )
		$.chans[n] = string(n+1)
	$.durations = []
	$.durations[0] = "1";
	$.durations[1] = "1,2";
	$.durations[2] = "1,1.5,2";
	$.durations[3] = "1,2,4";
	$.durationsarr = []
	$.durationsarr[0] = [0=1];
	$.durationsarr[1] = [0=1,1=2];
	$.durationsarr[2] = [0=1,1=1.5,2=2];
	$.durationsarr[3] = [0=1,1=2,2=4];

	$.row_patch = []	# patch buttons
	$.row_length = []	# length buttons
	$.row_nnotes = []	# tempo buttons
	$.row_vary = []		# duration vary buttons
	$.row_chan = []		# channel buttons
	for ( n=0; n<$.rows; n++ ) {
		$.row_patch[n] = new kvalbutton($.pname,$,"patchchanged",n)
		$.row_patch[n].set(0)
		$.row_length[n] = new kvalbutton($.lengths,$,"lengchanged",n)
		$.row_length[n].set(0)
		$.row_nnotes[n] = new kvalbutton($.nnotes,$,"nnoteschanged",n)
		$.row_nnotes[n].set(n)
		$.row_vary[n] = new kvalbutton($.durations,$,"durchanged",n)
		$.row_vary[n].set(0)
		$.row_chan[n] = new kvalbutton($.chans,$,"chanchanged",n)
		$.row_chan[n].set(n)
		$.addchild($.row_patch[n])
		$.addchild($.row_length[n])
		$.addchild($.row_nnotes[n])
		$.addchild($.row_vary[n])
		$.addchild($.row_chan[n])
	}
	$.trans = 0
	$.transvals = []
	for ( n=-12; n<=12; n++ )
		$.transvals[n+12] = string(n)

	$.transbutt = new kvalbutton($.transvals,$,"transchanged")
	$.transbutt.set(12)
	$.clearbutt = new kbutton("Clear",$,"clear")
	$.morebutt = new kmenubutton("More","mkmenu_gridder1",$)
	$.addchild($.transbutt)
	$.addchild($.morebutt)
	$.addchild($.clearbutt)

	$.durtype = 0
	$.startquant = 1b
	$.p = ''
	$.recompute()
	$.sendpatches()
}

method dump() {
	st = []
	st["p"] = $.p
	st["rows"] = $.rows
	st["cols"] = $.cols
	st["trans"] = $.trans
	st["patch"] = []
	st["nnotes"] = []
	st["length"] = []
	st["vary"] = []
	st["chan"] = []
	for ( n=0; n<$.rows; n++ ) {
		st["patch"][n] = $.row_patch[n].get()
		st["nnotes"][n] = $.row_nnotes[n].get()
		st["length"][n] = $.row_length[n].get()
		st["vary"][n] = $.row_vary[n].get()
		st["chan"][n] = $.row_chan[n].get()
	}
	return(st)
}

method restore(st) {
	$.p = st["p"]
	$.rows = st["rows"]
	$.cols = st["cols"]
	$.trans = st["trans"]
	for ( n=0; n<$.rows; n++ ) {
		$.row_patch[n].set(st["patch"][n])
		$.row_nnotes[n].set(st["nnotes"][n])
		$.row_length[n].set(st["length"][n])
		$.row_vary[n].set(st["vary"][n])
		$.row_chan[n].set(st["chan"][n])
	}
	$.recompute()
}

method set(p) {
	p = strip(p)
	p.length = latest(p)
	$.p = p
	$.recompute()
}
method loadfile() {
	p = browsephrase()
	if ( sizeof(p) > 0 )
		$.set(p)
}
method loadsnarf() {
	if ( sizeof(Snarf) > 0 )
		$.set(Snarf)
}
method transchanged(v) {
	$.trans = v - 12
	$.recompute()
}
method patchchanged(v,r) {
	$.sendpatches()
}
method nnoteschanged(v,r) {
	$.recompute()
}
method lengchanged(v,r) {
	$.recompute()
}
method durchanged(v,r) {
	$.recompute()
}
method chanchanged(v,r) {
	$.sendpatches()
	$.recompute()
}
method recompute() {
	if ( $.first == 0 ) {
		$.cell = []
		$.cellstate = []
		$.celltask = []
		for ( r=0; r<$.rows; r++ ) {
			$.cell[r] = []
			$.cellstate[r] = []
			$.celltask[r] = []
		}
		$.first = 1
	}
	stepsize = 1b/4
	for ( r=0; r<$.rows; r++ ) {
		sectsize = $.p.length / $.cols
		nnotes = 0 + $.row_nnotes[r].getvalue()
		ch = $.row_chan[r].get() + 1
		vry = $.row_vary[r].get()
		durarr = $.durationsarr[vry]
		for ( c=0; c<$.cols; c++ ) {
			p = cut($.p,CUT_TIME,c*sectsize,(c+1)*sectsize)
			p = strip(p)
			p = step(p,stepsize)
			p.pitch += $.trans
			p = head(p,nnotes)
			# p.chan = r+1
			p.chan = ch
			p.length = latest(p)
			ntimes = 0 + $.row_length[r].getvalue()
			p = scatimes(p,ntimes)
			if ( vry > 0 ) {
				dsz = sizeof(durarr)
				nn = sizeof(p)
				for ( n=0; n<nn; n++ ) {
					f = durarr[rand(dsz)]
					df = p%n.dur * f
					p%n.dur = integer(df)
				}
				p = arpeggio(p)
			}
			$.cell[r][c] = p
			if ( $.first == 0 ) {
				$.cellstate[r][c] = 0
				$.celltask[r][c] = 0
			}
		}
	}
}

method sendpatches() {
	for ( r=0; r<$.rows; r++ ) {
		ch = $.row_chan[r].get() + 1
		p = progchange(1+$.row_patch[r].get(),ch)
		realtime(p)
	}
}

method resize (sz) {
		if ( nargs() > 0 )
			$.w.resize(sz)
		$.dy = $.textheight() + 5
		tw = $.textwidth()
		$.xm = ($.xmin()+$.xmax())/2

		$.ym = $.ymin() + 3*$.dy
		$.dx2 = ($.xmax() - $.xm) / 5
		ysz = $.ymax() - $.ym
		y0 = $.ym

		# resize grid
		$.grid.resize(xy($.xmin()+2,$.ym, $.xm-2,$.ymax()-2))

		for ( n=0; n<$.rows; n++ ) {
			y0 = $.ym + (n*ysz) / $.rows
			y1 = $.ym + ((n+1)*ysz) / $.rows
			$.row_patch[n].resize(xy($.xm+2,y0+1,$.xm+$.dx2-2,y1-1))
			$.row_length[n].resize(xy($.xm+2+$.dx2,y0+1,$.xm+2*$.dx2-2,y1-1))
			$.row_nnotes[n].resize(xy($.xm+2+2*$.dx2,y0+1,$.xm+3*$.dx2-2,y1-1))
			$.row_vary[n].resize(xy($.xm+2+3*$.dx2,y0+1,$.xm+4*$.dx2-2,y1-1))
			$.row_chan[n].resize(xy($.xm+2+4*$.dx2,y0+1,$.xm+5*$.dx2-2,y1-2))
			y0 = y1
		}

		nb = 2
		dx = ($.xmax() - $.xm) / nb
		$.clearbutt.resize(xy($.xm+1,$.ymin()+2,
			$.xm+dx-1,$.ymin()+$.dy-2))
		$.morebutt.resize(xy($.xm+dx+1,$.ymin()+2,
			$.xmax()-2,$.ymin()+$.dy-2))
		$.transbutt.resize(xy($.xm+dx+1,$.ymin()+$.dy+2,
				$.xmax()-2,$.ymin()+2*$.dy-2))
}
method redraw {
		$.w.redraw()
		nb = 2
		dx = ($.xmax() - $.xm) / nb
		$.w.text("Loopy!",xy($.xmin(),$.ymin()+$.dy, $.xm,$.ymin()+2*$.dy))
		$.w.text("Transpose:",xy($.xm,$.ymin()+$.dy, $.xm+dx,$.ymin()+2*$.dy))

		$.w.text("Ptch",xy($.xm,$.ymin()+2*$.dy, $.xm+$.dx2,$.ym))
		$.w.text("Leng",xy($.xm+$.dx2,$.ymin()+2*$.dy, $.xm+2*$.dx2,$.ym))
		$.w.text("#Notes",xy($.xm+2*$.dx2,$.ymin()+2*$.dy, $.xm+3*$.dx2,$.ym))
		$.w.text("Vary",xy($.xm+3*$.dx2,$.ymin()+2*$.dy, $.xm+4*$.dx2,$.ym))
		$.w.text("Chan",xy($.xm+4*$.dx2,$.ymin()+2*$.dy, $.xmax()-1,$.ym))

		methodbroadcast()
}

method clear() {
	for ( r=0; r<$.rows; r++ ) {
		for ( c=0; c<$.cols; c++ ) {
			if ( $.cellstate[r][c] != 0 ) {
				s = $.celltask[r][c]
				if ( typeof(s) == "integer" )
					kill($.celltask[r][c])
			}
			$.cellstate[r][c] = 0
			$.celltask[r][c] = 0
			$.grid.fillcell(r,c,CLEAR)
		}
	}
	$.redraw()
}

method gotdown (m,ms) {
	r = m["row"]
	c = m["col"]
	p = $.cell[r][c]
	b = ms["button"]
	lock($)
	if ( b == 1 ) {
		# turns off repeating-forever cells
		if ( $.cellstate[r][c] == 2 ) {
			$.cellstate[r][c] = 0
			kill($.celltask[r][c])
			$.grid.fillcell(r,c,CLEAR)
		}
		else {
			# play as long as button is down
			$.cellstate[r][c] = 1
			$.celltask[r][c] = task $.playcell(r,c)
		}
	}
	else if ( b == 2 ) {
		# repeat forever (or turn off if it's already on)
		if ( $.cellstate[r][c] == 2 ) {
			$.cellstate[r][c] = 0
			kill($.celltask[r][c])
			$.grid.fillcell(r,c,CLEAR)
		}
		else {
			# repeat forever
			$.cellstate[r][c] = 2
			$.grid.fillcell(r,c,STORE)
			$.celltask[r][c] = task $.playcell(r,c)
		}
	}
	unlock($)
}

method playcell(r,c) {
	t = nextquant(Now,$.startquant)
	sleeptill(t)
	while (1) {
		p = $.cell[r][c]
		sz = p.length
		realtime(p,t)
		t += sz
		sleeptill(t)
		lock($)
		st = $.cellstate[r][c]
		unlock($)
		if ( st < 2 )
			break
	}
}

method gotup (m,ms) {
	r = m["row"]
	c = m["col"]
	p = $.cell[r][c]
	b = ms["button"]
	if ( $.cellstate[r][c] == 1 ) {
	}
}
method gotdrag (m,ms) {
}
method setstartquant(v) {
	$.startquant = v
}
}

function mkmenu_gridder1(o,po) {
	o.menucmd("Load from File",po,"loadfile")
	o.menucmd("Load from Snarf",po,"loadsnarf")
	o.submenu("Start Quant  ->","mkmenu_wrquantvals",po,"setstartquant")
}
