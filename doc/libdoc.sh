# This script looks for #usage and #desc comments in
# the library function source code, and constucts an xml file
# containing them all.

tmp=/tmp/$$
list=/tmp/list.$$

trap "rm -fr $tmp $list ; exit 1" 1 2 3 15
pwd=`pwd`
cat > $list
rm -fr $tmp
mkdir $tmp
for i in `cat $list`
do
	if [ "`grep '^#name' $i`" = "" ]
	then
		cd . ; # echo "$i doesn't have proper comments!" >&2
	fi
done

# We have to sort the entries, somehow, so we just put
# each one into a separate file.

cat $list | xargs awk '
BEGIN		{	state=0
			fname=""
		}
/^#name/	{	state=0
			if (fname!="") close(fname)
			fname = "'$tmp'/" $2
			filecomment = ""

			# if ( ($2 ".k") != FILENAME )
			# 	filecomment = "(defined in " FILENAME ")"
			# else
			# 	filecomment = ""
		}
/^#usage/	{	
			printf "<blankline/>\n" > fname
			printf "<listitem name=\"%s  %s\" bold=\"yes\" />\n",substr($0,8),filecomment > fname
		}
/^#desc/	{	
			printf "%s\n",substr($0,7) > fname
			state=1
		}
'
cd $tmp

echo "<document name=\"KeyKit Library Functions\" title=\"Library Functions\" >"
echo "<list>"
cat *
echo "</list>"
echo "</document>"

cd "$pwd"
rm -fr $tmp $list
