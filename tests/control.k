for(n=0;n++<1;)
	print(n)
for(n=0;
	++n<1;
		)
	{
		print(n)
	}
n=0
for(;;) {
	n+=2;
	if ( n > 10 ) {
		break
	}
	print(n)
}
for(;n--;print(n)) if ( n>5 ) continue else break
for(n=10;n--;) { if ( n>5 ) {print(n) ; continue } ;  break }
if ( 1 > 2 ) print("no") ; else print("yes")
if ( 1 == 2 )
	print("no")
else
	print("yes")
if ( !(1>=2) ) {
	print("yes")
	if ( 1 > 0 )
		if ( 2 > 1 )
			print("yes")
		else
			print("no")
	else
		print("no")
}
else print("no")
n=0
while (1)
	if ( n++ > 10 )
		break;
	else
		print(n)
while (n>4) print(--n)
while (n<10)
{
	if ( ++n < 7 )
		continue
	print(n)
}
