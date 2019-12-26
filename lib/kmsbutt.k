#name	kmsbutton

class kmsbutton {

method init (po,meth,bn,...) {

	$.c = new kmenubutton("Aud Sweep","kmsbutton_mkmenu",po,meth,bn,...)
	$.inherit($.c)
}
}

function kmsbutton_mkmenu(o,po,meth,bn,...) {
	o.submenu("Aud   ->","mkmenu_buttaud",po,meth,bn,...)
	o.submenu("Pick  ->","mkmenu_buttpick",po,meth,bn,...)
	o.submenu("Drag  ->","mkmenu_buttdrag",po,meth,bn,...)
	o.submenu("Draw  ->","mkmenu_draw",po,meth,bn,...)
	o.submenu("Paste ->","mkmenu_buttpaste",po,meth,bn,...)
	o.submenu("Insert->","mkmenu_buttinsert",po,meth,bn,...)
	o.submenu("Append->","mkmenu_buttappend",po,meth,bn,...)
	o.menucmd("Open",po,meth,9,bn,...)
	o.menucmd("Close",po,meth,10,bn,...)
	# o.menucmd("Info",po,meth,13,bn,...)
	o.menucmd("Brush",po,meth,11,bn,...)
	o.menucmd("Pluck",po,meth,25,bn,...)
	# o.menucmd("Trigger",po,meth,14,bn,...)
	o.menucmd("Tool",po,meth,42,bn,...)
}
function mkmenu_buttpaste(o,po,meth,bn,...) {
	o.menucmd("Snarf",po,meth,12,bn,...)
	o.menucmd("Last Rec (Note/Chord)",po,meth,34,bn,...)
	o.menucmd("Last Rec (2b space)",po,meth,35,bn,...)
}
function mkmenu_buttinsert(o,po,meth,bn,...) {
	o.menucmd("Snarf",po,meth,36,bn,...)
	o.menucmd("Last Rec (Note/Chord)",po,meth,37,bn,...)
	o.menucmd("Last Rec (2b space)",po,meth,38,bn,...)
}
function mkmenu_buttappend(o,po,meth,bn,...) {
	o.menucmd("Snarf",po,meth,39,bn,...)
	o.menucmd("Last Rec (Note/Chord)",po,meth,40,bn,...)
	o.menucmd("Last Rec (2b space)",po,meth,41,bn,...)
}
function mkmenu_buttdrag(o,po,meth,bn,...) {
	o.menucmd("Time",po,meth,6,bn,...)
	o.menucmd("Dur",po,meth,7,bn,...)
	o.menucmd("Pitch",po,meth,8,bn,...)
}

function mkmenu_buttaud(o,po,meth,bn,...) {
	o.menucmd("Play",po,meth,1,bn,...)
	o.menucmd("Sweep",po,meth,0,bn,...)
	o.menucmd("Loop",po,meth,27,bn,...)
}

function mkmenu_buttpick(o,po,meth,bn,...) {
	o.menucmd("Play",po,meth,5,bn,...)
	o.menucmd("Pick Sweep",po,meth,2,bn,...)
	o.menucmd("Pick+Sweep",po,meth,33,bn,...)
	o.menucmd("Pick-Sweep",po,meth,31,bn,...)
	o.menucmd("Pick&Sweep",po,meth,32,bn,...)
	o.menucmd("Pick Strip",po,meth,16,bn,...)
	o.menucmd("Pick+Strip",po,meth,30,bn,...)
	o.menucmd("Pick-Strip",po,meth,28,bn,...)
	o.menucmd("Pick&Strip",po,meth,29,bn,...)
	o.menucmd("Pick 1",po,meth,24,bn,...)
	o.menucmd("Pick +1",po,meth,3,bn,...)
	o.menucmd("Pick -1",po,meth,4,bn,...)
	o.menucmd("Stretch",po,meth,15,bn,...)
	o.menucmd("Oct Shift",po,meth,17,bn,...)
}
function mkmenu_draw(o,po,meth,bn,...) {
	o.menucmd("Volume",po,meth,18,bn,0x07,...)
	o.menucmd("Modulation",po,meth,19,bn,0x01,...)
	o.menucmd("Expression",po,meth,20,bn,0x0b,...)
	o.menucmd("Pan",po,meth,21,bn,0x0a,...)
	o.menucmd("Reverb",po,meth,22,bn,0x5b,...)
	o.menucmd("Chorus",po,meth,23,bn,0x5d,...)
	o.menucmd("Notes",po,meth,26,bn,...)
}

