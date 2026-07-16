/* line:  list lines of file with numbers */

#include <stdio.h>

main(argc,argv)
char **argv;
{
     char line[256];
     register int count = 0;

     if(--argc)
          if(freopen(*++argv,"r",stdin) == NULL) {
               fprintf(stderr,"can't open file: %s\n",*argv);
               exit(errno);
          }

     while(gets(line))
          printf("%5d %s\n",++count,line);
}
