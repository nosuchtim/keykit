class wbounce {

method init {
	$.w = new window()
	$.inherit($.w)

	$.c = []
	$.w2 = new window()
	$.addchild($.w2)
	$.togg = new ktoggle("On",$,"setonoff")
	$.addchild($.togg)
	$.slide = new kslider(0,100,60,$,"setspeed")
	$.addchild($.slide)
	$.r1 = new wriff() ; $.addchild($.r1)
	$.r2 = new wriff() ; $.addchild($.r2)
	$.r3 = new wriff() ; $.addchild($.r3)
	$.r4 = new wriff() ; $.addchild($.r4)
	$.tid = -1

	$.lines = []
	$.dirs = []
	$.sleeptm = 40
}
method redraw {
	$.w.redraw()
	$.w2.redraw()
	$.line($.sep)
	$.w.text("Bounce",$.textxy)
	$.w.text("Speed",$.speedxy)
	for ( o in $.children() )
		o.redraw()
}
method dump { return([
	"r1"=$.r1.dump(),
	"r2"=$.r2.dump(),
	"r3"=$.r3.dump(),
	"r4"=$.r4.dump()
	])
}
method restore (state) {
	$.r1.restore(state["r1"])
	$.r2.restore(state["r2"])
	$.r3.restore(state["r3"])
	$.r4.restore(state["r4"])
}
method on {
	if ( $.tid >= 0 )
		print("wbounce is already on!?")
	else
		$.tid = task $.task_bounce()
}
method delete {
	kill($.tid)
	millisleep(1000)
}
method off {
	if ( $.tid < 0 )
		print("wbounce not running!?")
	else {
		kill($.tid)
		$.tid = -1
	}
}
method reset {
	$.w2.redraw()
	# $.line($.lines[0],CLEAR)
}
method setonoff (v) { if (v) $.on(); else $.off() }
method setspeed (v) { $.sleeptm = 100-v }

method task_bounce() {
	onexit(global(domethod),$,"reset")
	$.lines[0] = xy($.w2.xmin()+10,$.w2.ymin()+10,
			$.w2.xmin()+30,$.w2.ymin()+30)
	$.dirs[0] = xy(1,2,2,1)
	$.line($.lines[0],XOR)
	while ( 1 ) {
		if ( $.sleeptm > 0 ) {
			sync()
			millisleep($.sleeptm)
		}
		$.line($.lines[0],XOR)
		sz = $.w2.size()

		$.adj($.lines[0],$.dirs[0],sz)

		$.line($.lines[0],XOR)
	}
}

method adj(ln,d,sz) {
	ln["x0"] += d["x0"]
	if ( ln["x0"] < sz["x0"] ) {
		ln["x0"] -= d["x0"]
		d["x0"] = -d["x0"]
		$.r4.bang()
		$.reset()
	}
	else if ( ln["x0"] > sz["x1"] ) {
		ln["x0"] -= d["x0"]
		d["x0"] = -d["x0"]
		$.r2.bang()
		$.reset()
	}

	ln["x1"] += d["x1"]
	if ( ln["x1"] < sz["x0"] ) {
		ln["x1"] -= d["x1"]
		d["x1"] = -d["x1"]
		$.r4.bang()
		$.reset()
	}
	else if ( ln["x1"] > sz["x1"] ) {
		ln["x1"] -= d["x1"]
		d["x1"] = -d["x1"]
		$.r2.bang()
		$.reset()
	}

	ln["y0"] += d["y0"]
	if ( ln["y0"] < sz["y0"] ) {
		ln["y0"] -= d["y0"]
		d["y0"] = -d["y0"]
		$.r1.bang()
		$.reset()
	}
	else if ( ln["y0"] > sz["y1"] ) {
		ln["y0"] -= d["y0"]
		d["y0"] = -d["y0"]
		$.r3.bang()
		$.reset()
	}

	ln["y1"] += d["y1"]
	if ( ln["y1"] < sz["y0"] ) {
		ln["y1"] -= d["y1"]
		d["y1"] = -d["y1"]
		$.r1.bang()
		$.reset()
	}
	else if ( ln["y1"] > sz["y1"] ) {
		ln["y1"] -= d["y1"]
		d["y1"] = -d["y1"]
		$.r3.bang()
		$.reset()
	}
}

method resize(sz) {
	$.w.resize(sz)
	th = $.textheight()
	x0 = $.xmin()+2
	x1 = $.xmax()-2
	dx = x1-x0
	xm = x0 + dx/2
	xm1 = x0 + dx/3
	xm2 = x0 + 2*dx/3

	y0 = $.ymin()+2
	y0a = y0 + th + 6
	y1 = $.ymax()-2
	dy = y1-y0a
	ym1 = y0a + dy/3
	ym2 = y0a + 2*dy/3

	xs1 = x0 + dx/12	# for slider
	xs2 = x0 + 3*dx/12
	ys1 = y0a + th + 4

	$.textxy = xy($.xmin(),$.ymin(),xm, y0a-4)
	$.togg.resize(xy(xm,y0,x1,y0a-4))
	$.slide.resize(xy(xs1,ys1,xs2,ym1-6))
	$.speedxy = xy(xs1,y0a,xs2,ys1)
	$.sep = xy(x0,y0a-2,x1,y0a-2)

	$.w2.resize(xy(xm1,ym1,xm2,ym2))
	$.r1.resize(xy(xm1,y0a,xm2,ym1))
	$.r2.resize(xy(xm2,ym1,x1,ym2))
	$.r3.resize(xy(xm1,ym2,xm2,y1))
	$.r4.resize(xy(x0,ym1,xm1,ym2))
}
}
