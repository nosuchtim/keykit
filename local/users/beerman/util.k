function lookandkill(start,time1,time2,pitch1,pitch2,ch,phr) {
	sleeptill(start+seconds(time1))

	# spawn the task that will monitor midi input
	# looking for middle C
        t = task lookfornote(pitch1,pitch2,ch,phr)

	# that task looking for the note is now going on in parallel
	# with this one.  So we just sleep till the appointed time
	# and then kill the task.

	sleeptill(start+seconds(time2))

        kill(t)
}



# plays a random melody 
function melody(notes,time,beginpitch,endpitch,begindur,enddur)
{
start=Now
phrase=''
for(n=0;n<notes;n++){
phrase+=makenote(rand(beginpitch,endpitch),rand(begindur,enddur))
}
realtime(phrase,start+seconds(time))
}

# chooses range of durations for the melody
function melody2(num,delay,beginpitch,endpitch)
{
start=Now
phrase=''
for(n=0;n<num;n++){
x=rand(0,1)
print(x)
if(x==1)
phrase+=makenote(rand(beginpitch,endpitch),rand(20,50))
phrase+=makenote(rand(beginpitch,endpitch),rand(60,150))

}
realtime(phrase,start+seconds(delay))

}


function panic(when)
{
sleeptill(start+seconds(when))
realtime(ano())
print("panic button is running")
}

function lookfornote(pitch1,pitch2,ch,phr) {

        # Arrange for fifo f to get a copy of Midi input,
	# and make sure it's cleaned up when this task
	# gets killed.

	u = gettid()
	Midiin[u] = f = open()
	onexit(closemidi,u)

	# Remember, the messages we're going to get
	# here include both note-ons and note-offs.

	while ( (m=get(f)) != Eof )
	  {
	{	 m.time-=m%1.time # sets time to 0 so midi starts without delay
               x=transpose(m,0)
               realtime(x,Now)}


  if ( m.type == NOTEON && m.pitch >= pitch1 && m.pitch <=pitch2 && m.channel==ch) {
			# It is assumed that the first note
			# of phr is at time 0, so this should
			# start playing right away.
                        realtime(phr)

		}
	}
}
