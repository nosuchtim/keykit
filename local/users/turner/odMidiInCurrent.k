# although this inherits from oInputDevice and oOutputDevice,
# the oInputDevice aspect is just for convenience.  This is
# considered to be an output-device only (the input is already
# "taken").

class odMidiInCurrent {
    method init {
        $.od = new oOutputDevice()
        $.inherit($.od)
        $.id = new oInputDevice()
        $.inherit($.id)
        $.odMidiIn = new odMidiIn()
        # send $.odMidiIn to $(as $.id)
        $.odMidiIn.sendTo($)
        $.t = task $.doSend()
    }
    method delete {
        deleteobject($.odMidiIn)
        kill($.t)
    }
    method deleteSelf {
        deleteobject($)
    }
    # when id sends anything, compare Current to oldCurrent and if
    # they differ, send Current out "inheritance-parent" $.od
    method doSend {
        # "initialize" target
        $.send(oldCurrent = ''+Current)
        inFifo = $.getFifo()
        
        # note: it is NOT guaranteed that the same
        # value will never come down the pipe twice
        # in a row (this is already ensured by the
        # connection/disconnection semantics; we 
        # increase the "risk factor" here because
        # we have two non-atomic references to Current.

        while (get(inFifo) != Eof) 
            if (oldCurrent != Current) 
                $.send(oldCurrent = ''+Current)            
    }
    
    # override sendTo to "prime the pump"
    method sendTo(idNew) {
        $.od.sendTo(idNew)
        $.send(Current)
    }
}

