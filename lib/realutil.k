function realmidi(p,stime) {
	if ( nargs() < 2 )
		stime = Now
	tid = task realmiditask(p,stime)
	return(tid)
}
function realmiditask(p,stime) {
	tid1 = realtime(p,stime)
	tid2 = task noticecontrollers(p,stime)
	tid3 = task noticeprogram(p,stime)
	onexit(global(killtids),tid1,tid2,tid3)
	wait(tid1)
}
function realslow(p) {
	for ( n in p ) {
		if ( n.type == MIDIBYTES || n.type == SYSEX ) {
			bn = 1
			while ( (a=subbytes(n,bn,1)) != '' ) {
				realtime(a)
				millisleep(10)
				bn++
			}
		}
		else {
			realtime(n)
		}
	}
}

function noticecontrollers(p,stime) {
	if ( Nonotice )
		return()
	pc = cut(p,CUT_TYPE,CONTROLLER)
	pc.time += stime
	for ( n in pc ) {
		t = n.time
		if ( t > Now )
			sleeptill(t)
		ch = 1+(subbytes(n,1,1)&0xf)
		cn = integer(subbytes(n,2,1))
		cv = integer(subbytes(n,3,1))

		# spawn a task, so broadcastcontrol can increase its priority,
		# so it won't get killed mid-broadcast
		task broadcastcontrol(ch,cn,cv)
	}
}

function noticeprogram(p,stime) {
	if ( Nonotice )
		return()
   if (ACPATCHES == 0)                  # Hack by Stef for GeoMaestro
   {
	pc = cut(p,CUT_TYPE,PROGRAM)
	pc.time += stime
	for ( n in pc ) {
		t = n.time
		if ( t > Now )
			sleeptill(t)
		ch = 1+(subbytes(n,1,1)&0xf)
		pn = 1+subbytes(n,2,1)
		# spawn a task, so broadcastprogram can increase its priority,
		# so it won't get killed mid-broadcast
		task broadcastprogram(ch,pn)
	}
   }
}

function realexpr(p,stime) {
	tid = task realexprtask(p,stime)
	return(tid)
}
function realexprtask(p,stime) {
	if ( nargs() < 2 )
		stime = Now
	p = cut(p,CUT_TYPE,SYSEXTEXT)
	if ( sizeof(p) == 0 )
		return()
	tm = stime
	for ( nt in p ) {
		s = string(nt)
		if ( substr(s,3,1) != "{" )
			continue
		lng = sizeof(s)
		ex = substr(s,4,lng-6)
		tm = nt.time + stime
		task waitneval(tm,ex)
	}
	sleeptill(tm)	# We stick around, so that if someone
			# kills us, we kill all our child tasks
}

function tick(t,nt) {
	if ( nargs() < 1 )
		t = 4b
	print("TICK start")
	nt = Now + t
	for ( ;; ) {
		sleeptill(nt)
		print("TICK ",nt/1b)
		nt += t
	}
	print("TICK end")
}

function testgenerateclock() {
	print("Clocks are being generated - press any console key to quit")
	t = task generateclock()
	Root.waitforconsolekey()
	kill(t)
	print("Done.")
}

function generateclock() {
	t = Now
	for ( ;; ) {
		t += 4
		realtime('xf8',t)
		sleeptill(t)
	}
}

#name	getsysexdump
#usage	getsysexdump(sx)
#desc	Get a sysex dump.  The sx argument is the sysex message
#desc	that will be output, presumably causing the device to respond
#desc	with a dump.

SysexDump = ''

#name	getsysexdump
#usage	getsysexdump(sendmessage,tmout)
#desc	This function retrieves a sysex dump from an attached MIDI device.
#desc	The 'sendmessage' argument is expected to be a sysex message that,
#desc	when sent to the device, will cause it to send back a sysex dump
#desc	(or any sysex message, really).  For example, for a TX81Z, the
#desc	value of 'xf0432004f7' will cause it to send back a sysex dump
#desc	containing all patches.  The 'tmout' parameter is a timeout value
#desc	in milliseconds - if this time elapses without receiving any output
#desc	from MIDI input, the function will abort and return an empty phrase.

function getsysexdump(sx,tmout) {
	
	if ( nargs() < 2 )
		tmout = 20000;	# default is 20 seconds

	# We don't want to echo the dump back to the synth, in case we're
	#  connected in a loop, so we turn off Merge temporarily (if it's on)
	origMerge = Merge
	Merge = 0

	SysexDump = ''

	# For some reason, the MIDI input doesn't get flushed all the way
	# to the fifo we're reading here, unless there's another task running,
	# or some other event (like mouse movement) occurs.
	# Something's amiss here, this is just a workaround.
	sleep_tid = task loophack()

	# By adding an entry to Midiin, we can read a copy of all MIDI input.
	# See loops.k (specifically midiloop()) for the code that manages this.
	id = gettid()
	Midiin[id] = f = open();

	# spawn a task that reads from MIDI input until the dump is received
	collect_tid = task collectsysexdump(f)

	sx.time = 0	# just to make sure it gets put out right away
	realtime(sx)

	# spawn a task that waits for the timeout, and kills the
	# collectsysexdump task if the timeout elapses.
	killer_tid = task waitncall(Now+milliclicks(tmout),kill,collect_tid)

	# wait for things collection task to finish (or be killed)
	wait(collect_tid)

	# print("length of SysexDump=",sizeof(string(SysexDump))-2);

	# clean up
	delete Midiin[id]
	close(f)
	kill(sleep_tid)
	kill(killer_tid)
	Merge = origMerge

	return(SysexDump)
}

function loophack() {
	while (1) {
		millisleep(100);
	}
}

function collectsysexdump(f) {
	# This blocks, waiting for MIDI input to be provided on fifo f.
	while ( (m=get(f)) != Eof ) {
		if ( m.type == SYSEX || m.type == MIDIBYTES ) {
			SysexDump = m;
			return();
		}
	}
}

function txpatches() {
	return(getsysexdump('xf0432004f7'))
}
function txperfs() {
	return(getsysexdump('xf043207e4c4d202038393736504df7'))
}

function getanote() {
	
	origMerge = Merge
	Merge = 0

	id = gettid()
	Midiin[id] = f = open();

	while ( (m=get(f)) != Eof ) {
		if ( m.type == NOTEOFF )
			break
	}
	delete Midiin[id]
	close(f)
	Merge = origMerge
	return(m)
}

function task_loop(p,tm) {
	st = Now
	while ( 1 ) {
		t1 = realtime(p,st)
		onexit(global(killtids),t1)
		st += tm
		sleeptill(st-4)
	}
}

function mergeonly(ch) {
	oldmergefilter = Mergefilter
	Mergefilter = 0
	for ( c=1; c<=16; c++ ) {
		Mergefilter |= 1<<(c-1)
	}
	return(oldmergefilter)
}

function recfilteron(ch) {
	oldrecfilter = Recfilter
	Recfilter = 1<<(ch-1)
	return(oldrecfilter)
}

function task_monitor() {
	f = open()
	Monitorfifo = f
	while ( (p=get(f)) != Eof ) {
		print("monitor p=",p)
	}
}
function test_monitor() {
	task task_monitor()
}

function virusreq1(dd,bb,ss) {
	
	if ( nargs() < 3 ) {
		print("usage: virusreq1(deviceid,bank,program)")
		return('')
	}
	tmout = 20000;	# default is 20 seconds

	# We don't want to echo the dump back to the synth, in case we're
	#  connected in a loop, so we turn off Merge temporarily (if it's on)
	origMerge = Merge
	Merge = 0

	SysexDump = ''

	# For some reason, the MIDI input doesn't get flushed all the way
	# to the fifo we're reading here, unless there's another task running,
	# or some other event (like mouse movement) occurs.
	# Something's amiss here, this is just a workaround.
	sleep_tid = task loophack()

	# By adding an entry to Midiin, we can read a copy of all MIDI input.
	# See loops.k (specifically midiloop()) for the code that manages this.
	id = gettid()
	Midiin[id] = f = open();

	# spawn a task that reads from MIDI input until the dump is received
	collect_tid = task collectsysexdump(f)

	req = midibytes(0xf0,0x00,0x20,0x33,0x01,dd,0x30,bb,ss,0xf7)
	req.time = 0	# just to make sure it gets put out right away
	print("req=",req)
	realtime(req)

	# spawn a task that waits for the timeout, and kills the
	# collectsysexdump task if the timeout elapses.
	killer_tid = task waitncall(Now+milliclicks(tmout),kill,collect_tid)

	# wait for things collection task to finish (or be killed)
	wait(collect_tid)

	# print("length of SysexDump=",sizeof(string(SysexDump))-2);

	# clean up
	delete Midiin[id]
	close(f)
	kill(sleep_tid)
	kill(killer_tid)
	Merge = origMerge

	return(SysexDump)
}
function virustest(dd,bb,ss) {
	for ( n=1; n<10; n++ ) {
		p = virusreq1(0,1,n)
		c = subbytes(p,9,1)
		print("c=",c)
		millisleep(1000)
	}
}
function waitforstart(o,sq) {
	print("Waiting for Midi Start or Midi Continue")
	if ( Sync == 0 ) {
		print("Hey - Sync is 0 !?  I'm forcing it to 1.")
		Sync = 1
	}
	Midiin[o] = f = open();
	while ( (n=get(f)) != Eof ) {
		t = n.time
		n.time = 0
		n.port = 0
		if ( n == 'xfa' || n == 'xfb' ) {
			starttm = t
			break
		}
	}
	closemidi(o)
	# The startquant is -100 - offset
	# and we want to add the offset to the starttm
	starttm -= (sq+100)
	return(starttm)
}
function synctostart(qnt) {
	print("Waiting for Midi Start or Midi Continue")
	if ( Sync == 0 ) {
		print("Hey - Sync is 0 !?  I'm forcing it to 1.")
		Sync = 1
	}
	o = 99
	Midiin[o] = f = open();
	while ( (n=get(f)) != Eof ) {
		t = n.time
		n.time = 0
		n.port = 0
		if ( n == 'xfa' || n == 'xfb' ) {
			nw = nextquant(Now,qnt)
			Nowoffset = nw - Now
			print("Nowoffset = ",Nowoffset)
			break
		}
	}
	closemidi(o)
}
