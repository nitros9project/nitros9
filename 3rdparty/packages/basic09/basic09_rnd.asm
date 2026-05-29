* Random number function
                   ifeq      INCLUDED&EDITOR
RNDFNC               clra
                    clrb
                   else
                    ifne      H6309
RNDFNC               clrd
                    else
RNDFNC               clra
                    clrb
                    endc
                   endc
                    std       <u004C
                    std       <u004E
                    pshs      a
                    lda       $02,y
                    beq       L4DFC
                    ldb       $05,y
                    bitb      #$01
                    bne       RMOVE
                    com       ,s
                    bra       L4DFC

RMOVE               addb      #$FE
                    addb      $01,y
                    lda       $04,y
                    std       <u0052
                    ldd       $02,y
                    std       <u0050
L4DFC               lda       <u0053
                    ldb       <u0057
                    mul
                    std       <u004E
                    lda       <u0052
                    ldb       <u0057
                    mul
                    addd      <u004D
                    bcc       L4E0E
                    inc       <u004C
L4E0E               std       <u004D
                    lda       <u0053
                    ldb       <u0056
                    mul
                    addd      <u004D
                    bcc       L4E1B
                    inc       <u004C
L4E1B               std       <u004D
                    lda       <u0051
                    ldb       <u0057
                    mul
                    addd      <u004C
                    std       <u004C
                    lda       <u0052
                    ldb       <u0056
                    mul
                    addd      <u004C
                    std       <u004C
                    lda       <u0053
                    ldb       <u0055
                    mul
                    addd      <u004C
                    std       <u004C
                    lda       <u0050
                    ldb       <u0057
                    mul
                    addb      <u004C
                    stb       <u004C
                    lda       <u0051
                    ldb       <u0056
                    mul
                    addb      <u004C
                    stb       <u004C
                    lda       <u0052
                    ldb       <u0055
                    mul
                    addb      <u004C
                    stb       <u004C
                    lda       <u0053
                    ldb       <u0054
                    mul
                    addb      <u004C
                    stb       <u004C
                    ldd       <u004E
                    addd      <u005A
                    std       <u0052
                    ldd       <u004C
                    adcb      <u0059
                    adca      <u0058
                    std       <u0050
                    tst       ,s+
                    bne       RND2
                    ldd       <u0050
                    std       $02,y
                    ldd       <u0052
                    std       $04,y
                    clr       $01,y
* Normalize the result
RNDNOR               lda       #$1F
                    pshs      a
                    ldd       $02,y
                    bmi       RNDNR2
FPDV30               dec       ,s
                    beq       RNDNR2
                    dec       $01,y
                    lsl       $05,y
                    rol       $04,y
                    rolb
                    rola
                    bpl       FPDV30
RNDNR2               std       $02,y
                    ldb       $05,y
                    andb      #$FE
                    stb       $05,y
                    puls      pc,b

RND2                ldd       <u0052
                    andb      #$FE
                    std       ,--y
                    ldd       <u0050
                    std       ,--y
                   ifeq      INCLUDED&EDITOR
                    clra
                    clrb
                   else
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                   endc
                    std       ,--y
                    bsr       RNDNOR
                   ifeq      INCLUDED&EDITOR
                    lbra      RLMUL
                   else
                    lbra      L40CC
                   endc
