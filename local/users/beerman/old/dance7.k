# The goal of this code is to play phrases
# in response to notes within certain time periods.

function seconds(s1) {
        return(integer((s1*1000000.0*1b)/tempo()))
}

function burton1() {

	start = Now
	# these values are in seconds
        point1 = 1
        point2 = 10
        point3 = 15
        point4 = 20
        point5 = 40
        point6 = 50
        point7 = 60
        point8 = 70


a1='d4d110,cv40c1 c5c2d140v90,r50,d5c7d40v50 d6c2 a5c4, r80,d3v30d25,e4v40,f+6v50,b3v60,a4 b2,bf5v70,a4v75,f4v80,d6,e5v90c3 f4v90c2,r150,b-4v40c1d75,f5d35c2 f3c4,d450v70,e6c7v60d110 f4c8 '

a2= 'd5v55c1d60 d3c2,c5c6v70,d5c8v70,ev80c7 b3c2,b-5v90,f5 f6c4v80,d5v90,e5c2d150 f4c3'

b1='p57d200v100c4 p60c11 p40c10, p55c2 p79c1,p57 45 69'

b2='p60d548v100c3,62,64c5 76c15d300,p71c7 p83c15'

b3='pc60d50c1 48c8, d4c9 d6c11 a5c16,e4d200c14,b4d130c9 50c10
40 c10, a4c9d23 a3c8 a6c5,d4,c,f4c1d200 c58 30c10 60c10'

b4='d6d100c12v100 d5c6 d4c5 20c10,c60c1 72c2 77c3 61c10,
   d5c5 d6c7,e4 e5 e6 e7'



	# performance tasks for the bodysynth
        task lookandkill(start,point1,point3, 0,128,1,a1)

        task lookandkill(start,point2,point4, 0,128,1,a2)

        # not tied to the bodysynth

        realtime('p48v110d300c1 p60V80 p67',start+seconds(point1))
        realtime('p60v110d300c1 p55c15V80 p78c5',start+seconds(point2))
        realtime('p48v110d300c1 p64c11V80 p80c12',start+seconds(point3))
        realtime('p60v110d300c1 p69c8V80 p74c9',start+seconds(point4))
        realtime('p36v110d300c1 p48V80 p67',start+seconds(point5))
        realtime('p72v110d300c1 p55c15V79 p77c5',start+seconds(point6))
        realtime('p48v110d300c1 p36c11V80 p74c12',start+seconds(point7))
        realtime('p60v110d300c1 p32c8V80 p72c9',start+seconds(point8))

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

	while ( (m=get(f)) != Eof )
	  {      if ( m.type == NOTEON && m.pitch >= pitch1 && m.pitch <=pitch2 && m.channel==ch) {
			# It is assumed that the first note
			# of phr is at time 0, so this should
			# start playing right away.
                        realtime(phr)

		}
	}
}
