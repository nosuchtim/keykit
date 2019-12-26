#********************************************************************

#	WCHORDMEH
#	by
#	Mehmet Okonsar
#	mokonsar@dominet.in.com.tr
#	Extension of the tool "Chord Palette" by Tim Thompson
#	New chords created from the book serie 
#	"Contemporary Stiles for the Jazz Pianist" by John Mehegan
#	USAGE:
#	To be able to use this as well as its complementary tools:
#	wchordmeh and wchordsMes the function function chord(root,typ,oct)
#	file basic1.k at the lib directory should be updated as :
#
#function chord(root,typ,oct) {
#	charr = [
#		"major"='p0 p4 p7',
#		"minor"='p0 p3 p7',
#		"maj7"='p0 p4 p7 p11',
#		"min7"='p0 p3 p7 p10',
#		"maj9"='p0 p4 p7 p11 p14',
#		"min9"='p0 p3 p7 p10 p14',
#		"sus"='p0 p5 p7',
#		"dim"='p0 p3 p6',
#		"aug"='p0 p4 p8',
#		"Maj69"='p0 p4 p7 p9',
#		"MajB769"='p0 p3 p5 p9 p10',
#		"HalfDim"='p0 p3 p6 p10',
#		"Dim9"='p0 p3 p6 p9 p14',
#		"NModMaj1"='p0 p1 p4 p8',
#		"NModMaj2"='p0 p4 p6 p9',
#		"NModMaj3"='p0 p1 p3 p6',	
#		"NModDom1"='p0 p1 p4 p7',	
#		"NModDom2"='p0 p1 p4 p6',
#		"NModDom3"='p0 p2 p6 p8',
#		"NModDom4"='p0 p5 p8 p11',
#		"ArtDim"='p0 p2 p5 p8',
#		"AOVoic1"='p0 p7 p10 p12 p17',
#		"AOVoic2"='p0 p1 p7 p12 p17',
#		"AllMaj"='p0 p2 p5 p7 p11 p16 p21',
#		"Res"='p0 p4 p7 p10 p14 p17 p20 p23',
#		"Vitr1"='p0 p3 p6 p8 p14 p16 p19 p22',
#		"Vitr2"='p0 p3 p5 p9 p13 p16 p19 p23',
#		"Fourths"='p0 p6 p11 p17 p22 p28',
#		"Pr1"='p0 p2 p3 p5 p7 p11',
#		"Pr2"='p0 p3 p5 p7 p11 p13',
#		"Pr3"='p0 p5 p7 p11 p13 p14',
#		"Pr4"='p0 p3 p5 p7 p11 p14 p17']
#	if ( ! (typ in charr) ) {
#		print("chord(): unrecognized chord type - ",typ)
#		return('')
#	}
#	ch = charr[typ]
#	ch.pitch += root.pitch
#	return(ch)
#}
#
#	copy and paste the above lines (do not forget to throw away the 
#	#'s!)

#*********************************************************************
class wchordMeh {

method init {
	$.w = new window()
	$.inherit($.w)

	$.b1 = new kmenubutton("More","mkmenu_chpal1",$)
	$.addchild($.b1)

	$.keys = [0="C",1="C#",2="D",3="D#",4="E",5="F",
		6="F#",7="G",8="G#",9="A",10="A#",11="B"]
	$.chordtypes = [0="Maj69",1="MajB769",2="HalfDim",3="Dim9",4="NModMaj1",
		5="NModMaj2",6="NModMaj3",7="NModDom1",8="NModDom2",9="NModDom3",
		10="NModDom4",11="ArtDim",12="AOVoic1",13="AOVoic2"]
	$.nkeys = sizeof($.keys)
	$.ntypes = sizeof($.chordtypes)
	$.xstart = []
	$.ystart = []
	$.currkey = -1
	$.currtype = -1
	$.octave = 3
	$.mode = "both"
	$.on = 0
}
method setoctave (oct) { $.octave = oct }
method setmode (mode) { $.mode = mode }
method seton (on) { $.on = on }
method redraw {
	$.w.redraw()
	x0 = $.xmin()
	x1 = $.xmax()
	y0 = $.ymin()
	y1 = $.ymax()
	x0b = $.xmin() + ($.xmax()-$.xmin())/3
	# chord names
	for ( n=0; n<$.ntypes; n++ ) {
		$.text($.chordtypes[n],xy(x0,$.ystart[n],x0b,$.ystart[n+1]))
		$.line(xy(x0,$.ystart[n],x1,$.ystart[n]))
	}
	# beat numbers
	for ( n=0; n<$.nkeys; n++ ) {
		$.text($.keys[n],xy($.xstart[n],y0,$.xstart[n+1],$.ystart[0]))
		$.line(xy($.xstart[n],y0,$.xstart[n],y1))
	}
	if ( $.currkey >=0 && $.currtype >= 0 )
		$.fill($.currkey,$.currtype,STORE)
	methodbroadcast()
}

method fill(sn,dn,mode) {
	x0 = $.xstart[sn]+1
	y0 = $.ystart[dn]+1
	x1 = $.xstart[sn+1]-1
	y1 = $.ystart[dn+1]-1
	$.w.fillrectangle(xy(x0,y0,x1,y1),mode)
}

method mousedown(m) {
	x = m["x"]
	y = m["y"]
	if ( y < $.ystart[0] || x < $.xstart[0] ) {
		mouseforward(m,"mousedown")
		return()
	}
	for ( dn=0; dn<$.ntypes; dn++ ) {
		if ( y < $.ystart[dn+1] )
			break;
	}
	if ( dn<$.ntypes ) {
		for ( sn=0; sn<$.nkeys; sn++ ) {
			if ( x < $.xstart[sn+1] ) {
				# erase old one
				if ( $.currkey >=0 && $.currtype >= 0 )
					$.fill($.currkey,$.currtype,CLEAR)
				$.currkey = sn
				$.currtype = dn
				$.fill(sn,dn,STORE)
				arr = ["C"='c',"C#"='c+',"D"='d',
					"D#"='d+',"E"='e',"F"='f',
					"F#"='f+',"G"='g',"G#"='g+',
					"A"='a',"A#"='a+',"B"='b']
				kname = $.keys[sn]
				knote = arr[kname]
				t = $.chordtypes[dn]
				knote.pitch += ($.octave-3)*12
				ch = chord(knote,t)
				if ( $.mode=="play" || $.mode=="both")
					realmidi(ch)
				if ( $.mode=="snarf" || $.mode=="both")
					setsnarf(ch,kname+" "+t)
				return()
			}
		}
	}
	mouseforward(m,"mousedown")
}

method clear() {
	for ( sn=0; sn<$.nkeys; sn++ ) {
		for ( dn=0; dn<$.ntypes; dn++ )
			$.cell[sn][dn] = 0
	}
	$.redraw()
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	x0 = $.xmin()
	y0 = $.ymin()
	x1 = $.xmax()
	y1 = $.ymax()
	x0b = $.xmin() + ($.xmax()-$.xmin())/3
	ty = $.textheight() + 4

	for ( sn=0; sn<=$.nkeys; sn++ )
		$.xstart[sn] = x0b+(sn*(x1-x0b))/$.nkeys
	for ( dn=0; dn<=$.ntypes; dn++ )
		$.ystart[dn] = y0 + ty + (dn*(y1-y0-ty))/$.ntypes

	$.b1.resize(xy(x0+1,y0+1,$.xstart[0]-1,$.ystart[0]-1))
}
}

function mkmenu_chpal1(o,...) {
	o.submenu("Mode   ->","mkmenu_chpalmode",...)
	o.submenu("Octave ->","mkmenu_chpaloct",...)
}

function mkmenu_chpalmode(o,po) {
	o.menucmd("Play",po,"setmode","play")
	o.menucmd("Snarf",po,"setmode","snarf")
	o.menucmd("Both",po,"setmode","both")
}

function mkmenu_chpaloct(o,po) {
	for ( n = -1; n<8; n++ )
		o.menucmd(string(n),po,"setoctave",n)
}



