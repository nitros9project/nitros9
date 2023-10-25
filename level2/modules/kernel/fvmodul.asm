**************************************************
* System Call: F$VModul
*
* Function: Validate a module.
*
* Checks the module header parity and (if enabled)
* the CRC bytes of the module.
*
* Input:  X = Address of module to verify
*         D = DAT image pointer
*
* Output: U = Address of module directory entry
*
* Error:  CC = C bit set; B = error code
*
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
                    lbsr      L0524
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
                    lbsr      L0B02
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
L0503               puls      x
                    ldy       2,s
                    endc

                    ldu       MD$MPDAT,u
                    puls      d

L050C               cmpx      MD$MPDAT,y
                    bne       L051B
                    stu       MD$MPDAT,y
                    cmpd      MD$MBSiz,y
                    bcc       L0519
                    ldd       MD$MBSiz,y
L0519               std       MD$MBSiz,y
L051B               leay      MD$ESize,y
                    cmpy      <D.ModEnd
                    bne       L050C
                    puls      x,y,u,pc

L0524               pshs      x,y,u
                    ldd       #M$Size
                    lbsr      L0B02
                    addd      ,s
                    addd      #$1FFF
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    tfr       a,b
                    pshs      b
*         incb
                    comb                          one byte shorter than incb;lslg;negb
                    lslb
*         negb
                    sex
                    bsr       L054E
                    bcc       L054C
                    os9       F$GCMDir            get rid of empty slots in module directory
                    ifne      H6309
                    tfr       0,u
                    else
                    ldu       #$0000
                    endc
                    stu       $05,s
                    bsr       L054E
L054C               puls      b,x,y,u,pc

L054E               ldx       <D.ModDAT
                    leax      d,x
                    cmpx      <D.ModEnd
                    bcs       S.Poll
                    ldu       7,s
                    bne       L056E
                    ldy       <D.ModEnd
                    leay      MD$ESize,y
                    ifne      H6309
                    cmpr      x,y
                    else
                    pshs      x
                    cmpy      ,s++
                    endc
                    bhi       S.Poll
                    sty       <D.ModEnd
                    leay      -MD$ESize,y
                    sty       $07,s
L056E               stx       <D.ModDAT
                    ifne      H6309
                    ldd       $05,s               Get source ptr
                    stx       $05,s
                    ldf       2,s
                    clre
                    rolw
                    tfm       d+,x+
                    stw       ,x                  Save 0
                    else
                    ldy       5,s
                    ldb       2,s                 B=block count
                    stx       5,s                 return dir datimg ptr
L0577               ldu       ,y++                copy images
                    stu       ,x++                to new mod dat entry
                    decb
                    bne       L0577
                    clr       ,x                  zero flag
                    clr       1,x
                    endc
                    rts

* Default interrupt handling routine on first booting OS9p1
S.Poll              orcc      #Carry
                    rts

* Check module ID & calculate module header parity & CRC
* Entry: X=Block offset of module
*        Y=DAT image pointer of module
L0586               pshs      x,y                 save block offset & DAT pointer
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    lbsr      L0B02               get module ID
                    cmpd      #M$ID12             legal module?
                    beq       L0597               yes, calculate header parity
                    ldb       #E$BMID             get bad module ID error
                    bra       L05F3               return error
* Calculate module header parity
L0597               leax      2,x                 point to start location of header calc
                    lbsr      AdjBlk0             adjust it for block 0
                    ifne      H6309
                    ldw       #($4A*256+M$Revs)   Get initial value & count (7 bytes of header)
L05A2               lbsr      LDAXY               get a byte from module
                    eorr      a,e                 add it into running parity
                    decf                          done full header?
                    bne       L05A2               no, keep going
                    ince                          valid parity?
                    else
                    leas      -1,s                make var
                    ldd       #($4A*256+M$Revs)   Get initial value & count (7 bytes of header)
L05A2               sta       ,s                  save crc
                    lbsr      LDAXY               get next byte
                    eora      ,s                  do crc
                    decb                          more?
                    bne       L05A2               ..loop
                    leas      1,s                 drop var
                    inca                          $FF+1 = 00
                    endc
                    beq       L05B5               yes, skip ahead
                    ldb       #E$BMHP             get module header parity error
                    bra       L05F3               return with error
L05B5               puls      x,y                 restore module pointer & DAT pointer
* this checks if the module CRC checking is on or off
                    lda       <D.CRC              is CRC checking on?
                    bne       L05BA               yes - go check it
                    ifne      H6309
                    clrd                          no, clear out
                    else
                    clra
                    clrb
                    endc
                    rts                           and return
* Begin checking Module CRC
* Entry: X=Module pointer
*        Y=DAT image pointer of module
L05BA               ldd       #M$Size             get offset to module size
                    lbsr      L0B02               get module size
                    ifne      H6309
                    tfr       d,w                 move length to W
                    pshs      y,x                 preserve [X]=Buffer pointer,[Y]=DAT pointer
                    else
                    pshs      y,x,b,a             preserve [X]=Buffer pointer,[Y]=DAT pointer
                    endc
                    ldd       #$FFFF              initial CRC value of $FFFFFF
                    pshs      d                   set up local 24 bit variable
                    pshs      b
                    lbsr      AdjBlk0             adjust module pointer into block 0 for mapping
                    leau      ,s                  point to CRC accumulator
* Loop: W=# bytes left to use in CRC calc
L05CB               equ       *
                    ifne      H6309
                    tstf                          on 256 byte boundary?
                    else
                    tstb
                    endc
                    bne       L05D8               no, keep going
                    pshs      x                   give up some time to system
                    ldx       #1
                    os9       F$Sleep
                    puls      x                   restore module pointer
L05D8               lbsr      LDAXY               get a byte from module into A
                    bsr       CRCCalc             add it to running CRC
                    ifne      H6309
                    decw                          Dec # bytes left to calculate CRC with
                    else
                    ldd       3,s
                    subd      #$0001
                    std       3,s
                    endc
                    bne       L05CB               Still more, continue
                    ifne      H6309
                    puls      b,x                 yes, restore CRC
                    else
                    puls      b,x,y               yes, restore CRC
                    endc
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
                    ifne      H6309
                    lsld
                    else
                    aslb
                    rola
                    endc
                    eora      1,u
                    std       1,u
                    clrb
                    lda       ,s
                    ifne      H6309
                    lsrd
                    lsrd
                    eord      1,u
                    else
                    lsra
                    rorb
                    lsra
                    rorb
                    eora      1,u
                    eorb      2,u
                    endc
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
                    ifne      H6309
                    eim       #$80,,u
                    eim       #$21,2,u
                    else
                    ldd       #$8021
                    eora      ,u
                    sta       ,u
                    eorb      2,u
                    stb       2,u
                    endc
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
                    ifne      H6309
                    ldw       9,s                 get byte count
                    endc
L065D               lbsr      LDAXY               get byte from callers buffer
                    bsr       CRCCalc             add it to CRC
                    ifne      H6309
                    decw                          done?
                    else
                    ldd       9,s
                    subd      #$0001
                    std       9,s
                    endc
                    bne       L065D               no, keep going
                    puls      d,x,y               restore pointers
                    exg       a,b                 swap around the task numbers
                    exg       x,u                 and the pointers
                    lbsr      L0B2C               move accumulator back to user
                    leas      7,s                 clean up stack
L0677               clrb                          no error
                    rts
