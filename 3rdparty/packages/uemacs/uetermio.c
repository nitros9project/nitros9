/*
 * The functions in this file negotiate with the operating system for
 * characters, and write characters in a barely buffered fashion on the display.
 * All operating systems.
 */
#include        <stdio.h>
#include        "ueed.h"

#ifdef AMIGA
#define NEW 1006
#define LEN 1

static long terminal;
#endif

#ifdef VMS
#include        <stsdef.h>
#include        <ssdef.h>
#include        <descrip.h>
#include        <iodef.h>
#include        <ttdef.h>

#define NIBUF   128                     /* Input  buffer size           */
#define NOBUF   1024                    /* MM says bug buffers win!     */
#define EFN     0                       /* Event flag                   */


char    obuf[NOBUF];                    /* Output buffer                */
int     nobuf;                          /* # of bytes in above          */
char    ibuf[NIBUF];                    /* Input buffer                 */
int     nibuf;                          /* # of bytes in above          */
int     ibufi;                          /* Read index                   */
int     oldmode[2];                     /* Old TTY mode bits            */
int     newmode[2];                     /* New TTY mode bits            */
short   iochan;                         /* TTY I/O channel              */
#endif

#ifdef CPM
#include        <bdos.h>
#endif

#ifdef MSDOS
#undef  LATTICE
#include        <dos.h>
#endif

#ifdef RAINBOW
#include "rainbow.h"
#endif

#ifdef V7
#include        <sgtty.h>               /* for stty/gtty functions */

struct  sgttyb  ostate;                 /* saved tty state */
struct  sgttyb  nstate;                 /* values for editor mode */
#endif

#ifdef OS9
#include        <sgstat.h>               /* for stty/gtty functions */
struct  sgbuf  ostate;                 /* saved tty state */
struct  sgbuf  nstate;                 /* values for editor mode */
#endif

#ifdef OSK
#include        <sgstat.h>             /* same as os9/6809 */
struct  sgbuf  ostate;
struct  sgbuf  nstate;
#endif

/*
 * This function is called once to set up the terminal device streams.
 * On VMS, it translates SYS$INPUT until it finds the terminal, then assigns
 * a channel to it and sets it raw. On CPM it is a no-op.
 */
ttopen()
{
#ifdef AMIGA
        terminal = Open("RAW:1/1/639/199/MicroEmacs", NEW);
#endif
#ifdef VMS
        struct  dsc$descriptor  idsc;
        struct  dsc$descriptor  odsc;
        char    oname[40];
        int     iosb[2];
        int     status;

        odsc.dsc$a_pointer = "SYS$INPUT";
        odsc.dsc$w_length  = strlen(odsc.dsc$a_pointer);
        odsc.dsc$b_dtype   = DSC$K_DTYPE_T;
        odsc.dsc$b_class   = DSC$K_CLASS_S;
        idsc.dsc$b_dtype   = DSC$K_DTYPE_T;
        idsc.dsc$b_class   = DSC$K_CLASS_S;
        do {
                idsc.dsc$a_pointer = odsc.dsc$a_pointer;
                idsc.dsc$w_length  = odsc.dsc$w_length;
                odsc.dsc$a_pointer = &oname[0];
                odsc.dsc$w_length  = sizeof(oname);
                status = LIB$SYS_TRNLOG(&idsc, &odsc.dsc$w_length, &odsc);
                if (status!=SS$_NORMAL && status!=SS$_NOTRAN)
                        exit(status);
                if (oname[0] == 0x1B) {
                        odsc.dsc$a_pointer += 4;
                        odsc.dsc$w_length  -= 4;
                }
        } while (status == SS$_NORMAL);
        status = SYS$ASSIGN(&odsc, &iochan, 0, 0);
        if (status != SS$_NORMAL)
                exit(status);
        status = SYS$QIOW(EFN, iochan, IO$_SENSEMODE, iosb, 0, 0,
                          oldmode, sizeof(oldmode), 0, 0, 0, 0);
        if (status!=SS$_NORMAL || (iosb[0]&0xFFFF)!=SS$_NORMAL)
                exit(status);
        newmode[0] = oldmode[0];
        newmode[1] = oldmode[1] | TT$M_PASSALL | TT$M_NOECHO;
        status = SYS$QIOW(EFN, iochan, IO$_SETMODE, iosb, 0, 0,
                          newmode, sizeof(newmode), 0, 0, 0, 0);
        if (status!=SS$_NORMAL || (iosb[0]&0xFFFF)!=SS$_NORMAL)
                exit(status);
#endif
#ifdef CPM
#endif
#ifdef MSDOS
#endif
#ifdef V7
        gtty(1, &ostate);                       /* save old state */
        gtty(1, &nstate);                       /* get base of new state */
        nstate.sg_flags |= RAW;
        nstate.sg_flags &= ~(ECHO|CRMOD);       /* no echo for now... */
        stty(1, &nstate);                       /* set mode */
#endif
#ifdef OS9
        getstat(0, 0, &ostate);                       /* save old state */
        getstat(0, 0, &nstate);                       /* get base of new state */
        nstate.sg_echo = 0;       /* no echo for now... */
        nstate.sg_bellch = 0;
        nstate.sg_bsech = 0;
        nstate.sg_kbach = 0;
        nstate.sg_kbich = 0;
        nstate.sg_psch = 0;
        nstate.sg_dulnch = 0;
        nstate.sg_rlnch = 0;
        nstate.sg_eofch = 0;
        nstate.sg_eorch = 0;
        nstate.sg_dlnch = 0;
        nstate.sg_bspch = 0;
        nstate.sg_pause = 0;
        nstate.sg_alf = 0;
        nstate.sg_backsp = 0;
        setstat(0, 0, &nstate);                       /* set mode */
        stdin->_flag &= ~_SCF;
        stdin->_flag |= _RBF;
        stdout->_flag &= ~_SCF;
        stdout->_flag |= _RBF;
        setbuf(stdout,0);
#endif
#ifdef OSK
        getstat(0, 0, &ostate);                       /* save old state */
        getstat(0, 0, &nstate);                       /* get base of new state *
/
        nstate.sg_echo = 0;       /* no echo for now... */
        nstate.sg_bellch = 0;
        nstate.sg_bsech = 0;
        nstate.sg_kbach = 0;

        nstate.sg_kbich = 0;
        nstate.sg_psch = 0;
        nstate.sg_dulnch = 0;
        nstate.sg_rlnch = 0;
        nstate.sg_eofch = 0;
        nstate.sg_eorch = 0;
        nstate.sg_dlnch = 0;
        nstate.sg_bspch = 0;
        nstate.sg_pause = 0;
        nstate.sg_alf = 0;
        nstate.sg_backsp = 0;
        nstate.sg_xoff =0;     /* new for OSK */
        nstate.sg_xon  =0;
        setstat(0, 0, &nstate);                       /* set mode */
        stdin->_flag &= ~_SCF;
        stdin->_flag |= _RBF;
        stdout->_flag &= ~_SCF;
        stdout->_flag |= _RBF;
        setbuf(stdout,0);
#endif
}

/*
 * This function gets called just before we go back home to the command
 * interpreter. On VMS it puts the terminal back in a reasonable state.
 * Another no-operation on CPM.
 */
ttclose()
{
#ifdef AMIGA
        Close(terminal);
#endif
#ifdef VMS
        int     status;
        int     iosb[1];

        ttflush();
        status = SYS$QIOW(EFN, iochan, IO$_SETMODE, iosb, 0, 0,
                 oldmode, sizeof(oldmode), 0, 0, 0, 0);
        if (status!=SS$_NORMAL || (iosb[0]&0xFFFF)!=SS$_NORMAL)
                exit(status);
        status = SYS$DASSGN(iochan);
        if (status != SS$_NORMAL)
                exit(status);
#endif
#ifdef CPM
#endif
#ifdef MSDOS
#endif
#ifdef V7
        stty(1, &ostate);
#endif
#ifdef OS9
        setstat(0, 0, &ostate);
#endif
#ifdef OSK
        setstat(0, 0, &ostate);
#endif
}

/*
 * Write a character to the display. On VMS, terminal output is buffered, and
 * we just put the characters in the big array, after checking for overflow.
 * On CPM terminal I/O unbuffered, so we just write the byte out. Ditto on
 * MS-DOS (use the very very raw console output routine).
 */
ttputc(c)
char c;
{
#ifdef AMIGA
        Write(terminal, &c, LEN);
#endif
#ifdef VMS
        if (nobuf >= NOBUF)
                ttflush();
        obuf[nobuf++] = c;
#endif

#ifdef CPM
        bios(BCONOUT, c, 0);
#endif

#if defined(MSDOS) || defined(CWC86)
        dosb(CONDIO, c, 0);
#endif

#ifdef RAINBOW
        Put_Char(c);                    /* fast video */
#endif

#ifdef V7
        fputc(c, stdout);
#endif
#ifdef OS9
        putc(c, stdout);
#endif
#ifdef OSK
        putc(c, stdout);
#endif
}

/*
 * Flush terminal buffer. Does real work where the terminal output is buffered
 * up. A no-operation on systems where byte at a time terminal I/O is done.
 */
ttflush()
{
#ifdef AMIGA
#endif
#ifdef VMS
        int     status;
        int     iosb[2];

        status = SS$_NORMAL;
        if (nobuf != 0) {
                status = SYS$QIOW(EFN, iochan, IO$_WRITELBLK|IO$M_NOFORMAT,
                         iosb, 0, 0, obuf, nobuf, 0, 0, 0, 0);
                if (status == SS$_NORMAL)
                        status = iosb[0] & 0xFFFF;
                nobuf = 0;
        }
        return (status);
#endif
#ifdef CPM
#endif
#ifdef MSDOS
#endif
#ifdef V7
        fflush(stdout);
#endif
#ifdef OS9
        fflush(stdout);
#endif
#ifdef OSK
        fflush(stdout);
#endif
}

/*
 * Read a character from the terminal, performing no editing and doing no echo
 * at all. More complex in VMS that almost anyplace else, which figures. Very
 * simple on CPM, because the system can do exactly what you want.
 */
ttgetc()
{
#ifdef AMIGA
        char ch;

        Read(terminal, &ch, LEN);
        return (int) ch;
#endif
#ifdef VMS
        int     status;
        int     iosb[2];
        int     term[2];

        while (ibufi >= nibuf) {
                ibufi = 0;
                term[0] = 0;
                term[1] = 0;
                status = SYS$QIOW(EFN, iochan, IO$_READLBLK|IO$M_TIMED,
                         iosb, 0, 0, ibuf, NIBUF, 0, term, 0, 0);
                if (status != SS$_NORMAL)
                        exit(status);
                status = iosb[0] & 0xFFFF;
                if (status!=SS$_NORMAL && status!=SS$_TIMEOUT)
                        exit(status);
                nibuf = (iosb[0]>>16) + (iosb[1]>>16);
                if (nibuf == 0) {
                        status = SYS$QIOW(EFN, iochan, IO$_READLBLK,
                                 iosb, 0, 0, ibuf, 1, 0, term, 0, 0);
                        if (status != SS$_NORMAL
                        || (status = (iosb[0]&0xFFFF)) != SS$_NORMAL)
                                exit(status);
                        nibuf = (iosb[0]>>16) + (iosb[1]>>16);
                }
        }
        return (ibuf[ibufi++] & 0xFF);          /* Allow multinational  */
#endif

#ifdef CPM
        return (biosb(BCONIN, 0, 0));
#endif

#ifdef RAINBOW
        int Ch;

        while ((Ch = Read_Keyboard()) < 0);

        if ((Ch & Function_Key) == 0)
                if (!((Ch & 0xFF) == 015 || (Ch & 0xFF) == 0177))
                        Ch &= 0xFF;

        return Ch;
#endif

#ifdef MSDOS
#ifdef MWC86
        return (dosb(CONRAW, 0, 0));
#endif
#endif

#ifdef V7
        return(fgetc(stdin));
#endif
#ifdef OS9
    char ch;

        read(0, &ch, 1);
        return((int)ch);
#endif
#ifdef OSK
    char ch;

        read(0, &ch, 1);
        return((int)ch);
#endif
}

