/*
 * The routines in this file provide support for the COCO /TERM  terminal
 * under OS9. The serial I/O services are provided by routines in
 * "termio.c".
 * Adapted 1/5/86 by:
 * Bob Santy
 * 5 Johnson Ave
 * Medford, MA 02155
 * (617) 488-7160
 */

#include        <stdio.h>
#include        "ueed.h"

/* Color Computer /TERM specifications        */
#define NROW    16    /* Screen size.         */
#define NCOL    32    /* Edit if you want to. */
#define BEL     0x07  /* BEL character.       */
#define ESC     0x1B  /* ESC character.       */
#define CURSOR  0x02  /* Commands manual p126 */
#define CEOL    0x04  /* 1.01 Supplement      */
#define CEOS    0x0B  /* 1.01 Supplement      */

extern  int     ttopen();               /* Forward references.          */
extern  int     ttgetc();
extern  int     ttputc();
extern  int     ttflush();
extern  int     ttclose();
extern  int     cocomove();
extern  int     cocoeeol();
extern  int     cocoeeop();
extern  int     cocobeep();
extern  int     cocoopen();

/*
 * Standard terminal interface dispatch table. Most of the fields point into
 * "termio" code.
 */
TERM    term    = {
        NROW-1,
        NCOL,
        cocoopen,
        ttclose,
        ttgetc,
        ttputc,
        ttflush,
        cocomove,
        cocoeeol,
        cocoeeop,
        cocobeep
};

/*
 * Cursor move command.
 */
 cocomove(row, col)
{
        ttputc(CURSOR);
        cocoparm(col);
        cocoparm(row);
}

/*
 * Clear to end of line.
 */
cocoeeol()
{
        ttputc(CEOL);
}

/*
 * Clear to end of screen.
 */
cocoeeop()
{
        ttputc(CEOS);
}

/*
 * Sound the horn (will work in
 * OS9 Rev 2.00
 */
cocobeep()
{
        ttputc(BEL);
        ttflush();
}

/*
 * Cursor position needs 32 added to
 * X and Y coordinates.
 */
cocoparm(n)
register int    n;
{
        ttputc(n + 32);
}

/*
 * Open terminal.  No special codes.
 */
cocoopen()
{
        ttopen();
}

