**************************************************
* System Call: F$FreeHB
*
* Function: Get free high block
*
* Called from F$MapBlk and from SS.MpGPB)
*
* Input:  B = Block count
*         Y = DAT image pointer
*
* Output: A = High block number
*
* Error:  CC = C bit set; B = error code
*
FFreeHB             ldb       R$B,u               Get # blocks requested
                    ldy       R$Y,u               Get DAT Img ptr
                    bsr       L0A31               Go find free blocks in high part of DAT
L0A2C               bcs       L0A30               Couldn't find any, exit with error
                    sta       R$A,u               Save starting block #
L0A30               rts                           Return

L0A31               tfr       b,a                 Copy # blocks requested to A
* This gets called directly from within F$Link
L0A33               suba      #$09                Invert within 8
                    nega
                    pshs      x,d                 Save X, block # & block count
                    ldd       #$FFFF              -1'
L0A56               pshs      d

* Move to next block - SHOULD OPTIMIZE WITH W
L0A58               clra                          # free blocks found so far=0
                    ldb       2,s                 Get block #
                    addb      ,s                  Add block increment (point to next block)
                    stb       2,s                 Save new block # to check
                    cmpb      1,s                 Same as block count?
                    bne       L0A75               No, skip ahead
                    ldb       #E$MemFul           Preset error for 207 (Process mem full)
                    cmpy      <D.SysDAT           Is it the system process?
                    bne       L0A6C               No, exit with error 207
                    ldb       #E$NoRAM            System Mem full (237)
L0A6C               stb       3,s                 Save error code
                    comb                          set carry
                    bra       L0A82               Exit with error

L0A71               tfr       a,b                 Copy # blocks to B
                    addb      2,s                 Add to current start block #
L0A75               lslb                          Multiply block # by 2
                    ldx       b,y                 Get DAT marker for that block
                    cmpx      #DAT.Free           Empty block?
                    bne       L0A58               No, move to next block
                    inca                          Bump up # blocks free counter
                    cmpa      3,s                 Have we got enough?
                    bne       L0A71               No, keep looking
L0A82               leas      2,s                 Eat temporary stack
                    puls      d,x,pc              Restore reg, error code & return


* WHERE DOES THIS EVER GET CALLED FROM???
* Rodney says: "It's called via os9p1 syscall vector in line 393"
FSFreeLB            ldb       R$B,u               Get block count
                    ldy       R$Y,u               Get ptr to DAT Image
                    bsr       L0A4B               Go find block #'s
                    bra       L0A2C               Do error checking & exit (since never called,
* not worried about speed)

L0A4B               lda       #$FF                Value to start loop at block 0
                    pshs      x,d                 Preserve X,flag & block count
*         lda   #$01           # to add to go to next block (positive here)
                    nega                          -(-1)=+1
                    subb      #9                  Drop block count to -8 to -1 (invert within 8)
                    negb                          Negate so it is a positive # again
                    bra       L0A56               Go into main find loop


**************************************************
* System Call: F$FreeLB
*
* Function: Get free low block
*
* Input:  B = Block count
*         Y = DAT image pointer
*
* Output: A = Low block number
*
* Error:  CC = C bit set; B = error code
*
FFreeLB             ldd       R$D,u
                    ldx       R$X,u
                    ldu       R$U,u
L0A8C               pshs      d,x,y,u
                    leay      <P$DATImg,x
                    lsla
                    leay      a,y
                    ifne      H6309
                    clra
                    lslb
                    tfr       d,w
                    tfm       u+,y+
                    oim       #ImgChg,P$State,x
                    else
                    lslb
L0ALoop             lda       ,u+
                    sta       ,y+
                    decb
                    bne       L0ALoop
                    lda       P$State,x
                    ora       #ImgChg
                    sta       P$State,x
                    endc
                    clrb
                    puls      d,x,y,u,pc
