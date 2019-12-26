# Example of sub-classing an existing tool,
# with an intervening hook for one of its methods.

class wtempo2 {
method init {
	$.w = new wtempo()
	$.inherit($.w)
}
method mousedown (m) {
	print("wtempo2 mousedown called")
	$.w.mousedown(m)
}
}
