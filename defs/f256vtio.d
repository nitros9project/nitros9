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
V.CurRow            RMB       1                   the current row where the next character goes
V.CurCol            RMB       1                   the current column where the next character goes
V.CurChr            RMB       1                   the character under the cursor
V.CapsLck           RMB       1                   the CAPS LOCK key up/down flag ($00 = up)
V.SHIFT             RMB       1                   the SHIFT key up/down flag ($00 = up)
V.CTRL              RMB       1                   the CTRL key up/down flag ($00 = up)
V.ALT               RMB       1                   the ALT key up/down flag ($00 = up)
V.KySns             RMB       1                   the key sense flags
V.EscCh1            RMB       2                   the escape vector handler for the first character after the escape code
V.EscVect           RMB       2                   the escape vector handle
V.Reverse           RMB       1                   the reverse video flag ($00 = off, $FF = on)
V.FBCol             RMB       1                   the currently selected foreground and background color
V.BordCol           RMB       1                   the currently selected border color
V.KCVect            RMB       2                   the PS/2 key code handler
V.IBufH             RMB       1                   the input buffer head pointer
V.IBufT             RMB       1                   the input buffer tail pointer

V.WWidth            RMB       1                   the window width
V.WHeight           RMB       1                   the window height

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

                    ENDC
