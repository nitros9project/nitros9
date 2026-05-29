**************************************************
* System Call: F$FModul
*
* Function: Find module directory entry
*
* Input:  A = Module type
*         X = Module name string pointer
*         Y = Name string DAT image pointer
*
* Output: A = Module type
*         B = Module revision
*         X = Updated past name string
*         U = Module directory entry pointer
*
* Error:  CC = C bit set; B = error code
*
FFModul             pshs      u         ; preserve register stack pointer
                    lda       R$A,u     ; get module type
                    ldx       R$X,u     ; get pointer to name
                    ldy       R$Y,u     ; get pointer to DAT image of name (from caller)
                    bsr       FFmodulJoin ; go find it
                    puls      y         ; restore register stack pointer
                    std       R$D,y     ; save type & revision
                    stx       R$X,y     ; save updated name pointer
                    stu       R$U,y     ; save pointer to directory entry
                    rts                 ; return

* Find module in module directory
* Entry: A=Module type
*        X=Pointer to module name
*        Y=DAT image pointer for module name
FFmodulJoin         equ       *         ; define assembler symbol FFmodulJoin
                  IFNE    H6309   ; begin conditional assembly for H6309
                    tfr       0,u       ; init directory pointer to nothing
                  ELSE
                    ldu       #$0000    ; load U from #$0000
                  ENDC
                    pshs      d,u       ; preserve (Why B?)
                    bsr       FFmodulDATImage ; go find 1st char of module name requested
                    cmpa      #PDELIM   ; is it a '/'?
                    beq       FFmodulError ; yes, exit with error
                    lbsr      ParseNam  ; parse the name to find the end & length
                    bcs       FFmodulError2 ; error (illegal name), exit
                    ldu       <D.ModEnd ; get module directory end pointer
                    bra       FFmodulBackEntryMod ; start looking for it

* Main module directory search
* Entry: A=Module type
*        B=Module name length
*        X=Logical address of name in Caller's 64k space
*        Y=DAT image of caller (for module name)
*        U=Module directory Entry ptr (current module being checked)
FFmodulModTypeNm    pshs      d,x,y     ; preserve Mod type/nm len, Log. Addr, DAT Img ptr
                    pshs      x,y       ; preserve Log. addr & DAT Img ptr
                    ldy       MD$MPDAT,u ; does the module have a DAT Image ptr?
                    beq       FFmodulPurge ; no, skip module
                    ldx       MD$MPtr,u ; get module pointer
                    pshs      x,y       ; save module ptr & DAT Img ptr of module
                    ldd       #M$Name   ; # bytes to go in to get module name ptr
                    lbsr      FLdTarget ; go get the module name offset from module start (direct F$LDDXY call)
                  IFNE    H6309   ; begin conditional assembly for H6309
                    addr      d,x       ; add it to module start
                  ELSE
                    leax      d,x       ; compute d,x into X
                  ENDC
                    pshs      x,y       ; preserve module name ptr & DAT pointer
                    leax      8,s       ; point to addr of name we are searching for
                    ldb       13,s      ; get name length
                    leay      ,s        ; point to module name name ptr within module DAT
* Stack:
* 0-1,s = Ptr to module name within Module DAT Img
* 2-3,s = Ptr to module's DAT Img
* 4-5,s = Ptr to module start
* 6-7,s = Ptr to module's DAT Img
* 8-9,s = Ptr to name we are looking for in caller's 64K space
* A-B,s = Ptr to caller's DAT Img
* C,s   = Module type we are looking for (0=don't care)
* D,s   = Length of module name
* E-F,s = Ptr to name we are looking for in caller's 64K space
* 10-11,s = Ptr to caller's DAT Img
* 12,s  = Module type looking for
* 13,s  = ??? (B from entry)
* 14-15,s = Module directory ptr (inited to 0)
                    lbsr      FCmpnamTarget ; compare the names (direct call to F$CmpNam)
                    leas      4,s       ; purge stack
                    puls      y,x       ; restore module pointer & DAT image
                    leas      4,s       ; purge stack
                    bcs       FFmodulPointers ; name didn't match, skip ahead
                    ldd       #M$Type   ; offset ptr to module type
                    lbsr      FLdTarget ; get it
                    sta       ,s        ; save high byte
                    stb       $07,s     ; and low byte
                    lda       $06,s     ; get type/language we are looking for
                    beq       FFmodulFoundMatch ; 0 means don't care on either, so skip ahead
                    anda      #TypeMask ; keep just type
                    beq       FFmodulTypeLangWe ; type 0 means don't care, skip ahead
                    eora      ,s        ; exclusive-OR A with ,s
                    anda      #TypeMask ; does it match?
                    bne       FFmodulPointers ; no, check next module
FFmodulTypeLangWe   lda       $06,s     ; get type/language we are looking for again
                    anda      #LangMask ; keep just Language
                    beq       FFmodulFoundMatch ; 0=don't care, skip ahead
                    eora      ,s        ; does it match language we are looking for?
                    anda      #LangMask ; mask A with #LangMask
                    bne       FFmodulPointers ; no, check next module
FFmodulFoundMatch   puls      y,x,d     ; found match, restore regs
                    abx                 ; update processor state
                    clrb                ; clear B
                    ldb       1,s       ; load B from 1,s
                    leas      4,s       ; purge stack and return no error
                    rts                 ; return to caller

FFmodulPurge        leas      4,s       ; purge stack
                    ldd       8,s       ; do we have a directory pointer?
                    bne       FFmodulPointers ; yes, skip ahead
                    stu       8,s       ; save directory entry pointer
FFmodulPointers     puls      d,x,y     ; restore pointers
FFmodulBackEntryMod leau      -MD$ESize,u ; move back 1 entry in module table
                    cmpu      <D.ModDir ; at the beginning?
                    bhs       FFmodulModTypeNm ; no, check entry
                    ldb       #E$MNF    ; get error code (module not found)
                    fcb       $8C       ; skip 2 bytes
FFmodulError        ldb       #E$BNam   ; get error code
                    coma                ; set carry for error
FFmodulError2       stb       1,s       ; save error code for caller
                    puls      d,u,pc    ; return

* Skip spaces in name string & return first character of name
* Entry: X=Pointer to name
*        Y=DAT image pointer
* Exit : A=First character of name
*        B=DAT image block offset
*        X=Logical address of name
FFmodulDATImage     pshs      y         ; preserve DAT image pointer
FFmodulAdjstOffMap  lbsr      AdjBlk0   ; adjust pointer to offset for mapping in
                    lbsr      FLdMMUBlockData ; map in block
                    leax      1,x       ; compute 1,x into X
                    cmpa      #C$SPAC   ; space?
                    beq       FFmodulAdjstOffMap ; yes, eat it
                    leax      -1,x      ; move back to first character
FFmodulChar         pshs      d,cc      ; preserve char
                    tfr       y,d       ; copy DAT pointer to D
                    subd      3,s       ; calculate DAT image offset
                    asrb                ; divide it by 2
                    lbsr      CmpLBlk   ; convert X to logical address in 64k map
                    puls      cc,d,y,pc ; restore & return
