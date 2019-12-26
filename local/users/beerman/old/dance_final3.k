#  WATER LILES for bodysynth (dancer) and electric clarinet
# The goal of this code is to play phrases
# in response to notes within certain time periods.
# this has the original plus f,m and ry phrases

#not busy enough

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




a1='d4d110,cv40c1 c5c2d140v90,r50,d5c7d40v50 d6c2 a5c4, r80,d3v30d25,e4v40,f+6v50,b3v60,a4 b2,
bf5v70,a4v75,f4v80,d6,e5v90c3 f4v90c2,r150,b-4v40c1d75,f5d35c2 f3c4,d450v70,e6c7v60d110 f4c8 '
a1a='a5c4, r80,e4v40,f+6v50,d4d110,cv40c1 c5c2d140v90,bf5v70,a4v75,f4v80,d6,e5v90c3 f4v90c2'
a1b=shuffle(a1)
a1c=reverse(a1)
a2= 'd5v55c1d60 d3c2,c5c6v70,d5c8v70,ev80c7 b3c2,b-5v90,f5 f6c4v80,d5v90,e5c2d150 f4c3'
a2a=shuffle(a2)
a2b=reverse(a2)
b1='p57d200v100c4 p60c11 p40c10, p55c2 p79c1,p57 45 69'
b1a=randdur(b1,50)

b2='p60d548v100c3,62,64c5 76c15d300,p71c7 p83c15'
b2a=eventime(b2)
b2b=randpitch(b2,12)
b3='pc60d50c1 48c8, d4c9 d6c11 a5c16,e4d200c14,b4d130c9 50c1040 c10,
    a4c9d23 a3c8 a6c5,d4,c,f4c1d200 c58 30c10 60c10'
b3a=randpitch(b3,12)
b3b=var7(b3)
b4='d6d100c12v100 d5c6 d4c5 20c10,c60c1 72c2 77c3 61c10,
   d5c5 d6c7,e4 e5 e6 e7'
b4a=var8(b4)

f1='d4c5v100d300 a3c11d200,g4c13d200 d5c14 d5c7'
f2='a5c8d70,g4c9d26 g4c16,f4c15 f3c4,c4c14d200 c5c6 c6c3'
f3='e-4c9d20 e-5c14,f4c13 f3c6,a-6c2 a-4c12,gc1d300c11,g5c4'

m1='a3c13v100d400 a2c4 e4c5 a4c6,b4c1d18,g4d400 d5c6 a5c14'
m2='a3d70v110c14,d3d16,f+4d150c7 f+5c8,a4d70c11 e5c9 a5c15,g4d400c6 d5 g5'
m3='c5d80v100c1,fc15,c5d18,f4c2,d3c3,c4c4,e5c5,f4c6,g5d500c16 g6c15 d6c7'

ry1='cv127d22c10 d4 e5c2,r55,a2c10v90d77 f5c2d33,gc10 d,av127 gc2 bc3,ev90c10,d,a,f'
ry2='f5c10d80v90 f4 e3,r50,b2c10v127d50 c3 d4 e5,g4c10d100v90 a5,d4c2v120 a6 e7d40,d4c10v90d29,a5,g4,e3'
ry3='cv127d22c10 d4 e5c2,r55,a2c10v90d77 f5c2d33,gc10 d,av127 gc2 bc3,ev90c10,d,a,f'
ry4='f5c10d80v90 f4 e3,r50,b2c10v127d50 c3 d4 e5,g4c10d100v90 a5,d4c2v120 a6 e7d40,d4c10v90d29,a5,g4,e3'
ry5='g2d70c3v100 a4c10 e-5,r29,d2c10v90d30,e5,g4,d6,g5,fv110 c d g,ev90'
ry6='b-2c3v87d44 f+5c10,r40,fc10v90d27,gc1 ac10 bc3,gc10,d,f,e'

p1='p45v110c10 55,ed20,f,a,g,55d40'
p1a=shuffle(p1)
p1b=reverse(p1)

p2='p45v110c10 55,ed20,f,a,g,55d40'
p2a=flip(p2)
p2b=repleng(p2,500)

p3='p50v110d19c10,55,67,44,66 80 22,100,20 51, 30,44,46,47,48,50 30 77'

r1='p40v127d19 50 60 70 80,r5,p40v80,r5,p42 56,r5,p40 41 55,r5,p40v127 50 52 54,
    p41v80,r5,40,r5'
r1a=randpitch(r1,12)
r1b=randdur(r1,50)

r2='p48v127d19c10 66 70,r5,p39v80d19 52,r5,p38v80d19 53c9,r5,p48v127d19c10 66 70,r5,
    p39v80d19 52,r5,p42v80d19 47 58c8,r5,p37v80d19c10 56 59,r5'
r2a=pitchlimit(r2,70,86)
r3='p45v127d19c10 62 70c11,r5,p39v80d19c10 51,r5,p38v120d19 53c7,r5,p48v127d19c10 66 70c12,r5,
    p39v80d19c10 52,r5,p60v120d19 49 58c13,r5,p37v80d19c10 56 59,r5'
r3a=shuffle(r3)
r3b=swapnote(r3)
r3c=randpitch(r3,24)

r4= 'p59v127d19c10 70 57c11,r5,p37v80d19c10 51c14,r5,p40v80d19 53c15,r5,p47v127d19c10 66 70c12,r5,
    p53v80d19c10 48c3 60c7 76c5,r5,p60v120d19c10 50 58c8,r5,p37v127d19c10 56 59,r5,
    p49v80d19c10'
r4a=shuffle(r4)

	# performance tasks for the bodysynth
	# section one  o'-1'10"
	#point 1 to 2
    task lookandkill(start,point1,point2, 60,63,1,a1a)
	#task lookandkill(start,point1,point2, 60,63,2,a1)
 	task lookandkill(start,point1,point2, 60,63,3,ry1)

	task lookandkill(start,point1,point2, 64,66,1,m2)
	#task lookandkill(start,point1,point2, 64,66,2,b2)
 	#task lookandkill(start,point1,point2, 64,66,3,p1)

	task lookandkill(start,point1,point2, 67,72,1,ry2)
	#task lookandkill(start,point1,point2, 67,72,2,a2b)
 	task lookandkill(start,point1,point2, 67,72,3,r4a)
		task panic(point2)


	#point2 to 3
	task lookandkill(start,point2,point3, 60,63,1,a1c)
	#task lookandkill(start,point2,point3, 60,63,2,b1a)
 	task lookandkill(start,point2,point3, 60,63,3,p1b)

	task lookandkill(start,point2,point3, 64,66,1,f1)
	#task lookandkill(start,point2,point3, 64,66,2,p2b)
 	task lookandkill(start,point2,point3, 64,66,3,ry4)

	task lookandkill(start,point2,point3, 67,72,1,a2)
	task lookandkill(start,point2,point3, 67,72,2,f2)
 	#task lookandkill(start,point2,point3, 67,72,3,ry5)

	task panic(point3)

	# point3 to 4
	task lookandkill(start,point3,point4, 60,63,1,f3)
	task lookandkill(start,point3,point4, 60,63,2,r3b)
 	task lookandkill(start,point3,point4, 60,63,3,ry6)

	task lookandkill(start,point3,point4, 64,66,1,a1b)
	#task lookandkill(start,point3,point4, 64,66,2,m1)
 	task lookandkill(start,point3,point4, 64,66,3,p2b)

	#task lookandkill(start,point3,point4, 67,72,1,p2)
	#task lookandkill(start,point3,point4, 67,72,2,a1a)
 	task lookandkill(start,point3,point4, 67,72,3,r1a)

		task panic(point4)

	#point4 to 5
	task lookandkill(start,point4,point5, 60,63,1,b3)
	task lookandkill(start,point4,point5, 60,63,2,r3b)
 	task lookandkill(start,point4,point5, 60,63,3,r2)
	task lookandkill(start,point4,point5, 64,66,1,a1)
	task lookandkill(start,point4,point5, 64,66,2,r1b)
 	task lookandkill(start,point4,point5, 64,66,3,p2a)
	task lookandkill(start,point4,point5, 67,72,1,p2)
	task lookandkill(start,point4,point5, 67,72,2,a1a)
 	task lookandkill(start,point4,point5, 67,72,3,b2)
	task panic(point5)

	#point 5 to 6
	task lookandkill(start,point5,point7, 60,63,1,a1b)
	task lookandkill(start,point5,point7, 60,63,2,r2)
 	task lookandkill(start,point5,point7, 60,63,3,b1)
	task lookandkill(start,point5,point6, 64,66,1,a1a)
	task lookandkill(start,point5,point6, 64,66,2,p3)
 	task lookandkill(start,point5,point6, 64,66,3,p2b)
	task lookandkill(start,point5,point6, 67,72,1,p2)
	task lookandkill(start,point5,point6, 67,72,2,r3c)
 	task lookandkill(start,point5,point6, 67,72,3,r1a)
	task panic(point6)

	#section two
	#point 7 to 8
	task lookandkill(start,point7,point8, 60,67,1,p1b)
	task lookandkill(start,point7,point8, 60,67,2,r3)
	task lookandkill(start,point7,point8, 60,67,3,b3b)
		task panic(point7)

	#point 8 to 8a
	task lookandkill(start,point8,point8a, 64,64,1,a2)
	task lookandkill(start,point8,point8a, 60,67,2,a1)
	task lookandkill(start,point8,point8a, 60,67,3,a1b)
	task panic(point8a)
		task panic(point8)

	#point8a to 8b
	task lookandkill(start,point8a,point8b, 60,63,1,a2b)
	task lookandkill(start,point8a,point8b, 60,63,2,p1a)
 	task lookandkill(start,point8a,point8b, 60,63,3,r3)
			task panic(point8b)

	
	#point 8b to 8c
	task lookandkill(start,point8b,point8c, 60,63,1,a2b)
	task lookandkill(start,point8b,point8c, 60,63,2,p1a)
 	task lookandkill(start,point8b,point8c, 60,63,3,r3)
	task lookandkill(start,point8b,point8c, 64,66,1,a1b)
	task lookandkill(start,point8b,point8c, 64,66,2,r2)
 	task lookandkill(start,point8b,point8c, 64,66,3,p2a)
	task lookandkill(start,point8b,point8c, 67,72,1,p2)
	task lookandkill(start,point8b,point8c, 67,72,2,r3b)
 	task lookandkill(start,point8b,point8c, 67,72,3,r1a)
	task panic(point8c)
	
	# point 8c to 8d
#	task lookandkill(start,point8c,point8d, 60,67,1,p2b)
#	task lookandkill(start,point8c,point8d, 60,67,1,r3b)
#	task lookandkill(start,point8c,point8d, 60,67,1,r3b)
	
	# point 8d to 8e
#	task lookandkill(start,point8d,point8e, 60,67,1,p2b)
#	task lookandkill(start,point8d,point8e, 60,67,1,r3b)
#	task lookandkill(start,point8d,point8e, 60,67,1,r3b)

	#point 8e t 8f
	task lookandkill(start,point8e,point8f, 64,64,1,a2)
	task lookandkill(start,point8e,point8f, 60,67,1,r2a)
		task panic(point8f)

	#point 9 to 10
	task lookandkill(start,point9,point10, 60,63,1,b1)
	task lookandkill(start,point9,point10, 60,63,2,p1a)
 	task lookandkill(start,point9,point10, 60,63,3,12b)
	task lookandkill(start,point9,point10, 64,66,1,a1b)
	task lookandkill(start,point9,point10, 64,66,2,r1)
	task lookandkill(start,point9,point10, 64,66,3,p2b)
	task lookandkill(start,point9,point10, 67,72,1,p3)
	task lookandkill(start,point9,point10, 67,72,2,r3)
 	task lookandkill(start,point9,point10, 67,72,3,r4)
	task panic(point10)
	
	# point 10 to 11
	task lookandkill(start,point10,point11, 60,63,1,b1)
	task lookandkill(start,point10,point11, 60,63,2,p1a)
 	task lookandkill(start,point10,point11, 60,63,3,12b)
	
	#point 11 to 12
	task lookandkill(start,point11,point12, 60,63,1,b3b)
	task lookandkill(start,point11,point12, 64,63,2,r4)
	task lookandkill(start,point11,point12, 64,67,1,r1a)
	task lookandkill(start,point11,point12, 60,67,2,r1b)
		task panic(point12)

	#point 12 to 13
	task lookandkill(start,point12,point13, 60,63,1,b3b)
	task lookandkill(start,point12,point13, 64,63,2,r4)
	task lookandkill(start,point12,point13, 64,67,1,r1a)
	
	#POINT 13 TO 14
	task lookandkill(start,point13,point14, 64,66,2,r2)
 	task lookandkill(start,point13,point14, 67,72,1,p2)
	task lookandkill(start,point13,point14, 67,72,2,r3)
 	#task lookandkill(start,point13,point14, 67,72,3,p1)
	task panic(point14)

	#section three
	#point 15 to 15a
	task lookandkill(start,point15,point15a, 60,67,1,p3)
	task lookandkill(start,point15,point15a, 60,67,2,p1a)

	#point 15b to 15c
	task lookandkill(start,point15b,point15c, 60,67,1,p1a)
	task lookandkill(start,point15b,point15c, 60,67,2,r3b)
	task lookandkill(start,point15b,point15c, 60,67,3,p2)
	task panic(point15c)

	#point 15c to 15d
	task lookandkill(start,point15c,point15d, 60,67,1,p1a)
	task lookandkill(start,point15c,point15d, 60,67,2,r3b)
	task lookandkill(start,point15c,point15d, 60,67,3,p2)
	
	#point 15d to 15e
	task lookandkill(start,point15d,point15e, 60,67,1,b3)
	task lookandkill(start,point15d,point15e, 60,67,2,p1a)
	task lookandkill(start,point15d,point15e, 60,67,3,r3a)
	task panic(point15e)

	#point 15e to 15 f
	task lookandkill(start,point15e,point15f, 60,67,1,p1a)
	task lookandkill(start,point15e,point15f, 60,67,2,r3b)
	task lookandkill(start,point15e,point15f, 60,67,3,p2)
	
	#point 15f to 15g
	task lookandkill(start,point15f,point15g, 60,67,1,p2)
	task lookandkill(start,point15f,point15g, 60,67,2,p1a)
	task lookandkill(start,point15f,point15g, 60,67,3,r3b)
	task panic(point15g)

	#point 16 to 17
	task lookandkill(start,point16,point17, 60,63,1,r4a)
	task lookandkill(start,point16,point17, 60,63,2,r4)
 	task lookandkill(start,point16,point17, 60,63,3,r3c)
	task lookandkill(start,point16,point17, 64,66,1,r3b)
	task lookandkill(start,point16,point17, 64,66,2,r2)
 	task lookandkill(start,point16,point17, 64,66,3,r3a)
	task lookandkill(start,point16,point17, 67,72,1,p2)
	#task lookandkill(start,point16,point17, 67,72,2,r3)
 	#task lookandkill(start,point16,point17, 67,72,3,p1)
	task panic(point17)

	#section three
	#point 17 to 18
	task lookandkill(start,point17,point18, 60,67,1,a1)
	task lookandkill(start,point17,point18, 60,67,2,p1b)
		task panic(point18)

	#point 19 to 20
	task lookandkill(start,point19,point20, 60,67,1,a2)
	task lookandkill(start,point19,point20, 60,67,2,p1)
	task lookandkill(start,point19,point20, 60,67,3,b1)
	task panic(20)

	#point 20 to 21
	task lookandkill(start,point20,point21, 60,67,1,b1)
	task lookandkill(start,point20,point21, 60,67,2,p3)
	task lookandkill(start,point20,point21, 60,67,3,a2)
	task panic(point21)

	task lookandkill(start,point21a,point21b, 60,67,1,b1)
	task lookandkill(start,point21a,point21b, 60,67,2,p3)
	task lookandkill(start,point21b,point21c, 60,67,1,b1)
	task lookandkill(start,point21b,point21c, 60,67,2,p3)
    task lookandkill(start,point21d,point21e, 60,67,1,b1)
	task lookandkill(start,point21e,point21f, 60,67,2,p3)
		task panic(point21f)


	#section four
	#point 22 to 23
	task lookandkill(start,point22,point23, 60,67,1,r1)
	task lookandkill(start,point22,point23, 60,67,2,r2)
	task lookandkill(start,point22,point23, 60,67,3,a1)
		task panic(point23)

	#point 24 to 25
	task lookandkill(start,point23,point24, 60,67,1,p1a)
	task lookandkill(start,point23,point24, 60,67,2,r2)
	task lookandkill(start,point24,point25, 60,67,1,p1b)
	task lookandkill(start,point24,point25, 60,67,2,r2)
		task panic(point25)

	#section five
	#points 26 to 27
	task lookandkill(start,point26,point27, 60,67,1,r1)
	task lookandkill(start,point26,point27, 60,67,2,r3)
	task lookandkill(start,point22,point23, 60,67,3,b1)
		task panic(point27)

	#points 28 to 29
	task lookandkill(start,point28,point29, 60,67,1,r3a)
	task lookandkill(start,point28,point29, 60,67,2,r4a)
	task lookandkill(start,point22,point23, 60,67,3,r2)
	task panic(point29)



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
	  realtime(p1,start+seconds(point9))
	  realtime('p45v110c10 55,ed20,f,a,g,55d40',start+seconds(point11))
	  realtime('p50v110d19c10,55,67,44,66 80 22,100,20 51, 30,44,46,47,48,50 30 77',
	  start+seconds(point13))

	#section three
	  realtime(r1,start+seconds(point16))
	  realtime(r4,start+seconds(point16))
	  realtime(r2,start+seconds(point18))
	  realtime(p3,start+seconds(point19))
	  realtime(r3,start+seconds(point20))

	#section four
		realtime('p36v110d300c1 p48V80 p67',start+seconds(point22))
        realtime('p72v110d300c1 p55c15V79 p77c5',start+seconds(point23))
        realtime('p48v110d300c1 p36c11V80 p74c12',start+seconds(point24))
#        realtime('p60v110d300c1 p32c8V80 p72c9',start+seconds(point25))

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
