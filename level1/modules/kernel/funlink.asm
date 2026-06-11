;;; F$Unlink
;;;
;;; Decrement a module's link count.
;;;
;;; Entry:  U = The address of the module header.
;;;
;;; Exit:   None
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$Wait suspends the calling process until one of its children terminates. The kerenel returns the child’s
;;; process ID and exit status. If the child terminated due to a signal, the exit status byte in B contains the
;;; signal code.
;;;
;;; If the caller has more than one child, the kernel activates the caller when the first one terminates. Therefore,
;;; you need call F$Wait to detect the termination of each child.
;;;
;;; The kernel immediately reactivates the caller if a child terminates before F$Wait. If the caller has no children,
;;; F$Wait returns an error.
;;; A return from F$Wait with the carry bit set indicates failure; otherwise, the call functioned properly and the
;;; child's exit status resides in B.

                  IFEQ    Level-1 ; begin conditional assembly for Level-1

FUnlink             ldd       R$U,u     ; get the pointer to the module to unlink
                    beq       okex@     ; branch if it's empty
                    ldx       <D.ModDir ; get the pointer to the first module in the module directory
FUnlinkPssdModMod   cmpd      MD$MPtr,x ; compare the passed module address to the one in this module directory entry
                    beq       found@    ; if we've found it, branch
                    leax      MD$ESize,x ; else go to next entry
                    cmpx      <D.ModDir+2 ; are we at the end of the module directory?
                    bcs       FUnlinkPssdModMod ; if not, go check next entry for match
                    bra       okex@     ; else exit
found@              lda       MD$Link,x ; get the module's link count
                    beq       dealloc@  ; branch if zero
                    deca                ; else decrement by one
                    sta       MD$Link,x ; and save count
                    bne       okex@     ; branch if post-dec wasn't zero
* If here, deallocate module
dealloc@            ldy       MD$MPtr,x ; get the module pointer in the current module directory
                    cmpy      <D.BTLO   ; compare against the bottom of boot memory
                    bcc       okex@     ; branch if the branch if the pointer is in the boot memory area; we don't unlink modules there
                    ldb       M$Type,y  ; get the type of module
                    cmpb      #FlMgr    ; is it a file manager?
                    bcs       deletemod@ ; branch if not
                    os9       F$IODel   ; determine if I/O module is in use
                    bcc       deletemod@ ; branch if not
                    inc       MD$Link,x ; else cancel out prior dec
                    bra       ex@       ; and return to the caller
deletemod@          clra                ; clear A
                    clrb                ; clear B, D = 0
                    std       MD$MPtr,x ; clear out the module directory entry's module address
                    std       M$ID,y    ; and clear the module's first two sync bytes
                    ldd       M$Size,y  ; get size of module in D
                    lbsr      RoundUpD  ; round up D to next 256 byte page
                    exg       d,y       ; exchange D and Y
                    exg       a,b       ; move the upper 16 bits of the module's memory size into B
                    ldx       <D.FMBM   ; get the memory allocation bitmap pointer
                    os9       F$DelBit  ; delete the corresponding bits
okex@               clra                ; clear the carry
ex@                 rts                 ; return to the caller

                  ELSE

FUnLink             pshs      d,u       ; preserve register stack pointer and make a buffer
                    ldd       R$U,u     ; get pointer to module header
                    tfr       d,x       ; copy it to X
                    lsra                ; divide MSB by 32 to get DAT block offset
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    sta       ,s        ; save DAT block offset
                    lbeq      FUnlinkErrors ; zero, can't use so exit
                    ldu       <D.Proc   ; get pointer to current process
                    leay      P$DATImg,u ; point Y to it's DAT image
                    lsla                ; account for 2 bytes/entry
                    ldd       a,y       ; get block #
                    ldu       <D.BlkMap ; get pointer to system block map
                  IFNE    H6309   ; begin conditional assembly for H6309
                    tim       #ModBlock,d,u Is memory block a module type?
                  ELSE
                    ldb       d,u       ; load B from d,u
                    bitb      #ModBlock ; test bits in B against #ModBlock
                  ENDC
                    beq       FUnlinkErrors ; no, exit without error
                    leau      (P$Links-P$DATImg),y ; point to block link counts
                    bra       FUnlinkOffset ; go unlink block

FUnlinkWe           dec       ,s        ; we done?
                    beq       FUnlinkErrors ; yes, go on
FUnlinkOffset       ldb       ,s        ; get current offset
                    lslb                ; account for 2 bytes entry
                    ldd       b,u       ; get block link count
                    beq       FUnlinkWe ; already zero, get next one
                    lda       ,s        ; get block offset
                    lsla                ; find offset into 64k map by multiplying by 32
                    lsla                ; shift or rotate and update condition codes
                    lsla                ; shift or rotate and update condition codes
                    lsla                ; shift or rotate and update condition codes
                    lsla                ; shift or rotate and update condition codes
                    clrb                ; clear B
                    nega                ; update processor state
                  IFNE    H6309   ; begin conditional assembly for H6309
                    addr      d,x       ; add d,x to R
                  ELSE
                    leax      d,x       ; compute d,x into X
                  ENDC
                    ldb       ,s        ; get block offset
                    lslb                ; account for 2 bytes/entry
                    ldd       b,y       ; get block #
                    ldu       <D.ModDir ; get module directory pointer
                    bra       FUnlinkModuleSame ; go look for it

* Main module directory search routine
FUnlinkModuleEntry  leau      MD$ESize,u ; move to next module entry
                    cmpu      <D.ModEnd ; done entire directory?
                    bhs       FUnlinkErrors ; yes, exit
FUnlinkModuleSame   cmpx      MD$MPtr,u ; is module pointer the same?
                    bne       FUnlinkModuleEntry ; no, keep looking
                    cmpd      [MD$MPDAT,u] ; dAT match?
                    bne       FUnlinkModuleEntry ; no, keep looking
* Module is found decrement link count
* NOTE: COULD WE USE D?
*   L0198 - Safe, destroys D immediately
*   Fall through- safe, destroys D immediately
*   L01B5 - Seems to be safe
                    ldd       MD$Link,u ; get module link count
                    beq       FUnlinkTarget ; it's zero, go unlink it
                  IFNE    H6309   ; begin conditional assembly for H6309
                    decd      decrement link count
                  ELSE
                    subd      #$0001    ; subtract #$0001 from D
                  ENDC
                    std       MD$Link,u ; save it back
                    bne       FUnlinkBlock ; go on
* Module link count is zero check if he's unlinking a I/O module
FUnlinkTarget       ldx       2,s       ; get pointer to register stack
                    ldx       R$U,x     ; get pointer to module
                    ldd       #M$Type   ; get offset to module type
                    os9       F$LDDDXY  ; get module type
                    cmpa      #FlMgr    ; is it a I/O module?
                    blo       FUnlinkDltModMem ; no, don't process for I/O
                    os9       F$IODel   ; device still being used by somebody else?
                    bcc       FUnlinkDltModMem ; no, go on
                    ldd       MD$Link,u ; put the link count back to where it was
                  IFNE    H6309   ; begin conditional assembly for H6309
                    incd                ; update processor state
                  ELSE
                    addd      #$0001    ; add #$0001 to D
                  ENDC
                    std       MD$Link,u ; store D at MD$Link,u
                    bra       FUnlinkPrgLclData ; return error
* Clear module from memory
FUnlinkDltModMem    bsr       DelMod    ; delete module from memory & module dir
FUnlinkBlock        ldb       ,s        ; get block
                    lslb                ; account for 2 bytes/entry
                    leay      b,y       ; point to block
                    ldd       (P$Links-P$DATImg),y ; get block link count
                  IFNE    H6309   ; begin conditional assembly for H6309
                    decd      decrement it
                  ELSE
                    subd      #$0001    ; subtract #$0001 from D
                  ENDC
                    std       (P$Links-P$DATImg),y ; save new link count
                    bne       FUnlinkErrors ; not zero, return to user
* Clear module blocks in process DAT image
                    ldd       MD$MBSiz,u ; get block size
                    bsr       FUnlinkRndUpNear ; calculate # blocks to delete
                    ldx       #DAT.Free ; get DAT free marker
FUnlinkDATImage     stx       ,y++      ; save it in DAT image
                    deca                ; done?
                    bne       FUnlinkDATImage ; no, keep going
FUnlinkErrors       clrb                ; clear errors
FUnlinkPrgLclData   leas      2,s       ; purge local data
                    puls      u,pc      ; restore & return

* Delete module from module directory & from memory
* Entry: U=Module directory entry pointer to delete
* Exit : None
DelMod              ldx       <D.BlkMap ; get pointer to memory block map
                    ldd       [MD$MPDAT,u] ; get pointer to module DAT image
                    lda       d,x       ; is block type ROM?
                    bmi       FUnlinkReturn ; yes can't delete it, return
                    ldx       <D.ModDir ; get pointer to module directory
FUnlinkOffsetDAT    ldd       [MD$MPDAT,x] ; get offset to DAT
                    cmpd      [MD$MPDAT,u] ; match what we're looking for?
                    bne       FUnlinkModule ; no, keep looking
                    ldd       MD$Link,x ; get module link count
                    bne       FUnlinkReturn ; not zero, return
FUnlinkModule       leax      MD$ESize,x ; move to next module
                    cmpx      <D.ModEnd ; at the end?
                    bcs       FUnlinkOffsetDAT ; no, keep going
                    ldx       <D.BlkMap ; get pointer to block map
                    ldd       MD$MBSiz,u ; get memory block size
                    bsr       FUnlinkRndUpNear ; calculate # blocks to clear
                  IFNE    H6309   ; begin conditional assembly for H6309
                    pshs      u         ; preserve U (faster than original Y below)
                    clrb                ; setup for faster block in use clears
                    ldu       MD$MPDAT,u ; get pointer to module DAT image
FUnlinkTarget2      ldw       ,u++      Get first block
                    stb       -2,u      ; clear it in DAT image
                    stb       -1,u      ; store B at -1,u
                    addr      x,w       ; point to block in block map
                    aim       #^(ModBlock!RAMinUse),,w
                    deca                ; decrement A
                    bne       FUnlinkTarget2 ; branch if zero is clear to FUnlinkTarget2
                    puls      u         ; restore module ptr
                  ELSE
                    pshs      y         ; save y
                    ldy       MD$MPDAT,u ; module image ptr
FUnlinkTarget2      pshs      a,x       ; save #blocks, ptr
                    ldd       ,y        ; get block number
                    clr       ,y+       ; clear the image
                    clr       ,y+       ; clear ,y+
                    leax      d,x       ; point to blkmap entry
                    ldb       ,x        ; load B from ,x
                    andb      #^(RAMinUse+ModBlock) ; free block
                    stb       ,x        ; store B at ,x
                    puls      a,x       ; restore a,x from the stack
                    deca                ; last block done?
                    bne       FUnlinkTarget2 ; ..no, loop
                    puls      y         ; restore y from the stack
                  ENDC
                    ldx       <D.ModDir ; get module directory pointer
                    ldd       MD$MPDAT,u ; get module DAT pointer
FUnlinkMatch        cmpd      MD$MPDAT,x ; match?
                    bne       FUnlinkModuleEntry2 ; no, keep looking
                    clr       MD$MPDAT,x ; clear module DAT image pointer
                    clr       MD$MPDAT+1,x ; clear MD$MPDAT+1,x
FUnlinkModuleEntry2 leax      MD$ESize,x ; point to next module entry
                    cmpx      <D.ModEnd ; at the end?
                    blo       FUnlinkMatch ; no, keep looking
FUnlinkReturn       rts                 ; return

FUnlinkRndUpNear    addd      #$1FFF    ; round up to nearest block
                    lsra                ; calculate block # within 64k workspace
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    rts                 ; return to caller

                  ENDC
