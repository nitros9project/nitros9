********************************************************************
* vectors - CoCo ROM vectors
*
* $Id: vectors.asm,v 1.1 2004/04/05 03:34:39 boisy Exp $
*
* These 16 bytes are merged at the end of the ROM image in ROM-based
* NitrOS-9 kernels
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

*
* Note that the $8015 value for the RESET vector must match the
* offset of the "start" label in rominfo.asm
*
                    ifp1
                    use       defsfile
                    endc

                    ifgt      Level-1

* NitrOS-9 Level 2 ROM vectors
                    fdb       $0000               Reserved
                    fdb       $FEEE               SWI3
                    fdb       $FEF1               SWI2
                    fdb       $FEF4               FIRQ
                    fdb       $FEF7               IRQ
                    fdb       $FEFA               SWI
                    fdb       $FEFD               NMI
                    fdb       $8015               RESET

                    else

* NitrOS-9 Level 1 ROM Vectors
                    fdb       $8015               Reserved
                    fdb       $0100               SWI3
                    fdb       $0103               SWI2
                    fdb       $010F               FIRQ
                    fdb       $010C               IRQ
                    fdb       $0106               SWI
                    fdb       $0109               NMI
                    fdb       $8015               RESET

                    endc
