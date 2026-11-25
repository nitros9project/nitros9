* Repeated balanced module/file/process operations with measured checkpoints.
                    use       defsfile
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,size
                    use       runtime-data.asm
                    org       size-512
worker              rmb       2
filehandle          rmb       1
warmups             rmb       1
cycles              rmb       2
checkpoint          rmb       2
forkparams          rmb       2
                    rmb       500
name                fcs       /LeakCheck/
                    fcb       1
workername          fcs       /GrpWorker/
workerfile          fcc       "/dd/cmds/grpworker"
                    fcb       C$CR
shortfile           fcc       "/dd/short.grp"
                    fcb       C$CR
longfile            fcc       "/dd/long.grp"
                    fcb       C$CR
shortb              fcs       /ShortB/
longb               fcs       /LongB/
param0              fcb       'l','0',C$CR
param1              fcb       'l','1',C$CR
filename            fcc       "/dd/leak.tmp"
                    fcb       C$CR
bytevalue           fcb       $5A
reportname          fcc       "/dd/leak.bin"
                    fcb       C$CR
passed              fcc       /RESOURCELEAKPASS/
                    fcb       C$CR
start               lbsr      initmap
                    lda       #'L'
                    sta       role,u
                    clr       peer,u
                    leax      workerfile,pcr
                    clra
                    pshs      u
                    os9       F$Load
                    tfr       u,x
                    puls      u
                    lbcs      fail
                    stx       worker,u
                    leax      reportname,pcr
                    lda       #WRITE.
                    ldb       #READ.+WRITE.
                    os9       I$Create
                    lbcs      fail
                    sta       outpath,u
                    clra
                    clrb
                    std       sequence,u
                    lda       #10
                    sta       warmups,u
warmloop            lbsr      cycle
                    dec       warmups,u
                    bne       warmloop
                    clra
                    lbsr      snapshot
                    ldd       #LEAK_CYCLES
                    std       cycles,u
                    ldd       #100
                    std       checkpoint,u
nextcycle           lbsr      cycle
                    ldd       sequence,u
                    addd      #1
                    std       sequence,u
                    ldd       cycles,u
                    subd      #1
                    std       cycles,u
                    beq       donecycles
                    ldd       checkpoint,u
                    subd      #1
                    std       checkpoint,u
                    bne       nextcycle
                    lda       #1
                    lbsr      snapshot
                    ldd       #100
                    std       checkpoint,u
                    bra       nextcycle
donecycles          lda       #2
                    lbsr      snapshot
                    lda       outpath,u
                    os9       I$Close
                    lbcs      fail
                    ldx       worker,u
                    lbsr      unlinkx
                    leax      passed,pcr
                    ldy       #17
                    lda       #1
                    os9       I$WritLn
                    clrb
                    os9       F$Exit
cycle               leax      shortfile,pcr
                    leay      param0,pcr
                    ldd       sequence,u
                    bitb      #1
                    beq       choosefile
                    leax      longfile,pcr
                    leay      param1,pcr
choosefile          sty       forkparams,u
                    clra
                    pshs      u
                    os9       F$Load
                    tfr       u,x
                    puls      u
                    lbcs      fail
                    stx       held,u
                    sty       entryheld,u
                    leax      shortb,pcr
                    ldd       sequence,u
                    bitb      #1
                    beq       chooseb
                    leax      longb,pcr
chooseb             clra
                    pshs      u
                    os9       F$Link
                    tfr       u,x
                    puls      u
                    lbcs      fail
                    stx       extra,u
                    sty       entryextra,u
                    leax      filename,pcr
                    lda       #UPDAT.
                    ldb       #READ.+WRITE.
                    os9       I$Create
                    lbcs      fail
                    sta       filehandle,u
                    leax      bytevalue,pcr
                    ldy       #1
                    os9       I$Write
                    lbcs      fail
                    lda       filehandle,u
                    os9       I$Close
                    lbcs      fail
                    leax      workername,pcr
                    ldy       forkparams,u
                    pshs      u
                    tfr       y,u
                    ldy       #3
                    clra
                    clrb
                    os9       F$Fork
                    puls      u
                    lbcs      fail
                    sta       peer,u
                    os9       F$Wait
                    lbcs      fail
                    cmpa      peer,u
                    lbne      bad
                    tstb
                    lbne      fail
                    jsr       [entryheld,u]
                    cmpb      #$A1
                    lbne      bad
                    jsr       [entryextra,u]
                    cmpb      #$A2
                    lbne      bad
                    ldx       extra,u
                    lbsr      unlinkx
                    lbsr      unlinkheld
                    leax      filename,pcr
                    os9       I$Delete
                    lbcs      fail
                    clra
                    clrb
                    std       held,u
                    std       extra,u
                    sta       peer,u
                    rts
                    use       runtime-support.asm
                    emod
eom                 equ       *
