CC = gcc
CFLAGS = -Wall -Wextra -O
STATIC = -static

PROTO = -p
BIN=../bin

KEYOBJ = yacc.o main.o util.o misc.o phrase.o sym.o keyto.o \
	code.o code2.o grid.o view.o menu.o task.o fifo.o \
	mfin.o real.o mdep1.o mdep2.o kwind.o fsm.o bltin.o \
	meth.o regex.o midi.o clock.o tracek.o

KEYFILES = main util misc phrase sym keyto yacc \
	code code2 grid view menu task fifo \
	mfin real mdep1 mdep2 kwind fsm bltin meth \
	regex midi clock

ALLDECS = d_code.h d_code2.h d_fsm.h d_grid.h d_keyto.h d_main.h d_mdep1.h \
	d_menu.h d_mfin.h d_midi.h d_misc.h d_phrase.h d_real.h d_sym.h \
	d_util.h d_view.h d_task.h d_fifo.h d_kwind.h d_regex.h d_bltin.h \
	d_meth.h d_clock.h d_mdep2.h d_tracek.h

libs =  libc.lib kernel32.lib user32.lib gdi32.lib winmm.lib comdlg32.lib

all : lowkey

install : all
	cp lowkey ../bin/lowkey
	cd ../bin ; ./resetkeylib

lowkey : protoflp $(ALLDECS) $(KEYOBJ)
	$(CC) $(STATIC) $(CFLAGS) $(KEYOBJ) -lm -o lowkey

protoflp : protoflp.c
	$(CC) $(STATIC) protoflp.c -o protoflp

keylib : keylib.o mdep1.o misc.o
	$(CC) $(STATIC) keylib.o mdep1.o misc.o -o keylib

.c.o:
	$(CC) $(CFLAGS) -c $*.c

yacc.c : gram.y
	../byacc/byacc -d gram.y
	mv y_tab.c yacc.c
	mv y_tab.h yacc.h

procfont : procfont.c
	$(WINCC) procfont.c

protoproc : protoflp
	for %%f in ($(KEYFILES)) do protoflp -p -d d_%%f.h < %%f.c > tmp.c
	rm -f tmp.c

clean :
	rm -f d_*.h
	rm -f *.o lowkey protoflp keylib

clobber : clean
	rm -f d_*.h
	rm -f yacc.c
	rm -f yacc.h
	rm -f y_output
	rm -f mdep.h mdep1.c mdep2.c midi.c clock.c tmp.c
	rm -f key
	rm -f keykit.ico tjt.ico

# Using protoflp, Create d_xx.h from xx.c (using d_xx_h.tmp temp file):
# 1) if d_xx.h doesn't exist
# 2) if d_xx.h is different than previous d_xx.h
# 3) if d_xx.h is older than xx.c
d_%.h: %.c
	@./protoflp $(PROTO) -dd_$*_h.tmp < $*.c > d_$*_c.tmp; \
	rm -f d_$*_c.tmp; \
	cmp -s d_$*_h.tmp d_$*.h; \
	test \( $$? -ne 0 \) -o \( $*.c -nt d_$*.h \); \
	if [ $$? -eq 0 ]; then \
		echo "generate 'd_$*.h'"; \
		mv -f d_$*_h.tmp d_$*.h; \
	else \
		rm -f d_$*_h.tmp; \
	fi

mdepback :
	cp mdep1.c ../mdep/stdio/mdep1.c
	cp mdep2.c ../mdep/stdio/mdep2.c
	cp mdep.h ../mdep/stdio/mdep.h
	cp makefile ../mdep/stdio/makefile
	cp clock.c ../mdep/stdio/clock.c
	cp midi.c ../mdep/stdio/midi.c
