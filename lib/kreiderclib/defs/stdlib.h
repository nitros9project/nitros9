/*
 * stdlib.h
 *
 * Notes:
 *
 * Edt/Rev  YYYY/MM/DD  Modified by
 * Comment
 * ------------------------------------------------------------------
 *          2005/08/12  Boisy G. Pitre
 * Brought in from Carl Kreider's CLIB package.
 *
 *          2005/08/14  Boisy G. Pitre
 * stdlib.h now includes types.h so that standard types are pulled
 * in automatically.
 *
 *          2024/07/04  Boisy G. Pitre
 * Incorporated into CMOC.
 */

#ifndef _STDLIB_H
#define	_STDLIB_H

/* Exclude this until there is compiler support
#include		<types.h>
*/

#define	EXIT_FAILURE	1
#define	EXIT_SUCCESS	0

int				exit();
double          atof();
int             atoi();
long            atol();
char           *itoa();
char           *ltoa();
char           *utoa();
int             htoi();
long            htol();
int             max();
int             min();
unsigned        umin();
unsigned        umax();
char           *calloc();
char           *malloc();
char           *realloc();

/*
void     free();
*/

#endif				/* _STDLIB_H */
