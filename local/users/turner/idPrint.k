# example class -- prints its input

class idPrint {
    method init {
        $.id = new oInputDevice()
        $.inherit($.id)
        $.t = task $.doInput($.getFifo())
        $.label = ""
    }
    method delete {
        kill($.t)
    }
    method deleteSelf {
        deleteobject($)    
    }
    method doInput(fIn) {
        while ((xIn = get(fIn)) != Eof) {
            print($.label, xIn)
        }
    }
    method setLabel(sLabel) {
        $.label = sLabel
    }
    method getLabel {
        return($.label)
    }
}
