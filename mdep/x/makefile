#
#	Copyright 1996 AT&T Corp.  All rights reserved.
#
#	keykit - a language for musical expressions
#

CC = gcc
INC = -I/usr/openwin/include
SOCKLIBS = -lsocket -lnsl
XLIBS = -L/usr/openwin/lib -L/usr/lib/X11 -lX11 -lm $(SOCKLIBS)

# Valid values of PROTO are -n (don't use prototypes) and -p (use prototypes).
# After changing PROTO, run "make protoproc".
PROTO = -p

BIN=../bin
EXECS = key keylib
OBJS = yacc.o sym.o real.o code.o code2.o main.o util.o mdep1.o mfin.o \
	phrase.o misc.o fsm.o grid.o view.o midi.o clock.o mdep2.o \
	keyto.o regex.o task.o fifo.o kwind.o menu.o bltin.o meth.o
SRC = real.c yacc.c code.c code2.c sym.c main.c util.c mdep1.c mfin.c \
	phrase.c misc.c fsm.c grid.c view.c midi.c clock.c mdep2.c \
	keyto.c regex.c task.c fifo.c kwind.c menu.c bltin.c meth.c
PROFILE = -g
CFLAGS = -O $(INC) $(PROFILE) -DDEMOTIMEOUT=0

all : $(EXECS)

install : all
	if [ $(BIN) != "." ] ; then cp $(EXECS) $(BIN) ; fi
	cd ../lib ; $(BIN)/keylib

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
	d_clock.h d_meth.h d_mdep2.h

d_regex.h : regex.c
	./protoflp $(PROTO) -dd_regex.h < regex.c > /dev/null
d_sym.h : sym.c
	./protoflp $(PROTO) -dd_sym.h < sym.c > /dev/null
d_bltin.h : bltin.c
	./protoflp $(PROTO) -dd_bltin.h < bltin.c > /dev/null
d_util.h : util.c
	./protoflp $(PROTO) -dd_util.h < util.c > /dev/null
d_phrase.h : phrase.c
	./protoflp $(PROTO) -dd_phrase.h < phrase.c > /dev/null
d_misc.h : misc.c
	./protoflp $(PROTO) -dd_misc.h < misc.c > /dev/null
d_main.h : main.c
	./protoflp $(PROTO) -dd_main.h < main.c > /dev/null
d_task.h : task.c
	./protoflp $(PROTO) -dd_task.h < task.c > /dev/null
d_fifo.h : fifo.c
	./protoflp $(PROTO) -dd_fifo.h < fifo.c > /dev/null
d_code.h : code.c
	./protoflp $(PROTO) -dd_code.h < code.c > /dev/null
d_code2.h : code2.c
	./protoflp $(PROTO) -dd_code2.h < code2.c > /dev/null
d_mdep1.h : mdep1.c
	./protoflp $(PROTO) -dd_mdep1.h < mdep1.c > /dev/null
d_mdep2.h : mdep2.c
	./protoflp $(PROTO) -dd_mdep2.h < mdep2.c > /dev/null
d_view.h : view.c
	./protoflp $(PROTO) -dd_view.h < view.c > /dev/null
d_grid.h : grid.c
	./protoflp $(PROTO) -dd_grid.h < grid.c > /dev/null
d_midi.h : midi.c
	./protoflp $(PROTO) -dd_midi.h < midi.c > /dev/null
d_clock.h : clock.c
	./protoflp $(PROTO) -dd_clock.h < clock.c > /dev/null
d_real.h : real.c
	./protoflp $(PROTO) -dd_real.h < real.c > /dev/null
d_fsm.h : fsm.c
	./protoflp $(PROTO) -dd_fsm.h < fsm.c > /dev/null
d_keyto.h : keyto.c
	./protoflp $(PROTO) -dd_keyto.h < keyto.c > /dev/null
d_mfin.h : mfin.c
	./protoflp $(PROTO) -dd_mfin.h < mfin.c > /dev/null
d_menu.h : menu.c
	./protoflp $(PROTO) -dd_menu.h < menu.c > /dev/null
d_kwind.h : kwind.c
	./protoflp $(PROTO) -dd_kwind.h < kwind.c > /dev/null
d_meth.h : meth.c
	./protoflp $(PROTO) -dd_meth.h < meth.c > /dev/null


alldecs : $(ALLDECS)

key:	protoflp $(ALLDECS) $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(XLIBS) -o key

protoflp: protoflp.c
	$(CC) protoflp.c -o protoflp

keylib: keylib.o mdep1.o misc.o
	$(CC) keylib.o mdep1.o misc.o -o keylib

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
	-rm -f gram.tab.c
	mv gram.tab.h bison.h

yacc.c : gram.y
	../byacc/byacc -d gram.y
	mv y_tab.c yacc.c
	mv y_tab.h yacc.h

lint :
	lint $(CFLAGS) $(SRC) | grep -v questionable | lintfilter

mdepback :
	cp mdep1.c mdep2.c mdep.h makefile ../mdep/x
	cp tjt.ico keykit.ico ../mdep/x
	cp clock.c ../mdep/x/bsdclock.c
	cp midi.c ../mdep/x/nullmidi.c

test :  all
	cd ../tests ; sh keytest.sh

clean:
	-rm -f *.o [xy].tab.[ch] yacc.acts yacc.debug yacc.tmp
	-rm -f $(EXECS) ptest1 ptest2 ptest3 ptest4 protoflp

clobber: clean
	-rm -f d_*.h yacc.c yacc.h
	-rm -f *.arc setjmp.h setjmp.s pc-ints.asm y_output tmp.lint
	-if [ $(BIN) != "." ] ; then cd $(BIN) ; rm -f $(EXECS) ; fi
