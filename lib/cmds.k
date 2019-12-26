#define EDITINPLACE(p,expr) origt=p%(1).time;p.time-=origt;p.length=latest(p);p=expr;p.time+=origt

function cmd_inverti(p) {
	return(inverti(p))
}
function cmd_invertidir(p) {
	return(invertidir(p))
}
function cmd_crescendo(p) {
	return(crescendo(p,minvolume(p),maxvolume(p)))
}
function cmd_decrescendo(p) {
	return(crescendo(p,maxvolume(p),minvolume(p)))
}

function cmd_slowdown(p) {
	return(slowdown(p))
}
function cmd_leavechan(p,arg) {
	return(cut(p,CUT_CHANNEL,arg))
}
function cmd_removechan(p,arg) {
	p2 = cut(p,CUT_CHANNEL,arg)
	return(p-p2)
}

function cmd_leavetype(p,t) {
	if ( t == NOTE )
		return(p-nonnotes(p))
	else if ( t == MIDIBYTES )
		return(nonnotes(p))
	else if ( t == SUSTAIN )
		return(sustainnotes(p))
	else if ( t == VOLUMECONTROLLERS )
		return(volumenotes(p))
	else if ( t == EXPRESSION )
		return(expressionnotes(p))
	else if ( t == MODULATION )
		return(modulationnotes(p))
	else if ( t == PAN )
		return(pannotes(p))
	else if ( t == TOOLNOTES )
		return(toolnotes(p))
	else
		return(cut(p,CUT_TYPE,t))
}
function cmd_removetype(p,t) {
	if ( t == NOTE )
		return(nonnotes(p))
	else if ( t == MIDIBYTES )
		return(p-nonnotes(p))
	else if ( t == SUSTAIN )
		return(p-sustainnotes(p))
	else if ( t == VOLUMECONTROLLERS )
		return(p-volumenotes(p))
	else if ( t == EXPRESSION )
		return(p-expressionnotes(p))
	else if ( t == MODULATION )
		return(p-modulationnotes(p))
	else if ( t == PAN )
		return(p-pannotes(p))
	else if ( t == TOOLNOTES )
		return(p-toolnotes(p))
	else
		return(cut(p,CUT_NOTTYPE,t))
}

function cmd_leaveonbeat(p,tm) {
	return(p{isonbeat(??,tm)})
}
function cmd_removeonbeat(p,tm) {
	return(p{!isonbeat(??,tm)})
}

function cmd_leavenearbeat(p,tm1,tm2) {
	return(p{isnearbeat(??,tm1,tm2)})
}
function cmd_removenearbeat(p,tm1,tm2) {
	return(p{!isnearbeat(??,tm1,tm2)})
}

function cmd_leaverand(p,n) {
	return(p{rand(n)==0})
}
function cmd_removerand(p,n) {
	return(p{rand(n)})
}

function cmd_leaventh(p,n) {
	return(p{(??.number)%n==1})
}
function cmd_removenth(p,n) {
	return(p{(??.number)%n!=1})
}

function cmd_leavedur(p,dir,dur) {
	p = onlynotes(p)
	if ( dir > 0 )
		return( p{??.dur > dur} )
	else if ( dir < 0 )
		return( p{??.dur < dur} )
	else
		return( p{??.dur == dur} )
}

function cmd_removedur(p,dir,dur) {
	p = onlynotes(p)
	if ( dir > 0 )
		return( p - p{??.dur > dur} )
	else if ( dir < 0 )
		return( p - p{??.dur < dur} )
	else
		return( p - p{??.dur == dur} )
}

function cmd_leavevol(p,dir,vol) {
	p = onlynotes(p)
	vol = p.vol		# i.e. is the average
	if ( dir > 0 )
		return( p{??.vol > vol} )
	else if ( dir < 0 )
		return( p{??.vol < vol} )
	else
		return( p{??.vol == vol} )
}

function cmd_removevol(p,dir,vol) {
	p = onlynotes(p)
	vol = p.vol		# i.e. is the average
	if ( dir > 0 )
		return( p - p{??.vol > vol} )
	else if ( dir < 0 )
		return( p - p{??.vol < vol} )
	else
		return( p - p{??.vol == vol} )
}

function cmd_addroot(p,i) {
	origt=p%(1).time
	p.time-=origt
	p.length=latest(p)
	p=makerootevery(p,i)
	p.time+=origt
	return(p)
}
function cmd_arpeggio(p) {
	EDITINPLACE(p,arpeggio(p))
	return(p)
}
function cmd_legato(p) {
	EDITINPLACE(p,legato(p))
	return(p)
}
function cmd_transposeseq(p,rep) {
	seq = onlynotes(Snarf)
	if ( sizeof(seq) == 0 ) {
		error("The Snarf doesn't have any notes!?")
	}
	if ( rep ) {
		EDITINPLACE(p,transposeseqrepeat(p,seq))
	}
	else {
		EDITINPLACE(p,transposeseqinplace(p,seq))
	}
	return(p)
}
function cmd_transpose(p,a) {
	return(transpose(p,a))
}
function cmd_scalast(op,cmd,t) {
	if ( nargs() < 3 || t == 1 ) {
		p = onlynotes(lastbunch(Recorded,2b))
	} else {
		p = onlynotes(Snarf)
	}
	if ( sizeof(p) <= 0 ) {
		print("No notes in Recorded or Snarf!?")
		return(p)
	}
	p.time = 0
	p.dur = 0
	scale = ''
	for ( n in p ) {
		while ( n.pitch >= 12 )
			n.pitch -= 12
		scale |= n
	}
	scale = dedup(scale)
	if ( cmd == "cmd_scadjust" )
		op = scadjust(op,scale)
	else
		op = scafilt(op,scale)
	return(op)
}
function cmd_chordize(p,key,chtype) {
	p = chordmel(p,key,chtype)
	p.flags = 1
	return(p)
}
function cmd_scadjust(p,nt,scale) {
	return ( scadjust(p,transpose(scale,nt.pitch)) )
}
function cmd_scafilt(p,nt,scale) {
	return ( scafilt(p,transpose(scale,nt.pitch)) )
}
function cmd_mono(p,t) {
	return(mono(p,t))
}
function cmd_null(p) {
	return('')
}
function cmd_applynear(p,type) {
	p = applynear(p,Snarf,type)
	return(p)
}
function cmd_applyseq(p,type) {
	p = apply(p,strip(Snarf),type,1)
	return(p)
}
function cmd_average(p,arg) {
	if ( arg == "Time" )
		p.time = p.time
	else if ( arg == "Duration" )
		p.dur = p.dur
	else if ( arg == "Volume" )
		p.vol = p.vol
	else if ( arg == "Pitch" )
		p.pitch = p.pitch
	return(p)
}
function cmd_dedup(ph) {
	return(dedup(ph))
}
function cmd_debank(ph) {
	return(debank(ph))
}
function cmd_dedupdur(ph) {
	return(dedupdur(ph))
}
function cmd_echo(ph,num,rtime,rfactor) {
	if ( nargs() < 3 )
		rtime = 1b
	if ( nargs() < 4 )
		rfactor = 0.90
	return(echo(ph,num,rtime,rfactor)) 
}
function cmd_preecho(...) {
	return(preecho(...)) 
}
function cmd_spread(ph,num,rtime,rfactor) {
	if ( nargs() < 3 )
		rtime = 1b
	if ( nargs() < 4 )
		rfactor = 0.70
	return(spread(ph,num,rtime,rfactor)) 
}
function cmd_bs(p,maj) {
	if ( sizeof(Snarf) <= 0 )
		error("You have to put something in the Snarf!")
	bskey = 'e-'
	bsmajor = []
	bsmajor[ 1 ]= 'e-o-2'
	bsmajor[ 2 ]= 'e-o-2,f,g,b-'
	bsmajor[ 3 ]= 'e-o-2,b-'
	bsmajor[ 4 ]= 'e-o-2,b-'
	bsmajor[ 5 ]= 'e-o-2,f,g,b-'
	bsmajor[ 6 ]= 'e-o-2,b-'
	bsmajor[ 7 ]= 'e-o-2,f,g,b-'
	bsmajor[ 8 ]= 'e-o-2,b-'
	bsminor = []
	bsminor[ 1 ]= 'e-o-2'
	bsminor[ 2 ]= 'e-o-2,f,g-,b-'
	bsminor[ 3 ]= 'e-o-2,b-'
	bsminor[ 4 ]= 'e-o-2,b-'
	bsminor[ 5 ]= 'e-o-2,f,g-,b-'
	bsminor[ 6 ]= 'e-o-2,b-'
	bsminor[ 7 ]= 'e-o-2,f,g-,b-'
	bsminor[ 8 ]= 'e-o-2,b-'
	if ( maj )
		bs = bsmajor
	else
		bs = bsminor
	# The Snarf gets used as the keyguide, and p gets used as the noteguide
	s = onlynotes(Snarf)
	p = onlynotes(p)
	s1t = s%1.time
	p.time -= s1t
	s.time -= s1t
	p.length = latest(p)
	s.length = latest(s)
	p = bsguide(bs,bskey,s,p,1b/4,s.length)
	p.time += s1t
	return(p)
}
function cmd_permute(p) {
	plimit = 6
	if ( sizeof(p) > plimit ) {
		print("Too many notes (more than ",plimit,") to do permutations,\nchange plimit in lib/cmds.k if you really want to do it.")
		return(p)
	}
	arr = permutations(p)
	r = ''
	for ( n=0; n in arr; n++ ) {
		r += arr[n]
	}
	return(r)
}
function cmd_expandvol(p,f) {
	return(expandvol(p,f))
}
function cmd_evolve(p,n) {
	if ( n <= 0 )
		return(evolve(p,Snarf))
	else
		return(evolve(p,Snarf,n))
}
function cmd_autopan(p,v1,v2) {
	return(autopan(p,v1,v2))
}
function cmd_flip(p) {
	return(flip(p))
}
function cmd_tonerow(p) {
	return(tonerow(p))
}
function cmd_replace(p,...) {
	n = argv(1)
	tm1 = p%1.time
	origdur = p.dur
	if ( n == 0 )
		p = Snarf
	if ( n == 1 )
		p = lastnotechord(Recorded)
	if ( n == 2 )
		p = lastbunch(Recorded,2b)
	if ( n == 3 ) {
		p = lastnotechord(Recorded)
		p.dur = origdur
	}
	if ( n == 4 ) {
		lst = lastnotechord(Recorded)
		for ( i=1; i<=sizeof(p); i++ ) {
			t = p%i.type
			if ( t==NOTE || t==NOTEON || t==NOTEOFF ) {
				nt = p%i
				p -= nt
				lst.time = nt.time
				p |= lst
			}
		}
	}
	p = strip(p)
	p.time += tm1
	p.flags = 1
	return(p)
}
function cmd_thin(p,...) {
	return(thinit(p,...))
}
function cmd_thincontrol(p,...) {
	return(thincontrol(p,...))
}
function cmd_fractal(p) {
	return(fractal(p))
}
function cmd_shuffle(p) {
	return(shuffle(p))
}
function cmd_eventime(p) {
	EDITINPLACE(p,eventime(p))
	return(p)
}
function cmd_quantize(p,arg) {
	return(quantize(p,arg))
}
function cmd_quantizefirst(p,arg) {
	return(quantizefirst(p,arg))
}
function cmd_quantizedur(p,arg) {
	return(quantizedur(p,arg))
}
function cmd_setduration(p,arg) {
	p.dur = arg
	return(p)
}
function cmd_step(p,arg) {
	EDITINPLACE(p,step(p,arg))
	return(p)
}
function cmd_timescale(p,arg) {
	EDITINPLACE(p,scatimes(p,arg))
	return(p)
}
function cmd_durscale(p,arg) {
	EDITINPLACE(p,scadur(p,arg))
	return(p)
}
function cmd_volscale(p,arg) {
	EDITINPLACE(p,scavol(p,arg))
	return(p)
}
function cmd_stutter(p,wid,num) {
	EDITINPLACE(p,stutter(p,wid,num))
	return(p)
}
function cmd_stutterrand(p) {
	EDITINPLACE(p,stutterrand(p))
	return(p)
}
function cmd_repeat(p,arg) {
	EDITINPLACE(p,repeat(p,arg))
	return(p)
}
function cmd_repeatquant(p,n,q) {
	EDITINPLACE(p,repeat(p,n,q))
	return(p)
}
# function cmd_copy(p,arg) {
# 	EDITINPLACE(p,p|p)
# 	return(p)
# }
function cmd_setchan(p,arg) {
	p.chan = arg
	return(p)
}
function cmd_adjvol(p,inc) {
	p.vol += inc
	return(p)
}
function cmd_swapnotes(p) {
	return(swapnote(p))
}
function cmd_shift(p,arg) {
	p.time += arg
	return(p)
}
function cmd_reverse(p,arg) {
	if ( arg == "Time" ) {
		EDITINPLACE(p,reverse(p))
	}
	else {
		EDITINPLACE(p,revpitch(p))
	}
	return(p)
}
function cmd_fade(ph,num,dir) {

	# just use the min/max time of the Pick
	origt = ph%(1).time
	origleng = latest(ph) - origt

	ph.length = origleng
	ph.time -= origt
	ph = repfade(ph,num,dir)
	if ( dir>0 )	# fade in
		ph.time += (origt - (num-1)*origleng)
	else
		ph.time += origt
	return(ph)
}

function cmd_noise(ph,ntype,att,amnt) {
	ph = noise(ph,ntype,amnt,att)
	return(ph)
}

function cmd_ornament(ph,t) {
	if ( t == 0 )
		orn = lastbunch(Recorded,2b)
	else
		orn = Snarf
	orn = strip(orn)
	if ( t == 2 )
		doscaleng = 1
	else
		doscaleng = 0
	return(ornament(ph,orn,doscaleng))
}

