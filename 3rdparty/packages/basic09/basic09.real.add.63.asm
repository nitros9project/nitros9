* Add for REAL #'s - 6309 version
L3FB1               pshs      x                   Preserve X
                    tst       2,y                 1st byte of mantissa 0 (means value is 0)?
                    beq       L3FC7               Yes, eat temp var & leave other var alone
                    tst       8,y                 Is original # a 0?
                    bne       L3FCB               No, go do actual add
L3FBB               ldq       1,y                 Get Exponent & 1st 3 bytes of mantissa
                    stq       7,y                 Save in destination var space
                    lda       5,y                 Copy last byte of mantissa (sign bit) to orig var
                    sta       $B,y
L3FC7               leay      6,y                 Eat temp var & return
                    puls      pc,x

* Real add with non-zero values starts here
* NOTE: Exponents are 2^n, with n being the SIGNED exponent byte
L3FCB               lda       7,y                 Get 1st exponent
                    suba      1,y                 Calculate difference in exponents
                    bvc       L3FD5               Didn't exceed +127 or -128, skip ahead
                    bpl       L3FBB               Went too big on plus side, make temp var the answe
                    bra       L3FC7               Too small, eat temp var & leave answer alone

L3FD5               bmi       L3FDD               If negative difference in exponents, skip ahead
                    cmpa      #31                 Difference of exponents within 0-31?
                    ble       L3FE5               Yes, go deal with it
                    bra       L3FC7               >2^31, out of range so eat temp var & return

L3FDD               cmpa      #-31                Difference of exponents within -1 to -31?
                    blt       L3FBB               <2^-31, out of range so copy temp to answer
                    ldb       1,y                 ???Since negative difference, copy temp exponent
                    stb       7,y                 overtop destination exponent?
* As of this point, exponent in temp var no longer needed (A=difference in exp
L3FE5               ldb       $B,y                Get sign of dest. var
                    andb      #$01                Keep sign bit only
                    stb       ,y                  Save copy over var type
                    eorb      5,y                 EOR with sign bit of temp var
                    andb      #$01                Keep only merged sign bit
                    stb       1,y                 Save what resulting sign should be
*        aim   #$fe,$B,y    Force sign bit off on dest var
*        aim   #$fe,5,y     Force sign bit off on temp var
                    fcb       $62,$fe,$2b
                    fcb       $62,$fe,$25
                    tsta                          Are exponents exactly the same?
                    beq       L4031               Yes, skip ahead
                    bpl       L4029               Exponent difference positive, go process
* Exponent difference is a negative value
                    nega                          Force to positive
                    leax      6,y                 Point X to dest. var
                    bsr       L4082               Shift mantissa to match other value (into X:D)
                    tst       1,y                 Result going to be positive?
                    beq       L4039               Yes, skip ahead
L400B               subw      4,y                 Q=Q-[2,y]
                    sbcd      2,y
                    bcc       L404D               No borrow required, skip ahead
                    comw                          Do NEGQ
                    comd
                    addw      #1
                    adcd      #0
L4025               dec       ,y                  Drop exponent by 1
                    bra       L404D

* >24 bits to shift - Just use B, then clear a, tfr d to w, clrd
Shift24             beq       SkpSh24             Even byte, skip ahead
                    ldb       2,x                 Get MSB of # to shift
S24Lp               lsrb                          Shift it down
                    deca                          Until done
                    bne       S24Lp
                    tfr       d,w                 Copy to LSW
                    clrb                          Clear out MSW
                    rts

* Exactly 24 bits
SkpSh24             ldf       2,x                 Get LSB
                    clre                          Clear 2nd LSB
                    clrb                          Clear MS 24 bits (A=0 to get here)
                    rts

* Exponent difference is positive value
L4029               leax      ,y                  Point X to temp var
                    bsr       L4082               Shift mantissa to match other value
                    stq       2,y                 Save shifted result
* Equal exponents come here
L4031               ldq       8,y                 Get mantissa of dest var into Q
                    tst       1,y                 Check exponent of temp var
                    bne       L400B               <>0, go do Subtract again
L4039               addw      4,y                 32 bit add of Q+[2,y]
                    adcd      2,y
                    bcc       L404D               No overflow carry after add, skip ahead
                    rord                          Overflow, divide 32 bit mantissa by 2
                    rorw
                    inc       7,y                 Bump up exponent of dest var by 1
L404D               tsta                          Check sign of MSb of Q
                    bmi       L4060               Set, skip ahead
                    andcc     #^Carry             Force carry bit off (for ROLW since no LSLW)
L4050               dec       7,y                 Drop exponent of dest var by 1
                    bvc       L4054               Not underflowed, continue
                    puls      x                   Pull X back before zeroing out answer
                    bra       L40DD               Underflow; answer=0

L4054               rolw                          32 bit multiply by 2
                    rold
                    bpl       L4050               Keep doing until a set bit comes out
L4060               addw      #1                  Add 1 to Q
                    adcd      #0
                    bcc       L4071               No carry, skip ahead
                    rora
                    inc       7,y
L4071               std       8,y                 Save MSW of answer
                    tfr       w,d                 Move LSW to D
                    lsrb                          Eat sign bit
                    lslb
                    orb       ,y                  Put in sign of result
L407C               std       $A,y                Save LSW with sign bit
                    leay      6,y                 Eat temp var
                    puls      pc,x                Restore X & return

* Tested:WORKS
* ENTRY: A=ABS(difference between exponents) - will never be 0?
*        Y=Ptr to var packet 1
*        X=Ptr to var packet 2
* During: Q=32 bit mantissa
*        <u0014 = ABS difference of exponents
* Exit:  Q:32 bit shifted mantissa
L4082               suba      #24                 24-31 bit shift?
                    bge       Shift24             Yes, go process
                    adda      #8                  16-23 bit shift?
                    bge       Shift16             Yes, go process
                    adda      #8                  8-15 bit shift?
                    bge       Shift8              Yes, go process
                    adda      #8                  Restore 1-7 bit shift count
                    sta       <u0014              Save # of shifts required (1-7)
                    ldq       2,x                 Get # to shift
L40BD               lsrd                          Shift 32 bit # (worst case is 180 cycles)
                    rorw
                    dec       <u0014              Dec # shifts left to do
                    bne       L40BD               Keep doing until done
                    rts

* >15 bits to shift
Shift16             beq       SkpSh16             Even 2 bytes, go do
                    ldw       2,x                 Get MSW of # to shift
S16Lp               lsrw      Shift               it down (worst case is 90 cycles)
                    deca                          Until done
                    bne       S16Lp
                    clrb                          Clear MSW of Q (A=0 from dec loop)
                    rts

* Exactly 16 bits
SkpSh16             ldw       2,x                 Get LSW of Q
                    clrb
                    rts

* >7 bits to shift - Use B:W
Shift8              beq       SkpSh8              Exactly 8, use faster method
                    ldb       2,x                 Get LS 24 bits
                    ldw       3,x
S8Lp                lsrb                          Shift it down
                    rorw
                    deca
                    bne       S8Lp
                    rts

* Exactly 8 bits (A=0 to get here)
SkpSh8              ldb       2,x                 Get MSW of Q
                    ldw       3,x                 Get LSW of Q
                    rts
