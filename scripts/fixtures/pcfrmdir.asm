* Parent retains open/default-directory references; child resets its own data
* and execution directories before attempting removal through another alias.
                    use       defsfile  ; include shared definitions or implementation
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,size ; emit OS-9 module header
                    org       0         ; set storage origin
held                rmb       1         ; reserve storage
expect              rmb       1         ; reserve storage
childid             rmb       1         ; reserve storage
checks              rmb       1         ; reserve storage
                    rmb       512       ; reserve storage
size                equ       .         ; define constant or offset
name                fcs       /pcfrmdir/          ; module name or literal text
                    fcb       1         ; emit byte data
start               lda       ,x        ; load A from ,x
                    cmpa      #'d       ; compare A with #'d
                    lbeq      childdelete ; branch when equal or zero childdelete
                    clr       checks,u  ; clear checks,u
                    lbsr      maketest  ; call helper maketest
                    leax      target,pcr ; point X at target,pcr
                    lda       #DIR.+READ. ; load A from #DIR.+READ.
                    os9       I$Open    ; invoke OS-9 I$Open service
                    lbcs      fail      ; branch on carry or error fail
                    sta       held,u    ; save A in held,u
                    leax      busy,pcr  ; point X at busy,pcr
                    lbsr      spawn     ; call helper spawn
                    lda       held,u    ; load A from held,u
                    os9       I$Dup     ; invoke OS-9 I$Dup service
                    lbcs      fail      ; branch on carry or error fail
                    pshs      a         ; preserve a on stack
                    lbsr      closeheld ; call helper closeheld
                    puls      a         ; restore a from stack
                    sta       held,u    ; save A in held,u
                    leax      busy,pcr  ; point X at busy,pcr
                    lbsr      spawn     ; call helper spawn
                    lbsr      closeheld ; call helper closeheld
                    leax      removeok,pcr ; point X at removeok,pcr
                    lbsr      spawn     ; call helper spawn
* Only the parent keeps this data-directory reference after child setup.
                    lbsr      maketest  ; call helper maketest
                    leax      target,pcr ; point X at target,pcr
                    lda       #READ.    ; load A from #READ.
                    os9       I$ChgDir  ; invoke OS-9 I$ChgDir service
                    lbcs      fail      ; branch on carry or error fail
                    leax      busy,pcr  ; point X at busy,pcr
                    lbsr      spawn     ; call helper spawn
                    lbsr      resetdirs ; call helper resetdirs
                    leax      removeok,pcr ; point X at removeok,pcr
                    lbsr      spawn     ; call helper spawn
* Likewise for the execution directory, which is independent of data cwd.
                    lbsr      maketest  ; call helper maketest
                    leax      target,pcr ; point X at target,pcr
                    lda       #EXEC.    ; load A from #EXEC.
                    os9       I$ChgDir  ; invoke OS-9 I$ChgDir service
                    lbcs      fail      ; branch on carry or error fail
                    leax      busy,pcr  ; point X at busy,pcr
                    lbsr      spawn     ; call helper spawn
                    lbsr      resetdirs ; call helper resetdirs
                    leax      removeok,pcr ; point X at removeok,pcr
                    lbsr      spawn     ; call helper spawn
* A regular file makes its parent nonempty. Verify its data survived rejection.
                    lbsr      maketest  ; call helper maketest
                    leax      file,pcr  ; point X at file,pcr
                    lda       #UPDAT.   ; load A from #UPDAT.
                    ldb       #READ.+WRITE.+PREAD.+PWRIT. ; load B from #READ.+WRITE.+PREAD.+PWRIT.
                    os9       I$Create  ; invoke OS-9 I$Create service
                    lbcs      fail      ; branch on carry or error fail
                    leax      payload,pcr ; point X at payload,pcr
                    ldy       #4        ; load Y from #4
                    os9       I$Write   ; invoke OS-9 I$Write service
                    lbcs      fail      ; branch on carry or error fail
                    os9       I$Close   ; invoke OS-9 I$Close service
                    lbcs      fail      ; branch on carry or error fail
                    leax      nonempty,pcr ; point X at nonempty,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      file,pcr  ; point X at file,pcr
                    lda       #READ.    ; load A from #READ.
                    os9       I$Open    ; invoke OS-9 I$Open service
                    lbcs      fail      ; branch on carry or error fail
* Code is read-only: use stack storage for the verification buffer.
                    leas      -4,s      ; point S at -4,s
                    sta       held,u    ; save A in held,u
                    leax      ,s        ; point X at ,s
                    ldy       #4        ; load Y from #4
                    os9       I$Read    ; invoke OS-9 I$Read service
                    lbcs      fail      ; branch on carry or error fail
                    ldd       ,s        ; load D from ,s
                    cmpd      #$4B45    ; compare D with #$4B45
                    lbne      badtest   ; branch when unequal or nonzero badtest
                    ldd       2,s       ; load D from 2,s
                    cmpd      #$4550    ; compare D with #$4550
                    lbne      badtest   ; branch when unequal or nonzero badtest
                    leas      4,s       ; point S at 4,s
                    lda       held,u    ; load A from held,u
                    os9       I$Close   ; invoke OS-9 I$Close service
                    lbcs      fail      ; branch on carry or error fail
                    leax      file,pcr  ; point X at file,pcr
                    os9       I$Delete  ; invoke OS-9 I$Delete service
                    lbcs      fail      ; branch on carry or error fail
                    leax      removeok,pcr ; point X at removeok,pcr
                    lbsr      spawn     ; call helper spawn
* A child directory also makes the target nonempty.
                    lbsr      maketest  ; call helper maketest
                    leax      subdir,pcr ; point X at subdir,pcr
                    ldb       #^SHARE.  ; load B from #^SHARE.
                    os9       I$MakDir  ; invoke OS-9 I$MakDir service
                    lbcs      fail      ; branch on carry or error fail
                    leax      nonempty,pcr ; point X at nonempty,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      subdir,pcr ; point X at subdir,pcr
                    os9       I$Delete  ; invoke OS-9 I$Delete service
                    lbcs      fail      ; branch on carry or error fail
                    leax      removeok,pcr ; point X at removeok,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      rootdenied,pcr ; point X at rootdenied,pcr
                    lbsr      spawn     ; call helper spawn
                    lbsr      maketest  ; call helper maketest
                    leax      dotdenied,pcr ; point X at dotdenied,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      removeok,pcr ; point X at removeok,pcr
                    lbsr      spawn     ; call helper spawn
                    lda       checks,u  ; load A from checks,u
                    cmpa      #14       ; compare A with #14
                    lbne      badtest   ; branch when unequal or nonzero badtest
                    leax      passed,pcr ; point X at passed,pcr
                    lbsr      message   ; call helper message
                    clrb                ; clear accumulator B and carry
                    os9       F$Exit    ; invoke OS-9 F$Exit service
maketest            leax      target,pcr ; point X at target,pcr
                    ldb       #^SHARE.  ; load B from #^SHARE.
                    os9       I$MakDir  ; invoke OS-9 I$MakDir service
                    lbcs      fail      ; branch on carry or error fail
                    rts                 ; return to caller
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
countloop           lda       ,x+       ; load A from ,x+
                    cmpa      #C$CR     ; compare A with #C$CR
                    bne       countloop ; branch when unequal or nonzero countloop
                    tfr       x,d       ; transfer registers x,d
                    pshs      u         ; preserve u on stack
                    subd      ,s++      ; subtract from D: ,s++
                    tfr       d,y       ; transfer registers d,y
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
childdelete         pshs      x         ; preserve x on stack
                    lbsr      resetdirs ; call helper resetdirs
                    puls      x         ; restore x from stack
                    ldb       1,x       ; load B from 1,x
                    stb       expect,u  ; save B in expect,u
                    leax      2,x       ; point X at 2,x
                    tstb                ; test accumulator B
                    beq       attempt@  ; branch when equal or zero attempt@
                    pshs      x         ; preserve x on stack
                    leax      denybegin,pcr ; point X at denybegin,pcr
                    bsr       message   ; call helper message
                    puls      x         ; restore x from stack
attempt@            os9       I$Delete  ; invoke OS-9 I$Delete service
                    bcs       result@   ; branch on carry or error result@
                    clrb                ; clear accumulator B and carry
result@             cmpb      expect,u  ; compare B with expect,u
                    bne       badtest   ; branch when unequal or nonzero badtest
                    tstb                ; test accumulator B
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
target              fcc       "/dd/RMTEST"        ; module name or literal text
                    fcb       C$CR      ; emit byte data
root                fcc       "/dd"               ; module name or literal text
                    fcb       C$CR      ; emit byte data
commands            fcc       "/dd/cmds"          ; module name or literal text
                    fcb       C$CR      ; emit byte data
file                fcc       "/dd/RMTEST/KEEP.TXT"  ; module name or literal text
                    fcb       C$CR      ; emit byte data
subdir              fcc       "/dd/RMTEST/CHILD"  ; module name or literal text
                    fcb       C$CR      ; emit byte data
busy                fcb       'd,E$Share ; emit byte data
                    fcc       "/pc0/RMTEST"       ; module name or literal text
                    fcb       C$CR      ; emit byte data
removeok            fcb       'd,0      ; emit byte data
                    fcc       "/pc0/RMTEST"       ; module name or literal text
                    fcb       C$CR      ; emit byte data
nonempty            fcb       'd,E$DNE  ; emit byte data
                    fcc       "/pc0/RMTEST"       ; module name or literal text
                    fcb       C$CR      ; emit byte data
rootdenied          fcb       'd,E$FNA  ; emit byte data
                    fcc       "/pc0"              ; module name or literal text
                    fcb       C$CR      ; emit byte data
dotdenied           fcb       'd,E$FNA  ; emit byte data
                    fcc       "/pc0/RMTEST/."     ; module name or literal text
                    fcb       C$CR      ; emit byte data
payload             fcc       "KEEP"              ; module name or literal text
denybegin           fcc       "PCFRMDENYBEGIN"    ; module name or literal text
                    fcb       C$CR      ; emit byte data
denyend             fcc       "PCFRMDENYEND"      ; module name or literal text
                    fcb       C$CR      ; emit byte data
passed              fcc       "PCFRMDIR PASS: 14 parent/child checks"  ; module name or literal text
                    fcb       C$CR      ; emit byte data
failed              fcc       "PCFRMDIR FAIL"     ; module name or literal text
                    fcb       C$CR      ; emit byte data
                    emod      ;         finish module and CRC
eom                 equ       *         ; define constant or offset
