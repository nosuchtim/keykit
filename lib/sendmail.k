function sendmail(mailto,subject,msg) {
	if ( SmtpServer == "" ) {
		print("No SmtpServer defined, cannot send mail!")
		return()
	}
	if ( nargs() < 3 ) {
		print("Usage: sendmail(mailto,subject,msg)")
		return()
	}
	ports = open("25@"+SmtpServer,"rw","tcpip_connect")
	r = ports["r"]
	w = ports["w"]
	fifoctl(r,"type","l")
	fifoctl(w,"type","l")

	CRLF = "\r\n"

	a=get(r)
	# This line should be something like "220 {hostname} ESMTP"

	from = "key@"+KeyKitHost
	put(w,"MAIL FROM:"+from+CRLF);

	a=get(r)
	if ( mailresponse(a) != 250 ) {
		print("Unexpected response to FROM: from SMTP server: "+a+"\n")
		return()
	}

	put(w,"RCPT TO:"+mailto+CRLF)

	a=get(r)
	if ( mailresponse(a) != 250 ) {
		print("Unexpected response to RCPT: from SMTP server: "+a+"\n")
		return()
	}

	put(w,"DATA"+CRLF)

	a=get(r)
	if ( mailresponse(a) != 354 ) {
		print("Unexpected response to DATA from SMTP server: "+a+"\n")
		return()
	}

	# For some reason, my mail reader on Linux needs a date
	# after the name on the from line.  That didn't used to be necessary.
	date = "Sun Jan 12 19:33:35 2003"
	put(w,"From "+from+" "+date+CRLF)
	put(w,"From: "+from+CRLF)
	put(w,"To: "+mailto+CRLF)
	put(w,"Subject: "+subject+CRLF)
	put(w,CRLF)
	put(w,msg)
	put(w,CRLF+"."+CRLF)

	a=get(r)
	if ( mailresponse(a) != 250 ) {
		print("Unexpected response to msg from SMTP server: "+a+"\n")
		return()
	}

	close(r)
	close(w)
	print("Mail successfully sent to "+mailto)
}

function mailresponse(line) {
	w = split(line)
	if ( sizeof(w) < 1 )
		return(-1)
	else
		return(integer(w[0]))
}
