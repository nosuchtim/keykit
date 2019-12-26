###########################################################################################
#
#  GéoMaestro  v0.8		Interface Graphique				(Juin 2000)
#
###########################################################################################



class wev {

method init() {


      $.w = new window()
      $.inherit($.w)

      $.f = new wfen()
      $.addchild($.f)
      $.f.parentGUI($)

      $.modes = [
	      0 = GMblah_GUImen0,	#"infos",
	      1 = GMblah_GUImen1,	#"zoom",
	      2 = GMblah_GUImen2,	#"move around",
	      3 = GMblah_GUImen3,	#"new point",
	      4 = GMblah_GUImen4,	#"new event",
	      5 = GMblah_GUImen5,	#"selection",
	      6 = GMblah_GUImen6,	#"move selection",
	      7 = GMblah_GUImen7,	#"rotate selection",
	      8 = GMblah_GUImen8,	#"copy selection",
	      9 = GMblah_GUImen9,	#"phrase to segment",
	      10 = GMblah_GUImen10,	#"phrase to circle",
	      11 = GMblah_GUImen12,	#"hear ev/seg",
	      12 = GMblah_GUImen11	#"define zone"
      ]
      $.defmode1 = 2		# modes par défaut (dumpés)
      $.defmode2 = 0		#
      $.mobut = []
      for (n=1; n<=2; n++)
      {
	  $.mobut[n] = new kvalbutton($.modes, $, "setmousemode", n)
	  $.addchild($.mobut[n])
      }
      $.mobut[1].set($.defmode1) ; $.setmousemode($.defmode1,1)
      $.mobut[2].set($.defmode2) ; $.setmousemode($.defmode2,2)

      $.selmodes = [0= GMblah_GUI29, 1= "plus", 2= GMblah_GUI30]
      $.bsel = new kvalbutton($.selmodes, $, "setselmode")
      $.addchild($.bsel)
      $.defselmode = 0		# mode par défaut (dumpé)
      $.bsel.set($.defselmode) ; $.setselmode($.defselmode)

      $.bpc = new kbutton(textfunc(GMblah_GUI31), $, "affichepoints")
      $.addchild($.bpc)

      $.col1 = 200
      $.col2 = 150

      $.befface = new kbutton(textfunc(GMblah_GUI32), $, "efface")
      $.addchild($.befface)
      $.bform = new kbutton(textfunc(GMblah_GUI33), $, "formule")
      $.addchild($.bform)

      $.tmodes = [
	      0 = "points -> piste",
	      1 = GMblah_GUI49,
	      2 = GMblah_GUI50,
	      3 = GMblah_GUI51
      ]	
      $.tmobut = new kvalbutton($.tmodes, $, "settmode", n)
      $.addchild($.tmobut)
      $.tmobut.set($.tmode = 0)		# par défaut
      $.btrans = new kbutton(textfunc("--->"), $, "transfertsel")
      $.addchild($.btrans)

      $.bact = new kbutton(textfunc("active"), $, "evact")
      $.addchild($.bact)     
      $.binact = new kbutton(textfunc(GMblah_GUI56), $, "evinact")
      $.addchild($.binact)

      $.bnew = new kbutton(textfunc(GMblah_GUI34), $, "newev")
      $.addchild($.bnew)     
      $.bwrite = new kbutton(textfunc(GMblah_GUI35), $, "writeev")
      $.addchild($.bwrite)
      $.bread = new kbutton(textfunc(GMblah_GUI36), $, "loadev")
      $.addchild($.bread)
      $.baddsc = new kbutton(textfunc(GMblah_GUI37), $, "addsc")
      $.addchild($.baddsc)

      $.btog0 = new kbutton(textfunc("ev"), $, "toggle", 0)
      $.addchild($.btog0)
      $.btog1 = new kbutton(textfunc("pj"), $, "toggle", 1)
      $.addchild($.btog1)
      $.btog2 = new kbutton(textfunc("fn"), $, "toggle", 2)
      $.addchild($.btog2)
      $.togmode = 0

      $.projecteur = 0
      $.projlist = [0=GMblah_GUI38]
      $.projinfos = proj_infos()
      for (i = 1; i<= $.projinfos[0]; i++) $.projlist[i] = $.projinfos[i]["nom"]
      $.bproj = new kvalbutton($.projlist, $, "setproj")
      $.addchild($.bproj)
      $.bprogo = new kbutton(textfunc("--->"), $, "projection")
      $.addchild($.bprogo)
      
      $.lstock = [0=0]		# Stock de lignes projetées
      $.licoms = []
      $.lignes=[0="Snarf                                "]
      $.currlin = 0
      $.blignes = new kvalbutton($.lignes, $, "infoligne")
      $.addchild($.blignes)
      $.baction = new kbutton(textfunc("Ex"), $, "lignexport")
      $.addchild($.baction)
      $.bexport = new kbutton(textfunc("->"), $, "onelignexport")
      $.addchild($.bexport)

      $.bhear = new kbutton(textfunc(GMblah_GUI39), $, "hearligne")
      $.addchild($.bhear)
      $.bredo = new kbutton(textfunc(GMblah_GUI40), $, "redoligne")
      $.addchild($.bredo)
      $.bsnarf = new kbutton(textfunc("snarf"), $, "snarfligne")
      $.addchild($.bsnarf)
      $.bkill = new kbutton(textfunc(GMblah_GUI41), $, "killligne")
      $.addchild($.bkill)

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
      $.bgrid = new kbutton(textfunc(GMblah_GUI45), $, "anneau_grid")
      $.addchild($.bgrid)
      $.bseg = new kbutton(textfunc("proj"), $, "anneau_seg")
      $.addchild($.bseg)      
      $.btaille = new kbutton(textfunc(GMblah_GUI46), $, "anneau_symboles")
      $.addchild($.btaille)
      $.bsnap = new kbutton(textfunc(GMblah_GUI63), $, "anneau_snap")
      $.addchild($.bsnap)

      $.currPAC = 0
      $.currf = 0
      $.currfonc = 0	# index de fonclist
      $.currch = 1

      $.bPAC = new kbutton(textfunc("PAC"), $, "definePAC")
      $.addchild($.bPAC) 
      $.bf1 = new kbutton(textfunc("->"), $, "setPAC")
      $.addchild($.bf1)
      pmap = patchmap()
      $.pbchange = []
      for (n=0; n<=sizeof(pmap)-1; n++) $.pbchange[n] = pmap[n]["name"]
      $.blis1 = new kvalbutton($.pbchange, $, "setcurPAC")
      $.addchild($.blis1) 
      $.fonclist = [0= "Vol", 1= "Pit", 2= "Dur", 3= "Pan"]
      $.bfonc = new kvalbutton($.fonclist, $, "setcurfonc")
      $.addchild($.bfonc)
      $.distort_liste = choice_of_distortions()
      $.distort_parameters = parameters_infos()
      $.blis2 = new kvalbutton($.distort_liste, $, "setfonc")
      $.addchild($.blis2)       
      $.bf2 = new kbutton(textfunc("->"), $, "menutof")
      $.addchild($.bf2)
      $.listch = []
      for (ch=1; ch <=NbCan; ch++) $.listch[ch-1] = "ch "+string(ch)
      $.bch = new kvalbutton($.listch, $, "setch")
      $.addchild($.bch)
      $.binfos = new kbutton(textfunc(GMblah_GUI48), $, "showsettings")
      $.addchild($.binfos) 

      $.realid = 0      
      $.init_undo(20)
}

method dump(fnom, eraselast)
{
	st = []
	st["mmodes"] = [1= ($.mobut[1].dump())["n"], 2= ($.mobut[2].dump())["n"]]
	st["selmode"] = ($.bsel.dump())["n"]
	st["tmode"] = $.tmode
	st["togmode"] = $.togmode
	st["f"] = $.f.dump()

	st["l1"] = ArCopy($.lstock)
	st["l2"] = ArCopy($.licoms)
	st["l3"] = ArCopy($.lignes)
	st["cl"] = ArCopy($.currlin) 

	st["ev"] = ArCopy(Ev)			

	st["fvol"] = ArCopy(Volume)
	st["fpit"] = ArCopy(Pit)
	st["fdur"] = ArCopy(Dur)
	st["fpan"] = ArCopy(Pan)

	st["LOG"] = ArCopy(LOG)
	st["FKK"] = ArCopy(FKK)
	st["FT"] = ArCopy(FT)
	st["SNARF"] = ArCopy(SNARF)
	st["FIF"] = ArCopy(FIF)	

	for (v in GVARS) eval("GVARS["+"\""+v+"\""+"]="+string(v))
	st["GVARS"] = ArCopy(GVARS)

	return(st)
}
method restore(st)
{
	$.mobut[1].set(st["mmodes"][1])
	$.setmousemode(st["mmodes"][1],1)
	$.mobut[2].set(st["mmodes"][2])
	$.setmousemode(st["mmodes"][2],2)
	$.bsel.set(st["selmode"])
	$.setselmode(st["selmode"])
	$.tmode = st["tmode"]
	$.togmode = st["togmode"]
	$.tmobut.set($.tmode)

	$.f.restore(st["f"])

	$.lstock = ArCopy(st["l1"])
	RL = []
	if ($.lstock[0] > 0 ) for (i=1; i<= $.lstock[0]; i++)
	   { T__ = $.lstock[i]; eval("RL["+string(i)+"]=T__") }

	$.licoms = ArCopy(st["l2"])
	$.lignes = ArCopy(st["l3"])
	$.currlin = ArCopy(st["cl"])
	$.blignes.setvals($.lignes)
	$.blignes.set($.currlin)
	
	Ev = ArCopy(st["ev"])	

	Volume = ArCopy(st["fvol"])
	Pit = ArCopy(st["fpit"])
	Dur = ArCopy(st["fdur"])
	Pan = ArCopy(st["fpan"])

	LOG = ArCopy(st["LOG"])
	FKK = ArCopy(st["FKK"])
	FT = ArCopy(st["FT"])
	SNARF = ArCopy(st["SNARF"])
	FIF = ArCopy(st["FIF"])	
	GVARS = ArCopy(st["GVARS"])
	ReVAR()

	$.resize()
	$.redraw()
}

method init_undo(n) {
       $.undostack = []
       $.nundo = 0
       $.undo_size = n		
}

method prepare_undo(infocom) {

       if (nargs() == 0) infocom = " ? "

       if ($.nundo > 0) for (n=$.nundo; n>=1; n--)
	  $.undostack[n] = $.undostack[n-1]

       $.undostack[0] = ["info"= infocom,
			 "ev"= ArCopy(Ev),
			 "fdump"= $.f.dump()]
       $.nundo = Minimum($.nundo+1, $.undo_size-1)
       print("("+GMblah_UNDO21+infocom+")")
}

method undo() {
       if ($.nundo > 0)
       {
		$.f.restore($.undostack[0]["fdump"])
		Ev = ArCopy($.undostack[0]["ev"])



		print(GMblah_GUI62+$.undostack[0]["info"])

		for (n = 1; n <=$.nundo; n++)
		    $.undostack[n-1] = $.undostack[n]		    
		$.nundo -= 1
		$.redraw()
       }
       else print(GMblah_GUI67)
}

method redraw() {
      th = $.textheight()
      tw = $.textwidth()

      $.w.redraw()
      $.text("mouse1 ",xy($.xmax()-$.col1, $.ymin(), $.xmax()-$.col2, $.ymin()+1.5*th))
      $.text("mouse2 ",xy($.xmax()-$.col1, $.ymin()+1.5*th, $.xmax()-$.col2, $.ymin()+3*th)) 
      $.text("SELECTION  mode",xy($.xmax()-$.col1, $.ymin()+4*th, $.xmax()-10*tw, $.ymin()+5*th))

      $.rectangle(xy($.xmax()-10*tw, $.ymin()+5.5*th, $.xmax(), $.ymin()+7*th))      
      $.rectangle(xy($.xmax()-$.col1+.5*tw, $.ymax()-7.25*th, $.xmax()-$.col2+3.5*tw, $.ymax()-3.25*th))      

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

       $.bsel.resize(xy($.xmax()-10*tw, $.ymin()+3.5*th, $.xmax(), $.ymin()+5.5*th))
       $.befface.resize(xy($.xmax()-9.5*tw, $.ymin()+5.75*th, $.xmax()-0.5*tw, $.ymin()+6.75*th))
       $.bform.resize(xy($.xmax()-$.col1, $.ymin()+5.5*th, $.xmax()-10*tw, $.ymin()+7*th))

       $.tmobut.resize(xy($.xmax()-$.col2, $.ymin()+7*th, $.xmax(), $.ymin()+8.5*th))
       $.btrans.resize(xy($.xmax()-$.col1, $.ymin()+7*th, $.xmax()-$.col2, $.ymin()+8.5*th))

       $.btog0.resize(xy($.xmax()-$.col1+10.25*tw, $.ymax()-7*th, $.xmax()-11.5*tw, $.ymax()-5.75*th))
       $.btog1.resize(xy($.xmax()-$.col1+10.25*tw, $.ymax()-5.75*th, $.xmax()-11.5*tw, $.ymax()-4.5*th))
       $.btog2.resize(xy($.xmax()-$.col1+10.25*tw, $.ymax()-4.5*th, $.xmax()-11.5*tw, $.ymax()-3.25*th))

    invisible = xy($.xmin()+5, $.ymin()+5, $.xmin()+5, $.ymin()+5)
    if ($.togmode == 0)
    {
       $.bact.resize(xy($.xmax()-$.col1, $.ymax()-10.5*th, $.xmax()-$.col1+10*tw, $.ymax()-9*th))
       $.binact.resize(xy($.xmax()-$.col1, $.ymax()-9*th, $.xmax()-$.col1+10*tw, $.ymax()-7.5*th))

       $.bnew.resize(xy($.xmax()-$.col1+10*tw, $.ymax()-9*th, $.xmax()-10*tw, $.ymax()-7.5*th))
       $.baddsc.resize(xy($.xmax()-10*tw, $.ymax()-10.5*th, $.xmax(), $.ymax()-9*th))
       $.bread.resize(xy($.xmax()-10*tw, $.ymax()-9*th, $.xmax(), $.ymax()-7.5*th))
       $.bwrite.resize(xy($.xmax()-10*tw, $.ymax()-7.5*th, $.xmax(), $.ymax()-6*th))

       $.bprogo.resize(invisible)
       $.bsnarf.resize(invisible)
       $.bhear.resize(invisible)
       $.bredo.resize(invisible)
       $.bkill.resize(invisible)
       $.blignes.resize(invisible)
       $.bproj.resize(invisible)
       $.baction.resize(invisible)
       $.bexport.resize(invisible)

       $.blis1.resize(invisible)
       $.bf1.resize(invisible)
       $.bPAC.resize(invisible) 
       $.blis2.resize(invisible)
       $.bf2.resize(invisible)
       $.bfonc.resize(invisible) 
       $.bch.resize(invisible)
       $.binfos.resize(invisible)   
    }
    else if ($.togmode == 1)
    {
       $.bprogo.resize(xy($.xmax()-$.col1, $.ymax()-10.5*th, $.xmax()-$.col2, $.ymax()-9*th))
       $.baction.resize(xy($.xmax()-$.col1, $.ymax()-9*th, $.xmax()-$.col1+3*tw, $.ymax()-7.5*th))
       $.bexport.resize(xy($.xmax()-$.col1+3*tw, $.ymax()-9*th, $.xmax()-$.col2, $.ymax()-7.5*th))
       $.blignes.resize(xy($.xmax()-$.col2, $.ymax()-9*th, $.xmax(), $.ymax()-7.5*th))
       $.bproj.resize(xy($.xmax()-$.col2, $.ymax()-10.5*th, $.xmax(), $.ymax()-9*th))
       $.bhear.resize(xy($.xmax()-10*tw, $.ymax()-7.5*th, $.xmax()-4.5*tw, $.ymax()-6*th))
       $.bredo.resize(xy($.xmax()-4.5*tw, $.ymax()-7.5*th, $.xmax(), $.ymax()-6*th))
       $.bsnarf.resize(xy($.xmax()-10*tw, $.ymax()-6*th, $.xmax()-4.5*tw, $.ymax()-4.5*th))
       $.bkill.resize(xy($.xmax()-4.5*tw, $.ymax()-6*th, $.xmax(), $.ymax()-4.5*th))

       $.bact.resize(invisible)
       $.binact.resize(invisible)
       $.bnew.resize(invisible)
       $.baddsc.resize(invisible)
       $.bread.resize(invisible)
       $.bwrite.resize(invisible)

       $.blis1.resize(invisible)
       $.bf1.resize(invisible)
       $.bPAC.resize(invisible)
       $.blis2.resize(invisible)
       $.bf2.resize(invisible)
       $.bfonc.resize(invisible)
       $.bch.resize(invisible)
       $.binfos.resize(invisible)   
    }
    else if ($.togmode == 2)
    {
       $.blis1.resize(xy($.xmax()-$.col1, $.ymax()-10.5*th, $.xmax()-8*tw, $.ymax()-9*th))
       $.bf1.resize(xy($.xmax()-8*tw, $.ymax()-10.5*th, $.xmax()-4*tw, $.ymax()-9*th))
       $.bPAC.resize(xy($.xmax()-4*tw, $.ymax()-10.5*th, $.xmax(), $.ymax()-9*th))
 
       $.blis2.resize(xy($.xmax()-$.col1, $.ymax()-9*th, $.xmax()-8*tw, $.ymax()-7.5*th))
       $.bf2.resize(xy($.xmax()-8*tw, $.ymax()-9*th, $.xmax()-4*tw, $.ymax()-7.5*th))
       $.bfonc.resize(xy($.xmax()-4*tw, $.ymax()-9*th, $.xmax(), $.ymax()-7.5*th))
 
       $.bch.resize(xy($.xmax()-8*tw, $.ymax()-7.5*th, $.xmax(), $.ymax()-6*th))
       $.binfos.resize(xy($.xmax()-8*tw, $.ymax()-6*th, $.xmax(), $.ymax()-4.5*th))   

       $.bprogo.resize(invisible)
       $.baction.resize(invisible)
       $.bexport.resize(invisible)
       $.blignes.resize(invisible)
       $.bproj.resize(invisible)
       $.bhear.resize(invisible)
       $.bredo.resize(invisible)
       $.bsnarf.resize(invisible)
       $.bkill.resize(invisible)

       $.bact.resize(invisible)
       $.binact.resize(invisible)
       $.bnew.resize(invisible)
       $.baddsc.resize(invisible)
       $.bread.resize(invisible)
       $.bwrite.resize(invisible)
    }

       $.btaille.resize(xy($.xmax()-10*tw, $.ymax()-1.5*th, $.xmax()-5*tw, $.ymax()))
       $.bsnap.resize(xy($.xmax()-5*tw, $.ymax()-1.5*th, $.xmax(), $.ymax()))
       $.bpc.resize(xy($.xmax()-10*tw, $.ymax()-4.5*th, $.xmax(), $.ymax()-3*th))
       $.bredraw.resize(xy($.xmax()-$.col1+tw, $.ymax()-7*th, $.xmax()-$.col2+3*tw, $.ymax()-5*th))
       $.bundo.resize(xy($.xmax()-$.col1+4.5*tw, $.ymax()-5*th, $.xmax()-$.col2+3*tw, $.ymax()-3.5*th))
       $.bpourundo.resize(xy($.xmax()-$.col1+tw, $.ymax()-5*th, $.xmax()-$.col1+4.5*tw, $.ymax()-3.5*th))
       $.bzin.resize(xy($.xmax()-$.col1, $.ymax()-3*th, $.xmax()-$.col1+10*tw, $.ymax()-1.5*th))
       $.bzout.resize(xy($.xmax()-$.col1, $.ymax()-1.5*th, $.xmax()-$.col1+10*tw, $.ymax()))
       $.bzauto.resize(xy($.xmax()-$.col1+10*tw, $.ymax()-3*th, $.xmax()-10*tw, $.ymax()))
       $.bgrid.resize(xy($.xmax()-10*tw, $.ymax()-3*th, $.xmax()-5*tw, $.ymax()-1.5*th))
       $.bseg.resize(xy($.xmax()-5*tw, $.ymax()-3*th, $.xmax(), $.ymax()-1.5*th))
       
}

method toggle(t) {
       $.togmode = t
       $.resize()
       $.redraw()
       $.f.redraw()
}

###########  Méthodes pour les boutons: gestion des Ev


method loadev() {

	fname = browsefiles("Ev File (*.ev)","*.ev",1)
	if ( fname == "" ) {
		print(GMblah_GUI52)
		return()
	}
	if ( ! fileisreadable(fname) ) {
		print(GMblah_GUI57,fname,GMblah_GUI58)
		return()
	}
	else 
	{
	     fm = split(fname,"\\/")
	     nm = sizeof(fm)
	     nom = split(fm[nm-1],".")
	     if (nom[1] == "ev")
	     {
	        $.prepare_undo(GMblah_UNDO1) 

	        dir = ""
		for (n=0; n<nm-1; n++) dir = dir+fm[n]+"/"
		LoadEv(nom[0],dir)
	     }
	}
	$.zoomauto()
        Root.redraw()
}

method writeev() {
	fname = browsefiles("Ev File (*.ev)","*.ev",1)
	if ( fname == "" ) {
		print(GMblah_GUI52)
		return([0=0])
	}
	fm = split(fname,"\\/")
	nm = sizeof(fm)
	nom = split(fm[nm-1],".")[0]
        dir = ""
	for (n=0; n<nm-1; n++) dir = dir+fm[n]+"/"
	WriteEv(nom,dir)
        Root.redraw()

	return ([0=nom,1=dir])	# (pour dump)
}

method newev() {
       
        confirm = getastr(GMblah_GUI1,"n")
	if ((confirm == "o") || (confirm == "y"))
	{
		Ev = [0=0]
		for (ch = 1; ch <= NbCan; ch++) 
		    Ev[ch]=[0=0, "PAC"='']

		AcVar=[]
		Root.redraw()
        }
}

method addsc() {
       noms = getastr(GMblah_GUI2,"")
       if ((noms != ""))
       {
	  $.prepare_undo(GMblah_UNDO2) 
          eval("T__ = defined("+noms+")")
	  if (T__)
	     eval("PlusScene("+noms+")")
	  else
	     print (noms+GMblah_GUI0)
	  
	  $.redraw()
       }
}

method evact() {
       test = getastr(GMblah_GUI53,"")
       if (test != "") 
       {
	   if (substr(test,1,1) == "µ")	# zones
	   {		
		nz = integer(split(test,"µ")[0])	
		$.f.activezone(nz)
	   }   
	   else
	   {
		$.prepare_undo(GMblah_UNDO3) 
		ActiveTest(test)
           }
         $.redraw()
       }	  
}

method evinact() {
       test = getastr(GMblah_GUI3,"")
       if (test != "") 
       { 
	   if (substr(test,1,1) == "µ")	# zones
	   {		
		nz = integer(split(test,"µ")[0])
		$.f.desactivezone(nz)
	   }   
	   else
	   {
		$.prepare_undo(GMblah_UNDO3) 
		DesactiveTest(test)
           }
         $.redraw()
       }	  
}



###########  Méthodes pour les boutons: gestion des sélections


method formule() {
       formule = getastr(GMblah_GUI4,"")
       if (formule != "")
       {
          $.prepare_undo(GMblah_UNDO5) 
          KKSS(formule)
	  $.f.formule_points(formule)
       }
       $.redraw()
}

method settmode(v) {
       $.tmode = v
}
method transfertsel() {
       if ($.tmode == 0)
	  $.f.seltopiste()
       else if ($.tmode == 1)
          $.seltoscene()
       else if ($.tmode == 2) 
	  $.f.selptoev()
       else if ($.tmode == 3) 
	  $.f.selevtop()
}
method seltoscene() {
       noms = getastr(GMblah_GUI2,"")
       if ((noms != ""))
       {
          eval("T__ = defined("+noms+")")
	  if (T__)				# la scene existe déjà
             eval("G__="+noms)       
	  else					# nouvelle scene
	     G__ = CreScen()
     
	  for (ch=1; ch <= NbCan; ch++) if (Ev[ch][0] > 0)
          {
	     nch = G__[ch][0]              
	     for (n= 1; n <= Ev[ch][0]; n++) if (Ev[ch][n]["s"] == 1)
	     {
		nch += 1
		G__[ch][nch] = ArCopy(Ev[ch][n])	
		G__[ch][nch]["s"] = 0       
	     }

	   G__[ch][0] = nch
           }
           eval(noms+"=G__")   
       }   
}


method efface() {
    confirm = getastr(GMblah_GUI5,"n")
    if ((confirm == "o") || (confirm == "y"))
    {
       $.prepare_undo(GMblah_UNDO6) 
       nEv = []
       for (ch=1; ch <= NbCan; ch++)
       {
           nEv[ch]= ["PAC"= Ev[ch]["PAC"]]                
	   nn = 0

	   if (Ev[ch][0] > 0)
	   for (n= 1; n <= Ev[ch][0]; n++)
	   {
	       if (Ev[ch][n]["s"] != 1)
	       {
			nn += 1
			nEv[ch][nn] = Ev[ch][n]	       
	       }
           }
	   nEv[ch][0] = nn

       }
       Ev = nEv
       $.redraw()
    }
}

###########  Méthodes pour les boutons: projections

method setproj(n) {
       $.projecteur = n
}

method projection() {

     if ((n = $.projecteur)>0)
     {       
       listarg = "--"+$.projinfos[n]["nom"]+"-- Arguments: "
       listtypes = "----> Arguments types: "
       for (i=1; i<= $.projinfos[n][0]; i++) 
       {   
	   listarg += $.projinfos[n][i]["d"]+", "
	   listtypes += $.projinfos[n][i]["t"]+", "
       }
       listarg += GMblah_GUI54
       listtypes += GMblah_GUI54b
       print(listarg)
       print(listtypes)

       arglist = getastr("Args > ","")

       if (arglist != "")
       {
	 arglist = $.ligne_comme_arg(arglist)		# voir plus bas (gestion des £)
	 isitok = RemVAR(arglist)	# garder mémoire des variables globales utilisées

         command = $.projinfos[n]["nom"]+"("+arglist+")"
         nl = ($.lstock[0] += 1)

	 if (isitok == "")
	 {
	   print(GMblah_GUI70+command+"...")
           eval("T__ = "+command)
	   print("...ok")
	   T__["tempo"] = temponote(tempo())
	   RL[nl] = $.lstock[nl] = T__
	 }
	 else 
	 {
	   RL[nl] = ["ph"='']
	   print(GMblah_GUI75+isitok)
	 }

	 $.licoms[nl] = command
	 $.lignes[nl] = string(nl)+": "+command
	 $.blignes.set($.currlin = nl)	# mise à jour du kvalbutton
	 $.redraw()
       }
     }
}
method ligne_comme_arg(arglist)    # gestion des £ dans $.projection()
				   # £12c   renvoie le cerle du "rac" de RL[12] s'il y a
				   # £12a	    le point A du "rac" (£12b pour B)
				   # £12d	    le temps de début RL[12][0] (£12f pour [1])
				   # £12i5c         le cercle du "inter" numéro 5
				   # £12    renvoie RL[12] (utile pour $.f.affichepoints)
{
	 while (1 in CoupeStr(arglist,"£")) 
	 {
		raccourci = split(CoupeStr(arglist,"£")[1],",.[]()+/*-")[0]
		suf = substr(raccourci,sizeof(raccourci),1)		# "a","b","d","f" ou "c"
		if ((suf == "a")||(suf == "b")||(suf == "d")||(suf == "f")||(suf == "c")||(suf == "s")) 
		   racc = split(raccourci, suf)[0]
		else 
		{
		   racc = raccourci
		   champs = ""	
		   suf = ""
		}

		if (suf == "c")			# cercle
		   champs = "[CERs]"
		else if (suf == "b")		# B
		   champs = "[PBs]"
		else if (suf == "a")		# A
		   champs = "[PAs]"
		else if (suf == "d")		# 0
		   champs = "[0]"
		else if (suf == "f")		# 1
		   champs = "[1]"
	
		gvarname = split(racc,"£")[0]+suf	# voir plus bas

		if (suf == "s")			# encore plus spécial : segment A-B
		{
		     csi = CoupeStr(racc,"i")
		     evrac = ""
		     if (1 in csi) racc = csi[0] + "iINTERs" + csi[1] 
		     else if (suf != "" && suf!= "d" && suf != "f") evrac = "[RACs]"

		     racine = "RL["+RemplaceInStr(split(racc,"£")[0],"i","][")+"]" 
		     rep1 = racine + evrac + "[PAs]"
		     rep2 = racine + evrac + "[PBs]"
		     rep = rep1 + "-" + rep2
		}
		else
		{
		     csi = CoupeStr(racc,"i")
		     if (1 in csi) racc = csi[0] + "iINTERs" + csi[1] 
		     else if (suf != "" && suf!= "d" && suf != "f") champs = "[RACs]"+champs

		     rep = "RL["+RemplaceInStr(split(racc,"£")[0],"i","][")+"]" + champs
		}

		print(raccourci+GMblah_GUI79+rep )		# info console

		# création d'une nouvelle variable globale S_,C_,P_ ou I_
		nonono = 0
		if (suf == "s") gvarname = "S_"+gvarname
		else if ((suf == "a")||(suf=="b")) gvarname = "P_"+gvarname
		else if (suf == "c") gvarname = "C_"+gvarname
		else if ((suf == "d")||(suf=="f")) gvarname = "I_"+gvarname
		else nonono = 1
		if (!nonono) 
		{
		        if (suf == "s")
			        eval(gvarname+"=Seg("+rep1+","+rep2+")")
			else
				eval(gvarname+"="+rep)
			arglist = RemplaceInStr(arglist, raccourci, gvarname)
			print(raccourci+GMblah_GUI80+gvarname)
		}
		else arglist = RemplaceInStr(arglist, raccourci, rep)		
	 }
        arglist = RemplaceInStr(arglist,"RL[]","£")
	return (arglist)
}

method infoligne(n) {
       $.currlin = n
}

method hearligne() {
   if ($.currlin > 0) 
      if ($.realid == 0)
      {
	 $.realid = realmidi(Init16()+$.lstock[$.currlin]["ph"], Now+2b)
	 $.resetrl = task $.reset_realid($.lstock[$.currlin][1]-$.lstock[$.currlin][0]+5)
      }
      else 
      {
	kill($.realid)
	kill($.resetrl)
	$.realid = 0
      }
}
method reset_realid(l) {
       sleeptill(Now+l)
       $.realid = 0
}

method redoligne() {
   if ($.currlin > 0)
	  {
	     print(GMblah_GUI71+string($.currlin))
	     debarglist = sizeof(split($.lignes[$.currlin],"()")[0])+2
	     larglist = sizeof($.lignes[$.currlin])-debarglist
	     isitok = RemVAR(substr($.lignes[$.currlin],debarglist,larglist))	
	     if (isitok == "")
	     {
		eval("T__ = "+split($.lignes[$.currlin],":")[1])
		RL[$.currlin] = $.lstock[$.currlin] = T__
		print("...ok")
             }
	     else print(GMblah_GUI75+isitok) 
	  }
}

method snarfligne() {
   if ($.currlin > 0)
	     Snarf = $.lstock[$.currlin]["ph"]
}

method killligne(n) {

   if ($.currlin > 0)
   {
      confirm = getastr(GMblah_GUI59+string($.currlin)+" ? > ","n")
      if ((confirm == "y") || (confirm == "o"))
	  {
             # $.prepare_undo(GMblah_UNDO7)     # si utile, ajouter $.lstock & Co au redo 
	     $.outligne($.currlin)
	     $.currlin -= 1
	     $.blignes.set($.currlin)
	     $.redraw()
	  }  
  }
  else if ($.lstock[0] > 0)	# à partir de la ligne (snarf)
  {
      confirm = getastr(GMblah_GUI72,"")
      if (confirm != "")
      {
        if (confirm == "--") {n1 = 1; n2 = $.lstock[0] }
	else
	{
		n1 = integer(split(confirm, "-")[0])
		n2 = integer(split(confirm, "-")[1])
	}
	for (n=n2; n>=n1; n--) $.outligne(n)
	$.redraw()
      }
  }

}
method outligne(n) {
	     $.lstock = SupprimeIndex(n, $.lstock)
	     $.licoms = SupprimeIndex(n, $.licoms) 
	     $.lignes = SupprimeIndex(n, $.lignes) 
	     $.lstock[0] -= 1

	     if ($.lstock[0] > 0)
	     {
		for (i=1; i<=$.lstock[0]; i++)
		    $.lignes[i] = string(i)+": "+$.licoms[i]
	     }

	     $.blignes.setvals($.lignes)
}

method lignexport() {

   if ($.lstock[0] > 0)
   {
	nom = getastr(GMblah_GUI6,"")
	if (nom == "")
	{
	   nom = getastr(GMblah_GUI7,"")
	   if (nom != "")
	   {
	        T__ = []
		for (i=1; i<=$.lstock[0]; i++) T__[i] = $.lstock[i]["ph"]
		eval (nom+"= T__")
	   }
	   else 
	   {
		nom = getastr(GMblah_GUI8,"")
		if (nom != "")
		{
			nom = nom+".mid"
			for (i=1; i<=$.lstock[0]; i++) ExMIDI($.lstock[i],RacineN(nom, MDOP))
		}
	   }
	}
	else
	{
	   T__ = $.lstock
	   eval(nom+"= T__")
	}
   }
   else print(GMblah_GUI9)
}


method onelignexport() {

   if ($.currlin == 0)
   {
	nom = getastr(GMblah_GUI10,"")
	if (nom != "")
	   eval(nom+"= Snarf")
   }
   else
   {
	num = string($.currlin)
	nom = getastr("LIGNE "+num+GMblah_GUI11,"")
	if (nom == "")
	{
	   nom = getastr("PHRASE "+num+GMblah_GUI12,"")
	   if (nom != "")
	   {
	        T__ = $.lstock[$.currlin]["ph"]
		eval (nom+"= T__")
	   }
	   else 
	   {
		nom = getastr(GMblah_GUI13,"")
		if (nom != "")
		{
			nom = nom+".mid"
			ExMIDI($.lstock[$.currlin],RacineN(nom, MDOP))
		}
	   }
	}
	else
	{
	   T__ = $.lstock[$.currlin]
	   eval(nom+"= T__")
	}
   }
}

###########  Méthodes pour les boutons: PACs et fonctions de distortion

method definePAC() {
       newp = getastr(GMblah_GUI55+string($.currch)+" > ","")
       if (newp != "")
       {
          $.prepare_undo(GMblah_UNDO8) 
	  eval("T__ ="+newp)
	  if (typeof(T__) == "phrase") Ev[$.currch]["PAC"] = T__
	  else if (typeof(T__) == "string") eval("Ev["+string($.currch)+"][PACs] ="+T__)
	  else print("no comprendo")
       }
}

method setPAC() {
   confirm = getastr(GMblah_GUI14+string($.currch)+GMblah_GUI15,"n")
   if ((confirm == "y") || (confirm == "o"))
   {
     $.prepare_undo(GMblah_UNDO9) 
     if (ACPATCHES) 
       Ev[$.currch]["PAC"] = PourAC(ACPat[$.currPAC+1]["lsb"],ACPat[$.currPAC+1]["pat"], $.currch)
     else 
       Ev[$.currch]["PAC"] = progchange($.currPAC+1, $.currch)
   }
}

method setcurPAC(n) {
       $.currPAC = n
}

method setcurfonc(n) {
       $.currfonc = n
}

method setfonc(n) {
       $.currf = n
}

method menutof() {
         $.prepare_undo(GMblah_UNDO10) 
         ch = $.currch
	 cf = $.fonclist[$.currfonc]
	 cff = $.currf
	 if (cf == "Vol")
	    Volume[ch] = $.distort_liste[cff]
	 else if (cf == "Pit")
	    Pit[ch] = $.distort_liste[cff]
	 else if (cf == "Dur")
	    Dur[ch] = $.distort_liste[cff]
	 else if (cf == "Pan")
	    Pan[ch] = $.distort_liste[cff]
	 if (cff in $.distort_parameters) 
	    print ("Param. ("+$.distort_liste[cff]+"): "+$.distort_parameters[cff])
}

method setch(n) {
       $.currch = n+1
}
method getcurrch() {
       return ($.currch)
}

method showsettings() {
       ch = $.currch
       print(GMblah_GUI16+string(ch)+":")
       
       pmap = patchmap()
       pac = Ev[ch]["PAC"]
       pacid = ""
       if (ch <= 16) for (i=0; i<=sizeof(pmap)-1; i++) 
	   if ((ACPATCHES) && (PourAC(ACPat[i+1]["lsb"],ACPat[i+1]["pat"], $.currch) == pac))
	      pacid = pmap[i]["name"]
	   else if ((ACPATCHES == 0) && progchange($.currPAC+1, $.currch) == pac)
	      pacid = pmap[i]["name"]
       if (pacid == "") pacid = "?"

       print("PAC: "+string(Ev[ch]["PAC"])+" ("+pacid+")")
       print("Vol: "+string(Volume[ch]))	
       print("Pit: "+string(Pit[ch]))		
       print("Dur: "+string(Dur[ch]))		
       print("Pan: "+string(Pan[ch]))		
}

###########  Méthodes pour les boutons: ... autres

method setmousemode(v, n) {
       $.f.setmousemode(n, v)
}
method setselmode(v) {
       $.f.setselmode(v)
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


method affichepoints(){
	$.f.affichepoints()
}

method anneau_snap {
       $.f.bougesnap()
}
method anneau_grid {
       $.f.bougegrid()
}
method anneau_seg {
       $.f.bougeseg()
}
method anneau_symboles {
       $.f.bougesymboles()
}


# fin class wev
}


########################################################################################

########################################################################################

########################################################################################

class wfen {

method init(bornes) {

       $.w = new window()
       $.inherit($.w)

       #### OPTIONS:
       $.taille_symboles = 4	# "rayon" maximum
       $.stick = 4		# "rayon" d'action pour le snap
	
       $.snap2grid = 0		# flag
       ####

       if (nargs() == 0) 
	  bornes = $.autobornes()

       $.bornes = bornes	# xy()

       $.plotmode = []
       $.plotmode[-1] = -1	# pour points sélectionnés
       $.plotmode[-2] = -2	# pour centre de cercle
       for (ch = 1; ch <= NbCan; ch++)	$.plotmode[ch] = ch

       $.grid = 0	      
       $.showprojections = 0

       $.lpoints = [0=0]
       $.lcercles = [0=0]       
       $.lsegs = [0=0]

       $.lzones = []


       # mode d'utilisation de la souris:

       $.Zonage_infos = 0
       $.Recadrage = 1
       $.MoveAround = 2
       $.DefPoint = 3
       $.NewEvent = 4
       $.ZSelection = 5
       $.DepSel = 6
       $.SModif = 7
       $.SCopy = 8
       $.Ph2Seg = 9
       $.Ph2Cer = 10
       $.DefZone = 12
       $.HearSeg = 11
       $.mouse_mode = [0= $.Zonage_infos, 1= $.Zonage_infos, 2= $.NewEvent]   # (défaut éventuel)

       Sremplace = 0
       Sadd = 1
       Sminus = 2
       $.selection_mode = Sremplace 

       $.ignoreup = 0
       $.zone = 0
       $.drag_en_cours = 0
}

method parentGUI(o) {
       $.GUI = o
}

method dump()
{
	st = []

        st["bornes"] = $.bornes
        st["plotmode"] = $.plotmode 
        st["symb"] = $.taille_symboles 
        st["grid"] = $.grid 
        st["projmode"] = $.showprojections 

        st["points"] = ArCopy($.lpoints)
        st["cercles"] = ArCopy($.lcercles)        
        st["segs"] = ArCopy($.lsegs) 

        st["zones"] = ArCopy($.lzones) 

	return(st)
}

method restore(st)
{
       $.bornes = st["bornes"]
       $.plotmode = st["plotmode"]
       $.taille_symboles = st["symb"]
       $.grid = st["grid"]
       $.showprojections = st["projmode"]

       $.lzones = ArCopy(st["zones"])

       $.lpoints = ArCopy(st["points"])
       $.lcercles = ArCopy(st["cercles"])      
       $.lsegs = ArCopy(st["segs"])

       $.ReDefine_lvariables($.lpoints)
       $.ReDefine_lvariables($.lcercles)
       $.ReDefine_lvariables($.lsegs)
}
method ReDefine_lvariables(liste) {
       if (liste[0]) for (i=1; i<=liste[0]; i++)
       {
	  ind = split(liste[i]["nom"],"[")		#]
	  if (sizeof(ind) > 1)			# ici la variable est un élément de tableau
	     $.defineAsArray("",string(liste[i]["nom"]))	#  ... pas rigoureux mais efficace
	  eval(liste[i]["nom"]+"="+string(liste[i]))
       }
}


method redraw(bornes) {

       $.w.redraw()
       colormix(5,0,0,65000)
       colormix(6,0,50000,20000)
       colormix(7,0,65000,0)
       colormix(8,30000,0,0)
       $.colorcycle(0)

       if (nargs()==1) $.bornes = bornes

       xmin = $.bornes["x0"]
       xmax = $.bornes["x1"]
       ymin = $.bornes["y0"]
       ymax = $.bornes["y1"]

       if ($.grid >= 1)
       {
           color(5)
	   $.line(xy($.xecran(0),$.ymin()+1,$.xecran(0),$.ymax()-1))
	   $.line(xy($.xmin()+1,$.yecran(0),$.xmax()-1,$.yecran(0)))
	   color(1)
       }
       if ($.grid >= 2)
       {
	   color(6)
           for (n = Arrondi(xmin); n <= Arrondi(xmax); n++) if (n != 0)
	       $.line(xy($.xecran(n),$.ymin()+1,$.xecran(n),$.ymax()-1))
           for (n = Arrondi(ymin); n <= Arrondi(ymax); n++) if (n != 0)
	       $.line(xy($.xmin()+1,$.yecran(n),$.xmax()-1,$.yecran(n)))
	   color(1)
       }
       if ($.grid >= 3)
       {
	   color(7)
           for (n = 0.1*Arrondi(10*xmin); n <= 0.1*Arrondi(10*xmax); n += 0.1) 
	       if (! EnvironEgal(n, Arrondi(n)))
		  $.line(xy($.xecran(n),$.ymin()+1,$.xecran(n),$.ymax()-1))
           for (n = 0.1*Arrondi(10*ymin); n <= 0.1*Arrondi(10*ymax); n += 0.1) 
	       if (! EnvironEgal(n, Arrondi(n)))
		  $.line(xy($.xmin()+1,$.yecran(n),$.xmax()-1,$.yecran(n)))
	   color(1)
       }

       for (ch = 1; ch <= NbCan; ch++) if (Ev[ch][0] > 0)
	   for (n = 1; n <= Ev[ch][0]; n++)
	   {
		x = Ev[ch][n]["x"]
		y = Ev[ch][n]["y"]

		if (Ev[ch][n]["actif"] == 1)
		if ((x<=xmax)&&(x>=xmin)&& (y<=ymax)&&(y>=ymin))
		{
		   if (Ev[ch][n]["s"] == 1)	# événement dans sélection
		      color(2)

		   xp = $.xmin() + ($.xmax()-$.xmin())*(x-xmin)/float(xmax-xmin) 
		   yp = $.ymax() - ($.ymax()-$.ymin())*(y-ymin)/float(ymax-ymin) 
		   $.plotev(ch,xp,yp)

		   color(1)
		}   
	   }
	
       color(5)  
       if ($.lpoints[0])
	   for (n = 1; n <= $.lpoints[0]; n++) if ($.lpoints[n]["s"] == 1)
	       {
	       color(2)
	       $.plotev(-1, $.xecran($.lpoints[n]["x"]), $.yecran($.lpoints[n]["y"]))	        
	       color(5)
	       }
	     else
	       $.plotev(0, $.xecran($.lpoints[n]["x"]), $.yecran($.lpoints[n]["y"]))

       color(5)  
       if ($.lsegs[0])
	   for (n = 1; n <= $.lsegs[0]; n++)
	   {
	       $.line(xy($.xecran($.lsegs[n]["x0"]),$.yecran($.lsegs[n]["y0"]),$.xecran($.lsegs[n]["x1"]),$.yecran($.lsegs[n]["y1"])))
	       if ($.showprojections != 0)
	       {
	       	       if ($.showprojections == 2) color($.colorcycle()) else color(2)
		       $.showProjSeg($.lsegs[n])
		       color(5)
	       }
	   }
	       	       
       color(5)
       if ($.lcercles[0])
	 for (n = 1; n <= $.lcercles[0]; n++) 
	 {
	   if ($.lcercles[n]["s"] == 1)
	   {
	       color(2)
	       x = $.xecran($.lcercles[n]["c"]["x"])
	       y = $.yecran($.lcercles[n]["c"]["y"])
	       $.plotev(-2, x, y)	
	       r = $.lcercles[n]["r"]*($.xmax()-$.xmin())/float($.bornes["x1"]-$.bornes["x0"])
	       $.cercle(x,y,r)
	       color(5)
	   }
	   else
	   {
	       x = $.xecran($.lcercles[n]["c"]["x"])
	       y = $.yecran($.lcercles[n]["c"]["y"])
	       $.plotev(-2, x, y)	
	       r = $.lcercles[n]["r"]*($.xmax()-$.xmin())/float($.bornes["x1"]-$.bornes["x0"])
	       $.cercle(x,y,r)
	   }
	   if ($.showprojections != 0)
	   {
	       if ($.showprojections == 2) color($.colorcycle()) else color(2)
	       $.showProjCer($.lcercles[n])
	       color(5)
	   }
	 }
       color(1)

       color(8)
       if (sizeof($.lzones) > 0)
	   for (n in $.lzones) if ($.lzones[n]["vis"] == 1)
	   {
	       xa = $.xecran($.lzones[n]["A"]["x"])
	       ya = $.yecran($.lzones[n]["A"]["y"])
	       xb = $.xecran($.lzones[n]["B"]["x"])
	       yb = $.yecran($.lzones[n]["B"]["y"])
	       $.rectangle(xy(xa,ya,xb,yb))
	       $.plotev(-10, xa, ya)	
	   }
       color(1)
}
method colorcycle(init) {
       if (nargs() == 0) 
	  $.colorcy +=1 
       else
       { 
          for (ic = 10; ic< 20; ic++) colormix(ic, 2500*(30-ic), 3500*(24-ic),3500*(ic-8))
          $.colorcy = 10
       }
       if ($.colorcy >= 20) {$.colorcy = 10}
       return(Minimum($.colorcy,19))
}
method showProjSeg(segm) 
{
    xd = segm["x0"]
    yd = segm["y0"]
    xf = segm["x1"]
    yf = segm["y1"]

    if (xd == xf) 				# cas: segment vertical
      testin = Tinvertical
    else if (yd == yf)				# cas: segment horizontal
      testin = Tinhorizontal
    else testin = Tinqcq

    if ($.showprojections == 3) $.colorcycle(0)

    for(ch = 1; ch<=NbCan; ch++) if (Ev[ch][0] > 0)
	for (ne=1 ; ne<=Ev[ch][0] ; ne++)			
	  if (Ev[ch][ne]["actif"])			# filtrage des événements actifs
	  {
	     if (($.showprojections != 3) || (Ev[ch][ne]["s"] == 1))
	     {
	        if ($.showprojections == 3) color($.colorcycle()) 	        

		x = Ev[ch][ne]["x"]
		y = Ev[ch][ne]["y"]		
		pro = testin(x,y,xd,yd,xf,yf)
		p = pro["p"]

		if ((p>=0) && (p<=1))		# Ev dans zone d'écoute ?
		  $.line(xy($.xecran(x),$.yecran(y),$.xecran(pro["x"]),$.yecran(pro["y"])))
	     }
          }
	  color(1)
}
method showProjCer(cercle) {

    xc = cercle["c"]["x"]
    yc = cercle["c"]["y"]
    rc = cercle["r"]

    if ($.showprojections == 3) $.colorcycle(0)

    for(ch = 1; ch<=NbCan; ch++) if (Ev[ch][0] > 0)
	for (ne=1 ; ne<=Ev[ch][0] ; ne++) if (Ev[ch][ne]["actif"])			
	{
	  if (($.showprojections != 3) || (Ev[ch][ne]["s"] == 1))
	  {
	      if ($.showprojections == 3) color($.colorcycle()) 	

	      x = Ev[ch][ne]["x"]
	      y = Ev[ch][ne]["y"]
	      polaire = Getpolar(x-xc,y-yc)		# pos. angulaire (/centre)	

	      if (polaire["r"] > 0)
	      {
		thetan = polaire["theta"]		
		circonf = Setpolar(rc,thetan)
		xcc = circonf["x"]+xc
		ycc = circonf["y"]+yc

		$.line(xy($.xecran(x),$.yecran(y),$.xecran(xcc),$.yecran(ycc)))
              }
	  }		        
	}
}


method xecran(xev) {
 return ($.xmin()+($.xmax()-$.xmin())*(xev-$.bornes["x0"])/float($.bornes["x1"]-$.bornes["x0"]))
}
method yecran(yev) {
 return ($.ymax()-($.ymax()-$.ymin())*(yev-$.bornes["y0"])/float($.bornes["y1"]-$.bornes["y0"]))
}
method xgeo(xec, mode_arrondi) {
 exact = $.bornes["x0"]+($.bornes["x1"]-$.bornes["x0"])*(xec-$.xmin())/float($.xmax()-$.xmin())
 if (nargs() == 1) mode_arrondi = 0
 if ((mode_arrondi == 0) || (($.bornes["x1"]-$.bornes["x0"]) < 0.01)) return(exact)
 else if (mode_arrondi) return (0.0001*Arrondi(10000*exact))
}
method ygeo(yec, mode_arrondi) {
 exact = $.bornes["y1"]-($.bornes["y1"]-$.bornes["y0"])*(yec-$.ymin())/float($.ymax()-$.ymin())
 if (nargs() == 1) mode_arrondi = 0
 if ((mode_arrondi == 0) || (($.bornes["x1"]-$.bornes["x0"]) < 0.01)) return(exact)
 else if (mode_arrondi) return (0.0001*Arrondi(10000*exact))
}
method autobornes(rep) {      # si (rep==1) conserve les rapports actuels (pour zoomauto)
	  x0 = y0 = 0
	  x1 = y1 = 0
	  for (ch = 1; ch <= NbCan; ch++) 
	  {
	    if (Ev[ch][0] > 0)
	    {
	      for (n=1; n <= Ev[ch][0]; n++) if (Ev[ch][n]["actif"] == 1)
	      {
		x0 = Minimum(x0, Ev[ch][n]["x"])
		x1 = Maximum(x1, Ev[ch][n]["x"])
		y0 = Minimum(y0, Ev[ch][n]["y"])
		y1 = Maximum(y1, Ev[ch][n]["y"])
	      }
	    }
	  }  
	  x0 -= 1
	  x1 += 1
	  y0 -= 1
	  y1 += 1

	  if (nargs() == 1)
	  {
		rapx = ($.xmax()-$.xmin())/float(x1-x0)
		rapy = ($.ymax()-$.ymin())/float(y1-y0)	  

		if (rapx < rapy) y1 = y0 + ($.ymax()-$.ymin())/rapx
		else  x1 = x0 + ($.xmax()-$.xmin())/rapy
	  }
		
	  return(xyd(x0, y0, x1, y1))
}

method plotev(ch,x,y) {

       mode = $.plotmode[ch]
       ts = $.taille_symboles

       if (mode == 1)				# croix
	  { $.line(xy(x-ts,y,x+ts,y)) ; $.line(xy(x,y-ts,x,y+ts)) }

       else  if (mode == 2)			# carrés
	  { $.line(xy(x-ts,y-ts,x-ts,y+ts)) ; $.line(xy(x+ts,y-ts,x+ts,y+ts)) 
	    $.line(xy(x-ts,y-ts,x+ts,y-ts)) ; $.line(xy(x-ts,y+ts,x+ts,y+ts)) }
	    
       else  if (mode == 3)			# signes mult.				 
	  { $.line(xy(x-ts,y-ts,x+ts,y+ts)) ; $.line(xy(x+ts,y-ts,x-ts,y+ts)) }
	    
       else  if (mode == 4)			# étoiles
	  { $.line(xy(x-ts,y,x+ts,y)) ; $.line(xy(x,y-ts,x,y+ts)) 
	    $.line(xy(x-ts,y-ts,x+ts,y+ts)) ; $.line(xy(x+ts,y-ts,x-ts,y+ts)) }

       else  if (mode == 5)			# carrés sur la pointe
	  { $.line(xy(x-ts,y,x,y+ts)) ; $.line(xy(x-ts,y,x,y-ts)) 
	    $.line(xy(x+ts,y,x,y-ts)) ; $.line(xy(x+ts,y,x,y+ts)) }

       else  if (mode == 6)			# carrés avec centre
	  { $.line(xy(x-ts,y-ts,x-ts,y+ts)) ; $.line(xy(x+ts,y-ts,x+ts,y+ts)) 
	    $.line(xy(x-ts,y-ts,x+ts,y-ts)) ; $.line(xy(x-ts,y+ts,x+ts,y+ts)) 
	    $.line(xy(x,y,x,y)) }

       else  if (mode == 7)			# carrés sur la pointe avec centre
	  { $.line(xy(x-ts,y,x,y+ts)) ; $.line(xy(x-ts,y,x,y-ts)) 
	    $.line(xy(x+ts,y,x,y-ts)) ; $.line(xy(x+ts,y,x,y+ts)) 
	    $.line(xy(x,y,x,y)) }

       else  if (mode == 8)			# triangles pointe bas
	  { $.line(xy(x-ts,y-ts,x+ts,y-ts)) ; $.line(xy(x-ts,y-ts,x,y+ts)) 
	    $.line(xy(x,y+ts,x+ts,y-ts))  }

       else  if (mode == 9)			# triangles pointe haut
	  { $.line(xy(x-ts,y+ts,x+ts,y+ts)) ; $.line(xy(x-ts,y+ts,x,y-ts)) 
	    $.line(xy(x,y-ts,x+ts,y+ts))  }

       else  if (mode == 10)			# triangles pointe droite
	  { $.line(xy(x-ts,y,x+ts,y+ts)) ; $.line(xy(x-ts,y,x+ts,y-ts)) 
	    $.line(xy(x+ts,y+ts,x+ts,y-ts))  }

       else  if (mode == 11)			# triangles pointe gauche
	  { $.line(xy(x+ts,y,x-ts,y+ts)) ; $.line(xy(x+ts,y,x-ts,y-ts)) 
	    $.line(xy(x-ts,y+ts,x-ts,y-ts))  }

       else  if (mode == 12)			# triangles pointe bas avec centre
	  { $.line(xy(x-ts,y-ts,x+ts,y-ts)) ; $.line(xy(x-ts,y-ts,x,y+ts)) 
	    $.line(xy(x,y+ts,x+ts,y-ts)) ; $.line(xy(x,y-ts,x,y+ts)) }

       else  if (mode == 13)			# triangles pointe haut avec centre
	  { $.line(xy(x-ts,y+ts,x+ts,y+ts)) ; $.line(xy(x-ts,y+ts,x,y-ts)) 
	    $.line(xy(x,y-ts,x+ts,y+ts)) ; $.line(xy(x,y-ts,x,y+ts)) }

       else  if (mode == 14)			# triangles pointe droite avec centre
	  { $.line(xy(x-ts,y,x+ts,y+ts)) ; $.line(xy(x-ts,y,x+ts,y-ts)) 
	    $.line(xy(x+ts,y+ts,x+ts,y-ts)) ; $.line(xy(x-ts,y,x+ts,y)) }

       else  if (mode == 15)			# triangles pointe gauche avec centre
	  { $.line(xy(x+ts,y,x-ts,y+ts)) ; $.line(xy(x+ts,y,x-ts,y-ts)) 
	    $.line(xy(x-ts,y+ts,x-ts,y-ts)) ; $.line(xy(x-ts,y,x+ts,y)) }

       else  if (mode == 16)			# deux triangles superposés			 
	  { $.line(xy(x-ts,y-ts,x+ts,y+ts)) ; $.line(xy(x+ts,y-ts,x-ts,y+ts)) 
	    $.line(xy(x-ts,y-ts,x+ts,y-ts)) ; $.line(xy(x+ts,y+ts,x-ts,y+ts)) }    

       else  if (mode == 17)			# deux triangles couchés			 
	  { $.line(xy(x-ts,y-ts,x+ts,y+ts)) ; $.line(xy(x+ts,y-ts,x-ts,y+ts)) 
	    $.line(xy(x-ts,y-ts,x-ts,y+ts)) ; $.line(xy(x+ts,y-ts,x+ts,y+ts)) }    

       else  if (mode == 18)			# deux triangles superposés avec centre			 
	  { $.line(xy(x-ts,y-ts,x+ts,y+ts)) ; $.line(xy(x+ts,y-ts,x-ts,y+ts)) 
	    $.line(xy(x-ts,y-ts,x+ts,y-ts)) ; $.line(xy(x+ts,y+ts,x-ts,y+ts)) 
	    $.line(xy(x,y-ts,x,y+ts)) }    

       else  if (mode == 19)			# deux triangles couchés avec centre			 
	  { $.line(xy(x-ts,y-ts,x+ts,y+ts)) ; $.line(xy(x+ts,y-ts,x-ts,y+ts)) 
	    $.line(xy(x-ts,y-ts,x-ts,y+ts)) ; $.line(xy(x+ts,y-ts,x+ts,y+ts)) 
	    $.line(xy(x-ts,y,x+ts,y)) }    



       else  if (mode == -1)			# (utilisé pour les points sélectionnés)		 
	  { $.ellipse(xy(x-ts,y-ts,x+ts,y+ts))
	    $.ellipse(xy(x-0.5*ts,y-0.5*ts,x+0.5*ts,y+0.5*ts)) }    

       else  if (mode == -2)			# (utilisé pour les centres de cercles)		 
	  { $.line(xy(x-2*ts,y,x-ts,y)) ; $.line(xy(x,y-2*ts,x,y-ts))   
	    $.line(xy(x+2*ts,y,x+ts,y)) ; $.line(xy(x,y+2*ts,x,y+ts)) } 

       else
	  $.ellipse(xy(x-ts,y-ts,x+ts,y+ts))
}


method cercle(cx,cy,r,mode){

       dt = 0.04*Pi
       if (nargs() == 3) mode = STORE

       xt0 = r+cx
       yt0 = cy
       for (t=dt; t<= 2*Pi+dt; t+=dt)
       {
	   xt = r*cos(t)+cx
	   yt = r*sin(t)+cy
	   $.line(xy(xt0,yt0,xt,yt),mode)
	   xt0 = xt
	   yt0 = yt
       }       
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

########################################################################################
###################### Options d'affichage


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
        ($.GUI).prepare_undo(GMblah_UNDO11) 
	$.bornes = $.autobornes(1)
	$.redraw()
}


method bougesymboles() {
       if (($.taille_symboles += 1) > 5) $.taille_symboles = 1
       $.stick = $.taille_symboles
       $.redraw()
}

method bougegrid() {
       if (($.grid += 1) > 3) $.grid = 0	
       $.redraw()
}

method bougeseg() {
       $.showprojections = ($.showprojections+1)%4
       $.redraw()
}

method bougesnap() {
       $.snap2grid = ($.snap2grid+1)%2
       if ($.snap2grid == 0) print(GMblah_GUI65)
       else print (GMblah_GUI64)
}

########################################################################################
###################### Gestion des zones

method activezone(nz) {

    if (nz in $.lzones)
    {
       ActiveRegion(RRect($.lzones[nz]["A"],$.lzones[nz]["B"]))
       $.redraw()
    }
}

method desactivezone(nz) {

    if (nz in $.lzones)
    {
       DesactiveRegion(RRect($.lzones[nz]["A"],$.lzones[nz]["B"]))
       $.redraw()
    }
}


########################################################################################
###################### Gestion des $.lpoints, $.lcercles et $.lsegs: DISPLAY


method affichepoints(command)	       # méthode principale pour "display"
{
     $.affichinfos(0)
     if (nargs()==1)
	listestr = command
     else
     {
        ($.GUI).prepare_undo(GMblah_UNDO12) 
        listestr = (getastr("Nom(s): ",""))
     }
     liste = split(listestr,", ")
	
     if (liste[0] != "")
     {
	for (n=0; n<sizeof(liste); n++)
	{
	   ## Syntaxe spéciale pour les segments dynamiques (A-B  ---> S_A_B)	      
	   tsd = split(liste[n], "-")
	   if (substr(liste[n],1,1) == "-") neg = "-" else neg = ""	
	   if (sizeof(tsd) >= 2)
	   {	
	     for (is = 0; is < sizeof(tsd)-1; is ++)
	     {
		eval("S_"+tsd[is]+"_"+tsd[is+1]+" = Seg("+tsd[is]+","+tsd[is+1]+")")
		$.affichepoints(neg+"S_"+tsd[is]+"_"+tsd[is+1])
	     }
	     liste[n]=""
	   }	

	   ## Syntaxe spéciale pour les lignes de $.lstock (£n ---> RL[n])	      
	   liste[n] = $.GUI.ligne_comme_arg(liste[n])		

	   ## Syntaxe spéciale pour les zones de $.lzones (µn)	      
	   if (substr(liste[n],1,1) == "µ")	
	   {		
	      zosp = split(liste[n],"µ")	
	      if (sizeof(zosp) == 0)
		for (nz in $.lzones) $.lzones[nz]["vis"] = 1
	      else
	      {
		nz = integer(zosp[0])	
		if (nz in $.lzones) $.lzones[nz]["vis"] = 1
              }
	      liste[n] = ""
	   }        
	   else if (substr(liste[n],1,2) == "-µ")
	   {
	      zosp = split(liste[n],"µ")
	      if (sizeof(zosp) == 1)
		for (nz in $.lzones) $.lzones[nz]["vis"] = 0
	      else	
	      {
		nz = integer(zosp[1])	
		if (nz in $.lzones) $.lzones[nz]["vis"] = 0
              }
	      liste[n] = ""
	   }	
	   ## fin syntaxes spéciales


	   if (liste[n] == "--")			# efface tout
	   {
		$.lpoints = [0=0]
		$.lcercles = [0=0]
		$.lsegs = [0=0]
	   }
	   else if (liste[n] == "-£")			# efface toutes les lignes
	   {
		for (ic = $.lsegs[0]; ic >= 1; ic--)
		   if (substr($.lsegs[ic]["nom"],1,5) == "In_RL") $.lsegs[ic]= 0
	        $.lsegs = $.reorganise($.lsegs)
		for (ic = $.lpoints[0]; ic >= 1; ic--)
		   if (substr($.lpoints[ic]["nom"],1,5) == "In_RL") $.lpoints[ic]= 0
	        $.lpoints = $.reorganise($.lpoints)
		for (ic = $.lcercles[0]; ic >= 1; ic--)
		   if (substr($.lcercles[ic]["nom"],1,5) == "In_RL") $.lcercles[ic]= 0
	        $.lcercles = $.reorganise($.lcercles)
	   }
	   else if (substr(liste[n],1,1) == "-")	# suppression d'un élément
	   {
		nomv = substr(liste[n],2, sizeof(liste[n])-1)

		eval("G__ = "+nomv)
		if (typeof(G__) != "array") break

		if (0 in G__)				# ligne, collection, piste
		{
		   ls = sizeof(nomv)+3
		   if ($.lsegs[0])
		   {
		     for (ic = $.lsegs[0]; ic >= 1; ic--)
		       if (substr($.lsegs[ic]["nom"],1,ls) == "In_"+nomv) $.lsegs[ic]= 0
			
	             $.lsegs = $.reorganise($.lsegs)
		   }     
		   if ($.lpoints[0])
		   {
		     for (ic = $.lpoints[0]; ic >= 1; ic--)
		       if (substr($.lpoints[ic]["nom"],1,ls) == "In_"+nomv) $.lpoints[ic]= 0

		     $.lpoints = $.reorganise($.lpoints)
		   }
		   if ($.lcercles[0])
		   {
		     for (ic = $.lcercles[0]; ic >= 1; ic--)
		       if (substr($.lcercles[ic]["nom"],1,ls) == "In_"+nomv) $.lcercles[ic]= 0

		     $.lcercles = $.reorganise($.lcercles)
		   }
		}
		else 
		{
		   if ($.lpoints[0])
		      for (ip = 1; ip <= $.lpoints[0]; ip++)
		       if ($.lpoints[ip]["nom"] == nomv)
			   {$.lpoints = SupprimeIndex(ip, $.lpoints) ; $.lpoints[0] -= 1 ;ip--}
		   if ($.lcercles[0])
		      for (ic = 1; ic <= $.lcercles[0]; ic++)
		       if ($.lcercles[ic]["nom"] == nomv)
			   {$.lcercles = SupprimeIndex(ic, $.lcercles) ; $.lcercles[0] -= 1 ;ic--}
		   if ($.lsegs[0])
		      for (ic = 1; ic <= $.lsegs[0]; ic++)
		       if ($.lsegs[ic]["nom"] == nomv)
			   {$.lsegs =  SupprimeIndex(ic, $.lsegs) ; $.lsegs[0] -= 1 ;ic--}
                }
	   }
	   else if (liste[n] != "")
	   {				
		eval("G__="+liste[n])
		if (typeof(G__) != "array") print("---- "+liste[n]+GMblah_GUI17)	  # non défini

		else if ("c" in G__)	# cercle
		   $.ajoutitem(liste[n], G__, $.lcercles) 

		else if ("x" in G__)	# point
		   $.ajoutitem(liste[n], G__, $.lpoints) 

		else if ("x0" in G__)	# segment
		   $.ajoutitem(liste[n], G__, $.lsegs) 

		else if ("id" in G__)	# ligne
		{
		   $.defineAsArray("In_",liste[n])
		   $.inters_et_racs(G__,"In_"+liste[n])
		}

		else if (0 in G__)	# collection, piste
		   if(G__[0]) for (i = 1; i<= G__[0]; i++)
			$.ajoutitem("In_"+liste[n]+string(i), G__[i], $.lpoints)
	   }
	}
	$.redraw()
	$.affichinfos(1)
     }
}
method inters_et_racs(lig,nom) {	# scan récursif des champs "rac" et "inter"

    eval(nom+"= []")

    for (i in lig)
    {     
       if (i == "rac") $.cherche_sc(lig["rac"],nom+"[0]")

       else if (i == "inter") 
	 $.inters_et_racs(lig["inter"],nom)

       else if ((typeof(i) == "integer") && (typeof(lig[i]) == "array")) 
	    if ((res = $.cherche_sc(lig[i],nom+"["+string(i)+"]")) == 0)
	       $.inters_et_racs(lig[i],nom+"["+string(i)+"]")  
    }	 
}
method cherche_sc(lig,nom) {	# recherche des définitions de cercles et de segments
	   if ("A" in lig)
	   {
		     eval("G__G = "+nom+"= Seg("+string(lig["A"])+","+string(lig["B"])+")")
		     $.ajoutitem(nom, G__G, $.lsegs)	
		     return(1)	
	   }
	   else if ("cer" in lig)
	   {
		     eval("G__G = "+nom+"="+string(lig["cer"]))
		     $.ajoutitem(nom, G__G, $.lcercles)
		     return(1)
	   }
	   else return(0)
}
method defineAsArray(prefix, nomv) {			# chaud !

       mor = split(nomv, "[")			#]

       nom = prefix+mor[0]
       eval(nom+"=[]")

       if (sizeof(mor) > 1) for (i=1; i<= sizeof(mor)-1; i++)
	{
	    nom = nom+"["+mor[i]		#]
	    eval(nom+"=[]")
	}
}
method reorganise(liste) {
       
       index = 0
       newliste = []
       if (liste[0] > 0) 
	 for (pointeur = 1; pointeur <= liste[0]; pointeur++)
	   if (liste[pointeur] != 0) 
	   {
		index +=1
		newliste[index] = liste[pointeur]
	   }
    
       newliste[0] = index
       return(liste = newliste)
}
method ajoutitem(nom, item, liste) {

	liste[0] += 1
	liste[liste[0]] = ArCopy(item)
	liste[liste[0]]["nom"] = nom
}
method affichinfos(df){
        
	if (df == 0)
	{
		code = "\"--\""
		print(GMblah_GUI18+code+GMblah_GUI19)
	}
	else	
		print(GMblah_GUI20)

	lp = ""
	if ($.lpoints[0])
	   for (ip = 1; ip <= $.lpoints[0]; ip++) lp = lp+$.lpoints[ip]["nom"]+" "
	print("Points: "+lp)

	ls = ""
	if ($.lsegs[0])
	   for (ip = 1; ip <= $.lsegs[0]; ip++) ls = ls+$.lsegs[ip]["nom"]+" "
	print("Segments: "+ls)

	lp = ""
	if ($.lcercles[0])
	   for (ip = 1; ip <= $.lcercles[0]; ip++) lp = lp+$.lcercles[ip]["nom"]+" "
	print(GMblah_GUI21+lp)
}

method init_segdyn() {
       $.segdyn = []		
}
method add_segdyn(nom) {
       $.segdyn[nom] = 1	
}
method update_segdyn() {
   if ($.lsegs[0])
   {
	liste_ajour = ""
	for (ic = 1; ic <= $.lsegs[0]; ic++)
	{
	   noms = $.lsegs[ic]["nom"] 
	   comp = split(noms,"_")
	   if (sizeof(comp) == 3)					# type S_A_B
	      if ((comp[1] in $.segdyn) || (comp[2] in $.segdyn))
		 liste_ajour += ",-"+noms+","+comp[1]+"-"+comp[2]
	}
	$.affichepoints(liste_ajour)
   }
}


########################################################################################
###################### Gestion des $.lpoints, $.lcercles et $.lsegs: OPERATION, TRANSFERT 


method formule_points(formule) {	# extension de KKSS pour $.lpoints et $.lcercles

  scripts=split(formule,"$")
  for (i=0; i<sizeof(scripts); i++)
  {	
    formule = GereHistory(scripts[i], FKK)	  # si ":.." pour history et mode indirect

    update_segdyn = 0		   
    if ($.lpoints[0])
    {
       $.init_segdyn()
       for (n=1; n <= $.lpoints[0]; n++) if ($.lpoints[n]["s"] == 1)
	     {
		X_ = $.lpoints[n]["x"] 
		Y_ = $.lpoints[n]["y"] 
		N_ = ''
		C_ = 0
		S_ = $.lpoints[n]["s"] 
		eval(formule)
		$.lpoints[n]["x"] = X_
		$.lpoints[n]["y"] = Y_ 
		$.lpoints[n]["s"] = S_
		eval($.lpoints[n]["nom"]+"= xyd("+string(X_)+","+string(Y_)+")")
		$.add_segdyn($.lpoints[n]["nom"])
		update_segdyn = 1
	     } 
    }
    if (update_segdyn) $.update_segdyn()

    if ($.lcercles[0])
	  for (n=1; n <= $.lcercles[0]; n++) if ($.lcercles[n]["s"] == 1)
	  {
	        X_ = $.lcercles[n]["c"]["x"] 
	        Y_ = $.lcercles[n]["c"]["y"] 
		N_ = ''
		R_ = $.lcercles[n]["r"]
		S_ = $.lcercles[n]["s"]
		C_ = 0
		eval(formule)
		x= string($.lcercles[n]["c"]["x"] = X_)
		y= string($.lcercles[n]["c"]["y"] = Y_)
		r= string($.lcercles[n]["r"] = R_)
		$.lcercles[n]["s"] = S_
		eval($.lcercles[n]["nom"]+"= Cerc(xyd("+x+","+y+"), "+r+")")
	  }
  }
}


method selptoev() {
         ($.GUI).prepare_undo(GMblah_UNDO13) 
         if ($.lpoints[0])
           for (n=1; n <= $.lpoints[0]; n++) if ($.lpoints[n]["s"] == 1)
		$.mousenewevent("mode interne", $.lpoints[n])
}


method selevtop() {
	for (ch = 1; ch <= NbCan; ch++) if (Ev[ch][0] > 0)
	     for (n=1; n <= Ev[ch][0]; n++) if (Ev[ch][n]["s"] == 1)
	        $.mousenewpoint("appel interne", Ev[ch][n])
}


method seltopiste() {  
       nom = getastr(GMblah_GUI2,"")
       if (nom != "")
       {
	 N__ = 0
	 eval("G__ = defined("+nom+")")
	 if (G__ == 1)		# ajout à une piste existante
	    eval("N__ = "+nom+"[0]")
         np = N__
	 T__ = [0=N__]

         if ($.lpoints[0])
           for (n=1; n <= $.lpoints[0]; n++) if ($.lpoints[n]["s"] == 1)
	     {
	        np ++
		T__[np] = ["x"= $.lpoints[n]["x"], "y"= $.lpoints[n]["y"]] 
	     } 
	 T__[0] = np

	 if (G__ == 1)		# ajout à une piste existante
	    eval(nom+"[0]=T[0]; for (n=N__+1; n<=T__[0]; n++) "+nom+"[n]= T__[n]")
	 else			# nouvelle piste
	    eval(nom+"= ArCopy(T__)")
       }    
}


########################################################################################
################### gestion souris: aiguillage

method setmousemode(nbutt, mode) {
       $.mouse_mode[nbutt] = mode 
}

method setselmode(mode) {
       $.selection_mode = mode
}
method mousedown(m) {
       mode = $.mouse_mode[m["button"]]
       $.mbutton = m["button"]

       if ((mode == $.Zonage_infos)||(mode == $.ZSelection)||(mode == $.Recadrage)||(mode == $.DefZone))
	  $.mousedown_zonage(m)

       else if (mode == $.NewEvent)
          $.mousenewevent($.collaugrillage(m))

       else if (mode == $.DefPoint)
          $.mousenewpoint($.collaugrillage(m))

       else if (mode == $.SModif)
	  $.installe_mire($.collaugrillage(m))

       else if ((mode == $.DepSel) || (mode == $.SCopy) || (mode == $.Ph2Seg) || (mode == $.Ph2Cer)|| (mode == $.HearSeg))
          $.point_ref($.cherche_cible($.collaugrillage(m)))

       else if (mode == $.MoveAround)
          $.point_ref(m)
}
method mousedrag(m) {
       mode = $.mouse_mode[m["button"]]

       if ((mode == $.Zonage_infos)||(mode == $.ZSelection)||(mode == $.Recadrage)||(mode == $.DefZone))
	  $.mousedrag_zonage(m)

       else if (mode == $.SModif)
	  $.mod_mire($.collaugrillage(m))

       else if ((mode == $.DepSel) || (mode == $.SCopy) || (mode == $.Ph2Seg) || (mode == $.HearSeg))
	  $.pointe_vers_ref($.collaugrillage(m))

       else if (mode == $.Ph2Cer)
       {
	  $.pointe_vers_ref($.collaugrillage(m))
	  $.cercle_ref(m, 1)
       }

       else if (mode == $.MoveAround)
          $.movedirect(m)
}
method mouseup(m) {
       mode = $.mouse_mode[$.mbutton]

       if (mode == $.Zonage_infos)
       {
		$.mouseup_zonage(m)
		$.onup_infos()
       }

       else if (mode == $.ZSelection)
       {
		$.mouseup_zonage(m)
		$.onup_selectionne()
       }

       else if (mode == $.DefZone)
       {
		$.mouseup_zonage(m)
		$.onup_defzone()
       }

       else if (mode == $.Recadrage)
       {
		$.mouseup_zonage(m)
		$.onup_recadre()
       }

       else if (mode == $.SModif)
			$.desinstalle_mire($.collaugrillage(m))

       else if (mode == $.DepSel)
		        $.onup_depsel($.collaugrillage(m))

       else if (mode == $.SCopy)
		        $.onup_scopy($.collaugrillage(m))

       else if (mode == $.Ph2Seg)
			$.onup_aligneph($.collaugrillage(m))

       else if (mode == $.Ph2Cer)
			$.onup_enrondph($.collaugrillage(m))

       else if (mode == $.HearSeg)
			$.onup_hearseg($.collaugrillage(m))
       
} 


########################################################################################
############## gestion souris: méthodes

method mousenewevent(m, m2) {

       if (nargs() == 1)    # appel par souris
       {
	 rax = float($.bornes["x1"]-$.bornes["x0"])/($.xmax()-$.xmin())
	 ray = float($.bornes["y1"]-$.bornes["y0"])/($.ymax()-$.ymin())
	 
	 xev = $.xgeo(m["x"],$.snap2grid)
	 yev = $.ygeo(m["y"],$.snap2grid )
       }
       else		    # appel par $.selptoev
       {
         xev = m2["x"]
	 yev = m2["y"]
       }		
	 newev = getastr("("+string(xev)+","+string(yev)+") nodur#ch: ","")

	 if (newev != "")
	 {
	   if (newev == "*") newev = "2b#"+string($.GUI.getcurrch())	 

	   nev = split(newev, "#")
	   if (1 in nev) ch = integer(nev[1]) else ch=$.GUI.getcurrch()
	   if ((ch < 1) || (ch > NbCan)) ch = $.GUI.getcurrch()1

	   Ev[ch][0] += 1
	   eval("N_N = "+nev[0]) 
	   if (typeof(N_N) == "integer") N_N = $.getrecorded(N_N)	# get Recorded
	   else if (typeof(N_N) != "phrase") N_N = phrase(N_N)

	   if ((ch <= 16) && (N_N.chan != ch)) print(GMblah_GUI74)
	   if (ch <= 16) {N_N=onlynotes(N_N) ; N_N.chan = 1 }

	   print("nodur: "+string(N_N))
	   Ev[ch][Ev[ch][0]] = ["x"= float(xev), "y"=float(yev), "nodur" = N_N, "actif"=1]
	   $.redraw()
	 }
}
method getrecorded(space) {
	ph = lastbunch(Recorded,space)
	if ( sizeof(ph) <= 0 ) {
		print(GMblah_GUI73)
		return()
	}
	ph = syncphr(ph, 1)
	return(ph)
}

method mousenewpoint(m, m2) {

       if (nargs() == 1)    # appel par souris
       {
	 xev = string($.xgeo(m["x"],$.snap2grid))
	 yev = string($.ygeo(m["y"],$.snap2grid))
       }
       else		    # appel par $.selevtop
       {
         xev = string(m2["x"])
	 yev = string(m2["y"])
       }	
		
	 newp = getastr("Point ("+xev+","+yev+GMblah_GUI22,"")
	 
	 if (newp != "")
	 {	 
		 eval(newp+"= xyd("+xev+","+yev+")")
		 $.ajoutitem(newp, xyd(float(xev), float(yev)), $.lpoints) 
		 $.redraw()
         }
}

method mousedown_zonage(m) {

        $.zone = 1
        $.drag_en_cours = 0
	$.zone_x1 = x = m["x"]
	$.zone_y1 = y = m["y"]
 
	$.line(xy(x,$.ymin()+1,x,$.ymax()-1),XOR) ; $.line(xy($.xmin()+1,y,$.xmax()-1,y),XOR)  
 
}
method mousedrag_zonage(m) { 


       if ($.drag_en_cours ==1)
       {
	x = $.zone_x2 
	y = $.zone_y2 
	$.line(xy(x,$.ymin()+1,x,$.ymax()-1),XOR) ; $.line(xy($.xmin()+1,y,$.xmax()-1,y),XOR)
       }		

       $.drag_en_cours = 1       

       $.zone_x2 = x = m["x"]
       $.zone_y2 = y = m["y"] 	

       $.line(xy(x,$.ymin()+1,x,$.ymax()-1),XOR) ; $.line(xy($.xmin()+1,y,$.xmax()-1,y),XOR)
      
}

method mouseup_zonage(m) {

        if ($.zone == 1)
	{
		x = $.zone_x1 
		y = $.zone_y1 
		$.line(xy(x,$.ymin()+1,x,$.ymax()-1),XOR) ; $.line(xy($.xmin()+1,y,$.xmax()-1,y),XOR)
		$.zone = 0
	}

	if ($.drag_en_cours == 1)
	{
	 x = $.zone_x2 
	 y = $.zone_y2 
	 $.line(xy(x,$.ymin()+1,x,$.ymax()-1),XOR) ; $.line(xy($.xmin()+1,y,$.xmax()-1,y),XOR)

	 $.drag_en_cours = 0
	}
	else
	{
		$.zone_x2 =  m["x"]
		$.zone_y2 =  m["y"] 	
	}
}

method onup_infos() {

	 xmin = Minimum($.zone_x1, $.zone_x2)
	 xmax = Maximum($.zone_x1, $.zone_x2)
	 ymin = Minimum($.zone_y1, $.zone_y2)
	 ymax = Maximum($.zone_y1, $.zone_y2)

	 rax = float($.bornes["x1"]-$.bornes["x0"])/($.xmax()-$.xmin())
	 ray = float($.bornes["y1"]-$.bornes["y0"])/($.ymax()-$.ymin())

	 if ((xmax != xmin)&&(ymax != ymin))
	 {
	   oui = 0
	   print("---- infos:")

	   ################### $.lpoints

	   if ($.lpoints[0])
	      for (n=1; n <= $.lpoints[0]; n++) 
	      {
		x = ($.lpoints[n]["x"] - $.bornes["x0"])/rax + $.xmin()
		y = $.ymax() - ($.lpoints[n]["y"] - $.bornes["y0"])/ray

		if ((x <= xmax)&&(x>= xmin)&&(y<=ymax)&&(y>=ymin))
		{
		   oui = 1
		   print("POINT "+$.lpoints[n]["nom"]+" x="+string($.lpoints[n]["x"])+" y="+string($.lpoints[n]["y"]))
		}
              }

	   ################### $.lcercles

	   if ($.lcercles[0])
	      for (n=1; n <= $.lcercles[0]; n++) 
	      {
		x = ($.lcercles[n]["c"]["x"] - $.bornes["x0"])/rax + $.xmin()
		y = $.ymax() - ($.lcercles[n]["c"]["y"] - $.bornes["y0"])/ray

		if ((x <= xmax)&&(x>= xmin)&&(y<=ymax)&&(y>=ymin))
		{
		   oui = 1
		   print(GMblah_GUI23+$.lcercles[n]["nom"]+" x="+string($.lcercles[n]["c"]["x"])+" y="+string($.lcercles[n]["c"]["y"])+" R="+string($.lcercles[n]["r"]))
		}
              }

	   ##### Zones

	   if (sizeof($.lzones) > 0)
	      for (n in $.lzones)
	      {
	        x = $.xecran($.lzones[n]["A"]["x"])
	        y = $.yecran($.lzones[n]["A"]["y"])
		if ((x <= xmax)&&(x>= xmin)&&(y<=ymax)&&(y>=ymin))
		{
		   oui = 1
		   print($.lzones[n]["comm"])
		   zocom = getastr(GMblah_GUI68,"")
		   if (zocom != "") $.lzones[n]["comm"] = string(n)+": "+zocom
		}
	      }
	  

	   ##### Ev
	   
	   for (ch = 1; ch <= NbCan; ch++) if (Ev[ch][0] > 0)
	     for (n=1; n <= Ev[ch][0]; n++) if (Ev[ch][n]["actif"] == 1)
	     {
		xev = (Ev[ch][n]["x"] - $.bornes["x0"])/rax + $.xmin()
		yev = $.ymax() - (Ev[ch][n]["y"] - $.bornes["y0"])/ray

		if ((xev <= xmax)&&(xev>= xmin)&&(yev<=ymax)&&(yev>=ymin))
		{
		   print("(ch"+string(ch)+" n"+string(n)+") x="+string(Ev[ch][n]["x"])+" y="+string(Ev[ch][n]["y"])+" "+string(Ev[ch][n]["nodur"]))
		   if (Ev[ch][n]["label"]+Ev[ch][n]["script"] != "")
		      print(" (label: "+"\""+Ev[ch][n]["label"]+"\""+" script: "+"\""+Ev[ch][n]["script"]+"\""+")")
		   oui = 1
		}
	     } 
	     if (oui == 0)
	        print(GMblah_GUI24) 
	 }
	 else
	   print("point x=",$.xgeo(xmin)," y=",$.ygeo(ymin))
}

method onup_defzone() {
    zo= getastr("{n}, infos > ","")    
    if (zo != "")
    {
       nuzo = integer(split(zo," ,:/;-=")[0])
       if (!defined(nuzo)) 
	  {
		nuzo = 1	
		while (nuzo in $.lzones) nuzo += 1
		zo = string(nuzo)+": "+zo
	  }
       if (nuzo in $.lzones) ok = getastr(GMblah_GUI69,"n") else ok ="o"
       if ((ok == "y") || (ok == "o"))
       {
	 $.lzones[nuzo] = ["comm"= "Zone "+zo]
	 xmin = Minimum($.zone_x1, $.zone_x2)
	 xmax = Maximum($.zone_x1, $.zone_x2)
	 ymin = Minimum($.zone_y1, $.zone_y2)
	 ymax = Maximum($.zone_y1, $.zone_y2)
	 $.lzones[nuzo]["A"] = ["x"= $.xgeo(xmin), "y"= $.ygeo(ymin)]
	 $.lzones[nuzo]["B"] = ["x"= $.xgeo(xmax), "y"= $.ygeo(ymax)]
	 $.lzones[nuzo]["vis"] = 1
       }
       $.redraw()
   }
}

method onup_selectionne() {

	 xmin = Minimum($.zone_x1, $.zone_x2)
	 xmax = Maximum($.zone_x1, $.zone_x2)
	 ymin = Minimum($.zone_y1, $.zone_y2)
	 ymax = Maximum($.zone_y1, $.zone_y2)

	 rax = float($.bornes["x1"]-$.bornes["x0"])/($.xmax()-$.xmin())
	 ray = float($.bornes["y1"]-$.bornes["y0"])/($.ymax()-$.ymin())

	 if ((xmax != xmin)&&(ymax != ymin))
	 {

	   if ($.selection_mode == Sminus)
		print(GMblah_GUI25)
	   else
		print(GMblah_GUI26)
	   oui = 0

	   ################### $.lpoints

	   if ($.lpoints[0])
	      for (n=1; n <= $.lpoints[0]; n++)
	      {
	        if ($.selection_mode == Sremplace)
		   $.lpoints[n]["s"] = 0

		x = ($.lpoints[n]["x"] - $.bornes["x0"])/rax + $.xmin()
		y = $.ymax() - ($.lpoints[n]["y"] - $.bornes["y0"])/ray

		if ((x <= xmax)&&(x>= xmin)&&(y<=ymax)&&(y>=ymin))
		{
		   oui = 1
		   print("POINT "+$.lpoints[n]["nom"])
		   if ($.selection_mode == Sminus)
		     $.lpoints[n]["s"] = 0
		   else
		     $.lpoints[n]["s"] = 1
		}
              }

	   ################### $.lcercles

	   if ($.lcercles[0])
	      for (n=1; n <= $.lcercles[0]; n++)
	      {
	        if ($.selection_mode == Sremplace)
		   $.lcercles[n]["s"] = 0

		x = ($.lcercles[n]["c"]["x"] - $.bornes["x0"])/rax + $.xmin()
		y = $.ymax() - ($.lcercles[n]["c"]["y"] - $.bornes["y0"])/ray

		if ((x <= xmax)&&(x>= xmin)&&(y<=ymax)&&(y>=ymin))
		{
		   oui = 1
		   print(GMblah_GUI23+$.lcercles[n]["nom"])
		   if ($.selection_mode == Sminus)
		     $.lcercles[n]["s"] = 0
		   else
		     $.lcercles[n]["s"] = 1
		}
              }


           ##### Ev

	   for (ch = 1; ch <= NbCan; ch++) if (Ev[ch][0] > 0)
	     for (n=1; n <= Ev[ch][0]; n++) if (Ev[ch][n]["actif"] == 1)
	     {
	        if ($.selection_mode == Sremplace)
		   Ev[ch][n]["s"] = 0

		xev = (Ev[ch][n]["x"] - $.bornes["x0"])/rax + $.xmin()
		yev = $.ymax() - (Ev[ch][n]["y"] - $.bornes["y0"])/ray

		if ((xev <= xmax)&&(xev>= xmin)&&(yev<=ymax)&&(yev>=ymin))
		{
		   oui = 1
		   print("(ch"+string(ch)+") x="+string(Ev[ch][n]["x"])+" y="+string(Ev[ch][n]["y"])+" "+string(Ev[ch][n]["nodur"]))
		   if ($.selection_mode == Sminus)
		      Ev[ch][n]["s"] = 0
		   else
		      Ev[ch][n]["s"] = 1
		}
	     }
	     if (! oui)
	        print(GMblah_GUI27) 
	 }
	 else
	 {
	    print("point x=",$.xgeo(xmin)," y=",$.ygeo(ymin))
	    for (ch = 1; ch <= NbCan; ch++) if (Ev[ch][0] > 0)
	       for (n=1; n <= Ev[ch][0]; n++)
		   Ev[ch][n]["s"] = 0

            if ($.lpoints[0])
	      for (n=1; n <= $.lpoints[0]; n++)
	         $.lpoints[n]["s"] = 0

            if ($.lcercles[0])
	      for (n=1; n <= $.lcercles[0]; n++)
	         $.lcercles[n]["s"] = 0
	 }  
         $.redraw()
}


method onup_recadre() {

	 xmin = Minimum($.zone_x1, $.zone_x2)
	 xmax = Maximum($.zone_x1, $.zone_x2)
	 ymin = Minimum($.zone_y1, $.zone_y2)
	 ymax = Maximum($.zone_y1, $.zone_y2)

	 if ((xmax != xmin)&&(ymax != ymin))
	 {
            ($.GUI).prepare_undo(GMblah_UNDO14) 

	    nbornes = xyd($.xgeo(xmin), $.ygeo(ymax), $.xgeo(xmax), $.ygeo(ymin))
  
	    rapportx = float(nbornes["x1"]-nbornes["x0"])/($.xmax()-$.xmin())
	    rapporty = float(nbornes["y1"]-nbornes["y0"])/($.ymax()-$.ymin())

	    if (rapportx > rapporty)
		   nbornes["y1"] = nbornes["y0"] + ($.ymax()-$.ymin())*rapportx
	    else
		   nbornes["x1"] = nbornes["x0"] + ($.xmax()-$.xmin())*rapporty
         }
	 
	 else		# recentrage intelligent (cherche une cible)
	 {
	     m = $.cherche_cible(xyd(xmin,ymin))	 

  	     cx = $.xgeo(m["x"],1)
	     cy = $.ygeo(m["y"],1)
	     ix = 0.5*($.bornes["x1"]-$.bornes["x0"])
	     iy = 0.5*($.bornes["y1"]-$.bornes["y0"])
	     nbornes = xyd(cx-ix, cy-iy, cx+ix, cy+iy)
	 }
	 $.redraw(nbornes)
}

method installe_mire(m) {

        $.centre = xymid(xy($.xmin(), $.ymin(), $.xmax(), $.ymax() ))

	x = m["x"]-$.centre["x"]
	y = m["y"]-$.centre["y"]
	$.ref = Getpolar(x, y)
        $.raymire = $.ref["r"] 	

	$.refx1 = $.centre["x"] - $.raymire
	$.refx2 = $.centre["x"] + $.raymire
	$.refy1 = $.centre["y"] - $.raymire
	$.refy2 = $.centre["y"] + $.raymire

	color(5)

	$.ellipse(xy($.refx1, $.refy1, $.refx2, $.refy2),STORE)
	$.line(xy($.centre["x"], $.centre["y"], $.centre["x"], $.centre["y"]-$.raymire),STORE)

	color(1)
}

method mod_mire(m) { 
  	
	$.redraw()

	color(5)
       x = m["x"]-$.centre["x"]
       y = m["y"]-$.centre["y"]
       $.cer = Getpolar(x, y)

       $.raymire = $.cer["r"] 
       angle = Mod2Pi($.cer["theta"]-$.ref["theta"])

       $.cerx1 = $.centre["x"] - $.raymire
       $.cerx2 = $.centre["x"] + $.raymire
       $.cery1 = $.centre["y"] - $.raymire
       $.cery2 = $.centre["y"] + $.raymire

       $.ellipse(xy($.refx1, $.refy1, $.refx2, $.refy2),STORE)
       $.ellipse(xy($.cerx1, $.cery1, $.cerx2, $.cery2),STORE)
       $.line(xy($.centre["x"], $.centre["y"], $.centre["x"]+$.raymire*sin(angle), $.centre["y"]-$.raymire*cos(angle)),STORE)
	
	color(1)
}

method desinstalle_mire(m) {
        ($.GUI).prepare_undo(GMblah_UNDO15) 

	x = m["x"]-$.centre["x"]
	y = m["y"]-$.centre["y"]
	$.cer = Getpolar(x, y)

        angle = Mod2Pi($.cer["theta"]-$.ref["theta"])	
	scalef = $.cer["r"]*pow($.ref["r"], -1)
	cx = $.xgeo($.centre["x"])	    # centre de rotation dans le plan des Ev
	cy = $.ygeo($.centre["y"])	    #

	for (ch = 1; ch <= NbCan; ch++) if (Ev[ch][0] > 0)
	     for (n=1; n <= Ev[ch][0]; n++) if (Ev[ch][n]["s"] == 1)
	     {
	        x = Ev[ch][n]["x"] - cx
	        y = Ev[ch][n]["y"] - cy
		rev = Setpolar(Getpolar(x,y)["r"]*scalef, Getpolar(x,y)["theta"]-angle)
		Ev[ch][n]["x"] = rev["x"]+cx
		Ev[ch][n]["y"] = rev["y"]+cy
	     }

       update_segdyn = 0
       if ($.lpoints[0])
       {
	  $.init_segdyn()
	  for (n=1; n <= $.lpoints[0]; n++) if ($.lpoints[n]["s"] == 1)
	  {
	        x = $.lpoints[n]["x"] - cx
	        y = $.lpoints[n]["y"] - cy
		rev = Setpolar(Getpolar(x,y)["r"]*scalef, Getpolar(x,y)["theta"]-angle)

		x = string($.lpoints[n]["x"] = rev["x"]+cx)
		y = string($.lpoints[n]["y"] = rev["y"]+cy)
		nom = $.lpoints[n]["nom"]
		eval(nom+"= xyd("+x+","+y+")")
		$.add_segdyn(nom)
		update_segdyn = 1
	  }
       }

       if ($.lcercles[0])
	  for (n=1; n <= $.lcercles[0]; n++) if ($.lcercles[n]["s"] == 1)
	  {
	        x = $.lcercles[n]["c"]["x"] - cx
	        y = $.lcercles[n]["c"]["y"] - cy
		rev = Setpolar(Getpolar(x,y)["r"]*scalef, Getpolar(x,y)["theta"]-angle)
		x= string($.lcercles[n]["c"]["x"] = rev["x"]+cx)
		y= string($.lcercles[n]["c"]["y"] = rev["y"]+cy)
		r= string($.lcercles[n]["r"] *= scalef)
		nom = $.lcercles[n]["nom"]
		eval(nom+"= Cerc(xyd("+x+","+y+"), "+r+")")
	  }

       if (update_segdyn) $.update_segdyn()
       $.redraw()
}

method point_ref(m) {
       $.refx = m["x"]
       $.refy = m["y"]
}

method pointe_vers_ref(m) {
       $.redraw()
       color(5)
       $.line(xy($.refx,$.refy,m["x"],m["y"]))
       color(1)
}

method cercle_ref(m, noredrawflag) {
       if (nargs() == 1) $.redraw()

       r = sqrt(pow(m["x"]-$.refx,2)+pow(m["y"]-$.refy,2))
       color(5)
       $.cercle($.refx,$.refy,r)
       color(1)
}

method onup_depsel(m) {
       ($.GUI).prepare_undo(GMblah_UNDO16) 

       vx = (m["x"]-$.refx)*(r=($.bornes["x1"]-$.bornes["x0"])/float($.xmax()-$.xmin()))
       vy = -(m["y"]-$.refy)*r

       for (ch = 1; ch <= NbCan; ch++) if (Ev[ch][0] > 0)
	  for (n=1; n <= Ev[ch][0]; n++) if (Ev[ch][n]["s"] == 1)
	  {
		Ev[ch][n]["x"] += vx
		Ev[ch][n]["y"] += vy
	  }

       update_segdyn = 0
       if ($.lpoints[0])
       {
	  $.init_segdyn()
	  for (n=1; n <= $.lpoints[0]; n++) if ($.lpoints[n]["s"] == 1)
	  {
		x = string($.lpoints[n]["x"] += vx)
		y = string($.lpoints[n]["y"] += vy)
		nom = $.lpoints[n]["nom"]
		eval(nom+"= xyd("+x+","+y+")")
		$.add_segdyn(nom)
		update_segdyn = 1
	  }
       }

       if ($.lcercles[0])
	  for (n=1; n <= $.lcercles[0]; n++) if ($.lcercles[n]["s"] == 1)
	  {
		x = string($.lcercles[n]["c"]["x"] += vx)
		y = string($.lcercles[n]["c"]["y"] += vy)
		r = string($.lcercles[n]["r"])
		nom = $.lcercles[n]["nom"]
		eval(nom+"= Cerc(xyd("+x+","+y+"), "+r+")")
	  }

       if (update_segdyn) $.update_segdyn()
       $.redraw()
}

method onup_scopy(m) {
       ($.GUI).prepare_undo(GMblah_UNDO17) 

       vx = (m["x"]-$.refx)*(r=($.bornes["x1"]-$.bornes["x0"])/float($.xmax()-$.xmin()))
       vy = -(m["y"]-$.refy)*r

       for (ch = 1; ch <= NbCan; ch++) if (Ev[ch][0] > 0)
	  for (n=1; n <= Ev[ch][0]; n++) if (Ev[ch][n]["s"] == 1)
	  {
		nn = (Ev[ch][0] +=1 )
		Ev[ch][nn] = ArCopy(Ev[ch][n])
		Ev[ch][nn]["x"] =  Ev[ch][n]["x"] + vx
		Ev[ch][nn]["y"] =  Ev[ch][n]["y"] + vy
		Ev[ch][nn]["s"] = 0
	  }


       if ($.lpoints[0])
	  for (n=1; n <= $.lpoints[0]; n++) if ($.lpoints[n]["s"] == 1)
	  {
	     newp = getastr("("+$.lpoints[n]["nom"]+GMblah_GUI28,"")
	     if (newp != "")
	     {
		eval(newp+"= xyd("+string($.lpoints[n]["x"] + vx)+","+string($.lpoints[n]["y"] + vy)+")")
		$.ajoutitem(newp, xyd($.lpoints[n]["x"] + vx,$.lpoints[n]["y"] + vy), $.lpoints) 
             }
	  }


       if ($.lcercles[0])
	  for (n=1; n <= $.lcercles[0]; n++) if ($.lcercles[n]["s"] == 1)
	  {
	     newp = getastr("("+$.lcercles[n]["nom"]+GMblah_GUI28,"")
	     if (newp != "")
	     {
		eval(newp+"= Cerc(xyd("+string($.lcercles[n]["c"]["x"] + vx)+","+string($.lcercles[n]["c"]["y"] + vy)+"),"+string($.lcercles[n]["r"])+")")
		$.ajoutitem(newp, Cerc(xyd($.lcercles[n]["c"]["x"] + vx,$.lcercles[n]["c"]["y"] + vy),$.lcercles[n]["r"]), $.lcercles) 
             }
	  }


       $.redraw()
}

method onup_aligneph(m) {
       ($.GUI).prepare_undo(GMblah_UNDO18) 

       paras = getastr("ph # ch {# auto} > ","")
       para = split(paras, "#")

       if (sizeof(para) >= 2)
       {
	   if (split(para[0]," ")[0] == "*")	# * pour get Recorded
	     P__ = $.getrecorded(2b)
	   else
	     eval("P__ ="+para[0])

	   eval("C__ ="+para[1])
	   if (sizeof(para) == 3) auto = 1 else auto = 0

	   pa = xyd($.xgeo($.refx,$.snap2grid), $.ygeo($.refy,$.snap2grid)) 
	   pb = xyd($.xgeo(m["x"],$.snap2grid), $.ygeo(m["y"],$.snap2grid)) 

	   if (auto)				# ici on considère la durée de la phrase
	   {
		duree = latest(P__)-P__%1.time
		longseg = duree/float(CPCM)
		facteur = longseg/float(Dist(pa,pb))
		pb["x"] = pa["x"] + facteur*(pb["x"]-pa["x"])   
		pb["y"] = pa["y"] + facteur*(pb["y"]-pa["y"])  
           }

	   Aligne(P__, pa, pb ,C__)    
	   PhS_= Seg(pa,pb)
	   print(GMblah_GUI77)  
	   $.redraw()
       }
}

method onup_enrondph(m) {
       ($.GUI).prepare_undo(GMblah_UNDO19) 

       paras = getastr("ph # ch {# auto} > ","")
       para = split(paras, "#")

       if (sizeof(para) >= 2)
       {
	   if (split(para[0]," ")[0] == "*")	# * pour get Recorded
	     P__ = $.getrecorded(2b)
	   else
	     eval("P__ ="+para[0])

	   eval("C__ ="+para[1])
	   if (sizeof(para) == 3) auto = 1 else auto = 0

	   cen = xyd($.xgeo($.refx,$.snap2grid), $.ygeo($.refy,$.snap2grid))

	   theta = Getpolar(m["x"]-$.refx,m["y"]-$.refy)["theta"]

	   if (auto == 0)
	   { 
		peri = xyd($.xgeo(m["x"]), $.ygeo(m["y"])) 
		ray = Dist(cen, peri)
	   }
	   else 				# ici on considère la durée de la phrase
	   {
		duree = latest(P__)-P__%1.time
		longperi = duree/float(CPCM)
		ray = longperi/(2*Pi) 
           }

	   EnRond(P__, cen, ray ,C__, theta)    
	   PhC_= Cerc(cen,ray)
	   print(GMblah_GUI78)
	   $.redraw()
       }
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


method onup_hearseg(m) 
{
	if ((Abs(m["x"]-$.refx)<$.stick) && (Abs(m["y"]-$.refy)<$.stick))
	{
	   for (ch = 1; ch <= NbCan; ch++) if (Ev[ch][0] > 0)
	     for (n=1; n <= Ev[ch][0]; n++) if (Ev[ch][n]["actif"] == 1)
	     {
		xev = $.xecran(Ev[ch][n]["x"])
		yev = $.yecran(Ev[ch][n]["y"])

		if ((Abs(m["x"]-xev)<$.stick) && (Abs(m["y"]-yev)<$.stick))
		{
		   nodch = Ev[ch][n]["nodur"]
		   if (ch <= 16) nodch.chan = ch
		   task realmidi(Ev[ch]["PAC"]+nodch) 
		   print(string(Ev[ch]["PAC"]+Ev[ch][n]["nodur"])+GMblah_GUI66a)
		}
	     } 
	}
	else
	{
		M_A = xyd($.xgeo($.refx),$.ygeo($.refy))
		M_B = xyd($.xgeo(m["x"]),$.ygeo(m["y"]))
		task realmidi(Snarph(Init16()+Ecoute(M_A,M_B)["ph"],"Ecoute() à la souris"))
		print(GMblah_GUI66b)
		$.redraw()		
	}
}



#########################################################################################


method collaugrillage(m) {	

   if ($.snap2grid != 0)
   {
       xin = xcib = m["x"]
       yin = ycib = m["y"]

       xmin = $.bornes["x0"]
       xmax = $.bornes["x1"]
       ymin = $.bornes["y0"]
       ymax = $.bornes["y1"]

       if ($.grid == 1)
       {
	   if (Abs(xin-$.xecran(0)) < $.stick) xcib = $.xecran(0)
	   if (Abs(yin-$.yecran(0)) < $.stick) ycib = $.yecran(0)
       }
       if ($.grid == 2)
       {
	   xing = $.xecran(Arrondi($.xgeo(xin)))
	   if (Abs(xin-xing) < $.stick) xcib = xing
	   ying = $.yecran(Arrondi($.ygeo(yin)))
	   if (Abs(yin-ying) < $.stick) ycib = ying
       }
       if ($.grid == 3)
       {
	   xing = $.xecran(0.1*Arrondi(10*$.xgeo(xin)))
	   if (Abs(xin-xing) < $.stick) xcib = xing
	   ying = $.yecran(0.1*Arrondi(10*$.ygeo(yin)))
	   if (Abs(yin-ying) < $.stick) ycib = ying
       }

       m["x"] = xcib
       m["y"] = ycib
   }
   return(m)
}


method cherche_cible(m) {	# améliorer l'algorithme, avec des options peut-être

	    xin = xcib = m["x"]
	    yin = ycib = m["y"]

	    #$.lpoints

	    if ($.lpoints[0])
	      for (n=1; n <= $.lpoints[0]; n++) 
	      {
		x = $.xecran($.lpoints[n]["x"])
		y = $.yecran($.lpoints[n]["y"])

		if ((Abs(x - xin) < $.stick)&&(Abs(y-yin) < $.stick))
		{
		   xcib = x
		   ycib = y
		}
              }

	   # $.lcercles

	   if ($.lcercles[0])
	      for (n=1; n <= $.lcercles[0]; n++) 
	      {
		x = $.xecran($.lcercles[n]["c"]["x"])
		y = $.yecran($.lcercles[n]["c"]["y"])

		if ((Abs(x - xin) < $.stick)&&(Abs(y-yin) < $.stick))
		{
		   xcib = x
		   ycib = y
		}
              }

	   # Ev

	   for (ch = 1; ch <= NbCan; ch++) if (Ev[ch][0] > 0)
	     for (n=1; n <= Ev[ch][0]; n++) if (Ev[ch][n]["actif"] == 1)
	     {
		x = $.xecran(Ev[ch][n]["x"])
		y = $.yecran(Ev[ch][n]["y"])
		
		if ((Abs(x - xin) < $.stick)&&(Abs(y-yin) < $.stick))
		{
		   xcib = x
		   ycib = y
		}
	     } 

	   m["x"] = xcib
	   m["y"] = ycib
	   return(m)
}



# fin class wfen
}




