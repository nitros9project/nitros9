                    ifgt      Level-1

**************************************************
* System Call: F$SLink
*
* Function: System Link
*
* Input:  A = Module type
*         X = Module name string pointer
*         Y = Name string DAT image pointer
*
* Output: A = Module type
*         B = Module revision
*         X = Updated name string pointer
*         Y = Module entry point
*         U = Module pointer
*
* Error:  CC = C bit set; B = error code
*
FSLink              ldy       R$Y,u               get DAT image pointer of name
                    bra       L0398               skip ahead


**************************************************
* System Call: F$ELink
*
* Function: Link using module directory entry
*
* Input:  B = Module type
*         X = Pointer to module directory entry
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FELink              pshs      u                   preserve register stack pointer
                    ldb       R$B,u               get module type
                    ldx       R$X,u               get pointer to module directory entry
                    bra       L03AF               skip ahead

                    endc

**************************************************
* System Call: F$Link
*
* Function: Link to a memory module
*
* Input:  X = Address of module name
*         A = Type/Language byte
*
* Output: X = Advanced past module name
*         Y = Module entry point address
*         U = Module header address
*         A = Module type/language byte
*         B = Module attributes/revision byte
*
* Error:  CC = C bit set; B = error code
*
FLink               equ       *
                    ifgt      Level-1
                    ldx       <D.Proc             get pointer to DAT image
                    leay      P$DATImg,x          point to process DAT image
                    endc
L0398               pshs      u                   preserve register stack pointer
                    ldx       R$X,u               get pointer to path name
                    lda       R$A,u               get module type
                    lbsr      L068D               search module directory
                    bcs       LinkErr             not there, exit with error
                    leay      ,u                  point to module directory entry
                    ldu       ,s                  get register stack pointer
                    stx       R$X,u               save updated module name pointer
                    std       R$D,u               save type/language
                    leax      ,y                  point to directory entry
L03AF               bitb      #ReEnt              is it re-entrant?
                    bne       L03BB               yes, skip ahead
                    ldd       MD$Link,x           is module busy?
                    beq       L03BB               no, go link it
                    ldb       #E$ModBsy           return module busy error
                    bra       LinkErr             return
L03BB               ldd       MD$MPtr,x           get module pointer
                    pshs      d,x                 preserve that & directory pointer
                    ldy       MD$MPDAT,x          get module DAT image pointer
                    ldd       MD$MBSiz,x          get block size
                    addd      #$1FFF              round it up
                    tfr       a,b
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    lsrb
*         adda   #$02
                    lsra
                    inca                          instead of adda #2, above
                    lsra
                    lsra
                    lsra
                    lsra
                    pshs      a
                    leau      ,y                  point to module DAT image
                    bsr       L0422               is it already linked in process space?
                    bcc       L03EB               yes, skip ahead
                    lda       ,s
                    lbsr      L0A33               find free low block in process DAT image
                    bcc       L03E8               found some, skip ahead
                    leas      5,s                 purge stack
                    bra       LinkErr             return error

L03E8               lbsr      L0A8C               copy memory blocks into process DAT image
L03EB               ldb       #P$Links            point to memory block link counts
                    abx                           smaller and faster than leax P$Links,x
                    sta       ,s                  save block # on stack
                    lsla                          account for 2 bytes/entry
                    leau      a,x                 point to block # we want
                    ldd       ,u                  get link count for that block
                    ifne      H6309
                    incd                          bump up by 1
                    else
                    addd      #$0001
                    endc
                    beq       L03FC               If wraps to 0, leave at $FFFF
                    std       ,u                  Otherwise, store new link count
L03FC               ldu       $03,s
                    ldd       MD$Link,u
                    ifne      H6309
                    incd
                    else
                    addd      #$0001
                    endc
                    beq       L0406
                    std       MD$Link,u
L0406               puls      b,x,y,u
                    lbsr      CmpLBlk
                    stx       R$U,u
                    ldx       MD$MPtr,y
                    ldy       ,y
                    ldd       #M$Exec             get offset to execution address
                    lbsr      L0B02               get execution offset
                    addd      R$U,u               add it to start of module
                    std       R$Y,u               set execution entry point
                    clrb                          No error & return
                    rts

LinkErr             orcc      #Carry              Error & return
                    puls      u,pc

L0422               ldx       <D.Proc             get pointer to current process
                    leay      P$DATImg,x          point to process DAT image
                    clra
                    pshs      d,x,y
                    subb      #DAT.BlCt
                    negb
                    lslb
                    leay      b,y
                    ifne      H6309
L0430               ldw       ,s                  Get counter
                    else
L0430               ldx       ,s
                    endc
                    pshs      u,y
L0434               ldd       ,y++
                    cmpd      ,u++
                    bne       L0449
                    ifne      H6309
                    decw                          Dec counter
                    else
                    leax      -1,x
                    endc
                    bne       L0434               If not done, keep going
                    puls      d,u
                    subd      4,s
                    lsrb
                    stb       ,s
                    clrb
                    puls      d,x,y,pc            Restore regs & return

L0449               puls      u,y
                    leay      -2,y
                    cmpy      4,s
                    bcc       L0430
                    puls      d,x,y,pc
