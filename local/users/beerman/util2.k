###################################################################
# printAt - print string s at time t
###################################################################

function printAt(t,s) {
	task realprintAt(t,s)
}

function realprintAt(t,s) {
	sleeptill(Start+seconds(t))
	print(s)
}

###################################################################
# playAt - play phrase p at time t (whose value is in seconds) 
###################################################################

function playAt(t,p) {
	realtime(p,Start+seconds(t))
}

###################################################################
# panicAt - send an all-notes-off message at time t.
###################################################################

function panicAt(t) {
	sleeptill(start+seconds(t))
	realtime(ano())
	print("panicAt has sent all-notes-off")
}

function dofrom(tm1,tm2,pitch1,pitch2,ch,p1) {
	task lookAndPlay(Start,tm1,tm2, pitch1,pitch2,ch,p1)
}

###################################################################

# lookAndPlay - this function spawns a task that looks for notes
# between pitch1 and pitch2 on channel ch, and plays phr when it
# sees any.  The task is started at time1 and killed at time2.
###################################################################

function lookAndPlay(start,time1,time2,pitch1,pitch2,ch,phr) {

	sleeptill(start+seconds(time1))

	# spawn the task that will monitor midi input
	# looking for notes between pitch1 and pitch2

        t = task lookForNoteRange(pitch1,pitch2,ch,phr)

	# The task looking for the note is now going on in parallel
	# with this one.  So we just sleep till the appointed time
	# and then kill the task.

	sleeptill(start+seconds(time2))

        kill(t)
}

###################################################################


# lookForNoteRange - This function monitors MIDI input, looking
# for notes between pitch1 and pitch2 on a specific channel (ch),
# and when it sees one, it plays the phrase (phr).
###################################################################

function lookForNoteRange(pitch1,pitch2,ch,phr) {

        # Arrange for fifo f to get a copy of Midi input,
	# and make sure it's cleaned up when this task
	# gets killed.

	u = gettid()
	Midiin[u] = f = open()
	onexit(closemidi,u)

	# Remember, the messages we're going to get
	# here include both note-ons and note-offs.

	while ( (m=get(f)) != Eof ) {

		realtime(m,0)

		if ( m.type == NOTEON
			&& m.pitch >= pitch1
			&& m.pitch <= pitch2
			&& m.channel == ch) {

			# It is assumed that the first note
			# of phr is at time 0, so this should
			# start playing right away.

                       realtime(phr)

		}
	}
}

##########################################

#######################

# record a phrase once and get it ready for processing
function interact(time,size)
{start=Now
print("the program is running")
sleeptill(start+seconds(time))
bunch=cut(Recorded,CUT_TIME,Now,Now-size,TRUNCATE)
bunch.time-=bunch%1.time
print("this is the phrase/n")
print(bunch)

return(bunch)
}
###########################################
# grab the last bunch of MIDI input
function grab(time){
start=Now
ph = lastbunch(Recorded,2b)
ph.time-=ph%1.time
realtime(ph,start+seconds(time))
    # Use the velocity value of each note
    # as the pitch of the note.
    
r = ''
    for ( nt in ph ) {
        nt.pitch = nt.vol
       r |= nt
		
    }

	realtime(r,start+seconds(20))
	}


	########################

function doit(time,size)
{
start=Now
t= task	interact2(time,size)

 interact2(time,size)
kill(t)
		}		
# record a phrase once and get it ready for processing
function interact2(time,size)
{
print("the program is running")
sleeptill(start+seconds(time))
bunch=cut(Recorded,CUT_TIME,Now,Now-size,TRUNCATE)
bunch.time-=bunch%1.time
print("this is the phrase/n")
A=(bunch)

#return(bunch)
}		
################################################		
		
		

