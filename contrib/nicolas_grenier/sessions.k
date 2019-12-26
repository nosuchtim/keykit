function f20061130(){
	s=new sc("maj",0)
	a=randseq1(7,28,14,1)
	h="ea 82"
	b=s.gen(a,1)
	c=phbin(b,8,h)
	c=legato2(c)
	c+=s.flip(c)
	c+=phns(c,8,perm(8,rand(factorial(8))))
	c=shuffl(c+s.trans(c,7),4)
	out=scadur(c,2)
	return(out)
}

function f20061201(){
	s=new sc("pent",0)
	a=randseq1(9,24,14,1)
	b=randseq2(8,0,7,2,7,a[8]-a[0])
	h="88 20 a8 8a"
	c=saddk(a,b)
	d=phbin(s.gen(c,1),8,h)
	d=legato2(d)
	e=spi(seq(0,1,2,3),seq(1,2,3,0),4)
	f=phns(d,4,e)
	f=s.trans(f,3)
	g=shuffl(f+repeat(d,4),32)
	return(scadur(g,4))
}

function f20061201_2(){
	s=new sc("maj",4)
	h="9a 28"
	a=randseq1(6,0,14,1)
	b=spi(a,seq(2,1,4,3,5,0),4)
	b=saddk(b,-7)
	b=juxt(b,smulk(b,2))
	b=saddk(b,35)
	c=legato2(phbin(s.gen(b,1),8,h))
	c=repeat(c,8)
	d=s.trans(c,mods(8,5,3),1)
	return(scadur(d,4))
}

function f20061202(){
	s=new sc("maj",0)
	a=randcomp(256,15)
	b=randseq2(sizeof(a),28,14,2,5)
	out=s.gen(b,a)
	return(scadur(out,4))
}

function f20061203(){
	s=new sc("maj",0)
	a=tri(0,8)
	a=bounce(a,2,4)
	a=spi(a,seq(0,3,2,5,4,7,6,9,8,11,10,13,12,15,14,1),8)
	b=smulk(a,2)
	c=mergeseq(a,b)
	c=juxt(c,flipseq(c))
	c=saddk(c,28)
	d=s.gen(c,4)
	out=scadur(d,2)
	return(out)
}

function f20061204(){
	s=new sc("maj",0)
	h="92 07 2a 54"
	a=repseq(seq(27),8)
	b=stair(28,8)
	c=randseq1(8,36,7)
	d=mergeseq(a,b,c)
	e=s.gen(d,1)
	f=phbin(e,8,h)
	f=scadur(legato2(f),4)
	return(f)
}

function f20061209(){
	s=new sc("jazz",4)
	a=morphabseq(randseq1(5,22,6,1),randseq1(5,28,6,1))
	a=s.gen(a,1)
	a=phbin(a,8,"a4 88 84 a8")
	a=legato2(a)
	a=scadur(a,4)
	return(a)
}

function f20061212(){
	s=new sc("maj",4)
	a=randseq1(12,21,14,1)
	a=spi(a,seq(0,4,2,3,7,5,6,10,8,9,1,11),4)
	h="94 8a 92 86"
	a=legato2(phbin(s.gen(a,1),8,h))
	b=s.flip(a)
	b.pitch+=12
	c=binab(a,b,8,h,4)
	c+=binab(b,a,8,h,4)
	c.pitch+=12
	return(scadur(c,4))
}

function f20061215(){
	a=smulk(seq(0,1,2,1,-1,-2,-1),seq(1,2,1,-1,-2,-1,2,-1))
	a=saddk(a,32)
	h="80 28 20 a8"
	b=seq(8,6,8,6,4,4,6)
	s=new sc("jazz",4)
	c=s.gen(a,b)
	d=phbin(c,8,h)
	return(scadur(d,4))
}

function f20070121(){
	s=new sc("maj",0)
	a=randseq0(16,28,5)
	b=randseq0(16,33,5)
	c=randseq0(16,38,5)
	d=mergeseq(a,b,a,b,c,b,c,a)
	out=s.gen(d,1)
	return(scadur(out,4))
}

function f20070210(){
	s=new sc("maj",0)
	a=randseq1(8,28,14,1)
	b=seq(4,6,4,5)
	c=spi(a,seq(0,7,2,1,4,3,6,5),4)
	out=phbin(s.gen(c,b),8,"b4")
	return(out)
}

function f20070223(){
	a=randseq3(1,3,seq(1,0,0,-1,0,1),28)
	s=new sc("maj",0)
	return(legato2(phbin(s.gen(a,1),8,"a9 92")))

}