function f0(...) {
	f1(...)
}
function f1(a,b,...) {
	print("In f1, nargs=",nargs())
	print("In f1, a=",a,"  b=",b)
	f2(a,...)
}
function f2(r,s,t,u,v,w,...) {
	print("In f2, nargs=",nargs())
	print("In f2, r=",r,"  s=",s,"  t=",t,"  u=",u)
	f3(r,...)
}
function f3(a,b,c,d,e) {
	print("In f3, nargs=",nargs())
	if ( ! defined(b) ) print("b is undefined")
	if ( ! defined(e) ) print("e is undefined")
}
f0(11,22,33,44,55)
