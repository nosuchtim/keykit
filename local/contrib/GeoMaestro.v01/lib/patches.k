function bank(msb, lsb, ch)		# change la banque de MIDI programs sur le canal ch
{
	# LSB, petit index, le seul pertinent pour mes configurations
	# MSB, gros index, généralement 0 donc

	if ( nargs() != 3 ) {
    		print("Usage: bank(msb,lsb,channel)")
    		return('')
  	}

	ph = phrase("'xb" + Hexa16(ch-1) + "00" + Hexa(msb) + "'")		 
	ph += phrase("'xb" + Hexa16(ch-1) + "20" + Hexa(lsb) + "'")			
	realmidi(ph)		 
	return(ph)
}

function GM(ch)			# équivalent à bank(0,0,ch), juste plus court...
{
	if ( nargs() != 1 ) {
    		print("Usage: GM(channel)")
    		return('')
  	}
	
	return(bank(0,0,ch))
}

function Pat(lsb, patch, ch)	# définit complètement l'instrument, banque comprise (pour MSB=0)
{
	if ( nargs() != 3 ) {
    		print("Usage: Pat(lsb,patch number [1..128],channel)")
    		return('')
  	}
	pb = bank(0,lsb,ch)
	realmidi(pgch = progchange(patch, ch))
	return(pb + pgch)
}

function PAC(lsb, patch, ch)		# idem mais on démarre en 0: compatibilité Audio Compositor
{
	if ( nargs() != 3 ) {
    		print("Usage: PAC(lsb,patch number [0..127],channel)")
    		return('')
  	}
	pb = bank(0,lsb,ch)
	realmidi(pgch = progchange(patch+1, ch))
	return(pb + pgch)
}

function test(ch)		# teste le son du canal ch
{
	realtime(phrase("'ac"+string(ch)+", b, c, d, e'"))
	
	return(ch)

}

# Pas de realmidi ici :

function PourAC(lsb, patch, ch)		# PAC sans utiliser realmidi()
{
	if ( nargs() != 3 ) {
    		print("Usage: PAC(lsb,patch number [0..127],channel)")
    		return('')
  	}
	pb = phrase("'xb" + Hexa16(ch-1) + "00" + Hexa(0) + "'")		 
	pb += phrase("'xb" + Hexa16(ch-1) + "20" + Hexa(lsb) + "'")	
	pb.time += 1
	pgch = progchange(patch+1, ch)
	pgch.time += 2		# le bank change doit précéder le pg change... 

	pourac = pb | pgch
	pourac.length = 2
	return (pourac)
}


########################### facilités...

function Xylo(ch) {return (PourAC(70,0,ch)) }
function WXylo(ch) {return (PourAC(70,3,ch)) }
function Viola(ch) {return (PourAC(50,0,ch)) }
function Violin(ch) {return (PourAC(50,10,ch)) }

function Contrabass(ch) {return (PourAC(50,20,ch)) }
function SlapBass(ch) {return (PourAC(30,6,ch)) }
function JazzBass(ch) {return (PourAC(30,10,ch)) }
function PanPipes(ch) {return (PourAC(11,0,ch)) }

function Harpsichord(ch) {return (PourAC(21,0,ch)) }
function PianoWT(ch) {return (PourAC(20,0,ch)) }
function Guitar(ch) {return (PourAC(51,24,ch)) }
function EGuitar(ch) {return (PourAC(52,11,ch)) }

function IndexPourAC() 
{
print("Xylo")
print("WXylo")
print("Viola")
print("Violin")

print("Contrabass")
print("SlapBass")
print("JazzBass")
print("PanPipes")

print("Harpsichord")
print("PianoWT")
print("Guitar")
print("EGuitar")
}