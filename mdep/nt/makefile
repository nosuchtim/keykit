########
# To enable (compiler) debugging info, reverse the order of 4 things, here.
########

LINK=link
LIB=lib
CC=cl

WINDOWS10SDK = 10.0.18362.0

VCPATHS="/libpath:\program files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.26.28801\lib\x64" \
	"/libpath:\program files (x86)\windows kits\10\lib\$(WINDOWS10SDK)\ucrt\x64" \
       	"/libpath:\program files (x86)\windows kits\10\lib\$(WINDOWS10SDK)\um\x64"


# Reverse the order of these statements to toggle debug info
OTHER = /MLd
OTHER =

# Reverse the order of these statements to toggle debug info
# LIBC = libc.lib
# LIBC = libcd.lib

# Reverse the order of these statements to toggle debug info
DEBUGCC = $(cdebug) /nologo $(OTHER)
DEBUGCC = /D _DEBUG /D _CRT_SECURE_NO_WARNINGS /W3 /MDd

# Reverse the order of these statements to toggle debug info
DEBUGLINK = /STACK:4194304 /MAP $(linkdebug) /nologo /FIXED:NO /NODEFAULTLIB:library
DEBUGLINK = /STACK:4194304 /nologo

# Reverse the order of these statements to enable winsock support
# (also need to define WINSOCK in mdep2.c)
WINSOCK =
WINSOCK = wsock32.lib

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

# libs = $(LIBC) kernel32.lib user32.lib gdi32.lib winmm.lib comdlg32.lib $(WINSOCK) ole32.lib $(FWTRACK) setupapi.lib quartz.lib msacm32.lib oleaut32.lib advapi32.lib strmiids.lib
#
libs = $(LIBC) kernel32.lib user32.lib gdi32.lib winmm.lib comdlg32.lib $(WINSOCK) ole32.lib $(FWTRACK) setupapi.lib quartz.lib msacm32.lib oleaut32.lib advapi32.lib strmiids.lib

all : key.exe keylib.exe

demo :
	rm -f real.obj
	rm -f sym.obj
	nmake install
	rm -f real.obj
	rm -f sym.obj

install : all
	cp key.exe ..\bin\key.exe
	rm -f ..\bin\keylib.exe
	cp keylib.exe ..\bin\keylib.exe
	cd ..\lib
	..\bin\keylib.exe
	cd ..\src

keypc : key.exe
	cp key.exe k:\key\bin\key.exe
	cp keylib.exe k:\key\bin\keylib.exe

key.exe : protoflp.exe $(ALLDECS) $(KEYOBJ) key.res
	$(LINK) $(DEBUGLINK) $(guiflags) -map:key.map -out:key.exe /subsystem:windows /libpath:. $(VCPATHS) $(KEYOBJ) key.res $(libs)

key.res: key.rc
	rc $(rcvars) /I $(PLATINC) -r key.rc

protoflp.exe : protoflp.obj
	$(LINK) $(conflags) $(VCPATHS) -out:protoflp.exe protoflp.obj $(conlibs)

keylib.exe : keylib.obj mdep1.obj misc.obj
	$(LINK) $(conflags) $(VCPATHS) -out:keylib.exe keylib.obj mdep1.obj misc.obj $(conlibs)

tjt.exe : tjt.obj 
	$(LINK) $(conflags) $(VCPATHS) -out:tjt.exe tjt.obj $(conlibs)

.c.obj:
	$(CC) -c $(DEBUGCC) $(cflags) -I. $(cvars) $*.c

.cpp.obj:
	$(CC) -c -EHsc $(DEBUGCC) $(cflags) -I. $(cvars) $*.cpp

alltests : ptest1.exe ptest2.exe ptest3.exe

PSTUFF = ptest0.obj mdep1.obj mdep2.obj midi.obj clock.obj key.res

ptest1.exe : ptest1.obj $(PSTUFF)
	$(LINK) $(DEBUGLINK) $(guiflags) -out:ptest1.exe ptest1.obj $(PSTUFF) $(libs)

ptest2.exe : ptest2.obj $(PSTUFF)
	$(LINK) $(DEBUGLINK) $(guiflags) -out:ptest2.exe ptest2.obj $(PSTUFF) $(libs)

ptest3.exe : ptest3.obj $(PSTUFF)
	$(LINK) $(DEBUGLINK) $(guiflags) -out:ptest3.exe ptest3.obj $(PSTUFF) $(libs)

yacc.c : gram.y
	..\byacc\byacc -d gram.y
	rm -f yacc.c
	mv y_tab.c yacc.c
	rm -f yacc.h
	mv y_tab.h yacc.h

procfont.exe : procfont.c
	$(WINCC) procfont.c

protoproc : protoflp.exe
	for %%f in ($(KEYFILES)) do protoflp -p -d d_%%f.h < %%f.c > tmp.c
	rm -f tmp.c

clean :
	rm -f key.err
	rm -f key.dbg
	rm -f d_*.h
	rm -f *.obj
	rm -f *.pbi
	rm -f *.pbt
	rm -f *.pbo
	rm -f *.exe
	rm -f *.map
	rm -f tmp.c
	rm -f *.lnk
	rm -f keylib.k

clobber : clean
	rm -fr Debug x64
	rm -f d_*.h
	rm -f *.cur
	rm -f *.ico
	rm -f *.ilk
	rm -f *.pdb
	rm -f last.kp
	rm -f yacc.c
	rm -f yacc.h
	rm -f mdep.h
	rm -f mdep1.c
	rm -f mdep2.c
	rm -f midi.c
	rm -f y_output
	rm -f key.dbg
	rm -f *.sln *.vcxproj*

d_regex.h : regex.c
	.\protoflp -dd_regex.h < regex.c > tmp.c
d_sym.h : sym.c
	.\protoflp -dd_sym.h < sym.c > tmp.c
d_bltin.h : bltin.c
	.\protoflp -dd_bltin.h < bltin.c > tmp.c
d_meth.h : meth.c
	.\protoflp -dd_meth.h < meth.c > tmp.c
d_util.h : util.c
	.\protoflp -dd_util.h < util.c > tmp.c
d_phrase.h : phrase.c
	.\protoflp -dd_phrase.h < phrase.c > tmp.c
d_misc.h : misc.c
	.\protoflp -dd_misc.h < misc.c > tmp.c
d_main.h : main.c
	.\protoflp -dd_main.h < main.c > tmp.c
d_task.h : task.c
	.\protoflp -dd_task.h < task.c > tmp.c
d_fifo.h : fifo.c
	.\protoflp -dd_fifo.h < fifo.c > tmp.c
d_code.h : code.c
	.\protoflp -dd_code.h < code.c > tmp.c
d_code2.h : code2.c
	.\protoflp -dd_code2.h < code2.c > tmp.c
d_mdep1.h : mdep1.c
	.\protoflp -dd_mdep1.h < mdep1.c > tmp.c
d_mdep2.h : mdep2.c
	.\protoflp -dd_mdep2.h < mdep2.c > tmp.c
d_view.h : view.c
	.\protoflp -dd_view.h < view.c > tmp.c
d_grid.h : grid.c
	.\protoflp -dd_grid.h < grid.c > tmp.c
d_midi.h : midi.c
	.\protoflp -dd_midi.h < midi.c > tmp.c
d_clock.h : clock.c
	.\protoflp -dd_clock.h < clock.c > tmp.c
d_real.h : real.c
	.\protoflp -dd_real.h < real.c > tmp.c
d_fsm.h : fsm.c
	.\protoflp -dd_fsm.h < fsm.c > tmp.c
d_keyto.h : keyto.c
	.\protoflp -dd_keyto.h < keyto.c > tmp.c
d_mfin.h : mfin.c
	.\protoflp -dd_mfin.h < mfin.c > tmp.c
d_menu.h : menu.c
	.\protoflp -dd_menu.h < menu.c > tmp.c
d_kwind.h : kwind.c
	.\protoflp -dd_kwind.h < kwind.c > tmp.c

mdepback :
	cp makefile ..\mdep\nt\makefile
	cp key.sln ..\mdep\nt\key.sln
	cp key.vcxproj ..\mdep\nt\key.vcxproj
	cp mdep1.c ..\mdep\nt\mdep1.c
	cp mdep2.c ..\mdep\nt\mdep2.c
	cp mdep.h ..\mdep\nt\mdep.h
	cp midi.c ..\mdep\nt\midi.c
	cp clock.c ..\mdep\nt\clock.c
	cp key.rc ..\mdep\nt\key.rc
	cp keycap.cpp ..\mdep\nt\keycap.cpp
	echo "This didn't copy EVERYTHING back, like *.cur and *.ico"
