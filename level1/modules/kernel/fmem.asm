;;; F$Mem
;;;
;;; Change the process' data area size.
;;;
;;; Entry:  D = The size to expand the memory area to (0 = return the current size).
;;;
;;; Exit:   Y = The address of the new memory area's upper bound.
;;;         D = The size of the new memory area, in bytes.
;;;        CC = Carry flag clear to indicate success.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$Mem expands or contracts the process’ data memory area to the specified size. If you specify zero as the new size,
;;; the current size and upper boundaries of data memory is returned.
;;; F$Mem rounds the size up to the next page boundary. Allocating additional memory continues upward from the previous
;;; highest address. Deallocating unneeded memory continues downward from that address.

                  IFEQ    Level-1 ; begin conditional assembly for Level-1

FMem                ldx       <D.Proc   ; get the current process descriptor
                    ldd       R$A,u     ; get the size of the requested memory area
                    beq       returnsize@ ; branch if 0
                    bsr       RoundUpD  ; round up requested memory area
                    subb      P$PagCnt,x ; subtract the current page count from B
                    beq       returnsize@ ; branch if 0
                    bcs       FMemProcessorState ; branch if less than 0
                    tfr       d,y       ; else transfer requested memory area to Y
                    ldx       P$ADDR,x  ; get the process' base data address page and page count in X
                    pshs      u,y,x     ; save off registers
_stkPageAddr@       set       0         ; define assembler symbol
_stkPageCnt@        set       1         ; define assembler symbol
_stkReqMem@         set       2         ; define assembler symbol
                    ldb       _stkPageAddr@,s ; get the page address from the stack
                    beq       FMemStartFreeMem ; branch if it's 0
                    addb      _stkPageCnt@,s ; add it to te page count from the stack
FMemStartFreeMem    ldx       <D.FMBM   ; get the address of the start of the free memory bitmap
                    ldu       <D.FMBM+2 ; and the address of the end of the free memory bitmap
                    os9       F$SchBit  ; search for the location
                    bcs       ex@       ; branch if there was an error
                    stb       _stkReqMem@,s ; save it the location to the stack
                    ldb       _stkPageAddr@,s ; load B from _stkPageAddr@,s
                    beq       FMemStkreqmem ; branch if zero is set to FMemStkreqmem
                    addb      _stkPageCnt@,s ; add _stkPageCnt@,s to B
                    cmpb      _stkReqMem@,s ; compare B with _stkReqMem@,s
                    bne       ex@       ; branch if zero is clear to ex@
FMemStkreqmem       ldb       _stkReqMem@,s ; load B from _stkReqMem@,s
                    os9       F$AllBit  ; allocate the bits
                    ldd       _stkReqMem@,s ; load D from _stkReqMem@,s
                    suba      _stkPageCnt@,s ; subtract _stkPageCnt@,s from A
                    addb      _stkPageCnt@,s ; add _stkPageCnt@,s to B
                    puls      u,y,x     ; restore u,y,x from the stack
                    ldx       <D.Proc   ; get the current process descriptor
                    bra       FUnlinkReturn ; branch unconditionally to FUnlinkReturn
FMemProcessorState  negb                ; update processor state
                    tfr       d,y       ; transfer register value d,y
                    negb                ; update processor state
                    addb      P$PagCnt,x ; add the page count
                    addb      P$ADDR,x  ; and the base data address page
                    cmpb      P$SP,x    ; compare it to the caller's stack pointer
                    bhi       FMemFreeMemBtmp ; branch if we're higher
                    comb                ; else set the carry flag
                    ldb       #E$DelSP  ; return an error indicating the requested size would overrun the stack
                    rts                 ; return to the caller
FMemFreeMemBtmp     ldx       <D.FMBM   ; get the free memory bitmap pointer
                    os9       F$DelBit  ; delete the bits
                    tfr       y,d       ; transfer register value y,d
                    negb                ; update processor state
                    ldx       <D.Proc   ; get the current process descriptor
                    addb      P$PagCnt,x ; add P$PagCnt,x to B
                    lda       P$ADDR,x  ; get the process' base data address page
FUnlinkReturn       std       P$ADDR,x  ; store the process' base data address page and page count
returnsize@         lda       P$PagCnt,x ; get the page count
                    clrb                ; clear B
                    std       R$D,u     ; save off the current memory area in the caller's D
                    adda      P$ADDR,x  ; add the address to A
                    std       R$Y,u     ; and store it to the caller's Y
                    rts                 ; return to the caller
ex@                 comb                ; set the carry flag
                    ldb       #E$MemFul ; indicate memory is full
                    puls      pc,u,y,x  ; restore registers and return to the caller

RoundUpD            addd      #$00FF    ; add 255 to D
                    clrb                ; clear B
                    exg       a,b       ; swap the registers
                    rts                 ; return to the caller

                  ELSE

FMem                ldx       <D.Proc   ; get current process pointer
                    ldd       R$D,u     ; get requested memory size
                    beq       FMemPageCount2 ; he wants current size, return it
                    addd      #$00FF    ; round up to nearest page
                    bcc       FMemMatchPageCount ; no overflow, skip ahead
                    ldb       #E$MemFul ; get mem full error
                    rts                 ; return

FMemMatchPageCount  cmpa      P$PagCnt,x ; match current page count?
                    beq       FMemPageCount2 ; yes, return it
                    pshs      a         ; save page count
                    bhs       FMemPageCount ; he's requesting more, skip ahead
                    deca                ; subtract a page
                    ldb       #($100-R$Size) ; get size of default stack - R$Size
                    cmpd      P$SP,x    ; shrinking it into stack?
                    bhs       FMemPageCount ; no, skip ahead
                    ldb       #E$DelSP  ; get error code (223)
                    bra       FMemPurge ; return error
FMemPageCount       lda       P$PagCnt,x ; get page count
                    adda      #$1F      ; round it up
                    lsra                ; divide by 32 to get block count
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    ldb       ,s        ; load B from ,s
                    addb      #$1F      ; add #$1F to B
                    bcc       FMemDvdByBlk ; still have room, skip ahead
                    ldb       #E$MemFul ; load B from #E$MemFul
                    bra       FMemPurge ; branch unconditionally to FMemPurge
FMemDvdByBlk        lsrb                ; divide by 32 to get block count
                    lsrb                ; shift or rotate and update condition codes
                    lsrb                ; shift or rotate and update condition codes
                    lsrb                ; shift or rotate and update condition codes
                    lsrb                ; shift or rotate and update condition codes
                  IFNE    H6309   ; begin conditional assembly for H6309
                    subr      a,b       same count?
                  ELSE
                    pshs      a         ; save a on the stack
                    subb      ,s+       ; subtract ,s+ from B
                  ENDC
                    beq       FMemReqPgCnt ; yes, save it
                    bcs       FMemJoin  ; overflow, delete the ram we just got
                    os9       F$AllImg  ; allocate the image in DAT
                    bcc       FMemReqPgCnt ; no error, skip ahead
FMemPurge           leas      1,s       ; purge stack
FMemCarryError      orcc      #Carry    ; set carry for error
                    rts                 ; return

FMemJoin            equ       *         ; define assembler symbol
                  IFNE    H6309   ; begin conditional assembly for H6309
                    addr      b,a       ; add b,a to R
                  ELSE
                    pshs      b         ; save b on the stack
                    adda      ,s+       ; add ,s+ to A
                  ENDC
                    negb                ; update processor state
                    os9       F$DelImg  ; call OS-9 service F$DelImg
FMemReqPgCnt        puls      a         ; restore requested page count
                    sta       P$PagCnt,x ; save it into process descriptor
FMemPageCount2      lda       P$PagCnt,x ; get page count
                    clrb                ; clear LSB
                    std       R$D,u     ; save mem byte count to caller
                    std       R$Y,u     ; save memory upper limit to caller
                    rts                 ; return

                  ENDC
