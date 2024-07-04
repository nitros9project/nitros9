/*      set.c   */
#include <stdio.h>
#include "tools.h"
#include "ed.h"

struct tbl {
  char *t_str;
  int *t_ptr;
  int t_val;
} *t, tbl[] = {
  {"number", &nflg, TRUE},
  {"nonumber", &nflg, FALSE},
  {"list", &lflg, TRUE},
  {"nolist", &lflg, FALSE},
  {"eightbit", &eightbit, TRUE},
  {"noeightbit", &eightbit, FALSE},
  {0, 0, 0}
};

int set()
{
  char word[16];
  int i;

  inptr++;
  if (*inptr != 't') {
        if (*inptr != SP && *inptr != HT && *inptr != NL) return(ERR);
  } else
        inptr++;

  if (*inptr == NL) return(show());
  /* Skip white space */
  while (*inptr == SP || *inptr == HT) inptr++;

  for (i = 0; *inptr != SP && *inptr != HT && *inptr != NL;)
        word[i++] = *inptr++;
  word[i] = EOS;
  for (t = tbl; t->t_str; t++) {
        if (strcmp(word, t->t_str) == 0) {
                *t->t_ptr = t->t_val;
                return(0);
        }
  }
  return(0);
}

int show()
{
  extern int version;

  printf("ed version %d.%d\n", version / 100, version % 100);
  printf("number %s, list %s\n", nflg ? "ON" : "OFF", lflg ? "ON" : "OFF");
  return(0);
}

