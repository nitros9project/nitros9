/*
 * setjmp.h
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

#ifndef _SETJMP_H
#define _SETJMP_H

#ifdef OSK
typedef int     jmp_buf[16];

#else
typedef int     jmp_buf[4];

#endif

#endif				/* _SETJMP_H */
