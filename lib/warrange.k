#name	warrange
#usage	warrange(args)
#desc	This is used to let you interactively rearrange windows.

function warrange(dir) {

	print("Point to each window you want to include.")
	print("Point to the last window twice, and then sweep the desired area.")
	lasto = -1
	oarray = []
	olist = []
	nobj = 0
	while (1) {
		o = wselect()
		if ( o == Root )
			return()
		if ( o == lasto )
			break;
		if ( ! (o in olist) ) {
			oarray[nobj++] = o
			olist[o] = 1
		}
		lasto = o
	}
	sz = waitnsweep(Root,SWEEP)

	px = 1
	py = 1

	if ( (sz["x1"]-sz["x0"]) < 3 ) {
		sz = fillspace(sz,olist,"xy")
	}
	if ( dir == "x" ) {
		d = (sz["x1"] - sz["x0"])/nobj - px
		dp = px * 3
	}
	else {
		d = (sz["y1"] - sz["y0"])/nobj - py
		dp = py * 3
	}
	osz = arraycopy(sz)
	for ( n=0; n<nobj; n++ ) {
		if ( dir == "x" ) {
			osz["x0"] = sz["x0"] + n*d + n*dp+ 0.5
			osz["x1"] = sz["x0"] + (n+1)*d + n*dp + 0.5
		}
		else {
			osz["y0"] = sz["y0"] + n*d + n*dp + 0.5
			osz["y1"] = sz["y0"] + (n+1)*d + n*dp + 0.5
		}
		oarray[n].erase()
		oarray[n].resize(osz)
		oarray[n].redraw()
	}
}
