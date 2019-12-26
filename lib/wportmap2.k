class wportmap2{

method init {
	$.w = new window()
	$.inherit($.w)

	$.cin = new kmenubutton("default","wportmap2_inputs",$)
	$.addchild($.cin);

	$.c = []
	for ( n=1; n<=16; n++ ) {
		$.c[n] = new kmenubutton("","wportmap2_outputs",$,n)
		$.addchild($.c[n])
	}
	$.title = new ktext("Port Map","left")
	$.addchild($.title)

	$.currinport = 0
	$.currinname = "default"
}

method dump {
	a = []
	return(a)
}
method restore (state) {
}

method redraw {
	$.w.redraw()
	th = $.textheight()
	tw = $.textwidth()
	y0 = $.ymin() ; y1 = y0+(2*th)+10 ; y2 = $.ymax()-4
	x0 = $.xmin() ; x1 = $.xmin()+4*tw+4 ; x2 = $.xmax()-2

	x1a = x0 + (x2-x0)/4
	x1b = x0 + (x2-x0)/2
	dy = (y2-y1)/16

	$.title.resize(xy(x0+2,y0+2,x1a,y0+th+4))
	$.textright("Input =",xy(x1a,y0,x1b,y0+th+4))

	$.text("Ch",xy(x0,y1-th-2,x1,y1))
	$.text("Output",xy(x1,y1-th-2,x2,y1))
	for ( n=1; n<=16; n++ )
		$.text(string(n), xy(x0,y1+(n-1)*dy,x1,y1+n*dy))
	methodbroadcast()
}

method resize(sz) {
	th = $.textheight()
	tw = $.textwidth()
	if ( nargs() > 0 )
		$.w.resize(sz)
	y0 = $.ymin() ; y1 = y0+(2*th)+10 ; y2 = $.ymax()-4
	x0 = $.xmin() ; x1 = $.xmin()+4*tw+4 ; x2 = $.xmax()
	x1b = (x0+x2)/2
	$.cin.resize(xy(x1b,y0+2,x2,y0+th+4))
	dy = (y2-y1)/16
	for ( n=1; n<=16; n++ )
		$.c[n].resize(xy(x1+1,y1+(n-1)*dy,x2-3,y1+n*dy))
}

method inputchanged (portno,name) {
	$.currinpport = portno
	$.currinname = name
	$.cin.settext(name,"right");
	$.cin.redraw()
}
method outputchanged (portno,ch,name) {
	if ( portno < 0 )
		return()
	midi("portmap",$.currinport,ch,portno);
	$.c[ch].settext(name,"right");
	$.c[ch].redraw()
}
}

function wportmap2_inputs(o,po) {
	list = midi("input","list");
	names = []
	vals = []
	i = 0;

	names[i] = "default"
	vals[i] = 0
	i++

	old = Arraysort
	Arraysort = 1
	for ( n in list ) {
		if ( midi("input","isopen",n) ) {
			names[i] = list[n]
			vals[i] = n
			i++
		}
	}
	Arraysort = old
	if ( i == 0 ) {
		names[i] = "No inputs are open (use Port Enabler tool)"
		vals[i] = -1
		i++;
	}
	for ( n=0; n<i; n++ ) {
		o.menucmd(names[n],po,"inputchanged",vals[n],names[n])
	}
}
function wportmap2_outputs(o,po,ch) {
	list = midi("output","list");
	names = []
	vals = []
	i = 0;
	old = Arraysort
	Arraysort = 1
	for ( n in list ) {
		if ( midi("output","isopen",n) ) {
			names[i] = list[n]
			vals[i] = n
			i++
			
		}
	}
	Arraysort = old
	if ( i == 0 ) {
		names[i] = "No outputs are open (use Port Enabler tool)"
		vals[i] = -1
		i++;
	}
	for ( n=0; n<i; n++ ) {
		o.menucmd(names[n],po,"outputchanged",vals[n],ch,names[n])
	}
}
