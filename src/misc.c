/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

/* This is a hook that allows things to be put into mdep.h for */
/* one-time inclusion.  For example, this can be used to put a small */
/* function in mdep.h, so that the full mdep.o isn't needed. */
#define ONETIMEINCLUDE

#define OVERLAY6

#include "key.h"

void (*Fatalfunc)(char *) = 0;
void (*Diagfunc)(char *) = 0;
long dval = 1;
long *Debug = &dval;
long dmval = 1;
extern long *Debugmalloc;

int
exists(char *fname)
{
	FILE *f;

	/* MS C++ fopen() crashes if you give it a "" value? */
	if ( fname==NULL || *fname=='\0' )
		return 0;

	int err = 0;
	f = fopen(fname, "r");
	if ( f == NULL ) {
		err = errno;
	}
	if ( err == 0 && f != NULL ) {
		myfclose(f);
		return(1);
	}
	return(0);
}

void
myfclose(FILE *f)
{
	if ( fclose(f) != 0 ) {
		if ( Diagfunc ) {
			(*Diagfunc)("Error in fclose()!?\n");
		}
		else
			eprint("Error in fclose()!? errno=%d\n",errno);
	}
}

int
hexchar(register int c)
{
	if ( c >= '0' && c <= '9' )
		return(c-'0');
	if ( c >= 'A' && c <= 'F' )
		return(c-'A'+10);
	if ( c >= 'a' && c <= 'f' )
		return(c-'a'+10);
	return(-1);
}

long
numscan(register char **as)
{
	char c = **as;
	long num = 0;
	int sign = 1;

	if ( c == '-' ) {
		sign = -1;
		c = *(++(*as));
	}
	while ( c>='0' && c<='9' ) {
		num = num * 10 + (c-'0');
		c = *(++(*as));
	}
	return(num*sign);
}

static void
reverse(register char *s)
{
	register long i, j;
	char c;

	for ( i=0, j=(long)strlen(s)-1; i<j; i++, j-- ) {
		c = s[i];
		s[i] = s[j];
		s[j] = c;
	}
}

/*
 * prlongto
 *
 * Convert n to a decimal string, putting it in s, returning a pointer
 * to the end of s.  Compliments of K&R.
 */

char *
prlongto(register long n,register char *s)
{
	register int i, sign = 0;

	if ( n < 0 ) {
		sign = -1;
		n = -n;
	}
	i = 0;
	do {
		s[i++] = (int)(n % 10) + '0';
	} while ( (n /= 10) > 0 );
	if ( sign < 0 )
		s[i++] = '-';
	s[i] = '\0';
	reverse(s);
	return(&s[i]);
}

char *
printto(register int n,register char *s)
{
	register int i, sign;

	if ( (sign=n) < 0 )
		n = -n;
	i = 0;
	do {
		s[i++] = n % 10 + '0';
	} while ( (n /= 10) > 0 );
	if ( sign < 0 )
		s[i++] = '-';
	s[i] = '\0';
	reverse(s);
	return(&s[i]);
}

char *
strsave(register char *s)
{
	register char *p = kmalloc((unsigned)(strlen(s)+1),"strsave");
	strcpy(p,s);
	if ( Debugmalloc!=NULL && *Debugmalloc ) {
		char buff[100];
		sprintf(buff,"strsave=(%s)(ch1=%d)\n",p,p[0]);
		keyerrfile(buff);
	}
	return(p);
}

int
stdioname(char *fname)
{
	/* "|" and "-" are equivalent to /dev/stdin and /dev/stdout */

	if ( ( *fname == '|' || *fname == '-' ) && *(fname+1) == '\0' )
		return(1);
	return(0);
}

void
allocerror(void)
{
	if ( Fatalfunc )
		(*Fatalfunc)("Unable to allocate memory!?");
	else {
		eprint("Fatal error: unable to allocate memory!\n");
#ifdef MDEBUG
		keyerrfile("Fatal error: unable to allocate memory!\n");
#endif
		exit(1);
	}
}

/*
 * The following routines can be used to keep track of what has
 * been allocated and not yet freed.  The mmreset() function can
 * be used to 'tag' the memory that has been allocated up to that
 * point, so that new memory items can be identified (and dumped
 * by mmdump().
 */

#ifndef MDEBUG
char *
allocate(unsigned int s, char *tag)
{
	char *p;

	p = (char*) malloc(s);
	/* if ( Debugmalloc!=NULL && *Debugmalloc!=0 && recurse<=1 )
		keyerrfile("allocate(%d %s)=%d\n",s,tag,p); */
	if ( p == NULL )
		allocerror();
	return(p);
}
#else

struct mminfo {
	char *ptr;
	unsigned int size;
	char *tag;
	short flag;
	struct mminfo *next;
};
struct mminfo *Topmm = NULL;

char *
dbgallocate(unsigned int s,char *tag)
{
	struct mminfo *m;
	char *tg;
	char *p;
static int recurse = 0;

recurse++;
{extern long *Debug;
if(Debug && *Debug && recurse <= 1){char buff[32];sprintf(buff,"a(%d,%s)",s,tag==NULL?"":tag);keyerrfile(buff);}
}
recurse--;
	p = malloc(s);
if(Debugmalloc && *Debugmalloc){
	char buff[100];
	sprintf(buff,"allocate(%d,tag=%s)=%lld\n",s,tag,(long long)p);
	keyerrfile(buff);
}
	m = (struct mminfo *)malloc(sizeof(struct mminfo));
keyerrfile("dbgalloc B1 malloc of %d\n",sizeof(struct mminfo));
	m->ptr = p;
	if ( p==NULL || m==NULL )
		allocerror();
	m->flag = 0;
	m->size = s;
	s = strlen(tag)+1;
	tg = malloc(s);
	if ( tg == NULL )
		allocerror();
	strcpy(tg,tag);
	m->tag = tg;
	m->next = Topmm;
	Topmm = m;
keyerrfile("dbgalloc C\n");
	{extern long *Debug;
		if ( Debug!=NULL && *Debug!='\0' ) {
			char buff[100];
			sprintf(buff,"allocate(%d %s)\n",m->size,tag);
			keyerrfile(buff);
		}
	}
keyerrfile("dbgalloc returning\n");
	return(p);
}

void
mmreset(void)
{
	struct mminfo *m;

	for ( m=Topmm; m!=NULL; m=m->next )
		m->flag = 1;
	keyerrfile("mmreset done\n");
}

char *
visstr(char *s)
{
	register char *p = s;

	for ( ; *p!='\0'; p++ ) {
		if ( ! isprint(*p) )
			return("<non-printable?>");
	}
	return(s);
}

void
mmdump(void)
{
	struct mminfo *m;
	char buff[200];

	keyerrfile("mmdump\n");
	for ( m=Topmm; m!=NULL; m=m->next ) {
		if ( m->flag == 1 )
			continue;
		sprintf(buff,"mm ptr=%lld size=%d tag=%s str=%s\n",
			(long long)(m->ptr),m->size,m->tag,visstr(m->ptr));
		keyerrfile(buff);
	}
}
#endif

void
myfree(char *s)
{
	if ( s == NULL )
		return;
#ifdef MDEBUG
    {	struct mminfo *m, *prevm;
	for ( prevm=NULL,m=Topmm; m!=NULL; prevm=m,m=m->next ) {
		if ( m->ptr == s )
			break;
	}
	if ( m == NULL ) {
		keyerrfile("Hey, myfree called with a pointer that wasn't allocate'ed\n");
	}
	else {
		if(Debugmalloc && *Debugmalloc) {
			char buff[100];
			sprintf(buff,"myfree(%lld tag=%s)\n",(long long)s,m->tag);
			keyerrfile(buff);
		}
	}
	if ( prevm==NULL )
		Topmm = Topmm->next;
	else
		prevm->next = m->next;
    }
#endif
	free(s);	/* DO NOT CHANGE THIS TO kfree() ! */
}

char *
myfgets(char *buff, int bufsiz, FILE *f)
{
	int c;
	int n;
	char *p = buff;

	for ( n=0; n<bufsiz; n++ ) {
		c = getc(f);
		if ( c < 0 ) {
			if ( p == buff )
				return 0;
			else
				return buff;
		}
		*p++ = c;
		if ( c == '\n' || c == '\r' ) {
			*p = 0;
			return buff;
		}
	}
	return buff;
}
