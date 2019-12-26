function layout_vertical(xyarr,...) {
	nvert = nargs()-1
	dy = (xyarr["y1"] - xyarr["y0"]) / nvert - 2
	dya = (xyarr["y1"] - xyarr["y0"])
	x0 = xyarr["x0"]
	y0 = xyarr["y0"]
	x1 = xyarr["x1"]
	y1 = xyarr["y1"]
	for ( n=1; n<=nvert; n++ ) {
		o = argv(n)
		yv1 = y0+(n-1)*dya/nvert
		yv2 = y1-(nvert-n)*dya/nvert
		if ( n == 1 ) {
			yv2 -= 2
		} else if ( n == nvert ) {
			yv1 += 2
		} else {
			yv1++
			yv2--
		}
		o.resize(xy(x0,yv1,x1,yv2))
	}
}
function layout_horizontal(xyarr,...) {
	nhoriz = nargs()-1
	dx = (xyarr["x1"] - xyarr["x0"]) / nhoriz - 2
	dxa = (xyarr["x1"] - xyarr["x0"])
	x0 = xyarr["x0"]
	y0 = xyarr["y0"]
	x1 = xyarr["x1"]
	y1 = xyarr["y1"]
	for ( n=1; n<=nhoriz; n++ ) {
		o = argv(n)
		xv1 = x0+(n-1)*dxa/nhoriz
		xv2 = x1-(nhoriz-n)*dxa/nhoriz
		if ( n == 1 ) {
			xv2 -= 2
		} else if ( n == nhoriz ) {
			xv1 += 2
		} else {
			xv1++
			xv2--
		}
		o.resize(xy(xv1,y0,xv2,y1))
	}
}
