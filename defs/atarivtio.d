                    IFNE      ATARIVTIO.D-1
ATARIVTIO.D         SET       1

********************************************************************
* VTIO Defs for the Atari XE/XL
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
V.KySns             RMB       1                   key sense flags
V.EscCh1            RMB       2                   escape vector handler
V.EscVect           RMB       2                   escape vector handler
V.IBufH             RMB       1                   input buffer head
V.IBufT             RMB       1                   input buffer tail
V.InBuf             RMB       KBufSz              input buffer
                    RMB       250-.
V.Last              EQU       .

                    ENDC
