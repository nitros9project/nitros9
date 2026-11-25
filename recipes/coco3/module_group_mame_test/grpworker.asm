* Child for synchronized module ownership and repeated process cleanup tests.
                    use       defsfile
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,size
                    use       runtime-data.asm
                    org       size-512
mode                rmb       1
filehandle          rmb       1
readbyte            rmb       1
                    rmb       509
name                fcs       /GrpWorker/
                    fcb       1
report0             fcc       "/dd/child1.bin"
                    fcb       C$CR
report1             fcc       "/dd/child2.bin"
                    fcb       C$CR
membera             fcs       /LongA/
memberb             fcs       /LongB/
shortb              fcs       /ShortB/
leakfile            fcc       "/dd/leak.tmp"
                    fcb       C$CR
start               lda       ,x
                    sta       mode,u
                    lda       1,x
                    suba      #'0'
                    sta       reverse,u
                    cmpa      #1
                    lbhi      bad
                    lda       mode,u
                    cmpa      #'l'
                    lbeq      leakchild
                    cmpa      #'m'
                    lbne      bad
                    lbsr      initmap
                    leax      intercept,pcr
                    os9       F$Icpt
                    lbcs      fail
                    clr       event,u
                    lda       #'C'
                    sta       role,u
                    clra
                    ldb       reverse,u
                    incb
                    std       sequence,u
                    os9       F$ID
                    leax      descriptor,u
                    os9       F$GPrDsc
                    lbcs      fail
                    lda       descriptor+P$PID,u
                    sta       peer,u
                    leax      report0,pcr
                    tst       reverse,u
                    beq       createreport
                    leax      report1,pcr
createreport        lda       #WRITE.
                    ldb       #READ.+WRITE.
                    os9       I$Create
                    lbcs      fail
                    sta       outpath,u
                    leax      memberb,pcr
                    tst       reverse,u
                    beq       linkheld
                    leax      membera,pcr
linkheld            clra
                    pshs      u
                    os9       F$Link
                    tfr       u,x
                    puls      u
                    lbcs      fail
                    stx       held,u
                    sty       entryheld,u
                    clra
                    clrb
                    std       extra,u
                    lbsr      callheld
                    clra
                    lbsr      snapshot
                    ldb       #4
                    lbsr      notify
                    lda       #5
                    lbsr      waitsignal
* Parent has dropped its only reference and tried an extra unlink.
                    lbsr      callheld
                    lda       #1
                    lbsr      snapshot
                    leax      membera,pcr
                    tst       reverse,u
                    beq       linkextra
                    leax      memberb,pcr
linkextra           clra
                    pshs      u
                    os9       F$Link
                    tfr       u,x
                    puls      u
                    lbcs      fail
                    stx       extra,u
                    sty       entryextra,u
                    ldb       #6
                    lbsr      notify
                    lda       #7
                    lbsr      waitsignal
* Global count for the parent's old module is nonzero, but parent has no map.
                    lbsr      callheld
                    jsr       [entryextra,u]
                    lda       reverse,u
                    adda      #$A1
                    pshs      b
                    cmpa      ,s+
                    lbne      bad
                    lda       #2
                    lbsr      snapshot
                    ldx       extra,u
                    lbsr      unlinkx
                    lbsr      callheld
                    lda       #3
                    lbsr      snapshot
                    lbsr      unlinkheld
                    lda       #4
                    lbsr      snapshot
                    lda       outpath,u
                    os9       I$Close
                    lbcs      fail
                    clrb
                    os9       F$Exit
callheld            jsr       [entryheld,u]
                    lda       #$A2
                    suba      reverse,u
                    pshs      b
                    cmpa      ,s+
                    lbne      bad
                    rts
leakchild           leax      shortb,pcr
                    tst       reverse,u
                    beq       leaklink
                    leax      memberb,pcr
leaklink            clra
                    pshs      u
                    os9       F$Link
                    tfr       u,x
                    puls      u
                    lbcs      fail
                    stx       held,u
                    sty       entryheld,u
                    jsr       [entryheld,u]
                    cmpb      #$A2
                    lbne      bad
                    leax      leakfile,pcr
                    lda       #READ.
                    os9       I$Open
                    lbcs      fail
                    sta       filehandle,u
                    leax      readbyte,u
                    ldy       #1
                    os9       I$Read
                    lbcs      fail
                    lda       readbyte,u
                    cmpa      #$5A
                    lbne      bad
                    lda       filehandle,u
                    os9       I$Close
                    lbcs      fail
                    lbsr      unlinkheld
                    clrb
                    os9       F$Exit
                    use       runtime-support.asm
                    emod
eom                 equ       *
