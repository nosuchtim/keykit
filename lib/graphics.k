# By Brian Gilson (briang@briang.dabsol.co.uk)
#

class graphics {
	method init {
		$.w = new window()
		$.inherit($.w)
		$.style(NOBORDER)
		$.tid = task $.task_draw()
		$.nt = ''
	}
	
	method delete {
		kill($.tid)
	}
	
	method get { return($.nt) }
	method set (v) { 
		$.nt = v
		# print("v = " + string(v))	
		# print("ntv = " + string($.nt))
		return($.nt) 
	}
	method dump { return(["value"=$.get()]) }
	method restore (state) { $.set(state["value"]) }
	method redraw { $.w.redraw() }
	
	method note_time_select {
		# print("$.nt = "+string($.nt))
		print($.nt)
		if ($.nt == '')
			return($.choose_dur())
		else
			return($.nt)
	}
	
	method choose_dur {
			choice = rand(7) # the diceman cometh !
			if (choice == 0) { $.nt =  1b/4}
			if (choice == 1) { $.nt =  1b/3}
			if (choice == 2) { $.nt =  1b/2}
			if (choice == 3) { $.nt =  1b}
			if (choice == 4) { $.nt =  1b*2}
			if (choice == 5) { $.nt =  1b*3}
			if (choice == 6) { $.nt =  1b*4}
			return($.nt)
	}

	method task_draw {
		aswitch = 0 
		
		note_time = $.note_time_select()
		# print ("note_time = " + string(note_time))
		
		l_to_r = 1	
		
		root_x = Root.xmax()/2	# halfway across screen
		
		dx = $.xmax() - $.xmin() # distance across window
		dy = $.ymax() - $.ymin()
		
		hx = dx/2	# halfway across window	
		
		while ( 1 ) {
			sleeptill(Now+note_time)
			
			# set up all the necessary variables -
			if (aswitch == 0) {
				cx = 0 # position in window
				cy = 0
				rx = dx/2 # halfway across window
				ry = dy/2
			
				angle = 0
				count_x = 0
				count_y = 0
				aswitch = 1
				bounce_switch = 1
			}
			
			# SINE WAVE - to and fro
			x_div = (rand(8)+1)*8
			x_unit = dx/x_div
			
			rx = x_unit*count_x
			ry = integer((dy/2)+(sin(angle)*(dy/2)))
			
			# left to right
			if (l_to_r == 1) {
				if ($.xmin()+rx > $.xmax()) {
					cx = 0
					rx = 0
					count_x = 0
					l_to_r = 0
				}
				sz = xy($.xmin()+cx,$.ymin()+cy,$.xmin()+rx,$.ymin()+ry)
				# sz = xy($.xmin()+cx,$.ymin+(dy/2),$.xmin()+(dx/2),$.ymin()+ry)
			}

			# right to left
			if (l_to_r == 0) {
				if ($.xmax()-rx < $.xmin()) {
					cx = 0
					rx = 0
					count_x = -1
					l_to_r = 1
				}
				sz = xy($.xmax()-cx,$.ymin()+cy,$.xmax()-rx,$.ymin()+ry)
					
			}

			cx = rx
			cy = ry
			
			count_x = count_x + 1
			
			if (angle >= 360)
				angle = 0
			else
				angle = angle + 0.05
				
			if ($.xmin()+cx < root_x) vx = root_x-($.xmin()+cx)
			if ($.xmin()+cx > root_x) vx = ($.xmin()+cx)-root_x

# ------ PLAY SINE WAVE NOTE --------------------------------------------------

			pitch_thing = integer(($.ymin()+ry)/7)
			
			if (pitch_thing < 21)
				pitch_thing=pitch_thing+21
				
			# make top of screen the high notes
			
			dur = note_time-12
			vol = 128-((96*vx)/root_x)
			# print(vx)
			# print(root_x)
			# print(vol)
			chan = rand(4)+1
			
			y_pitch = makenote(128-pitch_thing,dur,vol,chan)
			
			y_pitch = scadjust(y_pitch,'c,d,e-,f,g,a,b+')
			
			realtime(y_pitch)

# ------------ DO PROG CHANGE & A whole rectangle ? ----------------------------

			do_prog = rand(768)
			if (do_prog == 0) {
				sz = xy($.xmax()-cx,$.ymin+(dy/2),$.xmin()-(dx/2),$.ymin()+ry)
				prog = rand(36)+8
				realtime(progchange(prog,chan))
			}

# ---------------------COLORS--------------------------------------------------
			
			colormix(5,0,0,0)		# BLACK
			colormix(6,65535,65535,65535)	# WHITE
			colormix(7,65535,0,0)		# RED

#-----------------------DRAWING------------------------------------------------
			
			colorset(5)
			$.fill(xy($.xmin(),$.ymin(),$.xmax(),$.ymax()),STORE)
	
			# EITHER STORE OR CLEAR OR XOR
			choice_style = rand(7)

			colorset(7)
		
       			if (choice_style == 0) $.rectangle(sz,STORE)
			if (choice_style == 1) $.rectangle(sz,STORE)
			if (choice_style == 2) $.rectangle(sz,CLEAR)

			colorset(6)
				
			if (choice_style == 3) $.fillrectangle(sz,CLEAR)
			if (choice_style == 4) $.fillrectangle(sz,STORE)
			if (choice_style == 5) $.fillrectangle(sz,XOR)
			if (choice_style == 6) $.rectangle(sz,XOR)
			
			colorset(1)	# RESET color for buttons etc.
			
		}
	}
}
