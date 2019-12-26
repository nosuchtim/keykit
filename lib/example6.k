# The goal of this code is to take a phrase
# and play it transposed in response to incoming notes.
# An example of using it would be
#
#      example_6('c e g')
#
# After doing this, every time you pressed a key,
# a major chord would be played, transposed to the
# key you pressed.
# 
# The effect will continue until a console key
# was pressed.

function example_6(p) {

        # Don't echo MIDI input
        oldMerge = Merge
        Merge = 0

        # spawn the task that will monitor midi input
        t = task lookandtranspose(p)
        Root.waitforconsolekey()

        kill(t)

        Merge= oldMerge
}

function lookandtranspose(p) {
        
        # Arrange for fifo f to get a copy of Midi input,
        # and make sure it's cleaned up when this task 
        # gets killed.

        Midiin[$] = f = open()
        onexit(closemidi,$)

        low = lowest(p)
        while ( (m=get(f)) != Eof ) {
                if ( m.type != NOTEON )
                        continue
                dp = m.pitch - low
                newp = p
                newp.pitch += dp
                realtime(newp)
        }
}
