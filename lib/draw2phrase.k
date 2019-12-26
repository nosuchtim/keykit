# "Raw to Phrase" tool by Darren Izzard (zysyshelp@yahoo.com)

# This file contains two classes: "krawwindow" and "wrawtophrase"

# The "wrawtophrase" tool allows you to load binary files into
# Keykit, and convert them into phrases, interpreting each byte
# in the file as a note pitch.



# krawwindow - just a custom widget to allow the user to select
#	part or all of a raw file. It appears as a sliderbar-like
#	thing, but you can drag a bar across it to select part of
#	a file. If a file isn't loaded, or there isn't a selection,
#	it displays appropriate messages. "No selection" is signified
#	internally, and in return values, by selection end=-1.

class krawwindow {

	method init() {
		$.w=new window()
		$.w.style(BORDER)
		$.inherit($.w)

		$.filesize=0
		$.selstart=0
		$.selend=-1
	}

	method setfilesize(ns) {
		$.filesize=ns
		$.selstart=0
		$.selend=-1
		$.redraw()
		}

	method getsel() {
		$.normalize()
		return(["start"=$.selstart,"end"=$.selend])
	}

	method setsel(start,end) {
		$.selstart=start
		$.selend=end
		$.normalize()
		$.redraw()
	}

	method dump() {
		$.normalize()
		return(["filesize"=$.filesize,"selstart"=$.selstart,"selend"=$.selend])
	}

	method restore(x) {
		$.filesize=x["filesize"]
		$.selstart=x["selstart"]
		$.selend=x["selend"]
		$.normalize()
	}

	method resize(sz) {
		if ( nargs() > 0 ) {
			$.w.resize(sz)
		}
		$.redraw()
	}

	method redraw() {
		$.w.redraw()

		l=$.w.xmin()
		r=$.w.xmax()
		t=$.w.ymin()
		b=$.w.ymax()
		if(((r-l)<5) || ((b-t)<5)) {
			ofs=0
		} else {
			ofs=2
		}
		l+=ofs
		t+=ofs
		r-=ofs
		b-=ofs
		$.w.fillrectangle(xy(l,t,r,b),CLEAR)
		$.w.rectangle(xy(l,t,r,b))
		if(($.selend>=0)&&($.filesize>0)) {
			$.w.fillrectangle(xy(l+((r-l)*$.selstart)/$.filesize,t,l+((r-l)*$.selend)/$.filesize,b))
		}
		if($.filesize==0) {
			$.w.textcenter("No File Loaded",xy(l,t,r,b))
		} else {
			if($.selend<0) {
				$.w.textcenter("All Selected",xy(l,t,r,b))
			}
		}
	}

	method calcpos(x) {
		l=$.w.xmin()
		r=$.w.xmax()
		t=$.w.ymin()
		b=$.w.ymax()
		if(((r-l)<5) || ((b-t)<5)) {
			ofs=0
		} else {
			ofs=2
		}
		l+=ofs
		r-=ofs
		if((r-l)>0) {
			proj=((x-l)*$.filesize)/(r-l)
		} else {
			proj=0
		}
		if(proj<0) {
			proj=0
		}
		if(proj>$.filesize) {
			proj=$.filesize
		}
		return(proj)
	}

	method mousedown(m) {
		if(m["button"]==1) {
			$.selstart=$.calcpos(m["x"])
			$.selend=-1
			$.redraw()
		}
	}

	method mousedrag(m) {
		if(m["button"]==1) {
			$.selend=$.calcpos(m["x"])
			$.redraw()
		}
	}

	method normalize() {
		if($.selend!=-1) {
			if($.selend<$.selstart) {
				x=$.selend
				$.selend=$.selstart
				$.selstart=x
			}
		}
	}

	method mouseup(m) {
		if(m["button"]==1) {
			$.normalize()
			$.redraw()
		}
		if(m["button"]==2) {
			$.selstart=0
			$.selend=-1
			$.redraw()
		}
	}

}

class wrawtophrase {

	method init() {
		$.w=new window()
		$.inherit($.w)
		$.c=[]
		$.c["rawwin"]=new krawwindow()
		$.c["title"]=new ktext("Raw to Phrase, by Darren Izzard")
		$.c["helpmsg0"]=new ktext("Use the bar above to select")
		$.c["helpmsg1"]=new ktext("all or part of the file.")
		$.c["openbut"]=new kbutton("Open Binary File",$,"but_open")
		$.c["copybut"]=new kbutton("Copy to Phrase",$,"but_copy")
		$.c["snarfbut"]=new kbutton("Snarf Phrase",$,"but_snarf")
		$.c["sizembut"]=new kmenubutton("Size","mkmenu_raw2phrase_size",$)
		$.c["phrase"]=new wphrase()
		for(ctrl in $.c) {
			$.addchild($.c[ctrl])
		}
		
		$.curfile=[]
		$.curfilesize=0
		$.curphrase=''
		$.stoptids=[]
	}		

	method delete {
		killtids($.stoptids)
		$.stoptids=[]
	}

	method get { return($.curphrase) }
	method set(x) { $.curphrase=x }

	method redraw {
		$.w.redraw()
		methodbroadcast()
		$.rebuildphrasewindow()
	}

	method dump {
		return([
			"rawwindow"=$.c["rawwin"].dump(),
			"curfile"=$.curfile,
			"curfilesize"=$.curfilesize,
			"phrase"=string($.get())
			])
	}

	method restore(state) {
		$.c["rawwin"].restore(state["rawwindow"])
		$.curfile=state["curfile"]
		$.curfilesize=state["curfilesize"]
		$.set(phrase(state["phrase"]))
	}

	method but_snarf() {
		setsnarf($.get())
	}

	method but_open() {
		fn=browsefiles("All files (*.*)","*.*",1)
		if(fn!="") {
			$.showbusymessage()
			$.getrawfile(fn)
			$.c["rawwin"].setfilesize($.curfilesize)
			$.curphrase=''
			$.rebuildphrasewindow()
			$.c["openbut"].redraw()
		}
	}

	method showbusymessage() {
			$.fillrectangle($.c["phrase"].size(),CLEAR)
			$.rectangle($.c["phrase"].size())
			$.textcenter("Working, please wait...",$.c["phrase"].size())
	}

	method but_copy() {
		if(sizeof($.curfile)>0) {
			ph=''
			sel=$.c["rawwin"].getsel()
			if(sel["end"]<0) {
				sel["start"]=0
				sel["end"]=$.curfilesize
			}
			for(t=sel["start"]; t<=sel["end"]; t++) {
				note='c'
				note.pitch=$.curfile[t]
				ph+=note
			}
			$.curphrase=ph
			$.rebuildphrasewindow()
		}
	}

	method rebuildphrasewindow {
		$.c["phrase"].set($.curphrase,0)
		$.c["phrase"].fitall()
		$.c["phrase"].redraw()
	}

	method mousedown(m) {
		# bits and pieces borrowed from Markov Maker
		if($.c["phrase"].contains(m)) {
			if($.c["phrase"].isplaying()) {
				$.stop()
			} else {
				tid=$.c["phrase"].play(nextquant(Now,1b))
				$.stoptids[tid]=1
			}
		} else {
			mouseforward(m,"mousedown")
		}
	}

	method bang() {
		if($.c["phrase"].isplaying()) {
			$.stop()
		}
		tid=$.c["phrase"].play(Now)
		$.stoptids[tid]=1
	}

	method stop() {
		killtids($.stoptids)
		$.stoptids=[]
		$.c["phrase"].stop()
	}

	method getrawfile(fname) {
		# for this one, thanks to read1.k in the lib dir.
		f=open(fname,"r")
		fifoctl(f,"type","b")
		$.curfile=[]
		i=0
		while((c=get(f))!=Eof) {
			if(c>127) {
				c=127
			}
			if(c<0) {
				c=0
				# shouldn't happen really though
			}
			$.curfile[i]=c
			i++
		}
		$.curfilesize=i-1
		close(f)
	}

	method setsize(sz) {
		if(sz==0) {
			$.c["rawwin"].setsel(0,-1)
		} else {
			sel=$.c["rawwin"].getsel()
			if(sel["end"]>=0) {
				sel["end"]=sel["start"]+(sz-1)
				if(sel["end"]>$.curfilesize) {
					sel["end"]=$.curfilesize
				}
				$.c["rawwin"].setsel(sel["start"],sel["end"])
			}
		}
	}

	method resize(sz) {
		if(nargs()>0) {
			$.w.resize(sz)
			# print(string(sz))
		}
		x0=$.xmin()
		x1=$.xmax()
		y0=$.ymin()
		y1=$.ymax()

		x0+=2
		x1-=2
		y0+=2
		y1-=2

		titley=y0+$.textheight()
		msght=$.textheight()*2
		btnht=$.textheight()*1.5
		phrht=(y1-y0)-($.textheight()+msght+btnht*3)
		if(phrht<0) {
			phrht=0
		}
		openwd=$.textwidth()*17
		sizewd=$.textwidth()*5
		if(((x1-x0)-(openwd+sizewd))<$.textwidth()) {
			# fair share
			openwd-=($.textwidth()-((x1-x0)-(openwd+sizewd)))*(17.0/22.0)
			sizewd-=($.textwidth()-((x1-x0)-(openwd+sizewd)))*(5.0/22.0)
		}

		$.c["rawwin"].resize(xy(x0+openwd,titley,x1-sizewd,titley+btnht))
		$.c["sizembut"].resize(xy(x1-sizewd,titley,x1,titley+btnht))
		$.c["title"].resize(xy(x0,y0,x1,titley))
		$.c["helpmsg0"].resize(xy(x0,titley+btnht,x1,titley+btnht+msght/2))
		$.c["helpmsg1"].resize(xy(x0,titley+btnht+msght/2,x1,titley+btnht+msght))
		$.c["openbut"].resize(xy(x0,titley,x0+openwd,titley+btnht))
		$.c["copybut"].resize(xy(x0,titley+btnht+msght,x1,titley+btnht*2+msght))
		$.c["snarfbut"].resize(xy(x0,y1-btnht,x1,y1))
		$.c["phrase"].resize(xy(x0,titley+btnht*2+msght,x1,y1-btnht))
	}
}

function mkmenu_raw2phrase_size(o,po) {
	o.menucmd("Select All",po,"setsize",0)
	for(t=0; t<17; t++) {
		sz=1<<t
		if(sz>1) {
			x=" bytes"
		} else {
			x=" byte"
		}
		o.menucmd(string(sz)+x,po,"setsize",sz)
	}
}


