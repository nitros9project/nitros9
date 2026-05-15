* Main routine for REAL multiply - 6809 version
RealMul               pshs      x                   Preserve X
                    lda       2,y                 Get 1st byte of mantissa
                    bpl       RmulZeroResult               If mantissa is in lower range, force result to 0
                    lda       8,y                 Get 1st byte of mantissa from 2nd number
                    bmi       RmulChkOverflow               If in upper range, go do multiply
RmulZeroResult               clra
                    clrb
                    std       7,y                 Save 0 as result
                    std       9,y
                    sta       $B,y
                    leay      6,y                 Eat temp var
                    puls      pc,x

* Check for possible over/underflows before doing multiply
RmulChkOverflow               lda       1,y                 Get exponent from temp var
                    adda      7,y                 Add to exponent from 1st var
                    bvc       RmulDoProduct               If within 8 bit range, go do multiply
RmulExpError               bpl       RmulZeroResult               If resulting exponent is too small, result=0
                    comb                          Resulting exponent too big, exit with
                    ldb       #$32                Floating overflow error
                    puls      pc,x

* Exponent possibly in range, process
RmulDoProduct               sta       7,y                 Save resultant exponent overtop 1st vars
                    ldb       $B,y                Get sign bit of 2nd #
                    eorb      5,y                 EOR with sign bit of 1st #
                    andb      #$01                Only keep resulting sign bit
                    stb       ,y                  Save what sign of result will be
                    lda       $B,y                Now, for actual multiply, force to positive
                    anda      #$FE
                    sta       $B,y
                    ldb       5,y                 Force both mantissa's to positive
                    andb      #$FE
                    stb       5,y
* Possible 32x32 bit multiply routine?
                    mul                           Multiply LSB's together
                    sta       ,-s                 Save MSB of result only (drop LSB)
                    clr       ,-s                 And make 2 zero hi-bytes (result is 3 byte #)
                    clr       ,-s
                    lda       $B,y                LSB * 2nd LSB
                    ldb       4,y
                    mul
                    addd      1,s                 Add to previous #
                    std       1,s
                    bcc       RmulProd1               No carry required, skip ahead
                    inc       ,s
RmulProd1               lda       $A,y                2nd LSB * LSB
                    ldb       5,y
                    mul
                    addd      1,s                 Add with carry to previous #
                    std       1,s
                    bcc       RmulProd2
                    inc       ,s
RmulProd2               ldx       ,s                  Done 16x8 multiply, now just keep MSW
                    stx       1,s
                    clr       ,s                  Zero out hi-byte in 3 byte #
                    lda       $B,y
                    ldb       3,y
                    mul
                    addd      1,s
                    std       1,s
                    bcc       RmulProd3
                    inc       ,s
RmulProd3               lda       $0A,y
                    ldb       $04,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       RmulProd4
                    inc       ,s
RmulProd4               lda       $09,y
                    ldb       $05,y
                    mul
                    addd      1,s
                    std       1,s
                    bcc       RmulProd5
                    inc       ,s
RmulProd5               ldb       2,s
                    ldx       ,s
                    stx       1,s
                    clr       ,s
                    lda       $B,y
                    ldb       $2,y
                    mul
                    addd      1,s
                    std       1,s
                    bhs       RmulProd6
                    inc       ,s
RmulProd6               lda       $A,y
                    ldb       $3,y
                    mul
                    addd      1,s
                    std       1,s
                    bhs       RmulProd7
                    inc       ,s
RmulProd7               lda       9,y
                    ldb       4,y
                    mul
                    addd      1,s
                    std       1,s
                    bhs       RmulProd8
                    inc       ,s
RmulProd8               lda       $08,y
                    ldb       $05,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bhs       RmulProd9
                    inc       ,s
RmulProd9               ldb       $02,s
                    ldx       ,s
                    stx       $01,s
                    clr       ,s
                    stb       $0B,y
                    lda       $0A,y
                    ldb       $02,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       RmulProdA
                    inc       ,s
RmulProdA               lda       $09,y
                    ldb       $03,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       RmulProdB
                    inc       ,s
RmulProdB               lda       $08,y
                    ldb       $04,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       RmulProdC
                    inc       ,s
RmulProdC               ldb       $02,s
                    ldx       ,s
                    stx       $01,s
                    clr       ,s
                    stb       $0A,y
                    lda       $09,y
                    ldb       $02,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       RmulProdD
                    inc       ,s
RmulProdD               lda       $08,y
                    ldb       $03,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       RmulProdE
                    inc       ,s
RmulProdE               lda       $08,y
                    ldb       $02,y
                    mul
                    addd      ,s
                    bmi       RmulProdF
                    lsl       $0B,y
                    rol       $0A,y
                    rol       $02,s
                    rolb
                    rola
                    dec       7,y
                    bvs       RmulNorm1
RmulProdF               std       8,y
                    lda       2,s
                    ldb       $A,y
                    addd      #$0001
                    bcc       RmulNorm2
                    inc       9,y
                    bne       RmulNorm3
                    inc       8,y
                    bne       RmulNorm3
                    ror       8,y
                    inc       7,y
                    bvc       RmulNorm3
RmulNorm1               leas      3,s
                    lbra      RmulExpError

RmulNorm2               andb      #$FE
RmulNorm3               orb       ,y
                    std       $A,y
                    leay      6,y
                    leas      3,s
                    clrb                          No error, restore & return
                    puls      pc,x
