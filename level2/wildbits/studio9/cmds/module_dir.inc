* U = S9ModulePathBytes-byte destination. X returns its filename insertion point.
* Resolve the inherited execution device once, without changing either directory.
* Preserves Y/U. Carry/B report errors. SS.DevNm returns an FCS device name.
S9InitDir           pshs      y,u
                    lda       #'/
                    sta       ,u+
                    leax      S9ExecDot,pcr
                    lda       #DIR.+EXEC.+READ.
                    os9       I$Open
                    bcs       s9dirret@
                    pshs      a                   STACK OFFSET 0: temporary open directory path
                    tfr       u,x
                    ldb       #SS.DevNm
                    os9       I$GetStt
                    pshs      b,cc
                    lda       2,s                 STACK OFFSET 2: path below saved CC/B
                    os9       I$Close
                    puls      cc,b
                    leas      1,s
                    bcs       s9dirret@
                    tfr       u,x
                    ldb       #32                 capacity of SS.DevNm result
s9dirscan@          lda       ,x
                    bmi       s9dirend@
                    leax      1,x
                    decb
                    bne       s9dirscan@
                    ldb       #E$BPNam
                    orcc      #Carry
                    bra       s9dirret@
s9dirend@           anda      #$7F
                    sta       ,x+
                    leay      S9DirSuffix,pcr
s9dircopy@          lda       ,y+
                    sta       ,x+
                    bne       s9dircopy@
                    leax      -1,x
                    clrb
s9dirret@           puls      y,u,pc
S9ExecDot           fcb       '.,C$CR
S9DirSuffix         fcc       "/s9/"
                    fcb       0
