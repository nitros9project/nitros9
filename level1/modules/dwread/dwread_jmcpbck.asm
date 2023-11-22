* NOTE: There is no timeout currently on here...
DWRead              clra                          ; clear Carry (no framing error)
                    deca                          ; clear Z flag, A = timeout msb ($ff)
                    tfr       cc,b
                    pshs      u,x,dp,b,a          ; preserve registers, push timeout msb
                    leau      ,x
                    ldx       #$0000
                    orcc      #IntMasks
loop@               ldb       $FF4C
                    bitb      #$02
                    beq       loop@
                    ldb       $FF44
                    stb       ,u+
                    abx
                    leay      ,-y
                    bne       loop@

                    tfr       x,y
                    ldb       #0
                    lda       #3
                    leas      1,s                 ; remove timeout msb from stack
                    inca                          ; A = status to be returned in C and Z
                    ora       ,s                  ; place status information into the..
                    sta       ,s                  ; ..C and Z bits of the preserved CC
                    leay      ,x                  ; return checksum in Y
                    puls      cc,dp,x,u,pc        ; restore registers and return
