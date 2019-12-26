#name	wpack
#usage	wpack(args)
#desc	This is used to let you interactively pack windows.
#
# THIS DOES NOT WORK (at least, I haven't tried it in a while).

function wpack() {

	lastw = -1
	warray = []
	wlist = []
	newsz = []
	nwind = 0

	sweep1 = waitnsweep(Root,SWEEP)
	c = Root.children()
	for ( i in c ) {
		cw = c[i]
		if ( cw.contains(sweep1) )
			wlist[nwind++] = cw
	}
	dx = Root.textwidth()
	nmoved = 1
	for ( n=0; n<nwind; n++ ) {
		w = wlist[n]
		newsz[w] = w.size()
	}
	while ( nmoved > 0 ) {
		nmoved = 0
		for ( n=0; n<nwind; n++ ) {
			w = wlist[n]
			sz = newsz[w]
			if ( (sz["x0"]-dx) < sweep1["x0"] )
				continue
			sz["x0"] -= dx
			sz["x1"] -= dx
			if ( Root.windowsover(sz,[w=1]) == 0 ) {
				nmoved++
				w.erase()
				w.resize(sz)
				w.rectangle(sz)
			}
			else {
				sz["x0"] += dx
				sz["x1"] += dx
			}
		}
	}
	nmoved = 1
	while ( nmoved > 0 ) {
		nmoved = 0
		for ( n=0; n<nwind; n++ ) {
			w = wlist[n]
			sz = newsz[w]
			if ( (sz["y0"]-dx) < sweep1["y0"] )
				continue
			sz["y0"] -= dx
			sz["y1"] -= dx
			if ( Root.windowsover(sz,[w=1]) == 0 ) {
				nmoved++
				w.erase()
				w.resize(sz)
				w.rectangle(sz)
			}
			else {
				sz["y0"] += dx
				sz["y1"] += dx
			}
		}
	}
	for ( n=0; n<nwind; n++ ) {
		w = wlist[n]
		w.resize(newsz[w])
		w.redraw()
	}
return()

	px = 1
	py = 1

	if ( (sz["x1"]-sz["x0"]) < 3 ) {
		sz = fillspace(sz,wlist,"xy")
	}
	wsz = arraycopy(sz)
	for ( n=0; n<nwind; n++ ) {
		if ( dir == "x" ) {
			wsz["x0"] = sz["x0"] + n*d + n*dp+ 0.5
			wsz["x1"] = sz["x0"] + (n+1)*d + n*dp + 0.5
		}
		else {
			wsz["y0"] = sz["y0"] + n*d + n*dp + 0.5
			wsz["y1"] = sz["y0"] + (n+1)*d + n*dp + 0.5
		}
		warray[n].erase()
		warray[n].resize(wsz)
		warray[n].redraw()
	}
}
