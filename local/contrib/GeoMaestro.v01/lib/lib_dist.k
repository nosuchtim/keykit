

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
	12 = "RandomAuLoin"
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


	# Param�tres par d�faut des fonctions Volume[]()
	VOL_PARA = 0.5
	VOL_DEF = 63
	VOL_DR = 2


	# Param�tres par d�faut des fonctions Pit[]()
	PIT_ORANGE = 2
	PIT_FDIST = 5


	# Param�tres par d�faut des fonctions Pan[]()
	PAN_FDIST = 10


	# Param�tres par d�faut des fonctions Dur[]()
	DUR_MINI = 30
	DUR_FDIST = 50
}


#####################################  Fonctions de distortion:
#
# apr�s d�finition, compl�ter le tableau que retourne choice_of_distortions() ci-dessus
# et �ventuellement les deux autres fonctions relatives aux param�tres
# 
# Toutes les fonctions sont appel�es par CoreModes() avec les param�tres suivant:
#	 ph	 nodur initial
#	 pan	 c�t� o� se trouve l'�v�nement (-1 pour la gauche, +1 pour la droite)
#	 dist	 distance au support de projection
#	 ch	 canal GeoMaestro de l'�v�nement
#		 (ce dernier peut �tre utilis� pour d�finir des param�tres sp�cifiques 
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

function Vexp1(ph, pan, distance)		# fortement d�croissante
{ return (ph.vol*(exp(-distance)-1))}		# (� moiti� pour d~=1, v0 pour d>5)


function Vexp10(ph, pan, distance)		# d�croissance exponentielle "moyenne"
{ return (ph.vol*(exp(-0.5*distance)-1))}	# (� moiti� pour d=2, v0 pour d>10)


function VexpPARA(ph, pan, distance)		# d�croissance exponentielle 
{ return (ph.vol*(exp(-VOL_PARA*distance)-1))}	#  PARAm�tr�e


function MemeVol(ph, pan, dist)			# la fonction qui ne fait rien
	 {return (0)}


function VolDEF()				# volume constant, param�tr�
	 {return (VOL_DEF)}


function D2(ph, pan, dist)			# zone circulaire de rayon VOL_DR, rien au-del� 
	 {if (dist <= VOL_DR) {return (0)} else {return (-127)}}


function VolDansDisque(...)
{	 return (D2(...))  }


################ PIT
#
#	retour: integer entre 0 et 127
#		qui sera AJOUTE au ph.pitch



function BasicPitch()			# la fonction qui ne fait rien...
	 {return (0)}


function DopplerLateral(ph, pan, distance)  # monte d'un cot� et descend de l'autre
	 {return (pan*integer(Minimum(PIT_FDIST*distance,PIT_ORANGE*12)))}


function FondBasses(ph, pan, distance)	  # jusqu'� -PIT_ORANGE octaves au loin
	 {return (-1*integer(Minimum(PIT_FDIST*distance, PIT_ORANGE*12)))}


function FondAigu(ph, pan, distance)	  # jusqu'� +PIT_ORANGE octaves au loin
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
## PB[]
##
## (Fonctions de pitch bend: elles retournent une phrase de controleurs)
##

# PB: de 0 (vers bas) � 127 (vers haut), 64 �tant neutre
# (ceci parce que le premier hexa est fix� � 00 dans ProjSeg et ProjCer)


function NoBend()			# la fonction qui n'agit pas...
	 {return ('')}


function PetitDoppler(ph, pan, dist, ch)	# � tester !
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


