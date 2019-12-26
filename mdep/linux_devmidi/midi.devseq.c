
/*   Time-stamp: <1998-12-07 16:58:40 madhu>       --*C*--
*   Touched: Sun Nov 29 23:18:20 1998 <madhu@cs.unm.edu>
*
* Hack-tested with Linux 2.0.36 (redhat,OSS/Free:3.8s2++,awedrv0.42d)
* to read my external keyboard controller and to play sounds on the
* soundcard synthesizer.  Consider macroing real.c:midiput() to
* seq_do_midi_msg.
*
* Copyright 1996 AT&T Corp.  All rights reserved.
*
* This contains support for Voxware MIDI version 2.9 and (hopefully)
* later.  It assumes Voxware is installed.
**/

#include "key.h"
#include <sys/types.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

/* Change this if you prefer to use a different default MIDI interface */
/* this needs to be /dev/sequencer for my drumbanks to work.    -madhu */

#define MIDIDEVICE "/dev/sequencer"

extern int errno;

int
mdep_initmidi(void)
{
extern char **Devmidi;
int r;
int ret = 0;
char *MidiDevice;

if ( (MidiDevice = getenv("MIDIDEVICE")) == NULL ) {
MidiDevice = MIDIDEVICE;
}

Midifd = open(MidiDevice,O_RDWR);
if ( Midifd >= 0 ) {

if ( Devmidi )
*Devmidi = uniqstr(MidiDevice);
if ( ! ismuxable(Midifd) ) {
fprintf(stderr,"Hey, Midifd isn't muxable!\n");
exit(1);
}
}
else {
fprintf(stderr,"Unable to open %s (errno=%d)\n",
MidiDevice,errno);
ret = 1;
}
seq_init();
return(ret);
}

void
mdep_endmidi(void)
{
if ( Midifd >= 0 )
close(Midifd);
}

/* must return -1 if there is nothing to read */
int
mdep_getnmidi(char *buff,int buffsize)
{
  
  fd_set readfds;
  fd_set writefds;
  fd_set exceptfds;
  struct timeval t;
  
  if ( Midifd < 0 )
    return 0;
  
  FD_ZERO(&readfds);
  FD_ZERO(&writefds);
  FD_ZERO(&exceptfds);
  FD_SET(Midifd, &readfds);
  FD_SET(Midifd, &exceptfds);
  t.tv_sec = 0;
  t.tv_usec = 0;
  if(select(fd+1, &readfds, &writefds, &exceptfds, &t) == 0) {
    return -1;
  }
  return seq_readevent(Midifd,buffsize,buff);
}

void
mdep_putnmidi(int n,char *p)
{
  if ( Midifd < 0 )
    return;
  
  /* assume full midi message in p, dump it instead of seq_midiparse */
  seq_do_midi_msg(p,n);
  return;

  /*
  int i;
  if ( write(Midifd,p,(unsigned)n) != n ) {
    eprint("Hmm, write to MIDI device didn't write everything?\n");
    keyerrfile("Hmm, write to MIDI device didn't write everything?\n");
  }
  */
}



/* AWE_HACK:------------------------------------------------------------*/

#include <sys/soundcard.h>
#include <linux/awe_voice.h>
#include <assert.h>
#define TRUE 1

extern char * seq_ctl_name(int ctlno);

extern int errno;
extern int Midifd; /*  open descriptor for sequencer devicee */
static int DEVNUM = 0; /* synth deviceno on the soundcard */

SEQ_DEFINEBUF(128); /* sets up buffer size of 128 bytes */

unsigned char _seqbuf[]; /* canonical code that the API provides */
int _seqbuflen;
int _seqbufptr;

void
seqbuf_dump() /* the MIDI messages get dumped here */
{
  if (_seqbufptr) /* the buffer is written to */
    if (write (Midifd, _seqbuf, _seqbufptr) == -1)
      perror("Can't write to MIDI device"); 
  _seqbufptr = 0;
}

/* figure out DEVNUM -------------------------------------------------------*/
static struct synth_info card_info;
static int nrsynths, max_synth_voices;
static int seq_bank = 0x00, seq_preset = 0x00;
static short seq_bend = 0x2000;

void
seq_init()
{
  int i, awe_drv  = 0;
  assert(! (Midifd < 0));

  errno = 0;
  if (ioctl(Midifd, SNDCTL_SEQ_NRSYNTHS, &nrsynths) == -1) {
    fprintf(stderr, "there is no soundcard installed: %s\n",
    strerror(errno));
    exit(-1);
  }
  else
    fprintf(stderr,"(0x%02x) SYNTHS found\n", nrsynths);

  DEVNUM = -1; 
  errno = 0;  

  for (i = 0; i < nrsynths; i++) {
    card_info.device = i;
    if (ioctl(Midifd, SNDCTL_SYNTH_INFO, &card_info) == -1) {
      fprintf(stderr, "cannot get info on soundcard: %s\n",
      strerror(errno));
      exit(-1);
    }
    if (card_info.synth_type == SYNTH_TYPE_SAMPLE
&& card_info.synth_subtype == SAMPLE_TYPE_AWE32) {
      awe_drv = 1;
      DEVNUM = i;
    }
  }
  
  if (DEVNUM == -1)  {
    fprintf(stderr,"couldnt detect synth\n");
    exit(-1);
  }
  else 
    fprintf(stderr,"using synth at (0x%02x)\n", DEVNUM);
  
  if (awe_drv) {
    /* use MIDI channel mode */
    AWE_SET_CHANNEL_MODE(DEVNUM, AWE_PLAY_MULTI);
      
    /* toggle drum flag if bank #128 is received */
    AWE_MISC_MODE(DEVNUM, AWE_MD_TOGGLE_DRUM_BANK, TRUE);
    
    /* set some defaults on channel 0 */
    SEQ_CONTROL(DEVNUM, 0, CTL_BANK_SELECT, seq_bank);
    SEQ_SET_PATCH(DEVNUM, 0, seq_preset);
    SEQ_BENDER(DEVNUM, 0, seq_bend);
  }
}


/* play a MIDI message on DEVNUM ------------------------------------------*/
void
seq_do_midi_msg(unsigned char *msg, int mlen)
{

  if (*Debugmidi) {
    int k;
    tprint("seq_domidi( DEVNUM=%d, n= %d 0x", DEVNUM, mlen);
    for ( k=0; k<mlen; k++ )
      tprint("%02x",msg[k]&0xff);
    tprint(" )\n");
  }
  else
  
  switch (msg[0] & 0xf0)
    {
    case 0x90:
      if (msg[2] != 0)
{
  SEQ_START_NOTE(DEVNUM, msg[0] & 0x0f, msg[1], msg[2]);
  /* tprint("awe_hack: noteon note=(0x%02x) vel=(0x%02x)\n",
msg[1], msg[2]); */
  break;
} /* msg[2] = 64;*/
      
    case 0x80:
      SEQ_STOP_NOTE(DEVNUM, msg[0] & 0x0f, msg[1], msg[2]);
      /* tprint("awe_hack: noteoff note=(0x%02x) vel=(0x%02x)\n",
     msg[1], msg[2]); */
      break;
      
    case 0xA0:
      SEQ_KEY_PRESSURE(DEVNUM, msg[0] & 0x0f, msg[1], msg[2]);
      tprint("awe_hack: aftertouch note=(0x%02x) pressure=(0x%02x)\n",
      msg[0],msg[1]);
      break;
      
    case 0xB0:
      SEQ_CONTROL(DEVNUM, msg[0] & 0x0f, msg[1], msg[2]);
      tprint("awehack: setting ctl=%d (%s) to val=%d\n",
     msg[1], seq_ctl_name(msg[1]), msg[2]);
      break;
      
    case 0xC0:
      SEQ_PGM_CHANGE(DEVNUM, msg[0] & 0x0f, msg[1]);
      tprint("awe_hack: programchange no=(0x%02x)\n",msg[1]);
      break;
      
    case 0xD0:
      SEQ_CHN_PRESSURE(DEVNUM, msg[0] & 0x0f, msg[1]);
      tprint("awe_hack: channelpressure=(0x%02x) for chnl\n",
      msg[1]);
      break;
      
    case 0xE0:
      SEQ_BENDER(DEVNUM, msg[0] & 0x0f,
(msg[1] % 0x7f) | ((msg[2] & 0x7f) << 7) );
      /* tprint("awe_hack: pitchwheel bend = (0x%04x)\n",
     (msg[1] % 0x7f) | ((msg[2] & 0x7f) << 7) ); */
      break;
      
    default:
      tprint("awe_hack: Unknown midi channel message %02x\n", msg[0]);
    }

  SEQ_DUMPBUF();
}


/* my midiparse, calls seq_do_midi_msg -----------------------------------*/
#define MSINIT  0x00 /* midiparse states */
#define MSDATA  0x10
#define MSYSEX  0x20

static unsigned  char m_state = MSINIT;
static unsigned char  m_buf[6];
static int m_ptr = 0, m_left = 0, m_prev_status = MSINIT;

void
seq_midiparse(unsigned char data)
{
  /* # data bytes following a status */
  static unsigned char len_tab[] = {
    2, /* 8x */
    2, /* 9x */
    2, /* Ax */
    2, /* Bx */
    1, /* Cx */
    1, /* Dx */
    2, /* Ex */
    0 /* Fx */
  };
  
  if (data == 0xfe) /* Ignore active sensing */
    return;
  
  switch (m_state)
    {
    case MSINIT:
      if (data & 0x80) /* MIDI status byte */
{
  if ((data & 0xf0) == 0xf0) /* Handle Common message first:*/
    {
      switch (data)
{
case 0xf0: /* Sysex */
  m_state = MSYSEX;
  break; /* Sysex */
  
case 0xf1: /* MTC quarter frame */
case 0xf3: /* Song select */
  m_state = MSDATA;
  m_ptr = 1;
  m_left = 1;
  m_buf[0] = data;
  break;
  
case 0xf2: /* Song position pointer */
  m_state = MSDATA;
  m_ptr = 1;
  m_left = 2;
  m_buf[0] = data;
  break;
  
default:
  m_buf[0] = data;
  m_ptr = 1;
  /* Tada!: */
  seq_do_midi_msg(m_buf, m_ptr);
  m_ptr = 0;
  m_left = 0;
}
    }
  else
    {
      m_state = MSDATA;
      m_ptr = 1;
      m_left = len_tab[(data >> 4) - 8];
      m_buf[0] = m_prev_status = data;
    }
}
      else
if (m_prev_status & 0x80) /* Ignore if no previous status (yet) */
  { /* Data byte (use running status) */
    m_state = MSDATA;
    m_ptr = 2;
    m_left = len_tab[(data >> 4) - 8] - 1;
    m_buf[0] = m_prev_status;
    m_buf[1] = data;
  }
      break; /* MSINIT */
      
    case MSDATA:
      m_buf[m_ptr++] = data;
      if (--m_left <= 0)
{
  m_state = MSINIT;
  seq_do_midi_msg(m_buf, m_ptr);
  m_ptr = 0;
}
      break; /* MSDATA */
      
    case MSYSEX:
      if (data == 0xf7) /* Sysex end */
{
  m_state = MSINIT;
  m_left = 0;
  m_ptr = 0;
}
      break; /* MSYSEX */
      
    default:
      tprint("MIDIPARSE:Unexpected state %d (%02x)\n", m_state,(int)data);
      m_state = MSINIT;
    }
}

/* to print out defined controller names---------------------------------*/
#define NULLENT(n) {n, "", 0},
typedef struct seq_ctl {
  Unchar number;
  char * desc;
  Unchar value;
} seq_ctl;

static
seq_ctl seq_ctl_lst[] = {
{0, "Bank Select", 0 },
{1, "Modulation Wheel (coarse)", 0},
{2, "Breath controller (coarse)", 0},
  NULLENT(3)
{4, "Foot Pedal (coarse)", 0},
{5, "Portamento Time (coarse)", 0},
{6, "Data Entry (coarse)", 0},
{7, "Volume (coarse)", 0},
{8, "Balance (coarse)", 0},
    NULLENT(9)
{10, "Pan position (coarse)", 0},
{11, "Expression (coarse)", 0},
{12, "Effect Control 1 (coarse)", 0},
{13, "Effect Control 2 (coarse)", 0},
    NULLENT(14)    NULLENT(15)
{16, "General Purpose Slider 1", 0},
{17, "General Purpose Slider 2", 0},
{18, "General Purpose Slider 3", 0},
{19, "General Purpose Slider 4", 0},
  NULLENT(20) NULLENT(21) NULLENT(22) NULLENT(23) NULLENT(24) NULLENT(25)
  NULLENT(26) NULLENT(27) NULLENT(28) NULLENT(29) NULLENT(30) NULLENT(31)      
{32, "Bank Select (fine)", 0},
{33, "Modulation Wheel (fine)", 0},
{34, "Breath controller (fine)", 0},
  NULLENT(35)
{36, "Foot Pedal (fine)", 0},
{37, "Portamento Time (fine)", 0},
{38, "Data Entry (fine)", 0},
{39, "Volume (fine)", 0},
{40, "Balance (fine)", 0},
NULLENT(41)
{42, "Pan position (fine)", 0},
{43, "Expression (fine)", 0},
{44, "Effect Control 1 (fine)", 0},
{45, "Effect Control 2 (fine)", 0},
  NULLENT(46) NULLENT(47) NULLENT(48) NULLENT(49) NULLENT(50) NULLENT(51)
  NULLENT(52) NULLENT(53) NULLENT(54) NULLENT(55) NULLENT(56) NULLENT(57)
  NULLENT(58) NULLENT(59) NULLENT(60) NULLENT(61) NULLENT(62) NULLENT(63)
{64, "Hold Pedal (on/off)", 0},
{65, "Portamento (on/off)", 0},
{66, "Sustenuto Pedal (on/off)", 0},
{67, "Soft Pedal (on/off)", 0},
{68, "Legato Pedal (on/off)", 0},
{69, "Hold 2 Pedal (on/off)", 0},
{70, "Sound Variation", 0},
{71, "Sound Timbre", 0},
{72, "Sound Release Time", 0},
{73, "Sound Attack Time", 0},
{74, "Sound Brightness", 0},
{75, "Sound Control 6", 0},
{76, "Sound Control 7", 0},
{77, "Sound Control 8", 0},
{78, "Sound Control 9", 0},
{79, "Sound Control 10", 0},
{80, "General Purpose Button 1 (on/off)", 0},
{81, "General Purpose Button 2 (on/off)", 0},
{82, "General Purpose Button 3 (on/off)", 0},
{83, "General Purpose Button 4 (on/off)", 0},
  NULLENT(83) NULLENT(84) NULLENT(85) NULLENT(86) NULLENT(87)
  NULLENT(88) NULLENT(89) NULLENT(90) 
{91, "Effects Level", 0},
{92, "Tremulo Level", 0},
{93, "Chorus Level", 0},
{94, "Celeste Level", 0},
{95, "Phaser Level", 0},
{96, "Data Button increment", 0},
{97, "Data Button decrement", 0},
{98, "Non-registered Parameter (fine)", 0},
{99, "Non-registered Parameter (coarse)", 0},
{100, "Registered Parameter (fine)", 0},
{101, "Registered Parameter (coarse)", 0},
NULLENT(102) NULLENT(103) NULLENT(104) NULLENT(105) NULLENT(106) NULLENT(107)
NULLENT(108) NULLENT(109) NULLENT(110) NULLENT(111) NULLENT(112) NULLENT(113)
NULLENT(114) NULLENT(115) NULLENT(116) NULLENT(117) NULLENT(118) NULLENT(119)
{120, "All Sound Off", 0},
{121, "All Controllers Off", 0},
{122, "Local Keyboard (on/off)", 0},
{123, "All Notes Off", 0},
{124, "Omni Mode Off", 0},
{125, "Omni Mode On", 0},
{126, "Mono Operation", 0},
{127, "Poly Operation", 0}
};

char *seq_ctl_name(int ctlno) { return (seq_ctl_lst + ctlno)->desc; }


/* for reading bytes from the input events----------------------------------*/
int
seq_readevent(int midifd, int buffsize, char *buff)
{
  int i, n,  nwrit = 0;
  static char inbuf[8]; /* for events */
  /**
   * We assume data is waiting. Read an event of atmost buffsize
   * length from fd and store it in buf. Return the number of bytes
   * written to buf.
   **/
  assert(8 < buffsize);
  assert(! (midifd < 0));
  
  if ((n = read(midifd,inbuf,8)) <= 0)  return 0;

  if (*Debugmidi) {
    fprintf(stderr,"read %d bytes: ", n);
    fprintf(stderr, "WTF is ");
    for (i = 0; i < n; i++)
      fprintf(stderr, " 0x%04x ", inbuf[i]);
    fprintf(stderr, "\n");
  } else {

  for(i = 0; i < 8; i+=4)
    switch(inbuf[i+0])
      {
      case SEQ_WAIT: /* fprintf(stderr,"SEQWAIT\n"); */
break;
      case SEQ_ECHO: /* fprintf(stderr,"ECHO EVENT\n"); */
break;
      case SEQ_MIDIPUTC: /* fprintf(stderr,"MIDIPUTC\n"); */
*buff++ = inbuf[i+1]; nwrit++;
break;
      default:
if (i == 0) goto read8byte;
tprint("getMIDI: unknown midi event\n");
      }
  
  /* fprintf(stderr,"read 4byte event\n"); */
  return nwrit;
  
read8byte:
  if ((inbuf[0] & 0xf0) == 0x80)
    {
      tprint("System Level Events unimplemented\n");
    }
  else if ((inbuf[0] & 0xf0) == 0x90)
    {
      switch(inbuf[0] & 0xff)
{
case EV_CHN_COMMON: /* (0x92 dev cmd chn p1 p2 w14  ) */
  *buff++ = (inbuf[2] & 0xf0) | (inbuf[3] &0x0f);
  nwrit++;
  switch(inbuf[2] & 0xf0)
    {
    case MIDI_CTL_CHANGE: /* 0xB0 */
      *buff++ = inbuf[4]; 
      *buff = *(short *) &inbuf[6];
      buff += 2;
      nwrit += 2;
      break;
    case MIDI_PGM_CHANGE: /* 0xC0 */
      *buff++ = inbuf[4];
      nwrit++;
      break;
    case MIDI_CHN_PRESSURE: /* 0xD0 */
      *buff++ = inbuf[4];
      nwrit++;
      break;
    case MIDI_PITCH_BEND: /* 0xE0 */
      *(short *)buff = *(short *) &inbuf[6];
      buff+=2;
      nwrit+=2;
      break;
    default:
      tprint("Unknown common message (0x%02x)\n", inbuf[0]);
    }
  break;
case EV_CHN_VOICE: /* (0x93 dev cmd chn not val 0 0) */
  *buff++ = (inbuf[2] & 0xf0) | (inbuf[3] & 0x0f);
  *buff++ = inbuf[4];
  *buff++ = inbuf[5];
  nwrit += 3;
  break;
case EV_SYSEX: /* (0x94 dev p1 p2 p3 p4 p5 p6) */
  tprint("get MIDIL: Sysex Events unimplemented\n");
  break;
default:
  tprint("get MIDI: Unknown Event type = 0x%02x\n",
inbuf[0]&0xff);
}
    }
  else
    {
      tprint("get MIDI: unkown event\n");
    }

  /* fprintf(stderr,"read 8byte event\n"); */
  return nwrit;
  }
}



