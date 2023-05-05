#!/bin/sh

ARGS="-Debugmemscribble"

echo "Arg passed to lowkey: '${ARGS}'"

echo Running ack test ...
../bin/lowkey $ARGS ack.k > ack.out
diff ack.out ack.sav

echo Running attrib test ...
../bin/lowkey $ARGS attrib.k > attrib.out
diff attrib.out attrib.sav

echo Running bigtest test ...
../bin/lowkey $ARGS bigtest.k > bigtest.out
diff bigtest.out bigtest.sav

echo Running control test ...
../bin/lowkey $ARGS control.k > control.out
diff control.out control.sav

echo Running dot test ...
../bin/lowkey $ARGS dot.k > dot.out
diff dot.out dot.sav

echo Running fork test ...
../bin/lowkey $ARGS fork.k > fork.out
diff fork.out fork.sav

echo Running more test ...
../bin/lowkey $ARGS more.k > more.out
diff more.out more.sav

echo Running multi test ...
../bin/lowkey $ARGS multi.k > multi.out
diff multi.out multi.sav

echo Running obj test ...
../bin/lowkey $ARGS obj.k > obj.out
diff obj.out obj.sav

echo Running ptr test ...
../bin/lowkey $ARGS ptr.k > ptr.out
diff ptr.out ptr.sav

