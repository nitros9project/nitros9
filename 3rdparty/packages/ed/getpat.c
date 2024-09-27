/*      getpat.c        */
#include <stdio.h>
#include "tools.h"

TOKEN * makepat();

/* Translate arg into a TOKEN string */
TOKEN *
 getpat(arg)
char *arg;
{

  return(makepat(arg, '\000'));
}

