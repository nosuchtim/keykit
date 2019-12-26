function aa(tm) {
	sleeptill(tm)
	# The locks are so the printing isn't interleaved
	lock(1)
	print("aa finished")
	unlock(1)
}

function bb(tm) {
	n1 = task aa(tm)
	n2 = task aa(tm)
	n3 = task aa(tm)
	sleeptill(tm)
}

task bb(Now+8b)

function tryit() {
	for(n=0;n<1000;n++) ;
}
function try( f,c,id) {
	print("try start")
	id = task tryit()
	wait(id)
	print("after wait!")
}

try()
