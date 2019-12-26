
static long Mclock = 0;

long
mdep_milliclock()
{
	return Mclock++;
}

void
mdep_resetclock()
{
	Mclock = 0;
}
