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

FUnlink             ldd       R$U,u               get the pointer to the module to unlink
                    beq       okex@               branch if it's empty
                    ldx       <D.ModDir           get the pointer to the first module in the module directory
L00B8               cmpd      MD$MPtr,x           compare the passed module address to the one in this module directory entry
                    beq       found@              if we've found it, branch
                    leax      MD$ESize,x          else go to next entry
                    cmpx      <D.ModDir+2         are we at the end of the module directory?
                    bcs       L00B8               if not, go check next entry for match
                    bra       okex@               else exit
found@              lda       MD$Link,x           get the module's link count
                    beq       dealloc@            branch if zero
                    deca                          else decrement by one
                    sta       MD$Link,x           and save count
                    bne       okex@               branch if post-dec wasn't zero
* If here, deallocate module
dealloc@            ldy       MD$MPtr,x           get the module pointer in the current module directory
                    cmpy      <D.BTLO             compare against the bottom of boot memory
                    bcc       okex@               branch if the branch if the pointer is in the boot memory area; we don't unlink modules there
                    ldb       M$Type,y            get the type of module
                    cmpb      #FlMgr              is it a file manager?
                    bcs       deletemod@          branch if not
                    os9       F$IODel             determine if I/O module is in use
                    bcc       deletemod@          branch if not
                    inc       MD$Link,x           else cancel out prior dec
                    bra       ex@                 and return to the caller
deletemod@          clra                          clear A
                    clrb                          clear B, D = 0
                    std       MD$MPtr,x           clear out the module directory entry's module address
                    std       M$ID,y              and clear the module's first two sync bytes
                    ldd       M$Size,y            get size of module in D
                    lbsr      RoundUpD            round up D to next 256 byte page
                    exg       d,y                 exchange D and Y
                    exg       a,b                 move the upper 16 bits of the module's memory size into B
                    ldx       <D.FMBM             get the memory allocation bitmap pointer
                    os9       F$DelBit            delete the corresponding bits
okex@               clra                          clear the carry
ex@                 rts                           return to the caller
