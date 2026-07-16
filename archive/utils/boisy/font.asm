                    nam       Font
                    ttl       Sets Fonts

                    ifp1
                    use       defsfile
                    endc

                    mod       psize,pname,Prgrm+Objct,ReEnt+1,dsize,start

pname               fcs       /Font/

temp                rmb       2
mpf                 rmb       2
fontset             rmb       3
fontinfo            rmb       2
stack               rmb       200
params              rmb       200
BadBuff             fcc       /You've selected an undefined buffer./
                    fcb       C$LF,C$LF,C$CR
dsize               equ       *

start               decb
                    beq       error
                    leay      fontset,u
                    ldd       #$1b3a
                    std       ,y++
                    lda       #$c8
                    sta       ,y+
                    leay      fontinfo,u
                    ldb       #1
loop1               bsr       numcvt
                    sta       ,Y+
                    decb
                    bne       loop1
                    leax      fontset,u
                    ldy       #4
                    lda       #1
                    os9       I$Write
                    bcc       Exit
                    cmpb      #194
                    bne       error
                    leax      BadBuff,pcr
                    lda       #2
                    ldy       #50
                    os9       I$WritLn
                    bra       Exit
numcvt              pshs      b,y
nloop2              lda       ,x+
                    cmpa      #$30
                    blo       nout2
                    cmpa      #$39
                    bhi       nout2
                    bra       nloop2
nout2               pshs      x
                    leax      -1,x
                    clr       temp,u
                    lda       #1
                    sta       mpf,u
nloop3              lda       ,-x
                    cmpa      #$30
                    blo       nout3
                    cmpa      #$39
                    bhi       nout3
                    suba      #$30
                    ldb       mpf,u
                    mul
                    addb      temp,u
                    stb       temp,u
                    lda       mpf,u
                    ldb       #10
                    mul
                    stb       mpf,u
                    bra       nloop3
nout3               lda       temp,u
                    puls      x
                    puls      b,y,pc
exit                clrb
error               os9       F$Exit

                    emod
psize               equ       *
                    end

