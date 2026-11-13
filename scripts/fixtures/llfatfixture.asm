* Test-only sparse FAT32 block medium; never touches hardware or accepts writes.
                    use       defsfile  ; include shared definitions or implementation
                    use       blkdrv.d  ; include shared definitions or implementation
                    mod       eom,name,Sbrtn+Objct,ReEnt+1,start,0 ; emit OS-9 module header
name                fcs       /llfatfixture/      ; module name or literal text
                    fcb       1         ; emit byte data
start               lbra      Good      ; continue unconditionally Good
                    lbra      Read      ; continue unconditionally Read
                    lbra      Write     ; continue unconditionally Write
                    lbra      Info      ; continue unconditionally Info
                    lbra      Good      ; continue unconditionally Good
                    lbra      Good      ; continue unconditionally Good
                    fdb       BD.Magic  ; emit word data
                    fcb       BD.Version,BH.Len ; emit byte data
                    fdb       1         ; emit word data
Good                clrb                ; clear accumulator B and carry
                    rts                 ; return to caller
Write               ldb       #E$WP     ; load B from #E$WP
                    coma                ; complement A and set carry
                    rts                 ; return to caller
Info                clr       BI.Unit,x ; clear BI.Unit,x
                    lda       #BF.ReadOnly|BF.Flush ; load A from #BF.ReadOnly|BF.Flush
                    sta       BI.Flags,x ; save A in BI.Flags,x
                    ldd       #512      ; load D from #512
                    std       BI.BlockSize,x ; save D in BI.BlockSize,x
                    ldd       #FixtureLast/65536 ; load D from #FixtureLast/65536
                    std       BI.Last,x ; save D in BI.Last,x
                    ldd       #FixtureLast&$FFFF ; load D from #FixtureLast&$FFFF
                    std       BI.Last+2,x ; save D in BI.Last+2,x
                    ldd       #1        ; load D from #1
                    std       BI.MaxCount,x ; save D in BI.MaxCount,x
                    clrb                ; clear accumulator B and carry
                    rts                 ; return to caller
Read                pshs      x,y,u     ; preserve x,y,u on stack
                    ldu       BR.Buffer,x ; load U from BR.Buffer,x
                    leay      SectorTable,pcr ; point Y at SectorTable,pcr
                    ldd       #FixtureCount ; load D from #FixtureCount
                    pshs      d         ; preserve d on stack
find@               ldd       BR.LBA,x  ; load D from BR.LBA,x
                    cmpd      ,y        ; compare D with ,y
                    bne       next@     ; branch when unequal or nonzero next@
                    ldd       BR.LBA+2,x ; load D from BR.LBA+2,x
                    cmpd      2,y       ; compare D with 2,y
                    beq       found@    ; branch when equal or zero found@
next@               leay      8,y       ; point Y at 8,y
                    ldd       ,s        ; load D from ,s
                    subd      #1        ; subtract from D: #1
                    std       ,s        ; save D in ,s
                    bne       find@     ; branch when unequal or nonzero find@
                    leas      2,s       ; point S at 2,s
                    ldy       #512      ; load Y from #512
zero@               clr       ,u+       ; clear ,u+
                    leay      -1,y      ; point Y at -1,y
                    bne       zero@     ; branch when unequal or nonzero zero@
                    bra       done@     ; continue unconditionally done@
found@              leas      2,s       ; point S at 2,s
                    ldd       6,y                 stored prefix length
                    pshs      d         ; preserve d on stack
                    ldd       4,y       ; load D from 4,y
                    leay      SectorTable,pcr ; point Y at SectorTable,pcr
                    leay      d,y       ; point Y at d,y
                    ldd       ,s        ; load D from ,s
                    pshs      d         ; preserve d on stack
                    beq       copied@   ; branch when equal or zero copied@
copy@               lda       ,y+       ; load A from ,y+
                    sta       ,u+       ; save A in ,u+
                    ldd       ,s        ; load D from ,s
                    subd      #1        ; subtract from D: #1
                    std       ,s        ; save D in ,s
                    bne       copy@     ; branch when unequal or nonzero copy@
copied@             leas      2,s       ; point S at 2,s
                    ldd       #512      ; load D from #512
                    subd      ,s++      ; subtract from D: ,s++
                    tfr       d,y       ; transfer registers d,y
                    cmpy      #0        ; compare Y with #0
                    bne       zero@     ; branch when unequal or nonzero zero@
done@               ldd       #1        ; load D from #1
                    std       BR.Done,x ; save D in BR.Done,x
                    clrb                ; clear accumulator B and carry
                    puls      x,y,u,pc  ; restore x,y,u,pc from stack
                    use       fatfixture-data.asm ; include shared definitions or implementation
                    emod      ;         finish module and CRC
eom                 equ       *         ; define constant or offset
                    end       ;         end assembly source
