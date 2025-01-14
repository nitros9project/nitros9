/*
 * password.h - Definitions for password access
 *
 * Notes:
 *  Two different delimiters are accepted, ',' and ':'.
 *  In the second (Unix like) case, an extra field is
 *   defined for comments (ugcos).
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

#ifndef _PASSWORD_H
#define _PASSWORD_H

#ifdef TEST
#define  PASSWORD "/DD/SYS/massword"
#else
#define  PASSWORD "/DD/SYS/password"
#endif

#ifndef _OSK			/* OS-9/6809 doesn't know about voids */
#ifndef _VOID_
#define _VOID_
typedef int void;

#endif
#endif



#define  PWEMAX   64		/* mamimum lines in password file */
#define  PWSIZ    132		/* maximim size of password file line */
#define  PWNSIZ   32		/* maximum size of user's name */
#define  PWPSIZ   32		/* maximum size of user's password */
#define  UNXDLM   ':'		/* Unix style password file delim */
#define  OS9DLM   ','		/* OS9 style password file delim */



typedef struct
{
	char           *unam,
	               *upw,
	               *uid,
	               *upri,
	               *ugcos,
	               *ucmd,
	               *udat,
	               *ujob;	/* field pointers */
}               PWENT;


/* returns a pointer to broken down password entry */
PWENT          *getpwent();

/* same, but for the given int uid */
PWENT          *getpwuid();

/* same, but for the given char *name */
PWENT          *getpwnam();

/* rewinds the password file for another scan */
void            setpwent();

/* terminates password file access (closes) file */
void            endpwent();

/* returns the current password entry delimiter */
int             getpwdlm();

#endif				/* _PASSWORD_H */