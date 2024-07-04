/*  expire.c   This program deletes old Usenet news articles.
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

/* Options:
   --------
      -t         test (don't actually delete articles)
      -x<level>  debug, default is 0 (OFF)
      -n<group>  expire only given group
      -e<days>   expire articles older than specified number of days

     With no arguments, expires all articles older than 14 days in
     all newsgroups.  */

#define MAIN                                       /* added -- REB */

#include "uucp.h"
#include <modes.h>
#include <signal.h>

#define MAXDAYS  14                     /* default time article lives --REB */

QQ int expireflag = TRUE;
QQ int debuglvl = 0;
QQ int ngroups;
QQ FILE *log;
QQ int gotactive, ramdisk, logopen;
QQ unsigned myuid;                              /* to keep makepath() happy */
char sender[] = "expire";                       /*                          */
char fname[100];                                /* to keep getdirs() happy  */
struct active groups[MAXNEWSGROUPS];


main (argc, argv)
int argc;
char *argv[];
{
     char newsgroup[100];
     register int i;                                      /* Changed -- REB */
     int limit, found;
     int option, myinterrupt(), onegroup;                   /* Added -- REB */
     char *fixgroupname();

     *newsgroup = '\0';
     found = FALSE;
     limit = MAXDAYS;
     gotactive = FALSE;                          /* Added --REB */
     onegroup = FALSE;                           /*              */
     logopen = FALSE;

     myuid = getuid();

     if (myuid != 0)
          fatal ("you are not the superuser!");

     intercept (myinterrupt);                      /* signal trap --REB */

     if ((newsdir = getdirs ("newsdir")) == NULL)
          fatal ("newsdir not in Parameters");

     if ((logdir = getenv ("LOGDIR")) != NULL)
          logdir = strdup (logdir);
     else
          logdir = LOGDIR;

     /* Added --REB */
     while ((option = getopt (argc, argv, "e:x:n:t")) != EOF)
          switch (option)
            {
               case 'e':
                    limit = atoi (optarg);
                    break;

               case 'x':
                    debuglvl = atoi (optarg);
                    break;

               case 'n':
                    strcpy (newsgroup, optarg);
                    onegroup = TRUE;
                    break;
 
               case 't':
                    expireflag = FALSE;
                    break;

               case '?':
                    usage();
                    break;
            }

     openlog();

     if (!onegroup)
          fprintf (log, "%s %s expiring articles over %d days old\n",
                        sender, gtime(), limit);

     /* read active file into in-core table */
     readactive (S_IREAD|S_IWRITE|S_ISHARE, FALSE);
     gotactive = TRUE;

     /* cycle through available newsgroups */
     for (i = 0;  i < ngroups && !found;  i++)
       {
          char *ngroup;

          ngroup = NULL;

          /* Only expire one newsgroup? */
          if (*newsgroup != '\0')
               if (strucmp (newsgroup, groups[i].newsgroup) == 0)
                    found = TRUE;
               else
                    continue;

          if (expireflag)
            {
               fprintf (log, "%s %s expiring: %s", 
                              sender, gtime(), groups[i].newsgroup);
               if (onegroup)
                    fprintf (log, " articles over %d days old", limit);

               putc ('\n', log);
            }
          else
               printf ("would expire '%s' newsgroup\n", groups[i].newsgroup);

          if (chdir (newsdir) == ERROR)
            {
               sprintf (fname, "can't change to news directory '%s'",                                         newsdir);
               fatal (fname);
            }

          ngroup = fixgroupname (groups[i].newsgroup);
          makepath (groups[i].newsgroup);

          if (ngroup != NULL)
            {
               free (ngroup);
               ngroup = NULL;
            }
          expgroup (&(groups[i]), limit);
       }

     if (*newsgroup != '\0'  &&  !found)
          fprintf (log, "%s %s newsgroup not found: %s\n",
                        sender, gtime(), newsgroup);

     /* Update active file to reflect expired news articles */
     updactive();
     closelog();
     exit (0);
}



int openlog()
{
     char temp[80];

     ramdisk = FALSE;

     /* For testing send everything to the screen --REB */
     if (expireflag == FALSE)
          log = stdout;

     /* with debug on, don't use the RAM disk --REB */
     else if (debuglvl > 0)
       {
          sprintf (temp, "%s/uulog", logdir);
          log = fopen (temp, "a");
          logopen = TRUE;
       }

     /* for normal use (debug off), use RAM disk for temporary log -- REB */
     else
       {
          sprintf (temp, "%s/uulog", RAMDISK);

          if ((log = fopen (temp, "w")) != NULL)
               ramdisk = TRUE;
          else
            {
               sprintf (temp, "%s/uulog", logdir);
               log = fopen (temp, "a");
            }

          logopen = TRUE;
       }

     /* log file should be unbuffered -- REB */
     setbuf (log, NULL);
}



int closelog()
{
     char temp[80], temp2[80];

     /* close log file -- REB */
     if (logopen)
       {
          fclose (log);
          logopen = FALSE;

          /* move RAM disk copy to permanent log file -- REB */
          if (ramdisk)
            {
               asetuid (0);
               sprintf (temp2, "%s/uulog", RAMDISK);
               sprintf (temp, "%s/uulog", logdir);
               fileapnd (temp2, temp, TRUE);
               unlink (temp2);
            }
       }
}



/* clean up if we get a keyboard interrupt --REB */

int myinterrupt (sig)
int sig;
{
     closelog();
     exit (sig);
}



int usage()
{
     char *strdetab(), temp[80];
     register char **use;
     static char *usetxt[] = {
          "expire\t\tnews article expire utility",
          " ",
          "\t-t\t\t test (don't actually delete articles)",
          "\t-x<level>  debug, default is 0 (OFF)",
          "\t-n<group>  expire only given group",
          "\t-e<days>   expire articles older than specified number of days",
          " ",
          "\tWith no arguments, expires all articles older than 14 days in",
          "\tall newsgroups.",
          NULL
       };

     for (use = usetxt; *use != NULL; ++use)
          fprintf (stderr, " %s\n", strdetab (strcpy (temp, *use), 4));

     fprintf (stderr, "\nv%s (%s) This is free software released under the GNU General Public\n",
                      version, VERDATE);
     fputs ("License.  Please send suggestions/bug reports to:  bob@kc2wz.bubble.org\n", stderr);
     exit (0);
}



int fatal (msg)
char *msg;
{
     fprintf (stderr, "expire: %s", msg);

     if (errno != 0)
          fprintf (stderr, "...error %d\n", errno);

     exit (0);
}
