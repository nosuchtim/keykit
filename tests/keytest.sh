#!/bin/sh

ARGS="-Debugmemscribble"

echo "Arg passed to lowkey: '${ARGS}'"

echo Running ack test ...

KEYPATH=../lib ../bin/lowkey ${ARGS} ack.k > ack.out
diff ack.out ack.sav

echo Running attrib test ...
KEYPATH=../lib ../bin/lowkey ${ARGS} attrib.k > attrib.out
diff attrib.out attrib.sav

echo Running bigtest test ...
KEYPATH=../lib ../bin/lowkey ${ARGS} bigtest.k > bigtest.out
diff bigtest.out bigtest.sav

echo Running control test ...
KEYPATH=../lib ../bin/lowkey ${ARGS} control.k > control.out
diff control.out control.sav

echo Running dot test ...
KEYPATH=../lib ../bin/lowkey ${ARGS} dot.k > dot.out
diff dot.out dot.sav

echo Running fork test ...
KEYPATH=../lib ../bin/lowkey ${ARGS} fork.k > fork.out
diff fork.out fork.sav

echo Running more test ...
KEYPATH=../lib ../bin/lowkey ${ARGS} more.k > more.out
diff more.out more.sav

echo Running multi test ...
KEYPATH=../lib ../bin/lowkey ${ARGS} multi.k > multi.out
diff multi.out multi.sav

echo Running obj test ...
KEYPATH=../lib ../bin/lowkey ${ARGS} obj.k > obj.out
diff obj.out obj.sav

echo Running ptr test ...
KEYPATH=../lib ../bin/lowkey ${ARGS} ptr.k > ptr.out
diff ptr.out ptr.sav

echo Running logical test ...
KEYPATH=../lib ../bin/lowkey ${ARGS} logical.k > logical.out
diff logical.out logical.sav
