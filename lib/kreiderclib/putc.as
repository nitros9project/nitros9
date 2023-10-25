* Disassembly by Os9disasm of putc.r

                    section   code

putc                pshs      u
                    ldu       6,s
                    ldd       6,u
                    anda      #$80
                    andb      #$22
                    cmpb      #2
                    bne       L0046
                    cmpa      #$80
                    beq       L0019
                    pshs      u
                    lbsr      _setbase
                    leas      2,s
L0019               ldd       6,u
                    andb      #4
                    beq       L004b
                    ldd       #1
                    pshs      d
                    leax      7,s
                    ldd       8,u
                    pshs      d,x
                    ldb       7,u
                    andb      #$40
                    beq       L0035
                    lbsr      writeln
                    bra       L0038
L0035               lbsr      write
L0038               leas      6,s
                    cmpd      #-1
                    bne       L0079
                    ldb       7,u
                    orb       #$20
                    stb       7,u
L0046               ldd       #-1
                    puls      u,pc
L004b               anda      #1
                    bne       L0058
                    pshs      u
                    lbsr      L00fd
                    std       ,s++
                    bne       L0046
L0058               ldx       ,u
                    ldb       5,s
                    stb       ,x+
                    stx       ,u
                    cmpx      4,u
                    bcc       L0070
                    ldb       7,u
                    andb      #$40
                    beq       L0079
                    ldb       5,s
                    cmpb      #$0d
                    bne       L0079
L0070               pshs      u
                    lbsr      L00fd
                    std       ,s++
                    bne       L0046
L0079               ldd       4,s
                    puls      u,pc
putw                pshs      u
                    ldu       6,s
                    ldb       4,s
                    pshs      d,u
                    lbsr      putc
                    ldb       9,s
                    stb       1,s
                    lbsr      putc
                    leas      4,s
                    puls      u,pc
_tidyup             pshs      u
                    leax      _iob,y
                    ldb       #$10
                    pshs      b
L009d               pshs      x
                    bsr       fclose
                    puls      x
                    leax      13,x
                    dec       ,s
                    bne       L009d
                    puls      b,u,pc
fclose              pshs      u
                    ldu       4,s
                    lbeq      L0046
                    ldd       6,u
                    lbeq      L0046
                    andb      #2
                    beq       L00c5
                    pshs      u
                    bsr       fflush
                    leas      2,s
                    bra       L00c7
L00c5               clra
                    clrb
L00c7               pshs      d
                    ldd       8,u
                    pshs      d
                    lbsr      close
                    leas      2,s
                    clra
                    clrb
                    std       6,u
                    puls      d,u,pc
fflush              pshs      u
                    ldu       4,s
                    lbeq      L0046
                    ldd       6,u
                    andb      #$22
                    cmpb      #2
                    lbne      L0046
                    anda      #$80
                    bne       L00f5
                    pshs      u
                    lbsr      _setbase
                    leas      2,s
L00f5               pshs      u
                    bsr       L00fd
                    leas      2,s
                    puls      u,pc
L00fd               pshs      u
                    ldu       4,s
                    leas      -4,s
                    lda       6,u
                    anda      #1
                    bne       L012c
                    ldd       ,u
                    cmpd      4,u
                    beq       L012c
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    lbsr      ftell
                    leas      2,s
                    ldd       2,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       8,u
                    pshs      d
                    lbsr      lseek
                    leas      8,s
L012c               ldd       ,u
                    subd      2,u
                    std       2,s
                    lbeq      L0194
                    ldd       6,u
                    anda      #1
                    lbeq      L0194
                    andb      #$40
                    beq       L016f
                    ldd       2,u
                    bra       L0167
L0146               pshs      d
                    ldd       ,u
                    pshs      d
                    ldd       8,u
                    pshs      d
                    lbsr      writeln
                    leas      6,s
                    std       ,s
                    cmpd      #-1
                    beq       L0185
                    ldd       2,s
                    subd      ,s
                    std       2,s
                    ldd       ,u
                    addd      ,s
L0167               std       ,u
                    ldd       2,s
                    bne       L0146
                    bra       L0194
L016f               ldd       2,s
                    pshs      d
                    ldd       2,u
                    pshs      d
                    ldd       8,u
                    pshs      d
                    lbsr      write
                    leas      6,s
                    cmpd      2,s
                    beq       L0194
L0185               ldb       7,u
                    orb       #$20
                    stb       7,u
                    ldd       4,u
                    std       ,u
                    ldd       #-1
                    bra       L01a4
L0194               lda       6,u
                    ora       #1
                    sta       6,u
                    ldd       2,u
                    std       ,u
                    addd      11,u
                    std       4,u
                    clra
                    clrb
L01a4               leas      4,s
                    puls      u,pc

                    endsect

