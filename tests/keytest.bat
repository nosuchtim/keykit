@echo off

echo Running ack test ...
..\bin\lowkey ack.k > ack.out
diff -b ack.out ack.sav

echo Running attrib test ...
..\bin\lowkey attrib.k > attrib.out
diff -b attrib.out attrib.sav

echo Running bigtest test ...
..\bin\lowkey bigtest.k > bigtest.out
diff -b bigtest.out bigtest.sav

echo Running control test ...
..\bin\lowkey control.k > control.out
diff -b control.out control.sav

echo Running dot test ...
..\bin\lowkey dot.k > dot.out
diff -b dot.out dot.sav

echo Running fork test ...
..\bin\lowkey fork.k > fork.out
diff -b fork.out fork.sav

echo Running big test ...
..\bin\lowkey bigtest.k > bigtest.out
diff -b bigtest.out bigtest.sav

echo Running more test ...
..\bin\lowkey more.k > more.out
fold more.out > morefold.out
fold more.sav > morefold.sav
diff -b morefold.out morefold.sav
del morefold.out
del morefold.sav

echo Running multi test ...
..\bin\lowkey multi.k > multi.out
diff -b multi.out multi.sav

echo Running obj test ...
..\bin\lowkey obj.k > obj.out
diff -b obj.out obj.sav

echo Running ptr test ...
..\bin\lowkey ptr.k > ptr.out
diff -b ptr.out ptr.sav

