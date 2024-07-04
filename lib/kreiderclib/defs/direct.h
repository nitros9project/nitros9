/*
 * direct.h - RBF directory entry structures
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

#ifndef _DIRECT_H
#define _DIRECT_H

struct dirent
{
	char            dir_name[29];
	char            dir_addr[3];
};

struct fildes
{
	char            fd_att;
	unsigned        fd_own;
	char            fd_date[5];
	char            fd_link;
	long            fd_fsize;
	char            fd_dcr[3];
	struct
	{
		char            addr[3];
		unsigned        size;
	}
	                fdseg[48];
};


struct ddsect
{
	char            dd_tot[3];
	char            dd_tsk;
	unsigned        dd_map;
	unsigned        dd_bit;
	char            dd_dir[3];
	unsigned        dd_own;
	char            dd_att;
	unsigned        dd_dsk;
	char            dd_fmt;
	unsigned        dd_spt;
	unsigned        dd_res;
	char            dd_bt[3];
	unsigned        dd_bsz;
	char            dd_date[5];
	char            dd_name[32];
};

#endif				/* _DIRECT_H */
