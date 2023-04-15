#include "misc.h"
#import <mach.h>
#import <cthreads.h>
#import <stdio.h>
#import <stdlib.h>
#import <fcntl.h>
#import <mach_error.h>
#import <servers/netname.h>
#import <strings.h>
#import <midi/midi_server.h>
#import <midi/midi_reply_handler.h>
#import <midi/midi_timer.h>
#import <midi/midi_timer_reply_handler.h>
#import <midi/midi_error.h>
#import <midi/midi_timer_error.h>
#import <machine/kern_return.h>

static unsigned char inBytes[128];
static int inBytesCtr = 0;
static port_t recv_port;
static port_t recv_reply_port;
static port_set_name_t port_set;
static port_t timer_reply_port;
static msg_header_t *in_msg, *out_msg;
static int Usefixed = 0;

static kern_return_t my_timer_event (
	void *arg,
	timeval_t timeval,
	u_int quanta,
	u_int usec_per_quantum,
	u_int real_usec_per_quantum,
	boolean_t timer_expired,
	boolean_t timer_stopped,
	boolean_t timer_forward)
{
	return KERN_SUCCESS;
}

midi_timer_reply_t midi_timer_reply = {
    my_timer_event,0,0
};

kern_return_t my_ret_raw_data(
	void *		arg,
	midi_raw_t	midi_raw_data,
	u_int		midi_raw_dataCnt)
{
        while (midi_raw_dataCnt--) 
	  inBytes[inBytesCtr++] = midi_raw_data++->data;
	midi_get_data(recv_port, recv_reply_port);
	return KERN_SUCCESS;
}

midi_reply_t midi_reply = {
	my_ret_raw_data,0,0,0,0,0
};

int
statmidi()
{
        int r;
        if (inBytesCtr)
	  return 1;
	in_msg->msg_size = MSG_SIZE_MAX;
	in_msg->msg_local_port = port_set;
	r = msg_receive(in_msg, RCV_TIMEOUT, 0);
	if (r == KERN_SUCCESS) {
	  if (in_msg->msg_local_port == recv_reply_port) {
	      r = midi_reply_handler(in_msg,&midi_reply);
	  }
	  else if (in_msg->msg_local_port == timer_reply_port) {
	      r = midi_timer_reply_handler(in_msg,&midi_timer_reply);
	  }
        }
	return (inBytesCtr != 0);
}

char *
getnmidi(an)
int *an;
{
        *an = inBytesCtr; 
	inBytesCtr = 0;
	return (char *)inBytes;
}

void
endmidi()
{
}

void
rtstart()
{
}

void
rtend()
{
}

#define max(a, b) ((a) > (b) ? (a) : (b))

#define A_MIDI_PORT "midi0"
#define B_MIDI_PORT "midi1"
#define DEFAULT_MIDI_PORT  B_MIDI_PORT 

static port_t dev_port,owner_port,timer_port,xmit_port,xmit_reply_port,
  neg_port;
static u_int queue_max = max(MIDI_COOKED_DATA_MAX, MIDI_RAW_DATA_MAX)*2;

Symlongp Nextmidiport;

static void setPolicyToFixed(cthread_t cthread);
static void setPriorityToMax(cthread_t cthread);

static void setFixedPolicy()
{
   system("enableFixedPolicy");
   setPolicyToFixed(cthread_self());
   setPriorityToMax(cthread_self());
}

void
initmidi()
{
    static int first = 1;
    kern_return_t r;
    char *midiPort;
    char msg[128];

    if ( Usefixed )
	setFixedPolicy();

    if ( first ) 
	first = 0;
    else
	return;
    installnum("Nextmidiport",&Nextmidiport,1L);
    if ( *Nextmidiport == 0 )
        midiPort = A_MIDI_PORT;
    else
	midiPort = B_MIDI_PORT;
    sprintf(msg,"Using MIDI port %s\n",midiPort);
    tprint(msg);

    /*
     * Get a connection to the midi driver.
     */
    r = netname_look_up(name_server_port, "",midiPort, &dev_port);
    if (r != KERN_SUCCESS) {
	    mach_error("timer_track: netname_look_up error", r);
	    exit(1);
    }

    /*
     * Become owner of the device.
     */
    r = port_allocate(task_self(), &owner_port);
    if (r != KERN_SUCCESS) {
	mach_error("allocate owner port", r);
        exit(1);
    }

    neg_port = PORT_NULL;
    r = midi_set_owner(dev_port, owner_port, &neg_port);
    if (r != KERN_SUCCESS) {
	midi_error("become owner", r);
	exit(1);
    }

    /*
     * Get the timer port for the device.
     */
    r = midi_get_out_timer_port(dev_port, &timer_port);
    if (r != KERN_SUCCESS) {
	midi_error("output timer port", r);
	exit(1);
    }

    /*
     * Get the transmit port for the device.
     */
    r = midi_get_xmit(dev_port, owner_port, &xmit_port);
    if (r != KERN_SUCCESS) {
	midi_error("xmit port", r);
	exit(1);
    }

    /*
     * Get the receive port for the device.
     */
    r = midi_get_recv(dev_port, owner_port, &recv_port);
    if (r != KERN_SUCCESS) {
	    midi_error("recv port", r);
	    exit(1);
    }

    /*
     * Tell it to ignore system messages we're not interested in.
     */
    #define MAX_FILTER (MIDI_IGNORE_ACTIVE_SENS | MIDI_IGNORE_TIMING_CLCK \
			 | MIDI_IGNORE_START | MIDI_IGNORE_CONTINUE | \
			 MIDI_IGNORE_STOP| MIDI_IGNORE_SONG_POS_P)
    #define NO_FILTER 0
    
    r = midi_set_sys_ignores(recv_port, NO_FILTER);
    if (r != KERN_SUCCESS) {
	    mach_error("midi_set_sys_ignores", r);
	    exit(1);
    }

    r = port_allocate(task_self(), &timer_reply_port);
    if (r != KERN_SUCCESS) {
	mach_error("allocate timer reply port", r);
	exit(1);
    }

    /*
     * Find out what time it is (and other vital information).
     */
    r = port_allocate(task_self(), &xmit_reply_port);
    if (r != KERN_SUCCESS) {
	mach_error("allocate xmit reply port", r);
	exit(1);
    }

    /*
     * Set the protocol to indicate our preferences.
     */
#ifdef DONTUSE
    r = midi_set_proto(xmit_port,
	MIDI_PROTO_RAW,      // raw, cooked, or packed
        FALSE,			// absolute time codes wanted
        MIDI_PROTO_SYNC_SYS,	// use system clock
        10,			// 10 clocks before data sent
        2,			// 2 clock timeout between input chars
        queue_max);		// maximum output queue size
#else
    r = midi_set_proto(xmit_port,
	MIDI_PROTO_RAW,      // raw, cooked, or packed
        FALSE,			// absolute time codes wanted
        MIDI_PROTO_SYNC_SYS,	// use system clock
        0,			// 0 clocks before data sent
        0,			// 0 clock timeout between input chars
        queue_max);		// maximum output queue size
#endif
    if (r != KERN_SUCCESS) {
        mach_error("midi_set_proto", r);
        exit(1);
    }

    /*
     * Allocate port set.
     */
    r = port_set_allocate(task_self(), &port_set);
    if (r != KERN_SUCCESS) {
        mach_error("allocate port set", r);
        exit(1);
    }

#ifdef DONTUSE
    /*
     * Add timer receive port to port set.
     */
    r = port_set_add(task_self(), port_set, timer_reply_port);
    if (r != KERN_SUCCESS) {
        mach_error("add timer_reply_port to set", r);
        exit(1);
    }
#endif

    r = port_allocate(task_self(), &recv_reply_port);
    if (r != KERN_SUCCESS) {
	    mach_error("allocate timer reply port", r);
	    exit(1);
    }

    /*
     * Add driver reply port to port set.
     */
    r = port_set_add(task_self(), port_set, xmit_reply_port);
    if (r != KERN_SUCCESS) {
	mach_error("add xmit_reply_port to set", r);
	exit(1);
    }


    r = port_set_add(task_self(), port_set, recv_reply_port);
    if (r != KERN_SUCCESS) {
	mach_error("add recv_reply_port to set", r);
	exit(1);
    }

    /*
     * Get it to send us received data.
     */
    r = midi_get_data(recv_port, recv_reply_port);	// from now
    if (r != KERN_SUCCESS) {
	    midi_timer_error("midi_get_data", r);
	    exit(1);
    }

    /*
     * Start the timer up.
     */
    r = timer_start(timer_port, owner_port);
    if (r != KERN_SUCCESS) {
	    midi_error("timer start", r);
	    exit(1);
    }
    in_msg = (msg_header_t *)malloc(MSG_SIZE_MAX);
    out_msg = (msg_header_t *)malloc(MSG_SIZE_MAX);
}

#define IN_SIZE max(MIDI_TIMER_REPLY_INMSG_SIZE, MIDI_REPLY_INMSG_SIZE)
#define OUT_SIZE max(MIDI_TIMER_REPLY_OUTMSG_SIZE, MIDI_REPLY_OUTMSG_SIZE)

int
putnmidi(n,msg)
int n;
char *msg;
{
    int i;
    kern_return_t r;
    midi_raw_data_t	raw[MIDI_RAW_DATA_MAX];
    midi_raw_data_t *p;
    /* copy the midi data into driver style structure */
    for (i = n, p = raw; i--; p++) {
	p->data = *msg++;
	p->quanta = 0;
    }
    r = midi_send_raw_data(xmit_port, raw, n, TRUE);
    if (r == MIDI_WILL_BLOCK) {
	fprintf(stderr,"MIDI_WILL_BLOCK\n");
    } else if (r != KERN_SUCCESS) {
	midi_error("midi_send_raw_data", r);
	exit(1);
    }

    return KERN_SUCCESS;
}


/* Caution: If a thread that uses fixed policy goes into an infinte loop,
   it will lock out all lower-priority threads. Thus, any fixed policy
   thread should go into a msg_receive with a non-0 time-out now and
   then. Be prepared to reboot if your fixed policy goes into an infinite 
   loop! 
*/
   
static int getThreadInfo(int *info,cthread_t cthread)
    /* Gets info about cthread.  Returns 1 for success, 0 for failure. */
{
    kern_return_t ec;
    unsigned int count = THREAD_INFO_MAX;
    ec = thread_info(cthread_thread(cthread), 
		     THREAD_SCHED_INFO, (thread_info_t)info,
		     &count);
    if (ec != KERN_SUCCESS) {
	fprintf(stderr,"Can't get thread scheduling info: %s",
		  mach_error_string(ec));
	return 0;
    }
    return 1;
}

#define QUANTUM 100                /* in ms */

static void setPolicyToFixed(cthread_t cthread)
    /* Set scheduling policy to fixed for the specified cthread.  Note that
     * this will fail if the policy is not enabled for the machine as a whole.
     */
{
    kern_return_t ec;
    int info[THREAD_INFO_MAX];
    thread_sched_info_t sched_info;
    if (!getThreadInfo(info,cthread))
      return;
    sched_info = (thread_sched_info_t)info;
    ec = thread_policy(cthread_thread(cthread), POLICY_FIXEDPRI, QUANTUM);
    if (ec != KERN_SUCCESS) 
	fprintf(stderr,"Can't set thread policy to fixed: %s",
		mach_error_string(ec));
}

static void setPriorityToMax(cthread_t cthread)
    /*
     * Increase our thread priority to our current max priority.
     */
{
    int info[THREAD_INFO_MAX];
    kern_return_t ec;
    thread_sched_info_t sched_info;
    if (!getThreadInfo(info,cthread))
      return;
    sched_info = (thread_sched_info_t)info;
    /* Check for special strange case of priority greater than max, 
     * as can happen with nice -20!. 
     */
    if (sched_info->base_priority < sched_info->max_priority) {
	ec = thread_priority(cthread_thread(cthread),sched_info->max_priority,
			     0);
	if (ec != KERN_SUCCESS) 
	    fprintf(stderr,"Can't set thread priority: %s",
		    mach_error_string(ec));
    }
}

