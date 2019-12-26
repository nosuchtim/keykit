#name	trrackpatch
#usage	trrackpatch(ch,bank,prog)
#desc	Return sysex that changes a parts bank/program.
#desc	Assumes that the 16 parts are assigned to channels 1-16.
#desc	ch is 1-based
#desc	bank is 0-based
#desc	prog is 0-based
function trrackpatch(ch,bank,prog) {
	b = midibytes(
		bankselect(ch,0,bank),
		progchange(prog+1,ch)
		)
	return(b)
}

# This function returns an array containing the names
# of patches of a given type (e.g. "pad", "hard", "percussive", etc.)

function patchmap_types_trrack(type) {
	n=0
	p = []
	if ( "pad" ~~ type ) {
		p[n++] = "Water Space"
		p[n++] = "Mondo'Rimba"
		p[n++] = "Pop Bottle"
		p[n++] = "Pot Covers"
		p[n++] = "Solo Pizzicato"
		p[n++] = "Pluck Bell"
		p[n++] = "Natural Kalimba"
		p[n++] = "Stacc-echo"
		p[n++] = "Music Box / SW1"
		p[n++] = "Sitar"
		p[n++] = "Glockenspiel"
		p[n++] = "SynMallet"
		p[n++] = "Solar Lullaby"
		p[n++] = "Analog Pad"
		p[n++] = "Doo the Vibe Pad"
		p[n++] = "Vocal Motion"
		p[n++] = "Forest Choir"
		p[n++] = "Space Life"
		p[n++] = "Icicle"
		p[n++] = "Rez Motion Sweep"
		p[n++] = "Saw Pad"
		p[n++] = "Synclav Pad"
		p[n++] = "Frozen Crystals"
		p[n++] = "Moon Walking"
		p[n++] = "WAVE STATION"
		p[n++] = "Evolver Pad"
		p[n++] = "TAP RibbonVoices"
		p[n++] = "Vocalscape"
		p[n++] = "Rising The Sun"
	}
	if ( "hard" ~~ type ) {
		p[n++] = "FM.*SA EP"
		p[n++] = "Acoustic Piano"
		p[n++] = "Finger Pickin'"
		p[n++] = "Custom Roads"
		p[n++] = "Marimba"
		p[n++] = "Dyno-E.Piano"
		p[n++] = "Nylon Guitar"
		p[n++] = "Koto"
		p[n++] = "Aftermath"
		p[n++] = "Square Snaps"
		p[n++] = "=Snappy= Clavi"
		p[n++] = "Nylon Harmonics"
		p[n++] = "Steel String Gtr"
		p[n++] = "Killer Organ"
		p[n++] = "Phantom Tines"
		p[n++] = "Dad's JazzGuitar"
		p[n++] = "Synpiano"
		p[n++] = "Funkin' Guitar"
		p[n++] = "Cry Baby Bass"
	}
	if ( "bass" ~~ type ) {
		p[n++] = "Picked Bass2"
		p[n++] = "Picked Bass"	
		p[n++] = "Pull Me Please"
		p[n++] = "WarmPickedBass"
		p[n++] = "Punctured BASS"
		p[n++] = "__Kleer_Bass__"
		p[n++] = "Finger Bass"
		p[n++] = "Thunder Pick"
		p[n++] = "Jacobass"
		p[n++] = "Acoustic Bass"
	}
	if ( "perc" ~~ type ) {
		p[n++] = "Muted Gt."
		p[n++] = "FM.*SA EP"
		p[n++] = "Acoustic Piano"
		p[n++] = "Finger Pickin'"
		p[n++] = "Custom Roads"
		p[n++] = "Marimba"
		p[n++] = "Dyno-E.Piano"
		p[n++] = "Nylon Guitar"
		p[n++] = "Koto"
		p[n++] = "Aftermath"
		p[n++] = "Square Snaps"
		p[n++] = "=Snappy= Clavi"
		p[n++] = "Nylon Harmonics"
		p[n++] = "Steel String Gtr"
		p[n++] = "Killer Organ"
		p[n++] = "Phantom Tines"
		p[n++] = "Dad's JazzGuitar"
		p[n++] = "Synpiano"
		p[n++] = "Funkin' Guitar"
		p[n++] = "Cry Baby Bass"
	}
	if ( "drum" ~~ type ) {
		p[n++] = "Kick Menu 2"
	}
	if ( "vocal" ~~ type ) {
		p[n++] = "JzVoice Thum"
	}

	return(p)
}

function patchmap_trrack() {

	if ( defined(Patchmaptrrack) )
		return(Patchmaptrrack)

	r = []
	n = 0

	r[n++] = [ "name"="Tsunami Warning", "func"="trrackpatch(CH,0,0)"]
	r[n++] = [ "name"="Acoustic Piano", "func"="trrackpatch(CH,0,1)"]
	r[n++] = [ "name"="Alto Sax", "func"="trrackpatch(CH,0,2)"]
	r[n++] = [ "name"="Take Voices", "func"="trrackpatch(CH,0,3)"]
	r[n++] = [ "name"="Finger Pickin'", "func"="trrackpatch(CH,0,4)"]
	r[n++] = [ "name"="VS Bell Boy", "func"="trrackpatch(CH,0,5)"]
	r[n++] = [ "name"="Fretless Bass", "func"="trrackpatch(CH,0,6)"]
	r[n++] = [ "name"="Stereo Strings", "func"="trrackpatch(CH,0,7)"]
	r[n++] = [ "name"="Standard Kit", "func"="trrackpatch(CH,0,8)"]
	r[n++] = [ "name"="Ultra Res. Sweep", "func"="trrackpatch(CH,0,9)"]
	r[n++] = [ "name"="Velocity Organ", "func"="trrackpatch(CH,0,10)"]
	r[n++] = [ "name"="*Tingly* E.Piano", "func"="trrackpatch(CH,0,11)"]
	r[n++] = [ "name"="Stereo Brass", "func"="trrackpatch(CH,0,12)"]
	r[n++] = [ "name"="Natural Kalimba", "func"="trrackpatch(CH,0,13)"]
	r[n++] = [ "name"="RibbonYoHeadOff!", "func"="trrackpatch(CH,0,14)"]
	r[n++] = [ "name"="Indian Duet", "func"="trrackpatch(CH,0,15)"]
	r[n++] = [ "name"="Planet Of Funk", "func"="trrackpatch(CH,0,16)"]
	r[n++] = [ "name"="Dyno-E.Piano", "func"="trrackpatch(CH,0,17)"]
	r[n++] = [ "name"="SweetSilverFlute", "func"="trrackpatch(CH,0,18)"]
	r[n++] = [ "name"="Breath of Life", "func"="trrackpatch(CH,0,19)"]
	r[n++] = [ "name"="Studio Strato", "func"="trrackpatch(CH,0,20)"]
	r[n++] = [ "name"="Tubular Vibes", "func"="trrackpatch(CH,0,21)"]
	r[n++] = [ "name"="Vinyl Rap Bass", "func"="trrackpatch(CH,0,22)"]
	r[n++] = [ "name"="Solo String(SW1)", "func"="trrackpatch(CH,0,23)"]
	r[n++] = [ "name"="Lethal Drum Hit", "func"="trrackpatch(CH,0,24)"]
	r[n++] = [ "name"="That Heaven Vibe", "func"="trrackpatch(CH,0,25)"]
	r[n++] = [ "name"="Rotary Organ", "func"="trrackpatch(CH,0,26)"]
	r[n++] = [ "name"="Dreamy E.Piano", "func"="trrackpatch(CH,0,27)"]
	r[n++] = [ "name"="Hard Trombone", "func"="trrackpatch(CH,0,28)"]
	r[n++] = [ "name"="Mondo'Rimba", "func"="trrackpatch(CH,0,29)"]
	r[n++] = [ "name"="Spectrum Lead", "func"="trrackpatch(CH,0,30)"]
	r[n++] = [ "name"="Adieu Rainforest", "func"="trrackpatch(CH,0,31)"]
	r[n++] = [ "name"="Frozen Crystals", "func"="trrackpatch(CH,0,32)"]
	r[n++] = [ "name"="[| 9A's Piano |]", "func"="trrackpatch(CH,0,33)"]
	r[n++] = [ "name"="Clarinet", "func"="trrackpatch(CH,0,34)"]
	r[n++] = [ "name"="Light Choir", "func"="trrackpatch(CH,0,35)"]
	r[n++] = [ "name"="Nylon Guitar", "func"="trrackpatch(CH,0,36)"]
	r[n++] = [ "name"="Sun Bells", "func"="trrackpatch(CH,0,37)"]
	r[n++] = [ "name"="Acoustic Bass", "func"="trrackpatch(CH,0,38)"]
	r[n++] = [ "name"="The Symphony", "func"="trrackpatch(CH,0,39)"]
	r[n++] = [ "name"="!{Mega-Mix}! Kit", "func"="trrackpatch(CH,0,40)"]
	r[n++] = [ "name"="TECHNOphobic", "func"="trrackpatch(CH,0,41)"]
	r[n++] = [ "name"="Pipe Tutti", "func"="trrackpatch(CH,0,42)"]
	r[n++] = [ "name"="Night Tine EP", "func"="trrackpatch(CH,0,43)"]
	r[n++] = [ "name"="Soft Trumpet", "func"="trrackpatch(CH,0,44)"]
	r[n++] = [ "name"="Vibraphone", "func"="trrackpatch(CH,0,45)"]
	r[n++] = [ "name"="Electric Lead", "func"="trrackpatch(CH,0,46)"]
	r[n++] = [ "name"="Mandolin", "func"="trrackpatch(CH,0,47)"]
	r[n++] = [ "name"="Moon Walking", "func"="trrackpatch(CH,0,48)"]
	r[n++] = [ "name"="Electric Grand", "func"="trrackpatch(CH,0,49)"]
	r[n++] = [ "name"="Oboe", "func"="trrackpatch(CH,0,50)"]
	r[n++] = [ "name"="Harp Heaven", "func"="trrackpatch(CH,0,51)"]
	r[n++] = [ "name"="Lead Guitar/JS-Y", "func"="trrackpatch(CH,0,52)"]
	r[n++] = [ "name"="*Bell * Arena*", "func"="trrackpatch(CH,0,53)"]
	r[n++] = [ "name"="FM Bass", "func"="trrackpatch(CH,0,54)"]
	r[n++] = [ "name"="Solo Violin", "func"="trrackpatch(CH,0,55)"]
	r[n++] = [ "name"="Asian Gong", "func"="trrackpatch(CH,0,56)"]
	r[n++] = [ "name"="Synth Orchestra", "func"="trrackpatch(CH,0,57)"]
	r[n++] = [ "name"="Jazz-Organ 2", "func"="trrackpatch(CH,0,58)"]
	r[n++] = [ "name"="Future Synth", "func"="trrackpatch(CH,0,59)"]
	r[n++] = [ "name"="Trombone Ens.", "func"="trrackpatch(CH,0,60)"]
	r[n++] = [ "name"="Steel Drum", "func"="trrackpatch(CH,0,61)"]
	r[n++] = [ "name"="SnoopDoggy Bass", "func"="trrackpatch(CH,0,62)"]
	r[n++] = [ "name"="Harp", "func"="trrackpatch(CH,0,63)"]
	r[n++] = [ "name"="Dragon's Lair", "func"="trrackpatch(CH,0,64)"]
	r[n++] = [ "name"="Clav Control", "func"="trrackpatch(CH,0,65)"]
	r[n++] = [ "name"="Soprano Sax", "func"="trrackpatch(CH,0,66)"]
	r[n++] = [ "name"="Analog Strings", "func"="trrackpatch(CH,0,67)"]
	r[n++] = [ "name"="Power Chord Plus", "func"="trrackpatch(CH,0,68)"]
	r[n++] = [ "name"="Ancient Bells", "func"="trrackpatch(CH,0,69)"]
	r[n++] = [ "name"="Mono Slap Bass", "func"="trrackpatch(CH,0,70)"]
	r[n++] = [ "name"="Modern Strings", "func"="trrackpatch(CH,0,71)"]
	r[n++] = [ "name"="Percussion Kit", "func"="trrackpatch(CH,0,72)"]
	r[n++] = [ "name"="Synclav Pad", "func"="trrackpatch(CH,0,73)"]
	r[n++] = [ "name"="Garage Organ", "func"="trrackpatch(CH,0,74)"]
	r[n++] = [ "name"="Akkordeon/SW 1&2", "func"="trrackpatch(CH,0,75)"]
	r[n++] = [ "name"="French Horn Ens.", "func"="trrackpatch(CH,0,76)"]
	r[n++] = [ "name"="Music Box / SW1", "func"="trrackpatch(CH,0,77)"]
	r[n++] = [ "name"="3A3A3 Square", "func"="trrackpatch(CH,0,78)"]
	r[n++] = [ "name"="Koto", "func"="trrackpatch(CH,0,79)"]
	r[n++] = [ "name"="Hard-Air Hit", "func"="trrackpatch(CH,0,80)"]
	r[n++] = [ "name"="2A,AAA Fathoms", "func"="trrackpatch(CH,0,81)"]
	r[n++] = [ "name"="Recorder", "func"="trrackpatch(CH,0,82)"]
	r[n++] = [ "name"="Xylospectrum", "func"="trrackpatch(CH,0,83)"]
	r[n++] = [ "name"="Tell A Caster", "func"="trrackpatch(CH,0,84)"]
	r[n++] = [ "name"="Bell Angels", "func"="trrackpatch(CH,0,85)"]
	r[n++] = [ "name"="3A3A3 Mega Bass", "func"="trrackpatch(CH,0,86)"]
	r[n++] = [ "name"="Pizzicato Ens.", "func"="trrackpatch(CH,0,87)"]
	r[n++] = [ "name"="Jazz/Brush Kits", "func"="trrackpatch(CH,0,88)"]
	r[n++] = [ "name"="Analog Power", "func"="trrackpatch(CH,0,89)"]
	r[n++] = [ "name"="Super BX-3", "func"="trrackpatch(CH,0,90)"]
	r[n++] = [ "name"="Musette / SW 1&2", "func"="trrackpatch(CH,0,91)"]
	r[n++] = [ "name"="Mute Trumpet", "func"="trrackpatch(CH,0,92)"]
	r[n++] = [ "name"="African Log Drum", "func"="trrackpatch(CH,0,93)"]
	r[n++] = [ "name"="Mr. Nightmare", "func"="trrackpatch(CH,0,94)"]
	r[n++] = [ "name"="Nylon Harmonics", "func"="trrackpatch(CH,0,95)"]
	r[n++] = [ "name"="Shape Shifter", "func"="trrackpatch(CH,0,96)"]
	r[n++] = [ "name"="Breathy Layers", "func"="trrackpatch(CH,0,97)"]
	r[n++] = [ "name"="Pan Flute", "func"="trrackpatch(CH,0,98)"]
	r[n++] = [ "name"="Doo the Vibe Pad", "func"="trrackpatch(CH,0,99)"]
	r[n++] = [ "name"="12 String Guitar", "func"="trrackpatch(CH,0,100)"]
	r[n++] = [ "name"="Finger Cymbal", "func"="trrackpatch(CH,0,101)"]
	r[n++] = [ "name"="Finger Bass", "func"="trrackpatch(CH,0,102)"]
	r[n++] = [ "name"="Marcato Strings", "func"="trrackpatch(CH,0,103)"]
	r[n++] = [ "name"="BassDrums&Snares", "func"="trrackpatch(CH,0,104)"]
	r[n++] = [ "name"="Rezpad", "func"="trrackpatch(CH,0,105)"]
	r[n++] = [ "name"="Gospel Organ", "func"="trrackpatch(CH,0,106)"]
	r[n++] = [ "name"="Brass Pad", "func"="trrackpatch(CH,0,107)"]
	r[n++] = [ "name"="Tuba", "func"="trrackpatch(CH,0,108)"]
	r[n++] = [ "name"="Staccato Hit!", "func"="trrackpatch(CH,0,109)"]
	r[n++] = [ "name"="Orbiting Probes", "func"="trrackpatch(CH,0,110)"]
	r[n++] = [ "name"="Chorus E.Guitar", "func"="trrackpatch(CH,0,111)"]
	r[n++] = [ "name"="Insectisuicides", "func"="trrackpatch(CH,0,112)"]
	r[n++] = [ "name"="Custom Roads", "func"="trrackpatch(CH,0,113)"]
	r[n++] = [ "name"="The Sax Band", "func"="trrackpatch(CH,0,114)"]
	r[n++] = [ "name"="Martian Winds", "func"="trrackpatch(CH,0,115)"]
	r[n++] = [ "name"="Metal Maniac", "func"="trrackpatch(CH,0,116)"]
	r[n++] = [ "name"="Breathy Bells", "func"="trrackpatch(CH,0,117)"]
	r[n++] = [ "name"="Monster Bass", "func"="trrackpatch(CH,0,118)"]
	r[n++] = [ "name"="Solo Cello", "func"="trrackpatch(CH,0,119)"]
	r[n++] = [ "name"="A1/W Total Kit", "func"="trrackpatch(CH,0,120)"]
	r[n++] = [ "name"="Flutepad", "func"="trrackpatch(CH,0,121)"]
	r[n++] = [ "name"="Pipe Positive", "func"="trrackpatch(CH,0,122)"]
	r[n++] = [ "name"="Shakuhachi", "func"="trrackpatch(CH,0,123)"]
	r[n++] = [ "name"="Velo Orchestra", "func"="trrackpatch(CH,0,124)"]
	r[n++] = [ "name"="Pop Bottle", "func"="trrackpatch(CH,0,125)"]
	r[n++] = [ "name"="The UFO Appears", "func"="trrackpatch(CH,0,126)"]
	r[n++] = [ "name"="Hawaiian Glass", "func"="trrackpatch(CH,0,127)"]
	r[n++] = [ "name"="Sky Diver...", "func"="trrackpatch(CH,1,0)"]
	r[n++] = [ "name"="Compressed Piano", "func"="trrackpatch(CH,1,1)"]
	r[n++] = [ "name"="Growling Tenor", "func"="trrackpatch(CH,1,2)"]
	r[n++] = [ "name"="Mixed Choir", "func"="trrackpatch(CH,1,3)"]
	r[n++] = [ "name"="Steel String Gtr", "func"="trrackpatch(CH,1,4)"]
	r[n++] = [ "name"="Ensemble Bell", "func"="trrackpatch(CH,1,5)"]
	r[n++] = [ "name"="Jacobass", "func"="trrackpatch(CH,1,6)"]
	r[n++] = [ "name"="World Strings", "func"="trrackpatch(CH,1,7)"]
	r[n++] = [ "name"="Processed Kit", "func"="trrackpatch(CH,1,8)"]
	r[n++] = [ "name"="Mine Sweep", "func"="trrackpatch(CH,1,9)"]
	r[n++] = [ "name"="Killer Organ", "func"="trrackpatch(CH,1,10)"]
	r[n++] = [ "name"="Phantom Tines", "func"="trrackpatch(CH,1,11)"]
	r[n++] = [ "name"="Grando Bando", "func"="trrackpatch(CH,1,12)"]
	r[n++] = [ "name"="Xylophone", "func"="trrackpatch(CH,1,13)"]
	r[n++] = [ "name"="Monster Lead", "func"="trrackpatch(CH,1,14)"]
	r[n++] = [ "name"="Sitar", "func"="trrackpatch(CH,1,15)"]
	r[n++] = [ "name"="Hands of Time", "func"="trrackpatch(CH,1,16)"]
	r[n++] = [ "name"="Pro-Stage E.P.", "func"="trrackpatch(CH,1,17)"]
	r[n++] = [ "name"="Piccolo", "func"="trrackpatch(CH,1,18)"]
	r[n++] = [ "name"="BreathyLayerPad", "func"="trrackpatch(CH,1,19)"]
	r[n++] = [ "name"="Dynastrat", "func"="trrackpatch(CH,1,20)"]
	r[n++] = [ "name"="Tubular Bell", "func"="trrackpatch(CH,1,21)"]
	r[n++] = [ "name"="Dark SynBass", "func"="trrackpatch(CH,1,22)"]
	r[n++] = [ "name"="Ensemble & Solo", "func"="trrackpatch(CH,1,23)"]
	r[n++] = [ "name"="Cyber-Impact/SW1", "func"="trrackpatch(CH,1,24)"]
	r[n++] = [ "name"="Solar Ghosts", "func"="trrackpatch(CH,1,25)"]
	r[n++] = [ "name"="Perc Rock Organ", "func"="trrackpatch(CH,1,26)"]
	r[n++] = [ "name"="*Belliano*", "func"="trrackpatch(CH,1,27)"]
	r[n++] = [ "name"="Soft Trombone", "func"="trrackpatch(CH,1,28)"]
	r[n++] = [ "name"="Marimba", "func"="trrackpatch(CH,1,29)"]
	r[n++] = [ "name"="Syn Pipes", "func"="trrackpatch(CH,1,30)"]
	r[n++] = [ "name"="Mandolin Trem", "func"="trrackpatch(CH,1,31)"]
	r[n++] = [ "name"="Aurora Borealis", "func"="trrackpatch(CH,1,32)"]
	r[n++] = [ "name"="Super Grand", "func"="trrackpatch(CH,1,33)"]
	r[n++] = [ "name"="Bass Clarinet", "func"="trrackpatch(CH,1,34)"]
	r[n++] = [ "name"="Boys Choir", "func"="trrackpatch(CH,1,35)"]
	r[n++] = [ "name"="Dad's JazzGuitar", "func"="trrackpatch(CH,1,36)"]
	r[n++] = [ "name"="Pluck Bell", "func"="trrackpatch(CH,1,37)"]
	r[n++] = [ "name"="Jazz Bass (SW1)", "func"="trrackpatch(CH,1,38)"]
	r[n++] = [ "name"="{Slow Strings}", "func"="trrackpatch(CH,1,39)"]
	r[n++] = [ "name"="Psycho Kit", "func"="trrackpatch(CH,1,40)"]
	r[n++] = [ "name"="Hit The Beast", "func"="trrackpatch(CH,1,41)"]
	r[n++] = [ "name"="Pipe Mixture", "func"="trrackpatch(CH,1,42)"]
	r[n++] = [ "name"="MIDI Ensemble", "func"="trrackpatch(CH,1,43)"]
	r[n++] = [ "name"="Medium Trumpet", "func"="trrackpatch(CH,1,44)"]
	r[n++] = [ "name"="Ribbon Rhythm", "func"="trrackpatch(CH,1,45)"]
	r[n++] = [ "name"="Espresso Lead", "func"="trrackpatch(CH,1,46)"]
	r[n++] = [ "name"="Hackbrett", "func"="trrackpatch(CH,1,47)"]
	r[n++] = [ "name"="Random Dancer", "func"="trrackpatch(CH,1,48)"]
	r[n++] = [ "name"="Super Whirly", "func"="trrackpatch(CH,1,49)"]
	r[n++] = [ "name"="Bassoon", "func"="trrackpatch(CH,1,50)"]
	r[n++] = [ "name"="Super Pad", "func"="trrackpatch(CH,1,51)"]
	r[n++] = [ "name"="Stadium Guitar", "func"="trrackpatch(CH,1,52)"]
	r[n++] = [ "name"="Solar Motion", "func"="trrackpatch(CH,1,53)"]
	r[n++] = [ "name"="Euro 8va Bass", "func"="trrackpatch(CH,1,54)"]
	r[n++] = [ "name"="Solo Viola", "func"="trrackpatch(CH,1,55)"]
	r[n++] = [ "name"="Timpani", "func"="trrackpatch(CH,1,56)"]
	r[n++] = [ "name"="Analog Pad", "func"="trrackpatch(CH,1,57)"]
	r[n++] = [ "name"="Jazz-Organ 1", "func"="trrackpatch(CH,1,58)"]
	r[n++] = [ "name"="Brite FM Roads", "func"="trrackpatch(CH,1,59)"]
	r[n++] = [ "name"="Modern Brass", "func"="trrackpatch(CH,1,60)"]
	r[n++] = [ "name"="Balaphone", "func"="trrackpatch(CH,1,61)"]
	r[n++] = [ "name"="Square Wave Lead", "func"="trrackpatch(CH,1,62)"]
	r[n++] = [ "name"="Bouzouki", "func"="trrackpatch(CH,1,63)"]
	r[n++] = [ "name"="Vocal Motion", "func"="trrackpatch(CH,1,64)"]
	r[n++] = [ "name"="=Snappy= Clavi", "func"="trrackpatch(CH,1,65)"]
	r[n++] = [ "name"="Baritone Sax", "func"="trrackpatch(CH,1,66)"]
	r[n++] = [ "name"="Symphonic Pad", "func"="trrackpatch(CH,1,67)"]
	r[n++] = [ "name"="Parker Piezo", "func"="trrackpatch(CH,1,68)"]
	r[n++] = [ "name"="13 Bells Of Bali", "func"="trrackpatch(CH,1,69)"]
	r[n++] = [ "name"="Picked Bass", "func"="trrackpatch(CH,1,70)"]
	r[n++] = [ "name"="ClassicalStrings", "func"="trrackpatch(CH,1,71)"]
	r[n++] = [ "name"="Orch/Ethnic Kits", "func"="trrackpatch(CH,1,72)"]
	r[n++] = [ "name"="Hybrid keys", "func"="trrackpatch(CH,1,73)"]
	r[n++] = [ "name"="Big Old JazzOrg", "func"="trrackpatch(CH,1,74)"]
	r[n++] = [ "name"="Tango / SW 1&2", "func"="trrackpatch(CH,1,75)"]
	r[n++] = [ "name"="Flugelhorn", "func"="trrackpatch(CH,1,76)"]
	r[n++] = [ "name"="Glockenspiel", "func"="trrackpatch(CH,1,77)"]
	r[n++] = [ "name"="Phat Synth Bass", "func"="trrackpatch(CH,1,78)"]
	r[n++] = [ "name"="Shamisen", "func"="trrackpatch(CH,1,79)"]
	r[n++] = [ "name"="The Mind", "func"="trrackpatch(CH,1,80)"]
	r[n++] = [ "name"="Harpsichord", "func"="trrackpatch(CH,1,81)"]
	r[n++] = [ "name"="Tin Flute", "func"="trrackpatch(CH,1,82)"]
	r[n++] = [ "name"="Air Thing", "func"="trrackpatch(CH,1,83)"]
	r[n++] = [ "name"="ExpressmanShadow", "func"="trrackpatch(CH,1,84)"]
	r[n++] = [ "name"="FM Bells", "func"="trrackpatch(CH,1,85)"]
	r[n++] = [ "name"="30303 Rez Bass", "func"="trrackpatch(CH,1,86)"]
	r[n++] = [ "name"="Solo Pizzicato", "func"="trrackpatch(CH,1,87)"]
	r[n++] = [ "name"="Analog/Club Kits", "func"="trrackpatch(CH,1,88)"]
	r[n++] = [ "name"="Synpiano", "func"="trrackpatch(CH,1,89)"]
	r[n++] = [ "name"="Dark Old BX-3", "func"="trrackpatch(CH,1,90)"]
	r[n++] = [ "name"="Jangle heart", "func"="trrackpatch(CH,1,91)"]
	r[n++] = [ "name"="Mute Trombone", "func"="trrackpatch(CH,1,92)"]
	r[n++] = [ "name"="Wooden Slit Drum", "func"="trrackpatch(CH,1,93)"]
	r[n++] = [ "name"="Pipe Reeds", "func"="trrackpatch(CH,1,94)"]
	r[n++] = [ "name"="Banjo Andro", "func"="trrackpatch(CH,1,95)"]
	r[n++] = [ "name"="({ Scanners })", "func"="trrackpatch(CH,1,96)"]
	r[n++] = [ "name"="Power Piano", "func"="trrackpatch(CH,1,97)"]
	r[n++] = [ "name"="Bottle", "func"="trrackpatch(CH,1,98)"]
	r[n++] = [ "name"="City of Angels", "func"="trrackpatch(CH,1,99)"]
	r[n++] = [ "name"="Funkin' Guitar", "func"="trrackpatch(CH,1,100)"]
	r[n++] = [ "name"="Finger Gamelon", "func"="trrackpatch(CH,1,101)"]
	r[n++] = [ "name"="Electric Bass", "func"="trrackpatch(CH,1,102)"]
	r[n++] = [ "name"="Ribbon Strings", "func"="trrackpatch(CH,1,103)"]
	r[n++] = [ "name"="Toms & Cymbals", "func"="trrackpatch(CH,1,104)"]
	r[n++] = [ "name"="Aftermath", "func"="trrackpatch(CH,1,105)"]
	r[n++] = [ "name"="Full Organ", "func"="trrackpatch(CH,1,106)"]
	r[n++] = [ "name"="Pedal Steel", "func"="trrackpatch(CH,1,107)"]
	r[n++] = [ "name"="Hard Trumpet", "func"="trrackpatch(CH,1,108)"]
	r[n++] = [ "name"="Space Hatch", "func"="trrackpatch(CH,1,109)"]
	r[n++] = [ "name"="StadiumSW1=Shore", "func"="trrackpatch(CH,1,110)"]
	r[n++] = [ "name"="Funky Strato", "func"="trrackpatch(CH,1,111)"]
	r[n++] = [ "name"="Out of the myst.", "func"="trrackpatch(CH,1,112)"]
	r[n++] = [ "name"="Birds & Bugs", "func"="trrackpatch(CH,1,113)"]
	r[n++] = [ "name"="Harmonica", "func"="trrackpatch(CH,1,114)"]
	r[n++] = [ "name"="Decaying Organ", "func"="trrackpatch(CH,1,115)"]
	r[n++] = [ "name"="TalkBox Gtr/JS-Y", "func"="trrackpatch(CH,1,116)"]
	r[n++] = [ "name"="Pot Covers", "func"="trrackpatch(CH,1,117)"]
	r[n++] = [ "name"="Pull Me Please", "func"="trrackpatch(CH,1,118)"]
	r[n++] = [ "name"="Contrabass&Cello", "func"="trrackpatch(CH,1,119)"]
	r[n++] = [ "name"="Marc Tree", "func"="trrackpatch(CH,1,120)"]
	r[n++] = [ "name"="Classic Squares", "func"="trrackpatch(CH,1,121)"]
	r[n++] = [ "name"="Pipe Tuentiana", "func"="trrackpatch(CH,1,122)"]
	r[n++] = [ "name"="Hover Craft", "func"="trrackpatch(CH,1,123)"]
	r[n++] = [ "name"="Band Hit!", "func"="trrackpatch(CH,1,124)"]
	r[n++] = [ "name"="Thunderstorm!!!!", "func"="trrackpatch(CH,1,125)"]
	r[n++] = [ "name"="Bass go pop.", "func"="trrackpatch(CH,1,126)"]
	r[n++] = [ "name"="Mute Guitar", "func"="trrackpatch(CH,1,127)"]
	r[n++] = [ "name"="Soft-StereoPiano", "func"="trrackpatch(CH,2,0)"]
	r[n++] = [ "name"="Clear Mallet", "func"="trrackpatch(CH,2,1)"]
	r[n++] = [ "name"="Bed of Vocals", "func"="trrackpatch(CH,2,2)"]
	r[n++] = [ "name"="     ...sleep...", "func"="trrackpatch(CH,2,3)"]
	r[n++] = [ "name"="Trance Lead", "func"="trrackpatch(CH,2,4)"]
	r[n++] = [ "name"="Bass Drum Bass", "func"="trrackpatch(CH,2,5)"]
	r[n++] = [ "name"="SweepUp Synth", "func"="trrackpatch(CH,2,6)"]
	r[n++] = [ "name"="Sharp Brass", "func"="trrackpatch(CH,2,7)"]
	r[n++] = [ "name"="DaDanceMixPiano", "func"="trrackpatch(CH,2,8)"]
	r[n++] = [ "name"="KnobbingBass", "func"="trrackpatch(CH,2,9)"]
	r[n++] = [ "name"="HipHop/Rap Kit", "func"="trrackpatch(CH,2,10)"]
	r[n++] = [ "name"="Tape Synth", "func"="trrackpatch(CH,2,11)"]
	r[n++] = [ "name"="Brain Swimming", "func"="trrackpatch(CH,2,12)"]
	r[n++] = [ "name"="Reggae Gtr Chd", "func"="trrackpatch(CH,2,13)"]
	r[n++] = [ "name"="ST Sus.Band Hit", "func"="trrackpatch(CH,2,14)"]
	r[n++] = [ "name"="Dr.Groove Bass", "func"="trrackpatch(CH,2,15)"]
	r[n++] = [ "name"="Vintage Grand", "func"="trrackpatch(CH,2,16)"]
	r[n++] = [ "name"="Upsweep", "func"="trrackpatch(CH,2,17)"]
	r[n++] = [ "name"="Synth Brazz", "func"="trrackpatch(CH,2,18)"]
	r[n++] = [ "name"="Forest Choir", "func"="trrackpatch(CH,2,19)"]
	r[n++] = [ "name"="KBed E.P.", "func"="trrackpatch(CH,2,20)"]
	r[n++] = [ "name"="Noctiluca", "func"="trrackpatch(CH,2,21)"]
	r[n++] = [ "name"="Orchestral Brass", "func"="trrackpatch(CH,2,22)"]
	r[n++] = [ "name"="OLD/Dark E.P.", "func"="trrackpatch(CH,2,23)"]
	r[n++] = [ "name"="Solo Sax", "func"="trrackpatch(CH,2,24)"]
	r[n++] = [ "name"="Pound Bass", "func"="trrackpatch(CH,2,25)"]
	r[n++] = [ "name"="Funky Drummin'", "func"="trrackpatch(CH,2,26)"]
	r[n++] = [ "name"="Old & Analog", "func"="trrackpatch(CH,2,27)"]
	r[n++] = [ "name"="False Reality", "func"="trrackpatch(CH,2,28)"]
	r[n++] = [ "name"="Pop Guitar Chd", "func"="trrackpatch(CH,2,29)"]
	r[n++] = [ "name"="ST Disonant Hit", "func"="trrackpatch(CH,2,30)"]
	r[n++] = [ "name"="{_Hip * Pick_}", "func"="trrackpatch(CH,2,31)"]
	r[n++] = [ "name"="Night Moods", "func"="trrackpatch(CH,2,32)"]
	r[n++] = [ "name"="Dance Lead", "func"="trrackpatch(CH,2,33)"]
	r[n++] = [ "name"="Square Snaps", "func"="trrackpatch(CH,2,34)"]
	r[n++] = [ "name"="ST Old Brass Hit", "func"="trrackpatch(CH,2,35)"]
	r[n++] = [ "name"="FM Tubular", "func"="trrackpatch(CH,2,36)"]
	r[n++] = [ "name"="Asid Bass", "func"="trrackpatch(CH,2,37)"]
	r[n++] = [ "name"="Space Life", "func"="trrackpatch(CH,2,38)"]
	r[n++] = [ "name"="ST Brass Fall", "func"="trrackpatch(CH,2,39)"]
	r[n++] = [ "name"="ClassicM1Organ2", "func"="trrackpatch(CH,2,40)"]
	r[n++] = [ "name"="{POP} House Bass", "func"="trrackpatch(CH,2,41)"]
	r[n++] = [ "name"="House/Techno/Jun", "func"="trrackpatch(CH,2,42)"]
	r[n++] = [ "name"="Triangulation", "func"="trrackpatch(CH,2,43)"]
	r[n++] = [ "name"="Wavetable E.P.", "func"="trrackpatch(CH,2,44)"]
	r[n++] = [ "name"="FunkyGtr 9th Chd", "func"="trrackpatch(CH,2,45)"]
	r[n++] = [ "name"="ST Glass O.Hit", "func"="trrackpatch(CH,2,46)"]
	r[n++] = [ "name"="Upright Bass", "func"="trrackpatch(CH,2,47)"]
	r[n++] = [ "name"="Super CP Layer", "func"="trrackpatch(CH,2,48)"]
	r[n++] = [ "name"="brak", "func"="trrackpatch(CH,2,49)"]
	r[n++] = [ "name"="Perc. Bottle", "func"="trrackpatch(CH,2,50)"]
	r[n++] = [ "name"="Noise Hits", "func"="trrackpatch(CH,2,51)"]
	r[n++] = [ "name"="Solar Bells", "func"="trrackpatch(CH,2,52)"]
	r[n++] = [ "name"="Nistrom", "func"="trrackpatch(CH,2,53)"]
	r[n++] = [ "name"="*{LAZER WARS}*", "func"="trrackpatch(CH,2,54)"]
	r[n++] = [ "name"="Trumpet", "func"="trrackpatch(CH,2,55)"]
	r[n++] = [ "name"="Clavi-Attack", "func"="trrackpatch(CH,2,56)"]
	r[n++] = [ "name"="Power R&B Organ", "func"="trrackpatch(CH,2,57)"]
	r[n++] = [ "name"="Ribbon Rez Bass", "func"="trrackpatch(CH,2,58)"]
	r[n++] = [ "name"="Bamboo B!!", "func"="trrackpatch(CH,2,59)"]
	r[n++] = [ "name"="Pole", "func"="trrackpatch(CH,2,60)"]
	r[n++] = [ "name"="[Ribbon] Rok Gtr", "func"="trrackpatch(CH,2,61)"]
	r[n++] = [ "name"="__Kleer_Bass__", "func"="trrackpatch(CH,2,62)"]
	r[n++] = [ "name"="Mg Lead (Ribbon)", "func"="trrackpatch(CH,2,63)"]
	r[n++] = [ "name"="M1 Piano", "func"="trrackpatch(CH,2,64)"]
	r[n++] = [ "name"="Sub-Synth", "func"="trrackpatch(CH,2,65)"]
	r[n++] = [ "name"="Saw Pad", "func"="trrackpatch(CH,2,66)"]
	r[n++] = [ "name"="<< Going Home >>", "func"="trrackpatch(CH,2,67)"]
	r[n++] = [ "name"="son of big one", "func"="trrackpatch(CH,2,68)"]
	r[n++] = [ "name"="Jungle Bass 2", "func"="trrackpatch(CH,2,69)"]
	r[n++] = [ "name"="SynMallet", "func"="trrackpatch(CH,2,70)"]
	r[n++] = [ "name"="WAVE STATION", "func"="trrackpatch(CH,2,71)"]
	r[n++] = [ "name"="Piano Pad #3", "func"="trrackpatch(CH,2,72)"]
	r[n++] = [ "name"="Knocker Bass", "func"="trrackpatch(CH,2,73)"]
	r[n++] = [ "name"="Jungle Kit", "func"="trrackpatch(CH,2,74)"]
	r[n++] = [ "name"="[{ The Summit }]", "func"="trrackpatch(CH,2,75)"]
	r[n++] = [ "name"="Ddum'n Bass SQ01", "func"="trrackpatch(CH,2,76)"]
	r[n++] = [ "name"="Crunchy Power Gt", "func"="trrackpatch(CH,2,77)"]
	r[n++] = [ "name"="ST Power Pop Hit", "func"="trrackpatch(CH,2,78)"]
	r[n++] = [ "name"="Punctured BASS", "func"="trrackpatch(CH,2,79)"]
	r[n++] = [ "name"="Digi JET Stream", "func"="trrackpatch(CH,2,80)"]
	r[n++] = [ "name"="Mondo Rave Pad'", "func"="trrackpatch(CH,2,81)"]
	r[n++] = [ "name"="Evolver Pad", "func"="trrackpatch(CH,2,82)"]
	r[n++] = [ "name"="ST Brass Hit", "func"="trrackpatch(CH,2,83)"]
	r[n++] = [ "name"="Mr.8 Sync Lead", "func"="trrackpatch(CH,2,84)"]
	r[n++] = [ "name"="StandUpTheBass", "func"="trrackpatch(CH,2,85)"]
	r[n++] = [ "name"="Mermaid", "func"="trrackpatch(CH,2,86)"]
	r[n++] = [ "name"="01W Trombone1", "func"="trrackpatch(CH,2,87)"]
	r[n++] = [ "name"="ChordWork", "func"="trrackpatch(CH,2,88)"]
	r[n++] = [ "name"="01W Alto Sax", "func"="trrackpatch(CH,2,89)"]
	r[n++] = [ "name"="AnalogSweeper", "func"="trrackpatch(CH,2,90)"]
	r[n++] = [ "name"="pressure", "func"="trrackpatch(CH,2,91)"]
	r[n++] = [ "name"="Cyber Choir", "func"="trrackpatch(CH,2,92)"]
	r[n++] = [ "name"="Street Guitar", "func"="trrackpatch(CH,2,93)"]
	r[n++] = [ "name"="ST Major O.Hit", "func"="trrackpatch(CH,2,94)"]
	r[n++] = [ "name"="Razor Bass", "func"="trrackpatch(CH,2,95)"]
	r[n++] = [ "name"="Velocity EP", "func"="trrackpatch(CH,2,96)"]
	r[n++] = [ "name"="BubbleGumRibbon", "func"="trrackpatch(CH,2,97)"]
	r[n++] = [ "name"="Cyborg Pad'", "func"="trrackpatch(CH,2,98)"]
	r[n++] = [ "name"="DSP Noise", "func"="trrackpatch(CH,2,99)"]
	r[n++] = [ "name"="TAP RibbonVoices", "func"="trrackpatch(CH,2,100)"]
	r[n++] = [ "name"=" ! Stinky Bass !", "func"="trrackpatch(CH,2,101)"]
	r[n++] = [ "name"="Rubber{Wah}Clav", "func"="trrackpatch(CH,2,102)"]
	r[n++] = [ "name"="CrawlersLeadSax", "func"="trrackpatch(CH,2,103)"]
	r[n++] = [ "name"="Piano Pad #1", "func"="trrackpatch(CH,2,104)"]
	r[n++] = [ "name"="SUB-SUB-BASS", "func"="trrackpatch(CH,2,105)"]
	r[n++] = [ "name"="Industry/Analog", "func"="trrackpatch(CH,2,106)"]
	r[n++] = [ "name"="Icicle", "func"="trrackpatch(CH,2,107)"]
	r[n++] = [ "name"="Lock the Piano!", "func"="trrackpatch(CH,2,108)"]
	r[n++] = [ "name"="A Vox Wah (SW1)", "func"="trrackpatch(CH,2,109)"]
	r[n++] = [ "name"="ST Intense Hit", "func"="trrackpatch(CH,2,110)"]
	r[n++] = [ "name"="Vogue Bass", "func"="trrackpatch(CH,2,111)"]
	r[n++] = [ "name"="Bell/Piano/Pad", "func"="trrackpatch(CH,2,112)"]
	r[n++] = [ "name"="Analog Scuttlin", "func"="trrackpatch(CH,2,113)"]
	r[n++] = [ "name"="3-Way Lead Synth", "func"="trrackpatch(CH,2,114)"]
	r[n++] = [ "name"="Fretless", "func"="trrackpatch(CH,2,115)"]
	r[n++] = [ "name"="Detuned E.P.", "func"="trrackpatch(CH,2,116)"]
	r[n++] = [ "name"="Slap Bass", "func"="trrackpatch(CH,2,117)"]
	r[n++] = [ "name"="Funky Lead", "func"="trrackpatch(CH,2,118)"]
	r[n++] = [ "name"="01W Trombone2", "func"="trrackpatch(CH,2,119)"]
	r[n++] = [ "name"="M1 Grand Piano", "func"="trrackpatch(CH,2,120)"]
	r[n++] = [ "name"="Plastic Man", "func"="trrackpatch(CH,2,121)"]
	r[n++] = [ "name"="Super Pizz Hit", "func"="trrackpatch(CH,2,122)"]
	r[n++] = [ "name"="Disco Brass", "func"="trrackpatch(CH,2,123)"]
	r[n++] = [ "name"="Super Stage EP", "func"="trrackpatch(CH,2,124)"]
	r[n++] = [ "name"="Touch Wah '70s", "func"="trrackpatch(CH,2,125)"]
	r[n++] = [ "name"="ST 5th Choir Hit", "func"="trrackpatch(CH,2,126)"]
	r[n++] = [ "name"="Elevator Noise", "func"="trrackpatch(CH,2,127)"]
	r[n++] = [ "name"="NeuroSurgery", "func"="trrackpatch(CH,3,0)"]
	r[n++] = [ "name"="SinisterDrug@3AM", "func"="trrackpatch(CH,3,1)"]
	r[n++] = [ "name"="Digital Polysix", "func"="trrackpatch(CH,3,2)"]
	r[n++] = [ "name"="Bells In Motion", "func"="trrackpatch(CH,3,3)"]
	r[n++] = [ "name"="Octarez Bass", "func"="trrackpatch(CH,3,4)"]
	r[n++] = [ "name"="Mr. Impact", "func"="trrackpatch(CH,3,5)"]
	r[n++] = [ "name"="Dance Piano", "func"="trrackpatch(CH,3,6)"]
	r[n++] = [ "name"="Tek Quire", "func"="trrackpatch(CH,3,7)"]
	r[n++] = [ "name"="Electrik Brass", "func"="trrackpatch(CH,3,8)"]
	r[n++] = [ "name"="Reggae Organ", "func"="trrackpatch(CH,3,9)"]
	r[n++] = [ "name"="Pop/R&B Kit", "func"="trrackpatch(CH,3,10)"]
	r[n++] = [ "name"="StereoBrightOHit", "func"="trrackpatch(CH,3,11)"]
	r[n++] = [ "name"="Thunder Pick", "func"="trrackpatch(CH,3,12)"]
	r[n++] = [ "name"="Double Strings", "func"="trrackpatch(CH,3,13)"]
	r[n++] = [ "name"="Trencher", "func"="trrackpatch(CH,3,14)"]
	r[n++] = [ "name"="Saw303Devotee JS", "func"="trrackpatch(CH,3,15)"]
	r[n++] = [ "name"="TempoSynth~Organ", "func"="trrackpatch(CH,3,16)"]
	r[n++] = [ "name"="Sonic }{ Soup", "func"="trrackpatch(CH,3,17)"]
	r[n++] = [ "name"="Dynamic Rave", "func"="trrackpatch(CH,3,18)"]
	r[n++] = [ "name"="FM Water Bell", "func"="trrackpatch(CH,3,19)"]
	r[n++] = [ "name"="Dark Moog", "func"="trrackpatch(CH,3,20)"]
	r[n++] = [ "name"="Drub Square", "func"="trrackpatch(CH,3,21)"]
	r[n++] = [ "name"="SmoothStage E.P.", "func"="trrackpatch(CH,3,22)"]
	r[n++] = [ "name"="Vocalscape", "func"="trrackpatch(CH,3,23)"]
	r[n++] = [ "name"="Brass Brothers", "func"="trrackpatch(CH,3,24)"]
	r[n++] = [ "name"="Garage Organ", "func"="trrackpatch(CH,3,25)"]
	r[n++] = [ "name"="Vintage Kit", "func"="trrackpatch(CH,3,26)"]
	r[n++] = [ "name"="Delicate Morpher", "func"="trrackpatch(CH,3,27)"]
	r[n++] = [ "name"="Tri Me Bass", "func"="trrackpatch(CH,3,28)"]
	r[n++] = [ "name"="Pop Strings 1", "func"="trrackpatch(CH,3,29)"]
	r[n++] = [ "name"="}( Meditate ){", "func"="trrackpatch(CH,3,30)"]
	r[n++] = [ "name"="Lead, or Bass?", "func"="trrackpatch(CH,3,31)"]
	r[n++] = [ "name"="Rhythm Sweep", "func"="trrackpatch(CH,3,32)"]
	r[n++] = [ "name"="NOISY VOX Ribbon", "func"="trrackpatch(CH,3,33)"]
	r[n++] = [ "name"="Rezo Airpad", "func"="trrackpatch(CH,3,34)"]
	r[n++] = [ "name"="Bellend", "func"="trrackpatch(CH,3,35)"]
	r[n++] = [ "name"="Rave Choir", "func"="trrackpatch(CH,3,36)"]
	r[n++] = [ "name"="TranceOrganBass", "func"="trrackpatch(CH,3,37)"]
	r[n++] = [ "name"="Saw Stack", "func"="trrackpatch(CH,3,38)"]
	r[n++] = [ "name"="Rez Motion Sweep", "func"="trrackpatch(CH,3,39)"]
	r[n++] = [ "name"="Band & Fall", "func"="trrackpatch(CH,3,40)"]
	r[n++] = [ "name"="Disco*ORGAN*Bass", "func"="trrackpatch(CH,3,41)"]
	r[n++] = [ "name"="Agressiv Kit", "func"="trrackpatch(CH,3,42)"]
	r[n++] = [ "name"="= Evaporate =", "func"="trrackpatch(CH,3,43)"]
	r[n++] = [ "name"="Savage Squares", "func"="trrackpatch(CH,3,44)"]
	r[n++] = [ "name"="Pop Strings 2", "func"="trrackpatch(CH,3,45)"]
	r[n++] = [ "name"="Rubber Banned", "func"="trrackpatch(CH,3,46)"]
	r[n++] = [ "name"="Cry Baby Bass", "func"="trrackpatch(CH,3,47)"]
	r[n++] = [ "name"="Rising The Sun", "func"="trrackpatch(CH,3,48)"]
	r[n++] = [ "name"="Seq DDL Lead", "func"="trrackpatch(CH,3,49)"]
	r[n++] = [ "name"="Vel~Swellz", "func"="trrackpatch(CH,3,50)"]
	r[n++] = [ "name"="Tinkle Bells", "func"="trrackpatch(CH,3,51)"]
	r[n++] = [ "name"="SQ Bass", "func"="trrackpatch(CH,3,52)"]
	r[n++] = [ "name"="Random Syn Hit", "func"="trrackpatch(CH,3,53)"]
	r[n++] = [ "name"="Analog Clav", "func"="trrackpatch(CH,3,54)"]
	r[n++] = [ "name"="Basic But Useful", "func"="trrackpatch(CH,3,55)"]
	r[n++] = [ "name"="Sweepy Strings", "func"="trrackpatch(CH,3,56)"]
	r[n++] = [ "name"="String Stab", "func"="trrackpatch(CH,3,57)"]
	r[n++] = [ "name"="Well Hard Kit", "func"="trrackpatch(CH,3,58)"]
	r[n++] = [ "name"="Flashy SAWS", "func"="trrackpatch(CH,3,59)"]
	r[n++] = [ "name"="WarmPickedBass", "func"="trrackpatch(CH,3,60)"]
	r[n++] = [ "name"="ThrustingThrunge", "func"="trrackpatch(CH,3,61)"]
	r[n++] = [ "name"="Tikki", "func"="trrackpatch(CH,3,62)"]
	r[n++] = [ "name"="Zapper Bass", "func"="trrackpatch(CH,3,63)"]
	r[n++] = [ "name"="Tronic Strinng", "func"="trrackpatch(CH,3,64)"]
	r[n++] = [ "name"="Stereo Filters", "func"="trrackpatch(CH,3,65)"]
	r[n++] = [ "name"="Ghostly Strings", "func"="trrackpatch(CH,3,66)"]
	r[n++] = [ "name"="Solar Lullaby", "func"="trrackpatch(CH,3,67)"]
	r[n++] = [ "name"="Sync Bass", "func"="trrackpatch(CH,3,68)"]
	r[n++] = [ "name"="Analog Bass  SW1", "func"="trrackpatch(CH,3,69)"]
	r[n++] = [ "name"="Soft Clavitar", "func"="trrackpatch(CH,3,70)"]
	r[n++] = [ "name"="Steady Breath", "func"="trrackpatch(CH,3,71)"]
	r[n++] = [ "name"="Trianglular", "func"="trrackpatch(CH,3,72)"]
	r[n++] = [ "name"="Interval Sweep", "func"="trrackpatch(CH,3,73)"]
	r[n++] = [ "name"="Jazz/Funk/Reggae", "func"="trrackpatch(CH,3,74)"]
	r[n++] = [ "name"="Solarium Pad", "func"="trrackpatch(CH,3,75)"]
	r[n++] = [ "name"="Pfunky Bass  SW1", "func"="trrackpatch(CH,3,76)"]
	r[n++] = [ "name"="* Ice Whistle *", "func"="trrackpatch(CH,3,77)"]
	r[n++] = [ "name"="Dance Arp Wave", "func"="trrackpatch(CH,3,78)"]
	r[n++] = [ "name"="Velo/Rez Bass", "func"="trrackpatch(CH,3,79)"]
	r[n++] = [ "name"="Lifting Off...", "func"="trrackpatch(CH,3,80)"]
	r[n++] = [ "name"="PWM Pad SW1", "func"="trrackpatch(CH,3,81)"]
	r[n++] = [ "name"="OPERA", "func"="trrackpatch(CH,3,82)"]
	r[n++] = [ "name"="{Chasing Comets}", "func"="trrackpatch(CH,3,83)"]
	r[n++] = [ "name"="Rawsaw Syn. Bass", "func"="trrackpatch(CH,3,84)"]
	r[n++] = [ "name"="Junnggle Bass", "func"="trrackpatch(CH,3,85)"]
	r[n++] = [ "name"="Radio Piano(SW1)", "func"="trrackpatch(CH,3,86)"]
	r[n++] = [ "name"="Digistack Stab", "func"="trrackpatch(CH,3,87)"]
	r[n++] = [ "name"="Stabbin' McNally", "func"="trrackpatch(CH,3,88)"]
	r[n++] = [ "name"="Staccato Pad", "func"="trrackpatch(CH,3,89)"]
	r[n++] = [ "name"="Vox Rhythms", "func"="trrackpatch(CH,3,90)"]
	r[n++] = [ "name"="DigiBell Pad", "func"="trrackpatch(CH,3,91)"]
	r[n++] = [ "name"="TsuB Bass", "func"="trrackpatch(CH,3,92)"]
	r[n++] = [ "name"="Pop Mutes", "func"="trrackpatch(CH,3,93)"]
	r[n++] = [ "name"="Detuned Ana. Era", "func"="trrackpatch(CH,3,94)"]
	r[n++] = [ "name"="SQ 303Devotee JS", "func"="trrackpatch(CH,3,95)"]
	r[n++] = [ "name"="Hallucinating", "func"="trrackpatch(CH,3,96)"]
	r[n++] = [ "name"="Chiff Anatomy", "func"="trrackpatch(CH,3,97)"]
	r[n++] = [ "name"="Arpy Guy (JS-Y)", "func"="trrackpatch(CH,3,98)"]
	r[n++] = [ "name"="Teknostatic", "func"="trrackpatch(CH,3,99)"]
	r[n++] = [ "name"="Organ Hit", "func"="trrackpatch(CH,3,100)"]
	r[n++] = [ "name"="TranceBass SW1&2", "func"="trrackpatch(CH,3,101)"]
	r[n++] = [ "name"="Synth Clav", "func"="trrackpatch(CH,3,102)"]
	r[n++] = [ "name"="Organ grind", "func"="trrackpatch(CH,3,103)"]
	r[n++] = [ "name"="Slow Sweeper", "func"="trrackpatch(CH,3,104)"]
	r[n++] = [ "name"="Rhythmic Rez", "func"="trrackpatch(CH,3,105)"]
	r[n++] = [ "name"="Synth Logg Drum", "func"="trrackpatch(CH,3,106)"]
	r[n++] = [ "name"="Ginch", "func"="trrackpatch(CH,3,107)"]
	r[n++] = [ "name"="30303 Rezdark", "func"="trrackpatch(CH,3,108)"]
	r[n++] = [ "name"="Useful Trash", "func"="trrackpatch(CH,3,109)"]
	r[n++] = [ "name"="Unison Filters", "func"="trrackpatch(CH,3,110)"]
	r[n++] = [ "name"="Syn-Zap Bass", "func"="trrackpatch(CH,3,111)"]
	r[n++] = [ "name"="Classic Whirly", "func"="trrackpatch(CH,3,112)"]
	r[n++] = [ "name"="Velorezo", "func"="trrackpatch(CH,3,113)"]
	r[n++] = [ "name"="Monstrousity", "func"="trrackpatch(CH,3,114)"]
	r[n++] = [ "name"="RADIO -Y&Ribbon", "func"="trrackpatch(CH,3,115)"]
	r[n++] = [ "name"="RAVE Siren (SW1)", "func"="trrackpatch(CH,3,116)"]
	r[n++] = [ "name"="Skip's DUB Bass", "func"="trrackpatch(CH,3,117)"]
	r[n++] = [ "name"="Sticky Rez Clav", "func"="trrackpatch(CH,3,118)"]
	r[n++] = [ "name"="Stacc-echo", "func"="trrackpatch(CH,3,119)"]
	r[n++] = [ "name"="SineUsoid", "func"="trrackpatch(CH,3,120)"]
	r[n++] = [ "name"="...For Medusa", "func"="trrackpatch(CH,3,121)"]
	r[n++] = [ "name"="squinge sqr >SW1", "func"="trrackpatch(CH,3,122)"]
	r[n++] = [ "name"="Slang Bass", "func"="trrackpatch(CH,3,123)"]
	r[n++] = [ "name"="Downsizinng", "func"="trrackpatch(CH,3,124)"]
	r[n++] = [ "name"="Euro Stab", "func"="trrackpatch(CH,3,125)"]
	r[n++] = [ "name"="Super Slammer", "func"="trrackpatch(CH,3,126)"]
	r[n++] = [ "name"="Rain Forest", "func"="trrackpatch(CH,3,127)"]

 	r[n++] = ["name"="None", "func"=""]

	Patchmaptrrack = r

	return(Patchmaptrrack)
}
