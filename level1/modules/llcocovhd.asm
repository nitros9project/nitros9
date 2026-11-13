* Read/write blkdrv backend for MAME's CoCo virtual hard disk registers.
* BC.Port=$FF80, BC.Unit=0/1, BC.Base=inclusive last 512-byte LBA.
* The emulator has 24-bit 256-byte records: two records per blkdrv block.
* This backend's 4 GiB ceiling does not restrict the 32-bit blkdrv ABI.
                    use       defsfile  ; include shared definitions or implementation
                    use       blkdrv.d  ; include shared definitions or implementation
                    mod       eom,name,Sbrtn+Objct,ReEnt+1,start,0 ; emit OS-9 module header
name                fcs       /llcocovhd/         ; module name or literal text
                    fcb       1         ; emit byte data
start               lbra      Init      ; continue unconditionally Init
                    lbra      Read      ; continue unconditionally Read
                    lbra      Write     ; continue unconditionally Write
                    lbra      Info      ; continue unconditionally Info
                    lbra      Good      ; continue unconditionally Good
                    lbra      Good      ; continue unconditionally Good
                    fdb       BD.Magic  ; emit word data
                    fcb       BD.Version,BH.Len ; emit byte data
                    fdb       StateSize ; emit word data
                    org       0         ; set storage origin
Bounce              rmb       256                 SRqMem provides a page-aligned DMA buffer
Request             rmb       2         ; reserve storage
Destination         rmb       2         ; reserve storage
Port                rmb       2         ; reserve storage
Unit                rmb       1         ; reserve storage
Command             rmb       1         ; reserve storage
Half                rmb       1         ; reserve storage
StateSize           equ       .         ; define constant or offset
Init                ldd       BC.Port,y ; load D from BC.Port,y
                    cmpd      #$FF80    ; compare D with #$FF80
                    bne       BadConfig ; branch when unequal or nonzero BadConfig
                    std       Port,u    ; save D in Port,u
                    lda       BC.Unit,y ; load A from BC.Unit,y
                    cmpa      #2        ; compare A with #2
                    bhs       BadConfig ; branch when unsigned higher or equal BadConfig
                    sta       Unit,u    ; save A in Unit,u
                    lda       BC.Base,y ; load A from BC.Base,y
                    bne       BadConfig ; branch when unequal or nonzero BadConfig
                    lda       BC.Base+1,y ; load A from BC.Base+1,y
                    bita      #$80      ; test A against #$80
                    bne       BadConfig ; branch when unequal or nonzero BadConfig
Good                clrb                ; clear accumulator B and carry
                    rts                 ; return to caller
BadConfig           ldb       #E$IllArg ; load B from #E$IllArg
                    coma                ; complement A and set carry
                    rts                 ; return to caller
Info                lda       BC.Unit,y ; load A from BC.Unit,y
                    sta       BI.Unit,x ; save A in BI.Unit,x
                    lda       BC.Flags,y ; load A from BC.Flags,y
                    anda      #BF.ReadOnly ; mask A with #BF.ReadOnly
                    ora       #BF.Flush ; merge A with #BF.Flush
                    sta       BI.Flags,x ; save A in BI.Flags,x
                    ldd       #512      ; load D from #512
                    std       BI.BlockSize,x ; save D in BI.BlockSize,x
                    ldd       BC.Base,y ; load D from BC.Base,y
                    std       BI.Last,x ; save D in BI.Last,x
                    ldd       BC.Base+2,y ; load D from BC.Base+2,y
                    std       BI.Last+2,x ; save D in BI.Last+2,x
                    ldd       #1        ; load D from #1
                    std       BI.MaxCount,x ; save D in BI.MaxCount,x
                    clrb                ; clear accumulator B and carry
                    rts                 ; return to caller
Read                clra                ; clear accumulator A and carry
                    bra       Transfer  ; continue unconditionally Transfer
Write               lda       #1        ; load A from #1
Transfer            pshs      x,y,u     ; preserve x,y,u on stack
                    sta       Command,u ; save A in Command,u
                    stx       Request,u ; save X in Request,u
                    ldd       BR.Buffer,x ; load D from BR.Buffer,x
                    std       Destination,u ; save D in Destination,u
                    clr       Half,u    ; clear Half,u
next@               tst       Command,u ; test Command,u
                    beq       issue@    ; branch when equal or zero issue@
                    ldx       Destination,u ; load X from Destination,u
                    tfr       u,y       ; transfer registers u,y
                    clrb                ; clear accumulator B and carry
put@                lda       ,x+       ; load A from ,x+
                    sta       ,y+       ; save A in ,y+
                    decb                ; decrement accumulator B
                    bne       put@      ; branch when unequal or nonzero put@
issue@              ldy       Port,u    ; load Y from Port,u
                    lda       Unit,u    ; load A from Unit,u
                    sta       6,y                 select image every time
                    ldx       Request,u ; load X from Request,u
                    ldd       BR.LBA+2,x ; load D from BR.LBA+2,x
                    lslb                ; shift or rotate accumulator B
                    rola                ; shift or rotate accumulator A
                    orb       Half,u    ; merge B with Half,u
                    std       1,y       ; save D in 1,y
                    lda       BR.LBA+1,x ; load A from BR.LBA+1,x
                    rola                ; shift or rotate accumulator A
                    sta       ,y                  24-bit record = LBA*2 + half
                    stu       4,y                 page-aligned bounce buffer, never crosses 8K
                    lda       Command,u ; load A from Command,u
                    sta       3,y                 synchronous read/write command
                    lda       3,y       ; load A from 3,y
                    bne       failed@   ; branch when unequal or nonzero failed@
                    ldx       Destination,u ; load X from Destination,u
                    tst       Command,u ; test Command,u
                    bne       advance@  ; branch when unequal or nonzero advance@
                    tfr       u,y       ; transfer registers u,y
                    clrb                ; clear accumulator B and carry
copy@               lda       ,y+       ; load A from ,y+
                    sta       ,x+       ; save A in ,x+
                    decb                ; decrement accumulator B
                    bne       copy@     ; branch when unequal or nonzero copy@
                    bra       copied@   ; continue unconditionally copied@
advance@            leax      256,x     ; point X at 256,x
copied@             stx       Destination,u ; save X in Destination,u
                    inc       Half,u    ; increment Half,u
                    lda       Half,u    ; load A from Half,u
                    cmpa      #2        ; compare A with #2
                    blo       next@     ; branch when unsigned lower next@
                    ldx       Request,u ; load X from Request,u
                    ldd       #1        ; load D from #1
                    std       BR.Done,x ; save D in BR.Done,x
                    clrb                ; clear accumulator B and carry
                    puls      x,y,u,pc  ; restore x,y,u,pc from stack
failed@             ldb       #E$Read   ; load B from #E$Read
                    tst       Command,u ; test Command,u
                    beq       classify@ ; branch when equal or zero classify@
                    ldb       #E$Write  ; load B from #E$Write
classify@
                    cmpa      #2        ; compare A with #2
                    beq       notready@ ; branch when equal or zero notready@
                    cmpa      #255      ; compare A with #255
                    bne       error@    ; branch when unequal or nonzero error@
notready@           ldb       #E$NotRdy ; load B from #E$NotRdy
error@              coma                ; complement A and set carry
                    puls      x,y,u,pc  ; restore x,y,u,pc from stack
                    emod      ;         finish module and CRC
eom                 equ       *         ; define constant or offset
                    end       ;         end assembly source
