function minor(a) { return ( a | transpose(a,3) | transpose(a,7) ) }
function major(a) { return ( a | transpose(a,4) | transpose(a,7) ) }
print(minor('c'))
print(major('c'))
f = minor
print(f('c'))
function pickfunc(arg,n,f1,f2) {
     if ( n == 0 )
          return(f1(arg))
     else
          return(f2(arg))
}
print(pickfunc('c',0,major,minor))
print(pickfunc('c',1,major,minor))
function pickf(n,f1,f2) {
     if ( n == 0 )
          return(f1)
      else
          return(f2)
}
for(n=0;n<10;n++){
	f = pickf(0,major,minor)
	print(f('c'))
	print(pickf(0,major,minor)('c'))
	print(pickf(1,major,minor)('c'))
	
	a = []
	a[1] = 3 ; a[2] = 6 ; a[3] = 9
	b = a
	print(b[2])
	a = [0=3,1=4,2=5,3=6]
	print(sizeof(a))
	print(a,b,string(a),string(b))
	print(sizeof(b))
	print(b[2])
	
	c = [0=[0=2,1=3,2=4],1=[0="hello",1="world"]]
	print(typeof(c))
	print(sizeof(c))
	arrayprint(c)
	print(c,string(c))
}
