* Two real processes interleave links to different members of one file.
                    use       defsfile
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,size
                    use       runtime-data.asm
name                fcs       /MultiProc/
                    fcb       1
reportname          fcc       "/dd/parent.bin"
                    fcb       C$CR
filename            fcc       "/dd/long.grp"
                    fcb       C$CR
memberb             fcs       /LongB/
workername          fcs       /GrpWorker/
param0              fcb       'm','0',C$CR
param1              fcb       'm','1',C$CR
passed              fcc       /MULTIPROCESSPASS/
                    fcb       C$CR
start               lbsr      initmap
                    leax      intercept,pcr
                    os9       F$Icpt
                    lbcs      fail
                    lda       #'P'
                    sta       role,u
                    clr       reverse,u
                    ldd       #1
                    std       sequence,u
                    leax      reportname,pcr
                    lda       #WRITE.
                    ldb       #READ.+WRITE.
                    os9       I$Create
                    lbcs      fail
                    sta       outpath,u
nextcase            clra
                    clrb
                    std       held,u
                    std       extra,u
                    clr       peer,u
                    clr       event,u
                    clra
                    lbsr      snapshot
                    leax      filename,pcr
                    clra
                    pshs      u
                    os9       F$Load
                    tfr       u,x
                    puls      u
                    lbcs      fail
                    stx       held,u
                    sty       entryheld,u
                    tst       reverse,u
                    beq       forkchild
* Reverse case: parent holds B; child will hold A.
                    leax      memberb,pcr
                    clra
                    pshs      u
                    os9       F$Link
                    tfr       u,x
                    puls      u
                    lbcs      fail
                    stx       extra,u
                    sty       entryextra,u
                    lbsr      unlinkheld
                    ldd       extra,u
                    std       held,u
                    ldd       entryextra,u
                    std       entryheld,u
forkchild           leax      workername,pcr
                    leay      param0,pcr
                    tst       reverse,u
                    beq       doparam
                    leay      param1,pcr
doparam             pshs      u
                    tfr       y,u
                    ldy       #3
                    clra
                    clrb
                    os9       F$Fork
                    puls      u
                    lbcs      fail
                    sta       peer,u
                    lda       #4
                    lbsr      waitsignal
                    lda       #1
                    lbsr      snapshot
                    jsr       [entryheld,u]
                    lda       reverse,u
                    adda      #$A1
                    pshs      b
                    cmpa      ,s+
                    lbne      bad
                    lbsr      unlinkheld
                    lbsr      unlinkheld
                    lda       #2
                    lbsr      snapshot
                    ldb       #5
                    lbsr      notify
* Child links the parent's former member. Its global count is nonzero again.
                    lda       #6
                    lbsr      waitsignal
                    lbsr      unlinkheld
                    lda       #3
                    lbsr      snapshot
                    ldb       #7
                    lbsr      notify
                    os9       F$Wait
                    lbcs      fail
                    cmpa      peer,u
                    lbne      bad
                    tstb
                    lbne      fail
                    lda       #4
                    lbsr      snapshot
                    tst       reverse,u
                    bne       finished
                    inc       reverse,u
                    ldd       #2
                    std       sequence,u
                    lbra      nextcase
finished            lda       outpath,u
                    os9       I$Close
                    lbcs      fail
                    leax      passed,pcr
                    ldy       #17
                    lda       #1
                    os9       I$WritLn
                    clrb
                    os9       F$Exit
                    use       runtime-support.asm
                    emod
eom                 equ       *
