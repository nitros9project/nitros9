/*  gproto.c   These are the g protocol routines for UUCPbb package.
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

#include "uucp.h"
#include "uucico.h"

#define CLOSE2    9                                 /* Added --BGP */

#ifdef DEBUG
#define debuglvl ((int)0x62726164)
#endif


/* used for a quick calculation of packet sizes, only in this file */
static int uucpbufsiz[9] = {0, 32, 64, 128, 256, 512, 1024, 2048, 4096};

/* This variable tells swin_flush() to accept a LDATA(HY) in response to
   a LDATA(HY) sent by us.  Normally, only an RR or RJ are accepted -- BAS */

static QQ flag eat_HY = FALSE;                             /* BAS */
static char msg[200];


int gproto()
{
     register flag state;
     short length, i;
     int qq = 0;

     /* sseq needs to be initialized for wtcontrol */
     sseq = 0;

     /* Tell remote the window size we can handle */
     wtcontrol (INITA | rec_window);

     if (rdpacket (msg, &length) != INITA)
       {
          logerror ("bad response to INITA");
          return (ABORT);
       }

     /* get the size the remote can handle */
     winsiz = inpacket.C & 0x07;

     /* Use the window size the remote sent us or our size, whichever is
        smaller. */

     winsiz = min (rec_window, winsiz);

     /* Set data packet size */
     if (debuglvl > 4)
          fprintf (log, "Sent: INITB %d\n", rec_segment);

     wtcontrol (INITB | rec_segment-1);

     if (rdpacket (msg, &length) != INITB)
       {
          logerror ("bad response to INITB");
          return (ABORT);
       }

     /* Get the data segment size the remote wants to use. */
     segsiz = inpacket.C & 0x07;

     /* Tell the remote the window we will use. */
     wtcontrol (INITC | winsiz);

     for (i = 0; i < 4; ++i)
          if (rdpacket (msg, &length) != INITC)
               logerror ("bad response to INITC");
          else
               break;

     winsiz = inpacket.C & 0x07;

     if (debuglvl > 0)
          fprintf (log,
                   "%s %s %s DEBUG--gproto: protocol started; segsize = %d, winsize = %d\n",
                   sender, sysname, gtime(), segsiz, winsiz);

     for (rseq = sseq = 0, state = role;;)
          switch (state)
            {
               case MASTER:
                    state = master();
                    break;

               case SLAVE:
                    state = slave();
                    break;

               /* The close sequence can be started from either side. This
                  is the case when we have not been sent a CLOSE yet. -BAS

                  That is:
                      US          THEM

                      CLOSE  ->
                             <-   CLOSE */

               case CLOSE:
                    /* close up shop */
                    for (i = 0; i < 3; i++)
                      {
                         wtcontrol (CLOSE);

                         if (rdpacket (msg, &length) == CLOSE)
                              return (_END);
                      }
                    break;

               /* This case should handle that case where we have been sent a
                  CLOSE. The CLOSE itself is read by master() and slave() -BAS

                  That is:
                     US        THEM
                           <-   CLOSE [read at master() or slave()]
                     CLOSE ->  */

               case CLOSE2:
                    wtcontrol (CLOSE);
                    return (_END);
                    break;
            }
}



/* This should ONLY be executed when the role is MASTER otherwise, things
   will get confused --BAS */
 

int master()
{
     register int type;
     int len;

     /* find and perform all queued work as master */
     findwork();
     
#ifndef DEBUG
     if (debuglvl > 1)
          fputs ("master: asking remote if it has work for us\n", log);
else      
     if (debuglvl > 1)
          fputs ("master: sending H to Slave to see if it has work for us\n",
                 log);
#endif

     /* does other system have queued work for us? */
     wtmsg ("H");

#ifdef DEBUG
     fputs("master: Sent H to slave\n",log);
#endif

     /* The only valid responses from H should be HY or HN.  An HN means that
        the slave has work to do and roles should be switched.  HY means it's
        ok to begin to shut the protocol down --BAS */

#ifdef DEBUG
     fputs("master: About to read an HY or HN from slave\n",log);
#endif

     rdmsg (msg);

#ifdef DEBUG
     fputs("master: Read an HY or HN from slave\n",log);
#endif

     if (strncmp (msg, "HN", 2) == 0)
       {
          if (debuglvl > 1)
               fputs ("master: Slave wants to reverse roles\n", log);

          role = SLAVE;
          return (SLAVE);
       }

     /* We should probably check to make sure that message was an HY --BAS */

#ifndef DEBUG
     if (debuglvl > 1)
          fputs ("master: remote says no, hang up\n", log);
#else
     if (debuglvl > 1)
          fputs ("master: slave must want to quit\n", log);

     fputs ("master: About to send final HY to slave\n", log);
#endif

     /* We need to munch an LDATA(HY) when we run Taylor UUCP  -- BAS */
     eat_HY = TRUE;
     swin_send (LDATA,"HY",2);
     eat_HY = FALSE;

#ifdef DEBUG
     fputs ("master: Sent final HY to slave\n", log);
#endif

     if (debuglvl > 3)
       fputs ("master: About to read last message from slave\n", log);

     type = getpacket (msg, &len);

#ifdef DEBUG
     fputs ("master: Got last message from slave\n", log);
#endif

     switch (type)
       {
          /* This case takes care of any LDATA or SDATA packets at the end
             Apparently Ultrix uucico sends this -- BAS */

          case LDATA:
          case SDATA:
               if (debuglvl > 3)
                    fputs ("master: slave sent us a LDATA or SDATA, RR it and send a CLOSE.\n",
                           log);

               rseq = (++rseq & 0x07);
               wtcontrol (RR | rseq);
               break;

          /* This is the usual case for Sun uucico [really System V, I think]
              and whatever UUNET Tech. uses. -- BAS */

          case RR:
               if (debuglvl > 3)
                    fputs ("master: slave sent us an RR, send them CLOSE.\n",
                           log);

              return (CLOSE);
              break;

          /* This seems to be the usual case for Taylor UUCP. -- BAS */
          case CLOSE:
               if (debuglvl > 3)
                    fputs ("master: slave sent us an CLOSE, send them one.\n",
                           log);

               return (CLOSE2);
               break;

          /* This may handle everything else, maybe not???  Who knows....
             -- BAS */

          default:
               if (debuglvl > 1)
                 {
                    fprintf (log,
                             "master: slave sent us something--> %d\n",
                             type);
                    fputs ("          send them a CLOSE.\n", log);
                 }
               break;
       }
     return (CLOSE);
}



/* This should ONLY be executed when role is SLAVE, otherwise things will get
   confused.  --BAS */

int slave()
{
     register int type;
     int len;

     /* do all the queued work for us */
     for (rdmsg (msg);  strcmp (msg, "H") != 0;  rdmsg (msg))
       {
          if (debuglvl > 1)                                        /* DEBUG */
               fprintf (log, "DEBUG--slave: cline=%s:\n", msg);

          slavework (msg);
       }

     /* We need to check to see if we have any work to send --BAS */
     if (anywork() == 1)
       {
          if (debuglvl > 3)
               fputs ("slave: switch roles, send HN to master\n", log);

          wtmsg ("HN");

#ifdef DEBUG
          fputs ("slave: Sent an HN to master\n", log);
#endif
          role = MASTER;
          return (MASTER);
       }

     if (debuglvl > 3)
          fputs ("slave: slave has no work to do, send last HY to master\n",
                 log);

     wtmsg ("HY");

#ifdef DEBUG
     fputs ("slave: Sent last HY to master\n", log);
#endif

     if (debuglvl > 3)
          fputs ("slave: read last message from master\n", log);

     /* According to the spec. on the 'g' protocol, the only thing that should
        be sent from the master is a LDATA(HY), however, at least Ultrix
        uucico will send a CLOSE.  Nice huh?... --BAS */

     type = getpacket (msg, &len);

#ifdef DEBUG
     fputs ("slave: Got last message from master\n", log);
#endif

     switch (type)
       {
          /* This seems to be the usual case for Sun and Taylor, most uucicos,
             I think -- BAS */

          case LDATA:
          case SDATA:
               if (debuglvl > 3)
                    fputs ("slave: master sent us a LDATA or SDATA, RR it and send a CLOSE.\n",
                           log);

               rseq = (++rseq & 0x07);
               wtcontrol (RR | rseq);
               break;

          /* Never seen this one actually execute.  -- BAS */
          case RR:
               if (debuglvl > 3)
                    fputs ("slave: master sent us an RR, send them CLOSE.\n",
                           log);

               return (CLOSE);
               break;

          /* Ultrix apparently sends this.  -- BAS */
          case CLOSE:
               if (debuglvl > 3)
                    fputs ("slave: master sent us an CLOSE, send them one.\n",
                           log);

               return (CLOSE2);
               break;

          /* Don't know what this could be, really.... -- BAS */
          default:
               if (debuglvl > 1)
                 {
                    fprintf (log,
                             "slave: master sent us something--> %d\n", type);
                    fputs ("          send them a CLOSE.\n", log);
                 }
               break;
       }
     return (CLOSE);
}



/* swin_init   initialize sending window */

int swin_init()
{
     swin = sseq;
}



/* swin_send   Send one packet, update window if reply is ready return only if
               window is not fully extended. */

int swin_send (type, data, length)
char type, *data;
int length;
{
     /* send current packet */
     sseq = (++sseq & 7);
     wtdata (type, data, length);
     swin_flush (FALSE);
}



/* swin_flush  wait for sending window to be emptied
      if sw_flag == TRUE, return when swin == sseq
      if sw_flag != TRUE, return when window is not fully extended */

int swin_flush (sw_flag)
int sw_flag;
{
     char tseq = sseq;
     register int type;
     int length, size;
     flag ready = TRUE;
     struct pk *outp;
#ifndef _OSK
     unsigned cksum;
#else
     unsigned short cksum;
#endif

     /* read response if one is ready
        on error, retransmit all packets up to sseq
        return only when it's safe to send another packet
           ie: if window is full, wait for response from remote.

        Eddie Kuns fixed a bug in the original routine where retransmitting
        a block required that some values be updated first.  Eddie's fix is
        included here. */

     do
       {
          /* If we have to retransmit a packet, do so */
          if (tseq != sseq)
            {
               tseq = (++tseq & 7);
               outp = &(outpacket[tseq]);

               size = uucpbufsiz[outp->K];

               /* get old data checksum so we can update it later */
               cksum = MAGIC - ((outp->C0 & 0xff) | (outp->C1 << 8));
               cksum ^= (outp->C & 0xFF);

               /* first update "last packet read" counter */
               outp->C &= 0xf8;
               outp->C |= rseq & 0x7;

               /* now update checksums */
               cksum = MAGIC - (cksum ^ (outp->C & 0xFF));
               outp->C0 = cksum & 0xFF;
               outp->C1 = (cksum >> 8) & 0xFF;

               outp->X = outp->K ^ outp->C0 ^ outp->C1 ^ outp->C;

               write(port, outp, size + 6);

               if (debuglvl > 4)
                    dumpcode("R> ", outp);

               if (debuglvl > 8)
                {
                    fputs ("        ", log);
                    strdump (outp->data);
                }
            }

          /* read reply if one is waiting
             if we cannot exit yet, force reading a packet
             if retransmitting packets, do not force reading a packet.

             _gs_rdy() is necessary, sliding windows are disabled otherwise */

          if (_gs_rdy (port) > 0  ||  (!ready && tseq == sseq))
            {
               type = getpacket (msg, &length);

               /* This is a bit of a hack to keep master() clean.  Taylor
                  UUCP, and perhaps others, like to send strange things at the
                  shutdown of the protocol --BAS */

               if (eat_HY  &&  type == LDATA)
                    if (strncmp (msg, "HY", 2) == 0)
                      {
                         if (debuglvl > 3)
                              fputs ("swin_flush: eating an LDATA(HY) and sending RR\n",
                                     log);

                         /* Tell a bit of a lie to the switch statement that
                            follows... -- BAS */
                         type = RR;
                         rseq = (++rseq & 0x07);
                         wtcontrol (RR | rseq);
                      }

               switch (type)
                 {
                    /* All is OK! */
                    case RR:
                         swin = inpacket.C & 7;        /* slide window here */
                         break;

                    /* Error detected */
                    case RJ:
                         swin = inpacket.C & 7;         /* last good packet */
                         tseq = swin;          /* retransmit at next packet */
                         break;

                    /* Huh?  Unexpected packet type!  Log error. --REB */
                    default:
                         if (debuglvl > 0)
                              fprintf (log,
                                       "\n%s %s %s Unexpected packet type: $%X msg = %s\n",
                                       sender, sysname, gtime(), type, msg);
                 }
            }

          /* set value of "ready"
             TRICK: open window = ((sseq + 7) - swin) & 7
                                = (sseq - swin) & 7
                    even when sseq < swin! */

          if (sw_flag)
               ready = (swin == sseq);
          else
               ready = (((sseq - swin) & 7) < winsiz);
       }
     while (tseq != sseq || !ready);
}



/* wtdata  --packetize data + send.  Don't wait for response */

int wtdata (type, data, length)
char type, *data;
int length;
{
     register struct pk *outp;
#ifdef _OSK
#define USE_C_CHKSUM
#endif

#ifdef DCC_LW
#define USE_C_CHKSUM
#endif

#ifdef USE_C_CHKSUM
     short cksum;
#else
     unsigned cksum;
#endif
     int size, diff, i;
     char *p;

     outp = &(outpacket[sseq]);

     for (i = 0; i < 64; i++)
          outp->data[i] = 0;

     outp->DLE = 0x10;
     p = outp->data;
     outp->C = type;

     if (type == (char) SDATA)
       {
          size = 64;
          outp->K = K64;
          diff = size - length;

          if ((diff & 0x80) == 0)
               *p++ = (diff & 0xFF);
          else
            {
               *p++ = (diff & 0xFF) | 0x80;
               *p++ = diff >> 7;
            }
       }
     else
       {
          size = 64;          /* our packet size */
          outp->K = K64;
       }

     outp->C |= (sseq & 0x7) << 3;
     outp->C |= rseq & 0x7;

     /* Move data into outgoing packet */
     memcpy (p, data, length < size ? length : size);

     cksum = MAGIC - (g_chksum (outp->data, size) ^ (outp->C & 0xFF));
     outp->C0 = cksum & 0xFF;
     outp->C1 = (cksum >> 8) & 0xFF;

     outp->X = outp->K ^ outp->C0 ^ outp->C1 ^ outp->C;

     if (debuglvl > 7)
         dumpcode (">> ", outp);

     write (port, outp, size + 6);
}



/* wtmsg   --write g-proto message, wait for RR */

int wtmsg (message)
char *message;
{
     register char *p;

     if (debuglvl >= 5)
          fprintf (log, ">> %s\n", message);

     p = message;

     /* initialize sliding windows */
     swin_init();

     /* send message; swin_send updates sseq */
     do
       {
          int lenp = strlen (p);

          /* write data packet containing message */
          swin_send (LDATA, p, lenp);
          p += lenp < 64  ? lenp : 64;
       }
     while (*p);

     /* make sure all packets are sent */
     swin_flush (TRUE);
}



/* wtcontrol  --write control packet, don't wait for response */

int wtcontrol (code)
register int code;
{
     static struct pk outp;
#ifdef _OSK
     short cksum;
#else
     int cksum;
#endif

     code &= 0xFF;
     outp.DLE = 0x10;
     outp.K = KCONTROL;
     outp.C = code;
     cksum = MAGIC - code;
     outp.C0 = cksum & 0xFF;
     outp.C1 = (cksum >> 8) & 0xFF;
     outp.X = outp.K ^ outp.C0 ^ outp.C1 ^ code;

     if (debuglvl > 7)
          dumpcode (">> ", &outp);

     write (port, &outp, 6);
}



/* rdpacket  --read a packet

         Return:
             data
             length of data (zero if no data)
             type of packet (CLOSE, LDATA, SDATA, RR, INITA, etc) */

int rdpacket (data, length)
char *data;
int  *length;
{
     char c, *p;
#ifdef _OSK
     short cksum;
#else
     unsigned cksum;
#endif
     int diff = 0, type;

     *length = 0;
     *data = '\0';

     /* scan for leading DLE */
     do
       {
          if (readport (&c, PKTTIME, GET_TRY) == TIMEDOUT)
               longjmp (env, FATAL);
       }
     while (c != 0x10);

     inpacket.DLE = c;

     /* read packet header */
     if (readport (&inpacket.K, PKTTIME, MAXTRY) == TIMEDOUT)
          longjmp (env, FATAL);

     if (readport (&inpacket.C0, PKTTIME, MAXTRY) == TIMEDOUT)
          longjmp (env, FATAL);

     if (readport (&inpacket.C1, PKTTIME, MAXTRY) == TIMEDOUT)
          longjmp (env, FATAL);

     if (readport (&inpacket.C, PKTTIME, MAXTRY) == TIMEDOUT)
          longjmp (env, FATAL);

     if (readport (&inpacket.X, PKTTIME, MAXTRY) == TIMEDOUT)
          longjmp (env, FATAL);

     /* return type of packet */
     if ((inpacket.C & 0xC0) == 0)
          type = inpacket.C & 0x38;
     else
          type = inpacket.C & 0xC0;

     /* check XOR checksum of packet */
     if ((inpacket.K ^ inpacket.C0 ^ inpacket.C1 ^ inpacket.C) != inpacket.X)
          return (FALSE);

     if (debuglvl > 7)
          dumpcode ("<< ", &inpacket);

     /* control packet? */
     if (inpacket.K == KCONTROL)
          return (type);

     /* if not control packet, read data */
     if (inpacket.K != KCONTROL)
       {
          if (inpacket.K == 0)
               *length = 0;
          else
            {
               *length = uucpbufsiz[inpacket.K];

               /* If we don't get a whole packet, return error */
               if (readfill (inpacket.data, *length) != *length)
                    return (FALSE);
            }
        }

     cksum = MAGIC - (g_chksum (inpacket.data, *length)
              ^(inpacket.C & 0xFF));

     /* short data packet, or long data packet? */
     if ((inpacket.C & 0xC0) == SDATA)
       {
          /* short data packet */
          diff = inpacket.data[0] & 0xFF;
          p = inpacket.data;

          if ((diff & 0x80) == 0)
            {
               *length -= diff;
               p++;
            }
          else
            {
               diff &= 0x7F;
               diff |= ((inpacket.data[1] & 0xFF) << 7);
               *length -= diff;
               p += 2;
            }
       }
     else
       {
          /* long data packet */
          p = inpacket.data;
       }

     /* check checksum of data portion */
     if (cksum != ((inpacket.C1 << 8) | (inpacket.C0 & 0xFF)))
          return (FALSE);
     else
       {
          if (*length)
               memcpy (data, p, *length);

          return (type);
       }
}



/* rdmsg  --read g-proto message */

int rdmsg (message)
char *message;
{
     register int i;
     int msglen, length, type;
     char *p;

     p = message;

     do
       {
          for (i = 0; i < GET_TRY; i++)
               if ((type = getpacket (p, &length)) == LDATA || type == SDATA)
                 {
                    rseq = (++rseq & 0x7);
                    wtcontrol (RR | rseq);
                    break;
                 }

          /* fatal error abort back to uucico() */
          if (i == GET_TRY)
            {
               logerror ("rdmsg: didn't get message");
               longjmp (env, FATAL);
            }

          msglen = strlen (inpacket.data);
          p += msglen;

       }
     while (type == LDATA && length == msglen);

     if (debuglvl > 4)
          fprintf (log, "<< %s\n", message);
}



/* getpacket   --get data packet */

int getpacket (data, length)
char *data;
int *length;
{
     int status;
     register int tries;

     for (tries = 0; tries < GET_TRY; tries++)
       {
          status = rdpacket (data, length);

          if (!status)
               wtcontrol (RJ | rseq);
          else
               return (status);
       }

     /* If we get too many errors, abort to highest level and exit. */
     putc ('\n', log);
     logerror ("getpacket: too many checksum errors in received packets");
     fputs ("                       *** TRANSFER ABORTED ***\n", log);
     longjmp (env, FATAL);
}



/*========== Calculate checksum routines for 6809, 6309 and OSK ==========*/

#ifdef _OSK
#define USE_C_G_CHKSUM
#endif

#ifdef DCC_LW
#define USE_C_G_CHKSUM
#endif

#ifdef USE_C_G_CHKSUM
/* g_chksum for OSK borrowed from Taylor UUCP */

int g_chksum (z, c)
register char *z;
register int c;
{
     register unsigned int ichk1, ichk2;

     ichk1 = 0xffff;
     ichk2 = 0;

     do
       {
          register unsigned int b;

          /* rotate ichk1 left */
          if ((ichk1 & 0x8000) == 0)
               ichk1 <<= 1;
          else
            {
               ichk1 <<= 1;
               ++ichk1;
            }

          /* add next character to ichk1 */
          b = *z++ & 0xff;
          ichk1 += b;

          /* add ichk1 xor the checksum position in the buffer counting
             from the back to ichk2. */
          ichk2 += ichk1 ^ c;

          /* if the character was zero, or adding it to ichk1 causes
             an overflow, xor ichk2 to ichk1 */
          if (b == 0  ||  (ichk1 & 0xffff)  < b)
               ichk1 ^= ichk2;
       }
     while (--c > 0);

     return (ichk1 & 0xffff);
}

#else

#  ifndef m6309
#  asm        assembler routine for OS9/6809 using 6809

*        Remember below that C identifiers are 8 characters long

 vsect dp
ChkSum rmb 2
X      rmb 2
 endsect

g_chksum:
 ldd #0
 std  <X
 deca
 decb
 std  <ChkSum

 pshs u,y
 ldu  6,s       Get pointer into U.
 ldy  8,s       Get count into Y
 beq  Fin_CRC   In case the count = 0
Upd_CRC1
 ldd  <ChkSum
 aslb           ChkSum <<= 1  (and += 1 if negative)
 rola
 adcb #0
 std  <ChkSum
 pshs d         t = chksum
 clra           chksum += *(s++)
 ldb  ,u+
 addd ,s
 std  <ChkSum
 pshs y         X += chksum ^ n
 eora ,s+
 eorb ,s+
 addd <X
 std  <X
 ldd  <ChkSum   if ( (unsigned) chksum <= t)
 cmpd ,s++
 bhi  Next
 eora <X                 chksum ^= x;
 eorb <X+1
 std  <ChkSum
Next
 leay -1,y
 bne  Upd_CRC1
Fin_CRC
 puls u,y,pc

#  endasm

#  else
#  asm        assembler routine for OS9/6809 using 6309

*             This routine uses the W register.  It assumes OS-9's kernel is
*             patched so it does not destroy the contents of W during
*             interrupts.  Burke & Burke's PowerBoost is an example of such
*             a patch.

*        Remember below that C identifiers are 8 characters long

 vsect dp
ChkSum rmb 2
X      rmb 2
 endsect

g_chksum:
 fdb  $104f    clrd
 std  <X
 fdb  $104a    decd
 std  <ChkSum
 pshs u,y
 ldu  6,s       Get pointer into U.
 ldy  8,s       Get count into Y
 beq  Fin_CRC   In case the count = 0

Upd_CRC1
 ldd  <ChkSum
 fdb  $1048        asld      ChkSum <<= 1  (and += 1 if negative)
 adcb #0
 std  <ChkSum
 fdb $1f06         tfr d,w    t = chksum
 clra                         chksum += *(s++)
 ldb  ,u+
 fcb $10,$30,$60   addr w,d
 std  <ChkSum
 fcb $10,$36,$20   eorr y,d   X += chksum ^ n
 addd <X
 std  <X
 ldd  <ChkSum                 if ( (unsigned) chksum <= t)
 fcb $10,$37,$60   cmpr w,d
 bhi  Next
 eora <X                      chksum ^= x;
 eorb <X+1
 std  <ChkSum

Next
 leay -1,y
 bne  Upd_CRC1

Fin_CRC
 puls u,y,pc
#  endasm
#  endif
#endif
