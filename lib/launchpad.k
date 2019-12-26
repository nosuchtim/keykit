function launchrand() {

	t = task task_launchrand()

	Root.waitforconsolekey()

	kill(t)
}

function task_launchrand() {
	while ( 1 ) {
		task launchpad_flash(rand(9),rand(9),1b,rand(3))
		sleeptill(Now+4)
	}
}
Launchpad_color = [0=0,1=48,2=3,3=51]  # 0=off 1=green 2=red 3=amber
Launchphr_on = []
Launchphr_off = []
Launchphr_initialized = 0
Launchpad_last_tm = 0

function launchpad_init() {
	print("LAUNCHPAD_INIT!")
	for ( row=0; row<8; row++ ) {
		Launchphr_on[row] = []
		Launchphr_off[row] = []
		for ( col=0; col<9; col++ ) {
			nt = makenote(112 - 16 * row + col)
			nt.port = Launchpad_output
			nt.type = NOTEON
			Launchphr_on[row][col] = nt
			nt.type = NOTEOFF
			Launchphr_off[row][col] = nt
		}
	}
	Launchphr_on[8] = []
	Launchphr_off[8] = []
	for ( col=0; col<9; col++ ) {
		nt = controller(1,104+col,127)
		nt.port = Launchpad_output
		Launchphr_on[8][col] = nt

		nt = controller(1,104+col,0)
		nt.port = Launchpad_output
		Launchphr_off[8][col] = nt
	}
	Launchphr_initialized = 1
}
function launchpad_reset() {
	p = midibytes(0xb0,0,0)
	p.port = Launchpad_output
	realtime(p)
}

function launchpad_flash(row,col,dur,color) {
	launchpad_on(row,col,color)
	sleeptill(Now+dur)
	launchpad_off(row,col)
}

function launchpad_on(row,col,color) {
	if ( Launchphr_initialized == 0 )
		launchpad_init()
	p = Launchphr_on[row][col]
	if ( p.type == NOTEON ) {
		p.vol = Launchpad_color[color]
	} else {
		after = midibytes(subbytes(p,1,2),127)
		after.port = p.port
		p = after
	}
	launchpad_realtime(p)
}

function launchpad_off(row,col) {
	if ( Launchphr_initialized == 0 )
		launchpad_init()
	p = Launchphr_off[row][col]
	realtime(p)
}

function launchpad_realtime(p) {
	realtime(p)
	return()
	if ( Now > Launchpad_last_tm )
		Launchpad_last_tm = Now
	else
		Launchpad_last_tm += 1
	# print("launch p=",p," Now=",Now," tm=",Launchpad_last_tm)
	realtime(p,Launchpad_last_tm)
}
