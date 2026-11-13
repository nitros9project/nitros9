* pcf - FAT32 file manager over blkdrv ABI 1.
                    use       defsfile
                    use       blkdrv.d
                    use       pcf.d
                    use       readdir.d
                    mod       eom,name,FlMgr+Objct,ReEnt+1,start,0
name                fcs       /pcf/
                    fcb       1
* ABI entry slots remain three bytes: BSR plus an unsigned table offset.
* The common dispatcher replaces its return address with the target routine;
* no execution falls through into a selector byte or the relative-offset table.
start
Create              bsr       FMLocked
                    fcb       0*2
Open                bsr       FMLocked
                    fcb       1*2
MkDir               bsr       FMLocked
                    fcb       2*2
ChgDir              bsr       FMLocked
                    fcb       3*2
Delete              bsr       FMLocked
                    fcb       4*2
Seek                bsr       FMLocked
                    fcb       5*2
Read                bsr       FMLocked
                    fcb       6*2
Write               bsr       FMLocked
                    fcb       7*2
ReadLn              bsr       FMLocked
                    fcb       8*2
WriteLn             bsr       FMLocked
                    fcb       9*2
GetStat             bsr       FMLocked
                    fcb       10*2
SetStat             bsr       FMLocked
                    fcb       11*2
Close               bsr       FMLocked
                    fcb       12*2
FMLocked            pshs      x
                    ldx       2,s                 address of entry selector
                    ldb       ,x
                    leax      FMTargets,pcr
                    ldd       b,x
                    leax      d,x
                    stx       2,s                 replace dispatcher return address
                    ldx       PD.DEV,y
                    ldx       V$STAT,x
                    pshs      cc
                    orcc      #IntMasks
                    tst       V.BUSY,x
                    bne       fmbusy@
                    inc       V.BUSY,x
                    puls      cc
* Per-open buffers must not hide changes made through another open path.
                    ldx       PD.BUF,y
                    beq       fmcall@
                    clr       F.DataValid,x
                    clr       F.FatValid,x
fmcall@             jsr       [2,s]
                    pshs      b,cc
                    ldx       PD.DEV,y
                    ldx       V$STAT,x
                    clr       V.BUSY,x
                    puls      b,cc
                    bra       fmreturn@
fmbusy@             puls      cc
                    ldb       #E$DevBsy
                    coma
fmreturn@           puls      x
                    leas      2,s
                    rts

FMTargets
                    fdb       CreateImpl-FMTargets
                    fdb       OpenImpl-FMTargets
                    fdb       MkDirImpl-FMTargets
                    fdb       ChgDirImpl-FMTargets
                    fdb       DeleteImpl-FMTargets
                    fdb       SeekImpl-FMTargets
                    fdb       ReadImpl-FMTargets
                    fdb       WriteImpl-FMTargets
                    fdb       ReadLnImpl-FMTargets
                    fdb       WriteLnImpl-FMTargets
                    fdb       GetStatImpl-FMTargets
                    fdb       SetStatImpl-FMTargets
                    fdb       CloseImpl-FMTargets
ReadOnly            ldb       #E$WP
                    coma
                    rts
BadMedia            ldb       #E$BTyp
                    coma
                    rts
EOFError            ldb       #E$EOF
                    coma
                    rts
PathError           ldb       #E$BPNam
                    coma
                    rts
NotFound            ldb       #E$PNNF
                    coma
                    rts
AccessError         ldb       #E$FNA
                    coma
                    rts
Success             clrb
                    rts

* Internals: Y=path descriptor, U=private workspace. X/D scratch.
* Decode unaligned little-endian disk integers into the big-endian Val.
LE32                lda       3,x
                    ldb       2,x
                    std       F.Val,u
LELow               lda       1,x
                    ldb       ,x
                    std       F.Val+2,u
                    rts
LE16                clr       F.Val,u
                    clr       F.Val+1,u
                    bra       LELow
* A is a signed field displacement from U+128, covering offsets 0..255.
* LEAX leaves carry intact; the tail retains LoadVal/StoreVal register results.
LoadField           leax      128,u
                    leax      a,x
LoadVal             ldd       ,x
                    std       F.Val,u
                    ldd       2,x
                    std       F.Val+2,u
                    rts
* Increment a byte-addressable 32-bit field, retaining Val and the final X.
IncField            bsr       LoadField
                    bsr       IncVal
                    bra       StoreVal
StoreField          leax      128,u
                    leax      a,x
                    bra       StoreVal
* A/B are unsigned source/destination workspace offsets (before F.Path).
* Match LoadVal + StoreVal: Val and X retain the copy; carry is preserved.
CopyVal             pshs      b,cc
                    tfr       a,b
                    clra
                    leax      d,u
                    bsr       LoadVal
                    clra
                    puls      b,cc
                    leax      d,u
StoreVal            ldd       F.Val,u
                    std       ,x
                    ldd       F.Val+2,u
                    std       2,x
                    rts
AddVal              ldd       2,x
                    addd      F.Val+2,u
                    std       2,x
                    ldd       ,x
                    adcb      F.Val+1,u
                    adca      F.Val,u
                    std       ,x
                    rts
SubVal              ldd       2,x
                    subd      F.Val+2,u
                    std       2,x
                    ldd       ,x
                    sbcb      F.Val+1,u
                    sbca      F.Val,u
                    std       ,x
                    rts
CompareVal          ldd       F.Val,u
                    cmpd      ,x
                    bne       cmpdone@
                    ldd       F.Val+2,u
                    cmpd      2,x
cmpdone@            rts
IncVal              ldd       #1
* Add unsigned D to Val, preserving X/Y/U and returning the full-width carry.
AddWord             addd      F.Val+2,u
                    std       F.Val+2,u
                    ldd       F.Val,u
                    adcb      #0
                    adca      #0
                    std       F.Val,u
                    rts
* Add unsigned D to the path position, leaving X/Y/U and Val untouched.
AddPosition         addd      F.Pos+2,u
                    std       F.Pos+2,u
                    ldd       F.Pos,u
                    adcb      #0
                    adca      #0
                    std       F.Pos,u
                    rts
DecVal              ldd       F.Val+2,u
                    subd      #1
                    std       F.Val+2,u
                    ldd       F.Val,u
                    sbcb      #0
                    sbca      #0
                    std       F.Val,u
                    rts
ShiftRight          lsr       F.Val,u
                    ror       F.Val+1,u
                    ror       F.Val+2,u
                    ror       F.Val+3,u
                    decb
                    bne       ShiftRight
                    rts
ShiftLeft           lsl       F.Val+3,u
                    rol       F.Val+2,u
                    rol       F.Val+1,u
                    rol       F.Val,u
                    bcs       shiftbad@
                    decb
                    bne       ShiftLeft
                    clrb
                    rts
shiftbad@           lbra      BadMedia

* X=request or info, A=driver slot. No PD.BUF/RBF deblocking convention.
Driver              pshs      a,x,y,u
                    ldx       PD.DEV,y
                    ldu       V$STAT,x
                    ifgt      Level-1
                    ldx       V$DRIVEX,x
                    else
                    ldx       V$DRIV,x
                    ldd       M$Exec,x
                    leax      d,x
                    endc
                    lda       ,s
                    leax      a,x
                    pshs      x
                    ldx       3,s
                    jsr       [,s]
                    leas      2,s
                    puls      a,x,y,u,pc

* Val=absolute LBA. Separate one-sector FAT and data caches.
ReadData            leax      F.DataValid,u
                    pshs      x
                    leax      F.Data,u
                    bra       ReadCache
ReadFat             leax      F.FatValid,u
                    pshs      x
                    leax      F.Fat,u
* Stack: sector buffer, cache descriptor (valid byte + LBA). Y remains the
* OS-9 path descriptor throughout ReadBlock/Driver. Failed fills stay invalid.
ReadCache           pshs      x
                    ldx       2,s
                    tst       ,x
                    beq       cachefill@
                    leax      1,x
                    lbsr      CompareVal
                    beq       cachehit@
cachefill@          ldx       2,s
                    clr       ,x
                    ldx       ,s
                    stx       F.Request+BR.Buffer,u
                    bsr       ReadBlock
                    bcs       cacheret@
                    ldx       2,s
                    leax      1,x
                    lbsr      StoreVal
                    inc       -1,x
cachehit@           clrb
cacheret@           puls      x
                    leas      2,s
                    rts
* Read/write share LBA setup, driver-error propagation and exact block count.
WriteBlock          lda       #BD.Write
                    bra       TransferBlock
ReadBlock           lda       #BD.Read
TransferBlock       pshs      a
                    leax      F.Request+BR.LBA,u
                    lbsr      StoreVal
                    leax      F.Request,u
                    puls      a
                    bsr       Driver
                    bcs       blockret@
                    ldd       F.Request+BR.Done,u
                    cmpd      #1
                    lbne      BadMedia
                    clrb
blockret@           rts

* Validate BPB and all derived geometry before any FAT/directory reads.
Mount               leax      F.Info,u
                    ldd       #BI.Len*256+BD.Version
                    std       BI.Size,x
                    lda       #BD.Info
                    lbsr      Driver
                    lbcs      mountret
                    ldd       F.Info+BI.BlockSize,u
                    cmpd      #512
                    lbne      BadMedia
                    ldd       #BR.Len*256+BD.Version
                    std       F.Request+BR.Size,u
                    lda       F.Info+BI.Unit,u
                    sta       F.Request+BR.Unit,u
                    ldd       #1
                    std       F.Request+BR.Count,u
                    ldd       #512
                    std       F.Request+BR.Bytes,u
                    ldx       PD.DEV,y
                    ldx       V$DESC,x
                    pshs      x
                    leax      FT.Base,x
                    lbsr      LoadVal
                    lda       #F.Base-128
                    lbsr      StoreField
                    leax      F.Info+BI.Last,u
                    lbsr      CompareVal
                    lbhi      mountdescbad
                    ldx       ,s
                    leax      FT.Length,x
                    lbsr      LoadVal
                    lda       #F.Span-128
                    lbsr      StoreField
                    leas      2,s
                    lda       #F.Base-128
                    lbsr      LoadField
                    lbsr      ReadData
                    lbcs      mountret
                    ldd       510,x
                    cmpd      #$55AA
                    lbne      BadMedia
                    ldd       11,x
                    cmpd      #$0002               512 little endian
                    lbne      BadMedia
                    ldd       17,x                 root entry count must be zero
                    lbne      BadMedia
                    ldd       19,x                 total16 must be zero on FAT32
                    lbne      BadMedia
                    ldd       22,x                 FAT16 size must be zero
                    lbne      BadMedia
                    ldd       42,x                 filesystem version 0
                    lbne      BadMedia
                    lda       16,x
                    lbeq      mountbad
                    cmpa      #2
                    lbhi      mountbad
                    sta       F.Fats,u
                    lda       13,x
                    lbeq      mountbad
                    bmi       spc128@
                    bra       spcpower@
spc128@             cmpa      #128
                    lbne      mountbad
spcpower@           sta       F.SPC,u
                    deca
                    anda      F.SPC,u
                    lbne      mountbad
                    lda       F.SPC,u
spcshift@           lsra
                    beq       spcdone@
                    inc       F.Shift,u
                    bra       spcshift@
spcdone@            leax      32,x
                    lbsr      LE32
                    lda       #F.Total-128
                    lbsr      StoreField
                    ldd       F.Val,u
                    bne       totalok@
                    ldd       F.Val+2,u
                    lbeq      mountbad
totalok@            ldd       F.Span,u
                    bne       spancheck@
                    ldd       F.Span+2,u
                    beq       endcheck@
spancheck@          leax      F.Span,u
                    lbsr      CompareVal
                    lbhi      mountbad
endcheck@           lbsr      DecVal
                    leax      F.Base,u
                    lbsr      AddBase
                    lbcs      mountret
                    leax      F.Info+BI.Last,u
                    lbsr      CompareVal
                    lbhi      mountbad
                    leax      F.Data+14,u
                    lbsr      LE16
                    ldd       F.Val+2,u
                    lbeq      mountbad
                    lda       #F.Temp-128
                    lbsr      StoreField          relative data start begins at reserved count
                    leax      F.Base,u
                    lbsr      AddBase
                    lbcs      mountret
                    lda       #F.FatStart-128
                    lbsr      StoreField
                    leax      F.Data+36,u
                    lbsr      LE32
                    ldd       F.Val,u
                    bne       fatszok@
                    ldd       F.Val+2,u
                    lbeq      mountbad
fatszok@            lda       #F.FatSize-128
                    lbsr      StoreField
                    lda       F.Fats,u
                    pshs      a
fatmultiply@        leax      F.Temp,u
                    lbsr      AddVal
                    lbcs      mountbadpop
                    dec       ,s
                    bne       fatmultiply@
                    leas      1,s
                    lda       #F.Temp-128
                    lbsr      LoadField
                    leax      F.Total,u
                    lbsr      CompareVal
                    lbhs      mountbad
                    leax      F.Base,u
                    lbsr      AddBase
                    lbcs      mountret
                    lda       #F.DataStart-128
                    lbsr      StoreField
                    ldd       #F.Total*256+F.MaxCluster
                    lbsr      CopyVal
                    lda       #F.Temp-128
                    lbsr      LoadField
                    leax      F.MaxCluster,u
                    lbsr      SubVal
                    lbsr      LoadVal
                    ldb       F.Shift,u
                    beq       clusters@
                    lbsr      ShiftRight
clusters@           ldd       F.Val,u
                    bne       minimum@
                    ldd       F.Val+2,u
                    cmpd      #65525               discriminate FAT32 by cluster count
                    blo       mountbad
minimum@            lbsr      IncVal
                    lda       #F.MaxCluster-128
                    lbsr      StoreField
                    bsr       ValidCluster
                    bcs       mountret
* FAT must contain entries zero through MaxCluster inclusive.
                    lbsr      IncVal
                    ldd       #127
                    lbsr      AddWord
                    ldb       #7
                    lbsr      ShiftRight
                    leax      F.FatSize,u
                    lbsr      CompareVal
                    bhi       mountbad
* FAT32 ExtFlags: mirroring enabled chooses FAT 0; otherwise select active FAT.
                    lda       F.Data+40,u
                    bita      #$80
                    beq       root@
                    anda      #15
                    cmpa      F.Fats,u
                    bhs       mountbad
                    sta       F.Active,u
                    tsta
                    beq       root@
                    lda       #F.FatSize-128
                    lbsr      LoadField
                    leax      F.FatStart,u
                    lbsr      AddVal
                    bcs       mountbad
root@               lbsr      MountWriteInfo
                    leax      F.Data+44,u
                    lbsr      LE32
                    bsr       ValidCluster
                    bcs       mountret
                    lda       #F.Root-128
                    lbsr      StoreField
                    clrb
mountret            rts
mountdescbad        leas      1,s
mountbadpop         leas      1,s
mountbad            lbra      BadMedia

* Val += 32-bit value at X, with checked overflow.
AddBase             ldd       F.Val+2,u
                    addd      2,x
                    std       F.Val+2,u
                    ldd       F.Val,u
                    adcb      1,x
                    adca      ,x
                    std       F.Val,u
                    lbcs      BadMedia
                    clrb
                    rts
ValidCluster        ldd       F.Val,u
                    cmpd      #$0FFF
                    bhi       invalid@
                    blo       lowcheck@
                    ldd       F.Val+2,u
                    cmpd      #$FFF0
                    bhs       invalid@
lowcheck@           ldd       F.Val,u
                    bne       maxcheck@
                    ldd       F.Val+2,u
                    cmpd      #2
                    blo       invalid@
maxcheck@           leax      F.MaxCluster,u
                    lbsr      CompareVal
                    bhi       invalid@
                    clrb
                    rts
invalid@            lbra      BadMedia

* Cluster in/out, EOF only for FAT EOC markers; free/bad/reserved links fail.
FatEntry            lda       #F.Cluster-128
                    lbsr      LoadField
                    ldb       #7
                    lbsr      ShiftRight
                    leax      F.FatStart,u
                    bsr       AddBase
                    bcs       fatentryret@
                    lbsr      ReadFat
                    bcs       fatentryret@
                    ldb       F.Cluster+3,u
                    andb      #127
                    clra
                    lslb
                    rola
                    lslb
                    rola
                    leax      d,x
                    clrb
fatentryret@        rts
NextCluster         lda       #F.Cluster-128
                    lbsr      LoadField
                    bsr       ValidCluster
                    bcs       nextret@
                    bsr       FatEntry
                    bcs       nextret@
                    lbsr      LE32
                    lda       F.Val,u
                    anda      #15
                    sta       F.Val,u
                    ldd       F.Val,u
                    cmpd      #$0FFF
                    bne       linkvalid@
                    ldd       F.Val+2,u
                    cmpd      #$FFF8
                    lbhs      EOFError
linkvalid@          bsr       ValidCluster
                    bcs       nextret@
                    lda       #F.Cluster-128
                    lbsr      StoreField
                    clrb
nextret@            rts

* File/dir chain cursor with Floyd cycle detection; no cluster-number truncation.
ResetWalk           lda       #F.Start-128
                    lbsr      LoadField
                    lbsr      ValidCluster
                    bcs       resetret@
                    lda       #F.Walk-128
                    lbsr      StoreField
                    lda       #F.Hare-128
                    lbsr      StoreField
                    clra
                    clrb
                    std       F.WalkIndex,u
                    std       F.WalkIndex+2,u
                    lda       #1
                    sta       F.WalkValid,u
resetret@           rts
Advance             ldd       #F.Walk*256+F.Cluster
                    lbsr      CopyVal
                    bsr       NextCluster
                    bcs       advret@
                    lda       #F.Walk-128
                    lbsr      StoreField
                    lda       #F.WalkIndex-128
                    lbsr      IncField
                    ldd       F.Hare,u
                    bne       harego@
                    ldd       F.Hare+2,u
                    beq       advok@
harego@             ldd       #F.Hare*256+F.Cluster
                    lbsr      CopyVal
                    ldb       #2
                    pshs      b
harestep@           lbsr      NextCluster
                    bcs       hareend@
                    dec       ,s
                    bne       harestep@
                    leas      1,s
                    lda       #F.Hare-128
                    lbsr      StoreField
                    leax      F.Walk,u
                    lbsr      CompareVal
                    lbeq      BadMedia
advok@              clrb
advret@             rts
hareend@            leas      1,s
                    cmpb      #E$EOF
                    bne       advfail@
                    clra
                    clrb
                    std       F.Hare,u
                    std       F.Hare+2,u
                    rts
advfail@            coma
                    rts

* Offset is logical byte offset within Start's chain. Return X=byte in data.
Locate              lda       #F.Offset-128
                    lbsr      LoadField
                    ldb       F.Shift,u
                    addb      #9
                    lbsr      ShiftRight
                    lda       #F.Target-128
                    lbsr      StoreField
                    tst       F.WalkValid,u
                    beq       restart@
                    leax      F.WalkIndex,u
                    lbsr      CompareVal
                    bhs       locatewalk@
restart@            lbsr      ResetWalk
                    bcs       locret@
locatewalk@         lda       #F.Target-128
                    lbsr      LoadField
                    leax      F.WalkIndex,u
                    lbsr      CompareVal
                    beq       locsector@
                    lbsr      Advance
                    bcs       locret@
                    bra       locatewalk@
locsector@          lda       #F.Walk-128
                    lbsr      LoadField
                    lbsr      DecVal
                    lbsr      DecVal
                    ldb       F.Shift,u
                    beq       locbase@
                    lbsr      ShiftLeft
                    bcs       locret@
locbase@            leax      F.DataStart,u
                    lbsr      AddBase
                    bcs       locret@
                    lda       #F.Temp-128
                    lbsr      StoreField
                    lda       #F.Offset-128
                    lbsr      LoadField
                    ldb       #9
                    lbsr      ShiftRight
                    lda       F.SPC,u
                    deca
                    anda      F.Val+3,u
                    clrb
                    stb       F.Val,u
                    stb       F.Val+1,u
                    stb       F.Val+2,u
                    sta       F.Val+3,u
                    leax      F.Temp,u
                    lbsr      AddBase
                    bcs       locret@
                    lbsr      ReadData
                    bcs       locret@
                    ldd       F.Offset+2,u
                    anda      #1
                    leax      d,x
                    clrb
locret@             rts

CreateImpl          lda       #1
                    bra       OpenBegin
OpenImpl            clra
OpenBegin           pshs      a,x,y,u
                    clr       PD.BUF,y
                    clr       PD.BUF+1,y
                    lda       PD.MOD,y
                    bita      #READ.+WRITE.+EXEC.
                    lbeq      openaccess
                    ldd       #F.Len
                    os9       F$SRqMem
                    lbcs      openreturn
                    stu       PD.BUF,y
                    tfr       u,x
                    ldd       #F.Len
openzero@           clr       ,x+
                    subd      #1
                    bne       openzero@
                    lda       ,s
                    cmpa      #3
                    bne       openkind@
                    inc       F.Deleting,u
                    clra
openkind@           sta       F.Creating,u
                    sty       F.Owner,u
                    ldx       5,s
                    stx       F.Regs,u
                    lbsr      Mount
                    lbcs      openfailed
                    lda       PD.MOD,y
                    bita      #WRITE.
                    beq       openread@
                    lbsr      Writable
                    lbcs      openfailed
openread@           lbsr      CopyPath
                    bcs       openfailed
                    lbsr      Resolve
                    bcs       openfailed
                    tst       F.Creating,u
                    beq       openexisting@
                    ldb       #E$CEF
                    bra       openfailed
openexisting@       lda       F.Entry+11,u
                    anda      #$10
                    beq       openfile@
                    lda       PD.MOD,y
                    bita      #DIR.
                    bne       opendir@
                    tst       F.Deleting,u
                    beq       openaccessfree
opendir@            lbsr      DirectorySize
                    bcs       openfailed
                    bra       openok@
openfile@           lda       PD.MOD,y
                    bita      #DIR.
                    bne       openaccessfree
                    ldd       F.Size,u
                    bne       openvalid@
                    ldd       F.Size+2,u
                    beq       openok@
openvalid@          lda       #F.Start-128
                    lbsr      LoadField
                    lbsr      ValidCluster
                    bcs       openfailed
openok@             lda       PD.MOD,y
                    bita      #WRITE.
                    beq       openshare@
                    lda       F.Entry+11,u
                    bita      #$10
                    beq       openwritefile@
* Writable directory handles authorize metadata services, never raw writes.
                    bita      #1
                    bne       openaccessfree
                    bra       openshare@
openwritefile@      lbsr      CanWriteFile
                    bcs       openfailed
openshare@          lbsr      RegisterPath
                    bcs       openfailed
                    ldb       F.Entry+11,u
                    lbsr      Attributes
                    sta       PD.ATT,y
                    clr       F.WalkValid,u
                    clrb
openreturn          leas      1,s
                    puls      x,y,u,pc
openwp              ldb       #E$WP
                    coma
                    bra       openreturn
openaccess          ldb       #E$FNA
                    coma
                    bra       openreturn
openaccessfree      ldb       #E$FNA
                    coma
openfailed          pshs      b
                    lbsr      FreePath
                    puls      b
                    coma
                    bra       openreturn

* Copy caller path to private memory. OS-9 high-bit terminators are accepted.
CopyPath            pshs      y
                    ldx       F.Regs,u
                    ldx       R$X,x
                    leay      F.Path,u
                    pshs      y
copychar@           pshs      y
                    ifgt      Level-1
                    ldy       <D.Proc
                    ldb       P$Task,y
                    os9       F$LDABX
                    else
                    lda       ,x
                    endc
                    puls      y
                    tsta
                    beq       pathdone@
                    cmpa      #C$CR
                    beq       pathdone@
                    cmpa      #C$SPAC
                    beq       pathdone@
                    cmpa      #',
                    beq       pathdone@
                    pshs      a
                    anda      #$7F
                    sta       ,y+
                    leax      1,x
                    tfr       y,d
                    subd      1,s                compare copied length (saved char is atop pointer)
                    cmpd      #255
                    bhi       pathtoolong@
                    puls      a
                    tsta
                    bpl       copychar@
pathdone@           clr       ,y
* Return the next argument, skipping OS-9 command-line separators.
pathskip@           equ       *
                    ifgt      Level-1
                    ldy       <D.Proc
                    ldb       P$Task,y
                    os9       F$LDABX
                    else
                    lda       ,x
                    endc
                    cmpa      #C$SPAC
                    beq       pathadvance@
                    cmpa      #',
                    bne       pathreturn@
pathadvance@        leax      1,x
                    bra       pathskip@
pathreturn@         leas      2,s
                    ldy       F.Regs,u
                    stx       R$X,y
                    clrb
                    puls      y,pc
pathtoolong@        leas      3,s
                    puls      y
                    lbra      PathError

* Starting directory: absolute paths skip the device name; relative paths
* use all four file-manager bytes in P$DIO (CWD) or P$DIO+6 (CXD).
Resolve             ldd       #F.Root*256+F.Start
                    lbsr      CopyVal
                    lda       #$10
                    sta       F.Entry+11,u
                    leax      F.Path,u
                    lda       ,x
                    lbeq      resolvebad@
                    cmpa      #'/
                    beq       skipdevice@
                    pshs      x
                    ldx       <D.Proc
                    leax      P$DIO,x
                    lda       PD.MOD,y
                    bita      #EXEC.
                    beq       cwd@
                    leax      6,x
cwd@                ldd       ,x
                    cmpd      PD.DEV,y
                    bne       cwdroot@
                    leax      2,x
                    lbsr      LoadVal
                    ldd       F.Val,u
                    bne       cwdvalid@
                    ldd       F.Val+2,u
                    beq       cwdroot@
cwdvalid@           lbsr      ValidCluster
                    bcs       cwderror@
                    lda       #F.Start-128
                    lbsr      StoreField
cwdroot@            puls      x
                    bra       component@
cwderror@           leas      2,s
                    rts
skipdevice@         leax      1,x
skipdevchar@        lda       ,x+
                    beq       resolveroot@
                    cmpa      #'/
                    bne       skipdevchar@
component@          lda       ,x
                    beq       resolveroot@
                    cmpa      #'/
                    bne       parsename@
                    leax      1,x
                    bra       component@
parsename@          stx       F.Cursor,u
                    bsr       ParseName
                    bcs       resolveret@
                    tst       F.Dots,u
                    beq       ordinary@
                    dec       F.Dots,u
                    beq       aftercomponent@
parentloop@         lda       #F.Start-128
                    lbsr      LoadField
                    leax      F.Root,u
                    lbsr      CompareVal
                    beq       parentdone@
                    lbsr      Lookup
                    bcs       resolveret@
parentdone@         dec       F.Dots,u
                    bne       parentloop@
                    bra       aftercomponent@
ordinary@           lbsr      Lookup
                    bcc       aftercomponent@
                    cmpb      #E$PNNF
                    bne       resolverefail@
                    tst       F.Creating,u
                    beq       resolverefail@
                    ldx       F.Cursor,u
                    tst       ,x
                    bne       resolverefail@
                    lbsr      CreateEntry
                    bra       resolveret@
resolverefail@      coma
                    rts
aftercomponent@     ldx       F.Cursor,u
                    lda       ,x
                    beq       resolved@
                    lda       F.Entry+11,u
                    bita      #$10
                    lbeq      NotFound
                    bra       component@
resolveroot@        clrb
                    rts
resolved@           clrb
resolveret@         rts
resolvebad@         lbra      PathError

* ASCII 8.3 aliases, case insensitive. Dot-only names use OS-9 ascent rules.
ParseName           pshs      y
                    leay      F.Name,u
                    ldb       #11
                    lda       #C$SPAC
padname@            sta       ,y+
                    decb
                    bne       padname@
                    clr       F.Dots,u
                    ldx       F.Cursor,u
dotcount@           lda       ,x+
                    cmpa      #'.
                    bne       dotend@
                    inc       F.Dots,u
                    bra       dotcount@
dotend@             tsta
                    beq       alldots@
                    cmpa      #'/
                    beq       alldots@
normalname@         clr       F.Dots,u
                    ldx       F.Cursor,u
                    leay      F.Name,u
                    ldb       #8
basename@           lda       ,x+
                    beq       nameterm@
                    cmpa      #'/
                    beq       nameterm@
                    cmpa      #'.
                    beq       extension@
                    bsr       NameChar
                    bcs       namebad@
                    tstb
                    beq       namebad@
                    sta       ,y+
                    decb
                    bra       basename@
extension@          cmpb      #8
                    beq       namebad@
                    leay      F.Name+8,u
                    ldb       #3
extchar@            lda       ,x+
                    beq       nameterm@
                    cmpa      #'/
                    beq       nameterm@
                    bsr       NameChar
                    bcs       namebad@
                    tstb
                    beq       namebad@
                    sta       ,y+
                    decb
                    bra       extchar@
alldots@            tst       F.Dots,u
                    beq       normalname@
                    lda       #'.
                    sta       F.Name,u
                    sta       F.Name+1,u
nameterm@           leax      -1,x
                    stx       F.Cursor,u
                    clrb
                    puls      y,pc
namebad@            puls      y
                    lbra      PathError
NameChar            cmpa      #'a
                    blo       charcheck@
                    cmpa      #'z
                    bhi       charcheck@
                    suba      #32
charcheck@          cmpa      #33
                    blo       charbad@
                    cmpa      #127
                    bhs       charbad@
                    pshs      x
                    leax      IllegalChars,pcr
charloop@           tst       ,x
                    beq       charok@
                    cmpa      ,x+
                    bne       charloop@
                    puls      x
charbad@            coma
                    rts
charok@             puls      x
                    andcc     #$FE
                    rts
IllegalChars        fcc       /"*+,.:;<=>?[\]|/
                    fcb       0

* Scan one directory for Name; all addresses and offsets are 32 bits.
Lookup              clr       F.HasLFN,u
                    clr       F.WalkValid,u
                    clra
                    clrb
                    std       F.Scan,u
                    std       F.Scan+2,u
lookloop@           ldd       #F.Scan*256+F.Offset
                    lbsr      CopyVal
                    lbsr      Locate
                    bcs       lookerror@
                    lda       ,x
                    beq       lookmissing@
                    cmpa      #$E5
                    beq       lookclear@
                    lda       11,x
                    cmpa      #$0F
                    bne       lookattr@
                    inc       F.HasLFN,u
                    bra       looknext@
lookattr@           bita      #8
                    bne       lookclear@
                    pshs      x,y
                    leay      F.Name,u
                    ldb       #11
lookcompare@        lda       ,x+
                    cmpa      ,y+
                    bne       looknomatch@
                    decb
                    bne       lookcompare@
                    puls      x,y
                    lbsr      EntryLocation
                    bsr       AdoptEntry
                    rts
looknomatch@        puls      x,y
lookclear@          clr       F.HasLFN,u
looknext@           bsr       ScanNext
                    bcc       lookloop@
                    rts
lookerror@          cmpb      #E$EOF
                    bne       lookio@
lookmissing@        lbra      NotFound
lookio@             coma
                    rts
ScanNext            lda       #F.Scan-128
                    lbsr      LoadField
                    ldd       #32
                    lbsr      AddWord
                    lbcs      BadMedia
                    lda       #F.Scan-128
                    lbsr      StoreField
                    clrb
                    rts
AdoptEntry          pshs      y
                    leay      F.Entry,u
                    ldb       #32
                    lbsr      CopyBytes
                    puls      y
                    leax      F.Entry+28,u
                    lbsr      LE32
                    lda       #F.Size-128
                    lbsr      StoreField
                    lda       F.Entry+21,u
                    anda      #15
                    ldb       F.Entry+20,u
                    std       F.Val,u
                    lda       F.Entry+27,u
                    ldb       F.Entry+26,u
                    std       F.Val+2,u
                    lda       F.Entry+11,u
                    bita      #$10
                    beq       adoptstart@
                    ldd       F.Val,u
                    bne       adoptvalid@
                    ldd       F.Val+2,u
                    bne       adoptvalid@
* Only the actual '..' entry is allowed to encode the root as cluster zero.
                    ldd       F.Entry,u
                    cmpd      #$2E2E
                    lbne      BadMedia
                    lda       #F.Root-128
                    lbsr      LoadField
adoptvalid@         lbsr      ValidCluster
                    bcs       adoptret@
adoptstart@         lda       #F.Start-128
                    lbsr      StoreField
                    clr       F.WalkValid,u
                    clrb
adoptret@           rts

* Directory view contains two synthetic dot records followed by physical slots.
* Deleted/LFN/volume/disk dot slots become zero records, preserving cookie offsets.
DirectorySize       clr       F.WalkValid,u
                    clra
                    clrb
                    std       F.Scan,u
                    std       F.Scan+2,u
dirsizewalk@        ldd       #F.Scan*256+F.Offset
                    lbsr      CopyVal
                    lbsr      Locate
                    bcs       dirsizeend@
                    tst       ,x
                    beq       dirsizefound@
                    lbsr      ScanNext
                    bcs       dirsizeret@
                    bra       dirsizewalk@
dirsizeend@         cmpb      #E$EOF
                    bne       dirsizeerror@
dirsizefound@       lda       #F.Scan-128
                    lbsr      LoadField
                    ldd       #64
                    lbsr      AddWord
                    lbcs      BadMedia
                    lda       #F.Size-128
                    lbsr      StoreField
                    clrb
dirsizeret@         rts
dirsizeerror@       coma
                    rts

ChgDirImpl          pshs      x,y,u
                    lda       PD.MOD,y
                    ora       #DIR.
                    sta       PD.MOD,y
                    lbsr      OpenImpl
                    bcs       chgret@
                    ldu       PD.BUF,y
                    ldx       <D.Proc
                    lda       PD.MOD,y
                    bita      #READ.
                    beq       chgexec@
                    ldd       F.Start,u
                    std       P$DIO+2,x
                    ldd       F.Start+2,u
                    std       P$DIO+4,x
chgexec@            lda       PD.MOD,y
                    bita      #EXEC.
                    beq       chgfree@
                    ldd       F.Start,u
                    std       P$DIO+8,x
                    ldd       F.Start+2,u
                    std       P$DIO+10,x
chgfree@            bsr       FreePath
chgret@             puls      x,y,u,pc
CloseImpl           tst       PD.CNT,y
                    bne       closeshared@
                    bra       FreePath
closeshared@        clrb
                    rts
FreePath            pshs      x,y,u
                    ldu       PD.BUF,y
                    beq       freeok@
                    lbsr      UnregisterPath
                    clr       PD.BUF,y
                    clr       PD.BUF+1,y
                    ldd       #F.Len
                    os9       F$SRtMem
                    puls      x,y,u,pc
freeok@             clrb
                    puls      x,y,u,pc

SeekImpl            pshs      x,y,u
                    tfr       u,x
                    ldu       PD.BUF,y
                    ldd       R$X,x
                    std       F.Pos,u
                    ldd       R$U,x
                    std       F.Pos+2,u
                    clrb
                    puls      x,y,u,pc

ReadImpl            clra
                    bra       ReadCommon
ReadLnImpl          lda       #1
ReadCommon          pshs      x,y,u
                    tfr       u,x
                    ldu       PD.BUF,y
                    stx       F.Regs,u
                    sta       F.Line,u
                    clr       F.Stop,u
                    ldd       R$Y,x
                    std       F.Remain,u
                    clra
                    clrb
                    std       R$Y,x
                    std       F.Actual,u
                    ldd       R$X,x
                    std       F.Dest,u
readloop@           ldd       F.Remain,u
                    lbeq      readsuccess@
                    leax      F.Pos,u
                    lbsr      LoadVal
                    leax      F.Size,u
                    lbsr      CompareVal
                    lbhs      readeof@
                    lda       F.Entry+11,u
                    bita      #$10
                    bne       readdirectory@
                    lda       #F.Offset-128
                    lbsr      StoreField
                    lbsr      Locate
                    lbcs      readchainerror@
                    ldd       F.Pos+2,u
                    anda      #1
                    pshs      d
                    ldd       #512
                    subd      ,s++
                    bra       readlimit@
readdirectory@      lbsr      DirectoryRecord
                    lbcs      readexit@
                    ldb       F.Pos+3,u
                    andb      #31
                    abx
                    negb
                    addb      #32
                    clra
readlimit@          cmpd      F.Remain,u
                    bls       readfilesize@
                    ldd       F.Remain,u
readfilesize@       std       F.Move,u
                    pshs      x
                    ldd       #F.Size*256+F.Temp
                    lbsr      CopyVal
                    leax      F.Pos,u
                    lbsr      LoadVal
                    leax      F.Temp,u
                    lbsr      SubVal
                    ldd       F.Temp,u
                    bne       readscan@
                    ldd       F.Temp+2,u
                    cmpd      F.Move,u
                    bhs       readscan@
                    std       F.Move,u
readscan@           puls      x
                    tst       F.Line,u
                    beq       readmove@
                    pshs      x
                    ldd       F.Move,u
                    pshs      d
linescan@           lda       ,x+
                    cmpa      #C$CR
                    beq       linefound@
                    ldd       ,s
                    subd      #1
                    std       ,s
                    bne       linescan@
                    bra       lineend@
linefound@          ldd       F.Move,u
                    subd      ,s
                    addd      #1
                    std       F.Move,u
                    inc       F.Stop,u
lineend@            leas      2,s
                    puls      x
readmove@           bsr       MoveOut
                    bcs       readexit@
                    ldd       F.Move,u
                    addd      F.Actual,u
                    std       F.Actual,u
                    ldd       F.Remain,u
                    subd      F.Move,u
                    std       F.Remain,u
                    ldd       F.Dest,u
                    addd      F.Move,u
                    std       F.Dest,u
                    ldd       F.Move,u
                    lbsr      AddPosition
                    tst       F.Stop,u
                    lbeq      readloop@
readsuccess@        clrb
ReadReturn
readexit@           pshs      b,cc
                    ldx       F.Regs,u
                    ldd       F.Actual,u
                    std       R$Y,x
                    puls      b,cc
                    puls      x,y,u,pc
readeof@            ldd       F.Actual,u
                    bne       readsuccess@
                    ldb       #E$EOF
                    coma
                    bra       readexit@
readchainerror@     cmpb      #E$EOF
                    bne       readerror@
                    ldb       #E$BTyp              chain ended before file size
readerror@          coma
                    bra       readexit@

* Caller address/count are F.Dest/F.Move; X is the system buffer.
* Share the pointer setup and transfer, swapping source/destination for MoveIn.
* Preserve X/Y/U on both success and failure; A/B are scratch/status.
MoveIn              pshs      x,y,u
                    bsr       MovePointers
                    exg       x,u
                    bra       MoveBytes
MoveOut             pshs      x,y,u
                    bsr       MovePointers
                    ifgt      Level-1
                    exg       a,b
                    endc
MoveBytes
                    ifgt      Level-1
                    os9       F$Move
                    else
movebyte@           cmpy      #0
                    beq       movedone@
                    lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bra       movebyte@
movedone@           clrb
                    endc
                    puls      x,y,u,pc
MovePointers
                    ifgt      Level-1
                    ldy       <D.Proc
                    lda       P$Task,y
                    ldb       <D.SysTsk
                    endc
                    ldy       F.Move,u
                    ldu       F.Dest,u
                    rts

* Build a stable OS-9 directory record at Pos. Cookie = physical slot + 1,
* scoped to this open directory, not a truncated FAT cluster or disk address.
DirectoryRecord     leax      F.Record,u
                    ldb       #32
recordzero@         clr       ,x+
                    decb
                    bne       recordzero@
                    leax      F.Pos,u
                    lbsr      LoadVal
                    ldd       F.Val,u
                    bne       recordraw@
                    ldd       F.Val+2,u
                    cmpd      #64
                    bhs       recordraw@
                    leax      F.Record,u
                    cmpd      #32
                    bhs       recorddot@
                    lda       #'.
                    sta       ,x
                    lda       #'.+$80
                    sta       1,x
                    clrb
                    rts
recorddot@          lda       #'.+$80
                    sta       ,x
                    clrb
                    rts
recordraw@          ldd       F.Val+2,u
                    subd      #64
                    std       F.Val+2,u
                    ldd       F.Val,u
                    sbcb      #0
                    sbca      #0
                    std       F.Val,u
                    lda       F.Val+3,u
                    anda      #$E0
                    sta       F.Val+3,u
                    lda       #F.Offset-128
                    lbsr      StoreField
                    ldb       #5
                    lbsr      ShiftRight
                    lbsr      IncVal
                    tst       F.Val,u
                    lbne      BadMedia             cookie must fit SS.FDInf's 24 bits
                    lda       #F.Cookie-128
                    lbsr      StoreField
                    lbsr      Locate
                    bcs       recordret@
                    lda       ,x
                    beq       recordblank@
                    cmpa      #$E5
                    beq       recordblank@
                    cmpa      #'.
                    beq       recordblank@
                    lda       11,x
                    bita      #8
                    bne       recordblank@
                    pshs      y
                    leay      F.Record,u
                    ldb       #8
recordbase@         lda       ,x+
                    cmpa      #C$SPAC
                    beq       recordbaseskip@
                    sta       ,y+
recordbaseskip@     decb
                    bne       recordbase@
                    lda       ,x
                    cmpa      #C$SPAC
                    beq       recordnameend@
                    lda       #'.
                    sta       ,y+
                    ldb       #3
recordext@          lda       ,x+
                    cmpa      #C$SPAC
                    beq       recordextskip@
                    sta       ,y+
recordextskip@      decb
                    bne       recordext@
recordnameend@      lda       -1,y
                    ora       #$80
                    sta       -1,y
                    puls      y
                    lda       F.Cookie+1,u
                    sta       F.Record+29,u
                    ldd       F.Cookie+2,u
                    std       F.Record+30,u
recordblank@        leax      F.Record,u
                    clrb
recordret@          rts

GetStatImpl         pshs      x,y,u
                    tfr       u,x
                    ldu       PD.BUF,y
                    stx       F.Regs,u
                    ldb       R$B,x
                    cmpb      #SS.ReadDir
                    lbeq      statreaddir
                    cmpb      #SS.Opt
                    beq       statok
                    cmpb      #SS.DevNm
                    beq       statok                IOMan copies these common results
                    cmpb      #SS.Size
                    beq       statsize
                    cmpb      #SS.Pos
                    beq       statpos
                    cmpb      #SS.EOF
                    beq       stateof
                    cmpb      #SS.Ready
                    beq       statready
                    cmpb      #SS.FD
                    beq       statfd
                    cmpb      #SS.FDInf
                    beq       statfdinf
                    ldb       #E$UnkSvc
                    coma
statreturn          puls      x,y,u,pc
statok              clrb
                    bra       statreturn
statsize            ldd       F.Size,u
                    std       R$X,x
                    ldd       F.Size+2,u
                    std       R$U,x
                    bra       statok
statpos             ldd       F.Pos,u
                    std       R$X,x
                    ldd       F.Pos+2,u
                    std       R$U,x
                    bra       statok
stateof             leax      F.Pos,u
                    lbsr      LoadVal
                    leax      F.Size,u
                    lbsr      CompareVal
                    blo       statok
                    ldb       #E$EOF
                    coma
                    bra       statreturn
statready           clr       R$B,x
                    bra       statok
statfd              ldd       R$Y,x
                    cmpd      #256
                    bls       statfdlen@
                    ldd       #256
statfdlen@          std       F.Move,u
                    ldd       R$X,x
                    std       F.Dest,u
                    leax      F.Entry,u
                    lbsr      MakeFD
                    leax      F.Record+FD.SIZ,u
                    ldd       F.Size,u
                    std       ,x
                    ldd       F.Size+2,u
                    std       2,x
                    bra       statfdcopy
statfdinf           lda       F.Entry+11,u
                    bita      #$10
                    beq       statbad@
                    ldb       R$Y+1,x              low Y is requested byte count
                    clra
                    std       F.Move,u
                    ldd       R$X,x
                    std       F.Dest,u
                    clr       F.Val,u
                    lda       R$Y,x                high Y is cookie high byte
                    sta       F.Val+1,u
                    ldd       R$U,x
                    std       F.Val+2,u
                    bne       statcookie@
                    tst       F.Val+1,u
                    bne       statcookie@
                    leax      F.Entry,u
                    lbsr      MakeFD
                    bra       statfdcopy
statcookie@         lbsr      DecVal
                    ldb       #5
                    lbsr      ShiftLeft
                    lbcs      statreturn
                    lda       #F.Offset-128
                    lbsr      StoreField
* Cookie must refer to a physical record within this directory's visible size.
                    ldd       #64
                    lbsr      AddWord
                    bcs       statbad@
                    leax      F.Size,u
                    lbsr      CompareVal
                    bhs       statbad@
                    lbsr      Locate
                    lbcs      statreturn
                    lda       ,x
                    beq       statbad@
                    cmpa      #$E5
                    beq       statbad@
                    lda       11,x
                    bita      #8
                    bne       statbad@
                    lbsr      MakeFD
statfdcopy          leax      F.Record,u
                    lbsr      MoveOut
                    lbra      statreturn
statbad@            ldb       #E$IllArg
                    coma
                    lbra      statreturn

* Portable enumeration shares the normal directory position and decodes
* metadata directly after the name in the output record.
statreaddir         lda       PD.MOD,y
                    anda      #DIR.+READ.
                    cmpa      #DIR.+READ.
                    bne       rdaccess@
                    lda       F.Entry+11,u
                    bita      #$10
                    beq       rdaccess@
                    ldd       R$Y,x
                    cmpd      #RD.NameSize
                    beq       rdcount@
                    cmpd      #RD.Size
                    bne       rdpath@
rdcount@            std       F.Move,u
                    ldd       R$X,x
                    std       F.Dest,u
                    lda       F.Pos+3,u
                    anda      #31
                    bne       rdpath@
rdnext@             leax      F.Pos,u
                    lbsr      LoadVal
                    leax      F.Size,u
                    lbsr      CompareVal
                    bhs       rdeof@
                    lbsr      DirectoryRecord
                    lbcs      statreturn
* Advance even when filtering a slot; a failed caller copy may consume it.
                    ldd       #32
                    lbsr      AddPosition
                    lda       ,x
                    beq       rdnext@
                    anda      #$7F
                    cmpa      #'.
                    beq       rdnext@
                    ldd       F.Move,u
                    cmpd      #RD.NameSize
                    beq       rdcopy@
* Decode directly after the name; no pathname scratch or metadata shuffling.
                    pshs      y
                    ldd       F.Offset+2,u
                    anda      #1
                    leax      F.Data,u
                    leax      d,x
                    leay      F.Record+RD.Attr,u
                    ldb       #16
                    bsr       DecodeFD
                    puls      y
rdcopy@             leax      F.Record,u
                    lbsr      MoveOut
                    lbra      statreturn
rdaccess@           ldb       #E$FNA
                    bra       rderror@
rdpath@             ldb       #E$BPNam
                    bra       rderror@
rdeof@              ldb       #E$EOF
rderror@            coma
                    lbra      statreturn

* Translate a FAT entry to OS-9 metadata. The source is F.Entry or F.Data,
* never the output record, so it can be decoded directly without a scratch copy.
* SS.FD clears all 256 bytes; SS.ReadDir clears only its metadata tail.
MakeFD              pshs      y
                    leay      F.Record,u
                    clrb
                    bsr       DecodeFD
                    puls      y,pc
* X=FAT entry, Y=output FD base, B=bytes to clear (0 means 256).
* SS.ReadDir exposes the first 13 FD bytes; creation date occupies unused tail.
* Preserve X/Y; use the same attributes, size and date decoding for both APIs.
DecodeFD            pshs      x,y
fdzero@             clr       ,y+
                    decb
                    bne       fdzero@
                    ldy       2,s
                    ldb       11,x
                    lbsr      Attributes
                    sta       FD.ATT,y
                    lda       #1
                    sta       FD.LNK,y
                    ldd       28,x
                    exg       a,b
                    std       FD.SIZ+2,y
                    ldd       30,x
                    exg       a,b
                    std       FD.SIZ,y
                    leax      24,x
                    leay      FD.DAT,y
                    bsr       DateToOS9
                    ldx       ,s
                    ldy       2,s
                    lda       23,x
                    lsra
                    lsra
                    lsra
                    sta       FD.DAT+3,y
                    lda       23,x
                    anda      #7
                    lsla
                    lsla
                    lsla
                    sta       FD.DAT+4,y
                    lda       22,x
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    ora       FD.DAT+4,y
                    sta       FD.DAT+4,y
                    leax      16,x
                    leay      FD.Creat,y
                    bsr       DateToOS9
                    puls      x,y,pc
DateToOS9           lda       1,x
                    lsra
                    adda      #80
                    sta       ,y
* Carry brings date bit 8 into the month before shifting bits 5..8 down.
                    lda       1,x
                    lsra
                    lda       ,x
                    rora
                    lsra
                    lsra
                    lsra
                    lsra
                    sta       1,y
                    lda       ,x
                    anda      #31
                    sta       2,y
                    rts
                    use       fatwrite.asm
                    emod
eom                 equ       *
                    end
