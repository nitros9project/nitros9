**************************************************
* System Call: F$Move
*
* Function: Move data (low bound first)
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
*
               ifeq      H6309
L0A01          clrb      
               rts       
               endc      

FMove          ldd       R$D,u               get source & destination task #'s
L0B25          ldy       R$Y,u               Get # bytes to move
               beq       L0A01               None, exit without error
               ldx       R$X,u               get source pointer
               ldu       R$U,u               get destination pointer

L0B2C          pshs      d,x,y,u             preserve it all
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
               tfr       d,y                 Move to Y since unused in loop below
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
L0B6A          equ       *
               ifne      H6309
               ldd       [<6,s]              [B]=Block # of source
               ldw       [<10,s]             [A]=Block # of destination
               tfr       f,a
* Calculate move length for this pass
               ldw       14,s                get full byte count
               cmpw      ,s                  we gonna overlap source?
               bls       L0B82               no, skip ahead
               ldw       ,s                  get remaining bytes in source block
L0B82          cmpw      2,s                 we gonna overlap destination?
               bls       L0B89               no, skip ahead
               ldw       2,s                 get remaining bytes in destination block
L0B89          cmpw      #$0100              less than 128 bytes?
               bls       L0B92               yes, skip ahead
               ldw       #$0100              force to 128 bytes
L0B92          stw       12,s                save count
               orcc      #IntMasks           Shut off interrupts
               std       >DAT.Regs+5         map in the blocks
               tfm       x+,u+               Copy up to 128 bytes
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
L0BD7          std       ,s                  save updated source offset in block
               ldd       2,s                 get destination offset
               subd      12,s                need to switch destination block?
               bne       L0BEA               no, skip ahead
               lda       #$20                B=0 from 'bne', above
               subr      d,u                 reset destination back to beginning of block
               inc       7,s                 add 2 to destination DAT pointer
               inc       7,s
L0BEA          std       2,s                 save updated destination offset in block
               bra       L0B6A               go do next block
* Block move done, return
L0BEF          leas      16,s                purge stack
L0BF2          clrb                          clear errors
               puls      d,x,y,u,pc          return
               else      
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
L0BXA          pshs      cc
               ldd       [<$07,s]
               pshs      b
               ldd       [<$0C,s]
               pshs      b
               ldd       <$11,s
               cmpd      $03,s
               bls       L0B82
               ldd       $03,s
L0B82          cmpd      $05,s
               bls       L0B89
               ldd       $05,s
L0B89          cmpd      #$0040
               bls       L0B84
               ldd       #$0040
L0B84          std       $0F,s
               puls      y
               orcc      #IntMasks
               ifne      mc09
               lda       <D.TINIT            Current MMU mask - selects block 0
               ora       #5
               sta       >MMUADR             Select block 5
               lda       $0E,s               stack could disappear in the remapping..
               exg       d,y                 swap them; final destination for d
               sta       >MMUDAT
***** NO STACK USE BETWEEN HERE.....
               lda       <D.TINIT            Current MMU mask - selects block 0
               ora       #6
               sta       >MMUADR             Select block 6
               stb       >MMUDAT
* the coco code did a "tfr d,y". mc09 did a "exg d,y" which
* left y correct but we also need d=y at the end..
               tfr       y,d
               else      
               lda       $0E,s               +++
               sty       >DAT.Regs+5
***** NO STACK USE BETWEEN HERE.....
               tfr       d,y                 +++
               endif     
               andb      #$07
               beq       L0B99
L0B92          lda       ,x+
               sta       ,u+
               decb      
               bne       L0B92
L0B99                    
               tfr       y,d                 +++
*         ldb   $0E,s  ---
*         lsrb        ---
*         lsrb        ---
*         lsrb        ---
               lsra                          +++
               lsra                          +++
               lsra                          +++
               beq       L0BBC
*         pshs  b      ---
               exg       x,u
L0BA4                    
*         pulu  y,b,a  ---
*         std   ,x     ---
*         sty   $02,x  ---
*         pulu  y,b,a  ---
*         std   $04,x  ---
*         sty   $06,x  ---
*         leax  $08,x  ---
*         dec   ,s     ---
*         bne   L0BA4  ---
*         leas  $01,s  ---
               pulu      y                   +++
               sty       ,x++                +++
               pulu      y                   +++
               sty       ,x++                +++
               pulu      y                   +++
               sty       ,x++                +++
               pulu      y                   +++
               sty       ,x++                +++
               deca                          +++
               bne       L0BA4               +++
               exg       x,u
L0BBC          ldy       <D.SysDAT
               ifne      mc09
               lda       <D.TINIT            Current MMU mask - selects block 0
               ora       #5
               sta       >MMUADR             Select block 5
               ldb       $0B,y
               stb       >MMUDAT             Restore it
               inca      
               sta       >MMUADR             Select block 6
               ldb       $0D,y
               stb       >MMUDAT             Restore it
               else      
               lda       $0B,y
               ldb       $0D,y
               std       >DAT.Regs+5
               endif     
***** AND HERE...........
               puls      cc
               ldd       $0E,s
               subd      $0C,s
               beq       L0BEF
               std       $0E,s
               ldd       ,s
               subd      $0C,s
               bne       L0BD7
               ldd       #DAT.BlSz
               leax      >-DAT.BlSz,x
               inc       $0B,s
               inc       $0B,s
L0BD7          std       ,s
               ldd       $02,s
               subd      $0C,s
               bne       L0BEA
               ldd       #DAT.BlSz
               leau      >-DAT.BlSz,u
               inc       $07,s
               inc       $07,s
L0BEA          std       $02,s
               lbra      L0BXA
L0BEF          leas      <$10,s
L0BF2          clrb      
               puls      pc,u,y,x,b,a
               endc      

L0BF3          tfr       u,y                 save a copy of U for later

* Calculate offset within DAT image
* Entry: B=Task #
*        X=Pointer to data
* Exit : A=Offset into DAT image
*        X=Offset within block from original pointer
* Possible bug:  No one ever checks if the DAT image, in fact, exists.
L0BF5          ldu       <D.TskIPt           get task image ptr table
               lslb      
               ldu       b,u                 get ptr to this task's DAT image
               tfr       x,d                 copy logical address to D
               anda      #%11100000          Keep only which 8K bank it's in
               beq       L0C07               Bank 0, no further calcs needed
               clrb                          force it to start on an 8K boundary
               ifne      H6309
               subr      d,x                 now X=offset into the block
               else      
               pshs      d
               tfr       x,d
               subd      ,s
               tfr       d,x
               puls      d
               endc      
               lsra                          Calculate offset into DAT image to get proper
               lsra                          8K bank (remember that each entry in a DAT image
               lsra                          is 2 bytes)
               lsra      
L0C07          rts       
