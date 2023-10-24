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

FMem                ldx       <D.Proc             get the current process descriptor
                    ldd       R$A,u               get the size of the requested memory area
                    beq       returnsize@         branch if 0
                    bsr       RoundUpD            round up requested memory area
                    subb      P$PagCnt,x          subtract the current page count from B
                    beq       returnsize@         branch if 0
                    bcs       L0207               branch if less than 0
                    tfr       d,y                 else transfer requested memory area to Y
                    ldx       P$ADDR,x            get the process' base data address page and page count in X
                    pshs      u,y,x               save off registers
_stkPageAddr@       set       0
_stkPageCnt@        set       1
_stkReqMem@         set       2
                    ldb       _stkPageAddr@,s     get the page address from the stack
                    beq       L01E1               branch if it's 0
                    addb      _stkPageCnt@,s      add it to te page count from the stack
L01E1               ldx       <D.FMBM             get the address of the start of the free memory bitmap
                    ldu       <D.FMBM+2           and the address of the end of the free memory bitmap
                    os9       F$SchBit            search for the location
                    bcs       ex@                 branch if there was an error
                    stb       _stkReqMem@,s       save it the location to the stack
                    ldb       _stkPageAddr@,s
                    beq       L01F6
                    addb      _stkPageCnt@,s
                    cmpb      _stkReqMem@,s
                    bne       ex@
L01F6               ldb       _stkReqMem@,s
                    os9       F$AllBit            allocate the bits
                    ldd       _stkReqMem@,s
                    suba      _stkPageCnt@,s
                    addb      _stkPageCnt@,s
                    puls      u,y,x
                    ldx       <D.Proc             get the current process descriptor
                    bra       L0225
L0207               negb
                    tfr       d,y
                    negb
                    addb      P$PagCnt,x          add the page count
                    addb      P$ADDR,x            and the base data address page
                    cmpb      P$SP,x              compare it to the caller's stack pointer
                    bhi       L0217               branch if we're higher
                    comb                          else set the carry flag
                    ldb       #E$DelSP            return an error indicating the requested size would overrun the stack
                    rts                           return to the caller
L0217               ldx       <D.FMBM             get the free memory bitmap pointer
                    os9       F$DelBit            delete the bits
                    tfr       y,d
                    negb
                    ldx       <D.Proc             get the current process descriptor
                    addb      P$PagCnt,x
                    lda       P$ADDR,x            get the process' base data address page
L0225               std       P$ADDR,x            store the process' base data address page and page count
returnsize@         lda       P$PagCnt,x          get the page count
                    clrb                          clear B
                    std       R$D,u               save off the current memory area in the caller's D
                    adda      P$ADDR,x            add the address to A
                    std       R$Y,u               and store it to the caller's Y
                    rts                           return to the caller
ex@                 comb                          set the carry flag
                    ldb       #E$MemFul           indicate memory is full
                    puls      pc,u,y,x            restore registers and return to the caller

RoundUpD            addd      #$00FF              add 255 to D
                    clrb                          clear B
                    exg       a,b                 swap the registers
                    rts                           return to the caller
