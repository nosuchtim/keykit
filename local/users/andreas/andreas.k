# Copyright 1991 Andreas Gustafsson

global Nchords
global Chords
global Prob
global Range
global Curchord

Nchords=0
Chords=[]
Prob=[]
Range = 0.8

function chord(s)
{
  ph = 'p0 p4 p7';
  pi = phrase("'" + substr(s,1,1) + "'").pitch;
  for(i=2; i<=sizeof(s); i++)
  { m = substr(s,i,1);
    if(m=="m")
      ph = 'p0 p3 p7';
    if(m=="7")
      ph |= 'p10'
  }
  ph.pitch += pi;
  return(ph);
}

function defchord(c,p)
{
  Chords[Nchords] = chord(c)
  Prob[Nchords] = p
  Nchords++
}


function randchord(  i)
{
  while(1)
  { i = rand(Nchords);
    if(rand(20) <= Prob[i])
      break;
  }
  return(Chords[i]);
}



function goodenough_sqrt(x)
{
  r = 1.0;
  while(x > 1)
  {
    x = x / 2;
    r *= 1.41;
  }
  return(r);
}


function randmel(len, nvoices, ptch, depth)
{
  if(len==8 && nvoices > 1)
  {
    Curchord = randchord();
    Curchord.dur = len*24;

    mel = '';
	ptch2 = []
    for(i=0; i<nvoices; i++)
    {
      ptch2[0] = ptch[i];
      mel |= randmel(len, 1, ptch2, depth);
    }
    return(mel);
  }

  if(len < 64)
    for(i=0; i<nvoices; i++)
    {
      ptch[i] += goodenough_sqrt(len) * float(rand(-1000,1000)) * 0.001 * Range;
      if(ptch[i] < 20)
        ptch[i] += 6;
    }

  if(len>8 || (len>1 && rand(1000) < 500))
  { # subdivide always if longer than a 1/1 note, and sometimes if 1/1..1/4
    if(rand(800) < 500)
    {
      if(len < 8)
        depthinc=1
      else 
        depthinc=0
      mel=randmel(len/2, nvoices, ptch, depth)+randmel(len/2, nvoices, ptch, depth+depthinc);
    }
    else
    {
      mel=randmel(len/2, nvoices, ptch, depth); 
      mel=mel+mel;
    }
    return(mel);
  }
  else	
  { 
    n=integer(float(ptch[0]))

#    fudge=1000;	# repair div/mod brain damage
#    scalen=5;
#    oct=(n+fudge*scalen)/scalen-fudge
#    which=(n+fudge*scalen)%scalen
#    note='p0 p3 p5 p7 p10'%(which+1)

     if(depth < 4 || rand(1000) < 300 || n < 70) 
     {
       # adjust the pitch in a random direction until it
       # coincides with a note in the current chord
       if(rand(700) < 350) dir=1; else dir=-1
       while(!(Curchord{(??.pitch%12) == (n%12)}.pitch))
       {
	 n += dir
       }
     }
     note='p0';
     note.pitch+=n;
    
    note.dur=note.length=len*24
    # print note
    return(note)
  }
}

function andreas() {

	defchord("c",10);
	defchord("d",3);
	defchord("em",3);
	defchord("f",7);
	defchord("g7",7);
	defchord("am",5);
	# defchord("b",2);

	globptch=[]
	globptch[0] = 87;
	globptch[1] = 78;
	globptch[2] = 70;
	globptch[3] = 54;
	globptch[4] = 45;
	globptch[5] = 62;

	rand(-1430)

	tempo(500 * (1000+rand(700)))

	return(randmel(1024,6,globptch,0));
}
