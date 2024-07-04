/*
 * dir.h - Defines RBF directory structures
 *
 * Notes:
 *
 * Edt/Rev  YYYY/MM/DD  Modified by
 * Comment
 * ------------------------------------------------------------------
 *          2005/08/12  Boisy G. Pitre
 * Brought in from Carl Kreider's CLIB package.
 *
 *          2024/07/04  Boisy G. Pitre
 * Incorporated into CMOC.
 */

#ifndef _DIR_H
#define	_DIR_H

struct direct
{
	long            d_addr;	/* file desc addr */
	char            d_name[30];	/* directory entry name */
};


typedef struct
{
	int             dd_fd;	/* fd for open directory */
	char            dd_buf[32];	/* a one entry buffer */
}

                DIR;


#define DIRECT       struct direct
#define rewinddir(a) seekdir(a, 0L)

extern DIR     *opendir();
extern DIRECT  *readdir();
extern long     telldir();
extern /* void */ seekdir(), closedir();

#endif				/* _DIR_H */
