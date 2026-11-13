* Real OS-9 parent/child SS.Rename tests. Default directories are reset in
* the child, so cwd/cxd rejections prove that another process holds the target.
                    use       defsfile
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,size
                    org       0
held                rmb       1
parent              rmb       1
expect              rmb       1
childid             rmb       1
checks              rmb       1
request             rmb       2
                    rmb       768
size                equ       .
name                fcs       /pcfren/
                    fcb       1
start               lda       ,x
                    cmpa      #'r
                    lbeq      childrename
                    clr       checks,u
                    leax      filedd,pcr
                    lda       #READ.
                    os9       I$Open
                    lbcs      fail
                    sta       held,u
                    leax      filebusy,pcr
                    lbsr      spawn
                    lda       held,u
                    os9       I$Dup
                    lbcs      fail
                    pshs      a
                    lbsr      closeheld
                    puls      a
                    sta       held,u
                    leax      filebusy,pcr
                    lbsr      spawn
                    lbsr      closeheld
                    leax      fileok,pcr
                    lbsr      spawn
                    leax      fileback,pcr
                    lbsr      spawn
                    leax      childdir,pcr
                    lda       #DIR.+READ.
                    os9       I$Open
                    lbcs      fail
                    sta       held,u
                    leax      dirbusy,pcr
                    lbsr      spawn
                    lbsr      closeheld
                    leax      dirok,pcr
                    lbsr      spawn
                    leax      dirback,pcr
                    lbsr      spawn
                    leax      childdir,pcr
                    lda       #READ.
                    os9       I$ChgDir
                    lbcs      fail
                    leax      dirbusy,pcr
                    lbsr      spawn
                    lbsr      resetdirs
                    leax      dirok,pcr
                    lbsr      spawn
                    leax      dirback,pcr
                    lbsr      spawn
                    leax      childdir,pcr
                    lda       #EXEC.
                    os9       I$ChgDir
                    lbcs      fail
                    leax      dirbusy,pcr
                    lbsr      spawn
                    lbsr      resetdirs
                    leax      dirok,pcr
                    lbsr      spawn
                    leax      dirback,pcr
                    lbsr      spawn
                    leax      missing,pcr
                    lbsr      spawn
                    leax      filecollision,pcr
                    lbsr      spawn
                    leax      dircollision,pcr
                    lbsr      spawn
                    leax      dot,pcr
                    lbsr      spawn
                    leax      dotdot,pcr
                    lbsr      spawn
                    leax      slash,pcr
                    lbsr      spawn
                    leax      longname,pcr
                    lbsr      spawn
                    leax      punctuation,pcr
                    lbsr      spawn
                    leax      badcount,pcr
                    lbsr      spawn
                    leax      readmode,pcr
                    lbsr      spawn
                    leax      fileparent,pcr
                    lbsr      spawn
                    leax      caseonly,pcr
                    lbsr      spawn
                    lda       checks,u
                    cmpa      #25
                    lbne      badtest
                    leax      passed,pcr
                    lbsr      message
                    clrb
                    os9       F$Exit
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
                    ldy       #66
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
childrename         stx       request,u
                    lbsr      resetdirs
                    ldx       request,u
                    ldb       3,x
                    stb       expect,u
                    lda       1,x
                    ldb       4,x
                    leax      parentdir,pcr
                    tstb
                    beq       openparent@
                    leax      filepc,pcr
openparent@         os9       I$Open
                    lbcs      fail
                    sta       parent,u
                    tst       expect,u
                    beq       attempt@
                    leax      denybegin,pcr
                    lbsr      message
attempt@            ldx       request,u
                    clra
                    ldb       2,x
                    tfr       d,y
                    leax      5,x
                    lda       parent,u
                    ldb       #SS.Rename
                    os9       I$SetStt
                    bcs       result@
                    clrb
result@             cmpb      expect,u
                    bne       badtest
                    lda       parent,u
                    os9       I$Close
                    bcs       fail
                    tst       expect,u
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
root                fcc       "/dd"
                    fcb       C$CR
commands            fcc       "/dd/cmds"
                    fcb       C$CR
parentdir           fcc       "/pc0/RNTEST"
                    fcb       C$CR
filedd              fcc       "/dd/RNTEST/HELD.TXT"
                    fcb       C$CR
filepc              fcc       "/pc0/RNTEST/HELD.TXT"
                    fcb       C$CR
childdir            fcc       "/dd/RNTEST/CHILD"
                    fcb       C$CR
denybegin           fcc       "PCFRENDENYBEGIN"
                    fcb       C$CR
denyend             fcc       "PCFRENDENYEND"
                    fcb       C$CR
passed              fcc       "PCFRENAME PASS: 25 parent/child checks"
                    fcb       C$CR
failed              fcc       "PCFRENAME FAIL"
                    fcb       C$CR
filebusy            fcb       'r,$82,60,E$Share,0
                    fcc       "HELD.TXT"
                    zmb       22
                    fcc       "MOVED.TXT"
                    zmb       21
                    fcb       C$CR
fileok              fcb       'r,$82,60,0,0
                    fcc       "HELD.TXT"
                    zmb       22
                    fcc       "MOVED.TXT"
                    zmb       21
                    fcb       C$CR
fileback            fcb       'r,$82,60,0,0
                    fcc       "MOVED.TXT"
                    zmb       21
                    fcc       "HELD.TXT"
                    zmb       22
                    fcb       C$CR
dirbusy             fcb       'r,$82,60,E$Share,0
                    fcc       "CHILD"
                    zmb       25
                    fcc       "MOVED"
                    zmb       25
                    fcb       C$CR
dirok               fcb       'r,$82,60,0,0
                    fcc       "CHILD"
                    zmb       25
                    fcc       "MOVED"
                    zmb       25
                    fcb       C$CR
dirback             fcb       'r,$82,60,0,0
                    fcc       "MOVED"
                    zmb       25
                    fcc       "CHILD"
                    zmb       25
                    fcb       C$CR
missing             fcb       'r,$82,60,E$PNNF,0
                    fcc       "ABSENT"
                    zmb       24
                    fcc       "NEW"
                    zmb       27
                    fcb       C$CR
filecollision       fcb       'r,$82,60,E$CEF,0
                    fcc       "HELD.TXT"
                    zmb       22
                    fcc       "CHILD"
                    zmb       25
                    fcb       C$CR
dircollision        fcb       'r,$82,60,E$CEF,0
                    fcc       "CHILD"
                    zmb       25
                    fcc       "HELD.TXT"
                    zmb       22
                    fcb       C$CR
dot                 fcb       'r,$82,60,E$BPNam,0
                    fcc       "."
                    zmb       29
                    fcc       "NEW"
                    zmb       27
                    fcb       C$CR
dotdot              fcb       'r,$82,60,E$BPNam,0
                    fcc       ".."
                    zmb       28
                    fcc       "NEW"
                    zmb       27
                    fcb       C$CR
slash               fcb       'r,$82,60,E$BPNam,0
                    fcc       "CHILD"
                    zmb       25
                    fcc       "BAD/NAME"
                    zmb       22
                    fcb       C$CR
longname            fcb       'r,$82,60,E$BPNam,0
                    fcc       "CHILD"
                    zmb       25
                    fcc       "TOOLONGNAME"
                    zmb       19
                    fcb       C$CR
punctuation         fcb       'r,$82,60,E$BPNam,0
                    fcc       "CHILD"
                    zmb       25
                    fcc       "B*AD"
                    zmb       26
                    fcb       C$CR
badcount            fcb       'r,$82,59,E$BPNam,0
                    fcc       "CHILD"
                    zmb       25
                    fcc       "NEW"
                    zmb       27
                    fcb       C$CR
readmode            fcb       'r,$81,60,E$FNA,0
                    fcc       "CHILD"
                    zmb       25
                    fcc       "NEW"
                    zmb       27
                    fcb       C$CR
fileparent          fcb       'r,$03,60,E$FNA,1
                    fcc       "CHILD"
                    zmb       25
                    fcc       "NEW"
                    zmb       27
                    fcb       C$CR
caseonly            fcb       'r,$82,60,0,0
                    fcc       "HELD.TXT"
                    zmb       22
                    fcc       "held.txt"
                    zmb       22
                    fcb       C$CR
                    emod
eom                 equ       *
                    end
