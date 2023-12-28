********************************************************************
* Boot_d64, bootfile for Dragon 32/64, Dragon Alpha/Professional.
* Provides HWInit, HWTerm, HWRead which are called by code in
* "use"d boot_common.asm
*
* 2004-11-07, P.Harvey-Smith.
*       First disasembly and porting
*
* 2004-11-09, P.Harvey-Smith.
*       Dragon Alpha code, I am not sure of how to disable NMI
*       on the Alpha, it is simulated in software using the NMIFlag.
*
* See DDisk.asm for a fuller discription of how Dragon Alpha
* interface works.
*
* 2004-11-25, P.Harvey-Smith.
*       Double sided Disk code added
*
* 2005-05-08, P.Harvey-Smith,
*       Added code to force 5/8 line low on Alpha so correct clock selected.
*
* 2005-06-16, P.Harvey-Smith.
*       Added NMI enable/disable code, as I know know how to enable/disable
*       NMI on the Alpha, having disasembled the Alpha's OS9's ddisk.
*
* 2005-10-22, P.Harvey-Smith.
*       Removed unused user stack variable (u0000).
*
* 2005-12-31, P.Harvey-Smith.
*       Converted to using new boot system which can support fragmented
*       boot files.
*
* 2006-01-08, P.Harvey-Smith.
*       Fixed up step-rate so that it is the same as that specified as the
*       default when building NitrOS9, currently the distribution sets
*       this to 12ms, as this seems to be the default for both the
*       Dragon Data original 5.25" floppies, and for the Sony 3.5"
*       drives in the Alpha. This allows NitrOS9 to boot correctly
*       on Dragon Data 5.25" drives, and should also make booting on
*       the Alpha much more reliable.
*

                    nam       Boot
                    ttl       Dragon 32/64 Boot module

* Disassembled 1900/00/00 00:05:56 by Disasm v1.5 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

                    ifne      dalpha
* Dragon Alpha has a third PIA at $FF24, this is used for
* Drive select/motor control, and provides FIRQ from the
* disk controller.

DPPIADA             equ       DPPIA2DA
DPPIACRA            equ       DPPIA2CRA
DPPIADB             equ       DPPIA2DB
DPPIACRB            equ       DPPIA2CRB

PIADA               equ       DPPIADA+IO          Side A Data/DDR
PIACRA              equ       DPPIACRA+IO         Side A Control.
PIADB               equ       DPPIADB+IO          Side A Data/DDR
PIACRB              equ       DPPIACRB+IO         Side A Control.

* WD2797 Floppy disk controller, used in Alpha. Note registers in reverse order!
DPCMDREG            equ       DPCmdRegA           command/status
DPTRKREG            equ       DPTrkRegA           Track register
DPSECREG            equ       DPSecRegA           Sector register
DPDATAREG           equ       DPDataRegA          Data register

CMDREG              equ       DPCMDREG+IO         command/status
TRKREG              equ       DPTRKREG+IO         Track register
SECREG              equ       DPSECREG+IO         Sector register
DATAREG             equ       DPDATAREG+IO        Data register

* Disk IO bitmasks
NMIEn               equ       NMIEnA
WPCEn               equ       WPCEnA
SDensEn             equ       SDensEnA
MotorOn             equ       MotorOnA

* Drive selects for non default boot drives.
DRVSEL0             equ       Drive0A
DRVSEL1             equ       Drive1A
DRVSEL2             equ       Drive2A
DRVSEL3             equ       Drive3A

                    else
DPPIADA             equ       DPPIA1DA
DPPIACRA            equ       DPPIA1CRA
DPPIADB             equ       DPPIA1DB
DPPIACRB            equ       DPPIA1CRB

PIADA               equ       DPPIADA+IO          Side A Data/DDR
PIACRA              equ       DPPIACRA+IO         Side A Control.
PIADB               equ       DPPIADB+IO          Side A Data/DDR
PIACRB              equ       DPPIACRB+IO         Side A Control.

* WD2797 Floppy disk controller, used in DragonDos.
DPCMDREG            equ       DPCmdRegD           command/status
DPTRKREG            equ       DPTrkRegD           Track register
DPSECREG            equ       DPSecRegD           Sector register
DPDATAREG           equ       DPDataRegD          Data register

CMDREG              equ       DPCMDREG+IO         command/status
TRKREG              equ       DPTRKREG+IO         Track register
SECREG              equ       DPSECREG+IO         Sector register
DATAREG             equ       DPDATAREG+IO        Data register

* Disk IO bitmasks

NMIEn               equ       NMIEnD
WPCEn               equ       WPCEnD
SDensEn             equ       SDensEnD
MotorOn             equ       MotorOnD


* Drive selects for non default boot drives.

DRVSEL0             equ       Drive0D
DRVSEL1             equ       Drive1D
DRVSEL2             equ       Drive2D
DRVSEL3             equ       Drive3D
                    endc

* Default Boot is from drive 0
BootDr              set       DRVSEL0
                    ifeq      DNum-1
BootDr              set       DRVSEL1             Alternate boot from drive 1
                    endc
                    ifeq      DNum-2
BootDr              set       DRVSEL2             Alternate boot from drive 2
                    endc
                    ifeq      DNum-3
BootDr              set       DRVSEL3             Alternate boot from drive 3
                    endc

StepRate            equ       3-STEP              Convert OS9 steprate code to WD.

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

* NOTE: these are U-stack offsets, not DP
seglist             rmb       2                   pointer to segment list
blockloc            rmb       2                   pointer to memory requested
blockimg            rmb       2                   duplicate of the above
bootsize            rmb       2                   size in bytes
LSN0Ptr             rmb       2                   In memory LSN0 pointer
drvsel              rmb       1
CurrentTrack        rmb       1                   Current track number
* Note, for optimization purposes, the following two variables
* should be adjacent!!
ddtks               rmb       1                   no. of sectors per track
ddfmt               rmb       1
side                rmb       1                   side 2 flag

size                equ       .

name                equ       *
                    fcs       /Boot/
                    fcb       $00

* Common booter-required defines
LSN24BIT            equ       0
FLOPPY              equ       1


HWInit              clra
                    ldx       #CMDREG             Force interrupt
                    lda       #FrcInt
                    sta       ,x
                    lbsr      Delay               Wait for command to complete
                    lda       ,x
                    lda       piadb               Clear DRQ from WD.

                    ifne      dalpha
                    lda       #NMICA2Dis          Set PIA2 CA2 as output & disable NMI
                    sta       PIA2CRA
                    endc

                    lda       #$FF
                    sta       CurrentTrack,u
                    leax      >NMIService,pcr     Setup NMI Handler.
                    stx       >D.XNMI+1
                    lda       #$7E                $7E=JMP
                    sta       >D.XNMI

                    lda       #MotorOn            Turn on motor
                    ora       WhichDrv,pcr        OR in selected drive
                    sta       drvsel,u            save drive selection byte

                    ifne      dalpha
                    lbsr      AlphaDskCtl
                    else
                    sta       >DSKCTL
                    endc

                    ldd       #$C350              Delay while motors spin up
MotorOnDelay
                    nop
                    nop
                    subd      #$0001
                    bne       MotorOnDelay

HWTerm              clrb
                    rts

                    use       boot_common.asm

*
* Reset disk heads to track 0
*

ResetTrack0
                    clr       CurrentTrack,u      Zero current track
                    lda       #$05
L00A9               ldb       #StpICmnd+StepRate  Step in
                    pshs      a
                    lbsr      CommandWaitReady
                    puls      a
                    deca
                    bne       L00A9
                    ldb       #RestCmnd+StepRate  Restore to track 0
                    lbra      CommandWaitReady

* HWRead - Read a 256 byte sector from the device
*   Entry: Y = hardware address
*          B = bits 23-16 of LSN
*          X = bits 15-0  of LSN
*                  blockloc,u = ptr to 256 byte sector
*   Exit:  X = ptr to data (i.e. ptr in blockloc,u)
*          Carry Clear = OK, Set = Error

ReadSec
HWRead
                    lda       #$91                Retry count
                    bsr       ReadDataWithRetry   Yes read sector
                    bcs       ReadDataExit        And restore Y=LSN0 pointer
                    ldx       blockloc,u
                    clrb
ReadDataExit
                    rts

ReadDataRetry
                    bcc       ReadDataWithRetry   Retry data read if error
                    pshs      x,b,a
                    bsr       ResetTrack0         Recalibrate drive
                    puls      x,b,a

ReadDataWithRetry
                    pshs      x,b,a
                    bsr       DoReadData          Try reading data
                    puls      x,b,a
                    bcc       ReadDataExit        No error, return to caller
                    lsra                          decrement retry count
                    bne       ReadDataRetry       retry read on error

DoReadData
                    bsr       SeekTrack           Seek to correct track
                    bcs       ReadDataExit        Error : exit

                    ldx       blockloc,u          Set X=Data load address
                    pshs      y,dp,cc
                    orcc      #$50                Enable FIRQ=DRQ from WD
                    lda       #$FF                Make DP=$FF, so access to WD regs faster
                    tfr       a,dp

                    lda       #$34
                    sta       <dppia0crb          Disable out PIA0 IRQ

                    lda       #$37
                    sta       <dppiacrb           Enable FIRQ
                    lda       <dppiadb            Clear any pending FIRQ

                    lda       drvsel,u
                    ora       #NMIEn

                    ifne      dalpha
                    lbsr      AlphaDskCtl
                    else
                    sta       <dpdskctl
                    endif

                    ldb       #ReadCmnd           Issue a read command
                    orb       side,u              mask in side select
                    stb       <dpcmdreg

                    ifne      dalpha
                    lda       #NMICA2En           Enable NMI
                    sta       <DPPIA2CRA
                    endif

ReadDataWait
                    sync                          Read data from controller, save
ReadDataNow
                    lda       <dpdatareg          in memory at X
                    ldb       <dppiadb
                    sta       ,x+
                    bra       ReadDataWait        We break out with an NMI

*
* NMI service routine.
*

NMIService

                    leas      R$Size,s            Drop saved Regs from stack
                    lda       #MotorOn

                    ifne      dalpha
                    lbsr      AlphaDskCtl
                    lda       #NMICA2Dis          Disable NMI
                    sta       <DPPIA2CRA
                    else
                    sta       <dpdskctl
                    endif

                    lda       #$34                Disable FIRQ inturrupt
                    sta       <dppiacrb
                    ldb       <dpcmdreg
                    puls      y,dp,cc

                    bitb      #$04                Check for error
                    lbeq      L015A
L011A               comb
                    ldb       #$F4
                    rts

*
* Seek to a track, at this point Y still points to
* in memory copy of LSN0 (if not reading LSN0 !).
*

SeekTrack
                    ldy       LSN0Ptr,u           Get LSN0 pointer
                    tfr       x,d
                    cmpd      #$0000              LSN0 ?
                    beq       SeekCalcSkip
                    clr       ,-s                 Zero track counter
                    bra       L012E

L012C               inc       ,s
L012E
                    subd      DD.Spt,Y            Take sectors per track from LSN
                    bcc       L012C               still +ve ? keep looping
                    addd      DD.Spt,Y            Compensate for over-loop
                    puls      a                   retrieve track count.

* At this point the A contains the track number,
* and B contains the sector number on that track.

SeekCalcSkip
                    pshs      b                   Save sector number

                    ldb       DD.Fmt,Y            Is the media double sided ?
                    lsrb
                    bcc       DiskSide0           skip if not

                    lsra                          Get bit 0 into CC, and divide track by 2
                    bcc       DiskSide0           Even track no so it's on side 0
                    ldb       #Sid2Sel            Odd track so on side 1, flag it
                    bra       SetSide

DiskSide0
                    clrb                          Single sided, make sure sidesel set correctly
SetSide
                    stb       side,U              Set side

                    puls      b                   Get sector number
                    incb
                    stb       SECREG
                    ldb       CurrentTrack,u
                    stb       TRKREG
                    cmpa      CurrentTrack,u
                    beq       L0158
                    sta       CurrentTrack,u
                    sta       DATAREG
                    ldb       #SeekCmnd+3         Seek command+ step rate code $13
                    bsr       CommandWaitReady
                    pshs      x

                    ldx       #$222E              Wait for head to settle.
SettleWait
                    leax      -$01,x
                    bne       SettleWait

                    puls      x
L0158               clrb
                    rts

L015A               bitb      #$98
                    bne       L011A
                    clrb
                    rts

CommandWaitReady
                    bsr       MotorOnCmdBDelay    Turn on motor and give command to WD
CommandWait
                    ldb       >CMDREG             Get command status
                    bitb      #$01                finished ?
                    bne       CommandWait         nope : continue waiting.
                    rts

MotorOnCmdB
                    lda       drvsel,u            Turn on motor

                    ifne      dalpha
                    bsr       AlphaDskCtl
                    else
                    sta       >DSKCTL
                    endif

                    stb       >CMDREG             Give command from B
                    rts

MotorOnCmdBDelay
                    bsr       MotorOnCmdB
Delay               lbsr      Delay2
Delay2              lbsr      Delay3
Delay3              rts

                    ifne      dalpha
*
* Turn on drives/motor/nmi for The Dragon Alpha.
*

AlphaDskCtl
                    pshs      X,A,B,CC

                    bita      #MotorOn            test motor on ?
                    bne       MotorRunning

                    clra                          No, turn off other bits.
MotorRunning
                    anda      #Mask58             Mask out 5/8 bit to force the use of 5.25" clock
                    sta       -1,s

                    orcc      #$50                disable inturrupts

                    ldx       #PIA2DA
                    lda       #AYIOREG            AY-8912 IO register
                    sta       2,X                 Output to PIA
                    ldb       #AYREGLatch         Latch register to modify
                    stb       ,x

                    clr       ,x                  Idle AY

                    lda       -1,s                Fetch saved Drive Selects etc
                    sta       2,x                 output to PIA
                    ldb       #AYWriteReg         Write value to latched register
                    stb       ,x

                    clr       ,x

                    puls      x,A,B,CC
                    rts
                    endc

Address             fdb       DPort
WhichDrv            fcb       BootDr

                    emod
eom                 equ       *
                    end
