# OK, this whole input / output thing gets terribly dyslexic, so here 
# is how I keep it straight: output devices "spew" data (any type)
# out towards the programmable universe.  Thus, in some sense,
# a physical "input" (like a keyboard or midi input) device would
# have a corresponding oOutputDevice in this framework.

# it is assumed that all official output devices will descend from this.

class oOutputDevice {
    method init {
        $.fIn = -1
    }

    method sendTo(idNew) {
        if (typeof(idNew) == "object")
            fNew = idNew.getFifo()
        else
            fNew = -1            
        $.fIn = fNew
    }

    method send(xData) {
        put($.fIn, xData)
    }

    method deleteSelf {
        deleteobject($)
    }
}