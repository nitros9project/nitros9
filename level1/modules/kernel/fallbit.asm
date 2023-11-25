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

               ifeq      Level-1

FAllBit        ldd       R$D,u               get bit number to start with
               leau      R$X,u               point U to the caller's R$X
               pulu      y,x                 load caller's R$X and R$Y into X and Y in one call
AllocBit       pshs      y,x,b,a             preserve registers
               bsr       CalcBit             calculate byte and position, and get first bit mask
               tsta                          test the mask
               pshs      a                   then preserve the mask on the stack
_mask@         set       0
               bmi       whole@              branch if the hi-bit of the mask is set
               lda       ,x                  else get the next byte in the bitmap
loop@          ora       _mask@,s            OR it with the mask on the stack
               leay      -1,y                decrement the bits to set counter
               beq       ex@                 branch if we're done
               lsr       _mask@,s            else shift the mask on the stack to the right
               bcc       loop@               branch if low bit on mask was 0
               sta       ,x+                 save the updated byte with the appropriate bits set
whole@         tfr       y,d                 pass the current bit count to D
               sta       _mask@,s            and save off the A as the mask
               lda       #%11111111          load A with all new set of bits set
               bra       loopstart@          and now set whole bytes at a time
loop2@         sta       ,x+                 save the updated byte with the appropriate bits set
loopstart@     subb      #$08                subtract 8 from B
               bcc       loop2@              branch if B is >= 0
               dec       _mask@,s            else decrement mask byte
               bpl       loop2@              and branch if hi bit not set
loop3@         lsla                          divide A by 2
               incb                          increment B
               bne       loop3@              continue if B is not 0
               ora       ,x                  OR A with value at X
ex@            sta       ,x                  and store it at X
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

CalcBit        pshs      b                   preserve B
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
loop@          lsra                          else right shift A
               decb                          and decrement B (the bit counter)
               bne       loop@               until B reaches 0
ex@            rts                           return to the caller

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

FDelBit        ldd       R$D,u               get bit number to start with
               leau      R$X,u               point U to the address of the caller's register pointer
               pulu      y,x                 load X/Y/U with this slick trick
DelBit         pshs      y,x,b,a             preserve registers
               bsr       CalcBit             calculate byte and position, and get first bit mask
               coma                          complement the mask
               pshs      a                   then preserve the mask on the stack
_mask@         set       0
               bpl       delstart@           branch if high bit in A is clear
               lda       ,x                  get byte to clear bits of
loop@          anda      _mask@,s            AND with mask on stack
               leay      -1,y                decrement the bits to clear counter
               beq       ex@                 if zero, we're done, so return to caller
               asr       _mask@,s            else shift right the mask byte on the stack (bit 7 remains constant, bit 0 goe sinto the carry)
               bcs       loop@               and continue if carry set (bit 0 was 1 in the mask)
               sta       ,x+                 else store the updated byte and increment to the next
delstart@      tfr       y,d                 transfer bit clear count from Y into D
               bra       loopstart@          start the loop
loop2@         clr       ,x+                 clear this byte and move X to next
loopstart@     subd      #$0008              subtract 8 from the clear count
               bhi       loop2@              branch if D > 0
               beq       ex@                 branch if D = 0
loop3@         lsla                          shift A left one bit, filling LSB with 0
               incb                          increment B
               bne       loop3@              if not zero, keep shifting
               coma                          complement A
               anda      ,x                  and it with byte at X
ex@            sta       ,x                  and store it
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

FSchBit        pshs      u                   save off caller's registers
               ldd       R$D,u               get bit number to start with
               ldx       R$X,u               get the address of allocation bit map
               ldy       R$Y,u               get the number of cleared contiguous bits to search for
               ldu       R$U,u               get the address of the end of the allocation map
               bsr       SchBit              perform the search
               puls      u                   recover the caller's registers
               std       R$D,u               save the starting bit number in the caller's D
               sty       R$Y,u               and the number of bits cleared at that point in caller's Y
               rts                           return
SchBit         pshs      u,y,x,b,a           preserve registers
               pshs      y,b,a               preserve more
_stk2A@        set       0
_stk2B@        set       1
_stk2Y@        set       2
_stk1A@        set       4
_stk1B@        set       5
_stk1X@        set       6
_stk1Y@        set       8
_stk1U@        set       10
               clr       _stk1Y@,s
               clr       _stk1Y@+1,s
               tfr       d,y
               bsr       CalcBit             calculate the bit location
               pshs      a                   save the mask that points to bit number within byte we are starting on.
_stk3A@        set       0
_stk2A@        set       _stk2A@+1
_stk2B@        set       _stk2B@+1
_stk2Y@        set       _stk2Y@+1
_stk1A@        set       _stk1A@+1
_stk1B@        set       _stk1B@+1
_stk1X@        set       _stk1X@+1
_stk1Y@        set       _stk1Y@+1
_stk1U@        set       _stk1U@+1
               bra       looptop@            start at the top of the loop
loop@          leay      1,y                 increment Y
               sty       _stk1A@,s           save onto the stack
loop2@         lsr       _stk3A@,s           shift the byte on the stack right (bit 0 goes into carry)
               bcc       looptop2@           branch if carry is clear (more to do)
               ror       _stk3A@,s           else rotate right byte on stack
               leax      1,x                 advance X by 1
looptop@       cmpx      _stk1U@,s           compare X to the end of the bitmap on the stack
               bcc       loopout@            branch if equal (we're finished)
looptop2@      lda       ,x                  get the byte in the bitmap at X into A
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
loopout@       ldd       _stk2A@,s           get the next position on the stack
               std       _stk1A@,s           store it
               coma                          complement A
               bra       ex@                 and prepare to return to the caller
saveandex@     std       _stk1Y@,s           get the number of bits cleared
ex@            leas      _stk1A@,s           clean up the stack
               puls      pc,u,y,x,b,a        restore registers and return to the caller

               else

**************************************************
* System Call: F$AllBit
*
* Function: Sets bits in an allocation bitmap
*
* Input:  X = Address of allocation bitmap
*         D = Number of first bit to set
*         Y = Bit count (number of bits to set)
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FAllBit  ldd   R$D,u        get bit # to start with
         ldx   R$X,u        get address of allocation bit map
         bsr   CalcBit      calculate byte & position & get first bit mask
         IFGT  Level-1
         ldy   <D.Proc      get current task #
         ldb   P$Task,y     get task number
         bra   DoAllBit     go do it

* F$AllBit (System State)
FSAllBit ldd   R$D,u        get bit # to start with
         ldx   R$X,u        get address of allocation bit map
         bsr   CalcBit      calculate byte & pos & get first bit mask
         ldb   <D.SysTsk    Get system task #
         ENDC

* Main bit setting loop
DoAllBit equ   *
         IFNE  H6309
         ldw   R$Y,u        get # bits to set
         ELSE
         ldy   R$Y,u        get # bits to set
         ENDC
         beq   BitEx        nothing to set, return
         sta   ,-s          preserve current mask
         bmi   SkpBit       If high bit set, skip ahead
         IFGT  Level-1
         os9   F$LDABX      go get original value from bit map
         ELSE
         lda   ,x
         ENDC
NxtBitLp ora   ,s           OR it with the current mask
         IFNE  H6309
         decw               dec the bit counter
         ELSE
         leay  -1,y
         ENDC
         beq   BitStEx      done, go put the byte back into the task's map
         lsr   ,s           shift out the lowest bit of original
         bcc   NxtBitLp     if it is a 0, do next bit
         IFGT  Level-1
         os9   F$STABX      if it was a 1 (which means whole byte done),
         ELSE
         sta   ,x
         ENDC
         leax  1,x          store finished byte and bump ptr
SkpBit   lda   #$FF         preload a finished byte
         bra   SkpBit2      skip ahead

StFulByt equ   *
         IFGT  Level-1
         os9   F$STABX      store full byte
         ELSE
         sta   ,x
         ENDC
         leax  1,x          bump ptr up 1
         IFNE  H6309
         subw  #8           bump counter down by 8
SkpBit2  cmpw  #8           is there at least 8 more (a full byte) to do?
         ELSE
         leay  -8,y
SkpBit2  cmpy  #$0008
         ENDC
         bhi   StFulByt     more than 1, go do current
         beq   BitStEx      exactly 1 byte left, do final store & exit

* Last byte: Not a full byte left loop
L085A    lsra               bump out least sig. bit
         IFNE  H6309
         decw               dec the bit counter
         ELSE
         leay  -1,y
         ENDC
         bne   L085A        keep going until last one is shifted out
         coma               invert byte to get proper result
         sta   ,s           preserve a sec
         IFGT  Level-1
         os9   F$LDABX      get byte for original map
         ELSE
         lda   ,x
         ENDC
         ora   ,s           merge with new mask
BitStEx  equ   *
         IFGT  Level-1
         os9   F$STABX      store finished byte into task
         ELSE
         sta   ,x
         ENDC
         leas  1,s          eat the working copy of the mask
BitEx    clrb               no error & return
         rts

* Calculate address of first byte we want, and which bit in that byte, from
*   a bit allocation map given the address of the map & the bit # we want to
*   point to
* Entry: D=Bit #
*        X=Ptr to bit mask table
* Exit:  A=Mask to point to bit # within byte we are starting on
*        X=Ptr in allocation map to first byte we are starting on
CalcBit  pshs  b,y          preserve registers
         IFNE  H6309
         lsrd               divide bit # by 8 to calculate byte # to start
         lsrd               allocating at
         lsrd
         addr  d,x          offset that far into the map
         ELSE
         lsra
         rorb
         lsra
         rorb
         lsra
         rorb
         leax  d,x
         ENDC
         puls  b            restore bit position LSB
         leay  <MaskTbl,pc  point to mask table
         andb  #7           round it down to nearest bit
         lda   b,y          get bit mask
         puls  y,pc         restore & return

* Bit position table (NOTE that bit #'s are done by left to right)
MaskTbl  fcb   $80,$40,$20,$10,$08,$04,$02,$01


**************************************************
* System Call: F$DelBit
*
* Function: Clears bits in an allocation bitmap
*
* Input:  X = Address of allocation bitmap
*         D = Number of first bit to clear
*         Y = Bit count (number of bits to clear)
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FDelBit  ldd   R$D,u        get bit # to start with
         ldx   R$X,u        get addr. of bit allocation map
         bsr   CalcBit      point to starting bit
         IFGT  Level-1
         ldy   <D.Proc      get current Task #
         ldb   P$Task,y     get task #
         bra   DoDelBit     do rest of 0 bits

* F$DelBit entry point for system state
FSDelBit ldd   R$D,u        get bit # to start with
         ldx   R$X,u        get addr. of bit allocation map
         bsr   CalcBit      point to starting bit
         ldb   <D.SysTsk    get system task #
         ENDC

DoDelBit equ   *
         IFNE  H6309
         ldw   R$Y,u        get # bits to clear
         ELSE
         ldy   R$Y,u        get # bits to clear
         ENDC
         beq   L08E0        none, return
         coma               invert current bit mask
         sta   ,-s          preserve on stack
         bpl   L08BC        if high bit clear, skip ahead
         IFGT  Level-1
         os9   F$LDABX      go get byte from user's map
         ELSE
         lda   ,x
         ENDC
L08AD    anda  ,s           AND it with current mask
         IFNE  H6309
         decw               dec the bits left counter
         ELSE
         leay  -1,y
         ENDC
         beq   BitDone      done, store finished byte back in task's map
         asr   ,s           shift out lowest bit, leaving highest alone
         bcs   L08AD        if it is a 1, do next bit
         IFGT  Level-1
         os9   F$STABX      if it was a 0 (which means whole byte done),
         ELSE
         sta   ,x
         ENDC
         leax  1,x          store finished byte & inc. ptr
L08BC    clra               preload a cleared byte
         bra   ChkFull      skip ahead
L08BF    equ   *
         IFGT  Level-1
         os9   F$STABX      store full byte
         ELSE
         sta   ,x
         ENDC
         leax  1,x          bump ptr up by 1
         IFNE  H6309
         subw  #8           dec bits left counter by 8
ChkFull  cmpw  #8           at least 1 full byte left?
         ELSE
         leay  -8,y
ChkFull  cmpy  #8
         ENDC
         bhi   L08BF        yes, do a whole byte in 1 shot
         beq   BitDone      exactly 1, store byte & exit
         coma               < full byte left, invert bits
L08CF    lsra               shift out rightmost bit
         IFNE  H6309
         decw               dec bits left counter
         ELSE
         leay  -1,y
         ENDC
         bne   L08CF        keep doing till done
         sta   ,s           save finished mask
         IFGT  Level-1
         os9   F$LDABX      get original byte from task
         ELSE
         lda   ,x
         ENDC
         anda  ,s           merge cleared bits with it
BitDone  equ   *
         IFGT  Level-1
         os9   F$STABX      store finished byte into task
         ELSE
         sta   ,x
         ENDC
         leas  1,s          eat working copy of mask
L08E0    clrb               eat error & return
         rts


**************************************************
* System Call: F$SchBit
*
* Function: Search bitmap for a free area
*
* Input:  X = Address of allocation bitmap
*         D = Starting bit number
*         Y = Bit count (free bit block size)
*         U = Address of end of allocation bitmap
*
* Output: D = Beginning bit number
*         Y = Bit count
*
* Error:  CC = C bit set; B = error code
*
FSchBit  ldd   R$D,u        get start bit #
         ldx   R$X,u        get addr. of allocation bit map
         bsr   CalcBit      point to starting bit
         IFGT  Level-1
         ldy   <D.Proc      get task #
         ldb   P$Task,y
         bra   DoSchBit     skip ahead

* F$SchBit entry point for system
FSSchBit ldd   R$D,u        get start bit #
         ldx   R$X,u        get addr. of allocation bit map
         lbsr  CalcBit      point to starting bit
         ldb   <D.SysTsk    get task #
* Stack: 0,s : byte we are working on (from original map)
*        1,s : Mask of which bit in current byte to start on
*        2,s : Task number the allocation bit map is in
*        3,s : Largest block found so far
*        5,s : Starting bit # of requested (or closest) size found
*        7,s : Starting bit # of current block being checked (2 bytes) (NOW IN Y)
         ENDC
DoSchBit equ  *
         IFNE  H6309
         pshs  cc,d,x,y     preserve task # & bit mask & reserve stack space
         clrd               faster than 2 memory clears
         ELSE
         pshs  cc,d,x,y,u   preserve task # & bit mask & reserve stack space
         clra
         clrb
         ENDC
         std   3,s          preserve it
         IFNE  H6309
         ldw   R$D,u        get start bit #
         tfr   w,y          save as current block starting bit #
         ELSE
         ldy   R$D,u
         sty   7,s
         ENDC
         bra   Skipper      skip ahead

* New start point for search at current location
RstSrch  equ   *
         IFNE  H6309
         tfr   w,y          preserve current block bit # start
         ELSE
         sty   7,s
         ENDC
* Move to next bit position, and to next byte if current byte is done
MoveBit  lsr   1,s          move to next bit position
         bcc   CheckBit     if not the last one, check it
         ror   1,s          move bit position marker to 1st bit again
         leax  1,x          move byte ptr (in map) to next byte

* Check if we are finished allocation map
Skipper  cmpx  R$U,u        done entire map?
         bhs   BadNews      yes, couldn't fit in 1 block, notify caller
         ldb   2,s          get task number
         IFGT  Level-1
         os9   F$LDABX      get byte from bit allocation map
         ELSE
         lda   ,x
         ENDC
         sta   ,s           preserve in scratch area

* Main checking
CheckBit equ   *
         IFNE  H6309
         incw               increment current bit #
         ELSE
         leay  1,y
         ENDC
         lda   ,s           get current byte
         anda  1,s          mask out all but current bit position
         bne   RstSrch      if bit not free, restart search from next bit
         IFNE  H6309
         tfr   w,d          dup current bit # into D
         subr  y,d          calculate size we have free so far
         ELSE
         tfr   y,d
         subd  7,s
         ENDC
         cmpd  R$Y,u        as big as user requested?
         bhs   WereDone     yes, we are done
         cmpd  $03,s        as big as the largest one we have found so far?
         bls   MoveBit      no, move to next bit and keep going
         std   $03,s        it is the largest, save current size
         IFNE  H6309
         sty   $05,s        save as start bit # of largest block found so far
         ELSE
         ldd   7,s
         std   5,s
         ENDC
         bra   MoveBit      move to next bit and keep going

* Couldn't find requested size block; tell user where the closest was found
*   and how big it was
BadNews  ldd   $03,s        get size of largest block we found
         std   R$Y,u        put into callers Y register
         comb               set carry to indicate we couldn't get full size
         ldd   5,s          get starting bit # of largest block we found
         bra   BadSkip      skip ahead
* Found one, tell user where it is
WereDone equ   *
         IFNE  H6309
         tfr   y,d          get start bit # of the block we found
         ELSE
         ldd   7,s
         ENDC
BadSkip  std   R$D,u        put starting bit # of block into callers D register
         IFNE  H6309
         leas  $07,s        eat our temporary stack area & return
         ELSE
         leas  $09,s
         ENDC
         rts

               endc