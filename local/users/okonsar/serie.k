#********************************************************************

#	SERIE 
#	by
#	Mehmet Okonsar
#	mokonsar@dominet.in.com.tr
#	Tool for reading and writing series of numbers. The primary usage
#	is that a mathematically generated serie of numbers can be read
#	and applied to any composant of the loaded phrase such as pitch
#	dur, time, vel. That makes possible and convenient to use mathematical
#	and spreadshet programs in music generating. 
#	USAGE:
#	"ORIG" -> read in a midi file or snarf, read a text file (*.txt)
#		this is an unformatted text file with one number per column.
#		For ex. the output as .txt of a spreadsheet program..
#		source for applying its attributes
#		Extract pitches, pitch intervals, durations etc .. to a 
#		text file as a column of numbers. This may serve for 
#		numerical analysis..
#	"SERIE" -> apply the loaded serie of numbers to any composant
#		Note: when "Apply to velocity -> As accentuation pattern"
#		is used, the loaded numbers give to number of notes to be 
#		accentuated..
#		Mix : is the mixing of the resulting and original phrases.
#		Restore : restores to the original phrase.

#*********************************************************************
class wserie {
method init {
	NVALUE=0 # number of values in the serie
	$.w = new window()
	$.inherit($.w)
	$.ph1 = new wphrase()
	$.ph2 = new wphrase()
	$.addchild($.ph1)
	$.addchild($.ph2)

	$.b1 = new kmenubutton("Orig","mkmenu_serie1",$)
	$.b2 = new kmenubutton("Serie","mkmenu_serie2",$)
	$.addchild($.b1)
	$.addchild($.b2)

	$.isset = 0
	$.stoptids = []
}
method redraw {
	$.w.redraw()
	methodbroadcast();
	$.w.text("Series",
		xy($.xmin(),$.ymin(),$.xmax(),$.ymin()+$.textheight()+4))
}
method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	dx = ($.xmax()-$.xmin()) / 6
	dy = ($.ymax()-$.ymin()) / 3
	y0 = $.ymin()+2
	y0a = $.ymin() + $.textheight() + 4
	y0b = ( y0a + $.ymax() ) / 2
	x0 = $.xmin() + 2
	x1 = $.xmax() - 2
	y1 = $.ymax() - 2
	$.b1.resize(xy(x0+1,y0a+2,x0+dx-1,y0b-2))
	$.b2.resize(xy(x0+1,y0b+2,x0+dx-1,y1))
	$.ph1.resize(xy(x0+dx+1,y0a+2,x1,y0b-2))
	$.ph2.resize(xy(x0+dx+1,y0b+2,x1,y1))
}
method delete {
	killtids($.stoptids)
	$.stoptids = []
}
method set (p,doredraw) {
	p = onlynotes(p)
	$.ph1.set(p,0)
	$.ph1.fitall()
	if ( nargs() > 1 && doredraw )
		$.ph1.redraw()
	$.isset = 0
}
method get {
	return($.ph2.get())
}

method dump {
	return ( [ "phrase" = $.ph1.get() ] )
}

method restore (state) { $.set(state["phrase"]) }

#********************************************************************
#		PLAYING
#********************************************************************

method play (stime) {
	if ( $.ph1.isplaying() || $.ph2.isplaying() )
		$.stop()
	if ( nargs() < 1 ) {
		stime = nextquant(Now,1b)
	}
	tid = $.ph2.play(stime,1b)
	$.stoptids[tid] = 1
}
method stop {
	killtids($.stoptids)
	$.stoptids = []
	$.ph1.stop()
	$.ph2.stop()
}
method mousedown (m) {
	if ( $.ph1.contains(m) ) {
		if ( $.ph1.isplaying() || $.ph2.isplaying() )
			$.stop()
		else {
			tid = $.ph1.play(nextquant(Now,1b))
			$.stoptids[tid] = 1
		}
	}
	else if ( $.ph2.contains(m) ) {
		if ( $.ph1.isplaying() || $.ph2.isplaying() )
			$.stop()
		else {
			tid = $.ph2.play(nextquant(Now,1b))
			$.stoptids[tid] = 1
		}
	}
	else {
		mouseforward(m,"mousedown")
	}
}

#********************************************************************
#		LOADING and SNARFING
#********************************************************************

method snarf { Snarf = $.ph2.get() }

method loadsnarf {
	if ( sizeof(Snarf) == 0 )
		print("Nothing int the Snarf ?!")
	else {
	$.stop()
	ORIGINALPHRASENOTES = 0
	ORIGINALPHRASE = onlynotes(Snarf)
	oph = ORIGINALPHRASE
	RESTOREPHRASE = ORIGINALPHRASE 
	$.set(ORIGINALPHRASE,1)
	for ( nt in oph ) 
		ORIGINALPHRASENOTES++
	print ("Number of Notes (in the Snarf): "+string(ORIGINALPHRASENOTES))
	}
}
method loadfile {
	$.stop()
	ORIGINALPHRASENOTES = 0
	ORIGINALPHRASE = onlynotes(browsephrase())
	oph = ORIGINALPHRASE
	RESTOREPHRASE = ORIGINALPHRASE 
	if ( sizeof(ORIGINALPHRASE) > 0 )
		$.set(ORIGINALPHRASE,1)
	for ( nt in oph ) 
		ORIGINALPHRASENOTES++
	print ("Number of Notes (in the file): "+string(ORIGINALPHRASENOTES))
}
method loadserie {
	VALUE=[]
	fname = browsefiles("Series (*.txt)","*.txt",1)
	if (fname > "") {
		f = open(fname) 
		for ( NVALUE=1; (VALUE[NVALUE]=get(f)) != Eof; NVALUE++ ) 
			print("(" + string(NVALUE) + ") = " + VALUE[NVALUE]) 
		close(f) 
	}
	else
		print("Reading cancelled")
}
method savetomidi {
	fname = browsefiles("Midi files (*.mid)","*.mid",1)
	if (sizeof(fname )>0){
		writemf(ORIGINALPHRASE ,fname )
		print ("Saved to : "+fname )
	}
	else
	print("Saving cancelled")
}
method restoreph {
	ORIGINALPHRASE = RESTOREPHRASE 
	$.ph2.set(ORIGINALPHRASE,0)
	$.ph2.fitall()
	$.ph2.redraw()
}

#*********************************************************************
#		APPLYING VALUES
#*********************************************************************

method AddIntPitches {
	j=1
	if ( NVALUE==0 ) {
		print ("No serie selected ! You need to do 'Orig -> Read Serie")
		return() }		
	for ( i=1; i<ORIGINALPHRASENOTES; i++ ) {
		ORIGINALPHRASE%i.pitch+=VALUE[j] 
		if (ORIGINALPHRASE%i.pitch < 0){
			print ("Note number "+i+" dropped below 0! Original pitch restitued")
			ORIGINALPHRASE%i.pitch+=abs(VALUE[j]) 
			}
		if (ORIGINALPHRASE%i.pitch > 127) {
			print ("Note number "+i+" raised above 127! Original pitch restitued")
			ORIGINALPHRASE%i.pitch-=VALUE[j] 
			}
		if (j<NVALUE-1)
			j+=1
		else
			j=1
	}
	$.ph2.set(ORIGINALPHRASE,0)
	$.ph2.fitall()
	$.ph2.redraw() 
}

method AbsolutePitches {
	j=1
	if ( NVALUE==0 ) {
		print ("No serie selected ! You need to do 'Orig -> Read Serie")
		return()
	}		
	for ( i=1; i<ORIGINALPHRASENOTES; i++ ) {
	if ((VALUE[j] >=0) && (VALUE[j] <=127))
		ORIGINALPHRASE%i.pitch=VALUE[j] 
	else
		print (string(VALUE[j])+" is outside pitch limits (0..127)! Original pitch kept")
	if (j<NVALUE-1)
		j+=1
	else
		j=1
	}
	$.ph2.set(ORIGINALPHRASE,0)
	$.ph2.fitall()
	$.ph2.redraw()
}

method AddIntDuration {
	j=1
	if ( NVALUE==0 ) {
		print ("No serie selected ! You need to do 'Orig -> Read Serie")
		return()
	}		
	for ( i=1; i<ORIGINALPHRASENOTES; i++ ) {
		ORIGINALPHRASE%i.dur+=VALUE[j] 
	if (ORIGINALPHRASE%i.dur < 0){
		print ("Note number "+string(i)+" dropped below 0 of duration! Original duration restitued")
		ORIGINALPHRASE%i.dur+=abs(VALUE[j]) 
		}
	if (j<NVALUE-1)
		j+=1
	else
		j=1
	}
	$.ph2.set(ORIGINALPHRASE,0)
	$.ph2.fitall()
	$.ph2.redraw()
}
method AbsoluteDuration {
	j=1
	if ( NVALUE==0 ) {
		print ("No serie selected ! You need to do 'Orig -> Read Serie")
		return()
	}		
	for ( i=1; i<ORIGINALPHRASENOTES; i++ ) { 
	if (VALUE[j] >=0)
		ORIGINALPHRASE%i.dur=VALUE[j] 
	else
		print (string(VALUE[j])+" is negative ! Original duration kept")
	if (j<NVALUE-1)
		j+=1
	else
		j=1
	}
	$.ph2.set(ORIGINALPHRASE,0)
	$.ph2.fitall()
	$.ph2.redraw()
}

method AddIntTime {
	j=1
	if ( NVALUE==0 ) {
		print ("No serie selected ! You need to do 'Orig -> Read Serie")
		return()
	}		
	for ( i=2; i<ORIGINALPHRASENOTES; i++ ) { 
		ORIGINALPHRASE%i.time+=VALUE[j] 
	if (ORIGINALPHRASE%i.time < 0){
		print ("Note number "+string(j)+" has negative time! Original time restitued")
		ORIGINALPHRASE%i.time+=abs(VALUE[j]) 
		}
	if (j<NVALUE-1)
		j+=1
	else
		j=1
	}
	$.ph2.set(ORIGINALPHRASE,0)
	$.ph2.fitall()
	$.ph2.redraw()
}

method AbsoluteTime {
	j=1
	if ( NVALUE==0 ) {
		print ("No serie selected ! You need to do 'Orig -> Read Serie")
		return()
	}		
	for ( i=1; i<ORIGINALPHRASENOTES; i++ ) {
	if (VALUE[j] >=0)
		ORIGINALPHRASE%i.time=VALUE[j] 
	else
		print (string(VALUE[j])+" is negative ! Original time kept")
	if (j<NVALUE-1)
		j+=1
	else
		j=1
	}
	$.ph2.set(ORIGINALPHRASE,0)
	$.ph2.fitall()
	$.ph2.redraw()
}
method Accentuation {
	if ( NVALUE==0 ) {
		print ("No serie selected ! You need to do 'Orig -> Read Serie")
		return()
	}		
	for ( i=1; i<NVALUE; i++ ) {
		p=VALUE[i]
		ORIGINALPHRASE%p.vol=127 
	}
	$.ph2.set(ORIGINALPHRASE,0)
	$.ph2.fitall()
	$.ph2.redraw()
}

method AddIntVelocity {
	j=1
	if ( NVALUE==0 ) {
		print ("No serie selected ! You need to do 'Orig -> Read Serie")
		return()
	}		
	for ( i=1; i<ORIGINALPHRASENOTES; i++ ) {
		ORIGINALPHRASE%i.vol+=VALUE[j] 
	if (ORIGINALPHRASE%i.vol < 0){
		print ("Note number "+string(i)+" dropped below 0! Original velocity restitued")
		ORIGINALPHRASE%i.vol+=abs(VALUE[j]) 
		}
	if (ORIGINALPHRASE%i.pitch > 127){
		print ("Note number "+string(i)+" raised above 127! Original velocity restitued")
		ORIGINALPHRASE%i.vol-=VALUE[j] 
		}
	if (j<NVALUE-1)
		j+=1
	else
		j=1
	}
	$.ph2.set(ORIGINALPHRASE,0)
	$.ph2.fitall()
	$.ph2.redraw()
}

method AbsoluteVelocities {
	j=1
	if ( NVALUE==0 ) {
		print ("No serie selected ! You need to do 'Orig -> Read Serie")
		return()
	}		
	for ( i=1; i<ORIGINALPHRASENOTES ; i++ ) {
	if ((VALUE[j] >=0) && (VALUE[j] <=127))
		ORIGINALPHRASE%i.vol=VALUE[j] 
	else
		print (VALUE[j]+" is outside velocity limits(0..127)! Original velocity kept")
		if (j<NVALUE-1)
			j+=1
		else
			j=1
	}
	$.ph2.set(ORIGINALPHRASE,0)
	$.ph2.fitall()
	$.ph2.redraw()
}

#*********************************************************************
#		EXTRACTING SERIES
#*********************************************************************

method extrp {
	fname = browsefiles("Series (*.txt)","*.txt",1)
	if (fname!="") {
		f=open(fname,"w")
		for ( nt in RESTOREPHRASE) 
		put(f,string(nt.pitch)+"\n")
		close(f)
	}
	else 
		print("Extract aborted")
}

method extrpi {
	fname = browsefiles("Series (*.txt)","*.txt",1)
	if (fname!="") {
		f=open(fname,"w")
		for (i=1;i<(ORIGINALPHRASENOTES-1);i++) {
			j=i+1
			ni=RESTOREPHRASE%j.pitch-RESTOREPHRASE%i.pitch
			put(f,string(ni)+"\n")
		}
		close(f)
	}
	else 
		print("Extract aborted")
}

method extrd {
	fname = browsefiles("Series (*.txt)","*.txt",1)
	if (fname!="") {
		f=open(fname,"w")
		for ( nt in RESTOREPHRASE) 
		put(f,string(nt.dur)+"\n")
		close(f)
	}
	else 
		print("Extract aborted")
}

method extrdi {
	fname = browsefiles("Series (*.txt)","*.txt",1)
	if (fname!="") {
		f=open(fname,"w")
		for (i=1;i<(ORIGINALPHRASENOTES-1);i++) {
			j=i+1
			ni=RESTOREPHRASE%j.dur-RESTOREPHRASE%i.dur
			put(f,string(ni)+"\n")
		}
		close(f)
	}
	else 
		print("Extract aborted")
}

method extrt {
	fname = browsefiles("Series (*.txt)","*.txt",1)
	if (fname!="") {
		f=open(fname,"w")
		for ( nt in RESTOREPHRASE) 
		put(f,string(nt.time)+"\n")
		close(f)
	}
	else 
		print("Extract aborted")
}

method extrti {
	fname = browsefiles("Series (*.txt)","*.txt",1)
	if (fname!="") {
		f=open(fname,"w")
		for (i=1;i<(ORIGINALPHRASENOTES-1);i++) {
			j=i+1
			ni=RESTOREPHRASE%j.time-RESTOREPHRASE%i.time
			put(f,string(ni)+"\n")
		}
		close(f)
	}
	else 
		print("Extract aborted")
}

method extrv {
	fname = browsefiles("Series (*.txt)","*.txt",1)
	if (fname!="") {
		f=open(fname,"w")
		for ( nt in RESTOREPHRASE) 
		put(f,string(nt.vol)+"\n")
		close(f)
	}
	else 
		print("Extract aborted")
}

method extrvi {
	fname = browsefiles("Series (*.txt)","*.txt",1)
	if (fname!="") {
		f=open(fname,"w")
		for (i=1;i<(ORIGINALPHRASENOTES-1);i++) {
			j=i+1
			ni=RESTOREPHRASE%j.vol-RESTOREPHRASE%i.vol
			put(f,string(ni)+"\n")
		}
		close(f)
	}
	else 
		print("Extract aborted")
}

method extrp2 {
	fname = browsefiles("Series (*.txt)","*.txt",1)
	if (fname!="") {
		f=open(fname,"w")
		for ( nt in ORIGINALPHRASE) 
		put(f,string(nt.pitch)+"\n")
		close(f)
	}
	else 
		print("Extract aborted")
}

method extrpi2 {
	fname = browsefiles("Series (*.txt)","*.txt",1)
	if (fname!="") {
		f=open(fname,"w")
		for (i=1;i<(ORIGINALPHRASENOTES-1);i++) {
			j=i+1
			ni=ORIGINALPHRASE%j.pitch-ORIGINALPHRASE%i.pitch
			put(f,string(ni)+"\n")
		}
		close(f)
	}
	else 
		print("Extract aborted")
}

method extrd2 {
	fname = browsefiles("Series (*.txt)","*.txt",1)
	if (fname!="") {
		f=open(fname,"w")
		for ( nt in ORIGINALPHRASE) 
		put(f,string(nt.dur)+"\n")
		close(f)
	}
	else 
		print("Extract aborted")
}

method extrdi2 {
	fname = browsefiles("Series (*.txt)","*.txt",1)
	if (fname!="") {
		f=open(fname,"w")
		for (i=1;i<(ORIGINALPHRASENOTES-1);i++) {
			j=i+1
			ni=ORIGINALPHRASE%j.dur-ORIGINALPHRASE%i.dur
			put(f,string(ni)+"\n")
		}
		close(f)
	}
	else 
		print("Extract aborted")
}

method extrt2 {
	fname = browsefiles("Series (*.txt)","*.txt",1)
	if (fname!="") {
		f=open(fname,"w")
		for ( nt in ORIGINALPHRASE) 
		put(f,string(nt.time)+"\n")
		close(f)
	}
	else 
		print("Extract aborted")
}

method extrti2 {
	fname = browsefiles("Series (*.txt)","*.txt",1)
	if (fname!="") {
		f=open(fname,"w")
		for (i=1;i<(ORIGINALPHRASENOTES-1);i++) {
			j=i+1
			ni=ORIGINALPHRASE%j.time-ORIGINALPHRASE%i.time
			put(f,string(ni)+"\n")
		}
		close(f)
	}
	else 
		print("Extract aborted")
}

method extrv2 {
	fname = browsefiles("Series (*.txt)","*.txt",1)
	if (fname!="") {
		f=open(fname,"w")
		for ( nt in ORIGINALPHRASE) 
		put(f,string(nt.vol)+"\n")
		close(f)
	}
	else 
		print("Extract aborted")
}

method extrvi2 {
	fname = browsefiles("Series (*.txt)","*.txt",1)
	if (fname!="") {
		f=open(fname,"w")
		for (i=1;i<(ORIGINALPHRASENOTES-1);i++) {
			j=i+1
			ni=ORIGINALPHRASE%j.vol-ORIGINALPHRASE%i.vol
			put(f,string(ni)+"\n")
		}
		close(f)
	}
	else 
		print("Extract aborted")
}

#*******************************************************************
#		CONCATENATE and MERGE REULT PHRASES

method conc1 { 
	ORIGINALPHRASE =ORIGINALPHRASE + RESTOREPHRASE 
	$.ph2.set(ORIGINALPHRASE ,0)
	$.ph2.fitall()
	$.ph2.redraw()
}	
	
method conc2 { 
	ORIGINALPHRASE =RESTOREPHRASE + ORIGINALPHRASE 
	$.ph2.set(ORIGINALPHRASE ,0)
	$.ph2.fitall()
	$.ph2.redraw()
}

method mrg  { 
	ORIGINALPHRASE =RESTOREPHRASE | ORIGINALPHRASE 
	$.ph2.set(ORIGINALPHRASE ,0)
	$.ph2.fitall()
	$.ph2.redraw()
}
}
#*******************************************************************
#		MENUS

function mkmenu_serie1(o,po) {
	o.submenu("Read Music  ->","mkmenu_serie_read",po)
	o.menucmd("Read Serie",po,"loadserie")
	o.submenu("Extract  ->","mkmenu_extract",po)
}

function mkmenu_serie_read(o,po) {
	o.menucmd("Midi File",po,"loadfile")
	o.menucmd("Snarf",po,"loadsnarf")
}

function mkmenu_extract(o,po) {
	o.submenu("Pitches ->","mkmenu_expitch",po)
	o.submenu("Durations ->","mkmenu_exdur",po)
	o.submenu("Timings ->","mkmenu_extime",po)
	o.submenu("Velocities->","mkmenu_exvel",po)
}

function mkmenu_extract2(o,po) {
	o.submenu("Pitches ->","mkmenu_expitch2",po)
	o.submenu("Durations ->","mkmenu_exdur2",po)
	o.submenu("Timings ->","mkmenu_extime2",po)
	o.submenu("Velocities->","mkmenu_exvel2",po)
}

function mkmenu_expitch(o,po) {
	o.menucmd("Pitches",po,"extrp")
	o.menucmd("Intervals",po,"extrpi")
}

function mkmenu_exdur(o,po) {
	o.menucmd("Durations",po,"extrd")
	o.menucmd("Intervals",po,"extrdi")
}

function mkmenu_extime(o,po) {
	o.menucmd("Timings",po,"extrt")
	o.menucmd("Intervals",po,"extrti")
}

function mkmenu_exvel(o,po) {
	o.menucmd("Velocities",po,"extrv")
	o.menucmd("Intervals",po,"extrvi")
}

function mkmenu_expitch2(o,po) {
	o.menucmd("Pitches",po,"extrp2")
	o.menucmd("Intervals",po,"extrpi2")
}

function mkmenu_exdur2(o,po) {
	o.menucmd("Durations",po,"extrd2")
	o.menucmd("Intervals",po,"extrdi2")
}

function mkmenu_extime2(o,po) {
	o.menucmd("Timings",po,"extrt2")
	o.menucmd("Intervals",po,"extrti2")
}

function mkmenu_exvel2(o,po) {
	o.menucmd("Velocities",po,"extrv2")
	o.menucmd("Intervals",po,"extrvi2")
}

function mkmenu_serie2(o,po) {
	o.submenu("Apply to Pitches ->","mkmenu_serie3",po)
	o.submenu("Apply to Durations ->","mkmenu_serie4",po)
	o.submenu("Apply to Timings ->","mkmenu_serie5",po)
	o.submenu("Apply to Velocities ->","mkmenu_mark6",po)
	o.submenu("Mix  ->","mkmenu_mix",po)
	o.menucmd("Restore",po,"restoreph")
	o.menucmd("Snarf",po,"snarf")
	o.menucmd("Write",po,"savetomidi")
	o.submenu("Extract  ->","mkmenu_extract2",po)
}

function mkmenu_mix(o,po) {
	o.menucmd("Modif + Orig",po,"conc1")
	o.menucmd("Orig + Modif",po,"conc2")
	o.menucmd("Merge",po,"mrg")
}

function mkmenu_serie3(o,po) {
	o.menucmd("Add/Soubstract Intervals",po,"AddIntPitches",n)
	o.menucmd("Absolute Pitches",po,"AbsolutePitches",n)
}

function mkmenu_serie4(o,po) {
	o.menucmd("Add/Soubstract Durations",po,"AddIntDuration",n)
	o.menucmd("Absolute Durations",po,"AbsoluteDuration",n)
}

function mkmenu_serie5(o,po) {
	o.menucmd("Add/Soubstract Timing",po,"AddIntTime",n)
	o.menucmd("Absolute Timing",po,"AbsoluteTime",n)
}

function mkmenu_mark6(o,po) {
	o.menucmd("Add/Soubstract Velocities",po,"AddIntVelocity",n)
	o.menucmd("Absolute Velocities",po,"AbsoluteVelocities",n)
	o.menucmd("As Accentuation Pattern",po,"Accentuation",n)
}
