################################################
# This code was written by hljimm@werewolf.net
# and appeared in Csound magazine, autumn 1999.
################################################

# Hopasong generates a short phrase based on the scales selected and the hopalong algorithm

function hopasong(n, root, chrd, d, hpa, hpb) 

# n is the length of the phrase
# root is the key the phrase is in
# chrd determines the which chord or scale to use
# d is the duration of each note
# hpa is the hopalong constant a
# hpb is the hopalong constant b

 {                                  
  b        =''                      # Initialize b to an empty string
  a        ='c'                     # Initialize a to some dummy note value
  a.dur    = d                      # Adjust duration and length of the note
  a.length = d

  x = 0;                            # Initialize hpx and hpy to zero
  y = 0;

  for (j=0; j<n; j++)
   {
    snx = (x == 0) ? 1 : x/abs(x)    # Determine the sign of X
    xx  = y - snx + sqrt(abs(hpb*x)) # Hopalong the X part and save the new X
    y   = hpa - x                    # Hopalong the Y part
    x   = xx                         # Update X

    a.pitch = ffscal(abs(x)%60, chrd)+60+root # Find the note in the scale
    a.vel      = (abs(y)%4/1+1)*32            # Use Y for the 
    b         = b+a                  # Add the new note to the list of notes
   }
  return (b)
 }


function ffscal(scp, scn)                       # Generates a relative note number based on scale
 {                                              # and note in the scale.
  s=[]                                          # Initialize the scale
  sn=scn%36                                     # Limit the scalenumber to those defined
  sp=scp%(ffscaletotal(sn))                     # Limit the pitch to those availble for that scale

  s[0]  = [0=0, 1=2, 2=3, 3=5, 4=7, 5=9,  6=10] # Minor scale
  s[1]  = [0=0, 1=2, 2=4, 3=5, 4=7, 5=9,  6=11] # Major scale
  s[2]  = [0=0, 1=4, 2=7]                       # Major chord
  s[3]  = [0=0, 1=3, 2=7]                       # Minor chord
  s[4]  = [0=0, 1=3, 2=7, 3=10]                 # Min7
  s[5]  = [0=0, 1=5, 2=7]                       # Sus4
  s[6]  = [0=0, 1=1, 2=2, 3=3, 4=4, 5=5,  6=6, 7=7, 8=8, 9=9,  10=10, 11=11] # Chromatic
  s[7]  = [0=0, 1=2, 2=3, 3=5, 4=6, 5=7,  6=9, 7=10,8=11] # Blues scale
  s[8]  = [0=0, 1=2, 2=4, 3=5, 4=7]             # Major pentatonic scale
  s[9]  = [0=0, 1=1, 2=3, 3=5, 4=7, 5=8,  6=11] # Neapolitan Minor
  s[10] = [0=0, 1=1, 2=3, 3=5, 4=7, 5=9,  6=11] # Neapolitan Major
  s[11] = [0=0, 1=1, 2=4, 3=5, 4=6, 5=9,  6=10] # Oriental
  s[12] = [0=0, 1=1, 2=4, 3=5, 4=7, 5=8,  6=11] # Double harmonic
  s[13] = [0=0, 1=1, 2=4, 3=6, 4=8, 5=10, 6=11] # Enigmatic
  s[14] = [0=0, 1=2, 2=3, 3=7, 4=8]             # Hirajoshi
  s[15] = [0=0, 1=2, 2=3, 3=6, 4=7, 5=8,  6=11] # Hungarian Minor
  s[16] = [0=0, 1=3, 2=4, 3=6, 4=7, 5=9,  6=10] # Hungarian Major
  s[17] = [0=0, 1=1, 2=5, 3=7, 4=8]             # Kumoi
  s[18] = [0=0, 1=1, 2=5, 3=6, 4=10]            # Iwato
  s[19] = [0=0, 1=2, 2=4, 3=5, 4=7, 5=8,  6=10] # Hindu
  s[20] = [0=0, 1=1, 2=3, 3=4, 4=5, 5=6,  6=8, 7=10] # Spanish 8 Tone
  s[21] = [0=0, 1=1, 2=3, 3=7, 4=10]            # Pelog
  s[22] = [0=0, 1=2, 2=3, 3=6, 4=7, 5=8,  6=10] # Hungarian Gypsy
  s[23] = [0=0, 1=1, 2=4, 3=5, 4=7, 5=8,  6=10] # Major Phrygian
  s[24] = [0=0, 1=2, 2=4, 3=5, 4=6, 5=8,  6=10] # Major Locrian
  s[25] = [0=0, 1=2, 2=4, 3=6, 4=7, 5=8,  6=10] # Lydian Minor
  s[26] = [0=0, 1=2, 2=4, 3=6, 4=7, 5=9,  6=10] # Overtone
  s[27] = [0=0, 1=2, 2=4, 3=6, 4=8, 5=10, 6=11] # Leading Whole Tone
  s[28] = [0=0, 1=2, 2=4, 3=5, 4=6, 5=8,  6=10] # Arabian
  s[29] = [0=0, 1=1, 2=3, 3=7, 4=8]             # Balinese
  s[30] = [0=0, 1=1, 2=4, 3=5, 4=7, 5=8, 6=11]  # Gypsy
  s[31] = [0=0, 1=2, 2=3, 3=5, 4=7, 5=8, 6=11]  # Mohammedan
  s[32] = [0=0, 1=1, 2=3, 3=5, 4=7, 5=9, 6=10]  # Javanese
  s[33] = [0=0, 1=1, 2=4, 3=5, 4=6, 5=8, 6=11]  # Persian
  s[34] = [0=0, 1=2, 2=3, 3=6, 4=7, 5=8, 6=11, 7=12, 8=14, 9=15, 10=17]  # Algerian
  s[35] = [0=0, 1=2, 2=3, 3=5, 4=7, 5=8, 6=10]  # Aeolian

  return (s[sn][sp])                        # Return the correct note in the correct scale
 }

function ffscaletotal(scn)                  # Generates the total number of elements in a scale
 {
  nns=[0=7, 1=7, 2=3, 3=3, 4=4, 5=3, 6=12, 7=9, 8=4, 9=7, 10=7, 11=7, 12=7, 13=7, 14=5, 15=7] # Matrix defining number of notes in each scale
  nns[16]=7
  nns[17]=5
  nns[18]=5
  nns[19]=7
  nns[20]=8
  nns[21]=5
  nns[22]=7
  nns[23]=7
  nns[24]=7
  nns[25]=7
  nns[26]=7
  nns[27]=7
  nns[28]=7
  nns[29]=5
  nns[30]=7
  nns[31]=7
  nns[32]=7
  nns[33]=7
  nns[34]=11
  nns[35]=7

  return (nns[scn])                         # Return the number of notes in the scale
 }

function ffgetnn(note, scale, root)         # Generate a midi note number based on relative note
 {                                          # scale and root
  noct=0                                    # Number of octaves is intially zero
  ffst=ffscaletotal(scale)                  # Get the number of elements in the scale
  if (note<0)                               # Negative values require special approach
   {                                        # rather than just modulo
    while (note<0)                          # While the note is less than zero
     {                                      # jump to the next octave for this scale
      note+=ffst                            # Every ffst steps is another octave for that scale
      noct--                                # Count the number of octaves
     }
   }
  if (note>=ffst)                           # If the number is greater than zero use modulo
   {
    noct=note/ffst                          # To get the octave just divide
    note=note%ffst                          # Limit the note to those available in the scale
   }
  return (ffscal(note, scale)+root+12*noct+60) # Return the midi note number, centered on 60
 }


