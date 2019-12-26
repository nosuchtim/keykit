function stochgen(ph,chunksize) {

	ph = onlynotes(ph)

	Gen = []

	# Fill in the starting chunk
	ch = ''
	for ( n=1; n<chunksize; n++ ) {
		ch += strip(ph%n)
	}
	ch = strip(ch)
	limit = sizeof(ph)

	# Take each successive note, add an entry to the Gen
	# array to indicate that that note can follow the current
	# chunk, then remove the first note of the chunk, add the
	# new note to the end of the chunk, and loop.

	for ( ; n <= limit ; n++ ) {
		nextnt = ph%n
		nextnt.time = 0
		nextnt.length = nextnt.dur
		if ( ! ch in Gen )
			Gen[ch] = ''
		Gen[ch] += nextnt
		ch%1 = ''		# remove 1st note
		if ( sizeof(ch) == 0 )
			ch = ''
		else {
			t1 = ch%(1).time
			ch.time -= t1
			ch.length -= t1
		}
		ch += nextnt
	}
}

function printstoch() {
	for ( nt in Gen ) {
		print("Gen[",nt,"] = ",Gen[nt])
	}
}

function makestoch(cnt) {
	n = 0
	for ( ch in Gen )
		n++
	n = rand(n)
	for ( ch in Gen ) {
		if ( n-- <= 0 )
			break
	}
	ch = phrase(ch)
	result = ch
	while ( cnt-- > 0 ) {
		if ( ! ch in Gen ) {
			print("Terminating condition, ch=",ch)
			break
		}
		choices = Gen[ch]
		if ( sizeof(choices) == 0 ) {
			print("Hey, Gen[",ch,"] is null?")
			break
		}
		choice = choices%(1+rand(sizeof(choices)))
		choice = strip(choice)
		result += choice
		ch%(1)=''
		if ( sizeof(ch) == 0 )
			ch = ''
		else {
			t1 = ch%(1).time
			ch.time -= t1
			ch.length -= t1
		}
		ch += choice
	}
	return(result)
}

# function putstoch() {
# 	sweep(VERTICAL);
# 	cnt = getanum("Enter number of cycles to generate -> ")
# 	if ( cnt > 0 ) {
# 		Pick=makestoch(cnt)
# 		Pick.time += Sweepstart
# 		if ( Sweepdir > 0 )
# 			Pick.time += Sweepleng
# 		gridadd(Pick)
# 		setpick()
# 	}
# }
