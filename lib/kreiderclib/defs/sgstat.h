/*
 * sgstat.h
 *
 * Notes:
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

#ifndef _SGSTAT_H
#define	_SGSTAT_H

struct _sgs_s
{
	/* structure for 'getstat()' and 'setstat()' */
	char            _sgs_class,	/* device class */

	/*
	 * The following are for an SCF type device. See below for structure
	 * member definitions for an RBF device.
	 */
	                _sgs_case,	/* 0 = upper and lower cases, 1 =
					 * upper case only */
	                _sgs_backsp,	/* 0 = BSE, 1 = BSE-SP-BSE */
	                _sgs_delete,	/* delete sequence */
	                _sgs_echo,	/* 0 = no echo */
	                _sgs_alf,	/* 0 = no auto line feed */
	                _sgs_nulls,	/* end of line null count */
	                _sgs_pause,	/* 0 = no end of page pause */
	                _sgs_page,	/* lines per page */
	                _sgs_bspch,	/* backspace character */
	                _sgs_dlnch,	/* delete line character */
	                _sgs_eorch,	/* end of record character */
	                _sgs_eofch,	/* end of file character */
	                _sgs_rlnch,	/* reprint line character */
	                _sgs_dulnch,	/* duplicate last line character */
	                _sgs_psch,	/* pause character */
	                _sgs_kbich,	/* keyboard interrupt character */
	                _sgs_kbach,	/* keyboard abort character */
	                _sgs_bsech,	/* backspace echo character */
	                _sgs_bellch,	/* line overflow character (bell) */
	                _sgs_parity,	/* device initialisation (parity) */
	                _sgs_baud;	/* baud rate */
#ifdef OSK
	WORD            _sgs_d2p;	/* offset to second device name
					 * string */
	char            _sgs_xon,	/* x-on char */
	                _sgs_xoff;	/* x-off char */
	WORD            _sgs_tab;	/* tab field size */
	long            _sgs_tbl;	/* Device table addr (copy) */
	WORD            _sgs_col;	/* Current col number */
	char            _sgs_err;	/* most recent error status */
	char            _sgs_spare[93];	/* spare bytes - necessary for
					 * correct sizing */
#else
	unsigned        _sgs_d2p;	/* offset to second device name
					 * string */
	char            _sgs_xon,	/* x-on char */
	                _sgs_xoff;	/* x-off char */
	unsigned        _sgs_stn;	/* offset to status routine name */
	char            _sgs_err;	/* most recent error status */
	char            _sgs_spare[5];	/* spare bytes - necessary for
					 * correct sizing */
#endif
};

#define sg_class	_sgm._sgs._sgs_class
#define sg_case 	_sgm._sgs._sgs_case
#define sg_backsp 	_sgm._sgs._sgs_backsp
#define sg_delete	_sgm._sgs._sgs_delete
#define sg_echo		_sgm._sgs._sgs_echo
#define sg_alf		_sgm._sgs._sgs_alf
#define sg_nulls	_sgm._sgs._sgs_nulls
#define sg_pause	_sgm._sgs._sgs_pause
#define sg_page		_sgm._sgs._sgs_page
#define sg_bspch	_sgm._sgs._sgs_bspch
#define sg_dlnch	_sgm._sgs._sgs_dlnch
#define sg_eorch	_sgm._sgs._sgs_eorch
#define sg_eofch	_sgm._sgs._sgs_eofch
#define sg_rlnch	_sgm._sgs._sgs_rlnch
#define sg_dulnch	_sgm._sgs._sgs_dulnch
#define sg_psch		_sgm._sgs._sgs_psch
#define sg_kbich	_sgm._sgs._sgs_kbich
#define sg_kbach	_sgm._sgs._sgs_kbach
#define sg_bsech	_sgm._sgs._sgs_bsech
#define sg_bellch	_sgm._sgs._sgs_bellch
#define sg_parity	_sgm._sgs._sgs_parity
#define sg_baud		_sgm._sgs._sgs_baud
#define sg_d2p		_sgm._sgs._sgs_d2p
#define sg_xon		_sgm._sgs._sgs_xon
#define sg_xoff		_sgm._sgs._sgs_xoff
#define sg_tabcr	_sgm._sgs._sgs_tab
#define sg_tbl		_sgm._sgs._sgs_tbl
#define sg_col		_sgm._sgs._sgs_col
#define sg_err		_sgm._sgs._sgs_err
#define sg_spare	_sgm._sgs._sgs_spare

/*
 * the following is a structure definition to set the names, types and
 * offsets of structure members which are applicable to an RBF type device
 * file.
 */
struct _sgr_s
{
	char            _sgr_class,	/* device class - repeated from above */
	                _sgr_drive,	/* drive number */
	                _sgr_step,	/* step rate */
	                _sgr_dtype,	/* device type */
	                _sgr_dense;	/* density capability */
#ifdef OSK
	char            _sgr_fill1;	/* not used */
	WORD            _sgr_cyls;	/* number of cylinders (tracks) */
	char            _sgr_sides,	/* number of sides */
	                _sgr_verify;	/* 0 = verify on writes */
	WORD            _sgr_spt,	/* default sectors per track */
	                _sgr_spt0,	/* ditto track 0 */
	                _sgr_salloc;	/* segment allocation size */
	char            _sgr_intlv,	/* sector interleave factor */
	                _sgr_DMAtfm,	/* DMA transfer mode */
	                _sgr_toffs,	/* track offset values */
	                _sgr_soffs,	/* Sector offset value */
	                _sgr_rsvd[33],	/* reserved for future use */
	                _sgr_att;	/* file attributes */
	long            _sgr_fdpsn,	/* file descriptor PSN */
	                _sgr_dipsn,	/* file's directory PSN */
	                _sgr_dirptr,	/* directory entry pointer */
	                _sgr_dvt;	/* address of device table entry */
	char            _sgr_fname[32],	/* filename */
	                _sgr_resrvd[26];	/* Reserved */
#else
	unsigned        _sgr_cyls;	/* number of cylinders (tracks) */
	char            _sgr_sides,	/* number of sides */
	                _sgr_verify;	/* 0 = verify on writes */
	unsigned        _sgr_spt;	/* default sectors per track */
	char            _sgr_sp0,	/* ditto track 0 */
	                _sgr_intlv,	/* sector interleave factor */
	                _sgr_salloc,	/* segment allocation size */
	                _sgr_DMAtfm;	/* DMA Transfer Mode */
	unsigned        _sgr_exten;	/* Path extension */
	char            _sgr_stoff,	/* track/sector offset */
	                _sgr_att,	/* file attributes */
	                _sgr_fdpsn[3],	/* file descriptor PSN */
	                _sgr_dipsn[3];	/* file's directory PSN */
	long            _sgr_dirptr;	/* directory entry pointer */
	unsigned        _sgr_dvt;	/* address of device table entry */
#endif
};

#define sg_drive	_sgm._sgr._sgr_drive
#define sg_step		_sgm._sgr._sgr_step
#define sg_dtype	_sgm._sgr._sgr_dtype
#define sg_dense	_sgm._sgr._sgr_dense
#define sg_fill1	_sgm._sgr._sgr_fill1
#define sg_cyls		_sgm._sgr._sgr_cyls
#define sg_sides	_sgm._sgr._sgr_sides
#define sg_verify	_sgm._sgr._sgr_verify
#define sg_spt		_sgm._sgr._sgr_spt
#define sg_spt0		_sgm._sgr._sgr_sp0
#define sg_salloc	_sgm._sgr._sgr_salloc
#define sg_intlv	_sgm._sgr._sgr_intlv
#define sg_DMAtfm	_sgm._sgr._sgr_DMAtfm
#define sg_toffs	_sgm._sgr._sgr_toffs
#define sg_soffs	_sgm._sgr._sgr_soffs
#define sg_att		_sgm._sgr._sgr_att
#define sg_fdpsn	_sgm._sgr._sgr_fdpsn
#define sg_dipsn	_sgm._sgr._sgr_dipsn
#define sg_dirptr	_sgm._sgr._sgr_dirptr
#define sg_dvt		_sgm._sgr._sgr_dvt
#define sg_fname	_sgm._sgr._sgr_fname
#define sg_resrvd	_sgm._sgr._sgr_resrvd
#define sg_exten    _sgm._sgr._sgr_exten
#define sg_stoffs	_sgm._sgr._sgr_stoffs

struct sgbuf
{
	union
	{
		struct _sgs_s   _sgs;
		struct _sgr_s   _sgr;
	}               _sgm;
};

#endif				/* _SGSTAT_H */
