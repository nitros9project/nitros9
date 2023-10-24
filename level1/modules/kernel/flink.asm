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

FLink               pshs      u                   save caller regs
                    ldd       R$A,u               get desired type/language byte
                    ldx       R$X,u               get pointer to desired module name to link to
                    lbsr      FindModule          go find the module
                    bcc       ok@                 branch if found
                    ldb       #E$MNF              ...else Module Not Found error
                    bra       ex@                 and return to caller
ok@                 ldy       MD$MPtr,u           get module directory ptr
                    ldb       M$Revs,y            get revision byte
                    bitb      #ReEnt              reentrant?
                    bne       inc@                branch if so
                    tst       MD$Link,u           link count zero?
                    beq       inc@                yep, ok to link to non-reentrant
                    comb                          ...else set carry
                    ldb       #E$ModBsy           load B with Module Busy
                    bra       ex@                 and return to caller
inc@                inc       MD$Link,u           increment link count
                    ldu       ,s                  get caller register pointer from stack
                    stx       R$X,u               save off updated name pointer
                    sty       R$U,u               save off address of found module
                    ldd       M$Type,y            get type/language byte from found module
                    std       R$D,u               and place it in caller's D register
                    ldd       M$IDSize,y          get the module ID size in D
                    leax      d,y                 advance X to the start of the body of the module
                    stx       R$Y,u               store X in caller's Y register
ex@                 puls      pc,u                return to caller
