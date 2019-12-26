#tracks
#all you can do is add a track
#a
#           = p{phrase file path}<pitchshift>name:1-s,2-d...
#           = m{midi file path}<pitchshift>name:1-s,2-d...
#
# to avoid problems controlling the track (ie patches), 
# only notes are added
function tracks (commandstr)
{
origcommand = commandstr
commandstr = strsplit (commandstr, "=")["post"]

filetype = strsplit (commandstr, "{")["pre"]
commandstr = strsplit (commandstr, "{")["post"]

filepath = strsplit (commandstr, "}")["pre"]
commandstr = strsplit (commandstr, "}")["post"]

if (strsplit (commandstr, "<")["post"] != "")
  {
  # extract a pitch command
  commandstr = strsplit (commandstr, "<")["post"]
  movepitch = strsplit (commandstr, ">")["pre"]
  commandstr = strsplit (commandstr, ">")["post"]
  }
else 
  movepitch = "0"

trackname = strsplit (commandstr, ":")["pre"]
thetracks = strsplit (commandstr, ":")["post"]

if (filetype == "" || filepath == "" )
  {
  print ("track command error in ", origcommand)
  return (0)
  }

if (filetype == "p")
  {
  if (thetracks == "")
    {
    # default is that the only track is not a drum track
    thetracks = "0-s"
    }
  pharray = []
  pharray [1] = readphr (filepath)
  }
else
  {
  if (thetracks == "" )
    {
    #default includes all tracks, GM spec (drums on 10)
    thetracks = "1-s,2-s,3-s,4-s,5-s,6-s,7-s,8-s,9-s,10-d,11-s,12-s,13-s,14-s,15-s"
    }
  pharray = midifile (filepath)
  }
trackadd (pharray, trackname, thetracks, integer(movepitch))
return (1)
} # tracks


# trackadd
# adds the phrases stored in multiph controlled by trackstr
function trackadd ( multiph, name, atrackstr, pitchshift)
{
while (atrackstr != "")
 {

 thistrk = strsplit (atrackstr, ",")["pre"]
 atrackstr = strsplit (atrackstr, ",")["post"]

 itrack = strsplit ( thistrk, "-")["pre"]
 ttype = strsplit (thistrk, "-")["post"]
 thetrack = name + "-" + itrack
 
if (integer(itrack) in multiph)
   {
   if (ttype == "s")
     {
     if ( onlynotes (multiph[integer(itrack)]) != '')
       {
       if (! thetrack in Trackout )
         {
         if (sizeof (Trackout) == 0)
           Trackout = []
         Trackout[thetrack] = ''
         newchannel = getchannel (thetrack)
         Trackout[thetrack].chan = newchannel

         Trackout[thetrack] += gmresetch (newchannel)
         Trackout[thetrack].length ++
         Trackout[thetrack] += patchchange (1,newchannel)
         }
       else 
         {
         newchannel = tellchannel (thetrack)
         }
       Trackout[thetrack].length = Outpos * ClicksperBeat
       Trackout[thetrack] += rechannel (transpose(multiph[integer(itrack)],pitchshift),newchannel) 
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
     Drumout[thetrack] += onlynotes (transpose (multiph[integer(itrack)],pitchshift))
     }# if (ttype == "d")
   }# if (itrack in multiph)
 }#while
}# trackadd




