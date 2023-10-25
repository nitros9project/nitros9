********************************************************************
* GFX - CoCo 2 graphics subroutine module
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.

                    nam       GFX
                    ttl       CoCo 2 graphics subroutine module

* Disassembled 98/09/25 21:47:16 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size
u0000               rmb       0
size                equ       .

name                fcs       /GFX/
                    fcb       edition

FuncTbl             fdb       Alpha-FuncTbl
                    fcc       "Alpha"
                    fcb       $FF
                    fdb       Circle-FuncTbl
                    fcc       "Circle"
                    fcb       $FF
                    fdb       Clear-FuncTbl
                    fcc       "Clear"
                    fcb       $FF
                    fdb       CColor-FuncTbl
                    fcc       "Color"
                    fcb       $FF
                    fdb       GColr-FuncTbl
                    fcc       "GColr"
                    fcb       $FF
                    fdb       GLoc-FuncTbl
                    fcc       "GLoc"
                    fcb       $FF
                    fdb       JoyStk-FuncTbl
                    fcc       "JoyStk"
                    fcb       $FF
                    fdb       Line-FuncTbl
                    fcc       "Line"
                    fcb       $FF
                    fdb       Mode-FuncTbl
                    fcc       "Mode"
                    fcb       $FF
                    fdb       Move-FuncTbl
                    fcc       "Move"
                    fcb       $FF
                    fdb       Point-FuncTbl
                    fcc       "Point"
                    fcb       $FF
                    fdb       Quit-FuncTbl
                    fcc       "Quit"
                    fcb       $FF
                    fdb       $0000

stkdepth            set       9

start               leas      -stkdepth,s
                    ldd       2+stkdepth,s        get parameter count
                    beq       BadFunc
                    tsta                          param count greater than 255?
                    bne       BadFunc             yep, branch to error
                    leau      >FuncTbl,pcr        point to function pointer table
L007D               ldy       ,u++                get pointer to function
                    beq       NoFunc

* Compare passed function name to our list
                    ldx       4+stkdepth,s
L0084               lda       ,x+                 get passed param char
                    eora      ,u+                 XOR it with compared param char
                    anda      #$DF                make case same
                    beq       L0094               branch if equal
                    leau      -1,u                back up one
L008E               tst       ,u+
                    bpl       L008E
                    bra       L007D
L0094               tst       -1,u
                    bpl       L0084
                    tfr       y,d                 put funcion pointer in D
                    leay      >FuncTbl,pcr        point Y to table
                    leay      d,y                 get function address
                    leax      ,s
                    leau      <$11,s
                    ldd       stkdepth+2,s        put parameter count in D
                    jmp       ,y

NoFunc              ldb       #E$NoRout
                    bra       L00AF
BadFunc             ldb       #E$ParmEr           $38
L00AF               coma
                    leas      stkdepth,s
                    rts

* Each subroutine enters with the following parameters
* B = parameter count
* X = temporary stack
* U = pointer to size of first parameter

Mode                lda       #$0F
                    bra       L00B9

Move                lda       #$15
L00B9               cmpb      #$03                correct number of params?
                    bne       BadFunc
                    bra       L010B

CColor              lda       #$11
                    bra       L00DE

Point               cmpb      #$03                correct number of params?
                    beq       L00D4
                    cmpb      #$04
                    bne       BadFunc
                    leau      <$19,s
                    lbsr      L015E
                    leau      <$11,s
L00D4               lda       #$18
                    bra       L010B

Clear               cmpb      #$01                correct number of params?
                    beq       L00E4
                    lda       #$10
L00DE               cmpb      #$02
                    bne       BadFunc
                    bra       L0136

L00E4               lda       #$13
                    bra       L0142

Line                cmpb      #$06                correct number of params?
                    bhi       BadFunc
                    cmpb      #$03
                    bcs       L015B
                    bitb      #$01
                    bne       L0103
                    leau      <$19,s
                    cmpb      #$04
                    beq       L00FE
                    leau      <$21,s
L00FE               bsr       L015E
                    leau      <$11,s
L0103               cmpb      #$04
                    bls       L0109
                    bsr       L0164
L0109               lda       #$16
L010B               sta       ,x+
                    bsr       L016E
                    bsr       L016E
                    bra       L0144

Circle              cmpb      #$05                correct number of params?
                    bhi       L015B
                    cmpb      #$02
                    bcs       L015B
                    bitb      #$01
                    beq       L012E
                    leau      <$15,s
                    cmpb      #$03
                    beq       L0129
                    leau      <$1D,s
L0129               bsr       L015E
                    leau      <$11,s
L012E               cmpb      #$03
                    bls       L0134
                    bsr       L0164
L0134               lda       #$1A
L0136               sta       ,x+
                    bsr       L016E
                    bra       L0144

Alpha               lda       #$0E
                    bra       L0142

Quit                lda       #$12
L0142               sta       ,x+
L0144               bsr       L0149
                    leas      stkdepth,s
                    rts

L0149               tfr       x,d
                    leax      2,s
                    pshs      x
                    subd      ,s++
                    tfr       d,y
                    lda       #1
                    os9       I$Write
                    rts

L0159               leas      $06,s
L015B               lbra      BadFunc
L015E               lda       #$11
                    sta       ,x+
                    bra       L016E
L0164               puls      y
                    lda       #$15
                    sta       ,x+
                    bsr       L016E
                    pshs      y
L016E               pshs      y,b,a
                    ldd       [,u++]
                    sta       ,x+
                    pulu      y
                    leay      -$01,y
                    beq       L0183
                    leay      -$01,y
                    bne       L0159
                    tsta
                    bne       L0159
                    stb       -$01,x
L0183               puls      pc,y,b,a

GLoc                cmpb      #$02                correct number of params?
                    bne       L015B
                    ldx       <$13,s
                    leax      -$02,x
                    bne       L015B
                    lda       #1                  standard out
                    ldb       #SS.DStat
                    os9       I$GetStt
                    bcs       L019C
                    stx       [<$11,s]
L019C               leas      stkdepth,s
                    rts

GColr               cmpb      #2                  correct number of params?
                    beq       L01AD
                    cmpb      #$04
                    bne       L015B
                    bsr       L0164
                    bsr       L0149
                    bcs       L019C
L01AD               lda       #$01
                    ldb       #$12
                    os9       I$GetStt
                    bcs       L019C
                    tfr       a,b
                    bra       L01ED
L01BA               leau      $04,u
                    pshs      u,x
                    ldx       -$02,u
                    ldu       -$04,u
                    leax      -$01,x
                    beq       L01CC
                    leax      -$01,x
                    bne       L0159
                    clr       ,u+
L01CC               stb       ,u+
                    puls      pc,u,x

JoyStk              cmpb      #5                  correct number of params?
                    bne       L015B
                    clr       ,x+
                    bsr       L016E
                    ldx       -2,x
                    lda       #1
                    ldb       #SS.Joy
                    os9       I$GetStt
                    bcs       L019C
                    tfr       a,b
                    bsr       L01BA
                    tfr       x,d
                    bsr       L01BA
                    tfr       y,d
L01ED               bsr       L01BA
                    leas      stkdepth,s
                    rts

                    emod
eom                 equ       *
                    end
