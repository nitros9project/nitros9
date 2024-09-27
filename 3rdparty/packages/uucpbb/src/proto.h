/*  proto.h   Function declarations used by UUCPbb package.
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

/* Various declarations used by UUCPbb package.  This should help to keep the
   the various OS-9 compilers happy.  */

extern int errno;

 /***************************\
 * CoCo specific defs/macros *
 \***************************/

#ifndef _OSK
# ifndef _VOID_
#  define _VOID_
#  ifndef _CMOC_VERSION_
typedef int void;
#  endif
# endif
# ifndef _CMOC_VERSION_
#define QQ direct                  /* CoCo type 'direct' [page] */
#else
#define QQ
#endif
typedef int flag;
char *parse_cmd();
#endif


 /**************************\
 * OSK specific defs/macros *
 \**************************/

#ifdef _OSK
#define QQ                         /* OSK doesn't have direct page type */
typedef char flag;
#endif


 /******************************\
 * OS-9000 specific defs/macros *
 \******************************/

#ifdef _OS9K
#define QQ                         /* OS-9000 doesn't have direct page type */
typedef char flag;
#endif


 /*============ miscellaneous declarations--applies to everyone ============*/

#ifdef _OSK
extern char **_environ;      /* Ultra C style */
extern char **environ;       /* 3.2 C style */

/* OSK prototypes */
char *strend();
extern int os9exec();
extern int os9fork();
int parse_cmd();

#else
/* CoCo prototypes */
char *parse_cmd();
#endif

/* external variables used by getopt() */
extern char *optarg;
extern int optind, opterr;

/* various functions */
char *date822();              /* returns string with date in RFC-822 format */
char *gtime();                /* returns string in form '(May 05-01:56:00)' */
char *skipspace();                       /* added to parse.c */
char *getdirs(), *mfgets(), *getenv();
char *getstring(), *getval(), *getrealname(), *genseq();
char *strdetab(), *strlwr(), *strupr(), *strdup(), *strstr(), *strend();
char *InttouID();
int  strucmp();
long getseq();
void errorexit();
