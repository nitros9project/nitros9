* Level One RBF runtime: actual data, boundary seeks, reopen, EOF and cleanup.
                    use       defsfile
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,size
                    org       0
path                rmb       1
buffer              rmb       513
                    rmb       512
size                equ       .
name                fcs       /L1Check/
                    fcb       1
dirname             fcc       "/dd/probe"
                    fcb       C$CR
filename            fcc       "/dd/probe/data"
                    fcb       C$CR
relative            fcc       "data"
                    fcb       C$CR
tempname            fcc       "/dd/transient"
                    fcb       C$CR
donefile            fcc       "/dd/l1done"
                    fcb       C$CR
passed              fcc       /L1RUNTIMEPASS/
                    fcb       C$CR
start               leax      buffer,u
                    clrb
                    ldy       #513
fill                stb       ,x+
                    incb
                    leay      -1,y
                    bne       fill
                    leax      dirname,pcr
                    ldb       #READ.+WRITE.+DIR.
                    os9       I$MakDir
                    lbcs      fail
                    leax      filename,pcr
                    lda       #UPDAT.
                    ldb       #READ.+WRITE.
                    os9       I$Create
                    lbcs      fail
                    sta       path,u
                    leax      buffer,u
                    ldy       #513
                    os9       I$Write
                    lbcs      fail
* Seek across a sector boundary and require bytes 255,0,1.
                    lda       path,u
                    ldx       #0
                    pshs      u
                    ldu       #255
                    os9       I$Seek
                    puls      u
                    lbcs      fail
                    leax      buffer,u
                    ldy       #3
                    os9       I$Read
                    lbcs      fail
                    lda       buffer,u
                    cmpa      #255
                    lbne      bad
                    tst       buffer+1,u
                    lbne      bad
                    lda       buffer+2,u
                    cmpa      #1
                    lbne      bad
                    lda       path,u
                    os9       I$Close
                    lbcs      fail
* Change directory and reopen the same file by relative name.
                    leax      dirname,pcr
                    lda       #READ.
                    os9       I$ChgDir
                    lbcs      fail
                    leax      relative,pcr
                    lda       #READ.
                    os9       I$Open
                    lbcs      fail
                    sta       path,u
                    leax      buffer,u
                    ldy       #513
                    os9       I$Read
                    lbcs      fail
                    cmpy      #513
                    lbne      bad
                    leax      buffer,u
                    ldy       #513
                    clrb
compare             cmpb      ,x+
                    lbne      bad
                    incb
                    leay      -1,y
                    bne       compare
                    lda       path,u
                    leax      buffer,u
                    ldy       #1
                    os9       I$Read
                    lbcc      bad
                    cmpb      #E$EOF
                    lbne      fail
                    lda       path,u
                    os9       I$Close
                    lbcs      fail
                    leax      tempname,pcr
                    lda       #WRITE.
                    ldb       #READ.+WRITE.
                    os9       I$Create
                    lbcs      fail
                    os9       I$Close
                    lbcs      fail
                    leax      tempname,pcr
                    os9       I$Delete
                    lbcs      fail
                    leax      donefile,pcr
                    lda       #WRITE.
                    ldb       #READ.+WRITE.
                    os9       I$Create
                    lbcs      fail
                    sta       path,u
                    leax      passed,pcr
                    ldy       #14
                    os9       I$Write
                    lbcs      fail
                    lda       path,u
                    os9       I$Close
                    lbcs      fail
                    leax      passed,pcr
                    ldy       #14
                    lda       #1
                    os9       I$WritLn
                    clrb
                    os9       F$Exit
bad                 ldb       #E$IllArg
fail                os9       F$Exit
                    emod
eom                 equ       *
