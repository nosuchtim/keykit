# OK, this whole input / output thing gets terribly dyslexic, so here 
# is how I keep it straight: input devices "suck" data (any type)
# in from the programmable universe.  Thus, in some sense,
# a physical "output device" (like a monitor or midi output) might
# have a corresponding oInputDevice in this framework.  

# interface requirement of all InputDevices: must return fifo
# to which input can be sent in getFifo; "input" put into the
# fifo should then do something.  

# The reason the input device gets to own the fifo is simple: the
# input-device-descendant is the likely candidate to block on the
# fifo.

class oInputDevice {
    method init {
        $.fIn = open()
    }
    method getFifo {
        return($.fIn)
    }
    method delete {
        close($.fIn)
    }
    method deleteSelf {
        deleteobject($)
    }
}

