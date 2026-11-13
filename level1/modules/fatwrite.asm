* PCF mutation support. Caller holds the device-wide file-manager lock.
* Writes are synchronous. The media must not be modified outside this mount.
Writable            lda       F.Info+BI.Flags,u ; load A from F.Info+BI.Flags,u
                    bita      #BF.ReadOnly ; test A against #BF.ReadOnly
                    lbne      ReadOnly  ; branch when unequal or nonzero ReadOnly
                    clrb                ; clear accumulator B and carry
                    rts                 ; return to caller
CanWriteFile        bsr       Writable  ; call helper Writable
                    bcs       canret@   ; branch on carry or error canret@
                    lda       F.Entry+11,u ; load A from F.Entry+11,u
                    bita      #$11                 readonly or directory
                    lbne      AccessError ; branch when unequal or nonzero AccessError
                    tst       F.HasLFN,u           mutations are short-name only for now
                    lbne      AccessError ; branch when unequal or nonzero AccessError
                    clrb                ; clear accumulator B and carry
canret@             rts                 ; return to caller
Attributes          lda       #READ.+EXEC.+PREAD.+PEXEC. ; load A from #READ.+EXEC.+PREAD.+PEXEC.
                    bitb      #1        ; test B against #1
                    bne       attrdir@  ; branch when unequal or nonzero attrdir@
                    pshs      b         ; preserve b on stack
                    ldb       F.Info+BI.Flags,u ; load B from F.Info+BI.Flags,u
                    bitb      #BF.ReadOnly ; test B against #BF.ReadOnly
                    puls      b         ; restore b from stack
                    bne       attrdir@  ; branch when unequal or nonzero attrdir@
                    ora       #WRITE.+PWRIT. ; merge A with #WRITE.+PWRIT.
attrdir@            bitb      #$10      ; test B against #$10
                    beq       attrret@  ; branch when equal or zero attrret@
                    ora       #DIR.     ; merge A with #DIR.
attrret@            rts                 ; return to caller

* Link live paths through opaque blkdrv file-manager storage. A writer excludes
* other opens of the same file; delete refuses even a read-open target.
RegisterPath        lda       PD.MOD,y  ; load A from PD.MOD,y
                    anda      #WRITE.   ; mask A with #WRITE.
                    bsr       CheckSharing ; call helper CheckSharing
                    bcs       registerret@ ; branch on carry or error registerret@
                    ldx       PD.DEV,y  ; load X from PD.DEV,y
                    ldx       V$STAT,x  ; load X from V$STAT,x
                    ldd       BV.FMPaths,x ; load D from BV.FMPaths,x
                    std       F.NextPath,u ; save D in F.NextPath,u
                    stu       BV.FMPaths,x ; save U in BV.FMPaths,x
                    inc       F.Registered,u ; increment F.Registered,u
                    clrb                ; clear accumulator B and carry
registerret@        rts                 ; return to caller
CheckSharing        pshs      a,x,y     ; preserve a,x,y on stack
                    ldx       PD.DEV,y  ; load X from PD.DEV,y
                    ldx       V$STAT,x  ; load X from V$STAT,x
                    ldx       BV.FMPaths,x ; load X from BV.FMPaths,x
shareloop@          cmpx      #0        ; compare X with #0
                    beq       shareok@  ; branch when equal or zero shareok@
                    pshs      u         ; preserve u on stack
                    cmpx      ,s++      ; compare X with ,s++
                    beq       sharenext@ ; branch when equal or zero sharenext@
                    ldd       F.DirLBA,u ; load D from F.DirLBA,u
                    cmpd      F.DirLBA,x ; compare D with F.DirLBA,x
                    bne       sharenext@ ; branch when unequal or nonzero sharenext@
                    ldd       F.DirLBA+2,u ; load D from F.DirLBA+2,u
                    cmpd      F.DirLBA+2,x ; compare D with F.DirLBA+2,x
                    bne       sharenext@ ; branch when unequal or nonzero sharenext@
                    ldd       F.DirOff,u ; load D from F.DirOff,u
                    cmpd      F.DirOff,x ; compare D with F.DirOff,x
                    bne       sharenext@ ; branch when unequal or nonzero sharenext@
                    lda       F.Entry+11,u ; load A from F.Entry+11,u
                    bita      #$10      ; test A against #$10
                    bne       sharenext@ ; branch when unequal or nonzero sharenext@
                    tst       ,s        ; test ,s
                    bne       sharebad@ ; branch when unequal or nonzero sharebad@
                    ldy       F.Owner,x ; load Y from F.Owner,x
                    lda       PD.MOD,y  ; load A from PD.MOD,y
                    bita      #WRITE.   ; test A against #WRITE.
                    bne       sharebad@ ; branch when unequal or nonzero sharebad@
sharenext@          ldx       F.NextPath,x ; load X from F.NextPath,x
                    bra       shareloop@ ; continue unconditionally shareloop@
shareok@            clrb                ; clear accumulator B and carry
                    puls      a,x,y,pc  ; restore a,x,y,pc from stack
sharebad@           ldb       #E$Share  ; load B from #E$Share
                    coma                ; complement A and set carry
                    puls      a,x,y,pc  ; restore a,x,y,pc from stack
UnregisterPath      pshs      x         ; preserve x on stack
                    tst       F.Registered,u ; test F.Registered,u
                    beq       unlinkdone@ ; branch when equal or zero unlinkdone@
                    ldx       PD.DEV,y  ; load X from PD.DEV,y
                    ldx       V$STAT,x  ; load X from V$STAT,x
                    leax      BV.FMPaths,x ; point X at BV.FMPaths,x
unlinkloop@         tfr       u,d       ; transfer registers u,d
                    cmpd      ,x        ; compare D with ,x
                    beq       unlinkfound@ ; branch when equal or zero unlinkfound@
                    ldx       ,x        ; load X from ,x
                    beq       unlinkdone@ ; branch when equal or zero unlinkdone@
                    leax      F.NextPath,x ; point X at F.NextPath,x
                    bra       unlinkloop@ ; continue unconditionally unlinkloop@
unlinkfound@        ldd       F.NextPath,u ; load D from F.NextPath,u
                    std       ,x        ; save D in ,x
                    clr       F.Registered,u ; clear F.Registered,u
unlinkdone@         puls      x,pc      ; restore x,pc from stack
EntryLocation       pshs      x         ; preserve x on stack
                    tfr       x,d       ; transfer registers x,d
                    leax      F.Data,u  ; point X at F.Data,u
                    pshs      x         ; preserve x on stack
                    subd      ,s++      ; subtract from D: ,s++
                    std       F.DirOff,u ; save D in F.DirOff,u
                    ldd       #F.DataLBA*256+F.DirLBA ; load D from #F.DataLBA*256+F.DirLBA
                    lbsr      CopyVal   ; call helper CopyVal
                    puls      x,pc      ; restore x,pc from stack

* Remember valid reserved-sector FSInfo locations. Backup FSInfo is at
* BPB_BkBootSec + BPB_FSInfo; either may legitimately be absent.
MountWriteInfo      lda       F.Data+40,u ; load A from F.Data+40,u
                    bita      #$80      ; test A against #$80
                    bne       infoaddr@ ; branch when unequal or nonzero infoaddr@
                    inc       F.Mirror,u ; increment F.Mirror,u
infoaddr@           leax      F.Data+48,u ; point X at F.Data+48,u
                    lbsr      LE16      ; call helper LE16
                    ldd       F.Val+2,u ; load D from F.Val+2,u
                    beq       infodone@ ; branch when equal or zero infodone@
                    pshs      d         ; preserve d on stack
                    leax      F.Data+14,u ; point X at F.Data+14,u
                    lbsr      LE16      ; call helper LE16
                    ldd       ,s        ; load D from ,s
                    cmpd      F.Val+2,u ; compare D with F.Val+2,u
                    bhs       infopop@  ; branch when unsigned higher or equal infopop@
                    leax      F.Data+48,u ; point X at F.Data+48,u
                    lbsr      LE16      ; call helper LE16
                    leax      F.Base,u  ; point X at F.Base,u
                    lbsr      AddBase   ; call helper AddBase
                    lda       #F.FSInfo-128 ; load A from #F.FSInfo-128
                    lbsr      StoreField ; call helper StoreField
                    leax      F.Data+50,u ; point X at F.Data+50,u
                    lbsr      LE16      ; call helper LE16
                    ldd       F.Val+2,u ; load D from F.Val+2,u
                    beq       infopop@  ; branch when equal or zero infopop@
                    addd      ,s        ; add to D: ,s
                    bcs       infopop@  ; branch on carry or error infopop@
                    std       ,s        ; save D in ,s
                    leax      F.Data+14,u ; point X at F.Data+14,u
                    lbsr      LE16      ; call helper LE16
                    ldd       ,s        ; load D from ,s
                    cmpd      F.Val+2,u ; compare D with F.Val+2,u
                    bhs       infopop@  ; branch when unsigned higher or equal infopop@
                    std       F.Val+2,u ; save D in F.Val+2,u
                    leax      F.Base,u  ; point X at F.Base,u
                    lbsr      AddBase   ; call helper AddBase
                    lda       #F.BackInfo-128 ; load A from #F.BackInfo-128
                    lbsr      StoreField ; call helper StoreField
infopop@            leas      2,s       ; point S at 2,s
infodone@           rts                 ; return to caller

* Store Val little endian at X without changing its reserved FAT bits elsewhere.
PutLE               lda       F.Val+3,u ; load A from F.Val+3,u
                    sta       ,x        ; save A in ,x
                    lda       F.Val+2,u ; load A from F.Val+2,u
                    sta       1,x       ; save A in 1,x
                    lda       F.Val+1,u ; load A from F.Val+1,u
                    sta       2,x       ; save A in 2,x
                    lda       F.Val,u   ; load A from F.Val,u
                    sta       3,x       ; save A in 3,x
                    rts                 ; return to caller
WriteData           leax      F.Data,u  ; point X at F.Data,u
                    stx       F.Request+BR.Buffer,u ; save X in F.Request+BR.Buffer,u
                    lda       #F.DataLBA-128 ; load A from #F.DataLBA-128
                    lbsr      LoadField ; call helper LoadField
                    lbra      WriteBlock ; continue unconditionally WriteBlock
Flush               leax      F.Request,u ; point X at F.Request,u
                    lda       #BD.Flush ; load A from #BD.Flush
                    lbra      Driver    ; continue unconditionally Driver

* F.Cluster entry <- F.Value. Update every FAT if mirrored, active FAT only
* otherwise. Re-read each copy so its upper four reserved bits are preserved.
SetFat              clr       F.FatCopy,u ; clear F.FatCopy,u
setfatloop@         lbsr      FatEntry  ; call helper FatEntry
                    bcs       setfatret@ ; branch on carry or error setfatret@
                    tst       F.FatCopy,u ; test F.FatCopy,u
                    beq       setfatstore@ ; branch when equal or zero setfatstore@
                    lda       #F.FatLBA-128 ; load A from #F.FatLBA-128
                    lbsr      LoadField ; call helper LoadField
                    ldb       F.FatCopy,u ; offset from the active FAT base
                    pshs      b         ; preserve copy index through arithmetic
                    leax      F.FatSize,u ; sectors per FAT copy
fatcopyoffset@      lbsr      AddBase   ; add one complete FAT
                    dec       ,s        ; count copied FAT spans
                    bne       fatcopyoffset@ ; support every configured mirror
                    leas      1,s       ; release copy counter
                    lbsr      ReadFat   ; call helper ReadFat
                    bcs       setfatret@ ; branch on carry or error setfatret@
                    ldb       F.Cluster+3,u ; load B from F.Cluster+3,u
                    andb      #127      ; mask B with #127
                    clra                ; clear accumulator A and carry
                    lslb                ; shift or rotate accumulator B
                    rola                ; shift or rotate accumulator A
                    lslb                ; shift or rotate accumulator B
                    rola                ; shift or rotate accumulator A
                    leax      d,x       ; point X at d,x
setfatstore@        pshs      x         ; preserve x on stack
                    lda       3,x       ; load A from 3,x
                    anda      #$F0      ; mask A with #$F0
                    pshs      a         ; preserve a on stack
                    lda       #F.Value-128 ; load A from #F.Value-128
                    lbsr      LoadField ; call helper LoadField
                    lda       F.Val,u   ; load A from F.Val,u
                    anda      #15       ; mask A with #15
                    ora       ,s+       ; merge A with ,s+
                    sta       F.Val,u   ; save A in F.Val,u
                    puls      x         ; restore x from stack
                    bsr       PutLE     ; call helper PutLE
                    leax      F.Fat,u   ; point X at F.Fat,u
                    stx       F.Request+BR.Buffer,u ; save X in F.Request+BR.Buffer,u
                    lda       #F.FatLBA-128 ; load A from #F.FatLBA-128
                    lbsr      LoadField ; call helper LoadField
                    lbsr      WriteBlock ; call helper WriteBlock
                    bcs       setfatret@ ; branch on carry or error setfatret@
                    tst       F.Mirror,u ; test F.Mirror,u
                    beq       setfatok@ ; branch when equal or zero setfatok@
                    inc       F.FatCopy,u ; increment F.FatCopy,u
                    lda       F.FatCopy,u ; load A from F.FatCopy,u
                    cmpa      F.Fats,u  ; compare A with F.Fats,u
                    blo       setfatloop@ ; branch when unsigned lower setfatloop@
setfatok@           clrb                ; clear accumulator B and carry
setfatret@          pshs      cc        ; preserve cc on stack
                    clr       F.FatValid,u ; clear F.FatValid,u
                    puls      cc,pc     ; restore cc,pc from stack

* Read and update optional FSInfo hints. Unknown counts stay unknown.
* Invalid/missing FSInfo is ignored; it is not authoritative allocation data.
UpdateHints         lda       #F.FSInfo-128 ; load A from #F.FSInfo-128
                    lbsr      LoadField ; call helper LoadField
                    bsr       UpdateHint ; call helper UpdateHint
                    lbcs      hintret@  ; branch on carry or error hintret@
                    lda       #F.BackInfo-128 ; load A from #F.BackInfo-128
                    lbsr      LoadField ; call helper LoadField
UpdateHint          ldd       F.Val,u   ; load D from F.Val,u
                    bne       hintread@ ; branch when unequal or nonzero hintread@
                    ldd       F.Val+2,u ; load D from F.Val+2,u
                    lbeq      hintok@   ; branch when equal or zero hintok@
hintread@           lbsr      ReadData  ; call helper ReadData
                    lbcs      hintret@  ; branch on carry or error hintret@
                    ldd       ,x        ; load D from ,x
                    cmpd      #$5252    ; compare D with #$5252
                    lbne      hintok@   ; branch when unequal or nonzero hintok@
                    ldd       2,x       ; load D from 2,x
                    cmpd      #$6141    ; compare D with #$6141
                    lbne      hintok@   ; branch when unequal or nonzero hintok@
                    ldd       484,x     ; load D from 484,x
                    cmpd      #$7272    ; compare D with #$7272
                    lbne      hintok@   ; branch when unequal or nonzero hintok@
                    ldd       486,x     ; load D from 486,x
                    cmpd      #$4161    ; compare D with #$4161
                    lbne      hintok@   ; branch when unequal or nonzero hintok@
                    ldd       508,x     ; fsinfo trail signature
                    lbne      hintok@   ; reject malformed hints
                    ldd       510,x     ; remaining trail bytes
                    cmpd      #$55AA    ; little-endian $AA550000
                    lbne      hintok@   ; ignore damaged sector
                    leax      488,x     ; point X at 488,x
                    pshs      x         ; preserve x on stack
                    lbsr      LE32      ; call helper LE32
                    ldd       F.Val,u   ; load D from F.Val,u
                    cmpd      #$FFFF    ; compare D with #$FFFF
                    bne       hintcount@ ; validate known count
                    ldd       F.Val+2,u ; unknown must be exactly $FFFFFFFF
                    cmpd      #$FFFF    ; reserved unknown value
                    beq       hintunknown@ ; retain unknown
hintcount@          leax      F.MaxCluster,u ; cluster count is MaxCluster minus one
                    lbsr      CompareVal ; reject out-of-range free counts
                    bhs       hintinvalid@ ; do not wrap a corrupt count
                    tst       F.HintDelta,u ; choose count adjustment
                    bpl       hintincrement@ ; a free adds one cluster
                    ldd       F.Val,u   ; protect zero from underflow
                    bne       hintincrement@ ; nonzero high word
                    ldd       F.Val+2,u ; low count
                    beq       hintinvalid@ ; cannot decrement zero
hintincrement@
                    tst       F.HintDelta,u ; test F.HintDelta,u
                    bmi       hintdec@  ; branch when negative hintdec@
                    lbsr      IncVal    ; call helper IncVal
                    bra       hintput@  ; continue unconditionally hintput@
hintdec@            lbsr      DecVal    ; call helper DecVal
hintput@            ldx       ,s        ; load X from ,s
                    lbsr      PutLE     ; call helper PutLE
                    bra       hintunknown@ ; write adjusted count
hintinvalid@        ldx       ,s        ; mark invalid count unknown
                    ldd       #$FFFF    ; unknown free count
                    std       ,x        ; first word
                    std       2,x       ; second word
hintunknown@        puls      x         ; restore x from stack
                    ldd       #$FFFF    ; load D from #$FFFF
                    std       4,x       ; save D in 4,x
                    std       6,x       ; save D in 6,x
                    lbra      WriteData ; continue unconditionally WriteData
hintok@             clrb                ; clear accumulator B and carry
hintret@            rts                 ; return to caller

ClusterBase         lbsr      DecVal    ; call helper DecVal
                    lbsr      DecVal    ; call helper DecVal
                    ldb       F.Shift,u ; load B from F.Shift,u
                    beq       clusterbase@ ; branch when equal or zero clusterbase@
                    lbsr      ShiftLeft ; call helper ShiftLeft
                    bcs       baseret@  ; branch on carry or error baseret@
clusterbase@        leax      F.DataStart,u ; point X at F.DataStart,u
                    lbsr      AddBase   ; call helper AddBase
baseret@            rts                 ; return to caller
* Return New = allocated, zeroed EOC cluster. Always consult the FAT itself.
Allocate            lda       #F.New-128 ; previous allocation is a scan hint
                    lbsr      LoadField ; start just after it
                    lbsr      IncVal    ; next possible free cluster
                    leax      F.MaxCluster,u ; validate the hint
                    lbsr      CompareVal ; last legal cluster
                    bhi       allocreset@ ; stale/high hint wraps to cluster two
                    ldd       F.Val,u   ; high word of candidate
                    bne       allocstart@ ; nonzero high word is at least two
                    ldd       F.Val+2,u ; low candidate word
                    cmpd      #2        ; skip reserved clusters zero and one
                    bhs       allocstart@ ; valid starting point
allocreset@         clra                ; reset invalid/end hint
                    clrb                ; clear high word
                    std       F.Val,u   ; high word zero
                    ldd       #2        ; first data cluster
                    std       F.Val+2,u ; low word two
allocstart@         lda       #F.New-128 ; save current candidate
                    lbsr      StoreField ; candidate in New
                    ldd       F.New+2,u ; remember starting point for wrap detection
                    pshs      d         ; low word of scan origin
                    ldd       F.New,u   ; high word of scan origin
                    pshs      d         ; retain full 32-bit origin
allocscan@          lda       #F.New-128 ; load A from #F.New-128
                    lbsr      LoadField ; call helper LoadField
                    leax      F.MaxCluster,u ; point X at F.MaxCluster,u
                    lbsr      CompareVal ; call helper CompareVal
                    lbhi      allocwrap@ ; end of FAT wraps to first cluster
                    lda       #F.Cluster-128 ; load A from #F.Cluster-128
                    lbsr      StoreField ; call helper StoreField
                    lbsr      FatEntry  ; call helper FatEntry
                    lbcs      allocret@ ; branch on carry or error allocret@
                    lbsr      LE32      ; call helper LE32
                    lda       F.Val,u   ; load A from F.Val,u
                    anda      #15       ; mask A with #15
                    ora       F.Val+1,u ; merge A with F.Val+1,u
                    ora       F.Val+2,u ; merge A with F.Val+2,u
                    ora       F.Val+3,u ; merge A with F.Val+3,u
                    lbeq      allocfree@ ; branch when equal or zero allocfree@
                    lda       #F.New-128 ; load A from #F.New-128
                    lbsr      IncField  ; call helper IncField
alloccheck@         ldd       F.New,u   ; detect a complete circular scan
                    cmpd      ,s        ; compare origin high word
                    bne       allocscan@ ; not yet wrapped
                    ldd       F.New+2,u ; compare origin low word
                    cmpd      2,s       ; complete origin
                    lbeq      allocfull@ ; every usable cluster is allocated
                    bra       allocscan@ ; inspect next candidate
allocwrap@          clra                ; wrap high word to zero
                    clrb                ; clear low accumulator
                    std       F.New,u   ; high candidate word
                    ldd       #2        ; first usable cluster
                    std       F.New+2,u ; candidate two
                    bra       alloccheck@ ; avoid rescanning a full volume
allocfree@          lda       #F.New-128 ; load A from #F.New-128
                    lbsr      LoadField ; call helper LoadField
                    lbsr      ClusterBase ; call helper ClusterBase
                    lbcs      allocret@ ; branch on carry or error allocret@
                    lda       #F.DataLBA-128 ; load A from #F.DataLBA-128
                    lbsr      StoreField ; call helper StoreField
                    leax      F.Data,u  ; point X at F.Data,u
                    ldd       #512      ; load D from #512
alloczero@          clr       ,x+       ; clear ,x+
                    subd      #1        ; subtract from D: #1
                    bne       alloczero@ ; branch when unequal or nonzero alloczero@
                    clr       F.DataValid,u ; clear F.DataValid,u
                    lda       F.SPC,u   ; load A from F.SPC,u
                    sta       F.Sectors,u ; save A in F.Sectors,u
allocsector@        lbsr      WriteData ; call helper WriteData
                    lbcs      allocret@ ; branch on carry or error allocret@
                    lda       #F.DataLBA-128 ; load A from #F.DataLBA-128
                    lbsr      IncField  ; call helper IncField
                    dec       F.Sectors,u ; decrement F.Sectors,u
                    bne       allocsector@ ; branch when unequal or nonzero allocsector@
                    ldd       #$0FFF    ; load D from #$0FFF
                    std       F.Value,u ; save D in F.Value,u
                    ldd       #$FFFF    ; load D from #$FFFF
                    std       F.Value+2,u ; save D in F.Value+2,u
                    ldd       #F.New*256+F.Cluster ; load D from #F.New*256+F.Cluster
                    lbsr      CopyVal   ; call helper CopyVal
                    lbsr      SetFat    ; call helper SetFat
                    bcs       allocundo@ ; reclaim a partially written EOC
                    lda       #$FF      ; load A from #$FF
                    sta       F.HintDelta,u ; save A in F.HintDelta,u
                    lbsr      UpdateHints ; best-effort advisory update
                    clrb                ; allocation is already committed
                    bra       allocret@ ; release scan origin
allocundo@          pshs      b,cc      ; preserve FAT publication error
                    clra                ; unpublished cluster was free
                    clrb                ; zero FAT value
                    std       F.Value,u ; high word zero
                    std       F.Value+2,u ; low word zero
                    lbsr      SetFat    ; restore all FAT mirrors if possible
                    puls      b,cc      ; return original failure
                    bra       allocret@ ; release scan state
allocfull@          ldb       #E$Full   ; load B from #E$Full
                    coma                ; complement A and set carry
allocret@           leas      4,s       ; release scan origin
                    rts                 ; return to caller

* Validate the complete chain before destructive operations (including cycles).
ValidateChain       ldd       F.Start,u ; load D from F.Start,u
                    bne       validatebegin@ ; branch when unequal or nonzero validatebegin@
                    ldd       F.Start+2,u ; load D from F.Start+2,u
                    beq       validateok@ ; branch when equal or zero validateok@
validatebegin@      lbsr      ResetWalk ; call helper ResetWalk
                    bcs       validateret@ ; branch on carry or error validateret@
validateloop@       lbsr      Advance   ; call helper Advance
                    bcc       validateloop@ ; branch with carry clear validateloop@
                    cmpb      #E$EOF    ; compare B with #E$EOF
                    bne       validatebad@ ; branch when unequal or nonzero validatebad@
validateok@         clrb                ; clear accumulator B and carry
validateret@        rts                 ; return to caller
validatebad@        coma                ; complement A and set carry
                    rts                 ; return to caller
* Free a previously validated chain beginning at Saved (zero is empty).
FreeChain           ldd       F.Saved,u ; load D from F.Saved,u
                    bne       freechainloop@ ; branch when unequal or nonzero freechainloop@
                    ldd       F.Saved+2,u ; load D from F.Saved+2,u
                    beq       freechainok@ ; branch when equal or zero freechainok@
freechainloop@      ldd       #F.Saved*256+F.Cluster ; load D from #F.Saved*256+F.Cluster
                    lbsr      CopyVal   ; call helper CopyVal
                    lbsr      NextCluster ; call helper NextCluster
                    bcc       freenext@ ; branch with carry clear freenext@
                    cmpb      #E$EOF    ; compare B with #E$EOF
                    bne       freechainbad@ ; branch when unequal or nonzero freechainbad@
                    clra                ; clear accumulator A and carry
                    clrb                ; clear accumulator B and carry
                    std       F.Val,u   ; save D in F.Val,u
                    std       F.Val+2,u ; save D in F.Val+2,u
freenext@           lda       #F.Link-128 ; load A from #F.Link-128
                    lbsr      StoreField ; call helper StoreField
                    ldd       #F.Saved*256+F.Cluster ; load D from #F.Saved*256+F.Cluster
                    lbsr      CopyVal   ; call helper CopyVal
                    clra                ; clear accumulator A and carry
                    clrb                ; clear accumulator B and carry
                    std       F.Value,u ; save D in F.Value,u
                    std       F.Value+2,u ; save D in F.Value+2,u
                    lbsr      SetFat    ; call helper SetFat
                    bcs       freechainret@ ; branch on carry or error freechainret@
                    lda       #1        ; load A from #1
                    sta       F.HintDelta,u ; save A in F.HintDelta,u
                    lbsr      UpdateHints ; hint errors cannot stop chain reclamation
                    ldd       #F.Link*256+F.Saved ; load D from #F.Link*256+F.Saved
                    lbsr      CopyVal   ; call helper CopyVal
                    bra       FreeChain ; continue unconditionally FreeChain
freechainok@        clrb                ; clear accumulator B and carry
freechainret@       rts                 ; return to caller
freechainbad@       coma                ; complement A and set carry
                    rts                 ; return to caller

* FAT timestamps from the kernel's six-byte clock (year is since 1900).
Stamp               pshs      x,y,cc    ; preserve x,y,cc on stack
                    orcc      #IntMasks ; set selected CC bits with #IntMasks
                    ldx       #D.Time   ; load X from #D.Time
                    leay      F.Time,u  ; point Y at F.Time,u
                    ldb       #6        ; load B from #6
                    lbsr      CopyBytes ; call helper CopyBytes
                    puls      cc,x,y    ; restore cc,x,y from stack
EncodeTime          lda       F.Time,u  ; load A from F.Time,u
                    cmpa      #80       ; compare A with #80
                    bhs       stampyear@ ; branch when unsigned higher or equal stampyear@
                    lda       #80       ; load A from #80
stampyear@          cmpa      #207      ; last FAT year is 2107
                    bls       stampbounded@ ; retain representable year
                    lda       #207      ; saturate upper bound
stampbounded@       suba      #80       ; subtract from A: #80
                    lsla                ; shift or rotate accumulator A
                    sta       F.Entry+25,u ; save A in F.Entry+25,u
                    ldb       F.Time+1,u ; load B from F.Time+1,u
                    bne       stampmonth@ ; branch when unequal or nonzero stampmonth@
                    ldb       #1        ; load B from #1
* Month * 32 supplies both the high date bits and the low date byte.
stampmonth@         lda       #32       ; load A from #32
                    mul                 ; multiply A by B into D
                    ora       F.Entry+25,u ; merge A with F.Entry+25,u
                    sta       F.Entry+25,u ; save A in F.Entry+25,u
                    lda       F.Time+2,u ; load A from F.Time+2,u
                    bne       stampday@ ; branch when unequal or nonzero stampday@
                    lda       #1        ; load A from #1
stampday@           pshs      b         ; preserve b on stack
                    ora       ,s+       ; merge A with ,s+
                    sta       F.Entry+24,u ; save A in F.Entry+24,u
* Minute * 32 supplies both time bytes; combine hours and half-seconds.
                    lda       #32       ; load A from #32
                    ldb       F.Time+4,u ; load B from F.Time+4,u
                    mul                 ; multiply A by B into D
                    pshs      d         ; preserve d on stack
                    lda       F.Time+3,u ; load A from F.Time+3,u
                    lsla                ; shift or rotate accumulator A
                    lsla                ; shift or rotate accumulator A
                    lsla                ; shift or rotate accumulator A
                    ora       ,s+       ; merge A with ,s+
                    sta       F.Entry+23,u ; save A in F.Entry+23,u
                    lda       F.Time+5,u ; load A from F.Time+5,u
                    lsra                ; shift or rotate accumulator A
                    ora       ,s+       ; merge A with ,s+
                    sta       F.Entry+22,u ; save A in F.Entry+22,u
                    rts                 ; return to caller
UpdateEntry         bsr       Stamp     ; call helper Stamp
CommitEntry         lda       #F.Start-128 ; load A from #F.Start-128
                    lbsr      LoadField ; call helper LoadField
                    leax      F.Entry,u ; point X at F.Entry,u
                    lbsr      EntryCluster ; call helper EntryCluster
                    lda       #F.Size-128 ; load A from #F.Size-128
                    lbsr      LoadField ; call helper LoadField
                    leax      F.Entry+28,u ; point X at F.Entry+28,u
                    lbsr      PutLE     ; call helper PutLE
                    lda       F.Entry+11,u ; load A from F.Entry+11,u
                    ora       #$20      ; merge A with #$20
                    sta       F.Entry+11,u ; save A in F.Entry+11,u
                    lda       #F.DirLBA-128 ; load A from #F.DirLBA-128
                    lbsr      LoadField ; call helper LoadField
                    lbsr      ReadData  ; call helper ReadData
                    bcs       commitret@ ; branch on carry or error commitret@
                    ldd       F.DirOff,u ; load D from F.DirOff,u
                    leax      d,x       ; point X at d,x
                    pshs      x,y       ; preserve x,y on stack
                    leay      F.Entry,u ; point Y at F.Entry,u
                    ldb       #11       ; load B from #11
commitcheck@        lda       ,x+       ; load A from ,x+
                    cmpa      ,y+       ; compare A with ,y+
                    bne       commitgone@ ; branch when unequal or nonzero commitgone@
                    decb                ; decrement accumulator B
                    bne       commitcheck@ ; branch when unequal or nonzero commitcheck@
                    puls      x,y       ; restore x,y from stack
                    bsr       CopyEntryToDisk ; call helper CopyEntryToDisk
                    lbra      WriteData ; continue unconditionally WriteData
commitgone@         puls      x,y       ; restore x,y from stack
                    ldb       #E$Share  ; load B from #E$Share
                    coma                ; complement A and set carry
commitret@          rts                 ; return to caller
CopyEntryToDisk     pshs      y         ; preserve y on stack
                    leay      F.Entry,u ; point Y at F.Entry,u
                    ldb       #32       ; load B from #32
entryout@           lda       ,y+       ; load A from ,y+
                    sta       ,x+       ; save A in ,x+
                    decb                ; decrement accumulator B
                    bne       entryout@ ; branch when unequal or nonzero entryout@
                    puls      y,pc      ; restore y,pc from stack

* The parent has already been resolved and Lookup proved the name absent.
CreateEntry         lbsr      Writable  ; call helper Writable
                    lbcs      createret@ ; branch on carry or error createret@
                    lda       PD.MOD,y  ; load A from PD.MOD,y
                    bita      #DIR.     ; test A against #DIR.
                    beq       createkind@ ; branch when equal or zero createkind@
                    lda       F.Creating,u ; load A from F.Creating,u
                    cmpa      #2        ; compare A with #2
                    lbne      AccessError ; branch when unequal or nonzero AccessError
createkind@         ldd       #F.Start*256+F.Parent ; retain the directory receiving this child
                    lbsr      CopyVal   ; remember parent before AdoptEntry
                    clr       F.WalkValid,u ; clear F.WalkValid,u
                    clra                ; clear accumulator A and carry
                    clrb                ; clear accumulator B and carry
                    std       F.Scan,u  ; save D in F.Scan,u
                    std       F.Scan+2,u ; save D in F.Scan+2,u
createscan@         ldd       #F.Scan*256+F.Offset ; load D from #F.Scan*256+F.Offset
                    lbsr      CopyVal   ; call helper CopyVal
                    lbsr      Locate    ; call helper Locate
                    bcc       createslot@ ; branch with carry clear createslot@
                    cmpb      #E$EOF    ; compare B with #E$EOF
                    lbne      createbad@ ; branch when unequal or nonzero createbad@
* A full directory grows by one zeroed cluster, including a fragmented root.
                    ldd       #F.Walk*256+F.Link ; load D from #F.Walk*256+F.Link
                    lbsr      CopyVal   ; call helper CopyVal
                    lbsr      Allocate  ; call helper Allocate
                    lbcs      createret@ ; branch on carry or error createret@
                    ldd       #F.New*256+F.Value ; load D from #F.New*256+F.Value
                    lbsr      CopyVal   ; call helper CopyVal
                    ldd       #F.Link*256+F.Cluster ; load D from #F.Link*256+F.Cluster
                    lbsr      CopyVal   ; call helper CopyVal
                    lbsr      LinkNew   ; call helper LinkNew
                    lbcs      createret@ ; branch on carry or error createret@
                    bra       createscan@ ; continue from the cached former tail
createslot@         lda       ,x        ; load A from ,x
                    beq       createfree@ ; branch when equal or zero createfree@
                    cmpa      #$E5      ; compare A with #$E5
                    beq       createfree@ ; branch when equal or zero createfree@
                    lbsr      ScanNext  ; call helper ScanNext
                    lbcs      createret@ ; branch on carry or error createret@
                    bra       createscan@ ; continue unconditionally createscan@
createfree@         sta       F.Zero,u             zero means preserve end marker
                    lbsr      EntryLocation ; call helper EntryLocation
                    pshs      x         ; preserve x on stack
                    leax      F.Entry,u ; point X at F.Entry,u
                    ldb       #32       ; load B from #32
createzero@         clr       ,x+       ; clear ,x+
                    decb                ; decrement accumulator B
                    bne       createzero@ ; branch when unequal or nonzero createzero@
                    pshs      y         ; preserve y on stack
                    leax      F.Name,u  ; point X at F.Name,u
                    leay      F.Entry,u ; point Y at F.Entry,u
                    ldb       #11       ; load B from #11
                    lbsr      CopyBytes ; call helper CopyBytes
                    puls      y         ; restore y from stack
                    lda       #$20      ; load A from #$20
                    ldb       F.Creating,u ; load B from F.Creating,u
                    cmpb      #2        ; compare B with #2
                    bne       createattr@ ; branch when unequal or nonzero createattr@
                    lda       #$10      ; load A from #$10
createattr@         sta       F.Entry+11,u ; save A in F.Entry+11,u
                    lbsr      Stamp     ; call helper Stamp
                    ldd       F.Entry+24,u ; load D from F.Entry+24,u
                    std       F.Entry+16,u ; save D in F.Entry+16,u
                    std       F.Entry+18,u ; save D in F.Entry+18,u
                    ldd       F.Entry+22,u ; load D from F.Entry+22,u
                    std       F.Entry+14,u ; save D in F.Entry+14,u
                    puls      x         ; restore x from stack
                    lda       F.Creating,u ; load A from F.Creating,u
                    cmpa      #2        ; compare A with #2
                    bne       createpublish@ ; branch when unequal or nonzero createpublish@
                    lbsr      NewDirectory ; call helper NewDirectory
                    bcs       createret@ ; branch on carry or error createret@
createpublish@      lbsr      CopyEntryToDisk ; call helper CopyEntryToDisk
                    lbsr      WriteData ; call helper WriteData
                    bcs       createret@ ; branch on carry or error createret@
                    tst       F.Zero,u  ; test F.Zero,u
                    bne       createdone@ ; branch when unequal or nonzero createdone@
                    lbsr      ScanNext  ; call helper ScanNext
                    bcs       createret@ ; branch on carry or error createret@
                    ldd       #F.Scan*256+F.Offset ; load D from #F.Scan*256+F.Offset
                    lbsr      CopyVal   ; call helper CopyVal
                    lbsr      Locate    ; call helper Locate
                    bcc       createend@ ; branch with carry clear createend@
                    cmpb      #E$EOF    ; compare B with #E$EOF
                    bne       createbad@ ; branch when unequal or nonzero createbad@
                    bra       createdone@ ; continue unconditionally createdone@
createend@          clr       ,x        ; clear ,x
                    lbsr      WriteData ; call helper WriteData
                    bcs       createret@ ; branch on carry or error createret@
createdone@         clr       F.Creating,u ; clear F.Creating,u
                    clr       F.HasLFN,u ; clear F.HasLFN,u
                    leax      F.Entry,u ; point X at F.Entry,u
                    lbsr      AdoptEntry ; call helper AdoptEntry
                    bcs       createret@ ; branch on carry or error createret@
                    lda       #F.Parent-128 ; containing directory identity
                    lbsr      LoadField ; select the parent timestamp
                    lbsr      TouchDirectory ; update parent after successful publication
                    bcs       createret@ ; propagate parent metadata errors
                    lbsr      Flush     ; call helper Flush
createret@          rts                 ; return to caller
createbad@          coma                ; complement A and set carry
                    rts                 ; return to caller

* Locate a write position, allocating/linking a zeroed cluster as necessary.
EnsureCluster       ldd       F.Start,u ; load D from F.Start,u
                    bne       ensurelocate@ ; branch when unequal or nonzero ensurelocate@
                    ldd       F.Start+2,u ; load D from F.Start+2,u
                    bne       ensurelocate@ ; branch when unequal or nonzero ensurelocate@
                    lbsr      Allocate  ; call helper Allocate
                    bcs       ensureret@ ; branch on carry or error ensureret@
                    lbsr      SaveIdentity ; preserve empty-file identity
                    ldd       #F.New*256+F.Start ; load D from #F.New*256+F.Start
                    lbsr      CopyVal   ; call helper CopyVal
                    lbsr      UpdateEntry ; call helper UpdateEntry
                    bcs       ensureundo@ ; repair publication before reclaiming
                    clr       F.WalkValid,u ; clear F.WalkValid,u
ensurelocate@       lbsr      Locate    ; call helper Locate
                    bcc       ensureret@ ; branch with carry clear ensureret@
                    cmpb      #E$EOF    ; compare B with #E$EOF
                    bne       ensurebad@ ; branch when unequal or nonzero ensurebad@
                    ldd       #F.Walk*256+F.Link ; load D from #F.Walk*256+F.Link
                    lbsr      CopyVal   ; call helper CopyVal
                    lbsr      Allocate  ; call helper Allocate
                    bcs       ensureret@ ; branch on carry or error ensureret@
                    ldd       #F.New*256+F.Value ; load D from #F.New*256+F.Value
                    lbsr      CopyVal   ; call helper CopyVal
                    ldd       #F.Link*256+F.Cluster ; load D from #F.Link*256+F.Cluster
                    lbsr      CopyVal   ; call helper CopyVal
                    lbsr      LinkNew   ; call helper LinkNew
                    bcs       ensureret@ ; branch on carry or error ensureret@
                    bra       ensurelocate@ ; advance from cached former tail
ensureundo@         pshs      b,cc      ; preserve publication failure
                    lbsr      RestoreIdentity ; restore empty-file identity
                    lbsr      CommitEntry ; undo a possible partial directory write
                    bcs       ensurefailed@ ; retain cluster if rollback fails
                    lbsr      ReclaimNew ; cluster is now unreachable
ensurefailed@       puls      b,cc      ; report original error
                    rts                 ; return
ensurebad@          coma                ; complement A and set carry
ensureret@          rts                 ; return to caller

WriteImpl           clra                ; clear accumulator A and carry
                    bra       WriteCommon ; continue unconditionally WriteCommon
WriteLnImpl         lda       #1        ; load A from #1
WriteCommon         pshs      x,y,u     ; preserve x,y,u on stack
                    tfr       u,x       ; transfer registers u,x
                    ldu       PD.BUF,y  ; load U from PD.BUF,y
                    stx       F.Regs,u  ; save X in F.Regs,u
                    sta       F.Line,u  ; save A in F.Line,u
                    clr       F.Stop,u  ; clear F.Stop,u
                    clr       F.Zero,u  ; clear F.Zero,u
                    ldd       R$Y,x     ; load D from R$Y,x
                    std       F.Remain,u ; save D in F.Remain,u
                    ldd       R$X,x     ; load D from R$X,x
                    std       F.Dest,u  ; save D in F.Dest,u
                    clra                ; clear accumulator A and carry
                    clrb                ; clear accumulator B and carry
                    std       F.Actual,u ; save D in F.Actual,u
                    std       R$Y,x     ; save D in R$Y,x
                    lda       PD.MOD,y  ; load A from PD.MOD,y
                    bita      #WRITE.   ; test A against #WRITE.
                    beq       writemode@ ; branch when equal or zero writemode@
                    lbsr      CanWriteFile ; call helper CanWriteFile
                    bcs       writereturn@ ; branch on carry or error writereturn@
                    ldd       F.Remain,u ; load D from F.Remain,u
                    beq       writesuccess@ ; branch when equal or zero writesuccess@
                    ldd       F.Pos+2,u ; load D from F.Pos+2,u
                    addd      F.Remain,u ; add to D: F.Remain,u
                    ldd       F.Pos,u   ; load D from F.Pos,u
                    adcb      #0        ; add to B with carry: #0
                    adca      #0        ; add to A with carry: #0
                    bcs       writeoverflow@ ; branch on carry or error writeoverflow@
                    ldd       #F.Pos*256+F.GapEnd ; load D from #F.Pos*256+F.GapEnd
                    lbsr      CopyVal   ; call helper CopyVal
                    bsr       FillGap   ; call helper FillGap
                    bcs       writereturn@ ; branch on carry or error writereturn@
writeloop@          ldd       F.Remain,u ; load D from F.Remain,u
                    beq       writesuccess@ ; branch when equal or zero writesuccess@
                    bsr       ChunkSpace ; call helper ChunkSpace
                    cmpd      F.Remain,u ; compare D with F.Remain,u
                    bls       writecount@ ; branch when unsigned lower or equal writecount@
                    ldd       F.Remain,u ; load D from F.Remain,u
writecount@         std       F.Move,u  ; save D in F.Move,u
                    lbsr      PutChunk  ; call helper PutChunk
                    bcs       writereturn@ ; branch on carry or error writereturn@
                    ldd       F.Move,u  ; load D from F.Move,u
                    addd      F.Actual,u ; add to D: F.Actual,u
                    std       F.Actual,u ; save D in F.Actual,u
                    ldd       F.Remain,u ; load D from F.Remain,u
                    subd      F.Move,u  ; subtract from D: F.Move,u
                    std       F.Remain,u ; save D in F.Remain,u
                    ldd       F.Dest,u  ; load D from F.Dest,u
                    addd      F.Move,u  ; add to D: F.Move,u
                    std       F.Dest,u  ; save D in F.Dest,u
                    tst       F.Stop,u  ; test F.Stop,u
                    beq       writeloop@ ; branch when equal or zero writeloop@
writesuccess@       lbsr      Flush     ; call helper Flush
writereturn@        lbra      ReadReturn ; continue unconditionally ReadReturn
writeoverflow@      ldb       #E$BTyp   ; load B from #E$BTyp
                    coma                ; complement A and set carry
                    bra       writereturn@ ; continue unconditionally writereturn@
writemode@          ldb       #E$BMode  ; load B from #E$BMode
                    coma                ; complement A and set carry
                    bra       writereturn@ ; continue unconditionally writereturn@
ChunkSpace          ldd       F.Pos+2,u ; load D from F.Pos+2,u
                    anda      #1        ; mask A with #1
                    pshs      d         ; preserve d on stack
                    ldd       #512      ; load D from #512
                    subd      ,s++      ; subtract from D: ,s++
                    rts                 ; return to caller

* Fill a seek/resize gap with zeros; do not expose stale disk bytes.
FillGap             lda       #F.GapEnd-128 ; load A from #F.GapEnd-128
                    lbsr      LoadField ; call helper LoadField
                    leax      F.Size,u  ; point X at F.Size,u
                    lbsr      CompareVal ; call helper CompareVal
                    bls       gapok@    ; branch when unsigned lower or equal gapok@
                    ldd       #F.Size*256+F.Pos ; load D from #F.Size*256+F.Pos
                    lbsr      CopyVal   ; call helper CopyVal
                    inc       F.Zero,u  ; increment F.Zero,u
gaploop@            lda       #F.GapEnd-128 ; load A from #F.GapEnd-128
                    lbsr      LoadField ; call helper LoadField
                    leax      F.Pos,u   ; point X at F.Pos,u
                    lbsr      CompareVal ; call helper CompareVal
                    beq       gapdone@  ; branch when equal or zero gapdone@
                    lda       #F.Wanted-128 ; load A from #F.Wanted-128
                    lbsr      StoreField ; call helper StoreField
                    leax      F.Pos,u   ; point X at F.Pos,u
                    lbsr      LoadVal   ; call helper LoadVal
                    leax      F.Wanted,u ; point X at F.Wanted,u
                    lbsr      SubVal    ; call helper SubVal
                    bsr       ChunkSpace ; call helper ChunkSpace
                    std       F.Move,u  ; save D in F.Move,u
                    ldd       F.Wanted,u ; load D from F.Wanted,u
                    bne       gapchunk@ ; branch when unequal or nonzero gapchunk@
                    ldd       F.Wanted+2,u ; load D from F.Wanted+2,u
                    cmpd      F.Move,u  ; compare D with F.Move,u
                    bhs       gapchunk@ ; branch when unsigned higher or equal gapchunk@
                    std       F.Move,u  ; save D in F.Move,u
gapchunk@           bsr       PutChunk  ; call helper PutChunk
                    bcc       gaploop@  ; branch with carry clear gaploop@
                    pshs      cc        ; preserve cc on stack
                    clr       F.Zero,u  ; clear F.Zero,u
                    puls      cc,pc     ; restore cc,pc from stack
gapdone@            clr       F.Zero,u  ; clear F.Zero,u
gapok@              clrb                ; clear accumulator B and carry
                    rts                 ; return to caller

PutChunk            ldd       #F.Pos*256+F.Offset ; load D from #F.Pos*256+F.Offset
                    lbsr      CopyVal   ; call helper CopyVal
                    lbsr      EnsureCluster ; call helper EnsureCluster
                    bcs       putret@   ; branch on carry or error putret@
                    tst       F.Zero,u  ; test F.Zero,u
                    beq       putuser@  ; branch when equal or zero putuser@
                    ldd       F.Move,u  ; load D from F.Move,u
putzero@            clr       ,x+       ; clear ,x+
                    subd      #1        ; subtract from D: #1
                    bne       putzero@  ; branch when unequal or nonzero putzero@
                    bra       putdisk@  ; continue unconditionally putdisk@
putuser@            lbsr      WriteLineCount ; call helper WriteLineCount
                    lbsr      MoveIn    ; call helper MoveIn
                    bcs       putret@   ; branch on carry or error putret@
putdisk@            lbsr      WriteData ; call helper WriteData
                    bcs       putret@   ; branch on carry or error putret@
                    ldd       F.Move,u  ; load D from F.Move,u
                    lbsr      AddPosition ; call helper AddPosition
                    lbcs      BadMedia  ; branch on carry or error BadMedia
                    leax      F.Pos,u   ; point X at F.Pos,u
                    lbsr      LoadVal   ; call helper LoadVal
                    leax      F.Size,u  ; point X at F.Size,u
                    lbsr      CompareVal ; call helper CompareVal
                    bls       putmetadata@ ; branch when unsigned lower or equal putmetadata@
                    lbsr      StoreVal  ; call helper StoreVal
putmetadata@        lbsr      UpdateEntry ; call helper UpdateEntry
putret@             rts                 ; return to caller

DeleteImpl          pshs      x,y,u     ; preserve x,y,u on stack
                    lda       PD.MOD,y  ; load A from PD.MOD,y
                    pshs      a         ; preserve a on stack
                    anda      #EXEC.    ; retain I$DeletX directory selection
                    ora       #READ.    ; resolve with read access
                    sta       PD.MOD,y  ; temporary open mode
                    lda       #3        ; load A from #3
                    lbsr      OpenBegin ; call helper OpenBegin
                    bcs       deletereturn@ ; branch on carry or error deletereturn@
                    ldu       PD.BUF,y  ; load U from PD.BUF,y
                    lda       F.Entry+11,u ; load A from F.Entry+11,u
                    bita      #$10      ; test A against #$10
                    beq       deletefile@ ; branch when equal or zero deletefile@
                    lbsr      RemovableDirectory ; call helper RemovableDirectory
                    bra       deletechecked@ ; continue unconditionally deletechecked@
deletefile@         lbsr      CanWriteFile ; call helper CanWriteFile
deletechecked@      bcs       deletefree@ ; branch on carry or error deletefree@
                    lda       #WRITE.   ; load A from #WRITE.
                    lbsr      CheckSharing ; call helper CheckSharing
                    bcs       deletefree@ ; branch on carry or error deletefree@
                    lbsr      ValidateChain ; call helper ValidateChain
                    bcs       deletefree@ ; branch on carry or error deletefree@
                    ldd       #F.Start*256+F.Saved ; load D from #F.Start*256+F.Saved
                    lbsr      CopyVal   ; call helper CopyVal
                    lda       #F.DirLBA-128 ; load A from #F.DirLBA-128
                    lbsr      LoadField ; call helper LoadField
                    lbsr      ReadData  ; call helper ReadData
                    bcs       deletefree@ ; branch on carry or error deletefree@
                    ldd       F.DirOff,u ; load D from F.DirOff,u
                    leax      d,x       ; point X at d,x
                    lda       #$E5      ; load A from #$E5
                    sta       ,x        ; save A in ,x
                    lbsr      WriteData ; call helper WriteData
                    bcs       deletefree@ ; branch on carry or error deletefree@
                    lbsr      FreeChain ; call helper FreeChain
                    bcs       deletefree@ ; branch on carry or error deletefree@
                    lda       #F.Parent-128 ; parent retained by Lookup
                    lbsr      LoadField ; select containing directory
                    lbsr      TouchDirectory ; update parent after successful deletion
                    bcs       deletefree@ ; propagate parent metadata errors
                    lbsr      Flush     ; call helper Flush
deletefree@         pshs      b,cc      ; preserve b,cc on stack
                    lbsr      FreePath  ; call helper FreePath
                    puls      b,cc      ; restore b,cc from stack
deletereturn@       puls      a         ; restore a from stack
                    sta       PD.MOD,y  ; save A in PD.MOD,y
                    puls      x,y,u,pc  ; restore x,y,u,pc from stack

SetStatImpl         pshs      x,y,u     ; preserve x,y,u on stack
                    tfr       u,x       ; transfer registers u,x
                    ldu       PD.BUF,y  ; load U from PD.BUF,y
                    stx       F.Regs,u  ; save X in F.Regs,u
                    ldb       R$B,x     ; requested status service
                    cmpb      #SS.Opt   ; ioman owns the path option copy
                    beq       setopt@   ; no media write is required
                    lbsr      Writable  ; remaining services mutate media
                    bcs       SetStatReturn ; branch on carry or error SetStatReturn
                    ldx       F.Regs,u  ; load X from F.Regs,u
                    ldb       R$B,x     ; load B from R$B,x
                    cmpb      #SS.Rename ; compare B with #SS.Rename
                    lbeq      RenameEntry ; branch when equal or zero RenameEntry
                    cmpb      #SS.Size  ; compare B with #SS.Size
                    beq       SetSize   ; branch when equal or zero SetSize
                    ldb       #E$UnkSvc            PCF does not promise RBF permissions/FD writes
                    coma                ; complement A and set carry
                    bra       SetStatReturn ; retain unknown-service error
setopt@             clrb                ; accept path option update
SetStatReturn       puls      x,y,u,pc  ; restore x,y,u,pc from stack
SetSize             lda       PD.MOD,y  ; load A from PD.MOD,y
                    bita      #WRITE.   ; test A against #WRITE.
                    lbeq      setmode@  ; branch when equal or zero setmode@
                    lbsr      CanWriteFile ; call helper CanWriteFile
                    bcs       SetStatReturn ; branch on carry or error SetStatReturn
                    ldd       #F.Pos*256+F.SavedPos ; load D from #F.Pos*256+F.SavedPos
                    lbsr      CopyVal   ; call helper CopyVal
                    ldx       F.Regs,u  ; load X from F.Regs,u
                    ldd       R$X,x     ; load D from R$X,x
                    std       F.GapEnd,u ; save D in F.GapEnd,u
                    ldd       R$U,x     ; load D from R$U,x
                    std       F.GapEnd+2,u ; save D in F.GapEnd+2,u
                    lda       #F.GapEnd-128 ; load A from #F.GapEnd-128
                    lbsr      LoadField ; call helper LoadField
                    leax      F.Size,u  ; point X at F.Size,u
                    lbsr      CompareVal ; call helper CompareVal
                    lbeq      sizerestore@ ; branch when equal or zero sizerestore@
                    blo       sizeshrink@ ; branch when unsigned lower sizeshrink@
                    lbsr      FillGap   ; call helper FillGap
                    lbra      sizerestore@ ; continue unconditionally sizerestore@
sizeshrink@         lbsr      SaveIdentity ; snapshot before destructive changes
                    lbsr      ValidateChain ; call helper ValidateChain
                    bcs       sizerestore@ ; branch on carry or error sizerestore@
                    lda       #F.GapEnd-128 ; load A from #F.GapEnd-128
                    lbsr      LoadField ; call helper LoadField
                    ldd       F.Val,u   ; load D from F.Val,u
                    bne       sizepartial@ ; branch when unequal or nonzero sizepartial@
                    ldd       F.Val+2,u ; load D from F.Val+2,u
                    bne       sizepartial@ ; branch when unequal or nonzero sizepartial@
                    ldd       #F.Start*256+F.Saved ; load D from #F.Start*256+F.Saved
                    lbsr      CopyVal   ; call helper CopyVal
                    clra                ; clear accumulator A and carry
                    clrb                ; clear accumulator B and carry
                    std       F.Start,u ; save D in F.Start,u
                    std       F.Start+2,u ; save D in F.Start+2,u
                    bra       sizepublish@ ; continue unconditionally sizepublish@
sizepartial@        lbsr      DecVal    ; call helper DecVal
                    lda       #F.Offset-128 ; load A from #F.Offset-128
                    lbsr      StoreField ; call helper StoreField
                    lbsr      Locate    ; call helper Locate
                    bcs       sizerestore@ ; branch on carry or error sizerestore@
                    ldd       #F.Walk*256+F.New ; load D from #F.Walk*256+F.New
                    lbsr      CopyVal   ; call helper CopyVal
                    lda       #F.Cluster-128 ; load A from #F.Cluster-128
                    lbsr      StoreField ; call helper StoreField
                    lbsr      NextCluster ; call helper NextCluster
                    bcc       sizetail@ ; branch with carry clear sizetail@
                    cmpb      #E$EOF    ; compare B with #E$EOF
                    bne       sizebad@  ; branch when unequal or nonzero sizebad@
                    clra                ; clear accumulator A and carry
                    clrb                ; clear accumulator B and carry
                    std       F.Val,u   ; save D in F.Val,u
                    std       F.Val+2,u ; save D in F.Val+2,u
sizetail@           lda       #F.Saved-128 ; load A from #F.Saved-128
                    lbsr      StoreField ; call helper StoreField
sizepublish@        ldd       #F.GapEnd*256+F.Size ; load D from #F.GapEnd*256+F.Size
                    lbsr      CopyVal   ; call helper CopyVal
                    lbsr      UpdateEntry ; call helper UpdateEntry
                    bcs       sizeundo@ ; restore disk and memory before returning
                    ldd       F.Start,u ; load D from F.Start,u
                    bne       sizedetach@ ; branch when unequal or nonzero sizedetach@
                    ldd       F.Start+2,u ; load D from F.Start+2,u
                    beq       sizefree@ ; branch when equal or zero sizefree@
sizedetach@         ldd       #F.New*256+F.Cluster ; load D from #F.New*256+F.Cluster
                    lbsr      CopyVal   ; call helper CopyVal
                    ldd       #$0FFF    ; load D from #$0FFF
                    std       F.Value,u ; save D in F.Value,u
                    ldd       #$FFFF    ; load D from #$FFFF
                    std       F.Value+2,u ; save D in F.Value+2,u
                    lbsr      SetFat    ; call helper SetFat
                    bcs       sizerestore@ ; branch on carry or error sizerestore@
sizefree@           lbsr      FreeChain ; call helper FreeChain
sizerestore@        pshs      b,cc      ; preserve b,cc on stack
                    ldd       #F.SavedPos*256+F.Pos ; load D from #F.SavedPos*256+F.Pos
                    lbsr      CopyVal   ; call helper CopyVal
                    clr       F.WalkValid,u ; clear F.WalkValid,u
                    puls      b,cc      ; restore b,cc from stack
                    lbcs      SetStatReturn ; branch on carry or error SetStatReturn
                    lbsr      Flush     ; call helper Flush
                    lbra      SetStatReturn ; continue unconditionally SetStatReturn
sizeundo@           pshs      b,cc      ; retain the publication error
                    lbsr      RestoreIdentity ; restore first cluster, size and metadata
                    lbsr      CommitEntry ; repair a possible partial sector write
                    puls      b,cc      ; report original failure
                    lbra      sizerestore@ ; restore position on every path
sizebad@            coma                ; complement A and set carry
                    lbra      sizerestore@ ; continue unconditionally sizerestore@
setmode@            ldb       #E$BMode  ; load B from #E$BMode
                    coma                ; complement A and set carry
                    lbra      SetStatReturn ; continue unconditionally SetStatReturn

* Determine WriteLn's actual transfer length before modifying the data cache.
WriteLineCount      tst       F.Line,u  ; test F.Line,u
                    beq       linecountok@ ; branch when equal or zero linecountok@
                    pshs      x,y       ; preserve x,y on stack
                    ldx       F.Dest,u  ; load X from F.Dest,u
                    ldd       F.Move,u  ; load D from F.Move,u
                    pshs      d         ; preserve d on stack
linecountloop@      equ       *         ; define constant or offset
                  IFGT    Level-1 ; conditional assembly
                    ldy       <D.Proc   ; load Y from <D.Proc
                    ldb       P$Task,y  ; load B from P$Task,y
                    os9       F$LDABX   ; invoke OS-9 F$LDABX service
                  ELSE            ; conditional assembly
                    lda       ,x        ; load A from ,x
                  ENDC            ; conditional assembly
                    leax      1,x       ; point X at 1,x
                    cmpa      #C$CR     ; compare A with #C$CR
                    beq       linecountfound@ ; branch when equal or zero linecountfound@
                    ldd       ,s        ; load D from ,s
                    subd      #1        ; subtract from D: #1
                    std       ,s        ; save D in ,s
                    bne       linecountloop@ ; branch when unequal or nonzero linecountloop@
                    leas      2,s       ; point S at 2,s
                    puls      x,y       ; restore x,y from stack
                    bra       linecountok@ ; continue unconditionally linecountok@
linecountfound@     ldd       F.Move,u  ; load D from F.Move,u
                    subd      ,s++      ; subtract from D: ,s++
                    addd      #1        ; add to D: #1
                    std       F.Move,u  ; save D in F.Move,u
                    inc       F.Stop,u  ; increment F.Stop,u
                    puls      x,y       ; restore x,y from stack
linecountok@        clrb                ; clear accumulator B and carry
                    rts                 ; return to caller


* I$MakDir has no persistent open path. Reuse create resolution with a private
* kind flag, then release the temporary directory path on success or failure.
MkDirImpl           pshs      x,y,u     ; preserve x,y,u on stack
                    lda       PD.MOD,y  ; load A from PD.MOD,y
                    pshs      a         ; preserve a on stack
                    lda       #DIR.+READ. ; load A from #DIR.+READ.
                    sta       PD.MOD,y  ; save A in PD.MOD,y
                    lda       #2        ; load A from #2
                    lbsr      OpenBegin ; call helper OpenBegin
                    bcs       mkdirreturn@ ; branch on carry or error mkdirreturn@
                    lbsr      FreePath  ; call helper FreePath
mkdirreturn@        puls      a         ; restore a from stack
                    sta       PD.MOD,y  ; save A in PD.MOD,y
                    puls      x,y,u,pc  ; restore x,y,u,pc from stack

* Initialize the child fully before publishing its parent's entry. F.Start is
* still the parent cluster. Return X pointing at the reloaded parent slot.
NewDirectory        lbsr      Allocate  ; call helper Allocate
                    bcs       newdirret@ ; branch on carry or error newdirret@
                    ldd       #F.New*256+F.Child ; load D from #F.New*256+F.Child
                    lbsr      CopyVal   ; call helper CopyVal
                    lbsr      ClusterBase ; call helper ClusterBase
                    bcs       newdirundo@ ; branch on carry or error newdirundo@
                    lbsr      ReadData  ; call helper ReadData
                    bcs       newdirundo@ ; branch on carry or error newdirundo@
                    lda       #F.Child-128 ; load A from #F.Child-128
                    lbsr      LoadField ; call helper LoadField
                    leax      F.Data,u  ; point X at F.Data,u
                    bsr       DotEntry  ; call helper DotEntry
                    lda       #F.Start-128 ; load A from #F.Start-128
                    lbsr      LoadField ; call helper LoadField
                    leax      F.Root,u  ; point X at F.Root,u
                    lbsr      CompareVal ; call helper CompareVal
                    bne       newdirparent@ ; branch when unequal or nonzero newdirparent@
* FAT32 encodes a root parent as cluster zero in '..'.
                    clra                ; clear accumulator A and carry
                    clrb                ; clear accumulator B and carry
                    std       F.Val,u   ; save D in F.Val,u
                    std       F.Val+2,u ; save D in F.Val+2,u
newdirparent@       leax      F.Data+32,u ; point X at F.Data+32,u
                    bsr       DotEntry  ; call helper DotEntry
                    lda       #'.       ; load A from #'.
                    sta       F.Data+33,u ; save A in F.Data+33,u
                    lbsr      WriteData ; call helper WriteData
                    bcs       newdirundo@ ; branch on carry or error newdirundo@
                    lda       #F.Child-128 ; load A from #F.Child-128
                    lbsr      LoadField ; call helper LoadField
                    leax      F.Entry,u ; point X at F.Entry,u
                    bsr       EntryCluster ; call helper EntryCluster
                    lda       #F.DirLBA-128 ; load A from #F.DirLBA-128
                    lbsr      LoadField ; call helper LoadField
                    lbsr      ReadData  ; call helper ReadData
                    bcs       newdirundo@ ; branch on carry or error newdirundo@
                    ldd       F.DirOff,u ; load D from F.DirOff,u
                    leax      d,x       ; point X at d,x
                    clrb                ; clear accumulator B and carry
newdirret@          rts                 ; return to caller
* The child is not reachable yet. Best-effort reclaim preserves the original
* error; an additional media error during rollback still requires fsck.
newdirundo@         pshs      b,cc      ; preserve b,cc on stack
                    ldd       #F.Child*256+F.Saved ; load D from #F.Child*256+F.Saved
                    lbsr      CopyVal   ; call helper CopyVal
                    lbsr      FreeChain ; call helper FreeChain
                    lbsr      Flush     ; call helper Flush
                    puls      b,cc,pc   ; restore b,cc,pc from stack
DotEntry            pshs      x         ; preserve x on stack
                    lbsr      CopyEntryToDisk ; call helper CopyEntryToDisk
                    puls      x         ; restore x from stack
                    pshs      x         ; preserve x on stack
                    lda       #C$SPAC   ; load A from #C$SPAC
                    ldb       #11       ; load B from #11
dotname@            sta       ,x+       ; save A in ,x+
                    decb                ; decrement accumulator B
                    bne       dotname@  ; branch when unequal or nonzero dotname@
                    puls      x         ; restore x from stack
                    lda       #'.       ; load A from #'.
                    sta       ,x        ; save A in ,x
EntryCluster        lda       F.Val+1,u ; load A from F.Val+1,u
                    sta       20,x      ; save A in 20,x
                    lda       F.Val,u   ; load A from F.Val,u
                    sta       21,x      ; save A in 21,x
                    lda       F.Val+3,u ; load A from F.Val+3,u
                    sta       26,x      ; save A in 26,x
                    lda       F.Val+2,u ; load A from F.Val+2,u
                    sta       27,x      ; save A in 27,x
                    rts                 ; return to caller


* Reject the volume root, dot aliases, readonly/LFN entries, open directories,
* and any process's data or execution directory before changing the medium.
RemovableDirectory  lbsr      Writable  ; call helper Writable
                    lbcs      rmdirret@ ; branch on carry or error rmdirret@
                    lda       F.Entry+11,u ; load A from F.Entry+11,u
                    bita      #1        ; test A against #1
                    lbne      AccessError ; branch when unequal or nonzero AccessError
                    tst       F.HasLFN,u ; test F.HasLFN,u
                    lbne      AccessError ; branch when unequal or nonzero AccessError
                    lda       F.Name,u  ; load A from F.Name,u
                    cmpa      #'.       ; compare A with #'.
                    lbeq      AccessError ; branch when equal or zero AccessError
                    lda       #F.Start-128 ; load A from #F.Start-128
                    lbsr      LoadField ; call helper LoadField
                    leax      F.Root,u  ; point X at F.Root,u
                    lbsr      CompareVal ; call helper CompareVal
                    lbeq      AccessError ; branch when equal or zero AccessError
                    bsr       DirectoryBusy ; call helper DirectoryBusy
                    bcs       rmdirret@ ; branch on carry or error rmdirret@
                    clr       F.WalkValid,u ; clear F.WalkValid,u
                    clra                ; clear accumulator A and carry
                    clrb                ; clear accumulator B and carry
                    std       F.Scan,u  ; save D in F.Scan,u
                    std       F.Scan+2,u ; save D in F.Scan+2,u
emptyloop@          ldd       #F.Scan*256+F.Offset ; load D from #F.Scan*256+F.Offset
                    lbsr      CopyVal   ; call helper CopyVal
                    lbsr      Locate    ; call helper Locate
                    bcc       emptyslot@ ; branch with carry clear emptyslot@
                    cmpb      #E$EOF    ; compare B with #E$EOF
                    beq       emptyok@  ; branch when equal or zero emptyok@
                    coma                ; complement A and set carry
                    bra       rmdirret@ ; continue unconditionally rmdirret@
emptyslot@          lda       ,x        ; load A from ,x
                    beq       emptyok@  ; branch when equal or zero emptyok@
                    cmpa      #$E5      ; compare A with #$E5
                    beq       emptynext@ ; branch when equal or zero emptynext@
* Only exact '.' and '..' records in their standard slots may be ignored.
                    cmpa      #'.       ; compare A with #'.
                    bne       notempty@ ; branch when unequal or nonzero notempty@
                    lda       11,x      ; load A from 11,x
                    bita      #$10      ; test A against #$10
                    beq       notempty@ ; branch when equal or zero notempty@
                    ldd       F.Scan,u  ; load D from F.Scan,u
                    bne       notempty@ ; branch when unequal or nonzero notempty@
                    ldd       F.Scan+2,u ; load D from F.Scan+2,u
                    cmpd      #32       ; compare D with #32
                    bhi       notempty@ ; branch when unsigned higher notempty@
                    leax      1,x       ; point X at 1,x
                    ldb       #10       ; load B from #10
                    tst       F.Scan+3,u ; test F.Scan+3,u
                    beq       dotspaces@ ; branch when equal or zero dotspaces@
                    lda       ,x+       ; load A from ,x+
                    cmpa      #'.       ; compare A with #'.
                    bne       notempty@ ; branch when unequal or nonzero notempty@
                    decb                ; decrement accumulator B
dotspaces@          lda       ,x+       ; load A from ,x+
                    cmpa      #C$SPAC   ; compare A with #C$SPAC
                    bne       notempty@ ; branch when unequal or nonzero notempty@
                    decb                ; decrement accumulator B
                    bne       dotspaces@ ; branch when unequal or nonzero dotspaces@
emptynext@          lbsr      ScanNext  ; call helper ScanNext
                    bcs       rmdirret@ ; branch on carry or error rmdirret@
                    bra       emptyloop@ ; continue unconditionally emptyloop@
notempty@           ldb       #E$DNE    ; load B from #E$DNE
                    coma                ; complement A and set carry
rmdirret@           rts                 ; return to caller
emptyok@            clrb                ; clear accumulator B and carry
                    rts                 ; return to caller

DirectoryBusy       pshs      x,y       ; preserve x,y on stack
                    ldx       PD.DEV,y  ; load X from PD.DEV,y
                    ldx       V$STAT,x  ; load X from V$STAT,x
                    ldx       BV.FMPaths,x ; load X from BV.FMPaths,x
busyopen@           cmpx      #0        ; compare X with #0
                    beq       busyprocess@ ; branch when equal or zero busyprocess@
                    pshs      u         ; preserve u on stack
                    cmpx      ,s++      ; compare X with ,s++
                    beq       busynext@ ; branch when equal or zero busynext@
                    ldd       F.Base,u  ; load D from F.Base,u
                    cmpd      F.Base,x  ; compare D with F.Base,x
                    bne       busynext@ ; branch when unequal or nonzero busynext@
                    ldd       F.Base+2,u ; load D from F.Base+2,u
                    cmpd      F.Base+2,x ; compare D with F.Base+2,x
                    bne       busynext@ ; branch when unequal or nonzero busynext@
                    ldd       F.Start,u ; load D from F.Start,u
                    cmpd      F.Start,x ; compare D with F.Start,x
                    bne       busynext@ ; branch when unequal or nonzero busynext@
                    ldd       F.Start+2,u ; load D from F.Start+2,u
                    cmpd      F.Start+2,x ; compare D with F.Start+2,x
                    beq       busyerror@ ; branch when equal or zero busyerror@
busynext@           ldx       F.NextPath,x ; load X from F.NextPath,x
                    bra       busyopen@ ; continue unconditionally busyopen@
* Fork inherits these references without opening a path, so scan live process
* descriptors as well as the open-path list. The volume lock excludes ChgDir.
busyprocess@        lda       #1        ; load A from #1
                    pshs      a         ; preserve a on stack
busyid@             lda       ,s        ; load A from ,s
                  IFGT    Level-1 ; conditional assembly
                    os9       F$GProcP  ; invoke OS-9 F$GProcP service
                  ELSE            ; conditional assembly
                    ldx       <D.PrcDBT ; load X from <D.PrcDBT
                    os9       F$Find64  ; invoke OS-9 F$Find64 service
                  ENDC            ; conditional assembly
                    bcs       busyadvance@ ; branch on carry or error busyadvance@
                    lda       P$State,y ; load A from P$State,y
                    bita      #Dead     ; test A against #Dead
                    bne       busyadvance@ ; branch when unequal or nonzero busyadvance@
                    leax      P$DIO,y   ; point X at P$DIO,y
                    bsr       DirectoryRef ; call helper DirectoryRef
                    bcs       busyfound@ ; branch on carry or error busyfound@
                    leax      P$DIO+6,y ; point X at P$DIO+6,y
                    bsr       DirectoryRef ; call helper DirectoryRef
                    bcs       busyfound@ ; branch on carry or error busyfound@
busyadvance@        inc       ,s        ; increment ,s
                    bne       busyid@   ; branch when unequal or nonzero busyid@
                    clrb                ; clear accumulator B and carry
busyfound@          leas      1,s       ; point S at 1,s
                    puls      x,y,pc    ; restore x,y,pc from stack
busyerror@          ldb       #E$Share  ; load B from #E$Share
                    coma                ; complement A and set carry
                    puls      x,y,pc    ; restore x,y,pc from stack
* X points to a six-byte device/cluster reference. Compare physical device
* statics and partition base so /dd and /pc0 aliases cannot bypass protection.
DirectoryRef        pshs      x,y       ; preserve x,y on stack
                    ldd       2,x       ; load D from 2,x
                    cmpd      F.Start,u ; compare D with F.Start,u
                    bne       refok@    ; branch when unequal or nonzero refok@
                    ldd       4,x       ; load D from 4,x
                    cmpd      F.Start+2,u ; compare D with F.Start+2,u
                    bne       refok@    ; branch when unequal or nonzero refok@
                    ldx       ,x        ; load X from ,x
                    beq       refok@    ; branch when equal or zero refok@
                    ldy       F.Owner,u ; load Y from F.Owner,u
                    ldy       PD.DEV,y  ; load Y from PD.DEV,y
                    ldd       V$FMGR,x  ; load D from V$FMGR,x
                    cmpd      V$FMGR,y  ; compare D with V$FMGR,y
                    bne       refok@    ; branch when unequal or nonzero refok@
                    ldd       V$STAT,x  ; load D from V$STAT,x
                    cmpd      V$STAT,y  ; compare D with V$STAT,y
                    bne       refok@    ; branch when unequal or nonzero refok@
                    ldx       V$DESC,x  ; load X from V$DESC,x
                    ldd       FT.Base,x ; load D from FT.Base,x
                    cmpd      F.Base,u  ; compare D with F.Base,u
                    bne       refok@    ; branch when unequal or nonzero refok@
                    ldd       FT.Base+2,x ; load D from FT.Base+2,x
                    cmpd      F.Base+2,u ; compare D with F.Base+2,u
                    bne       refok@    ; branch when unequal or nonzero refok@
                    bra       busyerror@ ; continue unconditionally busyerror@
refok@              clrb                ; clear accumulator B and carry
                    puls      x,y,pc    ; restore x,y,pc from stack

* SS.Rename: two validated 30-byte basenames, on a writable parent directory.
* F.Record stages the parent's identity (40+6 bytes), source location (6),
* and canonical new name (11). F.Pos is never changed. No extra workspace.
RenameEntry         clr       F.Record+63,u ; only a committed rename touches its parent
                    lda       PD.MOD,y  ; load A from PD.MOD,y
                    anda      #DIR.+WRITE. ; mask A with #DIR.+WRITE.
                    cmpa      #DIR.+WRITE. ; compare A with #DIR.+WRITE.
                    lbne      renameaccess@ ; branch when unequal or nonzero renameaccess@
                    lda       F.Entry+11,u ; load A from F.Entry+11,u
                    bita      #$10      ; test A against #$10
                    lbeq      renameaccess@ ; branch when equal or zero renameaccess@
                    bita      #1        ; test A against #1
                    lbne      renameaccess@ ; branch when unequal or nonzero renameaccess@
                    ldd       R$Y,x     ; load D from R$Y,x
                    cmpd      #60       ; compare D with #60
                    lbne      renamebad@ ; branch when unequal or nonzero renamebad@
                    std       F.Move,u  ; save D in F.Move,u
                    ldd       R$X,x     ; load D from R$X,x
                    std       F.Dest,u  ; save D in F.Dest,u
                    leax      F.Path,u  ; point X at F.Path,u
                    lbsr      MoveIn    ; call helper MoveIn
                    lbcs      SetStatReturn ; branch on carry or error SetStatReturn
                    leax      F.Path+30,u ; point X at F.Path+30,u
                    lbsr      RenameName ; call helper RenameName
                    lbcs      SetStatReturn ; branch on carry or error SetStatReturn
                    pshs      y         ; preserve y on stack
                    leax      F.Name,u  ; point X at F.Name,u
                    leay      F.Record+52,u ; point Y at F.Record+52,u
                    ldb       #11       ; load B from #11
                    lbsr      CopyBytes ; call helper CopyBytes
                    puls      y         ; restore y from stack
                    leax      F.Path,u  ; point X at F.Path,u
                    lbsr      RenameName ; call helper RenameName
                    lbcs      SetStatReturn ; branch on carry or error SetStatReturn
* Save parent identity before Lookup adopts the source child.
                    pshs      y         ; preserve y on stack
                    leax      F.Start,u ; point X at F.Start,u
                    leay      F.Record,u ; point Y at F.Record,u
                    ldb       #40       ; load B from #40
                    lbsr      CopyBytes ; call helper CopyBytes
                    leax      F.DirLBA,u ; point X at F.DirLBA,u
                    ldb       #6        ; load B from #6
                    lbsr      CopyBytes ; call helper CopyBytes
                    puls      y         ; restore y from stack
                    lbsr      Lookup    ; call helper Lookup
                    lbcs      renamerestore@ ; branch on carry or error renamerestore@
                    tst       F.HasLFN,u ; test F.HasLFN,u
                    beq       renamebusy@ ; branch when equal or zero renamebusy@
                    ldb       #E$FNA    ; load B from #E$FNA
                    coma                ; complement A and set carry
                    lbra      renamerestore@ ; continue unconditionally renamerestore@
renamebusy@         lda       F.Entry+11,u ; load A from F.Entry+11,u
                    bita      #$10      ; test A against #$10
                    beq       renamefile@ ; branch when equal or zero renamefile@
                    lbsr      DirectoryBusy ; call helper DirectoryBusy
                    bra       renamechecked@ ; continue unconditionally renamechecked@
renamefile@         lda       #WRITE.   ; load A from #WRITE.
                    lbsr      CheckSharing ; call helper CheckSharing
renamechecked@      lbcs      renamerestore@ ; branch on carry or error renamerestore@
                    pshs      y         ; preserve y on stack
                    leax      F.DirLBA,u ; point X at F.DirLBA,u
                    leay      F.Record+46,u ; point Y at F.Record+46,u
                    ldb       #6        ; load B from #6
                    lbsr      CopyBytes ; call helper CopyBytes
                    leax      F.Record+52,u ; point X at F.Record+52,u
                    leay      F.Name,u  ; point Y at F.Name,u
                    ldb       #11       ; load B from #11
                    lbsr      CopyBytes ; call helper CopyBytes
                    puls      y         ; restore y from stack
* Search the same parent for collisions. Its cluster, not the child, is used.
                    leax      F.Record,u ; point X at F.Record,u
                    lbsr      LoadVal   ; call helper LoadVal
                    lda       #F.Start-128 ; load A from #F.Start-128
                    lbsr      StoreField ; call helper StoreField
                    lbsr      Lookup    ; call helper Lookup
                    bcs       renamemissing@ ; branch on carry or error renamemissing@
* Same canonical alias (including case-only changes) is a successful no-op.
                    pshs      y         ; preserve y on stack
                    leax      F.DirLBA,u ; point X at F.DirLBA,u
                    leay      F.Record+46,u ; point Y at F.Record+46,u
                    ldb       #6        ; load B from #6
renamecompare@      lda       ,x+       ; load A from ,x+
                    cmpa      ,y+       ; compare A with ,y+
                    bne       renameexists@ ; branch when unequal or nonzero renameexists@
                    decb                ; decrement accumulator B
                    bne       renamecompare@ ; branch when unequal or nonzero renamecompare@
                    puls      y         ; restore y from stack
                    clrb                ; clear accumulator B and carry
                    bra       renamerestore@ ; continue unconditionally renamerestore@
renameexists@       puls      y         ; restore y from stack
                    ldb       #E$CEF    ; load B from #E$CEF
                    coma                ; complement A and set carry
                    bra       renamerestore@ ; continue unconditionally renamerestore@
renamemissing@      cmpb      #E$PNNF   ; compare B with #E$PNNF
                    bne       renameerror@ ; branch when unequal or nonzero renameerror@
                    leax      F.Record+46,u ; point X at F.Record+46,u
                    lbsr      LoadVal   ; call helper LoadVal
                    lbsr      ReadData  ; call helper ReadData
                    bcs       renamerestore@ ; branch on carry or error renamerestore@
                    ldd       F.Record+50,u ; load D from F.Record+50,u
                    leax      d,x       ; point X at d,x
                    pshs      y         ; preserve y on stack
                    leay      F.Record+52,u ; point Y at F.Record+52,u
                    ldb       #11       ; load B from #11
renamestore@        lda       ,y+       ; load A from ,y+
                    sta       ,x+       ; save A in ,x+
                    decb                ; decrement accumulator B
                    bne       renamestore@ ; branch when unequal or nonzero renamestore@
* New short names are uppercase; clear NT lowercase flags, preserve metadata.
                    lda       1,x       ; load A from 1,x
                    anda      #$E7      ; mask A with #$E7
                    sta       1,x       ; save A in 1,x
                    puls      y         ; restore y from stack
                    lbsr      WriteData ; call helper WriteData
                    bcs       renamerestore@ ; branch on carry or error renamerestore@
                    inc       F.Record+63,u ; distinguish actual rename from case-only no-op
                    clrb                ; restore parent identity before timestamp update
                    bra       renamerestore@ ; continue unconditionally renamerestore@
renameerror@        coma                ; complement A and set carry
renamerestore@      pshs      b,cc,y    ; preserve b,cc,y on stack
                    leax      F.Record,u ; point X at F.Record,u
                    leay      F.Start,u ; point Y at F.Start,u
                    ldb       #40       ; load B from #40
                    bsr       CopyBytes ; call helper CopyBytes
                    leay      F.DirLBA,u ; point Y at F.DirLBA,u
                    ldb       #6        ; load B from #6
                    bsr       CopyBytes ; call helper CopyBytes
                    clr       F.WalkValid,u ; clear F.WalkValid,u
                    puls      b,cc,y    ; restore b,cc,y from stack
                    lbcs      SetStatReturn ; rejected renames never write parent metadata
                    tst       F.Record+63,u ; case-only rename is a zero-write no-op
                    lbeq      SetStatReturn ; retain no-op behavior
                    lda       #F.Start-128 ; restored parent directory cluster
                    lbsr      LoadField ; select the directory whose entry changed
                    lbsr      TouchDirectory ; stamp the parent and its live path caches
                    lbcs      SetStatReturn ; propagate parent metadata errors
                    lbsr      Flush     ; complete both name and timestamp writes
                    lbra      SetStatReturn ; continue unconditionally SetStatReturn
renameaccess@       ldb       #E$FNA    ; load B from #E$FNA
                    coma                ; complement A and set carry
                    lbra      SetStatReturn ; continue unconditionally SetStatReturn
renamebad@          ldb       #E$BPNam  ; load B from #E$BPNam
                    coma                ; complement A and set carry
                    lbra      SetStatReturn ; continue unconditionally SetStatReturn
RenameName          pshs      x         ; preserve x on stack
                    bsr       RNName    ; call helper RNName
                    puls      x         ; restore x from stack
                    bcs       renamenameret@ ; branch on carry or error renamenameret@
                    stx       F.Cursor,u ; save X in F.Cursor,u
                    lbsr      ParseName ; call helper ParseName
                    bcs       renamenameret@ ; branch on carry or error renamenameret@
                    tst       F.Dots,u  ; test F.Dots,u
                    lbne      PathError ; branch when unequal or nonzero PathError
                    clrb                ; clear accumulator B and carry
renamenameret@      rts                 ; return to caller
* X source, Y destination, B byte count. Used only with nonoverlapping buffers.
CopyBytes           lda       ,x+       ; load A from ,x+
                    sta       ,y+       ; save A in ,y+
                    decb                ; decrement accumulator B
                    bne       CopyBytes ; branch when unequal or nonzero CopyBytes
                    rts                 ; return to caller
                    use       rename-name.d ; include shared definitions or implementation

* Snapshot identity before metadata publication; Record is scratch while writing.
SaveIdentity        pshs      x,y       ; preserve caller pointers
                    leax      F.Start,u ; first cluster, size, FAT entry
                    leay      F.Record,u ; transient snapshot
                    ldb       #40       ; complete identity
                    lbsr      CopyBytes ; copy without overlapping
                    puls      x,y,pc    ; return
RestoreIdentity     pshs      x,y       ; preserve caller pointers
                    leax      F.Record,u ; saved identity
                    leay      F.Start,u ; active identity
                    ldb       #40       ; complete identity
                    lbsr      CopyBytes ; restore the original metadata
                    clr       F.WalkValid,u ; invalidate the chain cursor
                    puls      x,y,pc    ; return
* A failed FAT link may have changed one mirror. Restore the old EOC first;
* only reclaim the new cluster after all copies no longer point to it.
LinkNew             lbsr      SetFat    ; publish the new link
                    bcc       linkret@  ; linked successfully
                    pshs      b,cc      ; retain original error
                    ldd       #$0FFF    ; original tail was EOC
                    std       F.Value,u ; high end marker
                    ldd       #$FFFF    ; low end marker
                    std       F.Value+2,u ; complete end marker
                    lbsr      SetFat    ; roll back any partially updated mirrors
                    bcs       linkfailed@ ; leave allocation for fsck on rollback failure
                    lbsr      ReclaimNew ; reclaim unreachable cluster
linkfailed@         puls      b,cc      ; return original link failure
linkret@            rts                 ; return
ReclaimNew          ldd       #F.New*256+F.Saved ; unpublished allocation
                    lbsr      CopyVal   ; select the allocated cluster
                    lbra      FreeChain ; best-effort reclamation

* Val identifies a directory whose children changed. FAT32 root has no parent
* entry to timestamp. For other directories, follow '..' and find the directory
* by cluster in its parent's entries; this also works for relative cwd paths and
* renamed/LFN-backed directories without needing a stored pathname.
* Record[0..63] belongs to rename; [64..135] is private scratch here.
TouchDirectory      pshs      x,y       ; preserve caller pointers before comparisons
                    leax      F.Root,u  ; the root has no timestamp-bearing entry
                    lbsr      CompareVal ; compare target cluster with root
                    lbeq      touchroot@ ; root mutations need no extra I/O
                    leax      F.Record+128,u ; stable target across directory lookup
                    lbsr      StoreVal  ; retain target directory cluster
                    leax      F.Start,u ; current first cluster, size and entry
                    leay      F.Record+64,u ; snapshot without disturbing rename
                    ldb       #40       ; complete active identity
                    lbsr      CopyBytes ; preserve active file or directory
                    leax      F.DirLBA,u ; original entry location
                    ldb       #6        ; sector and offset
                    lbsr      CopyBytes ; snapshot location
                    leax      F.Parent,u ; original containing-directory cluster
                    ldb       #4        ; full-width cluster
                    lbsr      CopyBytes ; preserve deletion/create context
                    leax      F.Name,u  ; original short-name scratch
                    ldb       #11       ; padded alias
                    lbsr      CopyBytes ; preserve caller name
                    lda       F.HasLFN,u ; retain the active alias protection flag
                    sta       F.Record+125,u ; final byte of the identity snapshot
                    leax      F.Record+128,u ; target directory
                    lbsr      LoadVal   ; select target
                    lda       #F.Start-128 ; traverse target directory
                    lbsr      StoreField ; set temporary start cluster
                    leax      F.Name,u  ; request the parent link
                    ldd       #$2E2E    ; exact '..' basename
                    std       ,x++      ; first two name bytes
                    lda       #C$SPAC   ; padded short-name format
                    ldb       #9        ; remaining alias bytes
touchname@          sta       ,x+       ; pad parent alias
                    decb                ; count padding
                    bne       touchname@ ; finish alias
                    ldy       2,s       ; restore path descriptor after scratch copies
                    lbsr      Lookup    ; adopt the directory containing the target
                    lbcs      touchrestore@ ; restore identity after lookup failure
                    clra                ; begin parent directory scan at byte zero
                    clrb                ; clear low accumulator
                    std       F.Scan,u  ; high scan word
                    std       F.Scan+2,u ; low scan word
                    clr       F.WalkValid,u ; new directory chain
touchscan@          ldd       #F.Scan*256+F.Offset ; next physical directory record
                    lbsr      CopyVal   ; set Locate operand
                    lbsr      Locate    ; fetch slot using normal chain validation
                    bcs       touchrestore@ ; return media or chain failure
                    lda       ,x        ; check directory end marker
                    beq       touchbad@ ; target must remain linked from its parent
                    cmpa      #$E5      ; deleted record
                    beq       touchnext@ ; skip free slot
                    cmpa      #'.       ; dot entries do not name the target child
                    beq       touchnext@ ; skip dot links
                    lda       11,x      ; fat attributes
                    anda      #$18      ; directory or volume-label bits
                    cmpa      #$10      ; accept directories only
                    bne       touchnext@ ; skip files, labels and LFN slots
                    lda       21,x      ; high cluster word, little endian
                    anda      #15       ; fat32 reserved top bits
                    ldb       20,x      ; remaining high-word byte
                    cmpd      F.Record+128,u ; target high word
                    bne       touchnext@ ; another directory
                    lda       27,x      ; low cluster word, little endian
                    ldb       26,x      ; remaining low-word byte
                    cmpd      F.Record+130,u ; target low word
                    beq       touchfound@ ; located the target's real entry
touchnext@          lbsr      ScanNext  ; advance by one FAT directory slot
                    bcc       touchscan@ ; continue validated scan
                    bra       touchrestore@ ; propagate arithmetic failure
touchbad@           ldb       #E$BTyp   ; missing parent link is corrupt media
                    coma                ; set error carry
                    bra       touchrestore@ ; restore active identity
touchfound@         pshs      x         ; preserve the real on-disk slot
                    leay      F.Entry,u ; reuse normal timestamp encoder
                    ldb       #32       ; complete directory metadata
                    lbsr      CopyBytes ; copy directory entry to scratch
                    lbsr      Stamp     ; encode current kernel clock
                    puls      x         ; original disk entry pointer
                    ldd       F.Entry+22,u ; fat modification time
                    std       22,x      ; update time only
                    std       F.Record+132,u ; retain for open directory caches
                    ldd       F.Entry+24,u ; fat modification date
                    std       24,x      ; preserve all other metadata
                    std       F.Record+134,u ; cache update value
                    ldy       2,s       ; restore path descriptor after entry encoding
                    lbsr      WriteData ; commit the parent directory sector
touchrestore@       pshs      b,cc      ; retain metadata operation result
                    leax      F.Record+64,u ; saved current identity
                    leay      F.Start,u ; first cluster, size and entry
                    ldb       #40       ; complete identity length
                    lbsr      CopyBytes ; restore active path
                    leay      F.DirLBA,u ; saved sector and entry offset
                    ldb       #6        ; location length
                    lbsr      CopyBytes ; restore original location
                    leay      F.Parent,u ; original parent cluster
                    ldb       #4        ; parent width
                    lbsr      CopyBytes ; restore mutation context
                    leay      F.Name,u  ; original name scratch
                    ldb       #11       ; alias width
                    lbsr      CopyBytes ; restore short name
                    lda       F.Record+125,u ; original alias protection state
                    sta       F.HasLFN,u ; restore permission metadata
                    clr       F.WalkValid,u ; scan used a different directory chain
                    puls      b,cc      ; recover original result
                    bcs       touchreturn@ ; failed metadata I/O does not refresh caches
                    bsr       TouchDirectoryCaches ; keep open directory FD results coherent
touchreturn@        puls      x,y,pc    ; preserve caller pointers and carry
touchroot@          clrb                ; root has no stored timestamp
                    puls      x,y,pc    ; return without I/O
* Directory readers can coexist with mutations. Update only matching physical
* volume/cluster caches, after restoring the caller's own entry identity.
TouchDirectoryCaches ldx       F.Owner,u ; caller path descriptor
                    ldx       PD.DEV,x  ; physical device
                    ldx       V$STAT,x  ; shared statics across aliases
                    ldx       BV.FMPaths,x ; live path list
touchcache@         cmpx      #0        ; list terminator
                    beq       touchcacheok@ ; complete cache refresh
                    ldd       F.Base,u  ; distinguish partitions on the device
                    cmpd      F.Base,x  ; partition high word
                    bne       touchcachenext@ ; another mounted volume
                    ldd       F.Base+2,u ; partition low word
                    cmpd      F.Base+2,x ; complete partition match
                    bne       touchcachenext@ ; another mounted volume
                    ldd       F.Record+128,u ; changed directory cluster
                    cmpd      F.Start,x ; cached high cluster word
                    bne       touchcachenext@ ; another object
                    ldd       F.Record+130,u ; changed low cluster word
                    cmpd      F.Start+2,x ; cached low cluster word
                    bne       touchcachenext@ ; another object
                    ldd       F.Record+132,u ; newly committed time
                    std       F.Entry+22,x ; update cached modification time
                    ldd       F.Record+134,u ; newly committed date
                    std       F.Entry+24,x ; update cached modification date
touchcachenext@     ldx       F.NextPath,x ; next open path
                    bra       touchcache@ ; examine the next cache
touchcacheok@       clrb                ; successful synchronous refresh
                    rts                 ; return
