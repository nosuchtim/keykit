function jv_bank_patch(ch,s,pn) {
	r = ''
	if ( s == "A" ) {
		r += bankselect(ch,81,0)
	} else if ( s == "B" ) {
		r += bankselect(ch,81,1)
	} else if ( s == "C" ) {
		r += bankselect(ch,81,2)
	} else if ( s == "GM" || s == "D" ) {
		r += bankselect(ch,81,3)
	} else if ( s == "E" ) {
		r += bankselect(ch,81,4)
	}
	r.length++
	r += progchange(pn,ch)
	r.length++
	return(r)
}

function jvpatch_A(ch,pn) { return(jv_bank_patch(ch,"A",pn)) }
function jvpatch_B(ch,pn) { return(jv_bank_patch(ch,"B",pn)) }
function jvpatch_C(ch,pn) { return(jv_bank_patch(ch,"C",pn)) }
function jvpatch_D(ch,pn) { return(jv_bank_patch(ch,"D",pn)) }
function jvpatch_E(ch,pn) { return(jv_bank_patch(ch,"E",pn)) }
