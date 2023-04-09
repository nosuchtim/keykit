function amiga_test( name, val, f ) {
	global arexx_tasks,arexx_fifos;
	print( name + " is running args=", val );
	while( 1 ) {
		s = get(f);
		print( name + ": read = "+s );
	}
	arexx_tasks[name] = "";
	close(arexx_fifos[name]);
}

function amiga_arexx( port ) {
	global arexx_infifo,arexx_fifos;
	port = open( port, "lrw", "rexxhost" )
	arexx_tasks = [];
	arexx_fifos = [];
	arexx_cmds = [];
	arexx_cmds["REXX"] = "port/a";
	arexx_cmds["NEW"] = "page/a";
	arexx_cmds["OPEN"] = "page/a";
	arexx_cmds["SAVE"] = "";
	arexx_cmds["SAVEAS"] = "page/a";
	arexx_cmds["RUN"] = "func/k/a,proc/k/a,args/m";
	arexx_cmds["STOP"] = "proc/a";
	arexx_cmds["CMD"] = "args/a";
	arexx_cmds["EVENT"] = "proc/k/a,event/k/a";
	arexx_cmds["PHRASE"] = "phrase/a";
	arexx_cmds["TIMENOW"] = "";
	taskno = 1;
	if( typeof(port) == "array" ) {
		while( 1 ) {
			# get the message
			mstring = get(port["r"]);
			print("mstring is: ",mstring, "\n");
			args = mdep("readargs", mstring, arexx_cmds );
			if( typeof(args) != "array" ) {
				put( port["w"], "" )
				continue;
			}
			cmd = split( mstring, "\n" );
			cmd = split( cmd[0], " " );
			ret = "0";
			print("cmd is "+cmd[0] );
			print("args are: ",args );

			if( cmd[0] == "REXX" ) {
				task amiga_arexx( args[0] );
			} else if( cmd[0] == "NEW" ) {
				page_switchto( wpage(object()), args[0] );
			} else if( cmd[0] == "QUIT" ) {
				break;
			} else if( cmd[0] == "OPEN" ) {
				page_readnew( args[0] );
			} else if( cmd[0] == "SAVE" ) {
				if( args[0] != 0 )
					page_write( args[0] );
				else
					page_write( );
			} else if( cmd[0] == "SAVEAS" ) {
				page_write( args[0] );
			} else if( cmd[0] == "RUN" ) {
				global arexx_new_task, arexx_parms;
				arexx_infifo = open();
				arexx_parms = args[2];
				eval "arexx_new_task = task "+args[0]+"( \""+args[1]+"\",arexx_parms, arexx_infifo );";
				arexx_fifos[args[1]] = arexx_infifo
				if( cmd[2] == "." ) {
					arexx_tasks[args[1]] = taskno++;
				} else {
					arexx_tasks[args[1]] = arexx_new_task;
				}
			} else if( cmd[0] == "STOP" ) {
				if ( arexx_tasks[args[0]] != "" ) {
					kill( arexx_tasks[args[0]] );
					arexx_tasks[args[0]] = "";
				} else {
					print("Task: " + args[0]+ " is not running." );
					ret="";
				}
			} else if( cmd[0] == "CMD" ) {
				put( interpfifo, args[0] );
			} else if( cmd[0] == "EVENT" ) {
				global arexx_parms, arexx_infifo;
				arexx_parms = args[1];
				arexx_infifo = arexx_fifos[args[0]];
				eval "put( arexx_infifo, arexx_parms );";
			} else if( cmd[0] == "PHRASE" ) {
				realtime( midibytes( args[0] ));
			} else if( cmd[0] == "TIMENOW" ) {
				ret = Now + "";
			} else {
				print("Unknown command: "+ cmd[0] );
			}
			# reply message with a result of zero and "ret" as RESULT
			put( port["w"], ret )
		}
	}
	print("arexx task exiting!" )
}

function postrc() {
	# Create a keykit AREXX server...
	task amiga_arexx( "KeyKit" )
}
