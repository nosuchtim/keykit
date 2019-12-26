# fixme: arrange for singular global midi in with demux

# odMidiIn is an input devce representing KeyKit's cannonical 
# midi input.  Each midi action will be output.

class odMidiIn {
    method init {
        $.od = new oOutputDevice()
        $.inherit($.od)
        Midiin[$] = $.fInput = open()
        $.t = task $.doDupMidiIn()
    }
    method delete {
        # do something like closemidi
	if ( $ in Midiin ) 
            delete Midiin[$]

        close($.fInput)
        kill($.t)
    }
    method deleteSelf {
        deleteobject($)
    }
    method doDupMidiIn {
        fIn = $.fInput
        while ((pIn = get(fIn)) != Eof) 
            $.send(pIn)
    }    
}