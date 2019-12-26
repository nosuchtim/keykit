function happy_rhythmsets4() {
	return([
		0 = [
			0 = 'a',
			1 = 'a',
			2 = 'ad24,ad24,ad48,ad24,ad24',
			3 = 'ad24,ad24',
			4 = 'ad24,ad24,ad48',
			5 = 'ad48,ad24,ad24',
			6 = 'ad24,ad48,ad24',
			7 = 'ad24,a,a,a'
			],
		1 = [
			0 = 'ad24,r,ad24,ad24,ad24,r,ad24',
			1 = 'ad24,ad48,ad48,rd24,ad48',
			2 = 'ad24,ad24,ad48,ad24,ad24,ad24',
			3 = 'ad24,ad24,ad24,ad24,rd48,ad48',
			4 = 'ad24,ad24,rd48,ad48,ad24',
			5 = 'ad48,ad24,ad24,ad48,ad48',
			6 = 'ad48,ad48,rd24,ad24,ad24,ad24',
			7 = 'ad24,a,ad120,ad24'
			],
		2 = [
			0 = 'ad24,r,ad24,ad24,r,ad24,ad24',
			1 = 'ad48,ad24,a,a,r',
			2 = 'ad24,ad24,ad48,ad24,ad24',
			3 = 'ad24,ad24,ad24,ad48,ad48',
			4 = 'ad48,ad24,ad24,ad48,ad48',
			5 = 'ad48,ad12,ad24,ad24,ad24,ad12,ad48,ad48',
			6 = 'ad24,r,ad48,ad48',
			7 = 'ad24,a,a,ad48,a,ad24,a,a,ad48'
			]
		]
	)
}
function happy_rhythmsets6() {
	return([
		0 = [
			0 = 'ad24,ad24',
			1 = 'ad24,ad24',
			2 = 'ad24,ad24',
			3 = 'ad24,ad24',
			4 = 'ad24,ad24',
			5 = 'ad24,ad24',
			6 = 'ad24,ad24',
			7 = 'ad24,ad24'
			],
		1 = [
			0 = 'ad24,ad24',
			1 = 'ad48,ad48',
			2 = 'ad24,ad24,ad48,ad24,ad48,ad24',
			3 = 'ad24,ad24,ad48,ad48',
			4 = 'ad24,ad48,ad24,ad24,ad48,ad24',
			5 = 'ad48,ad24,ad24',
			6 = 'ad24,ad48,ad24',
			7 = 'ad24,a,a,a,ad48,ad48'
			],
		2 = [
			0 = 'ad24,r,ad24,ad24,ad24,r,ad24',
			1 = 'ad24,ad24,r,ad12,ad12,ad24,ad24',
			2 = 'ad24,ad24,ad48,ad24,ad24,ad24',
			3 = 'ad24,ad24',
			4 = 'ad24,ad24,ad48',
			5 = 'ad48,ad24,ad24,ad24,ad24,ad24,ad24',
			6 = 'ad24,ad48,ad24,ad24,ad24,ad48',
			7 = 'ad24,a,a,a'
			],
		3 = [
			0 = 'ad24,r,ad24,ad24,r,ad24,ad24',
			1 = 'ad12,ad24,r,ad12,ad24,ad48,ad24,ad24',
			2 = 'ad24,ad24,ad48,ad24,ad24',
			3 = 'ad24,ad24,ad24,ad48,ad48',
			4 = 'ad48,ad24,ad24,ad48,ad48',
			5 = 'ad48,ad24,ad12,ad12,ad24',
			6 = 'ad24,r,ad48,ad48',
			7 = 'ad24,a,ad12,ad12,a,ad12,ad12,a'
			]
		]
	)
}
function happy_riffsets6() {
	return([
		0 = [
			0 = 'c e g',
			1 = 'c f g',
			2 = 'c co4 g',
			3 = 'c fo2 g',
			4 = 'c eo4 co5',
			5 = 'c co2 fo4',
			6 = 'c a f',
			7 = 'c b- g'
			],
		1 = [
			0 = 'a',
			1 = 'b',
			2 = 'c',
			3 = 'd',
			4 = 'e',
			5 = 'f',
			6 = 'g',
			7 = 'a'
			],
		2 = [
			0 = 'c,e,g',
			1 = 'f,g',
			2 = 'e,g,c',
			3 = 'a,g,f',
			4 = 'c,f,g',
			5 = 'c,co4',
			6 = 'c,co2',
			7 = 'g,e'
			],
		3 = [
			0 = 'c e g',
			1 = 'g f c',
			2 = 'f a c',
			3 = 'e g b',
			4 = 'e a c',
			5 = 'c f g',
			6 = 'c g co4',
			7 = 'c co2'
			]
		]
	)
}

function happy_patchset6_rhythmic() {
	f = patchtypes_for_chan(1)
	return(f("hard"))
}

function happy_patchset6_bass() {
	f = patchtypes_for_chan(1)
	return(f("bass"))
}

function happy_patchset6_light() {
	f = patchtypes_for_chan(1)
	return(f("pad"))
}

function happy_patchset6_pads() {
	f = patchtypes_for_chan(1)
	return(f("pad"))
}

function happy_patchset6_slow() {
	f = patchtypes_for_chan(1)
	return(f("pad"))
}

function happy_drumsets6snares() {
	n=0
	a = []
	a["name"] = []
	a["notes"] = []

	a["name"][n] = "Jazz/Brush Kits"
	a["notes"][n] = 'p24,p26,p28,p29,p33,p35,p40,p42,p48,p56,p74,p79,p80,p85,p87,p89'
	n++
	a["name"][n] = "BassDrums&Snares"
	a["notes"][n] = 'p26,p27,p29,p30,p35,p36,p37,p46,p47,p52,p62,p67,p74,p82,p91'
	n++
	a["name"][n] = "Percussion Kit"
	a["notes"][n] = 'p24,p25,p26,p27,p28,p29,p30,p31,p32,p33,p34,p35,p36,p40,p43,p53,p59,p65,p70,p72,p73,p74,p75,p76,p79'
	n++
	a["name"][n] = "Psycho Kit"
	a["notes"][n] = 'p26,p29,p31,p35,p36,p40,p44,p46,p48,p49,p51,p54,p66,p77,p80,p90,p100'
	n++
	a["name"][n] = "Analog/Club Kits"
	a["notes"][n] = 'p24,p25,p26,p30,p31,p32,p37,p41,p43,p45,p54,p55,p58,p61,p89,p91,p92,p94,p100,p101,p102,p103'
	n++
	a["name"][n] = "Processed Kit"
	a["notes"][n] = 'p36,p39,p41,p42,p46,p47,p54,p66,p72,p73,p74,p75,p76,p80'
	n++
	a["name"][n] = "House/Techno/Jun"
	a["notes"][n] = 'p24,p29,p31,p32,p33,p34,p38,p41,p43,p44,p55,p56,p61,p63,p65,p67,p68,p71,p96'
	n++
	a["name"][n] = "Standard Kit"
	a["notes"][n] = 'p24,p25,p26,p27,p28,p29,p30,p31,p32,p33,p36,p38,p40,p48,p49,p50,p53,p54,p55,p57,p59,p60,p62,p73,p74,p75,p76,p77'
	n++
	a["name"][n] = "Mega Mix"
	a["notes"][n] = 'p26,p29,p31,p32,p38,p41,p49,p54,p73,p76,p78'
	n++
	return(a)
}
function happy_drumsets6soft() {
	n=0
	a = []
	a["name"] = []
	a["notes"] = []

	a["name"][n] = "Jazz/Brush Kits"
	a["notes"][n] = 'p26,p33,p35,p48,p56,p74'
	n++
	a["name"][n] = "BassDrums&Snares"
	a["notes"][n] = 'p29,p30,p35,p36,p52,p82,p93'
	n++
	a["name"][n] = "Analog/Club Kits"
	a["notes"][n] = 'p24,p25,p31,p32,p37,p41,p43,p55,p58,p61,p101,p106'
	n++
	a["name"][n] = "Psycho Kit"
	a["notes"][n] = 'p29,p31,p35,p36,p38,p48,p51,p54,p66,p79,p90,p94,p100'
	n++
	a["name"][n] = "House/Techno/Jun"
	a["notes"][n] = 'p24,p29,p31,p32,p38,p41,p43,p55,p67,p71'
	n++
	a["name"][n] = "Percussion Kit"
	a["notes"][n] = 'p24,p25,p26,p29,p30,p31,p32,p33,p35,p43,p65,p72,p74,p75'
	n++
	a["name"][n] = "Processed Kit"
	a["notes"][n] = 'p36,p47,p54,p74,p76,p80,p82'
	n++
	a["name"][n] = "Standard Kit"
	a["notes"][n] = 'p24,p25,p26,p27,p28,p29,p30,p31,p32,p33,p36,p38,p40,p48,p73,p74,p75,p76,p77'
	n++
	a["name"][n] = "Mega Mix"
	a["notes"][n] = 'p28,p29,p32,p41,p73,p76,p78,p88,p101,p105'
	n++
	return(a)
}
