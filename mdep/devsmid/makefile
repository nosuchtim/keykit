install :
	sh Install

all : testread testwrite resetmidi 

Driver.o : Driver.c
	cc -D_KERNEL -c Driver.c

clean clobber :
	rm -f testread testwrite resetmidi *.o testopen

lint :
	lint -nux -D_KERNEL Driver.c | grep -v "struct/union.*never defined"

oldlint : lintlib.ln
	lint -nux lintlib.ln Driver.c | grep -v "struct/union.*never defined"

lintlib.ln : lintlib.c
	lint -c lintlib.c
