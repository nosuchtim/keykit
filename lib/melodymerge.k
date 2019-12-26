##############################################################
# melodymerge_text
# melodymerge
#
# These functions apply an algorithm discussed in the
# algo-comp mailing list.  The function that does the work
# is melodymerge.  melodymerge_text() is a version that
# accepts and returns the "text" notes (C0, D1, etc) rather than
# keykit phrases.
##############################################################

function melodymerge_text(starting,target,intervals) {
	p = melodymerge(text2note(starting),target,intervals)
	return(note2text(p))
}

function melodymerge(starting,target,intervals) {
	lastnt = starting
	merged = lastnt
	while (target != "") {
		c1 = substr(target,1,1)
		c2 = substr(target,2,1)
		skip = 1
		if ( c1 == "+" ) {
			lastnt.pitch += intervals[c2]
			skip++
		} else if ( c1 == "-" ) {
			lastnt.pitch -= intervals[c2]
			skip++
		} else if ( c1 != "=" ) {
			print("Unexpected character in target: ",c1)
		}
		merged += lastnt
		target = substr(target,skip+1)
	}
	return(merged)
}

##############################################################
# Sample usage.
##############################################################

function test_melodymerge() {
	m1 = melodymerge_text("C0","+a+b-c===-a+b+c+c",["a"=1,"b"=2,"c"=3])
	print("test one = ",m1)
	m2 = melodymerge_text("C0","+a+a+b+a+a+a+b==-b+b",["a"=2,"b"=1])
	print("test two = ",m2)

	# Now play them
	p1 = melodymerge(text2note("C0"),
			"+a+b-c===-a+b+c+c",["a"=1,"b"=2,"c"=3])
	p1.pitch += 24
	wait(realtime(p1))
	millisleep(1000)
	p2 = melodymerge(text2note("C0"),
			"+a+a+b+a+a+a+b==-b+b",["a"=2,"b"=1])
	p2.pitch += 24
	wait(realtime(p2))
}

##############################################################
# Utility functions for converting between keykit phrases and
# text strings of the form "C0", "D#1", etc
##############################################################

Note_letters = [	
		"A"=  9,
		"A#"=10,
		"B"= 11,
		"C"=12,
		"C#"= 13,
		"D"= 14,
		"D#"=15,
		"E"= 16,
		"F"= 17,
		"F#"=18,
		"G"= 19,
		"G#"=20]

Note_oct = [		
		"-1" = -1*12,
		"0" =  0*12,
		"1" =  1*12,
		"2" =  2*12,
		"3" =  3*12,
		"4" =  4*12,
		"5" =  5*12,
		"6" =  6*12
	]

function note2text(p) {
	result = ""
	sep = ""
	for ( nt in p ) {
		oct = 0
		while ( nt.pitch > 20 ) {
			nt.pitch -= 12
			oct++
		}
		while ( nt.pitch < 9 ) {
			nt.pitch += 12
			oct--
		}
		for ( i in Note_letters ) {
			if ( Note_letters[i] == nt.pitch ) {
				result += sep + (i + string(oct))
				sep = " "
				break;
			}
		}
	}
	return(result)
}
function text2note(s) {
	c1 = substr(s,1,1)
	c2 = substr(s,2,1)

	if ( ! ( c1 in Note_letters ) ) {
		print("First letter isn't A-G?")
		return('')
	}
	nt = makenote(Note_letters[c1])
	if ( c2 == "#" ) {
		nt.pitch++
		rest = substr(s,3)
	} else {
		rest = substr(s,2)
	}
	if ( ! (rest in Note_oct) ) {
		print("Unexpected format: ",s," rest=",rest)
		return('')
	}
	nt.pitch += Note_oct[rest]
	return(nt)
}

##############################################################
