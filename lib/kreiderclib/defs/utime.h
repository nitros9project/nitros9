/*
 * utime.h - UNIX time structure
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

#ifndef _UTIME_H
#define	_UTIME_H

struct tm
{
	int             tm_sec;	/* seconds (0 - 59) */
	int             tm_min;	/* minutes (0 - 59) */
	int             tm_hour;/* hours (0 - 23) */
	int             tm_mday;/* day of month (1 - 31) */
	int             tm_mon;	/* month of year (0 - 11) */
	int             tm_year;/* year (year - 1900) */
	int             tm_wday;/* day of week (Sunday = 0) */
	int             tm_yday;/* day of year (0 - 365) */
	int             tm_isdst;	/* not used */
};

long            time();		/* just like Unix */
struct tm      *localtime();	/* just like Unix */
char           *asctime();	/* just like Unix */
char           *ctime();	/* just like Unix */

long            o2utime();	/* converts os9 style buf to Unix long */

 /* void */ u2otime();		/* converts 'tm' to os9 char buf */

#endif				/* _UTIME_H */
