;;; F$Link
;;;
;;; Link to a memory module that has the specified name, language, and type.
;;;
;;; Entry: A = The desired type/language byte.
;;;        X = The address of the desired module name.
;;;
;;; Exit:  A = The module's type/language byte.
;;;        B = The module's attributes/revision byte.
;;;        X = The address of the last byte of the module name, plus 1.
;;;        Y = The address of the module’s execution entry point.
;;;        U = The address of the module header.
;;;       CC = Carry flag clear to indicate no error.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; A module's link count indicates how many processes are using it. F$Link increases the module’s
;;; link count count by one. If the module requested isn't shareable (not re-entrant), only one process
;;; can link to it at a time, and any additional link attempts return E$ModBsy.
;;;
;;; F$Link searches the module directory for a module that has the specified name, language, and type.
;;; If it finds the module, it returns the address of the module’s header in U, and the absolute address of the
;;; module’s execution entry point in Y. If F$Link can't find the desired module, it returns E$MNF.
                  IFEQ    Level-1 ; begin conditional assembly for Level-1

FLink               pshs      u         ; save caller regs
                    ldd       R$A,u     ; get desired type/language byte
                    ldx       R$X,u     ; get pointer to desired module name to link to
                    lbsr      FindModule ; go find the module
                    bcc       ok@       ; branch if found
                    ldb       #E$MNF    ; ...else Module Not Found error
                    bra       ex@       ; and return to caller
ok@                 ldy       MD$MPtr,u ; get module directory ptr
                    ldb       M$Revs,y  ; get revision byte
                    bitb      #ReEnt    ; reentrant?
                    bne       inc@      ; branch if so
                    tst       MD$Link,u ; link count zero?
                    beq       inc@      ; yep, ok to link to non-reentrant
                    comb                ; ...else set carry
                    ldb       #E$ModBsy ; load B with Module Busy
                    bra       ex@       ; and return to caller
inc@                inc       MD$Link,u ; increment link count
                    ldu       ,s        ; get caller register pointer from stack
                    stx       R$X,u     ; save off updated name pointer
                    sty       R$U,u     ; save off address of found module
                    ldd       M$Type,y  ; get type/language byte from found module
                    std       R$D,u     ; and place it in caller's D register
                    ldd       M$IDSize,y ; get the module ID size in D
                    leax      d,y       ; advance X to the start of the body of the module
                    stx       R$Y,u     ; store X in caller's Y register
ex@                 puls      pc,u      ; return to caller

                  ELSE

;;; F$SLink
;;;
;;; Link to a memory module that has the specified name, language, and type.
;;;
;;; Entry: A = The desired type/language byte.
;;;        X = The address of the desired module name.
;;;        Y = The DAT image pointer to the name string.
;;;
;;; Exit:  A = The module's type/language byte.
;;;        B = The module's attributes/revision byte.
;;;        X = The address of the last byte of the module name, plus 1.
;;;        Y = The address of the module’s execution entry point.
;;;        U = The address of the module header.
;;;       CC = Carry flag clear to indicate no error.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;

FSLink              ldy       R$Y,u     ; get DAT image pointer of name
                    bra       FLinkTarget ; skip ahead

;;; F$ELink
;;;
;;; Link to a memory module using the module directory entry.
;;;
;;; Entry: B = The module type.
;;;        X = The pointer to the module directory entry.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;

FELink              pshs      u         ; preserve register stack pointer
                    ldb       R$B,u     ; get module type
                    ldx       R$X,u     ; get pointer to module directory entry
                    bra       FLinkReEntrant ; skip ahead

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
FLink               equ       *         ; define assembler symbol
                    ldx       <D.Proc   ; get pointer to DAT image
                    leay      P$DATImg,x ; point to process DAT image
FLinkTarget         pshs      u         ; preserve register stack pointer
                    ldx       R$X,u     ; get pointer to path name
                    lda       R$A,u     ; get module type
                    lbsr      FFmodulJoin ; search module directory
                    bcs       LinkErr   ; not there, exit with error
                    leay      ,u        ; point to module directory entry
                    ldu       ,s        ; get register stack pointer
                    stx       R$X,u     ; save updated module name pointer
                    std       R$D,u     ; save type/language
                    leax      ,y        ; point to directory entry
FLinkReEntrant      bitb      #ReEnt    ; is it re-entrant?
                    bne       FLinkModule ; yes, skip ahead
                    ldd       MD$Link,x ; is module busy?
                    beq       FLinkModule ; no, go link it
                    ldb       #E$ModBsy ; return module busy error
                    bra       LinkErr   ; return
FLinkModule         ldd       MD$MPtr,x ; get module pointer
                    pshs      d,x       ; preserve that & directory pointer
                    ldy       MD$MPDAT,x ; get module DAT image pointer
                    ldd       MD$MBSiz,x ; get block size
                    addd      #$1FFF    ; round it up
                    tfr       a,b       ; transfer register value a,b
                    lsrb                ; shift or rotate and update condition codes
                    lsrb                ; shift or rotate and update condition codes
                    lsrb                ; shift or rotate and update condition codes
                    lsrb                ; shift or rotate and update condition codes
                    lsrb                ; shift or rotate and update condition codes
*         adda   #$02
                    lsra                ; shift or rotate and update condition codes
                    inca                ; instead of adda #2, above
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    pshs      a         ; save a on the stack
                    leau      ,y        ; point to module DAT image
                    bsr       FLinkProcess ; is it already linked in process space?
                    bcc       FLinkMemBlkLink ; yes, skip ahead
                    lda       ,s        ; load A from ,s
                    lbsr      FFreehbInvertWithin ; find free low block in process DAT image
                    bcc       FLinkMemBlksProc ; found some, skip ahead
                    leas      5,s       ; purge stack
                    bra       LinkErr   ; return error

FLinkMemBlksProc    lbsr      FFreehbTheseOnto ; copy memory blocks into process DAT image
FLinkMemBlkLink     ldb       #P$Links  ; point to memory block link counts
                    abx                 ; smaller and faster than leax P$Links,x
                    sta       ,s        ; save block # on stack
                    lsla                ; account for 2 bytes/entry
                    leau      a,x       ; point to block # we want
                    ldd       ,u        ; get link count for that block
                  IFNE    H6309   ; begin conditional assembly for H6309
                    incd                ; bump up by 1
                  ELSE
                    addd      #$0001    ; add #$0001 to D
                  ENDC
                    beq       FLinkTarget2 ; if wraps to 0, leave at $FFFF
                    std       ,u        ; otherwise, store new link count
FLinkTarget2        ldu       $03,s     ; load U from $03,s
                    ldd       MD$Link,u ; load D from MD$Link,u
                  IFNE    H6309   ; begin conditional assembly for H6309
                    incd                ; update processor state
                  ELSE
                    addd      #$0001    ; add #$0001 to D
                  ENDC
                    beq       FLinkTarget3 ; branch if zero is set to FLinkTarget3
                    std       MD$Link,u ; store D at MD$Link,u
FLinkTarget3        puls      b,x,y,u   ; restore b,x,y,u from the stack
                    lbsr      CmpLBlk   ; call local routine CmpLBlk
                    stx       R$U,u     ; store X at R$U,u
                    ldx       MD$MPtr,y ; load X from MD$MPtr,y
                    ldy       ,y        ; load Y from ,y
                    ldd       #M$Exec   ; get offset to execution address
                    lbsr      FLdTarget ; get execution offset
                    addd      R$U,u     ; add it to start of module
                    std       R$Y,u     ; set execution entry point
                    clrb                ; no error & return
                    rts                 ; return to caller

LinkErr             orcc      #Carry    ; error & return
                    puls      u,pc      ; restore u,pc from the stack

FLinkProcess        ldx       <D.Proc   ; get pointer to current process
                    leay      P$DATImg,x ; point to process DAT image
                    clra                ; clear A
                    pshs      d,x,y     ; save d,x,y on the stack
                    subb      #DAT.BlCt ; subtract #DAT.BlCt from B
                    negb                ; update processor state
                    lslb                ; shift or rotate and update condition codes
                    leay      b,y       ; compute b,y into Y
                  IFNE    H6309   ; begin conditional assembly for H6309
FLinkTarget4        ldw       ,s        Get counter
                  ELSE
FLinkTarget4        ldx       ,s        ; load X from ,s
                  ENDC
                    pshs      u,y       ; save u,y on the stack
FLinkTarget5        ldd       ,y++      ; load D from ,y++
                    cmpd      ,u++      ; compare D with ,u++
                    bne       FLinkTarget6 ; branch if zero is clear to FLinkTarget6
                  IFNE    H6309   ; begin conditional assembly for H6309
                    decw                ; dec counter
                  ELSE
                    leax      -1,x      ; compute -1,x into X
                  ENDC
                    bne       FLinkTarget5 ; if not done, keep going
                    puls      d,u       ; restore d,u from the stack
                    subd      4,s       ; subtract 4,s from D
                    lsrb                ; shift or rotate and update condition codes
                    stb       ,s        ; store B at ,s
                    clrb                ; clear B
                    puls      d,x,y,pc  ; restore regs & return

FLinkTarget6        puls      u,y       ; restore u,y from the stack
                    leay      -2,y      ; compute -2,y into Y
                    cmpy      4,s       ; compare Y with 4,s
                    bcc       FLinkTarget4 ; branch if carry is clear to FLinkTarget4
                    puls      d,x,y,pc  ; restore d,x,y,pc from the stack

                  ENDC
