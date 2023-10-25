* Search the module directory for a module of name pointed by X.
*
* Entry:  A = Type of module to link.
*         X = Pointer to name of module.
*
* Exit:   X = Pointer to first character after the module's name
*         U = Pointer to the module directory entry of found entry (if found)
*        CC = Carry flag clear to indicate success.
*
* Error:  B = A non-zero error code.
*        CC = Carry flag set to indicate error.

FindModule
                    ldu       #$0000              initialize U with $0000
                    tfr       a,b                 copy A to B
                    anda      #TypeMask           preserve type bits in A
                    andb      #LangMask           preserve language bits in B
                    pshs      u,y,x,b,a           save important registers
_stk1A@             set       0
_stk1B@             set       1
_stk1X@             set       2
_stk1Y@             set       4
_stk1U@             set       6
                    bsr       eatspace@           move X past any spaces
                    cmpa      #PDELIM             pathlist char?
                    beq       exerr@              branch if so
                    lbsr      ParseNam            parse name
                    bcs       ex@                 branch if error
                    ldu       <D.ModDir           get pointer to module directory
FindLoop            pshs      u,y,b               save important registers
_stk2B@             set       0                   B = pathname length
_stk2Y@             set       1                   Y =
_stk2U@             set       3                   U = address of next module in module directory
_stk1A@             set       0+_stk2U@+2
_stk1B@             set       1+_stk2U@+2
_stk1X@             set       2+_stk2U@+2
_stk1Y@             set       4+_stk2U@+2
_stk1U@             set       6+_stk2U@+2
                    ldu       MD$MPtr,u           get pointer to next module to compare names with
                    beq       CheckEnd            empty entry... continue to next module in list
                    ldd       M$Name,u            get module name offset in module
                    leay      d,u                 point Y to module name
                    ldb       _stk2B@,s           get length of pathname on stack
                    lbsr      CmpNam              compare name of modules
                    bcs       NextMod             branch if not same name
                    lda       _stk1A@,s           get saved type byte on stack
                    beq       ChkLang             same... now check language
                    eora      M$Type,u            EOR with type in module
                    anda      #TypeMask           preserve type bits
                    bne       NextMod             branch if not same type
ChkLang             lda       _stk1B@,s           get saved language byte on stack
                    beq       ModFound            branch if 0
                    eora      M$Type,u            EOR with language in module
                    anda      #LangMask           preserve language bits
                    bne       NextMod             branch if not same language
ModFound            puls      u,x,b               module found... restore regs
_stk1A@             set       0
_stk1B@             set       1
_stk1X@             set       2
_stk1Y@             set       4
_stk1U@             set       6
                    stu       _stk1U@,s           save off found module in caller's U
                    bsr       eatspace@           move past any spaces
                    stx       _stk1X@,s           save off character past module name in caller's X
                    clra                          clear carry
                    bra       ex@                 branch to exit of routine
_stk2B@             set       0
_stk2Y@             set       1
_stk2U@             set       3
_stk1A@             set       0+_stk2U@+2
_stk1B@             set       1+_stk2U@+2
_stk1X@             set       2+_stk2U@+2
_stk1Y@             set       4+_stk2U@+2
_stk1U@             set       6+_stk2U@+2
CheckEnd            ldd       _stk1U@,s           get saved pointer in module directory
                    bne       NextMod             branch to get next module in directory
                    ldd       _stk2U@,s           get saved U
                    std       _stk1U@,s           put in saved U in earlier stack
NextMod             puls      u,y,b               restore pushed regs
                    leau      MD$ESize,u          advance to next module directory entry
                    cmpu      <D.ModDir+2         at end of directory?
                    bcs       FindLoop            no... continue searching
exerr@              comb                          set carry
ex@                 puls      pc,u,y,x,b,a        return to caller
* Advance past any leading spaces in a string.
*
* Entry: X = Pointer to string.
*
* Exit:  A = First non-space character.
*        X = Pointer to first non-space character.
eatspace@           lda       #C$SPAC             load A with space character
loop@               cmpa      ,x+                 compare with character at X and increment
                    beq       loop@               if space, keep going
                    lda       ,-x                 else get non-space character at X-1
                    rts                           return

;;; F$VModul
;;;
;;; Validate the validity of a module.
;;;
;;; Entry:  X = The address of the module to verify.
;;;
;;; Exit:   U = The absolute address of the module header.
;;;        CC = Carry flag clear to indicate success.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$VModul validates that a module exists at the passed address, and if so, searches the module directory
;;; for a module with the same name. If one exists, the module with the higher revision level remains in memory.
;;; If both modules have the same revision level, F$VModul retains the module in memory.
;;;
;;; If the module integrity feature flag is turned on at build time, F$VModul will verify the module's header and
;;; CRC to ensure the module is completely correct; otherwise, these checks aren't done.

FVModul             pshs      u                   save caller's registers
                    ldx       R$X,u               get caller's X (address of module name)
                    bsr       ValMod              perform the validation
                    puls      y                   pull the caller's registers
                    stu       R$U,y               save the new (if any) module address
                    rts                           return to caller

* X = address of module to validate
ValMod              bsr       ChkMHCRC            check the module header and CRC
                    bcs       ex@                 ... exit if error
                    lda       M$Type,x            get the type byte
                    pshs      x,a                 save off module address
                    ldd       M$Name,x            get module name offset
                    leax      d,x                 set X to address of name in module
                    puls      a                   restore type byte
                    lbsr      FindModule          attempt to locate module in module directory of same name
                    puls      x                   restore passed module address
* Now, X points to module that was passed by caller, and
* U points to module dirctory entry of the module of the same name that was found (if any)
* already in module directory
                    bcs       isempty@            branch if FindModule returned error (no module found of the same name)
                    ldb       #E$KwnMod           prepare possible error
                    cmpx      MD$MPtr,u           is the returned module directory entry the same?
                    beq       errex@              branch if so
* Here, we've established another module of the same name as the one we're validating already
* exists in the module directory, and it's NOT this same module.
* Check the revision to see if this one is newer and should replace the existing one.
                    lda       M$Revs,x            else get revision byte of passed module
                    anda      #RevsMask           mask out all but revision
                    pshs      a                   save off
                    ldy       MD$MPtr,u           get pointer to found module (different)
                    lda       M$Revs,y            get revision byte of found module
                    anda      #RevsMask           mask out all but revision
                    cmpa      ,s+                 compare revisions
                    bcc       errex@              if same or lower, return to caller
                    pshs      y,x                 save off pointer to modules
                    ldb       MD$Link,u           get link count of module
                    bne       pulsaveandex@       branch if not zero
                    ldx       MD$MPtr,u           get address of module into X
                    cmpx      <D.BTLO             compare against Boot low memory pointer
                    bcc       pulsaveandex@       branch if higher
* Here, we've determined the module we're validating is newer than the one that already
* exists in memory.
                    ldd       M$Size,x            else get module size from module header
                    addd      #$00FF              round up to next page
                    tfr       a,b                 divide by 256 (# of pages to clear)
                    clra                          D = rounded up value of module's memory footprint (number of bits to clear)
                    tfr       d,y                 transfer to Y
                    ldb       MD$MPtr,u           put high byte of module address into B (D = first bit in allocation table to clear)
                    ldx       <D.FMBM             get pointer to free memory bitmap
                    os9       F$DelBit            delete from allocation table (D = first bit to clear, X = bitmap address, Y = # of bits to clear)
                    clr       MD$Link,u           clear link count in module directory entry
pulsaveandex@       puls      y,x                 restore X and Y
saveandex@          stx       MD$MPtr,u           save newly validated module into module directory entry of deallocated modulke
                    clrb                          clear carry and error code
ex@                 rts                           return
isempty@            leay      MD$MPtr,u           get module pointer in Y
                    bne       saveandex@          branch if module exists
                    ldb       #E$DirFul           module directory is full
errex@              coma                          set carry
                    rts                           return to caller

* Check module header and CRC
*
* Entry: X = Address of potential module.
ChkMHCRC            ldd       ,x                  get two bytes at start of potential module
                    cmpd      #M$ID12             are these module sync bytes?
                    bne       errex@              nope, not a module here
                    leay      M$Parity,x          else point Y to the parity byte in the module
                    bsr       ChkMHPar            check header parity
                    bcc       Chk4CRC             branch if ok
errex@              comb                          else set carry
                    ldb       #E$BMID             and load B with error
                    rts                           return to caller

* Check module CRC
*
* Entry: X = Address of module to check.
Chk4CRC
                    lda       <D.CRC              is CRC checking on?
                    bne       DoCRCCk             branch if so
                    clrb                          else clear carry
                    rts                           return to caller

* Check if module CRC checking is on
*
* Entry: X = Address of module to check.
DoCRCCk             pshs      x                   save off module address onto stack
                    ldy       M$Size,x            get module size in module header
                    bsr       ChkMCRC             check module CRC
                    puls      pc,x

* Check module header parity
*
* Entry: X = Module header to check.
*        Y = Pointer to parity byte.
ChkMHPar            pshs      y,x                 save off X and Y
_stk1X@             set       0
_stk1Y@             set       2
                    clra                          A = 0
loop@               eora      ,x+                 XOR with
                    cmpx      _stk1Y@,s           compare to address of parity byte
                    bls       loop@               branch if not there yet
                    cmpa      #$FF                parity check done... is it correct?
                    puls      pc,y,x              restore regs and return

* Check module CRC
*
* Entry: X = Address of potential module.
*        Y = Size of module.
ChkMCRC             ldd       #$FFFF              initialize D to $FFFF
                    pshs      b,a                 save off stack
                    pshs      b,a                 32 bits
                    leau      1,s                 advance one byte (24 byte CRC)
loop@               lda       ,x+                 get next byte of module
                    bsr       CRCAlgo             perform algorithm
                    leay      -1,y                decrement Y (size of module)
                    bne       loop@               continue if not at end
                    clr       -1,u                clear first 8 bits of 32 bits
                    lda       ,u                  get first byte of CRC
                    cmpa      #CRCCon1            is it what we expect?
                    bne       err@                branch if not
                    ldd       1,u                 get next two bytes of CRC
                    cmpd      #CRCCon23           is it what we expect?
                    beq       ex@                 branch if what we expect
err@                comb                          ...else set carry
                    ldb       #E$BMCRC            load B with error
ex@                 puls      pc,y,x              return to caller

