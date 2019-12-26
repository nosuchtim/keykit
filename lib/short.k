#
# This file contains works in progress for the "call for algorithmic shorts"
#

Sh_notes = [
	0 = [
		0 = 'c',
		1 = 'g',
		2 = transpose(chordnamed("min9"),'c'),
		3 = 'co1'
		],
	1 = [
		0 = 'c',
		1 = 'g',
		2 = transpose(chordnamed("min9"),'c'),
		3 = 'co0'
		],
	2 = [
		0 = 'c',
		1 = 'g',
		2 = transpose(chordnamed("min9"),'c'),
		3 = 'co1'
		],
	3 = [
		0 = 'c',
		1 = 'g',
		2 = transpose(chordnamed("min9"),'c'),
		3 = 'co0'
		],
	4 = [
		0 = 'd',
		1 = 'a',
		2 = transpose(chordnamed("min9"),'d'),
		3 = 'do-1'
		],
	5 = [
		0 = 'd',
		1 = 'a',
		2 = transpose(chordnamed("min9"),'d'),
		3 = 'do0'
		],
	6 = [
		0 = 'e-',
		1 = 'g',
		2 = transpose(chordnamed("sus"),'e'),
		3 = 'eo0'
		],
	7 = [
		0 = 'f',
		1 = 'g',
		2 = transpose(chordnamed("sus"),'e'),
		3 = 'eo-1'
		]
];

Sh_trans = [ 0=0, 1=5, 2=3, 3=-2, 4=0, 5=-5, 6=-2, 7=2 ];

function cutb(p,b) {
	p = cut(p,CUT_TIME,0,b*1b)
	p.length = b*1b
	return(p)
}


Sh_durs = [ 0 = 1b, 1 = 1b/2, 2 = 1b/4, 3 = 1b/8 ];
Sh_octs = [ 0 = 0, 1 = 0, 2 = 0, 3 = 0 ];

function transform_echo4(x) { return(echo(x,4,1b/2,0.6)) }
function transform_echo2(x) { return(echo(x,2,1b/2,0.8)) }
function transform_preecho(x) { return(x | preecho(x,2,1b/8,0.6)) }
function transform_preecho2(x) { return(x | preecho(x,4,1b/8,0.6)) }
function transform_null(x) { return(x) }
function transform_slow(x) { return(scatimes(x,2)) }
function transform_none(x) { return('') }
function transform_step(x) { return(step(x,1b/4)) }
function transform_step2(x) { return(step(x,1b/2)) }
function transform_fractal(x) { return(fractal(x)) }
function transform_stutter(x) { return(stutter(x,1b/2,2)) }
function transform_arpeggio(x) { return(cutb(arpeggio(x),x.length/1b)) }
function transform_tonerow(x) { return(tonerow(x)) }
function transform_thin(x) { return(thinit(x,1b/2)) }
function transform_spread(x) { return(arpeggio(spread(x,2,1b/4,0.5))) }
function transform_reverse(x) { return(reverse(x)) }

Sh_transform1 = [
	0 = transform_null,
	1 = transform_echo2,
	2 = transform_preecho2,
	3 = transform_preecho,
	4 = transform_step,
	5 = transform_step2,
	6 = transform_preecho2,
	7 = transform_step
];

Sh_transform2 = [
	# 0 = transform_step,
	# 1 = transform_step2,
	# 2 = transform_stutter,
	# 3 = transform_arpeggio
	0 = transform_arpeggio,
	1 = transform_step,
	2 = transform_arpeggio,
	3 = transform_stutter
];

function S1(n,v) {

	Bits01 = v & 0x3
	Bits12 = (v>>1) & 0x3
	Bits23 = (v>>2) & 0x3
	Bits45 = (v>>4) & 0x3
	Bits67 = (v>>6) & 0x3

	Bits123 = v & 0x7
	Bits1234 = v & 0xf

	Bits234 = (v>>2) & 0x7

	Bits567 = (v>>5) & 0x7
	Bits4567 = (v>>4) & 0xf

	c = Sh_notes[n][Bits01]
	c.dur = Sh_durs[Bits23]
	c.pitch += Sh_octs[Bits45]
	f = Sh_transform1[Bits234];
	c = f(c)
	c.length = Sh_durs[Bits23]
	return(c)
}

function S2() {
	r = ''
	for ( k=0; k<8; k++) {
		r += S1(k,V++)
	}
	return(cutb(r,2))
}
function S() {
	all = ''
	V = 1
	for ( bb=0; bb<32; bb++ ) {
		s = S2()
		f = Sh_transform2[Bits45];
		b = s.length/1b
		s = f(s)
		s = cutb(s,b)
		# s = transpose(s,Sh_trans[Bits67])
		all += s
	}
	return(all)
}
