* Deterministic RAM-backed block device. Caller owns the RAM window.
                    use       defsfile  ; include shared definitions or implementation
                    use       blkdrv.d  ; include shared definitions or implementation
                    mod       eom,name,Sbrtn+Objct,ReEnt+1,start,0 ; emit OS-9 module header
name                fcs       /llmemblk/          ; module name or literal text
                    fcb       1         ; emit byte data
start               lbra      Init      ; continue unconditionally Init
                    lbra      Read      ; continue unconditionally Read
                    lbra      Write     ; continue unconditionally Write
                    lbra      Info      ; continue unconditionally Info
                    lbra      Success   ; continue unconditionally Success
                    lbra      Success   ; continue unconditionally Success
                    fdb       BD.Magic  ; emit word data
                    fcb       BD.Version,BH.Len ; emit byte data
                    fdb       1         no persistent state needed
Init                ldd       BC.Blocks,y ; load D from BC.Blocks,y
                    beq       Bad       ; branch when equal or zero Bad
                    cmpd      #127      ; compare D with #127
                    bhi       Bad       ; branch when unsigned higher Bad
                    tfr       b,a       ; transfer registers b,a
                    clrb                ; clear accumulator B and carry
                    lsla                ; shift or rotate accumulator A
                    addd      BC.Ram,y  ; add to D: BC.Ram,y
                    bcs       Bad       ; branch on carry or error Bad
                    ldd       BC.Blocks,y ; load D from BC.Blocks,y
                    subd      #1        ; subtract from D: #1
                    addd      BC.Base+2,y ; add to D: BC.Base+2,y
                    ldd       BC.Base,y ; load D from BC.Base,y
                    adcb      #0        ; add to B with carry: #0
                    adca      #0        ; add to A with carry: #0
                    bcs       Bad       ; branch on carry or error Bad
Success             clrb                ; clear accumulator B and carry
                    rts                 ; return to caller
Bad                 ldb       #E$IllArg ; load B from #E$IllArg
                    coma                ; complement A and set carry
                    rts                 ; return to caller
Info                pshs      d         ; preserve d on stack
                    lda       BC.Unit,y ; load A from BC.Unit,y
                    sta       BI.Unit,x ; save A in BI.Unit,x
                    lda       BC.Flags,y ; load A from BC.Flags,y
                    anda      #BF.ReadOnly ; mask A with #BF.ReadOnly
                    ora       #BF.Flush ; merge A with #BF.Flush
                    sta       BI.Flags,x ; save A in BI.Flags,x
                    ldd       #512      ; load D from #512
                    std       BI.BlockSize,x ; save D in BI.BlockSize,x
                    ldd       #127      ; load D from #127
                    std       BI.MaxCount,x ; save D in BI.MaxCount,x
                    ldd       BC.Blocks,y ; load D from BC.Blocks,y
                    subd      #1        ; subtract from D: #1
                    addd      BC.Base+2,y ; add to D: BC.Base+2,y
                    std       BI.Last+2,x ; save D in BI.Last+2,x
                    ldd       BC.Base,y ; load D from BC.Base,y
                    adcb      #0        ; add to B with carry: #0
                    adca      #0        ; add to A with carry: #0
                    std       BI.Last,x ; save D in BI.Last,x
                    puls      d         ; restore d from stack
                    clrb                ; clear accumulator B and carry
                    rts                 ; return to caller
Read                clra                ; clear accumulator A and carry
                    bra       Transfer  ; continue unconditionally Transfer
Write               lda       #1        ; load A from #1
Transfer            pshs      a,x,y,u   ; preserve a,x,y,u on stack
                    ldd       BR.LBA+2,x ; load D from BR.LBA+2,x
                    subd      BC.Base+2,y ; subtract from D: BC.Base+2,y
                    pshs      d         ; preserve d on stack
                    ldd       BR.LBA,x  ; load D from BR.LBA,x
                    sbcb      BC.Base+1,y ; subtract from B with borrow: BC.Base+1,y
                    sbca      BC.Base,y ; subtract from A with borrow: BC.Base,y
                    bcs       sector@   ; branch on carry or error sector@
                    cmpd      #0        ; compare D with #0
                    bne       sector@   ; branch when unequal or nonzero sector@
                    ldd       ,s        ; load D from ,s
                    cmpd      BC.Blocks,y ; compare D with BC.Blocks,y
                    bhs       sector@   ; branch when unsigned higher or equal sector@
                    tfr       b,a       ; transfer registers b,a
                    clrb                ; clear accumulator B and carry
                    lsla                ; shift or rotate accumulator A
                    addd      BC.Ram,y  ; add to D: BC.Ram,y
                    tfr       d,u       ; ram cursor
                    leas      2,s       ; point S at 2,s
loop@               ldd       BR.Done,x ; load D from BR.Done,x
                    cmpd      BR.Count,x ; compare D with BR.Count,x
                    beq       done@     ; branch when equal or zero done@
                    cmpd      BC.FailAfter,y ; compare D with BC.FailAfter,y
                    beq       fault@    ; branch when equal or zero fault@
                    pshs      x,y       ; preserve x,y on stack
                    ldy       BR.Buffer,x ; load Y from BR.Buffer,x
                    tfr       b,a       ; transfer registers b,a
                    clrb                ; clear accumulator B and carry
                    lsla                ; shift or rotate accumulator A
                    leay      d,y       ; point Y at d,y
                    ldx       #512      ; load X from #512
                    tst       4,s       ; operation byte
                    bne       put@      ; branch when unequal or nonzero put@
get@                lda       ,u+       ; load A from ,u+
                    sta       ,y+       ; save A in ,y+
                    leax      -1,x      ; point X at -1,x
                    bne       get@      ; branch when unequal or nonzero get@
                    bra       next@     ; continue unconditionally next@
put@                lda       ,y+       ; load A from ,y+
                    sta       ,u+       ; save A in ,u+
                    leax      -1,x      ; point X at -1,x
                    bne       put@      ; branch when unequal or nonzero put@
next@               puls      x,y       ; restore x,y from stack
                    ldd       BR.Done,x ; load D from BR.Done,x
                    addd      #1        ; add to D: #1
                    std       BR.Done,x ; save D in BR.Done,x
                    bra       loop@     ; continue unconditionally loop@
sector@             leas      2,s       ; point S at 2,s
                    ldb       #E$Sect   ; load B from #E$Sect
                    bra       error@    ; continue unconditionally error@
fault@              ldb       #E$Read   ; load B from #E$Read
                    tst       ,s        ; test ,s
                    beq       error@    ; branch when equal or zero error@
                    ldb       #E$Write  ; load B from #E$Write
error@              coma                ; complement A and set carry
                    puls      a,x,y,u,pc ; restore a,x,y,u,pc from stack
done@               clrb                ; clear accumulator B and carry
                    puls      a,x,y,u,pc ; restore a,x,y,u,pc from stack
                    emod      ;         finish module and CRC
eom                 equ       *         ; define constant or offset
                    end       ;         end assembly source
