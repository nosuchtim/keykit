###########################################################################################
#
#  GéoMaestro  v0.8		   Compositeur				(Juillet 2000)
#
###########################################################################################



class wcompositor {

method init() {


      $.w = new window()
      $.inherit($.w)

      $.f = new wgraphes()
      $.addchild($.f)
      $.f.parentGUI($)

      $.col1 = 200
      $.col2 = 150
 

      $.modes = [
	      0 = GMblah_GUImen0,	#"infos",
	      1 = GMblah_GUImen1,	#"zoom",
	      2 = GMblah_GUImen2,	#"move around",
	      3 = "grab boxes",
	      4 = "new box",
	      5 = "new link"
      ]
      $.defmode1 = 3		# modes par défaut (dumpés)
      $.defmode2 = 2		#
      $.mobut = []
      for (n=1; n<=2; n++)
      {
	  $.mobut[n] = new kvalbutton($.modes, $, "setmousemode", n)
	  $.addchild($.mobut[n])
      }
      $.mobut[1].set($.defmode1) ; $.setmousemode($.defmode1,1)
      $.mobut[2].set($.defmode2) ; $.setmousemode($.defmode2,2)


      $.listbox = $.f.makelistbox()
      $.blist = new kvalbutton($.listbox, $, "setcurrbox", n)
      $.addchild($.blist)
      $.setcurrbox(0)



      $.bredraw = new kbutton(textfunc(GMblah_GUI42), $, "redraw")
      $.addchild($.bredraw)
      $.bundo = new kbutton(textfunc("UNDO"), $, "undo")
      $.addchild($.bundo)
      $.bpourundo = new kbutton(textfunc("STO"), $, "prepare_undo",GMblah_UNDO20)
      $.addchild($.bpourundo) 
      $.bzin = new kbutton(textfunc(GMblah_GUI43), $, "zoomin")
      $.addchild($.bzin)
      $.bzout = new kbutton(textfunc(GMblah_GUI44), $, "zoomout")
      $.addchild($.bzout)
      $.bzauto = new kbutton(textfunc("auto"), $, "zoomauto")
      $.addchild($.bzauto)
    
}

method dump(fnom, eraselast)
{
	st = []

	return(st)
}
method restore(st)
{


	$.resize()
	$.redraw()
}

method redraw() {
      th = $.textheight()
      tw = $.textwidth()

      $.w.redraw()

      $.text("mouse1 ",xy($.xmax()-$.col1, $.ymin(), $.xmax()-$.col2, $.ymin()+1.5*th))
      $.text("mouse2 ",xy($.xmax()-$.col1, $.ymin()+1.5*th, $.xmax()-$.col2, $.ymin()+3*th)) 

      methodbroadcast()
}

method resize (sz) {
       th = $.textheight()
       tw = $.textwidth()

       if (nargs() >= 1)
       { 
		if (sz["x1"]-sz["x0"] < $.col1+50)  sz["x1"] = sz["x0"] + $.col1+50
		if (sz["y1"]-sz["y0"] < th*20)  sz["y1"] = sz["y0"] + th*20	
		$.w.resize(sz)     
		$.f.resize(xy($.xmin(), $.ymin(), $.xmax()-$.col1, $.ymax())) 
       }

       $.mobut[1].resize(xy($.xmax()-$.col2, $.ymin(), $.xmax(), $.ymin()+1.5*th)) 
       $.mobut[2].resize(xy($.xmax()-$.col2, $.ymin()+1.5*th, $.xmax(), $.ymin()+3*th))

       $.blist.resize(xy($.xmax()-$.col1, $.ymin()+4.5*th, $.xmax(), $.ymin()+6*th))

       $.bredraw.resize(xy($.xmax()-$.col1+tw, $.ymax()-7*th, $.xmax()-$.col2+3*tw, $.ymax()-5*th))
       $.bundo.resize(xy($.xmax()-$.col1+4.5*tw, $.ymax()-5*th, $.xmax()-$.col2+3*tw, $.ymax()-3.5*th))
       $.bpourundo.resize(xy($.xmax()-$.col1+tw, $.ymax()-5*th, $.xmax()-$.col1+4.5*tw, $.ymax()-3.5*th))
       $.bzin.resize(xy($.xmax()-$.col1, $.ymax()-3*th, $.xmax()-$.col1+10*tw, $.ymax()-1.5*th))
       $.bzout.resize(xy($.xmax()-$.col1, $.ymax()-1.5*th, $.xmax()-$.col1+10*tw, $.ymax()))
       $.bzauto.resize(xy($.xmax()-$.col1+10*tw, $.ymax()-3*th, $.xmax()-10*tw, $.ymax()))       
}



method setcurrbox(n) {
       $.f.setcurrbox(n+1)
}

method setmousemode(v, n) {
       $.f.setmousemode(n, v)
}


method zoomin() {
       $.f.zoomin()
}
method zoomout() {
       $.f.zoomout()
}
method zoomauto() {
       $.f.zoomauto()
}






# fin class wcompositor
}


########################################################################################

########################################################################################

########################################################################################

class wgraphes {

method init() {

       $.w = new window()
       $.inherit($.w)

       $.hauteur = 10

       $.boites = [1= $.exemple_de_boite(1),       
		   2= $.exemple_de_boite(2),
		   3= $.exemple_de_boite(3),
		   4= $.exemple_de_boite(4)]


       $.selbox = 0


       $.bornes = $.autobornes($.boites)



       # mode d'utilisation de la souris:

       $.Zonage_infos = 0
       $.Recadrage = 1
       $.MoveAround = 2
       $.MoveBox = 3
       $.NewBox = 4
       $.NewLink = 5
       $.mouse_mode = []   # (défaut éventuel)


}


method parentGUI(o) {
       $.GUI = o
}

method dump()
{
	st = []

	return(st)
}

method restore(st)
{

}



method redraw(bornes) {

       $.w.redraw()
       $.principal = xy($.xmin(),$.ymin(),$.xmax(),$.ymax())

       color(1)
       for (i in $.boites)
       {
         if (i == $.selbox) color(2)
	 $.drawboite($.boites[i],$.principal)
	 $.drawliens($.boites[i],$.principal)
	 color(1)
       }
 
}
method drawboite(b,fenetre) {

       $.rectangle(xy($.xE(b["x"]),$.yE(b["y"]),$.xE(b["x"]+b["l"]),$.yE(b["y"]+$.hauteur)))
       if (b["m"] != [])
	  for (m in b["m"])
	  {
	      mx = b["x"]+b["m"][m]*b["l"]
	      $.line(xy($.xE(mx),$.yE(b["y"]),$.xE(mx),$.yE(b["y"]+$.hauteur)))
	  }
}
method drawliens(b,fenetre) {

       if (b["nex"]!=[]) for (l in b["nex"]) if (l in $.boites)
       {
           if (b["nex"][l] != -1)	# entre 0 et 1: marqueur
	   {
		cx = $.xE($.boites[l]["x"])
		cy = $.yE($.boites[l]["y"]+0.5*$.hauteur)
		xd = $.xE(b["x"]+b["l"])
		yd = $.yE(b["y"]+0.5*$.hauteur)
		$.line(xy(xd,yd,cx,cy))
           }
       }

}



method xE(xev) {
 return ($.xmin()+($.xmax()-$.xmin())*(xev-$.bornes["x0"])/float($.bornes["x1"]-$.bornes["x0"]))
}
method yE(yev) {
 return ($.ymax()-($.ymax()-$.ymin())*(yev-$.bornes["y0"])/float($.bornes["y1"]-$.bornes["y0"]))
}
method xb(xec, mode_arrondi) {
 exact = $.bornes["x0"]+($.bornes["x1"]-$.bornes["x0"])*(xec-$.xmin())/float($.xmax()-$.xmin())
 if (nargs() == 1) mode_arrondi = 0
 if ((mode_arrondi == 0) || (($.bornes["x1"]-$.bornes["x0"]) < 0.01)) return(exact)
 else if (mode_arrondi) return (0.0001*Arrondi(10000*exact))
}
method yb(yec, mode_arrondi) {
 exact = $.bornes["y1"]-($.bornes["y1"]-$.bornes["y0"])*(yec-$.ymin())/float($.ymax()-$.ymin())
 if (nargs() == 1) mode_arrondi = 0
 if ((mode_arrondi == 0) || (($.bornes["x1"]-$.bornes["x0"]) < 0.01)) return(exact)
 else if (mode_arrondi) return (0.0001*Arrondi(10000*exact))
}
method autobornes(niveau) {      
	  x0 = y0 = 0
	  x1 = y1 = 0
	  for (i in niveau) 
	  {
		x0 = Minimum(x0, niveau[i]["x"])
		x1 = Maximum(x1, niveau[i]["x"]+niveau[i]["l"])
		y0 = Minimum(y0, niveau[i]["y"])
		y1 = Maximum(y1, niveau[i]["y"]+1.5*$.hauteur)
	  }  
	  x0 -= 1
	  x1 += 1
	  y0 -= 1
	  y1 += 1
		
	  return(xyd(x0, y0, x1, y1))
}




method resize(sz) {

        if ( nargs() > 0 ) 
	{
		rapportx = float(sz["x1"]-sz["x0"])/($.bornes["x1"]-$.bornes["x0"])
		rapporty = float(sz["y1"]-sz["y0"])/($.bornes["y1"]-$.bornes["y0"])

		if (rapportx < rapporty)
		{
		   raby = (sz["y1"] - sz["y0"])/rapportx
		   $.bornes["y1"] = $.bornes["y0"] + raby
		}
		else
		{
		   rabx = (sz["x1"] - sz["x0"])/rapporty
		   $.bornes["x1"] = $.bornes["x0"] + rabx
		}
		$.w.resize(sz) 
	}	

	return (sz)

}






method setcurrbox(n) { $.currbox = n }


method zoomin () {
        cx = 0.5*($.bornes["x1"]+$.bornes["x0"])
	cy = 0.5*($.bornes["y1"]+$.bornes["y0"])
	ix = 0.25*($.bornes["x1"]-$.bornes["x0"])
	iy = 0.25*($.bornes["y1"]-$.bornes["y0"])
	$.bornes = xyd(cx-ix, cy-iy, cx+ix, cy+iy)
	$.redraw()
}

method zoomout () {
        cx = 0.5*($.bornes["x1"]+$.bornes["x0"])
	cy = 0.5*($.bornes["y1"]+$.bornes["y0"])
	ix = ($.bornes["x1"]-$.bornes["x0"])
	iy = ($.bornes["y1"]-$.bornes["y0"])
	$.bornes = xyd(cx-ix, cy-iy, cx+ix, cy+iy)
	$.redraw()
}

method zoomauto () {
	$.bornes = $.autobornes($.boites)
	$.redraw()
}

###@@@@@@@@@@@@@@@@@@@@@@@@
########## très provisoire :

method exemple_de_boite(n) {

       return ( [
		"nom"= "boite exemple num."+string(n),
		"ph"= 'a,b,c',
		"traitements"= [],
		"nex"= [],
		"t0"= 0,
		"m"= [1 = 0.2 , 2 = 0.5, 3=0.6],
		"interne"= "",
		"x"= 10*n,
		"y"= 10*n+2*$.hauteur,
		"l"= 20*n
		] )
}



method makelistbox() {
       $.listebox = [1= $.exemple_de_boite(1),
		     2= $.exemple_de_boite(2),
		     3= $.exemple_de_boite(3),
		     4= $.exemple_de_boite(4)]

      # ça commence ici en fait:

      list = []
      for (i in $.listebox)
	  list[i-1] = $.listebox[i]["nom"]

      return (list)

}

###@@@@@@@@@@@@@@@@@@@@@@@@






#########################################################################################
## Souris

method setmousemode(nbutt, mode) {
       $.mouse_mode[nbutt] = mode 
}


method mousedown(m) {
       mode = $.mouse_mode[m["button"]]
       $.ignoreup = 0
       $.mbutton = m["button"]

       if (mode == $.MoveBox)
	  $.mousedown_idbox(m)

       else if (mode == $.MoveAround)
       {
	  $.ignoreup = 1		# pas d'action en up
          $.point_ref(m)
       }

       else if (mode == $.NewBox)
       {
	  $.ignoreup = 1
	  $.new_box(m)
       }

       else if (mode == $.NewLink)
       {
	  $.mousedown_idbox(m)
       }

}
method mousedrag(m) {
       mode = $.mouse_mode[m["button"]]

       if (mode == $.MoveBox)
          $.dragbox(m)

       else if (mode == $.MoveAround)
          $.movedirect(m)

       else if (mode == $.NewLink)
          $.showlink(m)

}
method mouseup(m) {
       mode = $.mouse_mode[$.mbutton]


       if (mode == $.NewLink)
       {
          $.createlink(m)
	  
       }
} 






method new_box(m) {

       $.selbox = sizeof($.boites)+1

       $.boites[$.selbox] = ArCopy($.listebox[$.currbox])
       $.boites[$.selbox]["x"] = $.xb(m["x"])
       $.boites[$.selbox]["y"] = $.yb(m["y"])
	  
       $.redraw()

}

method mousedown_idbox(m) {

       $.selbox = 0

       for (i in $.boites)
	   if ($.inthebox($.boites[i],m)) $.selbox=i
	  
       $.redraw()

}

method inthebox(box,po) {

       px = $.xb(po["x"])
       py = $.yb(po["y"])
       return ((px>=box["x"])&&(px<=box["x"]+box["l"])&&(py>=box["y"])&&(py<=box["y"]+$.hauteur))

}

method dragbox(m) {

       if ($.selbox != 0)
       {
	  $.boites[$.selbox]["x"] = $.xb(m["x"])
	  $.boites[$.selbox]["y"] = $.yb(m["y"])
	  $.redraw()
       }


}

method showlink(m) {

       if ($.selbox != 0)
       {
		$.redraw()
		xd = $.xE($.boites[$.selbox]["x"]+$.boites[$.selbox]["l"])
		yd = $.yE($.boites[$.selbox]["y"]+0.5*$.hauteur)
		$.line(xy(m["x"],m["y"],xd,yd))
       }
}
method createlink(m) {

       if ($.selbox != 0)
       {
          cible = 0
          for (i in $.boites)
	     if ($.inthebox($.boites[i],m) == 1) cible = i
	  
          if ((cible != 0) && (cible != $.selbox))
   		$.boites[$.selbox]["nex"][cible] = 1	#	1 provisoire !!
          for (i in $.boites) if (i != $.selbox)
	     if (cible in $.boites[i]["nex"]) $.boites[i]["nex"][cible] = -1

     
          $.redraw()
       }
}


method point_ref(m) {
       $.refx = m["x"]
       $.refy = m["y"]
}




method movedirect(m) {
       vx = -(m["x"]-$.refx)*(r=($.bornes["x1"]-$.bornes["x0"])/float($.xmax()-$.xmin()))
       vy = (m["y"]-$.refy)*r
       
       $.bornes["x0"] += vx
       $.bornes["x1"] += vx
       $.bornes["y0"] += vy
       $.bornes["y1"] += vy

       $.redraw()

       $.refx = m["x"]
       $.refy = m["y"]
}





# fin class wfen
}




