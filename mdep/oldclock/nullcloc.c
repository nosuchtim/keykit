
static long Mclock = 0;

long
milliclock()
{
	return Mclock++;
}

void
resetclock()
{
	Mclock = 0;
}
