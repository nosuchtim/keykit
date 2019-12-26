#########################################
# Message Library
#########################################






#########################################
# Interface
#########################################



#SongInit "mySong"
#SongPlay 
#SongStop 
#SongGotoBar 16
#SongUpdate 
#SongSetScene 1, "mix1"
#SongSetLoop 1, 32





#########################################
# Data structures
#########################################






#########################################
# Functionality
#########################################




function SongInit(name, beatsperbar, beatsperstep) {
	Song=[
		"name" = name,
   		"SongA" = 0,
		"SongB" = 127
	]
	Song["beatsperbar"] = beatsperbar
	Song["precalc"] = 2b
	Song["stepdur"] = beatsperstep * Clicks
	Song["SongDur"] = 32b
	Song["step"] = Song["stepA"]
	Song["stoptids"] = []
	Song["playstr"] = ""

	# Loop for length of Song
	SongSetLoop (0, 7)
}


function SongSetLoop(barA, barB) {
	Song["barA"] = barA
	Song["barB"] = barB
	Song["stepA"] = barA
	Song["stepB"] = barB
}


function SongPlay () {

	# Stop existing Song
	SongStop()

	# start the new performer
	Song["stoptids"][task SongPlayTask()] = 1
	Song["on"] = 1
}


function SongStop () {
	killtids(Song["stoptids"])
	Song["stoptids"] = []
	Song["on"] = 0
}



function SongPlayTask() {

	# Store time of user pressing play in Clicks

	t = Now
	Song["startclick"] = t

	# Start at stepA or gotoA?
	Song["step"] = Song["stepA"]

	if (0) {
 
		pat = Pat[Song["patternName"]]
		Song["pat"] = pat
		params = pat["params"]

		# Force an update
		for (r = params["rowA"]; r <= params["rowB"]; r++) {
			Song[r] = ["lastver"=pat["ver"]]
		}
	}

	# Loop until we get killed by SongStop
	while (1 ) {

		SongUpdatePlayers(t)

		# Move time forward after starting current music
		t += Song["stepdur"]

		# Sleep till just before needed
		sleeptill(t - Song["precalc"])

		# Step onwards or wraparound?
		if (Song["step"] < Song["stepB"]) 
			Song["step"]++
		else
			Song["step"] = Song["stepA"]
	}
	
}



function SongUpdatePlayers(starttime) {
	# Loop thru channels 
	pat = Song["pat"]
	seq = pat["seq"]
	params = pat["params"]

	if (0) {
		# Go thru all the selected rows
		for (r = params["rowA"]; r <= params["rowB"]; r++) {
			trk = Song[r]
			if (1) {

				# Get the channel data 
				partinfo = seq[r]
				if (typeof(partinfo) == "array") {

					ph = gph(partinfo[0])
					ph = repeat(ph, partinfo[1])
			
					start = Song["step"] * Song["stepdur"]
	#				print(starttime,Song["step"],start,r,Song["stepdur"])

					# Kill off previous player
					tsk = trk["trktsk"]
					if (typeof(tsk)!="string") {
	#					kill(tsk)
					}

					# 
					ph = cut(ph, CUT_TIME, start, start + Song["stepdur"])	
					ph.time -= start
					ph.length = Song["stepdur"]
					#print(ph)
					# Create a task and start it at the start of the step
					tsk = realtime(ph, starttime)

					# Remember the task id for the player
					Song["stoptids"][tsk] = r
					Song[r]["trktsk"] = tsk
				}
			}

		}
	}
}








SongInit ("mySong", 4, 4, 4)


