                    use       defsfile  ; include shared definitions or implementation
                    use       blkdrv.d  ; include shared definitions or implementation
                    mod       eom,name,Drivr+Objct,ReEnt+1,start,BV.Len ; emit OS-9 module header
                    fcb       $FF       file manager owns path access policy
name                fcs       /blkdrv/            ; module name or literal text
                    fcb       1         ; emit byte data
start               lbra      Init      ; continue unconditionally Init
                    lbra      Read      ; continue unconditionally Read
                    lbra      Write     ; continue unconditionally Write
                    lbra      GetInfo   ; continue unconditionally GetInfo
                    lbra      Flush     ; continue unconditionally Flush
                    lbra      Term      ; continue unconditionally Term

* Init: Y=descriptor, U=OS-9 statics. Other entries: X=request/info,
* Y=path, U=statics. GetInfo/Flush are kernel block calls, not SS codes.
Init                pshs      x,y,u     ; preserve x,y,u on stack
                    clr       BV.Ready,u ; clear BV.Ready,u
                    clr       BV.Lock,u ; clear BV.Lock,u
                    ldd       #0        ; load D from #0
                    std       BV.FMPaths,u ; save D in BV.FMPaths,u
                    clr       V.BUSY,u  ; clear V.BUSY,u
                    std       BV.Module,u ; save D in BV.Module,u
                    std       BV.State,u ; save D in BV.State,u
                    lda       BT.Version,y ; load A from BT.Version,y
                    cmpa      #BD.Version ; compare A with #BD.Version
                    lbne      BadInit   ; branch when unequal or nonzero BadInit
                    ldd       BT.Config+BC.Port,y ; descriptor backend port
                    cmpd      V.PORT,u  ; ioman physical-device port
                    lbne      BadInit   ; reject inconsistent descriptors
* Copy configuration: IOMan may share statics after the first descriptor detaches.
                    pshs      y         ; preserve y on stack
                    leay      BT.Config,y ; point Y at BT.Config,y
                    leax      BV.Config,u ; point X at BV.Config,u
                    ldb       #BC.Len   ; load B from #BC.Len
copycfg@            lda       ,y+       ; load A from ,y+
                    sta       ,x+       ; save A in ,x+
                    decb                ; decrement accumulator B
                    bne       copycfg@  ; branch when unequal or nonzero copycfg@
                    puls      y         ; restore y from stack
                    ldd       BT.Backend,y ; load D from BT.Backend,y
                    leax      d,y       ; point X at d,y
                  IFGT    Level-1 ; conditional assembly
                    ldd       <D.Proc   ; load D from <D.Proc
                    pshs      d         ; preserve d on stack
                    ldd       <D.SysPrc ; load D from <D.SysPrc
                    std       <D.Proc   ; save D in <D.Proc
                  ENDC            ; conditional assembly
                    lda       #Sbrtn+Objct ; load A from #Sbrtn+Objct
                    os9       F$Link    ; invoke OS-9 F$Link service
                  IFGT    Level-1 ; conditional assembly
                    puls      x         ; restore x from stack
                    stx       <D.Proc   ; save X in <D.Proc
                  ENDC            ; conditional assembly
                    tfr       u,x       ; transfer registers u,x
                    ldu       4,s       ; load U from 4,s
                    lbcs      InitExit  ; branch on carry or error InitExit
                    stx       BV.Module,u ; save X in BV.Module,u
                    sty       BV.Entry,u ; save Y in BV.Entry,u
* Reject a truncated backend header before reading its ABI metadata.
                    ldd       M$Size,x  ; load D from M$Size,x
                    subd      #3        ; exclude module CRC
                    cmpd      M$Exec,x  ; compare D with M$Exec,x
                    bls       BadInit   ; branch when unsigned lower or equal BadInit
                    subd      M$Exec,x  ; subtract from D: M$Exec,x
                    cmpd      #BH.Len   ; compare D with #BH.Len
                    blo       BadInit   ; branch when unsigned lower BadInit
                    ldd       BH.Magic,y ; load D from BH.Magic,y
                    cmpd      #BD.Magic ; compare D with #BD.Magic
                    bne       BadInit   ; branch when unequal or nonzero BadInit
                    lda       BH.Version,y ; load A from BH.Version,y
                    cmpa      #BD.Version ; compare A with #BD.Version
                    bne       BadInit   ; branch when unequal or nonzero BadInit
                    lda       BH.Size,y ; load A from BH.Size,y
                    cmpa      #BH.Len   ; compare A with #BH.Len
                    bne       BadInit   ; branch when unequal or nonzero BadInit
                    ldd       BH.Memory,y ; load D from BH.Memory,y
                    beq       BadInit   ; branch when equal or zero BadInit
                    cmpd      #$FF00    ; f$SRqMem rounds to whole pages
                    bhi       BadInit   ; branch when unsigned higher BadInit
                    os9       F$SRqMem  ; invoke OS-9 F$SRqMem service
                    tfr       u,x       ; transfer registers u,x
                    ldu       4,s       ; load U from 4,s
                    bcs       InitFailed ; branch on carry or error InitFailed
                    stx       BV.State,u ; save X in BV.State,u
                    std       BV.Alloc,u ; save D in BV.Alloc,u
* Clear allocated storage, including allocation rounding.
                    pshs      x         ; preserve x on stack
clear0@             clr       ,x+       ; clear ,x+
                    subd      #1        ; subtract from D: #1
                    bne       clear0@   ; branch when unequal or nonzero clear0@
                    puls      x         ; restore x from stack
                    lda       #BD.Init  ; load A from #BD.Init
                    lbsr      CallBackend ; call helper CallBackend
                    bcs       InitFailed ; branch on carry or error InitFailed
                    inc       BV.Ready,u ; increment BV.Ready,u
                    clrb                ; clear accumulator B and carry
InitExit            puls      x,y,u,pc  ; restore x,y,u,pc from stack
BadInit             ldb       #E$BMode  ; load B from #E$BMode
                    coma                ; complement A and set carry
InitFailed          pshs      b         ; preserve b on stack
                    lbsr      Dispose   ; call helper Dispose
                    puls      b         ; restore b from stack
                    coma                ; complement A and set carry
                    bra       InitExit  ; continue unconditionally InitExit

* Allocation and link cleanup, also safe after a partially failed Init.
Dispose             pshs      x,y,u     ; preserve x,y,u on stack
                    ldx       BV.State,u ; load X from BV.State,u
                    beq       unlink0@  ; branch when equal or zero unlink0@
                    ldd       BV.Alloc,u ; load D from BV.Alloc,u
                    pshs      u         ; preserve u on stack
                    tfr       x,u       ; transfer registers x,u
                    os9       F$SRtMem  ; invoke OS-9 F$SRtMem service
                    puls      u         ; restore u from stack
                    clr       BV.State,u ; clear BV.State,u
                    clr       BV.State+1,u ; clear BV.State+1,u
unlink0@            ldx       BV.Module,u ; load X from BV.Module,u
                    beq       done0@    ; branch when equal or zero done0@
                  IFGT    Level-1 ; conditional assembly
                    ldd       <D.Proc   ; load D from <D.Proc
                    pshs      d         ; preserve d on stack
                    ldd       <D.SysPrc ; load D from <D.SysPrc
                    std       <D.Proc   ; save D in <D.Proc
                  ENDC            ; conditional assembly
                    pshs      u         ; preserve u on stack
                    tfr       x,u       ; transfer registers x,u
                    os9       F$UnLink  ; invoke OS-9 F$UnLink service
                    puls      u         ; restore u from stack
                  IFGT    Level-1 ; conditional assembly
                    puls      d         ; restore d from stack
                    std       <D.Proc   ; save D in <D.Proc
                  ENDC            ; conditional assembly
                    clr       BV.Module,u ; clear BV.Module,u
                    clr       BV.Module+1,u ; clear BV.Module+1,u
done0@              clrb                ; clear accumulator B and carry
                    puls      x,y,u,pc  ; restore x,y,u,pc from stack

* Atomic, nonblocking lock. Caller may retry E$DevBsy after yielding.
Acquire             pshs      cc        ; preserve cc on stack
                    orcc      #IntMasks ; set selected CC bits with #IntMasks
                    tst       BV.Lock,u ; test BV.Lock,u
                    bne       busy0@    ; branch when unequal or nonzero busy0@
                    inc       BV.Lock,u ; increment BV.Lock,u
                    puls      cc        ; restore cc from stack
                    tst       BV.Ready,u ; test BV.Ready,u
                    beq       notready0@ ; branch when equal or zero notready0@
                    clrb                ; clear accumulator B and carry
                    rts                 ; return to caller
busy0@              puls      cc        ; restore cc from stack
                    ldb       #E$DevBsy ; load B from #E$DevBsy
                    coma                ; complement A and set carry
                    rts                 ; return to caller
notready0@          clr       BV.Lock,u ; clear BV.Lock,u
                    ldb       #E$NotRdy ; load B from #E$NotRdy
                    coma                ; complement A and set carry
                    rts                 ; return to caller
Release             pshs      cc        ; preserve cc on stack
                    clr       BV.Lock,u ; clear BV.Lock,u
                    puls      cc,pc     ; restore cc,pc from stack

* Backend has independent private state and immutable configuration.
CallBackend         pshs      x,y,u     ; preserve x,y,u on stack
                    ldy       BV.Entry,u ; load Y from BV.Entry,u
                    leay      a,y       ; point Y at a,y
                    pshs      y         ; preserve y on stack
                    leay      BV.Config,u ; point Y at BV.Config,u
                    ldu       BV.State,u ; load U from BV.State,u
                    jsr       [,s]      ; call routine [,s]
                    leas      2,s       ; point S at 2,s
                    puls      x,y,u,pc  ; restore x,y,u,pc from stack

GetInfo             lbsr      Acquire   ; call helper Acquire
                    bcs       ret1@     ; branch on carry or error ret1@
                    lda       BI.Size,x ; load A from BI.Size,x
                    cmpa      #BI.Len   ; compare A with #BI.Len
                    bne       bad1@     ; branch when unequal or nonzero bad1@
                    lda       BI.Version,x ; load A from BI.Version,x
                    cmpa      #BD.Version ; compare A with #BD.Version
                    bne       bad1@     ; branch when unequal or nonzero bad1@
                    lda       #BD.Info  ; load A from #BD.Info
                    lbsr      CallBackend ; call helper CallBackend
                    lbra      Release   ; continue unconditionally Release
bad1@               ldb       #E$IllArg ; load B from #E$IllArg
                    coma                ; complement A and set carry
                    lbra      Release   ; continue unconditionally Release
ret1@               rts                 ; return to caller
Flush               lbsr      Acquire   ; call helper Acquire
                    bcs       ret2@     ; branch on carry or error ret2@
                    lda       #BD.Flush ; load A from #BD.Flush
                    lbsr      CallBackend ; call helper CallBackend
                    lbra      Release   ; continue unconditionally Release
ret2@               rts                 ; return to caller
* IOMan frees statics even if Term reports an error: always release resources.
Term                tst       BV.Ready,u ; test BV.Ready,u
                    beq       termdispose@ ; branch when equal or zero termdispose@
                    lbsr      Acquire   ; call helper Acquire
                    bcs       termclean@ ; dispose even when acquiring the backend fails
                    lda       #BD.Flush ; load A from #BD.Flush
                    lbsr      CallBackend ; call helper CallBackend
                    pshs      b,cc      ; preserve b,cc on stack
                    lda       #BD.Term  ; load A from #BD.Term
                    lbsr      CallBackend ; call helper CallBackend
                    pshs      b,cc      ; term result
                    lda       2,s       ; flush CC
                    bita      #1        ; test A against #1
                    beq       termstatus@ ; branch when equal or zero termstatus@
                    leas      2,s       ; point S at 2,s
                    puls      b,cc      ; restore b,cc from stack
                    bra       termclean@ ; continue unconditionally termclean@
termstatus@         puls      b,cc      ; restore b,cc from stack
                    leas      2,s       ; point S at 2,s
termclean@          pshs      b,cc      ; preserve b,cc on stack
                    clr       BV.Ready,u ; clear BV.Ready,u
                    clr       BV.Lock,u ; clear BV.Lock,u
                    lbsr      Dispose   ; call helper Dispose
                    puls      b,cc,pc   ; restore b,cc,pc from stack
termdispose@        lbra      Dispose   ; continue unconditionally Dispose

Read                lda       #BD.Read  ; load A from #BD.Read
                    bra       Transfer  ; continue unconditionally Transfer
Write               lda       #BD.Write ; load A from #BD.Write
Transfer            pshs      a,x,y,u   ; preserve a,x,y,u on stack
                    lbsr      Acquire   ; call helper Acquire
                    lbcs      xret      ; branch on carry or error xret
* Reject malformed requests without touching fields beyond their length.
                    lda       BR.Size,x ; load A from BR.Size,x
                    cmpa      #BR.Len   ; compare A with #BR.Len
                    lbne      BadRequest ; branch when unequal or nonzero BadRequest
                    clra                ; clear accumulator A and carry
                    clrb                ; clear accumulator B and carry
                    std       BR.Done,x ; save D in BR.Done,x
                    lda       BR.Version,x ; load A from BR.Version,x
                    cmpa      #BD.Version ; compare A with #BD.Version
                    lbne      BadRequest ; branch when unequal or nonzero BadRequest
                    tst       BR.Flags,x ; test BR.Flags,x
                    lbne      BadRequest ; branch when unequal or nonzero BadRequest
                    leay      BV.Config,u ; point Y at BV.Config,u
                    lda       BR.Unit,x ; load A from BR.Unit,x
                    cmpa      BC.Unit,y ; compare A with BC.Unit,y
                    lbne      BadUnit   ; branch when unequal or nonzero BadUnit
                    leax      BV.Info,u ; point X at BV.Info,u
                    ldd       #BI.Len*256+BD.Version ; load D from #BI.Len*256+BD.Version
                    std       BI.Size,x ; save D in BI.Size,x
                    lda       #BD.Info  ; load A from #BD.Info
                    lbsr      CallBackend ; call helper CallBackend
                    lbcs      xrelease  ; branch on carry or error xrelease
                    ldx       1,s       ; load X from 1,s
                    lda       ,s        ; load A from ,s
                    cmpa      #BD.Write ; compare A with #BD.Write
                    bne       writable3@ ; branch when unequal or nonzero writable3@
                    lda       BV.Info+BI.Flags,u ; load A from BV.Info+BI.Flags,u
                    bita      #BF.ReadOnly ; test A against #BF.ReadOnly
                    lbne      Protected ; branch when unequal or nonzero Protected
writable3@          ldd       BV.Info+BI.BlockSize,u ; load D from BV.Info+BI.BlockSize,u
                    cmpd      #512      ; compare D with #512
                    lbne      BadRequest ; abi 1 implementation accepts 512 only
                    ldd       BR.Count,x ; load D from BR.Count,x
                    lbeq      BadRequest ; branch when equal or zero BadRequest
                    cmpd      BV.Info+BI.MaxCount,u ; compare D with BV.Info+BI.MaxCount,u
                    lbhi      BadRequest ; branch when unsigned higher BadRequest
                    cmpd      #127      ; 16-bit buffer length, no wrap
                    lbhi      BadRequest ; branch when unsigned higher BadRequest
                    tfr       b,a       ; transfer registers b,a
                    clrb                ; clear accumulator B and carry
                    lsla                ; count * 512
                    cmpd      BR.Bytes,x ; compare D with BR.Bytes,x
                    lbhi      BadRequest ; branch when unsigned higher BadRequest
                    addd      BR.Buffer,x ; add to D: BR.Buffer,x
                    lbcs      BadRequest ; branch on carry or error BadRequest
* Inclusive final LBA = start + count - 1, rejecting 32-bit overflow.
                    ldd       BR.Count,x ; load D from BR.Count,x
                    subd      #1        ; subtract from D: #1
                    addd      BR.LBA+2,x ; add to D: BR.LBA+2,x
                    pshs      d         ; preserve d on stack
                    ldd       BR.LBA,x  ; load D from BR.LBA,x
                    adcb      #0        ; add to B with carry: #0
                    adca      #0        ; add to A with carry: #0
                    bcs       overflow3@ ; branch on carry or error overflow3@
                    cmpd      BV.Info+BI.Last,u ; compare D with BV.Info+BI.Last,u
                    bhi       overflow3@ ; branch when unsigned higher overflow3@
                    blo       valid3@   ; branch when unsigned lower valid3@
                    ldd       ,s        ; load D from ,s
                    cmpd      BV.Info+BI.Last+2,u ; compare D with BV.Info+BI.Last+2,u
                    bhi       overflow3@ ; branch when unsigned higher overflow3@
valid3@             leas      2,s       ; point S at 2,s
                    lda       ,s        ; load A from ,s
                    lbsr      CallBackend ; call helper CallBackend
                    bra       xrelease  ; continue unconditionally xrelease
overflow3@          leas      2,s       ; point S at 2,s
                    ldb       #E$Sect   ; load B from #E$Sect
                    bra       xerror    ; continue unconditionally xerror
BadRequest          ldb       #E$IllArg ; load B from #E$IllArg
                    bra       xerror    ; continue unconditionally xerror
BadUnit             ldb       #E$Unit   ; load B from #E$Unit
                    bra       xerror    ; continue unconditionally xerror
Protected           ldb       #E$WP     ; load B from #E$WP
xerror              coma                ; complement A and set carry
xrelease            lbsr      Release   ; call helper Release
xret                puls      a,x,y,u,pc ; restore a,x,y,u,pc from stack
                    emod      ;         finish module and CRC
eom                 equ       *         ; define constant or offset
                    end       ;         end assembly source
