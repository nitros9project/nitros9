* s9g: drive menu from loaded RBF descriptors ('m'); studio9.cfg XML remembers drive paths.
* 'r', root: remember current directory in RAM; restore the requested drive.
* 's': remember only. 'e': remember and flush once at normal application exit.
* XML is C-heap owned across overlay unloads; temporary directory work is on S.
                    nam       s9g
UME_SCOPE_S9G                  equ       1
                    use       equates.asm
                  IFP1
                    use       defsfile
                  ENDC
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,$104C
name                fcs       /s9g/
                    fcb       1
* Startup enumerates modules without opening studio9.cfg. Other commands keep
* per-drive paths; check their larger work frame before touching the stack.
start               ldb       3,s
                    cmpb      #'m
                    lbeq      DriveMenuEntry
ConfigEntry         pshs      x,y,u
                    ldx       >UmeData_c_heaptop
                    cmpx      #UmeStaticEnd
                    bhs       cfgheap@
                    ldx       #UmeStaticEnd
cfgheap@            ldd       >pConfigCache
                    bne       cfgcheck@
                    leax      CfgCacheBytes,x     first use: reserve persistent XML, not another stack copy
cfgcheck@           leay      -Frame-128,s
                    pshs      x
                    cmpy      ,s++
                    bls       cfgspace@
                    ldd       >pConfigCache
                    bne       cfgframe@
                    stx       >UmeData_c_heaptop
                    leax      -CfgCacheBytes,x
                    stx       >pConfigCache
                    clr       CfgCacheState,x
                    clr       CfgCacheEnd,x
                    clr       CfgCacheEnd+1,x
                    bra       cfgframe@
cfgspace@           ldb       9,s                 STACK OFFSET: command above saved X/Y/U and return
                    cmpb      #'r
                    bne       cfgskip@
                    ldx       10,s                STACK OFFSET: requested root argument
                    lda       #READ.
                    os9       I$ChgDir
                    bcc       cfgskip@
                    ldd       #-1
                    puls      x,y,u,pc
cfgskip@            clra
                    clrb
                    puls      x,y,u,pc
cfgframe@           leas      -Frame,s
                    tfr       s,u
                    ldx       >pConfigCache
                    ldd       CfgCacheEnd,x
                    std       DocEnd,u
                    leax      CfgCacheXml,x
                    stx       Xml,u
                    ldb       Frame+9,u           STACK OFFSET: caller command
                    stb       Cmd,u
                    clr       Root,u
                    clr       Root+1,u
                    clr       Root+2,u
                    clr       Root+3,u
                    cmpb      #'r
                    bne       cfgsave@
                    ldx       Frame+10,u          STACK OFFSET: requested root argument
                    ldd       ,x
                    std       Root,u
                    ldd       2,x
                    std       Root+2,u
cfgsave@            lbsr      CachedConfig
                    bcs       cfgselect@
                    lbsr      SaveCurrent
cfgselect@          ldb       Cmd,u
                    cmpb      #'e
                    beq       cfgflush@
                    cmpb      #'r
                    bne       CfgOk
                    lbsr      CachedConfig
                    bcs       cfgroot@
                    lbsr      MakeTag
                    lbsr      FindValue
                    bcs       cfgroot@
                    lbsr      DecodePath
                    bcs       cfgroot@
                    leax      PathBuf,u
                    lda       #READ.
                    os9       I$ChgDir
                    bcc       CfgOk
cfgroot@            leax      Root,u
                    lda       #READ.
                    os9       I$ChgDir
                    bcc       CfgOk
                    ldd       #-1
                    bra       cfgexit@
cfgflush@           ldx       >pConfigCache
                    lda       CfgCacheState,x
                    cmpa      #CfgValid+CfgDirty
                    bne       CfgOk
                    lbsr      WriteConfig         the sole disk-write caller: normal application exit
CfgOk               clra
                    clrb
cfgexit@            leas      Frame,s
                    puls      x,y,u,pc

* Read once. Missing settings start an empty in-memory document; malformed or
* unreadable settings remain untouched. A failed read never blocks startup.
CachedConfig        ldx       >pConfigCache
                    lda       CfgCacheState,x
                    beq       ccfirst@
                    bita      #CfgValid
                    beq       ccbad@
                    andcc     #$FE
                    rts
ccfirst@            lda       #CfgBlocked
                    sta       CfgCacheState,x
                    lbsr      ReadConfig
                    bcc       ccgood@
                    leax      ConfigName,pcr
                    lda       #READ.
                    os9       I$Open
                    bcc       ccexists@
                    cmpb      #E$PNNF
                    bne       ccbad@
                    ldx       Xml,u
                    leay      EmptyXml,pcr
ccempty@            lda       ,y+
                    sta       ,x+
                    bne       ccempty@
                    leax      -1,x
                    stx       DocEnd,u
ccgood@             ldx       >pConfigCache
                    lda       #CfgValid
                    sta       CfgCacheState,x
                    ldd       DocEnd,u
                    std       CfgCacheEnd,x
                    andcc     #$FE
                    rts
ccexists@           os9       I$Close
ccbad@              orcc      #1
                    rts

* Open directories without changing cwd. Scan parents by FD sector number.
GetCurrent          leax      PathBuf+256,u
                    clr       ,x
                    stx       PathPtr,u
                    leax      Rel,u
                    lda       #'.
                    sta       ,x
                    clr       1,x
                    lbsr      OpenDir
                    lbcs      gcerr@
                    leax      Dev,u
                    ldb       #SS.DevNm
                    lda       Fd,u
                    os9       I$GetStt
                    lbcs      gcclose@
gcdots@             leax      Entry,u
                    ldy       #64
                    lbsr      ReadBytes
                    lbcs      gcclose@
                    cmpy      #64
                    lbne      gcclose@
                    leax      Entry,u
                    lda       ,x
                    cmpa      #$AE
                    beq       gcfirst@
                    leax      32,x
gcfirst@            lda       29,x
                    sta       Own,u
                    ldd       30,x
                    std       Own+1,u
                    leax      Entry,u
                    lda       ,x
                    cmpa      #$AE
                    bne       gcparent@
                    leax      32,x
gcparent@           lda       29,x
                    sta       Parent,u
                    ldd       30,x
                    std       Parent+1,u
                    lbsr      CloseFd
                    lda       Own,u
                    cmpa      Parent,u
                    bne       gcup@
                    ldd       Own+1,u
                    cmpd      Parent+1,u
                    beq       gcroot@
gcup@               leax      Rel,u
gcendrel@           tst       ,x+
                    bne       gcendrel@
                    leax      -1,x
                    leay      Rel+123,u
                    pshs      y
                    cmpx      ,s++
                    bhi       gcerr@
                    ldd       #$2F2E
                    std       ,x++
                    lda       #'.
                    sta       ,x+
                    clr       ,x
                    leax      Rel,u
                    lbsr      OpenDir
                    bcs       gcerr@
gcscan@             leax      Entry,u
                    ldy       #32
                    lbsr      ReadBytes
                    lbcs      gcclose@
                    cmpy      #32
                    lbne      gcclose@
                    lda       Entry,u
                    beq       gcscan@
                    lda       Entry+29,u
                    cmpa      Own,u
                    bne       gcscan@
                    ldd       Entry+30,u
                    cmpd      Own+1,u
                    bne       gcscan@
                    leax      Entry,u
                    lbsr      PrependName
                    lbcs      gcclose@
* Reopen the parent at offset zero to read its dot entries.
                    lbsr      CloseFd
                    leax      Rel,u
                    lbsr      OpenDir
                    bcs       gcerr@
                    lbra      gcdots@
gcroot@             leax      Dev,u
                    lbsr      PrependName
                    bcs       gcerr@
                    ldx       PathPtr,u
                    andcc     #$FE
                    rts
gcclose@            lbsr      CloseFd
gcerr@              orcc      #1
                    rts

* X is a high-bit terminated OS-9 name. Prepend /name to PathPtr.
PrependName         stx       Tmp,u
                    ldb       #32
pnend@              lda       ,x+
                    bmi       pnfound@
                    beq       pnnul@
                    decb
                    bne       pnend@
                    bra       pnerr@
pnnul@              leax      -1,x
pnfound@            tfr       x,d
                    subd      Tmp,u
                    beq       pnerr@
                    std       ValueEnd,u
                    ldx       PathPtr,u
                    tfr       x,d
                    subd      ValueEnd,u
                    subd      #1
                    leay      PathBuf,u
                    pshs      y
                    cmpd      ,s++
                    blo       pnerr@
                    tfr       d,x
                    stx       PathPtr,u
                    lda       #'/
                    sta       ,x+
                    ldy       Tmp,u
                    ldd       ValueEnd,u
                    stb       ValueEnd,u
pncopy@             lda       ,y+
                    anda      #$7F
                    sta       ,x+
                    dec       ValueEnd,u
                    bne       pncopy@
                    andcc     #$FE
                    rts
pnerr@              orcc      #1
                    rts

OpenDir             lda       #READ.+DIR.
                    os9       I$Open
                    bcs       odret@
                    sta       Fd,u
odret@              rts
ReadBytes           lda       Fd,u
                    os9       I$Read
                    rts
CloseFd             lda       Fd,u
                    os9       I$Close
                    rts

* Read at most Cap bytes; reject oversized/truncated/non-studio9 documents.
ReadConfig          leax      ConfigName,pcr
                    lda       #READ.
                    os9       I$Open
                    lbcs      rcerr@
                    sta       Fd,u
                    ldx       Xml,u
                    ldy       #Cap
                    lbsr      ReadBytes
                    bcs       rcclose@
                    cmpy      #Cap
                    bhs       rcclose@
                    ldx       Xml,u
                    tfr       y,d
                    leax      d,x
                    clr       ,x
                    stx       DocEnd,u
                    lbsr      CloseFd
                    ldx       Xml,u
                    leay      XmlOpen,pcr
                    lbsr      Match
                    bcs       rcerr@
                    ldx       Xml,u
                    leay      XmlClose,pcr
                    lbsr      Find
                    bcs       rcerr@
* Find returns X just after closing root; only whitespace may follow.
rctail@             lda       ,x+
                    beq       rcok@
                    cmpa      #32
                    beq       rctail@
                    cmpa      #13
                    beq       rctail@
                    cmpa      #10
                    beq       rctail@
                    cmpa      #9
                    beq       rctail@
                    bra       rcerr@
rcok@               andcc     #$FE
                    rts
rcclose@            lbsr      CloseFd
rcerr@              orcc      #1
                    rts

* Match NUL-terminated Y against X. Success advances X, preserves Y.
Match               pshs      y
matchloop@          lda       ,y+
                    beq       matchok@
                    cmpa      ,x+
                    bne       matchbad@
                    bra       matchloop@
matchok@            andcc     #$FE
                    puls      y,pc
matchbad@           orcc      #1
                    puls      y,pc
Find                tst       ,x
                    beq       findbad@
                    pshs      x
                    lbsr      Match
                    bcc       findok@
                    puls      x
                    leax      1,x
                    bra       Find
findok@             leas      2,s
                    rts
findbad@            orcc      #1
                    rts

* Tags are drive names (<d0>, <dd>, ...) under <studio9>; no drive numbers in the file.
MakeTag             leax      Tag,u
                    lda       #'<
                    sta       ,x+
                    leay      Root+1,u
mtcopy@             lda       ,y+
                    beq       mtend@
                    sta       ,x+
                    bra       mtcopy@
mtend@              lda       #'>
                    sta       ,x+
                    clr       ,x
                    rts
FindValue           ldx       Xml,u
                    leay      Tag,u
                    lbsr      Find
                    bcs       fvret@
                    stx       Value,u
fvscan@             lda       ,x+
                    beq       fvbad@
                    cmpa      #'<
                    bne       fvscan@
                    leax      -1,x
                    stx       ValueEnd,u
                    ldd       ,x++
                    cmpd      #$3C2F
                    bne       fvbad@
                    leay      Root+1,u
fvname@             lda       ,y+
                    beq       fvend@
                    cmpa      ,x+
                    bne       fvbad@
                    bra       fvname@
fvend@              lda       ,x
                    cmpa      #'>
                    bne       fvbad@
                    andcc     #$FE
fvret@              rts
fvbad@              orcc      #1
                    rts

* Decode entities into a bounded absolute path, confined to the requested drive.
DecodePath          ldx       Value,u
                    leay      PathBuf,u
dpnext@             cmpx      ValueEnd,u
                    bhs       dpdone@
                    leay      0,y
                    tfr       y,d
                    pshs      x
                    leax      PathBuf+127,u
                    pshs      x
                    cmpd      ,s++
                    puls      x
                    lbhs      dpbad@
                    lda       ,x+
                    cmpa      #'&
                    bne       dpput@
                    pshs      y
                    leay      Entities,pcr
dptest@             ldb       ,y+
                    beq       dpentitybad@
                    pshs      x,b
                    lbsr      Match
                    bcc       dpentityok@
                    puls      b,x
dpskip@             tst       ,y+
                    bne       dpskip@
                    bra       dptest@
dpentityok@         puls      b
                    leas      2,s
                    tfr       b,a
                    puls      y
                    bra       dpput@
dpentitybad@        puls      y
                    bra       dpbad@
dpput@              cmpa      #32
                    blo       dpbad@
                    cmpa      #$7F
                    lbhs      dpbad@
                    sta       ,y+
                    bra       dpnext@
dpdone@             clr       ,y
                    leax      PathBuf,u
                    leay      Root,u
dproot@             lda       ,y+
                    beq       dprootend@
                    cmpa      ,x+
                    bne       dpbad@
                    bra       dproot@
dprootend@          lda       ,x
                    beq       dpok@
                    cmpa      #'/
                    bne       dpbad@
                    leax      PathBuf,u
* Reject . and .. components so a hand-edited path cannot leave its drive.
dpcomponent@        lda       ,x+
                    beq       dpok@
                    cmpa      #'/
                    bne       dpcomponent@
                    lda       ,x
                    cmpa      #'.
                    bne       dpcomponent@
                    lda       1,x
                    beq       dpbad@
                    cmpa      #'/
                    beq       dpbad@
                    cmpa      #'.
                    bne       dpcomponent@
                    lda       2,x
                    beq       dpbad@
                    cmpa      #'/
                    beq       dpbad@
                    bra       dpcomponent@
dpok@               andcc     #$FE
                    rts
dpbad@              orcc      #1
                    rts

* Serialize current path, escaping XML metacharacters. Root is only a scratch
* key here; restore the requested root before the restore phase.
SaveCurrent         pshs      d,x,y
                    ldd       Root,u
                    pshs      d
                    ldd       Root+2,u
                    pshs      d
                    lbsr      GetCurrent
                    lbcs      scdone@
* The settings file stores at most 127 characters, even for a longer current path.
                    pshs      x
                    ldb       #127
sclimit@            tst       ,x+
                    beq       sclimited@
                    decb
                    bne       sclimit@
                    clr       ,x
sclimited@          puls      x
                    lda       #'/
                    sta       Root,u
                    lda       1,x
                    ora       #$20
                    cmpa      #'a
                    lblo      scdone@
                    cmpa      #'z
                    lbhi      scdone@
                    sta       Root+1,u
                    clr       Root+2,u
                    clr       Root+3,u
                    lda       2,x
                    beq       scdrive@
                    cmpa      #'/
                    beq       scdrive@
                    ora       #$20
                    lbsr      NameChar
                    lbcs      scdone@
                    sta       Root+2,u
                    lda       3,x
                    beq       scdrive@
                    cmpa      #'/
                    lbne      scdone@
scdrive@            leay      Enc,u
scencode@           lda       ,x+
                    beq       scencoded@
                    pshs      x
                    leax      Entities,pcr
scentity@           ldb       ,x+
                    beq       scliteral@
                    pshs      y
                    cmpa      -1,x
                    puls      y
                    beq       scescape@
scskip@             tst       ,x+
                    bne       scskip@
                    bra       scentity@
scliteral@          sta       ,y+
                    bra       scnext@
scescape@           lda       #'&
                    sta       ,y+
scstr@              lda       ,x+
                    beq       scnext@
                    sta       ,y+
                    bra       scstr@
scnext@             puls      x
                    bra       scencode@
scencoded@          clr       ,y
scread@             lbsr      MakeTag
                    lbsr      FindValue
                    lbcc      screplace@
* Insert a missing drive immediately before the root closing tag.
                    ldx       Xml,u
                    leay      XmlClose,pcr
                    lbsr      Find
                    lbcs      scdone@
                    leax      -10,x
                    stx       Value,u
                    stx       ValueEnd,u
* Enc receives <drive>escaped-path</drive> CR. Shift existing text right 4.
                    leax      Enc,u
scenclen@           tst       ,x+
                    bne       scenclen@
                    leax      -1,x
                    leay      4,x
scshift@            lda       ,x
                    sta       ,y
                    leay      -1,y
                    leax      -1,x
                    tfr       x,d
                    pshs      x
                    leax      Enc,u
                    pshs      x
                    cmpd      ,s++
                    puls      x
                    bhs       scshift@
                    leax      Enc,u
                    lda       #'<
                    sta       ,x+
                    lda       Root+1,u
                    sta       ,x+
                    lda       Root+2,u
                    bne       sctwo@
* Remove the extra opening-tag byte reserved by the four-byte shift.
                    leay      Enc+4,u
                    lda       #'>
                    sta       ,x+
scone@              lda       ,y+
                    sta       ,x+
                    bne       scone@
                    leax      -1,x
                    bra       scclosing@
sctwo@              sta       ,x+
                    lda       #'>
                    sta       ,x+
scendenc@           tst       ,x+
                    bne       scendenc@
                    leax      -1,x
scclosing@          ldd       #$3C2F
                    std       ,x++
                    lda       Root+1,u
                    sta       ,x+
                    lda       Root+2,u
                    beq       scclosend@
                    sta       ,x+
scclosend@          ldd       #$3E0D
                    std       ,x++
                    clr       ,x
screplace@          lbsr      ReplaceValue
                    bcs       scdone@
                    ldx       >pConfigCache
                    lda       #CfgValid+CfgDirty
                    sta       CfgCacheState,x
                    ldd       DocEnd,u
                    std       CfgCacheEnd,x
scdone@             puls      d
                    std       Root+2,u
                    puls      d
                    std       Root,u
                    puls      d,x,y,pc

* Replace [Value,ValueEnd) with Enc, bounded to Cap. Preserve the entire suffix.
ReplaceValue        leax      Enc,u
rvlen@              tst       ,x+
                    bne       rvlen@
                    leax      -1,x
                    tfr       x,d
                    leax      Enc,u
                    pshs      x
                    subd      ,s++
                    addd      Value,u
                    std       Tmp,u              new suffix start
                    subd      ValueEnd,u          signed size change
                    addd      DocEnd,u
                    ldx       Xml,u
                    leax      Cap,x
                    pshs      x
                    cmpd      ,s++
                    bhs       rvbad@
                    pshs      d                   new document end
                    ldx       ValueEnd,u
                    ldy       Tmp,u
                    cmpy      ValueEnd,u
                    bls       rvforward@
                    ldx       DocEnd,u
                    ldy       ,s
rvback@             lda       ,x
                    sta       ,y
                    cmpx      ValueEnd,u
                    beq       rvcopy@
                    leax      -1,x
                    leay      -1,y
                    bra       rvback@
rvforward@          lda       ,x+
                    sta       ,y+
                    tsta
                    bne       rvforward@
rvcopy@             puls      d
                    std       DocEnd,u
                    leax      Enc,u
                    ldy       Value,u
rvput@              lda       ,x+
                    beq       rvgood@
                    sta       ,y+
                    bra       rvput@
rvgood@             andcc     #$FE
                    rts
rvbad@              orcc      #1
                    rts

* Open/update and truncate to exact length after a complete write. A failed
* save is nonfatal; future reads reject a partial document and use drive root.
WriteConfig         leax      ConfigName,pcr
                    lda       #WRITE.
                    os9       I$Open
                    bcc       wcopen@
                    cmpb      #E$PNNF
                    bne       wcret@
                    leax      ConfigName,pcr
                    lda       #WRITE.
                    ldb       #READ.+WRITE.
                    os9       I$Create
                    bcs       wcret@
wcopen@             sta       Fd,u
                    ldd       DocEnd,u
                    ldx       Xml,u
                    pshs      x
                    subd      ,s++
                    tfr       d,y
                    pshs      d
                    lda       Fd,u
                    os9       I$Write
                    bcs       wcskip@
                    cmpy      ,s
                    bne       wcskip@
                    pshs      u
                    ldu       2,s
                    ldx       #0
                    ldb       #SS.Size
                    os9       I$SetStt
                    puls      u
wcskip@             leas      2,s
                    lbsr      CloseFd
wcret@              rts

* F$GModDr's documented 2048-byte buffer covers WildBits' $0A00-$0FFF
* module directory/DAT area. Keep it off the persistent heap and check the
* complete frame BEFORE reserving it. All syscall-returned U values are saved.
DriveMenuEntry      pshs      x,y,u
                    clr       >pConfigCache
                    clr       >pConfigCache+1
                    clr       >pDriveMenu
                    clr       >pDriveMenu+1
                    ldx       >UmeData_c_heaptop
                    cmpx      #UmeStaticEnd
                    bhs       dmheap@
                    ldx       #UmeStaticEnd
dmheap@             leay      83,x
                    pshs      y
                    leay      -DmFrame-128,s
                    cmpy      ,s++
                    bls       dmnospace@
                    stx       >pDriveMenu
                    leay      83,x
                    sty       >UmeData_c_heaptop
                    leas      -DmFrame,s
                    tfr       s,u
                    lbra      InitDriveMenu
dmnospace@          ldd       #-1
                    puls      x,y,u,pc
InitDriveMenu       equ       *
                    leay      MenuTemplate,pcr
                    ldb       #64
imcopy@             lda       ,y+
                    sta       ,x+
                    decb
                    bne       imcopy@
                    ldb       #19
imzero@             clr       ,x+
                    decb
                    bne       imzero@
                    ldx       >pDriveMenu
                    leax      40,x
                    ldb       #6
imdisable@          lda       #$FF
                    sta       ,x
                    leax      4,x
                    decb
                    bne       imdisable@
                    leax      DmDir,u
                    pshs      u
                    os9       F$GModDr
                    tfr       u,d                 system directory base
                    puls      u
                    lbcs      imlayout@
                    std       DmSys,u
                    sty       DmEnd,u
                    stx       DmCur,u
                    leay      DmDir+2048,u
                    cmpy      DmEnd,u
                    lblo      imlayout@
dmscan@             ldx       DmCur,u
                    cmpx      DmEnd,u
                    lbhs      imlayout@
                    leay      MD$ESize,x
                    sty       DmCur,u
                    cmpy      DmEnd,u
                    lbhi      imlayout@
                    ldd       MD$MPDAT,x
                    lbeq      dmscan@
                    subd      DmSys,u
                    cmpd      #2048-16
                    lbhi      dmscan@
                    leay      DmDir,u
                    leay      d,y
                    sty       DmDat,u
                    ldx       MD$MPtr,x
                    stx       DmMod,u
                    tfr       y,d
                    leay      DmHead,u
                    pshs      u
                    tfr       y,u
                    ldy       #M$DTyp+1
                    os9       F$CpyMem
                    puls      u
                    lbcs      dmscan@
                    lda       DmHead+M$Type,u
                    anda      #$F0
                    cmpa      #Devic
                    lbne      dmscan@
                    lda       DmHead+M$DTyp,u
                    cmpa      #DT.RBF
                    lbne      dmscan@
* Reject rbmem by descriptor DRIVER name, not by the drive's displayed name.
                    ldd       DmHead+M$PDev,u
                    lbsr      DriveReadName
                    lbcs      dmscan@
                    leax      DmText,u
                    leay      RbmemName,pcr
                    ldb       #5
dmrbmem@            lda       ,x+
                    anda      #$7F
                    ora       #$20
                    cmpa      ,y+
                    bne       dmgetname@
                    decb
                    bne       dmrbmem@
                    tst       -1,x
                    lbmi      dmscan@
dmgetname@          ldd       DmHead+M$Name,u
                    lbsr      DriveReadName
                    lbcs      dmscan@
                    clr       DmName+2,u
                    clr       DmName+3,u
                    lda       DmText,u
                    lbsr      DriveFirstChar
                    lbcs      dmscan@
                    sta       DmName+1,u
                    tst       DmText,u
                    bmi       dmunique@
                    lda       DmText+1,u
                    lbpl      dmscan@             no names longer than two characters
                    anda      #$7F
                    ora       #$20
                    lbsr      NameChar
                    lbcs      dmscan@
                    sta       DmName+2,u
dmunique@           ldy       >pDriveMenu
                    ldb       82,y
                    stb       DmSlot,u
                    leay      64,y
dmdups@             tst       DmSlot,u
                    beq       dmadd@
                    ldd       ,y
                    cmpd      DmName+1,u
                    lbeq      dmscan@
                    leay      3,y
                    dec       DmSlot,u
                    bra       dmdups@
dmadd@              ldx       >pDriveMenu
                    ldb       82,x
                    inc       82,x
                    lda       #3
                    mul
                    leax      d,x
                    ldd       DmName+1,u
                    std       64,x
                    ldx       >pDriveMenu
                    ldb       82,x
                    cmpb      #6
                    lblo      dmscan@
imlayout@           ldx       >pDriveMenu
                    ldb       82,x
                    stb       DmSlot,u
                    clr       DmCol,u           total width
                    leax      64,x
imwidth@            tst       DmSlot,u
                    beq       imposition@
                    ldd       ,x
                    andb      #$DF
                    anda      #$DF
                    cmpd      #$4444
                    bne       miwidth@
                    inc       DmCol,u
                    inc       DmCol,u
miwidth@            equ       *
                    inc       DmCol,u           leading space
                    inc       DmCol,u           first character
                    tst       1,x
                    beq       imwidthnext@
                    inc       DmCol,u
imwidthnext@        leax      3,x
                    dec       DmSlot,u
                    bra       imwidth@
imposition@         lda       #79
                    suba      DmCol,u
                    sta       DmCol,u           first column
                    clr       DmSlot,u              slot index
imslot@             ldx       >pDriveMenu
                    ldb       DmSlot,u
                    cmpb      82,x
                    bhs       imblank@
                    lda       #4
                    mul
                    leay      d,x
                    pshs      x
                    ldb       DmSlot,u
                    lda       #3
                    mul
                    leax      d,x
                    ldd       64,x
                    anda      #$DF
                    andb      #$DF
                    cmpd      #$4444
                    bne       midrive@
                    inc       DmCol,u
                    inc       DmCol,u
midrive@            puls      x
                    lda       DmCol,u
                    sta       40,y
                    ldb       DmSlot,u
                    lda       #3
                    mul
                    leax      d,x
                    lda       #2
                    tst       65,x
                    beq       imsize@
                    inca
imsize@             adda      DmCol,u
                    sta       DmCol,u
                    deca
                    sta       42,y
                    bra       imsend@
imblank@            ldx       >pDriveMenu
                    ldb       DmSlot,u
                    lda       #3
                    mul
                    leax      d,x
imsend@             stx       DmPtr,u
                    ldb       #FrDriveLabelCmd
                    lbsr      MenuPutc
                    ldb       DmSlot,u
                    lbsr      MenuPutc
                    ldx       >pDriveMenu
                    ldb       DmSlot,u
                    lda       #4
                    mul
                    leax      d,x
                    ldb       40,x
                    lbsr      MenuPutc
                    ldx       DmPtr,u
                    ldb       64,x
                    beq       imchar1@
                    andb      #$DF
imchar1@            lbsr      MenuPutc
                    ldx       DmPtr,u
                    ldb       65,x
                    cmpb      #'a
                    blo       imchar2@
                    andb      #$DF
imchar2@            lbsr      MenuPutc
                    inc       DmSlot,u
                    lda       DmSlot,u
                    cmpa      #6
                    lblo      imslot@
                    lbra      DriveMenuDone
DriveMenuDone       clra
                    clrb
                    leas      DmFrame,s
                    puls      x,y,u,pc
* D = descriptor-relative string offset; copy only eight bytes for filtering.
DriveReadName       ldx       DmMod,u
                    leax      d,x
                    ldd       DmDat,u
                    leay      DmText,u
                    pshs      u
                    tfr       y,u
                    ldy       #8
                    os9       F$CpyMem
                    puls      u,pc
DriveFirstChar      anda      #$7F
                    ora       #$20
                    cmpa      #'a
                    blo       dfbad@
                    cmpa      #'z
                    bhi       dfbad@
                    andcc     #$FE
                    rts
dfbad@              orcc      #1
                    rts
RbmemName           fcc       /rbmem/
MenuPutc            pshs      x,y,u
                    ldy       DmFrame+2,u         C callback requires caller static base
                    clra
                    pshs      d
                    jsr       [>UmeData_pputchar]
                    leas      2,s
                    puls      x,y,u,pc
NameChar            cmpa      #'0
                    blo       ncbad@
                    cmpa      #'9
                    bls       ncgood@
                    cmpa      #'a
                    blo       ncbad@
                    cmpa      #'z
                    bhi       ncbad@
ncgood@             andcc     #$FE
                    rts
ncbad@              orcc      #1
                    rts
MenuTemplate      fcb       MenuBarC0,MenuBarY1,MenuBarC0+MenuBarW0-1,MenuBarY2
                    fcb       MenuBarC1,MenuBarY1,MenuBarC1+MenuBarW1-1,MenuBarY2
                    fcb       MenuBarC2,MenuBarY1,MenuBarC2+MenuBarW2-1,MenuBarY2
                    fcb       MenuBarC3,MenuBarY1,MenuBarC3+MenuBarW3-1,MenuBarY2
                    fcb       MenuBarC4,MenuBarY1,MenuBarC4+MenuBarW4-1,MenuBarY2
                    fcb       MenuBarC5,MenuBarY1,MenuBarC5+MenuBarW5-1,MenuBarY2
                    fcb       MenuBarC6,MenuBarY1,MenuBarC6+MenuBarW6-1,MenuBarY2
                    fcb       MenuBarC7,MenuBarY1,MenuBarC7+MenuBarW7-1,MenuBarY2
                    fcb       MenuBarC8,MenuBarY1,MenuBarC8+MenuBarW8-1,MenuBarY2
                    fcb       MenuBarC9,MenuBarY1,MenuBarC9+MenuBarW9-1,MenuBarY2
                    fcb       MenuBarC10,MenuBarY1,MenuBarC10+MenuBarW10-1,MenuBarY2
                    fcb       MenuBarC11,MenuBarY1,MenuBarC11+MenuBarW11-1,MenuBarY2
                    fcb       MenuBarC12,MenuBarY1,MenuBarC12+MenuBarW12-1,MenuBarY2
                    fcb       MenuBarC13,MenuBarY1,MenuBarC13+MenuBarW13-1,MenuBarY2
                    fcb       MenuBarC14,MenuBarY1,MenuBarC14+MenuBarW14-1,MenuBarY2
                    fcb       MenuBarC15,MenuBarY1,MenuBarC15+MenuBarW15-1,MenuBarY2
ConfigName          fcc       "/dd/sys/studio9.cfg"
                    fcb       0
XmlOpen             fcc       /<studio9>/
                    fcb       0
XmlClose            fcc       "</studio9>"
                    fcb       0
EmptyXml            fcc       /<studio9>/
                    fcb       13
                    fcc       "</studio9>"
                    fcb       13,0
Entities            fcb       '&
                    fcc       /amp;/
                    fcb       0,'<
                    fcc       /lt;/
                    fcb       0,'>
                    fcc       /gt;/
                    fcb       0,'"
                    fcc       /quot;/
                    fcb       0,39
                    fcc       /apos;/
                    fcb       0,0
                    emod
eom                 equ       *
