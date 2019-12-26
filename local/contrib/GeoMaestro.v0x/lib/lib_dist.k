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


function choice_of_distortions() 
{
	return([
	0 = "NoChanges",
	1 = "BasicPan",
	2 = "LargePan",
	3 = "DopplerLateral",
	4 = "FondBasses",
	5 = "FondAigu",
	6 = "Vexp1",
	7 = "Vexp10",
	8 = "VexpPARA",
	9 = "VolDansDisque",
	10 = "VolDEF",
	11 = "DureAuLoin",
	12 = "RandomAuLoin",
				13 = "KeepScore",
				14 = "NoScore",
				15 = "CStest"
	])
}

function parameters_infos() 
{
	return([
	1 = "PAN_FDIST",
	2 = "PAN_FDIST",
	3 = "PIT_FDIST, PIT_ORANGE",
	4 = "PIT_FDIST, PIT_ORANGE",
	5 = "PIT_FDIST, PIT_ORANGE",
	8 = "VOL_PARA",
	9 = "VOL_DR",
	10 = "VOL_DEF",
	11 = "DUR_MINI, DUR_FDIST",
	12 = "RAND_FDIST"
	])

}

function InitParameters() 
{
	RAND_FDIST = 1


	# Paramètres par défaut des fonctions Volume[]()
	VOL_PARA = 0.5
	VOL_DEF = 63
	VOL_DR = 2


	# Paramètres par défaut des fonctions Pit[]()
	PIT_ORANGE = 2
	PIT_FDIST = 5


	# Paramètres par défaut des fonctions Pan[]()
	PAN_FDIST = 10


	# Paramètres par défaut des fonctions Dur[]()
	DUR_MINI = 30
	DUR_FDIST = 50
}


#####################################  Fonctions de distortion:
#
# après définition, compléter le tableau que retourne choice_of_distortions() ci-dessus
# et éventuellement les deux autres fonctions relatives aux paramètres
# 
# Toutes les fonctions sont appelées par CoreModes() avec les paramètres suivant:
#	 ph	 nodur initial
#	 pan	 côté où se trouve l'évènement (-1 pour la gauche, +1 pour la droite)
#	 dist	 distance au support de projection
#	 ch	 canal GeoMaestro de l'événement
#		 (ce dernier peut être utilisé pour définir des paramètres spécifiques 
#		  au canal)
#
#######################################################################################


function NoChanges() { return(0) }


################ PAN
#
##  pan = -1 (g) ou +1 (d)
#
#   doit retourner un integer entre 0 et 127, 63 correspondant au milieu du panorama


function BasicPan(ph, pan, distance)
	 {return (64 + pan*integer(Minimum(PAN_FDIST*distance,63)))}


function LargePan(ph, pan, distance)
	 {return (64 + pan*integer(Minimum(5*PAN_FDIST*distance,63)))}





################ VOL
#
#	retour: integer entre 0 et 127
#		qui sera AJOUTE au ph.vol

function Vexp1(ph, pan, distance)		# fortement décroissante
{ return (ph.vol*(exp(-distance)-1))}		# (à moitié pour d~=1, v0 pour d>5)


function Vexp10(ph, pan, distance)		# décroissance exponentielle "moyenne"
{ return (ph.vol*(exp(-0.5*distance)-1))}	# (à moitié pour d=2, v0 pour d>10)


function VexpPARA(ph, pan, distance)		# décroissance exponentielle 
{ return (ph.vol*(exp(-VOL_PARA*distance)-1))}	#  PARAmétrée


function MemeVol(ph, pan, dist)			# la fonction qui ne fait rien
	 {return (0)}


function VolDEF()				# volume constant, paramétré
	 {return (VOL_DEF)}


function D2(ph, pan, dist)			# zone circulaire de rayon VOL_DR, rien au-delà 
	 {if (dist <= VOL_DR) {return (0)} else {return (-127)}}


function VolDansDisque(...)
{	 return (D2(...))  }


################ PIT
#
#	retour: integer entre 0 et 127
#		qui sera AJOUTE au ph.pitch



function BasicPitch()			# la fonction qui ne fait rien...
	 {return (0)}


function DopplerLateral(ph, pan, distance)  # monte d'un coté et descend de l'autre
	 {return (pan*integer(Minimum(PIT_FDIST*distance,PIT_ORANGE*12)))}


function FondBasses(ph, pan, distance)	  # jusqu'à -PIT_ORANGE octaves au loin
	 {return (-1*integer(Minimum(PIT_FDIST*distance, PIT_ORANGE*12)))}


function FondAigu(ph, pan, distance)	  # jusqu'à +PIT_ORANGE octaves au loin
	 {return (integer(Minimum(PIT_FDIST*distance, PIT_ORANGE*12)))}



################ DUR
#
#	retour: integer quelconque 
#		qui sera AJOUTE au ph.dur


function MemeDur(ph, pan, dist)
{
	return (0)
}

function DureAuLoin(ph, pan, dist)
{
	return (DUR_MINI+DUR_FDIST*dist   -ph.dur)
}

function RandomAuLoin(ph, pan, dist)
{
	range = integer(RAND_FDIST*dist)
	return (rand(range)-0.5*range)
}


#################################################################################
## CScore[]
##		... voir lib_csound.k

















#################################################################################
## PB[]
##
## (Fonctions de pitch bend: elles retournent une phrase de controleurs)
##

# PB: de 0 (vers bas) à 127 (vers haut), 64 étant neutre
# (ceci parce que le premier hexa est fixé à 00 dans ProjSeg et ProjCer)


function NoBend()			# la fonction qui n'agit pas...
	 {return ('')}


function PetitDoppler(ph, pan, dist, ch)	# à tester !
{
	val = 64+pan*integer(Minimum(25*dist,64))
	return (PB64(ch, val))
}


function PB64(ch, val)	# Un message Pitch Bend avec l'octet principal seulement
{								    # (val entre 0 et 127)
	return (phrase("'xe"+Hexa16(ch-1)+"00"+Hexa(val)+"'"))
}
function PB8K(ch, val)	# Un message Pitch Bend complet
{								    # (val entre 0 et 127*127)
	return (phrase("'xe"+Hexa16(ch-1)+Hexa(val%127)+Hexa(val/127)+"'"))
}


