all : testread testwrite resetmidi testpoll

clean clobber :
	rm -f testread testwrite resetmidi testpoll *.o

lint : lintlib.ln
	lint -nux lintlib.ln Driver.c | grep -v "struct/union.*never defined"

lintlib.ln : lintlib.c
	lint -c lintlib.c
