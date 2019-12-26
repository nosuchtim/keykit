
// Getting a Full Pathname
// Utilities from the Apple Q&A Stack showing how to get the full
// pathname of a file.  Note that this is NOT the recommended way
// to specify a file to Toolbox routines.  These routines should be
// used for displaying full pathnames only.

#include "pathname.h"

// Assumes inclusion of <MacHeaders>
#define haveAUX() 0

/*
 * Pascal string utilities
 */
/*
 * pstrcat - add string 'src' to end of string 'dst'
 */
void pstrcat(StringPtr dst, StringPtr src)
{
	/* copy string in */
	BlockMove(src + 1, dst + *dst + 1, *src);
	/* adjust length byte */
	*dst += *src;
}

/*
 * pstrinsert - insert string 'src' at beginning of string 'dst'
 */
void pstrinsert(StringPtr dst, StringPtr src)
{
	/* make room for new string */
	BlockMove(dst + 1, dst + *src + 1, *dst);
	/* copy new string in */
	BlockMove(src + 1, dst + 1, *src);
	/* adjust length byte */
	*dst += *src;
}

void PathNameFromDirID(long dirID, short vRefNum, StringPtr fullPathName)
{
	DirInfo	block;
	Str255	directoryName;
	OSErr	err;
	Boolean	root;

	fullPathName[0] = '\0';
	root = true;

	block.ioDrParID = dirID;
	block.ioNamePtr = directoryName;
	do {

			block.ioVRefNum = 0; 		// use default volume - can't get vRefNum to work;
			block.ioFDirIndex = -1;		// directories only
			block.ioDrDirID = block.ioDrParID;

			err = PBGetCatInfoSync( (CInfoPBPtr) &block);

			if (!root) {
				pstrcat(directoryName, (StringPtr)"\p:");
			}
			pstrinsert(fullPathName, directoryName);
			
			root = false;

	} while (block.ioDrDirID != fsRtDirID /* 2 */);
}


/*
PathNameFromWD:
Given an HFS working directory, this routine returns the full pathname that
corresponds to it. It does this by calling PBGetWDInfo to get the VRefNum and
DirID of the real directory. It then calls PathNameFromDirID, and returns its
result.

*/
void PathNameFromWD(long vRefNum, StringPtr pathName)
{
	WDPBRec	myBlock;
	OSErr	err;
	/*
 	PBGetWDInfo has a bug under A/UX 1.1.  If vRefNum is a real
	 vRefNum and not a wdRefNum, then it returns garbage.
 	Since A/UX has only 1 volume (in the Macintosh sense) and
 	only 1 root directory, this can occur only when a file has been
 	selected in the root directory (/).
 	So we look for this and hardcode the DirID and vRefNum.
	*/
	if ((haveAUX()) && (vRefNum == -1))
			PathNameFromDirID(2, -1, pathName);
	else {
			myBlock.ioNamePtr = nil;
			myBlock.ioVRefNum = vRefNum;
			myBlock.ioWDIndex = 0;
			myBlock.ioWDProcID = 0;
	/*
	 Change the Working Directory number in vRefnum into a real
	vRefnum and DirID. The real vRefnum is returned in ioVRefnum,
	 and the real DirID is returned in ioWDDirID.
	*/
			err = PBGetWDInfoSync(&myBlock);
			if (err != noErr)
					return;
			PathNameFromDirID(myBlock.ioWDDirID, myBlock.ioWDVRefNum,
					pathName);
	}
}


