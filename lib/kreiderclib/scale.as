* Disassembly by Os9disasm of scale.r

                    section   bss

* Initialized Data (class G)
atoftbl             fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $80
                    fcb       $20
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $84
                    fcb       $48
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $87
                    fcb       $7a
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $8a
                    fcb       $1c
                    fcb       $40
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $8e
                    fcb       $43
                    fcb       $50
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $91
                    fcb       $74
                    fcb       $24
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $94
                    fcb       $18
                    fcb       $96
                    fcb       $80
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $98
                    fcb       $3e
                    fcb       $bc
                    fcb       $20
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $9b
                    fcb       $6e
                    fcb       $6b
                    fcb       $28
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $9e
                    fcb       $15
                    fcb       $02
                    fcb       $f9
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $a2
                    fcb       $2d
                    fcb       $78
                    fcb       $eb
                    fcb       $c5
                    fcb       $ac
                    fcb       $62
                    fcb       $00
                    fcb       $c3
                    fcb       $49
                    fcb       $f2
                    fcb       $c9
                    fcb       $cd
                    fcb       $04
                    fcb       $67
                    fcb       $4f
                    fcb       $e4

                    endsect

                    section   code

L0000               pshs      u
                    ldd       12,s
                    beq       L003c
                    ldd       14,s
                    beq       L0023
                    leax      4,s
                    lbsr      _dstack
                    ldd       20,s
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    leax      atoftbl,y
                    leax      d,x
                    lbsr      _dmul
                    bra       L003e
L0023               leax      4,s
                    lbsr      _dstack
                    ldd       20,s
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    leax      atoftbl,y
                    leax      d,x
                    lbsr      _ddiv
                    bra       L003e
L003c               leax      4,s
L003e               leau      _flacc,y
                    pshs      u
                    lbsr      _dmove
                    puls      u,pc
scale               pshs      u
                    ldd       12,s
                    cmpd      #9
                    ble       L0079
                    leax      4,s
                    pshs      x
                    ldd       16,s
                    pshs      d
                    ldd       16,s
                    pshs      d
                    ldd       #$000a
                    lbsr      ccdiv
                    addd      #9
                    pshs      d
                    leax      10,s
                    lbsr      _dstack
                    lbsr      L0000
                    leas      12,s
                    lbsr      _dmove
L0079               ldd       14,s
                    pshs      d
                    ldd       14,s
                    pshs      d
                    ldd       #$000a
                    lbsr      ccmod
                    pshs      d
                    leax      8,s
                    lbsr      _dstack
                    lbsr      L0000
                    leas      12,s
                    puls      u,pc

                    endsect

