/*  postnews.c   This is main program for sending Usenet news.
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

   -f <file>
   -n <newsgroup>
   -S <system>
   -s <subject>
   -i <reference-ID>
   -a <reference-article>
   -t (force /t2 "dumb" windowing codes)
   -x <debug_level>
*/

#define MAIN

#include "uucp.h"
#include <time.h>
#ifndef _OSK
#include <utime.h>
#endif
#include <signal.h>
#ifndef _OSK
#include <os9.h>
#endif

extern QQ unsigned myuid;
extern QQ char sepsym, quotechar;
extern QQ char *nodename, *sitename, *name, *newshost, *organization;
extern char user[], temp[];

#ifndef TERMCAP
QQ flag t2flag = FALSE;
#endif
QQ FILE *log;
#ifndef _OSK
QQ flag usedotilde;
static char *dotilde = "dotilde";
#endif
QQ char *got_escape = "<ESC> hit...exiting";
QQ int debuglvl = 0;
static char value[100];
char sysname[20], artfile[100], newsgroup[1024], subject[128];
char reference[256],article[100], distrib[50], localgroup[256];
char tempfile[100];                /* moved from postgroup() so myinterrupt() */
                                   /* can clean up -- REB */

int main(argc, argv)
int argc;
char *argv[];
{
     int option, myinterrupt();
     register char *p;
#ifndef _OSK
     struct registers regs;
#endif
     *sysname = *artfile = *newsgroup = *subject = *localgroup = '\0';
     *reference = *article = *tempfile = '\0';
     homedir = NULL;
     opterr = TRUE;
     log = stderr;               /* use stderr rather than uulog file --REB */

#ifndef _OSK
     pflinit();                  /* tell linker longs will be printed --REB */
#endif

     /* handle keyboard interrupts */
     intercept (myinterrupt);

#ifdef TERMCAP
     init_term_cap();
#endif

     while ((option = getopt (argc, argv, "f:n:s:S:i:a:tx:")) != EOF)
          switch (option)
            {
               case 'f':
                    strcpy (artfile, optarg);
                    break;

               case 'n':
                    strcat (strcat (newsgroup, optarg), " ");
                    break;
 
               case 's':
                    strcpy (subject, optarg);
                    break;

               case 'S':
                    strcpy (sysname, optarg);
                    break;

               case 'i':
                    strcpy (reference, optarg);
                    break;

               case 'a':
                    strcpy (article, optarg);
                    break;

               case 't':
#ifndef TERMCAP
                    t2flag = TRUE;
                    break;
#endif
               case 'x':
                    debuglvl = atoi (optarg);
                    break;

               case '?':
                    usage();
                    break;

               default:
                    strcat (strcat (newsgroup, optarg), " ");
                    break;
            }

     /* elminated last blank in newsgroup list -- REB */
     newsgroup[strlen (newsgroup) - 1] = '\0';

     if (getparam() == FALSE)
          myinterrupt (0);

     userparam();

     if ((newsdir = getdirs ("newsdir")) == NULL)
          badparam ("newsdir");

     if ((spooldir = getdirs ("spooldir")) == NULL)
          badparam ("spooldir");

#ifndef _OSK
    if (nmlink (dotilde, 0, 0) == -1)
         if (nmload (dotilde, 0, 0) == -1)
              fatal ("can't load dotilde");

    usedotilde = TRUE;
#endif

#ifndef TERMCAP
     if (!t2flag)
          t2flag = t2test();
#endif
     /* figure out path to article being replied to, if any */
     if (*article != '\0')
       {
          sprintf (temp, "%s/%s/%s", newsdir, newsgroup, article);

          while ((p = strchr (temp, '.')) != NULL)
               *p = '/';

          strcpy (article, temp);
       }

     /* use default newsfeed host is -S wasn't on command line -- REB */
     if (*sysname == '\0')
          if (*newshost != '\0')
               strcpy (sysname, newshost);
          else
               getsys (sysname);

     /* get user name */
     if (*user == '\0')
          fatal ("user not in password file");

     /* post article to newsgroup */
     postgroup (sysname);
     myinterrupt (0);
}



/* postgroup  --queue article for remote news delivery */

int postgroup (system)
char *system;
{
     static char line[128], filename[50];
     static char cname[15], xname[14], dname[14], jname[14];
     char seq[5];
     FILE *file, *qfile, *sigfile;
     char *p;
     long nseq;
     int result;
     flag localonly;

     /* open prepared article, if any */
     if (*artfile != '\0')
          if ((file = fopen (artfile, "r")) == NULL)
               fatal ("can't open article file");

     /* Become super user so we can go to proper spool file */
     asetuid (0);
     sprintf (temp, "%s/%s", spooldir, system);

     if (chdir (temp) == -1)
       {
          char tmp[100];

          sprintf (tmp, "can't change to spool directory: %s\n", temp);
          fatal (tmp);
       }
     asetuid (myuid);

     /* Get unique message ID number.  Moved here to speed things up a bit.
        When we return our user ID will be restored.  --REB */

     nseq = getseq (NEWSEQ);

     /* figure out all the spool file names */
     strcpy (seq, genseq() );

     /* D.sysnameXXXX filename (article data file) */
     sprintf (dname, "D.%.7s%s", nodename, seq);

     /* D.sysnameXXXX file (job file) */
     sprintf (jname, "D.%.7s%s", system, seq);

     /* C.sysnameCXXXX (control file) */
     sprintf (cname, "C.%.7sC%s", system, seq);

     /* X.sysnameXXXX (execute file) */
     sprintf (xname, "X.%.7s%s", system, seq);

     /* open article data file */
     maketemp (tempfile, '1', FALSE);

     /* change id so we can open a file -- BAS */
     cls();
     asetuid (0);

     if ((qfile = fopen (tempfile, "w")) == NULL)
          fatal ("can't open article data file");

     fixperms (qfile);
     asetuid (myuid);

     /* Path: ccentral!rickadams */
     fprintf (qfile, "Path: %s!%s\n", nodename, user);

     /* From: rickadams@ccentral.UUCP (The OTHER Rick Adams) */
     sprintf (line, "From: %s%c%s%s%s%s\n",
                    sepsym != '!' ? user : sitename,
                    sepsym,
                    sepsym != '!' ? sitename : user,
                    *name != '\0' ? " (" : "",
                    *name != '\0' ? name : "",
                    *name != '\0' ? ")"  : "");

     fputs (line, stdout);
     fputs (line, qfile);

     /* Newsgroups: ca.test */
     if (*newsgroup == '\0')
       {
          sprintf (filename, "%s/active", UUCPSYS);
          getvalue (qfile, "Newsgroups", filename);
          strcpy (newsgroup, value);
       }
     else
       {
          sprintf (line, "Newsgroups: %s\n", newsgroup);
          fputs (line, stdout);
          fputs (line, qfile);
       }

     /* Subject: test */
     if (*subject == '\0')
          getfield (qfile, "Subject", TRUE);
     else
       {
          sprintf (line, "Subject: %s\n", subject);
          fputs (line, stdout);
          fputs (line, qfile);
       }

     /* Keywords: test */
     getfield (qfile, "Keywords", FALSE);

     /* Message-ID: <1@ccentral.UUCP>   Changed -- REB */
     sprintf (line, "Message-ID: <%ld@%s>\n", nseq, sitename);
     fputs (line, stdout);
     fputs (line, qfile);

     /* Date: Tue, 12 Feb 91 10:57:45 -0800    Changed -- REB */
     strcat (strcpy (line, "Date: "), date822());
     puts (line);
     fprintf (qfile, "%s\n", line);

     /* Reply-To: user@sitename   Some news articles seem to have this */
     /* I don't know if it is done completely right. -- BAS            */

     sprintf (line, "Reply-To: %s%c%s\n",
                    sepsym != '!' ? user : sitename,
                    sepsym,
                    sepsym != '!' ? sitename : user);

     fputs (line, stdout);
     fputs (line, qfile);

     /* References: <1234@sitename.UUCP>   Changed -- REB */
     if (*reference != '\0')
       {
          sprintf (line, "References: %s\n", reference);
          fputs (line, stdout);
          fputs (line, qfile);
       }

     /* Distribution: ca */
     if (!localcheck())
       {
          sprintf (filename, "%s/distributions", UUCPSYS);
          getvalue (qfile, "Distribution", filename);
          strcpy (distrib, value);
       }
     else
       {
          /* local article */
          sprintf (line, "Distribution: local\n");
          fputs (line, stdout);
          fputs (line, qfile);
          strcpy (distrib, "local");
       }

     /* local distribution only? */
     localonly = (strcmp (distrib, "local") == 0)  ? TRUE : FALSE;

     /* Summary: This is a test message. */
     getfield (qfile, "Summary", FALSE);

     /* Organization: Color Central Software */
     if (*organization != '\0')
       {
          sprintf (line, "Organization: %s\n", organization);
          fputs (line, stdout);
          fputs (line, qfile);
       }

     /* body of message */
     putchar ('\n');
     putc ('\n', qfile);

     if (*artfile != '\0')
       {
          while (fgets (line, sizeof (line), file) != NULL)
            {
               if ((p = strchr (line, '\n')) != NULL)
                    *p = '\0';

               fprintf (qfile, "%s\n", line);
               printf ("%s\n", line);
            }
          fclose (file);
       }
     else
          for (;;)
            {
               /* end of input? */
               if (fgets (line, sizeof (line), stdin) == NULL)
                    break;

               if (*line == '.'  &&  *(line + 1) == '\n')
                 {
                    CurUp();
                    fputs (" \b", stdout);
                    fflush (stdout);
                    break;
                 }
               else
                 {
                    if (*line == '~')
                      {
                         int tilde;

                         fclose (qfile);
                         line[strlen (line) - 1] = '\0';

                         sprintf (temp,
                                  "dotilde \"%s\" %d %d %c %s %s %s",
#ifndef TERMCAP
                                  line, t2flag, myuid, quotechar, tempfile,
#else
                                  line, 0, myuid, quotechar, tempfile,
#endif
                                  homedir, article);

                         asetuid (0);
                         tilde = docmd_na (temp);

                         if (tilde == SIGINT  ||  tilde == SIGQUIT
                             || tilde == ABORT)
                           {
                              myinterrupt (0);
                           }

                         if ((qfile = fopen (tempfile, "a")) == NULL)
                              fatal ("can't reopen article file");

                         fixperms (qfile);
                         asetuid (myuid);
                      }
                    else
                         fprintf (qfile, "%s", line);
                 }
            }

     /* append signature file */
#ifdef _OSK
     sprintf (line, "%s/.signature", homedir);
#else
     sprintf (line, "%s/%s/signature", homedir, uudir);
#endif

     if ((sigfile = fopen (line, "r")) != NULL)
       {
          fprintf (qfile, "-- \n");
          puts ("--");

          while (fgets (line, sizeof (line), sigfile) != NULL)
            {
               if ((p = strchr (line, '\n')) != NULL)
                    *p = '\0';

               fprintf (qfile, "%s\n", line);
               printf ("%s\n", line);
            }
          fclose (sigfile);
       }

     /* close article file */
     fclose (qfile);

     /* transfer article file to queued data file and replace CRs with LFs */
     asetuid (0);
     filemovl (tempfile, dname);
     *tempfile = '\0';
     fputs ("\n\nposting your article...locally...", stdout);
     fflush (stdout);

     /* post article locally */
     sprintf (line, "rnews -x%d -n%s %s", debuglvl, newsgroup, dname);

     if ((result = docmd_na (line)) != 0)
       {
          unlink (dname);
          myinterrupt (result);
       }

     /* local article only? */
     if (localonly)
       {
          asetuid (0);                  /* so we can delete the file -- BAS */
          unlink (dname);
          asetuid (myuid);
          cls();
          return (0);
       }

     fputs ("and to the net...", stdout);
     fflush (stdout);

     /* write job file */
     asetuid (0);

     if ((qfile = fopen (jname, "w")) == NULL)
          fatal ("can't create job file");

     fixperms (qfile);
     chown (jname, myuid);

     fprintf (qfile, "U %s %s\x0a", user, nodename);
     fprintf (qfile, "F %s\x0a", dname);
     fprintf (qfile, "I %s\x0a", dname);
     fputs ("C rnews \x0a", qfile);
     fclose( qfile);

     /* write control file */
     if ((qfile = fopen (cname, "w")) == NULL)
          fatal ("can't create control file");

     fixperms (qfile);
     chown (cname, myuid);

     fprintf (qfile, "S %s %s %s - %s 0666 %s\n",
                     dname, dname, user, dname, user);

     fprintf (qfile, "S %s %s %s - %s 0666 %s\n",
                     jname, xname, user, jname, user);

     fclose (qfile);
     asetuid (myuid);
     cls();
     return (0);
}



int getvalue (file, prompt, filename)
FILE *file;
char *prompt, *filename;
{
     char line[100];
     flag status;
     FILE *file2;
     char *p;

     do
       {
          /* get value */
          do
            {
               printf ("%s: ", prompt);

               if (mfgets (value, sizeof (value), stdin) == NULL)
                 {
                    errno = 0;
                    fatal (got_escape);
                 }

               if (*value == '\0')
                    printf ("\nThe \"%s\" field is required.\n\n", prompt);
            }
          while (*value == '\0');

          status = findent (value, filename, line, sizeof(line));

          if (!status)
            {
               /* dump out valid values */
               printf ("\nInvalid -- valid values for \"%s\" are:\n", prompt);

               if ((file2 = fopen (filename, "r")) != NULL)
                 {
                    while (mfgets (line, sizeof (line), file2) != NULL)
                      {
                         if ((p = strchr (line, ' ')) != NULL)
                              *p = '\0';

                         printf ("   %s\n", line);
                      }
                    fclose (file);
                 }
               putchar ('\n');
            }
       }
     while (!status);

    fprintf (file, "%s: %s\n", prompt, value);
}



int getfield (file, prompt, needthis)
FILE *file;
char *prompt;
flag needthis;                                          /* field required? */
{
     register char *p;

     p = value;
     do
       {
          printf ("%s: ", prompt);

          if (mfgets (p, sizeof (value), stdin) == NULL)
            {
               errno = 0;
               fatal (got_escape);
            }

          if (needthis  &&  *p == '\0')
               printf ("\nThe \"%s\" field is required.\n\n", prompt);

       }
     while (needthis  &&  *p == '\0');

     fprintf (file, "%s: %s\n", prompt, p);
     return (strlen (p));
}



/* check to see if this is a local newsgroup */

int localcheck()
{
     /* newsgroup begins with "nodename."? */
     strcat (strcpy (temp, nodename), ".");

     if (strncmp (newsgroup, temp, strlen (temp)) == 0)
          return (TRUE);

     /* newsgroup begins with "local." or "general."? */
     if (strncmp (newsgroup, "local.", 6) == 0)
          return (TRUE);
     else if (strncmp (newsgroup, "general.", 8) == 0)
          return (TRUE);
     else
          return (FALSE);
}



int fatal (msg)
char *msg;
{
     fprintf (stderr, "\npostnews: %s", msg);

     if (errno != 0)
          fprintf (stderr, "...error %d", errno);

     putc ('\n', stderr);
     myinterrupt (0);
}



int badparam (msg)
char *msg;
{
     fprintf (stderr, "postnews: %s not in Parameters\n", msg);
     myinterrupt (0);
}



/* deal with interruptions */

int myinterrupt (sig)
int sig;
{
     if (*tempfile != '\0')
          unlink (tempfile);
#ifndef _OSK
     if (usedotilde)
          munload (dotilde, 0);
#endif
     exit (sig);
}



int usage()
{
     char *stredetab();
     register char **ptr;
     static char *help[] = {
                     "postnews\t post news to Usenet",
                     " ",
                     "Usage: postnews [options]",
                     "\t  Options:",
                     "\t\t-f <file>",
                     "\t\t-n <newsgroup>",
                     "\t\t-S <system>",
                     "\t\t-s <subject>",
                     "\t\t-i <reference-ID>",
                     "\t\t-a <reference-article>",
#ifndef TERMCAP
                     "\t\t-t (force /t2 \"dumb\" windowing codes)",
#endif
                     NULL
                  };

     putc ('\n', stderr);
     for (ptr = help;  *ptr != NULL;  ++ptr)
          fprintf (stderr, "%s\n", strdetab (strcpy (temp, *ptr), 6));

     fprintf (stderr, "\nv%s (%s) This is free software released under the GNU General Public\n",
                      version, VERDATE);
     fputs ("License.  Please send suggestions/bug reports to:  bob@kc2wz.bubble.org\n", stderr);
     exit (0);
}
