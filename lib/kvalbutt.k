#name	kvalbutton
#usage	kvalbutton(vals)

class kvalbutton {
method init (vals,obj,meth,...) {
	$.c = new kmenubutton(vals[0],"kvalbutton_mkmenu",$)
	$.inherit($.c)

	$.vals = arraycopy(vals)
	$.n = 0
	if ( nargs() > 1 )
		$.obj = obj
	else
		$.obj = $0
	if ( $.obj != $0 )
		$.meth = meth
	$.args = argvlist(...)
	$.just = "left"
}
method setjust (s) {
	$.just = s
	$.c.settext($.vals[$.n],$.just)
}
method dump { return(["n"=$.n]) }
method restore (state) { $.set(state["n"]) }
method getvalue { return($.vals[$.n]) }
method getvals { return($.vals) }
method setvals (vals) { $.vals = arraycopy(vals) }
method get { return($.n) }
method set (n) {
	$.n = n
	$.c.settext($.vals[n],$.just)
}
method setbyval(val,doit) {
	if ( nargs() < 2 )
		doit = 0
	for ( n in $.vals ) {
		if ( val == $.vals[n] ) {
			$.n = n
			$.c.settext($.vals[n],$.just)
			if ( doit )
				$.doit()
			return()
		}
	}
	print("Couldn't find val="+string(val)+" in button values")
}
method invoke (n) {
	$.n = n
	$.c.settext($.vals[n],$.just)
	$.c.redraw()
	$.doit()
}
method doit() {
	if ( $.obj != $0 && $.obj != $-1 )
		$.obj.($.meth)($.n,varg($.args))
}
	

}

function kvalbutton_mkmenu(o,po) {
	# it's important to use the getvals() method here (when the menu
	# actually gets created), so we get the latest values in $.vals
	if ( po == $-1 || po == $0 ) {
		print("Hey, kvalbutton_mkmenu gets po==$-1 or $0 !?")
	}
	else if ( ! defined(po.classof) ) {
		print("Hey, kvalbutton_mkmenu called for something that doesn't have classof!?",po)
	}
	else if ( po.classof() != "kvalbutton" ) {
		print("Hey, kvalbutton_mkmenu called for something that isn't a kvalbutton!?",po)
	}
	else {
		vals = po.getvals()
		nv = sizeof(vals)
		for ( n=0; n<nv; n++ )
			o.menucmd(vals[n],po,"invoke",n)
	}
}
