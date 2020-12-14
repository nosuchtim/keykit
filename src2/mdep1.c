extern "C" {

#include "mdep.h"

void mdep_destroywindow(void);

#define SEPARATOR "\\"

void
mdep_hello(int argc,char **argv)
{
}

void
mdep_bye(void)
{
	mdep_destroywindow();
}

int
mdep_changedir(char *d)
{
	return -1;
}

char *
mdep_currentdir(char *buff,int leng)
{
	if ( leng < 2 ) {
		return NULL;
	}
	strcpy(buff,".");
	return buff;
}

#define fileisdir(fd) (((fd).dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)!=0)

int
mdep_lsdir(char *dir, char *exp, void (*callback)(char *,int))
{
	// while ( FindNextFile(h,&fd) == TRUE )
	//  	callback(fd.cFileName,fileisdir(fd)?1:0);
	return(0);
}

long
mdep_filetime(char *fn)
{
	return(-1);
}

int
mdep_fisatty(FILE *f)
{
	if ( f == stdin )
		return 1;
	else
		return 0;
}

#if 0
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
#endif

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
	char *p;

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

	return 0;
}

#ifdef LOCALUNLINK
int
unlink(const char *path)
{
	return remove(path);
}
#endif

}
