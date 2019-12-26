function bench1 {
	print("hi\n")
	tm1 = milliclock()
	sum = 12345
	sum2 = 0
	for ( k=0; k<1000; k++ ) {
		for ( i=0; i<100; i++ ) {
			sum *= 0.98
		}
		for ( i=0; i<100; i++ ) {
			sum *= 1.02
		}
	}
	print("sum=",sum)
	tm2 = milliclock()
	print("milli diff = ",(tm2-tm1))
}
bench1();
