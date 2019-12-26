#include "sys/types.h"
#include "sys/param.h"
#include "sys/sysmacros.h"
#include "sys/stream.h"
#include "sys/stropts.h"
#include "sys/dir.h"
#include "sys/signal.h"
#include "sys/user.h"
#include "sys/errno.h"
#include "sys/cred.h"
#include "sys/ddi.h"
#include "sys/inline.h"
#include "sys/systm.h"
#include "sys/kmem.h"

#include "sys/cmn_err.h"

#include "./smid.h"

static struct module_info rminfo = { 0xaabb, "smid", 0, INFPSZ, 0, 0 };
static struct module_info wminfo = { 0xaabb, "smid", 0, INFPSZ, 0, 0 };

static int smidopen(), smidclose(), smidwput(), smidreset();
static void smid_out(), smidioc();

static struct qinit rinit = {
	NULL, NULL, smidopen, smidclose, NULL, &rminfo, NULL };

static struct qinit winit = {
	smidwput, NULL, NULL, NULL, NULL, &wminfo, NULL };

struct streamtab smidinfo = { &rinit, &winit, NULL, NULL };

static int smid_debug = 0;

#define DATA_READY 0x40
#define DATA_AVAILABLE 0x80
#define RESET 0xff
#define UART 0x3f
/* note that active sensing and ACK from controller are the same */
#define ACK 0xfe
#define ACTIVE 0xfe

#define smid_putdata(ctlr,c)	(outb(Ctlr_to_data_port[ctlr],(c)))
#define smid_putcmd(ctlr,c)	(outb(Ctlr_to_status_port[ctlr],(c)))
#define smid_getstatus(ctlr)	(inb(Ctlr_to_status_port[ctlr]))
#define ready_for_data(ctlr)	(!(smid_getstatus(ctlr)&DATA_READY))
#define smid_getdata(ctlr)	(inb(Ctlr_to_data_port[ctlr]))
#define data_is_available(ctlr)	(!(smid_getstatus(ctlr)&DATA_AVAILABLE))
#define data_is_not_available(ctlr)	(smid_getstatus(ctlr)&DATA_AVAILABLE)

static unsigned char *
smid_qchr(mc,off)
struct smid_ctlr *mc;
off_t off;
{
	unsigned char *b = mc->buff;
	if ( ! b )
		return NULL;
	return (b + (int)(off%(mc->buffsize)));
}

static void
smid_qput(ctlr,c)
int ctlr;
unsigned char c;
{
	register struct smid_ctlr *mc = &Smid_ctlr[ctlr];
	register unsigned char *p = smid_qchr(mc,mc->high);
	register struct smid_stream *ms;
	int buffsize = mc->buffsize;
	int high, oldpl;

	if ( p ) {
		oldpl = splhi();
		*p = c;
		high = ++(mc->high);
		/* Make sure the low offset in Smid_streams keeps up, */
		/* by throwing away the oldest unread data. */
		for ( ms=Smid_stream; ms<Smid_end; ms++ ) {
			if ( ((ms->flags) & ISOPEN) == 0 )
				continue;
			if ( (high - ms->low) >= buffsize )
				ms->low = high - buffsize + 1;
		}
		splx(oldpl);
	}
}

static int
smid_qget(ms)
struct smid_stream *ms;
{
	struct smid_ctlr *mc;
	unsigned char *p;
	int c, oldpl, ctlr;

	oldpl = splhi();
	ctlr = ms->ctlr;
	mc = &Smid_ctlr[ctlr];
	if ( ms->low == mc->high ) {
		splx(oldpl);
		return -1;
	}
	p = smid_qchr(mc,ms->low);
	if ( ! p ) {
		splx(oldpl);
		return -1;
	}
	c = *p;
	ms->low++;
	splx(oldpl);
	return c;
}

extern int smiddevflag = 0;

static int
msclose(ms)
struct smid_stream *ms;
{
	struct smid_stream *ms2;
	struct smid_ctlr *mc;

if(smid_debug)printf("msclose A\n");
	if ( smid_debug )
		cmn_err(CE_NOTE,"msclose start");
	/* See if any other streams have that MPU controller open. */
	for ( ms2=Smid_stream; ms2<Smid_end; ms2++ ) {
		if ( ms2!=ms && ((ms2->flags)&ISOPEN)!=0 && ms2->ctlr==ms->ctlr)
			break;
	}
	/* only reset if noone else has it open */
	if ( ms2 >= Smid_end ) {
		(void) smidreset(ms->ctlr,0);
		mc = &Smid_ctlr[ms->ctlr];
		if ( mc->buff ) {
			kmem_free(mc->buff,mc->buffsize);
			mc->buff = NULL;
		}
		mc->flags &= (~ISOPEN);
	}
	if ( ((ms->flags)&ISOPEN) == 0 ) {
		cmn_err(CE_NOTE,"Hey, closing a non-open midi stream?!");
if(smid_debug)printf("msclose B\n");
		return 0;
	}

	ms->flags &= (~ISOPEN);
if(smid_debug)printf("msclose returning, notify=%x\n",(long)(ms->notify));
	ms->notify = NULL;
if(smid_debug)printf("msclose C\n");
	return 0;
}

static void
primenotify(ms)
struct smid_stream *ms;
{
	int oldpl;
	mblk_t *mp;

if(smid_debug)printf("primenotify A\n");
	if ( ms->notify == NULL ) {
		mp = allocb(sizeof(long),0);
		if ( mp == NULL ) {
			cmn_err(CE_NOTE,"mp==NULL in primenotify??");
			return;
		}
		/* not sure if this is needed */
		oldpl = splhi();
		if ( ms->notify == NULL ) {
			ms->notify = mp;
			*(ms->notify->b_wptr++) = 1;
			splx(oldpl);
		}
		else {
			splx(oldpl);
			freemsg(mp);
		}
	}
if(smid_debug)printf("primenotify B\n");
}

static int
smidopen(q, devp, flag, sflag, credp)
queue_t *q;	/* read queue */
dev_t *devp;	/* major/minor device number */
int flag;	/* file flags */
int sflag;	/* stream open flags */
cred_t *credp;	/* credentials */
{
	struct smid_ctlr *mc;
	struct smid_stream *ms;
	int ctlr, n;

if(smid_debug)printf("smidopen A\n");
#ifdef lint
	flag = flag;
#endif
	if ( smid_debug )
		cmn_err(CE_NOTE,"smidopen start flag=%d sflag=%d *devp=0x%x q=0x%x credp=0x%x",flag,sflag,(int)(*devp),(int)q,(int)credp);

	if ( sflag ) { /* check if non-driver open (or CLONEOPEN) */
if(smid_debug)printf("smidopen B\n");
		return ENXIO;
	}

	ctlr = getminor(*devp);
	if ( ctlr >= Smid_nctlr ) {
if(smid_debug)printf("smidopen C\n");
		return ENXIO;
	}

	mc = &Smid_ctlr[ctlr];

	/* all opens are cloning, look for unused entry */
	for ( ms=Smid_stream,n=0; ms<Smid_end; ms++,n++ ) {
		if ( (ms->flags & ISOPEN) == 0 )
			break;
	}
	if ( ms >= Smid_end ) {
if(smid_debug)printf("smidopen D\n");
		cmn_err(CE_NOTE,"smidopen() couldn't find unused structure??? n=%d",n);
		return EAGAIN; /* couldn't find unused structure */
	}

	*devp = makedevice(getmajor(*devp), 0x10 | n);

	ms->rq = q;
	ms->wq = WR(q);
	q->q_ptr = (char*) ms;
	WR(q)->q_ptr = (char*) ms;

	if ( ((ms->flags)&ISOPEN) != 0 )
		cmn_err(CE_NOTE,"midi stream already open!?");

	/* if controller isn't already open, allocate buffer */
	if ( ((mc->flags) & ISOPEN) == 0 ) {
		mc->buff = kmem_alloc(SMID_BUFFSIZE,KM_NOSLEEP);

if ( smid_debug ) cmn_err(CE_NOTE,"(smidopen allocating buff=%x)",(int)(mc->buff));

		mc->buffsize = SMID_BUFFSIZE;
		mc->high = 0;
		mc->flags |= ISOPEN;
	}
	ms->low = mc->high;
	ms->ctlr = ctlr;
	ms->flags |= ISOPEN;
	primenotify(ms);

	if ( smidreset(ctlr,1) ) {	 /* default is UART mode */
if(smid_debug)printf("smidopen E\n");
		(void) msclose(ms);
		return EIO;
	}

	ms->flags &= (~ACTSENSE); /* default is to ignore active sensing */
	ms->clockoffset = lbolt;  /* TIME starts out at 0 */

	if ( smid_debug )
		cmn_err(CE_NOTE,"smidopen successful");

if(smid_debug)printf("smidopen F\n");
	return 0;	/* success */
}

static void
smid_ack(q,mp)
queue_t *q;	/* pointer to the queue */
mblk_t *mp;	/* message pointer */
{
if(smid_debug)printf("smidack A\n");
	mp->b_datap->db_type = M_IOCACK;
	((struct iocblk *)(mp->b_rptr))->ioc_error = 0;
	qreply(q,mp);
if(smid_debug)printf("smidack B\n");
}

static void
smid_nak(q,mp)
queue_t *q;	/* pointer to the queue */
mblk_t *mp;	/* message pointer */
{
if(smid_debug)printf("smidnak A\n");
	mp->b_datap->db_type = M_IOCNAK;
	((struct iocblk *)(mp->b_rptr))->ioc_error = EINVAL;
	qreply(q,mp);
if(smid_debug)printf("smidnak B\n");
}

static int
smidwput(q, mp)
queue_t *q;	/* pointer to the queue */
mblk_t *mp;	/* message pointer */
{
	struct copyresp *csp;
	struct iocblk *iocbp;

if(smid_debug)printf("smidwput A\n");
	switch (mp->b_datap->db_type) {
	case M_DATA:
if(smid_debug)printf("smidwput B\n");
		if ( smid_debug )
			cmn_err(CE_NOTE,"smidwput calling smid_out");
		smid_out((struct smid_stream *)q->q_ptr,
			mp->b_rptr,
			mp->b_wptr - mp->b_rptr);
		freemsg(mp);
		break;
	case M_FLUSH:
if(smid_debug)printf("smidwput C\n");
		if ( smid_debug )
			cmn_err(CE_NOTE,"smidwput M_FLUSH");
		if ( *mp->b_rptr & FLUSHW ) {
			flushq(q,FLUSHDATA);
		}
		if ( *mp->b_rptr & FLUSHR ) {
			*mp->b_rptr &= ~FLUSHW;
			qreply(q,mp);
		}
		else {
			freemsg(mp);
		}
		break;
	case M_IOCDATA:
if(smid_debug)printf("smidwput D\n");
		if ( smid_debug )
			cmn_err(CE_NOTE,"smidwput M_IOCDATA");
		/* probably a response to SMIDDATA */
		csp = (struct copyresp *)mp->b_rptr;
		if ( csp->cp_cmd != SMIDDATA && csp->cp_cmd != SMIDTIME ) {
			/* if this was a module, mp would be passed on */
			cmn_err(CE_NOTE,"M_IOCDATA not SMIDDATA or SMIDTIME?");
			freemsg(mp);
			break;
		}
		if ( csp->cp_rval ) {
			cmn_err(CE_NOTE,"M_IOCDATA  cp_rval != 0 ?");
			freemsg(mp);	/* failure */
			break;
		}
		mp->b_datap->db_type = M_IOCACK;
		mp->b_wptr = mp->b_rptr + sizeof(struct iocblk);
		iocbp = (struct iocblk *)(mp->b_rptr);
		iocbp->ioc_error = 0;
		iocbp->ioc_count = 0;
		iocbp->ioc_rval = 0;
		qreply(q,mp);
		break;
	case M_IOCTL:
if(smid_debug)printf("smidwput E\n");
		if ( smid_debug )
			cmn_err(CE_NOTE,"smidwput M_IOCTL");
		smidioc(q,mp);
		break;
	default:
if(smid_debug)printf("smidwput F\n");
		freemsg(mp);
		break;
	}
if(smid_debug)printf("smidwput G\n");
	return 0;
}

void
smidioc(q,mp)
queue_t *q;
mblk_t *mp;
{
	struct smid_stream *ms;
	int transparent;
	struct iocblk *iocbp;
	struct copyreq *cqp;
	struct smid_data *md;
	int c;

if(smid_debug)printf("smidioc A\n");
	if ( smid_debug )
		cmn_err(CE_NOTE,"smidioc start");
	ms = (struct smid_stream *)q->q_ptr;
	iocbp = (struct iocblk *)(mp->b_rptr);
	switch (iocbp->ioc_cmd) {
	case SMIDACTIVE:
		ms->flags |= ACTSENSE;
		smid_ack(q,mp);
		break;
	case SMIDNOACTIVE:
		ms->flags &= (~ACTSENSE);
		smid_ack(q,mp);
		break;
	case SMIDRESET:
		if ( smidreset(ms->ctlr,1) )
			smid_nak(q,mp);
		else
			smid_ack(q,mp);
		break;
	case SMIDTHRU:
		if ( smidreset(ms->ctlr,0) )
			smid_nak(q,mp);
		else
			smid_ack(q,mp);
		break;
	case SMIDTIMERESET:
		ms->clockoffset = lbolt;
		smid_ack(q,mp);
		break;
	case SMIDSTAT:
		cmn_err(CE_NOTE,"SMIDSTAT ioctl no longer recognized!!");
		smid_nak(q,mp);
		break;
	case SMIDDATA:
		if ( smid_debug )
			cmn_err(CE_NOTE,"smidioc SMIDDATA");
		if ( iocbp->ioc_count == TRANSPARENT ) {
			transparent = 1;
			cqp = (struct copyreq *)mp->b_rptr;
			cqp->cq_size = sizeof(struct smid_data);
			cqp->cq_addr = (caddr_t) *(long*)(mp->b_cont->b_rptr);
			cqp->cq_flag = 0;
		}
		/* Whether it's an I_STR ioctl or a TRANSPARENT one, we */
		/* put the data to be returned into the b_cont data block */
		if ( mp->b_cont )
			freemsg(mp->b_cont);
		mp->b_cont = allocb(sizeof(struct smid_data),0);
		if ( mp->b_cont==NULL || (md=(struct smid_data*)(mp->b_cont->b_rptr))==NULL ) {
			cmn_err(CE_NOTE,"SMIDDATA failed cont or md==NULL");
			mp->b_datap->db_type = M_IOCNAK;
			iocbp->ioc_error = EAGAIN;
			qreply(q,mp);
			break;
		}
		mp->b_cont->b_wptr += sizeof(struct smid_data);
		md->clock = ((1000/HZ)*(lbolt - ms->clockoffset));
		md->nbytes = 0;
		while ( md->nbytes < SMID_DATASIZE ) {
			c = smid_qget(ms);
			if ( c < 0 )
				break;
			md->buff[md->nbytes++] = c;
		}
		primenotify(ms);
		if ( smid_debug )
			cmn_err(CE_NOTE,"smidioc SMIDDATA nbytes=%d",(int)(md->nbytes));

		if ( transparent ) {
			mp->b_datap->db_type = M_COPYOUT;
			mp->b_wptr = mp->b_rptr + sizeof(struct copyreq);
			cqp = (struct copyreq *)mp->b_rptr;
		}
		else {
			mp->b_datap->db_type = M_IOCACK;
			iocbp->ioc_count = sizeof(struct smid_data);
		}
		qreply(q,mp);
		break;

	case SMIDTIME:
		if ( iocbp->ioc_count == TRANSPARENT ) {
			transparent = 1;
			cqp = (struct copyreq *)mp->b_rptr;
			cqp->cq_size = sizeof(long);
			cqp->cq_addr = (caddr_t) *(long*)(mp->b_cont->b_rptr);
			cqp->cq_flag = 0;
		}
		/* Whether it's an I_STR ioctl or a TRANSPARENT one, we */
		/* put the data to be returned into the b_cont data block */
		if ( mp->b_cont )
			freemsg(mp->b_cont);
		mp->b_cont = allocb(sizeof(long),0);
		{ long *lp;
		if ( mp->b_cont==NULL || (lp=(long*)(mp->b_cont->b_rptr))==NULL ) {
			cmn_err(CE_NOTE,"SMIDTIME failed cont or sp==NULL");
			mp->b_datap->db_type = M_IOCNAK;
			iocbp->ioc_error = EAGAIN;
			qreply(q,mp);
			break;
		}
		mp->b_cont->b_wptr += sizeof(long);
		*lp = ((1000/HZ)*(lbolt - ms->clockoffset));
		}

		if ( transparent ) {
			mp->b_datap->db_type = M_COPYOUT;
			mp->b_wptr = mp->b_rptr + sizeof(struct copyreq);
			cqp = (struct copyreq *)mp->b_rptr;
		}
		else {
			mp->b_datap->db_type = M_IOCACK;
			iocbp->ioc_count = sizeof(long);
		}
		qreply(q,mp);
		break;

	default:
		smid_nak(q,mp);
		break;
	}
if(smid_debug)printf("smidioc end\n");
}

static int
smidclose(q,flag,credp)
queue_t *q;	/* read queue */
int flag;	/* file flags */
cred_t *credp;	/* credentials */
{
	struct smid_stream *ms;
	int r;

if(smid_debug)printf("smidclose A\n");
#ifdef lint
	flag = flag;
	credp = credp;
#endif
	if ( smid_debug )
		cmn_err(CE_NOTE,"smidclose start");
	ms = (struct smid_stream *)q->q_ptr;
	if ( ms == NULL ) {
		cmn_err(CE_NOTE,"Hey, ms==NULL in smidclose()!");
		return 1;
	}
	r = msclose(ms);
if(smid_debug)printf("smidclose B\n");
	return r;
}

static void
smid_notify(ctlr)
int ctlr;
{
	register struct smid_stream *ms;
	int oldpl;

if(smid_debug)printf("smidnotify A\n");
	/* notify any streams that haven't been */
	for ( ms=Smid_stream; ms<Smid_end; ms++ ) {
		if ( ((ms->flags) & ISOPEN) == 0 )
			continue;
		/* Make sure we don't get interrupted while we read/modify */
		/* the notify flag. */
		oldpl = splhi();
		if ( ms->ctlr==ctlr && ms->notify != NULL ) {
			mblk_t *savenotify = ms->notify;
			ms->notify = NULL;
			splx(oldpl);
			putnext(ms->rq,savenotify);
		}
		else
			splx(oldpl);
	}
if(smid_debug)printf("smidnotify B\n");
}

void
smidintr(irq)
int irq;
{
	struct smid_ctlr *mc;
	unsigned char c;
	int ctlr;

	ctlr = Irq_to_ctlr[irq];
	mc = &Smid_ctlr[ctlr];
	while ( data_is_available(ctlr) ) {
		c = smid_getdata(ctlr);
		if ( ((mc->flags)&ISOPEN) != 0 ) {
			/* ACK (e.g. from the MPU in response to smidreset()) */
			/* is the same as an active sensing message. */
			if ( c == ACK ) {
				if ( (mc->flags & WAITINGFORACK) != 0 ) {
					untimeout(mc->to_id);
					mc->flags &= (~WAITINGFORACK);
					wakeup((caddr_t)mc);
				}
				/* active sensing is ignored */
			}
			else {
				smid_qput(ctlr,c);
				smid_notify(ctlr);
			}
		}
	}
}

void
smidinit()
{
	register int n;

	/* create an Irq_to_ctlr array so that smidintr() can */
	/* get the ctlr number quickly. */
	for ( n=0; n<NUMIRQ; n++ )
		Irq_to_ctlr[n] = 0;
	for ( n=0; n<Smid_nctlr; n++ ) {
		Irq_to_ctlr[ Ctlr_to_irq[n] ] = n;
		Smid_ctlr[n].buff = NULL;
	}
	for ( n=0; n<SMID_STREAMS; n++ ) {
		Smid_stream[n].flags = 0;
	}
}

static void
smidflush(ctlr)
{
if(smid_debug)printf("smidflush A\n");
	while ( data_is_available(ctlr) )
		(void) smid_getdata(ctlr);
if(smid_debug)printf("smidflush B\n");
}

static int
smid_rawreset(ctlr)
{
	register time_t etime;
	int n;

if(smid_debug)printf("smidrawreset A\n");
	smidflush(ctlr);
	/* try 5 times to get an ACK after a RESET */
	for ( n=0; n<5; n++ ) {
		smid_putcmd(ctlr,RESET);
		/* timeout in 20 milliseconds */
		etime = lbolt + HZ/50;
		while ( lbolt < etime ) {
			if (data_is_available(ctlr) && smid_getdata(ctlr)==ACK)
				return 0;
		}
	}
if(smid_debug)printf("smidrawreset B\n");
	return 1;
}

void
smidstart()
{
	register int n;

	for ( n=0; n<Smid_nctlr; n++ ) {
		printf("SMID Driver, IRQ=%d Addr=0x%x, ",
			Ctlr_to_irq[n],Ctlr_to_data_port[n]);
		if ( smid_rawreset(n) )
			printf("MPU interface is NOT RESPONDING?!\n");
		else
			printf("MPU interface is OK (thru mode set).\n");
	}
}

int
smidreset(ctlr,uart)
{
	register struct smid_ctlr *mc = &Smid_ctlr[ ctlr ];
	int n, oldpl;
	int gotack = 0;

if(smid_debug)printf("smidreset A\n");
	smidflush(ctlr);
	/* try 5 times to get an ACK after a RESET */
	for ( n=0; n<5 && !gotack; n++ ) {
		smid_putcmd(ctlr,RESET);
		oldpl = splhi();
		mc->flags |= WAITINGFORACK;
		/* timeout in 20 milliseconds */
		mc->to_id = timeout(wakeup,(caddr_t)mc,HZ/50);
		if ( sleep((caddr_t)mc,(PCATCH | PZERO+2)) == 1 ) {
			/* if user sent a signal to abort it */
			mc->flags &= (~WAITINGFORACK);
			untimeout(mc->to_id);
			splx(oldpl);
			return 1;
		}
		if ( (mc->flags & WAITINGFORACK) == 0 )
			gotack = 1;
		splx(oldpl);
	}
	if ( ! gotack )
		return 1;
	if ( uart )
		smid_putcmd(ctlr,UART);	/* doesn't send an ACK back */
if(smid_debug)printf("smidreset B\n");
	return 0;
}

static int
smid_wait_for_ready(ctlr)
{
	int tmout;

	for ( tmout=50000; tmout>0; tmout-- ) {
		if ( ready_for_data(ctlr) )
			break;
	}
	if ( tmout <= 0 ) {
		cmn_err(CE_NOTE,"/dev/smid timed out waiting for data ready\n");
		return 0;
	}
	return 1;
}

static void
smid_out(ms,base,count)
struct smid_stream *ms;
unsigned char *base;
int count;
{
	register int ctlr;

	if ( !ms ) {
		cmn_err(CE_NOTE,"ms==NULL in smid_out!!");
		return;
	}
	ctlr = ms->ctlr;
	while ( count ) {
		if ( smid_wait_for_ready(ctlr) ) {
			smid_putdata(ctlr,*base++);
			count--;
		}
	}
}
