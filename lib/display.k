function display(fullscreen) {
	if ( nargs() < 1 )
		fullscreen = 0
	if ( fullscreen )
		mdep("display","start",800,600,"noborder")
	else
		mdep("display","start",800,600)
}
