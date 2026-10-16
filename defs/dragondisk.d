                    IFNE      DRAGONDISK.D-1
DRAGONDISK.D        set       1

********************************************************************
* DragonDisk - Dragon 64 floppy (DragonDOS WD2797) definitions
*
* The disk and PIA equates of dragon.d, for Level 2 Dragon builds that
* use coco.d for everything else (i-MMU-nity). dragon.d can't be used
* there: it redefines Bt.Size/Bt.Track/Bt.Start, PIA0Base and the clock
* symbols that the Level 2 kernel track gets from coco.d.
* Used only by ddisk.asm and boot_d64.asm (ifgt Level-1).
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2026/10/16
* Split from dragon.d for the Dragon 64 + i-MMU-nity port.

                    nam       DragonDisk
                    ttl       Dragon 64 floppy definitions

IO                  equ       $FF00               I/O page

* PIA 0 and 1, direct page offsets and absolute addresses
DPPIA0DA            equ       $00
DPPIA0CRA           equ       $01
DPPIA0DB            equ       $02
DPPIA0CRB           equ       $03
PIA0DA              equ       DPPIA0DA+IO
PIA0CRA             equ       DPPIA0CRA+IO
PIA0DB              equ       DPPIA0DB+IO
PIA0CRB             equ       DPPIA0CRB+IO

DPPIA1DA            equ       $20
DPPIA1CRA           equ       $21
DPPIA1DB            equ       $22
DPPIA1CRB           equ       $23
PIA1DA              equ       DPPIA1DA+IO
PIA1CRA             equ       DPPIA1CRA+IO
PIA1DB              equ       DPPIA1DB+IO
PIA1CRB             equ       DPPIA1CRB+IO

* Dragon 64 6551 ACIA
DPAciaData          equ       $04
DPAciaStat          equ       $05
DPAciaCmd           equ       $06
DPAciaCtrl          equ       $07
AciaData            equ       DPAciaData+IO
AciaStat            equ       DPAciaStat+IO
AciaCmd             equ       DPAciaCmd+IO
AciaCtrl            equ       DPAciaCtrl+IO

* DragonDOS WD2797
DPCmdRegD           equ       $40                 command/status
DPTrkRegD           equ       $41                 track
DPSecRegD           equ       $42                 sector
DPDataRegD          equ       $43                 data
CmdRegD             equ       DPCmdRegD+IO
TrkRegD             equ       DPTrkRegD+IO
SecRegD             equ       DPSecRegD+IO
DataRegD            equ       DPDataRegD+IO

* Drive control latch
DPDSKCTL            equ       $48
DSKCTL              equ       DPDSKCTL+IO
NMIEnD              equ       %00100000
WPCEnD              equ       %00010000
SDensEnD            equ       %00001000
MotorOnD            equ       %00000100
Drive0D             equ       %00000000
Drive1D             equ       %00000001
Drive2D             equ       %00000010
Drive3D             equ       %00000011
DDosDriveMask       equ       %00000011
DDosCtrlMask        equ       %11111100

* WD2797 commands
FrcInt              equ       %11010000
ReadCmnd            equ       %10001000
RestCmnd            equ       %00000000
SeekCmnd            equ       %00010000
StpICmnd            equ       %01000000
WritCmnd            equ       %10101000
WtTkCmnd            equ       %11110000
Sid2Sel             equ       %00000010

* WD2797 status bits
BusyMask            equ       %00000001
LostMask            equ       %00000100
ErrMask             equ       %11111000
CRCMask             equ       %00001000
RNFMask             equ       %00010000
RTypMask            equ       %00100000
WPMask              equ       %01000000
NotRMask            equ       %10000000

* PD.DNS bits
DensMask            equ       %00000001
T80Mask             equ       %00000010

                    ENDC
