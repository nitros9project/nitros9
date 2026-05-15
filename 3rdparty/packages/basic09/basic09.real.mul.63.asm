* Main routine for REAL multiply - 6309 version
* 08/07/95 - Change RmulZeroResult to use CLRD/CLRW/STQ (Saves 1 cycle)
*          - Changed entire routine as per Chris Dekker's RunB
* 08/08/95 - Took out PSHS/PULS X
RealMul               lda       2,y                 Get 1st byte of mantissa
                    bpl       RmulZeroResult               If mantissa is in lower range, force result to 0
                    lda       8,y                 Get 1st byte of mantissa from 2nd number
                    bmi       RmulChkOverflow               If in upper range, go do multiply
RmulZeroResult               clrd                          Force REAL result to 0
                    clrw
                    stq       7,y                 Save 0 as result
                    sta       $B,y
                    leay      6,y                 Eat temp var & return
                    rts

* Check for possible over/underflows before doing multiply
RmulChkOverflow               lda       1,y                 Get exponent from temp var
                    adda      7,y                 Add to exponent from 1st var
                    bvc       RmulDoProduct               If within 8 bit range, go do multiply
RmulExpError               bpl       RmulZeroResult               If resulting exponent is too small, result=0
                    comb                          Resulting exponent too big, exit with
                    ldb       #$32                Floating overflow error
                    rts

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
                    clre
                    clr       <RealShiftCnt              Clear out 3rd byte to keep track of
                    tfr       a,f                 Save MSB into middle byte
                    lda       $B,y                LSB * 2nd LSB
                    ldb       4,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       RmulProd1               No carry required, skip ahead
                    inc       <RealShiftCnt
RmulProd1               lda       $A,y                2nd LSB * LSB
                    ldb       5,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       RmulProd2
                    inc       <RealShiftCnt
RmulProd2               tfr       e,f
                    lde       <RealShiftCnt
                    clr       <RealShiftCnt
                    lda       $B,y
                    ldb       3,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       RmulProd3
                    inc       <RealShiftCnt
RmulProd3               lda       $A,y
                    ldb       4,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       RmulProd4
                    inc       <RealShiftCnt
RmulProd4               lda       9,y
                    ldb       5,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       RmulProd5
                    inc       <RealShiftCnt
RmulProd5               tfr       e,f
                    lde       <RealShiftCnt
                    clr       <RealShiftCnt
                    lda       $B,y
                    ldb       2,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       RmulProd6
                    inc       <RealShiftCnt
RmulProd6               lda       $A,y
                    ldb       $3,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       RmulProd7
                    inc       <RealShiftCnt
RmulProd7               lda       9,y
                    ldb       4,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       RmulProd8
                    inc       <RealShiftCnt
RmulProd8               lda       8,y
                    ldb       5,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       RmulProd9
                    inc       <RealShiftCnt
RmulProd9               stf       $B,y
                    tfr       e,f
                    lde       <RealShiftCnt
                    clr       <RealShiftCnt
                    lda       $A,y
                    ldb       2,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       RmulProdA
                    inc       <RealShiftCnt
RmulProdA               lda       9,y
                    ldb       3,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       RmulProdB
                    inc       <RealShiftCnt
RmulProdB               lda       8,y
                    ldb       4,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       RmulProdC
                    inc       <RealShiftCnt
RmulProdC               stf       $A,y
                    tfr       e,f
                    lde       <RealShiftCnt
                    clr       <RealShiftCnt
                    lda       9,y
                    ldb       2,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       RmulProdD
                    inc       <RealShiftCnt
RmulProdD               lda       8,y
                    ldb       3,y
                    mul
                    addr      d,w                 Add to previous #
                    bcc       RmulProdE
                    inc       <RealShiftCnt
RmulProdE               lda       8,y
                    ldb       2,y
                    mul
                    tfr       w,u
                    tfr       e,f
                    lde       <RealShiftCnt
                    exg       d,u
                    addr      u,w
                    bmi       RmulProdF
                    asl       $B,y
                    rol       $A,y
                    rolb
                    rolw
                    dec       7,y
                    bvs       RmulNorm1

RmulProdF               tfr       b,a
                    ldb       $A,y
                    exg       d,w
                    addw      #1
                    adcd      #0
                    bne       RmulNorm1
                    rora
                    inc       7,y
RmulNorm1               exg       d,w
                    lsrb                          Clear sign bit
                    lslb
                    orb       ,y                  Merge resultant sign bit
                    std       $A,y
                    stw       8,y
                    leay      6,y
                    clrb                          No error, restore & return
                    rts
