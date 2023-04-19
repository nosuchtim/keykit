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
		keyerrfile("strsave=(%s)(ch1=%d)\n",p,p[0]);
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
void *
allocate(unsigned int s, char *tag)
{
	char *p;

	dummyusage(tag);
	p = malloc(s);
	/* if ( Debugmalloc!=NULL && *Debugmalloc!=0 && recurse<=1 )
		keyerrfile("allocate(%d %s)=%d\n",s,tag,p); */
	if ( p == NULL )
		allocerror();
	return(p);
}

void *
myrealloc(void *s, unsigned int size, char *tag)
{
	char *p;

	dummyusage(tag);
	p = realloc(s, size);
	/* if ( Debugmalloc!=NULL && *Debugmalloc!=0 && recurse<=1 )
		keyerrfile("myrealloc(%d %s)=%d\n",s,tag,p); */
	if ( p == NULL )
		allocerror();
	return(p);
}

void
myfree(void *s)
{
	if ( s == NULL )
		return;
	free(s);	/* DO NOT CHANGE THIS TO kfree() ! */
}

#else /* MDEBUG */

struct mminfo {
	char *ptr;
	unsigned int size;
	char *tag;
	short flag;
	struct mminfo *next;
};
struct mminfo *Topmm = NULL;

void *
dbgallocate(unsigned int s,char *tag)
{
	extern long *Debug;
	struct mminfo *m;
	char *tg;
	char *p;
	static int recurse = 0;


	p = malloc(s);
	recurse++;
	{
		if(Debug && *Debug && recurse <= 1) {
			keyerrfile("allocate(%d)=0x%" KEY_PRIxPTR " tag=%s\n",s,(KEY_PRIxPTR_TYPE)p,tag==NULL?"":tag);
		}
	}
	recurse--;

	m = (struct mminfo *)malloc(sizeof(struct mminfo));
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
	return(p);
}

void *
dbgmyrealloc(void *s, unsigned int size, char *tag)
{
	extern long *Debug;
	struct mminfo *m;
	char *p;

	if ( s == NULL )
		return dbgallocate(size, tag);

	for ( m=Topmm; m!=NULL; m=m->next ) {
		if ( m->ptr == s )
			break;
	}
	if ( m == NULL ) {
		keyerrfile("Hey, myrealloc(0x%" KEY_PRIxPTR ") called with unallocated pointer\n", (KEY_PRIxPTR_TYPE)s);
	}

	p = realloc(s, size);
	if ( p == NULL )
		allocerror();

	if(Debug && *Debug) {
		keyerrfile("myrealloc(0x%" KEY_PRIxPTR ",%d)=0x%" KEY_PRIxPTR " tag=%s\n",s,size,(KEY_PRIxPTR_TYPE)p,tag==NULL?"":tag);
	}

	m->ptr = p;
	m->size = size;
	m->flag = 0;
	m->tag = tag;
	return p;
}

void
dbgmyfree(void *s)
{
	struct mminfo *m, *prevm;
	if ( s == NULL )
		return;

	for ( prevm=NULL,m=Topmm; m!=NULL; prevm=m,m=m->next ) {
		if ( m->ptr == s )
			break;
	}
	if ( m == NULL ) {
		keyerrfile("Hey, myfree(0x%" KEY_PRIxPTR ") called with unallocated pointer\n", (KEY_PRIxPTR_TYPE)s);
	}
	else {
		if(Debug && *Debug) {
			keyerrfile("myfree(0x%" KEY_PRIxPTR ") tag=%s\n",(KEY_PRIxPTR_TYPE)s,m?m->tag:"");
		}
	}
	if ( prevm==NULL )
		Topmm = Topmm->next;
	else
		prevm->next = m->next;

	free(s);	/* DO NOT CHANGE THIS TO kfree() ! */
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

	keyerrfile("mmdump\n");
	for ( m=Topmm; m!=NULL; m=m->next ) {
		if ( m->flag == 1 )
			continue;
		keyerrfile("mm ptr=0x%" KEY_PRIxPTR " size=%d tag=%s str=%s\n",
			(KEY_PRIxPTR_TYPE)(m->ptr),m->size,m->tag,visstr(m->ptr));
	}
}
#endif


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
