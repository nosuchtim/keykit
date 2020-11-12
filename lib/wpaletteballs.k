class wpaletteballs {

method init {

	$.w = new window()
	$.inherit($.w)

	# Figure Remember what ports each channel goes to
	$.defouts = midi("portmap")[0]

	$.lastx = -1
	$.lasty = -1
	$.tid = -1
	$.fmax = 1000000.0
	$.fdfactor = 13333.0	# amount to multiply dx/dy things by
	$.currentregion = "A"
	$.maxballsperregion = 16
	$.editing = 0
	$.shiftdown = 0
	$.breakout = 0
	$.randomadd = 1
	$.mapon = 0

	$.paletteout = 1
	$.midiout = 0
	$.cursornum = 1
	addr = "3333@127.0.0.1"
	$.oscpalette = open(addr,"wb","osc_send")

	$.setbasech(1)

	$.regionchan = ["A"=1,"B"=2,"C"=3,"D"=4]
	$.colorindex = ["A"=8,"B"=9,"C"=10,"D"=11]
	$.orderedregions = [0="A",1="B",2="C",3="D"]
	$.colorbuttpressed = []
	$.colordur = ["A"=1.0,"B"=1.0,"C"=1.0,"D"=1.0]
	$.defaultvol = 90
	$.colorvol = ["A"=$.defaultvol,"B"=$.defaultvol,"C"=$.defaultvol,"D"=$.defaultvol]

	$.offset = 0
	$.debug = 0

	colormix(8,255*255,0,0)
	colormix(9,0,255*255,0)
	colormix(10,0,0,255*255)
	colormix(11,255*255,0,255*255)
	$.wallcolor = 12

	$.grid = $0
	$.more = new kmenubutton("More","mkmenu_paletteballs_1",$)
	$.addchild($.more)

	$.butt_A = new ktoggle("A",$,"onoff_A")
	$.addchild($.butt_A)
	$.butt_B = new ktoggle("B",$,"onoff_B")
	$.addchild($.butt_B)
	$.butt_C = new ktoggle("C",$,"onoff_C")
	$.addchild($.butt_C)
	$.butt_D = new ktoggle("D",$,"onoff_D")
	$.addchild($.butt_D)

	$.b3 = new kvalbutton([0="Normal",1="Control",2="Shift"],
			$,"modchanged",REDRAW);

	$.onoffbutt = new ktoggle("On",$,"onoff")
	$.addchild($.onoffbutt)

	$.clearbutt = new kbutton("Clear",$,"clear")
	$.addchild($.clearbutt)

	$.basevelocity = 0
	$.topvelocity = 127
	$.decaydefault = 0
	$.decaymax = 1000
	$.velocitydefault = 500
	$.energydefault = 500
	$.dsmall = 0.024

	$.slidermax = 1000
	$.decayslider = []
	$.energyslider = []
	for ( cl in $.colorindex ) {
		$.decayslider[cl] = new kslider(0,$.slidermax,
					$.decaydefault,$,"changedecay",cl)
		$.addchild($.decayslider[cl])
		$.energyslider[cl] = new kslider(0,$.slidermax,
					$.energydefault,$,"changeenergy",cl)
		$.addchild($.energyslider[cl])
	}

	$.maxe =       1000000
	$.einit =        60000
	$.einc =         60000
	$.edec =         60000
	$.edecaymax =     4000

	$.maxmove =  300
	$.key = 'c'
	$.scale = "aeolian"
	$.startquant = 1b
	$.playquant = 1b/4
	$.movespeed = 1b/8
	$.colorlimit = []
	$.playlimit = 4
	$.freeze = []
	$.freezep = []

	$.colordecay = []
	$.colorenergy = []
	for ( cl in $.colorindex ) {
		$.colordecay[cl] = $.decaydefault
		$.colorenergy[cl] = $.energydefault
		$.colorlimit[cl] = $.maxballsperregion/2
		$.freeze[cl] = 0
		$.freezep[cl] = ''
	}
	$.tids = []
	$.butt_A.set(1)

	MazeTool = $

	$.setgridsize(16,0)

	if ( defined(JoyBallsNotes) ) {
		nnotes = JoyBallsNotes
	} else {
		nnotes = 1
	}
}

method dump() {
	return( [
		"colorlimit" = $.colorlimit,
		"colordecay" = $.colordecay,
		"colorenergy" = $.colorenergy,
		"sidetop" = $.sidetop,
		"sidebottom" = $.sidebottom,
		"sideleft" = $.sideleft,
		"sideright" = $.sideright,
		"wallbottom" = $.wallbottom,
		"wallright" = $.wallright,
		"basech" = $.basech,
		"mapon" = $.mapon,
		"ball" = $.ball
	] )
}
method restore(st) {
	for ( cl in $.colorindex ) {
		$.decayslider[cl].set(st["colordecay"][cl])
		$.energyslider[cl].set(st["colorenergy"][cl])
	}
	$.mapon = st["mapon"]

	$.setbasech(st["basech"])

	$.colorlimit = arraycopy(st["colorlimit"])
	$.colordecay = arraycopy(st["colordecay"])
	$.colorenergy = arraycopy(st["colorenergy"])

	$.sidetop = arraycopy(st["sidetop"])
	$.sidebottom = arraycopy(st["sidebottom"])
	$.sideleft = arraycopy(st["sideleft"])
	$.sideright = arraycopy(st["sideright"])
	$.wallbottom = arraycopy(st["wallbottom"])
	$.wallright = arraycopy(st["wallright"])
	$.ball = arraycopy(st["ball"])
}

method chanchanged(v) {
	$.setbasech(v+1)
}
method setbasech(v) {
	$.basech = v
	$.regionchan = ["A"=$.basech,"B"=$.basech+1,"C"=$.basech+2,"D"=$.basech+3]
}
method changedecay(v,cl) {
	$.colordecay[cl] = v
}
method changeenergy(v,cl) {
	# change all the existing balls
	lock($)
	$.colorenergy[cl] = v
	for ( cl in $.colorindex ) {
		for ( n=0; n<$.maxballsperregion; n++ ) {
			b = $.ball[cl][n]
			if ( b["on"] == 0 )
				break
			# Reset dfx to original values
			if ( b["dfx"] < 0  )
				b["dfx"] = -1.0
			else
				b["dfx"] = 1.0
			if ( b["dfy"] < 0 )
				b["dfy"] = -1.0
			else
				b["dfy"] = 1.0
		}
	}
	unlock($)
}

method setgridsize(v,doredraw) {
	$.nrows = v
	$.ncols = v
	if ( $.grid != $0 ) {
		$.removechild($.grid)
	}
	deleteobject($.grid)
	$.grid = new wgrid($.ncols,$.nrows)
	$.addchild($.grid)

	$.grid.setcallbackdown($,"gotdown")
	$.grid.setcallbackdrag($,"gotdrag")
	$.initballs()

	if ( doredraw ) {
		$.resize()
		$.redraw()
	}
}

method initballs {
	lock($)
	$.ball = []
	for ( cl in $.colorindex ) {
		$.ball[cl] = []
		for ( n=0; n<$.maxballsperregion; n++ ) {
			$.ball[cl][n] = []
			$.ball[cl][n]["on"] = 0
			$.ball[cl][n]["row"] = -1
			$.ball[cl][n]["col"] = -1
			$.ball[cl][n]["fx"] = -1.0
			$.ball[cl][n]["fy"] = -1.0
			$.ball[cl][n]["dfx"] = 0.0	# from -1 to 1
			$.ball[cl][n]["dfy"] = 0.0	# from -1 to 1
		}
	}
	$.sidetop = []
	$.sidebottom = []
	$.sideleft = []
	$.sideright = []
	$.wallbottom = []
	$.wallright = []

	for ( r=0; r<$.nrows; r++ ) {
		$.sidetop[r] = []
		$.sidebottom[r] = []
		$.sideleft[r] = []
		$.sideright[r] = []
		$.wallbottom[r] = []
		$.wallright[r] = []
		for ( c=0; c<$.ncols; c++ ) {
			$.sidetop[r][c] = []
			$.sidebottom[r][c] = []
			$.sideleft[r][c] = []
			$.sideright[r][c] = []
			$.wallbottom[r][c] = 1
			$.wallright[r][c] = 1
		}
	}
	unlock($)
	$.allwallsup(0)
}
method allwallsup(doredraw) {
	if ( nargs() < 1 )
		doredraw = 1
	lock($)
	for ( r=0; r<$.nrows; r++ ) {
		for ( c=0; c<$.ncols; c++ ) {
			$.wallbottom[r][c] = 1
			$.wallright[r][c] = 1
		}
	}
	unlock($)
	if ( doredraw )
		$.redraw()
}
method allwallsrand(doredraw,f) {
	if ( nargs() < 1 )
		doredraw = 1
	lock($)
	for ( r=0; r<$.nrows; r++ ) {
		for ( c=0; c<$.ncols; c++ ) {
			$.wallbottom[r][c] = ( rand(100) < (f * 100) )
			$.wallright[r][c] = ( rand(100) < (f * 100) )
		}
	}
	unlock($)
	if ( doredraw )
		$.redraw()
}
method erasewalls {
	for ( r=0; r<$.nrows; r++ ) {
		for ( c=0; c<$.ncols; c++ ) {
			if ( $.wallright[r][c] == 0 ) {
				$.grid.drawwallright(r,c,CLEAR)
			}
			if ( $.wallbottom[r][c] == 0 ) {
				$.grid.drawwallbottom(r,c,CLEAR)
			}
		}
	}
}
method ballxy(arr,bx,by) {
	x0 = arr["x0"]
	y0 = arr["y0"]
	x1 = arr["x1"]
	y1 = arr["y1"]
	bx0 = x0 + 1 + (x1-x0-2)*bx/($.fmax/$.ncols)
	by0 = y0 + 1 + (y1-y0-2)*by/($.fmax/$.nrows)
	return( xy(bx0-1,by0-1,bx0+1,by0+1) )
}
method hitleft(r,c,cl) {
	if ( $.breakout && c > 0 ) {
		if ( r < 0 || r >= $.nrows )
			print("Unexpected r in hitleft")
		$.wallright[r][c-1] = 0
		$.grid.drawwallright(r,c-1,CLEAR)
	}
}
method hitright(r,c,cl) {
	if ( $.breakout && c < ($.nrows-1) ) {
		$.wallright[r][c] = 0
		$.grid.drawwallright(r,c,CLEAR)
	}
}
method hittop(r,c,cl) {
	if ( $.breakout && r > 0 ) {
		$.wallbottom[r-1][c] = 0
		$.grid.drawwallbottom(r-1,c,CLEAR)
	}
}
method hitbottom(r,c,cl) {
	if ( $.breakout && r < ($.nrows-1) ) {
		$.wallbottom[r][c] = 0
		$.grid.drawwallbottom(r,c,CLEAR)
	}
}
method moveballs(cl) {
	lock($)
	lim = $.colorlimit[cl]
	$.lastx = -1
	# $.breakout = $.controldown
	for ( n=0; n<lim; n++ ) {
		b = $.ball[cl][n]
		if ( b["on"] == 0 )
			break
		r = b["row"]
		c = b["col"]
		realdfx = b["dfx"] * $.fdfactor * $.colorenergy[cl] / $.energydefault
		nfx = b["fx"] + realdfx
		realdfy = b["dfy"] * $.fdfactor * $.colorenergy[cl] / $.energydefault
		nfy = b["fy"] + realdfy

		if ( $.colordecay[cl] > (0.1*$.decaydefault) ) {
			ddd = 1.0 - 0.05 * float($.colordecay[cl]) / $.decaymax
			b["dfx"] = float(b["dfx"]) * ddd
			b["dfy"] = float(b["dfy"]) * ddd
		}
		# If it goes slow enough, delete it
		velocity = abs(b["dfx"]) + abs(b["dfy"])
		if ( velocity < $.dsmall ) {
			$.deleteball(cl,n)
			n--
			continue
		}

		# scale nfx,y to size of grid on screen
		nxy = $.fxy2xy(nfx,nfy)
		rc = $.grid.rxy2rc(nxy,0)
		newrow = rc["row"] 
		newcol = rc["col"] 
# print("r,c=",r,c,"  newrow,col=",rc)
		bouncetype = ""
		if ( (r != newrow || c != newcol) ) {
			if (r!=newrow && c!=newcol)
				iscorner = 1
			else
				iscorner = 0

			bouncedy = 0
			bouncedx = 0
			redrawbottomr = -2
			redrawbottomc = -2
			redrawrightr = -2
			redrawrightc = -2

			# Special cases for corners
			if ( iscorner ) {
				# print("ISCORNER");
				if ( newrow < r && newcol < c ) {
					# upper-left
					horiz = ($.hastop(r,c) && $.hastop(r,c-1) && !$.hasright(r,c-1))
					vert = ($.hasright(r,c-1) && $.hasright(r-1,c-1) && !$.hastop(r,c))
					corn1 = ($.hastop(r,c) && $.hasright(r,c-1))
					corn2 = ($.hasright(r-1,c-1) && $.hastop(r,c-1))
					if ( horiz ) {
						bouncetype = "top"
					} else if ( vert ) {
						bouncetype = "left"
					} else if ( corn1 || corn2 ) {
						$.hittop(r,c,cl)
						b["dfy"] = -b["dfy"]
						b["dfx"] = -b["dfx"]
						bouncedy = 1
						bouncedx = 1
						redrawbottomr = r-1
						redrawbottomc = c
						redrawrightr = r
						redrawrightc = c-1
					}
				} else if ( newrow > r && newcol < c ) {
					# lower-left
					horiz = ($.hastop(r+1,c) && $.hastop(r+1,c-1) && !$.hasright(r,c-1))
					vert = ($.hasright(r,c-1) && $.hasright(r+1,c-1) && !$.hastop(r+1,c))
					corn1 = ($.hastop(r+1,c) && $.hasright(r,c-1))
					corn2 = ($.hasright(r+1,c-1) && $.hastop(r+1,c-1))
					if ( horiz ) {
						bouncetype = "bottom"
					} else if ( vert ) {
						bouncetype = "left"
					} else if ( corn1 || corn2 ) {
						$.hitbottom(r,c,cl)
						b["dfy"] = -b["dfy"]
						b["dfx"] = -b["dfx"]
						bouncedy = 1
						bouncedx = 1
						redrawbottomr = r
						redrawbottomc = c
						redrawrightr = r
						redrawrightc = c-1
					}
				} else if ( newrow < r && newcol > c ) {
					# upper-right
					horiz = ($.hastop(r,c) && $.hastop(r,c+1) && !$.hasright(r,c))
					vert = ($.hasright(r,c) && $.hasright(r-1,c) && !$.hastop(r,c))
					corn1 = ($.hastop(r,c) && $.hasright(r,c))
					corn2 = ($.hasright(r-1,c) && $.hastop(r,c+1))
					if ( horiz ) {
						bouncetype = "top"
					} else if ( vert ) {
						bouncetype = "right"
					} else if ( corn1 || corn2 ) {
						$.hittop(r,c,cl)
						b["dfy"] = -b["dfy"]
						b["dfx"] = -b["dfx"]
						bouncedy = 1
						bouncedx = 1
						redrawbottomr = r-1
						redrawbottomc = c
						redrawrightr = r
						redrawrightc = c
					}
				} else if ( newrow > r && newcol > c ) {
					# lower-right
					horiz = ($.hastop(r+1,c) && $.hastop(r+1,c+1) && !$.hasright(r,c))
					vert = ($.hasright(r,c) && $.hasright(r+1,c) && !$.hastop(r+1,c))
					corn1 = ($.hastop(r+1,c) && $.hasright(r,c))
					corn2 = ($.hasright(r+1,c) && $.hastop(r+1,c+1))
					if ( horiz ) {
						bouncetype = "bottom"
					} else if ( vert ) {
						bouncetype = "right"
					} else if ( corn1 || corn2 ) {
						$.hittop(r,c,cl)
						b["dfy"] = -b["dfy"]
						b["dfx"] = -b["dfx"]
						bouncedy = 1
						bouncedx = 1
						redrawbottomr = r
						redrawbottomc = c
						redrawrightr = r
						redrawrightc = c
					}
				}
			}

			if ( bouncetype == "" ) {
				# NORMAL bounce, off one side 
				if ( newrow < r ) {
					# potential bounce off top
					if ( $.hastop(r,c) ) {
						bouncetype = "top"
					}
				} else if ( newrow > r ) {
					# potential bounce off bottom
					if ( $.hasbottom(r,c) ) {
						bouncetype = "bottom"
					}
				} else if ( newcol < c ) {
					# potential bounce off left
					if ( $.hasleft(r,c) ) {
						bouncetype = "left"
					}
				} else if ( newcol > c ) {
					# potential bounce off right
					if ( $.hasright(r,c) ) {
						bouncetype = "right"
					}
				}
			}

			if ( bouncetype != "" && $.paletteout ) {
				$.sendtopalette(r,c,bouncetype,cl)
			}

			if ( bouncetype == "top" ) {
				$.hittop(r,c,cl)
				b["dfy"] = -b["dfy"]
				bouncedy = 1
				redrawbottomr = r-1
				redrawbottomc = c
			} else if ( bouncetype == "bottom" ) {
				$.hitbottom(r,c,cl)
				b["dfy"] = -b["dfy"]
				bouncedy = 1
				redrawbottomr = r
				redrawbottomc = c
			} else if ( bouncetype == "left" ) {
				$.hitleft(r,c,cl)
				b["dfx"] = -b["dfx"]
				bouncedx = 1
				redrawrightr = r
				redrawrightc = c-1
			} else if ( bouncetype == "right" ) {
				$.hitright(r,c,cl)
				b["dfx"] = -b["dfx"]
				bouncedx = 1
				redrawrightr = r
				redrawrightc = c
			}


			if ( bouncedx && bouncedy ) {
				if ( bouncedx )
					nfx = b["fx"]
				if ( bouncedy )
					nfy = b["fy"]
			} else {
				if ( bouncedx )
					nfx = b["fx"]
				if ( bouncedy )
					nfy = b["fy"]
			}

			nxy = $.fxy2xy(nfx,nfy)
# print("BOUNCE, b=",b,"  nfxy=",nfx,nfy,"  nxy=",nxy["x"],nxy["y"])
			rc = $.grid.rxy2rc(nxy,0)
			# Sanity check - if we bounce, we should
			# be in the same cell.
			if ( ! bouncedy ) {
				if ( newrow < 0 ) {
					print("!bouncedy, newrow<0")
					newcol = 0
				}
				b["row"] = newrow
			}
			if ( ! bouncedx ) {
				if ( newcol < 0 ) {
					print("!bouncedx, newcol<0=",newcol)
					newcol = 0
				}
				b["col"] = newcol
			}
			if ( redrawrightr != -2 ) {
				task $.redrawright(redrawrightr,
					redrawrightc)
			}
			if ( redrawbottomr != -2 ) {
				task $.redrawbottom(redrawbottomr,
					redrawbottomc)
			}
		}
		$.drawball(b,CLEAR)
		$.updateball(b,nfx,nfy,nxy["x"],nxy["y"])
		colorset($.colorindex[cl])
		$.drawball(b,STORE)
	}
	colorset(1)
	unlock($)
}
method redrawright(r,c) {
	if ( r<0 || r>=$.nrows || c<-1 || c>=$.ncols )
		return()
	sleeptill(Now+1b)
	lock($)
	if ( c<0 || $.wallright[r][c] ) {
		colorset($.wallcolor)
		$.grid.drawwallright(r,c,STORE)
	}
	unlock($)
}
method redrawbottom(r,c) {
	if ( r<-1 || r>=$.nrows || c<0 || c>=$.ncols )
		return()
	sleeptill(Now+1b)
	lock($)
	if ( r<0 || $.wallbottom[r][c] ) {
		colorset($.wallcolor)
		$.grid.drawwallbottom(r,c,STORE)
	}
	unlock($)
}
method hastop(r,c) {
	if ( r<=0 || c<0 || r>=$.nrows || c>=$.ncols )
		return(1)
	if ( $.wallbottom[r-1][c] )
		return(1)
	return(0)
}
method hasbottom(r,c) {
	if ( r<0 || c<0 || c>=($.ncols) || r>=($.nrows-1) )
		return(1)
	if ( $.wallbottom[r][c] )
		return(1)
	return(0)
}
method hasleft(r,c) {
	if ( c<=0 || r<0 || c>=$.ncols || r>=$.nrows )
		return(1)
	if ( $.wallright[r][c-1] )
		return(1)
	return(0)
}
method hasright(r,c) {
	if ( c<0 || r<0 || c>=($.ncols-1) || r>=$.nrows )
		return(1)
	if ( $.wallright[r][c] )
		return(1)
	return(0)
}
method updateball(b,nfx,nfy,nx,ny) {
	b["xy"] = xy(nx-1,ny-1,nx+1,ny+1)
	b["fx"] = nfx
	b["fy"] = nfy
}
method drawball(b,mode) {
	arr = b["xy"]
	$.w.fillrectangle(arr,mode)
	if ( mode == STORE ) {
		if ( $.lastx >= 0 ) {
			a = xy($.lastx,$.lasty,arr["x0"],arr["y0"])
			# $.w.line(a,mode)
		}
		$.lastx = arr["x0"]
		$.lasty = arr["y0"]
	}
}
method drawballs(mode) {
	if ( nargs() < 1 )
		mode = STORE
	
# print("\nDrawballs start")
	for ( cl in $.colorindex ) {
		lim = $.colorlimit[cl]
		$.lastx = -1
		colorset($.colorindex[cl])
		for ( n=0; n<lim; n++ ) {
			b = $.ball[cl][n]
			if (b["on"]==0 )
				break
			$.drawball(b,mode)
		}
	}
	colorset(1)
}
method ison {
	if ( $.tid >= 0 )
		return(1)
	else
		return(0)
}
method clear(v) {
	lock($)
	for ( cl in $.colorindex ) {
		while ( $.ball[cl][0]["on"] ) {
			$.deleteball(cl,0)
		}
	}
	unlock($)
	$.redraw()
}
method maponoff(v) {
	$.mapon = v
}
method onoff_A(v) {
	if ( v ) {
		$.currentregion = "A"
		$.butt_B.set(0) ; $.butt_B.redraw()
		$.butt_C.set(0) ; $.butt_C.redraw()
		$.butt_D.set(0) ; $.butt_D.redraw()
	} else {
		$.butt_A.set(1) ; $.butt_A.redraw()
	}
}
method onoff_B(v) {
	if ( v ) {
		$.currentregion = "B"
		$.butt_A.set(0) ; $.butt_A.redraw()
		$.butt_C.set(0) ; $.butt_C.redraw()
		$.butt_D.set(0) ; $.butt_D.redraw()
	} else {
		$.butt_B.set(1) ; $.butt_B.redraw()
	}
}
method onoff_C(v) {
	if ( v ) {
		$.currentregion = "C"
		$.butt_A.set(0) ; $.butt_A.redraw()
		$.butt_B.set(0) ; $.butt_B.redraw()
		$.butt_D.set(0) ; $.butt_D.redraw()
	} else {
		$.butt_C.set(1) ; $.butt_C.redraw()
	}
}
method onoff_D(v) {
	if ( v ) {
		$.currentregion = "D"
		$.butt_A.set(0) ; $.butt_A.redraw()
		$.butt_B.set(0) ; $.butt_B.redraw()
		$.butt_C.set(0) ; $.butt_C.redraw()
	} else {
		$.butt_D.set(1) ; $.butt_D.redraw()
	}
}
method onoff(v) {
	lock($)
	if ( v ) {
		if ( $.tid >= 0 )
			kill($.tid)
		$.tid = task $.mazetask()
	} else {
		kill($.tid)
		$.tid = -1
	}
	unlock($)
}
method addoneball(v) {
	if ( v == 0 )
		return()

	for ( cl in $.colorbuttpressed ) {
		lim = $.colorlimit[cl]
		found = -1
		for ( n=0; n<lim; n++ ) {
			b = $.ball[cl][n]
			if (b["on"]==0 ) {
				found = n
				break
			}
		}
		if ( found < 0 )
			continue

		if ( $.randomadd || found == 0 ) {

			r = rand($.nrows)
			c = rand($.ncols)
			cellxy = $.grid.getcellxy(r,c)
			arr = ["row"=r,"col"=c,
				"x"=(cellxy["x0"]+cellxy["x1"])/2,
				"y"=(cellxy["y0"]+cellxy["y1"])/2]
			$.gotdown(arr,["button"=1],cl)

		} else if ( found > 0 ) {
			# creating a copy of the last ball
			b = arraycopy($.ball[cl][found-1])
			b["dfy"] = -b["dfy"]
			$.ball[cl][found] = b
		}
	}
}
method deleteoneball(v) {
	if ( v == 0 )
		return()
	lock($)
	for ( cl in $.colorbuttpressed ) {
		# delete 0th one if it's on
		b = $.ball[cl][0]
		if (b["on"]!=0 ) {
			$.deleteball(cl,0)
		}
	}
	unlock($)
}
method editonoff(v) {
	$.editing = v
}
method dobreakout(v) {
	$.breakout = v
}

method sendtopalette(r,c,bouncetype,cl) {
	y = r / float($.nrows-1)
	x = c / float($.ncols-1)
	z = 0.5
	sendtype = "cursor"
	region = cl
	if ( sendtype == "sprite" ) {
		cid = sprintf("%s_%s_%d",bouncetype,cl,$.cursornum++)
		msg = [0="/spriteevent",1=sprintf("{ \"event\": \"sprite\", \"cid\": \"%s\", \"region\": \"%s\", \"x\": %f, \"y\": %f, \"z\": %f }",cid,region,x,y,z)]
		mdep("osc","send",$.oscpalette,msg)
	} else {
		cid = sprintf("%s_%s_%d",bouncetype,cl,$.cursornum++)
		msgdown = [0="/cursorevent",1=sprintf("{ \"event\": \"down\", \"cid\": \"%s\", \"region\": \"%s\", \"x\": %f, \"y\": %f, \"z\": %f }",cid,region,x,y,z)]
		msgup = [0="/cursorevent",1=sprintf("{ \"event\": \"up\", \"cid\": \"%s\", \"region\": \"%s\", \"x\": %f, \"y\": %f, \"z\": 0.0 }",cid,region,x,y)]
		task $.sendcursor(msgdown,msgup)
	}
}
method sendcursor(msgdown,msgup) {
	mdep("osc","send",$.oscpalette,msgdown)
	sleeptill(Now+1b/4)
	mdep("osc","send",$.oscpalette,msgup)
}
method domidi(v) {
	$.midiout = v
}
method mazetask {
	# print("mazetask start")
	tm = Now
	tm = nextquant(tm,$.startquant)
	while ( 1 ) {
		sleeptill(tm-2)
		$.moveballs("A")
		$.moveballs("B")
		$.moveballs("C")
		$.moveballs("D")
		tm += $.movespeed
	}
}
method delete {
	kill($.tid)
	MazeTool = $0
}
method resize (sz) {
			if ( nargs() > 0 )
				$.w.resize(sz)
			$.dy = $.textheight() + 5
			tw = $.textwidth()

			ym2 = $.ymin() + 2

			$.dx = $.textwidth()*2
			$.x0a = $.xmin() + 2 + 5*$.dx
			cln = 0

			y0 = $.ymin()+$.dy
			ddy = ($.ymax()-2-y0)/2
			y0a = y0+ddy
			y0c = $.ymax()-2
			y0mid = y0a

			x0 = $.xmin()+2
			for ( n=0; n<sizeof($.orderedregions); n++ ) {
				cl = $.orderedregions[n]
				x0a = x0 + $.dx

				x1 = $.xmin()+(cln+1)*$.dx-1
				$.decayslider[cl].resize(
					xy(x0,y0,x0a,y0mid-3))
				$.energyslider[cl].resize(
					xy(x0,y0mid+3,x0a,y0c))
				cln++
				x0 = x0a
			}

			$.butt_A.resize(xy($.xmin()+2,ym2,
				$.xmin()+$.dx-1,$.ymin()+$.dy-2))
			$.butt_B.resize(xy($.xmin()+$.dx+1,ym2,
				$.xmin()+2*$.dx-1,$.ymin()+$.dy-2))
			$.butt_C.resize(xy($.xmin()+2*$.dx+1,ym2,
				$.xmin()+3*$.dx-1,$.ymin()+$.dy-2))
			$.butt_D.resize(xy($.xmin()+3*$.dx+1,ym2,
				$.xmin()+4*$.dx-1,$.ymin()+$.dy-2))

			$.gridsize = xy($.x0a+2,$.ymin()+$.dy,
					$.xmax()-3,$.ymax()-2)
			$.grid.resize($.gridsize)
			$.griddx = $.gridsize["x1"] - $.gridsize["x0"]
			$.griddy = $.gridsize["y1"] - $.gridsize["y0"]

			$.xm = $.xmin() + ($.xmax()-$.xmin())/2
			# if ( $.xm < ($.xmax()-28*tw) )
			# 	$.xm = ($.xmax()-28*tw)

			$.xmdx = ($.xmax() - $.xm)/5


			$.onoffbutt.resize(xy($.xm+2*$.xmdx+1,ym2,
				$.xm+3*$.xmdx-1,$.ymin()+$.dy-2))
			$.clearbutt.resize(xy($.xm+3*$.xmdx+1,ym2,
				$.xm+4*$.xmdx-1,$.ymin()+$.dy-2))
			$.more.resize(xy($.xm+4*$.xmdx+1,ym2,
				$.xmax()-2,$.ymin()+$.dy-2))
		}
method redraw {
		lock($)
		$.w.redraw()
		colorset($.wallcolor)
		$.w.textcenter("PaletteBalls",xy($.xmin(),$.ymin(),
				$.xmax(),$.ymin()+$.dy))
		x0c = $.xmin() + 2 + 4*$.dx
		x0d = $.xmin() + 2 + 5*$.dx
		y0 = $.ymin()+$.dy
		ddy = ($.ymax()-2-y0)/2
		y0a = y0+ddy
		y0c = $.ymax()-2
		y0mid = (y0a+y0c)/2
		th = $.textheight()

		# vertical text
		s = "DECAY"
		yoff = -5
		for ( n=0 ; n<sizeof(s); n++ ) {
			$.w.textcenter(substr(s,n+1,1),xy(x0c,y0+(yoff+n)*th,x0d,y0mid-1+(yoff+n+1)*th))
		}
		s = "ENERGY"
		yoff = -5
		for ( n=0 ; n<sizeof(s); n++ ) {
			$.w.textcenter(substr(s,n+1,1),xy(x0c,y0mid+(yoff+n)*th,x0d,y0c-1+(yoff+n+1)*th))
		}

		methodbroadcast()
		$.w.rectangle($.gridsize)
		$.erasewalls()
		$.drawballs()
		unlock($)
		}
method notify(r,c,cl) {
	cellxy = $.grid.getcellxy(r,c)
	arr = ["row"=r,"col"=c,
		"x"=(cellxy["x0"]+cellxy["x1"])/2,
		"y"=(cellxy["y0"]+cellxy["y1"])/2]
	$.gotdown(arr,["button"=1],cl)
}
method fxy2xy(fx,fy) {
	return(xy(integer($.gridsize["x0"] + $.griddx * fx / $.fmax),
		integer($.gridsize["y0"] + $.griddy * fy / $.fmax)))
}
method gotdrag (m,ms,cl) {
	if ( nargs() < 3 ) {
		cl = $.currentregion
	}
	# Drag events don't include the modifier, bummer
	ms["modifier"] = $.shiftdown * 2 + $.controldown
	$.realgotdown(1,m,ms,cl)
}
method gotdown (m,ms,cl) {
	if ( nargs() < 3 ) {
		cl = $.currentregion
	}
	$.realgotdown(0,m,ms,cl)
}
method realgotdown(dragged,m,ms,cl) {

# print("realgotdown(dragged=",dragged," m=",m," ms=",ms," cl=",cl)
	r = m["row"]
	c = m["col"]
	if ( r >= $.nrows )
		return()
	if ( c >= $.ncols )
		return()

	lock($)

	if ( ms["modifier"] == "" ) {
		$.shiftdown = 0
		$.controldown = 0
	} else {
		$.shiftdown = (( ms["modifier"] & 2 ) != 0 )
		$.controldown = (( ms["modifier"] & 1 ) != 0 )
	}

	# When the control key is down, we're deleting/adding walls
	if ( $.controldown ) {
		# If the shift key is down, we're adding walls
		addit = ((ms["modifier"] & 2) != 0)
		if ( ms["button"] == 2 && c < ($.ncols-1) ) {
			# do the right wall
			$.wallright[r][c] = addit
			if ( $.wallright[r][c] == 0 ) {
				$.grid.drawwallright(r,c,CLEAR)
			} else {
				colorset($.wallcolor)
				$.grid.drawwallright(r,c,STORE)
			}
		} else if ( ms["button"] == 1 && r < ($.nrows-1) ) {
			# toggle the bottom wall
			$.wallbottom[r][c] = addit
			if ( $.wallbottom[r][c] == 0 ) {
				$.grid.drawwallbottom(r,c,CLEAR)
			} else {
				colorset($.wallcolor)
				$.grid.drawwallbottom(r,c,STORE)
			}
		}
		unlock($)
		return()
	}
	if ( dragged ) {
		unlock($)
		return()
	}

	if ( $.shiftdown ) {

# XXX - This isn't really used anymore, I think.

		# find any balls already in that cell, and delete 1
		found = -1
		laston = -1
		for ( cl in $.colorindex ) {
			lim = $.colorlimit[cl]
			for ( n=0; n<lim; n++ ) {
				b = $.ball[cl][n]
				if (b["on"]==0)
					break
				laston = n
				if ( b["row"]==r && b["col"]==c ) {
					found = n
					foundcl = cl
				}
			}
		}
		if ( found>=0 ) {
			b = $.ball[foundcl][found]
			$.drawball(b,CLEAR)
			b["on"] = 0
			# swap it with last "on" one
			if ( laston != found ) {
				tb = $.ball[foundcl][found]
				$.ball[foundcl][found] = $.ball[foundcl][laston]
				$.ball[foundcl][laston] = tb
			}
		}
		unlock($)
		return()
	}

	initfx = (m["x"] - $.gridsize["x0"]) * $.fmax / $.griddx
	initfy = (m["y"] - $.gridsize["y0"]) * $.fmax / $.griddy

	$.addball($.currentregion,r,c,initfx,initfy)
	unlock($)
}

method addball(cl,r,c,initfx,initfy) {
	# print("addball cl=",cl)
	if ( cl != "A" && cl != "B" && cl != "C" && cl != "D" ) {
		print("Hey, addball can't handle cl=",cl)
		return()
	}
	# find any balls already in that cell
	found = -1
	freeslot = -1
	laston = -1
	for ( n=0; n<$.colorlimit[cl]; n++ ) {
		b = $.ball[cl][n]
		if (b["on"]==0) {
			freeslot = n
			break
		}
		laston = n
		if ( b["row"]==r && b["col"]==c )
			found = n
	}
	if ( freeslot < 0 ) {
		# Erase 0th one and shift others down
		$.drawball($.ball[cl][0],CLEAR)

		lim = $.colorlimit[cl]
		for ( n=1; n<lim; n++ )
			$.ball[cl][n-1] = $.ball[cl][n]
		freeslot = lim-1
	}
	n = freeslot
	$.ball[cl][n] = []
	b = $.ball[cl][n]
	b["on"] = 1
	b["row"] = r
	b["col"] = c

	bxy = $.fxy2xy(initfx,initfy)
	$.updateball(b,initfx,initfy,bxy["x"],bxy["y"])

	b["dfx"] = 1.0
	b["dfy"] = 1.0
# print("NEW ball b=",b," in slot n=",n)
	colorset($.colorindex[cl])
	$.drawball(b,STORE)
	colorset(1)
}

method deleteball(cl,dn) {
	laston = -1
	lim = $.colorlimit[cl]
	for ( n=0; n<lim; n++ ) {
		b = $.ball[cl][n]
		if (b["on"]==0)
			break
		laston = n
	}
	if ( laston>=0 ) {
		b = $.ball[cl][dn]
		$.drawball(b,CLEAR)
		b["on"] = 0
		# swap it with last "on" one
		if ( laston != dn ) {
			tb = $.ball[cl][dn]
			$.ball[cl][dn] = $.ball[cl][laston]
			$.ball[cl][laston] = tb
		}
	}
}

method setplayquant(v) {
	$.playquant = v
}

method setmovinglimit(v) {
	if ( v > $.maxballsperregion ) {
		print("You can't have that many, the limit is ",$.maxballsperregion)
		return()
	}
	lock($)
	for ( cl in $.colorindex ) {
		oldlim = $.colorlimit[cl]
		n = v
		while ( (n in $.ball[cl]) && $.ball[cl][n]["on"] ) {
			$.deleteball(cl,n)
		}
		$.colorlimit[cl] = v
	}
	unlock($)
}

method setmovespeed(n) {
	$.onoff(0)
	$.movespeed = n
	print("Setting movespeed to ",$.movespeed)
	$.onoff(1)
}

method debugprint {
	$.debug = 1 - $.debug
	for ( cl in $.colorindex ) {
		print("cl=",cl)
		for ( n=0; n<$.maxballsperregion; n++ ) {
			b = $.ball[cl][n]
			if (b["on"]==0)
				break
			print("b=",b)
		}
	}
}
}

function mkmenu_paletteballs_1(o,po) {
	o.submenu("Grid Size   ->","mkmenu_paletteballs_gridsize",po)
	o.submenu("Rand Walls  ->","mkmenu_paletteballs_randwalls",po)
	o.submenu("Speed       ->","mkmenu_paletteballs_speed",po)
	o.submenu("Max Balls   ->","mkmenu_paletteballs_moving",po)
	o.submenu("Breakout    ->","mkmenu_paletteballs_breakout",po)
	o.menucmd("All Walls Up",po,"allwallsup",1)
	# o.menucmd("Debug Print",po,"debugprint")
}
function mkmenu_paletteballs_breakout(o,po) {
	o.menucmd("on",po,"dobreakout",1)
	o.menucmd("off",po,"dobreakout",0)
}
function mkmenu_paletteballs_midi(o,po) {
	o.menucmd("on",po,"domidi",1)
	o.menucmd("off",po,"domidi",0)
}
function mkmenu_paletteballs_randwalls(o,po) {
	o.menucmd("10%",po,"allwallsrand",1,0.1)
	o.menucmd("20%",po,"allwallsrand",1,0.2)
	o.menucmd("50%",po,"allwallsrand",1,0.5)
	o.menucmd("100%",po,"allwallsrand",1,1.0)
}
function mkmenu_paletteballs_gridsize(o,po) {
	# o.menucmd("4",po,"setgridsize",4,1)
	o.menucmd("8",po,"setgridsize",8,1)
	o.menucmd("16",po,"setgridsize",16,1)
	o.menucmd("32",po,"setgridsize",32,1)
	# o.menucmd("64",po,"setgridsize",64,1)
}
function mkmenu_paletteballs_moving(o,po) {
	o.menucmd("1",po,"setmovinglimit",1)
	o.menucmd("2",po,"setmovinglimit",2)
	o.menucmd("4",po,"setmovinglimit",4)
	o.menucmd("8",po,"setmovinglimit",8)
	o.menucmd("12",po,"setmovinglimit",12)
	o.menucmd("16",po,"setmovinglimit",16)
}
function mkmenu_paletteballs_speed(o,po) {
	o.menucmd("Slowest",po,"setmovespeed",1b)
	o.menucmd("Slower",po,"setmovespeed",1b/2)
	o.menucmd("Slow",po,"setmovespeed",1b/4)
	o.menucmd("Normal",po,"setmovespeed",1b/8)
	o.menucmd("Fast",po,"setmovespeed",1b/16)
	o.menucmd("Faster",po,"setmovespeed",1b/32)
	o.menucmd("Fastest",po,"setmovespeed",2)
}
function mkmenu_paletteballs_playquant(o,po) {
	o.menucmd("2b",po,"setplayquant",2b)
	o.menucmd("1b",po,"setplayquant",1b)
	o.menucmd("1b/2",po,"setplayquant",1b/2)
	o.menucmd("1b/4",po,"setplayquant",1b/4)
	o.menucmd("1b/8",po,"setplayquant",1b/8)
	o.menucmd("1b/16",po,"setplayquant",1b/16)
	o.menucmd("1b/32",po,"setplayquant",1b/32)
}
