#	file: gs_utils.k
#	This library was inspired by Tim's sc7_util.k
#	Modified and extended for GS-compatible SoundCanvas SC-880
#	Holger Stoltenberg, sg@issus.fh-hamburg.de, 1998-2001
#	======================================================================
#

function gs_strangemap() {
	# maps a part-number passed (often equal to midi channel)  
	#   to a GS-internal block address, which is returned.
	# format of array-init    is:        index = returnvalue
	# format of function-call is:  returnvalue = gs_strangemap()[index]
	#

	return( [10=0, 1=1,  2=2,  3=3,  4=4,  5=5,  6=6, 7=7, 8=8, 9=9,
	              11=10,12=11,13=12,14=13,15=14,16=15] )
}

function gs_chksum(...) {
	# returns the checksum used in GS sysex-commands of
	# any number of bytes passed 

	sum = 0

	for ( n=0; n<nargs(); n++ ) {
	  sum += argv(n)
	}	
	chksum = (128-sum%128) & 0x7f	# mask to avoid chksum==0x80,
					# return 0x00 instead

	return (chksum)
}

function gs_reset() {
	# reset GS-device (e.g.sound canvas) to its GS-factory default,
	# has to be called once before using NRPN controllers

	r     = ''
	cksum = gs_chksum(0x40,0x00,0x7f,0x00)

	r += midibytes(0xf0,0x41,0x10,0x42,0x12,  0x40,0x00,0x7f,0x00,  cksum,0xf7)	

	return (r)
}

function gs_turnon(...) {
	# turns on a particular channel by setting the RX channel to itself
	r = ''
	for ( n=0; n<nargs(); n++ ) {
	  chnum = argv(n)
	  cn    = gs_strangemap()[chnum] + 0x10
	  v     = chnum-1
	  cksum = gs_chksum(0x40,cn,0x02,v)

	  r += midibytes(0xf0,0x41,0x10,0x42,0x12,  0x40,cn,0x02,v,  cksum,0xf7)
	}
	return (r)
}

function gs_turnoff(...) {
	# turns off particular channels by setting the RX channel to 0x10
	r = ''
	for ( n=0; n<nargs(); n++ ) {
	  chnum = argv(n)
	  cn    = gs_strangemap()[chnum] + 0x10
	  cksum = gs_chksum(0x40,cn,0x02,0x10)

	  r += midibytes(0xf0,0x41,0x10,0x42,0x12,  0x40,cn,0x02,0x10,  cksum,0xf7)
	}
	return (r)
}

function gs_scaletune(chnum,c,db,d,eb,e,f,gb,g,ab,a,bb,h,addr) {
	# tunes the 12 tones of a particular channel to individual intonation.
	# (passed in integer cents, a value of 0x40 results in equal temperament.)
	r     = ''
	cn    = gs_strangemap()[chnum] + 0x10
	cksum = gs_chksum(addr,cn,0x40,c,db,d,eb,e,f,gb,g,ab,a,bb,h)
	r    += midibytes(0xf0,0x41,0x10,0x42,0x12,
			addr,cn,0x40,c,db,d,eb,e,f,gb,g,ab,a,bb,h,
			cksum,0xf7)
	return (r)
}

function gs_finetune(chnum,dcent,addr) {
	#          midichn|value|0x40 or 0x50 == Midiinput A or B 
	# returns a phrase to retune one part (midi channel with chnum) to
	# +/-dcent cents relative to equal tempered intonation using sysex.
	# (dcent is passed as a *float* value, range from -100.0 to + 99.99)
	
	r      = ''
	blkn   = gs_strangemap()[chnum] + 0x10

	# scale dcent to 100 cent / 14 bit resolution and clip LSB part
	# jj     = integer ((dcent / 100.0) * 8192.0)
	jj     = integer (dcent * 81.92)		# mult. (8192 / 100)
	jj0    = jj / 128

	# add offset for dcent=0
	cmsb   = jj0 + 0x40

	# compute lsb as difference between scaled input dcent and msb-value.
	# att: integer arithmetics ...: jj / 128 * 128 is not jj !
	clsb   = jj - (jj0 * 128)

	# adjust result for carry
	if (clsb < 0) {
	  clsb += 128
	  cmsb -= 1
	}	

	# diagnostics01
	# printf (" %f %s %d    %s %d\n",dcent,typeof(cmsb),cmsb,typeof(clsb),clsb)

	# prepare midi output phrase
	cksum = gs_chksum(addr,blkn,0x2a,cmsb,clsb)
	r    += midibytes(0xf0,0x41,0x10,0x42,0x12,
			  addr,blkn,0x2a,cmsb,clsb,  cksum,0xf7)
	return (r)
}

function gs_coarsetune(chnum, semi,addr) {
	#            midichn|value|0x40 or 0x50 == Midiinput A or B 
	# returns a phrase to retune one part (midi channel with chnum) to
	# +/-semi semitones relative to normal pitch (using sysex).
	# legal range for semi is +/- 24
	
	r     = ''
	blkn  = gs_strangemap()[chnum] + 0x10

	semi += 0x40			# add offset to process semi within sysex

	cksum = gs_chksum(addr,blkn,0x16,semi)
	r    += midibytes(0xf0,0x41,0x10,0x42,0x12,
			  addr,blkn,0x16,semi,  cksum,0xf7)
	return (r)
}

function gs_nrpnvibrato (chnum,ival){
	# returns a phrase to set vibrato for one part (midi channel with chnum) to
	# a value of ival.
	# legal range for ival is -64/+63

	r      = ''

	# set control change status and map channel numbers 1-16 to indices 0-15
	status = 0xb0 + (chnum-1)	

	# add offset for val=0
	ival  += 0x40

	# prepare midi output phrase
	r += midibytes(status,0x63,0x01,0x62,0x09,0x06,ival,0x26,0x00,0x65,0x7f,0x64,0x7f)
	           #  Control NRPN:               (N)RPN:             (N)RPN:
	           #  Change, vibrato depth,       data entry,         (N)RPN null(undefine)
	           #   Bn      MSB,val   LSB,val   MSB,val  LSB,val    MSB,val   LSB,val
	           #            99        98       6        38,ignore  101       100
	return (r)
}

function gs_nrpncombi (chnum, icutoff, ireso, iattack, idecay){
	#
	# returns a phrase to set *all at once* to individual values passed:  
	# filter cutoff-frequency, filter resonance, attack time and decay time 
	# for a single part (midi channel with chnum).
	# Legal range for i-parameters is -64/+63
	# Remarks: 
	# 1.) This function is optimised for the shortest 
	#   midi-phrase possible due to limited midi bandwidth.
	#   It relies on NRPN *running status* for NRPN-MSB.
	# 2.) Note: First part of midi-phrase set to 'r' is last to be sent.

	r      = ''

	# set control change status and map channel numbers 1-16 to indices 0-15
	status = 0xb0 + (chnum-1)	

	icutoff  += 0x40			# add offsets for val=0
	ireso    += 0x40
	iattack  += 0x40
	idecay   += 0x40

	# prepare midi output phrase
	r += midibytes(0x65,0x7f,0x64,0x7f)	# (N)RPN null(undefine)      # last sent!!
	r += midibytes(                   0x62,0x63,0x06,iattack, 0x62,0x64,0x06,idecay)
	r += midibytes(status, 0x63,0x01, 0x62,0x20,0x06,icutoff, 0x62,0x21,0x06,ireso)
	           #  Control NRPN:                (N)RPN:        NRPN:     (N)RPN:    ...
	           #  Change, cutoff frequ.        data entry,    resonance data entry ...
	           #   Bn      MSB,val    LSB,val  MSB,val        LSB,val   MSB,val    ...
	           #            99   1     98  32   6  icutoff     98  33   6   ireso  ...
	return (r)
}

function gs_nrpnctrl (from_ch, to_ch, nrpnmsb, nrpnlsb, ival){
	#
	# returns a phrase to set any GS-compatible NRPN-controller to a passed 
	# value ival. Subsequent midi channels can be specified by parameters
	# from_ch and to_ch. If only one channel is controlled, from_ch and
	# to_ch take the same value. Legal range for ival is -64/+63.
	# Remark: First part of midi-phrase set to 'r' is last to be sent.

	r      = ''

	# set control change status and map channel numbers 1-16 to indices 0-15

	ival  += 0x40				# add offset for val=0

	# prepare midi output phrase
	r += midibytes(0x65,0x7f,0x64,0x7f)	# (N)RPN null(undefine), last sent

	for (chnum = from_ch;  chnum <= to_ch;  chnum++){
	  status = 0xb0 + (chnum-1)	
	  r += midibytes(status, 0x63,nrpnmsb, 0x62,nrpnlsb, 0x06,ival)
	             # Control  |NRPN:       |             | (N)RPN:
	}            # Change Bn|MSB,val     | LSB,val     | data entry

	return (r)
}

function gs_nrpncutoff (chnum, icutoff){
	#
	# returns a phrase to set cutoff frequency to a passed value icutoff 
	# for a single part (midi channel with chnum).
	# Legal range for i-parameter is -64/+63
	# Remark: First part of midi-phrase set to 'r' is last to be sent.

	r      = ''

	# set control change status and map channel numbers 1-16 to indices 0-15
	status = 0xb0 + (chnum-1)	

	icutoff  += 0x40			# add offset for val=0

	# prepare midi output phrase
	r += midibytes(0x65,0x7f,0x64,0x7f)	# (N)RPN null(undefine)  # last sent!
	r += midibytes(status, 0x63,0x01, 0x62,0x20,0x06,icutoff)
	           #  Control NRPN:                (N)RPN:
	           #  Change, cutoff frequ.        data entry,    
	           #   Bn      MSB,val    LSB,val  MSB,val        
	           #            99   1     98  32   6  icutoff     
	return (r)
}

function gs_nrpnreso (chnum, ireso){
	#
	# returns a phrase to set filter resonance to a passed value ireso  
	# for a single part (midi channel with chnum).
	# Legal range for i-parameter is -64/+63
	# Remark: First part of midi-phrase set to 'r' is last to be sent.

	r      = ''

	# set control change status and map channel numbers 1-16 to indices 0-15
	status = 0xb0 + (chnum-1)	

	ireso    += 0x40			# add offset for val=0

	# prepare midi output phrase
	r += midibytes(0x65,0x7f,0x64,0x7f)	# (N)RPN null(undefine)  # last sent!
	r += midibytes(status, 0x63,0x01, 0x62,0x21,0x06,ireso)
	           #  Control  NRPN:                 (N)RPN:
	           #  Change,  filter resonance      data entry
	           #   Bn      MSB,val    LSB,val    MSB,val
	           #            99   1     98  33     6  ireso
	return (r)
}

function gs_nrpnattack (chnum, iattack){
	#
	# returns a phrase to set attack time to a passed value iattack  
	# for a single part (midi channel with chnum).
	# Legal range for i-parameter is -64/+63
	# Remarks: First part of midi-phrase set to 'r' is last to be sent.

	r      = ''

	# set control change status and map channel numbers 1-16 to indices 0-15
	status = 0xb0 + (chnum-1)	

	iattack  += 0x40			# add offset for val=0

	# prepare midi output phrase
	r += midibytes(0x65,0x7f,0x64,0x7f)	# (N)RPN null(undefine)  # last sent!!
	r += midibytes(status, 0x63,0x01 , 0x62,0x63, 0x06,iattack)
	           #  Control  NRPN:                 (N)RPN:
	           #  Change   attack MSB,LSB         data entry
	return (r)
}

function gs_nrpndecay (chnum, idecay){
	#
	# returns a phrase to set decay time to a passed value idecay  
	# for a single part (midi channel with chnum).
	# Legal range for i-parameter is -64/+63
	# Remark: First part of midi-phrase set to 'r' is last to be sent.

	r      = ''

	# set control change status and map channel numbers 1-16 to indices 0-15
	status = 0xb0 + (chnum-1)	

	idecay   += 0x40			# add offset for val=0

	# prepare midi output phrase
	r += midibytes(0x65,0x7f,0x64,0x7f)	# (N)RPN null(undefine)  # last sent!!
	r += midibytes(status, 0x63,0x01, 0x62,0x64,0x06,idecay)
	           #  Control NRPN:                (N)RPN:
	           #  Change  decay MSB ,LSB        data entry
	return (r)
}

function gs_nrpnrelease (chnum, irel){
	#
	# returns a phrase to set release time to a passed value irel
	# for a single part (midi channel with chnum).
	# Legal range for i-parameter is -64/+63
	# Remark: First part of midi-phrase set to 'r' is last to be sent.

	r      = ''

	# set control change status and map channel numbers 1-16 to indices 0-15
	status = 0xb0 + (chnum-1)	

	irel  += 0x40			# add offset for val=0

	# prepare midi output phrase
	r += midibytes(0x65,0x7f,0x64,0x7f)	# (N)RPN null(undefine)  # last sent!!
	r += midibytes(status, 0x63,0x01, 0x62,0x66,0x06,irel)
	           #  Control NRPN:                (N)RPN:
	           #  Change  release MSB,LSB       data entry
	return (r)
}

function rpn_finetune (chnum,dcent){
	# returns a phrase to retune one part (midi channel with chnum) to
	# +/-dcent cents relative to equal tempered intonation using RPNs.
	# (dcent is passed as a *float* value, range from -100.0 to + 99.99)

	r      = ''

	# set control change status and map channel numbers 1-16 to indices 0-15
	status = 0xb0 + (chnum-1)	

	# scale dcent to 100 cent / 14 bit resolution and clip LSB part
	# jj     = integer ((dcent / 100.0) * 8192.0)
	jj     = integer (dcent * 81.92)	
	jj0    = jj / 128

	# add offset for dcent=0
	cmsb   = jj0 + 0x40

	# compute lsb as difference between scaled input dcent and msb-value.
	# att: integer arithmetics ...: jj / 128 * 128 is not jj !
	clsb   = jj - (jj0 * 128)

	# adjust result for carry
	if (clsb < 0) {
	  clsb += 128
	  cmsb -= 1
	}	

	# diagnostics01
	# printf ("%f %s %d    %s %d\n",dcent,typeof(cmsb),cmsb,typeof(clsb),clsb)

	# prepare midi output phrase
	r += midibytes(status,0x65,0x00,0x64,0x01,0x06,cmsb,0x26,clsb,0x65,0x7f,0x64,0x7f)
	           #  Control RPN:                RPN:                RPN:
	           #  Change, master fine tune,   data entry,         RPN null (undefine)
	           #   Bn      MSB,val   LSB,val   MSB,val   LSB,val   MSB,val   LSB,val
	           #           101       100       6         38        101       100
	return (r)
}

function rpn_coarsetune (chnum,semi){
	# returns a phrase to retune one part (midi channel with chnum) to
	# +/-semi semitones relative to normal pitch.
	# legal range for semi is +/- 24
	# Remark: Result is *not* displayed in the SC-880 part's Pitch display page.
 
	r      = ''

	# set control change status and map channel numbers 1-16 to indices 0-15
	status = 0xb0 + (chnum-1)	

	# add offset for semi=0
	semi  += 0x40

	# prepare midi output phrase
	r += midibytes(status,0x65,0x00,0x64,0x02,0x06,semi,0x26,0x00,0x65,0x7f,0x64,0x7f)
	           #  Control RPN:                RPN:                RPN:
	           #  Change, master coarse tune, data entry,         RPN null (undefine)
	           #   Bn      MSB,val   LSB,val   MSB,val  LSB,val    MSB,val   LSB,val
	           #           101       100       6        38,ignore  101       100

	return (r)
}

function rpn_bendrange (chnum,semi){
	# returns a phrase to set one part's (a midi channel with chnum)
	# pitchbend-sensitivity to +/-semi semitones. 
	# Legal range for semi is 0 to +24.

	r      = ''

	# set control change status and map channel numbers 1-16 to indices 0-15
	status = 0xb0 + (chnum-1)	

	# prepare midi output phrase
	r += midibytes(status,0x65,0x00,0x64,0x00,0x06,semi,0x26,0x00,0x65,0x7f,0x64,0x7f)
	           #  Control RPN:                RPN:                RPN:
	           #  Change, bend-sensitivity,   data entry,         RPN null (undefine)
	           #   Bn      MSB,val   LSB,val   MSB,val  LSB,val    MSB,val   LSB,val
	           #           101       100       6        38,ignore  101       100
	return (r)
}

function gs_mastertune (shift){
	# returns a phrase to retune all parts of a GS-instrument to
	# +/-shift cents relative to normal pitch of A=440 Hz.
	# Legal range for shift is +/- 100.0 (float cents).

	# print ("gs_mastertune shift:",shift)			# diagnostic

	nib = []						# holds four nibble bytes
	r   = ''						# empty return phrase

	ti  = bd_round (1024.0 + shift*10.0)			# find nearest integer
	# print(ti)						# diagnostic
	for (j=0; j<4; j++){
	  nib[j] = ti % 16					# modulo division,
	  ti    /= 16						# integer arithmetics
	  # print ( "nib [",j,"]=", nib[j], "ti=",ti)		# diagnostic
	}

	# prepare midi output phrase
	cksum = gs_chksum(0x40,0x00,0x00,nib[3],nib[2],nib[1],nib[0])
	r    += midibytes(0xf0,0x41,0x10,0x42,0x12,
			  0x40,0x00,0x00,nib[3],nib[2],nib[1],nib[0],  cksum,0xf7)

	return (r)
}

function gs_toneselect(chnum, bank, prog, addr, toneset) {
	#            midichn| CC00|  PC | 0x40 or 0x50 == Midiinput A or B 
	# generates a phrase,which contains a sysex-message to select an
	# instrument sound (tone). The message is a combination of a 
	# CC00 (bank select) and a program change (PC) message.
	# Midi channel-number is chnum. The toneset parameter identifies
	# the SC-Pro/SC880-Series set of sounds from 1 to 3. 
	# toneset=0 leaves the actual toneset unchanged.
	# Note: First part of midi-phrase set to 'r' is last to be sent.
	
	r       = ''
	blkn1   = gs_strangemap()[chnum] + 0x10
	blkn4   = gs_strangemap()[chnum] + 0x40

	prog   -= 1

	cksum1  = gs_chksum(addr,blkn1,0x00,bank,prog)
	cksum4  = gs_chksum(addr,blkn4,0x01,toneset)

	r      += midibytes(0xf0,0x41,0x10,0x42,0x12,
		 	    addr,blkn1,0x00,bank,prog,  cksum1,0xf7)   # last sent!!
	r      += midibytes(0xf0,0x41,0x10,0x42,0x12,
			    addr,blkn4,0x01,toneset,    cksum4,0xf7)
	return (r)
}

function gs_partmode(chnum, mode, addr) {
	#           midichn| 0-2 |0x40 or 0x50 == Midiinput A or B 
	# returns a phrase to make one part (midi channel with chnum) 
	# a normal part (mode 0), a rhythm module 1 (mode 1) 
	# or a rhythm module 2 (mode 2) using sysex.
	# legal range for mode is 0 to 2.
	
	r     = ''
	blkn  = gs_strangemap()[chnum] + 0x10

	cksum = gs_chksum(addr,blkn,0x15,mode)
	r    += midibytes(0xf0,0x41,0x10,0x42,0x12,
			  addr,blkn,0x15,mode,  cksum,0xf7)
	return (r)
}

function gs_mfxtype(val1,val2) {
	# returns a phrase to select a multi-effect type 
	# (refer to Roland's MIDI-implementation)
	# Examples: Through 	val1=0x00, val2=0x00
	#           Humanizer	val1=0x01, val2=0x03
	#           Overdrive	val1=0x01, val2=0x10
	#           Distortion	val1=0x01, val2=0x11

	r     = ''

	cksum = gs_chksum(0x40,0x03,0x00,val1,val2)
	r    += midibytes(0xf0,0x41,0x10,0x42,0x12,
			  0x40,0x03,0x00,val1,val2,  cksum,0xf7)
	return (r)
}

function gs_mfxpart(chnum, mode, addr) {
	#     1-16 midichn| 0/1 |0x40 or 0x50 == Midiinput A or B 
	# returns a phrase to activate multi effects for 
	# one part (midi channel with chnum) using sysex.
	# legal choices for mode are 0x00 (bypass) or 0x01 (mfx on)
	
	r     = ''
	blkn  = gs_strangemap()[chnum] + 0x40

	cksum = gs_chksum(addr,blkn,0x22,mode)
	r    += midibytes(0xf0,0x41,0x10,0x42,0x12,
			  addr,blkn,0x22,mode,  cksum,0xf7)
	return (r)
}

function gs_mfxpara(paranum, val) {
	#             1-20 | range for val depends on effect
	# returns a phrase to adjust a multi-effect parameter
	# (refer to Roland's SC-880 MIDI-implementation)
	# Examples given for Humanizer effect:
	#   paranum = 1,  val = 0-127 Drive intensity
	#   paranum = 2,  val = 0-1   Drive off/on
	#   paranum = 3,  val = 0-4   Vowel a,i,u,e,o
	#   paranum = 4,  val = 0-127 Accel, refer to p.164 for
	#             specific parameter value conversion table
	#   ...

	r     = ''
	addr  = paranum + 2

	cksum = gs_chksum(0x40,0x03,addr,val)
	r    += midibytes(0xf0,0x41,0x10,0x42,0x12,
			  0x40,0x03,addr,val,  cksum,0xf7)
	return (r)
}

#----------- bd_round() is called by gs_mastertune() -----------
#	(I ususally store this in another library. I hope, that 
#	 I didn't forget anything to put all of this to use.)
#	  

function bd_round (r) {
	# This function returns the nearest integer  
	# to a float-value r passed.

	if (r>=0) { i = integer(r+0.5) }
	else      { i = integer(r-0.5) }

	return (i)
}

# -^-^-^---- End  of gs_utils.k library ----^-^-^-
