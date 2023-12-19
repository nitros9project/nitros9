**************************************************
* System Call: F$CRCMod
*
* Function: Changes CRC module reporting
*
* Input:  A = Flag (0 = report, 1 = CRC off, 2 = CRC on)
*
* Output: A = State (0 = CRC off, 1 = CRC on)
*
* Error:  CC = C bit set; B = error code
*
FCRCMod             lda       R$A,u               do they want a report or a toggle?
                    beq       CRCRep              a report only
                    deca                          check for OFF
                    bne       GoCRCon             no, must be on
                    fcb       $8C                 skip 2 bytes, saves 3 bytes of memory
GoCRCon             lda       #$1                 CRC checking on
                    sta       <D.CRC              turn CRC checking on
CRCRep              lda       <D.CRC              get current CRC flag for return
CRCRep2             sta       R$A,u               save it to their register stack
                    clrb                          no error
                    rts                           and exit
