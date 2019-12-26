
# travaux pratiques: tools


class wtestsliders {

method init {
      $.w = new window()
      $.inherit($.w)

      $.ks = new kslider(0,127,63,$,"action","pouet")
      $.addchild($.ks)

      $.k2ds = new k2dslider(0,127,63,0,127,63,$,"action2d","bof")
      $.addchild($.k2ds)

      $.k3ds = new lozslider(0,0,0,0,127,$,"action_rec","yep")
      $.addchild($.k3ds)

}

method action (p1, s2)
{
	Bprint("val:",p1,"("+s2+")")

}

method action2d (ph, pv, s)
{
	Bprint("val horiz.:",ph,"val vert.:",pv,"("+s+")")

}

method action_rec (a1, a2, a3, a4, s)
{
	Bprint("a1",a1,"a2", a2,"a3",a3,"a4",a4,"("+s+")")

}


method resize(sz) 
{
	if ( nargs() > 0 )
		$.w.resize(sz)

	$.ks.resize(xy($.xmin()+10,$.ymin()+20,$.xmin()+100,$.ymin()+110))
	$.k2ds.resize(xy($.xmin()+10,$.ymin()+120,$.xmin()+100,$.ymin()+210))
	$.k3ds.resize(xy($.xmin()+110,$.ymin()+20,$.xmin()+200,$.ymin()+110))
}

method redraw
{
	$.w.redraw()
	methodbroadcast()
}



}