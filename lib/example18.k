# This is an example waits until you press a console key
# (during which time you can play something on MIDI input),
# and then writes everything that appeared on MIDI input into
# the named file, with each channel as a separate track.

function example18(fname) {
    if ( nargs() < 1 )
        fname = "example18.mid"
    tm0 = Now
    print("Play on MIDI input, then press a console key...")
    Root.waitforconsolekey()
    print("Writing MIDI file: ",fname)
    ph = strip(cut(Recorded,CUT_TIME,tm0,Now))
    arr = []
    trknum = 0
    for ( ch=1; ch<=16; ch++ ) {
        p = ph{??.type != SYSEX && ??.type != MIDIBYTES && ??.chan == ch}
        if ( p != '' ) {
            arr[trknum++] = p
        }
    }
    midifile(arr,fname)
}

