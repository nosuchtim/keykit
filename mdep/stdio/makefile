CC = gcc
CFLAGS = -Wall -Wextra -O
STATIC = -static

PROTO = -p
BIN=../bin

KEYOBJ = yacc.o main.o util.o misc.o phrase.o sym.o keyto.o \
	code.o code2.o grid.o view.o menu.o task.o fifo.o \
	mfin.o real.o mdep1.o mdep2.o kwind.o fsm.o bltin.o \
	meth.o regex.o midi.o clock.o

KEYFILES = main util misc phrase sym keyto yacc \
	code code2 grid view menu task fifo \
	mfin real mdep1 mdep2 kwind fsm bltin meth \
	regex midi clock

ALLDECS = d_code.h d_code2.h d_fsm.h d_grid.h d_keyto.h d_main.h d_mdep1.h \
	d_menu.h d_mfin.h d_midi.h d_misc.h d_phrase.h d_real.h d_sym.h \
	d_util.h d_view.h d_task.h d_fifo.h d_kwind.h d_regex.h d_bltin.h \
	d_meth.h d_clock.h d_mdep2.h

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

d_regex.h : regex.c
	./protoflp $(PROTO) -dd_regex.h < regex.c > tmp.c
d_sym.h : sym.c
	./protoflp $(PROTO) -dd_sym.h < sym.c > tmp.c
d_bltin.h : bltin.c
	./protoflp $(PROTO) -dd_bltin.h < bltin.c > tmp.c
d_meth.h : meth.c
	./protoflp $(PROTO) -dd_meth.h < meth.c > tmp.c
d_util.h : util.c
	./protoflp $(PROTO) -dd_util.h < util.c > tmp.c
d_phrase.h : phrase.c
	./protoflp $(PROTO) -dd_phrase.h < phrase.c > tmp.c
d_misc.h : misc.c
	./protoflp $(PROTO) -dd_misc.h < misc.c > tmp.c
d_main.h : main.c
	./protoflp $(PROTO) -dd_main.h < main.c > tmp.c
d_task.h : task.c
	./protoflp $(PROTO) -dd_task.h < task.c > tmp.c
d_fifo.h : fifo.c
	./protoflp $(PROTO) -dd_fifo.h < fifo.c > tmp.c
d_code.h : code.c
	./protoflp $(PROTO) -dd_code.h < code.c > tmp.c
d_code2.h : code2.c
	./protoflp $(PROTO) -dd_code2.h < code2.c > tmp.c
d_mdep1.h : mdep1.c
	./protoflp $(PROTO) -dd_mdep1.h < mdep1.c > tmp.c
d_mdep2.h : mdep2.c
	./protoflp $(PROTO) -dd_mdep2.h < mdep2.c > tmp.c
d_view.h : view.c
	./protoflp $(PROTO) -dd_view.h < view.c > tmp.c
d_grid.h : grid.c
	./protoflp $(PROTO) -dd_grid.h < grid.c > tmp.c
d_midi.h : midi.c
	./protoflp $(PROTO) -dd_midi.h < midi.c > tmp.c
d_clock.h : clock.c
	./protoflp $(PROTO) -dd_clock.h < clock.c > tmp.c
d_real.h : real.c
	./protoflp $(PROTO) -dd_real.h < real.c > tmp.c
d_fsm.h : fsm.c
	./protoflp $(PROTO) -dd_fsm.h < fsm.c > tmp.c
d_keyto.h : keyto.c
	./protoflp $(PROTO) -dd_keyto.h < keyto.c > tmp.c
d_mfin.h : mfin.c
	./protoflp $(PROTO) -dd_mfin.h < mfin.c > tmp.c
d_menu.h : menu.c
	./protoflp $(PROTO) -dd_menu.h < menu.c > tmp.c
d_kwind.h : kwind.c
	./protoflp $(PROTO) -dd_kwind.h < kwind.c > tmp.c

mdepback :
	cp mdep1.c ../mdep/stdio/mdep1.c
	cp mdep2.c ../mdep/stdio/mdep2.c
	cp mdep.h ../mdep/stdio/mdep.h
	cp makefile ../mdep/stdio/makefile
	cp clock.c ../mdep/stdio/clock.c
	cp midi.c ../mdep/stdio/midi.c
