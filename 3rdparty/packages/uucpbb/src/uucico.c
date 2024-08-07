/*  uucico.c   This is the main UUCP communications program.
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

/*  usage: uucico [opts] -r | sys [sys...]  [opts]

         sys       -remote system to call as MASTER, e.g.
                      uucico sys1 sys2   calls sys1 then sys2

    opts: -r       -run as SLAVE
          -u       -do not run UUXQT at all
          -a       -run UUXQT after each call, default is after all
                      calls are completed
          -iN      -wait N minutes between call retries
          -tN      -try to call remote up to N times
          -wN      -use window size of N
          -xN      -set debug level to N (0-9), default is 0 (off)
          -o       -orphan UUXQT
          -pN      -run UUXQT at a priority of N
          -q       -send no output to standard out
          -l       -use RAM disk for temporary uulog
          -z       -send debug output to screen if debug level is 1 to 5
                      overrides -l
*/

#define MAIN

#include "uucp.h"
#include "uucico.h"
#ifdef _OSK
#include <procid.h>
#endif
#include "getopt.h"

#define MAXTRIES    1        /* default number of attempts to call a system */
#define LOGSIZE     80       /* size of uulog pathname */

extern QQ unsigned myuid;

int myinterrupt();


main (argc, argv)
int argc; 
char *argv[];
{
     int option, priority, naptime, numsys, maxtries;
     char **syslist;
     register char **sysptr;
     flag runuuxqt, aftercall, gotmail, orphan;

     /* defaults */
     logopen   = FALSE;                         /* log file open flag       */
     debuglvl  = 0;                             /* debug off                */
     role      = MASTER;                        /* default role is master   */
     ramdisk   = FALSE;                         /* don't use RAM disk yet   */
     quiet     = FALSE;                         /* print to stdout --BGP    */
     logflag   = TRUE;                          /* write /DD/LOG/uulog --TK */
     maxtries  = MAXTRIES;                      /* max call attempts        */
     aftercall = TRUE;                     /* run UUXQT when calls are done */
     naptime   = NAPTIME;                       /* sleep between retries    */
     runuuxqt  = TRUE;                          /* run UUXQT                */
     gotmail   = FALSE;                         /* no mail received         */
     orphan    = FALSE;                         /* run UUXQT as an orphan   */
     priority  = 128;                           /* normal priority          */

#ifndef _OSK
     pflinit();                                    /* longs will be printed */
#endif

     intercept (myinterrupt);                      /* deal with interruptions */
     asetuid (0);

     if (getparam() == FALSE)
          exit (0);

     if ((logdir = getenv ("LOGDIR")) != NULL)
          logdir = strdup (logdir);
     else
          logdir = LOGDIR;

     if ((spooldir = getdirs ("spooldir")) == NULL)
          fatal ("spooldir not in Parameters");

     if ((pubdir = getdirs ("pubdir")) == NULL)
          fatal ("pubdir not in Parameters");

     syslist = sysptr = (char **) malloc (argc * sizeof (char));

     if (syslist == NULL)
          fatal ("can't malloc() syslist");

     /* no system to call yet */
     *syslist = NULL;
     numsys = 0;

     while (((option = getopt (argc, argv, "arqx:uw:lop:i:t:zS:s:m:?"))
             != NONOPT)  ||  optarg != NULL)
       {
          int scnt = 0;

          switch (option)
            {
               case 'S':                 /* DEBUG--run under different name */
#ifdef DEBUG
                    strcpy (nodename, optarg);
#endif
                    break;

               case 'a':                      /* run UUXQT after each call */
                    aftercall = FALSE;
                    break;

               case 'r':                             /* run as slave */
                    role = SLAVE; 
                    break;

               case 'x':                              /* debug level */
                    debuglvl = atoi (optarg);

                    if (debuglvl > 5)
                         ramdisk = TRUE;
                    break;

               case 'u':                               /* do not run UUXQT */
                    runuuxqt = FALSE;
                    break;

               case 'w':               /* override 'parameters' window size */
                    rec_window = atoi (optarg);

                    if (rec_window > 7)
                         rec_window = 7;
                    else if (rec_window <= 0)
                         rec_window = 1;
                    break;

               case 'm':               /* segment size */
                    while (ssiz[scnt][0] != '\0')
                      {
                         if (strcmp (optarg, ssiz[scnt]) == 0)
                           {
                              rec_segment = scnt;
                              break;
                           }
                         scnt++;
                      }

                    if (ssiz[scnt][0] == '\0')
                         fprintf (stderr, "Don't understand '%s'\n", optarg);
                    break;

               case 'l':             /* use RAM disk for temporary log file */
                    ramdisk = TRUE;
                    break;

               case 'o':                    /* orphan UUXQT when it is run */
                    orphan = TRUE;
                    break;

               case 'p':                 /* run UUXQT at different priority */
                    priority = atoi (optarg);

                    if (priority < 1)
                         priority = 0;                       /* no change */
                    else if (priority > MAXPRIORITY)
                         priority = MAXPRIORITY;

                    break;

               case 'i':            /* minutes to wait between call retries */
                    naptime = atoi (optarg);
                    break;

               case 'q':                         /* no output to the screen */
                    quiet = TRUE;
                    break;

               case 't':                /* max call retries for each remote */
                    maxtries = atoi (optarg);
                    break;

               case 'z':           /* log to screen if debug level >0 && <6 */
                    logflag = FALSE;
                    break;

               case 's':                            /* remote's name */
               case NONOPT:
                    *sysptr++ = optarg;
                    *sysptr = NULL;
                    ++numsys;
                    break;

               case '?':                        /* help/bad option */
                    usage();
            }
       }

     if (!logflag  &&  debuglvl > 5)
          logflag = ramdisk = TRUE;

     /* can't orphan UUXQT unless it is run after all calls are completed */
     if (aftercall == FALSE)
          orphan = FALSE;

     asetuid (0);                            /* we run as the superuser */

     if (role == MASTER)
       {
          if (*syslist == NULL)
               fatal ("no remote to call!");

          if (numsys == 1)
               aftercall = TRUE;

          if (!quiet)
               putchar ('\n');

          /* poll each system we were given */
          for (sysptr = syslist; *sysptr; sysptr++)
             {
               int call;
               flag done;

               normal_end = done = uuxflag = offhook = FALSE;
               call = 1;
               openlog();

               /* get remote's info */
               strncpy (sysname, *sysptr, sizeof (sysname));
               sysname[sizeof (sysname) - 1] = '\0';

               /* initial sender is 'uucp' */
               strcpy (sender, "uucp");

               /* skip bad system */
               if (SystemIsOK (TRUE) == FALSE)
                    continue;

               if (!quiet)
                    printf ("polling '%s' ... %d attempt%s will be made\n",
                                 sysname, maxtries, maxtries > 1 ? "s" : "");

               /* loop until success or we retry out */
               while (!normal_end  &&  !done)
                 {
                    if (!quiet)
                      {
                         fputs ("      calling...  ", stdout);

                         if (!logflag)
                              putchar ('\n');

                         fflush (stdout);
                      }

                    role = MASTER;    /* make sure we are running as master */
                    pollremote();
                    closelog();

                    if (normal_end)
                      {
                         if (!quiet)
                           {
                              backspace (12);
                              printf ("call successful after %2d %s\n",
                                       call, call > 1 ? "tries": "try");
                           }

                         if (uuxflag)
                              gotmail = TRUE;
                      }
                    else
                      {
                         if (!quiet)
                           {
                              backspace (12);
                              printf ("call %d failed -- ", call);
                           }

                         if (call < maxtries)
                           {
                              if (!quiet)
                                {
                                   printf ("will try again in %d minute%s...",
                                           naptime, naptime > 1 ? "s" : "");

                                   fflush (stdout);
                                }
                              ++call;
                              sleep (naptime * 60);

                              if (!quiet)
                                   backspace (52);
                           }
                         else
                           {
                              if (!quiet)
                                   printf ("'%s' is unavailable\n", sysname);

                              done = TRUE;
                           }
                      }
                 }

               /* run UUXQT after each call? */
               if (!aftercall)
                    if (runuuxqt &&  uuxflag)
                         do_uuxqt (priority, FALSE, sysname, orphan);

               if (!quiet)
                    putchar ('\n');
            } 
          free (syslist);

          if (!quiet)
               printf ("call%s completed\n\n", numsys > 1 ? "s" : "");

          /* all calls are made, run UUXQT on every remote? */
          if (aftercall)
               if (runuuxqt && gotmail)
                    if (numsys > 1)
                         do_uuxqt (priority, TRUE, "ALL", orphan);
                    else
                         do_uuxqt (priority, TRUE, sysname, orphan);
       }

     /* running as slave, take the call */
     else
       {
          /* initial sender is 'uucp' */
          strcpy (sender, "uucp");
          normal_end = uuxflag = offhook = FALSE;
          openlog();
          pollremote();
          closelog();                                           /* TK */

          /* run UUXQT? */
          if (runuuxqt  &&  uuxflag)
               do_uuxqt (priority, TRUE, sysname, orphan);
       }
}



int pollremote()
{
     register flag state;

     *device = '\0';                             /* no port yet */

     /* set up for longjmp() abort from a low level function --REB */
     state = setjmp (env);

     /* run this loop "forever" */
     for (;;)
      {
          switch (state)
            {
               case INITIAL:
                    state = role == MASTER ? callup() : openport();
                    break;

               case MOPEN:
                    state = mopenuucp();
                    break;

               case SOPEN:
                    endflag = TRUE;
                    time (&start_time);
                    state = sopenuucp();
                    break;

               case MS_SNDRCV:
                    sprintf (fname, "%s/%s", spooldir, sysname);

                    /* can't open spool directory? */
                    if (chdir (fname) == ERROR)
                      {
                         char tmp[128];

                         sprintf (tmp,
                                  "pollremote: can't change to spool directory: %s",
                                  fname);
                         logerror (tmp);
                         state = ABORT;
                      }
                    else
                         state = gproto();
                    break;

               case _END:
                    state = role == MASTER ? mcloseuucp() : scloseuucp();
                    break;
            }

          if (state == ABORT  ||  state == FATAL)
               break;
       }
     endcall();
}



/* Try to connect for each applicable System file entry findmach() updates
   the index.  Changed --REB */

int callup()
{
     int index = 0;
     register flag state = INITIAL; 

     for (;;)
          switch (state)
            {
               case INITIAL:
                    state = findmach (&index);
                    break;

               case OPENPORT:
                    endflag = TRUE;
                    state = openport();
                    break;

               case PORTBUSY:
                    if (!quiet)
                         printf ("  %s is in use...aborting\n", device);

                    exit (NONSHARE);

               case MAKECALL:
                    time (&start_time);
                    state = connect (index);
                    break;

               case OK:
                    if (!quiet)
                      {
                         backspace (12);
                         fputs ("connected...", stdout);
                         fflush (stdout);
                      }
                    return (MOPEN);

               case BUSY:
               case NOCARRIER:
                    endcall();
                    state = INITIAL;
                    break;

               case NODIALTONE:
               case NOANSWER:
               case CHATERROR:
               case ABORT:
                    return (ABORT);

               case FATAL:
                    state = INITIAL;
                    break;
            }
}



int endcall()
{
     closeport();
     time (&endtime);
     *device = '\0';

     if (endflag)
       {
          if (offhook)
               call_length = endtime - start_time;
          else
               call_length = 0L;

          fprintf (log, "%s %s %s Call complete (%ld seconds)%s\n",
                        sender, sysname, gtime(), call_length,
                        normal_end ? "" : " --FAILED");

          offhook = endflag = FALSE;
       }
}



/* Open the log file.  It should be unbuffered.  If we don't want the RAM
   RAM disk or can't open the log file on it use the directory logdir --REB

   Altered logging for UUCP.  If ramdisk is TRUE then /R0 logging.  If logflag
   is TRUE then HD logging else log to screen. */

void openlog()
{
     static flag firstpass = TRUE;
     static char lname[LOGSIZE];

     if (logopen)
          return;

     if (firstpass)
       {
          if (ramdisk)
               strcat (strcpy (lname, RAMDISK), "/uulog");
          else
               if (logflag)
                    strcat (strcpy (lname, logdir), "/uulog");
          firstpass = FALSE;
       }

     /* if log file RAM or HD logging...
        otherwise, use screen logging-- standard error path */

     if (logflag)
       {
          if ((log = fopen (lname, "a")) != NULL)
            {
               setbuf (log, NULL);
               logopen = TRUE;
               return;
            }
          else
               quiet = TRUE;
       }

     /* send everything to bit bucket if quiet or can't open log file */
     if (quiet)
          log = fopen (NIL, "w");
     else
          log = stderr;

     logopen = TRUE;
     return;
}



/* Close log file, if we used RAM disk, move the temporary to the permanent
   uulog file --REB
   modified for "new" logging procedure! -TK */

void closelog()
{
     if (logopen)
       {
          fclose (log);
          logopen = FALSE;

          if (ramdisk)
            {

               strcat (strcpy (temp, RAMDISK), "/uulog");
               strcat (strcpy (fname, logdir), "/uulog");
               fileapnd (temp, fname, TRUE);
               unlink (temp);
            }
       }
}



/* If the orphan flag is set, UUXQT will be forked without a parent.  This
   should prevent the modem kill switch from killing off UUXQT on some
   systems. */
 
int do_uuxqt (priority, chain, remotef, orphan)
int priority;
flag chain;
char *remotef;
flag orphan;
{
     sprintf (temp, "%suuxqt -%sx%d %s%s%s",
                    orphan ? "shell (" : "",
                    (orphan || quiet) ? "q" : "",
                    debuglvl, remotef,
                    orphan ? "&) >>" : "",
                    orphan ? NIL : "");

     if (debuglvl > 0)
          puts (temp);

     if (chain)
       {
          /* do we want to run at a different priority? */
          if (priority)
               setpr (getpid(), priority);
          dochcmd (temp);
       }
     else
          docmd (temp);
}



/* remove line by backspace-space-backspace over it */

int backspace (howmany)
int howmany;
{
     register int i;

     for (i = 0; i < howmany; ++i)
          fputs ("\b \b", stdout);
}



/* log errors to file */

int logerror (msg)
char *msg;
{
     fprintf (log, "%s %s %s ERROR--%s\n", sender, sysname, gtime(), msg);
}



/* log normal events */

int lognorm (msg)
char *msg;
{
     fprintf (log, "%s %s %s %s\n", sender, sysname, gtime(), msg);
}



int fatal (msg)
char *msg;
{
     fprintf (stderr, "\nuucico: %s", msg);

     if (errno != 0)
          fprintf (stderr, "...error %d", errno);
     putc ('\n', stderr);
     exit (0);
}



/* clean up before we exit on keyboard abort -- REB */

int myinterrupt (sig)
int sig;
{
     fprintf (log, "\n%s %s %s OPERATOR ABORTED\n", sender,sysname,gtime() );
     endcall();
     exit (sig);
}



int usage()
{
     char *strdetab();
     static char *help1[] = {
          "usage: uucico [opts] -r | sys [sys...]  [opts]",
          " ",
          "\tsys      -remote system to call as MASTER (default)",
          " ",
          "opts: -r\t -run as SLAVE",
          "\t-u\t -do not run UUXQT at all",
          "\t-a\t -run UUXQT after each call, default is after all calls",
          "\t\t\tare completed",
          "\t-l\t -use RAM disk for temporary \"uulog\"",
          "\t-o\t -orphan UUXQT",
          "\t-pN\t-fork UUXQT with a priority of N",
          "\t-q\t -run quietly",
          "\t-wN\t-use window size of N",
          "\t-xN\t-set debug level to N (0-9), default is 0 (off), if N > 5",
          "\t\t\tadditional info sent to 'uulog'",
          "\t-z\t -send log info to screen if debug level is 1 to 5,",
          "\t\t\toverrides -l",
#ifdef DEBUG
          "\t-S<node> -run as <node> instead of using Parameters file nodename",
#endif
          NULL
        };
     static char *help2 =
        "\t-iN\t-wait N minutes between call retries, default is "; 
     static char *help3 = 
        "\t-tN\t-try to call remote up to N times, default is ";
     register char **hlp;

     for (hlp = help1;  *hlp != NULL;  ++hlp)
          fprintf (stderr, "%s\n", strdetab (strcpy (temp, *hlp), 6));

     fprintf (stderr, "%s%d\n", strdetab (strcpy (temp, help2), 6), NAPTIME);
     fprintf (stderr, "%s%d\n", strdetab (strcpy (temp, help3), 6), MAXTRIES);
     fprintf (stderr, "\nv%s (%s) This is free software released under the GNU General Public\n",
                      version, VERDATE);
     fputs ("License.  Please send suggestions/bug reports to:  bob@kc2wz.bubble.org\n", stderr);
     exit (0);
}
