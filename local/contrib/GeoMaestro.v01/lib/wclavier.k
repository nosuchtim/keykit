

#########################################################################################

class wclavier {

method init {
	$.w = new window()
	$.inherit($.w)

	InitLiveAC()

	$.piano = new wpiano()
	$.addchild($.piano)

	$.message = "Clavier & Palette"

	$.cname = []
	for (i=0; i<16; i++) $.cname[i]="c"+string(i+1)
	$.c = []

	$.octaves = []
	for (i=0; i<=8; i++) $.octaves[i]="o"+string(i-2)	
	$.oc = []	
	$.kbpara = []
	for ( n=1; n<=5; n++ ) {
		$.c[n] = new kvalbutton($.cname,$,"setchan",n)
		$.addchild($.c[n])
		$.c[n].set($.piano.dump()["ch"][n]-1)
		
		$.oc[n] = new kvalbutton($.octaves,$,"setoct",n)
		$.addchild($.oc[n])
		$.oc[n].set($.piano.dump()["oct"][n]+2)

		$.kbpara[n] = new kbutton(textfunc("vd?"), $, "setparas", n)
		$.addchild($.kbpara[n])
	}

	$.kb = new kbutton(textfunc(GMblah_clavier4), $, "ecoutekb")
	$.addchild($.kb)

	$.volu = 63
	$.ksvol = new kslider(0,127,$.volu,$,"setvolume")
	$.addchild($.ksvol)

	$.duree = 1b
	$.ksdur = new kslider(0,10b,$.duree,$,"setduree")
	$.addchild($.ksdur)

}

method dump()
{
	st = ["c"=[], "oc"=[]]
	
	st["piano"] = $.piano.dump()
	st["message"] = $.message
	st["volu"] = $.volu
	st["duree"] = $.duree
	for (n=1; n<=5; n++)
	{
	    st["c"][n] = ($.c[n].dump())["n"]
	    st["oc"][n] = ($.oc[n].dump())["n"]
	}

	return (st)
}

method restore(st)
{
	$.message = st["message"]
	$.piano.restore(st["piano"])
	$.volu = st["volu"]
	$.duree = st["duree"]
	for (n=1; n<=5; n++)
	{
	    $.c[n].set(st["c"][n])
	    $.oc[n].set(st["oc"][n])
	}

}

method ecoutekb {
       task $.piano.kbmode()
}

method setchan(v, n) {
       $.piano.setchan(v+1,n)
}

method setoct(v, n) {
       $.piano.setoct(v-2, n)
}

method setvolume(v) {
       $.piano.setvolume(v)
}

method setduree(v) {
       $.piano.setduree(v)
}

method setparas(n) {
       $.piano.setparas(n)
}

method redraw  {
	$.w.redraw()

	th = $.textheight()
	tw = $.textwidth()
	y0 = $.ymin() ; y1 = y0+th+4 
	x0 = $.xmin() ; x1 = $.xmax()-10*tw
	$.text($.message,xy(x0,y0,x1,y1))

	htouch = ($.ymax()-$.ymin()-th)*0.2
	$.text("d",xy($.xmax()-4*tw,$.ymin()+2*htouch+th,$.xmax(),$.ymin()+2*htouch+2*th))
	$.text("v",xy($.xmax()-4*tw,$.ymin()+3*htouch,$.xmax(),$.ymin()+3*htouch+th))

	methodbroadcast()
}

method resize (sz) { 

	th = $.textheight()
	tw = $.textwidth()

        if ( nargs() > 0 ) 
	{
		sz["y1"] = Maximum(sz["y1"], 208)
                $.w.resize(sz) 
	}	

	$.piano.resize(xy(5*tw+$.xmin(),$.ymin()+th,$.xmax()-4*tw,$.ymax()))

	htouch = ($.ymax()-$.ymin()-th)*0.2

	for ( n=1; n<=5; n++ ) {
		$.c[n].resize(xy($.xmin(),$.ymin()+(n-1)*htouch+th,$.xmin()+5*tw,$.ymin()+(n-1)*htouch+2*th))
		$.oc[n].resize(xy($.xmin(),$.ymin()+(n-1)*htouch+2*th,$.xmin()+5*tw,$.ymin()+(n-1)*htouch+3*th))
		$.kbpara[n].resize(xy($.xmin(),$.ymin()+(n-1)*htouch+3*th,$.xmin()+5*tw,$.ymin()+n*htouch+th))
	}

	$.kb.resize(xy($.xmax()-10*tw, $.ymin(), $.xmax(), $.ymin()+th))
	$.ksdur.resize(xy($.xmax()-4*tw,$.ymin()+th,$.xmax(),$.ymin()+2*htouch+th))
	$.ksvol.resize(xy($.xmax()-4*tw,$.ymin()+3*htouch+th,$.xmax(),$.ymax()))
} 
	

}




#########################################################################################


class wpiano {

method init(charray, octarray) {

	$.w = new window()
	$.inherit($.w)

	$.defvol = 63
	$.defdur = 1b

	$.chdur = [1=0,2=0,3=0,4=0,5=0]
	$.chvol = [1=0,2=0,3=0,4=0,5=0]

	$.car = []		# caractère ASCII associé à une touche
	$.offset = []		# offset pour le mode kb
	for (r=0; r<=4; r++) 
	{
		$.offset[r] = []
		$.car[r] = []
		for (c=0; c<=23; c++) { $.car[r][c] = ""; $.offset[r][c] = [0=0] }
	}

	if (nargs() == 0)
	   $.ch = [1=1, 2=1, 3=1, 4=1, 5=1]
	else
	   $.ch = charray

	if (nargs() <= 1)
	   $.oct = [1=-2, 2=0, 3=2, 4=4, 5=6]
	else
	   $.oct = octarray

	$.cols = 12*2
	$.rows = 5				# total 5*2 = 10 octaves

	$.upobj = $0 ; $.upmeth = ""
	$.downobj = $0 ; $.downmeth = ""
	$.dragobj = $0 ; $.dragmeth = ""
	$.callbackup = 0

	$.KBMODEON = 0
}

method redraw {
	$.w.redraw()

	ysz = $.ymax() - $.ymin() + 1
	for ( n=1; n<$.rows; n++ ) {
		y = $.ymin() + (n*ysz)/$.rows
		$.w.line(xy($.xmin(),y,$.xmax(),y))
	}
	xsz = $.xmax() - $.xmin() + 1
	for ( n=1; n<$.cols; n++ ) {
		x = $.xmin() + (n*xsz)/$.cols
		$.w.line(xy(x,$.ymin(),x,$.ymax()))
		if ((n%12) in arraylist(2,4,7,9,11))
		   for (r = 1; r <= $.rows; r++) $.noire(r-1,n-1,STORE,2)
	}
	
	for ( n=1; n<$.cols; n++ )	
	    for (r = 1; r <= $.rows; r++) $.etiquette(r-1, n-1, CLEAR)
}
method noire(r,c,mode,bord) {
	ysz = $.ymax() - $.ymin() + 1
	xsz = $.xmax() - $.xmin() + 1
	x0 = $.xmin() + (c*xsz)/$.cols
	y0 = $.ymin() + (r*ysz)/$.rows
	x0++
	y0++
	x1 = $.xmin() + ((c+1)*xsz)/$.cols
	y1 = $.ymin() + ((r+1)*ysz)/$.rows
	x1--
	y1--
	$.w.fillrectangle(xy(x0+bord,y0+bord,x1-bord,y1-bord-$.textheight()),mode)
}
method etiquette(r,c,mode) {
	ysz = $.ymax() - $.ymin() + 1
	xsz = $.xmax() - $.xmin() + 1
	x0 = $.xmin() + (c*xsz)/$.cols
	y0 = $.ymin() + (r*ysz)/$.rows
	x0++
	y0++
	x1 = $.xmin() + ((c+1)*xsz)/$.cols
	y1 = $.ymin() + ((r+1)*ysz)/$.rows
	x1--
	y1--
	$.text($.car[r][c], xy(x0, y1-$.textheight(), x1, y1))
}

method setchan(v, n) {
       $.ch[n] = v
}

method setoct(v, n) {
       $.oct[n] = v
}

method setparas(n) {
       if ($.warning == "")
       {
	def = string($.chvol[n])
	$.chvol[n] = integer(getastr("*Piano "+string(n)+"*    volume ("+def+") :", def))
	def = string($.chdur[n])
	$.chdur[n] = integer(getastr("*Piano "+string(n)+"*    durée ("+def+") :", def))
       }
       else getastr($.warning)
}

method setvolume(v) {
       $.defvol = v
}

method setduree(v) {
       $.defdur = v
}

method kbmode {
	print(GMblah_clavier1)
	Consecho = 0	# turn off echoing of characters on console	
	$.KBMODEON = 1
	while ( 1 ) {
		t = Root.waitforconsolekey()		
	
		if ( t == " " )			# <SPC> pour arrêter			
		   break		

		playph = ''

		for (r=0; r<=4; r++) for(c=0; c<=23; c++)
		    if (t == $.car[r][c])
		    {
		       midicode = c +12*($.oct[r+1]+2)
		       note = phrase("'p"+string(midicode)+"'")
		       note.chan = $.ch[r+1]

		       if ($.chvol[r+1])	note.vol = $.chvol[r+1]
		       else		note.vol = $.defvol

		       if ($.chdur[r+1])	note.dur= $.chdur[r+1]
		       else		note.dur = $.defdur

		       if ((nbnotes = $.offset[r][c][0])>0)
		       {
			   notes = ''
			   for (n = 1; n <= nbnotes; n++)
			   {
			       note.time = $.offset[r][c][n]
			       notes |= note
			   }
		       }
		       else notes = note
		       		       
		       playph |= LiveAC[$.ch[r+1]]+notes
		       Bprint("(",midicode,")",notes)
		       
		    }		   
		if (playph != '')
		{
		       task realtime(playph)    
		       Snarph(playph, "("+t+GMblah_clavier3)
		}
	}
	$.KBMODEON = 0
	Consecho = 1
	print(GMblah_clavier2)
}


method mousedown (m) {

       r = $.wgridxy2rc(m)["row"]
       c = $.wgridxy2rc(m)["col"]

       if (m["button"] == 1)
       {
		midicode = c +12*($.oct[r+1]+2)

		note = phrase("'p"+string(midicode)+"'")
		note.chan = $.ch[r+1]

		if ($.chvol[r+1])	note.vol = $.chvol[r+1]
		else		note.vol = $.defvol

		if ($.chdur[r+1])	note.dur= $.chdur[r+1]
		else		note.dur = $.defdur

		realtime(LiveAC[$.ch[r+1]]+note)
		Bprint("(",midicode,")",note)
       }
       else 
       {
		if ($.KBMODEON) Root.consolekey(" ")
                defoff = ""
		if ((nn = $.offset[r][c][0])>0) for (n=1; n<=nn; n++)
		   defoff += ","+string($.offset[r][c][n])
		
		$.car[r][c] = substr(com = getastr("Raccourci ("+$.car[r][c]+defoff+"):",$.car[r][c]+defoff), 1, 1)			

		if (sizeof(com) > 1)
		{
		  off = split(split(com, $.car[r][c])[0],",")
		  $.offset[r][c][0] = sizeof(off)
		  if ((nn = sizeof(off)) > 0)
		  for (n=1; n<=nn; n++)
		      $.offset[r][c][n] = integer(off[n-1])
		} 
		$.redraw()
       }	
}
method mouseup (m) {
}
method mousedrag (m) {
#       Bprint("drag...",m)
}
method wgridxy2rc(m) {
	c = (m["x"]-$.xmin())*$.cols/($.xmax()-$.xmin())
	if ( c >= $.cols )
		c = $.cols-1
	else if ( c < 0 )
		c = 0
	r = (m["y"]-$.ymin())*$.rows/($.ymax()-$.ymin())
	if ( r >= $.rows )
		r = $.rows-1
	else if ( r < 0 )
		r = 0
	return(["row"=r,"col"=c])
}
method wgridrc2xy(m) {					# inutilisée
	x = $.xmin() + (c*($.xmax()-$.xmin()))/$.cols
	y = $.ymin() + (r*($.ymax()-$.ymin()))/$.rows
	return(["x"=x,"y"=y])
}


method dump()
{
	st = []

	st["car"] = arraycopy($.car)
	st["offset"] = arraycopy($.offset)
	st["ch"] = arraycopy($.ch)	
	st["oct"] = arraycopy($.oct)
	st["defvol"] = $.defvol
	st["defdur"] = $.defdur
	st["chvol"] = arraycopy($.chvol)	
	st["chdur"] = arraycopy($.chdur)	

	return (st)
}

method restore(st)
{
	$.oct = arraycopy(st["oct"])
	$.ch = arraycopy(st["ch"])
	$.car = arraycopy(st["car"])
	$.offset = arraycopy(st["offset"])
	$.defvol = st["defvol"]
	$.defdur = st["defdur"]
	$.chvol = arraycopy(st["chvol"])
	$.chdur = arraycopy(st["chdur"])	
}


}
