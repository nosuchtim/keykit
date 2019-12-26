# FUNCTIONS RELATED TO STATISTICS TOOL

#*********************************************************************
#			MENUS & UTILITIES
#------------------------------------------------------------------------------
#			MIN-MAX MENUS
#------------------------------------------------------------------------------

function mkmenu_mm (o,po) {
	o.submenu("Pitches  ->","mkmenu_pitches_minmax",po)
	o.submenu("Durations  ->","mkmenu_durations_minmax",po)
	o.submenu("Timings  ->","mkmenu_timeintervals_minmax",po)
	o.submenu("Velocities  ->","mkmenu_velvalues_minmax",po)
}

#-------------------------------------------------------------------

function mkmenu_pitches_minmax (o,po) {
	o.submenu("Pitch Values  ->","mkmenu_pitchvalues_minmax",po)
	o.submenu("Intervals  ->","mkmenu_pitchintervals_minmax",po)
}

function mkmenu_durations_minmax (o,po) {
	o.submenu("Duration Values  ->","mkmenu_durvalues_minmax",po)
	o.submenu("Intervals  ->","mkmenu_durintervals_minmax",po)
}

#-----------------------------------------------------------------------
#			PITCHES - INTERVALS

function mkmenu_pitchvalues_minmax (o,po,param) {
	o.menucmd("Lowest Note",po,"minpitch","pitch")
	o.menucmd("Highest Note",po,"maxpitch","pitch")
	o.menucmd("Mean Note",po,"arith_mean","pitch")
	o.menucmd("St. Dev Pitches",po,"stand_dev","pitch")
}

function mkmenu_pitchintervals_minmax (o,po,param_i) {
	o.menucmd("Min P Int",po,"min_pitch_interval","pitch_i")
	o.menucmd("Max P Int",po,"max_pitch_interval","pitch_i")
	o.menucmd("Mean P Int",po,"pitch_int_arith_mean","pitch_i")
	o.menucmd("St. Dev. P Int",po,"pitch_int_stand_dev","pitch_i")
}

#---------------------------------------------------------------------------
#			DURATIONS - RHYTHM INTERVALS

function mkmenu_durvalues_minmax (o,po,param) {
	o.menucmd("Shortest Dur.",po,"minpitch","dur")
	o.menucmd("Longest Dur.",po,"maxpitch","dur")
	o.menucmd("Mean Dur.",po,"arith_mean","dur")
	o.menucmd("St. Dev Dur.",po,"stand_dev","dur")	
}

function mkmenu_durintervals_minmax (o,po,param_i) {
	o.menucmd("Min R Int",po,"min_pitch_interval","dur_i")
	o.menucmd("Max R Int",po,"max_pitch_interval","dur_i")
	o.menucmd("Mean R Int",po,"pitch_int_arith_mean","dur_i")
	o.menucmd("St. Dev R Int",po,"pitch_int_stand_dev","dur_i")	
}

#---------------------------------------------------------------------------
#			TIMINGS - TIME INTERVALS

function mkmenu_timeintervals_minmax (o,po,param_i) {
	o.menucmd("Min T Int",po,"min_pitch_interval","time_i")
	o.menucmd("Max T Int",po,"max_pitch_interval","time_i")
	o.menucmd("Mean T Int",po,"pitch_int_arith_mean","time_i")
	o.menucmd("St. Dev T Int",po,"pitch_int_stand_dev","time_i")	
}

#----------------------------------------------------------------------------
#			VELOCITY INTERVALS

function mkmenu_velvalues_minmax (o,po,param) {
	o.menucmd("Softest Note",po,"minpitch","vel")
	o.menucmd("Loudest Note",po,"maxpitch","vel")
	o.menucmd("Mean V Note",po,"arith_mean","vel")
	o.menucmd("St. Dev Velocity",po,"stand_dev","vel")
}

#-----------------------------------------------------------------------------
#			LOADING and SAVING

function mkmenu_load (o,po) {
	o.menucmd("Load File",po,"loadfileanalyse")
	o.menucmd("Load Snarf",po,"loadsnarfanalyse")
}

function mkmenu_save (o,po) {
	o.submenu("Modify ->","mkmenu_save_modify",po)
	o.submenu("Build ->","mkmenu_save_build",po)
	o.menucmd("To file",po,"save_file")
	o.menucmd("Snarf",po,"save_snarf")
	o.menucmd("Clear",po,"save_clear")
}

function mkmenu_save_modify (o,po) {
	o.menucmd("Joint",po,"joint_result_notes")
	o.menucmd("Legato",po,"save_legato")
}

function mkmenu_save_build (o,po) {
	o.menucmd("Mix",po,"save_mix")
	o.menucmd("Append",po,"save_append")
}
#******************************************************************************
#			PERCENT MENUS
#******************************************************************************

function mkmenu_percent (o,po,param_pc) {
	o.submenu("Notes % ->","mkmenu_notes_pint",po)
	o.menucmd("Durations %",po,"notes_durations_percent")
	o.menucmd("Velocities %",po,"notes_pitches_percent","vel_pc")
}

function mkmenu_notes_pint (o,po,param_pc) {
	o.menucmd ("Pitches",po,"notes_pitches_percent","notes_pc")
	o.menucmd ("Intervals",po,"notes_pitches_percent","int_pc")
}

#******************************************************************************
#			ABOVE - BELOW MENUS
#******************************************************************************

function mkmenu_above_below (o,po) {
	o.submenu("Pitches ->","mkmenu_ab_pitches",po)
	o.submenu("Intervals ->","mkmenu_ab_intervals",po)
	o.submenu("Durations % ->","mkmenu_ab_dur",po)
	o.submenu("Velocities% ->","mkmenu_ab_vel",po)	
}

function mkmenu_ab_pitches (o,po) {
	o.submenu("Above ->","mkmenu_ab_pitches_note_above",po)
	o.submenu("Below ->","mkmenu_ab_pitches_note_below",po)
	o.menucmd("From .. To",po,"ab_pitches_note_from_to")
}

function mkmenu_ab_pitches_note_above(o,po,ntstr) {
	o.submenu("C->","mkmenu_ab_pitches_octave_above",po,"c")
	o.submenu("C#->","mkmenu_ab_pitches_octave_above",po,"c+")
	o.submenu("D->","mkmenu_ab_pitches_octave_above",po,"d")
	o.submenu("D#->","mkmenu_ab_pitches_octave_above",po,"d+")
	o.submenu("E->","mkmenu_ab_pitches_octave_above",po,"e")
	o.submenu("F->","mkmenu_ab_pitches_octave_above",po,"f")
	o.submenu("F#->","mkmenu_ab_pitches_octave_above",po,"f+")
	o.submenu("G->","mkmenu_ab_pitches_octave_above",po,"g")
	o.submenu("G#->","mkmenu_ab_pitches_octave_above",po,"g+")
	o.submenu("A->","mkmenu_ab_pitches_octave_above",po,"a")
	o.submenu("A#->","mkmenu_ab_pitches_octave_above",po,"a+")
	o.submenu("B->","mkmenu_ab_pitches_octave_above",po,"b")
}

function mkmenu_ab_pitches_octave_above (o,po,ntstr,octstr) {
	o.menucmd("0 (Mid C)",po,"above_note",ntstr,"o3")
	o.menucmd("+1",po,"above_note",ntstr,"o4")
	o.menucmd("+2",po,"above_note",ntstr,"o5")
	o.menucmd("+3",po,"above_note",ntstr,"o6")
	o.menucmd("+4",po,"above_note",ntstr,"o7")
	o.menucmd("-1",po,"above_note",ntstr,"o2")
	o.menucmd("-2",po,"above_note",ntstr,"o1")
	o.menucmd("-3",po,"above_note",ntstr,"o0")
	o.menucmd("-4",po,"above_note",ntstr,"o-1")
}

function mkmenu_ab_pitches_note_below(o,po,ntstr) {
	o.submenu("C->","mkmenu_ab_pitches_octave_below",po,"c")
	o.submenu("C#->","mkmenu_ab_pitches_octave_below",po,"c+")
	o.submenu("D->","mkmenu_ab_pitches_octave_below",po,"d")
	o.submenu("D#->","mkmenu_ab_pitches_octave_below",po,"d+")
	o.submenu("E->","mkmenu_ab_pitches_octave_below",po,"e")
	o.submenu("F->","mkmenu_ab_pitches_octave_below",po,"f")
	o.submenu("F#->","mkmenu_ab_pitches_octave_below",po,"f+")
	o.submenu("G->","mkmenu_ab_pitches_octave_below",po,"g")
	o.submenu("G#->","mkmenu_ab_pitches_octave_below",po,"g+")
	o.submenu("A->","mkmenu_ab_pitches_octave_below",po,"a")
	o.submenu("A#->","mkmenu_ab_pitches_octave_below",po,"a+")
	o.submenu("B->","mkmenu_ab_pitches_octave_below",po,"b")
}

function mkmenu_ab_pitches_octave_below(o,po,ntstr,octstr) {
	o.menucmd("0 (Mid C)",po,"below_note",ntstr,"o3")
	o.menucmd("+1",po,"below_note",ntstr,"o4")
	o.menucmd("+2",po,"below_note",ntstr,"o5")
	o.menucmd("+3",po,"below_note",ntstr,"o6")
	o.menucmd("+4",po,"below_note",ntstr,"o7")
	o.menucmd("-1",po,"below_note",ntstr,"o2")
	o.menucmd("-2",po,"below_note",ntstr,"o1")
	o.menucmd("-3",po,"below_note",ntstr,"o0")
	o.menucmd("-4",po,"below_note",ntstr,"o-1")
}

#--------------------------- ABOVE - BELOW INTERVALS ---------------

function mkmenu_ab_intervals(o,po) {
	o.submenu("Above ->","mkmenu_ab_pitches_intervals_above",po)
	o.submenu("Below ->","mkmenu_ab_pitches_intervals_below",po)
	o.menucmd("From .. To",po,"ab_pitches_intervals_from_to")
}

function mkmenu_ab_pitches_intervals_above (o,po,ni) {
	o.menucmd("2nd M",po,"above_pitches_intervals",2 )
	o.menucmd("3nd m",po,"above_pitches_intervals",3 )
	o.menucmd("3rd M",po,"above_pitches_intervals",4 )
	o.menucmd("4th P",po,"above_pitches_intervals",5 )
	o.menucmd("4th A",po,"above_pitches_intervals",6 )
	o.menucmd("5nd P",po,"above_pitches_intervals",7 )
	o.menucmd("6th m",po,"above_pitches_intervals",8 )
	o.menucmd("6th M",po,"above_pitches_intervals",9 )
	o.menucmd("7th m",po,"above_pitches_intervals",10 )
	o.menucmd("7th M",po,"above_pitches_intervals",11 )
	o.menucmd("Octave",po,"above_pitches_intervals",12 )
	o.menucmd("other ..",po,"above_pitches_intervals",0 )	
}

function mkmenu_ab_pitches_intervals_below (o,po,ni) {
	o.menucmd("2nd M",po,"below_pitches_intervals",2 )
	o.menucmd("3nd m",po,"below_pitches_intervals",3 )
	o.menucmd("3rd M",po,"below_pitches_intervals",4 )
	o.menucmd("4th P",po,"below_pitches_intervals",5 )
	o.menucmd("4th A",po,"below_pitches_intervals",6 )
	o.menucmd("5nd P",po,"below_pitches_intervals",7 )
	o.menucmd("6th m",po,"below_pitches_intervals",8 )
	o.menucmd("6th M",po,"below_pitches_intervals",9 )
	o.menucmd("7th m",po,"below_pitches_intervals",10 )
	o.menucmd("7th M",po,"below_pitches_intervals",11 )
	o.menucmd("Octave",po,"below_pitches_intervals",12 )
	o.menucmd("other ..",po,"below_pitches_intervals",0 )	
}

#--------------------------- ABOVE - BELOW DURATIONS ---------------

function mkmenu_ab_dur(o,po) {
	o.submenu("Above ->","mkmenu_ab_dur_above",po)
	o.submenu("Below ->","mkmenu_ab_dur_below",po)
	o.menucmd("From .. To",po,"ab_dur_from_to")
}

function mkmenu_ab_dur_above (o,po,d) {
	o.menucmd("Whole",po,"above_dur",384 )
	o.menucmd("Half dot",po,"above_dur",288 )
	o.menucmd("Half",po,"above_dur",192 )
	o.menucmd("Quarter dot",po,"above_dur",144 )
	o.menucmd("Quarter",po,"above_dur",96 )
	o.menucmd("Eight dot",po,"above_dur",72 )
	o.menucmd("Eight",po,"above_dur",48 )
	o.menucmd("Sixteenth",po,"above_dur",24 )
	o.menucmd("32.nd",po,"above_dur",12 )
	o.menucmd("other ..",po,"above_dur",0 )	
}

function mkmenu_ab_dur_below(o,po,d) {
	o.menucmd("Whole",po,"below_dur",384 )
	o.menucmd("Half dot",po,"below_dur",288 )
	o.menucmd("Half",po,"below_dur",192 )
	o.menucmd("Quarter dot",po,"below_dur",144 )
	o.menucmd("Quarter",po,"below_dur",96 )
	o.menucmd("Eight dot",po,"below_dur",72 )
	o.menucmd("Eight",po,"below_dur",48 )
	o.menucmd("Sixteenth",po,"below_dur",24 )
	o.menucmd("32.nd",po,"below_dur",12 )
	o.menucmd("other ..",po,"below_dur",0 )	
}

#--------------------------- ABOVE - BELOW VELOCITIES---------------

function mkmenu_ab_vel(o,po) {
	o.submenu("Above ->","mkmenu_ab_vel_above",po)
	o.submenu("Below ->","mkmenu_ab_vel_below",po)
	o.menucmd("From .. To",po,"ab_vel_from_to")
}

function mkmenu_ab_vel_above (o,po,v) {
	o.menucmd("ppp (1-10)",po,"above_vel",1)
	o.menucmd("pp (11-24)",po,"above_vel",11)
	o.menucmd("p (25-36)",po,"above_vel",25)
	o.menucmd("mp (37-50)",po,"above_vel",37)
	o.menucmd("mf (51-64)",po,"above_vel",51)
	o.menucmd("f (65-78)",po,"above_vel",65)
	o.menucmd("ff (79-99)",po,"above_vel",79)
	o.menucmd("fff (100-127)",po,"above_vel",100)
	o.menucmd("other ..",po,"above_vel",0)	
}

function mkmenu_ab_vel_below(o,po,v) {
	o.menucmd("ppp (1-10)",po,"below_vel",1)
	o.menucmd("pp (11-24)",po,"below_vel",11)
	o.menucmd("p (25-36)",po,"below_vel",25)
	o.menucmd("mp (37-50)",po,"below_vel",37)
	o.menucmd("mf (51-64)",po,"below_vel",51)
	o.menucmd("f (65-78)",po,"below_vel",65)
	o.menucmd("ff (79-99)",po,"below_vel",79)
	o.menucmd("fff (100-127)",po,"below_vel",100)
	o.menucmd("other ..",po,"below_vel",0)	
}

function mkmenu_writelog (o,po) {
	o.menucmd("Write ..",po,"write_verbose1")
	o.menucmd("Do all and write ..",po,"do_write")
	o.submenu("Write in columns->","mkmenu_write_col",po)
}

function mkmenu_write_col (o,po) {
	o.menucmd("Notes ..",po,"write_most_tabular_notes")
	o.menucmd("Intervals",po,"write_most_tabular_intervals")	
	o.menucmd("Durations",po,"write_most_tabular_durations")
	o.menucmd("Notes by DUR",po,"write_most_tabular_notes_dur")
	o.menucmd("Intervals by DUR",po,"write_most_tabular_intervals_dur")
}

#*********************************************************************
#			MOST MENUS
#*********************************************************************

function mkmenu_most (o,po) {
	o.submenu("Notes ->","mkmenu_most_notes",po)
	o.submenu("Intervals ->","mkmenu_most_intervals",po)
	o.submenu("Durations ->","mkmenu_most_dur",po)
}

function mkmenu_most_notes (o,po,param1) {
	o.menucmd("by Attacks",po,"most_attacks","pitch")
	o.menucmd("by Duration",po,"most_dur","pitch")
}

function mkmenu_most_intervals (o,po,param1) {
	o.menucmd("by Attacks",po,"most_attacks","int")
	o.menucmd("by Duration",po,"most_dur","int")
}

function mkmenu_most_dur (o,po,param1) {
	o.menucmd("by Attacks",po,"most_attacks","dur")
}

#***********************************************************************************************
#			UTILITY FUNCTIONS
#***********************************************************************************************

function maxduration(p) {
	maxdur = 1
	for ( n in p ) {
		if ( n.dur > maxdur )
			maxdur = n.dur
	}
	return(maxdur)
}

function get_rhythm (d) {
	r_name = "undefined"
		if ( d == 1) r_name = "1 Click"
		if ( d == 2) r_name = "128.th Trip."
		if ( d == 3) r_name = "128.th"
		if ( d == 4) r_name = "64.th Trip."
		if ( d == 6) r_name = "64.th"
		if ( d == 8) r_name = "32.th Trip."
		if ( (d >= 9) && (d < 10)) r_name = "32.th Tentupl."
		if ( (d >= 10) &&(d <11)) r_name = "32.th Ninetupl"
		if ( d == 12) r_name = "32.nd"
		if ( (d >= 13) &&(d <14)) r_name = "16.th Seventupl"
		if ( d == 16) r_name = "16.th Sextupl"
		if ( (d >= 19) && (d < 20)) r_name = "16.th Quint."
		if (( d >= 21) && ( d < 22)) r_name = "16.th Ninetupl"
		if ( d == 24) r_name = "Sixteen"
		if (( d >= 27) && ( d < 28)) r_name = "Eight seventupl"
		if ( d == 32) r_name = "8.th Triplet"
		if (( d >= 38) && (d < 39)) r_name = "Eight quint."
		if ( d == 48) r_name = "Eight"
		if ( d == 64) r_name = "Quarter tripl."
		if ( d == 96) r_name = "Quarter"
		if ( d == 144) r_name = "Dotted quarter"
		if ( d == 192) r_name = "Half"
		if ( d == 288) r_name = "Dotted half"
		if ( d == 384) r_name = "Whole"
	return (r_name)
}

function get_note_name (p) {
	octave = -2
	note_name = ""
	while (p >= 12 ) {
		p -=12
		octave++
	}
	if (p == 0) note_name = "c"
	if (p == 1) note_name = "c#"
	if (p == 2) note_name = "d"
	if (p == 3) note_name = "d#"
	if (p == 4) note_name = "e"
	if (p == 5) note_name = "f"
	if (p == 6) note_name = "f#"
	if (p == 7) note_name = "g"
	if (p == 8) note_name = "g#"
	if (p == 9) note_name = "a"
	if (p == 10) note_name = "a#"
	if (p == 11) note_name = "b"
	note_name+="o" + string (octave)
	return (note_name)
}

function get_nuance (v) {
	if (v<=10) nuance = "ppp"
	if ((v>10) && (v<=24)) nuance = "pp"
	if ((v>24) && (v<=36)) nuance = "p"
	if ((v>36) && (v<=50)) nuance = "mp"
	if ((v>50) && (v<=64)) nuance = "mf"
	if ((v>64) && (v<=78)) nuance = "f"
	if ((v>78) && (v<=99)) nuance = "ff"
	if (v>100) nuance = "fff"
	return(nuance)
}

function get_interval_name (int) {
	interval = "undefined"
	if (abs(int) == 1) interval = "Sec.Min."
	if (abs(int) == 2) interval = "Sec.Maj."
	if (abs(int) == 3) interval = "3rd.Min."
	if (abs(int) == 4) interval = "3rd.Maj."
	if (abs(int) == 5) interval = "4th."
	if (abs(int) == 6) interval = "4th.Aug."
	if (abs(int) == 7) interval = "5th."
	if (abs(int) == 8) interval = "6th.Min"
	if (abs(int) == 9) interval = "6th.Maj."
	if (abs(int) == 10) interval = "7th.Min"
	if (abs(int) == 11) interval = "7th.Maj."
	if (abs(int) == 12) interval = "8ve."
	if (abs(int) == 13) interval = "8ve.+Sec.Min."
	if (abs(int) == 14) interval = "8ve.+Sec.Maj."
	if (abs(int) == 15) interval = "8ve.+3rd.Min."
	if (abs(int) == 16) interval = "8ve.+3rd.Maj."
	if (abs(int) == 17) interval = "8ve.+4th."
	if (abs(int) == 18) interval = "8ve.+4th.Aug."
	if (abs(int) == 19) interval = "8ve.+5th."
	if (abs(int) == 20) interval = "8ve.+6th.Min"
	if (abs(int) == 21) interval = "8ve.+6th.Maj."
	if (abs(int) == 22) interval = "8ve.+7th.Min"
	if (abs(int) == 23) interval = "8ve.+7th.Maj."
	if (abs(int) == 24) interval = "8ve.+8ve."
	return (interval)
}

function print_guide () {
	print ("Mid.C=60; Co-2=0; Co-1=12; Co0=24; Co1=36; Co2=48; Co3=60; Co4=72; Co5=84; Co6=96")
}

function get_phrase_notes (p) {
	nnotes = 0
	for (nt in p)
		 nnotes++
	return (nnotes)
}

function get_percent_ratio (np) {
	if (np<100)
		pr = float(100 / np)
	else
		pr = float(np / 100)
	return (pr)
}


