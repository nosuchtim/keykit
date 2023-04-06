/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#define OVERLAY7

#include "key.h"

Htablep Fifotable = NULL;
Fifo *Topfifo = NULL;
Fifo *Freefifo = NULL;
int Nblocked = 0;
long Fifonum = 0;
int Default_fifotype = 0;

Fifo *Midi_in_f = NULL;
Fifo *Midi_out_f = NULL;
Fifo *Consinf = NULL;
Fifo *Consoutf = NULL;
Fifo *Mousef = NULL;

void
initfifos(void)
{
	if ( Fifotable == NULL ) {
		char *p = getenv("FIFOHASHSIZE");
		Fifotable = newht( p ? atoi(p) : 67 );
	}
}

static Fifodata *Freefd = NULL;

Fifodata *
newfd(Datum d)
{
	static int used = ALLOCFD;
	static Fifodata *lastfd;
	Fifodata *fd;

	if ( Freefd != NULL ) {
		fd = Freefd;
		Freefd = Freefd->next;
	}
	else {
		if ( used == ALLOCFD ) {
			used = 0;
			lastfd = (Fifodata *) kmalloc(ALLOCFD*sizeof(Fifodata),"newfd");
		}
		used++;
		fd = lastfd++;
	}
#ifdef THIS_CAUSES_PROBLEM_ON_MAC_AND_DOESNT_REALLY_DO_ANYTHING_ANYWAY
	if ( lastfd == NULL ) {
		eprint("Internal error, lastfd==NULL!?  forced abort()\n");
		abort();
	}
#endif
	fd->d = d;
	incruse(d);
	fd->next = NULL;
	return fd;
}

void
freefd(Fifodata *fd)
{
	decruse(fd->d);
	/* Add to free list */
	fd->next = Freefd;
	Freefd = fd;
}

Fifo *
fifoptr(long n)
{
	Hnodep h = hashtable(Fifotable,numdatum(n),H_LOOK);
	if ( h )
		return( h->val.u.fifo );
	else
		return(NULL);
}

PORTHANDLE porttofind;
Fifo *foundfifo;

int
findport(Hnodep h)
{
	Fifo *f;

	f = h->val.u.fifo;
	if ( (f->flags & FIFO_ISPORT) != 0 && f->port == porttofind )
		foundfifo = f;
	return 0;
}

Fifo *
port2fifo(PORTHANDLE port)
{
	foundfifo = NULL;
	porttofind = port;
	hashvisit(Fifotable,findport);
	return foundfifo;
}

void
closefifo(Fifo *f)
{
	Fifodata *fd, *nextfd;

	flushlinebuff(f);
	if ( f->flags & FIFO_ISPORT ) {
		if ( mdep_closeport(f->port) )
			mdep_popup("Unexpected event, mdep_closeport failed!?");
	}
	else if ( f->fp ) {
		if ( (f->flags & FIFO_PIPE) != 0 ) {
#ifdef PIPES
			if ( pclose(f->fp) < 0 )
				eprint("Error in pclose!?\n");
#else
			eprint("No pipes?!\n");
#endif
		}
		else
			myfclose(f->fp);
		f->fp = NULL;
	}

	/* If any task is blocked on it, give them an Eof */
	if ( f->t && f->t->state != T_FREE ) {
		if ( f->t->state == T_BLOCKED ) {
			Ktaskp saveT;

			saveT = T;
			T = f->t;
			unblocktask(f->t);
			/* This returns Eofval to the get() that's blocked */
			ret(numdatum(*Eofval));
			T = saveT;
		}
		else
			eprint("Internal error, in closefifo, task wasn't blocked?? state=%d\n",f->t->state);
	}
	f->t = NULL;
	f->flags = 0;
	f->size = 0;

#ifdef lint
	nextfd = NULL;
#endif
	for ( fd=f->tail; fd!=NULL; fd=nextfd ) {
		nextfd = fd->next;
		freefd(fd);
	}
}

void
deletefifo(Fifo *f)
{
	(void) hashtable(Fifotable,numdatum(f->num),H_DELETE);
}

void
freeff(Fifo *f)
{
	if ( f->flags & FIFO_OPEN )
		closefifo(f);
	f->next = Freefifo;
	Freefifo = f;
}

void
flushfifo(Fifo *f)
{
	Fifodata *fd, *nextfd;

	flushlinebuff(f);
	if ( f->fp ) {
		if ( (f->flags & (FIFO_WRITE|FIFO_APPEND)) != 0 )
			if ( fflush(f->fp) )
				mdep_popup("Unexpected error from fflush()?");
	}
	else if ( f->tail ) {
		/* there's data in the fifo, clear it */
#ifdef lint
		nextfd = NULL;
#endif
		for ( fd=f->tail; fd!=NULL; fd=nextfd ) {
			nextfd = fd->next;
			freefd(fd);
		}
		f->head = NULL;
		f->tail = NULL;
		f->size = 0;
		f->t = NULL;
	}
}

void
flushlinebuff(Fifo* f)
{
	if ( ((f->flags)&FIFO_READ) && f->linebuff!=NULL && f->linesofar > 0 ){
		f->linebuff[f->linesofar] = '\0';
		putfifo(f,strdatum(uniqstr(f->linebuff)));
		f->linesofar = 0;
	}
}

void
closeallfifos(void)
{
	clearht(Fifotable);
	Nblocked = 0;
}

char *
nameofchar(int c)
{
	static char *names[] = {
		"00", /* 00 */
		"01", /* 01 */
		"02", /* 02 */
		"03", /* 03 */
		"04", /* 04 */
		"05", /* 05 */
		"06", /* 06 */
		"07", /* 07 */
		"BS", /* 08 */
		"TAB", /* 09 */
		"10", /* 10 */
		"11", /* 11 */
		"12", /* 12 */
		"RETURN", /* 13 */
		"14", /* 14 */
		"15", /* 15 */
		"SHIFT", /* 16 */
		"CTRL", /* 17 */
		"18", /* 18 */
		"BREAK", /* 19 */
		"20", /* 20 */
		"21", /* 21 */
		"22", /* 22 */
		"23", /* 23 */
		"24", /* 24 */
		"25", /* 25 */
		"26", /* 26 */
		"ESC", /* 27 */
		"28", /* 28 */
		"29", /* 29 */
		"30", /* 30 */
		"31", /* 31 */
		"SPACE", /* 32 */
		"PAGEUP", /* 33 */
		"PAGEDOWN", /* 34 */
		"END", /* 35 */
		"HOME", /* 36 */
		"LEFTARROW", /* 37 */
		"UPARROW", /* 38 */
		"RIGHTARROW", /* 39 */
		"DOWNARROW", /* 40 */
		"41", /* 41 */
		"42", /* 42 */
		"43", /* 43 */
		"44", /* 44 */
		"INSERT", /* 45 */
		"DEL", /* 46 */
		"47", /* 47 */
		"0", /* 48 */
		"1", /* 49 */
		"2", /* 50 */
		"3", /* 51 */
		"4", /* 52 */
		"5", /* 53 */
		"6", /* 54 */
		"7", /* 55 */
		"8", /* 56 */
		"9", /* 57 */
		"58", /* 58 */
		"59", /* 59 */
		"60", /* 60 */
		"61", /* 61 */
		"62", /* 62 */
		"63", /* 63 */
		"64", /* 64 */
		"A", /* 65 */
		"B", /* 66 */
		"C", /* 67 */
		"D", /* 68 */
		"E", /* 69 */
		"F", /* 70 */
		"G", /* 71 */
		"H", /* 72 */
		"I", /* 73 */
		"J", /* 74 */
		"K", /* 75 */
		"L", /* 76 */
		"M", /* 77 */
		"N", /* 78 */
		"O", /* 79 */
		"P", /* 80 */
		"Q", /* 81 */
		"R", /* 82 */
		"S", /* 83 */
		"T", /* 84 */
		"U", /* 85 */
		"V", /* 86 */
		"W", /* 87 */
		"X", /* 88 */
		"Y", /* 89 */
		"Z", /* 90 */
		"91", /* 91 */
		"92", /* 92 */
		"93", /* 93 */
		"94", /* 94 */
		"95", /* 95 */
		"96", /* 96 */
		"97", /* 97 */
		"98", /* 98 */
		"99", /* 99 */
		"100", /* 100 */
		"101", /* 101 */
		"102", /* 102 */
		"103", /* 103 */
		"104", /* 104 */
		"105", /* 105 */
		"106", /* 106 */
		"107", /* 107 */
		"108", /* 108 */
		"109", /* 109 */
		"110", /* 110 */
		"111", /* 111 */
		"112", /* 112 */
		"113", /* 113 */
		"114", /* 114 */
		"115", /* 115 */
		"116", /* 116 */
		"117", /* 117 */
		"118", /* 118 */
		"119", /* 119 */
		"120", /* 120 */
		"121", /* 121 */
		"122", /* 122 */
		"123", /* 123 */
		"124", /* 124 */
		"125", /* 125 */
		"126", /* 126 */
		"127", /* 127 */
		"128", /* 128 */
		"129", /* 129 */
		"130", /* 130 */
		"131", /* 131 */
		"132", /* 132 */
		"133", /* 133 */
		"134", /* 134 */
		"135", /* 135 */
		"136", /* 136 */
		"137", /* 137 */
		"138", /* 138 */
		"139", /* 139 */
		"140", /* 140 */
		"141", /* 141 */
		"142", /* 142 */
		"143", /* 143 */
		"144", /* 144 */
		"145", /* 145 */
		"146", /* 146 */
		"147", /* 147 */
		"148", /* 148 */
		"149", /* 149 */
		"150", /* 150 */
		"151", /* 151 */
		"152", /* 152 */
		"153", /* 153 */
		"154", /* 154 */
		"155", /* 155 */
		"156", /* 156 */
		"157", /* 157 */
		"158", /* 158 */
		"159", /* 159 */
		"160", /* 160 */
		"161", /* 161 */
		"162", /* 162 */
		"163", /* 163 */
		"164", /* 164 */
		"165", /* 165 */
		"166", /* 166 */
		"167", /* 167 */
		"168", /* 168 */
		"169", /* 169 */
		"170", /* 170 */
		"171", /* 171 */
		"172", /* 172 */
		"173", /* 173 */
		"174", /* 174 */
		"175", /* 175 */
		"176", /* 176 */
		"177", /* 177 */
		"178", /* 178 */
		"179", /* 179 */
		"180", /* 180 */
		"181", /* 181 */
		"182", /* 182 */
		"183", /* 183 */
		"184", /* 184 */
		"185", /* 185 */
		";",   /* 186 */
		"=",   /* 187 */
		",",   /* 188 */
		"MINUS", /* 189 */
		".",   /* 190 */
		"/",   /* 191 */
		"GRAVEACCENT", /* 192 */
		"193", /* 193 */
		"194", /* 194 */
		"195", /* 195 */
		"196", /* 196 */
		"197", /* 197 */
		"198", /* 198 */
		"199", /* 199 */
		"200", /* 200 */
		"202", /* 202 */
		"202", /* 202 */
		"203", /* 203 */
		"204", /* 204 */
		"205", /* 205 */
		"206", /* 206 */
		"207", /* 207 */
		"208", /* 208 */
		"209", /* 209 */
		"210", /* 210 */
		"211", /* 211 */
		"212", /* 212 */
		"213", /* 213 */
		"214", /* 214 */
		"215", /* 215 */
		"216", /* 216 */
		"217", /* 217 */
		"218", /* 218 */
		"LEFTSQUARE", /* 219 */
		"BACKSLASH", /* 220 */
		"RIGHTSQUARE", /* 221 */
		"QUOTE", /* 222 */
		"223", /* 223 */
		"224", /* 224 */
		"225", /* 225 */
		"226", /* 226 */
		"227", /* 227 */
		"228", /* 228 */
		"229", /* 229 */
		"230", /* 230 */
		"232", /* 232 */
		"232", /* 232 */
		"233", /* 233 */
		"234", /* 234 */
		"235", /* 235 */
		"236", /* 236 */
		"237", /* 237 */
		"238", /* 238 */
		"239", /* 239 */
		"240", /* 240 */
		"242", /* 242 */
		"242", /* 242 */
		"243", /* 243 */
		"244", /* 244 */
		"245", /* 245 */
		"246", /* 246 */
		"247", /* 247 */
		"248", /* 248 */
		"249", /* 249 */
		"250", /* 250 */
		"252", /* 252 */
		"252", /* 252 */
		"253", /* 253 */
		"254", /* 254 */
		"255", /* 255 */
	};

	c = c & 0xff;
	return names[c];
}

void
putonconsinfifo(int c)
{
	if ( Consinf == NULL )
		execerror("Internal error, Consinf==NULL?");

	if ( c < 0 )
		putfifo(Consinf,numdatum(*Eofval));
	else if ( c == Intrchar )
		putfifo(Consinf,numdatum(*Intrval));
	else {
		char s[20];
		if ( (c & KEYDOWNBIT) != 0 ) {
			c &= (~KEYDOWNBIT);
			s[0] = '+';
			strcpy(s+1,nameofchar(c));
		} else if ( (c & KEYUPBIT) != 0 ) {
			c &= (~KEYUPBIT);
			s[0] = '-';
			strcpy(s+1,nameofchar(c));
		} else {
			s[0] = c;
			s[1] = '\0';
		}
		putfifo(Consinf,strdatum(uniqstr(s)));
	}
}

void
putonconsoutfifo(char *s)
{
	if ( Consoutf == NULL )
		mdep_popup(s);
	else
		putfifo(Consoutf,strdatum(s));
}

void
putonconsechofifo(char *s)
{
	Fifo *f = fifoptr(*Consecho_fnum);
	if ( f != NULL )
		putfifo(f,strdatum(s));
	else
		putonconsoutfifo(s);
}

void
putonmousefifo(int mval,int x,int y,int pressed,int mod)
{
	static int lastpressed = -99;	/* just so it's not -1, 0, or 1 */

	if ( Mousef == NULL )
		execerror("Hmm, Mousef == NULL in putonmousefifo?");

	/* when dragging or moving (i.e. pressed==0), we don't want */
	/* too many events to collect in mouse fifo. */
	if (!(pressed==0 && lastpressed==0 && fifosize(Mousef)>*Mousefifolimit)) {
		Datum da;
		long lx = x;
		long ly = y;
		Datum t;

		switch (pressed) {
		case 1:
			t = Str_down;
			break;
		case 0:
			if ( mval != 0 )
				t = Str_drag;
			else {
				if ( *Mousemoveevents == 0 )
					goto getout;
				t = Str_move;
			}
			break;
		case -1:
			t = Str_up;
			break;
		}
		da = newarrdatum(0,7);
		setarraydata(da.u.arr,Str_type,t);
		setarraydata(da.u.arr,Str_x,numdatum(lx));
		setarraydata(da.u.arr,Str_y,numdatum(ly));
		setarraydata(da.u.arr,Str_button,numdatum((long)mval));
		if ( mod != 0 )
			setarraydata(da.u.arr,Str_modifier,numdatum((long)mod));
		putfifo(Mousef,da);
	}
    getout:
	lastpressed = pressed;
}

void
putonmidiinfifo(Noteptr n)
{
	putntonfifo(n,Midi_in_f);
}

void
putntonfifo(Noteptr n,Fifo* f)
{
	if ( f == NULL )
		eprint("Hmm, f in putntonfifo == NULL ?\n");
	else {
		Phrasep ph = newph(0);
		ntinsert(ntcopy(n),ph);
		putfifo(f,phrdatum(ph));
	}
}

char *
findopt(char *nm,char **args)
{
	int n, ln;
	char *p, *q;
	char buff[BUFSIZ];

	for ( n=0; (p=args[n])!=NULL; n++ ) {
		if ( (q=strchr(p,'=')) == NULL )
			continue;
		ln = (int)(q-p);
		strncpy(buff,p,ln);
		buff[ln] = '\0';
		if ( strcmp(buff,nm) == 0 )
			return(q+1);
	}
	return NULL;
}

int
isspecialfifo(Fifo *f)
{
	return (f->flags) & FIFO_SPECIAL ;
}

Fifo *
specialfifo(void)
{
	Fifo *f;
	if ( newfifo((char*)NULL,(char*)NULL,(char*)NULL,&f,NULL) != 1 )
		execerror("Internal error - can't open specialfifo()!?");
	f->flags |= FIFO_SPECIAL ;
	return f;
	
}

Fifo *
getafifo(void)
{
	Fifo *f;
	Hnodep h;

	/* try to find a free one */
	if ( Freefifo ) {
		f = Freefifo;
		Freefifo = Freefifo->next;
	}
	else {
		/* none available, make a new one */
		f = (Fifo*)kmalloc(sizeof(Fifo),"newfifo");
		f->next = Topfifo;
		Topfifo = f;
	}
	f->flags = 0;
	f->head = NULL;
	f->tail = NULL;
	f->size = 0;
	f->t = NULL;
	f->fp = NULL;
	f->fifoctl_type = FIFOTYPE_UNTYPED;
	f->linebuff = NULL;
	f->linesize = 0;
	f->linesofar = 0;

	f->num = Fifonum++;
	h = hashtable(Fifotable,numdatum(f->num),H_INSERT);
	if ( isnoval(h->val) )
		h->val = fifodatum(f);
	else
		eprint("Hmm, fifo=%ld was already in Fifotable???\n",f->num);
	return f;
}

int
fifoctl2type(char *mode, int def)
{
	if ( strchr(mode,'f') != NULL )
		return FIFOTYPE_FIFO;
	if ( strchr(mode,'l') != NULL )
		return FIFOTYPE_LINE;
	if ( strchr(mode,'b') != NULL )
		return FIFOTYPE_BINARY;
	if ( strchr(mode,'A') != NULL )
		return FIFOTYPE_ARRAY;
	return def;	/* default */
}

int
mode2flags(char *mode)
{
	int flags = 0;

	if ( strchr(mode,'w') != NULL )
		flags |= FIFO_WRITE;
	if ( strchr(mode,'a') != NULL )
		flags |= FIFO_APPEND;
	if ( strchr(mode,'r') != NULL )
		flags |= FIFO_READ;
	return flags;
}

int
newfifo(char *fname,char *mode,char *porttype,Fifo **pf1,Fifo **pf2)
{
	Fifo *f1, *f2;
	FILE *fp;
	int flags;

	if ( fname == NULL ) {
		/* It's a keykit generic fifo */
		f1 = getafifo();
		f1->flags = FIFO_OPEN;
		*pf1 = f1;
		return 1;
	}

	if ( mode == NULL )
		execerror("Internal error, mode==NULL in newfifo()");
	if ( porttype == NULL )
		execerror("Internal error, porttype==NULL in newfifo()");

	flags = mode2flags(mode) | FIFO_OPEN;

	if ( strcmp(porttype,"pipe") == 0 ) {
#ifdef PIPES
		if ( (flags&(FIFO_WRITE|FIFO_APPEND)) != 0 )
			fp = popen(fname,"w");
		else {
			fp = popen(fname,"r");
			flags |= FIFO_READ;	 /* in case it wasn't explicit */
		}
		if ( fp==NULL ) {
			eprint("Error in opening pipe %s\n",fname);
			return 0;
		}
		f1 = getafifo();
		f1->flags = flags;
		f1->flags |= FIFO_PIPE;
		f1->fp = fp;
		*pf1 = f1;
		return 1;
#else
		eprint("No pipes!?\n");
		return 0;
#endif
	}
	else if ( strcmp(porttype,"file") == 0 ) {
		if ( (flags&FIFO_WRITE) != 0 )
			fp = fopen(fname,"w");
		else if ( (flags&FIFO_APPEND) != 0 )
			fp = fopen(fname,"a");
		else {
			fp = fopen(fname,"r");
			flags |= FIFO_READ;	 /* in case it wasn't explicit */
		}
		if ( fp==NULL ) {
			eprint("Error in opening %s\n",fname);
			return 0;
		}
		f1 = getafifo();
		f1->fp = fp;
		f1->flags = flags;
		*pf1 = f1;
		return 1;
	}
	else {
		PORTHANDLE *ports;
		int rflag = (strchr(mode,'r')!=NULL);
		int wflag = (strchr(mode,'w')!=NULL);
		int r = 0;

		ports = mdep_openport(fname,mode,porttype);
		// tprint("mdep_openports returned ports = %ld\n",ports);
		if ( ports == NULL ) {
			eprint("Unable to open port: open(%s,%s,%s) !?\n",
				fname,mode,porttype);
			return 0;
		}

		if ( rflag && ports[0] ) {
			f1 = getafifo();
			f1->flags = FIFO_OPEN | FIFO_ISPORT | FIFO_READ;
			f1->port = ports[0];
			f1->fifoctl_type = fifoctl2type(mode,Default_fifotype);
			*pf1 = f1;
			r |= 1;
		}
		if ( wflag && ports[1] ) {
			f2 = getafifo();
			f2->flags = FIFO_OPEN | FIFO_ISPORT | FIFO_WRITE;
			f2->port = ports[1];
			f2->fifoctl_type = fifoctl2type(mode,Default_fifotype);
			*pf2 = f2;
			r |= 2;
		}
		// tprint("mdep_openports returned r = %d\n",r);
		return r;
	}
}

int
fifosize(Fifo *f)
{
	return f->size;
}

void
getfromfifo(Fifo *f)
{
	Fifodata *fd;
	Datum d;

	fd = f->tail;

	if ( f->fp ) {
		int c = getc(f->fp);
		if ( c < 0 ) {
			f->size = 0;
			ret(numdatum(*Eofval));
		} else {
			int i = 0;
			/* the get() call returns a single byte or an */
			/* entire line, depending on flags */
			if ( f->fifoctl_type == FIFOTYPE_BINARY ) {
				ret(numdatum(c));
			}
			else {
				while ( c >= 0 && c != '\n' ) {
					makeroom((long)i+2,&Msg1,&Msg1size);
					Msg1[i++] = c;
					c = getc(f->fp);
				}
				Msg1[i] = '\0';
				ret(strdatum(uniqstr(Msg1)));
			}
		}
	}
	else if ( fd ) {	/* i.e. there's something in the fifo */
		if ( f->size <= 0 )
			execerror("Hey, f->tail is non-NULL, but f->size is <=0\n");

		if ( ((f->flags) & FIFO_NORETURN) != 0 ) {
			f->flags &= (~FIFO_NORETURN); /* only lasts 1 time */
		}
		else {
			/* return value for the bi_get call */
			d = removedatafromfifo(f);
			ret(d);
		}
	}
	else {
		if ( f->t ) {
			execerror("Multiple tasks (%ld and %ld) are blocking on the same fifo (%ld)\n",
				f->t->tid,T->tid,fifonum(f));
		}
		/* Hack for handling multiple get()s on the Console fifo */
		/* after Eof has been received. */
		if ( f == Consinf && Consolefd == -1 ) {
			f->size = 0;
			ret(numdatum(*Eofval));
		} else {
			blockfifo(f,0);	/* normal blocking on a get() */
		}
	}
}

Datum
removedatafromfifo(Fifo *f)
{
	Fifodata *fd = f->tail;
	Datum d;

	d = fd->d;
	/* remove if from the fifo */
	f->tail = fd->next;
	if ( --(f->size) == 0 )
		f->head = NULL;
	freefd(fd);
	return(d);
}

void
blockfifo(Fifo *f,int noreturn)
{
	T->fifo = f;
	f->t = T;
	if ( noreturn )
		f->flags |= FIFO_NORETURN;	/* don't ret() when data comes*/
	else
		f->flags &= (~FIFO_NORETURN);
	Nblocked++;
	taskunrun(T,T_BLOCKED);
	T = Running;
}

void
unblocktask(Ktaskp t)
{
	restarttask(t);
	Nblocked--;
	t->fifo = NULL;
}

void
getfifo(Fifo *f)
{
	if ( (f->flags & (FIFO_WRITE|FIFO_APPEND)) != 0 )
		execerror("Attempt to get() on a fifo (%ld) that is opened for writing!",fifonum(f));
	getfromfifo(f);
}

static FILE *Fputfp;

void
fputit(char *s)
{
	fputs(s,Fputfp);
}

void
putfifo(Fifo *f,Datum d)
{
	Fifodata *fd;
	char bytes[4];
	Symstr s;

	/* This routine is used both by the bi_put() routine when a */
	/* user is putting something on a fifo, as well as by the */
	/* handlewaitfor() when something arrives on a port, and it needs */
	/* to be put on a fifo for future reading by the user */
	/* (i.e. bi_get()).  Probably needs to be split up in the future. */

	if ( (f->flags & FIFO_ISPORT) != 0 && (f->flags & FIFO_WRITE) != 0 ) {
		switch(d.type) {
		case D_NUM:
			bytes[0] = (char)(d.u.val & 0xff);
			mdep_putportdata(f->port,bytes,1);
			break;
		default:
			s = datumstr(d);
			mdep_putportdata(f->port,s,(int)strlen(s));
			break;
		}
		return;
	}

	if ( f->fp ) {
		if ( f->fifoctl_type == FIFOTYPE_BINARY ) {
			int c = roundval(d);
			fputc(c,f->fp);
		}
		else {
			Fputfp = f->fp;
			prdatum(d,fputit,0);
		}
		return;
	}

	fd = newfd(d);

	if ( f->head ) {
		/* The list of fd's goes from f->tail to f->head.  f->tail is */
		/* where they're gotten from, and f->head is where they're put on. */
		f->head->next = fd;
	}
	else {
		/* nothing in fifo yet */
		f->tail = fd;
	}
	f->head = fd;
	f->size++;
	// keyerrfile("putfifo, size=%d\n",f->size);

	/* If there is a task that blocked on a get() */
	/* of this fifo, resurrect it. */
	if ( f->t ) {
		Ktaskp saveT;
		int tstate = f->t->state;
		if ( tstate != T_BLOCKED && tstate != T_FREE )
			execerror("unblocked task (tid=%ld ) isn't T_BLOCKED or T_FREE (state=%d)!?",T->tid,T->state);
		saveT = T;
		T = f->t;
		/* unblocktask(T);  NONONONO */
		restarttask(T);
		Nblocked--;
		getfromfifo(f);
		f->t = NULL;
		T->fifo = NULL;
		T = saveT;
	} else {
		// keyerrfile("No task blocked.\n");
	}
}
