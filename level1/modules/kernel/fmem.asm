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

               ifeq      Level-1

FMem           ldx       <D.Proc             get the current process descriptor
               ldd       R$A,u               get the size of the requested memory area
               beq       returnsize@         branch if 0
               bsr       RoundUpD            round up requested memory area
               subb      P$PagCnt,x          subtract the current page count from B
               beq       returnsize@         branch if 0
               bcs       L0207               branch if less than 0
               tfr       d,y                 else transfer requested memory area to Y
               ldx       P$ADDR,x            get the process' base data address page and page count in X
               pshs      u,y,x               save off registers
_stkPageAddr@  set       0
_stkPageCnt@   set       1
_stkReqMem@    set       2
               ldb       _stkPageAddr@,s     get the page address from the stack
               beq       L01E1               branch if it's 0
               addb      _stkPageCnt@,s      add it to te page count from the stack
L01E1          ldx       <D.FMBM             get the address of the start of the free memory bitmap
               ldu       <D.FMBM+2           and the address of the end of the free memory bitmap
               os9       F$SchBit            search for the location
               bcs       ex@                 branch if there was an error
               stb       _stkReqMem@,s       save it the location to the stack
               ldb       _stkPageAddr@,s
               beq       L01F6
               addb      _stkPageCnt@,s
               cmpb      _stkReqMem@,s
               bne       ex@
L01F6          ldb       _stkReqMem@,s
               os9       F$AllBit            allocate the bits
               ldd       _stkReqMem@,s
               suba      _stkPageCnt@,s
               addb      _stkPageCnt@,s
               puls      u,y,x
               ldx       <D.Proc             get the current process descriptor
               bra       L0225
L0207          negb
               tfr       d,y
               negb
               addb      P$PagCnt,x          add the page count
               addb      P$ADDR,x            and the base data address page
               cmpb      P$SP,x              compare it to the caller's stack pointer
               bhi       L0217               branch if we're higher
               comb                          else set the carry flag
               ldb       #E$DelSP            return an error indicating the requested size would overrun the stack
               rts                           return to the caller
L0217          ldx       <D.FMBM             get the free memory bitmap pointer
               os9       F$DelBit            delete the bits
               tfr       y,d
               negb
               ldx       <D.Proc             get the current process descriptor
               addb      P$PagCnt,x
               lda       P$ADDR,x            get the process' base data address page
L0225          std       P$ADDR,x            store the process' base data address page and page count
returnsize@    lda       P$PagCnt,x          get the page count
               clrb                          clear B
               std       R$D,u               save off the current memory area in the caller's D
               adda      P$ADDR,x            add the address to A
               std       R$Y,u               and store it to the caller's Y
               rts                           return to the caller
ex@            comb                          set the carry flag
               ldb       #E$MemFul           indicate memory is full
               puls      pc,u,y,x            restore registers and return to the caller

RoundUpD       addd      #$00FF              add 255 to D
               clrb                          clear B
               exg       a,b                 swap the registers
               rts                           return to the caller

               else

FMem           ldx       <D.Proc             get current process pointer
               ldd       R$D,u               get requested memory size
               beq       L0638               he wants current size, return it
               addd      #$00FF              round up to nearest page
               bcc       L05EE               no overflow, skip ahead
               ldb       #E$MemFul           get mem full error
               rts                           return

L05EE          cmpa      P$PagCnt,x          match current page count?
               beq       L0638               yes, return it
               pshs      a                   save page count
               bhs       L0602               he's requesting more, skip ahead
               deca                          subtract a page
               ldb       #($100-R$Size)      get size of default stack - R$Size
               cmpd      P$SP,x              shrinking it into stack?
               bhs       L0602               no, skip ahead
               ldb       #E$DelSP            get error code (223)
               bra       L0627               return error
L0602          lda       P$PagCnt,x          get page count
               adda      #$1F                round it up
               lsra                          divide by 32 to get block count
               lsra
               lsra
               lsra
               lsra
               ldb       ,s
               addb      #$1F
               bcc       L0615               still have room, skip ahead
               ldb       #E$MemFul
               bra       L0627
L0615          lsrb                          divide by 32 to get block count
               lsrb
               lsrb
               lsrb
               lsrb
               ifne      H6309
               subr      a,b                 same count?
               else
               pshs      a
               subb      ,s+
               endc
               beq       L0634               yes, save it
               bcs       L062C               overflow, delete the ram we just got
               os9       F$AllImg            allocate the image in DAT
               bcc       L0634               no error, skip ahead
L0627          leas      1,s                 purge stack
L0629          orcc      #Carry              set carry for error
               rts                           return

L062C          equ       *
               ifne      H6309
               addr      b,a
               else
               pshs      b
               adda      ,s+
               endc
               negb
               os9       F$DelImg
L0634          puls      a                   restore requested page count
               sta       P$PagCnt,x          save it into process descriptor
L0638          lda       P$PagCnt,x          get page count
               clrb                          clear LSB
               std       R$D,u               save mem byte count to caller
               std       R$Y,u               save memory upper limit to caller
               rts                           return

               endc