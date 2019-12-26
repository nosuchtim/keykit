function globvarlist() {
	qvn = [0="Whole",1="Half",2="Quarter",3="Eighth",4="Sixteenth",5="32nd",6="1 Click"]
	qvv = [0=4b,1=2b,2=1b,3=1b/2,4=1b/4,5=1b/8,6=1]
	onoffn = [0="on",1="off"]
	onoffv = [0=1,1=0]
	return ( [
		0=["name"="Autoresize","valnames"=onoffn,"valvals"=onoffv],
		1=["name"="Dragquant","valnames"=qvn,"valvals"=qvv],
		2=["name"="Menujump","valnames"=onoffn,"valvals"=onoffv],
		3=["name"="Merge","valnames"=onoffn,"valvals"=onoffv],
		4=["name"="Record","valnames"=onoffn,"valvals"=onoffv],
		5=["name"="Recsched","valnames"=onoffn,"valvals"=onoffv],
		6=["name"="Sweepquant","valnames"=qvn,"valvals"=qvv],
		7=["name"="Volstem","valnames"=onoffn,"valvals"=onoffv],
		8=["name"="Flashquick","valnames"=onoffn,"valvals"=onoffv],
		9=["name"="Showbar","valnames"=qvn,"valvals"=qvv],
		10=["name"="Playquant","valnames"=qvn,"valvals"=qvv],
		11=["name"="Sync","valnames"=onoffn,"valvals"=onoffv],
		12=["name"="Chancolors","valnames"=onoffn,"valvals"=onoffv]
		] )
}
