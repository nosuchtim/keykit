class wkeychaos {
# 
# K e y C H A O S - v. 1.0 by Alberto Zin 
#
# KeyKit Tool for making music with chaos & fractals.
# Music is played on the first three midi channels.
# See readme_ketchaos.txt for more information. 
# Tested on Keykit 7.3a and 7.4b. This code is released under GPL.
# Dependencies: ffscal() and ffscaletotal() from H. Mikelson's hopasong.k
#
# Alberto Zin, 2006, Alberto.Zin@poste.it
# 
     
method init {       
    $.w = new window()
    $.inherit($.w)

    printf("\n")
    printf("K e y C h a o s !\n")
    printf("by Alberto Zin, 2006 - Initializing ...")
    
    $.debugprint = 0 # if 1 writes on c:\temp\keychaos.txt
    $.alpha =  1.4   # Henon Map attractor constants
    $.beta  =  0.3 
    $.dja   =  2.24  # De Jong attractor constants
    $.djb   = -0.65
    $.djc   =  0.43
    $.djd   = -2.43
    $.cra   =  0.15  # Rossler attractor constants
    $.crb   =  0.20
    $.crc   = 10.0
    $.h     =  0.04  # step size for runge kutta integration routine
    $.hlrz  =  0.01  # step size for runge kutta integration routine (Lorenz)
    $.hpa   =  1.25
    $.hpb   =  2.02
    $.hpc   =  0.5
    $.lrza  = 10.0   # Lorenz constants
    $.lrzb  = 28.0
    $.lrzc  = 8.0/3.0
    $.aduff = 0.256  # Duffing attractor
    $.bduff = 0.31
    $.wduff = 1.078 
    $.hpda  = 5.0    # henon phase diagrams

    $.fractal_type = 0  # no fractal selected yet
    $.dynfact = 1.0     # factor for $.alg_scal 
    $.bipolar = 1
    $.colored = 0       # colored drawing
    $.bkgcolor = 2
    $.ptsize =0.1
    $.strength = 3      # default "strength" parameter
    $.view = 0
    $.xalg = 0.1        # initial conditions for algorithms
    $.yalg = 0.0
    $.zalg = 0.0
    $.tid = -1
    $.first = 1
    $.startquant = 1b
    $.movesize = 1b/16  # default speed of the point
    $.PI = 3.141592653589793238462
    $.grid = $0
    $.sleeptm = 40 
    #patches =  progchange(5,1)    OLD DEFAULT
    # | progchange(12,2)           
    # | progchange(14,3)           
    patches =  progchange(47,1)    #new DEFAULT: harp, marimba, vibraphone
     | progchange(13,2)           
     | progchange(14,3)               
    realtime(patches) # initialize default patches
    $.c = []
    $.pname = []

    $.panpos = 63;        # default pan pos (To be implmemented)
    $.Scaleselection = 35 # default scale: AEOLIAN
    $.rootnote = 48       # default base "pitch"
    $.onv1 = 1            # activate voice 1 
    $.onv2 = 1
    $.onv3 = 1
    $.dur1 = 1b
    $.dur2 = 1b
    $.dur3 = 1b
    $.activate_audio = 1  # starts with/without sounds
    $.counter_x_mod = 5   # these set the amount of voice 1,2,3 playing
    $.counter_y_mod = 25
    $.counter_z_mod = 10
    $.phi = 0.0           # camera view for 3D algorithms azimuth
    $.theta = 0.0         # camera view for 3D algorithms elevation  
    $.cosphi = cos($.phi*$.PI/180.0)
    $.sinphi = sin($.phi*$.PI/180.0)
    $.costheta = cos($.theta*$.PI/180.0)
    $.sintheta = sin($.theta*$.PI/180.0)
    # interface elements definition follows:
    $.textsplash = new ktext("K e y C h a o s   -   v 1.0 ")
    $.textsplash.style(NOBORDER)
    $.addchild($.textsplash)
    $.textsplash2 = new ktext("Select a Fractal from \"Music\" menu")
    $.textsplash2.style(NOBORDER)
    $.addchild($.textsplash2)
    $.textsplash3 = new ktext("then press ON")
    $.textsplash3.style(NOBORDER)
    $.addchild($.textsplash3)
    $.onoffbutt = new ktoggle("On",$,"onoff")
    $.addchild($.onoffbutt) 
    $.redrawbutt = new kbutton("Redraw",$,"redr")
    $.addchild($.redrawbutt)        
    $.musicbutt = new kmenubutton("Music","mkmenu_wtr_fract_mus",$)    
    $.addchild($.musicbutt)
    $.displbutt = new kmenubutton("Display","mkmenu_wtr_fract_displ",$)    
    $.addchild($.displbutt)
    $.textspeed = new ktext("Spd")
    $.textspeed.style(NOBORDER)
    $.addchild($.textspeed) 
    $.textdyn = new ktext("Dyn")
    $.textdyn.style(NOBORDER)
    $.addchild($.textdyn)               
    $.textroot = new ktext("Roo")
    $.textroot.style(NOBORDER)
    $.addchild($.textroot)              
    $.textftitle = new ktext("")
    $.textftitle.style(NOBORDER)
    $.addchild($.textftitle)
    $.textdja = new ktext("a")
    $.textdja.style(NOBORDER)
    $.addchild($.textdja)
    $.textdjb = new ktext("b")
    $.textdjb.style(NOBORDER)
    $.addchild($.textdjb)
    $.textdjc = new ktext("c")
    $.textdjc.style(NOBORDER)
    $.addchild($.textdjc)
    $.textdjd = new ktext("d")
    $.textdjd.style(NOBORDER)
    $.addchild($.textdjd)
    $.a_dj_slide = new kslider(-1000,1000,224,$,"set_dja")     # de jong fractal constants can be changed through gui sliders
    $.addchild($.a_dj_slide) 
    $.b_dj_slide = new kslider(-1000,1000,-65,$,"set_djb")    
    $.addchild($.b_dj_slide) 
    $.c_dj_slide = new kslider(-1000,1000,43,$,"set_djc")    
    $.addchild($.c_dj_slide) 
    $.d_dj_slide = new kslider(-1000,1000,-243,$,"set_djd")    
    $.addchild($.d_dj_slide) 
    $.pcch1 = new ktext("V1")
    $.pcch1.style(NOBORDER)
    $.addchild($.pcch1)    
    $.pcch2 = new ktext("V2")
    $.pcch2.style(NOBORDER)
    $.addchild($.pcch2)        
    $.pcch3 = new ktext("V3")        
    $.pcch3.style(NOBORDER)
    $.addchild($.pcch3)        
    $.textaz = new ktext("AZ") # azimuth and elevation sliders for 3D fractals
    $.textaz.style(NOBORDER)
    $.addchild($.textaz)
    $.textel = new ktext("EL")
    $.textel.style(NOBORDER)
    $.addchild($.textel)
    $.azim_slider = new kslider(0,360,45,$,"set_azimtuh")
    $.addchild($.azim_slider)
    $.elev_slider = new kslider(-90,90,30,$,"set_elev")
    $.addchild($.elev_slider)
    $.slide = new kslider(0,100,40,$,"setspeed")    
    $.addchild($.slide) 
    $.slidedyn = new kslider(1,1000,300,$,"setdyn")   
    $.addchild($.slidedyn)  
    $.slideroot = new kslider(30,80,50,$,"setrootnote")   
    $.addchild($.slideroot)                                    
    
    for ( n=1; n<4; n++ ) {
        $.c[n] = new kvalbutton($.pname,$,"valchanged",n)
        $.addchild($.c[n])
    }
    $.pmap = []
    $.setdefaults() 
    for ( n=1; n<4; n++ ) {
        $.c[n].set(0)
    }   
    
    $.setgridsize(1,0) 
    #print("Init Completed")        
    printf(" Ready !\n")    
}
    
method setdefaults() {
    defouts = midi("portmap")[0]
    outnames = midi("output","list")
    for ( n=1; n<4; n++ ) {
        out = defouts[n]
        if ( out in Port2Patchmap )
            pmap = Port2Patchmap[out]
        else
            pmap = patchmap_gm()
        pnames = patchmapnames(pmap)
        $.c[n].setvals(pnames)
        $.c[n].set($.c[n].get())

        $.pmap[n] = pmap
    }
}

method delete {
    kill($.tid)
}
    
method redraw {
    lock($)
    $.w.redraw()
    if ($.fractal_type == 1){ 
        if ($.view == 0)
            $.w.textleft("Henon Map - 2D View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
        else if ($.view == 1)   
            $.w.textleft("Henon Map - X", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))            
        else if ($.view == 2)   
            $.w.textleft("Henon Map - Y", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))            
    }    
    else if ($.fractal_type == 2){    
        if ($.view == 0)
            $.w.textleft("De Jong Fractal - 2D View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
        else if ($.view == 1)
            $.w.textleft("De Jong Fractal - X", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))            
        else if ($.view == 2)
            $.w.textleft("De Jong Fractal - Y", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))                       
    }    
    else if ($.fractal_type == 3){    
        if ($.view == 0)
            $.w.textleft("Rossler Attractor - 3D View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
        else if ($.view == 1)
            $.w.textleft("Rossler Attractor - X View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
        else if ($.view == 2)
            $.w.textleft("Rossler Attractor - Y View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
        else if ($.view == 3)
            $.w.textleft("Rossler Attractor - Z View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))                
    }    
    else if ($.fractal_type == 4){    
        if ($.view == 0)
            $.w.textleft("Hopalong - 2D View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
        else if ($.view == 1)
            $.w.textleft("Hopalong - X View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
        else if ($.view == 2)
            $.w.textleft("Hopalong - Y View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
    }    
    else if ($.fractal_type == 5){    
        if ($.view == 0)
            $.w.textleft("Lorenz Attractor - 3D View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
        else if ($.view == 1)
            $.w.textleft("Lorenz Attractor - X View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
        else if ($.view == 2)
            $.w.textleft("Lorenz Attractor - Y View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
        else if ($.view == 3)
            $.w.textleft("Lorenz Attractor - Z View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))             
    }        
    else if ($.fractal_type == 6){    
        if ($.view == 0)
            $.w.textleft("Duffing Attractor - 2D View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
        else if ($.view == 1)
            $.w.textleft("Duffing Attractor - X View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
        else if ($.view == 2)
            $.w.textleft("Duffing Attractor - Y View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
    }            
    else if ($.fractal_type == 7){    
        if ($.view == 0)
            $.w.textleft("Clifford Attractor - 2D View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
        else if ($.view == 1)
            $.w.textleft("Clifford Attractor - X View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
        else if ($.view == 2)
            $.w.textleft("Clifford Attractor - Y View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
    }            
    else if ($.fractal_type == 8){    
        if ($.view == 0)
            $.w.textleft("Henon Phase Map - 3D View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
        else if ($.view == 1)
            $.w.textleft("Henon Phase Map - X View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
        else if ($.view == 2)
            $.w.textleft("Henon Phase Map - Y View", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
    }            
    methodbroadcast()
    $.resize()
    unlock($)
    #print("Redraw Completed")            
}

method resize(sz) {
    if ( nargs() > 0 )
        $.w.resize(sz)
    $.dy = $.textheight() + 5
    tw = $.textwidth()      
    ym2 = $.ymin() + 2
    $.dx = $.textwidth()*2

    y0  = $.ymin()+$.dy
    gridxmin = $.xmin()
    gridxmax = $.xmax()
    gridymin = $.ymin()+20
    gridymax = $.ymax()
    one_fifth = ($.xmax()-$.xmin())/5     # 1/5 of total width
    one_fifth_d4 = one_fifth / 4          # (1/5) * (1/4)
    one_fifth_d3 = one_fifth / 3          # (1/5) * (1/3)    
    four_fifths = $.xmin() + 4*one_fifth  # four fifths from left wall
    four_fifthsp2 = four_fifths + 2     
    y_one_eight = ($.ymax()-$.ymin())/8   # 1/8 of total height    
    one_eight_y = $.ymin() + y_one_eight

    $.gridsize = xy(gridxmin+4, gridymin+4, four_fifths, gridymax-4) 
    $.grid.resize($.gridsize)
    $.griddx = $.gridsize["x1"] - $.gridsize["x0"]
    $.griddy = $.gridsize["y1"] - $.gridsize["y0"]
    $.griddx_d256 = integer($.griddx / 256)
    if ($.fractal_type != 0) {
        #$.rectangle($.gridsize,CLEAR) # in this way the rectangular contour is not drawn. STORE will draw it
        colorset(1)
        $.rectangle(xy(gridxmin+3, gridymin+3, four_fifths+1, gridymax-3),STORE)
        $.textsplash.resize(xy($.xmin(), $.ymin(), $.xmin()+1, $.ymin()+1))
        $.textsplash.redraw()
        $.textsplash2.resize(xy($.xmin(), $.ymin(), $.xmin()+1, $.ymin()+1))
        $.textsplash2.redraw()
        $.textsplash3.resize(xy($.xmin(), $.ymin(), $.xmin()+1, $.ymin()+1))
        $.textsplash3.redraw()        
        rc = rand(10)+5        
        if ($.bkgcolor == 1){
            c1 = 0
            c2 = 0
            c3 = 0
        } else if ($.bkgcolor == 2){
            c1 = 38400
            c2 = 41984
            c3 = 63232
        } else if ($.bkgcolor == 3) {           
            #colormix(rc,rand(255)*256,rand(255)*256,rand(255)*256)
            c1 = rand(255)*256
            c2 = rand(255)*256
            c3 = rand(255)*256          
        }
        colormix(rc,c1,c2,c3)
        #printf("Color is %f %f %f\n",c1, c2, c3)
        colorset(rc)        
        $.fillrectangle($.gridsize,STORE)
        colorset(1)
    } else {
        $.textsplash.resize(xy($.xmin()+6, $.ymin()+$.griddy/2, $.xmin() + 3*one_fifth, $.ymin()+$.griddy/2+2*$.dy))         
        $.textsplash2.resize(xy($.xmin()+6, $.ymin()+$.griddy/2+3*$.dy, $.xmin() + 3*one_fifth, $.ymin()+$.griddy/2+4*$.dy))         
        $.textsplash3.resize(xy($.xmin()+6, $.ymin()+$.griddy/2+4*$.dy, $.xmin() + 3*one_fifth, $.ymin()+$.griddy/2+5*$.dy))                 
    }    
    $.xm = $.xmin() + ($.xmax()-$.xmin())/3     # one third from left wall
    if ( $.xm < ($.xmax()-28*tw) )
        $.xm = ($.xmax()-28*tw)
    $.xmdx = ($.xmax() - $.xm)/9                # (1/3) * (1/8)
    
    $.onoffbutt.resize(xy($.xmax()-9*$.xmdx, ym2+2, $.xmax()-6*$.xmdx, $.ymin()+$.dy))         
    $.musicbutt.resize(xy($.xmax()-6*$.xmdx+2, ym2+2, $.xmax()-3*$.xmdx, $.ymin()+$.dy))                
    $.displbutt.resize(xy($.xmax()-3*$.xmdx+2, ym2+2, $.xmax()-2, $.ymin()+$.dy))                    
    #$.randbutt.resize(xy($.xm+3*$.xmdx,ym2+2, $.xm+6*$.xmdx-2, $.ymin()+$.dy))  
    if ($.fractal_type != 0) {
        $.redrawbutt.resize(xy($.xmax()-3*$.xmdx+2,$.ymin()+$.dy+2,$.xmax()-2, $.ymin()+2*$.dy))  
        #$.randpchbutt.resize(xy($.xmax()-3*$.xmdx+2,$.ymin()+2*$.dy+2,$.xmax()-2, $.ymin()+3*$.dy))          
        $.c[1].resize(xy($.xmax()-3*$.xmdx+2, $.ymin()+2*$.dy+2,$.xmax()-2,$.ymin()+3*$.dy))
        $.c[2].resize(xy($.xmax()-3*$.xmdx+2, $.ymin()+3*$.dy+2,$.xmax()-2,$.ymin()+4*$.dy))
        $.c[3].resize(xy($.xmax()-3*$.xmdx+2, $.ymin()+4*$.dy+2,$.xmax()-2,$.ymin()+5*$.dy))
        $.pcch1.resize(xy($.xmax()-4*$.xmdx+2, $.ymin()+2*$.dy+2,$.xmax()-3*$.xmdx,$.ymin()+3*$.dy))
        $.pcch2.resize(xy($.xmax()-4*$.xmdx+2, $.ymin()+3*$.dy+2,$.xmax()-3*$.xmdx,$.ymin()+4*$.dy))
        $.pcch3.resize(xy($.xmax()-4*$.xmdx+2, $.ymin()+4*$.dy+2,$.xmax()-3*$.xmdx,$.ymin()+5*$.dy))                    
    }
    #$.scalebutton.resize(xy($.xm+6*$.xmdx, ym2+2, $.xm+9*$.xmdx, $.ymin()+$.dy ))                       
    if (one_eight_y-$.dy > $.ymin()+$.dy)
        starty = one_eight_y-$.dy
    else 
        starty = $.ymin()+$.dy +2   
        
    if (one_eight_y<$.dy)
        $.dy = one_eight_y
        
    if ( ($.fractal_type == 2) || ($.fractal_type == 7) ) {
        $.textdja.resize(xy(four_fifthsp2+4,                   $.ymin()+5*$.dy+2, four_fifthsp2+1*one_fifth_d4,   $.ymin()+6*$.dy))
        $.textdjb.resize(xy(four_fifthsp2+1*one_fifth_d4+4,    $.ymin()+5*$.dy+2, four_fifthsp2+2*one_fifth_d4,   $.ymin()+6*$.dy))
        $.textdjc.resize(xy(four_fifthsp2+2*one_fifth_d4+4,    $.ymin()+5*$.dy+2, four_fifthsp2+3*one_fifth_d4,   $.ymin()+6*$.dy))
        $.textdjd.resize(xy(four_fifthsp2+3*one_fifth_d4+4,    $.ymin()+5*$.dy+2, four_fifthsp2+4*one_fifth_d4-4, $.ymin()+6*$.dy))
        $.a_dj_slide.resize(xy(four_fifthsp2+2,                $.ymin()+6*$.dy+2, four_fifthsp2+1*one_fifth_d4,  starty + 5.4*y_one_eight-2 ))
        $.b_dj_slide.resize(xy(four_fifthsp2+1*one_fifth_d4+2, $.ymin()+6*$.dy+2, four_fifthsp2+2*one_fifth_d4,  starty + 5.4*y_one_eight-2 ))
        $.c_dj_slide.resize(xy(four_fifthsp2+2*one_fifth_d4+2, $.ymin()+6*$.dy+2, four_fifthsp2+3*one_fifth_d4,  starty + 5.4*y_one_eight-2 ))
        $.d_dj_slide.resize(xy(four_fifthsp2+3*one_fifth_d4+2, $.ymin()+6*$.dy+2, four_fifthsp2+3*one_fifth_d3-4,starty + 5.4*y_one_eight-2 ))
    }
    if (($.fractal_type == 3) || ($.fractal_type == 5)){
        $.textaz.resize(xy(four_fifthsp2+4,                     $.ymin()+5*$.dy+2, four_fifthsp2+1*one_fifth_d4,   $.ymin()+6*$.dy))
        $.textel.resize(xy(four_fifthsp2+1*one_fifth_d4+4,      $.ymin()+5*$.dy+2, four_fifthsp2+2*one_fifth_d4,   $.ymin()+6*$.dy))
        $.azim_slider.resize(xy(four_fifthsp2+2,                $.ymin()+6*$.dy+2, four_fifthsp2+1*one_fifth_d4,  starty + 5.4*y_one_eight-2 ))
        $.elev_slider.resize(xy(four_fifthsp2+1*one_fifth_d4+2, $.ymin()+6*$.dy+2, four_fifthsp2+2*one_fifth_d4,  starty + 5.4*y_one_eight-2 ))
    }    
    if ($.fractal_type != 0) {
        $.textspeed.resize(xy(four_fifthsp2,               starty + 6*y_one_eight-$.dy-2, four_fifthsp2+one_fifth_d3, starty + 6*y_one_eight-2)) # resize "Sp"
        $.textdyn.resize(xy(four_fifthsp2+one_fifth_d3+2,  starty + 6*y_one_eight-$.dy-2, four_fifthsp2+2*one_fifth_d3-2, starty + 6*y_one_eight-2)) # resize "Vo"   
        $.textroot.resize(xy(four_fifthsp2+2*one_fifth_d3, starty + 6*y_one_eight-$.dy-2, four_fifthsp2+3*one_fifth_d3-4, starty + 6*y_one_eight-2)) # resize "Ro"       
        $.slide.resize(xy(four_fifthsp2+2,                 starty + 6*y_one_eight, four_fifthsp2+one_fifth_d3,     gridymax-4))   # resize "Sp" slider
        $.slidedyn.resize(xy(four_fifthsp2+one_fifth_d3+2, starty + 6*y_one_eight, four_fifthsp2+2*one_fifth_d3-2, gridymax-4))   # resize "Dy" slider
        $.slideroot.resize(xy(four_fifthsp2+2*one_fifth_d3,starty + 6*y_one_eight, four_fifthsp2+3*one_fifth_d3-4, gridymax-4))   # resize "Ro" slider                  
    }
    if ( ($.fractal_type != 2.0) && ($.fractal_type != 7.0)) 
    {
        # bad trick!. Since textdja has been declared in init and after coming from dejong
        # fractal to another one, the dejong sliders have to be REMOVED (hidden) in some why. 
        # The following redraw the sliders and text in the higher left corner of the window :-)
        # What is a better way to do it ? 
        $.textdja.resize(xy($.xmin()+1, $.ymin(), $.xmin()+2, $.ymin()+1))
        $.textdja.redraw()
        $.textdjb.resize(xy($.xmin()+2, $.ymin(), $.xmin()+3, $.ymin()+1))
        $.textdjb.redraw()        
        $.textdjc.resize(xy($.xmin()+3, $.ymin(), $.xmin()+4, $.ymin()+1))
        $.textdjc.redraw()        
        $.textdjd.resize(xy($.xmin()+4, $.ymin(), $.xmin()+5, $.ymin()+1))
        $.textdjd.redraw()        
        $.a_dj_slide.resize(xy($.xmin()+5, $.ymin(), $.xmin()+6, $.ymin()+1))
        $.a_dj_slide.redraw()        
        $.b_dj_slide.resize(xy($.xmin()+6, $.ymin(), $.xmin()+7, $.ymin()+1))
        $.b_dj_slide.redraw()                
        $.c_dj_slide.resize(xy($.xmin()+7, $.ymin(), $.xmin()+8, $.ymin()+1))
        $.c_dj_slide.redraw()                
        $.d_dj_slide.resize(xy($.xmin()+8, $.ymin(), $.xmin()+9, $.ymin()+1))
        $.d_dj_slide.redraw()                
    }
    if ( ($.fractal_type != 3) && ($.fractal_type != 5)) {      
        # same as above.
        $.textaz.resize(xy($.xmin()+9, $.ymin(), $.xmin()+10, $.ymin()+1))
        $.textel.resize(xy($.xmin()+10, $.ymin(), $.xmin()+11, $.ymin()+1))
        $.azim_slider.resize(xy($.xmin()+12, $.ymin(), $.xmin()+13, $.ymin()+1))
        $.elev_slider.resize(xy($.xmin()+13, $.ymin(), $.xmin()+14, $.ymin()+1))
    }               
    #print("Resize Completed")        
}

method setgridsize(v,doredraw) {
     $.nrows = v
     $.ncols = v
#     $.nrows = 1
#     $.ncols = 2
    if ( $.grid != $0 ) {
        $.removechild($.grid)
        print("setgridsize: removed !")
    }
    deleteobject($.grid)
    $.grid = new wgrid($.ncols,$.nrows)
    $.addchild($.grid)
    $.initballs()   
    if ( doredraw ) {
        print("setgridsize: doredraw")
        $.resize()
        $.redraw()
    }
    #print("Setgridsize Completed")    
}

method initballs() {
    lock($)
    $.ball = []
    for (n=0; n<1;n++) {        
        $.ball[n] = []
        $.ball[n]["on"] = 0
        $.ball[n]["xy"] = -1.0
    }
    #print("InitBalls Completed")
    unlock($)   
}

method drawball(b,mode) {
    status = 0
    if (b["xy"] != -1)
        $.w.fillrectangle(b["xy"],mode)
    else {
        status = 1  # "bad" status
   }
   return(status)
}

method onoff(v) {   
    #lock($)
    #printf("$.tid a %f \n",$.tid)
    if ( v ) {
        if ( $.tid >= 0 )
            kill($.tid)
        $.first = 1         
        if ($.debugprint == 1)
            $.fil = open("c:\\temp\\keychaos.txt","w")            
        if ($.fractal_type == 0){
            printf("First Select a Fractal from Music menu, then ON\n")
            return()
        } else {   
            $.tid = task $.chaos_task()
        }
    } else {
        kill($.tid)
        $.first = 1
        $.tid = -1
        $.xalg = rand(10)/1000.0 # initial conditions 
        $.yalg = rand(10)/1000.0
        $.zalg = rand(10)/1000.0
        $.dynfact = 1.0
        $.dur1 = 1b
        $.dur2 = 1b
        $.dur3 = 1b
        $.onv1 = 1            # activate voice 1 
        $.onv2 = 1
        $.onv3 = 1                
        $.strength = 3     # default "strength" parameter
        $.rootnote = 48
        $.bipolar = 1
        $.slidedyn.set(300)   #  WHY THIS DOES NOT ALWAYS WORK ?
        $.slidedyn.redraw()   #  "    "     "   "     "     " ?
        #printf("$.slidedyn.get() %f \n",$.slidedyn.get())   # reset "Dyn"         
        $.slideroot.set(50)   # reset "Root" slider
        $.slideroot.redraw()  
        #printf("$.slideroot.get() %f \n",$.slideroot.get())   # reset "Root"                 
        # for debug 
        if ($.debugprint == 1)
            close($.fil)
    }
    #print("Onoff Completed")                            
}

method redr() {
    $.resize()
    $.redraw()
} 

method setspeed (v) { $.sleeptm = 100-v }

method setrootnote(v) { 
    # set root note (controls pitch of the generated melody)
    lock($)
    $.rootnote = v
    printf("Root Note is: %f\n",$.rootnote)    
    unlock($) 
}

method setbkgcolorset(v) {
     $.bkgcolor = v 
}

method setdyn(v) { 
    # set the "dynamics" of the music algorithm. 
    #$.dynfact = float(v)*0.0015+0.485    # from 0.5 to 2
    #$.dynfact = float(v)*0.010+0.110     # from 0.1 to 10
    $.dynfact = float(v)*0.0027+0.27      # from ~ 0.3 to 3, linear    
    printf("Musical Dynamic Factor is: %f\n",$.dynfact)
}

# set dejong constants via gui
method set_dja(v){ 
    $.dja = v/100.0
    printf("a = %f\n",$.dja)    
}
method set_djb(v){ 
    $.djb = v/100.0
    printf("b = %f\n",$.djb)    
}
method set_djc(v){ 
    $.djc = v/100.0
    printf("c = %f\n",$.djc)    
}
method set_djd(v){ 
    $.djd = v/100.0
    printf("d = %f\n",$.djd)
}

method set_azimtuh(v){ 
    lock($)     
    $.theta = float(v)
    $.costheta = cos($.theta*$.PI/180.0)
    $.sintheta = sin($.theta*$.PI/180.0)
    printf("Camera azimuth = %f deg. Now Redraw\n",$.theta)
    unlock($)   
}

method set_elev(v){ 
    lock($) 
    $.phi = float(v)
    $.cosphi = cos($.phi*$.PI/180.0)
    $.sinphi = sin($.phi*$.PI/180.0)    
    printf("Camera elevation = %f deg. Now Redraw\n",$.phi)
    unlock($)
}

method set_bipolar(v){ 
    tmp = integer(v)
    if (tmp == 1){ 
        $.bipolar = 1
        printf("Bipolar Note Selection\n")        
    } else { 
        $.bipolar = 0
        printf("Unipolar Note Selection\n")        
    }
}    

method set_duration(u,v){ 
    #printf("set_duration u  %f   v  %f  \n",u,v)
    if (u == 1){ 
        if (v == 0)
            $.dur1 = 1b/4	    
        else if (v == 1)
            $.dur1 = 1b/2
        else if (v == 2)
            $.dur1 = 1b         
        else if (v == 3)
            $.dur1 = 2b                     
    }
    if (u == 2){ 
        if (v == 0)
            $.dur1 = 1b/4	    
        else if (v == 1)
            $.dur2 = 1b/2
        else if (v == 2)
            $.dur2 = 1b         
        else if (v == 3)
            $.dur2 = 2b                     
    }
    if (u == 3){ 
        if (v == 0)
            $.dur1 = 1b/4	    
        else if (v == 1)
            $.dur3 = 1b/2
        else if (v == 2)
            $.dur3 = 1b         
        else if (v == 3)
            $.dur3 = 2b                     
    }        
}    

method select_fractal(v){ 
    $.fractal_type = integer(v)
    if ($.fractal_type == 1){ 
        $.textftitle.set("Henon Map")
        $.redraw()
        $.redraw()
        # Following is the "Algorithm scaling factor". Since each algorithm has
        # its own numerical outcomes, a scaling is necessary for generating 
        # music. This numer is then rescaled by the "Dyn" factor, which sets
        # the "dynamics" (intended in this case as pitch variation). 
        # This number is tuned by trial and errors on musical outcomes.
        #
        $.alg_scal = 12.0
        #printf("Algorithm scaling factor: %f\n",$.alg_scal)        
    }    
    else if ($.fractal_type == 2){    
        $.textftitle.set("De Jong Fract")
        $.redraw()
        $.redraw()
        $.alg_scal = 12.0
        #printf("Algorithm scaling factor: %f\n",$.alg_scal)        
    }    
    else if ($.fractal_type == 3){    
        $.textftitle.set("Rossler Attractor")
        $.redraw()
        $.redraw()
        $.alg_scal = 2.6
        #printf("Algorithm scaling factor: %f\n",$.alg_scal)        
    }    
    else if ($.fractal_type == 4){    
        $.textftitle.set("Hopalong")
        $.redraw()
        $.redraw()
        $.alg_scal = 2.6
        #printf("Algorithm scaling factor: %f\n",$.alg_scal)        
    }    
    else if ($.fractal_type == 5){    
        $.textftitle.set("Lorenz Attractor")
        $.redraw()
        $.redraw()
        $.alg_scal = 1.0
        #printf("Algorithm scaling factor: %f\n",$.alg_scal)        
    }    
    else if ($.fractal_type == 6){    
        $.textftitle.set("Duffing Attractor")
        $.redraw()
        $.redraw()
        $.alg_scal = 4.6
        #printf("Algorithm scaling factor: %f\n",$.alg_scal)        
    } 
    else if ($.fractal_type == 7){    
        $.textftitle.set("Clifford Attractor")
        $.redraw()
        $.redraw()
        $.alg_scal = 8.0
        #printf("Algorithm scaling factor: %f\n",$.alg_scal)        
    }    
    else if ($.fractal_type == 8){    
        # seems not working
        $.textftitle.set("Henon Phase Diagr.")
        $.redraw()
        $.redraw()
        $.alg_scal = 0.6
        #printf("Algorithm scaling factor: %f\n",$.alg_scal)        
    }    
}

method pchange_manager(v) {
    if (v == 1) {
        # returns default GM patches
        patches =  progchange(47,1)    
         | progchange(13,2)           
         | progchange(14,3)           
        realtime(patches)
        printf("Default Patch Selection:\n")         
        printf("patch 47 on channel 1\n")         
        printf("patch 13 on channel 2\n")         
        printf("patch 14 on channel 3\n")         
        printf("...\n")              
        realtime(patches)
    } else if (v == 2) {
        # returns three random GM patches   
        p1 = rand(126)
        p2 = rand(126)
        p3 = rand(126)
        if (p1 == 0) p1 == 1 
        if (p2 == 0) p2 == 1 
        if (p3 == 0) p3 == 1 
        patches =  progchange(p1,1)   # random patches
                 | progchange(p2,2)    
                   | progchange(p3,3)   
    printf("Random Patch Selection:\n")                        
    printf("Playing patch %f on channel 1\n",p1)         
    printf("Playing patch %f on channel 2\n",p2)         
    printf("Playing patch %f on channel 3\n",p3)         
    printf("...\n")              
    realtime(patches)       
    }
}

method setscale(v) {   
    ell_scale_names_fr(v)
    $.Scaleselection = v
}

method act_audio(v) {
    if (v == 1)
        $.activate_audio = 1
    else 
        $.activate_audio = 0  
    methodbroadcast()        
}

method select_drw_colorset(v){
    if (v == 1)
        $.colored = 0
    else if (v == 2)
        $.colored = 1
    else if (v == 3)
        $.colored = 2
    else if (v == 4)
        $.colored = 3
    else if (v == 5)
        $.colored = 4
    else if (v == 6)
        $.colored = 5
    else if (v == 7)
        $.colored = 6
    else if (v == 8)
        $.colored = 7                        
    else if (v == 9)
        $.colored = 8                                
}   

method select_pt_size(v){
    if (v == 0)
        $.ptsize = 0.1
    else if (v == 1)
        $.ptsize = 0.5
    else if (v == 2)
        $.ptsize = 1.0
    printf("Drawing Point Size: %f \n",$.ptsize)    
}   

method select_view(v){
    if (v == 0)
        $.view = 0   # 2D/3D
    else if (v == 1)
        $.view = 1   # X
    else if (v == 2)
        $.view = 2   # Y
    else if (v == 3)
        $.view = 3   # Z
    #printf("View: %f \n",$.view)    
}   

method select_mod_counters(v){
    # this function is in charge of distributing the probability of voice playing 
    if (v == 0) {
        $.strength = 0
        $.counter_x_mod = 7
        $.counter_y_mod = 25
        $.counter_z_mod = 10
    } else if (v == 1) {
        $.strength = 1
        $.counter_x_mod = 5
        $.counter_y_mod = 25
        $.counter_z_mod = 10        
    } else if (v == 2) {
        $.strength = 2
        $.counter_x_mod = 5
        $.counter_y_mod = 15
        $.counter_z_mod = 15
    } else if (v == 3) {
        $.strength = 3
        $.counter_x_mod = 5
        $.counter_y_mod = 10
        $.counter_z_mod = 10
    } else if (v == 4) {
        $.strength = 4
        $.counter_x_mod = 5
        $.counter_y_mod = 5
        $.counter_z_mod = 5
    } else if (v == 5) {
        $.strength = 5  # voices 2 and three always active
        $.counter_x_mod = 3
        $.counter_y_mod = 3
        $.counter_z_mod = 3
    }    
    #printf("Counters x, y, z mod: %f %f %f \n",$.counter_x_mod,$.counter_y_mod,$.counter_z_mod)    
    printf("\n")        
    printf("Strength: %f of 5 \n",$.strength)    
    printf("\n")            
}   

method generatenoteflow(note1,note2,note3) {
    # three-voices note generator
    # would be nice to feed a sound synthesizer like csound or pure data in real time. OSC ? 
    scale = $.Scaleselection     # selected from gui
    root  = $.rootnote           # selected from gui
    ffst  = ffscaletotal(scale)     # Get the number of elements in the scale
    
    if ($.bipolar == 0) {
       note1 = abs(note1)
       note2 = abs(note2)
       note3 = abs(note3)
   }
    #note = rand(ffst)
    if ($.debugprint == 1) {    
        tmp1 = note1
        tmp2 = note2
        tmp3 = note3
    }
    
    note1 = integer(note1*$.alg_scal*$.dynfact)  # the outcome of the algorithm properly scaled
    note2 = integer(note2*$.alg_scal*$.dynfact)  # by $.alg_scal (hardcoded) plus some variation  
    note3 = integer(note3*$.alg_scal*$.dynfact)  # around it from GUI "Dyn" parameter  

    if (abs(note1)>=ffst) {
        noct1=note1/ffst        # To get the octave just divide
        note1=abs(note1)%ffst   # Limit the note to those available in the scale
    } else
        noct1 = 0
    
    if (abs(note2)>=ffst) {
        noct2=note2/ffst        
        note2=abs(note2)%ffst   
    } else
        noct2 = 0

    if (abs(note3)>=ffst) {
        noct3=note3/ffst        
        note3=abs(note3)%ffst   
    } else
        noct3 = 0
    
    #prevent divergency of some algorithm. Allow a maximum of +- 3 octave range
    if (abs(noct1) > 3) 
        noct1 = integer(abs(noct1)/noct1)*3 #zero division is automatically prevented
    if (abs(noct2) > 3) 
        noct2 = integer(abs(noct2)/noct2)*3
    if (abs(noct3) > 3) 
        noct3 = integer(abs(noct3)/noct3)*3
    #printf("noct1 %f, noct2 %f, noct3 %f \n",noct1,noct2,noct3)
    # pitch generation:
    note1 = ffscal(abs(note1), scale) + root + 12*noct1
    note2 = ffscal(abs(note2), scale) + root + 12*noct2
    note3 = ffscal(abs(note3), scale) + root + 12*noct3
#     vel1 = (abs(note1)%4/1+1)*32
#     vel2 = (abs(note2)%4/1+1)*32
#     vel3 = (abs(note3)%4/1+1)*32
    vel1 = (abs(note2)%8/1+1)*16
    vel2 = (abs(note1)%8/1+1)*16
    vel3 = (abs(note3)%8/1+1)*16    
    
    if (note1 > 135) 
        note1 = 135
    if (note2 > 135) 
        note2 = 135
    if (note3 > 135) 
        note3 = 135
    if (note1 < 30) 
        note1 = 30
    if (note2 < 30) 
        note2 = 30
    if (note3 < 30) 
        note3 = 30

    if ($.onv1 == 1)
        #p1 = makenote(note1,dur[0],vel1,1)
        p1 = makenote(note1,$.dur1,vel1,1)
    else                
        p1 = ''
    if ($.onv2 == 1)  
        #p2 = makenote(note2,dur[1],vel2,2)
        p2 = makenote(note2,$.dur2,vel2,2)        
    else                
        p2 = ''             
    if ($.onv3 == 1)
        #p3 = makenote(note3,dur[0],vel3,3)
        p3 = makenote(note3,$.dur3,vel3,2)                
    else                
        p3 = ''
    if ($.debugprint == 1) {
        put($.fil,sprintf("1  %f  %f  %f  %f\n",tmp1,note1,noct1,vel1))
        put($.fil,sprintf("2  %f  %f  %f  %f\n",tmp2,note2,noct2,vel2))            
        put($.fil,sprintf("3  %f  %f  %f  %f\n",tmp3,note3,noct3,vel3))    
    }
    if (rand(2) ==1) 
        out = p1+p2+p3
    else
        out = p1|p2|p3

    realtime(out)
}

#
# main task follows, activated by the "on-off" button  
#
method chaos_task() {  

    tm = Now
    tm = nextquant(tm,$.startquant)
    while ( 1 ) {
        if ( $.sleeptm > 0 ) {
            sync()
            millisleep($.sleeptm)
        }
        if ($.first) {
            $.first = 0            
            col1 = 1
            counter_x = 1
            counter_y = 1
            counter_z = 1
            time = $.gridsize["x0"]
            b0 = $.ball[0]
            b0["xy"] = xy(time-$.ptsize,$.gridsize["y0"]+$.griddy/2,time, $.gridsize["y0"]+$.griddy/2-$.ptsize)
            x0 = $.ball[0]["xy"]["x0"]
            y0 = $.ball[0]["xy"]["y0"]
            drawline = 0

            if ($.fractal_type == 1) {
                # Henon map
                xx = 1.0 - $.alpha * ($.xalg*$.xalg) + $.yalg
                $.yalg  = $.beta * $.xalg
                $.xalg  = xx    
            }
            else if ($.fractal_type == 2) {    
                # DeJong iterative algoritm - limited by [-2 2][-2 2]
                xx  = sin($.dja*$.yalg) - cos($.djb*$.xalg) 
                yy  = sin($.djc*$.xalg) - cos($.djd*$.yalg) 
                $.xalg   = xx        
                $.yalg   = yy        
            }
            else if ($.fractal_type == 3) {    
                # Rossler
                $.xalg = 0.0
                $.yalg = 0.0
                $.zalg = 10.0 
                xalgold = 0.0
                yalgold = 0.0
                zalgold = 0.0
            }
            else if ($.fractal_type == 5) {    
                # Lorenz
                $.xalg = 0.1
                $.yalg = 0.0
                $.zalg = 0.0 
                xalgold = 0.1
                yalgold = 0.0
                zalgold = 0.0      
            }       
            else if ($.fractal_type == 6) {    
                # Duffing
                $.xalg = 0.0
                $.yalg = 0.0
                tim=0.0            
            }
            else if ($.fractal_type == 7) {    
                # Clifford iterative algoritm - bounded by 1+djc*1
                xx  = sin($.dja*$.yalg) + $.djc*cos($.dja*$.xalg) 
                yy  = sin($.djb*$.xalg) + $.djd*cos($.djb*$.yalg) 
                $.xalg   = xx        
                $.yalg   = yy        
            }
            else if ($.fractal_type == 8) {    
                # Henon Phase Diagrams
                xx  = $.xalg * cos($.hpda) - ($.yalg - pow($.xalg,2.0)) * sin($.hpda)
                yy  = $.xalg * sin($.hpda) - ($.yalg - pow($.xalg,2.0)) * cos($.hpda)
                $.xalg   = xx        
                $.yalg   = yy        
            }
        } else { # not first
            if ($.fractal_type == 1) {    
                # henon map
                xx = 1.0 - $.alpha * ($.xalg*$.xalg) + $.yalg
                $.yalg  = $.beta * $.xalg
                $.xalg  = xx
            }
            else if ($.fractal_type == 2) {    
                xx  = sin($.dja*$.yalg) - cos($.djb*$.xalg) 
                yy  = sin($.djc*$.xalg) - cos($.djd*$.yalg) 
                $.xalg   = xx        # Update X
                $.yalg   = yy        # Update Y
            }   
            else if ($.fractal_type == 3) {    
                # runge kutta 4(5) method
                h1 = []
                h2 = []
                h3 = []
                h4 = []
                h1 = rossler_wfr($.xalg,$.yalg,$.zalg)
                h1 = [0=$.h*h1[0], 1=$.h*h1[1], 2=$.h*h1[2]]
                h2 = rossler_wfr($.xalg+h1[0]/2,$.yalg+h1[1]/2,$.zalg+h1[2]/2)
                h2 = [0=$.h*h2[0], 1=$.h*h2[1], 2=$.h*h2[2]]      
                h3 = rossler_wfr($.xalg+h2[0]/2,$.yalg+h2[1]/2,$.zalg+h2[2]/2)
                h3 = [0=$.h*h3[0], 1=$.h*h3[1],2=$.h*h3[2]]          
                h4 = rossler_wfr($.xalg+h3[0],$.yalg+h3[1],$.zalg+h3[2])
                h4 = [0=$.h*h4[0], 1=$.h*h4[1], 2=$.h*h4[2]]  
                xnew = $.xalg + float(1.0/6.0)*(h1[0] + 2*(h2[0] + h3[0]) + h4[0])
                ynew = $.yalg + float(1.0/6.0)*(h1[1] + 2*(h2[1] + h3[1]) + h4[1])
                znew = $.zalg + float(1.0/6.0)*(h1[2] + 2*(h2[2] + h3[2]) + h4[2])  
                $.xalg = xnew
                $.yalg = ynew
                $.zalg = znew
                # camera view: apply rotation in azimuth and elevation (only for 3D attractors)
                xalgold = xnew*$.costheta + ynew*$.sintheta
                yalgold = -xnew*$.cosphi*$.sintheta  +  ynew*$.cosphi*$.costheta  +  znew*$.sinphi
                zalgold = xnew*$.sinphi*$.sintheta - ynew*$.sinphi*$.costheta + znew*$.cosphi
            }
            else if ($.fractal_type == 5) {        
                # runge kutta 4(5) method
                h1 = []
                h2 = []
                h3 = []
                h4 = []
                h1 = lorenz_wfr($.xalg,$.yalg,$.zalg)
                h1 = [0=$.hlrz*h1[0], 1=$.hlrz*h1[1], 2=$.hlrz*h1[2]]
                h2 = lorenz_wfr($.xalg+h1[0]/2,$.yalg+h1[1]/2,$.zalg+h1[2]/2)
                h2 = [0=$.hlrz*h2[0], 1=$.hlrz*h2[1], 2=$.hlrz*h2[2]]      
                h3 = lorenz_wfr($.xalg+h2[0]/2,$.yalg+h2[1]/2,$.zalg+h2[2]/2)
                h3 = [0=$.hlrz*h3[0], 1=$.hlrz*h3[1],2=$.hlrz*h3[2]]          
                h4 = lorenz_wfr($.xalg+h3[0],$.yalg+h3[1],$.zalg+h3[2])
                h4 = [0=$.hlrz*h4[0], 1=$.hlrz*h4[1], 2=$.hlrz*h4[2]]  
                xnew = $.xalg + float(1.0/6.0)*(h1[0] + 2*(h2[0] + h3[0]) + h4[0])
                ynew = $.yalg + float(1.0/6.0)*(h1[1] + 2*(h2[1] + h3[1]) + h4[1])
                znew = $.zalg + float(1.0/6.0)*(h1[2] + 2*(h2[2] + h3[2]) + h4[2])  
                $.xalg = xnew
                $.yalg = ynew
                $.zalg = znew
                # apply rotation in azimuth and elevation (only for 3D attractors)
                xalgold = xnew*$.costheta  +  ynew*$.sintheta
                yalgold = -xnew*$.cosphi*$.sintheta  +  ynew*$.cosphi*$.costheta  +  znew*$.sinphi
                zalgold = xnew*$.sinphi*$.sintheta - ynew*$.sinphi*$.costheta + znew*$.cosphi                
            }                   
            else if ($.fractal_type == 4) {        
                # Hopalong algorithm (from H. Mikelson's "hopasong", corrected hopalong algorithm)          
                if ($.xalg != 0)
                    snx = $.xalg/abs($.xalg)
                else
                    snx = 1
                xx     = $.yalg - snx * sqrt(abs($.hpb*$.xalg-$.hpc))   
                $.yalg = $.hpa - $.xalg                            
                $.xalg = xx                                           
            }
            else if ($.fractal_type == 6) {    # Duffing attractor
                tim += 0.04 # time step. the integration output seems to heavily 
                            # depend by this parameter.
                if (tim > (2*$.PI))
                    tim -= 2*$.PI
                # runge kutta 4(5) method
                h1 = []
                h2 = []
                h3 = []
                h4 = []
                h1 = duffing_wfr($.xalg,$.yalg,tim)
                h1 = [0=$.h*h1[0], 1=$.h*h1[1]]
                h2 = duffing_wfr($.xalg+h1[0]/2,$.yalg+h1[1]/2,tim)
                h2 = [0=$.h*h2[0], 1=$.h*h2[1]]      
                h3 = duffing_wfr($.xalg+h2[0]/2,$.yalg+h2[1]/2,tim)
                h3 = [0=$.h*h3[0], 1=$.h*h3[1]]          
                h4 = duffing_wfr($.xalg+h3[0],$.yalg+h3[1],tim)
                h4 = [0=$.h*h4[0], 1=$.h*h4[1]]  
                xnew = $.xalg + float(1.0/6.0)*(h1[0] + 2*(h2[0] + h3[0]) + h4[0])
                ynew = $.yalg + float(1.0/6.0)*(h1[1] + 2*(h2[1] + h3[1]) + h4[1])
                $.xalg = xnew
                $.yalg = ynew
                # printf("$.xalg %f,$.yalg %f,$.zalg %f\n",$.xalg ,$.yalg,$.zalg)
            }
            else if ($.fractal_type == 7) {    
                # Clifford iterative algoritm - limited by  1 + djc*1
                if (abs($.djc) > 2.5){
                    sign_djc = ($.djc == 0) ? 1 : ($.djc / abs($.djc))                
                    Ccl = sign_djc*2.5
                    #printf("c reset to %f to avoid graphic overflow\n",Ccl)
                } else
                    Ccl = $.djc
                if (abs($.djd) > 2.5){
                    sign_djd = ($.djd == 0) ? 1 : ($.djd / abs($.djd))
                    Dcl = sign_djd*2.5                    
                    #printf("d reset to %f to avoid graphic overflow\n",Ccl)                    
                } else
                    Dcl = $.djd
                
                xx  = sin($.dja*$.yalg) + Ccl*cos($.dja*$.xalg) 
                yy  = sin($.djb*$.xalg) + Dcl*cos($.djb*$.yalg) 
                $.xalg   = xx        
                $.yalg   = yy        
            }
            else if ($.fractal_type == 8) {    
                # Henon Phase Diagrams
                xx  = $.xalg * cos($.hpda) - ($.yalg - pow($.xalg,2)) * sin($.hpda)
                yy  = $.xalg * sin($.hpda) - ($.yalg - pow($.xalg,2)) * cos($.hpda)
                $.xalg   = xx        
                $.yalg   = yy        
            }
        } # end first / not first 

        # draw using proper scaling factors for visualization
        if ($.fractal_type == 1) {             # Henon
            nx1 = ($.griddx/3)*($.xalg + 1.5) + $.gridsize["x0"]
            ny1 = ($.griddy/1.8)*($.yalg + 0.9) + $.gridsize["y0"]
        }        
        else if ($.fractal_type == 2) {        # De Jong
            nx1 = ($.griddx/4)*($.xalg + 2) + $.gridsize["x0"]
            ny1 = ($.griddy/4)*($.yalg + 2) + $.gridsize["y0"]
        }
        else if ($.fractal_type == 3) {        # Rossler
            nx1 = ($.griddx/40)*(xalgold + 20) + $.gridsize["x0"]
            ny1 = ($.griddy/40)*(yalgold + 20) + $.gridsize["y0"]
            nz1 = ($.griddy/40)*(zalgold + 20) + $.gridsize["y0"]
        }
        else if ($.fractal_type == 4) {        # Hopalong
            nx1 = ($.griddx/40)*($.xalg + 20) + $.gridsize["x0"]
            ny1 = ($.griddy/40)*($.yalg + 20) + $.gridsize["y0"]
            # growing fractal. Check boundaries
            if ((nx1 < $.gridsize["x0"]) || (nx1 > $.gridsize["x1"]) || (ny1 < $.gridsize["y0"]) || (ny1 > $.gridsize["y1"])) 
            {   # Reset
                $.first = 1
                $.xalg = 0.1  # initial conditions 
                $.yalg = 0.0
                $.zalg = 0.0
                $.redraw()
            }
        }
        else if ($.fractal_type == 5) {        # Lorenz
            nx1 = ($.griddx/40)*(xalgold/2 + 20) + $.gridsize["x0"]
            ny1 = ($.griddy/40)*(yalgold/2 + 20) + $.gridsize["y0"]
            nz1 = ($.griddy/40)*(zalgold/2 + 20) + $.gridsize["y0"]
        }
        else if ($.fractal_type == 6) {        # Duffing
            nx1 = ($.griddx/3)*($.xalg + 1.5) + $.gridsize["x0"]
            ny1 = ($.griddy/3)*($.yalg + 1.5) + $.gridsize["y0"]
        }
        else if ($.fractal_type == 7) {        # Clifford
            nx1 = ($.griddx/8.0)*($.xalg + 4.0) + $.gridsize["x0"]
            ny1 = ($.griddy/8.0)*($.yalg + 4.0) + $.gridsize["y0"]
        }
        else if ($.fractal_type == 8) {        # Henon ph. map
            nx1 = ($.griddx/3)*($.xalg + 1.5) + $.gridsize["x0"]
            ny1 = ($.griddy/3)*($.yalg + 1.5) + $.gridsize["y0"]
        }

        b0 = $.ball[0]
        if ($.view == 0) 
            b0["xy"] = xy(nx1-$.ptsize,ny1-$.ptsize,nx1,ny1)      
        else if ($.view == 1) { # show X
            time += $.griddx_d256
            if (time > $.gridsize["x1"]) {
               time = $.gridsize["x0"]
               $.redraw()
               drawline = 0
            } else 
               drawline = 1
            b0["xy"] = xy(time-$.ptsize,nx1-$.griddy/2-$.ptsize,time, nx1-$.griddy/2)
        } else if ($.view == 2) { # show Y
            time += $.griddx_d256
            if (time > $.gridsize["x1"]) {
               time = $.gridsize["x0"]
               $.redraw()
               drawline = 0
            } else 
               drawline = 1
            b0["xy"] = xy(time-$.ptsize,ny1-$.ptsize,time, ny1)
        } else if ($.view == 3) {   # show Z only for 3D fractals
            if (($.fractal_type == 5) || ($.fractal_type == 3)){
                time += $.griddx_d256
                if (time > $.gridsize["x1"]) {
                    time = $.gridsize["x0"]
                    $.redraw()
                    drawline = 0
                } else 
                    drawline = 1
                b0["xy"] = xy(time-$.ptsize,nz1-$.griddy/2-$.ptsize,time, nz1-$.griddy/2)
            } 
        }
        # Drawing pen color:
        if ($.colored == 1) {
            rc = 5 + rand(15)
            colormix(rc,55000,rand(5000),rand(5000)) # red
            colorset(rc)
        } else if ($.colored == 2) {
            rc = 5 + rand(15)
            colormix(rc,rand(5000),55000,rand(5000)) # green
            colorset(rc)
        } else if ($.colored == 3) {
            rc = 5 + rand(15)
            colormix(rc,rand(5000),rand(5000),55000) # blue
            colorset(rc)
        } else if ($.colored == 4) {
            rc = 5 + rand(15)
            #colormix(rc,rand(255)*256,rand(255)*256,rand(255)*256) #??
            col1 += 40
            if (col1 > 65535)
              col1 = 1
            colormix(rc,col1,col1,col1) 
            colorset(rc)
        } else if ($.colored == 5) {
            rc = 5 + rand(15)
            col1 += 40
            if (col1 > 65535)
              col1 = 1
            colormix(rc,col1,30000,30000) 
            colorset(rc)
        } else if ($.colored == 6) {
            rc = 5 + rand(15)
            #colormix(rc,rand(255)*256,rand(255)*256,rand(255)*256) #??
            col1 += 40
            if (col1 > 65535)
              col1 = 1
            colormix(rc,30000,col1,30000) 
            colorset(rc)
        } else if ($.colored == 7) {
            rc = 5 + rand(15)
            #colormix(rc,rand(255)*256,rand(255)*256,rand(255)*256) #??
            col1 += 40
            if (col1 > 65535)
              col1 = 1
            colormix(rc,30000,30000,col1) 
            colorset(rc)
        } else if ($.colored == 8) {
            rc = 5 + rand(15)
            #colormix(rc,rand(255)*256,rand(255)*256,rand(255)*256) #??
            col1 += 40
            col2 += 80            
            col2 += 120                        
            if (col1 > 65535)
              col1 = 1
            if (col2 > 65535)
              col2 = 1
            if (col1 > 65535)
              col3 = 1                            
            colormix(rc,col1,col2,col3) 
            colorset(rc)
        }                                
        # Draw point with selected color
        $.drawball(b0,STORE)
                 
        x1 = $.ball[0]["xy"]["x0"]
        y1 = $.ball[0]["xy"]["y0"]
        if (($.view == 1) || ($.view == 2) || ($.view == 3)){
            if (drawline == 1)
                $.line(xy(x0,y0,x1,y1),STORE)
        }
        colorset(1) # reset black        
        
        x0 = $.ball[0]["xy"]["x0"]
        y0 = $.ball[0]["xy"]["y0"]        
        
        if ($.activate_audio == 1) {
        # RANDOMIZE THE VOICE PLAYING 
            counter_x += 1
            counter_y += 1
            counter_z += 1        
            # SET VOICE PLAYING
            if (counter_y%(integer($.counter_y_mod)) == 0) {     # one note every counter_y_mod
                counter_y = 1
                $.onv2 = 1
            } else
                $.onv2 = 0        

            if (counter_z%(integer($.counter_z_mod)) == 0) {     # one note every 10
                counter_z = 1
                $.onv3 = 1
            } else
                $.onv3 = 0
                
            if (counter_x%(integer($.counter_x_mod)) == 0) {
                counter_x = 1
                if ($.strength == 0) {
                    if (rand(4) == 1) 
                        $.generatenoteflow($.xalg,$.yalg,$.zalg) # three voices note generator
                }
                else if ($.strength == 1)  {
                    if (rand(3) == 1) 
                        $.generatenoteflow($.xalg,$.yalg,$.zalg) 
                }
                else if (($.strength == 2) || ($.strength == 3) ) {
                    if (rand(2) == 1)                   
                        $.generatenoteflow($.xalg,$.yalg,$.zalg) 
                }
                else if (($.strength == 4) || ($.strength == 5))  {
                        $.generatenoteflow($.xalg,$.yalg,$.zalg) 
                }
            }
        }
        tm += $.movesize
    }                            # end while(1)
}               

# set of methods borrowed from wprogchx
method setcollection(s,doredraw) {
    if ( s == "" )
        s = "Patchmap"
        
    $.collname = s
    eval "ARR = "+s
    $.collection = ARR
    $.pnames = patchmapnames($.collection)

    for ( n=1; n<4; n++ ) {
        $.c[n].setvals($.pnames)
        $.c[n].set($.c[n].get())
        $.pmap[n] = $.collection
    }
    if ( nargs() > 1 && doredraw )
        $.redraw()
}

method valchanged (v,ch) {

    arr = patchmap_bynum_pmap(v,ch,$.pmap[ch])
    p = arr["patch"]
    $.playthis(p)
}

method playthis(p) {
    realmidi(p,nextquant(Now,$.startquant))
}

} # end class

# ----------- General FUNCTIONS ----------------------------------

function ell_scale_names_fr(v){
# scale names borrowed from H. Mikelson's Hopasong
    ellscale = []
    ellscale[0]  =  "Minor"
    ellscale[1]  =  "Major"
    ellscale[2]  =  "Major chord"
    ellscale[3]  =  "Minor chord"
    ellscale[4]  =  "Min7       "
    ellscale[5]  =  "Sus4       "
    ellscale[6]  =  "Chromatic  "
    ellscale[7]  =  "Blues"
    ellscale[8]  =  "Major pentatonic"
    ellscale[9]  =  "Neapolitan Minor"
    ellscale[10] =  "Neapolitan Major"
    ellscale[11] =  "Oriental"
    ellscale[12] =  "Double harmonic"
    ellscale[13] =  "Enigmatic"
    ellscale[14] =  "Hirajoshi"
    ellscale[15] =  "Hungarian Minor"
    ellscale[16] =  "Hungarian Major"
    ellscale[17] =  "Kumoi"
    ellscale[18] =  "Iwato"
    ellscale[19] =  "Hindu"
    ellscale[20] =  "Spanish 8 Tone"
    ellscale[21] =  "Pelog"
    ellscale[22] =  "Hungarian Gypsy"
    ellscale[23] =  "Major Phrygian"
    ellscale[24] =  "Major Locrian"
    ellscale[25] =  "Lydian Minor"
    ellscale[26] =  "Overtone"
    ellscale[27] =  "Leading Whole Tone"
    ellscale[28] =  "Arabian"
    ellscale[29] =  "Balinese"
    ellscale[30] =  "Gypsy"
    ellscale[31] =  "Mohammedan"
    ellscale[32] =  "Javanese"
    ellscale[33] =  "Persian"
    ellscale[34] =  "Algerian"
    ellscale[35] =  "Aeolian"   
    printf("Now generating on scale %s \n",ellscale[integer(v)]) 
}

function rossler_wfr(x,y,z) {
    # differential equations for the Rossler attractor
    out = []
    out[0] = -y - z
    out[1] = x + $.cra*y
    out[2] = $.crb + z*(x - $.crc)
    return(out)
}

function lorenz_wfr(x,y,z) {
    # differential equations for the Lorenz attractor
    out = []
    out[0] = $.lrza*(y-x)
    out[1] = x*($.lrzb - z)-y
    out[2] = x*y - $.lrzc*z
    #printf("x,y,z %f %f %f \n",z,y,x)
    #printf("out[0],out[1],out[2] %f %f %f \n",out[0],out[1],out[2])
    return(out)
}

function duffing_wfr(x,y,t) {
    # differential equations for the Duffing attractor
    out = []
    out[0] = y        
    out[1] =  x - pow(x,3.0) - $.aduff * y + $.bduff * cos($.wduff*t)
    return(out)
}

# ----------- MENU FUNCTIONS ----------------------------------

function mkmenu_wtr_fract_displ(o,po) {
    o.submenu("Drw Color ->","mkmenu_wtr_fract_drwcol",po)    
    o.submenu("Pt Size ->","mkmenu_wtr_fract_ptsize",po)    
    o.submenu("Bkg Color ->","mkmenu_wtr_fract_bkgcol",po)    
    o.submenu("Display ->","mkmenu_wtr_fract_view",po)
}

function mkmenu_wtr_fract_mus(o,po) {
    o.submenu("Fractal ->","mkmenu_wtr_fract_type",po)  
    o.submenu("Audio   ->","mkmenu_wtr_activate_audio",po)
    o.submenu("Scale   ->","mkmenu_wtr_fract_scale",po)
    o.submenu("Strength ->","mkmenu_wtr_fract_intensity",po)
    o.submenu("Algorithm->","mkmenu_wtr_bipolar",po)    
    o.submenu("Note Length->","mkmenu_wtr_notel",po)        
    o.submenu("Patch Manager->","mkmenu_wtr_def_pchange",po)    
}

function mkmenu_wtr_notel(o,po){
    o.submenu("Voice 1","mkmenu_wtr_set_l1",po)
    o.submenu("Voice 2","mkmenu_wtr_set_l1",po)
    o.submenu("Voice 3","mkmenu_wtr_set_l1",po)    
}

function mkmenu_wtr_fract_scale(o,po,meth) {   
    o.menucmd("Minor",po,"setscale","0")
    o.menucmd("Major",po,"setscale","1")
    o.menucmd("Major chord",po,"setscale","2")
    o.menucmd("Minor chord",po,"setscale","3")  
    o.menucmd("Min7",po,"setscale","4")
    o.menucmd("Sus4",po,"setscale","5")
    o.menucmd("Chromatic",po,"setscale","6")
    o.menucmd("Blues",po,"setscale","7")
    o.menucmd("Major pentatonic",po,"setscale","8")
    o.menucmd("Neapolitan Minor",po,"setscale","9")
    o.menucmd("Neapolitan Major",po,"setscale","10")
    o.menucmd("Oriental",po,"setscale","11")
    o.menucmd("Double harmonic",po,"setscale","12")
    o.menucmd("Enigmatic",po,"setscale","13")
    o.menucmd("Hirajoshi",po,"setscale","14")
    o.menucmd("Hungarian Minor",po,"setscale","15")
    o.menucmd("Hungarian Major",po,"setscale","16")
    o.menucmd("Kumoi",po,"setscale","17")
    o.menucmd("Iwato",po,"setscale","18")
    o.menucmd("Hindu",po,"setscale","19")
    o.menucmd("Spanish 8 Tone",po,"setscale","20")
    o.menucmd("Pelog",po,"setscale","21")
    o.menucmd("Hungarian Gypsy",po,"setscale","22")                                 
    o.menucmd("Major Phrygian",po,"setscale","23")
    o.menucmd("Major Locrian",po,"setscale","24")
    o.menucmd("Lydian Minor",po,"setscale","25")
    o.menucmd("Overtone",po,"setscale","26")
    o.menucmd("Leading Whole Tone",po,"setscale","27")
    o.menucmd("Arabian",po,"setscale","28")                     
    o.menucmd("Balinese",po,"setscale","29")
    o.menucmd("Gypsy",po,"setscale","30")                                   
    o.menucmd("Mohammedan",po,"setscale","31")
    o.menucmd("Javanese",po,"setscale","32")
    o.menucmd("Persian",po,"setscale","33")
    o.menucmd("Algerian",po,"setscale","34")
    o.menucmd("Aeolian",po,"setscale","35") 
}

function mkmenu_wtr_fract_type(o,po,meth) {   
    o.menucmd("Henon (2D)",po,"select_fractal","1")
    o.menucmd("De Jong (2D)",po,"select_fractal","2")
    o.menucmd("Rossler (3D)",po,"select_fractal","3") 
    o.menucmd("Hopalong (2D)",po,"select_fractal","4") 
    o.menucmd("Lorenz (3D)",po,"select_fractal","5")         
    o.menucmd("Duffing (2D)",po,"select_fractal","6")             
    o.menucmd("Clifford (2D)",po,"select_fractal","7")             
    #o.menucmd("Henon Phase Diag (2D)",po,"select_fractal","8")             
}

function mkmenu_wtr_def_pchange(o,po,meth){
    o.menucmd("Default",po,"pchange_manager","1")
    o.menucmd("Random",po,"pchange_manager","2")    
}

function mkmenu_wtr_fract_drwcol(o,po,meth) {
    o.menucmd("Black",po,"select_drw_color","1")
    o.menucmd("Red",po,"select_drw_color","2")
    o.menucmd("Green",po,"select_drw_color","3")
    o.menucmd("Blue",po,"select_drw_color","4")
    o.menucmd("Gradient 1",po,"select_drw_color","5")
    o.menucmd("Gradient 2",po,"select_drw_color","6")
    o.menucmd("Gradient 3",po,"select_drw_color","7")        
    o.menucmd("Gradient 3",po,"select_drw_color","8")            
}

function mkmenu_wtr_fract_ptsize(o,po,meth) {
    o.menucmd("Thick",po,"select_pt_size","0")
    o.menucmd("Medium",po,"select_pt_size","1")
    o.menucmd("Large",po,"select_pt_size","2")
}

function mkmenu_wtr_fract_intensity(o,po,meth) {
    o.menucmd("Strength 0",po,"select_mod_counters","0")
    o.menucmd("Strength 1",po,"select_mod_counters","1")
    o.menucmd("Strength 2",po,"select_mod_counters","2")
    o.menucmd("Strength 3",po,"select_mod_counters","3")
    o.menucmd("Strength 4",po,"select_mod_counters","4")
    o.menucmd("Strength 5",po,"select_mod_counters","5")            
}

function mkmenu_wtr_activate_audio(o,po,meth) {   
    o.menucmd("ON",po,"act_audio","1")
    o.menucmd("OFF",po,"act_audio","2")
}

function mkmenu_wtr_bipolar(o,po,meth){
    o.menucmd("bipolar",po,"set_bipolar","1")
    o.menucmd("unipolar",po,"set_bipolar","0")
}

function mkmenu_wtr_set_l1(o,po,meth){
    o.menucmd("1b/4",po,"set_duration","1","0")	
    o.menucmd("1b/2",po,"set_duration","1","1")
    o.menucmd("1b",po,"set_duration","1","2")
    o.menucmd("2b",po,"set_duration","1","3")        
}

function mkmenu_wtr_set_l2(o,po,meth){
    o.menucmd("1b/4",po,"set_duration","2","0")		
    o.menucmd("1b/2",po,"set_duration","2","1")
    o.menucmd("1b",po,"set_duration","2","2")
    o.menucmd("2b",po,"set_duration","2","3")        
}

function mkmenu_wtr_set_l3(o,po,meth){
    o.menucmd("1b/4",po,"set_duration","3","0")		
    o.menucmd("1b/2",po,"set_duration","3","1")
    o.menucmd("1b",po,"set_duration","3","2")
    o.menucmd("2b",po,"set_duration","3","3")        
}

function mkmenu_wtr_select_gmpatch(o,po) {
    #o.menucmd("General Midi",po,"setcollection","patchmap_gm()")                    
    o.menucmd("General Midi",po,"setcollection","patchmap_gm()")                        
}

function mkmenu_wtr_fract_view(o,po,meth) {
    o.menucmd("2D (3D) View",po,"select_view","0")
    o.menucmd("X",po,"select_view","1")
    o.menucmd("Y",po,"select_view","2")
    o.menucmd("Z",po,"select_view","3")    
}

function mkmenu_wtr_fract_bkgcol(o,po,meth) {
    o.menucmd("Black",po,"setbkgcolor","1")
    o.menucmd("Default",po,"setbkgcolor","2")
    o.menucmd("Random",po,"setbkgcolor","3")
}

