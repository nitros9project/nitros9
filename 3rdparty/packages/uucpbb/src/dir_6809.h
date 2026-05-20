
#ifndef UUCPBB_DIR_6809_H
#define UUCPBB_DIR_6809_H

#include <sys/types.h>

struct direct {
   long  d_addr;        /* file desc addr */
   char  d_name[30];    /* directory entry name */
   } ;

struct fildes {
   mode_t  fd_att;      /* file attributes: dsewrewr */
   uid_t   fd_own;      /* file owner */
   _BYTE   fd_date[5];  /* last written date/time */
   nlink_t fd_link;     /* link count */
   off_t   fd_fsize;    /* file size */
   _BYTE   fd_dcr[3];   /* creation date */
   struct {
      _BYTE addr[3];    /* LSN of segment start */
      size_t size;      /* byte size of segment */
      } fdseg[48];
   };

/* there is #define DIR in stdio.h.  This causes a problem with using DIR
** for this typedef.  Changing it to _DIR will eliminate this problem.
** -- Bob Billson
*/

typedef struct {
   int   dd_fd;         /* fd for open directory */
   char  dd_buf[32];    /* a one entry buffer */
   } DIR;

#define DIRECT       struct direct
#define rewinddir(a) seekdir(a, 0L)

extern DIR           *opendir();
extern DIRECT        *readdir();
extern long          telldir();
extern int /* void */    seekdir(), closedir();

#endif
