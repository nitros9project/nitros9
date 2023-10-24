* Disassembly by Os9disasm of sleep.r

                    section   code

* OS-9 system function equates

F$ID                equ       $0c
F$SUser             equ       $1c
F$NMLink            equ       $21
L0025               equ       $25

L0000               fcb       $61
                    fcb       $62
                    fcb       $62
                    cmpb      <L0068,pcr
sleep               equ       *-2
                    bne       L000d
                    ldd       #1
                    bra       L003a
L000d               pshs      d
                    os9       L0025
                    bcc       L0037
                    clra
                    os9       F$ID
                    os9       F$SUser
                    bcc       L0022
                    ldd       #$000a
                    bra       L0037
L0022               leax      <L0000,pcr
                    clra
                    os9       F$NMLink
                    bcc       L0034
                    cmpb      #$d0
                    bne       L0034
                    ldd       #$0064
                    bra       L0037
L0034               ldd       #$003c
L0037               lbsr      ccmult
L003a               pshs      d
                    lbsr      tsleep
                    puls      x,pc

                    endsect

