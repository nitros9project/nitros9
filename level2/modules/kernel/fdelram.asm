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
FDelRAM             ldb       R$B,u     ; # of blocks to de-allocate
                    beq       DelRAM.2  ; if none, exit
                    ldd       <D.BlkMap+2 ; get end of the block map
                    subd      <D.BlkMap ; subtract out start of the block map
                    subd      R$X,u     ; take out starting block number
                    bls       DelRAM.2  ; exit if the starting block is ># of blocks available
                    tsta                ; check high byte of RAM #
                    bne       DelRAM.0  ; if not zero, skip it
                    cmpb      R$B,u     ; check against size of the block
                    bhs       DelRAM.0  ; if size is >RAM available
                    stb       R$B,u     ; save actual # of blocks deleted
DelRAM.0            ldx       <D.BlkMap ; get start address of the block map
                    ldd       R$X,u     ; starting address of the RAM to de-allocate
                    leax      d,x       ; slower, but smaller than ADDR
                    ldb       R$B,u     ; get actual # of blocks to de-allocate
DelRAM.1            equ       *         ; define assembler symbol DelRAM.1
                  IFNE    H6309   ; begin conditional assembly for H6309
                    aim       #^RAMinUse,,x+ ; set to RAM not in use
                  ELSE
                    lda       ,x        ; load A from ,x
                    anda      #^RAMinUse ; mask A with #^RAMinUse
                    sta       ,x+       ; store A at ,x+
                  ENDC
                    decb                ; count down a block
                    bne       DelRAM.1  ; continue
DelRAM.2            clrb                ; and exit
                    rts                 ; return to caller
