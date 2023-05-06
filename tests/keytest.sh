echo Running ack test ...
KEYPATH=../lib ../bin/lowkey ack.k > ack.out
diff ack.out ack.sav

echo Running attrib test ...
KEYPATH=../lib ../bin/lowkey attrib.k > attrib.out
diff attrib.out attrib.sav

echo Running bigtest test ...
KEYPATH=../lib ../bin/lowkey bigtest.k > bigtest.out
diff bigtest.out bigtest.sav

echo Running control test ...
KEYPATH=../lib ../bin/lowkey control.k > control.out
diff control.out control.sav

echo Running dot test ...
KEYPATH=../lib ../bin/lowkey dot.k > dot.out
diff dot.out dot.sav

echo Running fork test ...
KEYPATH=../lib ../bin/lowkey fork.k > fork.out
diff fork.out fork.sav

echo Running more test ...
KEYPATH=../lib ../bin/lowkey more.k > more.out
diff more.out more.sav

echo Running multi test ...
KEYPATH=../lib ../bin/lowkey multi.k > multi.out
diff multi.out multi.sav

echo Running obj test ...
KEYPATH=../lib ../bin/lowkey obj.k > obj.out
diff obj.out obj.sav

echo Running ptr test ...
KEYPATH=../lib ../bin/lowkey ptr.k > ptr.out
diff ptr.out ptr.sav

