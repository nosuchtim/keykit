class wimage {

method init {
	$.w = new window()
	$.inherit($.w)

	$.isdown = 0
	$.image = -1
	$.iysize = 0
	$.ixsize = 0
	$.reset()
	$.notify = 0
	$.fname = ""
	$.bltin = 1
	$.usesaved = 0
}
method setnotify(o) {
	$.notify = o
}
method reset {
	$.mx0 = -1
	$.my0 = -1
	$.mx1 = -1
	$.my1 = -1
}
method dump {
	return( ["fname" = pathescape($.fname)] )
}
method restore(st) {
	$.fname = st["fname"]
	if ( $.fname != "" )
		$.readfile($.fname)
}
method readfile(fname) {
	$.fname = fname
	$.usesaved = 0
	if ( $.bltin )  {
		$.image = bitmap("read",fname)
		sz = bitmap("size",$.image)
		$.ixsize = sz["x"]
		$.iysize = sz["y"]
	} else  {
		$.image = readppm(fname)
		$.ixsize = $.image["xsize"]
		$.iysize = $.image["ysize"]
	}
}
method drawline(x0,y0,x1,y1) {
	if ( $.image == 0 )
		return()
	if ( nargs() == 1 ) {
		arr = x0
		x0 = arr["x0"]
		y0 = arr["y0"]
		x1 = arr["x1"]
		y1 = arr["y1"]
	}
	# The passed-in arguments are in the coordinate
	# space of the image, not the screen
	rx0 = $.x0 + (x0+0.5) * $.dx / $.ixsize
	ry0 = $.y0 + (y0+0.5) * $.dy / $.iysize
	rx1 = $.x0 + (x1+0.5) * $.dx / $.ixsize
	ry1 = $.y0 + (y1+0.5) * $.dy / $.iysize
	colorset(1)
	$.w.line(xy(rx0,ry0,rx1,ry1),XOR)
}
method drawpoint(x0,y0) {
	if ( $.image < 0 )
		return()
	if ( nargs() == 1 ) {
		arr = x0
		x0 = arr["x"]
		y0 = arr["y"]
	}
	# The passed-in arguments are in the coordinate
	# space of the image, not the screen
	rx0 = $.x0 + (x0) * $.dx / $.ixsize
	ry0 = $.y0 + (y0) * $.dy / $.iysize
	rx1 = $.x0 + (x0+1) * $.dx / $.ixsize
	ry1 = $.y0 + (y0+1) * $.dy / $.iysize
	colorset(1)
	arr = xy( rx0,ry0, rx1,ry1)
	$.w.fillrectangle(arr,XOR)
}
method imagesize {
	return(xy($.ixsize,$.iysize))
}
method drawimage(mode) {
	if ( $.image < 0 )
		return()
	if ( nargs() < 1 )
		mode = STORE
	lock($)
	if ( $.bltin ) {
		for ( x=0; x<$.ixsize; x++ ) {
			rx0 = $.x0 + x * $.dx / $.ixsize
			rx1 = $.x0 + (x+1) * $.dx / $.ixsize
			for ( y=0; y<$.iysize; y++ ) {
				v = bitmap("get",$.image,x,y)
				rv = (v>>16) & 0xff
				gv = (v>>8) & 0xff
				bv = v & 0xff
				# Why do I have to use two colors? Weird.
				rc = 8 + (y%2)
				colormix(rc,rv*256,gv*256,bv*256)
				colorset(rc)

				ry0 = $.y0 + y * $.dy / $.iysize
				ry1 = $.y0 + (y+1) * $.dy / $.iysize
				arr = xy(rx0,ry0,rx1,ry1)
				$.w.fillrectangle(arr,mode)
			}
		}
	} else {
		rimage = $.image["r"]
		gimage = $.image["g"]
		bimage = $.image["b"]
		for ( x=0; x<$.ixsize; x++ ) {
			rx0 = $.x0 + x * $.dx / $.ixsize
			rx1 = $.x0 + (x+1) * $.dx / $.ixsize
			rimagex = rimage[x]
			gimagex = gimage[x]
			bimagex = bimage[x]
			for ( y=0; y<$.iysize; y++ ) {
				rv = rimagex[y]
				gv = gimagex[y]
				bv = bimagex[y]
				rc = 8 + rand(5)
				colormix(rc,rv*256,gv*256,bv*256)
				colorset(rc)

				ry0 = $.y0 + y * $.dy / $.iysize
				ry1 = $.y0 + (y+1) * $.dy / $.iysize
				arr = xy(rx0,ry0,rx1,ry1)
				$.w.fillrectangle(arr,mode)
			}
		}
	}
	unlock($)
	colorset(1)
}
method resize (sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	sz = $.w.size()
	$.x0 = sz["x0"]+1
	$.y0 = sz["y0"]+1
	$.x1 = sz["x1"]-1
	$.y1 = sz["y1"]-1
	$.dx = $.x1-$.x0
	$.dy = $.y1-$.y0
	$.usesaved = 0
}
method redraw {
	if ( $.usesaved == 0 ) {
		$.w.redraw()
		$.drawimage()
		$.saveunder()
		$.usesaved = 1
	} else {
		$.restoreunder(1)	# 1 means don't discard after restoring
	}

}
method mousedown (m,ms) {
	lock($)
	if ( $.mx0 >= 0 && $.mx1 >= 0 ) {
		$.w.line(xy($.mx0,$.my0,$.mx1,$.my1),XOR)
		$.reset()
	}
	$.mx0 = m["x"]
	$.my0 = m["y"]
	unlock($)
}
method redat(x,y) {
	if ( x >= $.ixsize ) {
		error("HEY, REDAT catches x >= $.ixsize")
	}
	if ( y >= $.iysize ) {
		error("HEY, REDAT catches y >= $.iysize")
	}
	if ( $.bltin ) {
		v = bitmap("get",$.image,x,y)
		rv = (v>>16) & 0xff
		# gv = (v>>8) & 0xff
		# bv = v & 0xff
		return( rv )
	} else {
		return( $.image["r"][x][y] )
	}
}
method greenat(x,y) {
	if ( $.bltin ) {
		v = bitmap("get",$.image,x,y)
		# rv = (v>>16) & 0xff
		gv = (v>>8) & 0xff
		# bv = v & 0xff
		return( gv )
	} else {
		return( $.image["g"][x][y] )
	}
}
method blueat(x,y) {
	if ( $.bltin ) {
		v = bitmap("get",$.image,x,y)
		# rv = (v>>16) & 0xff
		# gv = (v>>8) & 0xff
		bv = v & 0xff
		return( bv )
	} else {
		return( $.image["b"][x][y] )
	}
}
method mouseup (m,ms) {
	lock($)
	if ( $.mx0 >= 0 && $.mx1 >= 0 ) {
		# final erase
		arr = xy($.mx0,$.my0,$.mx1,$.my1)
		$.w.line(arr,XOR)
		if ( $.notify != 0 && $.fname != "" ) {
			x0 = $.xmin()+1
			y0 = $.ymin()+1
			$.mx0 -= x0
			$.my0 -= y0
			$.mx1 -= x0
			$.my1 -= y0
			wid = $.xmax() - $.xmin()
			hgt = $.ymax() - $.ymin()
			sc_x0 = $.mx0 * $.ixsize / wid
			sc_y0 = $.my0 * $.iysize / hgt
			sc_x1 = $.mx1 * $.ixsize / wid
			sc_y1 = $.my1 * $.iysize / hgt
			imgline = xy( sc_x0, sc_y0, sc_x1, sc_y1)
			$.notify.gotline(imgline)
		}
	}
	$.reset()
	unlock($)
}
method mousedrag (m,ms) {
	lock($)
	if ( $.mx0 >= 0 ) {
		if ( $.mx1 >= 0 )
			$.w.line(xy($.mx0,$.my0,$.mx1,$.my1),XOR)
		$.mx1 = m["x"]
		$.my1 = m["y"]
		$.w.line(xy($.mx0,$.my0,$.mx1,$.my1),XOR)
	} else {
		$.mx0 = m["x"]
		$.my0 = m["y"]
	}
	unlock($)
}

}
