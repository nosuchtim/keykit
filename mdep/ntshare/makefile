!include <win32.mak>

MIDISHARE=c:\mdk32\include
MIDISHARELIB=c:\mdk32\lib\mshare32.lib
MIDISHARE=c:\mdk3216\Include
MIDISHARELIB=c:\mdk3216\Libraries\MShare3216.lib
CPU=i386

########
# To enable (compiler) debugging info, reverse the order of 4 things, here.
########

# Reverse the order of these statements to toggle debug info
OTHER = /MLd
OTHER =

# Reverse the order of these statements to toggle debug info
LIBC = libcd
LIBC = libc

# Reverse the order of these statements to toggle debug info
DEBUGCC = $(cdebug) /nologo $(OTHER)
DEBUGCC = /Ox /nologo $(OTHER)

# Reverse the order of these statements to toggle debug info
DEBUGLINK = /MAP $(linkdebug) /nologo
DEBUGLINK = /nologo

# Reverse the order of these statements to enable winsock support
# (also need to define WINSOCK in mdep2.c)
WINSOCK =
WINSOCK = wsock32.lib

KEYOBJ = yacc.obj main.obj util.obj misc.obj phrase.obj sym.obj keyto.obj \
	code.obj code2.obj grid.obj view.obj menu.obj task.obj fifo.obj \
	mfin.obj real.obj mdep1.obj mdep2.obj kwind.obj fsm.obj bltin.obj \
	meth.obj regex.obj midi.obj clock.obj chkkey.obj

KEYFILES = main util misc phrase sym keyto yacc \
	code code2 grid view menu task fifo \
	mfin real mdep1 mdep2 kwind fsm bltin meth \
	regex midi clock chkkey

ALLDECS = d_code.h d_code2.h d_fsm.h d_grid.h d_keyto.h d_main.h d_mdep1.h \
	d_menu.h d_mfin.h d_midi.h d_misc.h d_phrase.h d_real.h d_sym.h \
	d_util.h d_view.h d_task.h d_fifo.h d_kwind.h d_regex.h d_bltin.h \
	d_meth.h d_clock.h d_mdep2.h d_chkkey.h

libs =  $(LIBC).lib kernel32.lib user32.lib gdi32.lib winmm.lib comdlg32.lib $(WINSOCK)

all : key.exe keydll.dll keylib.exe

demo :
	deltree /y real.obj
	deltree /y sym.obj
	nmake install
	deltree /y real.obj
	deltree /y sym.obj

install : all
	copy key.exe ..\bin\key.exe
	copy keydll.dll ..\bin\keydll.dll
	copy keylib.exe ..\bin\keylib.exe
	cd ..\lib
	..\bin\keylib.exe
	cd ..\src

keypc : key.exe
	copy key.exe k:\key\bin\key.exe
	copy keylib.exe k:\key\bin\keylib.exe

key.exe : protoflp.exe $(ALLDECS) $(KEYOBJ) keydll.lib key.res
	link $(DEBUGLINK) $(guiflags) -map:key.map -out:key.exe $(KEYOBJ) key.res binmode.obj keydll.lib $(MIDISHARELIB) $(libs)

msh.exe : msh.obj
	link -out:msh.exe msh.obj $(MIDISHARELIB) $(libs)

key.res: key.rc
	$(rc) $(rcvars) -r key.rc

keydll.dll: keydll.obj keydll.def keydll.lib
	link $(DEBUGLINK) -base:0x1C000000 -dll -out:keydll.dll   \
		keydll.exp keydll.obj user32.lib winmm.lib

keydll.obj: keydll.c
	cl $(DEBUGCC) $(cflags) $(cvarsdll) keydll.c

# Update the import library

keydll.lib: keydll.obj keydll.def
	$(implib) -machine:$(CPU) -def:keydll.def keydll.obj -out:keydll.lib

protoflp.exe : protoflp.obj
	link $(conflags) -out:protoflp.exe protoflp.obj binmode.obj $(conlibs)

keylib.exe : keylib.obj mdep1.obj misc.obj
	link $(conflags) -out:keylib.exe keylib.obj mdep1.obj misc.obj binmode.obj $(conlibs)

.c.obj:
	cl $(DEBUGCC) $(cflags) -I. -I$(MIDISHARE) $(cvars) $*.c

alltests : ptest1.exe ptest2.exe ptest3.exe

PSTUFF = ptest0.obj mdep1.obj mdep2.obj midi.obj clock.obj keydll.lib key.res

ptest1.exe : ptest1.obj $(PSTUFF)
	link $(DEBUGLINK) $(guiflags) -out:ptest1.exe ptest1.obj $(PSTUFF) $(libs)

ptest2.exe : ptest2.obj $(PSTUFF)
	link $(DEBUGLINK) $(guiflags) -out:ptest2.exe ptest2.obj $(PSTUFF) $(libs)

ptest3.exe : ptest3.obj $(PSTUFF)
	link $(DEBUGLINK) $(guiflags) -out:ptest3.exe ptest3.obj $(PSTUFF) $(libs)

# yacc.c : gram.y
# 	yacc -D -d gram.y
# 	mv y_tab.c yacc.c
# 	mv y_tab.h yacc.h

yacc.c : gram.y
	..\byacc\byacc -d gram.y
	deltree /y yacc.c
	rename y_tab.c yacc.c
	deltree /y yacc.h
	rename y_tab.h yacc.h

procfont.exe : procfont.c
	$(WINCC) procfont.c

protoproc : protoflp.exe
	for %%f in ($(KEYFILES)) do protoflp -p -d d_%%f.h < %%f.c > tmp.c
	deltree /y tmp.c

clean :
	deltree /y keydll.exp
	deltree /y keydll.lib
	deltree /y keydll.pdb
	deltree /y keydll.dll
	deltree /y key.res
	deltree /y key.err
	deltree /y *.obj
	deltree /y *.pbi
	deltree /y *.pbt
	deltree /y *.pbo
	deltree /y *.exe
	deltree /y *.map
	deltree /y tmp.c
	deltree /y *.lnk
	deltree /y keylib.k

clobber : clean
	deltree /y d_*.h
	deltree /y *.cur
	deltree /y *.ico
	deltree /y yacc.c
	deltree /y yacc.h
	deltree /y y_output

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
d_chkkey.h : chkkey.c
	.\protoflp $(PROTO) -dd_chkkey.h < chkkey.c > tmp.c

mdepback :
	copy makefile ..\mdep\ntshare\makefile
	copy mdep1.c ..\mdep\ntshare\mdep1.c
	copy mdep2.c ..\mdep\ntshare\mdep2.c
	copy mdep.h ..\mdep\ntshare\mdep.h
	copy midi.c ..\mdep\ntshare\midi.c
	copy clock.c ..\mdep\ntshare\clock.c
	copy keydll.c ..\mdep\ntshare\keydll.c
	copy keydll.h ..\mdep\ntshare\keydll.h
	copy keydll.def ..\mdep\ntshare\keydll.def
	copy key.rc ..\mdep\ntshare\key.rc
	echo "This didn't copy EVERYTHING back, like *.cur and *.ico"
