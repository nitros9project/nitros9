********************************************************************
* progname - program module
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*  -     Original Pascal 2.0 distribution version
*
* $Log$
* Revision 1.1  2002/04/05 08:23:28  roug
* Checked in Pascal 2.0
*
*

                    nam       PascalE
                    ttl       program module

* Disassembled 02/04/05 10:05:29 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       /dd/defs/os9defs
                    endc
tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
                    mod       eom,name,tylg,atrv,start,size
u0000               rmb       2
u0002               rmb       2
u0004               rmb       1
u0005               rmb       1
u0006               rmb       1
u0007               rmb       1
u0008               rmb       1
u0009               rmb       1
u000A               rmb       1
u000B               rmb       1
u000C               rmb       1
u000D               rmb       1
u000E               rmb       1
u000F               rmb       1
u0010               rmb       6
u0016               rmb       2
u0018               rmb       2
u001A               rmb       6
u0020               rmb       2
u0022               rmb       12
u002E               rmb       18
u0040               rmb       2
u0042               rmb       2
u0044               rmb       2
u0046               rmb       2
u0048               rmb       6
u004E               rmb       2
u0050               rmb       58
u008A               rmb       2
u008C               rmb       2
u008E               rmb       1
u008F               rmb       6
u0095               rmb       4
u0099               rmb       2
u009B               rmb       245
u0190               rmb       5
u0195               rmb       6
u019B               rmb       4
u019F               rmb       4
u01A3               rmb       4160
size                equ       .
name                equ       *
                    fcs       /PascalE/
                    fcb       $01
L0015               fcb       $2A                 *
                    fcb       $45                 E
                    fcb       $52                 R
                    fcb       $52                 R
                    fcb       $4F                 O
                    fcb       $52                 R
                    fcb       $20
                    fcb       $4E                 N
                    fcb       $6F                 o
                    fcb       $20
                    fcb       $70                 p
                    fcb       $63                 c
                    fcb       $6F                 o
                    fcb       $64                 d
                    fcb       $65                 e
                    fcb       $20
                    fcb       $66                 f
                    fcb       $69                 i
                    fcb       $6C                 l
                    fcb       $65                 e
                    fcb       $20
                    fcb       $6E                 n
                    fcb       $61                 a
                    fcb       $6D                 m
                    fcb       $65                 e
                    fcb       $20
                    fcb       $68                 h
                    fcb       $61                 a
                    fcb       $73                 s
                    fcb       $20
                    fcb       $62                 b
                    fcb       $65                 e
                    fcb       $65                 e
                    fcb       $6E                 n
                    fcb       $20
                    fcb       $66                 f
                    fcb       $6F                 o
                    fcb       $75                 u
                    fcb       $6E                 n
                    fcb       $64                 d
                    fcb       $2E                 .
                    fcb       $20
                    fcb       $20
                    fcb       $41                 A
                    fcb       $20
                    fcb       $70                 p
                    fcb       $63                 c
                    fcb       $6F                 o
                    fcb       $64                 d
                    fcb       $65                 e
                    fcb       $20
                    fcb       $66                 f
                    fcb       $69                 i
                    fcb       $6C                 l
                    fcb       $65                 e
                    fcb       $20
                    fcb       $6E                 n
                    fcb       $61                 a
                    fcb       $6D                 m
                    fcb       $65                 e
                    fcb       $20
L0052               fcb       $6D                 m
                    fcb       $75                 u
                    fcb       $73                 s
                    fcb       $74                 t
                    fcb       $20
                    fcb       $62                 b
                    fcb       $65                 e
                    fcb       $20
                    fcb       $73                 s
                    fcb       $75                 u
                    fcb       $70                 p
                    fcb       $70                 p
                    fcb       $6C                 l
                    fcb       $69                 i
                    fcb       $65                 e
                    fcb       $64                 d
                    fcb       $20
                    fcb       $69                 i
                    fcb       $6D                 m
                    fcb       $6D                 m
                    fcb       $65                 e
                    fcb       $64                 d
                    fcb       $69                 i
                    fcb       $61                 a
                    fcb       $74                 t
                    fcb       $65                 e
                    fcb       $6C                 l
                    fcb       $79                 y
                    fcb       $20
                    fcb       $66                 f
                    fcb       $6F                 o
                    fcb       $6C                 l
                    fcb       $6C                 l
                    fcb       $6F                 o
                    fcb       $77                 w
                    fcb       $69                 i
                    fcb       $6E                 n
                    fcb       $67                 g
                    fcb       $20
                    fcb       $61                 a
                    fcb       $20
                    fcb       $22                 "
                    fcb       $3A                 :
                    fcb       $22                 "
                    fcb       $20
                    fcb       $6F                 o
                    fcb       $6E                 n
                    fcb       $20
                    fcb       $74                 t
                    fcb       $68                 h
                    fcb       $65                 e
                    fcb       $20
                    fcb       $63                 c
                    fcb       $6F                 o
                    fcb       $6D                 m
                    fcb       $6D                 m
                    fcb       $61                 a
                    fcb       $6E                 n
                    fcb       $64                 d
                    fcb       $20
                    fcb       $6C                 l
                    fcb       $69                 i
                    fcb       $6E                 n
                    fcb       $65                 e
                    fcb       $2E                 .
L0093               fcb       $46                 F
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
L009C               fcb       $2A                 *
                    fcb       $45                 E
                    fcb       $52                 R
                    fcb       $52                 R
                    fcb       $4F                 O
                    fcb       $52                 R
                    fcb       $20
                    fcb       $4F                 O
                    fcb       $53                 S
                    fcb       $2D                 -
                    fcb       $39                 9
                    fcb       $20
                    fcb       $65                 e
                    fcb       $72                 r
                    fcb       $72                 r
                    fcb       $6F                 o
                    fcb       $72                 r
                    fcb       $20
L00AE               fcb       $20
                    fcb       $65                 e
                    fcb       $6E                 n
                    fcb       $63                 c
                    fcb       $6F                 o
                    fcb       $75                 u
                    fcb       $6E                 n
                    fcb       $74                 t
                    fcb       $65                 e
                    fcb       $72                 r
                    fcb       $65                 e
                    fcb       $64                 d
                    fcb       $20
                    fcb       $77                 w
                    fcb       $68                 h
                    fcb       $65                 e
                    fcb       $6E                 n
                    fcb       $20
                    fcb       $74                 t
                    fcb       $72                 r
                    fcb       $79                 y
                    fcb       $69                 i
                    fcb       $6E                 n
                    fcb       $67                 g
                    fcb       $20
                    fcb       $74                 t
                    fcb       $6F                 o
                    fcb       $20
                    fcb       $6F                 o
                    fcb       $70                 p
                    fcb       $65                 e
                    fcb       $6E                 n
                    fcb       $20
                    fcb       $66                 f
                    fcb       $69                 i
                    fcb       $6C                 l
                    fcb       $65                 e
                    fcb       $2E                 .
L00D4               fcb       $46                 F
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
                    fcb       $20
L00DD               fcb       $2A                 *
                    fcb       $45                 E
                    fcb       $52                 R
                    fcb       $52                 R
                    fcb       $4F                 O
                    fcb       $52                 R
                    fcb       $20
                    fcb       $50                 P
                    fcb       $63                 c
                    fcb       $6F                 o
                    fcb       $64                 d
                    fcb       $65                 e
                    fcb       $20
                    fcb       $66                 f
                    fcb       $69                 i
                    fcb       $6C                 l
                    fcb       $65                 e
                    fcb       $20
                    fcb       $68                 h
                    fcb       $61                 a
                    fcb       $73                 s
                    fcb       $20
                    fcb       $62                 b
                    fcb       $65                 e
                    fcb       $65                 e
                    fcb       $6E                 n
                    fcb       $20
                    fcb       $61                 a
                    fcb       $6C                 l
                    fcb       $74                 t
                    fcb       $65                 e
                    fcb       $72                 r
                    fcb       $65                 e
                    fcb       $64                 d
                    fcb       $20
                    fcb       $6F                 o
                    fcb       $72                 r
                    fcb       $20
                    fcb       $68                 h
                    fcb       $61                 a
                    fcb       $73                 s
                    fcb       $20
                    fcb       $69                 i
                    fcb       $6E                 n
                    fcb       $76                 v
                    fcb       $61                 a
                    fcb       $6C                 l
                    fcb       $69                 i
                    fcb       $64                 d
                    fcb       $20
                    fcb       $66                 f
                    fcb       $6F                 o
                    fcb       $72                 r
                    fcb       $6D                 m
                    fcb       $61                 a
                    fcb       $74                 t
                    fcb       $2E                 .
L0116               fcb       $31                 1
                    fcb       $64                 d
L0118               fcb       $2A                 *
                    fcb       $45                 E
                    fcb       $52                 R
                    fcb       $52                 R
                    fcb       $4F                 O
                    fcb       $52                 R
                    fcb       $20
                    fcb       $50                 P
                    fcb       $63                 c
                    fcb       $6F                 o
                    fcb       $64                 d
                    fcb       $65                 e
                    fcb       $20
                    fcb       $66                 f
                    fcb       $69                 i
                    fcb       $6C                 l
                    fcb       $65                 e
                    fcb       $20
                    fcb       $77                 w
                    fcb       $61                 a
                    fcb       $73                 s
                    fcb       $20
                    fcb       $70                 p
                    fcb       $72                 r
                    fcb       $6F                 o
                    fcb       $64                 d
                    fcb       $75                 u
                    fcb       $63                 c
                    fcb       $65                 e
                    fcb       $64                 d
                    fcb       $20
                    fcb       $62                 b
                    fcb       $79                 y
                    fcb       $20
                    fcb       $74                 t
                    fcb       $68                 h
                    fcb       $65                 e
                    fcb       $20
                    fcb       $77                 w
                    fcb       $72                 r
                    fcb       $6F                 o
                    fcb       $6E                 n
                    fcb       $67                 g
                    fcb       $20
                    fcb       $73                 s
                    fcb       $65                 e
                    fcb       $72                 r
                    fcb       $69                 i
                    fcb       $65                 e
                    fcb       $73                 s
                    fcb       $20
                    fcb       $6F                 o
                    fcb       $66                 f
                    fcb       $20
                    fcb       $63                 c
                    fcb       $6F                 o
                    fcb       $6D                 m
                    fcb       $70                 p
                    fcb       $69                 i
                    fcb       $6C                 l
                    fcb       $65                 e
                    fcb       $72                 r
                    fcb       $2E                 .
L0157               fcb       $2A                 *
                    fcb       $45                 E
                    fcb       $52                 R
                    fcb       $52                 R
                    fcb       $4F                 O
                    fcb       $52                 R
                    fcb       $20
                    fcb       $50                 P
                    fcb       $63                 c
                    fcb       $6F                 o
                    fcb       $64                 d
                    fcb       $65                 e
                    fcb       $20
                    fcb       $66                 f
                    fcb       $69                 i
                    fcb       $6C                 l
                    fcb       $65                 e
                    fcb       $20
                    fcb       $68                 h
                    fcb       $61                 a
                    fcb       $73                 s
                    fcb       $20
L016D               fcb       $20
                    fcb       $63                 c
                    fcb       $6F                 o
                    fcb       $6D                 m
                    fcb       $70                 p
                    fcb       $69                 i
                    fcb       $6C                 l
                    fcb       $65                 e
                    fcb       $20
                    fcb       $74                 t
                    fcb       $69                 i
                    fcb       $6D                 m
                    fcb       $65                 e
                    fcb       $20
                    fcb       $65                 e
                    fcb       $72                 r
                    fcb       $72                 r
                    fcb       $6F                 o
                    fcb       $72                 r
                    fcb       $73                 s
                    fcb       $2C                 ,
                    fcb       $20
                    fcb       $69                 i
                    fcb       $74                 t
                    fcb       $20
                    fcb       $63                 c
                    fcb       $61                 a
                    fcb       $6E                 n
                    fcb       $6E                 n
                    fcb       $6F                 o
                    fcb       $74                 t
                    fcb       $20
                    fcb       $62                 b
                    fcb       $65                 e
                    fcb       $20
                    fcb       $70                 p
                    fcb       $72                 r
                    fcb       $6F                 o
                    fcb       $63                 c
                    fcb       $65                 e
                    fcb       $73                 s
                    fcb       $73                 s
                    fcb       $65                 e
                    fcb       $64                 d
                    fcb       $2E                 .
L019A               fcb       $2A                 *
                    fcb       $45                 E
                    fcb       $52                 R
                    fcb       $52                 R
                    fcb       $4F                 O
                    fcb       $52                 R
                    fcb       $20
                    fcb       $50                 P
                    fcb       $63                 c
                    fcb       $6F                 o
                    fcb       $64                 d
                    fcb       $65                 e
                    fcb       $20
                    fcb       $66                 f
                    fcb       $69                 i
                    fcb       $6C                 l
                    fcb       $65                 e
                    fcb       $20
                    fcb       $68                 h
                    fcb       $61                 a
                    fcb       $73                 s
                    fcb       $20
                    fcb       $6E                 n
                    fcb       $6F                 o
                    fcb       $20
                    fcb       $65                 e
                    fcb       $78                 x
                    fcb       $74                 t
                    fcb       $65                 e
                    fcb       $72                 r
                    fcb       $6E                 n
                    fcb       $61                 a
                    fcb       $6C                 l
                    fcb       $20
                    fcb       $72                 r
                    fcb       $6F                 o
                    fcb       $75                 u
                    fcb       $74                 t
                    fcb       $69                 i
                    fcb       $6E                 n
                    fcb       $65                 e
                    fcb       $73                 s
                    fcb       $2E                 .
L01C5               fcb       $54                 T
                    fcb       $68                 h
                    fcb       $65                 e
                    fcb       $20
                    fcb       $66                 f
                    fcb       $6F                 o
                    fcb       $6C                 l
                    fcb       $6C                 l
                    fcb       $6F                 o
                    fcb       $77                 w
                    fcb       $69                 i
                    fcb       $6E                 n
                    fcb       $67                 g
                    fcb       $20
                    fcb       $70                 p
                    fcb       $72                 r
                    fcb       $6F                 o
                    fcb       $63                 c
                    fcb       $65                 e
                    fcb       $64                 d
                    fcb       $75                 u
                    fcb       $72                 r
                    fcb       $65                 e
                    fcb       $73                 s
                    fcb       $20
                    fcb       $77                 w
                    fcb       $65                 e
                    fcb       $72                 r
                    fcb       $65                 e
                    fcb       $20
                    fcb       $6E                 n
                    fcb       $6F                 o
                    fcb       $74                 t
                    fcb       $20
                    fcb       $75                 u
                    fcb       $70                 p
                    fcb       $64                 d
                    fcb       $61                 a
                    fcb       $74                 t
                    fcb       $65                 e
                    fcb       $64                 d
                    fcb       $3A                 :
L01EF               fcb       $50                 P
                    fcb       $52                 R
                    fcb       $4F                 O
                    fcb       $43                 C
                    fcb       $4E                 N
                    fcb       $41                 A
                    fcb       $4D                 M
                    fcb       $45                 E
                    fcb       $20
                    fcb       $20
                    fcb       $50                 P
                    fcb       $52                 R
                    fcb       $4F                 O
                    fcb       $43                 C
                    fcb       $23                 #
                    fcb       $20
                    fcb       $20
                    fcb       $4D                 M
                    fcb       $54                 T
                    fcb       $59                 Y
                    fcb       $50                 P
                    fcb       $45                 E
L0205               fcb       $2D                 -
                    fcb       $2D                 -
                    fcb       $2D                 -
                    fcb       $2D                 -
                    fcb       $2D                 -
                    fcb       $2D                 -
                    fcb       $2D                 -
                    fcb       $2D                 -
                    fcb       $20
                    fcb       $20
                    fcb       $2D                 -
                    fcb       $2D                 -
                    fcb       $2D                 -
                    fcb       $2D                 -
                    fcb       $2D                 -
                    fcb       $20
                    fcb       $20
                    fcb       $2D                 -
                    fcb       $2D                 -
                    fcb       $2D                 -
                    fcb       $2D                 -
                    fcb       $2D                 -
L021B               fcb       $53                 S
                    fcb       $55                 U
                    fcb       $50                 P
                    fcb       $50                 P
                    fcb       $4F                 O
                    fcb       $52                 R
                    fcb       $D4                 T
start               equ       *
                    sty       <u0000
                    stx       <u004E
                    leax      -$01,y
                    stx       <u0050
                    stu       <u0002
                    leax      >L0758,pcr
                    stx       <u0008
                    leax      >L0768,pcr
                    stx       <u001A
                    leax      <L021B,pcr
                    lda       #$21
                    os9       F$Link
                    bcc       L024F
                    cmpb      #$DD
                    bne       L024C
                    os9       F$Load
                    bcc       L024F
L024C               os9       F$Exit
L024F               sty       <u0004
                    stu       <u0006
                    clra
                    clrb
                    stb       <u002E
                    stb       <u0040
                    std       <u0016
                    stb       <u0022
                    ldd       #$01F4
                    std       <u0046
                    ldx       <u0004
                    jsr       <-$1E,x
                    ldd       <u0002
                    addd      #$01DF
                    std       <u0018
                    ldd       #$0093
                    std       <u0044
                    ldd       #$0BB8
                    std       <u0042
                    clra
                    clrb
                    std       <u0048
                    ldx       <u0004
                    jsr       <-$39,x
                    leax      >-$01A3,s
                    pshs      x
                    ldd       #$0014
                    ldx       <u0004
                    jsr       <-$2A,x
                    ldd       #$0100
                    std       >-u019B,u
                    clr       >-u0190,u
                    ldd       #$0000
                    std       >-u0195,u
                    ldd       #$0000
                    std       -$06,y
L02A7               ldd       $06,y
                    addd      -$06,y
                    pshs      b,a
                    ldb       [,s++]
                    subb      #$20
                    beq       L02B7
                    ldb       #$01
                    bra       L02B8
L02B7               clrb
L02B8               pshs      b
                    ldd       -$06,y
                    subd      #$004F
                    bge       L02C5
                    ldb       #$01
                    bra       L02C6
L02C5               clrb
L02C6               andb      ,s+
                    lsrb
                    lbcc      L02D7
                    ldd       -$06,y
                    addd      #$0001
                    std       -$06,y
                    lbra      L02A7
L02D7               ldd       -$06,y
                    subd      #$0000
                    lbne      L0325
                    leax      >L0015,pcr
                    pshs      x
                    ldd       #$003D
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       $02,y
                    pshs      b,a
                    ldx       ,s
                    clr       $0D,x
                    ldx       <u0004
                    jsr       -$09,x
                    leax      >L0052,pcr
                    pshs      x
                    ldd       #$0041
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       $02,y
                    pshs      b,a
                    ldx       ,s
                    clr       $0D,x
                    ldx       <u0004
                    jsr       -$09,x
                    lbra      L074D
L0325               ldd       -$06,y
                    subd      #$004F
                    bne       L0330
                    ldb       #$01
                    bra       L0331
L0330               clrb
L0331               pshs      b
                    ldd       $06,y
                    addd      -$06,y
                    pshs      b,a
                    ldb       [,s++]
                    subb      #$20
                    beq       L0343
                    ldb       #$01
                    bra       L0344
L0343               clrb
L0344               andb      ,s+
                    lsrb
                    lbcc      L0353
                    ldd       #$0050
                    std       -$04,y
                    lbra      L0357
L0353               ldd       -$06,y
                    std       -$04,y
L0357               leax      >-$019F,y
                    pshs      x
                    ldb       #$00
                    pshs      b
                    ldx       <u0004
                    jsr       <-$18,x
                    leax      >-$019F,y
                    pshs      x
                    ldd       $06,y
                    pshs      b,a
                    leax      >L0093,pcr
                    pshs      x
                    ldx       <u0004
                    jsr       <-$54,x
                    leas      -$02,s
                    leax      >-$019F,y
                    pshs      x
                    ldx       <u0004
                    jsr       <-$12,x
                    puls      b,a
                    std       -$06,y
                    leax      >-$019F,y
                    pshs      x
                    ldb       #$01
                    pshs      b
                    ldx       <u0004
                    jsr       <-$18,x
                    ldd       -$06,y
                    subd      #$0000
                    lbeq      L0403
                    leax      >L009C,pcr
                    pshs      x
                    ldd       #$0012
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       -$06,y
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       ,x
                    leax      >L00AE,pcr
                    pshs      x
                    ldd       #$0026
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       $06,y
                    pshs      b,a
                    ldd       -$04,y
                    pshs      b,a
                    ldd       #$0050
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       $02,y
                    pshs      b,a
                    ldx       ,s
                    clr       $0D,x
                    ldx       <u0004
                    jsr       -$09,x
                    lbra      L074D
L0403               leax      >-$019F,y
                    pshs      x
                    ldd       #$0000
                    pshs      b,a
                    leax      >L00D4,pcr
                    pshs      x
                    ldx       <u0004
                    jsr       <-$21,x
                    leax      >-$019F,y
                    pshs      x
                    ldd       #$0000
                    pshs      b,a
                    ldx       <u0004
                    jsr       <$12,x
                    ldx       <u0004
                    jsr       <-$24,x
                    leax      >-$019F,y
                    pshs      x
                    ldx       <u0004
                    jsr       -$06,x
                    ldd       #$0000
                    std       -$02,y
                    ldd       #$0000
                    std       -$06,y
                    ldd       #$00FF
                    std       >-$01A1,y
                    ldd       -$06,y
                    subd      >-$01A1,y
                    lbgt      L0481
L0453               ldd       -$02,y
                    pshs      b,a
                    leax      >-$018F,y
                    ldd       -$06,y
                    ldb       d,x
                    clra
                    addd      ,s++
                    pshs      b,a
                    ldd       #$00FF
                    anda      ,s+
                    andb      ,s+
                    std       -$02,y
                    ldd       -$06,y
                    subd      >-$01A1,y
                    lbge      L0481
                    ldd       -$06,y
                    addd      #$0001
                    std       -$06,y
                    lbra      L0453
L0481               ldd       -$02,y
                    subd      #$0000
                    lbeq      L04AE
                    leax      >L00DD,pcr
                    pshs      x
                    ldd       #$0039
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       $02,y
                    pshs      b,a
                    ldx       ,s
                    clr       $0D,x
                    ldx       <u0004
                    jsr       -$09,x
                    lbra      L074D
L04AE               leax      >-$0173,y
                    pshs      x
                    leax      >L0116,pcr
                    ldd       ,x
                    subd      [,s++]
                    lbeq      L04E4
                    leax      >L0118,pcr
                    pshs      x
                    ldd       #$003F
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       $02,y
                    pshs      b,a
                    ldx       ,s
                    clr       $0D,x
                    ldx       <u0004
                    jsr       -$09,x
                    lbra      L074D
L04E4               ldd       >-$016B,y
                    subd      #$0000
                    lbeq      L053B
                    leax      >L0157,pcr
                    pshs      x
                    ldd       #$0016
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       >-$016B,y
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       ,x
                    leax      >L016D,pcr
                    pshs      x
                    ldd       #$002D
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       $02,y
                    pshs      b,a
                    ldx       ,s
                    clr       $0D,x
                    ldx       <u0004
                    jsr       -$09,x
                    lbra      L074D
L053B               ldd       >-$015F,y
                    subd      #$0000
                    lbne      L056A
                    leax      >L019A,pcr
                    pshs      x
                    ldd       #$002B
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       $02,y
                    pshs      b,a
                    ldx       ,s
                    clr       $0D,x
                    ldx       <u0004
                    jsr       -$09,x
                    lbra      L074D
L056A               ldd       #$0000
                    std       -$0A,y
                    ldd       >-$016F,y
                    std       -$0C,y
                    ldd       >-$0161,y
                    std       -$0E,y
                    ldd       #$0000
                    std       -$06,y
                    ldd       >-$015F,y
                    subd      #$0001
                    std       >-$01A1,y
                    ldd       -$06,y
                    subd      >-$01A1,y
                    lbgt      L065F
L0595               leax      >-$019F,y
                    pshs      x
                    ldd       -$0E,y
                    pshs      b,a
                    ldd       -$06,y
                    pshs      b,a
                    ldd       #$0002
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$0C,x
                    puls      b,a
                    addd      ,s++
                    pshs      b,a
                    ldx       <u0004
                    jsr       <$12,x
                    ldx       <u0004
                    jsr       <-$24,x
                    leax      >-$019F,y
                    pshs      x
                    ldx       <u0004
                    jsr       -$06,x
                    leax      -$08,y
                    pshs      x
                    ldd       #$000D
                    pshs      b,a
                    ldx       <u0004
                    jsr       <-$4B,x
                    leax      >-$018F,y
                    pshs      x
                    ldd       -$06,y
                    pshs      b,a
                    ldd       #$0001
                    anda      ,s+
                    andb      ,s+
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    addd      ,s++
                    std       >-u01A3,u
                    ldd       -$08,y
                    pshs      b,a
                    ldd       >-$01A3,y
                    addd      #$0004
                    pshs      b,a
                    sty       <u000E
                    stu       <u0010
                    puls      u,y
                    ldx       #$0008
L0610               ldd       ,y++
                    std       ,u++
                    leax      -$02,x
                    bne       L0610
                    ldu       <u0010
                    ldy       <u000E
                    ldd       -$08,y
                    addd      #$0008
                    pshs      b,a
                    ldx       >-$01A3,y
                    ldb       $02,x
                    stb       [,s++]
                    ldd       -$08,y
                    addd      #$0009
                    pshs      b,a
                    ldx       >-$01A3,y
                    ldb       $03,x
                    stb       [,s++]
                    ldx       -$08,y
                    ldb       #$01
                    stb       $0A,x
                    ldx       -$08,y
                    ldd       -$0A,y
                    std       $0B,x
                    ldd       -$08,y
                    std       -$0A,y
                    ldd       -$06,y
                    subd      >-$01A1,y
                    lbge      L065F
                    ldd       -$06,y
                    addd      #$0001
                    std       -$06,y
                    lbra      L0595
L065F               clr       -$0F,y
                    ldd       ,y
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      u
                    lbsr      L0E40
                    ldb       -$0F,y
                    eorb      #$01
                    lsrb
                    lbcc      L074D
                    leax      >L01C5,pcr
                    pshs      x
                    ldd       #$002A
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       $02,y
                    pshs      b,a
                    ldx       ,s
                    clr       $0D,x
                    ldx       <u0004
                    jsr       -$09,x
                    ldd       $02,y
                    pshs      b,a
                    ldx       ,s
                    clr       $0D,x
                    ldx       <u0004
                    jsr       -$09,x
                    leax      >L01EF,pcr
                    pshs      x
                    ldd       #$0016
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       $02,y
                    pshs      b,a
                    ldx       ,s
                    clr       $0D,x
                    ldx       <u0004
                    jsr       -$09,x
                    leax      >L0205,pcr
                    pshs      x
                    ldd       #$0016
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       $02,y
                    pshs      b,a
                    ldx       ,s
                    clr       $0D,x
                    ldx       <u0004
                    jsr       -$09,x
                    ldd       -$0A,y
                    std       -$08,y
L06EB               ldd       -$08,y
                    subd      #$0000
                    lbeq      L074D
                    ldx       -$08,y
                    ldb       $0A,x
                    lsrb
                    lbcc      L0744
                    ldd       -$08,y
                    pshs      b,a
                    ldd       #$0008
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldx       -$08,y
                    ldb       $09,x
                    clra
                    pshs      b,a
                    ldd       #$0007
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       ,x
                    ldx       -$08,y
                    ldb       $08,x
                    clra
                    pshs      b,a
                    ldd       #$0007
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       ,x
                    ldd       $02,y
                    pshs      b,a
                    ldx       ,s
                    clr       $0D,x
                    ldx       <u0004
                    jsr       -$09,x
L0744               ldx       -$08,y
                    ldd       $0B,x
                    std       -$08,y
                    lbra      L06EB
L074D               leax      >-u019F,u
                    pshs      x
                    ldx       <u0004
                    jsr       <-$3F,x
L0758               ldx       <u0004
                    jsr       <-$36,x
                    ldu       <u0006
                    os9       F$UnLink
                    bcs       L0765
                    clrb
L0765               os9       F$Exit
L0768               ldd       #$0076
                    ldx       <u0004
                    jsr       <-$3C,x
L0770               lda       <u0020
                    ldb       #$01
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    leax      -$02,s
                    pshs      x
                    ldd       #$0029
                    ldx       <u0004
                    jsr       <-$2A,x
                    leax      >-$008F,y
                    ldd       [<u000B,u]
                    ldb       d,x
                    subb      #$2C
                    lbeq      L079A
                    lbra      L0882
L079A               ldd       u000B,u
                    pshs      b,a
                    pshs      b,a
                    ldd       [,s++]
                    addd      #$0001
                    std       [,s++]
                    ldd       [<u000B,u]
                    subd      u0009,u
                    lbne      L07B3
                    lbra      L0882
L07B3               ldd       #$0000
                    std       [<u0007,u]
                    leax      >-$008F,y
                    ldd       [<u000B,u]
                    ldb       d,x
                    clra
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      b,a
                    pshs      b,a
                    ldd       #$03FF
                    pshs      b,a
                    ldb       #$18
L07D5               clr       ,-s
                    decb
                    bne       L07D5
                    lbsr      L1270
                    eorb      #$01
                    lsrb
                    lbcc      L07E7
                    lbra      L0882
L07E7               leax      >-$008F,y
                    ldd       [<u000B,u]
                    ldb       d,x
                    clra
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      b,a
                    pshs      b,a
                    ldd       #$03FF
                    pshs      b,a
                    ldb       #$18
L0803               clr       ,-s
                    decb
                    bne       L0803
                    lbsr      L1270
                    pshs      b
                    ldd       [<u000B,u]
                    subd      u0009,u
                    bge       L0818
                    ldb       #$01
                    bra       L0819
L0818               clrb
L0819               andb      ,s+
                    lsrb
                    lbcc      L087D
                    leax      >-$008F,y
                    ldd       [<u000B,u]
                    ldb       d,x
                    clra
                    subd      #$0030
                    std       -u0002,u
                    ldd       [<u0007,u]
                    subd      #$0CCC
                    bne       L083B
                    ldb       #$01
                    bra       L083C
L083B               clrb
L083C               pshs      b
                    ldd       -u0002,u
                    subd      #$0007
                    ble       L0849
                    ldb       #$01
                    bra       L084A
L0849               clrb
L084A               andb      ,s+
                    lsrb
                    lbcc      L0854
                    lbra      L0882
L0854               ldd       u0007,u
                    pshs      b,a
                    pshs      b,a
                    ldd       [,s++]
                    pshs      b,a
                    ldd       #$000A
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$0F,x
                    ldd       -u0002,u
                    addd      ,s++
                    std       [,s++]
                    ldd       u000B,u
                    pshs      b,a
                    pshs      b,a
                    ldd       [,s++]
                    addd      #$0001
                    std       [,s++]
                    lbra      L07E7
L087D               clr       u000D,u
                    lbra      L0886
L0882               ldb       #$01
                    stb       u000D,u
L0886               leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $08,s
                    jmp       ,x
L0892               bpl       L08D9
                    fcb       $52                 R
                    fcb       $52                 R
                    clra
                    fcb       $52                 R
                    bra       L08E3
                    jmp       -$0A,s
                    oim       #$6C,$09,s
                    lsr       $00,y
                    fcb       $45                 E
                    lslb
                    lsrb
                    fcb       $45                 E
                    fcb       $52                 R
                    fcb       $4E                 N
                    fcb       $41                 A
                    inca
                    bra       L090F
                    eim       #$66,$09,s
                    jmp       $09,s
                    lsr       >$696F
                    jmp       $00,y
                    ror       $0F,s
                    aim       #$6D,>$6174
                    bra       L092C
                    jmp       $00,y
                    inc       $09,s
                    jmp       $05,s
                    bra       L0933
                    eim       #$6D,>$6265
                    aim       #$20,>$2061
                    lsr       >$2055
                    comb
                    fcb       $45                 E
                    bra       L093A
                    rol       $0C,s
                    eim       #$20,$0E,s
L08D9               eim       #$73,-$0C,s
                    rol       $0E,s
                    asr       $00,y
                    inc       $05,s
                    ror       >$656C
                    bra       L0956
                    ror       $00,y
L08E9               lda       <u0020
                    ldb       #$02
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    leax      >-$008E,s
                    pshs      x
                    ldd       #$0029
                    ldx       <u0004
                    jsr       <-$2A,x
                    ldd       #$0000
                    std       -u0006,u
L0908               leax      >-$008F,y
                    ldd       -u0006,u
                    ldb       d,x
                    clra
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      b,a
                    pshs      b,a
                    ldd       #$03FF
                    pshs      b,a
                    ldd       #$FFFE
                    pshs      b,a
                    ldd       #$87FF
                    pshs      b,a
                    ldb       #$14
L092D               clr       ,-s
                    decb
                    bne       L092D
                    lbsr      L1270
                    pshs      b
                    ldd       -u0006,u
                    subd      #$0008
                    bge       L0942
                    ldb       #$01
                    bra       L0943
L0942               clrb
L0943               andb      ,s+
                    pshs      b
                    ldd       -u0006,u
                    subd      u000B,u
                    bge       L0951
                    ldb       #$01
                    bra       L0952
L0951               clrb
L0952               andb      ,s+
                    lsrb
                    lbcc      L0976
                    leax      <-u0018,u
                    ldd       -u0006,u
                    leax      d,x
                    pshs      x
                    leax      >-$008F,y
                    ldd       -u0006,u
                    ldb       d,x
                    stb       [,s++]
                    ldd       -u0006,u
                    addd      #$0001
                    std       -u0006,u
                    lbra      L0908
L0976               ldd       -u0006,u
                    subd      u000B,u
                    lbne      L0981
                    lbra      L0CF5
L0981               ldd       -u0006,u
                    std       -u0004,u
                    ldd       #$0007
                    std       >-u008E,u
                    ldd       -u0004,u
                    subd      >-u008E,u
                    lbgt      L09B5
L0996               leax      <-u0018,u
                    ldd       -u0004,u
                    leax      d,x
                    ldb       #$20
                    stb       ,x
                    ldd       -u0004,u
                    subd      >-u008E,u
                    lbge      L09B5
                    ldd       -u0004,u
                    addd      #$0001
                    std       -u0004,u
                    lbra      L0996
L09B5               leax      >-$008F,y
                    ldd       -u0006,u
                    ldb       d,x
                    subb      #$2C
                    lbeq      L09C6
                    lbra      L0CF5
L09C6               ldd       -u0006,u
                    addd      #$0001
                    std       -u0006,u
                    ldd       #$0000
                    std       -u0004,u
L09D2               leax      >-$008F,y
                    ldd       -u0006,u
                    ldb       d,x
                    clra
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      b,a
                    ldd       #$C000
                    pshs      b,a
                    ldd       #$03FF
                    pshs      b,a
                    ldd       #$FFFE
                    pshs      b,a
                    ldd       #$87FF
                    pshs      b,a
                    ldb       #$14
L09FA               clr       ,-s
                    decb
                    bne       L09FA
                    lbsr      L1270
                    pshs      b
                    ldd       -u0006,u
                    subd      u000B,u
                    bge       L0A0E
                    ldb       #$01
                    bra       L0A0F
L0A0E               clrb
L0A0F               andb      ,s+
                    pshs      b
                    ldd       -u0004,u
                    subd      #$0074
                    bge       L0A1E
                    ldb       #$01
                    bra       L0A1F
L0A1E               clrb
L0A1F               andb      ,s+
                    lsrb
                    lbcc      L0A4B
                    leax      >-u008C,u
                    ldd       -u0004,u
                    leax      d,x
                    pshs      x
                    leax      >-$008F,y
                    ldd       -u0006,u
                    ldb       d,x
                    stb       [,s++]
                    ldd       -u0006,u
                    addd      #$0001
                    std       -u0006,u
                    ldd       -u0004,u
                    addd      #$0001
                    std       -u0004,u
                    lbra      L09D2
L0A4B               ldd       -u0006,u
                    subd      u000B,u
                    bne       L0A55
                    ldb       #$01
                    bra       L0A56
L0A55               clrb
L0A56               pshs      b
                    ldd       -u0004,u
                    subd      #$0000
                    bne       L0A63
                    ldb       #$01
                    bra       L0A64
L0A63               clrb
L0A64               orb       ,s+
                    lsrb
                    lbcc      L0A6E
                    lbra      L0CF5
L0A6E               ldd       -u0004,u
                    std       -u0002,u
                    ldd       #$0073
                    std       >-u008E,u
                    ldd       -u0002,u
                    subd      >-u008E,u
                    lbgt      L0AA3
L0A83               leax      >-u008C,u
                    ldd       -u0002,u
                    leax      d,x
                    ldb       #$20
                    stb       ,x
                    ldd       -u0002,u
                    subd      >-u008E,u
                    lbge      L0AA3
                    ldd       -u0002,u
                    addd      #$0001
                    std       -u0002,u
                    lbra      L0A83
L0AA3               leas      -$01,s
                    leax      -u0006,u
                    pshs      x
                    ldd       u000B,u
                    pshs      b,a
                    leax      -u0002,u
                    pshs      x
                    ldx       u0005,u
                    pshs      x
                    lbsr      L0770
                    lsr       ,s+
                    lbcc      L0AC1
                    lbra      L0CF5
L0AC1               ldd       -u0002,u
                    subd      #$00FF
                    lble      L0ACD
                    lbra      L0CF5
L0ACD               ldd       -u0002,u
                    stb       -u000F,u
                    leas      -$01,s
                    leax      -u0006,u
                    pshs      x
                    ldd       u000B,u
                    pshs      b,a
                    leax      -u000E,u
                    pshs      x
                    ldx       u0005,u
                    pshs      x
                    lbsr      L0770
                    lsr       ,s+
                    lbcc      L0AEF
                    lbra      L0CF5
L0AEF               leas      -$01,s
                    leax      -u0006,u
                    pshs      x
                    ldd       u000B,u
                    pshs      b,a
                    leax      -u000C,u
                    pshs      x
                    ldx       u0005,u
                    pshs      x
                    lbsr      L0770
                    lsr       ,s+
                    lbcc      L0B0D
                    lbra      L0CF5
L0B0D               leas      -$01,s
                    leax      -u0006,u
                    pshs      x
                    ldd       u000B,u
                    pshs      b,a
                    leax      -u000A,u
                    pshs      x
                    ldx       u0005,u
                    pshs      x
                    lbsr      L0770
                    lsr       ,s+
                    lbcc      L0B2B
                    lbra      L0CF5
L0B2B               clr       -u0010,u
                    ldd       -$0A,y
                    std       -u0008,u
L0B31               ldd       -u0008,u
                    subd      #$0000
                    lbeq      L0CEC
                    ldx       -u0008,u
                    ldb       $0A,x
                    lsrb
                    lbcc      L0CE3
                    ldd       -u0008,u
                    pshs      b,a
                    leax      <-u0018,u
                    pshs      x
                    sty       <u000E
                    stu       <u0010
                    puls      u,y
                    ldx       #$0008
L0B56               ldd       ,u++
                    subd      ,y++
                    bne       L0B64
                    leax      -$02,x
                    bne       L0B56
                    ldb       #$01
                    bra       L0B65
L0B64               clrb
L0B65               ldu       <u0010
                    ldy       <u000E
                    lsrb
                    lbcc      L0CDF
                    leax      >-$019F,y
                    pshs      x
                    ldd       -$0C,y
                    pshs      b,a
                    ldx       -u0008,u
                    ldb       $09,x
                    clra
                    pshs      b,a
                    ldd       #$0008
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$0C,x
                    puls      b,a
                    addd      ,s++
                    pshs      b,a
                    ldx       <u0004
                    jsr       <$12,x
                    ldx       <u0004
                    jsr       <-$24,x
                    leax      >-$019F,y
                    pshs      x
                    ldx       <u0004
                    jsr       -$06,x
                    leax      >-$018F,y
                    pshs      x
                    ldx       -u0008,u
                    ldb       $09,x
                    clra
                    pshs      b,a
                    ldd       #$0007
                    anda      ,s+
                    andb      ,s+
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    addd      ,s++
                    std       >-u008E,u
                    addd      #$0002
                    pshs      b,a
                    ldd       -u000C,u
                    std       [,s++]
                    ldx       >-u008E,u
                    ldd       -u000A,u
                    std       $04,x
                    ldx       >-u008E,u
                    ldd       $0E,x
                    subd      #$0001
                    std       -u0006,u
                    leax      >-$019F,y
                    pshs      x
                    ldd       -$0C,y
                    pshs      b,a
                    ldx       -u0008,u
                    ldb       $09,x
                    clra
                    pshs      b,a
                    ldd       #$0008
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$0C,x
                    puls      b,a
                    addd      ,s++
                    pshs      b,a
                    ldx       <u0004
                    jsr       <$12,x
                    ldx       <u0004
                    jsr       <-$24,x
                    leax      >-$019F,y
                    pshs      x
                    ldx       <u0004
                    jsr       -$09,x
                    leax      >-$019F,y
                    pshs      x
                    ldd       -$0E,y
                    pshs      b,a
                    ldd       -u0006,u
                    pshs      b,a
                    ldd       #$0002
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$0C,x
                    puls      b,a
                    addd      ,s++
                    pshs      b,a
                    ldx       <u0004
                    jsr       <$12,x
                    ldx       <u0004
                    jsr       <-$24,x
                    leax      >-$019F,y
                    pshs      x
                    ldx       <u0004
                    jsr       -$06,x
                    leax      >-$018F,y
                    pshs      x
                    ldd       -u0006,u
                    pshs      b,a
                    ldd       #$0001
                    anda      ,s+
                    andb      ,s+
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    addd      ,s++
                    std       >-u008E,u
                    addd      #$0002
                    pshs      b,a
                    ldb       -u000F,u
                    stb       [,s++]
                    ldd       -u000E,u
                    std       [>-u008E,u]
                    ldd       >-u008E,u
                    addd      #$000C
                    pshs      b,a
                    leax      >-u008C,u
                    pshs      x
                    sty       <u000E
                    stu       <u0010
                    puls      u,y
                    ldx       #$0074
L0C95               ldd       ,y++
                    std       ,u++
                    leax      -$02,x
                    bne       L0C95
                    ldu       <u0010
                    ldy       <u000E
                    leax      >-$019F,y
                    pshs      x
                    ldd       -$0E,y
                    pshs      b,a
                    ldd       -u0006,u
                    pshs      b,a
                    ldd       #$0002
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$0C,x
                    puls      b,a
                    addd      ,s++
                    pshs      b,a
                    ldx       <u0004
                    jsr       <$12,x
                    ldx       <u0004
                    jsr       <-$24,x
                    leax      >-$019F,y
                    pshs      x
                    ldx       <u0004
                    jsr       -$09,x
                    ldd       -u0008,u
                    addd      #$000A
                    pshs      b,a
                    clr       [,s++]
                    lbra      L0CE3
L0CDF               ldb       #$01
                    stb       -u0010,u
L0CE3               ldx       -u0008,u
                    ldd       $0B,x
                    std       -u0008,u
                    lbra      L0B31
L0CEC               ldb       -u0010,u
                    eorb      #$01
                    stb       -$0F,y
                    lbra      L0D4D
L0CF5               leax      >L0892,pcr
                    pshs      x
                    ldd       #$0039
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       u0009,u
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       ,x
                    leax      >L08CB,pcr
                    pshs      x
                    ldd       #$001E
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       u0007,u
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       ,x
                    ldd       $02,y
                    pshs      b,a
                    ldx       ,s
                    clr       $0D,x
                    ldx       <u0004
                    jsr       -$09,x
L0D4D               leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $08,s
                    jmp       ,x
L0D59               fcb       $55                 U
                    comb
                    fcb       $45                 E
                    bra       L0DB7
                    bra       L0D80
                    bra       L0D82
                    bra       L0D84
                    bra       L0D86
L0D66               bpl       L0DBF
                    fcb       $41                 A
                    fcb       $52                 R
                    fcb       $4E                 N
                    rola
                    fcb       $4E                 N
                    asra
                    bra       L0DBF
                    comb
                    blt       L0DAC
                    bra       L0DBA
                    aim       #$72,>$6F72
                    bra       L0D9B
                    eim       #$6E,$03,s
                    clr       -$0B,s
L0D80               jmp       -$0C,s
L0D82               eim       #$72,$05,s
                    lsr       $00,y
                    asr       >$6869
                    inc       $05,s
                    bra       L0E02
                    aim       #$79,>$696E
                    asr       $00,y
                    lsr       >$6F20
                    clr       -$10,s
                    eim       #$6E,$00,y
                    fcb       $55                 U
                    comb
                    fcb       $45                 E
                    bra       L0E07
                    rol       $0C,s
                    eim       #$20,$0A,y
                    fcb       $45                 E
                    fcb       $52                 R
                    fcb       $52                 R
                    clra
                    fcb       $52                 R
                    bra       L0DF6
                    jmp       -$0A,s
                    oim       #$6C,$09,s
                    lsr       $00,y
                    com       $0F,s
                    tst       $0D,s
                    oim       #$6E,$04,s
                    bra       L0E2C
                    jmp       $00,y
L0DBF               inc       $09,s
                    jmp       $05,s
                    bra       L0E33
                    eim       #$6D,>$6265
                    aim       #$20,>$2061
                    lsr       >$2055
                    comb
                    fcb       $45                 E
                    bra       L0E3A
                    rol       $0C,s
                    eim       #$20,$0E,s
                    eim       #$73,-$0C,s
                    rol       $0E,s
                    asr       $00,y
                    inc       $05,s
                    ror       >$656C
                    bra       L0E56
                    ror       $00,y
L0DE9               bpl       L0E30
                    fcb       $52                 R
                    fcb       $52                 R
                    clra
                    fcb       $52                 R
                    bra       L0E3A
                    jmp       -$0A,s
                    oim       #$6C,$09,s
L0DF6               lsr       $00,y
                    fcb       $45                 E
                    lslb
                    lsrb
                    fcb       $45                 E
                    fcb       $52                 R
                    fcb       $4E                 N
                    fcb       $41                 A
                    inca
                    bra       L0E66
L0E02               eim       #$66,$09,s
                    jmp       $09,s
L0E07               lsr       >$696F
                    jmp       $00,y
                    ror       $0F,s
                    aim       #$6D,>$6174
                    bra       L0E83
                    jmp       $00,y
                    inc       $09,s
                    jmp       $05,s
                    bra       L0E8A
                    eim       #$6D,>$6265
                    aim       #$20,>$2061
                    lsr       >$2055
                    comb
                    fcb       $45                 E
                    bra       L0E91
                    rol       $0C,s
                    eim       #$20,$0E,s
L0E30               eim       #$73,-$0C,s
L0E33               rol       $0E,s
                    asr       $00,y
                    inc       $05,s
                    ror       >$656C
                    bra       L0EAD
                    ror       $00,y
L0E40               lda       <u0020
                    ldb       #$03
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    leax      >-$009B,s
                    pshs      x
                    ldd       #$002D
                    ldx       <u0004
                    jsr       <-$2A,x
                    ldd       #$0080
                    std       >-u0095,u
                    clr       >-u008A,u
                    ldd       #$0012
                    std       >-u008F,u
                    leas      -$01,s
                    ldd       u0009,u
                    pshs      b,a
                    ldx       <u0004
                    jsr       <-$15,x
                    lsr       ,s+
                    lbcc      L0E85
                    ldd       u0009,u
                    pshs      b,a
                    ldx       <u0004
L0E83               jsr       $06,x
L0E85               ldd       #$0000
                    std       -u0006,u
L0E8A               ldx       u0009,u
                    ldb       $0B,x
                    andb      #$01
                    eorb      #$01
                    lsrb
                    lbcc      L1259
                    ldd       #$0000
                    std       -u0008,u
L0E9C               ldx       u0009,u
                    ldb       $0B,x
                    andb      #$02
                    lsrb
                    eorb      #$01
                    pshs      b
                    ldd       -u0008,u
                    subd      #$0080
                    bge       L0EB2
                    ldb       #$01
                    bra       L0EB3
L0EB2               clrb
L0EB3               andb      ,s+
                    lsrb
                    lbcc      L0F29
                    ldd       u0009,u
                    std       >-u009B,u
                    leax      >-$008F,y
                    ldd       -u0008,u
                    leax      d,x
                    pshs      x
                    ldd       >-u009B,u
                    pshs      b,a
                    ldx       <u0004
                    jsr       $0C,x
                    leax      >-$008F,y
                    ldd       -u0008,u
                    ldb       d,x
                    clra
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      b,a
                    pshs      b,a
                    pshs      b,a
                    pshs      b,a
                    pshs      b,a
                    ldd       #$FFFE
                    pshs      b,a
                    ldd       #$07FF
                    pshs      b,a
                    ldb       #$10
L0EFA               clr       ,-s
                    decb
                    bne       L0EFA
                    lbsr      L1270
                    lsrb
                    lbcc      L0F1F
                    leax      >-$008F,y
                    ldd       -u0008,u
                    leax      d,x
                    pshs      x
                    leax      >-$008F,y
                    ldd       -u0008,u
                    ldb       d,x
                    clra
                    subd      #$0020
                    stb       [,s++]
L0F1F               ldd       -u0008,u
                    addd      #$0001
                    std       -u0008,u
                    lbra      L0E9C
L0F29               ldd       -u0008,u
                    subd      #$0080
                    bne       L0F34
                    ldb       #$01
                    bra       L0F35
L0F34               clrb
L0F35               pshs      b
                    ldx       u0009,u
                    ldb       $0B,x
                    andb      #$02
                    lsrb
                    eorb      #$01
                    andb      ,s+
                    lsrb
                    lbcc      L0F53
                    ldd       u0009,u
                    std       >-u009B,u
                    pshs      b,a
                    ldx       <u0004
                    jsr       $09,x
L0F53               ldd       -u0006,u
                    addd      #$0001
                    std       -u0006,u
                    ldd       -u0008,u
                    subd      #$0000
                    lbeq      L1241
                    ldb       >-$008F,y
                    subb      #$2A
                    lbeq      L1241
                    ldb       >-$008F,y
                    subb      #$20
                    lbne      L119E
                    leax      >-$008E,y
                    pshs      x
                    leax      >L0D59,pcr
                    pshs      x
                    sty       <u000E
                    stu       <u0010
                    puls      u,y
                    ldx       #$0004
L0F8D               ldd       ,u++
                    subd      ,y++
                    bne       L0F9B
                    leax      -$02,x
                    bne       L0F8D
                    ldb       #$01
                    bra       L0F9C
L0F9B               clrb
L0F9C               ldu       <u0010
                    ldy       <u000E
                    pshs      b
                    ldd       -u0008,u
                    subd      #$0006
                    blt       L0FAE
                    ldb       #$01
                    bra       L0FAF
L0FAE               clrb
L0FAF               andb      ,s+
                    lsrb
                    lbcc      L1143
                    ldd       #$0005
                    std       -u0004,u
                    ldd       #$0000
                    std       -u0002,u
L0FC0               leax      >-$008F,y
                    ldd       -u0004,u
                    ldb       d,x
                    subb      #$20
                    bne       L0FD0
                    ldb       #$01
                    bra       L0FD1
L0FD0               clrb
L0FD1               pshs      b
                    ldd       -u0004,u
                    subd      -u0008,u
                    bge       L0FDD
                    ldb       #$01
                    bra       L0FDE
L0FDD               clrb
L0FDE               andb      ,s+
                    lsrb
                    lbcc      L0FEF
                    ldd       -u0004,u
                    addd      #$0001
                    std       -u0004,u
                    lbra      L0FC0
L0FEF               leax      >-$008F,y
                    ldd       -u0004,u
                    ldb       d,x
                    subb      #$20
                    beq       L0FFF
                    ldb       #$01
                    bra       L1000
L0FFF               clrb
L1000               pshs      b
                    ldd       -u0004,u
                    subd      -u0008,u
                    bge       L100C
                    ldb       #$01
                    bra       L100D
L100C               clrb
L100D               andb      ,s+
                    lsrb
                    lbcc      L1039
                    leax      >-$008F,y
                    ldd       -u0002,u
                    leax      d,x
                    pshs      x
                    leax      >-$008F,y
                    ldd       -u0004,u
                    ldb       d,x
                    stb       [,s++]
                    ldd       -u0004,u
                    addd      #$0001
                    std       -u0004,u
                    ldd       -u0002,u
                    addd      #$0001
                    std       -u0002,u
                    lbra      L0FEF
L1039               leax      >-$008F,y
                    ldd       -u0002,u
                    leax      d,x
                    ldb       #$20
                    stb       ,x
                    leax      >-u0099,u
                    pshs      x
                    ldb       #$00
                    pshs      b
                    ldx       <u0004
                    jsr       <-$18,x
                    leax      >-u0099,u
                    pshs      x
                    leax      >-$008F,y
                    pshs      x
                    leax      >L0D5D,pcr
                    pshs      x
                    ldx       <u0004
                    jsr       <-$54,x
                    leas      -$02,s
                    leax      >-u0099,u
                    pshs      x
                    ldx       <u0004
                    jsr       <-$12,x
                    puls      b,a
                    std       -u0004,u
                    leax      >-u0099,u
                    pshs      x
                    ldb       #$01
                    pshs      b
                    ldx       <u0004
                    jsr       <-$18,x
                    ldd       -u0004,u
                    subd      #$0000
                    lbeq      L1122
                    leax      >L0D66,pcr
                    pshs      x
                    ldd       #$0014
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       -u0004,u
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       ,x
                    leax      >L0D7A,pcr
                    pshs      x
                    ldd       #$002B
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       #$0000
                    std       -u0004,u
                    ldd       -u0002,u
                    subd      #$0001
                    std       >-u009B,u
                    ldd       -u0004,u
                    subd      >-u009B,u
                    lbgt      L1113
L10E7               leax      >-$008F,y
                    ldd       -u0004,u
                    ldb       d,x
                    pshs      b
                    ldd       #$0001
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       <-$27,x
                    ldd       -u0004,u
                    subd      >-u009B,u
                    lbge      L1113
                    ldd       -u0004,u
                    addd      #$0001
                    std       -u0004,u
                    lbra      L10E7
L1113               ldd       $02,y
                    pshs      b,a
                    ldx       ,s
                    clr       $0D,x
                    ldx       <u0004
                    jsr       -$09,x
                    lbra      L1136
L1122               leax      >-u0099,u
                    pshs      x
                    ldd       u0007,u
                    addd      #$0001
                    pshs      b,a
                    ldx       u0005,u
                    pshs      x
                    lbsr      L0E40
L1136               ldb       -$0F,y
                    lsrb
                    lbcc      L1140
                    lbra      L1259
L1140               lbra      L119B
L1143               leax      >L0DA5,pcr
                    pshs      x
                    ldd       #$0026
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       -u0006,u
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       ,x
                    leax      >L0DCB,pcr
                    pshs      x
                    ldd       #$001E
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       u0007,u
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       ,x
                    ldd       $02,y
                    pshs      b,a
                    ldx       ,s
                    clr       $0D,x
                    ldx       <u0004
                    jsr       -$09,x
L119B               lbra      L1241
L119E               ldb       >-$008F,y
                    clra
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      b,a
                    pshs      b,a
                    pshs      b,a
                    ldd       #$FFFE
                    pshs      b,a
                    ldd       #$07FF
                    pshs      b,a
                    ldb       #$14
L11BC               clr       ,-s
                    decb
                    bne       L11BC
                    lbsr      L1270
                    lsrb
                    lbcc      L11E9
                    ldd       -u0008,u
                    pshs      b,a
                    ldd       -u0006,u
                    pshs      b,a
                    ldd       u0007,u
                    pshs      b,a
                    ldx       u0005,u
                    pshs      x
                    lbsr      L08E9
                    ldb       -$0F,y
                    lsrb
                    lbcc      L11E6
                    lbra      L1259
L11E6               lbra      L1241
L11E9               leax      >L0DE9,pcr
                    pshs      x
                    ldd       #$0039
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       -u0006,u
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       ,x
                    leax      >L0E22,pcr
                    pshs      x
                    ldd       #$001E
                    pshs      b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       -$03,x
                    ldd       u0007,u
                    pshs      b,a
                    ldd       #$0001
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    ldx       <u0004
                    jsr       ,x
                    ldd       $02,y
                    pshs      b,a
                    ldx       ,s
                    clr       $0D,x
                    ldx       <u0004
                    jsr       -$09,x
L1241               ldx       u0009,u
                    ldb       $0B,x
                    andb      #$01
                    eorb      #$01
                    lsrb
                    lbcc      L1256
                    ldd       u0009,u
                    pshs      b,a
                    ldx       <u0004
                    jsr       $06,x
L1256               lbra      L0E8A
L1259               leax      >-u0099,u
                    pshs      x
                    ldx       <u0004
                    jsr       <-$3F,x
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $06,s
                    jmp       ,x
L1270               leax      <$22,s
                    ldd       ,x
                    tsta
                    bne       L128F
                    lsrb
                    lsrb
                    lsrb
                    comb
                    lda       b,x
                    beq       L128F
                    ldb       $01,x
                    leax      <L1297,pcr
                    andb      #$07
                    bita      b,x
                    beq       L128F
                    ldb       #$01
                    bra       L1290
L128F               clrb
L1290               ldx       ,s
                    leas      <$24,s
                    jmp       ,x
L1297               oim       #$02,<u0004
                    lsl       <u0010
                    bra       L12DE
                    fcb       $80
                    emod
eom                 equ       *
