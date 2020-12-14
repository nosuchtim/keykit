#include "key.h"

/* miscellaneous stuff necessary for plotting test programs */
char *Mchn = "dummy";
char **Machine = &Mchn;
char *Fn = "font8.dat";
char **Fontname = &Fn;
char *Ps = ";";
char **Pathsep = &Ps;
char *Mp = "c:\\key\\music;.";
char **Musicpath = &Mp;
char *Kp = "c:\\key\\lib;.";
char **Keypath = &Kp;
char *Td = "c:\\tmp";
char **Tmpdir = &Td;
char *Kr = "c:\\";
char **Keyroot = &Kr;
char *Ic = "";
char **Icon = &Ic;
char *Ws = "dummy";
char **Windowsys = &Ws;
long Nw = 0;
long *Now = &Nw;
long Dbgv = 0;
long *Debug = &Dbgv;
long Mlrs = 1;
long *Millires = &Mlrs;
long Mlwn = 10;
long *Milliwarn = &Mlwn;
long Mrg = 1;
long *Merge = &Mrg;
long Mrgfilter = 0;
long *Mergefilter = &Mrgfilter;
long Rit = 1;
long *Resizeignoretime = &Rit;
long Rdt = 1;
long *Redrawignoretime = &Rdt;
long Kc = 0;
long *Conscount = &Kc;
#ifdef __STDC__
void (*Ttyoutfunc)(char*) = mdep_popup;
#else
void (*Ttyoutfunc)() = mdep_popup;
#endif
char Msg1b[256];
char *Msg1 = Msg1b;
char *Devm;
char **Devmidi = &Devm;
long *Menuymargin;
long Firsttime;
long Midimilli;
int Displayfd = -1;
int Consolefd = -1;
int Midifd = -1;

char *kpathsearch(s)
char *s;
{
	return s;
}

char *
uniqstr(s)
char *s;
{
	return s;
}

void
myfree(char *s)
{
	if ( s )
		free(s);
}

char *
strsave(char *s)
{
	char *p;
	p = (char *) malloc(strlen(s)+1);
	strcpy(p,s);
	return p;
}

/*
 * Break a KEYPATH into Pathsep-separated parts.
 * Pathsep can be escaped.
 */
char **
makeparts(path)
char *path;
{
	char *p;
	int nparts = 0;
	char buff[512];
	int Maxpathleng = 512;
	char *bp;
	int c, lng;
	char **parts;
	char sep;

	if ( Pathsep == 0 || *Pathsep == 0 )
		sep = ':';
	else
		sep = **Pathsep;

	/* count to get the (maximum) # of parts */
	p = path;
	while ( *p != '\0' ) {
		if ( *p++ == sep )
			nparts++;
	}
	parts = (char **) malloc((nparts+2)*sizeof(char *));
	bp = buff;
	nparts = 0;
	c = 1;	/* just to be non-0 */

	for ( p=path; c != '\0' ; ) {

		c = *p++;
		if ( c == sep || c == '\0' ) {
			*bp = '\0';

			/* An empty value is equivalent to the current directory */
			if ( *buff == '\0' )
				strcpy(buff,".");

			parts[nparts++] = uniqstr(buff);
			lng = strlen(buff);
			if ( lng > Maxpathleng )
				Maxpathleng = lng;
			bp = buff;
			continue;
		}
		if ( c == '\\' ) {
			/* backslash-sep results in just sep */
			if ( *p == sep )
				c = *p++;
		}
		*bp++ = c;
	}
	parts[nparts] = 0;
	return(parts);
}

void
error(s)
char *s;
{
	(*Ttyoutfunc)(s);
}

void
tprint(s)
char *s;
{
	(*Ttyoutfunc)(s);
		
}

void
eprint(s)
char *s;
{
}

void
installnum(name,p,v)
char *name;
Symlongp *p;
long v;
{
	*p = (Symlongp) malloc(sizeof(long));
	**p = v;
}

void
mdep_corecheck()
{
}

void
execerror(s)
char *s;
{
	exit(0);
}

void
m_menumain(void)
{
}

int Killchar, Erasechar;

long Cl = 2;
long *Colors = &Cl;

long Ki = 0;
long *Keyinverse = &Ki;

long Pr = 0;
long *Panraster = &Pr;

long Mi = 7;
long *Mpuirq = &Mi;

long Cm = 0;
long *Cachemenu = &Cm;

long Ma = 0x300;
long *Mpuaddr = &Ma;

long Zr = 0;
long *Fakemaxx = &Zr;
long *Fakemaxy = &Zr;

long Gm = 0;
long *Graphmode = &Gm;

long Gd = 0;
long *Graphdriver = &Gd;

long Ce = 0;
long *Consecho = &Ce;

int Intrchar;
