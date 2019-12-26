

###########################################################################################
########			                       ####################################
######## Formes de Pitch Bend                          ####################################
########			                       ####################################
###########################################################################################

# Formate une phase de Pitch Bends (par exemple enregistrée par DOP sur Virtual Piano)
#  le résultat est épuré des notes éventuelles, démarre à t=0 
#  et, optionnel, est affecté au canal ch


function FormatPB(fnom, ch)
{
	ph = nonnotes(readmf(MDOP+fnom+".mid"))

	infos = ''
	for (n=1;  (ph%n.type != 256) ; n++)  infos = infos|ph%n
	
	ph = ph-infos

	ph.time -= ph%1.time
	ph.length = latest(ph)
	if (nargs() == 2) ph.chan = ch

	return (ph)
}



###########################################################################################
########			                       ####################################
######## Distortion de l'écoulement du temps (gasp !)  ####################################
########			                       ####################################
###########################################################################################



# ex:    exp(x-1)*x

# ex2:   exp(pow((x-1),n))*x	# des formes sympas

# ex3:   pow(x, n)		# accélération au début, ralentissement à la fin 
#	 pow(x, pow(n,-1))	# l'inverse...

function Distort01(ph, fonct)		# ex: fonct = "exp(T_-1)*T_"
{
	if (sizeof(split(fonct, "=")) == 1)
	   fonct = "T="+fonct	

	test = 0
	if (sft = sizeof(FT)) for (i=1; i<= sft; i++) test = test||(fonct == FT[i])
	if (!test) FT[sft+1] = fonct

	debut = ph%1.time
	ph.time -= debut

	duree = latest(ph)
	unsurdur = pow(duree, -1)

	resph = ''

	n = 1
	for (note in ph)
	{
	    T_ = (note.time) * unsurdur

	    eval(fonct)
	    note.time = T*duree

	    resph |= note

	    n++
	    if (n > sizeof(ph))
	       break
	}
	resph.time += debut

	return (resph)
}