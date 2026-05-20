/*  uucp.h    Main header file for UUCPbb package.
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

/* Rick Adams' original header with additions.  Changes to code labeled 'REB'
   were made by Bob Billson  */

#include <stdio.h>                                          /* Added --REB */
#include <types.h>

 /**************************\
 * Compiler specific macros *
 \**************************/

#ifdef _UCC                    /* Ultra C compiler */       /* Added --BGP */
#undef USE_INDEX
#include <string.h>
#else                          /* all other C compilers */
#define USE_INDEX 0
/*#define strchr(a,b) index(a,b) */
/* #define strrchr(a,b) rindex(a,b) */
#include <string.h>
#endif

#include "os_misc.h"                                        /* Added --REB */

 /***************************************************
  ***************************************************
  *******   DO NOT change the #defines in the  ******
  *******   section immediately below.         ******
  ***************************************************
  ***************************************************/

#ifdef MAIN
#define EXTERN
QQ char *version = "2.1";                /* current software version --REB */
#else
#define EXTERN extern
EXTERN QQ char *version;
#endif

#define VERDATE   "94Sep30"
#define MAXTRY       3               /* number of retries to get a packet */

 /*******************************************************************
  *******************************************************************
  *******  User can modify the next section  to customize for *******
  *******  their system.  Be sure to leave double quotes (")  *******
  *******  around any strings that already have them.         *******
  *******************************************************************
  *******************************************************************/

/* For modems using compression (MNP, etc.) hardware rather than software
   (XON/XOFF) flow control often must be used.  Make the following #define
   TRUE if you use hardware (CTS/RTS) flow control.  Make it FALSE if your
   modem does NOT use compression or you use software flow control.

   -->NOTE<---  Bruce Isted's replacement for ACIAPAK (SACIA/DACIA) is needed.
                on the CoCo.  Also Eddie Kuns update of the Clock module
                (Edition #9) is highly recommended.  If you still are using
                ACIAPAK (you shouldn't be :-), make the #define FALSE  */

#define RTSFLOW    TRUE

/* Time (in ticks) to pause between sending modem commands.  If this is too
   fast for your modem try any value up to 60 (== 1 second on the CoCo 3).
   The default values represent a 1/4 second delay.  */

#ifdef _OSK
#define MODEMDELAY 0x80000040                       /* OSK */
#else
#define MODEMDELAY  15                              /* OS9/6809 */
#endif

/* Time in seconds UUCICO waits for the remote modem answer (when calling 
   out), detect a carrier and your modem sends its CONNECT message.  If your
   remote's modem takes longer to answer and send a carrer, try increasing the
   value of CNCTIME.  */

#define CNCTIME     40

/* Time in seconds UUCICO waits for the remote to send its first login prompt.
   If your modem connects but UUCICO times out before getting the login
   prompt, try increasing this value. */

#define LOGTIME      5

/* Maximum number of times UUCICO will attempt to login during a single call.
   It should rarely be necessary to change this value. */

#define MAXLOGTRY    3

/* Number of minutes UUCICO waits before calling a system again after a call
   fails.  This default time can be overridden with the -i option. */

#define NAPTIME     2

/* If UUCICO gives you lots of aborts due to checksum errors, try replacing
   MAXTRY below with a higher number.  (MAXTRY is set for a value of 3 at the
   beginning of this file.)  25 might be a good starting value to try.
   ==DO NOT== change the value of MAXTRY to fix checksum error aborts.
   Increasing GET_TRY may also be useful when running 9600 bps on the Coco. */

#define GET_TRY  MAXTRY

/* Various directories and #defines used by the package.   You can change the
   directories to suit your system, but do not change the file names.  Other
   directories are set in the /DD/SYS/UUCP/Parameters file or environment
   variables. */

/* file paths */
#define DEVICES    "/DD/SYS/UUCP/Devices"
#define DIALERS    "/DD/SYS/UUCP/Dialers"
#define SYSTEMS    "/DD/SYS/UUCP/Systems"
#define NGROUPS    "/DD/SYS/UUCP/active"
#define UUCPSYS    "/DD/SYS/UUCP"
#define NEWSEQ     "/DD/SYS/UUCP/sequence.news"
#define MAILSEQ    "/DD/SYS/UUCP/sequence.mail"
#define GENSEQ     "/DD/SYS/UUCP/sequence.spool"

/* Name of your RAM disk.  The RAM disk should be of a reasonable size;
   especially if you will use it for temporary storage when composing mail.
   A suggested size is at least 80K.  If you do not have a RAM disk on your
   system or want the RAM disk to never be used, leave the RAMDISK #define
   below unchanged and change RAMDSIZE to 0. */

#define RAMDISK    "/R0"

/* Maximum free space on your RAM disk */
#define RAMDSIZE   80000

/* our bit bucket */
#define NIL        "/nil"

/* default user directory; used by adduser.c --REB */
#define USERDIR     "/DD/USR"

/* default data and execution directories; used by login.c --REB */
#define DEFWORKDIR  "/DD/USR/GUEST"
#define DEFEXECDIR  "/DD/CMDS"

/* Readnews news help file */
#define NEWSHELP    "/DD/SYS/UUCP/newshelp"

/* If the environment variable LOGDIR is undefined.  The logging directory
   where the login and UUCP log files are kept defaults to this one. */

#define LOGDIR      "/DD/LOG"

/* These are the maximum number of Usenet news groups you expect to received
   on your system.  While there is no real limit under OSK, there in on the
   CoCo.  If you set the number too high, UUCPbb may not compile.  If it
   does, the news software may not work properly, if at all.  This is a
   memory limitation of the CoCo. */

#ifdef _OSK
#define MAXNEWSGROUPS  100                      /* max OSK newsgroups */
#else
#define MAXNEWSGROUPS  50                       /* max CoCo newsgroups */
#endif

 /*---------> End User Changeable Section <---------*/


 /***************************************************************
  ***************************************************************
  *******  WARNING: Gremlin Zone!!                         ******
  *******           Do not mess with anything below here.  ******
  ***************************************************************
  ***************************************************************/


/* Pointer to directory where login and uucico's log files are kept */
EXTERN QQ char *logdir;

#ifdef MAIN
/* Directory in user's home directory where aliases, newsrc, mailrc,
   signature, alt.signature, organization, forward, etc. files are kept
   on the CoCo. */

QQ char *uudir = "UUCP";
#else
extern QQ char *uudir;
#endif

/* outgoing/incoming mail/news files */
EXTERN QQ char *spooldir;

/* where news articles are kept */
EXTERN QQ char *newsdir;

/* where files (other than news/mail) transferred by uucp program get put */
EXTERN QQ char *pubdir;

/* names of various files in ./<HOMEDIR>/<USER>/UUCP directory (CoCo)
                        or   ./<HOMEDIR>/<USER>      directory (OSK)  */
#ifndef _OSK
#define _NEWSRC   "newsrc"                       /* CoCo */
#define _MAILRC   "mailrc"
#define _FRWRD    "forward"
#else
#define _NEWSRC   ".newsrc"                      /* OSK */
#define _MAILRC   ".mailrc"
#define _FRWRD    ".forward"
#endif

/* these are environment variables HOME and MAIL */
EXTERN QQ char *maildir;          /* mailbox directory for user's mail */
EXTERN QQ char *homedir;          /* user's login data directory */

/* Comment lines start with #, <space>, <tab> or <cr> */
#define ISCOMMENT(c) ((c) == '#' || (c) == ' ' || (c) == '\t' || (c) == '\0')

/* active file structure */
struct active {
         char newsgroup[50];  /* Newsgroup name    */
         int index,           /* Lowest article #  */
             seq;             /* Highest article # */
      };

/* Newsrc file structure (Capital on purpose!) */
struct Newsrc {
         char newsgroup[50];  /* Newsgroup name       */
         int  index;          /* Highest article read */
         flag sub;            /* 1=subscribed 0=not   */
      };

#define SUBSCRIBED    ':'
#define UNSUBSCRIBED  '!'
#define NEWGROUP      '\0'
#define SYSLINE       160         /* max size of line in Systems file */
#define MAXPARAM       20         /* max params in Parameters file */
#define MAXDISTRIB     10         /* max number of news distributations */
#define ABORT           9
#define FATAL          10
#define OK             11
#define TIMEDOUT       -1
