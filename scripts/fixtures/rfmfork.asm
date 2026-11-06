* Original regression: child must retain directories copied at F$Fork.
                    ifp1
                    use       defsfile
                    endc
                    mod       eom,name,Prgrm+Objct,ReEnt,start,$0200
name                fcs       /rfmfork/
                    fcb       1
* Private data: path byte, saved child PID, 32-byte input buffer.
start               lda       ,x
                    cmpa      #'c'
                    beq       child
                    leax      datadir,pcr
                    lda       #READ.
                    os9       I$ChgDir
                    bcs       exit
                    leax      execdir,pcr
                    lda       #EXEC.
                    os9       I$ChgDir
                    bcs       exit
                    leax      name,pcr
                    pshs      u
                    leau      childparam,pcr
                    ldy       #2
                    clra
                    clrb
                    os9       F$Fork
                    puls      u
                    bcs       exit
* Child sleeps before first I/O; parent replaces BOTH directory cookies.
                    leax      subdir,pcr
                    lda       #READ.
                    os9       I$ChgDir
                    bcs       exit
                    leax      subdir,pcr
                    lda       #EXEC.
                    os9       I$ChgDir
                    bcs       exit
                    os9       F$Wait
                    bcs       exit
                    tstb
                    bne       exit
* Parent still has its own directories after child's changes.
                    lbsr      marker
                    bcs       exit
                    leax      parentexec,pcr
                    lbsr      runexec
                    bra       exit
child               ldx       #120
                    os9       F$Sleep
                    bcs       exit
                    lbsr      marker
                    bcs       exit
                    leax      childexec,pcr
                    lbsr      runexec
                    bcs       exit
* Child changes both directions, leaving parent's copies untouched.
                    leax      parentdir,pcr
                    lda       #READ.
                    os9       I$ChgDir
                    bcs       exit
                    leax      parentdir,pcr
                    lda       #EXEC.
                    os9       I$ChgDir
exit                os9       F$Exit
marker              leax      markername,pcr
                    lda       #READ.
                    os9       I$Open
                    bcs       ret
                    pshs      a
                    leax      16,u
                    ldy       #32
                    os9       I$ReadLn
                    bcs       closeerror
                    lda       #1
                    os9       I$WritLn
closeerror          pshs      cc,b
                    lda       2,s
                    os9       I$Close
                    puls      cc,b
                    leas      1,s
ret                 rts
runexec             pshs      u
                    leau      empty,pcr
                    ldy       #1
                    clra
                    clrb
                    os9       F$Fork
                    puls      u
                    bcs       ret
                    os9       F$Wait
                    tstb
                    beq       ret
                    orcc      #1
                    rts
datadir             fcc       "/y0/rfmtest/data"
                    fcb       13
execdir             fcc       "/y0/rfmtest/bin"
                    fcb       13
subdir              fcc       /child/
                    fcb       13
parentdir           fcc       /../
                    fcb       13
markername          fcc       /marker/
                    fcb       13
childexec           fcc       /rfmexec/
                    fcb       13
parentexec          fcc       /rfmchild/
                    fcb       13
childparam          fcc       /c/
empty               fcb       13
                    emod
eom                 equ       *
