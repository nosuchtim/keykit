function omnitest(cnt) {
    if ( nargs() < 1 ) {
	cnt = 100
    }
    for ( n=0; n<cnt; n++ ) {
	p = 40+rand(40)
	ch = 1+rand(8)
	prog = 1+rand(48)
	nt1 = progchange(prog,ch)
	realtime(nt1)
	sleeptill(Now+6)
	nt2 = makenote(p,2b,100,ch)
	tid = realtime(nt2)
	# print("prog=",nt1," note=",nt2)
	sleeptill(Now+1b/16)
	kill(tid)
	a = ano()
	realtime(a)
    }
}
