* Shared executable basename validator for SS.Rename.
* X advances over a zero-padded 30-byte field. B=0 on success; Y is untouched.
* RBF converts the staged name to directory-entry form after validation.
RNName              ldd       ,x
                    cmpd      #$2E00             reject dot
                    beq       RNBad
                    cmpd      #$2E2E
                    bne       RNStart
                    tst       2,x                 reject dot-dot, allow longer names
                    beq       RNBad
RNStart             ldb       #30
RNChar              lda       ,x+
                    beq       RNPad
                    decb
                    beq       RNBad               reserve a byte for the terminator
                    suba      #$21
                    cmpa      #$5E                printable ASCII, excluding space
                    bhs       RNBad
                    cmpa      #$0E                slash minus $21
                    beq       RNBad
                    cmpa      #$3B                backslash minus $21
                    beq       RNBad
                    cmpa      #$19                colon minus $21
                    beq       RNBad
                    bra       RNChar
RNPad               cmpb      #30
                    beq       RNBad               empty basename
                    ifdef     RN.RBF
                    lda       -2,x
                    ora       #$80
                    sta       -2,x
                    endc
RNPadLoop           decb
                    beq       RNValid
                    lda       ,x+
                    bne       RNBad
                    bra       RNPadLoop
RNValid             clrb
                    rts
RNBad               ldb       #E$BPNam
                    orcc      #1
                    rts

                    ifdef     RN.RBF
* Compare staged and on-disk high-bit-terminated names. Only ASCII letters
* fold case: punctuation such as @ and ` must remain distinct.
* X=directory entry, U=staged name. Preserve both pointers and PD in Y.
RNCompare           pshs      x,u
RNCmpNext           lda       ,u+
                    eora      ,x+
                    beq       RNCmpSame
                    cmpa      #$20
                    bne       RNCmpNo
                    lda       -1,u
                    anda      #$7F
                    ora       #$20
                    suba      #'a
                    cmpa      #25
                    bhi       RNCmpNo
RNCmpSame           tst       -1,u
                    bpl       RNCmpNext
                    andcc     #$FE
                    puls      x,u,pc
RNCmpNo             orcc      #1
                    puls      x,u,pc
                    endc
