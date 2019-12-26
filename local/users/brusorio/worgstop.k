##########################################
# 	Copyright Patrick BRUSORIO 
#	Comput'Orgue Software
#	Release 1.5
#	Date Aug 07 2001
##########################################


class worgstop{
method init {
#colormix (0,255*164,255*229,255*226) #blue turquoise
#colormix (0,255*157,255*185,255*200) #blue microsoft
#colormix (0,255*192,255*192,255*192) #grey
colormix (0,255*255,255*240,255*213) #orange
#colormix (0,255*253,255*243,255*204) #yellow 


	$.w = new window()
	Merge = 0
	$.inherit($.w) 
	$.root = "AA"
	$.stopnu= []
	$.regnr= []	
	$.count = 0
	$.chnb = 16
	$.nbreg = 74
	$.nmem = 30
	$.stepcresc = 8
	$.ncresc = 3
	$.valcresc=1
	$.memnum=[]
	$.crescnum=[]
	$.memo = $.nmem +1
	$.memo1 = 3
	$.transp = 0
	$.startI = 1
	$.startII = 26
	$.startIII = 38
	$.startIV = 50
	$.stopnum=[]
	$.volk1 = 127
	$.volk2 = 127
	$.volk3 = 127
	$.volk4 = 127
	$.keybchan=[] 
	$.volnoise = 30
	$.banknr = 0
	$.mapnr = 0


							#Tempo slider
	
	$.inc = 10000	#1 bpm
	$.min = 285714	#210 bpm
	$.max = 1500000	#40 bpm
	$.initval = $.max-666666+$.min #90 bpm 
	$.valtempo = integer(60000000/666666)
	$.currval = $.initval
	$.temposlider = new ksliderh($.min,$.max,$.initval,$,"do")
	$.addchild($.temposlider)
	$.textvaltempo = new ktext(string($.valtempo))	
	$.addchild($.textvaltempo)
	$.button1 = new kbutton(0,$,"increment")
	$.addchild($.button1)
	$.button2 = new kbutton(0,$,"decrement")
	$.addchild($.button2)


	for ( n=0; n<=$.nmem; n++ ) {				# Memory init
		$.("mem"+string(n))=[]
		$.("memcoupler"+string(n))=[]
	}
	for ( n=1 ;n<= $.nmem  ;n++) {
		memory = n
		for ( s=1 ;s<= $.nbreg ;s++) {			
			$.("mem"+string(memory))[s]=0
		}
		for ( t=1 ;t<=6 ;t++) {			
			$.("memcoupler"+string(memory))[t]=0
		}

	}


	for ( n=1; n<=$.ncresc; n++ ) {			# Crescendo init
	memory1 = n
		for ( s=1 ;s<= $.nbreg ;s++) {
		memory2 = s		
			$.("cresc"+string(memory1)+string(memory2))=[]
		}
	}
	for ( n=1; n<=$.ncresc; n++ ) {			# Crescendo init
		memory1 = n
		for ( s=1 ;s<= $.nbreg ;s++) {
		memory2 = s	
			for(t=1 ;t<=$.stepcresc ;t++){
			memory3 = t
			$.("cresc"+string(memory1)+string(memory3))[memory2]=0
			}
		}
	}

									# StopMap button
	$.maplist=[]
	$.maplist= [0="Computorgan",
	1="organ1",
	2="organ2",
	3="organ3",
	4="organ4",
	5="organ5",
	6="organ6",
	7="organ7",
	8="organ8",
	9="organ9",
	10="organ10",
	11="organ11",
	12="organ12",
	13="organ13",
	14="organ14",
	15="organ15",
	16="organ16",
	17="organ17",
	18="organ18",
	19="organ19",
	20="organ20",
	21="GM"] 

      $.mapbut = new kvalbutton($.maplist,$,"mapchange")
      $.addchild($.mapbut)


							# Program name acquisition

if ($.mapnr ==0){   p = orgmaps()}
if ($.mapnr ==1){   p = orgmaps1()}
if ($.mapnr ==2){   p = orgmaps2()}
if ($.mapnr ==3){   p = orgmaps3()}
if ($.mapnr ==4){   p = orgmaps4()}
if ($.mapnr ==5){   p = orgmaps5()}
if ($.mapnr ==6){   p = orgmaps6()}
if ($.mapnr ==7){   p = orgmaps7()}
if ($.mapnr ==8){   p = orgmaps8()}
if ($.mapnr ==9){   p = orgmaps9()}
if ($.mapnr ==10){   p = orgmaps10()}
if ($.mapnr ==11){   p = orgmaps11()}
if ($.mapnr ==12){   p = orgmaps12()}
if ($.mapnr ==13){   p = orgmaps13()}
if ($.mapnr ==14){   p = orgmaps14()}
if ($.mapnr ==15){   p = orgmaps15()}
if ($.mapnr ==16){   p = orgmaps16()}
if ($.mapnr ==17){   p = orgmaps17()}
if ($.mapnr ==18){   p = orgmaps18()}
if ($.mapnr ==19){   p = orgmaps19()}
if ($.mapnr ==20){   p = orgmaps20()}

if ($.mapnr ==21){   p = Patchmap}

	psz = sizeof(p)	
	$.pname = []
	$.pnum = []
	$.abr =[]
	for ( n=0; n<psz; n++ ) {
		$.pname[n] = p[n]["name"]
		$.pnum[n] = p[n]["num"]
		$.abr[n] = p[n]["abr"]
	}


						# Language Text name acquisition
	$.languagenr=1	
	p = language()
	
	$.languagelist =[]
	$.computorgue =[]
	$.volumes =[]
	$.general =[]
	$.bruit =[]
	$.registre =[]
	$.preselections =[]
	$.reverb =[]
	$.crescendo =[]
	$.enreg =[]
	$.transpose =[]
	$.tirasses =[]
	$.anc =[]
	$.charger =[]	
	$.sauver =[]
	$.midii =[]
	$.midio1 =[]
	$.midio2 =[]
	$.mplus =[]
	$.mmoins =[]
	$.igrandorgue =[]
	$.iipositif =[]
	$.iiirecit =[]
	$.ivpedale =[]
	$.banque =[]	
	$.langue =[]
	$.map =[]
	$.configue =[]
	$.canal =[]
	
	
	for ( n=1; n<=6; n++ ) {
	$.languagelist[n] = p[0][n]
	$.computorgue[n] = p[1][n]
	$.volumes[n] = p[2][n]
	$.general[n] = p[3][n]
	$.bruit[n] = p[4][n]
	$.registre[n] = p[5][n]
	$.preselections[n] = p[6][n]
	$.reverb[n] = p[7][n]
	$.crescendo[n] = p[8][n]
	$.enreg[n] = p[9][n]
	$.transpose[n] = p[10][n]
	$.tirasses[n] = p[11][n]
	$.anc[n] = p[12][n]
	$.charger[n] = p[13][n]
	$.sauver[n] = p[14][n]
	$.midii[n] = p[15][n]
	$.midio1[n] = p[16][n]
	$.mmoins[n] = p[17][n]
	$.mplus[n] = p[18][n]
	$.igrandorgue[n] = p[19][n]
	$.iipositif[n] = p[20][n]
	$.iiirecit[n] = p[21][n]
	$.ivpedale[n] = p[22][n]
	$.banque[n] = p[23][n]
	$.langue[n] = p[24][n]
	$.map[n] = p[25][n]
	$.configue[n] = p[26][n]
	$.canal[n] = p[27][n]
	$.midio2[n] = p[88][n]
	}

	$.languagebut = new kvalbutton($.languagelist,$,"languagechange")
      $.addchild($.languagebut)
	
	for ( n=28; n<=82; n++ ) {				# Command help init
	$.("command"+string(n))=[]
		for ( t=1; t<=6; t++ ) {		
		$.("command"+string(n))[t]=p[n][t] 
		}
	}

							#Midi Port picker

      $.inports = midi("input", "list")
	$.nins = sizeof($.inports)
	for ( n=65; n<(65+$.nins) ; n++ ){
		if ( midi("input","isopen",n)!=0){ 
			midi("input","close",n)
		}
			midi("input","open",n)
	}

      $.outports = midi("output", "list")
	$.nouts = sizeof($.outports)
	for ( n=1; n<=$.nouts ; n++ ){
		if ( midi("output","isopen",n)!=0){
			midi("output","close",n)			
		}
			#midi("output","open",n)
	}
	$.butt1 =new kmenubutton("default","worgstop_inputs",$)
      $.butt2 = new kmenubutton("","worgstop_outputs1",$)
      $.butt3 = new kvalbutton($.outports, $, "switchoutput2")

      $.addchild($.butt1)
      $.addchild($.butt2)
      $.addchild($.butt3)

							#Bank change
	$.banklist=[]
	for ( n=0; n<=127; n++ ){
		$.banklist[n] = string(n)
	}
      $.bankbut = new kvalbutton($.banklist,$,"bankchange")
      $.addchild($.bankbut)
							#Channel nr picker
     	
	$.chanlist = []
	for ( n=1; n<= 16 ; n++ ) {
	$.chanlist [n] = string(n)
	}
	$.chanbut = []
	for ( n=1; n<= 6 ; n++ ) {
	$.chanbut[n] = new kvalbutton ($.chanlist,$,"chanchange",n)
	$.addchild($.chanbut[n])
	}
	$.channb = []

	

							# Volume slider
	$.volgen = 90
	$.slider = new kslider(0,127,$.volgen,$,"volchange")
	$.addchild($.slider)
							# I  Volume slider
	$.value = 125
	$.k1slider = new kslider(0,127,$.value,$,"k1volchange")
	$.addchild($.k1slider)
							# II Volume slider
	$.value = 125
	$.k2slider = new kslider(0,127,$.value,$,"k2volchange")
	$.addchild($.k2slider)
							# III Volume slider
	$.value = 125
	$.k3slider = new kslider(0,127,$.value,$,"k3volchange")
	$.addchild($.k3slider)
							# IV Volume slider
	$.value = 125
	$.k4slider = new kslider(0,127,$.value,$,"k4volchange")
	$.addchild($.k4slider)
							# Noise Volume slider
	$.value = 30
	$.noiseslider = new kslider(0,127,$.value,$,"noisevolchange")
	$.addchild($.noiseslider)

							# Pitch slider
	$.value = 63
	$.pitchslider = new ksliderh(0,127,$.value,$,"pitchchange")
	$.addchild($.pitchslider)
						      # k1 Modulation slider
	$.k1modulation = 63
	$.k1modslider = new kslider(0,127,$.k1modulation,$,"k1modchange")
	$.addchild($.k1modslider)
						      # k2 Modulation slider
	$.k2modulation = 63
	$.k2modslider = new kslider(0,127,$.k2modulation,$,"k2modchange")
	$.addchild($.k2modslider)
						      # k3 Modulation slider
	$.k3modulation = 63
	$.k3modslider = new kslider(0,127,$.k3modulation,$,"k3modchange")
	$.addchild($.k3modslider)

						      # k1 Tremulant frequency slider
	$.k1frequency = 53
	$.k1freqslider = new kslider(0,127,$.k1frequency,$,"k1freqchange")
	$.addchild($.k1freqslider)
						      # k2 Tremulant frequency slider
	$.k2frequency = 53
	$.k2freqslider = new kslider(0,127,$.k2frequency,$,"k2freqchange")
	$.addchild($.k2freqslider)
						      # k3 Tremulant frequency slider
	$.k3frequency = 53
	$.k3freqslider = new kslider(0,127,$.k3frequency,$,"k3freqchange")
	$.addchild($.k3freqslider)


							# Reverberation k1 slider
	$.volreverbk1 = 105
	$.reverbsliderk1 = new kslider(0,127,$.volreverbk1,$,"reverbvolchangek1") 	
	$.addchild($.reverbsliderk1)

							# Reverberation k2 slider
	$.volreverbk2 = 105
	$.reverbsliderk2 = new kslider(0,127,$.volreverbk2,$,"reverbvolchangek2")
	$.addchild($.reverbsliderk2)

							# Reverberation k3 slider
	$.volreverbk3 = 105
	$.reverbsliderk3 = new kslider(0,127,$.volreverbk3,$,"reverbvolchangek3")
	$.addchild($.reverbsliderk3)

							# Reverberation k4 slider
	$.volreverbk4 = 105
	$.reverbsliderk4 = new kslider(0,127,$.volreverbk4,$,"reverbvolchangek4")
	$.addchild($.reverbsliderk4)


							# Stop Volume slider
	$.volumestop = []
	$.stopslider = []
	$.volstopval = []
	for ( n=1; n<=$.nbreg ; n++ ) {
	$.volumestop[n]=90
	$.stopslider[n] = new ksliderh (0,127,$.volumestop,$, "stopvolchange",n)
		$.addchild($.stopslider[n])
	$.volstopval[n] = new ktext(string($.volumestop))
	$.addchild($.volstopval[n])
	}


							# Crescendo slider
	$.valcresc = 1
	$.crescslider = new kslider(1,$.stepcresc,$.valcresc,$,"crescend")
	$.addchild($.crescslider)
	$.textstepcresc=new ktext(string($.valcresc))
	$.addchild($.textstepcresc)

							# Stop name
	$.stopname = []
	for ( n=1; n<= $.nbreg ; n++ ) {
	$.stopname[n] = new kvalbutton ($.pname,$,"valchanged",n)
	$.addchild($.stopname[n])
	}

							# Stop button
	$.breg = []
	for ( n=1; n<= $.nbreg ; n++ ) {
		$.breg[n] = new kstopbut("",$,"onstop")
		$.addchild($.breg[n])
	}
							# Comment 1
	$.organname = "Organ Name"
	$.bcom = new kbutton(0,$,"oncomment")
	$.addchild($.bcom)

							# Crescendo select button
	$.bcresc = []
	$.namecresc = []
	for ( n=1; n<= $.ncresc ; n++ ) {
		$.namecresc[n]=n
		$.bcresc[n] = new ktoggle(string($.namecresc[n]),$,"oncresc",n)
		$.addchild($.bcresc[n])
	}
							# Coupling  select button
$.bcoup12 = new ktoggle("12",$,"oncoup12")
$.addchild($.bcoup12)
$.bcoup13 = new ktoggle("13",$,"oncoup13")
$.addchild($.bcoup13)
$.bcoup23 = new ktoggle("23",$,"oncoup23")
$.addchild($.bcoup23)
$.bcoupP1 = new ktoggle("P1",$,"oncoupP1")
$.addchild($.bcoupP1)
$.bcoupP2 = new ktoggle("P2",$,"oncoupP2")
$.addchild($.bcoupP2)
$.bcoupP3 = new ktoggle("P3",$,"oncoupP3")
$.addchild($.bcoupP3)
							# Metronome select button 
$.bmetro = new ktoggle("Metro",$,"onmetro")
$.addchild($.bmetro)
							# k1Modulation select button 
$.k1bmod = new ktoggle("Tr",$,"onmodk1")
$.addchild($.k1bmod)
							# k2Modulation select button 
$.k2bmod = new ktoggle("Tr",$,"onmodk2")
$.addchild($.k2bmod)
							# k3Modulation select button 
$.k3bmod = new ktoggle("Tr",$,"onmodk3")
$.addchild($.k3bmod)

							# Memory select button
	$.bmem = []
	$.namemem = []
	for ( n=1; n<= $.nmem+1 ; n++ ) {
		$.namemem[n]=n
		$.bmem[n] = new ktoggle(string($.namemem[n]),$,"onmem",n)
		$.addchild($.bmem[n])
	}
							# Memory record button
	$.brecmem = new kbutton(0,$, "onrecmem")
	$.addchild($.brecmem)
							# Crescendo record button
	$.breccresc = new kbutton(0,$, "onreccresc")
	$.addchild($.breccresc)

							# "Load" Button	
	$.bread = new kbutton(0,$,"onread")
	$.addchild($.bread)
							# "Save" Button	
	$.bwrite = new kbutton(0,$,"onwrite")
	$.addchild($.bwrite)

							# " Cancel I stops " Button	
	$.bcancelI = new kbutton(0,$, "oncancelI")
	$.addchild($.bcancelI)

							# " Cancel II stops " Button	
	$.bcancelII = new kbutton(0,$, "oncancelII")
	$.addchild($.bcancelII)

							# " Cancel III stops " Button	
	$.bcancelIII = new kbutton(0,$, "oncancelIII")
	$.addchild($.bcancelIII)
							# " Cancel IV stops " Button	
	$.bcancelIV = new kbutton(0,$, "oncancelIV")
	$.addchild($.bcancelIV)

							# " Cancel reeds " Button	
	$.bcancreeds = new kbutton(0,$, "oncancreeds")
	$.addchild($.bcancreeds)
	$.cancreeds=0 
							# " Call reeds " Button	
	$.bcallreeds = new kbutton(0,$, "oncallreeds")
	$.addchild($.bcallreeds)
	$.callreeds=0 
							# " Mem + " Button	
	$.bmemp = new kbutton(0,$, "onmemp")
	$.addchild($.bmemp)
							# " Mem - " Button	
	$.bmemm = new kbutton(0,$, "onmemm")
	$.addchild($.bmemm)
							# " Transpose+  " Button	
	$.btransp = new kbutton(0,$, "ontransp")
	$.addchild($.btransp)
							# " Transpose-" Button	
	$.btransm = new kbutton(0,$, "ontransm")
	$.addchild($.btransm)

	$.texttrans=new ktext (string($.transp))
	$.addchild($.texttrans)

							# Channel Nr	
	$.chnum = []
	$.tchnum = []
	for ( n=1; n<= $.nbreg ; n++ ) {
		$.tchnum[n] = new ktext("")	
		$.addchild($.tchnum[n])
	$.chnum[n] = "0"
	}
	regiprogram($)
}



							#Metronome Tempo slider
method do (v) {
	if ( nargs() > 0 )
		$.currval = v
	# Reverse the direction,
	# so up is faster, and down is slower
	tempo($.max-$.currval+$.min)
	if ( Konnect != $0 ) 		Konnect.sendtempo(tempo())
	$.valtempo=integer(60000000/($.max-$.currval+$.min))
	$.textvaltempo.set(string($.valtempo))
	$.textvaltempo.redraw()


}
method increment {
	$.set($.temposlider.get()+$.inc,1)
	$.temposlider.redraw()
	$.temposlider.do()

	#	colormix (0,255*164,255*229,255*226) #blue turquoise
	#	$.msg = new kmsg(string($.command79[$.languagenr]))
	#	location=["x0"=$.a52["x0"]+15,"x1"=$.a52["x1"]+350,"y0"=$.a52["y0"]+20,"y1"=$.a52["y1"]+30]
	#	$.msg.resize(location)	
	#	$.msg.redraw()
	#	colormix (0,255*255,255*240,255*213) #orange
	#	$.button1.redraw()
}
method decrement {
	$.set($.temposlider.get()-$.inc,1)
	$.temposlider.redraw()
	$.temposlider.do()
	#	colormix (0,255*164,255*229,255*226) #blue turquoise
	#	$.msg = new kmsg(string($.command78[$.languagenr]))
	#	location=["x0"=$.a51["x0"]+15,"x1"=$.a51["x1"]+350,"y0"=$.a51["y0"]+20,"y1"=$.a51["y1"]+30]
	#	$.msg.resize(location)	
	#	$.msg.redraw()
	#	colormix (0,255*255,255*240,255*213) #orange
	#	$.button2.redraw()

}
method update { $.temposlider.do()
 }

method get {
	# used to be: return($.temposlider.get()) }
	t = $.max-$.currval+$.min
	return( phrase("'\"Tempo="+string(t)+"\"'") )
}
method set (v,dodraw) {
	$.temposlider.set(v)
	if( nargs() > 1 && dodraw)
		$.temposlider.redraw()
}
							# StopMap selection
method mapchange(mapnr) {
$.mapnr = mapnr

if ($.mapnr ==0)	{p = orgmaps()}
if ($.mapnr ==1)	{p = orgmaps1()}
if ($.mapnr ==2)	{p = orgmaps2()}
if ($.mapnr ==3)	{p = orgmaps3()}
if ($.mapnr ==4)	{p = orgmaps4()}
if ($.mapnr ==5)	{p = orgmaps5()}
if ($.mapnr ==6)	{p = orgmaps6()}
if ($.mapnr ==7)	{p = orgmaps7()}
if ($.mapnr ==8)	{p = orgmaps8()}
if ($.mapnr ==9)	{p = orgmaps9()}
if ($.mapnr ==10)	{p = orgmaps10()}
if ($.mapnr ==11)	{p = orgmaps11()}
if ($.mapnr ==12)	{p = orgmaps12()}
if ($.mapnr ==13)	{p = orgmaps13()}
if ($.mapnr ==14)	{p = orgmaps14()}
if ($.mapnr ==15)	{p = orgmaps15()}
if ($.mapnr ==16)	{p = orgmaps16()}
if ($.mapnr ==17)	{p = orgmaps17()}
if ($.mapnr ==18)	{p = orgmaps18()}
if ($.mapnr ==19)	{p = orgmaps19()}
if ($.mapnr ==20)	{p = orgmaps20()}

if ($.mapnr ==21)	{p = Patchmap}


	psz = sizeof(p)	

	for ( n=0; n<psz; n++ ) {
		$.pname[n] = p[n]["name"]
		$.pnum[n] = p[n]["num"]
		$.abr[n] = p[n][ "abr"]
	}					
	for ( n=1; n<= $.nbreg ; n++ ) {
		$.stopname[n].setvals($.pname)
	}
}
							# stopnum change		
method valchanged (v,ch)  {
	if ( !(v in $.pnum))
		error("Hey, v=",v," in valchanged, not in $.pnum ? ")
	$.stopnum[ch]=$.pnum[v]
}
							# Comment
method oncomment(v)  {
	s = getastr($.configue[$.languagenr],"")
	if ( s != "" ){
		$.organname=s
		$.redraw()
		#colormix (0,255*164,255*229,255*226) #blue turquoise
		#$.msg = new kmsg(string($.command28[$.languagenr]))
		#location=["x0"=$.a1["x0"]+15,"x1"=$.a1["x1"]+350,"y0"=$.a1["y0"]+20,"y1"=$.a1["y1"]+30]
		#$.msg.resize(location)	
		#$.msg.redraw()
		#colormix (0,255*255,255*240,255*213) #orange	
		#$.bcom.redraw()

		}
}

method oncancelI{ 				# " Cancel I stops "  Button

	for ( n=1 ;n<= 25  ;n++) {	
		$.breg[n].set(0)
		$.breg[n].redraw()
	}
			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)		
	$.onstop()
}

method oncancelII{ 				# " Cancel II stops "  Button

	for ( n=26 ;n<= 37  ;n++) {	
		$.breg[n].set(0)
		$.breg[n]. redraw()
	}
			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)		
	$.onstop()
}

method oncancelIII{ 				# " Cancel III stops "  Button

	for ( n=38 ;n<= 49  ;n++) {	
		$.breg[n].set(0)
		$.breg[n]. redraw()
	}
			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)		
	$.onstop()
}
method oncancelIV{ 				# " Cancel IV stops "  Button

	for ( n=50 ;n<= 74  ;n++) {	
		$.breg[n].set(0)
		$.breg[n]. redraw()
	}
			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)		
	$.onstop()
}



method oncancreeds  { 				# " Cancel reeds "  Button

							# Stop dispatching 
			for ( s=1 ;s<= $.nbreg  ;s++) {	
				if ($.("mem"+string($.nmem))[s]!=0) 
				{
				$.breg[s].set(0)
				$.breg[s].redraw()				
				}
			}
			$.onstop()

			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)	
		#$.cancreeds=1
		#colormix (0,255*164,255*229,255*226) #blue turquoise
		#$.msg = new kmsg(string($.command58[$.languagenr]))
		#location=["x0"=$.a31["x0"]+15,"x1"=$.a31["x1"]+350,"y0"=$.a31["y0"]+20,"y1"=$.a31["y1"]+30]
		#$.msg.resize(location)	
		#$.msg.redraw()
		#colormix (0,255*255,255*240,255*213) #orange
		#$.bcancreeds.redraw()		

}

method oncallreeds  { 				# " Call reeds "  Button
			
	for ( s=1 ;s<= $.nbreg ;s++) {	
		
			if ($.("mem"+string($.nmem))[s]!=0) 
			{
			$.breg[s].set($.("mem"+string($.nmem))[s])

			$.breg[s]. redraw()
			}
	}
		#$.onstop()
		#$.callreeds=1 
		#colormix (0,255*164,255*229,255*226) #blue turquoise
		#$.msg = new kmsg(string($.command57[$.languagenr]))
		#location=["x0"=$.a30["x0"]+15,"x1"=$.a30["x1"]+350,"y0"=$.a30["y0"]+20,"y1"=$.a30["y1"]+30]
		#$.msg.resize(location)	
		#$.msg.redraw()
		#colormix (0,255*255,255*240,255*213) #orange	
		#$.bcallreeds.redraw()
}

method ontransp  { 				# " Transpose + "  Button 
$.transp=$.transp+1
			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)		
$.texttrans.set($.transp)
$.texttrans.redraw()
}

method ontransm  { 				# " Transpose - "  Button 
$.transp=$.transp-1
			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)		
$.texttrans.set($.transp)
$.texttrans.redraw()
}



							# Page save
method onwrite {
return (page_write())
}

							# Page load
method onread {
return (page_readnew())
}
							# Midi port picker 

#method switchinput (input) {
	#$.input = integer(input)
	#midi("input","open",$.input)
#}

method inputchanged (portno,name) {
	if ( portno < 0 )
		return()
	$.input  = portno
	$.currinname = name
	$.butt1.setdrawfunc(textfunc(name))
	$.butt1.redraw()
}

method output1changed (portno,name) {
	if ( portno < 0 )
		return()
	$.output1 = portno
	mapport($.input,portno)
	$.butt2.setdrawfunc(textfunc(name))
	$.butt2.redraw()
}

#method switchoutput1 (output1) {
	#$.output1 = integer(output1)
	#midi("output","open",$.output1)

#}
#method switchoutput2 (output2) {
#	$.output2 = integer(output2)
#	midi("output","open",$.output2)
#}


							# Midi bank picker 
method bankchange(banknr) {
$.banknr = integer (banknr)
	for (n=0;n<$.chnb ;n++){ 
		p = midibytes(0xb0 | (n),00, $.banknr)
		realmidi(p)
    		p = midibytes(0xc0 | (n),00)
		realmidi(p)
    		}
		$.onstop()	
}
							# Midi channel picker 
method chanchange(ch,num) {
$.keybchan[num] = ch
}
							# Language selection
method languagechange(languagenr) {
$.languagenr = integer (languagenr)
$.redraw()
}


method onmemp  { 					# "Mem + "  Button 
	$.tid = task $.task_echomidi()
	for ( n=1 ;n<= $.nmem  ;n++) {
		if ($.bmem[n].get() !=0) {
	$.memo = n
		}
	}
	if($.memo<$.nmem){
		$.bmem[$.memo].set(0)
		$.bmem[$.memo].redraw()
		$.bmem[$.memo+1].set(1)
		$.bmem[$.memo+1].redraw()
	
		for (s=1 ;s<= $.nbreg  ;s++) {# Stop  dispatching
			$.breg[s].set($.("mem"+string($.memo+1))[s])
			$.breg[s].redraw()
		}
	$.onstop()
	}
}

method onmemm  { 					# "Mem - "  Button 
	$.tid = task $.task_echomidi()
	for ( n=1 ;n<= $.nmem  ;n++) {
		if ($.bmem[n].get() !=0) {
	$.memo = n
		}
	}
	if($.memo>1){
		$.bmem[$.memo].set(0)
		$.bmem[$.memo].redraw()
		$.bmem[$.memo-1].set(1)
		$.bmem[$.memo-1].redraw()
		for (s=1 ;s<= $.nbreg  ;s++) {# Stop  dispatching
			$.breg[s].set($.("mem"+string($.memo-1))[s])
			$.breg[s].redraw()
		}
	$.onstop()
	}
}

method oncoup12  { 				# "Coupling 12 "  Button 
	if ($.bcoup12.get() !=0){
			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)		
		#colormix (0,255*164,255*229,255*226) #blue turquoise
		#$.msg = new kmsg(string($.command54[$.languagenr]))
		#location=["x0"=$.a27["x0"]+15,"x1"=$.a27["x1"]+350,"y0"=$.a27["y0"]+20,"y1"=$.a27["y1"]+30]
		#$.msg.resize(location)	
		#$.msg.redraw()
		#colormix (0,255*255,255*240,255*213) #orange
		#$.bcoup12.redraw()
	}
else {
			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)		
}
}
method oncoup13  { 				# "Coupling 13 "  Button 
	if ($.bcoup13.get() !=0){
			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)		
		#colormix (0,255*164,255*229,255*226) #blue turquoise
		#$.msg = new kmsg(string($.command55[$.languagenr]))
		#location=["x0"=$.a28["x0"]+15,"x1"=$.a28["x1"]+350,"y0"=$.a28["y0"]+20,"y1"=$.a28["y1"]+30]
		#$.msg.resize(location)	
		#$.msg.redraw()
		#colormix (0,255*255,255*240,255*213) #orange
		#$.bcoup13.redraw()
	}
else {
			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)		
}
}
method oncoup23  { 				# "Coupling 23 "  Button 
	if ($.bcoup23.get() !=0){
			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)		
		#colormix (0,255*164,255*229,255*226) #blue turquoise
		#$.msg = new kmsg(string($.command56[$.languagenr]))
		#location=["x0"=$.a29["x0"]+15,"x1"=$.a29["x1"]+350,"y0"=$.a29["y0"]+20,"y1"=$.a29["y1"]+30]
		#$.msg.resize(location)	
		#$.msg.redraw()
		#colormix (0,255*255,255*240,255*213) #orange
		#$.bcoup23.redraw()
	}
else {
			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)		
}
}

method oncoupP1  { 				# "Coupling P1 "  Button 
	if ($.bcoupP1.get() !=0){
			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)

		#colormix (0,255*164,255*229,255*226) #blue turquoise
		#$.msg = new kmsg(string($.command51[$.languagenr]))
		#location=["x0"=$.a24["x0"]+15,"x1"=$.a24["x1"]+350,"y0"=$.a24["y0"]+20,"y1"=$.a24["y1"]+30]
		#$.msg.resize(location)	
		#$.msg.redraw()
		#colormix (0,255*255,255*240,255*213) #orange
		#$.bcoupP1.redraw()
	}
else {			
			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)	
		
}
}

method oncoupP2  { 				# "Coupling P2 "  Button 
	if ($.bcoupP2.get() !=0){
			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)	
		#colormix (0,255*164,255*229,255*226) #blue turquoise
		#$.msg = new kmsg(string($.command52[$.languagenr]))
		#location=["x0"=$.a25["x0"]+15,"x1"=$.a25["x1"]+350,"y0"=$.a25["y0"]+20,"y1"=$.a25["y1"]+30]
		#$.msg.resize(location)	
		#$.msg.redraw()
		#colormix (0,255*255,255*240,255*213) #orange
		#$.bcoupP2.redraw()
	}
else {
			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)		
}
}

method oncoupP3  { 				# "Coupling P3 "  Button 
	if ($.bcoupP3.get() !=0){
			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}

		#realtime(a)		
		#colormix (0,255*164,255*229,255*226) #blue turquoise
		#$.msg = new kmsg(string($.command53[$.languagenr]))
		#location=["x0"=$.a26["x0"]+15,"x1"=$.a26["x1"]+350,"y0"=$.a26["y0"]+20,"y1"=$.a26["y1"]+30]
		#$.msg.resize(location)	
		#$.msg.redraw()
		#colormix (0,255*255,255*240,255*213) #orange		
		#$.bcoupP3.redraw()

	}
else {
			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)		
}
}



method onstop  { 					# Stop button : ProgChange dispaching 
							# to Channels 1 to 9 and 11 to 16 

$.tid = task $.task_echomidi()
$.tid = task $.task_echoconsole()	
	$.reverbvolchangek1($.volreverbk1)
	$.reverbvolchangek2($.volreverbk2)
	$.reverbvolchangek3($.volreverbk3)
	$.reverbvolchangek4($.volreverbk4)
	$.count = 0		
	for ( n=1 ;n<= $.nbreg  ;n++) {
			if ($.breg[n].get() !=0) {
			$.count = $.count+1
			if ($.count == 10) { $.count = $.count+1}
				if ($.count <= $.chnb ) {
					realmidi(progchange($.stopnum[n]+1,$.count))
				}	
				else {$.breg[n].set(0)
					$.breg[n]. redraw()
				}	
			}
	}

			a=''				# note off toChannel off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x7b, 0x00 )}
			realtime(a)		
			a=''				# Modulation off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x01, 0x00 )}
			realtime(a)		
}



method onmem { 					# Memory button
	$.tid = task $.task_echomidi()
	$.bmem[$.memo].set(0)
	$.bmem[$.memo].redraw()
	for ( n=1 ;n<= $.nmem  ;n++) {
		if ($.bmem[n].get() !=0) {
			$.memo = n
							# Stop dispatching 
			for ( s=1 ;s<= $.nbreg  ;s++) {	
				$.breg[s].set($.("mem"+string($.memo))[s])
				$.breg[s]. redraw()
			}
							# Coupler dispatching
			$.bcoupP1.set($.("memcoupler"+string($.memo))[1])
			$.bcoupP1.redraw()
			$.bcoupP2.set($.("memcoupler"+string($.memo))[2])
			$.bcoupP2.redraw()
			$.bcoupP3.set($.("memcoupler"+string($.memo))[3])
			$.bcoupP3.redraw()
			$.bcoup12.set($.("memcoupler"+string($.memo))[4])
			$.bcoup12.redraw()
			$.bcoup13.set($.("memcoupler"+string($.memo))[5])
			$.bcoup13.redraw()
			$.bcoup23.set($.("memcoupler"+string($.memo))[6])
			$.bcoup23.redraw()
			$.onstop()
		}
	}
}
method oncresc { 					# Crescendo button
	$.bcresc[$.memo1].set(0)
	$.bcresc[$.memo1]. redraw()
	$.tid = task $.task_echomidi()
	for ( n=1 ;n<= $.ncresc  ;n++) {
		if ($.bcresc[n].get() !=0) {
			$.memo1= n
							# Stop dispatching 
		for ( s=1 ;s<= $.nbreg  ;s++) {$.breg[s].set($.("cresc"+string($.memo1)+string($.valcresc))[s])
		$.breg[s]. redraw()
		}
		$.onstop()	
		}
	}	
}

method onrecmem { 					# Memory Record button

	for ( n=1 ;n<= $.nmem  ;n++) {
		if ($.bmem[n].get() !=0) {
		memory = n
			for ( s=1 ;s<= $.nbreg ;s++) {  # stop mem		
			$.("mem"+string(memory))[s]=0
			}
			for ( t=1 ;t<= 6 ;t++) {	  # Coupler mem
			$.("memcoupler"+string(memory))[t]=0
			}
		}
	}
	for ( s=1 ;s<= $.nbreg  ;s++) {				
		if ($.breg[s].get() !=0) {
			$.("mem"+string(memory))[s]=1
		}
	}
	if ($.bcoupP1.get()!=0) { $.("memcoupler"+string(memory))[1]=1}
	if ($.bcoupP2.get()!=0) { $.("memcoupler"+string(memory))[2]=1}
	if ($.bcoupP3.get()!=0) { $.("memcoupler"+string(memory))[3]=1}
	if ($.bcoup12.get()!=0) { $.("memcoupler"+string(memory))[4]=1}
	if ($.bcoup13.get()!=0) { $.("memcoupler"+string(memory))[5]=1}
	if ($.bcoup23.get()!=0) { $.("memcoupler"+string(memory))[6]=1}
}
method onreccresc { 					# Crescendo Record button
	for ( n=1 ;n<= $.ncresc  ;n++) {
		if ($.bcresc[n].get() !=0) {
	memory1 = n
			for ( s=1 ;s<= $.nbreg ;s++) {			
				$.("cresc"+string(memory1) +string($.valcresc))[s]=0
				if ($.breg[s].get()	!=0){
					$.("cresc"+string(memory1) +string($.valcresc))[s]=1
				}
			}
		}
}	
}

method task_echoconsole() {

f = open() 
	while ( (nt=get(f)) != Eof ) {
		print(get(Consolefifo))
		if(get(Consolefifo)== "a") {
			$.bcoup12.set(1)
			$.bcoup12.redraw()
		}
}
}

method set (v,dodraw) {
	#$.K3slider.set(v)
	#if( nargs() > 1 && dodraw)
	#	$.K3slider.redraw()
	#$.crescslider.set(v)
	#if( nargs() > 1 && dodraw)
	#	$.crescslider.redraw()
}
method task_echomidi() {				# dynamic channel dispatching

Midiin[$] = f = open()
	while ( (nt=get(f)) != Eof ) {

#			if ( nt.type & (PROGRAM) ) { # memory Nr transfert
#			$.bmem[integer(subbytes(nt,2,1))+1].set(1)								
#			$.bmem[integer(subbytes(nt,2,1))+1].redraw()							
#			$.onmem(integer(subbytes(nt,2,1))+1)
#			}

		if ( nt.type & (CONTROLLER) ) {
#			print(integer(subbytes(nt,2,1))) # to verify the Controller Nr

			if (integer(subbytes(nt,2,1))==7){ # Action on swell pedal
			$.volk3 = integer(subbytes(nt,3,1))
			$.k3slider.set($.volk3)
			$.k3slider.redraw()
			$.k3volchange($.volk3)
			} 

#			print(integer(subbytes(nt,3,1))) # to verify the Controller value

#			if (integer(subbytes(nt,2,1))==64){ # Action on sustain pedal
				# increase KIII volume
	#				if ($.volk3 <125) {
	#				$.volk3=$.volk3 +3 
	#				$.set($.K3slider.get()+3,1)
	#				$.k3volchange($.volk3)
	#				}
				# increase crescendo 
	#				if ($.valcresc <8) {
	#				$.valcresc=$.valcresc+0.5
	#				$.set($.crescslider.get()+0.5,1)
	#				$.crescend($.valcresc)
	#				$.oncresc	
	#				}				


	#		if (integer(subbytes(nt,2,1))==67){ # Action on damper pedal 
				# decrease KIII volume 
	#				if ($.volk3 >3) {
	#				$.volk3=$.volk3 -3 
	#				$.set($.K3slider.get()-3,1)
	#				$.K3volchange($.volk3)
	#				}
				# decrease crescendo
	#				if ($.valcresc >1) {
	#				$.valcresc=$.valcresc-0.5 
	#				$.set($.crescslider.get()-0.5,1)
	#				$.crescend($.valcresc) 
	#				$.oncresc	
	#				}	
	#		}
			}
			if ( nt.type & (NOTE|NOTEON) ) {
			#print(integer(nt))
							# mem- controlled by keyboard A 23
			#if (integer(nt)==(21-$.transp)){$.onmemm()}	



							# mem- controlled by keyboard C 108
			#if (integer(nt)==(108-$.transp)){$.onmemp()}	

							# mem- controlled by keyboard 24
			#if (integer(nt)==(22-$.transp)){$.oncancreeds()}

							# mem- controlled by keyboard 106
			#if (integer(nt)==(106-$.transp)){$.oncallreeds()}		

							# Coup12 controlled by keyboard 101
			#if (integer(nt)==(101-$.transp)){
			#	if ($.bcoup12.get()  !=0) { $.bcoup12.set(0) }
			#	else {$.bcoup12.set(1)}
			#	$.bcoup12.redraw()
			#}
							# CoupP2 controlled by keyboard 100
			#if (integer(nt)==(100+$.transp)){
				#if ($.bcoupP2.get() !=0){ $.bcoupP2.set(0) }
				#else {$.bcoupP2.set(1)}
				#$.bcoupP2.redraw()
			#}
							# CoupP1 controlled by keyboard 100
			#if (integer(nt)==(98+$.transp)){
				#if ($.bcoupP1.get() !=0){$.bcoupP1.set(0) }
				#else {$.bcoupP1.set(1)}
				#$.bcoupP1.redraw()
			#}


							# reg01 controlled by keyboard 100
			if (integer(nt)==(100+$.transp)){
				if ($.breg[1].get()==1){$.breg[1].set(0) }
				else {$.breg[1].set(1)}
				$.breg[1].redraw()
			}
		}

			if ( nt.type & (NOTE|NOTEOFF|NOTEON) ) {
          
					ntch1=cut(nt,CUT_CHANNEL,$.keybchan[1])

					$.count1 = 0				
					ntch1.pitch += $.transp

					for ( nn=1 ;nn<$.startII  ;nn++) {    # Keybord I
						if ($.breg[nn].get() !=0) {
							$.count1 = $.count1+1
			               if ($.count1 == 10) { $.count1 = $.count1+1}
							ntch1.vol = integer ($.volumestop[nn]*$.volk1/127*$.volgen/127)
							ntch1.chan=$.count1
    							if ($.k1bmod.get() !=0){

								p = controller($.count1,99,127)  # tremolo frequence 
								realmidi(p)
								p = controller($.count1,98,1)
								realmidi(p)
								p = controller($.count1,6,64)
								realmidi(p)
								p = controller($.count1,38,$.k1frequency)
								realmidi(p)

								p = controller($.count1,01,$.k1modulation) # tremolo amplitude
								realmidi(p)} 

							realtime(ntch1,0)

							ntch1.chan=10  # Transmission Noise
							ntch1.vol =  integer ($.volnoise*$.volgen/127)
							#ntch1.port = $.output1
							realtime(ntch1,0)					
						}					
					}
					if ($.bcoup12.get() !=0){		# Coupling I-II
						$.count2 = $.count1
						ntch1=cut(nt,CUT_CHANNEL,$.keybchan[1])
						ntch1.pitch += $.transp
						for ( nn=$.startII ;nn<$.startIII  ;nn++) {
							if ($.breg[nn].get() !=0) {
								$.count2 = $.count2+1
			            if ($.count2 == 10) { $.count2 = $.count2+1}
					ntch1.vol=integer ($.volumestop[nn]*$.volk2/127*$.volgen/127)
					ntch1.chan=$.count2
    					if ($.k2bmod.get() !=0){
						p = controller($.count2,99,127)  # tremolo frequence 
						realmidi(p)
						p = controller($.count2,98,1)
						realmidi(p)
						p = controller($.count2,6,64)
						realmidi(p)
						p = controller($.count2,38,$.k2frequency)
						realmidi(p)

						p = controller($.count2,01,$.k2modulation) # tremolo amplitude
						realmidi(p)} 
						#ntch1.port = $.output1
						realtime(ntch1,0)
							}
						}					
					}
					else {$.count2 = $.count1}
	
					if ($.bcoup13.get() !=0){		# Coupling I-III
						if ($.bcoup12.get() !=0){$.count3 = $.count2}
						else {for ( nn=$.startII ;nn<$.startIII  ;nn++) {
							if ($.breg[nn].get() !=0) {
								$.count2 = $.count2+1
			            				if ($.count2 == 10) { $.count2 = $.count2+1}
											  	  }
									   $.count3 = $.count2 
											   }			
											 }
						 				
						ntch1=cut(nt,CUT_CHANNEL,$.keybchan[1])
						ntch1.pitch += $.transp
						for ( nn=$.startIII ;nn<$.startIV  ;nn++) {
							if ($.breg[nn].get() !=0) {
								$.count3 = $.count3+1
			            if ($.count3 == 10) { $.count3 = $.count3+1}
					ntch1.vol=integer($.volumestop[nn]*$.volk3/127*$.volgen/127)
					ntch1.chan=$.count3
    					if ($.k3bmod.get() !=0){
						p = controller($.count3,99,127)  # tremolo frequence 
						realmidi(p)
						p = controller($.count3,98,1)
						realmidi(p)
						p = controller($.count3,6,64)
						realmidi(p)
						p = controller($.count3,38,$.k3frequency)
						realmidi(p)

						p = controller($.count3,01,$.k3modulation)# tremolo amplitude
						realmidi(p)} 
							#ntch1.port = $.output1
								realtime(ntch1,0)
							}
						}					
					}

					ntch2=cut(nt,CUT_CHANNEL,$.keybchan[2])# Keyboard II

					ntch2.pitch += $.transp
					for ( nn=$.startII ;nn<$.startIII  ;nn++) {
							if ($.breg[nn].get() !=0) {
								$.count1 = $.count1+1
			      	if ($.count1 == 10) { $.count1 = $.count1+1}
					ntch2.vol = integer ($.volumestop[nn]*$.volk2/127*$.volgen/127)
					ntch2.chan=$.count1
	                  	if ($.k2bmod.get() !=0){
						p = controller($.count1,99,127)  # tremolo frequence 
						realmidi(p)
						p = controller($.count1,98,1)
						realmidi(p)
						p = controller($.count1,6,64)
						realmidi(p)
						p = controller($.count1,38,$.k2frequency)
						realmidi(p)			

						p = controller($.count1,01,$.k2modulation) # tremolo amplitude 
						realmidi(p)} 
						realtime(ntch2,0)
						ntch2.chan=10  # Transmission Noise
						ntch2.vol = integer ($.volnoise*$.volgen/127)
							#ntch2.port = $.output1
						realtime(ntch2,0)					
							}
						}
					if ($.bcoup23.get() !=0){		# Coupling II-III
						$.count2 = $.count1
						ntch2=cut(nt,CUT_CHANNEL,$.keybchan[2])
						ntch2.pitch += $.transp
						for ( nn=$.startIII ;nn<$.startIV  ;nn++) {
							if ($.breg[nn].get() !=0) {
								$.count2 = $.count2+1
			            if ($.count2 == 10) { $.count2 = $.count2+1}
					ntch2.vol=integer($.volumestop[nn]*$.volk3/127*$.volgen/127)
					ntch2.chan=$.count2
    					if ($.k3bmod.get() !=0){
						p = controller($.count2,99,127)  # tremolo frequence 
						realmidi(p)
						p = controller($.count2,98,1)
						realmidi(p)
						p = controller($.count2,6,64)
						realmidi(p)
						p = controller($.count2,38,$.k3frequency)
						realmidi(p)			
		
						p = controller($.count2,01,$.k3modulation)# tremolo amplitude
						realmidi(p)} 
							#ntch2.port = $.output1
								realtime(ntch2,0)
							}
						}					
					}

					ntch3=cut(nt,CUT_CHANNEL,$.keybchan[3])# Keyboard III

					ntch3.pitch += $.transp
					for ( nn=$.startIII ;nn<$.startIV  ;nn++) {
							if ($.breg[nn].get() !=0) {
								$.count1 = $.count1+1
				      if ($.count1 == 10) { $.count1 = $.count1+1}
					ntch3.vol = integer ($.volumestop[nn]*$.volk3/127*$.volgen/127)
					ntch3.chan=$.count1
	            	      if ($.k3bmod.get() !=0){
						p = controller($.count1,99,127)  # tremolo frequence 
						realmidi(p)
						p = controller($.count1,98,1)
						realmidi(p)
						p = controller($.count1,6,64)
						realmidi(p)
						p = controller($.count1,38,$.k3frequency)
						realmidi(p)	

						p = controller($.count1,01,$.k3modulation)# tremolo amplitude 
						realmidi(p)} 
							realtime(ntch3,0)
							ntch3.chan=10  # Transmission Noise
							ntch3.vol = integer ($.volnoise*$.volgen/127)
							#ntch3.port = $.output1	
							realtime(ntch3,0)	
								
							}
						}					

					ntch4=cut(nt,CUT_CHANNEL,$.keybchan[4])# Keyboard III
					ntch4.pitch += $.transp
					for ( nn=$.startIV ;nn<= $.nbreg ;nn++) {
							if ($.breg[nn].get() !=0) {
								$.count1 = $.count1+1
			            if ($.count1 == 10) { $.count1 = $.count1+1}
					ntch4.vol = integer ($.volumestop[nn]*$.volk4/127*$.volgen/127)
					ntch4.chan=$.count1
							realtime(ntch4,0)
							ntch4.chan=10  # Transmission Noise
							ntch4.vol = $.volnoise
							#ntch4.port = $.output1
							realtime(ntch4,0)					
							}
						}				

					if ($.bcoupP1.get() !=0){		# Coupling P-I
					$.count1=0
						for ( nn=1 ;nn< $.startII ;nn++) {
							if ($.breg[nn].get() !=0) {
								$.count1 = $.count1+1
			            			if ($.count1 == 10) { $.count1 = $.count1+1}
								ntch4.vol = integer ($.volumestop[nn]*$.volk1/127*$.volgen/127)
								ntch4.chan=$.count1
    								if ($.k1bmod.get() !=0){
									p = controller($.count1,99,127)  # tremolo frequence 
									realmidi(p)
									p = controller($.count1,98,1)
									realmidi(p)
									p = controller($.count1,6,64)
									realmidi(p)
									p = controller($.count1,38,$.k1frequency)
									realmidi(p)	

								p = controller($.count2,01,$.k1modulation) # tremolo amplitude 
								realmidi(p)}
								#ntch4.port = $.output1 
								realtime(ntch4,0)
							}
						}				
					}
					if ($.bcoupP2.get() !=0){		# Coupling P-II
						$.count1=0
						for ( nn=1 ;nn< $.startIII ;nn++) {
							if ($.breg[nn].get() !=0) {
								$.count1 = $.count1+1
			            			if ($.count1 == 10) { $.count1 = $.count1+1}
								if (nn>=$.startII){
								ntch4.vol = integer ($.volumestop[nn]*$.volk2/127*$.volgen/127)
								ntch4.chan=$.count1
								if ($.k2bmod.get() !=0){
									p = controller($.count1,99,127)  # tremolo frequence 
									realmidi(p)
									p = controller($.count1,98,1)
									realmidi(p)
									p = controller($.count1,6,64)
									realmidi(p)
									p = controller($.count1,38,$.k2frequency)
									realmidi(p)	

   		                                          p = controller($.count1,01,$.k2modulation)# tremolo ampl 
                                                	realmidi(p)} 
									#ntch4.port = $.output1
									realtime(ntch4,0)
							}
							}				
						}
					}
					if ($.bcoupP3.get() !=0){		# Coupling P-III
						$.count1=0
						for ( nn=1 ;nn< $.startIV ;nn++) {
							if ($.breg[nn].get() !=0) {
								$.count1 = $.count1+1
			            			if ($.count1 == 10) { $.count1 = $.count1+1}
								if (nn>=$.startIII){
								ntch4.vol = integer ($.volumestop[nn]*$.volk3/127*$.volgen/127)
								ntch4.chan=$.count1
								if ($.k3bmod.get() !=0){
									p = controller($.count1,99,127)  # tremolo frequence 
									realmidi(p)
									p = controller($.count1,98,1)
									realmidi(p)
									p = controller($.count1,6,64)
									realmidi(p)
									p = controller($.count1,38,$.k2frequency)
									realmidi(p)	

                                                	p = controller($.count1,01,$.k3modulation)# tremolo ampl                                               		 
									realmidi(p)}
									#ntch4.port = $.output1 
									realtime(ntch4,0)
							}
							}				
						}
					}
  

			}			
	}
}

method stopvolchange (val,numstop){			# Stop Volume slider
$.va=val
$.volumestop[numstop]=val
#$.tchnum[numstop].set(string($.va)) A supprimer
#$.tchnum[numstop].redraw()
	$.volstopval[numstop].set($.volumestop[numstop]) 
	$.volstopval[numstop].redraw()  
}

method delete {
	unregiprogram($)
	delete Midiin[$]	
	Consecho = 1
}
	
method force (ch,pn) {}

method volchange (w) {					# General Volume slider 
	$.volgen = integer(w)
	q = gvolchange(w)
	realmidi(q)
}


method k1volchange (w) {				# I Volume slider 
	$.volk1 = integer(w)

					$.count1 = 0	
  					for ( nn=1 ;nn<$.startII  ;nn++) 
					{
						if ($.breg[nn].get() !=0) 
						{
						{$.count1 = $.count1+1}
			      		if ($.count1 == 10) { $.count1 = $.count1+1}
					
				p = ''
				p += chanvolchange($.count1,$.volk1*$.volgen/127)
						realmidi(p)
						}
					}
}

method k2volchange (w) {				# II Volume slider 
	$.volk2 = integer(w)

					$.count1 = 0	
  					for ( nn=1 ;nn<$.startII  ;nn++) 
					{
						if ($.breg[nn].get() !=0) 
						{$.count1 = $.count1+1}
					if ($.count1 == 10) { $.count1 = $.count1+1}
					}
					for ( nn=$.startII ;nn<$.startIII  ;nn++) 
					{
						if ($.breg[nn].get() !=0) 
						{
						$.count1 = $.count1+1
			      		if ($.count1 == 10) { $.count1 = $.count1+1}
				p = ''
				p += chanvolchange($.count1,$.volk2*$.volgen/127)
						realmidi(p)
						}
					}
}

method k3volchange (w) {				# III Volume slider 
	$.volk3 = integer(w)

					$.count1 = 0	
  					for ( nn=1 ;nn<$.startIII  ;nn++) 
					{
						if ($.breg[nn].get() !=0) 
						{$.count1 = $.count1+1}
					if ($.count1 == 10) { $.count1 = $.count1+1}
					}
					for ( nn=$.startIII ;nn<$.startIV  ;nn++) 
					{
						if ($.breg[nn].get() !=0) 
						{
						$.count1 = $.count1+1
			      		if ($.count1 == 10) { $.count1 = $.count1+1}
				p = ''
				p += chanvolchange($.count1,$.volk3*$.volgen/127)
						realmidi(p)
						}
					}
}

method k4volchange (w) {				# IV Volume slider 
	$.volk4 = integer(w)

					$.count1 = 0	
  					for ( nn=1 ;nn<$.startIV  ;nn++) 
					{
						if ($.breg[nn].get() !=0) 
						{$.count1 = $.count1+1}
			      		if ($.count1 == 10) { $.count1 = $.count1+1}
					}
					for ( nn=$.startIV ;nn<=$.nbreg  ;nn++) 
					{
						if ($.breg[nn].get() !=0) 
						{
						$.count1 = $.count1+1
			      		if ($.count1 == 10) { $.count1 = $.count1+1}
				p = ''
				p += chanvolchange($.count1,$.volk4*$.volgen/127)
						realmidi(p)
						}
					}
}

method noisevolchange (w) {				# Noise Volume slider 
	$.volnoise = integer(w)	
				p = ''
				p += chanvolchange(10,$.volnoise*$.volgen/127)
						realmidi(p)
}

method pitchchange (w) {				# Pitch slider 
	$.value = integer(w)
	q = gpitchchange(w)
	realmidi(q)
}

method k1modchange (w) {					# k1Modulation slider 
	$.k1modulation = integer(w)
}
method k2modchange (w) {					# k2Modulation slider 
	$.k2modulation = integer(w)
}
method k3modchange (w) {					# k3Modulation slider 
	$.k3modulation = integer(w)
}


method k1freqchange (w) {					# k1 frequency slider 
	$.k1frequency = integer(w)
	$.k1modchange($.k1modulation)
}
method k2freqchange (w) {					# k2 frequency slider 
	$.k2frequency = integer(w)
	$.k2modchange($.k2modulation)
}
method k3freqchange (w) {					# k3 frequency slider 
	$.k3frequency = integer(w)
	$.k3modchange($.k3modulation)
}



method reverbvolchangek1 (w) {			# k1 Reverberation Volume slider 
	$.volreverbk1 = integer(w)

	$.count1 = 0	
  	for ( nn=1 ;nn<$.startII  ;nn++) 
		{
		if ($.breg[nn].get() !=0) 
			{
			{$.count1 = $.count1+1}
			if ($.count1 == 10) { $.count1 = $.count1+1}
			p = controller($.count1,91,$.volreverbk1)
			realmidi(p)
			p = controller(10,91,$.volreverbk1) # noise reverberation
			realmidi(p)
	}
	}				
}

method reverbvolchangek2 (w) {			# k2 Reverberation Volume slider 
	$.volreverbk2 = integer(w)
		$.count1 = 0	
  		for ( nn=1 ;nn<$.startII  ;nn++) 
			{
			if ($.breg[nn].get() !=0) 
				{$.count1 = $.count1+1}
				if ($.count1 == 10) { $.count1 = $.count1+1}
				}
		for ( nn=$.startII ;nn<$.startIII  ;nn++) 
			{
			if ($.breg[nn].get() !=0) 
				{$.count1 = $.count1+1
			      if ($.count1 == 10) { $.count1 = $.count1+1}
		p = controller($.count1,91,$.volreverbk2)
		realmidi(p)
	}				
	}
}
method reverbvolchangek3 (w) {			# k3 Reverberation Volume slider 
	$.volreverbk3 = integer(w)
		$.count1 = 0	
  		for ( nn=1 ;nn<$.startIII  ;nn++) 
		{
			if ($.breg[nn].get() !=0) 
				{$.count1 = $.count1+1}
				if ($.count1 == 10) { $.count1 = $.count1+1}
				}
				for ( nn=$.startIII ;nn<$.startIV  ;nn++) 
				{
			if ($.breg[nn].get() !=0) 
				{$.count1 = $.count1+1
			      if ($.count1 == 10) { $.count1 = $.count1+1}
		p = controller($.count1,91,$.volreverbk3)
		realmidi(p)
	}				
	}
}
method reverbvolchangek4 (w) {			# k4 Reverberation Volume slider 
	$.volreverbk4 = integer(w)
		$.count1 = 0	
  		for ( nn=1 ;nn<$.startIV  ;nn++) 
			{
			if ($.breg[nn].get() !=0) 
			{$.count1 = $.count1+1}
			      if ($.count1 == 10) { $.count1 = $.count1+1}
				}
		for ( nn=$.startIV ;nn<=$.nbreg  ;nn++) 
			{
			if ($.breg[nn].get() !=0) 
				{$.count1 = $.count1+1
			     	if ($.count1 == 10) { $.count1 = $.count1+1}
		p = controller($.count1,91,$.volreverbk4)
		realmidi(p)
	}
	}				
}

method onmetro  { 						# Metronome Button 
	q = togglemet()
#	realmidi(q)
}

method onmodk1  { 						# k1 Modulation Button 
	if ($.k1bmod.get()==0){
			a=''					# Modulation off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x01, 0x00 )}
							# channel pressure reset
			for (n=0;n<$.chnb ;n++){a += midibytes( n + 0xd0, 0x00 )}
			realtime(a)		


	}
}
method onmodk2  { 						# k1 Modulation Button 
	if ($.k2bmod.get()==0){
			a=''					# Modulation off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x01, 0x00 )}
							# channel pressure reset
			for (n=0;n<$.chnb ;n++){a += midibytes( n + 0xd0, 0x00 )}
			realtime(a)		
	}
}
method onmodk3  { 						# k3 Modulation Button 
	if ($.k3bmod.get()==0){
			a=''					# Modulation off 
			for (n=0;n<$.chnb ;n++){a += midibytes(n + 0xb0, 0x01, 0x00 )}
							# channel pressure reset
			for (n=0;n<$.chnb ;n++){a += midibytes( n + 0xd0, 0x00 )}
			realtime(a)		
	}
}

method crescend (w1) {					# Crescendo  slider
	$.valcresc=w1
	$.textstepcresc.set($.valcresc)
$.textstepcresc. redraw()
	for ( n=1 ;n<= $.ncresc  ;n++) {
		if ($.bcresc[n].get() !=0) {
			$.memo1 = n
# Stop dispatching
			for ( s=1 ;s<= $.nbreg  ;s++) {$.breg[s].set($.("cresc"+string($.memo1)+string(w1))[s])
				$.breg[s]. redraw()
			}
		$.onstop()	
		}
	}
}

method dump {
	a =[]							# Memory
	point=0
	a[point]= "memory :"
	point=point+1
	for ( n=1; n<= $.nmem ; n++ ) { 			
		memory =n 	
		a[memory] = $.( "mem"+string(memory))
	}
	point=memory
	point=point+1					# Crescendo
	a[point]= "Crescendo :"	
	for (n=1 ;n<=$.ncresc ;n++){memory1=n
		for (s=1 ;s<=$.stepcresc ;s++){
			memory2=s
			point=point+1
			a[point]=$.( "cresc"+string(memory1)+string(memory2))
		}
	}	

	point=point+1					# Maplist
	a[point]= "Maplist :"	
	point=point+1					
	a[point]=$.mapnr 

	point=point+1
	a[point]= "volumestop :"			# volumestop
	point=point+1
	a[point]=$.volumestop
	
	point=point+1
	a[point]= "stopname /num :"			# stopname /num

	for(n=1 ;n<=$.nbreg ;n++){			
		point=point+1
		a[point]=$.stopname[n].get()
		point=point+1
		a[point]=$.stopnum[n]
	}

	point=point+1
	a[point]= "Inport:"				# InPort
	point=point+1
	a[point]= $.input

	point=point+1					# Outport1
	a[point]= "Outport1 :"
	point=point+1
	a[point]= $.output1

	point=point+1					# keyboardchannelNr
	a[point]= "keyboardchannelNr:"
	for (n=1 ;n<=4 ;n++){				 
	point=point+1
	a[point]= $.keybchan[n]
	}
	point=point+1					# bank nr
	a[point]= "bank nr:"
	point=point+1
	a[point]= $.banknr

	point=point+1					# Keyboard Vol
	a[point]= "Keyboard Vol:"
	point=point+1
	a[point]= $.volk1	
			
	point=point+1
	a[point]= $.volk2					

	point=point+1
	a[point]= $.volk3					

	point=point+1
	a[point]= $.volk4					
	
	point=point+1					# Reverb Vol
	a[point]= "Reverb Vol:"	
	point=point+1
	a[point]= $.volreverbk1
		
	point=point+1
	a[point]= $.volreverbk2
		
	point=point+1
	a[point]= $.volreverbk3
		
	point=point+1
	a[point]= $.volreverbk4

	point=point+1					# Noise Vol
	a[point]= "Noise Vol:"	
	point=point+1
	a[point]= $.volnoise

	point=point+1					# Language
	a[point]= "Language :"	
	point=point+1
	a[point]= $.languagenr

	point=point+1					# Orgue Configuration Name
	a[point]= "Orgue Configuration Name:"	
	point=point+1
	a[point]= $.organname					


	point=point+1					# Coupler in preselections
	a[point]= "Coupler Memory :"	
	for ( n=1; n<= $.nmem ; n++ ) { 	
		point=point+1
		memory =n 	
		a[point] = $.( "memcoupler"+string(memory))
	}

	point=point+1					# Tremulant 
	a[point]= "tremulant parameters :"	
	point=point+1
	a[point]= $.k1frequency
	point=point+1
	a[point]= $.k1modulation
	point=point+1
	a[point]= $.k2frequency
	point=point+1
	a[point]= $.k2modulation
	point=point+1
	a[point]= $.k3frequency
	point=point+1
	a[point]= $.k3modulation

return (a)
}

method restore (state) {
	point=0
	#print(state[point])
 	for ( n=1; n<= $.nmem ; n++ ) { 		# Memory
	memory=n
	$.("mem"+string(n))=state[n]
	}
	point=memory

	point=point+1
	#print(state[point])
	for(n=1 ;n<=$.ncresc ;n++){			# Crescendo
		memory1=n
		for (s=1 ;s<=$.stepcresc ;s++){
			memory2=s
		point=point+1
			$.( "cresc"+string(memory1)+string(memory2))=state[point]
		}
	}
	point=point+1
	#print(state[point])				# Maplist
	point=point+1	
	$.mapnr=(state[point])
	$.mapbut.set($.mapnr)
	$.mapchange($.mapnr)


	point=point+1 					# VolumeStop
	#print(state[point])
	point=point+1

	$.volumestop=state[point]
	for (n=1 ;n<=$.nbreg ;n++){
		$.stopslider[n].set($.volumestop[n])
		$.volstopval[n].set($.volumestop[n])
	}

	point=point+1
	#print(state[point])
	for(n=1 ;n<=$.nbreg ;n++){			# Stopname / num
		point=point+1
		$.stopname[n].set(state[point])
		point=point+1
		memo=n
		$.stopnum[memo]=state[point]
	}

	point=point+1
	#print(state[point])
	point=point+1					# InPort
	$.input= state[point]
	#inport($.input)
	#$.butt1.set(state[point])

	point=point+1
	#print(state[point])
	point=point+1					# OutPort1
	$.output1= state[point]
	#outport($.output)
	#$.butt2.set(state[point])

	point=point+1
	#print(state[point])
	for (n=1 ;n<=4 ;n++){				# keyboardchannelNr
	point=point+1
	$.keybchan[n]= state[point]
	$.chanbut[n].set(state[point])
	}

	point=point+1
	#print(state[point])
	point=point+1
	$.banknr= state[point]				# bank change
	$.bankbut.set(state[point])
	$.bankchange($.banknr)
								# Keyboard Vol
	point=point+1
	#print(state[point])
	point=point+1
	$.volk1= state[point] 
	$.k1slider.set($.volk1)

	point=point+1
	$.volk2= state[point] 
	$.k2slider.set($.volk2)

	point=point+1
	$.volk3= state[point] 
	$.k3slider.set($.volk3)

	point=point+1
	$.volk4= state[point] 
	$.k4slider.set($.volk4)
								# Reverb Vol
	point=point+1		
	#print(state[point])
	point=point+1
	$.volreverbk1= state[point]
	$.reverbsliderk1.set($.volreverbk1)

	point=point+1
	$.volreverbk2= state[point]
	$.reverbsliderk2.set($.volreverbk2)

	point=point+1
	$.volreverbk3= state[point]
	$.reverbsliderk2.set($.volreverbk2)

	point=point+1
	$.volreverbk4= state[point]
	$.reverbsliderk2.set($.volreverbk2)
								# Noise Vol
	point=point+1
	#print(state[point])
	point=point+1
	$.volnoise= state[point]
	$.noiseslider.set($.volnoise)
								# Language
	point=point+1
	#print(state[point])
	point=point+1
	$.languagenr= state[point]
	$.languagechange($.languagenr)
	$.languagebut.set($.languagenr)



	point=point+1
	#print(state[point])
	point=point+1					# Orgue Configuration Name
	$.organname=(state[point])			

 	point=point+1
	#print(state[point])
	for ( n=1; n<= $.nmem ; n++ ) { 		# Coupler Memory
		point=point+1
		memory=n
		$.("memcoupler"+string(memory))=state[point]
	}
								# Tremulant parameters
	point=point+1		
	#print(state[point])
	point=point+1
	$.k1frequency = state[point]
	$.k1freqslider.set($.k1frequency)

	point=point+1
	$.k1modulation = state[point]
	$.k1modslider.set($.k1modulation )

	point=point+1
	$.k2frequency = state[point]
	$.k2freqslider.set($.k2frequency)

	point=point+1
	$.k2modulation = state[point]
	$.k2modslider.set($.k2modulation )

	point=point+1
	$.k3frequency = state[point]
	$.k3freqslider.set($.k3frequency)

	point=point+1
	$.k3modulation = state[point]
	$.k3modslider.set($.k3modulation )

}

method redraw {

	$.w.redraw()
	th = $.textheight()
	tw = $.textwidth()
	y0 = $.ymin() ; y1 = y0+th+4 ; y2 = $.ymax()-4
	x0 = $.xmin() ; x1 = $.xmax()
	dx = (x1-x0) / 34	
	dy = (y2-y0) / 32
      $.text($.computorgue[$.languagenr]+"V1.5",xy(x0+2,y0+0*dy+1,x0+8*dx+8,y0+1*dy-1))
	$.text($.volumes[$.languagenr],xy(x0,y0+1*dy+1,x0+1*dx,y0+2*dy-1))
	$.text($.general[$.languagenr],xy(x0,y0+2*dy+1,x0+1*dx,y0+3*dy-1))
	$.text($.volumes[$.languagenr],xy(x0+22*dx,y0+2*dy+1,x0+23*dx,y0+3*dy-1))
	$.text($.volumes[$.languagenr],xy(x0+22*dx,y0+15*dy+1,x0+23*dx,y0+16*dy-1))
	$.text($.volumes[$.languagenr],xy(x0+11*dx,y0+2*dy+1,x0+12*dx,y0+3*dy-1))
	$.text($.volumes[$.languagenr],xy(x0+33*dx,y0+2*dy+1,x0+34*dx,y0+3*dy-1))
	$.text($.bruit[$.languagenr],xy(x0,y0+6*dy+1,x0+1*dx,y0+7*dy-1))
	$.text($.preselections[$.languagenr],xy(x0+15*dx+1,y0+30*dy, x0+20*dx-1,y0+31*dy-1))
	$.text($.reverb[$.languagenr],xy(x0+22*dx,y0+6*dy+1,x0+23*dx,y0+ 7*dy-1))
	$.text($.reverb[$.languagenr],xy(x0+11*dx,y0+6*dy+1,x0+12*dx,y0+ 7*dy-1))
	$.text($.reverb[$.languagenr],xy(x0+33*dx,y0+6*dy+1,x0+34*dx,y0+ 7*dy-1))
	$.text($.reverb[$.languagenr],xy(x0+22*dx,y0+19*dy+1,x0+23*dx,y0+ 20*dy-1))
	$.text($.crescendo[$.languagenr],xy(x0+0*dx,y0+14*dy+1, x0+1*dx,y0+15*dy-1))
	$.text($.enreg[$.languagenr],xy(x0+0*dx,y0+28*dy+1, x0+1*dx,y0+29*dy-1))
	$.text($.transpose[$.languagenr],xy(x0+1*dx,y0+30*dy+1, x0+4*dx,y0+31*dy-1))
	$.text($.tirasses[$.languagenr],xy(x0+5*dx+2,y0+28*dy+1, x0+11*dx-2,y0+29*dy-1))
	$.text($.anc[$.languagenr],xy(x0+11.5*dx+2,y0+28*dy+1, x0+14.5*dx-2,y0+29*dy-1))
	$.text($.charger[$.languagenr],xy(x0+20*dx,y0+28*dy+1, x0+23*dx-1,y0+29*dy-1))
	$.text($.sauver[$.languagenr],xy(x0+20*dx,y0+29*dy+1, x0+23*dx-1,y0+30*dy-1))
	$.text($.midii[$.languagenr],xy(x0+24*dx,y0+28*dy+1, x0+26*dx,y0+29*dy-1))
	$.text($.midio1[$.languagenr],xy(x0+24*dx,y0+29*dy+1, x0+26*dx,y0+30*dy-1))
	$.text($.midio2[$.languagenr],xy(x0+24*dx,y0+30*dy+1, x0+26*dx,y0+31*dy-1))
	$.text($.enreg[$.languagenr],xy(x0+32*dx+2,y0+30*dy+1, x0+33.5*dx-2,y0+31*dy-1))
	$.text($.mplus[$.languagenr],xy(x0+31*dx+2,y0+30*dy+1, x0+32*dx-2,y0+31*dy-1))
	$.text($.mmoins[$.languagenr],xy(x0+0*dx,y0+30*dy+1, x0+1*dx-2,y0+31*dy-1))
	$.text($.igrandorgue[$.languagenr],xy(x0+5*dx+0,y0+1*dy+1, x0+10*dx-0,y0+2*dy-1))
	$.text($.iipositif[$.languagenr],xy(x0+16*dx+0,y0+1*dy+1, x0+21*dx-0,y0+2*dy-1))
	$.text($.iiirecit[$.languagenr],xy(x0+16*dx+0,y0+14*dy+1, x0+21*dx-0,y0+15*dy-1))
	$.text($.ivpedale[$.languagenr],xy(x0+27*dx+0,y0+1*dy+1, x0+32*dx-0,y0+2*dy-1))
	$.text("-",xy(x0+15*dx, y0+28*dy+1,x0+15.5*dx,y0+29*dy-1))
	$.text("+",xy(x0+19.5*dx, y0+28*dy+1,x0+20*dx,y0+29*dy-1))
	$.text($.banque[$.languagenr],xy(x0+20*dx,y0+30*dy+1, x0+23*dx-1,y0+31*dy-1))
	$.text($.langue[$.languagenr],xy(x0+28.5*dx+2,y0+28*dy+1,x0+31*dx,y0+29*dy-1))
	$.text($.map[$.languagenr],xy(x0+28.5*dx+2,y0+29*dy+1,x0+31*dx,y0+30*dy-1))
	$.text($.organname,xy(x0+7*dx,y0+0*dy+1,x0+33*dx-1,y0+1*dy-1))
	$.text($.canal[$.languagenr],xy(x0+1*dx+2,y0+1*dy+1, x0+4*dx-2,y0+2*dy-1))
	$.text($.canal[$.languagenr],xy(x0+12*dx+2,y0+1*dy+1, x0+15*dx-2,y0+2*dy-1))
	$.text($.canal[$.languagenr],xy(x0+12*dx+2,y0+14*dy+1, x0+15*dx-2,y0+15*dy-1))
	$.text($.canal[$.languagenr],xy(x0+23*dx+2,y0+1*dy+1, x0+26*dx-2,y0+2*dy-1))


	methodbroadcast()
}

method resize(sz) {
#colormix (1,0, 0, 0)
#colormix (0,255*253,255*177,255*128)
colormix (6,65000,65000,65000)

	th = $.textheight()
	tw = $.textwidth()
	if ( nargs() > 0 )
		$.w.resize(sz)
	y0 = $.ymin() ; y1 = y0+th+4 ; y2 = $.ymax()-4
	x0 = $.xmin() ; x1 = $.xmax()
	dx = (x1-x0) / 34	
	dy = (y2-y0) / 32
	$.a1 =xy(x0+8*dx+2,y0+0*dy+1,x0+9*dx-2,y0+1*dy-1); $.bcom.resize($.a1)
	$.a2 =xy(x0+2,y0+3*dy,x0+dx-6, y0+ 6*dy-1); $.slider.resize($.a2)
	$.a3 =xy(x0+11*dx+2,y0+3*dy,x0+12*dx-6, y0+ 6*dy-1);$.k1slider.resize($.a3)
	$.a4 =xy(x0+22*dx+2,y0+3*dy,x0+23*dx-6, y0+ 6*dy-1);$.k2slider.resize($.a4)
	$.a5 =xy(x0+22*dx+2,y0+16*dy,x0+23*dx-6, y0+ 19*dy-1);$.k3slider.resize($.a5)
	$.a6 =xy(x0+33*dx+2,y0+3*dy,x0+34*dx-6, y0+ 6*dy-1);	$.k4slider.resize($.a6)
	$.a7 =xy(x0+1*dx+2,y0+29*dy+1,x0+4*dx-2, y0+ 30*dy-1);$.pitchslider.resize($.a7)
	$.a8 =xy(x0+2,y0+15*dy+1,x0+dx-6, y0+ 21*dy-1);$.crescslider.resize($.a8) 
	$.a9 =xy(x0+2,y0+21*dy+1,x0+dx-6,y0+22*dy-1);$.textstepcresc.resize($.a9)	
	$.a10=xy(x0+4*dx+2,y0+1*dy+1, x0+5*dx-2,y0+2*dy-1);$.chanbut[1].resize($.a10)
	$.a11=xy(x0+15*dx+2,y0+1*dy+1, x0+16*dx-2,y0+2*dy-1);$.chanbut[2].resize($.a11)
	$.a12=xy(x0+15*dx+2,y0+14*dy+1, x0+16*dx-2,y0+15*dy-1);$.chanbut[3].resize($.a12) 
	$.a13=xy(x0+26*dx+2,y0+1*dy+1, x0+27*dx-2,y0+2*dy-1);$.chanbut[4].resize($.a13) 
	$.a14=xy(x0+11*dx+2,y0+7*dy+1,x0+12*dx-6,y0+10*dy-1);$.reverbsliderk1.resize($.a14) 
	$.a15=xy(x0+22*dx+2,y0+7*dy+1,x0+23*dx-6,y0+10*dy-1);$.reverbsliderk2.resize($.a15)
	$.a16=xy(x0+22*dx+2,y0+20*dy+1,x0+23*dx-6,y0+23*dy-1);$.reverbsliderk3.resize($.a16)
	$.a17=xy(x0+33*dx+2,y0+7*dy+1,x0+34*dx-6,y0+10*dy-1);$.reverbsliderk4.resize($.a17) 
	$.a18=xy(x0+2,y0+7*dy+1,x0+1*dx-6,y0+10*dy-1);$.noiseslider.resize($.a18) 
	$.a19=xy(x0+2,y0+31*dy+1,x0+dx-2,y0+32*dy-1);$.bmemm.resize($.a19)	
	$.a20=xy(x0+31*dx+2,y0+31*dy+1,x0+32*dx-2,y0+32*dy-1);$.bmemp.resize($.a20)
	$.a21=xy(x0+1*dx+2,y0+28*dy+1,x0+2*dx-2,y0+29*dy-1);$.btransm.resize($.a21) 	
	$.a22=xy(x0+2*dx+2,y0+28*dy+1,x0+3*dx-2, y0+29*dy-1);$.texttrans.resize($.a22)
	$.a23=xy(x0+3*dx+2,y0+28*dy+1,x0+4*dx-2, y0+29*dy-1);$.btransp.resize($.a23)
	$.a24=xy(x0+5*dx+2,y0+29*dy+1,x0+6*dx-2, y0+30*dy-1);$.bcoupP1.resize($.a24)
	$.a25=xy(x0+6*dx+2,y0+29*dy+1,x0+7*dx-2, y0+30*dy-1);$.bcoupP2.resize($.a25)
	$.a26=xy(x0+7*dx+2,y0+29*dy+1,x0+8*dx-2, y0+30*dy-1);$.bcoupP3.resize($.a26)
	$.a27=xy(x0+8*dx+2,y0+29*dy+1,x0+9*dx-2, y0+30*dy-1);$.bcoup12.resize($.a27)	
	$.a28=xy(x0+9*dx+2,y0+29*dy+1,x0+10*dx-2, y0+30*dy-1);$.bcoup13.resize($.a28)
	$.a29=xy(x0+10*dx+2,y0+29*dy+1,x0+11*dx-2, y0+30*dy-1);$.bcoup23.resize($.a29)
	$.a30=xy(x0+13*dx+2,y0+29*dy+1,x0+14*dx-2, y0+30*dy-1);$.bcallreeds.resize($.a30)
	$.a31=xy(x0+12*dx+2,y0+29*dy+1,x0+13*dx-2, y0+30*dy-1);$.bcancreeds.resize($.a31)
	$.a32=xy(x0+11*dx+2,y0+11*dy+1,x0+11.5*dx-2,y0+14*dy-1);$.k1modslider.resize($.a32)	
	$.a33=xy(x0+22*dx+2,y0+11*dy+1,x0+22.5*dx-2,y0+14*dy-1);$.k2modslider.resize($.a33)
	$.a34=xy(x0+22*dx+2,y0+24*dy+1,x0+22.5*dx-2,y0+27*dy-1);$.k3modslider.resize($.a34)
	$.a35=xy(x0+11*dx+2,y0+10*dy+1,x0+12*dx-6,y0+11*dy-1);$.k1bmod.resize($.a35)	
	$.a36=xy(x0+22*dx+2,y0+10*dy+1,x0+23*dx-6,y0+11*dy-1);$.k2bmod.resize($.a36)
	$.a37=xy(x0+22*dx+2,y0+23*dy+1,x0+23*dx-6,y0+24*dy-1);$.k3bmod.resize($.a37)
	$.a38=xy(x0+10*dx+2,y0+1*dy+1,x0+11*dx-2, y0+2*dy-1);$.bcancelI.resize($.a38)
	$.a39=xy(x0+21*dx+2,y0+14*dy+1,x0+22*dx-2, y0+15*dy-1);$.bcancelIII.resize($.a39)	
	$.a40=xy(x0+21*dx+2,y0+1*dy+1,x0+22*dx-2, y0+2*dy-1);$.bcancelII.resize($.a40)	
	$.a41=xy(x0+26*dx+2,y0+28*dy+1,x0+28.5*dx-2, y0+29*dy-1);$.butt1.resize($.a41)
	$.a42=xy(x0+26*dx+2,y0+29*dy+1,x0+28.5*dx-2, y0+30*dy-1);$.butt2.resize($.a42)
	$.a43=xy(x0+32*dx+2,y0+1*dy+1,x0+33*dx-2,y0+2*dy-1);$.bcancelIV.resize($.a43)
	$.a44=xy(x0+32*dx+2, y0+31*dy+1,x0+33*dx-2,y0+32*dy-1);$.brecmem.resize($.a44)
	$.a45=xy(x0+0*dx+2, y0+26*dy+1,x0+1*dx-6,y0+27*dy-1);$.breccresc.resize($.a45)
	$.a46=xy(x0+23*dx+2,y0+28*dy+1,x0+24*dx-2,y0+29*dy-1);$.bread.resize($.a46)
	$.a47=xy(x0+23*dx+2,y0+29*dy+1,x0+24*dx-2,y0+30*dy-1);$.bwrite.resize($.a47)
	$.a48=xy(x0+15.5*dx,y0+29*dy+1,x0+19.5*dx,y0+30*dy-1);$.temposlider.resize($.a48)
	$.a49=xy(x0+15.5*dx+2,y0+28*dy+1,x0+17.5*dx-2,y0+29*dy-1);$.bmetro.resize($.a49)	
	$.a50=xy(x0+17.5*dx+2,y0+28*dy+1,x0+19.5*dx-2,y0+29*dy-1);$.textvaltempo.resize($.a50)
	$.a51=xy(x0+15*dx,y0+29*dy+1,x0+15.5*dx,y0+30*dy-1);$.button2.resize($.a51)
	$.a52=xy(x0+19.5*dx,y0+29*dy+1,x0+20*dx,y0+30*dy-1);$.button1.resize($.a52)
	$.a53=xy(x0+23*dx+2,y0+30*dy+1,x0+24*dx-2,y0+31*dy-1);$.bankbut.resize($.a53)
	$.a54=xy(x0+31*dx+2,y0+28*dy+1,x0+34*dx-2,y0+29*dy-1);$.languagebut.resize($.a54)
	$.a55=xy(x0+31*dx+2,y0+29*dy+1,x0+34*dx-2,y0+30*dy-1);$.mapbut.resize($.a55)
	$.a56=xy(x0+11.5*dx-2,y0+11*dy+1,x0+12*dx-6,y0+14*dy-1);$.k1freqslider.resize($.a56)
	$.a57=xy(x0+22.5*dx-2,y0+11*dy+1,x0+23*dx-6,y0+14*dy-1);$.k2freqslider.resize($.a57)
	$.a58=xy(x0+22.5*dx-2,y0+24*dy+1,x0+23*dx-6,y0+27*dy-1);$.k3freqslider.resize($.a58)
	#$.a59=xy(x0+26*dx+2,y0+30*dy+1,x0+28.5*dx-2, y0+31*dy-1);$.butt3.resize($.a59)

	for ( n=1; n<=$.nmem ; n++ ){
		$.bmem[n].resize(xy(x0+(n)*dx+2,y0+31*dy+1,x0+(n+1)*dx-2,y0+32*dy-1))
		}
	for ( n=1; n<=25 ; n++ ){
		$.stopslider[n].resize(xy(x0+1*dx+2,y0+(n+1)*dy+1,x0+4*dx-2,y0+(n+2)*dy-1))
		$.volstopval[n].resize(xy(x0+4*dx-2,y0+(n+1)*dy+1,x0+5*dx-1,y0+(n+2)*dy-1))
		$.stopname[n].resize(xy(x0+5*dx+2,y0+(n+1)*dy+1,x0+10*dx-2,y0+(n+2)*dy-1))
		$.breg[n].resize(xy(x0+10*dx+4,y0+(n+1)*dy+1,x0+11*dx-4,y0+(n+2)*dy-1))	}
	for ( n=26; n<=37 ; n++ ){
		$.stopslider[n].resize(xy(x0+12*dx+2,y0+(n+1-25)*dy+1,x0+15*dx-2,y0+(n+2-25)*dy-1))
		$.volstopval[n].resize(xy(x0+15*dx-2,y0+(n+1-25)*dy+1,x0+16*dx-1,y0+(n+2-25)*dy-1))
		$.stopname[n].resize(xy(x0+16*dx+2,y0+(n+1-25)*dy+1,x0+21*dx-2,y0+(n+2-25)*dy-1))
		$.breg[n].resize(xy(x0+21*dx+4,y0+(n+1-25)*dy+1,x0+22*dx-4,y0+(n+2-25)*dy-1))	
		}
	for ( n=38; n<=49 ; n++ ){
		$.stopslider[n].resize(xy(x0+12*dx+2,y0+(n+2-25)*dy+1,x0+15*dx-2,y0+(n+3-25)*dy-1))
		$.volstopval[n].resize(xy(x0+15*dx-2,y0+(n+2-25)*dy+1,x0+16*dx-1,y0+(n+3-25)*dy-1))
		$.stopname[n].resize(xy(x0+16*dx+2,y0+(n+2-25)*dy+1,x0+21*dx-2,y0+(n+3-25)*dy-1))
		$.breg[n].resize(xy(x0+21*dx+4,y0+(n+2-25)*dy+1,x0+22*dx-4,y0+(n+3-25)*dy-1))	
		}
	for ( n=50; n<=74 ; n++ ){
		$.stopslider[n].resize(xy(x0+23*dx+2,y0+(n+2-50)*dy+1,x0+26*dx-2,y0+(n+3-50)*dy-1))
		$.volstopval[n].resize(xy(x0+26*dx-2,y0+(n+2-50)*dy+1,x0+27*dx-1,y0+(n+3-50)*dy-1))
		$.stopname[n].resize(xy(x0+27*dx+2,y0+(n+2-50)*dy+1,x0+32*dx-2,y0+(n+3-50)*dy-1))
		$.breg[n].resize(xy(x0+32*dx+4,y0+(n+2-50)*dy+1,x0+33*dx-4,y0+(n+3-50)*dy-1))		
	}

	for ( n=1; n<= $.ncresc ; n++ ){
	$.bcresc[n].resize(xy(x0+0*dx+2,y0+(22+n)*dy+1,x0+1*dx-6,y0+(23+n)*dy-1))
	}

}
}
function gpitchchange(v) {
	p = ''
	for ( c=0; c<16; c++ )
		p += midibytes(0xe0 | c, 0x00, v)
	return(p)
}

function togglemet() {
	if ( Metid >= 0 ) {
		kill(Metid)
		Metid = -1
	}
	else if ( defined(Met) && Met.length>0 ) {
		tm = nextquant(Now,1b)
		Metid = realtime(Met,tm,Met.length)
	}
	else
		print("No value for Met?!")
}

# If you want to change the commande name according to your language
# you have to modify the following file 
# don't forget to save with the previous text format



function language() {
	return([
		0= [ 0="Variable",1="Français",2="English",3="Deutsch",4="Spanish",5="Italiano",6=" "],
		1= [ 0="$.computorgue" ,  1="Comput'Orgue", 2="Comput'Organ" , 3="Comput'Orgel", 4="Comput'Organ" ,5="Comput'Organ",6=" "],	
		2= [ 0="$.volumes" ,  1="Vol", 2="Vol" , 3="Vol", 4="" ,5="Vol",6=""],	
		3= [ 0="$.general" ,  1="Gen", 2="Gen" , 3="Gen", 4="" ,5="Gen",6=""],	
		4= [ 0="$.bruit" ,  1="Br", 2="Noi" , 3="Noi", 4="" ,5="Mec",6=""],	
		5= [ 0="$.registre" ,  1="Régistre", 2="Stops" , 3="", 4="" ,5="Registn",6=""],
		6= [ 0="$.preselections" ,  1="Preselections", 2="Presets" , 3="Kombinationen", 4="" ,5="Preselezioni",6=""],
		7= [ 0="$.reverb" ,  1="Rev", 2="Rev" , 3="Rev", 4="" ,5="Riv",6=""],	
		8= [ 0="$.crescendo" ,  1="Cre", 2="Cre" , 3="Cre", 4="" ,5="Cre",6=""],	
		9= [ 0="$.enreg" ,  1="Enr", 2="Rec" , 3="S", 4="" ,5="Reg",6=""],	
		10= [ 0="$.transpose" ,  1="-Transp+", 2="-Transp+" , 3="-Transp+", 4="" ,5="-Trasp+",6=""],	
		11= [ 0="$.tirasses" ,  1="Accoupl./Tirasses", 2="Coupling" , 3="Koppeln", 4="" ,5="Unioni",6=""],
		12= [ 0="$.anc" ,  1="-Anch+", 2="-Reed+" , 3="-Zungen+", 4="" ,5="-Ance+",6=""],
		13= [ 0="$.charger" ,  1="Charger", 2="Load" , 3="Oeffnen", 4="" ,5="Apri",6=""],
		14= [ 0="$.sauver" ,  1="Sauver", 2="Save" , 3="Speichern", 4="" ,5="Salva",6=""],
		15= [ 0="$.midii" ,  1="MidiIn", 2="MidiIn" , 3="MidiIn", 4="" ,5="MidiIn",6=""],
		16= [ 0="$.midio1" ,  1="MidiO1", 2="MidiO1" , 3="MidiO1", 4="" ,5="MidiO1",6=""],
		17= [ 0="$.mmoins" ,  1="M-", 2="P-" , 3="M-", 4="" ,5="M-",6=""],
		18= [ 0="$.mplus" ,  1="M+", 2="P+" , 3="M+", 4="" ,5="M+",6=""],
		19= [ 0="$.igrandorgue" ,  1="I Gr.Orgue", 2="I Great" , 3="I Hauptwerk", 4="" ,5="I°Man",6=""],
		20= [ 0="$.iipositif" ,  1="II Positif", 2="II Swell" , 3="II Rueckpositiv", 4="" ,5="II°Man",6=""],
		21= [ 0="$.iiirecit" ,  1="III Récit", 2="III Choir" , 3="III Brustwerk", 4="" ,5="III°Man",6=""],
		22= [ 0="$.ivpedale" ,  1="IV Pédale", 2="IV Pedal" , 3="IV Pedal", 4="" ,5="IV Pedale",6=""],
		23= [ 0="$.banque" ,  1="Banque", 2="Bank" , 3="Bank", 4="" ,5="Banco",6=""],		
		24= [ 0="$.langue" ,  1="Langue", 2="Language" , 3="Sprache", 4="" ,5="Lingua",6=""],		
		25= [ 0="$.map" ,  1="ListReg", 2="StopMap" , 3="RegList", 4="" ,5="Listareg",6=""],
		26= [ 0="$.configue" ,  1="Entrez le nouveau nom de la configuration (ou CR pour abandonner) -> ",
		2="Enter New Organ Configuration Name (or <CR> to abort) -> " ,
		3="Eingabe: neuer name fuer Orgelkonfiguration (abbrechen mit <CR>)", 4="" ,5="Indicare il nuovo nome la console(CR per uscire)",6=""],
		27= [ 0="$.canal" ,  1="Canal", 2="Channel" , 3="Channel", 4="" ,5="Canale",6=""],
		28= [ 0="$.a1" ,  1="Changer le nom de la configuration", 2="Configuration Name Changing" , 3="", 4="" ,5="",6=""],	
		29= [ 0="$.a2" ,  1="Volume Général", 2="General Volume" , 3="", 4="" ,5="",6=""],
		30= [ 0="$.a3" ,  1="Volume clavier I", 2="Keyboard I Volume" , 3="", 4="" ,5="",6=""],
		31= [ 0="$.a4" ,  1="Volume clavier II", 2="Keyboard II Volume" , 3="", 4="" ,5="",6=""],
		32= [ 0="$.a5" ,  1="Volume clavier III", 2="Keyboard III Volume" , 3="", 4="" ,5="",6=""],
		33= [ 0="$.a6" ,  1="Volume clavier IV", 2="Keyboard IV Volume" , 3="", 4="" ,5="",6=""],
		34= [ 0="$.a7" ,  1="Réglage fin de l'accord", 2="Pitch Adjustment" , 3="", 4="" ,5="",6=""],
		35= [ 0="$.a8" ,  1="Volume du Crescendo", 2="Crescendo Volume" , 3="", 4="" ,5="",6=""],
		36= [ 0="$.a9" ,  1="Pas du Crescendo", 2="Crescendo Step" , 3="", 4="" ,5="",6=""],
		37= [ 0="$.a10" ,  1="Canal midi clavier I", 2="Keyboard I Midi Channel" , 3="", 4="" ,5="",6=""],
		38= [ 0="$.a11" ,  1="Canal midi clavier II", 2="Keyboard II Midi Channel" , 3="", 4="" ,5="",6=""],
		39= [ 0="$.a12" ,  1="Canal midi clavier III", 2="Keyboard III Midi Channel" , 3="", 4="" ,5="",6=""],
		40= [ 0="$.a13" ,  1="Canal midi clavier IV", 2="Keyboard IV Midi Channel" , 3="", 4="" ,5="",6=""],
		41= [ 0="$.a14" ,  1="Volume Réverberation Clavier I", 2="Keyboard I Reverberation Volume" , 3="", 4="" ,5="",6=""],
		42= [ 0="$.a15" ,  1="Volume Réverberation Clavier II", 2="Keyboard II Reverberation Volume" , 3="", 4="" ,5="",6=""],
		43= [ 0="$.a16" ,  1="Volume Réverberation Clavier III", 2="Keyboard III Reverberation Volume" , 3="", 4="" ,5="",6=""],
		44= [ 0="$.a17" ,  1="Volume Réverberation Clavier IV", 2="Keyboard IV Reverberation Volume" , 3="", 4="" ,5="",6=""],
		45= [ 0="$.a18" ,  1="Volume du bruit de traction mécanique", 2="Mechanical Tramsmission Noise Volume" , 3="", 4="" ,5="",6=""],
		46= [ 0="$.a19" ,  1="Selection Préselection précédente", 2="Previous Preset Selection" , 3="", 4="" ,5="",6=""],
		47= [ 0="$.a20" ,  1="Selection Préselection Suivante", 2="Next Preset Selection" , 3="", 4="" ,5="",6=""],
		48= [ 0="$.a21" ,  1="Accord -1/2 ton", 2="-1/2 ton Pitch" , 3="", 4="" ,5="",6=""],
		49= [ 0="$.a22" ,  1="Valeur de l'Accord", 2="Pitch Value" , 3="", 4="" ,5="",6=""],
		50= [ 0="$.a23" ,  1="Accord +1/2 ton", 2="+1/2 ton Pitch" , 3="", 4="" ,5="",6=""],
		51= [ 0="$.a24" ,  1="Accouplement Pédale - Clavier I", 2="Coupling Pedal to Keyboard I" , 3="", 4="" ,5="",6=""],
		52= [ 0="$.a25" ,  1="Accouplement Pédale - Clavier II", 2="Coupling Pedal to Keyboard II" , 3="", 4="" ,5="",6=""],
		53= [ 0="$.a26" ,  1="Accouplement Pédale - Clavier III", 2="Coupling Pedal to Keyboard III" , 3="", 4="" ,5="",6=""],
		54= [ 0="$.a27" ,  1="Accouplement Clavier I - Clavier II", 2="Coupling Keyboard I to Keyboard II" , 3="", 4="" ,5="",6=""],
		55= [ 0="$.a28" ,  1="Accouplement Clavier I - Clavier III", 2="Coupling Keyboard I to Keyboard III" , 3="", 4="" ,5="",6=""],
		56= [ 0="$.a29" ,  1="Accouplement Clavier II - Clavier III", 2="Coupling Keyboard II to Keyboard III" , 3="", 4="" ,5="",6=""],
		57= [ 0="$.a30" ,  1="Appel des Anches", 2="Reeds Call" , 3="", 4="" ,5="",6=""],
		58= [ 0="$.a31" ,  1="Annulation des Anches", 2="Reeds Cancel" , 3="", 4="" ,5="",6=""],
		59= [ 0="$.a32" ,  1="Volume Tremblant Clavier I", 2="Keyboard I Tremolo Volume" , 3="", 4="" ,5="",6=""],	
		60= [ 0="$.a33" ,  1="Volume Tremblant Clavier II", 2="Keyboard II Tremolo Volume" , 3="", 4="" ,5="",6=""],
		61= [ 0="$.a34" ,  1="Volume Tremblant Clavier III", 2="Keyboard III Tremolo Volume" , 3="", 4="" ,5="",6=""],
		62= [ 0="$.a35" ,  1="Selection Tremblant Clavier I", 2="Keyboard I Tremolo Selection" , 3="", 4="" ,5="",6=""],
		63= [ 0="$.a36" ,  1="Selection Tremblant Clavier II", 2="Keyboard II Tremolo Selection" , 3="", 4="" ,5="",6=""],
		64= [ 0="$.a37" ,  1="Selection Tremblant Clavier III", 2="Keyboard III Tremolo Selection" , 3="", 4="" ,5="",6=""],
		65= [ 0="$.a38" ,  1="Annulation des Jeux Clavier I", 2="Keyboard I Stops Cancel" , 3="", 4="" ,5="",6=""],
		66= [ 0="$.a39" ,  1="Annulation des Jeux Clavier III", 2="Keyboard III Stops Cancel" , 3="", 4="" ,5="",6=""],
		67= [ 0="$.a40" ,  1="Annulation des Jeux Clavier II", 2="Keyboard II Stops Cancel" , 3="", 4="" ,5="",6=""],
		68= [ 0="$.a41" ,  1="Choix du port MidiIn", 2="MidiIn Port Selection" , 3="", 4="" ,5="",6=""],
		69= [ 0="$.a42" ,  1="Choix du port MidiOut1", 2="MidiOut1 Port Selection" , 3="", 4="" ,5="",6=""],
		70= [ 0="$.a43" ,  1="Annulation des Jeux Clavier IV", 2="Keyboard IV Stops Cancel" , 3="", 4="" ,5="",6=""],
		71= [ 0="$.a44" ,  1="Enregistrement Mémoire", 2="Preset Record" , 3="", 4="" ,5="",6=""],
		72= [ 0="$.a45" ,  1="Enregistrement Crescendo", 2="Crescendo Record" , 3="", 4="" ,5="",6=""],
		73= [ 0="$.a46" ,  1="Charger Fichier de Configuration", 2="Configuration File Saving" , 3="", 4="" ,5="",6=""],
		74= [ 0="$.a47" ,  1="Sauver Fichier de Configuration", 2="Configuration File Loading" , 3="", 4="" ,5="",6=""],
		75= [ 0="$.a48" ,  1="Ajustement du Tempo de Metronome", 2="Metronome Tempo Controle" , 3="", 4="" ,5="",6=""],
		76= [ 0="$.a49" ,  1="Mise en Marche Metronome", 2="Metronome on" , 3="", 4="" ,5="",6=""],
		77= [ 0="$.a50" ,  1="Tempo du Metronome", 2="Metronome Tempo" , 3="", 4="" ,5="",6=""],
		78= [ 0="$.a51" ,  1="Ralentissement du Tempo", 2="Tempo Down" , 3="", 4="" ,5="",6=""],
		79= [ 0="$.a52" ,  1="Accéleration du Tempo", 2="Tempo Up" , 3="", 4="" ,5="",6=""],
		80= [ 0="$.a53" ,  1="Selection de la Banque Midi", 2="Midi Bank Selection" , 3="", 4="" ,5="",6=""],	
		81= [ 0="$.a54" ,  1="Selection de la Langue", 2="Language Selection" , 3="", 4="" ,5="",6=""],
		82= [ 0="$.a55" ,  1="Bibliothèque de Registre", 2="Stop Map Selection" , 3="", 4="" ,5="",6=""],
		83= [ 0="$.a56" ,  1="Frequence Tremblant Clavier I", 2="Keyboard I Tremulant Frequency" , 3="", 4="" ,5="",6=""],
		84= [ 0="$.a57" ,  1="Frequence Tremblant Clavier II", 2="Keyboard II Tremulant Frequency" , 3="", 4="" ,5="",6=""],
		85= [ 0="$.a58" ,  1="Frequence Tremblant Clavier III", 2="Keyboard III Tremulant Frequency" , 3="", 4="" ,5="",6=""],
		86= [ 0="$.a59" ,  1="Choix du port MidiOut2", 2="MidiOut2 Port Selection" , 3="", 4="" ,5="",6=""],
		88= [ 0="$.midio2" ,  1="MidiO2", 2="MidiO2" , 3="MidiO2", 4="" ,5="MidiO2",6=""]

	])
}

function worgstop_inputs(o,po) {
	list = midi("input","list");
	names = []
	vals = []
	i = 0;

	names[i] = "default"
	vals[i] = 0
	i++

	old = Arraysort
	Arraysort = 1
	for ( n in list ) {
		if ( midi("input","isopen",n) ) {
			names[i] = list[n]
			vals[i] = n
			i++
		}
	}
	Arraysort = old
	if ( i == 1 ) {
		names[i] = "No inputs are open (use Port Enabler tool)"
		vals[i] = -1
		i++;
	}
	for ( n=0; n<i; n++ ) {
		o.menucmd(names[n],po,"inputchanged",vals[n],names[n])
	}
}

function worgstop_outputs1(o,po) {
	list = midi("output","list");
	names = []
	vals = []
	i = 0;
	old = Arraysort
	Arraysort = 1
	for ( n in list ) {
		if ( midi("output","isopen",n) ) {
			names[i] = list[n]
			vals[i] = n
			i++
		}
	}
	Arraysort = old
	if ( i == 0 ) {
		names[i] = "No outputs are open (use Port Enabler tool)"
		vals[i] = -1
		i++;
	}
	for ( n=0; n<i; n++ ) {
		o.menucmd(names[n],po,"output1changed",vals[n],names[n])
	}
}

