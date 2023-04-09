/*
 *    Copyright 1996 AT&T Corp.  All rights reserved.
 */

#include <termios.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <unistd.h>

#include "key.h"

/* hello - This function does anything that needs to be done when */
/*         keykit first starts up. */

void
mdep_hello(int argc,char **argv)
{
#ifdef TTYSTUFF
	struct termio t;

	dummyusage(argc);
	dummyusage(argv);

	if ( ioctl(0,TCGETA,&t) == 0 ) {
		Killchar = t.c_cc[VKILL];
		Erasechar = t.c_cc[VERASE];
		Intrchar = t.c_cc[VINTR];
	}
	else {
		Intrchar = 0x7f;
	}

	Isatty = isatty(Consolefd);
	if ( Isatty )
		setbuf(stdout,(char*)NULL);

	if ( Isatty )
		ttysetraw();
#endif

}

/* bye -   This function does any cleanup, before final exit. */
void
mdep_bye(void)
{
#ifdef TRYWITHOUT
	if ( Initdone ) {
		int fd = 0;
		if ( ioctl(fd,TCSETA,&Initterm) < 0 ) {
			sprintf(Msg1,"Error in ioctl(%d,TCSETA) in bye()?  errno=%d\n",fd,errno);
			eprint(Msg1);
		}
	}
#endif
}

/* filetime - Return the modification time of a file in seconds. */
long
mdep_filetime(char *fn)
{
        struct stat s;
 
        if ( stat(fn,&s) == -1 )
                return(-1);
        return(s.st_mtime);
}

/* Return current time in seconds (consistent with filetime()) */
long
mdep_currtime(void)
{
        return ( time((long *)0) );
}

/* coreleft - Return memory available */
long
mdep_coreleft(void)
{
	struct rlimit rl;
	if ( getrlimit(RLIMIT_DATA,&rl) < 0 || (long)(rl.rlim_cur) < 0 )
		return(MAXLONG);
	return (long)rl.rlim_cur;
}

/* fisatty - Return non-zero if the given file is attached to a TTY */
/*           (ie. not a normal file) */
int
mdep_fisatty(FILE *f)
{
	return isatty(fileno(f));
}

int
mdep_changedir(char *d)
{
	return chdir(d);
}

char *
mdep_currentdir(char *buff, int leng)
{
	return getcwd(buff,leng);
}

int
mdep_lsdir(char *dir, char *exp, void (*callback)(char*,int))
{
	char buff[BUFSIZ];
	FILE *f;
	struct stat sb;
	int dleng = strlen(dir);
	char *sep = "/";

	/* If dir ends in "/", don't add an additional "/" */
	if ( dleng > 0 && dir[dleng-1] == '/' )
		sep = "";

	sprintf(buff,"ls -d %s%s%s 2>/dev/null",dir,sep,exp);
	f = popen(buff,"r");
	if ( f == NULL ) {
		return 1;
	}
	while ( fgets(buff,BUFSIZ,f) != NULL ) {
		char *p = strchr(buff,'\n');
		if ( p )
			*p = '\0';
		if ( stat(buff,&sb) < 0 )
			continue;
		callback(buff,S_ISDIR(sb.st_mode)?1:0);
	}
	pclose(f);
	return 0;
}

