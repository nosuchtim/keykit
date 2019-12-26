use XML::Parser;

my $p = new XML::Parser(ErrorContext => 2);


$p->setHandlers(
		Start => \&start_handler,
		Char => \&char_handler,
		End => \&end_handler
		);

$f = $ARGV[0];

if ( -d $f ) {
	print "Directory!\n";
	open(IND,">$f/index.html") || die("Unable to open index.html\n");
	&header(IND);
	&titlebox(IND,"Tools","Tools");
	print IND "<p>Below is a list of some of the tools in the default graphical user interface of KeyKit.  All of these tools are implemented with code in the <b>lib</b> directory.  Since the tools are so easy to change, the descriptions here may not be completely up to date, but they should be pretty close.<p>\n";
	print IND "Interactive tools:<p/>\n";
	print IND "<ul>\n";
	$toolname = "";
	while ( $fn = <$f/*.xml> ) {
		print "Doing $fn\n";
		$b = $fn;
		$b =~ s/.xml$//;
		open(OUT,">$b.html") || die("Unable to open $b.html\n");
		&header(OUT);
		$p->parsefile("$b.xml");
		close(OUT);
		$b =~ s/.*\///;
		# Hack!
		if ( "$toolname" eq "Apply" ) {
			print IND "</ul><p/>\n";
			print IND "GUI Tools:<p/>\n";
			print IND "<ul>\n";
		}
		print IND "<li><a href=$b.html>$toolname</a></li>\n";
	}
	print IND "</ul>\n";
	close(IND);
	exit(0);
}

$b = $f;
$b =~ s/.xml$//;
open(OUT,">$b.html") || die("Unable to open $b.html\n");
&header(OUT);


$p->parsefile("$b.xml");
close(OUT);
exit(0);

####################

sub header() {
	local $out = $_[0];
	print $out "<html><head>
		<style type=\"text/css\">
		.big {margin: 0pt; font-family: \"Arial\"; font-size: 18pt}
		.normal {margin: 0pt; font-family: \"Arial\"; font-size: 12pt}
		.small {margin: 0pt; font-family: \"Arial\"; font-size: 10pt}
		.tiny {margin: 0pt; font-family: \"Arial\"; font-size: 8pt}
		</style>
		</head>";
}

sub titlebox() {
	local $out = $_[0];
	local $name = $_[1];
	local $title = $_[2];
	print $out "<title>$name</title><body><table border=0 width=100% bgcolor=#ffcc99><tr><td><font class=big><a href=../index.html>KeyKit</a> :: $title</td></tr></table>\n";
}

sub char_handler {
	my $xp = shift;
	my $el = shift;
	print OUT "$el";
}

sub start_handler {
	my $xp = shift;
	my $el = shift;
	%atts = ();
	$all = "<".$el;
	while ( @_ ) {
		my $att = shift;
		my $val = shift;
		$atts{$att} = $val;
		$all = $all." ".$att."=\"".$val."\"";
	}
	$all = $all." >";
	if ( $el eq "b" ) {
		print OUT "<b>";
	} elsif ( $el eq "document" ) {
		&titlebox(OUT,$atts{name},$atts{title});
	} elsif ( $el eq "header1" ) {
		print OUT "<h2>$atts{name}</h2>\n";
	} elsif ( $el eq "font" ) {
		print OUT "<font ";
		if ( $atts{class} ) {
			print OUT " class=\"$atts{class}\"";
		}
		if ( $atts{face} ) {
			print OUT " face=\"$atts{face}\"";
		}
		print OUT " >";
	} elsif ( $el eq "list" ) {
		print OUT "<dl>\n";
	} elsif ( $el eq "pre" ) {
		print OUT "<pre>\n";
	} elsif ( $el eq "listitem" ) {
		$s = $atts{name};
		if ( $atts{bold} ) {
			print OUT "<dt><b>$s</b><dd>\n";
		} else {
			print OUT "<dt>$s<dd>\n";
		}
	} elsif ( $el eq "title1" ) {
		print OUT "<h2>$atts{name}</h2>\n";
	} elsif ( $el eq "title2" ) {
		print OUT "<h3>$atts{name}</h3>\n";
	} elsif ( $el eq "titleend" ) {
		print OUT "<p>\n";
	} elsif ( $el eq "headercontents" ) {
		print OUT "<a name=$atts{key} desc=\"$atts{name}\"></a>\n";
	} elsif ( $el eq "funcitem" ) {
		print OUT "<p><dt><font face=\"Courier\">$atts{name}</font><dd>\n";
	} elsif ( $el eq "tool" ) {
		$toolname = $atts{name};
		print OUT "<title>Keykit tool: $atts{name}</title>";
		print OUT "<table border=0 width=100% bgcolor=#ffcc99><tr><td><font class=big><a href=../index.html>KeyKit</a> :: <a href=index.html>Tools</a> :: $atts{name}</td></tr></table>\n";
		print OUT "<p/>";
	} elsif ( $el eq "blankline" ) {
		print OUT "<p>";
	} else {
		print OUT "$all";
	}
}

sub end_handler {
	my $xp = shift;
	my $el = shift;
	if ( $el eq "b" ) {
		print OUT "</b>";
	} elsif ( $el eq "font" ) {
		print OUT "</font>";
	} elsif ( $el eq "list" ) {
		print OUT "</dl>";
	} elsif ( $el eq "pre" ) {
		print OUT "</pre>";
	} elsif ( $el eq "document" ) {
		print OUT "</body>";
	} elsif ( $el eq "header1" ) {
		# It's a standalone item
	} elsif ( $el eq "headercontents" ) {
		# It's a standalone item
	} elsif ( $el eq "titleend" ) {
		# It's a standalone item
	} elsif ( $el eq "blankline" ) {
		# It's a standalone item
	} else {
		print OUT "</".$el.">";
	}
}
