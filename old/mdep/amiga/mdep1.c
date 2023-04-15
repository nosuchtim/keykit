/*
 *	Copyright 1996 AT&T Corp.  All rights reserved.
 */

/*
 * Amiga code for keykit
 *	Alan Bland
 *	mab@druwy.att.com
 */

#include <stdio.h>
#include <signal.h>
#include <string.h>
#include <time.h>
#include <dos/dos.h>
#include <dos/dosextens.h>

#include <proto/dos.h>
#include <proto/exec.h>

#include "mdep.h"

static long Olddir;
void (*ami_byefcn)( void ) = NULL;

mdep_fisatty(FILE *f)
{
	return((f==stdin || f==stdout || f==stderr)?1:0);
}

/* return file modification time in seconds */
long mdep_filetime(char *fn)
{
	extern long	getft();
	return ( getft(fn) );
}

/* return current time in seconds */
long mdep_currtime( void )
{
	extern long	time();
	return ( time((long *) 0) );
}

char *
mdep_currentdir( char *buff, int leng )
{
	return( getcwd(buff, leng) );
}

int
mdep_lsdir(char *dir, char *exp, void (*callback)(char *,int))
{
	__aligned struct AnchorPath anch;
	long error;
	long dlock, old;

	if( strcmp( dir, "." ) == 0 )
		dir = "";

	if( strcmp( exp, "*" ) == 0 )
		exp = "#?";

	if( ( dlock = Lock( dir, ACCESS_READ ) ) == 0 )
	{
		printf( "The directory\n\"%s\"\ndoes not exist\n", dir );
		return 0;
	}
	old = CurrentDir( dlock );

	if( strcmp( exp, "*.*" ) == 0)
		exp = "#?";
	else if( strcmp( exp, "*.k" ) == 0)
		exp = "#?.k";

	memset( &anch, 0, sizeof( anch ) );
	anch.ap_Flags |= APF_DOWILD;
	anch.ap_Strlen = 0;
	if( ( error = MatchFirst( exp, &anch ) ) != 0 )
	{
		if( old )
			CurrentDir( old );
		UnLock( dlock );
		return -1;
	}

	do {
		(*callback)( anch.ap_Info.fib_FileName, anch.ap_Info.fib_DirEntryType > 0 );
	} while( MatchNext( &anch ) == 0 );

	MatchEnd( &anch );
	if( old )
		CurrentDir( old );
	UnLock( dlock );
	return( 0 );
}

mdep_full_or_relative_path( char *path )
{
	if( strchr( path, ':' ) )
		return 1;
	else
		return 0;
}

void mdep_hello(int argc, char **argv)
{
	Olddir = 0;
}

mdep_changedir( char *d )
{
	static int didcd;
	long l, od;

	if( ( l = Lock( d, ACCESS_READ ) ) == NULL )
	{
		return( 1 );
	}
	if( didcd == 0 )
	{
		Olddir = CurrentDir( l );
		didcd = 1;
	}
	else
	{
		od = CurrentDir( l );
		if( od ) UnLock( od );
	}
	return( 0 );
}

/*
 * Amiga-dependent clean-up
 */
void mdep_bye( void )
{
	if( Olddir )
	{
		long od;
		od = CurrentDir( Olddir );
		if( od ) UnLock( od );
	}
	if( ami_byefcn )
		(*ami_byefcn)();
}

/*
 * build a pathname from a directory/device prefix and a filename.
 * amiga does not use SEPARATOR at the root of a device
 * like most other systems do.  acceptable formats are:
 *	device:fname
 *	device:dir/fname
 *	device:dir/dir/fname ...
 * the file name is left unchanged if it contains a
 * colon or begins with a slash.
 */

int
mdep_makepath(char *dname, char *fname, char *result, int resultsize)
{
	if( strchr(fname,':') == NULL && strchr( fname, '/' ) == NULL )
	{
		if( ( strlen( dname ) + strlen( fname ) + 1 ) >= resultsize )
		{
			return( 1 );
		}
		else
		{
			strcpy(result, dname);
			if (result[strlen(result)-1] != ':')
				strcat(result,"/");
			strcat(result,fname);
		}
	} else {
		strcpy(result,fname);
	}
	return( 0 );
}

/*
 * return number of bytes of free memory
 */
long mdep_coreleft()
{
	return (long) (AvailMem(MEMF_CHIP) + AvailMem(MEMF_FAST));
}
