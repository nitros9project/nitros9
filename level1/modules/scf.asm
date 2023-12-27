********************************************************************
* SCF - NitrOS-9 Sequential Character File Manager
*
* $Id$
*
* This contains an added SetStat call to allow placing prearranged data
* into the keyboard buffer of ANY SCF related device.
*
* Usage:
*
* Entry: X = Pointer to the string
*        Y = Length of the string
*        A = Path number
*        B = SS.Fill ($A0) (syscall SETSTAT function call number)
* NOTE: If high bit of Y is set, no carriage return will be appended to
*       the read buffer (used in Shellplus V2.2 history)
*
* This also includes Kevin Darlings SCF Editor patches.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          1993/04/20  ???
* V1.09:
* - Speeded up L05CC (write char to device) routine by a few cycles
* - Slightly optimized Insert char.
* - Move branch table so Read & ReadLn are 1 cycle faster each; fixed
*   SS.Fill so size is truncated @ 256 bytes.
* - Added NO CR option to SS.Fill (for use with modified Shellplus V2.2
*   command history).
*
*          1993/04/21  ???
* Slight speedup to some of ReadLn parsing, TFM's in Open/Close.
* - More optimization to read/write driver calls
* - Got rid of branch table @ L05E3 for speed
*
*          1993/05/21  ???
* V1.10:
* Added Boisy Pitre's patch for non-sharable devices.
* - Saved 4 cycles in routine @ L042B
* - Modified Boisy's routine to not pshs/puls B (saves 2 cycles).
* - Changed buffer prefill of CR's to save 1 byte.
*
*          1993/07/27  ???
* V1.11:
* Changed a BRA to a LBRA to a straight LBRA in L0322.
* - Optimized path option character routine @ L032C
*
*          1993/08/03  ???
* Modified vector table @ L033F to save 1 cycle on PD.PSC
* - Sped up uppercase conversion checks for ReadLn & WritLn
* - Changed 2 BRA's to L02F9 to do an LBRA straight to L05F8 (ReadLn loop)
* - Moved L0565 routine so Reprint line, Insert & Delete char (on ReadLn)
*   are 1 cycle faster / char printed
* - Changed 2 references to L0420 to go straight to L0565
* - Sped up ReadLn loop by 2 or 3 cycles per char read
*
*          1993/09/21  ???
* V1.12:
* Sped up L0435 by 1 or 2 cycles (depending on branch)
* - Changed LDD ,S to TFR X,D (saves 1 cycle) @ L04F1 (Write & WritLn)
* - Modified L04F1 to use W without TFR (+1 byte, -3 cycles) (Write)
*
*          1993/11/09  ???
* Took LDX #0/LDU PD.BUF,y from L03B5 & merged in @ L028A, L02EF & L0381.
* Also changed BEQ @ L03A5 to skip re-loading X with 0.
*
*          1993/11/10  ???
* Moved L04B2 routine to allow a couple of BSR's instead of LBSR's In READ.
* - Moved driver call right into READ loop (should save 25 cycles/char read)
* - Moved driver call right into L0565 (should save 12 cycles/char written on echo,
*   line editing, etc.)
*
*          1993/11/26  ???
* Moved L02FE (ReadLn parsing) to end where ReadLn routine is moved L03E2
* so Read loop would be optimized for it (read char from driver) instead of
* L042B (write filled buffer to caller).
* Changed LDA #C$NULL to CLRA.
*
*          1993/12/01  ???
* Modified device write call (L056F) to preserve Y as well, to cut down on
* PSHS/PULS.
* - Changed L03E2 & L03DA to exit immediately if PD.DEV or PD.DV2 (depending
* on which routine) is empty (eliminated redundant LEAX ,X).
*
*          1994/05/31  ???
* Attempted mode to L03F1 to eliminate LDW #D$READ, changed:
*      LDX V$DRIV,x
*      ADDW M$Exec,x
*      JSR w,x
* to:
*      LDW V$DRIV,x
*      ADDW M$Exec,w
*      JSR D$READ,w
* Did same to L05C9 & L056F (should speed up each by 1 cycle)
*
*          1994/06/07  ???
* Attempted to modify all M$Exec calls to use new V$DRIVEX (REQUIRES NEW IOMAN)
* - L01FA (Get/SetStat), L03F1 (Read), L05C9 (Write), L056F (Write)
* - Changed L046A to use LDB V.BUSY,x...CMPB ,s...TFR B,A
*
*          1994/06/08  ???
* Changed TST <PD.EKO,y in read loop (L02BC) to LDB PD.EKO,y
* - Changed LEAX 1,X to LDB #1/ABX @ L02C4
* - Changed LEAX >L033F,pc @ L032C to use < (8 bit) version
* - Modified L02E5 to use D instead of X, allowing TSTA, and faster exit on 0 byte
*   just BRAnching to L0453
*
*          1994/06/09  ???
* Changed LEAX 1,X to LDB #1/ABX @ L053D, L05F8, L0312, L0351, L03B8
* - Changed to L0573: All TST's changed to LDB's
* - Changed Open/Create init to use LEAX,PC instead of BSR/PULS X
* - Changed TST PD.CNT,y to LDA PD.CNT,y @ close
* - Eliminated L010D, changed references to it to go to L0129
* - Eliminated useless LEAX ,X @ L0182, and changed BEQ @ L0182 to go to L012A
*   instead of L0129 (speeds CLOSE by 5 or 10 cycles)
* - Moved L06B9 into L012B, eliminate BSR/RTS, plus
* - Changed TST V.TYPE,x to LDB V.TYPE,x
* - Moved L0624 to just before L05F8 to eliminate BRA L05F8 (ReadLn)
* - Changed TST PD.EKO,y @ L0413 to LDB PD.EKO,y
* - Moved L0413-L0423 routines to later in code to allow short branches
* - As result of above, changed 6 LBxx to Bxx
* - Changed TST PD.MIN,y @ L04BB to LDA PD.MIN,y
* - Changed TST PD.RAW,y/TST PD.UPC,y @ L0523 to LDB's
* - Changed TST PD.ALF,y @ L052A to LDB
* - L053D: Moved TST PD.RAW,y to before LDA -1,u to speed up WRITE, changed it to LDB
*
*          1994/06/10  ???
* Changed TST PD.ALF,y to LDB @ L052A
* - Changed CLR V.WAKE,u to CLRA/STA V.WAKE,u @ L03F1 (Read)
* - Changed CLR V.BUSY,u to CLRA/STA V.BUSY,u @ L045D
* - Changed CLR PD.MIN,y to CLRA/STA PD.MIN,y, moved before LDA P$ID,x @ L04A7
* - Changed CLR PD.RAW,y @ L04BB to STA PD.RAW, since A already 0 to get there
* - Changed CLR V.PAUS,u to CLRA/STA V.PAUS,u @ L05A2
* - Changed TST PD.RAW,y to LDA PD.RAW,y @ L05A2
* - Changed TST PD.ALF,y to LDA PD.ALF,y @ L05A2
* - Changed CLR V.WAKE,u to CLRB/STB V.WAKE,u @ L05C9
* - Changed CLR V.WAKE,u to CLRB/STB V.WAKE,u @ L056F
* - Changed TST PD.UPC,y to LDB PD.UPC,y @ L0322
* - Changed TST PD.DLO,y/TST PD.EKO,y to LDB's @ L03A5
*
*          1994/06/16  ???
* Changed TST PD.UPC,y to LDB PD.UPC,y @ L0322
* - Changed TST PD.BSO,y to LDB PD.BSO,y @ L03BF
* - Changed TST PD.EKO,y to LDB PD.EKO,y @ L03BF
*
*          2002/10/11  Boisy G. Pitre
* Merged NitrOS-9 and TuneUp versions for single-source maintenance.  Note that
* the 6809 version of TuneUp never seemed to call GrfDrv directly to do fast screen
* writes (see note around g.done label).
*
*  16r2    2002/05/16  Boisy G. Pitre
* Removed pshs/puls of b from sharable code segment for non-NitrOS-9 because it was
* not needed.
*
*  16r3    2002/08/16  Boisy G. Pitre
* Now uses V$DRIVEX.
*
*  16r4    2004/07/12  Boisy G. Pitre
* 6809 version now calls the FAST TEXT entry point of GrfDrv.
*
*  17      2010/01/15  Boisy G. Pitre
* Fix for bug described in Artifact 2932883 on SF
* Also added Level 1 conditionals for eventual backporting

*
*  17      2010/01/15  Boisy G. Pitre
* Handling of device exclusivity using the SHARE. bit has been rearchitected.
* The '93 patch looked at the mode bytes in the descriptor and driver and
* determined that if both were set, then only one path would be allowed to
* be opened on the device at a time.
* I now believe this is wrong.
* The mode bytes in the device driver and descriptor are capability bytes.
* They advertise what the device is capable of doing (READ, WRITE, etc) so
* the mode bytes alone do not convey action, but merely what is possible.
* When the user calls I$Open on a device, he passes the desired mode byte
* in RegA and IOMan checks to make sure that all bits in that register are
* set in the mode bytes of the driver and descriptor.  So once we get into
* the Open call of this file manager, we know that all set bits in RegA are
* also set in the mode bytes of the driver and descriptor.
*
* For SHARE., what we SHOULD be doing is checking the number of open paths
* on the device.  If the SHARE. bit is set in RegA, then we check if a path
* is already open and if so, return the E$DevBsy error.
* Likewise, if SHARE. is not set in RegA, we check the path at the head of
* the open path list, and if ITS mode byte has the SHARE. bit set, we exit
* with E$DevBsy too.  The idea is that if the SHARE. bit is set on the newly
* opened path or an existing path, then there can "be only one."
*
*  18      2010/01/23  Boisy G. Pitre
* SCF has successfully been backported to NitrOS-9 Level 1.
* SCF now returns on carry set after calling SS.Open.  Prior to this
* change, SS.ComSt would be called right after SS.Open even if SS.Open
* failed. This caused misery with the scdwn driver wildcard feature.
*
* EOU Version 1.0.0
*          2022/08/01  LCB
* slight optimization in ReadLn chars when echo is turned on & a control
* code other than CR was received. Saves 2 bytes/3 cyc for that case (other
* chars no change. (L0418)
* 2 lbsr's changed to bsr's (both CPU's) - bsr L0403 in g.loop & bsr L0565 in L0634

                    nam       SCF
                    ttl       NitrOS-9 Sequential Character File Manager

                    IFP1
                    use       defsfile
                    use       scf.d
                    IFGT      Level-1
                    use       cocovtio.d
                    ENDC
                    ENDC

tylg                set       FlMgr+Objct
atrv                set       ReEnt+rev
rev                 set       0
edition             equ       18

                    mod       eom,SCFName,tylg,atrv,SCFEnt,0

SCFName             fcs       /SCF/
                    fcb       edition

* Default input buffer setting for SCF devices when Opened/Created
*               123456789!123456789!1234567890
*msg      fcc   'by B.Nobel,C.Boyle,W.Gale-1993'
msg                 fcc       'www.nitros9.org'
msgsize             equ       *-msg               Size of default input buffer message
                    fcb       C$CR                2nd CR for buffer pad fill
blksize             equ       256-msgsize         Size of blank space after it

* Return bad pathname error
opbpnam             puls      y
bpnam               comb                          Set carry for error
                    ldb       #E$BPNam            Get error code
oerr                rts                           Return to caller

* I$Create/I$Open entry point
* Entry: Y= Path dsc. ptr
open                ldx       PD.DEV,y            Get device table pointer
                    stx       PD.TBL,y            Save it
                    ldu       PD.RGS,y            Get callers register stack pointer
                    pshs      y                   Save path descriptor pointer
                    ldx       R$X,u               Get pointer to device pathname
                    os9       F$PrsNam            Parse it
                    bcs       opbpnam             Error, exit
                    tsta                          End of pathname?
                    bmi       open1               Yes, go on
                    leax      ,y                  Point to actual device name
                    os9       F$PrsNam            Parse it again
                    bcc       opbpnam             Return to caller with bad path name if more
open1               sty       R$X,u               Save updated name pointer to caller
                    puls      y                   Restore path descriptor pointer
                    ldd       #256                Get size of input buffer in bytes
                    os9       F$SRqMem            Allocate it
                    bcs       oerr                Can't allocate it return with error
                    stu       PD.BUF,y            Save buffer address to path descriptor
                    leax      <msg,pc             Get ptr to init string
                    IFNE      H6309
                    ldw       #msgsize            get size of default message
                    tfm       x+,u+               Copy it into buffer (leaves X pointing to 2nd CR)
                    ldw       #blksize            Size of rest of buffer
                    tfm       x,u+                Fill rest of buffer with CR's
                    ELSE
CopyMsg             lda       ,x+
                    sta       ,u+
                    decb
                    cmpa      #C$CR
                    bne       CopyMsg
CopyCR              sta       ,u+
                    decb
                    bne       CopyCR
                    ENDC
                    ldu       PD.DEV,y            Get device table entry address
                    beq       bpnam               Doesn't exist, exit with bad pathname error
                    ldx       V$STAT,u            Get devices' static storage address
                    lda       PD.PAG,y            Get devices page length
                    sta       V.LINE,x            Save it to devices static storage
                    ldx       V$DESC,u            Get descriptor address
                    ldd       PD.D2P,y            Get offset to device name (duplicate from dev dsc)
                    beq       L00CF               None, skip ahead
                    IFNE      H6309
                    addr      d,x                 Point to device name in descriptor
                    lda       PD.MOD,y            Get device mode (Read/Write/Update)
                    lsrd                          ??? (swap Read/Write bits around in A?)
                    ELSE
                    leax      d,x
                    lda       PD.MOD,y            Get device mode (Read/Write/Update)
                    lsra
                    rorb
                    ENDC
                    lsra
                    rolb
                    rola
                    rorb
                    rola
                    IFGT      Level-1
                    pshs      y                   Save path descriptor pointer temporarily
                    ldy       <D.Proc             Get current process pointer
                    ldu       <D.SysPrc           Get system process descriptor pointer
                    stu       <D.Proc             Make system current process
                    ENDC
                    os9       I$Attach            Attempt to attach to device name in device desc.
                    IFGT      Level-1
                    sty       <D.Proc             Restore old current process pointer
                    puls      y                   Restore path descriptor pointer
                    ENDC
                    bcs       OpenErr             Couldn't attach to device, detach & exit with error
                    stu       PD.DV2,y            Save new output (echo) device table pointer
*         ldu   PD.DEV,y     Get device table pointer
L00CF               ldu       V$STAT,u            Point to it's static storage
                    IFNE      H6309
                    clrd
                    ELSE
                    clra
                    clrb
                    ENDC
                    std       PD.PLP,y            Clear out path descriptor list pointer
                    sta       PD.PST,y            Clear path status: Carrier not lost
                    pshs      d                   Save 0 on stack
                    ldx       V.PDLHd,u           Get path descriptor list header pointer
* 05/25/93 mod - Boisy Pitre's non-sharable device patches
* 01/15/10 mod - Boisy Pitre redoes his non-sharable device patch
                    beq       Yespath             No paths open, so we know we can open it
* IOMan has already vetted the mode byte of the driver and the descriptor
* and compared it to REGA of I$Open (now in PD.MOD of this current path).
* here we know there is at least one path open for this device.
* in order to properly support SHARE. (device exclusivity), we get the
* mode byte for the path we are opening and see if the SHARE. bit is set.
* if so, then we return error since we cannot have exclusivity to the device.
                    IFNE      H6309
                    tim       #SHARE.,PD.MOD,y
                    ELSE
                    lda       PD.MOD,y
                    bita      #SHARE.
                    ENDC
                    bne       NoShare
* we now know that the path's mode doesn't have the SHARE. bit set, so
* we need to look at the mode of the path in the list header pointer to
* see if ITS SHARE. bit is set (meaning it wants exclusive access to the
* port).  If so we bail out
                    IFNE      H6309
                    tim       #SHARE.,PD.MOD,x
                    ELSE
                    lda       PD.MOD,x
                    bita      #SHARE.
                    ENDC
                    beq       CkCar               Check carrier status
NoShare             leas      2,s                 Eat extra stack (including good path count)
                    comb
                    ldb       #E$DevBsy           Non-sharable device busy error
                    bra       OpenErr             Go detach device & exit with error

Yespath             sty       V.PDLHd,u           Save path descriptor ptr
                    bra       L00F8               Go open the path

L00E6               tfr       d,x                 Change to PD.PLP path descriptor
CkCar               ldb       PD.PST,x            Get Carrier status
                    bne       L00EF               Carrier was lost, don't update count
                    inc       1,s                 Carrier not lost, bump up count of good paths
L00EF               ldd       PD.PLP,x            Get path descriptor list pointer
                    bne       L00E6               There is one, go make it the current one
                    sty       PD.PLP,x            Save path descriptor ptr as path dsc. list ptr
L00F8               lda       #SS.Open            Internal open call
                    pshs      a                   Save it on the stack
                    inc       2,s                 Bump counter of good paths up by 1
                    lbsr      L025B               Do the SS.Open call to the driver
                    lda       2,s                 Get counter of good paths
                    leas      3,s                 Eat stack
* NEW: return with error if SS.Open return error
                    bcs       L010F               +++BGP+++
                    deca                          Bump down good path count
                    bne       L0129               If more still open, exit without error
                    blo       L010F               If negative, something went wrong
                    lbra      L0250               Set parity/baud & return

* we come here if there was an error in Open (after I$Attach and F$SRqMem!)
L010F               bsr       RemoveFromPDList    Error, go clear stuff out
OpenErr             pshs      b,cc                Preserve error status
                    bsr       L0136               Detach device
                    puls      pc,b,cc             Restore error status & return

* I$Close entry point
close               pshs      cc                  Preserve interrupt status
                    orcc      #IntMasks           Disable interrupts
                    ldx       PD.DEV,y            Get device table pointer
                    bsr       L0182               Check it
                    ldx       PD.DV2,y            Get output device table pointer
                    bsr       L0182               Check it
                    puls      cc                  Restore interrupts
                    lda       PD.CNT,y            Any open images?
                    beq       L012B               No, go on
L0129               clra                          Clear carry
L012A               rts                           Return

* Detach device & return buffer memory
L012B               bsr       RemoveFromPDList
                    lda       #SS.Close           Get setstat code for close
                    ldx       PD.DEV,y            get pointer to device table
                    ldx       V$STAT,x            get static mem ptr
                    ldb       V.TYPE,x            Get device type    \ WON'T THIS SCREW UP WITH
                    bmi       L0136               Window, skip ahead / MARK OR SPACE PARITY???
                    pshs      x,a                 Save close code & X for SS.Close calling routine
                    lbsr      L025B               Not window, go call driver's SS.Close routine
                    leas      3,s                 Purge stack
L0136               ldu       PD.DV2,y            Get output device pointer
                    beq       L013D               Nothing there, go on
                    os9       I$Detach            Detach it
L013D               ldu       PD.BUF,y            Get buffer pointer
                    beq       L0147               None defined go on
                    ldd       #256                Get buffer size
                    os9       F$SRtMem            Return buffer memory to system
L0147               clra                          Clear carry
                    rts                           Return

* Remove path descriptor from device path descriptor linked list
* Entry: Y = path descriptor
RemoveFromPDList
                    ldx       #1
                    pshs      cc,d,x,y,u
                    ldu       PD.DEV,y            Get device table pointer
                    beq       L017B               None, skip ahead
                    ldu       V$STAT,u            Get static storage pointer
                    beq       L017B               None, skip ahead
                    ldx       V.PDLHd,u           Get path descriptor list header
                    beq       L017B               None, skip ahead
                    ldd       PD.PLP,y            Get path descriptor list pointer
                    cmpy      V.PDLHd,u           is the passed path descriptor the same?
                    bne       L0172               branch if not
                    std       V.PDLHd,u
                    bne       L017B
                    clr       4,s                 Clear LSB of X on stack
                    bra       L017B               Return

* D = path descriptor to store
L016D               ldx       PD.PLP,x            advance to next path descriptor in list
                    beq       L0180               branch if at end of linked list
L0172               cmpy      PD.PLP,x            is the passed path descriptor the same?
                    bne       L016D               branch if not
                    std       PD.PLP,x            store
                    IFNE      H6309
L017B               clrd
                    ELSE
L017B               clra
                    clrb
                    ENDC
                    std       PD.PLP,y
L0180               puls      cc,d,x,y,u,pc


* Check path number?
* Entry: X=Ptr to device table (just LDX'd)
*        Y=Path dsc. ptr
L0182               beq       L012A               No device table, return to caller
                    ldx       V$STAT,x            Get static storage pointer
                    ldb       PD.PD,y             Get system path number from path dsc.
                    lda       PD.CPR,y            Get ID # of process currently using path
                    pshs      d,x,y               Save everything
                    cmpa      V.LPRC,x            Current process same as last process using path?
                    bne       L01CA               No, return
                    IFGT      Level-1
                    ldx       <D.Proc             Get current process pointer
                    ELSE
                    ldx       >D.Proc             Get current process pointer
                    ENDC
                    leax      P$Path,x            Point to local path table
                    clra                          Start path # = 0 (Std In)
L0198               cmpb      a,x                 Same path as one is process' local path list?
                    beq       L01CA               Yes, return
                    inca                          Move to next path
                    cmpa      #NumPaths           Done all paths?
                    blo       L0198               No, keep going
                    pshs      y                   Preserve path descriptor pointer
                    IFNE      H6309
                    lda       #SS.Relea           Release signals SetStat
                    ldf       #D$PSTA             Get Setstat offset
                    ELSE
                    ldd       #SS.Relea*256+D$PSTA
                    ENDC
                    bsr       L01FA               Execute driver setstat routine
                    puls      y                   Restore path pointer
                    IFGT      Level-1
                    ldx       <D.Proc             Get current process pointer
                    ELSE
                    ldx       >D.Proc             Get current process pointer
                    ENDC
                    lda       P$PID,x             Get parent process ID
                    sta       ,s                  Save it
                    IFGT      Level-1
                    os9       F$GProcP            Get pointer to parent process descriptor
                    ELSE
                    ldx       <D.PrcDBT
                    os9       F$Find64
                    ENDC
                    leax      P$Path,y            Point to local path table
                    ldb       1,s                 Get path number
                    clra                          Get starting path number
L01B9               cmpb      a,x                 Same path?
                    beq       L01C4               Yes, go on
                    inca                          Move to next path
                    cmpa      #NumPaths           Done all paths?
                    blo       L01B9               No, keep checking
                    clr       ,s                  Clear process ID
L01C4               lda       ,s                  Get process ID
                    ldx       2,s                 Get static storage pointer
                    sta       V.LPRC,x            Store it as last process
L01CA               puls      d,x,y,pc            Restore & return

* I$GetStt entry point
getstt              lda       PD.PST,y            Path status ok?
                    lbne      L04C6               No, terminate process
                    ldx       PD.RGS,y            Get register stack pointer
                    lda       R$B,x               Get function code
                    bne       L01F8               If not SS.Opt, call driver with function code
* ($00) SS.Opt Getstat - All of PD.OPT is already set up, *except* parity/baud, so we need to grab that
                    pshs      a,x,y               Preserve registers (LCB: why X? SS.ComSt doesn't use X)
                    lda       #SS.ComSt           Get code for Comstat
                    sta       R$B,x               Save it in callers B
                    ldu       R$Y,x               Preserve callers Y
                    pshs      u
                    bsr       L01F8               Call SS.ComSt GetStat in driver (puts parity/baud into callers Y)
                    puls      u                   Restore callers Y
                    puls      a,x,y               Restore registers
                    sta       R$B,x               Save SS.Opt code back into caller's B
                    ldd       R$Y,x               Get com stat (baud/parity)
                    stu       R$Y,x               Put original callers Y back
                    bcs       L01F6               Return if error
                    std       PD.PAR,y            Update path descriptor with baud/parity
L01F6               clrb                          Clear carry
L01F7               rts                           Return

* Execute device driver Get/Set Status routine
* Entry: A=GetStat/SetStat code
*        Y=path descriptor ptr
                    IFNE      H6309
L01F8               ldf       #D$GSTA             Get Getstat driver entry offset
L01FA               ldx       PD.DEV,y            Get device table pointer
                    ldu       V$STAT,x            Get static storage pointer
                    IFGT      Level-1
                    ldx       V$DRIVEX,x          get execution pointer of driver
                    ELSE
                    pshs      d
                    ldx       V$DRIV,x            get driver module
                    ldd       M$EXEC,x            Point to entry point in driver
                    leax      d,x
                    puls      d
                    ENDC
                    pshs      y,u                 Preserve registers
                    jsr       f,x                 Execute driver
                    puls      y,u,pc              Restore & return
                    ELSE
L01F8               ldb       #D$GSTA
L01FA               ldx       PD.DEV,y
                    ldu       V$STAT,x
                    IFGT      Level-1
                    ldx       V$DRIVEX,x
                    ELSE
                    pshs      d
                    ldx       V$DRIV,x            get driver module
                    ldd       M$EXEC,x
                    leax      d,x
                    puls      d
                    ENDC
                    pshs      u,y
LC486               jsr       b,x
                    puls      y,u,pc
                    ENDC

* I$SetStt entry point
setstt              lbsr      L04A2
L0212               bsr       L021B               Check codes
                    pshs      cc,b                Preserve registers
                    lbsr      L0453               Wait for device
                    puls      cc,b,pc             Restore & return

putkey              cmpa      #SS.Fill            Buffer preload?
                    bne       L01FA               No, go execute driver setstat
                    pshs      u,y,x
                    IFGT      Level-1
                    ldx       <D.Proc             Get current process pointer
                    ELSE
                    ldx       >D.Proc             Get current process pointer
                    ENDC
                    lda       R$Y,u               Get flag byte for CR/NO CR
                    pshs      a                   Save it
                    IFGT      Level-1
                    lda       P$Task,x            Get task number
                    ldb       <D.SysTsk           Get system task
                    IFNE      H6309
                    ldx       R$X,u               Get pointer to data to move
                    ldf       R$Y+1,u             Get number of bytes (max size of 256 bytes)
                    ldu       PD.BUF,y            Get input buffer pointer
                    clre                          High byte of Y
                    tfr       w,y                 Move size into proper register for F$Move
                    ELSE
                    pshs      d
                    clra
                    ldb       R$Y+1,u
                    ldx       R$X,u
                    ldu       PD.BUF,y
                    tfr       d,y
                    puls      d
                    ENDC
* X=Source ptr from caller, Y=# bytes to move, U=Input buffer ptr
                    os9       F$Move              Move it
                    bcs       putkey1             Exit if error
                    tfr       y,d                 Move number of bytes to D
                    ELSE
loop                lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       loop
                    ENDC
                    lda       ,s                  Get CR flag
                    bmi       putkey1             Don't want CR appended, exit
                    lda       #C$CR               Get code for carriage return
                    sta       b,u                 Put it in buffer to terminate string
putkey1             puls      a,x,y,u,pc          Eat stack & return

                    IFNE      H6309
L021B               ldf       #D$PSTA             Get driver entry offset for setstat
                    ELSE
L021B               ldb       #D$PSTA             Get driver entry offset for setstat
                    ENDC
                    lda       R$B,u               Get function code from caller
                    bne       putkey              Not SS.OPT, go check buffer load
* SS.OPT SETSTAT
                    ldx       PD.PAU,y            Get current pause & page
                    IFGT      Level-1
                    pshs      y,x                 Preserve Path pointer & pause/page
                    ldx       <D.Proc             Get current process pointer
                    lda       P$Task,x            Get task number
                    ldb       <D.SysTsk           Get system task number
                    ldx       R$X,u               Get callers destination pointer
                    leau      PD.OPT,y            Point to path options
                    ldy       #OPTCNT             Get option length
                    os9       F$Move              Move it to caller
                    puls      y,x                 Restore Path pointer & page/pause status
                    bcs       L01F7               Return if error from move
                    ELSE
                    pshs      x,y
                    ldx       R$X,u
                    leay      PD.OPT,y
                    ldb       #OPTCNT
optloop             lda       ,x+
                    sta       ,y+
                    decb
                    bne       optloop
                    puls      x,y
                    ENDC
                    IFEQ      H6309
                    pshs      x
                    ENDC
                    ldd       PD.PAU,y            Get new page/pause status
                    IFNE      H6309
                    cmpr      d,x                 Same as old?
                    ELSE
                    cmpd      ,s++
                    ENDC
                    beq       L0250               Yes, go on
                    ldu       PD.DEV,y            Get device table pointer
                    ldu       V$STAT,u            Get static storage pointer
                    beq       L0250               Go on if none
                    stb       V.LINE,u            Update new line count
L0250               ldx       PD.PAR,y            Get parity/baud
                    lda       #SS.ComSt           Get code for ComSt
                    pshs      a,x                 Preserve them
                    bsr       L025B               Update parity & baud
                    puls      a,x,pc              Restore & return

* Update path Parity & baud
L025B               pshs      x,y,u               Preserve everything
                    ldx       PD.RGS,y            Get callers register pointer
                    ldu       R$Y,x               Get his Y
                    lda       R$B,x               Get his B
                    pshs      a,x,y,u             Preserve it all
                    ldd       $10,s               Get current parity/baud
                    std       R$Y,x               Put it in callers Y
                    lda       $0F,s               Get function code
                    sta       R$B,x               Put it in callers B
                    lbsr      L04A7               Wait for device to be ready
                    lbsr      L0212               Send it to driver
                    puls      a,x,y,u             Restore callers registers
                    stu       R$Y,x               Put back his Y
                    sta       R$B,x               Put back his B
                    bcc       L0282               Return if no error
                    cmpb      #E$UnkSvc           Unknown service request?
                    beq       L0282               Yes, return
                    coma                          Set carry
L0282               puls      x,y,u,pc            Restore & return

* I$Read entry point
read                lbsr      L04A2               Go wait for device to be ready for us
                    bcc       L028A               No error, go on
L0289               rts                           Return with error

L028A               inc       PD.RAW,y            Make sure we do Raw read
                    ldx       R$Y,u               Get number of characters to read
                    beq       L02DC               Return if zero
                    pshs      x                   Save character count
                    ldx       #0
                    ldu       PD.BUF,y            Get buffer address
                    bsr       L03E2               Read 1 character from device
                    bcs       L02A4               Return if error
                    tsta                          Character read zero?
                    beq       L02C4               Yes, go try again
                    cmpa      PD.EOF,y            End of file character?
                    bne       L02BC               No, keep checking
L02A2               ldb       #E$EOF              Get EOF error code
L02A4               leas      2,s                 Purge stack
                    pshs      b                   Save error code
                    bsr       L02D5               Return
                    comb                          Set carry
                    puls      b,pc                Restore & return

******************************
*
* SCF file manager entry point
*
* Entry: Y = Path descriptor pointer
*        U = Callers register stack pointer
*

SCFEnt              lbra      open                Create path
                    lbra      open                Open path
                    lbra      bpnam               Makdir
                    lbra      bpnam               Chgdir
                    lbra      L0129               Delete (return no error)
                    lbra      L0129               Seek (return no error)
                    bra       read                Read character
                    nop
                    lbra      write               Write character
                    lbra      readln              ReadLn
                    lbra      writln              WriteLn
                    lbra      getstt              Get Status
                    lbra      setstt              Set Status
                    lbra      close               Close path

* MAIN READ LOOP (no editing)
L02AD               tfr       x,d                 move character count to D
                    tstb                          past buffer end?
                    bne       L02B7               no, go get character from device
* Not often used: only when buffer is full
                    bsr       L042B               move buffer to caller's buffer
                    ldu       PD.BUF,y            reset buffer pointer back to start
* Main char by char read loop
L02B7               bsr       L03E2               get a character from device
                    bcs       L02A4               exit if error
L02BC               ldb       PD.EKO,y            echo turned on?
                    beq       L02C4               no, don't write it to device
                    lbsr      L0565               send it to device write
L02C4               ldb       #1                  Bump up char count
                    abx
                    sta       ,u+                 save character in local buffer
                    beq       L02CF               go try again if it was a null
                    cmpa      PD.EOR,y            end of record charcter?
                    beq       L02D3               yes, return
L02CF               cmpx      ,s                  done read?
                    blo       L02AD               no, keep going till we are

L02D3               leas      2,s                 purge stack
L02D5               bsr       L042B               move local buffer to caller
                    ldu       PD.RGS,y            get register stack pointer
                    stx       R$Y,u               save number of characters read
L02DC               bra       L0453               update path descriptor and return

* Read character from device
L03E2               pshs      u,y,x               Preserve regs
                    ldx       PD.DEV,y            Get device table pointer for input
                    beq       L0401               None, exit
                    ldu       PD.DV2,y            Get device table pointer for echoed output
                    beq       L03F1               No echoed output device, skip ahead
L03EA               ldu       V$STAT,u            Get device static storage ptr for echo device
                    ldb       PD.PAG,y            Get lines per page
                    stb       V.LINE,u            Store it in device static
L03F1               tfr       u,d                 Yes, move echo device' static storage to D
                    ldu       V$STAT,x            Get static storage ptr for input
                    std       V.DEV2,u            Save echo device's static storage into input device
                    clra
                    sta       V.WAKE,u            Flag input device to be awake
                    IFGT      Level-1
                    ldx       V$DRIVEX,x          Get driver execution pointer
                    ELSE
                    pshs      d
                    ldx       V$DRIV,x            get driver module
                    ldd       M$EXEC,x            Get driver execution pointer
                    leax      d,x
                    puls      d
                    ENDC
                    jsr       D$READ,x            Execute READ routine in driver
L0401               puls      pc,u,y,x            Restore regs & return

* Move buffer to caller
* Entry: Y=Path dsc. ptr
*        X=# chars to move
L042B               pshs      y,x                 Preserve path dsc. ptr & char. count
                    ldd       ,s                  Get # bytes to move
                    beq       L0451               Exit if none
                    tstb                          Uneven # bytes (not even page of 256)?
                    bne       L0435               Yes, go on
                    deca                          >256, so bump MSB down
L0435               clrb                          Force to even page
                    ldu       PD.RGS,y            Get callers register stack pointer
                    ldu       R$X,u               Get ptr to caller's buffer
                    IFNE      H6309
                    addr      d,u                 Offset to even page into buffer
                    clre                          Clear MSB of count
                    ldf       1,s                 LSB of count on even page?
                    bne       L0442               No, go on
                    ince                          Make it even 256
L0442
                    IFGT      Level-1
                    lda       <D.SysTsk           Get source task number
                    ENDC
                    ELSE
                    leau      d,u
                    clra
                    ldb       1,s
                    bne       L0442               No, go on
                    inca
L0442               pshs      d
                    IFGT      Level-1
                    lda       <D.SysTsk           Get source task number
                    ENDC
                    ENDC
                    IFGT      Level-1
                    ldx       <D.Proc             Get destination task number
                    ldb       P$Task,x
                    ldx       PD.BUF,y            Get buffer pointer
                    IFNE      H6309
                    tfr       w,y                 Put count into proper register
                    ELSE
                    puls      y
                    ENDC
                    os9       F$Move              Move it to caller
                    ELSE
                    ldx       PD.BUF,y            Get buffer pointer
                    IFEQ      H6309
                    puls      y
                    ELSE
                    tfr       w,y
                    ENDC
                    pshs      u
L0443               lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       L0443
                    puls      u
                    ENDC
L0451               puls      pc,y,x              Restore & return

* I$ReadLn entry point
readln              bsr       L04A2               Go wait for device to be ready for us
                    bcc       L02E5               No error, continue
                    rts                           Error, exit with it

L02E5               ldd       R$Y,u               Get character count
                    beq       L0453               If none, mark device as un-busy
                    tsta                          Past 256 bytes?
                    beq       L02EF               No, go on
                    ldd       #$0100              Get new character count
L02EF               pshs      d                   Save character count
                    ldd       #$FFFF              Get maximum character count
                    std       PD.MAX,y            Store it in path descriptor
                    ldx       #0                  Set character count so far to 0
                    ldu       PD.BUF,y            Get buffer ptr
                    lbra      L05F8               Go process readln

* Wait for device - Clears out V.BUSY if either Default or output devices are
* no longer busy
* Modifies X and A
L0453
                    IFGT      Level-1
                    ldx       <D.Proc             Get current process
                    ELSE
                    ldx       >D.Proc             Get current process
                    ENDC
                    lda       P$ID,x              Get it's process ID
                    ldx       PD.DEV,y            Get device table pointer from our path dsc.
                    bsr       L045D               Check if it's busy
                    ldx       PD.DV2,y            Get output device table pointer
L045D               beq       L0467               Doesn't exist, exit
                    ldx       V$STAT,x            Get static storage pointer for our device
                    cmpa      V.BUSY,x            Same process as current process?
                    bne       L0467               No, device busy return
                    clra
                    sta       V.BUSY,x            Yes, mark device as free for use
L0467               rts                           Return

L0468               pshs      x,a                 Preserve device table entry pointer & process ID
L046A               ldx       V$STAT,x            Get device static storage address
                    ldb       V.BUSY,x            Get active process ID
                    beq       L048A               No active process, device not busy go reserve it
                    cmpb      ,s                  Is it our own process?
                    beq       L049F               Yes, return without error
                    bsr       L0453               Go wait for device to no longer be busy
                    tfr       b,a                 Get process # busy using device
                    os9       F$IOQu              Put our process into the IO Queue
                    inc       PD.MIN,y            Mark device as not mine
                    IFGT      Level-1
                    ldx       <D.Proc             Get current process
                    ELSE
                    ldx       >D.Proc             Get current process
                    ENDC
                    ldb       P$Signal,x          Get signal code
                    lda       ,s                  Get our process id # again for L046A
                    beq       L046A               No signal go try again
                    coma                          Set carry
                    puls      x,a,pc              Restore device table ptr (eat a) & return

* Mark device as busy;copy pause/interrupt/quit/xon/xoff chars into static mem
L048A               sta       V.BUSY,x            Make it as process # busy on this device
                    sta       V.LPRC,x            Save it as the last process to use device
                    lda       PD.PSC,y            Get pause character from path dsc.
                    sta       V.PCHR,x            Save copy in static storage (faster later)
                    ldd       PD.INT,y            Get keyboard interrupt & quit chars
                    std       V.INTR,x            Save copies in static mem
                    ldd       PD.XON,y            Get XON/XOFF chars
                    std       V.XON,x             Save them in static mem too
L049F               clra                          No error & return
                    puls      pc,x,a              Restore A=Process #,X=Dev table entry ptr

* Wait for device?
L04A2               lda       PD.PST,y            Get path status (carrier)
                    bne       L04C4               If carrier was lost, hang up process
L04A7
                    IFGT      Level-1
                    ldx       <D.Proc             Get current process ID
                    ELSE
                    ldx       >D.Proc             Get current process ID
                    ENDC
                    clra
                    sta       PD.MIN,y            Flag device is mine
                    lda       P$ID,x              Get process ID #
                    ldx       PD.DEV,y            Get device table pointer
                    bsr       L0468               Busy?
                    bcs       L04C1               No, return
                    ldx       PD.DV2,y            Get output device table pointer
                    beq       L04BB               Go on if it doesn't exist
                    bsr       L0468               Busy?
                    bcs       L04C1               No, return
L04BB               lda       PD.MIN,y            Device mine?
                    bne       L04A2               No, go wait for it
                    sta       PD.RAW,y            Mark device with editing
L04C1               ldu       PD.RGS,y            Get register stack pointer
                    rts                           Return

* Hangup process
L04C4               leas      2,s                 Purge return address
L04C6               ldb       #E$HangUp           Get hangup error code
                    cmpa      #S$Abort            Termination signal (or carrier lost)?
                    blo       L04D3               Yes, increment status flag & return
                    lda       PD.CPR,y            Get current process ID # using path
                    ldb       #S$Kill             Get kill signal
                    os9       F$Send              Send it to process
L04D3               inc       PD.PST,y            Set path status
                    orcc      #Carry              Set carry
                    rts                           Return

* I$WritLn entry point
writln              bsr       L04A2               Go wait for device to be ready for us
                    bra       L04E1               Go write

* I$Write entry point
write               bsr       L04A2               Go wait for device to be ready for us
                    inc       PD.RAW,y            Mark device for raw write
L04E1               ldx       R$Y,u               Get number of characters to write
                    lbeq      L055A               Zero so return
                    pshs      x                   Save character count
                    ldx       #$0000              Get write data offset
                    bra       L04F1               Go write data

L04EC               tfr       u,d                 Move current position in PD.BUF to D
                    tstb                          At 256 (end of PD.BUF)?
                    bne       L0523               No, keep writing from current PD.BUF

* Get new block of data to write into [PD.BUF]
* Only allows up to 32 bytes at a time, and puts them in the last 32 bytes of
* the 256 byte [PD.BUF] buffer. This way, can use TFR U,D/TSTB to see if fin-
* ished.
* NOTE: 32 bytes max for 6809, to keep "lockout" of grfdrv down to less CPU time
L04F1               pshs      y,x                 Save write offset & path descriptor pointer
                    tfr       x,d                 Move data offset to D
                    ldu       PD.RGS,y            Get register stack pointer
                    ldx       R$X,u               Get pointer to user's WRITE string
                    IFNE      H6309
                    addr      d,x                 Point to where we are in it now
                    ldw       R$Y,u               Get # chars of original write
                    subr      d,w                 Calculate # chars we have left to write
                    cmpw      #64                 More than 64?
                    bls       L0508               No, go on
                    ldw       #64                 Max size per chunk 6309=64
L0508               ldd       PD.BUF,y            Get buffer ptr
                    inca                          Point to PD.BUF+256 (1 byte past end
                    subr      w,d                 Subtract data size
                    ELSE
                    leax      d,x                 Point to where we are in it now
                    ldd       R$Y,u               Get # chars of original write
                    subd      ,s                  Calculate # chars we have left to write
                    cmpd      #32                 More than 32?
                    bls       L0508               No, go on
                    ldd       #32                 Max size per chunk 6809=32
L0508               pshs      d                   Save buffered chunk size on stack
                    ldd       PD.BUF,y            Get buffer ptr
                    inca                          Point to PD.BUF+256 (1 byte past end)
                    subd      ,s                  Subtract data size
                    ENDC
                    tfr       d,u                 Move it to U
                    lda       #C$CR               Put a carriage return 1 byte before start
                    sta       -1,u                of write portion of buffer
                    IFGT      Level-1
                    ldy       <D.Proc             Get current process pointer
                    lda       P$Task,y            Get the task number
                    ldb       <D.SysTsk           Get system task number
                    IFNE      H6309
                    tfr       w,y                 Get number of bytes to move
                    ELSE
                    puls      y
                    ENDC
                    os9       F$Move              Move data to buffer
                    ELSE
                    IFNE      H6309
                    pshs      u                   Move data to buffer (level 1)
                    tfm       x+,u+
                    puls      u
                    ELSE
                    puls      y                   Move data to buffer (level 1)
                    pshs      u
L0509               lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       L0509
                    puls      u
                    ENDC
                    ENDC
                    puls      y,x                 Restore path descriptor pointer and data offset

* at this point, we have
* 0,s = end address of characters to write
* X = number of characters written
* Y = PD pointer
* U = pointer to data buffer to write
* Level 2: Use callcode $06 to call grfdrv (old DWProtSW from previous versions,
*   now unused by GrfDrv
L0523
                    IFGT      Level-1
                    ldb       PD.PAR,y            get device parity: bit 7 set = window
                    cmpb      #$80                is it even potentially a CoWin window?
                    bne       L0524               no, skip the rest of the crap
                    clrb                          set to no uppercase conversion
                    lda       PD.RAW,y            get raw output flag
                    bne       g.raw               if non-zero, we do raw writes: no conversion
                    ldb       PD.UPC,y            get uppercase conversion flag: 1 = do uppercase
g.raw               pshs      b,x,y,u             save length, PD, data buffer pointers
                    lbsr      get.wptr            get window table ptr into Y
                    bcs       no.wptr             do old method on error
* now we find out the number of non-control characters to write...
g.fast              lda       5,s                 grab page number
                    inca                          go to the next page
                    clrb                          at the top of it
                    subd      5,s                 take out number of bytes left to write
                    pshs      b                   max. number of characters
                    clrb                          always <256 characters to write
g.loop              lda       ,u+                 get a character
                    cmpa      #$20                is it a control character?
                    blo       g.done              yes, we're done this stint
                    tst       1,s                 get uppercase conversion flag
                    beq       g.loop1             don't convert
                    bsr       L0403               do a lower-uppercase conversion, if necessary
                    sta       -1,u                save again
g.loop1             incb                          done one more character
                    cmpb      ,s                  done as many as we can?
                    bne       g.loop
g.done              leas      1,s                 kill max. count of characters to use
                    cmpb      #1                  one or fewer characters?
                    bls       no.wptr             yes, go use old method
* now we call grfdrv...
                    ldu       5,s                 get start pointer again
                    abx                           done B more characters...
                    stx       1,s                 save on-stack
                    lbsr      call.grf            go call grfdrv: no error possible on return
                    leau      b,u                 go up B characters in U, too
                    stu       5,s                 save old U, too
                    puls      b,x,y,u             restore registers
                    bra       L0544               do end-buffer checks and continue

no.wptr             puls      b,x,y,u             restore all registers
                    ENDC
L0524               lda       ,u+                 Get character to write
                    ldb       PD.RAW,y            Raw mode?
                    bne       L053D               Yes, go write it
                    ldb       PD.UPC,y            Force uppercase?
                    beq       L052A               No, continue
                    bsr       L0403               Make it uppercase
L052A               cmpa      #C$LF               Is it a Line feed?
                    bne       L053D               No, go print it
                    lda       #C$CR               Get code for carriage return
                    ldb       PD.ALF,y            Auto Line feed?
                    bne       L053D               Yes, go print carriage return first
                    bsr       L0573               Print carriage return
                    bcs       L055D               If error, go wait for device
                    lda       #C$LF               Now, print the line feed

* Write character to device (call driver)
L053D               bsr       L0573               Go write it to device
                    bcs       L055D               If error, go wait for device
                    ldb       #1                  Bump up # chars we have written
                    abx
L0544               cmpx      ,s                  Done whole WRITE call?
                    bhs       L0554               Yes, go save # chars written & exit
                    ldb       PD.RAW,y            Raw mode?
                    lbne      L04EC               Yes, keep writing
                    lda       -1,u                Get the char we wrote
                    lbeq      L04EC               NUL, keep writing
                    cmpa      PD.EOR,y            End of record?
                    lbne      L04EC               No, keep writing
L0554               leas      2,s                 Eof record, stop & Eat end of buffer ptr???
L0556               ldu       PD.RGS,y            Get callers register pointer
                    stx       R$Y,u               Save character count to callers Y
L055A               lbra      L0453               Mark device write clear and return

* Check for forced uppercase
L0403               cmpa      #'a                 Less then 'a'?
                    blo       L0412               Yes, leave it
                    cmpa      #'z                 Higher than 'z'?
                    bhi       L0412               Yes, leave it
                    suba      #$20                Make it uppercase
L0412               rts                           Return

L055D               leas      2,s                 Purge stack
                    pshs      b,cc                Preserve registers
                    bsr       L0556               Wait for device
                    puls      pc,b,cc             Restore & return

* Check for end of page (part of send char to driver)
L0573               pshs      u,y,x,a             Preserve registers
                    ldx       PD.DEV,y            Get device table pointer
                    cmpa      #C$CR               Carriage return?
                    bne       L056F               No, go print it
                    ldu       V$STAT,x            Get pointer to device stactic storage
                    ldb       V.PAUS,u            Pause request?
                    bne       L0590               Yes, go pause device
                    ldb       PD.RAW,y            Raw output mode?
                    bne       L05A2               Yes, go on
                    ldb       PD.PAU,y            End of page pause enabled?
                    beq       L05A2               No, go on
                    dec       V.LINE,u            Subtract a line
                    bne       L05A2               Not done, go on
                    ldb       #$ff                do a immediate pause request
                    stb       V.PAUS,u
                    bra       L059A               Go read next character

L03DA               pshs      u,y,x               Preserve registers
                    ldx       PD.DV2,y            Get output device table pointer
                    beq       NoOut               None, exit
                    ldu       PD.DEV,y            Get device table pointer
                    lbra      L03EA               Process & return

NoOut               puls      pc,u,y,x            No output device so exit

* Wait for pause release
L0590               bsr       L03DA               Read next character
                    bcs       L059A               Error, try again
                    cmpa      PD.PSC,y            Pause char?
                    bne       L0590               No, try again
L059A               bsr       L03DA               Reset line count and read a character
                    cmpa      PD.PSC,y            Pause character?
                    beq       L059A               Yes, go read again
* Process Carriage return - do auto linefeed & Null's if necessary
* Entry: A=CHR$($0D)
L05A2               ldu       V$STAT,x            Get static storage pointer
                    clra
                    sta       V.PAUS,u            Clear pause request
                    lda       #C$CR               Carriage return (in cases from pause)
                    bsr       L05C9               Send it to driver
                    lda       PD.RAW,y            Raw mode?
                    bne       L05C7               Yes, return
                    ldb       PD.NUL,y            Get end of line null count
                    pshs      b                   Save it
                    lda       PD.ALF,y            Auto line feed enabled?
                    beq       L05BE               No, go on
                    lda       #C$LF               Get line feed code
L05BA               bsr       L05C9               Execute driver write routine
                    bcs       L05C5               Error, purge stack and return
L05BE               clra                          Get null character
                    dec       ,s                  Done null count?
                    bpl       L05BA               No, go send it to driver
                    clra                          Clear carry
L05C5               leas      1,s                 Purge stack
L05C7               puls      pc,u,y,x,a          Restore & return

* Execute device driver write routine
* Entry: A=Character to write
* Execute device driver
* Entry: W=Entry offset (for type of function, ex. Write, Read)
*        A=Code to send to driver
L05C9               ldu       V$STAT,x            Get device static storage pointer
                    pshs      y,x                 Preserve registers
                    clrb
                    stb       V.WAKE,u            Wake it up
                    IFGT      Level-1
                    ldx       V$DRIVEX,x          Get driver execution pointer
                    ELSE
                    pshs      d
                    ldx       V$DRIV,x            Get driver execution pointer
                    ldd       M$EXEC,x
                    leax      d,x
                    puls      d
                    ENDC
                    jsr       D$WRIT,x            Execute driver
                    puls      pc,y,x              Restore & return

* Send character to driver
L0565               pshs      u,y,x,a             Preserve registers
                    ldx       PD.DV2,y            Get output device table pointer
                    beq       L0571               Return if none
                    cmpa      #C$CR               Carriage return?
                    beq       L05A2               Yes, go process it
L056F               ldu       V$STAT,x            Get device static storage pointer
                    clrb
                    stb       V.WAKE,u            Wake it up
                    IFGT      Level-1
                    ldx       V$DRIVEX,x          Get driver execution pointer
                    ELSE
                    pshs      d
                    ldx       V$DRIV,x            get driver module
                    ldd       M$EXEC,x
                    leax      d,x
                    puls      d
                    ENDC
                    jsr       D$WRIT,x            Execute driver
L0571               puls      pc,u,y,x,a          Restore & return


* Check for printable character (Entry: A=char to echo)
L0413               ldb       PD.EKO,y            Echo turned on?
                    bne       L0418               Yes, go do
                    rts                           No, just return

L0418               cmpa      #C$SPAC             CHR$(32) or higher?
                    bhs       L0565               Yes, go send to driver
                    cmpa      #C$CR               Ctrl char; is it a Carriage return?
                    beq       L0565               Yes, send it to the driver
* Any ctrl char <> CR, replace with period when echoed to device
L0423               pshs      a                   Save code
                    lda       #'.                 Get code for period
                    bsr       L0565               Output it to device
                    puls      pc,a                Restore original ctrl char & return

L0624               bsr       L0418               check if it's printable and send it to driver
* Process ReadLn
L05F8               lbsr      L03E2               get a character from device
                    lbcs      L0370               return if error
                    tsta                          usable character?
                    lbeq      L02FE               no, check path descriptor special characters
                    ldb       PD.RPR,y            get reprint line code
                    cmpb      #C$RPRT             cntrl D?
                    lbeq      L02FE               yes, check path descriptor special characters
                    cmpa      PD.RPR,y            reprint line?
                    bne       L0629               no, Check line editor keys
                    cmpx      PD.MAX,y            character count at maximum?
                    beq       L05F8               yes, go read next character
                    ldb       #1                  Bump char count up by 1
                    abx
                    cmpx      ,s                  done?
                    bhs       L0620               yes, exit
                    lda       ,u+                 get character read
                    beq       L0624               null, go send it to driver
                    cmpa      PD.EOR,y            end of record character?
                    bne       L0624               no, go send it to driver
                    leau      -1,u                bump buffer pointer back 1
L0620               leax      -1,x                bump character count back 1
                    bra       L05F8               go read next character

L0629               cmpa      #C$PLINE            Print rest of line code?
                    bne       L0647               No, check insert
* Process print rest of line
L062D               pshs      u                   Save buffer pointer
                    lbsr      L038B               Go print rest of line
                    lda       PD.BSE,y            Get backspace echo character
L0634               cmpu      ,s                  Beginning of buffer?
                    beq       L0642               Yes, exit
                    leau      -1,u                Bump buffer pointer back 1
                    leax      -1,x                Bump character count back 1
                    bsr       L0565               Print it
                    bra       L0634               Keep going

L0642               leas      2,s                 Purge buffer pointer
                    bra       L05F8               Return

L0647               cmpa      #C$INSERT           Insert character code?
                    bne       L0664               No, check delete
* Process Insert character (NOTE:Currently destroys W)
                    IFNE      H6309
                    pshs      x,y                 Preserve x&y a moment
                    tfr       u,w                 Dupe buffer pointer into w
                    ldf       #$fe                End of buffer -1
                    tfr       w,x                 Source copy address
                    incw                          Include char we are on & dest address is+1
                    tfr       w,y                 Destination copy address
                    subr      u,w                 w=w-u (Size of copy)
                    tfm       x-,y-               Move buffer up one
                    puls      y,x                 Get back original y & x
                    lda       #C$SPAC             Get code for space
                    sta       ,u                  Save it there
                    ELSE
                    pshs      u
                    tfr       u,d                 Move buffer ptr to D
                    ldb       #$FF                Point to end of buffer
                    tfr       d,u                 Move back to U
L06DE               lda       ,-u                 shift buffer later by 1 char
                    sta       1,u
                    cmpu      ,s
                    bne       L06DE
                    lda       #C$SPAC             Insert space at insert point in buffer
                    sta       ,u
                    leas      2,s
                    ENDC
                    bra       L062D               Go print rest of line

L0664               cmpa      #C$DELETE           Delete character code?
                    bne       L068B               No, check end of line
* Process delete line
                    pshs      u                   Save buffer pointer
                    lda       ,u                  Get character there
                    cmpa      PD.EOR,y            End of record?
                    beq       L0687               Yes, don't bother to delete it
L0671               lda       1,u                 Get character beside it
                    cmpa      PD.EOR,y            This an end of record?
                    beq       L067C               Yes, delete it
                    sta       ,u+                 Bump character back
                    bra       L0671               Go do next character

L067C               lda       #C$SPAC             Get code for space
                    cmpa      ,u                  Already there?
                    bne       L0685               No, put it in
                    lda       PD.EOR,y            Get end of record code
L0685               sta       ,u                  Put it there
L0687               puls      u                   Restore buffer pointer
                    bra       L062D               Go print rest of line

* Delete rest of buffer
L068B               cmpa      PD.EOR,y            End of record code? (normally CR)
                    bne       L02FE               No, check for special path dsc. chars
* CR hit, replace rest of buffer with spaces?
                    pshs      u                   Yes, Save buffer pointer
                    bra       L069F               Go erase rest of buffer

L0696               pshs      a                   Save CR code
                    lda       #C$SPAC             Get code for space
                    lbsr      L0565               Print it
                    puls      a                   Restore CR code
L069F               cmpa      ,u+                 End of record?
                    bne       L0696               No, go print a space
                    puls      u                   Restore buffer pointer
* Check character read against path descriptor
L02FE               tsta                          Usable character?
                    beq       L030C               No, go on
                    ldb       #PD.BSP             Get start point in path descriptor
L0303               cmpa      b,y                 Match code in descriptor?
                    beq       L032C               Yes, go process it
                    incb                          Move to next one
                    cmpb      #PD.QUT             Done check?
                    bls       L0303               No, keep going
L030C               cmpx      PD.MAX,y            Past maximum character count?
                    bls       L0312               No, go on
                    stx       PD.MAX,y            Update maximum character count
L0312               ldb       #1                  Add 1 char
                    abx
                    cmpx      ,s                  Past requested amount?
                    blo       L0322               No, go on
                    lda       PD.OVF,y            Get overflow character
                    lbsr      L0565               Send it to driver
                    leax      -1,x                Subtract a character
                    lbra      L05F8               Go try again

L0322               ldb       PD.UPC,y            Force uppercase?
                    beq       L0328               No, put char in buffer
                    lbsr      L0403               Make character uppercase
L0328               sta       ,u+                 Put character in buffer
                    lbsr      L0413               Check for printable
                    lbra      L05F8               Go try again

* Process path option characters
L032C               pshs      x,pc                Preserve character count & PC
                    leax      <L033F,pc           Point to branch table
                    subb      #PD.BSP             Subtract off first code
                    lslb                          Account for 2 bytes a entry
                    abx                           Point to entry point
                    stx       2,s                 Save it in PC on stack
                    puls      x                   Restore X
C8E3                jsr       [,s++]              Execute routine
                    lbra      L05F8               Continue on

* Vector points for PD.BSP-PD.QUT
L033F               bra       L03BB               Process PD.BSP
                    bra       L03A5               Process PD.DEL
                    bra       L0351               Process PD.EOR
                    bra       L0366               Process PD.EOF
                    bra       L0381               Process PD.RPR
                    bra       L038B               Process PD.DUP
                    rts                           PD.PSC we don't worry about
                    nop
                    bra       L03A5               Process PD.INT
                    bra       L03A5               Process PD.QUT

* Process PD.EOR character
L0351               leas      2,s                 Purge return address
                    sta       ,u                  Save character in buffer
                    lbsr      L0413
                    ldu       PD.RGS,y            Get callers register stack pointer
                    ldb       #1                  Bump up char count by 1
                    abx
                    stx       R$Y,u               Store it in callers Y
                    lbsr      L042B
                    leas      2,s
                    lbra      L0453

* Process PD.EOF
L0366               leas      2,s                 Purge return address
                    leax      ,x                  read anything?
                    lbeq      L02A2
                    bra       L030C

L0370               pshs      b
                    lda       #C$CR
                    sta       ,u
                    lbsr      L0565               Send it to the driver
                    puls      b
                    lbra      L02A4

* Process PD.RPR
L0381               lda       PD.EOR,y            Get end of record character
                    sta       ,u                  Put it in buffer
                    ldx       #0
                    ldu       PD.BUF,y            Get buffer ptr
L0388               lbsr      L0418               Send it to driver
L038B               cmpx      PD.MAX,y            Character maximum?
                    beq       L03A2               Yes, return
                    ldb       #1                  Bump char count up by 1
                    abx
                    cmpx      2,s                 Done count?
                    bhs       L03A0               Yes, exit
                    lda       ,u+                 Get character from buffer
                    beq       L0388               Null, go send it
                    cmpa      PD.EOR,y            Done line?
                    bne       L0388               No go send it
                    leau      -1,u                Move back a character
L03A0               leax      -1,x                Move character count back
L03A2               rts                           Return

L03A3               bsr       L03BF
* PD.DEL/PD.QUT/PD.INT processing
L03A5               leax      ,x                  Any characters?
                    beq       L03B8               No, reset buffer ptr
                    ldb       PD.DLO,y            Backspace over line?
                    beq       L03A3               Yes, go do it
                    ldb       PD.EKO,y            Echo character?
                    beq       L03B5               No, zero out buffer pointers & return
                    lda       #C$CR               Send CR to the driver
                    lbsr      L0565               send it to driver
L03B5               ldx       #0                  zero out count
L03B8               ldu       PD.BUF,y            reset buffer pointer
L03BA               rts                           return

* Process PD.BSP
L03BB               leax      ,x                  Any characters?
                    beq       L03A2               No, return
L03BF               leau      -1,u                Mover buffer pointer back 1 character
                    leax      -1,x                Move character count back 1
                    ldb       PD.EKO,y            Echoing characters?
                    beq       L03BA               No, return
                    ldb       PD.BSO,y            Which backspace method?
                    beq       L03D4               Use BSE
                    bsr       L03D4               Do a BSE
                    lda       #C$SPAC             Get code for space
                    lbsr      L0565               Send it to driver
L03D4               lda       PD.BSE,y            Get BSE
                    lbra      L0565               Send it to driver

                    IFGT      Level-1
* check PD.DTP,y and update PD.WPTR,y if it's device type $10 (grfdrv)
get.wptr            pshs      x,u
                    ldu       PD.DEV,y            get device table entry
                    ldx       V$DRIV,u            get device driver module
                    ldd       M$Name,x            offset to name
                    ldd       d,x
                    cmpd      #"VT                is it VTIO?
                    bne       no.fast             no, don't do the fast stuff
* If/when we introduce buffered writes to CoVDG, this will need changing. LCB
                    ldd       >WGlobal+G.GrfEnt   does GrfDrv have an entry address?
                    beq       no.fast             nope, don't bother calling it.
                    ldu       V$STAT,u            and device static storage
                    tst       V.ParmCnt,u         are we busy getting more parameters?
                    bne       no.fast             yes, don't do buffered writes
* Get window table pointer & verify it: copied from CoWin and modified
                    ldb       V.WinNum,u          Get window # from device mem
                    lda       #Wt.Siz             Size of each entry
                    mul                           Calculate window table offset
                    addd      #WinBase            Point to specific window table entry
                    tfr       d,y                 Move to y, the register we want
                    lda       Wt.STbl,y           Get MSB of scrn tbl ptr
                    bgt       VerExit             If $01-$7f, should be ok
* Return illegal window definition error
no.fast             comb                          set carry: no error code, it's an internal routine
                    puls      x,u,pc

VerExit             clra                          No error
                    puls      x,u,pc

call.grf            pshs      d,x,y,u             save registers
                    ldx       #$0180              where to put the text
                    IFNE      H6309
                    pshs      cc                  save old CC
                    ELSE
                    tfr       cc,a
                    sta       -2,x
                    ENDC
                    orcc      #IntMasks+Entire    shut everything else off
                    IFNE      H6309
                    clra                          make sure high byte=0
                    tfr       d,w
                    tfm       u+,x+               move the data into low memory
                    ELSE
l@                  lda       ,u+
                    sta       ,x+
                    decb
                    bne       l@
                    ENDC
                    ldb       #6                  alpha put
                    stb       >WGlobal+G.GfBusy   flag grfdrv busy
                    IFNE      H6309
                    lde       ,s+                 grab old CC off of the stack
                    lda       1,s                 get the number of characters to write
                    ELSE
                    lda       1,s                 get the number of characters to write
                    ENDC
* A = number of bytes at $0180 to write out...
                    bsr       do.grf              do the call
* ignore errors : none possible from this particular call
call.out            puls      d,x,y,u,pc          and return

* this routine should always be called by a BSR, and grfdrv will use the
* PC saved on-stack to return to the calling routine.
* ALL REGISTERS WILL BE TRASHED
do.grf              sts       >WGlobal+G.GrfStk   stack pointer for GrfDrv
                    lds       <D.CCStk            get new stack pointer
                    IFNE      H6309
                    pshs      dp,x,y,u,pc
                    pshsw
                    pshs      cc,d                save all registers
                    ELSE
                    pshs      dp,cc,d,x,y,u,pc
                    ENDC
                    ldx       >WGlobal+G.GrfEnt   get GrfDrv entry address
                    stx       R$PC,s              save grfdrv entry address as PC on the stack
                    IFNE      H6309
                    ste       R$CC,s              save CC onto CC on the stack
                    ELSE
                    stb       R$B,s
                    ldb       $017E
                    stb       R$CC,s
                    ENDC
                    jmp       [>D.Flip1]          flip to grfdrv and execute it
                    ENDC

                    emod
eom                 equ       *
                    end

