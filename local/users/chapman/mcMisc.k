# 
#
#
#


########################################################

function kmGetGroup() {
	if ("g" in KMTools) 
		return([0=KMTools["g"]])
	else if ("" in KMTools) 
		return([0=KMTools[""]])
	else
		return([])
}



function kmGrpAudition() {
	print("Audition...")
	
	g=kmGetGroup()

	if (sizeof(g)) 
		g[0].auditionall() 	
}



function kmGrpSnarf2Grp() {
	g=kmGetGroup()

	if (sizeof(g)) 
		g[0].set(Snarf)
}



function kmGrp2Snarf() {
	g=kmGetGroup()

	if (sizeof(g)) 
		Snarf=g[0].get()
}



function kmGrpSet() {
	ph='c'
	g=kmGetGroup()

	if (sizeof(g)) 
		g[0].set(ph)
}



kmAddMenu("group", 
	">> a audition  s snarf2grp  S grp2snarf  p pat2grp P grp2pat\n>> x panx",
	"\n>> v vol  f fil  h hzc",
	[
		"a" = kmGrpAudition,
		"x" = function ? () { print(345345); },
		"s" = kmGrpSnarf2Grp,
		"S" = kmGrp2Snarf,
		"p" = kmGrpPat2Grp,
		"P" = kmGrp2Pat
	]
)




###########################################################
#
#
# Fun Stuff
#
#
###########################################################







