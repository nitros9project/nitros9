**************************************************
* System Call: F$LDAXY
*
* Function: Load A [X,[Y]]
*
* Input:  X = Block offset
*         Y = DAT image pointer
*
* Output: A = data byte at X offset of Y
*
* Error:  CC = C bit set; B = error code
*
FLDAXY              ldx       R$X,u     ; get offset within block (S/B $0000-$1FFF)
                    ldy       R$Y,u     ; get ptr to DAT block entry
                    bsr       FLdMMUBlockData ; go get byte
                    sta       R$A,u     ; save in caller's A reg.
                    rts                 ; return to caller

* Entry: X=offset ($0000-$1fff) to get from block pointed to by Y (DAT entry
* format)
FLdMMUBlockData     lda       1,y       ; get MMU block # to get data from
                    clrb                ; clear carry/setup for STB
                    pshs      cc        ; preserve interrupt status/settings
                    orcc      #IntMasks ; shut IRQ's off
                  IFNE    mc09    ; begin conditional assembly for mc09
                    ldb       <D.TINIT  ; current MMU mask - selects block 0
                    stb       >MMUADR   ; select block 0
                    sta       >MMUDAT   ; map block into $0000-$1FFF
                    lda       ,x        ; get byte
                    clrb                ; clear B
                    stb       >MMUDAT   ; map block 0 into $0000-$1FFF
                  ELSE
                  IFNE    picothing ; begin conditional assembly for picothing
                    cmpa      #KrnBlk   ; kernel page = the DAT "unavailable" sentinel?
                    bne       mblk@     ; no, safe to map into slot 0
                    lda       >((DAT.BlCt-1)*DAT.BlSz),x ; read in place from fixed window
                    puls      pc,cc     ; return, no DAT slot was touched
mblk@               equ       *         ; remap path for an ordinary block
                  ENDC
                    sta       >DAT.Regs ; map block into $0000-$1FFF
                    lda       ,x        ; get byte
                    stb       >DAT.Regs ; map block 0 into $0000-$1FFF
                  ENDC
                    puls      pc,cc     ; get interrupt status/(or turn on) & return

* Get 1st byte of LDDDXY - also used by many other routines
* Increments X on exit; adjusts X for within 8K block & Y (DAT img ptr)
LDAXY               lda       1,y       ; get MMU block #
                    pshs      b,cc      ; save regs
                    clrb                ; clear B
                    orcc      #IntMasks ; shut off interrupts
                  IFNE    picothing ; begin conditional assembly for picothing
                    cmpa      #KrnBlk   ; kernel page = the DAT "unavailable" sentinel?
                    bne       lax@      ; no, safe to map into slot 0
                    lda       >((DAT.BlCt-1)*DAT.BlSz),x ; read in place from fixed window
                    leax      1,x       ; advance X to match lda ,x+
                    puls      b,cc      ; restore regs
                    bra       AdjBlk0   ; go adjust X and Y for block wrap
lax@                equ       *         ; remap path for an ordinary block
                  ENDC
                    sta       >DAT.Regs ; map in MMU block into slot 0
                    lda       ,x+       ; get byte
                    stb       >DAT.Regs ; map MMU block #0 back
                    puls      b,cc      ; restore b,cc from the stack
                    bra       AdjBlk0   ; branch unconditionally to AdjBlk0

FLdBumpOffStart     leax      >-DAT.BlSz,x ; bump offset ptr to start of block again
                    leay      2,y       ; bump source MMU block up to next one in DAT Image
AdjBlk0             cmpx      #DAT.BlSz ; going to wrap out of our block?
                    bhs       FLdBumpOffStart ; yes, go adjust
                    rts                 ; no, return


**************************************************
* System Call: F$LDDXY
*
* Function: Load D [D+X,[Y]]
*
* Input:  D = Offset to offset
*         X = Offset
*         Y = DAT image pointer
*
* Output: D = bytes address by [D+X,Y]
*
* Error:  CC = C bit set; B = error code
*
FLDDDXY             ldd       R$D,u     ; get offset to offset within DAT Image
                    leau      R$X,u     ; point U to Offset
                    pulu      x,y       ; Y=Offset within DAT Image, X=DAT Image ptr
                    bsr       FLdTarget ; go get 2 bytes
                    std       -(R$X+3),u ; save into caller's X
                    clrb                ; no error & return
                    rts                 ; return to caller
* Get 2 bytes for LDDDXY (also called by other routines)
* Should simply map in 2 blocks, and do a LDD (don't have to worry about wrap)
FLdTarget           pshs      u,y,x     ; preserve regs
                  IFNE    H6309   ; begin conditional assembly for H6309
                    addr      d,x       ; point X to X+D
                  ELSE
                    leax      d,x       ; compute d,x into X
                  ENDC
                    bsr       AdjBlk0   ; wrap address around for 1 block
                  IFNE    picothing ; begin conditional assembly for picothing
* Picothing DAT RAM is readable SRAM.  Read the actual hardware slot
* values so we restore exactly what was there (the DAT image may hold
* DAT.Free for unallocated blocks, which differs from the identity map
* the hardware was booted with).
                    lda       1,y       ; get MMU block #0 to map in
                    ldb       3,y       ; get MMU block #1 to map in
                    pshs      cc        ; preserve int. status
                    orcc      #IntMasks ; shut off int.
                    cmpa      #KrnBlk   ; kernel page = the DAT "unavailable" sentinel?
                    bne       fldt@     ; no, safe to map into slots 0 and 1
* The kernel block cannot be mapped into a consulted slot; its module
* data lives in the fixed $E000-$FFFF window, so read it there in place.
                    ldd       >((DAT.BlCt-1)*DAT.BlSz),x ; get 2 bytes from fixed window
                    puls      pc,u,y,x,cc ; restore regs and return
fldt@               ldu       >DAT.Regs ; save actual hardware slots 0 and 1
                    std       >DAT.Regs ; map in both blocks
                    ldd       ,x        ; get 2 bytes
                    stu       >DAT.Regs ; restore original hardware slots
                  ELSE
                    ldu       <D.SysDAT ; get sys DAT Image ptr
                    clra                ; system block 0 =0 always
                    ldb       3,u       ; get MMU block #1
                    tfr       d,u       ; make U=blocks to re-map in once done
                    lda       1,y       ; get MMU block #0
                    ldb       3,y       ; get MMU block #1
                    pshs      cc        ; preserve int. status
                    orcc      #IntMasks ; shut off int.
                    std       >DAT.Regs ; map in both blocks
                    ldd       ,x        ; get 2 bytes
                    stu       >DAT.Regs ; map original blocks in
                  ENDC
                    puls      pc,u,y,x,cc ; restore regs & return
