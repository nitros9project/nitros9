/*
 * sets.h
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

#ifndef _SETS_H
#define _SETS_H

#define SETMAX   255		/* ie 0..255 */
char           *allocset();
char           *addc2set(s, c);
char           *adds2set(s, p);
char           *rmfmset(s, c);
int             smember(s, c);
char           *sunion(s1, s2);
char           *sintersect(s1, s2);
char           *sdifference(s1, s2);
char           *copyset(s1, s2);
char           *dupset(s);

#endif				/* _SETS_H */
