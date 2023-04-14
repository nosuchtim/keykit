#include <sys/types.h>
#include <sys/signal.h>
#include <sys/errno.h>
#include <sys/param.h>
#include <sys/dir.h>
#include <sys/user.h>
#include <sys/buf.h>
#include <sys/sysmacros.h>
#include <sys/systm.h>
#include <sys/midi.h>

/* BUFSIZ is the size of the buffers obtained from geteblk().  Is there */
/* a #define elsewhere that gives this value?  (besides stdio.h) */
#define BUFSIZ 1024

#define CIRCLESIZE (BUFSIZ*MIDI_BUFS)

#define controller(dev) (minor(dev))

#define DATA_PORT 0x330
#define STATUS_PORT 0x331
#define DATA_READY 0x40
#define DATA_AVAILABLE 0x80
#define RESET 0xff
#define UART 0x3f
/* note that active sensing and ACK from controller are the same */
#define ACK 0xfe
#define ACTIVE 0xfe

#define midi_putdata(ctlr,c)	(outb(ctlr_to_data_port[ctlr],(c)))
#define midi_putcmd(ctlr,c)	(outb(ctlr_to_status_port[ctlr],(c)))
#define midi_getdata(ctlr)	(inb(ctlr_to_data_port[ctlr]))
#define midi_getstatus(ctlr)	(inb(ctlr_to_status_port[ctlr]))
#define data_is_available(ctlr)	(!(midi_getstatus(ctlr)&DATA_AVAILABLE))
#define ready_for_data(ctlr)	(!(midi_getstatus(ctlr)&DATA_READY))

void
midiinit()
{
	register int n;

	/* create an irq_to_ctlr array so that midiintr() can */
	/* get the ctlr number quickly. */
	for ( n=0; n<NUMIRQ; n++ )
		irq_to_ctlr[n] = 0;
	for ( n=0; n<midi_nctlr; n++ ) {
		irq_to_ctlr[ ctlr_to_irq[n] ] = n;
#ifdef ODT
		printcfg("midi",ctlr_to_data_port[n],2,ctlr_to_irq[n],-1,"");
#endif
	}
}

unsigned char *
midiqchr(q,off)
struct midi_queue *q;
off_t off;
{
	struct buf *b;
	unsigned char *a;

	b = q->buf[(int)((off/BUFSIZ)%MIDI_BUFS)];
	if ( ! b )
		return NULL;
	a = (unsigned char *)(b->b_un.b_addr);
	if ( ! a )
		return NULL;
	return (a + (int)(off%BUFSIZ));
}

void
midiqput(q,c)
register struct midi_queue *q;
int c;
{
	register unsigned char *p = midiqchr(q,q->high);

	if ( p ) {
		*p = c;
		q->high++;
		/* if we wrap around in the circular buffer, */
		/* make sure the low offset keeps up (ie. this */
		/* throws away the oldest unread data) */
		if ( (q->high - q->low) >= CIRCLESIZE )
			q->low = q->high - CIRCLESIZE + 1;
	}
}

midiqget(q)
struct midi_queue *q;
{
	register unsigned char *p;
	register int c;

	if ( q->low == q->high )
		return -1;

	p = midiqchr(q,q->low);
	if ( ! p )
		return -1;
	c = *p;
	q->low++;
	return c;
}

void
midireset(ctlr,uart)
{
	register struct midi_ctlr *m = &midi_ctlr[ ctlr ];
	register time_t etime;
	int n;

	while ( data_is_available(ctlr) )
		(void) midi_getdata(ctlr);

	/* try reset twice if ACK not received */
	for ( n=0; n<2; n++ ) {
		midi_putcmd(ctlr,RESET);
		/* probably shouldn't busy loop */
		etime = lbolt + HZ / 40;	/* for 25 milliseconds */
		while ( lbolt >= etime ) {
			if ( midiqget(&(m->in)) == ACK )
				break;
		}
		if ( lbolt < etime )
			break;
	}
	if ( n >= 2 )
		printf("midireset didn't get ACK?\n");
	if ( uart )
		midi_putcmd(ctlr,UART);	/* doesn't send an ACK back */
}

void
midiopen(dev)
{
	register struct midi_ctlr *m;
	register int ctlr = controller(dev);
	register int n;

	if ( ctlr >= midi_nctlr ) {
		u.u_error = ENXIO;
		return;
	}
	m = &midi_ctlr[ctlr];
	if ( ((m->flags)&ISOPEN) == 0 ) {
		/* opened for the first time */
		for ( n=0; n<MIDI_BUFS; n++ ) {
			m->in.buf[n] = geteblk();
			m->in.low = m->in.high = 0;
		}
		m->flags |= ISOPEN;
		m->flags &= (~ACTSENSE);/* default is to ignore active sensing */
		m->clockoffset = lbolt;	/* TIME starts out at 0 */
		midireset(ctlr,1);	/* default is UART mode */
	}
}

void
midiioctl(dev, cmd, arg, mode)
{
	register int ctlr = controller(dev);
	register struct midi_ctlr *m;
	time_t *t;
	off_t n;

	m = &midi_ctlr[ ctlr ];
	switch(cmd) {
	case MIDIACTIVE:
		if ( arg )
			m->flags |= ACTSENSE;
		else
			m->flags &= (~ACTSENSE);
		break;
	case MIDIRESET:
		midireset(ctlr,1);	/* default is UART mode */
		break;
	case MIDITHRU:
		midireset(ctlr,0);
		break;
	case MIDITIMERESET:
		m->clockoffset = lbolt;
		break;
	case MIDITIME:
		t = (time_t *)arg;
#define MILLIPERHZ (1000/HZ)
		if ( t )
			suword(t,(long)(MILLIPERHZ*(lbolt - m->clockoffset)));
		break;
	default:
		u.u_error = EINVAL;
		break;
	}
}

midi_wait_for_ready(ctlr)
{
	int tmout;

	for ( tmout=50000; tmout>0; tmout-- ) {
		if ( ready_for_data(ctlr) )
			break;
	}
	if ( tmout <= 0 ) {
		printf("/dev/midi timed out waiting for data ready\n");
		return 0;
	}
	return 1;
}

void
midiclose(dev)
{
	register struct midi_ctlr *m;
	register int n;
	register int ctlr = controller(dev);

	midireset(ctlr,0);
	m = &midi_ctlr[ ctlr ];
	if ( ((m->flags)&ISOPEN) != 0 ) {	/* paranoia */
		m->flags &= (~ISOPEN);
		for ( n=0; n<MIDI_BUFS; n++ )
			brelse(m->in.buf[n]);
	}
}

void
midiread(dev)
{
	register struct midi_ctlr *m;
	register int ctlr = controller(dev);
	register int c;

	m = &midi_ctlr[ ctlr ];
	while ( u.u_count ) {
		c = midiqget(&(m->in));
		if ( c < 0 )
			break; 
		/* active sensing may be ignored */
		if ( c == ACTIVE && ((m->flags&ACTSENSE)==0) )
			break;
		subyte(u.u_base,c);
		u.u_base++;
		u.u_count--;
	}
}

void
midiwrite(dev)
{
	register int ctlr = controller(dev);

	while ( u.u_count ) {
		if ( midi_wait_for_ready(ctlr) ) {
			midi_putdata(ctlr,fubyte(u.u_base));
			u.u_base++;
			u.u_count--;
		}
	}
}

void
midiintr(irq)
{
	register struct midi_ctlr *m;
	register int ctlr;
	register int c;

	ctlr = irq_to_ctlr[irq];
	if ( data_is_available(ctlr) ) {
		c = midi_getdata(ctlr);
		m = &midi_ctlr[ ctlr ];
		if ( (m->flags & ISOPEN) != 0 )
			midiqput(&(m->in),c);
	}
}
