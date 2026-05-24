********************************************************************
* RunB - Basic09 Runtime
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  22      2002/12/26  Boisy G. Pitre
* Acquired Tandy/Microware version.
*
*          2003/05/13  Robert Gault
* Tables L000D, L00E9 removed some UNID, translated jump
* vectors L00D9, L0442.
*
* 06/07/14 - Minor change to Date$ to accommodate F$Time Y2K changes. RG
                    nam       RunB
                    ttl       Basic09 Runtime

* Disassembled 02/12/26 08:42:45 by Disasm v1.5 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       22
B09RUNB             set       1
EDITOR              equ       $01
RUNTIM              equ       $02
MATHPAK             equ       $04
INCLUDED            set       RUNTIM+MATHPAK

                    use       runb_core.asm

                    emod
eom                 equ       *
                    end
