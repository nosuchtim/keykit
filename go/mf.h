/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

#ifdef __STDC__
extern int (*Mf_getc)(NOARG);
extern void (*Mf_header)(int,int,int);
extern void (*Mf_starttrack)(NOARG);
extern void (*Mf_endtrack)(NOARG);
extern void (*Mf_on)(int,int,int);
extern void (*Mf_off)(int,int,int);
extern void (*Mf_pressure)(int,int,int);
extern void (*Mf_controller)(int,int,int);
extern void (*Mf_pitchbend)(int,int,int);
extern void (*Mf_program)(int,int);
extern void (*Mf_chanpressure)(int,int);
extern void (*Mf_sysex)(int,char*);
extern void (*Mf_metamisc)(int,int,char*);
extern void (*Mf_sqspecific)(int,char*);
extern void (*Mf_seqnum)(int);
extern void (*Mf_text)(int,int,char*);
extern void (*Mf_eot)(NOARG);
extern void (*Mf_timesig)(int,int,int,int);
extern void (*Mf_smpte)(int,int,int,int,int);
extern void (*Mf_tempo)(long);
extern void (*Mf_keysig)(int,int);
extern void (*Mf_arbitrary)(int,char*);
extern void (*Mf_error)(char *);
extern long Mf_currtime;
extern int Mf_nomerge;
extern int Mf_skipinit;
#else
extern int (*Mf_getc)();
extern void (*Mf_header)();
extern void (*Mf_starttrack)();
extern void (*Mf_endtrack)();
extern void (*Mf_on)();
extern void (*Mf_off)();
extern void (*Mf_pressure)();
extern void (*Mf_controller)();
extern void (*Mf_pitchbend)();
extern void (*Mf_program)();
extern void (*Mf_chanpressure)();
extern void (*Mf_sysex)();
extern void (*Mf_metamisc)();
extern void (*Mf_sqspecific)();
extern void (*Mf_seqnum)();
extern void (*Mf_text)();
extern void (*Mf_eot)();
extern void (*Mf_timesig)();
extern void (*Mf_smpte)();
extern void (*Mf_tempo)();
extern void (*Mf_keysig)();
extern void (*Mf_arbitrary)();
extern void (*Mf_error)();
extern long Mf_currtime;
extern int Mf_nomerge;
extern int Mf_skipinit;
#endif
