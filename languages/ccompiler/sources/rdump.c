#include <stdio.h>

/* rdump:  prints formatted dump of .r and .l files

     rdump [opts] <file>[ <file>] [opts]

     options:
          -g - add global definition info
          -r - add reference info
          -o - add reference and local offset info
          -a - all of the above
*/

/* symbol table types */

/* symbol definition/reference type/location */

/* type flags */
#define CODENT      0x04        /* data/code flag */
/* data type flags */
#define DIRENT      0x02        /* global/direct flag */
#define INIENT      0x01        /* clear/init. data flag */

/* location flags */
#define CODLOC      0x20        /* data/code flag */
#define DIRLOC      0x10        /* global/direct flag */
#define LOC1BYT     0x08        /* two/one byte size flag */
#define LOCMASK     (CODLOC|DIRLOC)

#define NEGMASK     0x40        /* negate on resolution */
#define RELATIVE    0x80        /* relative reference */

/* misc. constants */
#define ROFSYNC     0x62CD2387
#define SYMLEN      9         /* Length of symbols */
#define MAXNAME     16        /* length of module name */

/* definition/reference */
typedef struct {
     char r_flag; /* type/location */
     unsigned r_offset;
} def_ref;

/* rof header structure */
typedef struct {
     long h_sync;
     unsigned h_tylan;
     char h_valid;
     char h_date[5];
     char h_edit;
     char h_spare;
     unsigned h_glbl;
     unsigned h_dglbl;
     unsigned h_data;
     unsigned h_ddata;
     unsigned h_ocode;
     unsigned h_stack;
     unsigned h_entry;
} binhead;

#define MAXSOURCE 20
#define puts(s) fputs(s,stdout)
#define mc(c) ((c)&0xff)

#define DEF 1
#define REF 2

direct char *snames[MAXSOURCE],*fname;
direct int scount;
direct int gflag,rflag,oflag;

binhead hd;
FILE *in;

main(argc,argv)
int argc;
char **argv;
{

     register char *p;

     while (--argc>0) {
          if(*(p=*++argv)=='-') {
               while(*++p) switch(*p) {
                    case 'g': gflag=1; break;
                    case 'r': rflag=1; break;
                    case 'o': oflag=1; break;
                    case 'a': gflag=rflag=oflag=1; break;
                    default:  error("unknown option -%c",*p);
               }
               done: ;
          }
          else {
               if(scount==MAXSOURCE) error(0,"too many source files");
               snames[scount++]=*argv;
          }
     }
     pass1();
}

pass1()
{
     int count;

     if(scount == 0)
          return;

     for(count=0; count<scount; ++count) {
          fname = snames[count];
          if((in = fopen(fname,"r")) == NULL) {
               printf("can't open '%s'",fname);
               continue;
          }

          for(;;) {
               if(fread(&hd,sizeof(hd),1,in) == 0)
                    break;

               if(hd.h_sync != ROFSYNC) {
                    printf("'%s' is not a relocatable module",fname);
                    break;
               }

               showhead();
               showglobs();

/* skip code and initialized data */
               fseek(in,(long)(hd.h_ocode + hd.h_ddata + hd.h_data),1);

               showrefs();
               showlcls();

          }
          fclose(in);
     }
}

showhead()
{
     int c;

     puts("\nModule name: ");
     while(c=getc(in))
          putchar(c);
     if(ferror(in)) ferr(fname);

     printf("\nTyLa/RvAt:   %02x/%02x\n",mc(hd.h_tylan>>8),mc(hd.h_tylan));
     printf("Asm valid:   %s\n",hd.h_valid ? "No" : "Yes");
     printf("Create date: %.3s %2d, %4d %02d:%02d\n",
          &("JanFebMarAprMayJunJulAugSepOctNovDec"[(mc(hd.h_date[1])-1)*3]),
          mc(hd.h_date[2]),1900+mc(hd.h_date[0]),
          mc(hd.h_date[3]),mc(hd.h_date[4]));
     printf("Edition:     %2d\n",hd.h_edit);
       puts("  Section    Init Uninit\n");
     printf("   Code:     %04x\n",hd.h_ocode);
     printf("     DP:       %02x   %02x\n",hd.h_ddata,hd.h_dglbl);
     printf("   Data:     %04x %04x\n",hd.h_data,hd.h_glbl);
     printf("  Stack:     %04x\n",hd.h_stack);
     printf("Entry point: %04x\n",hd.h_entry);
}
showglobs()
{
     register unsigned count,offset;
     char sym[SYMLEN+1],flag;

     count=getw(in);          /* global def count */
     if(gflag)
          printf("\n%u global symbols defined:\n",count);

     while(count--) {
          getname(sym);
          flag=getc(in);
          offset=getw(in);
          if(gflag) {
               printf(" %9s %04x ",sym,offset);
               ftext(flag,DEF);
          }
     }
}

getname(s)
register char *s;
{
     while(*s++ = getc(in));
     *s = '\0';
     if(ferror(in)) ferr(fname);
}

ftext(c,ref)
char c;
int ref;
{

     printf("(%02x) ",mc(c));
     if(ref & REF) {
          if(c & CODLOC)
               puts("in code");
          else puts(c & DIRLOC ? "in dp data" : "in non-dp data");

          puts(c & LOC1BYT ? "/byte" : "/word");
          if(c & NEGMASK)
               puts("/neg");
          if(c & RELATIVE)
               puts("/pcr");
     }
     if(ref & DEF) {
          if(ref & REF)
               puts(" - ");
          if(c & CODENT)
               puts("to code");
          else {
               puts(c & DIRENT ? "to dp" : "to non-dp");
               puts(c & INIENT ? " data" : " bss");
          }
     }
     putchar('\n');
}
showrefs()
{
     register unsigned count,rcount;
     def_ref ref;
     char sym[SYMLEN+1];
     int fflag;

     count=getw(in);
     if(rflag)
          printf("\n%u external references:\n",count);

     while(count--) {
          getname(sym);
          rcount=getw(in);
          if(rflag)
               printf(" %9s ",sym);
          fflag=0;
          while(rcount--) {
               fread(&ref,sizeof(ref),1,in);
               if(ferror(in)) ferr(fname);
               if(rflag && oflag) {
                    if(fflag)
                         puts("           ");
                    else fflag=1;
                    printf("%04x ",ref.r_offset);
                    ftext(ref.r_flag,REF);
               }
          }
          if(rflag && !oflag)
               putchar('\n');
     }
}
showlcls()
{
     register unsigned count;
     def_ref ref;

     count=getw(in);
     if(oflag)
          printf("\n%u local references\n",count);

     while(count--) {
          fread(&ref,sizeof(ref),1,in);
          if(ferror(in)) ferr(fname);
          if(oflag) {
               printf("   %04x ",ref.r_offset);
               ftext(ref.r_flag,DEF | REF);
          }
     }
}
error(s1,s2,s3,s4)
{
     fprintf(stderr,"rdump: ");
     fprintf(stderr,s1,s2,s3,s4);
     putc('\n',stderr);
     exit(1);
}
ferr(s)
{
     error("error reading '%s'",s);
}
