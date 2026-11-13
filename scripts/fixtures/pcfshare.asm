* Real OS-9 parent/child sharing checks. Parent retains its open path while
* each child independently opens/deletes the same file through another alias.
                    use       defsfile
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,size
                    org       0
held                rmb       1
expect              rmb       1
childid             rmb       1
checks              rmb       1
mode                rmb       1
readbyte            rmb       1
                    rmb       512
size                equ       .
name                fcs       /pcfshare/
                    fcb       1
start               lda       ,x
                    cmpa      #'r
                    lbeq      childread
                    cmpa      #'w
                    lbeq      childwrite
                    cmpa      #'d
                    lbeq      childdelete
                    cmpa      #'x
                    lbeq      childexit
                    clr       checks,u
                    leax      filedd,pcr
                    lbsr      create
                    leax      other,pcr
                    lbsr      create
* Reader through /dd: another reader succeeds; writer/delete fail via /pc0.
                    leax      filedd,pcr
                    lda       #READ.
                    os9       I$Open
                    lbcs      fail
                    sta       held,u
                    lbsr      readheld
                    cmpb      #'A
                    lbne      badtest
                    leax      readok,pcr
                    lbsr      spawn
                    lbsr      readheld
                    cmpb      #'B
                    lbne      badtest
                    leax      writebusy,pcr
                    lbsr      spawn
                    leax      deletebusy,pcr
                    lbsr      spawn
                    lbsr      closeheld
* Writer through /pc0: read/write/delete fail through /dd; other file works.
                    leax      filepc,pcr
                    lda       #UPDAT.
                    os9       I$Open
                    lbcs      fail
                    sta       held,u
* Record locking is explicitly unsupported, rather than silently successful.
                    ldb       #SS.Lock
                    ldx       #1
                    os9       I$SetStt
                    lbcc      badtest
                    cmpb      #E$UnkSvc
                    lbne      fail
                    leax      readbusy,pcr
                    lbsr      spawn
                    leax      writebusydd,pcr
                    lbsr      spawn
                    leax      deletebusydd,pcr
                    lbsr      spawn
                    leax      otherok,pcr
                    lbsr      spawn
* A duplicate keeps the exclusion until the last reference closes.
                    lda       held,u
                    os9       I$Dup
                    lbcs      fail
                    pshs      a
                    lbsr      closeheld
                    puls      a
                    sta       held,u
                    leax      readbusy,pcr
                    lbsr      spawn
                    lbsr      closeheld
                    leax      readok,pcr
                    lbsr      spawn
                    leax      writeok,pcr
                    lbsr      spawn
* Child exits with a writable path open: kernel cleanup must release it.
                    leax      exitopen,pcr
                    lbsr      spawn
                    leax      writeok,pcr
                    lbsr      spawn
                    leax      deleteok,pcr
                    lbsr      spawn
                    leax      other,pcr
                    os9       I$Delete
                    lbcs      fail
                    lda       checks,u
                    cmpa      #13
                    lbne      badtest
                    leax      passed,pcr
                    lbsr      message
                    clrb
                    os9       F$Exit
create              lda       #UPDAT.
                    ldb       #READ.+WRITE.+PREAD.+PWRIT.
                    os9       I$Create
                    lbcs      fail
                    leax      contents,pcr
                    ldy       #2
                    os9       I$Write
                    lbcs      fail
                    os9       I$Close
                    lbcs      fail
                    rts
readheld            lda       held,u
                    leax      readbyte,u
                    ldy       #1
                    os9       I$Read
                    lbcs      fail
                    ldb       readbyte,u
                    rts
closeheld           lda       held,u
                    os9       I$Close
                    lbcs      fail
                    rts
* X points to child parameters: operation, expected error byte, path, CR.
spawn               pshs      u
                    tfr       x,u
countloop           lda       ,x+
                    cmpa      #C$CR
                    bne       countloop
* Use pointer subtraction instead of the accumulator clobbered by scan.
                    tfr       x,d
                    pshs      u
                    subd      ,s++
                    tfr       d,y
                    leax      name,pcr
                    ldd       #$1100
                    os9       F$Fork
                    puls      u
                    lbcs      fail
                    sta       childid,u
                    os9       F$Wait
                    lbcs      fail
                    cmpa      childid,u
                    lbne      badtest
                    tstb
                    lbne      fail
                    inc       checks,u
                    rts
childread           lda       #READ.
                    bra       childopen
childwrite          lda       #UPDAT.
childopen           sta       mode,u
                    ldb       1,x
                    stb       expect,u
                    leax      2,x
                    os9       I$Open
                    bcs       childresult
                    ldb       mode,u
                    cmpb      #READ.
                    bne       childclose
                    leax      readbyte,u
                    ldy       #1
                    os9       I$Read
                    bcs       fail
                    ldb       readbyte,u
                    cmpb      #'A
                    bne       badtest
childclose          os9       I$Close
                    bcs       fail
                    clrb
                    bra       childresult
childdelete         ldb       1,x
                    stb       expect,u
                    leax      2,x
                    os9       I$Delete
                    bcs       childresult
                    clrb
childresult         cmpb      expect,u
                    bne       badtest
                    clrb
                    os9       F$Exit
childexit           leax      2,x
                    lda       #UPDAT.
                    os9       I$Open
                    bcs       fail
                    clrb
                    os9       F$Exit
badtest             ldb       #E$IllArg
fail                pshs      b
                    leax      failed,pcr
                    lbsr      message
                    puls      b
                    os9       F$Exit
message             lda       #1
                    ldy       #100
                    os9       I$WritLn
                    rts
filedd              fcc       "/dd/share.txt"
                    fcb       C$CR
filepc              fcc       "/pc0/share.txt"
                    fcb       C$CR
other               fcc       "/dd/other.txt"
                    fcb       C$CR
readok              fcb       'r,0
                    fcc       "/pc0/share.txt"
                    fcb       C$CR
writebusy           fcb       'w,E$Share
                    fcc       "/pc0/share.txt"
                    fcb       C$CR
deletebusy          fcb       'd,E$Share
                    fcc       "/pc0/share.txt"
                    fcb       C$CR
readbusy            fcb       'r,E$Share
                    fcc       "/dd/share.txt"
                    fcb       C$CR
writebusydd         fcb       'w,E$Share
                    fcc       "/dd/share.txt"
                    fcb       C$CR
deletebusydd        fcb       'd,E$Share
                    fcc       "/dd/share.txt"
                    fcb       C$CR
otherok             fcb       'w,0
                    fcc       "/dd/other.txt"
                    fcb       C$CR
writeok             fcb       'w,0
                    fcc       "/pc0/share.txt"
                    fcb       C$CR
exitopen            fcb       'x,0
                    fcc       "/dd/share.txt"
                    fcb       C$CR
deleteok            fcb       'd,0
                    fcc       "/pc0/share.txt"
                    fcb       C$CR
contents            fcc       "AB"
passed              fcc       "PCFSHARE PASS: 13 parent/child checks"
                    fcb       C$CR
failed              fcc       "PCFSHARE FAIL"
                    fcb       C$CR
                    emod
eom                 equ       *
