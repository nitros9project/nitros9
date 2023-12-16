**************************************************
* System Call: F$AllRAM
*
* Function: Allocate RAM blocks
*
* Input:  B = Desired block count
*
* Output: D = Beginning RAM block number
*
* Error:  CC = C bit set; B = error code
*
FAllRAM             ldb       R$B,u               get the number blocks requested
                    pshs      b,x,y               save registers
                    ldx       <D.BlkMap           get pointer to the start of the block map
L0974               leay      ,x                  point Y to the current block
                    ldb       ,s                  get the number of blocks requested
srchblk             cmpx      <D.BlkMap+2         hit end of map yet?
                    bhs       L0995               yes, exit with No RAM error
                    lda       ,x+                 get the block marker
                    bne       L0974               already used, start over with the next block up
                    decb                          decrement the number blocks still needed
                    bne       srchblk             still more, keep checking
* Entry: Y=pointer to start of memory found
* Note: Due to fact that block map always starts @ $200 (up to $2FF), we
*       don't need to calculate A
L0983               tfr       y,d                 copy the start of the requested block memory pointer to D (B)
                    lda       ,s                  get the number blocks requested
                    stb       ,s                  save the starting block number
L098D               inc       ,y+                 flag the blocks as used
                    deca                          (for all blocks allocated)
                    bne       L098D               do this until done
                    puls      b                   get the starting block number
                    clra                          (allow for D as per original calls)
                    std       R$D,u               save for the caller
                    puls      x,y,pc              restore the registers and return

L0995               comb                          set the carry
                    ldb       #E$NoRAM            exit with No RAM error
                    stb       ,s                  save B on the stack for the caller
                    puls      b,x,y,pc            restore the registers and return


**************************************************
* System Call: F$AlHRAM
*
* Function: Allocate RAM blocks from top of RAM
*
* Input:  B = Desired block count
*
* Output: D = Beginning RAM block number
*
* Error:  CC = C bit set; B = error code
*
FAlHRAM             ldb       R$B,u               get the number blocks to allocate
                    pshs      b,x,y               preserve registers
                    ldx       <D.BlkMap+2         get the pointer to the end of block map
L09A9               ldb       ,s                  get the number blocks requested
L09AB               cmpx      <D.BlkMap           are we at the beginning of RAM yet?
                    bls       L0995               yes, exit with No RAM error
                    lda       ,-x                 get the RAM block marker
                    bne       L09A9               if not free, start checking the next one down
                    decb                          free block; decrement the number blocks left to find the count
                    bne       L09AB               still more needed, so keep checking
                    tfr       x,y                 found enough contiguous blocks, so move the pointer to Y
                    bra       L0983               go mark then blocks as used and return the information to caller
