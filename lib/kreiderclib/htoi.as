* Disassembly by Os9disasm of htoi.r

                    section   code

htoi                clra
                    clrb
                    pshs      d,u
                    ldu       6,s
                    leax      _chcodes,y
L000a               ldb       ,u
                    cmpb      #$20
                    beq       L0014
                    cmpb      #9
                    bne       L003b
L0014               leau      1,u
                    bra       L000a
L0018               ldd       ,s
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    std       ,s
                    ldb       ,u+
                    subb      #$30
                    cmpb      #9
                    ble       L0034
                    subb      #7
                    cmpb      #$0f
                    ble       L0034
                    subb      #$20
L0034               clra
                    addd      ,s
                    std       ,s
                    ldb       ,u
L003b               ldb       b,x
                    andb      #$40
                    bne       L0018
                    puls      d,u,pc

                    endsect

