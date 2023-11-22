* Note: this is an optimistic routine. It presumes that the server will always be there, and
* has NO timeout fallback. It is also very short and quick.

DWRead              clra                          ; clear Carry (no framing error)
                    pshs      u,x,cc              ; preserve registers
                    leau      ,x
                    ldx       #$0000
loop@               tst       $FF51               ; check for CA1 bit (1=Arduino has byte ready)
                    bpl       loop@               ; loop if not set
                    ldb       $FF50               ; clear CA1 bit in status register
                    stb       ,u+                 ; save off acquired byte
                    abx                           ; update checksum
                    leay      ,-y
                    bne       loop@
                    leay      ,x                  ; return checksum in Y
                    puls      cc,x,u,pc           ; restore registers and return
