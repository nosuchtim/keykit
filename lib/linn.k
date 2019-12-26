
function note2rowcol(nt) {
	row = nt.chan - 1
	col = nt.pitch - 30 - (row-1)*12
	return(["row"=row,"col"=col])
}

function reallinn(p,...) {
	p.port = Linnstrument_output
	# print("reallinn p=",p," to Linnstrument")
	realtime(p,...)
}

function linnusermode(onoff) {
	return(nrpnlinn(1,245,onoff))
}

function nrpnlinn(ch,param,value) {
	msbparam = param >> 7
	lsbparam = param & 0x7f
	msbvalue = value >> 7
	lsbvalue = value & 0x7f
	byte1 = 0xb0 | (ch-1)
	return(midibytes(
		byte1, 0x63, msbparam,
		byte1, 0x62, lsbparam,
		byte1, 0x06, msbvalue,
		byte1, 0x26, lsbvalue,
		byte1, 0x65, 0xff,
		byte1, 0x64, 0xff
		))
}

function linnmon(all) {
	if ( nargs() < 1 ) { all = 0 }
	t = task task_linnmon(all)
	Root.waitforconsolekey()
	kill(t)
}

function linntest() {
	a = ''
	for ( r=0; r<8; r++ ) {
		for ( c=0; c<25; c++ ) {
			colour = 1 + (c % 6)
			a += linnlight(r,c,colour)
		}
	}
	reallinn(a)
}

function linnclear(colour) {
	a = ''
	for ( r=0; r<8; r++ ) {
		for ( c=0; c<25; c++ ) {
			a += linnlight(r,c,colour)
		}
	}
	reallinn(a)
}

# NOTE: col = -1 is the switch column
function linnlight(row,col,colour) {
	ch = 1
	p1 = controller(ch,20,col+1)
	p2 = controller(ch,21,row)
	p3 = controller(ch,22,colour)
	a = midibytes(p1,p2,p3)
	return(a)
}

function linnplay() {
	Merge = 0
	t = task task_linnplay()
	Root.waitforconsolekey()
	kill(t)
	Merge = 1
}

function task_linnplay() {
	Midiin[$] = f = open()
	onexit(closemidi,$)

	scale = []
	for ( r=0; r<8; r++ ) {
		scale[r] = completescale('c',"newage")
	}
	pitchoffset = 3*12
	while ( (nt=get(f)) != Eof ) {
		if (nt.type==NOTEON || nt.type==NOTEOFF) {
			rc = note2rowcol(nt)
			# print("chan=",nt.chan," pitch=",nt.pitch," rc=",rc)
			sc = scale[rc["row"]]
			offset = 1 + (rc["col"] % sizeof(sc))
			nt.pitch = sc % offset
			print("nt=",nt)
			nt.time = 0

			nt.pitch += pitchoffset

			# SHOULD THE .port BE SET HERE?
			realtime(nt)
		}
	}
}

function task_linnmon(all) {

	Midiin[$] = f = open()
	onexit(closemidi,$)

	while ( (m=get(f)) != Eof ) {
		if ( all == 0 ) {
			if (m.type==NOTEON || m.type==NOTEOFF) {
				rc = note2rowcol(m)
				print("chan=",m.chan," pitch=",m.pitch," rc=",rc)
			}
			continue
		}

		if (m.type==NOTEON || m.type==NOTEOFF) {
			rc = note2rowcol(m)
			print("chan=",m.chan," pitch=",m.pitch," rc=",rc)
		} else if ( m.type == CONTROLLER ) {
			ch = (integer(subbytes(m,1,1)) & 0xf) + 1
			ct = integer(subbytes(m,2,1))
			v = integer(subbytes(m,3,1))
			print("CONTROL chan=",ch," ctrl=",ct," val=",v)
		} else if ( m.type == PITCHBEND ) {
			ch = (integer(subbytes(m,1,1)) & 0xf) + 1
			v1 = integer(subbytes(m,2,1))
			v2 = integer(subbytes(m,3,1))
                        v = v1 + v2*128
			print("BEND chan=",ch," bend=",v)
		} else if ( m.type == PRESSURE ) {
			ch = (integer(subbytes(m,1,1)) & 0xf) + 1
			p = integer(subbytes(m,2,1))
			v = integer(subbytes(m,3,1))
			print("PRESSURE chan=",ch," p=",p," v=",v)
		} else if ( m.type == CHANPRESSURE ) {
			ch = (integer(subbytes(m,1,1)) & 0xf) + 1
			p = integer(subbytes(m,2,1))
			print("CHANPRESSURE chan=",ch," p=",p)
		} else {
			print("m.type=",m.type," chan=",m.chan," pitch=",m.pitch," vol=",m.vol," p=",m)
		}
	}
}
