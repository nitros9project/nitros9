* Shared executable basename validator for SS.Rename.
* Validate one zero-padded 30-byte basename. X advances by 30; B=length.
RNName              pshs      x,y
                    leay      30,x
                    pshs      y
                    clrb
RNChar              lda       ,x+
                    beq       RNPad
                    cmpb      #29
                    bhs       RNBad
                    cmpa      #$21
                    blo       RNBad
                    cmpa      #$7F
                    bhs       RNBad
                    cmpa      #'/
                    beq       RNBad
                    cmpa      #$5C
                    beq       RNBad
                    cmpa      #':
                    beq       RNBad
                    incb
                    bra       RNChar
RNPad               tstb
                    beq       RNBad
                    ldx       2,s
                    lda       ,x
                    cmpa      #'.
                    bne       RNPadStart
                    cmpb      #1
                    beq       RNBad
                    cmpb      #2
                    bne       RNPadStart
                    lda       1,x
                    cmpa      #'.
                    beq       RNBad
RNPadStart          abx
RNPadLoop           lda       ,x+
                    bne       RNBad
                    cmpx      ,s
                    blo       RNPadLoop
                    leas      4,s
                    puls      y
                    andcc     #$FE
                    rts
RNBad               leas      2,s
                    puls      x,y
                    ldb       #E$BPNam
                    orcc      #1
                    rts

* Compare X=plain name, B=length, Y=high-bit-terminated directory entry.
* Carry clear on match; preserve pointers and count.
RNCompare           pshs      x,y,b
RNCmpNext           lda       ,y+
                    pshs      a
                    anda      #$7F
                    bsr       RNUpper
                    pshs      a
                    lda       ,x+
                    bsr       RNUpper
                    cmpa      ,s+
                    bne       RNCmpBadStack
                    decb
                    puls      a
                    tsta
                    bmi       RNCmpLast
                    tstb
                    bne       RNCmpNext
RNCmpNo             orcc      #1
                    puls      x,y,b,pc
RNCmpBadStack       leas      1,s
                    bra       RNCmpNo
RNCmpLast           tstb
                    bne       RNCmpNo
                    andcc     #$FE
                    puls      x,y,b,pc
RNUpper             cmpa      #'a
                    blo       RNUpperDone
                    cmpa      #'z
                    bhi       RNUpperDone
                    anda      #$DF
RNUpperDone         rts
