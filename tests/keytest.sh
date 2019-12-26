echo Running ack test ...
../bin/lowkey ack.k > ack.out
diff ack.out ack.sav

echo Running attrib test ...
../bin/lowkey attrib.k > attrib.out
diff attrib.out attrib.sav

echo Running bigtest test ...
../bin/lowkey bigtest.k > bigtest.out
diff bigtest.out bigtest.sav

echo Running control test ...
../bin/lowkey control.k > control.out
diff control.out control.sav

echo Running dot test ...
../bin/lowkey dot.k > dot.out
diff dot.out dot.sav

echo Running fork test ...
../bin/lowkey fork.k > fork.out
diff fork.out fork.sav

echo Running more test ...
../bin/lowkey more.k > more.out
diff more.out more.sav

echo Running multi test ...
../bin/lowkey multi.k > multi.out
diff multi.out multi.sav

echo Running obj test ...
../bin/lowkey obj.k > obj.out
diff obj.out obj.sav

echo Running ptr test ...
../bin/lowkey ptr.k > ptr.out
diff ptr.out ptr.sav

