test_nt :
	keytest

test_long_nt :
	keytest_long

clean_nt :
	del *.out

clean :
	rm -f *.out

test_stdio :
	flip -u *.k *.sav *.sh
	sh ./keytest.sh

test_long_stdio :
	flip -u stringsoak.k stringsoak.sav keytest_long.sh
	sh ./keytest_long.sh

clean_stdio :
	rm -f *.out
