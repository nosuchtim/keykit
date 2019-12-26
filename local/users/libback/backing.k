# Simon Blakely 24/4/98
#
# This routine uses a style library to generate a midi file 
# The style library consists of a midi file with bars of
# each style. The styles are all 7th chords, and get modified
# to provide all other chords.
#
# 0 is a details track.
# The chord definition is thus
# note name (a-g) followed by chord type 
#					maj
#					maj7
#					7th
# 					6th
#					sus4
#					7sus4
#					aug
#					dim
#					min
#					min7
#					min6
#
# These are strung together with " " as a separator and a beat count
# a beat offset may be added with a "+" for effect 
# ie
#"e.maj-4 e.maj7-4 e.7th-4 e.6th-4 a.maj7-4 a.7th-4 e.7th-4 e.6th-4 
# b.7-4 a.7-4 e.maj7-6 b.7-2+0"
#
# There are 3 components to a generated phrase
#
#    Style elements
#      a style has 6 elements by default, but each element may
#      be individually modified
#    Track elements
#      these are phrases or midis that are layered on to the result
#      and only have a single transpose
#    Drum elements
#      these do not get transposed. Tempo info also gets placed here.
#
# Before use, you MUST call initstyle to initialise
#
# Outpos is the current time, Offset is used to "shift" the style
#
# Drumout, Styleout, Trackout are the current outputs.
#
# backingit returns an array of phrases

function backingit ( chords, fileout )
{
  if (nargs () < 2) 
  {
  fileout = ""
  }

  # initialise the system
  initstyle ()
  song = split (chords)
  for (index in song)
   {
   # Is this an x command?
   chordstr = song [index]
   if (substr (chordstr, 1 ,1) == "x")
    {
    thecommand = substr (chordstr, 2, 1)
    if (thecommand == "t")
      #Tempo command
      {
      styletempo (strsplit(chordstr,"=")["post"])
      }
    if (thecommand == "s")
      #change style
      {
      done = style ( strsplit(chordstr, "s")["post"])
      }#change style
    if (thecommand == "p")
      # track commands
      {
      done = tracks ( strsplit(chordstr, "p")["post"])
      }# tracks
    if (thecommand == "o")
      # offset command xo=4
      {
      Offset = integer (strsplit(chordstr,"=")["post"])
      }
    if (thecommand == "b")
      # beat command  xb=4/4 etc
      {
      Timesig = strsplit(chordstr,"=")["post"]
      Beatsperbar = integer (strsplit(Timesig,"/")["pre"])
      ClicksperBeat = (Clicks / 4) * integer (strsplit(Timesig,"/")["post"])
      }
    if (thecommand == "-")
      # rest command x-=4
      {
      Outpos += integer (strsplit(chordstr,"=")["post"])
      }
   }# x command
  else
    {
    # For each chord, get the pitch, chord type and duration
    m= strsplit ( chordstr, ".")
    thispitch = m["pre"]
    chordstr = m["post"] 
    m = strsplit ( chordstr, "-" )
    thischord = m["pre"]
    chordstr = m["post"]
    m = strsplit (chordstr, ":")
    thislength = m["pre"]
    thisoffset = m["post"]
    backinggen (thispitch, thischord, thislength, thisoffset)
    }#else
  } #for (index in song)
# generate a phrase to output, and a midi structure to write
r = ''
midiout = []
midiout [0] = ''
midiout [0] = Drumout [0]
track = 1
for (i in Trackout)
  {
  if ( onlynotes (Trackout[i]) != '')
    {
    r |= Trackout[i]
    midiout [track] = Trackout [i]
    track++
    }
  }
for (i in Styleout)
  {
  if ( onlynotes (Styleout[i]) != '')
    {
    r |= Styleout[i]
    midiout [track] = Styleout [i]
    track++
    }
  }
r |= Drumout [0]
for (i in Drumout)
  {
  if ( onlynotes (Drumout[i]) != '')
    {
    r |= Drumout[i]
    midiout [track] = Drumout [i]
    track++
    }
  }

if (fileout != "")
  midifile (midiout, fileout) 

# Comment these statements out if you don't want to play it
# when you call this function
r.time += 4b
r |= gmresetall()
realtime(r)

return (midiout)

}

# backinggen
# this does the generation magic
# get the style, change it to right chord, transpose it
# repeat it to make up the count, and shift it 
# we want the beat structure to remain consistent (unless we 
# deliberately specify oherwise)
# drums just get repeated and shifted
# 
function backinggen ( thepitch, thechord, thelength, theoffset)
{
# Generate the music
for (n in Currentstyle )
  {
  modulus = integer((Currentstyle[n].length / 1b) + 0.5)
  Styleout[n].length = Outpos * ClicksperBeat
  thisphrase =transpose (stylechord (Currentstyle[n],thechord), phrase("'"+thepitch+"'")%1.pitch- phrase("'c'")%1.pitch)
  if (theoffset == "")
    thisphrase = replengo (thisphrase, thelength * ClicksperBeat, ((Outpos-Offset) % modulus)* ClicksperBeat)
  else
    thisphrase = replengo (thisphrase, thelength * ClicksperBeat, (integer (theoffset) % modulus)* ClicksperBeat)   
  Styleout[n] += thisphrase
  }
for (n in Currentdrum)
  {
  Drumout[n].length = Outpos * ClicksperBeat
  thisphrase = Currentdrum[n]
  modulus = integer((thisphrase.length / 1b) + 0.5)
  if (theoffset == "")
    thisphrase = replengo (thisphrase, thelength * ClicksperBeat, ((Outpos - Offset) % modulus)* ClicksperBeat)
  else
    thisphrase = replengo (thisphrase, thelength * ClicksperBeat, (integer (theoffset) % modulus)* ClicksperBeat)   
  Drumout [n] += thisphrase
  }
Outpos += thelength
}

# fbackit generates a backing track from a text file
# it returns an array of phrases
function fbackit ( sourcefile, destfile)
{
if (nargs () <1)
  {
  print ("usage: fbackit ( sourcefile [,destination file]")
  }
if (nargs () <2)
  {
  destfile = ""
  }
cr = ascii (13)
musicstr = ""
f = open(sourcefile) 
	for ( n=1; (v=get(f)) != Eof; n++ ) 
        # lines starting with "#" are a comment
        if (substr (v,1,1) != "#")
          {
          # trim carriage-returns for PC users
          if (substr (v, sizeof (v),1) == cr)
            v = substr (v, 1, sizeof(v)-1)
	    musicstr = musicstr + " " + v
          }
	close(f) 
outa = []
outa = backingit ( musicstr, destfile)
return (outa)
}



# quick and easy command to test
function doit()
{
fbackit ("d:\\keykit\\music\\waltz.txt", "d:\\test2.mid")
}

