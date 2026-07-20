
CalcCRC
 clr CRCAcc,u
 clr CRCAcc+1,u     Clear CRC
 stx buffptr,u      Set pointer to start of buffer
 ldd #BlkLn-1
 std buffcnt,u      Initialize counter
crcloop
 ldx buffptr,u
 lda ,x+            Get next character
 stx buffptr,u      Increment pointer
 clrb
 eora CRCAcc,u
 eorb CRCAcc+1,u    Exclusive or
 std CRCAcc,u       Store it
 clr icount,u
 clr icount+1,u     Clear icount
forloop
 ldd CRCAcc,u
 anda #$80          Test hi bit
 clrb
 tfr d,y            Save result in y
 ldd CRCAcc,u       Shift CRC 1 bit left
 aslb
 rola
 cmpy #0
 lbeq NotHi         Check hi bit
 eora #$10          Hi bit set
 eorb #$21
NotHi
 std CRCAcc,u       Hi bit not set
 ldd icount,u       Get icount
 addd #1            Icrement
 std icount,u       Save icount
 cmpd #8            Is it 8 yet?
 lblt forloop       If not, do it again
 ldd buffcnt,u      Get buffcnt
 addd #-1           Decrement
 std buffcnt,u      Save it
 lbge crcloop       Loop if not less than 0 yet
Return
 ldd CRCAcc,u
 rts
