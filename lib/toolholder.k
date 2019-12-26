
class toolholder {

method init(notifyobj,tname) {

	$.w = new window()
	$.inherit($.w)

	if ( nargs() < 2 ) {
		t = $0
		$.toolname = ""
		$.tool = $0
	} else {
		if ( ! (tname in Tool) && Readingpage==0 ) {
			print("toolholder init, tname=",tname," NOT IN TOOL!?")
			$.toolname = tname
			$.tool = $0
		} else {
			t = Tool[tname]
			$.toolname = tname
			$.tool = $0    # mainly so that settool doesn't fail
		}
	}

	hname = maketoolholdername()

	if ( hname in Holder_name2obj ) {
		print("HEY, hname=",hname," IS ALREADY IN Holder_name2obj!!!")
	}

	Holder_name2obj[hname] = $
	Holder_obj2name[$] = hname
	$.holdername = hname

	$.text = new ktext($.toolname)
	$.butt = new kmenubutton("Tool","mkmenu_holder",$)
	if ( nargs() > 0 )
		$.notifyobj = notifyobj
	else
		$.notifyobj = $0

	if ( nargs() > 1 )
		$.notifyobj = notifyobj
	else
		$.notifyobj = $0

	$.addchild($.text)
	$.addchild($.butt)
	if ( $.tool != $0 )
		$.addchild($.tool)

	$.grabbed = 0
}
method info() {
	print("ToolHolder, $=",$," holdername=",$.holdername," tool=",$.tool," toolname=",$.toolname)
	o = $.getnotifyobj()
	print("   notifyobj=",o)
	if ( o != $0 && o != $-1 ) {
		print("    notifyobj class=",o.classof(),"  children=",o.children())
	}
}
method getisowner() {
	if ( $.tool != $0 && $.tool != $-1 )
		return(1)
	else
		return(0)
}
method ihavechanged(lengthchanged) {
	$.redraw()
	$.notifyofchange($,lengthchanged)
}
method notifyofchange(changedobj,lengthchanged) {

	if ( nargs() < 2 )
		lengthchanged = 0

	# When a tool holder gets notified of a change,
	# it needs to notify the notifyobj of all tool holders that 
	# share the same tool name.

	notifylist = []
	myname = $.gettoolname()

	for ( hnm in Holder_name2obj ) {
		h = Holder_name2obj[hnm]
		if ( h.gettoolname() == myname ) {
			obj = h.getnotifyobj()
			if ( obj != $0 && obj != $-1 && ! (obj in notifylist)){
				notifylist[h] = obj
			}
		}
	}
	if ( sizeof(notifylist) > 0 ) {
		for ( h in notifylist ) {
			o = notifylist[h]
			o.notifyofchange(h,lengthchanged)
		}
	} else {
		# If there's nobody to notify, we at least need to redraw
		# if ( doredraw )
		#	$.redraw()
	}
}
method rename() {
	oldtname = $.gettoolname()
	t = Tool[oldtname]
	str = getastr("New tool name -> ")
	$.settoolname(str)
	for ( h in Holder_obj2name ) {
		htname = h.gettoolname()
		if ( htname == oldtname )
			h.settoolname(str)
	}
	# update entry in Tool array
	delete Tool[oldtname]
	Tool[str] = t
	$.ihavechanged(0)
}
method untool() {
	o = $.notifyobj
	if ( o != $0 && o != $-1 && o.classof() == "wphrase" ) {
		o.untoolholder($.holdername)
	}
}
method takeover(redraw_givebacks) {
	if ( nargs() < 1 )
		redraw_givebacks = 1
	if ( $.getisowner() ) {
		print("Already owner, no action taken.")
		return()
	}
	# Collect a list of all holders holding the same tool
	tools = []	# index will be holder
	owners = []
	thisname = $.gettoolname()
	for ( h in Holder_obj2name ) {
		if ( h.gettoolname() == thisname ) {
			tools[h] = 1
			if ( h.getisowner() )
				owners[h] = 1
		}
	}
	# There better be only one owner
	n = sizeof(owners)
	if ( n > 1 ) {
		print("Error in toolholder.takeover, sizeof(owners)=",n,"  owners=",owners)
		return()
	}
	# If there are no owners, then it's likely that the real
	# owner was deleted somehow.  Nothing really needs to be done.

	# turn the current owner off
	savetool = $0
	for ( oh in owners ) {
		savetool = oh.gettool()
		oh.giveback(redraw_givebacks)
	}

	if ( savetool != $0 )
		$.settool(savetool)
	$.resize()
	$.redraw()
}
method untakeover() {
	if ( ! $.getisowner() ) {
		print("Not owner, can't release.")
		return()
	}
	# Collect a list of all holders holding the same tool
	nonowners = []	# index will be holder
	owners = []
	thisname = $.gettoolname()
	for ( h in Holder_obj2name ) {
		if ( h.gettoolname() == thisname ) {
			if ( h.getisowner() )
				owners[h] = 1
			else
				nonowners[h] = 1
		}
	}
	# There better be only one owner
	n = sizeof(nonowners)
	if ( n > 0 ) {
		saveh = $0
		for ( hh in nonowners ) {
			saveh = hh;
		}
		if ( saveh != $0 ) {
			saveh.takeover(0)	# don't redraw giveback
		}
		return()
	}
}
method separate() {
	if ( $.getisowner() ) {
		print("You can only separate a reference, not the owner of a tool.")
		return()
	}

	oldtname = $.gettoolname()
	oldt = Tool[oldtname]

	# create the new tool
	$.settooltype(oldt.classof())

	# initialize its contents by getting a dump from the old tool
	newtname = $.gettoolname()
	newt = Tool[newtname]
	if ( defined(oldt.dump) ) {
		d = oldt.dump()
		newt.restore(d)
	}
	$.ihavechanged(1)
}
method giveback(doredraw) {
	if ( $.tool != $0 ) {
		$.removechild($.tool)
	}
	$.tool = $0
	if ( doredraw ) {
		$.resize()
		$.redraw()
	}
}
method redraw {
	$.w.redraw()
	t = $0
	if ( $.tool != $0 && $.tool != $-1 ) {
		t = $.tool
		$.tool.redraw()
	} else {
		xyarr = $.size()
		y0 = xyarr["y0"]
		xyarr["x0"] += 3
		xyarr["y0"] = $.y0a
		xyarr["x1"] -= 3
		xyarr["y1"] -= 3
		$.w.line(xy($.x0a,y0,$.x0a,$.y0a))
		$.w.fillrectangle(xyarr,STORE)
		$.w.text("Reference",xyarr,CLEAR)
	}
	# call redraw of all other children (i.e. the button)
	for ( c in $.children() ) {
		if ( c != t )
			c.redraw()
	}
}
method resize(sz) {
	if ( nargs() > 0 ) {
		$.w.resize(sz)
	} else {
		sz = $.w.size()
	}
	y0 = sz["y0"]
	x0 = sz["x0"]
	x1 = sz["x1"]
	th = $.textheight()
	$.x0a = x0 + $.textwidth()
	$.y0a = y0 + th + 3

	xmid1 = ($.x0a+x1)/2
	$.text.resize( xy($.x0a,y0,xmid1,y0+th) )
	$.butt.resize( xy(xmid1,y0,x1,y0+th) )
	if ( $.tool != $0 && $.tool != $-1 ) {
		sz2 = xy(x0,y0+th,x1,sz["y1"])
		$.tool.resize(sz2)
	}
}

method mousedown(m) {
	x = m["x"]
	y = m["y"]
	if ( x > $.xmin() && x <= $.x0a && y > $.ymin() && y < $.y0a ) {
		if ( $.notifyobj == $0 || $.notifyobj == $-1 ) {
			# This is only if the toolholder is already detached,
			# i.e. not embedded in a wphrase.
			task wmove($,m,1)
		} else {
			grabmouse($)
			$.grabbed = 1
			sz = $.size()
			$.outline = sz
			$.dx = sz["x1"] - sz["x0"]
			$.dy = sz["y1"] - sz["y0"]
			Root.rectangle($.outline,XOR)
		}
	} else {
		$.grabbed = 0
		mouseforward(m,"mousedown")
	}
}

method mousedrag(m) {
	if ( $.grabbed ) {
		# erase old one
		Root.rectangle($.outline,XOR)
		# draw new one
		sz = $.size()
		$.outline = ["x0"=m["x"],"x1"=m["x"]+$.dx,"y0"=m["y"],"y1"=m["y"]+$.dy]
		Root.rectangle($.outline,XOR)
	} else {
		mouseforward(m,"mousedrag")
	}
}
method mouseup(m) {
	if ( $.grabbed ) {
		ungrabmouse($)
		$.grabbed = 0

		Root.rectangle($.outline,XOR)

		oldsz = $.size()

		# Add a new toolholder to the screen
		newh = new toolholder()
		sz = []
		sz["x0"] = m["x"]
		sz["y0"] = m["y"]
		sz["x1"] = sz["x0"] + (oldsz["x1"]-oldsz["x0"])
		if ( sz["x1"] > Root.xmax() ) {
			sz["x1"] = Root.xmax()-2
		}
		sz["y1"] = sz["y0"] + (oldsz["y1"]-oldsz["y0"])
		if ( sz["y1"] > Root.ymax() )
			sz["y1"] = Root.ymax()-2

		tname = $.gettoolname()
		newh.settoolreference(tname)

		Root.addtool(newh,sz)

		newh.takeover()		# this does a redraw, too

	} else {
		mouseforward(m,"mouseup")
	}
}
method settoolname(tname) {
	$.toolname = tname
	$.text.set(tname)
}
method settoolreference(tname) {
	$.settoolname(tname)
	$.tool = $0
}
method settooltype(type,doresizeredraw,...) {
	if ( nargs() < 2 )
		doresizeredraw = 1
	# print("settooltype = ",type," args=",...)
	tf = efunction(type)
	ntool = new tf(...)

	tname = maketoolname()
	Tool[tname] = ntool

	$.settoolname(tname)

	$.settool(ntool)
	if ( doresizeredraw ) {
		$.resize()
		$.ihavechanged(1)
	}
}
method settool(o) {
	# Should we be deleting the tool that we're replacing?  Probably not.
	if ( ! ( $.tool == $0 || $.tool == $-1) ) {
		$.removechild($.tool)
	}
	$.tool = o
	$.addchild($.tool)
	if ( defined(o.setnotify) )
		o.setnotify($)
}
method setnotify(o) {
	$.notifyobj = o
}
method getnotifyobj() {
	return($.notifyobj)
}
method scaleit() {
	t = $.tool
	if ( t == $0 ) {
		if ( $.toolname in Tool ) {
			t = Tool[$.toolname]
		}
	}
	if ( t == $0 || defined(t.scaleit) )
		s = 1
	else
		s = 0
	return(s)
}
method gettool() {
	return($.tool)
}
method gettoolname() {
	return($.toolname)
}
method getholdername() {
	return($.holdername)
}
method nameof() {
	t = $.tool
	if ( defined(t.nameof) )
		nm = t.nameof()
	else
		nm = t.classof()
	return(nm)
}
method getaudition(...) {
	return($.get(...))
}
# This should really be getaudition()
method get(...) {
	t = $.tool

	# hack!
	if ( Readingpage )
		return('')

	if ( t == $0 || t == $-1 ) {
		if ( ! ( $.toolname in Tool ) ) {
			print("toolholder.get, reference to toolname=",$.toolname,", but that's not in Tool!");
			return('');
		}
		t = Tool[$.toolname]
	}
	if ( ! defined(t.get) ) {
		print("No get method in tool?  t=",t)
		return('')
	}
	p = t.get(...)
	p.attrib = ""
	if ( typeof(p) != "phrase" ) {
		print("get() of tool didn't return a phrase?  tool class=",t.classof())
		return('')
	}
	return(p)
}

method set(p) {
	# $.ispicked = p.flags
	t = $.gettool()
	if ( t != $0 && t != $-1 ) {
		if ( defined(t.set) ) {
			t.set(p)
		}
	}
}

method delete {
	if ( $.getisowner() ) {
		print("In toolholder.delete, Owner should be giving the tool to someone?")
		$.untakeover();
	}
# print("TOOLHOLDER.DELETE!  Holder=",$,"  name=",Holder_obj2name[$])
	delete Holder_obj2name[$]
	delete Holder_name2obj[$.holdername]
}
method dump {
	st = []
	st["toolname"] = $.gettoolname()
	t = $.gettool()
	if ( t != $0 && t != $-1 ) {
		# It's the owner of the tool
		st["toolclass"] = t.classof()
		if ( defined(t.dump) )
			st["tooldump"] = t.dump()
		else
			st["tooldump"] = []
	}
	return(st)
}
method restore(s) {
	tname = s["toolname"]
	$.settoolname(tname)
	if ( "toolclass" in s ) {
		# If tool already exists, don't create another copy
		if ( (tname in Tool) && Readingpage==0 )
			print("Hey, tool tname=",tname," already exists!? (B)")
		# It's the owner of the tool, and it doesn't
		# exist already, so instantiate and restore it
		tc = s["toolclass"]
		td = s["tooldump"]
		ff = function(tc)
		if ( ! defined(ff) ) {
			print("No definition for tool class (",tc,") !")
			return()
		}
		t = new ff()
		if ( defined(t.restore) )
			t.restore(td)
		Tool[tname] = t
		$.settool(t)
	}
	$.resize()
}
}

function tooldesc(nt) {
	h = note2holder(nt)
	tool = h.gettool()
	return("tooldesc: nt = "+string(nt)+"  h="+string(h)
		+" tool="+string(tool))
}

function toolnotesdump(tnts) {

	# This is going to produce an array that can be given back
	# to toolnotesrestore, which will recreate the
	# tools and references in the given phrase.

	st = []
	n=0
	for ( nt in tnts ) {
		h = note2holder(nt)
		st[n] = []
		# st[n]["holdername"] = h.getholdername()
		st[n]["toolname"] = h.gettoolname()
		st[n]["time"] = nt.time
		st[n]["dur"] = nt.dur
		t = h.gettool()
		if ( t != $0 && t != $-1 ) {
			st[n]["toolclass"] = t.classof()
			if ( defined(t.dump) )
				st[n]["tooldump"] = t.dump()
			else
				st[n]["tooldump"] = []
		}
		n++
	}
	return(st)
}

function toolnotesrestore(st,notifyobj) {
	# First go through and create all the holders and tools
	newtnp = ''

	# There will be new holders created for all holders.
	# There will also be new tools created.  First instantiate all
	# the tools.
	n=0;
	created = []
	while ( n in st ) {
		s = st[n]
		tname = s["toolname"]
		if ( "toolclass" in s ) {
			# If tool already exists, don't create another copy
			if ( tname in Tool ) {
				# print("Hey! tool tname=",tname," already exists!? (A)")
			}
			else {
				# It's the owner of the tool, and it doesn't
				# exist already, so instantiate and restore it
				tc = s["toolclass"]
				td = s["tooldump"]
				ff = function(tc)
				if ( ! defined(ff) ) {
					print("No definition for tool class (",tc,") !")
					continue
				}
				t = new ff()
				if ( defined(t.restore) )
					t.restore(td)
				Tool[tname] = t
				created[tname] = t
			}
		}
		n++
	}
	n=0;
	while ( n in st ) {
		s = st[n]
		tname = s["toolname"]
		if ( ("toolclass" in s) && (tname in created) ) {
			h = new toolholder(notifyobj,tname)
			tname = s["toolname"]
			h.settoolname(tname)
			h.settool(Tool[tname])
		} else {
			h = new toolholder(notifyobj)
			tname = s["toolname"]
			# It's just a reference to the tool.
			h.settoolreference(tname)
# print("RESTORED TOOL REFERENCE  h=",h,"   toolname=",tname);
		}

		tm = s["time"]
		d = s["dur"]
		newnt = makeholdernote(tm,tm+d,h)
		newtnp |= newnt
		n++
	}
	return(newtnp)
}

function mkmenu_holder(o,po) {
	o.submenu("Type  ->","mkmenu_holdertype",po)
	o.menucmd("UnTool",po,"untool")
	o.menucmd("Rename",po,"rename")
	# o.menucmd("UnTakeover",po,"untakeover")
	o.menucmd("Takeover",po,"takeover")
	o.menucmd("Separate",po,"separate")
	o.menucmd("Debug",po,"info")
}

function mkmenu_holdertype(o,po) {
	names = tooltypesall()
	nn = sizeof(names)
	# Create a menu of all the tools that are "trackable"
	for ( n=0; n<nn; n++ ) {
		a = names[n]
		if ( "trackable" in a ) {
			o.menucmd(a["name"],po,"settooltype",a["class"])
		}
	}
}

Toolindex = 1
Toolholderindex = 1
function maketoolname() {
	s = "T"+string(Toolindex++)
	while ( s in Tool ) {
		s = "T"+string(Toolindex++)
	}
	return(s)
}
function maketoolholdername() {
	hn = "H"+string(Toolholderindex++)
	while ( hn in Holder_name2obj )
		hn = "H"+string(Toolholderindex++)
	return(hn)
}
