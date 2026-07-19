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
fbye                clrb                ; clear B
                    rts                 ; return to caller

FMove               ldd       R$D,u     ; get source & destination task #'s
* Entry point from F$CRC
FMoveBytes          ldy       R$Y,u     ; get # bytes to move
                    beq       fbye      ; none, exit without error
                    ldx       R$X,u     ; get source pointer
                    ldu       R$U,u     ; get destination pointer
FMoveTarget         pshs      d,x,y,u   ; preserve it all
                    pshs      d,y       ; save task #'s & byte count
                    tfr       a,b       ; copy source task to B
                    lbsr      FMoveTaskImageTable ; calculate block offset of source
                    leay      a,u       ; point to block
                    pshs      x,y       ; save source pointer & DAT pointer of source
                    ldb       9,s       ; get destination task #
                    ldx       14,s      ; get destination pointer
                    lbsr      FMoveTaskImageTable ; calculate block offset
                    leay      a,u       ; point to block
                    pshs      x,y       ; save dest. pointer & DAT pointer to dest.
* try ldq #$20002000/ subr x,w / pshsw (+3), take out ldd (-3)
                    ldd       #DAT.BlSz ; get block size
                    subd      ,s        ; take off offset
                    pshs      d         ; preserve
                    ldd       #DAT.BlSz ; init offset in block
                    subd      6,s       ; subtract 6,s from D
                    pshs      d         ; save distance to end??
                    ldx       8,s       ; get source pointer
                    leax      -$6000,x  ; make X point to where we'll map block ($a000)
                    ldu       4,s       ; get destination pointer
                    leau      -$4000,u  ; make U point to where we'll map block ($c000)
                    ldy       <D.SysDAT ; get ptr to system DAT image
                    lda       11,y      ; get MMU block #5
                    ldb       13,y      ; get MMU block #6
                  IFNE    H6309   ; begin conditional assembly for H6309
                    tfr       d,y       ; move to Y since unused in loop below
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
FMoveJoin           equ       *         ; define assembler symbol FMoveJoin
                  IFNE    H6309   ; begin conditional assembly for H6309
                  IFNE    picothing ; begin conditional assembly for picothing
* WARNING: before enabling H6309 native mode on Pico-Thing, this path
* needs the same KrnBlk fixed-window guard as the 6809 path below —
* mapping page $FF into slots 5/6 faults NMI (DAT unavailable sentinel).
                  ENDC
                    ldd       [<6,s]    ; [B]=Block # of source
                    ldw       [<10,s]   ; [A]=Block # of destination
                    tfr       f,a       ; transfer register value f,a
* Calculate move length for this pass
                    ldw       14,s      ; get full byte count
                    cmpw      ,s        ; we gonna overlap source?
                    bls       FMoveWeGnnOvrlp ; no, skip ahead
                    ldw       ,s        ; get remaining bytes in source block
FMoveWeGnnOvrlp     cmpw      2,s       ; we gonna overlap destination?
                    bls       FMoveBytes2 ; no, skip ahead
                    ldw       2,s       ; get remaining bytes in destination block
FMoveBytes2         cmpw      #$0100    ; less than 256 bytes?
                    bls       FMoveCount ; yes, skip ahead
                    ldw       #$0100    ; force to 256 bytes
FMoveCount          stw       12,s      ; save count
                    orcc      #IntMasks ; shut off interrupts
                    std       >DAT.Regs+5 ; map in the blocks
                    tfm       x+,u+     ; copy up to 256 bytes (max 774 cycles)
                    sty       >DAT.Regs+5 ; restore system blocks 5&6 to normal
                    andcc     #^IntMasks ; clear condition-code bits using #^IntMasks
                    ldd       14,s      ; get full count
                    subd      12,s      ; done?
                    beq       FMovePurge ; yes, return
                    std       14,s      ; save updated count
                    ldd       ,s        ; get current offset in block
                    subd      12,s      ; need to switch source block?
                    bne       FMoveUpdSrcOff ; no, skip ahead
                    lda       #$20      ; B=0 from 'bne' above
                    subr      d,x       ; reset source back to begining of block
                    inc       11,s      ; add 2 to source DAT pointer
                    inc       11,s      ; increment 11,s
FMoveUpdSrcOff      std       ,s        ; save updated source offset in block
                    ldd       2,s       ; get destination offset
                    subd      12,s      ; need to switch destination block?
                    bne       FMoveUpdDstOff ; no, skip ahead
                    lda       #$20      ; B=0 from 'bne', above
                    subr      d,u       ; reset destination back to beginning of block
                    inc       7,s       ; add 2 to destination DAT pointer
                    inc       7,s       ; increment 7,s
FMoveUpdDstOff      std       2,s       ; save updated destination offset in block
                    bra       FMoveJoin ; go do next block

* Block move done, return
FMovePurge          leas      16,s      ; purge stack
FMoveErrors         clrb                ; clear errors
                    puls      d,x,y,u,pc ; return

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
L0BXA               ldd       [<$6,s]   ; get block # of source into B
                    pshs      b         ; save on stack
                    ldd       [<10+1,s] ; get block # of dest into B
                    pshs      b         ; save on stack
                    ldd       <14+2,s   ; get total byte count left we are copying
                    cmpd      0+2,s     ; will that go past end of source block?
                    bls       FMoveWeGnnOvrlp ; no, check destination
                    ldd       0+2,s     ; get # of bytes until end of source block
FMoveWeGnnOvrlp     cmpd      2+2,s     ; will that go past end of dest block?
                    bls       FMoveBytes2 ; no, check max size we want IRQ's of
                    ldd       2+2,s     ; get # of bytes until end of dest block
FMoveBytes2         cmpd      #$0060    ; >96 bytes to copy left?
                    bls       FMoveSizeBlock ; no, do entire # of bytes left
                    ldd       #$0060    ; yes, force to 96
FMoveSizeBlock      std       12+2,s    ; save size of current copy block
                    puls      y         ; get source & dest MMU block #'s
                  IFNE    picothing ; begin conditional assembly for picothing
* Pico-Thing: page $FF (KrnBlk) is also the DAT "unavailable" sentinel,
* so it must never be mapped into a consulted slot (the access would
* fault NMI).  The kernel block's contents are readable in place in the
* fixed $E000-$FFFF window, so when a side's page is KrnBlk, bias that
* side's pointer into the fixed window and map a harmless page 0 into
* the slot instead (nothing references the slot for that side).
                    pshs      y         ; examine the two page numbers
                    lda       ,s        ; get the source page (slot 5)
                    cmpa      #KrnBlk   ; is the source the kernel block?
                    bne       nsrc@     ; no, map it normally
                    clr       ,s        ; substitute page 0 for slot 5
                    leax      >(2*DAT.BlSz),x ; read the source via the fixed window
nsrc@               lda       1,s       ; get the destination page (slot 6)
                    cmpa      #KrnBlk   ; is the destination the kernel block?
                    bne       ndst@     ; no, map it normally
                    clr       1,s       ; substitute page 0 for slot 6
                    leau      >DAT.BlSz,u ; write the destination via the fixed window
ndst@               puls      y         ; reload the (possibly adjusted) pages
                  ENDC
                    orcc      #IntMasks ; shut IRQ's off
                    stb       <D.IRQTmp+1 ; save copy of current copy block size
                    sty       >DAT.Regs+5 ; swap in source/dest MMU blocks into $A000-$DFFF
***** NO STACK USE BETWEEN HERE.....
                    andb      #$07      ; 2 1st, do single byte copies for 1-7 leftover bytes
                    beq       FMoveSizeBack ; 3 No leftovers, go to 8 byte copy routine
FMoveCount          lda       ,x+       ; 6 Copy 1-7 leftover bytes
                    sta       ,u+       ; 6
                    decb                ; 2
                    bne       FMoveCount ; 3
FMoveSizeBack       lda       <D.IRQTmp+1 ; +4 Get copy size back into A
                    lsra                ; divide size by 8 (since 8 byte chunks copying)
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    beq       FMoveSystemDAT ; branch if zero is set to FMoveSystemDAT
                    sta       <D.IRQTmp ; save loop counter (# 8 byte blocks) +4
                    exg       x,u       ; swap source/destination ptrs for PULU routine
FMoveCyclsPerByts   pulu      y,d       ; 9 55 cycles per 8 bytes copied
                    std       ,x        ; 5 (old pulu y/sty ,x++ was 69)
                    sty       2,x       ; 6
                    pulu      y,d       ; 9
                    std       4,x       ; 6
                    sty       6,x       ; 6
                    leax      8,x       ; 5
                    dec       <D.IRQTmp ; 6
                    bne       FMoveCyclsPerByts ; 3
                    exg       x,u       ; 8 Swap updated source/dest ptrs
FMoveSystemDAT      ldy       <D.SysDAT ; 6 Get system DAT pointer
                    lda       $0B,y     ; 5 Get original MMU blocks
                    ldb       $0D,y     ; 5
                    std       >DAT.Regs+5 ; 6 Restore originals
***** AND HERE...........
                  IFNE    picothing ; begin conditional assembly for picothing
* Undo the fixed-window bias for any side whose page was KrnBlk.  The
* image pointers have not been bumped yet, so re-reading the entries
* tells us which sides were biased this pass.  D is reloaded below.
                    ldd       [10,s]    ; this pass's source image entry
                    cmpb      #KrnBlk   ; was the source the kernel block?
                    bne       usrc@     ; no, X is already window-relative
                    leax      >-(2*DAT.BlSz),x ; bias X back to the slot 5 window
usrc@               ldd       [6,s]     ; this pass's destination image entry
                    cmpb      #KrnBlk   ; was the destination the kernel block?
                    bne       udst@     ; no, U is already window-relative
                    leau      >-DAT.BlSz,u ; bias U back to the slot 6 window
udst@               equ       *         ; both pointers window-relative again
                  ENDC
                    andcc     #^IntMasks ; turn IRQ's back on
                    ldd       14,s      ; get # of bytes left to copy
                    subd      12,s      ; subtract # bytes we copied
                    beq       FMovePurge ; done Move
                    std       14,s      ; save new # of bytes left to copy
                    ldd       ,s        ; get # bytes until end of source block
                    subd      12,s      ; subtract # bytes copied
                    bne       FMoveUpdSrcOff ; still more in current source MMU block
                    ldd       #DAT.BlSz ; size of MMU block (8K)
* Since we know where the blocks are mapped, we can change this leax
* and the later leau to ldx #$A000 and ldu #$C000 (faster smaller)
                    leax      >-DAT.BlSz,x ; move source ptr back to beginning of MMU block
* If we do lda 11,s/adda #2/sta 11,s (2 more bytes, -2 cycles), move above
* ldd #DAT.BlSz to after the sta 11,s
* Not sure if worth the extra code space - these only get done when 8K
* boundaries are crossed, so not often at all
                    inc       11,s      ; 7 Add 2 to source DAT ptr
                    inc       11,s      ; increment 11,s
FMoveUpdSrcOff      std       ,s        ; save new distance (8K) to end of source block
                    ldd       2,s       ; get # bytes until end of dest block
                    subd      12,s      ; subtract # bytes copied
                    bne       FMoveUpdDstOff ; still more in current dest MMU block
                    ldd       #DAT.BlSz ; load D from #DAT.BlSz
                    leau      >-DAT.BlSz,u ; wrap dest pr back
                    inc       7,s       ; 7 Add 2 to dest DAT ptr
                    inc       7,s       ; increment 7,s
FMoveUpdDstOff      std       2,s       ; save # of bytes left in dest block
                    lbra      L0BXA     ; branch unconditionally to L0BXA

FMovePurge          leas      <$10,s    ; eat temp stack
FMoveErrors         clrb                ; exit w/o error
                    puls      pc,u,y,x,d ; restore pc,u,y,x,d from the stack

                  ENDC

FMoveLater          tfr       u,y       ; save a copy of U for later
* Calculate offset within DAT image
* Entry: B=Task #
*        X=Pointer to data
* Exit : A=Offset into DAT image
*        X=Offset within block from original pointer
* Possible bug:  No one ever checks if the DAT image, in fact, exists.
FMoveTaskImageTable ldu       <D.TskIPt ; get task image ptr table
                    lslb                ; shift or rotate and update condition codes
                    ldu       b,u       ; get ptr to this task's DAT image
                    tfr       x,d       ; copy logical address to D
                    anda      #%11100000 ; keep only which 8K bank it's in
                    beq       FMoveReturn ; bank 0, no further calcs needed
                    clrb                ; force it to start on an 8K boundary
                  IFNE    H6309   ; begin conditional assembly for H6309
                    subr      d,x       ; now X=offset into the block
                  ELSE
                    pshs      d         ; save d on the stack
                    tfr       x,d       ; transfer register value x,d
                    subd      ,s        ; subtract ,s from D
                    tfr       d,x       ; transfer register value d,x
                    puls      d         ; restore d from the stack
                  ENDC
                    lsra                ; calculate offset into DAT image to get proper
                    lsra                ; 8K bank (remember that each entry in a DAT image
                    lsra                ; is 2 bytes)
                    lsra                ; shift or rotate and update condition codes
FMoveReturn         rts                 ; return to caller
