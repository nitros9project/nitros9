* Read/write blkdrv backend for MAME's CoCo virtual hard disk registers.
* BC.Port=$FF80, BC.Unit=0/1, BC.Base=inclusive last 512-byte LBA.
* The emulator has 24-bit 256-byte records: two records per blkdrv block.
* This backend's 4 GiB ceiling does not restrict the 32-bit blkdrv ABI.
                    use       defsfile
                    use       blkdrv.d
                    mod       eom,name,Sbrtn+Objct,ReEnt+1,start,0
name                fcs       /llcocovhd/
                    fcb       1
start               lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      Info
                    lbra      Good
                    lbra      Good
                    fdb       BD.Magic
                    fcb       BD.Version,BH.Len
                    fdb       StateSize
                    org       0
Bounce              rmb       256                 SRqMem provides a page-aligned DMA buffer
Request             rmb       2
Destination         rmb       2
Port                rmb       2
Unit                rmb       1
Command             rmb       1
Half                rmb       1
StateSize           equ       .
Init                ldd       BC.Port,y
                    cmpd      #$FF80
                    bne       BadConfig
                    std       Port,u
                    lda       BC.Unit,y
                    cmpa      #2
                    bhs       BadConfig
                    sta       Unit,u
                    lda       BC.Base,y
                    bne       BadConfig
                    lda       BC.Base+1,y
                    bita      #$80
                    bne       BadConfig
Good                clrb
                    rts
BadConfig           ldb       #E$IllArg
                    coma
                    rts
Info                lda       BC.Unit,y
                    sta       BI.Unit,x
                    lda       BC.Flags,y
                    anda      #BF.ReadOnly
                    ora       #BF.Flush
                    sta       BI.Flags,x
                    ldd       #512
                    std       BI.BlockSize,x
                    ldd       BC.Base,y
                    std       BI.Last,x
                    ldd       BC.Base+2,y
                    std       BI.Last+2,x
                    ldd       #1
                    std       BI.MaxCount,x
                    clrb
                    rts
Read                clra
                    bra       Transfer
Write               lda       #1
Transfer            pshs      x,y,u
                    sta       Command,u
                    stx       Request,u
                    ldd       BR.Buffer,x
                    std       Destination,u
                    clr       Half,u
next@               tst       Command,u
                    beq       issue@
                    ldx       Destination,u
                    tfr       u,y
                    clrb
put@                lda       ,x+
                    sta       ,y+
                    decb
                    bne       put@
issue@              ldy       Port,u
                    lda       Unit,u
                    sta       6,y                 select image every time
                    ldx       Request,u
                    ldd       BR.LBA+2,x
                    lslb
                    rola
                    orb       Half,u
                    std       1,y
                    lda       BR.LBA+1,x
                    rola
                    sta       ,y                  24-bit record = LBA*2 + half
                    stu       4,y                 page-aligned bounce buffer, never crosses 8K
                    lda       Command,u
                    sta       3,y                 synchronous read/write command
                    lda       3,y
                    bne       failed@
                    ldx       Destination,u
                    tst       Command,u
                    bne       advance@
                    tfr       u,y
                    clrb
copy@               lda       ,y+
                    sta       ,x+
                    decb
                    bne       copy@
                    bra       copied@
advance@            leax      256,x
copied@             stx       Destination,u
                    inc       Half,u
                    lda       Half,u
                    cmpa      #2
                    blo       next@
                    ldx       Request,u
                    ldd       #1
                    std       BR.Done,x
                    clrb
                    puls      x,y,u,pc
failed@             ldb       #E$Read
                    tst       Command,u
                    beq       classify@
                    ldb       #E$Write
classify@
                    cmpa      #2
                    beq       notready@
                    cmpa      #255
                    bne       error@
notready@           ldb       #E$NotRdy
error@              coma
                    puls      x,y,u,pc
                    emod
eom                 equ       *
                    end
