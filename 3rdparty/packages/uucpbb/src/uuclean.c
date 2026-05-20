/*  uuclean.c   The program cleans the UUCP spool directories.
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

/* Looks in the spool directory for any files that are older then the
   specified number of days (default 7).  Deletes those that are and mails the
   owner telling him of this action.

   Deletes the oldest log file and rotates the rest.

   Allows only the superuser (uid 0) to use the utility to prevent
   unauthorized users from deleting files.

   Thanks to Mark for his okey dokey to modify and use his program in the
   UUCPbb package.  --Bob Billson (REB) */

#define MAIN                                      /* Added -- REB */

#include "uucp.h"
#include <modes.h>
#include <time.h>
#include <ctype.h>
#ifndef _OSK
#include "dir_6809.h"
#else
#include <dir.h>
#endif

#define DEFDAYS   7                          /* default oldest file days */
#define WORDSIZE  4                          /* added --REB */

extern QQ unsigned myuid;
extern QQ char *nodename, *sitename;
extern QQ flag fsactive;
extern char user[];

/* array of log filenames to move in the log directory */
QQ char *uul[] = { "uulog.7",
                   "uulog.6",
                   "uulog.5",
                   "uulog.4",
                   "uulog.3",
                   "uulog.2",
                   "uulog.1",
                   "uulog",
                 };

QQ char *fsl[] = { "fileserv.7",
                   "fileserv.6",
                   "fileserv.5",
                   "fileserv.4",
                   "fileserv.3",
                   "fileserv.2",
                   "fileserv.1",
                   "fileserv",
                 };

/* Variable declarations */
QQ flag verbose = FALSE;                       /* verbose off */
QQ flag debug = FALSE;                         /* debug off */
QQ flag cplogs = TRUE;                         /* copy log files by default */
QQ int pn;
QQ char *def_dir;
QQ FILE *fd;
QQ FILE *log;
long num_days;
char def_date[6], timestr[21], tempstr[128];
char xtype[2], datafile[80];

/* Structures */
struct fildes fdbuf;                        /* file descriptor buffer */

/* Function declarations */
void mail_owner();
void mvlogs();

int main (argc, argv)
int argc;
char *argv[];
{
     char dirname[100];
     int option;
     DIR *dir;                          /* these two structures are already */
     struct direct *pdir;               /* defined in dir.h.  Added --REB */

     /* initialize variables */
     num_days = DEFDAYS;                     /* default number of days */
     log = stderr;                           /* don't log error -- REB */
     def_dir = NULL;

     if (getuid() != 0)
          fatal ("you are not the superuser!");

     if (getparam() == FALSE)
          exit (0);

     if ((logdir = getenv ("LOGDIR")) != NULL)
          logdir = strdup (logdir);
     else
          logdir = LOGDIR;

     strcpy (user, "uucp");

     /*  Process any command line arguments */
     while ((option = getopt (argc, argv, "vxln:d:?")) != EOF)
          switch (tolower (option))
            {
               case 'v':
                    verbose = TRUE;
                    break;

               case 'x':
                    verbose = TRUE;
                    debug = TRUE;
                    break;

               case 'l':
                    cplogs = FALSE;
                    break;

               case 'n':
                    num_days = abs (atoi (optarg));
                    break;

               case 'd':
                    free (def_dir);

                    if ((def_dir = strdup (optarg)) == NULL)
                         fatal ("can't dup -d <directory>");
                    break;

               case '?':
                    usage();
                    break;
            }

     /* default to spool directory if we weren't told to use another --REB */
     if (def_dir == NULL)
          if ((def_dir = getdirs ("spooldir")) == NULL)
               fatal ("spooldir not in Parameters");

     /*  Calculate the time */
     rtime (num_days, def_date);

     if (verbose)
          printf ("\nRemove all files before: %s\n", timestr);

     if ((dir = opendir (def_dir)) == NULL)  
       {
          sprintf (tempstr, "cannot open %s\n", def_dir);
          fatal (tempstr);
       }

     /* loop through each directory in UUCP spool directory -- REB */
     while ((pdir = readdir (dir)) != NULL) 
       {
          if (pdir->d_name[0] == '.')
               continue;

          sprintf (dirname, "%s/%s", def_dir, pdir->d_name);

          /* change to the spool directory for the next remote */
          if (chdir (dirname) == ERROR)
               fprintf (stderr, "can't change to directory '%s'\n", dirname);

          if (verbose)
               printf ("\nChanged to directory '%s'\n", dirname);

          /* clean up this spool directory */
          rmspooled (dirname);

          /* backup one directory level and go for the next one */
          chdir ("..");
       }
     free (def_dir);
     closedir (dir);

     /* Copy the log files unless -l option is used.  Rotate the uulog files.
        Also the FileServ log files if the fileserver is active */

     if (cplogs)
       {
          mvlogs (TRUE);              /* rotate uulog files */

          if (fsactive)
               mvlogs (FALSE);        /* rotate FileServ */
       }
     exit (0);
}



/* Go through the spool directory.  Open each file and check its last modified
   date with the default date.  If the file is older, delete it.  Mail the
   owner if the file is a C. work file. */

int rmspooled (dirname)
char *dirname;
{
     char filename[100], dfile[11];
     DIR *dir;                        /* these two structures are already */
     struct direct *pdir;                             /* defined in DIR.H */
     flag got_data_file;
     char *words[WORDSIZE];                                 /* REB */

     if ((dir = opendir (dirname)) == NULL)  
       {
          sprintf (tempstr,"cannot open %s\n", dirname);
          fatal (tempstr);
       }
     sprintf (dfile, "D.%s", nodename);

     while ((pdir = readdir (dir)) != NULL)
       {
          if (pdir->d_name[0] == '.')
               continue;

          strcpy (filename, pdir->d_name);

          if (verbose)
               printf ("\nFound file '%s'\n", filename);

          if ((pn = open (filename, 1)) == ERROR)
            {
               if (verbose)
                    printf ("cannot open '%s'\n", filename);

               continue;
            }

          if ((_gs_gfd (pn, &fdbuf, sizeof (fdbuf))) == ERROR)
            {
                close (pn);

                if (verbose)
                     puts ("Error getting file descriptor");

                continue;
            }

          if (verbose)
               printf ("Date of this file is: %02d/%02d/%02d %02d:%02d\n",
                       fdbuf.fd_date[1], fdbuf.fd_date[2],
                       fdbuf.fd_date[0], fdbuf.fd_date[3],
                       fdbuf.fd_date[4]);

          /* If this is a D.<ournode> data file return it to sender */
          if (strnucmp (filename, dfile, strlen (dfile)) == 0)
            {
               strcpy (datafile, filename);
               got_data_file = TRUE;

               if (verbose)
                    printf ("Got data file '%s\n", datafile);
            }
          else
               got_data_file = FALSE;

          close (pn);

          if (strncmp (fdbuf.fd_date, def_date, 5) <= 0)
            {
               if (got_data_file)
                    mail_owner();

               if (verbose)
                    printf ("%s ....\n", debug ? "would be deleted"
                                               : "deleting");
               if (!debug)
                    unlink (filename);
            }
          else
               if (verbose)
                    puts ("Not old enough to kill!");
       }
     closedir (dir);
}



/* Rtime is a function which returns a date relative to the current date and
   time. It expects an OFFSET, which is an integer in units of days (+ or -)
   from today.  DATEBUFF is the location in which to return the new relative
   date.

   Provided by Pete Lyall - CIS 76703,4230

   Slightly modified by Mark Griffith to return a time the number of days less
   than the current time as passed in offset. */

int rtime (offset, datebuff)
long offset;
struct sgtbuf *datebuff;
{
     long systime;
     struct tm *utimeptr;

     systime = time ((char *)0);                    /* get current time */

     /* substract the offset in hours */
     systime -= offset*24L*60L*60L;                 /* changed [MDG] */
     utimeptr = localtime(&systime);

     datebuff->t_year   = utimeptr->tm_year;
#ifdef _OSK
     datebuff->t_month  = utimeptr->tm_mon + 1;     /* OSK is different!!! */
#else
# ifndef NEWCLIB                                 /* early Kreider CLIB.L    */
     datebuff->t_month  = utimeptr->tm_mon;      /* does it one way, newer  */
# else                                           /* versions (1990) does it */
     datebuff->t_month  = utimeptr->tm_mon + 1;  /* like OSK...confused??   */
# endif                                          /* me, too --REB           */
#endif
     datebuff->t_day    = utimeptr->tm_mday;
     datebuff->t_hour   = utimeptr->tm_hour;
     datebuff->t_minute = utimeptr->tm_min;
     datebuff->t_second = utimeptr->tm_sec;

     /* Setup a string with the date in it for possible printing.
        Added [MDG] */

     sprintf (timestr,"%02d/%02d/%02d %02d:%02d:%02d",
                      datebuff->t_month, datebuff->t_day, datebuff->t_year,
                      datebuff->t_hour, datebuff->t_minute,
                      datebuff->t_second);
/*   return (datebuff); */
}



/* attempt to return the undeliverable mail to the sender. */

void mail_owner()
{
     char line[256], tmpfile[80], rtrnto[128], origto[128];
     FILE *msgfd;
     register char *lp;
     flag header;
     unsigned tmpuid;
     char *p;

     if ((fd = fopen (datafile, "r")) == NULL)
          return;

     extractadrs (rtrnto, origto);

     if (*rtrnto == '\0')
       {
          fclose (fd);
          return;
       }

     if (verbose)
          printf ("would return mail for: %s\nback to: %s\n", origto, rtrnto);

     if (debug)
       {
          fclose (fd);
          return;
       }

     /* create the return message */
     maketemp (tmpfile, '1', FALSE);

     if ((msgfd = fopen (tmpfile, "w")) == NULL)
       {
          fclose (fd);
          return;
       }

     /* daemon is the one sending the mail */
     setuser ("daemon");
     tmpuid = getuid();
     chown (tmpfile, tmpuid);
     asetuid (0);

     /* assemble the returned message */
     fprintf (msgfd, "From MAILER-DAEMON %s\n", date822());
     fprintf (msgfd, "Date: %s\n", date822());
     fprintf (msgfd, "From: Mail Delivery Subsystem <MAILER-DAEMON@%s>\n",
                     sitename);

     fprintf (msgfd, "Reply-To: nobody@%s\n", sitename);
     fprintf (msgfd, "To: %s\n", rtrnto);
     fprintf (msgfd,
              "Subject: Returned mail: Cannot send message for %d day%s\n\n",
              (int) num_days, (int) num_days > 1 ? "s" : "");

     fprintf (msgfd,
              "After %d day%s, your message to the following person:\n\n",
              (int) num_days, (int) num_days > 1 ? "s" : "");

     fprintf (msgfd, "    %s\n\n", origto);
     fputs ("could not be delivered.  No further attempts will be made.\n\n",
             msgfd);

     fputs ("        Sincerely,\n", msgfd);
     fprintf (msgfd, "        %s!uucp\n\n", nodename);
     fputs ("   ----- Unsent message follows -----\n", msgfd);

     /* now tack on the unsent message */
     rewind (fd);
     lp = line;

     while (mfgets (lp, sizeof (line), fd) != NULL)
          if (*lp != '\0')
               fprintf (msgfd, "%s\n", lp);
          else
               putc ('\n', msgfd);

     fclose (fd);
     fclose (msgfd);

     /* send it back */
     sprintf (tempstr, "rmail %s %s", tmpfile, rtrnto);

     if (docmd_na (tempstr) != 0)
               fputs ("uuclean: unable to fork RMAIL\n", stderr);

     unlink (tmpfile);
}



/* extract the To: and From: addresses of mail to return. --REB */

int extractadrs (origfrom, origto)
char *origfrom, *origto;
{
     char replyto[128], resentfrm[128], resentrply[128], line[256];
     char rtrnto[128];
     register char *lp;
     flag header;
     unsigned tmpuid;
     char *p;

     *resentfrm =  '\0';
     *resentrply = '\0';

     /* be sure this are all cleared out -- REB */
     memset (replyto, '\0', sizeof (replyto));
     memset (rtrnto, '\0', sizeof (rtrnto));

     /* start reading lines looking for "From:" or "Reply-to:" */
     header = TRUE;
     lp = line;

     /* Are we still in the header?  If so, look at line */
     while (header)
          if (mfgets (line, sizeof (line), fd) != NULL)
            {
               if (*lp == '\0')
                 {
                    header = FALSE;
                    continue;
                 }

               /* Be paranoid and extract From return path this will be
                  overwritten by From: or Reply-to:, if found. */

               if (strncmp (lp, ">From ", 6) == 0
                    ||  strnucmp (lp, "From ", 5) == 0)
                 {
                    strcpy (tempstr, skipspace (lp+5));

                    for (p = tempstr; !isspace (*p) && *p != '\0'; p++)
                         ;

                    *p = '\0';
                    strcpy (rtrnto, tempstr);
                 }

               /* extract From: return path */
               if (*lp == 'F'  &&  strnucmp (lp, "From: ", 6) == 0)
                     strcpy (rtrnto, getval (line));

               /* Reply-To, Resent-Reply-To, Resent-From: fields */
               if (*lp == 'R')
                 {
                    /* extract Reply-To: return path */
                    if (strnucmp (lp, "Reply-To: ", 10) == 0)
                         strcpy (replyto, getval (line));

                    /* extract Resent-From: path */
                    else if (strnucmp (lp, "Resent-From: ", 13) == 0)
                         strcpy (resentfrm, getval (line));

                    /* extract Resent-Reply-To: path */
                    else if (strnucmp (lp, "Resent-Reply-To: ", 17) == 0)
                         strcpy (resentrply, getval (line));
                 }

               if (*lp == 'T'  &&  strnucmp (lp, "To: ", 4) == 0)
                    strcpy (origto, getval (line));
            }
          else
            {
               /* header ended prematurely */
               *origfrom = '\0';
               return (0);
            }

     /*      Resent-Reply-To: supercedes From: in determining return path
        -or- Resent-From:     supercedes From: in determining return path
        -or- Reply-To:        supercedes From: in determining return path  */

     if (*resentrply != '\0')
          strcpy (rtrnto, resentrply);
     else if (*resentfrm != '\0')
          strcpy (rtrnto, resentfrm);
     else if (*replyto != '\0')
          strcpy (rtrnto, replyto);

     strcpy (origfrom, rtrnto);
}



/* Rotate old uulog or FileServ files deleting the oldest */

void mvlogs (uulogs)
flag uulogs;
{
     int i;

     if (chdir (logdir) == ERROR)            /* change to the log directory */
          return;

     if (verbose)
          printf ("\nDeleting %s\n", uul[0]);

     if (!debug)
          if (uulogs)                             /* delete oldest log file */
               unlink (uul[0]);                   /* uulog files */
          else
               unlink (fsl[0]);                   /* FileServ files */

     for (i = 0; i < 7; i++)
       {
          if (verbose)
               printf ("Renaming %s to %s\n",
                       uulogs ? uul[i + 1] : fsl[i + 1],
                       uulogs ? uul[i]     : fsl[i]);

          if (!debug)
            {
               sprintf (tempstr, "rename %s %s",
                        uulogs ? uul[i + 1] : fsl[i + 1],
                        uulogs ? uul[i]     : fsl[i]);

               docmd_na (tempstr);
            }
       }

     if (!debug)
       {
          /* create new log file ignoring errors */
          if (uulogs)
               fd = fopen (uul[7], "w");
          else
               fd = fopen (fsl[7], "w");

          fclose (fd);
       }
}



int fatal (msg)
char *msg;
{
     fprintf (stderr, "uuclean: %s", msg);

     if (errno != 0)
          fprintf (stderr, "...error %d", errno);

     putc ('\n', stderr);
     exit (0);
}



int usage()
{
     fputs ("\nuuclean: removed old UUCP files, rotate UUCP and FileServ log files\n",
            stderr);
     fputs ("Usage: uuclean [opts]\n\n", stderr);
     fprintf (stderr,
               "Opts:   -nX     Remove those files over X days old (default is %d)\n",
               DEFDAYS);
     fputs ("        -ddir   Use this directory name\n", stderr);
     fputs ("        -v      Set verbose option on\n", stderr);
     fputs ("        -l      Do not rotate log files\n", stderr);
     fputs ("        -x      Set debug option on (files are not touched)\n\n",
            stderr);
     fprintf (stderr, "v%s (%s) This is free software released under the GNU General Public\n",
                      version, VERDATE);
     fputs ("License.  Please send suggestions/bug reports to:  bob@kc2wz.bubble.org\n", stderr);
     exit (0);
}
