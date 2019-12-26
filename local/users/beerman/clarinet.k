############################################################
#
#template for work for electric clarinet and computer 
# 
############################################################

function clarinet() {
start=Now
	print("clarinet...")

	# All times computed by the program will be
	# relative to Start, so that things are all
	# synchronized to a common starting point.

	Start = Now

	# All of the values here in seconds

        point1 = 1
			point1a=15
	    point2 = 30
			point2a=37
		point3 = 60
        

	######################################
	# PHRASES 
	######################################
	a=''
	
	
	
	######################################
	# PERFORMANCE TASKS FOR IN RESPONSE TO THE CLARINET
	######################################

	#################
	# SECTION ONE  o'-1'10"
	#################

	# point 1 to 2

	dofrom(point1,point2,60,63,1,doit(10,20b))
	B=A
	realtime(B,start+seconds(20))
	
	# point 2 to 3
	dofrom(point2,point3,60,63,1,doit(10,20b))
	C=A
	realtime(A,start+seconds(40))
	
	
	
	
		
		
		
		
	
		
	
		
		
		
		
	
	########
	# Things below are not triggered by the clarinet.
	# Play various phrases at specific points in the piece.
	########

	# SECTION ONE
	
		playAt(point1,'')
       

	# Print messages at each point in the piece.

	printAt(point1,"POINT 1")
	printAt(point2,"POINT 2")
	printAt(point3,"POINT 3")
	}

