********************************************************************
* rb1773 - Western Digital 1773 Disk Controller Driver
*
* $Id$
*
* This driver has been tested with the following controllers:
*   - Tandy FD-502 "shortie" disk controller
*   - Disto Super Controller I
*   - Disto Super Controller II
*
* This driver can also be assembled to support the no-halt feature of
* the Disto Super Controller II.
*
*
* A lot of references to **.CYL or <u00B6 using 16 bit registers can be
* changed to 8 bit registers with a +1 offset, since track #'s >255 are
* ignored
*
* NOTE: 512 bytes is reserved as a physical sector buffer. Any reads/
*  writes are done from this buffer to the controller. Copies of the 256
*  byte chunk needed are done by a block memory move
*
*
********** DISTO SUPER CONTROLLER II NOTES **********
*
* SCII     0=standard controller 1=Disto Super Controller II
* SCIIALT  0=Normal I/O register 1=Alternative registers; See below
*
* Disto Super Controller II Registers:
*
* $FF74   RW.Dat  --- R/W Buffer data #1
* $FF75       mirror of $FF74
* $FF76   RW.Ctrl --- Write  D0 = 0  FDC Write Op #2
*                               = 1  FDC Read Op  #2
*                            D1 = 0  Normal Mode
*                               = 1  Buffered I/O Mode
*                            D2 = 0  Normal NMI
*                               = 1  Masked NMI
*                            D3 = 0  No FIRQ (Masked)
*                               = 1  Enabled FIRQ
*                     Read   D7 = FDC INT Status (Inverted)
* $FF77       mirror of $FF76
*        #1: any write to $FF76-$FF77 clears Buffer counter
*        #2: in buffered mode only
*
* Alternate port is at $FF58-$FF5B in case of hardware conflicts.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  11      1993/05/12  ???
* Special opts for TC9 to slow controller reads and writes TFM's
* between sector buffers & in drive table init/copies.
* Changed software timing loop (drive spin-up) to F$Sleep for 32 ticks
* Shrunk (slowed slightly) error returns
* Added blobstop code
*
*  11r1    2003/09/03  Boisy G. Pitre
* Added code to sense if HW is present or not and return error if not.
*
*   1r0    2004/05/20  Boisy G. Pitre
* Restarted edition due to name change; backported to Level 1
*
*          2004/06/01  Robert Gault
* Added code to obtain an SCII driver, at least for the Sleep mode. It
* would be quite difficult and probably not worth the effort to permit
* selection of both Sleep and IRQ SCII drivers. However, both normal
* and Alt SCII I/O registers are supported.
*
* Cleaned up some errors in the last version of rb1773.
*
*         2004/07/11   Robert Gault
* Corrected the error handling code for read & write to separate SCII errors
* from OS-9 errors. Changed drive test from compare #4 to compare #N.Drives to
* permit up to 6 drives using alternate table.
*
*         2005/01/27   Robert Gault
* Separated the sector write and format write loops so that the CPU clock
* can be slowed down during formats. This "corrects" problems some hardware
* have with the current NitrOS-9 during formats.
*
*   1r1   2005/04/07   Boisy G. Pitre
* We now save the contents of D.NMI (Level 2) or D.XNMI (Level 1) before
* overwriting them, and then restore the original values at term time.
*
*	2009/03/19	Robert Gault
* Removed slow down hack from format and write sector but left code just in case.
*
*     2013/12/16 Robert Gault and Gene Heskett
* Added two new flags, flagWP flagFMT, to prevent disk damage by Writes where
* the drive head width does not match the disk track density.
* flagWP <>0 write protects; flagFMT <>0 overrules flagWP so that a Format can
* write to a disk.
* A descriptor that does not match your drive can still cause Writes to disks that
* could possibly cause disk corruption. This cannot be prevented.
*
* When LSN0 is read using a 3.5" drive, most of the checks of density, sides, etc.
* are bypassed as not needed.

                    nam       rb1773
                    ttl       Western Digital 1773 Disk Controller Driver

* These lines needed if assembling with on a Color computer.
*SCII     set   1                 * 0=not present 1=present
*SCIIALT  set   1                 * 0=normal address 1=alternate
SCIIHACK            set       0                   * 0=stock model 1=512 byte buffer
*H6309    set   1
*LEVEL    set   2
* These lines needed if not using latest os9def files.
*TkPerSec set   60
*DPort    set   $FF40

* This should be changed for NitrOS9 project to "use defsfile"
                    ifp1
                    use       defsfile
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       1

* Configuration Settings
N.Drives            equ       4                   number of drives to support
TC9                 equ       0                   Set to 1 for TC9 special slowdowns
PRECOMP             equ       0                   Set to 1 to turn on write precompensation

* Disto Super Controller defs
                    ifeq      SCIIALT
RW.Dat              equ       $FF74
RW.Ctrl             equ       $FF76
                    else
RW.Dat              equ       $FF58
RW.Ctrl             equ       $FF5A
                    endc


* WD-17X3 Definitions
CtrlReg             equ       $00                 Control register for Tandy controllers; not part of WD
WD_Cmd              equ       $08
WD_Stat             equ       WD_Cmd
WD_Trak             equ       $09
WD_Sect             equ       $0A
WD_Data             equ       $0B

* WD-17X3 Commands
S$Read              equ       $80                 Read sector
S$Format            equ       $A0                 Format track
S$FrcInt            equ       $D0                 Force interrupt

* Control Register Definitions
C_HALT              equ       %10000000           Halt line to CPU is active when set
C_SIDSEL            equ       %01000000           Side select (0 = front side, 1 = back side)
C_DBLDNS            equ       %00100000           Density (0 = single, 1 = double)
C_WPRCMP            equ       %00010000           Write precompensation (0 = off, 1 = on)
C_MOTOR             equ       %00001000           Drive motor (0 = off, 1 = on)
C_DRV2              equ       %00000100           Drive 2 selected when set
C_DRV1              equ       %00000010           Drive 1 selected when set
C_DRV0              equ       %00000001           Drive 0 selected when set

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       DRVBEG+(DRVMEM*N.Drives)
lastdrv             rmb       2                   Last drive table accessed (ptr)
ctlimg              rmb       1                   Bit mask for control reg (drive #, side,etc)
u00AA               rmb       1                   drive change flag
sectbuf             rmb       2                   Ptr to 512 byte sector buffer
currside            rmb       1                   head flag; 0=front 1 = back
u00AE               rmb       1                   LSB of LSN
                    ifgt      Level-1
FBlock              rmb       2                   block number for format
FTask               rmb       1                   task number for format
NMISave             rmb       2
                    else
NMISave             rmb       3
                    endc
VIRQPak             rmb       2                   Vi.Cnt word for VIRQ
u00B3               rmb       2                   Vi.Rst word for VIRQ
u00B5               rmb       1                   Vi.Stat byte for VIRQ (drive motor timeout)
loglsn              rmb       2                   OS9's logical sector #
* Removed next line and added two new ones. RG
* PCDOS does not ask driver for any info.
* physlsn  rmb   2              PCDOS (512 byte sector) #
flag512             rmb       1                   PCDOS (512 byte sector) 0=no, 1=yes
flagform            rmb       1                   SCII format flag
flagWP              rmb       1                   write protection <>0
flagFMT             rmb       1                   format flag
size                equ       .

                    fcb       DIR.+SHARE.+PEXEC.+PWRIT.+PREAD.+EXEC.+UPDAT.

name                fcs       /rb1773/
                    fcb       edition

VIRQCnt             fdb       TkPerSec*4          Initial count for VIRQ (4 seconds)

IRQPkt              fcb       $00                 Normal bits (flip byte)
                    fcb       $01                 Bit 1 is interrupt request flag (Mask byte)
                    fcb       10                  Priority byte

* Init
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
* New code added 09/03/2003 by Boisy G. Pitre
* Write a pattern to $FF4B and read it back to verify that the hardware
* does exist.
Init                equ       *
* Two new lines for SCII. RG
                    ifne      SCII
                    clr       RW.Ctrl             clear SCII control register
                    clr       flagform,u          clear SCII format flag
                    endc
                    clr       flagWP,u
                    clr       flagFMT,u
                    ldx       V.PORT,u            get Base port address
                    lda       WD_Data,x           get byte at FDC Data register
                    coma                          complement it to modify it
                    sta       WD_Data,x           write it
                    clrb
Init2               decb                          delay a bit...
                    bmi       Init2
                    suba      WD_Data,x           read it back
                    lbne      NoHW                if not zero, we didn't read what we wrote
**
                    ifeq      Level-1
                    clr       >D.DskTmr           flag drive motor as not running
                    else
                    clr       <D.MotOn            flag drive motor as not running
                    endc
                    leax      WD_Stat,x           point to Status/Command register
                    lda       #S$FrcInt           "Force Interrupt" command
                    sta       ,x                  send to FDC
                    lbsr      FDCDelay            time delay for ~ 108 cycles
                    lda       ,x                  eat status register
                    ldd       #$FF*256+N.Drives   'invalid' value & # of drives
                    leax      DRVBEG,u            point to start of drive tables
l1                  sta       ,x                  DD.TOT MSB to bogus value
                    sta       <V.TRAK,x           init current track # to bogus value
                    leax      <DRVMEM,x           point to next drive table
                    decb                          done all drives yet?
                    bne       l1                  no, init them all
*** Fix on 04/06/2005: we now save the contents of D.NMI (Level 2)
*** or D.XNMI (Level 1) before overwriting them.
                    ifgt      Level-1
                    ldx       >D.NMI
                    stx       NMISave,u
                    leax      >NMISvc,pc          point to NMI service routine
                    stx       >D.NMI              install as system NMI
                    else
                    ldx       >D.XNMI
                    stx       NMISave,u
                    lda       >D.XNMI+2
                    sta       NMISave+2,u
                    leax      >NMISvc,pc          point to NMI service routine
                    stx       >D.XNMI+1           NMI jump vector operand
                    lda       #$7E                JMP code
                    sta       >D.XNMI             NMI jump vector opcode
                    endc
                    pshs      y                   save device dsc. ptr
                    leay      >u00B5,u            point to Vi.Stat in VIRQ packet
                    tfr       y,d                 make it the status register ptr for IRQ
                    leay      >IRQSvc,pc          point to IRQ service routine
                    leax      >IRQPkt,pc          point to IRQ packet
                    os9       F$IRQ               install IRQ
                    puls      y                   Get back device dsc. ptr
                    bcs       Return              If we can't install IRQ, exit
                    ldd       #512                Request 512 byte sector buffer
                    pshs      u                   Preserve device mem ptr
                    os9       F$SRqMem            Request sector buffer
                    tfr       u,x                 Move ptr to sector buffer to x
                    puls      u                   Restore device mem ptr
                    bcs       Return              If error, exit with it
                    stx       >sectbuf,u          Save ptr to sector buffer

* GetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
GetStat             clrb                          no GetStt calls - return, no error, ignore
Return              rts

* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Term                leay      >VIRQPak,u          Point to VIRQ packet
                    ifne      H6309
                    tfr       0,x                 "remove"
                    else
                    ldx       #$0000
                    endc
                    os9       F$VIRQ              Remove VIRQ
                    ifne      H6309
                    tfr       0,x                 "remove"
                    else
                    ldx       #$0000
                    endc
                    leay      >IRQSvc,pc          point to IRQ service routine
                    os9       F$IRQ               Remove IRQ
*** Fix: we now restore original D.NMI (Level 2) or D.XNMI (Level 1)
*** before overwriting them.
                    ifgt      Level-1
                    ldx       NMISave,u
                    stx       >D.NMI
                    else
                    ldx       NMISave,u
                    stx       >D.XNMI
                    lda       NMISave+2,u
                    sta       >D.XNMI+2
                    endc
***
                    pshs      u                   Save device mem ptr
                    ldu       >sectbuf,u          Get pointer to sector buffer
                    ldd       #512                Return sector buffer memory
                    os9       F$SRtMem
                    puls      u                   Restore device mem ptr
                    clr       >DPort+CtrlReg      shut off drive motors
                    ifeq      Level-1
                    clr       >D.DskTmr           Clear out drive motor timeout flag
                    else
                    clr       <D.MotOn            Clear out drive motor timeout flag
                    endc
ex                  rts                           return

* Check if 512 byte sector conversion needed
* Entry: B:X=LSN
*        U=Static mem ptr
*        Y=Path dsc. ptr
* Exit:  X=New LSN (same as original for 256 byte sectors, 1/2 of original
*        for 512 byte sectors
*        regD changed
Chk512              equ       *
                    clr       flag512,u           set to 256 byte sector
                    stx       >loglsn,u           save OS9 LSN
                    lda       <PD.TYP,y           get device type from path dsc.
                    anda      #%00000100          mask out all but 512 byte sector flag
                    bne       Log2Phys            512 byte sectors, go process
                    rts                           RG

* 512 byte sector processing goes here
* regB should be saved and not just cleared at end because there is
* a subsequent tst for the msb of lsn. The test is pointless if B
* is changed.
Log2Phys            pshs      b                   save MSB of LSN; new RG
* Minor inefficiencies here that I have changed, RG
                    tfr       x,d
                    ifne      H6309
                    lsrd
                    else
                    lsra
                    rorb
                    endc
                    tfr       d,x                 move new LSN back to regX
* New line for stock SCII controller with 256 max no-halt.
                    inc       flag512,u           set to 512 byte sector
                    puls      b,pc                regB will be tested later for >0

start               lbra      Init
                    bra       Read
                    nop
                    lbra      Write
                    bra       GetStat
                    nop
                    lbra      SetStat
                    bra       Term
                    nop

* Read
*
* Entry:
*    B  = MSB of LSN
*    X  = LSB of LSN
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Read                bsr       Chk512              go check for 512 byte sector/adjust if needed
                    lda       #%10010001          error flags (see Disto SCII source)
                    pshs      x                   preserve sector #
                    lbsr      ReadWithRetry       go read the sector
                    puls      x                   restore sector #
                    bcs       ex                  if error, exit
                    pshs      y,x                 save path dsc ptr & LSN
                    leax      ,x                  LSN0?, ie. tstx
                    bne       L012D               no, go calculate normally
                    puls      y,x                 yes, restore path dsc ptr & LSN
                    lda       <PD.TYP,y           get type from path dsc.
                    bita      #TYP.NSF            standard OS-9 format?
                    beq       L00F0               yes, skip ahead
                    lbsr      MakeDTEntry         else make a drive table entry
                    pshs      y,x                 save path dsc ptr
                    bra       L012D

* LSN0, standard OS-9 format - copy part of LSN0 into drive table
L00F0               ldx       >sectbuf,u          Get ptr to sector buffer
                    pshs      y,x                 Preserve path dsc. ptr & sector buffer ptr
                    ldy       >lastdrv,u          Get last drive table accessed ptr
                    ifne      H6309
                    ldw       #DD.SIZ             # bytes to copy from new LSN0 to drive table
                    tfm       x+,y+               Copy them
                    else
                    ldb       #DD.SIZ
L00F0Lp             lda       ,x+
                    sta       ,y+
                    decb
                    bne       L00F0Lp
                    endc
                    ldy       >lastdrv,u          Get drive table ptr back
                    lda       <DD.FMT,y           Get format for disk in drive
                    ldy       2,s                 restore path descriptor pointer
* !!!!!!! Most of these tests are pointless with a 3.5" drive RG
                    ldb       <PD.TYP,y           Get path's type settings RG
                    bitb      #1                  test for 3.5" drive
                    bne       L0128               skip rest of tests if 3.5" drive
                    ldb       <PD.DNS,y           Get path's density settings
                    bita      #FMT.DNS            Disk in drive double density?
                    beq       L0115               No, all drives can read single, skip ahead
                    bitb      #DNS.MFM            Can our path dsc. handle double density?
                    beq       erbtyp              No, illegal
L0115               bita      #FMT.TDNS           Is new disk 96tpi?
                    beq       L011D               No, all drives handle 48/135 tpi, so skip ahead
                    sta       flagWP,u            set write protection
                    bitb      #DNS.DTD            Can path dsc. handle 96 tpi?
                    beq       erbtyp              No, illegal format
                    clr       flagWP,u            clear write protection since disk and descriptor match
L011D               bita      #FMT.SIDE           Is new disk double sided?
                    beq       L0128               No, all drives handle single sided, we're done
                    lda       <PD.SID,y           Get # sides path dsc. can handle
                    suba      #2                  sides higher or equal to 2?
                    blo       erbtyp              Yes, exit with illegal type error
L0128               clrb                          No error
* LSN's other than 0 come straight here
L012D               ldy       2,s                 Get path dsc. ptr back??
                    ldx       PD.BUF,y            Get path dsc. buffer ptr
*        lda   <PD.TYP,y      Get path dsc. disk type, RG
                    ldy       >sectbuf,u          Get ptr to sector buffer
                    ifne      H6309
                    ldw       #256                OS9 sector size (even if physical was 512)
                    endc
*        anda  #%00000100     Mask out all but 512 byte sector flag, RG
* Next replaces the two lines removed, RG
                    tst       flag512,u           Is it a 512 byte sector?
                    beq       L014B               If normal sector, just copy it
                    ldd       >loglsn,u           Get OS9's LSN (twice of the 'real' 512 sector)
                    andb      #$01                Mask out all but odd/even sector indicator
                    beq       L014B               Even, use 1st half of 512 byte sector
                    ifne      H6309
                    addr      w,y                 Odd, bump sector buffer ptr to 2nd half
                    else
                    leay      256,y
                    endc
L014B               equ       *
                    ifne      H6309
                    tfm       y+,x+               Copy from physical sector buffer to PD buffer
                    puls      pc,y,x              restore path dsc & sector buffer ptrs & return
                    else
                    pshs      d
                    clrb
L014BLp             lda       ,y+
                    sta       ,x+
                    decb
                    bne       L014BLp
                    puls      pc,y,x,d            restore path dsc & sector buffer ptrs & return
                    endc

erbtyp              comb
                    ldb       #E$BTyp             Error - wrong type error
                    puls      pc,y,x

**********************
* Read error - retry handler
Retry
                    bcc       ReadWithRetry       Normal retry, try reading again
                    pshs      x,d                 Preserve regs
                    lbsr      sktrk0              Seek to track 0 (attempt to recalibrate)
                    puls      x,d                 Restore regs & try reading again


* Read With Retry: Do read with retries
*
* ENTER reg B,X=working lsn on disk
*          Y=path descriptor
*          U=driver data
*          A=retry sequence   mix of read & seek track 0
* EXIT     X,Y,U preserved; D,CC changed
*          B=error if any
*          CC=error flag
ReadWithRetry
                    pshs      x,d                 Preserve regs
                    bsr       ReadSector          Go read sector
                    puls      x,d                 Restore regs (A=retry flags)
                    lbcc      L01D7               No error, return
                    lsra                          Shift retry flags
                    bne       Retry               Still more retries allowed, go do them
* otherwise, final try before we give up
ReadSector
                    lbsr      L02AC               Do double-step/precomp etc. if needed, seek
                    lbcs      L01D7               Error somewhere, exit with it
L0176               ldx       >sectbuf,u          Get physical sector buffer ptr
                    ldb       #S$Read             Read sector command
                    ifne      SCII
* If SCII not hacked for 512 byte no-halt, must use halt for 512b sectors RG
                    ifeq      SCIIHACK
                    clra                          SCII normal mode, normal NMI
                    tst       flag512,u           SCII must use halt mode for 512 byte sectors
                    bne       L0176B
                    endc
                    lda       #7                  SCII read, buffered mode, masked NMI
                    bsr       L01A1B              send commands and wait
* New lines needed because the SCII has error other than OS-9 errors. RG
                    bcs       ngood
* This now becomes a subroutine call. RG
*        lbcs  L03AF          get the errors
                    lbsr      L03AF               get the errors
                    bcc       good
ngood               rts

good                pshs      y
                    ifne      H6309
                    ldw       #256                set counter
                    ldy       #RW.DAT             source of data
                    ifne      SCIIHACK
                    tst       flag512,u
                    beq       sc2rlp
                    ldw       #512                bump up counter to 512 byte sector
                    endc
* Don't use tfm if no halt important else need orcc #$50 for tfm
* If an interrupt occurs during a tfm transfer, the SCII counter
* will update but the tfm will repeat a byte and lose track.
* If orcc #$50 used, then key presses may be lost even with no-halt
* mode.
sc2rlp              lda       ,y                  read byte from SCII
                    sta       ,x+                 transfer byte to system buffer
                    decw                          update counter
                    bne       sc2rlp
                    else
                    ldy       #256
                    ifne      SCIIHACK
                    tst       flag512,u
                    beq       sc2rlp
                    ldy       #512
                    endc
sc2rlp              lda       >RW.DAT
                    sta       ,x+
                    leay      -1,y
                    bne       sc2rlp
                    endc
                    clrb                          no errors
                    puls      y,pc
                    endc

L0176B              bsr       L01A1               Send to controller & time delay to let it settle
*** Next few lines are commented out for blobstop patches
*L0180    bita  >DPort+WD_Stat check status register
*         bne   L0197          eat it & start reading sector
*         leay  -1,y           bump timeout timer down
*         bne   L0180          keep trying until it reaches 0 or sector read
*         lda   >ctlimg,u       get current drive settings
*         ora   #C_MOTOR       turn drive motor on
*         sta   >DPort+CtrlReg send to controller
*         puls  y,cc           restore regs
*         lbra  L03E0          exit with Read Error
*** Blobstop fixes
                    stb       >DPort+CtrlReg      send B to control register
                    nop       allow               HALT to take effect
                    nop
                    bra       L0197               and a bit more time
* Read loop - exited with NMI
* Entry: X=ptr to sector buffer
*        B=Control register settings
L0197               lda       >DPort+WD_Data      get byte from controller
                    sta       ,x+                 store into sector buffer
*         stb   >DPort+CtrlReg drive info
                    nop       --                  blobstop fix
                    bra       L0197               Keep reading until sector done

L01A1               orcc      #IntMasks           Shut off IRQ & FIRQ
* No-halt mode must enter here, skipping IRQ shutoff.
L01A1B              stb       >DPort+WD_Cmd       Send command
                    ifne      SCII
                    sta       >RW.Ctrl            tell SCII what to do
                    endc
L01A1C              ldb       #C_DBLDNS+C_MOTOR   Double density & motor on
                    orb       >ctlimg,u           Merge with current drive settings
                    stb       >DPort+CtrlReg      Send to control register
                    ifne      SCII
                    tst       flagform,u          Format uses halt mode
                    bne       s512
                    ifeq      SCIIHACK
                    tst       flag512,u           SCII uses halt with 512 byte sectors
                    beq       s256
                    else
                    bra       s256
                    endc
                    endc
s512                ldb       #C_HALT+C_DBLDNS+C_MOTOR Enable halt, double density & motor on
                    orb       >ctlimg,u           Merge that with current drive settings
                    lbra      FDCDelay            Time delay to wait for command to settle
                    ifne      SCII
s256                ldb       #4                  normal mode, NMI masked
                    lda       #255                time out slices
                    pshs      a,x
SC2tmr1             ldx       #1
                    lbsr      Delay               sleep or timer
                    dec       ,s                  count
                    beq       tmout
                    tst       >RW.Ctrl            check status
                    bmi       SC2tmr1             loop on not ready
                    stb       RW.Ctrl             clear SCII but don't generate NMI
                    clrb
                    puls      a,x,pc
tmout               stb       RW.Ctrl             clear SCII buffer counter
                    lda       #$D0                force interrupt
                    sta       DPort+WD_Cmd
                    comb                          set carry
                    puls      a,x,pc
                    endc

* Delay for some number of ticks (1 tick = 1/60 second).
* For a hard delay, we need to delay for 14833 cycles at .89MHz or
* 29666 cycles at 1.78MHz
* Entry: X = number of ticks to delay
Delay
                    pshs      d                   [5+] [4+]
                    ifgt      Level-1
                    ldd       <D.Proc             [6]  [5] process pointer
                    cmpd      <D.SysPrc           [is it the system?
                    beq       hardloop            [3]  [3]
                    os9       F$Sleep             if not system then sleep
                    puls      d,pc                [5+] [4+]
                    endc
hardloop            tfr       x,d                 we want X in A,B
l1@                 equ       *
                    ifeq      Level-1
                    ifne      H6309
                    ldx       #1854/2
                    else
                    ldx       #1482/2             [3]  [3]
                    endc
                    else
                    ifne      H6309
                    ldx       #1854               [3]  [3]
                    else
                    ldx       #1482               [3]  [3]
                    endc
                    endc
l2@                 nop       [2]                 [1]
                    nop       [2]                 [1]
                    nop       [2]                 [1]
                    leax      -1,x                [4+] [4+]
                    bne       l2@                 [3]  [3]
                    subd      #$0001              [4]  [3]
                    bne       l1@                 [3]  [3]
                    puls      d,pc                [5+] [4+]

* Write
* Entry:
*    B  = MSB of LSN
*    X  = LSB of LSN
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Write               tst       flagFMT,u
                    bne       w3                  if a format write normally and clear flags
                    tst       flagWP,u
                    beq       w2                  continue if not a mismatch
                    ldb       #E$BTyp
                    lbra      L03E0               report bad type if forced WP
w3                  clr       flagFMT,u
                    clr       flagWP,u
w2                  lbsr      Chk512              go adjust LSN for 512 byte sector if needed
* Next line was lda #%1001001 which was an error RG
                    lda       #%10010001          retry flags for I/O errors (see Disto SCII source)
L01C4               pshs      x,d                 preserve LSN, retries
                    bsr       L01E8               go write the sector
                    puls      x,d                 restore LSN, retries
                    bcs       L01D8               error writing, go to write retry handler
                    tst       <PD.VFY,y           no error, do we want physical verify?
                    bne       L01D6               no, exit without error
                    lbsr      verify              go re-read & verify 64 out of 256 bytes
                    bcs       L01D8               error on verify, go to write retry handler
L01D6               clrb                          no error & return
L01D7               rts

* Write error retry handler
L01D8               lsra                          Shift retry flags
                    lbeq      L03AF               Too many retries, exit with error
                    bcc       L01C4               Normal retry, attemp to re-write sector
                    pshs      x,d                 Preserve flags & sector #
                    lbsr      sktrk0              Seek to track 0 (attempt to recalibrate)
                    puls      x,d                 Restore flags & sector #
                    bra       L01C4               Try re-writing now

* 512 byte sector write here
L01E8               lbsr      L02AC               Go do double-step/write precomp if needed
                    bcs       L01D7               Error, exit with it
                    pshs      y,d                 Preserve path dsc. ptr & LSN
* Since I have modified chk512 the next two lines are replaced. RG
*         lda   <PD.TYP,y      Get device type
*         anda  #%00000100     512 byte sector?
                    tst       flag512,u           go if 256 byte sectors
                    beq       L020D               Not 512 then skip ahead
                    lbsr      L0176               Go read the sector in
                    ldd       >loglsn,u           Get OS9 LSN
                    andb      #$01                Even or odd?
                    beq       L020D               Even, skip ahead
                    ldx       >sectbuf,u          Get physical sector buffer ptr
                    leax      >$0100,x            Point to 2nd half
                    bra       L0211               Copy caller's buffer to 2nd half of sector

L020D               ldx       >sectbuf,u          Get physical sector buffer ptr

L0211               ldy       PD.BUF,y            Get path dsc. buffer ptr
                    ifne      H6309
                    ldw       #256                Copy write buffer to sector buffer
                    tfm       y+,x+
                    else
                    clrb
L0211Lp             lda       ,y+
                    sta       ,x+
                    decb
                    bne       L0211Lp
                    endc
                    puls      y,d                 Get path dsc. ptr & LSN back
                    ldx       >sectbuf,u          Get physical sector buffer ptr again
* See read routine for explanation of SCII code. RG
                    ifne      SCII
                    ifeq      SCIIHACK
                    clra                          SCII write, normal mode & NMI
                    tst       flag512,u
                    bne       wr512
                    endc
                    lda       #4                  SCII normal mode, masked NMI
                    sta       RW.Ctrl             tell SCII
                    pshs      y
                    ldy       #RW.Dat             Send data to SCII RAM buffer
                    ifne      H6309
                    ldw       #256
                    tst       flag512,u
                    beq       wrbuf
                    ldw       #512
wrbuf               lda       ,x+
                    sta       ,y
                    decw
                    bne       wrbuf
                    else
                    ldy       #256
                    tst       flag512,u
                    beq       wrbuf
                    ldy       #512
wrbuf               lda       ,x+
                    sta       >RW.DAT
                    leay      -1,y
                    bne       wrbuf
                    endc
                    puls      y
                    ldb       #$A0                Write sector command
                    lda       #6                  SCII masked NMI, buffered mode, write
* See Read section for explanation of error changes below. RG
*        lbra  L01A1B          send command to controller
                    lbsr      L01A1B              send command to controller
                    bcs       wngood              SCII error, then go
                    lbra      L03AF               check for OS-9 errors
wngood              rts
                    endc
wr512               ldb       #S$Format

* Format track comes here with B=$F0 (write track)
* as does write sector with B=$A0
*WrTrk    pshs  y,cc           Preserve path dsc. ptr & CC
WrTrk               lbsr      L01A1               Send command to controller (including delay)
*** Commented out for blobstop fixes
*L0229    bita  >DPort+WD_Stat Controller done yet?
*         bne   L0240          Yes, go write sector out
*         leay  -$01,y         No, bump wait counter
*         bne   L0229          Still more tries, continue
*         lda   >ctlimg,u       Get current drive control register settings
*         ora   #C_MOTOR       Drive motor on (but drive select off)
*         sta   >DPort+CtrlReg Send to controller
*         puls  y,cc           Restore regs
*         lbra  L03AF          Check for errors from status register

*** added blobstop
                    ifgt      Level-1
                    lda       FBlock+1,u          get the block number for format
                    beq       L0230               if not format, don't do anything
                    sta       >$FFA1              otherwise map the block in
* added delay for for MMU line settling. RG 2005/1/23
                    nop
                    nop
                    endc
L0230               stb       >DPort+CtrlReg      send data to control register
* These lines converted to separate sector writes from format. RG
* Removed slow down but left code just in case. RG
                    nop
                    nop
*         cmpb   #$F0           if format, then
*         beq   L0240b          go to special loop
                    bra       L0240               wait a bit for HALT to enable

* Write sector routine (Entry: B= drive/side select) (NMI will break out)
* Was part of timing change mentioned above.  Removed RG
L0240               nop       ---                 wait a bit more
                    lda       ,x+                 Get byte from write buffer
*L0240    lda   ,x+             Get byte from write buffer
                    sta       >DPort+WD_Data      Save to FDC's data register
* EAT 2 CYCLES: TC9 ONLY (TRY 1 CYCLE AND SEE HOW IT WORKS)
                    ifeq      TC9-1
                    nop
                    nop
*         ELSE
* See above. RG Now removed.
*         nop
                    endc
* No blob change.
*         stb   >DPort+CtrlReg Set up to read next byte
                    bra       L0240               Go read it
* Special loop for format slows CPU clock. RG Now removed.
*L0240b
*         IFGT  Level-1
*         sta   >$FFD8
*         ENDC
*L0240c   lda   ,x+
*         sta   >DPort+WD_Data
*         bra   L0240c
* NMI routine
NMISvc              leas      R$Size,s            Eat register stack
* Added to compensate above change in format loop. RG Now removed.
                    ifgt      Level-1
*         sta   >$FFD9
                    ldx       <D.SysDAT           get pointer to system DAT image
                    lda       3,x                 get block number 1
                    sta       >$FFA1              map it back into memory
                    endc
                    andcc     #^IntMasks          turn IRQ's on again
                    ldb       >DPort+WD_Stat      Get status register
                    ifne      SCII
                    clr       RW.Ctrl             Clear SCII command register
                    endc
                    bitb      #%00000100          Did we lose data in the transfer?
                    lbeq      L03B2               Otherwise, check for drive errors
                    comb                          -- blobstop error code
                    ldb       #E$DevBsy           -- device busy
                    rts                           -- and exit

verify              pshs      x,d
* Removed unneeded code. Data never sent to PD.BUF anyway so there is
* no need to redirect the PD.BUF pointer. RG
*        ldx   PD.BUF,y       Get write buffer ptr
*        pshs  x              Preserve it
*        ldx   >sectbuf,u     Get sector buffer ptr
*        stx   PD.BUF,y       Save as write buffer ptr
*        ldx   4,s
                    lbsr      ReadSector          Go read sector we just wrote
*        puls  x              Get original write buffer ptr
*        stx   PD.BUF,y       Restore path dsc. version
                    bcs       L02A3               If error reading, exit with it
                    ldx       PD.BUF,y            Get system buffer ptr
                    pshs      u,y                 Preserve device mem, path dsc. ptrs
* See change in chk512 routine. RG
*        ldb   <PD.TYP,y      Get type from path dsc.
                    ldy       >sectbuf,u          Get sector buffer ptr
*        andb  #%00000100     512 byte sector?
                    tst       flag512,u           512 byte sector?
                    beq       L028D               No, skip ahead
                    ldd       >loglsn,u           Get OS9's sector #
                    andb      #$01                Odd/even sector?
                    beq       L028D               Even; compare first half
                    leay      >$0100,y            Odd, compare second half
L028D               tfr       x,u                 Move PD.BUF ptr to U (since cmpx is faster)
                    clra                          check all 256 bytes
L028F               ldx       ,u++                Get 2 bytes from original write buffer
                    cmpx      ,y++                Same as corresponding bytes in re-read sector?
                    bne       vfybad              No, error & return
                    inca
                    bpl       L028F               No, continue
                    bra       L02A1               carry is clear by virtue of last cmpx
vfybad              comb                          set carry
L02A1               puls      u,y
L02A3               puls      pc,x,d

L02A5               pshs      a                   Save Caller's track #
                    ldb       <V.TRAK,x           Get track # drive is currently on
                    bra       L02E9               Go save it to controller & continue

L02AC               lbsr      L0376               Go set up controller for drive, spin motor up
                    bsr       L032B               Get track/sector # (A=Trk, B=Sector)
                    pshs      a                   Save track #
                    lda       >currside,u         Get side 1/2 flag
                    beq       L02C4               Side 1, skip ahead
                    lda       >ctlimg,u           Get control register settings
                    ora       #C_SIDSEL           Set side 2 (drive 3) select
                    sta       >ctlimg,u           Save it back
L02C4               lda       <PD.TYP,y           Get drive type settings
                    bita      #%00000010          ??? (Base 0/1 for sector #?)
                    bne       L02CC               Skip ahead
                    incb                          Bump sector # up by 1
*!!!!!!!!!!!!!!!!!!!!!critical section on double-stepping
L02CC               stb       >DPort+WD_Sect      Save into Sector register
                    ldx       >lastdrv,u          Get last drive table accessed
                    ldb       <V.TRAK,x           Get current track # on device
                    lda       <PD.TYP,y           Get drive type
                    bita      #1                  3.5" drive
                    beq       L02CCb              go if not 3.5" RG
                    lda       ,s                  recover track #
                    clr       flagWP,u
                    bra       L02E9
L02CCb              lda       <DD.FMT,x           Get drive format specs; actually disk format specs RG
                    lsra                          Shift track & bit densities to match PD; bit0 is MF or MFM
                    eora      <PD.DNS,y           Check for differences with path densities; bit0 is MF MFM, bit1 is 96tpi
                    anda      #%00000010          Keep only 96 tpi
                    pshs      a                   Save differences
                    lda       1,s                 Get track # back
                    tst       ,s+                 Are tpi's different?
                    beq       L02E9               No, continue normally
                    lsla                          Yes, multiply track # by 2 ('double-step')
                    lslb                          Multiply current track # by 2 ('double-step')
                    clr       flagWP,u
                    inc       flagWP,u            if double-step then prevent future writes
L02E9               stb       >DPort+WD_Trak      Save current track # onto controller

* From here to the line before L0307 is for write precomp, but is not used.
* Unless write precomp is needed, all of this is useless
* I think most (if not all) drives do NOT need precomp
                    ifeq      PRECOMP-1
                    ldb       #21                 Pre-comp track #
                    pshs      b                   Save it
                    ldb       <PD.DNS,y           Get current density settings
                    andb      #%00000010          Just want to check track density
                    beq       L02F9               48 tpi, skip ahead
                    lsl       ,s                  Multiply pre-comp value by 2 ('double-step')
L02F9               cmpa      ,s+                 Is track # high enough to warrant precomp?
                    bls       L0307               No, continue normally
                    ldb       >ctlimg,u
                    orb       #C_WPRCMP           Turn on Write precomp
                    stb       >ctlimg,u
                    endc

L0307               tst       >u00AA,u            ??? Get flag (same drive flag?)
                    bne       L0314               no, skip ahead
                    ldb       ,s                  get track #
                    cmpb      <V.TRAK,x           same as current track on this drive?
                    beq       L0321               yes, skip ahead
L0314               sta       >DPort+WD_Data      save track # to data register
                    ldb       <PD.STP,y           get stepping rate
                    andb      #%00000011          just keep usable settings (6-30 ms)
                    eorb      #%00011011          set proper bits for controller
                    lbsr      L03E4               send command to controller & time delay
L0321               puls      a                   get track # back
                    sta       <V.TRAK,x           save as current track #
                    sta       >DPort+WD_Trak      save to controller
                    clrb                          no error & return
                    rts

* Entry: B:X LSN
* Exit:  A=Track #
*        B=Sector #
*   <currside=00 = Head 1 , $FF = Head 2
L032B               tstb                          Sector # > 65535?
                    bne       L033F               Yes, illegal for floppy
                    tfr       x,d                 Move sector # to D
                    leax      ,x                  LSN 0? ie. "tstx"
                    beq       L0371               Yes, exit this routine
                    ldx       >lastdrv,u          Get previous drive table ptr
                    cmpd      DD.TOT+1,x          Within range of drive spec?
                    blo       L0343               Yes, go calculate track/sector #'s
L033F               comb                          Exit with Bad sector # error
                    ldb       #E$Sect
                    rts

* Calculate track/sector #'s?
* These two sections could be combined into one with a final
* test of DD.FMT. Then currside can be set and regA can be lsra
* as needed. RG
L0343               stb       >u00AE,u            Save LSB of LSN
                    clr       ,-s                 Clear track # on stack
                    ldb       <DD.FMT,x           Get drive format
                    lsrb                          Shift out # sides into carry
                    ldb       >u00AE,u            Get LSB of LSN again
                    bcc       L0367               Single sided drive, skip ahead
                    bra       L035D               Double sided drive, skip ahead
* Double sided drive handling here
L0355               com       >currside,u         Odd/even sector track flag
                    bne       L035D               Odd, so don't bump track # up
                    inc       ,s                  Bump up track #

* Changed this to more effient code. RG
*L035D    subb  DD.TKS,x       Subtract # sectors/track
*        sbca  #$00
L035D               subd      DD.SPT,x
                    bcc       L0355               Still more sectors left, continue
                    bra       L036D               Wrapped, skip ahead
* Single sided drive handling here
L0365               inc       ,s                  Bump track # up

* See above. RG
*L0367    subb  DD.TKS,x       Subtract # sectors/track
*        sbca  #$00
L0367               subd      DD.SPT,x
                    bcc       L0365               Still more, go bump the track up
* Next possible because upper limit is 256 sectors/track. RG
L036D               addb      DD.TKS,x            Bump sector # back up from negative value
                    puls      a                   Get the track #
L0371               rts                           A=track #, B=Sector #, <currside=Odd

* Drive control register bit mask table
* May want an option here for double sided SDDD disks ex. RG
*        fcb   $1      drive0
*        fcb   $2      drive1
*        fcb   $41     drive2
*        fcb   $42     drive3
*        fcb   $4      drive4
*        fcb   $44     drive5

L0372               fcb       $01                 Drive 0
                    fcb       $02                 Drive 1
                    fcb       $04                 Drive 2
                    fcb       $40                 Drive 3 / Side select

* Changes regD; X,Y,U preserved
L0376               clr       >u00AA,u            clear drive change flag
chkdrv              lda       <PD.DRV,y           Get drive # requested
* It is possible to have more than 4 drive # so the change below. RG
*        cmpa  #4             Drive 0-3?
                    cmpa      #N.Drives           Drive 0-6 if alternate table used?
                    blo       L0385               Yes, continue normally
NoHW                comb                          Illegal drive # error
                    ldb       #E$Unit
                    rts

* Entry: A=drive #, X=LSN (Physical, not OS9 logical if PCDOS disk)
L0385               pshs      x,d                 Save sector #, drive # & B???
                    leax      >L0372,pc           Point to drive bit mask table
                    ldb       a,x                 Get bit mask for drive # we want
                    stb       >ctlimg,u           Save mask
                    leax      DRVBEG,u            Point to beginning of drive tables
                    ldb       #DRVMEM             Get size of each drive table
                    mul                           Calculate offset to drive table we want
                    leax      d,x                 Point to it
                    cmpx      >lastdrv,u          Same as Last drive table accessed?
                    beq       L03A6               Yes, skip ahead
                    stx       >lastdrv,u          Save new drive table ptr
                    com       >u00AA,u            Set drive change flag
L03A6               clr       >currside,u         Set side (head) flag to side 1
                    lbsr      L04B3               Go set up VIRQ to wait for drive motor
                    puls      pc,x,d              Restore sector #,drive #,B & return

L03AF               ldb       >DPort+WD_Stat      Get status register from FDC
* This line needed when returning to Disk Basic but probably
* not needed for OS-9. RG
                    ifne      SCII
                    clr       RW.Ctrl             return SCII to halt mode
                    endc
L03B2               bitb      #%11111000          any of the error bits set?
                    beq       L03CA               No, exit without error
                    aslb                          Drive not ready?
                    bcs       L03CC               Yes, use that error code
                    aslb                          Write protect error?
                    bcs       L03D0               Yes, use that error code
                    aslb                          Write fault error?
                    bcs       L03D4               Yes, use that error code
                    aslb                          Sector not found?
                    bcs       L03D8               Yes, use Seek error code
                    aslb                          CRC error?
                    bcs       L03DC               Yes, use that error code
L03CA               clrb                          No error & return
                    rts

L03CC               ldb       #E$NotRdy           not ready
                    fcb       $8C                 skip 2 bytes

L03D0               ldb       #E$WP               write protect
                    fcb       $8C                 skip 2 bytes

L03D4               ldb       #E$Write            write error
                    fcb       $8C

L03D8               ldb       #E$Seek             seek error
                    fcb       $8C

L03DC               ldb       #E$CRC              CRC error
*         fcb   $8C

*L03E0    ldb   #E$Read        Read error
L03E0               orcc      #Carry              set carry
                    rts

L03E4               bsr       L0404               Send command to controller & waste some time
L03E6               ldb       >DPort+WD_Stat      Check FDC status register
                    bitb      #$01                Is controller still busy?
                    beq       L0403               No, exit
                    ldd       >VIRQCnt,pc         Get initial count value for drive motor speed
                    std       >VIRQPak,u          Save it
* Again, I'm trying to match Kevin Darling code. It may not be needed. RG
                    pshs      x
                    ldx       #1                  Sleep remainder of slice
                    lbsr      Delay
                    puls      x
                    bra       L03E6               Wait for controller to finish previous command

* Send command to FDC
L03F7               lda       #C_MOTOR
*        lda   #%00001000     Mask in Drive motor on bit
                    ora       >ctlimg,u           Merge in drive/side selects
                    sta       >DPort+CtrlReg      Turn the drive motor on & select drive
                    stb       >DPort+WD_Cmd       Save command & return
L0403               rts

L0404               bsr       L03F7               Go send command to controller

* This loop has been changed from nested LBSRs to timing loop.
* People with crystal upgrades should modify the loop counter
* to get a 58+ us delay time.  MINIMUM 58us.
FDCDelay
                    pshs      a                   14 cycles, plus 3*loop counter
                    ifeq      Level-1
                    lda       #18                 (only do about a 100 cycle delay for now)
                    else
                    lda       #29                 (only do about a 100 cycle delay for now)
                    endc
L0409               deca                          for total ~63 us delay (123 cycles max.)
                    bne       L0409
                    puls      a,pc                restore register and exit

* SetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
SetStat             ldx       PD.RGS,y            Get caller's register stack ptr
                    ldb       R$B,x               Get function code
                    cmpb      #SS.WTrk            Write track?
                    beq       SSWTrk              Yes, go do it
                    cmpb      #SS.Reset           Restore head to track 0?
                    lbeq      sktrk0              Yes, go do it --- beq
                    comb                          set carry for error
                    ldb       #E$UnkSvc           return illegal service request error
                    rts

SSWTrk              stb       flagFMT,u           permit unconditional write on format
                    clr       flagWP,u            don't protect on a format
                    pshs      u,y                 preserve register stack & descriptor

* Level 2 Code
                    ifgt      Level-1

*--- new code
                    ldb       #1                  1 block to allocate
                    os9       F$AllRAM            allocate some RAM
                    lbcs      L0489               error out if at all
                    leax      >FBlock,u           point to 'my' DAT image
                    std       ,x                  save a copy of the block
                    os9       F$ResTsk            reserve a task number for the copy
                    bcs       FError              error out
                    stb       2,x                 save temporary task number in FTask,u
                    lslb                          2 bytes per entry
                    ldu       <D.TskIPt           get task image table pointer
                    stx       b,u                 save pointer to the task's DAT image
                    lsrb                          get the right number again
                    ifne      H6309
                    tfr       0,u                 destination is address 0
                    else
                    ldu       #$0000
                    endc
*--- end new code

                    ldx       2,s                 get pointer to descriptor
*         stu   >FBlock,x
                    ldx       <D.Proc             Get current process ptr
                    lda       P$Task,x            Get task # for current process
*         ldb   <D.SysTsk      Get system task #
                    ldy       ,s
                    ldx       PD.RGS,y            Get register stack ptr
                    ldx       R$X,x               Get ptr to caller's track buffer
                    ldy       #$1A00              Size of track buffer
                    os9       F$Move              Copy from caller to temporary task
                    bcs       L0479               Error copying, exit
                    puls      u,y
                    pshs      u,y

                    endc
* End of Level 2 Code

                    lbsr      L0376               Go check drive #/wait for it to spin up
                    ldx       PD.RGS,y            Get caller's register stack ptr
                    ldb       R$Y+1,x             Get caller's side/density
                    bitb      #$01                Check side
                    beq       L0465               Side 1, skip ahead
* I think this next line is not needed. RG
                    com       >currside,u         * Why? This is normally used with
*                               calculate track. RG
                    ldb       >ctlimg,u           Get current control register settings
*         orb   #%01000000     Mask in side 2
                    orb       #C_SIDSEL           Mask in side 2
                    stb       >ctlimg,u           Save updated control register
L0465               lda       R$U+1,x             Get caller's track #
                    ldx       >lastdrv,u          Get current drive table ptr
                    lbsr      L02A5
                    bcs       L0489
                    ldb       #$F0                Write track command
*---
                    ifeq      Level-1
                    ldx       PD.RGS,y
                    ldx       R$X,x
                    else
                    ldx       #$2000              start writing from block 1
                    endc

                    ifne      SCII
                    lda       #1                  normal unbuffered write
* Next line prevents WrTrk from switching to SCII buffered mode. RG
                    sta       flagform,u
                    endc
                    lbsr      WrTrk               Go write the track
                    ifne      SCII
                    clr       flagform,u          permit no-halt mode RG
                    endc

                    ifgt      Level-1
L0479               ldu       2,s
                    pshs      b,cc                Preserve error
                    ldb       >FTask,u            point to task
                    os9       F$RelTsk            release the task
                    fcb       $8C                 skip 2 bytes

* format comes here when block allocation passes, but task allocation
* gives error.  So er de-allocate the block.
FError
                    pshs      b,cc                save error code, cc
                    ldx       >FBlock,u           point to block
                    ldb       #1                  1 block to return
                    os9       F$DelRAM            de-allocate image RAM blocks
                    clr       FBlock+1,u          ensure that the block # in FBlock is zero.
                    puls      b,cc                Restore error
                    endc

L0489               puls      pc,u,y              Restore regs & return

* seek the head to track 0
sktrk0              lbsr      chkdrv
                    ldx       >lastdrv,u
                    clr       <V.TRAK,x
                    lda       #1                  was 5 but that causes head banging
L0497               ldb       <PD.STP,y
                    andb      #%00000011          Just keep usable settings (6-30 ms)
                    eorb      #%01001011          Set proper bits for controller
                    pshs      a
                    lbsr      L03E4
                    puls      a
                    deca
                    bne       L0497
                    ldb       <PD.STP,y
                    andb      #%00000011          Just keep usable settings (6-30 ms)
                    eorb      #%00001011          Set proper bits for controller
                    lbra      L03E4

L04B3               pshs      y,x,d               Preserve regs
                    ldd       >VIRQCnt,pc         Get VIRQ initial count value
                    std       >VIRQPak,u          Save it
                    lda       >ctlimg,u           ?Get drive?
                    ora       #C_MOTOR            Turn drive motor on for that drive
*         ora   #%00001000     Turn drive motor on for that drive
                    sta       >DPort+CtrlReg      Send drive motor on command to FDC
                    ifeq      Level-1
                    lda       >D.DskTmr           Get VIRQ flag
                    else
                    lda       <D.MotOn            Get VIRQ flag
                    endc
                    bmi       L04DE               Not installed yet, try installing it
                    bne       L04E0               Drive already up to speed, exit without error

* Drive motor speed timing loop (could be F$Sleep call now) (was over .5 sec)
* 32 was not sufficient for one of my drives. RG
                    ldx       #50                 wait for 32 ticks; increased it RG
                    lbsr      Delay

L04DE               bsr       InsVIRQ             Install VIRQ to wait for drive motors
L04E0               clrb                          No error & return
                    puls      pc,y,x,d

InsVIRQ             lda       #$01                Flag drive motor is up to speed
                    ifeq      Level-1
                    sta       >D.DskTmr
                    else
                    sta       <D.MotOn
                    endc
                    ldx       #$0001              Install VIRQ entry
                    leay      >VIRQPak,u          Point to packet
                    clr       Vi.Stat,y           Reset Status byte
                    ldd       >VIRQCnt,pc         Get initial VIRQ count value
                    os9       F$VIRQ              Install VIRQ
                    bcc       VIRQOut             No error, exit
                    lda       #$80                Flag that VIRQ wasn't installed
                    ifeq      Level-1
                    sta       >D.DskTmr
                    else
                    sta       <D.MotOn
                    endc
VIRQOut             clra
                    rts

* IRQ service routine for VIRQ (drive motor time)
* Entry: U=Ptr to VIRQ memory area
IRQSvc              pshs      a
                    lda       <D.DMAReq
                    beq       L0509
                    bsr       InsVIRQ
                    bra       IRQOut
L0509               sta       >DPort+CtrlReg
* I changed this to a clear. Don't see the point of an AND. RG
*        IFNE  H6309
*        aim   #$FE,>u00B5,u
*        ELSE
*        lda   u00B5,u
*        anda  #$FE
*        sta   u00B5,u
*        ENDC
*         fdb   u00B5      --- so changes in data size won't affect anything
                    clr       u00B5,u
                    ifeq      Level-1
                    clr       >D.DskTmr
                    else
                    clr       <D.MotOn
                    endc
IRQOut              puls      pc,a

* Non-OS9 formatted floppies need a drive table entry constructed
* by hand since there is no RBF LSN0.
*
* Entry: X=LSN
*        Y=Path dsc. ptr
*        U=Device mem ptr
MakeDTEntry
                    pshs      x                   Preserve Logical sector #
                    ldx       >lastdrv,u          Get last drive table accessed ptr
                    clra
                    pshs      x,a                 Save ptr & NUL byte
                    ifne      H6309
                    ldw       #20                 Clear 20 bytes
                    tfm       s,x+
                    else
                    ldb       #20
L051ALp             clr       ,x+
                    decb
                    bne       L051ALp
                    endc
                    puls      x,a                 Eat NUL & get back drive table ptr
                    ldb       <PD.CYL+1,y         Get # cylinders on drive (ignores high byte)
                    lda       <PD.SID,y           Get # sides
                    mul                           Calculate # tracks on drive (1 per head)
                    ifne      H6309
                    decd      Adjust              to ignore track 0
                    else
                    subd      #$0001
                    endc
                    lda       <PD.SCT+1,y         Get # sectors/track
                    sta       DD.TKS,x            Save in drive table
                    sta       <DD.SPT+1,x         Save in other copy in drive table
                    mul                           Calculate # sectors on drive (minus track 0)
                    pshs      x                   Preserve drive table ptr
                    tfr       d,x                 Move # sectors on drive to X
                    lda       <PD.T0S+1,y         Get # sectors on track 0
                    leax      a,x                 Add that many sectors to total
                    lda       <PD.TYP,y           Get device type settings
                    anda      #%00000100          Mask out all but 512 byte sector flag
                    beq       L0550               Not 512 byte sector, skip ahead
                    ifne      H6309
                    addr      x,x                 Multiply by 2 (convert to 256 byte OS9 sectors)
                    else
                    tfr       x,d
                    leax      d,x
                    endc
L0550               tfr       x,d                 Move # sectors to D
                    puls      x                   Get back drive table ptr
                    std       DD.TOT+1,x          Save # sectors allowed on drive
                    lda       #UPDAT.+EXEC.       Owner's read/write/exec attributes
                    sta       DD.ATT,x            Set attributes for disk
                    lda       <PD.DNS,y           Get density settings   this should be bit1 96tpi bit0 MF MFM normally is 1
                    lsla                          Shift for DD.FMT
                    pshs      a                   Preserve it a sec
                    lda       <PD.SID,y           Get # sides
                    deca                          Adjust to base 0
                    ora       ,s+                 Merge with density settings
                    sta       <DD.FMT,x           Save in device table; normally becomes %11 or 3
                    clrb                          No error?
                    puls      pc,x                Restore original LSN & return

                    emod
eom                 equ       *
                    end

