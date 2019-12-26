class wburnbox {
	method init {
		$.w = new window()
		$.inherit($.w)
		$.tid = task $.task_draw()
		$.w.style(NOBORDER)
	}
	method delete {
		kill($.tid)
	}
	method redraw {
		$.w.redraw()
	}
	method offset(arr,dx,dy) {
		return(xy(
			arr["x0"]+dx,
			arr["y0"]+dy,
			arr["x1"]+dx,
			arr["y1"]+dy
			))
	}
	method bar(arr,mode) {
		$.line(arr,mode);
		$.line($.offset(arr,-1,0),mode);
		$.line($.offset(arr,1,0),mode);
		$.line($.offset(arr,0,-1),mode);
		$.line($.offset(arr,0,1),mode);
	}
	method task_draw {
		while ( 1 ) {
			millisleep(200)
			x0 = $.xmin()
			x1 = $.xmax() 
			y0 = $.ymin()
			y1 = $.ymax() 

			tw = $.textwidth()
			th = $.textheight()
			d = (x1-x0)/2
			ln = []

			ln[0] = xy(x0+tw,y0+2*th,x0+tw+d,y0+2*th) # top
			ln[1] = xy(x0+tw,y0+2*th+d,x0+tw+d,y0+2*th+d) # bottom
			ln[2] = xy(x0+tw,y0+2*th,x0+tw,y0+2*th+d) # left
			ln[3] = xy(x0+tw+d,y0+2*th,x0+tw+d,y0+2*th+d) # right

			f = d/4
			ln[4] = $.offset(ln[0],f,-f/2)
			ln[5] = $.offset(ln[1],f,-f/2)
			ln[6] = $.offset(ln[2],f,-f/2)
			ln[7] = $.offset(ln[3],f,-f/2)

			ln[8] = xy(
				ln[0]["x0"], ln[0]["y0"],
				ln[4]["x0"], ln[4]["y0"])
			ln[9] = xy(
				ln[0]["x1"], ln[0]["y1"],
				ln[4]["x1"], ln[4]["y1"])
			ln[10] = xy(
				ln[1]["x0"], ln[1]["y0"],
				ln[5]["x0"], ln[5]["y0"])
			ln[11] = xy(
				ln[1]["x1"], ln[1]["y1"],
				ln[5]["x1"], ln[5]["y1"])


			choice = rand(sizeof(ln))
			for ( n=0; n<sizeof(ln); n++ ) {

				if ( n == choice ) {
					rc = 2+rand(10)
					colormix(rc,rand(255)*256,rand(255)*256,rand(255)+256)
					colorset(rc)
					$.bar(ln[n],STORE);
				} else {
					rc = 2+rand(10)
					g = 230 * 256
					colormix(rc,g,g,g)
					colorset(rc)
					$.bar(ln[n],STORE);
				}

			}

			colorset(1)
		}
	}
}
