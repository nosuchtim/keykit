#
# by Marin Taunton, maru@tauntonm.freeserve.co.uk
#

Mmstate = 0	# 1 if a note is currently playing
Mmode = 0
Mmnotes = ''
Mmpitches = ''
Mmquant = 0
MatrixSnarf = 1
Snarfharmony = ''
A=65535
B=32767
colormix(5,A,0,0)
colormix(6,0,A,0)
colormix(7,0,0,A)
colormix(8,0,0,B)
Currcolor = 5
Toolmode = 0

class wharmony
{
method init{
	#default to GEN MIDI STRINGS on CH1
	First = 1
	Last=[]
	realtime('xc331')
#reverb127
	realtime('xb35b7f')
#default to strings at startup
 	Str = 0 
#chord length 384 by default
	Len = 384
#default octave.  
	Shift = 0
#arrays for molody note, chords(eg 0,3,7,12), and chord types(eg dim7)
	$.nt = []
	$.ch = []
	$.chdtype=[]
#class definition
	$.w = new window()
	$.inherit($.w)
#melody not names
$.keys = [0="C",1="C#",2="D",3="D#",4="E",5="F",
	6="F#",7="G",8="G#",9="A",10="A#",11="B"]
#used to map the chords in case they need rearranging
	p=[0=0,1=8,2=10,3=12,4=1,5=13,6=19,7=6,8=21,9=23,10=9,11=17,12=22,13=5,14=20,
	15=16,16=2,17=14,18=11,19=4,20=18,21=7,22=15,23=3,24=24]
#chord intervals
$.chords=[p[0]="0.4.7.12",p[1]="0.6.9.12",p[2]="3.6.9.12",p[3]="2.6.9.12",
	p[4]="0.5.9.12",p[5]="3.5.9.12",p[6]="2.5.9.12",p[7]="0.4.9.12",p[8]="4.7.9.12",
	p[9]="4.6.9.12", p[10]="0.3.9.12",p[11]="3.7.9.12",p[12]="4.5.9.12",p[13]="0.5.8.12",
	p[14]="3.5.8.12",p[15]="2.5.8.12",p[16]="0.3.8.12",p[17]="3.6.8.12",
	p[18]="4.7.10.12",p[19]="0.3.7.12",p[20]="3.7.10.12",p[21]="0.3.6.12",
		p[22]="3.6.10.12",p[23]="0.5.7.12",p[24]="0,4,8,12"]
#used to shift the chord root 
$.scnms=[p[0]=0,p[1]=6,p[2]=0,p[3]=2,p[4]=5,p[5]=5,p[6]=2,p[7]=9,p[8]=9,p[9]=9,
				p[10]=9,p[11]=9,p[12]=5,p[13]=5,p[14]=5,p[15]=2,p[16]=8,p[17]=8,
				p[18]=0,p[19]=0,p[20]=0,p[21]=0,p[22]=0,p[23]=0,p[24]=0]
#chord types 
$.types=[p[0]="Maj",p[1]="dim",p[2]="dim7",p[3]="7",p[4]="Maj",p[5]="7",p[6]="m7",p[7]="m",p[8]="m7",
				p[9]="m6",p[10]="dim",p[11]="m7b5",p[12]="M7",p[13]="m",p[14]="m7",p[15]="m7b5",p[16]="Maj",
				p[17]="7",p[18]="7",p[19]="m",p[20]="m7",p[21]="dim",p[22]="m7b5",p[23]="sus4",p[24]="aug"]
#no of chord types currently used to determine grid row number	
$.nchords = 25
#12 possible melody notes with four positions each for varing the chord root
	$.grid = new wgrid(48,$.nchords)
	$.addchild($.grid)
	$.group = new wgroup()
	$.addchild($.group)
#button to lower octave
	$.octdown = new kbutton("Octave down",$,"down")
	$.addchild($.octdown)
#button to raise octave
	$.octup = new kbutton("Octave up",$,"up")
	$.addchild($.octup)
#button to select strings
	$.bow = new kbutton("Bow",$,"string")
	$.addchild($.bow)
#button to select guitar
	$.strum = new kbutton("Strum",$,"pluck")
	$.addchild($.strum)
#button to select 1 beat
	$.one = new kbutton("1",$,"onebeat")
	$.addchild($.one)
#button to select 2 beats
	$.two = new kbutton("2",$,"twobeat")
	$.addchild($.two)
#button to select 3 beats
	$.three = new kbutton("3",$,"threebeat")
	$.addchild($.three)
#button to select 4 beats  
	$.four = new kbutton("4",$,"fourbeat")
	$.addchild($.four)
#button to undo last chord entry
	$.undo = new kbutton("Undo",$,"toolundo")
	$.addchild($.undo)
#button to enter silence
	$.blank = new kbutton("Rest",$,"rest")
	$.addchild($.blank)
#button to set Toolmode to lines 
	$.lmode = new kbutton("/",$,"linemode")
	$.addchild($.lmode)
#button to set Toolmode to chords 
	$.cmode = new kbutton("=",$,"chordmode")
	$.addchild($.cmode)
#button to delete all depending on mode
	$.delall = new kbutton("X",$,"startover")
	$.addchild($.delall)
#callbacks from grid
	$.grid.setcallbackdown($,"gotdown")
	$.grid.setcallbackup($,"gotup")
	$.grid.setcallbackdrag($,"gotdrag")
#text button to display chord currently sounding
	$.chtxt = new ktext("CHORD")
	$.addchild($.chtxt)
#load melody notes accross top opf grid
		for(txt=0;txt<12;txt++)
			{
			$.nt[txt] = new kbutton($.keys[txt],$,"fill",$.keys[txt])
			$.addchild($.nt[txt])
			
			}
#load chord intervals (ex (0,3,7,12)) down left of grid
		for(chd=0;chd<$.nchords;chd++)
			{
			$.ch[chd] = new ktext($.chords[chd])
			$.addchild($.ch[chd])
			
			}
#load chord types down right of grid
		for(ctype=0;ctype<$.nchords;ctype++)
			{
			$.chdtype[ctype] = new ktext($.types[ctype])
			$.addchild($.chdtype[ctype])
			
			}
		}
method resize (sz) {
			if ( nargs() > 0 )
				$.w.resize(sz)
			$.dy = $.textheight() 
			tw = $.textwidth()
			$.grid.resize(xy($.xmin(),$.ymin()+4*$.dy,($.xmax()+$.xmin())/2,$.ymax()-10))
			$.xm = ($.xmin()+$.xmax())/float(2)
			if ( $.xm < ($.xmax()-9*tw) )
				$.xm = ($.xmax()-9*tw)
			l = $.grid.xmin()
			m = $.grid.xmax()
			n = $.grid.ymin()
			o = $.grid.ymax()
			$.group.resize(xy((3*$.xmin()+5*$.xmax())/8,$.ymin(),$.xmax(),$.ymax()))

			gapx = (m-l)/float(12)
			Gapc = gapx/float(4)
			gapy = (o-n)/float($.nchords)
			Gapr = gapy
			for(txt=0;txt<12;txt++)
			{
			$.nt[txt].resize(xy(l+txt*gapx,$.ymin()+4*$.dy,l+(txt+1)*gapx,$.ymin()+3*$.dy))
			}
			#for(chd=0;chd<$.nchords;chd++)
				#{
				#$.ch[chd].resize(xy($.xmin()+5,n+chd*gapy,l-5,n+chd*gapy+$.dy))
				#}
			for(ct=0;ct<$.nchords;ct++)
				(
				$.chdtype[ct].resize(xy(m+2,n+ct*gapy,$.group.xmin(),n+ct*gapy+$.dy))
				)
			$.octup.resize(xy(l+9*gapx,$.ymin()+$.dy,l+12*gapx,$.ymin()+$.dy*3))
			$.octdown.resize(xy(l,$.ymin()+$.dy,l+3*gapx,$.ymin()+$.dy*3))
			$.chtxt.resize(xy(l+ 3*gapx,$.ymin()+$.dy,l+9*gapx,$.ymin()+$.dy*3))
			$.undo.resize(xy(l+12*gapx,$.ymin(),l+13.5*gapx,$.ymin()+$.dy))
			$.strum.resize(xy(l+12*gapx,$.ymin()+$.dy,l+13.5*gapx,$.ymin()+$.dy*2))
			$.bow.resize(xy(l+12*gapx,$.strum.ymax(),l+13.5*gapx,$.strum.ymax()+$.dy))
			$.one.resize(xy($.strum.xmax(),$.ymin(),$.group.xmin(),$.ymin()+$.dy))
			$.two.resize(xy($.strum.xmax(),$.one.ymax(),$.group.xmin(),$.one.ymax()+$.dy))
			$.three.resize(xy($.strum.xmax(),$.two.ymax(),$.group.xmin(),$.two.ymax()+$.dy))
			$.four.resize(xy($.strum.xmax(),$.three.ymax(),$.group.xmin(),$.three.ymax()+$.dy))
			$.blank.resize(xy(l+12*gapx,$.bow.ymax(),l+13.5*gapx,$.bow.ymax()+$.dy))
			$.lmode.resize(xy(l+9*gapx,$.ymin(),l+10*gapx,$.ymin()+$.dy))
			$.cmode.resize(xy(l+10*gapx,$.ymin(),l+11*gapx,$.ymin()+$.dy))
			$.delall.resize(xy(l+11*gapx,$.ymin(),l+12*gapx,$.ymin()+$.dy))
	}
method redraw {   First = 1
			$.w.redraw()
			$.dy = $.textheight() 
			$.w.textleft("MELODY HARMONISER",xy($.xmin(),$.ymin(),
					$.xm,$.ymin()+$.dy))
			methodbroadcast()
		}
method gotdown (m,ms) { $.mmdown(m,ms) }
method gotup (m,ms) { $.mmoff(m,ms) }
method gotdrag (m,ms) { $.mmdrag(m,ms) }

method mmmap(m,ms) {
	if(Str==0)
		{n1 = n2 = n3 = n4 = n5 = 'ar'
		n1.dur=n2.dur=n3.dur=n4.dur=n5.dur = Len
		}
		else
		{
		n1 = n2 = n3 = n4 = n5 = 'a'
				
		n5.length=10;n5.dur=Len
		n1.length=10;n1.dur = Len-10
		n2.length=10;n2.dur = Len-20
		n3.length=10;n3.dur = Len-30		
		n4.length=10;n4.dur = Len-40
		}
	c = m["col"]
	r = m["row"]
#extract relative note pitches from chord intervals
	nt1  = substr($.chords[r],1,1)
	nt2 = substr($.chords[r],3,1)
	nt3 =  substr($.chords[r],5,2)
	nt4 = 12
		# construct the phrase 
		b = (c-c%4)/4
		step= [0=integer(nt1),1=integer(nt2),2=integer(nt3),3=integer(nt4)]
		n1.pitch = 48+step[0]+b
		n2.pitch = 48+step[1]+b
		n3.pitch = 48+step[2]+b
		n4.pitch = 48+step[3]+b
		n5.pitch = 24+step[c%4]+b  #root note varies cell [c%4]
		left = $.keys[(b+$.scnms[r])%12]+$.types[r]
		right = $.keys[(b+step[c%4])%12]

#make melody note and base note satnd out a bit
		n1.vol=n2.vol=n3.vol = 100
		n5.vol = n4.vol = 100 
#construct the complete chord based on the selected cell
				colorset(1)
		$.chtxt.set($.keys[b]+"/"+left+"/"+right)
		Ctext=$.chtxt.get()
		$.chtxt.redraw()
#either strum (for guitar) or play simultaneously (for strings)
		if (Str==0)
		p = n1|n2|n3|n4|n5
		else
		p= n5+n1+n2+n3+n4
		p.pitch+=12*Shift
		p.chan = 4
		Ly = phrase("'\"Lyric="+string(left)+"/"+string(right)+"\"'")
		ph=Ly|p 
		return(ph)
}

method mmon {
	Mmstate = 1
	Mmnotes = Mmpitches
	Mmnotes.type = NOTEON
	c = Now
	if ( Mmquant )
		c = nextquant(c,Mmquant)
	realtime(Mmnotes,c)
	if ( MatrixSnarf ) {
		Mmnotes.type = NOTE
		Snarf = Mmnotes
		Snarfharmony += Snarf
	}
}

method mmoff {
		colorset(1)
	if ( Mmstate ) {
		Mmstate = 0
		
		Mmnotes.type = NOTEOFF
		c = Now
		if ( Mmquant )
			c = nextquant(c,Mmquant)
		realtime(Mmnotes,c)
			}
}

method mmdown(m,ms) {r=m["row"];c = m["col"]

				if(First==1)
					{First = 0
					Last =["x"=centre(r,c)["x"],"y" = centre(r,c)["y"]]
					colorset(Currcolor)
					}
					else
		{
				colorset(Currcolor)
				This =["x"=centre(r,c)["x"],"y" = centre(r,c)["y"]]
				if(ms["button"]==2&& Toolmode==0)
				{$.line(["x0"=Last["x"],"y0"=Last["y"],"x1"=This["x"],"y1"=This["y"]])
					Undo = Last
					Last = This
					Currcolor+=1
					if (Currcolor==9)Currcolor=5
					return()
				}
		}
					
				$.mmoff()		# in case of multiple downs
				Mmpitches = $.mmmap(m,ms)
				if ( ms["button"] == 2 && Toolmode == 1)
				{$.group.paste(1,Mmpitches,1)
				}
				
				$.mmon()

	}
method mmdrag(m,ms) {
	newpitches = $.mmmap(m,ms)
		if ( newpitches != Mmpitches ) {
		$.mmoff()
		Mmpitches = newpitches
			      
		$.mmon()
		}
	}
method up(){
if (Shift==2)return()
Shift+=1
}
method down(){
if (Shift==-1)return()
Shift+=-1
}
method pluck()
{Str = 1
realtime('xc318')
}
method string()
{Str = 0
realtime('xc331')
}
method onebeat()
{
print(nargs())
Len = 96
}
method twobeat()
{
Len = 192
}

method threebeat()
{
Len = 288
}

method fourbeat()
{
Len = 394
}
method toolundo()
{
if (Toolmode == 1)
$.group.undo()
else
		{
		$.line(["x0"=Undo["x"],"y0"=Undo["y"],"x1"=This["x"],"y1"=This["y"]],CLEAR)
		Currcolor -=1
		if(Currcolor ==3)Currcolor = 8
		Last = Undo
		}		
}
method rest()
{
phr = '"Lyric=rest",ac10o-3v1'
phr.dur=Len
$.group.paste(1,phr,1)
}
method linemode(){
			Toolmode = 0
			}
method chordmode(){
			Toolmode = 1
				}
method startover(){
	if(Toolmode==0)
		{First = 1
		$.grid.redraw()}
		
			}
method fill()
{
l = $.grid.xmin()
t = $.grid.ymin()
for(r=0;r<$.nchords;r++)
	{for(c=0;c<48;c++)
		{
		nt1  = substr($.chords[r],1,1)
		nt2 = substr($.chords[r],3,1)
		nt3 =  substr($.chords[r],5,2)
		nt4 = 12
		b = (c-c%4)/4
		step= [0=integer(nt1),1=integer(nt2),2=integer(nt3),3=integer(nt4)]
		right = $.keys[(b+step[c%4])%12]
		mx=l+(c+0.5)*Gapc
		my=t+(r+0.5)*Gapr
		xyarr=["x0"=mx,"y0"=my,"x1"=mx+1,"y1"=my+1]
		if (argv(0) == right)
		$.fillrectangle(xyarr,XOR)
		else 
		$.fillrectangle(xyarr,CLEAR)
		}
	}
	}	
}
function centre(r,c)
{	
l = $.grid.xmin()
t = $.grid.ymin()
return(["x"=l+(c+0.5)*Gapc,"y"=t+(r+0.5)*Gapr])
}

