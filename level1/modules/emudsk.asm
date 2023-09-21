********************************************************************
* Emudsk - Virtual disk driver for CoCo emulators
*
* $Id$
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*  01    Modified to compile under OS9Source            tjl 02/08/28
*  02    Modified to handle two .vhd drives        R. Gault 11/12/23
*        Conforms to MESS v1.44 or more recent
*        Added and enhanced some comments
*        Note the forced > extended addressing in some cases.
*        That is required as this code is relocatable but the
*        addresses are fixed. Part of original code.
*  03    Corrected minor errors in GetSect.        R. Gault 11/12/26
*  04    Corrected more logic errors.              R. Gault 11/12/29
*                                                & R. Gault 12/02/24
*  05    Correct frame errors                      EJJaquay 20/12/29
*        small optimization to branch table        LCB      20/12/29
*  06    Clear drive select in INIT. Rearrange
*        getsect slightly to reduce use of stack.  EJJaquay 21/01/05
*
* EmuDisk floppy disk controller driver
* Edition #1
* 04/18/96 : Written from scratch by Alan DeKok
*                                 aland@sandelman.ocunix.on.ca
*
*  This program is Copyright (C) 1996 by Alan DeKok,
*                  All Rights Reserved.
*  License is given to individuals for personal use only.
*
*  Comments: Ensure that device descriptors mark it as a hard drive
*
*   $FF80-$FF82: logical record number
LSN      equ  $FF80           where to put the logical sector number

*
*   $FF83: command/status register.
*          Output: 0=read, 1=write, 2=close.
*          Input: 0=no error, non-zero=error codes (see below).
command  equ  $FF83           where to put the commands

*
*   $FF84-$FF85: 6809's 16-bit buffer address (cannot cross an 8K boundary due
*          to interference from the MMU emulation).
buffer   equ  $FF84           pointer to the buffer

*   $FF86: controls .vhd drive 0=drive1 1=drive2
vhdnum   equ  $FF86

* Returns:
*
* 0=successful
* 2=not enabled
* 4=too many MS-DOS files open,
* 5=access denied (virtual HD file locked by another program
*      or MS-DOS read-only status)
* 6/12=internal error
* 254=invalid command byte
* 255=power-on state or closed.
*
* The "close" command just flushes all the read/write buffers and
* restores the metacontroller to its power-up state.  The hard drive must be
* enabled by the user using the MS-DOS command "ECHO >COCO3.VHD" (another
* crash safeguard), so error code 2 indicates this has not been done.

         nam   EmuDsk
         ttl   os9 device driver

         ifp1
         use   os9.d
         use   rbf.d
         endc

tylg     set   Drivr+Objct
atrv     set   ReEnt+rev
rev      set   $02

         mod   eom,name,tylg,atrv,start,size

         org   0
         rmb   DRVBEG+(DRVMEM*2) Normal RBF device mem for 2 drives RG
prevdr   rmb   1                 previously used drive RG
         rmb   255-.             residual page RAM for stack etc. RG
size     equ   .

         fcb   $FF               This byte is the driver permissions
name     fcs   /EmuDsk/
         fcb   6

**************************************************************************
* Init
*
* Entry: Y=Ptr to device descriptor
*        U=Ptr to device mem
*        V.PAGE and V.PORT 24 bit device address
*
* Exit:  CC carry set on error
*        B  error code if any
*
* Actions:
*
*   Set V.NDRV to number of drives supported (2)
*   Set DD.TOT to something non-zero
*   Set V.TRACK to $FF
*   Initialize device control registers?
*
* Default to only one drive supported, there's really no need for more.
* Since MESS now offers second vhd drive, EmuDsk will support it. RG
**************************************************************************

INIT     ldd   #$FF02        'Invalid' value & # of drives
         stb   V.NDRV,u      Tell RBF how many drives
         leax  DRVBEG,u      Point to start of drive tables
init2    sta   DD.TOT+2,x    Set media size to bogus value $FF0000
         sta   V.TRAK,x      Init current track # to bogus value
         leax  DRVMEM,x      Move to second drive memory. RG
         decb
         bne   init2
         stb   prevdr,u      preset previous drive to 1st vhd
         stb   >vhdnum       let emulator know EJJ 05jan21

**************************************************************************
* Term
*
* for now, TERM routine goes here.  Perhaps it should be pointing to the
* park routine? ... probably not.
**************************************************************************
TERM

**************************************************************************
* GetSta
*
* Entry: Y   = path dsc. ptr
*        U   = Device mem ptr
*
* Exit:  CC carry set on error
*        B  error code if any
*
**************************************************************************
GETSTA   clrb                 no GetStt calls - return, no error, ignore
         rts                  return to caller

**************************************************************************
* Module Jump table here to minimize long branches LCB
**************************************************************************

start    bra    INIT          3 bytes per entry to keep RBF happy
         nop
         bra    READ
         nop
         bra    WRITE
         nop
         bra    GETSTA
         nop
         lbra   SETSTA
         bra    TERM
         nop

**************************************************************************
* Read
*
* Entry: B:X = LSN
*        Y   = path dsc. ptr
*        U   = Device mem ptr
*
* Exit:  CC carry set on error
*        B  error code if any
*
* Actions:
*  Load A with read command and call GetSect
*  If error return it in reg B
*  if LSN is not zero use GETSTA to return
*  If LSN is zero copy first DD.SIZ bytes of sector to drive table
*
**************************************************************************
READ     clra                 READ command value=0
         bsr   GetSect        Get the sector
         bne   reterr         error return if not zero
         tstb                 test msb of LSN
         bne   noerr          if not sector 0, return
         leax  ,x             sets CC.Z bit if lsw of LSN not $0000
         bne   noerr          if not sector zero, return
* Copy LSN0 data to the drive table each time LSN0 is read
         ldx   PD.BUF,y       get ptr to sector buffer
         leau  DRVBEG,u       point to first drive table
         lda   PD.DRV,y       get vhd drive number from descriptor RG
         beq   copy.0         go if first vhd drive
         leau  DRVMEM,u       point to second drive table
       IFNE  H6309
copy.0   ldw   #DD.SIZ        # bytes to copy over
         tfm   x+,u+
       ELSE
copy.0   ldb   #DD.SIZ        # bytes to copy over
copy.1   lda   ,x+            grab from LSN0
         sta   ,u+            save into device static storage
         decb
         bne   copy.1
       ENDC
noerr    clrb
         rts

**************************************************************************
* Write
*
* Entry: B:X = LSN
*        Y   = path dsc. ptr
*        U   = Device mem ptr
*
* Exit:  CC carry set on error
*        B  error code if any
*
* Actions:
*  Load reg A with write command and call get sect
*  Return with error if any in reg B
**************************************************************************

WRITE    lda   #$01           WRITE command = 1
         bsr   GetSect
         bne   reterr
         clrb
         rts

reterr   tfr    a,b           Move error code to reg B
         coma                 Set the carry flag
         rts

**************************************************************************
* GetSect
*
* Entry: A = read/write command code (0/1)
*        B,X = LSN to read/write
*        Y = path dsc. ptr
*        U = Device static storage ptr
*
* Exit:  A = Error code, zero if none (also sets CC)
*        B,X,Y,U are preserved
*
* Note: Returns from READ or WRITE on errors to preserve stack frame - EJJ
*
* Actions:
*  Put buffer address from PD.BUF
*  Put drive from PD.DRV
*  Put LSN from B,X
*  Put command to cause emulator to do syncronous DMA transfer
*  Translate and return error code
**************************************************************************

GetSect  pshs  x,a            Save regs x and a
         lda   PD.DRV,y       Get drive number requested
         cmpa  #2             Only two drives allowed. RG
         bhs   DriveErr       Too many?
         cmpa  prevdr,u       did the drive change? RG
         beq   gs.1           no, then don't reset the drive
         sta   >vhdnum        set to new vhd# RG
         sta   prevdr,u       update RG
gs.1     stb   >LSN           Tell emulator which LSN
         stx   >LSN+1
         ldx   PD.BUF,y       Where the 256-byte LSN should go

* Note: OS-9 allocates buffers from system memory on page boundaries, so
* the low byte of X should now be $00, ensuring that the sector is not
* falling over an 8K MMU block boundary.
* This should be the job of RBF not EmuDsk! RG

         stx   >buffer        set up the buffer address
         puls  x,a            restore regs
         sta   >command       get the emulator to blast over the sector
         lda   >command       get the error status
         bne   FixErr         if non-zero translate the error and return
         rts                  return with LSN intact and no error

* Translate emulator error code to OS-9 code and return to caller.

DriveErr puls  x,a            restore regs
         bra   NotRdy         not ready

* Entry: A=error code from emulator
FixErr   cmpa  #02            not enabled
         beq   NotRdy
         cmpa  #255           power on state or closed
         beq   NotRdy
         cmpa  #5             access denied or DOS read-only
         beq   WP
         cmpa  #6             internal error
         beq   CRC
         cmpa  #12            internal error
         beq   CRC

* if it's something we don't recognize, it's a seek error
Seek     lda   #E$Seek        seek error
         rts

NotRdy   lda   #E$NotRdy      not ready
         rts

WP       lda   #E$WP          write protect
         rts

CRC      lda   #E$CRC         CRC error
         rts

*L03D4    lda   #E$Write       write error
*         rts

*L03E0    lda   #E$Read        Read error
*         rts

**************************************************************************
* SetSta
*
* Entry: Y   = path dsc. ptr
*        U   = Device mem ptr
*
* Exit:  CC carry set on error
*        B  error code if any
*
* Actions:
*   Get function code from stack PD.RGS,Y
*   Get drive number from stack PD.DRV,Y
*   issue park command if requested
*   ignore other requests
*
**************************************************************************

SETSTA   ldx   PD.RGS,y       Get caller's register stack ptr
         ldb   R$B,x          Get function code
         cmpb  #SS.WTrk       Write track?
         beq   format         Yes, ignore it
         cmpb  #SS.Reset      Restore head to track 0?
         beq   format         Yes, ignore it
         cmpb  #SS.SQD        sequence down the drive (i.e. park it)?
         beq   park
         comb                 set carry for error
         ldb   #E$UnkSvc      return illegal service request error
         rts

* This next is pointless for a virtual drive but probably does not hurt.
* Emulators do not require this if hard drives are swapped in mid-stream. In
* real hardware, this is important as would be closing all open files. RG

park     lda   PD.DRV,y       get drive number RG
         cmpa  #2             test for illegal value RG
         bhs   format         ignore if illegal RG
         sta   >vhdnum        tell which drive to halt RG
         ldb   #$02           close the drive
         stb   >command       save in command register
         clr   >vhdnum        Reset drive to H0 RG
         clr   prevdr,u       Clear prevdr to match vhdnum EJJ
format   clrb                 ignore physical formats.  They're not
         rts                  necessary

         emod
eom      equ   *

