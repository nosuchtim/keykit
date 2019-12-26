for ( loop=0; loop<5; loop++ ) {

print("mono('a,b,c')=",mono('a,b,c'))
print("mono('a,bt4,ct10')=",mono('a,bt4,ct10'))
print("mono('a,bt4,ct10,eo4t14d2')=",mono('a,bt4,ct10,eo4t14d2'))

ph='a,b,c,d,e'
print("ph = ",ph)
print("cut(ph,CUT_TIME,0,MAXCLICKS) = ",cut(ph,CUT_TIME,0,MAXCLICKS))
print("cut(ph,CUT_TIME,0,24) = ",cut(ph,CUT_TIME,0,24))
print("cut(ph,CUT_TIME,0,25) = ",cut(ph,CUT_TIME,0,25))
print("cut(ph,CUT_TIME,10,20) = ",cut(ph,CUT_TIME,10,20))
print("cut(ph,CUT_TIME,10,50) = ",cut(ph,CUT_TIME,10,50))
print("cuttrunc(ph,0,MAXCLICKS) = ",cut(ph,CUT_TIME,0,MAXCLICKS,TRUNCATE))
print("cuttrunc(ph,0,24) = ",cut(ph,CUT_TIME,0,24,TRUNCATE))
print("cuttrunc(ph,0,25) = ",cut(ph,CUT_TIME,0,25,TRUNCATE))
print("cuttrunc(ph,10,20) = ",cut(ph,CUT_TIME,10,20,TRUNCATE))
print("cuttrunc(ph,10,50) = ",cut(ph,CUT_TIME,10,50,TRUNCATE))
print("repleng('a,b',96) = ",repleng('a,b',96))

print("arpeggio('a b c,d,e')=",arpeggio('a b c,d,e'))

print("flip('e,f,g,a','f') = ",flip('e,f,g,a','f'))
print("flip('eo2,f,g,a','f') = ",flip('eo2,f,g,a','f'))

print("scatimes('a,b,c',3)=",scatimes('a,b,c',3))

print("quantize('ad5,b,c,d,e,f,g',6)=",quantize('ad5,b,c,d,e,f,g',6))
print("randvol('a,a,a,a,a',10)=",randvol('a,a,a,a,a,a',10))
print("randpitch('a,a,a,a,a',10)=",randpitch('a,a,a,a,a,a',10))
print("randdur('a,a,a,a,a',10)=",randdur('a,a,a,a,a,a',10))

print("scaleng('a,b,c',30)=",scaleng('a,b,c',30))
print("scaleng('a,b,c')=",scaleng('a,b,c',24))
print("scaleng('a,b,c,d')=",scaleng('a,b,c,d',48))

for ( n=0; n<5; n++ ) print("picknote('a,b,c')=",picknote('a,b,c'))
for ( n=0; n<5; n++ ) print("pickphr('a','b','c')=",pickphr('a','b','c'))

ch = 'c e g,f a c,c e g'
print("ch=",ch)
print("chfilter(c,c,c)=",chfilter('c,c,c',ch))
print("chfilter(c,e,c)=",chfilter('c,e,c',ch))
print("chfilter(f,e,b)=",chfilter('f,e,b',ch))
print("chfilter(ct12,e,c,d,f)=",chfilter('ct12,e,c,d,f',ch))
print("chadjust(c,c,c)=",chadjust('c,c,c',ch))
print("chadjust(c,e,c)=",chadjust('c,e,c',ch))
print("chadjust(f,e,b)=",chadjust('f,e,b',ch))
print("chadjust(ct12,e,c,d,f)=",chadjust('ct12,e,c,d,f',ch))
print("scadjust(c,c,c)=",scadjust('c,c,c',ch))
print("scadjust(c,e,c)=",scadjust('c,e,c',ch))
print("scadjust(f,e,b)=",scadjust('f,e,b',ch))
print("scadjust(ct12,e,c,d,f)=",scadjust('ct12,e,c,d,f',ch))
print("scafilt(c,c,c)=",scafilt('c,c,c',ch))
print("scafilt(c,e,c)=",scafilt('c,e,c',ch))
print("scafilt(f,e,b)=",scafilt('f,e,b',ch))
print("scafilt(ct12,e,c,d,f)=",scafilt('ct12,e,c,d,f',ch))
z = []
for(n=0;n<10;n++) {
	i = rand(100)
	z[i] = n
}
for(i in z) delete z[i]
# Nothing should be printed by this loop
for(i in z) print(i)
}
