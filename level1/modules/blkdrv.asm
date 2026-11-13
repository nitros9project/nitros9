                    use       defsfile
                    use       blkdrv.d
                    mod       eom,name,Drivr+Objct,ReEnt+1,start,BV.Len
                    fcb       $FF       file manager owns path access policy
name                fcs       /blkdrv/
                    fcb       1
start               lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetInfo
                    lbra      Flush
                    lbra      Term

* Init: Y=descriptor, U=OS-9 statics. Other entries: X=request/info,
* Y=path, U=statics. GetInfo/Flush are kernel block calls, not SS codes.
Init                pshs      x,y,u
                    clr       BV.Ready,u
                    clr       BV.Lock,u
                    ldd       #0
                    std       BV.FMPaths,u
                    clr       V.BUSY,u
                    std       BV.Module,u
                    std       BV.State,u
                    lda       BT.Version,y
                    cmpa      #BD.Version
                    lbne      BadInit
* Copy configuration: IOMan may share statics after the first descriptor detaches.
                    pshs      y
                    leay      BT.Config,y
                    leax      BV.Config,u
                    ldb       #BC.Len
copycfg@            lda       ,y+
                    sta       ,x+
                    decb
                    bne       copycfg@
                    puls      y
                    ldd       BT.Backend,y
                    leax      d,y
                  IFGT    Level-1
                    ldd       <D.Proc
                    pshs      d
                    ldd       <D.SysPrc
                    std       <D.Proc
                  ENDC
                    lda       #Sbrtn+Objct
                    os9       F$Link
                  IFGT    Level-1
                    puls      x
                    stx       <D.Proc
                  ENDC
                    tfr       u,x
                    ldu       4,s
                    lbcs      InitExit
                    stx       BV.Module,u
                    sty       BV.Entry,u
* Reject a truncated backend header before reading its ABI metadata.
                    ldd       M$Size,x
                    subd      #3        ; exclude module CRC
                    cmpd      M$Exec,x
                    bls       BadInit
                    subd      M$Exec,x
                    cmpd      #BH.Len
                    blo       BadInit
                    ldd       BH.Magic,y
                    cmpd      #BD.Magic
                    bne       BadInit
                    lda       BH.Version,y
                    cmpa      #BD.Version
                    bne       BadInit
                    lda       BH.Size,y
                    cmpa      #BH.Len
                    bne       BadInit
                    ldd       BH.Memory,y
                    beq       BadInit
                    cmpd      #$FF00    ; f$SRqMem rounds to whole pages
                    bhi       BadInit
                    os9       F$SRqMem
                    tfr       u,x
                    ldu       4,s
                    bcs       InitFailed
                    stx       BV.State,u
                    std       BV.Alloc,u
* Clear allocated storage, including allocation rounding.
                    pshs      x
clear0@             clr       ,x+
                    subd      #1
                    bne       clear0@
                    puls      x
                    lda       #BD.Init
                    lbsr      CallBackend
                    bcs       InitFailed
                    inc       BV.Ready,u
                    clrb
InitExit            puls      x,y,u,pc
BadInit             ldb       #E$BMode
                    coma
InitFailed          pshs      b
                    lbsr      Dispose
                    puls      b
                    coma
                    bra       InitExit

* Allocation and link cleanup, also safe after a partially failed Init.
Dispose             pshs      x,y,u
                    ldx       BV.State,u
                    beq       unlink0@
                    ldd       BV.Alloc,u
                    pshs      u
                    tfr       x,u
                    os9       F$SRtMem
                    puls      u
                    clr       BV.State,u
                    clr       BV.State+1,u
unlink0@            ldx       BV.Module,u
                    beq       done0@
                  IFGT    Level-1
                    ldd       <D.Proc
                    pshs      d
                    ldd       <D.SysPrc
                    std       <D.Proc
                  ENDC
                    pshs      u
                    tfr       x,u
                    os9       F$UnLink
                    puls      u
                  IFGT    Level-1
                    puls      d
                    std       <D.Proc
                  ENDC
                    clr       BV.Module,u
                    clr       BV.Module+1,u
done0@              clrb
                    puls      x,y,u,pc

* Atomic, nonblocking lock. Caller may retry E$DevBsy after yielding.
Acquire             pshs      cc
                    orcc      #IntMasks
                    tst       BV.Lock,u
                    bne       busy0@
                    inc       BV.Lock,u
                    puls      cc
                    tst       BV.Ready,u
                    beq       notready0@
                    clrb
                    rts
busy0@              puls      cc
                    ldb       #E$DevBsy
                    coma
                    rts
notready0@          clr       BV.Lock,u
                    ldb       #E$NotRdy
                    coma
                    rts
Release             pshs      cc
                    clr       BV.Lock,u
                    puls      cc,pc

* Backend has independent private state and immutable configuration.
CallBackend         pshs      x,y,u
                    ldy       BV.Entry,u
                    leay      a,y
                    pshs      y
                    leay      BV.Config,u
                    ldu       BV.State,u
                    jsr       [,s]
                    leas      2,s
                    puls      x,y,u,pc

GetInfo             lbsr      Acquire
                    bcs       ret1@
                    lda       BI.Size,x
                    cmpa      #BI.Len
                    bne       bad1@
                    lda       BI.Version,x
                    cmpa      #BD.Version
                    bne       bad1@
                    lda       #BD.Info
                    lbsr      CallBackend
                    lbra      Release
bad1@               ldb       #E$IllArg
                    coma
                    lbra      Release
ret1@               rts
Flush               lbsr      Acquire
                    bcs       ret2@
                    lda       #BD.Flush
                    lbsr      CallBackend
                    lbra      Release
ret2@               rts
* IOMan frees statics even if Term reports an error: always release resources.
Term                tst       BV.Ready,u
                    beq       termdispose@
                    lbsr      Acquire
                    bcs       termret@
                    lda       #BD.Flush
                    lbsr      CallBackend
                    pshs      b,cc
                    lda       #BD.Term
                    lbsr      CallBackend
                    pshs      b,cc      ; term result
                    lda       2,s       ; flush CC
                    bita      #1
                    beq       termstatus@
                    leas      2,s
                    puls      b,cc
                    bra       termclean@
termstatus@         puls      b,cc
                    leas      2,s
termclean@          pshs      b,cc
                    clr       BV.Ready,u
                    clr       BV.Lock,u
                    lbsr      Dispose
                    puls      b,cc,pc
termdispose@        lbra      Dispose
termret@            rts

Read                lda       #BD.Read
                    bra       Transfer
Write               lda       #BD.Write
Transfer            pshs      a,x,y,u
                    lbsr      Acquire
                    lbcs      xret
* Reject malformed requests without touching fields beyond their length.
                    lda       BR.Size,x
                    cmpa      #BR.Len
                    lbne      BadRequest
                    clra
                    clrb
                    std       BR.Done,x
                    lda       BR.Version,x
                    cmpa      #BD.Version
                    lbne      BadRequest
                    tst       BR.Flags,x
                    lbne      BadRequest
                    leay      BV.Config,u
                    lda       BR.Unit,x
                    cmpa      BC.Unit,y
                    lbne      BadUnit
                    leax      BV.Info,u
                    ldd       #BI.Len*256+BD.Version
                    std       BI.Size,x
                    lda       #BD.Info
                    lbsr      CallBackend
                    lbcs      xrelease
                    ldx       1,s
                    lda       ,s
                    cmpa      #BD.Write
                    bne       writable3@
                    lda       BV.Info+BI.Flags,u
                    bita      #BF.ReadOnly
                    lbne      Protected
writable3@          ldd       BV.Info+BI.BlockSize,u
                    cmpd      #512
                    lbne      BadRequest ; abi 1 implementation accepts 512 only
                    ldd       BR.Count,x
                    lbeq      BadRequest
                    cmpd      BV.Info+BI.MaxCount,u
                    lbhi      BadRequest
                    cmpd      #127      ; 16-bit buffer length, no wrap
                    lbhi      BadRequest
                    tfr       b,a
                    clrb
                    lsla                ; count * 512
                    cmpd      BR.Bytes,x
                    lbhi      BadRequest
                    addd      BR.Buffer,x
                    lbcs      BadRequest
* Inclusive final LBA = start + count - 1, rejecting 32-bit overflow.
                    ldd       BR.Count,x
                    subd      #1
                    addd      BR.LBA+2,x
                    pshs      d
                    ldd       BR.LBA,x
                    adcb      #0
                    adca      #0
                    bcs       overflow3@
                    cmpd      BV.Info+BI.Last,u
                    bhi       overflow3@
                    blo       valid3@
                    ldd       ,s
                    cmpd      BV.Info+BI.Last+2,u
                    bhi       overflow3@
valid3@             leas      2,s
                    lda       ,s
                    lbsr      CallBackend
                    bra       xrelease
overflow3@          leas      2,s
                    ldb       #E$Sect
                    bra       xerror
BadRequest          ldb       #E$IllArg
                    bra       xerror
BadUnit             ldb       #E$Unit
                    bra       xerror
Protected           ldb       #E$WP
xerror              coma
xrelease            lbsr      Release
xret                puls      a,x,y,u,pc
                    emod
eom                 equ       *
                    end
