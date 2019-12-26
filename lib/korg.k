KorgLcdColor = [
	1=3,
	2=3,
	3=3,
	4=3,
	5=3,
	6=3,
	7=3,
	8=3,
	"main"=3
]
KorgPadNote = [
	1=1,
	2=2,
	3=3,
	4=4,
	5=5,
	6=6,
	7=7,
	8=8,
	9=9,
	10=10,
	11=11,
	12=12,
	13=13,
	14=14,
	15=15,
	16=16
]
KorgPadLeds = [
	1=1,
	2=1,
	3=1,
	4=1,
	5=1,
	6=1,
	7=1,
	8=1,
	9=1,
	10=1,
	11=1,
	12=1,
	13=1,
	14=1,
	15=1,
	16=1,
	"enter"=1,
	"exit"=1,
	"scene"=1,
	"message"=1,
	"setting"=1,
	"<red"=1,
	">green"=1,
	"<green"=1,
	">green"=1,
	"tempo"=1,
	"hex"=1
	]
KorgLabels = [
	"main"="KeyKit",
	1="",
	2="",
	3="",
	4="",
	5="",
	6="",
	7="",
	8=""
	]

function korg_init() {
	task korg_router()
	task ergo()
	task hoops2()
}

function nummidibytes(p) {
	p.port = 0
	p.time = 0
	return ((sizeof(string(p))-3)/2)
}
function korg_send(p,f) {
	if ( ! defined(Korgctrl) ) {
		print("You must define Korgctrl in your keylocal.k file!")
		return()
	}
	out = Korgctrl
	p.port = out
	realtime(p)
}
function korg_label(s) {
	if ( sizeof(s) > 8 ) {
		print("korg_label too long, truncating")
		s = substr(s,1,8)
	}
	if ( sizeof(s) < 8 ) {
		s = s + substr("          ",1,8-sizeof(s))
	}
	return(midibytes(
		ascii(substr(s,1,1)),
		ascii(substr(s,2,1)),
		ascii(substr(s,3,1)),
		ascii(substr(s,4,1)),
		ascii(substr(s,5,1)),
		ascii(substr(s,6,1)),
		ascii(substr(s,7,1)),
		ascii(substr(s,8,1))
		))
}
function korg_native_on() {
	print("KORG_NATIVE_ON !!!")
	oldMerge = Merge
	Merge = 0

	id = gettid()
	lock(id)
	Midiin[id] = f = open();

	p0 = 'xf042406e00000001f7'
	korg_send(p0,f)

	korg_push_table3(f)

	korg_push_labels(f)

	delete Midiin[id]
	close(f)
	unlock(id)
}

function korg_push_table3(f) {
	pads_send_notes = 'x7f7f03'	# To have pads send notes
	pads_send_notes = 'x000000'	# Pads don't send notes (only sysex)
	table3 = midibytes('x000000',pads_send_notes
		,'x00000000000000000000000000000000', # pad channels
		KorgPadNote[1],
		KorgPadNote[2],
		KorgPadNote[3],
		KorgPadNote[4],
		KorgPadNote[5],
		KorgPadNote[6],
		KorgPadNote[7],
		KorgPadNote[8],
		KorgPadNote[9],
		KorgPadNote[10],
		KorgPadNote[11],
		KorgPadNote[12],
		KorgPadNote[13],
		KorgPadNote[14],
		KorgPadNote[15],
		KorgPadNote[16]
		)
	p1 = midibytes('xf042406e003f2700',table3,'xf7')
	korg_send(p1,f)
}

function korg_set_label(n,label,color) {
	if ( nargs() < 3 )
		color = 3
	if ( color < 0 || color > 3 ) {
		print("Bad color given to korg_set_label (",color,")")
		color = 3
	}
	KorgLabels[n] = label
	KorgLcdColor[n] = color
	korg_do(global(korg_push_labels))
}

function korg_do(fnc) {
	id = gettid()
	lock(id)
	Midiin[id] = f = open();
	fnc(f)
	delete Midiin[id]
	close(f)
	unlock(id)
}

function korg_set_pad(n,onoff) {
	KorgPadLeds[n] = onoff
	korg_do(global(korg_push_labels))
}

function korg_push_labels(f) {

	b0 = KorgPadLeds[1]
		| (KorgPadLeds[2] << 1 )
		| (KorgPadLeds[3] << 2 )
		| (KorgPadLeds[4] << 3 )
		| (KorgPadLeds[5] << 4 )
		| (KorgPadLeds[6] << 5 )
		| (KorgPadLeds[7] << 6 )
	b1 = KorgPadLeds[8]
		| (KorgPadLeds[9] << 1 )
		| (KorgPadLeds[10] << 2 )
		| (KorgPadLeds[11] << 3 )
		| (KorgPadLeds[12] << 4 )
		| (KorgPadLeds[13] << 5 )
		| (KorgPadLeds[14] << 6 )
	b2 = KorgPadLeds[15]
		| KorgPadLeds[16] << 1 
		| KorgPadLeds["setting"] << 2
		| KorgPadLeds["message"] << 3
		| KorgPadLeds["scene"] << 4
		| KorgPadLeds["exit"] << 5
		| KorgPadLeds["enter"] << 6
	b3 = KorgPadLeds["hex"]
		| KorgPadLeds["tempo"] << 1 
		| KorgPadLeds[">green"] << 3
		| KorgPadLeds["<green"] << 4
		| KorgPadLeds[">red"] << 5
		| KorgPadLeds["<red"] << 6
	b4 = KorgLcdColor[1]
		| KorgLcdColor[2] << 4
	b5 = KorgLcdColor[3]
		| KorgLcdColor[4] << 4
	b6 = KorgLcdColor[5]
		| KorgLcdColor[6] << 4
	b7 = KorgLcdColor[7]
		| KorgLcdColor[8] << 4
	b8 = KorgLcdColor["main"]
	table4 = midibytes(b0,b1,b2,b3,b4,b5,b6,b7,b8
			,korg_label(KorgLabels["main"]))
	p2 = midibytes('xf042406e003f1201',table4,'xf7')
	korg_send(p2,f)

	table5 = midibytes(korg_label(KorgLabels[1]),
		korg_label(KorgLabels[2]),
		korg_label(KorgLabels[3]),
		korg_label(KorgLabels[4]))
	p3 = midibytes('xf042406e003f2102',table5,'xf7')
	korg_send(p3,f)

	table6 = midibytes(korg_label(KorgLabels[5]),
		korg_label(KorgLabels[6]),
		korg_label(KorgLabels[7]),
		korg_label(KorgLabels[8]))
	p4 = midibytes('xf042406e003f2103',table6,'xf7')
	korg_send(p4,f)

}

function korg_native_off() {

	id = gettid()
	lock(id)
	Midiin[id] = f = open();

	p5 = 'xf042406e00000000f7'
	korg_send(p5,f)

	delete Midiin[id]
	close(f)
	unlock(id)
}
		
function korg_inq(ch) {
	p = midibytes('xf07e',ch-1,'x0601f7')
	realtime(p)
	print("p=",p)
}
		
function korg_portdetect(ch) {
	p = midibytes('xf042',ch-1+'x40','x6e001e0001f7')
	realtime(p)
	print("p=",p)
}
		
function korg_dump(ch) {
	if ( nargs() < 1 ) {
		print("usage: korg_dump(channel)")
		return('')
	}
	p = midibytes('xf042',0x40+ch-1,'x6e00','x1f','x10','x00','xf7')
	realtime(p)
	print("p=",p)
}

function korg_led(ch,led,d) {
	if ( nargs() < 3 ) {
		print("usage: korg_led(channel,led,onoff)")
		return('')
	}
	p = midibytes('xf042',0x40+ch-1,'x6e00','x01',led,d,'xf7')
	realtime(p)
	print("p=",p)
}
function korg_lcd(ch) {
	p = midibytes('xf042',0x40+ch-1,'x6e00','x22','x09','x20',
			'x6e',
			'x6e',
			'x6e',
			'x6e',

			'x6e',
			'x6e',
			'x6e',
			'x6e',

			'xf7')
	realtime(p)
	print("p=",p)
}
function korg_try() {
	ch = 1
print("start");
	for ( led=0;led<0x1d;led++) {
		for ( n=0; n<128; n++ ) {
			p = midibytes('xf042',0x40+ch-1,'x6e00','x01',
				led,n,'xf7')
print("p=",p)
			realtime(p)
			millisleep(100)
		}
	}
print("stop");
}

function korg_filter() {
	oldMerge = Merge
	Merge = 0

	# spawn the task that will monitor MIDI input
	t = task task_korg_filter()

	wait(t)

	print("Turning Merge back on...")
	kill(t)
	Merge = oldMerge
}

function task_korg_filter() {

	tid = gettid()
	Midiin[tid] = f = open()
	onexit(closemidi,tid)

	# Read MIDI input messages forever (or until
	# the task is killed.
	currcontrol = 7	# volume

	if ( ! defined(KorgA) ) {
		print("You must define KorgA in your keylocal.k file!")
		return()
	}
	if ( ! defined(KorgB) ) {
		print("You must define KorgB in your keylocal.k file!")
		return()
	}

	mainport = KorgA
	controlport = KorgB

	lastchan = []
	# Fill it in so we don't have to check for existence
	for ( i=0; i<127; i++ )
		lastchan[i] = [1=1]

	chanof = [13 = 1, 14 = 2, 15 = 3, 16 = 4,
		  9 = 5, 10 = 6, 11 = 7, 12 = 8]
	control2chan = [101=1, 102=2, 103=3, 104=4, 105=5, 106=6, 107=7, 108=8,
		 109=9, 110=10, 111=11, 112=12, 113=13, 114=14, 115=15, 116=16]
	paddown = []
	muted = []
	for ( i=1; i<=16; i++ ) {
		paddown[i] = 0
		muted[i] = 0
	}

	ignoreup = -1
	solochan = 0
	solochanpitch = 13	# Pad 0
	solochan10pitch = 14	# Pad 1
	addchan = 0
	addchanpitch = 15	# Pad 2
	addchan10pitch = 16	# Pad 3
	currchan = [1=1]
	while ( (n=get(f)) != Eof ) {

		t = n.type
		if ( n.port == mainport ) {
			if ( t == NOTEON ) {
				if ( solochan ) {
					can = canonic(n) + solochan
					currchan = [can=1]
					print("Currchan = ",currchan)
					ignoreup = n.pitch
					continue
				} else {
					r = ''
					for ( c in currchan ) {
						n.chan = c
						r |= n
					}
					lastchan[n.pitch] = currchan
					n = r
				}
			} else if ( t == NOTEOFF ) {
				if ( n.pitch == ignoreup ) {
					ignoreup = -1
					continue
				} else {
					r = ''
					for ( c in lastchan[n.pitch] ) {
						n.chan = c
						r |= n
					}
					n = r
				}
			} else if ( t == CHANPRESSURE
				|| t == CONTROLLER
				|| t == PROGRAM
				|| t == PRESSURE
				|| t == PITCHBEND
				) {
				r = ''
				for ( c in currchan ) {
					n.chan = c
					r |= n
				}
				n = r
			}
			realtime(n,0)
		} else if ( n.port == controlport ) {
			if ( t == NOTEON ) {
				if ( n.pitch == solochanpitch ) {
					solochan = 1
					continue
				}
				if ( n.pitch == solochan10pitch ) {
					solochan = 11
					continue
				}
				# if ( n.pitch in chanof ) {
				# 	currchan = chanof[n.pitch]
				# 	print("Currchan =",currchan)
				# }

				print("CONTROL PORT n= ",n,", has no function")
				# realtime(n,0)

				paddown[n.pitch] = 1
				if ( n.pitch <= 16 &&
					n.pitch > 1 &&
					paddown[(n.pitch)-1] == 1 ) {
					break
				}
			} else if ( t == NOTEOFF ) {
				paddown[n.pitch] = 0
				if ( n.pitch == solochanpitch
					|| n.pitch == solochan10pitch ) {
					solochan = 0
					continue
				}
			} else if ( t == CONTROLLER ) {
				cn = 0+subbytes(n,2,1)
				v = 0+subbytes(n,3,1)
				if ( cn in control2chan ) {
					ch = control2chan[cn]
					n = controller(ch,currcontrol,v)
					n.port = mainport # is this needed?
					realtime(n,0)
				} else {
					print("Unrecognized controller n=",n)
				}
			} else {
				print("Unrecognized controlport n=",n)
			}
		} else {
			print("Unexpected port!?  port=",n.port)
		}
	}
}

function korgmon() {
	f = open()
	k = korgcontrol()
	k.sendtofifo(f)
	t = task task_korg_mon(f,k)
	Root.waitforconsolekey()
	kill(t)
	k.unsendtofifo(f)
	close(f)
}
function task_korg_mon(f,k) {
	
	while ( (m=get(f)) != Eof ) {
		print(m)
	}
}
function korg_noise(kk) {
	for ( n=0; n<kk; n++ ) {
		i = rand(16)
		k = rand(10000)
		c = rand(4)
		korg_set_label(i+1,string(k),c)
	}
}
