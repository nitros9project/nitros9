                    IFNE      RBSUPER.D-1
RBSUPER.D           SET       1

********************************************************************
* rbsuper.d - rbsuper definitions
*
* $Id$
*
* (C) 2004 Boisy G. Pitre - Licensed to Cloud-9
*
* These definitions make up the static storage environment for the
* rbsuper driver.  Low level drivers share these variables with
* rbsuper, and also have an area reserved exclusively for their use.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2004/04/10  Boisy G. Pitre
* Created.
*
*          2005/11/27  Boisy G. Pitre
* Moved SCSI base addresses and I/O offsets to here.
*
*          2005/12/13  Boisy G. Pitre
* Employed a "trick" whereby driver's U is pointed UOFFSET bytes
* into the static storage for faster, smaller code generation.
*
*          2005/12/13  Boisy G. Pitre
* Rearranged order of driver statics for smaller code size

* Interface Address
SDAddr              SET       $FF00
SDMPI               SET       $FF

*
* IT.DNS Definitions for all Low Level Drivers
*
DNS.HDB             EQU       %00001000

*
* IT.DNS Definitions for Low Level SCSI Driver
*
DNS.TURBO           EQU       %00010000

maxcache            SET       2048
DrvCount            EQU       8
llreserve           EQU       64

UOFFSET             EQU       DRVBEG+(DRVMEM*DrvCount)

                    ORG       0
V.LLSema            RMB       1                   low-level semaphore variable
V.LastDrv           RMB       1                   last drive to access cache
V.PhysSect          RMB       3                   physical (HW) sector
V.LogSect           RMB       3                   logical (256 byte) sector
V.SectSize          RMB       1                   sector size
V.SectCnt           RMB       1                   number of hw sectors to read from interface
V.Log2Phys          RMB       1                   number of logical (256) byte sectors to 1 physical sector
V.CchAddr           RMB       2                   address of cache in system memory
V.CchSize           RMB       2                   size of cache in bytes
V.CchPSpot          RMB       2                   pointer to target physical sector in cache
V.CchLSpot          RMB       2                   pointer to target logical sector in cache
V.CchDirty          RMB       1                   cache dirty flag (0 = cache is stable, !0 = cache is dirty)
V.CchBase           RMB       3                   logical sector at start of cache
V.HDBDrive          RMB       1                   IT.STP (used as HDB-DOS drive number if HDB-DOS partition)
V.HDBPart           RMB       1                   HDB-DOS partition flag (0 = not HDB-DOS partition, !0 = is)
V.SSCache           RMB       DrvCount            sector size cache table for each drive
V.LLAddr            RMB       2                   low level module address
V.LLInit            RMB       2                   low level init entry point
V.LLRead            RMB       2                   low level read entry point
V.LLWrite           RMB       2                   low level write entry point
V.LLGtSt            RMB       2                   low level getstat entry point
V.LLStSt            RMB       2                   low level setstat entry point
V.LLTerm            RMB       2                   low level term entry point
* Low Level Driver Memory starts here
V.LLMem             EQU       .                   start of low level driver memory
                    RMB       llreserve           reserved area... low level driver uses this as it wants
V.LLMemSz           EQU       .-V.LLMem
* Note: we trick rbsuper too so that it thinks its static storage starts at
* zero when it really starts beyond DRVBEG+(DRVMEM*DrvCount).
                    RMB       UOFFSET
V.RBSuper           EQU       .                   end of RBSuper's (and ll driver's) memory requirements

                    ENDC

