/*  rmail.c   This program routes mail to a local or remote user.
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
 /****************************************\
 * Usage: rmail [file] "site!user[@site]" *
 \****************************************/

#define MAIN

#include "uucp.h" 
#include <time.h>
#include <modes.h>
#include <direct.h>
#include <signal.h>
#include <ctype.h>
#ifndef _OSK
#include <os9.h>
#endif

#define DELIVERED    0
#define UNDELIVERED  1 
#define UNKWNUSER    2
#define UNKWNSITE    3
#define NOTBOUNCED   4
#define BOUNCED      5
#define FRMSIZE     19
#define SUBJSIZE    27
#define WORDSIZE    30

extern QQ unsigned myuid;
extern QQ unsigned validuid;                      /* defined in validuser.c */
extern QQ char *uucphost, *bithost, *inhost;
extern QQ char *nodename, *sitename, *errorsto;
extern char temp[], user[], fname[];

QQ char *errmsg = "ERROR--";
QQ flag logopen = FALSE;
QQ int debug = 0;
QQ char *filename;
QQ int fileowner;                                 /* owner of passed file */
QQ FILE *log;
QQ char *userdir;                                 /* used by dolocal() */
char mailstring[80];                              /*                   */

/*
QQ unsigned errorsID;
*/
static char address[512], line[512], line2[512];
void openlog(), closelog(), logerror();
long _gs_size();


int main(argc, argv)
int argc;
char *argv[];
{
     register FILE *file;
     flag delivered;
     int myinterrupt();

     userdir = NULL;
     homedir = NULL;
     log = NULL;

#ifdef _OSK
     pflinit();                              /* longs will be printed */
#endif
     intercept (myinterrupt);

     switch (argc)
       {
          case 2:
               if (argv[1][0] == '-'  &&  argv[1][1] == '?')
                    usage();

               strcpy (address, argv[1]);
               file = stdin;
               *filename = '\0';
               break;

          case 3:
               strcpy (address, argv[2]);
               filename = argv[1];

               if ((file = fopen (filename, "r")) == NULL)
                 {
                    sprintf (temp, "can't open input file %s", filename);
                    logerror (temp);
                    exit (UNDELIVERED);
                 }
               break;

          default:
               usage();
       }

     if ((logdir = getenv ("LOGDIR")) != NULL)
          logdir = strdup (logdir);
     else 
          logdir = LOGDIR;

     openlog();

     /* find out who owns the file we were passed */
     fileowner = who_owns_the (file);
     asetuid (fileowner);

     if (getparam() == FALSE)
          errorexit (UNDELIVERED);

     getuser (user);
     getuserdir();

     /* make sure we are superuser */
     asetuid (0);

     /* is this a local delivery by uucp? */
     if ((strnucmp (argv[1], "D.", 2) == 0)
          && (strchr (address, '!') == NULL)
          && (strchr (address, '@') == NULL))
       {
          strcpy (user, "uucp");
       }
     else if (*user == '\0')
       {
          sprintf (temp, "user '%s' not in password file", user);
          logerror (temp);
          bouncemail (file, UNKWNUSER);
       }

     /* Validate address, adding missing net information if address is
        unparsable or to a nonexistent user, BOUNCE! */

     if (validaddr() == FALSE)
          bouncemail (file, UNKWNSITE);

     /* local or remote delivery? */
     if ((strchr (address, '!') != NULL) || (strchr (address, '@') != NULL))
       {
          free (userdir);
          delivered = doremote (file);
       }
     else
          delivered = dolocal (file);

     /* if we can't deliver the mail, return it to the sender */
     if (delivered == UNDELIVERED)
          bouncemail (file, UNKWNSITE);
     else
          fclose (file);

     closelog();
     exit (delivered);
}



int who_owns_the (file)
FILE *file;
{
     struct fildes buffer;

     _gs_gfd (file->_fd, &buffer, sizeof (buffer));
#ifndef _OSK
     return ((int) buffer.fd_own);
#else
     return (atoi (buffer.fd_own));
#endif
}



int getuserdir()
{
     register char *p;

     if (strrchr (homedir, '/') == NULL)
       {
          closelog();
          exit (UNDELIVERED);
       }

     /* determine if there are two '/'s in the path */
     if ((p = strchr (homedir, '/')) != NULL  &&  strchr (p+1, '/') != NULL)
       {
          p = strrchr (homedir, '/');
          *p = '\0';
       }
     userdir = strdup (homedir);

     if (userdir == NULL)
       {
          closelog();
          exit (UNDELIVERED);
       }
     *p = '/';
}



/* validate the address */

int validaddr()
{
     char *p;
     flag bang;
     FILE *fp;
     register char *b = strchr (address, '!');   /* Bang */
     char *a = strrchr (address, '@');           /* At   */
     char *c = strchr (address, '%');    /* user%mynode.uucp@somewhere.else */

     /* local mail hiding as remote mail or mail passing through */

     if (b)
       {
          bang = TRUE;
          *b = '\0';
       }
     else
          bang = FALSE;

     /* Handle user%ournode.uucp@someplace.else or user%ournode@someplace.
        This just rewrites those as user.  This may be somewhat a hack, but it
        is useful for those who don't have a proper domain name.  I suspect
        that this rewrite might not actually be needed, as the receiving uucp
        site should relay the message back.  --BAS  */

     if (c)
       {
          int nodelen = strlen (nodename);

          if (strnucmp (c+1, nodename, nodelen) == 0)
               if (( *(c+1+nodelen) == '@') ||
                   (strnucmp (c+1+nodelen,".uucp@",6) == 0))
                 {
                    *c = '\0';
                    return (TRUE);
                 }
       }

     /* user@ournode.domain  or  ournode!user */
     if ((a  &&  (strucmp ((a+1), nodename) == 0
                  || strucmp ((a+1), sitename) == 0)) 
          || (bang && (strucmp (address, nodename) == 0
                  || strucmp (address, sitename) == 0)))
       {
          /* put ! back if it was there before */
          if (bang)
               *b = '!';

          *a = '\0';

          /* remove any leading !s, we know it goes here */
          if ((p = strrchr (address, '!')) != NULL)
               strcpy (address, (p+1));

          if (fixpercent (address)  &&  a)
               *a = '\0';

          a = strrchr (address, '@');
          b = strchr (address, '!');
       }
     else
       {
          /* put ! back if it was there before */
          if (bang)
               *b = '!';
        }

     /* local mail */
     if (!b  &&  !a)
       {
          /* mail to "nobody" == bit bucket or for the file server? */
          if (strucmp (address, "nobody") == 0
              || strucmp (address, "fileserv") == 0
              || strucmp (address, "mail-server") == 0)
            {
               return (TRUE);
            }

          /* if local user has a forward file, forward the mail there */
#ifdef _OSK
          sprintf (fname, "%s/%s/%s", userdir, address, _FRWRD);
#else
          sprintf (fname, "%s/%s/%s/%s", userdir, address, uudir, _FRWRD);
#endif
          if ((fp = fopen (fname, "r")) != NULL)
               if (mfgets (address, sizeof (address), fp) != NULL)
                    return ( validaddr() );

          if (doalias (address))
               return ( validaddr() );

          return (validuser (address));
       }

     /* poorly formed address */
     else if (a  &&  b > a)
          return (FALSE);

     /* UUCP-style beginning
        address in form:  site!site2!user or domain2.domain1!site!user  */

     else if (b)
       {
          /* Get 1st node to send to */
          *b = '\0';
          strcpy (line, address);
          *b = '!';

          /* Strip off leading "nodename!" if addressed to our node.  Check
             to see if the address is aliased. */

          if ((strucmp (line, nodename) == 0)
               || (strucmp (line, sitename) == 0))
            {
               strcpy (address, strcpy (line, (b + 1)));
               doalias (address);
               return (validaddr());
            }

          /* domain address?  use leftmost domain as node */
          if ((p = strchr (line, '.')) != NULL)
               *p = '\0';

          /* do we talk directly to them? */
          if (findent (line, SYSTEMS, line2, sizeof (line2)) == TRUE)
               strcat (line, b);
          else
               /* no, we need to prepend the UUCP smarthost address */
               strcat (strcpy (line, uucphost), address);
       }

     /* internet address or bitnet address to be internet-ized.  Address
        arrives in the form:
            user@domain2.domain1, user%domain2.domain1@node, or user@node
        which becomes 'user@node.bitnet'. */

     else if (((p = strchr (a, '.')) != NULL)  ||  (*bithost == '\0'))
       {
          if (!p  &&  *bithost == '\0')
               strcat (address, ".bitnet");

          *a++ = '\0';
          strcpy (line, a);

          /* Strip off '@nodename' if addressed to our node.
             Check to see if address is aliased. */

          if ((strucmp (line, nodename) == 0)
                || (strucmp (line, sitename) == 0))
            {
               fixpercent (address);
               strcpy (address, strcpy (line, address));
               doalias (address);
               return (validaddr());
            }

          /* use leftmost domain as node */
          *p = '\0';
          strcpy (line, a);

          /* do we talk directly to them? */
          if (findent (line, SYSTEMS, line2, sizeof (line2)) == TRUE)
            {
               fixpercent (address);
               sprintf (line, "%s!%s", a, address);
            }
          else
            {
               /* need to prepend our internet host address */
               *p = '.';
               *--a = '@';
               strcat (strcpy (line, inhost), address);
            }
       }

     /* bitnet address */
     else
          strcat (strcpy (line, bithost), address);

     strcpy (address, line);
     return (TRUE);
}



/* Deal with internet '%'.  Changes rightmost '%' in 'string' to '@' if
   found and returns TRUE; otherwise returns FALSE. */

int fixpercent (string)
char *string;
{
     register char *p;

     if ((p = strrchr (string, '%')) != NULL)
       {
          *p = '@';
          return (TRUE);
       }
     return (FALSE);
}



/* dolocal  --local mail delivery

              Returns DELIVERED if delivery was successful.  UNDELIVERED if
              delivery failed. */

int dolocal (file)
FILE *file;
{
     char mailbox[256], envelop[16];
     struct sgtbuf tod;
     register FILE *mailfile;
     FILE *mail_list;
     char *ptmp;
     long linecount, msgsize, movemail();

     /* mail for user 'nobody', it goes in the bit bucket */
     if (strucmp (address, "nobody") == 0)
          return (DELIVERED);

     /* be sure we are super user */
     asetuid (0);

     /* If sent to user 'fileserv' fork the fileserver program. */
     if (strucmp (address, "fileserv") == 0)
          return (forkfileserv (file));

     /* If sent to user 'mail-server' fork a program named 'mailserver'.

        Currently, 'mailserver' does not exit.  This pseudo-user is provided
        for those who wish to write their own application software to
        interface with UUCP mail.  The only requirement is that the
        application read its standard input; for the entire message, header
        and all, will be piped to it.  It is up to the application to
        deal with the message.

        No error is returned if the mailserver program cannot be forked.  The
        message is silently discarded.

        The next version of RMail will allow for multiple psuedo-users
        applications.  Each need only read their standard input for the
        message. */

     if (strucmp (address, "mail-server") == 0)
          return (forkmailserver (file));

     /* get forwarding, if any */
#ifdef _OSK
     sprintf (fname, "%s/.%s", userdir, address);
#else
     sprintf (fname, "%s/%s/%s", userdir, uudir, address);
#endif

     if ((mailfile = fopen (fname, "r")) != NULL)
       {
          register char *p;

          if (mfgets (temp, 30, mailfile) == NULL)
            {
               sprintf (line2, "dolocal: empty forwarding file: %s", fname);
               logerror (line2);
               return (UNDELIVERED);
            }

          strcpy (address, temp);
          fclose (mailfile);

          /* If forwarded to a news gateway, post to local news group.
             Gatewaying to worldwide newsgroups would invite abuses (it's not
             in the proper format to be posted, anyway) */

          sprintf (temp, "%s.", nodename);

          if ((strncmp (address, temp, strlen (temp)) == 0)
               || (strncmp (address, "local.", 6) ==0))
            {
               return (gateway (file, filename, address));
            }
       }

     /* Look for the environment MAIL.  If that doesn't exist, look in the
        the Parameters file for the 'maildir' parameter. */

     if ((maildir = getenv ("MAIL")) != NULL)
          maildir = strdup (maildir);
     else if ((maildir = getdirs ("maildir")) == NULL)
          fatal ("MAIL undefined");

     /* change to user's mailbox directory */
     sprintf (mailbox, "%s/%s", maildir, address);

#ifdef DEBUG
     sprintf (line2, "dolocal: changing to mailbox: %s", mailbox);
     logerror (line2);
#endif

     if (chdir (mailbox) == ERROR)
       {
          sprintf (line2, "dolocal: can't change to mailbox: %s", mailbox);
          fatal (line2);
       }

     /* Create the envelope.  Account for new millenium in case this code is
        is still being used after 1999. :-) */

     getime (&tod);
     sprintf (envelop, "m%02d%02d%02d%02d%02d%02d%02d",
                       (tod.t_year >= 92) && (tod.t_year <= 99)  ? 19  : 20,
                       tod.t_year, tod.t_month, tod.t_day, tod.t_hour,
                       tod.t_minute, tod.t_second);

     /* new line for letterfile */
     memset (mailstring, '\0', sizeof (mailstring));
     sprintf (mailstring, "N%s|", envelop);

     /* set uid to that of recipient */
     asetuid (validuid);

     /* put the envelop in the mailbox */
     if ((mailfile = fopen (envelop, "w")) == NULL)
       {
          sprintf (line2, "dolocal: can't put letter in mailbox: %s",
                          address);
          fatal (line2);
       }

     /* open letter list for updating */
     if ((mail_list = fopen ("mail..list", "a")) == NULL)
       {
          sprintf (line2, "dolocal: can't update mail..list file with: %s",
                          envelop);
          fatal (line2);
       }

     fixperms (mailfile);

     /* move the mail message */
     linecount = movemail (file, mailfile, TRUE);

     /* If the file size is 0 or we can't get the size, something got trashed.
        Delete the letter file and report the letter as undeliverable. */

     if ((msgsize = _gs_size (fileno (mailfile))) <= 0)
       {
          fclose (mailfile);
          fclose (mail_list);
          unlink (envelop);
          exit (UNDELIVERED);
       }

     /* update the mail..list */
     fputs (mailstring, mail_list);

#ifndef _OSK
     fprintf (mail_list, "|%ld|%ld\n", linecount, msgsize);
#else
     fprintf (mail_list, "|%d|%d\n", (int) linecount, msgsize);
#endif
     fclose (mailfile);
     fclose (mail_list);
     return (DELIVERED);
}



/* doremote  --queue job for remote mail delivery  */

int doremote (file)
FILE *file;
{
     char cname[15], xname[14], dname[14], jname[14], seq[5];
     register FILE *qfile;
     char *p;
     long movemail();

     /* parse system and address...if a bad address, bounce it back */
     if ((p = strchr (address, '!')) == NULL)
          return (UNDELIVERED);

     *p++ = '\0';

     /* Now p points to recipient name, address points to system.  Go to
        proper spool directory.  If we can't change to the spool directory, we
        don't talk to this site so bounce the mail. */

     if ((spooldir = getdirs ("spooldir")) == NULL)
          fatal ("spooldir not in Parameters");

     sprintf (line, "%s/%s", spooldir, address);

#ifdef DEBUG
     sprintf (line2, "doremote: spooldir = %s\n", line);
     logerror (line2);
#endif

     asetuid (0);
     if (chdir (line) == ERROR)
       {
          sprintf (line2, "doremote: can't change to spool directory: %s",
                          address);
          fatal (line2);
       }

     /* get a unique ID for the work files */
     strcpy (seq, genseq());

     /* Figure out all the file names.  To be compatible with other UUCPs,
        system names are truncated to 7 characters. */

     /* D.sysnameXXXX filename (mail data file) */
     sprintf (dname, "D.%.7s%s", nodename, seq);

     /* D.sysnameXXXX file (job file) */
     sprintf (jname, "D.%.7s%s", address, seq);

     /* C.sysnameCXXXX (control file) */
     sprintf (cname, "C.%.7sC%s", address, seq);

     /* X.sysnameXXXX (execute file) */
     sprintf (xname, "X.%.7s%s", address, seq);

     /* write mail to mail data file */
     asetuid (0);
     if ((qfile = fopen (dname, "w")) == NULL)
          fatal ("doremote: can't create data (D.<ournode>) file");

     /* make file secure and change ownership to sender */
     fixperms (qfile);
     chown (dname, fileowner);

     /* move the mail message */
     movemail (file, qfile, FALSE);

     if (_gs_size (fileno (qfile)) <= 0)
       {
          fclose (qfile);
          unlink (qfile);
          fatal ("doremote: error writing data (D.) file");
       }

     fclose (qfile);

     /* write job file */
     if ((qfile = fopen (jname, "w")) == NULL)
       {
          unlink (dname);
          fatal ("doremote: can't create job (D.<remote>) file");
       }

     /* make file secure and change ownership to sender */
     fixperms (qfile);
     chown (jname, fileowner);
     fprintf (qfile, "U %s %s\x0A", user, nodename);
     fprintf (qfile, "F %s\x0A", dname);
     fprintf (qfile, "I %s\x0A", dname);
     fprintf (qfile, "C rmail %s \x0A", p);
     fclose (qfile);

     /* write control file */
     if ((qfile = fopen (cname, "w")) == NULL)
       {
          unlink (dname);
          unlink (jname);
          fatal ("doremote: can't open control (C.<remote>) file");
       }

     /* make file secure and change ownership to sender */
     fixperms (qfile);
     chown (cname, fileowner);
     fprintf (qfile, "S %s %s %s - %s 0666 %s\n",
                      dname, dname, user, dname, user);

     fprintf (qfile, "S %s %s %s - %s 0666 %s\n",
                      jname, xname, user, jname, user);
     fclose (qfile);
     return (DELIVERED);
}



long movemail (file, mailfile, islocal)
FILE *file, *mailfile;
flag islocal;
{
     char neighbor[40], addr[256], subj[SUBJSIZE], frm[FRMSIZE];
     register char *words[WORDSIZE];
     char crlf, *strpbrk(), *grabfrom();
     flag weorig;
     int n;
     long linecount, forwardseq();

     /* processing local or remote mail? */
     crlf = islocal  ? '\x0D' : '\x0A';

     /* Collapse all From & >From lines to a single line only final From line
        will contain valid username. */

     *addr = *neighbor = '\0';
     getline (file, line);

     while (((n = findstr (1, line, "From ")) <= 2)  &&  (n > 0))
       {
          strcpy (line2, line);
          n = getargs (words, line2, WORDSIZE);

          if (*addr != '\0')
               strcat (addr, "!");

          if (findstr (1, line, " remote from ") != 0)
            {
               if (*neighbor == '\0')
                    strcpy (neighbor, words[n - 1]);

               /* Did we get a valid address, or a munged attempt? */
               if (findstr (1, *(words + 1), "uucp") != 0)
                    strcat (strcpy (line, addr), words[n - 1]);
               else
                    sprintf (line, "%s%s!%s",
                                   addr, words[n - 1], words[1]);
            }
          else
               strcat (strcpy (line, addr), words[1]);

          strcpy (addr, line);
          getline (file, line);
       }

     /* Add this only if outgoing. */
     if (!islocal)
          sprintf (line2, " remote from %s", nodename);
     else
          *line2 = '\0';

     fprintf (mailfile, "%sFrom %s %s%s%c",
                        islocal ? ">" : "",
                        addr, date822(), line2, crlf);

     /* did we originate mail? */
     if (strpbrk (words[1], "!@%") == NULL   &&  *neighbor == '\0')
          weorig = TRUE;
     else
          weorig = FALSE;

     /* If mail is not between users on this system, add:

        Received: [from someone@this.site] by our.site (RMail OS-9 UUCP)
                id <AA12345@our.site>; Wed, 15 Sep 93 07:41 -0400  */

     if (!islocal || (islocal && !weorig))
       {
          if (*neighbor != '\0')
               sprintf (line2, " from %s", neighbor);
          else
               *line2 = '\0';

#ifndef _OSK
          fprintf (mailfile, "Received:%s by %s (RMail OS-9 UUCP)%c",
#else
# ifndef _OS9K
          fprintf (mailfile, "Received:%s by %s (RMail OS-9/68K UUCP)%c",
# else
          fprintf (mailfile, "Received:%s by %s (RMail OS-9000 UUCP)%c",
# endif
#endif
                             line2, sitename, crlf);

          fprintf (mailfile, "\tid <AA%05ld@%s>; %s%c",
                             forwardseq (weorig), sitename, date822(), crlf);
       }

     /* copy the rest of header */
     *frm = *subj = '\0';
     do
       {
          flag gotfrom = FALSE, gotsubj = FALSE;

          if (islocal)
               if (*line == 'F'  &&  !gotfrom)
                 {
                    if (strnucmp (line, "From: ", 6) == 0)
                      {
                         strncpy0 (frm, grabfrom (line), FRMSIZE);
                         gotfrom = TRUE;
                      }
                 }
               else if (*line == 'S'  &&  !gotsubj)
                    if (strnucmp (line, "Subject: ", 9) == 0
                         ||  strnucmp (line, "Subj: ", 6) == 0)
                      {
                         int len;

                         strncpy0 (subj, getstring (line), SUBJSIZE);
                         gotsubj = TRUE;
                      }
          fprintf (mailfile, "%s%c", line, crlf);

          if (*line == '\0')
               break;
       }
     while (getline (file, line) != -1);

     /* copy rest of message body unchanged */
     linecount = 0;
     while (getline (file, line) != -1)
       {
          fprintf (mailfile, "%s%c", line, crlf);
          ++linecount;
       }

     /* Add From: and Subject: to mail..list line, if local delivery */
     if (islocal)
       {
          sprintf (line, "%s|%s", 
                         *frm != '\0' ? frm : " ",
                         *subj != '\0' ? subj : " ");

          strcat (mailstring, line);
       }
     fflush (mailfile);
     return (linecount);
}



/* Return pointer to real name or address if no real name in From: line */

char *grabfrom (fromline)
char *fromline;
{
     register char *p;

     p = getrealname (fromline);

     if (*p == '\0')
          p = getval (fromline);

     return (p);
}



long forwardseq (weorig)
flag weorig;
{
     char buf[7];
     FILE *fp;
     long sequence, atol();

     /* mail originates with us, repeat the message-id number */
     if (weorig)
       {
          if ((fp = fopen (MAILSEQ, "r")) == NULL)
               return (1L);

          mfgets (buf, sizeof (buf), fp);
          return (atol (buf));
       }

     /* didn't originate with us, give a consecutive id number */
     sprintf (fname, "%s/sequence.rmail", UUCPSYS);

     if ((fp = fopen (fname, "r")) == NULL)
       {
          if ((fp = fopen (fname, "w")) == NULL)
              return (1L);

          fputs ("1\n", fp);
          sequence = 1;
       }
     else
       {
          mfgets (buf, sizeof (buf), fp);
          fclose (fp);
          sequence = atol (buf) + 1;

          /* wrap around above 99,9999 */
          if (sequence > 99999)
               sequence = 1;

          if ((fp = fopen (fname, "w")) != NULL)
#ifndef _OSK
               fprintf (fp, "%ld\n", sequence);
#else
               fprintf (fp, "%d\n", sequence);
#endif
          else
               return (sequence);

          return (sequence);
       }
     fixperms (fp);
     fclose (fp);
     return (sequence);
}



int gateway (file, filename, newsgroup)
FILE *file;
char *filename, *newsgroup;
{
     fclose (file);
     sprintf (temp, "rnews -n%s %s", newsgroup, filename);
     system (temp);
     unlink (filename);
     return (DELIVERED);
}



int forkfileserv (fp)
FILE *fp;
{
     register char *p;
     int count;
     FILE *pipe;

     p = line2;

     if ((pipe = popen ("fileserv", "w")) == NULL)
       {
          logerror ("forkfileserv: can't open pipe to FILESERV");
          return (UNDELIVERED);
       }

     closelog();

     while ((count = fread (p, sizeof (char), sizeof (line2), fp)) != 0)
          fwrite (p, sizeof (char), count, pipe);

     pclose (pipe);
     return (DELIVERED);
}



/* We always report success, even if we can't fork the program mailserver. */

int forkmailserver (fp)
FILE *fp;
{
     register char *p;
     int count;
     FILE *pipe;

     p = line2;
     if ((pipe = popen ("mailserver", "w")) != NULL)
       {
          closelog();

          while ((count = fread (p, sizeof (char), sizeof (line2), fp)) != 0)
               fwrite (p, sizeof (char), count, pipe);

          pclose (pipe);
       }
     return (DELIVERED);
}



/* For now all bounced mail gets sent to the 'errorsto' user. They will have
   manually return it to the sender. */

int bouncemail (file, reason)
FILE *file;
int reason;
{
     /* Global string 'address' already has errorsto user name.  validuid
        already has errorsto's UID.  */

     dolocal (file);
     closelog();
     exit (0);
}



/* Open the uulog file if we can.  The directory it is in is given by the
   environment variable LOGDIR.  If we can't open uulog, write to the standard
   error path instead. */

void openlog()
{
     if (logopen)
          return;

     strcat (strcpy (fname, logdir), "/uulog");

     if ((log = fopen (fname, "a")) != NULL)
       {
          setbuf (log, NULL);
          logopen = TRUE;
       }
     else
          log = stderr;
}



/* Close the uulog file if it was opened. */

void closelog()
{
     if (log == stderr)
          return;

     if (logopen)
          fclose (log);

     logopen = FALSE;
}



/* Log an error message */

void logerror (msg)
char *msg;
{
     openlog();

     if (logopen)
          fprintf (log, "rmail %s %s %s%s\n",
                        *nodename != '\0'  ? nodename : "uucp",
                        gtime(), errmsg, msg);
     else
          fprintf (stderr, "rmail: %s\n", msg);

     closelog();
}



/* exit with error if we receive a signal */

int myinterrupt (sig)
int sig;
{
     closelog();
     exit (ABORT);
}



int fatal (msg)
char *msg;
{
     fprintf (stderr, "rmail: %s", msg);

     if (logopen)
          fprintf (log, "rmail %s %s %s%s", nodename, gtime(), errmsg, msg);

     if (errno != 0)
       {
          sprintf (fname, "...error #%d", errno);

          if (logopen)
               fputs (fname, log);

          fputs (fname, stderr);
       }

     if (log != NULL)
          putc ('\n', log);

     putc ('\n', stderr);
     closelog();
     exit (UNDELIVERED);
}



void errorexit (sig)
int sig;
{
     closelog();
     exit (sig);
}



int usage()
{
     fputs ("usage: rmail [file] \"site!user[@site]\"\n\n", stderr);
     fprintf (stderr, "v%s (%s) This is free software released under the GNU General Public\n",
                      version, VERDATE);
     fputs ("License.  Please send suggestions/bug reports to:  bob@kc2wz.bubble.org\n", stderr);
     exit (0);
}
