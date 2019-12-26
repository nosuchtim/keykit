
static long Mclock = 0;

long
milliclock( void )
{
	return Mclock++;
}
