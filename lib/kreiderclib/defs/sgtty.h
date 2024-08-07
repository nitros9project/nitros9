/*
 * sgtty.h - Structure for stty and gtty system calls.
 *
 * Notes:
 * OS9 Version of UNIX stty & gtty functions   11/19/84
 *  Implemented by W.G. Seaton NASA, SC-LPS-32, KSC,FL
 * UNISRC_ID: @(#)sgtty.h14.1  83/04/29
 * made changes to Bxxx constants and ioctl argument list
 *
 * Edt/Rev  YYYY/MM/DD  Modified by
 * Comment
 * ------------------------------------------------------------------
 *          2005/08/12  Boisy G. Pitre
 * Brought in from Carl Kreider's CLIB package.
 *
 *          2024/07/04  Boisy G. Pitre
 * Incorporated into CMOC.
 */

#ifndef _SGTTY_H
#define _SGTTY_H

struct sgttyb
{
	char            sg_ispeed;	/* input speed */
	char            sg_ospeed;	/* output speed */
	char            sg_erase;	/* erase character */
	char            sg_kill;/* kill character */
	int             sg_flags;	/* mode flags */
};

/*
 * Modes
 */
#define  HUPCL  01
#define  XTABS  02
#define  LCASE  04
#define  ECHO  010
#define  CRMOD  020
#define  RAW  040
#define  ODDP  0100
#define  EVENP  0200
#define ANYP  0300
#define  NLDELAY  001400
#define  TBDELAY  002000
#define  CRDELAY  030000
#define  VTDELAY  040000
#define BSDELAY   0100000
#define ALLDELAY  0177400
/*
 * Delay algorithms
 */
#define  CR0  0
#define  CR1  010000
#define  CR2  020000
#define  CR3  030000
#define  NL0  0
#define  NL1  000400
#define  NL2  001000
#define  NL3  001400
#define  TAB0  0
#define  TAB1  002000
#define  NOAL  004000
#define  FF0  0
#define  FF1  040000
#define  BS0  0
#define  BS1  0100000
/*
 * Speeds
 */
#define B0  0
#define B50  1
#define B75  2
#define B110  3
#define B134  4
#define B150  5
#define B200  6
#define B300  7
#define B600  8
#define B900  9
#define B1200  10
#define B1800  11
#define B2400  12
#define B3600  13
#define B4800  14
#define B7200  15
#define B9600  16
#define B19200  17
#define B38400  18
#define EXTA  30
#define EXTB  31
/*
 *  ioctl arguments
 */
#define  TIOCGETP  (('t'<<8)|8)
#define  TIOCSETP  (('t'<<8)|9)
/*
     OS9 Sgstat.h included here
     */
struct sgbuf
{				/* structure for 'getstat()' and 'setstat()' */
	char            sg_class,	/* device class */

	/*
	 * The following are for an SCF type device. See below for structure
	 * member definitions for an RBF device.
	 */
	                sg_case,/* 0 = upper and lower cases, 1 = upper case
				 * only */
	                sg_backsp,	/* 0 = BSE, 1 = BSE-SP-BSE */
	                sg_delete,	/* delete sequence */
	                sg_echo,/* 0 = no echo */
	                sg_alf,	/* 0 = no auto line feed */
	                sg_nulls,	/* end of line null count */
	                sg_pause,	/* 0 = no end of page pause */
	                sg_page,/* lines per page */
	                sg_bspch,	/* backspace character */
	                sg_dlnch,	/* delete line character */
	                sg_eorch,	/* end of record character */
	                sg_eofch,	/* end of file character */
	                sg_rlnch,	/* reprint line character */
	                sg_dulnch,	/* duplicate last line character */
	                sg_psch,/* pause character */
	                sg_kbich,	/* keyboard interrupt character */
	                sg_kbach,	/* keyboard abort character */
	                sg_bsech,	/* backspace echo character */
	                sg_bellch,	/* line overflow character (bell) */
	                sg_parity,	/* device initialisation (parity) */
	                sg_baud;/* baud rate */
	int             sg_d2p,	/* offset to second device name string */
	                sg_stn;	/* offset to status routine name */
	char            sg_err;	/* most recent error status */
	char            sg_spare[5];	/* spare bytes - necessary for
					 * correct sizing */
};

/*
 * the following is a structure definition to set the names, types and
 * offsets of structure members which are applicable to an RBF type device
 * file.
 */
struct
{
	char            sg_class,	/* device class - repeated from above */
	                sg_drive,	/* drive number */
	                sg_step,/* step rate */
	                sg_dtype,	/* device type */
	                sg_dense;	/* density capability */
	int             sg_cyls;/* number of cylinders (tracks) */
	char            sg_sides,	/* number of sides */
	                sg_verify;	/* 0 = verify on writes */
	int             sg_spt,	/* default sectors per track */
	                sg_spt0;/* ditto track 0 */
	char            sg_intlv,	/* sector interleave factor */
	                sg_salloc,	/* segment allocation size */
	                sg_att,	/* file attributes */
	                sg_fdpsn[3],	/* file descriptor PSN */
	                sg_dipsn[3];	/* file's directory PSN */
	long            sg_dirptr;	/* directory entry pointer */
	int             sg_dvt;	/* address of device table entry */
};

/*
     OS9 gtty UNIX Function        11/01/84
     */
gtty(Path, Utty)
	int             Path;	/* OS9 I/O Path Number   */
	struct sgttyb  *Utty;	/* Unix format I/O status */
{
	struct sgbuf    os9sgb;

	getstat(0, Path, &os9sgb);	/* get device information block  */
	Utty->sg_erase = os9sgb.sg_bspch;	/* erase/backspace       */
	Utty->sg_kill = os9sgb.sg_kbach;	/* task abort code       */
	Utty->sg_ispeed = Utty->sg_ospeed = os9sgb.sg_baud;	/* best guess
								 * implementation */

	/*
	 * Build Unix flags word from OS9 statuses
	 */
	Utty->sg_flags = 0;
	if (os9sgb.sg_case)
		Utty->sg_flags = HUPCL;	/* Upper case  only  */
	if (os9sgb.sg_echo)
		Utty->sg_flags |= ECHO;	/* Device echo */
	if (os9sgb.sg_nulls)
		Utty->sg_flags |= CRMOD;	/* null fill after cr ? */
	/* If any character processing, set RAW bit   */
	/* backspace or delete character sequence */
	if (os9sgb.sg_backsp || os9sgb.sg_delete)
		Utty->sg_flags &= ~(RAW);
	/* pause character  end of record character  */
	if (os9sgb.sg_pause || os9sgb.sg_eorch)
		Utty->sg_flags &= ~(RAW);
	/* end of file  and duplicate line character   */
	if (os9sgb.sg_eofch || os9sgb.sg_dulnch)
		Utty->sg_flags &= ~(RAW);
	/* pause character and interupt character   */
	if (os9sgb.sg_psch || os9sgb.sg_kbich)
		Utty->sg_flags &= ~(RAW);
	/* task abort and delete line character     */
	if (os9sgb.sg_kbach || os9sgb.sg_dlnch)
		Utty->sg_flags &= ~(RAW);
}

/* OS9 stty Unix function   11/01/84   */
stty(Path, Utty)
	int             Path;	/* OS9 I/O path number   */
	struct sgttyb  *Utty;
{
	struct sgbuf    os9sgb;	/* OS9 device statuses  */

	getstat(0, Path, &os9sgb);	/* Get device statuses   */
	os9sgb.sg_bspch = Utty->sg_erase;	/* set erase character  */
	os9sgb.sg_kbach = Utty->sg_kill;	/* Kill task character  */
	/* no baud option  */
	if (Utty->sg_flags & RAW)	/* set or clear all normal device
					 * statuses */
	{			/* clear all  */
		os9sgb.sg_backsp = os9sgb.sg_delete = 0;	/* backspace & delete  */
		os9sgb.sg_echo = os9sgb.sg_pause = 0;	/* echo & pause mode  */
		os9sgb.sg_eorch = os9sgb.sg_eofch = 0;	/* eof and eor character */
		os9sgb.sg_dulnch = os9sgb.sg_psch = 0;	/* dup line & pause char  */
		os9sgb.sg_kbich = os9sgb.sg_kbach = 0;	/* Int & abort char       */
		os9sgb.sg_case = os9sgb.sg_alf = 0;	/* Upper & lower case,
							 * no LF */
	}
	else
	{			/* set to normal OS9 values  */
		os9sgb.sg_backsp = 1;	/* echo bse space bse    */
		os9sgb.sg_alf = 1;	/* set auto lf on        */
		os9sgb.sg_delete = 0;	/* delete cr lf          */
		if (Utty->sg_flags & ECHO)
			os9sgb.sg_echo = 1;	/* set echo on           */
		else
			os9sgb.sg_echo = 0;	/* No echo               */
		os9sgb.sg_pause = 1;	/* set page pause on     */
		os9sgb.sg_eorch = 0x0d;	/* set eor to CR         */
		os9sgb.sg_eofch = 0x1b;	/* set eof to ESC        */
		os9sgb.sg_dulnch = 1;	/* set dup last line to ^A  */
		os9sgb.sg_psch = 0x17;	/* set pause to ^W       */
		os9sgb.sg_kbich = 3;	/* set interupt to ^C    */
	}
	setstat(0, Path, &os9sgb);
}

#endif				/* _SGTTY_H */
