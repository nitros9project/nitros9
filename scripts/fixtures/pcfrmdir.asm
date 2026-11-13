* Parent retains open/default-directory references; child resets its own data
* and execution directories before attempting removal through another alias.
                    use       defsfile
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,size
                    org       0
held                rmb       1
expect              rmb       1
childid             rmb       1
checks              rmb       1
                    rmb       512
size                equ       .
name                fcs       /pcfrmdir/
                    fcb       1
start               lda       ,x
                    cmpa      #'d
                    lbeq      childdelete
                    clr       checks,u
                    lbsr      maketest
                    leax      target,pcr
                    lda       #DIR.+READ.
                    os9       I$Open
                    lbcs      fail
                    sta       held,u
                    leax      busy,pcr
                    lbsr      spawn
                    lda       held,u
                    os9       I$Dup
                    lbcs      fail
                    pshs      a
                    lbsr      closeheld
                    puls      a
                    sta       held,u
                    leax      busy,pcr
                    lbsr      spawn
                    lbsr      closeheld
                    leax      removeok,pcr
                    lbsr      spawn
* Only the parent keeps this data-directory reference after child setup.
                    lbsr      maketest
                    leax      target,pcr
                    lda       #READ.
                    os9       I$ChgDir
                    lbcs      fail
                    leax      busy,pcr
                    lbsr      spawn
                    lbsr      resetdirs
                    leax      removeok,pcr
                    lbsr      spawn
* Likewise for the execution directory, which is independent of data cwd.
                    lbsr      maketest
                    leax      target,pcr
                    lda       #EXEC.
                    os9       I$ChgDir
                    lbcs      fail
                    leax      busy,pcr
                    lbsr      spawn
                    lbsr      resetdirs
                    leax      removeok,pcr
                    lbsr      spawn
* A regular file makes its parent nonempty. Verify its data survived rejection.
                    lbsr      maketest
                    leax      file,pcr
                    lda       #UPDAT.
                    ldb       #READ.+WRITE.+PREAD.+PWRIT.
                    os9       I$Create
                    lbcs      fail
                    leax      payload,pcr
                    ldy       #4
                    os9       I$Write
                    lbcs      fail
                    os9       I$Close
                    lbcs      fail
                    leax      nonempty,pcr
                    lbsr      spawn
                    leax      file,pcr
                    lda       #READ.
                    os9       I$Open
                    lbcs      fail
* Code is read-only: use stack storage for the verification buffer.
                    leas      -4,s
                    sta       held,u
                    leax      ,s
                    ldy       #4
                    os9       I$Read
                    lbcs      fail
                    ldd       ,s
                    cmpd      #$4B45
                    lbne      badtest
                    ldd       2,s
                    cmpd      #$4550
                    lbne      badtest
                    leas      4,s
                    lda       held,u
                    os9       I$Close
                    lbcs      fail
                    leax      file,pcr
                    os9       I$Delete
                    lbcs      fail
                    leax      removeok,pcr
                    lbsr      spawn
* A child directory also makes the target nonempty.
                    lbsr      maketest
                    leax      subdir,pcr
                    ldb       #^SHARE.
                    os9       I$MakDir
                    lbcs      fail
                    leax      nonempty,pcr
                    lbsr      spawn
                    leax      subdir,pcr
                    os9       I$Delete
                    lbcs      fail
                    leax      removeok,pcr
                    lbsr      spawn
                    leax      rootdenied,pcr
                    lbsr      spawn
                    lbsr      maketest
                    leax      dotdenied,pcr
                    lbsr      spawn
                    leax      removeok,pcr
                    lbsr      spawn
                    lda       checks,u
                    cmpa      #14
                    lbne      badtest
                    leax      passed,pcr
                    lbsr      message
                    clrb
                    os9       F$Exit
maketest            leax      target,pcr
                    ldb       #^SHARE.
                    os9       I$MakDir
                    lbcs      fail
                    rts
closeheld           lda       held,u
                    os9       I$Close
                    lbcs      fail
                    rts
resetdirs           leax      root,pcr
                    lda       #READ.
                    os9       I$ChgDir
                    lbcs      fail
                    leax      commands,pcr
                    lda       #EXEC.
                    os9       I$ChgDir
                    lbcs      fail
                    rts
spawn               pshs      u
                    tfr       x,u
countloop           lda       ,x+
                    cmpa      #C$CR
                    bne       countloop
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
childdelete         pshs      x
                    lbsr      resetdirs
                    puls      x
                    ldb       1,x
                    stb       expect,u
                    leax      2,x
                    tstb
                    beq       attempt@
                    pshs      x
                    leax      denybegin,pcr
                    bsr       message
                    puls      x
attempt@            os9       I$Delete
                    bcs       result@
                    clrb
result@             cmpb      expect,u
                    bne       badtest
                    tstb
                    beq       childok@
                    leax      denyend,pcr
                    bsr       message
childok@            clrb
                    os9       F$Exit
badtest             ldb       #E$IllArg
fail                pshs      b
                    leax      failed,pcr
                    bsr       message
                    puls      b
                    os9       F$Exit
message             lda       #1
                    ldy       #100
                    os9       I$WritLn
                    rts
target              fcc       "/dd/RMTEST"
                    fcb       C$CR
root                fcc       "/dd"
                    fcb       C$CR
commands            fcc       "/dd/cmds"
                    fcb       C$CR
file                fcc       "/dd/RMTEST/KEEP.TXT"
                    fcb       C$CR
subdir              fcc       "/dd/RMTEST/CHILD"
                    fcb       C$CR
busy                fcb       'd,E$Share
                    fcc       "/pc0/RMTEST"
                    fcb       C$CR
removeok            fcb       'd,0
                    fcc       "/pc0/RMTEST"
                    fcb       C$CR
nonempty            fcb       'd,E$DNE
                    fcc       "/pc0/RMTEST"
                    fcb       C$CR
rootdenied          fcb       'd,E$FNA
                    fcc       "/pc0"
                    fcb       C$CR
dotdenied           fcb       'd,E$FNA
                    fcc       "/pc0/RMTEST/."
                    fcb       C$CR
payload             fcc       "KEEP"
denybegin           fcc       "PCFRMDENYBEGIN"
                    fcb       C$CR
denyend             fcc       "PCFRMDENYEND"
                    fcb       C$CR
passed              fcc       "PCFRMDIR PASS: 14 parent/child checks"
                    fcb       C$CR
failed              fcc       "PCFRMDIR FAIL"
                    fcb       C$CR
                    emod
eom                 equ       *
