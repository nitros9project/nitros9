**************************************************
* System Call: F$MapBlk
*
* Function: Map specific block
*
* Input:  B = Number of blocks
*         X = Beginning block number
*
* Output: U = Address of first block
*
* Error:  CC = C bit set; B = error code
*
FMapBlk        lda       R$B,u               get # blocks
               beq       L0BAA               can't map 0 blocks, return error
               cmpa      #DAT.BlCt           within range of DAT image?
               bhi       L0BAA               no, return error
               leas      -$10,s              make a buffer to hold DAT image
               ldx       R$X,u               get start block #
               ldb       #1                  block increment value
               ifne      H6309
* Change to W 05/19/93 - used W since one cycle faster per block
               tfr       s,w                 point to buffer
FMapBlk2       stx       ,w++                save block # to buffer
               else      
               tfr       s,y                 point to buffer
FMapBlk2       stx       ,y++                save block # to buffer
               endc      
               abx                           Next block
               deca                          done?
               bne       FMapBlk2            no, keep going
               ldb       R$B,u               get block count again
               ldx       <D.Proc             get process pointer
               leay      <P$DATImg,x         point to DAT image
               os9       F$FreeHB            find the highest free block offset
               bcs       L0BA6               no room, return error
               ifne      H6309
               tfr       d,w                 Preserve start block # & # of blocks
               else      
               pshs      d
               endc      
               lsla                          Multiply start block # by 32
               lsla      
               lsla      
               lsla      
               lsla      
               clrb      
               std       R$U,u               save address of first block
               ifne      H6309
               tfr       w,d                 Restore offset
               else      
               puls      d
               endc      
               leau      ,s                  move DAT image into process descriptor
               os9       F$SetImg            Change process dsc to reflect new blocks
L0BA6          leas      <$10,s              Eat DAT image copy & return
               rts       

L0BAA          comb                          Illegal Block address error
               ldb       #E$IBA
               rts       
