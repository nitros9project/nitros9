/*  recvmail.c   This routine allows a user to read his/her mail.
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

/* Rewritten to support new spooled mail format.  Mail is kept as separate
   files in the directory pointed to by the parameter 'maildir' in the
   /DD/SYS/UUCP/Parameters file.  Each file is named 'mYYMMDDHHMMSS', where
   'YYMMDDHHMMSS' is the date/time RMAIL processed the message  --REB */

#include "uucp.h"
#include "mail.h"
#include <ctype.h>
#include <modes.h>
#include <direct.h>                              /* Added - BAS */
#include <sgstat.h>
#ifndef _OSK
#include <os9.h>
#include "dir_6809.h"
#else
#include <dir.h>
#endif

#define WORDSIZE   40


char dspmail(), getresponse();
void givehelp();


int recvmail (fifo)
flag fifo;
{
     flag dothis, direction;
     int numltrs, ltrsleft;
     register MAILPTR envelop;
     MAILPTR firstenvelop = NULL;
     struct mailbag *whatnow(), *reverselist(), *gathermail();

     /* Check waiting for mail.  Exit if there is none.  When we return our
        current data directory will be our mailbox directory. */

     if ((numltrs = ltrsleft = checkmail (FALSE, user)) == 0)
          exit (0);

     firstenvelop = gathermail (numltrs);

     if (!fifo)
          firstenvelop = reverselist (firstenvelop);

     /* Open each letter and read it.  Then decide if we want to: save,
        delete, undelete, redisplay, move to the next or previous letter. */

     envelop = firstenvelop;
     direction = FORWARD;
     do
          switch (dothis = openenvelop (envelop))
            {
               case ALLREAD:
                    markallmail (firstenvelop, TRUE);
                    break;

               case KILLMAIL:
                    markallmail (firstenvelop, FALSE);
                    ltrsleft = 0;

               case QUIT:
                    envelop = ENDMAIL;
                    break;

               case UNDELETE:
                    undeletemail (firstenvelop, &ltrsleft);
                    break;

               case DELETE:
                    --ltrsleft;

               default:
                    envelop = whatnow (dothis, envelop, &direction);
                    break;
            }
     while (envelop != ENDMAIL);

     if (!fifo)
          firstenvelop = reverselist (firstenvelop);

     if (ltrsleft < numltrs)
          fputs ("\b \bremoving deleted mail...", stdout);

     fflush (stdout);
#ifndef _OSK
     loadpager (FALSE);
#endif

     if (rmailin)
          munload (rmail, 0);

     updatemail_list (firstenvelop, ltrsleft);
     free (firstenvelop);
}



/* Create a double-linked list of all the mail.  Return a pointer to the start
   of the list.   */

struct mailbag *gathermail (numltrs)
int numltrs;
{
     char mailine[MLINE];
     register MAILPTR ep;
     FILE *mlptr;
     char *p, *p1;
     MAILPTR elast, envelops;
     int newmail, unreadmail;

     if ((mlptr = fopen (mail_list, "r")) == NULL)
          fatal ("gathermail: can't open user's mail..list");

     /* create a double-linked list of pointers to each line in mail..list */
     envelops = (MAILPTR) malloc (numltrs * sizeof (MAILBAG));
     
     if (envelops == NULL)
          fatal ("gathermail: can't malloc envelops array");

     /* make forward and backward links */
     ep = envelops;
     elast = envelops + numltrs;
     do
       {
          if (ep < elast - 1)
               ep->next = ep + 1;                    /* next envelop or... */
          else
               ep->next = ENDMAIL;                   /* ...end of list */

          if (ep != envelops)
               ep->prev = ep - 1;                    /* everything else... */
          else
               ep->prev = ENDMAIL;                   /* ...or first envelop */
       }
     while (++ep < elast);

     newmail = unreadmail = 0;
     ep = envelops;
     while (mfgets (mailine, MLINE, mlptr) != NULL)
       {
          /* save the individual mail..list line and point to the fields */
          ep->mline = p1 = strdup (mailine);

          if (ep->mline == NULL)
               fatal ("recvmail: can't malloc mail..list line");

          /* status */
          ep->status = *p1++;

          if (ep->status == 'N')
               ++newmail;
          else if (ep->status == 'U')
               ++unreadmail;

          /* file name */
          p = strchr (p1, '|');
          *p = '\0';
          ep->letter = p1;
          ++ep;
       }
     fclose (mlptr);

     if (newmail || unreadmail)
       {
          printf ("\nOS-9 Mailx v%s    %d message%s",
                     version, numltrs, numltrs > 0 ? "s" : "");

          if (newmail)
               printf ("    %d new", newmail);

          if (unreadmail)
               printf ("    %d unread", unreadmail + newmail);

          fputs ("\n\nhit <ENTER> to continue...", stdout);
          fflush (stdout);
          getresponse();
          cls();
       }
     return (envelops);
}



/* reverse the order of a double-linked list --REB */

struct mailbag *reverselist (list)
MAILPTR list;
{
     register MAILPTR p1;
     MAILPTR p2;

     p2 = ENDMAIL;
     while (list)
       {
          p1 = list;
          list = p1->next;
          p1->prev = p1->next;
          p1->next = p2;
          p2 = p1;
       }
     return (p2);
}



struct mailbag *whatnow (whichway, envelop, direction)
flag whichway, *direction;
register MAILPTR envelop;
{
     MAILPTR tmpmail;

     tmpmail = envelop;
     switch (whichway)
       {
          case DELETE:                 /* toss letter/envelop, update links */
               envelop->status = 'D';
               whichway = *direction == FORWARD ? NEXT : PREVIOUS;

          case NEXT:                               /* move to next message */
               do
                    if ((envelop = envelop->next) == ENDMAIL)
                      {
                         if ( !quitmail() )
                              envelop = tmpmail;
                         break;
                      }
               while (envelop->status == 'D'  ||  envelop->status == 'B');

               *direction = FORWARD;
               break;

          case PREVIOUS:                              /* show last message */
               do
                    if ((envelop = envelop->prev) == ENDMAIL)
                      {
                         envelop = tmpmail;
                         break;
                      }
               while (envelop->status == 'D' ||  envelop->status == 'B');

               *direction = REVERSE;
               break;

          case BADLETTER:             /* damaged letter or header, skip it */
               envelop->status = 'B';
               envelop = *direction == FORWARD ? envelop->next != ENDMAIL
                                                    ? envelop->next : envelop
                                               : envelop->next != ENDMAIL
                                                    ? envelop->prev : envelop;
               break;

          case AGAIN:                        /* show current message again */
          default:
               break;
       }
     return (envelop);
}



/* mark all mail as either all read or all deleted.  If KILLMAIL is TRUE, all
   mail will be deleted and mail will exit immediately.  Therefore, killed
   mail cannot be restored with the 'x' or 'u' commands. --REB */

int markallmail (firstenvelop, nokilli)
MAILPTR firstenvelop;
flag nokilli;
{
     register MAILPTR envelop;

     for (envelop = firstenvelop;  envelop;  envelop = envelop->next)
          envelop->status = nokilli ? 'P' : 'D';
}



/* make mail we deleted in this session readable again */

int undeletemail (firstenvelop, ltrsleft)
MAILPTR firstenvelop;
int *ltrsleft;
{
     char line[256];
     MAILPTR envelop;
     register char *p;
     char c;
     FILE *fp;
     int i;

     p = line;
     envelop = firstenvelop;
     do
          if (envelop->status == 'D')
               if ((fp = fopen (envelop->letter, "r")) != NULL)
                 {
                    /* print header... */
                    cls();

                    while (mfgets (p, sizeof (line), fp) != NULL)
                      {
                         if (!*p)
                              break;

                         puts (p);
                      }

                    /* ...and first four lines of message */
                    putchar ('\n');

                    for (i = 0; i < 4; ++i)
                         if (mfgets (p, sizeof (line), fp) == NULL)
                              break;
                         else
                              puts (p);

                    fclose (fp);
                    fputs ("\n\nUndelete this or resume reading?   Y/n/r...",
                            stdout);

                    fflush (stdout);
                    c = tolower ( getresponse() );
                    switch (c)
                      {
                         case 'r':
                              return (0);

                         case 'n':
                              break;

                         case 'y':
                         default:
                              envelop->status = 'P';
                              ++(*ltrsleft);
                              break;
                      }
               }
     while ((envelop = envelop->next) != ENDMAIL);

     fputs ("\n\nHit ENTER to read mail...", stdout);
     fflush (stdout);
     getresponse();
     return (0);
}



/* returns TRUE if user wants to exit after reading last message --REB */

int quitmail()
{
     register char c;
     char answer;

     putchar ('\n');
     ReVOn();
     fputs (" Last message...quit?  y/N ", stdout);
     ReVOff();
     c = tolower ( getresponse() );
     CurUp();
     putchar ('\n');
     ErEOLine();
     CurUp();
     putchar ('\n');

     if (c == 'y')
       {
          putchar (' ');
          fflush (stdout);
       }
     return (c == 'y' ? TRUE : FALSE);
}



int openenvelop (envelop)
MAILPTR envelop;
{
     FILE *infile;
     flag whichway;
     register char c;

     if ((infile = fopen (envelop->letter, "r")) == NULL)
       {
          printf ("\n%s: glue too strong...can't open '%s'\n",
                  pname, envelop->letter);

          /* give 'em a chance to read */
          sleep (2);

          /* letter disappear on us?  remove it from mail..list */
          return (errno == 216 ? DELETE : BADLETTER);
       }

     /* display incoming mail */
     if (getmsg (infile))
       {
          if (usepager)
            {
               sprintf (temp, "%s %s", pager, envelop->letter);
               docmd_na (temp);
               whichway = mailcmd (envelop->letter);
            }
          else
            {  
               c = dspmail (infile, envelop->status);
               switch (tolower (c))
                 {
                    /* want to see letter again */
                    case 'a':
                         whichway = AGAIN;
                         break;

                    /* want to see previous letter */
                    case 'p':
                    case '-':
                         whichway = PREVIOUS;
                         break;

                    /* go on to next letter */
                    case 'n':
                         whichway = NEXT;
                         break;

                    /* exit immediately, leaving mail unchanged */
                    case 'x':
                         exit (0);

                    /* we need help */
                    case 'h':
                    case '?':
                         givehelp();
                         /* fall through */

                    /* continue with the current letter */
                    default:
                         whichway = mailcmd (envelop->letter);
                         break;
                 }
            }
          if (envelop->status != 'D'  &&  envelop->status != 'B')
               envelop->status = 'P';
       }
     else
       {
          whichway = BADLETTER;
          printf ("\n%s: letter %s's header has illegible handwriting\n",
                  pname, envelop->letter);
          sleep (2);                          /* short pause */
       }

     /* close the letter file */
     fclose (infile);
     return (whichway);
}



/* getmsg  --get message

   Get header info from next mail message in the spooled mail directory.
*/

int getmsg (file)
FILE *file;
{
     char replyto[100], replynam[100], resentrply[100], resentfrm[100];
     char resentnam[100], resentdate[40], resentid[100];
     register char *lp;
     char *p;
     flag header;

     *subject = *fromdate = *frommsgid = *fromname = '\0';
     *sender = *replynam = *resentrply = *resentfrm = '\0';
     *resentdate = *resentid = '\0';
     header = TRUE;
     lp = line;

     /* be sure this are all cleared out -- REB */
     memset (address, '\0', sizeof (address));
     memset (replyto, '\0', sizeof (replyto));
 
     /* Are we still in the header?  If so, look at line */
     while (header)
          if (mfgets (lp, sizeof (line), file) != NULL)
            {
               if (*lp == '\0')
                 {
                    header = FALSE;
                    continue;
                 }

               /* Be paranoid and extract From return path this will be
                  overwritten by From: or Reply-to:, if found. */

               if (*lp == '>'  &&  strncmp (lp, ">From ", 6) == 0)
                 {
                    strcpy (temp, skipspace (lp+5));
                    for (p = temp; !isspace (*p) && *p != '\0'; p++)
                         ;

                    *p = '\0';
                    strcpy (address, temp);
                 }

               /* extract From: return path + fromname */
               if (*lp == 'F'  &&  strnucmp (lp, Hfrom, 6) == 0)
                 {
                    strcpy (address, getval (lp));
                    strcpy (fromname, getrealname (lp));
                 }

               /* extract Sender: return path */
               if (*lp == 'S'  &&  strnucmp (lp, Hsender, 8) == 0)
                    strcpy (sender, getval (lp));

               /* Reply-To, Resent-Reply-To, Resent-From: fields */
               if (*lp == 'R')
                 {
                    /* extract Reply-To: return path */
                    if (strnucmp (lp, Hreplyto, 10) == 0)
                      {
                         strcpy (replyto, getval (lp));
                         strcpy (replynam, getrealname (lp));
                      }

                    /* extract Resent-From: path */
                    else if (strnucmp (lp, "Resent-From: ", 13) == 0)
                      {
                         strcpy (resentfrm, getval (lp));
                         strcpy (resentnam, getrealname (lp));
                      }

                    /* extract Resent-Reply-To: path */
                    else if (strnucmp (lp, "Resent-Reply-To: ", 17) == 0)
                      {
                         strcpy (resentrply, getval (lp));
                         strcpy (resentnam, getrealname (lp));
                      }  

                    /* extract Resent-Date */
                    else if (strnucmp (lp, "Resent-Date: ", 13) == 0)
                         strcpy (resentdate, getstring (lp));

                    /* extract Resent-Message-Id */
                    else if (strnucmp (lp, "Resent-Message-Id: ", 19) == 0)
                         strcpy (resentid, getval (lp));
                 }

               /* extract message ID */
               if (*lp == 'M'  &&  *resentid == '\0'
                    &&  strnucmp (lp, "Message-Id: ", 12) == 0)
                 {
                    strcpy (frommsgid, getval (lp));
                 }

               /* extract message time */
               if (*lp == 'D'  &&  *resentdate == '\0'
                    &&  strnucmp (lp, Hdate, 6) == 0)
                 {
                    strncpy (fromdate, getstring (lp), sizeof (fromdate));
                 }

               /* extract subject */
               if (*lp == 'S'  &&  strnucmp (lp, Hsubject, 9) == 0 || 
                                   strnucmp (lp, Hsubj, 6) == 0)
                 {
                    if (*subject == '\0')
                      {
                         strcpy (temp, getstring (lp));

                         if (strnucmp (temp, "Re:", 3) != 0)
                              strcpy (subject, "Re: ");

                         strcat (subject, temp);
                      }
                 }
            }
          else
               /* header ended prematurely */
               return (FALSE);

     /* Resent-Date overrides Date: --REB */
     if (*resentdate != '\0')
          strncpy (fromdate, resentdate, sizeof (fromdate));

     /* be sure fromdate is properly terminated */
     fromdate[sizeof (fromdate) - 1] = '\0';

     /* Resent-Message-Id: overrides Message-Id: --REB */
     if (*resentid != '\0')
       {
          strncpy (frommsgid, resentid, sizeof (fromdate));
          frommsgid[sizeof (frommsgid) - 1] = '\0';
       }

     /*      Resent-Reply-To: supercedes From: in determining return path
        -or- Resent-From:     supercedes From: in determining return path
        -or- Reply-To:        supercedes From: in determining return path  */

     if (*resentrply != '\0')
       {
          strcpy (address, resentrply);
          strcpy (fromname, resentnam);
       }
     else if (*resentfrm != '\0')
       {
          strcpy (address, resentfrm);
          strcpy (fromname, resentnam);
       }
     else if (*replyto != '\0')
       {
          strcpy (address, replyto);
          strcpy (fromname, replynam);
       }

     if (*fromname == '\0')
          strcpy (fromname, address);

     rewind (file);
     return (TRUE);
}



/* dspmail  --display mail message */

char dspmail (file, status)
register FILE *file;
char status;
{
     static char *returnon = "ahnp-qx?";
     static int columns = 79, rows;
     static flag firstletter = TRUE;
     register char *p;
     flag header = TRUE;
     int i;
     char c, t;

     /* Get number of rows from path descriptor.  We assume at least an
        80 column display is used.  */

     if (firstletter)                              /* Changed -- REB */
       {
          struct sgbuf pd;

          rows = (_gs_opt (STDOUT, &pd) != ERROR) ? (int) pd.sg_page : 24;
          --rows;
          firstletter = FALSE;
       }

     cls();
     i = 0;
     c = '\0';
     p = line;
     while (mfgets (p, sizeof (line), file) != NULL)
       {
          if (header  &&  *p == '\0')
            {
               fputs ("Status: ", stdout);
               switch (status)
                 {
                    case 'N':
                         puts ("NEW");
                         break;

                    case 'U':
                         puts ("UNREAD");
                         break;

                    default:
                         puts ("READ");
                         break;
                 }
               header = FALSE;
               ++i;
            }

          if (i >= rows  ||  *p == '\f')
            {
               ReVOn();
               fputs (" --MORE--", stdout);
               ReVOff ();
               c = tolower ( getresponse() );
               CurUp();
               putchar('\n');
               DelLine();
               CurUp();
               putchar ('\n');
               i = 0;

               /* Go to 'mailx>' prompt on <A>gain, <->/<P>revious, <N>ext,
                  <Q>uit, or e<X>it.  Changed --REB  */

               if (strchr (returnon, c) != NULL)
                    break;
            }
          fixline (p);

          if (header)
               if (!fullheader)
                    if (strnucmp (p, ">From ", 6) == 0)
                         goto showit;
                    else if (strnucmp (p, Hfrom, 6) == 0)
                         goto showit;
                    else if (strnucmp (p, "To: ", 4) == 0)
                         goto showit;
                    else if (strnucmp (p, Hdate, 6) == 0)
                         goto showit;
                    else if (strnucmp (p, Hreplyto, 10) == 0)
                         goto showit;
                    else if (strnucmp (p, Hsubject, 9) == 0
                             ||  strnucmp (p, Hsubj, 6) == 0)
                         goto showit;
                    else if (strnucmp (p, Hcc, 4) == 0)
                         goto showit;
                    else if (strnucmp (p, Hsender, 8) == 0)
                         goto showit;
                    else if (strnucmp (p, Hx, 2) == 0)
                         goto showit;
                    else
                         continue;
showit:   puts (p);
          i += (strlen (p) / columns) + 1;
       }
     fclose (file);

     if (c == 'n')                             /* flush keyboard input */
          if ((i = _gs_rdy (0)) > 0)
               read (0, temp, i);
     return (c);
}



/* Returns PREVIOUS if we want to redisplay the previous message.  AGAIN if we
   want to redisplay the current message.  NEXT if we want to move on to the
   next message.  DELETE if we deleted the current message. */

int mailcmd (letter)
char *letter;
{
     char path[128]; 
     struct fildes fdes;
     flag noerror, orig_usesig, orig_cc_prompt, cflag;
     int n, f;
     register char c;
     char *p, *words[WORDSIZE], *tmpAdrs, *tmpSubj;

     /* make a copy of the filename in case we reply -- REB */
     strcpy (message, letter);

     /* run mailx commands for this message */
     for (;;)
       {
          fputs ("\nmailx> ", stdout);
          fflush (stdout);
          c = tolower ( getresponse() );
          switch (c)
            {
               /* Next message */
               case ' ':
               case 'n':
               case '\n':
                    return (NEXT);

               /* toggle displaying entire or abbreviated header */
               case 'z':
                    fullheader = !fullheader;
                    backspace (1);
                    printf ("full header display %s...",
                            fullheader ? "on" : "off");

                    fflush (stdout);
#ifndef _OSK
                    tsleep (60);                       /* brief pause so    */
#else                                                  /* everyone can read */
                    sleep (1);                         /* the message       */
#endif
                    /* fall through */

               /* redisplay the current message */
               case 'a':
                    return (AGAIN);

               /* reply command */
               case 'r':
                    /* save current From: */
                    if ((tmpAdrs = strdup (address)) != NULL)
                      {
                         reply = TRUE;
                         putchar ('\n');
                         sendmail();
                         strcpy (address, tmpAdrs);
                         free (tmpAdrs);
                         reply = FALSE;
                      }
                    else
                      {
                         fputs ("mailcmd: can't make copy of From:", stdout);
                         fflush (stdout);
                         continue;
                      }
                    break;

               /* save command -- strip or keep header --REB */
               case 's':
               case 'w':
                    /* Set up a flag to tell us later whether or not we need
                       to reset the uid of the file.  We don't want to do this
                       simple hack for just any file as it would allow anyone
                       to put a file anywhere in the file system.  --BAS 2  */

                    cflag = FALSE;
                    p = getinput (path, sizeof (path));

                    if (*p == '\0')
                      {
                         sprintf (fname, "%s/mbox", homedir);
                         cflag = TRUE;
                         asetuid (0);
                      }
                    else if (*p == '/')
                         strcpy (fname, p);
                    else
                      {
                         sprintf (fname, "%s/%s", homedir, p);
                         cflag = TRUE;
                         asetuid(0);
                      }
                    printf ("\nSaving message to %s\n", fname);

                    /* If you don't check the ownership of the file, then it
                       is possible to overwrite any file on the same disk as
                       filename given, if you allow users to make links.
                         --BAS 2 */

                    if ((f = open (fname, 1)) > 0)
                      {
                         _gs_gfd (f, &fdes, sizeof (fdes));
                         close (f);

                         if (myuid != (unsigned)fdes.fd_own)
                           {
                              printf ("%s: %s exists and it is not yours\n",
                                      pname, fname);

                              if (cflag)
                                   asetuid (myuid);
                              continue;
                           }
                      }

                    /* save message with header */
                    if (c == 's')
                         noerror = fileapnd (letter, fname, TRUE);
                    else
                         /* save message without header */
                         noerror = fileapskp (letter, fname, TRUE);

                    if (noerror == FALSE)
                      {
                         printf ("%s: can't save letter to %s...error %d\n",
                                 pname, fname, errno);

                         asetuid (myuid);
                         continue;
                      }

                    /* If we need to, reset the ownership of the file-BAS 2 */
                    if (cflag)
                      {
                         chown (fname, myuid);
                         asetuid (myuid);
                      }

               /* delete current message -- REB */
               case 'd':
                    CurUp();
                    fputs ("\nDelete? y/N ", stdout);
                    fflush (stdout);
                    c = tolower ( getresponse() );

                    if (c == 'y')
                         return (DELETE);
                    else
                      {
                         CurUp();
                         putchar ('\n');
                         ErEOLine();
                         CurUp();
                         fflush (stdout);
                      }
                    break;

               /* redisplay previous message */
               case 'p':
               case '-':
                    return (PREVIOUS);

               /* forward copy of message to user(s) */
               case 'f':
                    fputs ("orward to: ", stdout);
                    p = getinput (path, sizeof (path));

                    if (!*p)
                         continue;

                    /* save the current To: */
                    if ((tmpAdrs = strdup (address)) != NULL)
                      {
                         /* clear the old To: */
                         memset (address, '\0', sizeof (address));
                         usesig = NOSIG;
                         forward = TRUE;
                         n = getargs (words, p, WORDSIZE);           /* REB */

                         if (parse_addr (n, words) != ABORT)
                              sendmail();

                         /* restore previous To: */
                         strcpy (address, tmpAdrs);
                         free (tmpAdrs);
                         usesig = USESIG;
                         forward = FALSE;
                      }
                    else
                      {
                         fputs ("mailcmd: can't make copy of To:", stdout);
                         fflush (stdout);
                         continue;
                      }
                    break;

               /* mail command...can include command line options d,p and s */
               case 'm':
                    p = getinput (path, sizeof (path));

                    if (*p == '\0')
                         continue;

                    /* save original To: and Subject: */
                    if ((tmpAdrs = strdup (address)) == NULL)
                      {
                         fputs ("mailcmd: cannot save original To:",
                                stdout);
                         fflush (stdout);
                         continue;
                      }

                    if ((tmpSubj = strdup (subject)) == NULL)
                      {
                         fputs ("mailcmd: cannot save original Subject:",
                                stdout);
                         fflush (stdout);
                         continue;
                      }
                         
                    /* clear the address and subject --REB */
                    memset (address, '\0', sizeof (address));
                    memset (subject, '\0', sizeof (subject));

                    /* save original cc_prompt and usesig */
                    orig_usesig = usesig;
                    orig_cc_prompt = cc_prompt;
                    n = getargs (words, p, WORDSIZE);

                    if (parse_addr (n, words) != ABORT)
                         sendmail();

                    /* put back original cc_prompt and usesig */
                    usesig = orig_usesig;
                    cc_prompt = orig_cc_prompt;
                    strcpy (address, tmpAdrs);
                    free (tmpAdrs);
                    strcpy (subject, tmpSubj);
                    free (tmpSubj);
                    break;

               /* exit mail after killing deleted mail */
               case 'q':
                    return (QUIT);

               /* exit without touch any mail */
               case 'x':
                    myinterrupt (0);

               /* make ALL deleted mail readable again */
               case 'u':
                    return (UNDELETE);

               /* fork a shell for the user */
               case '!':
                    forkshell();
                    fputs ("\b  ", stdout);
                    CurUp();
                    break;

               /* help command */
               case 'h':
               case '?':
                    givehelp();
                    break;

               /* mark all mail read --REB */
               case 'c':
                    backspace (1);
                    fputs ("marking all mail as read...", stdout);
                    fflush (stdout);
                    return (ALLREAD);

               /* delete ALL mail then exit */
               case 'k':
                    backspace (1);
                    fputs ("delete ALL mail?  y/N ", stdout);
                    fflush (stdout);
                    c = tolower ( getresponse() );
                    backspace (23);

                    if (c == 'y')
                      {
                         fputs ("are you sure?  y/N ", stdout);
                         fflush (stdout);
                         c = tolower ( getresponse() );
                         backspace (20);

                         if (c == 'y')
                           {
                              fputs ("killing all mail...", stdout);
                              fflush (stdout);
                              return (KILLMAIL);
                           }
                      }
                    CurUp();
                    fflush (stdout);
                    break;

               /* toggle file viewer on or off --REB */
               case 'v':
                    fputs ("iewer ", stdout);

                    if (*pager != '\0')
                      {
                         usepager = !usepager;
                         printf ("now %s...", usepager ? "on" : "off");
                         fflush (stdout);
#ifndef _OSK
                         loadpager (usepager ? TRUE: FALSE);
#endif
                       }
                    else
                      {
                         fputs ("is not defined...", stdout);
                         fflush (stdout);
                      }
                    break;

#ifdef FIXME
               /* current message is piped to standard input of a program */
               case '|':
                    p = getinput (path, sizeof (path));

                    if (*p == NULL)
                         continue;

                    dopipe (letter, p);
                    break;
#endif
               default:
                    printf ("\nUnknown command: %c\n", c);
                    break;
            }
       }
}



/* get a single character response from the user */

char getresponse()
{
     char c;

     /* wait for valid input */
     echo (OFF);
     do
       {
          while (_gs_rdy (0) <= 0)
               tsleep (4);

          read (0, &c, 1);
       }
     while (c < '\x20'  &&  c > '\x7f');

     echo (ON);
     if (c != '\n'  &&  c != ' ')
       {
          putchar (c);
          fflush (stdout);
       }
     return (c);
}



/* Open double overlay windows for keyboard user--white on red over black on
   black.  Should only be called by CoCo when TERMCAP is not defined. */

#ifndef TERMCAP
int popdoublewindow (x, y, width, height)
int x, y, width, height;
{
     char outstr[18];

     /* turn off the cursor */
     write (1, "\x05\x20", 2);

     *(outstr + 0) = *(outstr + 9)  = 0x1b;
     *(outstr + 1) = *(outstr + 10) = 0x22;
     *(outstr + 2) = *(outstr + 11) = 1;
     *(outstr + 5) = *(outstr + 14) = width;
     *(outstr + 6) = *(outstr + 15) = height;

     /* bottom window */
     *(outstr + 3) = x + 1;                    /* offset bottom window */
     *(outstr + 4) = y + 1;
     *(outstr + 7) = 2;                        /* black on black */
     *(outstr + 8) = 2;

     /* top window */
     *(outstr + 12) = x;
     *(outstr + 13) = y;
     *(outstr + 16) = 0;                        /* white on red */
     *(outstr + 17) = 4;

     write (1, outstr, sizeof (outstr));
     winopen = TRUE;
}



/* Close double overlay window */

int closedoublewindow()
{
     write (1, "\x1b\x23\x1b\x23\x08  \n\x09\x05\x21", 11);
     winopen = FALSE;
}
#endif


/* backspace-space-backspace to delete part of a line */

int backspace (howmany)
int howmany;
{
     register int i;

     for (i = 0; i < howmany; ++i)
          fputs ("\b \b", stdout);

     fflush (stdout);
}



int putdashes (howmany)
int howmany;
{
     register int i;

     putchar (' ');

     for (i = 0; i < howmany; ++i)
          putchar ('=');

     fflush (stdout);
}



void givehelp()
{
     register char **hlp;
     static char *helptxt[] = {
                            "a\t\t redisplay current message",
                            "c\t\t mark all mail as read",
                            "d\t\t delete current message",
                            "f\t\t forward current message",
                            "h, ?\t     this message",
                            "k\t\t delete ALL mail",
                            "m <address>     send mail to <address>",
                            "n/ENTER/SPACE   go to next message",
                            "p, -\t     show previous message",
                            "q\t\t update and exit",
                            "r\t\t reply to this message",
                            "s [filename]    save message to 'filename'",
                            "\t\t   default is 'mbox'",
                            "u\t\t undelete mail",
                            "v\t\t toggle using file viewer",
                            "w [filename]    save message without header to",
                            "\t\t   'filename', default is 'mbox'",
                            "x\t\t exit with no updating",
                            "z\t\t toggle message header display",
                            "!\t\t fork a shell",
#ifdef FIXME
                            "|cmd\t   run 'cmd' with current message",
                            "\t\t   as input",
#endif
                            NULL
                         };

#ifndef TERMCAP
     if (t2flag)
          puts ("\n");
     else
       {
          popdoublewindow (31, 0, 48, 22);
          putdashes (17);
          printf (" Mailx v%s", version);
          putdashes (17);
          putchar (' ');
       }
#else
     putchar ('\n');
     putdashes (17);
     printf ("Mailx v%s", version);
     putdashes (17);
     putchar ('\n');
#endif
     for (hlp = helptxt; *hlp; ++hlp)
          printf (" %s\n", strdetab (strcpy (temp, *hlp), 7));

#ifndef TERMCAP
     if (t2flag)
          putchar ('\n');
     else
       {
          putdashes (46);
          getresponse();
          closedoublewindow();
       }
#else
     putdashes (46);
     putchar ('\n');
#endif
}
