********************************************************************
* SuperDesc - Super Driver Device Descriptor Template
*
*	edited 12/10/2013 Gene Heskett
*	see as noted within
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
                    nam       SuperDesc
                    ttl       Super Driver Device Descriptor Template

* Super Driver specific fields
*               IFEQ      ITDRV
                    ifndef    ITDRV
ITDRV               set       $00
                    endc
*               IFEQ      ITSTP
                    ifndef    ITSTP
ITSTP               set       $00
                    endc
*               IFEQ      ITTYP
                    ifndef    ITTYP
ITTYP               set       $81
                    endc
*               IFEQ      ITDNS
                    ifndef    ITDNS
ITDNS               set       $00
                    endc

*               IFEQ      ITSOFS1
                    ifndef    ITSOFS1
ITSOFS1             set       $00
                    endc
*               IFEQ      ITSOFS2
                    ifndef    ITSOFS2
ITSOFS2             set       $00
                    endc
*               IFEQ      ITSOFS3
                    ifndef    ITSOFS3
ITSOFS3             set       $00
                    endc

                    ifne      CC3FPGA
Sides               set       $01
Cyls                set       $7100
SectTrk             set       $0012
SectTrk0            set       $0012
Interlv             set       $01
SAS                 set       $08
                    else
* Geometry for an EZ-135
*               IFEQ      Sides
                    ifndef    Sides
Sides               set       $40
                    endc
*               IFEQ      Cyls
                    ifndef    Cyls
Cyls                set       $007f
                    endc
*               IFEQ      SectTrk
                    ifndef    SectTrk
SectTrk             set       $0020
                    endc
*               IFEQ      SectTrk0
                    ifndef    SectTrk0
SectTrk0            set       $0020
                    endc
*               IFEQ      Interlv
                    ifndef    Interlv
Interlv             set       $01
                    endc
*               IFEQ      SAS
                    ifndef    SAS
SAS                 set       $10
                    endc
                    endc

                    ifp1
                    use       defsfile
                    use       rbsuper.d
                    ifne      IDE
                    use       ide.d
                    else
                    ifne      TC3+KTLR+D4N1+HDII
                    use       scsi.d
                    else
                    use       cocosdc.d
                    endc
                    endc
                    endc

                    ifne      CC3FPGA
SDAddr              set       $FF64
                    endc

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $09

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    ifne      CDROM
                    fcb       DIR.+SHARE.+PEXEC.+PREAD.+EXEC.+READ.
                    else
                    fcb       DIR.+SHARE.+PEXEC.+PREAD.+PWRIT.+EXEC.+UPDAT.
                    endc
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
                    ifne      CC3FPGA
                    ifne      ITDRV
                    fcb       $03                 (IT.WPC)
                    fcb       $F9                 (IT.OFS)
                    else
                    fcb       ITSOFS1             (IT.WPC)
                    fcb       ITSOFS2             (IT.OFS)
                    endc
                    else
                    fcb       ITSOFS1             (IT.WPC)
                    fcb       ITSOFS2             (IT.OFS)
                    endc
                    fcb       ITSOFS3
initsize            equ       *
                    fdb       lldrv               (IT.RWC)
                    fcb       SDMPI               (IT.MPI)

                    ifne      NULL
name                fcc       /NULL/
                    fcb       '0+ITDRV+$80
                    else
                    ifne      DD
name                fcs       /DD/
                    else
                    ifne      DRIVEWIRE
name                fcc       /X/
                    ifne      HB
                    fcs       /H/
                    else
                    fcb       '0+ITDRV+$80
                    endc
                    else
                    ifne      IDE
name                fcc       /I/
                    ifne      HB
                    fcs       /H/
                    else
                    fcb       '0+ITDNS+$80
                    endc
                    else
                    ifne      COCOSDC+CC3FPGA
name                fcc       /SD/
                    ifne      HB
                    fcs       /H/
                    else
                    fcb       '0+ITDRV+$80
                    endc
                    else
name                fcc       /S/
                    ifne      HB
                    fcs       /H/
                    else
                    fcb       '0+ITDRV+$80
                    endc
                    endc
                    endc
                    endc
                    endc
                    endc

mgrnam              fcs       /RBF/
drvnam              fcs       /rbsuper/
lldrv               equ       *
                    ifne      NULL
                    fcs       /llnull/
                    fcb       0
                    else
                    ifne      DRIVEWIRE
                    fcs       /lldw/
                    fcb       0,0,0
                    else
                    ifne      TC3+SB
                    fcs       /lltc3/
                    fcb       0,0
                    else
                    ifne      KTLR
                    fcs       /llktlr/
                    fcb       0
                    else
                    ifne      HDII+D4N1
                    fcs       /lldisto/
                    else
                    ifne      IDE
                    fcs       /llide/
                    fcb       0,0
                    else
                    ifne      COCOSDC
                    fcs       /llcocosdc/
                    fcb       0,0,0
                    else
                    ifne      CC3FPGA
                    fcs       /llcoco3fpga/
                    fcb       0,0,0
                    endc
                    endc
                    endc
                    endc
                    endc
                    endc
                    endc
                    endc


                    emod
eom                 equ       *
                    end
