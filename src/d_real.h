void chksched(char *str);
void psched(void);
void resetcurrphr(void);
void initmidiport(Midiport *p);
void startrealtime(void);
void clrcontroller(void);
void newtempo(long t);
void resetreal(void);
void finishoff(void);
void addandput(int port, int n0, int chan, int c1,int c2);
#ifdef OLDSTUFF
void chkrealoften(void);
#endif
void chkinput(void);
void chkoutput(void);
Unchar * ustrchr(Unchar *pn,int n);
int chanofbyte(int b);
int execnt(register Sched *s, Sched *pres);
void toomany(char *onoff);
#ifdef OLDSTUFF
#endif
void rc_on(Unchar *mess,int indx);
void rc_off(Unchar *mess,int indx);
void rc_mess(Unchar *mess,int indx);
void rc_messhandle(Unchar *mess,int indx, int chan);
void rc_control(Unchar *mess,int indx);
void rc_pressure(Unchar *mess,int indx);
void rc_program(Unchar *mess,int indx);
void rc_chanpress(Unchar *mess,int indx);
void rc_pitchbend(Unchar *mess,int indx);
void rc_sysex(Unchar *mess,int indx);
void rc_position(Unchar *mess,int indx);
void rc_song(Unchar *mess,int indx);
void rc_startstopcont(Unchar *mess,int indx);
void rc_clock(Unchar *mess,int indx);
void chkcontroller(int port, Unchar* mess);
Noteptr  qnote(int chan);
#ifdef NTATTRIB
#endif
void noteon(register Noteptr q);
#ifdef NTATTRIB
#endif
void noteoff(Noteptr q);
#ifdef OLDSTUFF
#endif
#ifdef NTATTRIB
#endif
void notemess(Noteptr q);
#ifdef NTATTRIB
#endif
void ntrecord(Noteptr n);
#ifdef OLDSTUFF
#endif
void clrsched(Sched **as);
Sched * newsch(void);
void unsched(Task *t);
void freesch(register Sched *s);
Sched * immsched(int type,long clicks,Ktaskp tp,int monitor);
long taskphr(Phrasep ph, long clicks, long rep, int monitor);
void schdwake(long clicks);
