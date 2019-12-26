# this input-device represents the KeyKit cannonical midi output.
# data sent to its fifo is scheduled for immediate realtime output

class idMidiOut {
    method init {
        $.id = new oInputDevice()
        $.inherit($.id)
        $.t = task $.doInput()
    }
    method delete {
        kill($.t)
    }
    method deleteSelf {
        deleteobject($)
    }
    method doInput {
        fIn = $.getFifo()
        while ((pIn = get(fIn)) != Eof)
            realtime(pIn, 0)
    }
}