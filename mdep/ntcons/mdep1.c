#include <windows.h>
#include <malloc.h>
#include <dos.h>
#include <time.h>
#include <io.h>
#include <direct.h>

#include "mdep.h"

#define SEPARATOR "\\"

void
mdep_hello(int argc,char **argv)
{
}

void
mdep_bye(void)
{
}

int
mdep_changedir(char *d)
{
	return _chdir(d);
}

char *
mdep_currentdir(char *buff,int leng)
{
	if ( GetCurrentDirectory(leng,buff) == 0 )
		return NULL;
	else
		return buff;
}

#define fileisdir(fd) (((fd).dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)!=0)

int
mdep_lsdir(char *dir, char *exp, void (*callback)(char *,int))
{
	WIN32_FIND_DATA fd;
	HANDLE h;
	char buff[MAX_PATH];

	strcpy(buff,dir);
	strcat(buff,SEPARATOR);
	strcat(buff,exp);
	h = FindFirstFile(buff,&fd);
	if ( h == INVALID_HANDLE_VALUE )
		return(0);	/* okay, there's just nothing that matches */
	callback(fd.cFileName,fileisdir(fd)?1:0);
	while ( FindNextFile(h,&fd) == TRUE ) {
		callback(fd.cFileName,fileisdir(fd)?1:0);
	}
	return(0);
}

long
mdep_filetime(char *fn)
{
	struct _stat s;

	if ( _stat(fn,&s) == -1 )
		return(-1);
	return((long)s.st_mtime);
}

int
mdep_fisatty(FILE *f)
{
	if ( f == stdin )
		return 1;
	else
		return _isatty(_fileno(f));
}

long
mdep_currtime(void)
{
	SYSTEMTIME st;
	GetSystemTime(&st);
	return (
		(3600*24*30)*st.wMonth
		+ (3600*24)*st.wDay
		+ 3600*st.wHour
		+ 60*st.wMinute
		+ st.wSecond);
}

long
mdep_coreleft(void)
{
	MEMORYSTATUS m;
	m.dwLength = sizeof(MEMORYSTATUS);
	GlobalMemoryStatus(&m);
	return (long) m.dwAvailPageFile;
}

int
mdep_full_or_relative_path(char *path)
{
	if ( *path == '/'
		|| *path=='\\'
		|| *(path+1)==':'
		|| *path == '.' )
		return 1;
	else
		return 0;
}

int
mdep_makepath(char *dirname, char *filename, char *result, int resultsize)
{
	char *p, *q;

	if ( resultsize < (int)(strlen(dirname)+strlen(filename)+5) )
		return 1;

	/* special case for current directory, */
	/* since ./file doesn't always work? */
	if ( strcmp(dirname,".") == 0 ) {
		strcpy(result,filename);
		return 0;
	}

	strcpy(result,dirname);
	if ( *dirname != '\0' )
		strcat(result,SEPARATOR);
	p = strchr(result,'\0');
	strcat(result,filename);
	/* If filename is of form *.*, enforce 8.3 character limits */
	if ( (q=strchr(p,'.')) != NULL ) {
		if ( strlen(q+1) > 3 )
			*(q+4) = '\0';
		if ( (q-p) > 8 )
			strcpy(p+8,q);
	}
	return 0;
}

