#########################################
# Groove Toy
#########################################


# A toy to generate dynamic beat patterns from parts
#
# Each part is a repeating list of volumes and notes('p34' or 'p45,p65') 
# 9 effects can also be applied to each note 
#   Repeat(2,3,4) or EchoIn(2,3,4) or EchoOut(2,3,4)
#   
#



#########################################
# Interface
#########################################



#########################################
# Data structures
#########################################

  

#########################################
# Functionality
#########################################



# Initialise any needed data
function grvInit() {
	GrvData = [
		"pat"="m.grv",
		"part"="b"
	]
}



# Test
function grvTest() {
	
	grvInit()

	pat = [
		"fn"="grv",
		"ch"=10,
		"pitch"=0,
		"gain"=1,
		"dur"=0.1,
		"len"=8b,
		"parts"=[
			"b"= [
				"steps"="16",
				"groups"="9700",
				"kinds"="10",
				"notes"="9058"
			],
			"o"= [
				"steps"="32",
				"notes"="9390",
				"kinds"="102",
				"groups"="437"
			],
			"h"= [
				"steps"="32",
				"notes"="9800",
				"kinds"="230",
				"groups"="56"
			],
			"z"= [
				"steps"="32",
				"notes"="980",
				"kinds"="2302",
				"groups"="56"
			],
			"l"= [
				"steps"="32",
				"notes"="0092",
				"kinds"="201",
				"groups"="526"
			],
			"s"= [
				"steps"="16",
				"kinds"="340",
				"notes"="9003",
				"groups"="8240"
			]
		]
	]

	ph=grvFnGen(pat)
	
	patSet("m.grv", pat)

	patToolDisplay(pat)

	print(patGetPh("m.grv"))
}







function grvGetPat() {
	if (sizeof(GrvData["pat"])) 
		return([0=GrvData["pat"]])
	else
		return([])
}	


# part:b s:64 ev:'p50' notes:9052 groups:305
function grvDisplayPart() {
	pat = grvGetPat()
	if (!sizeof(pat)) 
		return()
	pat=pat[0]
	print(AllBlank + "Pat: " + GrvData["pat"] + "Ch: " + pat["ch"] + "  Len: " + pat["len"] + "" )
}




# Generate the events
function grvFnGen(pat) {
	
	r = ''
	
	parts=pat["parts"]
	gain=pat["gain"]
	dur=pat["dur"]
	pitch=pat["pitch"]
	ch = pat["ch"]
	len = pat["len"]

	for (p in parts) {

		part = parts[p]

		if ("steps" in part)
			steps=integer(part["steps"])
		else
			steps=16

		if ("notes" in part)
			notes=part["notes"]
		else
			notes="50"

		if ("groups" in part)
			groups=part["groups"]
		else
			groups="9"

		if ("kinds" in part) 
			kinds=part["kinds"]
		else
			kinds="0"

		notelen=sizeof(notes)
		grouplen=sizeof(groups)
		kindlen=sizeof(kinds)
		
		if ("ev" in part) 
			phlist=[0=part["ev"]]
		else 
			if (p in MsgDrums) 
				phlist=MsgDrums[p]
			else 
				phlist=[0='c']

		# Maintain three counters and a phrase for each part
		i=1
		note=1
		group=1
		kind=1
		partph=''
			#print("PP",kinds)
		#" Steps:" + string(steps) + 
		#printf("Part:" + p + " Groups:" + string(groups) + " Notes:" + string(notes) + "\n  ")
		printf(p + "  g:" + string(groups) + "  n:" + string(notes) + "  ph:")
		while(i<=steps) {
			
			notevol=integer(substr(notes,note,1))
			groupvol=integer(substr(groups,group,1))
			kindval = integer(substr(kinds,kind,1))
			
			vol = integer(notevol * groupvol * 1.5 * gain)
			printf("%d",integer(vol/126.0*9))


			if (vol > 2) {
				#print("u",kindval)
				
				ph = phlist[kindval % (sizeof(phlist)-1)]
				ph.chan = ch
				phnew = ph
				phnew.vol = vol
				phnew.dur *= dur
				phnew.pitch += pitch
				
				partph += phnew

			} else 
				partph.length += 1b

			if (kind<kindlen) 
				kind++
			else 
				kind=1

			if (note<notelen) 
				note++
			else {
				note=1
				if (group<grouplen)
					group++
				else 
					group=1
			}
			i++
		}
		print("")
		partph = scaleng(partph,len)

		r |= partph
	}
	if (pitch>0)
		r.pitch+=pitch
	return(r)
}



# Choose current part
function grvChoosePart() {
	
	patnm=GrvData["pat"]
	if (!sizeof(patnm)) {
		print("Choose pattern first...")
		return()
	}

	pat = patGet(patnm,"grvChoosePart")

	if (!sizeof(pat)) return()
	parts = pat["parts"]

	#s = kmRead("Part (" + string(parts) + "):")
	s = kmRead("Part:")
	if (sizeof(s) && (s in parts))
		GrvData["part"] = s
}



# Set the pattern that the toy will work on
function grvChoosePat() {
	if (0) {
		names = patLibGetNames("")
		pat = kmChoose("Pattern:", names)
		if (pat!=-1) 
			GrvData["pat"] = names[pat]

	} else {
		pat = kmChoosePattern()
		Root.releaseconsole()

		if (sizeof(pat)) 
			GrvData["pat"] = pat[0]
	}	
}



function grvReadPartStr(kind) {
	if (!("pat" in GrvData)) return()
		
	patnm = GrvData["pat"]

	pat = patGet(patnm,"grvReadStr")

	if (sizeof(pat)) {

		if ("part" in GrvData) {

			partnm = GrvData["part"]
			
			print(AllBlank,"Pat:",patnm,"Part:",partnm)

			while (1) {
				parts=pat["parts"]

				if (partnm in parts) {
					part=parts[partnm]

					s = kmRead(kind+": ", "")
					if (sizeof(s)) {
						
						part[kind]=s
						
						# Generate and show
						patToolDisplay(patnm)
						break
					} else {
						break
					}
				}
			}
		}
	}
}



###########################################################


kmAddMenu("grv", 
	">> Groove toy. Generating patterns from repetition with variation\n" +
	">> a active  g gen  t test",
	"\n>> v vol  f fil  h hzc",
	[
		"n" = function ? () { grvReadPartStr("notes") },
		"g" = function ? () { grvReadPartStr("groups") },
		"s" = function ? () { grvReadPartStr("steps") },
		"k" = function ? () { grvReadPartStr("kinds") },
		"e" = function ? () { grvReadPartStr("ev") },
		"t" = function ? () { grvTest() },
		"a" = function ? () { grvChoosePat() },
		"p" = function ? () { grvChoosePart() },
		"d" = function ? () { grvDisplayPart() },
		" " = function ? () { patToolDisplay("m.grv") }
 	]
)

