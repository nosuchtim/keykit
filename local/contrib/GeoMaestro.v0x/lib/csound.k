################################################################################
#
#    GeoMaestro v1.0
#    Copyright (C) 2000  Stéphane Rollandin (hepta@infonie.fr)
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA
#
################################################################################

function PrintScore(lin)	# lin peut aussi être un événement
{
	if ((InitScore() != "")&&(!("nodur" in lin))) print(InitScore())
	if ("score" in lin)
	   if (lin["score"][0] > 0)
	      for (l=1; l <= lin["score"][0]; l++)
		  print(string(l)+":  ",RemplaceInStr(lin["score"][l],"\t","  "))
}


function ReadScore(fname)
{
	sc = [0=0]

	f = open(fname)
	while ((l = get(f)) != Eof)
	      sc[++sc[0]] = RemplaceInStr(RemplaceInStr(l,"\r",""),"\n","")

	close(f)

	return (sc)
}

function ExScore(lin, fname)	# lin peut aussi être un événement
{
	f = open(fname, "w")
	if (InitScore() != "") put(f, InitScore())
	if ("score" in lin)
	   if (lin["score"][0] > 0)
	      for (l=1; l <= lin["score"][0]; l++)
		  put(f, lin["score"][l] + "\n")
	close(f)
}

function InitScore()
{
	is = ""
	for (ch=1; ch <= NbCan; ch++)
	    if ("score" in Ev[ch]) if (Ev[ch]["score"][0] > 0)
	       for (l=1; l <= Ev[ch]["score"][0]; l++)
		   is += Ev[ch]["score"][l]+"\n"
	return (is)
}		   




function AjouteAuScore(temps, score, tsco)	# appelée par ProjSeg et ProjCer
{
    if (0 in tsco)
    {
	if (temps >= 0) tsco = SCp2Clicks(tsco, temps)	# fixe les paramètres p2 du score pour t=temps
	ind = score[0]
	for (n=1; n<= tsco[0]; n++)
	    score[ind+n] = tsco[n]
	score[0] += tsco[0]
    }

    return (ArCopy(score))
}

function SCp2Clicks(score, t)	# ajoute à p2 la valeur correspondant au temps t
				#  pour toutes les lignes de score ("array")
				#  t est exprimé en Clicks	
{
	tens = t/float(seconds(1))			# tens =  t en secondes
	if (score[0]>0) for (n=1; n<= score[0]; n++)
	    score[n] = SCpn(score[n], 2, SCgetpn(score[n],2)+tens)

	return(ArCopy(score))
}


function SCpn(lsco, pn, val, d)	# donne la valeur val au parametre numéro pn (s'il existe)
				# lsco = ligne de score
				# d = nbe de chiffres après la virgule (defaut: CS_DIGITS)
{
	if (nargs() == 3) d = CS_DIGITS

	if (split(lsco," ")[0] ~~ "i")   # sinon, ce n'est pas une commande d'instrument
	{
	  spl = split(lsco,"\t ")
	  if (pn == 1)
	    spl[0] = "i"+string(val)
	  else if ((pn-1) in spl)
	     spl[pn-1] = string(Arrondi(pow(10,CS_DIGITS)*string(val))*pow(10,-CS_DIGITS))

	  lsco = ""
	  for (n = 1; n<= sizeof(spl); n++)
	      lsco = lsco+spl[n-1]+"\t"
	}

	return (lsco)
}

function SCgetpn(lsco, pn)	# retourne le paramètre pn de la ligne de score lsco
{
    if (split(lsco," ")[0] ~~ "i")    # sinon, ce n'est pas une ligne d'instrument !
    {
	spl = split(lsco,"\t ")
	if (pn == 1)
	   return (integer(split(spl[0],"i")[0]))
	else if ((pn-1) in spl)
	   return (float(spl[pn-1]))
	else return ("nope")		# pn n'existe pas
    }
    else return (";")			# ligne de commentaire !
}

function SCpnAdd(lsco, pn, add, d)		# ajoute add au paramètre pn (s'il existe)
{
	if (nargs() == 3) d = CS_DIGITS
	return (SCpn(lsco,pn,SCgetpn(lsco,pn)+add, d))
}



