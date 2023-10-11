/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#define OVERLAY3

#include "key.h"
#include "gram.h"

int Tjt = 0;
int	Indef = 0;	/* >0 while parsing a function definition */
int	Inclass = 0;	/* >0 while parsing a class definition */
int	Inparams = 0;	/* 1 while parsing the parameters of a func def'n */
int	Inselect = 0;	/* 1 while parsing a select {...} construct */
int	Globaldecl = 0;	/* 1 while parsing a global statement. */

void
resetstack(void)
{
	Stackp = Stack;
}

void
underflow(void)
NO_RETURN_ATTRIBUTE
{
	execerror("Stack underflow");
}

void
i_pop(void)
{
	Datum d;

	if (Stackp == Stack)
		underflow();
	d = *--Stackp;
	decruse(d);
}

Instnodep *Iseg = NULL;
Instnodep *Lastin = NULL;
Instnodep *Future = NULL;

/* This is purposely low, just to exercise newly added code. */
#define ISEGINC 2
int Maxiseg = 0;
int Niseg = -1;

Instcode Stopcode;

void
clriseg(void)
{
	Iseg[Niseg] = NULL;
	Lastin[Niseg] = NULL;
	Future[Niseg] = newin();
}

void
pushiseg(void)
{
	if ( ++Niseg >= Maxiseg ) {
		int newmax = Maxiseg + ISEGINC;
		unsigned int newsize = newmax * sizeof(Instnodep);

		Iseg = krealloc(Iseg, newsize, "pushiseg");
		Lastin = krealloc(Lastin, newsize, "pushiseg");
		Future = krealloc(Future, newsize, "pushiseg");
		Maxiseg  = newmax;
	}
	clriseg();
}

Codep
inodes2code(Instnodep inlist)
{
	register Instnodep in2;
	Instcode i;
	int n;
	Unchar *ip, *ip2;
	Instnodep in;
	int offset = 0;
	int codetype;

	/* First go through and figure out how big the code will be, */
	/* so we know the exact byte position of each instruction, and also */
	/* so we know how much memory to allocate. */

#ifdef FFF
fprintf(FF,"INODES2CODE start\n");
#endif

	/* Anything that's still an i_stop is really an i_stop. */
	/* Need to change it before computing sizes. */
	for ( in=inlist; in!=NULL; in=nextinode(in) ) {
		/* Can't use codeis() here, since type==IC_INST */
		if ( in->code.u.func==(BYTEFUNC)I_STOP && in->code.type==IC_INST )
			in->code.type = IC_FUNC;
	}

	for ( in=inlist; in!=NULL; in=nextinode(in) ) {
	
		in->offset = offset;

		/* advance offset by size of code type */
		codetype = in->code.type;
		if ( codetype <= 0 || codetype >= (int)sizeof(Codesize) ) {
			eprint("Unknown IC_* (%d) in 2inst!?",codetype);
		}
		else {
			if ( codetype != IC_NUM )
				offset += Codesize[codetype];
			else
				offset += varinum_size(in->code.u.val);
		}
	}

	ip = (Unchar *) kmalloc(offset,"inodes2code");
	*Numinst1 += offset;	/* keep track of how much memory consumed */

	for ( ip2=ip,in=inlist; in!=NULL; in=nextinode(in) ) {
		i = in->code;
		if ( i.type == IC_INST ) {
			/* This is a branch - find which inode it points */
			/* to, and set up the proper value */

			for ( in2=inlist,n=0; in2!=NULL; n++,in2=nextinode(in2) ) {
				if ( i.u.in == in2 ) {
					Unchar* p = ip;
					p += in2->offset;
					i.u.ip = p;
					break;
				}
			}
			if ( in2 == NULL )
				mdep_popup("Internal error: couldn't find branch point for instruction!?");
		}

		switch ( i.type ) {
		case IC_NUM:
			ip2 = put_numcode(i.u.val,ip2);
			break;
		case IC_STR:
			ip2 = put_strcode(i.u.str,ip2);
			break;
		case IC_DBL:
			ip2 = put_dblcode(i.u.dbl,ip2);
			break;
		case IC_SYM:
			ip2 = put_symcode(i.u.sym,ip2);
			break;
		case IC_PHR:
			ip2 = put_phrcode(i.u.phr,ip2);
			break;
		case IC_INST:
			ip2 = put_ipcode(i.u.ip,ip2);
			break;
		case IC_FUNC:
			ip2 = put_funccode(i.u.func,ip2);
			break;
		case IC_BLTIN:
			ip2 = put_bltincode(i.u.bltin,ip2);
			break;
		default:
			mdep_popup("Unknown IC_* in 2inst!?");
		}
	}
	return(ip);
}

Instnodebranchlist iblist;

void
freeinstnodebranchlist(void)
{
	iblist.used = 0;
}

/* Add branch instruction address (and target) to instnode branch list */
void
addinstnodebranch(Instnodep addr, Instnodep target)
{
	Instnodebranchp ib;
	makeroom(sizeof(iblist.arry[0])*(iblist.used+1), (char **)&iblist.arry, &iblist.size);
	ib = &iblist.arry[iblist.used++];
	ib->addr = addr;
	ib->target = target;
}

/* Initially build list of branch instructions before optimization */
void
buildinstnodebranchlist(Instnodep t)
{
	Instnodep i,j,target;
	intptr_t funcidx;
	
	for (i = t; i; i=nextinode(i)) {
		switch(i->code.type) {
		    case IC_FUNC:
			    funcidx = (intptr_t)i->code.u.func;
			    switch(funcidx) {
				case I_DOSWEEPCONT:
				case I_SELECT2:
				case I_SELECT3:
				case I_TCONDEVAL:
				case I_FCONDEVAL:
				case I_GOTO:
				case I_AND1:
				case I_OR1:
				case I_FORIN1:
					/* IC_INST follows */
					j = nextinode(i);
					if (j->code.type != IC_INST)
					{
						execerror("0x%" KEY_PRIxPTR ": ", (KEY_PRIxPTR_TYPE)i);
						Errors++;
						return;
					}
					target = j->code.u.in;
					addinstnodebranch(i, target);
					if ( *Debuginst )
						keyerrfile("insn 0x%" KEY_PRIxPTR " points to 0x%" KEY_PRIxPTR "\n", (KEY_PRIxPTR_TYPE)i, (KEY_PRIxPTR_TYPE)target);
					i = j; /* skip over the tailing IC_INST */
					break;
				default:
					break;
			    }
			    break;
		    case IC_INST:
		    {
			    if (i->code.u.func != (BYTEFUNC)I_STOP) {
				    keyerrfile("warning: 0x%" KEY_PRIxPTR ": IC_INST found!\n", (KEY_PRIxPTR_TYPE)i);
			    }
			    break;
		    }
		    default:
			    break;
		}
	}
}

/* Update the branch poriton of insn to jump to new target */
void
instnodebranchupdate(Instnodep insn, Instnodep newtarget)
{
	Instnodebranchp ib, ibend;

	ibend = &iblist.arry[iblist.used];
	for (ib=iblist.arry; ib<ibend; ++ib) {
		if (ib->addr == insn) {
			if ( *Debuginst )
				keyerrfile("udpate insnnodelist 0x%" KEY_PRIxPTR " from 0x%" KEY_PRIxPTR " to 0x%" KEY_PRIxPTR "\n", (KEY_PRIxPTR_TYPE)insn, (KEY_PRIxPTR_TYPE)ib->target, (KEY_PRIxPTR_TYPE)newtarget);
			ib->target = newtarget;
			return;
		}
	}
	execerror("%s: couldn't find insn 0x%" KEY_PRIxPTR "", __FUNCTION__, (KEY_PRIxPTR_TYPE)insn);
}

Codep
popiseg(void)
{
	Codep ip;
	Instnodep poppedin;

	if ( Niseg < 0 )
		execerror("popiseg called too many times?");

	/* add final Stopcode instruction */
	Future[Niseg]->code = Stopcode;
	addinode(Future[Niseg]);

	poppedin = Iseg[Niseg--];
	if ( Errors == 0 ) {
		buildinstnodebranchlist(poppedin);
		optiseg(poppedin);
		freeinstnodebranchlist();
	}
	ip = inodes2code(poppedin);
	freeiseg(poppedin);
	return ip;
}

/* Remove the inode following prei */
void
rminstnode(Instnodep prei,int adjust)
{
	Instnodep rmi = nextinode(prei);
	previnode(nextinode(rmi)) = previnode(rmi);
	nextinode(previnode(rmi)) = nextinode(rmi);
	freeinode(rmi);
	if ( adjust )
		instnodepatch(rmi,nextinode(prei));
}

void
instnodepatch(Instnodep oldtarget,Instnodep newtarget)
{
	/* Backpatch any pointers to an inode, i.e. change all */
	/* occurrences of pointers to oldtarget into pointers to newtarget */
	Instnodebranchp ib, ibend;

	ibend = &iblist.arry[iblist.used];
	for (ib = iblist.arry; ib<ibend; ++ib) {
		if ( ib->target == oldtarget ) {
			if ( *Debuginst )
				keyerrfile("Patching insn 0x%" KEY_PRIxPTR "; branch 0x%" KEY_PRIxPTR " => 0x%" KEY_PRIxPTR "\n", (KEY_PRIxPTR_TYPE)ib->addr, (KEY_PRIxPTR_TYPE)oldtarget, (KEY_PRIxPTR_TYPE)newtarget);
			/* ib->insn banches to i1 - make it branch to i2 */
			ib->target = newtarget;
			/* Note: nextnode(ib->addr) is IC_INST of i1 branch
			 * insn(since all brnach insns have IC_INST follow */
			nextinode(ib->addr)->code.u.in = newtarget;
		}
	}
}

struct {
	unsigned int val;
	char *str;
} dottypelist[] = {
	{ VOL, "VOL" },
	{ DUR, "DUR" },
	{ CHAN, "CHAN" },
	{ PORT, "PORT" },
	{ TIME, "TIME" },
	{ PITCH, "PITCH" },
	{ LENGTH, "LENGTH" },
	{ TYPE, "TYPE" },
	{ ATTRIB, "ATTRIB" },
	{ FLAGS, "FLAGS" },
	{ NUMBER, "NUMBER" }
};

static
char *dottypestr(unsigned int dottype)
{
	unsigned int idx;
	
	for (idx=0; idx<ARRAY_SIZE(dottypelist); ++idx) {
		if (dottype == dottypelist[idx].val) {
			break;
		}
	}
	if (idx != ARRAY_SIZE(dottypelist)) {
		return dottypelist[idx].str;
	}
	return NULL;
}

unsigned int
multicodeiseg(Instnodep i)
{
	unsigned int skip;
	Instnodep opnode, dotnode, j, k;
	intptr_t funcidx;
	char *dontpush, *opstr;
	char opbuf[2];
	unsigned int op, orgop;
	char *dotstr;
	
	if (i->code.type != IC_FUNC) {
		return 0;
	}

	skip = 0;
	funcidx = (intptr_t)i->code.u.func;
	switch(funcidx) {
	    case I_FORIN1:
		    /* Should have IC_INST and IC_SYM following */
		    j = nextinode(i);
		    if ( j->code.type != IC_INST ) {
			    return 0;
		    }
		    k = nextinode(j);
		    if ( k->code.type != IC_SYM ) {
			    return 0;
		    }
		    skip = 2; /* Skip IC_INST and IC_SYM */
		    keyerrfile("IC_FUNC ");
		    eprfunc(i->code.u.func);
		    if (k->code.u.sym->name.u.str != NULL) {
			    keyerrfile(" [%s", k->code.u.sym->name.u.str);
		    }
		    else {
			    keyerrfile(" [NULL!");
		    }
		    if (j->code.u.in != NULL) {
			    keyerrfile(" 0x%" KEY_PRIxPTR "]", (KEY_PRIxPTR_TYPE)j->code.u.in);
		    }
		    else {
			    keyerrfile(" NULL!] ");
		    }
		    break;
		    
	    case I_AND1:
	    case I_OR1:
	    case I_GOTO:
	    case I_TCONDEVAL:
		    /* Should have single IC_INST following */
		    j = nextinode(i);
		    if ( j->code.type != IC_INST ) {
			    return 0;
		    }
		    skip = 1; /* Skip single IC_INST */
		    keyerrfile("IC_FUNC ");
		    eprfunc(i->code.u.func);
		    if (j->code.u.in != NULL) {
			    keyerrfile(" [0x%" KEY_PRIxPTR "]", (KEY_PRIxPTR_TYPE)j->code.u.in);
		    }
		    else {
			    keyerrfile(" [NULL!]");
		    }
		    break;

	    case I_UNDEFINE:
	    case I_DEFINED:
	    case I_OBJCALLFUNC:
	    case I_GVAREVAL:
	    case I_LVAREVAL:
	    case I_VARPUSH:
	    case I_CALLFUNC:
		    /* Should have IC_SYM following */
		    j = nextinode(i);
		    if ( (j->code.type != IC_SYM)
			 || (j->code.u.sym == NULL) ) {
			    return 0;
		    }
		    skip = 1; /* Skip single IC_SYM */
		    keyerrfile("IC_FUNC ");
		    eprfunc(i->code.u.func);
		    if (j->code.u.sym->name.u.str != NULL) {
			    keyerrfile(" [%s]", j->code.u.sym->name.u.str);
		    }
		    else {
			    keyerrfile(" [NULL!]");
		    }
		    break;

	    case I_FILENAME:
	    case I_STRINGPUSH:
		    /* Should have IC_STR following */
		    j = nextinode(i);
		    if (j->code.type != IC_STR) {
			    return 0;
		    }
		    skip = 1; /* Skip single IC_STR */
		    keyerrfile("IC_FUNC ");
		    eprfunc(i->code.u.func);
		    if (j->code.u.str != NULL) {
			    keyerrfile(" [\"%s\"]", j->code.u.str);
		    }
		    else {
			    keyerrfile(" [NULL!]");
		    }
		    break;

	    case I_VARG:
	    case I_DOTDOTARG:
	    case I_ARRAY:
	    case I_LINENUM:
	    case I_CONSTANT:
	    case I_CONSTOBJEVAL:
		    /* Should have IC_NUM following */
		    j = nextinode(i);
		    if (j->code.type != IC_NUM) {
			    return 0;
		    }
		    skip = 1; /* Skip single IC_NUM */
		    keyerrfile("IC_FUNC ");
		    eprfunc(i->code.u.func);
		    keyerrfile(" [%ld]", j->code.u.val);
		    break;

	    case I_DOT:
		    /* Should have IC_NUM following that is dot type. */
		    j = nextinode(i);
		    if (j->code.type != IC_NUM) {
			    return 0;
		    }
		    skip = 1; /* Skip single IC_NUM */
		    keyerrfile("IC_FUNC ");
		    eprfunc(i->code.u.func);
		    keyerrfile(" [%ld => .%s]", j->code.u.val, dottypestr(j->code.u.val));
		    break;
		    
	    case I_DOTASSIGN:
	    case I_MODDOTASSIGN:
	    case I_VARASSIGN:
	    case I_MODASSIGN:
		    /* i_var/modassign should have IC_NUM following
		     * that is type of assignment.
		     * i_moddot/dotassign should have 2 IC_NUM following,
		     * 1st being the dottype, 2nd being type of assignment. */
		    opnode = nextinode(i);
		    if (opnode->code.type != IC_NUM) {
			    return 0;
		    }
		    dotnode = NULL;
		    if (funcidx == I_DOTASSIGN || funcidx == I_MODDOTASSIGN) {
			    dotnode = opnode;
			    opnode = nextinode(dotnode);
			    if (opnode->code.type != IC_NUM) {
				    return 0;
			    }
			    skip=2; /* Skip two following IC_NUM */
		    }
		    else {
			    skip = 1; /* Skip single following IC_NUM */
		    }
		    orgop = op = opnode->code.u.val;
		    dontpush = NULL;
		    if (op & DONTPUSH) {
			    dontpush="dontpush";
			    op &= ~DONTPUSH;
		    }
		    dotstr = NULL;
		    if (dotnode) {
			    dotstr = dottypestr(dotnode->code.u.val);
		    }
		    switch(op)
		    {
			case INC:
				opstr = "INC";
				break;
			case DEC:
				opstr = "DEC";
				break;
			case POSTDEC:
				opstr = "POSTDEC";
				break;
			case POSTINC:
				opstr = "POSTINC";
				break;
			default:
				opbuf[0] = op;
				opbuf[1] = '\0';
				opstr = opbuf;
				break;
		    }
		    keyerrfile("IC_FUNC ");
		    eprfunc(i->code.u.func);
		    if (dotstr) {
			    keyerrfile(" .%s", dotstr);
		    }
		    keyerrfile(" [0x%x => %s%s%s]", orgop, dontpush?dontpush:"", dontpush?" ":"", opstr);
		    break;

	    case I_PHRASEPUSH:
		    /* Should have a phrase pointer */
		    j = nextinode(i);
		    if (j->code.type != IC_PHR) {
			    return 0;
		    }
		    skip = 1; /* Skip single following IC_PHR */
		    keyerrfile("IC_FUNC ");
		    eprfunc(i->code.u.func);
		    if (j->code.u.phr != NULL) {
			    keyerrfile(" [0x%" KEY_PRIxPTR "]", (KEY_PRIxPTR_TYPE)j->code.u.phr);
		    }
		    else {
			    keyerrfile(" [NULL!]");
		    }
		    break;
		    
	    default:
		    break;
	}
	return skip;
}

void
dumpcodeiseg(Instnodep t, const char *msg)
{
	Instnodep i;
	unsigned int skip, idx;

	keyerrfile("%s\n", msg);
	for ( i=t; i!=NULL; i=nextinode(i) ) {
		int decoded = 0;
		keyerrfile("  0x%" KEY_PRIxPTR " ",(KEY_PRIxPTR_TYPE)i);
		skip = multicodeiseg(i);
		for (idx = 0; idx<skip; ++idx) {
			i = nextinode(i);
		}
		decoded = skip != 0;

		if ( !decoded ) {
			switch(i->code.type) {
			    case IC_NUM:
				    keyerrfile("IC_NUM %ld", i->code.u.val);
				    break;
			    case IC_STR:
				    if ( i->code.u.str != NULL ) {
					    keyerrfile("IC_STR 0x%" KEY_PRIxPTR " '%s'", i->code.u.str, i->code.u.str);
				    }
				    else {
					    keyerrfile("IC_STR NULL!");
				    }
				    break;
			    case IC_DBL:
				    keyerrfile("IC_DBL %g", i->code.u.dbl);
				    break;
			    case IC_SYM:
				    if ( i->code.u.sym != NULL ) {
					    keyerrfile("IC_SYM 0x%" KEY_PRIxPTR " '%s'", i->code.u.sym, i->code.u.sym->name.u.str);
				    }
				    else {
					    keyerrfile("IC_SYM NULL!");
				    }
				    break;
			    case IC_INST:
				    if (i->code.u.func == (BYTEFUNC)I_STOP) {
					    /* Could be an unconverted stop */
					    keyerrfile("IC_INST => IC_FUNC(STOP)");
				    }
				    else {
					    keyerrfile("IC_INST => 0x%" KEY_PRIxPTR "", (KEY_PRIxPTR_TYPE)i->code.u.in);
				    }
				    break;
			    case IC_BLTIN:
				    keyerrfile("IC_BLTIN ");
				    eprfunc(i->code.u.func);
				    break;
			    case IC_NONE:
				    keyerrfile("IC_NONE! ");
				    eprfunc(i->code.u.func);
				    break;
			    case IC_PHR:
				    keyerrfile("IC_PHR => 0x%" KEY_PRIxPTR "", (KEY_PRIxPTR_TYPE)i->code.u.phr);
				    break;
			    case IC_FUNC:
				    keyerrfile("IC_FUNC ");
				    eprfunc(i->code.u.func);
				    break;
				    
			    default:
				    keyerrfile("IC_(0x%x) ", i->code.type);
				    eprfunc(i->code.u.func);
				    break;
			}
		}
		keyerrfile("\n");
	}
}

void
optiseg(Instnodep t)
{
	Instnodep i, pi, i1, i2, i3, i4, i5, oldi1;
	Symbolp s;
	int anyopt, pass;
	int totalopt = 0;
	intptr_t funcidx;
	
	if ( t == NULL )
		return;

	/* This is a necessary adjustment, it's not an optimization */
	for ( i=t; i!=NULL; i=nextinode(i) ) {
		if ( codeis(i->code,I_VAREVAL) ) {
			s = nextinode(i)->code.u.sym;
			if ( isglobal(s) )
				i->code = funcinst(I_GVAREVAL);
			else
				i->code = funcinst(I_LVAREVAL);
		}
	}

	if ( *Debuginst != 0) {
		dumpcodeiseg(t, "ISEG BEFORE Optimization");
	}

	if ( *Optimize == 0 )
		return;

	/* Multiple optimization passes */
	anyopt = 1;
	for ( pass=1; anyopt; pass++ ) {
	    anyopt = 0;
	    if ( *Debuginst )
		keyerrfile("Pass %d of Optimization\n",pass);
	    for ( pi=t,i1=nextinode(pi); i1!=NULL; ) {

		i2 = nextinode(i1);
		i3 = i2 ? nextinode(i2) : NULL;
		i4 = i3 ? nextinode(i3) : NULL;
		i5 = i4 ? nextinode(i4) : NULL;

		if ( i1->code.type != IC_FUNC ) {
			/* All optimization patterns start with a IC_FUNC;
			 * if insn not IC_FUNC, skip to next Instnode. */
			pi = i1;
			i1 = i2;
			continue;
		}

		funcidx = (intptr_t)i1->code.u.func;
		switch(funcidx) {
		case I_GVAREVAL:
			if (i2 && i3 && i4 && i5
			    && codeis(i3->code,I_LINENUM)
			    && codeis(i5->code,I_POPIGNORE) ) {

				if ( *Debuginst )
					keyerrfile("Optimization X at i1=0x%" KEY_PRIxPTR "\n",(KEY_PRIxPTR_TYPE)i1);

				/* A global var is being pushed and then ignored. */
				/* It's probably a standalone function definition. */

				oldi1 = i1;
				rminstnode(pi,0);	/* I_GVAREVAL */
				rminstnode(pi,0);	/* symbol */
				rminstnode(pi,0);	/* I_LINENUM */
				rminstnode(pi,0);	/* number */
				rminstnode(pi,0);	/* I_POPIGNORE */
				i1 = nextinode(pi);

				instnodepatch(oldi1,i1);
				anyopt++;
				continue;
			}
			break;

		case I_LINENUM:
			if (i2 && i3 && codeis(i3->code,I_LINENUM) ) {

				if ( *Debuginst )
					keyerrfile("Optimization A at i1=0x%" KEY_PRIxPTR "\n",(KEY_PRIxPTR_TYPE)i1);

				/* multiple consecutive I_LINENUMS, delete the first */
				oldi1 = i1;
				rminstnode(pi,0);	/* I_LINENUM */
				rminstnode(pi,0);	/* constant value */
				i1 = i3;
				instnodepatch(oldi1,i1);
				anyopt++;
				continue;
			}
			break;

		case I_CONSTANT:
			if (i2 && i3 && codeis(i3->code,I_POPIGNORE) ) {

				if ( *Debuginst )
					keyerrfile("Optimization B at i1=0x%" KEY_PRIxPTR "\n",(KEY_PRIxPTR_TYPE)i1);

				/* A constant is being pushed and then ignored. */
				/* It's probably the fakeval/popignore that we */
				/* insert for statement values. We get rid of all */
				/* 3 inodes.  We need to save the old value of i1, */
				/* so we can go back and patch any pointers to it. */

				oldi1 = i1;
				rminstnode(pi,0);	/* I_CONSTANT */
				rminstnode(pi,0);	/* constant value */
				rminstnode(pi,0);	/* popignore */
				i1 = nextinode(pi);

				instnodepatch(oldi1,i1);
				anyopt++;
				continue;
			}
			if ( i2 && i3 && codeis(i3->code,I_NEGATE) ) {
				if ( *Debuginst )
					keyerrfile("Optimization F1 at i1=0x%" KEY_PRIxPTR "\n",(KEY_PRIxPTR_TYPE)i1);
				/* Have "I_CONSTANT; IC_NUM <val>; I_NEGATE".
				 * Replace with: "I_CONSTANT; IC_NUM <-val>" */
				i2->code.u.val = -i2->code.u.val;
				rminstnode(i2,1);
				anyopt++;
				continue;
			}
			break;

		case I_VARASSIGN:
			if (i2 && i3 && codeis(i3->code,I_POPIGNORE) ) {

				if ( *Debuginst )
					keyerrfile("Optimization C at i1=0x%" KEY_PRIxPTR "\n",(KEY_PRIxPTR_TYPE)i1);

				/* It's a varassign whose result is being
				 * ignored; get rid of the popignore, and
				 * adjust the assign code so the value
				 * isn't pushed. */
				rminstnode(i2,1);	/* gets rid of i3 */
				i2->code.u.val |= DONTPUSH;
				pi = i2;
				i1 = nextinode(pi);
				anyopt++;
				continue;
			}
			break;

		case I_NOOP:
			if ( *Debuginst )
				keyerrfile("Optimization D at i1=0x%" KEY_PRIxPTR "\n",(KEY_PRIxPTR_TYPE)i1);
			rminstnode(pi,1);
			i1 = nextinode(pi);
			anyopt++;
			continue;

		case I_DBLPUSH:
			if ( i2 && codeis(i3->code,I_NEGATE) ) {
				if ( *Debuginst )
					keyerrfile("Optimization F2 at i1=0x%" KEY_PRIxPTR "\n",(KEY_PRIxPTR_TYPE)i1);
				/* Have "I_DBLPUSH; IC_DBL <val>; I_NEGATE".
				 * Replace with: "I_DBLPUSH; IC_DBL <-val>" */
				i2->code.u.dbl = -i2->code.u.dbl;
				rminstnode(i2,1);
				anyopt++;
				continue;
			}
			break;
			    
		default:
			break;
		}

		pi=i1;
		i1=i2;
	    }
	    if ( *Debuginst && anyopt ) {
		    char buf[80];
		    snprintf(buf, sizeof(buf), "ISEG AFTER %d optimizations in pass %d", anyopt, pass);
		    dumpcodeiseg(t, buf);
	    }
	    totalopt += anyopt;
	}
	if ( *Debuginst ) {
		keyerrfile("Total optimizations: %d\n", totalopt);
	}
}

Instnodep
futureinstnode(void)
{
	return(Future[Niseg]);
}

void
addinode(Instnodep in)
{
	Instnodep last = Lastin[Niseg];
	if ( last == NULL ) {
		Iseg[Niseg] = in;
	}
	else {
		nextinode(last) = in;
		previnode(in) = last;
	}
	nextinode(in) = NULL;
	Lastin[Niseg] = in;
}

Instnodep
code(Instcode ic)
{
	register Instnodep in;

	in = Future[Niseg];
	Future[Niseg] = newin();
	in->code = ic;

	addinode(in);
	return(in);
}

Instcode
numinst(int n)
{
	Instcode i;
	i.u.val = n;
	i.type = IC_NUM;
	return i;
}

Instcode
strinst(Symstr s)
{
	Instcode i;
	i.u.str = s;
	i.type = IC_STR;
	return i;
}

Instcode
dblinst(double d)
{
	Instcode i;
	i.u.dbl = (DBLTYPE) d;
	i.type = IC_DBL;
	return i;
}

Instcode
syminst(Symbolp s)
{
	Instcode i;
	i.u.sym = s;
	i.type = IC_SYM;
	return i;
}

Instcode
phrinst(Phrasep p)
{
	Instcode i;
	i.u.phr = p;
	i.type = IC_PHR;
	return i;
}

Instcode
instnodeinst(Instnodep n)
{
	Instcode i;
	i.u.in = n;
	i.type = IC_INST;
	return i;
}

Instcode
realfuncinst(BYTEFUNC f)
{
	Instcode i;
	i.u.func = f;
	i.type = IC_FUNC;
	return i;
}

Instcode
bltininst(BLTINCODE f)
{
	Instcode i;
	i.u.bltin = f;
	i.type = IC_BLTIN;
	return i;
}

Instcode*
ptincode(register Instnodep in,register int n)
{
	while ( n-- > 0 )
		in = nextinode(in);
	return( & (in->code) );
}

void
i_dblpush(void)
{
	Datum d;

	d = dbldatum(use_dblcode());
	pushm(d);
}

void
i_stringpush(void)
{
	Datum d;

	d = strdatum(use_strcode());
	pushm(d);
}

void
i_phrasepush(void)
{
	Datum d;

	d = phrdatum( use_phrcode() );
	pushm(d);
}

/* makeroom - increase the size of a buffer to make room for n chars */
void
makeroom(long n,char **aptr,long *asize)
{
	char *s, *t, *ns;
	long k, newsize;

	if ( *asize >= n )
		return;
	newsize = *asize;
	while ( newsize < n )
		newsize = ((newsize+1)*3)/2;   /* increase by 50% */

	ns = s = (char *) kmalloc((unsigned)newsize,"makeroom");
	t = *aptr;
	for ( k = *asize; k>0; k-- )
		*s++ = *t++;
	kfree(*aptr);	/* NULL value okay */
	*aptr = ns;
	*asize = newsize;
}

static long Msg2leng = 0;	/* length of string in Msg2 */
static long Msg3leng = 0;	/* length of string in Msg3 */

void
reinitmsg2(void)
{
	*Msg2 = '\0';
	Msg2leng = 0;
}

void
ptomsg2(register Symstr s)
{
	long lng = (long)strlen((char*)s);

	makeroom(Msg2leng+lng+1,&Msg2,&Msg2size);
	strcpy(&Msg2[Msg2leng],s);
	Msg2leng += lng;
}

void
reinitmsg3(void)
{
	*Msg3 = '\0';
	Msg3leng = 0;
}

void
ptomsg3(register Symstr s)
{
	long lng = (long)strlen((char*)s);

	makeroom(Msg3leng+lng+1,&Msg3,&Msg3size);
	strcpy(&Msg3[Msg3leng],s);
	Msg3leng += lng;
}

Symstr
phrstr(Phrasep p, int nl)
{
	reinitmsg2();
	phprint(ptomsg2,p,nl);
	return uniqstr(Msg2);
}

/* Convert an arbitrary Datum to a string */

Symstr
dtostr(Datum d)
{
	switch ( d.type ) {
	case D_STR:
		return d.u.str;
	case D_PHR:
		return phrstr(d.u.phr,0);
	default:
		(void) prlongto(numval(d),Buffer);
		return uniqstr(Buffer);
	}
}

/* Convert an arbitrary Datum to a canonical value appropriate for array */
/* index operations.  We prefer to make it a number, so that comparisons */
/* when searching arrays are faster. */

Datum
dtoindex(Datum d)
{
	long l;

	switch ( d.type ) {
	case D_NUM:
		/* leave it alone */
		break;
	case D_STR:
		/* leave it alone */
		break;
	case D_PHR:		/* convert phrase to a string */
		d = strdatum(phrstr(d.u.phr,0));
		break;
	case D_OBJ:
		/* leave it alone */
		break;
	default:
		/* don't merge these two - evaluation order is undefined. */
		l = numval(d);
		d = numdatum(l);
		break;
	}
	return d;
}

void
expectarr(Datum d,Datum subs,char *s)
{
	if ( d.type == D_ARR )
		return;
	execerror("Expected an array value %s, but got %s (subscript value was %s)",
		s,atypestr(d.type),datumstr(subs));
}

void
i_arrend(void)
{
	register Symbolp s;
	Datum subs;
	Datum d;

	/* this is called when we want to evaluate an array expression */
	/* and push the VALUE of the array element onto the stack. */

	popinto(subs);
	popinto(d);	/* symbol for array */
	expectarr(d,subs,"before subscript");
	s = arraysym(d.u.arr,subs,H_INSERT);
	pushexp(*symdataptr(s));
}

void
i_arraypush(void)
{
	Datum d;
	Datum subs;
	Datum darr;

	popinto(subs);
	popinto(darr);
	expectarr(darr,subs,"before subscript");

	if ( isnoval(subs) )
		execerror("undefined values can't be used as subscripts");

	/* get the symbol for the array element */
	d.u.sym = arraysym(darr.u.arr,subs,H_INSERT);
	d.type = D_SYM;

	pushm(d);
}

void
i_incond(void)
{
	Datum d1, d2;
	int n;

	popinto(d2);
	popinto(d1);
	if ( d2.type == D_PHR && d1.type == D_PHR )
		n = phrinphr(d1,d2);
	else if ( d2.type == D_ARR )
		n = (arraysym(d2.u.arr,d1,H_LOOK) != NULL);
	else
		execerror("the \"in\" operator only works on an array or phrase");
	pushnum(n);
}

void
startclass(Symbolp sp)
{
	startdef(sp);
	Inclass++;
}

void
endclass(Symbolp sp)
{
	Inclass--;
	enddef(sp);
}

void
startdef(register Symbolp sp)
{
	Datum *dp;

	Indef++;
	if ( (sp->flags & S_READONLY) != 0 )
		execerror("Can't redefine a readonly function (%s)",symname(sp));
	sp->stype = VAR;
	dp = symdataptr(sp);
	if ( dp == NULL )
		execerror("Unexpected dp==NULL in startdef for (%s)",symname(sp));
	*dp = codepdatum((Codep)0);
	newcontext(sp,29);	/* no good reason for size of 29 */
	/* Start a new code segment */
	pushiseg();
}

/* put function in symbol table */
void
enddef(register Symbolp sp)
{
	Codep cp;

	cp = popiseg();

	symdataptr(sp)->u.codep = cp;

	sp->stype = VAR;

	/* For user-defined functions, the first Inst is 0. */
	put_bltincode(0,cp);

	Indef--;
	popcontext();
}

/* Call a function.  Assumes function, obj, and arguments are already */
/* pushed onto the Stack. */
void
callfuncd(Symbolp s)
{
	int npassed, nlocals, varsize, bi, needed;
	Datum d, funcd, dnpassed;
	Datum *objdp, *realobjdp, *methdp, *dp;
	Codep cp;
	Unchar *tp = NULL;
	Symstr meth;

	/* THIS ENTIRE FUNCTION IS A HOT SPOT.   AWKWARD CODING IS DUE */
	/* TO OPTIMIZATION. */

	popinto(dnpassed);
	npassed = numval(dnpassed);

	dp = Stackp - PREARGSIZE - npassed;
	funcd = *(dp+FRAME_PREARG_FUNC_OFFSET);
	realobjdp = dp+FRAME_PREARG_REALOBJ_OFFSET;
	objdp = dp+FRAME_PREARG_OBJ_OFFSET;
	methdp = dp+FRAME_PREARG_METHOD_OFFSET;

	if ( realobjdp->type != objdp->type ) { /* quicker: 1 test vs. 2 */
		if ( realobjdp->type != D_OBJ )
			execerror("callfuncd got non-object value for realobj!?\n");
		if ( objdp->type != D_OBJ )
			execerror("callfuncd got non-object value for obj!?\n");
	}
	if ( methdp->type != D_STR )
		execerror("callfuncd got non-string method!?\n");
	meth = methdp->u.str;

	if ( funcd.type != D_CODEP ) {	/* quicker, 1 test in normal case */
		/* If the value on the stack isn't a defined, then we look at */
		/* the current symbol value (if s is given) to see if its value */
		/* has been updated. */
		if ( isnoval(funcd) ) {
			if ( s )
				funcd = *symdataptr(s);
			if ( isnoval(funcd) ) {
				char *sn = symname(s);
				sprintf(Msg1,"Attempt to call an undefined function");
				if ( s != NULL )
					sprintf(strend(Msg1)," named '%s'",sn);
				if ( strcmp(sn,"keyrc") == 0 ) {
					mdep_popup("Fatal error: couldn't find keyrc!\nYou should cd to the bin directory,\nor add the bin directory to your PATH");
				}
				execerror(Msg1);
			}
		}
		if ( funcd.type != D_CODEP )
			execerror("Expected function value, got %s",atypestr(funcd.type));
	}

	cp = funcd.u.codep;
	if ( cp == NULL )
		execerror("Attempt to invoke an undefined function!?");

	bi = BLTINOF(cp);
	if ( bi != 0 ) {	/* if it's a built-in function */

		nlocals = 0;

		/* See if the stack needs to be expanded. */
		/* The extra 4 here is for paranoia */
		needed = FRAMEHEADER+4;
		if ( (Stackp+needed) >= Stackend ) {

			expandstackatleast(T,needed);

			/* Update values that need it, after expanding stack */
			dp = Stackp - PREARGSIZE - npassed;
			realobjdp = dp+FRAME_PREARG_REALOBJ_OFFSET;
			objdp = dp+FRAME_PREARG_OBJ_OFFSET;
			/* no need to update methdp, it isn't used below */
		}
	}
	else {
		int n, nparams;
		tp = cp;

		/* For user-defined funcs, # of parameters is the 2nd code */
		(void)SCAN_BLTINCODE(tp);
		nparams = SCAN_NUMCODE(tp);

		SKIP_SYMCODE(tp);   /* skip over 3rd code (symbol) */

		/* and # of locals is the 4th code */
		nlocals = SCAN_NUMCODE(tp);

		/* Be careful here - tp is assumed to retain it's value
		 * until it's used again down in the setpc() call at the
		 * very end of this function! */

		/* See if the stack needs to be expanded. */
		/* The extra 4 here is for paranoia */
		needed = nparams+nlocals+FRAMEHEADER+4;
		if ( (Stackp+needed) >= Stackend ) {

			expandstackatleast(T,needed);

			/* Update values that need it, after expanding stack */
			dp = Stackp - PREARGSIZE - npassed;
			realobjdp = dp+FRAME_PREARG_REALOBJ_OFFSET;
			objdp = dp+FRAME_PREARG_OBJ_OFFSET;
			/* no need to update methdp, it isn't used below */
		}

		while ( npassed < nparams ) {
			pushnoinc_nochk(Noval);
			npassed++;
		}
		/* expand Stack to handle local vars */
		for ( n=0; n<nlocals; n++ ) {
			pushnoinc_nochk(Noval);
		}
	}

	/* Save frame header on stack: */
	/* 	linenum, fname, f, Pc, realobj, obj, method, */
	/* 	npassed, varsize, stackframe */

	pushnum_nochk(T->linenum);

	pushexp_nochk(strdatum(T->filename));

	d.type = D_CODEP;
	d.u.codep = cp;

	pushfunc_nochk(d);

	d.u.codep = Pc;
	pushfunc_nochk(d);

	d.type = D_OBJ;
	d.u.obj = T->realobj;
	pushexp_nochk(d);	/* saving OLD realobj */

	d.u.obj = T->obj;
	pushexp_nochk(d);	/* saving OLD obj */

	pushexp_nochk(strdatum(T->method));	/* saving OLD method */

	pushnum_nochk(npassed);

	varsize = npassed + nlocals;
	pushnum_nochk(varsize);

	d.type = D_FRM;
	d.u.frm = T->stackframe;
	pushexp_nochk(d);

	T->stackframe = Stackp - 1;
	T->arg0 = T->stackframe - FRAMEHEADER - varsize;
	T->realobj = realobjdp->u.obj;
	T->obj = objdp->u.obj;
	T->method = meth;

	if ( *Linetrace > 1 ) {
		char *ipf = ipfuncname(funcd.u.codep);
		eprint("Calling function: %s  Pc=0x%" KEY_PRIxPTR "\n",ipf==NULL?"(NULL?)":ipf, (KEY_PRIxPTR_TYPE)T->pc);
	}

	if ( bi != 0 ) {
		if (bi > 127) {
			eprint("Internal error: bi=%d\n", bi);
		}
		/* it's a built-in function - execute it right away */
		BLTINFUNC f = Bltinfuncs[bi];
		(*(f))(npassed);
	}
	else {
		/* For user-defined function, just set Pc to start it up */
		setpc(tp);
	}
}

#ifdef OLDSTUFF
void
chkstk(void)
{
	Datum *dp = T->stackframe;
	if( dp != NULL ) {
		Datum *dp2 = dp->u.frm;
		if ( dp2!=NULL && (long)dp2 < 1000 ) {
			eprint("Hey, T->stackframe->u.frm = %ld  dp=%ld  T=%ld\n",
				dp2,dp,T);
			abort();
		}
	}
}

void
prtstk(void)
{
	Datum *dp = T->stackframe;
	Datum *dp2, *dp3, *dp4;
	if( dp != NULL ) {
		dp2 = dp->u.frm;
		eprint("T=%ld T->stackframe=%ld ->u.frm=%ld ",
			T,dp,dp2);
		if ( dp2 != NULL ) {
			dp3 = dp2->u.frm;
			eprint("  dp3=%ld",dp3);
			if ( dp3 != NULL ) {
				dp4 = dp3->u.frm;
				eprint("    dp4=%ld",dp4);
			}
		}
		eprint("\n");
	}
}
#endif

void
ret(Datum retd)
{
	Datum *tstackframe;
	Datum *savedframe;
	Codep savedpc;
	Kobjectp savedobj, savedrealobj;
	Symstr savedmethod;
	int n, nlocals, npassed, varsize;
	Datum d;
	long savedlnum;
	char *savedfname;

	tstackframe = T->stackframe;
	if ( tstackframe != (Stackp-1) ) {
	    if ( tstackframe < (Stackp-1) ) {
		if ( numval(*(Stackp-1)) == FORINJUNK ) {
			/* This code is triggered when we've done a */
			/* "return()" out of a "for(var in xxx)" loop. */
			i_forinend();
		}
		else {
			/* Otherwise, if there's extra junk left on the */
			/* stack, it's an internal error. */
			tprint("Internal error, extra stuff on stack!?\n");
			while ( tstackframe < (Stackp-1) ) {
				popinto(d);
			tprint("d=");
			prdatum(d,(STRFUNC)eprint,1);
			tprint("\n");
			}
		}
	    }
	    else { /* i.e. ( tstackframe > (Stackp-1) ) */
		execerror("Return from function finds bad stack!");
	    }
	}

	savedframe = tstackframe->u.frm;
	npassed = (int) ((tstackframe - FRAME_NPASSED_OFFSET)->u.val);
	varsize = (int) ((tstackframe - FRAME_VARSIZE_OFFSET)->u.val);
	nlocals = varsize - npassed;
	savedpc = (tstackframe - FRAME_PC_OFFSET)->u.codep;
	savedrealobj = (tstackframe - FRAME_REALOBJ_OFFSET)->u.obj;
	savedobj = (tstackframe - FRAME_OBJ_OFFSET)->u.obj;
	savedmethod = (tstackframe - FRAME_METHOD_OFFSET)->u.str;

	savedfname = (tstackframe - FRAME_FNAME_OFFSET)->u.str;
	savedlnum = (tstackframe - FRAME_LNUM_OFFSET)->u.val;

	/* adjust reference counts on passed and local vars */
	for ( n=0; n<npassed; n++ ) {
		Datum d2;
		d2 = ARG(n);
		decruse(d2);
	}
	for ( n=0; n<nlocals; n++ ) {
		Datum d2;
		d2 = (*(T->stackframe-FRAMEHEADER-(n)));
		decruse(d2);
	}
	Stackp = tstackframe-varsize-FRAMEHEADER-PREARGSIZE;

	/* Restore previous values */
	T->stackframe = savedframe;
	T->realobj = savedrealobj;
	T->obj = savedobj;
	T->method = savedmethod;
	T->linenum = savedlnum;
	T->filename = savedfname;

	redoarg0(T);
	pushm(retd);
	setpc(savedpc);
}

void
redoarg0(Ktaskp t)
{
	register Datum *tstackframe = t->stackframe;

	if ( tstackframe )
		t->arg0 = arg0_of_frame(tstackframe);
	else
		t->arg0 = NULL;
}

Datum *
symdataptr(Symbolp s)
{
	Datum *sf;
	int sp = s->stackpos;

	/* handle unsigned characters and broken compilers */
	if ( sp > 127 )
		sp -= 256;
	
	if ( sp == 0 )		/* it's a global var */
		return &(s->sd);

	if ( sp > 0 )		/* it's a parameter var */
		return T->arg0 + sp - 1;

	/* stackpos<0 , it's a local var */

	sf = T->stackframe;
	if ( sf == NULL )
		execerror("Internal error - stackframe NULL, sym=%s\n",symname(s));
	return sf - FRAMEHEADER + sp + 1;
}

void
i_divcode(void)
{
	Datum d1, d2;

	popinto(d2);
	popinto(d1);
	pushexp(ddiv(d1,d2));
}

void
i_par(void)
{
	Datum d1, d2;

	popinto(d2);
	popinto(d1);
	pushexp(dpar(d1,d2));
}

void
i_amp(void)
{
	Datum d1, d2;

	popinto(d2);
	popinto(d1);
	pushexp(damp(d1,d2));
}

Datum
dlshift(Datum d1,Datum d2)
{
	Datum r;
	/* do not merge these statements - bug in MSC 7.00 */
	long v1 = numval(d1);
	int v2 = (int)numval(d2);
	r = numdatum( v1 << v2 );
	return r;
}

Datum
drightshift(Datum d1,Datum d2)
{
	Datum r;
	/* do not merge these statements - bug in MSC 7.00 */
	long v1 = numval(d1);
	int v2 = (int)numval(d2);
	r = numdatum( v1 >> v2 );
	return r;
}

void
i_lshift(void)
{
	Datum d1, d2;

	popinto(d2);
	popinto(d1);
	pushexp(dlshift(d1,d2));
}

void
i_rightshift(void)
{
	Datum d1, d2;

	popinto(d2);
	popinto(d1);
	pushexp(drightshift(d1,d2));
}

void
i_negate(void)
{
	Datum d, t;

	popinto(d);
	switch ( d.type ) {
	case D_NUM:
		d.u.val = -(d.u.val);
		break;
	case D_DBL:
		d.u.dbl = -(d.u.dbl);
		break;
	default:
		/* don't merge these - lint says eval order is undefined */
		t = numdatum( -numval(d) );
		d = t;
		break;
	}
	pushm(d);
}

void
i_tilda(void)
{
	Datum d;
	long l;

	popinto(d);
	l = numval(d);
	d = numdatum( (long) ( ~l ) );
	pushm(d);
}

void
i_lt(void)
{
	Datum d1, d2;
	popinto(d2); popinto(d1);
	pushnum(dcompare(d1,d2) < 0);
}
void
i_gt(void)
{
	Datum d1, d2;
	popinto(d2); popinto(d1);
	pushnum(dcompare(d1,d2) > 0);
}
void
i_le(void)
{
	Datum d1, d2;
	popinto(d2); popinto(d1);
	pushnum(dcompare(d1,d2) <= 0);
}
void
i_ge(void)
{
	Datum d1, d2;
	popinto(d2); popinto(d1);
	pushnum(dcompare(d1,d2) >= 0);
}
void
i_ne(void)
{
	Datum d1, d2;
	popinto(d2); popinto(d1);
	pushnum(dcompare(d1,d2) != 0);
}
void
i_eq(void)
{
	Datum d1, d2;
	popinto(d2); popinto(d1);
	pushnum(dcompare(d1,d2) == 0);
}

void
i_regexeq(void)
{
	Datum d1, d2;

	popinto(d2);
	popinto(d1);
	if ( d1.type != D_STR || d2.type != D_STR )
		execerror("Regular expression matching requires string operands, but got %s (%s) and %s (%s)!",atypestr(d1.type),datumstr(d1),atypestr(d2.type),datumstr(d2));
	if ( myre_comp(d2.u.str) )
		execerror("Error in regular expression: %s",d2.u.str);
	if ( myre_exec(d1.u.str) )
		d1 = numdatum(1L);
	else
		d1 = numdatum(0L);
	pushm(d1);

}

int
dcompare(Datum d1,Datum d2)
{
	register int n;

	if ( d1.type == D_NUM && d2.type == D_NUM ) {

		/* Uninitialized values look like integers, and comparisons */
		/* with Uninitialized values are either == or != */
		if ( d1.u.val==Noval.u.val || d2.u.val==Noval.u.val ) {
			execerror("Can't compare undefined values!?");
			/* used to be: */
			/* return (d1.u.val==d2.u.val)?0:1; */
		}
			
		if ( d1.u.val > d2.u.val )
			n = 1;
		else if ( d1.u.val < d2.u.val )
			n = -1;
		else
			n = 0;
	}
	else if ( d1.type == D_STR && d2.type == D_STR ) {
		if ( d1.u.str == d2.u.str )
			n = 0;
		else {
			/* an ASCII comparison, don't use pointers */
			n = strcmp(d1.u.str,d2.u.str);
		}
	}
	else if ( d1.type == D_PHR && d2.type == D_PHR ) {
		n = phrcmp(d1.u.phr,d2.u.phr);
	}
	else if ( d1.type == D_OBJ && d2.type == D_OBJ ) {
		if ( d1.u.obj->id > d2.u.obj->id )
			n = 1;
		else if ( d1.u.obj->id < d2.u.obj->id )
			n = -1;
		else
			n = 0;
	}
	else if ( d1.type == D_CODEP && d2.type == D_CODEP ) {
		if ( d1.u.codep == d2.u.codep )
			n = 0;
		else
			n = 1;
	}
	else if ( isnoval(d1) || isnoval(d2) ) {
		return (isnoval(d1) == isnoval(d2)?0:1);
	}
	else if ( d1.type == D_DBL || d2.type == D_DBL ) {
		double dbl1 = dblval(d1);
		double dbl2 = dblval(d2);
		if ( dbl1 > dbl2 )
			n = 1;
		else if ( dbl1 < dbl2 )
			n = -1;
		else
			n = 0;
	}
	else if ( d1.type == D_ARR || d2.type == D_ARR ) {
		if ( d1.type != d2.type )
			n = 1;
		else
			n = (d1.u.arr!=d2.u.arr);
	}
	else {
		long lng1, lng2;

		/* numval() is normally illegal on arrays.  We want */
		/* comparisons of arrays with other things to work, */
		/* hence this hack. */
		if ( d1.type == D_ARR || d1.type == D_OBJ )
			d1 = Nullval;
		if ( d2.type == D_ARR || d2.type == D_OBJ )
			d2 = Nullval;
		lng1 = numval(d1);
		lng2 = numval(d2);
		if ( lng1 > lng2 )
			n = 1;
		else if ( lng1 < lng2 )
			n = -1;
		else
			n = 0;
	}

	return n;
}

void
i_and1(void)
{
	Datum d;
	Codep endi;

	endi = use_ipcode();
	popinto(d);
	/* skip second half if possible */
	if ( numval(d) == 0 ) {
		pushnum(0);
		setpc(endi);
	}
}

void
i_or1(void)
{
	Datum d;
	Codep endi;

	endi = use_ipcode();
	popinto(d);
	/* skip second half if possible */
	if ( numval(d) != 0 ) {
		pushnum(1);
		setpc(endi);
	}
}

void
i_not(void)
{
	Datum d;
	popinto(d);
	d.u.val = (long)(numval(d) == 0);
	d.type = D_NUM;
	pushm(d);
}

void
prdatum(Datum d,STRFUNC outfunc,int quotes)
{
	Datum *alist;
	int asize, n;

	if ( isnoval(d) ) {
		/* was: execerror("Attempt to print Uninitialized value!?"); */
		(*outfunc)("<Uninitialized>");
		return;
	}

	switch(d.type){
	case D_NUM:
		(void) prlongto(d.u.val,Msg1);
		(*outfunc)(Msg1);
		break;
	case D_STR:
		if ( ! quotes )
			(*outfunc)(d.u.str);
		else {
			int c;
			char buf[3];
			char *p;

			(*outfunc)("\"");
			for ( p=d.u.str; (c=(*p)) != 0; p++ ) {
				switch(c){
				case '\n': strcpy(buf,"\\n"); break;
				case '\t': strcpy(buf,"\\t"); break;
				case '\b': strcpy(buf,"\\b"); break;
				case '\r': strcpy(buf,"\\r"); break;
				case '\f': strcpy(buf,"\\f"); break;
				default  : buf[0] = c; buf[1] = 0; break;
				}
				(*outfunc)(buf);
			}
			(*outfunc)("\"");
		}
		break;
	case D_PHR:
		if ( d.u.phr == NULL )
			execerror("NULL phr?");
		phprint(outfunc,d.u.phr,(*Printsplit)!=0);
		break;
	case D_SYM:
		(*outfunc)(symname(d.u.sym));
		(*outfunc)("{}");
		break;
	case D_ARR:
		(*outfunc)("[");
		alist = arrlist(d.u.arr,&asize,1);
		for ( n=0; n<asize; n++ ) {
			Symbol *as = arraysym(d.u.arr,alist[n],H_LOOK);
			if ( as == NULL )
				execerror("Hey, as==NULL, impossible!");
			if ( n != 0 )
				(*outfunc)(",");
			prdatum(as->name,outfunc,1);
			(*outfunc)("=");
			prdatum(*symdataptr(as),outfunc,1);
		}
		kfree(alist);
		(*outfunc)("]");
		break;
	case D_CODEP:
		(*outfunc)("()");
		break;
	case D_DBL:
		sprintf(Msg1,"%g",(double)d.u.dbl);
		(*outfunc)(Msg1);
		break;
	case D_FRM:
		(*outfunc)("(frame)");
		break;
	case D_OBJ:
		if ( d.u.obj == NULL )
			(void) (*outfunc)("$NULL");
		else {
			(*outfunc)("$");
			(void) prlongto(d.u.obj->id,Msg1);
			(*outfunc)(Msg1);
		}
		break;
	default:
		(*outfunc)("???");
		break;
	}
}

void
i_noop(void)
{
}

void
prstack(Datum *d)
{
	int n;

	if ( Stack==NULL || Stackp==NULL ) {
		printf("Stack is not initialized!\n");
		return;
	}
	if ( d == NULL )
		d = Stackp - 1;
	if ( d < Stack ) {
		printf("Stack is EMPTY!\n");
		return;
	}
#define PRSTACKLIMIT 20
	for ( n=0; n<PRSTACKLIMIT && d >= Stack; d--,n++ ) {
		char *s1, *s2;
		if ( isnoval(*d) ) {
			s1 = "<Uninitialized>";
			s2 = "";
		}
		else {
			switch( (*d).type ) {
			case D_NUM: s1 = "D_NUM"; break;
			case D_STR: s1 = "D_STR"; break;
			case D_PHR: s1 = "D_PHR"; break;
			case D_SYM: s1 = "D_SYM"; break;
			case D_DBL: s1 = "D_DBL"; break;
			case D_ARR: s1 = "D_ARR"; break;
			case D_CODEP: s1 = "D_CODEP"; break;
			case D_FRM: s1 = "D_FRM"; break;
			case D_OBJ: s1 = "D_OBJ"; break;
			default: s1 = "D_???"; break;
			}
			s2 = datumstr(*d);
		}
		sprintf(Msg1,"tid=%ld Stack[top-%d] (%" KEY_PRIdPTR ") = %s %s",T->tid,n,( KEY_PRIdPTR_TYPE )(d),s1,s2);
		if ( (*d).type == D_PHR ) {
			sprintf(strend(Msg1)," %" KEY_PRIdPTR " used=%d tobe=%d",( KEY_PRIdPTR_TYPE )((*d).u.phr),(*d).u.phr->p_used,(*d).u.phr->p_tobe);
		}
		if ( (*d).type == D_CODEP )
			sprintf(strend(Msg1)," fnc=%" KEY_PRIdPTR "",( KEY_PRIdPTR_TYPE )((*d).u.codep));
		eprint(Msg1);
	}
	if ( n >= PRSTACKLIMIT ) eprint("STACK LIST TRUNCATED!!!\n");
}
