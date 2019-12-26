class wnudge {

method init {
	$.w = new window()
	$.inherit($.w)
	$.initval = 500000
	$.inc = 10000
	$.min = 10000
	$.max = 1000000
	$.currval = $.initval
	$.slow1 = new kbutton("wnudge_leftarrow",$,"slower1",1)
	$.slow2 = new kbutton("wnudge_leftarrow2",$,"slower1",2)
	$.fast1 = new kbutton("wnudge_rightarrow",$,"faster1",1)
	$.fast2 = new kbutton("wnudge_rightarrow2",$,"faster1",2)
	$.addchild($.slow1)
	$.addchild($.fast1)
	$.addchild($.slow2)
	$.addchild($.fast2)
}
method redraw {
	$.w.redraw()
	$.w.text("Nudge",$.textxy)
	for ( o in $.children() )
		o.redraw()
}
method slower1(n) {
	lock($)
	t1 = tempo()
	backtime = Now + 1b/4
	tempo(t1*(1+n*0.1))
	task nudge_back(backtime,t1,$)
}
method faster1(n) {
	lock($)
	t1 = tempo()
	backtime = Now + 1b/4
	tempo(t1/(1+n*0.1))
	task nudge_back(backtime,t1,$)
}
method dump { return([]) }
method restore (state) { }
method resize(sz) {
	$.w.resize(sz)
	dy = $.textheight() + 4
	x0 = $.xmin()+2
	x1 = $.xmax()-2
	dx = (x1-x0)/4
	y0 = $.ymin()+2
	y0a = $.ymin()+dy+2
	y1 = $.ymax()-2
	$.textxy = xy($.xmin(),$.ymin(),$.xmax(), y0a)
	$.slow2.resize(xy(x0,y0a,x0+dx,y1))
	$.slow1.resize(xy(x0+dx,y0a,x0+2*dx,y1))
	$.fast1.resize(xy(x0+2*dx,y0a,x0+3*dx,y1))
	$.fast2.resize(xy(x0+3*dx,y0a,x1,y1))
}
}

function wnudge_uparrow() {
	x0 = $.xmin()
	x1 = $.xmax()
	y0 = $.ymin() + 2
	y1 = $.ymax() - 2
	$.line(xy(x0,y1,(x0+x1)/2,y0))
	$.line(xy((x0+x1)/2,y0,x1,y1))
	$.line(xy(x1,y1,x0,y1))
}

function wnudge_downarrow() {
	x0 = $.xmin()
	x1 = $.xmax()
	y0 = $.ymin() + 2
	y1 = $.ymax() - 2
	$.line(xy(x0,y0,(x0+x1)/2,y1))
	$.line(xy((x0+x1)/2,y1,x1,y0))
	$.line(xy(x1,y0,x0,y0))
}
function wnudge_leftarrow() {
	x0 = $.xmin()+2
	x1 = $.xmax()-2
	y0 = $.ymin()
	y1 = $.ymax()
	$.line(xy(x1,y1,x0,(y0+y1)/2))
	$.line(xy(x0,(y0+y1)/2,x1,y0))
	$.line(xy(x1,y0,x1,y1))
}
function wnudge_leftarrow2() {
	x0 = $.xmin()+2
	x1 = $.xmax()-2
	y0 = $.ymin()
	y1 = $.ymax()
	dx = (x1-x0)/4
	dy = (y1-y0)/4
	$.line(xy(x1,y1,x0,(y0+y1)/2))
	$.line(xy(x1,y1-dy,x0+dx,(y0+y1)/2))
	$.line(xy(x0,(y0+y1)/2,x1,y0))
	$.line(xy(x0+dx,(y0+y1)/2,x1,y0+dy))
	$.line(xy(x1,y0,x1,y1))
}

function wnudge_rightarrow() {
	x0 = $.xmin()+2
	x1 = $.xmax()-2
	y0 = $.ymin()
	y1 = $.ymax()
	$.line(xy(x0,y1,x1,(y0+y1)/2))
	$.line(xy(x1,(y0+y1)/2,x0,y0))
	$.line(xy(x0,y0,x0,y1))
}
function wnudge_rightarrow2() {
	x0 = $.xmin()+2
	x1 = $.xmax()-2
	y0 = $.ymin()
	y1 = $.ymax()
	dx = (x1-x0)/4
	dy = (y1-y0)/4
	$.line(xy(x0,y1,x1,(y0+y1)/2))
	$.line(xy(x0,y1-dy,x1-dx,(y0+y1)/2))
	$.line(xy(x1,(y0+y1)/2,x0,y0))
	$.line(xy(x1-dx,(y0+y1)/2,x0,y0+dy))
	$.line(xy(x0,y0,x0,y1))
}

function nudge_back(tm,t) {
	sleeptill(tm)
	tempo(t)
	unlock($)
}
