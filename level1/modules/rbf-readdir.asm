RDBad               ldb       #E$BPNam  ; load B from #E$BPNam
                    bra       RDError   ; continue unconditionally RDError
RDDenied            ldb       #E$FNA    ; load B from #E$FNA
RDError             orcc      #1        ; set selected CC bits with #1
                    rts                 ; return to caller
* SS.ReadDir uses the open directory's byte position. No new resident data.
* Reuse the native scanner, buffer, metadata read and caller-copy routines.
RDRead              ldd       R$Y,u     ; load D from R$Y,u
                    cmpd      #RD.NameSize ; compare D with #RD.NameSize
                    beq       RDMode    ; branch when equal or zero RDMode
                    cmpd      #RD.Size  ; compare D with #RD.Size
                    bne       RDBad     ; branch when unequal or nonzero RDBad
RDMode              lda       PD.MOD,y  ; load A from PD.MOD,y
                    anda      #DIR.!READ. ; mask A with #DIR.!READ.
                    cmpa      #DIR.!READ. ; compare A with #DIR.!READ.
                    bne       RDDenied  ; branch when unequal or nonzero RDDenied
                    ldb       PD.CP+3,y ; load B from PD.CP+3,y
                    andb      #DIR.SZ-1 ; mask B with #DIR.SZ-1
                    bne       RDBad     ; branch when unequal or nonzero RDBad
                    pshs      u         ; preserve u on stack
                    lbsr      ReadDirectoryEntry ; call helper ReadDirectoryEntry
RDEntry             bcs       RDDone    ; branch on carry or error RDDone
                    lda       ,x        ; load A from ,x
                    beq       RDNext    ; branch when equal or zero RDNext
                    cmpa      #'.+$80   ; compare A with #'.+$80
                    beq       RDNext    ; branch when equal or zero RDNext
                    ldd       ,x        ; load D from ,x
                    cmpd      #'.*256+'.+$80 ; compare D with #'.*256+'.+$80
                    bne       RDCopy    ; branch when unequal or nonzero RDCopy
RDNext              lbsr      NextDirectoryEntry ; call helper NextDirectoryEntry
                    bra       RDEntry   ; continue unconditionally RDEntry
RDCopy              tfr       x,u       ; transfer registers x,u
                    ldx       ,s        ; load X from ,s
                    ldx       R$X,x     ; load X from R$X,x
                    ldd       #RD.NameSize ; load D from #RD.NameSize
                    bsr       RDCopyOut ; call helper RDCopyOut
                    bcs       RDDone    ; branch on carry or error RDDone
                    ldx       ,s        ; load X from ,s
                    ldd       R$Y,x     ; load D from R$Y,x
                    cmpb      #RD.NameSize ; compare B with #RD.NameSize
                    beq       RDAdvance ; branch when equal or zero RDAdvance
* Save the entry's internal FD address before replacing the sector buffer.
                    ldb       DIR.FD,u  ; load B from DIR.FD,u
                    ldx       DIR.FD+1,u ; load X from DIR.FD+1,u
                    pshs      b,x       ; preserve b,x on stack
                    lbsr      FlushSectorBuffer ; call helper FlushSectorBuffer
                    puls      b,x       ; restore b,x from stack
                    bcs       RDDone    ; branch on carry or error RDDone
                    lbsr      ReadCurrentSector ; call helper ReadCurrentSector
                    bcs       RDDone    ; branch on carry or error RDDone
                    ldx       ,s        ; load X from ,s
                    ldx       R$X,x     ; load X from R$X,x
                    leax      RD.NameSize,x ; point X at RD.NameSize,x
                    ldu       PD.BUF,y  ; load U from PD.BUF,y
                    ldd       #RD.Size-RD.NameSize ; load D from #RD.Size-RD.NameSize
                    bsr       RDCopyOut ; call helper RDCopyOut
                    bcs       RDDone    ; branch on carry or error RDDone
RDAdvance           ldd       PD.CP+2,y ; load D from PD.CP+2,y
                    addd      #DIR.SZ   ; add to D: #DIR.SZ
                    std       PD.CP+2,y ; save D in PD.CP+2,y
                    bcc       RDFlush   ; branch with carry clear RDFlush
                    inc       PD.CP+1,y ; increment PD.CP+1,y
                    bne       RDFlush   ; branch when unequal or nonzero RDFlush
                    inc       PD.CP,y   ; increment PD.CP,y
RDFlush             tst       PD.CP+3,y ; test PD.CP+3,y
                    bne       RDOk      ; branch when unequal or nonzero RDOk
                    lbsr      FlushSectorBuffer ; call helper FlushSectorBuffer
                    bcs       RDDone    ; branch on carry or error RDDone
RDOk                clrb                ; clear accumulator B and carry
RDDone              lda       PD.SMF,y  ; load A from PD.SMF,y
                    anda      #^BufBusy ; mask A with #^BufBusy
                    sta       PD.SMF,y  ; save A in PD.SMF,y
                    puls      u         ; restore u from stack
                  IFGT    Level-1 ; conditional assembly
                    lbra      ReadUnlockReturn ; normal read lock cleanup
                  ELSE            ; conditional assembly
                    rts                 ; return to caller
                  ENDC            ; conditional assembly
* Preserve the path and source, but propagate F$Move's error byte.
RDCopyOut           pshs      y,u       ; preserve y,u on stack
                    exg       x,u       ; exchange registers x,u
                    tfr       d,y       ; transfer registers d,y
                    lbsr      CopyToCaller ; call helper CopyToCaller
                    puls      y,u,pc    ; restore y,u,pc from stack
