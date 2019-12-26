# An example of using function references in an object.
# This one keeps an array of function references, and
# then invokes one of them in the value() method.
#
# Also demonstrated is the ability to invoke a method
# indirectly, using a string value that is dynamically
# looked-up - there's one example of this at the
# end of example15(), and another example in the
# othervalue() method.

function example15() {
	print("example 15 start")
	c = new ex15()

	print("c.value = ",c.value())

	print("c.othervalue = ",c.othervalue())

	meth = "othervalue"
	print("c.othervalue = ",c.(meth)())
}
class ex15 {
	method init {
		$.funcarr = ["one"=$.func1, "two"=$.func2]
	}
	method value {
		f = $.funcarr["one"]
		return(f())
	}
	method othervalue {
		v = $.("func1")()
		return(v)
	}
	method func1 {
		return(1)
	}
	method func2 {
		return(2)
	}
}
