#  WATER LILES for bodysynth (dancer) and electric clarinet
# The goal of this code is to play phrases
# in response to notes within certain time periods.
function seconds(s1) {

        return(integer((s1*1000000.0*1b)/tempo()))
}

function burton1() {
	stackhack(600)
	start = Now
	# these values are in seconds
        point1 = 1
        point2 = 10
        point3 = 15
        point4 = 20
        point5 = 40
        point6 = 50
        point7 = 60	#1'
        point8 = 70

	#new insert 1
	point8a=80
	point8b=100	#1'40"
	point8c=110
	point8d=120	#2'
	point8e=130
	point8f=140	#2'20"

	#section two
	point9 = 150 	#2'30"
	point10= 163
	point11= 170	#2'50"
	point12= 185	#3'05"
	point13= 190	#3'10"
	point14= 200	#3'20"
	point15= 220	#3'40"

	#new insert two
	point15a=230
	point15b=250	#4'10"
	point15c=270	#4'30"
	point15d=280
	point15e=290
	point15f=300	#5'
	point15g=310

	#section three
	point16= 320	#5'20"
	point17= 335	#5'35"
	point18= 345	#5'45"
	point19= 360	#6'
	point20= 375	#6'15"
	point21= 385	#6'25"

	#new insert three
	point21a=395	#6'35"
	point21b=410	#6'50"
	point21c=420	#7'
	point21d=430
	point21e=445	#7'25"
	point21f=460	#7'40"

	#section four (just percussion)
	point22= 485	#8'05"
	point23= 490	#8'10"
	point24= 510	#8'30"
	point25= 520	#8'40"

	#section five (just channels 11-16)
	point26= 525	#8'45"
	point27= 540	#9'
	point28= 555	#9'15"
	point29= 570	#9'30"
	point30= 600
	point31= 630



# phrases used by the bodysynth and called by variable name

#fragments
f1='d4c5v100d300 a3c11d200,g4c13d200 d5c14 d5c7'
f2='a5c8d70,g4c9d26 g4c16,f4c15 f3c4,c4c14d200 c5c6 c6c3'
f3='e-4c9d20 e-5c14,f4c13 f3c6,a-6c2 a-4c12,gc1d300c11,g5c4'

#variations
#f1a=reverse(f1)
#f2a=shuffle(f2)
#f3a=flip(f3,g4)

#clarinet melody
m1='a3c13v100d400 a2c4 e4c5 a4c6,b4c1d18,g4d400 d5c6 a5c14'
m2='a3d70v110c14,d3d16,f+4d150c7 f+5c8,a4d70c11 e5c9 a5c15,g4d400c6 d5 g5'
m3='c5d80v100c1,fc15,c5d18,f4c2,d3c3,c4c4,e5c5,f4c6,g5d500c16 g6c15 d6c7'

#rythmic fragments
r1='cv127d22c10 d4 e5c2,r55,a2c10v90d77 f5c2d33,gc10 d,av127 gc2 bc3,ev90c10,d,a,f'
r2='f5c10d80v90 f4 e3,r50,b2c10v127d50 c3 d4 e5,g4c10d100v90 a5,d4c2v120 a6 e7d40,d4c10v90d29,a5,g4,e3'
r3='cv127d22c10 d4 e5c2,r55,a2c10v90d77 f5c2d33,gc10 d,av127 gc2 bc3,ev90c10,d,a,f'
r4='f5c10d80v90 f4 e3,r50,b2c10v127d50 c3 d4 e5,g4c10d100v90 a5,d4c2v120 a6 e7d40,d4c10v90d29,a5,g4,e3'
r5='g2d70c3v100 a4c10 e-5,r29,d2c10v90d30,e5,g4,d6,g5,fv110 c d g,ev90'
r6='b-2c3v87d44 f+5c10,r40,fc10v90d27,gc1 ac10 bc3,gc10,d,f,e'

	# performance tasks for the bodysynth
	#point 1 to 2 0-10"
     task lookandkill(start,point1,point2, 60,63,1,f1)
	 task lookandkill(start,point1,point2, 60,63,2,f2)
 	 task lookandkill(start,point1,point2, 60,63,3,f3)
		task panic(point2)
		
	#point 2-3 15"	
	 task lookandkill(start,point2,point3, 60,63,1,m1)
	 task lookandkill(start,point2,point3, 60,63,2,m2)
 	 task lookandkill(start,point2,point3, 60,63,3,m3)
		task panic(point3)

	#point 3 to 4 20"
		# task lookandkill(start,point3,point4, 60,63,1,f1a)
		# task lookandkill(start,point3,point4, 60,63,2,f2a)
	 	# task lookandkill(start,point3,point4, 60,63,3,f3a)
		task panic(point3)
	
	 # not tied to the bodysynth
	#section one
	    realtime('p48v110d300c1 p60V80 p67',start+seconds(point1))
        realtime('p60v110d300c2 p55c15V80 p78c5',start+seconds(point2))
        realtime('p48v110d300c3 p64c11V80 p80c12',start+seconds(point3))
        realtime('p60v110d300c4 p69c8V80 p74c9',start+seconds(point4))
        realtime('p36v110d300c5 p48V80 p67',start+seconds(point5))
        realtime('p72v110d300c6 p55c15V79 p77c5',start+seconds(point6))
        realtime('p48v110d300c7 p36c11V80 p74c12',start+seconds(point7))
        realtime('p60v110d300c8 p32c8V80 p72c9',start+seconds(point8))

	#section two
	  realtime(a1,start+seconds(point9))
	  realtime('p45v110c10 55,ed20,f,a,g,55d40',start+seconds(point11))
	  realtime('p50v110d19c10,55,67,44,66 80 22,100,20 51, 30,44,46,47,48,50 30 77',
	  start+seconds(point13))

	#section three
	  realtime(m1,start+seconds(point16))
	  realtime(m2,start+seconds(point16))
	  realtime(m3,start+seconds(point18))
	  realtime(r1,start+seconds(point19))
	  realtime(r2,start+seconds(point20))

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
sleeptill(start+seconds(when))
realtime(ano())
print("panic button is running")
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
	{	 m.time-=m%1.time # sets time to 0 so midi starts without delay
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
