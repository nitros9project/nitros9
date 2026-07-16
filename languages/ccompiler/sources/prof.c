/*   C program profiler

     The -P option of the compiler generates code at the beginning
     of each function that calls _prof with the function's absolute
     address and a pointer to the name of the function.  This version
     of _prof just tallies the number of times a function is called.
     It could possibly be modified to trace the execution of functions.
*/

#include <stdio.h>

#define MAXFUNC 63       /* maximum number of unique functions */

typedef struct profstr {
     int (*func)();
     char *fname;
     long count;
     } prof;

static prof pfs[MAXFUNC];
static prof *pfree=pfs;
static prof *pmax=&pfs[MAXFUNC];

_prof(afunc,name)
int (*afunc)();
char *name;
{
     register prof *p;

/* linear search for the function addr (not quick, but easy) */
     for(p=pfs; p<pfree; ++p)
          if(p->func == afunc) {        /* function found, bump count */
               ++p->count;
               return;
          }

     if(pfree > pmax) {       /* no more room? */
          p=pfree-1;
          p->fname = p->fname ? "????????" : name; /* put it here */
          ++p->count;
     }
     else {                   /* enter the function in table */
          p=pfree++;
          p->fname=name;      /* pointer to function */
          p->func = afunc;    /* pointer to function name */
          p->count = 1;
     }
}

/* _dumprof() is called by exit() at program end.
          It may be called at any time to get a count */
_dumprof()
{
     register prof *p;

     pflinit();
     fflush(stdout);          /* flush stdout first */
     for(p=pfs; p<pfree; ++p)      /* dump names and counts */
          fprintf(stderr," %8s() %ld\n",p->fname,p->count);
}
