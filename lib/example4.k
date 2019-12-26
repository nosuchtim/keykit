# The goal of this code is to play things
# in response to seeing start/stop/continue messages.
#
# An example of using it would be:
#
#      example_4('c e g','f a c','g b d')
#
# This would play a C, F, and G chords ever time
# a MIDI start, stop, and continue message was received.
#
# This effect would continue until a console key
# was pressed.

function example_4(p1,p2,p3) {
        # spawn the task that will monitor midi input
        t = task lookforstartstopcont(p1,p2,p3)
        Root.waitforconsolekey()
        kill(t)
}

function lookforstartstopcont(p1,p2,p3) {
        
        # Arrange for fifo f to get a copy of Midi input,
        # and make sure it's cleaned up when this task 
        # gets killed.

        Midiin[$] = f = open()
        onexit(closemidi,$)

        while ( (m=get(f)) != Eof ) {
                m.time = 0
                if ( m == 'xfa' ) {
                        realtime(p1)
                } else if ( m == 'xfb' ) {
                        realtime(p2)
                } else if ( m == 'xfc' ) {
                        realtime(p3)
                }
        }
}
