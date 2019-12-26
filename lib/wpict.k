
class wpict {

method init {

	$.w = new window()
	$.inherit($.w)

	$.ch = 1
	$.tid = -1
	$.more = new kmenubutton("More","mkmenu_pict1",$)
	$.addchild($.more)
	$.sweepbutt = new kbutton("Sweep",$,"sweep")
	$.addchild($.sweepbutt)
	$.img = new wimage()
	$.addchild($.img)
	$.doingbegin = new ktoggle("Bgn",$,"setbegin")
	$.addchild($.doingbegin)
	$.doingend = new ktoggle("End",$,"setend")
	$.addchild($.doingend)

	$.filterval = 40
	$.beginxy = xy(-1,-1)
	$.endxy = xy(-1,-1)
	$.key = 'c'
	$.scale = "aeolian"
	$.startquant = 4b
	$.stepsize = 1b/4
	$.nsteps = 8
	$.isdown = 0
	$.iysize = 0
	$.ixsize = 0
	$.setonly("")

	$.img.setnotify($)

	$.doingbegin.set(1)
	$.doingend.set(0)
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
method setbegin(v) {
	if ( v == 1 ) {
		$.doingend.set(0)
		$.doingend.redraw()
	}
}
method setend(v) {
	if ( v == 1 ) {
		$.doingbegin.set(0)
		$.doingbegin.redraw()
	}
}
method readfile() {
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
	$.dy = $.textheight() + 5
	tw = $.textwidth()
	$.xm = ($.xmin()+$.xmax())/2

	if ( $.xm > ($.xmin()+13*tw) )
		$.xm = ($.xmin()+13*tw)

	dxm = ($.xmax() - $.xm)/5


	$.sweepbutt.resize(xy($.xm,$.ymin()+2,
		$.xm+dxm-1,  $.ymin()+$.dy-2))
	$.doingbegin.resize(xy($.xm+dxm+1,$.ymin()+2,
		$.xm+2*dxm-1,  $.ymin()+$.dy-2))
	$.doingend.resize(xy($.xm+2*dxm+1,$.ymin()+2,
		$.xm+3*dxm-1,  $.ymin()+$.dy-2))
	$.more.resize(xy($.xm+3*dxm,$.ymin()+2,
		$.xmax()-2,$.ymin()+$.dy-2))

	$.img.resize(xy($.xmin()+2,$.ymin()+30,
		$.xmax()-2,$.ymax()-2))
}
method redraw {
	$.w.redraw()
	$.w.text("PictSweep",xy($.xmin()+1,$.ymin(),
		$.xm,$.ymin()+$.dy))
	methodbroadcast()
}

method dump {
	return ( [
		"img" = $.img.dump(),
		"beginxy" = $.beginxy,
		"endxy" = $.endxy,
		"nsteps" = $.nsteps,
		"stepsize" = $.stepsize,
		"scale" = $.scale
		] )
}
method restore(st) {
	$.img.restore(st["img"])
	$.reinitimage()
	$.beginxy = arraycopy(st["beginxy"])
	$.endx = arraycopy(st["endxy"])
	$.nsteps = st["nsteps"]
	$.stepsize = st["stepsize"]
	$.scale = st["scale"]
}
method gotline(arr) {
	if ( $.doingbegin.get() == 1 ) {
		$.beginxy = arraycopy(arr)
	} else {
		$.endxy = arraycopy(arr)
	}
}

method sweep {
	bx0 = $.beginxy["x0"]
	by0 = $.beginxy["y0"]
	bx1 = $.beginxy["x1"]
	by1 = $.beginxy["y1"]
	dx0 = $.endxy["x0"] - $.beginxy["x0"]
	dy0 = $.endxy["y0"] - $.beginxy["y0"]
	dx1 = $.endxy["x1"] - $.beginxy["x1"]
	dy1 = $.endxy["y1"] - $.beginxy["y1"]
	r = ''
	colors = ["r"=1,"g"=1,"b"=1]
	chans = ["r"=1,"g"=2,"b"=3]
	lastpos = ["r"=-1,"g"=-1,"b"=-1]
	for ( n=0; n<($.nsteps+1); n++ ) {
		x0 = bx0 + n * dx0 / $.nsteps
		y0 = by0 + n * dy0 / $.nsteps
		x1 = bx1 + n * dx1 / $.nsteps
		y1 = by1 + n * dy1 / $.nsteps
		$.img.drawline(x0,y0,x1,y1)

		rr = ''

		peaks = $.linepeaks(x0,y0,x1,y1)
# print("peaks=",peaks)

		for ( c in colors ) {
			if ( $.redonly && c != "r" )
				continue
			if ( $.greenonly && c != "g" )
				continue
			if ( $.blueonly && c != "b" )
				continue
			arr = peaks[c]
			if ( arr["val"] > $.filterval ) {
# print("arrval = ",arr["val"])
				nt = arr["nt"]
				nt.chan = chans[c]
				rr |= nt
				x = arr["x"]
				y = arr["y"]
				# print("val = ",arr["val"])
				$.img.drawpoint(x,y)
				lastpos[c] = arr["pos"]
			}
		}
		rr.length = $.stepsize
		r += rr
	}
	# r = step(r,$.stepsize)
	print("r=",r," stepsize=",$.stepsize)
	realtime(r)
}
method linepeaks(x0,y0,x1,y1) {

# print("linepeaks xy0=",x0,y0,"  xy1=",x1,y1)
	if ( 0 ) {
		sc = completescale($.key,$.scale)
		ntarr = []
		n = 0
		for ( nt in sc ) {
			ntarr[n++] = nt
		}
	} else {
		p = readmf("prelude.mid")
		p.chan = 1
		p = head(p,100)
		ntarr = splitonstarts(p,0,1)
	}

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
# print("ntarrsize=",ntarrsize)
# print("ntarr=",ntarr)
	if ( ! ( x0 == x1 && y0 == y1 ) ) {
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

method setnsteps(n) {
	$.nsteps = n
}
method setfilter(n) {
	$.filterval = n
}
method setstepsize(n) {
	$.stepsize = n
}
method setkey(s) {
	$.key = k
}
method setscale(s) {
	$.scale = s
}
}

function mkmenu_pict1(o,po) {
	o.submenu("Scale     ->","mkmenu_pictscale",po)
	o.submenu("Key       ->","mkmenu_pictkey",po)
	o.submenu("Step Size ->","mkmenu_pictstepsize",po)
	o.submenu("# of Steps->","mkmenu_pictnsteps",po)
	o.submenu("Filter Lim->","mkmenu_pictfilter",po)
	o.submenu("Colors    ->","mkmenu_pictonly",po)
	o.menucmd("Read File",po,"readfile",1)
	o.menucmd("One Step",po,"onestep")
	o.menucmd("Read File",po,"readfile")
}
function mkmenu_pictkey(o,po) {
	o.menucmd("C",po,"setkey",'c')
	o.menucmd("C#",po,"setkey",'c+')
	o.menucmd("D",po,"setkey",'d')
	o.menucmd("D#",po,"setkey",'d+')
	o.menucmd("E",po,"setkey",'e')
	o.menucmd("F",po,"setkey",'f')
	o.menucmd("F#",po,"setkey",'f+')
	o.menucmd("G",po,"setkey",'g')
	o.menucmd("G#",po,"setkey",'g+')
	o.menucmd("A",po,"setkey",'a')
	o.menucmd("A#",po,"setkey",'a+')
	o.menucmd("B",po,"setkey",'b')
}
function mkmenu_pictscale(o,po) {
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
function mkmenu_pictstepsize(o,po) {
	o.menucmd("1b",po,"setstepsize",1b)
	o.menucmd("1b/2",po,"setstepsize",1b/2)
	o.menucmd("1b/4",po,"setstepsize",1b/4)
	o.menucmd("1b/8",po,"setstepsize",1b/8)
	o.menucmd("1b/16",po,"setstepsize",1b/16)
}
function mkmenu_pictnsteps(o,po) {
	o.menucmd("4",po,"setnsteps",4)
	o.menucmd("8",po,"setnsteps",8)
	o.menucmd("16",po,"setnsteps",16)
	o.menucmd("32",po,"setnsteps",32)
	o.menucmd("64",po,"setnsteps",64)
	o.menucmd("128",po,"setnsteps",128)
}
function mkmenu_pictonly(o,po) {
	o.menucmd("All",po,"setonly","")
	o.menucmd("Red only",po,"setonly","r")
	o.menucmd("Green only",po,"setonly","g")
	o.menucmd("Blue only",po,"setonly","b")
}
function mkmenu_pictfilter(o,po) {
	o.menucmd("0",po,"setfilter",0)
	o.menucmd("20",po,"setfilter",20)
	o.menucmd("40",po,"setfilter",40)
	o.menucmd("60",po,"setfilter",60)
	o.menucmd("80",po,"setfilter",80)
	o.menucmd("100",po,"setfilter",100)
	o.menucmd("150",po,"setfilter",150)
	o.menucmd("200",po,"setfilter",200)
}
