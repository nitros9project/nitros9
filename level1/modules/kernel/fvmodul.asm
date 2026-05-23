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

                  IFEQ    Level-1 ; begin conditional assembly for Level-1
FindModule
                    ldu       #$0000    ; initialize U with $0000
                    tfr       a,b       ; copy A to B
                    anda      #TypeMask ; preserve type bits in A
                    andb      #LangMask ; preserve language bits in B
                    pshs      u,y,x,b,a ; save important registers
_stk1A@             set       0         ; define assembler symbol
_stk1B@             set       1         ; define assembler symbol
_stk1X@             set       2         ; define assembler symbol
_stk1Y@             set       4         ; define assembler symbol
_stk1U@             set       6         ; define assembler symbol
                    bsr       eatspace@ ; move X past any spaces
                    cmpa      #PDELIM   ; pathlist char?
                    beq       exerr@    ; branch if so
                    lbsr      ParseNam  ; parse name
                    bcs       ex@       ; branch if error
                    ldu       <D.ModDir ; get pointer to module directory
FindLoop            pshs      u,y,b     ; save important registers
_stk2B@             set       0         ; B = pathname length
_stk2Y@             set       1         ; Y =
_stk2U@             set       3         ; U = address of next module in module directory
_stk1A@             set       0+_stk2U@+2 ; define assembler symbol
_stk1B@             set       1+_stk2U@+2 ; define assembler symbol
_stk1X@             set       2+_stk2U@+2 ; define assembler symbol
_stk1Y@             set       4+_stk2U@+2 ; define assembler symbol
_stk1U@             set       6+_stk2U@+2 ; define assembler symbol
                    ldu       MD$MPtr,u ; get pointer to next module to compare names with
                    beq       CheckEnd  ; empty entry... continue to next module in list
                    ldd       M$Name,u  ; get module name offset in module
                    leay      d,u       ; point Y to module name
                    ldb       _stk2B@,s ; get length of pathname on stack
                    lbsr      CmpNam    ; compare name of modules
                    bcs       NextMod   ; branch if not same name
                    lda       _stk1A@,s ; get saved type byte on stack
                    beq       ChkLang   ; same... now check language
                    eora      M$Type,u  ; eOR with type in module
                    anda      #TypeMask ; preserve type bits
                    bne       NextMod   ; branch if not same type
ChkLang             lda       _stk1B@,s ; get saved language byte on stack
                    beq       ModFound  ; branch if 0
                    eora      M$Type,u  ; eOR with language in module
                    anda      #LangMask ; preserve language bits
                    bne       NextMod   ; branch if not same language
ModFound            puls      u,x,b     ; module found... restore regs
_stk1A@             set       0         ; define assembler symbol
_stk1B@             set       1         ; define assembler symbol
_stk1X@             set       2         ; define assembler symbol
_stk1Y@             set       4         ; define assembler symbol
_stk1U@             set       6         ; define assembler symbol
                    stu       _stk1U@,s ; save off found module in caller's U
                    bsr       eatspace@ ; move past any spaces
                    stx       _stk1X@,s ; save off character past module name in caller's X
                    clra                ; clear carry
                    bra       ex@       ; branch to exit of routine
_stk2B@             set       0         ; define assembler symbol
_stk2Y@             set       1         ; define assembler symbol
_stk2U@             set       3         ; define assembler symbol
_stk1A@             set       0+_stk2U@+2 ; define assembler symbol
_stk1B@             set       1+_stk2U@+2 ; define assembler symbol
_stk1X@             set       2+_stk2U@+2 ; define assembler symbol
_stk1Y@             set       4+_stk2U@+2 ; define assembler symbol
_stk1U@             set       6+_stk2U@+2 ; define assembler symbol
CheckEnd            ldd       _stk1U@,s ; get saved pointer in module directory
                    bne       NextMod   ; branch to get next module in directory
                    ldd       _stk2U@,s ; get saved U
                    std       _stk1U@,s ; put in saved U in earlier stack
NextMod             puls      u,y,b     ; restore pushed regs
                    leau      MD$ESize,u ; advance to next module directory entry
                    cmpu      <D.ModDir+2 ; at end of directory?
                    bcs       FindLoop  ; no... continue searching
exerr@              comb                ; set carry
ex@                 puls      pc,u,y,x,b,a ; return to caller
* Advance past any leading spaces in a string.
*
* Entry: X = Pointer to string.
*
* Exit:  A = First non-space character.
*        X = Pointer to first non-space character.
eatspace@           lda       #C$SPAC   ; load A with space character
loop@               cmpa      ,x+       ; compare with character at X and increment
                    beq       loop@     ; if space, keep going
                    lda       ,-x       ; else get non-space character at X-1
                    rts                 ; return

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

FVModul             pshs      u         ; save caller's registers
                    ldx       R$X,u     ; get caller's X (address of module name)
                    bsr       ValMod    ; perform the validation
                    puls      y         ; pull the caller's registers
                    stu       R$U,y     ; save the new (if any) module address
                    rts                 ; return to caller

* X = address of module to validate
ValMod              bsr       ChkMHCRC  ; check the module header and CRC
                    bcs       ex@       ; ... exit if error
                    lda       M$Type,x  ; get the type byte
                    pshs      x,a       ; save off module address
                    ldd       M$Name,x  ; get module name offset
                    leax      d,x       ; set X to address of name in module
                    puls      a         ; restore type byte
                    lbsr      FindModule ; attempt to locate module in module directory of same name
                    puls      x         ; restore passed module address
* Now, X points to module that was passed by caller, and
* U points to module dirctory entry of the module of the same name that was found (if any)
* already in module directory
                    bcs       isempty@  ; branch if FindModule returned error (no module found of the same name)
                    ldb       #E$KwnMod ; prepare possible error
                    cmpx      MD$MPtr,u ; is the returned module directory entry the same?
                    beq       errex@    ; branch if so
* Here, we've established another module of the same name as the one we're validating already
* exists in the module directory, and it's NOT this same module.
* Check the revision to see if this one is newer and should replace the existing one.
                    lda       M$Revs,x  ; else get revision byte of passed module
                    anda      #RevsMask ; mask out all but revision
                    pshs      a         ; save off
                    ldy       MD$MPtr,u ; get pointer to found module (different)
                    lda       M$Revs,y  ; get revision byte of found module
                    anda      #RevsMask ; mask out all but revision
                    cmpa      ,s+       ; compare revisions
                    bcc       errex@    ; if same or lower, return to caller
                    pshs      y,x       ; save off pointer to modules
                    ldb       MD$Link,u ; get link count of module
                    bne       pulsaveandex@ ; branch if not zero
                    ldx       MD$MPtr,u ; get address of module into X
                    cmpx      <D.BTLO   ; compare against Boot low memory pointer
                    bcc       pulsaveandex@ ; branch if higher
* Here, we've determined the module we're validating is newer than the one that already
* exists in memory.
                    ldd       M$Size,x  ; else get module size from module header
                    addd      #$00FF    ; round up to next page
                    tfr       a,b       ; divide by 256 (# of pages to clear)
                    clra                ; D = rounded up value of module's memory footprint (number of bits to clear)
                    tfr       d,y       ; transfer to Y
                    ldb       MD$MPtr,u ; put high byte of module address into B (D = first bit in allocation table to clear)
                    ldx       <D.FMBM   ; get pointer to free memory bitmap
                    os9       F$DelBit  ; delete from allocation table (D = first bit to clear, X = bitmap address, Y = # of bits to clear)
                    clr       MD$Link,u ; clear link count in module directory entry
pulsaveandex@       puls      y,x       ; restore X and Y
saveandex@          stx       MD$MPtr,u ; save newly validated module into module directory entry of deallocated modulke
                    clrb                ; clear carry and error code
ex@                 rts                 ; return
isempty@            leay      MD$MPtr,u ; get module pointer in Y
                    bne       saveandex@ ; branch if module exists
                    ldb       #E$DirFul ; module directory is full
errex@              coma                ; set carry
                    rts                 ; return to caller

* Check module header and CRC
*
* Entry: X = Address of potential module.
ChkMHCRC            ldd       ,x        ; get two bytes at start of potential module
                    cmpd      #M$ID12   ; are these module sync bytes?
                    bne       errex@    ; nope, not a module here
                    leay      M$Parity,x ; else point Y to the parity byte in the module
                    bsr       ChkMHPar  ; check header parity
                    bcc       Chk4CRC   ; branch if ok
errex@              comb                ; else set carry
                    ldb       #E$BMID   ; and load B with error
                    rts                 ; return to caller

* Check module CRC
*
* Entry: X = Address of module to check.
Chk4CRC
                    lda       <D.CRC    ; is CRC checking on?
                    bne       DoCRCCk   ; branch if so
                    clrb                ; else clear carry
                    rts                 ; return to caller

* Check if module CRC checking is on
*
* Entry: X = Address of module to check.
DoCRCCk             pshs      x         ; save off module address onto stack
                    ldy       M$Size,x  ; get module size in module header
                    bsr       ChkMCRC   ; check module CRC
                    puls      pc,x      ; restore pc,x from the stack

* Check module header parity
*
* Entry: X = Module header to check.
*        Y = Pointer to parity byte.
ChkMHPar            pshs      y,x       ; save off X and Y
_stk1X@             set       0         ; define assembler symbol
_stk1Y@             set       2         ; define assembler symbol
                    clra                ; A = 0
loop@               eora      ,x+       ; xOR with
                    cmpx      _stk1Y@,s ; compare to address of parity byte
                    bls       loop@     ; branch if not there yet
                    cmpa      #$FF      ; parity check done... is it correct?
                    puls      pc,y,x    ; restore regs and return

* Check module CRC
*
* Entry: X = Address of potential module.
*        Y = Size of module.
ChkMCRC             ldd       #$FFFF    ; initialize D to $FFFF
                    pshs      b,a       ; save off stack
                    pshs      b,a       ; 32 bits
                    leau      1,s       ; advance one byte (24 byte CRC)
loop@               lda       ,x+       ; get next byte of module
                    bsr       CRCAlgo   ; perform algorithm
                    leay      -1,y      ; decrement Y (size of module)
                    bne       loop@     ; continue if not at end
                    clr       -1,u      ; clear first 8 bits of 32 bits
                    lda       ,u        ; get first byte of CRC
                    cmpa      #CRCCon1  ; is it what we expect?
                    bne       err@      ; branch if not
                    ldd       1,u       ; get next two bytes of CRC
                    cmpd      #CRCCon23 ; is it what we expect?
                    beq       ex@       ; branch if what we expect
err@                comb                ; ...else set carry
                    ldb       #E$BMCRC  ; load B with error
ex@                 puls      pc,y,x    ; return to caller

                  ELSE

FVModul             pshs      u         ; preserve register stack pointer
                    ldx       R$X,u     ; get block offset
                    ldy       R$D,u     ; get DAT image pointer
                    bsr       L0463     ; validate it
                    ldx       ,s        ; get register stack pointer
                    stu       R$U,x     ; save address of module directory entry
                    puls      u,pc      ; restore & return

* Validate module - shortcut for calls within OS9p1 go here (ex. OS9Boot)
* Entry: X=Module block offset
*        Y=Module DAT image pointer
L0463               pshs      x,y       ; save block offset & DAT Image ptr
                    lbsr      L0586     ; go check module ID & header parity
                    bcs       L0495     ; error, exit
                    ldd       #M$Type   ; get offset to module type
                    lbsr      L0B02     ; go get 2 bytes (module type)
                    andb      #LangMask ; just keep language mask
                    pshs      d         ; preserve ??? & language
                    ldd       #M$Name   ; get offset to module name
                    lbsr      L0B02     ; go get 2 bytes (offset)
                    leax      d,x       ; point X to module name
                    puls      a         ; restore type/language
                    lbsr      L068D     ; find module in module directory
                    puls      a         ; restore a from the stack
                    bcs       L0497     ; branch if carry is set to L0497
                    andb      #$0F      ; mask B with #$0F
                  IFNE    H6309   ; begin conditional assembly for H6309
                    subr      a,b
                  ELSE
                    pshs      a         ; save a on the stack
                    subb      ,s+       ; subtract ,s+ from B
                  ENDC
                    blo       L0497     ; if wrapped, skip ahead
                    ldb       #E$KwnMod ; load B from #E$KwnMod
                    fcb       $8C       ; skip 2 bytes
L0491               ldb       #E$DirFul ; load B from #E$DirFul
L0493               orcc      #Carry    ; set condition-code bits using #Carry
L0495               puls      x,y,pc    ; restore x,y,pc from the stack

L0497               ldx       ,s        ; load X from ,s
                  IFNE    H6309   ; begin conditional assembly for H6309
                    bsr       L0524     ; call local routine L0524
                  ELSE
                    lbsr      L0524     ; call local routine L0524
                  ENDC
                    bcs       L0491     ; branch if carry is set to L0491
                    sty       ,u        ; store Y at ,u
                    stx       MD$MPtr,u ; store X at MD$MPtr,u
                  IFNE    H6309   ; begin conditional assembly for H6309
                    clrd                ; update processor state
                  ELSE
                    clra                ; clear A
                    clrb                ; clear B
                  ENDC
                    std       MD$Link,u ; store D at MD$Link,u
                    ldd       #M$Size   ; get offset to size of module
                    lbsr      L0B02     ; get it
                  IFNE    H6309   ; begin conditional assembly for H6309
                    addr      x,d       ; add it to module ptr
                  ELSE
                    pshs      x         ; save x on the stack
                    addd      ,s++      ; add ,s++ to D
                  ENDC
                    std       MD$MBSiz,u ; store D at MD$MBSiz,u
                    ldy       [MD$MPDAT,u] ; get pointer to module DAT
                    ldx       <D.ModDir ; get module directory pointer
                    pshs      u         ; save module pointer
                    fcb       $8C       ; skip 2 bytes

L04BC               leax      MD$ESize,x ; move to next entry
L04BE               cmpx      <D.ModEnd ; compare X with <D.ModEnd
                    bcc       L04CD     ; branch if carry is clear to L04CD
                    cmpx      ,s        ; match?
                    beq       L04BC     ; no, keep looking
                    cmpy      [MD$MPDAT,x] ; dAT match?
                    bne       L04BC     ; no, keep looking
                    bsr       L04F2     ; call local routine L04F2

L04CD               puls      u         ; restore u from the stack
                    ldx       <D.BlkMap ; get ptr to block map
                    ldd       MD$MBSiz,u ; get size of module
                    addd      #$1FFF    ; round up to nearest 8K block
                    lsra                ; divide by 32
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    ldy       MD$MPDAT,u ; load Y from MD$MPDAT,u

                  IFNE    H6309   ; begin conditional assembly for H6309
                    tfr       a,e       ; transfer register value a,e
L04DE               ldd       ,y++      ; load D from ,y++
                    oim       #ModBlock,d,x
                    dece                ; update processor state
                  ELSE
L04DE               pshs      a,x       ; save block size, blkmap
                    ldd       ,y++      ; D = image block #
                    leax      d,x       ; X = blkmap ptr
                    ldb       ,x        ; get block marker
                    orb       #ModBlock ; set module in block
                    stb       ,x        ; marker
                    puls      x,a       ; restore x,a from the stack
                    deca                ; count--
                  ENDC
                    bne       L04DE     ; no, keep going
                    clrb                ; clear carry
                    puls      x,y,pc    ; return

L04F2               pshs      d,x,y,u   ; save d,x,y,u on the stack
* LCB - 6809 - this can be slightly sped up by swapping roles
                    ldx       ,x        ; load X from ,x
                  IFNE    H6309   ; begin conditional assembly for H6309
                    tfr       x,w       ; dupe to faster index register
                    clrd                ; update processor state
L04FA               ldy       ,w        ; load Y from ,w
                    beq       L0503     ; branch if zero is set to L0503
                    std       ,w++      ; store D at ,w++
                    bra       L04FA     ; branch unconditionally to L04FA
L0503               ldy       2,s       ; load Y from 2,s
                  ELSE
                    pshs      x         ; save x on the stack
                    clra                ; D=0000
                    clrb                ; clear B
L04FA               ldy       ,x        ; last entry?
                    beq       L0503     ; ..yes
                    std       ,x++      ; no, clear
                    bra       L04FA     ; and loop

* Entry: U=Ptr to current entry in module directory
*        Y=Ptr to entry in module directory we are comparing to
L0503               puls      x         ; restore x from the stack
                    ldy       2,s       ; get ptr to module dir entry we are comparing with
                  ENDC
*
                    ldu       MD$MPDAT,u ; get DAT img ptr for module
                    puls      d         ; restore d from the stack
L050C               cmpx      MD$MPDAT,y ; same as DAT img ptr for other module?
                    bne       L051B     ; no, check next one
                    stu       MD$MPDAT,y ; match; save current entry ptr here
                    cmpd      MD$MBSiz,y ; >memory block size already here?
* 6809/6309 LCB - couldn't we change next 2 lines to blo L051B
                    bhs       L0519     ; yes, use new one
                    ldd       MD$MBSiz,y ; no, get original and use that size instead
L0519               std       MD$MBSiz,y ; store D at MD$MBSiz,y
L051B               leay      MD$ESize,y ; bump ptr to next module dir entry
                    cmpy      <D.ModEnd ; are we at end of module dir?
                    bne       L050C     ; no,keep checking
                    puls      x,y,u,pc  ; restore x,y,u,pc from the stack

* Exit: B=MMU block # of some sort
L0524               pshs      x,y,u     ; save x,y,u on the stack
                    ldd       #M$Size   ; offset to module size
                    lbsr      L0B02     ; go get module size
                    addd      ,s        ; add to value
                    addd      #$1FFF    ; calc MMU block #
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    tfr       a,b       ; move block # to B
                    pshs      b         ; save it as well
                    comb                ; one byte shorter than incb;lslb;negb
                    lslb                ; (D=-B is what we are doing)
                    sex                 ; sign-extend B into A
                    bsr       L054E     ; call local routine L054E
                    bcc       L054C     ; branch if carry is clear to L054C
                    os9       F$GCMDir  ; get rid of empty slots in module directory
                  IFNE    H6309   ; begin conditional assembly for H6309
                    tfr       0,u       ; transfer register value 0,u
                  ELSE
                    ldu       #$0000    ; load U from #$0000
                  ENDC
                    stu       $05,s     ; save $0000 so U is 0 in puls below
                    bsr       L054E     ; call local routine L054E
L054C               puls      b,x,y,u,pc ; restore b,x,y,u,pc from the stack

* Entry: D=negative offset from end of module Dir DAT Img)
L054E               ldx       <D.ModDAT ; get end ptr of Module Dir DAT image
                    leax      d,x       ; add our negative offset
                    cmpx      <D.ModEnd ; is that past the end of the module directory?
                    blo       S.Poll    ; no, skip ahead
                    ldu       7,s       ; yes, get U from stack (0 means we compacted mod dir)
                    bne       L056E     ; not compacted, skip ahead
                    ldy       <D.ModEnd ; get ptr to end of module directory
                    leay      MD$ESize,y ; bump up by 1 entry
                  IFNE    H6309   ; begin conditional assembly for H6309
                    cmpr      x,y       Offset we did past new entry?
                  ELSE
                    pshs      x         ; offset we did past new entry?
                    cmpy      ,s++      ; compare Y with ,s++
                  ENDC
                    bhi       S.Poll    ; yes, skip ahead
                    sty       <D.ModEnd ; no, save new module directory end ptr
                    leay      -MD$ESize,y ; bump ptr back on entry
                    sty       $07,s     ; save that as new U on exit
L056E               stx       <D.ModDAT ; save new Module Dir DAT image end ptr
                  IFNE    H6309   ; begin conditional assembly for H6309
                    ldd       $05,s     ; get source ptr
                    stx       $05,s     ; store X at $05,s
                    ldf       2,s
                    clre                ; update processor state
                    rolw                ; update processor state
                    tfm       d+,x+
                    stw       ,x        Save 0
                  ELSE
                    ldy       5,s       ; load Y from 5,s
                    ldb       2,s       ; B=block count
                    stx       5,s       ; return dir datimg ptr
L0577               ldu       ,y++      ; copy images
                    stu       ,x++      ; to new mod dat entry
                    decb                ; decrement B
                    bne       L0577     ; branch if zero is clear to L0577
* 6809/6309 LCB - stb ,x - same size, faster (4 vs 6). Still need CLR
*  for clr 1,x to make sure carry is cleared
                    stb       ,x        ; zero flag
                    clr       1,x       ; & clear carry
                  ENDC
                    rts                 ; return to caller

* Default interrupt handling routine on first booting OS9p1
S.Poll              orcc      #Carry    ; set condition-code bits using #Carry
                    rts                 ; return to caller

* Check module ID & calculate module header parity & CRC
* Entry: X=Block offset of module
*        Y=DAT image pointer of module
L0586               pshs      x,y       ; save block offset & DAT pointer
                  IFNE    H6309   ; begin conditional assembly for H6309
                    clrd                ; m$ID offset
                  ELSE
                    clra                ; m$ID offset
                    clrb                ; clear B
                  ENDC
                    lbsr      L0B02     ; get module ID
                    cmpd      #M$ID12   ; legal module?
                    beq       L0597     ; yes, calculate header parity
                    ldb       #E$BMID   ; get bad module ID error
                    bra       L05F3     ; return error
* Calculate module header parity
L0597               leax      2,x       ; point to start location of header calc
                    lbsr      AdjBlk0   ; adjust it for block 0
                  IFNE    H6309   ; begin conditional assembly for H6309
                    ldw       #($4A*256+M$Revs) Get initial value & count (7 bytes of header)
L05A2               lbsr      LDAXY     ; get a byte from module
                    eorr      a,e       add it into running parity
                    decf                ; done full header?
                    bne       L05A2     ; no, keep going
                    ince                ; valid parity?
                  ELSE
                    leas      -1,s      ; make var
                    ldd       #($4A*256+M$Revs) ; get initial value & count (7 bytes of header)
L05A2               sta       ,s        ; save crc
                    lbsr      LDAXY     ; get next byte
                    eora      ,s        ; do crc
                    decb                ; more?
                    bne       L05A2     ; ..loop
                    leas      1,s       ; drop var
                    inca                ; $FF+1 = 00
                  ENDC
                    beq       L05B5     ; yes, skip ahead
                    ldb       #E$BMHP   ; get module header parity error
                    bra       L05F3     ; return with error

L05B5               puls      x,y       ; restore module pointer & DAT pointer
* this checks if the module CRC checking is on or off
                    lda       <D.CRC    ; is CRC checking on?
                    bne       L05BA     ; yes - go check it
                  IFNE    H6309   ; begin conditional assembly for H6309
                    clrd                ; no, clear out
                  ELSE
                    clra                ; clear A
                    clrb                ; clear B
                  ENDC
                    rts                 ; and return

* Begin checking Module CRC
* Entry: X=Module pointer
*        Y=DAT image pointer of module
L05BA               ldd       #M$Size   ; get offset to module size
                    lbsr      L0B02     ; get module size
                  IFNE    H6309   ; begin conditional assembly for H6309
                    tfr       d,w       ; move length to W
                    pshs      y,x       ; preserve [X]=Buffer pointer,[Y]=DAT pointer
                  ELSE
                    pshs      y,x,d     ; preserve [X]=Buffer pointer,[Y]=DAT pointer
                  ENDC
                    ldd       #$FFFF    ; initial CRC value of $FFFFFF
                    pshs      d         ; set up local 24 bit variable
                    pshs      b         ; save b on the stack
                    lbsr      AdjBlk0   ; adjust module pointer into block 0 for mapping
                    leau      ,s        ; point to CRC accumulator
* Loop: W=# bytes left to use in CRC calc
L05CB               equ       *         ; define assembler symbol
                  IFNE    H6309   ; begin conditional assembly for H6309
                    tstf                ; on 256 byte boundary?
                  ELSE
                    tstb                ; test B and update condition codes
                  ENDC
                    bne       L05D8     ; no, keep going
                    pshs      x         ; give up some time to system
                    ldx       #1        ; load X from #1
                    os9       F$Sleep   ; call OS-9 service F$Sleep
                    puls      x         ; restore module pointer
L05D8               lbsr      LDAXY     ; get a byte from module into A
                    bsr       CRCCalc   ; add it to running CRC
                  IFNE    H6309   ; begin conditional assembly for H6309
                    decw                ; dec # bytes left to calculate CRC with
                  ELSE
                    ldd       3,s       ; load D from 3,s
                    subd      #$0001    ; subtract #$0001 from D
                    std       3,s       ; store D at 3,s
                  ENDC
                    bne       L05CB     ; still more, continue
                  IFNE    H6309   ; begin conditional assembly for H6309
                    puls      b,x       ; yes, restore CRC
                  ELSE
                    puls      b,x,y     ; yes, restore CRC
                  ENDC
                    cmpb      #CRCCon1  ; cRC MSB match constant?
                    bne       L05F1     ; no, exit with error
                    cmpx      #CRCCon23 ; lSW match constant?
                    beq       L05F5     ; yes, skip ahead
L05F1               ldb       #E$BMCRC  ; bad Module CRC error
L05F3               orcc      #Carry    ; set up for error
L05F5               puls      x,y,pc    ; exit

* Calculate 24 bit CRC
* Entry: A=Byte to add to CRC
*        U=Pointer to 24 bit CRC accumulator
*
* Future reference note: Do not use W unless preserved, contains module
*                        byte counts from routines that come here!!
CRCCalc             eora      ,u        ; exclusive-OR A with ,u
                    pshs      a         ; save a on the stack
                    ldd       1,u       ; load D from 1,u
                    std       ,u        ; store D at ,u
                    clra                ; clear A
                    ldb       ,s        ; load B from ,s
                  IFNE    H6309   ; begin conditional assembly for H6309
                    lsld                ; shift or rotate and update condition codes
                  ELSE
                    aslb                ; update processor state
                    rola                ; shift or rotate and update condition codes
                  ENDC
                    eora      1,u       ; exclusive-OR A with 1,u
                    std       1,u       ; store D at 1,u
                    clrb                ; clear B
                    lda       ,s        ; load A from ,s
                  IFNE    H6309   ; begin conditional assembly for H6309
                    lsrd                ; shift or rotate and update condition codes
                    lsrd                ; shift or rotate and update condition codes
                    eord      1,u
                  ELSE
                    lsra                ; shift or rotate and update condition codes
                    rorb                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    rorb                ; shift or rotate and update condition codes
                    eora      1,u       ; exclusive-OR A with 1,u
                    eorb      2,u       ; exclusive-OR B with 2,u
                  ENDC
                    std       1,u       ; store D at 1,u
                    lda       ,s        ; load A from ,s
                    lsla                ; shift or rotate and update condition codes
                    eora      ,s        ; exclusive-OR A with ,s
                    sta       ,s        ; store A at ,s
                    lsla                ; shift or rotate and update condition codes
                    lsla                ; shift or rotate and update condition codes
                    eora      ,s        ; exclusive-OR A with ,s
                    sta       ,s        ; store A at ,s
                    lsla                ; shift or rotate and update condition codes
                    lsla                ; shift or rotate and update condition codes
                    lsla                ; shift or rotate and update condition codes
                    lsla                ; shift or rotate and update condition codes
                    eora      ,s+       ; exclusive-OR A with ,s+
                    bpl       L0635     ; branch if negative is clear to L0635
                  IFNE    H6309   ; begin conditional assembly for H6309
                    eim       #$80,,u
                    eim       #$21,2,u
                  ELSE
                    ldd       #$8021    ; load D from #$8021
                    eora      ,u        ; exclusive-OR A with ,u
                    sta       ,u        ; store A at ,u
                    eorb      2,u       ; exclusive-OR B with 2,u
                    stb       2,u       ; store B at 2,u
                  ENDC
L0635               rts                 ; return to caller

**************************************************
* System Call: F$CRC
*
* Function: Compute CRC
*
* Input:  X = Address to start computation
*         Y = Byte count
*         U = Address of 3 byte CRC accumulator
*
* Output: CRC accumulator is updated
*
* Error:  CC = C bit set; B = error code
*
FCRC                ldd       R$Y,u     ; get # bytes to do
                    beq       L0677     ; nothing there, so nothing to do, return
                    ldx       R$X,u     ; get caller's buffer pointer
                    pshs      d,x       ; save # bytes & buffer pointer
                    leas      -3,s      ; allocate a 3 byte buffer
                    ldx       <D.Proc   ; point to current process descriptor
                    lda       P$Task,x  ; get its task number
                    ldb       <D.SysTsk ; get the system task number
                    ldx       R$U,u     ; point to user's 24 bit CRC accumulator
                    ldy       #3        ; number of bytes to move
                    leau      ,s        ; point to our temp buffer
                    pshs      d,x,y     ; save [D]=task #'s,[X]=Buff,[Y]=3
                    lbsr      L0B2C     ; move CRC accumulator to temp buffer
                    ldx       <D.Proc   ; point to current process descriptor
                    leay      <P$DATImg,x ; point to its DAT image
                    ldx       11,s      ; restore the buffer pointer
                    lbsr      AdjBlk0   ; make callers buffer visible
                  IFNE    H6309   ; begin conditional assembly for H6309
                    ldw       9,s       get byte count
                  ENDC
L065D               lbsr      LDAXY     ; get byte from callers buffer
                    bsr       CRCCalc   ; add it to CRC
                  IFNE    H6309   ; begin conditional assembly for H6309
                    decw                ; done?
                  ELSE
                    ldd       9,s       ; load D from 9,s
                    subd      #$0001    ; subtract #$0001 from D
                    std       9,s       ; store D at 9,s
                  ENDC
                    bne       L065D     ; no, keep going
                    puls      d,x,y     ; restore pointers
                    exg       a,b       ; swap around the task numbers
                    exg       x,u       ; and the pointers
                    lbsr      L0B2C     ; move accumulator back to user
                    leas      7,s       ; clean up stack
L0677               clrb                ; no error
                    rts                 ; return to caller

                  ENDC
