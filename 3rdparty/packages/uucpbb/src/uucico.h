/*  uucico.h  --header file for the uucico program.
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

#include <setjmp.h>
#include <signal.h>
#include <time.h>

 /***************************************************************
  ***************************************************************
  *******  WARNING: Gremlin Zone!!                         ******
  *******           Do not mess with anything below here.  ******
  ***************************************************************
  ***************************************************************/

/* packet codes */
#define CLOSE      0x08      /* close channel */
#define RJ         0x10      /* reject */
#define RR         0x20      /* receiver ready */
#define SRJ        0x18      /* packet number to retransmit */
#define INITA      0x38      /* initialization A */
#define INITB      0x30      /* initialization B */
#define INITC      0x28      /* initialization C */
#define LDATA      0x80      /* long data */
#define SDATA      0xC0      /* short data */

/* packet size codes */
#define K32        1
#define K64        2
#define K128       3
#define K256       4
#define K512       5
#define K1024      6
#define K2048      7
#define K4096      8
#define KCONTROL   9

/* Max packet size for receiving */
#define PACKET_SIZE   K64

/* Max packet size for sending and receiving */
#define MAX_SEND_PACKET 128

#define MAGIC     0xAAAA
#define DLE_TRIES  1         /* attempts getpacket() will try to get DLE */

/* uucico roles */
#define MASTER   1
#define SLAVE    0

/* Main switch states */
#define INITIAL      0
#define OPENPORT     1
#define MAKECALL     2
#define MOPEN        3
#define SOPEN        4
#define MS_SNDRCV    5
#define _END         6
#define CHATERROR    7
#define PORTBUSY     8
#define NOCARRIER   12
#define NODIALTONE  13
#define BUSY        14
#define NOANSWER    15
#define LOGERR      16
#define MSGTIME      5         /* seconds to wait for a message */
#define PKTTIME      5         /* seconds to wait for a packet */

/* g protocol packet definition */
struct pk
        {    char DLE,       /* DLE character */
                  K,         /* packet size code */
                  C0,        /* checksum (lo) */
                  C1,        /* checksum (hi) */
                  C,         /* control packet code */
                  X,         /* XOR of K, C0, C1 and C */
                             /* data buffer */
                  data[MAX_SEND_PACKET+1];
        };

extern QQ int rec_segment;
extern QQ int rec_window;
extern QQ flag dropDTR;
extern char *nodename, fname[], temp[];

EXTERN QQ flag logopen;                         /* log file open flag */
EXTERN QQ flag role;                            /* default role is master */
EXTERN QQ flag ramdisk;                         /* don't use RAM disk yet */
EXTERN QQ flag quiet;                           /* print to stdout --BGP  */
EXTERN QQ flag logflag;                         /* write /DD/LOG/uulog --TK */
EXTERN QQ flag normal_end, uuxflag;
EXTERN QQ flag endflag, offhook;
EXTERN QQ int winsiz;                           /* window size */
EXTERN QQ int segsiz;                           /* packet size */
EXTERN QQ int port;                             /* path for device we use */
EXTERN QQ int debuglvl;
EXTERN QQ char protocol;                        /* name of protocol we use */
EXTERN QQ char rseq, sseq, swin;                /* used in gproto.c */
EXTERN QQ FILE *log;

/* globals added/changed --REB */
EXTERN char phone[25],                          /* remote's number */
            baud[7],                            /* computer to modem speed */
            device[5],                          /* device name of port */
            sysname[9],                         /* remote's name */
            sender[15],                         /* who is doing the sending */
            modemreset[20],                     /* modem reset string */
            dialscript[128],                   /* script for dialing remote */
            chatscript[128];              /* script for logging into remote */

#ifndef _OSK
EXTERN long start_time, endtime, call_length;
#else
EXTERN time_t start_time, endtime, call_length;
#endif

/* global environment variable for low level errors --REB */
EXTERN jmp_buf env;

/* g protocol packet buffers used by gproto.c and filexfer.c */
EXTERN struct pk inpacket, outpacket[8];

#ifdef MAIN
char *ssiz[] = {"K0","K32","K64","K128","K256","K512","K1024",
                "K2048","K4096",""};
#else
extern char *ssiz[];
#endif

/* function declarations */
void openlog(), closelog();
