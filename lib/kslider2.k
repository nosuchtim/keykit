class kslider2 {
method init (...) {
	$.k = new kslider(...)
	$.inherit($.k)
}
method mousedown (m) {
	print("kslider2 mousedown m=",m)
	$.k.mousedown(m)
}
}

