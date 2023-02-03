# These are routines used by the Space Palette

PaletteListenAddress = "6666@127.0.0.1"
PaletteListenConnection = 0
PaletteSendAddress = "3333@127.0.0.1"
PaletteSendConnection = 0
PaletteListenTask = 0

function palette_kill() {
	print("Killing listen task")
	kill(PaletteListenTask)
	PaletteListenTask = 0
}

function palette_listen() {
	if ( PaletteListenTask != 0 ) {
		print("Palette listener already running.")
		return()
	}
	PaletteListenTask = task palette_listen_task()
}

function palette_listen_task() {
	if ( PaletteListenConnection == 0 ) {
		PaletteListenConnection = open(PaletteListenAddress,"rA","osc_listen")
        if ( PaletteListenConnection < 0 ) {
			print("Palette: unable to open ",PaletteListenAddress)
			print("Palette: perhaps another process is listening on ",PaletteListenAddress)
            return()
		}
	}
	while ( (d = get(PaletteListenConnection)) != Eof ) {
		print("Palette sent to keykit:",string(d))
	}
}

function palette_send(msg) {
	if ( PaletteSendConnection == 0 ) {
		print("Opening connection to Palette: ",PaletteSendAddress)
		PaletteSendConnection = open(PaletteSendAddress,"wb","osc_send")
	}
	print("Sending to Palette:",msg)
	mdep("osc","send",PaletteSendConnection,msg)
}

function palette_test() {
	msg = [0="/api",1="{\"api\":\"engine.sprite\",\"x\":\"0.3\",\"y\":\"0.4\",\"z\":\"0.5\"}"]
	palette_send(msg)
}


