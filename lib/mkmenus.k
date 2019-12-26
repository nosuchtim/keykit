function addrecorded(o,space) {
	o.addtrackandshow(lastbunch(Recorded,space))
}
function zoomoutandredraw(o) {
	o.viewoutx()
	o.redraw()
}
function mkmenu_group1(o,po) {
	o.submenu("Read      ->","mkmenu_read",po)
	o.submenu("Write     ->","mkmenu_write",po)
	o.submenu("Misc      ->","mkmenu_trkmisc",po)
	o.submenu("Add Track ->","mkmenu_newtrack",po)
}
function mkmenu_newtrack(o,po) {
	o.menucmd("Blank",		po,"addtrackandshow","blank")
	o.menucmd("Last Overdub",	po,"addtrackandshow","overdub")
	o.menucmd("From Pick",		po,"addtrackandshow","pick")
	o.menucmd("From Snarf",		po,"addtrackandshow","snarf")

	# o.menucmd("From Pick",primemsg(msg("addpick","redraw","yes")))
}
function mkmenu_trkmisc(o,po) {
	o.menucmd("Split On Channels",po,"chansplit")
	o.menucmd("Append Tracks from another Group",po,"appendgroup")
	o.menucmd("Merge Tracks from another Group",po,"mergegroup")
}
function mkmenu_write(o,po) {
	o.menucmd("Standard MIDI File",po,"writesmf")
	o.menucmd("MIDI File w/Tempo Track",po,"writesmf",1)
}
function mkmenu_read(o,po) {
	o.menucmd("Standard MIDI File",po,"readfile",1)
	o.menucmd("Key File",po,"readfile",0)
	o.menucmd("Snarf",po,"readsnarf")
	o.menucmd("Recorded(2b space)",po,"readrecorded",2b)
	o.menucmd("Recorded(8b space)",po,"readrecorded",8b)
	o.menucmd("Last Console phrase",po,"readconph")
}
function mkmenu_show(o,po) {
	o.menucmd("All",po,"showall")
	o.menucmd("Active",po,"showactive")
	o.menucmd("Picked", po,"showpicked")
	o.submenu("Named ->", "mkmenu_trknamed",po)
}
function mkmenu_trknamed(o,po) {
	list = po.tracklabels()
	nt = sizeof(list)
	for ( n=0; n<nt; n++ )
		o.menucmd(list[n],po,"dispmore",n,1)
}
function mkmenu_tempo(o) {
	o.menucmd("New Tempo","sweeptool","wtempo")
}
function mkmenu_echo(o) {
	o.menucmd("New Echo","sweeptool","wecho")
}
function mkmenu_console(o) {
	o.menucmd("New Console","sweeptool","wconsole")
}
function mkmenu_debug(o) {
	o.menucmd("One",global(nullfunc));
	o.menucmd("Two",global(nullfunc));
}
function mkmenu_misc(o) {
	o.menucmd("Documentation","mainhelp")
	o.menucmd("AllNotesOff","alloff")
	o.menucmd("GM Reset","realgmreset")
	o.menucmd("Redraw",Root,"redraw")
	o.menucmd("Reread Library","rereadlib")
	# o.menucmd("Restart","restartconfig")
	o.menucmd("Send File","readandsend")
	o.menucmd("Stop All","alloff")
	o.menucmd("Toggle Met","togglemet")
	o.menucmd("Reset Console","rootreleaseconsole")
	o.submenu("Mouse     ->","mkmenu_mouse")
	# o.submenu("Demo      ->","mkmenu_demo")
}
function readandsend() {
	a = browsesyx()
	if ( sizeof(a) != 0 ) {
		registop(realmidi(a))
	}
}
function printit(p) {
	if ( sizeof(p) > 0 )
		print("p=",p)
}
function mkmenu_evolve(o,po) {
	for ( n=1; n<=8; n++ ) {
		o.menucmd(string(n)+" times",po,"edit","cmd_evolve",n)
	}
	o.menucmd("1 note per time",po,"edit","cmd_evolve",0)
}
function mkmenu_expand(o,po) {
	o.submenu("Vol   ->","mkmenu_expand2",po,"vol")
	o.menucmd("Autopan pitch 0-127 = L->R",po,"edit","cmd_autopan",0,127)
	o.menucmd("Autopan pitch 127-0 = R->L",po,"edit","cmd_autopan",127,0)
	o.menucmd("Autopan min->max = L->R",po,"edit","cmd_autopan",-1,-2)
	o.menucmd("Autopan max->min = R->L",po,"edit","cmd_autopan",-2,-1)
}
function mkmenu_expand2(o,po) {
	o.menucmd("0.2 X",po,"edit","cmd_expandvol",0.2)
	o.menucmd("0.4 X",po,"edit","cmd_expandvol",0.4)
	o.menucmd("0.6 X",po,"edit","cmd_expandvol",0.6)
	o.menucmd("0.8 X",po,"edit","cmd_expandvol",0.8)
	o.menucmd("1.1 X",po,"edit","cmd_expandvol",1.1)
	o.menucmd("1.2 X",po,"edit","cmd_expandvol",1.2)
	o.menucmd("1.4 X",po,"edit","cmd_expandvol",1.4)
	o.menucmd("1.6 X",po,"edit","cmd_expandvol",1.6)
	o.menucmd("2 X",po,"edit","cmd_expandvol",2.0)
}
function mkmenu_echoedit(o,po) {
	for ( n=1; n<=8; n++ )
		o.submenu(string(n)+" times ->","mkmenu_echovals",po,n,"cmd_echo")
	n=16
	o.submenu(string(n)+" times ->","mkmenu_echovals",po,n,"cmd_echo")
	n=32
	o.submenu(string(n)+" times ->","mkmenu_echovals",po,n,"cmd_echo")
}
function mkmenu_spreadedit(o,po) {
	for ( n=1; n<=8; n++ )
		o.submenu(string(n)+" times ->","mkmenu_echovals",po,n,"cmd_spread")
}
function mkmenu_preecho(o,po) {
	for ( n=1; n<=8; n++ )
		o.submenu(string(n)+" times ->","mkmenu_echovals",po,n,"cmd_preecho")
}
function mkmenu_dedup(o,po) {
	o.menucmd("Ignore duration",po,"edit","cmd_dedup")
	o.menucmd("Include duration",po,"edit","cmd_dedupdur")
}
function mkmenu_chordize(o,po) {
	o.submenu("C  ->","mkmenu_chordize2",po,'c')
	o.submenu("C# ->","mkmenu_chordize2",po,'c+')
	o.submenu("D  ->","mkmenu_chordize2",po,'d')
	o.submenu("D# ->","mkmenu_chordize2",po,'d')
	o.submenu("E  ->","mkmenu_chordize2",po,'e')
	o.submenu("F  ->","mkmenu_chordize2",po,'f')
	o.submenu("F# ->","mkmenu_chordize2",po,'f+')
	o.submenu("G  ->","mkmenu_chordize2",po,'g')
	o.submenu("G# ->","mkmenu_chordize2",po,'g+')
	o.submenu("A  ->","mkmenu_chordize2",po,'a')
	o.submenu("A# ->","mkmenu_chordize2",po,'a+')
	o.submenu("B  ->","mkmenu_chordize2",po,'b')
}
function mkmenu_chordize2(o,po,nt) {
	o.menucmd("Sus",po,"edit","cmd_chordize",nt,"sus")
	o.menucmd("Min7",po,"edit","cmd_chordize",nt,"min7")
}
function mkmenu_edit(o,po) {
	o.submenu("Apply    ->","mkmenu_apply",po)
	o.menucmd("Arpeggio", po,"edit","cmd_arpeggio")
	o.submenu("Average  ->","mkmenu_average",po)
	o.submenu("BeatStep ->","mkmenu_bs",po)
	o.menucmd("Copy",po,"copy")
	o.submenu("Chordize ->","mkmenu_chordize",po)
	o.menucmd("Debank",po,"edit","cmd_debank")
	o.submenu("Dedup    ->","mkmenu_dedup",po)
	o.menucmd("Delete",po,"edit","cmd_null")
	o.submenu("Echo     ->","mkmenu_echoedit",po)
	o.menucmd("Eventime",po,"edit","cmd_eventime")
	o.submenu("Evolve   ->","mkmenu_evolve",po)
	o.submenu("Expand   ->","mkmenu_expand",po)
	o.submenu("Fade     ->","mkmenu_fade",po)
	o.menucmd("Flip",po,"edit","cmd_flip")
	o.menucmd("Fractal",po,"edit","cmd_fractal")
	o.submenu("Gradual  ->","mkmenu_gradual",po)
	o.submenu("Info     ->","mkmenu_info",po)
	o.submenu("Interval ->","mkmenu_invertii",po) 
	o.menucmd("Legato", po,"edit","cmd_legato")
	o.submenu("Mono     ->","mkmenu_mono",po)
	o.submenu("Ornament ->","mkmenu_ornament",po)
	o.menucmd("Permutate",po,"edit","cmd_permute")
	o.submenu("Pre Echo ->","mkmenu_preecho",po)
	o.menucmd("Print",po,"onpicked","printit")
	o.submenu("Quantize ->","mkmenu_quantize",po)
	o.submenu("Randomize->","mkmenu_noise",po)
	o.submenu("Repeat   ->","mkmenu_repeat",po)
	o.submenu("Replace  ->","mkmenu_replace",po)
	o.submenu("Reverse  ->","mkmenu_reverse",po)
	o.submenu("Root     ->","mkmenu_addroot",po)
	o.submenu("Scadjust ->","mkmenu_sca",po,"cmd_scadjust")
	o.submenu("Scafilt  ->","mkmenu_sca",po,"cmd_scafilt")
	o.submenu("Scale    ->","mkmenu_scale",po)
	o.submenu("Set      ->","mkmenu_set",po)
	o.submenu("Shift    ->","mkmenu_shift",po)
	o.menucmd("Shuffle", po,"edit","cmd_shuffle")
	o.menucmd("Slowdown", po,"edit","cmd_slowdown")
	o.submenu("Spread   ->","mkmenu_spreadedit",po)
	# o.menucmd("Snarf",po,"snarfpick")
	# o.submenu("Timescale->","mkmenu_timescale",po)
	o.submenu("Step     ->","mkmenu_timevals",po,"cmd_step")
	o.submenu("Stutter  ->","mkmenu_stutter",po)
	o.menucmd("Swapnotes",po,"edit","cmd_swapnotes")
	o.submenu("Thin     ->","mkmenu_timevals2",po,"cmd_thin")
	o.menucmd("ToneRow",po,"edit","cmd_tonerow")
	o.submenu("Thin Ctlr->","mkmenu_timevals2",po,"cmd_thincontrol")
	# o.submenu("Tool     ->","mkmenu_settool",po)
	o.submenu("Transpose->","mkmenu_transpose",po)
	o.menucmd("Undo", po,"undo")
}
function mkmenu_invertii(o,po) {
	o.menucmd("Invert - Complementary",po,"edit","cmd_inverti")
	o.menucmd("Invert - Direction only",po,"edit","cmd_invertidir")
}
function mkmenu_ornament(o,po) {
	o.menucmd("From Recorded",po,"edit","cmd_ornament",0)
	o.menucmd("From Snarf",po,"edit","cmd_ornament",1)
	o.menucmd("From Snarf (scaled)",po,"edit","cmd_ornament",2)
}
function mkmenu_noise(o,po) {
	o.submenu("White    ->","mkmenu_noise2",po,0)
	o.submenu("1/F      ->","mkmenu_noise2",po,1)
	o.submenu("Brownian ->","mkmenu_noise2",po,2)
}
function mkmenu_noise2(o,po,t) {
	o.submenu("Pitch  ->","mkmenu_noise3",po,t,PITCH)
	o.submenu("Octave ->","mkmenu_noise3",po,t,OCTAVE)
	o.submenu("Vol    ->","mkmenu_noise3",po,t,VOLUME)
	o.submenu("Dur    ->","mkmenu_noise3",po,t,DURATION)
	o.submenu("Chan   ->","mkmenu_noise3",po,t,CHANNEL)
	o.submenu("Time   ->","mkmenu_noise4",po,t,TIME)
}
function mkmenu_noise3(o,po,ntype,type) {
	lim = 10
	if ( type == OCTAVE )
		lim = 5
	for ( n=1; n<=lim; n++ )
		o.menucmd(string(n),po,"edit","cmd_noise",ntype,type,n)
}
function mkmenu_noise4(o,po,ntype,type) {
	o.menucmd("Whole",po,"edit","cmd_noise",ntype,type,4b)
	o.menucmd("Half",po,"edit","cmd_noise",ntype,type,2b)
	o.menucmd("Quarter",po,"edit","cmd_noise",ntype,type,1b)
	o.menucmd("Eighth",po,"edit","cmd_noise",ntype,type,1b/2)
	o.menucmd("Sixteenth",po,"edit","cmd_noise",ntype,type,1b/4)
	o.menucmd("Thirtysecond",po,"edit","cmd_noise",ntype,type,1b/8)
	o.menucmd("Sixtyfourth",po,"edit","cmd_noise",ntype,type,1b/16)
	o.menucmd("1 click",po,"edit","cmd_noise",ntype,type,1)
}
function mkmenu_fade(o,po) {
	o.submenu("In  ->","mkmenu_faden",po,1)
	o.submenu("Out ->","mkmenu_faden",po,-1)
}
function mkmenu_faden(o,po,dir) {
	for ( n=1; n<=16; n++ )
		o.menucmd(string(n),po,"edit","cmd_fade",n,dir)
}
function mkmenu_mono(o,po) {
	o.menucmd("Highest",po,"edit","cmd_mono",0)
	o.menucmd("Lowest",po,"edit","cmd_mono",1)
	o.menucmd("Random",po,"edit","cmd_mono",2)
}
function mkmenu_transpose(o,po) {
	o.submenu("Up   ->","mkmenu_transposeit",po,1)
	o.submenu("Down ->","mkmenu_transposeit",po,-1)
	o.menucmd("Seq by Snarf (in place)",po,"edit","cmd_transposeseq",0)
	o.menucmd("Seq by Snarf (repeat)",po,"edit","cmd_transposeseq",1)
}
function mkmenu_transposeit(o,po,d) {
	o.menucmd("1",po,"edit","cmd_transpose",1*d)
	o.menucmd("2 - second",po,"edit","cmd_transpose",2*d)
	o.menucmd("3 - minor third",po,"edit","cmd_transpose",3*d)
	o.menucmd("4 - third",po,"edit","cmd_transpose",4*d)
	o.menucmd("5 - fourth",po,"edit","cmd_transpose",5*d)
	o.menucmd("6",po,"edit","cmd_transpose",6*d)
	o.menucmd("7 - fifth",po,"edit","cmd_transpose",7*d)
	o.menucmd("8",po,"edit","cmd_transpose",8*d)
	o.menucmd("9 - sixth",po,"edit","cmd_transpose",9*d)
	o.menucmd("10",po,"edit","cmd_transpose",10*d)
	o.menucmd("11",po,"edit","cmd_transpose",11*d)
	o.menucmd("12 - octave",po,"edit","cmd_transpose",12*d)
}
function mkmenu_gradual(o,po) {
	o.menucmd("Crescendo",po,"edit","cmd_crescendo")
	o.menucmd("Decrescendo",po,"edit","cmd_decrescendo")
}
function mkmenu_info(o,po) {
	o.menucmd("Beats",po,"onpicked","beatinfo")
	o.menucmd("Channels",po,"onpicked","fullinfo")
	o.menucmd("Polyphony",po,"onpicked","simulinfo")
}
function mkmenu_epchan(o,po,cmdstr) {
	for ( n=1; n<=16; n++ )
		o.menucmd(string(n),po,"editpick",cmdstr,n)
}
function mkmenu_groupview(o,po) {
	o.submenu("Tracks   ->","mkmenu_show",po)
	o.menucmd("Pan",po,"pan")
	o.menucmd("In",po,"startzoominx")
	o.menucmd("Out",po,"viewout",1,1)
	o.menucmd("Out a Bit",po,"viewout",1,0)
	o.menucmd("Fit Pick",po,"fitpick",1)
	o.menucmd("Last View",po,"zoomback")
	o.menucmd("Lengthen",po,"viewout",1,2)
	o.menucmd("Full Height",po,"viewout",1,3)
	o.menucmd("Chan Info",po,"showchan")

	# o.menucmd("Out Vert",primemsg(msg("zoomouty")))
	# o.menucmd("In Vert",primemsg(msg("zoominy")))
	# o.menucmd("Fit Pick",primemsg(msg("zoomfitpick")))
	# o.menucmd("Back",primemsg(msg("zoomback")))
}
function mkmenu_shift(o,po) {
	o.submenu("Forward  ->","mkmenu_foreback",po,1)
	o.submenu("Backward ->","mkmenu_foreback",po,-1)
}
function mkmenu_sca(o,po,cmd) {
	o.submenu("C  ->","mkmenu_sca2",po,'c',cmd)
	o.submenu("C# ->","mkmenu_sca2",po,'c+',cmd)
	o.submenu("D  ->","mkmenu_sca2",po,'d',cmd)
	o.submenu("D# ->","mkmenu_sca2",po,'d',cmd)
	o.submenu("E  ->","mkmenu_sca2",po,'e',cmd)
	o.submenu("F  ->","mkmenu_sca2",po,'f',cmd)
	o.submenu("F# ->","mkmenu_sca2",po,'f+',cmd)
	o.submenu("G  ->","mkmenu_sca2",po,'g',cmd)
	o.submenu("G# ->","mkmenu_sca2",po,'g+',cmd)
	o.submenu("A  ->","mkmenu_sca2",po,'a',cmd)
	o.submenu("A# ->","mkmenu_sca2",po,'a+',cmd)
	o.submenu("B  ->","mkmenu_sca2",po,'b',cmd)
	o.menucmd("Last Recorded (2b space)",po,"edit","cmd_scalast",cmd,1)
	o.menucmd("Snarf",po,"edit","cmd_scalast",cmd,2)
}
function mkmenu_sca2(o,po,nt,cmd) {
	o.menucmd("Ionian",po,"edit",cmd,nt,scale_ionian())
	o.menucmd("Dorian",po,"edit",cmd,nt,scale_dorian())
	o.menucmd("Phrygian",po,"edit",cmd,nt,scale_phrygian())
	o.menucmd("Lydian",po,"edit",cmd,nt,scale_lydian())
	o.menucmd("Mixolydian",po,"edit",cmd,nt,scale_mixolydian())
	o.menucmd("Aeolian",po,"edit",cmd,nt,scale_aeolian())
	o.menucmd("Locrian",po,"edit",cmd,nt,scale_locrian())
	o.menucmd("Locrian",po,"edit",cmd,nt,scale_locrian())
	o.menucmd("NewAge",po,"edit",cmd,nt,scale_newage())
}
function mkmenu_foreback(o,po,dir) {
	o.menucmd("Whole",po,"edit","cmd_shift",4b*dir)
	o.menucmd("Half",po,"edit","cmd_shift",2b*dir)
	o.menucmd("Quarter",po,"edit","cmd_shift",1b*dir)
	o.menucmd("Eighth",po,"edit","cmd_shift",1b/2*dir)
	o.menucmd("Sixteenth",po,"edit","cmd_shift",1b/4*dir)
	o.menucmd("Thirtysecond",po,"edit","cmd_shift",1b/8*dir)
	o.menucmd("Sixtyfourth",po,"edit","cmd_shift",1b/16*dir)
	o.menucmd("1 click",po,"edit","cmd_shift",1*dir)
}
function mkmenu_bs(o,po) {
	o.menucmd("Major",po,"editadd","cmd_bs",1)
	o.menucmd("Minor",po,"editadd","cmd_bs",0)
}
function mkmenu_apply(o,po) {
	o.menucmd("Nearest Time",po,"edit","cmd_applynear",TIME)
	o.menucmd("Nearest Duration",po,"edit","cmd_applynear",DURATION)
	o.menucmd("Nearest Volume",po,"edit","cmd_applynear",VOLUME)
	o.menucmd("Nearest Pitch",po,"edit","cmd_applynear",PITCH)
	o.menucmd("Sequence Time",po,"edit","cmd_applyseq",TIME)
	o.menucmd("Sequence Duration",po,"edit","cmd_applyseq",DURATION)
	o.menucmd("Sequence Volume",po,"edit","cmd_applyseq",VOLUME)
	o.menucmd("Sequence Pitch",po,"edit","cmd_applyseq",PITCH)
}
function mkmenu_average(o,po) {
	o.menucmd("Time",po,"edit","cmd_average","Time")
	o.menucmd("Duration",po,"edit","cmd_average","Duration")
	o.menucmd("Volume",po,"edit","cmd_average","Volume")
	o.menucmd("Pitch",po,"edit","cmd_average","Pitch")
}
function mkmenu_addroot(o,po) {
	o.menucmd("Every 1b",po,"editadd","cmd_addroot",1b)
	o.menucmd("Every 2b",po,"editadd","cmd_addroot",2b)
	o.menucmd("Every 4b",po,"editadd","cmd_addroot",4b)
	o.menucmd("Every 8b",po,"editadd","cmd_addroot",8b)
}
function mkmenu_replace(o,po) {
	o.menucmd("With Snarf",po,"edit","cmd_replace",0)
	o.menucmd("With Last Note/Chord",po,"edit","cmd_replace",1)
	o.menucmd("With Last Note/Chord (pitch only)",po,"edit","cmd_replace",3)
	o.menucmd("With Last Rec (2b space)",po,"edit","cmd_replace",2)
	o.menucmd("Each Note With Last Note/Chord",po,"edit","cmd_replace",4)
}
function mkmenu_repeat(o,po) {
	for ( n=2; n<=8; n++ )
		o.submenu(string(n)+"X, quant ->","mkmenu_repquant",po,n)
}
function mkmenu_repquant(o,po,n) {
	o.menucmd("8 Whole",po,"edit","cmd_repeatquant",n,32b)
	o.menucmd("4 Whole",po,"edit","cmd_repeatquant",n,16b)
	o.menucmd("2 Whole",po,"edit","cmd_repeatquant",n,8b)
	o.menucmd("Whole",po,"edit","cmd_repeatquant",n,4b)
	o.menucmd("Half",po,"edit","cmd_repeatquant",n,2b)
	o.menucmd("Quarter",po,"edit","cmd_repeatquant",n,1b)
	o.menucmd("Eighth",po,"edit","cmd_repeatquant",n,1b/2)
	o.menucmd("Sixteenth",po,"edit","cmd_repeatquant",n,1b/4)
}

function mkmenu_set(o,po) {
	o.submenu("Dur  ->","mkmenu_timevals",po,"cmd_setduration")
	o.submenu("Chan ->","mkmenu_setchan",po)
	o.submenu("Vol  ->","mkmenu_setvol",po)
}

function mkmenu_setchan(o,po) {
	for ( n=1; n<=16; n++ )
		o.menucmd(string(n),po,"edit","cmd_setchan",n)
}
function mkmenu_setvol(o,po) {
	o.menucmd("+1",po,"edit","cmd_adjvol",1)
	o.menucmd("+5",po,"edit","cmd_adjvol",5)
	o.menucmd("+10",po,"edit","cmd_adjvol",10)
	o.menucmd("-10",po,"edit","cmd_adjvol",-10)
	o.menucmd("-5",po,"edit","cmd_adjvol",-5)
	o.menucmd("-1",po,"edit","cmd_adjvol",-1)
}
function mkmenu_reverse(o,po) {
	o.menucmd("Pitch",po,"edit","cmd_reverse","Pitch")
	o.menucmd("Time",po,"edit","cmd_reverse","Time")
}
function mkmenu_stutter(o,po) {
	o.menucmd("Random",po,"edit","cmd_stutterrand")
	o.submenu("2x  ->","mkmenu_stut2",po,2)
	o.submenu("4x  ->","mkmenu_stut2",po,4)
}
function mkmenu_stut2(o,po,num) {
	o.menucmd("32 beats",po,"edit","cmd_stutter",32b,num)
	o.menucmd("16 beats",po,"edit","cmd_stutter",16b,num)
	o.menucmd("8 beats",po,"edit","cmd_stutter",8b,num)
	o.menucmd("7 beats",po,"edit","cmd_stutter",7b,num)
	o.menucmd("6 beats",po,"edit","cmd_stutter",6b,num)
	o.menucmd("5 beats",po,"edit","cmd_stutter",5b,num)
	o.menucmd("4 beats",po,"edit","cmd_stutter",4b,num)
	o.menucmd("3 beats",po,"edit","cmd_stutter",3b,num)
	o.menucmd("2 beats",po,"edit","cmd_stutter",2b,num)
	o.menucmd("Quarter",po,"edit","cmd_stutter",1b,num)
	o.menucmd("Eighth",po,"edit","cmd_stutter",1b/2,num)
	o.menucmd("Sixteenth",po,"edit","cmd_stutter",1b/4,num)
	o.menucmd("Thirtysecond",po,"edit","cmd_stutter",1b/8,num)
}
function mkmenu_quantize(o,po) {
	o.submenu("Each Note  ->","mkmenu_timevals",po,"cmd_quantize")
	o.submenu("First Note ->","mkmenu_timevals",po,"cmd_quantizefirst")
	o.submenu("Duration   ->","mkmenu_timevals",po,"cmd_quantizedur")
}
function mkmenu_timevals(o,po,cmd) {
	o.menucmd("Whole",po,"edit",cmd,4b)
	o.menucmd("Half",po,"edit",cmd,2b)
	o.menucmd("Quarter",po,"edit",cmd,1b)
	o.menucmd("Eighth",po,"edit",cmd,1b/2)
	o.menucmd("Sixteenth",po,"edit",cmd,1b/4)
	o.menucmd("Thirtysecond",po,"edit",cmd,1b/8)
	o.menucmd("Sixtyfourth",po,"edit",cmd,1b/16)
	o.menucmd("1 click",po,"edit",cmd,1)
}
function mkmenu_scale(o,po) {
	# note that mkmenu_scaleit is used for handling all three of these
	o.submenu("Time     ->","mkmenu_scaleit",po,"cmd_timescale")
	o.submenu("Duration ->","mkmenu_scaleit",po,"cmd_durscale")
	o.submenu("Volume   ->","mkmenu_scaleit",po,"cmd_volscale")
}
function mkmenu_scaleit(o,po,cmd) {
	o.menucmd("2x",po,"edit",cmd,2.0)
	o.menucmd("1.5x",po,"edit",cmd,1.5)
	o.menucmd("1.1x",po,"edit",cmd,1.1)
	o.menucmd("1.03x",po,"edit",cmd,1.03)
	o.menucmd("1.01x",po,"edit",cmd,1.01)
	o.menucmd("0.99x",po,"edit",cmd,0.99)
	o.menucmd("0.97x",po,"edit",cmd,0.97)
	o.menucmd("0.9x",po,"edit",cmd,0.9)
	o.menucmd("0.667x",po,"edit",cmd,0.6666666)
	o.menucmd("0.5x",po,"edit",cmd,0.5)
}
function mkmenu_timevals2(o,po,cmd) {
	o.menucmd("Whole",po,"edit",cmd,4b)
	o.menucmd("Half",po,"edit",cmd,2b)
	o.menucmd("Quarter",po,"edit",cmd,1b)
	o.menucmd("Eighth",po,"edit",cmd,1b/2)
	o.menucmd("Sixteenth",po,"edit",cmd,1b/4)
	o.menucmd("Thirtysecond",po,"edit",cmd,1b/8)
	o.menucmd("Sixtyfourth",po,"edit",cmd,1b/16)
	o.menucmd("5 clicks",po,"edit",cmd,5)
	o.menucmd("4 clicks",po,"edit",cmd,4)
	o.menucmd("3 clicks",po,"edit",cmd,3)
	o.menucmd("2 clicks",po,"edit",cmd,2)
	o.menucmd("1 clicks",po,"edit",cmd,1)
}
function mkmenu_echovals(o,po,n,cmd) {
	o.menucmd("Whole",po,"edit",cmd,n,4b)
	o.menucmd("Half",po,"edit",cmd,n,4b/2)
	o.menucmd("Quarter",po,"edit",cmd,n,4b/4)
	o.menucmd("Eighth",po,"edit",cmd,n,4b/8)
	o.menucmd("Sixteenth",po,"edit",cmd,n,4b/16)
	o.menucmd("Thirtysecond",po,"edit",cmd,n,4b/32)
	o.menucmd("64th",po,"edit",cmd,n,4b/64)
}
function mkmenu_root(o) {
	# o.menucmd("Monolith2b","sweeptool","wmonolith2b")
	o.menucmd("Move","wmove")
	o.menucmd("Resize","wresize")
	o.menucmd("Delete","wdelete")
	o.submenu("Tools1->","mkmenu_tools",1)
	o.submenu("Tools2->","mkmenu_tools",2)
	o.submenu("Misc  ->","mkmenu_misc")
	o.submenu("Page  ->","mkmenu_page")
	o.submenu("Window->","mkmenu_wind")
}

function mkmenu_tracktools(o,wt,tn) {
	o.submenu("Change Tool ->","mkmenu_tracktoollist",wt,tn)
}

function mkmenu_settool(o,po) {
	# Create a menu of all the tools that are "trackable"
	names = tooltypesall()
	nn = sizeof(names)
	for ( n=0; n<nn; n++ ) {
		a = names[n]
		if ( "trackable" in a ) {
			o.menucmd(a["name"],po,"edit","cmd_settool",a["class"])
		}
	}
}
function mkmenu_page(o) {
	o.menucmd("Snapshot","snapshot")
	o.submenu("Switch ->","mkmenu_switch")
	o.menucmd("Label","page_label")
	o.menucmd("New","page_new")
	o.menucmd("Read","page_readnew")
	# o.menucmd("Read Merge","page_readmerge")
	o.menucmd("Write","page_write")
	o.menucmd("Write All","pagecol_write")
}
function mkmenu_switch(o) {
	for ( po in Pages )
		o.menucmd(Pages[po],"page_switch",po)
}
function tooltypesall() {
	nm1 = tooltypes(1)
	sz1 = sizeof(nm1)

	nm2 = tooltypes(2)
	sz2 = sizeof(nm2)

	# Add the list in nm2 to nm1 - we need a separate array
	# because the one returned from tooltypes() is shared
	# by other things.

	nm1 = arraycopy(nm1)

	for ( k=0; k<sz2; k++ ) {
		# insertion sort
		for ( i=0; i<sz1; i++ ) {
			if ( nm2[k]["name"] < nm1[i]["name"] )
				break
		}
		for ( kk=sz1; kk>i; kk-- ) {
			nm1[kk] = nm1[kk-1]
		}
		nm1[i] = nm2[k]
		sz1++
	}
	return(nm1)
}

function tooltypes(ti) {

	if ( defined(Tooltypes) && Tooltypes != 0 )
		return(Tooltypes[ti])

	global Tooltypes
	Tooltypes = []

	for ( i=1; i<=2; i++ ) {
		Tooltypes[i] = []

		# Loop through all the directories in Keypath

		dirs = split(Keypath,Pathseparator)
		for ( di=0; di<sizeof(dirs); di++ ) {
			fn = dirs[di] + Dirseparator + "tools" + string(i) + ".lst"
			if ( fileexists(fn) ) {
				add2tooltypes(fn,Tooltypes[i])
			}
			# For upward compatibility, we also pull in
			# files of the form "localtools*.lst"
			fn = dirs[di] + Dirseparator + "localtools" + string(i) + ".lst"
			if ( fileexists(fn) ) {
				add2tooltypes(fn,Tooltypes[i])
			}
		}
	}

	return(Tooltypes[ti])
}

function add2tooltypes(fn,ttypes) {
	# print("Reading tool list from "+fn)
	f = open(fn)
	while ( (ln=get(f)) != Eof ) {
		if ( substr(ln,1,1) == "#" )
			continue
		s = split(ln,"\t:=\r\n")
		if ( sizeof(s) < 2 )
			continue
		n = sizeof(ttypes)
		ttypes[n] = ["name"=s[0],"class"=s[1]]
		# If any other words are included, look at them
		i = 2
		if ( sizeof(s) > i ) {
			t = s[i++]
			if ( t == "trackable" )
				ttypes[n]["trackable"] = 1
			# other words might be added later
		}
	}
	close(f)
}

function mkmenu_tools(o,i) {
	names = tooltypes(i)
	nn = sizeof(names)
	for ( n=0; n<nn; n++ ) {
		o.menucmd(names[n]["name"],"sweeptool",names[n]["class"])
	}
}

function mkmenu_arrange(o) {
	o.menucmd("Horizontal","warrange","x")
	o.menucmd("Vertical","warrange","y")
	# o.menucmd("Pack","wpack")
	o.submenu("Resize  ->","mkmenu_resize")
	o.menucmd("Swap","wswap")
	o.menucmd("Top","m_top")
}
function mkmenu_resize(o) {
	o.menucmd("Horizontal","wmax","x")
	o.menucmd("Vertical","wmax","y")
}
function mkmenu_mouse(o) {
	o.menucmd("Record On","mouserec",1)
	o.menucmd("Record Off","mouserec",-1)
	o.menucmd("Playback","mouseplay")
	o.menucmd("Write File","mousewritefile")
	o.menucmd("Read File","mousereadfile")
}
function mkmenu_wind(o) {
	o.submenu("Arrange   ->","mkmenu_arrange")
	o.menucmd("Broadcast","wbroadcast")
	o.menucmd("Copy","wcopy")
	o.submenu("File      ->","mkmenu_windfile")
	o.menucmd("Help","whelp")
	# o.menucmd("Info","winfo")
	o.menucmd("Snarf Phrase","wsnarf")
	o.menucmd("Snarf Tool","wsnarftool")
	o.menucmd("Paste Tool","wpastetool")
	# o.menucmd("Debug invis","winvis")
}
function mkmenu_windfile(o) {
	o.menucmd("Dump Tool to File","wdump")
	o.menucmd("Restore Tool from File","wrestore")
}
function mkmenu_demo(o) {
	o.menucmd("Demo 1","dodemo","demo1.km")
}
function winvis() {
	w = wselect()
	w.displaymode("invisible")
}
function m_top() {
	w = wselect()
	w.redraw()
}
