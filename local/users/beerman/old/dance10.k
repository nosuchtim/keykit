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

	#section two
	point9 = 150
	point10= 163
	point11= 170
	point12= 185
	point13= 190
	point14= 200
	point15= 220

	#section three
	point16= 320
	point17= 335
	point18= 345
	point19= 360
	point20= 375
	point21= 385

	#section four (just percussion)
	point22= 485
	point23= 490
	point24= 510
	point25= 520

	#section five (just channels 11-16)
	point26= 525
	point27= 540
	point28= 555
	point29= 570




a1='d4d110,cv40c1 c5c2d140v90,r50,d5c7d40v50 d6c2 a5c4, r80,d3v30d25,e4v40,f+6v50,b3v60,a4 b2,bf5v70,a4v75,f4v80,d6,e5v90c3 f4v90c2,r150,b-4v40c1d75,f5d35c2 f3c4,d450v70,e6c7v60d110 f4c8 '

a2= 'd5v55c1d60 d3c2,c5c6v70,d5c8v70,ev80c7 b3c2,b-5v90,f5 f6c4v80,d5v90,e5c2d150 f4c3'

b1='p57d200v100c4 p60c11 p40c10, p55c2 p79c1,p57 45 69'

b2='p60d548v100c3,62,64c5 76c15d300,p71c7 p83c15'

b3='pc60d50c1 48c8, d4c9 d6c11 a5c16,e4d200c14,b4d130c9 50c10
40 c10, a4c9d23 a3c8 a6c5,d4,c,f4c1d200 c58 30c10 60c10'

b4='d6d100c12v100 d5c6 d4c5 20c10,c60c1 72c2 77c3 61c10,
   d5c5 d6c7,e4 e5 e6 e7'
p1='p45v110c10 55,ed20,f,a,g,55d40'

p2='p45v110c10 55,ed20,f,a,g,55d40'

p3='p50v110d19c10,55,67,44,66 80 22,100,20 51, 30,44,46,47,48,50 30 77'

r1='p40'v127d19 50 60 70 80,r5'p40v80,r5,p42 56,r5,p40 41 55,r5,p40v127 50 52 54,
    p41v80,r5,40,r5'

r2='p48v127d19c10 66 70,r5,p39v80d19 52,r5,p38v80d19 53c9,r5,p48v127d19c10 66 70,r5,
    p39v80d19 52,r5,p42v80d19 47 58c8,r5,p37v80d19c10 56 59,r5'

r3='p45v127d19c10 62 70c11,r5,p39v80d19c10 51,r5,p38v120d19 53c7,r5,p48v127d19c10 66 70c12,r5,
    p39v80d19c10 52,r5,p60v120d19 49 58c13,r5,p37v80d19c10 56 59,r5'


r4= 'p59v127d19c10 70 57c11,r5,p37v80d19c10 51c14,r5,p40v80d19 53c15,r5,p47v127d19c10 66 70c12,r5,
    p53v80d19c10 48c3 60c7 76c5,r5,p60v120d19c10 50 58c8,r5,p37v127d19c10 56 59,r5,
    p49v80d19c10'

	# performance tasks for the bodysynth
	# section one  o'-1'10"
        task lookandkill(start,point1,point2, 60,67,1,p1)
	task lookandkill(start,point1,point2, 60,67,2,a2)
	task lookandkill(start,point2,point3, 60,67,1,a2)
	task panic(point3)
	task lookandkill(start,point3,point4, 60,67,1,b1)
	task lookandkill(start,point3,point4, 60,67,2,b3)
	task lookandkill(start,point4,point5, 60,67,1,b2)
	task lookandkill(start,point4,point5, 60,67,2,a1)
	task lookandkill(start,point5,point6, 60,67,1,p2)
	task lookandkill(start,point6,point7, 60,67,1,b3)
	task lookandkill(start,point6,point7, 60,67,2,b2)

	#section two
	task lookandkill(start,point1,point4, 64,64,1,a2)
	task lookandkill(start,point6,point8, 60,67,1,a1)
	task lookandkill(start,point9,point10, 60,67,1,r1)
	task lookandkill(start,point9,point10, 60,67,2,r2)
	task lookandkill(start,point11,point12, 60,67,1,r3)
	task lookandkill(start,point11,point12, 60,67,2,r4)
	task lookandkill(start,point13,point15, 60,67,1,p1)
	task lookandkill(start,point13,point14, 60,67,2,r2)

	#section three
	task lookandkill(start,point15,point16, 60,67,1,p2)
	task lookandkill(start,point15,point16, 60,67,2,r2)
	task lookandkill(start,point17,point18, 60,67,1,a1)
	task lookandkill(start,point17,point18, 60,67,2,r3)
	task lookandkill(start,point19,point20, 60,67,1,a2)
	task lookandkill(start,point19,point20, 60,67,2,p1)
	task lookandkill(start,point20,point21, 60,67,1,b1)
	task lookandkill(start,point20,point21, 60,67,2,p3)

	#section four
	task lookandkill(start,point22,point23, 60,67,1,r1)
	task lookandkill(start,point22,point23, 60,67,2,r2)
	task lookandkill(start,point23,point24, 60,67,1,r1)
	task lookandkill(start,point23,point24, 60,67,2,r2)
	task lookandkill(start,point24,point25, 60,67,1,r1)
	task lookandkill(start,point24,point25, 60,67,2,r2)

	#section five
	task lookandkill(start,point26,point27, 60,67,1,r1)
	task lookandkill(start,point26,point27, 60,67,2,r2)
	task lookandkill(start,point28,point29, 60,67,1,r1)
	task lookandkill(start,point28,point29, 60,67,2,r2)



	 # not tied to the bodysynth
	#section one
	realtime('p48v110d300c1 p60V80 p67',start+seconds(point1))
        realtime('p60v110d300c1 p55c15V80 p78c5',start+seconds(point2))
        realtime('p48v110d300c1 p64c11V80 p80c12',start+seconds(point3))
        realtime('p60v110d300c1 p69c8V80 p74c9',start+seconds(point4))
        realtime('p36v110d300c1 p48V80 p67',start+seconds(point5))
        realtime('p72v110d300c1 p55c15V79 p77c5',start+seconds(point6))
        realtime('p48v110d300c1 p36c11V80 p74c12',start+seconds(point7))
        realtime('p60v110d300c1 p32c8V80 p72c9',start+seconds(point8))

	#section two
	realtime=(p1,start+seconds(point9))
	realtime=(p1,start+seconds(point11))
	realtime=(p1,start+seconds(point13))

	#section three
	realtime=(r1,start+seconds(point16))
	realtime=(r2,start+seconds(point8))
	realtime=(r3,start+seconds(point20))

	#section four
	realtime('p36v110d300c1 p48V80 p67',start+seconds(point22))
        realtime('p72v110d300c1 p55c15V79 p77c5',start+seconds(point23))
        realtime('p48v110d300c1 p36c11V80 p74c12',start+seconds(point24))
        realtime('p60v110d300c1 p32c8V80 p72c9',start+seconds(point25))

	#section five
	realtime('p36v110d300c1 p48V80 p67',start+seconds(point26))
        realtime('p72v110d300c1 p55c15V79 p77c5',start+seconds(point27))
        realtime('p48v110d300c1 p36c11V80 p74c12',start+seconds(point28))
        realtime('p60v110d300c1 p32c8V80 p72c9',start+seconds(point29))


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

function panic(when)
{
sleeptill(when)
ano()
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
	  {
	{	 m.time-=m%1.time
               x=transpose(m,0)
               realtime(x,Now)}


  if ( m.type == NOTEON && m.pitch >= pitch1 && m.pitch <=pitch2 && m.channel==ch) {
			# It is assumed that the first note
			# of phr is at time 0, so this should
			# start playing right away.
                        realtime(phr)

		}
	}
}
