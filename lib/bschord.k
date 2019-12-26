
function bschord() {

	delta = [
		0=5,
		1=5,
		2=5,
		3=5,
		4=5,
		5=3,
		6=3,
		7=2,
		8=2
	]
	nchords = 4
	stepleng = 1b
	# nchords = 1
	# stepleng = 4b
	r = ''
	totalinc = 0
	for ( n=0; n<nchords; n++ ) {

		ch = 'c e g'
		ch.pitch += totalinc

		inc = delta[rand(sizeof(delta))]
		if ( rand(2) )
			inc = -inc

		totalinc += inc
		r += ch
	}
	return(r)
}
