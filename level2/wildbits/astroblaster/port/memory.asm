* Owned-buffer helpers. These never accept original physical G80 addresses.
* CopyBytes: X source, Y destination, U length. Advance X/Y; preserve D/U.
* Overlap follows original forward LDIR behavior. Zero length is a no-op.
CopyBytes         pshs      d,u
                    cmpu      #0
                    beq       CopyBytesDone
CopyNextByte      lda       ,x+
                    sta       ,y+
                    leau      -1,u
                    cmpu      #0        LEAU does not set Z; test the byte count
                    bne       CopyNextByte
CopyBytesDone     puls      d,u,pc

* FillBytes: X destination, U length, A fill byte. Advance X; preserve D/U.
FillBytes         pshs      u
                    cmpu      #0
                    beq       FillBytesDone
FillNextByte      sta       ,x+
                    leau      -1,u
                    cmpu      #0        LEAU does not set Z; test the byte count
                    bne       FillNextByte
FillBytesDone     puls      u,pc

* X = CS_ record list, Y = owned target base; zero length terminates.
* Relative source words keep the table relocatable with the OS-9 module.
* Caller validates each range. Preserve D,X,Y,U; CC scratch.
CopyOwnedSpans    pshs      d,x,y,u
                    tfr       x,u
CopyOwnedSpan     ldd       CS_Length,u
                    beq       CopyOwnedSpansDone
                    ldd       CS_Source,u
                    leax      d,u
                    ldy       CS_SavedTarget,s ; stack offset: original target base
                    ldd       CS_Target,u
                    leay      d,y
                    pshs      u
                    ldu       CS_Length,u
                    bsr       CopyBytes
                    puls      u
                    leau      CS_RecordBytes,u
                    bra       CopyOwnedSpan
CopyOwnedSpansDone puls     d,x,y,u,pc

* A modulo B (B nonzero), same repeated subtraction as original $1DA0.
* Preserve B,X,Y,U; A/CC scratch. Caller supplies a positive divisor.
Remainder8        pshs      b
RemainderLoop    cmpa      ,s        stack offset: divisor
                    blo       RemainderDone
                    suba      ,s        stack offset: divisor
                    bra       RemainderLoop
RemainderDone    puls      b,pc
