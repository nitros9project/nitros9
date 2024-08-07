/*
 * time.h - OS-9 time definitions
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

#ifndef _TIME_H
#define	_TIME_H

/* structure for the 'setime()' and 'getime()' calls */

struct sgtbuf
{
	char            t_year,
	                t_month,
	                t_day,
	                t_hour,
	                t_minute,
	                t_second;
};

/* system dependent value */
#ifdef COCO
#define tps		60	/* ticks per second */
#else
#ifdef LEVEL2
#define tps     100		/* ticks per second */
#else
#define tps     10		/* ticks per second */
#endif
#endif

#endif				/* _TIME_H */
