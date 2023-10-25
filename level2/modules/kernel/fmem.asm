**************************************************
* System Call: F$Mem
*
* Function: Resize data memory area
*
* Input:  D = Desired memory area (in bytes)
*
* Output: Y = Address of new memory area upper bound
*         D = New memory area size in bytes
*
* Error:  CC = C bit set; B = error code
*
FMem                ldx       <D.Proc             get current process pointer
                    ldd       R$D,u               get requested memory size
                    beq       L0638               he wants current size, return it
                    addd      #$00FF              round up to nearest page
                    bcc       L05EE               no overflow, skip ahead
                    ldb       #E$MemFul           get mem full error
                    rts                           return

L05EE               cmpa      P$PagCnt,x          match current page count?
                    beq       L0638               yes, return it
                    pshs      a                   save page count
                    bhs       L0602               he's requesting more, skip ahead
                    deca                          subtract a page
                    ldb       #($100-R$Size)      get size of default stack - R$Size
                    cmpd      P$SP,x              shrinking it into stack?
                    bhs       L0602               no, skip ahead
                    ldb       #E$DelSP            get error code (223)
                    bra       L0627               return error
L0602               lda       P$PagCnt,x          get page count
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
L0615               lsrb                          divide by 32 to get block count
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
L0627               leas      1,s                 purge stack
L0629               orcc      #Carry              set carry for error
                    rts                           return

L062C               equ       *
                    ifne      H6309
                    addr      b,a
                    else
                    pshs      b
                    adda      ,s+
                    endc
                    negb
                    os9       F$DelImg
L0634               puls      a                   restore requested page count
                    sta       P$PagCnt,x          save it into process descriptor
L0638               lda       P$PagCnt,x          get page count
                    clrb                          clear LSB
                    std       R$D,u               save mem byte count to caller
                    std       R$Y,u               save memory upper limit to caller
                    rts                           return
