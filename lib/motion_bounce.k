class motion_bounce {
	method init(top) {
		$.mt = new motion(top)
		$.inherit($.mt)
if($$.debug)print("++++ Motion_bounce $=",$,"  $.mt=",$.mt)
	}
	method move1(sh) {
		posxy = sh.getpos()
if($$.debug)print("\nMOTION BOUNCE MOVE1 initial posx=",posxy["x0"]," posy=",posxy["y0"])
		v = $.getparam("DELTA")
		posx = posxy["x0"] + $$.dx * v
		posy = posxy["y0"] + $$.dy * v
if($$.debug)print("    MOTION BOUNCE MOVE1 final posx=",posx,posy)
		sh.setpos(posx,posy)
	}
	method bound1(sh,init_x,init_y) {
if($$.debug)print("\nBBB motion_bounce BOUND1 , sh=",sh," init_xy=",init_x,init_y,"  dxy=",$$.dx,$$.dy)
		bounds = sh.getbounds()
		posxy = sh.getpos()
		posx = posxy["x0"]
		posy = posxy["y0"]
if($$.debug)print("   bounds = ",bounds," posxy=",posxy)
		px0 = posx + bounds["x0"]
		px1 = posx + bounds["x1"]
if($$.debug)print("      1? px0=",px0," px1=",px1,"  bounds=",bounds)
		if ( px1 > 1.0 ) {
			posx = 1.0 - (px1-1.0) - bounds["x1"]

			# Hmmm, do not combine the statements below,
			# it tickles a bug in keykit parser, I think
			f = -($$.dx)
			$$.dx = f

if($$.debug)print("BBBBOUNCING REVERSED X direction A, $$.dy=",$$.dy)
		} else if ( px0 < 0.0 ) {
if($$.debug)print("BEFORE REVERSE, POSX=",posx," px0=",px0)
			posx = -px0 - bounds["x0"]
if($$.debug)print("    AFTER REVERSE, POSX=",posx," px0=",px0)
			f = -($$.dx)
			$$.dx = f
if($$.debug)print("BBBBOUNCING REVERSED X direction B, $$.dy=",$$.dy)
		}
		py0 = posy + bounds["y0"]
		py1 = posy + bounds["y1"]
if($$.debug)print("      py1=",py1)
		if ( py1 > 1.0 ) {
if($$.debug)print("BEFORE REVERSE, POSY=",posy," py1=",py1)
			posy = 1.0 - (py1-1.0) - bounds["y1"]
if($$.debug)print("   AFTER REVERSE, POSY=",posy," py1=",py1)
			f = -($$.dy)
			$$.dy = f
if($$.debug)print("BBBBOUNCING REVERSED Y direction A, $$.dy=",$$.dy)
		} else if ( py0 < 0.0 ) {
			posy = -py0 - bounds["y0"]
			f = -($$.dy)
			$$.dy = f
if($$.debug)print("BBBBOUNCING REVERSED Y direction B, $$.dy=",$$.dy)
		}
if($$.debug)print("  NEW posxy=",posx,posy)
		sh.setpos(posx,posy)
	}
}
