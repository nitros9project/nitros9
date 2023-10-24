* Disassembly by Os9disasm of stat.r

                    section   code

* OS-9 system function equates

I$GetStt            equ       $8d
I$SetStt            equ       $8e

getstat             pshs      y,u
                    lda       9,s
                    ldb       7,s
                    beq       L003c
                    cmpb      #1
                    beq       L003e
                    cmpb      #2
                    beq       L0024
                    cmpb      #5
                    beq       L0024
                    cmpb      #6
                    beq       L003e
                    cmpb      #$0e
                    beq       L003c
                    cmpb      #$0f
                    beq       L0039
                    ldb       #$d0
                    bra       L0029
L0024               os9       I$GetStt
                    bcc       L002e
L0029               puls      y,u
                    lbra      _os9err
L002e               stx       [10,s]
                    ldx       10,s
                    stu       2,x
                    clrb
                    clra
                    puls      y,u,pc
L0039               ldy       12,s
L003c               ldx       10,s
L003e               os9       I$GetStt
                    puls      y,u
                    lbra      _sysret
setstat             pshs      y,u
                    lda       9,s
                    ldb       7,s
                    beq       L0096
                    cmpb      #2
                    beq       L0094
                    cmpb      #3
                    beq       L0096
                    cmpb      #4
                    beq       L0091
                    cmpb      #$0a
                    beq       L00a6
                    cmpb      #$0b
                    beq       L0096
                    cmpb      #$0c
                    beq       L00a6
                    cmpb      #$0d
                    beq       L009a
                    cmpb      #$0f
                    beq       L0096
                    cmpb      #$10
                    beq       L0096
                    cmpb      #$11
                    beq       L0094
                    cmpb      #$14
                    beq       L0091
                    cmpb      #$15
                    beq       L0091
                    cmpb      #$19
                    beq       L0091
                    cmpb      #$1a
                    beq       L0096
                    cmpb      #$1b
                    beq       L00a6
                    ldb       #$d0
                    puls      y,u
                    lbra      _os9err
L0091               ldy       14,s
L0094               ldu       12,s
L0096               ldx       10,s
                    bra       L00a6
L009a               tfr       a,b
                    lda       11,s
                    ldx       12,s
                    ldy       14,s
                    ldu       16,s
L00a6               os9       I$SetStt
                    puls      y,u
                    lbra      _sysret

                    endsect

