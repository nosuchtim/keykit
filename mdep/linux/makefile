#
#	Copyright 1996 AT&T Corp.  All rights reserved.
#
#	keykit - a language for musical expressions
#

CC = gcc
STATIC =
SOUNDLIBS = /usr/lib/x86_64-linux-gnu/libasound.so.2 -L/usr/lib/ -lpthread -ldl
XLIBS = /usr/lib/x86_64-linux-gnu/libX11.so.6 -lm
INC = -I/usr/include/
KEY = key

# Valid values of PROTO are -n (don't use prototypes) and -p (use prototypes).
# After changing PROTO, run "make protoproc".
PROTO = -p

BIN=../bin
EXECS = $(KEY)
OBJS = yacc.o sym.o real.o code.o code2.o main.o util.o mdep1.o mfin.o \
	phrase.o misc.o fsm.o grid.o view.o midi.o clock.o mdep2.o \
	keyto.o regex.o task.o fifo.o kwind.o menu.o bltin.o meth.o tracek.o
SRC = real.c yacc.c code.c code2.c sym.c main.c util.c mdep1.c mfin.c \
	phrase.c misc.c fsm.c grid.c view.c midi.c clock.c mdep2.c \
	keyto.c regex.c task.c fifo.c kwind.c menu.c bltin.c meth.c tracek.c
PROFILE = -g
CFLAGS = -Wall -Wextra -O $(INC) $(PROFILE)

all : $(EXECS)

demo :
	del real.obj
	del sym.obj
	make install
	del real.obj
	del sym.obj

install : all
	cp $(KEY) $(BIN)/$(KEY)
	cd ../src

protoproc : protoflp
	-@for i in $(SRC) ; do \
		b=`basename $$i .c` ; \
		echo "protoflp $(PROTO) $$i ...\\c" ; \
		./protoflp $(PROTO) -d d_$$b.h < $$i > tmp.c ; \
		r=$$? ; oldsize=`wc -c < $$i` ; newsize=`wc -c < tmp.c` ; \
		sizediff=`expr $$oldsize - $$newsize` ; \
		if [ $$sizediff -lt 0 ] ; \
		then \
			sizediff=`expr 0 - $$sizediff` ; \
		fi ; \
		cmp -s $$i tmp.c ; \
		q=$$? ; \
		if [ $$q -eq 0 ] ; \
		then \
			echo "okay - no change." ; \
		elif [ $$r -eq 0 -a $$sizediff -lt 800 ] ; \
		then \
			cp tmp.c $$i ; rm -f tmp.c ; \
			touch d_$$b.h ; \
			echo okay - $$i has been rewritten. ; \
		else \
			echo WARNING - $$i has NOT been rewritten! ; \
			echo    Reason: protoflp exit was $$r and sizediff was $$sizediff ; \
		fi ; \
	done ; exit 0

ALLDECS = d_code.h d_code2.h d_fsm.h d_grid.h d_keyto.h d_main.h d_mdep1.h \
	d_menu.h d_mfin.h d_midi.h d_misc.h d_phrase.h d_real.h d_sym.h \
	d_util.h d_view.h d_task.h d_fifo.h d_kwind.h d_regex.h d_bltin.h \
	d_clock.h d_meth.h d_mdep2.h d_tracek.h

# Using protoflp, Create d_xx.h from xx.c (using d_xx_h.tmp temp file):
# 1) if d_xx.h doesn't exist
# 2) if d_xx.h is different than previous d_xx.h
# 3) if d_xx.h is older than xx.c
d_%.h: %.c
	@./protoflp $(PROTO) -dd_$*_h.tmp < $*.c > /dev/null; \
	cmp -s d_$*_h.tmp d_$*.h; \
	test \( $$? -ne 0 \) -o \( $*.c -nt d_$*.h \); \
	if [ $$? -eq 0 ]; then \
		echo "generate 'd_$*.h'"; \
		mv -f d_$*_h.tmp d_$*.h; \
	else \
		rm -f d_$*_h.tmp; \
	fi


alldecs : $(ALLDECS)

$(KEY):	protoflp $(ALLDECS) $(OBJS)
	$(CC) $(STATIC) $(CFLAGS) $(OBJS) $(XLIBS) $(SOUNDLIBS) -o $(KEY)

.c.o:
	$(CC) $(CFLAGS) -c $*.c

trymidi:	trymidi.o
	$(CC) $(CFLAGS) trymidi.o $(SOUNDLIBS) -o trymidi

protoflp: protoflp.c
	$(CC) protoflp.c -o protoflp

keylib: keylib.o mdep1.o misc.o
	$(CC) $(STATIC) keylib.o mdep1.o misc.o -o keylib

mtest1:	mtest1.o midi.o
	$(CC) $(CFLAGS) mtest1.o midi.o $(LIBS) -o mtest1

PSTUFF = ptest0.o mdep1.o mdep2.o midi.o clock.o

ptest1:	ptest1.o $(PSTUFF)
	$(CC) $(CFLAGS) ptest1.o $(PSTUFF) $(XLIBS) -o ptest1

ptest2:	ptest2.o $(PSTUFF)
	$(CC) $(CFLAGS) ptest2.o $(PSTUFF) $(XLIBS) -o ptest2

ptest3:	ptest3.o $(PSTUFF)
	$(CC) $(CFLAGS) ptest3.o $(PSTUFF) $(XLIBS) -o ptest3

mdep.o: mdep.c
	$(CC) $(CFLAGS) -c mdep.c

bison.c : gram.y
	bison -d gram.y
	: Fix things to be more portable
	tr -d "\014" < gram.tab.c | sed \
		-e "/^#line/d" \
		-e "s/short/INT16/" \
		-e "s/^#include.*stdio.h.*//" \
		-e "s/^extern.*free();.*//" \
		-e '/print.*yytname/s/yytname.yychar1./((&==NULL)?"":&)/' \
		> bison.c
	rm -f gram.tab.c
	mv gram.tab.h bison.h

yacc.c : gram.y
	../byacc/byacc -d gram.y
	mv y_tab.c yacc.c
	mv y_tab.h yacc.h

lint :
	lint $(CFLAGS) $(SRC) | grep -v questionable | lintfilter

mdepback :
	cp mdep1.c mdep2.c mdep.h makefile ../mdep/linux
	cp tjt.ico keykit.ico ../mdep/linux
	cp clock.c ../mdep/linux/bsdclock.c
	cp midi.c ../mdep/linux

test :  all
	cd ../tests ; sh keytest.sh

clean:
	rm -f d_*.h
	rm -f *.o [xy].tab.[ch] yacc.acts yacc.debug yacc.tmp
	rm -f $(EXECS) ptest1 ptest2 ptest3 ptest4 protoflp

clobber: clean
	rm -f d_*.h yacc.c yacc.h
	rm -f mdep.h mdep1.c mdep2.c midi.c clock.c
	rm -f key.dbg lowkey tjt.ico keykit.ico
	rm -f key.dbg tmp.c
	rm -f *.arc setjmp.h setjmp.s pc-ints.asm y_output tmp.lint
	rm -f key
	if [ $(BIN) != "." ] ; then cd $(BIN) ; rm -f $(EXECS) ; fi
