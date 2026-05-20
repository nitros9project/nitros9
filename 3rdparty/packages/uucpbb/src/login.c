/*  L o g i n . C
    -- a level independent login program for OS-9

    AUTHOR
      Peter Durham
      The Wentworth Timesharing System
      summer: 6 Twin Brook Circle        school: Quincy House D-24
              Andover, MA 01810                  58 Plympton St.
              (617) 475-4243                     Cambridge, MA 02138
                                                 (617) 498-3209
      cis:    73177,1215                 delphi: PEDXING
      unix:   harvard!husc4!durham_2     intnet: durham_2@husc4.harvard.edu 

    Hacked upon by Mark Griffith [MDG], CIS 76070,41
    Hacked upon by Bob Billson (REB) <uunet!kc2wz!bob> for the OS-9 UUCP
        package, UUCPbb.

    VERSION
      02.00.00   86/06/25   Changes for CoCo OS-9 02.00.00:
                            * Added CR since echo off doesn't echo CR
                            * If directory isn't found, remains in current
                            * Checks for mail in "mailbox" file in login dir
      02.00.01   87/06/05   Changes for CoCo OS-9 Level II 02.00.01:
                            * ifdef added for Level II set user
      02.01.00   87/06/14   Changes to help clean up
                            * strings put all in one place
                            * detects level
      02.02.00   88/10/12   Heavily modified to support user logging
                            * changes in mail check routines,
                            * and other trivial things [MDG]
                            * This version requires the Kreider "C" library
      02.02.01   90/01/13   Modified to check login times for lockout periods
                            [Added - MDG]
      02.02.02   90/05/14   Hacks by E Gresick [EG]
                            * Added 'alias' file to get
                            * alias site and remote names.
                            * Added 'login.errors' file to store incorrect
                            * login entries.
      02.02.03   90/06/03   * Added tty locking code for UUCP
                            * Removed listing of MOTD also for UUCP
                            * (put 'list motd' in users ulogin file)
                            * Removed checking for mail
                            * (put 'lmail -c' in ulogin file) [MDG]
      02.02.04   90/07/17   * Added input timeouts for logging in to
                            * prevent stuck login processes [MDG]
      02.02.05   90/07/27   * added Ed Gresick's logerr() function
      02.30      ????????   * Released as version 2.3

      02.31      91/07/17   Minor updates done by Bob Billson (REB)
                            <...!uunet!kc2wz!bob>
                            * Fixed minor bug which caused input timeout to
                            * to work only if no characters were received.
                            * Any input would cause login to wait for the CR
                            * Changed some #define macros into functions.
      02.32      94/03/20   Updates by Bob Billson
                            * Changed to use password functions from Kreider
                            * clib.l.
                            * Only prompt for password if one is required.
*/

#define MAIN                /* Added -- REB */

#include "uucp.h"           /* several variables defined here - REQUIRED */
#include <os9.h>
#include <time.h>
#include <sgstat.h>
#include <password.h>       /* From Carl Kreider's CLIB -- REB */


#define   LEVEL2   TRUE     /* make this FALSE (0) if compiling for Level 1 */
#define   TIMEOUT   10      /* seconds before response timeout */
#define   ON         1
#define   OFF        0
#define   NODATA    -1

/* Changed these strings into functions.  Makes the resulting code just a tad
   smaller. --REB
#define   _fix(x)   while (*_f++ != '\n'); *--_f = '\0'
#define   getstr(x) {char *_f = x; readln(0, x, sizeof(x)); _fix(x);}
*/

QQ PWENT *pwentry;
QQ FILE *fp, *fdA;
QQ char *login_name;                    /* name User logins in as */
char tempstr[256],
     devname[9],                        /* Buffer for device name */
     oldlogname[PWNSIZ+1],
     inname[PWNSIZ+1],                  /* User name input */
     inpass[PWPSIZ+1];                  /* User password input */

long curr_time;                         /* holds login time [MDG] */
struct sgtbuf os9_time;
char *chk_alias();

/*  S t r i n g s */

QQ char NewLine = '\n',
        *Sorry = " Can't open password file\n",
        *Syntax = " Syntax error in password file!\n",
        *lfile_err = " Can't open logins file\n",
        *ufile_err = " Can't open user.login file\n",
        *log_err = " Can't change log directory",
        *timeout = " Timeout period exceeded\n<click>\n",
        *badtime = " Login out of allowed time period\n";

/* Change these strings as needed for your system (adds flexibility [MDG])
   logdir, DEFWORKDIR and DEFEXECDIR are defined in uucp.h. --REB */

QQ char *defw = DEFWORKDIR,             /* default data and execution */
        *defx = DEFEXECDIR;             /* directories in case of error */

/*  F u n c t i o n s */

/*  FUNCTION    main()
    PURPOSE     main loop  */

int main()
{
     int i;

     setbuf (stdout, NULL);
     setbuf (stdin, NULL);

     if ((logdir = getenv ("LOGDIR")) != NULL)
          logdir = strdup (logdir);
     else 
          logdir = LOGDIR;

     _gs_devn (2, tempstr);                     /* get dev from stderr */
     strhcpy (devname, tempstr);                /* copy changing high bit */
     asetuid (0);               /* must be superuser to read/write password */
     puts ("\nWelcome to the OS-9 Level Two Timesharing System");

     /* Try to login; if it returns here attempt failed */
     for (i = 0; i < 3; ++i)
       {
          putchar (NewLine);
          trylogin();
          puts ("Bad login.  Try again.");
       }

     /* If user doesn't make it in 3 tries, say bye */
     puts ("\nIncorrect login, 3 tries and you're out!\n<click>");
     myexit (0);
}



/*  FUNCTION    trylogin()
    PURPOSE     Function where all the work is done.  We prompt for
                username and password here, and check them. */

int trylogin()
{
     union {long l; char c[4];} crcpass;     /* Crc of password */
     int path,                               /* Password path number */
         procid;                             /* This process' ID number */
     long  htol();                           /* Declare long function */
     char tmptime[26];                       /* temporary time holder [REB] */

     /* Get the user name and the password */

     fputs ("login: ", stdout);

     /* Get login name and password. The timeout period is #defined in
        TIMEOUT.  Returns TRUE if the user timed out.  FALSE is returned and
        response is returned in 'inname' or 'inpass', otherwise.  The third
        parameter is a flag telling if everything type should be echoed to the
        standard output or not. --REB */

     if (get_response (inname, ON))
       {
          fputs (timeout, stdout);
          logerr (2);
          myexit (0);
       }
     putchar (NewLine);

     /* See if there is an entry for this name in the password file */
     pwentry = getpwnam (inname);
     endpwent();

     if (pwentry == (PWENT *) ERROR)
       {
          fputs (Sorry, stdout);
          logerr (3);
          myexit (1);
       }

     if (pwentry == NULL)
       {
          /*  Add invalid entry in error log  [EG] */
          logerr (1);
          return;
       }

     /* Do we need to get a password? */
     if (0L != htol (pwentry->upw))
       {
        fputs ("Password: ", stdout);

          if (get_response (inpass, OFF))
            {
               fputs (timeout, stdout);
               logerr (2);
               myexit (0);
            }
          putchar (NewLine);

          /* Get the CRC of the password */
          crcpass.l = 0xffffffL;
          crc (inpass, strlen (inpass), &crcpass.c[1]);

          if (crcpass.l != htol (pwentry->upw))
            {
               logerr (1);
               return;
            }
       }

     /* Check to see if this login is an alias and/or if they are allowed
        to log in at this time.  Changed --REB */

     login_name = chk_alias (pwentry->unam);
     chk_time (login_name);

     /* get our process ID */
     procid = getpid();

     /* Get the login time and update the log file - added [MDG] */
     curr_time = time ((long *)0);

     if (chdir (logdir) == -1)
       {
          fputs (log_err, stdout);
          logerr (4);
          myexit (0);
       }

     sprintf (tempstr, "%s.login", login_name);
     if ((fp = fopen (tempstr, "r+")) == 0)
       {
          fputs (ufile_err, stdout);
          logerr (4);
          myexit (0);
       }

     strcpy (tmptime, ctime (&curr_time));
     tmptime[3] = tmptime[10] = tmptime[19] = tmptime[24] = '\0';

     /* Print login messages */
     fputs ("\nUser ", stdout);
     putd (1, atoi (pwentry->uid));
     printf (" logged in on %s, %s %s at %s as process ",
             &tmptime[0], &tmptime[20], &tmptime[4], &tmptime[11]);
     putd (1, procid);
     printf (" on /%s\nLast login: ", devname);

     /* Read, print, and then update user login file.  Changed --REB */
     mfgets (tempstr, sizeof (tempstr), fp);
     puts (tempstr);
     rewind (fp);
     fprintf (fp, "%s, %s %s at %s\n%s",
                  &tmptime[0], &tmptime[20], &tmptime[4], &tmptime[11],
                  tempstr);

     fclose (fp);
     putchar (NewLine);

     /* Update user login file */
     strcpy (tempstr, "logins");

     if ((fp = fopen (tempstr, "a+")) == 0)
       {
          fixperms (fp);
          fputs (lfile_err, stdout);
          logerr (5);
          myexit (0);
       }

     sprintf (tempstr,"%s,%s,",login_name, devname);       /* added --REB */
     fwrite (tempstr, strlen (tempstr), sizeof(char), fp);
     fwrite (ctime (&curr_time), strlen (ctime (&curr_time)), sizeof(char), fp);
     fclose (fp);

     /* Change directories */
     if ((chxdir (pwentry->ucmd) == -1) || (chdir (pwentry->udat) == -1))
       {
          puts (" Can't find your login directory... will use default");
          chdir (defw);
          chxdir (defx);
       }

     /* Set up the user's id and priority */
     asetuid ((unsigned) atoi (pwentry->uid));
     setpr (procid, atoi (pwentry->upri));

     /* Chain to the user's command - changed [MDG] */
     sprintf (tempstr, "%s\n", pwentry->ujob);
     chain ("shell", strlen (tempstr), tempstr, 1, 1, 0);
}



/*  FUNCTION    putd()
    PURPOSE     Writes a decimal number to a path
    TAKES       int p, the path to write to
                int x, the number to write  */

int putd (p, x)
int p, x;
{
     if (x > 99)
          putch (p, x/100 + '0');

     if (x > 9)
          putch (p, x%100/10 + '0');

     putch (p, x%10 + '0');
}



/*  Added [EG]
    mfgets  (modified fgets)
    Same as fgets() only this version deletes '\n'
    From Mark Griffiths UUCP.c program  */

char *mfgets (s, n, iop)
register char   *s;
register int     n;
register FILE   *iop;
{
     register int    c;
     register char   *cs;

     cs = s;
     while (--n > 0 && (c = getc (iop)) != EOF)
          if (c == 0x0D)
            {
               *cs = '\0';
               break;
            }
          else
               *cs++ = c;

     return ((c == EOF  && cs == s) ? (char *)NULL : s);
}



/*  Checks alias file for any alias of the login name.
    Returns a pointer to login name use.  This will be changed if an alias
    was found.

    Note - 'oldlogname' (which must be a global variable)
           holds original login name.

    declare oldlogname as 'char oldlogname[PWNSIZ+1]'  */

char *chk_alias (name)
char *name;
{
     static char newlogname[PWNSIZ+1];
     char logname[PWNSIZ+1], *words[2];
     register char *p;
     int i;

     p = tempstr;

     /* Save the original name "just in case" */
     strcpy (newlogname, name);
     strcpy (oldlogname, name);
     sprintf (p, "%s/login.alias", logdir);

     /* Expected line format is:

           alias username

        Any lines starting with '#', <space>, <tab> or <cr> are comment lines
        and are ignored.  Changed --REB */

     if ((fdA = fopen (p, "r" )) != NULL)
       {
          fixperms (fdA);
          while (mfgets (p, sizeof (tempstr), fdA) != NULL)
               if ( ISCOMMENT (*p) == FALSE)
                    if ((i = getargs (words, tempstr, 2)) == 2)
                         if (strnucmp (name, *words, strlen (name)) == 0)
                           {
                              strcpy (newlogname, words[1]);
                              break;
                           }
          fclose(fdA);
       }
     return (newlogname);
}



/*  Checks the login time for individual users and either allows login
    to continue or exits with an error message [MDG]

    Allows unlimited logins to any user who does not have an entry in the
    login.times file.

    This function applies either of 3 rules to determine whether 
    the caller is calling at an allowed time.

    Rule 1: If 'endtime' is less than 'starttime' AND 
            'curtime' is less than 'endtime' then add
            2400 to 'curtime' and 'endtime'.
                      - or -
    Rule 2: If 'endtime' is less than 'starttime' then add
            2400 to 'endtime'.

    Rule 3: If the second field of the entry is the word 'never', the user's
            login attempt is always rejected.  --Added REB */

int chk_time (name)
char *name;
{
     register char *p1;
     char *curtime[20],
          *p = &os9_time,
          *words[3],
          *nologin = "\n\nSORRY - You cannot login at this time! <click!>";
     flag found_it = FALSE;
     int curtm, starttime, endtime, i;

     getime (p);
     sprintf (curtime, "%02d%02d", p->t_hour, p->t_minute);
     sprintf (tempstr, "%s/login.times", logdir);
     p1 = tempstr;

     /* Expected line format is:

           username  start_time end_time

        The second and third field is in 24-hour time format, i.e. 0930
        is 9:30 am, 2145 is 9:45 pm.  Any lines starting with '#', <space>,
        <tab> or <cr> are comment lines and are ignored.  Below, words[0]
        is field 1, words[1] is field 2 and words[2] is field 3.
        Changed --REB */

     if ((fdA = fopen (p1, "r" )) != NULL)
       {
          fixperms (fdA);
          while (mfgets (p1, sizeof (tempstr), fdA) != NULL)
               if ( ISCOMMENT (*p1) == FALSE)
                    if ((i = getargs (words, tempstr, 3)) >= 2)
                         if (strnucmp (name, *words, strlen (name)) == 0)
                           {
                              found_it = TRUE;
                              break;
                           }
          fclose (fdA);
       }

    /* if an entry was found, check the times */
    if (found_it)
      {
          if (i == 2)
               if (strucmp (words[1], "NEVER") == 0)
                 {
                    puts (nologin);
                    logerr (7);
                    myexit (0);
                 }
               else
                 {
                    logerr (9);
                    myexit (0);
                 }

          curtm = atoi (curtime);
          starttime = atoi (words[1]);
          endtime = atoi (words[2]);

          if ((endtime < starttime) && (curtm < endtime))
            {
               curtm += 2400;
               endtime += 2400;
            }
          else if (endtime < starttime)
               endtime += 2400;

          if ((curtm < starttime) || (curtm > endtime))
            {
               puts (nologin);
               logerr (7);
               myexit (0);
            }
       }
}



/*  Writes log-in error information to /dd/LOG/login.errors.
    due to:

    1  incorrect login name or password
    2  timeout while waiting for a user response
    3  can't open the password file
    4  can't open the user.login file
    5  can't open the logins file
    6  syntax error in the password file
    7  login during lockout period
    8  can't change to LOG directory
    9  syntax error in login.times file  */

int logerr (err)
int err;
{
     char err_log[100];

     sprintf (err_log, "%s/login.errors", logdir);
     curr_time = time ((long *)0);

     if ((fdA = fopen (err_log, "a+" )) != 0)
       {
          fixperms (fdA);
          sprintf (tempstr,"%s, %s, ",inname,inpass);
          fwrite (tempstr, strlen (tempstr), sizeof (char), fdA);
          fwrite (ctime (&curr_time), (strlen (ctime (&curr_time)) - 1),
                    sizeof (char), fdA);

          switch (err)
            { 
               case 1:
                    strcpy (tempstr, " Invalid user/password\n");
                    break;

               case 2:
                    strcpy (tempstr, timeout);
                    break;

               case 3:
                    strcpy (tempstr, Sorry);
                    break;

               case 4:
                    strcpy (tempstr, ufile_err);
                    break;

               case 5:
                    strcpy (tempstr, lfile_err);
                    break;

               case 6:
                    strcpy (tempstr, Syntax);
                    break;

               case 7:
                    strcpy (tempstr, badtime);
                    break;

               case 8:
                    strcpy (tempstr, log_err);
                    break;

               case 9:
                    strcpy (tempstr, "syntax error in login.times");
                    break;

               default:
                    strcpy (tempstr, "\n");
                    break;
            }
          fwrite (tempstr, strlen (tempstr), sizeof (char), fdA);
          fclose (fdA);
       }
}



/*  Exit with status 'n' after unlocking the port */

int myexit (n)
int n;
{
     free (logdir);
     exit (n);
}



/* If a character is not received within TIMEOUT seconds, TRUE is returned.
   This fixes a previous bug which cause LOGIN to time out only if nothing was
   ever typed.  Noise or someone calling, typing a character or two with no
   CR, then hanging up would make LOGIN wait forever...not nice. :-)
   If the CR is received within the timeout window, FALSE is returned and then
   received characters are put in BUFFER.

   ECHOFLAG determines whether or not characters are echoed to the standard
   output, which should be the port the is coming in on. --REB  */

int get_response (buffer, echoflag)
int echoflag;
char *buffer;
{
     int tdone, done;
     struct sgtbuf t;
     register char *p;
     char *start;                    /* used so we don't backspace too far */

     p = start = buffer;
     echo (OFF);                        /* turn off echoing to standard out */
     for (;;)
       {
          getime (&t);                              /* start/reset timer */

          if ((tdone = t.t_second + TIMEOUT) > 59)
               tdone -= 60;

          done = FALSE;
          while (!done)
               if (_gs_rdy (STDIN) == NODATA)               /* any key hit? */
                 {
                    getime(&t);

                    if (tdone == t.t_second)                /* timed out?   */
                      {
                         echo (ON);                         /* ...yup */
                         return (TRUE);
                      }
                 }
               else
                 {
                    read (STDIN, p, 1);                    /* got something */
                    switch (*p)
                      {
                         case '\n':                        /* CR ends input */
                              *p = '\0'; 
                              echo (ON);
                              write (STDOUT, "\n", 1);
                              return (FALSE);

                         case '\b':       /* backspace, don't go past start */
                              --p;

                              if (p < start)
                                   p = start;
                              else if (echoflag == ON)
                                   write (STDOUT, "\b \b",3);
                              break;

                         default:          /* echo character if flag is set */
                              if (echoflag == ON)
                                   write (STDOUT, p, 1);

                              ++p;
                              done = TRUE;                  /* reset timer */
                              break;
                      }
                 }
       }
}



int putch (path, x)
int path;
char x; 
{
     writeln (path, &x, 1);
}



int echo (onoroff)
int onoroff;
{
     struct sgbuf s;

     _gs_opt (1, &s);
     s.sg_echo = onoroff;
     _ss_opt (1, &s);
}
