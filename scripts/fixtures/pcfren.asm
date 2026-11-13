* Real OS-9 parent/child SS.Rename tests. Default directories are reset in
* the child, so cwd/cxd rejections prove that another process holds the target.
                    use       defsfile  ; include shared definitions or implementation
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,size ; emit OS-9 module header
                    org       0         ; set storage origin
held                rmb       1         ; reserve storage
parent              rmb       1         ; reserve storage
expect              rmb       1         ; reserve storage
childid             rmb       1         ; reserve storage
checks              rmb       1         ; reserve storage
request             rmb       2         ; reserve storage
                    rmb       768       ; reserve storage
size                equ       .         ; define constant or offset
name                fcs       /pcfren/            ; module name or literal text
                    fcb       1         ; emit byte data
start               lda       ,x        ; load A from ,x
                    cmpa      #'r       ; compare A with #'r
                    lbeq      childrename ; branch when equal or zero childrename
                    clr       checks,u  ; clear checks,u
                    leax      filedd,pcr ; point X at filedd,pcr
                    lda       #READ.    ; load A from #READ.
                    os9       I$Open    ; invoke OS-9 I$Open service
                    lbcs      fail      ; branch on carry or error fail
                    sta       held,u    ; save A in held,u
                    leax      filebusy,pcr ; point X at filebusy,pcr
                    lbsr      spawn     ; call helper spawn
                    lda       held,u    ; load A from held,u
                    os9       I$Dup     ; invoke OS-9 I$Dup service
                    lbcs      fail      ; branch on carry or error fail
                    pshs      a         ; preserve a on stack
                    lbsr      closeheld ; call helper closeheld
                    puls      a         ; restore a from stack
                    sta       held,u    ; save A in held,u
                    leax      filebusy,pcr ; point X at filebusy,pcr
                    lbsr      spawn     ; call helper spawn
                    lbsr      closeheld ; call helper closeheld
                    leax      fileok,pcr ; point X at fileok,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      fileback,pcr ; point X at fileback,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      childdir,pcr ; point X at childdir,pcr
                    lda       #DIR.+READ. ; load A from #DIR.+READ.
                    os9       I$Open    ; invoke OS-9 I$Open service
                    lbcs      fail      ; branch on carry or error fail
                    sta       held,u    ; save A in held,u
                    leax      dirbusy,pcr ; point X at dirbusy,pcr
                    lbsr      spawn     ; call helper spawn
                    lbsr      closeheld ; call helper closeheld
                    leax      dirok,pcr ; point X at dirok,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      dirback,pcr ; point X at dirback,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      childdir,pcr ; point X at childdir,pcr
                    lda       #READ.    ; load A from #READ.
                    os9       I$ChgDir  ; invoke OS-9 I$ChgDir service
                    lbcs      fail      ; branch on carry or error fail
                    leax      dirbusy,pcr ; point X at dirbusy,pcr
                    lbsr      spawn     ; call helper spawn
                    lbsr      resetdirs ; call helper resetdirs
                    leax      dirok,pcr ; point X at dirok,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      dirback,pcr ; point X at dirback,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      childdir,pcr ; point X at childdir,pcr
                    lda       #EXEC.    ; load A from #EXEC.
                    os9       I$ChgDir  ; invoke OS-9 I$ChgDir service
                    lbcs      fail      ; branch on carry or error fail
                    leax      dirbusy,pcr ; point X at dirbusy,pcr
                    lbsr      spawn     ; call helper spawn
                    lbsr      resetdirs ; call helper resetdirs
                    leax      dirok,pcr ; point X at dirok,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      dirback,pcr ; point X at dirback,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      missing,pcr ; point X at missing,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      filecollision,pcr ; point X at filecollision,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      dircollision,pcr ; point X at dircollision,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      dot,pcr   ; point X at dot,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      dotdot,pcr ; point X at dotdot,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      slash,pcr ; point X at slash,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      longname,pcr ; point X at longname,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      punctuation,pcr ; point X at punctuation,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      badcount,pcr ; point X at badcount,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      readmode,pcr ; point X at readmode,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      fileparent,pcr ; point X at fileparent,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      caseonly,pcr ; point X at caseonly,pcr
                    lbsr      spawn     ; call helper spawn
                    lda       checks,u  ; load A from checks,u
                    cmpa      #25       ; compare A with #25
                    lbne      badtest   ; branch when unequal or nonzero badtest
                    leax      passed,pcr ; point X at passed,pcr
                    lbsr      message   ; call helper message
                    clrb                ; clear accumulator B and carry
                    os9       F$Exit    ; invoke OS-9 F$Exit service
closeheld           lda       held,u    ; load A from held,u
                    os9       I$Close   ; invoke OS-9 I$Close service
                    lbcs      fail      ; branch on carry or error fail
                    rts                 ; return to caller
resetdirs           leax      root,pcr  ; point X at root,pcr
                    lda       #READ.    ; load A from #READ.
                    os9       I$ChgDir  ; invoke OS-9 I$ChgDir service
                    lbcs      fail      ; branch on carry or error fail
                    leax      commands,pcr ; point X at commands,pcr
                    lda       #EXEC.    ; load A from #EXEC.
                    os9       I$ChgDir  ; invoke OS-9 I$ChgDir service
                    lbcs      fail      ; branch on carry or error fail
                    rts                 ; return to caller
spawn               pshs      u         ; preserve u on stack
                    tfr       x,u       ; transfer registers x,u
                    ldy       #66       ; load Y from #66
                    leax      name,pcr  ; point X at name,pcr
                    ldd       #$1100    ; load D from #$1100
                    os9       F$Fork    ; invoke OS-9 F$Fork service
                    puls      u         ; restore u from stack
                    lbcs      fail      ; branch on carry or error fail
                    sta       childid,u ; save A in childid,u
                    os9       F$Wait    ; invoke OS-9 F$Wait service
                    lbcs      fail      ; branch on carry or error fail
                    cmpa      childid,u ; compare A with childid,u
                    lbne      badtest   ; branch when unequal or nonzero badtest
                    tstb                ; test accumulator B
                    lbne      fail      ; branch when unequal or nonzero fail
                    inc       checks,u  ; increment checks,u
                    rts                 ; return to caller
childrename         stx       request,u ; save X in request,u
                    lbsr      resetdirs ; call helper resetdirs
                    ldx       request,u ; load X from request,u
                    ldb       3,x       ; load B from 3,x
                    stb       expect,u  ; save B in expect,u
                    lda       1,x       ; load A from 1,x
                    ldb       4,x       ; load B from 4,x
                    leax      parentdir,pcr ; point X at parentdir,pcr
                    tstb                ; test accumulator B
                    beq       openparent@ ; branch when equal or zero openparent@
                    leax      filepc,pcr ; point X at filepc,pcr
openparent@         os9       I$Open    ; invoke OS-9 I$Open service
                    lbcs      fail      ; branch on carry or error fail
                    sta       parent,u  ; save A in parent,u
                    tst       expect,u  ; test expect,u
                    beq       attempt@  ; branch when equal or zero attempt@
                    leax      denybegin,pcr ; point X at denybegin,pcr
                    lbsr      message   ; call helper message
attempt@            ldx       request,u ; load X from request,u
                    clra                ; clear accumulator A and carry
                    ldb       2,x       ; load B from 2,x
                    tfr       d,y       ; transfer registers d,y
                    leax      5,x       ; point X at 5,x
                    lda       parent,u  ; load A from parent,u
                    ldb       #SS.Rename ; load B from #SS.Rename
                    os9       I$SetStt  ; invoke OS-9 I$SetStt service
                    bcs       result@   ; branch on carry or error result@
                    clrb                ; clear accumulator B and carry
result@             cmpb      expect,u  ; compare B with expect,u
                    bne       badtest   ; branch when unequal or nonzero badtest
                    lda       parent,u  ; load A from parent,u
                    os9       I$Close   ; invoke OS-9 I$Close service
                    bcs       fail      ; branch on carry or error fail
                    tst       expect,u  ; test expect,u
                    beq       childok@  ; branch when equal or zero childok@
                    leax      denyend,pcr ; point X at denyend,pcr
                    bsr       message   ; call helper message
childok@            clrb                ; clear accumulator B and carry
                    os9       F$Exit    ; invoke OS-9 F$Exit service
badtest             ldb       #E$IllArg ; load B from #E$IllArg
fail                pshs      b         ; preserve b on stack
                    leax      failed,pcr ; point X at failed,pcr
                    bsr       message   ; call helper message
                    puls      b         ; restore b from stack
                    os9       F$Exit    ; invoke OS-9 F$Exit service
message             lda       #1        ; load A from #1
                    ldy       #100      ; load Y from #100
                    os9       I$WritLn  ; invoke OS-9 I$WritLn service
                    rts                 ; return to caller
root                fcc       "/dd"               ; module name or literal text
                    fcb       C$CR      ; emit byte data
commands            fcc       "/dd/cmds"          ; module name or literal text
                    fcb       C$CR      ; emit byte data
parentdir           fcc       "/pc0/RNTEST"       ; module name or literal text
                    fcb       C$CR      ; emit byte data
filedd              fcc       "/dd/RNTEST/HELD.TXT"  ; module name or literal text
                    fcb       C$CR      ; emit byte data
filepc              fcc       "/pc0/RNTEST/HELD.TXT"  ; module name or literal text
                    fcb       C$CR      ; emit byte data
childdir            fcc       "/dd/RNTEST/CHILD"  ; module name or literal text
                    fcb       C$CR      ; emit byte data
denybegin           fcc       "PCFRENDENYBEGIN"   ; module name or literal text
                    fcb       C$CR      ; emit byte data
denyend             fcc       "PCFRENDENYEND"     ; module name or literal text
                    fcb       C$CR      ; emit byte data
passed              fcc       "PCFRENAME PASS: 25 parent/child checks"  ; module name or literal text
                    fcb       C$CR      ; emit byte data
failed              fcc       "PCFRENAME FAIL"    ; module name or literal text
                    fcb       C$CR      ; emit byte data
filebusy            fcb       'r,$82,60,E$Share,0 ; emit byte data
                    fcc       "HELD.TXT"          ; module name or literal text
                    zmb       22        ; perform zmb 22
                    fcc       "MOVED.TXT"         ; module name or literal text
                    zmb       21        ; perform zmb 21
                    fcb       C$CR      ; emit byte data
fileok              fcb       'r,$82,60,0,0 ; emit byte data
                    fcc       "HELD.TXT"          ; module name or literal text
                    zmb       22        ; perform zmb 22
                    fcc       "MOVED.TXT"         ; module name or literal text
                    zmb       21        ; perform zmb 21
                    fcb       C$CR      ; emit byte data
fileback            fcb       'r,$82,60,0,0 ; emit byte data
                    fcc       "MOVED.TXT"         ; module name or literal text
                    zmb       21        ; perform zmb 21
                    fcc       "HELD.TXT"          ; module name or literal text
                    zmb       22        ; perform zmb 22
                    fcb       C$CR      ; emit byte data
dirbusy             fcb       'r,$82,60,E$Share,0 ; emit byte data
                    fcc       "CHILD"             ; module name or literal text
                    zmb       25        ; perform zmb 25
                    fcc       "MOVED"             ; module name or literal text
                    zmb       25        ; perform zmb 25
                    fcb       C$CR      ; emit byte data
dirok               fcb       'r,$82,60,0,0 ; emit byte data
                    fcc       "CHILD"             ; module name or literal text
                    zmb       25        ; perform zmb 25
                    fcc       "MOVED"             ; module name or literal text
                    zmb       25        ; perform zmb 25
                    fcb       C$CR      ; emit byte data
dirback             fcb       'r,$82,60,0,0 ; emit byte data
                    fcc       "MOVED"             ; module name or literal text
                    zmb       25        ; perform zmb 25
                    fcc       "CHILD"             ; module name or literal text
                    zmb       25        ; perform zmb 25
                    fcb       C$CR      ; emit byte data
missing             fcb       'r,$82,60,E$PNNF,0 ; emit byte data
                    fcc       "ABSENT"            ; module name or literal text
                    zmb       24        ; perform zmb 24
                    fcc       "NEW"               ; module name or literal text
                    zmb       27        ; perform zmb 27
                    fcb       C$CR      ; emit byte data
filecollision       fcb       'r,$82,60,E$CEF,0 ; emit byte data
                    fcc       "HELD.TXT"          ; module name or literal text
                    zmb       22        ; perform zmb 22
                    fcc       "CHILD"             ; module name or literal text
                    zmb       25        ; perform zmb 25
                    fcb       C$CR      ; emit byte data
dircollision        fcb       'r,$82,60,E$CEF,0 ; emit byte data
                    fcc       "CHILD"             ; module name or literal text
                    zmb       25        ; perform zmb 25
                    fcc       "HELD.TXT"          ; module name or literal text
                    zmb       22        ; perform zmb 22
                    fcb       C$CR      ; emit byte data
dot                 fcb       'r,$82,60,E$BPNam,0 ; emit byte data
                    fcc       "."                 ; module name or literal text
                    zmb       29        ; perform zmb 29
                    fcc       "NEW"               ; module name or literal text
                    zmb       27        ; perform zmb 27
                    fcb       C$CR      ; emit byte data
dotdot              fcb       'r,$82,60,E$BPNam,0 ; emit byte data
                    fcc       ".."                ; module name or literal text
                    zmb       28        ; perform zmb 28
                    fcc       "NEW"               ; module name or literal text
                    zmb       27        ; perform zmb 27
                    fcb       C$CR      ; emit byte data
slash               fcb       'r,$82,60,E$BPNam,0 ; emit byte data
                    fcc       "CHILD"             ; module name or literal text
                    zmb       25        ; perform zmb 25
                    fcc       "BAD/NAME"          ; module name or literal text
                    zmb       22        ; perform zmb 22
                    fcb       C$CR      ; emit byte data
longname            fcb       'r,$82,60,E$BPNam,0 ; emit byte data
                    fcc       "CHILD"             ; module name or literal text
                    zmb       25        ; perform zmb 25
                    fcc       "TOOLONGNAME"       ; module name or literal text
                    zmb       19        ; perform zmb 19
                    fcb       C$CR      ; emit byte data
punctuation         fcb       'r,$82,60,E$BPNam,0 ; emit byte data
                    fcc       "CHILD"             ; module name or literal text
                    zmb       25        ; perform zmb 25
                    fcc       "B*AD"              ; module name or literal text
                    zmb       26        ; perform zmb 26
                    fcb       C$CR      ; emit byte data
badcount            fcb       'r,$82,59,E$BPNam,0 ; emit byte data
                    fcc       "CHILD"             ; module name or literal text
                    zmb       25        ; perform zmb 25
                    fcc       "NEW"               ; module name or literal text
                    zmb       27        ; perform zmb 27
                    fcb       C$CR      ; emit byte data
readmode            fcb       'r,$81,60,E$FNA,0 ; emit byte data
                    fcc       "CHILD"             ; module name or literal text
                    zmb       25        ; perform zmb 25
                    fcc       "NEW"               ; module name or literal text
                    zmb       27        ; perform zmb 27
                    fcb       C$CR      ; emit byte data
fileparent          fcb       'r,$03,60,E$FNA,1 ; emit byte data
                    fcc       "CHILD"             ; module name or literal text
                    zmb       25        ; perform zmb 25
                    fcc       "NEW"               ; module name or literal text
                    zmb       27        ; perform zmb 27
                    fcb       C$CR      ; emit byte data
caseonly            fcb       'r,$82,60,0,0 ; emit byte data
                    fcc       "HELD.TXT"          ; module name or literal text
                    zmb       22        ; perform zmb 22
                    fcc       "held.txt"          ; module name or literal text
                    zmb       22        ; perform zmb 22
                    fcb       C$CR      ; emit byte data
                    emod      ;         finish module and CRC
eom                 equ       *         ; define constant or offset
                    end       ;         end assembly source
