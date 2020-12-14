rem @echo off

rem THIS ONE DOES JUST FUNCTION PROFILING
rem prep /om /fc /ft %1.exe

rem THIS ONE DOES LINE COUNT PROFILING
prep /om /fc /ft /lc %1.exe

if errorlevel == 1 goto done
profile %1 %2 %3 %4 %5 %6 %7 %8 %9
if errorlevel == 1 goto done
prep /m %1
if errorlevel == 1 goto done
plist %1
:done
