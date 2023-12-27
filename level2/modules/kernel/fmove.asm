**************************************************
* System Call: F$Move
*
* Function: Move data (low bound first)
* Entry: U=ptr to caller's stack (see Input for what registers on stack
*  mean)
*
* Input:  A = Source task #
*         B = Destination task #
*         X = Source pointer
*         Y = Number of bytes to move
*         U = Destination pointer
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
* 2009/12/31 - Modified 6809 version so that it does not use the stack
* while MMU is in used... this addresses a crash that occurred when the
* bootfile was too small, causing the process descriptor to be allocated
* in the $AXXX range, and as a result, the process stack pointer would get
* switched out when $FFA5-$FFA6 was written and the stack would disappear.
* 2019/11/20 - Changed to use DP location for counter (DEC<xx is 6
* cycles) using D.IRQTmp. Saves 14 cycles/8 bytes copied in block copy loop
* Used D.IRQTmp+1 for copy of current block size as well.
* Eliminated pshs cc/puls cc around actual copy loop (when both temp MMU
* blocks swapped in) replacing with just orcc/andcc (slightly smaller, faster)
* Attempted change to size of copy from 64 to 96 bytes with new faster routine
*   (still has IRQ's off for 17 cycles less than 6309 version)
* Should speed up larger F$Moves
fbye                clrb
                    rts
                    
FMove               ldd       R$D,u               get source & destination task #'s
* Entry point from F$CRC
L0B25               ldy       R$Y,u               Get # bytes to move
                    beq       fbye                None, exit without error
                    ldx       R$X,u               get source pointer
                    ldu       R$U,u               get destination pointer
L0B2C               pshs      d,x,y,u             preserve it all
                    pshs      d,y                 save task #'s & byte count
                    tfr       a,b                 copy source task to B
                    lbsr      L0BF5               calculate block offset of source
                    leay      a,u                 point to block
                    pshs      x,y                 save source pointer & DAT pointer of source
                    ldb       9,s                 get destination task #
                    ldx       14,s                get destination pointer
                    lbsr      L0BF5               calculate block offset
                    leay      a,u                 point to block
                    pshs      x,y                 save dest. pointer & DAT pointer to dest.
* try ldq #$20002000/ subr x,w / pshsw (+3), take out ldd (-3)
                    ldd       #DAT.BlSz           get block size
                    subd      ,s                  take off offset
                    pshs      d                   preserve
                    ldd       #DAT.BlSz           init offset in block
                    subd      6,s
                    pshs      d                   save distance to end??
                    ldx       8,s                 get source pointer
                    leax      -$6000,x            make X point to where we'll map block ($a000)
                    ldu       4,s                 get destination pointer
                    leau      -$4000,u            make U point to where we'll map block ($c000)
                    ldy       <D.SysDAT           Get ptr to system DAT image
                    lda       11,y                Get MMU block #5
                    ldb       13,y                Get MMU block #6
                    IFNE      H6309
                    tfr       d,y                 Move to Y since unused in loop below
                    ENDC
* Main move loop
* Stack:  0,s=distance to end of source block
*         2,s=distance to end of destination block
*         4,s=pointer to destination
*         6,s=pointer to destination DAT image
*         8,s=pointer to source
*        10,s=pointer to source DAT image
*        12,s=task # of source
*        13,s=task # of destination
*        14,s=total byte count of move
* Registers: X=Source pointer
*            U=Destination pointer
L0B6A               equ       *
                    IFNE      H6309
                    ldd       [<6,s]              [B]=Block # of source
                    ldw       [<10,s]             [A]=Block # of destination
                    tfr       f,a
* Calculate move length for this pass
                    ldw       14,s                get full byte count
                    cmpw      ,s                  we gonna overlap source?
                    bls       L0B82               no, skip ahead
                    ldw       ,s                  get remaining bytes in source block
L0B82               cmpw      2,s                 we gonna overlap destination?
                    bls       L0B89               no, skip ahead
                    ldw       2,s                 get remaining bytes in destination block
L0B89               cmpw      #$0100              less than 256 bytes?
                    bls       L0B92               yes, skip ahead
                    ldw       #$0100              force to 256 bytes
L0B92               stw       12,s                save count
                    orcc      #IntMasks           Shut off interrupts
                    std       >DAT.Regs+5         map in the blocks
                    tfm       x+,u+               Copy up to 256 bytes (max 774 cycles)
                    sty       >DAT.Regs+5         Restore system blocks 5&6 to normal
                    andcc     #^IntMasks
                    ldd       14,s                get full count
                    subd      12,s                done?
                    beq       L0BEF               yes, return
                    std       14,s                save updated count
                    ldd       ,s                  get current offset in block
                    subd      12,s                need to switch source block?
                    bne       L0BD7               no, skip ahead
                    lda       #$20                B=0 from 'bne' above
                    subr      d,x                 reset source back to begining of block
                    inc       11,s                add 2 to source DAT pointer
                    inc       11,s
L0BD7               std       ,s                  save updated source offset in block
                    ldd       2,s                 get destination offset
                    subd      12,s                need to switch destination block?
                    bne       L0BEA               no, skip ahead
                    lda       #$20                B=0 from 'bne', above
                    subr      d,u                 reset destination back to beginning of block
                    inc       7,s                 add 2 to destination DAT pointer
                    inc       7,s
L0BEA               std       2,s                 save updated destination offset in block
                    bra       L0B6A               go do next block

* Block move done, return
L0BEF               leas      16,s                purge stack
L0BF2               clrb                          clear errors
                    puls      d,x,y,u,pc          return

                    ELSE

* Main move loop
* Stack:  0,s=distance to end of source block
*         2,s=distance to end of destination block
*         4,s=pointer to destination
*         6,s=pointer to destination DAT image
*         8,s=pointer to source
*        10,s=pointer to source DAT image
*        12,s=task # of source      \ These get repurposed to hold
*        13,s=task # of destination / current block copy size (6809)
*        14,s=total byte count of move
* Registers: X=Source pointer
*            U=Destination pointer
L0BXA               ldd       [<$6,s]             Get block # of source into B
                    pshs      b                   Save on stack
                    ldd       [<10+1,s]           Get block # of dest into B
                    pshs      b                   Save on stack
                    ldd       <14+2,s             Get total byte count left we are copying
                    cmpd      0+2,s               Will that go past end of source block?
                    bls       L0B82               No, check destination
                    ldd       0+2,s               Get # of bytes until end of source block
L0B82               cmpd      2+2,s               Will that go past end of dest block?
                    bls       L0B89               No, check max size we want IRQ's of
                    ldd       2+2,s               Get # of bytes until end of dest block
L0B89               cmpd      #$0060              >96 bytes to copy left?
                    bls       L0B84               No, do entire # of bytes left
                    ldd       #$0060              Yes, force to 96
L0B84               std       12+2,s              Save size of current copy block
                    puls      y                   Get source & dest MMU block #'s
                    orcc      #IntMasks           Shut IRQ's off
                    stb       <D.IRQTmp+1         Save copy of current copy block size
                    sty       >DAT.Regs+5         Swap in source/dest MMU blocks into $A000-$DFFF
***** NO STACK USE BETWEEN HERE.....
                    andb      #$07                2 1st, do single byte copies for 1-7 leftover bytes
                    beq       L0B99               3 No leftovers, go to 8 byte copy routine
L0B92               lda       ,x+                 6 Copy 1-7 leftover bytes
                    sta       ,u+                 6
                    decb                          2
                    bne       L0B92               3
L0B99               lda       <D.IRQTmp+1         +4 Get copy size back into A
                    lsra                          Divide size by 8 (since 8 byte chunks copying)
                    lsra
                    lsra
                    beq       L0BBC
                    sta       <D.IRQTmp           Save loop counter (# 8 byte blocks) +4
                    exg       x,u                 Swap source/destination ptrs for PULU routine
L0BA4               pulu      y,d                 9 55 cycles per 8 bytes copied
                    std       ,x                  5 (old pulu y/sty ,x++ was 69)
                    sty       2,x                 6
                    pulu      y,d                 9
                    std       4,x                 6
                    sty       6,x                 6
                    leax      8,x                 5
                    dec       <D.IRQTmp           6
                    bne       L0BA4               3
                    exg       x,u                 8 Swap updated source/dest ptrs
L0BBC               ldy       <D.SysDAT           6 Get system DAT pointer
                    lda       $0B,y               5 Get original MMU blocks
                    ldb       $0D,y               5
                    std       >DAT.Regs+5         6 Restore originals
***** AND HERE...........
                    andcc     #^IntMasks          Turn IRQ's back on
                    ldd       14,s                Get # of bytes left to copy
                    subd      12,s                Subtract # bytes we copied
                    beq       L0BEF               Done Move
                    std       14,s                Save new # of bytes left to copy
                    ldd       ,s                  Get # bytes until end of source block
                    subd      12,s                Subtract # bytes copied
                    bne       L0BD7               Still more in current source MMU block
                    ldd       #DAT.BlSz           Size of MMU block (8K)
* Since we know where the blocks are mapped, we can change this leax
* and the later leau to ldx #$A000 and ldu #$C000 (faster smaller)
                    leax      >-DAT.BlSz,x        Move source ptr back to beginning of MMU block
* If we do lda 11,s/adda #2/sta 11,s (2 more bytes, -2 cycles), move above
* ldd #DAT.BlSz to after the sta 11,s
* Not sure if worth the extra code space - these only get done when 8K
* boundaries are crossed, so not often at all
                    inc       11,s                7 Add 2 to source DAT ptr
                    inc       11,s
L0BD7               std       ,s                  Save new distance (8K) to end of source block
                    ldd       2,s                 Get # bytes until end of dest block
                    subd      12,s                Subtract # bytes copied
                    bne       L0BEA               Still more in current dest MMU block
                    ldd       #DAT.BlSz
                    leau      >-DAT.BlSz,u        Wrap dest pr back
                    inc       7,s                 7 Add 2 to dest DAT ptr
                    inc       7,s
L0BEA               std       2,s                 Save # of bytes left in dest block
                    lbra      L0BXA

L0BEF               leas      <$10,s              Eat temp stack
L0BF2               clrb                          Exit w/o error
                    puls      pc,u,y,x,d

                    ENDC

L0BF3               tfr       u,y                 save a copy of U for later
* Calculate offset within DAT image
* Entry: B=Task #
*        X=Pointer to data
* Exit : A=Offset into DAT image
*        X=Offset within block from original pointer
* Possible bug:  No one ever checks if the DAT image, in fact, exists.
L0BF5               ldu       <D.TskIPt           get task image ptr table
                    lslb
                    ldu       b,u                 get ptr to this task's DAT image
                    tfr       x,d                 copy logical address to D
                    anda      #%11100000          Keep only which 8K bank it's in
                    beq       L0C07               Bank 0, no further calcs needed
                    clrb                          force it to start on an 8K boundary
                    IFNE      H6309
                    subr      d,x                 now X=offset into the block
                    ELSE
                    pshs      d
                    tfr       x,d
                    subd      ,s
                    tfr       d,x
                    puls      d
                    ENDC
                    lsra                          Calculate offset into DAT image to get proper
                    lsra                          8K bank (remember that each entry in a DAT image
                    lsra                          is 2 bytes)
                    lsra
L0C07               rts
