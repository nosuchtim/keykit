function reload()
{
	libInclude("mcLib.k")
	libInclude("mcMsg.k")
	libInclude("mcKeyMenu.k")
	libInclude("mcPat.k")
	libInclude("mcPhGen.k")
	libInclude("mcSong.k")
	libInclude("mcWin.k")
	libInclude("mcMisc.k")
	libInclude("mcGrv.k")
	libInclude("postrc.k")
}



# Initialise the mc subsystem ;}
function mcInit() {

	msgInit()

	initConMap()

	kmInit(2,"root")

	patInit("../liblocal/")

	patLibRead("m")
	patLibRead("d")
}



# It all starts here
function postrc() {
	# Local post-keyrc() modifications go here.
	# For example, this is where you could set Met.

	Root.redraw();

	page_readnew("mike.kp")

	reload()

	mcInit()
}


