* Disassembly by Os9disasm of datmods.r

                    section   code

* OS-9 system function equates

F$Link              equ       $00
F$Load              equ       $01
F$UnLink            equ       $02

lockdata            ldx       2,s
                    pshs      cc
                    orcc      #$10
                    inc       ,x
                    beq       L001d
                    ldb       ,x
                    dec       ,x
L000e               sex
                    puls      cc,pc
unlkdata            ldx       2,s
                    pshs      cc
                    orcc      #$10
                    ldb       ,x
                    bne       L000e
                    dec       ,x
L001d               clra
                    clrb
                    puls      cc,pc
datlink             pshs      y,u
                    clr       ,-s
                    clr       ,-s
                    ldx       8,s
                    lda       #$40
                    os9       F$Link
                    bcc       L0045
                    cmpb      #$dd
                    beq       L003a
                    coma
L0035               puls      x,y,u
                    lbra      _os9err
L003a               ldx       8,s
                    lda       #$40
                    os9       F$Load
                    bcs       L0035
                    inc       1,s
L0045               pshs      y
                    tfr       u,d
                    subd      ,s++
                    std       ,y++
                    sty       [10,s]
                    addd      2,u
                    subd      #5
                    std       [12,s]
                    ldd       ,s
                    beq       L0067
                    pshs      y
                    bsr       lockdata
                    std       ,s++
                    beq       L0067
                    clr       1,s
L0067               puls      d,y,u,pc
dunlink             pshs      u
                    ldu       4,s
                    ldd       ,--u
                    leau      d,u
                    os9       F$UnLink
                    puls      u
                    lbra      _sysret

                    endsect

