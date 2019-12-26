# listen - by Ruchir Shah (ruchir@cableinet.co.uk)

# Here's my contribution, a function called listen(), 
# which produces riff tools on the fly from the console. 
# Hit 'a' to grab the last bit of music, 'd' to delete, 'p' to play, 
# 's' to stop and any number key to play the corresponding riff number,
# in the order in which they were grabbed

function listen() { o = []
x = 0
y = 0
n = 0
while ( 1 ) {
	c = Root.waitforconsolekey()
	ch = ascii(c)
	# Pressing ESC or control-d will get you out
	if ( ch == 27 || ch == 4 )
		break

	if (c=="a") {	
		n=n+1
		o[n] = new wriff()
		o[n].loadrec(2b)
		o[n].strip()
		Root.addtool(o[n],xy(x+10,y+10,x+100,y+100))
		o[n].redraw()
		x=x+30
		y=y+30
	}
	else if (c=="d") {
		if (n==0) {
			print("No more Riffs to delete!")
		}
		else {
		Root.deletetool(o[n])
		x=x-30
		y=y-30
		n=n-1
		}
	}
	else if (c=="p") {
		o[n].seton()
	}
	else if (c=="s") {
		o[n].stop()
	}
	else if (c==c/1 && c<=n) {
		c=c/1
		o[c].seton()
	}		
 }
}
