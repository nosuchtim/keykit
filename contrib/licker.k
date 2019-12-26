#Elton Joe
#April 26, 2005
#Digital Sound and Music Processing Seminar
#Smith College

# VARIATION TYPE RANDOMIZER ####################################################

# The purpose of this section is to provide matching variations for both the
# chords and the bass line.

# rand(2) is a random integer from 0 to 1
# rand(3) is a random integer from 0 to 2
# rand(4) is a random integer from 0 to 3
# etc.

A_part1_variation_type = rand(9)
A_part2_variation_type = rand(4)
A_ending_variation_type = rand(3)

B_part1_variation_type = rand(4)
B_part2_variation_type = rand(4)
B_part3_variation_type = rand(4)
B_part4_variation_type = rand(4)

################################################################################

# CHORDS #######################################################################

function A_part1_chords(instances)
{
	# |C     A     |D     G     |
	A_part1_chords_variation_0 = 'c e g, c e g, a c+ e, a c+ e, d f+ a, d f+ a, g b d, g b d'
	
	# |C     A     |Dm    G     |
	A_part1_chords_variation_1 = 'c e g, c e g, a c+ e, a c+ e, d f a, d f a, g b d, g b d'
	
	# |C     A     |F#dim G     |
	A_part1_chords_variation_2 = 'c e g, c e g, a c+ e, a c+ e, f+ a c, f+ a c, g b d, g b d'
	
	# |C     Am    |D     G     |
	A_part1_chords_variation_3 = 'c e g, c e g, a c e, a c e, d f+ a, d f+ a, g b d, g b d'
	
	# |C     Am    |Dm    G     |
	A_part1_chords_variation_4 = 'c e g, c e g, a c e, a c e, d f a, d f a, g b d, g b d'
	
	# |C     Am    |F#dim G     |
	A_part1_chords_variation_5 = 'c e g, c e g, a c e, a c e, f+ a c, f+ a c, g b d, g b d'
	
	# |C     C#dim |D     G     |
	A_part1_chords_variation_6 = 'c e g, c e g, c+ e g, c+ e g, d f+ a, d f+ a, g b d, g b d'
	
	# |C     C#dim |Dm    G     |
	A_part1_chords_variation_7 = 'c e g, c e g, c+ e g, c+ e g, d f a, d f a, g b d, g b d'
	
	# |C     C#dim |F#dim G     |
	A_part1_chords_variation_8 = 'c e g, c e g, c+ e g, c+ e g, f+ a c, f+ a c, g b d, g b d'
	
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(A_part1_variation_type == 0)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= A_part1_chords_variation_0 % y
			}
		}
		
		if(A_part1_variation_type == 1)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= A_part1_chords_variation_1 % y
			}
		}
		
		if(A_part1_variation_type == 2)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= A_part1_chords_variation_2 % y
			}
		}

		if(A_part1_variation_type == 3)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= A_part1_chords_variation_3 % y
			}
		}
		
		if(A_part1_variation_type == 4)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= A_part1_chords_variation_4 % y
			}
		}
		
		if(A_part1_variation_type == 5)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= A_part1_chords_variation_5 % y
			}
		}
		
		if(A_part1_variation_type == 6)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= A_part1_chords_variation_6 % y
			}
		}
		
		if(A_part1_variation_type == 7)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= A_part1_chords_variation_7 % y
			}
		}
		
		if(A_part1_variation_type == 8)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= A_part1_chords_variation_8 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

function A_part2_chords(instances)
{
	# |C     C7    |F     G     |
	A_part2_chords_variation_0 = 'c e g, c e g, c e g b-, c e g b-, f a c, f a c, g b d, g b d'
	
	# |C     C7    |F     Fm    |
	A_part2_chords_variation_1 = 'c e g, c e g, c e g b-, c e g b-, f a c, f a c, f a- c, f a- c'
	
	# |C     Edim  |F     G     |
	A_part2_chords_variation_2 = 'c e g, c e g, e g b-, e g b-, f a c, f a c, g b d, g b d'
	
	# |C     Edim  |F     Fm    |
	A_part2_chords_variation_3 = 'c e g, c e g, e g b-, e g b-, f a c, f a c, f a- c, f a- c'
	
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(A_part2_variation_type == 0)
		{
			for(y = 1; y <=26; y++)
			{
				phrase |= A_part2_chords_variation_0 % y
			}
		}
		
		if(A_part2_variation_type == 1)
		{
			for(y = 1; y <=26; y++)
			{
				phrase |= A_part2_chords_variation_1 % y
			}
		}
		
		if(A_part2_variation_type == 2)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= A_part2_chords_variation_2 % y
			}
		}
		
		if(A_part2_variation_type == 3)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= A_part2_chords_variation_3 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

function A_ending_chords(instances)
{
	# |C     G     |C           |
	A_ending_chords_variation_0 = 'c e g, c e g, g b d, g b d, cd384 ed384 gd384'
	
	# |Dm    G     |C           |
	A_ending_chords_variation_1 = 'd f a, d f a, g b d, g b d, cd384 ed384 gd384'
	
	# |F     G     |C           |
	A_ending_chords_variation_2 = 'f a c, f a c, g b d, g b d, cd384 ed384 gd384'
	
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(A_ending_variation_type == 0)
		{
			for(y = 1; y <=15; y++)
			{
				phrase |= A_ending_chords_variation_0 % y
			}
		}
		
		if(A_ending_variation_type == 1)
		{
			for(y = 1; y <=15; y++)
			{
				phrase |= A_ending_chords_variation_1 % y
			}
		}
		
		if(A_ending_variation_type == 2)
		{
			for(y = 1; y <=15; y++)
			{
				phrase |= A_ending_chords_variation_2 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

function B_part1_chords(instances)
{
	# |E           |E           |
	B_part1_chords_variation_0 = 'e g+ b, e g+ b, e g+ b, e g+ b, e g+ b, e g+ b, e g+ b, e g+ b'
	
	# |E           |E  /  /  Bb7|
	B_part1_chords_variation_1 = 'e g+ b, e g+ b, e g+ b, e g+ b, e g+ b, e g+ b, e g+ b, b- d f a-'
	
	# |E      Edim |E           |
	B_part1_chords_variation_2 = 'e g+ b, e g+ b, e g b-, e g b-, e g+ b, e g+ b, e g+ b, e g+ b'
	
	# |E      Edim |E  /  /  Bb7|
	B_part1_chords_variation_3 = 'e g+ b, e g+ b, e g b-, e g b-, e g+ b, e g+ b, e g+ b, b- d f a-'
	
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(B_part1_variation_type == 0)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= B_part1_chords_variation_0 % y
			}
		}
		
		if(B_part1_variation_type == 1)
		{
			for(y = 1; y <=25; y++)
			{
				phrase |= B_part1_chords_variation_1 % y
			}
		}
		
		if(B_part1_variation_type == 2)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= B_part1_chords_variation_2 % y
			}
		}
		
		if(B_part1_variation_type == 3)
		{
			for(y = 1; y <=25; y++)
			{
				phrase |= B_part1_chords_variation_3 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

function B_part2_chords(instances)
{
	# |A           |A           |
	B_part2_chords_variation_0 = 'a c+ e, a c+ e, a c+ e, a c+ e, a c+ e, a c+ e, a c+ e, a c+ e'
	
	# |A           |A  /  /  Eb7|
	B_part2_chords_variation_1 = 'a c+ e, a c+ e, a c+ e, a c+ e, a c+ e, a c+ e, a c+ e, e- g b- d-'
	
	# |A      Adim |A           |
	B_part2_chords_variation_2 = 'a c+ e, a c+ e, a c e-, a c e-, a c+ e, a c+ e, a c+ e, a c+ e'
	
	# |A      Adim |A  /  /  Eb7|
	B_part2_chords_variation_3 = 'a c+ e, a c+ e, a c e-, a c e-, a c+ e, a c+ e, a c+ e, e- g b- d-'
	
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(B_part2_variation_type == 0)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= B_part2_chords_variation_0 % y
			}
		}
		
		if(B_part2_variation_type == 1)
		{
			for(y = 1; y <=25; y++)
			{
				phrase |= B_part2_chords_variation_1 % y
			}
		}
		
		if(B_part2_variation_type == 2)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= B_part2_chords_variation_2 % y
			}
		}
		
		if(B_part2_variation_type == 3)
		{
			for(y = 1; y <=25; y++)
			{
				phrase |= B_part2_chords_variation_3 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

function B_part3_chords(instances)
{
	# |D           |D           |
	B_part3_chords_variation_0 = 'd f+ a, d f+ a, d f+ a, d f+ a, d f+ a, d f+ a, d f+ a, d f+ a'
	
	# |D           |D  /  /  Ab7|
	B_part3_chords_variation_1 = 'd f+ a, d f+ a, d f+ a, d f+ a, d f+ a, d f+ a, d f+ a, a- c e- g-'
	
	# |D      Ddim |D           |
	B_part3_chords_variation_2 = 'd f+ a, d f+ a, d f a-, d f a-, d f+ a, d f+ a, d f+ a, d f+ a'
	
	# |D      Ddim |D  /  /  Ab7|
	B_part3_chords_variation_3 = 'd f+ a, d f+ a, d f a-, d f a-, d f+ a, d f+ a, d f+ a, a- c e- g-'
	
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(B_part3_variation_type == 0)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= B_part3_chords_variation_0 % y
			}
		}
		
		if(B_part3_variation_type == 1)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= B_part3_chords_variation_1 % y
			}
		}
		
		if(B_part3_variation_type == 2)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= B_part3_chords_variation_2 % y
			}
		}
		
		if(B_part3_variation_type == 3)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= B_part3_chords_variation_3 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

function B_part4_chords(instances)
{
	# |G           |G           |
	B_part4_chords_variation_0 = 'g b d, g b d, g b d, g b d, g b d, g b d, g b d, g b d'
	
	# |G           |G  /  / Gaug|
	B_part4_chords_variation_1 = 'g b d, g b d, g b d, g b d, g b d, g b d, g b d, g b d+'
	
	# |G      Gdim |G           |
	B_part4_chords_variation_2 = 'g b d, g b d, g b- d-, g b- d-, g b d, g b d, g b d, g b d'
	
	# |G      Gdim |G  /  / Gaug|
	B_part4_chords_variation_3 = 'g b d, g b d, g b- d-, g b- d-, g b d, g b d, g b d, g b d+'
	
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(B_part4_variation_type == 0)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= B_part4_chords_variation_0 % y
			}
		}
		
		if(B_part4_variation_type == 1)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= B_part4_chords_variation_1 % y
			}
		}
		
		if(B_part4_variation_type == 2)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= B_part4_chords_variation_2 % y
			}
		}
		
		if(B_part4_variation_type == 3)
		{
			for(y = 1; y <=24; y++)
			{
				phrase |= B_part4_chords_variation_3 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

################################################################################

# BASS #########################################################################

function A_part1_bass(instances)
{
	# |C     A     |D     G     |
	A_part1_bass_variation_0 = 'co2d192, a, d, g'
	
	# |C     A     |Dm    G     |
	A_part1_bass_variation_1 = 'co2d192, a, d, g'
	
	# |C     A     |F#dim G     |
	A_part1_bass_variation_2 = 'co2d192, a, f+, g'
	
	# |C     Am    |D     G     |
	A_part1_bass_variation_3 = 'co2d192, a, d, g'
	
	# |C     Am    |Dm    G     |
	A_part1_bass_variation_4 = 'co2d192, a, d, g'
	
	# |C     Am    |F#dim G     |
	A_part1_bass_variation_5 = 'co2d192, a, f+, g'
	
	# |C     C#dim |D     G     |
	A_part1_bass_variation_6 = 'co2d192, c+, d, g'
	
	# |C     C#dim |Dm    G     |
	A_part1_bass_variation_7 = 'co2d192, c+, d, g'
	
	# |C     C#dim |F#dim G     |
	A_part1_bass_variation_8 = 'co2d192, c+, f+, g'
	
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(A_part1_variation_type == 0)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= A_part1_bass_variation_0 % y
			}
		}
		
		if(A_part1_variation_type == 1)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= A_part1_bass_variation_1 % y
			}
		}
		
		if(A_part1_variation_type == 2)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= A_part1_bass_variation_2 % y
			}
		}

		if(A_part1_variation_type == 3)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= A_part1_bass_variation_3 % y
			}
		}
		
		if(A_part1_variation_type == 4)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= A_part1_bass_variation_4 % y
			}
		}
		
		if(A_part1_variation_type == 5)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= A_part1_bass_variation_5 % y
			}
		}
		
		if(A_part1_variation_type == 6)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= A_part1_bass_variation_6 % y
			}
		}
		
		if(A_part1_variation_type == 7)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= A_part1_bass_variation_7 % y
			}
		}
		
		if(A_part1_variation_type == 8)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= A_part1_bass_variation_8 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

function A_part2_bass(instances)
{
	# |C     C7    |F     G     |
	A_part2_bass_variation_0 = 'co2d192, c, f, g'
	
	# |C     C7    |F     Fm    |
	A_part2_bass_variation_1 = 'co2d192, c, f, f'
	
	# |C     Edim  |F     G     |
	A_part2_bass_variation_2 = 'co2d192, e, f, g'
	
	# |C     Edim  |F     Fm    |
	A_part2_bass_variation_3 = 'co2d192, e, f, f'
	
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(A_part2_variation_type == 0)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= A_part2_bass_variation_0 % y
			}
		}
		
		if(A_part2_variation_type == 1)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= A_part2_bass_variation_1 % y
			}
		}
		
		if(A_part2_variation_type == 2)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= A_part2_bass_variation_2 % y
			}
		}
		
		if(A_part2_variation_type == 3)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= A_part2_bass_variation_3 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

function A_ending_bass(instances)
{
	# |C     G     |C           |
	A_ending_bass_variation_0 = 'co2d192, g, cd384'
	
	# |Dm    G     |C           |
	A_ending_bass_variation_1 = 'co2d192, g, cd384'
	
	# |F     G     |C           |
	A_ending_bass_variation_2 = 'fo2d192, g, cd384'
	
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(A_ending_variation_type == 0)
		{
			for(y = 1; y <=3; y++)
			{
				phrase |= A_ending_bass_variation_0 % y
			}
		}
		
		if(A_ending_variation_type == 1)
		{
			for(y = 1; y <=3; y++)
			{
				phrase |= A_ending_bass_variation_1 % y
			}
		}
		
		if(A_ending_variation_type == 2)
		{
			for(y = 1; y <=3; y++)
			{
				phrase |= A_ending_bass_variation_2 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

function B_part1_bass(instances)
{
	# |E           |E           |
	B_part1_bass_variation_0 = 'eo2d192, e, e, e'
	
	# |E           |E  /  /  Bb7|
	B_part1_bass_variation_1 = 'eo2d192, e, ed288, b-d96'
	
	# |E      Edim |E           |
	B_part1_bass_variation_2 = 'eo2d192, e, e, e'
	
	# |E      Edim |E  /  /  Bb7|
	B_part1_bass_variation_3 = 'eo2d192, e, ed288, b-d96'
	
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(B_part1_variation_type == 0)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= B_part1_bass_variation_0 % y
			}
		}
		
		if(B_part1_variation_type == 1)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= B_part1_bass_variation_1 % y
			}
		}
		
		if(B_part1_variation_type == 2)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= B_part1_bass_variation_2 % y
			}
		}
		
		if(B_part1_variation_type == 3)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= B_part1_bass_variation_3 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

function B_part2_bass(instances)
{
	# |A           |A           |
	B_part2_bass_variation_0 = 'ao2d192, a, a, a'
	
	# |A           |A  /  /  Eb7|
	B_part2_bass_variation_1 = 'ao2d192, a, ad288, e-d96'
	
	# |A      Adim |A           |
	B_part2_bass_variation_2 = 'ao2d192, a, a, a'
	
	# |A      Adim |A  /  /  Eb7|
	B_part2_bass_variation_3 = 'ao2d192, a, ad288, e-d96'
	
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(B_part2_variation_type == 0)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= B_part2_bass_variation_0 % y
			}
		}
		
		if(B_part2_variation_type == 1)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= B_part2_bass_variation_1 % y
			}
		}
		
		if(B_part2_variation_type == 2)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= B_part2_bass_variation_2 % y
			}
		}
		
		if(B_part2_variation_type == 3)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= B_part2_bass_variation_3 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

function B_part3_bass(instances)
{
	# |D           |D           |
	B_part3_bass_variation_0 = 'do2d192, d, d, d'
	
	# |D           |D  /  /  Ab7|
	B_part3_bass_variation_1 = 'do2d192, d, dd288, a-d96'
	
	# |D      Ddim |D           |
	B_part3_bass_variation_2 = 'do2d192, d, d, d'
	
	# |D      Ddim |D  /  /  Ab7|
	B_part3_bass_variation_3 = 'do2d192, d, dd288, a-d96'
	
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(B_part3_variation_type == 0)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= B_part3_bass_variation_0 % y
			}
		}
		
		if(B_part3_variation_type == 1)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= B_part3_bass_variation_1 % y
			}
		}
		
		if(B_part3_variation_type == 2)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= B_part3_bass_variation_2 % y
			}
		}
		
		if(B_part3_variation_type == 3)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= B_part3_bass_variation_3 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

function B_part4_bass(instances)
{
	# |G           |G           |
	B_part4_bass_variation_0 = 'go2d192, g, g, g'
	
	# |G           |G  /  / Gaug|
	B_part4_bass_variation_1 = 'go2d192, g, g, g'
	
	# |G      Gdim |G           |
	B_part4_bass_variation_2 = 'go2d192, g, g, g'
	
	# |G      Gdim |G  /  / Gaug|
	B_part4_bass_variation_3 = 'go2d192, g, g, g'
	
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(B_part4_variation_type == 0)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= B_part4_bass_variation_0 % y
			}
		}
		
		if(B_part4_variation_type == 1)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= B_part4_bass_variation_1 % y
			}
		}
		
		if(B_part4_variation_type == 2)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= B_part4_bass_variation_2 % y
			}
		}
		
		if(B_part4_variation_type == 3)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= B_part4_bass_variation_3 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

################################################################################

# DRUMS (INDIVIDUAL LINES) #####################################################

#The following line was only used to help me line up the notes.
#instrument = '1234567890, 1234567890, 1234567890, 1234567890, 1234567890, 1234567890, 1234567890, 1234567890'

#Bass Drum, All-purpose
Bassdrum0   = 'p36d96c10,              rd96,                   p36d48,     p36d48,     rd48,       p36d48    '
Bassdrum1   = 'p36d48c10,  p36d48,     rd48,       p36d48,     p36d48,     p36d48,     rd48,       p36d48    '
Bassdrum2   = 'p36d48c10,  rd24,p36d72,            p36d72,         p36d72,             p36d48,     p36d48    '
Bassdrum3   = 'p36d96c10,              rd48,       p36d96,                 p36d72,         p36d72            '


#Snare Drum, Steady
Snaredrum0  = 'rd96,                   p38d96c10,              rd96,                   p38d96                '
Snaredrum1  = 'rd96,                   p38d96c10,              rd24, p38d72,           p38d96                '

#Snare Drum, Fills
Snaredrum2  = 'p38d96c10,              p38d96,                 p38d24,p38d24, p38d24,p38d24, p38d24,p38d24, p38d24,p38d24'
Snaredrum3  = 'p38d96c10,              p38d96,                 p38d8,p38d8,p38d8, p38d8,p38d8,p38d8, p38d8,p38d8,p38d8, p38d8,p38d8,p38d8'
Snaredrum4  = 'r48,        p38d72c10,      p38d72,             p38d72,         p38d72,             p38d48    '


#Closed hi-hat, straight eighths
Hihat0      = 'p42d48c10,  p42d48,     p42d48,     p42d48,     p42d48,     p42d48,     p42d48,     p42d48    '

#Closed hi-hat, two swing variations
Hihat1      = 'p42d48c10,p42d32,p42d16,p42d48,  p42d32,p42d16, p42d48,  p42d32,p42d16, p42d48,  p42d32,p42d16'
Hihat2      = 'p42d32c10,p42d16,p42d48,p42d32,  p42d16,p42d48, p42d32,  p42d16,p42d48, p42d32,  p42d16,p42d48'

#Ride Cymbal, two swing variations
Hihat3      = 'p59d48c10,p59d32,p59d16,p59d48,  p59d32,p59d16, p59d48,  p59d32,p59d16, p59d48,  p59d32,p59d16'
Hihat4      = 'p59d32c10,p59d16,p59d48,p59d32,  p59d16,p59d48, p59d32,  p59d16,p59d48, p59d32,  p59d16,p59d48'


#Crash Cymbal
Crash0      = 'rd288,                                                                  p49d96c10'
Crash1      = 'p49d384c10                                                                       '

################################################################################

# DRUMS (VARIATION TYPE RANDOMIZER) ############################################

# rand(2) is a random integer from 0 to 1
# rand(3) is a random integer from 0 to 2
# rand(4) is a random integer from 0 to 3
# etc.

Bassdrum_steady_variation_type = rand(4)
Snaredrum_steady_variation_type = rand(2)
Snaredrum_fills_variation_type = rand(3)
Hihat_steady_variation_type = rand(5)
Crash_ending_variation_type = rand(2)

################################################################################

# DRUMS (BEAT DESIGNER) ########################################################

function bassdrum_steady_variation_generator(instances)
{
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(Bassdrum_steady_variation_type == 0)
		{
			for(y = 1; y <=6; y++)
			{
				phrase |= Bassdrum0 % y
			}
		}
		
		if(Bassdrum_steady_variation_type == 1)
		{
			for(y = 1; y <=8; y++)
			{
				phrase |= Bassdrum1 % y
			}
		}
	
		if(Bassdrum_steady_variation_type == 2)
		{
			for(y = 1; y <=7; y++)
			{
				phrase |= Bassdrum2 % y
			}
		}
		
		if(Bassdrum_steady_variation_type == 3)
		{
			for(y = 1; y <=5; y++)
			{
				phrase |= Bassdrum3 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

function snaredrum_steady_variation_generator(instances)
{
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(Snaredrum_steady_variation_type == 0)
		{
			for(y = 1; y <=4; y++)
			{
				phrase |= Snaredrum0 % y
			}
		}
		
		if(Snaredrum_steady_variation_type == 1)
		{
			for(y = 1; y <=5; y++)
			{
				phrase |= Snaredrum1 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

function snaredrum_fills_variation_generator(instances)
{
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(Snaredrum_fills_variation_type == 0)
		{
			for(y = 1; y <=10; y++)
			{
				phrase |= Snaredrum2 % y
			}
		}
		
		if(Snaredrum_fills_variation_type == 1)
		{
			for(y = 1; y <=14; y++)
			{
				phrase |= Snaredrum3 % y
			}
		}
		
		if(Snaredrum_fills_variation_type == 2)
		{
			for(y = 1; y <=6; y++)
			{
				phrase |= Snaredrum2 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

function hihat_steady_variation_generator(instances)
{
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(Hihat_steady_variation_type == 0)
		{
			for(y = 1; y <=8; y++)
			{
				phrase |= Hihat0 % y
			}
		}
		
		if(Hihat_steady_variation_type == 1)
		{
			for(y = 1; y <=12; y++)
			{
				phrase |= Hihat1 % y
			}
		}
		
		if(Hihat_steady_variation_type == 2)
		{
			for(y = 1; y <=12; y++)
			{
				phrase |= Hihat2 % y
			}
		}
		
		if(Hihat_steady_variation_type == 3)
		{
			for(y = 1; y <=12; y++)
			{
				phrase |= Hihat3 % y
			}
		}
		
		if(Hihat_steady_variation_type == 4)
		{
			for(y = 1; y <=12; y++)
			{
				phrase |= Hihat4 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

function crash_ending_variation_generator(instances)
{
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		if(Crash_ending_variation_type == 0)
		{
			for(y = 1; y <=2; y++)
			{
				phrase |= Crash0 % y
			}
		}
		
		if(Crash_ending_variation_type == 1)
		{
			for(y = 1; y <=1; y++)
			{
				phrase |= Crash1 % y
			}
		}
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

Bassdrum_steady = bassdrum_steady_variation_generator(1)
Snaredrum_steady = snaredrum_steady_variation_generator(1)
Snaredrum_fills = snaredrum_fills_variation_generator(1)
Hihat_steady = hihat_steady_variation_generator(1)
Crash_ending = crash_ending_variation_generator(1)

Drums_steady_variation = ''
Drums_steady_variation = Bassdrum_steady | Snaredrum_steady | Hihat_steady

Drums_fills_variation = ''
Drums_fills_variation = Bassdrum_steady | Snaredrum_fills

Drums_ending_variation = ''
Drums_ending_variation = Crash_ending

################################################################################

# DRUMS (INSTANCES COMPILER) ###################################################

function drums_steady(instances)
{
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		phrase |= Drums_steady_variation
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

function drums_fills(instances)
{
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		phrase |= Drums_fills_variation
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

function drums_ending(instances)
{
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances; x++)
	{
		phrase |= Drums_ending_variation
		
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

################################################################################

# MELODY #######################################################################

function melody_individual_notes()
{
	note0 = 'gd48'
	note1 = 'ad48'
	note2 = 'co4d48'
	note3 = 'do4d48'
	note4 = 'e-o4d48'
	note5 = 'eo4d48'
	note6 = 'rd48'
	
	#This generates a random integer between 0 and 11
	scale_degree_selector = rand(12)
	
	if(scale_degree_selector == 0)
	{
		return(note0)
	}
	
	if(scale_degree_selector == 1)
	{
		return(note1)
	}
	
	if(scale_degree_selector == 2)
	{
		return(note2)
	}
	
	if(scale_degree_selector == 3)
	{
		return(note3)
	}
	
	if(scale_degree_selector == 4)
	{
		return(note4)
	}
	
	if(scale_degree_selector == 5)
	{
		return(note5)
	}
	
	if(scale_degree_selector == 6)
	{
		return(note6)
	}
	
	if(scale_degree_selector == 7)
	{
		return(note6)
	}
	
	if(scale_degree_selector == 8)
	{
		return(note6)
	}
	
	if(scale_degree_selector == 9)
	{
		return(note6)
	}
	
	if(scale_degree_selector == 10)
	{
		return(note6)
	}
	
	if(scale_degree_selector == 11)
	{
		return(note6)
	}
}

function melody_measure_maker(instances)
{
	phrase = ''
	extendedphrase = ''
	
	for(x = 1; x <= instances*8; x++)
	{
		phrase |= melody_individual_notes()
		extendedphrase += phrase
		
		# Reset phrase
		phrase = ''
	}
	
	return(extendedphrase)
}

################################################################################

# VOICE CHOOSER ################################################################

function chords_voicing()
{
	#piano     =  1
	#e piano 1 =  5
	#vibes     = 12
	#perc org  = 18
	#jazz gtr  = 27
	#voice ooh = 54
	
	voice = rand(6)
	
	if(voice == 0)
	{
		chords_post_voiced = progchange(1, 1)
		chords_post_voiced |= Chords_pre_voiced
	}
	
	if(voice == 1)
	{
		chords_post_voiced = progchange(5, 1)
		chords_post_voiced |= Chords_pre_voiced
	}
	
	if(voice == 2)
	{
		chords_post_voiced = progchange(12, 1)
		chords_post_voiced |= Chords_pre_voiced
	}
	
	if(voice == 3)
	{
		chords_post_voiced = progchange(18, 1)
		chords_post_voiced |= Chords_pre_voiced
	}
	
	if(voice == 4)
	{
		chords_post_voiced = progchange(27, 1)
		chords_post_voiced |= Chords_pre_voiced
	}
	
	if(voice == 5)
	{
		chords_post_voiced = progchange(54, 1)
		chords_post_voiced |= Chords_pre_voiced
	}
	
	return(chords_post_voiced)
}

function bass_voicing()
{
	#drawbar org = 17
	#picked bass = 35
	#slap bass   = 37
	#tuba        = 59
	#bassoon     = 71
	
	voice = rand(5)
	
	if(voice == 0)
	{
		bass_post_voiced = progchange(17, 2)
		bass_post_voiced |= Bass_pre_voiced
	}
	
	if(voice == 1)
	{
		bass_post_voiced = progchange(35, 2)
		bass_post_voiced |= Bass_pre_voiced
	}
	
	if(voice == 2)
	{
		bass_post_voiced = progchange(37, 2)
		bass_post_voiced |= Bass_pre_voiced
	}
	
	if(voice == 3)
	{
		bass_post_voiced = progchange(59, 2)
		bass_post_voiced |= Bass_pre_voiced
	}
	
	if(voice == 4)
	{
		bass_post_voiced = progchange(71, 2)
		bass_post_voiced |= Bass_pre_voiced
	}
	
	return(bass_post_voiced)
}

function melody_voicing()
{
	#marimba     = 13
	#drawbar org = 17
	#cello       = 43
	#voice oohs  = 54
	#trumpet     = 57
	#tenor sax   = 67
	#piccolo     = 73
	
	voice = rand(7)
	
	if(voice == 0)
	{
		melody_post_voiced = progchange(13, 3)
		melody_post_voiced |= Melody_pre_voiced
	}
	
	if(voice == 1)
	{
		melody_post_voiced = progchange(17, 3)
		melody_post_voiced |= Melody_pre_voiced
	}
	
	if(voice == 2)
	{
		melody_post_voiced = progchange(43, 3)
		melody_post_voiced |= Melody_pre_voiced
	}
	
	if(voice == 3)
	{
		melody_post_voiced = progchange(54, 3)
		melody_post_voiced |= Melody_pre_voiced
	}
	
	if(voice == 4)
	{
		melody_post_voiced = progchange(57, 3)
		melody_post_voiced |= Melody_pre_voiced
	}
	
	if(voice == 5)
	{
		melody_post_voiced = progchange(67, 3)
		melody_post_voiced |= Melody_pre_voiced
	}
	
	if(voice == 6)
	{
		melody_post_voiced = progchange(73, 3)
		melody_post_voiced |= Melody_pre_voiced
	}
	
	return(melody_post_voiced)
}
	
################################################################################

# MAIN #########################################################################

function main()
{
	# Seed
	rand(-1*Now)
	
	# Part Compilation
	A_chords = A_part1_chords(2)                     + A_part2_chords(1) + A_ending_chords(1)
	B_chords = B_part1_chords(1) + B_part2_chords(1) + B_part3_chords(1) + B_part4_chords(1)
	
	Chords_pre_voiced = A_chords + A_chords + B_chords + A_chords
	Chords_pre_voiced.chan = 1
	
	
	A_bass = A_part1_bass(2)                   + A_part2_bass(1) + A_ending_bass(1)
	B_bass = B_part1_bass(1) + B_part2_bass(1) + B_part3_bass(1) + B_part4_bass(1)
	
	Bass_pre_voiced = A_bass + A_bass + B_bass + A_bass
	Bass_pre_voiced.chan = 2
	
	
	melody_ending = 'co4d384'
	
	melody_B_parts1and2 = melody_measure_maker(4)
	melody_B_parts1and2 = transpose(melody_B_parts1and2, 4)
	
	Melody_A = melody_measure_maker(7) + melody_ending
	Melody_B = melody_B_parts1and2 + melody_measure_maker(4)
	
	Melody_pre_voiced = Melody_A + Melody_A + Melody_B + Melody_A
	Melody_pre_voiced.chan = 3
	
	
	drums = drums_steady(7) + drums_fills(1) + drums_steady(7) + drums_fills(1) + drums_steady(7) + drums_fills(1) + drums_steady(7) + drums_ending(1)
	
	
	# Voice Chooser
	chords = chords_voicing()
	
	bass = bass_voicing()
	bass = transpose(bass, -12)
	
	melody = melody_voicing()
	
	
	#Volume Adjuster
	chords.vol = 55
	bass.vol = 65
	drums.vol = 50
	melody.vol = 80
	
	
	#Arranging
	
	threemeasurerest = ''
	threemeasurerest = 'rd1152'
	
	introchords = A_part2_chords(1) + A_ending_chords(1)
	introbass = A_part2_bass(1) + A_ending_bass(1)
	introdrums = threemeasurerest + drums_fills(1)
	intro = introchords | introbass | introdrums
	
	melody_up_an_octave = transpose(melody, 12)
	
	thirtytwobars_1 = chords | bass | drums | melody
	thirtytwobars_2 = chords | bass | drums
	thirtytwobars_3 = chords | bass | drums | melody_up_an_octave
	
	all = intro + thirtytwobars_1 + thirtytwobars_2 + thirtytwobars_3
	
	return(all)
}

piece = main()
phtomidi(piece,"licker.mid")

################################################################################

# TRANSPOSE ####################################################################

# For reference, here is the function transpose, which is included with keykit
# in the file basic1.k

#name	transpose
#usage	transpose(phrase,amount)
#desc	Transposes the phrase by the specified amount.

#function transpose(phr,amount) {
#	if ( nargs() != 2 ) {
#		print("usage: transpose(phrase,amount)")
#		return('')
#	}
#	phr.pitch += amount
#	return(phr)
#}

################################################################################

# PROGCHANGE ###################################################################

# For reference, here is the function progchange, which is included with keykit
# in the file basic2.k

#name	progchange
#usage	progchange(patchnum,ch)
#desc	Return a program change message, where patchnum is the
#desc	patch number (1-based), and ch is the channel (1-based).

#function progchange(patchnum,ch) {
#	na = nargs()
#	if ( na == 0 ) {
#		print("Usage: progchange(patch,channel)")
#		return('')
#	}
#	if ( na< 2 )
#		ch = 1	# default
#	if ( ch <= 0 || ch > 128 ) {
#		print("Warning, progchange got an invalid channel value: ",ch)
#		return('')
#	}
#	if ( patchnum <= 0 || patchnum > 128) {
#		print("Warning, progchange got an invalid patchnum value: ",patchnum)
#		return('')
#	}
#	p = midibytes(0xc0 | (ch-1), patchnum-1)
#	return(p)
#}

################################################################################

# MIDITOPH.K ###################################################################

# For reference, here are the entire contents of the file miditoph.k, originally
# downloaded from
# http://maven.smith.edu/~jfrankli/354s03/keykit/miditoph.k

# function miditoPh takes a filename (in quotes) of a midi file
#     and turns  it into a phrase array and returns
#     the track indicated by chan (starts at 0 for track 1).
#    General use of channels
#    might confuse it, but it usually works.
# function PhtoMidi takes in a phrase and a filename
#    in quotes, creates a midi file from the phrase and
#    writes it to the filename.
# Judy Franklin

function miditoph(filename, chan)
{
	Phrasearray=[]

	Phrasearray=midifile(filename)

	return (Phrasearray[chan])
}

function phtomidi(ph,filename) 
{
	Myphrasearray=[]
	Myphrasearray[0]=ph

	midifile(Myphrasearray,filename)
}

################################################################################






