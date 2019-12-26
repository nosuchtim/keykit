/*
   The following is an example of a UDP client that sends a packet
   to the UDP ECHO port on the local machine and prints what comes
   back. Note that it uses SYS$QIO to read the packet so that it can
   timeout and retransmit the packet.
*/


#include <windows.h>
#include <windowsx.h>
#include <winsock.h>
#include <stdlib.h>
#include <stdio.h>

void socket_perror(char* s)
{
	int e = WSAGetLastError();
	fprintf(stderr,"SOCKET_PERROR: err=%d s=%s\n",e,s);
}

   main()
   {
       int s, n;
       char buf[256];
       struct sockaddr_in sin;
       struct hostent *hp;
	WSADATA wsaData;
	int err;

fprintf(stderr,"ONE\n");
	err = WSAStartup(0x0101, &wsaData);
	if ( err ) {
               socket_perror("udpechoserver: startup");
               exit(0x10000000);
	}

       /*
        *  Get the IP address of the host named "LOCALHOST".
        *  This is the loopback address for ourselves
        */

fprintf(stderr,"TWO\n");
       hp = gethostbyname("127.0.0.1");
fprintf(stderr,"threE\n");
       if (hp == NULL) {
           fprintf(stderr, "udpechoclient: localhost unknown\n");
           exit(0x10000000);
       }

       /*
        *  Create an IP-family socket on which to
        *  make the connection
        */

fprintf(stderr,"four\n");
       s = socket(hp->h_addrtype, SOCK_DGRAM, 0);
fprintf(stderr,"socket s=%d\n",s);
       if (s < 0) {
               socket_perror("udpechoclient: socket");
               exit(0x10000000);
       }

       sin.sin_family = hp->h_addrtype;

	memcpy((LPSOCKADDR) &sin.sin_addr, hp->h_addr, hp->h_length);

       sin.sin_port = htons(7);

       /*
        *  Do a pseudo-connect to that address.  This tells
        *  the kernel that anything written on this socket
        *  gets sent to this destination.  It also binds us
        *  to a local port number (random, but that is ok).
        */

fprintf(stderr,"connect? s=%d\n",s);
       n = connect(s, (LPSOCKADDR)&sin, sizeof(sin));
fprintf(stderr,"post connect? n=%d\n",n);
       if (n < 0) {
           socket_perror("udpechoclient: connect");
           exit(0x10000004);
       }

   send(s, buf, strlen(buf),0);
       exit(0);
	return(0);
   }
