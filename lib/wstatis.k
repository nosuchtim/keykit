#********************************************************************

#	STATISTICS 
#	by
#	Mehmet Okonsar
#	mokonsar@dominet.in.com.tr
#	files : wStatis.k AND statfunc.k
#	Tool for getting statistical data from midi files. It may serve
#	for researches on styles ( of oneself and other composers) but 
#	also for composing.
#	USAGE:
#	"LOAD" -> a midi file or the snarf to be analysed
#	"MINMAX" -> extracts the minimum, maximum, mean and standard
#		deviation values of pitches, intervals, durs etc..
#	" % " -> extracts the percent values of occurences of 
#		pitches, intervals, durs etc..
#	" <> " -> search for above - below - from ..to given values
#		of pitches, intervals, durs etc..
#	" Most " -> mostly occuring notes, intervals etc.. Counted by
#		number of attacks (i.e. the actual number of notes) or by
#		duration (i.e. the total duration of the note for the 
#		whole piece)
#	" Write " -> "Write .." writes to a file (*.sta or *.txt) the 
#		generated searches;
#		"Do all and write" does all common searches and writes;
#		" Write in columns" output of specifical searches suitable for
#		use with spreadsheet and graphical analysis programs

#*********************************************************************

class wstatis {
	method init {
#------------------------------------
	MIN_PITCH_FOUND = 0
	MAX_PITCH_FOUND = 0
	MEAN_PITCH_FOUND = 0
	STAND_DEV_PITCH_FOUND = 0

	MIN_PITCH_INT_FOUND = 0
	MAX_PITCH_INT_FOUND = 0
	MEAN_PITCH_INT_FOUND = 0
	STAND_DEV_PITCH_INT_FOUND = 0

	MIN_DUR_FOUND = 0
	MAX_DUR_FOUND = 0
	MEAN_DUR_FOUND = 0
	STAND_DEV_DUR_FOUND = 0

	MIN_DUR_INT_FOUND = 0
	MAX_DUR_INT_FOUND = 0
	MEAN_DUR_INT_FOUND = 0
	STAND_DEV_DUR_INT_FOUND = 0

	MIN_TIME_INT_FOUND = 0
	MAX_TIME_INT_FOUND = 0
	MEAN_TIME_INT_FOUND = 0
	STAND_DEV_TIME_INT_FOUND = 0

	MIN_VEL_FOUND = 0
	MAX_VEL_FOUND = 0
	MEAN_VEL_FOUND = 0
	STAND_DEV_VEL_FOUND = 0

#---------------------------------------

	ANALYSEPHRASE = ''
	RESULTPHRASE = ''

	RESULTPHRASENOTES = 0
	ANALYSEPHRASENOTES = 0
#---------------------------------------

	LOWESTNOTE = ''
	HIGHESTNOTE = ''
	MEANNOTE = 0
	MIN_MELODIC_INTERVAL = 2	
	MAX_MELODIC_INTERVAL = 1
	PINTERVALS = []
	MEAN_PITCH_INTERVAL = 0
	MEANINTERVAL = 0
	P_INTERV_STANDARDDEV = 0

	SHORTESTNOTE = 0
	SHORTESTNOTERHYTHM = ""
	LONGESTNOTE = 0
	LONGESTNOTERHYTHM =""
	MEANDURATION = 0
	DUR_STANDARDDEV = 0
	DINTERVALS =[]
	MIN_RHYTHMIC_INTERVAL = 0
	MAX_RHYTHMIC_INTERVAL = 0
	MEAN_RHYTHMIC_INTERVAL = 0
	RHYTHMIC_INTERV_STANDARDDEV = 0

	TINTERVALS = []
	MIN_TIME_INTERVAL = 96
	MAX_TIME_INTERVAL = 96
	MEAN_TIME_INTERVAL = 0
	TIME_INTERV_STANDARDDEV = 0

	SOFTESTNOTE = 0
	LOUDESTNOTE = 0
	MEAN_NOTE_VEL = 0
	STANDARDDEV_VEL = 0

#---------------------------------------
	NOTE_OCCURENCE = []
	NOTE_OCCURENCE_PERCENT = []

	INTERVAL_OCCURENCE = []
	INTERVAL_OCCURENCE_PERCENT = []

	DUR_OCCURENCE = []
	DUR_OCCURENCE_PERCENT = []

	VEL_OCCURENCE = []
	VEL_OCCURENCE_PERCENT = []

	NOTE_OCCURENCE_DONE = 0
	INT_OCCURENCE_DONE = 0
	DUR_OCCURENCE_DONE = 0
	VEL_OCCURENCE_DONE = 0
#---------------------------------------
	SEARCH_ABOVE_NOTES_INDEX = 0
	ABOVE_NOTE_GIVEN = []
	NOTES_ABOVE_PERCENT = []
	ABOVE_NOTE_RESULT_PHRASE = []

	SEARCH_BELOW_NOTES_INDEX = 0
	BELOW_NOTE_GIVEN = []
	NOTES_BELOW_PERCENT = []
	BELOW_NOTE_RESULT_PHRASE = []

	SEARCH_FROMTO_NOTES_INDEX = 0
	FROM_NOTE_GIVEN = []
	TO_NOTE_GIVEN = []
	NOTES_FROMTO_PERCENT = []
	FROMTO_NOTE_RESULT_PHRASE = []

#---------------------------------------
	SEARCH_ABOVE_INTERVALS_INDEX = 0
	ABOVE_INTERVAL_GIVEN = []
	ABOVE_INTERVAL_RESULT_PHRASE = []
	INTERVAL_ABOVE_PERCENT = []

	SEARCH_BELOW_INTERVALS_INDEX = 0
	BELOW_INTERVAL_GIVEN = []
	BELOW_INTERVAL_RESULT_PHRASE = []
	INTERVAL_BELOW_PERCENT = []

	SEARCH_FROMTO_INTERVALS_INDEX = 0
	FROM_INTERVAL_GIVEN = []
	TO_INTERVAL_GIVEN = []
	FROMTO_INTERVAL_RESULT_PHRASE = []
	INTERVAL_FROMTO_PERCENT = []
#---------------------------------------
	SEARCH_ABOVE_DURS_INDEX = 0
	ABOVE_DUR_GIVEN = []
	ABOVE_DUR_RESULT_PHRASE = []
	DUR_ABOVE_PERCENT = []

	SEARCH_BELOW_DURS_INDEX = 0
	BELOW_DUR_GIVEN = []
	BELOW_DUR_RESULT_PHRASE = []
	DUR_BELOW_PERCENT = []

	SEARCH_FROMTO_DURATION_INDEX = 0
	FROM_DURATION_GIVEN = []
	TO_DURATION_GIVEN = []
	DURATION_FROMTO_PERCENT = []
	FROMTO_DURATION_RESULT_PHRASE = []
#---------------------------------------
	SEARCH_ABOVE_VELS_INDEX = 0
	ABOVE_VEL_GIVEN = []
	VELS_ABOVE_PERCENT = []
	ABOVE_VEL_RESULT_PHRASE = []

	SEARCH_BELOW_VELS_INDEX = 0
	BELOW_VEL_GIVEN = []
	VELS_BELOW_PERCENT = []
	BELOW_VEL_RESULT_PHRASE = []

	SEARCH_FROMTO_VEL_INDEX = 0
	FROM_VEL_GIVEN = []
	TO_VEL_GIVEN = []
	VEL_FROMTO_PERCENT = []
	FROMTO_VEL_RESULT_PHRASE = []
#----------------------------------------
	NOTE_OCCURENCE_COUNT = []
	INTERVAL_OCCURENCE_COUNT = []
	DURATION_OCCURENCE_COUNT = []

	NOTE_MOST_OCCURENCE_DONE = 0
	INTERVAL_MOST_OCCURENCE_DONE = 0
	DURATION_MOST_OCCURENCE_DONE = 0

	NOTE_MOST_OCCURENCE_PERCENT = []
	INTERVAL_MOST_OCCURENCE_PERCENT = []
	DURATION_MOST_OCCURENCE_PERCENT = []

	NOTE_OCCURENCE_COUNT_DUR = []
	INTERVAL_OCCURENCE_COUNT_DUR = []
	IOC_I = []
	IOC_C = []

	NOTE_MOST_OCCURENCE_DONE_DUR = 0
	INTERVAL_MOST_OCCURENCE_DONE_DUR = 0

	DOING_ALL = 0
	APP_RES_PH = 0	
	MIX_RES_PH = 0
	BACKUP_RES_PH = ''
#----------------------------------------

	$.w = new window()
	$.inherit($.w)
	$.analyseph= new wphrase()
	$.resultph = new wphrase()

	$.saveb = new kmenubutton("Save","mkmenu_save",$)
	$.loadb = new kmenubutton("Load","mkmenu_load",$)

	$.funct_btn1 = new kmenubutton("MinMax","mkmenu_mm",$)	
	$.funct_btn2 = new kmenubutton("%","mkmenu_percent",$)
	$.funct_btn3 = new kmenubutton("<>","mkmenu_above_below",$)
	$.funct_btn4 = new kmenubutton("Most","mkmenu_most",$)
	$.funct_btn6 = new kmenubutton("Write","mkmenu_writelog",$)

	$.addchild($.saveb)
	$.addchild($.loadb)

	$.addchild($.resultph )
	$.addchild($.analyseph)

	$.addchild($.funct_btn1)
	$.addchild($.funct_btn2)
	$.addchild($.funct_btn3)
	$.addchild($.funct_btn4)
	$.addchild($.funct_btn6)

	$.isset = 0
	$.stoptids = []
}

method redraw {
	$.w.redraw()
	methodbroadcast();
	$.w.text("Statistics",
		xy($.xmin(),$.ymin(),$.xmax(),$.ymin()+$.textheight()+4))
}

method resize(sz) {
	if ( nargs() > 0 )
		$.w.resize(sz)
	usable_top= $.ymin() + $.textheight() + 4
	usable_height=$.ymax()-2-(usable_top)
	height_unit = usable_height / 6

	btn_width = ($.xmax()-$.xmin()-12) / 5
	func_btn1_left = $.xmin()+2
	file_btn_left = func_btn1_left
	func_btn2_left = func_btn1_left + btn_width+2
	func_btn3_left = func_btn2_left + btn_width+2
	func_btn4_left = func_btn3_left + btn_width+2
	func_btn6_left = func_btn4_left + btn_width+2
	
	func_btn1_right = func_btn1_left + btn_width
	func_btn2_right = func_btn2_left + btn_width
	func_btn3_right = func_btn3_left + btn_width
	func_btn4_right = func_btn4_left + btn_width
	func_btn6_right = func_btn6_left + btn_width

	func_btn_height = height_unit
	func_btn_top = usable_top

	file_btn_height = (usable_height-func_btn_height-4)/2
	file_btn_top = usable_top + func_btn_height + 2
	
	ph_wind_left = file_btn_left + (btn_width/1.5) + 2
	ph_wind1_top = file_btn_top
	ph_wind2_top = file_btn_top+file_btn_height+4
	ph_wind_right = $.xmax()-2
	ph_wind1_bottom = file_btn_top+file_btn_height
	ph_wind2_bottom = file_btn_top+(file_btn_height*2)+2

	$.funct_btn1.resize(xy(func_btn1_left,func_btn_top,func_btn1_right,func_btn_top+func_btn_height))
	$.funct_btn2.resize(xy(func_btn2_left,func_btn_top,func_btn2_right,func_btn_top+func_btn_height))
	$.funct_btn3.resize(xy(func_btn3_left,func_btn_top,func_btn3_right,func_btn_top+func_btn_height))
	$.funct_btn4.resize(xy(func_btn4_left,func_btn_top,func_btn4_right,func_btn_top+func_btn_height))
	$.funct_btn6.resize(xy(func_btn6_left,func_btn_top,func_btn6_right,func_btn_top+func_btn_height))

	$.saveb.resize(xy(file_btn_left,file_btn_top,file_btn_left + (btn_width/1.5),file_btn_top+file_btn_height))
	$.loadb.resize(xy(file_btn_left,file_btn_top+file_btn_height+4,file_btn_left + (btn_width/1.5),file_btn_top+(file_btn_height*2)+2))

	$.resultph.resize(xy(ph_wind_left,ph_wind1_top,ph_wind_right,ph_wind1_bottom))
	$.analyseph.resize(xy(ph_wind_left,ph_wind2_top,ph_wind_right,ph_wind2_bottom))
}

method delete {
	killtids($.stoptids)
	$.stoptids = []
}

method set (p,doredraw) {
	p = onlynotes(p)
	$.analyseph.set(p,0)
	$.analyseph.fitall()
	if ( nargs() > 1 && doredraw )
		$.analyseph.redraw()
	$.isset = 0
}

method get {
	p = $.resultph.get()
	p.length = latest(p)
	return(p)
}

method dump {
	return ( [ "phrase" = $.get() ] )
}

method restore (state) { $.set(state["phrase"]) }

#********************************************************************
#		PLAYING
#********************************************************************

method play (stime) {
	if ( $.resultph.isplaying() || $.analyseph.isplaying() )
		$.stop()
	if ( nargs() < 1 ) {
		stime = nextquant(Now,1b)
	}
	tid = $.analyseph.play(stime,1b)
	$.stoptids[tid] = 1
}
method stop {
	killtids($.stoptids)
	$.stoptids = []
	$.resultph.stop()
	$.analyseph.stop()
}
method mousedown (m) {
	if ( $.resultph.contains(m) ) {
		if ( $.resultph.isplaying() || $.analyseph.isplaying() )
			$.stop()
		else {
			tid = $.resultph.play(nextquant(Now,1b))
			$.stoptids[tid] = 1
		}
	}
	else if ( $.analyseph.contains(m) ) {
		if ( $.resultph.isplaying() || $.analyseph.isplaying() )
			$.stop()
		else {
			tid = $.analyseph.play(nextquant(Now,1b))
			$.stoptids[tid] = 1
		}
	}
	else {
		mouseforward(m,"mousedown")
	}
}

#********************************************************************
#			LOADING AND SNARFING
#********************************************************************

method snarf { Snarf = $.get() }
method save_snarf { $.snarf() }

method loadsnarfanalyse {
	if ( sizeof(Snarf) == 0 )
		print("Nothing int the Snarf ?!")
	else {
	FILENAME = "Snarf"
	$.stop()
	ANALYSEPHRASENOTES = 0
	ANALYSEPHRASE = onlynotes(Snarf)
	oph = ANALYSEPHRASE 
	$.set(ANALYSEPHRASE ,1)
	for ( nt in oph ) 
		ANALYSEPHRASENOTES ++
	print ("Number of Notes (in the Snarf): "+string(ANALYSEPHRASENOTES ))
	}
}

method loadfileanalyse {
	$.stop()
	ANALYSEPHRASENOTES = 0
	FILENAME = browsefiles("Midi (*.mid)","*.mid",1)
	if ( FILENAME == "" ) {
		print("No file given.")
		return()
	}
	print("Statistical analysis on : \n" + FILENAME)
	ANALYSEPHRASE = onlynotes(readmf(FILENAME))
	oph = ANALYSEPHRASE 
	if ( sizeof(ANALYSEPHRASE) > 0 )
		$.set(ANALYSEPHRASE,1)
	for ( nt in oph ) 
		ANALYSEPHRASENOTES ++
	print ("Number of Notes : " + string(ANALYSEPHRASENOTES ))
	print("Number of intervals : " + string(ANALYSEPHRASENOTES - 1))
}

method savetomidiresult {
	fname = browsefiles("Midi files (*.mid)","*.mid",1)
	if (sizeof(fname )>0){
		writemf(RESULTPHRASE ,fname )
		print ("Saved to : "+fname )
	}
	else
	print("Saving cancelled")
}

#**************************************************************************************
#			BUILD AND MODIFY RESULT-PHRASE		
#**************************************************************************************

# joint notes in the RESULTPHRASE (like function legato())without changing their lengts)

method joint_result_notes {
	res_ph_notes = 0
	for ( nt in RESULTPHRASE ) 
		res_ph_notes++
	for ( i=2; i<res_ph_notes; i++ )
	  RESULTPHRASE%i.time = RESULTPHRASE%(i-1).time + RESULTPHRASE%(i-1).dur
		$.resultph .set(RESULTPHRASE,0)
		$.resultph .fitall()
		$.resultph .redraw()	
}

method save_legato {
	RESULTPHRASE = legato(RESULTPHRASE)
	$.resultph .set(RESULTPHRASE,0)
	$.resultph .fitall()
	$.resultph .redraw()	
}

method save_mix {
	if (MIX_RES_PH == 0) {
		MIX_RES_PH = 1
		BACKUP_RES_PH = RESULTPHRASE
		print("Mix -> : ON")
	}
	else {
		MIX_RES_PH = 0
		BACKUP_RES_PH = ''
		print("Mix -> : OFF")
	}
}

method save_append {
	if (APP_RES_PH == 0) {
		APP_RES_PH = 1
		BACKUP_RES_PH = RESULTPHRASE
		print("Append-> : ON")
	}
	else {
		APP_RES_PH = 0
		BACKUP_RES_PH = ''
		print("Append-> : OFF")
	}		
}

method save_clear {
	RESULTPHRASE = ''
	$.resultph .set(RESULTPHRASE,0)
	$.resultph .fitall()
	$.resultph .redraw()
}
#line 440
#***********************************************************************************************
# 			ANALYSE METHODS
#			A - GENERAL STATISTICAL
#***********************************************************************************************
#			1-A) PITCHES, DURATIONS, VELOCITIES
#				a) Minimum
#				b) Maximum
#				c) Arithmetic Mean
#				d) Standard Deviation
#-----------------------------------------------------------------------------------------------
#				a) Minimum
#-----------------------------------------------------------------------------------------------
method minpitch(param) {
	if (ANALYSEPHRASE > 0) {
		if (param == "pitch") {
			LOWESTNOTE = lowestnt(ANALYSEPHRASE)
			if (DOING_ALL == 0)
				print("Lowest note = "+ string(LOWESTNOTE) +"(pitch : "+string(lowest(ANALYSEPHRASE))+")")
			RESULTPHRASE =  RESULTPHRASE + LOWESTNOTE
			MIN_PITCH_FOUND = 1
		}
		if (param == "dur" ) {
			SHORTESTNOTE = minduration(ANALYSEPHRASE)
			SHORTESTNOTERHYTHM = get_rhythm(SHORTESTNOTE)
			if (DOING_ALL == 0)
				print("Shortest rhythm = "+ SHORTESTNOTERHYTHM +"(dur. : "+string(SHORTESTNOTE)+")")
			MIN_DUR_FOUND = 1
		}
		if (param == "vel" ) {
			SOFTESTNOTE = minvolume(ANALYSEPHRASE)
			MIN_VEL_FOUND = 1
			if (DOING_ALL == 0)
				print("Softest note = "+string(SOFTESTNOTE))
		}
		if (DOING_ALL == 0) {
			if (APP_RES_PH == 1)
				$.resultph .set (BACKUP_RES_PH + RESULTPHRASE,0)
			if (MIX_RES_PH == 1)
				$.resultph .set(BACKUP_RES_PH | RESULTPHRASE,0)
			else
 				$.resultph .set(RESULTPHRASE,0)
			$.resultph .fitall()
			$.resultph .redraw()
		}
	}
	else
		print(" No phrase loaded for analyse!..")				
}
#-----------------------------------------------------------------------------------------------
#				b) Maximum
#-----------------------------------------------------------------------------------------------
method maxpitch (param){
	if (ANALYSEPHRASE > 0) {
		if (param == "pitch") {
			HIGHESTNOTE = highestnt(ANALYSEPHRASE)
			if (DOING_ALL == 0)
				print("Highest note = "+string(HIGHESTNOTE) +"(pitch : "+string(highest(ANALYSEPHRASE))+")")
			RESULTPHRASE = RESULTPHRASE + HIGHESTNOTE 
			MAX_PITCH_FOUND = 1
		}
		if (param == "dur" ) {
			LONGESTNOTE = maxduration (ANALYSEPHRASE)
			LONGESTNOTERHYTHM = get_rhythm (LONGESTNOTE)
			if (DOING_ALL == 0)
				print("Longest rhythm = "+ LONGESTNOTERHYTHM +"(dur. : "+string(LONGESTNOTE)+")")
			MAX_DUR_FOUND = 1
		}
		if (param == "vel" ) {
			LOUDESTNOTE = maxvolume(ANALYSEPHRASE)
			nuance = get_nuance(LOUDESTNOTE)
			if (DOING_ALL == 0)
				print("Loudest note = "+string(LOUDESTNOTE))
			MAX_VEL_FOUND = 1
		}
		if (DOING_ALL == 0) {
			if (APP_RES_PH == 1)
				$.resultph .set (BACKUP_RES_PH + RESULTPHRASE,0)
			if (MIX_RES_PH == 1)
				$.resultph .set(BACKUP_RES_PH | RESULTPHRASE,0)
			else
 				$.resultph .set(RESULTPHRASE,0)
			$.resultph .fitall()
			$.resultph .redraw()
		}
	}
}
#-----------------------------------------------------------------------------------------------
#				c) Mean
#-----------------------------------------------------------------------------------------------
method arith_mean (param) {
	if (param == "pitch") {
		if ((LOWESTNOTE != '') && (HIGHESTNOTE != '')) {
			MEANNOTE = (LOWESTNOTE.pitch +HIGHESTNOTE.pitch )/2
			if (DOING_ALL == 0)
				print ("Arithmetic mean note : " + string(MEANNOTE))
			mean_dur = (minduration(ANALYSEPHRASE)+maxduration(ANALYSEPHRASE))/2
			MEANNOTE = makenote (MEANNOTE,mean_dur)
			RESULTPHRASE = RESULTPHRASE + MEANNOTE 
			MEAN_PITCH_FOUND = 1
			if (DOING_ALL == 0) {
			if (APP_RES_PH == 1)
				$.resultph .set (BACKUP_RES_PH + RESULTPHRASE,0)
			if (MIX_RES_PH == 1)
				$.resultph .set(BACKUP_RES_PH | RESULTPHRASE,0)
			else
 				$.resultph .set(RESULTPHRASE,0)
				$.resultph .fitall()
				$.resultph .redraw()
			}
		}
	}
	if (param == "dur") {
		if ((SHORTESTNOTE != 0) && (LONGESTNOTE != 0)) {
			MEANDURATION = (SHORTESTNOTE + LONGESTNOTE )/2
			if (DOING_ALL == 0)
				print ("Arithmetic mean duration : " + string(MEANDURATION))
			MEAN_DUR_FOUND = 1
		}
	}
	if (param == "vel") {
		if ((SOFTESTNOTE != '') && (LOUDESTNOTE != '')) {
			MEAN_NOTE_VEL = (SOFTESTNOTE + LOUDESTNOTE)/2
			MEAN_VEL_FOUND = 1
			if (DOING_ALL == 0)
				print ("Arithmetic mean note velocity: " + string(MEAN_NOTE_VEL))
		}
	}
}
#-----------------------------------------------------------------------------------------------
#				d) Standard Deviation
#-----------------------------------------------------------------------------------------------
method stand_dev (param) {
	if (param == "pitch") {
		if ((ANALYSEPHRASE > 0) && (MEANNOTE>0)) {
			sigma = 0
			for ( i=1; i<ANALYSEPHRASENOTES; i++ ) 
				sigma = sigma +( pow((ANALYSEPHRASE%i.pitch - MEANNOTE),2)/(ANALYSEPHRASENOTES-1))
			STANDARDDEV = sqrt(sigma)
			STAND_DEV_PITCH_FOUND = 1
			if (DOING_ALL == 0)
				print ("Note pitches standard deviation : " + string(STANDARDDEV))
		}
	}
	if (param == "dur") {
		if (ANALYSEPHRASE > 0) {
			sigma = 0
			for ( i=1; i<ANALYSEPHRASENOTES; i++ ) 
				sigma = sigma +( pow((ANALYSEPHRASE%i.dur - MEANDURATION ),2)/(ANALYSEPHRASENOTES-1))
			DUR_STANDARDDEV = sqrt(sigma)
			if (DOING_ALL == 0)
				print ("Note duration standard deviation : " + string(DUR_STANDARDDEV))
			STAND_DEV_DUR_FOUND = 1
		}
	}
	if (param == "vel") {
		if ((ANALYSEPHRASE > 0) && (MEAN_NOTE_VEL>0)) {
			sigma = 0
			for ( i=1; i<ANALYSEPHRASENOTES; i++ ) 
				sigma = sigma +( pow((ANALYSEPHRASE%i.vol - MEAN_NOTE_VEL),2)/(ANALYSEPHRASENOTES-1))
			STANDARDDEV_VEL = sqrt(sigma)
			STAND_DEV_VEL_FOUND = 1
			if (DOING_ALL == 0)
				print ("Note velocity standard deviation : " + string(STANDARDDEV_VEL))
		}
	}
}
#***********************************************************************************************
#			1-B) INTERVALS : PITCHES, DURATIONS, TIMINGS
#				a) Minimum
#				b) Maximum
#				c) Arithmetic Mean
#				d) Standard Deviation
#-----------------------------------------------------------------------------------------------
#				a) Minimum
#-----------------------------------------------------------------------------------------------
method min_pitch_interval (param_i) {
	if (param_i=="pitch_i") {
		if ((ANALYSEPHRASE > 0) && (ANALYSEPHRASENOTES>0)){
			for (i=2; i<=ANALYSEPHRASENOTES; i++)
				PINTERVALS[i-1] = ANALYSEPHRASE%i.pitch - ANALYSEPHRASE%(i-1).pitch
			for (i=1; i<=ANALYSEPHRASENOTES-1; i++) 
				if (abs(PINTERVALS[i]) < abs(MIN_MELODIC_INTERVAL))
					MIN_MELODIC_INTERVAL = PINTERVALS[i]
			if (DOING_ALL == 0)
				print ("Minimum melodic interval = " + string(MIN_MELODIC_INTERVAL))
			MIN_PITCH_INT_FOUND = 1
		}
	}
	if (param_i=="dur_i") {
		if ((ANALYSEPHRASE > 0) && (ANALYSEPHRASENOTES>0)){
			for (i=2; i<=ANALYSEPHRASENOTES; i++)
				DINTERVALS[i-1] = ANALYSEPHRASE%i.dur - ANALYSEPHRASE%(i-1).dur
			for (i=1; i<=ANALYSEPHRASENOTES-1; i++) 
				if (abs(DINTERVALS[i]) < abs(MIN_RHYTHMIC_INTERVAL))
					MIN_RHYTHMIC_INTERVAL = DINTERVALS[i]
			if (DOING_ALL == 0)
				print ("Minimum rhythmic interval = "+string(MIN_RHYTHMIC_INTERVAL))
			MIN_DUR_INT_FOUND = 1
		}
	}
	if (param_i=="time_i") {
		if ((ANALYSEPHRASE > 0) && (ANALYSEPHRASENOTES>0)){
			for (i=2; i<=ANALYSEPHRASENOTES; i++)
				TINTERVALS[i-1] = ANALYSEPHRASE%i.time - ANALYSEPHRASE%(i-1).time
			for (i=1; i<=ANALYSEPHRASENOTES-1; i++) 
				if (abs(TINTERVALS[i]) < abs(MIN_TIME_INTERVAL))
					MIN_TIME_INTERVAL = TINTERVALS[i]
			MIN_TIME_INT_FOUND = 1
			if (DOING_ALL == 0)
				print ("Minimum time interval = "+string(MIN_TIME_INTERVAL))
		}
	}
}
#-----------------------------------------------------------------------------------------------
#				b) Maximum
#-----------------------------------------------------------------------------------------------
method max_pitch_interval (param_i) {
	if (param_i=="pitch_i") {
		if (ANALYSEPHRASE > 0) {
			for (i=2; i<=ANALYSEPHRASENOTES; i++)
				PINTERVALS[i-1] = ANALYSEPHRASE%i.pitch - ANALYSEPHRASE%(i-1).pitch
			for (i=1; i<=ANALYSEPHRASENOTES-1; i++) {
				if (abs(PINTERVALS[i]) > abs(MAX_MELODIC_INTERVAL))
					MAX_MELODIC_INTERVAL = PINTERVALS[i] 
			}
			if (DOING_ALL == 0)
				print ("Maximum melodic interval = "+string(MAX_MELODIC_INTERVAL))
			MAX_PITCH_INT_FOUND = 1
		}
	}
	if (param_i=="dur_i") {
		if (ANALYSEPHRASE > 0) {
			for (i=2; i<=ANALYSEPHRASENOTES; i++)
				DINTERVALS[i-1] = ANALYSEPHRASE%i.dur - ANALYSEPHRASE%(i-1).dur
			for (i=1; i<=ANALYSEPHRASENOTES-1; i++) {
				if (abs(DINTERVALS[i]) > abs(MAX_RHYTHMIC_INTERVAL))
					MAX_RHYTHMIC_INTERVAL = DINTERVALS[i] 
			}
			if (DOING_ALL == 0)
				print ("Maximum rhythmic interval = "+string(MAX_RHYTHMIC_INTERVAL))
			MAX_DUR_INT_FOUND = 1
		}
	}
	if (param_i=="time_i") {
		if (ANALYSEPHRASE > 0) {
			for (i=2; i<=ANALYSEPHRASENOTES; i++)
				TINTERVALS[i-1] = ANALYSEPHRASE%i.time - ANALYSEPHRASE%(i-1).time
			for (i=1; i<=ANALYSEPHRASENOTES-1; i++) {
				if (abs(TINTERVALS[i]) > abs(MAX_TIME_INTERVAL))
					MAX_TIME_INTERVAL = TINTERVALS[i] 
			}
			if (DOING_ALL == 0)
				print ("Maximum time interval = "+string(MAX_TIME_INTERVAL))
			MAX_TIME_INT_FOUND = 1
		}
	}
}

#-----------------------------------------------------------------------------------------------
#				c) Mean
#-----------------------------------------------------------------------------------------------
method pitch_int_arith_mean (param_i) {
	if (param_i=="pitch_i") {
		MEAN_PITCH_INTERVAL = (MIN_MELODIC_INTERVAL + MAX_MELODIC_INTERVAL)/2
		if (DOING_ALL == 0)
			print (" Arithmetic mean of pitch intervals : " + string(MEAN_PITCH_INTERVAL))
		MEAN_PITCH_INT_FOUND = 1
	}
	if (param_i=="dur_i") {	
		MEAN_RHYTHMIC_INTERVAL = (MIN_RHYTHMIC_INTERVAL + MAX_RHYTHMIC_INTERVAL)/2
		if (DOING_ALL == 0)
			print (" Arithmetic mean of rhythmic intervals : " + string(MEAN_RHYTHMIC_INTERVAL))
		MEAN_DUR_INT_FOUND = 1
	}
	if (param_i=="time_i") {	
		MEAN_TIME_INTERVAL = (MIN_TIME_INTERVAL + MAX_TIME_INTERVAL)/2
		MEAN_TIME_INT_FOUND = 1
		if (DOING_ALL == 0)
			print (" Arithmetic mean of time intervals : " + string(MEAN_TIME_INTERVAL))
	}			
}
#-----------------------------------------------------------------------------------------------
#				d) Standard Deviation
#-----------------------------------------------------------------------------------------------
method pitch_int_stand_dev (param_i) {
	if (param_i=="pitch_i") {
		if (ANALYSEPHRASE > 0) {
			if (ANALYSEPHRASENOTES == 0) 
				ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
			if (MIN_PITCH_INT_FOUND == 0)
				for (i=2; i<=ANALYSEPHRASENOTES; i++)
					PINTERVALS[i-1] = ANALYSEPHRASE%i.pitch - ANALYSEPHRASE%(i-1).pitch
			if (MEANINTERVAL == 0) {
				sigma_interval = 0
				for (i=1; i<ANALYSEPHRASENOTES-1; i++ )
					sigma_interval += PINTERVALS[i]
				MEANINTERVAL = sigma_interval/(ANALYSEPHRASENOTES-1)
			}
			sigma = 0
			for ( i=1; i<ANALYSEPHRASENOTES-1; i++ ) 
				sigma = sigma +( pow((PINTERVALS[i] - MEANINTERVAL ),2)/(ANALYSEPHRASENOTES-2))
			P_INTERV_STANDARDDEV = sqrt(sigma)
			STAND_DEV__PITCH_INT_FOUND = 1
			if (DOING_ALL == 0)
				print ("Pitch intervals standard deviation : " + string(P_INTERV_STANDARDDEV))
		}
	}
	if (param_i=="dur_i") {
		if (ANALYSEPHRASE > 0) {
			if (ANALYSEPHRASENOTES == 0) 
				ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
			if (MIN_DUR_INT_FOUND == 0)
				for (i=2; i<=ANALYSEPHRASENOTES; i++)
					DINTERVALS[i-1] = ANALYSEPHRASE%i.dur - ANALYSEPHRASE%(i-1).dur
			if (MEAN_RHYTHMIC_INTERVAL == 0) {
				sigma_interval = 0
				for (i=1; i<ANALYSEPHRASENOTES-1; i++ )
					sigma_interval += DINTERVALS[i]
				MEAN_RHYTHMIC_INTERVAL = sigma_interval/(ANALYSEPHRASENOTES-1)
			}
			sigma = 0
			for ( i=1; i<ANALYSEPHRASENOTES-1; i++ ) 
				sigma = sigma +( pow((DINTERVALS[i] - MEAN_RHYTHMIC_INTERVAL ),2)/(ANALYSEPHRASENOTES-2))
			RHYTHMIC_INTERV_STANDARDDEV = sqrt(sigma)
			STAND_DEV_DUR_INT_FOUND = 1
			if (DOING_ALL == 0)
				print ("Rhythm intervals standard deviation : " + string(RHYTHMIC_INTERV_STANDARDDEV))
		}
	}
	if (param_i=="time_i") {
		if (ANALYSEPHRASE > 0) {
			if (ANALYSEPHRASENOTES == 0) 
				ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
			if (MIN_TIME_INT_FOUND == 0)
				for (i=2; i<=ANALYSEPHRASENOTES; i++)
					TINTERVALS[i-1] = ANALYSEPHRASE%i.time - ANALYSEPHRASE%(i-1).time
			if (MEAN_TIME_INTERVAL == 0) {
				sigma_interval = 0
				for (i=1; i<ANALYSEPHRASENOTES-1; i++ )
					sigma_interval += TINTERVALS[i]
				MEAN_TIME_INTERVAL = sigma_interval/(ANALYSEPHRASENOTES-1)
			}
			sigma = 0
			for ( i=1; i<ANALYSEPHRASENOTES-1; i++ ) 
				sigma = sigma +( pow((TINTERVALS[i] - MEAN_TIME_INTERVAL ),2)/(ANALYSEPHRASENOTES-2))
			TIME_INTERV_STANDARDDEV = sqrt(sigma)
			STAND_DEV_TIME_INT_FOUND = 1
			if (DOING_ALL == 0)
				print ("Time intervals standard deviation : " + string(TIME_INTERV_STANDARDDEV))
		}
	}
}
#***********************************************************************************************
#			B - PERCENT ANALYSIS (OCCURENCE)
#***********************************************************************************************
#			a) PERCENT NOTES , INTERVALS , VELOCITIES (OCCURENCE)
#-----------------------------------------------------------------------------------------------
method notes_pitches_percent (param_pc) {
	if (ANALYSEPHRASE > 0) {
		if (ANALYSEPHRASENOTES==0) 
			ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
		percent_ratio = get_percent_ratio (ANALYSEPHRASENOTES )
			if (param_pc == "notes_pc") {
				for (ini=0; ini<=127; ini++) {
					NOTE_OCCURENCE[ini]= 0
					NOTE_OCCURENCE_PERCENT[ini]= 0
				}
			}
			if (param_pc == "vel_pc") {
				for (ini=0; ini<=127; ini++) {
					VEL_OCCURENCE[ini]= 0
					VEL_OCCURENCE_PERCENT[ini]= 0
				}
			}
			if (param_pc == "int_pc") {
				for (ini=-127; ini<=127; ini++) {
					INTERVAL_OCCURENCE[ini]= 0
					INTERVAL_OCCURENCE_PERCENT[ini]= 0
				}
			}
	if (param_pc == "int_pc") {
			for ( i=-127; i<=127; i++ ) {
				interval_search = i
				for (j=2; j<=ANALYSEPHRASENOTES; j++) {
					if (interval_search == ANALYSEPHRASE%j.pitch - ANALYSEPHRASE%(j-1).pitch)
						INTERVAL_OCCURENCE[i]++
				}
			}
		for ( i=-127; i<=127; i++ ) {
			if (INTERVAL_OCCURENCE[i] > 0){
				if (ANALYSEPHRASENOTES>100)
					INTERVAL_OCCURENCE_PERCENT[i] =  INTERVAL_OCCURENCE[i] / percent_ratio 
				else
					INTERVAL_OCCURENCE_PERCENT[i] =  INTERVAL_OCCURENCE[i] * percent_ratio 
			}	
		}
	}
	else {
		for ( i=0; i<=127; i++ ) {
			note_search = i
			for (j=1; j<=ANALYSEPHRASENOTES; j++) {
				if (param_pc == "notes_pc") {				
					if (note_search == ANALYSEPHRASE%j.pitch)
					NOTE_OCCURENCE[i]++
				}
				if (param_pc == "vel_pc") {
					if (note_search == ANALYSEPHRASE%j.vol)
					VEL_OCCURENCE[i]++
				}
			}
		}
		for ( i=0; i<=127; i++ ) {
			if (param_pc == "notes_pc") {			
				if (NOTE_OCCURENCE[i] > 0){
					if (ANALYSEPHRASENOTES>100)
						NOTE_OCCURENCE_PERCENT[i] =  NOTE_OCCURENCE[i] / percent_ratio 
					else
						NOTE_OCCURENCE_PERCENT[i] =  NOTE_OCCURENCE[i] * percent_ratio 
				}
			}
			if (param_pc == "vel_pc") {
				if (VEL_OCCURENCE[i] > 0){
					if (ANALYSEPHRASENOTES>100)
						VEL_OCCURENCE_PERCENT[i] =  VEL_OCCURENCE[i] / percent_ratio 
					else
						VEL_OCCURENCE_PERCENT[i] =  VEL_OCCURENCE[i] * percent_ratio 
				}
			}
		}
	}
		for ( i=0; i<=127; i++ ) {
			if (param_pc == "notes_pc") {
				if (NOTE_OCCURENCE[i] > 0) {
					if (NOTE_OCCURENCE_PERCENT[i]>100) NOTE_OCCURENCE_PERCENT[i] = 100
					if (DOING_ALL == 0)
						print(get_note_name(i) + " (" + string(i)+ ") occured " + string(NOTE_OCCURENCE[i]) + " times. (" + string(NOTE_OCCURENCE_PERCENT[i])+"%)")
					NOTE_OCCURENCE_DONE = 1
				}
			}
			if (param_pc == "vel_pc") {
				if (VEL_OCCURENCE[i] > 0) {
					if (VEL_OCCURENCE_PERCENT[i]>100) VEL_OCCURENCE_PERCENT[i] = 100
					if (DOING_ALL == 0)
						print(get_nuance(i) + " (" + string(i)+ ") occured " + string(VEL_OCCURENCE[i]) + " times. (" + string(VEL_OCCURENCE_PERCENT[i])+"%)")
					VEL_OCCURENCE_DONE = 1
				}
			}
		}
		for ( i=-127; i<=127; i++ ) {		
			if (param_pc == "int_pc") {
				if (abs(INTERVAL_OCCURENCE[i]) > 0) {
					if (INTERVAL_OCCURENCE_PERCENT[i]>100) INTERVAL_OCCURENCE_PERCENT[i] = 100
					if (DOING_ALL == 0)
						print(get_interval_name(i) + " (" + string(i)+ ") occured " + string(INTERVAL_OCCURENCE[i]) + " times. (" + string(INTERVAL_OCCURENCE_PERCENT[i]) +"%)")
					INT_OCCURENCE_DONE = 1
				}
			}
		}
	}
	else
		print(" No phrase loaded for analyse!..")	
}
#-----------------------------------------------------------------------------------
#			1-B) PERCENT DURATIONS (OCCURENCE)
#-----------------------------------------------------------------------------------

method notes_durations_percent {
	if (ANALYSEPHRASE > 0) {
		if (ANALYSEPHRASENOTES==0)
			ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
		shortest_note = minduration(ANALYSEPHRASE)
		LONGEST_NOTE = maxduration(ANALYSEPHRASE)
		percent_ratio = get_percent_ratio (ANALYSEPHRASENOTES )
		if (DOING_ALL == 0)
			print("Initializing variables ..")
		for (ini= 1; ini<=LONGEST_NOTE; ini++)
			DUR_OCCURENCE[ini]= 0
			DUR_OCCURENCE_PERCENT[ini]= 0
		if (DOING_ALL == 0) {
			print(".. variables initialized.")
			print("Counting ..")
		}
		for ( i=shortest_note; i<=LONGEST_NOTE; i++ ) {
			note_search = i
			for (j=1; j<=ANALYSEPHRASENOTES; j++) {
				if (note_search == ANALYSEPHRASE%j.dur)
					DUR_OCCURENCE[i]++
			}
			if (DUR_OCCURENCE[i] > 0){
				if (ANALYSEPHRASENOTES>100)
					DUR_OCCURENCE_PERCENT[i] =  DUR_OCCURENCE[i] / percent_ratio 
				else
					DUR_OCCURENCE_PERCENT[i] =  DUR_OCCURENCE[i] * percent_ratio 

			}
		}
		for ( i=shortest_note; i<=LONGEST_NOTE; i++ ) {
			if (DUR_OCCURENCE[i] > 0) {
				if (DUR_OCCURENCE_PERCENT[i]>100) DUR_OCCURENCE_PERCENT[i] = 100
				rh = get_rhythm(i)
				if (DOING_ALL == 0)
					print(rh + " (dur : " + string(i)+ ") occured " + string(DUR_OCCURENCE[i]) + " times. (" + string(DUR_OCCURENCE_PERCENT[i])+"%)")
				DUR_OCCURENCE_DONE = 1		
			}
		}
	}
	else
		print(" No phrase loaded for analyse!..")										
}

#***********************************************************************************************
#			C - ABOVE-BELOW ANALYSIS
#***********************************************************************************************
#			a) ABOVE NOTES
#--------------------------------------------------------------------------

method above_note (ntstr,octstr) {
	SEARCH_ABOVE_NOTES_INDEX++
	ntstr = "'"+ntstr+octstr+"'"
	ABOVE_NOTE_GIVEN [SEARCH_ABOVE_NOTES_INDEX]= phrase(ntstr)
	if (DOING_ALL == 0)
		print("Searching for notes above : "+string(ntstr))
	ABOVE_NOTE_RESULT_PHRASE [SEARCH_ABOVE_NOTES_INDEX]= ''
	result_phrase_notes = 0
	if (ANALYSEPHRASE > 0) {
		if (ANALYSEPHRASENOTES==0)
			ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
		percent_ratio = get_percent_ratio (ANALYSEPHRASENOTES )
	for (i=1; i<=ANALYSEPHRASENOTES; i++) {
		if (ANALYSEPHRASE%i.pitch >= ABOVE_NOTE_GIVEN[SEARCH_ABOVE_NOTES_INDEX].pitch){
			ABOVE_NOTE_RESULT_PHRASE[SEARCH_ABOVE_NOTES_INDEX] += strip(ANALYSEPHRASE%i)
			result_phrase_notes ++
		}
	}
	if (ABOVE_NOTE_RESULT_PHRASE[SEARCH_ABOVE_NOTES_INDEX] > 0) {
		if (ANALYSEPHRASENOTES>100)
			NOTES_ABOVE_PERCENT[SEARCH_ABOVE_NOTES_INDEX] =  result_phrase_notes / percent_ratio 
		else
			NOTES_ABOVE_PERCENT[SEARCH_ABOVE_NOTES_INDEX] =  result_phrase_notes * percent_ratio 		
		if (result_phrase_notes == ANALYSEPHRASENOTES )
			NOTES_ABOVE_PERCENT[SEARCH_ABOVE_NOTES_INDEX] = 100
		if (DOING_ALL == 0)
			print("Number of notes above (or equal to) " + string(ABOVE_NOTE_GIVEN [SEARCH_ABOVE_NOTES_INDEX]) + "(pitch =" + string(ABOVE_NOTE_GIVEN [SEARCH_ABOVE_NOTES_INDEX].pitch) + ") = " + string(result_phrase_notes) + " (" + string(NOTES_ABOVE_PERCENT[SEARCH_ABOVE_NOTES_INDEX]) + " %)" )
		RESULTPHRASE = ABOVE_NOTE_RESULT_PHRASE[SEARCH_ABOVE_NOTES_INDEX]
		if (DOING_ALL == 0) {
			if (APP_RES_PH == 1)
				$.resultph .set (BACKUP_RES_PH + RESULTPHRASE,0)
			if (MIX_RES_PH == 1)
				$.resultph .set(BACKUP_RES_PH | RESULTPHRASE,0)
			else
 				$.resultph .set(RESULTPHRASE,0)
			$.resultph .fitall()
			$.resultph .redraw()
		}
	}
	else
		if (DOING_ALL == 0)
			print("No notes above (or equal) to " + string(ABOVE_NOTE_GIVEN[SEARCH_ABOVE_NOTES_INDEX]) + "(pitch = " + string(ABOVE_NOTE_GIVEN[SEARCH_ABOVE_NOTES_INDEX].pitch) + ")")
	}
	else
		print(" No phrase loaded for analyse!..")											
}

#--------------------------------------------------------------------------
#			C-2) BELOW NOTES
#--------------------------------------------------------------------------

method below_note (ntstr,octstr) {
	SEARCH_BELOW_NOTES_INDEX++
	ntstr = "'"+ntstr+octstr+"'"
	BELOW_NOTE_GIVEN [SEARCH_BELOW_NOTES_INDEX]= phrase(ntstr)
	if (DOING_ALL == 0)
		print("Searching for notes below : "+string(ntstr))
	BELOW_NOTE_RESULT_PHRASE [SEARCH_BELOW_NOTES_INDEX]= ''
	result_phrase_notes = 0
	if (ANALYSEPHRASE > 0) {
		if (ANALYSEPHRASENOTES==0)
			ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
		percent_ratio = get_percent_ratio (ANALYSEPHRASENOTES )
	for (i=1; i<=ANALYSEPHRASENOTES; i++) {
		if (ANALYSEPHRASE%i.pitch <= BELOW_NOTE_GIVEN[SEARCH_BELOW_NOTES_INDEX].pitch){
			BELOW_NOTE_RESULT_PHRASE[SEARCH_BELOW_NOTES_INDEX] += strip(ANALYSEPHRASE%i)
			result_phrase_notes ++
		}
	}
	if (BELOW_NOTE_RESULT_PHRASE[SEARCH_BELOW_NOTES_INDEX] > 0) {
		if (ANALYSEPHRASENOTES>100)
			NOTES_BELOW_PERCENT[SEARCH_BELOW_NOTES_INDEX] =  result_phrase_notes / percent_ratio 
		else
			NOTES_BELOW_PERCENT[SEARCH_BELOW_NOTES_INDEX] =  result_phrase_notes * percent_ratio 		
		if (result_phrase_notes == ANALYSEPHRASENOTES )
			NOTES_BELOW_PERCENT[SEARCH_BELOW_NOTES_INDEX] = 100
		if (DOING_ALL == 0)
			print("Number of notes below (or equal)" + string(BELOW_NOTE_GIVEN [SEARCH_BELOW_NOTES_INDEX]) + "(pitch =" + string(BELOW_NOTE_GIVEN [SEARCH_BELOW_NOTES_INDEX].pitch) + ") = " + string(result_phrase_notes) + " (" + string(NOTES_BELOW_PERCENT[SEARCH_BELOW_NOTES_INDEX]) + " %)" )
		RESULTPHRASE = BELOW_NOTE_RESULT_PHRASE[SEARCH_BELOW_NOTES_INDEX]
		if (DOING_ALL == 0) {
			if (APP_RES_PH == 1) {
				$.resultph .set (BACKUP_RES_PH + RESULTPHRASE,0)
			}
			if (MIX_RES_PH == 1) {
				$.resultph .set(BACKUP_RES_PH | RESULTPHRASE,0)
			}
			else {
 				$.resultph .set(RESULTPHRASE,0)
			}
			$.resultph .fitall()
			$.resultph .redraw()
		}
	}
	else
		if (DOING_ALL == 0)
			print("No notes below to " + string(BELOW_NOTE_GIVEN[SEARCH_BELOW_NOTES_INDEX]) + "(pitch = " + string(BELOW_NOTE_GIVEN[SEARCH_BELOW_NOTES_INDEX].pitch) + ")")
	}
	else
		print(" No phrase loaded for analyse!..")											
}

#--------------------------------------------------------------------------
#			C-3) NOTES FROM - TO
#--------------------------------------------------------------------------
method ab_pitches_note_from_to {
	SEARCH_FROMTO_NOTES_INDEX++
	getstring_name1 = getastr("Note from (note name)->","") 
	if (getstring_name1== "") {
		x = print_guide ()
		getstring_pitch = getastr("Note from (note pitch)->","") 
		if (getstring_pitch == "") {
			print("Co-2 (pitch = 0) will be the default from note")
			getstring_pitch = 0
		}
		getstring_name1 = get_note_name (integer(getstring_pitch))
	}
	getstring_name2= getastr("Note to (note name)->","") 
	if (getstring_name2== "") {
		print("Co-2 = 0; Co-1 = 12; Mid. C = 60; ")
		getstring_pitch = getastr("Note to (note pitch)->","") 
		if (getstring_pitch == "") {
			print("G8(pitch = 127) will be the default from note")
			getstring_pitch = 127
		}
		getstring_name2 = get_note_name (integer(getstring_pitch))
	}
	FROM_NOTE_GIVEN[SEARCH_FROMTO_NOTES_INDEX] = phrase("'" + getstring_name1 + "'")
	TO_NOTE_GIVEN[SEARCH_FROMTO_NOTES_INDEX] = phrase("'" + getstring_name2 + "'")
	print("Searching for notes from : " + string(FROM_NOTE_GIVEN [SEARCH_FROMTO_NOTES_INDEX]) + "(pitch = " + string(FROM_NOTE_GIVEN[SEARCH_FROMTO_NOTES_INDEX].pitch)+ ") to : " + string(TO_NOTE_GIVEN [SEARCH_FROMTO_NOTES_INDEX]) + "(pitch = " + string(TO_NOTE_GIVEN[SEARCH_FROMTO_NOTES_INDEX].pitch) + ")")
	FROMTO_NOTE_RESULT_PHRASE [SEARCH_FROMTO_NOTES_INDEX]= ''
	result_phrase_notes = 0
	if (ANALYSEPHRASE > 0) {
		if (ANALYSEPHRASENOTES==0)
			ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
		percent_ratio = get_percent_ratio (ANALYSEPHRASENOTES )
		print("Number of notes to be searched: " + string(ANALYSEPHRASENOTES))
	for (i=1; i<=ANALYSEPHRASENOTES; i++) {
		if ((ANALYSEPHRASE%i.pitch >= FROM_NOTE_GIVEN[SEARCH_FROMTO_NOTES_INDEX].pitch) && (ANALYSEPHRASE%i.pitch <= TO_NOTE_GIVEN[SEARCH_FROMTO_NOTES_INDEX].pitch)){
			FROMTO_NOTE_RESULT_PHRASE[SEARCH_FROMTO_NOTES_INDEX] += strip(ANALYSEPHRASE%i)
			result_phrase_notes ++
		}
	}
	if (FROMTO_NOTE_RESULT_PHRASE[SEARCH_FROMTO_NOTES_INDEX] > 0) {
		if (ANALYSEPHRASENOTES>100)
			NOTES_FROMTO_PERCENT[SEARCH_FROMTO_NOTES_INDEX] =  result_phrase_notes / percent_ratio 
		else
			NOTES_FROMTO_PERCENT[SEARCH_FROMTO_NOTES_INDEX] =  result_phrase_notes * percent_ratio 		
		if (result_phrase_notes == ANALYSEPHRASENOTES )
			NOTES_FROMTO_PERCENT[SEARCH_FROMTO_NOTES_INDEX] = 100
		print("Number of notes between : [" + string(FROM_NOTE_GIVEN [SEARCH_FROMTO_NOTES_INDEX]) + "] and [" + string(TO_NOTE_GIVEN [SEARCH_FROMTO_NOTES_INDEX]) + "] = " + string(result_phrase_notes) + " (" + string(NOTES_FROMTO_PERCENT[SEARCH_FROMTO_NOTES_INDEX]) + " %)" )
		RESULTPHRASE = FROMTO_NOTE_RESULT_PHRASE[SEARCH_FROMTO_NOTES_INDEX]
			if (APP_RES_PH == 1)
				$.resultph .set (BACKUP_RES_PH + RESULTPHRASE,0)
			if (MIX_RES_PH == 1)
				$.resultph .set(BACKUP_RES_PH | RESULTPHRASE,0)
			else
 				$.resultph .set(RESULTPHRASE,0)
			$.resultph .fitall()
			$.resultph .redraw()
	}
	else
		print("No notes between : [" + string(FROM_NOTE_GIVEN[SEARCH_FROMTO_NOTES_INDEX]) + "](pitch = " + string(FROM_NOTE_GIVEN[SEARCH_FROMTO_NOTES_INDEX].pitch) + ") and [" + string(TO_NOTE_GIVEN [SEARCH_FROMTO_NOTES_INDEX]) +  "](pitch = " + string(TO_NOTE_GIVEN[SEARCH_FROMTO_NOTES_INDEX].pitch) + ")")
	}
	else
		print(" No phrase loaded for analyse!..")											
}

#--------------------------------------------------------------------------
#			C-4) INTERVALS ABOVE
#--------------------------------------------------------------------------

method above_pitches_intervals (ni) {
	SEARCH_ABOVE_INTERVALS_INDEX++
	if (DOING_ALL == 0)
		absolute = getastr ("Intervals +/- ? (y/n)->","n")
	else
		absolute = "y"
	if (ni == 0)
		ni = integer (getastr("Enter interval in semitones ->","1"))
	ABOVE_INTERVAL_GIVEN [SEARCH_ABOVE_INTERVALS_INDEX] = ni
	if (DOING_ALL == 0)
		print("Searching for intervals above : "+string(ABOVE_INTERVAL_GIVEN [SEARCH_ABOVE_INTERVALS_INDEX]) + " semitones ..")
	ABOVE_INTERVAL_RESULT_PHRASE [SEARCH_ABOVE_INTERVALS_INDEX]= ''
	result_phrase_notes = 0
	if (ANALYSEPHRASE > 0) {
		if (ANALYSEPHRASENOTES==0)
			ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
		percent_ratio = get_percent_ratio (ANALYSEPHRASENOTES )
	for (i=2; i<=ANALYSEPHRASENOTES; i++) {
		if (absolute == "n") {
			if ((ANALYSEPHRASE%i.pitch - ANALYSEPHRASE%(i-1).pitch) >= ABOVE_INTERVAL_GIVEN [SEARCH_ABOVE_INTERVALS_INDEX]) {
				ABOVE_INTERVAL_RESULT_PHRASE[SEARCH_ABOVE_INTERVALS_INDEX] += strip(ANALYSEPHRASE%i)
				result_phrase_notes ++
			}
		}
		if (absolute == "y") {
			if (abs(ANALYSEPHRASE%i.pitch - ANALYSEPHRASE%(i-1).pitch) >= abs(ABOVE_INTERVAL_GIVEN [SEARCH_ABOVE_INTERVALS_INDEX])) {
				ABOVE_INTERVAL_RESULT_PHRASE[SEARCH_ABOVE_INTERVALS_INDEX] += strip(ANALYSEPHRASE%i)
				result_phrase_notes ++
			}
		}
	}
	if (ABOVE_INTERVAL_RESULT_PHRASE[SEARCH_ABOVE_INTERVALS_INDEX] > 0) {
		if (ANALYSEPHRASENOTES>100)
			INTERVAL_ABOVE_PERCENT[SEARCH_ABOVE_INTERVALS_INDEX] =  result_phrase_notes / percent_ratio 
		else
			INTERVAL_ABOVE_PERCENT[SEARCH_ABOVE_INTERVALS_INDEX] =  result_phrase_notes * percent_ratio 		
		if (result_phrase_notes == ANALYSEPHRASENOTES )
			INTERVAL_ABOVE_PERCENT[SEARCH_ABOVE_INTERVALS_INDEX] = 100
		if (DOING_ALL == 0) {
			if (absolute == "n")
				print("Number of intervals above (or equal to) :" + string(ABOVE_INTERVAL_GIVEN [SEARCH_ABOVE_INTERVALS_INDEX]) + " = " +  string(result_phrase_notes) + " (" + string(INTERVAL_ABOVE_PERCENT[SEARCH_ABOVE_INTERVALS_INDEX]) + " %)" )
			if (absolute == "y")
				print("Number of intervals above (or equal to) : +/- " + string(ABOVE_INTERVAL_GIVEN [SEARCH_ABOVE_INTERVALS_INDEX]) + " = " +  string(result_phrase_notes) + " (" + string(INTERVAL_ABOVE_PERCENT[SEARCH_ABOVE_INTERVALS_INDEX]) + " %)" )
		}
		RESULTPHRASE = ABOVE_INTERVAL_RESULT_PHRASE[SEARCH_ABOVE_INTERVALS_INDEX]
		if (DOING_ALL == 0) {
			if (APP_RES_PH == 1)
				$.resultph .set (BACKUP_RES_PH + RESULTPHRASE,0)
			if (MIX_RES_PH == 1)
				$.resultph .set(BACKUP_RES_PH | RESULTPHRASE,0)
			else
 				$.resultph .set(RESULTPHRASE,0)
			$.resultph .fitall()
			$.resultph .redraw()
		}
	}
	else
		if (DOING_ALL == 0)
			print("No intervals above (or equal) to " + string(ABOVE_INTERVAL_GIVEN[SEARCH_ABOVE_INTERVALS_INDEX]) + "(" + string(ABOVE_INTERVAL_GIVEN[SEARCH_ABOVE_INTERVALS_INDEX]) + ")")
	}
	else
		print(" No phrase loaded for analyse!..")											
}

#--------------------------------------------------------------------------
#			C-5) INTERVALS BELOW
#--------------------------------------------------------------------------

method below_pitches_intervals (ni) {
	SEARCH_BELOW_INTERVALS_INDEX++
	if (DOING_ALL == 0)
		absolute = getastr ("Intervals +/- ? (y/n)->","n")
	else
		absolute = "y"
	if (ni == 0)
		ni = integer (getastr("Enter interval in semitones ->","1"))
	BELOW_INTERVAL_GIVEN [SEARCH_BELOW_INTERVALS_INDEX] = ni
	if (DOING_ALL == 0)
		print("Searching for intervals below : "+string(BELOW_INTERVAL_GIVEN [SEARCH_BELOW_INTERVALS_INDEX]) + "semitones ..")
	BELOW_INTERVAL_RESULT_PHRASE [SEARCH_BELOW_INTERVALS_INDEX]= ''
	result_phrase_notes = 0
	if (ANALYSEPHRASE > 0) {
		if (ANALYSEPHRASENOTES==0)
			ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
		percent_ratio = get_percent_ratio (ANALYSEPHRASENOTES )
	for (i=2; i<=ANALYSEPHRASENOTES; i++) {
		if (absolute == "n") {
			if ((ANALYSEPHRASE%i.pitch - ANALYSEPHRASE%(i-1).pitch) <= BELOW_INTERVAL_GIVEN [SEARCH_BELOW_INTERVALS_INDEX]) {
				BELOW_INTERVAL_RESULT_PHRASE[SEARCH_BELOW_INTERVALS_INDEX] += strip(ANALYSEPHRASE%i)
				result_phrase_notes ++
			}
		}
		if (absolute == "y") {
			if (abs(ANALYSEPHRASE%i.pitch - ANALYSEPHRASE%(i-1).pitch) <= abs(BELOW_INTERVAL_GIVEN [SEARCH_BELOW_INTERVALS_INDEX])) {
				BELOW_INTERVAL_RESULT_PHRASE[SEARCH_BELOW_INTERVALS_INDEX] += strip(ANALYSEPHRASE%i)
				result_phrase_notes ++
			}
		}
	}
	if (BELOW_INTERVAL_RESULT_PHRASE[SEARCH_BELOW_INTERVALS_INDEX] > 0) {
		if (ANALYSEPHRASENOTES>100)
			INTERVAL_BELOW_PERCENT[SEARCH_BELOW_INTERVALS_INDEX] =  result_phrase_notes / percent_ratio 
		else
			INTERVAL_BELOW_PERCENT[SEARCH_BELOW_INTERVALS_INDEX] =  result_phrase_notes * percent_ratio 		
		if (result_phrase_notes == ANALYSEPHRASENOTES )
			INTERVAL_BELOW_PERCENT[SEARCH_BELOW_INTERVALS_INDEX] = 100
		if (DOING_ALL == 0) {
			if (absolute == "n")
				print("Number of intervals below (or equal to) :" + string(BELOW_INTERVAL_GIVEN [SEARCH_BELOW_INTERVALS_INDEX]) + " = " +  string(result_phrase_notes) + " (" + string(INTERVAL_BELOW_PERCENT[SEARCH_BELOW_INTERVALS_INDEX]) + " %)" )
			if (absolute == "y")
				print("Number of intervals below (or equal to) : +/- " + string(BELOW_INTERVAL_GIVEN [SEARCH_BELOW_INTERVALS_INDEX]) + " = " +  string(result_phrase_notes) + " (" + string(INTERVAL_BELOW_PERCENT[SEARCH_BELOW_INTERVALS_INDEX]) + " %)" )
		}
		RESULTPHRASE = BELOW_INTERVAL_RESULT_PHRASE[SEARCH_BELOW_INTERVALS_INDEX]
		if (DOING_ALL == 0) {
			if (APP_RES_PH == 1)
				$.resultph .set (BACKUP_RES_PH + RESULTPHRASE,0)
			if (MIX_RES_PH == 1)
				$.resultph .set(BACKUP_RES_PH | RESULTPHRASE,0)
			else
 				$.resultph .set(RESULTPHRASE,0)
			$.resultph .fitall()
			$.resultph .redraw()
		}
	}
	else
		if (DOING_ALL == 0)
			print("No intervals below (or equal) to " + string(BELOW_INTERVAL_GIVEN[SEARCH_BELOW_INTERVALS_INDEX]) + "(" + string(BELOW_INTERVAL_GIVEN[SEARCH_BELOW_INTERVALS_INDEX]) + ")")
	}
	else
		print(" No phrase loaded for analyse!..")											
}

#--------------------------------------------------------------------------
#			C-6) INTERVALS FROM - TO
#--------------------------------------------------------------------------

method ab_pitches_intervals_from_to {
	SEARCH_FROMTO_INTERVALS_INDEX++
	getstring_name1 = getastr("Interval from (semitones)->","0") 
	if (getstring_name1== "0") 
		print("Default interval from : 1")
	getstring_name2= getastr("Interval to (semitones)->","0") 
	if (getstring_name2== "0") 
		print("Default interval to : 12")
	FROM_INTERVAL_GIVEN[SEARCH_FROMTO_INTERVALS_INDEX] = getstring_name1 
	TO_INTERVAL_GIVEN[SEARCH_FROMTO_INTERVALS_INDEX] = getstring_name2
	print("Searching for intervals from : " + string(FROM_INTERVAL_GIVEN [SEARCH_FROMTO_INTERVALS_INDEX]) + " to : " + string(TO_INTERVAL_GIVEN [SEARCH_FROMTO_INTERVALS_INDEX]))
	FROMTO_INTERVAL_RESULT_PHRASE [SEARCH_FROMTO_INTERVALS_INDEX]= ''
	result_phrase_notes = 0
	if (ANALYSEPHRASE > 0) {
		if (ANALYSEPHRASENOTES==0)
			ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
		percent_ratio = get_percent_ratio (ANALYSEPHRASENOTES )
	for (i=2; i<=ANALYSEPHRASENOTES; i++) {
		orig_int = ANALYSEPHRASE%i.pitch - ANALYSEPHRASE%(i-1).pitch
		if ( (orig_int >= FROM_INTERVAL_GIVEN[SEARCH_FROMTO_INTERVALS_INDEX]) && (orig_int <= TO_INTERVAL_GIVEN[SEARCH_FROMTO_INTERVALS_INDEX])) {
			FROMTO_INTERVAL_RESULT_PHRASE[SEARCH_FROMTO_INTERVALS_INDEX] += strip(ANALYSEPHRASE%i)
			result_phrase_notes ++
		}
	}
	if (FROMTO_INTERVAL_RESULT_PHRASE[SEARCH_FROMTO_INTERVALS_INDEX] >0 ) {
		if (ANALYSEPHRASENOTES>100)
			INTERVAL_FROMTO_PERCENT[SEARCH_FROMTO_INTERVALS_INDEX] =  result_phrase_notes / percent_ratio 
		else
			INTERVAL_FROMTO_PERCENT[SEARCH_FROMTO_INTERVALS_INDEX] =  result_phrase_notes * percent_ratio 		
		if (result_phrase_notes == ANALYSEPHRASENOTES )
			INTERVAL_FROMTO_PERCENT[SEARCH_FROMTO_INTERVALS_INDEX] = 100
		print("Number of notes with intervals between : [" + string(FROM_INTERVAL_GIVEN [SEARCH_FROMTO_INTERVALS_INDEX]) + "] and [" + string(TO_INTERVAL_GIVEN [SEARCH_FROMTO_INTERVALS_INDEX]) + "] = " + string(result_phrase_notes) + " (" + string(INTERVAL_FROMTO_PERCENT[SEARCH_FROMTO_INTERVALS_INDEX]) + " %)" )
		RESULTPHRASE = FROMTO_INTERVAL_RESULT_PHRASE[SEARCH_FROMTO_INTERVALS_INDEX]
			if (APP_RES_PH == 1)
				$.resultph .set (BACKUP_RES_PH + RESULTPHRASE,0)
			if (MIX_RES_PH == 1)
				$.resultph .set(BACKUP_RES_PH | RESULTPHRASE,0)
			else
 				$.resultph .set(RESULTPHRASE,0)
			$.resultph .fitall()
			$.resultph .redraw()
	}
	else
		print("No intervals between : [" + string(FROM_INTERVAL_GIVEN[SEARCH_FROMTO_INTERVALS_INDEX]) + "] and [" + string(TO_INTERVAL_GIVEN [SEARCH_FROMTO_INTERVALS_INDEX]) +  "]")
	}
	else
		print(" No phrase loaded for analyse!..")											
}

#--------------------------------------------------------------------------
#			C-7) DURATIONS ABOVE
#--------------------------------------------------------------------------

method above_dur (d) {
	SEARCH_ABOVE_DURS_INDEX++
	if (d == 0)
		d = integer (getastr("Duration in clicks (q = 96) ->","1"))
	ABOVE_DUR_GIVEN [SEARCH_ABOVE_DURS_INDEX] = d
	if (DOING_ALL == 0)
		print("Searching for durations above : "+string(ABOVE_DUR_GIVEN [SEARCH_ABOVE_DURS_INDEX]) + " clicks ..")
	ABOVE_DUR_RESULT_PHRASE [SEARCH_ABOVE_DURS_INDEX]= ''
	result_phrase_notes = 0
	if (ANALYSEPHRASE > 0) {
		if (ANALYSEPHRASENOTES==0)
			ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
		percent_ratio = get_percent_ratio (ANALYSEPHRASENOTES )
	for (i=1; i<=ANALYSEPHRASENOTES; i++) {
		if (ANALYSEPHRASE%i.dur >= ABOVE_DUR_GIVEN [SEARCH_ABOVE_DURS_INDEX]) {
			ABOVE_DUR_RESULT_PHRASE[SEARCH_ABOVE_DURS_INDEX] += strip(ANALYSEPHRASE%i)
			result_phrase_notes ++
			}
	}
	if (ABOVE_DUR_RESULT_PHRASE[SEARCH_ABOVE_DURS_INDEX] > 0) {
		if (ANALYSEPHRASENOTES>100)
			DUR_ABOVE_PERCENT[SEARCH_ABOVE_DURS_INDEX] =  result_phrase_notes / percent_ratio 
		else
			DUR_ABOVE_PERCENT[SEARCH_ABOVE_DURS_INDEX] =  result_phrase_notes * percent_ratio 		
		if (result_phrase_notes == ANALYSEPHRASENOTES )
			DUR_ABOVE_PERCENT[SEARCH_ABOVE_DURS_INDEX] = 100
		if (DOING_ALL == 0)
			print("Number of durations above (or equal to) :" + string(ABOVE_DUR_GIVEN [SEARCH_ABOVE_DURS_INDEX]) + " = " +  string(result_phrase_notes) + " (" + string(DUR_ABOVE_PERCENT[SEARCH_ABOVE_DURS_INDEX]) + " %)" )
		RESULTPHRASE = ABOVE_DUR_RESULT_PHRASE[SEARCH_ABOVE_DURS_INDEX]
		if (DOING_ALL == 0) {
			if (APP_RES_PH == 1)
				$.resultph .set (BACKUP_RES_PH + RESULTPHRASE,0)
			if (MIX_RES_PH == 1)
				$.resultph .set(BACKUP_RES_PH | RESULTPHRASE,0)
			else
 				$.resultph .set(RESULTPHRASE,0)
			$.resultph .fitall()
			$.resultph .redraw()
		}
	}
	else
		if (DOING_ALL == 0)
			print("No durations above (or equal) to " + string(ABOVE_DUR_GIVEN[SEARCH_ABOVE_DURS_INDEX]) + "(" + string(ABOVE_DUR_GIVEN[SEARCH_ABOVE_DURS_INDEX]) + ")")
	}
	else
		print(" No phrase loaded for analyse!..")											
}

#--------------------------------------------------------------------------
#			C-8) DURATIONS BELOW
#--------------------------------------------------------------------------

method below_dur (d) {
	SEARCH_BELOW_DURS_INDEX++
	if (d == 0)
		d = integer (getastr("Duration in clicks (q = 96) ->","1"))
	BELOW_DUR_GIVEN [SEARCH_BELOW_DURS_INDEX] = d
	if (DOING_ALL == 0)
 		print("Searching for durations below : "+string(BELOW_DUR_GIVEN [SEARCH_BELOW_DURS_INDEX]) + " clicks ..")
	BELOW_DUR_RESULT_PHRASE [SEARCH_BELOW_DURS_INDEX]= ''
	result_phrase_notes = 0
	if (ANALYSEPHRASE > 0) {
		if (ANALYSEPHRASENOTES==0)
			ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
		percent_ratio = get_percent_ratio (ANALYSEPHRASENOTES )
	for (i=1; i<=ANALYSEPHRASENOTES; i++) {
		if (ANALYSEPHRASE%i.dur <= BELOW_DUR_GIVEN [SEARCH_BELOW_DURS_INDEX]) {
			BELOW_DUR_RESULT_PHRASE[SEARCH_BELOW_DURS_INDEX] += strip(ANALYSEPHRASE%i)
			result_phrase_notes ++
			}
	}
	if (BELOW_DUR_RESULT_PHRASE[SEARCH_BELOW_DURS_INDEX] > 0) {
		if (ANALYSEPHRASENOTES>100)
			DUR_BELOW_PERCENT[SEARCH_BELOW_DURS_INDEX] =  result_phrase_notes / percent_ratio 
		else
			DUR_BELOW_PERCENT[SEARCH_BELOW_DURS_INDEX] =  result_phrase_notes * percent_ratio 		
		if (result_phrase_notes == ANALYSEPHRASENOTES )
			DUR_BELOW_PERCENT[SEARCH_BELOW_DURS_INDEX] = 100
		if (DOING_ALL == 0)
			print("Number of durations below (or equal to) :" + string(BELOW_DUR_GIVEN [SEARCH_BELOW_DURS_INDEX]) + " = " +  string(result_phrase_notes) + " (" + string(DUR_BELOW_PERCENT[SEARCH_BELOW_DURS_INDEX]) + " %)" )
		RESULTPHRASE = BELOW_DUR_RESULT_PHRASE[SEARCH_BELOW_DURS_INDEX]
		if (DOING_ALL == 0) {
			if (APP_RES_PH == 1)
				$.resultph .set (BACKUP_RES_PH + RESULTPHRASE,0)
			if (MIX_RES_PH == 1)
				$.resultph .set(BACKUP_RES_PH | RESULTPHRASE,0)
			else
 				$.resultph .set(RESULTPHRASE,0)
			$.resultph .fitall()
			$.resultph .redraw()
		}
	}
	else
		if (DOING_ALL == 0)
			print("No durations below (or equal) to " + string(BELOW_DUR_GIVEN[SEARCH_BELOW_DURS_INDEX]) + "(" + string(BELOW_DUR_GIVEN[SEARCH_BELOW_DURS_INDEX]) + ")")
	}
	else
		print(" No phrase loaded for analyse!..")											
}

#--------------------------------------------------------------------------
#			C-9) DURATIONS FROM - TO
#--------------------------------------------------------------------------

method ab_dur_from_to {
	SEARCH_FROMTO_DURATION_INDEX++
	get_dur_from = integer(getastr("Duration from (clicks)->","0"))
	get_dur_to= integer(getastr("Duration to (clicks)->","384")) 
	FROM_DURATION_GIVEN[SEARCH_FROMTO_DURATION_INDEX] = get_dur_from
	TO_DURATION_GIVEN[SEARCH_FROMTO_DURATION_INDEX] = get_dur_to
	print("Searching for durations from : " + string(FROM_DURATION_GIVEN [SEARCH_FROMTO_DURATION_INDEX]) + " to : " + string(TO_DURATION_GIVEN [SEARCH_FROMTO_DURATION_INDEX]))
	FROMTO_DURATION_RESULT_PHRASE [SEARCH_FROMTO_DURATION_INDEX]= ''
	result_phrase_notes = 0
	if (ANALYSEPHRASE > 0) {
		if (ANALYSEPHRASENOTES==0)
			ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
		percent_ratio = get_percent_ratio (ANALYSEPHRASENOTES )
		print("Number of notes to be searched: " + string(ANALYSEPHRASENOTES))
	for (i=1; i<=ANALYSEPHRASENOTES; i++) {
		if ((ANALYSEPHRASE%i.dur >= FROM_DURATION_GIVEN[SEARCH_FROMTO_DURATION_INDEX]) && (ANALYSEPHRASE%i.dur <= TO_DURATION_GIVEN[SEARCH_FROMTO_DURATION_INDEX])) {
			FROMTO_DURATION_RESULT_PHRASE[SEARCH_FROMTO_DURATION_INDEX] += strip(ANALYSEPHRASE%i)
			result_phrase_notes ++
		}
	}
	if (FROMTO_DURATION_RESULT_PHRASE[SEARCH_FROMTO_DURATION_INDEX] > 0) {
		if (ANALYSEPHRASENOTES>100)
			DURATION_FROMTO_PERCENT[SEARCH_FROMTO_DURATION_INDEX] =  result_phrase_notes / percent_ratio 
		else
			DURATION_FROMTO_PERCENT[SEARCH_FROMTO_DURATION_INDEX] =  result_phrase_notes * percent_ratio 		
		if (result_phrase_notes == ANALYSEPHRASENOTES )
			DURATION_FROMTO_PERCENT[SEARCH_FROMTO_DURATION_INDEX] = 100
		print("Number of durations between : [" + string(FROM_DURATION_GIVEN [SEARCH_FROMTO_DURATION_INDEX]) + "] and [" + string(TO_DURATION_GIVEN [SEARCH_FROMTO_DURATION_INDEX]) + "] = " + string(result_phrase_notes) + " (" + string(DURATION_FROMTO_PERCENT[SEARCH_FROMTO_DURATION_INDEX]) + " %)" )
		RESULTPHRASE = FROMTO_DURATION_RESULT_PHRASE[SEARCH_FROMTO_DURATION_INDEX]
			if (APP_RES_PH == 1)
				$.resultph .set (BACKUP_RES_PH + RESULTPHRASE,0)
			if (MIX_RES_PH == 1)
				$.resultph .set(BACKUP_RES_PH | RESULTPHRASE,0)
			else
 				$.resultph .set(RESULTPHRASE,0)
			$.resultph .fitall()
			$.resultph .redraw()
	}
	else
		print("No durations between : [" + string(FROM_DURATION_GIVEN[SEARCH_FROMTO_DURATION_INDEX]) + "] and [" + string(TO_DURATION_GIVEN [SEARCH_FROMTO_DURATION_INDEX]) +  "]")
	}
	else
		print(" No phrase loaded for analyse!..")											
}

#--------------------------------------------------------------------------
#			C-10) ABOVE VELOCITIES
#--------------------------------------------------------------------------

method above_vel (v) {
	SEARCH_ABOVE_VELS_INDEX++
	ABOVE_VEL_GIVEN [SEARCH_ABOVE_VELS_INDEX] = v
	if (DOING_ALL == 0)
		print("Searching for velocities above : "+string(ABOVE_VEL_GIVEN [SEARCH_ABOVE_VELS_INDEX]))
	ABOVE_VEL_RESULT_PHRASE [SEARCH_ABOVE_VELS_INDEX]= ''
	result_phrase_notes = 0
	if (ANALYSEPHRASE > 0) {
		if (ANALYSEPHRASENOTES==0)
			ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
		percent_ratio = get_percent_ratio (ANALYSEPHRASENOTES )
	for (i=1; i<=ANALYSEPHRASENOTES; i++) {
		if (ANALYSEPHRASE%i.vol >= ABOVE_VEL_GIVEN[SEARCH_ABOVE_VELS_INDEX]){
			ABOVE_VEL_RESULT_PHRASE[SEARCH_ABOVE_VELS_INDEX] += strip(ANALYSEPHRASE%i)
			result_phrase_notes ++
		}
	}
	if (ABOVE_VEL_RESULT_PHRASE[SEARCH_ABOVE_VELS_INDEX] > 0) {
		if (ANALYSEPHRASENOTES>100)
			VELS_ABOVE_PERCENT[SEARCH_ABOVE_VELS_INDEX] =  result_phrase_notes / percent_ratio 
		else
			VELS_ABOVE_PERCENT[SEARCH_ABOVE_VELS_INDEX] =  result_phrase_notes * percent_ratio 		
		if (result_phrase_notes == ANALYSEPHRASENOTES )
			VELS_ABOVE_PERCENT[SEARCH_ABOVE_VELS_INDEX] = 100
		if (DOING_ALL == 0)
			print("Number of velocities above (or equal to) " + string(ABOVE_VEL_GIVEN [SEARCH_ABOVE_VELS_INDEX]) + " = " + string(result_phrase_notes) + " (" + string(VELS_ABOVE_PERCENT[SEARCH_ABOVE_VELS_INDEX]) + "%)" )
		RESULTPHRASE = ABOVE_VEL_RESULT_PHRASE[SEARCH_ABOVE_VELS_INDEX]
		if (DOING_ALL == 0) {
			if (APP_RES_PH == 1)
				$.resultph .set (BACKUP_RES_PH + RESULTPHRASE,0)
			if (MIX_RES_PH == 1)
				$.resultph .set(BACKUP_RES_PH | RESULTPHRASE,0)
			else
 				$.resultph .set(RESULTPHRASE,0)
			$.resultph .fitall()
			$.resultph .redraw()
		}
	}
	else
		if (DOING_ALL == 0)
			print("No velocities above (or equal) to " + string(ABOVE_VEL_GIVEN[SEARCH_ABOVE_VELS_INDEX]) )
	}
	else
		print(" No phrase loaded for analyse!..")											
}

#--------------------------------------------------------------------------
#			C-11) BELOW VELOCITIES
#--------------------------------------------------------------------------

method below_vel (v) {
	SEARCH_BELOW_VELS_INDEX ++
	BELOW_VEL_GIVEN [SEARCH_BELOW_VELS_INDEX] = v
	if (DOING_ALL == 0)
		print("Searching for velocities below: " + string(BELOW_VEL_GIVEN [SEARCH_BELOW_VELS_INDEX]))
	BELOW_VEL_RESULT_PHRASE [SEARCH_BELOW_VELS_INDEX]= ''
	result_phrase_notes = 0
	if (ANALYSEPHRASE > 0) {
		if (ANALYSEPHRASENOTES==0) 
			ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
	percent_ratio = get_percent_ratio (ANALYSEPHRASENOTES )
	for (i=1; i<=ANALYSEPHRASENOTES; i++) {
		if (ANALYSEPHRASE%i.vol <= BELOW_VEL_GIVEN[SEARCH_BELOW_VELS_INDEX]){
			BELOW_VEL_RESULT_PHRASE[SEARCH_BELOW_VELS_INDEX] += strip(ANALYSEPHRASE%i)
			result_phrase_notes ++
		}
	}
	if (BELOW_VEL_RESULT_PHRASE[SEARCH_BELOW_VELS_INDEX] > 0) {
		if (ANALYSEPHRASENOTES>100)
			VELS_BELOW_PERCENT[SEARCH_BELOW_VELS_INDEX] =  result_phrase_notes / percent_ratio 
		else
			VELS_BELOW_PERCENT[SEARCH_BELOW_VELS_INDEX] =  result_phrase_notes * percent_ratio 		
		if (result_phrase_notes == ANALYSEPHRASENOTES )
			VELS_BELOW_PERCENT[SEARCH_BELOW_VELS_INDEX] = 100
		if (DOING_ALL == 0)
			print("Number of velocities below(or equal to) " + string(BELOW_VEL_GIVEN [SEARCH_BELOW_VELS_INDEX]) + " = " + string(result_phrase_notes) + " (" + string(VELS_BELOW_PERCENT[SEARCH_BELOW_VELS_INDEX]) + "%)" )
		RESULTPHRASE = BELOW_VEL_RESULT_PHRASE[SEARCH_BELOW_VELS_INDEX]
		if (DOING_ALL == 0) {
			if (APP_RES_PH == 1)
				$.resultph .set (BACKUP_RES_PH + RESULTPHRASE,0)
			if (MIX_RES_PH == 1)
				$.resultph .set(BACKUP_RES_PH | RESULTPHRASE,0)
			else
 				$.resultph .set(RESULTPHRASE,0)
			$.resultph .fitall()
			$.resultph .redraw()
		}
	}
	else
		if (DOING_ALL == 0)
			print("No velocities below(or equal) to " + string(BELOW_VEL_GIVEN[SEARCH_BELOW_VELS_INDEX]) )
	}
	else
		print(" No phrase loaded for analyse!..")											
}

#--------------------------------------------------------------------------
#			C-12) VELOCITIES FROM - TO
#--------------------------------------------------------------------------
method ab_vel_from_to {
	SEARCH_FROMTO_VEL_INDEX++
	get_vel_from = integer(getastr("Velocities from (0-127)->","0"))
	get_vel_to= integer(getastr("Velocities to (0-127)->","127")) 
	FROM_VEL_GIVEN[SEARCH_FROMTO_VEL_INDEX] = get_vel_from
	TO_VEL_GIVEN[SEARCH_FROMTO_VEL_INDEX] = get_vel_to
	print("Searching for velocities from : " + string(FROM_VEL_GIVEN [SEARCH_FROMTO_VEL_INDEX]) + " to : " + string(TO_VEL_GIVEN [SEARCH_FROMTO_VEL_INDEX]))
	FROMTO_VEL_RESULT_PHRASE [SEARCH_FROMTO_VEL_INDEX]= ''
	result_phrase_notes = 0
	if (ANALYSEPHRASE > 0) {
		if (ANALYSEPHRASENOTES==0)
			ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
		percent_ratio = get_percent_ratio (ANALYSEPHRASENOTES )
		print("Number of notes to be searched: " + string(ANALYSEPHRASENOTES))
	for (i=1; i<=ANALYSEPHRASENOTES; i++) {
		if ((ANALYSEPHRASE%i.vol>= FROM_VEL_GIVEN[SEARCH_FROMTO_VEL_INDEX]) && (ANALYSEPHRASE%i.vol<= TO_VEL_GIVEN[SEARCH_FROMTO_VEL_INDEX])) {
			FROMTO_VEL_RESULT_PHRASE[SEARCH_FROMTO_VEL_INDEX] += strip(ANALYSEPHRASE%i)
			result_phrase_notes ++
		}
	}
	if (FROMTO_VEL_RESULT_PHRASE[SEARCH_FROMTO_VEL_INDEX] > 0) {
		if (ANALYSEPHRASENOTES>100)
			VEL_FROMTO_PERCENT[SEARCH_FROMTO_VEL_INDEX] =  result_phrase_notes / percent_ratio 
		else
			VEL_FROMTO_PERCENT[SEARCH_FROMTO_VEL_INDEX] =  result_phrase_notes * percent_ratio 		
		if (result_phrase_notes == ANALYSEPHRASENOTES )
			VEL_FROMTO_PERCENT[SEARCH_FROMTO_VEL_INDEX] = 100
		print("Number of velocities between : [" + string(FROM_VEL_GIVEN [SEARCH_FROMTO_VEL_INDEX]) + "] and [" + string(TO_VEL_GIVEN [SEARCH_FROMTO_VEL_INDEX]) + "] = " + string(result_phrase_notes) + " (" + string(VEL_FROMTO_PERCENT[SEARCH_FROMTO_VEL_INDEX]) + " %)" )
		RESULTPHRASE = FROMTO_VEL_RESULT_PHRASE[SEARCH_FROMTO_VEL_INDEX]
			if (APP_RES_PH == 1)
				$.resultph .set (BACKUP_RES_PH + RESULTPHRASE,0)
			if (MIX_RES_PH == 1)
				$.resultph .set(BACKUP_RES_PH | RESULTPHRASE,0)
			else
 				$.resultph .set(RESULTPHRASE,0)
			$.resultph .fitall()
			$.resultph .redraw()
	}
	else
		print("No velocities between : [" + string(FROM_VEL_GIVEN[SEARCH_FROMTO_VEL_INDEX]) + "] and [" + string(TO_VEL_GIVEN [SEARCH_FROMTO_VEL_INDEX]) +  "]")
	}
	else
		print(" No phrase loaded for analyse!..")											
}
#***********************************************************************************************
#			D - MOSTLY OCCURING NOTES, INTERVALS, DURATIONS
#***********************************************************************************************
#			a) BY ATTACKS NUMBER
#--------------------------------------------------------------------------
method most_attacks (param1) {
	if (ANALYSEPHRASE > 0) {
		if (ANALYSEPHRASENOTES == 0)
			ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
			percent_ratio = get_percent_ratio (ANALYSEPHRASENOTES)
			if (param1 == "pitch") {
				for (ini = 0; ini <= 127; ini++) 
					NOTE_OCCURENCE_COUNT[ini] = 0
			}
			if (param1 == "int") {
				for (ini = -127; ini <= 127; ini++) 
					INTERVAL_OCCURENCE_COUNT[ini] = 0
			}
			if (param1 == "dur") {
				for (ini = 0; ini <= (maxduration (ANALYSEPHRASE)); ini++) 
					DURATION_OCCURENCE_COUNT[ini] = 0
			}
			if (param1 != "dur") {
				if (param1 == "pitch") {
					for (p = 0; p <= 127; p++) {
						for (notes=1; notes <= ANALYSEPHRASENOTES; notes++) 
							if (p == ANALYSEPHRASE%notes.pitch) 
								NOTE_OCCURENCE_COUNT[p]++
					}
				}
				if (param1 == "int") {
					for (p = -127; p <= 127; p++) {
						for (notes = 2; notes <= ANALYSEPHRASENOTES; notes++) 
							if (p == (ANALYSEPHRASE%(notes).pitch - ANALYSEPHRASE%(notes-1).pitch)) 
								INTERVAL_OCCURENCE_COUNT[p]++
					}
				}
				if (param1 == "pitch") {
					for (n = 0; n <= 127; n++) {
						if (ANALYSEPHRASENOTES>100)
							NOTE_MOST_OCCURENCE_PERCENT[n] =  NOTE_OCCURENCE_COUNT[n] / percent_ratio 
						else
							NOTE_MOST_OCCURENCE_PERCENT[n] =  NOTE_OCCURENCE_COUNT[n] * percent_ratio 
					}
				}
				if (param1 == "int") {
					for (n = -127; n <= 127; n++) {
						if (ANALYSEPHRASENOTES>100)
							INTERVAL_MOST_OCCURENCE_PERCENT[n] =  INTERVAL_OCCURENCE_COUNT[n] / percent_ratio 
						else
							INTERVAL_MOST_OCCURENCE_PERCENT[n] =  INTERVAL_OCCURENCE_COUNT[n] * percent_ratio 
					}
				}
				if (param1 == "pitch")
					NOTE_MOST_OCCURENCE_DONE = 1
				if (param1 == "int")
					INTERVAL_MOST_OCCURENCE_DONE = 1
			}
			if (param1 == "dur") {
				LONGEST_NOTE = maxduration(ANALYSEPHRASE)
				for (p = 1; p <= LONGEST_NOTE; p++) {
					for (notes=1; notes <= ANALYSEPHRASENOTES; notes++) 
						if (p == ANALYSEPHRASE%notes.dur) 
							DURATION_OCCURENCE_COUNT[p]++
				}
				for (n = 1; n <= LONGEST_NOTE; n++) {
						if (ANALYSEPHRASENOTES > 100)
							DURATION_MOST_OCCURENCE_PERCENT[n] =  DURATION_OCCURENCE_COUNT[n] / percent_ratio 
						else
							DURATION_MOST_OCCURENCE_PERCENT[n] =  DURATION_OCCURENCE_COUNT[n] * percent_ratio 
				}	
				DURATION_MOST_OCCURENCE_DONE = 1
			}
#------------------
#	Printing ..
		if (NOTE_MOST_OCCURENCE_DONE == 1) {
			for (i = 0; i <= 127; i++)
				if (NOTE_OCCURENCE_COUNT[i] >0 )
					print(get_note_name (i) + " (" + string(i) + ")" +  " occured : " + string(NOTE_OCCURENCE_COUNT[i]) + " times -> " + string(NOTE_MOST_OCCURENCE_PERCENT[i]) + "%")
		}
		if (INTERVAL_MOST_OCCURENCE_DONE == 1) {
			for (i = -127; i <= 127; i++)
				if (INTERVAL_OCCURENCE_COUNT[i] >0 )
					print(get_interval_name (i) + " (" + string(i) + ")" +  " occured : " + string(INTERVAL_OCCURENCE_COUNT[i]) + " times -> " + string(INTERVAL_MOST_OCCURENCE_PERCENT[i]) + "%")
		}
		if (DURATION_MOST_OCCURENCE_DONE == 1) {
			for (i = 1; i <= LONGEST_NOTE; i++)
				if (DURATION_OCCURENCE_COUNT[i] >0 )
					print(get_rhythm (i) + " (" + string(i) + ")" +  " occured : " + string(DURATION_OCCURENCE_COUNT[i]) + " times -> " + string(DURATION_MOST_OCCURENCE_PERCENT[i]) + "%")
		}
#------------------
	}
	else
		print(" No phrase loaded for analyse!..")											
}
#--------------------------------------------------------------------------
#			a) BY DURATION
#--------------------------------------------------------------------------
method most_dur (param1) {
	if (ANALYSEPHRASE > 0) {
		if (ANALYSEPHRASENOTES == 0)
			ANALYSEPHRASENOTES = get_phrase_notes (ANALYSEPHRASE)
			if (param1 == "pitch") {
				for (ini = 0; ini <= 127; ini++) 
					NOTE_OCCURENCE_COUNT_DUR[ini] = 0
			}
			if (param1 == "int") {
				for (ini = -127; ini <= 127; ini++) {
					INTERVAL_OCCURENCE_COUNT_DUR[ini] = 0
					IOC_I[ini] = 0
					IOC_C [ini] = 0
				}
			}
				if (param1 == "pitch") {
					for (p = 0; p <= 127; p++) {
						for (notes=1; notes <= ANALYSEPHRASENOTES; notes++) 
							if (p == ANALYSEPHRASE%notes.pitch) 
 								NOTE_OCCURENCE_COUNT_DUR[p]+=ANALYSEPHRASE%notes.dur						
					}	
				}
				if (param1 == "int") {
					for (p = -127; p <= 127; p++) {
						for (notes=2; notes <= ANALYSEPHRASENOTES; notes++) 
							if (p == (ANALYSEPHRASE%notes.pitch - ANALYSEPHRASE%(notes-1).pitch))  
 								INTERVAL_OCCURENCE_COUNT_DUR[p]+=ANALYSEPHRASE%notes.dur
					}
				}
				if (param1 == "pitch")
					NOTE_MOST_OCCURENCE_DONE_DUR = 1
				if (param1 == "int")
					INTERVAL_MOST_OCCURENCE_DONE_DUR = 1
#------------------
#	Printing ..
		if (NOTE_MOST_OCCURENCE_DONE_DUR == 1) {
			for (i = 0; i <= 127; i++)
				if (NOTE_OCCURENCE_COUNT_DUR[i] >0 )
					print(get_note_name (i) + " (" + string(i) + ")" +  " occured for : " + string(NOTE_OCCURENCE_COUNT_DUR[i]) + " clicks")
		}
		if (INTERVAL_MOST_OCCURENCE_DONE_DUR == 1) {
			for (i = -127; i <= 127; i++)
				if (INTERVAL_OCCURENCE_COUNT_DUR[i] >0 ) 
					print(get_interval_name (i) + " (" + string(i) + ")" +  " occured for : " + string(INTERVAL_OCCURENCE_COUNT_DUR[i]) + " clicks")
		}
#------------------
	}
	else
		print(" No phrase loaded for analyse!..")
}
#***********************************************************************************************
#			D - WRITE
#***********************************************************************************************
method write_verbose1 {
	fname = browsefiles("Analysis Files(*.sta, *.txt)","*.sta;*.txt",1)
	if ( fname != "" ) {
		f=open(fname,"w")
		title = getastr("Enter title ->", "STATISTICAL ANALYSIS")
		put (f,title +"\n\n")
		put (f,"STATISTICAL ANALYSIS of : \n\n" + FILENAME + "\n\n")
		comments = getastr("Enter comments ->", "")
		while (comments != "") {
			put (f,comments +"\n")
			comments = getastr("Enter comments ->", "")
		}
		put (f,"\n\nGENERAL DATA : \n\n")
		put (f,"* Number of notes : " + string(get_phrase_notes (ANALYSEPHRASE)) + "\n\n")
			if (MIN_PITCH_FOUND != 0)
				put(f, "* NOTE PITCHES \n\nLowest note : \t" + get_note_name(LOWESTNOTE) + "\t(" + string(LOWESTNOTE.pitch) + ")\n")
			if (MAX_PITCH_FOUND != 0)
				put (f, "Highest note : \t" + get_note_name(HIGHESTNOTE) + "\t(" + string(HIGHESTNOTE.pitch) + ")\n")
			if (MEAN_PITCH_FOUND!= 0)
				put (f, "Mean note : \t" + get_note_name(MEANNOTE) + "\t(" + string(MEANNOTE.pitch) + ")\n")
			if (STAND_DEV_PITCH_FOUND!= 0)
				put (f, "Notes standard deviation : \t" + string(STANDARDDEV) + "\n\n")
			if (MIN_PITCH_INT_FOUND != 0)
				put (f, "* PITCH INTERVALS \n\nMinimum note pitch interval : \t" + get_interval_name (MIN_MELODIC_INTERVAL) + "\t(" + string(MIN_MELODIC_INTERVAL) + " semitones)" + "\n")
			if (MAX_PITCH_INT_FOUND != 0)
				put (f, "Maximum note pitch interval : \t" + get_interval_name (MAX_MELODIC_INTERVAL) + "\t(" + string(MAX_MELODIC_INTERVAL) + " semitones)" + "\n")
			if (MEAN_PITCH_INT_FOUND != 0)
				put (f, "Mean note pitch interval : \t" + get_interval_name (MEAN_PITCH_INTERVAL) + "\t(" + string(MEAN_PITCH_INTERVAL) + " semitones)" + "\n\n")
			if (STAND_DEV_PITCH_INT_FOUND != 0)
				put (f, "Notes pitches standard deviation : \t" + string(P_INTERV_STANDARDDEV) + "\n\n")
			if (MIN_DUR_FOUND != 0)
				put(f, "* DURATIONS \n\nShortest note : \t" + get_rhythm(SHORTESTNOTE) + "\t(" + string(SHORTESTNOTE) + " clicks)" + "\n")
			if (MAX_DUR_FOUND != 0)
				put (f, "Longest note : \t" + get_rhythm(LONGESTNOTE ) + "\t(" + string(LONGESTNOTE) + " clicks)" + "\n")
			if (MEAN_DUR_FOUND != 0)
				put (f, "Mean note duration: \t" + get_rhythm(MEANDURATION) + "\t(" + string(MEANDURATION) + " clicks)" + "\n")
			if (STAND_DEV_DUR_FOUND != 0)
				put(f, "Notes durations standard deviation : \t" + string(DUR_STANDARDDEV) + "\n\n")
			if (MIN_DUR_INT_FOUND != 0)
				put(f, "* DURATION INTERVALS \n\nShortest duration interval : \t" + get_rhythm(MIN_RHYTHMIC_INTERVAL) + "\t(" + string(MIN_RHYTHMIC_INTERVAL) + " clicks)" + "\n")
			if (MAX_DUR_INT_FOUND != 0)
				put (f, "Longest duration interval : \t" + get_rhythm(MAX_RHYTHMIC_INTERVAL) + "\t(" + string(MAX_RHYTHMIC_INTERVAL) + " clicks)" + "\n")
			if (MEAN_DUR_INT_FOUND != 0)
				put (f, "Mean duration interval: \t" + get_rhythm(MEAN_RHYTHMIC_INTERVAL) + "\t(" + string(MEAN_RHYTHMIC_INTERVAL) + " clicks)" + "\n")
			if (STAND_DEV_DUR_INT_FOUND != 0)
				put (f, "Duration intervals standard deviation : \t" + string(RHYTHMIC_INTERV_STANDARDDEV) + "\n\n")
			if (MIN_TIME_INT_FOUND != 0)
				put (f, "* TIME INTERVALS \n\nShortest time interval : \t" + get_rhythm(MIN_TIME_INTERVAL) + "\t(" + string(MIN_TIME_INTERVAL) + " clicks)" + "\n")
			if (MAX_TIME_INT_FOUND != 0)
				put (f, "Longest time interval : \t" + get_rhythm(MAX_TIME_INTERVAL) + "\t(" + string(MAX_TIME_INTERVAL) + " clicks)" + "\n")
			if (MEAN_TIME_INT_FOUND != 0)
				put (f, "Mean time interval: \t" + get_rhythm(MEAN_TIME_INTERVAL) + "\t(" + string(MEAN_TIME_INTERVAL) + " clicks)" + "\n")
			if (STAND_DEV_TIME_INT_FOUND != 0)
				put (f, "Time intervals standard deviation : \t" + string(TIME_INTERV_STANDARDDEV) + "\n\n")
			if (SOFTESTNOTE != 0)
				put (f, "* VELOCITY \n\nMinimum velocity : \t" + get_nuance(SOFTESTNOTE ) + "\t(" + string(SOFTESTNOTE ) + ")" + "\n")
			if (LOUDESTNOTE  != 0)
				put (f, "Maximum velocity : \t" + get_nuance(LOUDESTNOTE) + "\t(" + string(LOUDESTNOTE) + ")" + "\n")
			if (MEAN_NOTE_VEL != 0)
				put (f, "Mean velocity : \t" + get_nuance(MEAN_NOTE_VEL) + "\t(" + string(MEAN_NOTE_VEL) + ")" + "\n")
			if (STAND_DEV_VEL_FOUND != 0)
				put (f, "Velocity standard deviation : \t" + string(STANDARDDEV_VEL) + "\n\n\n\n")
#--------------------------------------------
			if (SEARCH_ABOVE_NOTES_INDEX > 0) {
				for (a = 1; a<= SEARCH_ABOVE_NOTES_INDEX; a++)
					put (f, "* ABOVE - BELOW - FROM .. TO\n\nNOTES\nNotes above: \t" + string(ABOVE_NOTE_GIVEN [a]) + "(" + string(ABOVE_NOTE_GIVEN [a].pitch) + ")" + " -> \t" + string(get_phrase_notes(ABOVE_NOTE_RESULT_PHRASE [a])) + " notes \t" + " % " + string(NOTES_ABOVE_PERCENT[a]) + "\n")
			}
			if (SEARCH_BELOW_NOTES_INDEX > 0) {
				for (a = 1; a<= SEARCH_BELOW_NOTES_INDEX; a++)
					put (f, "Notes below : \t" + string(BELOW_NOTE_GIVEN [a]) + "(" + string(BELOW_NOTE_GIVEN [a].pitch) + ")" + " -> \t" + string(get_phrase_notes(BELOW_NOTE_RESULT_PHRASE [a])) + " notes \t" + " % " + string(NOTES_BELOW_PERCENT[a]) + "\n")
			}
			if (SEARCH_FROMTO_NOTES_INDEX >0) {
				for (a = 1; a<= SEARCH_FROMTO_NOTES_INDEX; a++)
					put (f, "Notes from : \t" + get_note_name(FROM_NOTE_GIVEN[a]) + "(" + string(FROM_NOTE_GIVEN[a].pitch) + ")" + " to : " + get_note_name(TO_NOTE_GIVEN[a]) + " (" + string(TO_NOTE_GIVEN[a]) + " ) -> \t" + string(get_phrase_notes(FROMTO_NOTE_RESULT_PHRASE[a])) + "\t % " + string(NOTES_FROMTO_PERCENT[a]) +  "\n")
			}
			put(f,"\n")
			if (SEARCH_ABOVE_INTERVALS_INDEX > 0) {
				for (a = 1; a<= SEARCH_ABOVE_INTERVALS_INDEX; a++)
					put (f, "INTERVALS \nIntervals above: \t" + get_interval_name(ABOVE_INTERVAL_GIVEN [a]) + "(" + string(ABOVE_INTERVAL_GIVEN [a]) + ")" + " -> \t" + string(get_phrase_notes(ABOVE_INTERVAL_RESULT_PHRASE [a])) + " notes -> \t" + " % " + string(INTERVAL_ABOVE_PERCENT[a]) + "\n")
			}
			if (SEARCH_BELOW_INTERVALS_INDEX > 0) {
				for (a = 1; a<= SEARCH_BELOW_INTERVALS_INDEX; a++)
					put (f, "Intervals below : \t" + get_interval_name(BELOW_INTERVAL_GIVEN [a]) + "(" + string(BELOW_INTERVAL_GIVEN [a]) + ")" + " -> \t" + string(get_phrase_notes(BELOW_INTERVAL_RESULT_PHRASE [a])) + " notes -> \t" + " % " + string(INTERVAL_BELOW_PERCENT[a]) + "\n")
			}
			if (SEARCH_FROMTO_INTERVALS_INDEX >0) {
				for (a= 1; a<= SEARCH_FROMTO_INTERVALS_INDEX; a++)
					put (f, "Intervals from : \t" + get_interval_name(FROM_INTERVAL_GIVEN [a]) + "(" + string(FROM_INTERVAL_GIVEN[a]) + ")" + " to : " + get_interval_name(TO_INTERVAL_GIVEN[a]) + " (" + string(TO_INTERVAL_GIVEN[a]) + ") -> \t" + string(get_phrase_notes(FROMTO_INTERVAL_RESULT_PHRASE[a])) + "\t % " + string(INTERVAL_FROMTO_PERCENT[a]) + "\n")
			}
			put(f,"\n")
			if (SEARCH_ABOVE_DURS_INDEX > 0) {
				for (a= 1; a<= SEARCH_ABOVE_DURS_INDEX; a++)
					put (f, "DURATIONS \nDurations above: \t" + get_rhythm(ABOVE_DUR_GIVEN[a]) + "(" + string(ABOVE_DUR_GIVEN [a]) + ")" + " -> \t" + string(get_phrase_notes(ABOVE_DUR_RESULT_PHRASE [a])) + " notes -> \t" + " % " + string(DUR_ABOVE_PERCENT [a]) + "\n")
			}
			if (SEARCH_BELOW_DURS_INDEX  > 0) {
				for (a= 1; a<= SEARCH_BELOW_DURS_INDEX  ; a++)
					put (f, "Durations below: \t" + get_rhythm(BELOW_DUR_GIVEN[a]) + "(" + string(BELOW_DUR_GIVEN[a]) + ")" + " -> \t" + string(get_phrase_notes(BELOW_DUR_RESULT_PHRASE[a])) + " notes -> \t" + " % " + string(DUR_BELOW_PERCENT[a]) + "\n")
			}
 			if (SEARCH_FROMTO_DURATION_INDEX > 0) {
				for (a= 1; a<= SEARCH_FROMTO_DURATION_INDEX; a++)
					put (f, "Durations from : \t" + get_rhythm(FROM_DURATION_GIVEN[a]) + "(" + string(FROM_DURATION_GIVEN[a]) + ") to : " + get_rhythm(TO_DURATION_GIVEN[a])  + " (" + string(TO_DURATION_GIVEN[a]) + ") -> \t" + string(get_phrase_notes(FROMTO_DURATION_RESULT_PHRASE[a])) + " notes -> \t" + " % " + string(DURATION_FROMTO_PERCENT[a]) + "\n")
			}
			put(f,"\n")
			if (SEARCH_ABOVE_VELS_INDEX > 0) {
				for (a= 1; a<= SEARCH_ABOVE_VELS_INDEX ; a++)
					put (f, "VELOCITIES \nVelocities above: \t" + get_nuance(ABOVE_VEL_GIVEN[a]) + "(" + string(ABOVE_VEL_GIVEN[a]) + ")  -> \t" + string(get_phrase_notes(ABOVE_VEL_RESULT_PHRASE[a])) + " notes -> \t" + " % " + string(VELS_ABOVE_PERCENT[a]) + "\n")
			}
			if (SEARCH_BELOW_VELS_INDEX  > 0) {
				for (a= 1; a<= SEARCH_BELOW_VELS_INDEX  ; a++)
					put (f, "Velocities below: \t" + get_nuance(BELOW_VEL_GIVEN[a]) + "(" + string(BELOW_VEL_GIVEN[a]) + ")  -> \t" + string(get_phrase_notes(BELOW_VEL_RESULT_PHRASE[a])) + " notes -> \t" + " % " + string(VELS_BELOW_PERCENT [a]) + "\n")
			}
			put(f,"\n\n\n")			
#---------------------------------------------
			if (NOTE_OCCURENCE_DONE == 1) {
				put (f,"\n-----\n* NOTE OCCURENCE \n") 
				for (a= 0; a<= 127  ; a++){
					if (NOTE_OCCURENCE[a]>0)
						put (f, "Note : \t" + get_note_name(a) + "\t(" + string(a) + ")  occured -> \t" + string(NOTE_OCCURENCE[a]) + "\t% " + string(NOTE_OCCURENCE_PERCENT[a]) + "\n")
				}
			}
			if (INT_OCCURENCE_DONE == 1) {
				put (f,"\n-----\n* INTERVAL OCCURENCE \n") 
				for (a= -127; a<= 127  ; a++){
					if (INTERVAL_OCCURENCE[a]>0)
						put (f, "Interval : \t" + get_interval_name(a) + "\t(" + string(a) + ")  occured -> \t" + string(INTERVAL_OCCURENCE[a]) + "\t%of notes :  " + string(INTERVAL_OCCURENCE_PERCENT[a]) + "\n")
				}
			}
			if (DUR_OCCURENCE_DONE == 1) {
				put (f,"\n-----\n* DURATION OCCURENCE \n") 
				for (a= 1; a<= LONGEST_NOTE  ; a++){
					if (DUR_OCCURENCE[a] > 0)
						put (f, "Duration : \t" + get_rhythm(a) + "\t(" + string(a) + " clicks)  occured -> \t" + string(DUR_OCCURENCE[a]) + "\t%of notes :  " + string(DUR_OCCURENCE_PERCENT[a]) + "\n")
				}
			}
			if (VEL_OCCURENCE_DONE == 1) {
				put (f,"\n-----\n* VELOCITY OCCURENCE \n") 
				for (a= 0; a<= 127  ; a++){
					if (VEL_OCCURENCE[a] > 0)
						put (f, "Velocity: \t" + get_nuance(a) + "\t(" + string(a) + ")  occured -> \t" + string(VEL_OCCURENCE[a]) + "\t% " + string(VEL_OCCURENCE_PERCENT[a]) + "\n\n\n\n")
				}
			}
			$.write_most(f)
#---------------------------------------------
		print ("Statistical analysis data on\n" + FILENAME + "\nsaved to : \n" + fname)
		close(f)
	}
	else 
		print("Writing aborted")
}

#-----------------------------------------------------------------------------------------------
#			DO ALL ANALYSIS and WRITE
#-----------------------------------------------------------------------------------------------
method do_write {
	if (ANALYSEPHRASE > 0) {
	fname = browsefiles("Analysis Files(*.sta, *.txt)","*.sta;*.txt",1)
	if ( fname != "" ) {
		f=open(fname,"w")
		title = getastr("Enter title ->", "STATISTICAL ANALYSIS")
		put (f,title +"\n\n")
		put (f,"AUTOMATIC STATISTICAL ANALYSIS of : \n\n" + FILENAME + "\n\n")
		most = getastr ("Write notes, intervals, durations occurences ? ->y/n","y")
		comments = getastr("Enter comments ->", "")
		while (comments != "") {
			put (f,comments +"\n")
			comments = getastr("Enter comments ->", "")
		}
	DOING_ALL = 1
	print("Extracting minimum values for pitch, duration and velocity ..")
	$.minpitch("pitch")
	$.minpitch("dur")
	$.minpitch("vel")
	print(".. done")
	print("Extracting maximum values for pitch, duration and velocity ..")
	$.maxpitch ("pitch")
	$.maxpitch ("dur")
	$.maxpitch ("vel")
	print(".. done")
	print("Extracting mean values for pitch, duration and velocity ..")	
	$.arith_mean ("pitch")
	$.arith_mean ("dur")
	$.arith_mean ("vel")
	print(".. done")
	print("Extracting standard values for pitch, duration and velocity ..")	
	$.stand_dev ("pitch")
	$.stand_dev ("dur")
	$.stand_dev ("vel")
	print(".. done")
	print("Extracting minimum values for intervals of pitch, duration and time ..")
	$.min_pitch_interval ("pitch_i")
	$.min_pitch_interval ("dur_i")
	$.min_pitch_interval ("time_i")
	print(".. done")
	print("Extracting maximum values for intervals of pitch, duration and time ..")
	$.max_pitch_interval ("pitch_i")
	$.max_pitch_interval ("dur_i")
	$.max_pitch_interval ("time_i")
	print(".. done")
	print("Extracting mean values for intervals of pitch, duration and time ...")
	$.pitch_int_arith_mean  ("pitch_i")
	$.pitch_int_arith_mean ("dur_i")
	$.pitch_int_arith_mean ("time_i")
	print(".. done")
	print("Extracting standard deviation values for intervals of pitch, duration and time ..")
	$.pitch_int_stand_dev("pitch_i")
	$.pitch_int_stand_dev ("dur_i")
	$.pitch_int_stand_dev ("time_i")
	print(".. done")
	print("Extracting occurence % for notes, intervals, durations and velocities ..")
	$.notes_pitches_percent ("notes_pc")
	$.notes_pitches_percent ("vel_pc")
	$.notes_pitches_percent ("int_pc")
	$.notes_durations_percent
	print(".. done")
#----------------------
	print("Extracting notes above C1 (pitch : 36)")
	$.above_note ("c","o1")
	print(".. done")
	print("Extracting notes above C3 (pitch : 60)")
	$.above_note ("c","o3")
	print(".. done")
	print("Extracting notes above C5 (pitch : 84)")
	$.above_note ("c","o5")
	print(".. done")
	print("Extracting notes below  C1 (pitch : 36)")
	$.below_note ("c","o1")
	print(".. done")
	print("Extracting notes below  C3 (pitch : 60)")
	$.below_note ("c","o3")
	print(".. done")
	print("Extracting notes below  C5 (pitch : 84)")
	$.below_note ("c","o5")
	print(".. done")
#----------------------
	print("Extracting intervals above P4th. (pitch : 5)")
	$.above_pitches_intervals (5)
	print(".. done")
	print("Extracting intervals above m7th. (pitch : 10)")
	$.above_pitches_intervals (10)
	print(".. done")
	print("Extracting intervals above m10th. (pitch : 15)")
	$.above_pitches_intervals (15)
	print(".. done")

	print("Extracting intervals below P4th. (pitch : 5)")
	$.below_pitches_intervals(5)
	print(".. done")
	print("Extracting intervals below -P4th. (pitch : -5)")
	$.below_pitches_intervals(-5)
	print(".. done")
	print("Extracting intervals below m7th. (pitch : 10)")
	$.below_pitches_intervals(10)
	print(".. done")
	print("Extracting intervals below -m7th. (pitch : -10)")
	$.below_pitches_intervals(-10)
	print(".. done")
	print("Extracting intervals below  m10th. (pitch : 15)")
	$.below_pitches_intervals (15)
	print(".. done")
	print("Extracting intervals below  -m10th. (pitch : -15)")
	$.below_pitches_intervals (-15)
	print(".. done")
#----------------------
	print("Extracting durations above eighth (48)")
	$.above_dur (48)
	print(".. done")
	print("Extracting durations above quarter (96)")
	$.above_dur (96)
	print(".. done")
	print("Extracting durations above half (192)")
	$.above_dur (192)
	print(".. done")
	print("Extracting durations below eighth (48)")
	$.below_dur (48)
	print(".. done")
	print("Extracting durations below quarter (96)")
	$.below_dur (96)
	print(".. done")
	print("Extracting durations below  half (192)")
	$.below_dur (192)
	print(".. done")
#----------------------
	print("Extracting velocities above (48) ")
	$.above_vel(48)
	print(".. done")
	print("Extracting velocities above (64)")
	$.above_vel(64)
	print(".. done")
	print("Extracting velocities above (95)")
	$.above_vel(95)
	print(".. done")
	print("Extracting velocities below (48)")
	$.below_vel(48)
	print(".. done")
	print("Extracting velocities below (64)")
	$.below_vel(64)
	print(".. done")
	print("Extracting velocities below  (95)")
	$.below_vel(95)
	print(".. done")
#----------------------
	print("Extracting mostly occuring pitches, intervals, durations (by attack number)")
	$.most_attacks ("pitch")
	$.most_attacks ("int")
	$.most_attacks ("dur")
	print(".. done")
	print("Extracting mostly occuring pitches, intervals (by duration)")
	$.most_dur("pitch")
	$.most_dur("int")
	print(".. done")
#-----------------------
	print("..writing automatic statistical analysis to : \n" + FILENAME)
#-----------------------
		put (f,"* Number of notes : " + string(get_phrase_notes (ANALYSEPHRASE)) + "\n\n")
				put(f, "* NOTE PITCHES \n\nLowest note : \t" + get_note_name(LOWESTNOTE) + "\t(" + string(LOWESTNOTE.pitch) + ")\n")
				put (f, "Highest note : \t" + get_note_name(HIGHESTNOTE) + "\t(" + string(HIGHESTNOTE.pitch) + ")\n")
				put (f, "Mean note : \t" + get_note_name(MEANNOTE) + "\t(" + string(MEANNOTE.pitch) + ")\n")
				put (f, "Notes standard deviation : \t" + string(STANDARDDEV) + "\n\n")
				put (f, "* PITCH INTERVALS \n\nMinimum note pitch interval : \t" + get_interval_name (MIN_MELODIC_INTERVAL) + "\t(" + string(MIN_MELODIC_INTERVAL) + " semitones)" + "\n")
				put (f, "Maximum note pitch interval : \t" + get_interval_name (MAX_MELODIC_INTERVAL) + "\t(" + string(MAX_MELODIC_INTERVAL) + " semitones)" + "\n")
				put (f, "Mean note pitch interval : \t" + get_interval_name (MEAN_PITCH_INTERVAL) + "\t(" + string(MEAN_PITCH_INTERVAL) + " semitones)" + "\n")
				put (f, "Notes pitch intervals standard deviation : \t" + string(P_INTERV_STANDARDDEV) + "\n\n")
				put(f, "* DURATIONS \n\nShortest note : \t" + get_rhythm(SHORTESTNOTE) + "\t(" + string(SHORTESTNOTE) + " clicks)" + "\n")
				put (f, "Longest note : \t" + get_rhythm(LONGESTNOTE ) + "\t(" + string(LONGESTNOTE) + " clicks)" + "\n")
				put (f, "Mean note duration: \t" + get_rhythm(MEANDURATION) + "\t(" + string(MEANDURATION) + " clicks)" + "\n")
				put(f, "Notes durations standard deviation : \t" + string(DUR_STANDARDDEV) + "\n\n")
				put(f, "* DURATION INTERVALS \n\nShortest duration interval : \t" + get_rhythm(MIN_RHYTHMIC_INTERVAL) + "\t(" + string(MIN_RHYTHMIC_INTERVAL) + " clicks)" + "\n")
				put (f, "Longest duration interval : \t" + get_rhythm(MAX_RHYTHMIC_INTERVAL) + "\t(" + string(MAX_RHYTHMIC_INTERVAL) + " clicks)" + "\n")
				put (f, "Mean duration interval: \t" + get_rhythm(MEAN_RHYTHMIC_INTERVAL) + "\t(" + string(MEAN_RHYTHMIC_INTERVAL) + " clicks)" + "\n")
				put (f, "Duration intervals standard deviation : \t" + string(RHYTHMIC_INTERV_STANDARDDEV) + "\n\n")
				put (f, "* TIME INTERVALS \n\nShortest time interval : \t" + get_rhythm(MIN_TIME_INTERVAL) + "\t(" + string(MIN_TIME_INTERVAL) + " clicks)" + "\n")
				put (f, "Longest time interval : \t" + get_rhythm(MAX_TIME_INTERVAL) + "\t(" + string(MAX_TIME_INTERVAL) + " clicks)" + "\n")
				put (f, "Mean time interval: \t" + get_rhythm(MEAN_TIME_INTERVAL) + "\t(" + string(MEAN_TIME_INTERVAL) + " clicks)" + "\n")
				put (f, "Time intervals standard deviation : \t" + string(TIME_INTERV_STANDARDDEV) + "\n\n")
				put (f, "* VELOCITY \n\nMinimum velocity : \t" + get_nuance(SOFTESTNOTE ) + "\t(" + string(SOFTESTNOTE ) + ")" + "\n")
				put (f, "Maximum velocity : \t" + get_nuance(LOUDESTNOTE) + "\t(" + string(LOUDESTNOTE) + ")" + "\n")
				put (f, "Mean velocity : \t" + get_nuance(MEAN_NOTE_VEL) + "\t(" + string(MEAN_NOTE_VEL) + ")" + "\n")
				put (f, "Velocity standard deviation : \t" + string(STANDARDDEV_VEL) + "\n\n")
#--------------------------------------------
				put (f,"* ABOVE - BELOW - FROM .. TO\n\nNOTES\n")
				for (a = 1; a<= SEARCH_ABOVE_NOTES_INDEX; a++)
					put (f, "Notes above: \t" + string(ABOVE_NOTE_GIVEN [a]) + "(" + string(ABOVE_NOTE_GIVEN [a].pitch) + ")" + " -> \t" + string(get_phrase_notes(ABOVE_NOTE_RESULT_PHRASE [a])) + " notes \t" + "% " + string(NOTES_ABOVE_PERCENT[a]) + "\n")
				for (a = 1; a<= SEARCH_BELOW_NOTES_INDEX; a++)
					put (f, "Notes below : \t" + string(BELOW_NOTE_GIVEN [a]) + "(" + string(BELOW_NOTE_GIVEN [a].pitch) + ")" + " -> \t" + string(get_phrase_notes(BELOW_NOTE_RESULT_PHRASE [a])) + " notes \t" + "% " + string(NOTES_BELOW_PERCENT[a]) + "\n")
				for (a = 1; a<= SEARCH_FROMTO_NOTES_INDEX; a++)
					put (f, "Notes from : \t" + get_note_name(FROM_NOTE_GIVEN[a]) + "(" + string(FROM_NOTE_GIVEN[a].pitch) + ")" + " to : " + get_note_name(TO_NOTE_GIVEN[a]) + " (" + string(TO_NOTE_GIVEN[a]) + " ) -> \t" + string(get_phrase_notes(FROMTO_NOTE_RESULT_PHRASE[a])) + "\t% " + string(NOTES_FROMTO_PERCENT[a]) +  "\n")
			put(f,"\nINTERVALS \n")
				for (a = 1; a<= SEARCH_ABOVE_INTERVALS_INDEX; a++)
					put (f, "Intervals above: \t" + get_interval_name(ABOVE_INTERVAL_GIVEN [a]) + "(" + string(ABOVE_INTERVAL_GIVEN [a]) + ")" + " -> \t" + string(get_phrase_notes(ABOVE_INTERVAL_RESULT_PHRASE [a])) + " notes -> \t" + "% " + string(INTERVAL_ABOVE_PERCENT[a]) + "\n")
				for (a = 1; a<= SEARCH_BELOW_INTERVALS_INDEX; a++)
					put (f, "Intervals below : \t" + get_interval_name(BELOW_INTERVAL_GIVEN [a]) + "(" + string(BELOW_INTERVAL_GIVEN [a]) + ")" + " -> \t" + string(get_phrase_notes(BELOW_INTERVAL_RESULT_PHRASE [a])) + " notes -> \t" + "% " + string(INTERVAL_BELOW_PERCENT[a]) + "\n")
				for (a= 1; a<= SEARCH_FROMTO_INTERVALS_INDEX; a++)
					put (f, "Intervals from : \t" + get_interval_name(FROM_INTERVAL_GIVEN [a]) + "(" + string(FROM_INTERVAL_GIVEN[a]) + ")" + " to : " + get_interval_name(TO_INTERVAL_GIVEN[a]) + " (" + string(TO_INTERVAL_GIVEN[a]) + ") -> \t" + string(get_phrase_notes(FROMTO_INTERVAL_RESULT_PHRASE[a])) + "\t% " + string(INTERVAL_FROMTO_PERCENT[a]) + "\n")
			put(f,"\nDURATIONS \n")
				for (a= 1; a<= SEARCH_ABOVE_DURS_INDEX; a++)
					put (f, "Durations above: \t" + get_rhythm(ABOVE_DUR_GIVEN[a]) + "(" + string(ABOVE_DUR_GIVEN [a]) + ")" + " -> \t" + string(get_phrase_notes(ABOVE_DUR_RESULT_PHRASE [a])) + " notes -> \t" + " % " + string(DUR_ABOVE_PERCENT [a]) + "\n")
				for (a= 1; a<= SEARCH_BELOW_DURS_INDEX  ; a++)
					put (f, "Durations below: \t" + get_rhythm(BELOW_DUR_GIVEN[a]) + "(" + string(BELOW_DUR_GIVEN[a]) + ")" + " -> \t" + string(get_phrase_notes(BELOW_DUR_RESULT_PHRASE[a])) + " notes -> \t" + " % " + string(DUR_BELOW_PERCENT[a]) + "\n")
				for (a= 1; a<= SEARCH_FROMTO_DURATION_INDEX; a++)
					put (f, "Durations from : \t" + get_rhythm(FROM_DURATION_GIVEN[a]) + "(" + string(FROM_DURATION_GIVEN[a]) + ") to : " + get_rhythm(TO_DURATION_GIVEN[a])  + " (" + string(TO_DURATION_GIVEN[a]) + ") -> \t" + string(get_phrase_notes(FROMTO_DURATION_RESULT_PHRASE[a])) + " notes -> \t" + " % " + string(DURATION_FROMTO_PERCENT[a]) + "\n")
			put(f,"\nVELOCITIES \n")
				for (a= 1; a<= SEARCH_ABOVE_VELS_INDEX ; a++)
					put (f, "Velocities above: \t" + get_nuance(ABOVE_VEL_GIVEN[a]) + "(" + string(ABOVE_VEL_GIVEN[a]) + ")  -> \t" + string(get_phrase_notes(ABOVE_VEL_RESULT_PHRASE[a])) + " notes -> \t" + " % " + string(VELS_ABOVE_PERCENT[a]) + "\n")
				for (a= 1; a<= SEARCH_BELOW_VELS_INDEX  ; a++)
					put (f, "Velocities below: \t" + get_nuance(BELOW_VEL_GIVEN[a]) + "(" + string(BELOW_VEL_GIVEN[a]) + ")  -> \t" + string(get_phrase_notes(BELOW_VEL_RESULT_PHRASE[a])) + " notes -> \t" + " % " + string(VELS_BELOW_PERCENT [a]) + "\n")
			put(f,"\n\n\n")
			if (most = "y")			
	 			$.write_most(f)
#-----------------------
		print ("Automatic statistical analysis data saved to : \n" + fname)
	close (f)
	}
	else
		print("Writing aborted")
	}
	else
		print("No phrase loaded for analyse!..")
	DOING_ALL = 0
}

method write_most (f) {
			if (NOTE_MOST_OCCURENCE_DONE == 1) {
				put (f,"\n\n* NOTE MOST OCCURENCE (by number of attacks)\n") 
				for (a= 0; a<= 127  ; a++){
					if (NOTE_OCCURENCE_COUNT[a] > 0)
						put (f, "Note: \t" +  get_note_name (a) + "\t(" + string(a) + ")  occured -> \t" + string(NOTE_OCCURENCE_COUNT[a]) + " times,  % \t" + string(NOTE_MOST_OCCURENCE_PERCENT[a]) + "\n")
				}
			}
			if (INTERVAL_MOST_OCCURENCE_DONE == 1) {
				put (f,"\n\n* INTERVAL MOST OCCURENCE (by number of attacks)\n") 
				for (a= -127; a<= 127  ; a++){
					if (INTERVAL_OCCURENCE_COUNT[a] > 0)
						put (f, "Interval: \t" +  get_interval_name (a) + "\t(" + string(a) + ")  occured -> \t" + string(INTERVAL_OCCURENCE_COUNT[a]) + " times,  % \t" + string(INTERVAL_MOST_OCCURENCE_PERCENT[a]) + "\n")
				}
			}
			if (DURATION_MOST_OCCURENCE_DONE == 1) {
				put (f,"\n\n* DURATION MOST OCCURENCE (by number of attacks)\n") 
				for (a= 1; a<= LONGEST_NOTE  ; a++){
					if (DURATION_OCCURENCE_COUNT[a] > 0)
						put (f, "Duration: \t" +  get_rhythm (a) + "\t(" + string(a) + ")  occured -> \t" + string(DURATION_OCCURENCE_COUNT[a]) + " times,  % \t" + string(DURATION_MOST_OCCURENCE_PERCENT[a]) + "\n")
				}
			}
			if (NOTE_MOST_OCCURENCE_DONE_DUR == 1) {
				put (f,"\n\n* NOTE MOST OCCURENCE (by total duration time)\n") 
				for (a= 0; a<= 127  ; a++){
					if (NOTE_OCCURENCE_COUNT_DUR[a] > 0)
						put (f, "Note: \t" +  get_note_name (a) + "\t(" + string(a) + ")  occured for a total of -> \t" + string(NOTE_OCCURENCE_COUNT_DUR[a]) + " clicks" + "\n")
				}
			}
			if (INTERVAL_MOST_OCCURENCE_DONE_DUR == 1) {
				put (f,"\n\n* INTERVAL MOST OCCURENCE (by total duration time)\n") 
				for (a= -127; a<= 127  ; a++){
					if (INTERVAL_OCCURENCE_COUNT_DUR[a] > 0)
						put (f, "Interval: \t" +  get_interval_name (a) + "\t(" + string(a) + ")  occured for a total of -> \t" + string(INTERVAL_OCCURENCE_COUNT_DUR[a]) + " clicks" + "\n")
				}
			}
}
												
method write_most_tabular_notes {
	if (ANALYSEPHRASE > 0) {
		fname = browsefiles("Analysis Files(*.sta, *.txt)","*.sta;*.txt",1)
		if ( fname != "" ) {
			f=open(fname,"w")
			$.most_attacks ("pitch")
			put (f, "NOTE MOST OCCURENCE (by number of attacks)\n\n")
			for (a= 0; a<= 127  ; a++){
				if (NOTE_OCCURENCE_COUNT[a] > 0)
					put (f, get_note_name (a) + "\t(" + string(a) + ")\t" + string(NOTE_OCCURENCE_COUNT[a]) + "\t(" + string(NOTE_MOST_OCCURENCE_PERCENT[a]) + "%)\n")
			}
		}
	}
	else
		print("No phrase loaded for analyse!..")
}

method write_most_tabular_intervals {
	if (ANALYSEPHRASE > 0) {
		fname = browsefiles("Analysis Files(*.sta, *.txt)","*.sta;*.txt",1)
		if ( fname != "" ) {
			f=open(fname,"w")
			$.most_attacks ("int")
			put (f,"\n\n* INTERVAL MOST OCCURENCE (by number of attacks)\n\n") 
			for (a= -127; a<= 127  ; a++){
				if (INTERVAL_OCCURENCE_COUNT[a] > 0)
					put (f, get_interval_name (a) + "\t(" + string(a) + ")\t" + string(INTERVAL_OCCURENCE_COUNT[a]) + "\t(" + string(INTERVAL_MOST_OCCURENCE_PERCENT[a]) + "%)\n")
			}
		}
	}
	else
		print("No phrase loaded for analyse!..")
}

method write_most_tabular_durations {
	if (ANALYSEPHRASE > 0) {
		fname = browsefiles("Analysis Files(*.sta, *.txt)","*.sta;*.txt",1)
		if ( fname != "" ) {
			f=open(fname,"w")
			$.most_attacks ("dur")
			put (f,"\n\n* DURATION MOST OCCURENCE (by number of attacks)\n\n") 
				for (a= 1; a<= LONGEST_NOTE  ; a++){
					if (DURATION_OCCURENCE_COUNT[a] > 0)
						put (f, get_rhythm (a) + "\t(" + string(a) + ")\t" + string(DURATION_OCCURENCE_COUNT[a]) + "\t(" + string(DURATION_MOST_OCCURENCE_PERCENT[a]) + "%)\n")
				}
		}
	}
	else
		print("No phrase loaded for analyse!..")
}

method write_most_tabular_notes_dur {
	if (ANALYSEPHRASE > 0) {
		fname = browsefiles("Analysis Files(*.sta, *.txt)","*.sta;*.txt",1)
		if ( fname != "" ) {
			f=open(fname,"w")
			$.most_dur("pitch")
			put (f,"\n\n* NOTE MOST OCCURENCE (by total duration time)\n\n") 
				for (a= 0; a<= 127  ; a++){
					if (NOTE_OCCURENCE_COUNT_DUR[a] > 0)
						put (f, get_note_name (a) + "\t(" + string(a) + ")\t" + string(NOTE_OCCURENCE_COUNT_DUR[a]) + "\n")
				}
		}
	}
	else
		print("No phrase loaded for analyse!..")
}

method write_most_tabular_intervals_dur {
	if (ANALYSEPHRASE > 0) {
		fname = browsefiles("Analysis Files(*.sta, *.txt)","*.sta;*.txt",1)
		if ( fname != "" ) {
			f=open(fname,"w")
			$.most_dur("int")
			put (f,"\n\n* INTERVAL MOST OCCURENCE (by total duration time)\n\n") 
				for (a= -127; a<= 127  ; a++){
					if (INTERVAL_OCCURENCE_COUNT_DUR[a] > 0)
						put (f, get_interval_name (a) + "\t(" + string(a) + ")\t" + string(INTERVAL_OCCURENCE_COUNT_DUR[a]) + "\n")
				}
		}
	}
	else
		print("No phrase loaded for analyse!..")
}

}
