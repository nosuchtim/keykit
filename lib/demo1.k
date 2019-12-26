# This is stuff from the reference manual.

#############################################
# Play a chord whenever a note below a given pitch is seen.
# The 'chordfunc' parameter should be a function value,
# which is called to generate the chord.
function autochord(chordfunc,limit) {
    Midiin[gettid()] = f = open()
    while ( (n=get(f)) != Eof ) {
        if ( n.pitch < limit )
            realtime(chordfunc(n),0)  # play the chord via MIDI output
    }
}
function major(nt) {
    return ( nt | transpose(nt,4) | transpose(nt,7) )
}
#############################################
class point {
method init {
		# data elements (private as always)
		$.xvalue = 0
		$.yvalue = 0
}
method x 	{ return($.xvalue) }
method y	{ return($.yvalue) }
method set(x,y)	{ $.xvalue = x ; $.yvalue = y }
}
#############################################
class polarpoint {
method init {
        $.pt = new point()
        $.inherit($.pt)
}
method setpolar (ang,r) {
	x = r*cos(ang)
	y = r*sin(ang)
	$.pt.set(x,y)
}
}
