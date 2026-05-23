**************************************************
* System Call: F$LDABX
*
* Function: Load A from 0,X in task B
*
* Input:  B = Task number
*         X = Data pointer
*
* Output: A = Data byte at 0,x in task's address space
*
* Error:  CC = C bit set; B = error code
*
FLDABX              ldb       R$B,u     ; get task # to get byte from
                    ldx       R$X,u     ; get offset into task's DAT image to get byte from

* Load a byte from another task
* Entry: B=Task #
*        X=Pointer to data
* Exit : B=Byte from other task
FLdabxTarget        pshs      cc,a,x,u  ; save cc,a,x,u on the stack
                    bsr       FMoveTaskImageTable ; calculate offset into DAT image (fmove.asm)
                    ldd       a,u       ; [NAC HACK 2017Jan25] why ldd when a is never used??
                    orcc      #IntMasks ; set condition-code bits using #IntMasks
                  IFNE    mc09    ; begin conditional assembly for mc09
                    lda       <D.TINIT  ; current MMU mask - selects block 0
                    sta       >MMUADR   ; select block 0

                    stb       >MMUDAT   ; map selected block into $0000-$1FFF
                    ldb       ,x        ; load B from ,x
                    clr       >MMUDAT   ; restore mapping at $0000-$1FFF
                  ELSE
                    stb       >DAT.Regs ; map block into $0000-$1FFF
                    ldb       ,x        ; load B from ,x
                    clr       >DAT.Regs ; restore mapping at $0000-$1FFF
                    endif
                    puls      cc,a,x,u  ; restore cc,a,x,u from the stack

                    stb       R$A,u     ; save into caller's A & return
                    clrb                ; set to no errors
                    rts                 ; return to caller

* Get pointer to task DAT image
* Entry: B=Task #
* Exit : U=Pointer to task image
*L0C09    ldu   <D.TskIPt    get pointer to task image table
*         lslb               multiply task # by 2
*         ldu   b,u          get pointer to task image (doesn't affect carry)
*         rts                restore & return


**************************************************
* System Call: F$STABX
*
* Function: Store A at 0,X in task B
*
* Input:  A = Data byte to store in task's address space
*         B = Task number
*         X = Logical address in task's address space
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FSTABX              ldd       R$D,u     ; load D from R$D,u
                    ldx       R$X,u     ; load X from R$X,u

* Store a byte in another task
* Entry: A=Byte to store
*        B=Task #
*        X=Pointer to data
FLdabxCarry         andcc     #^Carry   ; clear condition-code bits using #^Carry
                    pshs      cc,d,x,u  ; save cc,d,x,u on the stack
                    bsr       FMoveTaskImageTable ; calculate offset into DAT image (fmove.asm)
                    ldd       a,u       ; get memory block
                  IFNE    mc09    ; begin conditional assembly for mc09
                    orcc      #IntMasks ; set condition-code bits using #IntMasks
                    lda       <D.TINIT  ; current MMU mask - selects block 0
                    sta       >MMUADR   ; select block 0

                    lda       1,s       ; haven't lost stack yet so this is safe

                    stb       >MMUDAT   ; map selected block into $0000-$1FFF
                    sta       ,x        ; store A at ,x
                    clr       >MMUDAT   ; restore mapping at $0000-$1FFF
                  ELSE
                    lda       1,s       ; load A from 1,s
                    orcc      #IntMasks ; set condition-code bits using #IntMasks
                    stb       >DAT.Regs ; map selected block into $0000-$1FFF
                    sta       ,x        ; store A at ,x
                    clr       >DAT.Regs ; restore mapping at $0000-$1FFF
                    endif
                    puls      cc,d,x,u,pc ; restore cc,d,x,u,pc from the stack
