* Main routine for REAL multiply - 6309 version
* 08/07/95 - Change L40DD to use CLRD/CLRW/STQ (Saves 1 cycle)
*          - Changed entire routine as per Chris Dekker's RunB
* 08/08/95 - Took out PSHS/PULS X
L40D3               lda       2,y                 Get 1st byte of mantissa
                    bpl       L40DD               If mantissa is in lower range, force result to 0
                    lda       8,y                 Get 1st byte of mantissa from 2nd number
                    bmi       L40E9               If in upper range, go do multiply
L40DD               clrd                          Force REAL result to 0
                    clrw
                    stq       7,y                 Save 0 as result
                    sta       $B,y
                    leay      6,y                 Eat temp var & return
                    rts

* Check for possible over/underflows before doing multiply
L40E9               lda       1,y                 Get exponent from temp var
                    adda      7,y                 Add to exponent from 1st var
                    bvc       L40F6               If within 8 bit range, go do multiply
L40EF               bpl       L40DD               If resulting exponent is too small, result=0
                    comb                          Resulting exponent too big, exit with
                    ldb       #$32                Floating overflow error
                    rts

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
                    clre
                    clr       <u0014              Clear out 3rd byte to keep track of
                    tfr       a,f                 Save MSB into middle byte
                    lda       $B,y                LSB * 2nd LSB
                    ldb       4,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       L4120               No carry required, skip ahead
                    inc       <u0014
L4120               lda       $A,y                2nd LSB * LSB
                    ldb       5,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       L412D
                    inc       <u0014
L412D               tfr       e,f
                    lde       <u0014
                    clr       <u0014
                    lda       $B,y
                    ldb       3,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       L4142
                    inc       <u0014
L4142               lda       $A,y
                    ldb       4,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       L414F
                    inc       <u0014
L414F               lda       9,y
                    ldb       5,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       L415C
                    inc       <u0014
L415C               tfr       e,f
                    lde       <u0014
                    clr       <u0014
                    lda       $B,y
                    ldb       2,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       L4171
                    inc       <u0014
L4171               lda       $A,y
                    ldb       $3,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       L417E
                    inc       <u0014
L417E               lda       9,y
                    ldb       4,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       L418B
                    inc       <u0014
L418B               lda       8,y
                    ldb       5,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       L4198
                    inc       <u0014
L4198               stf       $B,y
                    tfr       e,f
                    lde       <u0014
                    clr       <u0014
                    lda       $A,y
                    ldb       2,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       L41AF
                    inc       <u0014
L41AF               lda       9,y
                    ldb       3,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       L41BC
                    inc       <u0014
L41BC               lda       8,y
                    ldb       4,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       L41C9
                    inc       <u0014
L41C9               stf       $A,y
                    tfr       e,f
                    lde       <u0014
                    clr       <u0014
                    lda       9,y
                    ldb       2,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       L41E0
                    inc       <u0014
L41E0               lda       8,y
                    ldb       3,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       L41ED
                    inc       <u0014
L41ED               lda       8,y
                    ldb       2,y
                    mul
                    tfr       w,u
                    tfr       e,f
                    lde       <u0014
                    exg       d,u
                    addr      u,w
                    bmi       L4202
                    asl       $B,y
                    rol       $A,y
                    rolb
                    rolw
                    dec       7,y
                    bvs       L421B

L4202               tfr       b,a
                    ldb       $A,y
                    exg       d,w
                    addw      #1
                    adcd      #0
                    bne       L421B
                    rora
                    inc       7,y
L421B               exg       d,w
                    lsrb                          Clear sign bit
                    lslb
                    orb       ,y                  Merge resultant sign bit
                    std       $A,y
                    stw       8,y
                    leay      6,y
                    clrb                          No error, restore & return
                    rts
