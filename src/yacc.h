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
#define SYM_IN 268
#define BEINGREAD 269
#define EVAL 270
#define BREAK 271
#define CONTINUE 272
#define TASK 273
#define SYM_DELETE 274
#define UNDEFINE 275
#define RETURN 276
#define FUNC 277
#define DEFINED 278
#define READONLY 279
#define ONCHANGE 280
#define GLOBALDEC 281
#define CLASS 282
#define METHOD 283
#define KW_NEW 284
#define NARGS 285
#define TYPEOF 286
#define XY 287
#define DUR 288
#define VOL 289
#define TIME 290
#define CHAN 291
#define PITCH 292
#define LENGTH 293
#define NUMBER 294
#define TYPE 295
#define ATTRIB 296
#define FLAGS 297
#define VARG 298
#define PORT 299
#define PHRASE 300
#define STRING 301
#define NAME 302
#define INTEGER 303
#define OBJECT 304
#define DOUBLE 305
#define PLUSEQ 306
#define MINUSEQ 307
#define MULEQ 308
#define DIVEQ 309
#define AMPEQ 310
#define INC 311
#define DEC 312
#define POSTINC 313
#define POSTDEC 314
#define OREQ 315
#define XOREQ 316
#define RSHIFTEQ 317
#define LSHIFTEQ 318
#define OR 319
#define AND 320
#define GT 321
#define GE 322
#define LT 323
#define LE 324
#define EQ 325
#define NE 326
#define REGEXEQ 327
#define LSHIFT 328
#define RSHIFT 329
#define UNARYMINUS 330
#define BANG 331
#if 0
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
#endif
