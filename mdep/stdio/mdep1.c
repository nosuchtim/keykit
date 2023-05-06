#ifndef __FreeBSD__
#include <termio.h>
#endif
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#ifdef linux
#include <sys/time.h>
#include <time.h>
#include <unistd.h>
#define TRY_RLIMIT_DATA
#endif
#ifdef __sgi
#define TRY_RLIMIT_DATA
#endif
#ifdef __FreeBSD__
#define TRY_RLIMIT_DATA
#endif
#ifdef TRY_RLIMIT_DATA
#include <sys/resource.h>
#endif

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
#else
	dummyusage(argc);
	dummyusage(argv);
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
#ifdef TRY_RLIMIT_DATA
	struct rlimit rl;
	if ( getrlimit(RLIMIT_DATA,&rl) < 0 || (long)(rl.rlim_cur) < 0 ) {
		return(MAXLONG);
	}
	return (long)rl.rlim_cur;
#else
	long max = ulimit(3, 0);
	char *cur = (char*)sbrk(0);
	return max - (long)cur;
#endif
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
	char *sep = SEPARATOR;

	sprintf(buff,"ls %s%s%s 2>/dev/null",dir,sep,exp);
	f = popen(buff,"r");
	if ( f == NULL ) {
		return 1;
	}
	while ( fgets(buff,BUFSIZ,f) != NULL ) {
		unsigned int len;
		char *p = strchr(buff,'\n');
		if ( p )
			*p = '\0';
		if ( stat(buff,&sb) < 0 )
			continue;

		/* Strip off original directory and separator(if there) */
		len = strlen(dir);
		p = buff;
		if ( strncmp(p, dir, len) == 0 ) {
			p += len;
			len = strlen(sep);
			if ( strncmp(p, sep, len) == 0 ) {
				p += len;
			}
		}
		callback(p,S_ISDIR(sb.st_mode)?1:0);
	}
	pclose(f);
	return 0;
}

#if !(defined(__FreeBSD__) || defined(linux))
char *
strerror(int e)
{
	extern int sys_nerr;
	extern char *sys_errlist[];

	if ( e < 0 || e >= sys_nerr )
		return("Bad errno!?");
	else
		return sys_errlist[e];
}

#ifdef LOCALUNLINK
int
unlink(const char* path)
{
	return remove(path)
}
#endif

#endif
