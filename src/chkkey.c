
#include "key.h"

#define KEYLIB_K "keylib.k"


/* Duplicate string str */
char *
mystrdup(const char *str)
{
	char *p;
	unsigned int len;

	len = strlen(str);
	p = kmalloc(len+1, "chkkey");
	return strcpy(p, str);
}

/* Structure to track all files in a library directory(skipping keylib.k) */
struct ftime {
	long keylib_mtime; /* Modification time of keylib.k (or zero) */
	struct fileandtime {
		long mtime;
		char *fname;
	} *arry;
	unsigned int dim;
	unsigned int count;
} ftime;

/* Free the ftime structure data that holds file name and modification time */
void
freeftime(void)
{
	unsigned int i;
	if ( ftime.arry != NULL) {
		for (i=0; i<ftime.count; ++i)
		{
			kfree(ftime.arry[i].fname);
		}
		kfree(ftime.arry);
	}
	memset(&ftime, 0x00, sizeof(ftime));
}

void
addfilentime(char *fname, long mtime)
{
	char *dupfname;
	struct fileandtime *newftimearry;

	if ( ftime.count == ftime.dim )
	{
		ftime.dim = (3 * ftime.dim) / 2;
		if (ftime.dim < 20) {
			ftime.dim = 20;
		}
		newftimearry = realloc(ftime.arry, ftime.dim * sizeof(*ftime.arry));
		if ( newftimearry == NULL ) {
			eprint("Failed to allocates space for %d fileandtime structs\n", ftime.dim);
			freeftime();
			return;
		}
		ftime.arry = newftimearry;
	}
	dupfname = mystrdup(fname);
	if ( dupfname == NULL )
	{
		eprint("Failed to duplicate '%s' string\n", fname);
		return;
	}
	ftime.arry[ftime.count].mtime = mtime;
	ftime.arry[ftime.count].fname = dupfname;
	ftime.count++;
}

char *lsdir_prefix; /* directory prefix given mdep_lsdir() */

void
cback(char *fname, int type)
{
	char buf[BUFSIZ];
	long mtime;
	unsigned int len;

	if ( type != 0 ) {
		return;
	}

	len = strlen( fname );
	if ( strcasecmp(&fname[len-2], ".k") != 0 ) {
		return;
	}
	snprintf(buf, sizeof(buf), "%s%s%s", lsdir_prefix, SEPARATOR, fname);
	mtime = mdep_filetime(buf);
	
	if ( strcasecmp(fname, KEYLIB_K) == 0 ) {
		/* Skip keylib.k, but save its filetime */
		ftime.keylib_mtime = mtime;
	}
	else
	{
		addfilentime(fname,mtime);
	}
}


struct keylibklines {
	char **arry;
	unsigned int dim;
	unsigned int count;
} keylibklines;

/* Add a line to the list read */
void
addline(const char *line)
{
	char **newarry;
	char *p;
	
	if ( keylibklines.count == keylibklines.dim )
	{
		keylibklines.dim = (3 * keylibklines.dim) / 2;
		if (keylibklines.dim < 20) {
			keylibklines.dim = 20;
		}
		newarry = realloc(keylibklines.arry, keylibklines.dim * sizeof(char **));
		if ( newarry == NULL ) {
			eprint("Failed to allocate space for %d lines\n", keylibklines.dim);
			exit(1);
		}
		keylibklines.arry = newarry;
	}
	/* Dup the line and add to tail of array */
	p = mystrdup(line);
	if ( p == NULL )
	{
		eprint("Failed to duplicate '%s' string\n", p);
		exit(1);
	}
	keylibklines.arry[keylibklines.count++] = p;
}

void
sortkeylibklines(void)
{
	unsigned int i, j;
	for (i=0; i<keylibklines.count; ++i) {
		for (j=i+1; j<keylibklines.count; ++j) {
			if ( strcmp(keylibklines.arry[i], keylibklines.arry[j]) > 0 ) {
				char *tmp;
				tmp = keylibklines.arry[i];
				keylibklines.arry[i] = keylibklines.arry[j];
				keylibklines.arry[j] = tmp;
			}
		}
	}
}

void
freekeylibklines(void)
{
	unsigned int i;
	for (i=0; i<keylibklines.count; ++i)
	{
		kfree(keylibklines.arry[i]);
	}
	kfree(keylibklines.arry);
	memset(&keylibklines, 0x00, sizeof(keylibklines));
}

int
writekeylibklines(char *keylibdir)
{
	char fullfname[BUFSIZ];
	FILE *f;
	unsigned int i;

	snprintf(fullfname, sizeof(fullfname), "%s%s%s", keylibdir, SEPARATOR, KEYLIB_K);
	if ( *Debugkeylib ) {
		eprint("Write %u lines to '%s'\n", keylibklines.count, fullfname);
	}
	f = fopen(fullfname, "w");
	if ( f == NULL ) {
		eprint("Failed to open '%s' for writing\n", fullfname);
		// failed = 1;
		return -1;
	}

	for (i=0; i<keylibklines.count; ++i) {
		fprintf(f, "%s\n", keylibklines.arry[i]);
	}
	fclose(f);
	return 0;
}

int
rebuildkeylibdir(char *keylibdir, const char *reason)
{
	char fullfname[BUFSIZ];
	char buff[BUFSIZ];
	char line[BUFSIZ];
	unsigned int i;
	unsigned int l;
	char *p, *q;
	FILE *f;

	eprint("Rebuild %s%s%s since it %s\n", keylibdir, SEPARATOR, KEYLIB_K, reason);
	for (i=0; i<ftime.count; ++i) {
		snprintf(fullfname, sizeof(fullfname), "%s%s%s", keylibdir, SEPARATOR, ftime.arry[i].fname);
		f = fopen(fullfname, "r");
		if ( f == NULL ) {
			eprint("Failed to open '%s%s%s' for reading\n", keylibdir, SEPARATOR, ftime.arry[i].fname);
			return -1;
		}
		if ( *Debugkeylib ) {
			eprint("Scanning %s...\n",fullfname);
		}
		while ( myfgets(buff,sizeof(buff),f) != NULL ) {

			/* look for lines beginning with function or class */

			if ( strncmp(buff,"function",8) == 0 ) {
				l = 8;
			}
			else if ( strncmp(buff,"class",5) == 0 ) {
				l = 5;
			}
			else {
				continue;
			}
			if ( ! isspace(buff[l]) ) {
				continue;
			}
			q = &buff[l+1];
			while ( isspace(*q) ) {
				q++;
			}
			p = q;
			while ( *q!=0 && strchr("({ \t\n\r",*q)==NULL ) {
				q++;
			}
			if ( *q != '\0' ) {
				*q = '\0';
			}
			snprintf(line,sizeof(line),"#library %s %s",ftime.arry[i].fname,p);
			addline(line);
		}
		fclose(f);
	}
	sortkeylibklines();
	writekeylibklines(keylibdir);
	freekeylibklines();
	
	return 0;
}

/* If keylib.k in keylibdir doesn't exist, or is out of date
 * relative to any .k file in keylibdir, then regenerate it. */
int
checkkeylibdir(char *keylibdir)
{
	const char *rebuild_reason = NULL;
	unsigned int i;
	
	if ( *Debugkeylib ) {
		eprint("'%s'\n", keylibdir);
	}

	lsdir_prefix=keylibdir;
	mdep_lsdir(keylibdir,"*",cback);
	if ( ftime.count != 0L ) {
		if ( ftime.keylib_mtime == 0L ) {
			/* keylib.k not found - needs to be rebuilt */
			rebuild_reason = "doesn't exist";
		}
		else {
			if ( *Debugkeylib ) {
				eprint("keylib.k modification time %ld\n", ftime.keylib_mtime);
				eprint("Number of .k files in %s: %u\n", keylibdir, ftime.count);
			}
			for (i=0; i<ftime.count; ++i) {
				if ( ftime.arry[i].mtime > ftime.keylib_mtime ) {
					eprint("%s%s%s is newer than %s%s%s\n", keylibdir, SEPARATOR, ftime.arry[i].fname, keylibdir, SEPARATOR, KEYLIB_K);
					/* keylib.k is out of date - needs to be rebuilt */
					rebuild_reason = "out of date";
				}
			}
		}

		if ( rebuild_reason != NULL ) {
			rebuildkeylibdir(keylibdir, rebuild_reason);
		}
	}
	
	return 0;
}

int
checkkeylib(void)
{
	int ret = 0;
	char *dupkeypath;
	char *pathsep = PATHSEP;
	unsigned int pathseplen;
	char *p, *q;

	/* For each <dir> part of mdep_keypath() do:
	 * 1) determine whether <dir>/keylib.k exists
	 * 2) if so, determine if any <dir>/<file>.k (except keylib.k) is newer
	 * 3) if 1) is false, or 2) is true then regenerate <dir>/keylib.k */

	dupkeypath = mystrdup(mdep_keypath());
	pathseplen = strlen(pathsep);
	for (p = dupkeypath; *p; p=q+pathseplen) {
		q = strstr(p, pathsep);
		if ( q != NULL ) {
			/* Break out directory component (spans from p to q) */
			*q = '\0';
		}
		if ( checkkeylibdir(p) != 0 ) {
			ret = -1;
			goto cleanup;
		}
		if ( q == NULL ) {
			break;
		}
	}
  cleanup:
	freeftime();
	kfree(dupkeypath);
	if ( ret < 0 ) {
		eprint("checkkeylib() failed...\n");
		exit(1);
	}
	return ret;
}
