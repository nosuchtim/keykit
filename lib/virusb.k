# This is for Access Virus b - OS 4.51

#name	virusbpatch
#usage	virusbpatch(part,bank,prog)
#desc	Return sysex that changes a parts bank/program.
#desc	Assumes that the 16 parts are assigned to channels 1-16.
#desc	ch is 1-based
#desc	bank is 1-based
#desc	prog is 0-based
function virusb(ch,bank,prog) {
	pp = ch - 1
	bank -= 1
	# I tried using the "part bank select" to avoid changing
	# the bank until the program change, but it didn't work well -
	# the prog numbers seemed to act strangely.  Not sure why.
	b = midibytes(
	    0xf0,0x00,0x20,0x33,0x01,0x10,0x72,pp,0x20,bank,0xf7, # bank change
	    0xf0,0x00,0x20,0x33,0x01,0x10,0x72,pp,0x21,prog,0xf7) # prog change
	# Because it's a sysex, the default channel output
	# routings don't work, so we need to be explicit.
	b.port = default_port_for_channel(ch)
	return(b)
}

#name	virusbunpatch
#usage	virusbunpatch(p)
#desc	If p is a patch change message, return its name.
#desc	Return "" if it's not a patch message.
function virusbunpatch(p) {
	return("")
}


function patchmap_virusb() {

	r = []
	n = 0

	# BANK A and B are user-editable, so we can't depend on those.
	# They're included at the bottom of this file, though, if they
	# need to be included.

	r[n++] = ["name"="C000 Taurus JS", "func"="virusb(CH,3,0)"]
	r[n++] = ["name"="C001 OvertoneJS", "func"="virusb(CH,3,1)"]
	r[n++] = ["name"="C002 CALLIOPEJS", "func"="virusb(CH,3,2)"]
	r[n++] = ["name"="C003 HarmonixJS", "func"="virusb(CH,3,3)"]
	r[n++] = ["name"="C004 Outland JS", "func"="virusb(CH,3,4)"]
	r[n++] = ["name"="C005 Animate JS", "func"="virusb(CH,3,5)"]
	r[n++] = ["name"="C006 Uprite JS", "func"="virusb(CH,3,6)"]
	r[n++] = ["name"="C007 ConcreteJS", "func"="virusb(CH,3,7)"]
	r[n++] = ["name"="C008 Bassic JS", "func"="virusb(CH,3,8)"]
	r[n++] = ["name"="C009 7thHeavnJS", "func"="virusb(CH,3,9)"]
	r[n++] = ["name"="C010 Waver JS", "func"="virusb(CH,3,10)"]
	r[n++] = ["name"="C011 Carpets JS", "func"="virusb(CH,3,11)"]
	r[n++] = ["name"="C012 BASSTARDJS", "func"="virusb(CH,3,12)"]
	r[n++] = ["name"="C013 Raw JS", "func"="virusb(CH,3,13)"]
	r[n++] = ["name"="C014 Soaring JS", "func"="virusb(CH,3,14)"]
	r[n++] = ["name"="C015 Opener JS", "func"="virusb(CH,3,15)"]
	r[n++] = ["name"="C016 Anima JS", "func"="virusb(CH,3,16)"]
	r[n++] = ["name"="C017 Cold SawJS", "func"="virusb(CH,3,17)"]
	r[n++] = ["name"="C018 BELLA JS", "func"="virusb(CH,3,18)"]
	r[n++] = ["name"="C019 FM Bass JS", "func"="virusb(CH,3,19)"]
	r[n++] = ["name"="C020 Wailin JS", "func"="virusb(CH,3,20)"]
	r[n++] = ["name"="C021 FX Drum JS", "func"="virusb(CH,3,21)"]
	r[n++] = ["name"="C022 Simply JS", "func"="virusb(CH,3,22)"]
	r[n++] = ["name"="C023 Nasty JS", "func"="virusb(CH,3,23)"]
	r[n++] = ["name"="C024 Soaring JS", "func"="virusb(CH,3,24)"]
	r[n++] = ["name"="C025 Moving JS", "func"="virusb(CH,3,25)"]
	r[n++] = ["name"="C026 Tubez JS", "func"="virusb(CH,3,26)"]
	r[n++] = ["name"="C027 Whirly JS", "func"="virusb(CH,3,27)"]
	r[n++] = ["name"="C028 ChainsawJS", "func"="virusb(CH,3,28)"]
	r[n++] = ["name"="C029 Goa4 it JS", "func"="virusb(CH,3,29)"]
	r[n++] = ["name"="C030 Random JS", "func"="virusb(CH,3,30)"]
	r[n++] = ["name"="C031 YUCCA JS", "func"="virusb(CH,3,31)"]
	r[n++] = ["name"="C032 JUNO APGJS", "func"="virusb(CH,3,32)"]
	r[n++] = ["name"="C033 PolySin JS", "func"="virusb(CH,3,33)"]
	r[n++] = ["name"="C034 SinderelJS", "func"="virusb(CH,3,34)"]
	r[n++] = ["name"="C035 MajorityJS", "func"="virusb(CH,3,35)"]
	r[n++] = ["name"="C036 WalkaArpJS", "func"="virusb(CH,3,36)"]
	r[n++] = ["name"="C037 Organic JS", "func"="virusb(CH,3,37)"]
	r[n++] = ["name"="C038 Rough JS", "func"="virusb(CH,3,38)"]
	r[n++] = ["name"="C039 Ghost JS", "func"="virusb(CH,3,39)"]
	r[n++] = ["name"="C040 Quarx JS", "func"="virusb(CH,3,40)"]
	r[n++] = ["name"="C041 MonolithJS", "func"="virusb(CH,3,41)"]
	r[n++] = ["name"="C042 Sim SalaJS", "func"="virusb(CH,3,42)"]
	r[n++] = ["name"="C043 Soloist JS", "func"="virusb(CH,3,43)"]
	r[n++] = ["name"="C044 EnglArp JS", "func"="virusb(CH,3,44)"]
	r[n++] = ["name"="C045 X-Bellz JS", "func"="virusb(CH,3,45)"]
	r[n++] = ["name"="C046 Soaker JS", "func"="virusb(CH,3,46)"]
	r[n++] = ["name"="C047 Haunted JS", "func"="virusb(CH,3,47)"]
	r[n++] = ["name"="C048 NiceArp JS", "func"="virusb(CH,3,48)"]
	r[n++] = ["name"="C049 Alert JS", "func"="virusb(CH,3,49)"]
	r[n++] = ["name"="C050 Lead JS", "func"="virusb(CH,3,50)"]
	r[n++] = ["name"="C051 RHY-ARP JS", "func"="virusb(CH,3,51)"]
	r[n++] = ["name"="C052 Vienna JS", "func"="virusb(CH,3,52)"]
	r[n++] = ["name"="C053 Moon PadJS", "func"="virusb(CH,3,53)"]
	r[n++] = ["name"="C054 Start UpJS", "func"="virusb(CH,3,54)"]
	r[n++] = ["name"="C055 Virus B JS", "func"="virusb(CH,3,55)"]
	r[n++] = ["name"="C056 InfectedJS", "func"="virusb(CH,3,56)"]
	r[n++] = ["name"="C057 Beatbox JS", "func"="virusb(CH,3,57)"]
	r[n++] = ["name"="C058 Mallet JS", "func"="virusb(CH,3,58)"]
	r[n++] = ["name"="C059 BigSweepJS", "func"="virusb(CH,3,59)"]
	r[n++] = ["name"="C060 Voyager JS", "func"="virusb(CH,3,60)"]
	r[n++] = ["name"="C061 Ghost 2 JS", "func"="virusb(CH,3,61)"]
	r[n++] = ["name"="C062 Fuzzbox JS", "func"="virusb(CH,3,62)"]
	r[n++] = ["name"="C063 Induced JS", "func"="virusb(CH,3,63)"]
	r[n++] = ["name"="C064 Prodigy JS", "func"="virusb(CH,3,64)"]
	r[n++] = ["name"="C065 Sweeper JS", "func"="virusb(CH,3,65)"]
	r[n++] = ["name"="C066 Donkey JS", "func"="virusb(CH,3,66)"]
	r[n++] = ["name"="C067 FuzzBellJS", "func"="virusb(CH,3,67)"]
	r[n++] = ["name"="C068 Laville JS", "func"="virusb(CH,3,68)"]
	r[n++] = ["name"="C069 BIG FLY JS", "func"="virusb(CH,3,69)"]
	r[n++] = ["name"="C070 InfinityJS", "func"="virusb(CH,3,70)"]
	r[n++] = ["name"="C071 MorsSpc JS", "func"="virusb(CH,3,71)"]
	r[n++] = ["name"="C072 Tubular JS", "func"="virusb(CH,3,72)"]
	r[n++] = ["name"="C073 Bad S JS", "func"="virusb(CH,3,73)"]
	r[n++] = ["name"="C074 Chant JS", "func"="virusb(CH,3,74)"]
	r[n++] = ["name"="C075 Puncher JS", "func"="virusb(CH,3,75)"]
	r[n++] = ["name"="C076 BELLA 2 JS", "func"="virusb(CH,3,76)"]
	r[n++] = ["name"="C077 BELLARP JS", "func"="virusb(CH,3,77)"]
	r[n++] = ["name"="C078 FeedyPadJS", "func"="virusb(CH,3,78)"]
	r[n++] = ["name"="C079 Haunted JS", "func"="virusb(CH,3,79)"]
	r[n++] = ["name"="C080 Wave-PadJS", "func"="virusb(CH,3,80)"]
	r[n++] = ["name"="C081 ScanJob JS", "func"="virusb(CH,3,81)"]
	r[n++] = ["name"="C082 DIG ME JS", "func"="virusb(CH,3,82)"]
	r[n++] = ["name"="C083 NO AGE JS", "func"="virusb(CH,3,83)"]
	r[n++] = ["name"="C084 SeqIt JS", "func"="virusb(CH,3,84)"]
	r[n++] = ["name"="C085 DIG THISJS", "func"="virusb(CH,3,85)"]
	r[n++] = ["name"="C086 JAYSYNC JS", "func"="virusb(CH,3,86)"]
	r[n++] = ["name"="C087 Deeper JS", "func"="virusb(CH,3,87)"]
	r[n++] = ["name"="C088 PIGGY JS", "func"="virusb(CH,3,88)"]
	r[n++] = ["name"="C089 Percold JS", "func"="virusb(CH,3,89)"]
	r[n++] = ["name"="C090 HackbartJS", "func"="virusb(CH,3,90)"]
	r[n++] = ["name"="C091 Hover JS", "func"="virusb(CH,3,91)"]
	r[n++] = ["name"="C092 GINA PADJS", "func"="virusb(CH,3,92)"]
	r[n++] = ["name"="C093 Bassta JS", "func"="virusb(CH,3,93)"]
	r[n++] = ["name"="C094 SINEBEEZJS", "func"="virusb(CH,3,94)"]
	r[n++] = ["name"="C095 OverloadJS", "func"="virusb(CH,3,95)"]
	r[n++] = ["name"="C096 ArtificlJS", "func"="virusb(CH,3,96)"]
	r[n++] = ["name"="C097 JUSTICE JS", "func"="virusb(CH,3,97)"]
	r[n++] = ["name"="C098 EnoesqueJS", "func"="virusb(CH,3,98)"]
	r[n++] = ["name"="C099 For DeepJS", "func"="virusb(CH,3,99)"]
	r[n++] = ["name"="C100 Frozen JS", "func"="virusb(CH,3,100)"]
	r[n++] = ["name"="C101 Ah RESO JS", "func"="virusb(CH,3,101)"]
	r[n++] = ["name"="C102 KYOTO LdJS", "func"="virusb(CH,3,102)"]
	r[n++] = ["name"="C103 Walker JS", "func"="virusb(CH,3,103)"]
	r[n++] = ["name"="C104 Tight JS", "func"="virusb(CH,3,104)"]
	r[n++] = ["name"="C105 Odyssey JS", "func"="virusb(CH,3,105)"]
	r[n++] = ["name"="C106 Hybrid JS", "func"="virusb(CH,3,106)"]
	r[n++] = ["name"="C107 Birdy JS", "func"="virusb(CH,3,107)"]
	r[n++] = ["name"="C108 Feng JuiJS", "func"="virusb(CH,3,108)"]
	r[n++] = ["name"="C109 Anabo|icJS", "func"="virusb(CH,3,109)"]
	r[n++] = ["name"="C110 GLITCH OK", "func"="virusb(CH,3,110)"]
	r[n++] = ["name"="C111 DISCO OK", "func"="virusb(CH,3,111)"]
	r[n++] = ["name"="C112 OLDSCOL OK", "func"="virusb(CH,3,112)"]
	r[n++] = ["name"="C113 WetFunk BC", "func"="virusb(CH,3,113)"]
	r[n++] = ["name"="C114 Soft3rdsBC", "func"="virusb(CH,3,114)"]
	r[n++] = ["name"="C115 Puls4thsBC", "func"="virusb(CH,3,115)"]
	r[n++] = ["name"="C116 Choir 4 BC", "func"="virusb(CH,3,116)"]
	r[n++] = ["name"="C117 PluckMe BC", "func"="virusb(CH,3,117)"]
	r[n++] = ["name"="C118 BC VOV3 BC", "func"="virusb(CH,3,118)"]
	r[n++] = ["name"="C119 Dukbass+BC", "func"="virusb(CH,3,119)"]
	r[n++] = ["name"="C120 SmoothBsBC", "func"="virusb(CH,3,120)"]
	r[n++] = ["name"="C121 Subaqua BC", "func"="virusb(CH,3,121)"]
	r[n++] = ["name"="C122 BC VOV2 BC", "func"="virusb(CH,3,122)"]
	r[n++] = ["name"="C123 Braxter JV", "func"="virusb(CH,3,123)"]
	r[n++] = ["name"="C124 Pulsic JV", "func"="virusb(CH,3,124)"]
	r[n++] = ["name"="C125 >>INPUT<<", "func"="virusb(CH,3,125)"]
	r[n++] = ["name"="C126 - Init -", "func"="virusb(CH,3,126)"]
	r[n++] = ["name"="C127 - START -", "func"="virusb(CH,3,127)"]
	r[n++] = ["name"="D000 O-ME-2 RP", "func"="virusb(CH,4,0)"]
	r[n++] = ["name"="D001 2-CHORD RP", "func"="virusb(CH,4,1)"]
	r[n++] = ["name"="D002 TEC-ARP RP", "func"="virusb(CH,4,2)"]
	r[n++] = ["name"="D003 PAD-FLG RP", "func"="virusb(CH,4,3)"]
	r[n++] = ["name"="D004 OBY-PAD RP", "func"="virusb(CH,4,4)"]
	r[n++] = ["name"="D005 VARPEG RP", "func"="virusb(CH,4,5)"]
	r[n++] = ["name"="D006 VICHORD RP", "func"="virusb(CH,4,6)"]
	r[n++] = ["name"="D007 K-WERK1 RP", "func"="virusb(CH,4,7)"]
	r[n++] = ["name"="D008 RE-BASS RP", "func"="virusb(CH,4,8)"]
	r[n++] = ["name"="D009 NOISeAA RP", "func"="virusb(CH,4,9)"]
	r[n++] = ["name"="D010 7thCORD RP", "func"="virusb(CH,4,10)"]
	r[n++] = ["name"="D011 2-Brass RP", "func"="virusb(CH,4,11)"]
	r[n++] = ["name"="D012 RIBASS RP", "func"="virusb(CH,4,12)"]
	r[n++] = ["name"="D013 BPM-PAD RP", "func"="virusb(CH,4,13)"]
	r[n++] = ["name"="D014 SH-123 RP", "func"="virusb(CH,4,14)"]
	r[n++] = ["name"="D015 CLOCKED RP", "func"="virusb(CH,4,15)"]
	r[n++] = ["name"="D016 NOT-PAD#RP", "func"="virusb(CH,4,16)"]
	r[n++] = ["name"="D017 BRASS-2 RP", "func"="virusb(CH,4,17)"]
	r[n++] = ["name"="D018 AlfBass RP", "func"="virusb(CH,4,18)"]
	r[n++] = ["name"="D019 STRINGS RP", "func"="virusb(CH,4,19)"]
	r[n++] = ["name"="D020 BANDPAD RP", "func"="virusb(CH,4,20)"]
	r[n++] = ["name"="D021 VO-PAD RP", "func"="virusb(CH,4,21)"]
	r[n++] = ["name"="D022 NO-TJO RP", "func"="virusb(CH,4,22)"]
	r[n++] = ["name"="D023 QT-SOFT RP", "func"="virusb(CH,4,23)"]
	r[n++] = ["name"="D024 #NAME?", "func"="virusb(CH,4,24)"]
	r[n++] = ["name"="D025 PADINGS RP", "func"="virusb(CH,4,25)"]
	r[n++] = ["name"="D026 Whl-PAD RP", "func"="virusb(CH,4,26)"]
	r[n++] = ["name"="D027 MO-TJO RP", "func"="virusb(CH,4,27)"]
	r[n++] = ["name"="D028 VELO-ME RP", "func"="virusb(CH,4,28)"]
	r[n++] = ["name"="D029 BASS-O RP", "func"="virusb(CH,4,29)"]
	r[n++] = ["name"="D030 EASE RP", "func"="virusb(CH,4,30)"]
	r[n++] = ["name"="D031 K-Organ RP", "func"="virusb(CH,4,31)"]
	r[n++] = ["name"="D032 STR-ARP RP", "func"="virusb(CH,4,32)"]
	r[n++] = ["name"="D033 BASS ME RP", "func"="virusb(CH,4,33)"]
	r[n++] = ["name"="D034 E-CORD RP", "func"="virusb(CH,4,34)"]
	r[n++] = ["name"="D035 HAWSCH RP", "func"="virusb(CH,4,35)"]
	r[n++] = ["name"="D036 101BASS RP", "func"="virusb(CH,4,36)"]
	r[n++] = ["name"="D037 STR-WoW RP", "func"="virusb(CH,4,37)"]
	r[n++] = ["name"="D038 BRASS-1 RP", "func"="virusb(CH,4,38)"]
	r[n++] = ["name"="D039 TOMBASS RP", "func"="virusb(CH,4,39)"]
	r[n++] = ["name"="D040 WINDO RP", "func"="virusb(CH,4,40)"]
	r[n++] = ["name"="D041 SFX-VC3 RP", "func"="virusb(CH,4,41)"]
	r[n++] = ["name"="D042 FLUBBER RP", "func"="virusb(CH,4,42)"]
	r[n++] = ["name"="D043 GO BASS RP", "func"="virusb(CH,4,43)"]
	r[n++] = ["name"="D044 SoLead RP", "func"="virusb(CH,4,44)"]
	r[n++] = ["name"="D045 TI-BASS RP", "func"="virusb(CH,4,45)"]
	r[n++] = ["name"="D046 MELLOTR.RP", "func"="virusb(CH,4,46)"]
	r[n++] = ["name"="D047 ROBASS RP", "func"="virusb(CH,4,47)"]
	r[n++] = ["name"="D048 CHORD-U RP", "func"="virusb(CH,4,48)"]
	r[n++] = ["name"="D049 eXtream RP", "func"="virusb(CH,4,49)"]
	r[n++] = ["name"="D050 T-ORGAN RP", "func"="virusb(CH,4,50)"]
	r[n++] = ["name"="D051 K-WERK2 RP", "func"="virusb(CH,4,51)"]
	r[n++] = ["name"="D052 STR-II RP", "func"="virusb(CH,4,52)"]
	r[n++] = ["name"="D053 DSP-SEQ RP", "func"="virusb(CH,4,53)"]
	r[n++] = ["name"="D054 Vi-Rtro RP", "func"="virusb(CH,4,54)"]
	r[n++] = ["name"="D055 X MEAN RP", "func"="virusb(CH,4,55)"]
	r[n++] = ["name"="D056 R-PEGGI RP", "func"="virusb(CH,4,56)"]
	r[n++] = ["name"="D057 MooBass RP", "func"="virusb(CH,4,57)"]
	r[n++] = ["name"="D058 TD-SEQ RP", "func"="virusb(CH,4,58)"]
	r[n++] = ["name"="D059 BOWED RP", "func"="virusb(CH,4,59)"]
	r[n++] = ["name"="D060 BRASS-8 RP", "func"="virusb(CH,4,60)"]
	r[n++] = ["name"="D061 PolyPha RP", "func"="virusb(CH,4,61)"]
	r[n++] = ["name"="D062 TEC-MOS RP", "func"="virusb(CH,4,62)"]
	r[n++] = ["name"="D063 DSP-V RP", "func"="virusb(CH,4,63)"]
	r[n++] = ["name"="D064 SFX- X~ RP", "func"="virusb(CH,4,64)"]
	r[n++] = ["name"="D065 STEVIE RP", "func"="virusb(CH,4,65)"]
	r[n++] = ["name"="D066 T-8 RP", "func"="virusb(CH,4,66)"]
	r[n++] = ["name"="D067 TF BASS RP", "func"="virusb(CH,4,67)"]
	r[n++] = ["name"="D068 VITAR RP", "func"="virusb(CH,4,68)"]
	r[n++] = ["name"="D069 FILTERS RP", "func"="virusb(CH,4,69)"]
	r[n++] = ["name"="D070 BE-ME RP", "func"="virusb(CH,4,70)"]
	r[n++] = ["name"="D071 P-LEAD RP", "func"="virusb(CH,4,71)"]
	r[n++] = ["name"="D072 THE-BD2 RP", "func"="virusb(CH,4,72)"]
	r[n++] = ["name"="D073 PHASA RP", "func"="virusb(CH,4,73)"]
	r[n++] = ["name"="D074 TEC-NOS RP", "func"="virusb(CH,4,74)"]
	r[n++] = ["name"="D075 TE-T42 RP", "func"="virusb(CH,4,75)"]
	r[n++] = ["name"="D076 ARP-HH2 RP", "func"="virusb(CH,4,76)"]
	r[n++] = ["name"="D077 101-SUB RP", "func"="virusb(CH,4,77)"]
	r[n++] = ["name"="D078 TEC-STR RP", "func"="virusb(CH,4,78)"]
	r[n++] = ["name"="D079 SADINGS RP", "func"="virusb(CH,4,79)"]
	r[n++] = ["name"="D080 DEEBASS RP", "func"="virusb(CH,4,80)"]
	r[n++] = ["name"="D081 ARP-BD2 RP", "func"="virusb(CH,4,81)"]
	r[n++] = ["name"="D082 ROBOPAD RP", "func"="virusb(CH,4,82)"]
	r[n++] = ["name"="D083 OZ-LEAD RP", "func"="virusb(CH,4,83)"]
	r[n++] = ["name"="D084 TING RP", "func"="virusb(CH,4,84)"]
	r[n++] = ["name"="D085 TECBASS RP", "func"="virusb(CH,4,85)"]
	r[n++] = ["name"="D086 80s RP", "func"="virusb(CH,4,86)"]
	r[n++] = ["name"="D087 MAXWave RP", "func"="virusb(CH,4,87)"]
	r[n++] = ["name"="D088 Howner RP", "func"="virusb(CH,4,88)"]
	r[n++] = ["name"="D089 Omnef RP", "func"="virusb(CH,4,89)"]
	r[n++] = ["name"="D090 FENDERB RP", "func"="virusb(CH,4,90)"]
	r[n++] = ["name"="D091 NABASS RP", "func"="virusb(CH,4,91)"]
	r[n++] = ["name"="D092 CLUB-TO RP", "func"="virusb(CH,4,92)"]
	r[n++] = ["name"="D093 X0X KCK RP", "func"="virusb(CH,4,93)"]
	r[n++] = ["name"="D094 DIS-BD RP", "func"="virusb(CH,4,94)"]
	r[n++] = ["name"="D095 LowKick RP", "func"="virusb(CH,4,95)"]
	r[n++] = ["name"="D096 MS-10 1 RP", "func"="virusb(CH,4,96)"]
	r[n++] = ["name"="D097 PickGTR RP", "func"="virusb(CH,4,97)"]
	r[n++] = ["name"="D098 MISTERY RP", "func"="virusb(CH,4,98)"]
	r[n++] = ["name"="D099 MS-10 2 RP", "func"="virusb(CH,4,99)"]
	r[n++] = ["name"="D100 V Cl.HH RP", "func"="virusb(CH,4,100)"]
	r[n++] = ["name"="D101 V Op.HH RP", "func"="virusb(CH,4,101)"]
	r[n++] = ["name"="D102 P6OO RP", "func"="virusb(CH,4,102)"]
	r[n++] = ["name"="D103 P-ORGAN RP", "func"="virusb(CH,4,103)"]
	r[n++] = ["name"="D104 IQsnare RP", "func"="virusb(CH,4,104)"]
	r[n++] = ["name"="D105 T-DREAM RP", "func"="virusb(CH,4,105)"]
	r[n++] = ["name"="D106 VR-78 1 RP", "func"="virusb(CH,4,106)"]
	r[n++] = ["name"="D107 VR-78 2 RP", "func"="virusb(CH,4,107)"]
	r[n++] = ["name"="D108 SORRY RP", "func"="virusb(CH,4,108)"]
	r[n++] = ["name"="D109 DX-OEM RP", "func"="virusb(CH,4,109)"]
	r[n++] = ["name"="D110 BE-TWO RP", "func"="virusb(CH,4,110)"]
	r[n++] = ["name"="D111 DX-VE RP", "func"="virusb(CH,4,111)"]
	r[n++] = ["name"="D112 Q-TECK RP", "func"="virusb(CH,4,112)"]
	r[n++] = ["name"="D113 V-2-U RP", "func"="virusb(CH,4,113)"]
	r[n++] = ["name"="D114 2-Burst RP", "func"="virusb(CH,4,114)"]
	r[n++] = ["name"="D115 SHYCUS RP", "func"="virusb(CH,4,115)"]
	r[n++] = ["name"="D116 CORD 1 RP", "func"="virusb(CH,4,116)"]
	r[n++] = ["name"="D117 CORDY RP", "func"="virusb(CH,4,117)"]
	r[n++] = ["name"="D118 K-Werk3 RP", "func"="virusb(CH,4,118)"]
	r[n++] = ["name"="D119 PRO-12 RP", "func"="virusb(CH,4,119)"]
	r[n++] = ["name"="D120 HENDRIX RP", "func"="virusb(CH,4,120)"]
	r[n++] = ["name"="D121 ??F=V RP", "func"="virusb(CH,4,121)"]
	r[n++] = ["name"="D122 MS-99 RP", "func"="virusb(CH,4,122)"]
	r[n++] = ["name"="D123 Wurly RP", "func"="virusb(CH,4,123)"]
	r[n++] = ["name"="D124 FAT-SN. RP", "func"="virusb(CH,4,124)"]
	r[n++] = ["name"="D125 MOVER RP", "func"="virusb(CH,4,125)"]
	r[n++] = ["name"="D126 VeloPEW RP", "func"="virusb(CH,4,126)"]
	r[n++] = ["name"="D127 SNARE X RP", "func"="virusb(CH,4,127)"]
	r[n++] = ["name"="E000 AutoBendBC", "func"="virusb(CH,5,0)"]
	r[n++] = ["name"="E001 Avenues JS", "func"="virusb(CH,5,1)"]
	r[n++] = ["name"="E002 Back280sSV", "func"="virusb(CH,5,2)"]
	r[n++] = ["name"="E003 BC NewVoV3", "func"="virusb(CH,5,3)"]
	r[n++] = ["name"="E004 BlkvelvtSV", "func"="virusb(CH,5,4)"]
	r[n++] = ["name"="E005 B-SquareBC", "func"="virusb(CH,5,5)"]
	r[n++] = ["name"="E006 BusysawsSV", "func"="virusb(CH,5,6)"]
	r[n++] = ["name"="E007 ChilloutJS", "func"="virusb(CH,5,7)"]
	r[n++] = ["name"="E008 ChrunchyJS", "func"="virusb(CH,5,8)"]
	r[n++] = ["name"="E009 ClubbassSV", "func"="virusb(CH,5,9)"]
	r[n++] = ["name"="E010 ClubtoolBC", "func"="virusb(CH,5,10)"]
	r[n++] = ["name"="E011 Comm basSV", "func"="virusb(CH,5,11)"]
	r[n++] = ["name"="E012 CommerseSV", "func"="virusb(CH,5,12)"]
	r[n++] = ["name"="E013 Contra BC", "func"="virusb(CH,5,13)"]
	r[n++] = ["name"="E014 CosmicbsSV", "func"="virusb(CH,5,14)"]
	r[n++] = ["name"="E015 CreameryBC", "func"="virusb(CH,5,15)"]
	r[n++] = ["name"="E016 Cyclone JS", "func"="virusb(CH,5,16)"]
	r[n++] = ["name"="E017 Da Funk BC", "func"="virusb(CH,5,17)"]
	r[n++] = ["name"="E018 Dawn JS", "func"="virusb(CH,5,18)"]
	r[n++] = ["name"="E019 Decay JS", "func"="virusb(CH,5,19)"]
	r[n++] = ["name"="E020 Deep9thsBC", "func"="virusb(CH,5,20)"]
	r[n++] = ["name"="E021 Devlish SV", "func"="virusb(CH,5,21)"]
	r[n++] = ["name"="E022 DHR Amb BC", "func"="virusb(CH,5,22)"]
	r[n++] = ["name"="E023 Digedi JS", "func"="virusb(CH,5,23)"]
	r[n++] = ["name"="E024 Driver SV", "func"="virusb(CH,5,24)"]
	r[n++] = ["name"="E025 Drmswpr SV", "func"="virusb(CH,5,25)"]
	r[n++] = ["name"="E026 Duffer BC", "func"="virusb(CH,5,26)"]
	r[n++] = ["name"="E027 Edgy JS", "func"="virusb(CH,5,27)"]
	r[n++] = ["name"="E028 Etheral SV", "func"="virusb(CH,5,28)"]
	r[n++] = ["name"="E029 Far EastJS", "func"="virusb(CH,5,29)"]
	r[n++] = ["name"="E030 FatWah BC", "func"="virusb(CH,5,30)"]
	r[n++] = ["name"="E031 Five in1BC", "func"="virusb(CH,5,31)"]
	r[n++] = ["name"="E032 FlyBy BC", "func"="virusb(CH,5,32)"]
	r[n++] = ["name"="E033 FnkNastyBC", "func"="virusb(CH,5,33)"]
	r[n++] = ["name"="E034 Freno BC", "func"="virusb(CH,5,34)"]
	r[n++] = ["name"="E035 Fripper JS", "func"="virusb(CH,5,35)"]
	r[n++] = ["name"="E036 Future XSV", "func"="virusb(CH,5,36)"]
	r[n++] = ["name"="E037 FuturwldSV", "func"="virusb(CH,5,37)"]
	r[n++] = ["name"="E038 GarBass8BC", "func"="virusb(CH,5,38)"]
	r[n++] = ["name"="E039 Girls SV", "func"="virusb(CH,5,39)"]
	r[n++] = ["name"="E040 Glassey SV", "func"="virusb(CH,5,40)"]
	r[n++] = ["name"="E041 Goatic SV", "func"="virusb(CH,5,41)"]
	r[n++] = ["name"="E042 GoindownSV", "func"="virusb(CH,5,42)"]
	r[n++] = ["name"="E043 GoodniteJS", "func"="virusb(CH,5,43)"]
	r[n++] = ["name"="E044 Gulf JS", "func"="virusb(CH,5,44)"]
	r[n++] = ["name"="E045 Hifive SV", "func"="virusb(CH,5,45)"]
	r[n++] = ["name"="E046 HOA Pad SV", "func"="virusb(CH,5,46)"]
	r[n++] = ["name"="E047 Hollow JS", "func"="virusb(CH,5,47)"]
	r[n++] = ["name"="E048 Homeboy JS", "func"="virusb(CH,5,48)"]
	r[n++] = ["name"="E049 HongKongBC", "func"="virusb(CH,5,49)"]
	r[n++] = ["name"="E050 Hoppin' SV", "func"="virusb(CH,5,50)"]
	r[n++] = ["name"="E051 IntntentSV", "func"="virusb(CH,5,51)"]
	r[n++] = ["name"="E052 intruderJS", "func"="virusb(CH,5,52)"]
	r[n++] = ["name"="E053 Jazzy JS", "func"="virusb(CH,5,53)"]
	r[n++] = ["name"="E054 JoeZolo BC", "func"="virusb(CH,5,54)"]
	r[n++] = ["name"="E055 KatmanduJS", "func"="virusb(CH,5,55)"]
	r[n++] = ["name"="E056 KingsizeJS", "func"="virusb(CH,5,56)"]
	r[n++] = ["name"="E057 LatitudeSV", "func"="virusb(CH,5,57)"]
	r[n++] = ["name"="E058 Let's goSV", "func"="virusb(CH,5,58)"]
	r[n++] = ["name"="E059 Lite JS", "func"="virusb(CH,5,59)"]
	r[n++] = ["name"="E060 LongskrtSV", "func"="virusb(CH,5,60)"]
	r[n++] = ["name"="E061 Maja JS", "func"="virusb(CH,5,61)"]
	r[n++] = ["name"="E062 Mamba JS", "func"="virusb(CH,5,62)"]
	r[n++] = ["name"="E063 MentalitJS", "func"="virusb(CH,5,63)"]
	r[n++] = ["name"="E064 MetalsynJS", "func"="virusb(CH,5,64)"]
	r[n++] = ["name"="E065 Move it SV", "func"="virusb(CH,5,65)"]
	r[n++] = ["name"="E066 MoveMyMWBC", "func"="virusb(CH,5,66)"]
	r[n++] = ["name"="E067 Muzzle BC", "func"="virusb(CH,5,67)"]
	r[n++] = ["name"="E068 MWC#ord BC", "func"="virusb(CH,5,68)"]
	r[n++] = ["name"="E069 MystiqueJS", "func"="virusb(CH,5,69)"]
	r[n++] = ["name"="E070 NasalbasSV", "func"="virusb(CH,5,70)"]
	r[n++] = ["name"="E071 NastyFX JS", "func"="virusb(CH,5,71)"]
	r[n++] = ["name"="E072 NewVoV4 BC", "func"="virusb(CH,5,72)"]
	r[n++] = ["name"="E073 NoiztoyzJS", "func"="virusb(CH,5,73)"]
	r[n++] = ["name"="E074 OddgssaySV", "func"="virusb(CH,5,74)"]
	r[n++] = ["name"="E075 OffSoft BC", "func"="virusb(CH,5,75)"]
	r[n++] = ["name"="E076 Oil-crwlSV", "func"="virusb(CH,5,76)"]
	r[n++] = ["name"="E077 OwWah BC", "func"="virusb(CH,5,77)"]
	r[n++] = ["name"="E078 Pathos BC", "func"="virusb(CH,5,78)"]
	r[n++] = ["name"="E079 Peace BC", "func"="virusb(CH,5,79)"]
	r[n++] = ["name"="E080 Pensive BC", "func"="virusb(CH,5,80)"]
	r[n++] = ["name"="E081 Phlute JS", "func"="virusb(CH,5,81)"]
	r[n++] = ["name"="E082 Pitchy BC", "func"="virusb(CH,5,82)"]
	r[n++] = ["name"="E083 PlaycoolSV", "func"="virusb(CH,5,83)"]
	r[n++] = ["name"="E084 Plugged JS", "func"="virusb(CH,5,84)"]
	r[n++] = ["name"="E085 Polar JS", "func"="virusb(CH,5,85)"]
	r[n++] = ["name"="E086 PolyGrovJS", "func"="virusb(CH,5,86)"]
	r[n++] = ["name"="E087 PseudoTBSV", "func"="virusb(CH,5,87)"]
	r[n++] = ["name"="E088 Pulsar SV", "func"="virusb(CH,5,88)"]
	r[n++] = ["name"="E089 Q-Pad BC", "func"="virusb(CH,5,89)"]
	r[n++] = ["name"="E090 RbbrHrp2BC", "func"="virusb(CH,5,90)"]
	r[n++] = ["name"="E091 Red lineSV", "func"="virusb(CH,5,91)"]
	r[n++] = ["name"="E092 ReflxshnBC", "func"="virusb(CH,5,92)"]
	r[n++] = ["name"="E093 RepeaterJS", "func"="virusb(CH,5,93)"]
	r[n++] = ["name"="E094 RestlessBC", "func"="virusb(CH,5,94)"]
	r[n++] = ["name"="E095 Rezoid SV", "func"="virusb(CH,5,95)"]
	r[n++] = ["name"="E096 Rezzer2 BC", "func"="virusb(CH,5,96)"]
	r[n++] = ["name"="E097 Rise up!SV", "func"="virusb(CH,5,97)"]
	r[n++] = ["name"="E098 RubbrHrpBC", "func"="virusb(CH,5,98)"]
	r[n++] = ["name"="E099 Sawz 2 SV", "func"="virusb(CH,5,99)"]
	r[n++] = ["name"="E100 Sharp BC", "func"="virusb(CH,5,100)"]
	r[n++] = ["name"="E101 S&HOrganBC", "func"="virusb(CH,5,101)"]
	r[n++] = ["name"="E102 Sickly BC", "func"="virusb(CH,5,102)"]
	r[n++] = ["name"="E103 SilkArp SV", "func"="virusb(CH,5,103)"]
	r[n++] = ["name"="E104 SinebassJS", "func"="virusb(CH,5,104)"]
	r[n++] = ["name"="E105 SomethngSV", "func"="virusb(CH,5,105)"]
	r[n++] = ["name"="E106 SpitfireJS", "func"="virusb(CH,5,106)"]
	r[n++] = ["name"="E107 Spoiled SV", "func"="virusb(CH,5,107)"]
	r[n++] = ["name"="E108 SpringPdSV", "func"="virusb(CH,5,108)"]
	r[n++] = ["name"="E109 Spring SV", "func"="virusb(CH,5,109)"]
	r[n++] = ["name"="E110 StellarpSV", "func"="virusb(CH,5,110)"]
	r[n++] = ["name"="E111 StickyPdBC", "func"="virusb(CH,5,111)"]
	r[n++] = ["name"="E112 SubmergeSV", "func"="virusb(CH,5,112)"]
	r[n++] = ["name"="E113 T-Axxe JS", "func"="virusb(CH,5,113)"]
	r[n++] = ["name"="E114 Ten InchJS", "func"="virusb(CH,5,114)"]
	r[n++] = ["name"="E115 ThirdEarJS", "func"="virusb(CH,5,115)"]
	r[n++] = ["name"="E116 Tinycat SV", "func"="virusb(CH,5,116)"]
	r[n++] = ["name"="E117 TiptaptuSV", "func"="virusb(CH,5,117)"]
	r[n++] = ["name"="E118 T Pot BC", "func"="virusb(CH,5,118)"]
	r[n++] = ["name"="E119 TwotonesBC", "func"="virusb(CH,5,119)"]
	r[n++] = ["name"="E120 UniVoV BC", "func"="virusb(CH,5,120)"]
	r[n++] = ["name"="E121 Vapour SV", "func"="virusb(CH,5,121)"]
	r[n++] = ["name"="E122 V-Bells JS", "func"="virusb(CH,5,122)"]
	r[n++] = ["name"="E123 VindictrSV", "func"="virusb(CH,5,123)"]
	r[n++] = ["name"="E124 WarmVoV BC", "func"="virusb(CH,5,124)"]
	r[n++] = ["name"="E125 WD40 BC", "func"="virusb(CH,5,125)"]
	r[n++] = ["name"="E126 X World SV", "func"="virusb(CH,5,126)"]
	r[n++] = ["name"="E127 Yawning BC", "func"="virusb(CH,5,127)"]
	r[n++] = ["name"="F000 AndromdaHS", "func"="virusb(CH,6,0)"]
	r[n++] = ["name"="F001 Arctis HS", "func"="virusb(CH,6,1)"]
	r[n++] = ["name"="F002 AT-Mini HS", "func"="virusb(CH,6,2)"]
	r[n++] = ["name"="F003 AwashBs HS", "func"="virusb(CH,6,3)"]
	r[n++] = ["name"="F004 Backing HS", "func"="virusb(CH,6,4)"]
	r[n++] = ["name"="F005 BadTape HS", "func"="virusb(CH,6,5)"]
	r[n++] = ["name"="F006 Begin? HS", "func"="virusb(CH,6,6)"]
	r[n++] = ["name"="F007 BellBoy BC", "func"="virusb(CH,6,7)"]
	r[n++] = ["name"="F008 BerimTamHS", "func"="virusb(CH,6,8)"]
	r[n++] = ["name"="F009 Boingy HS", "func"="virusb(CH,6,9)"]
	r[n++] = ["name"="F010 BowBouncHS", "func"="virusb(CH,6,10)"]
	r[n++] = ["name"="F011 Bronze HS", "func"="virusb(CH,6,11)"]
	r[n++] = ["name"="F012 BubblX HS", "func"="virusb(CH,6,12)"]
	r[n++] = ["name"="F013 CantburyHS", "func"="virusb(CH,6,13)"]
	r[n++] = ["name"="F014 ChaosBelHS", "func"="virusb(CH,6,14)"]
	r[n++] = ["name"="F015 Choir2 HS", "func"="virusb(CH,6,15)"]
	r[n++] = ["name"="F016 ClubMed HS", "func"="virusb(CH,6,16)"]
	r[n++] = ["name"="F017 Congoid HS", "func"="virusb(CH,6,17)"]
	r[n++] = ["name"="F018 CptKork HS", "func"="virusb(CH,6,18)"]
	r[n++] = ["name"="F019 Cremoma HS", "func"="virusb(CH,6,19)"]
	r[n++] = ["name"="F020 DancePn HS", "func"="virusb(CH,6,20)"]
	r[n++] = ["name"="F021 Dangelo HS", "func"="virusb(CH,6,21)"]
	r[n++] = ["name"="F022 DB-Goer HS", "func"="virusb(CH,6,22)"]
	r[n++] = ["name"="F023 DinoBassHS", "func"="virusb(CH,6,23)"]
	r[n++] = ["name"="F024 Dirtron HS", "func"="virusb(CH,6,24)"]
	r[n++] = ["name"="F025 Dread-0 HS", "func"="virusb(CH,6,25)"]
	r[n++] = ["name"="F026 Dr.What?HS", "func"="virusb(CH,6,26)"]
	r[n++] = ["name"="F027 Dublyoo HS", "func"="virusb(CH,6,27)"]
	r[n++] = ["name"="F028 DX-Pno1 HS", "func"="virusb(CH,6,28)"]
	r[n++] = ["name"="F029 DX-Pno2 HS", "func"="virusb(CH,6,29)"]
	r[n++] = ["name"="F030 DX-Pno3 HS", "func"="virusb(CH,6,30)"]
	r[n++] = ["name"="F031 Dynette HS", "func"="virusb(CH,6,31)"]
	r[n++] = ["name"="F032 Easter1 HS", "func"="virusb(CH,6,32)"]
	r[n++] = ["name"="F033 E-Grand HS", "func"="virusb(CH,6,33)"]
	r[n++] = ["name"="F034 EkoRoad HS", "func"="virusb(CH,6,34)"]
	r[n++] = ["name"="F035 E.Rigby HS", "func"="virusb(CH,6,35)"]
	r[n++] = ["name"="F036 Everest HS", "func"="virusb(CH,6,36)"]
	r[n++] = ["name"="F037 Expense HS", "func"="virusb(CH,6,37)"]
	r[n++] = ["name"="F038 Flats HS", "func"="virusb(CH,6,38)"]
	r[n++] = ["name"="F039 Flutes HS", "func"="virusb(CH,6,39)"]
	r[n++] = ["name"="F040 Flutoon HS", "func"="virusb(CH,6,40)"]
	r[n++] = ["name"="F041 Froese HS", "func"="virusb(CH,6,41)"]
	r[n++] = ["name"="F042 FunctionHS", "func"="virusb(CH,6,42)"]
	r[n++] = ["name"="F043 Ganges HS", "func"="virusb(CH,6,43)"]
	r[n++] = ["name"="F044 GateRim HS", "func"="virusb(CH,6,44)"]
	r[n++] = ["name"="F045 Goomby HS", "func"="virusb(CH,6,45)"]
	r[n++] = ["name"="F046 Ham&X HS", "func"="virusb(CH,6,46)"]
	r[n++] = ["name"="F047 Harpsie HS", "func"="virusb(CH,6,47)"]
	r[n++] = ["name"="F048 Hektik HS", "func"="virusb(CH,6,48)"]
	r[n++] = ["name"="F049 HissPad BC", "func"="virusb(CH,6,49)"]
	r[n++] = ["name"="F050 JamMini HS", "func"="virusb(CH,6,50)"]
	r[n++] = ["name"="F051 Jawdan HS", "func"="virusb(CH,6,51)"]
	r[n++] = ["name"="F052 JazRoad HS", "func"="virusb(CH,6,52)"]
	r[n++] = ["name"="F053 J.Edgar HS", "func"="virusb(CH,6,53)"]
	r[n++] = ["name"="F054 JuicOrg HS", "func"="virusb(CH,6,54)"]
	r[n++] = ["name"="F055 Kitchen HS", "func"="virusb(CH,6,55)"]
	r[n++] = ["name"="F056 Latex HS", "func"="virusb(CH,6,56)"]
	r[n++] = ["name"="F057 LordOrg HS", "func"="virusb(CH,6,57)"]
	r[n++] = ["name"="F058 Macho HS", "func"="virusb(CH,6,58)"]
	r[n++] = ["name"="F059 Manfman HS", "func"="virusb(CH,6,59)"]
	r[n++] = ["name"="F060 MarkOne HS", "func"="virusb(CH,6,60)"]
	r[n++] = ["name"="F061 MarsAtx HS", "func"="virusb(CH,6,61)"]
	r[n++] = ["name"="F062 Meddle HS", "func"="virusb(CH,6,62)"]
	r[n++] = ["name"="F063 MelloVl HS", "func"="virusb(CH,6,63)"]
	r[n++] = ["name"="F064 MinorityHS", "func"="virusb(CH,6,64)"]
	r[n++] = ["name"="F065 Monza HS", "func"="virusb(CH,6,65)"]
	r[n++] = ["name"="F066 MoonWeedHS", "func"="virusb(CH,6,66)"]
	r[n++] = ["name"="F067 Multasm HS", "func"="virusb(CH,6,67)"]
	r[n++] = ["name"="F068 MW-StepsHS", "func"="virusb(CH,6,68)"]
	r[n++] = ["name"="F069 Nowhere BC", "func"="virusb(CH,6,69)"]
	r[n++] = ["name"="F070 NylSolo HS", "func"="virusb(CH,6,70)"]
	r[n++] = ["name"="F071 Oboe HS", "func"="virusb(CH,6,71)"]
	r[n++] = ["name"="F072 Oddigy HS", "func"="virusb(CH,6,72)"]
	r[n++] = ["name"="F073 Old S&H HS", "func"="virusb(CH,6,73)"]
	r[n++] = ["name"="F074 Orange HS", "func"="virusb(CH,6,74)"]
	r[n++] = ["name"="F075 Oscar1 HS", "func"="virusb(CH,6,75)"]
	r[n++] = ["name"="F076 Outpost HS", "func"="virusb(CH,6,76)"]
	r[n++] = ["name"="F077 PanShakeHS", "func"="virusb(CH,6,77)"]
	r[n++] = ["name"="F078 PataFiz HS", "func"="virusb(CH,6,78)"]
	r[n++] = ["name"="F079 PeaceOrgHS", "func"="virusb(CH,6,79)"]
	r[n++] = ["name"="F080 Picking HS", "func"="virusb(CH,6,80)"]
	r[n++] = ["name"="F081 PickUp HS", "func"="virusb(CH,6,81)"]
	r[n++] = ["name"="F082 PingOrg HS", "func"="virusb(CH,6,82)"]
	r[n++] = ["name"="F083 Pit-Str HS", "func"="virusb(CH,6,83)"]
	r[n++] = ["name"="F084 Pizza HS", "func"="virusb(CH,6,84)"]
	r[n++] = ["name"="F085 PlukalogHS", "func"="virusb(CH,6,85)"]
	r[n++] = ["name"="F086 PopCorn HS", "func"="virusb(CH,6,86)"]
	r[n++] = ["name"="F087 Prions HS", "func"="virusb(CH,6,87)"]
	r[n++] = ["name"="F088 Pstyro2 HS", "func"="virusb(CH,6,88)"]
	r[n++] = ["name"="F089 Pumpah HS", "func"="virusb(CH,6,89)"]
	r[n++] = ["name"="F090 Qatsi HS", "func"="virusb(CH,6,90)"]
	r[n++] = ["name"="F091 Quack! HS", "func"="virusb(CH,6,91)"]
	r[n++] = ["name"="F092 RadioG HS", "func"="virusb(CH,6,92)"]
	r[n++] = ["name"="F093 Raspry HS", "func"="virusb(CH,6,93)"]
	r[n++] = ["name"="F094 RuminateHS", "func"="virusb(CH,6,94)"]
	r[n++] = ["name"="F095 Saloon HS", "func"="virusb(CH,6,95)"]
	r[n++] = ["name"="F096 Saxpet HS", "func"="virusb(CH,6,96)"]
	r[n++] = ["name"="F097 Series3 HS", "func"="virusb(CH,6,97)"]
	r[n++] = ["name"="F098 ShineOn HS", "func"="virusb(CH,6,98)"]
	r[n++] = ["name"="F099 SidKid HS", "func"="virusb(CH,6,99)"]
	r[n++] = ["name"="F100 SimSyn HS", "func"="virusb(CH,6,100)"]
	r[n++] = ["name"="F101 SinSolo HS", "func"="virusb(CH,6,101)"]
	r[n++] = ["name"="F102 Slapska HS", "func"="virusb(CH,6,102)"]
	r[n++] = ["name"="F103 Spring HS", "func"="virusb(CH,6,103)"]
	r[n++] = ["name"="F104 Spy HS", "func"="virusb(CH,6,104)"]
	r[n++] = ["name"="F105 Squeeze HS", "func"="virusb(CH,6,105)"]
	r[n++] = ["name"="F106 Squoid HS", "func"="virusb(CH,6,106)"]
	r[n++] = ["name"="F107 Sunder HS", "func"="virusb(CH,6,107)"]
	r[n++] = ["name"="F108 Tabloid HS", "func"="virusb(CH,6,108)"]
	r[n++] = ["name"="F109 TheDome HS", "func"="virusb(CH,6,109)"]
	r[n++] = ["name"="F110 Thustra HS", "func"="virusb(CH,6,110)"]
	r[n++] = ["name"="F111 TimeStepHS", "func"="virusb(CH,6,111)"]
	r[n++] = ["name"="F112 Tunnel HS", "func"="virusb(CH,6,112)"]
	r[n++] = ["name"="F113 TuvaWeelHS", "func"="virusb(CH,6,113)"]
	r[n++] = ["name"="F114 TweakMe HS", "func"="virusb(CH,6,114)"]
	r[n++] = ["name"="F115 TwoOfUs HS", "func"="virusb(CH,6,115)"]
	r[n++] = ["name"="F116 Untune HS", "func"="virusb(CH,6,116)"]
	r[n++] = ["name"="F117 Vanilla HS", "func"="virusb(CH,6,117)"]
	r[n++] = ["name"="F118 Voodoo HS", "func"="virusb(CH,6,118)"]
	r[n++] = ["name"="F119 Vorwerk HS", "func"="virusb(CH,6,119)"]
	r[n++] = ["name"="F120 Warlord HS", "func"="virusb(CH,6,120)"]
	r[n++] = ["name"="F121 Wheee! HS", "func"="virusb(CH,6,121)"]
	r[n++] = ["name"="F122 WishBom HS", "func"="virusb(CH,6,122)"]
	r[n++] = ["name"="F123 WoodyBs HS", "func"="virusb(CH,6,123)"]
	r[n++] = ["name"="F124 X-Didge HS", "func"="virusb(CH,6,124)"]
	r[n++] = ["name"="F125 X-Werx HS", "func"="virusb(CH,6,125)"]
	r[n++] = ["name"="F126 Xyrimba HS", "func"="virusb(CH,6,126)"]
	r[n++] = ["name"="F127 Zorch HS", "func"="virusb(CH,6,127)"]
	r[n++] = ["name"="G000 AandreasM@", "func"="virusb(CH,7,0)"]
	r[n++] = ["name"="G001 Aerosol J", "func"="virusb(CH,7,1)"]
	r[n++] = ["name"="G002 AerSynthM@", "func"="virusb(CH,7,2)"]
	r[n++] = ["name"="G003 AI2 Pad M@", "func"="virusb(CH,7,3)"]
	r[n++] = ["name"="G004 AirMonixM@", "func"="virusb(CH,7,4)"]
	r[n++] = ["name"="G005 Apogee M@", "func"="virusb(CH,7,5)"]
	r[n++] = ["name"="G006 AqutouchM@", "func"="virusb(CH,7,6)"]
	r[n++] = ["name"="G007 Baggins M@", "func"="virusb(CH,7,7)"]
	r[n++] = ["name"="G008 BGot90s M@", "func"="virusb(CH,7,8)"]
	r[n++] = ["name"="G009 BigPadSwM@", "func"="virusb(CH,7,9)"]
	r[n++] = ["name"="G010 Bowzerz M@", "func"="virusb(CH,7,10)"]
	r[n++] = ["name"="G011 Cali-AirM@", "func"="virusb(CH,7,11)"]
	r[n++] = ["name"="G012 CheezwizM@", "func"="virusb(CH,7,12)"]
	r[n++] = ["name"="G013 Claps2 HS", "func"="virusb(CH,7,13)"]
	r[n++] = ["name"="G014 Clench BC", "func"="virusb(CH,7,14)"]
	r[n++] = ["name"="G015 CloudCtyM@", "func"="virusb(CH,7,15)"]
	r[n++] = ["name"="G016 COMPump M@", "func"="virusb(CH,7,16)"]
	r[n++] = ["name"="G017 CrossQ BC", "func"="virusb(CH,7,17)"]
	r[n++] = ["name"="G018 D&B FX", "func"="virusb(CH,7,18)"]
	r[n++] = ["name"="G019 D&B Geneqa", "func"="virusb(CH,7,19)"]
	r[n++] = ["name"="G020 D&B Woover", "func"="virusb(CH,7,20)"]
	r[n++] = ["name"="G021 D'EchoerM@", "func"="virusb(CH,7,21)"]
	r[n++] = ["name"="G022 DetektorM@", "func"="virusb(CH,7,22)"]
	r[n++] = ["name"="G023 DigiKoto M", "func"="virusb(CH,7,23)"]
	r[n++] = ["name"="G024 DontFretM@", "func"="virusb(CH,7,24)"]
	r[n++] = ["name"="G025 DripDropM@", "func"="virusb(CH,7,25)"]
	r[n++] = ["name"="G026 Driven M@", "func"="virusb(CH,7,26)"]
	r[n++] = ["name"="G027 EddiWho?M@", "func"="virusb(CH,7,27)"]
	r[n++] = ["name"="G028 EPhase BC", "func"="virusb(CH,7,28)"]
	r[n++] = ["name"="G029 EPStage?M@", "func"="virusb(CH,7,29)"]
	r[n++] = ["name"="G030 EPTines2M@", "func"="virusb(CH,7,30)"]
	r[n++] = ["name"="G031 EPWhirlyM@", "func"="virusb(CH,7,31)"]
	r[n++] = ["name"="G032 EPZeply M@", "func"="virusb(CH,7,32)"]
	r[n++] = ["name"="G033 ETom2002M@", "func"="virusb(CH,7,33)"]
	r[n++] = ["name"="G034 Fingers M@", "func"="virusb(CH,7,34)"]
	r[n++] = ["name"="G035 FMChittrM@", "func"="virusb(CH,7,35)"]
	r[n++] = ["name"="G036 FourSaws", "func"="virusb(CH,7,36)"]
	r[n++] = ["name"="G037 FunkLd-1SM", "func"="virusb(CH,7,37)"]
	r[n++] = ["name"="G038 FunkLd-2SM", "func"="virusb(CH,7,38)"]
	r[n++] = ["name"="G039 FunkLd-3SM", "func"="virusb(CH,7,39)"]
	r[n++] = ["name"="G040 FunkLd-4SM", "func"="virusb(CH,7,40)"]
	r[n++] = ["name"="G041 GedyLeedM@", "func"="virusb(CH,7,41)"]
	r[n++] = ["name"="G042 Gntle9thM@", "func"="virusb(CH,7,42)"]
	r[n++] = ["name"="G043 Grander M@", "func"="virusb(CH,7,43)"]
	r[n++] = ["name"="G044 GrimeyM@", "func"="virusb(CH,7,44)"]
	r[n++] = ["name"="G045 Hallows M@", "func"="virusb(CH,7,45)"]
	r[n++] = ["name"="G046 HarmopadM@", "func"="virusb(CH,7,46)"]
	r[n++] = ["name"="G047 He-VPlukM@", "func"="virusb(CH,7,47)"]
	r[n++] = ["name"="G048 HoldChrdM@", "func"="virusb(CH,7,48)"]
	r[n++] = ["name"="G049 HrmadnesM@", "func"="virusb(CH,7,49)"]
	r[n++] = ["name"="G050 Jetropa M@", "func"="virusb(CH,7,50)"]
	r[n++] = ["name"="G051 JunoPowrM@", "func"="virusb(CH,7,51)"]
	r[n++] = ["name"="G052 JV Bass M@", "func"="virusb(CH,7,52)"]
	r[n++] = ["name"="G053 Kompin' M@", "func"="virusb(CH,7,53)"]
	r[n++] = ["name"="G054 Korgan M@", "func"="virusb(CH,7,54)"]
	r[n++] = ["name"="G055 Kyrie M@", "func"="virusb(CH,7,55)"]
	r[n++] = ["name"="G056 Lektrik M@", "func"="virusb(CH,7,56)"]
	r[n++] = ["name"="G057 LetsSyncM@", "func"="virusb(CH,7,57)"]
	r[n++] = ["name"="G058 LongKickSM", "func"="virusb(CH,7,58)"]
	r[n++] = ["name"="G059 LuckyMan J", "func"="virusb(CH,7,59)"]
	r[n++] = ["name"="G060 MelodieaM@", "func"="virusb(CH,7,60)"]
	r[n++] = ["name"="G061 MiniBassSM", "func"="virusb(CH,7,61)"]
	r[n++] = ["name"="G062 MiniBS-2SM", "func"="virusb(CH,7,62)"]
	r[n++] = ["name"="G063 MiniBS-3SM", "func"="virusb(CH,7,63)"]
	r[n++] = ["name"="G064 MiniBS-4SM", "func"="virusb(CH,7,64)"]
	r[n++] = ["name"="G065 MiniBS-5SM", "func"="virusb(CH,7,65)"]
	r[n++] = ["name"="G066 MiniLeadSM", "func"="virusb(CH,7,66)"]
	r[n++] = ["name"="G067 ModsweepM@", "func"="virusb(CH,7,67)"]
	r[n++] = ["name"="G068 NewSnareBC", "func"="virusb(CH,7,68)"]
	r[n++] = ["name"="G069 NewWorldM@", "func"="virusb(CH,7,69)"]
	r[n++] = ["name"="G070 NoizBassM@", "func"="virusb(CH,7,70)"]
	r[n++] = ["name"="G071 ObiPad J", "func"="virusb(CH,7,71)"]
	r[n++] = ["name"="G072 OceanusM@", "func"="virusb(CH,7,72)"]
	r[n++] = ["name"="G073 OhEq-8 M@", "func"="virusb(CH,7,73)"]
	r[n++] = ["name"="G074 Oh Yeah M@", "func"="virusb(CH,7,74)"]
	r[n++] = ["name"="G075 O'Pad M@", "func"="virusb(CH,7,75)"]
	r[n++] = ["name"="G076 OrbteriaM@", "func"="virusb(CH,7,76)"]
	r[n++] = ["name"="G077 PadLayerM@", "func"="virusb(CH,7,77)"]
	r[n++] = ["name"="G078 Paiow M@", "func"="virusb(CH,7,78)"]
	r[n++] = ["name"="G079 Pat'sGR M@", "func"="virusb(CH,7,79)"]
	r[n++] = ["name"="G080 Pergru M@", "func"="virusb(CH,7,80)"]
	r[n++] = ["name"="G081 Perky! M@", "func"="virusb(CH,7,81)"]
	r[n++] = ["name"="G082 PhazplukM@", "func"="virusb(CH,7,82)"]
	r[n++] = ["name"="G083 Popcomp M@", "func"="virusb(CH,7,83)"]
	r[n++] = ["name"="G084 PortaPoly@", "func"="virusb(CH,7,84)"]
	r[n++] = ["name"="G085 ProfeticM@", "func"="virusb(CH,7,85)"]
	r[n++] = ["name"="G086 PrtaBeloBC", "func"="virusb(CH,7,86)"]
	r[n++] = ["name"="G087 Punchit2SV", "func"="virusb(CH,7,87)"]
	r[n++] = ["name"="G088 Punsh itSV", "func"="virusb(CH,7,88)"]
	r[n++] = ["name"="G089 QMenMW BC", "func"="virusb(CH,7,89)"]
	r[n++] = ["name"="G090 Replika M@", "func"="virusb(CH,7,90)"]
	r[n++] = ["name"="G091 ResoChrdJS", "func"="virusb(CH,7,91)"]
	r[n++] = ["name"="G092 Reveal JS", "func"="virusb(CH,7,92)"]
	r[n++] = ["name"="G093 RezTailsM@", "func"="virusb(CH,7,93)"]
	r[n++] = ["name"="G094 RichWind", "func"="virusb(CH,7,94)"]
	r[n++] = ["name"="G095 RimShot BC", "func"="virusb(CH,7,95)"]
	r[n++] = ["name"="G096 Ripper JS", "func"="virusb(CH,7,96)"]
	r[n++] = ["name"="G097 Rollin JS", "func"="virusb(CH,7,97)"]
	r[n++] = ["name"="G098 Rollups M@", "func"="virusb(CH,7,98)"]
	r[n++] = ["name"="G099 Saw-Ya! M@", "func"="virusb(CH,7,99)"]
	r[n++] = ["name"="G100 ShortWAVM@", "func"="virusb(CH,7,100)"]
	r[n++] = ["name"="G101 Spaced JS", "func"="virusb(CH,7,101)"]
	r[n++] = ["name"="G102 StarPad J", "func"="virusb(CH,7,102)"]
	r[n++] = ["name"="G103 Stratus JS", "func"="virusb(CH,7,103)"]
	r[n++] = ["name"="G104 SubdvisnM@", "func"="virusb(CH,7,104)"]
	r[n++] = ["name"="G105 SunbeamsJS", "func"="virusb(CH,7,105)"]
	r[n++] = ["name"="G106 SweePlukM@", "func"="virusb(CH,7,106)"]
	r[n++] = ["name"="G107 Synchym2M@", "func"="virusb(CH,7,107)"]
	r[n++] = ["name"="G108 SyncPedlM@", "func"="virusb(CH,7,108)"]
	r[n++] = ["name"="G109 Tender JS", "func"="virusb(CH,7,109)"]
	r[n++] = ["name"="G110 TheramosM@", "func"="virusb(CH,7,110)"]
	r[n++] = ["name"="G111 Tight8s M@", "func"="virusb(CH,7,111)"]
	r[n++] = ["name"="G112 Tremor JS", "func"="virusb(CH,7,112)"]
	r[n++] = ["name"="G113 TronFlt M@", "func"="virusb(CH,7,113)"]
	r[n++] = ["name"="G114 TronStr M@", "func"="virusb(CH,7,114)"]
	r[n++] = ["name"="G115 TwinPadsM@", "func"="virusb(CH,7,115)"]
	r[n++] = ["name"="G116 UofYouthM@", "func"="virusb(CH,7,116)"]
	r[n++] = ["name"="G117 VibePad M@", "func"="virusb(CH,7,117)"]
	r[n++] = ["name"="G118 VolutionM@", "func"="virusb(CH,7,118)"]
	r[n++] = ["name"="G119 Wavelet M@", "func"="virusb(CH,7,119)"]
	r[n++] = ["name"="G120 Whales JS", "func"="virusb(CH,7,120)"]
	r[n++] = ["name"="G121 WineglasM@", "func"="virusb(CH,7,121)"]
	r[n++] = ["name"="G122 WowGrowlM@", "func"="virusb(CH,7,122)"]
	r[n++] = ["name"="G123 WynwouldM@", "func"="virusb(CH,7,123)"]
	r[n++] = ["name"="G124 X Dream JS", "func"="virusb(CH,7,124)"]
	r[n++] = ["name"="G125 XitLeft M@", "func"="virusb(CH,7,125)"]
	r[n++] = ["name"="G126 X-Men JS", "func"="virusb(CH,7,126)"]
	r[n++] = ["name"="G127 Zyntar M@", "func"="virusb(CH,7,127)"]
	r[n++] = ["name"="H000 AESound zs", "func"="virusb(CH,8,0)"]
	r[n++] = ["name"="H001 AldoNovaM", "func"="virusb(CH,8,1)"]
	r[n++] = ["name"="H002 AmbientBlJ", "func"="virusb(CH,8,2)"]
	r[n++] = ["name"="H003 AmbientFXJ", "func"="virusb(CH,8,3)"]
	r[n++] = ["name"="H004 ambiRgM zs", "func"="virusb(CH,8,4)"]
	r[n++] = ["name"="H005 AnHigh M", "func"="virusb(CH,8,5)"]
	r[n++] = ["name"="H006 Arcade BC", "func"="virusb(CH,8,6)"]
	r[n++] = ["name"="H007 Atlas J", "func"="virusb(CH,8,7)"]
	r[n++] = ["name"="H008 Attack! J", "func"="virusb(CH,8,8)"]
	r[n++] = ["name"="H009 AutoTknoBC", "func"="virusb(CH,8,9)"]
	r[n++] = ["name"="H010 BadLand M", "func"="virusb(CH,8,10)"]
	r[n++] = ["name"="H011 Bass 415 M", "func"="virusb(CH,8,11)"]
	r[n++] = ["name"="H012 Bass 504 M", "func"="virusb(CH,8,12)"]
	r[n++] = ["name"="H013 Basser M", "func"="virusb(CH,8,13)"]
	r[n++] = ["name"="H014 BassIk M", "func"="virusb(CH,8,14)"]
	r[n++] = ["name"="H015 basting2zs", "func"="virusb(CH,8,15)"]
	r[n++] = ["name"="H016 basting zs", "func"="virusb(CH,8,16)"]
	r[n++] = ["name"="H017 B-Deep M", "func"="virusb(CH,8,17)"]
	r[n++] = ["name"="H018 B-Foe M", "func"="virusb(CH,8,18)"]
	r[n++] = ["name"="H019 bigTung zs", "func"="virusb(CH,8,19)"]
	r[n++] = ["name"="H020 Bleu! M", "func"="virusb(CH,8,20)"]
	r[n++] = ["name"="H021 Blotto M", "func"="virusb(CH,8,21)"]
	r[n++] = ["name"="H022 Bubble2 M", "func"="virusb(CH,8,22)"]
	r[n++] = ["name"="H023 CappSt M", "func"="virusb(CH,8,23)"]
	r[n++] = ["name"="H024 Cavsak M", "func"="virusb(CH,8,24)"]
	r[n++] = ["name"="H025 cirqStb zs", "func"="virusb(CH,8,25)"]
	r[n++] = ["name"="H026 CLEeeN M", "func"="virusb(CH,8,26)"]
	r[n++] = ["name"="H027 Cloakin M", "func"="virusb(CH,8,27)"]
	r[n++] = ["name"="H028 cutRes zs", "func"="virusb(CH,8,28)"]
	r[n++] = ["name"="H029 decDATA2zs", "func"="virusb(CH,8,29)"]
	r[n++] = ["name"="H030 decDATA3zs", "func"="virusb(CH,8,30)"]
	r[n++] = ["name"="H031 decDATA zs", "func"="virusb(CH,8,31)"]
	r[n++] = ["name"="H032 deciDAT4zs", "func"="virusb(CH,8,32)"]
	r[n++] = ["name"="H033 dirty zs", "func"="virusb(CH,8,33)"]
	r[n++] = ["name"="H034 dopeEp zs", "func"="virusb(CH,8,34)"]
	r[n++] = ["name"="H035 Dragon M", "func"="virusb(CH,8,35)"]
	r[n++] = ["name"="H036 dropIT zs", "func"="virusb(CH,8,36)"]
	r[n++] = ["name"="H037 drpBomb zs", "func"="virusb(CH,8,37)"]
	r[n++] = ["name"="H038 Drubber BC", "func"="virusb(CH,8,38)"]
	r[n++] = ["name"="H039 Dry Bass J", "func"="virusb(CH,8,39)"]
	r[n++] = ["name"="H040 dstStep zs", "func"="virusb(CH,8,40)"]
	r[n++] = ["name"="H041 Dubsak M", "func"="virusb(CH,8,41)"]
	r[n++] = ["name"="H042 Dumb! M", "func"="virusb(CH,8,42)"]
	r[n++] = ["name"="H043 Empira 2M", "func"="virusb(CH,8,43)"]
	r[n++] = ["name"="H044 Entropie J", "func"="virusb(CH,8,44)"]
	r[n++] = ["name"="H045 Everest J", "func"="virusb(CH,8,45)"]
	r[n++] = ["name"="H046 Facial M", "func"="virusb(CH,8,46)"]
	r[n++] = ["name"="H047 FePudn zs", "func"="virusb(CH,8,47)"]
	r[n++] = ["name"="H048 FlutDrumBC", "func"="virusb(CH,8,48)"]
	r[n++] = ["name"="H049 fnkStrg zs", "func"="virusb(CH,8,49)"]
	r[n++] = ["name"="H050 GBEp3 zs", "func"="virusb(CH,8,50)"]
	r[n++] = ["name"="H051 george2 zs", "func"="virusb(CH,8,51)"]
	r[n++] = ["name"="H052 GooHat M", "func"="virusb(CH,8,52)"]
	r[n++] = ["name"="H053 GotHAM! M", "func"="virusb(CH,8,53)"]
	r[n++] = ["name"="H054 HIDEson M", "func"="virusb(CH,8,54)"]
	r[n++] = ["name"="H055 IndustryBC", "func"="virusb(CH,8,55)"]
	r[n++] = ["name"="H056 LepY2 zs", "func"="virusb(CH,8,56)"]
	r[n++] = ["name"="H057 LepY3 zs", "func"="virusb(CH,8,57)"]
	r[n++] = ["name"="H058 lootRng zs", "func"="virusb(CH,8,58)"]
	r[n++] = ["name"="H059 Lost M", "func"="virusb(CH,8,59)"]
	r[n++] = ["name"="H060 marimba1zs", "func"="virusb(CH,8,60)"]
	r[n++] = ["name"="H061 marimba4zs", "func"="virusb(CH,8,61)"]
	r[n++] = ["name"="H062 MeBad? M", "func"="virusb(CH,8,62)"]
	r[n++] = ["name"="H063 Menace M", "func"="virusb(CH,8,63)"]
	r[n++] = ["name"="H064 MONose zs", "func"="virusb(CH,8,64)"]
	r[n++] = ["name"="H065 mostHih zs", "func"="virusb(CH,8,65)"]
	r[n++] = ["name"="H066 Mr.Foo M", "func"="virusb(CH,8,66)"]
	r[n++] = ["name"="H067 Necro M", "func"="virusb(CH,8,67)"]
	r[n++] = ["name"="H068 NoFuture M", "func"="virusb(CH,8,68)"]
	r[n++] = ["name"="H069 orguit zs", "func"="virusb(CH,8,69)"]
	r[n++] = ["name"="H070 phasEP zs", "func"="virusb(CH,8,70)"]
	r[n++] = ["name"="H071 Plead M", "func"="virusb(CH,8,71)"]
	r[n++] = ["name"="H072 Pluka zs", "func"="virusb(CH,8,72)"]
	r[n++] = ["name"="H073 PowerStrnJ", "func"="virusb(CH,8,73)"]
	r[n++] = ["name"="H074 pulsRay zs", "func"="virusb(CH,8,74)"]
	r[n++] = ["name"="H075 Quarp BC", "func"="virusb(CH,8,75)"]
	r[n++] = ["name"="H076 RbbrBellBC", "func"="virusb(CH,8,76)"]
	r[n++] = ["name"="H077 ReBird M", "func"="virusb(CH,8,77)"]
	r[n++] = ["name"="H078 resPad zs", "func"="virusb(CH,8,78)"]
	r[n++] = ["name"="H079 Reverse J", "func"="virusb(CH,8,79)"]
	r[n++] = ["name"="H080 rmBack zs", "func"="virusb(CH,8,80)"]
	r[n++] = ["name"="H081 rngPort zs", "func"="virusb(CH,8,81)"]
	r[n++] = ["name"="H082 Roboe zs", "func"="virusb(CH,8,82)"]
	r[n++] = ["name"="H083 Shifted BC", "func"="virusb(CH,8,83)"]
	r[n++] = ["name"="H084 ShineChrdJ", "func"="virusb(CH,8,84)"]
	r[n++] = ["name"="H085 shivrPd zs", "func"="virusb(CH,8,85)"]
	r[n++] = ["name"="H086 sineZZZ zs", "func"="virusb(CH,8,86)"]
	r[n++] = ["name"="H087 sinMorf zs", "func"="virusb(CH,8,87)"]
	r[n++] = ["name"="H088 sitar zs", "func"="virusb(CH,8,88)"]
	r[n++] = ["name"="H089 Skware zs", "func"="virusb(CH,8,89)"]
	r[n++] = ["name"="H090 smoovLd zs", "func"="virusb(CH,8,90)"]
	r[n++] = ["name"="H091 sneakr zs", "func"="virusb(CH,8,91)"]
	r[n++] = ["name"="H092 SoftBell J", "func"="virusb(CH,8,92)"]
	r[n++] = ["name"="H093 Softi J", "func"="virusb(CH,8,93)"]
	r[n++] = ["name"="H094 SoftSeq. J", "func"="virusb(CH,8,94)"]
	r[n++] = ["name"="H095 sofueMODzs", "func"="virusb(CH,8,95)"]
	r[n++] = ["name"="H096 SoSad M", "func"="virusb(CH,8,96)"]
	r[n++] = ["name"="H097 SpaceNighJ", "func"="virusb(CH,8,97)"]
	r[n++] = ["name"="H098 spasDrv zs", "func"="virusb(CH,8,98)"]
	r[n++] = ["name"="H099 Spinner M", "func"="virusb(CH,8,99)"]
	r[n++] = ["name"="H100 spoolPd zs", "func"="virusb(CH,8,100)"]
	r[n++] = ["name"="H101 sqPadMM zs", "func"="virusb(CH,8,101)"]
	r[n++] = ["name"="H102 squar00 zs", "func"="virusb(CH,8,102)"]
	r[n++] = ["name"="H103 Sr.Goo M", "func"="virusb(CH,8,103)"]
	r[n++] = ["name"="H104 step2it zs", "func"="virusb(CH,8,104)"]
	r[n++] = ["name"="H105 Subbass zs", "func"="virusb(CH,8,105)"]
	r[n++] = ["name"="H106 Sunday M", "func"="virusb(CH,8,106)"]
	r[n++] = ["name"="H107 Tomita J", "func"="virusb(CH,8,107)"]
	r[n++] = ["name"="H108 Torque", "func"="virusb(CH,8,108)"]
	r[n++] = ["name"="H109 UfO 4 M", "func"="virusb(CH,8,109)"]
	r[n++] = ["name"="H110 UKG2 BC", "func"="virusb(CH,8,110)"]
	r[n++] = ["name"="H111 UKG BC", "func"="virusb(CH,8,111)"]
	r[n++] = ["name"="H112 V_Acid#9 M", "func"="virusb(CH,8,112)"]
	r[n++] = ["name"="H113 V-Acid#4 M", "func"="virusb(CH,8,113)"]
	r[n++] = ["name"="H114 V-Acid#7 M", "func"="virusb(CH,8,114)"]
	r[n++] = ["name"="H115 VCS 3a J", "func"="virusb(CH,8,115)"]
	r[n++] = ["name"="H116 videoG1 zs", "func"="virusb(CH,8,116)"]
	r[n++] = ["name"="H117 videoG2 zs", "func"="virusb(CH,8,117)"]
	r[n++] = ["name"="H118 videoG4 zs", "func"="virusb(CH,8,118)"]
	r[n++] = ["name"="H119 waowLd zs", "func"="virusb(CH,8,119)"]
	r[n++] = ["name"="H120 Weazel M", "func"="virusb(CH,8,120)"]
	r[n++] = ["name"="H121 WetThn zs", "func"="virusb(CH,8,121)"]
	r[n++] = ["name"="H122 Wobble M", "func"="virusb(CH,8,122)"]
	r[n++] = ["name"="H123 xPandr zs", "func"="virusb(CH,8,123)"]
	r[n++] = ["name"="H124 yahy zs", "func"="virusb(CH,8,124)"]
	r[n++] = ["name"="H125 Yeao! M", "func"="virusb(CH,8,125)"]
	r[n++] = ["name"="H126 ZartPad J", "func"="virusb(CH,8,126)"]
	r[n++] = ["name"="H127 Zupfi J", "func"="virusb(CH,8,127)"]
 	r[n++] = ["name"="None", "func"=""]
	return(r)
}

# BANK A and B are user-editable, so we can't depend on those.

# A000 OvertureCK
# A001 Impact MS
# A002 DJ-IQ RP
# A003 BasstardJS
# A004 101BASS RP
# A005 CyberPopHS
# A006 NOT-PAD RP
# A007 HarmonixJS
# A008 OBY-PAD RP
# A009 Vi-Rtro RP
# A010 BASSEY NH
# A011 GungGungCK
# A012 PADINGS RP
# A013 FM Bass JS
# A014 MovementHS
# A015 Plang CK
# A016 The Fog CK
# A017 :)-bass RP
# A018 SmoothBsBC
# A019 SwellPadNH
# A020 MINI-M K9
# A021 SINEBEE JS
# A022 Grunge CK
# A023 JUNOAPG JS
# A024 InfinityJS
# A025 FlagoletAD
# A026 7thCORD RP
# A027 Grunge2 CK
# A028 CORD 1 RP
# A029 WAVE 1 K9
# A030 Wheek RP
# A031 LFOSSTZ K9
# A032 Puls4thsBC
# A033 TalkToMeAS
# A034 Strings CK
# A035 Soft3rdsBC
# A036 Aouuh CK
# A037 SpacePatHS
# A038 NicoPd4 NH
# A039 DmodePadMS
# A040 House 3 AS
# A041 BIGF1SH PN
# A042 RingSyncCK
# A043 Moloko K9
# A044 NicoPd4 NH
# A045 ResobassK9
# A046 TimpotroHS
# A047 SideBandNH
# A048 CybChoirK9
# A049 Alert JS
# A050 FltDist MZ
# A051 BassDrumCK
# A052 I k9ow UK9
# A053 OliveLF MS
# A054 SatSync CK
# A055 Virus CK
# A056 PP?-PAD RP
# A057 Adrenalin2
# A058 Farfisa AD
# A059 CALLIOPEJS
# A060 Prodigy JS
# A061 Howner RP
# A062 LFOnoiseK9
# A063 Teeobee K9
# A064 Teeotwo K9
# A065 Talking PI
# A066 Softie CK
# A067 DistoriaK9
# A068 PHASA RP
# A069 WAVE 1 K9
# A070 CyberPopHS
# A071 NicoPd2 NH
# A072 StrummerHS
# A073 WickiderPN
# A074 Ageless JH
# A075 SpaceChor2
# A076 Glint PI
# A077 RedPad NH
# A078 ShinyPadNH
# A079 FlagoletAD
# A080 VELORP RP
# A081 SwellPadNH
# A082 M-ORGAN RP
# A083 TO-OLD RP
# A084 ? BASS RP
# A085 FatZapp K9
# A086 ALISER MS
# A087 SFX-XXX RP
# A088 BE-TWO RP
# A089 VI-SYNC RP
# A090 Formant PI
# A091 BASSEY NH
# A092 SlowSeq PN
# A093 Cleanex JH
# A094 MovementHS
# A095 WishU HeHS
# A096 SFX-VC3 RP
# A097 CataclysMS
# A098 PrcChordAD
# A099 DJ-IQ RP
# A100 Subbass K9
# A101 NEU *UTZ
# A102 MINI-M K9
# A103 LFOSSTZ K9
# A104 Strings CK
# A105 HOLLAND RP
# A106 GO-SEQ RP
# A107 PiSweep RP
# A108 Bacon RP
# A109 DIS-BD RP
# A110 BassDrm2CK
# A111 BassDrm3CK
# A112 BassDrm4CK
# A113 BassDrm5CK
# A114 Kick 7 BC
# A115 Snare 1 BC
# A116 Snare 2 BC
# A117 Snare 3 BC
# A118 Claps RP
# A119 ClsdHHatBC
# A120 ClsdHHT2BC
# A121 OpenHHatBC
# A122 Crash4 BC
# A123 RideRim BC
# A124 RideBellBC
# A125 >>INPUT<<
# A126 - Init -
# A127 - START -
# BANK B
# B000 First K
# B001 Virus K
# B002 V-Pad 1 K
# B003 V-Birth1 K
# B004 V-Birth2 K
# B005 RavePad2 K
# B006 Compres2 K
# B007 PP?-PAD RP
# B008 NO-SEQ RP
# B009 V-Pad 2 K
# B010 Vi-bass RP
# B011 VI-SYNC RP
# B012 ZZ-ROB RP
# B013 Polaris
# B014 Compress K
# B015 SatSync K
# B016 ZZ-bass RP
# B017 XOBASS RP
# B018 No Age
# B019 PAD-777 RP
# B020 Virus 2 K
# B021 Clockwork
# B022 NO-TJO RP
# B023 V-Resoni K
# B024 TechnoArp
# B025 Tension...
# B026 V-Church K
# B027 Sitar
# B028 HOLLAND RP
# B029 GeneratoMS
# B030 InfectLead
# B031 Melodies
# B032 V-Orgel K
# B033 Cutoff K
# B034 V-Birth3 K
# B035 Zoober
# B036 V-Pad 3 K
# B037 ZZ-YOU RP
# B038 PercVox
# B039 PPG Bass2
# B040 S&H Arp
# B041 J.Arnold
# B042 Arpegiator
# B043 SpaceChor2
# B044 Adrenalin1
# B045 Arpeggia
# B046 Snip
# B047 SLAP-IT RP
# B048 TOM-TOM RP
# B049 HH 3
# B050 HH 2
# B051 O-HIHAT RP
# B052 C-HIHAT RP
# B053 V-snare RP
# B054 SNR 1
# B055 Adrenalin2
# B056 V-CUSS RP
# B057 Stick
# B058 Low
# B059 V-Jump K
# B060 Sci-fi1 K
# B061 NEU *UTZ
# B062 SatSync2 K
# B063 Resonator
# B064 WEX TEX RP
# B065 Sci-Fi 2
# B066 ABC-1 RP
# B067 RotDAM RP
# B068 Wino Bench
# B069 SEA-PAD RP
# B070 BluePAD RP
# B071 TECH-NO RP
# B072 SO-SOFT RP
# B073 Spaz meC*:
# B074 DANCIO2 RP
# B075 IQ-PAD RP
# B076 Uck Muk RP
# B077 RINGPAD
# B078 DarkMatter
# B079 BIG.F1SH
# B080 Welard !
# B081 PPG-PAD
# B082 SinusSeq
# B083 MOOBASS RP
# B084 MOOGY RP
# B085 Sci-fi2 K
# B086 TB-V03 RP
# B087 BASS-ON RP
# B088 SWELLAD RP
# B089 UNDERO RP
# B090 ViBee 1 RP
# B091 WAVEN RP
# B092 MINI-M RP
# B093 543 SEQ RP
# B094 FX 303 RP
# B095 ACCYBAS RP
# B096 V-550 RP
# B097 INP clean
# B098 INPlopass
# B099 INP reso
# B100 INPhipass
# B101 INPbandps
# B102 INPdouble
# B103 INPflange
# B104 INP key!
# B105 INPkeyfol
# B106 INP pad
# B107 INP arp1
# B108 INPsatura
# B109 INP amp
# B110 INPshaper
# B111 VOC osci1
# B112 VOC pad
# B113 VOC pwm
# B114 VOC waves
# B115 VOC crisp
# B116 VOC tube
# B117 VOCwalker
# B118 VOCnoise1
# B119 VOCreso1
# B120 VOCrevers
# B121 VOC bell1
# B122 VOCtwelve
# B123 VOCnarrow
# B124 VOCdiffus
# B125 VOC lfo
# B126 VOC bell2
# B127 VOC room

function patchmap_types_virusb(type) {
	n=0
	p = []
	if ( "good" ~~ type ) {
		p[n++] = "E043"
		p[n++] = "E080"
		p[n++] = "D014"
		p[n++] = "G056"
		p[n++] = "E022"
		p[n++] = "G034"
		p[n++] = "F108"
		p[n++] = "D035"
		p[n++] = "H086"
		p[n++] = "C094"
		p[n++] = "D084"
		p[n++] = "E079"
		p[n++] = "E091"
		p[n++] = "H075"
		p[n++] = "D034"
		p[n++] = "F098"
		p[n++] = "F097"
		p[n++] = "D004"
		p[n++] = "E117"
		p[n++] = "F082"
		p[n++] = "F001"
		p[n++] = "H105"
		p[n++] = "E105"
		p[n++] = "E098"
		p[n++] = "D053"
		p[n++] = "E056"
		p[n++] = "G056"
		p[n++] = "D116"
		p[n++] = "F097"
		p[n++] = "C008"
		p[n++] = "D071"
		p[n++] = "F039"
		p[n++] = "E001"
		p[n++] = "G065"
		p[n++] = "E002"
	}
	if ( "pad" ~~ type ) {
		p[n++] = "C080 Wave-PadJS"
		p[n++] = "G060 MelodieaM@"
		p[n++] = "D077 101-SUB RP"
		p[n++] = "E019 Decay JS"
		p[n++] = "G108 SyncPedlM@"
		p[n++] = "H090 smoovLd zs"
		p[n++] = "E046 HOA Pad SV"
		p[n++] = "D025 PADINGS RP"
		p[n++] = "D044 SoLead RP"
		p[n++] = "F059 Manfman HS"
		p[n++] = "G004 AirMonixM@"
		p[n++] = "G002 AerSynthM@"
		p[n++] = "G027 EddiWho?M@"
		p[n++] = "C091 Hover JS"
		p[n++] = "F009 Boingy HS"
		p[n++] = "G109 Tender JS"
		p[n++] = "F056 Latex HS"
		p[n++] = "F039 Flutes HS"
		p[n++] = "H050 GBEp3 zs"
		p[n++] = "E089"
	}
	if ( "hard" ~~ type ) {
		p[n++] = "G030 EPTines2M@"
		p[n++] = "G041"
		p[n++] = "H086"
	}
	if ( "bass" ~~ type ) {
		p[n++] = "G041"
		p[n++] = "Bassic JS"
		p[n++] = "C008"
	}
	if ( "perc" ~~ type ) {
		p[n++] = "C089 Percold JS"
		p[n++] = "E075"
	}
	if ( "drum" ~~ type ) {
		p[n++] = "C021 FX Drum JS"
	}
	if ( "vocal" ~~ type ) {
		p[n++] = "C116 Choir 4 BC"
		p[n++] = "H086"
	}

	return(p)
}

function patchmap_drums_virusb() {
	r = []
	n = 0
	r[n++] = ["name"="C021 FX Drum JS", "func"="virusb(10,3,21)"]
	return(r)
}

function drumtypes_virusb(type) {
	r = []
	n = 0
	if ( "good" ~~ type ) {
		r[n++] = "C021 FX Drum JS"
	}
	return(r)
}


function virus_parameter(pg,ch,param,val) {
	return(midibytes(0xf0, 0x00, 0x20, 0x33, 0x01, 0x10,
			pg, ch, param, val, 0xf7))
}

function virus_partoutput(ch,v) {
	return(virus_parameter(0x72,ch-1,41,v))
}
function virus_partvolume(ch,v) {
	return(virus_parameter(0x72,ch-1,39,v))
}
