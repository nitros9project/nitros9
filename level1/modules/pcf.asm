* pcf - FAT32 file manager over blkdrv ABI 1.
                    use       defsfile  ; include shared definitions or implementation
                    use       blkdrv.d  ; include shared definitions or implementation
                    use       pcf.d     ; include shared definitions or implementation
                    use       readdir.d ; include shared definitions or implementation
                    mod       eom,name,FlMgr+Objct,ReEnt+1,start,0 ; emit OS-9 module header
name                fcs       /pcf/               ; module name or literal text
                    fcb       1         ; emit byte data
* ABI entry slots remain three bytes: BSR plus an unsigned table offset.
* The common dispatcher replaces its return address with the target routine;
* no execution falls through into a selector byte or the relative-offset table.
start
Create              bsr       FMLocked  ; call helper FMLocked
                    fcb       0*2       ; emit byte data
Open                bsr       FMLocked  ; call helper FMLocked
                    fcb       1*2       ; emit byte data
MkDir               bsr       FMLocked  ; call helper FMLocked
                    fcb       2*2       ; emit byte data
ChgDir              bsr       FMLocked  ; call helper FMLocked
                    fcb       3*2       ; emit byte data
Delete              bsr       FMLocked  ; call helper FMLocked
                    fcb       4*2       ; emit byte data
Seek                bsr       FMLocked  ; call helper FMLocked
                    fcb       5*2       ; emit byte data
Read                bsr       FMLocked  ; call helper FMLocked
                    fcb       6*2       ; emit byte data
Write               bsr       FMLocked  ; call helper FMLocked
                    fcb       7*2       ; emit byte data
ReadLn              bsr       FMLocked  ; call helper FMLocked
                    fcb       8*2       ; emit byte data
WriteLn             bsr       FMLocked  ; call helper FMLocked
                    fcb       9*2       ; emit byte data
GetStat             bsr       FMLocked  ; call helper FMLocked
                    fcb       10*2      ; emit byte data
SetStat             bsr       FMLocked  ; call helper FMLocked
                    fcb       11*2      ; emit byte data
Close               bsr       FMLocked  ; call helper FMLocked
                    fcb       12*2      ; emit byte data
FMLocked            pshs      x         ; preserve x on stack
                    ldx       2,s                 address of entry selector
                    ldb       ,x        ; load B from ,x
                    leax      FMTargets,pcr ; point X at FMTargets,pcr
                    ldd       b,x       ; load D from b,x
                    leax      d,x       ; point X at d,x
                    stx       2,s                 replace dispatcher return address
                    ldx       PD.DEV,y  ; load X from PD.DEV,y
                    ldx       V$STAT,x  ; load X from V$STAT,x
                    pshs      cc        ; preserve cc on stack
                    orcc      #IntMasks ; set selected CC bits with #IntMasks
                    tst       V.BUSY,x  ; test V.BUSY,x
                    bne       fmbusy@   ; branch when unequal or nonzero fmbusy@
                    inc       V.BUSY,x  ; increment V.BUSY,x
                    puls      cc        ; restore cc from stack
* Per-open buffers must not hide changes made through another open path.
                    ldx       PD.BUF,y  ; load X from PD.BUF,y
                    beq       fmcall@   ; branch when equal or zero fmcall@
                    clr       F.DataValid,x ; clear F.DataValid,x
                    clr       F.FatValid,x ; clear F.FatValid,x
fmcall@             jsr       [2,s]     ; call routine [2,s]
                    pshs      b,cc      ; preserve b,cc on stack
                    ldx       PD.DEV,y  ; load X from PD.DEV,y
                    ldx       V$STAT,x  ; load X from V$STAT,x
                    clr       V.BUSY,x  ; clear V.BUSY,x
                    puls      b,cc      ; restore b,cc from stack
                    bra       fmreturn@ ; continue unconditionally fmreturn@
fmbusy@             puls      cc        ; restore cc from stack
                    ldb       #E$DevBsy ; load B from #E$DevBsy
                    coma                ; complement A and set carry
fmreturn@           puls      x         ; restore x from stack
                    leas      2,s       ; point S at 2,s
                    rts                 ; return to caller

FMTargets
                    fdb       CreateImpl-FMTargets ; emit word data
                    fdb       OpenImpl-FMTargets ; emit word data
                    fdb       MkDirImpl-FMTargets ; emit word data
                    fdb       ChgDirImpl-FMTargets ; emit word data
                    fdb       DeleteImpl-FMTargets ; emit word data
                    fdb       SeekImpl-FMTargets ; emit word data
                    fdb       ReadImpl-FMTargets ; emit word data
                    fdb       WriteImpl-FMTargets ; emit word data
                    fdb       ReadLnImpl-FMTargets ; emit word data
                    fdb       WriteLnImpl-FMTargets ; emit word data
                    fdb       GetStatImpl-FMTargets ; emit word data
                    fdb       SetStatImpl-FMTargets ; emit word data
                    fdb       CloseImpl-FMTargets ; emit word data
ReadOnly            ldb       #E$WP     ; load B from #E$WP
                    coma                ; complement A and set carry
                    rts                 ; return to caller
BadMedia            ldb       #E$BTyp   ; load B from #E$BTyp
                    coma                ; complement A and set carry
                    rts                 ; return to caller
EOFError            ldb       #E$EOF    ; load B from #E$EOF
                    coma                ; complement A and set carry
                    rts                 ; return to caller
PathError           ldb       #E$BPNam  ; load B from #E$BPNam
                    coma                ; complement A and set carry
                    rts                 ; return to caller
NotFound            ldb       #E$PNNF   ; load B from #E$PNNF
                    coma                ; complement A and set carry
                    rts                 ; return to caller
AccessError         ldb       #E$FNA    ; load B from #E$FNA
                    coma                ; complement A and set carry
                    rts                 ; return to caller
Success             clrb                ; clear accumulator B and carry
                    rts                 ; return to caller

* Internals: Y=path descriptor, U=private workspace. X/D scratch.
* Decode unaligned little-endian disk integers into the big-endian Val.
LE32                lda       3,x       ; load A from 3,x
                    ldb       2,x       ; load B from 2,x
                    std       F.Val,u   ; save D in F.Val,u
LELow               lda       1,x       ; load A from 1,x
                    ldb       ,x        ; load B from ,x
                    std       F.Val+2,u ; save D in F.Val+2,u
                    rts                 ; return to caller
LE16                clr       F.Val,u   ; clear F.Val,u
                    clr       F.Val+1,u ; clear F.Val+1,u
                    bra       LELow     ; continue unconditionally LELow
* A is a signed field displacement from U+128, covering offsets 0..255.
* LEAX leaves carry intact; the tail retains LoadVal/StoreVal register results.
LoadField           leax      128,u     ; point X at 128,u
                    leax      a,x       ; point X at a,x
LoadVal             ldd       ,x        ; load D from ,x
                    std       F.Val,u   ; save D in F.Val,u
                    ldd       2,x       ; load D from 2,x
                    std       F.Val+2,u ; save D in F.Val+2,u
                    rts                 ; return to caller
* Increment a byte-addressable 32-bit field, retaining Val and the final X.
IncField            bsr       LoadField ; call helper LoadField
                    bsr       IncVal    ; call helper IncVal
                    bra       StoreVal  ; continue unconditionally StoreVal
StoreField          leax      128,u     ; point X at 128,u
                    leax      a,x       ; point X at a,x
                    bra       StoreVal  ; continue unconditionally StoreVal
* A/B are unsigned source/destination workspace offsets (before F.Path).
* Match LoadVal + StoreVal: Val and X retain the copy; carry is preserved.
CopyVal             pshs      b,cc      ; preserve b,cc on stack
                    tfr       a,b       ; transfer registers a,b
                    clra                ; clear accumulator A and carry
                    leax      d,u       ; point X at d,u
                    bsr       LoadVal   ; call helper LoadVal
                    clra                ; clear accumulator A and carry
                    puls      b,cc      ; restore b,cc from stack
                    leax      d,u       ; point X at d,u
StoreVal            ldd       F.Val,u   ; load D from F.Val,u
                    std       ,x        ; save D in ,x
                    ldd       F.Val+2,u ; load D from F.Val+2,u
                    std       2,x       ; save D in 2,x
                    rts                 ; return to caller
AddVal              ldd       2,x       ; load D from 2,x
                    addd      F.Val+2,u ; add to D: F.Val+2,u
                    std       2,x       ; save D in 2,x
                    ldd       ,x        ; load D from ,x
                    adcb      F.Val+1,u ; add to B with carry: F.Val+1,u
                    adca      F.Val,u   ; add to A with carry: F.Val,u
                    std       ,x        ; save D in ,x
                    rts                 ; return to caller
SubVal              ldd       2,x       ; load D from 2,x
                    subd      F.Val+2,u ; subtract from D: F.Val+2,u
                    std       2,x       ; save D in 2,x
                    ldd       ,x        ; load D from ,x
                    sbcb      F.Val+1,u ; subtract from B with borrow: F.Val+1,u
                    sbca      F.Val,u   ; subtract from A with borrow: F.Val,u
                    std       ,x        ; save D in ,x
                    rts                 ; return to caller
CompareVal          ldd       F.Val,u   ; load D from F.Val,u
                    cmpd      ,x        ; compare D with ,x
                    bne       cmpdone@  ; branch when unequal or nonzero cmpdone@
                    ldd       F.Val+2,u ; load D from F.Val+2,u
                    cmpd      2,x       ; compare D with 2,x
cmpdone@            rts                 ; return to caller
IncVal              ldd       #1        ; load D from #1
* Add unsigned D to Val, preserving X/Y/U and returning the full-width carry.
AddWord             addd      F.Val+2,u ; add to D: F.Val+2,u
                    std       F.Val+2,u ; save D in F.Val+2,u
                    ldd       F.Val,u   ; load D from F.Val,u
                    adcb      #0        ; add to B with carry: #0
                    adca      #0        ; add to A with carry: #0
                    std       F.Val,u   ; save D in F.Val,u
                    rts                 ; return to caller
* Add unsigned D to the path position, leaving X/Y/U and Val untouched.
AddPosition         addd      F.Pos+2,u ; add to D: F.Pos+2,u
                    std       F.Pos+2,u ; save D in F.Pos+2,u
                    ldd       F.Pos,u   ; load D from F.Pos,u
                    adcb      #0        ; add to B with carry: #0
                    adca      #0        ; add to A with carry: #0
                    std       F.Pos,u   ; save D in F.Pos,u
                    rts                 ; return to caller
DecVal              ldd       F.Val+2,u ; load D from F.Val+2,u
                    subd      #1        ; subtract from D: #1
                    std       F.Val+2,u ; save D in F.Val+2,u
                    ldd       F.Val,u   ; load D from F.Val,u
                    sbcb      #0        ; subtract from B with borrow: #0
                    sbca      #0        ; subtract from A with borrow: #0
                    std       F.Val,u   ; save D in F.Val,u
                    rts                 ; return to caller
ShiftRight          lsr       F.Val,u   ; shift right unsigned F.Val,u
                    ror       F.Val+1,u ; rotate right through carry F.Val+1,u
                    ror       F.Val+2,u ; rotate right through carry F.Val+2,u
                    ror       F.Val+3,u ; rotate right through carry F.Val+3,u
                    decb                ; decrement accumulator B
                    bne       ShiftRight ; branch when unequal or nonzero ShiftRight
                    rts                 ; return to caller
ShiftLeft           lsl       F.Val+3,u ; shift left F.Val+3,u
                    rol       F.Val+2,u ; rotate left through carry F.Val+2,u
                    rol       F.Val+1,u ; rotate left through carry F.Val+1,u
                    rol       F.Val,u   ; rotate left through carry F.Val,u
                    bcs       shiftbad@ ; branch on carry or error shiftbad@
                    decb                ; decrement accumulator B
                    bne       ShiftLeft ; branch when unequal or nonzero ShiftLeft
                    clrb                ; clear accumulator B and carry
                    rts                 ; return to caller
shiftbad@           lbra      BadMedia  ; continue unconditionally BadMedia

* X=request or info, A=driver slot. No PD.BUF/RBF deblocking convention.
Driver              pshs      a,x,y,u   ; preserve a,x,y,u on stack
                    ldx       PD.DEV,y  ; load X from PD.DEV,y
                    ldu       V$STAT,x  ; load U from V$STAT,x
                  IFGT    Level-1 ; conditional assembly
                    ldx       V$DRIVEX,x ; load X from V$DRIVEX,x
                  ELSE            ; conditional assembly
                    ldx       V$DRIV,x  ; load X from V$DRIV,x
                    ldd       M$Exec,x  ; load D from M$Exec,x
                    leax      d,x       ; point X at d,x
                  ENDC            ; conditional assembly
                    lda       ,s        ; load A from ,s
                    leax      a,x       ; point X at a,x
                    pshs      x         ; preserve x on stack
                    ldx       3,s       ; load X from 3,s
                    jsr       [,s]      ; call routine [,s]
                    leas      2,s       ; point S at 2,s
                    puls      a,x,y,u,pc ; restore a,x,y,u,pc from stack

* Val=absolute LBA. Separate one-sector FAT and data caches.
ReadData            leax      F.DataValid,u ; point X at F.DataValid,u
                    pshs      x         ; preserve x on stack
                    leax      F.Data,u  ; point X at F.Data,u
                    bra       ReadCache ; continue unconditionally ReadCache
ReadFat             leax      F.FatValid,u ; point X at F.FatValid,u
                    pshs      x         ; preserve x on stack
                    leax      F.Fat,u   ; point X at F.Fat,u
* Stack: sector buffer, cache descriptor (valid byte + LBA). Y remains the
* OS-9 path descriptor throughout ReadBlock/Driver. Failed fills stay invalid.
ReadCache           pshs      x         ; preserve x on stack
                    ldx       2,s       ; load X from 2,s
                    tst       ,x        ; test ,x
                    beq       cachefill@ ; branch when equal or zero cachefill@
                    leax      1,x       ; point X at 1,x
                    lbsr      CompareVal ; call helper CompareVal
                    beq       cachehit@ ; branch when equal or zero cachehit@
cachefill@          ldx       2,s       ; load X from 2,s
                    clr       ,x        ; clear ,x
                    ldx       ,s        ; load X from ,s
                    stx       F.Request+BR.Buffer,u ; save X in F.Request+BR.Buffer,u
                    bsr       ReadBlock ; call helper ReadBlock
                    bcs       cacheret@ ; branch on carry or error cacheret@
                    ldx       2,s       ; load X from 2,s
                    leax      1,x       ; point X at 1,x
                    lbsr      StoreVal  ; call helper StoreVal
                    inc       -1,x      ; increment -1,x
cachehit@           clrb                ; clear accumulator B and carry
cacheret@           puls      x         ; restore x from stack
                    leas      2,s       ; point S at 2,s
                    rts                 ; return to caller
* Read/write share LBA setup, driver-error propagation and exact block count.
WriteBlock          lda       #BD.Write ; load A from #BD.Write
                    bra       TransferBlock ; continue unconditionally TransferBlock
ReadBlock           lda       #BD.Read  ; load A from #BD.Read
TransferBlock       pshs      a         ; preserve a on stack
                    leax      F.Request+BR.LBA,u ; point X at F.Request+BR.LBA,u
                    lbsr      StoreVal  ; call helper StoreVal
                    leax      F.Request,u ; point X at F.Request,u
                    puls      a         ; restore a from stack
                    bsr       Driver    ; call helper Driver
                    bcs       blockret@ ; branch on carry or error blockret@
                    ldd       F.Request+BR.Done,u ; load D from F.Request+BR.Done,u
                    cmpd      #1        ; compare D with #1
                    lbne      BadMedia  ; branch when unequal or nonzero BadMedia
                    clrb                ; clear accumulator B and carry
blockret@           rts                 ; return to caller

* Validate BPB and all derived geometry before any FAT/directory reads.
Mount               leax      F.Info,u  ; point X at F.Info,u
                    ldd       #BI.Len*256+BD.Version ; load D from #BI.Len*256+BD.Version
                    std       BI.Size,x ; save D in BI.Size,x
                    lda       #BD.Info  ; load A from #BD.Info
                    lbsr      Driver    ; call helper Driver
                    lbcs      mountret  ; branch on carry or error mountret
                    ldd       F.Info+BI.BlockSize,u ; load D from F.Info+BI.BlockSize,u
                    cmpd      #512      ; compare D with #512
                    lbne      BadMedia  ; branch when unequal or nonzero BadMedia
                    ldd       #BR.Len*256+BD.Version ; load D from #BR.Len*256+BD.Version
                    std       F.Request+BR.Size,u ; save D in F.Request+BR.Size,u
                    lda       F.Info+BI.Unit,u ; load A from F.Info+BI.Unit,u
                    sta       F.Request+BR.Unit,u ; save A in F.Request+BR.Unit,u
                    ldd       #1        ; load D from #1
                    std       F.Request+BR.Count,u ; save D in F.Request+BR.Count,u
                    ldd       #512      ; load D from #512
                    std       F.Request+BR.Bytes,u ; save D in F.Request+BR.Bytes,u
                    ldx       PD.DEV,y  ; load X from PD.DEV,y
                    ldx       V$DESC,x  ; load X from V$DESC,x
                    pshs      x         ; preserve x on stack
                    leax      FT.Base,x ; point X at FT.Base,x
                    lbsr      LoadVal   ; call helper LoadVal
                    lda       #F.Base-128 ; load A from #F.Base-128
                    lbsr      StoreField ; call helper StoreField
                    leax      F.Info+BI.Last,u ; point X at F.Info+BI.Last,u
                    lbsr      CompareVal ; call helper CompareVal
                    lbhi      mountdescbad ; branch when unsigned higher mountdescbad
                    ldx       ,s        ; load X from ,s
                    leax      FT.Length,x ; point X at FT.Length,x
                    lbsr      LoadVal   ; call helper LoadVal
                    lda       #F.Span-128 ; load A from #F.Span-128
                    lbsr      StoreField ; call helper StoreField
                    leas      2,s       ; point S at 2,s
                    lda       #F.Base-128 ; load A from #F.Base-128
                    lbsr      LoadField ; call helper LoadField
                    lbsr      ReadData  ; call helper ReadData
                    lbcs      mountret  ; branch on carry or error mountret
                    ldd       510,x     ; load D from 510,x
                    cmpd      #$55AA    ; compare D with #$55AA
                    lbne      BadMedia  ; branch when unequal or nonzero BadMedia
                    ldd       11,x      ; load D from 11,x
                    cmpd      #$0002               512 little endian
                    lbne      BadMedia  ; branch when unequal or nonzero BadMedia
                    ldd       17,x                 root entry count must be zero
                    lbne      BadMedia  ; branch when unequal or nonzero BadMedia
                    ldd       19,x                 total16 must be zero on FAT32
                    lbne      BadMedia  ; branch when unequal or nonzero BadMedia
                    ldd       22,x                 FAT16 size must be zero
                    lbne      BadMedia  ; branch when unequal or nonzero BadMedia
                    ldd       42,x                 filesystem version 0
                    lbne      BadMedia  ; branch when unequal or nonzero BadMedia
                    lda       16,x      ; load A from 16,x
                    lbeq      mountbad  ; branch when equal or zero mountbad
                    cmpa      #2        ; compare A with #2
                    lbhi      mountbad  ; branch when unsigned higher mountbad
                    sta       F.Fats,u  ; save A in F.Fats,u
                    lda       13,x      ; load A from 13,x
                    lbeq      mountbad  ; branch when equal or zero mountbad
                    bmi       spc128@   ; branch when negative spc128@
                    bra       spcpower@ ; continue unconditionally spcpower@
spc128@             cmpa      #128      ; compare A with #128
                    lbne      mountbad  ; branch when unequal or nonzero mountbad
spcpower@           sta       F.SPC,u   ; save A in F.SPC,u
                    deca                ; decrement accumulator A
                    anda      F.SPC,u   ; mask A with F.SPC,u
                    lbne      mountbad  ; branch when unequal or nonzero mountbad
                    lda       F.SPC,u   ; load A from F.SPC,u
spcshift@           lsra                ; shift or rotate accumulator A
                    beq       spcdone@  ; branch when equal or zero spcdone@
                    inc       F.Shift,u ; increment F.Shift,u
                    bra       spcshift@ ; continue unconditionally spcshift@
spcdone@            leax      32,x      ; point X at 32,x
                    lbsr      LE32      ; call helper LE32
                    lda       #F.Total-128 ; load A from #F.Total-128
                    lbsr      StoreField ; call helper StoreField
                    ldd       F.Val,u   ; load D from F.Val,u
                    bne       totalok@  ; branch when unequal or nonzero totalok@
                    ldd       F.Val+2,u ; load D from F.Val+2,u
                    lbeq      mountbad  ; branch when equal or zero mountbad
totalok@            ldd       F.Span,u  ; load D from F.Span,u
                    bne       spancheck@ ; branch when unequal or nonzero spancheck@
                    ldd       F.Span+2,u ; load D from F.Span+2,u
                    beq       endcheck@ ; branch when equal or zero endcheck@
spancheck@          leax      F.Span,u  ; point X at F.Span,u
                    lbsr      CompareVal ; call helper CompareVal
                    lbhi      mountbad  ; branch when unsigned higher mountbad
endcheck@           lbsr      DecVal    ; call helper DecVal
                    leax      F.Base,u  ; point X at F.Base,u
                    lbsr      AddBase   ; call helper AddBase
                    lbcs      mountret  ; branch on carry or error mountret
                    leax      F.Info+BI.Last,u ; point X at F.Info+BI.Last,u
                    lbsr      CompareVal ; call helper CompareVal
                    lbhi      mountbad  ; branch when unsigned higher mountbad
                    leax      F.Data+14,u ; point X at F.Data+14,u
                    lbsr      LE16      ; call helper LE16
                    ldd       F.Val+2,u ; load D from F.Val+2,u
                    lbeq      mountbad  ; branch when equal or zero mountbad
                    lda       #F.Temp-128 ; load A from #F.Temp-128
                    lbsr      StoreField          relative data start begins at reserved count
                    leax      F.Base,u  ; point X at F.Base,u
                    lbsr      AddBase   ; call helper AddBase
                    lbcs      mountret  ; branch on carry or error mountret
                    lda       #F.FatStart-128 ; load A from #F.FatStart-128
                    lbsr      StoreField ; call helper StoreField
                    leax      F.Data+36,u ; point X at F.Data+36,u
                    lbsr      LE32      ; call helper LE32
                    ldd       F.Val,u   ; load D from F.Val,u
                    bne       fatszok@  ; branch when unequal or nonzero fatszok@
                    ldd       F.Val+2,u ; load D from F.Val+2,u
                    lbeq      mountbad  ; branch when equal or zero mountbad
fatszok@            lda       #F.FatSize-128 ; load A from #F.FatSize-128
                    lbsr      StoreField ; call helper StoreField
                    lda       F.Fats,u  ; load A from F.Fats,u
                    pshs      a         ; preserve a on stack
fatmultiply@        leax      F.Temp,u  ; point X at F.Temp,u
                    lbsr      AddVal    ; call helper AddVal
                    lbcs      mountbadpop ; branch on carry or error mountbadpop
                    dec       ,s        ; decrement ,s
                    bne       fatmultiply@ ; branch when unequal or nonzero fatmultiply@
                    leas      1,s       ; point S at 1,s
                    lda       #F.Temp-128 ; load A from #F.Temp-128
                    lbsr      LoadField ; call helper LoadField
                    leax      F.Total,u ; point X at F.Total,u
                    lbsr      CompareVal ; call helper CompareVal
                    lbhs      mountbad  ; branch when unsigned higher or equal mountbad
                    leax      F.Base,u  ; point X at F.Base,u
                    lbsr      AddBase   ; call helper AddBase
                    lbcs      mountret  ; branch on carry or error mountret
                    lda       #F.DataStart-128 ; load A from #F.DataStart-128
                    lbsr      StoreField ; call helper StoreField
                    ldd       #F.Total*256+F.MaxCluster ; load D from #F.Total*256+F.MaxCluster
                    lbsr      CopyVal   ; call helper CopyVal
                    lda       #F.Temp-128 ; load A from #F.Temp-128
                    lbsr      LoadField ; call helper LoadField
                    leax      F.MaxCluster,u ; point X at F.MaxCluster,u
                    lbsr      SubVal    ; call helper SubVal
                    lbsr      LoadVal   ; call helper LoadVal
                    ldb       F.Shift,u ; load B from F.Shift,u
                    beq       clusters@ ; branch when equal or zero clusters@
                    lbsr      ShiftRight ; call helper ShiftRight
clusters@           ldd       F.Val,u   ; load D from F.Val,u
                    bne       minimum@  ; branch when unequal or nonzero minimum@
                    ldd       F.Val+2,u ; load D from F.Val+2,u
                    cmpd      #65525               discriminate FAT32 by cluster count
                    blo       mountbad  ; branch when unsigned lower mountbad
minimum@            lbsr      IncVal    ; call helper IncVal
                    lda       #F.MaxCluster-128 ; load A from #F.MaxCluster-128
                    lbsr      StoreField ; call helper StoreField
                    bsr       ValidCluster ; call helper ValidCluster
                    bcs       mountret  ; branch on carry or error mountret
* FAT must contain entries zero through MaxCluster inclusive.
                    lbsr      IncVal    ; call helper IncVal
                    ldd       #127      ; load D from #127
                    lbsr      AddWord   ; call helper AddWord
                    ldb       #7        ; load B from #7
                    lbsr      ShiftRight ; call helper ShiftRight
                    leax      F.FatSize,u ; point X at F.FatSize,u
                    lbsr      CompareVal ; call helper CompareVal
                    bhi       mountbad  ; branch when unsigned higher mountbad
* FAT32 ExtFlags: mirroring enabled chooses FAT 0; otherwise select active FAT.
                    lda       F.Data+40,u ; load A from F.Data+40,u
                    bita      #$80      ; test A against #$80
                    beq       root@     ; branch when equal or zero root@
                    anda      #15       ; mask A with #15
                    cmpa      F.Fats,u  ; compare A with F.Fats,u
                    bhs       mountbad  ; branch when unsigned higher or equal mountbad
                    sta       F.Active,u ; save A in F.Active,u
                    tsta                ; test accumulator A
                    beq       root@     ; branch when equal or zero root@
                    lda       #F.FatSize-128 ; load A from #F.FatSize-128
                    lbsr      LoadField ; call helper LoadField
                    leax      F.FatStart,u ; point X at F.FatStart,u
                    lbsr      AddVal    ; call helper AddVal
                    bcs       mountbad  ; branch on carry or error mountbad
root@               lbsr      MountWriteInfo ; call helper MountWriteInfo
                    leax      F.Data+44,u ; point X at F.Data+44,u
                    lbsr      LE32      ; call helper LE32
                    bsr       ValidCluster ; call helper ValidCluster
                    bcs       mountret  ; branch on carry or error mountret
                    lda       #F.Root-128 ; load A from #F.Root-128
                    lbsr      StoreField ; call helper StoreField
                    clrb                ; clear accumulator B and carry
mountret            rts                 ; return to caller
mountdescbad        leas      1,s       ; point S at 1,s
mountbadpop         leas      1,s       ; point S at 1,s
mountbad            lbra      BadMedia  ; continue unconditionally BadMedia

* Val += 32-bit value at X, with checked overflow.
AddBase             ldd       F.Val+2,u ; load D from F.Val+2,u
                    addd      2,x       ; add to D: 2,x
                    std       F.Val+2,u ; save D in F.Val+2,u
                    ldd       F.Val,u   ; load D from F.Val,u
                    adcb      1,x       ; add to B with carry: 1,x
                    adca      ,x        ; add to A with carry: ,x
                    std       F.Val,u   ; save D in F.Val,u
                    lbcs      BadMedia  ; branch on carry or error BadMedia
                    clrb                ; clear accumulator B and carry
                    rts                 ; return to caller
ValidCluster        ldd       F.Val,u   ; load D from F.Val,u
                    cmpd      #$0FFF    ; compare D with #$0FFF
                    bhi       invalid@  ; branch when unsigned higher invalid@
                    blo       lowcheck@ ; branch when unsigned lower lowcheck@
                    ldd       F.Val+2,u ; load D from F.Val+2,u
                    cmpd      #$FFF0    ; compare D with #$FFF0
                    bhs       invalid@  ; branch when unsigned higher or equal invalid@
lowcheck@           ldd       F.Val,u   ; load D from F.Val,u
                    bne       maxcheck@ ; branch when unequal or nonzero maxcheck@
                    ldd       F.Val+2,u ; load D from F.Val+2,u
                    cmpd      #2        ; compare D with #2
                    blo       invalid@  ; branch when unsigned lower invalid@
maxcheck@           leax      F.MaxCluster,u ; point X at F.MaxCluster,u
                    lbsr      CompareVal ; call helper CompareVal
                    bhi       invalid@  ; branch when unsigned higher invalid@
                    clrb                ; clear accumulator B and carry
                    rts                 ; return to caller
invalid@            lbra      BadMedia  ; continue unconditionally BadMedia

* Cluster in/out, EOF only for FAT EOC markers; free/bad/reserved links fail.
FatEntry            lda       #F.Cluster-128 ; load A from #F.Cluster-128
                    lbsr      LoadField ; call helper LoadField
                    ldb       #7        ; load B from #7
                    lbsr      ShiftRight ; call helper ShiftRight
                    leax      F.FatStart,u ; point X at F.FatStart,u
                    bsr       AddBase   ; call helper AddBase
                    bcs       fatentryret@ ; branch on carry or error fatentryret@
                    lbsr      ReadFat   ; call helper ReadFat
                    bcs       fatentryret@ ; branch on carry or error fatentryret@
                    ldb       F.Cluster+3,u ; load B from F.Cluster+3,u
                    andb      #127      ; mask B with #127
                    clra                ; clear accumulator A and carry
                    lslb                ; shift or rotate accumulator B
                    rola                ; shift or rotate accumulator A
                    lslb                ; shift or rotate accumulator B
                    rola                ; shift or rotate accumulator A
                    leax      d,x       ; point X at d,x
                    clrb                ; clear accumulator B and carry
fatentryret@        rts                 ; return to caller
NextCluster         lda       #F.Cluster-128 ; load A from #F.Cluster-128
                    lbsr      LoadField ; call helper LoadField
                    bsr       ValidCluster ; call helper ValidCluster
                    bcs       nextret@  ; branch on carry or error nextret@
                    bsr       FatEntry  ; call helper FatEntry
                    bcs       nextret@  ; branch on carry or error nextret@
                    lbsr      LE32      ; call helper LE32
                    lda       F.Val,u   ; load A from F.Val,u
                    anda      #15       ; mask A with #15
                    sta       F.Val,u   ; save A in F.Val,u
                    ldd       F.Val,u   ; load D from F.Val,u
                    cmpd      #$0FFF    ; compare D with #$0FFF
                    bne       linkvalid@ ; branch when unequal or nonzero linkvalid@
                    ldd       F.Val+2,u ; load D from F.Val+2,u
                    cmpd      #$FFF8    ; compare D with #$FFF8
                    lbhs      EOFError  ; branch when unsigned higher or equal EOFError
linkvalid@          bsr       ValidCluster ; call helper ValidCluster
                    bcs       nextret@  ; branch on carry or error nextret@
                    lda       #F.Cluster-128 ; load A from #F.Cluster-128
                    lbsr      StoreField ; call helper StoreField
                    clrb                ; clear accumulator B and carry
nextret@            rts                 ; return to caller

* File/dir chain cursor with Floyd cycle detection; no cluster-number truncation.
ResetWalk           lda       #F.Start-128 ; load A from #F.Start-128
                    lbsr      LoadField ; call helper LoadField
                    lbsr      ValidCluster ; call helper ValidCluster
                    bcs       resetret@ ; branch on carry or error resetret@
                    lda       #F.Walk-128 ; load A from #F.Walk-128
                    lbsr      StoreField ; call helper StoreField
                    lda       #F.Hare-128 ; load A from #F.Hare-128
                    lbsr      StoreField ; call helper StoreField
                    clra                ; clear accumulator A and carry
                    clrb                ; clear accumulator B and carry
                    std       F.WalkIndex,u ; save D in F.WalkIndex,u
                    std       F.WalkIndex+2,u ; save D in F.WalkIndex+2,u
                    lda       #1        ; load A from #1
                    sta       F.WalkValid,u ; save A in F.WalkValid,u
resetret@           rts                 ; return to caller
Advance             ldd       #F.Walk*256+F.Cluster ; load D from #F.Walk*256+F.Cluster
                    lbsr      CopyVal   ; call helper CopyVal
                    bsr       NextCluster ; call helper NextCluster
                    bcs       advret@   ; branch on carry or error advret@
                    lda       #F.Walk-128 ; load A from #F.Walk-128
                    lbsr      StoreField ; call helper StoreField
                    lda       #F.WalkIndex-128 ; load A from #F.WalkIndex-128
                    lbsr      IncField  ; call helper IncField
                    ldd       F.Hare,u  ; load D from F.Hare,u
                    bne       harego@   ; branch when unequal or nonzero harego@
                    ldd       F.Hare+2,u ; load D from F.Hare+2,u
                    beq       advok@    ; branch when equal or zero advok@
harego@             ldd       #F.Hare*256+F.Cluster ; load D from #F.Hare*256+F.Cluster
                    lbsr      CopyVal   ; call helper CopyVal
                    ldb       #2        ; load B from #2
                    pshs      b         ; preserve b on stack
harestep@           lbsr      NextCluster ; call helper NextCluster
                    bcs       hareend@  ; branch on carry or error hareend@
                    dec       ,s        ; decrement ,s
                    bne       harestep@ ; branch when unequal or nonzero harestep@
                    leas      1,s       ; point S at 1,s
                    lda       #F.Hare-128 ; load A from #F.Hare-128
                    lbsr      StoreField ; call helper StoreField
                    leax      F.Walk,u  ; point X at F.Walk,u
                    lbsr      CompareVal ; call helper CompareVal
                    lbeq      BadMedia  ; branch when equal or zero BadMedia
advok@              clrb                ; clear accumulator B and carry
advret@             rts                 ; return to caller
hareend@            leas      1,s       ; point S at 1,s
                    cmpb      #E$EOF    ; compare B with #E$EOF
                    bne       advfail@  ; branch when unequal or nonzero advfail@
                    clra                ; clear accumulator A and carry
                    clrb                ; clear accumulator B and carry
                    std       F.Hare,u  ; save D in F.Hare,u
                    std       F.Hare+2,u ; save D in F.Hare+2,u
                    rts                 ; return to caller
advfail@            coma                ; complement A and set carry
                    rts                 ; return to caller

* Offset is logical byte offset within Start's chain. Return X=byte in data.
Locate              lda       #F.Offset-128 ; load A from #F.Offset-128
                    lbsr      LoadField ; call helper LoadField
                    ldb       F.Shift,u ; load B from F.Shift,u
                    addb      #9        ; add to B: #9
                    lbsr      ShiftRight ; call helper ShiftRight
                    lda       #F.Target-128 ; load A from #F.Target-128
                    lbsr      StoreField ; call helper StoreField
                    tst       F.WalkValid,u ; test F.WalkValid,u
                    beq       restart@  ; branch when equal or zero restart@
                    leax      F.WalkIndex,u ; point X at F.WalkIndex,u
                    lbsr      CompareVal ; call helper CompareVal
                    bhs       locatewalk@ ; branch when unsigned higher or equal locatewalk@
restart@            lbsr      ResetWalk ; call helper ResetWalk
                    bcs       locret@   ; branch on carry or error locret@
locatewalk@         lda       #F.Target-128 ; load A from #F.Target-128
                    lbsr      LoadField ; call helper LoadField
                    leax      F.WalkIndex,u ; point X at F.WalkIndex,u
                    lbsr      CompareVal ; call helper CompareVal
                    beq       locsector@ ; branch when equal or zero locsector@
                    lbsr      Advance   ; call helper Advance
                    bcs       locret@   ; branch on carry or error locret@
                    bra       locatewalk@ ; continue unconditionally locatewalk@
locsector@          lda       #F.Walk-128 ; load A from #F.Walk-128
                    lbsr      LoadField ; call helper LoadField
                    lbsr      DecVal    ; call helper DecVal
                    lbsr      DecVal    ; call helper DecVal
                    ldb       F.Shift,u ; load B from F.Shift,u
                    beq       locbase@  ; branch when equal or zero locbase@
                    lbsr      ShiftLeft ; call helper ShiftLeft
                    bcs       locret@   ; branch on carry or error locret@
locbase@            leax      F.DataStart,u ; point X at F.DataStart,u
                    lbsr      AddBase   ; call helper AddBase
                    bcs       locret@   ; branch on carry or error locret@
                    lda       #F.Temp-128 ; load A from #F.Temp-128
                    lbsr      StoreField ; call helper StoreField
                    lda       #F.Offset-128 ; load A from #F.Offset-128
                    lbsr      LoadField ; call helper LoadField
                    ldb       #9        ; load B from #9
                    lbsr      ShiftRight ; call helper ShiftRight
                    lda       F.SPC,u   ; load A from F.SPC,u
                    deca                ; decrement accumulator A
                    anda      F.Val+3,u ; mask A with F.Val+3,u
                    clrb                ; clear accumulator B and carry
                    stb       F.Val,u   ; save B in F.Val,u
                    stb       F.Val+1,u ; save B in F.Val+1,u
                    stb       F.Val+2,u ; save B in F.Val+2,u
                    sta       F.Val+3,u ; save A in F.Val+3,u
                    leax      F.Temp,u  ; point X at F.Temp,u
                    lbsr      AddBase   ; call helper AddBase
                    bcs       locret@   ; branch on carry or error locret@
                    lbsr      ReadData  ; call helper ReadData
                    bcs       locret@   ; branch on carry or error locret@
                    ldd       F.Offset+2,u ; load D from F.Offset+2,u
                    anda      #1        ; mask A with #1
                    leax      d,x       ; point X at d,x
                    clrb                ; clear accumulator B and carry
locret@             rts                 ; return to caller

CreateImpl          lda       #1        ; load A from #1
                    bra       OpenBegin ; continue unconditionally OpenBegin
OpenImpl            clra                ; clear accumulator A and carry
OpenBegin           pshs      a,x,y,u   ; preserve a,x,y,u on stack
                    clr       PD.BUF,y  ; clear PD.BUF,y
                    clr       PD.BUF+1,y ; clear PD.BUF+1,y
                    lda       PD.MOD,y  ; load A from PD.MOD,y
                    bita      #READ.+WRITE.+EXEC. ; test A against #READ.+WRITE.+EXEC.
                    lbeq      openaccess ; branch when equal or zero openaccess
                    ldd       #F.Len    ; load D from #F.Len
                    os9       F$SRqMem  ; invoke OS-9 F$SRqMem service
                    lbcs      openreturn ; branch on carry or error openreturn
                    stu       PD.BUF,y  ; save U in PD.BUF,y
                    tfr       u,x       ; transfer registers u,x
                    ldd       #F.Len    ; load D from #F.Len
openzero@           clr       ,x+       ; clear ,x+
                    subd      #1        ; subtract from D: #1
                    bne       openzero@ ; branch when unequal or nonzero openzero@
                    lda       ,s        ; load A from ,s
                    cmpa      #3        ; compare A with #3
                    bne       openkind@ ; branch when unequal or nonzero openkind@
                    inc       F.Deleting,u ; increment F.Deleting,u
                    clra                ; clear accumulator A and carry
openkind@           sta       F.Creating,u ; save A in F.Creating,u
                    sty       F.Owner,u ; save Y in F.Owner,u
                    ldx       5,s       ; load X from 5,s
                    stx       F.Regs,u  ; save X in F.Regs,u
                    lbsr      Mount     ; call helper Mount
                    lbcs      openfailed ; branch on carry or error openfailed
                    lda       PD.MOD,y  ; load A from PD.MOD,y
                    bita      #WRITE.   ; test A against #WRITE.
                    beq       openread@ ; branch when equal or zero openread@
                    lbsr      Writable  ; call helper Writable
                    lbcs      openfailed ; branch on carry or error openfailed
openread@           lbsr      CopyPath  ; call helper CopyPath
                    bcs       openfailed ; branch on carry or error openfailed
                    lbsr      Resolve   ; call helper Resolve
                    bcs       openfailed ; branch on carry or error openfailed
                    tst       F.Creating,u ; test F.Creating,u
                    beq       openexisting@ ; branch when equal or zero openexisting@
                    ldb       #E$CEF    ; load B from #E$CEF
                    bra       openfailed ; continue unconditionally openfailed
openexisting@       lda       F.Entry+11,u ; load A from F.Entry+11,u
                    anda      #$10      ; mask A with #$10
                    beq       openfile@ ; branch when equal or zero openfile@
                    lda       PD.MOD,y  ; load A from PD.MOD,y
                    bita      #DIR.     ; test A against #DIR.
                    bne       opendir@  ; branch when unequal or nonzero opendir@
                    tst       F.Deleting,u ; test F.Deleting,u
                    beq       openaccessfree ; branch when equal or zero openaccessfree
opendir@            lbsr      DirectorySize ; call helper DirectorySize
                    bcs       openfailed ; branch on carry or error openfailed
                    bra       openok@   ; continue unconditionally openok@
openfile@           lda       PD.MOD,y  ; load A from PD.MOD,y
                    bita      #DIR.     ; test A against #DIR.
                    bne       openaccessfree ; branch when unequal or nonzero openaccessfree
                    ldd       F.Size,u  ; load D from F.Size,u
                    bne       openvalid@ ; branch when unequal or nonzero openvalid@
                    ldd       F.Size+2,u ; load D from F.Size+2,u
                    beq       openok@   ; branch when equal or zero openok@
openvalid@          lda       #F.Start-128 ; load A from #F.Start-128
                    lbsr      LoadField ; call helper LoadField
                    lbsr      ValidCluster ; call helper ValidCluster
                    bcs       openfailed ; branch on carry or error openfailed
openok@             lda       PD.MOD,y  ; load A from PD.MOD,y
                    bita      #WRITE.   ; test A against #WRITE.
                    beq       openshare@ ; branch when equal or zero openshare@
                    lda       F.Entry+11,u ; load A from F.Entry+11,u
                    bita      #$10      ; test A against #$10
                    beq       openwritefile@ ; branch when equal or zero openwritefile@
* Writable directory handles authorize metadata services, never raw writes.
                    bita      #1        ; test A against #1
                    bne       openaccessfree ; branch when unequal or nonzero openaccessfree
                    bra       openshare@ ; continue unconditionally openshare@
openwritefile@      lbsr      CanWriteFile ; call helper CanWriteFile
                    bcs       openfailed ; branch on carry or error openfailed
openshare@          lbsr      RegisterPath ; call helper RegisterPath
                    bcs       openfailed ; branch on carry or error openfailed
                    ldb       F.Entry+11,u ; load B from F.Entry+11,u
                    lbsr      Attributes ; call helper Attributes
                    sta       PD.ATT,y  ; save A in PD.ATT,y
                    clr       F.WalkValid,u ; clear F.WalkValid,u
                    clrb                ; clear accumulator B and carry
openreturn          leas      1,s       ; point S at 1,s
                    puls      x,y,u,pc  ; restore x,y,u,pc from stack
openaccess          ldb       #E$FNA    ; load B from #E$FNA
                    coma                ; complement A and set carry
                    bra       openreturn ; continue unconditionally openreturn
openaccessfree      ldb       #E$FNA    ; load B from #E$FNA
                    coma                ; complement A and set carry
openfailed          pshs      b         ; preserve b on stack
                    lbsr      FreePath  ; call helper FreePath
                    puls      b         ; restore b from stack
                    coma                ; complement A and set carry
                    bra       openreturn ; continue unconditionally openreturn

* Copy caller path to private memory. OS-9 high-bit terminators are accepted.
CopyPath            pshs      y         ; preserve y on stack
                    ldx       F.Regs,u  ; load X from F.Regs,u
                    ldx       R$X,x     ; load X from R$X,x
                    leay      F.Path,u  ; point Y at F.Path,u
                    pshs      y         ; preserve y on stack
copychar@           pshs      y         ; preserve y on stack
                  IFGT    Level-1 ; conditional assembly
                    ldy       <D.Proc   ; load Y from <D.Proc
                    ldb       P$Task,y  ; load B from P$Task,y
                    os9       F$LDABX   ; invoke OS-9 F$LDABX service
                  ELSE            ; conditional assembly
                    lda       ,x        ; load A from ,x
                  ENDC            ; conditional assembly
                    puls      y         ; restore y from stack
                    tsta                ; test accumulator A
                    beq       pathdone@ ; branch when equal or zero pathdone@
                    cmpa      #C$CR     ; compare A with #C$CR
                    beq       pathdone@ ; branch when equal or zero pathdone@
                    cmpa      #C$SPAC   ; compare A with #C$SPAC
                    beq       pathdone@ ; branch when equal or zero pathdone@
                    cmpa      #',       ; compare A with #',
                    beq       pathdone@ ; branch when equal or zero pathdone@
                    pshs      a         ; preserve a on stack
                    anda      #$7F      ; mask A with #$7F
                    sta       ,y+       ; save A in ,y+
                    leax      1,x       ; point X at 1,x
                    tfr       y,d       ; transfer registers y,d
                    subd      1,s                compare copied length (saved char is atop pointer)
                    cmpd      #255      ; compare D with #255
                    bhi       pathtoolong@ ; branch when unsigned higher pathtoolong@
                    puls      a         ; restore a from stack
                    tsta                ; test accumulator A
                    bpl       copychar@ ; branch when nonnegative copychar@
pathdone@           clr       ,y        ; clear ,y
* Return the next argument, skipping OS-9 command-line separators.
pathskip@           equ       *         ; define constant or offset
                  IFGT    Level-1 ; conditional assembly
                    ldy       <D.Proc   ; load Y from <D.Proc
                    ldb       P$Task,y  ; load B from P$Task,y
                    os9       F$LDABX   ; invoke OS-9 F$LDABX service
                  ELSE            ; conditional assembly
                    lda       ,x        ; load A from ,x
                  ENDC            ; conditional assembly
                    cmpa      #C$SPAC   ; compare A with #C$SPAC
                    beq       pathadvance@ ; branch when equal or zero pathadvance@
                    cmpa      #',       ; compare A with #',
                    bne       pathreturn@ ; branch when unequal or nonzero pathreturn@
pathadvance@        leax      1,x       ; point X at 1,x
                    bra       pathskip@ ; continue unconditionally pathskip@
pathreturn@         leas      2,s       ; point S at 2,s
                    ldy       F.Regs,u  ; load Y from F.Regs,u
                    stx       R$X,y     ; save X in R$X,y
                    clrb                ; clear accumulator B and carry
                    puls      y,pc      ; restore y,pc from stack
pathtoolong@        leas      3,s       ; point S at 3,s
                    puls      y         ; restore y from stack
                    lbra      PathError ; continue unconditionally PathError

* Starting directory: absolute paths skip the device name; relative paths
* use all four file-manager bytes in P$DIO (CWD) or P$DIO+6 (CXD).
Resolve             ldd       #F.Root*256+F.Start ; load D from #F.Root*256+F.Start
                    lbsr      CopyVal   ; call helper CopyVal
                    lda       #$10      ; load A from #$10
                    sta       F.Entry+11,u ; save A in F.Entry+11,u
                    leax      F.Path,u  ; point X at F.Path,u
                    lda       ,x        ; load A from ,x
                    lbeq      resolvebad@ ; branch when equal or zero resolvebad@
                    cmpa      #'/       ; compare A with #'/
                    beq       skipdevice@ ; branch when equal or zero skipdevice@
                    pshs      x         ; preserve x on stack
                    ldx       <D.Proc   ; load X from <D.Proc
                    leax      P$DIO,x   ; point X at P$DIO,x
                    lda       PD.MOD,y  ; load A from PD.MOD,y
                    bita      #EXEC.    ; test A against #EXEC.
                    beq       cwd@      ; branch when equal or zero cwd@
                    leax      6,x       ; point X at 6,x
cwd@                ldd       ,x        ; load D from ,x
                    cmpd      PD.DEV,y  ; compare D with PD.DEV,y
                    bne       cwdroot@  ; branch when unequal or nonzero cwdroot@
                    leax      2,x       ; point X at 2,x
                    lbsr      LoadVal   ; call helper LoadVal
                    ldd       F.Val,u   ; load D from F.Val,u
                    bne       cwdvalid@ ; branch when unequal or nonzero cwdvalid@
                    ldd       F.Val+2,u ; load D from F.Val+2,u
                    beq       cwdroot@  ; branch when equal or zero cwdroot@
cwdvalid@           lbsr      ValidCluster ; call helper ValidCluster
                    bcs       cwderror@ ; branch on carry or error cwderror@
                    lda       #F.Start-128 ; load A from #F.Start-128
                    lbsr      StoreField ; call helper StoreField
cwdroot@            puls      x         ; restore x from stack
                    bra       component@ ; continue unconditionally component@
cwderror@           leas      2,s       ; point S at 2,s
                    rts                 ; return to caller
skipdevice@         leax      1,x       ; point X at 1,x
skipdevchar@        lda       ,x+       ; load A from ,x+
                    beq       resolveroot@ ; branch when equal or zero resolveroot@
                    cmpa      #'/       ; compare A with #'/
                    bne       skipdevchar@ ; branch when unequal or nonzero skipdevchar@
component@          lda       ,x        ; load A from ,x
                    beq       resolveroot@ ; branch when equal or zero resolveroot@
                    cmpa      #'/       ; compare A with #'/
                    bne       parsename@ ; branch when unequal or nonzero parsename@
                    leax      1,x       ; point X at 1,x
                    bra       component@ ; continue unconditionally component@
parsename@          stx       F.Cursor,u ; save X in F.Cursor,u
                    bsr       ParseName ; call helper ParseName
                    bcs       resolveret@ ; branch on carry or error resolveret@
                    tst       F.Dots,u  ; test F.Dots,u
                    beq       ordinary@ ; branch when equal or zero ordinary@
                    dec       F.Dots,u  ; decrement F.Dots,u
                    beq       aftercomponent@ ; branch when equal or zero aftercomponent@
parentloop@         lda       #F.Start-128 ; load A from #F.Start-128
                    lbsr      LoadField ; call helper LoadField
                    leax      F.Root,u  ; point X at F.Root,u
                    lbsr      CompareVal ; call helper CompareVal
                    beq       parentdone@ ; branch when equal or zero parentdone@
                    lbsr      Lookup    ; call helper Lookup
                    bcs       resolveret@ ; branch on carry or error resolveret@
parentdone@         dec       F.Dots,u  ; decrement F.Dots,u
                    bne       parentloop@ ; branch when unequal or nonzero parentloop@
                    bra       aftercomponent@ ; continue unconditionally aftercomponent@
ordinary@           lbsr      Lookup    ; call helper Lookup
                    bcc       aftercomponent@ ; branch with carry clear aftercomponent@
                    cmpb      #E$PNNF   ; compare B with #E$PNNF
                    bne       resolverefail@ ; branch when unequal or nonzero resolverefail@
                    tst       F.Creating,u ; test F.Creating,u
                    beq       resolverefail@ ; branch when equal or zero resolverefail@
                    ldx       F.Cursor,u ; load X from F.Cursor,u
                    tst       ,x        ; test ,x
                    bne       resolverefail@ ; branch when unequal or nonzero resolverefail@
                    lbsr      CreateEntry ; call helper CreateEntry
                    bra       resolveret@ ; continue unconditionally resolveret@
resolverefail@      coma                ; complement A and set carry
                    rts                 ; return to caller
aftercomponent@     ldx       F.Cursor,u ; load X from F.Cursor,u
                    lda       ,x        ; load A from ,x
                    beq       resolved@ ; branch when equal or zero resolved@
                    lda       F.Entry+11,u ; load A from F.Entry+11,u
                    bita      #$10      ; test A against #$10
                    lbeq      NotFound  ; branch when equal or zero NotFound
                    bra       component@ ; continue unconditionally component@
resolveroot@        clrb                ; clear accumulator B and carry
                    rts                 ; return to caller
resolved@           clrb                ; clear accumulator B and carry
resolveret@         rts                 ; return to caller
resolvebad@         lbra      PathError ; continue unconditionally PathError

* ASCII 8.3 aliases, case insensitive. Dot-only names use OS-9 ascent rules.
ParseName           pshs      y         ; preserve y on stack
                    leay      F.Name,u  ; point Y at F.Name,u
                    ldb       #11       ; load B from #11
                    lda       #C$SPAC   ; load A from #C$SPAC
padname@            sta       ,y+       ; save A in ,y+
                    decb                ; decrement accumulator B
                    bne       padname@  ; branch when unequal or nonzero padname@
                    clr       F.Dots,u  ; clear F.Dots,u
                    ldx       F.Cursor,u ; load X from F.Cursor,u
dotcount@           lda       ,x+       ; load A from ,x+
                    cmpa      #'.       ; compare A with #'.
                    bne       dotend@   ; branch when unequal or nonzero dotend@
                    inc       F.Dots,u  ; increment F.Dots,u
                    bra       dotcount@ ; continue unconditionally dotcount@
dotend@             tsta                ; test accumulator A
                    beq       alldots@  ; branch when equal or zero alldots@
                    cmpa      #'/       ; compare A with #'/
                    beq       alldots@  ; branch when equal or zero alldots@
normalname@         clr       F.Dots,u  ; clear F.Dots,u
                    ldx       F.Cursor,u ; load X from F.Cursor,u
                    leay      F.Name,u  ; point Y at F.Name,u
                    ldb       #8        ; load B from #8
basename@           lda       ,x+       ; load A from ,x+
                    beq       nameterm@ ; branch when equal or zero nameterm@
                    cmpa      #'/       ; compare A with #'/
                    beq       nameterm@ ; branch when equal or zero nameterm@
                    cmpa      #'.       ; compare A with #'.
                    beq       extension@ ; branch when equal or zero extension@
                    bsr       NameChar  ; call helper NameChar
                    bcs       namebad@  ; branch on carry or error namebad@
                    tstb                ; test accumulator B
                    beq       namebad@  ; branch when equal or zero namebad@
                    sta       ,y+       ; save A in ,y+
                    decb                ; decrement accumulator B
                    bra       basename@ ; continue unconditionally basename@
extension@          cmpb      #8        ; compare B with #8
                    beq       namebad@  ; branch when equal or zero namebad@
                    leay      F.Name+8,u ; point Y at F.Name+8,u
                    ldb       #3        ; load B from #3
extchar@            lda       ,x+       ; load A from ,x+
                    beq       nameterm@ ; branch when equal or zero nameterm@
                    cmpa      #'/       ; compare A with #'/
                    beq       nameterm@ ; branch when equal or zero nameterm@
                    bsr       NameChar  ; call helper NameChar
                    bcs       namebad@  ; branch on carry or error namebad@
                    tstb                ; test accumulator B
                    beq       namebad@  ; branch when equal or zero namebad@
                    sta       ,y+       ; save A in ,y+
                    decb                ; decrement accumulator B
                    bra       extchar@  ; continue unconditionally extchar@
alldots@            tst       F.Dots,u  ; test F.Dots,u
                    beq       normalname@ ; branch when equal or zero normalname@
                    lda       #'.       ; load A from #'.
                    sta       F.Name,u  ; save A in F.Name,u
                    sta       F.Name+1,u ; save A in F.Name+1,u
nameterm@           leax      -1,x      ; point X at -1,x
                    stx       F.Cursor,u ; save X in F.Cursor,u
                    clrb                ; clear accumulator B and carry
                    puls      y,pc      ; restore y,pc from stack
namebad@            puls      y         ; restore y from stack
                    lbra      PathError ; continue unconditionally PathError
NameChar            cmpa      #'a       ; compare A with #'a
                    blo       charcheck@ ; branch when unsigned lower charcheck@
                    cmpa      #'z       ; compare A with #'z
                    bhi       charcheck@ ; branch when unsigned higher charcheck@
                    suba      #32       ; subtract from A: #32
charcheck@          cmpa      #33       ; compare A with #33
                    blo       charbad@  ; branch when unsigned lower charbad@
                    cmpa      #127      ; compare A with #127
                    bhs       charbad@  ; branch when unsigned higher or equal charbad@
                    pshs      x         ; preserve x on stack
                    leax      IllegalChars,pcr ; point X at IllegalChars,pcr
charloop@           tst       ,x        ; test ,x
                    beq       charok@   ; branch when equal or zero charok@
                    cmpa      ,x+       ; compare A with ,x+
                    bne       charloop@ ; branch when unequal or nonzero charloop@
                    puls      x         ; restore x from stack
charbad@            coma                ; complement A and set carry
                    rts                 ; return to caller
charok@             puls      x         ; restore x from stack
                    andcc     #$FE      ; clear selected CC bits with #$FE
                    rts                 ; return to caller
IllegalChars        fcc       /"*+,.:;<=>?[\]|/
                    fcb       0         ; emit byte data

* Scan one directory for Name; all addresses and offsets are 32 bits.
Lookup              clr       F.HasLFN,u ; clear F.HasLFN,u
                    clr       F.WalkValid,u ; clear F.WalkValid,u
                    clra                ; clear accumulator A and carry
                    clrb                ; clear accumulator B and carry
                    std       F.Scan,u  ; save D in F.Scan,u
                    std       F.Scan+2,u ; save D in F.Scan+2,u
lookloop@           ldd       #F.Scan*256+F.Offset ; load D from #F.Scan*256+F.Offset
                    lbsr      CopyVal   ; call helper CopyVal
                    lbsr      Locate    ; call helper Locate
                    bcs       lookerror@ ; branch on carry or error lookerror@
                    lda       ,x        ; load A from ,x
                    beq       lookmissing@ ; branch when equal or zero lookmissing@
                    cmpa      #$E5      ; compare A with #$E5
                    beq       lookclear@ ; branch when equal or zero lookclear@
                    lda       11,x      ; load A from 11,x
                    cmpa      #$0F      ; compare A with #$0F
                    bne       lookattr@ ; branch when unequal or nonzero lookattr@
                    lda       13,x      ; checksum binds LFN slots to their short alias
                    sta       F.Zero,u  ; temporary checksum while scanning
                    inc       F.HasLFN,u ; preceding LFN slot present
                    bra       looknext@ ; continue unconditionally looknext@
lookattr@           bita      #8        ; test A against #8
                    bne       lookclear@ ; branch when unequal or nonzero lookclear@
                    pshs      x,y       ; preserve x,y on stack
                    leay      F.Name,u  ; point Y at F.Name,u
                    ldb       #11       ; load B from #11
lookcompare@        lda       ,x+       ; load A from ,x+
                    cmpa      ,y+       ; compare A with ,y+
                    bne       looknomatch@ ; branch when unequal or nonzero looknomatch@
                    decb                ; decrement accumulator B
                    bne       lookcompare@ ; branch when unequal or nonzero lookcompare@
                    puls      x,y       ; restore x,y from stack
                    bsr       CheckLFN  ; ignore orphaned slots with a different checksum
                    lbsr      EntryLocation ; call helper EntryLocation
                    pshs      x         ; retain the matched on-disk entry pointer
                    ldd       #F.Start*256+F.Parent ; retain containing directory before adopting child
                    lbsr      CopyVal   ; record parent cluster for deletion
                    puls      x         ; adoptEntry still consumes the matched slot
                    bsr       AdoptEntry ; call helper AdoptEntry
                    rts                 ; return to caller
looknomatch@        puls      x,y       ; restore x,y from stack
lookclear@          clr       F.HasLFN,u ; clear F.HasLFN,u
looknext@           bsr       ScanNext  ; call helper ScanNext
                    bcc       lookloop@ ; branch with carry clear lookloop@
                    rts                 ; return to caller
lookerror@          cmpb      #E$EOF    ; compare B with #E$EOF
                    bne       lookio@   ; branch when unequal or nonzero lookio@
lookmissing@        lbra      NotFound  ; continue unconditionally NotFound
lookio@             coma                ; complement A and set carry
                    rts                 ; return to caller
* Validate the FAT short-name checksum before treating an alias as LFN-backed.
CheckLFN            tst       F.HasLFN,u ; any preceding long-name slots?
                    beq       lfnret@   ; plain short name
                    pshs      b,x       ; preserve entry pointer and counter
                    clra                ; initial checksum
                    ldb       #11       ; padded short-name bytes
lfnsum@             lsra                ; rotate checksum right
                    bcc       lfnadd@   ; zero rotated high bit
                    ora       #$80      ; wrap low bit into high bit
lfnadd@             adda      ,x+       ; accumulate alias byte
                    decb                ; count eleven bytes
                    bne       lfnsum@   ; finish checksum
                    cmpa      F.Zero,u  ; preceding LFN checksum
                    beq       lfnvalid@ ; matching alias remains protected
                    clr       F.HasLFN,u ; orphan does not own this alias
lfnvalid@           puls      b,x       ; restore caller state
lfnret@             rts                 ; return
ScanNext            lda       #F.Scan-128 ; load A from #F.Scan-128
                    lbsr      LoadField ; call helper LoadField
                    ldd       #32       ; load D from #32
                    lbsr      AddWord   ; call helper AddWord
                    lbcs      BadMedia  ; branch on carry or error BadMedia
                    lda       #F.Scan-128 ; load A from #F.Scan-128
                    lbsr      StoreField ; call helper StoreField
                    clrb                ; clear accumulator B and carry
                    rts                 ; return to caller
AdoptEntry          pshs      y         ; preserve y on stack
                    leay      F.Entry,u ; point Y at F.Entry,u
                    ldb       #32       ; load B from #32
                    lbsr      CopyBytes ; call helper CopyBytes
                    puls      y         ; restore y from stack
                    leax      F.Entry+28,u ; point X at F.Entry+28,u
                    lbsr      LE32      ; call helper LE32
                    lda       #F.Size-128 ; load A from #F.Size-128
                    lbsr      StoreField ; call helper StoreField
                    lda       F.Entry+21,u ; load A from F.Entry+21,u
                    anda      #15       ; mask A with #15
                    ldb       F.Entry+20,u ; load B from F.Entry+20,u
                    std       F.Val,u   ; save D in F.Val,u
                    lda       F.Entry+27,u ; load A from F.Entry+27,u
                    ldb       F.Entry+26,u ; load B from F.Entry+26,u
                    std       F.Val+2,u ; save D in F.Val+2,u
                    lda       F.Entry+11,u ; load A from F.Entry+11,u
                    bita      #$10      ; test A against #$10
                    beq       adoptstart@ ; branch when equal or zero adoptstart@
                    ldd       F.Val,u   ; load D from F.Val,u
                    bne       adoptvalid@ ; branch when unequal or nonzero adoptvalid@
                    ldd       F.Val+2,u ; load D from F.Val+2,u
                    bne       adoptvalid@ ; branch when unequal or nonzero adoptvalid@
* Only the actual '..' entry is allowed to encode the root as cluster zero.
                    ldd       F.Entry,u ; load D from F.Entry,u
                    cmpd      #$2E2E    ; compare D with #$2E2E
                    lbne      BadMedia  ; branch when unequal or nonzero BadMedia
                    lda       #F.Root-128 ; load A from #F.Root-128
                    lbsr      LoadField ; call helper LoadField
adoptvalid@         lbsr      ValidCluster ; call helper ValidCluster
                    bcs       adoptret@ ; branch on carry or error adoptret@
adoptstart@         lda       #F.Start-128 ; load A from #F.Start-128
                    lbsr      StoreField ; call helper StoreField
                    clr       F.WalkValid,u ; clear F.WalkValid,u
                    clrb                ; clear accumulator B and carry
adoptret@           rts                 ; return to caller

* Directory view contains two synthetic dot records followed by physical slots.
* Deleted/LFN/volume/disk dot slots become zero records, preserving cookie offsets.
DirectorySize       clr       F.WalkValid,u ; clear F.WalkValid,u
                    clra                ; clear accumulator A and carry
                    clrb                ; clear accumulator B and carry
                    std       F.Scan,u  ; save D in F.Scan,u
                    std       F.Scan+2,u ; save D in F.Scan+2,u
dirsizewalk@        ldd       #F.Scan*256+F.Offset ; load D from #F.Scan*256+F.Offset
                    lbsr      CopyVal   ; call helper CopyVal
                    lbsr      Locate    ; call helper Locate
                    bcs       dirsizeend@ ; branch on carry or error dirsizeend@
                    tst       ,x        ; test ,x
                    beq       dirsizefound@ ; branch when equal or zero dirsizefound@
                    lbsr      ScanNext  ; call helper ScanNext
                    bcs       dirsizeret@ ; branch on carry or error dirsizeret@
                    bra       dirsizewalk@ ; continue unconditionally dirsizewalk@
dirsizeend@         cmpb      #E$EOF    ; compare B with #E$EOF
                    bne       dirsizeerror@ ; branch when unequal or nonzero dirsizeerror@
dirsizefound@       lda       #F.Scan-128 ; load A from #F.Scan-128
                    lbsr      LoadField ; call helper LoadField
                    ldd       #64       ; load D from #64
                    lbsr      AddWord   ; call helper AddWord
                    lbcs      BadMedia  ; branch on carry or error BadMedia
                    lda       #F.Size-128 ; load A from #F.Size-128
                    lbsr      StoreField ; call helper StoreField
                    clrb                ; clear accumulator B and carry
dirsizeret@         rts                 ; return to caller
dirsizeerror@       coma                ; complement A and set carry
                    rts                 ; return to caller

ChgDirImpl          pshs      x,y,u     ; preserve x,y,u on stack
                    lda       PD.MOD,y  ; load A from PD.MOD,y
                    ora       #DIR.     ; merge A with #DIR.
                    sta       PD.MOD,y  ; save A in PD.MOD,y
                    lbsr      OpenImpl  ; call helper OpenImpl
                    bcs       chgret@   ; branch on carry or error chgret@
                    ldu       PD.BUF,y  ; load U from PD.BUF,y
                    ldx       <D.Proc   ; load X from <D.Proc
                    lda       PD.MOD,y  ; load A from PD.MOD,y
                    bita      #PREAD.+PWRIT.+UPDAT. ; match IOMan data-directory mask
                    beq       chgexec@  ; branch when equal or zero chgexec@
                    ldd       F.Start,u ; load D from F.Start,u
                    std       P$DIO+2,x ; save D in P$DIO+2,x
                    ldd       F.Start+2,u ; load D from F.Start+2,u
                    std       P$DIO+4,x ; save D in P$DIO+4,x
chgexec@            lda       PD.MOD,y  ; load A from PD.MOD,y
                    bita      #EXEC.    ; test A against #EXEC.
                    beq       chgfree@  ; branch when equal or zero chgfree@
                    ldd       F.Start,u ; load D from F.Start,u
                    std       P$DIO+8,x ; save D in P$DIO+8,x
                    ldd       F.Start+2,u ; load D from F.Start+2,u
                    std       P$DIO+10,x ; save D in P$DIO+10,x
chgfree@            bsr       FreePath  ; call helper FreePath
chgret@             puls      x,y,u,pc  ; restore x,y,u,pc from stack
CloseImpl           tst       PD.CNT,y  ; test PD.CNT,y
                    bne       closeshared@ ; branch when unequal or nonzero closeshared@
                    bra       FreePath  ; continue unconditionally FreePath
closeshared@        clrb                ; clear accumulator B and carry
                    rts                 ; return to caller
FreePath            pshs      x,y,u     ; preserve x,y,u on stack
                    ldu       PD.BUF,y  ; load U from PD.BUF,y
                    beq       freeok@   ; branch when equal or zero freeok@
                    lbsr      UnregisterPath ; call helper UnregisterPath
                    clr       PD.BUF,y  ; clear PD.BUF,y
                    clr       PD.BUF+1,y ; clear PD.BUF+1,y
                    ldd       #F.Len    ; load D from #F.Len
                    os9       F$SRtMem  ; invoke OS-9 F$SRtMem service
                    puls      x,y,u,pc  ; restore x,y,u,pc from stack
freeok@             clrb                ; clear accumulator B and carry
                    puls      x,y,u,pc  ; restore x,y,u,pc from stack

SeekImpl            pshs      x,y,u     ; preserve x,y,u on stack
                    tfr       u,x       ; transfer registers u,x
                    ldu       PD.BUF,y  ; load U from PD.BUF,y
                    ldd       R$X,x     ; load D from R$X,x
                    std       F.Pos,u   ; save D in F.Pos,u
                    ldd       R$U,x     ; load D from R$U,x
                    std       F.Pos+2,u ; save D in F.Pos+2,u
                    clrb                ; clear accumulator B and carry
                    puls      x,y,u,pc  ; restore x,y,u,pc from stack

ReadImpl            clra                ; clear accumulator A and carry
                    bra       ReadCommon ; continue unconditionally ReadCommon
ReadLnImpl          lda       #1        ; load A from #1
ReadCommon          pshs      x,y,u     ; preserve x,y,u on stack
                    tfr       u,x       ; transfer registers u,x
                    ldu       PD.BUF,y  ; load U from PD.BUF,y
                    stx       F.Regs,u  ; save X in F.Regs,u
                    sta       F.Line,u  ; save A in F.Line,u
                    clr       F.Stop,u  ; clear F.Stop,u
                    ldd       R$Y,x     ; load D from R$Y,x
                    std       F.Remain,u ; save D in F.Remain,u
                    clra                ; clear accumulator A and carry
                    clrb                ; clear accumulator B and carry
                    std       R$Y,x     ; save D in R$Y,x
                    std       F.Actual,u ; save D in F.Actual,u
                    ldd       R$X,x     ; load D from R$X,x
                    std       F.Dest,u  ; save D in F.Dest,u
readloop@           ldd       F.Remain,u ; load D from F.Remain,u
                    lbeq      readsuccess@ ; branch when equal or zero readsuccess@
                    leax      F.Pos,u   ; point X at F.Pos,u
                    lbsr      LoadVal   ; call helper LoadVal
                    leax      F.Size,u  ; point X at F.Size,u
                    lbsr      CompareVal ; call helper CompareVal
                    lbhs      readeof@  ; branch when unsigned higher or equal readeof@
                    lda       F.Entry+11,u ; load A from F.Entry+11,u
                    bita      #$10      ; test A against #$10
                    bne       readdirectory@ ; branch when unequal or nonzero readdirectory@
                    lda       #F.Offset-128 ; load A from #F.Offset-128
                    lbsr      StoreField ; call helper StoreField
                    lbsr      Locate    ; call helper Locate
                    lbcs      readchainerror@ ; branch on carry or error readchainerror@
                    ldd       F.Pos+2,u ; load D from F.Pos+2,u
                    anda      #1        ; mask A with #1
                    pshs      d         ; preserve d on stack
                    ldd       #512      ; load D from #512
                    subd      ,s++      ; subtract from D: ,s++
                    bra       readlimit@ ; continue unconditionally readlimit@
readdirectory@      lbsr      DirectoryRecord ; call helper DirectoryRecord
                    lbcs      readexit@ ; branch on carry or error readexit@
                    ldb       F.Pos+3,u ; load B from F.Pos+3,u
                    andb      #31       ; mask B with #31
                    abx                 ; add unsigned B to X
                    negb                ; shift or rotate accumulator B
                    addb      #32       ; add to B: #32
                    clra                ; clear accumulator A and carry
readlimit@          cmpd      F.Remain,u ; compare D with F.Remain,u
                    bls       readfilesize@ ; branch when unsigned lower or equal readfilesize@
                    ldd       F.Remain,u ; load D from F.Remain,u
readfilesize@       std       F.Move,u  ; save D in F.Move,u
                    pshs      x         ; preserve x on stack
                    ldd       #F.Size*256+F.Temp ; load D from #F.Size*256+F.Temp
                    lbsr      CopyVal   ; call helper CopyVal
                    leax      F.Pos,u   ; point X at F.Pos,u
                    lbsr      LoadVal   ; call helper LoadVal
                    leax      F.Temp,u  ; point X at F.Temp,u
                    lbsr      SubVal    ; call helper SubVal
                    ldd       F.Temp,u  ; load D from F.Temp,u
                    bne       readscan@ ; branch when unequal or nonzero readscan@
                    ldd       F.Temp+2,u ; load D from F.Temp+2,u
                    cmpd      F.Move,u  ; compare D with F.Move,u
                    bhs       readscan@ ; branch when unsigned higher or equal readscan@
                    std       F.Move,u  ; save D in F.Move,u
readscan@           puls      x         ; restore x from stack
                    tst       F.Line,u  ; test F.Line,u
                    beq       readmove@ ; branch when equal or zero readmove@
                    pshs      x         ; preserve x on stack
                    ldd       F.Move,u  ; load D from F.Move,u
                    pshs      d         ; preserve d on stack
linescan@           lda       ,x+       ; load A from ,x+
                    cmpa      #C$CR     ; compare A with #C$CR
                    beq       linefound@ ; branch when equal or zero linefound@
                    ldd       ,s        ; load D from ,s
                    subd      #1        ; subtract from D: #1
                    std       ,s        ; save D in ,s
                    bne       linescan@ ; branch when unequal or nonzero linescan@
                    bra       lineend@  ; continue unconditionally lineend@
linefound@          ldd       F.Move,u  ; load D from F.Move,u
                    subd      ,s        ; subtract from D: ,s
                    addd      #1        ; add to D: #1
                    std       F.Move,u  ; save D in F.Move,u
                    inc       F.Stop,u  ; increment F.Stop,u
lineend@            leas      2,s       ; point S at 2,s
                    puls      x         ; restore x from stack
readmove@           bsr       MoveOut   ; call helper MoveOut
                    bcs       readexit@ ; branch on carry or error readexit@
                    ldd       F.Move,u  ; load D from F.Move,u
                    addd      F.Actual,u ; add to D: F.Actual,u
                    std       F.Actual,u ; save D in F.Actual,u
                    ldd       F.Remain,u ; load D from F.Remain,u
                    subd      F.Move,u  ; subtract from D: F.Move,u
                    std       F.Remain,u ; save D in F.Remain,u
                    ldd       F.Dest,u  ; load D from F.Dest,u
                    addd      F.Move,u  ; add to D: F.Move,u
                    std       F.Dest,u  ; save D in F.Dest,u
                    ldd       F.Move,u  ; load D from F.Move,u
                    lbsr      AddPosition ; call helper AddPosition
                    tst       F.Stop,u  ; test F.Stop,u
                    lbeq      readloop@ ; branch when equal or zero readloop@
readsuccess@        clrb                ; clear accumulator B and carry
ReadReturn
readexit@           pshs      b,cc      ; preserve b,cc on stack
                    ldx       F.Regs,u  ; load X from F.Regs,u
                    ldd       F.Actual,u ; load D from F.Actual,u
                    std       R$Y,x     ; save D in R$Y,x
                    puls      b,cc      ; restore b,cc from stack
                    puls      x,y,u,pc  ; restore x,y,u,pc from stack
readeof@            ldd       F.Actual,u ; load D from F.Actual,u
                    bne       readsuccess@ ; branch when unequal or nonzero readsuccess@
                    ldb       #E$EOF    ; load B from #E$EOF
                    coma                ; complement A and set carry
                    bra       readexit@ ; continue unconditionally readexit@
readchainerror@     cmpb      #E$EOF    ; compare B with #E$EOF
                    bne       readerror@ ; branch when unequal or nonzero readerror@
                    ldb       #E$BTyp              chain ended before file size
readerror@          coma                ; complement A and set carry
                    bra       readexit@ ; continue unconditionally readexit@

* Caller address/count are F.Dest/F.Move; X is the system buffer.
* Share the pointer setup and transfer, swapping source/destination for MoveIn.
* Preserve X/Y/U on both success and failure; A/B are scratch/status.
MoveIn              pshs      x,y,u     ; preserve x,y,u on stack
                    bsr       MovePointers ; call helper MovePointers
                    exg       x,u       ; exchange registers x,u
                    bra       MoveBytes ; continue unconditionally MoveBytes
MoveOut             pshs      x,y,u     ; preserve x,y,u on stack
                    bsr       MovePointers ; call helper MovePointers
                  IFGT    Level-1 ; conditional assembly
                    exg       a,b       ; exchange registers a,b
                  ENDC            ; conditional assembly
MoveBytes
                  IFGT    Level-1 ; conditional assembly
                    os9       F$Move    ; invoke OS-9 F$Move service
                  ELSE            ; conditional assembly
movebyte@           cmpy      #0        ; compare Y with #0
                    beq       movedone@ ; branch when equal or zero movedone@
                    lda       ,x+       ; load A from ,x+
                    sta       ,u+       ; save A in ,u+
                    leay      -1,y      ; point Y at -1,y
                    bra       movebyte@ ; continue unconditionally movebyte@
movedone@           clrb                ; clear accumulator B and carry
                  ENDC            ; conditional assembly
                    puls      x,y,u,pc  ; restore x,y,u,pc from stack
MovePointers
                  IFGT    Level-1 ; conditional assembly
                    ldy       <D.Proc   ; load Y from <D.Proc
                    lda       P$Task,y  ; load A from P$Task,y
                    ldb       <D.SysTsk ; load B from <D.SysTsk
                  ENDC            ; conditional assembly
                    ldy       F.Move,u  ; load Y from F.Move,u
                    ldu       F.Dest,u  ; load U from F.Dest,u
                    rts                 ; return to caller

* Build a stable OS-9 directory record at Pos. Cookie = physical slot + 1,
* scoped to this open directory, not a truncated FAT cluster or disk address.
DirectoryRecord     leax      F.Record,u ; point X at F.Record,u
                    ldb       #32       ; load B from #32
recordzero@         clr       ,x+       ; clear ,x+
                    decb                ; decrement accumulator B
                    bne       recordzero@ ; branch when unequal or nonzero recordzero@
                    leax      F.Pos,u   ; point X at F.Pos,u
                    lbsr      LoadVal   ; call helper LoadVal
                    ldd       F.Val,u   ; load D from F.Val,u
                    bne       recordraw@ ; branch when unequal or nonzero recordraw@
                    ldd       F.Val+2,u ; load D from F.Val+2,u
                    cmpd      #64       ; compare D with #64
                    bhs       recordraw@ ; branch when unsigned higher or equal recordraw@
                    leax      F.Record,u ; point X at F.Record,u
                    cmpd      #32       ; compare D with #32
                    bhs       recorddot@ ; branch when unsigned higher or equal recorddot@
                    lda       #'.       ; load A from #'.
                    sta       ,x        ; save A in ,x
                    lda       #'.+$80   ; load A from #'.+$80
                    sta       1,x       ; save A in 1,x
                    clrb                ; clear accumulator B and carry
                    rts                 ; return to caller
recorddot@          lda       #'.+$80   ; load A from #'.+$80
                    sta       ,x        ; save A in ,x
                    clrb                ; clear accumulator B and carry
                    rts                 ; return to caller
recordraw@          ldd       F.Val+2,u ; load D from F.Val+2,u
                    subd      #64       ; subtract from D: #64
                    std       F.Val+2,u ; save D in F.Val+2,u
                    ldd       F.Val,u   ; load D from F.Val,u
                    sbcb      #0        ; subtract from B with borrow: #0
                    sbca      #0        ; subtract from A with borrow: #0
                    std       F.Val,u   ; save D in F.Val,u
                    lda       F.Val+3,u ; load A from F.Val+3,u
                    anda      #$E0      ; mask A with #$E0
                    sta       F.Val+3,u ; save A in F.Val+3,u
                    lda       #F.Offset-128 ; load A from #F.Offset-128
                    lbsr      StoreField ; call helper StoreField
                    ldb       #5        ; load B from #5
                    lbsr      ShiftRight ; call helper ShiftRight
                    lbsr      IncVal    ; call helper IncVal
                    tst       F.Val,u   ; test F.Val,u
                    lbne      BadMedia             cookie must fit SS.FDInf's 24 bits
                    lda       #F.Cookie-128 ; load A from #F.Cookie-128
                    lbsr      StoreField ; call helper StoreField
                    lbsr      Locate    ; call helper Locate
                    bcs       recordret@ ; branch on carry or error recordret@
                    lda       ,x        ; load A from ,x
                    beq       recordblank@ ; branch when equal or zero recordblank@
                    cmpa      #$E5      ; compare A with #$E5
                    beq       recordblank@ ; branch when equal or zero recordblank@
                    cmpa      #'.       ; compare A with #'.
                    beq       recordblank@ ; branch when equal or zero recordblank@
                    lda       11,x      ; load A from 11,x
                    bita      #8        ; test A against #8
                    bne       recordblank@ ; branch when unequal or nonzero recordblank@
                    pshs      y         ; preserve y on stack
                    leay      F.Record,u ; point Y at F.Record,u
                    ldb       #8        ; load B from #8
recordbase@         lda       ,x+       ; load A from ,x+
                    cmpa      #5        ; fat escapes leading $E5 as $05
                    bne       recordascii@ ; ordinary name byte
                    lda       #$E5      ; decode escaped name byte
recordascii@        bsr       RecordChar ; map unsupported codepage bytes safely
                    cmpa      #C$SPAC   ; compare A with #C$SPAC
                    beq       recordbaseskip@ ; branch when equal or zero recordbaseskip@
                    sta       ,y+       ; save A in ,y+
recordbaseskip@     decb                ; decrement accumulator B
                    bne       recordbase@ ; branch when unequal or nonzero recordbase@
                    lda       ,x        ; load A from ,x
                    cmpa      #C$SPAC   ; compare A with #C$SPAC
                    beq       recordnameend@ ; branch when equal or zero recordnameend@
                    lda       #'.       ; load A from #'.
                    sta       ,y+       ; save A in ,y+
                    ldb       #3        ; load B from #3
recordext@          lda       ,x+       ; load A from ,x+
                    bsr       RecordChar ; never emit premature OS-9 high-bit terminators
                    cmpa      #C$SPAC   ; compare A with #C$SPAC
                    beq       recordextskip@ ; branch when equal or zero recordextskip@
                    sta       ,y+       ; save A in ,y+
recordextskip@      decb                ; decrement accumulator B
                    bne       recordext@ ; branch when unequal or nonzero recordext@
recordnameend@      lda       -1,y      ; load A from -1,y
                    ora       #$80      ; merge A with #$80
                    sta       -1,y      ; save A in -1,y
                    puls      y         ; restore y from stack
                    lda       F.Cookie+1,u ; load A from F.Cookie+1,u
                    sta       F.Record+29,u ; save A in F.Record+29,u
                    ldd       F.Cookie+2,u ; load D from F.Cookie+2,u
                    std       F.Record+30,u ; save D in F.Record+30,u
recordblank@        leax      F.Record,u ; point X at F.Record,u
                    clrb                ; clear accumulator B and carry
recordret@          rts                 ; return to caller

* OS-9 uses bit seven as the name terminator; no OEM codepage is selected.
RecordChar          cmpa      #$80      ; ascii byte is directly representable
                    blo       recordcharret@ ; retain ASCII punctuation and letters
                    lda       #'?       ; display an unsupported OEM character
recordcharret@      rts                 ; return translated display byte

GetStatImpl         pshs      x,y,u     ; preserve x,y,u on stack
                    tfr       u,x       ; transfer registers u,x
                    ldu       PD.BUF,y  ; load U from PD.BUF,y
                    stx       F.Regs,u  ; save X in F.Regs,u
                    ldb       R$B,x     ; load B from R$B,x
                    cmpb      #SS.ReadDir ; compare B with #SS.ReadDir
                    lbeq      statreaddir ; branch when equal or zero statreaddir
                    cmpb      #SS.Opt   ; compare B with #SS.Opt
                    beq       statok    ; branch when equal or zero statok
                    cmpb      #SS.DevNm ; compare B with #SS.DevNm
                    beq       statok                IOMan copies these common results
                    cmpb      #SS.Size  ; compare B with #SS.Size
                    beq       statsize  ; branch when equal or zero statsize
                    cmpb      #SS.Pos   ; compare B with #SS.Pos
                    beq       statpos   ; branch when equal or zero statpos
                    cmpb      #SS.EOF   ; compare B with #SS.EOF
                    beq       stateof   ; branch when equal or zero stateof
                    cmpb      #SS.Ready ; compare B with #SS.Ready
                    beq       statready ; branch when equal or zero statready
                    cmpb      #SS.FD    ; compare B with #SS.FD
                    beq       statfd    ; branch when equal or zero statfd
                    cmpb      #SS.FDInf ; compare B with #SS.FDInf
                    beq       statfdinf ; branch when equal or zero statfdinf
                    ldb       #E$UnkSvc ; load B from #E$UnkSvc
                    coma                ; complement A and set carry
statreturn          puls      x,y,u,pc  ; restore x,y,u,pc from stack
statok              clrb                ; clear accumulator B and carry
                    bra       statreturn ; continue unconditionally statreturn
statsize            ldd       F.Size,u  ; load D from F.Size,u
                    std       R$X,x     ; save D in R$X,x
                    ldd       F.Size+2,u ; load D from F.Size+2,u
                    std       R$U,x     ; save D in R$U,x
                    bra       statok    ; continue unconditionally statok
statpos             ldd       F.Pos,u   ; load D from F.Pos,u
                    std       R$X,x     ; save D in R$X,x
                    ldd       F.Pos+2,u ; load D from F.Pos+2,u
                    std       R$U,x     ; save D in R$U,x
                    bra       statok    ; continue unconditionally statok
stateof             leax      F.Pos,u   ; point X at F.Pos,u
                    lbsr      LoadVal   ; call helper LoadVal
                    leax      F.Size,u  ; point X at F.Size,u
                    lbsr      CompareVal ; call helper CompareVal
                    blo       statok    ; branch when unsigned lower statok
                    ldb       #E$EOF    ; load B from #E$EOF
                    coma                ; complement A and set carry
                    bra       statreturn ; continue unconditionally statreturn
statready           clr       R$B,x     ; clear R$B,x
                    bra       statok    ; continue unconditionally statok
statfd              ldd       R$Y,x     ; load D from R$Y,x
                    cmpd      #256      ; compare D with #256
                    bls       statfdlen@ ; branch when unsigned lower or equal statfdlen@
                    ldd       #256      ; load D from #256
statfdlen@          std       F.Move,u  ; save D in F.Move,u
                    ldd       R$X,x     ; load D from R$X,x
                    std       F.Dest,u  ; save D in F.Dest,u
                    leax      F.Entry,u ; point X at F.Entry,u
                    lbsr      MakeFD    ; call helper MakeFD
                    leax      F.Record+FD.SIZ,u ; point X at F.Record+FD.SIZ,u
                    ldd       F.Size,u  ; load D from F.Size,u
                    std       ,x        ; save D in ,x
                    ldd       F.Size+2,u ; load D from F.Size+2,u
                    std       2,x       ; save D in 2,x
                    bra       statfdcopy ; continue unconditionally statfdcopy
statfdinf           lda       F.Entry+11,u ; load A from F.Entry+11,u
                    bita      #$10      ; test A against #$10
                    beq       statbad@  ; branch when equal or zero statbad@
                    ldb       R$Y+1,x              low Y is requested byte count
                    clra                ; clear accumulator A and carry
                    std       F.Move,u  ; save D in F.Move,u
                    ldd       R$X,x     ; load D from R$X,x
                    std       F.Dest,u  ; save D in F.Dest,u
                    clr       F.Val,u   ; clear F.Val,u
                    lda       R$Y,x                high Y is cookie high byte
                    sta       F.Val+1,u ; save A in F.Val+1,u
                    ldd       R$U,x     ; load D from R$U,x
                    std       F.Val+2,u ; save D in F.Val+2,u
                    bne       statcookie@ ; branch when unequal or nonzero statcookie@
                    tst       F.Val+1,u ; test F.Val+1,u
                    bne       statcookie@ ; branch when unequal or nonzero statcookie@
                    leax      F.Entry,u ; point X at F.Entry,u
                    lbsr      MakeFD    ; call helper MakeFD
                    bra       statfdcopy ; continue unconditionally statfdcopy
statcookie@         lbsr      DecVal    ; call helper DecVal
                    ldb       #5        ; load B from #5
                    lbsr      ShiftLeft ; call helper ShiftLeft
                    lbcs      statreturn ; branch on carry or error statreturn
                    lda       #F.Offset-128 ; load A from #F.Offset-128
                    lbsr      StoreField ; call helper StoreField
* Cookie must refer to a physical record within this directory's visible size.
                    ldd       #64       ; load D from #64
                    lbsr      AddWord   ; call helper AddWord
                    bcs       statbad@  ; branch on carry or error statbad@
                    leax      F.Size,u  ; point X at F.Size,u
                    lbsr      CompareVal ; call helper CompareVal
                    bhs       statbad@  ; branch when unsigned higher or equal statbad@
                    lbsr      Locate    ; call helper Locate
                    lbcs      statreturn ; branch on carry or error statreturn
                    lda       ,x        ; load A from ,x
                    beq       statbad@  ; branch when equal or zero statbad@
                    cmpa      #$E5      ; compare A with #$E5
                    beq       statbad@  ; branch when equal or zero statbad@
                    lda       11,x      ; load A from 11,x
                    bita      #8        ; test A against #8
                    bne       statbad@  ; branch when unequal or nonzero statbad@
                    lbsr      MakeFD    ; call helper MakeFD
statfdcopy          leax      F.Record,u ; point X at F.Record,u
                    lbsr      MoveOut   ; call helper MoveOut
                    lbra      statreturn ; continue unconditionally statreturn
statbad@            ldb       #E$IllArg ; load B from #E$IllArg
                    coma                ; complement A and set carry
                    lbra      statreturn ; continue unconditionally statreturn

* Portable enumeration shares the normal directory position and decodes
* metadata directly after the name in the output record.
statreaddir         lda       PD.MOD,y  ; load A from PD.MOD,y
                    anda      #DIR.+READ. ; mask A with #DIR.+READ.
                    cmpa      #DIR.+READ. ; compare A with #DIR.+READ.
                    bne       rdaccess@ ; branch when unequal or nonzero rdaccess@
                    lda       F.Entry+11,u ; load A from F.Entry+11,u
                    bita      #$10      ; test A against #$10
                    beq       rdaccess@ ; branch when equal or zero rdaccess@
                    ldd       R$Y,x     ; load D from R$Y,x
                    cmpd      #RD.NameSize ; compare D with #RD.NameSize
                    beq       rdcount@  ; branch when equal or zero rdcount@
                    cmpd      #RD.Size  ; compare D with #RD.Size
                    bne       rdpath@   ; branch when unequal or nonzero rdpath@
rdcount@            std       F.Move,u  ; save D in F.Move,u
                    ldd       R$X,x     ; load D from R$X,x
                    std       F.Dest,u  ; save D in F.Dest,u
                    lda       F.Pos+3,u ; load A from F.Pos+3,u
                    anda      #31       ; mask A with #31
                    bne       rdpath@   ; branch when unequal or nonzero rdpath@
rdnext@             leax      F.Pos,u   ; point X at F.Pos,u
                    lbsr      LoadVal   ; call helper LoadVal
                    leax      F.Size,u  ; point X at F.Size,u
                    lbsr      CompareVal ; call helper CompareVal
                    bhs       rdeof@    ; branch when unsigned higher or equal rdeof@
                    lbsr      DirectoryRecord ; call helper DirectoryRecord
                    lbcs      statreturn ; branch on carry or error statreturn
* Advance even when filtering a slot; a failed caller copy may consume it.
                    ldd       #32       ; load D from #32
                    lbsr      AddPosition ; call helper AddPosition
                    lda       ,x        ; load A from ,x
                    beq       rdnext@   ; branch when equal or zero rdnext@
                    anda      #$7F      ; mask A with #$7F
                    cmpa      #'.       ; compare A with #'.
                    beq       rdnext@   ; branch when equal or zero rdnext@
                    ldd       F.Move,u  ; load D from F.Move,u
                    cmpd      #RD.NameSize ; compare D with #RD.NameSize
                    beq       rdcopy@   ; branch when equal or zero rdcopy@
* Decode directly after the name; no pathname scratch or metadata shuffling.
                    pshs      y         ; preserve y on stack
                    ldd       F.Offset+2,u ; load D from F.Offset+2,u
                    anda      #1        ; mask A with #1
                    leax      F.Data,u  ; point X at F.Data,u
                    leax      d,x       ; point X at d,x
                    leay      F.Record+RD.Attr,u ; point Y at F.Record+RD.Attr,u
                    ldb       #16       ; load B from #16
                    bsr       DecodeFD  ; call helper DecodeFD
                    puls      y         ; restore y from stack
rdcopy@             leax      F.Record,u ; point X at F.Record,u
                    lbsr      MoveOut   ; call helper MoveOut
                    lbra      statreturn ; continue unconditionally statreturn
rdaccess@           ldb       #E$FNA    ; load B from #E$FNA
                    bra       rderror@  ; continue unconditionally rderror@
rdpath@             ldb       #E$BPNam  ; load B from #E$BPNam
                    bra       rderror@  ; continue unconditionally rderror@
rdeof@              ldb       #E$EOF    ; load B from #E$EOF
rderror@            coma                ; complement A and set carry
                    lbra      statreturn ; continue unconditionally statreturn

* Translate a FAT entry to OS-9 metadata. The source is F.Entry or F.Data,
* never the output record, so it can be decoded directly without a scratch copy.
* SS.FD clears all 256 bytes; SS.ReadDir clears only its metadata tail.
MakeFD              pshs      y         ; preserve y on stack
                    leay      F.Record,u ; point Y at F.Record,u
                    clrb                ; clear accumulator B and carry
                    bsr       DecodeFD  ; call helper DecodeFD
                    puls      y,pc      ; restore y,pc from stack
* X=FAT entry, Y=output FD base, B=bytes to clear (0 means 256).
* SS.ReadDir exposes the first 13 FD bytes; creation date occupies unused tail.
* Preserve X/Y; use the same attributes, size and date decoding for both APIs.
DecodeFD            pshs      x,y       ; preserve x,y on stack
fdzero@             clr       ,y+       ; clear ,y+
                    decb                ; decrement accumulator B
                    bne       fdzero@   ; branch when unequal or nonzero fdzero@
                    ldy       2,s       ; load Y from 2,s
                    ldb       11,x      ; load B from 11,x
                    lbsr      Attributes ; call helper Attributes
                    sta       FD.ATT,y  ; save A in FD.ATT,y
                    lda       #1        ; load A from #1
                    sta       FD.LNK,y  ; save A in FD.LNK,y
                    ldd       28,x      ; load D from 28,x
                    exg       a,b       ; exchange registers a,b
                    std       FD.SIZ+2,y ; save D in FD.SIZ+2,y
                    ldd       30,x      ; load D from 30,x
                    exg       a,b       ; exchange registers a,b
                    std       FD.SIZ,y  ; save D in FD.SIZ,y
                    leax      24,x      ; point X at 24,x
                    leay      FD.DAT,y  ; point Y at FD.DAT,y
                    bsr       DateToOS9 ; call helper DateToOS9
                    ldx       ,s        ; load X from ,s
                    ldy       2,s       ; load Y from 2,s
                    lda       23,x      ; load A from 23,x
                    lsra                ; shift or rotate accumulator A
                    lsra                ; shift or rotate accumulator A
                    lsra                ; shift or rotate accumulator A
                    sta       FD.DAT+3,y ; save A in FD.DAT+3,y
                    lda       23,x      ; load A from 23,x
                    anda      #7        ; mask A with #7
                    lsla                ; shift or rotate accumulator A
                    lsla                ; shift or rotate accumulator A
                    lsla                ; shift or rotate accumulator A
                    sta       FD.DAT+4,y ; save A in FD.DAT+4,y
                    lda       22,x      ; load A from 22,x
                    lsra                ; shift or rotate accumulator A
                    lsra                ; shift or rotate accumulator A
                    lsra                ; shift or rotate accumulator A
                    lsra                ; shift or rotate accumulator A
                    lsra                ; shift or rotate accumulator A
                    ora       FD.DAT+4,y ; merge A with FD.DAT+4,y
                    sta       FD.DAT+4,y ; save A in FD.DAT+4,y
                    leax      16,x      ; point X at 16,x
                    leay      FD.Creat,y ; point Y at FD.Creat,y
                    bsr       DateToOS9 ; call helper DateToOS9
                    puls      x,y,pc    ; restore x,y,pc from stack
DateToOS9           lda       1,x       ; load A from 1,x
                    lsra                ; shift or rotate accumulator A
                    adda      #80       ; add to A: #80
                    sta       ,y        ; save A in ,y
* Carry brings date bit 8 into the month before shifting bits 5..8 down.
                    lda       1,x       ; load A from 1,x
                    lsra                ; shift or rotate accumulator A
                    lda       ,x        ; load A from ,x
                    rora                ; shift or rotate accumulator A
                    lsra                ; shift or rotate accumulator A
                    lsra                ; shift or rotate accumulator A
                    lsra                ; shift or rotate accumulator A
                    lsra                ; shift or rotate accumulator A
                    sta       1,y       ; save A in 1,y
                    lda       ,x        ; load A from ,x
                    anda      #31       ; mask A with #31
                    sta       2,y       ; save A in 2,y
                    rts                 ; return to caller
                    use       fatwrite.asm ; include shared definitions or implementation
                    emod      ;         finish module and CRC
eom                 equ       *         ; define constant or offset
                    end       ;         end assembly source
