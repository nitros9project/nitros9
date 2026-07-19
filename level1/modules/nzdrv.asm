********************************************************************
* nzdrv - Lean SCF driver for the /Nil and /Zero pseudo-devices
*
* One source, two builds (selected by the NIL assembly symbol; an
* undefined NIL counts as 0 via the condundefzero pragma):
*   default          -> module "ZDrv": Read yields endless $00 bytes (/Zero)
*   assemble -DNIL=1  -> module "NDrv": Read yields end-of-file        (/Nil)
*
* The two builds share everything except a single Read instruction.
* Write/Init/GetStat/SetStat/Term all just succeed (writes discarded).
* No hardware is touched and NO IRQ/VIRQ is installed, so this is far
* lighter than VRN (the combined VIRQ/RAM/Nil driver) for ports that
* only want /Nil and/or /Zero. Pair with the matching nzdesc descriptor.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/06/17  Mark Murray
* Created.

                  IFP1
                    use       defsfile
                  ENDC

                    org       V.SCF     static starts at the SCF base
ZMem                equ       .         no driver-private storage required

rev                 set       $00
edition             set       1

                    mod       ZEnd,ZName,Drivr+Objct,ReEnt+rev,ZEntry,ZMem

                    fcb       UPDAT.    access mode(s): read + write

                  IFNE    NIL
ZName               fcs       "NDrv"
                  ELSE
ZName               fcs       "ZDrv"
                  ENDC
                    fcb       edition

* SCF low-level entry table: Init, Read, Write, GetStat, SetStat, Term
ZEntry              lbra      ZInit
                    lbra      ZRead
                    lbra      ZWrite
                    lbra      ZGetSt
                    lbra      ZSetSt
                    lbra      ZTerm

* Read - the only difference between the two devices:
*   /Zero: CLRA loads A with $00 (the byte SCF reads back) and clears
*          Carry (no error), so every read returns a zero, forever.
*   /Nil : return end-of-file (Carry set) - the classic bit-bucket read.
ZRead               equ       *
                  IFNE    NIL
                    comb                set Carry (error)
                    ldb       #E$EOF    end-of-file
                  ELSE
                    clra                A=$00 data byte, Carry clear
                  ENDC
                    rts

* Init/Write/GetStat/SetStat/Term - nothing to do. Write's byte (in A) is
* simply discarded. CLRB clears Carry (no error), so opens, writes, stat
* calls and detach all just succeed.
ZInit               equ       *
ZWrite              equ       *
ZGetSt              equ       *
ZSetSt              equ       *
ZTerm               clrb
                    rts

                    emod
ZEnd                equ       *
                    end
