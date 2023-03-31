
function midimon(verbose,notesonly) {

	if ( nargs() < 1 )
		verbose = 0
	if ( nargs() < 2 )
		notesonly = 0
	# spawn the task that will monitor MIDI input
	t = task task_midimon(verbose,notesonly)

	Root.waitforconsolekey()

	kill(t)
}

function unkorgmon(k,f) {
	k.unsendtofifo(f)
}

function print_cs32_msg(m) {
	ch = (integer(subbytes(m,1,1)) & 0xf) + 1
	ct = integer(subbytes(m,2,1))
	v = integer(subbytes(m,3,1))
	if ( ch == 14 && ct >= 16 && ct < 32 )
		print("CS32 row 0 slot ",ct-16," val ",v)
	else if ( ch == 14 && ct >= 80 && ct < 96 )
		print("CS32 row 1 slot ",ct-80," val ",v)
	else if ( ch == 15 && ct >= 16 && ct < 32 )
		print("CS32 row 2 slot ",ct-16," val ",v)
	else if ( ch == 15 && ct >= 0 && ct < 16 )
		print("CS32 row 3 slot ",ct," val ",v)
	else if ( ch == 14 && ct >= 64 && ct < 80 )
		print("CS32 row 4 slot ",ct-64," val ",v)
	else if ( ch == 14 && ct >= 0 && ct < 16 )
		print("CS32 row 5 slot ",ct," val ",v)
}

function task_midimon(verbose,notesonly) {

	k = korgcontrol(0)
	if ( k == -1 ) {
		Midiin[$] = f = open()
		onexit(closemidi,$)
	} else {
		f = open()
		k.sendtofifo(f)
		onexit(unkorgmon,k,f)
	}

	while ( (m=get(f)) != Eof ) {
		if ( verbose ) {
			if ( notesonly==0 && m.type == CONTROLLER ) {
				ch = (integer(subbytes(m,1,1)) & 0xf) + 1
				ct = integer(subbytes(m,2,1))
				v = integer(subbytes(m,3,1))
				print("port=",m.port," chan=",ch," controller=",ct," vol=",v)
			} else if ( notesonly==0 && m.type == CHANPRESSURE ) {
				ch = (integer(subbytes(m,1,1)) & 0xf) + 1
				p = integer(subbytes(m,2,1))
				print("port=",m.port," chan=",ch," chanpressure=",p)
			} else if ( notesonly==0 && m.type == PITCHBEND ) {
				ch = (integer(subbytes(m,1,1)) & 0xf) + 1
				v1 = integer(subbytes(m,2,1))
				v2 = integer(subbytes(m,3,1))
                                v = v1 + v2*128
				print("port=",m.port," chan=",ch," pitchbend=",v)
			} else if ( m.type == NOTEON || m.type == NOTEOFF || m.type == NOTE ) {
				print("port=",m.port," chan=",m.chan," pitch=",m.pitch," vol=",m.vol)
			} else {
				print("port=",m.port," p=",m)
			}
		} else {
			if ( notesonly==0 || m.type==NOTEON || m.type==NOTEOFF ) {
				print(m)
			}
		}
	}
}
