/*
 * regex - Regular expression pattern matching
 *         and replacement
 *
 * By:  Ozan S. Yigit (oz) 
 *      Dept. of Computer Science
 *      York University
 *
 * These routines are the PUBLIC DOMAIN equivalents 
 * of regex routines as found in 4.nBSD UN*X, with minor
 * extensions.
 *
 * These routines are derived from various implementations
 * found in software tools books, and Conroy's grep. They
 * are NOT derived from licensed/restricted software.
 * For more interesting/academic/complicated implementations,
 * see Henry Spencer's regexp routines, or GNU Emacs pattern
 * matching module.
 *
 * Routines:
 *      myre_comp:        compile a regular expression into
 *                      a DFA.
 *
 *			char *myre_comp(s)
 *			char *s;
 *
 *      myre_exec:        execute the DFA to match a pattern.
 *
 *			int myre_exec(s)
 *			char *s;
 *
 *	myre_modw		change myre_exec's understanding of what
 *			a "word" looks like (for \< and \>)
 *			by adding into the hidden word-character 
 *			table.
 *
 *			void myre_modw(s)
 *			char *s;
 *
 *      myre_subs:	substitute the matched portions in
 *              	a new string.
 *
 *			int myre_subs(src, dst)
 *			char *src;
 *			char *dst;
 *
 *	myre_fail:	failure routine for myre_exec.
 *
 *			void myre_fail(msg, op)
 *			char *msg;
 *			int op;
 *  
 * Regular Expressions:
 *
 *      [1]     char    matches itself, unless it is a special
 *                      character (metachar): . \ [ ] * + ^ $
 *
 *      [2]     .       matches any character.
 *
 *      [3]     \       matches the character following it, except
 *			when followed by a left or right round bracket,
 *			a digit 1 to 9 or a left or right angle bracket. 
 *			(see [7], [8] and [9])
 *			It is used as an escape character for all 
 *			other meta-characters, and itself. When used
 *			in a set ([4]), it is treated as an ordinary
 *			character.
 *
 *      [4]     [set]   matches one of the characters in the set.
 *                      If the first character in the set is "^",
 *                      it matches a character NOT in the set. A
 *                      shorthand S-E is used to specify a set of
 *                      characters S upto E, inclusive. The special
 *                      characters "]" and "-" have no special
 *                      meaning if they appear as the first chars
 *                      in the set.
 *                      examples:        match:
 *
 *                              [a-z]    any lowercase alpha
 *
 *                              [^]-]    any char except ] and -
 *
 *                              [^A-Z]   any char except uppercase
 *                                       alpha
 *
 *                              [a-zA-Z] any alpha
 *
 *      [5]     *       any regular expression form [1] to [4], followed by
 *                      closure char (*) matches zero or more matches of
 *                      that form.
 *
 *      [6]     +       same as [5], except it matches one or more.
 *
 *      [7]             a regular expression in the form [1] to [10], enclosed
 *                      as \(form\) matches what form matches. The enclosure
 *                      creates a set of tags, used for [8] and for
 *                      pattern substution. The tagged forms are numbered
 *			starting from 1.
 *
 *      [8]             a \ followed by a digit 1 to 9 matches whatever a
 *                      previously tagged regular expression ([7]) matched.
 *
 *	[9]	\<	a regular expression starting with a \< construct
 *		\>	and/or ending with a \> construct, restricts the
 *			pattern matching to the beginning of a word, and/or
 *			the end of a word. A word is defined to be a character
 *			string beginning and/or ending with the characters
 *			A-Z a-z 0-9 and _. It must also be preceded and/or
 *			followed by any character outside those mentioned.
 *
 *      [10]            a composite regular expression xy where x and y
 *                      are in the form [1] to [10] matches the longest
 *                      match of x followed by a match for y.
 *
 *      [11]	^	a regular expression starting with a ^ character
 *		$	and/or ending with a $ character, restricts the
 *                      pattern matching to the beginning of the line,
 *                      or the end of line. [anchors] Elsewhere in the
 *			pattern, ^ and $ are treated as ordinary characters.
 *
 *
 * Acknowledgements:
 *
 *	HCR's Hugh Redelmeier has been most helpful in various
 *	stages of development. He convinced me to include BOW
 *	and EOW constructs, originally invented by Rob Pike at
 *	the University of Toronto.
 *
 * References:
 *              Software tools			Kernighan & Plauger
 *              Software tools in Pascal        Kernighan & Plauger
 *              Grep [rsx-11 C dist]            David Conroy
 *		ed - text editor		Un*x Programmer's Manual
 *		Advanced editing on Un*x	B. W. Kernighan
 *		RegExp routines			Henry Spencer
 *
 * Notes:
 *
 *	This implementation uses a bit-set representation for character
 *	classes for speed and compactness. Each character is represented 
 *	by one bit in a 128-bit block. Thus, CCL or NCL always takes a 
 *	constant 16 bytes in the internal dfa, and myre_exec does a single
 *	bit comparison to locate the character in the set.
 *
 * Examples:
 *
 *	pattern:	foo*.*
 *	compile:	CHR f CHR o CLO CHR o END CLO ANY END END
 *	matches:	fo foo fooo foobar fobar foxx ...
 *
 *	pattern:	fo[ob]a[rz]	
 *	compile:	CHR f CHR o CCL 2 o b CHR a CCL bitset END
 *	matches:	fobar fooar fobaz fooaz
 *
 *	pattern:	foo\\+
 *	compile:	CHR f CHR o CHR o CHR \ CLO CHR \ END END
 *	matches:	foo\ foo\\ foo\\\  ...
 *
 *	pattern:	\(foo\)[1-3]\1	(same as foo[1-3]foo)
 *	compile:	BOT 1 CHR f CHR o CHR o EOT 1 CCL bitset REF 1 END
 *	matches:	foo1foo foo2foo foo3foo
 *
 *	pattern:	\(fo.*\)-\1
 *	compile:	BOT 1 CHR f CHR o CLO ANY END EOT 1 CHR - REF 1 END
 *	matches:	foo-foo fo-fo fob-fob foobar-foobar ...
 * 
 */

/* To allow definition of __STDC__ */
#include "key.h"

#define MAXDFA  1024
#define MAXTAG  10

#define OKP     1
#define NOP     0

#define CHR     1
#define ANY     2
#define CCL     3
#define NCL     4
#define BOL     5
#define EOL     6
#define BOT     7
#define EOT     8
#define BOW	9
#define EOW	10
#define REF     11
#define CLO     12

#define END     0

/*
 * The following defines are not meant
 * to be changeable. They are for readibility
 * only.
 *
 */
#define MAXCHR	128
#define CHRBIT	8
#define BITBLK	MAXCHR/CHRBIT
#define BLKIND	0170
#define BITIND	07

#define ASCIIB	0177

typedef /*unsigned*/ char CHAR;

static int  tagstk[MAXTAG];             /* subpat tag stack..*/
static CHAR *dfa;			/* automaton..       */
static int  sta = NOP;               	/* status of lastpat */

static CHAR bittab[BITBLK];		/* bit table for CCL */

static void
chset(register char c)
{
	bittab[((c)&BLKIND)>>3] |= 1<<((c)&BITIND);
}

#define badpat(x)	return(*dfa = END, x)	/* */
#define store(x)	*mp++ = x
 
char *
myre_compX(char *pat)
{
	register char *p;               /* pattern pointer   */
	register CHAR *mp=dfa;          /* dfa pointer       */
	register CHAR *lp;              /* saved pointer..   */
	register CHAR *sp=dfa;          /* another one..     */

	register int tagi = 0;          /* tag stack index   */
	register int tagc = 1;          /* actual tag count  */

	register int n;
	int c1, c2;
		
	if (!pat || !*pat) {
		if (sta)
			return(0);
		else
			badpat("No previous regular expression");
	}
	sta = NOP;

	for (p = pat; *p; p++) {
		lp = mp;
		switch(*p) {

		case '.':               /* match any char..  */
			store(ANY);
			break;

		case '^':               /* match beginning.. */
			if (p == pat)
				store(BOL);
			else {
				store(CHR);
				store(*p);
			}
			break;

		case '$':               /* match endofline.. */
			if (!*(p+1))
				store(EOL);
			else {
				store(CHR);
				store(*p);
			}
			break;

		case '[':               /* match char class..*/

			if (*++p == '^') {
				store(NCL);
				p++;
			}
			else
				store(CCL);

			if (*p == '-')		/* real dash */
				chset(*p++);
			if (*p == ']')		/* real brac */
				chset(*p++);
			while (*p && *p != ']') {
				if (*p == '-' && *(p+1) && *(p+1) != ']') {
					p++;
					c1 = *(p-2) + 1;
					c2 = *p++;
					while (c1 <= c2)
						chset((char)(c1++));
				}
#ifdef EXTEND
				else if (*p == '\\' && *(p+1)) {
					p++;
					chset(*p++);
				}
#endif
				else
					chset(*p++);
			}
			if (!*p)
				badpat("Missing ]");

			for (n = 0; n < BITBLK; bittab[n++] = (char) 0)
				store(bittab[n]);
	
			break;

		case '*':               /* match 0 or more.. */
		case '+':               /* match 1 or more.. */
			if (p == pat)
				badpat("Empty closure");
			lp = sp;                /* previous opcode */
			if (*lp == CLO)         /* equivalence..   */
				break;
			switch(*lp) {

			case BOL:
			case BOT:
			case EOT:
			case BOW:
			case EOW:
			case REF:
				badpat("Illegal closure");
			default:
				break;
			}

			if (*p == '+')
				for (sp = mp; lp < sp; lp++)
					store(*lp);

			store(END);
			store(END);
			sp = mp;
			while (--mp > lp)
				*mp = mp[-1];
			store(CLO);
			mp = sp;
			break;

		case '\\':              /* tags, backrefs .. */
			switch(*++p) {

			case '(':
				if (tagc < MAXTAG) {
					tagstk[++tagi] = tagc;
					store(BOT);
					store(tagc++);
				}
				else
					badpat("Too many \\(\\) pairs");
				break;
			case ')':
				if (*sp == BOT)
					badpat("Null pattern inside \\(\\)");
				if (tagi > 0) {
					store(EOT);
					store(tagstk[tagi--]);
				}
				else
					badpat("Unmatched \\)");
				break;
			case '<':
				store(BOW);
				break;
			case '>':
				if (*sp == BOW)
					badpat("Null pattern inside \\<\\>");
				store(EOW);
				break;
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				n = *p-'0';
				if (tagi > 0 && tagstk[tagi] == n)
					badpat("Cyclical reference");
				if (tagc > n) {
					store(REF);
					store(n);
				}
				else
					badpat("Undetermined reference");
				break;
#ifdef EXTEND
			case 'b':
				store(CHR);
				store('\b');
				break;
			case 'n':
				store(CHR);
				store('\n');
				break;
			case 'f':
				store(CHR);
				store('\f');
				break;
			case 'r':
				store(CHR);
				store('\r');
				break;
			case 't':
				store(CHR);
				store('\t');
				break;
#endif
			default:
				store(CHR);
				store(*p);
			}
			break;

		default :               /* an ordinary char  */
			store(CHR);
			store(*p);
			break;
		}
		sp = lp;
	}
	if (tagi > 0)
		badpat("Unmatched \\(");
	store(END);
	sta = OKP;
	return(0);
}

char *     
myre_comp(char *pat)
{
	static char first = 1;

	if ( first ) {
		dfa = (CHAR *) malloc(MAXDFA * sizeof(CHAR));
		first = 0;
	}
	return myre_compX(pat);
}

static char *bol;
static char *bopat[MAXTAG];
static char *eopat[MAXTAG];
#ifdef __STDC__
static char *pmatch(register char *lp, register CHAR *ap);
#else
static char *pmatch();
#endif

/*
 * myre_exec:
 * 	execute dfa to find a match.
 *
 *	special cases: (dfa[0])	
 *		BOL
 *			Match only once, starting from the
 *			beginning.
 *		CHR
 *			First locate the character without
 *			calling pmatch, and if found, call
 *			pmatch for the remaining string.
 *		END
 *			myre_comp failed, poor luser did not
 *			check for it. Fail fast.
 *
 *	If a match is found, bopat[0] and eopat[0] are set
 *	to the beginning and the end of the matched fragment,
 *	respectively.
 *
 */

int
myre_exec(register char *lp)
{
	register char c;
	register char *ep = 0;
	register CHAR *ap = dfa;

	bol = lp;

	bopat[0] = 0;
	bopat[1] = 0;
	bopat[2] = 0;
	bopat[3] = 0;
	bopat[4] = 0;
	bopat[5] = 0;
	bopat[6] = 0;
	bopat[7] = 0;
	bopat[8] = 0;
	bopat[9] = 0;

	switch(*ap) {

	case BOL:			/* anchored: match from BOL only */
		ep = pmatch(lp,ap);
		break;
	case CHR:			/* ordinary char: locate it fast */
		c = *(ap+1);
		while (*lp && *lp != c)
			lp++;
		if (!*lp)		/* if EOS, fail, else fall thru. */
			return(0);
	default:			/* regular matching all the way. */
		while (*lp) {
			if ( (ep = pmatch(lp,ap)) != 0 )
				break;
			lp++;
		}
		break;
	case END:			/* munged automaton. fail always */
		return(0);
	}
	if (!ep)
		return(0);

	bopat[0] = lp;
	eopat[0] = ep;
	return(1);
}

/* 
 * pmatch: 
 *	internal routine for the hard part
 *
 * 	This code is mostly snarfed from an early
 * 	grep written by David Conroy. The backref and
 * 	tag stuff, and various other mods are by oZ.
 *
 *	special cases: (dfa[n], dfa[n+1])
 *		CLO ANY
 *			We KNOW ".*" will match ANYTHING
 *			upto the end of line. Thus, go to
 *			the end of line straight, without
 *			calling pmatch recursively. As in
 *			the other closure cases, the remaining
 *			pattern must be matched by moving
 *			backwards on the string recursively,
 *			to find a match for xy (x is ".*" and 
 *			y is the remaining pattern) where
 *			the match satisfies the LONGEST match
 *			for x followed by a match for y.
 *		CLO CHR
 *			We can again scan the string forward
 *			for the single char without recursion, 
 *			and at the point of failure, we execute 
 *			the remaining dfa recursively, as
 *			described above.
 *
 *	At the end of a successful match, bopat[n] and eopat[n]
 *	are set to the beginning and end of subpatterns matched
 *	by tagged expressions (n = 1 to 9).	
 *
 */

#ifdef __STDC__
extern void myre_fail(char*,int);
#else
extern void myre_fail();
#endif

/*
 * character classification table for word boundary
 * operators BOW and EOW. the reason for not using 
 * ctype macros is that we can let the user add into 
 * our own table. see myre_modw. This table is not in
 * the bitset form, since we may wish to extend it
 * in the future for other character classifications. 
 *
 *	TRUE for 0-9 A-Z a-z _
 */
static char chrtyp[MAXCHR] = {
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 
	0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
	1, 0, 0, 0, 0, 1, 0, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 0, 0, 0, 0, 0
	};

#define inascii(x)	(0177&(x))
#define iswordc(x) 	chrtyp[inascii(x)]
#define isinset(x,y) 	((x)[((y)&BLKIND)>>3] & (1<<((y)&BITIND)))

/*
 * skip values for CLO XXX to skip past the closure
 *
 */

#define ANYSKIP	2 	/* CLO ANY END ...	   */
#define CHRSKIP	3	/* CLO CHR chr END ...	   */
#define CCLSKIP 18	/* CLO CCL 16bytes END ... */

static char *
pmatch(register char *lp, register CHAR *ap)
{
	register char *e;		/* extra pointer for CLO */
	register char *bp;		/* beginning of subpat.. */
	register char *ep;		/* ending of subpat..	 */
	register int op, c, n;
	char *are;			/* to save the line ptr. */

	while ((op = *ap++) != END)
		switch(op) {

		case CHR:
			if (*lp++ != *ap++)
				return(0);
			break;
		case ANY:
			if (!*lp++)
				return(0);
			break;
		case CCL:
			c = *lp++;
			if (!isinset(ap,c))
				return(0);
			ap += BITBLK;
			break;
		case NCL:
			c = *lp++;
			if (isinset(ap,c))
				return(0);
			ap += BITBLK;
			break;
		case BOL:
			if (lp != bol)
				return(0);
			break;
		case EOL:
			if (*lp)
				return(0);
			break;
		case BOT:
			bopat[(unsigned char)*ap++] = lp;
			break;
		case EOT:
			eopat[(unsigned char)*ap++] = lp;
			break;
 		case BOW:
			if (!(lp!=bol && iswordc(lp[-1])) && iswordc(*lp))
				break;
			return(0);
		case EOW:
			if ((lp!=bol && iswordc(lp[-1])) && !iswordc(*lp))
				break;
			return(0);
		case REF:
			n = *ap++;
			bp = bopat[n];
			ep = eopat[n];
			while (bp < ep)
				if (*bp++ != *lp++)
					return(0);
			break;
		case CLO:
			are = lp;
			switch(*ap) {

			case ANY:
				while (*lp)
					lp++;
				n = ANYSKIP;
				break;
			case CHR:
				c = *(ap+1);
				while (*lp && c == *lp)
					lp++;
				n = CHRSKIP;
				break;
			case CCL:
			case NCL:
				while (*lp && (e = pmatch(lp, ap)) != 0 )
					lp = e;
				n = CCLSKIP;
				break;
			default:
				myre_fail("closure: bad dfa.", *ap);
				return(0);
			}

			ap += n;

			while (lp >= are) {
				if ( (e = pmatch(lp, ap)) != 0 )
					return(e);
				--lp;
			}
			return(0);
		default:
			myre_fail("myre_exec: bad dfa.", op);
			return(0);
		}
	return(lp);
}

/*
 * myre_modw:
 *	add new characters into the word table to
 *	change the myre_exec's understanding of what
 *	a word should look like. Note that we only
 *	accept additions into the word definition.
 *
 *	If the string parameter is 0 or null string,
 *	the table is reset back to the default, which
 *	contains A-Z a-z 0-9 _. [We use the compact
 *	bitset representation for the default table]
 *
 */

static unsigned char deftab[16] = {	
	0, 0, 0, 0, 0, 0, 0377, 003, 0376, 0377, 0377, 0207,  
	0376, 0377, 0377, 007 
}; 

void
myre_modw(register char *s)
{
	register int i;

	if (!s || !*s) {
		for (i = 0; i < MAXCHR; i++)
			if (!isinset(deftab,i))
				iswordc(i) = 0;
	}
	else
		while(*s)
			iswordc(*s++) = 1;
}

/*
 * myre_subs:
 *	substitute the matched portions of the src in
 *	dst.
 *
 *	&	substitute the entire matched pattern.
 *
 *	\digit	substitute a subpattern, with the given
 *		tag number. Tags are numbered from 1 to
 *		9. If the particular tagged subpattern
 *		does not exist, null is substituted.
 *
 */
int
myre_subs(register char *src, register char *dst)
{
	register char c;
	register int  pin;
	register char *bp;
	register char *ep;

	if (!*src || !bopat[0])
		return(0);

	while ( (c = *src++) != 0 ) {
		switch(c) {

		case '&':
			pin = 0;
			break;

		case '\\':
			c = *src++;
			if (c >= '0' && c <= '9') {
				pin = c - '0';
				break;
			}
			/* Eliminate fallthrough warning by cloning default case here */
			*dst++ = c;
			continue;
			
		default:
			*dst++ = c;
			continue;
		}

		if ((bp=bopat[pin]) != 0 && (ep=eopat[pin]) != 0 ) {
			while (*bp && bp < ep)
				*dst++ = *bp++;
			if (bp < ep)
				return(0);
		}
	}
	*dst = (char) 0;
	return(1);
}
			
#ifdef REGEXDEBUG
/*
 * symbolic - produce a symbolic dump of the
 *            dfa
 */
void
symbolic(char *s) 
{
	printf("pattern: %s\n", s);
	printf("dfacode:\n");
	dfadump(dfa);
}

static	
dfadump(CHAR *ap)
{
	register int n;

	while (*ap != END)
		switch(*ap++) {
		case CLO:
			printf("CLOSURE");
			dfadump(ap);
			switch(*ap) {
			case CHR:
				n = CHRSKIP;
				break;
			case ANY:
				n = ANYSKIP;
				break;
			case CCL:
			case NCL:
				n = CCLSKIP;
				break;
			}
			ap += n;
			break;
		case CHR:
			printf("\tCHR %c\n",*ap++);
			break;
		case ANY:
			printf("\tANY .\n");
			break;
		case BOL:
			printf("\tBOL -\n");
			break;
		case EOL:
			printf("\tEOL -\n");
			break;
		case BOT:
			printf("BOT: %d\n",*ap++);
			break;
		case EOT:
			printf("EOT: %d\n",*ap++);
			break;
		case BOW:
			printf("BOW\n");
			break;
		case EOW:
			printf("EOW\n");
			break;
		case REF:
			printf("REF: %d\n",*ap++);
			break;
		case CCL:
			printf("\tCCL [");
			for (n = 0; n < MAXCHR; n++)
				if (isinset(ap,(CHAR)n))
					printf("%c",n);
			printf("]\n");
			ap += BITBLK;
			break;
		case NCL:
			printf("\tNCL [");
			for (n = 0; n < MAXCHR; n++)
				if (isinset(ap,(CHAR)n))
					printf("%c",n);
			printf("]\n");
			ap += BITBLK;
			break;
		default:
			printf("bad dfa. opcode %o\n", ap[-1]);
			exit(1);
			break;
		}
}
#endif
