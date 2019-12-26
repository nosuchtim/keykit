#
# bnchord.k - music based on 1/f noise and chords,
# for KeyKit 6.2
#
# Copyright 1991, 1997 Andreas Gustafsson
#
# To use:
#   key> Snarf=bnchord()
# Then do File->Read->Snarf in the Group tool.
#

global BnNchords;
global BnChords;
global BnProb;
global BnRange;
global BnCurchord;

BnNchords = 0;
BnChords = [];
BnProb = [];
BnRange = 0.8;

# Generate a phrase for the chord defined by the 
# string "s", which may look like "c", "em", "g7".

function genchord(s)
{
    ph = 'p0 p4 p7';
    pi = phrase("'" + substr(s,1,1) + "'").pitch;
    for (i=2; i<=sizeof(s); i++) {
	m = substr(s,i,1);
	if (m=="m")
	    ph = 'p0 p3 p7';
	if (m=="7")
	    ph |= 'p10'
    }
    ph.pitch += pi;
    return(ph);
}

# Add the chord "c" with probability "p" to the
# global chord table.

function defchord(c,p)
{
    BnChords[BnNchords] = genchord(c);
    BnProb[BnNchords] = p;
    BnNchords++;
}

# Choose a chord at random.

function randchord()
{
    while (1) {
	i = rand(BnNchords);
	if (rand(20) <= BnProb[i])
	    break;
    }
    return(BnChords[i]);
}

# A simple approximation of the square root function.  KeyKit 6.2
# has a built-in square root, but Keynote 4.2 didn't, so this code 
# was used instead.  It remains in order to ensure that old compositions
# still sound the same.

function goodenough_sqrt(x)
{
    r = 1.0;
    while (x > 1) {
	x = x / 2;
	r *= 1.41;
    }
    return(r);
}

# Generate a random melody of length len/8 bars, with 
# "nvoices" voices whose initial pitches are given by the
# array ptch[].  The "depth" argument indicates the recursion
# depth and should be given as 0 at the top level.

function randmel(len, nvoices, ptch, depth)
{
    if (len==8 && nvoices > 1) {	
	BnCurchord = randchord();
	BnCurchord.dur = len*24;

	mel = '';
	ptch2 = [];
	for (i=0; i<nvoices; i++) {   
	    ptch2[0] = ptch[i];
	    mel |= randmel(len, 1, ptch2, depth);
	}
	return(mel);
    }

    # Approximate an 1/f spectrum for the melody line by perturbing
    # the pitch of each phrase with a random amount whose magnitude 
    # increases with the square root of the time scale.  Stop doing
    # it at the scale of 8 bars to avoid getting compositions where
    # the average pitch varies grossly between the beginning and
    # end of the composition.

    if (len < 64)
	for (i=0; i<nvoices; i++) {   
	    tmp1=rand(-1000,1000);
	    tmp2=float(tmp1);
	    tmp3=goodenough_sqrt(len);
	    tmp4=tmp3*tmp2*0.001*BnRange;

	    ptch[i] += tmp4;

            # Avoid descending too deep into the bass.
	    if (ptch[i] < 20)
		ptch[i] += 6;
    }

    # If the phrase is longer than a 1/1 note, subdivide it into
    # two shorter phrases.  If it is the length of an 1/8 note, make
    # it a single note.  If the length is 1/1..1/4, do one
    # or the other at random.
    rand1 = rand(1000);
    if (len > 8 || (len > 1 && rand1 < 500)) {

        # Subdivide, either into two different subphrases, or
        # by repeating a single subphrase.
	if (rand(800) < 500) {   
	    if (len < 8)
		depthinc=1;
	    else 
		depthinc=0;
	    mel=randmel(len/2, nvoices, ptch, depth) +
		randmel(len/2, nvoices, ptch, depth+depthinc);
	} else {
	    mel=randmel(len/2, nvoices, ptch, depth); 
	    mel=mel+mel;
	}
	return(mel);
    } else {	
	n=integer(float(ptch[0]));
	
	# Adjust the pitch in a random direction until it
	# coincides with a note in the current chord,
	# especially if it has a low pitch.
	rand2 = rand(1000);
	if (depth < 4 || rand2 < 300 || n < 70)  {
	    if (rand(700) < 350)
		dir = 1;
	    else
		dir = -1;
	    while (!(BnCurchord{(??.pitch%12) == (n%12)}.pitch)) {   
		n += dir
	    }
	}
	note = 'p0';
	note.pitch += n;
	
	note.dur = note.length = len*24;
	return(note)
    }
}

# Compose.

function bnchord(seed) {
    if (nargs() == 0) {
	seed = 1430;
    }
    
    rand(-seed);

    # Initialize the chord tables.
    defchord("c",10);
    defchord("d",3);
    defchord("em",3);
    defchord("f",7);
    defchord("g7",7);
    defchord("am",5);
    # defchord("b",2);

    # Set up initial pitches for the voices.
    globptch=[];
    globptch[0] = 87;
    globptch[1] = 78;
    globptch[2] = 70;
    globptch[3] = 54;
    globptch[4] = 45;
    globptch[5] = 62;

    tempo(500 * (1000 + rand(700)));

    return(randmel(1024, 6, globptch, 0));
}
