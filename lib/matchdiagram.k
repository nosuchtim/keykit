class matchdiagram {

method init(opacity,timeout,dx,dy,seqA,seqB) {
	$.svgdx = dx
	$.svgdy = dy
	$.opacity = opacity 
	$.timeout = timeout 
	$.seqA = seqA
	$.seqB = seqB
	$.sizeperseq = 64 / seqB
}
method drawmatch(ph,wind,rect,svg,dostep,fn) {
	print("Matching started...")
	if ( svg ) {
		f = open(fn,"w")
		$.svgstart(f)
	}
	if ( !svg ) {
		$.wind = wind
		$.r = rect
		$.wind.fillrectangle($.r,CLEAR)
		$.rdx = $.r["x1"] - $.r["x0"]
		$.rdy = $.r["y1"] - $.r["y0"]
		$.x0 = $.wind.xmin() + 2
		$.y1 = $.wind.ymax() - 2
		}
	tm0 = milliclock()
	toolong = tm0 + $.timeout * 1000
		
	$.phlength = latest(ph)
	i = 0
	nts = split(ph)
	nnts = sizeof(nts)
	for ( n=0; n<nnts; n++ ) {
		if ( dostep )
			nts[n].dur = 1b/4
		nts[n].vol = 'a'.vol
	}
	a = []
	# Collect, for each note, lists of
	# the next 2 notes, 3 notes, 4 notes, etc.
	for ( n=0; n<nnts; n++ ) {
		a[n] = []
		a[n][0] = nts[n]

	 	for ( k=1; k<$.seqB; k++ ) {
			if ( n < (nnts-k+1) ) {
				r = nts[n]
				for ( z=n+1; z <= (n+k-1); z++ )
					r |= nts[z]
				if ( dostep )
					r = step(r)
				else
					r = strip(r)
				a[n][k] = r
				# print("a[",n,"][",k,"] = ",r)
			}
		}
	}
	quit = 0
	for ( n=0; n<(nnts-1) && !quit; n++ ) {
	    for ( m=n+1; m<nnts && !quit ; m++ ) {
		# Only look for note sequences of length seqA to seqB
		maxmatch = -1
	 	for ( k=$.seqA; k<$.seqB && !quit ; k++ ) {
			if ( m >= (nnts-k+1) )
				continue
			if ( !quit && milliclock() > toolong )  {
				print("Too long!")
				quit = 1
			}
			# print("Comparing, n=",n," (",a[n][k],")  ",
			#	" m=",m," (",a[m][k],") k=",k)
			if ( a[n][k] == a[m][k] ) {
				# print("Matched, n=",n," (",a[n][k],")  ",
				#	" m=",m," (",a[m][k],") k=",k)
				maxmatch = k
			} else {
				# As soon as one doesn't match, we know
				# any longer sequences can't match
				continue
			}
		}
		if ( maxmatch >= 0 ) {
			if ( svg ) {
				$.drawsvg(a[n][0].time,a[m][0].time,maxmatch,f)
			} else {
				$.drawgui(a[n][0].time,a[m][0].time,maxmatch)
			}
		}
	    }
	}
	if ( svg ) {
		$.svgend(f)
		close(f)
	}
	print("Matching ended...")
}

method xyat(t,v) {
	x = $.x0 + $.rdx * t / $.phlength
	y = $.y1 - $.rdy * v / 128
	return(xy(x,y))
}

method svgxyat(t,v) {
	x = $.svgdx * t / $.phlength
	y = $.svgdy - 10 - $.svgdy * v / 128
	return(xy(x,y))
}

method drawgui(t1,t2,sz) {
	pos1 = $.xyat(t1,64)
	posm = $.xyat((t1+t2)/2,64 + $.sizeperseq*sz)
	posm2 = $.xyat((t1+t2)/2,64 - $.sizeperseq*sz)
	pos2 = $.xyat(t2,64)
	$.wind.ellipse(xy(pos1["x"],posm["y"],
			pos2["x"],posm2["y"]))
}

method drawsvg(t1,t2,sz,f) {
	# print("t1=",t1," t2=",t2)
	pos1 = $.svgxyat(t1,64)
	posm = $.svgxyat((t1+t2)/2,64 + $.sizeperseq*sz)
	posm2 = $.svgxyat((t1+t2)/2,64 - $.sizeperseq*sz)
	pos2 = $.svgxyat(t2,0)
	diam = pos2["x"] - pos1["x"]
	r = string(diam / 2)
	s = "<path d='M "+string(pos1["x"])+" "+string(pos2["y"])+", A "+r+" "+r+" 0 0 1 "+string(pos2["x"])+" "+string(pos2["y"])+"'\n"
	put(f,s)
	if ( sz == 1 )
		wid = 1
	if ( sz == 2 )
		wid = 3
	if ( sz == 3 )
		wid = 6
	if ( sz == 4 )
		wid = 10
	if ( sz == 5 )
		wid = 15
	if ( sz >= 6 )
		wid = sz * 3

	if ( wid > diam )
		wid = diam
	put(f,"style='fill:none; stroke:red; stroke-width:"+string(wid)+"; stroke-opacity:"+string($.opacity)+"'\n")
	put(f,"/>\n")
}

method svgstart(f) {
	put(f,"<?xml version='1.0' standalone='no'?>\n")
	put(f,"<!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.0//EN'\n")
	put(f,"'http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd'>\n")
	put(f,"<svg width='"+string($.svgdx)+"px' height='"+string($.svgdy)+"px'>\n")
	put(f,"<path d='M 0 0, "+string($.svgdx)+" 0, "+string($.svgdx)+" "+
			string($.svgdy)+", 0 "+string($.svgdy)+", 0 0' \n")
	put(f,"style='fill:none; stroke:red; stroke-width:8; stroke-opacity:0.5'\n")
	put(f,"/>\n")
}
method svgend(f) {
	put(f,"</svg>")
}

}

