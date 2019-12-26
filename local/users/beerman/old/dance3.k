# The goal of this code is to play phrases
# in response to notes within certain time periods.

function seconds(s1) {
        return(integer((s1*1000000.0*1b)/tempo()))
}

function burton1() {

	start = Now
	# these values are in seconds
        point1 = 1
        point2 = 15
        point3 = 30
        point4 = 45

a1='d4d110,cv40c1 c5c2d140v90,r50,d5c7d40v50 d6c2 a5c4, r80,d3v30d25,e4v40,f+6v50,b3v60,a4 b2,bf5v70,a4v75,f4v80,d6,e5v90c3 f4v90c2,r150,b-4v40c1d75,f5d35c2 f3c4,d450v70,e6c7v60d110 f4c8 '

a2= 'd5v55c1d60 d3c2,c5c6v70,d5c8v70,ev80c7 b3c2,b-5v90,f5 f6c4v80,d5v90,e5c2d150 f4c3'


	# From point1 to point2 seconds, look for pitch 60 and play a1
        task lookandkill(start,point1,point3, 60,72,1,a1)

	# From 20 to 30 seconds, look for pitch 57 and play something else
        task lookandkill(start,point2,point4, 60,72,2,a2)

        # To give an indication of something happening
        
        realtime('p37v110d300c1 p48V80 p66',start+seconds(point1))
        realtime('p42v110d300c1 p55c15V80 p77c5',start+seconds(point2))
        realtime('p40v110d300c1 p38c11V80 p72c12',start+seconds(point3))
        realtime('p45v110d300c1 p29c8V80 p31c9',start+seconds(point4))
}

function lookandkill(start,time1,time2,pitch1,pitch2,ch,phr) {

	sleeptill(start+seconds(time1))

	# spawn the task that will monitor midi input
	# looking for middle C
        t = task lookfornote(pitch1,pitch2,ch,phr)
	
	# that task looking for the note is now going on in parallel
	# with this one.  So we just sleep till the appointed time
	# and then kill the task.

	sleeptill(start+seconds(time2))

        kill(t)
}

function lookfornote(pitch1,pitch2,ch,phr) {
        
        # Arrange for fifo f to get a copy of Midi input,
	# and make sure it's cleaned up when this task 
	# gets killed.

	u = gettid()
	Midiin[u] = f = open()
	onexit(closemidi,u)

	# Remember, the messages we're going to get
	# here include both note-ons and note-offs.

	while ( (m=get(f)) != Eof ) {
                if ( m.type == NOTEON && m.pitch >= pitch1 && m.pitch <=pitch2 && m.channel==ch) {
			# It is assumed that the first note
			# of phr is at time 0, so this should
			# start playing right away.
                        realtime(phr)
		}
	}
}
