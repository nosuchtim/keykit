function radio() {
	midiid = task task_radio();
}
function task_radio() {
	id = 99
	Midiin[id] = f = open()
	onexit(closemidi,99)
	while ( (m=get(f)) != Eof ) {
		print("type=",m.type," msg=",m);
		if ( m.chan == 16 ) {
			if ( m.type == CONTROLLER ) {
				byte1 = subbytes(m,2,1)+0;
				byte2 = subbytes(m,3,1)+0;
			}
			else if ( m.type == PRESSURE ) {
				byte3 = subbytes(m,2,1)+0;
				byte4 = subbytes(m,3,1)+0;
				print("message = ",byte1,byte2,byte3,byte4);
				if ( byte1 == 111 ) {
					realtime(makenote(byte2))
				}
				else if ( byte1 == 112 ) {
					realtime(makenote(byte3))
				}
			}
		}
	}
}
