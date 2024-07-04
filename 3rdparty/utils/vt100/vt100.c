/*
 vt100
*/

#include <stdio.h>
#include <stdlib.h>
#include <os9.h>

#define stdin_r 0
#define stdout_r 1
#define Case 1
#define echo 4
#define pause 7
#define eof 12
#define psc 15
#define kbi 16
#define kba 17
#define type 20
#define Baud 21
#define mark -96
#define space -32
#define even 96
#define odd 32
#define none 0
#define CSI '\x9B'

int cls(int path);
int getopt(int path, char *buffer);
int setopt(int path, char *buffer);
int owset();
int owend();

int main(argc,argv)
int argc;
char **argv;
{
  int count,kpm,ckm,ip,op,escmode;
  char path,a,x,y,t,l,emulation;
  char menuback,menufore,alt,baud,parity,stopbits,autolf,wordlen;
  char top,bottom,ox,oy,ap,cp,cn,start,autocr,autowrap,relative;
  char mainback,mainfore,mainbold,bold,inverse,underline,blink,test;
  char tab[80],combuf[50];
  char c;
  char inbuf[128],outbuf[128],xbuf[15],ansibuf[200];
  char scrnopt[32],oscrnopt[32],pathopt[32];
  char parityx[5];

  const char *menu1 = "  \x1f\x22                                    \x1f\x23\n\l  \x1f\x20         VT-220 - MAIN MENU         \x1f\x21\n\l\l  / - This menu\n\l  C - Change directory\n\l  H - Hangup modem\n\l  O - Options menu\n\l  Q - Quit\n\l";
  const char *menu2 = "  R - Reset terminal\n\l  S - Shell\n\l  0123456789-,.<ENTER> - keypad keys\n\l  SHIFT-1234 - PF1,PF2,PF3,PF4\n\l  <UP><DOWN><LEFT><RIGHT> - Arrow keys\n\l\l  Press key or <SPACE> to cancel: ";

  const char *quit = "  \x1f\x22               \x1f\x23\n\l  \x1f\x20     QUIT      \x1f\x21\n\l\l  Are you sure? ";
  const char *hangup = "  \x1f\x22               \x1f\x23\n\l  \x1f\x20 HANG UP MODEM \x1f\x21\n\l\l  Are you sure? ";
  const char *change = "  \x1f\x22                                                                      \x1f\x23\n\l  \x1f\x20                       CHANGE WORKING DIRECTORY                       \x1f\x21\n\l\l  Enter new directory name: ";
  const char *optionmenu = "  \x1f\x22                       \x1f\x23\n\l  \x1f\x20        OPTIONS        \x1f\x21\n\l\l";
  char workdir[128];
  const char *termstr = "OS-9  CRT   VT-52 VT-100VT-220VIDTEX";
  const char *onoff = "OffOn ";
  const char *baudstr = "110  300  600  1200 2400 4800 9600 19200";
  const char *paritystr = "None Even Odd  Mark Space";
  const char *wordstr = "87";
  const char *stopstr = "12";
  

  if((path=(char)open(*++argv,3))==-1)
  {
    printf("Error: Cannot open device.\n");
    exit(1);
  }
     
  getopt(stdout_r,oscrnopt);
  getopt(stdout_r,scrnopt);
  scrnopt[Case]=0;
  scrnopt[echo]=0;
  scrnopt[pause]=0;
  scrnopt[eof]=0;
  scrnopt[psc]=0;
  scrnopt[kbi]=0;
  scrnopt[kba]=0;
  setopt(stdout_r,scrnopt);
     
  baud=6;               /* 9600 baud startup */
  getopt(path,pathopt);
  pathopt[Case]=0;
  pathopt[echo]=0;
  pathopt[pause]=0;
  pathopt[eof]=0;
  pathopt[psc]=0;
  pathopt[kbi]=0;
  pathopt[kba]=0;
  pathopt[Baud]=baud;
  pathopt[type]=0;
  setopt(path,pathopt);
    
  x=1;
  y=1;
  mainback=2;
  mainfore=0;
  menuback=1;
  menufore=7;
  mainbold=5;
  kpm=0;
  ckm=0;
  emulation=4;
  parity=0;
  stopbits=0;
  wordlen=0;
  autolf=0;
  top=1;
  bottom=24;
  ox=1;
  oy=1;
  escmode=0;
  autocr=0;
  autowrap=0;
  relative=0;
  bold=0;
  underline=0;
  blink=0;
  inverse=0;

  for(cp=1;cp<81;cp++) tab[cp]=!((cp-1)&7);
  tab[80]=1;
  parityx[0]=none;
  parityx[1]=even;
  parityx[2]=odd;
  parityx[3]=mark;
  parityx[4]=space;

  if (owset(stdout_r,1,0,0,80,24,mainfore,mainback)==-1)
  {
    printf("Error: Window must be 80*24 text screen.");
    exit(1);
  }


  writeln(stdout_r,"=======================  This program is public domain  =======================\n",80);
  writeln(stdout_r,"____          ____   ___________          ___        _________      _________\n",78);
  writeln(stdout_r,"\\   \\        /   /  |           |        /   |      /   ___   \\    /   ___   \\\n",79);
  writeln(stdout_r," \\   \\      /   /   |___     ___|       /_   |     |   /   \\   |  |   /   \\   |\n",80);
  writeln(stdout_r,"  \\   \\    /   /        |   |             |  |     |  |     |  |  |  |     |  |\n",80);
  writeln(stdout_r,"   \\   \\  /   /         |   |    _____    |  |     |  |     |  |  |  |     |  |\n",80);
  writeln(stdout_r,"    \\   \\/   /          |   |   |_____|   |  |     |  |     |  |  |  |     |  |\n",80);
  writeln(stdout_r,"     \\      /           |   |           __|  |__   |  |     |  |  |  |     |  |\n",80);
  writeln(stdout_r,"      \\    /            |   |          |        |  |   \\___/   |  |   \\___/   |\n",80);
  writeln(stdout_r,"       \\__/             |___|          |________|   \\_________/    \\_________/\n",79);
  writeln(stdout_r,"\n",1);
  writeln(stdout_r,"==========================  Text Screen Version 1.1  ==========================\n",80);
  writeln(stdout_r,"                                      by:\n",42);
  writeln(stdout_r,"                                Brian Marcotte\n",47);
  writeln(stdout_r,"                    Partial VT-220 emulation by Gene Heskett\n",62);
  writeln(stdout_r,"US Mail   : 69 Kearney Ave.                 |  If you know of any way to make\n",78);
  writeln(stdout_r,"            Auburn, NY 13021                |  this program better, please\n",75);
  writeln(stdout_r,"CompuServe: 72507,3535                      |  send me mail. If you make a\n",75);
  writeln(stdout_r,"Delphi    : BRIMARCOTTE                     |  modification, please send a copy\n",80);
  writeln(stdout_r,"GEnie     : B.MARCOTTE                      |  of the source.\n",62);
  writeln(stdout_r,"BITNET    : V090J78Y@UBVMSA                 |\n",46);
  writeln(stdout_r,"INTERNET  : V090J78Y@UBVMSA.CC.BUFFALO.EDU  |\n",46);
  writeln(stdout_r,"\n",1);
  write(stdout_r,"=============================  Press Any Key:    ==============================",79);
  write(stdout_r,"\x02\x4e\x37\x07",4);
  read(stdin_r,&c,1);

  cls(stdout_r);
  
  for(;;)
  {
    if(_gs_rdy(stdin_r)>0)
    {
      read(stdin_r,&c,1);
      op=0;
      /* check for delete */
      if (c==-28) c=127; /* alt-d is delete */
      if(c>-1)
        outbuf[op++]=c; /* c is normal ascii char, output it */
      else
      { 
select: switch(alt=128+c) /* c was an ALT char, seen as negative here */
        { 
        case 's':
          owset(stdout_r,1,0,0,80,24,menufore,menuback);
          setopt(stdout_r,oscrnopt);
          system("");
          setopt(stdout_r,scrnopt);
          owend(stdout_r,underline,blink,inverse);
          break; /* end of switch ALT case 's' */
        case 'q':
          owset(stdout_r,1,30,9,19,5,menufore,menuback);
          write(stdout_r,quit,63);
          read(stdin_r,&c,1);
          owend(stdout_r,underline,blink,inverse);
          if(c=='y' || c=='Y')
          {
            setopt(stdout_r,oscrnopt);
            owend(stdout_r,0,0,0);
            exit(0);
          }
          break; /* end of switch ALT case 'q' */
        case 'r':
reset:    x=1;
          y=1;
          kpm=0;
          ckm=0;
          escmode=0;
          write(stdout_r,"\x1f\x21\x1f\x23\x1f\x25",6);
          xbuf[0]=0x1b;
          xbuf[1]=0x32;
          xbuf[2]=mainfore;
          xbuf[3]=7;
          write(stdout_r,xbuf,4);
          if(emulation>=3)
          { 
            autocr=0;
            relative=0;
            autowrap=0;
            top=1;
            bottom=24;
            bold=0;
            underline=0;
            blink=0;
            inverse=0;
            for(cp=1;cp<81;cp++) tab[cp]=!((cp-1)&7);
            tab[80]=1;
          }
          cls(stdout_r);
          break; /* end of switch ALT case 'r' */ 
        case 'h':
          owset(stdout_r,1,30,9,19,5,menufore,menuback);
          write(stdout_r,hangup,63);
          read(stdin_r,&c,1);
          owend(stdout_r,underline,blink,inverse);
          if(c=='y' || c=='Y')
          {
            close(path);
            sleep(1);
            path=(char)open(*argv,3);
            setopt(path,pathopt);
          }
          break; /* end of switch ALT case 'h' */
        case 'c':
          owset(stdout_r,1,3,9,74,5,menufore,menuback);
          write(stdout_r,change,185);
          setopt(stdout_r,oscrnopt);
          readln(stdin_r,workdir,100);
          write(stdout_r,"\x05\x20",2);
          setopt(stdout_r,scrnopt);
          chdir(workdir);
          owend(stdout_r,underline,blink,inverse);
          break; /* end of switch ALT case 'c' */
        case 'o': /* switch=ALT, options */
          a=emulation;
          owset(stdout_r,1,26,5,27,14,menufore,menuback);
          write(stdout_r,optionmenu,63);
          writeln(stdout_r,"  Emulation      : \n",20);
          writeln(stdout_r,"  Auto line feed : \n",20);
          writeln(stdout_r,"\n",1);
          writeln(stdout_r,"  Baud           : \n",20);
          writeln(stdout_r,"  Parity         : \n",20);
          writeln(stdout_r,"  Word length    : \n",20);
          writeln(stdout_r,"  Stop bits      : \n",20);
          write(stdout_r,"\l  Enter first letter of\n\l  item to change: ",44);          
          do /* renew screen data */
          {
            write(stdout_r,"\x02\x33\x23",3);
            write(stdout_r,termstr+emulation*6,6);
            write(stdout_r,"\x02\x33\x24",3);
            write(stdout_r,onoff+autolf*3,3);
            write(stdout_r,"\x02\x33\x26",3);
            write(stdout_r,baudstr+baud*5,5);
            write(stdout_r,"\x02\x33\x27",3);
            write(stdout_r,paritystr+parity*5,5);
            write(stdout_r,"\x02\x33\x28",3);
            write(stdout_r,wordstr+wordlen,1);
            write(stdout_r,"\x02\x33\x29",3);
            write(stdout_r,stopstr+stopbits,1);
            write(stdout_r,"\x02\x32\x2c",3);
            read(stdin_r,&c,1); /* get char typed */
            c=c|0x20; /* make typed option char lowercase */
            switch(c) /* now switch on its value */
            { /* ALT+'o'+switch(nchar) */
            case 'e':
              if (++emulation==5) emulation=0;
              break; /* end ALT+'o' then 'e' */
            case 'a':
              if (++autolf==2) autolf=0;
              break; /* end of ALT+'o' then 'a' */
            case 'b':
              if(++baud==8) baud=0;
              break; /* end of ALT+'o' then 'b' */
            case 'p':
              if(++parity==5) parity=0;
              break; /* end of ALT+'o' then 'p' */
            case 'w':
              if(++wordlen==2) wordlen=0;
              break; /* end of ALT+'o' then 'w' */
            case 's':
              if(++stopbits==2) stopbits=0;
            case 45: /* ALT+'o' then '-' OR enter key! */
            case 32: /* ALT+'o' then space bar */
              break; 
            default: 
              write(stdout_r,"\7",1);
            }
          }
          while(c!=45 && c!=32); /* end ALT+'o' then next char */
               /* update the paths options */
          pathopt[Baud]=baud+wordlen*32+stopbits*128;
          pathopt[type]=parityx[parity];
          setopt(path,pathopt);
          owend(stdout_r,underline,blink,inverse);
          if(a!=emulation) goto reset;
          break; /* ALT+'o' end */
        case '/': /* begin ALT+'/' */
          owset(stdout_r,1,20,4,40,16,menufore,menuback);
          write(stdout_r,menu1,182);
          write(stdout_r,menu2,180);
          read(stdin_r,&c,1);
          owend(stdout_r,underline,blink,inverse);
          if(c>='A' && c<='Z') c=c|32; /* make lowercase */
          c=c-128; /* and subtract the ALT key */
          goto select;
        default: /* it wasn't ALT+'o' or ALT+'/' */
          if(emulation>1)
          {
            switch(alt)
            {
            case '\\':
              outbuf[op++]=28;
              break;
            case ']':
              outbuf[op++]=29;
              break;
            case '^':
              outbuf[op++]=30;
              break;
            case '_':
              outbuf[op++]=31;
              break;
            case 12:
            case 10:
            case 9:
            case 8:
              outbuf[op++]=27;
              if(emulation==3)
              {
                switch(ckm)
                {
                case 0: /* code above here sets it to 0 always */
                  outbuf[op++]='[';
                  break;
                case 1:
                  outbuf[op++]='O';
                }
              }
              switch(alt) /* only if emulation=3 */
              {
              case 12:
                outbuf[op++]='A';
                break;
              case 10:
                outbuf[op++]='B';
                break;
              case 9:
                outbuf[op++]='C';
                break;
              case 8:
                outbuf[op++]='D';
                break;
              }
              break;
            case '+':
              alt=',';
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
            case '-':
            case ',':
            case '.':
            case 13:
              switch(kpm) /* code above sets it to 0 always */
              {
              case 0:
                outbuf[op++]=alt;
                break;
              case 1:
                outbuf[op++]=27;
                switch(emulation)
                {
                case 2:
                  outbuf[op++]='?';
                  break;
                case 3:
              /*  case 4: */
                  outbuf[op++]='O';
                } /* end of switch(emulation) */
                outbuf[op++]=alt+64;
                break;
              } /* end of switch(kpm) */
              break;
            case '`':
              alt='"';
            case '!':
            case '"':
            case '#':
            case '$':
              outbuf[op++]=27;
              if(emulation>=3) outbuf[op++]='O';
              outbuf[op++]=alt+47;
            } /* end if(emulation>1) */
          } /* end of ALT+ default */
        } /* end of ALT key stuffs */
      } /* end of keyboard input stuffs */
      write(path,outbuf,op); /* so write the buffer */
    }
    if((count=_gs_rdy(path))>0) /* something from the modem? */
    {
      count=read(path,inbuf,count);
      op=0;
      switch(emulation)
      {   
      case 0:
        for(ip=0;ip<count;ip++)
        {
          outbuf[op++]=inbuf[ip];
          if(autolf==1 && inbuf[ip]==13) outbuf[op++]=10;
        }
        break;
      case 1:
        for(ip=0;ip<count;ip++)
        {
          if(inbuf[ip]>31) outbuf[op++]=inbuf[ip];
          else
          {
            switch(inbuf[ip])
            {
            case 7:
            case 8:
            case 10:
            case 12:
              outbuf[op++]=inbuf[ip];
              break;
            case 13:
              outbuf[op++]=inbuf[ip];
              if(autolf) outbuf[op++]=10;
            }
          }
        }
        break;
      case 2:  /*switch case(emulation=2) */
        for(ip=0;ip<count;ip++)
        { 
nowvt52:  if(inbuf[ip]<=31)
          {
            switch(inbuf[ip])
            {
            case 7:
              outbuf[op++]=7;
              break;
            case 8:
              if(x>1)
              { 
                if((x--)!=80) outbuf[op++]=8;
              }
              break;
            case 9:
              if (x<80)
              {
                t=8-((x-1)&7);
                x+=t;
                if(x>80)
                {
                  x--;
                  t--;
                }
                while((t--)!=0)
                  outbuf[op++]=6;
              }  
              break;
            case 10:
            case 11:
            case 12:
              if(y<24) y++;
              outbuf[op++]=10;
              break;
            case 13:
              x=1;
              outbuf[op++]=13;
              if(autolf)
              {
                outbuf[op++]=10;
                if(y<24) y++;
              }
              break;
            case 24:
            case 26:
              escmode=0;
              break;
            case 27:
              escmode=1;
            }  /* end of switch inbuf[ip] */
          } /* end of inbuf[ip]<=31 and nowvt52 */
          else
          {
            switch(escmode)
            {
            case 0:
              if(inbuf[ip]!=127)
              {
                if(++x>80)
                {
                  if(y!=24)
                  {
                    outbuf[op++]=inbuf[ip];
                    outbuf[op++]=8;
                  }
                  else
                  {
                    write(stdout_r,outbuf,op);
                    op=0;
                    a=(bold) ? mainbold : mainfore;
                    owset(stdout_r,1,79,22,1,1,0,0);
                    owset(stdout_r,0,79,22,1,2,a,mainback);
                    xbuf[0]=inbuf[ip];
                    xbuf[1]=1;
                    xbuf[2]=31;
                    xbuf[3]=48;
                    write(stdout_r,xbuf,4);
                    owend(stdout_r,0,0,0);
                    owend(stdout_r,0,0,0);
                  }
                  if(x!=81) x=81;
                }
                else outbuf[op++]=inbuf[ip];
              }
              break; /* end of escape mode 0 */
            case 1:  /* escape mode 1 */
              switch (inbuf[ip])
              {
              case 'A':
                if(y>1)
                {
                  outbuf[op++]=9;
                  y--;
                }
                break;
              case 'B':
                if(y<24)
                {
                  outbuf[op++]=10;
                  y++;
                }
                break;
              case 'C':
                if(x<80)
                {
                  outbuf[op++]=6;
                  x++;
                }
                break;
              case 'D':
                if(x>1)
                {
                  outbuf[op++]=8;
                  x--;
                }
                break;
              case 'H':
                outbuf[op++]=1;
                x=1;
                y=1;
                break;
              case 'I':
                if(y==1)
                {
                  outbuf[op++]=31;
                  outbuf[op++]=48;
                }
                else
                {
                  outbuf[op++]=9;
                  y--;
                }
                break;
              case 'J':
                outbuf[op++]=11;
                break;
              case 'K':
                outbuf[op++]=4;
                break;
              case 'Y':
                escmode=3;
                l=0;
                break;
              case 'Z':
                xbuf[0]=27;
                xbuf[1]='/';
                xbuf[2]='Z';
                write(path,xbuf,3);
                break;
              case '=':
                kpm=1;
                break;
              case '>':
                kpm=0;
                break;
              case '<':
                emulation=3;
                escmode=0;
                goto nowvt100;
              } /* end of switch(inbuf) */
              escmode--; /* if escape mode was 1, now its 0 */
              break;  /* end of escape mode 1 */
            case 2:  /* escape mode 2 */
              if(l==0) l=inbuf[ip];
              else
              {
                outbuf[op++]=2;
                outbuf[op++]=inbuf[ip];
                outbuf[op++]=l;
                x=inbuf[ip]-31;
                y=l-31;
                escmode=0;
              } /* end of l wasn't 0 */
            } /* end of escape mode 2 */
          } /* end of switch(escmode) */
        } /* end of nowvt52 stuffs */
        break;
      case 3: /* of switch(emulation) */
      case 4: /* catch some vt-220 stuffs here too */
        for (ip=0;ip<count;ip++)
        {
tst220:   if(inbuf[ip]==CSI)
          {
            escmode= 5;
            ap     = 0;
          }  
nowvt100: if(inbuf[ip]<=31)
          {
            switch(inbuf[ip])
            {
            case 7:
              outbuf[op++]=7;
              break;
            case 8:
              if(x>1)
              {
                if((x--)!=81) outbuf[op++]=8;
              }
              break;
            case 9:
              if (x<80)
              {
                do outbuf[op++]=6;
                while(!tab[++x] && x<80);
              }
              break;
            case 10:
            case 11:
            case 12:
              if(autocr)
              {
                outbuf[op++]=13;
                x=1;
              }
              if(y==bottom)
              {
                write(stdout_r,outbuf,op);
                op=0;
                owset(stdout_r,0,0,top-1,80,bottom-top+1,mainfore,mainback);
                xbuf[0]=2;
                xbuf[1]=32;
                xbuf[2]=bottom-top+32;
                xbuf[3]=10;
                write(stdout_r,xbuf,4);
                owend(stdout_r,underline,blink,inverse);
              }
              else
              {
                if(y!=24)
                {
                  y++;
                  outbuf[op++]=10;
                }
              }
              break;
            case 13:
              x=1;
              outbuf[op++]=13;
              if(autolf)
              {
                if(y==bottom)
                {
                  write(stdout_r,outbuf,op);
                  op=0;
                  owset(stdout_r,0,0,top-1,80,bottom-top+1,mainfore,mainback);
                  xbuf[0]=2;
                  xbuf[1]=32;
                  xbuf[2]=bottom-top+32;
                  xbuf[3]=10;
                  write(stdout_r,xbuf,4);
                  owend(stdout_r,underline,blink,inverse);
                }
                else
                {
                  if(y!=24)
                  {
                    y++;
                    outbuf[op++]=10;
                  }
                }
              }
              break;
            case 24:
            case 26:
              escmode=0;
              break;
            case 27:
              escmode=1;
            }
          } /* end of inbuf[ip] <= 27 */
          else /* it was 28+ */
          {
            switch(escmode)
            {
            case 0:
              if(inbuf[ip]!=127)
              {
                if(++x>80)
                {
                  if(x==81 || autowrap==0)
                  {
                    x=81;
                    if(y!=24)
                    {
                      outbuf[op++]=inbuf[ip];
                      outbuf[op++]=8;
                    }
                    else
                    {
                      outbuf[op++]=0x1f;
                      outbuf[op++]=0x21;
                      write(stdout_r,outbuf,op);
                      op=0;
                      a=(bold) ? mainbold : mainfore;
                      owset(stdout_r,1,79,22,1,1,0,0);
                      owset(stdout_r,0,79,22,1,2,a,mainback);
                      xbuf[0]=(inverse) ? 0x1f : 0;
                      xbuf[1]=(inverse) ? 0x20 : 0;
                      xbuf[2]=(underline) ? 0x1f : 0;
                      xbuf[3]=(underline) ? 0x22 : 0;
                      xbuf[4]=(blink) ? 0x1f : 0;
                      xbuf[5]=(blink) ? 0x24 : 0;
                      xbuf[6]=inbuf[ip];
                      xbuf[7]=1;
                      xbuf[8]=31;
                      xbuf[9]=48;
                      write(stdout_r,xbuf,10);
                      owend(stdout_r,0,0,0);
                      owend(stdout_r,underline,blink,inverse);
                    }
                  }
                  else
                  {
                    x=2;
                    if(y==bottom)
                    {
                      outbuf[op++]=13;
                      write(stdout_r,outbuf,op);
                      op=0;
                      owset(stdout_r,0,0,top-1,80,bottom-top+1,mainfore,mainback);
                      xbuf[0]=2;
                      xbuf[1]=32;
                      xbuf[2]=bottom-top+32;
                      xbuf[3]=10;
                      write(stdout_r,xbuf,4);
                      owend(stdout_r,underline,blink,inverse);
                    }
                    else
                    {
                      if(++y==25) y=24;
                      outbuf[op++]=6;
                    }
                    outbuf[op++]=inbuf[ip];
                  }
                }
                else outbuf[op++]=inbuf[ip];
              }
              break; /* end escmode=0 */
            case 1: /* now do 1 stuffs */
              switch(inbuf[ip])
              {
              case 'c':
                x=1;
                y=1;
                kpm=0;
                ckm=0;
                escmode=0;
                write(stdout_r,"\x1f\x21\x1f\x23\x1f\x25",6);
                xbuf[0]=0x1b;
                xbuf[1]=0x32;
                xbuf[2]=mainfore;
                xbuf[3]=7;
                write(stdout_r,xbuf,4);
                autocr=0;
                relative=0;
                autowrap=0;
                top=1;
                bottom=24;
                bold=0;
                underline=0;
                blink=0;
                inverse=0;
                for(cp=1;cp<81;cp++) tab[cp]=!((cp-1)&7);
                tab[80]=1;
                cls(stdout_r);
                break;
              case 'E':
                outbuf[op++]=13;
                x=1;
              case 'D':
                if(y==bottom)
                {
                  write(stdout_r,outbuf,op);
                  op=0;
                  owset(stdout_r,0,0,top-1,80,bottom-top+1,mainfore,mainback);
                  xbuf[0]=2;
                  xbuf[1]=32;
                  xbuf[2]=bottom-top+32;
                  xbuf[3]=10;
                  write(stdout_r,xbuf,4);
                  owend(stdout_r,underline,blink,inverse);
                }
                else
                {
                  if(y!=24)
                  {
                    y++;
                    outbuf[op++]=10;
                  }
                }
                escmode=0;
                break;
              case 'H':
                tab[x]=1;
                escmode=0;
                break;
              case 'M':
                if(y!=top)
                {
                  outbuf[op++]=9;
                  if(--y<1) y=1;
                }
                else
                {
                  owset(stdout_r,0,0,top-1,80,bottom-top+1,mainfore,mainback);
                  write(stdout_r,"\x1f\x30",2);
                  owend(stdout_r,underline,blink,inverse);
                }
                escmode=0;
                break;
              case '7':
                ox=x;
                oy=y;
                escmode=0;
                break;
              case '8':
                x=ox;
                y=oy;
                outbuf[op++]=2;
                a=(x==81) ? 80 : x;
                outbuf[op++]=a+31;
                outbuf[op++]=y+31;
                escmode=0;
                break;
              case '=':
                kpm=1;
                escmode=0;
                break;
              case '>':
                kpm=0;
                escmode=0;
                break;
              case '#':
                escmode=2;
                break;
              case '(':
                escmode=3;
                break;
              case ')':
                escmode=4;
                break;
              case '[':
                escmode=5;
                ap=0;
                break;
              default:
                escmode=0;
              }
              break; /* end escmode=1 stuffs */
            case 2: /* Double height/Double width not supported */
              escmode=0;
              break;
            case 3: /* Selectable fonts not supported */
              escmode=0;
              break;
            case 4: /* Selectable fonts not supported */
              escmode=0;
              break;
            case 5:
              if((inbuf[ip]>='0'&&inbuf[ip]<='9')||inbuf[ip]==';'||inbuf[ip]=='?')
                ansibuf[ap++]=inbuf[ip];
              else /* wasn't numerical, a ';' or a '?' */
              {
                cn=0;
                start=0;
                ansibuf[ap]=';';
                for(cp=0;cp<=ap;cp++)
                {
                  if(ansibuf[cp]=='?') ansibuf[cp]='-';
                  else
                  {
                    if(ansibuf[cp]==';')
                    {
                      combuf[cn++]=(char)atoi(ansibuf+start);
                      start=cp+1;
                    }
                  }
                }
                switch(inbuf[ip])
                {
                case 'A':
                  if(combuf[0]==0) combuf[0]=1;
                  if(y<top)
                  {
                    if(y=(y-combuf[0])<1) y=1;
                  }
                  else
                  {
                    if((y=y-combuf[0])<top) y=top;
                  }
                  a=(x==81) ? 80 : x;
                  outbuf[op++]=2;
                  outbuf[op++]=a+31;
                  outbuf[op++]=y+31;
                  break;
                case 'B':
                  if(combuf[0]==0) combuf[0]=1;
                  if(y>bottom)
                  {
                    if(y=(y+combuf[0])>24) y=24;
                  }
                  else
                  {
                    if((y=y+combuf[0])>bottom) y=bottom;
                  }
                  a=(x==81) ? 80 : x;
                  outbuf[op++]=2;
                  outbuf[op++]=a+31;
                  outbuf[op++]=y+31;
                  break;
                case 'C':
                  if(combuf[0]==0) combuf[0]=1;
                  if((x=x+combuf[0])>80) x=80;
                  outbuf[op++]=2;
                  outbuf[op++]=x+31;
                  outbuf[op++]=y+31;
                  break;
                case 'D':
                  if(combuf[0]==0) combuf[0]=1;
                  if((x=x-combuf[0])<1) x=1;
                  outbuf[op++]=2;
                  outbuf[op++]=x+31;
                  outbuf[op++]=y+31;
                  break;
                case 'H': /* curser positioning stuffs */
                case 'f':
                  if(cn==1) combuf[1]=1;
                  if((x=combuf[1])>80) x=80;
                  else
                  {
                    if(x<1) x=1;
                  }
                  if(combuf[0]==0) combuf[0]=1;
                  if(relative)
                  {
                    if((y=top+combuf[0]-1)>bottom) y=bottom;
                  }
                  else
                  {
                    if((y=combuf[0])>24) y=24;
                  }
                  outbuf[op++]=2;
                  outbuf[op++]=x+31;
                  outbuf[op++]=y+31;
                  break;
                case 'm':
                  for(cp=0;cp<cn;cp++)
                  {
                    switch(combuf[cp])
                    {
                    case 0:
                      outbuf[op++]=0x1f;
                      outbuf[op++]=0x21;
                      inverse=0;
                      outbuf[op++]=0x1f;
                      outbuf[op++]=0x23;
                      underline=0;
                      outbuf[op++]=0x1f;
                      outbuf[op++]=0x25;
                      blink=0;
                      outbuf[op++]=0x1b;
                      outbuf[op++]=0x32;
                      outbuf[op++]=mainfore;
                      bold=0;
                      break;
                    case 1:
                      outbuf[op++]=0x1b;
                      outbuf[op++]=0x32;
                      outbuf[op++]=mainbold;
                      bold=1;
                      break;
                    case 4:
                      outbuf[op++]=0x1f;
                      outbuf[op++]=0x22;
                      underline=1;
                      break;
                    case 5:
                      outbuf[op++]=0x1f;
                      outbuf[op++]=0x24;
                      blink=1;
                      break;
                    case 7:
                      outbuf[op++]=0x1f;
                      outbuf[op++]=0x20;
                      inverse=1;
                    }
                  }
                  break;
                case 'K':
                  if(cn==0) combuf[0]=0;
                  switch(combuf[0])
                  {
                  case 0:
                    outbuf[op++]=0x1f;
                    outbuf[op++]=0x21;
                    outbuf[op++]=4;
                    if(inverse)
                    {
                      outbuf[op++]=0x1f;
                      outbuf[op++]=0x20;
                    }
                    break;
                  case 1:
                    if(x>1)
                    {
                      write(stdout_r,outbuf,op);
                      op=0;
                      owset(stdout_r,0,0,y-1,x-1,1,mainfore,mainback);
                      write(stdout_r,"\x0c",1);
                      owend(stdout_r,underline,blink,inverse);
                    }
                    break;
                  case 2:
                    outbuf[op++]=0x1f;
                    outbuf[op++]=0x21;
                    outbuf[op++]=3;
                    if(inverse)
                    {
                      outbuf[op++]=0x1f;
                      outbuf[op++]=0x20;
                    }
                    break;
                  }
                  break;
                case 'J':
                  if(cn==0) combuf[0]=0;
                  switch(combuf[0])
                  {
                  case 0:
                    outbuf[op++]=0x1f;
                    outbuf[op++]=0x21;
                    outbuf[op++]=11;
                    if(y==23)
                    {
                      outbuf[op++]=10;
                      outbuf[op++]=3;
                      outbuf[op++]=6;
                    }
                    if(inverse)
                    {
                      outbuf[op++]=0x1f;
                      outbuf[op++]=0x20;
                    }
                    break;
                  case 1:
                    if(y>1)
                    {
                      write(stdout_r,outbuf,op);
                      op=0;
                      owset(stdout_r,0,0,0,80,y-1,mainfore,mainback);
                      write(stdout_r,"\x0c",1);
                      owend(stdout_r,underline,blink,inverse);
                    }
                    if(x>1)
                    {
                      write(stdout_r,outbuf,op);
                      op=0;
                      owset(stdout_r,0,0,y-1,x-1,1,mainfore,mainback);
                      write(stdout_r,"\x0c",1);
                      owend(stdout_r,underline,blink,inverse);
                    }
                    break;
                  case 2:
                    outbuf[op++]=0x1f;
                    outbuf[op++]=0x21;
                    outbuf[op++]=12;
                    outbuf[op++]=2;
                    outbuf[op++]=x+31;
                    outbuf[op++]=y+31;
                    if(inverse)
                    {
                      outbuf[op++]=0x1f;
                      outbuf[op++]=0x20;
                    }
                  }
                  break;
                case 'r':
                  if(cn==1 || combuf[1]>24) combuf[1]=24;
                  if(combuf[0]<1) combuf[0]=1;
                  else
                  {
                    if(combuf[0]>24) combuf[0]=24;
                  }
                  if(combuf[1]>=combuf[0])
                  {
                    top=combuf[0];
                    bottom=combuf[1];
                    if(relative) y=top;
                    else y=1;
                    x=1;
                    outbuf[op++]=2;
                    outbuf[op++]=x+31;
                    outbuf[op++]=y+31;
                  }
                  break;
                case 'g':
                  switch(combuf[0])
                  {
                  case 0:
                    tab[x]=0;
                    break;
                  case 3:
                    for(cp=1;cp<80;cp++) tab[cp]=0;
                  }
                  break;
                case 'h':
                  for(cp=0;cp<cn;cp++)
                  {
                    switch(combuf[cp])
                    {
                    case 20:
                      autocr=1;
                      break;
                    case -1:
                      ckm=1;
                      break;
                    case -2:
                      emulation=3;
                      break;
                    case -6:
                      relative=1;
                      y=top;
                      x=1;
                      outbuf[op++]=2;
                      outbuf[op++]=x+31;
                      outbuf[op++]=y+31;
                      break;
                    case -7:
                      autowrap=1;
                    }
                  }
                  break;
                case 'l':
                  for(cp=0;cp<cn;cp++)
                  {
                    switch(combuf[cp])
                    {
                    case 20:
                      autocr=0;
                      break;
                    case -1:
                      ckm=0;
                      break;
                    case -2:
                      emulation=2;
                      top=1;
                      bottom=24;
                      bold=0;
                      inverse=0;
                      underline=0;
                      blink=0;
                      outbuf[op++]=31;
                      outbuf[op++]=0x21;
                      outbuf[op++]=31;
                      outbuf[op++]=0x23;
                      outbuf[op++]=31;
                      outbuf[op++]=0x25;
                      outbuf[op++]=27;
                      outbuf[op++]=0x32;
                      outbuf[op++]=mainfore;
                      goto nowvt52;
                    case -6:
                      relative=0;
                      x=1;
                      y=1;
                      outbuf[op++]=2;
                      outbuf[op++]=x+31;
                      outbuf[op++]=y+31;
                      break;
                    case -7:
                      autowrap=0;
                    } 
                  }    
                case 'n':
                  switch(combuf[0])
                  {
                  case 6:
                    sprintf(xbuf,"\x1b[%02d;%02dR",x,y);
                    write(path,xbuf,8);
                    break;
                  case 5:
                    xbuf[0]=27;
                    xbuf[1]='[';
                    xbuf[2]='0';
                    xbuf[3]='n';
                    write(path,xbuf,4);
                  }
                  break;
                case 'c':
                  if(combuf[cp]==0)
                  {
                    sprintf(xbuf,"\x1b[?1;0c");
                    write(path,xbuf,7);
                  }
                  break;
                }
                escmode=0;
              }   
            }          
          }            
        }              
      }                
      write(stdout_r,outbuf,op);
    }
  }
  
  return 0;
}

int owset(path,svs,cpx,cpy,szx,szy,prn1,prn2)
char path,svs,cpx,cpy,szx,szy,prn1,prn2;
{
  char buffer[9];
  buffer[0]=27;
  buffer[1]=34;
  buffer[2]=svs;
  buffer[3]=cpx;
  buffer[4]=cpy;
  buffer[5]=szx;
  buffer[6]=szy;
  buffer[7]=prn1;
  buffer[8]=prn2;
  return write(path,buffer,9);
}

int owend(path,underline,blink,inverse)
char path,underline,blink,inverse;
{
  char buffer[8];
  int p;

  p=0;
  buffer[p++]=27;
  buffer[p++]=35;
  if(underline){
    buffer[p++]=31;
    buffer[p++]=34;
  }
  if(blink){
    buffer[p++]=31;
    buffer[p++]=36;
  }
  if(inverse){
    buffer[p++]=31;
    buffer[p++]=32;
  }
  return write(path,buffer,p);
}

int cls(path)
int path;
{
  return write(path,"\x0c",1);
}

int setopt(int path, char *buffer)
{
  struct registers reg;

  reg.rg_a=(char)path;
  reg.rg_b=0;
  reg.rg_x=(int)buffer;
  return _os9(I_SETSTT,&reg);
}

int getopt(int path, char *buffer)
{
  struct registers reg;

  reg.rg_a=(char)path;
  reg.rg_b=0;
  reg.rg_x=(int)buffer;
  return _os9(I_GETSTT,&reg);
}

