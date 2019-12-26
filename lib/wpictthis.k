
class wpictthis {

method init {

	$.w = new window()
	$.inherit($.w)

	$.ch = 1
	$.tid = -1
	$.more = new kmenubutton("More","mkmenu_pictthis1",$)
	$.addchild($.more)
	$.img = new wimage()
	$.addchild($.img)
	$.linephrase = new wphrase()
	$.addchild($.linephrase)
	$.finalphrase = new wphrase()
	$.addchild($.finalphrase)

	$.showlines = 1
	$.filterval = 40
	$.beginxy = xy(-1,-1)
	$.endxy = xy(-1,-1)
	$.key = 'c'
	$.startquant = 4b
	$.loopquant = 2b
	$.isdown = 0
	$.iysize = 0
	$.ixsize = 0
	$.setonly("")
	$.autoplay = 1
	$.linelimit = 1000
	$.maxt = 0
	$.copied = 0
	$.phrase_playing = 0

	$.ndisplay = 5
	$.d_curr = 0
	$.d_offset = 0

	$.r_phrase = []
	$.r_lines = []
	$.r_points = []
	$.r_filter = []
	$.r_scansteps = []
	$.r_scantype = []
	$.r_steptype = []
	$.r_transpose = []
	$.r_patches = []
	$.r_stepsize = []
	$.r_scale = []
	$.r_colors = []
	$.r_repeats = []
	$.r_x0 = []
	$.r_y0 = []
	$.r_x1 = []
	$.r_y1 = []
	for ( n=0; n<$.ndisplay; n++ ) {
		$.r_init(n)
	}

	$.d_label = []
	$.d_tx0 = []
	$.d_ty0 = []
	$.d_tx1 = []
	$.d_ty1 = []
	$.d_filter = []
	$.d_steptype = []
	$.d_repeats = []
	$.d_colors = []
	$.d_phrase = []
	$.d_transpose = []
	$.d_scale = []
	$.d_stepsize = []
	$.d_scantype = []
	$.d_scansteps = []
	$.d_patches = []
	$.d_copy = []
	$.d_paste = []
	$.d_append = []
	$.d_delete = []

	$.v_filter = []
	fn=0;
	for ( f=10; f<=100; f+=10 )
		$.v_filter[fn++] = string(f)

	$.v_steptype = [0="Step",1="Use Orig Dur"]
	$.v_repeats = [0="1",1="2",2="3",3="4"]
	$.v_colors = [0="All",1="Red Only",2="Green Only",3="Blue Only"]
	$.v_scantype = [0="LR",1="RL",2="UD",3="DU"]

	$.v_scansteps = [0="4",
			1="8",
			2="10",
			3="12",
			4="14",
			5="16",
			6="24",
			7="32",
			8="64",
			9="128"]

	$.v_stepsize = [0="2b",1="1b",2="1b/2",3="1b/4",4="1b/8",5="1b/16",6="1b/32"]
	$.v_stepsize2 = [0=2b,1=1b,2=1b/2,3=1b/4,4=1b/8,5=1b/16,6=1b/32]

	n = 0
	$.v_transpose = []
	for ( n=0; n<25; n++ ) {
		$.v_transpose[n] = string(n-12)
	}
	$.v_scale = []
	scales = allscales()
	oas = Arraysort
	Arraysort = 1
	n = 0
	$.v_scale[n++] = "none"
	for ( s in scales ) {
		$.v_scale[n++] = s
	}
	Arraysort = oas
	$.v_patches = [0="none",
		1="Based on XY (1)",
		2="Based on XY (2)",
		3="Based on XY (3)",
		4="Based on XY (4)",
		5="Piano/Bass/Guitar"]
 	$.buttup = new kbutton(global(draw_uparrow),$,"scrollup")
 	$.addchild($.buttup)
 	$.buttdown = new kbutton(global(draw_downarrow),$,"scrolldown")
 	$.addchild($.buttdown)

 	for ( n=0; n<$.ndisplay; n++ ) {
 		$.d_phrase[n] = new wphrase()
 		$.addchild($.d_phrase[n])
 		$.d_label[n] = new ktoggle(string(n),$,"setcurr",n)
 		$.addchild($.d_label[n])
 		$.d_tx0[n] = new wtext("0")
 		$.addchild($.d_tx0[n])
 		$.d_ty0[n] = new wtext("0")
 		$.addchild($.d_ty0[n])
 		$.d_tx1[n] = new wtext("0")
 		$.addchild($.d_tx1[n])
 		$.d_ty1[n] = new wtext("0")
 		$.addchild($.d_ty1[n])
 		$.d_filter[n] = new kvalbutton($.v_filter,$,"setfilter",n)
 		$.addchild($.d_filter[n])
 		$.d_steptype[n] = new kvalbutton($.v_steptype,$,"setsteptype",n)
 		$.addchild($.d_steptype[n])
 		$.d_repeats[n] = new kvalbutton($.v_repeats,$,"setrepeats",n)
 		$.addchild($.d_repeats[n])
 		$.d_colors[n] = new kvalbutton($.v_colors,$,"setcolors",n)
 		$.addchild($.d_colors[n])
 		$.d_scantype[n] = new kvalbutton($.v_scantype,$,"setscantype",n)
 		$.addchild($.d_scantype[n])
 		$.d_scansteps[n] =new kvalbutton($.v_scansteps,$,"setscansteps",n)
 		$.addchild($.d_scansteps[n])
 		$.d_stepsize[n] =new kvalbutton($.v_stepsize,$,"setstepsize",n)

 		$.d_stepsize[n].setbyval("1b/4")

 		$.addchild($.d_stepsize[n])
 		$.d_scale[n] =new kvalbutton($.v_scale,$,"setscale",n)
 		$.addchild($.d_scale[n])
 		$.d_transpose[n] =new kvalbutton($.v_transpose,$,"settranspose",n)
 		$.addchild($.d_transpose[n])
 		$.d_transpose[n].set(12)	# for transpose=0

 		$.d_patches[n] =new kvalbutton($.v_patches,$,"setpatches",n)
 		$.addchild($.d_patches[n])

		$.d_copy[n] = new kbutton("C",$,"setcopy",n)
		$.addchild($.d_copy[n])
		$.d_paste[n] = new kbutton("P",$,"setpaste",n)
		$.addchild($.d_paste[n])
		$.d_append[n] = new kbutton("A",$,"setappend",n)
		$.addchild($.d_append[n])
		$.d_delete[n] = new kbutton("X",$,"setdelete",n)
		$.addchild($.d_delete[n])
 	}

	$.img.setnotify($)
	$.setlinephrase(completescale($.key,"newage"))
	defimage = pathsearch("default.ppm")
	if ( defimage != "" )
		$.img.readfile(defimage)
}
method get {
	return($.finalphrase.get())
}
method snarf {
	Snarf = $.get()
}
method snarfline {
	Snarf = $.linephrase.get()
}
method set(p) {
	$.linephrase.set(p)
	$.linephrase.fitall()
}
method r_init(n) {
	$.r_phrase[n] = ''
	$.r_x0[n] = 0
	$.r_y0[n] = 0
	$.r_x1[n] = 0
	$.r_y1[n] = 0
	$.r_lines[n] = []
	$.r_points[n] = []
	$.r_scansteps[n] = 4
	$.r_filter[n] = 100
	$.r_steptype[n] = 0
	$.r_scantype[n] = "LR"
	$.r_stepsize[n] = 3	# 1b/4
	$.r_transpose[n] = 0
	$.r_patches[n] = 0
	$.r_scale[n] = "none"
	$.r_colors[n] = 0
	$.r_repeats[n] = 1
}
method setshowlines(v) {
	t = $.d_curr+$.d_offset
	$.drawlinesof(t)
	$.showlines = v
	$.drawlinesof(t)
}
method changecurr(newcurr) {
	$.setcurr(1,0,newcurr)
}
method setcurr(v,m,newcurr) {
	for ( n=0; n<$.ndisplay; n++ ) {
		if ( n == newcurr )
			$.d_label[n].set(1)
		else
			$.d_label[n].set(0)
	}
	if ( v != 0 )
		$.reset_display(newcurr)
	else
		$.reset_display()
}
method setcopy(n) {
	t = n+$.d_offset
	if ( t >= $.maxt )
		return()
	$.copied = $.datafrom(t)
}
method setappend(n) {
	t = n+$.d_offset
	if ( t >= $.maxt )
		return()
	for ( t1=$.maxt; t1>t; t1-- ) {
		c = $.datafrom(t1-1)
		$.datato(t1,c)
	}
	$.maxt++
	$.reset_display(n)
	$.compute_all(-1,1)
}
method setdelete(n) {
	t = n+$.d_offset
	if ( t >= $.maxt )
		return()
	$.maxt--
	for ( t1=t; t1<$.maxt; t1++ ) {
		c = $.datafrom(t1+1)
		$.datato(t1,c)
	}
	$.r_init($.maxt)
	$.reset_display()
	$.compute_all(-1,1)
}
method setpaste(n) {
	t = n+$.d_offset
	if ( (t+1) > $.maxt )
		$.maxt = t + 1
	$.datato(t,$.copied)
	$.reset_display(n)
	$.update_change(t)
}
method datato(t,copied) {
	$.r_x0[t] = copied["x0"]
	$.r_y0[t] = copied["y0"]
	$.r_x1[t] = copied["x1"]
	$.r_y1[t] = copied["y1"]
	$.r_steptype[t] = copied["steptype"]
	$.r_scansteps[t] = copied["scansteps"]
	$.r_stepsize[t] = copied["stepsize"]
	$.r_filter[t] = copied["filter"]
	$.r_transpose[t] = copied["transpose"]
	$.r_patches[t] = copied["patches"]
	$.r_scale[t] = copied["scale"]
	$.r_colors[t] = copied["colors"]
	$.r_repeats[t] = copied["repeats"]
	$.r_scantype[t] = copied["scantype"]
}
method setpatches(v,n) {
	t = n+$.d_offset
	$.r_patches[t] = v
	$.update_change(t)
}
method settranspose(v,n) {
	t = n+$.d_offset
	$.r_transpose[t] = integer($.v_transpose[v])
	$.update_change(t)
}
method setscale(v,n) {
	t = n+$.d_offset
	$.r_scale[t] = $.v_scale[v]
	$.update_change(t)
}
method setstepsize(v,n) {
	t = n+$.d_offset
	$.r_stepsize[t] = v
	$.update_change(t)
}
method setscansteps(v,n) {
	t = n+$.d_offset
	$.drawlinesof(t)
	$.r_scansteps[t] = integer($.v_scansteps[v])
	$.changecurr(n)
	$.update_change(t)
	$.drawlinesof(t)
}
method setscantype(v,n) {
	t = n+$.d_offset
	$.drawlinesof(t)
	$.r_scantype[t] = $.v_scantype[v]
	$.changecurr(n)
	$.update_change(t)
	$.drawlinesof(t)
}
method setcolors(v,n) {
	t = n+$.d_offset
	$.drawlinesof(t)
	$.r_colors[t] = v
	$.changecurr(n)
	$.update_change(t)
	$.drawlinesof(t)
}
method setrepeats(v,n) {
	t = n+$.d_offset
	$.r_repeats[t] = integer($.v_repeats[v])
	$.update_change(t)
}
method setsteptype(v,n) {
	t = n+$.d_offset
	$.r_steptype[t] = v
	$.update_change(t)
}
method setfilter(v,n) {
	t = n+$.d_offset
	$.r_filter[t] = integer($.v_filter[v])
	$.update_change(t)
}
method setup(v,n) {
	print("setup v=",v," n=",n)
}
method setdown(v,n) {
	print("setdown v=",v," n=",n)
}
method setonly(s) {
	$.redonly = $.greenonly = $.blueonly = 0
	if ( s == "r" )
		$.redonly = 1
	if ( s == "g" )
		$.greenonly = 1
	if ( s == "b" )
		$.blueonly = 1
}
method setonly(s) {
	$.redonly = $.greenonly = $.blueonly = 0
	if ( s == "r" )
		$.redonly = 1
	if ( s == "g" )
		$.greenonly = 1
	if ( s == "b" )
		$.blueonly = 1
}
method readppmfile() {
	fname = browsefiles("PPM File (*.ppm)","*.ppm",0)
	if ( fname == "" ) {
		print("No file specified")
		return()
	}
	$.img.readfile(fname)
	$.img.redraw()
	$.reinitimage()
}
method reinitimage {
	sz = $.img.imagesize()
	$.beginxy = xy(0,0,0,sz["y"]-1)
	$.endxy = xy(sz["x"]-1,0,sz["x"]-1,sz["y"]-1)
}
method resize (sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	$.dy = 2*$.textheight() + 5
	tw = $.textwidth()

	$.xm = $.xmin() + ($.xmax()-$.xmin())/2
	$.dxm0 = ($.xm - $.xmin()) / 3

	dxm = ($.xmax() - $.xm)/5

	$.linephrase.resize(xy($.xmin()+$.dxm0,$.ymin()+2,
		$.xm-1,$.ymin()+$.dy-2))
	$.more.resize(xy($.xmin()+2,$.ymin()+$.textheight()+2,
		$.xmin()+$.dxm0-4,$.ymin()+$.dy-2))

	$.img.resize(xy($.xmin()+2,$.ymin()+$.dy,
		$.xm-1,$.ymax()-3*$.textheight()))

	$.finalphrase.resize(xy($.xmin()+2,
		$.ymax()-3*$.textheight()+2,
		$.xm-1,$.ymax()-2))

	tw = $.textwidth()
	bw = 2*tw
	$.d_x0 = $.xm+bw+1
	$.d_x1 = $.xmax()-2
	$.d_y0 = $.ymin()+2
	$.d_y1 = $.ymax()-2

	th = $.textheight()
	$.buttup.resize(xy($.xm+2,$.d_y0,$.d_x0-3,$.d_y0+th))
	$.buttdown.resize(xy($.xm+2,$.d_y1-th,$.d_x0-3,$.d_y1))

	y = $.d_y0
	x = $.d_x0 + tw + 6
	dx = ($.d_x1 - x)/8
	for ( n=0; n<$.ndisplay; n++ ) {
		ya = $.d_y0 + n * ($.d_y1 - $.d_y0) / $.ndisplay
		yb = $.d_y0 + (n+1) * ($.d_y1 - $.d_y0) / $.ndisplay
		yb -= 2
		yb -= 4
		ym = (ya+yb)/2 - 1

		$.d_copy[n].resize(xy($.d_x0-tw-8,ym-th-4,$.d_x0-2,ym-1))
		$.d_delete[n].resize(xy($.d_x0+1,ym-th-4,x-2,ym-1))
		$.d_paste[n].resize(xy($.d_x0-tw-8,ym+1,$.d_x0-2,ym+th+4))
		$.d_append[n].resize(xy($.d_x0+1,ym+1,x-2,ym+th+4))

		$.d_label[n].resize(xy(x,ya,x+dx,ym-1))
		$.d_phrase[n].resize(xy(x,ym+2,x+dx,yb))

		$.d_tx0[n].resize(xy(x+dx+2,ya,x+2*dx,ym))
		$.d_scantype[n].resize(xy(x+dx+2,ym+2,x+2*dx,yb))

		$.d_ty0[n].resize(xy(x+2*dx+2,ya,x+3*dx,ym))
		$.d_scansteps[n].resize(xy(x+2*dx+2,ym+2,x+3*dx,yb))

		$.d_tx1[n].resize(xy(x+3*dx+2,ya,x+4*dx,ym))
		$.d_stepsize[n].resize(xy(x+3*dx+2,ym+2,x+4*dx,yb))

		$.d_ty1[n].resize(xy(x+4*dx+2,ya,x+5*dx,ym))
		$.d_scale[n].resize(xy(x+4*dx+2,ym+2,x+5*dx,yb))

		$.d_filter[n].resize(xy(x+5*dx+2,ya,x+6*dx,ym))
		$.d_transpose[n].resize(xy(x+5*dx+2,ym+2,x+6*dx,yb))

		$.d_steptype[n].resize(xy(x+6*dx+2,ya,x+7*dx,ym))
		$.d_patches[n].resize(xy(x+6*dx+2,ym+2,x+7*dx,yb))

		$.d_colors[n].resize(xy(x+7*dx+2,ya,x+8*dx,ym))
		$.d_repeats[n].resize(xy(x+7*dx+2,ym+2,x+8*dx,yb))
	}
}
method scrollup {
	$.d_offset--
	if ( $.d_offset < 0 )
		$.d_offset = 0
	$.reset_display()
}
method scrolldown {
	$.d_offset++
	t = $.d_offset + $.ndisplay - 1
	if ( ! ( t in $.r_phrase ) ) {
		$.r_init(t)
	}
	$.reset_display()
}
method d_phrase_set(n,p,doredraw) {
	if ( nargs() < 3 )
		doredraw = 1
	$.d_phrase[n].set(p)
	if ( doredraw ) {
		$.d_phrase[n].fitall()
		$.d_phrase[n].redraw()
	}
}
method reset_display(newcurr) {
	if ( nargs() > 0 ) {
		$.drawlinesof($.d_curr + $.d_offset)
		$.d_curr = newcurr
	}
		
 	for ( n=0; n<$.ndisplay; n++ ) {
		t = n + $.d_offset
		if ( n == $.d_curr ) {
			$.d_label[n].set(1)
			$.drawlinesof($.d_curr + $.d_offset)
		}
		else {
			$.d_label[n].set(0)
		}
		$.d_label[n].settext(string(t))
		$.d_label[n].redraw()

		$.d_phrase_set(n,$.r_phrase[t],1)

		$.redraw_coord(n)

		$.d_filter[n].setbyval($.r_filter[t])
		$.d_filter[n].redraw()

		$.d_transpose[n].setbyval($.r_transpose[t])
		$.d_transpose[n].redraw()

		$.d_patches[n].set($.r_patches[t])
		$.d_patches[n].redraw()

		$.d_colors[n].set($.r_colors[t])
		$.d_colors[n].redraw()

		$.d_repeats[n].setbyval($.r_repeats[t])
		$.d_repeats[n].redraw()

		$.d_scantype[n].setbyval($.r_scantype[t])
		$.d_scantype[n].redraw()

		$.d_scansteps[n].setbyval($.r_scansteps[t])
		$.d_scansteps[n].redraw()

		$.d_steptype[n].set($.r_steptype[t])
		$.d_steptype[n].redraw()

		$.d_stepsize[n].set($.r_stepsize[t])
		$.d_stepsize[n].redraw()

		$.d_scale[n].setbyval($.r_scale[t])
		$.d_scale[n].redraw()
	}
}
method redraw_coord(n) {
	t = n + $.d_offset
	$.d_tx0[n].settext(string($.r_x0[t]))
	$.d_tx0[n].redraw()
	$.d_ty0[n].settext(string($.r_y0[t]))
	$.d_ty0[n].redraw()
	$.d_tx1[n].settext(string($.r_x1[t]))
	$.d_tx1[n].redraw()
	$.d_ty1[n].settext(string($.r_y1[t]))
	$.d_ty1[n].redraw()
}
method redraw {
	$.w.redraw()
	$.reset_display()
	$.w.textleft("Picture This",xy($.xmin()+1,$.ymin(),
		$.xmin()+$.dxm0,$.ymin()+$.textheight()))
	methodbroadcast()
	$.drawlinesof($.d_curr + $.d_offset)
}

method datafrom(t) {
	return([
		"x0" = $.r_x0[t],
		"y0" = $.r_y0[t],
		"x1" = $.r_x1[t],
		"y1" = $.r_y1[t],
		"steptype" = $.r_steptype[t],
		"scansteps" = $.r_scansteps[t],
		"stepsize" = $.r_stepsize[t],
		"filter" = $.r_filter[t],
		"transpose" = $.r_transpose[t],
		"patches" = $.r_patches[t],
		"scale" = $.r_scale[t],
		"colors" = $.r_colors[t],
		"repeats" = $.r_repeats[t],
		"scantype" = $.r_scantype[t]
		])
}

method dump {
	return ( [
		"linephrase" = $.linephrase.get(),
		"x0" = $.r_x0,
		"y0" = $.r_y0,
		"x1" = $.r_x1,
		"y1" = $.r_y1,
		"steptype" = $.r_steptype,
		"scansteps" = $.r_scansteps,
		"stepsize" = $.r_stepsize,
		"filter" = $.r_filter,
		"transpose" = $.r_transpose,
		"patches" = $.r_patches,
		"scale" = $.r_scale,
		"colors" = $.r_colors,
		"repeats" = $.r_repeats,
		"scantype" = $.r_scantype,
		"img" = $.img.dump(),
		"maxt" = $.maxt
		] )
}
method restore(st) {
	$.img.restore(st["img"])
	$.setlinephrase(st["linephrase"])
	$.maxt = st["maxt"]
	$.r_x0 = arraycopy(st["x0"])
	$.r_y0 = arraycopy(st["y0"])
	$.r_x1 = arraycopy(st["x1"])
	$.r_y1 = arraycopy(st["y1"])
	$.r_scansteps = arraycopy(st["scansteps"])
	$.r_steptype = arraycopy(st["steptype"])
	$.r_filter = arraycopy(st["filter"])
	$.r_stepsize = arraycopy(st["stepsize"])
	$.r_transpose = arraycopy(st["transpose"])
	$.r_patches = arraycopy(st["patches"])
	$.r_scale = arraycopy(st["scale"])
	$.r_colors = arraycopy(st["colors"])
	$.r_repeats = arraycopy(st["repeats"])
	$.r_scantype = arraycopy(st["scantype"])
	$.reinitimage()
	$.compute_all(-1,1)
}
method gotline(arr) {

	$.stop()

	# We reject perfectly horizonal or vertical lines
	if ( arr["x0"]==arr["x1"] || arr["y0"]==arr["y1"] ) {
		return() 
	}
	t = $.d_curr + $.d_offset
	$.r_x0[t] = arr["x0"]
	$.r_y0[t] = arr["y0"]
	$.r_x1[t] = arr["x1"]
	$.r_y1[t] = arr["y1"]
	$.drawlinesof(t)

	t = $.d_curr + $.d_offset
	if ( (t+1) > $.maxt )
		$.maxt = t + 1
	p = $.compute(t)
	$.r_phrase[t] = p

	$.d_phrase_set($.d_curr,p,1)

	$.compute_final()
	$.redraw_final()

	$.drawlinesof(t)
	$.play_curr()
	$.redraw_coord($.d_curr)
}
method set_curr_coord() {
 	$.d_tx0[$.d_curr].redraw()
 	$.d_ty0[$.d_curr].redraw()
 	$.d_tx1[$.d_curr].redraw()
 	$.d_ty1[$.d_curr].redraw()
}

method playthis(p) {
	lock($)
	if ( $.phrase_playing != 0 && $.phrase_playing.isplaying() ) {
		$.phrase_playing.stop()
		if ( $.phrase_playing == p )
			p = 0
	}
	$.phrase_playing = p
	if ( p != 0 )
		p.play()
	unlock($)
}
method play_curr {
	$.playthis($.d_phrase[$.d_curr])

}
method stop {
	if ( $.phrase_playing != 0 ) {
		$.phrase_playing.stop()
		$.phrase_playing = 0
	}
}
method enabled(t) {
	if ( $.r_x0[t]==0 && $.r_y0[t]==0 && $.r_x1[t]==0 && $.r_y1[t]==0 )
		return(0)
	return(1)
}
method update_change(which) {
	w = $.compute_all(which,1)
	if ( $.autoplay && w != 0 ) {
		$.stop()
		$.playthis(w)
	}
}
method compute_all(which,doredraw) {
	ret = 0
	lock($)
	if ( nargs() < 1 )
		which = -1
	if ( nargs() < 2 )
		doredraw = 0
	for ( t=0; t < $.maxt ; t++ ) {
		if ( ! $.enabled(t) )
			continue
		if ( which >= 0 && t != which )
			continue
		p = $.compute(t)
		$.r_phrase[t] = p
	}
	for ( n=0; n<$.ndisplay; n++ ) {
		t = n + $.d_offset
		if ( ! $.enabled(t) )
			continue
		if ( which >= 0 && t != which )
			continue
		p = $.r_phrase[t]
		$.d_phrase_set(n,p,0)
		ret = $.d_phrase[n]
	}
	$.compute_final()
	unlock($)
	if ( doredraw ) {
		for ( n=0; n<$.ndisplay; n++ ) {
			t = n + $.d_offset
			if ( ! $.enabled(t) )
				continue
			if ( which >= 0 && t != which )
				continue
			$.d_phrase[n].fitall()
			$.d_phrase[n].redraw()
		}
		$.redraw_final()
	}
	return(ret)
}
method compute_final() {
	r = ''
	for ( n=0; n in $.r_phrase; n++ ) {
		r += $.r_phrase[n]
	}
	$.finalphrase.set(r)
}
method redraw_final() {
	$.finalphrase.fitall()
	$.finalphrase.redraw()
}
method drawlinesof(t) {
	if ( $.showlines == 1 ) {
		arr = $.r_lines[t]
		for ( n in arr ) {
			$.img.drawline(arr[n])
		}
	} else {
		arr = $.r_points[t]
		for ( n in arr ) {
			$.img.drawpoint(arr[n])
		}
	}
}
method compute(t) {

	scantype = $.r_scantype[t]
	steptype = $.r_steptype[t]

	# Hardcoded for horizontal sweep
	if ( scantype == "LR" ) {
		bx0 = $.r_x0[t]
		by0 = $.r_y0[t]
		bx1 = $.r_x0[t]
		by1 = $.r_y1[t]
		ex0 = $.r_x1[t]
		ey0 = $.r_y0[t]
		ex1 = $.r_x1[t]
		ey1 = $.r_y1[t]
	} else if ( scantype == "RL" ) {
		ex0 = $.r_x0[t]
		ey0 = $.r_y0[t]
		ex1 = $.r_x0[t]
		ey1 = $.r_y1[t]
		bx0 = $.r_x1[t]
		by0 = $.r_y0[t]
		bx1 = $.r_x1[t]
		by1 = $.r_y1[t]
	} else if ( scantype == "UD" ) {
		bx0 = $.r_x0[t]
		by0 = $.r_y0[t]
		bx1 = $.r_x1[t]
		by1 = $.r_y0[t]
		ex0 = $.r_x0[t]
		ey0 = $.r_y1[t]
		ex1 = $.r_x1[t]
		ey1 = $.r_y1[t]
	} else if ( scantype == "DU" ) {
		ex0 = $.r_x0[t]
		ey0 = $.r_y0[t]
		ex1 = $.r_x1[t]
		ey1 = $.r_y0[t]
		bx0 = $.r_x0[t]
		by0 = $.r_y1[t]
		bx1 = $.r_x1[t]
		by1 = $.r_y1[t]
	}

	dx0 = ex0 - bx0
	dy0 = ey0 - by0
	dx1 = ex1 - bx1
	dy1 = ey1 - by1

	r = ''
	colors = ["r"=1,"g"=1,"b"=1]
	chans = ["r"=1,"g"=2,"b"=3]
	lastpos = ["r"=-1,"g"=-1,"b"=-1]

	$.r_lines[t] = []
	$.r_points[t] = []
	nlines = 0
	npoints = 0

	colorsonly = $.r_colors[t]

	nsteps = $.r_scansteps[t]-1
	for ( n=0; n<(nsteps+1); n++ ) {
		x0 = bx0 + n * dx0 / nsteps
		y0 = by0 + n * dy0 / nsteps
		x1 = bx1 + n * dx1 / nsteps
		y1 = by1 + n * dy1 / nsteps
# print("bx0=",bx0," bx1=",bx1)
		$.r_lines[t][nlines++] = xy(x0,y0,x1,y1)

		rr = ''

		peaks = $.linepeaks(x0,y0,x1,y1)

		for ( c in colors ) {
			if ( colorsonly==1 && c != "r" )
				continue
			if ( colorsonly==2 && c != "g" )
				continue
			if ( colorsonly==3 && c != "b" )
				continue
			arr = peaks[c]
			if ( arr["val"] > $.filterval ) {
				nt = arr["nt"]
				nt.chan = chans[c]
				rr |= nt
				x = arr["x"]
				y = arr["y"]
				$.r_points[t][npoints++] = ["color"=c,"x"=x,"y"=y]

				lastpos[c] = arr["pos"]
			}
		}
		if ( steptype == 0 ) {
			ss = $.v_stepsize2[$.r_stepsize[t]]
			rr.length = ss
			rr.dur = ss
		} else {
		}
		r += rr
	}
	r = transpose(r,$.r_transpose[t])
	r.length = numquant(r.length,$.loopquant)
	if ( $.r_repeats[t] > 1 ) {
		r = repeat(r,$.r_repeats[t])
	}
	if ( $.r_filter[t] < 100 ) {
		rand(-$.r_x0[t]*1237)
		r = r{rand(100) < $.r_filter[t]}
	}
	if ( $.r_scale[t] != "none" ) {
		sc = completescale($.key,$.r_scale[t])
		r = scadjust(r,sc)
	}
	if ( $.r_patches[t] != 0 ) {
		pt = $.r_patches[t]
		if ( pt >= 1 && pt <= 4 ) {
			rv = $.r_x0[t]+pt*$.r_y0[t]+2*pt*$.r_x1[t]+3*pt*$.r_y1[t]
			# seed random number generator
			rand(-rv)
			p1 = patchrandom(1)
			p2 = patchrandom(2)
			p3 = patchrandom(3)
		} else if ( pt == 5 ) {
			p1 = patchnamed("Piano",1)
			p2 = patchnamed("Bass",2)
			p3 = patchnamed("Guitar",3)
		}
		pp = p1|p2|p3;
		r |= pp;
	}
	r.length = numquant(r.length,$.loopquant)
	return(r)
}
method setlinefile {
	fname = browsefiles("MIDI File (*.mid)","*.mid",0)
	if ( fname == "" ) {
		print("No file specified")
		return()
	}
	p = onlynotes(readmf(fname))
	if ( sizeof(p) == 0 ) {
		print("No notes in that midi file?")
		return()
	}
	$.setlinephrase(p,1)
	$.compute_all(-1,1)
}
method setlinesnarf {
	p = onlynotes(Snarf)
	if ( sizeof(p) == 0 ) {
		print("No notes in Snarf")
		return()
	}
	$.setlinephrase(p,1)
	$.compute_all(-1,1)
}
method setlinescale(s) {
	p = completescale($.key,s)
	if ( sizeof(p) == 0 ) {
		print("No such scale? : ",s)
		return()
	}
	$.setlinephrase(p,1)
	$.compute_all(-1,1)
}
method setlinephrase(p,doredraw) {
	if ( nargs() < 2 )
		doredraw = 0
	p.chan = 1
	if ( $.linelimit > 0 ) 
		p = head(p,$.linelimit)
	$.linephrase.set(p)
	$.linephrase.fitall()
	if ( doredraw )
		$.linephrase.redraw()
}
method linepeaks(x0,y0,x1,y1) {

	p = $.linephrase.get()
	ntarr = splitonstarts(p,0,1)

	nnotes = sizeof(ntarr)
	n = 0
	dx = float(x1-x0)/nnotes
	dy = float(y1-y0)/nnotes
	maxr_val = -9999
	maxg_val = -9999
	maxb_val = -9999
	maxr_nt = ''
	maxg_nt = ''
	maxb_nt = ''
	maxr_x = -1
	maxg_x = -1
	maxb_x = -1

	lastx = -1
	lasty = -1

	ntarrsize = sizeof(ntarr)
# print("ntarr=",ntarr)
# print("x0=",x0," x1=",x1," y0=",y0," y1=",y1)
	if ( ! ( x0 == x1 && y0 == y1 ) ) {
# print("Hi B, ntarrsize=",ntarrsize)
		n = 0
		for ( i=0; i<ntarrsize; i++ ) {
			nt = ntarr[i]
# print("nt=",nt)
			
			x = x0 + integer( ((n+0.5) * dx)+0.5 )
			y = y0 + integer( ((n+0.5) * dy)+0.5 )
# print("n=",n," xy=",x,y," dy=",dy," imgxysize=",$.img.imagesize())
			if ( x != lastx || y != lasty ) {
				rv = $.img.redat(x,y)
				gv = $.img.greenat(x,y)
				bv = $.img.blueat(x,y)
# print("rgbv = ",rv,gv,bv)
				avgv = (rv+gv+bv)/3
				redv = rv - avgv
				greenv = gv - avgv
				bluev = bv - avgv
				if ( redv > maxr_val ) {
					maxr_x = x
					maxr_y = y
					maxr_val = redv
					maxr_nt = nt
					maxr_pos = i
				}
				if ( greenv > maxg_val ) {
					maxg_x = x
					maxg_y = y
					maxg_val = greenv
					maxg_nt = nt
					maxg_pos = i
				}
				if ( bluev > maxb_val ) {
					maxb_x = x
					maxb_y = y
					maxb_val = bluev
					maxb_nt = nt
					maxb_pos = i
				}
				lastx = x
				lasty = y
			}
			n++
		}
	}
	if ( maxr_x < 0 || maxg_x < 0 || maxb_x < 0 ) {
		print("Hey, maxr_x or g_x or b_x < 0 ??");
		return([])
	}
	return (
		[
		"r" = [
			"nt" = strip(maxr_nt),
			"x" = maxr_x,
			"y" = maxr_y,
			"pos" = maxr_pos,
			"val" = maxr_val ],
		"g" = [
			"nt" = strip(maxg_nt),
			"x" = maxg_x,
			"y" = maxg_y,
			"pos" = maxg_pos,
			"val" = maxg_val ],
		"b" = [
			"nt" = strip(maxb_nt),
			"x" = maxb_x,
			"y" = maxb_y,
			"pos" = maxb_pos,
			"val" = maxb_val ]
		]
		 )
}
method mousedown (m) {
	for ( n=0; n<$.ndisplay; n++ ) {
		if ( $.d_phrase[n].contains(m) ){
			$.setcurr(1,m,n)
			$.playthis($.d_phrase[n])
			return()
		}
	}
	if ( $.finalphrase.contains(m) ) {
		$.playthis($.finalphrase)
		return()
	}
	mouseforward(m,"mousedown")
}

}

function mkmenu_pictshow(o,po) {
	o.menucmd("On",po,"setshowlines",1)
	o.menucmd("Off",po,"setshowlines",0)
}

function mkmenu_pictlinescale(o,po) {
	scales = allscales()
	for ( s in scales ) {
		o.menucmd(s,po,"setlinescale",s)
	}
}
function mkmenu_pictline(o,po) {
	o.menucmd("From File",po,"setlinefile")
	o.menucmd("From Snarf",po,"setlinesnarf")
	o.submenu("From Scale ->","mkmenu_pictlinescale",po)
}

function mkmenu_pictthis1(o,po) {
	o.menucmd("Set Picture",po,"readppmfile")
	o.submenu("Set Line     ->","mkmenu_pictline",po)
	o.submenu("Show Lines   ->","mkmenu_pictshow",po)
	o.menucmd("Snarf",po,"snarf")
	o.menucmd("Snarf Line Phrase",po,"snarfline")
}
