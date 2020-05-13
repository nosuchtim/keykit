# Copyright 1996 AT&T Corp.  All rights reserved.
#
#       KeyKit has been ported to many environments in its lifetime,
#       however the most recent version has only been tested in the
#       environments described below.
#
#       Windows 95 - to compile, use "nmake install_nt".  This will
#                    copy binaries into the bin directory.
#                    You can also compile a "console" version by
#                    doing "nmake install_ntcons" - that version
#                    doesn't make use of any graphics - this is
#                    possibly better for scripting uses, and can be
#                    used to run the regression tests (make regress).
#                    The Win95 version has worked in the past on Windows NT,
#                    and should probably work on NT without any changes.
#                    It also runs pretty well using Win32s on Windows 3.1,
#                    except that MIDI system-exclusive messages don't work.
#
#	UNIX/Linux (stdio) - To compile, change the definition of MK to make,
#                    and change RMCR to the name of a program that will
#                    remove DOS-style carriage returns from text files
#		     (e.g mdep/linux/flip). Then use "make install_stdio".
#		     Use "make regress_stdio" to run the regression tests.
#
#	UNIX (X Windows) - To compile, follow the instructions above for
#                    the stdio version, then use "make install_x".
#
#	Linux (X Windows) - To compile, follow the instructions above for
#                    the stdio version, then use "make install_linux_x".
#
#	FreeBSD (stdio) - To compile, follow the instructions above for
#                    the stdio version, then use "make install_fbsd_stdio".
#
#	FreeBSD (X Windows) - To compile, follow the instructions above for
#                    the stdio version, then use "make install_fbsd_x".
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
MK = nmake
MK = make

# set RMCR to the name of a program that will remove carriage-returns
# (i.e. flip text files to "unix" mode)
RMCR = rmcr
RMCR = flip -u

VERSION=6.2a
SUFF=62a
KS = key$(SUFF)

default :
	@echo "No default.  Read the makefile."

install : install_nt

clean : clean_nt

clobber : clobber_nt

regress : regress_nt

install_nt : updateversion
	$(MK) clean
	cd byacc
	$(MK) -f makefile.msc all
	cd ..
	$(MK) copy_nt
	cd src
	$(MK) clean
	$(MK) install
	cd ..

# Windows NT (and 95) version
copy_nt :
	copy mdep\nt\makefile src\makefile
	copy mdep\nt\mdep1.c src\mdep1.c
	copy mdep\nt\mdep2.c src\mdep2.c
	copy mdep\nt\mdep.h src\mdep.h
	copy mdep\nt\values.h src\values.h
	copy mdep\nt\midi.c src\midi.c
	copy mdep\nt\clock.c src\clock.c
	copy mdep\nt\keydll.c src\keydll.c
	copy mdep\nt\keydll.h src\keydll.h
	copy mdep\nt\keydll.def src\keydll.def
	copy mdep\nt\key.rc src\key.rc
	copy mdep\nt\*.cur src
	copy mdep\nt\*.ico src

# NT (and 95) "stdio" version
copy_ntcons :
	cp mdep/ntcons/mdep1.c src/mdep1.c
	cp mdep/ntcons/mdep2.c src/mdep2.c
	cp mdep/ntcons/mdep.h src/mdep.h
	cp mdep/ntcons/makefile src/makefile
	cp mdep/ntcons/clock.c src/clock.c
	cp mdep/ntcons/midi.c src/midi.c

install_ntcons :
	$(MK) copy_ntcons
	cd src
	$(MK) clean
	$(MK) install

# clean for NT (and 95)
clean_nt :
	$(MK) copy_nt
	cd src
	$(MK) clean
	cd ..
	cd byacc
	$(MK) -f makefile.msc clobber
	cd ..
	cd doc
	$(MK) clean
	cd ..
	cd tests
	$(MK) clean
	cd ..
	cd mdep\winsetup
	$(MK) clean
	cd ..\..

clobber_nt : clean
	cd src
	$(MK) clobber
	cd ..
	deltree /y bin\key.exe
	deltree /y bin\keydll.dll
	deltree /y bin\keylib.exe
	deltree /y bin\lowkey.exe
	deltree /y src\d_*.h
	cd byacc
	$(MK) -f makefile.msc clobber
	cd ..

# complete compile/regression test (for NT and 95)
regress_nt :
	$(MK) copy_ntcons
	cd src
	$(MK) clean
	$(MK) install
	cd ..\tests
	$(MK)
	cd ..

###################
# The stuff here is specific to constructing the distribution.
###################

distribution :
	nmake winsetup
	nmake netdownload

# Complete a complete Windows distribution from scratch
winsetup :
	$(MK) clobber
	$(MK) install_nt
	$(MK) install_ntcons
	$(MK) setup

updateversion :
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
	cd ..
	cd mdep/winsetup
	sed -e /APP_NAME/s/'"'.*'"'/'"'KeyKit" $(VERSION)"'"'/ < setup.rul > setup2.rul
	sed -e /define.*PRODUCT_VERSION/s/'"'.*'"'/'"'"$(VERSION)"'"'/ < setup2.rul > setup.rul
	deltree /y setup2.rul
	cd ../..

DISTPREFIX=dist\key$(SUFF)

setup :
	cd doc
	$(MK) all
	cd ..
	$(MK) packitup
	$(MK) setuponly

setuponly :
	cd mdep\winsetup
	nmake
	cd ..\..
	mv mdep\winsetup\keyinst.exe $(DISTPREFIX).exe

PREDIR = mdep\winsetup\data

# This 'find' command must be the MKS toolkit find, or something similar
FIND = mksfind

packitup :
	deltree /y $(PREDIR)
	mkdir $(PREDIR)
	deltree /y tmp.lst
	$(FIND) ./liblocal ./lib ./music | grep -v .doc$$ > tmp.lst
	echo ./bin/keylib.exe >> tmp.lst
	echo ./bin/key.exe >> tmp.lst
	echo ./bin/lowkey.exe >> tmp.lst
	echo ./bin/keydll.dll >> tmp.lst
	echo ./LICENSE >> tmp.lst
	$(FIND) ./doc -name "*.txt" >> tmp.lst
	$(FIND) ./doc -name "*.ps" >> tmp.lst
	$(FIND) ./doc -name "*.hlp" >> tmp.lst
	echo ./doc/history >> tmp.lst
	echo ./doc/porting >> tmp.lst
	cat tmp.lst | cpio -pdmuv $(PREDIR)
#	deltree /y tmp.lst

netdownload :
	cd doc
	cp *.ps *.txt *.hlp ..\dist
	cd ..
	$(MK) clobber
	cd ..
	$(FIND) $(KS) -print | grep -vi $(KS)/museomat | grep -vi $(KS)/old | grep -vi $(KS)/dist | grep -vi /mdep/winsetup | grep -vi /mdep/old > tmp.lst
	cat tmp.lst | grep -vi /bin/ | grep -vi $(KS)/demo | grep -vi /sh_histo | grep -vi $(KS)/savmusic > tmp2.lst
	cat tmp2.lst | grep -vi $(KS)/kc | grep -vi /mdep/mac/.*.macbin | grep -vi /mdep/mac/.*.sit > tmp.lst
	cpio -co -O $(KS)/dist/$(KS)_src.cpio < tmp.lst
	cd key$(SUFF)
	cd dist
	cpio -cildum < $(KS)_src.cpio
	zip32 -r $(KS)_src.zip $(KS)
	tar cfv $(KS)_src.tar $(KS)
	deltree /y $(KS)_src.tar.Z
	compress -v $(KS)_src.tar
	deltree /y $(KS)
	deltree /y $(KS)_src.cpio
	cd linux
	mkdir $(KS)
	mkdir $(KS)\bin
	mkdir $(KS)\lib
	mkdir $(KS)\liblocal
	mkdir $(KS)\doc
	mkdir $(KS)\music
	cp ..\..\dist\*.ps $(KS)\doc
	cp ..\..\music\* $(KS)\music
	cp ..\..\lib\* $(KS)\lib
	deltree /y $(KS)\lib\*.doc
	cp ..\..\liblocal\* $(KS)\liblocal
	cp ..\..\README.linux $(KS)
	cp ..\..\LICENSE $(KS)
	cp key $(KS)\bin
	cp lowkey $(KS)\bin
	cp keylib $(KS)\bin
	tar cfv $(KS)_linux.tar $(KS)
	deltree /y $(KS)_linux.tar.Z
	compress -v $(KS)_linux.tar
	mv $(KS)_linux.tar.Z ..
	deltree /y $(KS)
	cd ..
	cd ..

flip_all:
	$(RMCR) src/*.c src/*.h src/makefile
	$(RMCR) lib/* liblocal/* mdep/*/*
	$(RMCR) tests/*
	echo 'flip done' > flip_all

#########################################################
# UNIX/Linux stdio version
#########################################################

copy_stdio: flip_all
	cp mdep/stdio/mdep1.c src/mdep1.c
	cp mdep/stdio/mdep2.c src/mdep2.c
	cp mdep/stdio/mdep.h src/mdep.h
	cp mdep/stdio/makefile src/makefile
	cp mdep/stdio/clock.c src/clock.c
	cp mdep/stdio/midi.c src/midi.c

install_stdio :
	$(MK) copy_stdio
	cd byacc ; $(MK) -f makefile.sun clobber ; $(MK) -f makefile.sun
	cd src ; $(MK) clean ; $(MK) install

regress_stdio : flip_all
	cd tests ; sh keytest.sh

#########################################################
# UNIX X Windows version without MIDI
#########################################################

copy_x : flip_all
	cp mdep/x/mdep1.c src/mdep1.c
	cp mdep/x/mdep2.c src/mdep2.c
	cp mdep/x/mdep.h src/mdep.h
	cp mdep/x/makefile src/makefile
	cp mdep/x/bsdclock.c src/clock.c
	cp mdep/x/tjt.ico src/tjt.ico
	cp mdep/x/keykit.ico src/keykit.ico
	cp mdep/x/nullmidi.c src/midi.c

# For X Windows (with GNU C):
install_x:
	$(MK) copy_x
	cd byacc ; $(MK) -f makefile.sun clobber ; $(MK) -f makefile.sun
	cd src ; $(MK) clobber ; $(MK) install

#########################################################
# FreeBSD X Windows and stdio versions
#########################################################

src/makefile_freebsd:
	$(MK) copy_stdio
	cp mdep/freebsd/makefile_stdio src/makefile
	ln src/makefile src/makefile_freebsd

install_fbsd_stdio: src/makefile_freebsd
	cd src ; $(MK) clean ; $(MK) install

src/freebsd_mdep.h:
	$(MK) copy_x
	cp mdep/freebsd/* src
	ln src/mdep.h src/freebsd_mdep.h

# For FreeBSD and X Windows (with GNU C):
install_fbsd_x: src/freebsd_mdep.h
	cd src ; $(MK) clobber ; $(MK) install

#########################################################
# Linux X Windows version with MIDI
#########################################################

copy_linux: flip_all
	cp mdep/linux/mdep1.c src/mdep1.c
	cp mdep/linux/mdep2.c src/mdep2.c
	cp mdep/linux/mdep.h src/mdep.h
	cp mdep/linux/makefile src/makefile
	cp mdep/linux/bsdclock.c src/clock.c
	cp mdep/linux/tjt.ico src/tjt.ico
	cp mdep/linux/keykit.ico src/keykit.ico
	cp mdep/linux/midi.c src/midi.c

install_linux_x:
	$(MK) copy_linux
	cd byacc ; $(MK) -f makefile.sun clobber ; $(MK) -f makefile.sun
	cd src ; $(MK) clobber ; $(MK) install

##########################################
# The targets below here are old - probably still largely usable, but
# untested for some time.
##########################################

# Watcom "stdio" version
wat :
	cp mdep/wat/mdep1.c src/mdep1.c
	cp mdep/wat/mdep2.c src/mdep2.c
	cp mdep/wat/mdep.h src/mdep.h
	cp mdep/wat/makefile src/makefile
	cp mdep/wat/clock.c src/clock.c
	cp mdep/wat/midi.c src/midi.c

# SVR4, with X and /dev/smid driver
svr4:	flip_all
	cp mdep/svr4/mdep1.c src/mdep1.c
	cp mdep/svr4/mdep2.c src/mdep2.c
	cp mdep/svr4/mdep.h src/mdep.h
	cp mdep/svr4/makefile src/makefile
	cp mdep/svr4/clock.c src/clock.c
	cp mdep/svr4/tjt.ico src/tjt.ico
	cp mdep/svr4/keykit.ico src/keykit.ico
	cp mdep/svr4/midi.c src/midi.c
