/*
 * This program is in public domain; written by Dave G. Conroy.
 * This file contains the main driving routine, and some keyboard processing
 * code, for the MicroEMACS screen editor.
 *
 * REVISION HISTORY:
 *
 * 1.0  Steve Wilhite, 30-Nov-85
 *      - Removed the old LK201 and VT100 logic. Added code to support the
 *        DEC Rainbow keyboard (which is a LK201 layout) using the the Level
 *        1 Console In ROM INT. See "rainbow.h" for the function key definitions
.
 *
 * 2.0  George Jones, 12-Dec-85
 *      - Ported to Amiga.
 *
 * 3.0  Bob Santy, 5-Jan-86
 *      - Ported to Tandy Color Computer OS9.
 *      - COCO version has window functions
 *        removed to save memory.
 *      - Source modules split into more,
 *        smaller files.
 * ?.?  Robert Larson
 *      - Os9/68000 version (OSK)
 *      - Fixes to ^X= command   
 */
  
#include        <stdio.h>
#include        "ueed.h"
#ifdef VMS
#include        <ssdef.h>
#define GOOD    (SS$_NORMAL)
#endif

#ifndef GOOD
#define GOOD    0
#endif

#define MAIN1 1
#include "uemain.h"

main(argc, argv)
char    *argv[];
{
        register int    c;
        register int    f;
        register int    n;
        register int    mflag;
        char            bname[NBUFN];

        strcpy(bname, "main");                  /* Work out the name of */
        if (argc > 1)                           /* the default buffer.  */
                makename(bname, argv[1]);
        edinit(bname);                          /* Buffers, windows.    */
        vtinit();                               /* Displays.            */
        if (argc > 1) {
                update();                       /* You have to update   */
                readin(argv[1]);                /* in case "[New file]" */
        }
        lastflag = 0;                           /* Fake last flags.     */
loop:
        update();                               /* Fix up the screen    */
        c = getkey();
        if (mpresf != FALSE) {
                mlerase();
                update();
                if (c == ' ')                   /* ITS EMACS does this  */
                        goto loop;
        }
        f = FALSE;
        n = 1;
        if (c == (CTRL|'U')) {                  /* ^U, start argument   */
                f = TRUE;
                n = 4;                          /* with argument of 4 */
                mflag = 0;                      /* that can be discarded. */
                mlwrite("Arg: 4");
                while ((c=getkey()) >='0' && c<='9' || c==(CTRL|'U') || c=='-'){
                        if (c == (CTRL|'U'))
                                n = n*4;
                        /*
                         * If dash, and start of argument string, set arg.
                         * to -1.  Otherwise, insert it.
                         */
                        else if (c == '-') {
                                if (mflag)
                                        break;
                                n = 0;
                                mflag = -1;
                        }
                        /*
                         * If first digit entered, replace previous argument
                         * with digit and set sign.  Otherwise, append to arg.
                         */
                        else {
                                if (!mflag) {
                                        n = 0;
                                        mflag = 1;
                                }
                                n = 10*n + c - '0';
                        }
                        mlwrite("Arg: %d", (mflag >=0) ? n : (n ? -n : -1));
                }
                /*
                 * Make arguments preceded by a minus sign negative and change
                 * the special argument "^U -" to an effective "^U -1".
                 */
                if (mflag == -1) {
                        if (n == 0)
                                n++;
                        n = -n;
                }
        }
        if (c == (CTRL|'X'))                    /* ^X is a prefix       */
                c = CTLX | getctl();
        if (kbdmip != NULL) {                   /* Save macro strokes.  */
                if (*kbdmip == kbdm[NKBDM-6])
/*                if (c != ( CTLX | ')' ) && kbdmip > &kbdm[NKBDM-6]) */
		{
                        ctrlg(FALSE, 0);
                        goto loop;
                }
                if (f != FALSE) {
                        *kbdmip++ = (CTRL|'U');
                        *kbdmip++ = n;
                }
                *kbdmip++ = c;
        }
        execute(c, f, n);                       /* Do it.               */
        goto loop;
}

