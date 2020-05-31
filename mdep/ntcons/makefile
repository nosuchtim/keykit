# This is the ntcons makefile

BINMODE=binmode.obj
VC7=$(MSVS)\vc
DEBUGCC = /Ox /nologo
DEBUGCC = /D "_DEBUG" /D "_CRT_SECURE_NO_WARNINGS" /W3 /nologo /MDd

# Reverse the order of these statements to toggle debug info
DEBUGLINK = /MAP $(linkdebug)
DEBUGLINK = /DEBUG

VC7LINK=link.exe
VC7INC=$(VC7)\include

# VCINCS=/I $(VC7INC)

KEYOBJ = yacc.obj main.obj util.obj misc.obj phrase.obj sym.obj keyto.obj \
	code.obj code2.obj grid.obj view.obj menu.obj task.obj fifo.obj \
	mfin.obj real.obj mdep1.obj mdep2.obj kwind.obj fsm.obj bltin.obj \
	meth.obj regex.obj midi.obj clock.obj

KEYFILES = main util misc phrase sym keyto yacc \
	code code2 grid view menu task fifo \
	mfin real mdep1 mdep2 kwind fsm bltin meth \
	regex midi clock

ALLDECS = d_code.h d_code2.h d_fsm.h d_grid.h d_keyto.h d_main.h d_mdep1.h \
	d_menu.h d_mfin.h d_midi.h d_misc.h d_phrase.h d_real.h d_sym.h \
	d_util.h d_view.h d_task.h d_fifo.h d_kwind.h d_regex.h d_bltin.h \
	d_meth.h d_clock.h d_mdep2.h

libs =  libc.lib kernel32.lib user32.lib gdi32.lib winmm.lib comdlg32.lib

all : lowkey.exe keylib.exe

install : all
	del /f ..\bin\lowkey.exe
	copy lowkey.exe ..\bin\lowkey.exe
	del /f ..\bin\keylib.exe
	copy keylib.exe ..\bin\keylib.exe
	cd ..\lib && ..\bin\keylib.exe

lowkey.exe : protoflp.exe $(ALLDECS) $(KEYOBJ) key.res
	$(VC7LINK) $(DEBUGLINK) $(conflags) -map:key.map -out:lowkey.exe $(KEYOBJ) key.res $(BINMODE) $(conlibs)

key.res: key.rc
	rc $(rcvars) -r key.rc

protoflp.exe : protoflp.obj
	$(VC7LINK) $(conflags) -out:protoflp.exe protoflp.obj $(BINMODE)  $(conlibs)

keylib.exe : keylib.obj mdep1.obj misc.obj
	$(VC7LINK) $(conflags) -out:keylib.exe keylib.obj mdep1.obj misc.obj $(BINMODE) $(conlibs)

.c.obj:
	cl -c $(DEBUGCC) $(cflags) -I. $(VCINCS) $(cvars) $*.c

alltests : ptest1.exe ptest2.exe ptest3.exe

PSTUFF = ptest0.obj mdep1.obj mdep2.obj midi.obj clock.obj keydll.lib key.res

ptest1.exe : ptest1.obj $(PSTUFF)
	$(VC7LINK) $(DEBUGLINK) $(guiflags) -out:ptest1.exe ptest1.obj $(PSTUFF) $(libs)

ptest2.exe : ptest2.obj $(PSTUFF)
	$(VC7LINK) $(DEBUGLINK) $(guiflags) -out:ptest2.exe ptest2.obj $(PSTUFF) $(libs)

ptest3.exe : ptest3.obj $(PSTUFF)
	$(VC7LINK) $(DEBUGLINK) $(guiflags) -out:ptest3.exe ptest3.obj $(PSTUFF) $(libs)

# yacc.c : gram.y
# 	yacc -D -d gram.y
# 	mv y_tab.c yacc.c
# 	mv y_tab.h yacc.h

yacc.c : gram.y
	..\byacc\byacc -d gram.y
	copy y_tab.c yacc.c
	copy y_tab.h yacc.h
	del /f y_tab.c
	del /f y_tab.h

procfont.exe : procfont.c
	$(WINCC) procfont.c

protoproc : protoflp.exe
	for %%f in ($(KEYFILES)) do .\protoflp -p -d d_%%f.h < %%f.c > tmp.c
	del / tmp.c

clean :
	del /f keydll.exp
	del /f keydll.lib
	del /f keydll.dll
	del /f *.obj
	del /f *.exe
	del /f *.map

clobber : clean
	del /f d_*.h
	del /f yacc.c
	del /f yacc.h
	del /f y_output

d_regex.h : regex.c
	.\protoflp $(PROTO) -dd_regex.h < regex.c > tmp.c
d_sym.h : sym.c
	.\protoflp $(PROTO) -dd_sym.h < sym.c > tmp.c
d_bltin.h : bltin.c
	.\protoflp $(PROTO) -dd_bltin.h < bltin.c > tmp.c
d_meth.h : meth.c
	.\protoflp $(PROTO) -dd_meth.h < meth.c > tmp.c
d_util.h : util.c
	.\protoflp $(PROTO) -dd_util.h < util.c > tmp.c
d_phrase.h : phrase.c
	.\protoflp $(PROTO) -dd_phrase.h < phrase.c > tmp.c
d_misc.h : misc.c
	.\protoflp $(PROTO) -dd_misc.h < misc.c > tmp.c
d_main.h : main.c
	.\protoflp $(PROTO) -dd_main.h < main.c > tmp.c
d_task.h : task.c
	.\protoflp $(PROTO) -dd_task.h < task.c > tmp.c
d_fifo.h : fifo.c
	.\protoflp $(PROTO) -dd_fifo.h < fifo.c > tmp.c
d_code.h : code.c
	.\protoflp $(PROTO) -dd_code.h < code.c > tmp.c
d_code2.h : code2.c
	.\protoflp $(PROTO) -dd_code2.h < code2.c > tmp.c
d_mdep1.h : mdep1.c
	.\protoflp $(PROTO) -dd_mdep1.h < mdep1.c > tmp.c
d_mdep2.h : mdep2.c
	.\protoflp $(PROTO) -dd_mdep2.h < mdep2.c > tmp.c
d_view.h : view.c
	.\protoflp $(PROTO) -dd_view.h < view.c > tmp.c
d_grid.h : grid.c
	.\protoflp $(PROTO) -dd_grid.h < grid.c > tmp.c
d_midi.h : midi.c
	.\protoflp $(PROTO) -dd_midi.h < midi.c > tmp.c
d_clock.h : clock.c
	.\protoflp $(PROTO) -dd_clock.h < clock.c > tmp.c
d_real.h : real.c
	.\protoflp $(PROTO) -dd_real.h < real.c > tmp.c
d_fsm.h : fsm.c
	.\protoflp $(PROTO) -dd_fsm.h < fsm.c > tmp.c
d_keyto.h : keyto.c
	.\protoflp $(PROTO) -dd_keyto.h < keyto.c > tmp.c
d_mfin.h : mfin.c
	.\protoflp $(PROTO) -dd_mfin.h < mfin.c > tmp.c
d_menu.h : menu.c
	.\protoflp $(PROTO) -dd_menu.h < menu.c > tmp.c
d_kwind.h : kwind.c
	.\protoflp $(PROTO) -dd_kwind.h < kwind.c > tmp.c

mdepback :
	copy mdep1.c ..\mdep\ntcons\mdep1.c
	copy mdep2.c ..\mdep\ntcons\mdep2.c
	copy mdep.h ..\mdep\ntcons\mdep.h
	copy makefile ..\mdep\ntcons\makefile
	copy clock.c ..\mdep\ntcons\clock.c
	copy midi.c ..\mdep\ntcons\midi.c
