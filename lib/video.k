function vidstart() {
	mdep("video","start",32,32)
}
function vidtest() {
	while ( 1 ) {
		print("red="+string(mdep("video","get","red",0,0))
		+" green="+string(mdep("video","get","green",0,0))
		+" blue="+string(mdep("video","get","blue",0,0)))
	}
}
