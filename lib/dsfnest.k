# Simple Fractal Nesting tool
# by Darren Izzard (SeDi) (zysyshelp@yahoo.com)

# See docs for Simple Fractal Tool first.

# Move the slider at the top to change the number of Simple Fractal
# sub-tools embedded within the window.

# Start All (re)starts all sub-tools. (Note that you can start, stop,
#   snarf and clear them individually if you prefer.)
# Stop All stops all playing sub-tools.
# Snarf All combines all their phrases and snarfs them together.
# Clear All clears all phrase windows.

# Using the Bang tool with this one will have the same effect as
# pressing the Start All button.

#include "dsimfrac.k"

class wsfnest {
	method init {
		$.maxkids=8
		$.startkids=3

		$.w=new window()
		$.inherit($.w)

		$.numkids=0
		$.c=[]
		$.c["sl_kids"]=new khslider(2,$.maxkids,$.startkids,$,"hslider_update")
		$.c["text_kids"]=new ktext("")
		$.c["text_title"]=new ktext("Simple Fractal Tool Nester, by Darren Izzard")
		$.kids=[]
		for(t=0; t<$.maxkids; t=t+1) {
			$.kids[t]=0
		}
		$.c["but_start"]=new kbutton("Start All",$,"but_startall")
		$.c["but_stop"]=new kbutton("Stop All",$,"but_stopall")
		$.c["but_snarf"]=new kbutton("Snarf All",$,"but_snarf")
		$.c["but_reset"]=new kbutton("Clear All",$,"but_reset")
		for(t in $.c)
			$.addchild($.c[t])
		$.setnumkids($.startkids)
	}

	method but_startall() {
		for(t=0; t<$.numkids; t=t+1) {
			if($.kids[t].isgoing()==1) {
				# stop so we can restart
				$.kids[t].tog_go()
			}
			$.kids[t].tog_go()
			$.kids[t].redraw()
		}
	}

	method but_stopall() {
		for(t=0; t<$.numkids; t=t+1) {
			if($.kids[t].isgoing()==1) {
				$.kids[t].tog_go()
				$.kids[t].redraw()
			}
		}
	}

	method but_reset() {
		for(t=0; t<$.numkids; t=t+1) {
			$.kids[t].but_reset()
		}
	}

	method but_snarf() {
		setsnarf($.get())
	}

	method hslider_update(curval) {
		$.setnumkids(curval)
	}

	method hslider_textupdate(curval) {
		$.c["text_kids"].set(string(curval))
		$.c["text_kids"].redraw()
	}

	method setnumkids(num) {
		if($.numkids!=num) {
			if($.numkids>num) {
				$.clearkids(num)
			} else {
				$.addkids($.numkids,num-1)
			}
			$.numkids=num
			$.resize()
			$.redraw()
			$.c["sl_kids"].set($.numkids)
			$.hslider_textupdate($.numkids)
		}
	}

	method redraw {
		$.w.redraw()
		methodbroadcast()
	}

	method bang {
		$.but_startall()
	}

	method dump {
		a=[]
		a["numkids"]=string($.numkids)
		for(t=0; t<$.numkids; t=t+1) {
			a["kid"+string(t)]=$.kids[t].dump()
		}
		return(a)
	}

	method clearkids(from) {
		for(t=from; t<$.maxkids; t=t+1) {
			if($.kids[t]!=0) {
				$.removechild($.kids[t])
				delete $.kids[t]
				$.kids[t]=0
			}
		}
	}

	method addkids(from,to) {
		for(t=from; t<=to; t=t+1) {
			if($.kids[t]!=0) {
				print("Hey, kids["+string(t)+"] not empty!")
			}
			$.kids[t]=new wsimfrac()
			$.kids[t].dosuppresstitle()
			$.addchild($.kids[t])
		}
	}

	method restore(state) {
		$.setnumkids(integer(state["numkids"]))
		for(t=0; t<$.numkids; t=t+1) {
			$.kids[t].restore(state["kid"+string(t)])
		}
	}

	method get {
		phr=''
		for(t=0; t<$.numkids; t=t+1) {
			phr=phr | $.kids[t].get()
		}
		return(phr)
	}

	method resize(sz) {
		if(nargs()>0)
			$.w.resize(sz)
		x0=$.xmin()
		x1=$.xmax()
		y0=$.ymin()
		y1=$.ymax()
		ytitle=y0+$.textheight()
		xsldiv=x1-($.textwidth()*5)
		if(xsldiv<x0) {
			xsldiv=x0
		}
		yunit=(y1-ytitle)/6
		yslider=ytitle+$.textheight()+6
		ybuttons=yslider+$.textheight()+6
		xbutdiv=(x1-x0)/4
		xbutdiv1=x0+xbutdiv
		xbutdiv2=x0+xbutdiv*2
		xbutdiv3=x0+xbutdiv*3

		ykiddiv=(y1-ybuttons)/$.numkids

		$.c["text_title"].resize(xy(x0,y0,x1,ytitle))
		$.c["sl_kids"].resize(xy(x0,ytitle,xsldiv,yslider))
		$.c["text_kids"].resize(xy(xsldiv,ytitle,x1,yslider))
		$.c["but_start"].resize(xy(x0,yslider,xbutdiv1,ybuttons))
		$.c["but_stop"].resize(xy(xbutdiv1,yslider,xbutdiv2,ybuttons))
		$.c["but_snarf"].resize(xy(xbutdiv2,yslider,xbutdiv3,ybuttons))
		$.c["but_reset"].resize(xy(xbutdiv3,yslider,x1,ybuttons))

		if((ykiddiv>1)&&(ybuttons>0)) {
			for(t=0; t<$.numkids; t=t+1) {
				$.kids[t].resize(xy(x0+2,ybuttons+ykiddiv*t+2,x1-2,ybuttons+ykiddiv*(t+1)-1))
			}
		} else {
			if(ybuttons>0) {
				for(t=0; t<$.numkids; t=t+1) {
					$.kids[t].resize(xy(x0,ybuttons,x1,y1))
				}
			}
		}
	}
}
