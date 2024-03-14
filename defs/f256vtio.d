                    IFNE      F256VTIO.D-1
F256VTIO.D          SET       1

********************************************************************
* vtio definitions for the F256
*
* Everything that the vtio driver needs is defined here, including
* static memory definitions.

* Constant definitions.
KBufSz              EQU       8                   the circular buffer size

* Driver static memory.
                    ORG       V.SCF
V.CurRow            RMB       1                   current row where the next character goes
V.CurCol            RMB       1                   current column where the next character goes
V.CapsLck           RMB       1                   CAPS LOCK key up/down flag ($00 = up)
V.SHIFT             RMB       1                   SHIFT key up/down flag ($00 = up)
V.CTRL              RMB       1                   CTRL key up/down flag ($00 = up)
V.ALT               RMB       1                   ALT key up/down flag ($00 = up)
V.KySns             RMB       1                   key sense flags
V.LEDStates         RMB       1                   PS/2 LED flags (bit 2 = CAPS Lock, bit 1 = NUM Lock, bit 0 = Scroll Lock)
V.EscVect           RMB       2                   escape vector handle
V.Reverse           RMB       1                   reverse video flag ($00 = off, $FF = on)
V.FBCol             RMB       1                   currently selected foreground and background color
V.BordCol           RMB       1                   currently selected border color
V.IBufH             RMB       1                   input buffer head pointer
V.IBufT             RMB       1                   input buffer tail pointer
V.SSigID            RMB       1                   data ready process ID
V.SSigSg            RMB       1                   data ready signal code
V.WWidth            RMB       1                   window width
V.WHeight           RMB       1                   window height

V.KeyDrvMPtr        RMB       2                   keydrv module address
V.KeyDrvEPtr        RMB       2                   keydrv entry point address

V.KeyDrvStat        equ       .
                    RMB       8

V.EscParms          RMB       20
* DWSet Parameters
V.DWType            set       V.EscParms+0
V.DWStartX          set       V.EscParms+1
V.DWStartY          set       V.EscParms+2
V.DWWidth           set       V.EscParms+3
V.DWHeight          set       V.EscParms+4
V.DWFore            set       V.EscParms+5
V.DWBack            set       V.EscParms+6
V.DWBorder          set       V.EscParms+7

V.InBuf             RMB       KBufSz              the input buffer
                    RMB       250-.
V.Last              EQU       .

* Borrow 11 bytes (16 bytes available in Level 1) from "CoCo" specific area of system globals for F256's use.
                    org       D.IRQTmp
D.Bell              rmb       2
D.TnCnt             rmb       1
D.OrgAlt            rmb       2
D.SndPrcID          rmb       1
D.KySns             rmb       1
* F256K specific section
D.RowState          RMB       9

* SS.KySns bit locations
SHIFTBIT	equ	 %00000001
CTRLBIT	equ	 %00000010
ALTBIT	equ	 %00000100
UPBIT	equ	 %00001000
DOWNBIT	equ	 %00010000
LEFTBIT	equ	 %00100000
RIGHTBIT	equ	 %01000000
SPACEBIT	equ	 %10000000

                    ENDC
