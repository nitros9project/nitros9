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

                    ifeq      Level-1
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

                    else

FVModul             pshs      u                   preserve register stack pointer
                    ldx       R$X,u               get block offset
                    ldy       R$D,u               get DAT image pointer
                    bsr       L0463               validate it
                    ldx       ,s                  get register stack pointer
                    stu       R$U,x               save address of module directory entry
                    puls      u,pc                restore & return

* Validate module - shortcut for calls within OS9p1 go here (ex. OS9Boot)
* Entry: X=Module block offset
*        Y=Module DAT image pointer
L0463               pshs      x,y                 save block offset & DAT Image ptr
                    lbsr      L0586               Go check module ID & header parity
                    bcs       L0495               Error, exit
                    ldd       #M$Type             Get offset to module type
                    lbsr      L0B02               go get 2 bytes (module type)
                    andb      #LangMask           Just keep language mask
                    pshs      d                   Preserve ??? & language
                    ldd       #M$Name             get offset to module name
                    lbsr      L0B02               go get 2 bytes (offset)
                    leax      d,x                 Point X to module name
                    puls      a                   Restore type/language
                    lbsr      L068D               Find module in module directory
                    puls      a
                    bcs       L0497
                    andb      #$0F
                    ifne      H6309
                    subr      a,b
                    else
                    pshs      a
                    subb      ,s+
                    endc
                    blo       L0497               If wrapped, skip ahead
                    ldb       #E$KwnMod
                    fcb       $8C                 skip 2 bytes
L0491               ldb       #E$DirFul
L0493               orcc      #Carry
L0495               puls      x,y,pc

L0497               ldx       ,s
                    ifne      H6309
                    bsr       L0524
                    else
                    lbsr      L0524
                    endc
                    bcs       L0491
                    sty       ,u
                    stx       MD$MPtr,u
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       MD$Link,u
                    ldd       #M$Size             Get offset to size of module
                    lbsr      L0B02               get it
                    ifne      H6309
                    addr      x,d                 Add it to module ptr
                    else
                    pshs      x
                    addd      ,s++
                    endc
                    std       MD$MBSiz,u
                    ldy       [MD$MPDAT,u]        get pointer to module DAT
                    ldx       <D.ModDir           get module directory pointer
                    pshs      u                   save module pointer
                    fcb       $8C                 skip 2 bytes

L04BC               leax      MD$ESize,x          move to next entry
L04BE               cmpx      <D.ModEnd
                    bcc       L04CD
                    cmpx      ,s                  match?
                    beq       L04BC               no, keep looking
                    cmpy      [MD$MPDAT,x]        DAT match?
                    bne       L04BC               no, keep looking
                    bsr       L04F2

L04CD               puls      u
                    ldx       <D.BlkMap           Get ptr to block map
                    ldd       MD$MBSiz,u          Get size of module
                    addd      #$1FFF              Round up to nearest 8K block
                    lsra                          Divide by 32
                    lsra
                    lsra
                    lsra
                    lsra
                    ldy       MD$MPDAT,u

                    ifne      H6309
                    tfr       a,e
L04DE               ldd       ,y++
                    oim       #ModBlock,d,x
                    dece
                    else
L04DE               pshs      a,x                 save block size, blkmap
                    ldd       ,y++                D = image block #
                    leax      d,x                 X = blkmap ptr
                    ldb       ,x                  get block marker
                    orb       #ModBlock           set module in block
                    stb       ,x                  marker
                    puls      x,a
                    deca                          count--
                    endc
                    bne       L04DE               no, keep going
                    clrb                          clear carry
                    puls      x,y,pc              return

L04F2               pshs      d,x,y,u
* LCB - 6809 - this can be slightly sped up by swapping roles
                    ldx       ,x
                    ifne      H6309
                    tfr       x,w                 Dupe to faster index register
                    clrd
L04FA               ldy       ,w
                    beq       L0503
                    std       ,w++
                    bra       L04FA
L0503               ldy       2,s
                    else
                    pshs      x
                    clra                          D=0000
                    clrb
L04FA               ldy       ,x                  last entry?
                    beq       L0503               ..yes
                    std       ,x++                no, clear
                    bra       L04FA               and loop

* Entry: U=Ptr to current entry in module directory
*        Y=Ptr to entry in module directory we are comparing to
L0503               puls      x
                    ldy       2,s                 Get ptr to module dir entry we are comparing with
                    endc
*
                    ldu       MD$MPDAT,u          Get DAT img ptr for module
                    puls      d
L050C               cmpx      MD$MPDAT,y          Same as DAT img ptr for other module?
                    bne       L051B               No, check next one
                    stu       MD$MPDAT,y          Match; save current entry ptr here
                    cmpd      MD$MBSiz,y          >memory block size already here?
* 6809/6309 LCB - couldn't we change next 2 lines to blo L051B
                    bhs       L0519               Yes, use new one
                    ldd       MD$MBSiz,y          No, get original and use that size instead
L0519               std       MD$MBSiz,y
L051B               leay      MD$ESize,y          Bump ptr to next module dir entry
                    cmpy      <D.ModEnd           Are we at end of module dir?
                    bne       L050C               No,keep checking
                    puls      x,y,u,pc

* Exit: B=MMU block # of some sort
L0524               pshs      x,y,u
                    ldd       #M$Size             Offset to module size
                    lbsr      L0B02               Go get module size
                    addd      ,s                  Add to value
                    addd      #$1FFF              Calc MMU block #
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    tfr       a,b                 Move block # to B
                    pshs      b                   Save it as well
                    comb                          one byte shorter than incb;lslb;negb
                    lslb                          (D=-B is what we are doing)
                    sex
                    bsr       L054E
                    bcc       L054C
                    os9       F$GCMDir            get rid of empty slots in module directory
                    IFNE      H6309
                    tfr       0,u
                    ELSE
                    ldu       #$0000
                    ENDC
                    stu       $05,s               Save $0000 so U is 0 in puls below
                    bsr       L054E
L054C               puls      b,x,y,u,pc

* Entry: D=negative offset from end of module Dir DAT Img)
L054E               ldx       <D.ModDAT           get end ptr of Module Dir DAT image
                    leax      d,x                 Add our negative offset
                    cmpx      <D.ModEnd           Is that past the end of the module directory?
                    blo       S.Poll              no, skip ahead
                    ldu       7,s                 Yes, get U from stack (0 means we compacted mod dir)
                    bne       L056E               Not compacted, skip ahead
                    ldy       <D.ModEnd           Get ptr to end of module directory
                    leay      MD$ESize,y          Bump up by 1 entry
                    IFNE      H6309
                    cmpr      x,y                 Offset we did past new entry?
                    ELSE
                    pshs      x                   Offset we did past new entry?
                    cmpy      ,s++
                    ENDC
                    bhi       S.Poll              Yes, skip ahead
                    sty       <D.ModEnd           No, save new module directory end ptr
                    leay      -MD$ESize,y         Bump ptr back on entry
                    sty       $07,s               Save that as new U on exit
L056E               stx       <D.ModDAT           Save new Module Dir DAT image end ptr
                    IFNE      H6309
                    ldd       $05,s               Get source ptr
                    stx       $05,s
                    ldf       2,s
                    clre
                    rolw
                    tfm       d+,x+
                    stw       ,x                  Save 0
                    ELSE
                    ldy       5,s
                    ldb       2,s                 B=block count
                    stx       5,s                 return dir datimg ptr
L0577               ldu       ,y++                copy images
                    stu       ,x++                to new mod dat entry
                    decb
                    bne       L0577
* 6809/6309 LCB - stb ,x - same size, faster (4 vs 6). Still need CLR
*  for clr 1,x to make sure carry is cleared
                    stb       ,x                  zero flag
                    clr       1,x                 & clear carry
                    ENDC
                    rts

* Default interrupt handling routine on first booting OS9p1
S.Poll              orcc      #Carry
                    rts

* Check module ID & calculate module header parity & CRC
* Entry: X=Block offset of module
*        Y=DAT image pointer of module
L0586               pshs      x,y                 save block offset & DAT pointer
                    IFNE      H6309
                    clrd                          M$ID offset
                    ELSE
                    clra                          M$ID offset
                    clrb
                    ENDC
                    lbsr      L0B02               get module ID
                    cmpd      #M$ID12             legal module?
                    beq       L0597               yes, calculate header parity
                    ldb       #E$BMID             get bad module ID error
                    bra       L05F3               return error
* Calculate module header parity
L0597               leax      2,x                 point to start location of header calc
                    lbsr      AdjBlk0             adjust it for block 0
                    IFNE      H6309
                    ldw       #($4A*256+M$Revs)   Get initial value & count (7 bytes of header)
L05A2               lbsr      LDAXY               get a byte from module
                    eorr      a,e                 add it into running parity
                    decf                          done full header?
                    bne       L05A2               no, keep going
                    ince                          valid parity?
                    ELSE
                    leas      -1,s                make var
                    ldd       #($4A*256+M$Revs)   Get initial value & count (7 bytes of header)
L05A2               sta       ,s                  save crc
                    lbsr      LDAXY               get next byte
                    eora      ,s                  do crc
                    decb                          more?
                    bne       L05A2               ..loop
                    leas      1,s                 drop var
                    inca                          $FF+1 = 00
                    ENDC
                    beq       L05B5               yes, skip ahead
                    ldb       #E$BMHP             get module header parity error
                    bra       L05F3               return with error

L05B5               puls      x,y                 restore module pointer & DAT pointer
* this checks if the module CRC checking is on or off
                    lda       <D.CRC              is CRC checking on?
                    bne       L05BA               yes - go check it
                    IFNE      H6309
                    clrd                          no, clear out
                    ELSE
                    clra
                    clrb
                    ENDC
                    rts                           and return

* Begin checking Module CRC
* Entry: X=Module pointer
*        Y=DAT image pointer of module
L05BA               ldd       #M$Size             get offset to module size
                    lbsr      L0B02               get module size
                    IFNE      H6309
                    tfr       d,w                 move length to W
                    pshs      y,x                 preserve [X]=Buffer pointer,[Y]=DAT pointer
                    ELSE
                    pshs      y,x,d               preserve [X]=Buffer pointer,[Y]=DAT pointer
                    ENDC
                    ldd       #$FFFF              initial CRC value of $FFFFFF
                    pshs      d                   set up local 24 bit variable
                    pshs      b
                    lbsr      AdjBlk0             adjust module pointer into block 0 for mapping
                    leau      ,s                  point to CRC accumulator
* Loop: W=# bytes left to use in CRC calc
L05CB               equ       *
                    IFNE      H6309
                    tstf                          on 256 byte boundary?
                    ELSE
                    tstb
                    ENDC
                    bne       L05D8               no, keep going
                    pshs      x                   give up some time to system
                    ldx       #1
                    os9       F$Sleep
                    puls      x                   restore module pointer
L05D8               lbsr      LDAXY               get a byte from module into A
                    bsr       CRCCalc             add it to running CRC
                    IFNE      H6309
                    decw                          Dec # bytes left to calculate CRC with
                    ELSE
                    ldd       3,s
                    subd      #$0001
                    std       3,s
                    ENDC
                    bne       L05CB               Still more, continue
                    IFNE      H6309
                    puls      b,x                 yes, restore CRC
                    ELSE
                    puls      b,x,y               yes, restore CRC
                    ENDC
                    cmpb      #CRCCon1            CRC MSB match constant?
                    bne       L05F1               no, exit with error
                    cmpx      #CRCCon23           LSW match constant?
                    beq       L05F5               yes, skip ahead
L05F1               ldb       #E$BMCRC            Bad Module CRC error
L05F3               orcc      #Carry              Set up for error
L05F5               puls      x,y,pc              exit

* Calculate 24 bit CRC
* Entry: A=Byte to add to CRC
*        U=Pointer to 24 bit CRC accumulator
*
* Future reference note: Do not use W unless preserved, contains module
*                        byte counts from routines that come here!!
CRCCalc             eora      ,u
                    pshs      a
                    ldd       1,u
                    std       ,u
                    clra
                    ldb       ,s
                    IFNE      H6309
                    lsld
                    ELSE
                    aslb
                    rola
                    ENDC
                    eora      1,u
                    std       1,u
                    clrb
                    lda       ,s
                    IFNE      H6309
                    lsrd
                    lsrd
                    eord      1,u
                    ELSE
                    lsra
                    rorb
                    lsra
                    rorb
                    eora      1,u
                    eorb      2,u
                    ENDC
                    std       1,u
                    lda       ,s
                    lsla
                    eora      ,s
                    sta       ,s
                    lsla
                    lsla
                    eora      ,s
                    sta       ,s
                    lsla
                    lsla
                    lsla
                    lsla
                    eora      ,s+
                    bpl       L0635
                    IFNE      H6309
                    eim       #$80,,u
                    eim       #$21,2,u
                    ELSE
                    ldd       #$8021
                    eora      ,u
                    sta       ,u
                    eorb      2,u
                    stb       2,u
                    ENDC
L0635               rts

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
FCRC                ldd       R$Y,u               get # bytes to do
                    beq       L0677               nothing there, so nothing to do, return
                    ldx       R$X,u               get caller's buffer pointer
                    pshs      d,x                 save # bytes & buffer pointer
                    leas      -3,s                allocate a 3 byte buffer
                    ldx       <D.Proc             point to current process descriptor
                    lda       P$Task,x            get its task number
                    ldb       <D.SysTsk           get the system task number
                    ldx       R$U,u               point to user's 24 bit CRC accumulator
                    ldy       #3                  number of bytes to move
                    leau      ,s                  point to our temp buffer
                    pshs      d,x,y               save [D]=task #'s,[X]=Buff,[Y]=3
                    lbsr      L0B2C               move CRC accumulator to temp buffer
                    ldx       <D.Proc             point to current process descriptor
                    leay      <P$DATImg,x         point to its DAT image
                    ldx       11,s                restore the buffer pointer
                    lbsr      AdjBlk0             make callers buffer visible
                    IFNE      H6309
                    ldw       9,s                 get byte count
                    ENDC
L065D               lbsr      LDAXY               get byte from callers buffer
                    bsr       CRCCalc             add it to CRC
                    IFNE      H6309
                    decw                          done?
                    ELSE
                    ldd       9,s
                    subd      #$0001
                    std       9,s
                    ENDC
                    bne       L065D               no, keep going
                    puls      d,x,y               restore pointers
                    exg       a,b                 swap around the task numbers
                    exg       x,u                 and the pointers
                    lbsr      L0B2C               move accumulator back to user
                    leas      7,s                 clean up stack
L0677               clrb                          no error
                    rts

                    endc
