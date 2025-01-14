/*
 * math.h - Transcendental math functions
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

#ifndef _MATH_H
#define _MATH_H

double          acos(), asin(), atan(), sin(), cos(), tan();
double          pow(), sinh(), cosh(), tanh(), asinh(), acosh(), atanh();
double          exp(), antilg(), log10(), log();
double          trunc(), sqrt(), sqr(), inv();
double          dexp(), dabs();
int             rad(), deg();

#endif				/* _MATH_H */
