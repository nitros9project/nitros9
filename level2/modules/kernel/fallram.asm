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
FAllRAM        ldb       R$B,u               Get # blocks requested
               pshs      b,x,y               Save regs
               ldx       <D.BlkMap           Get ptr to start of block map
L0974          leay      ,x                  Point Y to current block
               ldb       ,s                  Get # blocks requested
srchblk        cmpx      <D.BlkMap+2         Hit end of map yet?
               bhs       L0995               Yes, exit with No RAM error
               lda       ,x+                 Get block marker
               bne       L0974               Already used, start over with next block up
               decb                          Dec # blocks still needed
               bne       srchblk             Still more, keep checking
* Entry: Y=ptr to start of memory found
* Note: Due to fact that block map always starts @ $200 (up to $2FF), we
*       don't need to calc A
L0983          tfr       y,d                 Copy start of requested block mem ptr to D (B)
               lda       ,s                  Get # blocks requested
               stb       ,s                  Save start block #
L098D          inc       ,y+                 Flag blocks as used
               deca                          (for all blocks allocated)
               bne       L098D               Do until done
               puls      b                   Get start block #
               clra                          (allow for D as per original calls)
               std       R$D,u               Save for caller
               puls      x,y,pc              Restore regs & return

L0995          comb                          Exit with No RAM error
               ldb       #E$NoRAM
               stb       ,s
               puls      b,x,y,pc


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
FAlHRAM        ldb       R$B,u               Get # blocks to allocate
               pshs      b,x,y               Preserve regs
               ldx       <D.BlkMap+2         Get ptr to end of block map
L09A9          ldb       ,s                  Get # blocks requested
L09AB          cmpx      <D.BlkMap           Are we at beginning of RAM yet?
               bls       L0995               Yes, exit with No RAM error
               lda       ,-x                 Get RAM block marker
               bne       L09A9               If not free, start checking next one down
               decb                          Free block, dec # blocks left to find count
               bne       L09AB               Still more needed, keep checking
               tfr       x,y                 Found enough contigous blocks, move ptr to Y
               bra       L0983               Go mark blocks as used, & return info to caller
