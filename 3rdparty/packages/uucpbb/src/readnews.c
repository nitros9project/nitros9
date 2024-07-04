/*  readnews.c   The main program to read Usenet news.
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

#define MAIN

#include "uucp.h"
#ifndef _OSK
#include <os9.h>
#endif
#include <ctype.h>
#include <modes.h>
#include <sgstat.h>
#include <direct.h>

#define ON           1
#define OFF          0
#define MAILER     "mailx"

extern char temp[], fname[];
extern QQ flag auto_rot;
extern QQ unsigned myuid;

QQ FILE *log;
QQ int debuglvl = 0;
QQ int columns, rows, ngroups, curgroup;
QQ flag rot13, valid;
#ifndef TERMCAP
QQ flag t2flag, winopen;
#endif
struct active groups[MAXNEWSGROUPS];
struct Newsrc newsrc[MAXNEWSGROUPS];
char article[20], reference[256], subject[256], returnpath[512];
char sender[512], line[512], newsgroup[100];
char *getword(), getresponse(), *getarticlepath(), *fixgroupname();
char *mailer = MAILER;


int main(argc, argv)
int argc;
char *argv[];
{
     static char newsrcfile[100];
     char sub;
     register int i;
     int count, index, j, c, myinterrupt();
     FILE *file;

     homedir = NULL;
     log = stderr;

     if (argc > 1)
          usage();

     intercept (myinterrupt);

     if (getparam() == FALSE)
          exit (0);

     userparam();

     if ((newsdir = getdirs ("newsdir")) == NULL)
          fatal ("newsdir not in Parameters");

#ifndef TERMCAP
     t2flag = t2test();
     winopen = FALSE;
#else
     init_term_cap();
#endif

     getscreensize();

     /* init in-core newsgroups list from active file, release active file */
     if (readactive (S_IREAD|S_ISHARE) == FALSE)
          exit (0);

     closeactive();

     /* init newsrc from active file info.  Handle special case of empty group
        The "-1" puts the default newsrc index one below the lowest existing
        article.  */

     for (i = 0; i < ngroups; i++)
       {
          strcpy (newsrc[i].newsgroup, groups[i].newsgroup);
          newsrc[i].index = groups[i].index - 1;
          newsrc[i].sub = NEWGROUP;
       }

     /* Update in-core newsgroup indexes from user's newsrc for index, use
        lowest avail. article # - 1 if higher than newsrc #. */

#ifdef _OSK
     sprintf (newsrcfile, "%s/%s", homedir, _NEWSRC);
#else
     sprintf (newsrcfile, "%s/%s/%s", homedir, uudir, _NEWSRC);
#endif

     if ((file = fopen (newsrcfile, "r")) != NULL)
       {
          while (fscanf (file, "%100[^:!]%c 1-%d ", newsgroup, &sub, &index)
                    != EOF)
            {
               i = findgroup (newsgroup, TRUE);
               strcpy (newsrc[i].newsgroup, newsgroup);
               newsrc[i].index = max (index, newsrc[i].index);
               newsrc[i].sub = sub;
            }
          fclose (file);
       }
     else
       {
          /* Silently subscribe to newsgroups if new newsrc */
          for (i = 0; i < ngroups; i++)
               if (findstr (1, groups[i].newsgroup, "junk") != 0)
                    newsrc[i].sub = UNSUBSCRIBED;
               else if (findstr (1, groups[i].newsgroup, ".test") != 0)
                    newsrc[i].sub = UNSUBSCRIBED;
               else
                    newsrc[i].sub = SUBSCRIBED;

          /* display help file for new users */
          sprintf (temp, "%s", NEWSHELP);

          if ((file = fopen (temp, "r")) != NULL)
            {
               putchar ('\n');

               while (fgets (line, sizeof (line), file) != NULL)
                    printf ("%s", line);

               fclose ( file);
               fputs ("Press any key to continue: ", stdout);
               fflush (stdout);
               getresponse();
               puts ("\n");
            }
        }

     /* check for new newsgroups */
     for (i = 0; i < ngroups; i++)
          if (newsrc[i].sub == NEWGROUP)
            {
               printf ("New newsgroup: %s--Subscribe? [yn] ",
                       groups[i].newsgroup);

               fflush (stdout);
               sub = getresponse();
               putchar ('\n');
               newsrc[i].sub = (tolower(sub) == 'y') ? SUBSCRIBED
                                                     : UNSUBSCRIBED;
            }

     /* summary of unread news */
     for (i = 0; i < ngroups; i++)
          if (newsrc[i].sub == SUBSCRIBED)
            {
               count = groups[i].seq - newsrc[i].index;

               if (count > 0)
                    printf ("Unread news in %-25s %4d articles\n",
                              groups[i].newsgroup, count);
            }
     putchar ('\n');

     /* cycle through available newsgroups */
     for (i = 0; i < ngroups; i++)
       {
          curgroup = i;

          if (newsrc[i].sub == SUBSCRIBED)
               c = readgroup();

          switch (c)
            {
               case 'q':                          /* quit */
                    i = ngroups;                  /* Added BRT */
                    break;

               case 'p':                          /* previous newsgroup */
                    for (j = i - 1; j != i; j--)
                      {
                         if (j < 0)
                              j = ngroups - 1;

                         if (groups[j].seq > newsrc[j].index)
                           {
                              i -= j - 2;           /* Added BRT */
                              break;
                           }
                      }
                    break;

               default:
                    i = curgroup;
                    break;
            }

          /* Are we done? */
          if (i == ngroups - 1)
            {
               curgroup = ngroups;
               c = readgroup();
               i = curgroup;

               if (c != 'p'  &&  c != 'q'  &&  c != ' '  &&  i == ngroups)
                    i = -1;

               /* If they pressed SPACE, quit if all is read */
               if ((c == ' ') && (i == ngroups))
                 {
                    for (j = 0; j < ngroups; j++)
                         if (groups[j].seq != newsrc[j].index)
                              break;

                    /* Wrap if anything unread */
                    if (j < ngroups)
                         i = -1;
                 }
            }
       }
     cls();                                             /* Added BRT */
     fputs ("updating newsrc...", stdout);
     fflush (stdout);

     /* save a copy of the old newsrc file */
#ifdef _OSK
     sprintf (fname, "%s", homedir);
#else
     sprintf (fname, "%s/%s", homedir, uudir);
#endif
     if (chdir (fname) == -1)
       {
          char tmp[80];

          sprintf (tmp, "can't change to: %s\n", fname);
          fatal (tmp);
       }
#ifndef _OSK
     filemove ("newsrc", "oldnewsrc");
#else
     filemove (".newsrc", ".oldnewsrc");
#endif

     /* so the file can be opened - BAS */
     asetuid (0);

     /* update the newsrc file */
     if ((file = fopen (newsrcfile, "w+")) == NULL)         /* changed BRT */
#ifdef _OSK
          fatal ("can't update .newsrc file");
#else
          fatal ("can't update newsrc file");
#endif

     /* change the ownership of the file and reset uid -- BAS */
     chown (newsrcfile, myuid);
     asetuid (myuid);

     for (i = 0; i < ngroups; i++)
          fprintf (file, "%s%c 1-%d\n",
                         newsrc[i].newsgroup,
                         newsrc[i].sub,
                         newsrc[i].index);
     fclose (file);
     cls();
}



int readgroup()
{
     char c, *sb, *cr, *groupname, **hptr, tmp[60];
     char *ptr;                                         /* Added BTR */
     register int i;
     int seq, indx;
     static char *help1[] = {
                       "ENTER/SPACE  Read unread article",
                       "c\t\tCatch-up, mark all articles read",
                       "d\t\tDirectory of groups",
                       "g <group>    Goto newsgroup <group>",
                       "h or ?       Help",
                       "n\t\tNo, skip this group",
                       "p\t\tPrevious group",
                       "q\t\tQuit",
                       "s <group>    Subscribe to newsgroup <group>",
                       "u [<group>]  Unsubscribe from newsgroup <group>",
                       "\t\t   default is current newsgroup",
                       "y\t\tYes, read unread article",
                       "!\t\tFork a shell",
                       NULL
                    },

                 *help2[] = {
                       "SPACE/n/y  Start over, read new news",
                       "d\t    Directory of groups",
                       "g <group>  Goto newsgroup <group>",
                       "h\t    Help",
                       "q\t    Quit",
                       "s <group>  Subscribe to the <group>",
                       "u <group>  Unsubscribe from <group>",
                       NULL
                    };

     if (curgroup < ngroups)
       {
          seq = groups[curgroup].seq;
          indx = newsrc[curgroup].index;
       }

     c = '\0';

     while (seq > indx || curgroup == ngroups)
       {
          char ch, *ngrp;

          ngrp == NULL;

          if (curgroup == ngroups)
            {
               ReVOn();
               fputs ("**** End of newsgroups [yq] ", stdout);
               ReVOff();
            }
          else
            {
               ReVOn();
               printf ("**** %d articles unread in newsgroup %s--read now? [yncpq] ",
                       seq-indx, newsrc[curgroup].newsgroup);
               ReVOff();
            }

          fflush (stdout);
          c = getresponse();
          ch = c = tolower (c);      /* 'ch' is temp used only in switch() */

          /* Done? */
          if (curgroup == ngroups)
            {
               if (c == 'c')
                    ch = '*';                         /* Illegal command */
               else if (strchr ("qyn ", c) != NULL)
                 {
                    putchar ('\n');
                    return (c);
                 }
               else if (strchr ("h?", c) != NULL)
               ch = 'H';                          /* Different help */
                    /* Fall through for d, g, h, ?, s, u or illegal */
            }

          switch (ch)
            {
               /* Read new articles */
               case 'y':
               case ' ':
               case '\n':
                    putchar ('\n');
                    asetuid (0);

                    if (chdir (newsdir) == -1)
                      {
                         char tmp[80];

                         sprintf (tmp, "readgroup() can't change to: %s\n",
                                        newsdir);
                         fatal (tmp);
                      }

                    asetuid (myuid);
                    strcpy (newsgroup, newsrc[curgroup].newsgroup);

                    if ((ngrp = fixgroupname (newsgroup)) != NULL)
                      {
                         makepath (ngrp);

                         if (ngrp != NULL)
                           {
                              free (ngrp);
                              ngrp = NULL;
                           }
                         dogroup (indx, seq);
                      }
                    break;

               /* Catch up */
               case 'c':
                    puts ("\nMarking all articles as read");
                    newsrc[curgroup].index = seq;
                    break;

               /* Directory of all groups */
               case 'd':
                    puts ("\n\n   Sub  #msg  #unread  Newsgroup");

                    for (i = 0; i < ngroups; i++)
                      {
                         cr = (i == curgroup) ? ">" : " ";
                         sb = (newsrc[i].sub == SUBSCRIBED) ? "S" : "U";
                         printf ("  %s %s  %5.5d   %5.5d   %-50.50s\n",                                           cr, sb,
                                   groups[i].seq - groups[i].index + 1,
                                   groups[i].seq - newsrc[i].index,
                                   newsrc[i].newsgroup);
                      }
                    break;

               /* Subscribe to given group */
               case 's':
                    groupname = getword();

                    if (*groupname == '\0'
                         || ((i = findgroup (groupname, FALSE)) == -1))
                      {
                         printf ("\nGroup %s not found\n", groupname);
                         break;
                      }

                    if (*groupname == '\0'  &&  curgroup == ngroups)
                      {
                         puts ("\nNo current newsgroup");
                         break;
                      }

                    printf ("Subscribing to group %s\n", newsrc[i].newsgroup);
                    newsrc[i].sub = SUBSCRIBED;
                    break;

               /* Unsubscribe from group */
               case 'u':
                    groupname = getword();
 
                    /* unsubscribe from current newsgroup? */
                    if (*groupname == '\0')
                         if (curgroup == ngroups)
                           {
                              puts ("\nNo current newsgroup");
                              break;
                           }
                         else
                              i = curgroup;

                    /* unsubscribe from specified newsgroup?* /
                    else if ((i = findgroup (groupname, FALSE)) == -1)
                      {
                         printf ("\nGroup %s not found\n", groupname);
                         break;
                      }

                    /* unsubscribe from group */
                    printf ("Unsubscribing from group %s\n",
                               newsrc[i].newsgroup);

                    newsrc[i].sub = UNSUBSCRIBED;

                    /* if current group, move to next group */
                    if (curgroup == i)
                         return ('n');

                    break;

               /* No, do not read new articles in this group */
               case 'n':
               case 'q':                          /* Quit */
               case 'p':                          /* Previous group */
                    putchar ('\n');
                    return (c);

               /* Goto group ____ */
               case 'g':
                    groupname = getword();

                    if (*groupname == '\0' ||
                          ((i = findgroup (groupname, FALSE)) == -1))
                      {
                         printf ("\nGroup %s not found\n", groupname);
                         break;
                      }

                    curgroup = i;
                    seq = groups[curgroup].seq;
                    indx = newsrc[curgroup].index;
                    asetuid (0);

                    if (chdir (newsdir) == -1)
                      {
                         char tmp[80];

                         sprintf (tmp, "readgroup(): can't change to: %s\n",
                                       newsdir);
                         fatal (tmp);
                      }
                    asetuid (myuid);
                    strcpy (newsgroup, newsrc[curgroup].newsgroup);

                    if ((ngrp = fixgroupname (newsgroup)) != NULL)
                      {
                         makepath (ngrp);

                         if (ngrp != NULL)
                           {
                              free (ngrp);
                              ngrp = NULL;
                           }
                         dogroup (indx, seq);
                      }
                    break;

               /* Help */
               case 'h':
               case '?':
#ifndef TERMCAP
                    if (!t2flag)
                      {
                         popdoublewindow (29, 0, 49, 15);
                         putdashs (47);
                      }
#endif
                    putchar ('\n');

                    for (hptr = help1; *hptr != NULL;  ++hptr)
                         printf (" %s\n", strdetab (strcpy (tmp, *hptr), 6));

#ifndef TERMCAP
                    if (!t2flag)
                      {
                         putdashs (47);
                         fflush (stdout);
                         ch = getresponse();
                         closedoublewindow();
                      }
                    else
#endif
                         putchar ('\n');
                    break;

               /* Help, when at end of newsgroups */
               case 'H':
#ifndef TERMCAP
                    if (!t2flag)
                      {
                         popdoublewindow (37, 0, 42, 9);
                         putdashs (40);
                      }
#endif
                    putchar ('\n');

                    for (hptr = help2; *hptr != NULL;  ++hptr)
                         printf (" %s\n", strdetab (strcpy (tmp, *hptr), 6));

#ifndef TERMCAP
                    if (!t2flag)
                      {
                         putdashs (40);
                         fflush (stdout);
                         ch = getresponse();
                         closedoublewindow();
                      }
                    else
#endif
                         putchar ('\n');
                    break;

               /* fork a shell */
               case '!':
                    forkshell();
#ifndef TERMCAP
                    if (!t2flag)
                         resetline();
                    break;
#endif

               /* Illegal command */
               default:
                    printf ("\nIllegal command: %c\n", c);
                    break;
            }
          seq = groups[curgroup].seq;
          indx = newsrc[curgroup].index;
       }
     return (c);
}



/* dogroup  --scan unread articles in a specific group
              If all articles read, just display prompt. */

int dogroup (index, seq)
int index, seq;
{
     register int i = index + 1;            /* Next unread article */
     char c = '\0';                         /* Need a prompt in newscmd() */
     char dspnews();

     /* If we got here by 'G'oto, and the group is fully read: */
     if (i == seq + 1)
          i = newscmd (c, seq);              /* i = 0 if Quit */

     rot13 = FALSE;

     while (i <= seq && i > 0)
       {
          /* display article */
          if ((c = dspnews (i)) == -1)          /* If unavailable, skip to  */
               if (++i <= seq)                  /* next.  When group empty, */
                    continue;                   /* force prompt.  */

          newsrc[curgroup].index = max (i, newsrc[curgroup].index);
          rot13 = FALSE;
          i = newscmd (c, i);                           /* i = 0 if Quit */

          /* in case new articles posted in newscmd */
          seq = groups[curgroup].seq;

          if (i == 0)
               break;
       }
}



char dspnews (artnum)
int artnum;
{
     register char *lp;
     int screenline, k;
     flag go_on, header;
     char **hptr, tmp[60];
     static char ref2[256];
     FILE *file;
     static char *help[] = {
                     "SPACE     Show next screen",
                     "n\t  Next article",
                     "c\t  Catch-up",
                     "p\t  Previous article",
                     "s <file>  Save article to <file>",
                     "w <file>  Save article to <file>",
                     "\t     without header",
                     "v or .    Redisplay current article",
                     "u\t  Redisplay current article,",
                     "\t     rot13'd (unrot)",
                     "q\t  Quit displaying article", 
                     "h or ?    Help",
                     NULL
                  };

     sprintf (article, "a%d", artnum);

     if ((file = fopen (article, "r")) == NULL)
       {
          /* unavailable article */
          printf ("Article %d of newsgroup %s unavailable\n",
                    artnum, newsgroup);

          newsrc[curgroup].index = max (artnum, newsrc[curgroup].index);
#ifdef _OSK
          sleep (1);
#else
          tsleep (60);
#endif    
          return (-1);
       }

     cls();
     ReVOn();
     printf ("Article %d of newsgroup %s (%d left):\n",
             artnum, newsgroup,
             max ((groups[curgroup].seq - newsrc[curgroup].index - 1), 0));

     ReVOff();
     *subject = *reference = *returnpath = *ref2 = *sender = '\0';
     header = TRUE;
     valid = FALSE;                  /* not known to be valid news article */
     screenline = 0;                 /* was 1.  changed --REB */
     lp = line;

     while (fgets (lp, sizeof (line), file) != NULL)
       {
          register char c;

          if (screenline > rows  ||  *lp == '\f')         /* was >= --REB */
            {
               go_on = FALSE;

               while (!go_on)
                 {
#ifndef TERMCAP
                    if (t2flag)
                         write (1, "\n--MORE--", 9);
                    else
                         write (1, "\n\x1F\x20 --MORE--\x1F\x21", 14);
#else
                    ReVOn();
                    printf(" --MORE--");
                    ReVOff();
                    fflush(stdout);
#endif
                    c = getresponse();
#ifndef TERMCAP
                    if (t2flag)
                         write (1, "\x0D", 1);
                    else
                         write (1, "\x0D\x1F\x31", 3);
#else
                    putchar ('\n');
                    DelLine();
#endif
                    screenline = 0;

                    switch (tolower (c))
                      {
                         case 'w':               /* Save without header */
                              fputs ("\nw", stdout);             /* REB */
                              goto goback;                       /*     */
                         case 's':               /* Save */
                              fputs ("\ns", stdout);
                         case 'n':               /* Next */
                         case 'c':               /* Catchup */
                         case 'p':               /* Previous */
                         case 'v':               /* Current */
                         case '.':               /* Current */
                         case 'u':               /* Current, rot13'd */
                         case 'q':               /* Quit displaying article */
goback:                       fclose (file);
                              return (c);

                         case 'h':               /* Help */
                         case '?':
#ifndef TERMCAP
                              if (!t2flag)
                                {
                                   popdoublewindow (9, 0, 54, 15);
                                   putdashs (40);
                                }
#endif
                              putchar ('\n');

                              for (hptr = help; *hptr != NULL; ++hptr)
                                   printf (" %s\n",
                                            strdetab (strcpy (tmp,*hptr), 7));
#ifndef TERMCAP
                              if (!t2flag)
                                {
                                    putdashs (40);
                                    fflush (stdout);
                                    c = getresponse();
                                    closedoublewindow();
                                }
                              else
#endif
                                   putchar ('\n');
                              break;

                         case ' ':               /* Next screen */
                              go_on = TRUE;
                              break;

                         default:
                              printf ("Illegal command: %c\n", c);
                              break;
                      }
                 }
            }
          fixline (line);
          screenline += (strlen (lp) / columns) + 1;

          /* If we're still looking at the header */
          if (header)
            {
               int printline = TRUE;

               /* don't display initial "Path:" line */
               if (strncmp (lp, "Path: ", 6) == 0)
                 {
                    printline = FALSE;
                    valid = TRUE;                    /* valid news article */
                 }

               /* extract "Subject:" */
               if (strncmp (lp, "Subject: ", 9) == 0)
                 {
                    strcpy (temp, getstring (line));

                    if (strnucmp (temp, "Re:", 3) != 0)
                         sprintf (subject, "Re: %s", temp);
                    else
                         strcpy (subject, temp);
                 }

               /* extract "Message-ID:" */
               if (strncmp (lp, "Message-ID: ", 12) == 0)
                 {
                    reference[0] = '<';
                    strcpy (&reference[1], getval (line));
                 }

               /* extract "References:" but don't display it. */
               if (strncmp (lp, "References: ", 12) == 0)
                 {
                    strcpy (ref2, getstring (line));
                    screenline -= (strlen (lp) / columns) + 1;
                    printline = FALSE;
                 }

               /* extract "From:" */
               if (strncmp (lp, "From: ", 6) == 0)
                    strcpy (returnpath, getval (line));

               /* extract "Reply-To:", overwrites "From:" */
               if (strncmp (lp, "Reply-To: ", 10) == 0)
                    strcpy (returnpath, getval (line));

               /* extract "Sender:" */
               if (strncmp (lp, "Sender: ", 8) == 0)
                    strcpy (sender, getval (line));

               /* sense rot13 article */ 
               if (strncmp (lp, "Keywords: ", 10) == 0)
                    if (auto_rot && findstr (1, lp, "rot13") != 0)
                         rot13 = TRUE;

               if (printline)
                    fputs (lp, stdout);

               /* first blank line ends header */
               if (*lp == '\n')
                 {
                    header = FALSE;
#ifndef TERMCAP
                    if (t2flag)
                         write (1, "\n y/n/q? ", 9);
                    else
                         write (1, "\n\x1F\x20 y/n/q?\x1F\x21", 12);
#else
                    putchar ('\n');
                    ReVOn();
                    printf(" y/n/q?  ");
                    ReVOff();
                    fflush(stdout);
#endif
                    c = getresponse();
#ifndef TERMCAP
                    if (!t2flag)
                         write (1, "\x1f\x31", 2);

                    backspace (!t2flag ? 7 : 8);
#else
                    DelLine();
                    backspace (8);
#endif
                    switch (tolower (c))
                      {
                         case 'n':
                         case 'p':
                         case 'q':
                              fclose (file);
                              return (c);

                         default:
                              break;
                      }
                 }
            }

          /* Handling for body of article */
          else
            {
               if (rot13)
                 {
                    for (k = 0; line[k] != '\0'; k++)
                         if (isalpha (line[k]))
                              line[k] += (toupper (line[k]) > 'M')                                                        ? (-13) : 13;

                    /* Don't unrot signatures */
                    if (*lp == '-')
                         if (strcmp (lp, "--\n") == 0 || 
                              strcmp (lp, "-- \n") == 0)
                           {
                              rot13 = FALSE;
                           }
                 }
               fputs (lp, stdout);
            }
       }

     /* Append previous references */
     strcat (strcat (reference, "> "), ref2);
     fclose (file);
     return ('\0');
}



int newscmd (c, i)
register char c;
int i;
{
     char tmp[60];
     int f;                                                /* added BAS */
     int cin;                                              /* added BRT */
     flag cflag;                                           /* added BAS */
     flag noerror;
     struct fildes fdes;                                   /* added BAS */
     static int seq, index;
     char **hptr, t, *path;
     static char cmd[1024],
                 *help[] = {
                     "a\tadd new article in current group",
                     "s <file>  save article in <file>",
                     "w <file>  save article in <file> without header",
                     "p\tprevious article",
                     "c\tcatchup (Mark all articles read)",
                     "f\tpost followup to current article",
                     "r\treply to article author",
                     "q\tquit",
                     "v or .    redisplay current article",
                     "n\tnext",
                     "#\tdisplay article #",
                     "u\tredisplay current article, rot13'd (unrot)",
                     "h or ?    help",
                     "!\tfork a shell",
                     NULL
                  };

     index = groups[curgroup].index;
     seq = groups[curgroup].seq;

     for (;;)
       {
          /* Do we need a prompt? */
          if (c == '\0')
            {
               ReVOn();
               printf ("\nEnd of article %d (of %d-%d)--What now? [nq] ",
                       i, index, seq);
               ReVOff();
               putchar (' ');
               fflush (stdout);
               c = getresponse();
            }

          switch (tolower (c))
            {
               /* save article with or without header...changed --REB */
               case 's':
               case 'w':
                    /* Set up a flag to remember whether or not we changed
                       our uid.  We can't do this for the general case, as
                       that would allow anyone to put a file anywhere in the
                       file system --BAS */

                    cflag = FALSE;
                    path = getword();

                    if (path[0] == '/')
                         strcpy (cmd, path);
                    else
                      {
                         sprintf (cmd, "%s/%s", homedir, path);
                         asetuid (0);
                         cflag = FALSE;
                      }

                    /* If your system allows user to make links, then you need
                       to check the ownership of the file, if it exists.
                       Otherwise, you can overwrite any file that is on the
                       same disk as the file --BAS 2 */

                    if (myuid)
                         if ((f = open (cmd, 1)) > 0)
                           {
                              _gs_gfd (f, &fdes, sizeof (fdes));
                              close (f);

                              if (myuid != (unsigned)fdes.fd_own)
                                {
                                   printf ("readnews: you do not own %s\n",
                                           cmd);

                                   if (cflag)
                                        asetuid (myuid);

                                   continue;
                                }
                           }

                    /* save article with header or without it --REB */
                    if (c == 's')
                         noerror = fileapnd (article, cmd, TRUE);
                    else
                         noerror = fileapskp (article, cmd, TRUE);

                    if (!noerror)
                      {
                         fputs ("....can't save article", stdout);

                         /* Change our uid back, if needed -- BAS 2 */
                         if (cflag)
                              asetuid(myuid);

#ifdef _OSK
                         sleep (2);
#else
                         tsleep (120);
#endif
                      }

                    /* Change the ownership of the file, if needed -- BAS 2 */
                    if (cflag)
                      {
                         chown (cmd, myuid);
                         asetuid (myuid);
                      }
                    break;

               /* display previous article */
               case 'p':
                    i = max (i - 1, index);
               case 'v':
               case '.':
                    return (i);

               /* redisplay article */
               case 'u':
                    rot13 = TRUE;
                    return (i);

               /* read specific article */
               case '0':
               case '1':
               case '2':
               case '3':
               case '4':
               case '5':
               case '6':
               case '7':
               case '8':
               case '9':
                    cmd[0] = c;
                    gets (&cmd[1]); 
                    i = atoi (cmd);
                    i = min (i, seq);
                    i = max (i, index);
                    return (i);

               /* Catch-Up -- Mark all articles as read */
               case 'c':
                    i = newsrc[curgroup].index = seq;
                    puts ("\nMarking all articles as read");
                    return (i+1);

               /* Add a new article in current group */
               case 'a':
                    cls();
                    printf ("add article to group: %s...", newsgroup);
                    fflush (stdout);
                    sprintf (cmd, "postnews -n %s", newsgroup);
                    docmd (cmd);
                    seq = ++(groups[curgroup].seq);
                    break;

               /* Followup -- Post a news reply */
               case 'f':
                    cls();
                    fputs ("post followup article...", stdout);
                    fflush (stdout);

                    /* If Subject: line has double quotes ("), change them to
                       single quotes ('). */
                    fixquote();

                    if (valid)
                      {
                         if ((path = getarticlepath() ) == NULL)
                           {
                              badpost ("can't post followup");
                              break;
                           }

                         sprintf (cmd, "postnews -i \"%s\" -s \"%s\" -n %s -a %s",
                                       reference, subject,
                                       newsgroup, article);

                         freearticlepath();

                         if (docmd_na (cmd) != 0)
                              badpost ("can't post followup");

                         seq = ++(groups[curgroup].seq);
                      }
                    /* post reply to news gatewayed from mailing list */
                    else
                      {
                         if ((path = getarticlepath() ) == NULL)
                           {
                              badpost ("can't mail reply");
                              break;
                           }

                         /* reply to "sender" address if present */
                         if (*sender != '\0')
                              strcpy (returnpath, sender);

                         sprintf (cmd, "%s %s -s \"%s\" -a %s/%s",
                                       mailer, returnpath, subject, path,
                                       article);

                         freearticlepath (path);

                         if (docmd_na (cmd) != 0)
                              badpost ("can't mail followup");
                      }
                    break;

               /* Reply to article author */
               case 'r':
                    cls();
                    fputs ("reply to article by mail...", stdout);
                    fflush (stdout);

                    /* If Subject: line as double quotes ("), change them to
                       single quotes ('). */

                    fixquote();
                    if ((path = getarticlepath() ) == NULL)
                      {
                         badpost ("can't reply by mail");
                         break;
                      }
                    sprintf (cmd, "%s %s -s \"%s\" -a %s/%s",
                                  mailer, returnpath, subject, path, article);

                    freearticlepath (path);

                    if (docmd (cmd) != 0)
                         badpost ("can't reply by mail");

                    break;

               /* Next */
               case 'n':
               case ' ':
               case '\n':
                    putchar ('\n');

                    /* flush keyboard input */
                    if ((cin = _gs_rdy (0)) > 0)
                         read (0, temp, cin);

                    return (++i);

               /* Quit */
               case 'q':
                    putchar ('\n');
                    return (0);

               /* Help */
               case 'h':
               case '?':
#ifndef TERMCAP
                    if (!t2flag)
                      {
                         popdoublewindow (23, 0, 54, 16);
                         putdashs (52);
                      }
#endif
                    putchar ('\n');

                    for (hptr = help; *hptr != NULL; ++hptr)
                         printf (" %s\n", strdetab (strcpy (tmp, *hptr), 9));

#ifndef TERMCAP
                    if (!t2flag)
                      {
                         putdashs (52);
                         fflush (stdout);
                         c = getresponse();
                         closedoublewindow();
                         putchar ('\x09');
                      }
                    else
#endif
                         putchar ('\n');
                    break;

               /* fork a shell */
               case '!':
                    forkshell();

#ifndef TERMCAP
                    if (!t2flag)
                         resetline();
#else
                    resetline();
#endif
                    break;

               /* Illegal command */
               default:
                    printf ("\nIllegal command: %c\n", c);
                    break;
            }
          c = '\0';       /* We want a prompt for the next command */
       }
}



/* moved from main() --REB */

int getscreensize()
{
#ifdef TERMCAP
     extern int ncolumns, nrows;

     columns = ncolumns;
     rows = nrows;
#else
#  ifndef _OSK
     struct registers regs;

     /* get screen size */
     regs.rg_a = 0;
     regs.rg_b = SS_SCSIZ;
     _os9 (I_GETSTT, &regs);
     columns = regs.rg_x - 1;
     rows = regs.rg_y - 1;
#  else
     columns = 80;
     rows = 24;
#  endif
#endif
}



/* If the Subject: line has a double quote in it, MAILX and POSTNEWS interpret
   the quotes as ending the Subject:.  For example, a line passed as:

       -s \"darn "Bug" story\"

   gets parsed as: Subject: darn, with 'Bug"' [sic] and 'story' as addresses.
   By changing the existing double quotes to a single quote, the problem is
   avoided. */

int fixquote()
{
     register char *p;

     p = subject;

     while ((p = strchr (p, '"')) != NULL)
          *p = '\x27';                                        /* ' */
}



char *getword()
{
     register char *p;

     p = line;
     if (mfgets (p, sizeof (line), stdin) == NULL)
       {
          errno = 0;
          fatal ("<ESC> hit...exiting");
       }

     return (skipspace (p));             /* skipspace() is in parse.c --REB */

}



int putdashs (howmany)
int howmany;
{
     register int i;

     putchar (' ');

     for (i = 0; i < howmany; ++i)
          putchar ('=');

     fflush (stdout);
}



/* Get a single character response from the user. */

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

     if (c != '\n'  &&  c != ' ')
       {
          putchar (c);
          fflush (stdout);
       }

     echo (ON);
     return (c);
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



/* backspace-space-backspace to delete part of a line --REB */

int backspace (howmany)
int howmany;
{
     register int i;

     for (i = 0; i < howmany; ++i)
          fputs ("\b \b", stdout);

     fflush (stdout);
}



int myinterrupt (sig)
int sig;
{
#ifndef TERMCAP
     if (winopen)                 /* if a help window is open just close it */
       {
          closedoublewindow();
          return;
       }
#endif
     echo (ON);
     exit (sig);
}



int fatal (msg)
char *msg;
{
     fprintf (stderr, "\nreadnews: %s", msg);

     if (errno != 0)
          fprintf (stderr, "...error %d", errno);

     putc ('\n', stderr);
     myinterrupt (0);
}



/* Open double overlay windows for keyboard user--white on red over black on
   black.  Shouldn't be called if using CoCo TERMCAP.  */

#ifndef TERMCAP
int popdoublewindow (x, y, width, height)
int x, y, width, height;
{
     char outstr[18];

     /* turn off the cursor */
     write (1, "\x05\x20", 2);

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
     winopen = TRUE;
}


/* Close double overlay window */

int closedoublewindow()
{
     write (1, "\x1b\x23\x1b\x23", 4);
     winopen = FALSE;
     resetline();
}
#endif


int resetline()
{
     puts ("\b  ");
     CurUp();
     CurOn();
}



int badpost (msg)
char *msg;
{
     printf ("\n%s...error #%d", msg, errno);
     fflush( stdout);
#ifdef _OSK
     sleep (3);
#else
     tsleep (180);
#endif
}



char *getarticlepath()
{
     register char *ptmp2;
     char *ptmp;

     ptmp = (char *) malloc ((strlen (newsdir) + strlen (newsgroup) + 2)
                              * sizeof (char *));
     if (ptmp == NULL)
          return (NULL);

     sprintf (ptmp, "%s/%s", newsdir, newsgroup);
     ptmp2 = (ptmp + strlen (ptmp) - 1);

     while (ptmp2 >= ptmp  &&  *ptmp2 != '/')
       {
          if (*ptmp2 == '.')
               *ptmp2 = '/';

          --ptmp2;
       }
     ptmp2 = ptmp;

     if ((ptmp = fixgroupname (ptmp)) == NULL)
          return ((char *) NULL);

     free (ptmp2);
     return (ptmp);
}



int freearticlepath (ptr)
char *ptr;
{
     if (ptr != NULL)
          free (ptr);
}



int usage()
{
     fputs ("readnews: read Usenet news articles\n\n", stderr);
     fputs ("Usage: readnews\n\n", stderr);
     fprintf (stderr, "v%s (%s) This is free software released under the GNU General Public\n",
                      version, VERDATE);
     fputs ("License.  Please send suggestions/bug reports to:  bob@kc2wz.bubble.org\n", stderr);

     exit (0);
}
