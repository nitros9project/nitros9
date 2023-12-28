* Parallel Printer device for Dragon 32/64/Alpha.
*
* Disassembled from the Alpha OS-9 2005-06-14, P.Harvey-Smith.
*

                    nam       scdpp
                    ttl       Dragon Parallel Printer Driver

* Disassembled 1900/00/00 00:08:11 by Disasm v1.5 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       3
                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       29
size                equ       .

                    fcb       $03
name                equ       *
                    fcs       /scdpp/
                    fcb       edition

start               equ       *
                    lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term

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
Init                pshs      cc
                    orcc      #$50                ; Disable Inturrupts
                    ldx       #PIA1DA             ; Point to PIA1DA
                    ldb       1,x                 ; Get CRA
                    clr       1,x                 ; Zero CR and select DDRA
                    lda       #$FE                ; Set bit 0 as input (cassette in), all others as input
                    sta       ,x
                    stb       1,x                 ; Restore CRA
                    ldx       #PIA1DB             ; Point at PIA1DB
                    ldb       1,x                 ; Save CRB
                    clr       1,x                 ; Zero CR and select DDRB
                    lda       ,x                  ; get DDRB
                    anda      #$FE                ; Set bit 0 as input (printer busy), all others leave alone
                    sta       ,x
                    stb       1,x                 ; restore CRB
                    puls      cc
                    clrb                          ; Flag no error
                    rts

* Read
*
* Entry:
*    B  = MSB of the disk's LSN
*    X  = LSB of the disk's LSN
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*

Read                ldb       #$CB                ; Ilegal mode, cannot read from printer !
                    orcc      #$01
                    rts

* Write
*
* Entry:
*    B  = MSB of the disk's LSN
*    X  = LSB of the disk's LSN
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*

Write               pshs      a
L0053               ldb       #$08                ; retry count
L0055               lda       >PIA1DB             ; Get printer busy flag
                    lsra                          ; Get busy bit into carry
                    bcc       WriteNotBusy        ; Not busy : continue
                    nop       ;                   wait a little while
                    nop
                    decb                          ; decrement retry counter
                    bne       L0055               ; Non zero : check flag again

                    pshs      x                   ; Still busy: send calling process to sleep
                    ldx       #$0001
                    os9       F$Sleep
                    puls      x
                    bra       L0053               ; When we wake, poll busy again

WriteNotBusy
                    puls      a
                    pshs      cc
                    orcc      #$50                ; disable inturrupts
                    sta       >PIA0DB             ; Send character to printer
                    lda       >PIA1DA             ; Toggle printer strobe line
                    ora       #$02                ; high
                    sta       >PIA1DA
                    anda      #$FD                ; and low again
                    sta       >PIA1DA
                    puls      pc,cc               ; restore and return

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
GetStat
                    cmpa      #$01
                    bne       L008A
L0088               clrb
                    rts

L008A               cmpa      #$06
                    beq       L0088
*
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
SetStat
                    comb
                    ldb       #$D0
                    rts
*
* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*

Term                rts

                    emod
eom                 equ       *
                    end
