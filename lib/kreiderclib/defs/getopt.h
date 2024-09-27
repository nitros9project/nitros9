/*
 * getopt.h - Option parsing header file
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

#ifndef _GETOPT_H
#define _GETOPT_H

extern int      getopt();	/* Function to get command line options */

extern char    *optarg;		/* Set by GETOPT for options expecting
				 * arguments */
extern int      optind;		/* Set by GETOPT; index of next ARGV to be
				 * processed. */
extern int      opterr;		/* Disable (== 0) or enable (!= 0) error
				 * messages written to standard error */

#define NONOPT  (-1)		/* Non-option - returned by GETOPT when it
				 * encounters a non-option argument. */

#endif				/* _GETOPT_H */
