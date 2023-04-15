#define VAR 257
#define UNDEF 258
#define MACRO 259
#define TOGLOBSYM 260
#define QMARK2 261
#define DOLLAR2 262
#define WHILE 263
#define DOTDOTDOT 264
#define IF 265
#define ELSE 266
#define FOR 267
#define IN 268
#define BEINGREAD 269
#define EVAL 270
#define BREAK 271
#define CONTINUE 272
#define TASK 273
#define DELETE 274
#define UNDEFINE 275
#define RETURN 276
#define FUNC 277
#define DEFINED 278
#define READONLY 279
#define ONCHANGE 280
#define GLOBALDEC 281
#define DUR 282
#define VOL 283
#define TIME 284
#define CHAN 285
#define PITCH 286
#define LENGTH 287
#define NUMBER 288
#define TYPE 289
#define ATTRIB 290
#define FLAGS 291
#define VARG 292
#define PHRASE 293
#define STRING 294
#define NAME 295
#define INTEGER 296
#define OBJECT 297
#define DOUBLE 298
#define PLUSEQ 299
#define MINUSEQ 300
#define MULEQ 301
#define DIVEQ 302
#define AMPEQ 303
#define INC 304
#define DEC 305
#define POSTINC 306
#define POSTDEC 307
#define OREQ 308
#define XOREQ 309
#define RSHIFTEQ 310
#define LSHIFTEQ 311
#define OR 312
#define AND 313
#define GT 314
#define GE 315
#define LT 316
#define LE 317
#define EQ 318
#define NE 319
#define REGEXEQ 320
#define LSHIFT 321
#define RSHIFT 322
#define UNARYMINUS 323
#define BANG 324
typedef union {
	Symbolp	sym;	/* symbol table pointer */
	Instnodep in;	/* machine instruction */
	int	num;	/* number of arguments */
	long	val;	/* numeric constant */
	DBLTYPE	dbl;	/* floating constant */
	char	*str;	/* string constant */
	Phrasep	phr;	/* phrase constant */
} YYSTYPE;
extern YYSTYPE yylval;
