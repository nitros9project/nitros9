                    ifndef    BECKBASE
BECKBASE            equ       $FF41
                    endc
* X=destination, Y=count; return checksum in Y, C clear/Z set on success.
* A bounded per-byte poll also works with IRQs masked (no timer dependency).
DWRead              pshs      cc,u,x
                    leau      ,x
                    ldx       #0
                    cmpy      #0
                    beq       done@
                    ifeq      NOINTMASK
                    orcc      #IntMasks
                    endc
next@               pshs      x
                    ldx       #$8000
poll@               ldb       BECKBASE
                    bitb      #2
                    bne       ready@
                    leax      -1,x
                    bne       poll@
                    puls      x
                    puls      cc,x,u
                    andcc     #$FB
                    orcc      #1
                    rts
ready@              puls      x
                    ldb       BECKBASE+1
                    stb       ,u+
                    abx
                    leay      -1,y
                    bne       next@
done@               leay      ,x
                    puls      cc,x,u
                    andcc     #$FE
                    orcc      #4
                    rts
