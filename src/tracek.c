/*
 *	Copyright 2023 - No one???
 */

#include <math.h>
#include "key.h"
#include "gram.h"

/* tracek() - log formated output to mdep debug logfile
 * invocation:
 * tracek(<bitmask>, <format string>, ...)
 * tracek(<format string>, ...)
 *
 * <bitmask> - conditional mask (against dbgTraceBits)
 *             to control logging; if omitted logging is unconditional
 */
void
bi_tracek(int argc)
{
#ifndef MDEP_ENABLE_DBGTRACE
	dummyusage(argc);
#else
	char *fmt;
	char *ipf;
	int start_arg = 1;
	Datum d, *dp;
	Codep cp;
	char funcname[64];
	int idx;
	int founddigit = 0;
	
	if (argc > 0)
	{
		d = ARG(0);
		if (d.type == D_NUM)
		{
			if (argc == 1)
			{
				/* Set the bitmask since only one numerical arg */
                if (d.u.val > 0)
                {
                    DBGTRACE_SETBITS(d.u.val);
                } else {
                    DBGTRACE_CLRBITS(- d.u.val);
                }
				goto exit;
			}
			if (!DBGTRACE_ENABLED(d.u.val))
			{
				goto exit;
			}
			/* Have more than one arg, format must be 2nd arg */
			d = ARG(1);
			start_arg = 2;
		}

		fmt = needstr("tracek", d);
		reinitmsg3();
		keyprintf(fmt, start_arg, argc-start_arg, ptomsg3);
		dp = T->stackframe;
		cp = (dp - FRAME_FUNC_OFFSET)->u.codep;
		ipf = ipfuncname(cp);
		if (!ipf)
		{
			ipf="??";
		}
		if (DBGTRACE_ENABLED(DBGTRACE_CALLER))
		{
			/* First calling function is "tracek" find who called tracek */
			dp = dp->u.frm;
			if (dp) {
				if (dp < T->stack)
				{
					execerror("%s:%d bad stacktrace");
				}
				cp = (dp - FRAME_FUNC_OFFSET)->u.codep;
				ipf = ipfuncname(cp);
				if (!ipf)
				{
					ipf="??";
				}
			}
			/* Method names have form "<name>__<#>"; copy the func/method name
			 * and back search from end  to skip over trailing "__<#>" */
			for (idx=0; idx<(int)(sizeof(funcname)-2); ++idx)
			{
				char ch;
				ch = ipf[idx];
				if (ch == '\0')
			{
				break;
			}
			funcname[idx] = ch;
		}
		funcname[idx--] = '\0';
		while ((idx > 0) && isdigit(funcname[idx]))
		{
			founddigit = 1;
			idx--;
		}
		if (founddigit && (idx > 2) && (funcname[idx] == '_') && (funcname[idx-1] == '_'))
		{
			/* Strip off the "__#" from name */
			funcname[idx-1] = '\0';
		}
			DBGPRINTF("%s(%s):%d %s", T->filename?T->filename:"??", funcname, T->linenum, Msg3);
		}
		else {
			DBGPRINTF("%s", Msg3);
		}
	}
  exit:
#endif
	ret(Noval);
}
