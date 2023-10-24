* Disassembly by Os9disasm of mem.r

* OS-9 system function equates

F$Mem               equ       $07

                    section   bss

* Uninitialized data (class B)
_spare              rmb       2
* Initialized Data (class G)

                    endsect

                    section   code

sbrk                ldd       memend,y
                    pshs      d
                    ldd       4,s
                    cmpd      _spare,y
                    bcs       L0035
                    pshs      y
                    clra
                    clrb
                    os9       F$Mem
                    addd      6,s
                    os9       F$Mem
                    tfr       y,d
                    puls      y
                    bcc       L0027
                    ldd       #-1
                    leas      2,s
                    rts
L0027               std       memend,y
                    addd      _spare,y
                    subd      ,s
                    std       _spare,y
L0035               leas      2,s
                    ldd       _spare,y
                    pshs      d
                    subd      4,s
                    std       _spare,y
                    ldd       memend,y
                    subd      ,s++
                    pshs      d
                    clra
                    ldx       ,s
L004e               sta       ,x+
                    cmpx      memend,y
                    bcs       L004e
                    puls      d,pc
ibrk                ldd       2,s
                    addd      _mtop,y
                    bcs       L0081
                    cmpd      _stbot,y
                    bcc       L0081
                    pshs      d
                    ldx       _mtop,y
                    clra
L006e               cmpx      ,s
                    bcc       L0076
                    sta       ,x+
                    bra       L006e
L0076               ldd       _mtop,y
                    puls      x
                    stx       _mtop,y
                    rts
L0081               ldd       #-1
                    rts
unbrk               ldd       2,s
                    pshs      y
                    os9       F$Mem
                    bcc       L0093
                    ldd       #-1
                    puls      y,pc
L0093               tfr       y,d
                    puls      y
                    std       memend,y
                    clra
                    clrb
                    std       _spare,y
                    rts

                    endsect

