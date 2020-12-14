int mgetc(void);
void k_header(int f,int n,int d);
#ifdef WARNEVEN
#endif
void k_starttrack(void);
void putnfree(void);
void putallnotes(void);
void k_endtrack(void);
void k_noteon(int chan,int pitch,int vol);
Noteptr queuenote(int chan,int pitch,int vol,int type);
void k_noteoff(int chan,int pitch,int vol);
void k_pressure(int chan,int pitch,int press);
void k_controller(int chan,int control,int value);
void k_pitchbend(int chan,int msb,int lsb);
void k_program(int chan,int program);
void k_chanpressure(int chan,int press);
void threebytes(int c1,int c2,int c3);
void twobytes(int c1,int c2);
void queuemess(Unchar *mess,int leng);
void k_arbitrary(int leng,Unchar *mess);
void k_tempo(long tempo);
void k_timesig(unsigned nn,unsigned dd,unsigned cc,unsigned bb);
void k_keysig(unsigned sf,unsigned mi);
void k_chanprefix(unsigned c);
void k_seqnum(int n);
void k_smpte(unsigned hr,unsigned mn,unsigned se,unsigned fr,unsigned ff);
void k_metatext(int type,int leng,Unchar *mess);
int mftoarr(char *mfname,Htablep arr);
