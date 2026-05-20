/*  uulog.c   This program allows viewing the uulog and fileserv log files.
    Copyright (C) 1990, 1993  Mark Griffith and Bob Billson

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

/* Simply reads the uulog file for a specific system name or user name entry
   and prints it.  Defaults to printing every line if no options are given.

   Options:
           -s<sysname>   -show work to/from the remote <sysname>
           -u<username>  -show work to/from the user <username>
           -d<days>      -show log file for <days> days ago.  Default is
                            show today's log file
           -f            -show fileserver logs, default is UUCP logs

   Thanks to Mark for giving his okey dokey to modify his original code and
   include it in the UUCPbb package. * Changes and additions done by Bob
   Billson <...!uunet!kc2wz!bob> are indicated by 'REB'. */

#define MAIN                                        /* Added -- REB */

#include "uucp.h"

/* Globals */
char sysname[9], username[20], logfile[256], fsysname[9], fusername[20];
void usage(), fatal();


int main(argc, argv)
int argc;
char *argv[];
{
     register FILE *fd;                                 /* Changed --REB */
     flag all, fserver, dayflag, uulflag;               /*               */
     int option;
     char *day, *p, *q, line[256];

     all = TRUE;
     fserver = FALSE;                         /* look at uulog files --REB */
     uulflag = TRUE;
     dayflag = FALSE;

     /* Process any command line arguments  */
     while ((option = getopt (argc, argv, "s:u:d:f?")) != EOF)
          switch (tolower (option))
            {
               case 's':
                    strcpy (sysname, optarg);
                    all = FALSE;
                    break;

               case 'u':
                    strcpy (username, optarg);
                    all = FALSE;
                    break;

               case 'd':                                  /* changed -- REB */
                    dayflag = TRUE;
                    day = optarg;
                    break;

               case 'f':
                    uulflag = FALSE;
                    break;

               case '?':
                    usage();
            }

     if ((logdir = getenv ("LOGDIR")) != NULL)
          logdir = strdup (logdir);
     else
          logdir = LOGDIR;

     sprintf (logfile, "%s/%s%s%s",
                       logdir,
                       uulflag ? "uulog" : "fileserv",
                       dayflag ? "." : "",
                       dayflag ? day : "");

     if ((fd = fopen (logfile, "r")) == NULL)
          exit (_errmsg (errno, "unable to open '%s'\n", logfile));

     putchar ('\n');

     /* read uulog files */
     if (uulflag)
       {
          while (fgets (line, sizeof (line), fd) != NULL)
            {
               p = line;
               q = fusername;
               while (*p != '\0' && *p != ' ' && *p != '\t' && *p != '\n')
                    *q++ = *p++;
               *q = '\0';
               while (*p == ' ' || *p == '\t')
                    ++p;
               q = fsysname;
               while (*p != '\0' && *p != ' ' && *p != '\t' && *p != '\n')
                    *q++ = *p++;
               *q = '\0';

               if (!all)
                 {
                    if ((strucmp (fsysname, sysname) == 0)
                         || (strucmp (fusername, username) == 0))
                      {
                         fputs (line, stdout);
                         fflush (stdout);
                      }
                 }
               else
                 {
                    fputs (line, stdout);
                    fflush (stdout);
                 }
            }
       }
     else
       {
          /* show fileserver logs */
          while (fgets (line, sizeof (line), fd) != NULL)
            {
               fputs (line, stdout);
               fflush (stdout);
            }
       }
     fclose (fd);
     exit (0);
}



void fatal (msg)
char *msg;
{
     fprintf (stderr, "uulog: %s\n", msg);
     exit (0);
}



void usage()
{
     register char **use;
     static char *usetxt[] = {
          "uulog: examine uucp or fileserver log files",
          " ",
          "Usage: uulog [-s<sysname> -u<username> -d<days>] [-f]",
          " ",
          "Opts:  -s<sysname>   -show work to/from the remote <sysname>",
          "       -u<username>  -show work to/from the user <username>",
          "       -d<days>      -show log file for <days> days ago.  Default is show",
          "                        today's log file",
          "       -f            -show fileserver logs, default is UUCP logs",
          " ",
          NULL
       };

     for (use = usetxt;  *use != NULL; ++use)
          fprintf (stderr, "%s\n", *use);

     fprintf (stderr, "v%s (%s) This is free software released under the GNU General Public\n",
                      version, VERDATE);
     fputs ("License.  Please send suggestions/bug reports to:  bob@kc2wz.bubble.org\n", stderr);
     exit (0);
}
