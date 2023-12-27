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
FFModul             pshs      u                   preserve register stack pointer
                    lda       R$A,u               get module type
                    ldx       R$X,u               get pointer to name
                    ldy       R$Y,u               get pointer to DAT image of name (from caller)
                    bsr       L068D               go find it
                    puls      y                   restore register stack pointer
                    std       R$D,y               save type & revision
                    stx       R$X,y               save updated name pointer
                    stu       R$U,y               save pointer to directory entry
                    rts                           return

* Find module in module directory
* Entry: A=Module type
*        X=Pointer to module name
*        Y=DAT image pointer for module name
L068D               equ       *
                    IFNE      H6309
                    tfr       0,u                 init directory pointer to nothing
                    ELSE
                    ldu       #$0000
                    ENDC
                    pshs      d,u                 preserve (Why B?)
                    bsr       L0712               Go find 1st char of module name requested
                    cmpa      #PDELIM             Is it a '/'?
                    beq       L070B               yes, exit with error
                    lbsr      ParseNam            parse the name to find the end & length
                    bcs       L070E               error (illegal name), exit
                    ldu       <D.ModEnd           get module directory end pointer
                    bra       L0700               start looking for it

* Main module directory search
* Entry: A=Module type
*        B=Module name length
*        X=Logical address of name in Caller's 64k space
*        Y=DAT image of caller (for module name)
*        U=Module directory Entry ptr (current module being checked)
L06A1               pshs      d,x,y               Preserve Mod type/nm len, Log. Addr, DAT Img ptr
                    pshs      x,y                 Preserve Log. addr & DAT Img ptr
                    ldy       MD$MPDAT,u          Does the module have a DAT Image ptr?
                    beq       L06F6               no, skip module
                    ldx       MD$MPtr,u           get module pointer
                    pshs      x,y                 Save module ptr & DAT Img ptr of module
                    ldd       #M$Name             # bytes to go in to get module name ptr
                    lbsr      L0B02               Go get the module name offset from module start (direct F$LDDXY call)
                    IFNE      H6309
                    addr      d,x                 add it to module start
                    ELSE
                    leax      d,x
                    ENDC
                    pshs      x,y                 preserve module name ptr & DAT pointer
                    leax      8,s                 Point to addr of name we are searching for
                    ldb       13,s                get name length
                    leay      ,s                  point to module name name ptr within module DAT
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
                    lbsr      L07DE               compare the names (direct call to F$CmpNam)
                    leas      4,s                 purge stack
                    puls      y,x                 restore module pointer & DAT image
                    leas      4,s                 purge stack
                    bcs       L06FE               name didn't match, skip ahead
                    ldd       #M$Type             Offset ptr to module type
                    lbsr      L0B02               Get it
                    sta       ,s                  Save high byte
                    stb       $07,s               And low byte
                    lda       $06,s               Get type/language we are looking for
                    beq       L06ED               0 means don't care on either, so skip ahead
                    anda      #TypeMask           Keep just type
                    beq       L06E1               Type 0 means don't care, skip ahead
                    eora      ,s
                    anda      #TypeMask           does it match?
                    bne       L06FE               No, check next module
L06E1               lda       $06,s               Get type/language we are looking for again
                    anda      #LangMask           Keep just Language
                    beq       L06ED               0=don't care, skip ahead
                    eora      ,s                  Does it match language we are looking for?
                    anda      #LangMask
                    bne       L06FE               No, check next module
L06ED               puls      y,x,d               Found match, restore regs
                    abx
                    clrb
                    ldb       1,s
                    leas      4,s                 purge stack and return no error
                    rts

L06F6               leas      4,s                 purge stack
                    ldd       8,s                 do we have a directory pointer?
                    bne       L06FE               yes, skip ahead
                    stu       8,s                 save directory entry pointer
L06FE               puls      d,x,y               restore pointers
L0700               leau      -MD$ESize,u         move back 1 entry in module table
                    cmpu      <D.ModDir           at the beginning?
                    bhs       L06A1               no, check entry
                    ldb       #E$MNF              get error code (module not found)
                    fcb       $8C                 skip 2 bytes
L070B               ldb       #E$BNam             get error code
                    coma                          set carry for error
L070E               stb       1,s                 save error code for caller
                    puls      d,u,pc              return

* Skip spaces in name string & return first character of name
* Entry: X=Pointer to name
*        Y=DAT image pointer
* Exit : A=First character of name
*        B=DAT image block offset
*        X=Logical address of name
L0712               pshs      y                   preserve DAT image pointer
L0714               lbsr      AdjBlk0             adjust pointer to offset for mapping in
                    lbsr      L0AC8               map in block
                    leax      1,x
                    cmpa      #C$SPAC             space?
                    beq       L0714               yes, eat it
                    leax      -1,x                move back to first character
L0720               pshs      d,cc                preserve char
                    tfr       y,d                 copy DAT pointer to D
                    subd      3,s                 calculate DAT image offset
                    asrb                          divide it by 2
                    lbsr      CmpLBlk             convert X to logical address in 64k map
                    puls      cc,d,y,pc           restore & return
