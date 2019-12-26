# Example of getting raw console keystrokes, up and down.
# Breaks out of loop when the ESC key is pressed and then let go.

function example17(ph) {
	Consupdown = 1
	Consecho = 0
	consf = Root.grabconsole()
	while ( (s=get(consf)) != Eof ) {
		print("key =",s)
		if ( s == "-ESC" )
			break
	}
	Consupdown = 0
	Consecho = 1
	Root.releaseconsole()
}
