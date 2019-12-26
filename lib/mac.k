##############################################################
## These are Mac only functions
##############################################################

function fileWatch() {
	f = open("", "r", "openDocs")

	# Delay reading until everything's ready.
	# If you get errors from trying to launch
	# keykit by double-clicking a .kp file, try increasing this:
	millisleep(2000);

	while ( (s = ascii(get(f)) ) != Eof) {
		while ( fifosize(f) > 0) {
			s += ascii(get(f))
		}
		page_readnew(s)
	}
}

function scriptWatch() {
	f = open("", "r", "doScript")
	while ( (s = ascii(get(f)) ) != Eof) {
		while ( fifosize(f) > 0) {
			s += ascii(get(f))
		}
		eval s
	}
}
