********************************************************************
* Level 1 kernel feature switches shared with TurbOS.
* Defaults preserve the complete NitrOS-9 kernel. Override with -Dname=0
* to omit a feature. These switches do not change the OS-9 ABI or the
* process descriptor layout. Clock/VIRQ switches belong to clock modules.
*
* TurbOS profiles use _FF_SWI; its kernel uses _FF_SSWI. Accept both,
* with an explicit _FF_SSWI taking precedence.

                    ifndef    _FF_SSWI
                    ifdef     _FF_SWI
_FF_SSWI            equ       _FF_SWI
                    endc
                    endc

* Module header parity, CRC validation, and F$CRC.
                    ifndef    _FF_MODCHECK
_FF_MODCHECK        equ       1
                    endc

* IOMan dispatch and process path inheritance/cleanup.
                    ifndef    _FF_UNIFIED_IO
_FF_UNIFIED_IO      equ       1
                    endc

* Bootfile loading during kernel part 2 startup.
                    ifndef    _FF_BOOTING
_FF_BOOTING         equ       1
                    endc

* F$ID service.
                    ifndef    _FF_ID
_FF_ID              equ       1
                    endc

* F$SPrior service.
                    ifndef    _FF_SPRIOR
_FF_SPRIOR          equ       1
                    endc

* F$SSWI service (process software interrupt vectors).
                    ifndef    _FF_SSWI
_FF_SSWI            equ       1
                    endc

* Calls through the device interrupt polling vector.
                    ifndef    _FF_IRQ_POLL
_FF_IRQ_POLL        equ       1
                    endc

