
# grab the last bunch of MIDI input
function grab2(){
start=Now
ph = lastbunch(Recorded,2b)
ph.time-=ph%1.time
realtime(ph,start+seconds(8))
    # Use the velocity value of each note
    # as the pitch of the note.
    
r = ''
    for ( nt in ph ) {
        nt.pitch = nt.vol
       r |= nt
		
    }

	realtime(r,start+seconds(20))
	}
