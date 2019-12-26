# $Id: rvo.k,v 1.20 2004/03/28 18:02:28 Ralf Vosseler Exp $


# helper classes
# logging
class RvoLog {
	method init(classname) {
		s = "RvoLog initialized";
		$.ClassName = "";
		$.Logging =1;
		$.LogStates = [];
		$.LogStackIndex = 0;
		if ((nargs() !=0) && (typeof(classname) =="string"))
			$.ClassName = classname;

		if ($.ClassName !="")
			s += " for " +$.ClassName;

		s +="\n";
#		print (s);
	}


	# print out text
	method Log(...) {
		if ($.Logging !=0)
			if ($.ClassName !="")
				print ($.ClassName,": ");
			print (...);
	}

	# amtivate logging
	method LogOn() {

		$.Logging =1;
	}

	# disactivate logging
	method LogOff() {
		$.Logging =0;
	}

	# disactivate logging and remember previous state
	method PushLogging() {
		if (
		$.LogStackIndex <1000) {
			$.LogStates[$.LogStackIndex++] = $.Logging;
			$.Logging = 0;
		}
	}

	# restore previously saved log state
	method PopLogging() {
		$.Logging = $.LogStates[$.LogStackIndex];
		if ($.LogStackIndex >=0) {
			$.LogStackIndex--;
		}

	}

	# turn logging on, print message and restore priour state
	method LogError(...) {
		SaveLogging = $.Logging;
		Logging = 1;
		$.Log(...);
		$.Logging = SaveLogging;
	}

	# log a fatal error:
	# print error message and terminate the program
	method LogFatal(...) {
		$.LogError(...);
		exit()
	}

}

# a simple  stopwatch
class RvoStopWatch {
	method init() {
		$.StartTime = milliclock();
	}

	# restart it by just getting the new time
	method Restart() {
		$.StartTime = milliclock();
	}

	# return elapsed time in ms
	method ElapsedMS() {
		return (milliclock() - $.StartTime);
	}

	# return elapsed time in seconds
	method ElapsedS() {

		return (float(milliclock() -$.StartTime)/float(1000));
	}

	# return elapsed seconds since program start
	method ElapsedS0() {
		return (float(milliclock())/float(1000));
	}

}

# a cache
# currently for testing
class RvoCache {

	method init() {
		l = new RvoLog("RvoCache");
		$.inherit(l);

		$.Data = [];
		$.Requests = 0;
		$.Hits = 0;
		$.Entries =0;
	}

	method Contains(searchkey) {
		t = typeof(searchkey);
		if (t !="string")
			$.LogFatal("InCache: Need a string instead of ",t);
		$.Requests++;
		returnvalue = [];
		if (searchkey in $.Data) {
			returnvalue = $.Data[searchkey];
			$.Hits++;
		}
		return (returnvalue);
	}

	method Add(string,data) {
		if (nargs() != 2)
			$.LogFatal("AddToCache: Need a string and data.");
		t = typeof(string);
		if (t != "string")
			$.LogFatal("AddToCache: First argument must be a string, not a ",t);
		if (sizeof(data) ==0)
			$.LogFatal("Add: Data array contains nothing.");

		$.Data[string] = data;
		$.Entries++;
	}
	method PrintStatistics() {
		s ="Cache Statistics\n";
		s += "Entries: "+string($.Entries)+"\n";
		s +="Requests: "+string($.Requests)+"\n";
		s +="Hits: "+string($.Hits)+"\n\n";

		$.Log(s);
	}

}

# string management
class RvoStringTools {

	method init() {
		l = new RvoLog("RvoStringTools");
		$.inherit(l);
		$.UpperTable ="ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜ";
		$.LowerTable ="abcdefghijklmnopqrstuvwxyzäöü";
	}

	# find position of substring
	method StrPos(needle,haistack) {
		returnvalue = 0;

		if ((nargs() <2)
			|| (typeof(needle) !="string")
			|| (typeof(haistack) !="string"))
			return (0);

		if (!(haistack ~~ needle))
			return (0);

		for (c in haistack) {
			if (c == needle)
				break;
			else
				returnvalue++;
		}
		return (returnvalue);
	}

	# return n characters from the left, string length is maximum.
	method LeftStr(str,len) {
		length = 0;

		if ((nargs() <2)
			|| (typeof(str) !="string")
			|| (typeof(len) != "integer"))
			return ("");

		if (len >sizeof(str))
			length = sizeof(str);
		else
			length = len;

		return (substr(str,1,len));
	}

	# return max. n characters from the right.
	method RightStr(str,len) {
		start = 0;
		length = 0;

		if ((nargs() <2)
			|| (typeof(str) !="string")
			|| (typeof(len) != "integer"))
			return ("");

		if (len >sizeof(str))
			length = sizeof(str);
		else
			length = len;

		start = sizeof(str) - length;
		if (start <=0)
			start = 1;

		return (substr(str,start,len));
	}

	# convert a string to its lower case equivalent,
	# using the conversion tables.
	method ToLower(string) {
		returnvalue = "";
		c = "";
		i = 0;

		if (typeof(string) =="string") {
			for (i =1; i<=sizeof(string);i++) {
				c = substr(string,i,1);
				if ($.UpperTable ~~ c)
					returnvalue +=$.LowerTable[$.StrPos(c,$.UpperTable)];
				else
					returnvalue += c;
			}
		}
		return (returnvalue);
	}

	# convert a string to its upper case equivalent,
	# using the conversion tables.
	method ToUpper(string) {
		returnvalue = "";
		c = "";
		i = 0;

		if (typeof(string) =="string") {
			for (i = 1;i<=sizeof(string);i++) {
				c = substr(string,i,1);
				if ($.LowerTable ~~ c)
					returnvalue +=$.UpperTable[$.StrPos(c,$.LowerTable)];
				else
					returnvalue += c;
			}
		}
		return (returnvalue);
	}

	# convert input to a string
	# if a phrase is given 	leading and trailing ' are removed
	method ToString(input) {
		if (nargs() ==0)
			$.LogFatal("ToString: need an argument.");

		s = string(input);
		if (typeof(input) == "phrase")
			returnvalue = substr(s,2,sizeof(s)-2);
		else
			returnvalue = s;
		return (returnvalue);
	}
}

# a simple "Parser".
# Well, actually, it is only a lexer, since it recognizes character
# sequences.
# it can be used for simple applications, not e. g. for expressions.
#
# It works based on a function table containing
# functions to analyse a
# string and retrieve the data in the apropriate format.
# the functiontable is extensible so that own functions
# can be written and applied.
#
#
class RvoParser {

	# here the string to parse must be specified.
	method init(string) {
		l = new RvoLog("RvoParser");
		$.inherit(l);
		s = new RvoStringTools();
		$.inherit(s);

		if ((nargs() ==0) || (typeof(string) !="string"))
			$.GenError("Init: i need a string to parse.\n");

		if (sizeof(string) ==0)
			$.GenError("Init: The string is empty.");


		$.Pos =1; # position in string
		# constants
		$.BOS =-1; # begin of string
		$.EOS =-2;

		# get a copy of the string.
		$.String = string;

		$.LastExpected = "";	# needet for the get routine
								# to retrieve the data correctly



		$.Sym =""; # stores the red data
		$.FunctionTable =[]; # contains the functions for symbol types
		$.FunctionOwner = $;
		if ((nargs() ==2) && (typeof(argv(1)) == "object"))
			$.FunctionOwner = argv(1);

		$.Fraction = []; # structure to return just that.
		$.BuildFunctionTable();
	}

	# return true if the end of our string is reached
	method AtEnd() {
		return (($.CurrChar() ==$.EOS));
	}


	# add an entry to the functiontable
	# function names must be added as strings.
	method AddFtEntry(type,xpect,get) {


		$.FunctionTable[sizeof($.FunctionTable)] =
			["O"=$.FunctionOwner,"T"=type,"X"=xpect,"G"=get];
	}

	# fill function table with built-in symbol types
	method BuildFunctionTable() {
		$.AddFtEntry("Integer","XInt","GInt");
		$.AddFtEntry("Letter","XLetter","");
		$.AddFtEntry("Letters","XLetters","");
		$.AddFtEntry("Character","XChar","");
		$.AddFtEntry("Characters","XChars","");
		$.AddFtEntry("QualifierCharacter","XQualifierChar","");
		$.AddFtEntry("QualifierCharacters","XQualifierChars","");
		$.AddFtEntry("WhiteSpace","XWhiteSpace","");
		$.AddFtEntry("Fraction","XFraction","GFraction");
	}

	# print an error message and exit
	method GenError(...) {

		$.LogFatal(...);

	}

	# return a string containing
	# the input string given to the parser
	# an an up arrow at the current position
	method PositionIndicator() {
 		s = $.String +"\n";
		i =1;
		while (i < $.Pos) {
			i++;
			s +=" ";
		}
		s +="^\n";
		s +="Col. "+string($.Pos)+" ";
		return (s);
	}

	# a general Error message routine that prints
	# the input string + error indicator and all
	# given arguments
	method GeneralParsingError(...) {
		
		$.LogFatal($.PositionIndicator(),...);
	}

	# print a special error message, showing the
	# position of the needed symbol inside
	# the string
	method ExpectedError(symbol) {

		$.GeneralParsingError(symbol+" expected.");
	}

	# return the character at the current position
	method CurrChar() {

		if ($.Pos >sizeof($.String))
			return ($.EOS);
		else {
			return (substr($.String,$.Pos,1));
		}
	}

	# return the current symbol gathered
	method CurrSym() {
		return ($.Sym);
	}

	# return the current position inside the string
	method CurrPos() {
		return ($.Pos);
	}

	# set the position inside the string
	method SetPos(newpos) {

		if (typeof(newpos) !="integer")
			$.LogFatal("SetPos: Need an integer position.\n");
		$.Pos = newpos;
		if ($.Pos <0)
			$.Pos =1;
		if ($.Pos >sizeof($.String))
			$.Pos = sizeof($.String)+1;
	}

	# return the current character and advance position
	method GetChar() {


		char = $.CurrChar();
		$.Pos++;
		return (char);
	}

	# return true, if a character is white space character
	method IsWhiteSpace(ch) {
		a = ascii(ch);
		return ((a == 32) || (a == 9));
	}

	# skip whitespace characters
	method SkipWhite() {
		savepos = $.CurrPos();
		skipped =0;
		ch = $.CurrChar();

		while (($.IsWhiteSpace(ch)) && (ch !=$.EOS)) {
			ch = $.GetChar();
			skipped++;
		}
		if (skipped !=0)
			$.SetPos($.CurrPos()-1);
	}

	# find a function inside the function table
	# depending on the symbol type and
	# and the kind (expect/get)
	method FindFunction(symboltype,functype) {
		func =["Name"="","Owner"=$];
		$.Findex =-1;

		for (i in $.FunctionTable) {
			if ($.FunctionTable[i]["T"] == symboltype) {
				func = ["Name"=$.FunctionTable[i][functype],
					"Owner"=$.FunctionTable[i]["O"]];
				break;
			}
		}
		return (func);
	}

	# return true if l <=c <=h
	method InRange(l,h,c) {
		if ((typeof(l) !="string")
			|| (typeof(h) != "string")
			|| (typeof(c) != "string"))
			$.LogFatal("InRange: need strings as parameters.");
		return (((l <=c) && (h >=c)));
	}

	# look for a character or sequence of characters,
	# given exactness and number of appearances
	# note:
	# if the letter "i" is given, the number of appearances
	# is ignored.
	method LookAhead(symbol,exactness,howmany) {

		foundchars =0; # how many characters of the given symbol
						# have been found
		ch =$.CurrChar(); # get the current character
		i = 1;
		returnvalue = 0;
		s = substr(symbol,i,1);
		$.Sym ="";

		while (s == ch) {
			foundchars++;
			$.Sym +=ch;
			# we have to get the next character in order to update the
            # position
			ch = $.GetChar();
			# advance in the symbol to find?
			if (i != sizeof(symbol)) {
				i++;
				s = substr(symbol,i,1);
			}
			else {
				break;
			}
		}

		# check against exactness
		if (((exactness =="i") && (foundchars >0))
		|| ((exactness=="x")
			&& (foundchars == howmany))) {
			returnvalue = 1;
		}
		return(returnvalue);
	}

	# return true if the string contains a symbol
	# if the symbol is found inside the function table,
	# the corresponding function is used.
	# otherwhise the symbol is used as search string
	# this safes us from writing a function for each and everything.
	method Expect(symboltype) {
		if ((nargs() ==0) || (typeof(symboltype) !="string"))
			$.LogFatal("Expect: Need a Symbol\n");

		#$.Log("Expected: \"",symboltype,"\"");
		returnvalue = 0; # success

		$.LastExpected = "";
		func = $.FindFunction(symboltype,"X");	# from function table
		savepos = $.CurrPos();	# we have to return here later
		# only skip whitespaces if we are not looking for one
		if (symboltype !="WhiteSpace")
			$.SkipWhite();
		#$.Log("Expect: Positions: ",savepos,$.CurrPos());
		# adjust remembered position if chars have been skipped
		if (savepos !=$.CurrPos())
			savepos = $.CurrPos();
		# use specific function or search for string
		if (func["Name"] == "") {
			returnvalue = $.LookAhead(symboltype,"i",0);
		}
		else {
			# call our function
			returnvalue = func["Owner"].(func["Name"])();
			# safe last expected function type
			# this must be done after calling since
			# sub functions could change the last expected type
			# in order to retrieve the correct data.
			$.LastExpected = symboltype;
		}
		# reset our position, if the scan failed
		if (returnvalue ==0)
			$.SetPos(savepos);
		return (returnvalue);
	}

	# do an expect/get combination
	# usefull for syntactic elements which need not be processed
	method Required(symbolname) {

		if (!$.Expect(symbolname))
			$.ExpectedError(symbolname);
	}

	# search the string until the symbol type can be scanned
	method StopAt(symboltype) {
		if (nargs() ==0)
			$.LogFatal("StopAt: need a symbol type.");

		if (typeof(argv(0)) !="string")
			$.LogFatal("StopAt: Arguments must be strings.");
		returnvalue = [
			"String"="",
			"FoundChar"=""
		];
		while (($.CurrChar() != $.EOS)) {
			if ($.IsWhiteSpace($.CurrChar()))
				returnvalue["String"] +=$.GetChar();
			pos =$.CurrPos();
			if ($.Expect(symboltype)) {
				$.SetPos(pos);
				returnvalue["FoundChar"] = $.GetChar();
				break;
			}
			else
				returnvalue["String"] +=$.GetChar();
		}
		return (returnvalue);
	}

	# return the string scanned by the expect function or
	# the specific data, depending on the symbol type
	# given to the expect method
	method Get() {
		func = [];
		returnvalue = $.Sym;

		if ($.LastExpected != "") {
			func =$.FindFunction($.LastExpected,"G");

			if (func["Name"] !="")
				returnvalue = func["Owner"].(func["Name"])();
		}

		#$.Log("Get: \"",returnvalue,"\"");
		return (returnvalue);
	}

	# check the string contents for an integer
	# +|- followed by digits
	method XInt() {
		returnvalue = 0;
		ch = $.CurrChar();
		$.Sym ="";

		# check + or - sign
		if ("+-" ~~ ch) {
			$.Sym += ch;
			ch = $.GetChar();
		}

		# check for digits
		while (($.InRange("0","9",ch)) && (ch !=$.EOS)) {
			$.Sym += $.GetChar();
			ch = $.CurrChar();
			returnvalue++;
		}
		return(returnvalue);
	}

	# return the scanned integer
	# by converting the symbol variable
	method GInt() {

		return(integer($.Sym));
	}

	# scan for a letter
	method XLetter() {
		letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdeafghijklmnopqrstuvwxyz";
		returnvalue = 0;
		$.LastExpected = "";
		$.Sym ="";
		if (($.CurrChar() >=0) && (letters ~~ $.CurrChar())) {
			$.Sym +=$.GetChar();
			returnvalue++;
		}
		return (returnvalue);
	}

	# scan for as much letters as posible
	method XLetters() {
		returnvalue = 0;
		$.LastExpected = "";
		sym = "";
		while ($.XLetter()) {
			sym +=$.Sym;
			returnvalue++;
		}
		$.Sym = sym;
		return(returnvalue);
	}


	# scan for a legal character between 32 and 255
	method XChar() {
		returnvalue = 0;
		l =ascii(32);
		h = ascii(255);
		$.LastExpected = "";
		$.Sym ="";
		if (($.CurrChar() >=0) && ($.InRange(l,h,$.CurrChar()))) {
			$.Sym +=$.GetChar();
			returnvalue++;
		}
		return (returnvalue);
	}

	# scan for as much characters as posible
	method XChars() {
		returnvalue = 0;
		$.LastExpected = "";
		sym = "";
		while ($.XChar()) {
			sym += $.Sym;
			returnvalue++;
		}
		$.Sym = sym;
		return(returnvalue);
	}


	# scan for a qualifier character
	method XQualifierChar() {
		letters = "_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
			+"abcdeafghijklmnopqrstuvwxyz";
		returnvalue = 0;
		$.LastExpected = "";
		$.Sym = "";
		if (($.CurrChar() >=0) && (letters ~~ $.CurrChar())) {
			$.Sym +=$.GetChar();
			returnvalue++;
		}
		return (returnvalue);
	}

	# scan for as much letters as posible
	method XQualifierChars() {
		returnvalue = 0;
		$.LastExpected = "";
		sym ="";
		while ($.XQualifierChar()) {
			sym += $.Sym;
			returnvalue++;
		}
		$.Sym = sym;
		return(returnvalue);
	}

	# scan for a white space character
	method XWhiteSpace() {
		returnvalue = 0;
		$.LastExpected = "";
		$.Sym ="";
		if (($.CurrChar() >=0) && ($.IsWhiteSpace($.CurrChar()))) {
			$.Sym +=$.GetChar();
			returnvalue++;
		}
		return (returnvalue);
	}

	# scan for a fraction
	# here, the value of the fraction is stored inside the parser class
	# after scanning.
	method XFraction() {

		# scan for a numerator. If none can be found,
		# assume one
		$.LastExpected ="Integer";
		if (!$.XInt())
			numerator = 1;
		else
			numerator = $.Get();
		# we have to skip white space manually here, since we
		# work below the high level expecting function
		while ($.IsWhiteSpace($.CurrChar()))
			$.GetChar();
		# scan for the separator
		$.LastExpected ="";
		if (!$.LookAhead("/","x",1))
			return (0);
		$.Get();
		while ($.IsWhiteSpace($.CurrChar()))
			$.GetChar();
		# scan for the denominator
		$.LastExpected ="Integer";
		if (!$.XInt())
			return (0);

		denominator =$.Get();

		$.Fraction =[0=numerator,1=denominator];
		return (1);
	}

	# return the contents of the fraction
	method GFraction() {
		return ($.Fraction);
	}

}


class RvoDrumNoteParser {

	method init(string,cache) {
		l = new RvoLog("RvoDrumNoteParser");
		$.inherit(l);

		if ((nargs() <2) || (typeof(string) !="string")
			|| (typeof(cache) !="object"))
			$.LogFatal("Init: i need a string to parse and a cache to store data.\n");

		p = new RvoParser(string);
		$.inherit(p);

		$.Cache = cache;
	}

	method QuickParse() {
		allowedchars = "{}_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdeafghijklmnopqrstuvwxyz+-";
		searchkey = "";
		returnvalue = [];
		savepos = $.CurrPos();
		openbraces = 0;
		terminateloop =0;

		while (terminateloop ==0) {
			# exit at string end
			if ($.AtEnd())
				break;
			# get a character
			ch = $.GetChar();
			# we only collect chars till we find a closed brace
			if (ch == "}") {
				if (openbraces ==1)
					terminateloop =1;
				else
					$.GeneralParsingError("unexpected closed brace");
			}

			if (ch == "{") {
				openbraces++;
				if (openbraces >1)
					$.GeneralParsingError("Only one brace can be open at a time.");
			}

			# spaces are allowed but removed.
			if (ch == " ") {
				if (openbraces ==0)
					break;
				else
					continue;
			}

			if (!(allowedchars ~~ ch))
				$.GeneralParsingError("Invalid character.");
			else
				searchkey += ch;
		}

		returnvalue = $.Cache.Contains(searchkey);
		if (sizeof(returnvalue) == 0)
			$.SetPos(savepos);
		return (returnvalue);
	}


}


# Composing
# Base for most of the crap to come
class Rvo {

	method init() {
		l = new RvoLog("Rvo");
		$.inherit(l);
		s = new RvoStringTools();
		$.inherit(s);

		$.BeatsPerMeassure = 4;

	}


	# Play a midi file
	method PlayMid(f) {
	    s = "c:\\timidity\\timidgui.exe -EFreverb=0 -EFchorus=0 " + f;
#	    s = "C:\\PROGRA~1\\Window~1\\mplayer2.exe /Play " + f;
#		s = "c:\\progra~1\\awaves~1\\awaves~1.exe c:\\timidity\\12mbgs.sf2 -ap " +f;
	    system(s);
	}


	# Convert BPM to Ms.
	method Bpm2Ms(bpm) {
        return (1000000/(float(bpm)/60));
	}

	# Return a phrase with a tempo command
	method TempoPhrase(newbpm) {

		return (phrase("'\"Tempo=" + string($.Bpm2Ms(newbpm)) + "\"'"));
	}

	# Convert meassures, Beats, Ticks to Clicks
	method MBT2Clicks(meas,beats,ticks) {
		returnvalue = 0;

		if (meas >0)
			returnvalue += (meas*$.BeatsPerMeassure*Clicks);
		if (beats >0)
			returnvalue += (beats*Clicks);
		if (ticks >0)
			returnvalue += ticks;

		return (returnvalue);
	}

	# Play a phrase and optionally save it to a midi file.
	method PlayPhrase(phr,...) {
		# we don't play empty phrases
		if (phr == '') {
			$.LogError("PlayPhrase: Phrase is empty!");
			return();
		}

		if ((nargs() >1) && (typeof(argv(2)) == "string"))
			fname = argv(1);
		else
			fname = "tst.mid";
		writemf(phr,fname);
		$.PlayMid(fname);
		if (nargs() ==1) {
			system("del " + fname);
		}

	}

	# set beats per meassure
	method SetBeatsPerMeassure(newbeats) {
		if (typeof(newbeats) == "integer")
			$.BeatsPerMeassure = newbeats;
		else
			$.LogFatal("BeatsPerMeassure: Wrong type "
			+ typeof(newbeats) + " as parameter. Need an int.");
	}

	# return currently set beats per meassure
	method GetBeatsPerMeassure() {
		return ($.BeatsPerMeassure);
	}




}

# a track
class RvoTrack {

	method init() {
		l = new RvoLog("RvoTrack");
		$.inherit(l);
		r = new Rvo();
		$.inherit(r);
		$.MidiChannel = 1;	# where are we sending to
		$.ResultPhrase = '';
		$.Tempo = 120;
		$.Q = 1; # quantisation value
		$.CurrTime =[];
		$.CurrTime =[0=0,1=0,2=0,3=0];	# current time in meassures, beats ticks
       							# and all three expressed in clicks
	}

	# Set a midi channel for the track
	method SetMidiChannel(ch) {
		if ((ch >0) && (ch <17))
			$.MidiChannel = ch;
	}

	# Get midi channel
	method GetMidiChannel() {
		return ($.MidiChannel);
	}

	# Compose a note
	# MakeNote phrase/function/pitch, Velocity, Duration,
	#      start time, midi channel, length
	# currently not needed or used
	method MakeNote(nt,...) {
		value = 0;

		if (nargs() ==0) {
			$.LogFatalr("usage: makenote(phrase/function/pitch"
			+", [Velocity, [Duration, [start time, [midi channel, [length]]]]])");
			return('')
		}

		if ((typeof(note) != "phrase")
			|| (typeof(note) != "integer")) {
			$.LogFatal("MakeNote: i need a note phrase "
				+"or an integer type as first argument.");
 			return ('');
		}

		if (typeof(note) == "phrase")
			Note = note;
		else if (typeof(note) == "integer") {
			Note = 'a';
			Note.pitch = note;
		}
		else {
			$.Log("invalid datatype ",typeof(note),".");
			return ('');
		}


		# process remaining command line arguments
		for (i=1;i<nargs();i++) {
			if (typeof(argv(i)) == "integer")
				value = argv(i);
			if (value >=0) {

				if (i == 1)
					note.vol = value;

				if (i == 2) {
					note.dur = value;
					note.length = note.dur;
				}

				if (i == 3)
					note.Time = value;

				if ((i == 4) && (value >=1) && (value <=16))
					note.chan = value;


				if (i == 5)
					note.Length = value;
			}


		}


		return(note);
	}

	# Play the phrase created by the track
	# a file name can be specified.
	method Play(...) {
		$.PlayPhrase($.ResultPhrase,...);
	}

	# Set the new Tempo
	method SetTempo(tempobpm) {
		$.Tempo = tempobpm;
		$.Append($.TempoPhrase(tempobpm));
	}

	# Set current time in meassures, beats, ticks
	method SetTimeMBT(...) {
		meassures = 0;
		beats = 0;
		ticks = 0;

		# check argument types
		for (i=0;i<nargs();i++) {
			if (typeof(argv(i)) !="integer")
				$.LogFatal("SetTimeMbt: Argument ",i,"is not an integer.");
		}

		if (nargs() >=3)
			ticks = argv(2);
		if (nargs() >=2)
			beats = argv(1);
		if (nargs() >=1)
			meassures = argv(0);
		$.CurrTime[0] = meassures;
		$.CurrTime[1] = beats;
		$.CurrTime[2] = ticks;
		$.CurrTime[3] = $.MBT2Clicks(meassures,beats,ticks);

	}

	# advance the time by meassures, beats, ticks.
	# advance by one meassure per default.
	method Advance(...) {

		meassures = $.CurrTime[0];
		beats = $.CurrTime[1];
		ticks = $.CurrTime[2];

		if (nargs() ==0)
			meassures++;
		else {
			# check argument types
			for (i=0;i<nargs();i++) {
				if (typeof(argv(i)) !="integer")
					$.LogFatal("SetTimeMbt: Argument ",i,"is not an integer.");
			}

			if (nargs() >=3)
				ticks += argv(2);
			if (nargs() >=2)
				beats += argv(1);
			if (nargs() >=1)
				meassures += argv(0);
		}

		$.SetTimeMBT(meassures,beats,ticks);
	}

	# adjust all starting times of notesin a phrase
	# to the specified starting time
	method AdjustTime(phr,starttime) {
		result = '';


		if (nargs() <1)
			$.LogFatal("AdjustTime: Need at least a phrase which i can adjust.");
		if (typeof(phr) !="phrase")
			$.LogFatal("AdjustTime: First parameter must be a phrase, not ",
						typeof(phr),".");
		if (nargs() ==2) {
			if (typeof(starttime) =="integer")
            	time = starttime;
            else
            	$.LogFatal("AdjustTime: 2nd parameter must be an int4eger.");
		}
		else
			time = $.CurrTime[3];

		for (i in phr) {
			nt = i;
			nt.time +=time;
			result |= nt;
		}
		return (result);
	}


	# append a phrase to the track
	method Append(phr) {
		if (typeof(phr) == "phrase")
			$.ResultPhrase += phr;
	}

	# Insert a phrase
	method Insert(phr) {

		if (typeof(phr) == "phrase") {
			$.ResultPhrase |= phr;
		}
		else
			$.LogFatal("Insert: ",phr," Is no correct phrase to insert.");
	}

	# return resulting phrase
	method GetResultPhrase() {
		return ($.ResultPhrase);
	}

	# Set quantisation
	method SetQ(newq) {
		if (typeof(newq) == "integer")
			$.Q = newq;
		else
			$.LogFatal("SetQ: Wrong type "
				+ typeof(newq) + "as parameter. Need an integer.");
	}

	# return quantization value
 	method GetQ() {
		return ($.Q);
	}

}

# Song
# stores rvo tracks and creates a song out of them.
class RvoSong {

	method init(...) {
		$.Watch = new RvoStopWatch();
		l = new RvoLog("RvoSong");
		$.inherit(l);
		t = new RvoTrack();
		$.inherit(t);

		$.Tracks = [];
		$.NumTracks = 0;
		# insert the objects
		for (i=0;i<nargs();i++) {
			if ((typeof(argv(i)) == "object")
				&& (defined(argv(i).GetResultPhrase)))
				$.AddTrack(argv(i));
		}
		$.Build();
	}



	method Build() {
		for (i =0;i <$.NumTracks;i++) {
			$.Insert($.Tracks[i].GetResultPhrase());
		}
		$.Log("Generation Time:",$.Watch.ElapsedS0(),"Second(s)");
	}

	method AddTrack(track) {
		$.Tracks[sizeof($.Tracks)] = track;
		$.NumTracks = sizeof($.Tracks);
	}



}


# Drummer class
class RvoDrummer {

	method init() {
		l = new RvoLog("RvoDrummer");
		$.inherit(l);
		r = new RvoTrack();
		$.inherit(r);
		$.DrumMap = [];
		$.CreateDrumMap();
		$.Cache = new RvoCache();
	}


	# create the drum map
	method CreateDrumMap() {
	}

	# Add a drum note to the drum map
	method AddDrumNote(drumname,drumnote) {

		if (typeof(drumname) !="string")
			$.LogFatal("AddDrumNote: i need a string as the drumname.");

		if (typeof(drumnote) !="phrase")
			$.LogFatal("AddDrumNote: i need a string as the drumname.");
		$.DrumMap[sizeof($.DrumMap)] = ["Note"=drumnote,"Name"=drumname];


	}


	# look up a note in the drum map
	method LookUp(drumname) {
		if (typeof(drumname) == "string") {
			for (i in $.DrumMap) {
				if ($.DrumMap[i]["Name"] ~~ drumname)
					return ($.DrumMap[i]["Note"]);
			}
		}
		return ('');
	}



	# parse a drum note
	# the format is a repetition of:
	# note name, followed by attributes.
	# note name must be contained in the drum map
	# the attributes ar the v, d, l, t attributes known from notes
	# and are enclosed in fraces {}.
	# the specialty: you can specify an interval and a random value
	# is picked then.
	# ex: ClHiHat{v50..127}
	#
	# will look up the note and assign a random value between
	# 50 and 127.
	method OldParseDrumNote(notestring) {
		allowedqualifiers ="dltv";    # attribute letters
		returnvalue = "";	# we return a string converted to a phrase

		if (typeof(notestring) != "string")
			$.LogFatal("ParseDrumNote: got ",
				typeof(notestring)," need a string!");

		p = new RvoParser(notestring);
		if (!defined(p))
			$.LogFatal("ParseDrumNote: Could note create Parser object.");

		# parse the string
		while (!p.AtEnd()) {
			phr = "";
			if (!p.Expect("QualifierCharacters"))
				p.ExpectedError("drumnote qualifier");

			notename = p.Get();
			note = string($.LookUp(notename));
			if (note == "")
				p.GenError(notename," not found.");

			# Remove the phrase delimiters
			phr +=substr(note,2,sizeof(note)-2);
			if (p.Expect("{")) {
						p.Get();
				# letter for a parameter
				while (p.Expect("Letter")) {
					letter = $.ToLower(p.Get());
					if (!(allowedqualifiers ~~ letter))
						p.ExpectedError("One of ",allowedqualifiers," ");

					if (!p.Expect("Integer"))
						p.ExpectedError("integer");
						param1 = p.Get();
					if (p.Expect("..")) {
						p.Get();
						if (!p.Expect("Integer"))
	                       	p.ExpectedError("integer");

						param2 = p.Get();
						value =rand(param1,param2);
						letter += string(value);
					}
					else {
	                   	letter +=string(param1);
					}

					phr += letter;
				}
				p.Required("}");
			}
			# explicitely look for one white space or a comma
			# Note, we first have to check for white space
			# since otherwhise it will be skipped automagically.
			if (p.Expect("WhiteSpace"))
				phr += 				p.Get();


			if (p.Expect(","))
				phr += 				p.Get();


			returnvalue +=phr;
		}


		if (defined(p))
			deleteobject(p);

		returnvalue ="'" +returnvalue + "'";
		return (phrase(returnvalue));
	}

	method ParseDrumNote(notestring) {

		if (typeof(notestring) != "string")
			$.LogFatal("ParseDrumNote: got ",
				typeof(notestring)," need a string!");

		p = new RvoDrumNoteParser(notestring,$.Cache);
		if (!defined(p))
			$.LogFatal("ParseDrumNote: Could note create Parser object.");

		allowedqualifiers ="dltv";    # attribute letters
		returnvalue = "";	# we return a string converted to a phrase
		searchkey = "";     # the search index into the cache
		array = [];   # contains search results from the cache.

		# parse the string
		while (!p.AtEnd()) {
			array = p.QuickParse();
			if (sizeof(array) == 0) {
				# we parse manually
				if (!p.Expect("QualifierCharacters"))
					p.ExpectedError("drumnote qualifier");

				searchkey = "";
				notename = p.Get();
				note = string($.LookUp(notename));
				if (note == '')
					p.GenError(notename," not found.");

				searchkey += notename;
				# Remove the phrase delimiters
				array[0] = substr(note,2,sizeof(note)-2);

				if (p.Expect("{")) {
					searchkey += "{"

					i = 1;

					# letter for a parameter
					while (p.Expect("Letter")) {
						data = [];
						data[0] = $.ToLower(p.CurrSym());
						if (!(allowedqualifiers ~~ data[0]))
							p.ExpectedError("One of ",allowedqualifiers," ");

						searchkey += data[0];

						if (!p.Expect("Integer"))
							p.ExpectedError("integer");

						data[1] = p.Get();
						searchkey += p.CurrSym();
						if (p.Expect("..")) {
							searchkey +=p.CurrSym();

							if (!p.Expect("Integer"))
		                       	p.ExpectedError("integer");

							data[2] = p.Get();
							searchkey += p.CurrSym();

						}
					}

					array[i++] = data;

					p.Required("}");
					searchkey += "}";
					$.Cache.Add(searchkey,array);
				}
			}


			if (sizeof(array) !=0) {
				phr = "";
				phr +=array[0];
				for (i =1; i<sizeof(array);i++) {
					data = array[i];
					phr += data[0];
					if (sizeof(data) == 3) {
						phr += string(rand(data[1],data[2]));
					}
					else
						phr +=string(data[1]);
				}

				# explicitely look for one white space or a comma
				# Note, we first have to check for white space
				# since otherwhise it will be skipped automagically.
				if (p.Expect("WhiteSpace"))
					phr += p.Get();


				if (p.Expect(","))
					phr += p.Get();


				returnvalue += phr;
			}
		}


		if (defined(p))
			deleteobject(p);

		returnvalue ="'" +returnvalue + "'";
		return (phrase(returnvalue));
	}



	# calls makenote with lookup of the note name
	method Note(nt,...) {
		note = '';
		result = '';

		if (typeof(nt) == "string")
			note = $.LookUp(nt);
		else
			note = nt;

		result = $.MakeNote(note,...);
		return (result);
	}

	# assign a drum instrument to a beat.
	# beat numbers depend on the quantisation value
	method Beat(drumnote,...) {

		for (i=1;i<nargs();i++) {
			if (typeof(argv(i)) == "integer") {
				result = '';
				beattime =
				integer((argv(i)-1)*(Clicks*$.GetBeatsPerMeassure()/$.GetQ()));
                # add time of current meassure
                beattime +=$.CurrTime[3];


				if (typeof(drumnote) == "phrase") {
#					result = $.AdjustTime(drumnote,beattime);
					result = delay(drumnote,beattime);
				}


				if (typeof(drumnote) == "string") {
					result =
#                    $.AdjustTime($.ParseDrumNote(drumnote),beattime);
                    delay($.ParseDrumNote(drumnote),beattime);
				}

				$.Insert(result);
			}
		}
	}

	# beat with quantisation setting and restoring
	method BeatQ(q,drum,...) {


		if (typeof(q) == "integer") {
			oldq = $.GetQ();
			$.SetQ(q);
			$.Beat(drum,...);
			$.SetQ(oldq);
		}

	}

	# optional beat
	# a range can be specified. If a random value is in that range,
	# the beat is issued.
	method OBeat(min,max,drum,...) {
			if ((typeof(min) == "integer") && (typeof(max) == "integer")) {
				for (i = 2;i<nargs();i++) {
					if (rand(0,max) >=min)
						Beat(drum,argv(i));
				}
			}
	}

	# optional beat with quantisation
	# a range can be specified. If a random value is in that range,
	# the beat is issued.
	method OBeatQ(min,max,q,drum,...) {
			if ((typeof(min) == "integer") && (typeof(max) == "integer")
				&& (typeof(q) == "integer")) {
				for (i = 2;i<nargs();i++) {
					if (rand(0,max) >=min)
						$.BeatQ(q,drum,argv(i));
				}
			}
	}

	# return a flam = 2 hits at the same drum, slightly delayed
	method Flam(drumnote,flamq,volchange) {
		# check validity of arguments
		if (nargs() <2)
			$.LogFatal("Flam: I Need a phrase/string and a quantization value "
				+"Optional, a volume change can be given.");

		t3 = typeof(volchange);
		if ((t3 != "string") && (t3 != "integer"))
			$.LogFatal("Flam: Volume change must either be int or string.");

		t1 = typeof(drumnote);
		if ((t1 != "phrase") && (t1 != "string"))
			$.LogFatal("Flam: drumnote must be a phrase or string.");
		if (typeof(flamq) != "integer")
			$.LogFatal("Flam: flamq must be an integer.");



		# if the drumnote is a string, parse it
		if (t1 == "string")
			phr = $.ParseDrumNote(drumnote);
		else
			phr = drumnote;

		# time for the additional flam hit relativ to the first
		# note's start
		flamtime = integer(Clicks*$.GetBeatsPerMeassure()/flamq);

		# parse the flam volume, if it is a string
		if (t3 =="integer") {
			fval = volchange;
			operator ="=";
			percent =0;
		}
		else {
			p = new RvoParser(volchange);

			if ((p.Expect("+"))
				|| (p.Expect("-"))
				|| (p.Expect("=")))
				operator = p.Get();
			else
				operator = "=";


			if (!p.Expect("Integer"))
				p.ExpectedError("Integer");
			else
				fval = p.Get();
			if (p.Expect("%"))
				percent = 1;
			else
				percent = 0;


			if (defined(p))
				deleteobject(p);
		}



		returnvalue =phr;

		for (note in phr) {
			note2 = note;
			note2.time += flamtime;
			# calculate ending volume
			if (percent) {
				flamvol = integer(fval*note2.vol/100);
			}
			else
				flamvol = fval;

			if (operator =="+")
				newvol = note2.vol +flamvol;
			else if (operator =="-")
				newvol = note2.vol - flamvol;
			else
				newvol = flamvol;
			# clip the volume to legal range
			if (newvol >127)
				newvol = 127;
			else if (newvol <0)
				newvol = 0;


			note2.vol = newvol;
			returnvalue |= note2;
		}


		return (returnvalue);
	}

	# create a simple drum roll
	# specified by the drum note,
	# the quantization and
	# the roll length in clicks
	method Roll(drumnote,rollq,lengthinclicks,volchange) {
		# check arguments
		if (nargs() <3)
			$.LogFatal("Roll: i Need drumnote, quantization, "
				+"length in clicks.");

		if (typeof(rollq) !="integer")
			$.LogFatal("Roll: Roll quantization must be integer.");

		if (typeof(lengthinclicks) !="integer")
			$.LogFatal("Roll: length must be integer.");

		t1 = typeof(drumnote);
		if ((t1 !="phrase") && (t1 !="string"))
			$.LogFatal("Roll: if posibledrum note must be a phrase or a string.");


		# parse the ending volume
		if (nargs() >3) {
			t4 =typeof(volchange);
			if ((t4 != "integer") && (t4 !="string"))
				$.LogFatal("Roll: volume change must be either a string or integer.");

			if (t4 =="integer") {
				rollvolchange = volchange;
				operator ="=";
				percent = 0;
			}
			else {
				p = new RvoParser(volchange);

				if ((p.Expect("+"))
					|| (p.Expect("-"))
					|| (p.Expect("=")))
					operator = p.Get();
				else
					operator = "=";

				if (!p.Expect("Integer"))
					p.ExpectedError("Integer");
				else
					rollvolchange = p.Get();
				if (p.Expect("%"))
					percent = 1;
				else
					percent = 0;


				if (defined(p))
					deleteobject(p);
			}

		}
		else {
			rollvolchange = 0;
			operator = "+";
			percent = 0;
		}


		# parse the drum note
		if (t1 == "phrase")
			phr = drumnote;
		else
			phr = $.ParseDrumNote(drumnote);

		
		qclicks = integer(Clicks*$.GetBeatsPerMeassure()/rollq);
		numbeats = lengthinclicks/qclicks;
		returnvalue = phr;

		for (note in phr) {
			note2 = note;
			starttime = note2.time;

			# calculate ending volume
			currvol = note2.vol;
			if (percent) {
				volval = integer(rollvolchange*note2.vol/100);
			}
			else
				volval = rollvolchange;

			if (operator =="+")
				endvol = note2.vol +volval;
			else if (operator =="-")
				endvol = note2.vol - volval;
			else
				endvol = volval;


			# clip end volume to legal range
			if (endvol >127)
				endvol = 127;
			else if (endvol <0)
				endvol = 0;


			volchanges =abs(currvol -endvol);
			voldiff = float(volchanges)/float(numbeats);

			# adjust the difference, so that a simple addition can be done
			# to reach the ending volume
			if (currvol >endvol)
				voldiff = -voldiff;


			for (i=1;i<numbeats;i++) {
				currvol +=voldiff;
				note2.time = starttime +i*qclicks;
				note2.vol = currvol;

 				returnvalue |= note2;

			}
		}
		return (returnvalue);
	}

}

# gm drummer, generates the gm drum map
class RvoGmDrummer {

	method init() {
		l = new RvoLog("RvoGmDrummer");
		$.inherit(l);
		r = new RvoDrummer();
		$.inherit(r);
		$.CreateDrumMap();
		$.SetMidiChannel(10);
	}

	method CreateDrumMap() {


		$.AddDrumNote("Kick1",'p35c10');
		$.AddDrumNote("Kick2",'p36c10');
		$.AddDrumNote("SideStick",'p37c10');
		$.AddDrumNote("Snare1",'p38c10');
		$.AddDrumNote("Clap",'p39c10');
		$.AddDrumNote("Snare2",'p40c10');
		$.AddDrumNote("LoTom2",'p41c10');
		$.AddDrumNote("ClHiHat",'p42c10');
		$.AddDrumNote("LoTom1",'p43c10');
		$.AddDrumNote("PdHiHat",'p44c10');
		$.AddDrumNote("MidTom2",'p45c10');
		$.AddDrumNote("OpHiHat",'p46c10');
		$.AddDrumNote("MidTom1",'p47c10');
		$.AddDrumNote("HiTom2",'p48c10');
		$.AddDrumNote("Crash1",'p49c10');
		$.AddDrumNote("HiTom1",'p50c10');
		$.AddDrumNote("Ride1",'p51c10');
		$.AddDrumNote("China",'p52c10');
		$.AddDrumNote("RideBell",'p53c10');
		$.AddDrumNote("Tambourine",'p54c10');
		$.AddDrumNote("Splash",'p55c10');
		$.AddDrumNote("CowBell",'p56c10');
		$.AddDrumNote("Crash2",'p57c10');
		$.AddDrumNote("VibraSlap",'p58c10');
		$.AddDrumNote("Ride2",'p59c10');
		$.AddDrumNote("HiBongo",'p60c10');
		$.AddDrumNote("LoBongo",'p61c10');
		$.AddDrumNote("MuHiConga",'p62c10');
		$.AddDrumNote("OpHiConga",'p63c10');
		$.AddDrumNote("LoConga",'p64c10');
		$.AddDrumNote("HiTimbale",'p65c10');
		$.AddDrumNote("LoTimbale",'p66c10');
		$.AddDrumNote("HiAgogo",'p67c10');
		$.AddDrumNote("LoAgogo",'p68c10');
		$.AddDrumNote("Cabasa",'p69c10');
		$.AddDrumNote("Maracas",'p70c10');
		$.AddDrumNote("Whistle1",'p71c10');
		$.AddDrumNote("Whistle2",'p72c10');
		$.AddDrumNote("Guiro",'p73c10');
		$.AddDrumNote("Guiro2",'p74c10');
		$.AddDrumNote("Claves",'p75c10');
		$.AddDrumNote("HiWoodBlock",'p76c10');
		$.AddDrumNote("LoWoodBlock",'p77c10');
		$.AddDrumNote("MuCuica",'p78c10');
		$.AddDrumNote("OpCuica",'p79c10');
		$.AddDrumNote("MuTriangle",'p80c10');
		$.AddDrumNote("OpTriangle",'p81c10');
	}

}

# an instrument capable of parsing note values
# given as D, followed by the length:
# e. g.: "eo4D3/4,go3D2 3/8"
class RvoInstrument {

	method init() {
		l = new RvoLog("RvoInstrument");
		$.inherit(l);
		t = new RvoTrack();
		$.inherit(t);
	}

	# parse a note string and return a resulting phrase
	# attributes are enclosed in braces
	# and a group can hold several attribs.
	# supported attributes are:
	#d (duration) followed by a fraction or an int and a fraction
	#	d 7/8, d 2 3/4
	#
	# v (volume) followed by an integer
	#	or a range (integer .. integer)
	method ParseNoteString(notestring) {
		if (nargs() == 0)
			$.LogFatal("ParseNoteString: Call without Arguments.");


		if (typeof(notestring) != "string")
			$.LogFatal("ParseNoteString: Arguments must be string or phrase type.");
		p = new RvoParser(notestring);
		if (!defined(p))
			$.LogFatal("ParseNoteString: Could note create Parser object.");
		returnvalue = "'";
		while (!p.AtEnd()) {
			a = p.StopAt("{");
			returnvalue += a["String"];
			if (a["FoundChar"] != "{")
				break;
			while (!p.AtEnd()) {
				if (p.Expect("}")) {
					p.Get();
					break;
				}

				if (p.Expect("d")) {
					p.Get();
					# check for a fraction or an integer and a fraction
					frac = [];
					wholes = 0;
					if (p.Expect("Fraction")) {
						frac = p.Get();
					}
					else
						# check for a fraction preceded by wholes
						if (p.Expect("Integer")) {
							wholes = p.Get();
							if (p.Expect("Fraction"))
								frac = p.Get();
						}
						else
							p.ExpectedError("Integer or Fraction");

					# scan for dots
					dotted = 0;
					while ((!p.AtEnd()) && (p.Expect("."))) {
						dotted++;
						p.Get();
					}


					dur = wholes*Clicks*$.GetBeatsPerMeassure();
					if (frac !=[])
						dur +=frac[0]*Clicks*$.GetBeatsPerMeassure()/frac[1];

					# calculate dotting
					for (i=0;i<dotted;i++) {
						dur +=(dur/2);
					}
					returnvalue +="d"+string(dur);
				} # letter d = duration

				if (p.Expect("v")) {
					p.Get();
					if (p.Expect("Integer"))
						param1 = p.Get();
					else
                       	p.ExpectedError("integer");

					if (p.Expect("..")) {
						p.Get();
						if (!p.Expect("Integer"))
	                       	p.ExpectedError("integer");

						param2 = p.Get();
						value =rand(param1,param2);
						returnvalue += "v" +string(value);
					}
					else {
	                   	returnvalue +="v"+string(param1);
					}

				} #letter v
				


			} # not at end of brace group
		} # not at end, main loop
		returnvalue +="'";
		if (defined(p))
			deleteobject(p);
		return (phrase(returnvalue));
	}


	method InsertNote(...) {
		if (nargs() ==0)
			$.LogFatal("InsertNote: Call without arguments");
		for (i=0;i<nargs();i++) {
			if (typeof(argv(i)) == "phrase")
				$.Insert(argv(i));
			else if (typeof(argv(i)) == "string")
					$.Insert($.ParseNoteString(argv(i)));
		}

	}

	method AppendNote(...) {
		if (nargs() ==0)
			$.LogFatal("AppendNote: Call without arguments");

		for (i=0;i<nargs();i++) {
			if (typeof(argv(i)) == "phrase")
				$.Append(argv(i));
			else if (typeof(argv(i)) == "string")
					$.Append($.ParseNoteString(argv(i)));
		}


	}

	# this reflects what organ or piano players do, but
	# it is more flexible.
	# parameters:
	# notes: a phrase or a string as the
	# 	starting point
	# halftones: by how many halftones the given notes should be transposed
	# howmany: number of transpositions, i.e. slides
	#	default is 1
	# duration: pause between the transposed phrase in clicks or as string fraction
	#	default is 1/32
	#	If you specify duration as a string fraction, just
	#	specify the duration. The rest note plus duration char
	#	will be added automatically.
	#
	#
	method SlideKeys(notes,halftones,howmany,duration) {

		if (nargs() ==0)
			$.LogFatal("SlideKeys: Parameters are: notes,halftones,howmany,duration.");

		defaultduration = $.ParseNoteString("r{d1/32}");
		if (nargs() ==4) {
			if (typeof(duration) == "integer")
				dur = phrase('rd'+string(duration)+"'");
			if (typeof(duration) =="string")
				dur = $.ParseNoteString("rd"+duration);
			if (typeof(duration) == "phrase")
				dur = duration;
			else
				dur = defaultduration;
		}
		else {
			dur = defaultduration;
		}

		if (dur.length ==0)
			dur = '';

		if (nargs() <3)
			transposes = 1;
		else {
			if (typeof(howmany) == "integer")
				transposes = howmany;
			else
				$.LogFatal("SlideKeys: number of transpositions must be an integer.");
		}


		if (nargs() <2)
			htones = 1;
		else {
			if (typeof(halftones) == "integer")
				htones = halftones;
			else
				$.LogFatal("SlideKeys: number of half tone steps must be an integer.");
		}

!		if ((typeof(notes) != "phrase") && (typeof(notes) !="string"))
			$.LogFatal("SlideKeys: notesmust be a phrase or a string.");

		if (typeof(notes) =="phrase")
			returnvalue = notes;
		else
			returnvalue = $.ParseNoteString(notes);

		# append the transpositions to the result
		# we parse the note string with every iteration
		# in case it contains random values.
		for (i=0;i<transposes;i++) {
			returnvalue +=dur;
			if (typeof(notes) =="phrase")
				returnvalue += transpose(notes,i*htones);
			else
				returnvalue += transpose($.ParseNoteString(notes),i*htones);
		}

		return (returnvalue);
	}

}

# generate a single track by using two arrays.
# One contains functions to call, the other repeatitions and indexes
# into the first array.
# Both arrays are provided by the object given to the initialization
# method
class RvoTrackGenerator {
	method init(object) {


		l = new RvoLog("RvoTrackGenerator");
		$.inherit(l);

		$.Patterns =[];
		$.Sequence =[];
		$.Object = object;
		$.MaxRuns = 0;
		$.Run = 0;
	}

	# return the current run:
	# 0 < current run <max runs
	method GetRun() {
		return ($.Run);
	}

	# return the number of max runs a sequence
	# will be repeated.
	method GetMaxRuns() {
		return ($.MaxRuns);
	}

	# add a pattern to the list
	method AddPattern(patternname,...)     {
		a =[];
		i =0;

		for (i=0;i<nargs();i++) {
			if (typeof(argv(i)) != "string")
				$.LogFatal("AddPattern: Only strings accepted. Argument ",i,
					" is ",typeof(argv(i)),".");
		}

		for (i=1;i<nargs();i++) {
			a[sizeof(a)] = argv(i);
		}
		$.Patterns[patternname] =a;
	}

	# add a sequence
	method AddSequence(...) {
		previouswasint = 0;

		for (i=0;i<nargs();i++) {
			if (typeof(argv(i)) =="integer")
				previouswasint =1;
			else if (typeof(argv(i)) =="string") {
				if (previouswasint ==0)
					$.Sequence[sizeof($.Sequence)] =1;
				previouswasint =0;
			}
			else
				$.LogFatal("AddSequence: only strings or integers allowed.");
			$.Sequence[sizeof($.Sequence)] =argv(i);
		}

	}

	# process a row
	method ProcessRow(rowname) {
		row = [];
		func = "";
		if (nargs() ==0)
			$.LogFatal("ProcessRow: Need a Row name to process.");
		if (typeof(rowname) !="string")
			$.LogFatal("ProcessRowName: row name must be a string.")

		row = $.Patterns[rowname];
		for (i in row) {
			func = row[i];
			$.Object.(func)();
		}

	}

	# generate the whole track
	# either by processing sequences
	# or going row by row.
   	method Generate() {

		if (sizeof($.Patterns) ==0)
			$.LogFatal("Generate: No Patterns available.");

		if (sizeof($.Sequence) ==0) {
			$.Log("Generate: Going through patterns once since "\
				+"no sequence is given.");
			for (i in $.Patterns) {
				$.Run = 1;
				$.MaxRuns =1;
				$.ProcessRow(i);
			}
		}
		else {
			i = 0;
			j = 0;
			numtimes =0;
			rowname ="";
			for (i=0;i<sizeof($.Sequence);i+=2) {
				numtimes =$.Sequence[i];
				$.MaxRuns = numtimes;
				rowname =$.Sequence[i+1];
				for (j=0;j<numtimes;j++) {
					$.Run = j+1;
					$.ProcessRow(rowname);
				}
			}
		}

	}

}