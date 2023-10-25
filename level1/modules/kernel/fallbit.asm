*******************************************************************************
* TurbOS
*******************************************************************************
* See LICENSE.txt for licensing information.
*******************************************************************************
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ----------------------------------------------------------------------------
*          2023/08/11  Boisy Pitre
* Initial creation.
*
*******************************************************************************

;;; F$AllBit
;;;
;;; Sets bits in an allocation bitmap.
;;;
;;; Entry:  D = The number of the first bit to set.
;;;         X = The address of the allocation bitmap.
;;;         Y = The number of the bits to set.
;;;
;;; Exit:   None.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$AllBit sets bits in the allocation bitmap. Bit numbers range from 0 to n-1, where n is the number of bits
;;; in the allocation bit map.
;;;
;;; Don't call F$AllBit with Y set to 0 (a bit count of 0).

FAllBit             ldd       R$D,u               get bit number to start with
                    leau      R$X,u               point U to the caller's R$X
                    pulu      y,x                 load caller's R$X and R$Y into X and Y in one call
AllocBit            pshs      y,x,b,a             preserve registers
                    bsr       CalcBit             calculate byte and position, and get first bit mask
                    tsta                          test the mask
                    pshs      a                   then preserve the mask on the stack
_mask@              set       0
                    bmi       whole@              branch if the hi-bit of the mask is set
                    lda       ,x                  else get the next byte in the bitmap
loop@               ora       _mask@,s            OR it with the mask on the stack
                    leay      -1,y                decrement the bits to set counter
                    beq       ex@                 branch if we're done
                    lsr       _mask@,s            else shift the mask on the stack to the right
                    bcc       loop@               branch if low bit on mask was 0
                    sta       ,x+                 save the updated byte with the appropriate bits set
whole@              tfr       y,d                 pass the current bit count to D
                    sta       _mask@,s            and save off the A as the mask
                    lda       #%11111111          load A with all new set of bits set
                    bra       loopstart@          and now set whole bytes at a time
loop2@              sta       ,x+                 save the updated byte with the appropriate bits set
loopstart@          subb      #$08                subtract 8 from B
                    bcc       loop2@              branch if B is >= 0
                    dec       _mask@,s            else decrement mask byte
                    bpl       loop2@              and branch if hi bit not set
loop3@              lsla                          divide A by 2
                    incb                          increment B
                    bne       loop3@              continue if B is not 0
                    ora       ,x                  OR A with value at X
ex@                 sta       ,x                  and store it at X
                    clra                          clear carry
                    leas      _mask@+1,s          fix stack
                    puls      pc,y,x,b,a          restore registers and return

* Calculate address of first byte we want, and which bit in that byte, from
* a bit allocation map given the address of the map & the bit # we want to point to.
*
* Entry: D = The bit number we want.
*        X = The pointer to the bitmap table.
*
* Exit:  A = A mask that has the bit number within byte we are starting on.
*        X = The pointer in allocation map to first byte we are starting on.
*
* Example 1:
* We want bit 18 starting at address 1024. Pass 18 to D and 1024 to X.
* We get back 128 in A (bit 7 set) and 1026 in D (the address of the bit).
*
* Example 2:
* We want bit 5 starting at address 3000. Pass 5 to D and 3000 to X.
* We get back 8 in A (bit 3 set) and 3000 in D (the address of the bit).

CalcBit             pshs      b                   preserve B
                    ifne      H6309
*>>>>>>>>>> H6309
                    lsrd                          divide D by 2
                    lsrd                          then divide D by 2 again
                    lsrd                          and again, now D = D / 8
                    addr      d,x                 get the address of the byte in the bitmap to start
*<<<<<<<<<< H6309
                    else
*>>>>>>>>>> M6809
                    lsra                          divide D
                    rorb                          by 2
                    lsra                          then divide D
                    rorb                          by 2
                    lsra                          and divide D
                    rorb                          again by 2, now D = D/8, which is the byte offset
                    leax      d,x                 get the address of the byte in the bitmap to start
*<<<<<<<<<< M6809
                    endc
                    puls      b                   recover B to compute the bit
                    lda       #$80                load A with hi bit set
                    andb      #%0000111           mask out all but the lower 3 bits (0-7, the bit number)
                    beq       ex@                 branch if 0 (the 0th bit)
loop@               lsra                          else right shift A
                    decb                          and decrement B (the bit counter)
                    bne       loop@               until B reaches 0
ex@                 rts                           return to the caller

;;; F$DelBit
;;;
;;; Clears bits in an allocation bitmap.
;;;
;;; Entry:  D = The number of the first bit to clear.
;;;         X = The address of the allocation bitmap.
;;;         Y = The number of the bits to clear.
;;;
;;; Exit:   None.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$DelBit clears bits in the allocation bitmap. Bit numbers range from 0 to n-1, where n is the number of bits
;;; in the allocation bit map.
;;;
;;; Don't call F$DelBit with Y set to 0 (a bit count of 0).

FDelBit             ldd       R$D,u               get bit number to start with
                    leau      R$X,u               point U to the address of the caller's register pointer
                    pulu      y,x                 load X/Y/U with this slick trick
DelBit              pshs      y,x,b,a             preserve registers
                    bsr       CalcBit             calculate byte and position, and get first bit mask
                    coma                          complement the mask
                    pshs      a                   then preserve the mask on the stack
_mask@              set       0
                    bpl       delstart@           branch if high bit in A is clear
                    lda       ,x                  get byte to clear bits of
loop@               anda      _mask@,s            AND with mask on stack
                    leay      -1,y                decrement the bits to clear counter
                    beq       ex@                 if zero, we're done, so return to caller
                    asr       _mask@,s            else shift right the mask byte on the stack (bit 7 remains constant, bit 0 goe sinto the carry)
                    bcs       loop@               and continue if carry set (bit 0 was 1 in the mask)
                    sta       ,x+                 else store the updated byte and increment to the next
delstart@           tfr       y,d                 transfer bit clear count from Y into D
                    bra       loopstart@          start the loop
loop2@              clr       ,x+                 clear this byte and move X to next
loopstart@          subd      #$0008              subtract 8 from the clear count
                    bhi       loop2@              branch if D > 0
                    beq       ex@                 branch if D = 0
loop3@              lsla                          shift A left one bit, filling LSB with 0
                    incb                          increment B
                    bne       loop3@              if not zero, keep shifting
                    coma                          complement A
                    anda      ,x                  and it with byte at X
ex@                 sta       ,x                  and store it
                    clr       ,s+                 eat the byte at the stack
                    puls      pc,y,x,b,a          pull remaining registers and return to the caller

;;; F$SchBit
;;;
;;; Searches the bitmap for a free area.
;;;
;;; Entry:  X = The address of the allocation bitmap.
;;;         D = The number of the first bit to start searching.
;;;         Y = The number of clear contiguous bits to search for.
;;;         U = The address of the end of the allocation bitmap
;;;
;;; Exit:   D = The starting bit number.
;;;         Y = The number of bits cleared.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$SchBit searches the specified allocation bit map for contiguous cleared bits of the required length. The search
;;; starts at the starting bit number. If no block of the specified size exists, the call returns with the carry set,
;;; starting bit number, and size of the largest block.

FSchBit             pshs      u                   save off caller's registers
                    ldd       R$D,u               get bit number to start with
                    ldx       R$X,u               get the address of allocation bit map
                    ldy       R$Y,u               get the number of cleared contiguous bits to search for
                    ldu       R$U,u               get the address of the end of the allocation map
                    bsr       SchBit              perform the search
                    puls      u                   recover the caller's registers
                    std       R$D,u               save the starting bit number in the caller's D
                    sty       R$Y,u               and the number of bits cleared at that point in caller's Y
                    rts                           return
SchBit              pshs      u,y,x,b,a           preserve registers
                    pshs      y,b,a               preserve more
_stk2A@             set       0
_stk2B@             set       1
_stk2Y@             set       2
_stk1A@             set       4
_stk1B@             set       5
_stk1X@             set       6
_stk1Y@             set       8
_stk1U@             set       10
                    clr       _stk1Y@,s
                    clr       _stk1Y@+1,s
                    tfr       d,y
                    bsr       CalcBit             calculate the bit location
                    pshs      a                   save the mask that points to bit number within byte we are starting on.
_stk3A@             set       0
_stk2A@             set       _stk2A@+1
_stk2B@             set       _stk2B@+1
_stk2Y@             set       _stk2Y@+1
_stk1A@             set       _stk1A@+1
_stk1B@             set       _stk1B@+1
_stk1X@             set       _stk1X@+1
_stk1Y@             set       _stk1Y@+1
_stk1U@             set       _stk1U@+1
                    bra       looptop@            start at the top of the loop
loop@               leay      1,y                 increment Y
                    sty       _stk1A@,s           save onto the stack
loop2@              lsr       _stk3A@,s           shift the byte on the stack right (bit 0 goes into carry)
                    bcc       looptop2@           branch if carry is clear (more to do)
                    ror       _stk3A@,s           else rotate right byte on stack
                    leax      1,x                 advance X by 1
looptop@            cmpx      _stk1U@,s           compare X to the end of the bitmap on the stack
                    bcc       loopout@            branch if equal (we're finished)
looptop2@           lda       ,x                  get the byte in the bitmap at X into A
                    anda      _stk3A@,s           AND with bit mask on stack
                    bne       loop@               branch if not zero
                    leay      $01,y               else advance Y by 1 byte
                    tfr       y,d                 transfer it to D
                    subd      _stk1A@,s           subract bit number to start with the on the stack from D
                    cmpd      _stk2Y@,s           compare to our counter
                    bcc       saveandex@          branch if equal
                    cmpd      _stk1Y@,s           compare against the number of bits cleared on the stack with D
                    bls       loop2@              branch if the value on the stack is lower or same as D
                    std       _stk1Y@,s           else save D into the number of bits cleared position on the stack
                    ldd       _stk1A@,s           get the bit number to start with on the stack into D
                    std       _stk2A@,s           save off into the next position on the stack
                    bra       loop2@              and continue working
loopout@            ldd       _stk2A@,s           get the next position on the stack
                    std       _stk1A@,s           store it
                    coma                          complement A
                    bra       ex@                 and prepare to return to the caller
saveandex@          std       _stk1Y@,s           get the number of bits cleared
ex@                 leas      _stk1A@,s           clean up the stack
                    puls      pc,u,y,x,b,a        restore registers and return to the caller
