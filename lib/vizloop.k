#
# VizLoop
#

INCDEC_MID = 0
INCDEC_MIN = -2
INCDEC_MAX = 2
INCDEC_INC = 1
INCDEC_DEC = -1
DebugReal = 0
DebugParam = 0
DebugLoop = 0
DoVisualize = 0
DoShowClick = 0
DoBidule = 1
DoBiduleSwitching = 0
PerChanFadeout = 0

#define xxx rereadlib();vizloop()

OPS_COLUMN_0 = [
	128="VOLUME",
	64="SOLOMUTE",
	32="FADE",
	16="SHUFFLECOMB",
	8="CHANNEL",
	4="RANDADDDELETE",
	2="UNKNOWN1",
	1="UNKNOWN2"
	]

BlackColor = 0
RedColor = 1
YellowColor = 2
GreenColor = 3
CyanColor = 4
BlueColor = 5
MagentaColor = 6

PartColor = [
	"A" = BlueColor,
	"B" = YellowColor,
	"C" = CyanColor,
	"D" = MagentaColor
	]
Row2Part=[ 0="A", 1="A", 2="B", 3="B", 4="C", 5="C", 6="D", 7="D" ]
Loop2Row = [ 0 = 0, 1 = 2, 2 = 4, 3 = 6 ]
Row2GridChan = [ 0 = 1, 1 = 2, 2 = 3, 3 = 4, 4 = 5, 5 = 6, 6 = 7, 7 = 8 ]

GridRows = 8
GridCols = 24
GridLastCol = 25

LinnUserMode = 1
if ( LinnUserMode ) {
	Col0pitch = 2
	ScalePitchOffset = 3 * 12
	InputRowOffset = 0
} else {
	# LinnStrument should be set up so Linnstrument[0][0] is 18
	Col0pitch = 19
	ScalePitchOffset = 3 * 12
	InputRowOffset = 12
}

Fademap = [
	"None"    = 0,
	"Slowest" = 2,
	"Slow"    = 4,
	"Medium"  = 6,
	"Fast"    = 8,
	"Faster"  = 10,
	"Fastest" = 15,
	"Immediate" = 128
	]

FadeColor = [
	"None"    = GreenColor,
	"Slowest" = GreenColor,
	"Slow"    = GreenColor,
	"Medium"  = YellowColor,
	"Fast"    = YellowColor,
	"Faster"  = RedColor,
	"Fastest" = RedColor,
	"Immediate" = RedColor
	]

Faderow2name = [
	0="None",
	1="Slowest",
	2="Slow",
	3="Medium",
	4="Fast",
	5="Faster",
	6="Fastest",
	7="Immediate"
	]
Fadename2row = [
	"None" = 0,
	"Slowest" = 1,
	"Slow" = 2,
	"Medium" = 3,
	"Fast" = 4,
	"Faster" = 5,
	"Fastest" = 6,
	"Immediate" = 7
	]
Fadeval = [
	0 = "None",
	1 = "Slowest",
	2 = "Slow",
	3 = "Medium",
	4 = "Fast",
	5 = "Faster",
	6 = "Fastest",
	7 = "Immediate"
	]

vizinitparts("newage")

function vizloop() {

	if ( ! defined(Jsonlisten) ) {
		Jsonlisten = 4449
	}

	reallinn(linnusermode(1))

	if ( Machine != "win" ) {
		print("vizloop() only works on Windows, sorry!")
		return()
	}

	# print("Setting dragthreshold to 0...")
	Gesturedragthreshold = 0.0
	GestureDraglimit = 60

	if ( defined(TypoGM) && TypoGM == 1) {
		print("Sending gmresetall")
		realmidi(gmresetall(0x40))
	}

	t = new vizloop_mastertypo()
	t.start()
	t.waittilldone()
	t.stop()
}

class VizGridCell {
method init(r,c,inchan,inpitch,outchan,outpitch,color) {
	$._row = r
	$._col = c
	$._inchan = inchan
	$._inpitch = inpitch
	$._outchan = outchan
	$._outpitch = outpitch
	$._color = color
}
method inpitch() { return($._inpitch) }
method inchan() { return($._inchan) }
method outpitch() { return($._outpitch) }
method outchan() { return($._outchan) }
method row() { return($._row) }
method col() { return($._col) }
method color() { return($._color) }
method rc() { return(["row"=$._row,"col"=$._col]) }
}

function vizgridlight(row,col,color) {
	# print("GRIDLIGHT row=",row," col=",col," color=",color)
	return(linnlight(row,col+1,color))
}

function vizinitparts(scalename) {

	Grid = []
	GlobalScaleName = scalename
	GlobalScale = completescale('c',scalename)
	for ( r=0; r<GridRows; r++ ) {
		Grid[r] = []
		inchan = 1 + r
		outchan = 1 + r/2
		part = ascii(64+outchan)   # "A" for rows 0,1; "B" for 2,3, etc
		color = PartColor[part]

		# addition 1 to include switch buttons
		inpitch = Col0pitch - 2 + r*InputRowOffset
		for ( c= -2; c<0; c++ ) {
			p = makenote(inpitch)
			outpitch = inpitch
			Grid[r][c] = new VizGridCell(r,c,inchan,inpitch,outchan,outpitch,color)
			# print("Grid rc=",r,c," inpitch=",inpitch," outpitch=",outpitch," outchan=",outchan)
			inpitch++
		}

		inpitch = Col0pitch + r*InputRowOffset
		for ( c=0; c<GridCols; c++ ) {
			p = makenote(inpitch)
			outpitch = GlobalScale % (c+1)
			outpitch += ScalePitchOffset
			Grid[r][c] = new VizGridCell(r,c,inchan,inpitch,outchan,outpitch,color)
			# print("Grid rc=",r,c," inpitch=",inpitch," outpitch=",outpitch," outchan=",outchan)
			inpitch++
		}
	}
}

function outputnote2vizgridcell(nt,row) {

	for ( c=0; c<GridCols; c++ ) {
		g = Grid[row][c]
		if ( g.outpitch() == nt.pitch ) {
			# print("outputnote2vizgridcell nt=",nt," rc=",g.rc()," color=",g.color())
			return(g)
		}
	}
	print("HEY!  outputnote2vizgridcell nt=",nt," is Nullval??")
	return(Nullval)
}

function inputnote2vizgridrowcol(nt) {
	# The input notes are sent on channels 1-8 for rows 0-8

	for ( r=0; r<GridRows; r++ ) {
		for ( c=0; c<GridCols; c++ ) {
			g = Grid[r][c]
			if ( g.inpitch() == nt.pitch && g.inchan() == nt.chan ) {
				rc = ["row"=r,"col"=c]
				# print("inputnote2vizgridrowcol nt=",nt," rc=",rc," outpitch=",g.outpitch()," outchan=",g.outchan())
				return(rc)
			}
		}
	}
	for ( r=0; r<GridRows; r++ ) {
		for ( c= -2; c<0; c++ ) {
			g = Grid[r][c]
			if ( g.inpitch() == nt.pitch && g.inchan() == nt.chan ) {
				rc = ["row"=r,"col"=c]
				# print("inputnote2vizgridrowcol nt=",nt," rc=",rc," outpitch=",g.outpitch()," outchan=",g.outchan())
				return(rc)
			}
		}
	}
	return(["row"=0,"col"=0])
}

function vizgridrowcol2channote(row,col,innote) {
	g = Grid[row][col]
	innote.pitch = g.outpitch()
	innote.chan = g.outchan()
	# print("vizgridrowcol2channote row=",row," col=",col," nt=",innote)
	return(innote)
}

class vizloop_mastertypo {

method init() {

	# $.redraw()

	$.oldMerge = Merge
	Merge = 0

	$.visualpatch = 0
	$.soundpatch = 0
	$.gridrows = 8
	$.gridcols = 8

	$.opmode = ""
	$.opname = "sounds"   # the op specified by first column

	# 7 is the topmost row
	$.oprow2name = [7="sounds",6="visuals",5="fadeout",4="volume"]
	$.opname2row = ["sounds"=7,"visuals"=6,"fadeout"=5,"volume"=4]
	$.opname2type = ["sounds"="global","visuals"="global",
		"fadeout"="perloop","volume"="perloop"]
	$.oploop = 0

	$.transpose_values = [0=0,1=3,2=-2,3=5]
	$.transpose_pos = 0

	$.cell = []
	for ( r=0; r<$.gridrows; r++ ) {
		$.cell[r] = []
		for ( c=0; c<$.gridcols; c++ ) {
			$.cell[r][c] = ''
		}
	}

	$.globalparamset = [
		"bidule" = "set_bidule",
		"sounds" = "set_sounds",
		"visuals" = "set_visuals",
		"scale" = "set_scale",
		"tempo" = "set_tempo",
		# "loopleng"="change_global_loopleng",
		"soundset" = "set_soundset"
		]

	$.globalparamlist = [
		"sounds" = "int",
		"visuals" = "int",
		"drumfade" = "toggle",
		"bidule" = "toggle",
		"fasterquant" = "toggle",
		"tempo" = "int",
		"soundset" = "string",
		"scadjust" = "toggle",
		"scale" = "string",
		"fadeout" = "string",
		"loopleng" = "int",
		"trigger%" = "int",
		"initialized" = "toggle"
		]

	$.perchanparamlist = [
		"recording" = "toggle",
		"playloop" = "toggle",
		"velocity" = "int",
		"volume" = "int",
		"quant" = "int",
		"downqnt" = "int",
		"quantnowv" = "int",
		"quantrec" = "int",
		"quantreal" = "int",
		"trigger%" = "int",
		"trigable" = "toggle",
		"volvary%" = "int",
		"isdrum" = "toggle",
		"loopleng" = "int",
		"channel" = "int",
		"fadeout" = "string",
		"loopnotes" = "int"
		]

	$.chanparamset = [
		"volume" = "set_volume"
		]

	$.globalparam = []
	for ( nm in $.globalparamlist ) {
		type = $.globalparamlist[nm]
		$.set_globalparam(nm,$.null_value_of_type(type))
	}

	$.stopme = 0
	$.refresh_on_up = 0

	# print("TOUCH IGESTURE PAD...")

	$.vidmode = 0
	$.selectA = 1
	$.selectB = 2

	$.stepsize = 1b/4
	$.stepsize = 1b/8
	$.loopquant = 8b
	$.quit = 0
	$.lasttouchwarn = 0

	$.shiftisdown = 0

	# If shiftpolarity is 0, then you need to hold down
	# the SHIFT key in order to be recording notes.
	# If you set shiftpolarity to 1, then recording will be on
	# by default (and holding down shift will cause it to NOT record)
	$.shiftpolarity = 0

	$.charproc = 0
	$.ignorenextup = 0
	$.ctrl = 0
	$.shift = 0

	$.lastvol = []
	$.lastprox = []
	$.dragvol = 0

	$.ctrl_list = [
		"X" = "ctrl_exec"		# Xecute
	]

	$.scale_notes = [
		"Japanese" = 'p0,p3,p5,p8,p10',
		"Japanese2" = 'p0,p2,p3,p7,p8',
		"Japanese3" = 'p0,p1,p5,p7,p10',
		"Japanese4" = 'p0,p2,p3,p5,p7,p9',
		"Egyptian" = 'p0,p2,p3,p7,p8',
		"Egyptian2" = 'p0,p2,p3,p6,p7,p8,p11',
		"Greek" = 'p0,p1,p4,p7,p8,p10',
		"Greek1" = 'p0,p3,p4,p5,p7,p9,p11',
		"Greek2" = 'p0,p2,p3,p6,p7,p9,p10',
		"Greek3" = 'p0,p1,p3,p4,p7,p8,p10',
		"Greek4" = 'p0,p2,p3,p4,p7,p8,p10,p11',
		"Greek5" = 'p0,p3,p4,p5,p7,p8,p11',
		"Chinese" = 'p0,p2,p5,p7,p9',
		"Javanese" = 'p0,p2,p4,p5,p7,p9,p11',
		"Ionian" = 'p0,p2,p4,p5,p7,p9,p11',
		"Dorian" = 'p0,p2,p3,p5,p7,p9,p10',
		"Arabian" = 'p0,p1,p4,p5,p7,p8,p10',   # Phrygian
		"Arabian2" = 'p0,p1,p3,p6,p7,p8,p11',   # Blues?
		"Arabian3" = 'p0,p2,p3,p5,p7,p9,p10',
		"Indian" = 'p0,p1,p4,p6,p7,p8,p11',   # Purvi
		"African" = 'p0,p3,p5,p7,p10',
		"Lydian" = 'p0,p2,p4,p6,p7,p9,p11',
		"Mixolydian" = 'p0,p2,p4,p5,p7,p9,p10',
		"Aeolian" = 'p0,p2,p3,p5,p7,p8,p10',
		"Hungarian" = 'p0,p2,p3,p5,p6,p8,p9',
		"Rwanda" = 'p0,p2,p3,p7,p10',
		"New Age" = 'p0,p3,p5,p7,p10',
		"Fifths" = 'p0,p7',
		"Harminor" = 'p0,p2,p3,p5,p7,p8,p11',
		"Melminor" = 'p0,p2,p3,p5,p7,p9,p11',
		"Chromatic" = 'p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11'
		]

	$.buttprimed = ""

	# Now create the loopers

	vals = [ "chan" = 1, "shape" = 5 ]
	# fm8
	vals["nprograms"] = 20

	$.currloop = 0
	$.nloops = 4
	$.nrows = 8
	$.pitchcols = 21

	$.vizloop = []
	for ( lp=0; lp<$.nloops; lp++ ) {
		ch = 1
		$.vizloop[lp] = new vizloop_onelooper($,lp,$.stepsize,ch,vals,$.loopquant)
	}

	print("Init done, now starting OSC ...") 

	$.padmode = [0="Draw",0="Draw"]

	$.values = []

	$.jsonf1 = open(string(Jsonlisten)+"@127.0.0.1","rf","tcpip_listen")
	print("Listening for JSON on ",Jsonlisten)
	if ( $.jsonf1 == "" ) {
		print("Unable to listen on ",Jsonlisten," !?")
		$.jsontid1 = -1
	} else {
		$.jsontid1 = task $.jsontask($.jsonf1)
	}

	if ( DoBiduleSwitching ) {
		bidulehost = "127.0.0.1"
		biduleport = 3210
		print("OPENING BIDULE, hostname=",bidulehost," port=",biduleport)
		$.open_bidule(Hostname,biduleport)
	}

	$.reset()

##	print("Asking parameter controller for parameters")
##	$.to_parameter_controllers([0="/nth/sendallparams"])
##	print("Waiting for all parameter controller messages to arrive.")
##	$.got_continue = 0
##	$.to_parameter_controllers([0="/nth/echo",1="continue"])
##	toolong = Now + milliclicks(10000)
##	while ( $.got_continue == 0 && Now < toolong ) {
##		sleeptill(Now+1b/2)
##	}
##	if ( Now >= toolong ) {
##		print("Didn't get continue message!?  Continuing anyway...")
##	} else {
##		print("All parameters sent (and hopefully received).")
##	}

	$.change_global_loopleng("8b")

	nthcontrol = 0
	if ( ! nthcontrol ) {
		$.setdefaultsA()
	} else {
		$.nthosc = open("1385@127.0.0.1","wb","osc_send")
		msg = [0="/sendallparams"]
		mdep("osc","send",$.nthosc,msg)

		print("WAITING FOR INITIALIZATION FROM NTH GUI")
		$.set_globalparam("initialized",0)
		while ( $.get_globalparam("initialized") == 0 ) {
			sleeptill(Now+1b)
		}
	}

	print("VizLoop is NOW ACTIVE!")
	$.redraw()
}

method setdefaultsA() {
	# print("SETDEFAULTS!!!!")
	for ( lp=0; lp<4; lp++ ) {
		$.perchan_set("recording","on",lp)
		$.perchan_set("playloop","on",lp)
		$.perchan_set("trigger%",100,lp)
		$.perchan_set("loopleng","8b",lp)
		$.perchan_set("fadeout","Slow",lp)
		$.perchan_set("channel",1,lp)
		$.perchan_set("quantrec","1b/4",lp)
		$.perchan_set("quantreal","1b/4",lp)
		$.perchan_set("quantnowv","1b/4",lp)
		$.perchan_set("isdrum",(lp==3)?"on":"off",lp)
		$.perchan_set("loopnotes",32,lp)
		$.perchan_set("velocity",100,lp)
		$.perchan_set("volume",6,lp)
		$.perchan_set("downqnt","1b/4",lp)
	}
	$.global_set("trigger%",100)
	$.global_set("loopleng","8b")
	$.global_set("fadeout","Slow")
	$.global_set("scadjust","on")
	$.global_set("scale","Chinese")
	$.global_set("transposeabs",0)
	$.global_set("tempo",120)
}

method setdefaultsB() {
	# print("SETDEFAULTS!!!!")
	for ( lp=0; lp<4; lp++ ) {
		$.perchan_set("recording","off",lp)
		$.perchan_set("playloop","on",lp)
		$.perchan_set("trigger%",100,lp)
		$.perchan_set("loopleng","8b",lp)
		$.perchan_set("fadeout","Medium",lp)
		$.perchan_set("channel",1,lp)
		$.perchan_set("quantrec","0",lp)
		$.perchan_set("quantreal","0",lp)
		$.perchan_set("quantnowv","1b/4",lp)
		$.perchan_set("isdrum",(lp==3)?"on":"off",lp)
		$.perchan_set("loopnotes",32,lp)
		$.perchan_set("velocity",100,lp)
		$.perchan_set("volume",6,lp)
		$.perchan_set("downqnt","1b/4",lp)
	}
	$.global_set("trigger%",100)
	$.global_set("loopleng","8b")
	$.global_set("fadeout","Medium")
	$.global_set("scadjust","off")
	$.global_set("scale","Chinese")
	$.global_set("transposeabs",0)
	$.global_set("tempo",120)
}

method redrawop() {
	if ( $.opmode == "" ) {
		$.all_loops("redrawop")
		return()
	}
	p = ''
	for ( col=0; col<3; col++ ) {
		for ( row=0; row<8; row++ ) {
			p += linnlight(row,col,BlackColor)
		}
	}
	reallinn(p)
	p = ''
	if ( $.opname in $.opname2row ) {
		optype = $.opname2type[$.opname]
		row = $.opname2row[$.opname]
		p += linnlight(row,0,GreenColor)
		if ( optype == "global" ) {
			v = $.get_globalparam($.opname)
			p += linnlight(v,1,GreenColor)
			for ( row=0; row<8; row++ ) {
				color = PartColor[Row2Part[row]]
				p += linnlight(row,2,color) 
			}
		} else if ( optype == "perloop" ) {
			t = $.vizloop[$.oploop]
			if ( $.opname == "fadeout" ) {
				r = Fadename2row[t.get_chanparam("fadeout")]
				p += linnlight(r,1,GreenColor)
			} else if ( $.opname == "volume" ) {
				r = t.get_chanparam("volume")
				# print("Displaying volume r=",r)
				p += linnlight(r,1,GreenColor)
			}
			color = PartColor[Row2Part[$.oploop*2]]
			p += linnlight($.oploop*2,2,color) 
				+ linnlight($.oploop*2+1,2,color)
		}
	}
	reallinn(p)
}

method redrawcolblank(col) {
	p = ''
	for ( row=0; row<8; row++ ) {
		p += linnlight(row,col,0)
	}
	reallinn(p)
}

method redrawswitches() {
	p = ''

	if ( $.loopleng == 8b ) {
		looplengcolor = YellowColor
	} else {
		looplengcolor = BlueColor
	}
	p += linnlight(3,-1,looplengcolor)

	v = $.get_globalparam("fadeout")
	p += linnlight(4,-1,FadeColor[v])
	
	reallinn(p)
}

method redraw() {
	linnclear(0)
	$.redrawswitches()
	$.all_loops("redraw")
}

method null_value_of_type(t) {
	if ( t == "int" ) return(0)
	if ( t == "toggle" ) return(0)
	if ( t == "string" ) return("")
	print("Unexpected type in null_value_of_type: ",t)
}

method get_perchanparamlist() {
	return($.perchanparamlist)
}

method grid2drum(r,c) {
	p = 36 + c + r * $.gridcols
	return(makenote(p))
}

method set_globalparam(nm,v) {
	if ( DebugParam )
		print("SET GLOBAL PARAM nm=",nm," v=",v)
	$.globalparam[nm] = v
}

method do_transrand() {
	$.transpose_pos = ($.transpose_pos+1) % sizeof($.transpose_values)
	$.all_loops("set_transpose",$.transpose_values[$.transpose_pos])
}

method set_transpose(val) {
	$.realano()
	$.all_loops("set_transpose",val)
}

method jsontask(jsonf) {
	# Input will start coming as soon as a connection is open,
	# and setting the fifotype on the socket inside handle_json is
	# too late, so we change the default.
	fifoctl("default","type","l")

	while ( (x=get(jsonf)) != Eof ) {
		task $.handle_json(x)
	}
}

method handle_json(jsonconn) {

	reqtype = ""
	while ( (d=get(jsonconn["r"])) != Eof ) {
		if ( d == "\n" || d == "\r\n" || d == "\r" ) {
			if ( reqtype == "GET" ) {
				$.get_response(jsonconn["w"],getline)
				break;
			} else if ( reqtype == "POST" ) {
				# print("GOT POST request, continue reading")
			} else {
				print("GOT unrecognized request")
				put(jsonconn["w"],"Unrecognized request\n")
				break;
			}
			
		} else if ( substr(d,1,4) == "GET " ) {
			reqtype = "GET"
			getline = d
		} else if ( substr(d,1,5) == "POST " ) {
			reqtype = "POST"
			postline = d
		} else if ( substr(d,1,8) == "OPTIONS " ) {
			reqtype = "OPTIONS"
		} else if ( substr(d,1,1) == "{" ) {
			j = $.string2json(d)
			ret = $.jsonhandler(j)
			put(jsonconn["w"],ret)
			break
		} else {
		}
	}
	close(jsonconn["r"])
	close(jsonconn["w"])
}

method get_response(fout,getline) {

	put(fout,"GET has been disabled!\n")
	return()

	# Responses seem to get occasionally corrupted,
	# not sure why, but the lock helps
	# lock("get_response")

	words = split(getline)
	url = words[1]
	if ( url == "/" )
		url = "index.html"
	fname = LinnLooperHtmlDir + url
	fin = open(fname)
	if ( fin >= 0 ) {
		# print("Sending back fname=",fname)
		if (
			strindex(fname,".html") > 0
			|| strindex(fname,".htm") > 0
			|| strindex(fname,".css") > 0
			|| strindex(fname,".js") > 0
			) {
			fifoctl(fin,"type","l")
			fifoctl(fout,"type","l")
			cnt = 0
			totsize = 0
			while ( (line=get(fin)) != Eof ) {
				chunk = 64
				left = sizeof(line)
				while ( left > 0 ) {
					part1 = substr(line,1,chunk)
					line = substr(line,chunk+1)
					put(fout,part1)
					# print("CHUNK size=",sizeof(part1))
					totsize += sizeof(part1)
					cnt++
					left = sizeof(line)
					sleeptill(Now+1)
				}
				# put(fout,line)
				# totsize += sizeof(line)
				# cnt++
			}
			close(fin)
			print("TEXT FILE=",fname," had ",cnt," lines and ",totsize," bytes")
		} else {
			fifoctl(fin,"type","b")
			fifoctl(fout,"type","b")
			cnt = 0
			while ( (c=get(fin)) != Eof ) {
				put(fout,integer(c))
				cnt++
			}
			close(fin)
			# print("BINARY FILE=",fname," had ",cnt," bytes")
		}
	} else {
		print("UNABLE TO OPEN fname=",fname)
	}
	# unlock("get_response")
}

method options_response(f) {
	s = "HTTP/1.1 200 OK\r\n"
		+"Access-Control-Allow-Origin: *\r\n"
		+"Access-Control-Allow-Methods: GET, POST, OPTIONS\r\n"
		+"Content-Length: 0\r\n"
		+"\r\n"
		+"\r\n";
	print("Sending back: s=",s)
	put(f,s)
}

method jsonheader() {
	return("HTTP/1.1 200 OK\r\n\
Content-Type: application/json; charset=UTF-8\r\n\
Access-Control-Allow-Origin: *\r\n\
Access-Control-Allow-Methods: GET, POST\r\n\
Access-Control-Allow-Headers: X-Requested-With\r\n\
\r\n")
}


# This is a silly way of doing substitute, should it be built-in?
method substitute(s,c1,c2) {
	w = split(s,c1)
	nw = sizeof(w)
	r = ""
	for ( n=0; n<nw; n++ ) {
		if ( n > 0 )
			r += c2 
		r += w[n]
	}
	return(r)
}

# JSON handling should probably be built-in
method string2json(d)
{
	d = " "+d+" "   # to ensure that the split stuff works
	d = $.substitute(d,":","=")
	d = $.substitute(d,"[","arraylistordered(")
	d = $.substitute(d,"]",")")
	d = $.substitute(d,"{","[")
	d = $.substitute(d,"}","]")
	global true
	global false
	eval "JSON="+d
	return(JSON)
}

method jsonok() {
	return( $.jsonheader() + "{\"jsonrpc\": \"2.0\", \"result\": 0 }\r\n" )
}

method jsonerr(e,id) {
	if ( typeof(e) != "string" ) {
		print("Hey, e isn't a string in jsonerr? e=",e)
	}
	return( $.jsonheader() + "{\"jsonrpc\": \"2.0\", \"error\": {\"code\": -32700, \"message\": \"" + string(e) + "\"}, \"id\": "+string(id)+" }\r\n" )
}

method jsonresult_str(r,id) {
	return( $.jsonheader() + "{\"jsonrpc\": \"2.0\", \"result\": \"" + string(r) + "\", \"id\": \""+string(id)+"\" }\r\n" )
}

method jsonresult_number(r,id) {
	return( $.jsonheader() + "{\"jsonrpc\": \"2.0\", \"result\": " + string(r) + ", \"id\": \""+string(id)+"\" }\r\n" )
}

method get_looper(loopnum) {
	loopnum = integer(loopnum)   # if it's a string
	t = $.vizloop[loopnum]
	return(t)
}

method perchan_set(nm,v,looptoset) {

	t = $.get_looper(looptoset)
	ch = t.get_currchan()
	if ( ! (nm in $.perchanparamlist) ) {
		return("UNKNOWN loop parameter: "+nm)
	}
	pt = $.perchanparamlist[nm]
	if ( pt == "toggle" ) {
		t.set_chanparam(nm,$.ison(nm,v))
	} else if ( pt == "int" ) {
		# The value of v might be
		# a 'beat' value like 3b/4
		en = eval_number(v)
		if ( ! defined(en) )
			en = -1
		t.set_chanparam(nm,integer(en))
	} else if ( pt == "float" ) {
		t.set_chanparam(nm,float(v))
	} else if ( pt == "string" ) {
		t.set_chanparam(nm,v)
	} else {
		print("Unknown parameter type for nm=",nm)
	}
	if ( nm in $.chanparamset ) {
		t.($.chanparamset[nm])(ch)
	}
	return( Nullval)
}

method global_set(nm,v) {
	# print("global_set, name=",nm," v=",v)
	if ( nm in $.globalparamlist ) {
		pt = $.globalparamlist[nm]
		if ( pt == "toggle" ) {
			$.set_globalparam(nm,$.ison(nm,v))
		} else if ( pt == "int" ) {
			# The value of v might be
			# a 'beat' value like 3b/4
			en = eval_number(v)
			if ( ! defined(en) )
				en = -1
			$.set_globalparam(nm,integer(en))
		} else if ( pt == "float" ) {
			$.set_globalparam(nm,float(v))
		} else if ( pt == "string" ) {
			$.set_globalparam(nm,v)
		} else {
			print("Unknown parameter type for nm=",nm)
		}
		if ( nm in $.globalparamset ) {
			$.($.globalparamset[nm])(v)
		}
	} else if ( nm == "transposeabs" ) {
		i = integer(v)
		$.set_transpose(i)
	} else {
		print("UNKNOWN global parameter: "+nm)
		return("UNKNOWN global parameter: "+nm)
	}
	return( Nullval)
}

method jsonhandler(j) {

	if ( ! ("method" in j) ) {
		return($.jsonerr("No method in json?",-1))
	}

	id = j["id"]
	meth = j["method"]
	params = j["params"]

	if ( meth == "echo" ) {
		return( $.jsonresult_str(params["value"],id) )
	}
	if ( meth == "ping" ) {
		return( $.jsonresult_str("True",id) )
	}
	if ( meth == "perchan_set" ) {
		nm = params["name"]
		looptoset = params["channel"]
		v = params["value"]
		msg = $.perchan_set(nm,v,looptoset)
		if ( msg == Nullval ) {
			return( $.jsonok("True",id) )
		} else {
			return($.jsonerr(msg,id))
		}
	}
	if ( meth == "global_set" ) {
		# print("GLOBAL_SET params=",params)
		nm = params["name"]
		v = params["value"]
		msg = $.global_set(nm,v)
		if ( msg == Nullval ) {
			return( $.jsonok("True",id) )
		} else {
			return($.jsonerr(msg,id))
		}

	}
	if ( meth == "global_get" ) {
		nm = params["name"]
		v = $.get_globalparam(nm)
		print("global_set, name=",nm," v=",v)
		if ( v == Nullval ) {
			return($.jsonerr("UNKNOWN global parameter: "+nm,id))
		}
		if ( typeof(v) == "string" ) {
			return($.jsonresult_str(v,id))
		} else {
			return($.jsonresult_number(v,id))
		}
	}
	if ( meth == "global_action" ) {
		action = params["action"]
		print("GLOBAL ACTION = ",action)
		if ( action == "clear" ) {
			$.all_loops("oneloop_clear",1)
			$.redraw()
		} else if ( action == "transreset" ) {
			$.set_transpose(0)
		} else if ( action == "transrand" ) {
			$.do_transrand()
		} else if ( action == "fade" ) {
			$.all_loops("do_fade")
		} else if ( action == "comb" ) {
			$.all_loops("do_comb")
		} else if ( action == "shuffle" ) {
			$.all_loops("do_shuffle")
		} else if ( action == "quantnow" ) {
			$.all_loops("do_quantnow")
		} else {
			print("UNKNOWN global action: ",action)
			return($.jsonerr("UNKNOWN global action: "+action,id))
		}
		return( $.jsonok("True",id) )
	}
	if ( meth == "perchan_action") {
		action = params["action"]
		lp = params["channel"]
		print("PERCHAN ACTION = ",action," chan=",params["channel"]," lp=",lp)
		t = $.get_looper(lp)
		if ( DebugParam )
			print("NTH LOOP ACTION = ",d[1])
		if ( action == "clear" ) {
			t.oneloop_clear(0)
		} else if ( action == "quantnow" ) {
			t.do_quantnow()
		} else if ( action == "fade" ) {
			t.do_fade(1)
		} else if ( action == "comb" ) {
			t.do_comb()
		} else if ( action == "shuffle" ) {
			t.do_shuffle()
		} else if ( action == "comb" ) {
			$.all_loops("onechan_comb",ch)
		} else if ( action == "shuffle" ) {
			$.all_loops("onechan_shuffle",ch)
		} else {
			print("UNKNOWN perchan action: ",action)
			return($.jsonerr("UNKNOWN perchan action: "+action,id))
		}
		return( $.jsonok("True",id) )
	}
	if ( meth == "current_channel" ) {
		lp = params["channel"]
		$.currloop = lp
		t = $.get_looper($.currloop)
		print("SETTING CHANNEL =",t.get_currchan(),"  currloop=",lp)
		return( $.jsonok("True",id) )
	}

	return($.jsonerr("LinnLoop has no method named "+meth,-1))
		
	addr = d[0]
	t = $.get_looper($.currloop)
	ch = t.get_currchan()

	if ( addr == "/nth/echo" ) {
		if ( d[1] == "continue" ) {
			$.got_continue = 1
		}
	} else if ( addr == "/nth/ano" ) {
		print("ANO!")
		$.realano()
	} else if ( addr == "/nth/grab" ) {
		r = d[1]
		c = d[2]
		p = lastbunch(Recorded)
		p.time = 0
		$.cell[r][c] = p
		print("grabbed row/col=",r,c,"  p=",p)
	} else if ( addr == "/nth/currentloop" ) {
		print("/nth/currentloop IS BEING IGNORED!")
	} else if ( addr == "/registerclient" ) {
		$.registerclient(d[1],d[2])
	} else if ( addr == "/unregisterclient" ) {
		$.registerclient(d[1],d[2])
	} else {
		return("jsontask doesn't recognize: "+string(d))
	}
	return("")
}
method change_global_loopleng(lng) {
	# It comes in as a string like "4b"
	lng = eval_number(lng)
	$.loopleng = lng
	print("CHANGING GLOBAL LOOPLENG!! beats=",$.loopleng/1b)
	$.all_loops("change_loopleng","loopleng",$.loopleng)
}

method all_loops(action,...) {
	for ( lp in $.vizloop ) {
		t = $.vizloop[lp]
		# print("ALL LOOPS lp=",lp," t=",t)
		t.(action)(...)
	}
}

method set_soundset() {
	nm = $.get_globalparam("soundset")
	# print("SET SOUNDSET = ",nm)
	if ( nm == "One" ) {
		$.bidule_enable("Omnisphere_0",0)
		$.bidule_enable("Omnisphere_1",1)
		$.bidule_enable("Omnisphere_2",1)
		$.bidule_enable("Omnisphere_3",1)
	} else if ( nm == "Two" ) {
		$.bidule_enable("Omnisphere_0",1)
		$.bidule_enable("Omnisphere_1",0)
		$.bidule_enable("Omnisphere_2",1)
		$.bidule_enable("Omnisphere_3",1)
	} else if ( nm == "Three" ) {
		$.bidule_enable("Omnisphere_0",1)
		$.bidule_enable("Omnisphere_1",1)
		$.bidule_enable("Omnisphere_2",0)
		$.bidule_enable("Omnisphere_3",1)
	} else if ( nm == "Four" ) {
		$.bidule_enable("Omnisphere_0",1)
		$.bidule_enable("Omnisphere_1",1)
		$.bidule_enable("Omnisphere_2",1)
		$.bidule_enable("Omnisphere_3",0)
	}
}
method bidule_enable(nm,mode) {
	msg = [0="/"+nm+"/Mode",1=mode]
	$.to_bidule(msg)
}

method set_bidule() {
	nm = $.get_globalparam("bidule")
	msg = [0="/play",1=nm]
	print("SENDING bidule on/off =",msg)
	$.to_bidule(msg)
}

method set_scale() {
	print("SET_SCALE!!!  IGNORED!")
	return()
	nm = $.get_globalparam("scale")
	if ( DebugParam )
		print("SET_SCALE nm=",nm)
	if ( ! ( nm in $.scale_notes) ) {
		print("No scale named: ",nm)
		return()
	}
	sc = completescalephrase($.scale_notes[nm])
	sc = sc{??.pitch > 20 && ??.pitch < 116}

	print("SETTING GLOBAL SCALE to name=",nm," sc=",sc)
	vizinitparts(nm)

	for ( lp in $.vizloop ) {
		t = $.vizloop[lp]
	}
}

method to_bidule(msg) {
	if ( DoBidule ) {
		mdep("osc","send",$.bidule,msg)
	}
}

method open_bidule(host,port) {
	portaddr = string(port)+"@"+host
	$.bidule = open(portaddr,"wb","osc_send")
}

method waittilldone {
	wait($.constid)
}

method realano() {
	realtime(ano(),Now)
}

method start() { 

	for ( lp in $.vizloop ) {
		t = $.vizloop[lp]
		t.start()
	}

	Consecho = 0
	Consupdown = 1
	$.constid = task $.cons_task()

	$.current_loopnum = 0

	Midiin[$] = f = open()
	$.miditid = task $.midi_task(Midiin[$])
}

method stop {
	$.stopme = 1
	kill($.miditid)
	kill($.constid)

	if ( $.jsonf1 >= 0 )
		close($.jsonf1)

	for ( lp in $.vizloop ) {
		t = $.vizloop[lp]
		t.stop()
	}

	Typos = -1
	if ( $.consf >= 0 ) {
		Consupdown = 0
		# print("Setting Consecho to 1")
		Consecho = 1
		Root.releaseconsole()
	}
	Merge = $.oldMerge
}

method cons_task() {
	$.consf = Root.grabconsole()
	global vizloop_resetconsole
	onexit(vizloop_resetconsole,$)
	while ( $.quit == 0 && (c=get($.consf)) != Eof ) {
		# print("GOT c=",c," from console")
		$.handle_console(c)
	}
}

method midi_task(f) {
	global vizloop_midi_restart
	onexit(vizloop_midi_restart,$)

	print("MIDI_TASK start!")
	while ( (nt=get(f)) != Eof ) {
		# print("Got nt=",nt)
		$.handle_note(nt)
	}
	print("HEY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! midi_task finishes?!?")
}

method set_sounds(v) {
	print("Set Sound = ",v)
	$.soundpatch = v
	for ( lp in $.vizloop ) {
		t = $.vizloop[lp]
		t.set_sound(v)
	}
}



method set_visuals(v) {
	$.visualpatch = v
	print("SET VISUALS = ",$.visualpatch + 1)
	$.toffff = open("3333@127.0.0.1","wb","osc_send")
	patch = "viz_"+string($.visualpatch+1)
	msg = [0="/api",1="ffff.loadpipeline",2="{\"filename\":\""+patch+"\"}"]
	# print("Sending osc msg=",msg)
	mdep("osc","send",$.toffff,msg)

	# if ( MidiVizPort >= 0 ) {
	# 	# A CC #127 message on channel 16 sp
	# 	nt = controller(16,127,v)
	# 	nt.port = MidiVizPort
	# 	# print("Sending cc127 to change visual nt=",nt)
	# 	realtime(nt)
	# }
}

method settempo(v) {
	print("Tempo = ",v)
}

method handle_cmd_poke(row,col,keydown) {

	# print("HANDLE_CMD_POKE row=",row," col=",col," keydown=",keydown)

	if ( !keydown ) {
		return()
	}
	if ( col == -1 ) {
		if ( row in $.oprow2name ) {
			$.opname = $.oprow2name[row]
			print("SETTING opname=",$.opname)
		}
	} else if ( col == 0 ) {
		if ( $.opname2type[$.opname] == "global" ) {
			# print("SETTING GLOBAL value of ",$.opname," to ",row)
			# $.set_globalparam($.opname)
			$.global_set($.opname,row)
		} else {
			# perloop things
			t = $.get_looper($.oploop)
			if ( $.opname == "fadeout" ) {
				t.setfade(Fadeval[row])
			} else {
				t.set_chanparam($.opname,row)
			}
		}
	} else if ( col == 1 ) {
		lp = row / 2
		$.oploop = lp
	}
	$.redrawop()
	return()
}

method handle_cmd(row,col,keydown) {
	if ( keydown ) {
		# print("HANDLE_CMD rc=",row,col)
	}

	if ( col == -1 ) {
		# this is the erase and rec/play/mute column
		loopnum = row/2
		t = $.get_looper(loopnum)
		if ( (row%2) == 1 ) {
			# This is the red-lit button, erases one channel's loop
			if ( keydown ) {
				t.oneloop_clear(0)
				t.redrawblank()
			} else {
				t.redraw()
			}
		} else {
			if ( ! PerChanFadeout ) {
				# same as red button
				if ( keydown ) {
					t.oneloop_clear(0)
					t.redrawblank()
				} else {
					t.redraw()
				}
			} else {
				if ( keydown ) {
					f = t.get_chanparam("fadeout")
					print("Fadeout is ",f)
					if ( f == "Slowest" ) {
						f = "Medium"
					} else if ( f == "Medium" ) {
						f = "Fastest"
					} else { 
						f = "Slowest"
					}
					t.set_chanparam("fadeout",f)
					t.redraw()
				}
			}
		}
		return()
	}
	if ( col == -2 ) {

		# This is the column of toggle switches

		# Some switches turn red momentarily
		if ( row==7 || row==6 || row==5 || row==2 ) {
			if ( ! keydown ) {
				reallinn(linnlight(row,-1,BlackColor))
			} else {
				reallinn(linnlight(row,-1,RedColor))
			}
		}

		if ( row == 7 ) {
			if ( keydown ) {
				# Clear all 4 tracks
				print("clearing all tracks")
				$.all_loops("oneloop_clear",1)
				$.redraw()
			}
			return()
		}
		if ( row == 6 ) {
			if ( keydown ) {
				print("Next sound patch")
				nextv = ($.soundpatch+1) % 8
				$.set_sounds(nextv)
			}
			return()
		}
		if ( row == 5 ) {
			if ( keydown ) {
				print("Next visual patch")
				nextv = ($.visualpatch+1) % 8
				$.set_visuals(nextv)
			}
			return()
		}
		if ( row == 4 ) {
			if ( keydown ) {
				f = $.get_globalparam("fadeout")
				if ( f == "Slowest" ) {
					f = "Medium"
				} else if ( f == "Medium" ) {
					f = "Fastest"
				} else { 
					f = "Slowest"
				}
				$.set_globalparam("fadeout",f)
				for ( lp in $.vizloop ) {
					t = $.vizloop[lp]
					t.set_chanparam("fadeout",f)
				}
				print("All fadeout is now ",f)
				$.redrawswitches()
			}
			return()
		}
		if ( row == 3 ) {
			if ( keydown ) {
				if ( $.loopleng == 8b ) {
					lng = 16b
				} else {
					lng = 8b
				}
				$.change_global_loopleng(lng)
				$.redrawswitches()
			}
			return()
		}
		if ( row == 2 ) {
			if ( keydown ) {
				print("LESS QUANT")
				$.set_globalparam("fasterquant",1)
			} else {
				print("DEFAULT QUANT")
				$.set_globalparam("fasterquant",0)
			}
			return()
		}
		if ( row == 1 ) {
			print("ROW 1!!")
			if ( ! keydown ) {
				dt = Now - $.opmodetime
				if ( dt < 1b ) {
					# leave opmode on
					return()
				}
				$.opmode = ""
				$.redrawop()
			} else {    # keydown
				$.opmodetime = Now
				if ( $.opmode != "" ) {
					$.opmode = ""
				} else {
					if ( row == 7 ) {
						$.opmode = "global"
					} else {
						$.opmode = ""
					}
				}
				$.redrawop()
			}
			return()
		}
	}
	print("Cmd col unrecognized ! col=",col)
	return()

	if ( col == -3 ) {
		if ( row == 0 ) {
			if ( keydown ) {
				print("ANO!")
				$.all_loops("realano")
			}
		} else if ( row == 1 ) {
			b = $.get_globalparam("fasterquant")
			$.set_globalparam("fasterquant",!b)
		}
		return()
	}
	if ( col == -1 ) {
		if ( keydown ) {
 			loopnum = row/2
			plus = ((row%2)==1)
 			t = $.get_looper(loopnum)
			if ( $.oprow in OPS_COLUMN_0 ) {
				op = OPS_COLUMN_0[$.oprow]
				t.doop(op,plus)
			}
		}
		return()
	}

# 	if ( col == -1 ) {
# 		# resync click light
# 		if ( keydown ) {
# 			print("Resync!!")
# 			$.all_loops("resync")
# 			$.redraw()
# 		}
# 	} else if ( col == -2 ) {
# 		if ( row == 0 ) {
# 			$.muted = keydown
# 			print("SILENCE = ",$.muted)
# 			$.all_loops("set_muted",keydown)
# 		} else if ( row == 7 && keydown) {
# 			print("Clearing all loops, ANO")
# 			$.all_loops("oneloop_clear",1)
# 			$.all_loops("realano")
# 			$.redraw()
# 		}
# 	} else if ( col == -4 ) {
# 		if ( keydown ) {
# 			loopnum = row/2
# 			t = $.get_looper(loopnum)
# 			# t.oneloop_clear(0)
# 			print("FADING LOOPNUM = ",loopnum)
# 			t.do_fade()
# 			t.redraw()
# 		}
# 	} else if ( col == -3 ) {
# 		if ( keydown ) {
# 			loopnum = row/2
# 			t = $.get_looper(loopnum)
# 			# t.do_comb(0)
# 			print("SHUFFLING LOOPNUM = ",loopnum)
# 			t.do_shuffle()
# 			t.redraw()
# 		}
# 	} else {
# 		print("CMD not implemented for row=",row," col=",col)
# 	}
}

method midi_restart() {
	if ( $.stopme ) {
		closemidi($)
	} else {
		print("RESTARTING midi_task!!")
		$.miditid = task $.midi_task(Midiin[$])
	}
}

method putline(f,s) {
	put(f,s)
	put(f,"\n")
}

method ison(nm,v) {
	if ( v=="on" )
		return(1)
	if ( v=="off" )
		return(0)
	print("UNEXPECTED value in ison nm=",nm," v=",v)
	return(0)
}

method chan_get(ch,nm) {
	s = nm + "#" + string(ch)
	v = $.(s)
	# print("CHAN_GET called, ch=",ch," nm=",nm," s=",s," v=",v)
	return(v)
}

method get_globalparam(nm) {
	if ( ! ( nm in $.globalparam ) ) {
		print("ERROR get_globalparam called on nm=",nm)
		return(0)
	}
	return($.globalparam[nm])
}

method set_tempo() {
	v = $.get_globalparam("tempo")
	print("Setting BPM to ",v)
	bpm(v)
	# print("Tempo is now ",tempo())
}

method ano() {
	realtime(ano())
}

method reset() {
	$.ano()
}

method handle_note(c) {

	t = $.vizloop[$.current_loopnum]
	ch = t.get_currchan()

	doublequant = 0

	c.time = 0
	c.chan = ch
	isrecording = t.is_recording() && t.is_playloop()
	isdrum = t.get_chanparam("isdrum")

	# print("isrecording=",isrecording)
	# if ( ! isrecording && c.type == CONTROLLER )
	if ( c.type == CONTROLLER ) {

		b0 = integer(subbytes(c,1,1))
		ctrlnum = integer(subbytes(c,2,1))
		ctrlval = integer(subbytes(c,3,1))
		# print("b0=",b0," ctrlnum=",ctrlnum," ctrlval=",ctrlval)

		if ( ctrlnum >= 56 && ctrlnum <= 63 ) {
			# TOP RIGHT SWITCH ROW
			# ony 4 loops at the moment
			$.current_loopnum = ( ctrlnum - 56 ) % 4
			print("SETTING current_loopnum to = ",$.current_loopnum)
			return()
		} else if ( ctrlnum >= 49 && ctrlnum <= 55 ) {
			# FIRST ROW OF SWITCHES, TOP LEFT
			snd = ( ctrlnum-48 ) % 8
			t.set_sound(snd)
			return()
		} else if ( ctrlnum == 64 ) {
			# Sustain pedal, sigh
		} else if ( ctrlnum >= 65 && ctrlnum <= 71 ) {
			# SECOND ROW OF SWITCHES, TOP LEFT
			viz = ctrlnum-64
			$.set_visuals(viz)
			return()
		} else if ( ctrlnum == 118 ) {
			print("CLEARING ALL LOOPS!")
			$.all_loops("oneloop_clear",1)
			return()
		} else if ( ctrlnum == 117 ) {
			# this is >>
			print("SCALE ADJUST is ON")
			$.global_set("scadjust","on")
			return()
		} else if ( ctrlnum == 116 ) {
			# this is <<
			print("SCALE ADJUST is OFF")
			$.global_set("scadjust","off")
			return()
		} else if ( ctrlnum >= 80 && ctrlnum <= 87 ) {
			q = 1b/2
			if ( ctrlnum == 80 ) {
				q = 0
			} else if ( ctrlnum == 81 ) {
				q = 1b/4
			} else if ( ctrlnum == 82 ) {
				q = 1b/2
			}
			print("SETTING QUANT to ",q)
			$.perchan_set("quantrec",q,$.current_loopnum)
			$.perchan_set("quantreal",q,$.current_loopnum)
			return()
		} else if ( ctrlnum == 81 ) {
			# turn quantization on/off
			# THIRD ROW OF SWITCHES, TOP LEFT
			if ( ctrlval == 0 ) {
				v = "0"
			} else {
				v = "1b/4"
			}
			$.perchan_set("quantrec",v,$.current_loopnum)
			$.perchan_set("quantreal",v,$.current_loopnum)
			return()
		} else if ( ctrlnum == 88 ) {
			# long/short loop length
			if ( ctrlval == 0 ) {
				$.change_global_loopleng(8b)
			} else {
				$.change_global_loopleng(16b)
			}
			return()
		} else if ( ctrlnum == 114 ) {
			# the recording button
			if ( ctrlval > 0 ) {
				print("RECORDING for loopnum=",$.current_loopnum," is ON")
				$.perchan_set("recording","on",$.current_loopnum)
			}
			return()
		} else if ( ctrlnum == 119 ) {
			# the play button
			if ( ctrlval > 0 ) {
				print("RECORDING for loopnum=",$.current_loopnum," is OFF")
				$.perchan_set("recording","off",$.current_loopnum)
			}
			return()
		}

		if ( ctrlnum > 16 && ctrlnum != 64 ) {
			print("IGNORING ctrlnum=",ctrlnum)
			return()
		}

		c.port = t.current_port()
		c.time = 0
		print("Sending c=",c," port=",c.port," controller=",ctrlnum," ctrlval=",ctrlval)
		realtime(c,Now)
		return()

		# if ( b0 == 0xb0 && b1 == 0x07 ) {
		# 	# Volume control always works
		# 	c.port = 0
		# 	c.time = 0
		# 	$.realtime(c,Now)
		# 	return()
		# }
	}

	fasterquant = $.get_globalparam("fasterquant")
	doscadjust = $.get_globalparam("scadjust")
	if ( isrecording ) {
		# print("is_recording c=",c)

		if ( ! isdrum && doscadjust ) {
			c = scadjust(c,GlobalScale)
		}

		if ( c.type == NOTEON )
			keydown = 1
		else if ( c.type == NOTEOFF )
			keydown = 0
		else if ( c.type == CONTROLLER ) {
			print("Passing controller through c=",c)
			t.realtime(c,0,0)
			return()
		} else {
			# print("Passing non-note/non-controller through c=",c)
			t.realtime(c,0,0)
			return()
		}
		q = t.get_chanparam("quantrec")
		if ( fasterquant ) {
			q = q/2
		}
		if ( doublequant ) {
			q *= 2
		}
		# print("QUANT = ",q)
		t.looper_input_pq(keydown,c,1.5,900+c.pitch,1,q)
	} else {
		if ( ! isdrum && doscadjust ) {
			c = scadjust(c,GlobalScale)
		}
		q = t.get_chanparam("quantreal")
		if ( fasterquant ) {
			q = q/2
		}
		if ( doublequant ) {
			q *= 2
		}
		if ( q > 0 ) {
			playat = nextquant(Now,q)
		} else {
			playat = Now
		}
		# print("USING quantreal NOT looping = ",q," playat=",playat," Now=",Now)
		c.time = 0
		t.realtime(c,playat,1)
	}
	return()
}

method handle_console(c) {

	keydown = (substr(c,1,1) == "+" )
	c = substr(c,2)
	padi = -1
	prox = 2.0

	$.handle_chr(c,padi,prox,keydown)
}

method handle_chr(c,padi,prox,keydown) {

	# print("handle_chr c=",c," keydown=",keydown)
	if ( ! keydown ) {
		if ( c == $.ignorenextup ) {
			$.ignorenextup = 0
			return()
		}
	}

	if ( c == "CTRL" ) {
		$.ctrl = keydown
		return()
	}
	if ( c == "SHIFT" ) {
		$.shift = keydown
		return()
	}

	if ( $.charproc != 0 ) {
		if ( keydown ) {
			f = $.charproc
			if ( ! defined($.(f)) ) {
				print("f=",f," not defined?")
			} else {
				$.(f)(c)
			}
			# The function might have changed the
			# function as a way to grab the next character
			# If so, leave it alone
			if ( $.charproc == f )
				$.charproc = 0
			$.ignorenextup = c
		}
		return()
	}

	if ( keydown ) {
		num = -1
		if ( c == "96" ) {
			num = 0
		} else if ( c == "97" ) {
			num = 1
		} else if ( c == "98" ) {
			num = 2
		} else if ( c == "99" ) {
			num = 3
		}
		if ( num >= 0 ) {
			print("LOOPNUM = ",num)
			$.current_loopnum = num
			return()
		}
	}

	t = $.vizloop[$.current_loopnum]

	if ( ! keydown ) {
		return()
	}

	numbers = ["1"=1,"2"=1,"3"=1,"4"=1,"5"=1,"6"=1,"7"=1,"8"=1]
	if ( c in numbers ) {
		num = integer(c) - 1
		if ( $.shift ) { $.set_visuals(num); } else { t.set_sound(num);}
		return()
	}

	if ( c == "A" ) {
		$.setdefaultsA()
		print("SET DEFAULTS A")
		return()
	}
	if ( c == "B" ) {
		$.setdefaultsB()
		print("SET DEFAULTS B")
		return()
	}
	if ( c == "C" ) {
		if ( $.shift ) {
			print("CLEARING ALL LOOPS")
			$.all_loops("oneloop_clear",1)
		} else {
			print("CLEARING LOOPNUM ",$.current_loopnum)
			t.oneloop_clear(1)
		}
		return()
	}
	if ( c == "F" ) {
		if ( $.shift ) {
			t.adjustfadeout(-1)
			t.do_fade(1,0)
		} else {
			t.adjustfadeout(1)
			t.do_fade(1)
		}
		return()
	}
	if ( c == "S" ) {
		if ( $.shift ) {
			v = "on"
		} else {
			v = "off"
		}
		print("LOOPNUM ",$.current_loopnum," SCADJUST ",v)
		$.global_set("scadjust",v)
		return()
	}
	if ( c == "Q" ) {
		if ( $.shift && $.ctrl ) {
			q = 1b/2
		} else if ( $.shift ) {
			q = 1b/4
		} else if ( $.ctrl ) {
			q = 1b/8
		} else {
			q = 0
		}
		print("LOOPNUM ",$.current_loopnum," QUANT = ",q)
		$.perchan_set("quantrec",q,$.current_loopnum)
		$.perchan_set("quantreal",q,$.current_loopnum)
		return()
	}
	if ( c == "L" ) {
		if ( $.shift ) {
			$.change_global_loopleng(8b)
		} else {
			$.change_global_loopleng(16b)
		}
		return()
	}
	if ( c == "R" ) {
		# the recording button
		if ( $.shift ) {
			r = "off"
		} else {
			r = "on"
		}
		$.perchan_set("recording",r,$.current_loopnum)
		print("RECORDING is ",r," for loopnum ",$.current_loopnum)
		return()
	}

	if ( $.ctrl ) {
		if ( c in $.ctrl_list ) {
			# Call it afte we get the next character
			$.charproc = $.ctrl_list[c]
		}
		$.ignorenextup = c
		return()
	}

	if ( c == "END" ) {
		if ( keydown ) {
			print("Sending all-notes-off...")
			$.realano()
		}
		return()
	}	

	if ( keydown && c != "SHIFT")
		print("Ignoring char=",c)
	return()

}

method ctrl_exec(c,nw) {
	if ( c == "Q" ) {
		$.realano()
		$.quit = 1
	}
}

}


class vizloop_onelooper {

method init(parent,loopnum,stepsize,ch,vals,loopquant) {
	$.loopnum = loopnum
	$.parent = parent
	$.tid = -1
	$.stepsize = stepsize
	$.immediatefadeamount = 20
	$.immediate_fade = 0
	$.last_fade = 0
	$.transpose = 0
	$.stepnum = -1

	$.muted = 0
	$.soloed = 0
	$.unsoloed = 0

	$.chanparamchangemethod = [
		"loopleng"="change_loopleng",
		"volume"="set_volume"
		]
	$.paramnotice = [
		# "recording"=0,
		# "loopnotes"=0
		# "loopleng"=0,
		"soundset"=0
		]

	$.loopphrase = ''


	$.chanparam = []

	$.chanparam["channel"] = 1   # sigh
	$.chanparam["isdrum"] = 0   # sigh
	$.chanparam["loopleng"] = 8b   # sigh

	list = $.parent.get_perchanparamlist()
	# print("SETTING chanparams! list=",list," $.chanparam=",$.chanparam)

	for ( nm in list ) {
		# print("SETTING nm=",nm)
		if ( nm == "channel" ) {
			$.set_chanparam(nm,1)
		} else if ( nm == "isdrum" ) {
			$.set_chanparam(nm,0)
		} else {
			type = list[nm]
			v = $.parent.null_value_of_type(type)
			$.set_chanparam(nm,v)
		}
	}

	# print("CHANPARAM = ",$.chanparam)

	$.tp_loopstart = 0

	$.sustainwhiledown = 1
	$.lastplayedphr = []	# index is uid
	$.lastplayedtm = []	# index is uid
	$.lastplayedtid = []	# index is uid

	$.setloopphrase('')

	$.loopquant = loopquant
	$.vals = vals
	$.init_looptask(1)
	$.vals["loopxpose"] = 0
	$.centerp = 'p64'
}

method set_sound(v) {
	oldchan = $.get_currchan()
	$.set_chanparam("channel",v+1)
	$.realano(oldchan)
	print("LOOPNUM = ",$.loopnum," SOUND/CHAN=",$.get_currchan())
}

method adjustfadeout(inc) {
	# if inc is 1, fade faster, if -1, fade slower
	f = $.get_chanparam("fadeout")   # string value
	nf = ""
	for ( i in Fadeval ) {
		if ( f == Fadeval[i] ) {
			if ( (i+inc) in Fadeval ) {
				nf = Fadeval[i+inc]
				break;
			}
		}
	}
	if ( nf != "" ) {
		print("LOOPNUM ",$.loopnum," Setting fadeout to ",nf)
		$.set_chanparam("fadeout",nf)
	}
}

method setfade(val) {
	# print("SETFADE val=",val)
	if ( val in Fademap ) {
		$.set_chanparam("fadeout",val)
	}
}

method redrawblank() {
	p = ''
	row = Loop2Row[$.loopnum]
	part = Row2Part[row]
	color = BlackColor
	for ( c=1; c<GridLastCol; c++ ) {
		p += linnlight(row,c,color) + linnlight(row+1,c,color)
	}
	reallinn(p)
}

method redrawop() {
	$.redrawcol0()
	row = Loop2Row[$.loopnum]
	part = Row2Part[row]
	color = PartColor[part]
	p = ''
	for ( c=1; c<3; c++ ) {
		p += linnlight(row,c,color) + linnlight(row+1,c,color)
	}
	reallinn(p)
}

method redrawcol0() {
	f = $.get_chanparam("fadeout")
	# print("redrawcol0 loop=",$.loopnum," f=",f)
	if ( PerChanFadeout ) {
		fc = FadeColor[f]
	} else {
		fc = BlackColor
	}
	row = Loop2Row[$.loopnum]
	p = linnlight(row+1,0,RedColor) + linnlight(row,0,fc)
	reallinn(p)
}

method redraw() {

	$.redrawcol0()

	row = Loop2Row[$.loopnum]
	part = Row2Part[row]
	color = PartColor[part]
	p = ''
	for ( c=1; c<GridLastCol; c++ ) {
		p += linnlight(row,c,color) + linnlight(row+1,c,color)
	}
	reallinn(p)
}

method doop(operation,plus) {
	print("DOOP ",operation," ",plus)
	if ( operation == "VOLUME" ) {
		v = $.get_chanparam("volume")
		if ( plus ) {
			v += 10;
		} else {
			v -= 10;
		}
		if ( v > 127 ) { v = 127 } else if ( v < 0 ) { v = 0 }
		print("volume of loop ",$.loopnum," is now ",v)
		$.set_chanparam("volume",v)
		# $.set_volume()
	} else if ( operation == "SOLOMUTE" ) {
		if ( plus ) {
			# The SOLO (+) button has been used
			# the unsoloed value is so that 
			if ( $.soloed ) {
				$.parent.all_loops("set_soloed",0)
				$.parent.all_loops("set_unsoloed",0)
			} else {
				$.parent.all_loops("set_soloed",0)
				$.parent.all_loops("set_unsoloed",1)
				$.soloed = 1
				$.unsoloed = 0
			}
			print("loopnum=",$.loopnum,"  soloed=",$.soloed)
		} else {
			# The MUTE (0) button has been used
			print("MUTE loopnum=",$.loopnum)
			$.muted = !($.muted)
		}
	} else if ( operation == "FADE" ) {
		f = $.get_chanparam("fadeout")
		if ( plus ) {
			$.adjustfadeout(-1)
			$.do_fade(1,0)
		} else {
			$.adjustfadeout(1)
			$.do_fade(1)
		}
	} else if ( operation == "SHUFFLECOMB" ) {
		if ( plus ) {
			print("loopnum=",$.loopnum," do_shuffle")
			$.do_shuffle()
		} else {
			print("loopnum=",$.loopnum," do_comb")
			$.do_comb()
		}
	} else if ( operation == "CHANNEL" ) {
		ch = $.get_chanparam("channel")
		if ( plus ) {
			if ( ch < 8 ) {
				ch++
			}
		} else {
			if ( ch > 1 ) {
				ch--
			}
		}
		$.set_chanparam("channel",ch)
		print("loopnum=",$.loopnum," chan=",ch)
	} else if ( operation == "RANDADDDELETE" ) {
	} else if ( operation == "UNKNOWN1" ) {
	} else if ( operation == "UNKNOWN2" ) {
	} else {
		print("Unknown operation: "+operation)
	}
}

method set_unsoloed(v) {
	# print("unsoloed=",v," in loopnum=",$.loopnum)
	$.unsoloed = v
}
method set_soloed(v) {
	# print("soloed=",v," in loopnum=",$.loopnum)
	$.soloed = v
}

method set_volume() {
	# print("set_volume start")
	v = 16 * ( 1 + $.get_chanparam("volume") ) - 1
	ch = $.get_currchan()
	# Some synths pay attention to 0x0b, some to 0x07
	# Sending both is a hack, may need to be more selective
	# print("SET_VOLUME called loopnum=",$.loopnum," ch=",ch," v=",v)
	p = controller(ch,0x0b,v) + controller(ch,0x07,v)
	$.realtime(p,Now,0)
	# print("POST SET_VOLUME called loopnum=",$.loopnum," ch=",ch," v=",v)
}

method init_looptask(competely) {
	$.looptask_tid = -1
	if ( completely ) {
		$.looptask_clicks = -1
	}
}

method kill_looptasks(completely) {
	kill($.looptask_tid)
	if ( completely ) {
		kill($.looptask_clicks)
	}
}

method get_globalparam(nm) {
	return($.parent.get_globalparam(nm))
}

method get_lastplayedphr() {
	return($.lastplayedphr)
}

method get_currchan() {
	ch = $.get_chanparam("channel")
	return(ch)
}

method getvals() {
	print("HEY, getvalues shouldn't be called!")
	return([])
	return($.vals)
}

method start() {

	$.tid = task $.realtimetask()

	$.startdown = []
	$.selectdown = []
}

method stop {
	$.killrealtime()
}

method get_chanparam(nm) {
	if ( ! ( nm in $.chanparam ) ) {
		print("No value for nm=",nm," in $.chanparam!")
		return(0)
	}
	v = $.chanparam[nm]
	return(v)
}

method set_chanparam(nm,v) {

	# print("set_chanparam nm=",nm," v=",v,"  type=",typeof(v))
	# if ( ( nm in $.paramnotice) || DebugParam ) {
	# 	print("SETTING LOOPPARAM nm=",nm," lp=",$.loopnum," ch=",$.get_currchan()," v=",v)
	# }

	$.chanparam[nm] = v
	
	# print("set_chanparam MID nm=",nm," get_currchan=",$.get_currchan())
	if ( nm in $.chanparamchangemethod ) {
		m = $.chanparamchangemethod[nm]
		# print("Calling chanparamchangemethod on ",nm)
		$.(m)(nm,v)
	}
	# $.(nm) = v
	# print("set_chanparam END nm=",nm)
}

method change_loopleng(nm,newleng) {
	# print("CHANGING CHANNEL loopleng! loop=",$.loopnum," newleng=",newleng)
	oldleng = $.chanparam[nm]
	$.chanparam[nm] = newleng
	p = $.loopphrase
	p.length = oldleng

	# Force the looped phrase to be that length, but
	# either repeating or truncating it
	if ( p != '' ) {
		p = repleng(p,newleng)
	}
	p.length = newleng
	$.setloopphrase(p)
	# print("newp = ",p)
}

method realtimetask() {
	# print("STARTING realtimetask, tid=",gettid())
	tm = nextquant(Now,$.loopquant)
	checktime = 1b
	for ( ;; ) {
		t = Now

		while ( (Now+checktime) < (tm-2) ) {
			sleeptill(Now+checktime)
			# # If the loop has been cleared, reset
			# if ( $.tp_length == 0 ) {
			# 	tm = nextquant(Now,$.loopquant)
			# 	break
			# }
		}
		sleeptill(tm-1b/8)

		loopleng = $.get_chanparam("loopleng")

		# print("realtimetask ch=",$.get_currchan()," loopleng=",loopleng)

		# $.tp_length = loopleng

		if ( loopleng < 0) {
			print("Negative loop leng? ",loopleng)
			return()
		}

		if ( loopleng == 0 ) {
			print("loopleng is 0, skipping by loopquant=",$.loopquant)
			tm += $.loopquant
			continue
		}

		# There's a loop playing

		# If we've already established the length, keep track
		# of when each loop starts, so we know how to record new stuff
		if ( loopleng != 0 ) {
			# print("HEY!  length!=0 = ",loopleng," Setting loopstart to tm=",tm," me=",$," chan=",$.get_currchan())
			$.tp_loopstart = tm
		}

		$.play_loop(tm,loopleng)
		tm += loopleng
	}
	print("HEY, REALTIMETASK LOOP broke out?")
}

method current_port() {
	return( Synth[($.loopnum)%4] )
}

method play_loop(tm,loopleng) {

	if ( DoShowClick ) {
		$.looptask_clicks = task $.clicks_visualize(tm,$.loopnum,loopleng)
	}

	if ( $.loopphrase == '' ) {
		return()
	}

	# print("Play_loop called! loop=",$.loopnum," ismuted=",$.muted)
	thisloop = cut($.loopphrase,CUT_TIME,0,loopleng)

	ch = $.get_currchan()
	p = thisloop

	# playing_loop = $.get_chanparam("playloop")
	playing_loop = 1
	# print("CH = ",ch," playing_loop=",playing_loop)
	if ( sizeof(p) == 0 || ! playing_loop ) {
		return()
	}

	fade = Fademap[$.get_chanparam("fadeout")]
	if ( fade < 0 ) {
		fade = Fademap[$.get_globalparam("fadeout")]
	}
	if ( fade > 0 ) {
		$.loopphrase -= p
		p.vol -= (3 * fade)
		p -= p{??.vol==0}
		$.loopphrase |= p
		# print("faded p=",p)
		$.setloopphrase($.loopphrase)
	}

	if ( Now > tm ) {
		print("Falling behind! dt=",Now-tm)
	}

	# TRY WITHOUT
	p.port = $.current_port()

	# print("Calling phrase_play p=",p," loopnum=",$.loopnum)
	$.looptask_tid = task $.phrase_play(p,tm)

}

method realtime(p,tm,dovis) {
	if ( nargs() < 3 ) {
		print("WARNING, third argument not present in realtime!")
		dovis = 0
	}
	isdrum = $.get_chanparam("isdrum")
	if ( ! isdrum ) {
		p.pitch += $.transpose
	}
	p.port = $.current_port()
	# print("$.realtime loopnum=",$.loopnum," p=",p)
	t = realtime(p,tm)
	if ( MidiVizPort >= 0 ) {
		p.port = MidiVizPort
		# The channel sent to MidiVizPort indicates which
		# loop it's from, which is completely different
		# from the channel that gets sent to the synth
		p.chan = 1 + ($.loopnum%4)
		# print("Sending MidiVizPort p=",p)
		realtime(p,tm)
	}
	return(t)
}

method clicks_visualize(tm,loopnum,loopleng) {
	showfullclick = 0
	nsteps = loopleng / $.stepsize
	# print("STEPS_VISUALIZE tm=",tm," Now=",Now," loopnum=",loopnum," loopleng=",loopleng," stepsize=",$.stepsize," nsteps=",nsteps)
	col = 0
	row = Loop2Row[$.loopnum]

	fullclickon = linnlight(row,col,RedColor)+'l1'+linnlight(row+1,col,RedColor)
	fullclickoff = linnlight(row,col,BlackColor)+'l1'+linnlight(row+1,col,BlackColor)
	halfclickon = linnlight(row,col,RedColor)
	halfclickoff = linnlight(row,col,BlackColor)

	startn = 0
	clicktime = $.stepsize * 2
	if ( showfullclick ) {
		sleeptill(tm)
		reallinn(fullclickon)
		offtm = tm + clicktime/2
		sleeptill(offtm)
		reallinn(fullclickoff)
		startn = 1
	}

	for ( n=startn; n<nsteps; n++ ) {
		# Don't spawn a new task - we want to be able to kill this task

		tm += clicktime
		if ( (n%4) != 0 ) {
			continue
		}

		sleeptill(tm)
		reallinn(halfclickon)

		offtm = tm + clicktime/2
		sleeptill(offtm)
		reallinn(halfclickoff)
	}

}

method phrase_play(p,tm0) {

	$.immediate_fade = 0
	$.cumulative_quantnow = 0
	# print("=====phrase_play START loopnum=",$.loopnum," stepsize=",$.stepsize)

	for ( $.stepnum=0; $.stepnum<$.nsteps; $.stepnum++ ) {

		n = $.stepnum
		if ( ! (n in $.loopsteps) ) {
			continue
		}

		tm = tm0 + (n * $.stepsize)

		if ( ! $.soloed ) {
			if ( $.muted || $.unsoloed ) {
				sleeptill(tm)
				continue
			}
		}

		nt = $.loopsteps[n]  # could be multiple notes?
		if ( nt == '' ) {
			sleeptill(tm)
			continue
		}

		# print("phrase_play LOOP step=",n," nt=",nt," tm=",tm)

		# if ( sizeof(nt) > 1 ) {
		# 	# nt = nt % 1
		# 	print("HEY, loopstep n=",n," had more than 1 note!, is now ",nt)
		# }

		if ( $.cumulative_quantnow > 0 ) {
			tm = nextquant(tm,$.cumulative_quantnow)
			# print("phrase_play tm quantized = ",tm)
		} else {
			# print("phrase_play tm NOT quantized = ",tm)
		}

		playing_loop = $.get_chanparam("playloop")
		if ( ! playing_loop ) {
			sleeptill(tm)
			continue
		}

		trigable = $.get_chanparam("trigable")
		if ( trigable ) {
			trigger_global = $.get_globalparam("trigger%")
			trigger_chan = $.get_chanparam("trigger%")
			tp = integer(100.0 * (trigger_chan/100.0) * (trigger_global/100.0))

			if ( (tp < 100) && (rand(100) >= tp) ) {
				print("Omitting nt=",nt," in chan ",$.get_currchan())
				sleeptill(tm)
				continue
			}
		}
		if ( $.immediate_fade > 0 && $.should_fade() ) {
			nt = $.fade_phr(nt,$.immediate_fade)
			if ( nt == '' ) {
				sleeptill(tm)
				continue
			}
			# print("Changing nt for fade")
		}
		volvary = $.get_chanparam("volvary%")
		if ( volvary > 0 ) {
			nt = noise(nt,0,volvary,VOLUME)
			print("VOLVARY!!! nt is now",nt)
		}

		nt.time = 0
		dt = tm - Now

		ch = $.get_currchan()
		nt.chan = ch

		if ( DoVisualize ) {
			# print("DoVisualize of nt=",nt)
			if ( nt.type == NOTEON ) {
				task $.sendvisat(tm,nt,1)
			} else if ( nt.type == NOTEOFF ) {
				task $.sendvisat(tm,nt,0)
			} else if ( nt.type == NOTE ) {
				# Don't modify nt, since it's used later
				nt2 = nt
				nt2.type = NOTEON
				task $.sendvisat(tm,nt2,1)
				nt2.type = NOTEOFF
				task $.sendvisat(tm+nt2.dur,nt2,0)
			}
		}

		sleeptill(tm)
		# print("phrase_play loopnum=",$.loopnum," LOOP end nt=",nt," Now=",Now)
		$.realtime(nt,Now,0)
	}
	# print("=====phrase_play END get_currchan()=",$.get_currchan())
	$.stepnum = 0
}

method endvisat() {
	print("endvisat called")
}

method sendvisat(tm,phr,onoff) {
	result = ''
	row = Loop2Row[$.loopnum]
	ch = $.get_currchan()
	for ( nt in phr ) {
		g = outputnote2vizgridcell(nt,row,ch)
		if ( onoff ) {
			color = RedColor  # red
		} else {
			color = g.color()
		}
		# print("SENDVISAT tm=",tm," nt=",nt," rc=",g.rc()," color=",color)
		rc = g.rc()
		# row = rc["row"]
		col = rc["col"]
		result |= vizgridlight(row,col,color) + vizgridlight(row+1,col,color)
	}
	sleeptill(tm)
	# print("====   SENDVISAT tm=",tm," pitch=",nt.pitch," rc=",g.rc()," onoff=",onoff," color=",color)
	reallinn(result)
}

method resync() {
	p = $.loopphrase
	# print("Resync loopnum=",$.loopnum," stepnum=",$.stepnum)
}

method oneloop_clear(completely) {
	# print("oneloop_clear on loop ",$.loopnum," completely=",completely)
	$.stepnum = -1
	$.setloopphrase('')
	$.kill_looptasks(completely)
	$.init_looptask(completely)
	# print("Sending ANO on channel=",$.get_currchan())
	$.realano($.get_currchan())
	$.redraw()
}

method setloopphrase(p) {
	sz = sizeof(p)
	if ( sz > 200 ) {
		print("FILTERING LOOP RANDOMLY BY 2 !?!?  sizeof(p)=",sz)
		p = p{rand(2)==0}
	}
	$.loopphrase = p
	$.loopsteps = []
	$.nsteps = $.get_chanparam("loopleng") / $.stepsize
	# print("setloopphrase loopnum=",$.loopnum," p=",p)
	for ( n=0; n<$.nsteps; n++ ) {
		t1 = n * $.stepsize
		t2 = t1 + $.stepsize
		cp = cut(p,CUT_TIME,t1,t2-1)
		cp.time = 0
		cp.length = $.stepsize
		$.loopsteps[n] = cp
	}
}

method killrealtime() {
	# print("KILLREALTIME called")
	kill($.tid)
	$.tid = -1
	$.kill_looptasks(0)
	$.init_looptask(0)
}

method killall() {
	$.killrealtime()
	# Don't reset $.shiftisdown!
	# $.tp_length = $.get_chanparam("loopleng")
	print("TYPO_RESTART, loop=",$.loopnum)
	print("killall is setting loopstart to 0")
	$.tp_loopstart = 0
	$.setloopphrase('')
	$.tid = task $.realtimetask()
}

method nextinscale(p,sc) {
	p.pitch++
	p1 = p
	while ( p.pitch < 127 ) {
		if ( p in sc )
			return(p)
		p.pitch++
	}
	return(p1)
}

method apply_mods(p) {

	if ( p == '' ) {
		print("Hmmmm *********** apply_mods called on p=",p)
		return('')
	}
	if ( typeof(p) != "phrase") {
		print("Non phrase (",p,") given to apply_mods...")
		return('')
	}

	p.chan = $.get_currchan()
	# print("apply_mods setting p.chan=",p.chan)

	if ( $.vals["longdur"] ) {
		p.dur *= 2
	}

	return(p)
}

### method force_length_16b() { $.force_length(16b) }
### 
### method inc_length(factor) {
### 	$.set_length($.tp_length*2.0)
### }
### method dec_length(factor) {
### 	$.set_length($.tp_length/2.0)
### }
### method get_length() {
### 	return($.tp_length)
### }
### 
### method set_length(newleng) {
### 	print("SETTING length of loop ",$.loopnum,"to",newleng)
### 
### 	# print("old leng=",$.tp_length," phrase=",$.loopphrase)
### 	p = $.loopphrase
### 	oldleng = $.tp_length
### 	p.length = oldleng
### 	$.tp_length = newleng
### 
### 	# Force the looped phrase to be that length, but
### 	# either repeating or truncating it
### 	if ( newleng > oldleng ) {
### 		# Don't repeat it blindly, vary it
### 		p = p + shuffle(p)
### 	}
### 	p = repleng(p,newleng)
### 	p.length = newleng
### 	$.setloopphrase(p)
### 	# print("   new leng=",$.tp_length," phrase=",$.loopphrase)
### }
### 
### method set_loop_length(nw) {
### 	print("SET_LOOP_LENGTH, nw=",nw)
### 	if ( $.tp_length == 0 ) {
### 		print("typo set_loop_length called, SETTING LENGTH, loopstart=",$.tp_loopstart,"  chan=",$.currchan)
### 		if ( $.loopphrase == '' ) {
### 			print("Nothing in loopphrase, so ignoring set_loop_length");
### 			return()
### 		}
### 		lng = nw - $.tp_loopstart
### 		lq = nextquant(lng,$.loopquant)
### 		if ( (lq - lng) > ($.loopquant/2) ) {
### 			# play_loop(tm)
### 			lq -= $.loopquant
### 		}
### 		if ( lq < 0 ) {
### 			print("lq<0 ? lq=",lq," $.tp[loopstart]=",$.tp_loopstart,"  nw=",nw,"  lng=",lng)
### 			lq = $.loopquant
### 			print("Forcing lq to ",lq)
### 		}
### 		$.tp_length = lq
### 		ls = prevquant(nw,lq)
### 		if ( ls != $.tp_loopstart ) {
### 			# If we've already passed what should
### 			# really be the start of the first
### 			# iteration of the loop, we should
### 			# play the loop right away,
### 			# so there's not a blank space
### 			t2 = $.tp_loopstart + $.tp_length
### 			$.play_loop(t2,loopleng)
### 			# $.playprev = t2
### 		}
### 
### 		print("SET_LOOP_LENGTH setting loopstart to ls=",ls)
### 		$.tp_loopstart = ls
### 		print("LOOP LENGTH set to ",lq," ( ",lq/1b," beats )")
### 
### 	}
### }

method is_recording() {
	return($.get_chanparam("recording"))
}
method is_playloop() {
	return($.get_chanparam("playloop"))
}

method is_muted() {
	return($.muted)
}
method set_muted(onoff) {
	$.muted = onoff
}

method looper_input_pq(keydown,p,prox,uid,reallymidi,qnt) {

	nw = nextquant(Now,qnt)
	# print("input_p  p=",p," qnt=",qnt," nw=",nw)

	# print("LOOPER_INPUT_PQ p=",p," qnt=",qnt," keydown=",keydown," nw=",nw)

	isrecording = $.is_recording() && $.is_playloop()

	if ( keydown == 1 ) {

		# key just went down

		# If we're recording, we set
		# the start of the loop if it's not set already

		# print("keydown, loopstart=",$.tp_loopstart)

		if ( isrecording && ($.tp_loopstart == 0) ) {
			nq = prevquant(nw,$.loopquant)
			$.tp_loopstart = nq
			# print("STARTING LOOOP!!  loopstart/nq=",nq," p=",p)
		}
		# When the key goes down, we just play it.
		# It doesn't get added to the loop until it's let up.

		if ( typeof(p) != "phrase" ) {
			print("Hmmm, p isn't a phrase at XX1a?")
			return()
		}
		# print("preapply p=",p," prox=",prox," uid=",uid)
		if ( p == '' ) {
			print("NULL phrase before apply_mods?")
			return()
		}

		p = $.apply_mods(p)
		# print("p after mods = ",p)
		if ( typeof(p) != "phrase" ) {
			print("Hmmm, p isn't a phrase at XX1b?")
			return()
		}
		if ( p == '' ) {
			return()
		}

		if ( typeof(p) != "phrase" ) {
			print("Hmmm, p isn't a phrase at XX2?")
			return()
		}

		# Assumes loopMIDI ports 1 to 4 are set up
		p.port = $.current_port()

		$.lastplayedphr[uid] = p
		if ( $.sustainwhiledown ) {
			p.type = NOTEON
		}

		# print("playing D p=",p," nw=",nw)
		$.lastplayedtid[uid] = $.realtime(p,nw,1)
		$.lastplayedtm[uid] = nw
		return()
	}

	if ( ! (uid in $.lastplayedphr) ) {
		print("Hey, uid=",uid," is not in lastplayedphr?")
		return()
	}

	p = $.lastplayedphr[uid]
	# print("p from lastplayed uid=",uid," p=",p)
	lastdown = $.lastplayedtm[uid]

	killonup = $.vals["killonup"]
	if ( reallymidi == 0 && killonup ) {
		# print("Killing on up, delayed")
		$.kill_later($.lastplayedtid[uid],Now+1b/8)
	}

	if ( keydown == 0 ) {
		delete $.lastplayedphr[uid]
		delete $.lastplayedtm[uid]
		delete $.lastplayedtid[uid]
	}

	# print("p=",p,"  isrecording = ",isrecording)
	if ( ! isrecording ) {
		# We're NOT recording
		# p.time = 0
		if ( killonup == 0 || $.sustainwhiledown ) {
			if ( nw == lastdown ) {
				# print("Adding a bit of time to noteoff?")
				nw += qnt/2
			}
			if ( killonup ) {
				p.time = 0
			}
			p.type = NOTEOFF
			# print("Playing B realtime p=",p," nw=",nw)
			$.realtime(p,nw,1)
		}
		return()
	}
	# We ARE recording

	# Realtime - timing of notes gets used

	d = nw-lastdown

	# print("LOOPING on keyup, p=",p," d=",d)

	newp = ''
	p.type = NOTE
	for ( tmpnt in p ) {
		if ( (tmpnt.time + tmpnt.dur) < d ) {
			tmpnt.dur = d - tmpnt.time
		} 
		newp |= tmpnt
	}
	p = newp
	# print("NEW p = ",p)

	tmpdt = lastdown - $.tp_loopstart
	while ( tmpdt < 0 ) {
		# print("Adding loopleng to tmpdt !?")
		tmpdt += $.get_chanparam("loopleng")
	}

	if ( reallymidi==0 && killonup ) {
		killdt = Now-lastdown
		p1 = cut(p,CUT_TIME,0,killdt,TRUNCATE)
		# print("Truncated recorded killdt=",killdt," p1=",p1)
	} else {
		p1 = p
	}
	# print("p1=",p1)
	p1.time += nextquant(tmpdt,qnt)
	if ( p1.time <= lastdown ) {
		nw += qnt/2
	}
	d = nw-lastdown
	if ( d <= 0 )
		d = 1
	nextq = nextquant(d,qnt)
	p1.length = nextq

	# print("ADDING $=",$," p1=",p1," TO LOOP!!! chan=",$.get_currchan())

	if ( p1.dur == 0 ) {
		p1.dur = 6
		# print("dur==0, seet to ",p1.dur)
	}

	lim = $.get_chanparam("loopnotes")
	if ( sizeof($.loopphrase) > lim ) {
		before = sizeof($.loopphrase)
		minvol = minvolume($.loopphrase)
		toremove = $.loopphrase { ??.vol <= minvol }
		pp = $.loopphrase - head(toremove,3)
		$.setloopphrase(pp)
		# print("loopnotes cut down lim=",lim," size was =",before," now=",sizeof($.loopphrase))
	}
	p2 = $.loopphrase | p1

	p2 = dedup(p2)
	$.setloopphrase(p2)

	# p.time = 0
	p.type = NOTEOFF
	
	$.realtime(p,nw,1)
	# print("playing C p=",p," nw=",nw)
}

method kill_later(tid,tm) {
	# print("kill_later tid=",tid)
	sleeptill(tm)
	kill(tid)
}

method realano(ch) {
	if ( nargs() > 0 )
		p = ano(ch)
	else
		p = ano()
	p.port = $.current_port()
	realtime(p)
}

method fade_phr(p,fv) {
	p.vol -= fv
	p -= p{??.vol==0}
	# print("fade_phr returns p=",p)
	return(p)
}

method should_fade() {
	isdrum = $.get_chanparam("isdrum")
	drumfade = $.get_globalparam("drumfade")
	if ( !isdrum || drumfade )
		return(1)
	else
		return(0)
}

method do_fade(ischan,down) {
	if ( nargs() < 1 )
		ischan = 0
	if ( nargs() < 2 )
		down = 1

	if ( down && ((Now - $.last_fade) < milliclicks(250)) ) {
		print("MULTIPLE FADES IN < .25 secs, CLEARING!")
		$.oneloop_clear(0)
		return()
	}
		
	if ( $.loopphrase != '' ) {
		if ( down ) {
			immfade = $.immediatefadeamount
		} else {
			immfade = - $.immediatefadeamount
		}
		# print("immfade = ",immfade)
		if ( ischan || $.should_fade() ) {
			$.immediate_fade += immfade
			$.setloopphrase($.fade_phr($.loopphrase,immfade))
			# print("loopphrase is now ",$.loopphrase)
		}
	}
	$.last_fade = Now
}

method do_comb() {
	if ( $.loopphrase != '' ) {
		p = $.loopphrase
		onbeat = p{isnearbeat(??,1b/2,0)}
		poff = p - onbeat
		sz = sizeof(poff)
		# if no notes are off the beat, start removing those
		if ( sz == 0 ) {
			onbeat = onbeat{rand(2)==0}
			$.setloopphrase(onbeat)
			return()
		}
		# if only a new notes are left off the beat, remove them all
		if ( sz <= 3 ) {
			$.setloopphrase(onbeat)
			return()
		}
		# Filter the off-beat notes and add them back 
		poff = poff{rand(2)==0}
		onbeat |= poff
		$.setloopphrase(onbeat)
	}
}

method do_shuffle() {
	if ( $.loopphrase != '' ) {
		$.setloopphrase(shuffle($.loopphrase))
	}
}

method do_quantnow(ch) {
	if ( $.loopphrase != '' ) {
		p = $.loopphrase
		q = $.get_chanparam("quantnowv")
		$.cumulative_quantnow = q
		$.setloopphrase(quantize($.loopphrase,q))
	}
}

method set_transpose(val) {
	isdrum = $.get_chanparam("isdrum")
	if ( ! isdrum ) {
		$.transpose = val
	}
}

}

function vizloop_resetconsole(o) {
	o.stop()
}

function vizloop_midi_restart(o) {
	o.midi_restart()
}

