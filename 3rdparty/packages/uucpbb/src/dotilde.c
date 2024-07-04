/*  dotilde.c   This program handles the ~ commands from mailx and postnews.
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

/* Handle ~ commands from mail and postnews.  Made into a separate program
   for the CoCo to save keep mail and postnews smaller --REB

   args passed to us in the order:
        command t2flag myuid quotechar letter homedir message  */

#define MAIN

#include "uucp.h"
#include <signal.h>
#ifndef _OSK
#include <os9.h>
#endif

#define SHOWLINES  6              /* lines to show on screen with ~r and ~m */

#ifndef TERMCAP
QQ flag t2flag, winopen = FALSE;
#endif
QQ unsigned myuid;
char dline[256];
long _gs_size();
int myinterrupt();


int main(argc, argv)
int argc;
char **argv;
{
     char cmd[80], from[256], msgid[100], command[128];
     char *letter, *message, quotechar, *fname, c, *p, *words[3];
     FILE *infile, *outfile;
     register char *doline;
     flag douuencode = TRUE;
     char *errmsg = "ERROR--",
          *reopen = "can't reopen letter file\n",
          *required = "a filename is required...\n",
          *editor;                           /* moved from getparam.c --REB */

     pflinit();                              /* longs will be printed */
     intercept (myinterrupt);
     ++argv;
     strcpy (command, *argv++);
#ifndef TERMCAP
     t2flag = atoi (*argv);
#endif
     ++argv;
     myuid = atoi (*argv++);
     quotechar = **argv;
     letter = *(++argv);
     homedir = *(++argv);
     message = argc == 8 ? *(++argv) : NULL;
     doline = dline;
     editor = NULL;

     switch (*(command + 1))
       {
          /* ~v: edit letter with "vi" */
          case 'v':
          case 'V':
               sprintf (cmd, "vi %s", letter);

               if (docmd_na (cmd) != 0)
                    sleep (2);
               break;

          /* ~e: edit letter with appropriate editor */
          case 'e':
          case 'E':
#ifndef _OSK
               sprintf (doline, "%s/%s/%s", homedir, uudir, _MAILRC);
#else
               sprintf (doline, "%s/%s", homedir, _MAILRC);
#endif
               if ((infile = fopen (doline, "r")) != NULL)
                 {
                    while (mfgets (doline, sizeof (dline), infile) != NULL)
                         if (getargs (words, dline, 3) == 3)
                              if (strucmp ("editor", *words) == 0)
                                {
                                   editor = strdup (words[2]);
                                   break;
                                }
                    fclose (infile);
                 }

               if (editor == NULL)
                    if ((editor = getenv ("EDITOR")) == NULL)
                      {
                         puts ("EDITOR is undefined");
                         break;
                      }
               sprintf (cmd, "%s %s", editor, letter);
               docmd_na (cmd);
               free (editor);
               break;

          /* ~R: append contents of file to letter NO attempt to uuencode */
          case 'R':
               douuencode = FALSE;

          /* ~r: append contents of file to letter, uuencode if binary */
          case 'r':
               if (*(command + 2) != '\0')
                    fname = skipspace (command + 3);
               else
                    *fname = '\0';

               if (*fname == '\0')
                 {
                    printf ("%s%s", errmsg, required);
                    break;
                 }

               if ((p = strchr (command, '\n')) != NULL)
                    *p = '\0';

               if (douuencode  &&  (p = strrchr (fname, '.')) != NULL)
                 {
                    ++p;

                    if (isbin (fname, letter, p) == TRUE)
                         break;
                 }
               asetuid (0);

               if ((infile = fopen (fname, "r")) != NULL)
                    if ((outfile = fopen (letter, "a")) != NULL)
                      {
                         asetuid (myuid);
                         printf ("\nAppending file: %s\n\n", fname);
                         c = *(command + 2) == ' '  ? '\0'  : *(command + 2);
                         appendtext (infile, outfile, c, FALSE);
                      }
                    else
                      {
                         fclose (infile);
                         printf ("%s%s", errmsg, reopen);
                      }
               else
                    printf ("%scan't open file: %s\n", errmsg, fname);
               break;

          /* ~m: append the message we're replying to */
          case 'm':
          case 'M':
               asetuid (0);
               if (message == NULL)
                 {
                    printf ("%sno message read yet\n", errmsg);
                    break;
                 }

               if ((infile = fopen (message, "r")) != NULL)
                    if ((outfile = fopen (letter, "a")) != NULL)
                      {
                         asetuid (myuid);
                         *from = *msgid = '\0';
                      }
                    else
                      {
                         fclose (infile);
                         printf ("%s%s - %d", errmsg, reopen,errno);
                         break;
                      }
               else
                 {
                    printf ("%scan't open: %s ...%d\n", errmsg, message,errno);
                    break;
                 }

               while (mfgets (doline, sizeof (dline), infile) != NULL)
                 {
                    if (*doline == '\0')
                         break;
                    else if (*doline == 'F'  && *from == '\0'
                         && strnucmp (doline, "From: ", 6) == 0)
                      {
                         strncpy (from, &dline[6], sizeof (from));
                         from[sizeof (from) - 1] = '\0';
                      }
                    else if (*doline == 'M'  &&  *msgid == '\0'
                         && strnucmp (doline,"Message-Id: ",12) == 0)
                      {
                         strncpy (msgid, &dline[12], sizeof (msgid));
                         msgid[sizeof (msgid) - 1] = '\0';
                      }
                    else if (*doline == 'R')
                         if (strnucmp (doline, "Resent-From: ", 13) == 0)
                           {
                              strncpy (from, &dline[13], sizeof (from));
                              from[sizeof (from) - 1] = '\0';
                           }
                         else if (strnucmp (doline, "Resent-Message-Id: ", 19)
                                   == 0)
                           {
                              strncpy (msgid, &dline[19], sizeof (msgid));
                              msgid[sizeof (msgid) - 1] = '\0';
                           }
                 }

               if (*msgid != '\0'  &&  *from != '\0' &&
                      (strlen (msgid) + strlen (from)) < 70)
                 {
                    fprintf (outfile, "In %s, ", msgid);
                    printf ("In %s, ", msgid);
                 }

               if (*from != '\0')
                 {
                    sprintf (doline, "%s says:\n", skipspace (from));
                    fputs (doline, outfile);
                    fputs (doline, stdout);
                 }

               /* if no quote character is given default is */
               /* given in global quotechar.  Changed --REB */

               switch (*(command + 2))
                 {
                    case '\0':
                    case '\n':
                         c = quotechar;
                         break;

                    case ' ':
                         c = '\0';
                         break;

                    default:
                         c = *(command + 2);
                         break;
                 }

               appendtext (infile, outfile, c, TRUE);
               break;

          /* ~h: help command */
          case '?':
          case 'h':
          case 'H':
               editor = getenv ("EDITOR");
#ifndef TERMCAP
               if (!t2flag)
                    popdoublewindow (30, 0, 48, 15);

               putdashes (17);
               fputs (" Tilde Help", stdout);
               putdashes (17);
               putchar ('\n');
#else
               puts ("\n================= Tilde Help =================");
#endif
               puts (" ~h, ~?       this help message");
               puts (" ~m[c]        append message being replied to");
               puts ("                preface each line with char c");
               printf ("                default is %c\n", quotechar);
               puts (" ~r[c] <file> append 'file', preface each line");
               puts ("                with char c, uuencode binaries");
               puts (" ~R[c] <file> same as ~r, 'file' NOT uuencoded");
               puts (" ~v           edit message with vi");
               printf (" ~e           edit message with %s\n",
                       editor != NULL ? editor : "UNDEFINED");
               puts (" ~q, ~x       exit immediately");
               puts (" ~!           fork a shell");
               puts (" ~a           abort sending current message");
               puts (" ~u <file>    uuencode 'file' before appending");

#ifndef TERMCAP
               if (!t2flag)
                 {
                    putdashes (46);
                    read (0, &c, 1);
                    closedoublewindow();
                    CurUp();
                    CurUp();
                 }
#else
               putdashes (46);
               puts ("\n");
#endif
               break;

          /* ~q, ~x: exit command.  Cleanup after ourself -- REB */
          case 'q':
          case 'x':
               myinterrupt (SIGQUIT);

          /* ~!: fork a shell --REB */
          case '!':
               forkshell();
               CurUp();
               CurUp();
               break;

          /* ~a: abort sending message --REB */
          case 'a':
          case 'A':
               fputs ("Abort sending this message?  y/N ", stdout);
               fflush (stdout);
               read (0, &c, 1);

               if (tolower (c) == 'y')
                 {
                    putchar ('\n');
                    exit (ABORT);
                 }
               CurUp();
               putchar ('\n');
               ErEOLine();
               CurUp();
               CurUp();
               break;

          /* ~u: uuencode and append a file --REB */
          case 'u':
          case 'U':
               if (*(command + 2))
                    fname = skipspace (command + 3);
               else
                    *fname = '\0';

               if (*fname == '\0')
                 {
                    printf ("%s%s", errmsg, required);
                    break;
                 }

               if ((p = strchr (command, '\n')) != NULL)
                    *p = '\0';

               if (uuencodeit (fname, letter) == FALSE)
                    printf ("%scan't uuencode %s ...error %d\n",
                             errmsg, fname, errno);
               break;

          default:
               puts ("Unrecognized tilde command");
               break;
       }
     asetuid (myuid);
     puts ("\nContinuing...type \".\" or <ESC> to end message...");
     exit (0);
}



/* Append message or different file to current outgoing mail.  If the file
   larger than 500 bytes, only the first six lines are shown on the screen
   Boisy Pitre suggested this idea. */

int appendtext (infile, outfile, quote, fixln)
FILE *infile, *outfile;
char quote;
int fixln;
{
     register char *doline;
     int linecount, showlines;
     long filesize;

     linecount = SHOWLINES;
     doline = dline;

     filesize = _gs_size (fileno (infile));
     showlines = (filesize > 500L)  ?  FALSE : TRUE;

     while (mfgets (doline, sizeof (dline), infile) != NULL)
       {
          if (fixln)
               fixline (dline);

          if (quote != '\0')
               putc (quote, outfile);

          fprintf (outfile, "%s\n", doline);

          if (showlines)
            {
               if (quote != '\0')
                    putc (quote, outfile);

               puts (doline);
            }
          else
               if (linecount)
                 {
                    if (quote != '\0')
                         putchar (quote);

                    puts (doline);
                    --linecount;

                    if (linecount == 0)
                      {
                         fputs ("\n  [appending rest of text...", stdout);

                         if (filesize > 2000L)
                              printf ("%ld bytes", filesize);

                         fputs ("]  ", stdout);
                         fflush (stdout);
                      }
                 }
       }
     fclose (infile);
     fclose (outfile);

     if (!showlines)
          putchar ('\n');
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



int isbin (source, letter, ext)
char *source, *ext, *letter;
{
     register char *p;
     FILE *fp;
     int extlen = strlen (ext);

     p = dline;
     sprintf (p, "%s/bin.list", UUCPSYS);

     if ((fp = fopen (p, "r")) == NULL)
          return (FALSE);

     while (mfgets (p, sizeof (dline), fp) != NULL)
          if (strnucmp (p, ext, extlen) == 0)
            {
               fclose (fp);
               return (uuencodeit (source, letter));
            }
     fclose (fp);
     return (FALSE);
}



int uuencodeit (source, letter)
char *source, *letter;
{
     register int saveout;
     int result;
     char *p, *dash = "---------------";

     printf ("uuencoding %s...", source);
     fflush (stdout);

     if (access (source, READ) == ERROR)
          return (FALSE);

     /* save standard output */
     saveout = dup (STDOUT);
     
     /* try to redirect standard output */
     close (STDOUT);
     
     if (open (letter, WRITE) != STDOUT)
       {
          fprintf (stderr, "PANIC! can't redirect standard output to %s\n",
                           letter);
          dup (saveout);
          close (saveout);
          return (FALSE);
       }

     lseek (STDOUT, _gs_size (STDOUT), FRONT);
     p = strrchr (source, '/');
     sprintf (dline, "%s %s %s\n", dash, p != NULL ? ++p : source, dash);
     write (STDOUT, dline, strlen (dline));
     sprintf (dline, "uuencode %s %s", source, source);
     result = docmd_na (dline);
     close (STDOUT);
     dup (saveout);
     close (saveout);
     asetuid (myuid);
     return (result == 0 ? TRUE : FALSE);
}



int myinterrupt (sig)
int sig;
{
#ifndef TERMCAP
     if (winopen)
          return;
#endif
     exit (sig);
}



#ifndef TERMCAP
/* open double overlay windows for keyboard user--white on red over black on
   black.  Shouldn't be called if using CoCo TERMCAP.  */

int popdoublewindow (x, y, width, height)
int x, y, width, height;
{
     char outstr[18];

     /* turn off the cursor */
     CurOff();

     outstr[0] = outstr[9]  = 0x1b;
     outstr[1] = outstr[10] = 0x22;
     outstr[2] = outstr[11] = 1;
     outstr[5] = outstr[14] = width;
     outstr[6] = outstr[15] = height;

     /* bottom window */
     outstr[3] = x + 1;                    /* offset bottom window */
     outstr[4] = y + 1;
     outstr[7] = 2;                        /* black on black */
     outstr[8] = 2;

     /* top window */
     outstr[12] = x;
     outstr[13] = y;
     outstr[16] = 0;                        /* white on red */
     outstr[17] = 4;

     write (1, outstr, sizeof (outstr));

#ifndef TERMCAP
     winopen = TRUE;
#endif
}



/* Close double overlay window */

int closedoublewindow()
{
     write (1, "\x1b\x23\x1b\x23", 4);
     resetline();

#ifndef TERMCAP
     winopen = FALSE;
#endif
}



int resetline()
{
     puts ("\b  ");
     CurUp();
     CurOn();
}
#endif
