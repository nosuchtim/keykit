# This is the guts of "Mouse Matrix", usable as an object, not as a gui tool.

class mmatrix {

method init(rows,cols,p1,p2,scl) {

	$.rows = rows
	$.cols = cols

	$.p1 = p1
	$.p2 = p2

	if ( nargs() < 5 ) {
		$.scl = scale_newage()
	} else {
		$.scl = scl
	}

	$.mmstate = 0	# 1 if a note is currently playing
	$.mmnotes = ''
	$.mmpitches = ''
	$.mmquant = 0

	$.mmmake()
}

method getcell (r,c,ms) {
	if ( nargs() < 3 ) {
		ms = 1
	}
	n1 = 'a'
	n1.pitch = $.cells[r * $.cols + c]
	n1.chan = ms
	return(n1)
}

method mmmake() {

	$.cells = []

	nt1 = $.p1
	p1pitch = nt1.pitch

	p2 = $.p2
	p1 = $.p1
	dp = (p2.pitch - p1.pitch)/2

	for ( r=0; r<$.rows; r++ ) {


		if ( r == 0 )
			nt1.pitch = p1pitch
		else
			nt1.pitch = p1pitch + dp * r / ($.rows-1)

		for ( c=0; c<$.cols; c++ ) {

			n = $.p1
			if ( c == 0 )
				n.pitch = nt1.pitch
			else
				n.pitch = nt1.pitch + dp * c / ($.cols-1)
			n = closest(n, $.scl)

			$.cells[r*$.cols+c] = n
		}
	}
}
method printcells {
	for ( r=0; r<$.rows; r++ ) {
		for ( c=0; c<$.cols; c++ ) {
			print(r,c,$.getcell(r,c))
		}
	}
}
}
