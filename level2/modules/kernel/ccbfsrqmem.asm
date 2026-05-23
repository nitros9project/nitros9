**************************************************
* System Call: F$SRqMem
*
* Function: Request memory
*
* F$SRqMem allocates memory from the system's 64K address space in 256 byte 'pages.'
* There are 256 of these '256 byte pages' in the system's RAM area (256*256=64K).
* The allocation map, pointed to by D.SysMem holds one byte per page, making the
* allocation map itself 256 bytes in size.
*
* Memory is allocated from the top of the system RAM map downwards.  Rel/Boot/Krn
* also reside in this area, and are loaded from $ED00-$FFFF.  Since this area is
* always allocated, we start searching for free pages from page $EC downward.
*
* F$SRqMem also updates the system memory map according to 8K DAT blocks. If an
* empty block is found, this routine re-does the 32 entries in the SMAP table to
* indicate that they are free.
*
* Input:  D = Byte count
*
* Output: U = Address of allocated memory area
*
* Error:  CC = C bit set; B = error code
*
FSRqMem             ldd       R$D,u     ; get memory allocation size requested
                    addd      #$00FF    ; round it up to nearest 256 byte page (e.g. $1FF = $2FE)
                    clrb                ; just keep # of pages (and start 8K block #, e.g. $2FE = $200)
                    std       R$D,u     ; save rounded version back to user
*         leay  Bt.Start/256,y
*         leay  $20,y        skip Block 0 (always reserved for system)
* Change to pshs a,b:use 1,s for block # to check, and ,s for TFM spot
*         incb               skip block 0 (always reserved for system)
                    pshs      d         ; reserve a byte & put 0 byte on stack


* IMPORTANT!!!
* The following code was put in some time back to fix a problem.  That problem was not documented
* so I cannot recall why this code was in place.  What it appears to do is reset the system page
* memory map based upon the state of the system DAT image.
* This code really slows down F$SRqMem and since that system call is used quite often in the system,
* I am commenting it out in the hopes that I can remember what the hell I put it in for. -- Boisy
                  IFEQ    1       ; begin conditional assembly for 1
                    ldy       <D.SysMem ; get ptr to SMAP table
* This loop updates the SMAP table if anything can be marked as unused
FSrqmemSystemDATBlockList ldx       <D.SysDAT ; get pointer to system DAT block list
                    lslb                ; adjust block offset for 2 bytes/entry
                    ldd       b,x       ; get block type/# from system DAT
                    cmpd      #DAT.Free ; unused block?
                    beq       FSrqmemFillSystemPageMapNot ; yes, mark it free in SMAP table
                    ldx       <D.BlkMap ; no, get ptr to MMAP table
                    lda       d,x       ; get block marker for 2 meg mem map
                    cmpa      #RAMinUse ; is it in use (not free, ROM or used by module)?
                    bne       FSrqmemPut ; no, mark it as type it is in SMAP table
                    leay      32,y      ; yes, move to next block in pages
                    bra       FSrqmemBumpUpBlockCheck ; move to next block & try again
* Free RAM:
FSrqmemFillSystemPageMapNot clra                ; byte to fill system page map with (0=Not in use)
* NOT! RAMinUse:
                  IFNE    H6309   ; begin conditional assembly for H6309
FSrqmemPut          sta       ,s        ; put it on stack
                    ldw       #$0020    ; get size of 8K block in pages
                    tfm       s,y+      ; mark entire block's worth of pages with A
                  ELSE
FSrqmemPut          ldb       #32       ; count = 32 pages
FSrqmemMarkRAM      sta       ,y+       ; mark the RAM
                    decb                ; decrement B
                    bne       FSrqmemMarkRAM ; branch if zero is clear to FSrqmemMarkRAM
                  ENDC
FSrqmemBumpUpBlockCheck inc       1,s       ; bump up to next block to check
                    ldb       1,s       ; get it
                    cmpb      #DAT.BlCt ; done whole 64k system space?
                    blo       FSrqmemSystemDATBlockList ; no, keep checking
                  ENDC


* Now we can actually attempt to allocate the system RAM requested
* NOTE: Opt for CoCo/TC9 OS9 ONLY: skip last 256 - Bt.Start pages since
* they are: Kernel (REL/BOOT/KRN - 17 pages), vector RAM & I/O (2 pages)
* (Already permanently marked @ L01D2)
* At the start, Y is pointing to the end of the SMAP table+1
                    ldx       <D.SysMem ; get start of table ptr
                    *         CCB       change - start scanning from f000 down, rather than ec00
                    *         leay      Bt.Start/256,x
                    leay      $ff00/256,x ; compute $ff00/256,x into Y
                    *         end       of CCB change
                    ldb       #32       ; skip block 0: it's always full
                    abx                 ; same size, but faster than leax $20,x
*         leay  -(256-(Bt.Start>>8)),y  skip Kernel, Vector RAM & I/O (Can't be free)
FSrqmemNumberPagesRequested ldb       R$A,u     ; get # 256 byte pages requested
* Loop (from end of system mem map) to look for # continuous pages requested
FSrqmemJoin         equ       *         ; define assembler symbol FSrqmemJoin
                  IFNE    H6309   ; begin conditional assembly for H6309
                    cmpr      x,y       ; we still have any system RAM left to try?
                  ELSE
                    pshs      x         ; save x on the stack
                    cmpy      ,s++      ; compare Y with ,s++
                  ENDC
                    bhi       FSrqmemPageMarkerStartingEndSystem ; yes, continue
                    comb                ; exit with No System RAM Error
                    ldb       #E$NoRAM  ; load B from #E$NoRAM
                    bra       FSrqmemExit ; eat stack & exit

FSrqmemPageMarkerStartingEndSystem lda       ,-y       ; get page marker (starting @ end of SMAP)
                    bne       FSrqmemNumberPagesRequested ; used, try next lower page
                    decb                ; found 1 page, dec # pages we need to allocate
                    bne       FSrqmemJoin ; still more pages needed, check if we can get more
                    sty       ,s        ; found free contiguous pages, save SMAP entry ptr
                    lda       1,s       ; get LSB of ptr
                    lsra                ; divide by 32 (Calculate start 8K block #)
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    ldb       1,s       ; get LSB of ptr again
                    andb      #%00011111 ; keep only within 8K block offset
                    addb      R$A,u     ; add # pages requested
                    addb      #$1F      ; round up to nearest 8K block
                    lsrb                ; divide by 32 (Calculate end 8K block #)
                    lsrb                ; shift or rotate and update condition codes
                    lsrb                ; shift or rotate and update condition codes
                    lsrb                ; shift or rotate and update condition codes
                    lsrb                ; shift or rotate and update condition codes
                    ldx       <D.SysPrc ; get ptr to system proc. dsc.
                    lbsr      FAllimgTarget ; allocate an image with our start/end block #'s
                    bcs       FSrqmemExit ; couldn't, exit with error
                    ldb       R$A,u     ; get # pages requested
*         lda   #RAMinUse    Get SMAP in use flag
*L088A    sta   ,y+          Mark all the pages requested as In Use
FSrqmemSinceRaminuseWeCanSpace inc       ,y+       ; since RAMinUse is 1, we can save space by INC'ing from 0->1
                    decb                ; decrement B
                    bne       FSrqmemSinceRaminuseWeCanSpace ; branch if zero is clear to FSrqmemSinceRaminuseWeCanSpace
                    lda       1,s       ; get MSB of ptr to start of newly allocated Sys RAM
                    std       R$U,u     ; save for caller
                    clrb                ; no error
FSrqmemExit         puls      u,pc      ; eat stack (U is changed after it exits) & return


**************************************************
* System Call: F$SRtMem
*
* Function: Return memory
*
* Input:  U = Address of memory to return
*         D = Number of bytes to return
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FSRtMem             ldd       R$D,u     ; get # pages to free up
                    beq       FSrqmemErrorCarry ; nothing to free, return without error
                    addd      #$00FF    ; round it up to nearest page
                    ldb       R$U+1,u   ; get LSB of address
                    beq       FSrqmemMsbPage ; it's a even page, skip ahead
                    comb                ; set carry
                    ldb       #E$BPAddr ; get error code
                    rts                 ; return

FSrqmemMsbPage      ldb       R$U,u     ; get MSB of page address
                    beq       FSrqmemErrorCarry ; not a legal page, return without error
                    ldx       <D.SysMem ; get pointer to system memory map
                    abx                 ; set pointer into map
FSrqmemJoin2        equ       *         ; define assembler symbol FSrqmemJoin2
                  IFNE    H6309   ; begin conditional assembly for H6309
                    aim       #^RAMinUse,,x+ ; apply immediate bit operation #^RAMinUse,,x+
                  ELSE
                    ldb       ,x        ; load B from ,x
                    andb      #^RAMinUse ; mask B with #^RAMinUse
                    stb       ,x+       ; store B at ,x+
                  ENDC
                    deca                ; decrement A
                    bne       FSrqmemJoin2 ; branch if zero is clear to FSrqmemJoin2
* Scan DAT image to find memory blocks to free up
                    ldx       <D.SysDAT ; get pointer to system DAT image
                  IFNE    H6309   ; begin conditional assembly for H6309
                    lde       #DAT.BlCt ; get # blocks to check
                  ELSE
                    ldy       #DAT.BlCt ; load Y from #DAT.BlCt
                  ENDC
FSrqmemBlockImage   ldd       ,x        ; get block image
                    cmpd      #DAT.Free ; is it already free?
                    beq       FSrqmemDATBlock ; yes, skip to next one
                    ldu       <D.BlkMap ; get pointer to MMU block map
                    lda       d,u       ; get allocation flag for this block: 16-bit offset
                    cmpa      #RAMinUse ; being used?
                    bne       FSrqmemDATBlock ; no, move to next block
                    tfr       x,d       ; transfer register value x,d
                    subd      <D.SysDAT ; subtract <D.SysDAT from D
                    lslb                ; shift or rotate and update condition codes
                    lslb                ; shift or rotate and update condition codes
                    lslb                ; shift or rotate and update condition codes
                    lslb                ; shift or rotate and update condition codes
                    ldu       <D.SysMem ; get pointer to system map
                  IFNE    H6309   ; begin conditional assembly for H6309
                    addr      d,u       ; add d,u to destination register
* Check if we can remove the entire memory block from system map
                    ldf       #16       ; get # pages per block/2
FSrqmemEitherThesePagesAllocated ldd       ,u++      ; either of these 2 pages allocated?
                  ELSE
                    leau      d,u       ; compute d,u into U
                    ldb       #32       ; load B from #32
FSrqmemEitherThesePagesAllocated lda       ,u+       ; either of these 2 pages allocated?
                  ENDC
                    bne       FSrqmemDATBlock ; yes, can't free block, skip to next one
                  IFNE    H6309   ; begin conditional assembly for H6309
                    decf                ; checked all pages?
                  ELSE
                    decb                ; decrement B
                  ENDC
                    bne       FSrqmemEitherThesePagesAllocated ; no, keep looking
                    ldd       ,x        ; get block # into B: could be >$80
                    ldu       <D.BlkMap ; point to allocation table
                  IFNE    H6309   ; begin conditional assembly for H6309
                    sta       d,u       ; clear the block using 16-bit offset
                  ELSE
                    clr       d,u       ; clear d,u
                  ENDC
                    ldd       #DAT.Free ; get free block marker
                    std       ,x        ; save it into DAT image
FSrqmemDATBlock     leax      2,x       ; move to next DAT block
                  IFNE    H6309   ; begin conditional assembly for H6309
                    dece                ; done?
                  ELSE
                    leay      -1,y      ; compute -1,y into Y
                  ENDC
                    bne       FSrqmemBlockImage ; no, keep checking
FSrqmemErrorCarry   clrb                ; clear errors
FSrqmemReturn       rts                 ; return


**************************************************
* System Call: F$Boot
*
* Function: Bootstrap the system
*
* Optimized for size, as it's only called once...
*
* Input:  None
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FBoot
                    **        CCB       change: just panic
                    lda       #'t       ; tried to boot
                    jsr       <D.BtBug  ; call routine at <D.BtBug
                    jmp       <D.Crash  ; transfer control to <D.Crash
                    **
                    coma                ; set boot flag
                    lda       <D.Boot   ; we booted once before?
                    bne       FSrqmemReturn ; yes, return
                    inc       <D.Boot   ; set boot flag
                    ldx       <D.Init   ; get ptr to init module if it exists
                    beq       FSrqmemBootPcr ; it doesn't, point to boot name
                    ldd       <BootStr,x ; get offset to text
                    beq       FSrqmemBootPcr ; doesn't exist, get hard coded text
                    leax      d,x       ; adjust X to point to boot module
                    bra       FSrqmemSystmObjct ; try & link to module

boot                fcs       /Boot/

FSrqmemBootPcr      leax      <boot,pcr ; compute <boot,pcr into X
* Link to module and execute
FSrqmemSystmObjct   lda       #Systm+Objct ; load A from #Systm+Objct
                    os9       F$Link    ; call OS-9 service F$Link
                    bcs       FSrqmemReturn ; branch if carry is set to FSrqmemReturn
                    lda       #'b       ; calling boot
                    jsr       <D.BtBug  ; call routine at <D.BtBug
                    jsr       ,y        ; load boot file
                    bcs       FSrqmemReturn ; branch if carry is set to FSrqmemReturn
                    std       <D.BtSz   ; save boot file size
                    stx       <D.BtPtr  ; save start pointer of bootfile
                    lda       #'b       ; boot returns OK
                    jsr       <D.BtBug  ; call routine at <D.BtBug

* added for IOMan system memory extentions
                  IFNE    H6309   ; begin conditional assembly for H6309
                    ldd       M$Name,x  ; grab the name offset
                    ldd       d,x       ; find the first 2 bytes of the first module
                    cmpd      #$4E69    ; 'Ni' ? (NitrOS9 module?)
                    bne       not.ext   ; no, not system memory extensions
                    ldd       M$Exec,x  ; grab the execution ptr
                    jmp       d,x       ; and go execute the system memory extension module
                  ENDC

not.ext             ldd       <D.BtSz   ; load D from <D.BtSz
                    bsr       I.VBlock  ; internal verify block routine
                    ldx       <D.SysDAT ; get system DAT pointer
                    ldb       $0D,x     ; get highest allocated block number
                    incb                ; allocate block 0, too
                    ldx       <D.BlkMap ; point to the memory block map
                    lbra      KrnRAMUseFlag ; and go mark the blocks as used.


**************************************************
* System Call: F$VBlock
*
* Function: ???
*
* Input:  D = Size of block to verify
*         X = Start address to verify
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FVBlock             ldd       R$D,u     ; size of block to verify
                    ldx       R$X,u     ; start address to verify

I.VBlock            leau      d,x       ; point to end of bootfile
                    tfr       x,d       ; transfer start of block to D
                    anda      #$E0      ; mask A with #$E0
                    clrb                ; D is now block number
                    pshs      d,u       ; save starting block and end of block
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; A is now logical block * 2
                    ldy       <D.SysDAT ; get pointer to system DAT
                    leay      a,y       ; y is pointer of sys block map of start of block
FSrqmemModuleIDSignature ldd       M$ID,x    ; get module ID
                    cmpd      #M$ID12   ; legal ID?
                    bne       FSrqmemTarget ; no, keep looking

                    ldd       M$Name,x  ; find name offset pointer
                    pshs      x         ; save x on the stack
                    leax      d,x       ; compute d,x into X
name.prt            lda       ,x+       ; get first character of the name
                    jsr       <D.BtBug  ; print it out
                    bpl       name.prt  ; branch if negative is clear to name.prt
                    lda       #C$SPAC   ; a space
                    jsr       <D.BtBug  ; call routine at <D.BtBug
                    puls      x         ; restore x from the stack

                  IFNE    H6309   ; begin conditional assembly for H6309
                    ldd       ,s        ; offset into block
                    subr      d,x       ; make X=offset into block
                  ELSE
                    tfr       x,d       ; transfer register value x,d
                    subd      ,s        ; subtract ,s from D
                    tfr       d,x       ; transfer register value d,x
                  ENDC
                    tfr       y,d       ; transfer register value y,d
                    os9       F$VModul  ; call OS-9 service F$VModul
                  IFNE    H6309   ; begin conditional assembly for H6309
                    ldw       ,s        ; load W from ,s
                    leax      w,x       ; compute w,x into X
                  ELSE
                    pshs      b         ; save b on the stack
                    ldd       1,s       ; load D from 1,s
                    leax      d,x       ; compute d,x into X
                    puls      b         ; restore b from the stack
                  ENDC
                    bcc       FSrqmemModuleSize ; branch if carry is clear to FSrqmemModuleSize
                    cmpb      #E$KwnMod ; compare B with #E$KwnMod
                    bne       FSrqmemTarget ; branch if zero is clear to FSrqmemTarget
FSrqmemModuleSize   ldd       M$Size,x  ; load D from M$Size,x
                    leax      d,x       ; compute d,x into X
                    fcb       $8C       ; skip 2 bytes

FSrqmemTarget       leax      1,x       ; move to next byte
FSrqmemHaveWeGoneThroughBootfile cmpx      2,s       ; gone thru whole bootfile?
                    bcs       FSrqmemModuleIDSignature ; no, keep looking
                    leas      4,s       ; purge stack
                    clrb                ; clear B
                    rts                 ; return to caller
