
$f = $ARGV[0];

$b = $f;
$b =~ s/.doc$//;
open(FROM,"$b.doc") || die("Can't open $b.doc\n");
open(TO,">$b.xml") || die("Can't open $b.xml\n");
$name = "";
while ( <FROM> ) {
	chop;
	if ( $_ =~ /^\.H1/ ) {
		$name = $_;
		$name =~ s/" .*//;
		$name =~ s/.* "//;
		$class = $_;
		$class =~ s/.* //;
		printf TO "<tool name=\"$name\" class=\"$class\">\n";
	} elsif ( $_ =~ /^\.B / ) {
		$name = $_;
		$name =~ s/^.B //;
		printf TO "<b>$name</b>\n";
	} elsif ( $_ =~ /^\.SP/ ) {
		printf TO "<blankline/>\n";
	} elsif ( $_ =~ /^\.br/ ) {
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
if ( "$name" eq "" ) {
	printf STDERR "No .H1 line!?\n";
} else {
	printf TO "</tool>\n";
}
close(FROM);
close(TO);
exit(0);
