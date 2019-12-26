n=0
for i in all_*.fpp
do
	n=`expr $n + 1`
done
n=`expr $n - 1`
for n in `seq 0 $n`
do
	echo n=$n
done
