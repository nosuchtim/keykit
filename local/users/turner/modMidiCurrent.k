# module which converts an incoming "midi" stream to an
# outgoing "current" stream.

# this class is young -- it needs some work before it will work
# as might be expected.  The most obvious and functionally important
# thing is that it should handle all data on the incoming fifo until
# the fifo is empty before producing an output.  a 1:1 mapping (or close
# approximation thereof) of inputs to outputs defeats the whole purpose!

# also I assume it could be made more efficient with the use of cut.

class modMidiCurrent {
    method init {
        $.mod = new oModule()
        $.inherit($.mod)
        $.midiIn = new oInputDevice()
        $.currentOut = new oOutputDevice()
        $.addInput("midiIn", $.midiIn)
        $.addOutput("currentOut", $.currentOut)
        $.t = task $.doProcess()
    }
    method delete {
        kill($.t)
    }
    method doProcess() {
        pCurrentOpen = ''
        pCurrentClosed = ''
        
        fIn = $.midiIn.getFifo()
        odOut = $.currentOut
        
        while ((pIn = get(fIn)) != Eof) {
            # for some reason Now is lagging one behind each input!?
            # to correct for this I am adding one... ?

            now = Now + 1
            
            if (pIn.type == NOTE) { 
                if ((pIn.time <= now) && ((pIn.time + pIn.dur) > now))
                    pCurrentClosed |= pIn            
            } else if (pIn.type == NOTEON) {
                if (pIn.time <= now) {    
                    pInFlat = pIn
                    pCurrentOpen |= pInFlat
                }
            } else if (pIn.type == NOTEOFF) {          
                for (p in pCurrentOpen)
                    if (p.pitch == pIn.pitch) {
                        pCurrentOpen -= p
                        break
                    }
            }

            # look through pCurrentClosed for expired entries
            pDelete = ''
            for (p in pCurrentClosed) 
                if ((p.time + p.dur) < now) 
                    pDelete |= p
            pCurrentClosed -= pDelete;
            
            pResult = pCurrentClosed | pCurrentOpen
            pResult.duration = 0
            pResult.length = 0
            odOut.send(pResult)
        }
    }
}
