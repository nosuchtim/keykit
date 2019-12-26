# base class for a "module" with an arbitrary number of oInputDevices and
# oOutputDevices which are exposed via an API which allows the inputs and
# outputs in the module to be named (or not).

# fixme: probably the "names-list" is unneccesary.

class oModule {
    method init {
        $.aInput = []
        $.aInputNames = []
        $.aOutput = []
        $.aOutputNames = []
    }
    method delete {
        # auto-delete ins and outs
        for (x in $.aInput)
            deleteobject($.aInput[x])
        for (x in $.aOutput)
            deleteobject($.aOutput[x])
    }
    
    method getInput(sName) {
        if (sName in $.aInputNames)
            return($.aInput[sName])
        else
            return(-1)
    }
    method addInput(sName, ic) {
        if (sName in $.aInputNames)
            error("(oModule).addInput: input name conflict!")
        $.aInput[sName] = ic
        $.aInputNames[sName] = sName        
    }        
    method removeInput(sName) {
        if (sName in $.aInputNames)
            deleteobject($.aInput[sName])
        delete $.aInput[sName]
        delete $.aInputNames[sName]
    }
    method replaceInput(sName, ic) {
        removeInput(sName)
        addInput(sName, ic)
    }
    method getInputNames {
        # copy aInputNames to result
        return(arraycopy($.aInputNames))
    }
    
    method getOutput(sName) {
        if (sName in $.aOutputNames)
            return($.aOutput[sName])
        else
            return(-1)
    }
    method addOutput(sName, oc) {
        if (sName in $.aOutputNames)
            error("(oModule).addOutput: output name conflict!")
        $.aOutput[sName] = oc
        $.aOutputNames[sName] = sName
    }
    method removeOutput(sName) {
        if (sName in $.aOutputNames)
            deleteobject($.aOutput[sName])
        delete $.aOutput[sName]
        delete $.aOutputNames[sName]
    }
    method replaceOutput(sName, oc) {
        removeOutput(sName)
        addOutput(sName, oc)
    }
    method getOutputNames {
        return(arraycopy($.aOutputNames))
    }
}