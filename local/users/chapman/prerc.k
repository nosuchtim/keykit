function prerc() {

	# Local modifications go here

	##############################################################
	## If you want all MIDI input to be automatically echoed to
	## MIDI output (e.g. if your controller output is connected to
	## the PC input and the PC output is connected to your synths)
	## then set Merge=1.  If you have things set up so that your
	## controller is sending things to the synths as well as to
	## the PC, then you don't need this, and you should set Merge=0

	Merge = 0

	##############################################################
	## Often, you will have to adjust the MIDI input device that
	## is opened by default.  To get a list of the ports, type
	## "listports()" at the keykit console.  By default, the 0th
	## input port is used.  To use a different input port, use
	## the inport() function - the example here would use input port 2.
#	listports()
	outport(3)

	##############################################################
	## These lines are the kind you can use to
	## adjust the colors for the background (color
	## index 0), foreground (color index 1),
	## "picked notes" (color index 2), and
	## bar-lines-in-the-phrase-window (color index 3).
	## The example below produces a pink-ish background,
	## and magenta "picked" notes.

	# colormix(0,50000,40000,40000)
	# colormix(1,20000,1000,1000)
	# colormix(2,50000,0,30000)

	##############################################################
	## These things are used for TCP/IP things,
	## which only work in the Win32 version of
	## keykit.

	KeyKitHost = "localhost"
	KeyKitPort = 3333
	KeyKitRemotePort = 3333

	##############################################################
	## This is the name of the file that is
	## loaded, by default, in the kboom tool.

	KboomDrumkit = "drums.kbm"

	##############################################################
	## If you want to access other libraries of keykit functions, add
	## them to Keypath here.

#	Keypath += ";c:/FitzA/k"
#	Keypath += ";c:/FitzA/usr"
	# Keypath = Keypath + ";..\\users\\beerma"

	##############################################################
	## You can control the default assignment of actions to the
	## buttons in the Group tool, by setting the GroupActions array.
	## The numbers are magic - the actions/numbers are listed in 
	## the source code of wgroup.k

	if ( defined(Hostname) && Hostname=="spark" ) {
		# This one puts the "Tool" (42) sweep on the Shift-Left button
		GroupActions =  [ 1=[0=0,1=2,2=42], 2=[0=1,1=7,2=6] ]
	} else {
		# This one puts "Pluck" (25) on the Shift-Left button
		GroupActions =  [ 1=[0=0,1=2,2=25], 2=[0=1,1=7,2=6] ]
	}
}
