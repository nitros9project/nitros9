/*  unsubscribe.c   This program lets a user unsubscribe from newsgroups.
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

char line[512];


main (argc, argv)
int argc;
char *argv[];
{
     register int i;
     char *p;

     if (argc < 2
         || (argc >= 2  && (argv[1][0] == '-'  &&  argv[1][1] == '?')))
       {
          usage();
       }

     if ((homedir = getenv ("HOME")) != NULL)
          homedir = strdup (homedir);
     else
          fatal ("can't get HOME environment");

     p = line;
#ifdef _OSK
     sprintf (p, "%s", homedir);
#else
     sprintf (p, "%s/%s", homedir, uudir);
#endif

     if (chdir (p) == -1)
       {
#ifdef _OSK
          sprintf (p, "can't change to %s", homedir);
#else
          sprintf (p, "can't change to %s/%s", homedir, uudir);
#endif
          fatal (p);
       }

     for (i = 1; i < argc; i++)
          unsubscribe (argv[i]);

     exit (0);
}



int unsubscribe (newsgroup)
char *newsgroup;
{
     FILE *infile, *outfile;
     char group[512], flag, articles[512], newnewsrc[15];
     register char *p;
     char *q;
     char *newsrc = _NEWSRC;

     p = line;
     sprintf (newnewsrc, "new.%s", newsrc);

     if ((infile = fopen (newsrc, "r")) == NULL)
       {
          sprintf (p, "can't open %s file", newsrc);
          fatal (p);
       }

     if ((outfile = fopen (newnewsrc, "w")) == NULL)
       {
          sprintf (p, "can't create %s", newnewsrc);
          fatal (p);
       }

     while (fgets (p, sizeof (line), infile) != NULL)
       {
          *articles = '\0';
          q = group;
          while (*p != '\0' && *p != '!' && *p != ':')
               *q++ = *p++;
          *q = '\0';
          flag = *p++;
          while (*p == ' ')
               ++p;
          q = articles;
          while (*p != '\0' && *p != '\n')
               *q++ = *p++;
          *q = '\0';

          if ((strcmp (newsgroup, "all") == 0)
                || (strcmp (newsgroup, group) == 0))
            {
               if (flag == '!')
                    printf ("Newsgroup % is already unsubscribed.\n", group);
               else
                 {
                    printf ("Newsgroup %s is now unsubscribed.\n", group);
                    flag = '!';
                 }
            }
          fprintf (outfile, "%s%c %s\n", group, flag, articles);
       }

     fclose (infile);
     fclose (outfile);
     filemove (newnewsrc, newsrc);
}



int fatal (msg)
char *msg;
{
     fprintf (stderr, "unsubscribe: %s...error %d\n", msg, errno);
     exit (0);
}



int usage()
{
     fputs ("unsubscribe: unsubscribe from Usenet newsgroup(s)\n\n", stderr);
     fputs ("usage: unsubscribe <newsgroup> [newsgroup...]\n", stderr);
     fputs ("       if <newsgroup> is 'all', all newsgroups will be unsubscribed\n\n", stderr);
     fprintf (stderr, "v%s (%s) This is free software released under the GNU General Public\n",
                      version, VERDATE);
     fputs ("License.  Please send suggestions/bug reports to:  bob@kc2wz.bubble.org\n", stderr);
     exit (0);
}
