# This function takes a phrase and produces a file which contains
# line coordinates for drawing a piano-roll version of the phrase.
# This can be fed to a gd-like program for producing a GIF file for web things.

function writelines(p,fn,yzoom,doborder) {
        f = open(fn,"w")
        xsize1 = string(1+latest(p))
	lowpitch = lowest(onlynotes(p))
	if ( nargs() < 3 )
		yzoom = 0
	if ( nargs() < 4 )
		doborder = 1
	if ( yzoom ) {
		highpitch = highest(p)
		ysize = highpitch - lowpitch + 1
	}
	else {
		highpitch = 127
		ysize = 128
	}
        put(f,"size "+xsize1+" "+string(ysize)+"\n")
        xsize = string(latest(p))
	if ( doborder ) {
		put(f,"line 0 0 "+xsize+" 0\n")		# top
		put(f,"line "+xsize+" 0 "+xsize+" "+string(ysize-1)+"\n")	# right
		put(f,"line 0 "+string(ysize-1)+" "+xsize+" "+string(ysize-1)+"\n")	# bottom
		put(f,"line 0 0 0 "+string(ysize-1)+"\n")
	}
        for ( n in p ) {
		if ( n.type != NOTE )
			continue
                ys = string(highpitch-n.pitch)
                put(f,"line "+string(n.time)+" "+ys+" "
                                +string(n.time+n.dur)+" "+ys+"\n")
        }
        close(f)
}
