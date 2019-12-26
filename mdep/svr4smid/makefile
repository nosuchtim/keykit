install :
	sh Install

all : testin testout resetmidi 

clean clobber :
	rm -f testin testout resetmidi *.o testopen

lint :
	lint -nux -D_KERNEL Driver.c | grep -v "struct/union.*never defined"

oldlint : lintlib.ln
	lint -nux lintlib.ln Driver.c | grep -v "struct/union.*never defined"

lintlib.ln : lintlib.c
	lint -c lintlib.c
