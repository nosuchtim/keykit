int mdep_getnmidi(char *buff,int buffsize,int *port);
void mdep_putnmidi(int n, char *cp, Midiport * pport);
int openmidiin(int i);
#ifdef THIS_CAUSES_A_HANG_ON_SOME_SYSTEMS
#endif
void mdep_endmidi(void);
int mdep_initmidi(Midiport *inputs, Midiport *outputs);
#if THIS_MESSAGE_IS_BOGUS
#endif
void handlemidioutput(long long lParam, int windevno);
#if KEYCAPTURE
int startvideo(void);
void stopvideo(void);
#endif
#if KEYDISPLAY
int startdisplay(int noborder, int width, int height);
#endif
void setvideogrid(int gx, int gy);
Datum mdep_mdep(int argc);
#if KEYCAPTURE
#else
#endif
#if KEYDISPLAY
#endif
#if 0
#endif
int openmidiout(int windevno);
int mdep_midi(int openclose, Midiport * p);
#if 0
#endif
#ifdef EVENT_TIMESTAMP
#endif
void PutEvent(LPCIRCULARBUFFER lpBuf, LPEVENT lpEvent);
