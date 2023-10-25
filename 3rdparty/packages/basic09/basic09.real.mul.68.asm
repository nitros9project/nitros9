* Main routine for REAL multiply - 6809 version
L40D3               pshs      x                   Preserve X
                    lda       2,y                 Get 1st byte of mantissa
                    bpl       L40DD               If mantissa is in lower range, force result to 0
                    lda       8,y                 Get 1st byte of mantissa from 2nd number
                    bmi       L40E9               If in upper range, go do multiply
L40DD               clra
                    clrb
                    std       7,y                 Save 0 as result
                    std       9,y
                    sta       $B,y
                    leay      6,y                 Eat temp var
                    puls      pc,x

* Check for possible over/underflows before doing multiply
L40E9               lda       1,y                 Get exponent from temp var
                    adda      7,y                 Add to exponent from 1st var
                    bvc       L40F6               If within 8 bit range, go do multiply
L40EF               bpl       L40DD               If resulting exponent is too small, result=0
                    comb                          Resulting exponent too big, exit with
                    ldb       #$32                Floating overflow error
                    puls      pc,x

* Exponent possibly in range, process
L40F6               sta       7,y                 Save resultant exponent overtop 1st vars
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
                    bcc       L4120               No carry required, skip ahead
                    inc       ,s
L4120               lda       $A,y                2nd LSB * LSB
                    ldb       5,y
                    mul
                    addd      1,s                 Add with carry to previous #
                    std       1,s
                    bcc       L412D
                    inc       ,s
L412D               ldx       ,s                  Done 16x8 multiply, now just keep MSW
                    stx       1,s
                    clr       ,s                  Zero out hi-byte in 3 byte #
                    lda       $B,y
                    ldb       3,y
                    mul
                    addd      1,s
                    std       1,s
                    bcc       L4142
                    inc       ,s
L4142               lda       $0A,y
                    ldb       $04,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L414F
                    inc       ,s
L414F               lda       $09,y
                    ldb       $05,y
                    mul
                    addd      1,s
                    std       1,s
                    bcc       L415C
                    inc       ,s
L415C               ldb       2,s
                    ldx       ,s
                    stx       1,s
                    clr       ,s
                    lda       $B,y
                    ldb       $2,y
                    mul
                    addd      1,s
                    std       1,s
                    bhs       L4171
                    inc       ,s
L4171               lda       $A,y
                    ldb       $3,y
                    mul
                    addd      1,s
                    std       1,s
                    bhs       L417E
                    inc       ,s
L417E               lda       9,y
                    ldb       4,y
                    mul
                    addd      1,s
                    std       1,s
                    bhs       L418B
                    inc       ,s
L418B               lda       $08,y
                    ldb       $05,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bhs       L4198
                    inc       ,s
L4198               ldb       $02,s
                    ldx       ,s
                    stx       $01,s
                    clr       ,s
                    stb       $0B,y
                    lda       $0A,y
                    ldb       $02,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L41AF
                    inc       ,s
L41AF               lda       $09,y
                    ldb       $03,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L41BC
                    inc       ,s
L41BC               lda       $08,y
                    ldb       $04,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L41C9
                    inc       ,s
L41C9               ldb       $02,s
                    ldx       ,s
                    stx       $01,s
                    clr       ,s
                    stb       $0A,y
                    lda       $09,y
                    ldb       $02,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L41E0
                    inc       ,s
L41E0               lda       $08,y
                    ldb       $03,y
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L41ED
                    inc       ,s
L41ED               lda       $08,y
                    ldb       $02,y
                    mul
                    addd      ,s
                    bmi       L4202
                    lsl       $0B,y
                    rol       $0A,y
                    rol       $02,s
                    rolb
                    rola
                    dec       7,y
                    bvs       L421B
L4202               std       8,y
                    lda       2,s
                    ldb       $A,y
                    addd      #$0001
                    bcc       L4220
                    inc       9,y
                    bne       L4222
                    inc       8,y
                    bne       L4222
                    ror       8,y
                    inc       7,y
                    bvc       L4222
L421B               leas      3,s
                    lbra      L40EF

L4220               andb      #$FE
L4222               orb       ,y
                    std       $A,y
                    leay      6,y
                    leas      3,s
                    clrb                          No error, restore & return
                    puls      pc,x
