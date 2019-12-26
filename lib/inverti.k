#********************************************************************

#	INVERTI () & INVERTIDIR ()
#	by
#	Mehmet Okonsar
#	mokonsar@dominet.in.com.tr
#	INVERTI ():
#	A function for the EDIT menu of the Group tool which inverts the
#	melodic intervals.
#	for ex. C up to E (Maj.3 up) becomes C down to E (Min. 6 down) 
#	C down to G (P4 down) becomes C up to G (P5th. up)
#	INVERTIDIR():
#	A function for the EDIT menu of the Group tool which inverts the
#	direction only of the melodic intervals.
#	for ex. C up to E (Maj.3 up) becomes C down to A- (Maj.3 down) 
#	C down to G (P4 down) becomes C up to F (P4 up)
#	USAGE:
#	add the following lines at :
#	mkmenus.k -> function mkmenu_edit(o,po) 
#		
#		o.submenu("Invert intervals ->","mkmenu_invertii",po)
#	and
#		function mkmenu_invertii(o,po) {
#			o.menucmd("Complemetary",po,"edit","cmd_inverti")
#			o.menucmd("Direction only",po,"edit","cmd_invertidir")
#		}
#	then : to cmds.k -> 
#		function cmd_inverti(p) {
#			return(inverti(p))
#		}
#		function cmd_invertidir(p) {
#			return(invertidir(p))
#		}
#	then run Keylib.exe (in the directory lib !)

#*********************************************************************

function inverti(ph) {
	ph=onlynotes(ph)
	numbernotes=0
	ni=[]
	for(nt in ph)
		numbernotes+=1
	for (i=1;i<(numbernotes);i++) {
		j=i+1
		ni[i]=ph%j.pitch-ph%i.pitch
	}
	for (k=1; k<numbernotes; k++) {
		if (ni[k]==1)
			ni[k]=-11
else
		if (ni[k]==2)
			ni[k]=-10
else
		if (ni[k]==-10)
			ni[k]=2
else
		if (ni[k]==3)
			ni[k]=-9
else
		if (ni[k]==4)
			ni[k]=-8
else
		if (ni[k]==5)
			ni[k]=-7
else
		if (ni[k]==6)
			ni[k]=-6
else
		if (ni[k]==7)
			ni[k]=-5
else
		if (ni[k]==8)
			ni[k]=-4
else
		if (ni[k]==9)
			ni[k]=-3
else
		if (ni[k]==10)
			ni[k]=-2
else
		if (ni[k]==11)
			ni[k]=-1
else
		if (ni[k]==12)
			ni[k]=-12
else
		if (ni[k]==-1)
			ni[k]=11
else
		if (ni[k]==-2)
			ni[k]=10
else
		if (ni[k]==-3)
			ni[k]=9
else
		if (ni[k]==-4)
			ni[k]=8
else
		if (ni[k]==-5)
			ni[k]=7
else
		if (ni[k]==-6)
			ni[k]=6
else
		if (ni[k]==-7)
			ni[k]=5
else
		if (ni[k]==-8)
			ni[k]=4
else
		if (ni[k]==-9)
			ni[k]=3
else
		if (ni[k]==-10)
			ni[k]=2
else
		if (ni[k]==-11)
			ni[k]=1
else
		if (ni[k]==-12)
			ni[k]=12
	}
	pi=ph
	for (i=2;i<=numbernotes;i++) {
		j=i-1
		pi%i.pitch=pi%j.pitch+ni[j]
	}
	return(pi)
} 

function invertidir(ph) {
	ph=onlynotes(ph)
	numbernotes=0
	ni=[]
	for(nt in ph)
		numbernotes+=1
	for (i=1;i<(numbernotes);i++) {
		j=i+1
		ni[i]=ph%j.pitch-ph%i.pitch
	}
	for (k=1; k<numbernotes; k++) {
		if (ni[k]<=0)
			ni[k]=abs(ni[k])
		else
			ni[k]=0-ni[k]
	}	
	pi=ph
	for (i=2;i<=numbernotes;i++) {
		j=i-1
		pi%i.pitch=pi%j.pitch+ni[j]
	}
	return(pi)
} 