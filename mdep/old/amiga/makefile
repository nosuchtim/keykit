#	Amiga Makefile for KeyKit
#
#	The Amiga version of KeyKit is compiled with SAS/C V6.5
#	All bets are off for any earlier version of Lattice/C, or
#   for any other compiler.

BUFFALO = yacc

# Mix and match these flags depending on how much debugging you want.
# -O requires at least 1.5 megs or RAM, maybe more, but generates smaller
# and faster code.  Use -d1 and addsym to use the CPR debugger.

OPTIM	= nostackchk
#OPTIM	= -v
CDEBUG	=
ERRREXX = errrexx
#CDEBUG	= -d1
CFLAGS	= nover define=GRID idir=//src $(ERRREXX) $(CDEBUG) define=$(BUFFALO)GRAM $(OPTIM) data=far code=far objname=$@ math=ieee debug=ff
PRFLAGS = idir=//src define=GRID genprotos nogpdata gpparm novers errrexx gpfile=
MKPROTO	= sc
#MKPROTO	= mkproto
#PRFLAGS = -pv >
#LDEBUG	= addsym
LDEBUG	= debug=l
#LIBC	= lib:catchres.o
#LIBC	= lib:catch.o
LIBC	= 
BAREMINIMUM = define=BAREMINIMUM

CC	= sc
LD	= sc link batch math=ieee
LFLAGS	= 
CP	= copy
RM	= delete
MV	= copy

# For Amiga we don't bother to generate the m5 stuff.
EXECS	= key keylib

PROTOS	= d_$(BUFFALO).h d_code.h d_code2.h d_sym.h d_main.h d_util.h \
	d_real.h d_phrase.h d_misc.h d_fsm.h d_grid.h d_menu.h d_view.h d_mfin.h \
	d_task.h d_keyto.h d_clock.h d_bltin.h d_regex.h d_midi.h d_amtimer.h \
	d_ammain.h d_kwind.h d_fifo.h d_meth.h d_mdep1.h d_mdep2.h

OBJS	= $(BUFFALO).o code.o code2.o sym.o main.o util.o real.o phrase.o \
	misc.o fsm.o grid.o menu.o view.o mfin.o task.o bltin.o \
	regex.o fifo.o kwind.o meth.o keyto.o midi.o clock.o

KEYLIBOBJ = keylib.o mdep1.o

AMIGA	=  mdep1.o mdep2.o am-timer.o # am-main.o

all : $(EXECS)

protos: $(PROTOS)

# am-timer.c contains an interrupt hander, so must be compiled differently.
# DO NOT use $(CFLAGS) to compile this file, or unpredictable (usually nasty)
# results will occur.
am-timer.o : am-timer.c
	$(CC) code=far data=far nostackchk $*

# beware: link command line is almost too long for AmigaDOS 1.3!
key : $(OBJS) $(AMIGA) lib:rexxglue.o
	$(LD) pname=key $(OBJS) $(AMIGA) obj=lib:rexxglue.o $(LFLAGS)

keylib : $(KEYLIBOBJ)
	$(LD) pname=keylib $(KEYLIBOBJ) $(LFLAGS)

lib:rexxglue.o : rexxlib/rexxglue.o
	@echo " "
	@echo "+----------------------------------------------------------+"
	@echo "| lib:rexxglue.o does not exist or is out of date compared |"
	@echo "| to rexxlib/rexxglue.o.  Please read the installation     |"
	@echo "| instructions regarding rexxglue.o                        |"
	@echo "+----------------------------------------------------------+"
	@echo " "

mftext : mftext.o mfin.o
	$(LD) pname=mftext mftext.o mfin.o $(LFLAGS)

mftokey : mftokey.o mfin.o kfsm.o misc.o phrase.o
	$(LD) pname=mftokey mftokey.o mfin.o kfsm.o misc.o phrase.o $(LFLAGS)

keytomf : keyto.o phrase.o misc.o
	$(LD) pname=keytomf keyto.o phrase.o misc.o $(LFLAGS)

tokey.o : tokey.c
	$(CC) $(CFLAGS) $(BAREMINIMUM) tokey.c

# special versions of phrase.o and fsm.o are used for mftokey and keytomf
kphrase.o : //src/phrase.c
	$(CP) //src/phrase.c kphrase.c
	$(CC) $(CFLAGS) $(BAREMINIMUM) kphrase.c
	$(RM) kphrase.c

kfsm.o : fsm.c
	$(CP) fsm.c kfsm.c
	$(CC) $(CFLAGS) $(BAREMINIMUM) kfsm.c
	$(RM) kfsm.c

$(BUFFALO).o : $(BUFFALO).c
$(BUFFALO).c : //src/gram.y
	byacc -d //src/gram.y
	$(MV) y_tab.c $(BUFFALO).c
	delete y_tab.c
	$(MV) y_tab.h $(BUFFALO).h
	delete y_tab.h

ptest1:	ptest1.o ptest0.o mdep1.o am-timer.o
	$(LD) to ptest1 from $(LIBC) ptest1.o ptest0.o mdep1.o am-timer.o $(LFLAGS)

ptest2:	ptest2.o ptest0.o mdep1.o am-timer.o
	$(LD) to ptest2 from $(LIBC) ptest2.o ptest0.o mdep1.o am-timer.o $(LFLAGS)

ptest3:	ptest3.o ptest0.o mdep1.o am-timer.o
	$(LD) to ptest3 from $(LIBC) ptest3.o ptest0.o mdep1.o am-timer.o $(LFLAGS)

code.o: //src/code.c
code2.o: //src/code2.c
sym.o: //src/sym.c
main.o: //src/main.c
util.o: //src/util.c
real.o: //src/real.c
mfin.o: //src/mfin.c
phrase.o: //src/phrase.c
misc.o: //src/misc.c
fsm.o: //src/fsm.c
grid.o: //src/grid.c
menu.o: //src/menu.c
task.o: //src/task.c
fifo.o: //src/fifo.c
bltin.o: //src/bltin.c
view.o: //src/view.c
kwind.o: //src/kwind.c
keyto.o: //src/keyto.c
keylib.o: //src/keylib.c
meth.o: //src/meth.c
regex.o: //src/regex.c

d_code.h: //src/code.c
	$(MKPROTO) $(PRFLAGS)d_code.h //src/code.c
d_code2.h: //src/code2.c
	$(MKPROTO) $(PRFLAGS)d_code2.h //src/code2.c
d_sym.h: //src/sym.c
	$(MKPROTO) $(PRFLAGS)d_sym.h //src/sym.c
d_main.h: //src/main.c
	$(MKPROTO) $(PRFLAGS)d_main.h //src/main.c
d_util.h: //src/util.c
	$(MKPROTO) $(PRFLAGS)d_util.h //src/util.c
d_real.h: //src/real.c
	$(MKPROTO) $(PRFLAGS)d_real.h //src/real.c
d_mfin.h: //src/mfin.c
	$(MKPROTO) $(PRFLAGS)d_mfin.h //src/mfin.c
d_phrase.h: //src/phrase.c
	$(MKPROTO) $(PRFLAGS)d_phrase.h //src/phrase.c
d_misc.h: //src/misc.c
	$(MKPROTO) $(PRFLAGS)d_misc.h //src/misc.c
d_fsm.h: //src/fsm.c
	$(MKPROTO) $(PRFLAGS)d_fsm.h //src/fsm.c
d_grid.h: //src/grid.c
	$(MKPROTO) $(PRFLAGS)d_grid.h //src/grid.c
d_menu.h: //src/menu.c
	$(MKPROTO) $(PRFLAGS)d_menu.h //src/menu.c
d_view.h: //src/view.c
	$(MKPROTO) $(PRFLAGS)d_view.h //src/view.c
d_yacc.h: yacc.c
	$(MKPROTO) $(PRFLAGS)d_yacc.h yacc.c
d_mdep1.h: mdep1.c
	$(MKPROTO) $(PRFLAGS)d_mdep1.h mdep1.c
d_mdep2.h: mdep2.c
	$(MKPROTO) $(PRFLAGS)d_mdep2.h mdep2.c
d_amtimer.h: am-timer.c
	$(MKPROTO) $(PRFLAGS)d_amtimer.h am-timer.c
d_ammain.h: am-main.c
	$(MKPROTO) $(PRFLAGS)d_ammain.h am-main.c
d_regex.h: //src/regex.c
	$(MKPROTO) $(PRFLAGS)d_regex.h //src/regex.c
d_clock.h: clock.c
	$(MKPROTO) $(PRFLAGS)d_clock.h clock.c
d_keyto.h: //src/keyto.c
	$(MKPROTO) $(PRFLAGS)d_keyto.h //src/keyto.c
d_bltin.h: //src/bltin.c
	$(MKPROTO) $(PRFLAGS)d_bltin.h //src/bltin.c
d_task.h: //src/task.c
	$(MKPROTO) $(PRFLAGS)d_task.h //src/task.c
d_midi.h: midi.c
	$(MKPROTO) $(PRFLAGS)d_midi.h midi.c
d_kwind.h: //src/kwind.c
	$(MKPROTO) $(PRFLAGS)d_kwind.h //src/kwind.c
d_fifo.h: //src/fifo.c
	$(MKPROTO) $(PRFLAGS)d_fifo.h //src/fifo.c
d_meth.h: //src/meth.c
	$(MKPROTO) $(PRFLAGS)d_meth.h //src/meth.c
