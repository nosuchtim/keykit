#!/bin/sh

if [ "$1" = "" ]
then
	echo "usage: kvi {function-name}" >&2
	exit 1
fi

f=`basename $1 .k`

e=`grep "#library.* $f\$" keylib.k`
if [ "$e" = "" ]
then
	nmake
	e=`grep "#library.* $f\$" keylib.k`
fi
if [ "$e" = "" ]
then
	echo "Can't find a function named '$f' in keylib.k !?" >&2
	exit 1
fi
set $e
# vi "+/function $3" $2
vi $2
