From: Jim Bumgardner [jim.bumgardner@gmail.com]
Sent: Sunday, September 12, 2004 1:56 AM
To: keykit@nosuch.com
Subject: Terry Riley's "In C"

# Midi Performance for In C by Terry Riley
# Realization by Jim Bumgardner (in KeyKit)
#
drone = 'cv32o4d48,c,c,c,c,c,c,c';

nbrPlayers = 16                     # each player is on a different
channel (1-16)
minPhraseDuration = 96*40;   # minimum duration of a repeated phrase, in clicks
maxPhraseDuration = 96*120; # maximum duration

debug = 0 # turn this on to test individual phrases

a = [0='r96',
     1='cd6,ed90,cd6,ed90,cd6,ed90',
     2='cd6,ed42,fd48,ed96',
     3='rd48,e,f,e',
     4='rd48,e,f,g',
     5='ed48,f,g,r',
     6='co4d768',
     7='rd336,co3d24,c,cd48,rd432',
     8='gd576,fd768',
     9='bd24,g,rd336',
     10='bv48d24,g',
     11='fv48d24,g,b,g,b,g',
     12='fv63d48,g,bd384,co4d96',
     13='bd24,gd72,gd24,f,gd48,rd72,gd312',
     14='co4d384,bo3,g,f+',
     15='gd24,rd360',
     16='gv48d24,b,co4,bo3',
     17='bv48d24,co4,bo3,co4,bo3,r',
     18='ev48d24,f+,e,f+,ed72,ed24',
     19='r144,gv63o4d144',
     20='ev48d24,f+,e,f+,go2d72,eo3d24,f+,e,f+,e',
     21='f+d288',
     22='ed144,e,e,e,e,f+,g,a,bd48',
     23='ed48,f+d144,f+,f+,f+,f+,g,a,bd96',
     24='ed48,f+,gd144,g,g,g,g,a,bd48',
     25='ed48,f+,g,ad144,a,a,a,a,b',
     26='ed48,f+,g,a,bd144,b,b,b,b',
     27='ev48d24,f+,e,f+,gd48,ed24,g,f+,e,f+,e',
     28='ev48d24,f+,e,f+,ed72,ed24',
     29='ed288,g,co4',
     30='co4d576',
     31='gv48d24,f,g,b,g,b',
     32='fv48d24,g,f,g,b,fd312,gd144',
     33='gd24,f,rd48',
     34='gv48d24,f',
     35='fv48d24,g,b,g,b,g,b,g,b,g,rd336,b-v63d96,go4d288,ad48,gd96,bd48,ad144,gd48,ed288,gd48,f+d336,rd240,e,fd576',
     36='fv48d24,g,b,g,b,g',
     37='fv48d24,g',
     38='fv48d24,g,b',
     39='bv48d24,g,f,g,b,co4',
     40='bv48d24,f',
     41='bv48d24,g',
     42='co4d384,bo3,a,co4',
     43='fv48o4d24,e,f,e,ed48,e,e,fd24,e',
     44='fo4d48,ed96,ed48,cd96',
     45='do4d96,d,go3',
     46='gv48d24,do4,e,d,rd48,go3,r,g,r,g,gd24,do4,e,d',
     47='do4d24,e,dd48',
     48='gd576,gd384,fd480',
     49='fv48d24,g,b-,g,b-,g',
     50='fv48d24,g',
     51='fv48d24,g,b-',
     52='gv48d24,b-',
     53='b-v48d24,g'
     ]
if (debug)
{
  p = ''
  for (i = 45; i <= 53; ++i)
    p = p + a[i] + a[i];
  len = p.length;
  p2 = '';
  while (p2.length < len)
    p2 = p2 + drone;
  realtime(p2 | p);
}

pstr = '';

maxlen = 0;
perf = '';
filetracks = [];
for (p = 0; p < nbrPlayers; p++)
{
  pp = '';
  for (i in a)
  {
    phraseDuration = rand(minPhraseDuration,maxPhraseDuration);
    subp = '';
    while (subp.length < phraseDuration)
      subp = subp + a[i]
    pp = pp + subp
  }
  if (pp.length > maxlen)
    maxlen = pp.length;
  pp.chan = (p+1);
  filetracks[p+1] = pp;
  perf = perf | pp;
}

dstr = '';
while (dstr.length < maxlen+10*96)
  dstr = dstr + drone;
perf = perf | dstr;
filetracks[0] = dstr;

# Use this bit of script to hear "In C" performed in KeyKit
#
if (!debug)
  realtime(perf)

# Use this to save it to a file
# midifile(filetracks,"InC_TerryRiley.mid")
