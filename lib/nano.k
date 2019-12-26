# This is NON-WORKING CODE

#name	nanopatch
#usage	nanopatch(ch,bank,prog)
#desc	Return sysex that changes a parts bank/program.
#desc	Assumes that the 16 parts are assigned to channels 1-16.
#desc	ch is 1-based
#desc	bank is 0-based
#desc	prog is 0-based
function nanopatch(ch,bank,prog) {
	b = midibytes(
		bankselect(ch,0,bank),
		progchange(prog+1,ch)
		)
	return(b)
}

# This function returns an array containing the names
# of patches of a given type (e.g. "pad", "hard", "percussive", etc.)

function patchmap_types_nano(type) {
	n=0
	p = []
	if ( "pad" ~~ type ) {
		p[n++] = "Water Space"
	}
	if ( "hard" ~~ type ) {
		p[n++] = "FM.*SA EP"
	}
	if ( "bass" ~~ type ) {
		p[n++] = "Picked Bass2"
	}
	if ( "perc" ~~ type ) {
		p[n++] = "Muted Gt."
	}
	if ( "drum" ~~ type ) {
		p[n++] = "Kick Menu 2"
	}
	if ( "vocal" ~~ type ) {
		p[n++] = "JzVoice Thum"
	}

	return(p)
}

function patchmap_nano() {

	if ( defined(Patchmapnano) )
		return(Patchmapnano)

	r = []
	n = 0

	r[n++] = [ "name"="Tsunami Warning", "func"="nanopatch(CH,0,0)"]
	r[n++] = [ "name"="Rain Forest", "func"="nanopatch(CH,3,127)"]

 	r[n++] = ["name"="None", "func"=""]

	Patchmapnano = r

	return(Patchmapnano)
}
