********************************************************************
* Boot - WD1773 Boot module
* Provides HWInit, HWTerm, HWRead which are called by code in
* "use"d boot_common.asm
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   4      1985/??/??
* Original Tandy distribution version.
*
*   6      1998/10/12  Boisy G. Pitre
* Obtained from L2 Upgrade archive, has 6ms step rate and disk timeout
* changes.
*
*   6r2    2003/05/18  Boisy G. Pitre
* Added '.' output for each sector for OS-9 L2 and NitrOS9 for
* Mark Marlette (a special request :).
*
*   6r3    2003/08/31  Robert Gault
* Put BLOB-stop code in place, changed orb #$30 to orb #$28
*
*   6r4    2004/02/17  Rodney Hamilton
* Minor optimizations, improvements in source comments
*
*   7      2005/10/10  Boisy G. Pitre
* Added fragmented bootfile support
*
*   7      2005/10/13  Robert Gault
* Changed timing loops for H6309L2 so that code shortened enough to
* fit within the $1D0 boundary.
*
*   8      2006/03/03  Boisy G. Pitre
* Drive motors now turned off before returning to kernel.
*
*   9      2006/05/05  Boisy G. Pitre
* Fixed bug where single sided booting was broken
*
*          2006/06/04  Boisy G. Pitre
* Removed hard-coded value of #18 when adding back sectors per track and replaced
* with the appropriate value: ddtks,u

                    nam       Boot
                    ttl       WD1773 Boot module

                    ifp1
                    use       defsfile
                    endc

* FDC Control Register bits at $FF40
HALTENA             equ       %10000000
SIDESEL             equ       %01000000           DRVSEL3 if no DS drives
DDEN                equ       %00100000
READY               equ       %00010000           READY for Tandy WD1773-based controllers
MOTON               equ       %00001000
DRVSEL2             equ       %00000100
DRVSEL1             equ       %00000010
DRVSEL0             equ       %00000001

* Default Boot is from drive 0
BootDr              set       DRVSEL0
                    ifeq      DNum-1
BootDr              set       DRVSEL1             Alternate boot from drive 1
                    endc
                    ifeq      DNum-2
BootDr              set       DRVSEL2             Alternate boot from drive 2
                    endc
                    ifeq      DNum-3
BootDr              set       SIDESEL             Alternate boot from drive 3
                    endc

* WD17x3 DPort offsets
CONTROL             equ       0
CMDREG              equ       8+0                 write-only
STATREG             equ       CMDREG              read-only
TRACKREG            equ       8+1
SECTREG             equ       8+2
DATAREG             equ       8+3

* Sector Size
SECTSIZE            equ       256

* Step Rates:
*       $00  = 6ms
*       $01  = 12ms
*       $02  = 20ms
*       $03  = 30ms
                    ifndef    STEP
STEP                set       $00
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       9

                    mod       eom,name,tylg,atrv,start,size

* NOTE: these are U-stack offsets, not DP
seglist             rmb       2                   pointer to segment list
blockloc            rmb       2                   pointer to memory requested
blockimg            rmb       2                   duplicate of the above
bootsize            rmb       2                   size in bytes
LSN0Ptr             rmb       2                   In memory LSN0 pointer
drvsel              rmb       1
currtrak            rmb       1
* Note, for optimization purposes, the following two variables
* should be adjacent!!
ddtks               rmb       1                   no. of sectors per track
ddfmt               rmb       1
side                rmb       1                   side 2 flag
size                equ       .

name                fcs       /Boot/
                    fcb       edition

* Common booter-required defines
LSN24BIT            equ       0
FLOPPY              equ       1

* HWInit - Initialize the device
*   Entry: Y = hardware address
*   Exit:  Carry Clear = OK, Set = Error
*          B = error (Carry Set)
HWInit
                    lda       #%11010000          ($D0) Force Interrupt (stops any command in progress)
                    sta       CMDREG,y            write command to command register
                    lbsr      Delay2              delay 54~
                    lda       STATREG,y           clear status register
                    lda       #$FF
                    sta       currtrak,u          set current track to 255
                    leax      >NMIRtn,pcr         point to NMI routine
                    ifgt      Level-1
                    stx       <D.NMI              save address
                    else
                    stx       >D.XNMI+1           save address
                    lda       #$7E
                    sta       >D.XNMI
                    endc
                    lda       #MOTON              turn on drive motor
                    ora       WhichDrv,pcr
                    sta       CONTROL,y
* MOTOR ON spin-up delay loop (~307 mSec)
                    ifgt      Level-1
                    ifne      H6309
                    ldd       #$F000              3 cycles
                    else
                    ldd       #50000
                    endc
                    else
                    ldd       #25000
                    endc
*         IFNE  H6309
*         nop
*         ENDC
L003A               nop       1                   cycles
                    nop       1                   cycles
*         IFNE  H6309
*         nop
*         nop
*         nop
*         ENDC
                    subd      #$0001              4 cycles
                    bne       L003A               3 cycles
* HWTerm - Terminate the device
*   Entry: Y = hardware address
*   Exit:  Carry Clear = OK, Set = Error
*          B = error (Carry Set)
HWTerm              clrb
                    stb       CONTROL,y           turn off all drive motors (BGP)
                    rts


                    use       boot_common.asm


DoDDns              lda       #DDEN+MOTON         double density enable and motor on
                    ora       WhichDrv,pcr        OR in selected drive
                    sta       drvsel,u            save drive selection byte
                    clr       currtrak,u          clear current track
                    lda       #$05
                    lbsr      SetTrak             Set the track to the head we want
                    ldb       #0+STEP             RESTORE cmd
                    lbra      Talk2FDC            send command and wait for it to complete

* HWRead - Read a 256 byte sector from the device
*   Entry: Y = hardware address
*          B = bits 23-16 of LSN
*          X = bits 15-0  of LSN
*          blockloc,u = ptr to 256 byte sector
*   Exit:  X = ptr to data (i.e. ptr in blockloc,u)
*          Carry Clear = OK, Set = Error
*
HWRead              lda       #$91
                    bsr       L00DF               else branch subroutine
                    bcs       HWRRts              branch if error
                    ldx       blockloc,u          get buffer pointer in X for caller
                    clrb
HWRRts              rts

L00D7               bcc       L00DF
                    pshs      x,b,a
                    bsr       DoDDns
                    puls      x,b,a
L00DF               pshs      x,b,a               save LSN, command
                    bsr       ReadSect
                    puls      x,b,a               restore LSN, command
                    bcc       HWRRts              branch if OK
                    lsra
                    bne       L00D7
ReadSect            bsr       Seek2Sect           seek to the sector stored in X
                    bcs       HWRRts              if error, return to caller
                    ldx       blockloc,u          get address of buffer to fill
                    orcc      #IntMasks           mask interrupts
                    pshs      x                   save X
                    ldx       #$FFFF
                    ldb       #%10000000          ($80) READ SECTOR command
                    stb       CMDREG,y            write to command register
                    ldb       drvsel,u            (DDEN+MOTORON+BootDr)
* NOTE: The 1773 FDC multiplexes the write precomp enable and ready
* signals on the ENP/RDY pin, so the READY bit must always be ON for
* read and seek commands.  (from the FD502 FDC Service Manual)
                    orb       #DDEN+READY         set DDEN+READY bits ($30)
                    tst       side,u              are we on side 2?
                    beq       L0107
                    orb       #SIDESEL            set side 2 bit
L0107               stb       CONTROL,y
                    lbsr      Delay2              delay 54~
                    orb       #HALTENA            HALT enable ($80)
*         lda   #%00000010      RESTORE cmd ($02)
*L0111    bita  >DPort+STATREG
*         bne   L0123
*         leay  -$01,y
*         bne   L0111
*         lda   drvsel,u
*         sta   >DPort+CONTROL
*         puls  y
*         bra   L0138
                    stb       CONTROL,y
                    nop
                    nop
*         bra   L0123

                    ldx       ,s                  get X saved earlier
* Sector READ Loop
L0123               lda       DATAREG,y           read from WD DATA register
                    sta       ,x+
*         stb   >DPort+CONTROL
                    nop
                    bra       L0123
* RVH NOTE: This ONLY works for double density boot disks!  The Tandy
* controllers internally gate HALT enable with the DDEN bit, which
* means that reading a single-density boot disk will not generate the
* NMI signal needed to exit the read loop!  Single-density disks must
* use a polled I/O loop instead.
NMIRtn              leas      R$Size,s            adjust stack
                    puls      x
                    ldb       STATREG,y           read WD STATUS register
                    bitb      #$9C                any errors?
*         bitb  #$04            LOST DATA bit set?
                    beq       r@                  branch if not
*         beq   ChkErr          branch if not
L0138               comb                          else we will return error
                    ldb       #E$Read
r@                  rts

Seek2Sect
                    lda       #MOTON              permit alternate drives
                    ora       WhichDrv,pcr        permit alternate drives
                    sta       drvsel,u            save byte to static mem
                    clr       side,u              start on side 1
                    tfr       x,d                 move LSN into D
                    cmpd      #$0000              zero?
                    beq       L016C               branch if so
                    clr       ,-s                 else clear space on stack
                    pshs      a
                    lda       ddfmt,u
                    bita      #FMT.SIDE           double sided disk?
                    puls      a
                    beq       SnglSid             branch if not
                    bra       DblSid
* Double-sided code
L0152               com       side,u              flag side 2
                    bne       DblSid
                    inc       ,s
DblSid              subb      ddtks,u
                    sbca      #$00
                    bcc       L0152
                    bra       L0168
L0160               inc       ,s
SnglSid             subb      ddtks,u             subtract sectors per track from B
                    sbca      #$00
                    bcc       L0160
L0168               addb      ddtks,u             add sectors per track
                    puls      a                   get current track indicator off of stack
L016C               incb
                    stb       SECTREG,y           save in sector register
SetTrak             ldb       currtrak,u          get current track in B
                    stb       TRACKREG,y          save in track register
                    cmpa      currtrak,u          same as A?
                    beq       rtsok               branch if so
                    sta       currtrak,u
                    sta       DATAREG,y
                    ldb       #$10+STEP           SEEK command
                    bsr       Talk2FDC            send command to controller
                    pshs      x
* Seek Delay
                    ldx       #$222E              delay ~39 mSec (78mS L1)
SeekDly             leax      -$01,x
                    bne       SeekDly
                    puls      x
rtsok               clrb
                    rts

*ChkErr   bitb  #$98            evaluate WD status (READY, RNF, CRC err)
*         bne   L0138
*         clrb
*         rts

Talk2FDC            bsr       DoCMD               issue FDC cmd, wait 54~
FDCLoop             ldb       STATREG,y           get status
                    bitb      #$01                still BUSY?
                    bne       FDCLoop             loop until command completes
                    rts

* Issue command and wait 54 clocks
* Controller requires a min delay of 14uS (DD) or 28uS (SD)
* following a command write before status register is valid
DoCMD               bsr       SelNSend
* Delay branches
* 54 clock delay including bsr (=30uS/L2,60us/L1)
* H6309 code changed to reduce code size, RG
                    ifeq      H6309
Delay2
                    lbsr      Delay3
Delay3
                    lbsr      Delay4
Delay4
                    else
Delay2              lda       #5                  3 cycles
Delay3              exg       a,a                 5 cycles  | 10*5
                    deca                          2 cycles  |
                    bne       Delay3              3 cycles  |
                    endc
                    rts

* Select And Send
* Entry: B = command byte
SelNSend            lda       drvsel,u
                    sta       CONTROL,y
                    stb       CMDREG,y
                    rts

                    ifgt      Level-1
* L2 kernel file is composed of rel, boot, krn. The size of each of these
* is controlled with filler, so that (after relocation):
* rel  starts at $ED00 and is $130 bytes in size
* boot starts at $EE30 and is $1D0 bytes in size
* krn  starts at $F000 and ends at $FEFF (there is no 'emod' at the end
*      of krn and so there are no module-end boilerplate bytes)
*
* Filler to get to a total size of $1D0. 3, 2, 1 represent bytes after
* the filler: the end boilerplate for the module, fdb and fcb respectively.
Filler              fill      $39,$1D0-3-2-1-*
                    endc

Address             fdb       DPort
WhichDrv            fcb       BootDr

                    emod
eom                 equ       *
                    end
