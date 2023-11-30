CC = gcc
CFLAGS = -Wall -Wextra -O -g
STATIC = -static

PROTO = -p
BIN=../bin

KEYOBJ = yacc.o main.o util.o misc.o phrase.o sym.o keyto.o \
	code.o code2.o grid.o view.o menu.o task.o fifo.o \
	mfin.o real.o mdep1.o mdep2.o kwind.o fsm.o bltin.o \
	meth.o regex.o midi.o clock.o chkkey.o

KEYFILES = main util misc phrase sym keyto yacc \
	code code2 grid view menu task fifo \
	mfin real mdep1 mdep2 kwind fsm bltin meth \
	regex midi clock chkkey

ALLDECS = d_code.h d_code2.h d_fsm.h d_grid.h d_keyto.h d_main.h d_mdep1.h \
	d_menu.h d_mfin.h d_midi.h d_misc.h d_phrase.h d_real.h d_sym.h \
	d_util.h d_view.h d_task.h d_fifo.h d_kwind.h d_regex.h d_bltin.h \
	d_meth.h d_clock.h d_mdep2.h d_chkkey.h

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
	../byacc/byacc -dv gram.y
	mv y.tab.c yacc.c
	mv y.tab.h yacc.h
	mv y.output yacc.output

procfont : procfont.c
	$(WINCC) procfont.c

protoproc : protoflp
	for %%f in ($(KEYFILES)) do protoflp -s -p -d d_%%f.h < %%f.c

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
	./protoflp -s $(PROTO) -dd_regex.h < regex.c
d_sym.h : sym.c
	./protoflp -s $(PROTO) -dd_sym.h < sym.c
d_bltin.h : bltin.c
	./protoflp -s $(PROTO) -dd_bltin.h < bltin.c
d_meth.h : meth.c
	./protoflp -s $(PROTO) -dd_meth.h < meth.c
d_util.h : util.c
	./protoflp -s $(PROTO) -dd_util.h < util.c
d_phrase.h : phrase.c
	./protoflp -s -s $(PROTO) -dd_phrase.h < phrase.c
d_misc.h : misc.c
	./protoflp -s $(PROTO) -dd_misc.h < misc.c
d_main.h : main.c
	./protoflp -s $(PROTO) -dd_main.h < main.c
d_task.h : task.c
	./protoflp -s $(PROTO) -dd_task.h < task.c
d_fifo.h : fifo.c
	./protoflp -s $(PROTO) -dd_fifo.h < fifo.c
d_code.h : code.c
	./protoflp -s $(PROTO) -dd_code.h < code.c
d_code2.h : code2.c
	./protoflp -s $(PROTO) -dd_code2.h < code2.c
d_mdep1.h : mdep1.c
	./protoflp -s $(PROTO) -dd_mdep1.h < mdep1.c
d_mdep2.h : mdep2.c
	./protoflp -s $(PROTO) -dd_mdep2.h < mdep2.c
d_view.h : view.c
	./protoflp -s $(PROTO) -dd_view.h < view.c
d_grid.h : grid.c
	./protoflp -s $(PROTO) -dd_grid.h < grid.c
d_midi.h : midi.c
	./protoflp -s $(PROTO) -dd_midi.h < midi.c
d_clock.h : clock.c
	./protoflp -s $(PROTO) -dd_clock.h < clock.c
d_real.h : real.c
	./protoflp -s $(PROTO) -dd_real.h < real.c
d_fsm.h : fsm.c
	./protoflp -s $(PROTO) -dd_fsm.h < fsm.c
d_keyto.h : keyto.c
	./protoflp -s $(PROTO) -dd_keyto.h < keyto.c
d_mfin.h : mfin.c
	./protoflp -s $(PROTO) -dd_mfin.h < mfin.c
d_menu.h : menu.c
	./protoflp -s $(PROTO) -dd_menu.h < menu.c
d_kwind.h : kwind.c
	./protoflp -s $(PROTO) -dd_kwind.h < kwind.c
d_chkkey.h : chkkey.c
	./protoflp -s $(PROTO) -dd_chkkey.h < chkkey.c

mdepback :
	cp mdep1.c ../mdep/stdio/mdep1.c
	cp mdep2.c ../mdep/stdio/mdep2.c
	cp mdep.h ../mdep/stdio/mdep.h
	cp makefile ../mdep/stdio/makefile
	cp clock.c ../mdep/stdio/clock.c
	cp midi.c ../mdep/stdio/midi.c
