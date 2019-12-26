BEGIN {
	VERSION = "6.5e"
	PATHSEP = "/"
	tagN = 1
	printf("HELPSTRUCT helpData [] = {\n") > "helpData.c"
}


{gsub(/\\\*\(Es/, PATHSEP)}	# Convert "\*(Es" to PATHSEP

{gsub(/\\\*\(KV/, VERSION)}	# Substitute the version number

{gsub(/\\f[1-9]/, "\"")}	# Quote words/phrases that have a different font

# Convert Titles
/^\.T1/ {
	sub(/^\.T1 /, "")	# skip the code
	gsub(/\\/, "")		# Get rid of backslashes
	gsub(/\"/, "")		# Get rid of quotes

	printf("\\just center\n")
	printf("\\style bold underline\n")
	printf("\\size 115\n")
	print; next
}

/^\.T2/ {
	sub(/^\.T2 /, "")			# skip the code
	gsub(/\\/, "")				# Get rid of backslashes
	gsub(/\"/, "")				# Get rid of quotes


	printf("\\just center\n")
	printf("\\style underline\n")
	printf("\\size 110\n")
	print
	next
}

# Generate Table of CONtents entry (TCON) and
# TAG entry for a section.
/^\.H[1-9]/ {
	match($0, /\".*\"/)
	$1 = substr($0, RSTART+1, RLENGTH-2)
	printf("\n\n\\str#\n")
	printf("\\tcon %s\n", $1)
	printf("\\tag %.3d\n", tagN)
	printf("\t{{\"%s\"},\t{%d}},\n", $2, tagN) >> "helpData.c"
	tagN += 1
	printf("\\style bold underline\n")
	printf("\\size 110\n")
	printf("%s\n", $1)
	next
}

# Constant Width
/^\.CW/ {
	sub(/^\.CW /, "")				# skip the code
	gsub(/\\/, "")					# Remove any \'s
	printf("%s", Highlite($0))		# Highlite what's left
	next
}

# change bold text to quoted text
/^\.B/ {
	sub(/^\.B /, "")				# skip the code
	gsub(/\\/, "")					# Remove any \'s
	printf("%s", Highlite($0))		# Highlite what's left
	next
}

# .SP (new paragraph)
/^\.SP/ { printf("\n\n"); next }

# Ignore other troff commands
/^\./ {next}

# Any other line is just text.
# Identify its line terminator as one that will be removed.
{ 
	sub(/\n.*/, "")		# Strip line terminator
	gsub(/\\/, "")		# Remove any leftover \'s
	printf("%s ", $0)
}

END {
	printf("\t{{\"\"},\t\t{0}}\n") >> "helpData.c"
	printf("};\n") >> "helpData.c"
	printf("\n\\itcon %d\n", tagN-1)	# insert table of contents
}

function Highlite (theStr) {
	gsub(/\"/, "", theStr)		# Get rid of quotes
	sub(/\n$/, "", theStr)		# Strip line terminator
	return ("\"" theStr "\" ")	# return quoted string with a trailing space
}
