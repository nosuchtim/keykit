# Copyright 1996 AT&T Corp.  All rights reserved.
#
#       KeyKit has been ported to many environments in its lifetime,
#       however the most recent version has only been tested in the
#       environments described below.
#
#       Windows -    To compile the windows version, you'll need:
#
#                    0) Windows 10
#                    1) Microsoft Visual Studio 2019
#                    2) Cygwin64 (in c:\cygwin64, only needed for perl and an XML parsing library for docs)
#                    3) Git (in c:\program files\Git, for a few unix utilities)
#
#                    Once you have these, execute this command in a DOS window:
#
#                        makewindows.bat
#
#                    This will compile and put binaries in the bin directory.
#
#	UNIX/Linux (stdio) - To compile, "make install_stdio".
#                    Use "make regress_stdio" to run the regression tests.
#
#       The machine-dependent parts of KeyKit have not changed much
#       over the years, so many of the previous ports
#       (most of which are included in the mdep directory) should
#       be resurrected fairly easily.
#
#       See the doc directory for more documentation - in particular
#       the "porting" file gives detailed porting guidelines.
#
#	Any questions, email to me@timthompson.com

# set MK to the preferred version of the make utility on your system
MK = $(MAKE)
CHMOD = chmod.exe
ZIP32 = zip32.exe

# set RMCR to the name of a program that will remove carriage-returns
RMCR = mdep/stdio/rmcr
# WINRMCR = flip -u
WINRMCR = dos2unix

VERSION=8.0
SUFF=80
KS = key$(SUFF)

OTHERDIRS = 
LDLIB="export LD_LIBRARY_PATH=/usr/X11R6/lib"

### This determines what type of makefile gets used on windows.
### msvs is for Visual Studio 2003
# MSTYPE=msc
MSTYPE=msvs

default :
	@echo "There is no default makefile target."
	@echo ""
	@echo "Typical usage on linux is 'make install_linux'."
	@echo "Typical usage on windows is   'nmake install_nt'."
	@echo "Read the makefile for more details."

# The OSTYPE variable is only set on Linux.

install : default

clean :
	@echo "No default for 'make clean'."
	@echo "Use 'make clean_nt' or 'make clean_stdio'."

clobber :
	@echo "No default for 'make clobber'."
	@echo "Use 'make clobber_nt' or 'make clobber_stdio'."

clean_linux : 
	$(MK) -C src clean
	$(MK) -C doc clean
	$(MK) -C tests clean

test : regress_nt

test_nt : regress_nt
test_stdio : regress_stdio

install_nt :
	$(MK) install_nt_1
	$(MK) copy_nt
	$(MK) install_nt_2
	
install_tjt :
	$(MK) install_nt_1
	$(MK) copy_tjt
	$(MK) install_nt_2
	
install_python :
	$(MK) install_nt_python
	$(MK) install_final_python

PYTHON=c:\python25
FINALDIR=$(PYTHON)\lib\site-packages\nosuch

install_final_python :
	-mkdir $(FINALDIR)
	copy src\pykeykit.pyd $(FINALDIR)
	copy src\keykit.py $(FINALDIR)
	-mkdir $(FINALDIR)\keykit
	rm -fr $(FINALDIR)\keykit\lib
	-mkdir $(FINALDIR)\keykit\lib
	copy lib\*.* $(FINALDIR)\keykit\lib
	copy bin\sweep.cur $(FINALDIR)\keykit
	copy bin\nothing.cur $(FINALDIR)\keykit
	copy bin\keykit.ico $(FINALDIR)\keykit

install_nt_python :
	-mkdir bin
	$(MK) clean
	cd byacc && $(MK) -f makefile.$(MSTYPE) all
	$(MK) copy_nt_python
	cd src && $(MK) clean && rm -f d_*.h
	cd src && $(MK) install
	
install_nt_1 :
	-mkdir bin
	$(MK) clean
	cd byacc && $(MK) -f makefile.$(MSTYPE) all
	$(MK) copy_ntcons
	cd src && $(MK) clean && rm -f d_*.h
	cd src && $(MK) install

install_nt_2 :
	cd src && $(MK) clean && rm -f d_*.h
	cd src && $(MK) install
	cd doc && $(MK) all

# Windows NT (and 95) version
copy_nt :
	cp mdep/nt/key.sln src/key.sln
	cp mdep/nt/key.vcxproj src/key.vcxproj
	cp mdep/nt/makefile src/makefile
	cp mdep/nt/mdep1.c src/mdep1.c
	cp mdep/nt/mdep2.c src/mdep2.c
	cp mdep/nt/mdep.h src/mdep.h
	cp mdep/nt/values.h src/values.h
	cp mdep/nt/midi.c src/midi.c
	cp mdep/nt/clock.c src/clock.c
	cp mdep/nt/keycap.cpp src/keycap.cpp
	cp mdep/nt/key.rc src/key.rc
	cp mdep/nt/*.cur src
	cp mdep/nt/*.ico src
	cp mdep/nt/resetkeylib.bat bin

copy_tjt : copy_nt
	cp mdep/nt/makefile.tjt src/makefile

# Windows Python module
copy_nt_python :
	cp mdep/winpython/pykeykit.pyx src/pykeykit.pyx
	cp mdep/winpython/keykit.py src/keykit.py
	cp mdep/winpython/makefile src/makefile
	cp mdep/winpython/mdep1.c src/mdep1.c
	cp mdep/winpython/mdep2.c src/mdep2.c
	cp mdep/winpython/mdep.h src/mdep.h
	cp mdep/winpython/values.h src/values.h
	cp mdep/winpython/midi.c src/midi.c
	cp mdep/winpython/clock.c src/clock.c
	cp mdep/winpython/keycap.cpp src/keycap.cpp
	cp mdep/winpython/key.rc src/key.rc
	cp mdep/winpython/*.cur src
	cp mdep/winpython/*.ico src
	cp mdep/winpython/resetkeylib.bat bin

# Windows NT (and 95) version
copy_ntshare :
	cp mdep/ntshare/makefile src/makefile
	cp mdep/ntshare/mdep1.c src/mdep1.c
	cp mdep/ntshare/mdep2.c src/mdep2.c
	cp mdep/ntshare/mdep.h src/mdep.h
	cp mdep/ntshare/values.h src/values.h
	cp mdep/ntshare/midi.c src/midi.c
	cp mdep/ntshare/clock.c src/clock.c
	cp mdep/ntshare/key.rc src/key.rc
	cp mdep/ntshare/*.cur src
	cp mdep/ntshare/*.ico src
	cp mdep/ntshare/resetkeylib.bat bin

# NT (and 95) "stdio" version
copy_ntcons :
	cp mdep/ntcons/mdep1.c src/mdep1.c
	cp mdep/ntcons/mdep2.c src/mdep2.c
	cp mdep/ntcons/mdep.h src/mdep.h
	cp mdep/ntcons/makefile src/makefile
	cp mdep/ntcons/clock.c src/clock.c
	cp mdep/ntcons/midi.c src/midi.c
	cp mdep/ntcons/*.cur src
	cp mdep/ntcons/*.ico src
	cp mdep/nt/resetkeylib.bat bin

install_ntcons :
	$(MK) copy_ntcons
	cd src && $(MK) clean
	cd src && $(MK) install

# clean for NT (and 95)
clean_nt :
	$(MK) copy_nt
	cd src && $(MK) clean
	cd byacc && $(MK) -f makefile.stdio clobber
	cd doc && $(MK) clean
	cd tests && $(MK) clean_nt
	rm -f bin/last.kp

clobber_nt : clean_nt
	rm -f *~
	cd src && $(MK) clobber
	cd doc && $(MK) clobber
	cd lib && $(MK) clobber
	rm -fr mdep/nt/x64
	rm -f bin/key.dbg
	rm -f bin/key.exe
	rm -f bin/keylib.exe
	rm -f bin/keydll.dll
	rm -f bin/*.ico
	rm -f bin/*.cur
	rm -f bin/keykit.py
	rm -f bin/pykeykit.pyd
	rm -f bin/lowkey.exe
	rm -f src/d_*.h
	rm -f src/win32.mak
	rm -f src/clock.c
	rm -f src/makefile
	rm -f tmp.diff
	cd byacc && $(MK) -f makefile.$(MSTYPE) clobber

# complete compile/regression test (for NT and 95)
regress_nt :
	$(MK) copy_ntcons
	cd src && $(MK) clean && $(MK) install
	cd tests && $(MK)

# clean for linux
clean_stdio :
	$(MK) copy_stdio
	cd src ; $(MK) clean
	cd byacc ; $(MK) -f makefile.stdio clobber
	cd doc ; $(MK) clean
	cd tests ; $(MK) clean_stdio

clobber_stdio : clean_stdio
	rm -f */core
	cd src ; $(MK) clobber
	rm -f bin/lowkey bin/key
	cd byacc ; $(MK) -f makefile.stdio clobber

bindir :
	if [ ! -d bin ] ; then mkdir bin ; fi

###################
# The stuff here is specific to constructing the distribution.
###################

distribution_nt :
	$(MK) install_nt
	rm -fr dist/nt dist/key_nt.zip
	mkdir dist/nt
	mkdir dist/nt/key
	mkdir dist/nt/key/bin
	mkdir dist/nt/key/lib
	mkdir dist/nt/key/music
	cp bin/key bin/lowkey dist/nt/key/bin
	cp lib/* dist/nt/key/lib
	cp music/* dist/nt/key/music
	cd dist/nt && $(ZIP32) -r ../key_nt.zip key
	rm -fr dist/nt

tjt :
	cd dist/nt && $(ZIP32) -r ../key_nt.zip key
	rm -fr dist/nt

senddownload :
	senddownload

updateversion :
	sed -e "/KEYKITVERSION/s/Version ..../Version $(VERSION)/" < index.html > tmp.html
	mv tmp.html index.html
	cd src
	sed -e /define.KEYVERSION/s/'"'.*'"'/'"'$(VERSION)'"'/ < key.h > key2.h
	mv key2.h key.h
	sed -e /Copyright/s/KeyKit.*' - '/KeyKit' '$(VERSION)' - '/ < main.c > main2.c
	mv main2.c main.c
	cd ..
	cd mdep/nt
	sed -e /VERSION/s/'"'KeyKit.*'"'/'"'KeyKit' '($(VERSION))'"'/ < key.rc > key2.rc
	mv key2.rc key.rc
	cd ../..
	cd doc
	sed -e "/ds.KV/s/KV.*/KV $(VERSION)/" < macros > nmacros
	mv nmacros macros
	sed -e "/var=.KEYKITVERSION/s/Version ..../Version $(VERSION)/" < tutorial.xml > tmp.xml
	mv tmp.xml tutorial.xml
	sed -e "/var=.KEYKITVERSION/s/Version ..../Version $(VERSION)/" < language.xml > tmp.xml
	mv tmp.xml language.xml
	sed -e "/var=.KEYKITVERSION/s/Version ..../Version $(VERSION)/" < hacking.xml > tmp.xml
	mv tmp.xml hacking.xml
	cd ..
	cd mdep/winsetup
	cd ../..
	echo $(VERSION) > VERSION

DISTPREFIX=dist\$(KS)

setup :
	cd doc && $(MK) all
	$(MK) packitup
	$(MK) ziponly

ziponly :
	mv mdep\winsetup\key$(SUFF).zip dist\key$(SUFF)_win.zip

PREDIR = mdep/winsetup/key$(SUFF)
PREDIR2 = mdep\winsetup\key$(SUFF)

# This 'find' command must be the MKS toolkit find, or something similar
FIND = c:\cygwin64\bin\find

WINDOWS10SDK = 10.0.17763.0
REDIST = "c:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\redist\debug_nonredist\x64\Microsoft.VC140.DebugCRT"
UCRT = "c:\Program Files (x86)\Windows Kits\10\bin\$(WINDOWS10SKD)\x64\ucrt"

packitup :
	copy $(REDIST)\vcruntime140d.dll bin
	copy $(UCRT)\ucrtbased.dll bin
	rm -fr $(PREDIR)
	mkdir $(PREDIR2)
	$(FIND) ./lib ./music $(OTHERDIRS) | grep -v .doc$$ > tmp.lst
	$(FIND) ./bin/resetkeylib.bat >> tmp.lst
	$(FIND) ./bin/key.exe>> tmp.lst
	$(FIND) ./bin/lowkey.exe>> tmp.lst
	$(FIND) ./bin/vcruntime140d.dll >> tmp.lst
	$(FIND) ./bin/ucrtbased.dll >> tmp.lst
	$(FIND) ./bin -name "*.py" >> tmp.lst
	$(FIND) ./bin -name "*.ico" >> tmp.lst
	$(FIND) ./bin -name "*.cur" >> tmp.lst
	$(FIND) ./bin -name "*.pyd" >> tmp.lst
	$(FIND) ./doc -name "*.html" >> tmp.lst
	$(FIND) ./lib -name "*.html" >> tmp.lst
	$(FIND) ./contrib >> tmp.lst
	$(FIND) ./index.html>> tmp.lst
	$(FIND) ./doc/history>> tmp.lst
	$(FIND) ./doc/multiport>> tmp.lst
	$(FIND) ./LICENSE.txt>> tmp.lst
	$(WINRMCR) tmp.lst
	-cat tmp.lst | xargs -n 1 --replace=xxx cp -r --parents xxx $(PREDIR)
	cd mdep\winsetup && chmod ugo+rwx key$(SUFF) && $(ZIP32) -r key$(SUFF).zip key$(SUFF)

netdownload :
	-cd doc && cp *.html ..\dist
	$(MK) clobber_nt
	pwd
	$(FIND) mdep\winsetup\$(KS) -print | grep -vi $(KS)/local | grep -vi $(KS)/dist | grep -vi /mdep/winsetup | grep -vi /mdep/old | grep -vi /doc/electromusic2005 | grep -vi $(KS)/win > tmp.lst
	cat tmp.lst | grep -vi /bin/ | grep -vi /sh_histo > tmp2.lst
	cat tmp2.lst | grep -vi /mdep/mac/.*.macbin | grep -vi /mdep/mac/.*.sit | grep -vi /doc/fulltalk | grep -vi /doc/keykit2002.ppt | grep -vi /doc/examp*.bmp > tmp.lst
	$(WINRMCR) tmp.lst
	-tar --files-from=tmp.lst --no-recursion --create --file=dist/$(KS)_src.tar
	cd dist
	rm -fr $(KS)
	mkdir $(KS)
	cd $(KS) && tar xf ../$(KS)_src.tar
	pwd
	rm -f $(KS)_src.zip
	chmod ugo+rwx $(KS)
	$(ZIP32) -rq $(KS)_src.zip $(KS)
	rm -fr $(KS)
	rm -fr linux
	mkdir linux
	cd linux
	rm -fr $(KS)
	mkdir $(KS)
	mkdir $(KS)\bin
	mkdir $(KS)\lib
	mkdir $(KS)\doc
	mkdir $(KS)\music
	cp ../../music/* $(KS)/music
	cp ../../dist/*.html $(KS)/doc
	cp ../../doc/history $(KS)/doc
	cp ../../doc/keykit2003.ppt $(KS)/doc
	-cp ../../lib/* $(KS)/lib
	rm -fr $(KS)/lib/*.doc
	cp ../../README.linux $(KS)
	cp ../../makefile $(KS)
	cp ../../LICENSE.txt $(KS)
	cp ../../bin/resetkeylib $(KS)/bin
	tar cf $(KS)_linux.tar $(KS)
	mv $(KS)_linux.tar ..
	rm -fr $(KS)
	cd ..
	cd ..

flip_all:
	$(RMCR) src/*.c src/*.h src/makefile
	$(RMCR) lib/* mdep/*/*
	$(RMCR) tests/*
	echo 'flip done' > flip_all

#########################################################
# UNIX/Linux stdio version
#########################################################

copy_stdio : bindir
	cp mdep/stdio/mdep1.c src/mdep1.c
	cp mdep/stdio/mdep2.c src/mdep2.c
	cp mdep/stdio/mdep.h src/mdep.h
	cp mdep/stdio/makefile src/makefile
	cp mdep/stdio/clock.c src/clock.c
	cp mdep/stdio/midi.c src/midi.c
	chmod +x $(RMCR)
	$(RMCR) src/*.c src/*.h src/makefile
	$(RMCR) lib/*
	cp mdep/stdio/resetkeylib bin
	$(RMCR) bin/resetkeylib
	chmod +x bin/resetkeylib
	-$(RMCR) tests/*

install_stdio :
	$(MK) copy_stdio
	cd byacc ; $(MK) -f makefile.stdio clobber ; $(MK) -f makefile.stdio
	cd src ; $(MK) clean ; $(MK) install

regress_stdio :
	$(MK) install_stdio
	-$(RMCR) tests/*
	cd tests ; sh keytest.sh

#########################################################
# UNIX X Windows version without MIDI
#########################################################

copy_x : bindir
	cp mdep/x/mdep1.c src/mdep1.c
	cp mdep/x/mdep2.c src/mdep2.c
	cp mdep/x/mdep.h src/mdep.h
	cp mdep/x/makefile src/makefile
	cp mdep/x/bsdclock.c src/clock.c
	cp mdep/x/tjt.ico src/tjt.ico
	cp mdep/x/keykit.ico src/keykit.ico
	cp mdep/x/nullmidi.c src/midi.c
	$(RMCR) src/*.c src/*.h src/*.ico src/makefile
	$(RMCR) lib/*
	cp mdep/stdio/resetkeylib bin
	$(RMCR) bin/resetkeylib
	chmod +x bin/resetkeylib
	-$(RMCR) tests/*

#########################################################
# Linux X Windows version with MIDI
#########################################################

copy_linux_alsa : bindir
	cp mdep/linux_alsa/mdep1.c src/mdep1.c
	cp mdep/linux_alsa/mdep2.c src/mdep2.c
	cp mdep/linux_alsa/mdep.h src/mdep.h
	cp mdep/linux_alsa/makefile src/makefile
	cp mdep/linux_alsa/bsdclock.c src/clock.c
	cp mdep/linux_alsa/tjt.ico src/tjt.ico
	cp mdep/linux_alsa/keykit.ico src/keykit.ico
	cp mdep/linux_alsa/midi.c src/midi.c
	$(RMCR) src/*.c src/*.h src/*.ico src/makefile
	$(RMCR) lib/* tests/makefile
	cp mdep/stdio/resetkeylib bin
	$(RMCR) bin/resetkeylib
	chmod +x bin/resetkeylib
	chmod ugo+w */keylib.k
	-$(RMCR) tests/*

copy_raspbian : bindir
	cp mdep/raspbian/mdep1.c src/mdep1.c
	cp mdep/raspbian/mdep2.c src/mdep2.c
	cp mdep/raspbian/mdep.h src/mdep.h
	cp mdep/raspbian/makefile src/makefile
	cp mdep/raspbian/bsdclock.c src/clock.c
	cp mdep/raspbian/tjt.ico src/tjt.ico
	cp mdep/raspbian/keykit.ico src/keykit.ico
	cp mdep/raspbian/midi.c src/midi.c
	$(RMCR) src/*.c src/*.h src/*.ico src/makefile
	$(RMCR) lib/* tests/makefile
	cp mdep/stdio/resetkeylib bin
	$(RMCR) bin/resetkeylib
	chmod +x bin/resetkeylib
	chmod ugo+w */keylib.k
	-$(RMCR) tests/*

install_raspbian:
	$(MK) clean_stdio
	$(MK) install_stdio
	$(MK) clean_raspbian
	$(MK) copy_raspbian
	cd src ; $(MK) install

clean_raspbian :
	$(MK) copy_raspbian
	cd src ; $(MK) clean
	cd byacc ; $(MK) -f makefile.stdio clobber
	cd doc ; $(MK) clean
	cd tests ; $(MK) clean_stdio

clobber_raspbian : clean_raspbian
	rm -f */core
	cd src && $(MK) clobber
	cd doc && $(MK) clobber
	cd lib && $(MK) clobber
	rm -f bin/lowkey bin/key
	cd byacc ; $(MK) -f makefile.stdio clobber
	rm -f src/makefile

distribution_raspbian :
	$(MK) install_raspbian
	rm -fr dist/raspbian dist/key_raspbian.zip
	mkdir dist/raspbian
	mkdir dist/raspbian/key
	mkdir dist/raspbian/key/bin
	mkdir dist/raspbian/key/lib
	mkdir dist/raspbian/key/music
	cp bin/key bin/lowkey dist/raspbian/key/bin
	cp lib/* dist/raspbian/key/lib
	cp music/* dist/raspbian/key/music
	cd dist/raspbian ; zip -r ../key_raspbian.zip key
	rm -fr dist/raspbian

bindir :

install_linux_alsa: bindir
	$(MK) install_stdio
	$(MK) copy_linux_alsa
	cd src ; $(MK) install

distribution_linux_alsa :
	rm -fr dist/linux_alsa dist/key_linux_alsa.zip
	mkdir dist/linux_alsa
	mkdir dist/linux_alsa/key
	mkdir dist/linux_alsa/key/bin
	mkdir dist/linux_alsa/key/lib
	mkdir dist/linux_alsa/key/music
	cp bin/key bin/lowkey dist/linux_alsa/key/bin
	cp lib/* dist/linux_alsa/key/lib
	cp music/* dist/linux_alsa/key/music
	cd dist/linux_alsa ; zip -r ../key_linux_alsa.zip key
	rm -fr dist/linux_alsa


##########################################
# The targets below here are old - probably still largely usable, but
# untested for some time.
##########################################

# SVR4, with X and /dev/smid driver
svr4 :
	cp mdep/svr4/mdep1.c src/mdep1.c
	cp mdep/svr4/mdep2.c src/mdep2.c
	cp mdep/svr4/mdep.h src/mdep.h
	cp mdep/svr4/makefile src/makefile
	cp mdep/svr4/clock.c src/clock.c
	cp mdep/svr4/tjt.ico src/tjt.ico
	cp mdep/svr4/keykit.ico src/keykit.ico
	cp mdep/svr4/midi.c src/midi.c
	$(RMCR) src/*.c src/*.h src/*.ico src/makefile
	$(RMCR) lib/*

