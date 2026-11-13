* PCF mutation support. Caller holds the device-wide file-manager lock.
* Writes are synchronous. The media must not be modified outside this mount.
Writable            lda       F.Info+BI.Flags,u
                    bita      #BF.ReadOnly
                    lbne      ReadOnly
                    clrb
                    rts
CanWriteFile        bsr       Writable
                    bcs       canret@
                    lda       F.Entry+11,u
                    bita      #$11                 readonly or directory
                    lbne      AccessError
                    tst       F.HasLFN,u           mutations are short-name only for now
                    lbne      AccessError
                    clrb
canret@             rts
Attributes          lda       #READ.+EXEC.+PREAD.+PEXEC.
                    bitb      #1
                    bne       attrdir@
                    pshs      b
                    ldb       F.Info+BI.Flags,u
                    bitb      #BF.ReadOnly
                    puls      b
                    bne       attrdir@
                    ora       #WRITE.+PWRIT.
attrdir@            bitb      #$10
                    beq       attrret@
                    ora       #DIR.
attrret@            rts

* Link live paths through opaque blkdrv file-manager storage. A writer excludes
* other opens of the same file; delete refuses even a read-open target.
RegisterPath        lda       PD.MOD,y
                    anda      #WRITE.
                    bsr       CheckSharing
                    bcs       registerret@
                    ldx       PD.DEV,y
                    ldx       V$STAT,x
                    ldd       BV.FMPaths,x
                    std       F.NextPath,u
                    stu       BV.FMPaths,x
                    inc       F.Registered,u
                    clrb
registerret@        rts
CheckSharing        pshs      a,x,y
                    ldx       PD.DEV,y
                    ldx       V$STAT,x
                    ldx       BV.FMPaths,x
shareloop@          cmpx      #0
                    beq       shareok@
                    pshs      u
                    cmpx      ,s++
                    beq       sharenext@
                    ldd       F.DirLBA,u
                    cmpd      F.DirLBA,x
                    bne       sharenext@
                    ldd       F.DirLBA+2,u
                    cmpd      F.DirLBA+2,x
                    bne       sharenext@
                    ldd       F.DirOff,u
                    cmpd      F.DirOff,x
                    bne       sharenext@
                    lda       F.Entry+11,u
                    bita      #$10
                    bne       sharenext@
                    tst       ,s
                    bne       sharebad@
                    ldy       F.Owner,x
                    lda       PD.MOD,y
                    bita      #WRITE.
                    bne       sharebad@
sharenext@          ldx       F.NextPath,x
                    bra       shareloop@
shareok@            clrb
                    puls      a,x,y,pc
sharebad@           ldb       #E$Share
                    coma
                    puls      a,x,y,pc
UnregisterPath      pshs      x
                    tst       F.Registered,u
                    beq       unlinkdone@
                    ldx       PD.DEV,y
                    ldx       V$STAT,x
                    leax      BV.FMPaths,x
unlinkloop@         tfr       u,d
                    cmpd      ,x
                    beq       unlinkfound@
                    ldx       ,x
                    beq       unlinkdone@
                    leax      F.NextPath,x
                    bra       unlinkloop@
unlinkfound@        ldd       F.NextPath,u
                    std       ,x
                    clr       F.Registered,u
unlinkdone@         puls      x,pc
EntryLocation       pshs      x
                    tfr       x,d
                    leax      F.Data,u
                    pshs      x
                    subd      ,s++
                    std       F.DirOff,u
                    ldd       #F.DataLBA*256+F.DirLBA
                    lbsr      CopyVal
                    puls      x,pc

* Remember valid reserved-sector FSInfo locations. Backup FSInfo is at
* BPB_BkBootSec + BPB_FSInfo; either may legitimately be absent.
MountWriteInfo      lda       F.Data+40,u
                    bita      #$80
                    bne       infoaddr@
                    inc       F.Mirror,u
infoaddr@           leax      F.Data+48,u
                    lbsr      LE16
                    ldd       F.Val+2,u
                    beq       infodone@
                    pshs      d
                    leax      F.Data+14,u
                    lbsr      LE16
                    ldd       ,s
                    cmpd      F.Val+2,u
                    bhs       infopop@
                    std       F.Saved+2,u
                    leax      F.Data+48,u
                    lbsr      LE16
                    leax      F.Base,u
                    lbsr      AddBase
                    lda       #F.FSInfo-128
                    lbsr      StoreField
                    leax      F.Data+50,u
                    lbsr      LE16
                    ldd       F.Val+2,u
                    beq       infopop@
                    addd      ,s
                    bcs       infopop@
                    std       ,s
                    leax      F.Data+14,u
                    lbsr      LE16
                    ldd       ,s
                    cmpd      F.Val+2,u
                    bhs       infopop@
                    std       F.Val+2,u
                    leax      F.Base,u
                    lbsr      AddBase
                    lda       #F.BackInfo-128
                    lbsr      StoreField
infopop@            leas      2,s
infodone@           rts

* Store Val little endian at X without changing its reserved FAT bits elsewhere.
PutLE               lda       F.Val+3,u
                    sta       ,x
                    lda       F.Val+2,u
                    sta       1,x
                    lda       F.Val+1,u
                    sta       2,x
                    lda       F.Val,u
                    sta       3,x
                    rts
WriteData           leax      F.Data,u
                    stx       F.Request+BR.Buffer,u
                    lda       #F.DataLBA-128
                    lbsr      LoadField
                    lbra      WriteBlock
Flush               leax      F.Request,u
                    lda       #BD.Flush
                    lbra      Driver

* F.Cluster entry <- F.Value. Update every FAT if mirrored, active FAT only
* otherwise. Re-read each copy so its upper four reserved bits are preserved.
SetFat              clr       F.FatCopy,u
setfatloop@         lbsr      FatEntry
                    bcs       setfatret@
                    tst       F.FatCopy,u
                    beq       setfatstore@
                    lda       #F.FatLBA-128
                    lbsr      LoadField
                    leax      F.FatSize,u
                    lbsr      AddBase
                    lbsr      ReadFat
                    bcs       setfatret@
                    ldb       F.Cluster+3,u
                    andb      #127
                    clra
                    lslb
                    rola
                    lslb
                    rola
                    leax      d,x
setfatstore@        pshs      x
                    lda       3,x
                    anda      #$F0
                    pshs      a
                    lda       #F.Value-128
                    lbsr      LoadField
                    lda       F.Val,u
                    anda      #15
                    ora       ,s+
                    sta       F.Val,u
                    puls      x
                    bsr       PutLE
                    leax      F.Fat,u
                    stx       F.Request+BR.Buffer,u
                    lda       #F.FatLBA-128
                    lbsr      LoadField
                    lbsr      WriteBlock
                    bcs       setfatret@
                    tst       F.Mirror,u
                    beq       setfatok@
                    inc       F.FatCopy,u
                    lda       F.FatCopy,u
                    cmpa      F.Fats,u
                    blo       setfatloop@
setfatok@           clrb
setfatret@          pshs      cc
                    clr       F.FatValid,u
                    puls      cc,pc

* Read and update optional FSInfo hints. Unknown counts stay unknown.
* Invalid/missing FSInfo is ignored; it is not authoritative allocation data.
UpdateHints         lda       #F.FSInfo-128
                    lbsr      LoadField
                    bsr       UpdateHint
                    bcs       hintret@
                    lda       #F.BackInfo-128
                    lbsr      LoadField
UpdateHint          ldd       F.Val,u
                    bne       hintread@
                    ldd       F.Val+2,u
                    beq       hintret@
hintread@           lbsr      ReadData
                    bcs       hintret@
                    ldd       ,x
                    cmpd      #$5252
                    bne       hintok@
                    ldd       2,x
                    cmpd      #$6141
                    bne       hintok@
                    ldd       484,x
                    cmpd      #$7272
                    bne       hintok@
                    ldd       486,x
                    cmpd      #$4161
                    bne       hintok@
                    leax      488,x
                    pshs      x
                    lbsr      LE32
                    ldd       F.Val,u
                    cmpd      #$FFFF
                    beq       hintunknown@
                    tst       F.HintDelta,u
                    bmi       hintdec@
                    lbsr      IncVal
                    bra       hintput@
hintdec@            lbsr      DecVal
hintput@            ldx       ,s
                    lbsr      PutLE
hintunknown@        puls      x
                    ldd       #$FFFF
                    std       4,x
                    std       6,x
                    lbra      WriteData
hintok@             clrb
hintret@            rts

ClusterBase         lbsr      DecVal
                    lbsr      DecVal
                    ldb       F.Shift,u
                    beq       clusterbase@
                    lbsr      ShiftLeft
                    bcs       baseret@
clusterbase@        leax      F.DataStart,u
                    lbsr      AddBase
baseret@            rts
* Return New = allocated, zeroed EOC cluster. Always consult the FAT itself.
Allocate            clra
                    clrb
                    std       F.New,u
                    ldd       #2
                    std       F.New+2,u
allocscan@          lda       #F.New-128
                    lbsr      LoadField
                    leax      F.MaxCluster,u
                    lbsr      CompareVal
                    bhi       allocfull@
                    lda       #F.Cluster-128
                    lbsr      StoreField
                    lbsr      FatEntry
                    bcs       allocret@
                    lbsr      LE32
                    lda       F.Val,u
                    anda      #15
                    ora       F.Val+1,u
                    ora       F.Val+2,u
                    ora       F.Val+3,u
                    beq       allocfree@
                    lda       #F.New-128
                    lbsr      IncField
                    bra       allocscan@
allocfree@          lda       #F.New-128
                    lbsr      LoadField
                    bsr       ClusterBase
                    bcs       allocret@
                    lda       #F.DataLBA-128
                    lbsr      StoreField
                    leax      F.Data,u
                    ldd       #512
alloczero@          clr       ,x+
                    subd      #1
                    bne       alloczero@
                    clr       F.DataValid,u
                    lda       F.SPC,u
                    sta       F.Sectors,u
allocsector@        lbsr      WriteData
                    bcs       allocret@
                    lda       #F.DataLBA-128
                    lbsr      IncField
                    dec       F.Sectors,u
                    bne       allocsector@
                    ldd       #$0FFF
                    std       F.Value,u
                    ldd       #$FFFF
                    std       F.Value+2,u
                    ldd       #F.New*256+F.Cluster
                    lbsr      CopyVal
                    lbsr      SetFat
                    bcs       allocret@
                    lda       #$FF
                    sta       F.HintDelta,u
                    lbsr      UpdateHints
                    rts
allocfull@          ldb       #E$Full
                    coma
allocret@           rts

* Validate the complete chain before destructive operations (including cycles).
ValidateChain       ldd       F.Start,u
                    bne       validatebegin@
                    ldd       F.Start+2,u
                    beq       validateok@
validatebegin@      lbsr      ResetWalk
                    bcs       validateret@
validateloop@       lbsr      Advance
                    bcc       validateloop@
                    cmpb      #E$EOF
                    bne       validatebad@
validateok@         clrb
validateret@        rts
validatebad@        coma
                    rts
* Free a previously validated chain beginning at Saved (zero is empty).
FreeChain           ldd       F.Saved,u
                    bne       freechainloop@
                    ldd       F.Saved+2,u
                    beq       freechainok@
freechainloop@      ldd       #F.Saved*256+F.Cluster
                    lbsr      CopyVal
                    lbsr      NextCluster
                    bcc       freenext@
                    cmpb      #E$EOF
                    bne       freechainbad@
                    clra
                    clrb
                    std       F.Val,u
                    std       F.Val+2,u
freenext@           lda       #F.Link-128
                    lbsr      StoreField
                    ldd       #F.Saved*256+F.Cluster
                    lbsr      CopyVal
                    clra
                    clrb
                    std       F.Value,u
                    std       F.Value+2,u
                    lbsr      SetFat
                    bcs       freechainret@
                    lda       #1
                    sta       F.HintDelta,u
                    lbsr      UpdateHints
                    bcs       freechainret@
                    ldd       #F.Link*256+F.Saved
                    lbsr      CopyVal
                    bra       FreeChain
freechainok@        clrb
freechainret@       rts
freechainbad@       coma
                    rts

* FAT timestamps from the kernel's six-byte clock (year is since 1900).
Stamp               pshs      x,y,cc
                    orcc      #IntMasks
                    ldx       #D.Time
                    leay      F.Time,u
                    ldb       #6
                    lbsr      CopyBytes
                    puls      cc,x,y
EncodeTime          lda       F.Time,u
                    cmpa      #80
                    bhs       stampyear@
                    lda       #80
stampyear@          suba      #80
                    lsla
                    sta       F.Entry+25,u
                    ldb       F.Time+1,u
                    bne       stampmonth@
                    ldb       #1
* Month * 32 supplies both the high date bits and the low date byte.
stampmonth@         lda       #32
                    mul
                    ora       F.Entry+25,u
                    sta       F.Entry+25,u
                    lda       F.Time+2,u
                    bne       stampday@
                    lda       #1
stampday@           pshs      b
                    ora       ,s+
                    sta       F.Entry+24,u
* Minute * 32 supplies both time bytes; combine hours and half-seconds.
                    lda       #32
                    ldb       F.Time+4,u
                    mul
                    pshs      d
                    lda       F.Time+3,u
                    lsla
                    lsla
                    lsla
                    ora       ,s+
                    sta       F.Entry+23,u
                    lda       F.Time+5,u
                    lsra
                    ora       ,s+
                    sta       F.Entry+22,u
                    rts
UpdateEntry         bsr       Stamp
CommitEntry         lda       #F.Start-128
                    lbsr      LoadField
                    leax      F.Entry,u
                    lbsr      EntryCluster
                    lda       #F.Size-128
                    lbsr      LoadField
                    leax      F.Entry+28,u
                    lbsr      PutLE
                    lda       F.Entry+11,u
                    ora       #$20
                    sta       F.Entry+11,u
                    lda       #F.DirLBA-128
                    lbsr      LoadField
                    lbsr      ReadData
                    bcs       commitret@
                    ldd       F.DirOff,u
                    leax      d,x
                    pshs      x,y
                    leay      F.Entry,u
                    ldb       #11
commitcheck@        lda       ,x+
                    cmpa      ,y+
                    bne       commitgone@
                    decb
                    bne       commitcheck@
                    puls      x,y
                    bsr       CopyEntryToDisk
                    lbra      WriteData
commitgone@         puls      x,y
                    ldb       #E$Share
                    coma
commitret@          rts
CopyEntryToDisk     pshs      y
                    leay      F.Entry,u
                    ldb       #32
entryout@           lda       ,y+
                    sta       ,x+
                    decb
                    bne       entryout@
                    puls      y,pc

* The parent has already been resolved and Lookup proved the name absent.
CreateEntry         lbsr      Writable
                    lbcs      createret@
                    lda       PD.MOD,y
                    bita      #DIR.
                    beq       createkind@
                    lda       F.Creating,u
                    cmpa      #2
                    lbne      AccessError
createkind@         clr       F.WalkValid,u
                    clra
                    clrb
                    std       F.Scan,u
                    std       F.Scan+2,u
createscan@         ldd       #F.Scan*256+F.Offset
                    lbsr      CopyVal
                    lbsr      Locate
                    bcc       createslot@
                    cmpb      #E$EOF
                    lbne      createbad@
* A full directory grows by one zeroed cluster, including a fragmented root.
                    ldd       #F.Walk*256+F.Link
                    lbsr      CopyVal
                    lbsr      Allocate
                    lbcs      createret@
                    ldd       #F.New*256+F.Value
                    lbsr      CopyVal
                    ldd       #F.Link*256+F.Cluster
                    lbsr      CopyVal
                    lbsr      SetFat
                    lbcs      createret@
                    clr       F.WalkValid,u
                    bra       createscan@
createslot@         lda       ,x
                    beq       createfree@
                    cmpa      #$E5
                    beq       createfree@
                    lbsr      ScanNext
                    lbcs      createret@
                    bra       createscan@
createfree@         sta       F.Zero,u             zero means preserve end marker
                    lbsr      EntryLocation
                    pshs      x
                    leax      F.Entry,u
                    ldb       #32
createzero@         clr       ,x+
                    decb
                    bne       createzero@
                    pshs      y
                    leax      F.Name,u
                    leay      F.Entry,u
                    ldb       #11
                    lbsr      CopyBytes
                    puls      y
                    lda       #$20
                    ldb       F.Creating,u
                    cmpb      #2
                    bne       createattr@
                    lda       #$10
createattr@         sta       F.Entry+11,u
                    lbsr      Stamp
                    ldd       F.Entry+24,u
                    std       F.Entry+16,u
                    std       F.Entry+18,u
                    ldd       F.Entry+22,u
                    std       F.Entry+14,u
                    puls      x
                    lda       F.Creating,u
                    cmpa      #2
                    bne       createpublish@
                    lbsr      NewDirectory
                    bcs       createret@
createpublish@      lbsr      CopyEntryToDisk
                    lbsr      WriteData
                    bcs       createret@
                    tst       F.Zero,u
                    bne       createdone@
                    lbsr      ScanNext
                    bcs       createret@
                    ldd       #F.Scan*256+F.Offset
                    lbsr      CopyVal
                    lbsr      Locate
                    bcc       createend@
                    cmpb      #E$EOF
                    bne       createbad@
                    bra       createdone@
createend@          clr       ,x
                    lbsr      WriteData
                    bcs       createret@
createdone@         clr       F.Creating,u
                    clr       F.HasLFN,u
                    leax      F.Entry,u
                    lbsr      AdoptEntry
                    bcs       createret@
                    lbsr      Flush
createret@          rts
createbad@          coma
                    rts

* Locate a write position, allocating/linking a zeroed cluster as necessary.
EnsureCluster       ldd       F.Start,u
                    bne       ensurelocate@
                    ldd       F.Start+2,u
                    bne       ensurelocate@
                    lbsr      Allocate
                    bcs       ensureret@
                    ldd       #F.New*256+F.Start
                    lbsr      CopyVal
                    lbsr      UpdateEntry
                    bcs       ensureret@
                    clr       F.WalkValid,u
ensurelocate@       lbsr      Locate
                    bcc       ensureret@
                    cmpb      #E$EOF
                    bne       ensurebad@
                    ldd       #F.Walk*256+F.Link
                    lbsr      CopyVal
                    lbsr      Allocate
                    bcs       ensureret@
                    ldd       #F.New*256+F.Value
                    lbsr      CopyVal
                    ldd       #F.Link*256+F.Cluster
                    lbsr      CopyVal
                    lbsr      SetFat
                    bcs       ensureret@
                    clr       F.WalkValid,u
                    bra       ensurelocate@
ensurebad@          coma
ensureret@          rts

WriteImpl           clra
                    bra       WriteCommon
WriteLnImpl         lda       #1
WriteCommon         pshs      x,y,u
                    tfr       u,x
                    ldu       PD.BUF,y
                    stx       F.Regs,u
                    sta       F.Line,u
                    clr       F.Stop,u
                    clr       F.Zero,u
                    ldd       R$Y,x
                    std       F.Remain,u
                    ldd       R$X,x
                    std       F.Dest,u
                    clra
                    clrb
                    std       F.Actual,u
                    std       R$Y,x
                    lda       PD.MOD,y
                    bita      #WRITE.
                    beq       writemode@
                    lbsr      CanWriteFile
                    bcs       writereturn@
                    ldd       F.Remain,u
                    beq       writesuccess@
                    ldd       F.Pos+2,u
                    addd      F.Remain,u
                    ldd       F.Pos,u
                    adcb      #0
                    adca      #0
                    bcs       writeoverflow@
                    ldd       #F.Pos*256+F.GapEnd
                    lbsr      CopyVal
                    bsr       FillGap
                    bcs       writereturn@
writeloop@          ldd       F.Remain,u
                    beq       writesuccess@
                    bsr       ChunkSpace
                    cmpd      F.Remain,u
                    bls       writecount@
                    ldd       F.Remain,u
writecount@         std       F.Move,u
                    lbsr      PutChunk
                    bcs       writereturn@
                    ldd       F.Move,u
                    addd      F.Actual,u
                    std       F.Actual,u
                    ldd       F.Remain,u
                    subd      F.Move,u
                    std       F.Remain,u
                    ldd       F.Dest,u
                    addd      F.Move,u
                    std       F.Dest,u
                    tst       F.Stop,u
                    beq       writeloop@
writesuccess@       lbsr      Flush
writereturn@        lbra      ReadReturn
writeoverflow@      ldb       #E$BTyp
                    coma
                    bra       writereturn@
writemode@          ldb       #E$BMode
                    coma
                    bra       writereturn@
ChunkSpace          ldd       F.Pos+2,u
                    anda      #1
                    pshs      d
                    ldd       #512
                    subd      ,s++
                    rts

* Fill a seek/resize gap with zeros; do not expose stale disk bytes.
FillGap             lda       #F.GapEnd-128
                    lbsr      LoadField
                    leax      F.Size,u
                    lbsr      CompareVal
                    bls       gapok@
                    ldd       #F.Size*256+F.Pos
                    lbsr      CopyVal
                    inc       F.Zero,u
gaploop@            lda       #F.GapEnd-128
                    lbsr      LoadField
                    leax      F.Pos,u
                    lbsr      CompareVal
                    beq       gapdone@
                    lda       #F.Wanted-128
                    lbsr      StoreField
                    leax      F.Pos,u
                    lbsr      LoadVal
                    leax      F.Wanted,u
                    lbsr      SubVal
                    bsr       ChunkSpace
                    std       F.Move,u
                    ldd       F.Wanted,u
                    bne       gapchunk@
                    ldd       F.Wanted+2,u
                    cmpd      F.Move,u
                    bhs       gapchunk@
                    std       F.Move,u
gapchunk@           bsr       PutChunk
                    bcc       gaploop@
                    pshs      cc
                    clr       F.Zero,u
                    puls      cc,pc
gapdone@            clr       F.Zero,u
gapok@              clrb
                    rts

PutChunk            ldd       #F.Pos*256+F.Offset
                    lbsr      CopyVal
                    lbsr      EnsureCluster
                    bcs       putret@
                    tst       F.Zero,u
                    beq       putuser@
                    ldd       F.Move,u
putzero@            clr       ,x+
                    subd      #1
                    bne       putzero@
                    bra       putdisk@
putuser@            lbsr      WriteLineCount
                    lbsr      MoveIn
                    bcs       putret@
putdisk@            lbsr      WriteData
                    bcs       putret@
                    ldd       F.Move,u
                    lbsr      AddPosition
                    lbcs      BadMedia
                    leax      F.Pos,u
                    lbsr      LoadVal
                    leax      F.Size,u
                    lbsr      CompareVal
                    bls       putmetadata@
                    lbsr      StoreVal
putmetadata@        lbsr      UpdateEntry
putret@             rts

DeleteImpl          pshs      x,y,u
                    lda       PD.MOD,y
                    pshs      a
                    lda       #READ.
                    sta       PD.MOD,y
                    lda       #3
                    lbsr      OpenBegin
                    bcs       deletereturn@
                    ldu       PD.BUF,y
                    lda       F.Entry+11,u
                    bita      #$10
                    beq       deletefile@
                    lbsr      RemovableDirectory
                    bra       deletechecked@
deletefile@         lbsr      CanWriteFile
deletechecked@      bcs       deletefree@
                    lda       #WRITE.
                    lbsr      CheckSharing
                    bcs       deletefree@
                    lbsr      ValidateChain
                    bcs       deletefree@
                    ldd       #F.Start*256+F.Saved
                    lbsr      CopyVal
                    lda       #F.DirLBA-128
                    lbsr      LoadField
                    lbsr      ReadData
                    bcs       deletefree@
                    ldd       F.DirOff,u
                    leax      d,x
                    lda       #$E5
                    sta       ,x
                    lbsr      WriteData
                    bcs       deletefree@
                    lbsr      FreeChain
                    bcs       deletefree@
                    lbsr      Flush
deletefree@         pshs      b,cc
                    lbsr      FreePath
                    puls      b,cc
deletereturn@       puls      a
                    sta       PD.MOD,y
                    puls      x,y,u,pc

SetStatImpl         pshs      x,y,u
                    tfr       u,x
                    ldu       PD.BUF,y
                    stx       F.Regs,u
                    lbsr      Writable
                    bcs       SetStatReturn
                    ldx       F.Regs,u
                    ldb       R$B,x
                    cmpb      #SS.Rename
                    lbeq      RenameEntry
                    cmpb      #SS.Size
                    beq       SetSize
                    ldb       #E$UnkSvc            PCF does not promise RBF permissions/FD writes
                    coma
SetStatReturn       puls      x,y,u,pc
SetSize             lda       PD.MOD,y
                    bita      #WRITE.
                    lbeq      setmode@
                    lbsr      CanWriteFile
                    bcs       SetStatReturn
                    ldd       #F.Pos*256+F.SavedPos
                    lbsr      CopyVal
                    ldx       F.Regs,u
                    ldd       R$X,x
                    std       F.GapEnd,u
                    ldd       R$U,x
                    std       F.GapEnd+2,u
                    lda       #F.GapEnd-128
                    lbsr      LoadField
                    leax      F.Size,u
                    lbsr      CompareVal
                    lbeq      sizerestore@
                    blo       sizeshrink@
                    lbsr      FillGap
                    bra       sizerestore@
sizeshrink@         lbsr      ValidateChain
                    bcs       sizerestore@
                    lda       #F.GapEnd-128
                    lbsr      LoadField
                    ldd       F.Val,u
                    bne       sizepartial@
                    ldd       F.Val+2,u
                    bne       sizepartial@
                    ldd       #F.Start*256+F.Saved
                    lbsr      CopyVal
                    clra
                    clrb
                    std       F.Start,u
                    std       F.Start+2,u
                    bra       sizepublish@
sizepartial@        lbsr      DecVal
                    lda       #F.Offset-128
                    lbsr      StoreField
                    lbsr      Locate
                    bcs       sizerestore@
                    ldd       #F.Walk*256+F.New
                    lbsr      CopyVal
                    lda       #F.Cluster-128
                    lbsr      StoreField
                    lbsr      NextCluster
                    bcc       sizetail@
                    cmpb      #E$EOF
                    bne       sizebad@
                    clra
                    clrb
                    std       F.Val,u
                    std       F.Val+2,u
sizetail@           lda       #F.Saved-128
                    lbsr      StoreField
sizepublish@        ldd       #F.GapEnd*256+F.Size
                    lbsr      CopyVal
                    lbsr      UpdateEntry
                    bcs       sizerestore@
                    ldd       F.Start,u
                    bne       sizedetach@
                    ldd       F.Start+2,u
                    beq       sizefree@
sizedetach@         ldd       #F.New*256+F.Cluster
                    lbsr      CopyVal
                    ldd       #$0FFF
                    std       F.Value,u
                    ldd       #$FFFF
                    std       F.Value+2,u
                    lbsr      SetFat
                    bcs       sizerestore@
sizefree@           lbsr      FreeChain
sizerestore@        pshs      b,cc
                    ldd       #F.SavedPos*256+F.Pos
                    lbsr      CopyVal
                    clr       F.WalkValid,u
                    puls      b,cc
                    lbcs      SetStatReturn
                    lbsr      Flush
                    lbra      SetStatReturn
sizebad@            coma
                    bra       sizerestore@
setmode@            ldb       #E$BMode
                    coma
                    lbra      SetStatReturn

* Determine WriteLn's actual transfer length before modifying the data cache.
WriteLineCount      tst       F.Line,u
                    beq       linecountok@
                    pshs      x,y
                    ldx       F.Dest,u
                    ldd       F.Move,u
                    pshs      d
linecountloop@      equ       *
                    ifgt      Level-1
                    ldy       <D.Proc
                    ldb       P$Task,y
                    os9       F$LDABX
                    else
                    lda       ,x
                    endc
                    leax      1,x
                    cmpa      #C$CR
                    beq       linecountfound@
                    ldd       ,s
                    subd      #1
                    std       ,s
                    bne       linecountloop@
                    leas      2,s
                    puls      x,y
                    bra       linecountok@
linecountfound@     ldd       F.Move,u
                    subd      ,s++
                    addd      #1
                    std       F.Move,u
                    inc       F.Stop,u
                    puls      x,y
linecountok@        clrb
                    rts


* I$MakDir has no persistent open path. Reuse create resolution with a private
* kind flag, then release the temporary directory path on success or failure.
MkDirImpl           pshs      x,y,u
                    lda       PD.MOD,y
                    pshs      a
                    lda       #DIR.+READ.
                    sta       PD.MOD,y
                    lda       #2
                    lbsr      OpenBegin
                    bcs       mkdirreturn@
                    lbsr      FreePath
mkdirreturn@        puls      a
                    sta       PD.MOD,y
                    puls      x,y,u,pc

* Initialize the child fully before publishing its parent's entry. F.Start is
* still the parent cluster. Return X pointing at the reloaded parent slot.
NewDirectory        lbsr      Allocate
                    bcs       newdirret@
                    ldd       #F.New*256+F.Child
                    lbsr      CopyVal
                    lbsr      ClusterBase
                    bcs       newdirundo@
                    lbsr      ReadData
                    bcs       newdirundo@
                    lda       #F.Child-128
                    lbsr      LoadField
                    leax      F.Data,u
                    bsr       DotEntry
                    lda       #F.Start-128
                    lbsr      LoadField
                    leax      F.Root,u
                    lbsr      CompareVal
                    bne       newdirparent@
* FAT32 encodes a root parent as cluster zero in '..'.
                    clra
                    clrb
                    std       F.Val,u
                    std       F.Val+2,u
newdirparent@       leax      F.Data+32,u
                    bsr       DotEntry
                    lda       #'.
                    sta       F.Data+33,u
                    lbsr      WriteData
                    bcs       newdirundo@
                    lda       #F.Child-128
                    lbsr      LoadField
                    leax      F.Entry,u
                    bsr       EntryCluster
                    lda       #F.DirLBA-128
                    lbsr      LoadField
                    lbsr      ReadData
                    bcs       newdirundo@
                    ldd       F.DirOff,u
                    leax      d,x
                    clrb
newdirret@          rts
* The child is not reachable yet. Best-effort reclaim preserves the original
* error; an additional media error during rollback still requires fsck.
newdirundo@         pshs      b,cc
                    ldd       #F.Child*256+F.Saved
                    lbsr      CopyVal
                    lbsr      FreeChain
                    lbsr      Flush
                    puls      b,cc,pc
DotEntry            pshs      x
                    lbsr      CopyEntryToDisk
                    puls      x
                    pshs      x
                    lda       #C$SPAC
                    ldb       #11
dotname@            sta       ,x+
                    decb
                    bne       dotname@
                    puls      x
                    lda       #'.
                    sta       ,x
EntryCluster        lda       F.Val+1,u
                    sta       20,x
                    lda       F.Val,u
                    sta       21,x
                    lda       F.Val+3,u
                    sta       26,x
                    lda       F.Val+2,u
                    sta       27,x
                    rts


* Reject the volume root, dot aliases, readonly/LFN entries, open directories,
* and any process's data or execution directory before changing the medium.
RemovableDirectory  lbsr      Writable
                    lbcs      rmdirret@
                    lda       F.Entry+11,u
                    bita      #1
                    lbne      AccessError
                    tst       F.HasLFN,u
                    lbne      AccessError
                    lda       F.Name,u
                    cmpa      #'.
                    lbeq      AccessError
                    lda       #F.Start-128
                    lbsr      LoadField
                    leax      F.Root,u
                    lbsr      CompareVal
                    lbeq      AccessError
                    bsr       DirectoryBusy
                    bcs       rmdirret@
                    clr       F.WalkValid,u
                    clra
                    clrb
                    std       F.Scan,u
                    std       F.Scan+2,u
emptyloop@          ldd       #F.Scan*256+F.Offset
                    lbsr      CopyVal
                    lbsr      Locate
                    bcc       emptyslot@
                    cmpb      #E$EOF
                    beq       emptyok@
                    coma
                    bra       rmdirret@
emptyslot@          lda       ,x
                    beq       emptyok@
                    cmpa      #$E5
                    beq       emptynext@
* Only exact '.' and '..' records in their standard slots may be ignored.
                    cmpa      #'.
                    bne       notempty@
                    lda       11,x
                    bita      #$10
                    beq       notempty@
                    ldd       F.Scan,u
                    bne       notempty@
                    ldd       F.Scan+2,u
                    cmpd      #32
                    bhi       notempty@
                    leax      1,x
                    ldb       #10
                    tst       F.Scan+3,u
                    beq       dotspaces@
                    lda       ,x+
                    cmpa      #'.
                    bne       notempty@
                    decb
dotspaces@          lda       ,x+
                    cmpa      #C$SPAC
                    bne       notempty@
                    decb
                    bne       dotspaces@
emptynext@          lbsr      ScanNext
                    bcs       rmdirret@
                    bra       emptyloop@
notempty@           ldb       #E$DNE
                    coma
rmdirret@           rts
emptyok@            clrb
                    rts

DirectoryBusy       pshs      x,y
                    ldx       PD.DEV,y
                    ldx       V$STAT,x
                    ldx       BV.FMPaths,x
busyopen@           cmpx      #0
                    beq       busyprocess@
                    pshs      u
                    cmpx      ,s++
                    beq       busynext@
                    ldd       F.Base,u
                    cmpd      F.Base,x
                    bne       busynext@
                    ldd       F.Base+2,u
                    cmpd      F.Base+2,x
                    bne       busynext@
                    ldd       F.Start,u
                    cmpd      F.Start,x
                    bne       busynext@
                    ldd       F.Start+2,u
                    cmpd      F.Start+2,x
                    beq       busyerror@
busynext@           ldx       F.NextPath,x
                    bra       busyopen@
* Fork inherits these references without opening a path, so scan live process
* descriptors as well as the open-path list. The volume lock excludes ChgDir.
busyprocess@        lda       #1
                    pshs      a
busyid@             lda       ,s
                    ifgt      Level-1
                    os9       F$GProcP
                    else
                    ldx       <D.PrcDBT
                    os9       F$Find64
                    endc
                    bcs       busyadvance@
                    lda       P$State,y
                    bita      #Dead
                    bne       busyadvance@
                    leax      P$DIO,y
                    bsr       DirectoryRef
                    bcs       busyfound@
                    leax      P$DIO+6,y
                    bsr       DirectoryRef
                    bcs       busyfound@
busyadvance@        inc       ,s
                    bne       busyid@
                    clrb
busyfound@          leas      1,s
                    puls      x,y,pc
busyerror@          ldb       #E$Share
                    coma
                    puls      x,y,pc
* X points to a six-byte device/cluster reference. Compare physical device
* statics and partition base so /dd and /pc0 aliases cannot bypass protection.
DirectoryRef        pshs      x,y
                    ldd       2,x
                    cmpd      F.Start,u
                    bne       refok@
                    ldd       4,x
                    cmpd      F.Start+2,u
                    bne       refok@
                    ldx       ,x
                    beq       refok@
                    ldy       F.Owner,u
                    ldy       PD.DEV,y
                    ldd       V$FMGR,x
                    cmpd      V$FMGR,y
                    bne       refok@
                    ldd       V$STAT,x
                    cmpd      V$STAT,y
                    bne       refok@
                    ldx       V$DESC,x
                    ldd       FT.Base,x
                    cmpd      F.Base,u
                    bne       refok@
                    ldd       FT.Base+2,x
                    cmpd      F.Base+2,u
                    bne       refok@
                    bra       busyerror@
refok@              clrb
                    puls      x,y,pc

* SS.Rename: two validated 30-byte basenames, on a writable parent directory.
* F.Record stages the parent's identity (40+6 bytes), source location (6),
* and canonical new name (11). F.Pos is never changed. No extra workspace.
RenameEntry         lda       PD.MOD,y
                    anda      #DIR.+WRITE.
                    cmpa      #DIR.+WRITE.
                    lbne      renameaccess@
                    lda       F.Entry+11,u
                    bita      #$10
                    lbeq      renameaccess@
                    bita      #1
                    lbne      renameaccess@
                    ldd       R$Y,x
                    cmpd      #60
                    lbne      renamebad@
                    std       F.Move,u
                    ldd       R$X,x
                    std       F.Dest,u
                    leax      F.Path,u
                    lbsr      MoveIn
                    lbcs      SetStatReturn
                    leax      F.Path+30,u
                    lbsr      RenameName
                    lbcs      SetStatReturn
                    pshs      y
                    leax      F.Name,u
                    leay      F.Record+52,u
                    ldb       #11
                    lbsr      CopyBytes
                    puls      y
                    leax      F.Path,u
                    lbsr      RenameName
                    lbcs      SetStatReturn
* Save parent identity before Lookup adopts the source child.
                    pshs      y
                    leax      F.Start,u
                    leay      F.Record,u
                    ldb       #40
                    lbsr      CopyBytes
                    leax      F.DirLBA,u
                    ldb       #6
                    lbsr      CopyBytes
                    puls      y
                    lbsr      Lookup
                    lbcs      renamerestore@
                    tst       F.HasLFN,u
                    beq       renamebusy@
                    ldb       #E$FNA
                    coma
                    lbra      renamerestore@
renamebusy@         lda       F.Entry+11,u
                    bita      #$10
                    beq       renamefile@
                    lbsr      DirectoryBusy
                    bra       renamechecked@
renamefile@         lda       #WRITE.
                    lbsr      CheckSharing
renamechecked@      lbcs      renamerestore@
                    pshs      y
                    leax      F.DirLBA,u
                    leay      F.Record+46,u
                    ldb       #6
                    lbsr      CopyBytes
                    leax      F.Record+52,u
                    leay      F.Name,u
                    ldb       #11
                    lbsr      CopyBytes
                    puls      y
* Search the same parent for collisions. Its cluster, not the child, is used.
                    leax      F.Record,u
                    lbsr      LoadVal
                    lda       #F.Start-128
                    lbsr      StoreField
                    lbsr      Lookup
                    bcs       renamemissing@
* Same canonical alias (including case-only changes) is a successful no-op.
                    pshs      y
                    leax      F.DirLBA,u
                    leay      F.Record+46,u
                    ldb       #6
renamecompare@      lda       ,x+
                    cmpa      ,y+
                    bne       renameexists@
                    decb
                    bne       renamecompare@
                    puls      y
                    clrb
                    bra       renamerestore@
renameexists@       puls      y
                    ldb       #E$CEF
                    coma
                    bra       renamerestore@
renamemissing@      cmpb      #E$PNNF
                    bne       renameerror@
                    leax      F.Record+46,u
                    lbsr      LoadVal
                    lbsr      ReadData
                    bcs       renamerestore@
                    ldd       F.Record+50,u
                    leax      d,x
                    pshs      y
                    leay      F.Record+52,u
                    ldb       #11
renamestore@        lda       ,y+
                    sta       ,x+
                    decb
                    bne       renamestore@
* New short names are uppercase; clear NT lowercase flags, preserve metadata.
                    lda       1,x
                    anda      #$E7
                    sta       1,x
                    puls      y
                    lbsr      WriteData
                    bcs       renamerestore@
                    lbsr      Flush
                    bra       renamerestore@
renameerror@        coma
renamerestore@      pshs      b,cc,y
                    leax      F.Record,u
                    leay      F.Start,u
                    ldb       #40
                    bsr       CopyBytes
                    leay      F.DirLBA,u
                    ldb       #6
                    bsr       CopyBytes
                    clr       F.WalkValid,u
                    puls      b,cc,y
                    lbra      SetStatReturn
renameaccess@       ldb       #E$FNA
                    coma
                    lbra      SetStatReturn
renamebad@          ldb       #E$BPNam
                    coma
                    lbra      SetStatReturn
RenameName          pshs      x
                    bsr       RNName
                    puls      x
                    bcs       renamenameret@
                    stx       F.Cursor,u
                    lbsr      ParseName
                    bcs       renamenameret@
                    tst       F.Dots,u
                    lbne      PathError
                    clrb
renamenameret@      rts
* X source, Y destination, B byte count. Used only with nonoverlapping buffers.
CopyBytes          lda       ,x+
                    sta       ,y+
                    decb
                    bne       CopyBytes
                    rts
                    use       rename-name.d
