* Test-only sparse FAT32 block medium; never touches hardware or accepts writes.
                    use       defsfile
                    use       blkdrv.d
                    mod       eom,name,Sbrtn+Objct,ReEnt+1,start,0
name                fcs       /llfatfixture/
                    fcb       1
start               lbra      Good
                    lbra      Read
                    lbra      Write
                    lbra      Info
                    lbra      Good
                    lbra      Good
                    fdb       BD.Magic
                    fcb       BD.Version,BH.Len
                    fdb       1
Good                clrb
                    rts
Write               ldb       #E$WP
                    coma
                    rts
Info                clr       BI.Unit,x
                    lda       #BF.ReadOnly|BF.Flush
                    sta       BI.Flags,x
                    ldd       #512
                    std       BI.BlockSize,x
                    ldd       #FixtureLast/65536
                    std       BI.Last,x
                    ldd       #FixtureLast&$FFFF
                    std       BI.Last+2,x
                    ldd       #1
                    std       BI.MaxCount,x
                    clrb
                    rts
Read                pshs      x,y,u
                    ldu       BR.Buffer,x
                    leay      SectorTable,pcr
                    ldd       #FixtureCount
                    pshs      d
find@               ldd       BR.LBA,x
                    cmpd      ,y
                    bne       next@
                    ldd       BR.LBA+2,x
                    cmpd      2,y
                    beq       found@
next@               leay      8,y
                    ldd       ,s
                    subd      #1
                    std       ,s
                    bne       find@
                    leas      2,s
                    ldy       #512
zero@               clr       ,u+
                    leay      -1,y
                    bne       zero@
                    bra       done@
found@              leas      2,s
                    ldd       6,y                 stored prefix length
                    pshs      d
                    ldd       4,y
                    leay      SectorTable,pcr
                    leay      d,y
                    ldd       ,s
                    pshs      d
                    beq       copied@
copy@               lda       ,y+
                    sta       ,u+
                    ldd       ,s
                    subd      #1
                    std       ,s
                    bne       copy@
copied@             leas      2,s
                    ldd       #512
                    subd      ,s++
                    tfr       d,y
                    cmpy      #0
                    bne       zero@
done@               ldd       #1
                    std       BR.Done,x
                    clrb
                    puls      x,y,u,pc
                    use       fatfixture-data.asm
                    emod
eom                 equ       *
                    end
