# The goal of this code is to play a short phrase (p1)
# in response to a note (n1) when played within a
# certain number (s1) of seconds.
#
# An example of using it would be:
#
#      example_1('c e g',60,10)
#
# This would play a C chord every time middle C (pitch 60)
# was seen for the next 10 seconds.  The function would return
# after 10 seconds.  If you want to do other things at
# the same time, just spawn this function as a task:
#
#      t = task example_1('c e g',60,10)

function example_1(p1,n1,s1) {

	# spawn the task that will monitor midi input
	# looking for middle C 
	t = task lookfornote(p1,n1)
	
	# that task is now going on in parallel with this one.
	# So we just sleep for 10 seconds and then kill the task.
	sleeptill(Now+milliclicks(1000*s1))

	kill(t)
}

function lookfornote(p1,n1) {
	
	# Arrange for fifo f to get a copy of Midi input,
	# and make sure it's cleaned up when this task 
	# gets killed.

	Midiin[$] = f = open()
	onexit(closemidi,$)

	# Remember, the messages we're going to get
	# here include both note-ons and note-offs.

	while ( (m=get(f)) != Eof ) {
		if ( m.type == NOTEON && m.pitch == n1 ) {
			# It is assumed that the first note
			# of p1 is at time 0, so this should
			# start playing right away.
			realtime(p1)
		}
	}
}
