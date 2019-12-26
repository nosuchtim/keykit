class whues {
  method init {
    $.w = new window()
    $.inherit($.w)
    $.val_id = 0
    $.val_red = 255
    $.val_green = 255
    $.val_blue = 255
    $.c = []
    $.c["sl_id"] = new kslider(0, 7, 0, $, "set", "id")
    $.c["sl_red"] = new kslider(0, 255, 255, $, "set", "red")
    $.c["sl_green"] = new kslider(0, 255, 255, $, "set", "green")
    $.c["sl_blue"] = new kslider(0, 255, 255, $, "set", "blue")
    $.c["set"] = new ktoggle("Set",$,"tryit")
    $.c["text_id"] = new ktext("")
    $.c["text_red"] = new ktext("")
    $.c["text_green"] = new ktext("")
    $.c["text_blue"] = new ktext("")
    for ( t in $.c )
      $.addchild($.c[t])
    $.set(255, "red")
    for ( i in arraylist("id","red","green","blue") )
      $.set($.("val_"+i),i)
  }
  method set(val, nm) {
    $.("val_"+nm) = val
    t = nm + "\n" + string(val)
    $.c["text_"+nm].set(t)
    $.c["text_"+nm].redraw()
  }
  method tryit {
    colormix($.val_id, $.val_red * 256, $.val_green * 256, $.val_blue * 256)
    Root.redraw()
  }
  method redraw {
    $.w.redraw()
    methodbroadcast()
  }
  method resize (sz) {
    if (nargs() > 0)
      $.w.resize(sz)
    th = $.textheight()
    x0 = $.xmin() + 2
    y0 = $.ymin() + 1
    x1 = $.xmax() - 1
    y2 = $.ymax() - 2
    dy = y2 - y0
    if ( dy < (5 * th) ) {
      y0a = y0 + dy/3
      y0b = y0 + 2*dy/3
    }
    else {
      y0a = y0 + th + 5
      y0b = $.ymax() - 2*th - 5
    }
    dx = ($.xmax() - $.xmin()) / 4
 
    $.c["sl_id"].resize(xy(x0,y0a,x0+dx,y0b-2))
    $.c["sl_red"].resize(xy(x0+2+dx, y0a, x0+2*dx-1,y0b-2))
    $.c["sl_green"].resize(xy(x0+1+2*dx, y0a, x0+3*dx-1, y0b-2))
    $.c["sl_blue"].resize(xy(x0+1+3*dx,y0a,x1-1,y0b-2))
    $.c["set"].resize(xy(x0,y0+1,x1-1,y0a-2))
    $.c["text_id"].resize(xy(x0,y0b,x0+dx,y2))
    $.c["text_red"].resize(xy(x0+2+dx,y0b,x0+2*dx-1,y2))
    $.c["text_green"].resize(xy(x0+1+2*dx,y0b,x0+3*dx-1,y2))
    $.c["text_blue"].resize(xy(x0+1+3*dx,y0b,$.xmax()-2,y2))
  }
}
