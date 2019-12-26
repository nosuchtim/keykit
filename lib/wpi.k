
class wpi {

method init {

	$.w = new window()
	$.inherit($.w)

	$.ch = 1
	$.tid = -1
	$.more = new kmenubutton("More","mkmenu_pi1",$)
	$.addchild($.more)
	$.finalphrase = new wgroup()
	$.addchild($.finalphrase)

	$.filterval = 40
	$.beginxy = xy(-1,-1)
	$.endxy = xy(-1,-1)
	$.key = 'c'
	$.startquant = 4b
	$.loopquant = 2b
	$.isdown = 0
	$.iysize = 0
	$.ixsize = 0
	$.autoplay = 1
	$.maxt = 0
	$.copied = 0
	$.phrase_playing = 0

	$.ndisplay = 5
	$.d_curr = 0
	$.d_offset = 0

	$.r_phrase = []
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
	$.r_start = []
	$.r_num = []
	$.r_secs = []
	$.r_sect = []
	for ( n=0; n<$.ndisplay; n++ ) {
		$.r_init(n)
	}

	$.d_label = []
	$.d_start = []
	$.d_num = []
	$.d_secs = []
	$.d_sect = []
	$.d_filter = []
	$.d_steptype = []
	$.d_repeats = []
	$.d_colors = []
	$.d_phrase = []
	$.d_transpose = []
	$.d_scale = []
	$.d_stepsize = []
	$.d_randstart = []
	$.d_randnum = []
	$.d_patches = []
	$.d_copy = []
	$.d_paste = []
	$.d_append = []
	$.d_delete = []

	$.v_filter = []
	fn=0;
	for ( f=10; f<=100; f+=10 )
		$.v_filter[fn++] = string(f)

	$.v_steptype = [0="N/a"]
	$.v_repeats = [0="1X",1="2X",2="3X",3="4X"]
	$.v_colors = [0="N/A"]
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
	$.v_patches = [0="no patch changes", 1="random patches"]
 	$.buttup = new kbutton(global(draw_uparrow),$,"scrollup")
 	$.addchild($.buttup)
 	$.buttdown = new kbutton(global(draw_downarrow),$,"scrolldown")
 	$.addchild($.buttdown)

 	for ( n=0; n<$.ndisplay; n++ ) {
 		$.d_phrase[n] = new wphrase()
 		$.addchild($.d_phrase[n])
 		$.d_label[n] = new ktoggle(string(n),$,"setcurr",n)
 		$.addchild($.d_label[n])
 		$.d_start[n] = new wtext("1")
 		$.addchild($.d_start[n])
 		$.d_num[n] = new wtext("50")
 		$.addchild($.d_num[n])
 		$.d_secs[n] = new wtext("2")
 		$.addchild($.d_secs[n])
 		$.d_sect[n] = new wtext("1")
 		$.addchild($.d_sect[n])
 		$.d_filter[n] = new kvalbutton($.v_filter,$,"setfilter",n)
 		$.addchild($.d_filter[n])
 		$.d_steptype[n] = new kvalbutton($.v_steptype,$,"setsteptype",n)
 		$.addchild($.d_steptype[n])
 		$.d_repeats[n] = new kvalbutton($.v_repeats,$,"setrepeats",n)
 		$.addchild($.d_repeats[n])
 		$.d_colors[n] = new kvalbutton($.v_colors,$,"setcolors",n)
 		$.addchild($.d_colors[n])
 		$.d_randstart[n] = new kbutton("Start",$,"randstart",n)
 		$.addchild($.d_randstart[n])
 		$.d_randnum[n] = new kbutton("Num",$,"randnum",n)
 		$.addchild($.d_randnum[n])
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
}
method get {
	return($.finalphrase.get())
}
method snarf {
	Snarf = $.get()
}
method r_init(n) {
	$.r_phrase[n] = ''
	$.r_start[n] = 1
	$.r_num[n] = 10
	$.r_secs[n] = 2
	$.r_sect[n] = 8
	$.r_points[n] = []
	$.r_scansteps[n] = 4
	$.r_filter[n] = 100
	$.r_steptype[n] = 0
	$.r_scantype[n] = "LR"
	$.r_stepsize[n] = 3	# 1b/4
	$.r_transpose[n] = 0
	$.r_patches[n] = 1
	$.r_scale[n] = "none"
	$.r_colors[n] = 0
	$.r_repeats[n] = 1
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
method randstart(n) {
	t = n+$.d_offset
	if ( (t+1) > $.maxt )
		$.maxt = t + 1

	$.changecurr(n)

	$.r_start[t] = 1+rand(10000)

	$.r_secs[t] = 2	# seconds
	$.r_sect[t] = 8
	# $.r_num[t] = 10+rand(100)
	$.finishup(n)
}
method randnum(n) {
	t = n+$.d_offset
	if ( (t+1) > $.maxt )
		$.maxt = t + 1

	$.changecurr(n)

	$.r_num[t] = 10+rand(100)
	$.finishup(n)
}
method finishup(n) {

	t = n+$.d_offset

 	$.d_start[n].settext(string($.r_start[t]))
 	$.d_start[n].redraw()

 	$.d_num[n].settext(string($.r_num[t]))
 	$.d_num[n].redraw()

 	$.d_sect[n].settext(string($.r_sect[t]))
 	$.d_sect[n].redraw()

 	$.d_secs[n].settext(string($.r_secs[t]))
 	$.d_secs[n].redraw()

	p = $.compute(t)

	$.r_phrase[t] = p
	$.d_phrase_set($.d_curr,p,1)

	$.reset_display(n)
	$.update_change(t)

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
	$.r_start[t] = copied["start"]
	$.r_num[t] = copied["num"]
	$.r_secs[t] = copied["secs"]
	$.r_sect[t] = copied["sect"]
	$.r_steptype[t] = copied["steptype"]
	$.r_scansteps[t] = copied["scansteps"]
	$.r_stepsize[t] = copied["stepsize"]
	$.r_filter[t] = copied["filter"]
	$.r_transpose[t] = copied["transpose"]
	$.r_patches[t] = copied["patches"]
	$.r_scale[t] = copied["scale"]
	$.r_colors[t] = copied["colors"]
	$.r_repeats[t] = copied["repeats"]

	$.r_start[t] = copied["start"]
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
	$.r_scansteps[t] = integer($.v_scansteps[v])
	$.changecurr(n)
	$.update_change(t)
}
method setcolors(v,n) {
	t = n+$.d_offset
	$.r_colors[t] = v
	$.changecurr(n)
	$.update_change(t)
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
method resize (sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	$.dy = 2*$.textheight() + 5
	tw = $.textwidth()

	$.xm = $.xmin() + ($.xmax()-$.xmin())/2
	$.dxm0 = ($.xm - $.xmin()) / 3

	dxm = ($.xmax() - $.xm)/5

	$.more.resize(xy($.xmin()+2,$.ymin()+$.textheight()+2,
		$.xmin()+$.dxm0-4,$.ymin()+$.dy-2))

	$.finalphrase.resize(xy($.xmin()+2,
		$.ymin()+$.dy+2,
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

		$.d_start[n].resize(xy(x+dx+2,ya,x+2*dx,ym))
		$.d_randstart[n].resize(xy(x+dx+2,ym+2,x+2*dx,yb))

		$.d_num[n].resize(xy(x+2*dx+2,ya,x+3*dx,ym))
		$.d_randnum[n].resize(xy(x+2*dx+2,ym+2,x+3*dx,yb))

		$.d_secs[n].resize(xy(x+3*dx+2,ya,x+4*dx,ym))
		$.d_stepsize[n].resize(xy(x+3*dx+2,ym+2,x+4*dx,yb))

		$.d_sect[n].resize(xy(x+4*dx+2,ya,x+5*dx,ym))
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
		$.d_curr = newcurr
	}
		
 	for ( n=0; n<$.ndisplay; n++ ) {
		t = n + $.d_offset
		if ( n == $.d_curr ) {
			$.d_label[n].set(1)
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
	$.d_start[n].settext(string($.r_start[t]))
	$.d_start[n].redraw()
	$.d_num[n].settext(string($.r_num[t]))
	$.d_num[n].redraw()
	$.d_secs[n].settext(string($.r_secs[t]))
	$.d_secs[n].redraw()
	$.d_sect[n].settext(string($.r_sect[t]))
	$.d_sect[n].redraw()
}
method redraw {
	$.w.redraw()
	$.reset_display()
	$.w.textleft("Pi Slice",xy($.xmin()+1,$.ymin(),
		$.xmin()+$.dxm0,$.ymin()+$.textheight()))
	methodbroadcast()
}

method datafrom(t) {
	return([
		"start" = $.r_start[t],
		"num" = $.r_num[t],
		"secs" = $.r_secs[t],
		"sect" = $.r_sect[t],
		"steptype" = $.r_steptype[t],
		"scansteps" = $.r_scansteps[t],
		"stepsize" = $.r_stepsize[t],
		"filter" = $.r_filter[t],
		"transpose" = $.r_transpose[t],
		"patches" = $.r_patches[t],
		"scale" = $.r_scale[t],
		"colors" = $.r_colors[t],
		"repeats" = $.r_repeats[t],

		"start" = $.r_start[t]
		])
}

method dump {
	return ( [
		"start" = $.r_start,
		"num" = $.r_num,
		"secs" = $.r_secs,
		"sect" = $.r_sect,
		"steptype" = $.r_steptype,
		"scansteps" = $.r_scansteps,
		"stepsize" = $.r_stepsize,
		"filter" = $.r_filter,
		"transpose" = $.r_transpose,
		"patches" = $.r_patches,
		"scale" = $.r_scale,
		"colors" = $.r_colors,
		"repeats" = $.r_repeats,
		"start" = $.r_start,
		"maxt" = $.maxt
		] )
}
method restore(st) {
	$.maxt = st["maxt"]
	$.r_start = arraycopy(st["start"])
	$.r_num = arraycopy(st["num"])
	$.r_secs = arraycopy(st["secs"])
	$.r_sect = arraycopy(st["sect"])
	$.r_scansteps = arraycopy(st["scansteps"])
	$.r_steptype = arraycopy(st["steptype"])
	$.r_filter = arraycopy(st["filter"])
	$.r_stepsize = arraycopy(st["stepsize"])
	$.r_transpose = arraycopy(st["transpose"])
	$.r_patches = arraycopy(st["patches"])
	$.r_scale = arraycopy(st["scale"])
	$.r_colors = arraycopy(st["colors"])
	$.r_repeats = arraycopy(st["repeats"])
	$.r_start = arraycopy(st["start"])
	$.compute_all(-1,1)
}
method set_curr_coord() {
 	$.d_x_start[$.d_curr].redraw()
 	$.d_num[$.d_curr].redraw()
 	$.d_secs[$.d_curr].redraw()
 	$.d_sect[$.d_curr].redraw()
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
	if ( $.r_start[t]==0 && $.r_num[t]==0 && $.r_secs[t]==0 && $.r_sect[t]==0 )
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
method compute(t) {

	# print("piscan args are ",$.r_start[t], $.r_num[t], $.r_sect[t]*1b,'c',$.r_secs[t])

	r = piscan($.r_start[t], $.r_num[t], $.r_sect[t]*1b,'c',$.r_secs[t],
		$.r_patches[t])
	if ( $.r_repeats[t] > 1 ) {
		r = repeat(r,$.r_repeats[t])
	}
	return(r)
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
		$.stop()
		# $.playthis($.finalphrase)
		# return()
	}
	mouseforward(m,"mousedown")
}

}

function mkmenu_pi1(o,po) {
	o.menucmd("Snarf",po,"snarf")
}
