# GIF Jam
# Take an image (in pnm format), scan the pixels in a variety of
# ways, and use the RGB values to produce music.

function gifjam(fname,xval,yval,scantype,redrange,greenrange,bluerange) {

	inc = 1b/4
	Note1 = 'a'
	Note1.dur = inc
	Note1.length = inc
	Rest1 = 'r'
	Rest1.length = inc

	Maxval = 0
	if ( readpnm(fname) != 0 ) {
		print("Unrecognized file format");
		return()
	}
	Nrows = sizeof(CellR);
	Ncols = sizeof(CellR[0]);
	# print("ranges=",redrange,greenrange,bluerange);

	RedRange = getrange(redrange);
	GreenRange = getrange(greenrange);
	BlueRange = getrange(bluerange);

	# print("Nrows=",Nrows," Ncols=",Ncols);
	# print("xval=",xval," yval=",yval);
	y = integer(yval) * Nrows / 150
	x = integer(xval) * Ncols / 300

	NotesR = ''
	NotesG = ''
	NotesB = ''

	if ( scantype ~~ "Scan 3.*" ) {
		scanline(y) ; scanline(y+3) ; scanline(y+6)
	}
	else if ( scantype ~~ "Scan 1.*" ) {
		scanline(y)
	}
	else if ( scantype ~~ "Scan 6.*" ) {
		scanline(y) ; scanline(y+2) ; scanline(y+4)
		scanline(y+6) ; scanline(y+8) ; scanline(y+10)
	}
	else if ( scantype ~~ "Spiral.*" ) {
		spiralout(1024,x,y)
	}
	else if ( scantype ~~ "Four.*" ) {
		spiralout(1024,x,y)
	}
	else {
		print("Unrecognized scan type: ",scantype)
	}

	if ( typeof(RedRange) == "array" ) {
		NotesR.chan = 1;
		NotesR = scadjust(NotesR,transpose(scale_dorian(),'a'));
	}
	NotesR = NotesR{ rand(2)==0 };

	if ( typeof(GreenRange) == "array" ) {
		NotesG.chan = 2;
		NotesG = scadjust(NotesG,transpose(scale_dorian(),'a'));
	}
	NotesG = NotesG{ rand(2)==0 }

	if ( typeof(BlueRange) == "array" ) {
		NotesB.chan = 3;
		NotesB = scadjust(NotesB,transpose(scale_dorian(),'a'));
	}
	NotesB = NotesB{ rand(2)==0 }

	p = (NotesR | NotesG | NotesB)
	p = p | makerootevery(p{??.chan!=10},2b)

	writemf(p,"www.mid")
	writelines(p,"www.lines")
}

function getrange(range) {
	r = []
	if ( range ~~ "High .*" ) {
		r["high"] = 110
		r["low"] = 70
	}
	else if ( range ~~ "Medium-High .*" ) {
		r["high"] = 100
		r["low"] = 60
	}
	else if ( range ~~ "Medium .*" ) {
		r["high"] = 90
		r["low"] = 50
	}
	else if ( range ~~ "Medium-Low .*" ) {
		r["high"] = 80
		r["low"] = 40
	}
	else if ( range ~~ "Low .*" ) {
		r["high"] = 70
		r["low"] = 30
	}
	else if ( range ~~ "None.*" ) {
		return(-1)
	}
	else if ( range ~~ "Drums.*" ) {
		return(-2)
	}
	else if ( range ~~ "Chords.*" ) {
		return(-3)
	}
	r["span"] = r["high"] - r["low"]
	return(r)
}

function spiralout(nnts,x,y) {

	p = ''
	oy = y;
	dx = 1
	dxdir = -1
	dy = 0
	dydir = 1
	ndx = 0
	ndy = 0
	ndxsofar = 0
	ndysofar = 0
	for ( n=0; n<nnts; n++) {

		if ( x<0 || y<0 || x>=Ncols || y>=Nrows )
			break;

		usecell(y,x)

		x += dx
		y += dy

		if ( ++ndxsofar > ndx ) {
			ndxsofar = 0;
			if ( dx == 0 ) {
				dx = 1 * dxdir
				dy = 0
				dxdir = -dxdir
				ndx++
			}
			else {
				dx = 0
				dy = 1 * -dxdir
			}
		}
	}
	return(p)
}

function scanline(y) {
	for ( x=0; x<Ncols; x++ ) {
		usecell(y,x)
	}
}

Drums = [0=35,1=36,2=37,3=38,4=39,5=41,6=42,7=46,8=47,
	9=48,10=50,11=53,12=54,13=56,14=60,15=61,16=62,17=63]
Chords = [0='c e g',1='f a c',2='d f+ a',3='g b d',4='a c+ e']

function usecell(y,x) {

	v = (CellR[y][x])
	if ( v != 0 && v != Maxval ) {
		if ( typeof(RedRange) == "array" ) {
			v2 = v * RedRange["span"] / (Maxval)
			Note1.pitch = v2 + RedRange["low"]
			NotesR += Note1
		}
		else if ( RedRange == -2 ) {
			Note1.pitch = Drums[v%sizeof(Drums)]
			Note1.chan = 10
			NotesR += Note1
		}
		else if ( RedRange == -3 ) {
			ch = Chords[v%sizeof(Chords)]
			ch.dur = Note1.dur
			ch.length = Note1.length
			NotesR += ch
		}
	}
	else {
		NotesR += Rest1
	}

	v = (CellG[y][x])
	if ( v != 0 && v != Maxval ) {
		if ( typeof(GreenRange) == "array" ) {
			v2 = v * GreenRange["span"] / (Maxval)
			Note1.pitch = v2 + GreenRange["low"]
			NotesG += Note1
		}
		else if ( GreenRange == -2 ) {
			Note1.pitch = Drums[v%sizeof(Drums)]
			Note1.chan = 10
			NotesG += Note1
		}
	}
	else {
		NotesG += Rest1
	}

	v = (CellB[y][x])
	if ( v != 0 && v != Maxval ) {
		if ( typeof(BlueRange) == "array" ) {
			v2 = v * BlueRange["span"] / (Maxval)
			Note1.pitch = v2 + BlueRange["low"]
			NotesB += Note1
		}
		else if ( BlueRange == -2 ) {
			Note1.pitch = Drums[v%sizeof(Drums)]
			Note1.chan = 10
			NotesB += Note1
		}
	}
	else {
		NotesG += Rest1
	}
}

