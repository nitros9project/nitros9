                    ifp1
                    use       defsfile
                    endc

* Note: we are "stealing" D.SWPage for our driver. This means the WizFi and the
* SmartWatch functionality are not compatible and should not be in the same bootfile.
D.WZStatTbl         equ       D.SWPage

* D.WZStatTbl definitions (must be 256 bytes max)
WZ.StatCnt          equ       4                   there are four channels in the WizFi
WZ.BufSiz           equ       16                  16 bytes per channel for input buffering


* These next value represent offsets into the D.WZStatTbl (256 byte buffer) that the Init routine
* allocates using F$SRqMem.
                    org       $00
WZ.VIRQPkt          rmb       Vi.PkSz             VIRQ variables
WZ.StatTbl          rmb       WZ.StatCnt*WZ.BufSiz input buffers


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
Init
* Check if we've already allocated memory.
                    ifgt      Level-1
                    ldx       <D.WZStatTbl
                    else
                    ldx       >D.WZStatTbl
                    endc
                    bne       initex
                    
* Allocate a single 256 byte page of memory
                    ldd       #$0100
                    pshs      u
                    os9       F$SRqMem
                    tfr       u,x
                    puls      u
                    ifgt      Level-1
                    stx       <D.WZStatTbl
                    else
                    stx       >D.WZStatTbl
                    endc
                    
                    leax      WZ.VIRQPkt,x
                    pshs      u
                    tfr       x,u
                    leax      Vi.Stat,x           ;fake VIRQ status register
                    lda       #$80                ;VIRQ flag clear, repeated VIRQs
                    sta       ,x                  ;set it while we're here...
                    tfr       x,d                 ;copy fake VIRQ status register address
                    leax      IRQPckt,pcr         ;IRQ polling packet
                    leay      IRQSvc,pcr          ;IRQ service entry
                    os9       F$IRQ               ;install
                    puls      u
                    bcs       InitEx              ;exit with error
                    tfr       x,y                 ; move VIRQ software packet to Y
tryagain
                    ldx       #$0001              ; code to install new VIRQ
                    os9       F$VIRQ              ; install
                    bcc       IRQok               ; no error, continue
                    cmpb      #E$UnkSvc
                    bne       InitEx
IRQok

initex
                    clrb
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



* Interrupt Service Routine Section
IRQPckt             fcb       $00,$01,$0A         ;IRQ packet Flip(1),Mask(1),Priority(1) bytes

* Upon entry, U points to 
IRQSvc            
                    rti
                    
                    emod
eom                 equ       *
                    end