class oneobject {
method init {
	print("In oinit method is",taskinfo("method"))
	$.val = 99
	$.inherit(twoobject())
	$.addchild(twoobject())
	$.addchild(twoobject())
	print("In oinit, sizeof children = ",sizeof($.children()))
	a = $
	a = []
	a[$] = 44
	a["hello"] = 55
	print("a is ",a[$],a["hello"])
	if ( defined($.ometh) )
		print("ometh is defined")
	if ( defined($.xxx) )
		print("xxx is not defined")
	if ( defined($) ) print("dollar is defined!")
}
method ometh() {
	print("In ometh, method is",taskinfo("method"))
	print("val=",$.val)
	if ( defined($) ) print("dollar is defined!")
	$.addchild(twoobject())
}
}

class twoobject {
method init {
	print("In oinit2 method is",taskinfo("method"))
	$.val = 99
}
}

o=new oneobject()
o.ometh()
print("BEFORE objectlist=",sizeof(objectlist()))
if ( defined(o.init) ) print("init is defined")
if ( defined(o.ometh) ) print("ometh is defined")
if ( defined(o.xyz) ) print("xyz is defined")
if ( defined($) ) print("dollar is defined!?")
delete o
print("AFTER objectlist=",objectlist())
