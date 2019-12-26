# This is an example of a minimal tool object.
# It is capable of being resized, redrawn, dumped, and restored.

class whello {
	method init {
		$.w = new window()
		$.inherit($.w)
	}
	method redraw {
		$.w.redraw()
		$.w.text("Hello World",$.w.size())
	}
}
