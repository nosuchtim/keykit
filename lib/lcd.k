function lcd_test1(lcdnum)
{
	tm = Now+milliclicks(1000)
	while ( Now < tm ) {
		cmd = rand(3)
		rrow = rand(4)
		rcol = rand(20)
		chr = ascii(rand(128))
		if ( rand(2) == 0 ) {
			mdep("lcd","write",lcdnum,chr,rrow,rcol)
		} else {
			mdep("lcd","backlight",lcdnum,rand(2))
		}
	}
	mdep("lcd","clear",lcdnum)
	mdep("lcd","backlight",lcdnum,0)
}

function lcd_test(nlcd)
{
	if ( nargs() < 1 )
		nlcd = 2
	tm = Now+milliclicks(1000)
	while ( Now < tm ) {
		lcdnum = rand(nlcd)
		cmd = rand(3)
		rrow = rand(4)
		rcol = rand(20)
		chr = ascii(rand(128))
		if ( rand(2) == 0 ) {
			mdep("lcd","write",lcdnum,chr,rrow,rcol)
		} else {
			mdep("lcd","backlight",lcdnum,rand(2))
		}
	}
	for ( n=0; n<nlcd; n++ ) {
		mdep("lcd","clear",n)
		mdep("lcd","backlight",n,0)
	}
}

function lcd_demo()
{
	mdep("lcd","backlight",0,1)
	mdep("lcd","write",0,"Decay     |     Time",0,0)
	mdep("lcd","write",0,"Size      |    Width",1,0)
	mdep("lcd","write",0,"Gravity   |  Variety",2,0)
	mdep("lcd","write",0,"Speed     |    Color",3,0)
}
function lcd_demo2()
{
	mdep("lcd","backlight",0,1)
	mdep("lcd","write",0,"Transpose | LoopLeng",0,0)
	mdep("lcd","write",0,"Octave Vary |  Chord",1,0)
	mdep("lcd","write",0,"Key Focus  |  Source",2,0)
	mdep("lcd","write",0,"Patch | Grid Visible",3,0)
}
function lcd_write(n1)
{
	c = n1
	for ( r=0; r<4; r++ ) {
		for ( n=0; n<20; n++ ) {
			s = ascii(c)
			c++
			mdep("lcd","write",0,s,r,n)
		}
	}
}

function lcd_flash()
{
	mdep("lcd","clear",0)
	mdep("lcd","backlight",0,0)
	Consupdown = 1
	Consecho = 0
	f = Root.grabconsole()
	while ( (c=get(f)) != Eof ) {
		print("c=",c)
		if ( c == "+Q" )
			break
		s=""
		for ( n=0; n<10;n++)
			s += c
		mdep("lcd","write",0,s,0,0)
		mdep("lcd","write",0,s,1,0)
		mdep("lcd","write",0,s,2,0)
		mdep("lcd","write",0,s,3,0)
	}
	Root.releaseconsole()
	Consecho = 1
	Consupdown = 0
}

function lcd_multiline(lcd,msg) {
	mdep("lcd","clear",lcd)
	lines = split(msg,"\n")
	nlines = sizeof(lines)
	if ( nlines < 3 )
		linenum = 1
	else
		linenum = 0
	for ( n=0; n in lines; n++ ) {
		str = lines[n]
		colnum = (20 - sizeof(str))/2
		if ( colnum < 0 )
			colnum = 0
		if ( linenum > 3 )
			linenum = 3
		mdep("lcd","write",lcd,str,linenum,colnum)
		linenum++
	}
}
