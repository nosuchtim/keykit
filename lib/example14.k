# This shows various semantics in the inheritence of values.
#
# Note that in ex14a, the value of $.val2 returned by vfunc2()
# is the one declared in the "base class", while the value
# returned by vfunc2b() (which uses $$ rather than $)
# is the one returned by the derived class.

function example14() {
	print("example 14 start")
	c = new ex14c()
	print("c.vfunc = ",c.vfunc())
	print("c.test1 = ",c.test1())
	print("c.test2 = ",c.test2())
	print("c.vfunc2 = ",c.vfunc2())
	print("c.vfunc2b = ",c.vfunc2b())
}
class ex14c {
	method init {
		$.inherit(new ex14b())
		$.val2 = "C VAL2"
	}
	method test1 {
		return($.val1)
	}
	method test2 {
		return($.val2)
	}
}
class ex14b {
	method init {
		$.inherit(new ex14a())
	}
}
class ex14a {
	method init {
		$.val1 = "A VAL1"
		$.val2 = "A VAL2"
	}
	method vfunc {
		return("A FUNC")
	}
	method vfunc2 {
		return($.val2)
	}
	method vfunc2b {
		return($$.val2)
	}
}
