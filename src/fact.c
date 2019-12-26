#include <stdio.h>
int
fact(int n)
{
	if ( n < 2 ) return 1;
	else return(n*fact(n-1));
}

main()
{
	int n, k;

	printf("hello\n");
	for ( n=0; n<100000; n++ ) {
		k = fact(20);
	}
	printf("end\n");
}
