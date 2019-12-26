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

function Go()			# (appelée au démarrage dans le postrc)
{
	print("-GéoMaestro-v1.0")

#	Modir = 1		# console en mode direct (::)

	InitStatique()
	Conph = ''			

	Bavard = 0		# Scène de base (en mode silencieux)	
	if (fileexists(BASE+"init.ev"))
	   LoadEv("init", BASE)
	else
	   InitEv()

	if (fileexists(BASE+"init.df"))
	   ReadDF("init", BASE)
	else
	{
	   InitVolume()
	   InitPan()
	   InitPit()
	   InitPB()
	   InitDur()
	   InitCScore()
	}

	if (fileexists(BASE+"init.geo"))	# éléments géométriques en mémoire
	   Geo("init", BASE)
		
#	RestoreChantier()
	
	Bavard = 1		# mode Bavard (les Bprint fonctionnent)
       #DebProf = 1		# mode débuggage (DEBUG à toutes profondeurs)
        DebProf = 5		#		  DEBUG(5,...) et plus seulement 

	Recsched = 1
}

			

#########################################################################################
########								#################
########  Initialisations						#################
########								#################
#########################################################################################



function InitStatique()		# procède à toutes les initialisations
{
	InitConstantes()
	InitParameters()			# ... dans lib_dist.k
	if (typeof(InitVAR) == "function")	# créée par HardCodeVAR (voir console.k)
	   InitVAR()
}
										
			
function InitConstantes()	# Constantes, variables réservées et options
{
	####################################################################################
	# OPTIONS MODIFIABLES ## CUSTOMIZABLE PART #########################################

	# 1) paramètres GeoMaestro (parameters)
	#--------------------------------------

	# Nombre de clicks par centimètre, par défaut
	CPCM = seconds(1)     # ici, une seconde (192 clicks) par centimètre

	# nombre de canaux gérés:
	NbCan = 20	   # 16 midi (à instrument unique)
			   # + 4 fourre-tout GéoMaestro (qui utilisent les
			   #   n derniers canaux midis pour des compositions à n notes)

	# volume minimal pour que persiste une note:
	SILENCE = 10


	# 2) fichiers et chemins (filenames & paths)
	#-------------------------------------------

	# répertoires utiles:
	MDOP=	"../MIDI/"		# les fichiers MIDI sont écrits ici par ExMIDI() & Co.
	MAT=    "../contrib/GeoMaestro/"	# répertoire racine 
	DATA=	MAT+"data/"		
	COMPOS=	MAT+"userlib/"		# doit se trouver dans le Path de KeyKit
	VRAC =	MDOP+"Vrac/"		
	BASE=	COMPOS+"Courant/"	# compositions courantes (dont les Ev au démarrage)

	# Répertoire d'écriture par défaut  (utilisé par RacineN() et FichierN())
	DEFDIR = DATA


	# 3) Système
	#-----------

	# Langue (Langage)
	#	FrenchBlahBlah()
	EnglishBlahBlah()

	# Notepad(): le fichier "nom" sera ouvert par NOTEPAD1+"nom"+NOTEPAD2
	NOTEPAD1 = "Notepad.exe "	        # (pour Windows)
	NOTEPAD2 = ""				# (pour éventuelles options)
	TEMPFILE = DATA+"temp.txt"		# nom de fichier par défaut pour Notepad()


	# 4) CSound
	#----------

	# précision des floats par défaut:
	CS_DIGITS = 2				# cf. SCpn()

	# FIN OPTIONS ## END CUSTOM ########################################################
	####################################################################################




	Pi = 3.14159265358979	

	# console:
	GEOCOMMENT = "Défini à la console:"	# pour Sgeo()
	FT = []					# fonctions de T (history)
	FKK = []				# fonctions de X, Y, N, C (history)
	FIF = []				# tests sur X, Y, N, C (history)
	LOG = []				
	SNARF = []
	GVARS = []				# variables globales à retenir		

	# lignes créées par l'outil graphique:
	RL = []		

	# pour opérations sur les régions:
	Tout = [0=0]	      # région vide (pas de calcul de région effectué)
	EnPlusDe = ""	      # op pour ajouter (OU) la région
	EnMoinsDe = "!"	      # op pour ajouter (OU) le négatif de la région

	# variables globales réservées pour des calculs temporaires:
	# X_, Y_, C_, Ev, Ln, A_, P_, L_
	# G__, K__
	# N_, T__, S_		
	# G__G, N_N
	# Ma, Mb	points définis par la souris dans winterface.k

	# pour utilisation par Excel et par eval():
	Xs = "x"
	Ys = "y"
	Cs = "c"
	Rs = "r"
	Ph = "nodur"
	As = "actif"
	Ss = "s"
	PACs = "PAC"
	Ds = "desc"
	INTERs = "inter"
	RACs = "rac"
	CERs = "cer"
	PAs = "A"
	PBs = "B"
}							


function InitVolume()	# fonction de volume par défaut, pour chaque canal
{
	Volume = []
	for (c=1; c<= NbCan; c++) Volume[c] = "NoChanges"		# défaut	
}


function InitPan()	# fonction de stéréo par défaut, pour chaque canal
{
	Pan = []
	for (c=1; c<= NbCan; c++) Pan[c] = "BasicPan"		# défaut

	Pan[3] = "LargePan"
	Pan[4] = "LargePan"
	Pan[14] = "LargePan"
	Pan[15] = "LargePan"
	Pan[16] = "LargePan"
}


function InitPit()	# fonction de pitch par défaut, pour chaque canal
{
	Pit = []
	for (c=1; c<= NbCan; c++) Pit[c] = "NoChanges"		# défaut

	Pit[3] = "DopplerLateral"
	Pit[4] = "DopplerLateral"
	Pit[14] = "DopplerLateral"
	Pit[15] = "DopplerLateral"	
	Pit[16] = "DopplerLateral"
}


function InitPB()	# fonction de pitch bend par défaut, pour chaque canal
{
	PB = []
	for (c=1; c<= NbCan; c++) PB[c] = "NoBend"		# défaut
}


function InitDur()	# fonction de durée par défaut, pour chaque canal
{
	Dur = []
	for (c=1; c<= NbCan; c++) Dur[c] = "NoChanges"		# défaut
}


function InitEv()		
{							
	Ev = [0=0]			
	for (nc = 1; nc <= NbCan; nc++) {Ev[nc]=[0=0, "PAC"= '']}			
}


function InitCScore()	# fonction de distortion pour scores CSound 
{
	CScore = []
	for (c=1; c<= NbCan; c++) CScore[c] = "KeepScore"		
}




