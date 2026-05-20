/*  date822.c   This routine returns a date string in RFC-822 format.
    Copyright (C) 1990, 1993  Rick Adams and Bob Billson

    This file is part of the OS-9 UUCP package, UUCPbb.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

    The author of UUCPbb, Bob Billson, can be contacted at:
    bob@kc2wz.bubble.org  or  uunet!kc2wz!bob  or  by snail mail:
    21 Bates Way, Westfield, NJ 07090
*/

/* Returns a pointer to a character string containing the current date/time
   in RFC-822 format.  Requires Carl Kreider's CLIB.L or CLIBT.L to compile.

   ctime() format 'Mon Nov 21 11:31:54 1983\n\0'

   RFC822 format  'Mon, 21 Nov 1983 11:31:54 PST\0
           -or-   'Mon, 16 May 1988 02:13:10 -0700\0'

   The external variable 'tz' is defined in getparam.c and set in the
   /DD/SYS/UUCP/Parameters file.  */

#include "uucp.h"
#include <time.h>

#define WORDSIZE  5

extern char tz[];
static char RFCbuf[40];                   /* RFC-822 formatted time string */


char *date822()
{
     static long save_t = 0L;
     char date[26];
     register char *words[WORDSIZE];
     char *p, *adate;
     long t;

     adate = RFCbuf;

     /* get the current time */
     time (&t);

     /* If the time different from when we were last called, update the ADATE
        string and save the time in case we are immediately called again.  If
        the time is same, return the pointer to ADATE set from the previous
        call. */

     if (t != save_t)
       {
          save_t = t;

          /* convert the seconds to date/time format */
          strcpy (date, ctime (&t));
          p = strchr (date, '\n');
          *p = '\0';

          /* separate the various elements */
          getargs (words, date, WORDSIZE);

          /* put them in the RFC-822 format */
          sprintf (adate, "%s, %s %s %s %s %s",
                          words[0], words[2], words[1], &words[4][2],
                          words[3], tz);
       }
     return (adate);
}
