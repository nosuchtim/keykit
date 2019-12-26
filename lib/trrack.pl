open(F,"tmp.tr");
while ( <F> ) {
	chop;
	@arr = split(/:/,$_);
	$cat = $arr[0];
	$nm = $arr[1];
	$nm =~ s/ *$//;
	printf "	r[n++] = [ \"name\"=\"$nm\" \"func\"=\"trrackpatch0(CH,$cat,$n)\"]\n";
	$n++;
	if ( $n >= 128 ) { $n = 0; }
}
