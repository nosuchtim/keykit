#  this is the first file in a work for icmc featuring the bodysynth 
function bodysynth1() {

	print("...")bodysynth1

	start = Now
	# these values are in seconds
        point1=1
			point1a=20
			point1b=30
			point1c=40
			point1d=50
			point1e=60
			point1f=70
			point1g=80
			point1h=90
        point2 = 100
			point2a=120
			point2b=130
			point2c=140
			point2d=150
			point2e=160
			point2f=170
			point2g=180
			point2h=190
	    point3 = 200
			point3a=220
			point3b=230
			point3c=240
			point3d=250
			point3e=260
			point3f=270
			point3g=280
			point3h=290
        point4 = 300
			point4a=320
			point4b=330
			point4c=340
			point4d=350
			point4e=360
			point4f=370
			point4g=380
			point4h=390
	     point5=400
			point5a=420
			point5b=430
			point5c=440
			point5d=450
			point5e=460
			point5f=470
			point5g=480
			point5h=490
	     point6=500
			point6a=520
			point6b=530
			point6c=540
			point6d=550
			point6e=560
			point6f=570
			point6g=580
			point6h=590
	     point7=600
			point7a=620
			point7b=630
			point7c=640
			point7d=650
			point7e=660
			point7f=670
			point7g=680
			point7h=690
	     point8=700
			point8a=720
			point8b=730
			point8c=740
			point8d=750
			point8e=760
			point8f=770
			point8g=780
			point8h=790
	     point9=800
			point9a=820
			point9b=830
			point9c=840
			point9d=850
			point9e=860
			point9f=870
			point9g=880
			point9h=890
	     point10=900
			point10a=920
			point10b=930
			point10c=940
			point10d=950
			point10e=960
			point10f=970
			point10g=980
			point10h=990
	point11=1000
			point11a=1020
			point11b=1030
			point11c=1040
			point11d=1050
			point11e=1060
			point11f=1070
			point11g=1080
			point11h=1090
        point12=1100
			point12a=1120
			point12b=1130
			point12c=1140
			point12d=1150
			point12e=1160
			point12f=1170
			point12g=1180
			point12h=1190
	    point13=1200
			point13a=1220
			point13b=1230
			point13c=1240
			point13d=1250
			point13e=1260
			point13f=1270
			point13g=1280
			point13h=1290
        point14=1300
			point14a=1320
			point14b=1330
			point14c=1340
			point14d=1350
			point14e=1360
			point14f=1370
			point14g=1380
			point14h=1390
	     point15=1400
			point15a=1420
			point15b=1430
			point15c=1440
			point15d=1450
			point15e=1460
			point15f=1470
			point15g=1480
			point15h=1490
	     point16=1500
			point16a=1520
			point16b=1530
			point16c=1540
			point16d=1550
			point16e=1560
			point16f=1570
			point16g=1580
			point16h=1590
	     point17=1600
			point17a=1620
			point17b=1630
			point17c=1640
			point17d=1650
			point17e=1660
			point17f=1670
			point17g=1680
			point17h=1690
	     point18=1700
			point18a=1720
			point18b=1730
			point18c=1740
			point18d=1750
			point18e=1760
			point18f=1770
			point18g=1780
			point18h=1790
	     point19=1800
			point19a=1820
			point19b=1830
			point19c=1840
			point19d=1850
			point19e=1860
			point19f=1870
			point19g=1880
			point19h=1890
	     point20=1900
			point20a=1920
			point20b=1930
			point20c=1940
			point20d=1950
			point20e=1960
			point20f=1970
			point20g=1980
			point20h=1990
				
# phrases used by the bodysynth and called by variable name

a='c04d200c2 f4c11 bf2c4 d6c16,r200, a3d34v45c6,gd20v60c3,ev77,
f#5v80c5,a,fv92c7,c#6v100c9' #quick sweep up

b='f4d27v120c1 g3,f4v80 g,a5,f4d27v120 g3,f4v80 g,
d3,f5,ef4,g,f,f4d27v120 g3,f4v80 g,f4v80 g,d5,f,ef5 
f5,g'#driving 1

c='g2d26v120c1 f2 a3,a4v85,g,bf,g,a,r40,g2v120 a5,
a3v80 g4,a3v80 g4,c4d300 gd27,g,a,g2v120 a5,
a3v80c1 g4,a3v80 g4,g,a,g2v120 a5,
a3v80 g4,a3v80 g4,c4d300 gd27'#driving 2

d='g3d28v120c1 f4 a,g3d28v120 f4 a,g3d28v120 f4 a,g5v88,
ef3 af4,g3d28v120 f4 a,g3d28v120 f4 a,
g2d28v120 f4 a,g2d58v120 f3 a,
g3d28v120 f4 a,g5v88' #driving 3

e='g6v70d22,a5d200 g4,r100,f3v45d22,
d2,f#3v45,g5v60,a4v77,g6v80 g7,
a5v77c2d200c9 b6c6,r66,g5d34v44c7,fd24v55,dv66c8,
efv77c1,a4v77d200 b5,r66,g5d300v44 d4 d3' #ornamental melody a/g

f='g4d77v44c4 a5c5 b6c7,fd24v55c6,dv66c16,
 efv77c13,a4v77d200 b5c12,r66,g5d300v44c1 d4 d3,
 g6v70d22,a5d200 g4,r100,f3v45d220 g5,
r33,b4d40v77,a5v88,gv60 d3/a6' #ornamental melody variation of e

g='d6d50v100c2 e4c15 a5c11,g4v77c8,ac6 b5c4,a3c2 a4c3,bd25,
ac5,bc7,gc6,ac5,a5c4,
 g4v77c2,a b5c11,a3c10 a4,bd25c8' #steady upbeat
 
h='d6d88v100c3 e4c11 a5c5,g4v77c4,a b5,a3c1 a4,bd40,a,b,g,a,a5,
 g4v77,a b5,a3 a4,bd50,g4v77,a b5,a3 a4,bd40,
 d6d88v100 e4 a5,g4v77'  #steady, slow version of g 
 
i='d5v88c3d400 ac2 d6d400c16,r100,bf3c1d30,v120 c5 g a7,r20,ef4,
 v40c1,a,gv40,c5v60,df7v80,c3v90,g5v100,
d5v88c9d400 ac15 d6d400c12,r100,bf3c10d30 a,g,e,r40,e4,g,a,d' 


j='c4v88c9d100 a6c11 c#5d100c2,r100,d#4c2d120,
 v120 c5d470 gd200c7 a7 g3c6 c2c3 e5c4,ef4,
 v40c11,a,gv40,c5v60,df7v80,c3v90,g5v100,
d5v88c9d400 ac15 d6d400c12,r100,bf3c1d30 a,g,e,r40,e4,g,a,d'

k='a4d500c4v90 d5c6 e6c7,f#3c8d60 b7d300,g#4v40d26,a5v50,e4v55,bv62,fs5v70,d4v80,e5v90,d6v99,
 b4v101,ev110,a5v120 d4 c3c3'

l='a4v120c10d26 d g,a d g,cv80,r35,a d,g c d6,f4v40,gv60,av80,
 a4v120c10d26 d g,a d g,cv80' #rhythmic drums



# performance tasks for the bodysynth
	# point1
	 task lookandkill(start,point1,point1a, 60,63,1,
	 melody(15,15,57,63,26,77))
     task lookandkill(start,point1,point1a, 60,63,1,shuffle(b))
	 task lookandkill(start,point1a,point1b, 60,63,1,c)
	 task lookandkill(start,point1b,point1c, 60,63,1,b)
	 task lookandkill(start,point1c,point1d, 60,63,1,c)
	 task lookandkill(start,point1d,point1e, 60,63,1,b)
	 task lookandkill(start,point1e,point1f, 60,63,1,d)
	 task lookandkill(start,point1f,point1g, 60,63,1,a)
	 task lookandkill(start,point1g,point1h, 60,63,1,e)
			task panic(point2)
	# point2
    task lookandkill(start,point2,point2a, 60,63,1,f)
	task lookandkill(start,point2a,point2b, 60,63,1,g)
	task lookandkill(start,point2b,point2c, 60,63,1,shuffle(e))
	task lookandkill(start,point2c,point2d, 60,63,1,g)
	task lookandkill(start,point2d,point2e, 60,63,1,shuffle(d))
	task lookandkill(start,point2e,point2f, 60,63,1,slowdown(f))
	task lookandkill(start,point2f,point2g, 60,63,1,f)
	task lookandkill(start,point2g,point2h, 60,63,1,g)
			task panic(point3)
# point3
    task lookandkill(start,point3,point3a, 60,63,1,shuffle(b))
	task lookandkill(start,point3a,point3b, 60,63,1,shuffle(c))
	task lookandkill(start,point3b,point3c, 60,63,1,reverse(d))
	task lookandkill(start,point3c,point3d, 60,63,1,shuffle(b))
	task lookandkill(start,point3d,point3e, 60,63,1,d)
	task lookandkill(start,point3e,point3f, 60,63,1,shuffle(b))
	task lookandkill(start,point3f,point3g, 60,63,1,flip(b))
	task lookandkill(start,point3g,point3h, 60,63,1,
	pitchlimit(c,55,62))
			task panic(point4)
# point4
    task lookandkill(start,point4,point4a, 60,63,1,e)
	task lookandkill(start,point4a,point4b, 60,63,1,shuffle(g))
	task lookandkill(start,point4b,point4c, 60,63,1,shuffle(f))
	task lookandkill(start,point4c,point4d, 60,63,1,flip(g))
	task lookandkill(start,point4d,point4e, 60,63,1,stutter(e,100,5))
	task lookandkill(start,point4e,point4f, 60,63,1,g)
	task lookandkill(start,point4f,point4g, 60,63,1,reverse(f))
	task lookandkill(start,point4g,point4h, 
	60,63,1,pitchlimit(g,66,72))
			task panic(point5)
# point5
    task lookandkill(start,point5,point5a, 60,63,1,h)
	task lookandkill(start,point5a,point5b, 60,63,1,f)
	task lookandkill(start,point5b,point5c, 60,63,1,shuffle(f))
	task lookandkill(start,point5c,point5d, 60,63,1,revpitch(h))
	task lookandkill(start,point5d,point5e, 60,63,1,h)
	task lookandkill(start,point5e,point5f, 60,63,1,flip(f))
	task lookandkill(start,point5f,point5g, 60,63,1,g)
	task lookandkill(start,point5g,point5h, 60,63,1,shuffle(h))
			task panic(point6)
# point6
    task lookandkill(start,point6,point6a, 60,63,1,i)
	task lookandkill(start,point6a,point6b, 60,63,1,a)
	task lookandkill(start,point6b,point6c, 60,63,1,shuffle(i))
	task lookandkill(start,point6c,point6d, 60,63,1,flip(a))
	task lookandkill(start,point6d,point6e, 60,63,1,flip(i))
	task lookandkill(start,point6e,point6f, 60,63,1,c)
	task lookandkill(start,point6f,point6g, 60,63,1,d)
	task lookandkill(start,point6g,point6h, 60,63,1,shuffle(f))
			task panic(point7)
# point7
    task lookandkill(start,point7,point7a, 60,63,1,k)
	task lookandkill(start,point7a,point7b, 60,63,1,j)
	task lookandkill(start,point7b,point7c, 60,63,1,shuffle(i))
	task lookandkill(start,point7c,point7d, 60,63,1,slowdown(k))
	task lookandkill(start,point7d,point7e,60,63,1,slastbunch(d,300))
	task lookandkill(start,point7e,point7f, 60,63,1,shuffle(k))
	task lookandkill(start,point7f,point7g, 60,63,1,a)
	task lookandkill(start,point7g,point7h, 60,63,1,k)
			task panic(point8)
# point8
#    task lookandkill(start,point8,point8a, 60,63,1,p1)
#    task lookandkill(start,point8a,point8b, 60,63,1,p1)
#	task lookandkill(start,point8b,point8c, 60,63,1,p1)
#	task lookandkill(start,point8c,point8d, 60,63,1,p1)
#	task lookandkill(start,point8d,point8e, 60,63,1,p1)
#	task lookandkill(start,point8e,point8f, 60,63,1,p1)
#	task lookandkill(start,point8f,point8g, 60,63,1,p1)
#	task lookandkill(start,point8g,point8h, 60,63,1,p1)
			task panic(point9)			
# point9
 #   task lookandkill(start,point9,point9a, 60,63,1,l)
#	task lookandkill(start,point9a,point9b, 60,63,1,c)
#	task lookandkill(start,point9b,point9c, 60,63,1,shuffle(b))
#	task lookandkill(start,point9c,point9d, 60,63,1,shuffle(l))
#	task lookandkill(start,point9d,point9e, 60,63,1,c)
#	task lookandkill(start,point9e,point9f, 60,63,1,shuffle(d))
#	task lookandkill(start,point9f,point9g, 60,63,1,shuffle(b))
#	task lookandkill(start,point9g,point9h, 60,63,1,c)
			task panic(point10)
# point10
#    task lookandkill(start,point10,point10a, 60,63,1,revpitch(e))
#	task lookandkill(start,point10a,point10b, 60,63,1,a)
#	task lookandkill(start,point10b,point10c, 60,63,1,f)
#    task lookandkill(start,point10c,point10d, 60,63,1,reverse(g))
#    task lookandkill(start,point10d,point10e, 60,63,1,g)
#	task lookandkill(start,point10e,point10f, 60,63,1,i)
#	task lookandkill(start,point10f,point10g, 60,63,1,k)
#	task lookandkill(start,point10g,point10h, 60,63,1,i)
			task panic(point11)		
# point11
    # task lookandkill(start,point11,point11a, 60,63,1,p1)
	# task lookandkill(start,point11a,point11b, 60,63,1,p1)
	# task lookandkill(start,point11b,point11c, 60,63,1,p1)
	# task lookandkill(start,point11c,point11d, 60,63,1,p1)
	# task lookandkill(start,point11d,point11e, 60,63,1,p1)
	# task lookandkill(start,point11e,point11f, 60,63,1,p1)
	# task lookandkill(start,point11f,point11g, 60,63,1,p1)
	# task lookandkill(start,point11g,point11h, 60,63,1,p1)
			task panic(point12)
	# point12
    # task lookandkill(start,point12,point12a, 60,63,1,p1)
	# task lookandkill(start,point12a,point12b, 60,63,1,p1)
	# task lookandkill(start,point12b,point12c, 60,63,1,p1)
	# task lookandkill(start,point12c,point12d, 60,63,1,p1)
	# task lookandkill(start,point12d,point12e, 60,63,1,p1)
	# task lookandkill(start,point12e,point12f, 60,63,1,p1)
	# task lookandkill(start,point12f,point12g, 60,63,1,p1)
	# task lookandkill(start,point12g,point12h, 60,63,1,p1)
			task panic(point13)
# point13
    # task lookandkill(start,point13,point13a, 60,63,1,p1)
	# task lookandkill(start,point13a,point13b, 60,63,1,p1)
	# task lookandkill(start,point13b,point13c, 60,63,1,p1)
	# task lookandkill(start,point13c,point13d, 60,63,1,p1)
	# task lookandkill(start,point13d,point13e, 60,63,1,p1)
	# task lookandkill(start,point13e,point13f, 60,63,1,p1)
	# task lookandkill(start,point13f,point13g, 60,63,1,p1)
	# task lookandkill(start,point13g,point13h, 60,63,1,p1)
			task panic(point14)
# point14
    # task lookandkill(start,point14,point14a, 60,63,1,p1)
	# task lookandkill(start,point14a,point14b, 60,63,1,p1)
	# task lookandkill(start,point14b,point14c, 60,63,1,p1)
	# task lookandkill(start,point14c,point14d, 60,63,1,p1)
	# task lookandkill(start,point14d,point14e, 60,63,1,p1)
	# task lookandkill(start,point14e,point14f, 60,63,1,p1)
	# task lookandkill(start,point14f,point14g, 60,63,1,p1)
	# task lookandkill(start,point14g,point14h, 60,63,1,p1)
			task panic(point15)
# point15
    # task lookandkill(start,point15,point15a, 60,63,1,p1)
	# task lookandkill(start,point15a,point15b, 60,63,1,p1)
	# task lookandkill(start,point15b,point15c, 60,63,1,p1)
	# task lookandkill(start,point15c,point15d, 60,63,1,p1)
	# task lookandkill(start,point15d,point15e, 60,63,1,p1)
	# task lookandkill(start,point15e,point15f, 60,63,1,p1)
	# task lookandkill(start,point15f,point15g, 60,63,1,p1)
	# task lookandkill(start,point15g,point15h, 60,63,1,p1)
			task panic(point16)
# point16
    # task lookandkill(start,point16,point16a, 60,63,1,p1)
	# task lookandkill(start,point16a,point16b, 60,63,1,p1)
	# task lookandkill(start,point16b,point16c, 60,63,1,p1)
	# task lookandkill(start,point16c,point16d, 60,63,1,p1)
	# task lookandkill(start,point16d,point16e, 60,63,1,p1)
	# task lookandkill(start,point16e,point16f, 60,63,1,p1)
	# task lookandkill(start,point16f,point16g, 60,63,1,p1)
	# task lookandkill(start,point16g,point16h, 60,63,1,p1)
			task panic(point17)
# point17
    # task lookandkill(start,point17,point17a, 60,63,1,p1)
	# task lookandkill(start,point17a,point17b, 60,63,1,p1)
	# task lookandkill(start,point17b,point17c, 60,63,1,p1)
	# task lookandkill(start,point17c,point17d, 60,63,1,p1)
	# task lookandkill(start,point17d,point17e, 60,63,1,p1)
	# task lookandkill(start,point17e,point17f, 60,63,1,p1)
	# task lookandkill(start,point17f,point17g, 60,63,1,p1)
	# task lookandkill(start,point17g,point17h, 60,63,1,p1)
			task panic(point18)
# point18
    # task lookandkill(start,point18,point18a, 60,63,1,p1)
	# task lookandkill(start,point18a,point18b, 60,63,1,p1)
	# task lookandkill(start,point18b,point18c, 60,63,1,p1)
	# task lookandkill(start,point18c,point18d, 60,63,1,p1)
	# task lookandkill(start,point18d,point18e, 60,63,1,p1)
	# task lookandkill(start,point18e,point18f, 60,63,1,p1)
	# task lookandkill(start,point18f,point18g, 60,63,1,p1)
	# task lookandkill(start,point18g,point18h, 60,63,1,p1)
			task panic(point19)			
# point19
    # task lookandkill(start,point19,point19a, 60,63,1,p1)
	# task lookandkill(start,point19a,point19b, 60,63,1,p1)
	# task lookandkill(start,point19b,point19c, 60,63,1,p1)
	# task lookandkill(start,point19c,point19d, 60,63,1,p1)
	# task lookandkill(start,point19d,point19e, 60,63,1,p1)
	# task lookandkill(start,point19e,point19f, 60,63,1,p1)
	# task lookandkill(start,point19f,point19g, 60,63,1,p1)
	# task lookandkill(start,point19g,point19h, 60,63,1,p1)
			
# point10
    # task lookandkill(start,point10,point10a, 60,63,1,p1)
	# task lookandkill(start,point10a,point10b, 60,63,1,p1)
	# task lookandkill(start,point10b,point10c, 60,63,1,p1)
	# task lookandkill(start,point10c,point10d, 60,63,1,p1)
	# task lookandkill(start,point10d,point10e, 60,63,1,p1)
	# task lookandkill(start,point10e,point10f, 60,63,1,p1)
	# task lookandkill(start,point10f,point10g, 60,63,1,p1)
	# task lookandkill(start,point10g,point10h, 60,63,1,p1)
			task panic(point11)						
			
	 # not tied to the bodysynth
	  realtime(a,start+seconds(point1))
      realtime(c,start+seconds(point1c))
	  realtime(b,start+seconds(point1f))
	  realtime(c,start+seconds(point1g))
	  realtime(d,start+seconds(point1h))
	  
	  realtime(d,start+seconds(point3))
	  realtime(c,start+seconds(point3a))
	  realtime(b,start+seconds(point3d))
	  realtime(c,start+seconds(point3g))
	  realtime(d,start+seconds(point3h))
	  
	  realtime(b,start+seconds(point4))
	  realtime(c,start+seconds(point4c))
	  realtime(b,start+seconds(point4f))
	  realtime(a,start+seconds(point4g))
	  realtime(b,start+seconds(point4h))
	  
	  realtime(b,start+seconds(point5h))
	  
	  
	 # realtime('p45v110c10 55,ed20,f,a,g,55d40',
	 # start+seconds(point11))
	 # realtime(r1,start+seconds(point16))
	  

}
