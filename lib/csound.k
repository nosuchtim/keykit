#
# A simple example (and quite non-general) example of driving
# Csound from KeyKit in real time in Linux. It is hardwired to
# drive a particular instrument I was working with.
# 
# The idea behind this was to eventually use KeyKit as a a real-time
# algorithmic front-end to Csound (intelligent instrument), driven
# by MIDI input. This current example, which simply triggers the 
# instrument based on received MIDI notes,  by itself of course is pointless,
# since in this case we could more simply make the instrument MIDI-driven
# and not use KeyKit at all.
#
# Usage:
# 
# startcs()
# runtask(play_wgpluck)
# .. now play for a while ...
# endcs()
#
# Caveat: I have not re-loaded this file after adding this documentation,
# so beware of of typos, etc...
#
# Larry Troxler 
# November, 1999
# lt@westnet.com
#


#
#  Build the Csound command line
#
Cs = []
Cs["bufsize"]=128
# Set "rt" to 1 to grab POSIX rt scheduling
Cs["rt"] = 0
function CsBuildCmd()
{
  Cmd = "csound -o devaudio -dm0"

  # this bit is specific to the unnoficial Linux version :
  if( Cs["rt"] )
    Cmd += " --sched "

  Cmd += " -B " + string(Cs["bufsize"]) + " -b " + string(Cs["bufsize"])
  Cmd += " -L /proc/self/fd/0 test.orc test.sco"

}

#
# Parameters for Wgpluck instrument
#
Wgp = []
Wgp["Amp"] = 0.3
Wgp["Pick"] = 0.35
Wgp["Ipluck"] = 0.12
Wgp["Idamp"] = 5.0
Wgp["Ifilt"] = 20.0
Wgp["ReleaseTime"] = 0.05

#
# Start Csound
#
function startcs() {
  CsBuildCmd()  
  Csout =  open(Cmd, "w", "pipe" )
  return( Csout )
}

#
# Terminate csound - call this when done with real-time session
#
function endcs() {
  put(Csout,"e0 0 0\n")
  millisleep(500)
  close(Csout)
}

#
# Send a Csound Line-event to WgPluck instrument based on contents
# of supplied MIDI message
#
function csout(m) {
  if( m.type == NOTEON ) {
    put(Csout,sprintf("i %d.%d 0 -1 %d %f %f %f %f %f\n", m.chan,
	m.pitch+100, m.pitch, Wgp["Amp"], Wgp["Pick"], Wgp["Ipluck"],
	Wgp["Idamp"], Wgp["Ifilt"]))
  } else if( m.type == NOTEOFF ) {
     put(Csout,sprintf("i %d.%d 0 %f %d %f %f %f %f %f\n", m.chan,
	m.pitch+100,Wgp["ReleaseTime"],  m.pitch, Wgp["Amp"], Wgp["Pick"],
	Wgp["Ipluck"], Wgp["Idamp"], Wgp["Ifilt"]))
  }
  flush(Csout)
}


#
# Drive the WgPluck instrument through real-time MIDI input
#
function play_wgpluck() {

Midiin[$] = f = open()
onexit(closemidi,$)

while ( (m=get(f)) != Eof ) {
          csout(m)
}
}


#
# General-purpose task launcher, abortable by keypress
#
function runtask(tsk) {
   t = task tsk()
   Root.waitforconsolekey()
   kill(t)
}


