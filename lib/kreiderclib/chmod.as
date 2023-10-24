* Disassembly by Os9disasm of chmod.r

                    section   code

* OS-9 system function equates

F$ID                equ       $0c
I$Open              equ       $84
I$GetStt            equ       $8d
I$SetStt            equ       $8e
I$Close             equ       $8f

chmod               pshs      y,u
                    leas      -16,s
                    bsr       L0035
                    bcs       L002d
                    pshs      a,y
                    os9       F$ID
                    cmpy      #0
                    beq       L001c
                    ldb       #$d6
                    cmpy      1,x
                    orcc      #1
                    bne       L002d
L001c               ldb       28,s
                    stb       ,x
                    puls      a,y
                    ldb       #$0f
                    os9       I$SetStt
                    bcs       L002d
                    os9       I$Close
L002d               leas      16,s
                    puls      y,u
                    lbra      _sysret
L0035               lda       #2
                    ldx       24,s
                    os9       I$Open
                    bcc       L0040
                    rts
L0040               leax      2,s
                    ldy       #$0010
                    ldb       #$0f
                    os9       I$GetStt
                    rts

                    endsect

