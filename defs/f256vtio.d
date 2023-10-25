                    IFNE      F256VTIO.D-1
F256VTIO.D          SET       1

********************************************************************
* VTIO Defs for the F256
* Everything that the VTIO driver needs is defined here, including
* static memory definitions

* Constant Definitions
KBufSz              EQU       8                   circular buffer size


* Driver Static Memory
                    ORG       V.SCF
V.CurRow            RMB       1
V.CurCol            RMB       1
V.CurChr            RMB       1                   character under the cursor
V.CapsLck           RMB       1                   caps lock flag
V.Shift             RMB       1                   shift flag
V.Ctrl              RMB       1                   control flag
V.Alt               RMB       1                   alt flag
V.KySns             RMB       1                   key sense flags
V.EscCh1            RMB       2                   escape vector handler
V.EscVect           RMB       2                   escape vector handler
V.FBCol             RMB       1                   foreground and background color
V.BordCol           RMB       1                   border color
V.KeyCodeHandler    RMB       2                   key code handler
V.IBufH             RMB       1                   input buffer head
V.IBufT             RMB       1                   input buffer tail
V.InBuf             RMB       KBufSz              input buffer
                    RMB       250-.
V.Last              EQU       .

                    ENDC
