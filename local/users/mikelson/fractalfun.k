#
# By Hans Mikelson <hljmm@werewolf.net>
# 
# In 1986 I wrote a program in Basic which used the
# "circle squared" fractal-like algorithm to generate midi music.
# 
# This version generates three different phrases which run in parallel.  The
# notes are restricted to different chords or scales (ie major, minor, blues
# etc.)  The chords change periodically throughout the piece.
# 
# Here is a description:
# 
# ff1(cx, cy, stepsize, duration)
# 
# Cx, Cy is the lower left hand corner of what would have been the picture
# (seek the program fracint for more info on circle squared).  You don't need
# to be too careful about these but I would choose non-integer values.
# 
# Use non integer values for step size or you will get the same note repeated
# for the duration.  Small step sizes (<.1) will produce more repeating notes.
# Larger step sizes (>4) will produce a wide range of notes.  Very large step
# sizes may result in overflow problems.
# 
# The duration determines the number of chord changes in the piece and the
# length of the piece.  24 will play a song lasting a few minutes.
# 
# Here are some more examples:
# 
# ff1(-3.2, -4.5, .1254, 24)
# ff1(-3.6, -2.1, 5.341, 12)
# ff1(-2.1, -3.2, .123, 8)
# 
# Have fun,
# Hans Mikelson

# Fractal Fun 1
function ff1(cx, cy, ss, dd)
 {

  if ( nargs() < 4 ) {
    print("Usage: ff1(cx,cy,ss,dd)")
    return('')
  }
  a1  = 'e'
  b1  = ''
  a2  = 'e'
  b2  = ''
  a3  = 'e'
  b3  = ''

  for (j=0; j<dd; j++) {


    root1  = circlsq(0, j*ss+cy, 12)
    chord1 = rand(12)
    chrdur = rand(3)+1

    for (i=0; i<12*chrdur; i++)
     {
      a1.pitch=ffscale(circlsq(i*ss+cx, j*ss+cy, 12), chord1)+60+root1
      rdur1      = (circlsq(i*ss, j*ss, 3)+1)*32
      a1.dur     = rdur1
      a1.length  = rdur1
      b1=b1+a1

      a2.pitch=ffscale(circlsq((i+1)*ss+cx, (j+1)*ss+cy, 12), chord1)+48+root1
      rdur2      = (circlsq((i+1)*ss, (j+1)*ss, 3)+1)*32
      a2.dur     = rdur2
      a2.length  = rdur2
      b2=b2+a2

      a3.pitch=ffscale(circlsq((i+5)*ss+cx, (j+5)*ss+cy, 12), chord1)+72+root1
      rdur3      = (circlsq((i+5)*ss, (j+5)*ss, 3)+1)*32
      a3.dur     = rdur3
      a3.length  = rdur3
      b3=b3+a3
     }
   }
  e=b1|b2|b3
  # realtime(e)
  return(e)
 }

function circlsq(x, y, c)
 {
  return ((x*x+y*y)%c)
 }

function ffscale(x,y)
 {
  s=[]
  x1=x%12
  y1=y%8
  s[0]=[0=0, 1=0, 2=2, 3=3, 4=3, 5=5, 6=5, 7=7, 8=7, 9=9,  10=10, 11=10]
  s[1]=[0=0, 1=0, 2=2, 3=2, 4=4, 5=5, 6=5, 7=7, 8=7, 9=9,  10=9,  11=11]
  s[2]=[0=0, 1=0, 2=0, 3=0, 4=4, 5=4, 6=4, 7=4, 8=7, 9=7,  10=7,  11=7]
  s[3]=[0=0, 1=0, 2=0, 3=0, 4=3, 5=3, 6=3, 7=3, 8=7, 9=7,  10=7,  11=7]
  s[4]=[0=0, 1=0, 2=0, 3=3, 4=3, 5=3, 6=7, 7=7, 8=7, 9=10, 10=10, 11=10]
  s[5]=[0=0, 1=0, 2=0, 3=0, 4=5, 5=5, 6=5, 7=5, 8=7, 9=7,  10=7,  11=7]
  s[6]=[0=0, 1=1, 2=2, 3=3, 4=4, 5=5, 6=6, 7=7, 8=8, 9=9,  10=10, 11=11]
  s[7]=[0=0, 1=0, 2=2, 3=3, 4=3, 5=5, 6=6, 7=7, 8=7, 9=9,  10=10, 11=11]
  return (s[y1][x1])
 }
