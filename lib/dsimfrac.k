# Simple Fractal tool
# by Darren Izzard (SeDi) (zysyshelp@yahoo.com)

# Operation is quite simple. Start the tool (best if you put it in
# your liblocal list I think) then move the horizontal slider bar
# to change the value of "a" (higher values give more chaotic
# behavior). Press "Go" when you are ready to start making music!
# (or a fairly poor approximation!) Press it again to stop.
# Press "Snarf" to snarf the contents of the phrase window. Press
# "Clear" to reset the phrase window.

# It can be fun to set several copies of this running with different
# slider settings. The results can be surprisingly musical.

# Use the standard KeyKit tools to change tempo, instrument, volume,
# chorus, reverb...

# Note that use of the "Bang" tool with this one causes the phrase
# window to reset, and the fractal playback algorithm to begin.
# This is a good way of starting several copies of this tool at
# exactly the same time.

# The algorithm is quite simple (see task_playme() method). I got
# it from an old Acorn User magazine article on fractal sound
# generation, and I've seen it mentioned in several books too.

# Known problems: A while back the phrase window didn't refresh
# properly on occasion. I think I've fixed it now though.

class wsimfrac {
	method init() {
		$.w=new window()
		$.inherit($.w)

		$.suppresstitle=0
		$.phrase=''
		$.aval=0
		$.c=[]
		$.c["sl_aval"]=new khslider(0,4500,3000,$,"hslider_update")
		$.c["text_aval"]=new ktext("")
		if($.suppresstitle==0) {
			$.c["text_title"]=new ktext("Simple Fractal, by Darren Izzard")
		}
		$.c["phrasewin"]=new window("phrase")
		$.c["tog_go"]=new ktoggle("Go",$,"tog_go")
		$.c["but_snarf"]=new kbutton("Snarf Phrase",$,"but_snarf")
		$.c["but_reset"]=new kbutton("Clear Phrase",$,"but_reset")
		for(t in $.c)
			$.addchild($.c[t])
		$.a=3.0
		$.z=float(rand(100000))/100000.0
		$.going=0
		$.playtask=0
		$.set('');
		$.setaval(3000);
	}

	method dosuppresstitle() {
		$.suppresstitle=1
		$.removechild($.c["text_title"])
		delete $.c["text_title"]
		$.c["text_title"]=0
	}

	method isgoing() {
		return($.going)
	}

	method tog_go() {
		$.going=1-$.isgoing()
		if($.isgoing()==1) {
			$.a=float($.getaval())/1000.0
			if($.a==0.0) {
				$.a=3.5
			}
			$.playtask=task $.task_playme()
		} else {
			if($.playtask!=0) {
				kill($.playtask)
			}
		}
		$.c["tog_go"].set($.isgoing())
		$.c["tog_go"].redraw()
	}

	method task_playme() {
		a=$.a
		z=$.z
		p=$.get()
		while(1) {
			# Use of ftime variable means that tempo will remain as constant as
			# I can make it, even taking into account the calculations that follow.
			ftime=Now+1b
			z=a*z*(1.0-z)
			if(z<0.0)
				z=0.0
			if(z>1.0)
				z=1.0
			note='c'
			note.pitch=integer(z*127)
			realtime(note)
			p=p+note
			$.set(p)
			sleeptill(ftime)
		}
	}

	method but_reset() {
		$.set('')
		$.z=float(rand(100000))/100000.0
	}

	method but_snarf() {
		setsnarf($.get())
	}

	method hslider_update(curval) {
		$.aval=curval
		$.c["text_aval"].set(sprintf("%.3f",float(curval)/1000.0))
		$.c["text_aval"].redraw()
	}

	method redraw {
		$.w.redraw()
		methodbroadcast()
		$.rebuildphrasewindow()
	}

	method bang {
		if($.isgoing()) {
			$.tog_go()
		}
		$.but_reset()
		$.tog_go()
	}

	method dump {
		a=[]
		a["aval"]=string($.getaval())
		a["phrase"]=string($.get())
		a["z"]=string($.z)
		return(a)
	}

	method restore(state) {
		$.set(phrase(state["phrase"]))
		$.setaval(integer(state["aval"]))
		$.z=float(state["z"])
	}

	method set(phr) {
		$.phrase=phr
		$.rebuildphrasewindow()
	}
	method get { return($.phrase) }

	method rebuildphrasewindow {
		$.c["phrasewin"].fillrectangle($.c["phrasewin"].size(),CLEAR)
		$.c["phrasewin"].view(xy(0,0,$.phrase.length,127))
		$.c["phrasewin"].redraw()
		$.c["phrasewin"].drawphrase($.phrase,STORE)
	}

	method setaval(val) {
		$.aval=val
		$.c["sl_aval"].set($.aval)
		$.hslider_update($.aval)
	}
	method getaval { return($.aval) }

	method resize(sz) {
		if(nargs()>0) {
			$.w.resize(sz)
			# print(string(sz))
		}
		x0=$.xmin()
		x1=$.xmax()
		y0=$.ymin()
		y1=$.ymax()
		if($.suppresstitle==1) {
			ytitle=y0
		} else {
			ytitle=y0+$.textheight()+2
		}
		xsldiv=x1-($.textwidth()*6)
		if(xsldiv<x0) {
			xsldiv=x0
		}
		yunit=(y1-ytitle)/6
		yslider=ytitle+yunit
		ybuttons=ytitle+yunit*2
		xbutdiv1=(x0+x0+x1)/3
		xbutdiv2=(x0+x1+x1)/3

		if($.suppresstitle==0) {
			$.c["text_title"].resize(xy(x0,y0,x1,ytitle))
		}
		$.c["sl_aval"].resize(xy(x0,ytitle,xsldiv,yslider))
		$.c["text_aval"].resize(xy(xsldiv,ytitle,x1,yslider))
		$.c["tog_go"].resize(xy(x0,yslider,xbutdiv1,ybuttons))
		$.c["but_snarf"].resize(xy(xbutdiv1,yslider,xbutdiv2,ybuttons))
		$.c["but_reset"].resize(xy(xbutdiv2,yslider,x1,ybuttons))
		$.c["phrasewin"].resize(xy(x0,ybuttons,x1,y1))
	}
}
