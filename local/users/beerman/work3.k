
function work3() {
        Merge = 0
	# spawn the task that will monitor MIDI input
	t = task task_work3()

	Root.waitforconsolekey()

	kill(t)
}

function task_work3() {

	Midiin[$] = f = open()
	onexit(closemidi,$)

	while ( (m=get(f)) != Eof ) {
               
               n=cut(Recorded,CUT_TIME,Now,Now-2b,TRUNCATE)
               n|=Current
               print(n%1)
               n.time-=n%1.time
              
               realtime(n,Now+7b)
                
               
	}
}
