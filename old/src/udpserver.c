/*
   The following program is an example of a UDP server that listens
   for packets on the UDP ECHO port and sends them back to the port
   that transmitted them.
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
       short s;
       int n, len;
       char buf[256];
       static BOOL on=TRUE;
       struct sockaddr_in sin;
	WSADATA wsaData;
	int err;

       /*
        *  Create an IP-family socket on which to
        *  listen for packets
        */

fprintf(stderr,"Hi from main\n");

	err = WSAStartup(0x0101, &wsaData);
	if ( err ) {
               socket_perror("udpechoserver: startup");
               exit(0x10000000);
	}

       s = socket(PF_INET, SOCK_DGRAM, 0);
       if (s < 0) {
               socket_perror("udpechoserver: socket");
               exit(0x10000000);
       }

       /*
        *  Get the UDP port number of the "echo" server.
        *
        *  This is commented out, but left as an
        *  example.  We hardwire port 500 so we
        *  don't have to stop the MultiNet echo
        *  server before running this.
        */

       /*
        *  Set the "REUSEADDR" option on this socket.  This
        *  will allow us to bind() to it EVEN if there
        *  already connections in progress on this port
        *  number.  Otherwise, we would get an "Address
        *  already in use" error.
        */

/*
       if (setsockopt(s, SOL_SOCKET, SO_REUSEADDR,
                      (const char *)(&on), sizeof(on)) < 0) {
               socket_perror("udpechoserver: setsockopt");
               exit(0x10000000);
       }
*/

       /*
        *  Create a "sockaddr_in" structure which describes
        *  the port we want to listen to.  Address INADDR_ANY
        *  means we will accept connections to any of our
        *  local IP addresses.
        */

       sin.sin_family = AF_INET;
       sin.sin_addr.s_addr = INADDR_ANY;
       sin.sin_port = htons(7);
fprintf(stderr,"port=%d\n",sin.sin_port);

       /*
        *  Bind to that address...
        */

       if (bind(s, (LPSOCKADDR)&sin, sizeof (sin)) < 0) {
               socket_perror("udpechoserver: bind");
               exit(0x10000000);
       }

       /*
        *  Now go into a loop, reading data from the network
        *  and sending it right back...
        */

fprintf(stderr,"calling recvfrom\n");
       while ((n = recvfrom(s, buf, sizeof(buf),
                            0, (LPSOCKADDR)&sin, &len)) > 0) {
fprintf(stderr,"GOT SOMETHING!  sending back\n");
           sendto(s, buf, n, 0, (LPSOCKADDR)&sin, len);
fprintf(stderr,"after sending back\n");
       }

       if (n < 0) {
           socket_perror("udpechoserver: recvfrom");
           exit(0x10000004);
       }

       /*
        *  Now close down the connection...
        */

       closesocket(s);

       /*
        *  Exit successfully.
        */

fprintf(stderr,"BYE from main\n");
       exit(0);
	return(0);
   }
 


