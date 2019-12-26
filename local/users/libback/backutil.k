# utils for the Backing system

#name strsplit
#usage strsplit (string, splitchar)
#desc split the string about the splitchar 
#desc the splitchar is not returned
function strsplit (string, splitchar)
{
if (nargs() != 2 )
  {
  print ("strsplit argument error") 
  return (["pre"="","post"=""])
  }
n = strindex (string, splitchar)
if ( n != -1)
  {
  first = substr (string, 1, n-1)
  second = substr (string, n+sizeof (splitchar), sizeof (string)-((n-1)+sizeof (splitchar)))
  return (["pre"=first, "post"=second])
  }
else
  {
  thisstr = string
  return (["pre"=thisstr,"post"=""])
  }
} # strsplit

#name	replengo
#usage	repleng(phrase,length,[offset])
#desc	Repeat the specified phrase as many times as it takes
#desc	to fill the specified length of time.  The resultant
#desc	phrase is truncated to the exact length, if it doesn't
#desc	come out evenly. The optional offset shifts the start 
#desc point

function replengo(ph,lng, offset) {
	if ( nargs() < 2 ) {
		print("usage: repleng(phrase,desired-length, [offset])")
		return('')
	}
      if (nargs() == 2) {
            offset = 0
      }
	while ( ph.length < (lng + offset) )
		ph = ph + ph
	ph = cut(ph,CUT_TIME,offset,lng+offset,TRUNCATE)
      ph.time -= offset
	ph.length = lng;
	return(ph)
}


#name transnotes
#desc transnotes takes a phrase, and transposes all notes of a particular pitch
#desc by a specified amount
#desc ie
#desc transnotes ('c e g b-', 'b-', 2) = 'c e g c'
function transnotes ( ph, note, shift)
{
if (nargs () != 3)
  {
  print "usage: transnotes ( phrase, note, shift )"
  return ('')
  }
# extract all the appropriate notes
modnotes = ph{??.pitch % 12 == note.pitch % 12}
ph -= modnotes
modnotes.pitch += shift
ph |= modnotes
return (ph) 
}

# tellchannel
# tells which channel a track should be on
function tellchannel ( atrack)
{
for (i in Channels)
  if (Channels[i] == atrack)
    return (i)
  return (16)
}

# getchannel
# this allocates channels for the output, returns a channel
# if there are no free channels, dump it to 16
function getchannel (trackname)
{
for (i=1;i<=16;i++)
  {
  if (i != 10)
    {
    if (! i in Channels)
      {
      Channels [i] = trackname
      return (i)
      } 
    }
  }
return (16)
}

# freechannel
# this releases a used channel if needed
function freechannel (achannel)
{
if (achannel in Channels)
  {
  delete Channels [achannel]
  }
}

# stylechord
# this function takes the style and makes it the appropriate chord
function stylechord(ph, chordstr)
{
if (chordstr == "maj")
  {
  return (transnotes (ph, 'b-', 2))
  }
if (chordstr == "min")
  {
  return (transnotes (stylechord (ph, "maj"), 'e', -1))
  }
if (chordstr == "7th")
  {
  return (ph)
  }
if (chordstr == "6th")
  {
  return (transnotes (ph, 'a+', -1))
  }
if (chordstr == "maj7")
  {
  return (transnotes (ph, 'a+', 1))
  }
if (chordstr == "min")
  {
  return (transnotes (transnotes (ph, 'e', -1), 'a+', 2))
  }
if (chordstr == "min6")
  {
  return (transnotes (transnotes (ph, 'e', -1), 'a+', -1))
  }
if (chordstr == "minM7")
  {
  return (transnotes (transnotes (ph, 'e', -1), 'a+', 1))
  }
if (chordstr == "min7")
  {
  return (transnotes (ph, 'e', -1))
  }
if (chordstr == "sus4")
  {
  return (transnotes (transnotes (ph, 'e', 1), 'a+', 2))
  }
if (chordstr == "7sus4")
  {
  return (transnotes (ph, 'e', 1))
  }
if (chordstr == "7aug")
  {
  return (transnotes (ph, 'g', 1))
  }
if (chordstr == "aug")
  {
  return (transnotes (transnotes (ph, 'g', 1), 'b-',2))
  }
if (chordstr == "dim7")
  {
  return ( transnotes (transnotes (ph, 'e', -1), 'g', -1))
  }
if (chordstr == "dim")
  {
  return ( transnotes (transnotes (transnotes (ph, 'e', -1), 'g', -1),'a+',2))
  }
} # stylechord



#usage	gmresetch()
#desc	Returns a phrase containing controller messages that reset
#desc	everything appropriately for the beginning of
#desc	a General MIDI piece.

function gmresetch( channel ) 
{
a=''
lng = 0;
n = channel - 1
# pitch bend reset
a += midibytes( n + 0xe0, 0x00, 0x40 )
a.length++
# breath control reset
a += midibytes( n + 0xb0, 0x02, 0x00 )
a.length++
# sustain pedal reset
a += midibytes( n + 0xb0, 0x40, 0x00 )
a.length++
# all-notes-off
a += midibytes( n + 0xb0, 0x7b, 0x00 )
a.length++
# channel pressure reset
a += midibytes( n + 0xd0, 0x00 )
a.length++
# volume controller
a += midibytes( n + 0xb0, 0x07, 0x7f )
a.length++
# expression controller
a += midibytes( n + 0xb0, 0x0b, 0x7f )
a.length++
# modulation controller
a += midibytes( n + 0xb0, 0x01, 0x0 )
a.length++
# pan controller
a += midibytes( n + 0xb0, 0x0a, 0x41 )
a.length++
# reverb controller
a += midibytes( n + 0xb0, 0x5b, 0x1e )
a.length++
# chorus controller
a += midibytes( n + 0xb0, 0x5d, 0x1e )
a.length++
# reset pitch bend range to 2 semitones
a += midibytes( n + 0xb0, 100, 0 )
a.length++
a += midibytes( n + 0xb0, 101, 0 )
a.length++
a += midibytes( n + 0xb0, 6, 2 )
a.length++
a += midibytes( n + 0xb0, 38, 0 )
a.length++

return(a)
}#gmresetch


#name rechannel
#useage rechannel (ph, thechannel)
#desc rechannel changes all channel elements in a phrase
#desc to the channel defined by thechannel
function rechannel ( ph, thechannel)
{
for (i =1;i<=sizeof(ph);i++)
  ph%i.chan = thechannel
return (ph)
}#rechannel


#chanvolchange
#change the volume on a channel

function chanvolchange(v, channel) 
{
p = ''
p += midibytes(0xb0 | channel - 1, 0x07, v)
return(p)
}
