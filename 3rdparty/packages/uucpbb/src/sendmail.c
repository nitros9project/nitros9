/*  sendmail.c   This routine lets a user compose and sendmail.
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

/* Send mail to all addressees.  Mail that cannot be sent is saved in the
   user's home directory in the file 'dead.letter'.  Rewritten --REB  */

#include "uucp.h"
#include "mail.h"
#include <time.h>
#include <ctype.h>
#include <signal.h>

#define WORDSIZE  40

EXTERN QQ char sepsym, quotechar, *dotilde;
EXTERN QQ flag usedotilde, rmailin;

static QQ flag fromdaemon;                      /* mail from user 'daemon' */


int sendmail()
{
     char *words[WORDSIZE];
     register int i;
     int n, result;
     char *deadletter = "dead.letter";

     *tempfile = '\0';

     /* Is user local user 'daemon'? */
     fromdaemon =  strucmp (user, "daemon") == 0  ? TRUE : FALSE;
     asetuid (0);
     maketemp (tempfile, '1', FALSE);        /* compose mail in temp file */
     asetuid (myuid);

     /* If ABORT is returned something went wrong.  An error message should
        have already be display, just exit quietly.  Otherwise, send the
        mail. */

     if (compmail() == OK)
       {
          /* separate the destination addresses */
          n = getargs (words, address, WORDSIZE);

          /* send to each address */
          puts ("\n");

          if (n > 0)
            {
               /* Load rmail if it isn't already loaded.  We may be back with
                  more. */
#ifndef _OSK
               if (!rmailin)
                 {
                    asetuid (0);

                    if (nmlink (rmail, 0, 0) == -1)
                         if (nmload (rmail, 0, 0) == -1)
                              fatal ("sendmail: can't load rmail");
                 }
#else
               if (n > 1  &&  !rmailin)
                 {
                    asetuid (0);

                    if (modlink (rmail, 0) == -1)
                      {
                         char tmp[64];

                         if (modloadp (rmail, 0, tmp) == -1)
                              fatal ("sendmail: can't load rmail");
                      }
                 }
#endif
               asetuid (myuid);
               rmailin = TRUE;

               for (i = 0; i < n; i++)
                 {
                    printf ("%s %s %s\n",
                            forward ? i == 0 ? "Forwarding" :  "          "
                                    : i == 0 ? "Sending"    :  "       ",
                            i == 0  ? "mail to:"  : "        ",
                            words[i]);

                    sprintf (cmd, "rmail %s %s",
                                  tempfile, words[i]);

                    if (debug > 0)
                         puts  (cmd);

                    /* superuser runs RMAIL but don't quit on errors */
                    asetuid (0);
                    result = docmd_na (cmd);
                    asetuid (myuid);

                    if (result != 0)
                      {
                         printf ("undelivered mail put in '%s'\n\n",
                                 deadletter);

                         sprintf (fname, "%s/%s", homedir, deadletter);
                         fileapnd (tempfile, fname, TRUE);
                      }
                 }
            }
          else
            {
               Bell();
               printf ("mailx: who do I send the mail to?  Mail put in '%s'\n\n",
                       deadletter);

               sprintf (fname, "%s/%s", homedir, deadletter);
               fileapnd (tempfile, fname, TRUE);
            }
       }

     /* throw away mail temp file */
     asetuid (0);
     unlink (tempfile);
     asetuid (myuid);
     *tempfile = '\0';
}



/* compose mail

   Changed to allow forwarded mail, mail from local mailer daemon such as
   bounced mail.  The global variable tempfile contains the name of the
   temporary mail file.  TRUE (OK) is returned if mail is to be sent.  ABORT
   is returned if there was some type of of error. */

int compmail()
{
     char *words[40], *p, **wordptr, **wordlast;
     int count;
     struct sgtbuf date;
     long seq;
     register char *lp;
     char *got_escape = "<ESC> hit...exiting";

     lp = line;

     /* open temporary mail file */
     asetuid (0);                                      /* BAS */

     if ((ltrfile = fopen (tempfile, "w")) == NULL)
          fatal ("compmail: can't open temp file");

     /* set ownership of file and reset uid -- BAS */
     chown (tempfile, myuid);
     asetuid (myuid);
     fixperms (ltrfile);

     /* Get Message-ID number.  Moved here to speed things up --REB */
     seq = getseq (MAILSEQ);

     if (!redirect)
       {
#ifndef _OSK
          if (!usedotilde)
            {
               if (nmlink (dotilde, 0, 0) == -1)
                    if (nmload (dotilde, 0, 0) == -1)
                         fatal ("compmail: can't load dotilde");
               usedotilde = TRUE;
            }
#endif
          cls();
       }

     /* From rickadams Tue Feb 12 10:57:02 1991 -0800
        Added 'daemon' --REB */

     sprintf (lp,  "From %s %s",
                   !fromdaemon ? user : "MAILER-DAEMON",  date822());

     if (!redirect)
          puts (lp);

     fprintf (ltrfile, "%s\n", lp);

     /* From: Rick Adams <rickadams@ccentral.UUCP>
        From: rickadams@ccentral.UUCP
        Added daemon -- REB */

     if (!fromdaemon)
          sprintf (lp, "%s%s%s%s%c%s%s",
                       Hfrom,
                       *name != '\0' ? name : "",
                       *name != '\0' ? " <" : "",
                       sepsym != '!' ? user : sitename,
                       sepsym,
                       sepsym != '!' ? sitename : user,
                       *name != '\0' ? ">" : "");
     else
          sprintf (lp, "%sMail Delivery Subsystem <MAILER-DAEMON@%s>",
                       Hfrom, sitename);

     if (!redirect)
          puts (lp);

     fprintf (ltrfile, "%s\n", lp);

     /* Message-Id: line */
     getime (&date);
     sprintf (lp, "Message-Id: <%02d%02d%02d%02d%02d.AA%05ld@%s>",
                  date.t_year, date.t_month, date.t_day, date.t_hour,
                  date.t_minute, seq, sitename);

     fprintf (ltrfile, "%s\n", lp);

     if (!redirect)
          puts (lp);


     /* Subject: line */
     if (forward)
       {
          if (extract_orig_header (ltrfile) == ABORT)
            {
               fclose (ltrfile);
               return (ABORT);
            }
       }
     else
       {
          if (*subject == '\0')
            {
               fputs (Hsubject, stdout);

               if (!redirect)
                 {
                    if (mfgets (subject, sizeof (subject), stdin) == NULL)
                      {
                         errno = 0;
                         fatal (got_escape);
                      }
                 }
               else
                 {
                    fflush (stdout);
                    count = readln (2, subject, sizeof (subject) - 1);

                    if (count < 1)
                         count = 1;

                    subject[count - 1] = '\0';
                 }
            }
          else
            {
               if (!redirect)
                    printf ("%s%s\n", Hsubject, subject);
            }

          fprintf (ltrfile, "%s%s\n",
                           Hsubject,
                           *subject != '\0' ? subject : "<No subject given>");
       }

     /* Reply-To: bob@kc2wz.bubble.org
        If mail comes from daemon Reply-To is set to 'postmaster'. */

     if (!fromdaemon)
          sprintf (lp, "%s%s%s%s%c%s%s",
                       Hreplyto,
                       *name != '\0' ? name : "",
                       *name != '\0' ? " <" : "",
                       sepsym != '!' ? user : sitename,
                       sepsym,
                       sepsym != '!' ? sitename : user,
                       *name != '\0' ? ">" : "");
     else
          sprintf (lp, "%spostmaster%c%s", Hreplyto, sepsym, sitename);

     if (!redirect)
          puts (lp);

     fprintf (ltrfile, "%s\n", lp);

     /* To: addressee line(s).  If message is from redirected file, don't
        bother with showing the addresses. */

     if (!redirect)
          fputs (Hto, stdout);

     fputs (Hto, ltrfile);
     strcpy (temp, address);
     count = 4;
     wordptr = words;
     wordlast = words + getargs (words, temp, WORDSIZE);

     while (wordptr < wordlast)
       {
          int wordlen = strlen (*wordptr);

          if (count + wordlen >= 78  &&  wordlen < 76)
            {
               strcpy (lp, "\n    ");
               fputs (lp, ltrfile);

               if (!redirect)
                    fputs (lp, stdout);

               count = 4;
            }
          fprintf (ltrfile, "%s", *wordptr);

          if (!redirect)
               fputs (*wordptr, stdout);

          count += wordlen;

          if (++wordptr < wordlast)
            {
               strcpy (lp, ", ");
               fputs (lp, ltrfile);

               if (!redirect)
                    fputs (lp, stdout);

               count += 2;
            }
       }

     if (!redirect)
          putchar ('\n');

     putc ('\n', ltrfile);

     /* Sender: line *

     /* Date: Tue, 12 Feb 91 10:57:45 -0800 */
     sprintf (lp, "%s%s", Hdate, date822());

     if (!redirect)
          puts (lp);

     fprintf (ltrfile, "%s\n", lp);

     /* Cc: line     Added forward and daemon --REB */
     if (cc_prompt && !fromdaemon && !forward)
       {
          fputs (Hcc, stdout);

          if (!redirect)
            {
               if (mfgets (lp, sizeof (line), stdin) == NULL)
                 {
                    errno = 0;
                    fatal (got_escape);
                 }
            }
          else
            {
               fflush (stdout);
               count = readln (2, lp, 132);

               if (count < 1)
                    count = 1;

               line[count - 1] = '\0';
            }
          p = skipspace (line);

          if (*p)
            {
               int n;

               /* Add new addresses to addressee list.  First save where the
                  new ones will go. */

               n = getargs (words, p, WORDSIZE);
               p = strend (address);
               parse_addr (n, words);

               /* write Cc: line using parsed addresses */
               fputs (Hcc, ltrfile);
               strcpy (temp, p);
               count = 4;
               wordptr = words;
               wordlast = words + getargs (words, temp, WORDSIZE);

               while (wordptr < wordlast)
                 {
                    int wordlen = strlen (*wordptr);

                    if (count + wordlen >= 78  &&  wordlen < 76)
                      {
                         fputs ("\n    ", ltrfile);
                         count = 4;
                      }
                    fputs (*wordptr, ltrfile);
                    count += wordlen;

                    if (++wordptr < wordlast)
                      {
                         fputs (", ", ltrfile);
                         count += 2;
                      }
                 }
               putc ('\n', ltrfile);
            }
       }

     /* In-Reply-To: Fromname's/address's message of date line */
     if (reply && *frommsgid != '\0')
       {
          sprintf (lp, "In-Reply-To: %s's message of %s", fromname, fromdate);

          if (!redirect)
               puts (lp);

          fprintf (ltrfile, "%s\n", lp);
          sprintf (lp, "             id <%s>", frommsgid);

          if (!redirect)
               puts (lp);

          fprintf (ltrfile, "%s\n", lp);
       }

     /* X-Mailer: line */
#ifdef OS9
     sprintf (lp, "X-Mailer: Mailx (OS-9/6809 UUCP v%s %s)",
#else
# ifndef _OS9K
     sprintf (lp, "X-Mailer: Mailx (OS-9/68K UUCP v%s %s)",
# else
     sprintf (lp, "X-Mailer: Mailx (OS-9000 UUCP v%s %s)",
# endif
#endif
                   version, VERDATE);

     fprintf (ltrfile, "%s\n", lp);

     if (!redirect)
          puts (lp);

     /* blank line after header */
     putc ('\n', ltrfile);

     if (!redirect)
          putchar ('\n');

     /* forwarding? */
     if (forward)
       {
          int tilde;
          char *dash = "----------";

          sprintf (temp, "%s Forwarded message begins here %s\n", dash, dash);

          if (!redirect)
               fputs (temp, stdout);

          fputs (temp, ltrfile);
          fclose (ltrfile);
          sprintf (temp, "dotilde \"~r %s\" %d %d %c %s %s %s",
                         message, t2flag, myuid, quotechar, tempfile, homedir,
                         message);

          tilde = docmd_na (temp);

          if (tilde == SIGINT  ||  tilde == SIGQUIT)
               myinterrupt (0);
          else if (tilde == ABORT)
               return (ABORT);

          if ((ltrfile = fopen (tempfile, "a")) == NULL)
            {
               printf ("\n%s: can't forward letter", pname);
               return (ABORT);
            }

          fprintf (ltrfile, "%s End forwarded message %s\n", dash, dash);
       }

     /* Compose body of text.  Clear line buffer first. */
     memset (line, '\0', sizeof (line));
     while (mfgets (line, sizeof (line), stdin) != NULL)
       {
          int tilde;

          if (*line == '.'  &&  *(line+1) == '\0')
               break;

          /* tilde command? */
          if (*line == '~')
            {
               fclose (ltrfile);
               sprintf (temp, "dotilde \"%s\" %d %d %c %s %s %s",
                              line, t2flag, myuid, quotechar, tempfile,
                              homedir, message);

               tilde = docmd_na (temp);

               if (tilde == SIGINT  ||  tilde == SIGQUIT)
                    myinterrupt (0);
               else if (tilde == ABORT)
                    return (ABORT);

               asetuid (0);

               if ((ltrfile = fopen (tempfile, "a")) == NULL)
                 {
                    fputs ("compmail: can't reopen letter file", stderr);
                    asetuid (myuid);
                    return (ABORT);
                 }
               asetuid (myuid);
            }
          else
               fprintf (ltrfile, "%s\n", lp);
       }

     /* append signature? */
     if (usesig  &&  !fromdaemon)
       {
          register FILE *sigfile;

#ifdef _OSK
          sprintf (fname, "%s/%s", homedir,
                          usesig == USESIG ? ".signature" : ".alt_signature");
#else
          sprintf (fname, "%s/%s/%s", homedir, uudir,
                          usesig == USESIG ? "signature" : "alt_signature");
#endif
          /* Added fix so that it goes up one line ONLY if '.' was used.
             Using ESC interrupted the last line of the text on the screen
             --BGP */

          if (!redirect  &&  *line == '.')
            {
               CurUp();
               fputs (" \b", stdout);
            }
          fflush (stdout);

          if ((sigfile = fopen (fname, "r")) != NULL)
            {
               fputs ("-- \n", ltrfile);

               if (!redirect)
                    puts ("--");

               while (mfgets (lp, sizeof (line), sigfile) != NULL)
                 {
                    fprintf (ltrfile, "%s\n", lp);

                    if (!redirect)
                         puts (lp);
                 }
               fclose (sigfile);
            }
       }
     fclose (ltrfile);
     return (OK);
}



/* Get original header info for forwarded mail. */

int extract_orig_header (ltr)
FILE *ltr;
{
     register char *lp;
     FILE *origmsg;

     if ((origmsg = fopen (message, "r")) == NULL)
          return (ABORT);

     /* Get original To: field.  Tack 'X-' to the beginning of it.  Ignore
        the other fields. */

     lp = line;
     while (mfgets (lp, sizeof (line), origmsg) != NULL   &&  *lp != '\0')
       {
          if (*lp == '>'  &&  strnucmp (lp, ">From ", 6) == 0)
               continue;
          if (strnucmp (Hsubject, lp, 9) == 0
               || strnucmp (Hsubj, lp ,6) == 0)
            {
               sprintf (temp, "%s (forwarded)\n", lp);
               fputs (temp, stdout);
               fputs (temp, ltr);
            }
          else if (strnucmp (lp, Hsender, 8) == 0)
               fprintf (ltr, "%s%s\n", Hx, lp);
          else if (strnucmp (lp, Hto, 3) == 0)
               fprintf (ltr, "%s%s\n", Hx, lp);
       }
     fclose (origmsg);
     return (OK);
}
