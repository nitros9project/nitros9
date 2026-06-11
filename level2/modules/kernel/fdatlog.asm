**************************************************
* System Call: F$DATLog
*
* Function: Convert DAT block/offset to logical address
*
* Input:  B = DAT image offset
*         X = Block offset
*
* Output: X = Logical address
*
* Error:  CC = C bit set; B = error code
*
FDATLog             ldb       R$B,u     ; get logical Block #
                    ldx       R$X,u     ; get offset into block
                    bsr       CmpLBlk   ; go modify X to be Logical address
                    stx       R$X,u     ; save in callers X register
                    clrb                ; no error & return
                    rts                 ; return to caller

* Compute logical address given B=Logical Block # & X=offset into block
* Exits with B being logical block & X=logical address
CmpLBlk             pshs      b         ; preserve logical block #
                    tfr       b,a       ; move log. block # to A
                    lsla                ; multiply logical block by 32
                    lsla                ; shift or rotate and update condition codes
                    lsla                ; shift or rotate and update condition codes
                    lsla                ; shift or rotate and update condition codes
                    lsla                ; shift or rotate and update condition codes
                    clrb                ; D=8k offset value
                  IFNE    H6309   ; begin conditional assembly for H6309
                    addr      d,x       ; X=logical address in 64k workspace
                  ELSE
                    leax      d,x       ; compute d,x into X
                  ENDC
                    puls      b,pc      ; restore A, block # & return
