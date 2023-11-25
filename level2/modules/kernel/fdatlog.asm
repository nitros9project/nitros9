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
FDATLog        ldb       R$B,u               Get logical Block #
               ldx       R$X,u               Get offset into block
               bsr       CmpLBlk             Go modify X to be Logical address
               stx       R$X,u               Save in callers X register
               clrb                          No error & return
               rts       

* Compute logical address given B=Logical Block # & X=offset into block
* Exits with B being logical block & X=logical address
CmpLBlk        pshs      b                   Preserve logical block #
               tfr       b,a                 Move log. block # to A
               lsla                          Multiply logical block by 32
               lsla      
               lsla      
               lsla      
               lsla      
               clrb                          D=8k offset value
               ifne      H6309
               addr      d,x                 X=logical address in 64k workspace
               else      
               leax      d,x
               endc      
               puls      b,pc                Restore A, block # & return
