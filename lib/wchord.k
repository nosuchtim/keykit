class wchord {

method init {
	$.w = new window()
	$.inherit($.w)

	$.b1 = new kmenubutton("More","mkmenu_chpal1",$)
	$.addchild($.b1)

	$.keys = [0="C",1="C#",2="D",3="D#",4="E",5="F",
		6="F#",7="G",8="G#",9="A",10="A#",11="B"]

	$.chords = [
		0=["name"="major","type"="basic"],
		1=["name"="minor","type"="basic"],
		2=["name"="maj7","type"="basic"],
		3=["name"="min7","type"="basic"],
		4=["name"="maj9","type"="basic"],
		5=["name"="min9","type"="basic"],
		6=["name"="sus","type"="basic"],
		7=["name"="dim","type"="basic"],
		8=["name"="aug","type"="basic"],
		9=["name"="Maj69","type"="jazz"],
		10=["name"="MajB769","type"="jazz"],
		11=["name"="HalfDim","type"="jazz"],
		12=["name"="Dim9","type"="jazz"],
		13=["name"="NModMaj1","type"="jazz"],
		14=["name"="NModMaj2","type"="jazz"],
		15=["name"="NModMaj3","type"="jazz"],
		16=["name"="NModDom1","type"="jazz"],
		17=["name"="NModDom2","type"="jazz"],
		18=["name"="NModDom3","type"="jazz"],
		19=["name"="NModDom4","type"="jazz"],
		20=["name"="ArtDim","type"="jazz"],
		21=["name"="AOVoic1","type"="jazz"],
		22=["name"="AOVoic2","type"="jazz"],
		23=["name"="AllMaj","type"="messiaen"],
		24=["name"="Res","type"="messiaen"],
		25=["name"="Vitr1","type"="messiaen"],
		26=["name"="Vitr2","type"="messiaen"],
		27=["name"="Fourths","type"="messiaen"],
		28=["name"="Pr1","type"="prime"],
		29=["name"="Pr2","type"="prime"],
		30=["name"="Pr3","type"="prime"],
		31=["name"="Pr4","type"="prime"]
	]
	$.lastplay = ''
	$.nkeys = sizeof($.keys)
	$.xstart = []
	$.ystart = []
	$.octave = 3
	$.mode = "both"
	$.on = 0
	$.ch = 1
	$.setchords("basic")
}
method setchords(t,doredraw) {
	$.chordtypes = []
	cn = 0
	nchords = sizeof($.chords)
	for ( n=0; n<nchords; n++ ) {
		if ( t == "all" || t == $.chords[n]["type"] ) {
			$.chordtypes[cn++] = $.chords[n]["name"]
		}
	}
	$.ntypes = sizeof($.chordtypes)
	$.currkey = -1
	$.currtype = -1
	if ( nargs() > 1 && doredraw != 0 ) {
		$.resize();
		$.redraw();
	}
}
method setchannel (ch) { $.ch = ch }
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
				ch.chan = $.ch
				if ( $.mode=="play" || $.mode=="both")
					$.playthis(ch)
				if ( $.mode=="silentsnarf" || $.mode=="snarf" || $.mode=="both")
					setsnarf(ch,kname+" "+t)
				return()
			}
		}
	}
	mouseforward(m,"mousedown")
}
method get {
	return($.lastplay)
}
method playthis(p) {
	realmidi(p)
	$.lastplay = p
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
	o.submenu("Chords ->","mkmenu_chpalchords",...)
	o.submenu("Mode   ->","mkmenu_chpalmode",...)
	o.submenu("Octave ->","mkmenu_chpaloct",...)
	o.submenu("Chan   ->","mkmenu_chpalchan",...)
}

function mkmenu_chpalchords(o,po) {
	o.menucmd("Basic",po,"setchords","basic",1)
	o.menucmd("Jazz",po,"setchords","jazz",1)
	o.menucmd("Messiaen",po,"setchords","messiaen",1)
	o.menucmd("Prime",po,"setchords","prime",1)
	o.menucmd("All",po,"setchords","all",1)
}

function mkmenu_chpalmode(o,po) {
	o.menucmd("Play",po,"setmode","play")
	o.menucmd("Snarf",po,"setmode","snarf")
	o.menucmd("Silent Snarf",po,"setmode","silentsnarf")
	o.menucmd("Both",po,"setmode","both")
}

function mkmenu_chpaloct(o,po) {
	for ( n = -1; n<8; n++ )
		o.menucmd(string(n),po,"setoctave",n)
}
function mkmenu_chpalchan(o,po) {
	for ( n = 1; n<=16; n++ )
		o.menucmd(string(n),po,"setchannel",n)
}

