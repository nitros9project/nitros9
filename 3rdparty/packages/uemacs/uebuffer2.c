/*
 * Buffer management.
 * Some of the functions are internal,
 * and some are actually attached to user
 * keys. Like everyone else, they set hints
 * for the display system.
 */
#include        <stdio.h>
#include        "ueed.h"

#ifndef OS9
xitoa(buf, width, num)
register char   buf[];
register int    width;
register int    num;
{
        buf[width] = 0;                         /* End of string.       */
        while (num >= 10) {                     /* Conditional digits.  */
                buf[--width] = (num%10) + '0';
                num /= 10;
        }
        buf[--width] = num + '0';               /* Always 1 digit.      */
        while (width != 0)                      /* Pad with blanks.     */
                buf[--width] = ' ';
}

/*
 * The argument "text" points to
 * a string. Append this line to the
 * buffer list buffer. Handcraft the EOL
 * on the end. Return TRUE if it worked and
 * FALSE if you ran out of room.
 */
addline(text)
char    *text;
{
        register LINE   *lp;
        register int    i;
        register int    ntext;

        ntext = strlen(text);
        if ((lp=lalloc(ntext)) == NULL)
                return (FALSE);
        for (i=0; i<ntext; ++i)
                lputc(lp, i, text[i]);
        blistp->b_linep->l_bp->l_fp = lp;       /* Hook onto the end    */
        lp->l_bp = blistp->b_linep->l_bp;
        blistp->b_linep->l_bp = lp;
        lp->l_fp = blistp->b_linep;
        if (blistp->b_dotp == blistp->b_linep)  /* If "." is at the end */
                blistp->b_dotp = lp;            /* move it to new line  */
        return (TRUE);
}
#endif

/*
 * Look through the list of
 * buffers. Return TRUE if there
 * are any changed buffers. Buffers
 * that hold magic internal stuff are
 * not considered; who cares if the
 * list of buffer names is hacked.
 * Return FALSE if no buffers
 * have been changed.
 */
anycb()
{
        register BUFFER *bp;

        bp = bheadp;
        while (bp != NULL) {
                if ((bp->b_flag&BFTEMP)==0 && (bp->b_flag&BFCHG)!=0)
                        return (TRUE);
                bp = bp->b_bufp;
        }
        return (FALSE);
}

/*
 * Find a buffer, by name. Return a pointer
 * to the BUFFER structure associated with it. If
 * the named buffer is found, but is a TEMP buffer (like
 * the buffer list) conplain. If the buffer is not found
 * and the "cflag" is TRUE, create it. The "bflag" is
 * the settings for the flags in in buffer.
 */
BUFFER *bfind(bname, cflag, bflag)
register char *bname;
{
        register BUFFER *bp;
        register LINE   *lp;

        bp = bheadp;
        while (bp != NULL) {
                if (strcmp(bname, bp->b_bname) == 0) {
                        if ((bp->b_flag&BFTEMP) != 0) {
                                mlwrite("Cannot select builtin buffer");
                                return (NULL);
                        }
                        return (bp);
                }
                bp = bp->b_bufp;
        }
        if (cflag != FALSE) {
                if ((bp=(BUFFER *)malloc(sizeof(BUFFER))) == NULL)
                        return (NULL);
                if ((lp=lalloc(0)) == NULL) {
                        free((char *) bp);
                        return (NULL);
                }
                bp->b_bufp  = bheadp;
                bheadp = bp;
                bp->b_dotp  = lp;
                bp->b_doto  = 
                bp->b_markp = 
                bp->b_marko = 
                bp->b_nwnd  = 0;
                bp->b_linep = lp;
                bp->b_flag  = bflag;
                strcpy(bp->b_fname, "");
                strcpy(bp->b_bname, bname);
                lp->l_fp = lp;
                lp->l_bp = lp;
        }
        return (bp);
}

/*
 * This routine blows away all of the text
 * in a buffer. If the buffer is marked as changed
 * then we ask if it is ok to blow it away; this is
 * to save the user the grief of losing text. The
 * window chain is nearly always wrong if this gets
 * called; the caller must arrange for the updates
 * that are required. Return TRUE if everything
 * looks good.
 */
bclear(bp)
register BUFFER *bp;
{
        register LINE   *lp;
        register int    s;
        
        if ((bp->b_flag&BFTEMP) == 0            /* Not scratch buffer.  */
        && (bp->b_flag&BFCHG) != 0              /* Something changed    */
        && (s=mlyesno("Discard changes")) != TRUE)
                return (s);
        bp->b_flag  &= ~BFCHG;                  /* Not changed          */
        while ((lp=lforw(bp->b_linep)) != bp->b_linep)
                lfree(lp);
        bp->b_dotp  = bp->b_linep;              /* Fix "."              */
        bp->b_doto  = 
        bp->b_markp =                      /* Invalidate "mark"    */
        bp->b_marko = 0;
        return (TRUE);
}

