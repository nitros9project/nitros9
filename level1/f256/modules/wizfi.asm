                    ifp1
                    use       defsfile
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       V.SCF
size                equ       .

                    fcb       UPDAT.+SHARE.     these are the supported modes.

name                fcs       /wizfi/
                    fcb       edition

start               lbra      Init              |SCF jump table
                    lbra      Read              |
                    lbra      Write             |
                    lbra      GetSta            |
                    lbra      SetSta            |I$Open requires certain SetStats
                    lbra      Term


***********************************************************************************
* Init              
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
* Initialize driver to off.  We don't need to set up an SOL or IRQ
* until a user requests to set up one.
Init                clrb
                    rts


***********************************************************************************
* Read
*
* Entry:
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    A  = character read
*    CC = carry set on error
*    B  = error code
*
* Nothing to read, just return
Read                clra
                    ldb   #E$EOF
                    rts


***********************************************************************************
* Write
*
* Entry:
*    A  = character to write
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
* Nothing to write, just return
Write               clrb
                    rts


***********************************************************************************
* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Term                clrb
                    rts


***********************************************************************************
* GetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
****************************
* Get status entry point
* Entry: A=Function call #
* There are no getstat calls, just return
GetSta              clrb
                    rts


***********************************************************************************
* SetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
SetSta              clrb
                    rts

                    emod
eom                 equ       *
                    end