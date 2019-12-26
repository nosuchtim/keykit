# waid - one-click text/voice selection for handicapped people

class waid {

method init {

	# TIMING OF SAY AND MOVING, IN MILLISECONDS
	$.saydelay = 1000
	$.movedelay = 3000

	$.w = new window()
	$.inherit($.w)

	$.butt1 = new ktext("hello")
	$.addchild($.butt1)

	$.ncols = 3

	# $.tree = aid_read("aid.txt")
	$.tree = [
		0 = [	"text"="",
			"op" = 0
			],
		1 = [	"text"="SAY AGAIN",
			"op" = 1
			],
		3 = [	"text"="",
			"op" = 0
			],
		4 = [	"text"="I FEEL",
			"sub"=[
				0=["text"="", "op"=0],
				1=["text"="i feel HAPPY"],
				2=["text"="i feel UNCOMFORTABLE"],
				3=["text"="i feel SICK"],
				4=["text"="i feel PAIN"],
				5=["text"="i feel HEADACHE"],
				6=["text"="i feel HUNGRY"],
				7=["text"="i feel UPSET STOMACH"],
				8=["text"="i feel TIRED"],
				9=["text"="i feel WEAK"],
				10=["text"="i feel ANGRY"],
				11=["text"="", "op"=0],
				12=["text"="BACK", "op"=3,"delay"=2]
				]
			],
		5 = [	"text"="I WANT",
			"sub"=[
				0=["text"="", "op"=0],
				1=["text"="TURN ON TV"],
				2=["text"="TURN OFF TV"],
				3=["text"="READ TO ME"],
				4=["text"="READ NEWS"],
				5=["text"="TURN ON MUSIC"],
				6=["text"="TURN OFF MUSIC"],
				7=["text"="GO TO BATHROOM"],
				8=["text"="GO TO BED"],
				9=["text"="GO FOR A WALK"],
				10=["text"="GO FOR A RIDE"],
				11=["text"="GO OUTSIDE"],
				12=["text"="", "op"=0],
				13=["text"="BACK", "op"=3,"delay"=2]
				]
			],
		6 = [	"text"="TALK ABOUT",
			"sub"=[
				0=["text"="", "op"=0],
				1=["text"="FAMILY",
				"sub"=[
					0=["text"="", "op"=0],
					1=["text"="DAD"],
					2=["text"="KAREN"],
					3=["text"="JOANNA"],
					4=["text"="CATHY"],
					5=["text"="VERA"],
					6=["text"="EARL"],
					8=["text"="", "op"=0],
					9=["text"="BACK", "op"=3,"delay"=2]
					]
				],
				2=["text"="FRIENDS",
				"sub"=[
					0=["text"="", "op"=0],
					1=["text"="EVE"],
					2=["text"="CAROLYN"],
					3=["text"="SONNI"],
					4=["text"="CORA"],
					5=["text"="JOAN"],
					6=["text"="DARA"],
					8=["text"="", "op"=0],
					9=["text"="BACK", "op"=3,"delay"=2]
					]
				],
				3=["text"="BIBLE"],
				5=["text"="PLANTS"],
				6=["text"="FOOD"],
				7=["text"="LINE DANCING"],
				8=["text"="TRAVEL"],
				9=["text"="", "op"=0],
				10=["text"="BACK", "op"=3,"delay"=2]
				]
			],
		7 = [	"text"="QUESTION",
			"sub"=[
				0=["text"="", "op"=0],
				1=["text"="ARE",
				"sub"=[
					0=["text"="", "op"=0],
					1=["text"="are YOU"],
					2=["text"="are WE"],
					3=["text"="are THEY"],
					8=["text"="", "op"=0],
					9=["text"="BACK", "op"=3,"delay"=2]
					]
				],
				2=["text"="WHERE",
				"sub"=[
					0=["text"="", "op"=0],
					1=["text"="where ARE"],
					3=["text"="where WILL"],
					4=["text"="where DOES"],
					5=["text"="where AM"],
					8=["text"="", "op"=0],
					9=["text"="BACK", "op"=3,"delay"=2]
					]
				],
				3=["text"="WHEN",
				"sub"=[
					0=["text"="", "op"=0],
					1=["text"="when ARE"],
					2=["text"="when WE"],
					3=["text"="when WILL"],
					4=["text"="when DOES"],
					5=["text"="when AM"],
					8=["text"="", "op"=0],
					9=["text"="BACK", "op"=3,"delay"=2]
					]
				],
				4=["text"="WHY",
				"sub"=[
					0=["text"="", "op"=0],
					1=["text"="why ARE"],
					2=["text"="why WE"],
					3=["text"="why WILL"],
					4=["text"="why DOES"],
					5=["text"="why AM"],
					8=["text"="", "op"=0],
					9=["text"="BACK", "op"=3,"delay"=2]
					]
				],
				5=["text"="HOW",
				"sub"=[
					0=["text"="", "op"=0],
					1=["text"="how ARE"],
					2=["text"="how WE"],
					3=["text"="how WILL"],
					4=["text"="how DOES"],
					5=["text"="how AM"],
					8=["text"="", "op"=0],
					9=["text"="BACK", "op"=3,"delay"=2]
					]
				],
				6=["text"="WHO",
				"sub"=[
					0=["text"="", "op"=0],
					1=["text"="who ARE"],
					2=["text"="who WE"],
					3=["text"="who WILL"],
					4=["text"="who DOES"],
					5=["text"="who AM"],
					8=["text"="", "op"=0],
					9=["text"="BACK", "op"=3,"delay"=2]
					]
				],
				7=["text"="AM I",
				"sub"=[
					0=["text"="", "op"=0],
					1=["text"="am i SICK"],
					2=["text"="am i GOING"],
					8=["text"="", "op"=0],
					9=["text"="BACK", "op"=3,"delay"=2]
					]
				],
				8=["text"="", "op"=0],
				9=["text"="BACK", "op"=3,"delay"=2]
				]
			],
		8 = [	"text"="LETTERS A-M",
			"sub"=[
				0=["text"="", "op"=0],
				1=["text"="A"],
				2=["text"="B"],
				3=["text"="C"],
				4=["text"="D"],
				5=["text"="E"],
				6=["text"="F"],
				7=["text"="G"],
				8=["text"="H"],
				9=["text"="I"],
				10=["text"="J"],
				11=["text"="K"],
				12=["text"="L"],
				13=["text"="M"],
				14=["text"="BACK", "op"=3,"delay"=2]
				]
			],
		9 = [	"text"="LETTERS N-Z",
			"sub"=[
				0=["text"="", "op"=0],
				1=["text"="N"],
				2=["text"="O"],
				3=["text"="P"],
				4=["text"="Q"],
				5=["text"="R"],
				6=["text"="S"],
				7=["text"="T"],
				8=["text"="U"],
				9=["text"="V"],
				10=["text"="W"],
				11=["text"="X"],
				12=["text"="Y"],
				13=["text"="Z"],
				14=["text"="BACK", "op"=3,"delay"=2]
				]
			],
		10 = [	"text"="NUMBERS",
			"sub"=[
				0=["text"="", "op"=0],
				1=["text"="0"],
				2=["text"="1"],
				3=["text"="2"],
				4=["text"="3"],
				5=["text"="4"],
				6=["text"="5"],
				7=["text"="6"],
				8=["text"="7"],
				9=["text"="8"],
				10=["text"="9"],
				11=["text"="BACK", "op"=3]
				]
			],
		11 = [	"text"="PUNCTUATION",
			"sub"=[
				0=["text"="", "op"=0],
				1=["text"="SPACE","realtext"=" "],
				2=["text"="COMMA","realtext"=","],
				3=["text"="BACKSPACE","op" = 4],
				4=["text"="", "op"=0],
				5=["text"="BACK", "op"=3,"delay"=2]
				]
			],
		12 = [	"text"="",
			"op" = 0
			],
		13 = [	"text"="ERASE ALL",
			"op" = 2
			],
		14 = [	"text"="BACKSPACE",
			"op" = 4
			]
		]
	$.current = []
	$.choice = []
	$.level = 0
	$.doingletters = 0

	$.choice[$.level] = 0
	$.current[$.level] = $.tree
	$.busy = 0
	$.tid = task task_advance($)
	$.contents = ""
}

method advance {
	if ( $.busy == 0 ) {
		maxchoice = 0
		for ( n in $.current[$.level] ) {
			if ( n > maxchoice )
				maxchoice = n
		}
		$.choice[$.level]++
		# allow missing numbers
		while ( (! $.choice[$.level] in $.current[$.level]) && $.choice[$.level] < 30 ) {
			$.choice[$.level]++
		}
		if ( $.choice[$.level] > maxchoice )
			$.choice[$.level] = 0
		$.redraw()
	}
	t = $.current[$.level][$.choice[$.level]]
	if ( "delay" in t ) {
		return(t["delay"])
	}
	else
		return(1)
}

method resize (sz) {
		if ( nargs() > 0 )
			$.w.resize(sz)
		$.dy = $.textheight() + 4
		$.dx = ($.xmax() - $.xmin()) / $.ncols
		$.x0 = $.xmin() + 2
		$.x1 = $.xmax() - 2
		# tw = $.textwidth()
		# ya = $.ymin() + $.dy
		# yb = ya + $.dy
		# $.butt1.resize(xy($.x0,ya,$.x0+$.dx,yb))
	}

method topline (t) {
	tw = $.textwidth()
	x0 = $.x0 + 8*tw
	x1 = $.x1 - 8*tw
	sz = xy(x0,$.ymin()+$.dy,x1,$.ymin()+2*$.dy)
	$.w.fillrectangle(sz,STORE)
	$.w.text(t,sz,CLEAR)
}

method arrow(asz) {
	x0=asz["x0"]
	x1=asz["x1"]
	y0=asz["y0"]
	y1=asz["y1"]
	y0a = y0 + (y1-y0)/3
	y0b = y1 - (y1-y0)/3
	y0m = y1 - (y1-y0)/2
	x0a = x0 + 2*(x1-x0)/3
	$.w.line(xy(x0,y0a,x0,y0b),STORE)
	$.w.line(xy(x0,y0a,x0a,y0a),STORE)
	$.w.line(xy(x0,y0b,x0a,y0b),STORE)
	$.w.line(xy(x0a,y0,x0a,y0a),STORE)
	$.w.line(xy(x0a,y1,x0a,y0b),STORE)
	$.w.line(xy(x0a,y0,x1,y0m),STORE)
	$.w.line(xy(x0a,y1,x1,y0m),STORE)
}

method redraw {
	$.w.redraw()

	$.topline($.contents)

	for ( lev=0; lev<=$.level; lev++ ) {
		$.redraw_level(lev)
	}

	methodbroadcast()
}

method redraw_level(level) {

	# +5 for deleted lines
	nlines = sizeof($.current[level]) + 5
	tw = $.textwidth()
	x0 = $.x0 + level * (tw*24)

	ya = $.ymin() + 3*$.dy
	yb = ya + $.dy
	awid = tw*6
	x0a = x0+awid

	for ( n=0; n<nlines; n++ ) {
		if ( ! ( n in $.current[level] ) )
			continue
		if ( "text" in ($.current[level][n]) ) {
			t = $.current[level][n]["text"]
			if ( "sub" in ($.current[level][n]) )
				t += " ..."
			else {
				if ( t != "" && t != "BACK" )
					t += " !"
			}
				
			asz = xy(x0+tw,ya,x0a-tw,yb)
			sz = xy(x0a,ya,x0+$.dx,yb)
			if ( $.choice[level] == n ) {
				$.arrow(asz)
				$.w.fillrectangle(sz,STORE)
				$.w.text(t,sz,CLEAR)
			} else {
				$.w.fillrectangle(sz,CLEAR)
				$.w.text(t,sz,STORE)
			}
		} else {
			print("No text entry in $.current[level] n=",n)
		}
		ya = yb
		yb += $.dy
	}
}

method delete {
	kill($.tid)
}

method say {
	$.redraw()
	sec = milliclicks($.saydelay)
	mdep("clipboard","set"," ")
	sleeptill(Now+10)
	mdep("clipboard","set",$.contents)
	print("saying: ",$.contents)
	sleeptill(Now+2*sec)
}

# THIS IS WHERE THE OPS GET DONE

method mousedown(m) {
	t = $.current[$.level][$.choice[$.level]]
	$.busy = 1
	if ( "sub" in t ) {
		$.level++
		$.current[$.level] = t["sub"]
		$.choice[$.level] = 0
		$.redraw()
	} else if ( "op" in t ) {
		# If the entry is an "op", then we do something
		o = t["op"]
		if ( o == 1 ) {
			# SAY AGAIN
			$.say()
			$.level = 0
			$.choice[$.level] = 0
			$.redraw()
			sleeptill(Now+milliclicks($.movedelay))
		} else if ( o == 2 ) {
			# ERASE
			$.level = 0
			$.choice[$.level] = 0
			$.contents = ""
			$.redraw()
		} else if ( o == 4 ) {
			# ERASE 1 character
			lng = sizeof($.contents)
			$.contents = substr($.contents,1,lng-1)
			$.redraw()
		} else if ( o == 3 ) {
			# BACK
			$.level--
			$.redraw()
		}
	} else {
		# If the selection is text, then we say it
		txt = t["text"]
		if ( "realtext" in t )
			txt = t["realtext"]
		if ( sizeof(txt) == 1 ) {

			# If it's a single letter

			if ( $.doingletters == 1 ) {
				$.contents += txt
			} else {
				# If it's the first letter,
				# get rid of any existing contents
				$.doingletters = 1
				$.contents = txt
			}
		} else {
			$.doingletters = 0
			$.contents = txt

			# Old code that allowed concatenating words
			# if ( $.doingletters == 1 ) {
			# 	# If we were doing letters previously,
			# 	# get rid of the contents
			# 	$.doingletters = 0
			# 	$.contents = txt
			# } else {
			# 	$.contents += " " + txt
			# }
		}
		$.say()
		$.level = 0
		$.current[$.level] = $.tree
		$.choice[$.level] = 0
	}
	$.busy = 0
}

}

function task_advance(o) {
	sec = milliclicks($.movedelay)
	nextfactor = 1
	while ( 1 ) {
		sleeptill(Now+sec*nextfactor)
		nextfactor = o.advance()
	}
}

function aid_read(fn) {
	f = open(fn)
	while ( get(f) != Eof ) {
	}
	close(f)
}
