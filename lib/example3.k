# This is a simple example of using the kvalbutton widget
# to produce a pull-down menu of values.  The label on the
# button indicates the current choice.

class wexample3 {

method init {

        $.w = new window()
        $.inherit($.w)
        $.text = new ktext("Example3")

        # The array given as the first argument
        # is a list of the possible values.  The
        # index values (0,1,2...) determine the
        # order in the list, and these are also
        # the values that are passed to the method
        # (in this case, butt1changed) that
        # is invoked when the user selects a
        # value in the list.

        arr = [0="High",1="Medium",2="Low"]
        $.butt1 = new kvalbutton(arr, $, "butt1changed")

        $.addchild($.text)
        $.addchild($.butt1)
}

method resize(sz) {
        if ( nargs() > 0 )
                $.w.resize(sz)

        # Split the area in half, vertically - the text
        # is shown in the top, the button in the bottom.

        ymid = ($.ymax()+$.ymin())/2
        $.text.resize(xy($.xmin(),$.ymin(),$.xmax(),ymid))
        $.butt1.resize(xy($.xmin(),ymid,$.xmax(),$.ymax()))
}

method redraw {
        methodbroadcast()
}

method get {
        # If you want to get the current value of
        # the button at any time, you can just invoke
        # the get method of kvalbutton.
        return( $.butt1.get() )
}

method butt1changed(v) {
        # This is just an example, we just print
        # the value when the user selects something.
        print("v=",v)
}
}
