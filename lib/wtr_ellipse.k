class wtr_ellipse {
# 
# PRISONER OF ELLIPSE - V. 1.0 - 
# Generative tool for GM instruments.
# Three voices are used mapped on the first three midi channels.
#
# USE: 
# Place two points within the ellipse and then press "On": the line 
# will start bouncing within the walls. 
# Activate voices (1,2,3) and listen to you midi device.
# When the screen becomes "full" then Redraw (or set $.automatic_redraw to 1).
#
# The wall of the ellipse reflects the line in an always different way 
# depending on initial conditions. Inspired a lot from "Ellipse", "Joyballs" and 
# other tools (a lot of code is adapted from there). 
#
# INSTALL: see wtr_ellipse_install.txt
# DEPENDENCIES: ffscal() and ffscaletotal() from H. Mikelson's hopasong.k
#
# TO DO: 
# - Better characterization of thresholds ($.InOutThreshold, $.WallThreshold)
#
# If you have comments etc. feel free to write to Alberto.Zin@poste.it
#
# Alberto Zin,  2005 
#

     
method init {       
    $.w = new window()
    $.inherit($.w)

    printf("Prisoner of Ellipse  - Starting ...\n")

        $.tid = -1
    $.first = 1
    $.nballs = 0
    $.debugprint = 0
    $.automatic_redraw = 0
    $.startquant = 1b
    $.movesize = 1b/16            # speed of the ball 
    $.fmax = 1000000.0
    $.fdfactor = 13333.0          # amount to multiply dx/dy things by
    $.epsilon = 0.001             # precision for ellipse pixel computations
    $.PI = 3.141592653589793238462
    $.InOutThreshold = 0.2        # threshold for wall crossing
    $.WallThreshold = -0.04       # threshold for bouncing (was -0.05)
    $.grid = $0
    $.sleeptm = 40 
    # initialize default patches
    patches =  progchange(47,1)   # 47: Arp
     | progchange(92,2)           # 92: Pad 6 (metallic)
     | progchange(53,3)           # 53: Voice Oohs  
    realtime(patches)
    $.panpos = 63;                # default pan pos                  
    $.Scaleselection = 1          # default scale
    $.rootnote = 1                # default base "pitch"
    $.overallvol = 95             # default volume for the three MIDI channels
    $.presellast = 0 
    $.onv1 = 0                    # start without sounds
    $.onv2 = 0
    $.onv3 = 0                            
    
    $.onoffbutt = new ktoggle("On",$,"onoff")
    $.addchild($.onoffbutt) 
    $.redrawbutt = new kbutton("Redraw",$,"redr")
    $.addchild($.redrawbutt)        
    $.randbutt = new kbutton("RndPtch",$,"rand_pchange")
    $.addchild($.randbutt)          
    $.scalebutton = new kmenubutton("Scale ","ell_mkmenu_ellscale",$)   
    $.addchild($.scalebutton)                                     
    $.textspeed = new ktext("Spd")
    $.textspeed.style(NOBORDER)
    $.addchild($.textspeed) 
    $.textvol = new ktext("Vol")
    $.textvol.style(NOBORDER)
    $.addchild($.textvol)               
    $.textroot = new ktext("Roo")
    $.textroot.style(NOBORDER)
    $.addchild($.textroot)              
    
    $.textvoices = new ktext("Voices")
    $.textvoices.style(NOBORDER)
    $.addchild($.textvoices)        
    $.textpatch2 = new ktext("Patches")
    $.textpatch2.style(NOBORDER)
    $.addchild($.textpatch2)
                    
    $.preselpatch1 = new ktoggle("1",$,"set_pchange_n")
    $.addchild($.preselpatch1)  
    $.preselpatch2 = new ktoggle("2",$,"set_pchange_n")
    $.addchild($.preselpatch2)  
    $.preselpatch3 = new ktoggle("3",$,"set_pchange_n")
    $.addchild($.preselpatch3)  
    $.preselpatch4 = new ktoggle("4",$,"set_pchange_n")
    $.addchild($.preselpatch4)  
    $.preselpatch5 = new ktoggle("5",$,"set_pchange_n")
    $.addchild($.preselpatch5)  
    $.preselpatch6 = new ktoggle("6",$,"set_pchange_n")
    $.addchild($.preselpatch6)  
      
    $.actv1 = new ktoggle("1",$,"activate_voice1")
    $.addchild($.actv1) 
    $.actv2 = new ktoggle("2",$,"activate_voice2")
    $.addchild($.actv2) 
    $.actv3 = new ktoggle("3",$,"activate_voice3")
    $.addchild($.actv3)                        
        
    $.slide = new kslider(0,100,40,$,"setspeed")    
    $.addchild($.slide) 
    $.slidevol = new kslider(1,127,95,$,"setvol")   
    $.addchild($.slidevol)  
    $.slideroot = new kslider(1,30,1,$,"setrootnote")   
    $.addchild($.slideroot)                                    

    $.setgridsize(1,0)            

    #print("Init Completed")        
}
    
method delete {
    kill($.tid)
}
    
method redraw {
    lock($)
    $.w.redraw()
    $.w.textleft("Prisoner of Ellipse - v 1.0", xy($.xmin(),$.ymin(),$.xm,$.ymin()+$.dy))    
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
    one_fifth_d3 = one_fifth / 3          # (1/5) * (1/3)
    four_fifths = $.xmin() + 4*one_fifth  # four fifths from left wall
    four_fifthsp2 = four_fifths + 2     

    y_one_eight = ($.ymax()-$.ymin())/8   # 1/8 of total height    
    one_eight_y = $.ymin() + y_one_eight
                
    $.gridsize = xy(gridxmin+4, gridymin+4, four_fifths, gridymax-4) 
    $.grid.resize($.gridsize)
    $.griddx = $.gridsize["x1"] - $.gridsize["x0"]
    $.griddy = $.gridsize["y1"] - $.gridsize["y0"]

    $.ellipse($.gridsize)
    
    # uncomment the follwing if you want t see the two focus of the ellipse
    #$.set_focus()    

    $.xm = $.xmin() + ($.xmax()-$.xmin())/3     # one third from left wall
    if ( $.xm < ($.xmax()-28*tw) )
        $.xm = ($.xmax()-28*tw)
    $.xmdx = ($.xmax() - $.xm)/9                # (1/3) * (1/8)
    
    $.onoffbutt.resize(xy($.xm-$.xmdx, ym2+2, $.xm - 2, $.ymin()+$.dy))         
    $.redrawbutt.resize(xy($.xm, ym2+2, $.xm+3*$.xmdx-2, $.ymin()+$.dy))                
    $.randbutt.resize(xy($.xm+3*$.xmdx,ym2+2, $.xm+6*$.xmdx-2, $.ymin()+$.dy))  
    $.scalebutton.resize(xy($.xm+6*$.xmdx, ym2+2, $.xm+9*$.xmdx, $.ymin()+$.dy ))                       
    
    if (one_eight_y-$.dy > $.ymin()+$.dy)
        starty = one_eight_y-$.dy
    else 
        starty = $.ymin()+$.dy +2   
        
    if (one_eight_y<$.dy)
        $.dy = one_eight_y
                
    $.textvoices.resize(xy(four_fifthsp2,           starty,      four_fifthsp2+3*one_fifth_d3-4, starty+$.dy-1))
    $.actv1.resize(xy(four_fifthsp2,                starty+$.dy, four_fifthsp2+one_fifth_d3,     starty + 2*$.dy))                   
    $.actv2.resize(xy(four_fifthsp2+one_fifth_d3+2, starty+$.dy, four_fifthsp2+2*one_fifth_d3-2, starty + 2*$.dy))                  
    $.actv3.resize(xy(four_fifthsp2+2*one_fifth_d3, starty+$.dy, four_fifthsp2+3*one_fifth_d3-4, starty + 2*$.dy))                  
    
    $.textpatch2.resize(xy(four_fifthsp2,                  starty + 2*$.dy+1, four_fifthsp2+3*one_fifth_d3-4, starty + 3*$.dy-1))
    $.preselpatch1.resize(xy(four_fifthsp2,                starty + 3*$.dy, four_fifthsp2+one_fifth_d3,     starty + 4*$.dy-2 ))                  
    $.preselpatch2.resize(xy(four_fifthsp2+one_fifth_d3+2, starty + 3*$.dy, four_fifthsp2+2*one_fifth_d3-2, starty + 4*$.dy-2 ))                  
    $.preselpatch3.resize(xy(four_fifthsp2+2*one_fifth_d3, starty + 3*$.dy, four_fifthsp2+3*one_fifth_d3-4, starty + 4*$.dy-2 ))                  
    $.preselpatch4.resize(xy(four_fifthsp2,                starty + 4*$.dy, four_fifthsp2+one_fifth_d3,     starty + 5*$.dy ))                    
    $.preselpatch5.resize(xy(four_fifthsp2+one_fifth_d3+2, starty + 4*$.dy, four_fifthsp2+2*one_fifth_d3-2, starty + 5*$.dy ))                    
    $.preselpatch6.resize(xy(four_fifthsp2+2*one_fifth_d3, starty + 4*$.dy, four_fifthsp2+3*one_fifth_d3-4, starty + 5*$.dy ))                            

    $.textspeed.resize(xy(four_fifthsp2,               starty + 6*$.dy, four_fifthsp2+one_fifth_d3,     starty + 7*$.dy-1)) # resize "Sp"
    $.textvol.resize(xy(four_fifthsp2+one_fifth_d3+2,  starty + 6*$.dy, four_fifthsp2+2*one_fifth_d3-2, starty + 7*$.dy-1)) # resize "Vo"   
    $.textroot.resize(xy(four_fifthsp2+2*one_fifth_d3, starty + 6*$.dy, four_fifthsp2+3*one_fifth_d3-4, starty + 7*$.dy-1)) # resize "Ro"       
    $.slide.resize(xy(four_fifthsp2,                   starty + 7*$.dy, four_fifthsp2+one_fifth_d3,     gridymax-4))   # resize "Sp" slider
    $.slidevol.resize(xy(four_fifthsp2+one_fifth_d3+2, starty + 7*$.dy, four_fifthsp2+2*one_fifth_d3-2, gridymax-4))   # resize "Vo" slider
    $.slideroot.resize(xy(four_fifthsp2+2*one_fifth_d3,starty + 7*$.dy, four_fifthsp2+3*one_fifth_d3-4, gridymax-4))   # resize "Ro" slider                   
    #print("Resize Completed")        
}

method setgridsize(v,doredraw) {
    $.nrows = v
    $.ncols = v
    if ( $.grid != $0 ) {
        $.removechild($.grid)
        print("setgridsize: removed !")
    }
    deleteobject($.grid)
    $.grid = new wgrid($.ncols,$.nrows)
    $.addchild($.grid)
    $.grid.setcallbackdown($,"gotdown")
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
    for (n=0; n<2;n++) {        
        $.ball[n] = []
        $.ball[n]["on"] = 0
        $.ball[n]["fx"] = -1.0
        $.ball[n]["fy"] = -1.0
        $.ball[n]["dfx"] = 0.0  # from -1 to 1
        $.ball[n]["dfy"] = 0.0  # from -1 to 1  
        
        $.ball[n]["xy"] = -1.0
    }
    #print("InitBalls Completed")
    unlock($)   
}

method updateball(b,nfx,nfy,nx,ny) {
    # width of the point: minimum is 1 pixel
    b["xy"] = xy(nx-1,ny-1,nx,ny)
    b["fx"] = nfx
    b["fy"] = nfy
}

method drawball(b,mode) {
    status = 0
    if (b["xy"] != -1)
        $.w.fillrectangle(b["xy"],mode)
    else {
        print("First set two points within the ellipse, then ON !")
        status = 1                                 # "bad status"
   }
   return(status)     
}

method addball(n,initfx,initfy) {
    b = $.ball[n]
    b["on"] = 1
    bxy = $.fxy2xy(initfx,initfy)
    $.updateball(b,initfx,initfy,bxy["x"],bxy["y"])    
    # The following sets the initial slope of the trajectory (m = dfy/dfx)
    # IT MUST BE A UNIT VECTOR I.E. SQRT(b["dfx"]^2+b["dfy"]^2) = 1 OTHERWISE
    # THE FOLLOWING BOUNCING COMPUTATIONS DO NOT WORK PROPERLY !
    # b["dfx"] = 0.5
    # b["dfy"] = sqrt(1-b["dfx"]*b["dfx"])
    # Random initial slope:
    dx = float(rand(100))/100.0
    dy = sqrt(1-dx*dx)
    if (rand(2) == 0)
        dx = -dx
    if (rand(2) == 0)
        dy = -dy     
    b["dfx"] = dx
    b["dfy"] = dy
    if ($.debugprint > 0){
        printf("addball: initial slope %f %f\n",b["dfx"],b["dfy"])
    }
    $.drawball(b,STORE)
    #print("Addball Completed")                        
}
        
method fxy2xy(fx,fy) {
    return(xy(integer($.gridsize["x0"] + $.griddx * fx / $.fmax),
        integer($.gridsize["y0"] + $.griddy * fy / $.fmax)))
}

method moveballs(n) {
    #
    # This method moves one ball at a time and check for wall impact    
    #
    lock($)
    status = 0
    b = $.ball[n]
    realdfx = b["dfx"] * $.fdfactor 
    nfx = b["fx"] + realdfx
    realdfy = b["dfy"] * $.fdfactor 
    nfy = b["fy"] + realdfy
    # scale nfx,y to size of grid on screen
    nxy = $.fxy2xy(nfx,nfy)
    #$.drawball(b,CLEAR)
    $.updateball(b,nfx,nfy,nxy["x"],nxy["y"])

    smaj = float($.griddx/2)
    smin = float($.griddy/2)
    xpoint = b["xy"]["x0"]
    ypoint = b["xy"]["y0"]
    xleft  = $.gridsize["x0"]
    yleft  = $.gridsize["y0"]
    x = xpoint-(xleft+smaj)
    #
    # keykit natural pixel coordinates are reversed w.r.t to the 
    # definition of cartesian axes
    #
    y = -(ypoint-(yleft+smin))
    x2 = float(x*x)
    y2 = float(y*y)
    a2 = smaj*smaj
    b2 = smin*smin
    #
    # ELLIPSE COLLISION ROUTINE 
    #
    # 1. Obtain the canonical form of the ellipse
    #
    if (x2/a2+y2/b2-1.0 > $.InOutThreshold){           # Single Threshold Mechanism. Sometimes fails.
            print("One or more points outside ellipse.")
            print("Replace the points inside")
            status = 1                                 # "bad status"
            return(status)  
    }
    if (x2/a2+y2/b2-1.0 > $.WallThreshold) {           # Single Threshold Mechanism. Sometimes fails.
        status = 2 # bounce status
        # PAN POSITION IS SET FROM THE WALL BOUNCING
        #$.panpos = 63*(float(x/smaj)+1);        
        #realtime(pannote(1,$.panpos))
        #realtime(pannote(2,$.panpos))
        #realtime(pannote(3,$.panpos))       
        
        #print("----=====----")
        #print("BOUNCING BACK!")
        if (b["dfx"] == 0.0)
            b["dfx"] = 0.000001
        m_inc = -b["dfy"]/b["dfx"]
        if (m_inc == 0.0) m_inc = 0.000001
        #
        # 2. Compute the tangent to the ellipse in (xpoint,ypoint)
        # mt: slope of the tangent to the ellipse in (xpoint,ypoint)
        # mn: slope of the normal to the tangent to the ellipse in (xpoint,ypoint)
        # m_inc: slope of the incoming trajectory (minus because ypixel == -ycart)      
        #
        if (abs(x) < $.epsilon) {
            if (x > 0.0)
                x = $.epsilon   
            else
                x = -$.epsilon 
        }           
        if (abs(float(x - smaj)) < $.epsilon) {
            if (x > 0.0)
                x = smaj - $.epsilon    
            else
                x = $.epsilon - smaj    
        }
        # 3. The following if handles normal and particular cases (x~a && y ~ 0) - 
        if (abs(y)/smin > 0.2) {
            #print("Normal case entered")
            a2mx2 = a2-x2
            mt = - (x*y)/a2mx2
            if (abs(mt) > 14.1014)    # atan(1.5) threshold
                mn = 0.001
            else    
                mn = -1/mt                                  
            alpha =  atan(m_inc)
            if ($.debugprint > 0){
                printf("x, y, a2mx2, a2, x2 %f %f %f %f %f\n",x, y, a2mx2,a2, x2)               
                printf("atan(m_inc), atan(mt), atan(mn) [deg] %f %f %f\n",atan(m_inc)*180/$.PI,atan(mt)*180/$.PI,atan(mn)*180/$.PI)
                printf("m_inc, mn  %f %f\n",m_inc,mn)                
            }
            #
            # 5. rotate vn by beta in the correct direction
            #
            delta = atan(mn)
            vnx = cos(delta) 
            vny = sin(delta)
            # OUTER UNIT VECTOR
            if (x < 0) {  
                vnx = - vnx
                vny = - vny
            }
            #angle_n = atan(vny/vnx)*180.0/$.PI
            #printf("vnx, vny, angle: %f %f %f\n",vnx,vny, angle_n)
            vix = b["dfx"]
            viy = -b["dfy"]
            #angle_i = atan(viy/vix)*180.0/$.PI
            #printf("vix, viy, angle: %f %f %f\n",vix,viy,angle_i)            
            # beta: angle between incoming direction and normal to the ellipse 
            # is always between -PI/2 and +PI/2 -> can use atan.  
            # Same angle between normal and leaving direction 
            cosbeta = vix*vnx + viy*vny
            beta = acos(cosbeta)            

            vrx =  cos(beta)*vnx + sin(beta)*vny
            vry = -sin(beta)*vnx + cos(beta)*vny
            
            if (abs(vrx - vix) < 0.1) { 
                # WOOPS ! wrong rotation has been done. Reset beta
                # and carry out the opposite rotation :-)
                beta = -beta
                vrx =  cos(beta)*vnx + sin(beta)*vny
                vry = -sin(beta)*vnx + cos(beta)*vny
            }
            
            vrx_inner = -vrx 
            vry_inner = -vry 
            b["dfy"] = -vry_inner  # return to pixel coordinates
            b["dfx"] = vrx_inner 

        } else {   # particular cases (x~a && y ~ 0) 
            #print("Particular case entered")
            xnew =  y
            ynew = -x
            mt = - (xnew*ynew)/(b2-xnew*xnew)
            if (abs(mt) < $.epsilon) mt = 0.000001          
            mn = -1/mt
            m_inc = -1.0/m_inc
            tgbeta = (mn - m_inc)/(1 + mn*m_inc)
            beta  =  atan(tgbeta)   
            delta = -atan(mn)
            # 4. rotate vn by beta in the correct direction
            vnx = cos(delta) 
            vny = sin(delta)

            if (y > 0){
                vrx = cos(beta)*vnx+sin(beta)*vny
                vry = -sin(beta)*vnx+cos(beta)*vny     
                b["dfy"] =  vrx 
                b["dfx"] = -vry
            } else {
                vrx = cos(beta)*vnx+sin(beta)*vny
                vry = -sin(beta)*vnx+cos(beta)*vny             
                b["dfy"] = - vrx 
                b["dfx"] = vry 
            }           
        } # end particular case

        realdfx = b["dfx"] * $.fdfactor 
        nfx = b["fx"] + realdfx
        realdfy = b["dfy"] * $.fdfactor 
        nfy = b["fy"] + realdfy
        # scale nfx,y to size of grid on screen
        nxy = $.fxy2xy(nfx,nfy)
        #$.drawball(b,CLEAR)
        # 6. Redraw ball with correct leaving angle.
        $.updateball(b,nfx,nfy,nxy["x"],nxy["y"])       
    }
    # show or not the balls at the edges of the line
    #$.drawball(b,STORE)    
    $.drawball(b,CLEAR) 
    unlock($)
    return(status)  
}

method gotdown(m) {
    # Use the mouse to add a ball:
    lock($)
    initfx = (m["x"] - $.gridsize["x0"]) * $.fmax / $.griddx
    initfy = (m["y"] - $.gridsize["y0"]) * $.fmax / $.griddy
    $.nballs = $.nballs + 1
    if (($.nballs%2) == 0)
        n = 0
    else            
        n = 1
    $.addball(n,initfx,initfy)
    unlock($)
    #print("Gotdown Completed")                        
}

method onoff(v) {   
    lock($)
    if ( v ) {
        if ( $.tid >= 0 )
            kill($.tid)
        $.first = 1         
        #$.onoffbutt.redraw()
        $.tid = task $.ellbou_task()
    } else {
        kill($.tid)
        $.first = 1
        $.tid = -1
        #$.onoffbutt.redraw()
    }
    unlock($)
    #print("Onoff Completed")                            
}

method redr() {
    $.resize()
    $.redraw()
}

method set_focus() {
        #
        # Computes the position of the focus points of the ellipse.
        # This method has to be called after setting the gridsize
        #
        smaj = float($.griddx/2)
        smin = float($.griddy/2)    
        a2 = smaj*smaj
        b2 = smin*smin
        xleft  = $.gridsize["x0"]
        yleft  = $.gridsize["y0"]
        xright  = $.gridsize["x1"]
        yright  = $.gridsize["y1"]      
        if ((a2-b2)>0)
            c = sqrt(a2-b2)         
        else
            c = sqrt(b2-a2)                     
            
        nx1 = (xleft+smaj)+c
        ny1 = (yleft+smin)
        nx2 = (xleft+smaj)-c
        ny2 = (yleft+smin)      
        
        b0 = $.ball[0]
        b1 = $.ball[1]
        b0["xy"] = xy(nx1-1,ny1-1,nx1,ny1)      
        b1["xy"] = xy(nx2-1,ny2-1,nx2,ny2)
        $.drawball(b0, STORE)
        if ($.debugprint > 0){  
            print("ball b0 drawn with xleft, yleft, xright, yright,nx1, ny1, c", xleft, yleft, xright, yright,nx1, ny1, c)
        }           
        $.drawball(b1, STORE)
        if ($.debugprint > 0){  
            print("ball b1 drawn with b1[xy]",b1["xy"])
        }           
}

method setspeed (v) { $.sleeptm = 100-v }

#method setch(v) { 
#       # set chorus for all the three midi channels    
#       p1 = midibytes( 0xb0, 93, v ) 
#       p2 = midibytes( 0xb0+1, 93, v ) 
#       p3 = midibytes( 0xb0+2, 93, v )                         
#       realtime(p1+p2+p3)
#}

#method setreverbtime (v) { 
#       # set reverb for all the three midi channels
#       p1 = midibytes( 0xb0 , 91, v ) 
#       p2 = midibytes( 0xb0 + 1, 91, v ) 
#       p3 = midibytes( 0xb0 + 2, 91, v )               
#       realtime(p1+notep2+p3)
#}

method setrootnote(v) { 
# set root note (controls pitch of the generated melody)
        lock($)
        $.rootnote = v
        unlock($) 
}

method setvol(v) { 
# set overall volume
        $.overallvol = v
}

method rand_pchange () { 
    
    p1 = rand(126)
    p2 = rand(126)
    p3 = rand(126)
    if (p1 == 0) p1 == 1 
    if (p2 == 0) p2 == 1 
    if (p3 == 0) p3 == 1 
    
    patches =  progchange(p1,1)   # random patches
             | progchange(p2,2)    
             | progchange(p3,3)   

    printf("Playing patch %f on channel 1\n",p1)         
    printf("Playing patch %f on channel 2\n",p2)         
    printf("Playing patch %f on channel 3\n",p3)         
    printf("...\n")              

    realtime(patches)
}

method set_pchange_n () {   
    lock($)
    # first take care of GUI. Probably there is a better way to do the following :-)
    v1 = $.preselpatch1.get()    
    if (v1 == 1 && $.presellast != 1) {
        $.preselpatch1.set(1)        
        $.preselpatch2.set(0)
        $.preselpatch3.set(0)
        $.preselpatch4.set(0)
        $.preselpatch5.set(0)
        $.preselpatch6.set(0)                                                
        $.presellast = 1                                                
    }   
    v2 = $.preselpatch2.get()    
    if (v2 == 1 && $.presellast != 2) {
        $.preselpatch1.set(0)        
        $.preselpatch2.set(1)
        $.preselpatch3.set(0)
        $.preselpatch4.set(0)
        $.preselpatch5.set(0)
        $.preselpatch6.set(0)    
        $.presellast = 2                                                        
    }   
    v3 = $.preselpatch3.get()      
    if (v3 == 1 && $.presellast != 3) {
        $.preselpatch1.set(0)        
        $.preselpatch2.set(0)
        $.preselpatch3.set(1)
        $.preselpatch4.set(0)
        $.preselpatch5.set(0)
        $.preselpatch6.set(0)    
        $.presellast = 3                                                        
    }   
    v4 = $.preselpatch4.get()      
    if (v4 == 1 && $.presellast != 4) {
        $.preselpatch1.set(0)        
        $.preselpatch2.set(0)
        $.preselpatch3.set(0)
        $.preselpatch4.set(1)
        $.preselpatch5.set(0)
        $.preselpatch6.set(0)    
        $.presellast = 4                                                        
    }   
    v5 = $.preselpatch5.get()      
    if (v5 == 1 && $.presellast != 5) {
        $.preselpatch1.set(0)        
        $.preselpatch2.set(0)
        $.preselpatch3.set(0)
        $.preselpatch4.set(0)
        $.preselpatch5.set(1)
        $.preselpatch6.set(0) 
        $.presellast = 5                                                        
    }   
    v6 = $.preselpatch6.get()         
    if (v6 == 1 && $.presellast != 6) {
        $.preselpatch1.set(0)        
        $.preselpatch2.set(0)
        $.preselpatch3.set(0)
        $.preselpatch4.set(0)
        $.preselpatch5.set(0)
        $.preselpatch6.set(1) 
        $.presellast = 6                                                        
    }   
    
    $.preselpatch1.redraw()     
    $.preselpatch2.redraw()     
    $.preselpatch3.redraw()     
    $.preselpatch4.redraw()     
    $.preselpatch5.redraw()             
    $.preselpatch6.redraw()           
    
    ret = ell_preset_patches($.presellast)
    
    patches =  progchange(ret[0],1)   # pre-selected patches
             | progchange(ret[1],2)   # 
             | progchange(ret[2],3)   #
             
    printf("Playing patch %f on channel 1\n",ret[0])         
    printf("Playing patch %f on channel 2\n",ret[1])         
    printf("Playing patch %f on channel 3\n",ret[2])         
    printf("...\n")    
                   
    realtime(patches)
    unlock($)
}
method setscale(v) {   
    ell_scale_names(v)
    $.Scaleselection = v
}
    
method activate_voice1(v) {
    if (v == 1)
        $.onv1 = 1
    else 
        $.onv1 = 0
    methodbroadcast()
}

method activate_voice2(v) {
    if (v == 1)
        $.onv2 = 1
    else 
        $.onv2 = 0  
    methodbroadcast()        
}   

method activate_voice3(v) {
    if (v == 1)
        $.onv3 = 1
    else 
        $.onv3 = 0  
    methodbroadcast()        
}   
 
method generatenoteflow() {
    
    # three-voices note generator
    # would be fine to feed in real time a sound synthesizer like csound or pure data
    # in order to have more control on sound parameters 

    scale = $.Scaleselection     # selected from gui
    root  = $.rootnote           # selected from gui
    ffst=ffscaletotal(scale)     # Get the number of elements in the scale
    note = rand(ffst)
    if (note>=ffst)                           
    {
        noct=note/ffst             # To get the octave just divide
        note=note%ffst             # Limit the note to those available in the scale
    }
    else
        noct = 1    

    dur = []
    dur = [0="1b", 1="2b", 2="3b", 3="4b", 4="5b", 5="6b"]   
    #printf("before makenote: %f %f %f\n",$.onv1, $.onv2, $.onv3)            
    # Three notes having the same pitch with different patch; 
    if ($.onv1 == 1)
        p1 = makenote(ffscal(note, scale)+root+12*noct+40,dur[rand(6)],$.overallvol,1)
    else                
        p1 = ''
        
    if ($.onv2 == 1)  
        p2 = makenote(ffscal(note, scale)+root+12*noct+40,dur[rand(6)],$.overallvol,2)
    else                
        p2 = ''             

    if ($.onv3 == 1)
        p3 = makenote(ffscal(note, scale)+root+12*noct+40,dur[rand(6)],$.overallvol,3)
    else                
        p3 = ''

    if (rand(2) == 1)
    {
        case1 = p1+p2+p3
        realtime(case1)             
    }
    else
    {
        case2 = p1|p2|p3
        realtime(case2)
    }
}               

#
# main task follows, activated by the "on-off" button  
#
method ellbou_task() {  
    if (debugprint > 0)
        print("EllBounce1 task start")
    tm = Now
    tm = nextquant(tm,$.startquant)
    while ( 1 ) {
        if ( $.sleeptm > 0 ) {
            sync()
            millisleep($.sleeptm)
        }
        if ($.automatic_redraw == 1){
            if ((tm%1000) == 0) {
                $.redr()
                #printf("tm, (tm%1000) %f %f\n",tm, tm%1000)
            }
        }
        if ($.first) {
            $.first = 0
            #status001 = $.drawball($.ball[0],CLEAR)
            status001 = $.drawball($.ball[0],STORE)
            if (status001 == 1){ 
                 return()
            }                   
            #status002 = $.drawball($.ball[1],CLEAR)
            status002 = $.drawball($.ball[1],STORE)
            if (status002 == 1){ 
                 return()
            }                               
            x0 = $.ball[0]["xy"]["x0"]
            y0 = $.ball[0]["xy"]["y0"]
            x1 = $.ball[1]["xy"]["x0"]
            y1 = $.ball[1]["xy"]["y0"]          
            #$.line(xy(x0,y0,x1,y1),CLEAR)
            $.line(xy(x0,y0,x1,y1),STORE)
        }
        status0 = $.moveballs(0)
        if (status0 == 1){ 
            return()
        }       
        status1 = $.moveballs(1)
        if (status1 == 1){ 
            return()
        }
                
        x0 = $.ball[0]["xy"]["x0"]
        y0 = $.ball[0]["xy"]["y0"]
        x1 = $.ball[1]["xy"]["x0"]
        y1 = $.ball[1]["xy"]["y0"]

        if ((status0 == 2) || (status1 == 2)){ 
            # bouncing
            l_length = sqrt((x1-x0)*(x1-x0) + (y1-y0)*(y1-y0))
            smaj = float($.griddx/2)        
            #
            # Trigger a MIDI event here: volume based on length of the line
            #
            if (debugprint > 0)
                  printf("l_length, 2*smaj: %f %f %f %f %f %f\n",l_length,2*smaj, x1, x0, y1, y0)
            duration = l_length/(2*smaj)   # nomalized length of line w.r.t. major axis
            vol = duration*127          
            #printf("l_length, 2*smaj, duration: %f %f %f \n",l_length, 2*smaj, duration)
            #printf("before generatenoteflow: onv1, onv2, onv3 %f %f %f\n",$.onv1,$.onv2,$.onv3)
            $.generatenoteflow()
        }                   
                        
        x0old = x0
        x1old = x1
        y0old = y0
        y1old = y1          
        #$.line(xy(x0,y0,x1,y1),XOR)                
        $.line(xy(x0,y0,x1,y1),STORE)               
        tm += $.movesize
    }
}               

} # end class

function ell_scale_names(v){
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
 
function ell_preset_patches(v){
    
    # set here your favourite patches
    v = v-1
    good_patch = []
    good_patch[0] = [0=79, 1=14, 2=29]
    good_patch[1] = [0=50, 1=89, 2=27]
    good_patch[2] = [0=2,  1=70, 2=64]
    good_patch[3] = [0=64, 1=65, 2=53]
    good_patch[4] = [0=47, 1=51, 2=61]
    good_patch[5] = [0=71, 1=11, 2=12]
    
    return( good_patch[v] )
    
}

function ell_mkmenu_ellscale(o,po,meth) {   
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


