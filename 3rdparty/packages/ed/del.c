/*      del.c   */
#include <stdio.h>
#include "tools.h"
#include "ed.h"

int del(from, to)
int from, to;
{
  LINE *first, *last, *next, *tmp;

  if (from < 1) from = 1;
  first = getptr(prevln(from));
  last = getptr(nextln(to));
  next = first->l_next;
  while (next != last) {
        if (next == &line0) break;
        tmp = next->l_next;
        free((char *) next);
        next = tmp;
  }
  relink(first, last, first, last);
  lastln -= (to - from) + 1;
  curln = prevln(from);
  return(0);
}
