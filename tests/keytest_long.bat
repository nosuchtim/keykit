@echo off

echo Running stringsoak test ...
..\bin\lowkey stringsoak.k > stringsoak.out
diff -b stringsoak.out stringsoak.sav
