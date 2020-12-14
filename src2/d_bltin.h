void bi_debug(int argc);
#ifdef OLDSTUFF
#endif
#ifdef MDEBUG
#endif
#ifdef OLDSTUFF
#endif
Datum limitsarr(Phrasep ph);
void bi_sizeof(int argc);
void bi_limitsof(int argc);
void bi_prstack(int argc);
void bi_phdump(int argc);
int tasklistcollect(Hnodep h);
void bi_taskinfo(int argc);
void bi_oldtypeof(int argc);
#ifdef OLDSTUFF
#endif
void bi_string(int argc);
void bi_integer(int argc);
void bi_float(int argc);
void bi_phrase(int argc);
void bi_sin(int argc);
void bi_cos(int argc);
void bi_tan(int argc);
void bi_asin(int argc);
void bi_acos(int argc);
void bi_atan(int argc);
void bi_sqrt(int argc);
void bi_exp(int argc);
void bi_log(int argc);
void bi_log10(int argc);
void bi_pow(int argc);
void bi_readphr(int argc);
void bi_pathsearch(int argc);
void bi_ascii(int argc);
void bi_reboot(int argc);
int funcundefine(Hnodep hn);
void bi_refunc(int argc);
void bi_rekeylib(int argc);
void bi_midifile(int argc);
void bi_split(int argc);
void bi_cut(int argc);
void bi_midibytes(int argc);
#ifdef NTATTRIB
#endif
void bi_oldnargs(int argc);
#ifdef OLDSTUFF
#endif
void bi_error(int argc);
void bi_printf(int argc);
void bi_argv(int argc);
void nomidi(char *s);
void nographics(char *s);
void bi_realtime(int argc);
void bi_sleeptill(int argc);
#ifdef OLDSTUFF
#endif
void bi_wait(int argc);
void bi_lock(int argc);
void bi_unlock(int argc);
void bi_finishoff(int argc);
void bi_kill(int argc);
#ifdef DEBUGSTUFF
#endif
int chkprio(Hnodep h);
void bi_priority(int argc);
Dnode * grabargs(int fromargn,int toargn);
void bi_onexit(int argc);
void bi_onerror(int argc);
void bi_tempo(int argc);
void bi_substr(int argc);
void bi_sbbyes(int argc);
void bi_system(int argc);
void bi_chdir(int argc);
void lsdircallback(char *fname,int type);
void bi_lsdir(int argc);
void bi_filetime(int argc);
void bi_coreleft(int argc);
#ifdef CORELEFT
#else
#endif
void bi_currtime(int argc);
void bi_milliclock(int argc);
void bi_rand(int argc);
void bi_exit(int argc);
void bi_garbcollect(int argc);
void bi_funkey(int argc);
void bi_symbolnamed(int argc);
void bi_windobject(int argc);
void bi_sync(int argc);
void bi_browsefiles(int argc);
void bi_setmouse(int argc);
void bi_mousewarp(int argc);
long arraynumval(Htablep arr,Datum arrindex,char *err);
int getxy01(Htablep arr,long *ax0,long *ay0,long *ax1,long *ay1,int normalize,char *err);
Datum xy01arr(long x0,long y0,long x1,long y1);
Datum xyarr(long x0,long y0);
int addifnew(Hnodep h);
void addnonxy(Htablep newarr,Htablep arr);
void bi_oldxy(int argc);
#ifdef OLDSTUFF
#endif
void bi_attribarray(int argc);
void bi_screen(int argc);
void wsettrack(Kwind *w,char *trk);
void bi_colorset(int argc);
void bi_colormix(int argc);
void bi_get(int argc);
void bi_put(int argc);
void bi_flush(int argc);
void bi_fifoctl(int argc);
void bi_mdep(int argc);
void chkinputport(int portno);
void chkoutputport(int portno);
void bi_midi(int argc);
#ifndef MDEP_MIDI_PROVIDED
#else
#ifdef BADIDEA
#endif
#endif
void bi_bitmap(int argc);
void bi_help(int argc);
void bi_fifosize(int argc);
void validpitch(int n,char *s);
void bi_open(int argc);
void bi_close(int argc);
long newobjectid(void);
void bi_object(int argc);
void bi_objectlist(int argc);
void bi_objectinfo(int argc);
void bi_sprintf(int argc);
#ifdef MDEBUG
void bi_mmreset(int argc);
void bi_mmdump(int argc);
#endif
void bi_nullfunc(int argc);
