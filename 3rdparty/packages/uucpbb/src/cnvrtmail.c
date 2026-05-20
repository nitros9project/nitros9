/*
** This utility converts the spooled mail format from Rick Adams' uucp mailer
** (v4.2 and earlier) to a new format used by MAIL and RMAIL.  The original
** format kept all mail in the file ../MAIL/<user>.  The new format keeps all
** the mail in the *directory* ../MAIL/<user>.  The difference is that each
** message is kept as an individual file.  This makes the code for MAIL and
** RMAIL simpler.  One can easily delete and read mail in reverse order
** without needing to shuffle lots files around on the CoCo.
**
** Written by Bob Billson <bob@kc2wz.bubble.org>  1992 Mar 2
**
** This program requires Carl Kreider's CLIB.L to compile.
*/

#define MAIN

#include "uucp.h"
#include <password.h>
#include <time.h>
#include <modes.h>
#include "dir_6809.h"

#define REALNAMESIZE  18
#define STRINGSIZE    36

QQ char *mail_list = "mail..list";
QQ int deleteold;
QQ FILE *log;                                         /* dummy variables to */
char fname[100];                                      /* keep docmd.c happy */
char rootdir[4];
char *strupr(), *strlwr();
unsigned who_owns_the();

struct {
     char name[PWNSIZ+1];
     int id;
  } users[PWEMAX];



main (argc, argv)
int argc;
char *argv[];
{
     char line[PWSIZ+1], *p, *p2;
     register FILE *pwfile;
     int i;

     pflinit();                        /* tell compiler longs will be used */
     deleteold = FALSE;                /* don't delete old mail file */
     i = 0;
     log = stderr;                     /* don't log error, show them */

     if (getuid() != 0)
          fatal ("Sorry only the superuser can run this program");

     if (argc > 1) 
          if (strcmp (argv[1], "-k") == 0)         /* remove old mail file */
               deleteold = TRUE;
          else if (strcmp (argv[1], "-o") == 0)    /* convert v5.0 to 5.1+ */
            {
               cnvrtUUCPbb();
               exit (0);
            }
          else
               usage();

     if ((pwfile = fopen (PASSWORD, "r")) == NULL)
          fatal ("cannot open password file");

     if ((maildir = getenv ("MAIL")) != NULL)
          maildir = strdup (maildir);
     else
          fatal ("MAIL environment undefined");

     while ((fgets (line, sizeof (line), pwfile) != NULL)  &&  (i < PWEMAX))
       {
          if ((p = strchr (line, OS9DLM)) == NULL)
               pwerror();

          *p = '\0';
          strcpy (users[i].name, line);
 
          /* skip password entry */
          ++p;

          if ((p = strchr (p, OS9DLM)) == NULL)
               pwerror();

          /* point to uid field */
          p2 = ++p;

          if ((p = strchr (p2, OS9DLM)) == NULL)
               pwerror();

          *p = '\0';
          users[i++].id = atoi (p2);
       }

     fclose (pwfile);

     /* what device is the mail directory on? */
     strncpy (rootdir, maildir, 3);
     rootdir[3] = '\0';

     chdir (maildir);
     user_ok (i);
     make_dirs (i);
     makesequencefiles();
     free (maildir);
     puts ("\nConversion finished.  Mail is now in the new format.\n");
}



/* double-check to be sure each user is an actual user not a remote system */
int user_ok (last_user)
int last_user;
{
     register int i;
     char c, *answers;
     
     answers = malloc (last_user * sizeof (char));

     if (answers == NULL)
          fatal ("user_ok() can't malloc answers array");

     for (;;)
       {
          puts ("\fVerify that these users are valid to RECEIVE mail on this system:");

          for (i = 0; i < last_user; ++i) 
            {
               do
                 {
                    printf ("\nIs '%s' a valid mail user?  y/n --> ",
                             users[i].name);

                    fflush (stdout);
                    read (0, &c, 1);
                    tolower (c);
                 }
               while (c != 'y'  &&  c != 'n');

               answers[i] = c;
            }

          fputs ("\n\nAre all these correct?  ", stdout);
          fflush (stdout);
          read (0, &c, 1);

          if (tolower (c) == 'y')
               break;
       }

     /* ignore bad user names */
     for (i = 0; i < last_user; ++i)
          if (answers[i] == 'n')
               users[i].name[0] = '\0';

     free (answers);
     putchar ('\f');
}



int make_dirs (last_user)
int last_user;
{
     register int i = 0;
     char temp[100], mailpath[80];
     int path, success, mailwaiting;
     FILE *infile;

     while (i < last_user)
       {
          /* be sure we are superuser */
          asetuid (0);

          if (users[i].name[0] == '\0')
            {
               ++i;
               continue;
            }

          /* move the original mail file to the root directory.  If there */
          /* is no mail file, then there is no mail waiting for this user */

          if ((infile = fopen (users[i].name, "r")) == NULL)
               mailwaiting = FALSE;
          else
            {
               mailwaiting = TRUE; 
               sprintf (mailpath, "%s/%s.oldmail", rootdir, users[i].name);
               printf ("\ncopying original mail file to '%s'...", mailpath);
               fflush (stdout);
               filemovf (infile, mailpath);
               setnewowner (mailpath, users[i].id);

               /* make sure we can read the mail */
               path = open (mailpath, 2);
               _ss_attr (path, S_IREAD|S_IWRITE);
               close (path);

               /* remove the original mail file */
               unlink (users[i].name);
            }

          /* Make a mail directory for each user with the user as the owner */
          printf ("\nmaking mail directory for '%s'...", users[i].name);
          fflush (stdout);
          mknod (strupr (users[i].name), S_IREAD|S_IWRITE|S_IEXEC);
          strlwr (users[i].name);
          setnewowner (users[i].name, users[i].id);
          putchar ('\n');

          /* if there is spooled mail, convert it to the new format */
          if (mailwaiting)
            {
               success = cnvrtmail (i);

               /* back to being superuser */
               asetuid (0);

               /* do we get rid of the old mail? */
               if (success  &&  deleteold)
                 {
                    printf ("      ...deleting old mail file: %s", mailpath);
                    fflush (stdout);

                    if (unlink (mailpath) == NULL)
                         putchar ('\n');
                    else
                         printf ("...can't delete the file, error %d\n", errno);
                 }
               else
                    printf ("left old mail file as '%s'.\n",
                                mailpath);
            }
          else
            {
               /* no waiting mail to convert */
               printf ("user '%s' has no waiting mail to process\n",
                         users[i].name);
            }

          asetuid (0);
          putchar ('\n');
          ++i;
       }
}



/* Convert mail to new format.  Returns FALSE if error occurred, TRUE
** otherwise.
*/

int cnvrtmail (uindex)
int uindex;
{
     FILE *infile, *outfile;
     char line[256], temp[100], mailpath[80], fname[128];
     struct sgtbuf date;
     register int count;
     long nowtime;
     static long prevtime = 0L;
     int done;

     fputs ("converting mail to new format...", stdout);
     fflush (stdout);

     /* open the old format mail file */
     sprintf (mailpath, "%s/%s.oldmail", rootdir, users[uindex].name);

     if ((infile = fopen (mailpath, "r")) == NULL)
       {
          printf ("\nError converting mail for '%s'.\n", users[uindex].name);
          return (FALSE);
       }

     if (mfgets (line, sizeof (line), infile) != NULL) 
       {
          fputs ("messages converted:    ", stdout);
          fflush (stdout);
       }

     /*
      * Go through the entire spooled mail file.  Put each message in a
      * separate file in the new mail directory.  Each message is given the
      * name 'mYYYYMMDDHHMMSS'.
      */

     count = 0;
     done = FALSE;

     while (!done)
       {
          /* be sure we are superuser */
          asetuid (0);

          /* beginning of message? */
          if (strncmp (line, ">From ", 6) == 0
              || strncmp (line, "From ", 5) == 0)
            {
               for (;;)
                 {
                    getime (&date);
                    nowtime = o2utime (&date);

                    /* don't give two messages the same file name */
                    if (nowtime != prevtime)
                         break;

                    sleep (1);
                 }

               prevtime = nowtime;

               /* Account for change of century just in case this code */
               /* is still being used after 1999. <grin>               */

               sprintf (fname, "%s/m%s%02d%02d%02d%02d%02d%02d",
                        users[uindex].name,
                        date.t_year > 90  &&  date.t_year <= 99 ? "19" : "20",
                        date.t_year, date.t_month, date.t_day, date.t_hour,
                        date.t_minute, date.t_second);


               if ((outfile = fopen (fname, "w")) == NULL)
                 {
                    sprintf (temp, "\nerror processing mail for %s...can't create '%s'...error %d",
                               users[uindex].name, fname, errno);
                    fatal (temp);
                 }

               fixperms (outfile);

               /* send out the first line */
               if (line[0] != '>')
                    fprintf (outfile, ">%s\n", line);
               else
                    fprintf (outfile, "%s\n", line);

               /* move the rest of the messsage */
               if (copymsg (infile, outfile, line))  
                    fclose (outfile);

               setnewowner (fname, users[uindex].id);
               printf ("\b\b\b%3d", ++count);
               fflush (stdout);
            }
          else
               done = TRUE;
       }

     fclose (infile);

     /* create the mail..list file in the user's mail directory */
     fputs ("\ncreating user's 'mail..list' file...", stdout);
     fflush (stdout);
     rebuildmail (count, users[uindex].name, users[uindex].id);
     putchar ('\n');

     /* back to super user */
     asetuid (0);
     return (TRUE);
}



int copymsg (in, out, line)
register FILE *in;
FILE *out;
char *line;
{
     register char *p;
     char temp[256];

     p = temp;

     while (mfgets (p, sizeof (temp), in) != NULL)
       {
          /* beginning of next message? */
          if (((strncmp (p, "From ", 5) == 0)
              || (strncmp (p, ">From ", 6) == 0))  && p)
            {
               strcpy (line, p);
               return (TRUE);
            }
          else
               fprintf (out, "%s\n", p);
       }
     line[0] = '\0';
     return (FALSE);
}



/* 
** Copy old /dd/MAIL/sequence to /DD/SYS/UUCP/sequence.mail.  Create new other
** sequence files.
*/

int makesequencefiles()
{
     char line[100];
     FILE *old, *new;
     int newsequence = FALSE,
         sequence;

     fputs ("updating news and mail sequence files...", stdout);
     fflush (stdout);

     /*
     ** rename the news sequence file, /DD/SYS/UUCP/sequence to 
     ** /DD/SYS/UUCP/sequence.news
     */

     asetuid (0);
     sprintf (line, "rename %s/sequence %s", UUCPSYS, NEWSEQ);
     docmd_na (line);

     /* now move the mail sequence file to /DD/SYS/UUCP/sequence.mail */
     if ((new = fopen (MAILSEQ, "w")) == NULL)
       {
          sprintf (line, "can't create %s...error %d", MAILSEQ, errno);
          fatal (line);
       }

     /* try to find the old sequence file */
     sprintf (line, "%s/sequence", maildir);

     if ((old = fopen (line, "r")) == NULL)
          newsequence = TRUE;

     if (!newsequence)
       {
          if (fgets (line, sizeof (line), old) != NULL)
               sequence = atoi (line);
          else
               sequence = 0;
       }
     else
          sequence = 0;

     /* copy it to the new sequence file */
     fprintf (new, "%ld", sequence);
     fclose (old);

     /* make it secure */
     fixperms (new);
     fclose (new);

     /* remove the old sequence file */
     sprintf (line, "attr %s/sequence w", maildir);

     if (docmd_na (line) == 0)
        {
          sprintf (line, "%s/sequence", maildir);
          unlink (line);
       }
     else
          printf ("\ncould not find and deleted old sequence file '%s/sequence'\n",
                   maildir);

     /* create the spool sequence file */
     if ((new = fopen (GENSEQ, "w")) == NULL)
       {
          sprintf (line, "\ncan't create %s...error %d", GENSEQ, errno);
          fatal (line);
       }

     /* and initialize it */
     fputs ("0000", new);
     fclose (new);
     putchar ('\n');
}



int setnewowner (file_or_dir, owner)
char *file_or_dir;
unsigned owner;
{
     struct fildes fd;
     register int path;

     asetuid (0);

     if (((path = open (file_or_dir, S_IWRITE)) == ERROR)  &&
            ((path = open (file_or_dir, S_IFDIR | S_IWRITE)) == ERROR))
       {
          fprintf (stderr, "setnewowner(): can't open path to '%s'\n", 
                     file_or_dir);
          return (FALSE);
       }

     if (_gs_gfd (path, &fd, sizeof (struct fildes)) == ERROR)
       {
          close (path);
          return (FALSE);
       }

     /* set new owner */
     fd.fd_own = owner;

     /* update the file descriptor */
     if (_ss_pfd (path, &fd) == ERROR)
       {
          close (path);
          return (FALSE);
       }

     close (path);
     return (TRUE);
}



/* make slight update in Bob Billson's UUCPbb mail and mail..list files */

int cnvrtUUCPbb()
{
     char dirname[200], mbox[100];
     unsigned owner;
     DIR *dir;
     struct direct *dirptr;                      /* defined in dir.h -- REB */

     if ((dir = opendir (maildir)) == NULL)
       {
          sprintf (mbox, "ERROR--can't open %s", maildir);
          fatal (mbox);
       }

     putchar ('\n');

     /* loop through each directory in ./SPOOL/MAIL */ 
     while ((dirptr = readdir (dir)) != NULL)
       {
          if (dirptr->d_name[0] == '.')
               continue;

          strcpy (mbox, dirptr->d_name);
          sprintf (dirname, "%s/%s", maildir, mbox);
          printf ("updating mail for '%s'...", mbox);
          fflush (stdout);

          /*************************************************\
          * change to the mail directory for the system and *
          * look for mail to convert.                       *
          \*************************************************/

          owner = who_owns_the (dirname);

          if (chdir (dirname) != ERROR)
               updatemail (mbox, owner);
          else
               printf ("ERROR--can't change to %s's directory...continuing",
                        dirname);
       }
     closedir (dir);
}



int updatemail (username, owner)
char *username;
unsigned owner;
{
     FILE *old, *new;
     DIR *dp;                                  /* defined in dir.h */
     register struct direct *dirbuf;           /*                  */
     char oldfilename[80], newfilename[80], buff[256], cmd[128];
     int mailcount;

     /* remove the old mail..list file if it exists */
     unlink (mail_list);

     /*****************************************************************
      * open mail directory; exit on error.  Our current data directory
      * should already be the correct spool directory for this user.
      *****************************************************************/

     if ((dp = opendir (".")) == NULL)
          fatal ("updatemail(): not enough memory to read directory");

     /* scan the directory */
     mailcount = 0;
     fputs ("messages converted:    ", stdout);
     fflush (stdout);

     while ((dirbuf = readdir (dp)) != NULL)
       {
          if (dirbuf->d_name[0] == '.')
               continue;

          strcpy (oldfilename, dirbuf->d_name);
          printf ("\b\b\b%3d", mailcount);
          fflush (stdout);

          if ((old = fopen (oldfilename, "r")) == NULL)
            {
               fprintf ("can't open mail '%s' for reading\n", oldfilename);
               --mailcount;
               continue;
            }

          /* get the first line -- >From or From */
          if (mfgets (buff, sizeof (buff), old) == NULL)
            {
               fclose (old);
               unlink (oldfilename);
               printf ("\n'%s' is an empty file...deleting it\n",
                        oldfilename);

               printf ("messages converted: %3d", mailcount);
               fflush (stdout);
               --mailcount;
               continue;
            }

          /* already >From ? */
          if (buff[0] == '>')
            {
               fclose (old);
               ++mailcount;
               continue;
            }

          sprintf (newfilename, "%s.tmp", oldfilename);

          /* new letter file */
          if ((new = fopen (newfilename, "w")) != NULL)
            {
               setnewowner (newfilename, owner);
               fixperms (new);
            }
          else
            {
               fprintf (stderr, "can't create new mail file '%s'\n",
                         newfilename);
               continue;
            }

          /* convert From to >From */
          fprintf (new, ">%s\n", buff);

          /* copy the rest of the message unchanged */
          fastcopy (old, new, FALSE, FALSE);

          /* don't need the old mail file anymore */
          unlink (oldfilename);

          /* rename the new one */
          sprintf (cmd, "rename %s %s", newfilename, oldfilename);

          if (docmd_na (cmd) != 0)
               fprintf (stderr, "can't rename %s to %s...error #%d\n",
                                oldfilename, newfilename, errno);
          ++mailcount;
       }

     closedir (dp);

     /*******************************************************************\
     * back up to ./SPOOL/MAIL directory. rebuildmail() expects us there *
     * and create the mail..list file in the user's directory            *
     * when we return from rebuildmail we will be back in ./SPOOL/MAIL   *
     \*******************************************************************/

     chdir ("..");

     if (mailcount > 0)
       {
          fputs ("\n         rebuilding 'mail..list' file...", stdout);
          fflush (stdout);
          rebuildmail (verifycount (username), username, owner);
       }

     puts ("\n");
}



unsigned who_owns_the (file_or_dir)
char *file_or_dir;
{
     struct fildes buffer;
     register int path;

     asetuid (0);

     if (((path = open (file_or_dir, S_IWRITE)) == ERROR)  &&
            ((path = open (file_or_dir, S_IFDIR | S_IWRITE)) == ERROR))
       {
          fprintf (stderr, "who_owns_the(): can't open path to '%s'...error %d\n", 
                     file_or_dir, errno);
          exit (0);
       }

     if (_gs_gfd (path, &buffer, sizeof (struct fildes)) == ERROR)
       {
          fprintf  (stderr, "who_owns_the(): can't get file descriptor...error #%d\n", errno);
          exit (0);
       }

     close (path);
     return (buffer.fd_own);
}



int rebuildmail (mailcount, username, userid)
int mailcount;
char *username;
unsigned userid;
{
     FILE *mptr, *lptr;
     DIR *dirptr;
     struct direct *mbox;                        /* defined in dir.h -- REB */
     register int i;
     char temp[128];
     static struct mbag  {
                char letter[32];
              } *ltrs;

     ltrs = (struct mbag *) malloc (mailcount * sizeof (struct mbag));

     if (ltrs == NULL)
          fatal ("rebuildmail() can't malloc() ltrs array");

     asetuid (0);
     chdir (username);
     dirptr = opendir (".");

     if (dirptr == NULL)
          fatal ("rebuildmail() not enough memory for mailbox directory (too many letters)");

     /* read in the letter filenames */
     i = 0;

     while ((mbox = readdir (dirptr)) != NULL)
          if (mbox->d_name[0] != '.')
               strcpy (ltrs[i++].letter, mbox->d_name);

     closedir (dirptr);
     qsort (ltrs, mailcount, sizeof (struct mbag), strucmp);

     if ((mptr = fopen (mail_list, "w")) == NULL)
       {
          fputs ("rebuildmail() can't create 'mail..list'\n", stderr);
          exit (0);
       }

     /* make sure the same owner owns new mail..list file */
     chown (mail_list, userid);

     /* make sure nobody else can mess with us for now */
     _ss_attr (fileno (mptr), S_ISHARE|S_IREAD|S_IWRITE);

     for (i = 0; i < mailcount; ++i)
          if ((lptr = fopen (ltrs[i].letter, "r")) == NULL)
            {
               fprintf (stderr, "rebuildmail(): can't open '%s'\n",
                                ltrs[i].letter);
               continue;
            }
          else
            {
               getheader (lptr, mptr, ltrs[i].letter);
               fclose (lptr);
            }

     free (ltrs);

     /* for our eyes only */
     fixperms (mptr);
     fclose (mptr);
     free (ltrs);
     chdir ("..");
}



int getheader (fp, mptr, filename)
FILE *fp, *mptr;
char *filename;
{
     char mline[256], subj[28], frm[27], resentfrm[128], resentrply[128];
     register char *p;
     int linecount;
     long _gs_size();
     char *getval(), *getstring();

     subj[0] = frm[0] = resentfrm[0] = resentrply[0] = '\0';
     p = mline;

     while (mfgets (mline, sizeof (mline), fp) != NULL  &&  *p)
          if (*p == 'F' &&  strnucmp ("From: ", p, 6) == 0)
               strncpy (frm, getval (p), sizeof (frm));
          else if (*p == 'R')
            {
               if (strnucmp (p, "Resent-From: ", 13) == 0)
                 {
                    strcpy (resentfrm, getval (p));
                    resentfrm[sizeof (frm) - 1] = '\0';
                 }
               else
                    if (strnucmp (p, "Resent-Reply-To: ", 17) == 0)
                      {
                         strcpy (resentrply, getval (p));
                         resentrply[sizeof (resentrply) - 1] = '\0';
                      }
            }
          else if (*p == 'S'  && (strncmp ("Subject: ", p, 9) == 0)
                              || (strncmp ("Subj: ", p, 6) == 0))
            {
               strncpy (subj, getstring (p), sizeof (subj));
               subj[sizeof (subj) - 1] = '\0';
            }

     if (resentrply[0] != '\0')
          strncpy (frm, resentrply, sizeof (frm));
     else
          if (resentfrm[0] != '\0')
               strncpy (frm, resentfrm, sizeof (frm));

     /* make sure frm is terminated properly */
     frm[sizeof (frm) - 1] = '\0';

     /* count the lines */
     p = mline;
     linecount = 0;

     while (mfgets (p, sizeof (mline), fp) != NULL)
          ++linecount;

     fprintf (mptr, "N%s|%s|%s|%d|%ld\n",
                    filename, frm[0] != '\0' ? frm : " ",
                    subj[0] != '\0' ? subj : " ",
                    linecount, _gs_size (fileno (fp)));
}



int verifycount (whosemail)
char *whosemail;
{
     DIR *dirptr;
     struct direct *list;                        /* defined in dir.h -- REB */
     register int count_1;

     chdir (whosemail);

     if ((dirptr = opendir (".")) == NULL)   
          fatal ("checkmail() can't open mailbox");

     /* now count our letters */
     count_1 = 0;

     while ((list = readdir (dirptr)) != NULL) 
          if (list->d_name[0] != '.') 
               ++count_1;

     closedir (dirptr);
     chdir ("..");
     return (count_1);
}



int pwerror()
{
     fatal ("error in password file entry");
}



int fatal (msg)
char *msg;
{ 
     fprintf (stderr, "cnvrtmail: %s\n", msg);
     exit (0);
}



int usage()
{
     register char **hlp;
     static char *helptxt[] = {
       "cnvrtmail: convert Rick's Adams spool mail format v4.2 and earlier to new",
       "           format",
       "Usage: cnvrtmail [opt]\n",
       "  opt: ",
       "       -k   = delete user's old mail file",
       "       -o   = update v5.0 to v5.1 format",
       NULL
     };

     for (hlp = helptxt; *hlp !=NULL; ++hlp)
          fprintf(stderr, "%s\n", *hlp);

     exit (0);
}
