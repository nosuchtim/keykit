%{
/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#define OVERLAY3
#define YYDEBUG 1
#define MYYYDEBUG 1

/* to help avoid multiple <malloc> includes, since yacc inserts one */
#define DONTINCLUDEkmalloc

#include "key.h"
#define code2(a,b) code(a),code(b)
#define code3(a,b,c) code(a),code(b),code(c)
#define code4(a,b,c,d) code(a),code(b),code(c),code(d)
#define code6(a,b,c,d,e,f) code(a),code(b),code(c),code(d),code(e),code(f)

#define STUFFCODE(t,i,v) *ptincode(t,i)=v

static int Sawinit = 0;
static char* Methtemp;

%}
%union {
	Symbolp	sym;	/* symbol table pointer */
	Instnodep in;	/* machine instruction */
	int	num;	/* number of arguments */
	long	val;	/* numeric constant */
	DBLTYPE	dbl;	/* floating constant */
	char	*str;	/* string constant */
	Phrasep	phr;	/* phrase constant */
}
%token	<sym>	VAR UNDEF MACRO TOGLOBSYM QMARK2 DOLLAR2 WHILE DOTDOTDOT
%token	<sym>	IF ELSE FOR SYM_IN BEINGREAD EVAL BREAK CONTINUE TASK
%token	<sym>	SYM_DELETE UNDEFINE RETURN FUNC DEFINED READONLY ONCHANGE GLOBALDEC
%token	<sym>	CLASS METHOD KW_NEW NARGS TYPEOF XY
%token	<sym>	DUR VOL TIME CHAN PITCH LENGTH NUMBER TYPE ATTRIB FLAGS VARG PORT
%token	<phr>	PHRASE
%token	<str>	STRING NAME
%token	<val>	INTEGER OBJECT
%token	<dbl>	DOUBLE
%token	<num>	PLUSEQ MINUSEQ MULEQ DIVEQ AMPEQ INC DEC
%token	<num>	POSTINC POSTDEC OREQ XOREQ RSHIFTEQ LSHIFTEQ
%type	<in>	expr stmt stmts nosemi optstmt funcstart stmtnv
%type	<in>	tcond tfcond optrelx forin1 forin2 forinend end goto
%type	<in>	select1 select2 select3 and or equals
%type	<in>	prefunc1 prefunc3 preobj method arglist narglist
%type	<sym>	uniqvar var dottype globvar uniqm
%type	<num>	args prmlist prms arrlist
%type	<str>	methname
%right	'=' PLUSEQ MINUSEQ MULEQ DIVEQ AMPEQ OREQ XOREQ RSHIFTEQ LSHIFTEQ
%right	'?'
%right	':'
%left	OR
%left	AND
%left	'|'
%left	'^'
%left	'&'
%nonassoc	GT GE LT LE EQ NE REGEXEQ
%left	LSHIFT RSHIFT
%left	'+' '-'
%left	'*' '/'
%left	UNARYMINUS BANG '~'
%left	'%' '.'
%left	INC DEC
%%
list	: 			{
				code2(funcinst(I_STRINGPUSH), strinst(Infile));
				code2(funcinst(I_CONSTANT),numinst(Lineno));
				code(funcinst(I_PUSHINFO));
				}
		stmts		{
				code(funcinst(I_POPINFO));
				code(Stopcode);
				}
	;
stmts	: /* nothing */		{ $$ = futureinstnode(); }
	| stmt stmts
	;
optstmt : /* nothing */		{ $$ = futureinstnode(); }
	| nosemi
	;
stmt	: ';'			{ $$ = futureinstnode(); }
	| nosemi
	| nosemi ';'
	; 
nosemi	: stmtnv
	| expr		{ code(funcinst(I_POPIGNORE)); }
stmtnv	: RETURN		{ yyerror("'return' statement needs parentheses!");
			  	YYABORT;
				/*NOTREACHED*/ }
	| RETURN '(' ')'	{ defnonly("return");
				  $$ = code(funcinst(I_RETURN)); }
	| RETURN '(' expr ')'	{ defnonly("return");
				  $$=$3; code(funcinst(I_RETURNV)); }
	| BREAK			{
				looponly("break");
				$$ = code2(numinst(IBREAK),Stopcode);
				looppatch($$);
				}
	| CONTINUE		{
				looponly("continue");
				$$ = code2(numinst(ICONTINUE),Stopcode);
				looppatch($$);
				}
	| GLOBALDEC { $$=futureinstnode(); Globaldecl=1; } globlist {Globaldecl=0;}
	;
expr	: '{' stmts '}'		{ $$ = $2; fakeval(); }

	| SYM_DELETE expr
		{
		  if ( recodedelete($2,code(funcinst(I_DELETEIT))) != 0 ) {
			yyerror("Bad 'delete' statement!");
			YYABORT;
		  }
		  $$ = $2;
		fakeval();
		}
	| READONLY var {
		$$ = code2(funcinst(I_READONLYIT),syminst($2));
		fakeval();
		}
	| ONCHANGE '(' var ',' expr ')' {
		$$ = code2(funcinst(I_ONCHANGEIT),syminst($3));
		fakeval();
		}
	| WHILE {loopstart();} '(' expr tcond ')' stmt goto end {
		STUFFCODE($5,1, instnodeinst($9));	/* cond fails */
		STUFFCODE($8,1, instnodeinst($4));
		$$ = $4;
		loopend($4,$9);
		fakeval();
		}

	| FOR '(' optstmt {loopstart();} ';' 
		optrelx tfcond ';' optstmt goto ')' stmt goto end {

		STUFFCODE($7,1, instnodeinst($12));	/* cond succeeds */
		STUFFCODE($7,3, instnodeinst($14));	/* cond fails */
		STUFFCODE($10,1, instnodeinst($6));
		STUFFCODE($13,1, instnodeinst($9));
		$$ = $3;
		loopend($9,$14);
		fakeval();
		}

	| FOR '(' var SYM_IN {loopstart();} expr forin1 forin2 ')' stmt goto forinend {
		STUFFCODE($7,1, instnodeinst($12));
		STUFFCODE($7,2, syminst($3));
		STUFFCODE($11,1, instnodeinst($8));
		$$ = $6;
		loopend($8,$12);
		fakeval();
		}

	| IF '(' expr tcond ')' stmt end {		/* else-less if */
		STUFFCODE($4,1, instnodeinst($7));	/* cond fails */
		$$ = $3;
		fakeval();
		}
	| IF '(' expr tcond ')' stmt ELSE goto stmt end { /* if with else */
		STUFFCODE($4,1, instnodeinst($9));	/* cond fails */
		STUFFCODE($8,1, instnodeinst($10));
		$$ = $3;
		fakeval();
		}
	| KW_NEW var '(' prefunc3
				{ code2(funcinst(I_CONSTANT),numinst(0)); }
		narglist ')'	
				{
				Symbolp s = $2;
				if ( !isglobal(s) && !(s->flags & S_SEEN))
					s = forceglobal(s);
				STUFFCODE($4,1, syminst(s));
				code2(funcinst(I_CALLFUNC),syminst(s));
				$$ = $4;
				}
	| KW_NEW '(' prefunc3 expr ')' var '(' narglist ')'	
				{
				Symbolp s = $6;
				if ( !isglobal(s) && !(s->flags & S_SEEN))
					s = forceglobal(s);
				STUFFCODE($3,1, syminst(s));
				code2(funcinst(I_CALLFUNC),syminst(s));
				$$ = $3;
				}
	| UNDEFINE var {
		$$ = code2(funcinst(I_UNDEFINE),syminst($2));
		fakeval();
		}
	| UNDEFINE '(' var ')' {
		$$ = code2(funcinst(I_UNDEFINE),syminst($3));
		fakeval();
		}
	| '[' { $$ = futureinstnode(); } arrlist ']' {
		code2(funcinst(I_ARRAY),numinst($3));
		$$ = $2;
		}
	| INTEGER    { $$ = code2(funcinst(I_CONSTANT), numinst($1)); }
	| DOUBLE     { $$ = code2(funcinst(I_DBLPUSH), dblinst($1)); }
	| STRING     { $$ = code2(funcinst(I_STRINGPUSH), strinst($1)); }
	| PHRASE     { $$ = code2(funcinst(I_PHRASEPUSH), phrinst($1)); }
	| var	     { $$ = code2(funcinst(I_VAREVAL), syminst($1)); }
	| QMARK2     { $$ = code(funcinst(I_QMARK));
		       if ( Inselect == 0 ) {
				yyerror("\"?\" is only allowed in select expressions!");
				YYABORT;
				/*NOTREACHED*/
		       }
		     }
	| DOUBLE dottype	{ sprintf(Msg1,
	"Floating point number before '%s'?  Use parens around integer!", dotstr($2->stype));
				  yyerror(Msg1);
				  YYABORT;
				  /*NOTREACHED*/
				}
	| expr '[' expr ']'	{ code(funcinst(I_ARREND)); }
	| expr '{' select1 select2 expr select3 '}' end {
			STUFFCODE($4,1, instnodeinst($8));
			STUFFCODE($6,1, instnodeinst($4));
			Inselect--;
			}
	| expr '?' tcond expr goto ':' expr end {
			STUFFCODE($3,1, instnodeinst($7));	/* false */
			STUFFCODE($5,1, instnodeinst($8));
			}
	| '(' expr ')'		{ $$ = $2; }
	| DEFINED '(' var ')'	{ $$ = code2(funcinst(I_DEFINED),syminst($3)); }
	| DEFINED '(' '$' ')'	{ $$ = code(funcinst(I_CURROBJDEFINED)); }
	| DEFINED '(' DOLLAR2 ')'  { $$ = code(funcinst(I_REALOBJDEFINED)); }
	| DEFINED '(' expr '.' method ')'	{
				code(funcinst(I_OBJDEFINED));
				$$ = $3;
				}
	| DEFINED var		{ $$ = code2(funcinst(I_DEFINED),syminst($2)); }
	| expr '%' expr	{ code(funcinst(I_MODULO)); }
	| expr '+' expr	{ code(funcinst(I_ADDCODE)); }
	| expr '-' expr	{ code(funcinst(I_SUBCODE)); }
	| expr '*' expr	{ code(funcinst(I_MULCODE)); }
	| expr '/' expr	{ code(funcinst(I_DIVCODE)); }
	| expr '|' expr	{ code(funcinst(I_PAR)); }
	| expr '&' expr	{ code(funcinst(I_AMP)); }
	| expr '^' expr	{ code(funcinst(I_XORCODE)); }
	| expr LSHIFT expr { code(funcinst(I_LSHIFT)); }
	| expr RSHIFT expr { code(funcinst(I_RIGHTSHIFT)); }
	| '-' expr   %prec UNARYMINUS   { $$=$2; code(funcinst(I_NEGATE)); }
	| '~' expr   	{ $$=$2; code(funcinst(I_TILDA)); }
	| expr GT expr		{ code(funcinst(I_GT)); }
	| expr LT expr		{ code(funcinst(I_LT)); }
	| expr GE expr		{ code(funcinst(I_GE)); }
	| expr LE expr		{ code(funcinst(I_LE)); }
	| expr EQ expr		{ code(funcinst(I_EQ)); }
	| expr REGEXEQ expr	{ code(funcinst(I_REGEXEQ)); }
	| expr NE expr		{ code(funcinst(I_NE)); }
	| BANG expr		{ code(funcinst(I_NOT)); $$=$2; }
	| expr SYM_IN expr		{ code(funcinst(I_INCOND)); }
	| expr and expr end	{ STUFFCODE($2,1, instnodeinst($4)); }
	| expr or expr end	{ STUFFCODE($2,1, instnodeinst($4)); }

	| expr equals expr	{ recodeassign ( $1, $2 ); }
	| expr INC		{ recodeassign ( $1, code(numinst(POSTINC)) );}
	| expr DEC		{ recodeassign ( $1, code(numinst(POSTDEC)) );}
	| INC expr		{ $$ = $2; recodeassign ( $2, code(numinst(INC)) );}
	| DEC expr 		{ $$ = $2; recodeassign ( $2, code(numinst(DEC)) );}
	| EVAL expr 		{ $$ = $2; code(funcinst(I_EVAL)); }
	| '$' 			{ $$ = code(funcinst(I_ECURROBJEVAL)); }
	| DOLLAR2 		{ $$ = code(funcinst(I_EREALOBJEVAL)); }
	| OBJECT 		{ $$ = code2(funcinst(I_CONSTOBJEVAL),numinst($1)); }
	| expr '.' dottype	{ code2(funcinst(I_DOT),numinst($3->stype));}
	| expr '.' method	{ code(funcinst(I_OBJVAREVAL)); }
	| expr '.' method '(' preobj arglist ')' {
			code2(funcinst(I_OBJCALLFUNC),syminst(NULL));
			}
	| TASK var '(' prefunc3 arglist ')' {
				Symbolp s = $2;
				if ( !isglobal(s) && !(s->flags & S_SEEN))
					s = forceglobal(s);
				STUFFCODE($4,1, syminst(s));
				code2(funcinst(I_TASK),syminst(s));
				$$ = $4;
				}
	| TASK expr '(' arglist ')' {
			$$=$2; code2(funcinst(I_TASK),syminst(NULL));
			}
	| TASK expr '.' method '(' preobj arglist ')' {
			$$=$2; code2(funcinst(I_TASK),syminst(NULL));
			}
	| var '(' prefunc3 arglist ')'	{
				Symbolp s = $1;
				if ( !isglobal(s) && !(s->flags & S_SEEN))
					s = forceglobal(s);
				STUFFCODE($3,1, syminst(s));
				code2(funcinst(I_CALLFUNC),syminst(s));
				$$=$3;
				}
	| expr '(' prefunc1 arglist ')'	{
			code2(funcinst(I_CALLFUNC),syminst(NULL));
			}
	| NARGS '(' ')'	{
			$$ = code(funcinst(I_NARGS));
			}
	| TYPEOF '(' expr ')'	{
			code(funcinst(I_TYPEOF));
			$$ = $3;
			}
	| XY '(' expr ',' expr ')'	{
			code(funcinst(I_XY2));
			$$ = $3;
			}
	| XY '(' expr ',' expr ',' expr ',' expr ')'	{
			code(funcinst(I_XY4));
			$$ = $3;
			}
	| GLOBALDEC '(' { Globaldecl=1; } globvar {Globaldecl=0;} ')' {
			$$ = code2(funcinst(I_VAREVAL),syminst($4));
			}
	| FUNC '(' expr ')'	{ $$ = code(funcinst(I_FUNCNAMED)); }
	| FUNC var
				{startdef($2);}
		funcstart '('
				{ if (startparams()) YYABORT; }
		prmlist
				{ endparams($4,$7,$2); }
		')' '{' stmts '}'	{
				code(funcinst(I_RETURN));
				patchlocals($4);
				enddef($2);
				$$ = code2(funcinst(I_VAREVAL), syminst($2));
				}
	| FUNC var
				{startdef($2);}
		funcstart
				{ endparams($4,0,$2); /* 0 parameters */ }
		'{' stmts '}'	{
				code(funcinst(I_RETURN));
				patchlocals($4);
				enddef($2);
				$$ = code2(funcinst(I_VAREVAL), syminst($2));
				}
	| FUNC uniqvar
				{startdef($2);}
		funcstart '('
				{ if (startparams()) YYABORT; }
		prmlist
				{ endparams($4,$7,$2); }
		')' '{' stmts '}'	{
				code(funcinst(I_RETURN));
				patchlocals($4);
				enddef($2);
				$$ = code2(funcinst(I_VAREVAL), syminst($2));
				}
	| FUNC uniqvar
				{startdef($2);}
		funcstart
				{ endparams($4,0,$2);	/* 0 parameters */ }
		'{' stmts '}'	{
				code(funcinst(I_RETURN));
				patchlocals($4);
				enddef($2);
				$$ = code2(funcinst(I_VAREVAL), syminst($2));
				}
	| CLASS var
				{
				startclass($2);
				}
		funcstart
				{
				endparams($4,1,$2); /* 1 parameter, the o */
				/* Now start the code of the class function. */
				/* The number we push on the stack here is */
				/* a flag so I_CLASSINIT knows where the */
				/* method names end.  */
				code2(funcinst(I_STRINGPUSH),strinst($2->name.u.str));
				Sawinit = 0;
				}
		'{' methdefs '}'	{
				if ( ! Sawinit )
					tprint("Warning, no 'init' method in class definition!\n");

				/* create code that will init a new object */

				code(funcinst(I_CLASSINIT));

				/* create code that calls the object's init */
				/* method.  Note that this assumes that */
				/* i_classinit() has already pushed the */
				/* function value, and the obj/obj/method */
				/* values onto the stack. */

				code2(funcinst(I_DOTDOTARG),numinst(0));
				code2(funcinst(I_CALLFUNC),syminst(NULL));
				code(funcinst(I_POPIGNORE));

				code(funcinst(I_RETURNV));
				patchlocals($4);
				endclass($2);
				$$ = futureinstnode();
				fakeval();
				}
	;
methdefs: /* nothing */
	| methdef methdefs
	;
uniqm	: /* nothing */		{ $$ = uniqvar(Methtemp); }
	;
methdef	: METHOD methname { Methtemp=$2; } uniqm
				{
				if ( strcmp($2,"init") == 0 )
					Sawinit = 1;
				startdef($4);
				}
		funcstart '('
				{ if (startparams()) YYABORT; }
		prmlist
				{ endparams($6,$9,$4); }
		')' '{' stmts '}'	{
				code(funcinst(I_RETURN));
				patchlocals($6);
				enddef($4);

				/* Push the method name and function value, */
				/* to be retrieved by I_CLASSINIT. */
				code2(funcinst(I_STRINGPUSH),strinst($2));
				code2(funcinst(I_VAREVAL), syminst($4));
				}
	| METHOD methname { Methtemp = $2; } uniqm
				{
				if ( strcmp($2,"init") == 0 )
					Sawinit = 1;
				startdef($4);
				}
		funcstart
				{ endparams($6,0,$4); /* 0 parameters */ }
		'{' stmts '}'	{
				code(funcinst(I_RETURN));
				patchlocals($6);
				enddef($4);

				/* Push the method name and function value, */
				/* to be retrieved by I_CLASSINIT. */
				code2(funcinst(I_STRINGPUSH),strinst($2));
				code2(funcinst(I_VAREVAL), syminst($4));
				}
	;
prefunc1: /* nothing */		{ $$ = code(funcinst(I_CURROBJEVAL)); }
	;
prefunc3: /* nothing */		{
		$$ = code3(funcinst(I_VAREVAL),Stopcode,funcinst(I_CURROBJEVAL));
		}
	;
preobj	: /* nothing */		{ $$ = code(funcinst(I_OBJCALLFUNCPUSH)); }
	;
dottype	: VOL
	| DUR
	| CHAN
	| PORT
	| TIME
	| PITCH
	| LENGTH
	| TYPE
	| ATTRIB
	| FLAGS
	| NUMBER	{ if ( Inselect == 0 ) {
				yyerror("\".number\" is only allowed in select expressions!");
				YYABORT;
				/*NOTREACHED*/
			  }
			}
	;
equals	: PLUSEQ	{ $$ = code(numinst('+')); }
	| MINUSEQ	{ $$ = code(numinst('-')); }
	| MULEQ		{ $$ = code(numinst('*')); }
	| DIVEQ		{ $$ = code(numinst('/')); }
	| OREQ		{ $$ = code(numinst('|')); }
	| AMPEQ		{ $$ = code(numinst('&')); }
	| XOREQ		{ $$ = code(numinst('^')); }
	| RSHIFTEQ	{ $$ = code(numinst('>')); }
	| LSHIFTEQ	{ $$ = code(numinst('<')); }
	| '='		{ $$ = code(numinst('=')); }
	;
end	: /* nothing */	{ $$ = futureinstnode(); }
	;
goto	: /* nothing */	{ $$ = code2(funcinst(I_GOTO),Stopcode); }
	;
tcond	: /* nothing */	{ $$ = code2(funcinst(I_TCONDEVAL),Stopcode);}
	;
tfcond	: /* nothing */	{ $$ = code4(funcinst(I_FCONDEVAL),Stopcode,funcinst(I_GOTO),Stopcode);}
	;
optrelx	: /* nothing */	{ $$ = code2(funcinst(I_CONSTANT), numinst(1)); }
	| expr
	;
forin1	: /* nothing */	{ $$ = code3(funcinst(I_FORIN1),Stopcode,Stopcode); }
	;
forin2	: /* nothing */	{ $$ = code(funcinst(I_FORIN2)); }
	;
forinend: /* nothing */	{ $$ = code(funcinst(I_FORINEND)); }
	;
and	: AND		{ $$ = code2(funcinst(I_AND1),Stopcode); }
	;
or	: OR		{ $$ = code2(funcinst(I_OR1),Stopcode); }
	;
select1	: /* nothing */	{
			Inselect++;
			/* (void) makeqmark(); */
			$$=code(funcinst(I_SELECT1));
			}
	;
select2	: /* nothing */ { $$ = code2(funcinst(I_SELECT2), Stopcode); }
	;
select3	: /* nothing */ { $$ = code2(funcinst(I_SELECT3), Stopcode); }
	;
funcstart: /* nothing */	{
				/* bltin-or-0, # params, func name, # locals */
				$$ = code4(bltininst((BLTINCODE)0),
						Stopcode,Stopcode,Stopcode);
				}
uniqvar : '?'			{ $$ = uniqvar("function"); }
	;
prmlist	: /* nothing */		{ $$ = 0; }
	| prms 			{ $$ = $1; }
	| DOTDOTDOT		{ $$ = 0; }
	| prms ',' DOTDOTDOT	{ $$ = $1; }
	;
prms	: var			{ $$ = 1; }
	| prms ',' var		{ $$ = $1 + 1; }
	;
arglist	: /* nothing */		{ code2(funcinst(I_CONSTANT),numinst(0)); }
	| args			{ code2(funcinst(I_CONSTANT),numinst($1)); }
	| DOTDOTDOT		{ code2(funcinst(I_DOTDOTARG),numinst(0)); }
	| args ',' DOTDOTDOT	{ code2(funcinst(I_DOTDOTARG),numinst($1)); }
	| VARG '(' expr ')'	{ code2(funcinst(I_VARG),numinst(0)); }
	| args ',' VARG	'(' expr ')' { code2(funcinst(I_VARG),numinst($1)); }
	;
narglist: /* nothing */		{ code2(funcinst(I_CONSTANT),numinst(1)); }
	| args			{ code2(funcinst(I_CONSTANT),numinst(1+$1)); }
	| DOTDOTDOT		{ code2(funcinst(I_DOTDOTARG),numinst(1)); }
	| args ',' DOTDOTDOT	{ code2(funcinst(I_DOTDOTARG),numinst(1+$1)); }
	| VARG '(' expr ')'	{ code2(funcinst(I_VARG),numinst(1)); }
	| args ',' VARG	'(' expr ')' { code2(funcinst(I_VARG),numinst(1+$1)); }
	;
args	: expr			{ $$ = 1; }
	| args ',' expr		{ $$ = $1 + 1; }
	;
arritem	: expr '=' expr
	;
arrlist	: /* nothing */		{ $$ = 0; }
	| arritem		{ $$ = 1; }
	| arrlist ',' arritem	{ $$ = $1 + 1; }
	;
globvar	: var
	;
globlist: globvar
	| globlist ',' globvar
	;
var	: NAME		{ $$ = installvar($1); }
	| VOL		{ $$ = installvar($1->name.u.str); }
	| DUR		{ $$ = installvar($1->name.u.str); }
	| CHAN		{ $$ = installvar($1->name.u.str); }
	| PORT		{ $$ = installvar($1->name.u.str); }
	| TIME		{ $$ = installvar($1->name.u.str); }
	| PITCH		{ $$ = installvar($1->name.u.str); }
	| LENGTH	{ $$ = installvar($1->name.u.str); }
	| TYPE		{ $$ = installvar($1->name.u.str); }
	| ATTRIB	{ $$ = installvar($1->name.u.str); }
	| FLAGS		{ $$ = installvar($1->name.u.str); }
	| NUMBER	{ $$ = installvar($1->name.u.str); }
	| CLASS		{ $$ = installvar($1->name.u.str); }
	;
methname: NAME		{ $$ = $1;  }
	| SYM_DELETE	{ $$ = $1->name.u.str;  }
	| CLASS	{ $$ = $1->name.u.str;  }
	;
method	: NAME	  { $$ = code2(funcinst(I_STRINGPUSH),strinst($1));  }
	| SYM_DELETE  { $$ = code2(funcinst(I_STRINGPUSH),strinst($1->name.u.str));  }
	| CLASS	  { $$ = code2(funcinst(I_STRINGPUSH),strinst($1->name.u.str));  }
	| '(' expr ')'	{ $$ = $2; }
	;
%%

int
startparams(void)
{
	if ( Inparams ) {
		yyerror("Nested parameter lists!?!");
		return 1;
	}
	Inparams=1;
	return 0;
}

void
endparams(Instnodep codeptr,int nparams,Symbolp funcsym)
{
	Inparams = 0;
	STUFFCODE(codeptr,1, numinst(nparams));
	STUFFCODE(codeptr,2, syminst(funcsym));
	code(funcinst(I_FILENAME));
	code(strinst(Infile?uniqstr(Infile):Nullstr));
}

void
patchlocals(Instnodep codeptr)
{
	STUFFCODE(codeptr,3,numinst(Currct->localnum-1));
}

Symbolp
forceglobal(Symbolp s)
{
	Symbolp gs;
	Symstr up = symname(s);
	s->stype = TOGLOBSYM;
	gs = globalinstall(up, UNDEF);
	s->sd.u.sym = gs;
	return gs;
}

Symbolp
local2globalinstall(Symstr up)
{
	Symbolp s, s2;
	/* Add a symbol to the current local context, */
	/* which points us to the global symbol. */
	s = globalinstall(up, UNDEF);
	s2 = localinstall(up, TOGLOBSYM);
	s2->sd.u.sym = s;
	return s;
}

Symbolp
installvar(Symstr up)
{
	Symbolp s;

	if ( Inparams )
		return localinstall(up, UNDEF);

	if ((s=findsym(up,Currct->symbols)) != 0) {
		s->flags |= S_SEEN;
		if ( s->stype == TOGLOBSYM ) {
			s = s->sd.u.sym;
		}
		return s;
	}

	if ( Currct == Topct ) {
		/* we know it's not there already, so use globalinstallnew() */
		return globalinstallnew(up, UNDEF);
	}

	if ( Globaldecl != 0 )
		return local2globalinstall(up);

	/* See if it's a keyword or macro */
	if ( (s=findsym(up,Topct->symbols)) != NULL ) {
		if ( s->stype != UNDEF && s->stype != VAR )
			return s;
		if ( s->stype == VAR && s->sd.type == D_CODEP )
			return s;
	}
	/* Upper-case names are, by default, global. */
	if ( *up>='A' && *up<='Z' )
		return local2globalinstall(up);

	s = localinstall(up, UNDEF);
	return s;
}

int
yylex()
{
	register int c;
	int retval;
	int lastc = 0;
	int isdouble, nextc;
	long bmult = 1;
	long tot;

	Macrosused = 0;

    restart:
	/* Skip initial white space */
	do {
		c = yyinput();
	} while ( c == ' ' || c == '\t' || c == '\n' );

	if ( c == EOF ) {
#ifdef MYYYDEBUG
		if ( yydebug )
			printf("yylex returns 0, EOF\n");
#endif
		return(0);
	}

	Pyytext = Yytext;
	*Pyytext++ = c;

	if ( isname1char(c) ) {
		Symstr up;
		Symbolp s;

		while ((c=yyinput()) != EOF && isnamechar(c) )
			;
		yyunget(c);
		*Pyytext = '\0';

		up = uniqstr(Yytext);
		if ( (s=findsym(up,Keywords)) != NULL ) {
			retval = s->stype;
			yylval.sym = s;
			goto getout;
		}
		if ( (s=findsym(up,Macros)) != NULL ) {
			macroeval(up);
			goto restart;
		}
		yylval.str = up;
		retval = NAME;
		goto getout;
	}
	if ( c == '#' ) {
		if ( eatpound() == 0 ) {
#ifdef MYYYDEBUG
			if ( yydebug )
				printf("yylex eatpound returns 0, EOF\n");
#endif
			return(0);
		}
		goto restart;
	}
	isdouble = 0;
	if ( c == '.' ) {
		c = yyinput();
		/* allow numbers to start with . */
		if ( isdigit(c) ) {
			isdouble = 1;
			goto dblread;
		}
		if ( c == '.' ) {
			c = yyinput();
			if ( c == '.' ) {
				retval = DOTDOTDOT;
				goto getout;
			}
			execerror(".. is not valid - perhaps you meant ... ?");
		}
		yyunget(c);
		retval = '.';
		goto getout;
	}
	if ( c == '0' ) {	/* octal or hex numbers */
		tot = 0;
		if ( (c=yyinput()) == 'x' ) {			/* hex */
			while ( (c=yyinput()) != EOF ) {
				int h = hexchar(c);
				if ( h<0 )
					break;
				tot = 16 * tot + h;
			}
		}
		else if ( isdigit(c) ) {			/* octal */
			int e = 0;
			do {
				if ( c < '0' || c > '9' )
					break;
				if ( (c=='8'||c=='9') && e++ == 0 )
					eprint("Invalid octal number!\n");
				tot = 8 * tot + (c-'0');
			} while ( (c=yyinput()) != EOF );
		}
		else if ( c == '.' )
			goto foundadot;

		if ( c=='b' || c=='q' )
			bmult = ((Clicks==NULL)?(DEFCLICKS):(*Clicks));
		else
			yyunget(c);
			
		yylval.val = tot * bmult;
		retval = INTEGER;
		goto getout;
	}
	if ( isdigit(c) ) {			/* integers and floats */
	    dblread:
		for ( ; (c=yyinput()) != EOF; lastc=c ) {
			if ( isdigit(c) )
				continue;
			if ( c == '.' ) {
			    foundadot:
				/* look ahead to see if it's a float */
				nextc = yyinput();
				yyunget(nextc);
				if ( isdigit(nextc) || nextc=='e' ) {
					isdouble = 1;
					continue;
				}
				yyunget('.');
				/* a number followed by a '.' *and* then */
				/* followed by a non-digit is probably */
				/* an expression like ph%2.pitch, so we */
				/* just return the integer. */
				break;
			}
			if ( c == 'e' ) {
				isdouble = 1;
				continue;
			}
			/* An integer with a 'b' or 'q' suffix is multiplied by */
			/* the number of clicks in a quarter note. */
			if ( ! isdouble && (c=='q' || c=='b') ) {
				bmult = ((Clicks==NULL)?(DEFCLICKS):(*Clicks));
				/* and we're done */
				break;
			}
			if ( (c=='+'||c=='-') && lastc=='e' ) {
				isdouble = 1;
				continue;
			}
			yyunget(c);
			break;
		}
		*Pyytext = '\0';

		if ( isdouble ) {
			yylval.dbl = (DBLTYPE) atof(Yytext);
			retval = DOUBLE;
		}
		else {
			yylval.val = atol(Yytext) * bmult;
			retval = INTEGER;
		}
		goto getout;
	}
	if ( c == '\'' ) {
		yyunget(c);
		yylval.phr = yyphrase(yyinput);
		phincruse(yylval.phr);
		retval = PHRASE;
		goto getout;
	}
	/* strings ) */
	if ( c == '"' ) {
		int si = 0;
		int ch, n, i;

		while ( (ch=yyinput()) != '"' ) {

		    rechar:
			if ( ch == EOF )
				execerror("missing ending-quote on string");
			if ( ch == '\n' )
				execerror("Newline inside string?!");
			/* interpret \-characters */
			if ( ch == '\\' ) {
				switch ( ch=yyinput() ) {
				case '\n':
					/* escaped newlines are ignored */
					ch = yyinput();
					goto rechar;
					/* break; */
				case '0':
					/* Handle \0ddd numbers */
					for ( n=0,i=0; i<3; i++ ) {
						ch = yyinput();
						if ( ! isdigit(ch) )
							break;
						n = n*8 + ch - '0';
					}
					yyunget(ch);
					ch = n;
					break;
				case 'x':
					/* Handle \xfff numbers */
					for ( n=0,i=0; i<3; i++ ) {
						ch = hexchar(yyinput());
						if ( ch < 0 )
							break;
						n = n*16 + ch;
					}
					yyunget(ch);
					ch = n;
					break;
#ifdef OLDSTUFF
				/* use this if \xFF has only 2 chars */
				case 'x':
					{ int h1, h2;
					/* Handle \xFF numbers */
					h1 = hexchar(yyinput());
					h2 = hexchar(yyinput());
					if ( h1<0 || h2<0 ) {
						eprint("Invalid hex number!\n");
						ch = 0;
					}
					else
						ch = h1*16 + h2;
					}
					break;
#endif
				case 'b': ch ='\b'; break;
				case 'f': ch ='\f'; break;
				case 'n': ch ='\n'; break;
				case 'r': ch ='\r'; break;
				case 't': ch ='\t'; break;
				case 'v': ch ='\v'; break;
				case '"': ch ='"'; break;
				case '\'': ch ='\''; break;
				case '\\': ch = '\\'; break;
				default:
					if ( Slashcheck != NULL && *Slashcheck != 0 ) {
						eprint("Unrecognized backslashed character (%c) is ignored\n",ch);
						ch = yyinput();
						goto rechar;
					} else {
						yyunget(ch);
						ch = '\\';
					}
					break;
				}
			}
			makeroom((long)(si+2),&Msg1,&Msg1size); /* +1 for final '\0' */
			Msg1[si++] = ch;
		}
		Msg1[si] = '\0';
		yylval.str = uniqstr(Msg1);
		retval = STRING;
		goto getout;
	}
	if ( c == '$' ) {
		c = yyinput();
		if ( c == '$' ) {
			retval = DOLLAR2;
			goto getout;
		}
		if ( isdigit(c) || c == '-' ) {
			long n;
			int sgn;
			if ( c == '-' ) {
				n = 0;
				sgn = -1;
			}
			else {
				n = c - '0';
				sgn = 1;
			}
			while ( (c=yyinput()) != EOF ) {
				if ( ! isdigit(c) ) {
					yyunget(c);
					break;
				}
				n = n*10 + c - '0';
			}
			yylval.val = n*sgn + *Kobjectoffset;
			if ( yylval.val >= Nextobjid )
				Nextobjid = yylval.val + 1;
			retval = OBJECT;
			goto getout;
		}
		yyunget(c);
		retval = '$';
		goto getout;
	}
	switch(c) {
	case '\n': retval = '\n'; break;
	case '?':  retval = follow('?', QMARK2, '?'); break;
	case '=':  retval = follow('=', EQ, '='); break;
	case '+':  retval = follo2('=', PLUSEQ, '+', INC, '+'); break;
	case '-':  retval = follo2('=', MINUSEQ, '-', DEC, '-'); break;
	case '*':  retval = follow('=', MULEQ, '*'); break;
	case '>':  retval = follo3('=', GE, '>', '=',RSHIFT,RSHIFTEQ,GT);break;
	case '<':  retval = follo3('=', LE, '<', '=',LSHIFT,LSHIFTEQ,LT);break;
	case '!':  retval = follow('=', NE, BANG); break;
	case '&':  retval = follo2('=', AMPEQ, '&', AND, '&'); break;
	case '|':  retval = follo2('=', OREQ, '|', OR, '|'); break;
	case '/':  retval = follow('=', DIVEQ, '/'); break;
	case '^':  retval = follow('=', XOREQ, '^'); break;
	case '~':  retval = follow('~', REGEXEQ, '~'); break;
	default:   retval = c; break;
	}
    getout:
	*Pyytext = '\0';
#ifdef MYYYDEBUG
	if ( yydebug )
		printf("yylex returns %d, Yytext=(%s)\n",retval,Yytext);
#endif
	return(retval);
}
