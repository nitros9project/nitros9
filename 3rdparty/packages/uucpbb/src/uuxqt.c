/*  uuxqt.c   The main program which processes work from a remote system.
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

/* Usage:  uuxqt [opts]  <sys> [<sys>...]  [opts]

        <sys>  -process work for <sys>  If <sys> name is 'ALL', all
                  systems in the Systems file are processed

   opts: -xN   -set debug level to N.  0 (default) = OFF, 9 = highest
         -q    -work quietly, i.e. no messages to the screen */

#define MAIN

#include "uucp.h"
#ifndef _OSK
#include <os9.h>
#endif
#include <signal.h>
#include <dir.h>
#include "getopt.h"

#define MOREWORK  128                          /* more work signal */
#define PROC      "procs"                      /* PROC command */

extern QQ int childid;                         /* defined in docmd.c */

EXTERN QQ unsigned myuid;

QQ int debuglvl = 0;                           /* made direct page variable */
QQ flag quiet = FALSE;                         /* don't work silently */
QQ flag didwork = FALSE;
QQ flag allflag = FALSE;
QQ flag morework = FALSE;                      /* signal flag */
QQ flag logopen = FALSE;
QQ char *errormsg = "ERROR--";
QQ char *rnews = "rnews";
QQ char *rmail = "rmail";
QQ char **syslist;
QQ FILE *log;
char sender[6] = "uuxqt";
char sysname[9] = "";
char fname[100];
void openlog(), closelog();


int main(argc, argv)
int argc;
char *argv[];
{
     int option, myinterrupt();
     register char **sysptr;

     log = NULL;
     childid = -1;                                 /* no children yet */

     intercept (myinterrupt);                        /* set signal trap */
     myuid = getuid();

     if ((logdir = getenv ("LOGDIR")) != NULL)
          logdir = strdup (logdir);
     else
          logdir = LOGDIR;

     openlog();

     /* is another copy of uuxqt currently running? */
     isuuxqtrunning();

     if ((spooldir = getdirs ("spooldir")) == NULL)
          fatal ("spooldir not in Parameters");

     syslist = sysptr = (char **) malloc (argc * sizeof (char));
     
     if (syslist == NULL)
          fatal ("can't malloc() syslist");

     *syslist = NULL;

     while (((option = getopt (argc, argv, "d:x:qs:?")) != NONOPT)
             || optarg != NULL)
       {
          switch (option)
            {
               case 'd':
               case 'x':
                    debuglvl = atoi (optarg);
                    break;

               case 'q':
                    quiet = TRUE;
                    break;

               case 's':
               case NONOPT:
                    if (strcmp (optarg, "ALL") == 0)
                         allflag = TRUE;

                    *sysptr++ = optarg;
                    *sysptr = NULL;
                    break;

               case '?':
                    usage();
                    break;
            }
       }

     if (!*syslist)
       {
          fputs ("uuxqt: no system specified\n\n", stderr);
          usage();
       }

#ifdef _OSK
     if (modlink (rnews, 0) == -1)
       {
          char tmp[64];

          if (modloadp (rnews, 0, tmp) == -1)
               fatal ("can't load rnews");
       }

     if (modlink (rmail, 0) == -1)
       {
          char tmp[64];

          if (modloadp (rmail, 0, tmp) == -1)
            {
               munload (rnews, 0);
               fatal ("can't load rmail");
            }
       }
#else
     if (nmlink (rnews, 0, 0) == -1)
          if (nmload (rnews, 0, 0) == -1)
               fatal ("can't load rnews");

     if (nmlink (rmail, 0, 0) == -1)
          if (nmload (rmail, 0, 0) == -1)
            {
               munload (rnews, 0);
               fatal ("can't load rmail");
            }
#endif

     do
          processmail();
     while (morework);

     free (syslist);
     free (spooldir);

     /* unlink modules and close log file */
     munload (rmail, 0);
     munload (rnews, 0);
     closelog();
     exit (0);
}



/* Check to see if another copy of uuxqt is running.  If it is, send it a
   signal to indicate new mail which it doesn't know about.  We then exit
   quietly.  This functions requires the PROC command be available in memory
   or the current execution directory. */

int isuuxqtrunning()
{
     char line[80];
     register char *p;
     char *proc = PROC;
     FILE *fp;
     flag foundanother = FALSE;
     int uupid, ourpid;

     p = line;

     /* look for another uuxqt running besides us */
     ourpid = getpid();

     if ((fp = popen (proc, "r")) == NULL)
       {
          sprintf (line, "isuuxqtrunning() can't load '%s'", proc);

          if (!quiet  &&  logopen)
               fprintf (stderr, "uuxqt: %s...error %d\n", line, errno);

          fatal (line);
       }

     while (mfgets (p, sizeof (line), fp) != NULL)
#ifndef _OSK
          if (patmatch ("*uuxqt*", line, TRUE) == TRUE)
#else
          if (findstr (1, p, "uuxqt") != 0)
#endif
               if (atoi (p) != ourpid)
                 {
                    uupid = atoi (p);
                    foundanother = TRUE;
                 }
     pclose (fp);

     /* if we found another uuxqt tell it about new work and die */
     if (foundanother)
       {
          asetuid (0);
          kill (uupid, MOREWORK);
          exit (0);
       }
}



int processmail()
{
     DIR *dir;                                     /* defined is dir_6809.h */
     struct direct *dirptr;                        /* defined in dir_6809.h */
     register char **sysptr;
     char *badsys = " (bad system name)";
     char *cantchg = "can't change to spool directory for: ";

     if (morework)
       {
          morework = FALSE;
          allflag = TRUE;

          if (!quiet)
               puts ("\nnew work arrived...");
       }

     /* change to the main spool directory */
     if (chdir (spooldir) == ERROR)
       {
          char tmp[128];

          sprintf (tmp, "%s%s", cantchg, spooldir);
          fatal (tmp);
       }

     /* if we were passed a specific systems, do work for each */
     if (!allflag)
          for (sysptr = syslist; *sysptr; sysptr++)
            {
               /* change to the system's spool directory */
               strcpy (sysname, *sysptr);
               strlwr (sysname);

               if (!quiet)
                 {
                    printf ("uuxqt: doing work for '%s'...", sysname);
                    fflush (stdout);
                 }

               if (chdir (sysname) == ERROR)
                 {
                    char tmp[128];

                    if (!quiet)
                         puts (badsys);
 
                    sprintf (tmp, "%s%s", cantchg, spooldir);
                    error (tmp);
                    continue;
                 }

               findxwork();
               chdir ("..");

               if (!quiet)
                    putchar ('\n');
            }
     else
       {
          /* system name 'ALL' was passed, process all remotes */

          /* open top spool directory */
          if ((dir = opendir (".")) == NULL)
            {
               char tmp[128];

               sprintf (tmp, "can't open: %s", spooldir);
               fatal (tmp);
            }

          /* loop through each directory in ./SPOOL/UUCP */
          while ((dirptr = readdir (dir)) != NULL)
            {
               if (dirptr->d_name[0] == '.')
                    continue;

               strcpy (sysname, dirptr->d_name);
               strlwr (sysname);

               if (!quiet)
                 {
                    printf ("uuqxt: doing work for '%s'...", sysname);
                    fflush (stdout);
                 }

               /* change system's spool directory and look for work to do */
               if (chdir (sysname) == ERROR)
                 {
                    char tmp[128];

                    if (!quiet)
                         puts (badsys);

                    sprintf (tmp, "%s%s", cantchg, sysname);
                    error (tmp);
                    continue;
                 }

               /* handle any waiting work */
               findxwork();
               chdir ("..");

               if (!quiet)
                    putchar ('\n');
            }
          closedir (dir);
       }
}



void openlog()
{
     char tmp[128];

     if (logopen)
          return;

     strcat (strcpy (tmp, logdir), "/uulog");

     /* Open log file, uulog.  It should be unbuffered. */
     if ((log = fopen (tmp, "a")) != NULL)
       {
          setbuf (log, NULL);
          logopen = TRUE;
       }
     else
          log = stderr;
}



/* To keep uulog from getting fatally fragmented, recopy it. */

void closelog()
{
     char out[128], in[128];

     if (log == stderr)
          return;

     if (logopen)
          fclose (log);

     logopen = FALSE;

     if (didwork)
       {
          /* try to rename the original log file */
          sprintf (out, "%s/uulog.orig", logdir);
          unlink (out);
          sprintf (out, "rename %s/uulog uulog.orig", logdir);

         /* if we can't, forget about it this time */
         if (docmd_na (out) == 0)
           {
              sprintf (in, "%s/uulog.orig", logdir);
              sprintf (out, "%s/uulog", logdir);
              filemove (in, out);
           }
       }
}



int myinterrupt (sig)
int sig;
{
     switch (sig)
       {
          case MOREWORK:
               morework = TRUE;
               break;

          case SIGWAKE:
               break;

          case SIGQUIT:
          case SIGINT:
          case SIGKILL:
               if (childid != -1)           /* kill off any children */
                 {
                    kill (childid, SIGKILL);
                    childid = -1;
                 }

               munload (rmail, 0);
               munload (rnews, 0);
               closelog();
               exit (sig);
       }
}



int error (msg)
char *msg;
{
     fprintf (log, "%s %s %s %s%s",
                   sender, sysname, gtime(), errormsg, msg);

     if (errno != 0)
          fprintf ("...error #%d", errno);

     putc ('\n', log);
}



int fatal (msg)
char *msg;
{
     myinterrupt (errno);
     error (msg);
     exit (0);
}



int usage()
{
     char temp[80];
     register char **use;
     static char *usetxt[] = {
       " ",
       "uuxqt: process incoming queued UUCP traffic",
       " ",
       "Usage:  uuxqt [opts]  <sys> [<sys>...]  [opts]",
       " ",
       "\t<sys>   -process work for <sys>.  If <sys> name is 'ALL', all systems in",
       "\t\t\t the Systems file are processed",
       " ",
       "opts:  -xN   -set debug level to N.  0 = OFF (default), 9 = highest",
       "\t  -q    -work quietly (no messages to the screen)",
       " ",
       NULL
     };

     for (use = usetxt; *use != NULL; ++use)
          fprintf (stderr, " %s\n", strdetab (strcpy (temp, *use), 5));

     fprintf (stderr, "\nv%s (%s) This is free software released under the GNU General Public\n",
                      version, VERDATE);
     fputs ("License.  Please send suggestions/bug reports to:  bob@kc2wz.bubble.org\n", stderr);
     exit (0);
}
