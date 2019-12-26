# name: gm2on()
function gm2on() {
	return('xf07e7f0903f7')
}

function gm2a() {
	realtime(gm2on())
	realtime(controller(1,0,120))
	realtime(controller(1,32,0))
	realtime(progchange(9,1))
}

# name: brightnote(ch,v)
# desc: Construct a brightness controller message (General MIDI 2)
function brightnote(ch,v) {
	return(controller(ch,74,v))
}

# name: harmonicnote(ch,v)
# desc: Construct a harmonic controller message (General MIDI 2)
function harmonicnote(ch,v) {
	return(controller(ch,71,v))
}

# name: decaynote(ch,v)
# desc: Construct a decay controller message (General MIDI 2)
function decaynote(ch,v) {
	return(controller(ch,75,v))
}

# name: attacknote(ch,v)
# desc: Construct a attack controller message (General MIDI 2)
function attacknote(ch,v) {
	return(controller(ch,73,v))
}

# name: releasenote(ch,v)
# desc: Construct a release controller message (General MIDI 2)
function releasenote(ch,v) {
	return(controller(ch,72,v))
}

function gm2reverbtype(n) {
	pp = 0
	vv = n
	if ( n<0 || n==5 || n==6 || n==7 || n>8 ) {
		print("Invalid value given to gm2reverbtype\n")
		return('')
	}
	return(midibytes(0xf0,0x7f,0x7f,
		0x04,0x05,0x01,0x01,0x01,0x01,0x01,pp,vv,0xf7))
}
function gm2reverbtime(n) {
	pp = 1
	vv = n
	return(midibytes(0xf0,0x7f,0x7f,
		0x04,0x05,0x01,0x01,0x01,0x01,0x01,pp,vv,0xf7))
}
