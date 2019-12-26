# This object puts the Korg microKONTROL into 'native' mode
# and lets you get things from it

function korgcontrol(complain) {
	if ( nargs() < 1 )
		complain = 1
	if ( ! defined(KorgA) ) {
		if ( complain )
			print("You must define KorgA in your keylocal.k file!")
		return(-1)
	}
	if ( ! defined(KorgB) ) {
		if ( complain )
			print("You must define KorgB in your keylocal.k file!")
		return(-1)
	}

	if ( !defined(Korg_control) || Korg_control == $0 || Korg_control == $-1) {
		Korg_control = new korgcontrol_obj()
	}
	return(Korg_control)
}
class korgcontrol_obj {
	method init(standalone) {

		$.itid = -1
		$.debug = 0
		$.mfifo = 0
		$.notify = []
		print("------------ korgcontrol start native")
		$.korgport = KorgA
		korg_native_on()
		$.itid = task $.task_input()
		$.octave = 0
	}
	method sendtofifo(f) {
		$.notify[f] = 1
	}
	method unsendtofifo(f) {
		delete $.notify[f]
	}
	method setdebug(dbg) {
		$.debug = dbg
	}
	method setlabel(n,name) {
		korg_set_label(n,name)
	}
	method delete {
		print("korgcontrol_obj is being deleted")
		korg_native_off()
		if ( $.itid >= 0 )
			kill($.itid)
	}

	method cleanup {
		closemidi($)
		Merge = $.oldmerge
		Midiingrab = -1
	}

	method task_input {
		Midiingrab = $.mfifo = open()
		$.oldmerge = Merge
		Merge = 0
		onexit(global(domethod),$,"cleanup")

		print("korgcontrol task_input start")
		while ( (m=get($.mfifo)) != Eof ) {

		    print("korgcontrol task_input got m=",m)
		    if ( sizeof($.notify) == 0 )
			continue
		    m.time = 0
			
		    cmd = ""
		    if ( m.port == $.korgport ) {
			origm = m
			m.port = 0
			if ( m == 'xf7' )
				continue
			part1 = subbytes(m,1,5)
			if ( part1 != 'xf042406e00' ) {
				print("Unrecognized message from korg: ",m," origm=",origm)
				continue
			}
			part2a = integer(subbytes(m,6,1))
			pnum = integer(subbytes(m,7,1))
			part2c = integer(subbytes(m,8,1))
			if ( part2a == 0x45 ) {
				if ( pnum < 16 )
					s = "padoff "
				else {
					s = "padon "
					pnum -= 64
				}
				pnum++
				cmd = s+string(pnum)+" "+string(part2c)
			} else if ( part2a == 0x44 ) {
				pnum++
				cmd = "slider "+string(pnum)+" "+string(part2c)
			} else if ( part2a == 0x43 ) {
				if ( part2c < 64 ) {
					s = "encoderinc "
				} else {
					part2c = 128 - part2c
					s = "encoderdec "
				}
				pnum++
				cmd = s+string(pnum)+" "+string(part2c)
			} else if ( part2a == 0x48 ) {
				bname = [0="<",1=">",2="enter",3="hex",
					4="exit",5="scene",6="message",
					7="setting",8="joystick"]
				if ( part2c > 64 )
					s = "buttonon "
				else
					s = "buttonoff "
				if ( pnum in bname )
					b = bname[pnum]
				else
					b = string(pnum)
				cmd = s + b
				if (b == ">"||b == "<") {
					if (s == "buttonon" ) {
						if ( b == "<" )
							$.octave--
						else
							$.octave++
						print("OCTAVE=",$.octave)
					}
					cmd = ""
				}
			} else if ( part2a == 0x4b ) {
				cmd = "joystick "+string(pnum)+" "+string(part2c)
				mod = part2c - 64
				if ( mod < 0 )
					mod = 0
				mod *= 2
				if ( mod > 127 )
					mod = 127
				cmd = controller(1,0x01,mod)
			} else if ( part2a == 0x5f ) {
				# These are responses from setting things
			} else {
				print("Unrecognized control from korg: ",part2a," origm=",origm)
			}
		    } else {
			cmd = m
			cmd.pitch += ($.octave * 12)
# 			if ( m.type == NOTEON ) {
# 				cmd = "noteon "+string(m.chan)+" "+string(m.pitch)+" "+string(m.vol)
# 				cmd = m
# 			} else if ( m.type == NOTEOFF ) {
# 				cmd = "noteoff "+string(m.chan)+" "+string(m.pitch)+" "+string(m.vol)
# 			} else if ( m.type == CONTROLLER ) {
# 				ch = 1 + subbytes(m,1,1)&0x0f
# 				ct = 0+subbytes(m,2,1)
# 				cv = 0+subbytes(m,3,1)
# 				cmd = "controller "+string(ch)+" "+string(ct)+" "+string(cv)
# 			} else if ( m.type == PITCHBEND ) {
# 				cmd = ""	# it's a sysex in native mode
# 				# ch = 1 + subbytes(m,1,1)&0x0f
# 				# ct = 0+subbytes(m,2,1)
# 				# cv = 0+subbytes(m,3,1)
# 				# cmd = "pitchbend "+string(ch)+" "+string(ct)+" "+string(cv)
# 			}

		    }
		    if ( cmd != "" ) {
			if ( defined(Korgdebug) && Korgdebug != 0 )
				print("korgcontrol, notify=",$.notify," cmd=",cmd)
			for ( ff in $.notify ) {
				put(ff,cmd)
			}
		    }
		}
	}
}
