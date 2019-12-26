class khold 
{
	method init(draw, obj, close, open, ...) 
	{
		$.w = new window()
		$.inherit($.w)
		$.style(BUTTON)

		$.closed = 0

		$.drawfunc = draw
		$.obj = obj

		$.close = close
		$.open = open

		$.args = argvlist(...)
		
		print("typeof(draw) = " + typeof(draw))
	}

	method mouseup(m) 
	{
		if ($.closed) 
		{
			$.closed = 0
			$.w.style(BUTTON)
			$.redraw()
			$.obj.($.open)(varg($.args))
		}
	}

	method mousedown(m) 
	{
		if (! $.closed) 
		{
			$.closed = 1
			$.w.style(PRESSEDBUTTON)
			$.redraw()
			$.obj.($.close)(varg($.args))
		}
	}

	method mousedrag (m) { }

	method setdrawfunc(f) 
	{ 
		if (typeof(f) != "string")
		{
			printf("Hey, drawfunc isn't a string in a khold?")
		}
		else
		{
			$.drawfunc = f
		}
	}

	method redraw 
	{
		df = $.drawfunc
		print("typeof($.drawfunc) = " + typeof($.drawfunc))
		if ($.drawfunc != 0)
		{
			if ($.closed)
			{
				$.w.style(PRESSEDBUTTON)
				$.w.redraw()
				efunction($.drawfunc)($,CLEAR)
			}
			else
			{
				printf("one\n")
				$.w.style(BUTTON)
				printf("two\n")
				$.w.redraw()
				printf("three\n")
				printf(typeof(efunction($.drawfunc)) + "\n");
				printf("three b\n");
				ff = efunction($.drawfunc)
				ff($)
				printf("three c\n")
				printf("four\n")
			}
		}
		else
		{
			$.w.redraw()
		}
	}
}

class wtest
{
	method init
	{
		$.w = new window()
		$.inherit($.w)
		$.testhold = new khold("test", $, "testclose", "testopen")
		# $.testhold = new kbutton("test", $, "testclick")
		$.addchild($.testhold)
	}

	method redraw
	{
		$.w.redraw()
		methodbroadcast()
	}

	method resize(sz)
	{
		$.w.resize(sz)
		methodbroadcast(sz)
	}

	method testclose
	{
		print("close")
	}

	method testopen
	{
		print("open")
	}

	method testclick
	{
		print("click")
	}
}

sweeptool(wtest)
