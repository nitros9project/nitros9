RDBad               ldb       #E$BPNam
                    bra       RDError
RDDenied            ldb       #E$FNA
RDError             orcc      #1
                    rts
* SS.ReadDir uses the open directory's byte position. No new resident data.
* Reuse the native scanner, buffer, metadata read and caller-copy routines.
RDRead              ldd       R$Y,u
                    cmpd      #RD.NameSize
                    beq       RDMode
                    cmpd      #RD.Size
                    bne       RDBad
RDMode              lda       PD.MOD,y
                    anda      #DIR.!READ.
                    cmpa      #DIR.!READ.
                    bne       RDDenied
                    ldb       PD.CP+3,y
                    andb      #DIR.SZ-1
                    bne       RDBad
                    pshs      u
                    lbsr      L0957
RDEntry             bcs       RDDone
                    lda       ,x
                    beq       RDNext
                    cmpa      #'.+$80
                    beq       RDNext
                    ldd       ,x
                    cmpd      #'.*256+'.+$80
                    bne       RDCopy
RDNext              lbsr      L0942
                    bra       RDEntry
RDCopy              tfr       x,u
                    ldx       ,s
                    ldx       R$X,x
                    ldd       #RD.NameSize
                    bsr       RDCopyOut
                    bcs       RDDone
                    ldx       ,s
                    ldd       R$Y,x
                    cmpb      #RD.NameSize
                    beq       RDAdvance
* Save the entry's internal FD address before replacing the sector buffer.
                    ldb       DIR.FD,u
                    ldx       DIR.FD+1,u
                    pshs      b,x
                    lbsr      L1237
                    puls      b,x
                    bcs       RDDone
                    lbsr      L113A
                    bcs       RDDone
                    ldx       ,s
                    ldx       R$X,x
                    leax      RD.NameSize,x
                    ldu       PD.BUF,y
                    ldd       #RD.Size-RD.NameSize
                    bsr       RDCopyOut
                    bcs       RDDone
RDAdvance           ldd       PD.CP+2,y
                    addd      #DIR.SZ
                    std       PD.CP+2,y
                    bcc       RDFlush
                    inc       PD.CP+1,y
                    bne       RDFlush
                    inc       PD.CP,y
RDFlush             tst       PD.CP+3,y
                    bne       RDOk
                    lbsr      L1237
                    bcs       RDDone
RDOk                clrb
RDDone              lda       PD.SMF,y
                    anda      #^BufBusy
                    sta       PD.SMF,y
                    puls      u
                    ifgt      Level-1
                    lbra      Read4C5             normal read lock cleanup
                    else
                    rts
                    endc
* Preserve the path and source, but propagate F$Move's error byte.
RDCopyOut           pshs      y,u
                    exg       x,u
                    tfr       d,y
                    lbsr      RdLn49B
                    puls      y,u,pc
