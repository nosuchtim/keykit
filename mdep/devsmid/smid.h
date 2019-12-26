#define SMIDC		('M'<<8)
#define SMIDRESET	(SMIDC|01)
#define SMIDTIME	(SMIDC|02)
#define SMIDTIMERESET	(SMIDC|03)
#define SMIDACTIVE	(SMIDC|04)
#define SMIDTHRU	(SMIDC|05)
#define SMIDNOACTIVE	(SMIDC|06)
#define SMIDSTAT	(SMIDC|07)
#define SMIDDATA	(SMIDC|010)

#define NUMIRQ 16
#define SMID_STREAMS 16
#define SMID_BUFFSIZE 8096
#define SMID_DATASIZE 64

struct smid_data {
	long clock;
	off_t nbytes;
	unsigned char buff[SMID_DATASIZE];
};

#ifdef _KERNEL

/* bits for midi.flags */
#define ISOPEN		01
/* active sensing is passed on to the reader */
#define ACTSENSE	02
/* when waiting for ACK to come back after a reset */
#define WAITINGFORACK	04

/* There's one of these structures for each open stream */
struct smid_stream {
	int flags;
	time_t clockoffset;
	queue_t *wq;		/* write queue */
	queue_t *rq;		/* read queue */
	int ctlr;		/* controller */
	off_t	low;		/* next unread byte in controller's buff */
	mblk_t *notify;
};

/* Each SMID controller has a separate buffer, shared by all streams */
/* that are open on it.  */

struct smid_ctlr {
	int 		to_id;		/* timeout id */
	int		flags;		/* ISOPEN and WAITINGFORACK */
	unsigned char	*buff;
	off_t		buffsize;
	off_t		low;
	off_t		high;
};

extern int Irq_to_ctlr[];
extern int Ctlr_to_irq[];
extern int Ctlr_to_data_port[];
extern int Ctlr_to_status_port[];
extern int Smid_nctlr;			/* number of MPU controllers */
extern struct smid_stream Smid_stream[];	/* per stream */
extern struct smid_stream *Smid_end;
extern struct smid_ctlr Smid_ctlr[];		/* per controller */

#endif
