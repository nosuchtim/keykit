# Utility functions for image things

function readpnm(fname) {
	f = open(fname)
	Words = []
	Used = 0
	Type = getpnmword(f)

	cols = getpnmword(f)
	rows = getpnmword(f)
	Maxval = getpnmword(f)
	CellR = []
	CellG = []
	CellB = []
	if ( Type == "P2" ) {
		# greyscale
		for ( r=0; r<rows; r++ ) {
			CellR[r] = []
			CellG[r] = []
			CellB[r] = []
			for ( c=0; c<cols; c++ ) {
				i = integer(getpnmword(f))
				if ( i == Eof ) {
					print("Premature EOF!?");
					break;
				}
				CellR[r][c] = i
				CellG[r][c] = i
				CellB[r][c] = i
			}
		}
		ret = 0
	}
	else if ( Type == "P3" ) {
		# color
		for ( r=0; r<rows; r++ ) {
			CellR[r] = []
			CellG[r] = []
			CellB[r] = []
			for ( c=0; c<cols; c++ ) {
				ir = integer(getpnmword(f))
				if ( ir == Eof ) {
					print("Premature EOF!?");
					break;
				}
				ig = integer(getpnmword(f))
				if ( ig == Eof ) {
					print("Premature EOF!?");
					break;
				}
				ib = integer(getpnmword(f))
				if ( ib == Eof ) {
					print("Premature EOF!?");
					break;
				}
				CellR[r][c] = ir
				CellG[r][c] = ig
				CellB[r][c] = ib
			}
		}
		ret = 0
	}
	else {
		print("Unrecognized image type: ",Type);
		ret = 1
	}
	close(f)
	return(ret)
}

function readppm(fname) {
	f = open(fname,"r")
	if ( f < 0 )
		error("Unable to open file: ",fname)
	fifoctl(f,"type","b")

	line1 = getppmline(f)
	if ( line1 != "P6" )
		error("readppm() is expecting the first line of the file to be P6")
	line2 = getppmline(f)
	w = split(line2)
	if ( sizeof(w) != 2 )
		error("readppm() is expecting two words on the second line")
	xsize = integer(w[0])
	ysize = integer(w[1])

	line3 = getppmline(f)
	maxval = integer(line3)

	rast = []
	rast["maxval"] = maxval
	rast["xsize"] = xsize
	rast["ysize"] = ysize
	rast["r"] = rastr = []
	rast["g"] = rastg = []
	rast["b"] = rastb = []

	for ( x=0; x<xsize; x++ ) {
		rastr[x] = []
		rastg[x] = []
		rastb[x] = []
	}

	for ( y=0; y<ysize; y++ ) {
		for ( x=0; x<xsize; x++ ) {
			ir = get(f)
			ig = get(f)
			ib = get(f)
			if ( ib == Eof ) {
				print("Premature EOF!?");
				break;
			}
			rastr[x][y] = ir
			rastg[x][y] = ig
			rastb[x][y] = ib
		}
	}
	close(f)
	return(rast)
}

function getppmline(f) {
	s = ""
	while ( (c=get(f)) != Eof ) {
		ch = ascii(c)
		if ( ch == "\n" ) {
			break
		}
		s += ch
	}
	return(s)
}

function getpnmword(f) {
	if ( Used < sizeof(Words) ) {
		return(Words[Used++])
	}
	while (1) {
		ln = get(f)
		if ( ln == Eof )
			return(Eof)
		Words = split(ln)
		if ( sizeof(Words) > 0 )
			break;
	}
	Used = 0
	return (Words[Used++])
}

