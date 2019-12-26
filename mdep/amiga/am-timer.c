/*
 * This file implements a running millisecond timer using one of
 * the Amiga's hardware timers.
 *
 * This file must be compiled with Lattice -b0 and -v options.
 *
 * Alan Bland, August 1988
 * Updated June 1990 to follow Amiga Mail guidelines.
 */

#include <exec/types.h>
#include <exec/ports.h>
#include <exec/memory.h>
#include <exec/interrupts.h>
#include <hardware/cia.h>
#include <resources/cia.h>

#include <proto/exec.h>

volatile long __far TimeCounter = 0;
extern struct CIA ciab;
static struct Library *CIAResource;
static struct Interrupt interrupt;
static UBYTE interrupting;

void timerhandler()
{
	/* hardware timer interrupt - every 5 milliseconds (1/200 second) */
	TimeCounter += 5;
}

int timer_running()
{
	return (int) interrupting;
}

void starttimer()
{
	ciab.ciacrb &= ~CIACRBF_RUNMODE;
	ciab.ciacrb |= CIACRBF_LOAD | CIACRBF_START;
	SetICR(CIAResource, CIAICRF_TB);
	AbleICR(CIAResource, CIAICRF_SETCLR | CIAICRF_TB);
}

void stoptimer()
{
	AbleICR(CIAResource, CIAICRF_TB);
	ciab.ciacrb &= ~CIACRBF_START;
}

void opentimer()
{
	static char* timername = "key.timer";

	/* install interrupt handler */
	CIAResource = OpenResource(CIABNAME);
	if (CIAResource == NULL) fatal("can't get timer resource");

	interrupt.is_Node.ln_Type = NT_INTERRUPT;
	interrupt.is_Node.ln_Pri = 127;
	interrupt.is_Node.ln_Name = timername;
	interrupt.is_Data = NULL;
	interrupt.is_Code = timerhandler;
	if (AddICRVector(CIAResource, CIAICRB_TB, &interrupt) != NULL) {
		/* ok, there is probably another keykit running */
		/* let's keep going, but don't try the realtime loop */
		/* don't print message because it confuses readmf.k */
		return;
	}

	/* this timer is all mine */
	interrupting = 1;

	/* start continuous timer interrupts */
	/* 1/200 second = 3582 * 1.396 usec */
	ciab.ciatblo = 254;
	ciab.ciatbhi = 13;
	starttimer();
}

void closetimer()
{
	if (interrupting)
	{
		stoptimer();
		RemICRVector(CIAResource, CIAICRB_TB, &interrupt);
		interrupting = 0;
	}
}

/*
 * we never want to reset the clock in case it's being accessed by
 * multiple tasks (not implemented yet, maybe someday)
 */
void mdep_resetclock() {}
