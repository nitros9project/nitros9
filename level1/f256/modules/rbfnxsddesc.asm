********************************************************************
* fnxsddesc - Super Driver Device Descriptor Template
*
* $Id$
*
* RBSuper Defined Offsets
*
* IT.STP (offset $14)
*  Bit Meaning
*  --- ---------------------------------------------------------------
*  7-0 HDB-DOS Drive Number (useful only if HDB-DOS bit set in IT.DNS)
*
* IT.TYP (offset $15)
*  Bit Meaning
*  --- ---------------------------------------------------------------
*  7   Hard Disk:  1 = hard disk
*  6   Fudge LSN0: 0 = OS-9 disk, 1 = non-OS-9 disk
*  5   Undefined
*  4   Drive Size Query (1 = yes, 0 = no)
*  2-3 Undefined
*  0-1 Sector Size (0 = 256, 1 = 512, 2 = 1024, 3 = 2048)
*
*	The above IT.TYP has been superceded, see rbf.d for
*	currently used definitions for BOTH IT.TYP and IT.DNS
*	(should be removed eventually to prevent confusion)

* IT.DNS (offset $16) for SCSI Low Level Driver
*  Bit Meaning
*  --- ---------------------------------------------------------------
*  5-7 SCSI Logical Unit Number of drive (0-7) (ignored if bit 3 is 1)
*  4   Turbo Mode:  1 = use accelerated handshaking, 0 = standard
*  3   HDB-DOS Partition Flag
*  0-2 SCSI ID of the drive or controller (0-7)
*
* IT.DNS (offset $16) for IDE Low Level Driver
*  Bit Meaning
*  --- ---------------------------------------------------------------
*  4-7 Undefined
*  3   HDB-DOS Partition Flag
*  1-2 Undefined
*  0   IDE ID (0 = master, 1 = slave)
*
* Again, for final reference, see rbf.d, the above is obsolete.
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   0      2004/04/08  Boisy G. Pitre
* Created.
*
*   0      2005/11/27  Boisy G. Pitre
* Added IT.MPI value to descriptor.
*
*   0      2005/12/08  Boisy G. Pitre
* Reserved two bits in IT.TYP for llscsi.
*
*  1/1 	2013/12/10 Gene heskett
* 	Notes to reference rbf.d for IT.TYP, IT.DNS above
*	Raise SAS default to 10, shortens FD.SEG usage
*--------------------------------------------------------------------

* Super Driver specific fields
ITDRV               set       $00
ITSTP               set       $00
ITTYP               set       $81
ITDNS               set       $00
ITSOFS1             set       $00
ITSOFS2             set       $00
ITSOFS3             set       $00
Sides               set       $01
Cyls                set       $7100
SectTrk             set       $0012
SectTrk0            set       $0012
Interlv             set       $01
SAS                 set       $08

                    use       defsfile
                    use       rbsuper.d
                    use       f256.d

SDAddr              set       SDC.Base

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $09

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       DIR.+SHARE.+PEXEC.+PREAD.+PWRIT.+EXEC.+UPDAT.
                    fcb       HW.PAGE             extended controller address
                    fdb       SDAddr              physical controller address
                    fcb       initsize-*-1        initilization table size
                    fcb       DT.RBF              device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       ITDRV               drive number
                    fcb       ITSTP               step rate
                    fcb       ITTYP               drive device type
                    fcb       ITDNS               media density
                    fdb       Cyls                number of cylinders (tracks)
                    fcb       Sides               number of sides
                    fcb       $01                 verify disk writes:0=on
                    fdb       SectTrk             # of sectors per track
                    fdb       SectTrk0            # of sectors per track (track 0)
                    fcb       Interlv             sector interleave factor
                    fcb       SAS                 minimum size of sector allocation
                    fcb       0                   IT.TFM
                    fdb       0                   IT.Exten
                    fcb       0                   IT.STOff
* Super Driver specific additions to the device descriptor go here
* NOTE: These do NOT get copied into the path descriptor; they
*       cannot due to the fact that there is simply NO ROOM in
*       the path descriptor to do so.  The driver must access
*       these values directly from the descriptor.
                    fcb       $00                 (IT.WPC)
                    fcb       $00                 (IT.OFS)
                    fcb       $00
initsize            equ       *
                    fdb       lldrv               (IT.RWC)

name
                    ifne      DD
                    fcs       /dd/
                    else
                    fcc       /s/
                    fcb       '0+ITDRV+$80
                    endc

mgrnam              fcs       /rbf/
drvnam              fcs       /rbsuper/
lldrv               fcs       /llfnxsd/


                    emod
eom                 equ       *
                    end
