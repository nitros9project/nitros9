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
FAllBit             ldd       R$D,u               get bit # to start with
                    ldx       R$X,u               get address of allocation bit map
                    bsr       CalcBit             calculate byte & position & get first bit mask
                    IFGT      Level-1
                    ldy       <D.Proc             get current task #
                    ldb       P$Task,y            get task number
                    bra       DoAllBit            go do it

* F$AllBit (System State)
FSAllBit            ldd       R$D,u               get bit # to start with
                    ldx       R$X,u               get address of allocation bit map
                    bsr       CalcBit             calculate byte & pos & get first bit mask
                    ldb       <D.SysTsk           Get system task #
                    ENDC

* Main bit setting loop
DoAllBit            equ       *
                    IFNE      H6309
                    ldw       R$Y,u               get # bits to set
                    ELSE
                    ldy       R$Y,u               get # bits to set
                    ENDC
                    beq       BitEx               nothing to set, return
                    sta       ,-s                 preserve current mask
                    bmi       SkpBit              If high bit set, skip ahead
                    IFGT      Level-1
                    os9       F$LDABX             go get original value from bit map
                    ELSE
                    lda       ,x
                    ENDC
NxtBitLp            ora       ,s                  OR it with the current mask
                    IFNE      H6309
                    decw                          dec the bit counter
                    ELSE
                    leay      -1,y
                    ENDC
                    beq       BitStEx             done, go put the byte back into the task's map
                    lsr       ,s                  shift out the lowest bit of original
                    bcc       NxtBitLp            if it is a 0, do next bit
                    IFGT      Level-1
                    os9       F$STABX             if it was a 1 (which means whole byte done),
                    ELSE
                    sta       ,x
                    ENDC
                    leax      1,x                 store finished byte and bump ptr
SkpBit              lda       #$FF                preload a finished byte
                    bra       SkpBit2             skip ahead

StFulByt            equ       *
                    IFGT      Level-1
                    os9       F$STABX             store full byte
                    ELSE
                    sta       ,x
                    ENDC
                    leax      1,x                 bump ptr up 1
                    IFNE      H6309
                    subw      #8                  bump counter down by 8
SkpBit2             cmpw      #8                  is there at least 8 more (a full byte) to do?
                    ELSE
                    leay      -8,y
SkpBit2             cmpy      #$0008
                    ENDC
                    bhi       StFulByt            more than 1, go do current
                    beq       BitStEx             exactly 1 byte left, do final store & exit

* Last byte: Not a full byte left loop
L085A               lsra                          bump out least sig. bit
                    IFNE      H6309
                    decw                          dec the bit counter
                    ELSE
                    leay      -1,y
                    ENDC
                    bne       L085A               keep going until last one is shifted out
                    coma                          invert byte to get proper result
                    sta       ,s                  preserve a sec
                    IFGT      Level-1
                    os9       F$LDABX             get byte for original map
                    ELSE
                    lda       ,x
                    ENDC
                    ora       ,s                  merge with new mask
BitStEx             equ       *
                    IFGT      Level-1
                    os9       F$STABX             store finished byte into task
                    ELSE
                    sta       ,x
                    ENDC
                    leas      1,s                 eat the working copy of the mask
BitEx               clrb                          no error & return
                    rts

* Calculate address of first byte we want, and which bit in that byte, from
*   a bit allocation map given the address of the map & the bit # we want to
*   point to
* Entry: D=Bit #
*        X=Ptr to bit mask table
* Exit:  A=Mask to point to bit # within byte we are starting on
*        X=Ptr in allocation map to first byte we are starting on
CalcBit             pshs      b,y                 preserve registers
                    IFNE      H6309
                    lsrd                          divide bit # by 8 to calculate byte # to start
                    lsrd                          allocating at
                    lsrd
                    addr      d,x                 offset that far into the map
                    ELSE
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    leax      d,x
                    ENDC
                    puls      b                   restore bit position LSB
                    leay      <MaskTbl,pc         point to mask table
                    andb      #7                  round it down to nearest bit
                    lda       b,y                 get bit mask
                    puls      y,pc                restore & return

* Bit position table (NOTE that bit #'s are done by left to right)
MaskTbl             fcb       $80,$40,$20,$10,$08,$04,$02,$01


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
FDelBit             ldd       R$D,u               get bit # to start with
                    ldx       R$X,u               get addr. of bit allocation map
                    bsr       CalcBit             point to starting bit
                    IFGT      Level-1
                    ldy       <D.Proc             get current Task #
                    ldb       P$Task,y            get task #
                    bra       DoDelBit            do rest of 0 bits

* F$DelBit entry point for system state
FSDelBit            ldd       R$D,u               get bit # to start with
                    ldx       R$X,u               get addr. of bit allocation map
                    bsr       CalcBit             point to starting bit
                    ldb       <D.SysTsk           get system task #
                    ENDC

DoDelBit            equ       *
                    IFNE      H6309
                    ldw       R$Y,u               get # bits to clear
                    ELSE
                    ldy       R$Y,u               get # bits to clear
                    ENDC
                    beq       L08E0               none, return
                    coma                          invert current bit mask
                    sta       ,-s                 preserve on stack
                    bpl       L08BC               if high bit clear, skip ahead
                    IFGT      Level-1
                    os9       F$LDABX             go get byte from user's map
                    ELSE
                    lda       ,x
                    ENDC
L08AD               anda      ,s                  AND it with current mask
                    IFNE      H6309
                    decw                          dec the bits left counter
                    ELSE
                    leay      -1,y
                    ENDC
                    beq       BitDone             done, store finished byte back in task's map
                    asr       ,s                  shift out lowest bit, leaving highest alone
                    bcs       L08AD               if it is a 1, do next bit
                    IFGT      Level-1
                    os9       F$STABX             if it was a 0 (which means whole byte done),
                    ELSE
                    sta       ,x
                    ENDC
                    leax      1,x                 store finished byte & inc. ptr
L08BC               clra                          preload a cleared byte
                    bra       ChkFull             skip ahead
L08BF               equ       *
                    IFGT      Level-1
                    os9       F$STABX             store full byte
                    ELSE
                    sta       ,x
                    ENDC
                    leax      1,x                 bump ptr up by 1
                    IFNE      H6309
                    subw      #8                  dec bits left counter by 8
ChkFull             cmpw      #8                  at least 1 full byte left?
                    ELSE
                    leay      -8,y
ChkFull             cmpy      #8
                    ENDC
                    bhi       L08BF               yes, do a whole byte in 1 shot
                    beq       BitDone             exactly 1, store byte & exit
                    coma                          < full byte left, invert bits
L08CF               lsra                          shift out rightmost bit
                    IFNE      H6309
                    decw                          dec bits left counter
                    ELSE
                    leay      -1,y
                    ENDC
                    bne       L08CF               keep doing till done
                    sta       ,s                  save finished mask
                    IFGT      Level-1
                    os9       F$LDABX             get original byte from task
                    ELSE
                    lda       ,x
                    ENDC
                    anda      ,s                  merge cleared bits with it
BitDone             equ       *
                    IFGT      Level-1
                    os9       F$STABX             store finished byte into task
                    ELSE
                    sta       ,x
                    ENDC
                    leas      1,s                 eat working copy of mask
L08E0               clrb                          eat error & return
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
FSchBit             ldd       R$D,u               get start bit #
                    ldx       R$X,u               get addr. of allocation bit map
                    bsr       CalcBit             point to starting bit
                    IFGT      Level-1
                    ldy       <D.Proc             get task #
                    ldb       P$Task,y
                    bra       DoSchBit            skip ahead

* F$SchBit entry point for system
FSSchBit            ldd       R$D,u               get start bit #
                    ldx       R$X,u               get addr. of allocation bit map
                    lbsr      CalcBit             point to starting bit
                    ldb       <D.SysTsk           get task #
* Stack: 0,s : byte we are working on (from original map)
*        1,s : Mask of which bit in current byte to start on
*        2,s : Task number the allocation bit map is in
*        3,s : Largest block found so far
*        5,s : Starting bit # of requested (or closest) size found
*        7,s : Starting bit # of current block being checked (2 bytes) (NOW IN Y)
                    ENDC
DoSchBit            equ       *
                    IFNE      H6309
                    pshs      cc,d,x,y            preserve task # & bit mask & reserve stack space
                    clrd                          faster than 2 memory clears
                    ELSE
                    pshs      cc,d,x,y,u          preserve task # & bit mask & reserve stack space
                    clra
                    clrb
                    ENDC
                    std       3,s                 preserve it
                    IFNE      H6309
                    ldw       R$D,u               get start bit #
                    tfr       w,y                 save as current block starting bit #
                    ELSE
                    ldy       R$D,u
                    sty       7,s
                    ENDC
                    bra       Skipper             skip ahead

* New start point for search at current location
RstSrch             equ       *
                    IFNE      H6309
                    tfr       w,y                 preserve current block bit # start
                    ELSE
                    sty       7,s
                    ENDC
* Move to next bit position, and to next byte if current byte is done
MoveBit             lsr       1,s                 move to next bit position
                    bcc       CheckBit            if not the last one, check it
                    ror       1,s                 move bit position marker to 1st bit again
                    leax      1,x                 move byte ptr (in map) to next byte

* Check if we are finished allocation map
Skipper             cmpx      R$U,u               done entire map?
                    bhs       BadNews             yes, couldn't fit in 1 block, notify caller
                    ldb       2,s                 get task number
                    IFGT      Level-1
                    os9       F$LDABX             get byte from bit allocation map
                    ELSE
                    lda       ,x
                    ENDC
                    sta       ,s                  preserve in scratch area

* Main checking
CheckBit            equ       *
                    IFNE      H6309
                    incw                          increment current bit #
                    ELSE
                    leay      1,y
                    ENDC
                    lda       ,s                  get current byte
                    anda      1,s                 mask out all but current bit position
                    bne       RstSrch             if bit not free, restart search from next bit
                    IFNE      H6309
                    tfr       w,d                 dup current bit # into D
                    subr      y,d                 calculate size we have free so far
                    ELSE
                    tfr       y,d
                    subd      7,s
                    ENDC
                    cmpd      R$Y,u               as big as user requested?
                    bhs       WereDone            yes, we are done
                    cmpd      $03,s               as big as the largest one we have found so far?
                    bls       MoveBit             no, move to next bit and keep going
                    std       $03,s               it is the largest, save current size
                    IFNE      H6309
                    sty       $05,s               save as start bit # of largest block found so far
                    ELSE
                    ldd       7,s
                    std       5,s
                    ENDC
                    bra       MoveBit             move to next bit and keep going

* Couldn't find requested size block; tell user where the closest was found
*   and how big it was
BadNews             ldd       $03,s               get size of largest block we found
                    std       R$Y,u               put into callers Y register
                    comb                          set carry to indicate we couldn't get full size
                    ldd       5,s                 get starting bit # of largest block we found
                    bra       BadSkip             skip ahead
* Found one, tell user where it is
WereDone            equ       *
                    IFNE      H6309
                    tfr       y,d                 get start bit # of the block we found
                    ELSE
                    ldd       7,s
                    ENDC
BadSkip             std       R$D,u               put starting bit # of block into callers D register
                    IFNE      H6309
                    leas      $07,s               eat our temporary stack area & return
                    ELSE
                    leas      $09,s
                    ENDC
                    rts
