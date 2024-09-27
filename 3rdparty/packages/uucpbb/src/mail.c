/*  mail.c   This is the main mail program, Mailx, for the UUCPbb package.
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


/* mailx [-r]                                       ...read mail
        opt:    r              -read mail in reverse order

   mailx [opts] [<address>...] [opts]               ...send mail
        opts: a <file>         -file replying to
              s "subject"      -Subject: "subject"
              x N              -N = debug level
              d                -don't add signature
              n                -use alt_signature
              c [<user>...]    -check for our waiting mail and that
                                  of 'user' (superuser only)
              p                -don't prompt for carbon copy (Cc:)
              v                -toggle using pager, default [ON|OFF]
              ?                -this message

   When used with Shell+, non-superusers need to use '*' instead of '@' in
   command line addresses.  */

#define MAIN

#include "uucp.h"
#include "mail.h"
#include <signal.h>
#include <modes.h>
#include <ctype.h>
#include <sgstat.h>
#ifndef _OSK
#include <os9.h>
#include "dir_6809.h"
#else
#include <dir.h>
#endif

#define ARGVAL()    (*++(*names) || (--count && *++names))

extern QQ int childid;                               /* defined in docmd.c */

QQ flag readmail = FORWARD;

/* Declarations */
long _gs_pos(), _gs_size();
void usage();
int myinterrupt();


int main(argc, argv)
int argc;
char **argv;
{
     char *ptmp;
#ifndef TERMCAP
     winopen = FALSE;
#endif

     /* initialize defaults */
     ltrfile = NULL;
     homedir = NULL;
     *subject = '\0';
     *address = '\0';
     *tempfile = '\0';
     reply = FALSE,                                  /* not replying */
     debug = 0,                                      /* debug is off */
     usesig = USESIG,                                /* use signature file  */
     forward = FALSE,                                /* not forwarding mail */
     childid = -1;                                   /* no children yet */
     pname = *argv;
     usedotilde = FALSE;
     rmailin = FALSE;
     quiet = FALSE;

#ifndef _OSK
     pflinit();                                      /* longs will be print */
#endif
     intercept (myinterrupt);                          /* signal handler */

     if (getparam() == FALSE)
          exit (0);

     userparam();

     /* Look for the environment MAIL.  If that doesn't exist, look for the
        parameter 'maildir' in the Parameters file. */

     if ((maildir = getenv ("MAIL")) != NULL)
          maildir = strdup (maildir);
     else
          if ((maildir = getdirs ("maildir")) == NULL)
               fatal ("MAIL undefined");

     if ((logdir = getenv ("LOGDIR")) != NULL)
          logdir = strdup (logdir);
     else
          logdir = LOGDIR;

     if (parse_addr (--argc, ++argv) == ABORT)
          exit (0);

#ifndef TERMCAP
     t2flag = t2test();
#else
     init_term_cap();
#endif

     if (readmail == SEND)
       {
          /* Is stdin redirected from a file?  Try to position to
             beginning of file.  If it works, must be file. */

          redirect = (_gs_pos (0) == -1) ? FALSE : TRUE;
          asetuid (0);

#ifndef _OSK
          /* Load dotilde and rmail.  This should speed things up a bit */
          if (nmlink (dotilde, 0, 0) == -1)
               if (nmload (dotilde, 0, 0) == -1)
                    fatal ("can't load dotilde");

          if (nmlink (rmail, 0, 0) == -1)
               if (nmload (rmail, 0, 0) == -1)
                 {
                    munload (dotilde, 0);
                    fatal ("can't load rmail");
                 }
          usedotilde = TRUE;
#else
          /* for OSK just load rmail */
          if (modlink (rmail, 0) == -1)
            {
               char tmp[64];

               if (modloadp (rmail, 0, tmp) == -1)
                    fatal ("can't load rmail");
            }
#endif
          rmailin = TRUE;
          asetuid (myuid);
          sendmail();
          munload (rmail, 0);
          rmailin = FALSE;
       }
     else
       {
          /* read our mail */
#ifndef _OSK
          if (usepager  &&  *pager != '\0')
               loadpager (TRUE);
#endif
          recvmail (readmail == FORWARD ? TRUE : FALSE);
       }

#ifndef _OSK
     if (usedotilde)
          munload (dotilde, 0);
#endif
     putchar ('\n');
     exit (0);
}




/* Parse the command line.  Returns TRUE if sending mail.  Returns FALSE
   otherwise. */

int parse_addr (count, names)
int count;
register char **names;
{
     FILE *file;

     for (; count; count--, names++)
       {
          if (**names == '-')
            {
               while (*++(*names))
                 {
                    switch (**names)
                      {
                         /* Subject */
                         case 's':
                              if (!ARGVAL() )
                                   return (argerr ("s"));

                              strcpy (subject, *names);
                              readmail = SEND;
                              goto nextarg;

                         /* debug */
                         case 'x':
                              if (!ARGVAL() || !isdigit (**names))
                                   return (argerr ("x"));

                              debug = atoi (*names);

                              if (debug > 9)
                                   debug = 9;

                              goto nextarg;

                         /* File replying to */
                         case 'a':
                              if ( !ARGVAL() )
                                   return (argerr ("a"));

                              strcpy (message, *names);
                              readmail = SEND;
                              goto nextarg;

                         /* Check for waiting mail for ourself and possibly
                            another user.  Only superuser can check mail of
                            other users. */

                         case 'c':
                              /* check for our own mail... */
                              checkmail (TRUE, user);

                              /* ...and that of other users */
                              if (myuid == 0)
                                   if ( ARGVAL() )
                                     {
                                        printf ("\n%s: ", *names);
                                        checkmail (TRUE, *names);

                                        while (--count && *++names)
                                          {
                                             printf ("%s: ", *names);
                                             checkmail (TRUE, *names);
                                          }
                                     }
                              exit (0);

                         /* don't use signature */
                         case 'd':
                              usesig = NOSIG;
                              readmail = SEND;
                              break;

                         /* use alt_signature */
                         case 'n':
                              usesig = ALTSIG;
                              readmail = SEND;
                              break;

                         /* don't prompt for Cc:, overrides mailrc
                            parameter */
                         case 'p':
                              cc_prompt = FALSE;
                              readmail = SEND;
                              break;

                         /* read last in, first out order */
                         case 'r':
                              readmail = REVERSE;
                              break;

                         /* just want help */
                         case '?':
                              usage();
                              return (ABORT);
                              break;

                         default:
                              fprintf (stderr, "%s: bad option: %c ...for help use: %s -?\n", 
                                               pname, **names, pname);
                              return (ABORT);
                              break;

                    } /* end switch */
                 } /* end while processing this argument */
            } /* end if option parameter */

          /* must be mailing list or address */
          else
            {
               readmail = SEND;

               if (**names == '@'  ||  **names == '*')
                 {
                    char list[128];

                    /* read names from mailing list */
                    ++(*names);
#ifdef _OSK
                    sprintf (fname, "%s/%s", homedir, *names);
#else
                    sprintf (fname, "%s/%s/%s", homedir, uudir, *names);
#endif
                    if ((file = fopen (fname, "r")) == NULL)
                      {
                         char tmp[80];

                         sprintf (tmp, "can't open mailing list: %s", *names);
                         fatal (tmp);
                      }

                    while (mfgets (list, sizeof (list), file) != NULL)
                      {
                         doalias (list);
                         strcat (strcat (address, " "), list);
                      }
                    fclose (file);
                 }

               /* address or alias */
               else
                 {
                    strcpy (temp, *names);
#ifndef _OSK
                    fixstar (temp);
#endif
                    doalias (temp);
                    strcat (strcat (address, " "), temp);
                 }
            }
nextarg:  continue;                              /* process next argument */
       }
     return (OK);
}



#ifndef _OSK
/* Shell+ strips out command line '@' when used by anyone but the superuser
   This fixes it so non-superuser can use the form:  user*node or '*list'
   instead of 'user@node' or '@list'.  I know it is a kludge... :-) --REB */

int fixstar (adrs)
char *adrs;
{
     register char *p;

     for (p = adrs; *p; ++p)
          if (*p == '*')
               *p = '@';
}
#endif



int argerr (arg)
char *arg;
{
     _errmsg (0, "option requires an argument -- %s\n", arg);
     return (ABORT);
}




/* Open user's mailbox to check for waiting mail.  If mail is waiting, the
   number of messages is returned.  If no mail is waiting, a message to this
   effect is displayed.  If 'checkflag' is TRUE, the -c option was on the
   command line.  Just count the messages waiting and report it.  If
   'checkflag' is FALSE, count the message in the mailbox.  Compare it with
   the count given in the mail..list file.  If the two counts disagree
   reconstruct mail..list first.  Then return the number of messages waiting
   to the caller.
*/

int checkmail (checkflag, whosemail)
flag checkflag;
char *whosemail;
{
     DIR *dirptr;
     struct direct *list;                            /* defined in dir.h */
     register int count_1;
     int count_2;
     FILE *fp;

     /* become super user and change current data directory to user's mailbox
        directory */

     sprintf (fname, "%s/%s", maildir, whosemail);
     asetuid (0);

     if (chdir (fname) == ERROR)
       {
          char tmp[75];

          sprintf (tmp, "can't change to your mailbox directory: '%s'",
                        whosemail);
          fatal (tmp);
       }
     asetuid (myuid);

     if ((dirptr = opendir (".")) == NULL)   
          fatal ("checkmail: can't open your mailbox");

     /* now count our letters */
     count_1 = 0;
     while ((list = readdir (dirptr)) != NULL) 
          if ((list->d_name[0] != '.') 
               &&  (strncmp (list->d_name, mail_list, 6) != 0))
            {
               ++count_1;
            }
     closedir (dirptr);

     /* report our findings... */
     if (count_1 == 0)
       {
          Bell();
          puts ("no mail waiting");
          return (count_1);
       }

     if (checkflag) 
       {
          if (count_1 > 0)
               printf ("You have mail (%d message%s)\n",
                        count_1, count_1 > 1 ? "s" : "");
       }
     else
       {
          /* Compare count_1 with mail..list file.  If the two disagree or
             mail..list file does not exist, it probably got munged.  We need
             to rebuild mail..list before returning. */

          if ((fp = fopen (mail_list, "r")) != NULL)
            {
               char buff[MLINE];

               count_2 = 0;

               while (mfgets (buff, MLINE, fp) != NULL)
                    ++count_2;

               fclose (fp);
            }

          if (fp == NULL  ||  count_1 != count_2)
            {
               fputs ("\nERROR--rebuilding 'mail..list' file...", stderr);
               count_1 = rebuildmail (count_1);
            }
       }
     return (count_1);
}



/* mail..list file got munged somehow.  Reconstruct it. */

int rebuildmail (mailcount)
int mailcount;
{
     FILE *mptr, *lptr, *omptr;
     DIR *dirptr;
     struct direct *mbox;                           /* defined in dir.h */
     register int i;
     int newmailcount = 0;
     static struct mbag  {
                char letter[32];
              } *ltrs, *ltrsp, *eltrs;

     omptr = NULL;
     ltrs = (struct mbag *) malloc (mailcount * sizeof (struct mbag));

     if (ltrs == NULL)
          fatal ("rebuildmail: can't malloc() ltrs array");

     dirptr = opendir (".");

     if (dirptr == NULL)
          fatal ("rebuildmail: not enough memory...too much mail in mailbox directory");

     /* read in the letter filenames */
     i = 0;
     while ((mbox = readdir (dirptr)) != NULL)
          if ((mbox->d_name[0] != '.')
               && (strncmp (mbox->d_name, mail_list, 6) != 0))
            {
               strcpy ((ltrs + i)->letter, mbox->d_name);
               ++i;
            }
     closedir (dirptr);
     qsort (ltrs, mailcount, sizeof (struct mbag), strucmp);
     sprintf (fname, "%s.tmp", mail_list);

     if ((mptr = fopen (fname, "w")) == NULL)
       {
          fputs ("rebuildmail: can't create 'mail..list.tmp'", stderr);

          if (errno == 253)
               fputs ("...same user updating file", stderr);

          putc ('\n', stderr);
          exit (0);
       }

     /* make sure nobody else can mess with us for now */
     _ss_attr (fileno (mptr), S_ISHARE|S_IREAD|S_IWRITE);
     asetuid (myuid);

     /* extract header info */
     ltrsp = ltrs;
     eltrs = ltrs + mailcount;

     /* open original mail..list for comparison */
     omptr = fopen (mail_list, "r");

     do
       {
          if ((lptr = fopen (ltrsp->letter, "r")) == NULL)
            {
               fprintf (stderr, "rebuildmail: can't open '%s'\n",
                                ltrsp->letter);
               continue;
            }

          /* If the letter file is 0 bytes, something got trashed.  Delete
             the file and continue on. */

          if (_gs_size (fileno (lptr)) <= 0)
            {
               fclose (lptr);
               unlink (ltrsp->letter);
            }
          else
            {
               getheader (lptr, mptr, ltrsp->letter, omptr);
               fclose (lptr);
               ++newmailcount;
            }
       }
     while (++ltrsp < eltrs);

     if (omptr != NULL)
          fclose (omptr);

     free (ltrs);
     fixupdate ("rebuildmail", mptr);
     return (newmailcount);
}



/* Extract header information for the mail..list entry. */


int getheader (fp, mptr, filename, omptr)
FILE *fp, *mptr, *omptr;
char *filename;
{
     char mline[256], subj[SUBJSIZE], from[FRMSIZE], resentfrm[128];
     char resentrply[128];
     register char *p;
     int linecount;

     *subj = *from = *resentfrm = *resentrply = '\0';
     p = mline;

     while (mfgets (p, sizeof (mline), fp) != NULL  &&  *p)
          if (*p == 'F'  &&   strnucmp ("From: ", p, 6) == 0)
            {
               strncpy (from, grabfrom (p), FRMSIZE);
               from[FRMSIZE-1] = '\0';
            }
          else if (*p == 'R')
            {
               if (strnucmp (p, "Resent-From: ", 13) == 0)
                 {
                    strncpy (resentfrm, grabfrom (p), sizeof (resentfrm));
                    resentfrm[sizeof (resentfrm) - 1] = '\0';
                 }
               else
                    if (strnucmp (p, "Resent-Reply-To: ", 17) == 0)
                      {
                         strncpy (resentrply, grabfrom (p), sizeof (resentrply));
                         resentrply[sizeof (resentrply) - 1] = '\0';
                      }
            }
          else if (*p == 'S'  && (strncmp ("Subject: ", p, 9) == 0)
                              || (strncmp ("Subj: ", p, 6) == 0))
            {
               strncpy (subj, getstring (p), SUBJSIZE);
               subj[SUBJSIZE - 1] = '\0';
            }

     if (*resentrply != '\0')
          strncpy (from, resentrply, sizeof (from));
     else
          if (*resentfrm != '\0')
               strncpy (from, resentfrm, sizeof (from));

     /* be sure from is properly terminated */
     from[sizeof (from) - 1] = '\0';

     /* count the lines */
     linecount = 0;
     p = mline;
     while (mfgets (p, sizeof (mline), fp) != NULL)
          ++linecount;

     sprintf (temp, "N%s|%s|%s|%d|%ld",
                    filename, *from != '\0' ? from : " ",
                    *subj != '\0' ? subj : " ",
                    linecount, _gs_size (fileno (fp)));

     /* see if this line matches the original mail..list line */
     if (omptr != NULL)
       {
          /* if the lines match use the old status */
          while (mfgets (p, sizeof (mline), omptr) != NULL)
               if (strcmp ((temp + 1), (p + 1)) == 0)
                 {
                    *temp = *p;
                    break;
                 }
          rewind (omptr);
       }
     fprintf (mptr, "%s\n", temp);
}



/* Extract the user name from the From: line.  Returns a pointer to the char
   string containing the name. */

char *grabfrom (fromline)
char *fromline;
{
     char *realname;

     realname = getrealname (fromline);

     if (*realname == '\0')
          realname = getval (fromline);

     return (realname);
}



/* Update the user's mail..list file.  Kill deleted mail as we go. */

void updatemail_list (envelop, numltrs)
MAILPTR envelop;
int numltrs;
{
     char buff[MLINE];
     FILE *mptr, *mtptr;
     register char *p;

     p = buff;

     /* original mail..list */
     if ((mptr = fopen (mail_list, "r")) == NULL)
          fatal ("updatemail: can't read your 'mail..list'");

     sprintf (fname, "%s.tmp", mail_list);

     if ((mtptr = fopen (fname, "w")) == NULL)
       {
          fputs ("updatemail_list: can't create 'mail..list.tmp'", stderr);

          if (errno == 253)
               fputs ("...same user updating file", stderr);

          putc ('\n', stderr);

          /* quit */
          myinterrupt (0);
       }

     /* make sure nobody else can mess with us for now */
     _ss_attr (fileno (mtptr), S_ISHARE|S_IREAD|S_IWRITE);

     /* write out new mail..list, skip deleted mail */
     while (mfgets (p, MLINE, mptr) != NULL)
       {
          /* just in case new mail arrived */
          if (envelop != ENDMAIL)
            {
               switch (envelop->status)
                 {
                    case 'D':
                    case 'B':
                         unlink (envelop->letter);
                         free (envelop->mline);
                         envelop = envelop->next;
//                         continue;

                    case 'N':
                         *p = 'U';
                         free (envelop->mline);
                         break;

                    case 'P':
                         *p = ' ';
                         free (envelop->mline);
                         break;

                    default:
                         *p = envelop->status;
                         free (envelop->mline);
                         break;
                 }
               envelop = envelop->next;
            }
          fprintf (mtptr, "%s\n", p);
       }
     fclose (mptr);

     if (envelop != ENDMAIL  &&  numltrs)
       {
          fclose (mtptr);
          rebuildmail (numltrs);
          return;
       }
     fclose (mptr);
     fixupdate ("updatemail_list", mtptr);
}



int fixupdate (func, fp)
char *func;
FILE *fp;
{
     char buff[65];

     /* for our eyes only */
     fixperms (fp);
     fclose (fp);

     /* make sure the same owner owns new mail..list file */
     sprintf (fname, "%s.tmp", mail_list);
     chown (fname, myuid);

     /* remove the old mail..list file */
     unlink (mail_list);
     asetuid (0);

     if (docmd_na ("rename mail..list.tmp mail..list") != 0)
       {
          if (strcmp (func, "rebuildmail") == 0)
               strcpy (buff, "rebuildmail");
          else
               strcpy (buff, "updatemail_list");

          strcat (buff, "fixupdate: can't rename 'mail..list.tmp' to 'mail..list'");
          fatal (buff);
       }

     asetuid (myuid);
}



/* Get a string skipping over leading spaces.  Returns pointer to first
   non-space character.  skipspace() is in parse.c. */

char *getinput (p, size)
register char *p;
int size;
{
     if (mfgets (p, size, stdin) != NULL)
          return (skipspace (p));
     else
          return (NULL);
}



/* Turn off or on echo on the standard input path */

int echo (onoroff)
int onoroff;
{
     struct sgbuf stdinpath;

     _gs_opt (1, &stdinpath);
     stdinpath.sg_echo = onoroff;             /* switch standard input echo */
     _ss_opt (1, &stdinpath);                 /* update the path descriptor */
}



#ifndef _OSK
/* load or unload the file viewer */

int loadpager (loadit)
int loadit;
{
     if (loadit)
       {
          if (nmlink (pager, 0, 0) == -1)
               if (nmload (pager, 0, 0) == -1)
                 {
                    usepager = FALSE;
                    return;
                 }
          usepager = TRUE;
       }
     else
       {
          munload (pager, 0);
          usepager = FALSE;
       }
}
#endif



/* print a message and exit */

int fatal (msg)
char *msg;
{
     fprintf (stderr, "\n%s: %s", pname, msg);

     if (errno != 0)
          fprintf (stderr, "...error %d", errno);

     putc ('\n', stderr);
     myinterrupt (0);
}



/* Cleanup if we get a keyboard interrupt and get out. */

int myinterrupt (sig)
int sig;
{
#ifndef TERMCAP
     if (winopen)
       {
          closedoublewindow();
          return;
       }
#endif

     asetuid (0);

     /* kill off any children */
     if (childid > -1)
       {
          kill (childid, SIGKILL);
          childid = -1;
       }

     /* unlink RMAIL if we loaded it */
     if (rmailin)
          munload (rmail, 0);

#ifndef _OSK
     /* unlink pager and dotilde if we loaded them */
     if (usepager)
          loadpager (FALSE);

     if (usedotilde)
          munload (dotilde);
#endif
     /* clean up --REB */
     if (ltrfile != NULL)
          fclose (ltrfile);

     if (*tempfile != '\0')
          unlink (tempfile);

     /* put things back the way we found them */
     echo (ON);
     CurOn();
     putchar ('\n');
     exit (sig);
}



void usage()
{
     char *strdetab();
     register char **ptr;
     static char *usetxt[] = {
         "mail [-r]\t\t\t\t\t...read mail",
         "     opt:  r\t\t   -read mail in reverse order",
         " ",
         "mail [opts] [<address>...] [opts]\t\t...send mail",
         "     opts: a <file>\t    -file replying to",
         "\t   s \"subject\"\t -Subject: \"subject\"",
         "\t   x N\t\t -N = debug level",
#ifndef _OSK
         "\t   d\t\t   -don't add signature",
         "\t   n\t\t   -use alt_signature",
#else
         "\t   d\t\t   -don't add .signature",
         "\t   n\t\t   -use .alt_signature",
#endif
         "\t   p\t\t   -don't prompt for carbon copy (Cc:)",
         "\t   q\t\t   -work quietly when sending mail",
         "\t   ?\t\t   -this message",
         NULL
       };
     static char *usetxt1 = "\t    v\t\t   -toggle file viewer...";
     static char *usetxt2 = "\t   c [<user>...]       -check for our waiting mail and that of user\n";
     static char *usetxt3 = "\t   c\t\t   -check for waiting mail";

     fprintf (stdout, "mailx v%s (%s)  --send and receive e-mail\n\n",
                      version, VERDATE);

     for (ptr = usetxt; *ptr != NULL; ++ptr)
          fprintf (stderr, " %s\n", strdetab (strcpy (temp, *ptr), 8));

     fprintf (stderr, "%sdefault %s\n",
               strdetab (strcpy (temp, usetxt1), 8), usepager ? "ON" : "OFF");

     strcpy (temp, (myuid == 0) ? usetxt2 : usetxt3);
     fprintf (stderr, " %s\n", strdetab (temp, 8));

#ifndef _OSK
     fputs ("  When used with Shell+, non-superusers need to use ", stderr);
     fputs ("'*' instead of '@' in\n  command line addresses.\n\n", stderr);
#endif
     fputs ("This is free software released under the GNU General Public License.  Please",
            stderr);
     fputs ("Please send suggestions/bug reports to:  bob@kc2wz.bubble.org\n",
            stderr);
}
