function ack(a,b) {
	if ( a == 0 ) return(b + 1)
	if ( b == 0 ) return(ack(a-1,1))
	t = ack(a,b-1)
	return(ack(a-1, t))
}
print(ack(2,2))
