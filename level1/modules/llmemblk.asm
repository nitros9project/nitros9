* Deterministic RAM-backed block device. Caller owns the RAM window.
                    use       defsfile
                    use       blkdrv.d
                    mod       eom,name,Sbrtn+Objct,ReEnt+1,start,0
name                fcs       /llmemblk/
                    fcb       1
start               lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      Info
                    lbra      Success
                    lbra      Success
                    fdb       BD.Magic
                    fcb       BD.Version,BH.Len
                    fdb       1         no persistent state needed
Init                ldd       BC.Blocks,y
                    beq       Bad
                    cmpd      #127
                    bhi       Bad
                    tfr       b,a
                    clrb
                    lsla
                    addd      BC.Ram,y
                    bcs       Bad
                    ldd       BC.Blocks,y
                    subd      #1
                    addd      BC.Base+2,y
                    ldd       BC.Base,y
                    adcb      #0
                    adca      #0
                    bcs       Bad
Success             clrb
                    rts
Bad                 ldb       #E$IllArg
                    coma
                    rts
Info                pshs      d
                    lda       BC.Unit,y
                    sta       BI.Unit,x
                    lda       BC.Flags,y
                    anda      #BF.ReadOnly
                    ora       #BF.Flush
                    sta       BI.Flags,x
                    ldd       #512
                    std       BI.BlockSize,x
                    ldd       #127
                    std       BI.MaxCount,x
                    ldd       BC.Blocks,y
                    subd      #1
                    addd      BC.Base+2,y
                    std       BI.Last+2,x
                    ldd       BC.Base,y
                    adcb      #0
                    adca      #0
                    std       BI.Last,x
                    puls      d
                    clrb
                    rts
Read                clra
                    bra       Transfer
Write               lda       #1
Transfer            pshs      a,x,y,u
                    ldd       BR.LBA+2,x
                    subd      BC.Base+2,y
                    pshs      d
                    ldd       BR.LBA,x
                    sbcb      BC.Base+1,y
                    sbca      BC.Base,y
                    bcs       sector@
                    cmpd      #0
                    bne       sector@
                    ldd       ,s
                    cmpd      BC.Blocks,y
                    bhs       sector@
                    tfr       b,a
                    clrb
                    lsla
                    addd      BC.Ram,y
                    tfr       d,u       ; ram cursor
                    leas      2,s
loop@               ldd       BR.Done,x
                    cmpd      BR.Count,x
                    beq       done@
                    cmpd      BC.FailAfter,y
                    beq       fault@
                    pshs      x,y
                    ldy       BR.Buffer,x
                    tfr       b,a
                    clrb
                    lsla
                    leay      d,y
                    ldx       #512
                    tst       4,s       ; operation byte
                    bne       put@
get@                lda       ,u+
                    sta       ,y+
                    leax      -1,x
                    bne       get@
                    bra       next@
put@                lda       ,y+
                    sta       ,u+
                    leax      -1,x
                    bne       put@
next@               puls      x,y
                    ldd       BR.Done,x
                    addd      #1
                    std       BR.Done,x
                    bra       loop@
sector@             leas      2,s
                    ldb       #E$Sect
                    bra       error@
fault@              ldb       #E$Read
                    tst       ,s
                    beq       error@
                    ldb       #E$Write
error@              coma
                    puls      a,x,y,u,pc
done@               clrb
                    puls      a,x,y,u,pc
                    emod
eom                 equ       *
                    end
