# GeoMaestro initialization functions:
#-------------------------------------
#
# please refer to the online HTML manual for detailed explanations:
# http://www.zogotounga.net/GM/GMinstall.html

function geoprerc() 
{
	# extending the Keypath:
	ds = Dirseparator
	ps = Pathseparator
	Keypath += ps+Contribdir+ds+"GeoMaestro"+ds+"lib"
	Keypath += ps+Contribdir+ds+"GeoMaestro"+ds+"userlib"
	Keypath += ps+Contribdir+ds+"GeoMaestro"+ds+"userlib"+ds+"Courant"

	# defining the set of patches to use: 
	# (ACPATCHES = n must be associated to a file
	# ACpatchmap{n}.txt in /userlib)
	# 0 defaults to the GM set (no .txt file is required then)	
	if ( ! defined(ACPATCHES) ) {
		ACPATCHES = 0
	}

	if (ACPATCHES != 0)
	{	
		rekeylib()	
	    eval("function patchmap(){if(ACPATCHES>0) return(ACpatchmap()) else return(Patchmap)}")
		Patchmap = patchmap()
	}
}

function geopostrc() 
{
	Stoponpageswitch=0
	History = 1
	ConsoleReadedit = global(readedit2)
	Printsplit = 0

	# this launches GeoMaestro initializations:
	Go()
	# -> see code in /GeoMaestro/lib/intialisations.k
	# -> set local settings in /GeoMaestro/userlib/GeoPostInit.k

	HFName = MAT+"KKlog.txt"
}
