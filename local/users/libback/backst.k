# style
# processes commands relating to styles
# currently 
#  l (load)  completely resets all style setting
#  a (add)   add to current style setting
#           = p{phrase file path}<index|size>name:0-s|d
#           = m{midi file path}<index|size>name[:tracknum-s,tracknum-s...,tracknum-d...]
#             index is steps of size, size is in bars
#  r (remove) = styletrack,styletrack,...
#    removes a styletrack
#  m (modify) = styletrack:p-xx,v-xx,k-{see stylekit for actions}
function style( commandstr )
{
origcommand = commandstr
thecommand = substr (commandstr, 1, 1)
if (thecommand == "l" || thecommand == "a")
  #adding and loading are nearly identical
  {
  if (thecommand == "l")
    {
    # initialise style
    Currentstyle = [] 
    Currentdrum = []
    # delete any empty tracks
    for (i in Styleout)
      {
      if (onlynotes(Styleout [i]) == '')
        {
        freechannel (Styleout[i].channel)
        delete Styleout [i]
        }
      }
    }
  commandstr = strsplit (commandstr, "=")["post"]
  #extract the file type (p(hrase) or m(idi)
  styletype = strsplit (commandstr, "{")["pre"]
  commandstr = strsplit (commandstr, "{")["post"]
  #extract the path name
  stylepath = strsplit (commandstr, "}<")["pre"]
  commandstr = strsplit (commandstr, "}<")["post"]
  styleindex = strsplit (commandstr, "|")["pre"]
  commandstr = strsplit (commandstr, "|")["post"]
  stylesize =  strsplit (commandstr, ">")["pre"]
  commandstr = strsplit (commandstr, ">")["post"]
  stylename = strsplit (commandstr, ":")["pre"]
  thetracks = strsplit (commandstr, ":")["post"]


  #check essential elements, default nonessentials
  if (styletype == "" || stylepath == "" || styleindex == "" || stylesize == "")
    {
    print ("style command error in ", origcommand)
    return (0)
    }
  
  styleindexi = (integer (styleindex) -1)* stylesize
  if (styletype == "p")
    { #read a phrase
    temp = []
    temp [1] = readph (stylepath)
    if (thetracks == "")
      thetracks = "1-s"
    } 
  if (styletype == "m")
    {
    instyles = midifile (stylepath)
    temp = []
    for (i in instyles)
      {
      temp[i] = cut ( instyles[i], CUT_TIME, styleindexi * (Beatsperbar*ClicksperBeat), (styleindexi * (Beatsperbar*ClicksperBeat)) + ((Beatsperbar*ClicksperBeat)*stylesize), TRUNCATE) 
      temp[i].time -= styleindexi*(Beatsperbar*ClicksperBeat)
      }
    if (thetracks == "")
      thetracks = "1-s,2-s,3-s,4-s,5-s,6-s,7-d,8-d"
    }
  styleadd (temp,thetracks, stylename, stylesize)  
  }# thecommand == "l" || thecommand == "a"
if (thecommand == "r")
  {
  commandstr = strsplit (commandstr, "=")["post"]
  if (commandstr == "")
    {
    print ("style command error in ", origcommand)
    return (0)
    }

  #extract the tracknames and delete
  done = 0
  while ( commandstr != "" )
    {
    trackname = strsplit ( commandstr, ",")["pre"]
    commandstr = strsplit ( commandstr, ",")["post"]

    if ( trackname in Currentstyle)
      {
      delete Currentstyle [trackname]
      }
    if ( trackname in Currentdrum)
      {
      delete Currentdrum [trackname]
      }
    }
  }#thecommand == "r"
if ( thecommand == "m")
  {
  commandstr = strsplit (commandstr, "=")["post"]
  done = modstyle (commandstr)
  }#thecommand == "m"  
return (1)
}#style

# initstyle initialises the system
function initstyle ()
{
#load builtin styles
#initialise out
Channels = []
Styleout = []
Trackout = []
Drumout = []
#initialise current
Currentstyle = []
Currentdrum = []

Beatsperbar = 4
Timesig = "4/4"

Drumout [0] = ''
Outpos = 0
Offset = 0
ClicksperBeat = Clicks
# default tempo = 100
styletempo (100)
# default style = "01"
style ("sl=m{alla.mid}<1|2>8beat")
} #initstyle


# styleadd
# adds the phrases stored in multiph controlled by trackstr
function styleadd ( multiph, trackstr, name , size)
{
while (trackstr != "")
 {
 current = strsplit (trackstr, ",")["pre"]
 trackstr = strsplit (trackstr, ",")["post"]

 itrack = strsplit ( current, "-")["pre"]
 ttype = strsplit (current, "-")["post"]
 thetrack = name + "-" + itrack
 if (ttype == "s")
   {
   if ( onlynotes (multiph[integer(itrack)]) != '')
     {
     if (! thetrack in Styleout )
       {
       if (sizeof (Styleout) == 0)
         Styleout = []
       Styleout[thetrack] = ''
       newchannel = getchannel (thetrack)
       Styleout[thetrack] += gmresetch (newchannel)
       Styleout[thetrack] += patchchange (1,newchannel)
       }
     else 
       {
       newchannel = Styleout [thetrack].channel
       }
     Styleout[thetrack].length = (Outpos * ClicksperBeat) 
     controlph = multiph[integer(itrack)]{??.type == PROGRAM || ??.type == CONTROLLER}
     if (controlph == '')
       controlph = patchchange (1, 1)
     outcontrolph = rechannel(controlph, newchannel)
     outcontrolph.length = 1
     outcontrolph.time = 1
     Styleout[thetrack] += outcontrolph
     Currentstyle [thetrack] = multiph [integer(itrack)] - controlph
     Currentstyle [thetrack].length = Beatsperbar * ClicksperBeat * size
     Currentstyle [thetrack].channel = Styleout[thetrack].channel
     }
   }
 if (ttype == "d")
   {
   if (! thetrack in Drumout)
      {
      Drumout[thetrack] = ''
      Drumout[thetrack].channel = 10
      }
   Drumout[thetrack].length = Outpos * ClicksperBeat
   controlph = nonnotes (multiph[integer(itrack)])
   controlph.channel = 10
   Drumout[thetrack] += controlph
   Currentdrum [ name + "-" + itrack] = onlynotes (multiph [integer(itrack)])
   Currentdrum [thetrack].length = Beatsperbar * ClicksperBeat*size
   Currentdrum [thetrack].channel = 10
   }
 }
}# styleadd

# styletempo
# sets the tempo now to the value specified over the number of beats
# ie 50-16 changes the speed to 50 beats per minute over the next 16 beats
function styletempo ( newspeedcmd )
{
n = strindex ( string(newspeedcmd), "-")
if ( n == -1 )
  {
  speed = integer(newspeedcmd)
  thetempo = (60000000/speed)
  Currentspeed = speed
  oldpatch = cut (Drumout[0], CUT_TIME, (Outpos * ClicksperBeat) - (ClicksperBeat /8), (Outpos * ClicksperBeat) + (ClicksperBeat /8))
  Drumout [0] -= oldpatch
  Drumout[0].length = (Outpos * ClicksperBeat) 
  x = "'" + ascii(34) + "Tempo=" + string(thetempo)+ ascii(34)+"'"

  Drumout[0] += phrase (x)
  }
else
  {
  speed = substr (newspeedcmd, 1, n-1)
  thecount = substr (newspeedcmd, n+1, sizeof (newspeedcmd) - n )
  delta = (speed-Currentspeed)/(integer(thecount))
  for (i = 0.5;i <= thecount; i += 0.5)
    {
    thisspeed = (i * delta ) + Currentspeed
    thetempo = integer(60000000/thisspeed)
    Drumout[0].length = (Outpos + i) * ClicksperBeat
    x = "'" + ascii(34) + "Tempo=" + string(thetempo)+ ascii(34)+"'"
    Drumout[0] += phrase (x)
    }
  Currentspeed = thetempo
  }
}


function modstyle ( acommand )
{
trackname = strsplit (acommand, ":")["pre"]
acommand = strsplit (acommand, ":")["post"]
if (trackname == "" || acommand == "")
  {
  print ("style command error in ", acommand)
  return (0)
  }
#extract the mods and delete
done = 0
while ( acommand != "" )
  {
  modstr = strsplit ( acommand, ",")["pre"]
  acommand = strsplit ( acommand, ",")["post"]
  modcmd = strsplit (modstr, "-")["pre"]
  modinfo = strsplit (modstr, "-")["post"]

  if (modcmd == "p")
    # generate a patch command
    {
    done = stylepatch (trackname,modinfo)
    }# modcmd == "p"
    if (modcmd == "v")
    {
    done = stylevol (trackname, modinfo)
    } # modcmd == "v"
    if (modcmd == "k")
      {
      done = stylekit (trackname, modinfo)
      }
  } # while
  return (1)
} # modstyle


# stylepatch
# inserts a patch into a track
function stylepatch (thetrack,apatch)
{
if (thetrack in Styleout)
  {
  Styleout [thetrack].length = Outpos * ClicksperBeat
  # subtract any patches in range
  oldpatch = cut (Styleout[thetrack], CUT_TIME, (Outpos * ClicksperBeat) - (ClicksperBeat /8), (Outpos * ClicksperBeat) + (ClicksperBeat/8))
  oldpatch = oldpatch{??.type == PROGRAM}
  Styleout [thetrack] -= oldpatch
  chph = patchchange (integer(apatch), tellchannel(thetrack))
  chph.time = Outpos * ClicksperBeat
  chph.length = Outpos * ClicksperBeat
  Styleout [thetrack] |= chph
  } 
if (thetrack in Trackout)
  {
  oldpatch = cut (Trackout[thetrack], CUT_TIME, (Outpos * ClicksperBeat) - (ClicksperBeat /8), (Outpos * ClicksperBeat) + (ClicksperBeat /8))
  oldpatch = oldpatch{??.type == PROGRAM}
  Trackout [thetrack] -= oldpatch
  chph = patchchange (integer(apatch), tellchannel(thetrack))
  chph.time = (Outpos * ClicksperBeat)
  chph.length = Outpos * ClicksperBeat
  Trackout [thetrack] |= chph 
  } 
return (1)
}#stylepatch

function stylevol (thetrack, avol)
{
# generate a volume command
if (thetrack in Styleout)
  {
  Styleout [thetrack].length = Outpos * ClicksperBeat
  chph = chanvolchange (integer(avol), tellchannel(thetrack))
  chph.time = Outpos * ClicksperBeat
  chph.length = Outpos * ClicksperBeat
  Styleout [thetrack] |= chph
  } 
if (thetrack in Trackout)
  {
  chph = chanvolchange (integer(avol), tellchannel(thetrack))
  chph.time = (Outpos * ClicksperBeat) - 1
  chph.length = Outpos * ClicksperBeat
  Trackout [thetrack] |= chph 
  } 
return (1)
}#stylevol


# stylekit
# this function modifies the Style (or Drum) with an
# appropriate keykit function. the main aim is to
# modify the function without affecting the length
# away from an even number of beats (ie double is ok)
# or the tone away from the c7th chord
#
# add what you will

function stylekit (thetrack, kitmod)
{
if (thetrack in Currentstyle)
  {
  if (kitmod == "reverse")
    Currentstyle[thetrack] = reverse (Currentstyle[thetrack])
  if (kitmod == "double")
    Currentstyle[thetrack] = scatimes(Currentstyle[thetrack],2 )
  if (kitmod == "revpitch")
    Currentstyle[thetrack] = revpitch (Currentstyle[thetrack])
  if (kitmod == "upoctave")
    Currentstyle[thetrack] = transpose (Currentstyle[thetrack], 12)
  if (kitmod == "dnoctave")
    Currentstyle[thetrack] = transpose (Currentstyle[thetrack], -12)
  if (kitmod == "step")
    Currentstyle[thetrack] = step (Currentstyle[thetrack])
  if (kitmod == "even")
    Currentstyle[thetrack] = eventime (Currentstyle[thetrack])
  if (kitmod == "swap")
    Currentstyle[thetrack] = swapnote (Currentstyle[thetrack])
  if (kitmod == "shuffle")
    Currentstyle[thetrack] = shuffle (Currentstyle[thetrack])
  if (kitmod == "echo")
    Currentstyle[thetrack] = echo (Currentstyle[thetrack], Beatsperbar)
  if (kitmod == "firsthalf")
    Currentstyle[thetrack] = firsthalf (Currentstyle[thetrack])
  if (kitmod == "secondhalf")
    Currentstyle[thetrack] = secondhalf (Currentstyle[thetrack]) 
  }# thetrack in Currentstyle

if (thetrack in Currentdrum)
  {
  if (kitmod == "reverse")
    Currentdrum[thetrack] = reverse (Currentdrum[thetrack])
  if (kitmod == "double")
    Currentdrum[thetrack] = scatimes(Currentdrum[thetrack],2 )
  if (kitmod == "revpitch")
    Currentdrum[thetrack] = revpitch (Currentdrum[thetrack])
  if (kitmod == "upoctave")
    Currentdrum[thetrack] = transpose (Currentdrum[thetrack], 12)
  if (kitmod == "dnoctave")
    Currentdrum[thetrack] = transpose (Currentdrum[thetrack], -12)
  if (kitmod == "step")
    Currentdrum[thetrack] = transpose (Currentdrum[thetrack])
  if (kitmod == "even")
    Currentdrum[thetrack] = eventime (Currentdrum[thetrack])
  if (kitmod == "swap")
    Currentdrum[thetrack] = swapnote (Currentdrum[thetrack])
  if (kitmod == "shuffle")
    Currentdrum[thetrack] = shuffle (Currentdrum[thetrack])
  if (kitmod == "echo")
    Currentdrum[thetrack] = transpose (Currentdrum[thetrack], Beatsperbar)
  if (kitmod == "firsthalf")
    Currentdrum[thetrack] = firsthalf (Currentdrum[thetrack])
  if (kitmod == "secondhalf")
    Currentdrum[thetrack] = secondhalf (Currentdrum[thetrack]) 
  }# thetrack in Currentdrum
return (1)
}# stylekit
