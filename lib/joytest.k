function joymon() {
	o = new joytestobj()
	Root.waitforconsolekey()
	deleteobject(o)
}
function joytest() {
	print("Press START on any joystick when you're done testing...")
	o = new joytestobj()
	o.waittillstart()
	deleteobject(o)
}

class joytestobj {
method init {
	$.j = getjoymonitor()
	$.arr = joyinit()
	for ( jn in $.arr ) {
		$.j.notify($,jn)
	}
	lock($)
}
method delete {
	for ( jn in $.arr ) {
		$.j.unnotify($,jn)
	}
}
method waittillstart {
	lock($)
	unlock($)
}
method analogchange(jn,nm,v) {
	print("Analogchange, jn=",jn," nm=",nm," v=",v)
}
method buttonchange(jn,nm,v) {
	print("Buttonchange, jn=",jn," nm=",nm," v=",v)
	if ( nm == "START" && v == 0 )
		unlock($)
}
}
