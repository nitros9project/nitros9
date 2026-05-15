* Add for REAL #'s - 6809 version
RealAdd               pshs      x                   Preserve X
                    tst       2,y                 1st byte of mantissa 0 (means value is 0)?
                    beq       RaEatTmpVar               Yes, eat temp var & leave other var alone
                    tst       8,y                 Is original # a 0?
                    bne       RaActualAdd               No, go do actual add
RaCopyTmpOrig               ldd       1,y                 Copy temp var's value overtop original var (0)
                    std       7,y
                    ldd       3,y
                    std       9,y
                    lda       5,y                 Copy last byte of mantissa (sign bit) to orig var
                    sta       $B,y
RaEatTmpVar               leay      6,y                 Eat temp var & return
                    puls      pc,x

* Real add with non-zero values starts here
* NOTE: Exponents are 2^n, with n being the SIGNED exponent byte
RaActualAdd               lda       7,y                 Get 1st exponent
                    suba      1,y                 Calculate difference in exponents
                    bvc       RaExpDiffPos               Didn't exceed +127 or -128, skip ahead
                    bpl       RaCopyTmpOrig               Went too big on plus side, make temp var the answe
                    bra       RaEatTmpVar               Too small, eat temp var & leave answer alone

RaExpDiffPos               bmi       RaExpDiffNeg               If negative difference in exponents, skip ahead
                    cmpa      #31                 Difference of exponents within 0-31?
                    ble       RaSetSignBits               Yes, go deal with it
                    bra       RaEatTmpVar               >2^31, out of range so eat temp var & return

RaExpDiffNeg               cmpa      #-31                Difference of exponents within -1 to -31?
                    blt       RaCopyTmpOrig               <2^-31, out of range so copy temp to answer
                    ldb       1,y                 ???Since negative difference, copy temp exponent
                    stb       7,y                 overtop destination exponent?
* As of this point, exponent in temp var no longer needed (A=difference in exp
RaSetSignBits               ldb       $B,y                Get sign of dest. var
                    andb      #$01                Keep sign bit only
                    stb       ,y                  Save copy over var type
                    eorb      5,y                 EOR with sign bit of temp var
                    andb      #$01                Keep only merged sign bit
                    stb       1,y                 Save what resulting sign should be
                    ldb       $B,y
                    andb      #$FE
                    stb       $B,y
                    ldb       5,y
                    andb      #$FE
                    stb       5,y
                    tsta                          Are exponents exactly the same?
                    beq       RaEqualExp               Yes, skip ahead
                    bpl       RaAlignPosExp               Exponent difference positive, go process
* Exponent difference is a negative value
                    nega                          Force to positive
                    leax      6,y                 Point X to dest. var
                    bsr       RaShiftMant               Shift mantissa to match other value (into X:D)
                    tst       1,y                 Result going to be positive?
                    beq       RaAddMant               Yes, skip ahead
RaSubMant               subd      4,y                 Essentially, X:D=X:D-(2,y)
                    exg       d,x
* This is essentially a sign reverse on 32 bit #?
                    sbcb      3,y
                    sbca      2,y
                    bcc       RaNormCheck               No borrow required, skip ahead
                    coma                          Compliment all 4 bytes
                    comb
                    exg       d,x
                    coma
                    comb
                    addd      #1                  +1
                    exg       d,x
                    bcc       RaDecExp               If no carry, skip ahead
                    addd      #1                  +1 to rest of 32 bit #
RaDecExp               dec       ,y                  Drop exponent by 1
                    bra       RaNormCheck

* Exponent difference is positive value
RaAlignPosExp               leax      ,y                  Point X to temp var
                    bsr       RaShiftMant               Shift mantissa to match other value (into X:D)
                    stx       2,y
                    std       4,y
* Equal exponents come here
RaEqualExp               ldx       8,y                 Get mantissa of dest var into X:D
                    ldd       $A,y
                    tst       1,y                 Check exponent of temp var
                    bne       RaSubMant               <>0, go process
RaAddMant               addd      4,y                 32 bit add of X:D + [2,y]
                    exg       d,x
                    adcb      3,y
                    adca      2,y
                    bcc       RaNormCheck               No overflow carry after add, skip ahead
                    rora                          Overflow, divide 32 bit mantissa by 2
                    rorb
                    exg       d,x
                    rora
                    rorb
                    inc       7,y                 Bump up exponent of dest var by 1
                    exg       d,x
RaNormCheck               tsta
                    bmi       RaNormRound
RaNormLoop               dec       7,y
                    lbvs      RmulZeroResult
                    exg       d,x
                    lslb
                    rola
                    exg       d,x
                    rolb
                    rola
                    bpl       RaNormLoop
RaNormRound               exg       d,x
                    addd      #1
                    exg       d,x
                    bcc       RaSaveResult
                    addd      #1
                    bcc       RaSaveResult
                    rora
                    inc       7,y
RaSaveResult               std       8,y
                    tfr       x,d
                    andb      #$FE                Mask out sign bit in mantissa (force to positive)
                    tst       ,y                  Result supposed to be negative?
                    beq       RaSaveSignMant               No, leave it alone
                    incb                          Set sign bit (negative result)
RaSaveSignMant               std       $A,y                Save LSW of mantissa
                    leay      6,y                 Eat temp var
                    puls      pc,x                Restore X & return

* Entry: A=ABS(difference between exponents)
*        Y=Ptr to temp var packet\ These could be swapped depending on whether
*        X=Ptr to dest var packet/ exponent difference is positive or negative
* Exit:  X:D is 32 bit shifted mantissa
RaShiftMant               suba      #16                 Subtract 16 from exponent difference (2 byte shift
                    blo       RaShift1Byte               Wrapped to negative, skip ahead
                    suba      #8                  Try subtracting 8 from it
                    blo       RaShift2Byte               Wrapped, go add it back in
* 3 byte minimum shift
                    sta       <RealShiftCnt              Save number of rotates needed after 3 byte move
                    clra                          D=High word of mantissa
                    ldb       2,x
                    bra       RaDoShift               Go get Low word of mantissa into X & process

* 2 byte minimum shift
RaShift2Byte               adda      #8                  Bump # shifts back up
                    sta       <RealShiftCnt              Save number of rotates needed
                    ldd       2,x                 D=
RaDoShift               ldx       #0
                    tst       <RealShiftCnt              Any shifts required?
                    bne       RaShiftLoop2               Yes, go do them
                    rts                           No, return

RaShift1Byte               adda      #8                  Add 8 back (back to 1 byte shift)
                    bhs       RaShiftFull               Still more left, skip ahead
                    sta       <RealShiftCnt
                    clra
                    ldb       2,x
                    ldx       3,x
                    tst       <RealShiftCnt              Any shifts to do?
                    bne       RaShiftLoop               Yes, go do
                    exg       d,x
                    rts

RaShiftFull               adda      #8                  Add 8 back again (back to original difference)
                    sta       <RealShiftCnt              Save # bit shifts needed
                    ldd       2,x                 Get 32 bit mantissa into D:X from dest var
                    ldx       4,x
                    bra       RaShiftLoop               Go perform shift

* NOTE: BY LOOKS OF IT MOST OF THESE D,X PAIRS CAN BE CHANGED TO D,W (Q) PAIRS
* ELIMINATING ALL THE EXCHANGES AND SPEEDING UP REAL CALCS BY QUITE A BIT
RaShiftLoop2               exg       d,x
RaShiftLoop               lsra
                    rorb
                    exg       d,x
                    rora
                    rorb
                    dec       <RealShiftCnt
                    bne       RaShiftLoop2
RaShiftDone               rts
