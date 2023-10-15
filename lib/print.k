function print(...) {
	sep = ""
	if ( Graphics && defined(Console) ) {
		lock(Console)
		for ( n=0; n<nargs(); n++ ) {
			Console.printf("%s%s",sep,string(argv(n)))
			sep = " "
		}
		Console.printf("\n")
		unlock(Console)
	}
	else {
		for ( n=0; n<nargs(); n++ ) {
			printf("%s%s",sep,string(argv(n)))
			sep = " "
		}
		printf("\n")
	}
}
