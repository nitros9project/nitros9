* DATE$ and EOF functions
DATFNC               pshs      x
                    leay      -6,y
                    leax      -6,y
                    ldu       <u0048
                    stu       1,y
                    os9       F$Time
                    bcs       ENDSTR
                    lda       ,x+
                    ldb       #'/
                    cmpa      #100
                    blo       Y19
cnty                suba      #100
                    bhs       cnty
                    adda      #100
Y19                 bsr       DATC10
                    lda       #'/
                    bsr       DATCNV
                    lda       #'/
                    bsr       DATCNV
                    lda       #$20
                    bsr       DATCNV
                    lda       #':
                    bsr       DATCNV
                    lda       #':
                    bsr       DATCNV
                    bra       ENDSTR

DATCNV               sta       ,u+
L5021               lda       ,x+
                    ldb       #'/
DATC10               incb
                    suba      #10
                    bcc       DATC10
                    stb       ,u+
                    ldb       #':
DATC20               decb
                    inca
                    bne       DATC20
                    stb       ,u+
                    rts

EOFFNC               lda       2,y
                    ldb       #SS.EOF
                    os9       I$GetStt
                    bcc       L5046
                    cmpb      #E$EOF
                    bne       L5046
                    ldb       #$FF
                    bra       L5048
L5046               ifeq      INCLUDED&EDITOR
                    ldb       #$00
                    else
L5046               clrb
                    endc
L5048               clra
                    std       1,y
                    lda       #3
                    sta       ,y
                    rts
