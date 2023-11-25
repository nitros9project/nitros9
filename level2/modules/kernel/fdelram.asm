**************************************************
* System Call: F$DelRAM
*
* Function: Deallocate RAM blocks
*
* Input:  B = Number of blocks
*         X = Beginning block number
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FDelRAM        ldb       R$B,u               # of blocks to de-allocate
               beq       DelRAM.2            if none, exit
               ldd       <D.BlkMap+2         get end of the block map
               subd      <D.BlkMap           subtract out start of the block map
               subd      R$X,u               take out starting block number
               bls       DelRAM.2            exit if the starting block is ># of blocks available
               tsta                          check high byte of RAM #
               bne       DelRAM.0            if not zero, skip it
               cmpb      R$B,u               check against size of the block
               bhs       DelRAM.0            if size is >RAM available
               stb       R$B,u               save actual # of blocks deleted
DelRAM.0       ldx       <D.BlkMap           get start address of the block map
               ldd       R$X,u               starting address of the RAM to de-allocate
               leax      d,x                 slower, but smaller than ADDR
               ldb       R$B,u               get actual # of blocks to de-allocate
DelRAM.1       equ       *
               ifne      H6309
               aim       #^RAMinUse,,x+      set to RAM not in use
               else      
               lda       ,x
               anda      #^RAMinUse
               sta       ,x+
               endc      
               decb                          count down a block
               bne       DelRAM.1            continue
DelRAM.2       clrb                          and exit
               rts       
