function pagecol_write(fname)
{
	if ( nargs() < 1 ) {
		fname = browsefiles("Key Page (*.kp)","*.kp",0)
		if ( fname == "" ) {
			print("No file named, no page written.")
			return()
		}
	}

	tmp = Arraysort
	Arraysort = 1	

	num = 0
	for (o in Pages)
	{
		print("page "+string(++num)+" is: "+Pages[o])
		if (num > 1)
			page_write(fname+string(num),o,Pages[o])
		else
			page_write(fname,o,Pages[o])
	}

	for (n = 1; n<num; n++)
	{
		if (n > 1)
			f = open(fname+string(n), "a")
		else
			f = open(fname, "a")
		put(f,"\n")
		put(f,"function keypage_postcreate()\n{\n")
		put(f,"\tpage_readnew("+"\""+pathescape(fname)+string(n+1)+"\""+")\n}\n")
		close(f)
	}

	Arraysort = tmp
}

