CPU=i386

# This is the nt makefile

##### These values are from before I upgraded to Visual Studio 2003 
MSVS="\program files\microsoft visual studio .net"
ATLINC=-I "\Program Files\Microsoft Visual Studio\VC98\ATL\include"

##### These values are for after I upgraded to Visual Studio 2003 
MSVS="\program files\microsoft visual studio .net 2003"
ATLINC=-I $(MSVS)\vc7\atlmfc\include
ATLLIB=/libpath:$(MSVS)\vc7\atlmfc\lib
VC7LINK="\program files\microsoft visual studio .net 2003\vc7\bin\link.exe"
VC7=$(MSVS)\vc7
PLATLIB=$(VC7)\platformsdk\lib
PLATINC=$(VC7)\platformsdk\include

##### These values are for the free Visual C++ Express 
MSVS="\program files\microsoft visual studio 9.0"
ATLINC=-I $(MSVS)\vc7\atlmfc\include
ATLLIB=/libpath:$(MSVS)\vc7\atlmfc\lib
VC7LINK="\program files\microsoft visual studio 9.0\vc\bin\link.exe"
VC7=$(MSVS)\vc

PLATSDK="\program files\microsoft platform sdk for windows server 2003 r2"
PLATLIB=$(PLATSDK)\lib
PLATINC=$(PLATSDK)\include

# DXSDK=\local\dx8sdk
# DXSDK=\local\dx9sdk

DXSDK=\local\dx8sdk

#######################################################
# To enable/disable the iGesture pad support, flip the
# comments on the next two sections.  I.e. to disable
# it, use the second section.

FINGER=\local\fingerworks
FWLIB="/libpath:$(FINGER)\sdk\FWHID_HandTracking\lib"
FWTRACK=fwtrack.lib
GESTFLAGS=-I "$(FINGER)\sdk\FWHID_HandTracking\include" /DGESTURE=1

# FWLIB=
# FWTRACK=
# GESTFLAGS = /DGESTURE=0
#######################################################

PYFLAGS = /DPYTHON=1


########
# To enable (compiler) debugging info, reverse the order of 4 things, here.
########


# Use these values for debugging
# OTHER = /MLd
# LIBC = libcd.lib
# DEBUGCC = $(cdebug) /nologo $(OTHER)
# DEBUGLINK = /STACK:4194304 /MAP $(linkdebug) /nologo /FIXED:NO /NODEFAULTLIB:library


# Use these values for NOT debugging
OTHER =
LIBC = libc.lib
LIBC = libcmt.lib
DEBUGCC = /Ox /nologo $(OTHER)
DEBUGLINK = /STACK:4194304 /nologo


# Reverse the order of these statements to enable winsock support
# (also need to define WINSOCK in mdep2.c)
WINSOCK =
WINSOCK = wsock32.lib


KEYOBJ = yacc.obj main.obj util.obj misc.obj phrase.obj sym.obj keyto.obj \
	code.obj code2.obj grid.obj view.obj menu.obj task.obj fifo.obj \
	mfin.obj real.obj mdep1.obj mdep2.obj kwind.obj fsm.obj bltin.obj \
	meth.obj regex.obj midi.obj clock.obj keycap.obj display.obj \
	gesture.obj keydll.obj

KEYFILES = main util misc phrase sym keyto yacc \
	code code2 grid view menu task fifo \
	mfin real mdep1 mdep2 kwind fsm bltin meth \
	regex midi clock keydll

ALLDECS = d_code.h d_code2.h d_fsm.h d_grid.h d_keyto.h d_main.h d_mdep1.h \
	d_menu.h d_mfin.h d_midi.h d_misc.h d_phrase.h d_real.h d_sym.h \
	d_util.h d_view.h d_task.h d_fifo.h d_kwind.h d_regex.h d_bltin.h \
	d_meth.h d_clock.h d_mdep2.h


libs = $(LIBC) kernel32.lib user32.lib gdi32.lib winmm.lib comdlg32.lib $(WINSOCK) ole32.lib dxguid.lib dinput.lib d3dx8.lib d3d8.lib $(FWTRACK) setupapi.lib quartz.lib msacm32.lib olepro32.lib oleaut32.lib advapi32.lib strmbasd.lib strmiids.lib

libs = $(LIBC) kernel32.lib user32.lib gdi32.lib winmm.lib comdlg32.lib $(WINSOCK) ole32.lib dxguid.lib dinput.lib d3dx8.lib d3d8.lib $(FWTRACK) setupapi.lib quartz.lib msacm32.lib olepro32.lib oleaut32.lib advapi32.lib strmiids.lib

# libs = $(LIBC) $(FWTRACK)
#

PYTHON=c:\python25

install : pykeykit.pyd
	copy pykeykit.pyd ..\bin
	copy keykit.py ..\bin
	copy sweep.cur ..\bin
	copy nothing.cur ..\bin
	copy keykit.ico ..\bin

all : key.exe keylib.exe

demo :
	rm -f real.obj
	rm -f sym.obj
	nmake DEMOTIMEOUT=10 install
	rm -f real.obj
	rm -f sym.obj

installbin : all
	cp key.exe ..\bin\key.exe
	cp keylib.exe ..\bin\keylib.exe
	cd ..\lib
	..\bin\keylib.exe
	cd ..\src

keypc : key.exe
	cp key.exe k:\key\bin\key.exe
	cp keylib.exe k:\key\bin\keylib.exe

VC7LIB=$(VC7)\lib
VC7INC=$(VC7)\include
VCPATHS=/libpath:$(VC7LIB) /libpath:$(PLATLIB)
VCINCS=/I $(VC7INC) /I $(PLATINC) /I $(PYTHON)\include

DSHOW="\Program Files\Microsoft Platform SDK\DirectShow"
DSHOWBASE=$(DSHOW)\samples\C++\DirectShow\BaseClasses

# DSHOWINC=-I $(DSHOW)\include -I $(DSHOWBASE)\include

# DSHOWLIB=/libpath:$(DXSDK)\lib\x86 /libpath:$(DSHOWBASE)\Debug
# DSHOWLIB=/libpath:$(DSHOWBASE)\Debug

DXSDKINC=-I $(DXSDK)\include -I $(DSHOWBASE)
DXSDKLIB=/libpath:$(DXSDK)\lib

pykeykit.c : pykeykit.pyx
	python \local\python\Pyrex-0.9.4.1\pyrexc.py pykeykit.pyx

pykeykit.obj : pykeykit.c
	cl -c $(DEBUGCC) $(cflags) -I. -I $(PYTHON)\include $(VCINCS) $(DXSDKINC) $(DSHOWINC) $(GESTFLAGS) $(OTHERFLAGS) $(cvars) $*.c

key.exe : protoflp.exe $(ALLDECS) $(KEYOBJ) key.res
	$(VC7LINK) /NODEFAULTLIB $(DEBUGLINK) $(guiflags) -map:key.map -out:key.exe /libpath:. $(VCPATHS) $(DSHOWLIB) $(DXSDKLIB) $(FWLIB) $(ATLLIB) $(KEYOBJ) key.res binmode.obj $(libs)

pykeykit.pyd : protoflp.exe $(ALLDECS) $(KEYOBJ) pykeykit.obj key.res
	$(VC7LINK) /dll /NODEFAULTLIB $(DEBUGLINK) $(guiflags) -map:key.map /out:pykeykit.pyd /implib:key.lib /libpath:. /libpath:$(PYTHON)\libs $(VCPATHS) $(DSHOWLIB) $(DXSDKLIB) $(FWLIB) $(ATLLIB) $(KEYOBJ) pykeykit.obj key.res binmode.obj $(libs) python25.lib

key.res: key.rc
	rc $(rcvars) /I $(PLATINC) -r key.rc

protoflp.exe : protoflp.obj
	$(VC7LINK) $(conflags) $(VCPATHS) -out:protoflp.exe protoflp.obj binmode.obj $(conlibs)

keylib.exe : keylib.obj mdep1.obj misc.obj
	$(VC7LINK) $(conflags) $(VCPATHS) -out:keylib.exe keylib.obj mdep1.obj misc.obj binmode.obj $(conlibs)

tjt.exe : tjt.obj 
	$(VC7LINK) $(conflags) $(VCPATHS) -out:tjt.exe tjt.obj binmode.obj $(conlibs)

udp : udpclient.exe udpserver.exe

udpclient.exe : udpclient.obj
	$(VC7LINK) $(conflags) $(VCPATHS) -out:udpclient.exe udpclient.obj binmode.obj $(conlibs) $(LIBC) kernel32.lib user32.lib gdi32.lib winmm.lib comdlg32.lib $(WINSOCK) ole32.lib setupapi.lib msacm32.lib olepro32.lib oleaut32.lib advapi32.lib 

udpserver.exe : udpserver.obj
	$(VC7LINK) $(conflags) $(VCPATHS) -out:udpserver.exe udpserver.obj binmode.obj $(conlibs) $(LIBC) kernel32.lib user32.lib gdi32.lib winmm.lib comdlg32.lib $(WINSOCK) ole32.lib setupapi.lib msacm32.lib olepro32.lib oleaut32.lib advapi32.lib 


.c.obj:
	cl -c $(DEBUGCC) $(cflags) -I. $(VCINCS) $(DXSDKINC) $(DSHOWINC) $(GESTFLAGS) $(PYFLAGS) $(OTHERFLAGS) $(cvars) $*.c

.cpp.obj:
	cl -c -EHsc $(DEBUGCC) $(cflags) -I. $(VCINCS) $(DXSDKINC) $(ATLINC) $(DSHOWINC) $(GESTFLAGS) $(PYFLAGS) $(OTHERFLAGS) $(cvars) $*.cpp

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
	rm -f yacc.c
	mv y_tab.c yacc.c
	rm -f yacc.h
	mv y_tab.h yacc.h

procfont.exe : procfont.c
	$(WINCC) procfont.c

protoproc : protoflp.exe
	for %%f in ($(KEYFILES)) do .\protoflp -p -d d_%%f.h < %%f.c > tmp.c
	rm -f tmp.c

clean :
	rm -f key.res
	rm -f key.err
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
	rm -f d_*.h
	rm -f *.cur
	rm -f *.ico
	rm -f yacc.c
	rm -f yacc.h
	rm -f y_output

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
	cp pykeykit.h ..\mdep\winpython\pykeykit.h
	cp keykit.py ..\mdep\winpython\keykit.py
	cp pykeykit.pyx ..\mdep\winpython\pykeykit.pyx
	cp makefile ..\mdep\winpython\makefile
	cp mdep1.c ..\mdep\winpython\mdep1.c
	cp mdep2.c ..\mdep\winpython\mdep2.c
	cp mdep.h ..\mdep\winpython\mdep.h
	cp midi.c ..\mdep\winpython\midi.c
	cp clock.c ..\mdep\winpython\clock.c
	cp key.rc ..\mdep\winpython\key.rc
	cp keycap.cpp ..\mdep\winpython\keycap.cpp
	cp display.cpp ..\mdep\winpython\display.cpp
	cp gesture.c ..\mdep\winpython\gesture.c
	echo "This didn't copy EVERYTHING back, like *.cur and *.ico"
