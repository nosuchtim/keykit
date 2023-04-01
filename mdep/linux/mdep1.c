/*
 *    Copyright 1996 AT&T Corp.  All rights reserved.
 */

#include <termios.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/times.h>
#include <sys/resource.h>
#include <unistd.h>
#include <time.h>
#include <pthread.h>
#include <semaphore.h>
#include <stdarg.h>

#include "key.h"

#ifdef MDEP_ENABLE_DBGTRACE
/**
 * Machine dependent tracing code
 *
 * This code uses a ring buffer with produce in keykit while consumer
 * runs in a separate thread that pulls debug information out of the
 * ring buffer and writes into a file.
 */

#define DBG_POOL_NELEMENTS 64
#define DBG_POOL_STRING_LENGTH 128
struct DbgEntry {
	uintmax_t now; /* system clock ticks when entry put into dbgPool */
	char str[DBG_POOL_STRING_LENGTH];
};
struct DbgPool {
	uintmax_t start;
	sem_t emptySem;
	sem_t fullSem;
	pthread_mutex_t mutex;
	uint32_t freq;
	volatile uint32_t head, tail;
	pthread_t thread;
	volatile struct DbgEntry pool[DBG_POOL_NELEMENTS];
} dbgPool;

FILE *dbgLogfile;

static void
*dbgPrintThread(void *arg)
{
	struct DbgEntry entry;
	volatile struct DbgEntry *p;
	int ret;

	(void)arg;

	dbgLogfile = fopen("/tmp/keykit.log", "w");
	while (1)
	{
		/* Wait for dbgPool to not be empty */
		ret = sem_wait(&dbgPool.emptySem);
		if (ret)
		{
			fprintf(stderr, "%s: failed to lock empty sempaphore: %s\n", __FUNCTION__, strerror(errno));
			exit(1);
		}
		/* lock the pool then extract an entry */
		ret = pthread_mutex_lock(&dbgPool.mutex);
		if (ret)
		{
			fprintf(stderr, "%s: failed to lock pool mutex: %s\n", __FUNCTION__, strerror(errno));
			exit(1);
		}
		p = &dbgPool.pool[dbgPool.tail++ % DBG_POOL_NELEMENTS];
		entry = *p;
		ret = pthread_mutex_unlock(&dbgPool.mutex);
		if (ret)
		{
			fprintf(stderr, "%s: failed to unlock pool mutex: %s\n", __FUNCTION__, strerror(errno));
			exit(1);
		}
		ret = sem_post(&dbgPool.fullSem);
		if (ret)
		{
			fprintf(stderr, "%s: failed to post full semaphore: %s\n", __FUNCTION__, strerror(errno));
			exit(1);
		}
		
		if (dbgLogfile)
		{
			/* Compute time */
			uintmax_t delta = entry.now - dbgPool.start;
			uint32_t seconds = delta / dbgPool.freq;
			uint32_t hundredths = delta % dbgPool.freq;
			hundredths = (hundredths * 100) / dbgPool.freq;
			fprintf(dbgLogfile, "%" PRIu32 ".%02" PRIu32 " %s\n", seconds, hundredths, entry.str);
		}
	}
}

void
mdep_dbginit(void)
{
	int ret;

	/* Get tick frequency and time now */
	dbgPool.freq = sysconf(_SC_CLK_TCK);
	dbgPool.start = times(NULL);
	
	dbgPool.head = dbgPool.tail = 0;
	/* Init mutex, empty/full semaphores, and startup the consumer thread */
	pthread_mutex_init(&dbgPool.mutex, NULL);
	ret = sem_init(&dbgPool.emptySem, 0, 0);
	if (ret)
	{
		fprintf(stderr, "%s: Failed to init empty semaphore: %s\n", __FUNCTION__, strerror(errno));
		exit(-1);
	}
	ret = sem_init(&dbgPool.fullSem, 0, DBG_POOL_NELEMENTS);
	if (ret)
	{
		fprintf(stderr, "%s: Failed to init empty semaphore: %s\n", __FUNCTION__, strerror(errno));
		exit(-1);
	}
	ret = pthread_create(&dbgPool.thread, NULL, dbgPrintThread, NULL);
	if (ret)
	{
		fprintf(stderr, "%s: Failed to create dbgPrintConsumer thread: %s\n", __FUNCTION__, strerror(errno));
		exit(-1);
	}
	
}

unsigned int dbgTraceBits = DBGTRACE_KEYKIT | DBGTRACE_CALLER;

void
mdep_dbgsetbits(unsigned int bitmask)
{
    dbgTraceBits |= bitmask;
}

void
mdep_dbgclrbits(unsigned int bitmask)
{
    dbgTraceBits &= ~bitmask;
}

static void
mdep_dbgputentry(struct DbgEntry *entry)
{
	volatile struct DbgEntry *p;
	int ret;
	
	entry->now = times(NULL);
	ret = sem_wait(&dbgPool.fullSem);
	if (ret)
	{
		fprintf(stderr, "%s: failed to wait full semaphore: %s\n", __FUNCTION__, strerror(errno));
		exit(1);
	}
	ret = pthread_mutex_lock(&dbgPool.mutex);
	if (ret)
	{
		fprintf(stderr, "%s: failed to lock pool mutex: %s\n", __FUNCTION__, strerror(errno));
		exit(1);
	}
	p = &dbgPool.pool[dbgPool.head++ % DBG_POOL_NELEMENTS];
	*p = *entry;
	ret = pthread_mutex_unlock(&dbgPool.mutex);
	if (ret)
	{
		fprintf(stderr, "%s: failed to unlock pool mutex: %s\n", __FUNCTION__, strerror(errno));
		exit(1);
	}
	ret = sem_post(&dbgPool.emptySem);
	if (ret)
	{
		fprintf(stderr, "%s: failed to post empty semaphore: %s\n", __FUNCTION__, strerror(errno));
		exit(1);
	}
}

void
mdep_dbgputs(const char *str)
{
	struct DbgEntry entry;

	strncpy(entry.str, str, sizeof(entry.str)-1);
	entry.str[sizeof(entry.str)-1] = '\0';

	mdep_dbgputentry(&entry);
}

void
mdep_dbgtrace(const char *format, ...)
{
	va_list argPtr;
	struct DbgEntry entry;
	
	va_start(argPtr, format);
	vsnprintf(entry.str, sizeof(entry.str)-1, format, argPtr);
	va_end(argPtr);

	mdep_dbgputentry(&entry);
}
#endif

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

#ifdef MDEP_ENABLE_DBGTRACE
	mdep_dbginit();
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

