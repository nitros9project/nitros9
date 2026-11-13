* Real OS-9 parent/child sharing checks. Parent retains its open path while
* each child independently opens/deletes the same file through another alias.
                    use       defsfile  ; include shared definitions or implementation
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,size ; emit OS-9 module header
                    org       0         ; set storage origin
held                rmb       1         ; reserve storage
expect              rmb       1         ; reserve storage
childid             rmb       1         ; reserve storage
checks              rmb       1         ; reserve storage
mode                rmb       1         ; reserve storage
readbyte            rmb       1         ; reserve storage
                    rmb       512       ; reserve storage
size                equ       .         ; define constant or offset
name                fcs       /pcfshare/          ; module name or literal text
                    fcb       1         ; emit byte data
start               lda       ,x        ; load A from ,x
                    cmpa      #'r       ; compare A with #'r
                    lbeq      childread ; branch when equal or zero childread
                    cmpa      #'w       ; compare A with #'w
                    lbeq      childwrite ; branch when equal or zero childwrite
                    cmpa      #'d       ; compare A with #'d
                    lbeq      childdelete ; branch when equal or zero childdelete
                    cmpa      #'x       ; compare A with #'x
                    lbeq      childexit ; branch when equal or zero childexit
                    clr       checks,u  ; clear checks,u
                    leax      filedd,pcr ; point X at filedd,pcr
                    lbsr      create    ; call helper create
                    leax      other,pcr ; point X at other,pcr
                    lbsr      create    ; call helper create
* Reader through /dd: another reader succeeds; writer/delete fail via /pc0.
                    leax      filedd,pcr ; point X at filedd,pcr
                    lda       #READ.    ; load A from #READ.
                    os9       I$Open    ; invoke OS-9 I$Open service
                    lbcs      fail      ; branch on carry or error fail
                    sta       held,u    ; save A in held,u
                    lbsr      readheld  ; call helper readheld
                    cmpb      #'A       ; compare B with #'A
                    lbne      badtest   ; branch when unequal or nonzero badtest
                    leax      readok,pcr ; point X at readok,pcr
                    lbsr      spawn     ; call helper spawn
                    lbsr      readheld  ; call helper readheld
                    cmpb      #'B       ; compare B with #'B
                    lbne      badtest   ; branch when unequal or nonzero badtest
                    leax      writebusy,pcr ; point X at writebusy,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      deletebusy,pcr ; point X at deletebusy,pcr
                    lbsr      spawn     ; call helper spawn
                    lbsr      closeheld ; call helper closeheld
* Writer through /pc0: read/write/delete fail through /dd; other file works.
                    leax      filepc,pcr ; point X at filepc,pcr
                    lda       #UPDAT.   ; load A from #UPDAT.
                    os9       I$Open    ; invoke OS-9 I$Open service
                    lbcs      fail      ; branch on carry or error fail
                    sta       held,u    ; save A in held,u
* Record locking is explicitly unsupported, rather than silently successful.
                    ldb       #SS.Lock  ; load B from #SS.Lock
                    ldx       #1        ; load X from #1
                    os9       I$SetStt  ; invoke OS-9 I$SetStt service
                    lbcc      badtest   ; branch with carry clear badtest
                    cmpb      #E$UnkSvc ; compare B with #E$UnkSvc
                    lbne      fail      ; branch when unequal or nonzero fail
                    leax      readbusy,pcr ; point X at readbusy,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      writebusydd,pcr ; point X at writebusydd,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      deletebusydd,pcr ; point X at deletebusydd,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      otherok,pcr ; point X at otherok,pcr
                    lbsr      spawn     ; call helper spawn
* A duplicate keeps the exclusion until the last reference closes.
                    lda       held,u    ; load A from held,u
                    os9       I$Dup     ; invoke OS-9 I$Dup service
                    lbcs      fail      ; branch on carry or error fail
                    pshs      a         ; preserve a on stack
                    lbsr      closeheld ; call helper closeheld
                    puls      a         ; restore a from stack
                    sta       held,u    ; save A in held,u
                    leax      readbusy,pcr ; point X at readbusy,pcr
                    lbsr      spawn     ; call helper spawn
                    lbsr      closeheld ; call helper closeheld
                    leax      readok,pcr ; point X at readok,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      writeok,pcr ; point X at writeok,pcr
                    lbsr      spawn     ; call helper spawn
* Child exits with a writable path open: kernel cleanup must release it.
                    leax      exitopen,pcr ; point X at exitopen,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      writeok,pcr ; point X at writeok,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      deleteok,pcr ; point X at deleteok,pcr
                    lbsr      spawn     ; call helper spawn
                    leax      other,pcr ; point X at other,pcr
                    os9       I$Delete  ; invoke OS-9 I$Delete service
                    lbcs      fail      ; branch on carry or error fail
                    lda       checks,u  ; load A from checks,u
                    cmpa      #13       ; compare A with #13
                    lbne      badtest   ; branch when unequal or nonzero badtest
                    leax      passed,pcr ; point X at passed,pcr
                    lbsr      message   ; call helper message
                    clrb                ; clear accumulator B and carry
                    os9       F$Exit    ; invoke OS-9 F$Exit service
create              lda       #UPDAT.   ; load A from #UPDAT.
                    ldb       #READ.+WRITE.+PREAD.+PWRIT. ; load B from #READ.+WRITE.+PREAD.+PWRIT.
                    os9       I$Create  ; invoke OS-9 I$Create service
                    lbcs      fail      ; branch on carry or error fail
                    leax      contents,pcr ; point X at contents,pcr
                    ldy       #2        ; load Y from #2
                    os9       I$Write   ; invoke OS-9 I$Write service
                    lbcs      fail      ; branch on carry or error fail
                    os9       I$Close   ; invoke OS-9 I$Close service
                    lbcs      fail      ; branch on carry or error fail
                    rts                 ; return to caller
readheld            lda       held,u    ; load A from held,u
                    leax      readbyte,u ; point X at readbyte,u
                    ldy       #1        ; load Y from #1
                    os9       I$Read    ; invoke OS-9 I$Read service
                    lbcs      fail      ; branch on carry or error fail
                    ldb       readbyte,u ; load B from readbyte,u
                    rts                 ; return to caller
closeheld           lda       held,u    ; load A from held,u
                    os9       I$Close   ; invoke OS-9 I$Close service
                    lbcs      fail      ; branch on carry or error fail
                    rts                 ; return to caller
* X points to child parameters: operation, expected error byte, path, CR.
spawn               pshs      u         ; preserve u on stack
                    tfr       x,u       ; transfer registers x,u
countloop           lda       ,x+       ; load A from ,x+
                    cmpa      #C$CR     ; compare A with #C$CR
                    bne       countloop ; branch when unequal or nonzero countloop
* Use pointer subtraction instead of the accumulator clobbered by scan.
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
childread           lda       #READ.    ; load A from #READ.
                    bra       childopen ; continue unconditionally childopen
childwrite          lda       #UPDAT.   ; load A from #UPDAT.
childopen           sta       mode,u    ; save A in mode,u
                    ldb       1,x       ; load B from 1,x
                    stb       expect,u  ; save B in expect,u
                    leax      2,x       ; point X at 2,x
                    os9       I$Open    ; invoke OS-9 I$Open service
                    bcs       childresult ; branch on carry or error childresult
                    ldb       mode,u    ; load B from mode,u
                    cmpb      #READ.    ; compare B with #READ.
                    bne       childclose ; branch when unequal or nonzero childclose
                    leax      readbyte,u ; point X at readbyte,u
                    ldy       #1        ; load Y from #1
                    os9       I$Read    ; invoke OS-9 I$Read service
                    bcs       fail      ; branch on carry or error fail
                    ldb       readbyte,u ; load B from readbyte,u
                    cmpb      #'A       ; compare B with #'A
                    bne       badtest   ; branch when unequal or nonzero badtest
childclose          os9       I$Close   ; invoke OS-9 I$Close service
                    bcs       fail      ; branch on carry or error fail
                    clrb                ; clear accumulator B and carry
                    bra       childresult ; continue unconditionally childresult
childdelete         ldb       1,x       ; load B from 1,x
                    stb       expect,u  ; save B in expect,u
                    leax      2,x       ; point X at 2,x
                    os9       I$Delete  ; invoke OS-9 I$Delete service
                    bcs       childresult ; branch on carry or error childresult
                    clrb                ; clear accumulator B and carry
childresult         cmpb      expect,u  ; compare B with expect,u
                    bne       badtest   ; branch when unequal or nonzero badtest
                    clrb                ; clear accumulator B and carry
                    os9       F$Exit    ; invoke OS-9 F$Exit service
childexit           leax      2,x       ; point X at 2,x
                    lda       #UPDAT.   ; load A from #UPDAT.
                    os9       I$Open    ; invoke OS-9 I$Open service
                    bcs       fail      ; branch on carry or error fail
                    clrb                ; clear accumulator B and carry
                    os9       F$Exit    ; invoke OS-9 F$Exit service
badtest             ldb       #E$IllArg ; load B from #E$IllArg
fail                pshs      b         ; preserve b on stack
                    leax      failed,pcr ; point X at failed,pcr
                    lbsr      message   ; call helper message
                    puls      b         ; restore b from stack
                    os9       F$Exit    ; invoke OS-9 F$Exit service
message             lda       #1        ; load A from #1
                    ldy       #100      ; load Y from #100
                    os9       I$WritLn  ; invoke OS-9 I$WritLn service
                    rts                 ; return to caller
filedd              fcc       "/dd/share.txt"     ; module name or literal text
                    fcb       C$CR      ; emit byte data
filepc              fcc       "/pc0/share.txt"    ; module name or literal text
                    fcb       C$CR      ; emit byte data
other               fcc       "/dd/other.txt"     ; module name or literal text
                    fcb       C$CR      ; emit byte data
readok              fcb       'r,0      ; emit byte data
                    fcc       "/pc0/share.txt"    ; module name or literal text
                    fcb       C$CR      ; emit byte data
writebusy           fcb       'w,E$Share ; emit byte data
                    fcc       "/pc0/share.txt"    ; module name or literal text
                    fcb       C$CR      ; emit byte data
deletebusy          fcb       'd,E$Share ; emit byte data
                    fcc       "/pc0/share.txt"    ; module name or literal text
                    fcb       C$CR      ; emit byte data
readbusy            fcb       'r,E$Share ; emit byte data
                    fcc       "/dd/share.txt"     ; module name or literal text
                    fcb       C$CR      ; emit byte data
writebusydd         fcb       'w,E$Share ; emit byte data
                    fcc       "/dd/share.txt"     ; module name or literal text
                    fcb       C$CR      ; emit byte data
deletebusydd        fcb       'd,E$Share ; emit byte data
                    fcc       "/dd/share.txt"     ; module name or literal text
                    fcb       C$CR      ; emit byte data
otherok             fcb       'w,0      ; emit byte data
                    fcc       "/dd/other.txt"     ; module name or literal text
                    fcb       C$CR      ; emit byte data
writeok             fcb       'w,0      ; emit byte data
                    fcc       "/pc0/share.txt"    ; module name or literal text
                    fcb       C$CR      ; emit byte data
exitopen            fcb       'x,0      ; emit byte data
                    fcc       "/dd/share.txt"     ; module name or literal text
                    fcb       C$CR      ; emit byte data
deleteok            fcb       'd,0      ; emit byte data
                    fcc       "/pc0/share.txt"    ; module name or literal text
                    fcb       C$CR      ; emit byte data
contents            fcc       "AB"                ; module name or literal text
passed              fcc       "PCFSHARE PASS: 13 parent/child checks"  ; module name or literal text
                    fcb       C$CR      ; emit byte data
failed              fcc       "PCFSHARE FAIL"     ; module name or literal text
                    fcb       C$CR      ; emit byte data
                    emod      ;         finish module and CRC
eom                 equ       *         ; define constant or offset
