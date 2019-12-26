
$f = $ARGV[0];

$b = $f;
$b =~ s/.src$//;
open(FROM,"$b.src") || die("Can't open $b.src\n");
open(TO,">$b.xml") || die("Can't open $b.xml\n");
$name = "";
while ( <FROM> ) {
	chop;
	$_ =~ s/\&/&amp;/g;
	if ( $_ =~ /^\.Hi/ ) {
		$name = $_;
		$name =~ s/" .*//;
		$name =~ s/.* "//;
		printf TO "<document name=\"$name\">\n";
	} elsif ( $_ =~ /^\.H1/ ) {
		$name = $_; $name =~ s/" .*//; $name =~ s/.* "//;
		$key = $_; $key =~ s/.*" //; $key =~ s/ .*//;
		printf TO "<header1 name=\"$name\" key=\"$key\"/>\n";
	} elsif ( $_ =~ /^\.T1/ ) {
		$name = $_; $name =~ s/" .*//; $name =~ s/"$//; $name =~ s/.* "//;
		printf TO "<title1 name=\"$name\"/>\n";
	} elsif ( $_ =~ /^\.LS/ ) {
		printf TO "<list>\n";
	} elsif ( $_ =~ /^\.LE/ ) {
		printf TO "</list>\n";
	} elsif ( $_ =~ /^\.LI/ ) {
		$name = $_; $name =~ s/.LI //; $name =~ s/^"//; $name =~ s/"$//;
		printf TO "<listitem name=\"$name\"/>\n";
	} elsif ( $_ =~ /^\.FI/ ) {
		$name = $_; $name =~ s/.FI //;
		$name =~ s/"/&quot;/g;
		printf TO "<funcitem name=\"$name\"/>\n";
	} elsif ( $_ =~ /^\.so/ ) {
		# .so is ignored
	} elsif ( $_ =~ /^\.He/ ) {
		printf TO "</document>\n";
	} elsif ( $_ =~ /^\.C0/ ) {
		# .C0 is ignored
	} elsif ( $_ =~ /^\.ne/ ) {
		# .ne is ignored
	} elsif ( $_ =~ /^\.EL/ ) {
		# .EL is ignored
	} elsif ( $_ =~ /^\.ES/ ) {
		printf TO "<pre>\n";
	} elsif ( $_ =~ /^\.EL/ ) {
		printf TO "<pre>\n";
	} elsif ( $_ =~ /^\.EE/ ) {
		printf TO "</pre>\n";
	} elsif ( $_ =~ /^\.in/ ) {
		$name = $_; $name =~ s/.* //;
		printf TO "<indent amount=\"$name\"/>\n";
	} elsif ( $_ =~ /^\.KW/ ) {
		$name = $_; $name =~ s/.* //;
		$name =~ s/"$//; $name =~ s/^"//;
		printf TO "<keyword name=\"$name\"/>\n";
	} elsif ( $_ =~ /^\.I/ ) {
		$name = $_; $name =~ s/.* //;
		$name =~ s/"$//; $name =~ s/^"//;
		printf TO "<i>$name</i>>\n";
	} elsif ( $_ =~ /^\.Te/ ) {
		printf TO "<titleend/>\n";
	} elsif ( $_ =~ /^\.T2/ ) {
		$name = $_; $name =~ s/" .*//;
		$name =~ s/"$//; $name =~ s/.* "//;
		printf TO "<title2 name=\"$name\"/>\n";
	} elsif ( $_ =~ /^\.Hc/ ) {
		$name = $_; $name =~ s/" .*//; $name =~ s/.* "//;
		$key = $_; $key =~ s/.* //;
		printf TO "<headercontents name=\"$name\" key=\"$key\"/>\n";
	} elsif ( $_ =~ /^\.B / ) {
		$name = $_;
		$name =~ s/^.B //;
		printf TO "<b>$name</b>\n";
	} elsif ( $_ =~ /^$/ ) {
		printf TO "<blankline/>\n";
	} elsif ( $_ =~ /^\.S[P1]/ ) {
		printf TO "<blankline/>\n";
	} elsif ( $_ =~ /^\.br/i ) {
		printf TO "<br/>\n";
	} elsif ( $_ =~ /^\.CW / ) {
		$name = $_;
		$name =~ s/^\.CW //;
		if ( $name =~ /^".*"$/ ) {
			$name =~ s/^"//;
			$name =~ s/"$//;
		}
		printf TO "<font class=\"fixed\">$name</font>\n";
	} else {
		printf TO $_."\n";
	}
}
close(FROM);
close(TO);
exit(0);
