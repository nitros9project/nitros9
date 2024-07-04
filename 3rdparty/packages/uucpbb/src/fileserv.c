/*  fileserv.c   This is the main program of the OS-9 Fileserver.
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

/* This is a simple file server which sends requested files.  The server has
   five commands: reply <address>, help, get <filename>, dir and quit.  The
   Subject: line is ignored.  The server uses the directory specified by the
   parameter 'fileserver' in /DD/SYS/UUCP/Parameters.  Sysadmins will have to
   manually create and update the 'help' file for now.  The help file is
   called 'FileServ.help'.  fileserv expects to find it in /DD/SYS/UUCP.

   Usage: filserv

   FileServ reads the standard input.  It expects what it is reading is an
   e-mail message with a standard RFC-822 header.  It expects the message
   body contains commands.  Any commands not recognized are ignored.  Fileserv
   stops processing commands when it encounters the 'quit' command.  Each
   command creates a separate mail reply.

   History
   -------
   ????        - v1.0 written by Rick Adams and contributed to the UUCPbb
                   package.  Thanks Rick!!

   94 Feb 11   - v2.0 made stand alone program.
               - Added using pipes, proper message header, 'quit' and
                   'dir [pathname]' commands, uuencoding of binary files,
                   warning sysadmin about questionable requests and
                   generally "spiffed" it up.
                   --Bob Billson (REB)  bob@kc2wz.bubble.org
*/

#define MAIN

#include "uucp.h"
#include <ctype.h>
#include <time.h>
#include <modes.h>

/* Name of your favorite utility to show directory listings.  Preferably one
   which gives file size in decimal.  Anyone have a *good*, *basic* UNIX-like
   LS utility for the CoCo and/or OSK? --REB  */

#ifndef _OSK
#define LSUTIL  "dir e"                       /* CoCo standard 'dir' */
#else
#define LSUTIL  "dir -e"                      /* OSK standard 'dir' command */
#endif

#define WORDSIZE  10
#define BUFSIZE   256

extern char temp[], fname[];
extern QQ char *nodename, *sitename, *errorsto;
extern QQ flag fsactive;

QQ char *incomedir, *fsdir;
char tempfile[33];
FILE *log, *popen();
long _gs_size();
void wtlog(), warnadmin(), chg_to_dir(), flushbits(), writeheader();
void sendmsg(), rejectfile(), fatal();


int myinterrupt (sig)
int sig;
{
     if (*tempfile != '\0')
          unlink (tempfile);

     if (log != NULL)
          fclose (log);

     exit (0);
}



int main()
{
     char replyto[256], address[256], line[BUFSIZE], buff[BUFSIZE];
     register char *lp;
     char *words[WORDSIZE];
     int i, n;
     flag header, fileOK, fsdead, submitOK, firstcmd;
     FILE *msg, *creat_temp();

     *address = *replyto = *tempfile = '\0';
     log = NULL;

     pflinit();                      /* tell compiler longs will be printed */
     intercept (myinterrupt);

     if (getparam() == FALSE)
          exit (0);

     if ((logdir = getenv ("LOGDIR")) != NULL)
          logdir = strdup (logdir);
     else
          logdir = LOGDIR;

     if (fsactive)
          if ((fsdir = getdirs ("fileserver")) == NULL)
            {
               wtlog ("fileserv", "'fileserver' not in Parameters");
               fsactive = FALSE;
            }

     /* If the fileserver is active, are we accepting incoming files? */
     if (fsactive)
       {
          incomedir = getdirs ("incoming");

          if (incomedir == NULL)
               submitOK = FALSE;
          else if (strucmp (incomedir, "no") == 0
               ||  strucmp (incomedir, "off") == 0)
            {
               free (incomedir);
               submitOK = FALSE;
            }
          else
               submitOK = TRUE;
       }

     /* For now we are rejecting all submission attempts. */
     submitOK = FALSE;

     /* parse return address, commands */
     lp = line;
     header = TRUE;

     while (header)
          if (mfgets (lp, sizeof (line), stdin) != NULL)
            {
               /* end of header? */
               if (*lp == '\0')
                 {
                    header = FALSE;
                    continue;
                 }

               /* Be paranoid and extract From return path this will be
                  overwritten by From:, if found. */

               if (strncmp (lp, ">From ", 6) == 0
                   || strncmp (lp, "From ", 5) == 0)
                 {
                    char *p;

                    strcpy (temp, skipspace (lp+5));
                    for (p = temp; !isspace (*p) && *p != '\0'; p++)
                         /* do nothing */ ;

                    *p = '\0';
                    strcpy (address, temp);
                 }

               /* extract From: return path + fromname */
               else if (*lp == 'F'  &&  strnucmp (lp, "From: ", 6) == 0)
                    strcpy (address, getval (lp));

               /* extract Reply-To: return path */
               else if (*lp == 'R'  &&  strnucmp (lp, "Reply-To: ", 10) == 0)
                    strcpy (replyto, getval (lp));
            }
          else
               exit (0);              /* header ended prematurely  */

     /* Reply-To: supercedes From: for return path */
     if (*replyto != '\0')
          strcpy (address, replyto);

     /* file server not available?  Tell 'em and exit */
     if (!fsactive)
          unavailable (address, FALSE);

     /* Now we extract the message body.  What is in "line" might be a
        command.  "address" should have a valid reply path now. */

     lp = line;
     firstcmd = TRUE;

     while (mfgets (lp, sizeof (line), stdin) != NULL)
       {
          maketemp (tempfile, 'f');
          strcpy (buff, lp);
          switch (n = getargs (words, buff, WORDSIZE))
            {
               /* "quit", "dir" (no subdirectory), "help" or command? */
               case 1:
                    if (strucmp (*words, "quit") == 0)
                      {
                         wtlog (address, lp);
                         free (fsdir);

                         if (log != NULL)
                              fclose (log);

                         flushbits();
                         exit (0);
                      }
                    else if (strucmp (*words, "dir") == 0)
                      {
                         wtlog (address, lp);

                         /* Go to the public files directory */
                         chg_to_dir (address, FALSE);

                         if ((msg = creat_temp (tempfile)) == NULL)
                              continue;

                         writeheader (msg, address, "dir", TRUE);

                         if (grabdir (".", tempfile) == TRUE)
                              sendmsg (address, tempfile);
                      }
                    else if (strucmp (*words, "help") == 0)
                      {
                         wtlog (address, lp);

                         if ((msg = creat_temp (tempfile)) == NULL)
                              continue;

                         writeheader (msg, address, "help", FALSE);
                         fprintf (msg,
                                  "                    Welcome to the OS-9 File Server at %s\n\n",
                                  nodename);

                         fclose (msg);
                         sprintf (fname, "%s/FileServ.help", UUCPSYS);
                         fileapnd (fname, tempfile, TRUE);
                         sendmsg (address, tempfile);
                      }
                    break;

               /* "get <filename>", "dir <path>" or "reply <address>"? */
               case 2:
                    /* command "reply <address>".  We only accept this if it
                       is the first command sent us */

                    if (strucmp (*words, "reply") == 0)
                      {
                         if (!firstcmd)
                              continue;

                         wtlog (address, lp);
                         strcpy (address, words[1]);
                      }

                    /* command "dir <dir>"   --REB */
                    else if (strucmp (*words, "dir") == 0)
                      {
                         /* Go to the public files directory */
                         chg_to_dir (address, FALSE);

                         wtlog (address, lp);

                         if ((msg = creat_temp (tempfile)) == NULL)
                              continue;

                         writeheader (msg, address, lp, TRUE);

                         /* check for any "funny business".  changed --REB */
                         fileOK = pathallowed (words[1]);

                         if (fileOK)
                           {
                              if (grabdir (words[1], tempfile) == TRUE)
                                   sendmsg (address, tempfile);
                           }
                         else
                           {
                              warnadmin (address, lp);

                              /* tell the requester "sorry" */
                              msg = fopen (tempfile, "a");
                              fprintf (msg,
                                       "Could not find the directory: %s\n",
                                       words[1]);
                              fclose (msg);
                              sendmsg (address, tempfile);
                           }
                      } 

                    /* command "get <filename>" */
                    else if (strucmp (*words, "get") == 0)
                      {
                         char filepath[BUFSIZE];

                         /* Go to the public files directory */
                         chg_to_dir (address, FALSE);

                         wtlog (address, lp);

                         if ((msg = creat_temp (tempfile)) == NULL)
                              continue;

                         writeheader (msg, address, lp, TRUE);
 
                         /* check for any "funny business".  changed --REB */
                         fileOK = pathallowed (words[1]);

                         if (fileOK)
                           {
                              sprintf (filepath, "%s%s",
                                       words[1][0] == '/' ? "." : "",
                                       words[1]);

                              if ((fileOK = isbin (filepath, tempfile)) == FALSE)
                                   fileOK = fileapnd (filepath, tempfile, TRUE);
                           }
                         else
                           {
                              warnadmin (address, lp);

                              /* tell the requester "sorry" */
                              msg = fopen (tempfile, "a");
                              fprintf (msg, "Could not find file: %s\n",
                                            words[1]);
                              fclose (msg);
                           }
                         sendmsg (address, tempfile);
                      }

                    /* command "submit <filename>" */
                    else if (strucmp (*words, "submit") == 0)
                      {
                         wtlog (address, lp);

                         if (submitOK)
                              acceptfile (address, words[1], lp);
                         else
                           {
                              rejectfile (address, lp);
                              unavailable (address, TRUE);
                              exit (0);
                           }
                      }
                    break;
            }
          firstcmd = FALSE;
       }
     free (fsdir);

     if (log != NULL)
          fclose (log);

     exit (0);
}



FILE *creat_temp (filename)
char *filename;
{
     FILE *msg;

     if ((msg = fopen (tempfile, "w")) == NULL)
          unlink (tempfile);

     return (msg);
}



int unavailable (address, submitfile)
char *address;
flag submitfile;
{
     char tmp[65];
     register FILE *msg;

     maketemp (tempfile, 'f');

     if ((msg = fopen (tempfile, "w")) == NULL)
       {
          unlink (tempfile);
          exit (0);
       }

     writeheader (msg, address, "Fileserver unavailable", FALSE);
     fprintf (msg, "Sorry, the fileserver is not %s now.",
                   submitfile ? "accepting files" : "available");

     fputs ("\n\nIf you have questions about the server or need help, you can send mail to:\n",
            msg);
     fprintf (msg, "%s!%s.\n\n", sitename, errorsto);
     fputs ("      Sincerely,\n", msg);
     fprintf (msg, "      %s!fileserv\n", nodename);
     fclose (msg);
     sendmsg (address, tempfile);
     exit (0);
}



void wtlog (address, command)
char *address, *command;
{
     static int firstpass = TRUE;
     char *gtime();

     if (firstpass)
       {
          sprintf (fname, "%s/FileServ", logdir);

          if ((log = fopen (fname, "a")) == NULL)
               return;

          firstpass = FALSE;
       }
     fprintf (log, "%s %s  (%s)\n", gtime(), address, command);
}



void writeheader (msgfile, address, subject, closefile)
register FILE *msgfile;
char *address, *subject;
flag closefile;
{
     struct sgtbuf date;

     getime (&date);

     fprintf (msgfile, "From FILESERV %s\n", date822());
     fprintf (msgfile, "From: OS-9 FileServer <%s!FILESERV>\n", sitename);
     fprintf (msgfile, "Message-Id: <%02d%02d%02d%02d%02d%02d.AA%05ld@%s>\n",
                       date.t_year, date.t_month, date.t_day, date.t_hour,
                       date.t_minute, date.t_second, getseq (MAILSEQ),
                       sitename);
     fprintf (msgfile, "Subject: %s\n", subject);
     fprintf (msgfile, "Reply-To: nobody@%s\n", sitename);
     fprintf (msgfile, "To: %s\n", address);
     fprintf (msgfile, "Date: %s\n", date822());
     fprintf (msgfile, "X-Fileserver: OS-9 FileServ -- Version %s (%s)\n\n",
                       version, VERDATE);
     if (closefile)
          fclose (msgfile);
}



/* We don't allow users to request directories or files above the allowed
   directory and its subdirectories, e.g. "../sys/password", /h1/tmp, etc.    
   If they try, they'll just get "not found".  A warning message is sent to
   the 'errorsto' user.  Paths starting with '/' may be in a subdirectory;
   Make the path name "./<pathname>" to test this.  Changed --REB  */

int pathallowed (path)
register char *path;
{
     char filepath[BUFSIZE+2], *p;

     p = filepath;

     /* Don't allow paths trying to backup one or more levels or paths such
        as /h1@.  If the path starts with '/' force it to be a subdirectory
        of where they are allowed.  */

     if (strcmp (path, ".") == 0)                       /* .       */
          return (FALSE);
     else if (strcmp (path, "..") == 0)                 /* ..      */
          return (FALSE);
     else if (findstr (1, path, "../") != 0)            /* ../path */
          return (FALSE);
     else if (findstr (1, path, "/..") != 0)            /* path/.. */
          return (FALSE);
     else if (strchr (path, '@') != NULL)               /* /path@  */
          return (FALSE);
     else if (*path == '/')                             /* /path   */
          strcat (strcpy (p, "."), path);
     else
          strcpy (p, path);                             /* path    */

     if ((access (p, S_IREAD) == ERROR)
          && (access (p, S_IFDIR | S_IREAD) == ERROR))
       {
          return (FALSE);
       }
     else
          return (TRUE);
}



/* get listing of the requested directory contents, if allowed. Added --REB */

int grabdir (path, dest)
char *path, *dest;
{
     char buff[128];
     FILE *msg, *pipein;
     char *cmd;
     register char *p;

     p = buff;

     /* force pathname to be in allowed directory or its subdirectories */
     if (*path == '.')
          *p = '\0';
     else if (*path == '/')
          strcpy (p, ".");
     else
          strcpy (p, "./");

     cmd = (char *) malloc (strlen (LSUTIL) + strlen (p)
                             + strlen (path) + 2);
     if (cmd == NULL)
       {
          unlink (tempfile);
          return (FALSE);
       }

     sprintf (cmd, "%s %s%s", LSUTIL, p, path);

     if ((msg = fopen (tempfile, "a")) == NULL)
       {
          free (cmd);
          unlink (tempfile);
          return (FALSE);
       }

     if ((pipein = popen (cmd, "r")) != NULL)
       {
          /* pipe the directory utility's standard output to the message */
          while (mfgets (p, sizeof (buff), pipein) != NULL)
               fprintf (msg, "%s\n", p);

          pclose (pipein);
       }
     else
       {
          /* tell the requester "sorry" */
          msg = fopen (tempfile, "a");
          fprintf (msg, "The directory \"%s\" could not be found.\n", path);
       }

     free (cmd);
     fclose (msg);
     return (TRUE);
}



/* Check to see if the filename has an extention and matches binary
   extentions in /DD/SYS/UUCP/bin.list.  */

int isbin (source, dest)
char *source, *dest;
{
     char buf[100];
     register char *p;
     FILE *fp;
     char *ext;
     int extlen;

     p = buf;

     /* do we have an extension in the filename? */
     if ((ext = strrchr (source, '.')) == NULL)
          return (FALSE);

     /* is this a binary file? */
     ++ext;
     extlen = strlen (ext);
     sprintf (p, "%s/bin.list", UUCPSYS);

     if ((fp = fopen (p, "r")) == NULL)
          return (FALSE);

     while (mfgets (p, sizeof (buf), fp) != NULL)
          if (strnucmp (p, ext, extlen) == 0)
            {
               fclose (fp);
               return (uuencodeit (source, dest));
            }
     fclose (fp);
     return (FALSE);
}



/* uuencode a file, use pipes to connect the input and output files --REB */

int uuencodeit (source, dest)
char *source, *dest;
{
     int result;
     register char *p;

     if (access (source, READ) == ERROR)
          return (FALSE);

     /* redirect the standard output */
     if (make_pipe (TRUE, dest) == FALSE)
          return (FALSE);

     p = strrchr (source, '/');
     sprintf (temp, "uuencode %s %s", source, source);
     result = docmd_na (temp);

     /* restore the standard output */
     make_pipe (FALSE, dest);
     return (result == 0 ? TRUE : FALSE);
}



/* close the standard output and open it to a file.  Added --REB */

int make_pipe (new_stdout, dest)
int new_stdout;
char *dest;
{
     static int saveout;
     int result;
     char *p;

     /* we want to change the standard output to a file? */
     if (new_stdout)
       {
          /* save standard output */
          saveout = dup (STDOUT);
     
          /* try to redirect standard output */
          close (STDOUT);
     
          if (open (dest, WRITE) != STDOUT)
            {
               fprintf (stderr,
                        "filserv: PANIC! make_pipe() can't redirect standard output to %s\n",
                        dest);
              dup (saveout);
              close (saveout);
              return (FALSE);
            }

          /* position standard out to the end of the file */
          lseek (STDOUT, _gs_size (STDOUT), FRONT);
          return (TRUE);
       }
     else
       {
          /* restore the standard output path */
          close (STDOUT);
          dup (saveout);
          close (saveout);
          return (TRUE);
       }
}



void warnadmin (who, request)
char *who, *request;
{
     register FILE *msg;

     maketemp (fname, 'w');

     if ((msg = fopen (fname, "w")) == NULL)
          return;

     writeheader (msg, errorsto, "WARNING--possible misuse of fileserver");

     if ((msg = fopen (fname, "a")) == NULL)
       {
          unlink (fname);
          return;
       }

     fputs ("FileServ received a questionable file transfer request.\n\n",
        msg);
     fprintf (msg, "Requested by:  %s\n", who);
     fprintf (msg, "Date:          %s\n", gtime());
     fprintf (msg, "Command:       %s\n\n", request);
     fputs ("This may be an attempt to get forbidden file, such as /DD/SYS/password, or\n",
            msg);
     fputs ("simply a non-existent file or directory.  The latter could a typo on the\n",
            msg);
     fputs ("requester's part.\n\n", msg);
     fputs ("Just thought you would like to know.\n\n", msg);
     fputs ("\t\tFaithfully,\n", msg);
     fprintf (msg, "\t\t%s!fileserv\n", nodename);
     fclose (msg);

     sendmsg (errorsto, fname);
}



void sendmsg (address, tmpfile)
char *address;
register char *tmpfile;
{
     char cmd[128];
     int result;

     sprintf (cmd, "rmail %s %s", tmpfile, address);

     if ((result = docmd_na (cmd)) != 0)
       {
          sprintf (cmd, "unable to fork RMAIL...error %d", result);
          wtlog (address, cmd);
       }
     unlink (tmpfile);
}



/* Read in a file being sent to us.  Move it to our incoming directory.  If
   it is uuencoded, run uudecode on it first. */

int acceptfile (sender, filename)
char *sender, *filename;
{
     /* Go to incoming directory */
     chg_to_dir (sender, TRUE);

     /* Not written yet. For now we reject submissions */
     informadmin (sender, filename);
}



/* Tell the system admin an incoming file arrived. */

int informadmin (sender, file)
char *sender, *file;
{
     /* not written yet */
}



/* Not taking submit files.  Dump them in the bit bucket and tell the
   sender "sorry". */

void rejectfile (sender, command)
char *sender, *command;
{
     register FILE *msg;

     /* bit bucket the file */
     flushbits();

     maketemp (fname, 's');

     if ((msg = fopen (fname, "w")) == NULL)
       {
          unlink (fname);
          return;
       }
     writeheader (msg, sender, "WARNING--attempt to submit a file");

     if ((msg = fopen (fname, "a")) == NULL)
       {
          unlink (fname);
          return;
       }

     fprintf (msg, "A request to submitted a file was received on %s.  The request\n",
                    gtime());
     fprintf (msg, "came from: %s\n\n", sender);
     fputs ("FileServ is currently set to reject incoming files.  The full command was:\n\n", msg);
     fputs (command, msg);
     fputs ("\n\n\t\tFaithfully,\n", msg);
     fprintf (msg, "\t\t%s!fileserv\n", nodename);
     fclose (msg);
     sendmsg (errorsto, fname);
}



/* Change to the fileserver's incoming directory if 'submitfile' is TRUE.
   Otherwise, change to the public files directory. */

void chg_to_dir (address, submitfile)
char *address;
flag submitfile;
{
     /* change to the file server's directory */
     if (chdir (submitfile ? incomedir : fsdir) == ERROR)
       {
          char tmp[65];

          free (submitfile ? incomedir : fsdir);
          sprintf (tmp, "can't change to %s directory",
                        submitfile ? "incoming" : "fileserver");

          wtlog ("fileserv", tmp);
          unavailable (address, submitfile);
       }
}



/* bit bucket anything left on the standard input */

void flushbits()
{
     char buff[BUFSIZE];
     register char *p;
     int count;

     p = buff;

     while ((count = fread (p, sizeof (char), BUFSIZE, stdin)) != 0)
          /* do nothing */ ;
}



void fatal (msg)
register char *msg;
{
     fprintf (stderr, "fileserv: %s\n", msg);
     myinterrupt (0);
}


