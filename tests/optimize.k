#
# Test for bug in optimization
# commit 70c4bc4c9f246fdf4c082626f5b6c5442b885696 added more branch
# optimizations, including conversion of:
#
# <expr>; I_TCONDEVAL L1; I_GOTO L2; L1: ...
# into:
# <expr>; I_FCONDEVAL L2; L1: ...
#
# However previous change didn't account for both updating the
# instnodebranch[] target of origianl I_TCONDEVAL instruction,
# and remove the I_GOTO instruction from instnodebranch[].
# Other optimizations would trigger updates of branch targets
# which could end up causing the above to be optimized into:
#
# <expr>; I_FCONDEVAL L1; L1: ...
#
# With the above, the substr() conditional in testit() would always
# succeed resulting in output of "0", not "2" as expected.

Strarry = [ 1="#foo",
	      2=" foo",
	      3="#foo",
	      4="#foo",
	      5=" foo",
	      6="#foo"]
idx=1
	
function getln() {
	if (idx > 6) {
		return("");
	}
	return (Strarry[idx++]);
}

function testit()
{
	cnt = 0;
	while ((ln = getln()) != "") {
		if (substr(ln,1,1) == "#" )
			continue;
		cnt++;
	}
	print(cnt);
}

testit()
