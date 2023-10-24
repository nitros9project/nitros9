********************************************************************
* progname - program module
*
* $Id$
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

                    nam       Pascal
                    ttl       program module

* Disassembled 02/04/05 10:04:45 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       /dd/defs/os9defs
                    endc
tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $07
                    mod       eom,name,tylg,atrv,start,size
u0000               rmb       1
u0001               rmb       1
u0002               rmb       1
u0003               rmb       1
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
u000F               rmb       3
u0012               rmb       2
u0014               rmb       2
u0016               rmb       2
u0018               rmb       8
u0020               rmb       4
u0024               rmb       2
u0026               rmb       1
u0027               rmb       1
u0028               rmb       1
u0029               rmb       2
u002B               rmb       1
u002C               rmb       2
u002E               rmb       1
u002F               rmb       1
u0030               rmb       1
u0031               rmb       2
u0033               rmb       1
u0034               rmb       2
u0036               rmb       1
u0037               rmb       5
u003C               rmb       1
u003D               rmb       1
u003E               rmb       1
u003F               rmb       3
u0042               rmb       4
u0046               rmb       2
u0048               rmb       1
u0049               rmb       1
u004A               rmb       2
u004C               rmb       1
u004D               rmb       1
u004E               rmb       2
u0050               rmb       2
u0052               rmb       2
u0054               rmb       2
u0056               rmb       2
u0058               rmb       2
u005A               rmb       1
u005B               rmb       1
u005C               rmb       1
u005D               rmb       1
u005E               rmb       2
u0060               rmb       1
u0061               rmb       1
u0062               rmb       1
u0063               rmb       3
u0066               rmb       1
u0067               rmb       1
u0068               rmb       4
u006C               rmb       8
u0074               rmb       1
u0075               rmb       1
u0076               rmb       2
u0078               rmb       5
u007D               rmb       5
u0082               rmb       2
u0084               rmb       2
u0086               rmb       12
u0092               rmb       12
u009E               rmb       8
u00A6               rmb       8
u00AE               rmb       2
u00B0               rmb       2
u00B2               rmb       2
u00B4               rmb       22
u00CA               rmb       17
u00DB               rmb       18
u00ED               rmb       9
u00F6               rmb       1
u00F7               rmb       1
u00F8               rmb       1
u00F9               rmb       4
u00FD               rmb       1
u00FE               rmb       1
u00FF               rmb       12033
size                equ       .
name                equ       *
                    fcs       /Pascal/
                    fcb       $07
                    fcb       $31                 1
                    fcb       $64                 d
                    fcb       $31                 1
                    fcb       $28                 (
                    fcb       $43                 C
                    fcb       $29                 )
                    fcb       $20
                    fcb       $31                 1
                    fcb       $39                 9
                    fcb       $38                 8
                    fcb       $31                 1
                    fcb       $20
                    fcb       $42                 B
                    fcb       $59                 Y
                    fcb       $20
                    fcb       $4D                 M
                    fcb       $49                 I
                    fcb       $43                 C
                    fcb       $52                 R
                    fcb       $4F                 O
                    fcb       $57                 W
                    fcb       $41                 A
                    fcb       $52                 R
                    fcb       $45                 E
                    fcb       $20
                    fcb       $53                 S
                    fcb       $59                 Y
                    fcb       $53                 S
                    fcb       $54                 T
                    fcb       $45                 E
                    fcb       $4D                 M
                    fcb       $53                 S
                    fcb       $20
                    fcb       $43                 C
                    fcb       $4F                 O
                    fcb       $52                 R
                    fcb       $50                 P
                    fcb       $2E                 .
                    fcb       $20
                    fcb       $20
                    fcb       $41                 A
                    fcb       $4C                 L
                    fcb       $4C                 L
                    fcb       $20
                    fcb       $52                 R
                    fcb       $49                 I
                    fcb       $47                 G
                    fcb       $48                 H
                    fcb       $54                 T
                    fcb       $53                 S
                    fcb       $20
                    fcb       $52                 R
                    fcb       $45                 E
                    fcb       $53                 S
                    fcb       $45                 E
                    fcb       $52                 R
                    fcb       $56                 V
                    fcb       $45                 E
                    fcb       $44                 D
                    fcb       $2E                 .
L0050               fcb       $35                 5
                    fcb       $10
                    fcb       $9F
                    fcb       $1E
                    fcb       $DC                 \
                    fcb       $34                 4
                    fcb       $DD                 ]
                    fcb       $12
                    fcb       $DD                 ]
                    fcb       $3A                 :
                    fcb       $DC                 \
                    fcb       $00
                    fcb       $83
                    fcb       $01
                    fcb       $98
                    fcb       $1F
                    fcb       $02
                    fcb       $32                 2
                    fcb       $A4                 $
                    fcb       $33                 3
                    fcb       $E4                 d
                    fcb       $DF                 _
                    fcb       $14
                    fcb       $DF                 _
                    fcb       $38                 8
                    fcb       $93
                    fcb       $34                 4
                    fcb       $DD                 ]
                    fcb       $22                 "
                    fcb       $30                 0
                    fcb       $28                 (
                    fcb       $9F
                    fcb       $1C
                    fcb       $30                 0
                    fcb       $A8                 (
                    fcb       $12
                    fcb       $9F
                    fcb       $20
                    fcb       $30                 0
                    fcb       $A8                 (
                    fcb       $76                 v
                    fcb       $AF                 /
                    fcb       $A4                 $
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $80
                    fcb       $ED                 m
                    fcb       $04
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $14
                    fcb       $ED                 m
                    fcb       $0A
                    fcb       $4F                 O
                    fcb       $5F                 _
                    fcb       $E7                 g
                    fcb       $0C
                    fcb       $34                 4
                    fcb       $16
                    fcb       $34                 4
                    fcb       $06
                    fcb       $17
                    fcb       $00
                    fcb       $8C
                    fcb       $30                 0
                    fcb       $A9                 )
                    fcb       $01
                    fcb       $07
                    fcb       $AF                 /
                    fcb       $22                 "
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $80
                    fcb       $ED                 m
                    fcb       $04
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $18
                    fcb       $ED                 m
                    fcb       $0A
                    fcb       $86
                    fcb       $01
                    fcb       $A7                 '
                    fcb       $0C
                    fcb       $4F                 O
                    fcb       $5F                 _
                    fcb       $34                 4
                    fcb       $16
                    fcb       $34                 4
                    fcb       $06
                    fcb       $8D
                    fcb       $10
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $D7                 W
                    fcb       $29                 )
                    fcb       $DC                 \
                    fcb       $3C                 <
                    fcb       $ED                 m
                    fcb       $26                 &
                    fcb       $9E
                    fcb       $1E
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $86
                    fcb       $0C
                    fcb       $20
                    fcb       $02
                    fcb       $86
                    fcb       $08
                    fcb       $34                 4
                    fcb       $62                 b
                    fcb       $AE                 .
                    fcb       $6B                 k
                    fcb       $17
                    fcb       $02
                    fcb       $6A                 j
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $10
                    fcb       $AE                 .
                    fcb       $69                 i
                    fcb       $26                 &
                    fcb       $07
                    fcb       $C5                 E
                    fcb       $0C
                    fcb       $26                 &
                    fcb       $10
                    fcb       $10
                    fcb       $AE                 .
                    fcb       $67                 g
                    fcb       $C5                 E
                    fcb       $0C
                    fcb       $27                 '
                    fcb       $09
                    fcb       $34                 4
                    fcb       $10
                    fcb       $17
                    fcb       $06
                    fcb       $D8                 X
                    fcb       $AE                 .
                    fcb       $6B                 k
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $C4                 D
                    fcb       $3D                 =
                    fcb       $CA                 J
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $0B
                    fcb       $A6                 &
                    fcb       $E4                 d
                    fcb       $8D
                    fcb       $79                 y
                    fcb       $35                 5
                    fcb       $62                 b
                    fcb       $35                 5
                    fcb       $10
                    fcb       $32                 2
                    fcb       $66                 f
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $DF                 _
                    fcb       $10
                    fcb       $32                 2
                    fcb       $7A                 z
                    fcb       $30                 0
                    fcb       $E4                 d
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $15
                    fcb       $24                 $
                    fcb       $08
                    fcb       $4F                 O
                    fcb       $5F                 _
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $ED                 m
                    fcb       $62                 b
                    fcb       $ED                 m
                    fcb       $64                 d
                    fcb       $33                 3
                    fcb       $E8                 h
                    fcb       $14
                    fcb       $8E
                    fcb       $00
                    fcb       $06
                    fcb       $4F                 O
                    fcb       $35                 5
                    fcb       $04
                    fcb       $ED                 m
                    fcb       $D3                 S
                    fcb       $30                 0
                    fcb       $1F
                    fcb       $26                 &
                    fcb       $F8                 x
                    fcb       $DE                 ^
                    fcb       $10
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $32                 2
L0119               fcb       $6E                 n
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $34                 4
                    fcb       $60                 `
                    fcb       $AE                 .
                    fcb       $6A                 j
                    fcb       $17
                    fcb       $02
                    fcb       $0C
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $10
                    fcb       $AE                 .
                    fcb       $68                 h
                    fcb       $26                 &
                    fcb       $07
                    fcb       $C5                 E
                    fcb       $0C
                    fcb       $26                 &
                    fcb       $10
                    fcb       $10
                    fcb       $AE                 .
                    fcb       $66                 f
                    fcb       $C5                 E
                    fcb       $0C
                    fcb       $27                 '
                    fcb       $09
                    fcb       $34                 4
                    fcb       $10
                    fcb       $17
                    fcb       $06
                    fcb       $7A                 z
                    fcb       $AE                 .
                    fcb       $6A                 j
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $C4                 D
                    fcb       $3C                 <
                    fcb       $E7                 g
                    fcb       $0B
                    fcb       $86
                    fcb       $04
                    fcb       $8D
                    fcb       $1D
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $C5                 E
                    fcb       $40                 @
                    fcb       $27                 '
                    fcb       $0A
                    fcb       $CA                 J
                    fcb       $80
                    fcb       $E7                 g
                    fcb       $0B
                    fcb       $86
                    fcb       $20
                    fcb       $A7                 '
                    fcb       $0E
                    fcb       $20
                    fcb       $05
                    fcb       $34                 4
                    fcb       $10
                    fcb       $17
                    fcb       $03
                    fcb       $39                 9
                    fcb       $35                 5
                    fcb       $60                 `
                    fcb       $35                 5
                    fcb       $10
                    fcb       $32                 2
                    fcb       $66                 f
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $34                 4
                    fcb       $76                 v
                    fcb       $4F                 O
                    fcb       $5F                 _
                    fcb       $E7                 g
                    fcb       $0F
                    fcb       $ED                 m
                    fcb       $84
                    fcb       $ED                 m
                    fcb       $06
                    fcb       $ED                 m
                    fcb       $08
                    fcb       $C6                 F
                    fcb       $D0                 P
                    fcb       $E7                 g
                    fcb       $0D
                    fcb       $EC                 l
                    fcb       $0A
                    fcb       $84
                    fcb       $40                 @
                    fcb       $A7                 '
                    fcb       $0A
                    fcb       $C5                 E
                    fcb       $0C
                    fcb       $27                 '
                    fcb       $2D                 -
                    fcb       $A6                 &
                    fcb       $0C
                    fcb       $8E
                    fcb       $00
                    fcb       $00
                    fcb       $33                 3
                    fcb       $84
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $88
                    fcb       $24                 $
                    fcb       $49                 I
                    fcb       $D7                 W
                    fcb       $33                 3
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $63                 c
                    fcb       $AE                 .
                    fcb       $62                 b
                    fcb       $EE                 n
                    fcb       $66                 f
                    fcb       $17
                    fcb       $05
                    fcb       $59                 Y
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $C5                 E
                    fcb       $0C
                    fcb       $34                 4
                    fcb       $01
                    fcb       $C4                 D
                    fcb       $F3                 s
                    fcb       $E7                 g
                    fcb       $0B
                    fcb       $35                 5
                    fcb       $01
                    fcb       $27                 '
                    fcb       $05
                    fcb       $A6                 &
                    fcb       $0C
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $8F
                    fcb       $35                 5
                    fcb       $F6                 v
                    fcb       $30                 0
                    fcb       $A4                 $
                    fcb       $A6                 &
                    fcb       $E4                 d
                    fcb       $85
                    fcb       $08
                    fcb       $27                 '
                    fcb       $15
                    fcb       $CC                 L
                    fcb       $03
                    fcb       $07
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $83
                    fcb       $24                 $
                    fcb       $14
                    fcb       $C1                 A
                    fcb       $DA                 Z
                    fcb       $27                 '
                    fcb       $07
                    fcb       $D7                 W
                    fcb       $33                 3
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $62                 b
                    fcb       $20
                    fcb       $C9                 I
                    fcb       $AE                 .
                    fcb       $64                 d
                    fcb       $86
                    fcb       $03
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $84
                    fcb       $25                 %
                    fcb       $F0                 p
                    fcb       $AE                 .
                    fcb       $62                 b
                    fcb       $A7                 '
                    fcb       $0C
                    fcb       $AE                 .
                    fcb       $62                 b
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $C4                 D
                    fcb       $F3                 s
                    fcb       $EA                 j
                    fcb       $E4                 d
                    fcb       $E7                 g
                    fcb       $0B
                    fcb       $8D
                    fcb       $4D                 M
                    fcb       $32                 2
                    fcb       $E8                 h
                    fcb       $E0                 `
                    fcb       $A6                 &
                    fcb       $0C
                    fcb       $5F                 _
                    fcb       $30                 0
                    fcb       $E4                 d
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $8D
                    fcb       $24                 $
                    fcb       $0A
                    fcb       $D7                 W
                    fcb       $33                 3
                    fcb       $32                 2
                    fcb       $E8                 h
                    fcb       $20
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $60                 `
                    fcb       $20
                    fcb       $99
                    fcb       $AE                 .
                    fcb       $E8                 h
                    fcb       $22                 "
                    fcb       $A6                 &
                    fcb       $E4                 d
                    fcb       $26                 &
                    fcb       $10
                    fcb       $A6                 &
                    fcb       $65                 e
                    fcb       $84
                    fcb       $01
                    fcb       $8A
                    fcb       $80
                    fcb       $AA                 *
                    fcb       $0A
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $CA                 J
                    fcb       $40                 @
                    fcb       $ED                 m
                    fcb       $0A
                    fcb       $20
                    fcb       $1A
                    fcb       $81
                    fcb       $01
                    fcb       $26                 &
                    fcb       $16
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $C4                 D
                    fcb       $0C
                    fcb       $C1                 A
                    fcb       $08
                    fcb       $26                 &
                    fcb       $0E
                    fcb       $A6                 &
                    fcb       $0C
                    fcb       $C6                 F
                    fcb       $02
                    fcb       $8E
                    fcb       $00
                    fcb       $00
                    fcb       $33                 3
                    fcb       $84
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $8E
                    fcb       $25                 %
                    fcb       $C5                 E
                    fcb       $32                 2
                    fcb       $E8                 h
                    fcb       $20
                    fcb       $35                 5
                    fcb       $F6                 v
                    fcb       $34                 4
                    fcb       $06
                    fcb       $A6                 &
                    fcb       $0B
                    fcb       $85
                    fcb       $10
                    fcb       $27                 '
                    fcb       $06
                    fcb       $4F                 O
                    fcb       $5F                 _
                    fcb       $ED                 m
                    fcb       $84
                    fcb       $20
                    fcb       $02
                    fcb       $EC                 l
                    fcb       $04
                    fcb       $ED                 m
                    fcb       $02
                    fcb       $35                 5
                    fcb       $86
                    fcb       $34                 4
                    fcb       $10
                    fcb       $10
                    fcb       $AE                 .
                    fcb       $02
                    fcb       $27                 '
                    fcb       $15
                    fcb       $A6                 &
                    fcb       $0C
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $30                 0
                    fcb       $88
                    fcb       $10
                    fcb       $C5                 E
                    fcb       $10
                    fcb       $26                 &
                    fcb       $05
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $8A
                    fcb       $35                 5
                    fcb       $90
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $8C
                    fcb       $35                 5
                    fcb       $90
                    fcb       $5F                 _
                    fcb       $35                 5
                    fcb       $90
L025E               fcb       $AE                 .
                    fcb       $62                 b
                    fcb       $6F                 o
                    fcb       $0D
L0262               fcb       $34                 4
                    fcb       $20
                    fcb       $AE                 .
                    fcb       $64                 d
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $C5                 E
                    fcb       $0C
                    fcb       $26                 &
                    fcb       $05
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $5F                 _
                    fcb       $20
                    fcb       $1A
                    fcb       $C5                 E
                    fcb       $08
                    fcb       $26                 &
                    fcb       $05
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $5E                 ^
                    fcb       $20
                    fcb       $11
                    fcb       $C5                 E
                    fcb       $80
                    fcb       $27                 '
                    fcb       $06
                    fcb       $C4                 D
                    fcb       $7F
                    fcb       $CA                 J
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $0B
                    fcb       $C5                 E
                    fcb       $01
                    fcb       $26                 &
                    fcb       $08
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $5D                 ]
                    fcb       $17
                    fcb       $04
                    fcb       $60                 `
                    fcb       $20
                    fcb       $6E                 n
                    fcb       $C5                 E
                    fcb       $30                 0
                    fcb       $26                 &
                    fcb       $0B
                    fcb       $8D
                    fcb       $A9                 )
                    fcb       $24                 $
                    fcb       $6A                 j
                    fcb       $D7                 W
                    fcb       $33                 3
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $5C                 \
                    fcb       $20
                    fcb       $EC                 l
                    fcb       $C5                 E
                    fcb       $10
                    fcb       $27                 '
                    fcb       $F1                 q
                    fcb       $A6                 &
                    fcb       $0D
                    fcb       $81
                    fcb       $D0                 P
                    fcb       $27                 '
                    fcb       $1F
                    fcb       $A6                 &
                    fcb       $0A
                    fcb       $85
                    fcb       $80
                    fcb       $27                 '
                    fcb       $19
                    fcb       $EC                 l
                    fcb       $02
                    fcb       $27                 '
                    fcb       $1E
                    fcb       $ED                 m
                    fcb       $02
                    fcb       $31                 1
                    fcb       $88
                    fcb       $10
                    fcb       $83
                    fcb       $00
                    fcb       $01
                    fcb       $A6                 &
                    fcb       $AB                 +
                    fcb       $81
                    fcb       $20
                    fcb       $26                 &
                    fcb       $0B
                    fcb       $EC                 l
                    fcb       $02
                    fcb       $83
                    fcb       $00
                    fcb       $01
                    fcb       $20
                    fcb       $E9                 i
                    fcb       $EC                 l
                    fcb       $02
                    fcb       $27                 '
                    fcb       $05
                    fcb       $17
                    fcb       $FF
                    fcb       $70                 p
                    fcb       $25                 %
                    fcb       $C7                 G
                    fcb       $A6                 &
                    fcb       $0D
                    fcb       $26                 &
                    fcb       $08
                    fcb       $86
                    fcb       $0D
                    fcb       $8D
                    fcb       $47                 G
                    fcb       $25                 %
                    fcb       $BD                 =
                    fcb       $20
                    fcb       $21                 !
                    fcb       $81
                    fcb       $31                 1
                    fcb       $26                 &
                    fcb       $19
                    fcb       $86
                    fcb       $0C
                    fcb       $8D
                    fcb       $3B                 ;
                    fcb       $86
                    fcb       $0D
                    fcb       $34                 4
                    fcb       $12
                    fcb       $A6                 &
                    fcb       $0C
                    fcb       $30                 0
                    fcb       $E4                 d
                    fcb       $10
                    fcb       $8E
                    fcb       $00
                    fcb       $01
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $8A
                    fcb       $35                 5
                    fcb       $12
                    fcb       $25                 %
                    fcb       $A0
                    fcb       $20
                    fcb       $04
                    fcb       $81
                    fcb       $2B                 +
                    fcb       $27                 '
                    fcb       $E7                 g
                    fcb       $C6                 F
                    fcb       $D0                 P
                    fcb       $E7                 g
                    fcb       $0D
                    fcb       $17
                    fcb       $FF
                    fcb       $26                 &
                    fcb       $8D
                    fcb       $08
                    fcb       $35                 5
                    fcb       $20
                    fcb       $35                 5
                    fcb       $10
                    fcb       $32                 2
                    fcb       $62                 b
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $EC                 l
                    fcb       $08
                    fcb       $C3                 C
                    fcb       $00
                    fcb       $01
                    fcb       $ED                 m
                    fcb       $08
                    fcb       $24                 $
                    fcb       $07
                    fcb       $EC                 l
                    fcb       $06
                    fcb       $C3                 C
                    fcb       $00
                    fcb       $01
                    fcb       $ED                 m
                    fcb       $06
                    fcb       $39                 9
                    fcb       $34                 4
                    fcb       $12
                    fcb       $A6                 &
                    fcb       $0C
                    fcb       $30                 0
                    fcb       $E4                 d
                    fcb       $10
                    fcb       $8E
                    fcb       $00
                    fcb       $01
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $8C
                    fcb       $35                 5
                    fcb       $92
                    fcb       $34                 4
                    fcb       $16
                    fcb       $A6                 &
                    fcb       $0B
                    fcb       $84
                    fcb       $1D
                    fcb       $81
                    fcb       $19
                    fcb       $26                 &
                    fcb       $09
                    fcb       $EC                 l
                    fcb       $84
                    fcb       $27                 '
                    fcb       $05
                    fcb       $34                 4
                    fcb       $10
                    fcb       $17
                    fcb       $FF
                    fcb       $20
                    fcb       $35                 5
                    fcb       $96
                    fcb       $34                 4
                    fcb       $20
                    fcb       $AE                 .
                    fcb       $64                 d
                    fcb       $A6                 &
                    fcb       $0B
                    fcb       $85
                    fcb       $0C
                    fcb       $26                 &
                    fcb       $05
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $5F                 _
                    fcb       $20
                    fcb       $1C
                    fcb       $85
                    fcb       $08
                    fcb       $26                 &
                    fcb       $05
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $5E                 ^
                    fcb       $20
                    fcb       $13
                    fcb       $85
                    fcb       $80
                    fcb       $27                 '
                    fcb       $08
                    fcb       $84
                    fcb       $7F
                    fcb       $8A
                    fcb       $01
                    fcb       $A7                 '
                    fcb       $0B
                    fcb       $20
                    fcb       $18
                    fcb       $85
                    fcb       $01
                    fcb       $26                 &
                    fcb       $08
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $5D                 ]
                    fcb       $17
                    fcb       $03
                    fcb       $7C
                    fcb       $20
                    fcb       $20
                    fcb       $EC                 l
                    fcb       $02
                    fcb       $10
                    fcb       $A3                 #
                    fcb       $04
                    fcb       $25                 %
                    fcb       $05
                    fcb       $34                 4
                    fcb       $10
                    fcb       $17
                    fcb       $FE
                    fcb       $E2                 b
                    fcb       $AE                 .
                    fcb       $64                 d
                    fcb       $31                 1
                    fcb       $88
                    fcb       $10
                    fcb       $EC                 l
                    fcb       $84
                    fcb       $31                 1
                    fcb       $AB                 +
                    fcb       $C3                 C
                    fcb       $00
                    fcb       $01
                    fcb       $ED                 m
                    fcb       $84
                    fcb       $ED                 m
                    fcb       $02
                    fcb       $A6                 &
                    fcb       $0E
                    fcb       $A7                 '
                    fcb       $A4                 $
                    fcb       $35                 5
                    fcb       $20
                    fcb       $35                 5
                    fcb       $10
                    fcb       $32                 2
                    fcb       $62                 b
                    fcb       $6E                 n
                    fcb       $84
L039C               fcb       $35                 5
                    fcb       $10
                    fcb       $9F
                    fcb       $1E
                    fcb       $8E
                    fcb       $00
                    fcb       $01
                    fcb       $EC                 l
                    fcb       $E4                 d
                    fcb       $34                 4
                    fcb       $16
                    fcb       $EC                 l
                    fcb       $66                 f
                    fcb       $ED                 m
                    fcb       $64                 d
                    fcb       $30                 0
                    fcb       $68                 h
                    fcb       $AF                 /
                    fcb       $66                 f
                    fcb       $8D
                    fcb       $0E
                    fcb       $32                 2
                    fcb       $61                 a
                    fcb       $9E
                    fcb       $1E
                    fcb       $6E                 n
                    fcb       $84
L03B7               fcb       $AE                 .
                    fcb       $66                 f
                    fcb       $AC                 ,
                    fcb       $64                 d
                    fcb       $24                 $
                    fcb       $02
                    fcb       $AF                 /
                    fcb       $64                 d
                    fcb       $34                 4
                    fcb       $20
                    fcb       $EC                 l
                    fcb       $68                 h
                    fcb       $A3                 #
                    fcb       $66                 f
                    fcb       $2F                 /
                    fcb       $14
                    fcb       $AE                 .
                    fcb       $64                 d
                    fcb       $86
                    fcb       $20
                    fcb       $A7                 '
                    fcb       $0E
                    fcb       $34                 4
                    fcb       $10
                    fcb       $17
                    fcb       $FF
                    fcb       $72                 r
                    fcb       $EC                 l
                    fcb       $68                 h
                    fcb       $83
                    fcb       $00
                    fcb       $01
                    fcb       $ED                 m
                    fcb       $68                 h
                    fcb       $20
                    fcb       $E8                 h
                    fcb       $AE                 .
                    fcb       $64                 d
                    fcb       $EC                 l
                    fcb       $66                 f
                    fcb       $27                 '
                    fcb       $17
                    fcb       $10
                    fcb       $AE                 .
                    fcb       $6A                 j
                    fcb       $DD                 ]
                    fcb       $2A                 *
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $AE                 .
                    fcb       $64                 d
                    fcb       $E7                 g
                    fcb       $0E
                    fcb       $34                 4
                    fcb       $10
                    fcb       $17
                    fcb       $FF
                    fcb       $53                 S
                    fcb       $DC                 \
                    fcb       $2A                 *
                    fcb       $83
                    fcb       $00
                    fcb       $01
                    fcb       $26                 &
                    fcb       $EC                 l
                    fcb       $EC                 l
                    fcb       $68                 h
                    fcb       $A3                 #
                    fcb       $66                 f
                    fcb       $2F                 /
                    fcb       $14
                    fcb       $DD                 ]
                    fcb       $2A                 *
                    fcb       $AE                 .
                    fcb       $64                 d
                    fcb       $86
                    fcb       $20
                    fcb       $A7                 '
                    fcb       $0E
                    fcb       $34                 4
                    fcb       $10
                    fcb       $17
                    fcb       $FF
                    fcb       $39                 9
                    fcb       $DC                 \
                    fcb       $2A                 *
                    fcb       $83
                    fcb       $00
                    fcb       $01
                    fcb       $26                 &
                    fcb       $EC                 l
                    fcb       $35                 5
                    fcb       $20
                    fcb       $35                 5
                    fcb       $10
                    fcb       $32                 2
                    fcb       $68                 h
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $34                 4
                    fcb       $36                 6
                    fcb       $30                 0
                    fcb       $8C
                    fcb       $4B                 K
                    fcb       $0F
                    fcb       $27                 '
                    fcb       $0F
                    fcb       $2A                 *
                    fcb       $0F
                    fcb       $2B                 +
                    fcb       $4D                 M
                    fcb       $2A                 *
                    fcb       $0E
                    fcb       $0D
                    fcb       $28                 (
                    fcb       $26                 &
                    fcb       $0A
                    fcb       $86
                    fcb       $2D                 -
                    fcb       $A7                 '
                    fcb       $A0
                    fcb       $0C
                    fcb       $2B                 +
                    fcb       $4F                 O
                    fcb       $5F                 _
                    fcb       $A3                 #
                    fcb       $E4                 d
                    fcb       $DD                 ]
                    fcb       $0A
                    fcb       $DC                 \
                    fcb       $0A
                    fcb       $0F
                    fcb       $2C                 ,
                    fcb       $A3                 #
                    fcb       $84
                    fcb       $25                 %
                    fcb       $04
                    fcb       $0C
                    fcb       $2C                 ,
                    fcb       $20
                    fcb       $F8                 x
                    fcb       $E3                 c
                    fcb       $84
                    fcb       $DD                 ]
                    fcb       $0A
                    fcb       $96
                    fcb       $2C                 ,
                    fcb       $26                 &
                    fcb       $04
                    fcb       $0D
                    fcb       $27                 '
                    fcb       $27                 '
                    fcb       $08
                    fcb       $0C
                    fcb       $27                 '
                    fcb       $8A
                    fcb       $30                 0
                    fcb       $A7                 '
                    fcb       $A0
                    fcb       $0C
                    fcb       $2B                 +
                    fcb       $30                 0
                    fcb       $02
                    fcb       $6D                 m
                    fcb       $84
                    fcb       $2A                 *
                    fcb       $DA                 Z
                    fcb       $96
                    fcb       $0B
                    fcb       $8A
                    fcb       $30                 0
                    fcb       $C6                 F
                    fcb       $0D
                    fcb       $ED                 m
                    fcb       $A4                 $
                    fcb       $0C
                    fcb       $2B                 +
                    fcb       $35                 5
                    fcb       $B6                 6
                    fcb       $27                 '
                    fcb       $10
                    fcb       $03
                    fcb       $E8                 h
                    fcb       $00
                    fcb       $64                 d
                    fcb       $00
                    fcb       $0A
                    fcb       $FF
                    fcb       $FF
L0474               fcb       $34                 4
                    fcb       $20
                    fcb       $10
                    fcb       $9E
                    fcb       $1C
                    fcb       $EC                 l
                    fcb       $68                 h
                    fcb       $0F
                    fcb       $28                 (
                    fcb       $8D
                    fcb       $9B
                    fcb       $AE                 .
                    fcb       $66                 f
                    fcb       $DC                 \
                    fcb       $2A                 *
                    fcb       $34                 4
                    fcb       $36                 6
                    fcb       $AE                 .
                    fcb       $6A                 j
                    fcb       $34                 4
                    fcb       $10
                    fcb       $17
                    fcb       $FF
                    fcb       $33                 3
                    fcb       $35                 5
                    fcb       $20
                    fcb       $35                 5
                    fcb       $10
                    fcb       $32                 2
                    fcb       $66                 f
                    fcb       $6E                 n
                    fcb       $84
L0494               fcb       $34                 4
                    fcb       $20
                    fcb       $AE                 .
                    fcb       $64                 d
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $C5                 E
                    fcb       $0C
                    fcb       $26                 &
                    fcb       $05
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $47                 G
                    fcb       $20
                    fcb       $18
                    fcb       $C5                 E
                    fcb       $04
                    fcb       $26                 &
                    fcb       $05
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $46                 F
                    fcb       $20
                    fcb       $0F
                    fcb       $C5                 E
                    fcb       $80
                    fcb       $27                 '
                    fcb       $04
                    fcb       $C4                 D
                    fcb       $7E
                    fcb       $E7                 g
                    fcb       $0B
                    fcb       $C5                 E
                    fcb       $01
                    fcb       $27                 '
                    fcb       $17
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $45                 E
                    fcb       $17
                    fcb       $02
                    fcb       $30                 0
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $20
                    fcb       $3B                 ;
                    fcb       $10
                    fcb       $AC                 ,
                    fcb       $02
                    fcb       $27                 '
                    fcb       $74                 t
                    fcb       $10
                    fcb       $AF                 /
                    fcb       $02
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $44                 D
                    fcb       $20
                    fcb       $EC                 l
                    fcb       $C5                 E
                    fcb       $30                 0
                    fcb       $27                 '
                    fcb       $0A
                    fcb       $C5                 E
                    fcb       $10
                    fcb       $26                 &
                    fcb       $32                 2
                    fcb       $A6                 &
                    fcb       $0A
                    fcb       $85
                    fcb       $80
                    fcb       $26                 &
                    fcb       $2C                 ,
                    fcb       $A6                 &
                    fcb       $0C
                    fcb       $10
                    fcb       $AE                 .
                    fcb       $02
                    fcb       $30                 0
                    fcb       $88
                    fcb       $10
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $89
                    fcb       $AE                 .
                    fcb       $64                 d
                    fcb       $24                 $
                    fcb       $D6                 V
                    fcb       $C1                 A
                    fcb       $D3                 S
                    fcb       $27                 '
                    fcb       $07
                    fcb       $D7                 W
                    fcb       $33                 3
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $43                 C
                    fcb       $20
                    fcb       $C4                 D
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $CA                 J
                    fcb       $03
                    fcb       $E7                 g
                    fcb       $0B
                    fcb       $C5                 E
                    fcb       $10
                    fcb       $27                 '
                    fcb       $3A                 :
                    fcb       $4F                 O
                    fcb       $5F                 _
                    fcb       $ED                 m
                    fcb       $84
                    fcb       $ED                 m
                    fcb       $02
                    fcb       $20
                    fcb       $32                 2
                    fcb       $A6                 &
                    fcb       $0C
                    fcb       $10
                    fcb       $AE                 .
                    fcb       $04
                    fcb       $30                 0
                    fcb       $88
                    fcb       $10
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $8B
                    fcb       $AE                 .
L0515               fcb       $64                 d
                    fcb       $25                 %
                    fcb       $D4                 T
                    fcb       $31                 1
                    fcb       $3F                 ?
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $C5                 E
                    fcb       $20
                    fcb       $26                 &
                    fcb       $26                 &
                    fcb       $10
                    fcb       $AF                 /
                    fcb       $02
                    fcb       $A6                 &
                    fcb       $88
                    fcb       $10
                    fcb       $81
                    fcb       $0D
                    fcb       $26                 &
                    fcb       $06
                    fcb       $CA                 J
                    fcb       $02
                    fcb       $86
                    fcb       $20
                    fcb       $20
                    fcb       $02
                    fcb       $C4                 D
                    fcb       $FD
                    fcb       $A7                 '
                    fcb       $0E
                    fcb       $E7                 g
                    fcb       $0B
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $01
                    fcb       $ED                 m
                    fcb       $84
                    fcb       $17
                    fcb       $FD
                    fcb       $D1                 Q
                    fcb       $35                 5
                    fcb       $20
                    fcb       $35                 5
                    fcb       $10
                    fcb       $32                 2
                    fcb       $62                 b
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $34                 4
                    fcb       $20
                    fcb       $EC                 l
                    fcb       $E4                 d
                    fcb       $31                 1
                    fcb       $88
                    fcb       $10
                    fcb       $31                 1
                    fcb       $AB                 +
                    fcb       $EC                 l
                    fcb       $04
                    fcb       $ED                 m
                    fcb       $02
                    fcb       $A3                 #
                    fcb       $E1                 a
                    fcb       $1F
                    fcb       $01
                    fcb       $86
                    fcb       $20
                    fcb       $A7                 '
                    fcb       $A0
                    fcb       $30                 0
                    fcb       $1F
                    fcb       $26                 &
                    fcb       $FA                 z
                    fcb       $AE                 .
                    fcb       $64                 d
                    fcb       $20
                    fcb       $D8                 X
                    fcb       $20
                    fcb       $46                 F
                    fcb       $72                 r
                    fcb       $65                 e
                    fcb       $65                 e
                    fcb       $20
                    fcb       $4D                 M
                    fcb       $65                 e
                    fcb       $6D                 m
                    fcb       $6F                 o
                    fcb       $72                 r
                    fcb       $79                 y
                    fcb       $20
                    fcb       $3D                 =
                    fcb       $20
                    fcb       $20
                    fcb       $41                 A
                    fcb       $63                 c
                    fcb       $74                 t
                    fcb       $75                 u
                    fcb       $61                 a
                    fcb       $6C                 l
                    fcb       $20
                    fcb       $48                 H
                    fcb       $65                 e
                    fcb       $61                 a
                    fcb       $70                 p
                    fcb       $20
                    fcb       $3D                 =
                    fcb       $20
                    fcb       $41                 A
                    fcb       $63                 c
                    fcb       $74                 t
                    fcb       $75                 u
                    fcb       $61                 a
                    fcb       $6C                 l
                    fcb       $20
                    fcb       $53                 S
                    fcb       $74                 t
                    fcb       $61                 a
                    fcb       $63                 c
                    fcb       $6B                 k
                    fcb       $20
                    fcb       $3D                 =
                    fcb       $20
                    fcb       $FF
                    fcb       $E2                 b
                    fcb       $00
                    fcb       $0F
                    fcb       $00
                    fcb       $3A                 :
                    fcb       $FF
                    fcb       $F1                 q
                    fcb       $00
                    fcb       $0F
                    fcb       $00
                    fcb       $38                 8
                    fcb       $FF
                    fcb       $D3                 S
                    fcb       $00
                    fcb       $0F
                    fcb       $00
                    fcb       $22                 "
                    fcb       $00
                    fcb       $00
                    fcb       $10
                    fcb       $9E
                    fcb       $14
                    fcb       $96
                    fcb       $29                 )
                    fcb       $27                 '
                    fcb       $34                 4
                    fcb       $AE                 .
                    fcb       $22                 "
                    fcb       $17
                    fcb       $FD
                    fcb       $7F
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $D7                 W
                    fcb       $28                 (
                    fcb       $17
                    fcb       $01
                    fcb       $D3                 S
                    fcb       $DC                 \
                    fcb       $3A                 :
                    fcb       $93
                    fcb       $34                 4
                    fcb       $DD                 ]
                    fcb       $3A                 :
                    fcb       $DC                 \
                    fcb       $14
                    fcb       $93
                    fcb       $38                 8
                    fcb       $DD                 ]
                    fcb       $38                 8
                    fcb       $33                 3
                    fcb       $8C
                    fcb       $CA                 J
                    fcb       $EC                 l
                    fcb       $C1                 A
                    fcb       $27                 '
                    fcb       $15
                    fcb       $30                 0
                    fcb       $8C
                    fcb       $C3                 C
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $EC                 l
                    fcb       $C1                 A
                    fcb       $17
                    fcb       $01
                    fcb       $C7                 G
                    fcb       $9E
                    fcb       $02
                    fcb       $EC                 l
                    fcb       $C1                 A
                    fcb       $EC                 l
                    fcb       $8B
                    fcb       $17
                    fcb       $01
                    fcb       $C8                 H
                    fcb       $20
                    fcb       $E7                 g
                    fcb       $39                 9
L05E0               fcb       $DC                 \
                    fcb       $12
                    fcb       $ED                 m
                    fcb       $F8                 x
                    fcb       $04
                    fcb       $E3                 c
                    fcb       $62                 b
                    fcb       $25                 %
                    fcb       $25                 %
                    fcb       $DD                 ]
                    fcb       $12
                    fcb       $10
                    fcb       $93
                    fcb       $3A                 :
                    fcb       $23                 #
                    fcb       $02
                    fcb       $DD                 ]
                    fcb       $3A                 :
                    fcb       $DC                 \
                    fcb       $18
                    fcb       $93
                    fcb       $12
                    fcb       $25                 %
                    fcb       $16
                    fcb       $4D                 M
                    fcb       $27                 '
                    fcb       $13
                    fcb       $4A                 J
                    fcb       $10
                    fcb       $93
                    fcb       $22                 "
                    fcb       $24                 $
                    fcb       $02
                    fcb       $DD                 ]
                    fcb       $22                 "
                    fcb       $86
                    fcb       $01
                    fcb       $17
                    fcb       $15
                    fcb       $9E
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $32                 2
                    fcb       $66                 f
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $4F                 O
                    fcb       $5F                 _
                    fcb       $DD                 ]
                    fcb       $22                 "
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $B6                 6
                    fcb       $16
                    fcb       $00
                    fcb       $D6                 V
                    fcb       $AE                 .
                    fcb       $62                 b
                    fcb       $9C
                    fcb       $12
                    fcb       $22                 "
                    fcb       $47                 G
                    fcb       $9C
                    fcb       $34                 4
                    fcb       $25                 %
                    fcb       $43                 C
                    fcb       $9F
                    fcb       $12
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $32                 2
                    fcb       $64                 d
                    fcb       $6E                 n
                    fcb       $84
L062A               fcb       $34                 4
                    fcb       $06
                    fcb       $EC                 l
                    fcb       $64                 d
                    fcb       $34                 4
                    fcb       $40                 @
                    fcb       $10
                    fcb       $A3                 #
                    fcb       $E1                 a
                    fcb       $22                 "
                    fcb       $27                 '
                    fcb       $A3                 #
                    fcb       $E1                 a
                    fcb       $DD                 ]
                    fcb       $18
                    fcb       $25                 %
                    fcb       $21                 !
                    fcb       $10
                    fcb       $93
                    fcb       $38                 8
                    fcb       $24                 $
                    fcb       $02
                    fcb       $DD                 ]
                    fcb       $38                 8
                    fcb       $93
                    fcb       $12
                    fcb       $25                 %
                    fcb       $16
                    fcb       $4D                 M
                    fcb       $27                 '
                    fcb       $13
                    fcb       $4A                 J
                    fcb       $10
                    fcb       $93
                    fcb       $22                 "
                    fcb       $24                 $
                    fcb       $02
                    fcb       $DD                 ]
                    fcb       $22                 "
                    fcb       $4F                 O
                    fcb       $17
                    fcb       $15
                    fcb       $51                 Q
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $10
                    fcb       $EE                 n
                    fcb       $62                 b
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $4F                 O
                    fcb       $5F                 _
                    fcb       $DD                 ]
                    fcb       $22                 "
                    fcb       $C6                 F
                    fcb       $BB                 ;
                    fcb       $16
                    fcb       $00
                    fcb       $89
                    fcb       $C6                 F
                    fcb       $BA                 :
                    fcb       $20
                    fcb       $0A
                    fcb       $C6                 F
                    fcb       $C0                 @
                    fcb       $20
                    fcb       $06
                    fcb       $C6                 F
                    fcb       $C1                 A
                    fcb       $20
                    fcb       $02
L0671               fcb       $C6                 F
                    fcb       $C2                 B
L0673               fcb       $4F                 O
                    fcb       $AE                 .
                    fcb       $62                 b
                    fcb       $20
                    fcb       $76                 v
                    fcb       $50                 P
                    fcb       $41                 A
                    fcb       $53                 S
                    fcb       $43                 C
                    fcb       $41                 A
                    fcb       $4C                 L
                    fcb       $45                 E
                    fcb       $52                 R
                    fcb       $52                 R
                    fcb       $D3                 S
                    fcb       $34                 4
                    fcb       $46                 F
                    fcb       $96
                    fcb       $26                 &
                    fcb       $2E                 .
                    fcb       $10
                    fcb       $2D                 -
                    fcb       $35                 5
                    fcb       $30                 0
                    fcb       $8C
                    fcb       $EB                 k
                    fcb       $86
                    fcb       $21                 !
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $84
                    fcb       $25                 %
                    fcb       $2B                 +
                    fcb       $97
                    fcb       $25                 %
                    fcb       $0C
                    fcb       $26                 &
                    fcb       $8E
                    fcb       $00
                    fcb       $00
                    fcb       $33                 3
                    fcb       $84
                    fcb       $96
                    fcb       $25                 %
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $88
                    fcb       $25                 %
                    fcb       $19
                    fcb       $30                 0
                    fcb       $66                 f
                    fcb       $10
                    fcb       $8E
                    fcb       $00
                    fcb       $64                 d
                    fcb       $96
                    fcb       $25                 %
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $8B
                    fcb       $25                 %
                    fcb       $0C
                    fcb       $EC                 l
                    fcb       $E4                 d
                    fcb       $83
                    fcb       $00
                    fcb       $01
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $26                 &
                    fcb       $EA                 j
                    fcb       $30                 0
                    fcb       $66                 f
                    fcb       $5F                 _
                    fcb       $35                 5
                    fcb       $C6                 F
                    fcb       $86
                    fcb       $80
                    fcb       $97
                    fcb       $26                 &
                    fcb       $53                 S
                    fcb       $35                 5
                    fcb       $C6                 F
                    fcb       $50                 P
                    fcb       $61                 a
                    fcb       $73                 s
                    fcb       $63                 c
                    fcb       $61                 a
                    fcb       $6C                 l
                    fcb       $20
                    fcb       $45                 E
                    fcb       $72                 r
                    fcb       $72                 r
                    fcb       $6F                 o
                    fcb       $72                 r
                    fcb       $20
                    fcb       $23                 #
                    fcb       $50                 P
                    fcb       $63                 c
                    fcb       $6F                 o
                    fcb       $64                 d
                    fcb       $65                 e
                    fcb       $20
                    fcb       $6C                 l
                    fcb       $6F                 o
                    fcb       $63                 c
                    fcb       $61                 a
                    fcb       $74                 t
                    fcb       $69                 i
                    fcb       $6F                 o
                    fcb       $6E                 n
                    fcb       $3D                 =
                    fcb       $50                 P
                    fcb       $72                 r
                    fcb       $6F                 o
                    fcb       $63                 c
                    fcb       $65                 e
                    fcb       $64                 d
                    fcb       $75                 u
                    fcb       $72                 r
                    fcb       $65                 e
                    fcb       $20
                    fcb       $23                 #
                    fcb       $34                 4
                    fcb       $76                 v
                    fcb       $10
                    fcb       $83
                    fcb       $00
                    fcb       $64                 d
                    fcb       $24                 $
                    fcb       $18
                    fcb       $A6                 &
                    fcb       $0A
                    fcb       $85
                    fcb       $40                 @
                    fcb       $27                 '
                    fcb       $12
                    fcb       $A6                 &
                    fcb       $0F
                    fcb       $26                 &
                    fcb       $0C
                    fcb       $D6                 V
                    fcb       $33                 3
                    fcb       $27                 '
                    fcb       $04
                    fcb       $0F
                    fcb       $33                 3
                    fcb       $20
                    fcb       $02
                    fcb       $E6                 f
                    fcb       $61                 a
                    fcb       $E7                 g
                    fcb       $0F
                    fcb       $35                 5
                    fcb       $F6                 v
                    fcb       $8D
                    fcb       $7A                 z
                    fcb       $30                 0
                    fcb       $8C
                    fcb       $B3                 3
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $0E
                    fcb       $17
                    fcb       $00
                    fcb       $82
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $D7                 W
                    fcb       $28                 (
                    fcb       $EC                 l
                    fcb       $E4                 d
                    fcb       $17
                    fcb       $00
                    fcb       $83
                    fcb       $EC                 l
                    fcb       $E4                 d
                    fcb       $32                 2
                    fcb       $E8                 h
                    fcb       $9B
                    fcb       $17
                    fcb       $FF
                    fcb       $58                 X
                    fcb       $25                 %
                    fcb       $07
                    fcb       $86
                    fcb       $02
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $8C
                    fcb       $25                 %
                    fcb       $54                 T
                    fcb       $32                 2
                    fcb       $E8                 h
                    fcb       $65                 e
                    fcb       $D6                 V
                    fcb       $33                 3
                    fcb       $27                 '
                    fcb       $07
                    fcb       $86
                    fcb       $02
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $0F
                    fcb       $0F
                    fcb       $33                 3
                    fcb       $D6                 V
                    fcb       $29                 )
                    fcb       $27                 '
                    fcb       $3E                 >
                    fcb       $30                 0
                    fcb       $8D
                    fcb       $FF
                    fcb       $9A
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $0B
                    fcb       $8D
                    fcb       $4D                 M
                    fcb       $4F                 O
                    fcb       $D6                 V
                    fcb       $24                 $
                    fcb       $8D
                    fcb       $52                 R
                    fcb       $11
                    fcb       $93
                    fcb       $14
                    fcb       $24                 $
                    fcb       $12
                    fcb       $30                 0
                    fcb       $8D
                    fcb       $FF
                    fcb       $87
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $0B
                    fcb       $8D
                    fcb       $3A                 :
                    fcb       $4F                 O
                    fcb       $E6                 f
                    fcb       $42                 B
                    fcb       $8D
                    fcb       $3F                 ?
                    fcb       $EE                 n
                    fcb       $C4                 D
                    fcb       $20
                    fcb       $E9                 i
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $8C
                    fcb       $00
                    fcb       $BE                 >
                    fcb       $25                 %
                    fcb       $12
                    fcb       $8C
                    fcb       $00
                    fcb       $C7                 G
                    fcb       $22                 "
                    fcb       $0D
                    fcb       $30                 0
                    fcb       $8D
                    fcb       $FF
                    fcb       $5A                 Z
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $0F
                    fcb       $8D
                    fcb       $1C
                    fcb       $EC                 l
                    fcb       $62                 b
                    fcb       $8D
                    fcb       $22                 "
                    fcb       $9E
                    fcb       $08
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $06
                    fcb       $34                 4
                    fcb       $36                 6
                    fcb       $4F                 O
                    fcb       $C6                 F
                    fcb       $0D
                    fcb       $34                 4
                    fcb       $04
                    fcb       $30                 0
                    fcb       $E4                 d
                    fcb       $8D
                    fcb       $06
                    fcb       $32                 2
                    fcb       $61                 a
                    fcb       $35                 5
                    fcb       $B6                 6
                    fcb       $30                 0
                    fcb       $A4                 $
                    fcb       $1F
                    fcb       $02
                    fcb       $86
                    fcb       $02
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $8C
                    fcb       $25                 %
                    fcb       $E3                 c
                    fcb       $39                 9
                    fcb       $34                 4
                    fcb       $36                 6
                    fcb       $10
                    fcb       $9E
                    fcb       $1C
                    fcb       $17
                    fcb       $FC
                    fcb       $6D                 m
                    fcb       $DC                 \
                    fcb       $2A                 *
                    fcb       $5C                 \
                    fcb       $8D
                    fcb       $E7                 g
                    fcb       $35                 5
                    fcb       $B6                 6
                    fcb       $AE                 .
                    fcb       $62                 b
                    fcb       $A6                 &
                    fcb       $0B
                    fcb       $85
                    fcb       $0C
                    fcb       $27                 '
                    fcb       $1C
                    fcb       $17
                    fcb       $FB
                    fcb       $70                 p
                    fcb       $A6                 &
                    fcb       $0C
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $8F
                    fcb       $24                 $
                    fcb       $0A
                    fcb       $D7                 W
                    fcb       $33                 3
                    fcb       $AE                 .
                    fcb       $62                 b
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $3F                 ?
                    fcb       $17
                    fcb       $FF
                    fcb       $1E
                    fcb       $AE                 .
                    fcb       $62                 b
                    fcb       $A6                 &
                    fcb       $0B
                    fcb       $84
                    fcb       $F3                 s
                    fcb       $A7                 '
                    fcb       $0B
                    fcb       $35                 5
                    fcb       $10
                    fcb       $32                 2
                    fcb       $62                 b
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $ED                 m
                    fcb       $02
                    fcb       $39                 9
                    fcb       $EC                 l
                    fcb       $84
                    fcb       $27                 '
                    fcb       $F9                 y
                    fcb       $10
                    fcb       $83
                    fcb       $00
                    fcb       $02
                    fcb       $26                 &
                    fcb       $0F
                    fcb       $EC                 l
                    fcb       $02
                    fcb       $27                 '
                    fcb       $08
                    fcb       $47                 G
                    fcb       $56                 V
                    fcb       $ED                 m
                    fcb       $02
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $00
                    fcb       $59                 Y
                    fcb       $ED                 m
                    fcb       $84
                    fcb       $39                 9
                    fcb       $EC                 l
                    fcb       $02
                    fcb       $27                 '
                    fcb       $F9                 y
                    fcb       $4D                 M
                    fcb       $26                 &
                    fcb       $08
                    fcb       $1E
                    fcb       $89
                    fcb       $DD                 ]
                    fcb       $0A
                    fcb       $C6                 F
                    fcb       $08
                    fcb       $20
                    fcb       $04
                    fcb       $DD                 ]
                    fcb       $0A
                    fcb       $C6                 F
                    fcb       $10
                    fcb       $D7                 W
                    fcb       $2A                 *
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $00
                    fcb       $08
                    fcb       $0B
                    fcb       $09
                    fcb       $0A
                    fcb       $59                 Y
                    fcb       $49                 I
                    fcb       $A3                 #
                    fcb       $84
                    fcb       $2B                 +
                    fcb       $04
                    fcb       $0C
                    fcb       $0B
                    fcb       $20
                    fcb       $02
                    fcb       $E3                 c
                    fcb       $84
                    fcb       $0A
                    fcb       $2A                 *
                    fcb       $26                 &
                    fcb       $EC                 l
                    fcb       $ED                 m
                    fcb       $84
                    fcb       $DC                 \
                    fcb       $0A
                    fcb       $ED                 m
                    fcb       $02
                    fcb       $39                 9
                    fcb       $30                 0
                    fcb       $62                 b
                    fcb       $8D
                    fcb       $14
                    fcb       $8D
                    fcb       $AE                 .
                    fcb       $D6                 V
                    fcb       $2D                 -
                    fcb       $27                 '
                    fcb       $3B                 ;
                    fcb       $EC                 l
                    fcb       $02
                    fcb       $20
                    fcb       $31                 1
                    fcb       $30                 0
                    fcb       $62                 b
                    fcb       $8D
                    fcb       $06
                    fcb       $8D
                    fcb       $A0
                    fcb       $EC                 l
                    fcb       $84
                    fcb       $20
                    fcb       $2B                 +
                    fcb       $0F
                    fcb       $2D                 -
                    fcb       $EC                 l
                    fcb       $02
                    fcb       $2A                 *
                    fcb       $08
                    fcb       $40                 @
                    fcb       $50                 P
                    fcb       $82
                    fcb       $00
                    fcb       $ED                 m
                    fcb       $02
                    fcb       $03
                    fcb       $2D                 -
                    fcb       $EC                 l
                    fcb       $84
                    fcb       $2A                 *
                    fcb       $08
                    fcb       $40                 @
                    fcb       $50                 P
                    fcb       $82
                    fcb       $00
                    fcb       $ED                 m
                    fcb       $84
                    fcb       $03
                    fcb       $2D                 -
                    fcb       $39                 9
                    fcb       $30                 0
                    fcb       $62                 b
                    fcb       $8D
                    fcb       $E1                 a
                    fcb       $8D
                    fcb       $12
                    fcb       $DC                 \
                    fcb       $30                 0
                    fcb       $0D
                    fcb       $2D                 -
                    fcb       $27                 '
                    fcb       $04
                    fcb       $40                 @
                    fcb       $50                 P
                    fcb       $82
                    fcb       $00
                    fcb       $ED                 m
                    fcb       $64                 d
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $32                 2
                    fcb       $64                 d
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $EC                 l
                    fcb       $84
                    fcb       $27                 '
                    fcb       $21                 !
                    fcb       $10
                    fcb       $83
                    fcb       $00
                    fcb       $02
                    fcb       $26                 &
                    fcb       $04
                    fcb       $EC                 l
                    fcb       $02
                    fcb       $20
                    fcb       $0C
                    fcb       $EC                 l
                    fcb       $02
                    fcb       $27                 '
                    fcb       $13
                    fcb       $10
                    fcb       $83
                    fcb       $00
                    fcb       $02
                    fcb       $26                 &
                    fcb       $12
                    fcb       $EC                 l
                    fcb       $84
                    fcb       $58                 X
                    fcb       $49                 I
                    fcb       $DD                 ]
                    fcb       $30                 0
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $00
                    fcb       $59                 Y
                    fcb       $DD                 ]
                    fcb       $2E                 .
                    fcb       $39                 9
                    fcb       $DD                 ]
                    fcb       $30                 0
                    fcb       $DD                 ]
                    fcb       $2E                 .
                    fcb       $39                 9
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $00
                    fcb       $DD                 ]
                    fcb       $2E                 .
                    fcb       $E6                 f
                    fcb       $01
                    fcb       $A6                 &
                    fcb       $03
                    fcb       $3D                 =
                    fcb       $DD                 ]
                    fcb       $30                 0
                    fcb       $E6                 f
                    fcb       $01
                    fcb       $A6                 &
                    fcb       $02
                    fcb       $3D                 =
                    fcb       $D3                 S
                    fcb       $2F                 /
                    fcb       $DD                 ]
                    fcb       $2F                 /
                    fcb       $24                 $
                    fcb       $02
                    fcb       $0C
                    fcb       $2E                 .
                    fcb       $E6                 f
                    fcb       $84
                    fcb       $A6                 &
                    fcb       $03
                    fcb       $3D                 =
                    fcb       $D3                 S
                    fcb       $2F                 /
                    fcb       $DD                 ]
                    fcb       $2F                 /
                    fcb       $24                 $
                    fcb       $02
                    fcb       $0C
                    fcb       $2E                 .
                    fcb       $E6                 f
                    fcb       $84
                    fcb       $A6                 &
                    fcb       $02
                    fcb       $3D                 =
                    fcb       $D3                 S
                    fcb       $2E                 .
                    fcb       $DD                 ]
                    fcb       $2E                 .
                    fcb       $39                 9
                    fcb       $30                 0
                    fcb       $62                 b
                    fcb       $8D
                    fcb       $A2                 "
                    fcb       $DC                 \
                    fcb       $2E                 .
                    fcb       $26                 &
                    fcb       $04
                    fcb       $DC                 \
                    fcb       $30                 0
                    fcb       $20
                    fcb       $92
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $B9                 9
                    fcb       $16
                    fcb       $FE
                    fcb       $0A
L08E4               fcb       $9E
                    fcb       $3C                 <
                    fcb       $9C
                    fcb       $3E                 >
                    fcb       $24                 $
                    fcb       $06
                    fcb       $A6                 &
                    fcb       $80
                    fcb       $81
                    fcb       $3A                 :
                    fcb       $26                 &
                    fcb       $F6                 v
                    fcb       $DE                 ^
                    fcb       $02
                    fcb       $33                 3
                    fcb       $C8                 H
                    fcb       $70                 p
                    fcb       $DF                 _
                    fcb       $3C                 <
                    fcb       $C6                 F
                    fcb       $50                 P
                    fcb       $D7                 W
                    fcb       $0A
                    fcb       $9C
                    fcb       $3E                 >
                    fcb       $24                 $
                    fcb       $0A
                    fcb       $A6                 &
                    fcb       $80
                    fcb       $A7                 '
                    fcb       $C0                 @
                    fcb       $0A
                    fcb       $0A
                    fcb       $26                 &
                    fcb       $F4                 t
                    fcb       $20
                    fcb       $08
                    fcb       $86
                    fcb       $20
                    fcb       $A7                 '
                    fcb       $C0                 @
                    fcb       $0A
                    fcb       $0A
                    fcb       $26                 &
                    fcb       $FA                 z
L0911               fcb       $39                 9
                    fcb       $34                 4
                    fcb       $20
                    fcb       $EC                 l
                    fcb       $64                 d
                    fcb       $32                 2
                    fcb       $E8                 h
                    fcb       $9B
                    fcb       $17
                    fcb       $FD
                    fcb       $66                 f
                    fcb       $25                 %
                    fcb       $11
                    fcb       $34                 4
                    fcb       $10
                    fcb       $31                 1
                    fcb       $3F                 ?
                    fcb       $34                 4
                    fcb       $20
                    fcb       $34                 4
                    fcb       $20
                    fcb       $9E
                    fcb       $14
                    fcb       $EC                 l
                    fcb       $02
                    fcb       $34                 4
                    fcb       $06
                    fcb       $17
                    fcb       $FA                 z
                    fcb       $90
                    fcb       $32                 2
                    fcb       $E8                 h
                    fcb       $65                 e
                    fcb       $35                 5
                    fcb       $20
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $32                 2
                    fcb       $66                 f
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $34                 4
                    fcb       $60                 `
                    fcb       $31                 1
                    fcb       $66                 f
                    fcb       $E6                 f
                    fcb       $24                 $
                    fcb       $C8                 H
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $24                 $
                    fcb       $20
                    fcb       $4E                 N
                    fcb       $80
                    fcb       $10
                    fcb       $25                 %
                    fcb       $1A
                    fcb       $80
                    fcb       $08
                    fcb       $25                 %
                    fcb       $07
                    fcb       $34                 4
                    fcb       $02
                    fcb       $4F                 O
                    fcb       $E6                 f
                    fcb       $01
                    fcb       $20
                    fcb       $06
                    fcb       $8B
                    fcb       $08
                    fcb       $34                 4
                    fcb       $02
                    fcb       $EC                 l
                    fcb       $01
                    fcb       $8E
                    fcb       $00
                    fcb       $00
                    fcb       $6D                 m
                    fcb       $E4                 d
                    fcb       $27                 '
                    fcb       $2B                 +
                    fcb       $20
                    fcb       $1D
                    fcb       $8B
                    fcb       $08
                    fcb       $24                 $
                    fcb       $0F
                    fcb       $34                 4
                    fcb       $02
                    fcb       $4F                 O
                    fcb       $E6                 f
                    fcb       $01
                    fcb       $AE                 .
                    fcb       $02
                    fcb       $6D                 m
                    fcb       $E4                 d
                    fcb       $26                 &
                    fcb       $10
                    fcb       $1E
                    fcb       $01
                    fcb       $20
                    fcb       $16
                    fcb       $8B
                    fcb       $08
                    fcb       $34                 4
                    fcb       $02
                    fcb       $EC                 l
                    fcb       $01
                    fcb       $AE                 .
                    fcb       $03
                    fcb       $20
                    fcb       $02
                    fcb       $1E
                    fcb       $01
                    fcb       $44                 D
                    fcb       $56                 V
                    fcb       $1E
                    fcb       $01
                    fcb       $46                 F
                    fcb       $56                 V
                    fcb       $6A                 j
                    fcb       $E4                 d
                    fcb       $26                 &
                    fcb       $F4                 t
                    fcb       $32                 2
                    fcb       $61                 a
                    fcb       $39                 9
                    fcb       $34                 4
                    fcb       $60                 `
                    fcb       $31                 1
                    fcb       $66                 f
                    fcb       $A6                 &
                    fcb       $21                 !
                    fcb       $27                 '
                    fcb       $10
                    fcb       $A6                 &
                    fcb       $26                 &
                    fcb       $26                 &
                    fcb       $15
                    fcb       $EC                 l
                    fcb       $A4                 $
                    fcb       $ED                 m
                    fcb       $25                 %
                    fcb       $EC                 l
                    fcb       $22                 "
                    fcb       $ED                 m
                    fcb       $27                 '
                    fcb       $A6                 &
                    fcb       $24                 $
                    fcb       $A7                 '
                    fcb       $29                 )
                    fcb       $4F                 O
                    fcb       $35                 5
                    fcb       $60                 `
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $32                 2
                    fcb       $67                 g
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $A6                 &
                    fcb       $25                 %
                    fcb       $A0
                    fcb       $A4                 $
                    fcb       $28                 (
                    fcb       $04
                    fcb       $2A                 *
                    fcb       $E3                 c
                    fcb       $20
                    fcb       $ED                 m
                    fcb       $2B                 +
                    fcb       $06
                    fcb       $81
                    fcb       $1F
                    fcb       $2F                 /
                    fcb       $0A
                    fcb       $20
                    fcb       $E5                 e
                    fcb       $81
                    fcb       $E1                 a
                    fcb       $2D                 -
                    fcb       $D5                 U
                    fcb       $E6                 f
                    fcb       $A4                 $
                    fcb       $E7                 g
                    fcb       $25                 %
                    fcb       $E6                 f
                    fcb       $29                 )
                    fcb       $C4                 D
                    fcb       $01
                    fcb       $D7                 W
                    fcb       $2D                 -
                    fcb       $E8                 h
                    fcb       $24                 $
                    fcb       $C4                 D
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $A4                 $
                    fcb       $E6                 f
                    fcb       $29                 )
                    fcb       $C4                 D
                    fcb       $FE
                    fcb       $E7                 g
                    fcb       $29                 )
                    fcb       $E6                 f
                    fcb       $24                 $
                    fcb       $C4                 D
                    fcb       $FE
                    fcb       $E7                 g
                    fcb       $24                 $
                    fcb       $4D                 M
                    fcb       $27                 '
                    fcb       $33                 3
                    fcb       $2A                 *
                    fcb       $28                 (
                    fcb       $40                 @
                    fcb       $30                 0
                    fcb       $25                 %
                    fcb       $17
                    fcb       $FF
                    fcb       $58                 X
                    fcb       $6D                 m
                    fcb       $A4                 $
                    fcb       $27                 '
                    fcb       $2F                 /
                    fcb       $A3                 #
                    fcb       $23                 #
                    fcb       $1E
                    fcb       $01
                    fcb       $E2                 b
                    fcb       $22                 "
                    fcb       $A2                 "
                    fcb       $21                 !
                    fcb       $24                 $
                    fcb       $3B                 ;
                    fcb       $43                 C
                    fcb       $53                 S
                    fcb       $1E
                    fcb       $01
                    fcb       $43                 C
                    fcb       $53                 S
                    fcb       $C3                 C
                    fcb       $00
                    fcb       $01
                    fcb       $1E
                    fcb       $01
                    fcb       $24                 $
                    fcb       $03
                    fcb       $C3                 C
                    fcb       $00
                    fcb       $01
                    fcb       $0A
                    fcb       $2D                 -
                    fcb       $20
                    fcb       $27                 '
                    fcb       $30                 0
                    fcb       $A4                 $
                    fcb       $17
                    fcb       $FF
                    fcb       $31                 1
                    fcb       $AF                 /
                    fcb       $21                 !
                    fcb       $ED                 m
                    fcb       $23                 #
                    fcb       $AE                 .
                    fcb       $26                 &
                    fcb       $EC                 l
                    fcb       $28                 (
                    fcb       $6D                 m
                    fcb       $A4                 $
                    fcb       $26                 &
                    fcb       $D1                 Q
                    fcb       $E3                 c
                    fcb       $23                 #
                    fcb       $1E
                    fcb       $01
                    fcb       $E9                 i
                    fcb       $22                 "
                    fcb       $A9                 )
                    fcb       $21                 !
                    fcb       $24                 $
                    fcb       $0C
                    fcb       $46                 F
                    fcb       $56                 V
                    fcb       $1E
                    fcb       $01
                    fcb       $46                 F
                    fcb       $56                 V
                    fcb       $6C                 l
                    fcb       $25                 %
                    fcb       $29                 )
                    fcb       $51                 Q
                    fcb       $1E
                    fcb       $01
                    fcb       $4D                 M
                    fcb       $2B                 +
                    fcb       $0E
                    fcb       $6A                 j
                    fcb       $25                 %
                    fcb       $29                 )
                    fcb       $39                 9
                    fcb       $1E
                    fcb       $01
                    fcb       $58                 X
                    fcb       $49                 I
                    fcb       $1E
                    fcb       $01
                    fcb       $59                 Y
                    fcb       $49                 I
                    fcb       $2A                 *
                    fcb       $F2                 r
                    fcb       $1E
                    fcb       $01
                    fcb       $C3                 C
                    fcb       $00
                    fcb       $01
                    fcb       $1E
                    fcb       $01
                    fcb       $24                 $
                    fcb       $0A
                    fcb       $C3                 C
                    fcb       $00
                    fcb       $01
                    fcb       $24                 $
                    fcb       $05
                    fcb       $46                 F
                    fcb       $6C                 l
                    fcb       $25                 %
                    fcb       $29                 )
                    fcb       $2B                 +
                    fcb       $ED                 m
                    fcb       $26                 &
                    fcb       $1F
                    fcb       $10
                    fcb       $C4                 D
                    fcb       $FE
                    fcb       $0D
                    fcb       $2D                 -
                    fcb       $27                 '
                    fcb       $01
                    fcb       $5C                 \
                    fcb       $ED                 m
                    fcb       $28                 (
                    fcb       $16
                    fcb       $FF
                    fcb       $3D                 =
                    fcb       $34                 4
                    fcb       $60                 `
                    fcb       $31                 1
                    fcb       $66                 f
                    fcb       $A6                 &
                    fcb       $21                 !
                    fcb       $2A                 *
                    fcb       $04
                    fcb       $A6                 &
                    fcb       $26                 &
                    fcb       $2B                 +
                    fcb       $07
                    fcb       $4F                 O
                    fcb       $5F                 _
                    fcb       $ED                 m
                    fcb       $25                 %
                    fcb       $16
                    fcb       $FF
                    fcb       $2A                 *
                    fcb       $A6                 &
                    fcb       $A4                 $
                    fcb       $AB                 +
                    fcb       $25                 %
                    fcb       $28                 (
                    fcb       $0A
                    fcb       $2A                 *
                    fcb       $F1                 q
                    fcb       $96
                    fcb       $40                 @
                    fcb       $26                 &
                    fcb       $ED                 m
                    fcb       $43                 C
                    fcb       $16
                    fcb       $FF
                    fcb       $1B
                    fcb       $A7                 '
                    fcb       $25                 %
                    fcb       $E6                 f
                    fcb       $29                 )
                    fcb       $E8                 h
                    fcb       $24                 $
                    fcb       $C4                 D
                    fcb       $01
                    fcb       $D7                 W
                    fcb       $2D                 -
                    fcb       $A6                 &
                    fcb       $29                 )
                    fcb       $84
                    fcb       $FE
                    fcb       $A7                 '
                    fcb       $29                 )
                    fcb       $E6                 f
                    fcb       $24                 $
                    fcb       $C4                 D
                    fcb       $FE
                    fcb       $E7                 g
                    fcb       $24                 $
                    fcb       $3D                 =
                    fcb       $A7                 '
                    fcb       $E2                 b
                    fcb       $6F                 o
                    fcb       $E2                 b
                    fcb       $6F                 o
                    fcb       $E2                 b
                    fcb       $A6                 &
                    fcb       $29                 )
                    fcb       $E6                 f
                    fcb       $23                 #
                    fcb       $3D                 =
                    fcb       $E3                 c
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $61                 a
                    fcb       $24                 $
                    fcb       $02
                    fcb       $6C                 l
                    fcb       $E4                 d
                    fcb       $A6                 &
                    fcb       $28                 (
                    fcb       $E6                 f
                    fcb       $24                 $
                    fcb       $3D                 =
                    fcb       $E3                 c
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $61                 a
                    fcb       $24                 $
                    fcb       $02
                    fcb       $6C                 l
                    fcb       $E4                 d
                    fcb       $6F                 o
                    fcb       $E2                 b
                    fcb       $A6                 &
                    fcb       $29                 )
                    fcb       $E6                 f
                    fcb       $22                 "
                    fcb       $3D                 =
                    fcb       $E3                 c
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $61                 a
                    fcb       $24                 $
                    fcb       $02
                    fcb       $6C                 l
                    fcb       $E4                 d
                    fcb       $A6                 &
                    fcb       $28                 (
                    fcb       $E6                 f
                    fcb       $23                 #
                    fcb       $3D                 =
                    fcb       $E3                 c
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $61                 a
                    fcb       $24                 $
                    fcb       $02
                    fcb       $6C                 l
                    fcb       $E4                 d
                    fcb       $A6                 &
                    fcb       $27                 '
                    fcb       $E6                 f
                    fcb       $24                 $
                    fcb       $3D                 =
                    fcb       $E3                 c
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $61                 a
                    fcb       $24                 $
                    fcb       $02
                    fcb       $6C                 l
                    fcb       $E4                 d
                    fcb       $6F                 o
                    fcb       $E2                 b
                    fcb       $A6                 &
                    fcb       $29                 )
                    fcb       $E6                 f
                    fcb       $21                 !
                    fcb       $3D                 =
                    fcb       $E3                 c
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $61                 a
                    fcb       $24                 $
                    fcb       $02
                    fcb       $6C                 l
                    fcb       $E4                 d
                    fcb       $A6                 &
                    fcb       $28                 (
                    fcb       $E6                 f
                    fcb       $22                 "
                    fcb       $3D                 =
                    fcb       $E3                 c
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $61                 a
                    fcb       $24                 $
                    fcb       $02
                    fcb       $6C                 l
                    fcb       $E4                 d
                    fcb       $A6                 &
                    fcb       $27                 '
                    fcb       $E6                 f
                    fcb       $23                 #
                    fcb       $3D                 =
                    fcb       $E3                 c
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $61                 a
                    fcb       $24                 $
                    fcb       $02
                    fcb       $6C                 l
                    fcb       $E4                 d
                    fcb       $A6                 &
                    fcb       $26                 &
                    fcb       $E6                 f
                    fcb       $24                 $
                    fcb       $3D                 =
                    fcb       $E3                 c
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $61                 a
                    fcb       $24                 $
                    fcb       $02
                    fcb       $6C                 l
                    fcb       $E4                 d
                    fcb       $6F                 o
                    fcb       $E2                 b
                    fcb       $A6                 &
                    fcb       $28                 (
                    fcb       $E6                 f
                    fcb       $21                 !
                    fcb       $3D                 =
                    fcb       $E3                 c
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $61                 a
                    fcb       $24                 $
                    fcb       $02
                    fcb       $6C                 l
                    fcb       $E4                 d
                    fcb       $A6                 &
                    fcb       $27                 '
                    fcb       $E6                 f
                    fcb       $22                 "
                    fcb       $3D                 =
                    fcb       $E3                 c
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $61                 a
                    fcb       $24                 $
                    fcb       $02
                    fcb       $6C                 l
                    fcb       $E4                 d
                    fcb       $A6                 &
                    fcb       $26                 &
                    fcb       $E6                 f
                    fcb       $23                 #
                    fcb       $3D                 =
                    fcb       $E3                 c
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $61                 a
                    fcb       $24                 $
                    fcb       $02
                    fcb       $6C                 l
                    fcb       $E4                 d
                    fcb       $6F                 o
                    fcb       $E2                 b
                    fcb       $A6                 &
                    fcb       $27                 '
                    fcb       $E6                 f
                    fcb       $21                 !
                    fcb       $3D                 =
                    fcb       $E3                 c
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $61                 a
                    fcb       $24                 $
                    fcb       $02
                    fcb       $6C                 l
                    fcb       $E4                 d
                    fcb       $A6                 &
                    fcb       $26                 &
                    fcb       $E6                 f
                    fcb       $22                 "
                    fcb       $3D                 =
                    fcb       $E3                 c
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $61                 a
                    fcb       $24                 $
                    fcb       $02
                    fcb       $6C                 l
                    fcb       $E4                 d
                    fcb       $A6                 &
                    fcb       $26                 &
                    fcb       $E6                 f
                    fcb       $21                 !
                    fcb       $3D                 =
                    fcb       $E3                 c
                    fcb       $E4                 d
                    fcb       $2B                 +
                    fcb       $0C
                    fcb       $68                 h
                    fcb       $64                 d
                    fcb       $69                 i
                    fcb       $63                 c
                    fcb       $69                 i
                    fcb       $62                 b
                    fcb       $59                 Y
                    fcb       $49                 I
                    fcb       $6A                 j
                    fcb       $25                 %
                    fcb       $29                 )
                    fcb       $17
                    fcb       $ED                 m
                    fcb       $26                 &
                    fcb       $EC                 l
                    fcb       $62                 b
                    fcb       $C3                 C
                    fcb       $00
                    fcb       $01
                    fcb       $24                 $
                    fcb       $13
                    fcb       $6C                 l
                    fcb       $27                 '
                    fcb       $26                 &
                    fcb       $11
                    fcb       $6C                 l
                    fcb       $26                 &
                    fcb       $26                 &
                    fcb       $0D
                    fcb       $66                 f
                    fcb       $26                 &
                    fcb       $6C                 l
                    fcb       $25                 %
                    fcb       $28                 (
                    fcb       $07
                    fcb       $32                 2
                    fcb       $67                 g
                    fcb       $16
                    fcb       $FE
                    fcb       $EA                 j
                    fcb       $C4                 D
                    fcb       $FE
                    fcb       $DA                 Z
                    fcb       $2D                 -
                    fcb       $ED                 m
                    fcb       $28                 (
                    fcb       $32                 2
                    fcb       $67                 g
                    fcb       $16
                    fcb       $FE
                    fcb       $03
                    fcb       $34                 4
                    fcb       $60                 `
                    fcb       $31                 1
                    fcb       $66                 f
                    fcb       $A6                 &
                    fcb       $21                 !
                    fcb       $27                 '
                    fcb       $02
                    fcb       $A6                 &
                    fcb       $26                 &
                    fcb       $10
                    fcb       $27                 '
                    fcb       $FE
                    fcb       $C4                 D
                    fcb       $A6                 &
                    fcb       $25                 %
                    fcb       $A0
                    fcb       $A4                 $
                    fcb       $10
                    fcb       $29                 )
                    fcb       $FE
                    fcb       $C9                 I
                    fcb       $A7                 '
                    fcb       $25                 %
                    fcb       $86
                    fcb       $21                 !
                    fcb       $E6                 f
                    fcb       $24                 $
                    fcb       $E8                 h
                    fcb       $29                 )
                    fcb       $C4                 D
                    fcb       $01
                    fcb       $DD                 ]
                    fcb       $0A
                    fcb       $64                 d
                    fcb       $21                 !
                    fcb       $66                 f
                    fcb       $22                 "
                    fcb       $66                 f
                    fcb       $23                 #
                    fcb       $66                 f
                    fcb       $24                 $
                    fcb       $EC                 l
                    fcb       $26                 &
                    fcb       $AE                 .
                    fcb       $28                 (
                    fcb       $44                 D
                    fcb       $56                 V
                    fcb       $1E
                    fcb       $01
                    fcb       $46                 F
                    fcb       $56                 V
                    fcb       $6F                 o
                    fcb       $29                 )
                    fcb       $20
                    fcb       $02
                    fcb       $1E
                    fcb       $01
                    fcb       $A3                 #
                    fcb       $23                 #
                    fcb       $1E
                    fcb       $01
                    fcb       $24                 $
                    fcb       $03
                    fcb       $83
                    fcb       $00
                    fcb       $01
                    fcb       $A3                 #
                    fcb       $21                 !
                    fcb       $27                 '
                    fcb       $2F                 /
                    fcb       $2B                 +
                    fcb       $29                 )
                    fcb       $1A
                    fcb       $01
                    fcb       $0A
                    fcb       $0A
                    fcb       $27                 '
                    fcb       $74                 t
                    fcb       $69                 i
                    fcb       $29                 )
                    fcb       $69                 i
                    fcb       $28                 (
                    fcb       $69                 i
                    fcb       $27                 '
                    fcb       $69                 i
                    fcb       $26                 &
                    fcb       $1E
                    fcb       $01
                    fcb       $58                 X
                    fcb       $49                 I
                    fcb       $1E
                    fcb       $01
                    fcb       $59                 Y
                    fcb       $49                 I
                    fcb       $24                 $
                    fcb       $D7                 W
                    fcb       $1E
                    fcb       $01
                    fcb       $E3                 c
                    fcb       $23                 #
                    fcb       $1E
                    fcb       $01
                    fcb       $24                 $
                    fcb       $03
                    fcb       $C3                 C
                    fcb       $00
                    fcb       $01
                    fcb       $E3                 c
                    fcb       $21                 !
                    fcb       $27                 '
                    fcb       $06
                    fcb       $2A                 *
                    fcb       $D7                 W
                    fcb       $1C
                    fcb       $FE
                    fcb       $20
                    fcb       $D5                 U
                    fcb       $30                 0
                    fcb       $84
                    fcb       $26                 &
                    fcb       $CF                 O
                    fcb       $D6                 V
                    fcb       $0A
                    fcb       $5A                 Z
                    fcb       $C0                 @
                    fcb       $10
                    fcb       $2D                 -
                    fcb       $17
                    fcb       $C0                 @
                    fcb       $08
                    fcb       $2D                 -
                    fcb       $08
                    fcb       $D7                 W
                    fcb       $0A
                    fcb       $A6                 &
                    fcb       $29                 )
                    fcb       $C6                 F
                    fcb       $80
                    fcb       $20
                    fcb       $29                 )
                    fcb       $CB                 K
                    fcb       $08
                    fcb       $D7                 W
                    fcb       $0A
                    fcb       $CC                 L
                    fcb       $80
                    fcb       $00
                    fcb       $AE                 .
                    fcb       $28                 (
                    fcb       $20
                    fcb       $20
                    fcb       $CB                 K
                    fcb       $08
                    fcb       $2D                 -
                    fcb       $0A
                    fcb       $D7                 W
                    fcb       $0A
                    fcb       $AE                 .
                    fcb       $27                 '
                    fcb       $A6                 &
                    fcb       $29                 )
                    fcb       $C6                 F
                    fcb       $80
                    fcb       $20
                    fcb       $12
                    fcb       $CB                 K
                    fcb       $07
                    fcb       $D7                 W
                    fcb       $0A
                    fcb       $AE                 .
                    fcb       $26                 &
                    fcb       $EC                 l
                    fcb       $28                 (
                    fcb       $1A
                    fcb       $01
                    fcb       $59                 Y
                    fcb       $49                 I
                    fcb       $1E
                    fcb       $01
                    fcb       $59                 Y
                    fcb       $49                 I
                    fcb       $1E
                    fcb       $01
                    fcb       $1C
                    fcb       $FE
                    fcb       $0A
                    fcb       $0A
                    fcb       $2A                 *
                    fcb       $F2                 r
                    fcb       $1E
                    fcb       $01
                    fcb       $4D                 M
                    fcb       $20
                    fcb       $04
                    fcb       $AE                 .
                    fcb       $28                 (
                    fcb       $EC                 l
                    fcb       $26                 &
                    fcb       $2B                 +
                    fcb       $0E
                    fcb       $1E
                    fcb       $01
                    fcb       $59                 Y
                    fcb       $49                 I
                    fcb       $1E
                    fcb       $01
                    fcb       $59                 Y
                    fcb       $49                 I
                    fcb       $6A                 j
                    fcb       $25                 %
                    fcb       $10
                    fcb       $29                 )
                    fcb       $FD
                    fcb       $FB
                    fcb       $1E
                    fcb       $01
                    fcb       $C3                 C
                    fcb       $00
                    fcb       $01
                    fcb       $1E
                    fcb       $01
                    fcb       $24                 $
                    fcb       $0C
                    fcb       $C3                 C
                    fcb       $00
                    fcb       $01
                    fcb       $24                 $
                    fcb       $07
                    fcb       $46                 F
                    fcb       $6C                 l
                    fcb       $25                 %
                    fcb       $10
                    fcb       $29                 )
                    fcb       $FD
                    fcb       $F3                 s
                    fcb       $ED                 m
                    fcb       $26                 &
                    fcb       $1F
                    fcb       $10
                    fcb       $C4                 D
                    fcb       $FE
                    fcb       $DA                 Z
                    fcb       $0B
                    fcb       $ED                 m
                    fcb       $28                 (
                    fcb       $6C                 l
                    fcb       $25                 %
                    fcb       $10
                    fcb       $29                 )
                    fcb       $FD
                    fcb       $E3                 c
                    fcb       $16
                    fcb       $FD
                    fcb       $04
                    fcb       $E6                 f
                    fcb       $62                 b
                    fcb       $2E                 .
                    fcb       $04
                    fcb       $4F                 O
                    fcb       $5F                 _
                    fcb       $20
                    fcb       $3E                 >
                    fcb       $C0                 @
                    fcb       $10
                    fcb       $22                 "
                    fcb       $F8                 x
                    fcb       $25                 %
                    fcb       $0E
                    fcb       $64                 d
                    fcb       $66                 f
                    fcb       $24                 $
                    fcb       $F2                 r
                    fcb       $EC                 l
                    fcb       $63                 c
                    fcb       $10
                    fcb       $83
                    fcb       $80
                    fcb       $00
                    fcb       $26                 &
                    fcb       $EA                 j
                    fcb       $20
                    fcb       $2A                 *
                    fcb       $C1                 A
                    fcb       $F8                 x
                    fcb       $22                 "
                    fcb       $0E
                    fcb       $D7                 W
                    fcb       $0A
                    fcb       $EC                 l
                    fcb       $63                 c
                    fcb       $ED                 m
                    fcb       $64                 d
                    fcb       $6F                 o
                    fcb       $63                 c
                    fcb       $D6                 V
                    fcb       $0A
                    fcb       $CB                 K
                    fcb       $08
                    fcb       $27                 '
                    fcb       $09
                    fcb       $64                 d
                    fcb       $63                 c
                    fcb       $66                 f
                    fcb       $64                 d
                    fcb       $66                 f
                    fcb       $65                 e
                    fcb       $5C                 \
                    fcb       $26                 &
                    fcb       $F7                 w
                    fcb       $EC                 l
                    fcb       $63                 c
                    fcb       $20
                    fcb       $03
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $01
                    fcb       $64                 d
                    fcb       $66                 f
                    fcb       $24                 $
                    fcb       $04
                    fcb       $40                 @
                    fcb       $50                 P
                    fcb       $82
                    fcb       $00
                    fcb       $ED                 m
                    fcb       $65                 e
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $32                 2
                    fcb       $65                 e
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $DF                 _
                    fcb       $10
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $9F
                    fcb       $1E
                    fcb       $32                 2
                    fcb       $7F
                    fcb       $33                 3
                    fcb       $E4                 d
                    fcb       $20
                    fcb       $16
                    fcb       $DF                 _
                    fcb       $10
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $9F
                    fcb       $1E
                    fcb       $32                 2
                    fcb       $7F
                    fcb       $EC                 l
                    fcb       $63                 c
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $EC                 l
                    fcb       $65                 e
                    fcb       $ED                 m
                    fcb       $62                 b
                    fcb       $A6                 &
                    fcb       $67                 g
                    fcb       $A7                 '
                    fcb       $64                 d
                    fcb       $33                 3
                    fcb       $65                 e
                    fcb       $8D
                    fcb       $06
                    fcb       $DE                 ^
                    fcb       $10
                    fcb       $9E
                    fcb       $1E
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $AE                 .
                    fcb       $43                 C
                    fcb       $4F                 O
                    fcb       $5F                 _
                    fcb       $ED                 m
                    fcb       $43                 C
                    fcb       $ED                 m
                    fcb       $41                 A
                    fcb       $E7                 g
                    fcb       $C4                 D
                    fcb       $30                 0
                    fcb       $84
                    fcb       $27                 '
                    fcb       $24                 $
                    fcb       $1F
                    fcb       $10
                    fcb       $8E
                    fcb       $00
                    fcb       $10
                    fcb       $4D                 M
                    fcb       $2A                 *
                    fcb       $06
                    fcb       $40                 @
                    fcb       $50                 P
                    fcb       $82
                    fcb       $00
                    fcb       $6C                 l
                    fcb       $44                 D
                    fcb       $4D                 M
                    fcb       $26                 &
                    fcb       $04
                    fcb       $30                 0
                    fcb       $18
                    fcb       $1E
                    fcb       $89
                    fcb       $4D                 M
                    fcb       $2B                 +
                    fcb       $06
                    fcb       $30                 0
                    fcb       $1F
                    fcb       $58                 X
                    fcb       $49                 I
                    fcb       $2A                 *
                    fcb       $FA                 z
                    fcb       $ED                 m
                    fcb       $41                 A
                    fcb       $1F
                    fcb       $10
                    fcb       $E7                 g
                    fcb       $C4                 D
                    fcb       $39                 9
                    fcb       $AE                 .
                    fcb       $22                 "
                    fcb       $DC                 \
                    fcb       $2A                 *
                    fcb       $C3                 C
                    fcb       $00
                    fcb       $01
                    fcb       $DD                 ]
                    fcb       $2A                 *
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $10
                    fcb       $A3                 #
                    fcb       $A4                 $
                    fcb       $22                 "
                    fcb       $03
                    fcb       $A6                 &
                    fcb       $1F
                    fcb       $39                 9
                    fcb       $4F                 O
                    fcb       $39                 9
L0D64               fcb       $34                 4
                    fcb       $60                 `
                    fcb       $31                 1
                    fcb       $66                 f
                    fcb       $4F                 O
                    fcb       $5F                 _
                    fcb       $D7                 W
                    fcb       $42                 B
                    fcb       $D7                 W
                    fcb       $43                 C
                    fcb       $D7                 W
                    fcb       $32                 2
                    fcb       $D7                 W
                    fcb       $44                 D
                    fcb       $D7                 W
                    fcb       $45                 E
                    fcb       $D7                 W
                    fcb       $46                 F
                    fcb       $D7                 W
                    fcb       $40                 @
                    fcb       $DD                 ]
                    fcb       $2A                 *
                    fcb       $34                 4
                    fcb       $06
                    fcb       $34                 4
                    fcb       $06
                    fcb       $34                 4
                    fcb       $04
                    fcb       $8D
                    fcb       $CD                 M
                    fcb       $81
                    fcb       $20
                    fcb       $27                 '
                    fcb       $FA                 z
                    fcb       $81
                    fcb       $2B                 +
                    fcb       $27                 '
                    fcb       $06
                    fcb       $81
                    fcb       $2D                 -
                    fcb       $26                 &
                    fcb       $04
                    fcb       $0C
                    fcb       $42                 B
                    fcb       $8D
                    fcb       $BD                 =
                    fcb       $81
                    fcb       $2E                 .
                    fcb       $26                 &
                    fcb       $12
                    fcb       $D6                 V
                    fcb       $44                 D
                    fcb       $26                 &
                    fcb       $71                 q
                    fcb       $0C
                    fcb       $44                 D
                    fcb       $4F                 O
                    fcb       $5F                 _
                    fcb       $34                 4
                    fcb       $06
                    fcb       $34                 4
                    fcb       $06
                    fcb       $34                 4
                    fcb       $04
                    fcb       $D7                 W
                    fcb       $46                 F
                    fcb       $20
                    fcb       $E8                 h
                    fcb       $81
                    fcb       $45                 E
                    fcb       $27                 '
                    fcb       $04
                    fcb       $81
                    fcb       $65                 e
                    fcb       $26                 &
                    fcb       $33                 3
                    fcb       $D6                 V
                    fcb       $32                 2
                    fcb       $27                 '
                    fcb       $57                 W
                    fcb       $0F
                    fcb       $32                 2
                    fcb       $8D
                    fcb       $97
                    fcb       $81
                    fcb       $2B                 +
                    fcb       $27                 '
                    fcb       $06
                    fcb       $81
                    fcb       $2D                 -
                    fcb       $26                 &
                    fcb       $04
                    fcb       $0C
                    fcb       $43                 C
                    fcb       $8D
                    fcb       $8B
                    fcb       $81
                    fcb       $30                 0
                    fcb       $25                 %
                    fcb       $3F                 ?
                    fcb       $81
                    fcb       $39                 9
                    fcb       $22                 "
                    fcb       $3B                 ;
                    fcb       $97
                    fcb       $32                 2
                    fcb       $84
                    fcb       $0F
                    fcb       $34                 4
                    fcb       $02
                    fcb       $86
                    fcb       $0A
                    fcb       $D6                 V
                    fcb       $45                 E
                    fcb       $3D                 =
                    fcb       $EB                 k
                    fcb       $E0                 `
                    fcb       $89
                    fcb       $00
                    fcb       $27                 '
                    fcb       $02
                    fcb       $C6                 F
                    fcb       $FF
                    fcb       $D7                 W
                    fcb       $45                 E
                    fcb       $20
                    fcb       $DF                 _
                    fcb       $81
                    fcb       $30                 0
                    fcb       $25                 %
                    fcb       $20
                    fcb       $81
                    fcb       $39                 9
                    fcb       $22                 "
                    fcb       $1C
                    fcb       $97
                    fcb       $32                 2
                    fcb       $86
                    fcb       $01
                    fcb       $5F                 _
                    fcb       $8D
                    fcb       $5A                 Z
                    fcb       $25                 %
                    fcb       $17
                    fcb       $D6                 V
                    fcb       $32                 2
                    fcb       $C4                 D
                    fcb       $0F
                    fcb       $4F                 O
                    fcb       $34                 4
                    fcb       $06
                    fcb       $17
                    fcb       $FE
                    fcb       $F4                 t
                    fcb       $17
                    fcb       $FB
                    fcb       $8F
                    fcb       $25                 %
                    fcb       $08
                    fcb       $0C
                    fcb       $46                 F
                    fcb       $20
                    fcb       $89
                    fcb       $96
                    fcb       $32                 2
                    fcb       $26                 &
                    fcb       $0D
                    fcb       $30                 0
                    fcb       $24                 $
                    fcb       $C6                 F
                    fcb       $05
                    fcb       $6F                 o
                    fcb       $80
                    fcb       $5A                 Z
                    fcb       $26                 &
                    fcb       $FB
                    fcb       $32                 2
                    fcb       $3A                 :
                    fcb       $20
                    fcb       $2A                 *
                    fcb       $96
                    fcb       $44                 D
                    fcb       $27                 '
                    fcb       $0D
                    fcb       $96
                    fcb       $46                 F
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $8D
                    fcb       $2A                 *
                    fcb       $25                 %
                    fcb       $E7                 g
                    fcb       $17
                    fcb       $FB
                    fcb       $69                 i
                    fcb       $25                 %
                    fcb       $E2                 b
                    fcb       $96
                    fcb       $45                 E
                    fcb       $D6                 V
                    fcb       $43                 C
                    fcb       $8D
                    fcb       $1D
                    fcb       $25                 %
                    fcb       $DA                 Z
                    fcb       $A6                 &
                    fcb       $64                 d
                    fcb       $9A
                    fcb       $42                 B
                    fcb       $A7                 '
                    fcb       $64                 d
                    fcb       $30                 0
                    fcb       $24                 $
                    fcb       $C6                 F
                    fcb       $05
                    fcb       $35                 5
                    fcb       $02
                    fcb       $A7                 '
                    fcb       $80
                    fcb       $5A                 Z
                    fcb       $26                 &
                    fcb       $F9                 y
                    fcb       $35                 5
                    fcb       $60                 `
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $32                 2
                    fcb       $66                 f
                    fcb       $0C
                    fcb       $40                 @
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $9F
                    fcb       $0C
                    fcb       $35                 5
                    fcb       $40                 @
                    fcb       $4D                 M
                    fcb       $27                 '
                    fcb       $2D                 -
                    fcb       $30                 0
                    fcb       $8C
                    fcb       $2F                 /
                    fcb       $DD                 ]
                    fcb       $0E
                    fcb       $81
                    fcb       $13
                    fcb       $23                 #
                    fcb       $02
                    fcb       $86
                    fcb       $13
                    fcb       $C6                 F
                    fcb       $05
                    fcb       $3D                 =
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $C6                 F
                    fcb       $05
                    fcb       $A6                 &
                    fcb       $82
                    fcb       $34                 4
                    fcb       $02
                    fcb       $5A                 Z
                    fcb       $26                 &
                    fcb       $F9                 y
                    fcb       $D6                 V
                    fcb       $0F
                    fcb       $26                 &
                    fcb       $05
                    fcb       $17
                    fcb       $FB
                    fcb       $F8                 x
                    fcb       $20
                    fcb       $03
                    fcb       $17
                    fcb       $FD
                    fcb       $2D                 -
                    fcb       $25                 %
                    fcb       $07
                    fcb       $DC                 \
                    fcb       $0E
                    fcb       $80
                    fcb       $13
                    fcb       $22                 "
                    fcb       $D3                 S
                    fcb       $5F                 _
                    fcb       $9E
                    fcb       $0C
                    fcb       $6E                 n
                    fcb       $C4                 D
                    fcb       $04
                    fcb       $A0
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $07
                    fcb       $C8                 H
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $0A
                    fcb       $FA                 z
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $0E
                    fcb       $9C
                    fcb       $40                 @
                    fcb       $00
                    fcb       $00
                    fcb       $11
                    fcb       $C3                 C
                    fcb       $50                 P
                    fcb       $00
                    fcb       $00
                    fcb       $14
                    fcb       $F4                 t
                    fcb       $24                 $
                    fcb       $00
                    fcb       $00
                    fcb       $18
                    fcb       $98
                    fcb       $96
                    fcb       $80
                    fcb       $00
                    fcb       $1B
                    fcb       $BE                 >
                    fcb       $BC                 <
                    fcb       $20
                    fcb       $00
                    fcb       $1E
                    fcb       $EE                 n
                    fcb       $6B                 k
                    fcb       $28                 (
                    fcb       $00
                    fcb       $22                 "
                    fcb       $95
                    fcb       $02
                    fcb       $F9                 y
                    fcb       $00
                    fcb       $25                 %
                    fcb       $BA                 :
                    fcb       $43                 C
                    fcb       $B7                 7
                    fcb       $40                 @
                    fcb       $28                 (
                    fcb       $E8                 h
                    fcb       $D4                 T
                    fcb       $A5                 %
                    fcb       $10
                    fcb       $2C                 ,
                    fcb       $91
                    fcb       $84
                    fcb       $E7                 g
                    fcb       $2A                 *
                    fcb       $2F                 /
                    fcb       $B5                 5
                    fcb       $E6                 f
                    fcb       $20
                    fcb       $F4                 t
                    fcb       $32                 2
                    fcb       $E3                 c
                    fcb       $5F                 _
                    fcb       $A9                 )
                    fcb       $32                 2
                    fcb       $36                 6
                    fcb       $8E
                    fcb       $1B
                    fcb       $C9                 I
                    fcb       $C0                 @
                    fcb       $39                 9
                    fcb       $B1                 1
                    fcb       $A2                 "
                    fcb       $BC                 <
                    fcb       $2E                 .
                    fcb       $3C                 <
                    fcb       $DE                 ^
                    fcb       $0B
                    fcb       $6B                 k
                    fcb       $3A                 :
                    fcb       $40                 @
                    fcb       $8A
                    fcb       $C7                 G
                    fcb       $23                 #
                    fcb       $04
                    fcb       $E6                 f
                    fcb       $A4                 $
                    fcb       $2E                 .
                    fcb       $12
                    fcb       $2B                 +
                    fcb       $04
                    fcb       $A6                 &
                    fcb       $21                 !
                    fcb       $2B                 +
                    fcb       $03
                    fcb       $5F                 _
                    fcb       $20
                    fcb       $02
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $4F                 O
                    fcb       $ED                 m
                    fcb       $42                 B
                    fcb       $5F                 _
                    fcb       $ED                 m
                    fcb       $C4                 D
                    fcb       $39                 9
                    fcb       $C0                 @
                    fcb       $20
                    fcb       $22                 "
                    fcb       $2D                 -
                    fcb       $D7                 W
                    fcb       $2A                 *
                    fcb       $EC                 l
                    fcb       $21                 !
                    fcb       $ED                 m
                    fcb       $C4                 D
                    fcb       $EC                 l
                    fcb       $23                 #
                    fcb       $C5                 E
                    fcb       $01
                    fcb       $26                 &
                    fcb       $21                 !
                    fcb       $0D
                    fcb       $2A                 *
                    fcb       $27                 '
                    fcb       $19
                    fcb       $64                 d
                    fcb       $C4                 D
                    fcb       $66                 f
                    fcb       $41                 A
                    fcb       $46                 F
                    fcb       $56                 V
                    fcb       $0C
                    fcb       $2A                 *
                    fcb       $26                 &
                    fcb       $F6                 v
                    fcb       $24                 $
                    fcb       $0D
                    fcb       $C3                 C
                    fcb       $00
                    fcb       $01
                    fcb       $26                 &
                    fcb       $08
                    fcb       $6C                 l
                    fcb       $41                 A
                    fcb       $26                 &
                    fcb       $04
                    fcb       $6C                 l
                    fcb       $C4                 D
                    fcb       $27                 '
                    fcb       $04
                    fcb       $ED                 m
                    fcb       $42                 B
                    fcb       $5F                 _
                    fcb       $39                 9
                    fcb       $8D
                    fcb       $C1                 A
                    fcb       $53                 S
                    fcb       $39                 9
                    fcb       $EC                 l
                    fcb       $C4                 D
                    fcb       $27                 '
                    fcb       $0A
                    fcb       $ED                 m
                    fcb       $21                 !
                    fcb       $EC                 l
                    fcb       $42                 B
                    fcb       $ED                 m
                    fcb       $23                 #
                    fcb       $C6                 F
                    fcb       $20
                    fcb       $20
                    fcb       $0D
                    fcb       $ED                 m
                    fcb       $23                 #
                    fcb       $EC                 l
                    fcb       $42                 B
                    fcb       $26                 &
                    fcb       $03
                    fcb       $ED                 m
                    fcb       $A4                 $
                    fcb       $39                 9
                    fcb       $ED                 m
                    fcb       $21                 !
                    fcb       $C6                 F
                    fcb       $10
                    fcb       $E7                 g
                    fcb       $A4                 $
                    fcb       $6D                 m
                    fcb       $21                 !
                    fcb       $2B                 +
                    fcb       $0C
                    fcb       $6A                 j
                    fcb       $A4                 $
                    fcb       $68                 h
                    fcb       $24                 $
                    fcb       $69                 i
                    fcb       $23                 #
                    fcb       $69                 i
                    fcb       $22                 "
                    fcb       $69                 i
                    fcb       $21                 !
                    fcb       $2A                 *
                    fcb       $F4                 t
                    fcb       $E6                 f
                    fcb       $24                 $
                    fcb       $C4                 D
                    fcb       $FE
                    fcb       $E7                 g
                    fcb       $24                 $
                    fcb       $39                 9
                    fcb       $34                 4
                    fcb       $60                 `
                    fcb       $AE                 .
                    fcb       $6B                 k
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $C5                 E
                    fcb       $0C
                    fcb       $26                 &
                    fcb       $0A
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $56                 V
                    fcb       $EE                 n
                    fcb       $62                 b
                    fcb       $17
                    fcb       $F7                 w
                    fcb       $79                 y
                    fcb       $20
                    fcb       $46                 F
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $C4                 D
                    fcb       $FE
                    fcb       $CA                 J
                    fcb       $80
                    fcb       $E7                 g
                    fcb       $0B
                    fcb       $31                 1
                    fcb       $66                 f
                    fcb       $33                 3
                    fcb       $06
                    fcb       $17
                    fcb       $FF
                    fcb       $5E                 ^
                    fcb       $25                 %
                    fcb       $30                 0
                    fcb       $32                 2
                    fcb       $7B
                    fcb       $31                 1
                    fcb       $E4                 d
                    fcb       $8D
                    fcb       $A1                 !
                    fcb       $EC                 l
                    fcb       $04
                    fcb       $34                 4
                    fcb       $06
                    fcb       $17
                    fcb       $FD
                    fcb       $5D                 ]
                    fcb       $17
                    fcb       $FA                 z
                    fcb       $D3                 S
                    fcb       $DE                 ^
                    fcb       $02
                    fcb       $33                 3
                    fcb       $C8                 H
                    fcb       $2E                 .
                    fcb       $17
                    fcb       $FF
                    fcb       $44                 D
                    fcb       $32                 2
                    fcb       $65                 e
                    fcb       $25                 %
                    fcb       $14
                    fcb       $AE                 .
                    fcb       $6B                 k
                    fcb       $A6                 &
                    fcb       $0C
                    fcb       $9E
                    fcb       $2E                 .
                    fcb       $DE                 ^
                    fcb       $30                 0
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $88
                    fcb       $24                 $
                    fcb       $0C
                    fcb       $D7                 W
                    fcb       $33                 3
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $53                 S
                    fcb       $20
                    fcb       $B8                 8
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $54                 T
                    fcb       $20
                    fcb       $B3                 3
                    fcb       $35                 5
                    fcb       $60                 `
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $32                 2
                    fcb       $69                 i
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $35                 5
                    fcb       $06
                    fcb       $A8                 (
                    fcb       $E4                 d
                    fcb       $E8                 h
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $09
                    fcb       $53                 S
                    fcb       $17
                    fcb       $FA                 z
                    fcb       $98
                    fcb       $16
                    fcb       $09
                    fcb       $4D                 M
                    fcb       $A6                 &
                    fcb       $64                 d
                    fcb       $88
                    fcb       $01
                    fcb       $A7                 '
                    fcb       $64                 d
                    fcb       $16
                    fcb       $09
                    fcb       $44                 D
                    fcb       $17
                    fcb       $F9                 y
                    fcb       $58                 X
                    fcb       $16
                    fcb       $09
                    fcb       $3E                 >
                    fcb       $17
                    fcb       $FC
                    fcb       $BC                 <
                    fcb       $16
                    fcb       $09
                    fcb       $38                 8
                    fcb       $17
                    fcb       $F9                 y
                    fcb       $A2                 "
                    fcb       $16
                    fcb       $09
                    fcb       $32                 2
                    fcb       $17
                    fcb       $FB
                    fcb       $B1                 1
                    fcb       $16
                    fcb       $09
                    fcb       $2C                 ,
                    fcb       $17
                    fcb       $FC
                    fcb       $F8                 x
                    fcb       $16
                    fcb       $09
                    fcb       $26                 &
                    fcb       $17
                    fcb       $FC
                    fcb       $FE
                    fcb       $16
                    fcb       $09
                    fcb       $20
                    fcb       $31                 1
                    fcb       $21                 !
                    fcb       $16
                    fcb       $09
                    fcb       $1B
                    fcb       $C6                 F
                    fcb       $10
                    fcb       $D7                 W
                    fcb       $0A
                    fcb       $35                 5
                    fcb       $06
                    fcb       $AA                 *
                    fcb       $E8                 h
                    fcb       $1E
                    fcb       $EA                 j
                    fcb       $E8                 h
                    fcb       $1F
                    fcb       $ED                 m
                    fcb       $E8                 h
                    fcb       $1E
                    fcb       $0A
                    fcb       $0A
                    fcb       $26                 &
                    fcb       $F1                 q
                    fcb       $16
                    fcb       $09
                    fcb       $05
                    fcb       $C6                 F
                    fcb       $10
                    fcb       $D7                 W
                    fcb       $0A
                    fcb       $35                 5
                    fcb       $06
                    fcb       $43                 C
                    fcb       $53                 S
                    fcb       $A4                 $
                    fcb       $E8                 h
                    fcb       $1E
                    fcb       $E4                 d
                    fcb       $E8                 h
                    fcb       $1F
                    fcb       $ED                 m
                    fcb       $E8                 h
                    fcb       $1E
                    fcb       $0A
                    fcb       $0A
                    fcb       $26                 &
                    fcb       $EF                 o
                    fcb       $16
                    fcb       $08
                    fcb       $ED                 m
                    fcb       $30                 0
                    fcb       $E8                 h
                    fcb       $20
                    fcb       $EC                 l
                    fcb       $84
                    fcb       $4D                 M
                    fcb       $26                 &
                    fcb       $1B
                    fcb       $54                 T
                    fcb       $54                 T
                    fcb       $54                 T
                    fcb       $53                 S
                    fcb       $A6                 &
                    fcb       $85
                    fcb       $E6                 f
                    fcb       $01
                    fcb       $C4                 D
                    fcb       $07
                    fcb       $30                 0
                    fcb       $8C
                    fcb       $16
                    fcb       $A5                 %
                    fcb       $85
                    fcb       $27                 '
                    fcb       $0A
                    fcb       $32                 2
                    fcb       $E8                 h
                    fcb       $21                 !
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $08
                    fcb       $CA                 J
                    fcb       $32                 2
                    fcb       $E8                 h
                    fcb       $21                 !
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $08
                    fcb       $C2                 B
L1061               fcb       $01
                    fcb       $02
                    fcb       $04
                    fcb       $08
                    fcb       $10
                    fcb       $20
                    fcb       $40                 @
                    fcb       $80
                    fcb       $35                 5
                    fcb       $06
                    fcb       $DD                 ]
                    fcb       $0A
                    fcb       $CC                 L
                    fcb       $00
                    fcb       $00
                    fcb       $8E
                    fcb       $00
                    fcb       $00
                    fcb       $34                 4
                    fcb       $16
                    fcb       $34                 4
                    fcb       $16
                    fcb       $34                 4
                    fcb       $16
                    fcb       $34                 4
                    fcb       $16
                    fcb       $34                 4
                    fcb       $16
                    fcb       $34                 4
                    fcb       $16
                    fcb       $34                 4
                    fcb       $16
                    fcb       $34                 4
                    fcb       $16
                    fcb       $DC                 \
                    fcb       $0A
                    fcb       $4D                 M
                    fcb       $26                 &
                    fcb       $12
                    fcb       $30                 0
                    fcb       $8C
                    fcb       $D6                 V
                    fcb       $C4                 D
                    fcb       $07
                    fcb       $A6                 &
                    fcb       $85
                    fcb       $30                 0
                    fcb       $E8                 h
                    fcb       $20
                    fcb       $D6                 V
                    fcb       $0B
                    fcb       $54                 T
                    fcb       $54                 T
                    fcb       $54                 T
                    fcb       $53                 S
                    fcb       $A7                 '
                    fcb       $85
                    fcb       $16
                    fcb       $08
                    fcb       $86
                    fcb       $17
                    fcb       $F7                 w
                    fcb       $9B
                    fcb       $16
                    fcb       $08
                    fcb       $80
                    fcb       $17
                    fcb       $F7                 w
                    fcb       $BA                 :
                    fcb       $16
                    fcb       $08
                    fcb       $7A                 z
                    fcb       $17
                    fcb       $F7                 w
                    fcb       $81
                    fcb       $16
                    fcb       $08
                    fcb       $74                 t
                    fcb       $9E
                    fcb       $16
                    fcb       $D6                 V
                    fcb       $24                 $
                    fcb       $86
                    fcb       $0A
                    fcb       $3D                 =
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $D7                 W
                    fcb       $4B                 K
                    fcb       $97
                    fcb       $4C                 L
                    fcb       $E6                 f
                    fcb       $09
                    fcb       $D7                 W
                    fcb       $4A                 J
                    fcb       $2B                 +
                    fcb       $1A
                    fcb       $9E
                    fcb       $50                 P
                    fcb       $A1                 !
                    fcb       $85
                    fcb       $27                 '
                    fcb       $19
                    fcb       $25                 %
                    fcb       $12
                    fcb       $9E
                    fcb       $52                 R
                    fcb       $E6                 f
                    fcb       $85
                    fcb       $2B                 +
                    fcb       $0C
                    fcb       $D7                 W
                    fcb       $4A                 J
                    fcb       $9E
                    fcb       $50                 P
                    fcb       $A6                 &
                    fcb       $85
                    fcb       $91
                    fcb       $4C                 L
                    fcb       $27                 '
                    fcb       $07
                    fcb       $25                 %
                    fcb       $EE                 n
                    fcb       $17
                    fcb       $0C
                    fcb       $0A
                    fcb       $D6                 V
                    fcb       $4A                 J
                    fcb       $9E
                    fcb       $4E                 N
                    fcb       $86
                    fcb       $01
                    fcb       $A7                 '
                    fcb       $85
                    fcb       $DC                 \
                    fcb       $4A                 J
                    fcb       $9B
                    fcb       $5A                 Z
                    fcb       $34                 4
                    fcb       $60                 `
                    fcb       $1F
                    fcb       $02
                    fcb       $DE                 ^
                    fcb       $20
                    fcb       $8E
                    fcb       $00
                    fcb       $64                 d
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $ED                 m
                    fcb       $C1                 A
                    fcb       $30                 0
                    fcb       $1E
                    fcb       $26                 &
                    fcb       $F8                 x
                    fcb       $35                 5
                    fcb       $60                 `
                    fcb       $DC                 \
                    fcb       $20
                    fcb       $34                 4
                    fcb       $06
                    fcb       $16
                    fcb       $08
                    fcb       $1C
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $30                 0
                    fcb       $CB                 K
                    fcb       $35                 5
                    fcb       $06
                    fcb       $ED                 m
                    fcb       $84
                    fcb       $35                 5
                    fcb       $02
                    fcb       $A7                 '
                    fcb       $02
                    fcb       $35                 5
                    fcb       $06
                    fcb       $ED                 m
                    fcb       $03
                    fcb       $16
                    fcb       $08
                    fcb       $09
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $30                 0
                    fcb       $CB                 K
                    fcb       $EC                 l
                    fcb       $03
                    fcb       $34                 4
                    fcb       $06
                    fcb       $A6                 &
                    fcb       $02
                    fcb       $34                 4
                    fcb       $02
                    fcb       $EC                 l
                    fcb       $84
                    fcb       $16
                    fcb       $07
                    fcb       $F6                 v
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $8D
                    fcb       $2E                 .
                    fcb       $1F
                    fcb       $10
                    fcb       $E3                 c
                    fcb       $A1                 !
                    fcb       $16
                    fcb       $07
                    fcb       $EB                 k
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $8D
                    fcb       $23                 #
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $E6                 f
                    fcb       $8B
                    fcb       $34                 4
                    fcb       $04
                    fcb       $16
                    fcb       $07
                    fcb       $E0                 `
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $8D
                    fcb       $16
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $EC                 l
                    fcb       $8B
                    fcb       $16
                    fcb       $07
                    fcb       $D3                 S
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $8D
                    fcb       $0B
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $35                 5
                    fcb       $04
                    fcb       $E7                 g
                    fcb       $84
                    fcb       $16
                    fcb       $07
                    fcb       $C6                 F
L115D               fcb       $5D                 ]
                    fcb       $26                 &
                    fcb       $03
                    fcb       $30                 0
                    fcb       $C4                 D
                    fcb       $39                 9
                    fcb       $AE                 .
                    fcb       $45                 E
                    fcb       $5A                 Z
                    fcb       $27                 '
                    fcb       $05
                    fcb       $AE                 .
                    fcb       $05
                    fcb       $5A                 Z
                    fcb       $26                 &
                    fcb       $FB
                    fcb       $39                 9
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $8D
                    fcb       $EB                 k
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $35                 5
                    fcb       $06
                    fcb       $ED                 m
                    fcb       $84
                    fcb       $16
                    fcb       $07
                    fcb       $A6                 &
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $34                 4
                    fcb       $06
                    fcb       $17
                    fcb       $F7                 w
                    fcb       $4E                 N
                    fcb       $35                 5
                    fcb       $06
                    fcb       $E3                 c
                    fcb       $E4                 d
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $07
                    fcb       $96
                    fcb       $32                 2
                    fcb       $61                 a
                    fcb       $E6                 f
                    fcb       $E4                 d
                    fcb       $C4                 D
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $07
                    fcb       $8B
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $D7                 W
                    fcb       $0A
                    fcb       $27                 '
                    fcb       $07
                    fcb       $A6                 &
                    fcb       $A0
                    fcb       $34                 4
                    fcb       $02
                    fcb       $5A                 Z
                    fcb       $26                 &
                    fcb       $F9                 y
                    fcb       $C6                 F
                    fcb       $20
                    fcb       $D0                 P
                    fcb       $0A
                    fcb       $27                 '
                    fcb       $05
                    fcb       $6F                 o
                    fcb       $E2                 b
                    fcb       $5A                 Z
                    fcb       $26                 &
                    fcb       $FB
                    fcb       $16
                    fcb       $07
                    fcb       $70                 p
                    fcb       $AE                 .
                    fcb       $65                 e
                    fcb       $35                 5
                    fcb       $06
                    fcb       $ED                 m
                    fcb       $84
                    fcb       $35                 5
                    fcb       $02
                    fcb       $A7                 '
                    fcb       $02
                    fcb       $35                 5
                    fcb       $06
                    fcb       $ED                 m
                    fcb       $03
                    fcb       $32                 2
                    fcb       $62                 b
                    fcb       $16
                    fcb       $07
                    fcb       $5D                 ]
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $31                 1
                    fcb       $AB                 +
                    fcb       $1F
                    fcb       $20
                    fcb       $96
                    fcb       $4D                 M
                    fcb       $DD                 ]
                    fcb       $6E                 n
                    fcb       $E3                 c
                    fcb       $E4                 d
                    fcb       $E3                 c
                    fcb       $E1                 a
                    fcb       $97
                    fcb       $4C                 L
                    fcb       $D7                 W
                    fcb       $49                 I
                    fcb       $91
                    fcb       $4D                 M
                    fcb       $27                 '
                    fcb       $21                 !
                    fcb       $97
                    fcb       $4D                 M
                    fcb       $D6                 V
                    fcb       $48                 H
                    fcb       $9E
                    fcb       $52                 R
                    fcb       $E6                 f
                    fcb       $85
                    fcb       $D7                 W
                    fcb       $48                 H
                    fcb       $2B                 +
                    fcb       $0A
                    fcb       $9E
                    fcb       $50                 P
                    fcb       $A6                 &
                    fcb       $85
                    fcb       $91
                    fcb       $4C                 L
                    fcb       $27                 '
                    fcb       $07
                    fcb       $25                 %
                    fcb       $EE                 n
                    fcb       $17
                    fcb       $0A
                    fcb       $F3                 s
                    fcb       $D6                 V
                    fcb       $48                 H
                    fcb       $9E
                    fcb       $4E                 N
                    fcb       $86
                    fcb       $01
                    fcb       $A7                 '
                    fcb       $85
                    fcb       $9E
                    fcb       $48                 H
                    fcb       $DC                 \
                    fcb       $5A                 Z
                    fcb       $EC                 l
                    fcb       $8B
                    fcb       $27                 '
                    fcb       $09
                    fcb       $D3                 S
                    fcb       $6E                 n
                    fcb       $97
                    fcb       $4C                 L
                    fcb       $D7                 W
                    fcb       $49                 I
                    fcb       $16
                    fcb       $00
                    fcb       $8C
                    fcb       $DC                 \
                    fcb       $6E                 n
                    fcb       $34                 4
                    fcb       $06
                    fcb       $17
                    fcb       $F4                 t
                    fcb       $5C                 \
                    fcb       $9E
                    fcb       $14
                    fcb       $1E
                    fcb       $12
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $32                 2
                    fcb       $C4                 D
                    fcb       $35                 5
                    fcb       $40                 @
                    fcb       $35                 5
                    fcb       $24                 $
                    fcb       $D7                 W
                    fcb       $24                 $
                    fcb       $20
                    fcb       $25                 %
                    fcb       $32                 2
                    fcb       $C4                 D
                    fcb       $35                 5
                    fcb       $40                 @
                    fcb       $35                 5
                    fcb       $24                 $
                    fcb       $D7                 W
                    fcb       $24                 $
                    fcb       $32                 2
                    fcb       $63                 c
                    fcb       $20
                    fcb       $1B
                    fcb       $32                 2
                    fcb       $C4                 D
                    fcb       $35                 5
                    fcb       $40                 @
                    fcb       $35                 5
                    fcb       $24                 $
                    fcb       $D7                 W
                    fcb       $24                 $
                    fcb       $32                 2
                    fcb       $64                 d
                    fcb       $20
                    fcb       $0F
                    fcb       $E6                 f
                    fcb       $A4                 $
                    fcb       $32                 2
                    fcb       $C4                 D
                    fcb       $35                 5
                    fcb       $40                 @
                    fcb       $35                 5
                    fcb       $22                 "
                    fcb       $97
                    fcb       $24                 $
                    fcb       $4F                 O
                    fcb       $32                 2
                    fcb       $EB                 k
                    fcb       $32                 2
                    fcb       $62                 b
L124C               fcb       $D6                 V
                    fcb       $24                 $
                    fcb       $30                 0
                    fcb       $8D
                    fcb       $0C
                    fcb       $C1                 A
                    fcb       $E1                 a
                    fcb       $84
                    fcb       $27                 '
                    fcb       $BF                 ?
                    fcb       $30                 0
                    fcb       $03
                    fcb       $A6                 &
                    fcb       $84
                    fcb       $81
                    fcb       $FF
                    fcb       $26                 &
                    fcb       $F4                 t
                    fcb       $86
                    fcb       $0A
                    fcb       $D6                 V
                    fcb       $24                 $
                    fcb       $3D                 =
                    fcb       $9E
                    fcb       $16
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $1F
                    fcb       $20
                    fcb       $97
                    fcb       $4C                 L
                    fcb       $97
                    fcb       $4D                 M
                    fcb       $D7                 W
                    fcb       $49                 I
                    fcb       $E6                 f
                    fcb       $08
                    fcb       $D7                 W
                    fcb       $48                 H
                    fcb       $2B                 +
                    fcb       $0A
                    fcb       $9E
                    fcb       $50                 P
                    fcb       $A1                 !
                    fcb       $85
                    fcb       $10
                    fcb       $27                 '
                    fcb       $0A
                    fcb       $5A                 Z
                    fcb       $22                 "
                    fcb       $2B                 +
                    fcb       $16
                    fcb       $0A
                    fcb       $53                 S
                    fcb       $AE                 .
                    fcb       $A1                 !
                    fcb       $20
                    fcb       $08
                    fcb       $AE                 .
                    fcb       $A1                 !
                    fcb       $64                 d
                    fcb       $E0                 `
                    fcb       $10
                    fcb       $25                 %
                    fcb       $06
                    fcb       $95
                    fcb       $1F
                    fcb       $20
                    fcb       $96
                    fcb       $4D                 M
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $1F
                    fcb       $10
                    fcb       $97
                    fcb       $4C                 L
                    fcb       $D7                 W
                    fcb       $49                 I
                    fcb       $96
                    fcb       $4C                 L
                    fcb       $97
                    fcb       $4D                 M
                    fcb       $D6                 V
                    fcb       $48                 H
                    fcb       $9E
                    fcb       $50                 P
                    fcb       $A1                 !
                    fcb       $85
                    fcb       $10
                    fcb       $27                 '
                    fcb       $0A
                    fcb       $37                 7
                    fcb       $25                 %
                    fcb       $15
                    fcb       $9E
                    fcb       $52                 R
                    fcb       $E6                 f
                    fcb       $85
                    fcb       $D7                 W
                    fcb       $48                 H
                    fcb       $2B                 +
                    fcb       $CD                 M
                    fcb       $9E
                    fcb       $50                 P
                    fcb       $A6                 &
                    fcb       $85
                    fcb       $91
                    fcb       $4C                 L
                    fcb       $27                 '
                    fcb       $1A
                    fcb       $25                 %
                    fcb       $EE                 n
                    fcb       $16
                    fcb       $0A
                    fcb       $16
                    fcb       $9E
                    fcb       $54                 T
                    fcb       $E6                 f
                    fcb       $85
                    fcb       $D7                 W
                    fcb       $48                 H
                    fcb       $2B                 +
                    fcb       $B8                 8
                    fcb       $9E
                    fcb       $50                 P
                    fcb       $A6                 &
                    fcb       $85
                    fcb       $91
                    fcb       $4C                 L
                    fcb       $27                 '
                    fcb       $05
                    fcb       $22                 "
                    fcb       $EE                 n
                    fcb       $16
                    fcb       $0A
                    fcb       $01
                    fcb       $16
                    fcb       $0A
                    fcb       $00
                    fcb       $35                 5
                    fcb       $10
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $EC                 l
                    fcb       $03
                    fcb       $34                 4
                    fcb       $06
                    fcb       $A6                 &
                    fcb       $02
                    fcb       $34                 4
                    fcb       $02
                    fcb       $EC                 l
                    fcb       $84
                    fcb       $16
                    fcb       $06
                    fcb       $37                 7
                    fcb       $35                 5
                    fcb       $02
                    fcb       $A0
                    fcb       $E4                 d
                    fcb       $26                 &
                    fcb       $07
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $06
                    fcb       $2C                 ,
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $06
                    fcb       $27                 '
                    fcb       $35                 5
                    fcb       $06
                    fcb       $A3                 #
                    fcb       $E0                 `
                    fcb       $26                 &
                    fcb       $F5                 u
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $06
                    fcb       $1A
                    fcb       $35                 5
                    fcb       $02
                    fcb       $A0
                    fcb       $E4                 d
                    fcb       $27                 '
                    fcb       $07
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $06
                    fcb       $0D
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $06
                    fcb       $08
                    fcb       $35                 5
                    fcb       $06
                    fcb       $A3                 #
                    fcb       $E0                 `
                    fcb       $27                 '
                    fcb       $F5                 u
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $05
                    fcb       $FB
                    fcb       $35                 5
                    fcb       $02
                    fcb       $A0
                    fcb       $E4                 d
                    fcb       $25                 %
                    fcb       $07
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $05
                    fcb       $EE                 n
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $05
                    fcb       $E9                 i
                    fcb       $35                 5
                    fcb       $06
                    fcb       $A3                 #
                    fcb       $E0                 `
                    fcb       $2D                 -
                    fcb       $F5                 u
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $05
                    fcb       $DC                 \
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $05
                    fcb       $D7                 W
                    fcb       $35                 5
                    fcb       $06
                    fcb       $A3                 #
                    fcb       $E0                 `
                    fcb       $2C                 ,
                    fcb       $F5                 u
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $05
                    fcb       $CA                 J
                    fcb       $35                 5
                    fcb       $02
                    fcb       $A0
                    fcb       $E4                 d
                    fcb       $22                 "
                    fcb       $07
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $05
                    fcb       $BD                 =
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $05
                    fcb       $B8                 8
                    fcb       $35                 5
                    fcb       $06
                    fcb       $A3                 #
                    fcb       $E0                 `
                    fcb       $2E                 .
                    fcb       $F5                 u
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $05
                    fcb       $AB                 +
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $05
                    fcb       $A6                 &
                    fcb       $35                 5
                    fcb       $06
                    fcb       $A3                 #
                    fcb       $E0                 `
                    fcb       $2F                 /
                    fcb       $F5                 u
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $05
                    fcb       $99
                    fcb       $8D
                    fcb       $18
                    fcb       $26                 &
                    fcb       $09
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $32                 2
                    fcb       $63                 c
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $05
                    fcb       $8C
                    fcb       $32                 2
                    fcb       $63                 c
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $05
                    fcb       $85
                    fcb       $8D
                    fcb       $04
                    fcb       $26                 &
                    fcb       $EC                 l
                    fcb       $20
                    fcb       $F3                 s
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $34                 4
                    fcb       $60                 `
                    fcb       $AE                 .
                    fcb       $68                 h
                    fcb       $EE                 n
                    fcb       $66                 f
                    fcb       $1F
                    fcb       $02
                    fcb       $C5                 E
                    fcb       $01
                    fcb       $27                 '
                    fcb       $0A
                    fcb       $A6                 &
                    fcb       $80
                    fcb       $A0
                    fcb       $C0                 @
                    fcb       $26                 &
                    fcb       $0E
                    fcb       $31                 1
                    fcb       $3F                 ?
                    fcb       $27                 '
                    fcb       $0A
                    fcb       $EC                 l
                    fcb       $81
                    fcb       $A3                 #
                    fcb       $C1                 A
                    fcb       $26                 &
                    fcb       $04
                    fcb       $31                 1
                    fcb       $3E                 >
                    fcb       $26                 &
                    fcb       $F6                 v
                    fcb       $35                 5
                    fcb       $E0                 `
                    fcb       $DC                 \
                    fcb       $14
                    fcb       $20
                    fcb       $17
                    fcb       $35                 5
                    fcb       $06
                    fcb       $20
                    fcb       $13
                    fcb       $E6                 f
                    fcb       $22                 "
                    fcb       $17
                    fcb       $FD
                    fcb       $88
                    fcb       $EC                 l
                    fcb       $A4                 $
                    fcb       $E3                 c
                    fcb       $23                 #
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $EC                 l
                    fcb       $A4                 $
                    fcb       $31                 1
                    fcb       $25                 %
                    fcb       $20
                    fcb       $0A
                    fcb       $1F
                    fcb       $30                 0
                    fcb       $E3                 c
                    fcb       $A1                 !
                    fcb       $E3                 c
                    fcb       $A1                 !
                    fcb       $1F
                    fcb       $01
                    fcb       $EC                 l
                    fcb       $3C                 <
                    fcb       $10
                    fcb       $9F
                    fcb       $0E
                    fcb       $1F
                    fcb       $02
                    fcb       $C5                 E
                    fcb       $01
                    fcb       $27                 '
                    fcb       $08
                    fcb       $A6                 &
                    fcb       $82
                    fcb       $34                 4
                    fcb       $02
                    fcb       $31                 1
                    fcb       $3F                 ?
                    fcb       $27                 '
                    fcb       $08
                    fcb       $EC                 l
                    fcb       $83
                    fcb       $34                 4
                    fcb       $06
                    fcb       $31                 1
                    fcb       $3E                 >
                    fcb       $26                 &
                    fcb       $F8                 x
                    fcb       $10
                    fcb       $9E
                    fcb       $0E
                    fcb       $16
                    fcb       $05
                    fcb       $19
                    fcb       $C6                 F
                    fcb       $10
                    fcb       $D7                 W
                    fcb       $0A
                    fcb       $30                 0
                    fcb       $E8                 h
                    fcb       $20
                    fcb       $EC                 l
                    fcb       $83
                    fcb       $A3                 #
                    fcb       $88
                    fcb       $20
                    fcb       $26                 &
                    fcb       $0C
                    fcb       $0A
                    fcb       $0A
                    fcb       $26                 &
                    fcb       $F5                 u
                    fcb       $32                 2
                    fcb       $E8                 h
                    fcb       $3F                 ?
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $04
                    fcb       $FF
                    fcb       $32                 2
                    fcb       $E8                 h
                    fcb       $3F                 ?
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $04
                    fcb       $F5                 u
                    fcb       $DC                 \
                    fcb       $14
                    fcb       $E3                 c
                    fcb       $22                 "
                    fcb       $1F
                    fcb       $01
                    fcb       $20
                    fcb       $04
                    fcb       $EC                 l
                    fcb       $22                 "
                    fcb       $30                 0
                    fcb       $CB                 K
                    fcb       $EC                 l
                    fcb       $A4                 $
                    fcb       $31                 1
                    fcb       $24                 $
                    fcb       $8D
                    fcb       $0E
                    fcb       $16
                    fcb       $04
                    fcb       $E0                 `
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $AE                 .
                    fcb       $EB                 k
                    fcb       $8D
                    fcb       $05
                    fcb       $32                 2
                    fcb       $62                 b
                    fcb       $16
                    fcb       $04
                    fcb       $D5                 U
                    fcb       $DF                 _
                    fcb       $10
                    fcb       $10
                    fcb       $9F
                    fcb       $0E
                    fcb       $33                 3
                    fcb       $62                 b
                    fcb       $1F
                    fcb       $02
                    fcb       $C5                 E
                    fcb       $01
                    fcb       $27                 '
                    fcb       $08
                    fcb       $37                 7
                    fcb       $02
                    fcb       $A7                 '
                    fcb       $80
                    fcb       $31                 1
                    fcb       $3F                 ?
                    fcb       $27                 '
                    fcb       $08
                    fcb       $37                 7
                    fcb       $06
                    fcb       $ED                 m
                    fcb       $81
                    fcb       $31                 1
                    fcb       $3E                 >
                    fcb       $26                 &
                    fcb       $F8                 x
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $32                 2
                    fcb       $C4                 D
                    fcb       $10
                    fcb       $9E
                    fcb       $0E
                    fcb       $DE                 ^
                    fcb       $10
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $4F                 O
                    fcb       $34                 4
                    fcb       $60                 `
                    fcb       $AE                 .
                    fcb       $64                 d
                    fcb       $EE                 n
                    fcb       $66                 f
                    fcb       $1F
                    fcb       $02
                    fcb       $C5                 E
                    fcb       $01
                    fcb       $27                 '
                    fcb       $08
                    fcb       $A6                 &
                    fcb       $80
                    fcb       $A7                 '
                    fcb       $C0                 @
                    fcb       $31                 1
                    fcb       $3F                 ?
                    fcb       $27                 '
                    fcb       $08
                    fcb       $EC                 l
                    fcb       $81
                    fcb       $ED                 m
                    fcb       $C1                 A
                    fcb       $31                 1
                    fcb       $3E                 >
                    fcb       $26                 &
                    fcb       $F8                 x
                    fcb       $35                 5
                    fcb       $60                 `
                    fcb       $32                 2
                    fcb       $64                 d
                    fcb       $16
                    fcb       $04
                    fcb       $87
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $4F                 O
                    fcb       $DF                 _
                    fcb       $10
                    fcb       $35                 5
                    fcb       $40                 @
                    fcb       $33                 3
                    fcb       $CB                 K
                    fcb       $1F
                    fcb       $01
                    fcb       $C5                 E
                    fcb       $01
                    fcb       $27                 '
                    fcb       $08
                    fcb       $A6                 &
                    fcb       $C2                 B
                    fcb       $34                 4
                    fcb       $02
                    fcb       $30                 0
                    fcb       $1F
                    fcb       $27                 '
                    fcb       $08
                    fcb       $EC                 l
                    fcb       $C3                 C
                    fcb       $34                 4
                    fcb       $06
                    fcb       $30                 0
                    fcb       $1E
                    fcb       $26                 &
                    fcb       $F8                 x
                    fcb       $DE                 ^
                    fcb       $10
                    fcb       $16
                    fcb       $04
                    fcb       $63                 c
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $C1                 A
                    fcb       $39                 9
                    fcb       $22                 "
                    fcb       $7C
                    fcb       $58                 X
                    fcb       $30                 0
                    fcb       $8C
                    fcb       $04
                    fcb       $EC                 l
                    fcb       $85
                    fcb       $6E                 n
                    fcb       $8B
                    fcb       $00
                    fcb       $CB                 K
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $D6                 V
                    fcb       $00
                    fcb       $DC                 \
                    fcb       $00
                    fcb       $E2                 b
                    fcb       $01
                    fcb       $26                 &
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $E8                 h
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $EE                 n
                    fcb       $00
                    fcb       $F4                 t
                    fcb       $01
                    fcb       $21                 !
                    fcb       $00
                    fcb       $FA                 z
                    fcb       $01
                    fcb       $10
                    fcb       $01
                    fcb       $17
                    fcb       $01
                    fcb       $1D
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $BF                 ?
                    fcb       $01
                    fcb       $2C                 ,
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $84
                    fcb       $00
                    fcb       $C5                 E
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $98
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $B9                 9
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $7E
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $B3                 3
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $74                 t
                    fcb       $00
                    fcb       $77                 w
                    fcb       $16
                    fcb       $09
                    fcb       $A6                 &
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $32                 2
                    fcb       $EB                 k
                    fcb       $16
                    fcb       $03
                    fcb       $D7                 W
                    fcb       $17
                    fcb       $F3                 s
                    fcb       $C3                 C
                    fcb       $16
                    fcb       $03
                    fcb       $D1                 Q
                    fcb       $8D
                    fcb       $03
                    fcb       $16
                    fcb       $03
                    fcb       $CC                 L
                    fcb       $AE                 .
                    fcb       $62                 b
                    fcb       $4F                 O
                    fcb       $E6                 f
                    fcb       $0F
                    fcb       $ED                 m
                    fcb       $64                 d
                    fcb       $6F                 o
                    fcb       $0F
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $32                 2
                    fcb       $64                 d
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $8D
                    fcb       $03
                    fcb       $16
                    fcb       $03
                    fcb       $B8                 8
                    fcb       $AE                 .
                    fcb       $63                 c
                    fcb       $A6                 &
                    fcb       $0A
                    fcb       $64                 d
                    fcb       $62                 b
                    fcb       $25                 %
                    fcb       $04
                    fcb       $8A
                    fcb       $40                 @
                    fcb       $20
                    fcb       $02
                    fcb       $84
                    fcb       $BF                 ?
                    fcb       $A7                 '
                    fcb       $0A
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $32                 2
                    fcb       $65                 e
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $17
                    fcb       $F7                 w
                    fcb       $E0                 `
                    fcb       $16
                    fcb       $03
                    fcb       $9C
                    fcb       $17
                    fcb       $EB                 k
                    fcb       $68                 h
                    fcb       $16
                    fcb       $03
                    fcb       $96
                    fcb       $17
                    fcb       $F9                 y
                    fcb       $D3                 S
                    fcb       $16
                    fcb       $03
                    fcb       $90
                    fcb       $17
                    fcb       $EB                 k
                    fcb       $22                 "
                    fcb       $16
                    fcb       $03
                    fcb       $8A
                    fcb       $AE                 .
                    fcb       $E0                 `
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $C4                 D
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $03
                    fcb       $7F
                    fcb       $17
                    fcb       $EB                 k
                    fcb       $75                 u
                    fcb       $16
                    fcb       $03
                    fcb       $79                 y
                    fcb       $17
                    fcb       $EB                 k
                    fcb       $0F
                    fcb       $16
                    fcb       $03
                    fcb       $73                 s
                    fcb       $17
                    fcb       $EE                 n
                    fcb       $E1                 a
                    fcb       $16
                    fcb       $03
                    fcb       $6D                 m
                    fcb       $17
                    fcb       $EE                 n
                    fcb       $BB                 ;
                    fcb       $16
                    fcb       $03
                    fcb       $67                 g
                    fcb       $17
                    fcb       $ED                 m
                    fcb       $DD                 ]
                    fcb       $16
                    fcb       $03
                    fcb       $61                 a
                    fcb       $17
                    fcb       $ED                 m
                    fcb       $F2                 r
                    fcb       $16
                    fcb       $03
                    fcb       $5B                 [
                    fcb       $0F
                    fcb       $67                 g
                    fcb       $17
                    fcb       $F0                 p
                    fcb       $13
                    fcb       $04
                    fcb       $67                 g
                    fcb       $10
                    fcb       $24                 $
                    fcb       $03
                    fcb       $50                 P
                    fcb       $1F
                    fcb       $20
                    fcb       $96
                    fcb       $4D                 M
                    fcb       $97
                    fcb       $4C                 L
                    fcb       $D7                 W
                    fcb       $49                 I
                    fcb       $16
                    fcb       $06
                    fcb       $F7                 w
                    fcb       $DC                 \
                    fcb       $12
                    fcb       $ED                 m
                    fcb       $F1                 q
                    fcb       $16
                    fcb       $03
                    fcb       $3E                 >
                    fcb       $17
                    fcb       $F0                 p
                    fcb       $30                 0
                    fcb       $16
                    fcb       $03
                    fcb       $38                 8
                    fcb       $C6                 F
                    fcb       $31                 1
                    fcb       $20
                    fcb       $01
                    fcb       $5F                 _
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $E7                 g
                    fcb       $0D
                    fcb       $17
                    fcb       $EC                 l
                    fcb       $6B                 k
                    fcb       $16
                    fcb       $03
                    fcb       $29                 )
                    fcb       $17
                    fcb       $F1                 q
                    fcb       $B7                 7
                    fcb       $16
                    fcb       $03
                    fcb       $23                 #
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $AC                 ,
                    fcb       $A1                 !
                    fcb       $2D                 -
                    fcb       $0B
                    fcb       $AC                 ,
                    fcb       $A1                 !
                    fcb       $2E                 .
                    fcb       $09
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E2                 b
                    fcb       $16
                    fcb       $03
                    fcb       $12
                    fcb       $31                 1
                    fcb       $22                 "
                    fcb       $6F                 o
                    fcb       $E2                 b
                    fcb       $16
                    fcb       $03
                    fcb       $0B
L1618               fcb       $34                 4
                    fcb       $16
                    fcb       $AE                 .
                    fcb       $64                 d
                    fcb       $AF                 /
                    fcb       $62                 b
                    fcb       $1F
                    fcb       $20
                    fcb       $96
                    fcb       $4D                 M
                    fcb       $ED                 m
                    fcb       $64                 d
                    fcb       $35                 5
                    fcb       $86
                    fcb       $E6                 f
                    fcb       $E4                 d
                    fcb       $C4                 D
                    fcb       $FE
                    fcb       $26                 &
                    fcb       $20
                    fcb       $16
                    fcb       $02
                    fcb       $F4                 t
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $9C
                    fcb       $34                 4
                    fcb       $25                 %
                    fcb       $06
                    fcb       $9C
                    fcb       $12
                    fcb       $10
                    fcb       $25                 %
                    fcb       $02
                    fcb       $E8                 h
                    fcb       $8D
                    fcb       $DB                 [
                    fcb       $17
                    fcb       $F0                 p
                    fcb       $29                 )
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $AC                 ,
                    fcb       $A1                 !
                    fcb       $2D                 -
                    fcb       $06
                    fcb       $AC                 ,
                    fcb       $A1                 !
                    fcb       $10
                    fcb       $2F                 /
                    fcb       $02
                    fcb       $D7                 W
                    fcb       $8D
                    fcb       $CA                 J
                    fcb       $17
                    fcb       $F0                 p
                    fcb       $1C
L1651               fcb       $17
                    fcb       $EF                 o
                    fcb       $50                 P
                    fcb       $5F                 _
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $06
L1658               fcb       $50                 P
                    fcb       $41                 A
                    fcb       $53                 S
                    fcb       $43                 C
                    fcb       $41                 A
                    fcb       $4C                 L
                    fcb       $5F                 _
                    fcb       $43                 C
                    fcb       $4F                 O
                    fcb       $4D                 M
                    fcb       $50                 P
                    fcb       $49                 I
                    fcb       $4C                 L
                    fcb       $45                 E
                    fcb       $D2                 R
start               equ       *
                    stu       <u0002
                    sty       <u0000
                    stx       <u003C
                    leax      -$01,y
                    stx       <u003E
                    leax      <L1651,pcr
                    stx       <u0008
                    clr       <u0029
                    clr       <u0033
                    clr       <u0026
                    lda       #$21
                    leax      <L1658,pcr
                    os9       I$Open
                    bcs       L16BB
                    sta       <u0037
                    ldd       <u0002
                    addd      #$00C0
                    std       <u004E
                    addd      #$0080
                    std       <u0050
                    addd      #$0080
                    std       <u0052
                    addd      #$0080
                    std       <u0054
                    addd      #$0080
                    std       <u0056
                    addd      #$0080
                    std       <u0058
                    addd      #$0080
                    std       <u0016
                    ldx       <u0016
                    ldy       #$0100
                    lda       <u0037
                    os9       I$Read
                    bcc       L16CB
L16BB               stb       <u0033
                    ldb       #$CB
                    bra       L16C7
L16C1               ldb       #$CC
                    bra       L16C7
L16C5               ldb       #$CD
L16C7               clra
                    lbra      L0673
L16CB               ldx       <u0016
                    ldd       <$24,x
                    bne       L16C5
                    ldd       <$22,x
                    beq       L16C1
                    tsta
                    bne       L16C1
                    stb       <u0036
                    lda       #$0A
                    mul
                    addd      <u0016
                    lbsr      L1788
                    std       <u005A
                    ldu       <u0016
                    leau      <u0020,u
                    lbsr      L1795
                    ldu       <u005A
                    clrb
L16F1               stb       ,-u
                    cmpu      <u004E
                    bne       L16F1
                    ldx       <u0016
                    ldb       <u0036
                    stb       <u000A
L16FE               pshs      x
                    ldy       #$0020
                    lda       <u0037
                    os9       I$Read
                    bcs       L16BB
                    puls      x
                    ldd       $0A,x
                    std       $06,x
                    lda       #$FF
                    sta       $08,x
                    sta       $09,x
                    leax      $0A,x
                    dec       <u000A
                    bne       L16FE
                    lbsr      L08E4
                    ldd       <u005A
                    std       <u0034
                    addd      #$0800
                    bsr       L1788
                    ldd       <u0000
                    clrb
                    subd      #$8000
                    std       <u005A
                    ldd       <u0000
                    clrb
                    suba      #$08
                    std       <u0000
                    tfr       d,s
                    ldx       <u0058
                    lda       #$FF
                    clrb
L173F               sta       b,x
                    incb
                    cmpb      #$78
                    bne       L173F
                    stb       <u005C
                    ldu       <u0052
L174A               clr       b,x
                    tfr       b,a
                    inca
                    sta       b,u
                    incb
                    bpl       L174A
                    decb
                    lda       #$FF
                    sta       b,u
                    ldb       #$7F
                    stb       <u005D
                    ldd       <u0034
                    addd      #$010E
                    bsr       L1788
                    addd      #$0198
                    bsr       L1788
                    lbsr      L0050
                    ldx       <u0016
                    clra
                    clrb
                    sta       <u0024
                    sta       <u004C
                    sta       <u0049
                    sta       <u004D
                    subd      $02,x
                    leax      d,s
                    pshs      x
                    ldx       <u0016
                    ldd       $04,x
                    lbsr      L062A
                    lbra      L1CD5
L1788               bcs       L1790
                    cmpd      <u0000
                    bhi       L1790
                    rts
L1790               ldb       #$CE
                    lbra      L16C7
L1795               pshs      u,x,b,a
                    clra
                    ldb       ,u
                    tfr       d,x
                    clrb
                    lda       u0001,u
                    tfr       d,u
                    lda       <u0037
                    os9       I$Seek
                    lbcs      L16BB
                    puls      pc,u,x,b,a
L17AC               tfr       y,d
                    lda       <u004D
                    std       <u000A
                    ldy       <u0014
                    ldd       $01,x
                    leax      >L1F13,pcr
                    jsr       d,x
                    ldy       <u000A
                    lbra      L124C
                    ldb       ,y+
                    lbsr      L115D
                    pshs      x
                    ldb       ,y+
                    cmpb      <u0036
                    bcc       L182D
                    leax      >L1F13,pcr
L17D4               cmpb      ,x
                    beq       L17AC
                    leax      $03,x
                    lda       ,x
                    cmpa      #$FF
                    bne       L17D4
                    lda       <u0024
                    pshs      a
                    stb       <u0024
                    tfr       y,d
                    lda       <u004D
                    tfr       d,y
                    puls      a
                    pshs      y,a
L17F0               pshs      u
                    leau      ,s
                    lda       #$0A
                    ldb       <u0024
                    mul
                    ldx       <u0016
                    leax      d,x
                    stx       <u000C
                    clra
                    clrb
                    subd      $02,x
                    leax      d,s
                    pshs      x
                    ldx       <u000C
                    ldd       $04,x
                    lbsr      L062A
                    clra
                    sta       <u0049
                    sta       <u004D
                    sta       <u004C
                    ldb       <u0024
                    lda       #$0A
                    mul
                    ldx       <u0016
                    leax      d,x
                    ldb       $08,x
                    bmi       L1830
                    ldx       <u0050
                    lda       b,x
                    bne       L1830
                    stb       <u0048
                    lbra      L1CD7
L182D               lbra      L1EE7
L1830               lbra      L1CD5
                    lda       ,s
                    lbpl      L1923
                    ldd       #$0000
                    subd      ,s
                    std       ,s
                    lbra      L1923
                    ldd       ,y++
                    leax      d,u
                    puls      b
                    stb       ,x
                    lbra      L1923
                    tfr       u,d
                    addd      ,y++
                    lbra      L1921
                    leas      -$01,s
                    lbra      L1923
                    leas      -$02,s
                    lbra      L1923
                    dec       ,s
                    lbra      L1923
                    inc       ,s
                    lbra      L1923
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    lbra      L1923
                    ldb       ,y+
                    sex
                    addd      <u0014
                    lbra      L1921
                    puls      b
                    stb       [,s++]
                    lbra      L1923
                    clr       ,-s
                    lbra      L1923
                    ldd       ,y++
                    ldx       <u0014
                    ldb       d,x
                    pshs      b
                    lbra      L1923
                    ldd       ,y++
                    ldx       <u0014
                    leax      d,x
                    puls      b
                    stb       ,x
                    lbra      L1923
                    puls      x
                    ldd       ,y++
                    lda       d,x
                    pshs      a
                    lbra      L1923
                    puls      b
                    orb       ,s
                    stb       ,s
                    bra       L1923
                    leas      $01,s
                    bra       L1923
                    ldx       <u0014
                    ldd       $02,x
                    bra       L1921
                    ldx       <u0014
                    ldd       ,x
                    bra       L1921
                    ldd       u0009,u
                    bra       L1921
                    ldd       u0007,u
                    bra       L1921
                    puls      b,a
                    std       u0009,u
                    bra       L1923
                    puls      b,a
                    std       u0007,u
                    bra       L1923
                    ldb       ,y+
                    leax      b,u
                    pshs      x
                    bra       L1923
                    ldb       ,y+
                    lda       b,u
                    pshs      a
                    bra       L1923
                    ldb       ,y+
                    puls      a
                    sta       b,u
                    bra       L1923
                    ldb       #$05
L18F0               lda       ,y+
                    pshs      a
                    decb
                    bne       L18F0
                    bra       L1923
                    ldb       ,y+
                    sex
                    bra       L1921
                    ldx       <u0014
                    ldb       #$B0
                    subb      -$01,y
                    ldd       b,x
                    bra       L1921
                    ldb       #$D0
                    subb      -$01,y
                    ldd       b,u
                    bra       L1921
                    ldb       #$F0
                    subb      -$01,y
                    leax      b,u
                    puls      b,a
                    std       ,x
                    bra       L1923
                    ldb       -$01,y
                    subb      #$90
                    clra
L1921               pshs      b,a
L1923               ldb       ,y+
                    leax      <L19A1,pcr
                    abx
                    abx
                    ldd       ,x
                    jmp       d,x
                    ldb       ,s
                    eorb      #$01
                    stb       ,s
                    bra       L1923
                    ldd       $02,s
                    subd      ,s++
                    std       ,s
                    bra       L1923
                    puls      b,a
                    addd      ,s
                    std       ,s
                    bra       L1923
                    puls      b
                    andb      ,s
                    stb       ,s
                    bra       L1923
                    ldd       ,y++
                    leax      d,u
                    puls      b,a
                    std       ,x
                    bra       L1923
                    ldd       ,y++
                    ldd       d,u
                    bra       L1921
                    ldd       ,s
                    subd      #$0001
                    std       ,s
                    bra       L1923
                    ldd       ,s
                    addd      ,y++
                    std       ,s
                    bra       L1923
                    ldb       ,y+
                    pshs      b
                    bra       L1923
                    ldd       ,y++
                    bra       L1921
                    ldd       ,y++
                    addd      <u0014
                    bra       L1921
                    puls      b,a
                    std       [,s++]
                    bra       L1923
                    ldd       ,y++
                    ldx       <u0014
                    ldd       d,x
                    bra       L1921
                    ldd       ,y++
                    ldx       <u0014
                    leax      d,x
                    puls      b,a
                    std       ,x
                    bra       L1923
                    puls      x
                    ldd       ,y++
                    ldd       d,x
                    bra       L1921
L19A1               ldb       >$67F6
                    tim       #$05,>$3EF6
                    fcb       $8F
                    ldb       >$27F6
                    bmi       L19B3
                    pshu      pc,u,y,x,b,a
                    leax      [a,s]
                    pshs      b,cc
                    leax      [a,s]
L19B6               pshu      pc,u,y,x,b,a
                    abx
                    ldb       >$3E05
                    bvc       L19C3
                    bne       L19B6
                    ror       <u0005
L19C2               bhi       L19C2
                    stb       [a,s]
                    eorb      <u00F6
                    ldd       <u00FE
                    neg       >$FF63
                    stb       >$C0FF
                    asr       $05,x
                    nop
                    ldu       >$60FF
                    rol       [>$6FF6]
                    subb      <u00F6
                    ldx       #$FC74
                    ldb       >$1EFE
                    jmp       >$FE81
                    stu       >$79FE
                    sbca      #$F8
                    leas      [<$3A,s]
                    eorb      >$44FE
                    ror       [w,s]
                    rol       $04,x
                    subb      >$FC31
                    ldu       >$BB01
                    eora      [>$28FE]
                    bita      #$FC
                    leax      [>LDCFE,pcr]
                    jsr       >$FED1
                    bitb      >$FCFE
                    bitb      <u00FE
                    addb      <u00FE
                    ldd       [f,s]
                    asr       [f,s]
                    adda      #$F8
                    bpl       L1A1A
                    ldu       #$04CC
                    lsr       <u00CA
                    stu       >$5402
                    jsr       <u00FE
                    lsrb
                    ldb       >$8EFB
                    std       <u00F7
                    lslb
                    ldu       >$C7F8
                    rolb
                    stb       >$9BF8
                    rolb
                    lsr       <u00B4
                    lsr       <u00B2
                    lsr       <u00B0
                    stu       >$3204
                    cmpx      $04,x
                    ora       [>$3AF7]
                    asra
                    stu       >$3AF8
                    adca      [<-$47,s]
                    lsr       <u009E
                    adcb      >$43F8
                    subb      #$F8
                    subb      <u0004
                    lda       <u00F9
                    clra
                    lsr       <u0092
                    eorb      >$F904
                    ldx       #$048C
                    adcb      >$00F9
                    fcb       $10
                    lsr       <u0086
                    lsr       <u0084
                    lsr       <u0082
                    adcb      >$1A04
                    jmp       >$047C
                    eorb      >$BFF8
                    fcb       $CF                 O
                    lsr       <u0076
                    lsr       <u0074
                    ldb       >$DDF6
                    addb      >$046E
                    lsr       <u006C
                    ldb       >$BDF6
                    eorb      #$04
                    ror       [>$51FD,s]
                    sbcb      #$FE
                    addb      #$F6
                    sbca      #$F9
                    stx       $04,x
                    decb
                    ldu       >$CDF6
                    bsr       L1A89
                    fcb       $52                 R
                    ldu       >$0EFF
                    ror       <u00F8
                    fcb       $42                 B
                    adcb      >$35FD
                    adcb      >$FEF2
                    lsr       <u0046
                    adcb      >$8FFD
                    ldb       [w,s]
                    sbcb      $04,x
                    fcb       $3E                 >
                    adcb      >$21FD
                    sbcb      <u00FE
                    andb      <u00F7
                    ror       <u00F9
                    anda      <u00F6
                    stb       [a,s]
                    lsl       >$FD99
                    addb      >$8904
                    bpl       L1AC0
                    bvc       L1AC2
                    bne       L1AB9
L1AC0               fcb       $4B                 K
                    ldu       >$5BFE
                    rolb
                    ldu       >$57FE
                    fcb       $55                 U
                    ldu       >$53FE
                    fcb       $51                 Q
                    ldu       >$4FFE
                    tsta
                    ldu       >$4BFE
                    rola
                    ldu       >$47FE
                    fcb       $45                 E
                    ldu       >$43FE
                    fcb       $41                 A
                    ldu       >$3FFE
                    mul
                    ldu       >$3BFE
                    rts
                    ldu       >$37FE
                    puls      pc,u,y,x,dp,b,a
                    leau      [w,s]
                    leay      [w,s]
L1AEE               ble       L1AEE
L1AF0               blt       L1AF0
L1AF2               bmi       L1AF2
L1AF4               bvs       L1AF4
L1AF6               beq       L1AF6
L1AF8               bcs       L1AF8
L1AFA               bls       L1AFA
L1AFC               brn       L1AFC
                    tfr       f,e
                    sex
                    std       >$B5FD
                    adca      >$FDF9
                    std       >$F7FD
                    bitb      >$FDF3
                    std       >$F1FD
                    stu       [>L0911,pcr]
                    addb      [>L0515,pcr]
                    stb       [>L0119,pcr]
                    addd      [>LFD1D,pcr]
                    stu       <u00FD
                    std       <u00FD
                    addb      <u00FD
                    adcb      <u00FD
                    stb       <u00FD
                    bitb      <u00FD
                    addd      <u00FD
                    cmpb      <u00FD
                    fcb       $CF                 O
                    std       >$CDFD
                    addb      #$FD
                    adcb      #$FD
                    fcb       $C7                 G
                    std       >$C5FD
                    addd      #$FDC1
                    std       >$BFFD
                    cmpa      #$FD
                    subd      #$FDC3
                    std       >$C1FD
                    stx       >$FDBD
                    std       >$BBFD
                    adca      >$FDB7
                    std       >$B5FD
                    subd      >$FDB1
                    std       >$AFFD
                    jsr       [>LC75D,pcr]
                    adca      [>LC361,pcr]
                    bita      [>LBF65,pcr]
                    cmpa      [>LBB69,pcr]
                    jsr       <u00FD
                    adda      <u00FD
                    adca      <u00FD
                    sta       <u00FD
                    bita      <u00FD
                    subd      <u00FD
                    cmpa      <u00FD
                    fcb       $8F
                    std       >$8DFD
                    adda      #$FD
                    adca      #$FD
                    rola
                    std       >$4DFD
                    adda      #$FD
                    adca      #$FD
                    fcb       $87
                    std       >$85FD
                    subd      #$FD81
                    std       >$7FFD
                    tst       >$FD7B
                    std       >$79FD
                    asr       >$FD75
                    std       >$73FD
                    oim       #$31,>$2216
                    std       >$7D4D
                    bne       L1BC0
                    ldd       <u0018
                    clrb
                    deca
                    subd      <u005A
                    bpl       L1BB2
                    clra
L1BB2               ldx       <u0058
L1BB4               ldb       a,x
                    bmi       L1BBF
                    bsr       L1BD3
                    inca
                    cmpa      #$78
                    bne       L1BB4
L1BBF               rts
L1BC0               ldd       <u0012
                    clrb
                    subd      <u005A
                    bmi       L1BBF
                    ldx       <u0058
L1BC9               ldb       a,x
                    bmi       L1BBF
                    bsr       L1BD3
                    deca
                    bpl       L1BC9
                    rts
L1BD3               pshs      u,y,x,a
                    ldb       #$FF
                    stb       a,x
                    cmpa      <u0048
                    bne       L1BDF
                    inc       <u0067
L1BDF               ldx       <u0056
                    ldb       a,x
                    cmpb      #$FF
                    bne       L1C0C
                    lda       <u005C
                    bmi       L1C07
                    ldx       <u0052
                    cmpa      ,s
                    bne       L1BF9
                    ldb       a,x
                    stb       <u005C
                    puls      pc,u,y,x,a
L1BF7               tfr       b,a
L1BF9               ldb       a,x
                    bmi       L1C07
                    cmpb      ,s
                    bne       L1BF7
                    ldb       b,x
                    stb       a,x
                    puls      pc,u,y,x,a
L1C07               ldb       #$F9
                    lbra      L16C7
L1C0C               cmpb      <u0036
                    bcc       L1C07
                    lda       #$0A
                    mul
                    ldx       <u0016
                    leay      d,x
                    ldx       <u0052
                    ldu       <u0054
                    ldb       $08,y
                    bmi       L1C45
                    cmpb      ,s
                    bne       L1C2F
                    ldb       b,x
                    stb       $08,y
                    bmi       L1C2D
                    lda       #$FF
                    sta       b,u
L1C2D               puls      pc,u,y,x,a
L1C2F               stb       <u0063
                    ldb       b,x
                    bmi       L1C45
                    cmpb      ,s
                    bne       L1C2F
                    lda       b,x
                    ldb       <u0063
                    sta       b,x
                    bmi       L1C43
                    stb       a,u
L1C43               puls      pc,u,y,x,a
L1C45               ldb       $09,y
                    bmi       L1C07
                    cmpb      ,s
                    bne       L1C53
                    lda       b,x
                    sta       $09,y
                    puls      pc,u,y,x,a
L1C53               stb       <u0063
                    ldb       b,x
                    bmi       L1C07
                    cmpb      ,s
                    bne       L1C53
                    lda       b,x
                    ldb       <u0063
                    sta       b,x
                    puls      pc,u,y,x,a
L1C65               pshs      u,y
                    ldd       <u0018
                    clrb
                    suba      #$03
                    subd      <u005A
                    bmi       L1C99
                    sta       <u0061
                    ldd       <u0012
                    clrb
                    inca
                    subd      <u005A
                    bpl       L1C7B
                    clra
L1C7B               cmpa      <u0061
                    bcc       L1C99
                    ldb       #$FF
                    stb       <u0063
                    ldy       <u0058
                    ldu       <u0056
                    ldx       <u0052
L1C8A               ldb       a,y
                    bpl       L1C9B
                    bsr       L1CA6
                    inca
                    cmpa      <u0061
                    bls       L1C8A
L1C95               lda       <u0063
                    sta       <u005C
L1C99               puls      pc,u,y
L1C9B               lda       <u0061
L1C9D               ldb       a,y
                    bpl       L1C95
                    bsr       L1CA6
                    deca
                    bra       L1C9D
L1CA6               pshs      x
                    clr       a,y
                    ldb       <u0063
                    stb       a,x
                    sta       <u0063
                    ldx       <u004E
                    clr       a,x
                    ldb       #$FF
                    stb       a,u
                    puls      pc,x
                    clr       <u0049
                    ldb       <u0048
                    lda       <u004D
                    inca
                    sta       <u004C
                    sta       <u004D
                    ldx       <u0052
                    lda       b,x
                    bmi       L1CD5
                    sta       <u0048
                    ldx       <u0050
                    lda       a,x
                    cmpa      <u004C
                    beq       L1CD7
L1CD5               bsr       L1CE8
L1CD7               ldx       <u004E
                    ldb       <u0048
                    lda       #$01
                    sta       b,x
                    ldd       <u0048
                    adda      <u005A
                    tfr       d,y
                    lbra      L1923
L1CE8               clra
                    bra       L1CED
                    lda       #$01
L1CED               sta       <u0066
                    lda       <u005C
                    bmi       L1D3A
L1CF3               sta       <u0061
                    clrb
                    adda      <u005A
                    std       <u005E
                    ldx       <u0052
                    ldb       <u005C
                    lda       b,x
                    sta       <u005C
                    lbra      L1DBC
L1D05               ldb       <u0060
                    lda       #$0A
                    mul
                    ldx       <u0016
                    leax      d,x
                    stx       <u000C
L1D10               ldb       $09,x
                    bmi       L1D63
                    ldx       <u0052
                    cmpb      <u0061
                    bne       L1D25
                    ldb       <u0061
                    lda       b,x
                    ldx       <u000C
                    sta       $09,x
                    lbra      L1DBC
L1D25               stb       <u0063
                    ldb       b,x
                    bmi       L1D63
                    cmpb      <u0061
                    bne       L1D25
                    ldb       <u0061
                    lda       b,x
                    ldb       <u0063
                    sta       b,x
                    lbra      L1DBC
L1D3A               lbsr      L1C65
                    lda       <u005C
                    bpl       L1CF3
                    pshs      u
                    ldu       <u0058
                    ldx       <u004E
                    ldb       <u005D
L1D49               incb
                    bpl       L1D4D
                    clrb
L1D4D               lda       b,u
                    bmi       L1D49
                    lsr       b,x
                    bcs       L1D49
                    lda       <u0066
                    beq       L1D5D
                    cmpb      <u0048
                    beq       L1D49
L1D5D               stb       <u005D
                    puls      u
                    bra       L1D68
L1D63               ldb       #$CF
                    lbra      L16C7
L1D68               ldx       <u0056
                    stb       <u0061
                    lda       b,x
                    sta       <u0060
                    tfr       b,a
                    clrb
                    adda      <u005A
                    std       <u005E
                    ldb       <u0060
                    lda       #$0A
                    mul
                    ldx       <u0016
                    leax      d,x
                    stx       <u000C
                    ldb       $08,x
                    bmi       L1D10
                    ldx       <u0052
                    cmpb      <u0061
                    bne       L1D9E
                    ldb       <u0061
                    ldb       b,x
                    ldx       <u000C
                    stb       $08,x
                    bmi       L1DBC
                    ldx       <u0054
                    lda       #$FF
                    sta       b,x
                    bra       L1DBC
L1D9E               stb       <u0063
                    ldb       b,x
                    lbmi      L1D05
                    cmpb      <u0061
                    bne       L1D9E
                    ldx       <u0052
                    ldb       <u0061
                    lda       b,x
                    ldb       <u0063
                    sta       b,x
                    bmi       L1DBC
                    ldx       <u0054
                    ldb       <u0063
                    stb       a,x
L1DBC               ldb       <u0024
                    lda       #$0A
                    mul
                    ldx       <u0016
                    leax      d,x
                    stx       <u0068
                    lda       <u0066
                    beq       L1DCF
                    ldd       $06,x
                    bra       L1DD1
L1DCF               ldd       ,x
L1DD1               addb      <u004C
                    adca      #$00
                    std       <u002F
                    clr       <u002E
                    clr       <u0031
                    pshs      u,y
                    ldx       <u002E
                    ldu       <u0030
                    lda       <u0037
                    os9       I$Seek
L1DE6               ldu       $02,s
                    lbcs      L16BB
                    ldx       <u005E
                    ldy       #$0100
                    lda       <u0037
                    os9       I$Read
                    bcs       L1DE6
                    puls      u,y
                    lda       #$FF
                    sta       <u0063
                    lda       <u0066
                    beq       L1E5C
                    lda       <u0061
                    sta       <u004A
                    ldx       <u0068
                    ldb       $09,x
                    bpl       L1E1C
                    ldb       <u0061
                    stb       $09,x
                    ldx       <u0052
                    lda       #$FF
                    sta       b,x
                    lbra      L1ED0
L1E1A               tfr       a,b
L1E1C               ldx       <u0050
                    lda       b,x
                    cmpa      <u004C
                    bhi       L1E39
                    stb       <u0063
                    ldx       <u0052
                    lda       b,x
                    bpl       L1E1A
                    lda       <u0061
                    sta       b,x
                    ldx       <u0052
                    ldb       #$FF
                    stb       a,x
                    lbra      L1ED0
L1E39               ldb       <u0063
                    bpl       L1E4C
                    ldx       <u0068
                    ldb       <u0061
                    lda       $09,x
                    stb       $09,x
                    ldx       <u0052
                    sta       b,x
                    lbra      L1ED0
L1E4C               ldx       <u0052
                    lda       b,x
                    sta       <u0062
                    lda       <u0061
                    sta       b,x
                    ldb       <u0062
                    stb       a,x
                    bra       L1ED0
L1E5C               lda       <u0061
                    sta       <u0048
                    ldx       <u0068
                    ldb       $08,x
                    bpl       L1E78
                    lda       <u0061
                    sta       $08,x
                    ldx       <u0052
                    ldb       #$FF
                    stb       a,x
                    ldx       <u0054
                    stb       a,x
                    bra       L1ED0
L1E76               tfr       a,b
L1E78               ldx       <u0050
                    lda       b,x
                    cmpa      <u004C
                    bhi       L1E9A
                    stb       <u0063
                    ldx       <u0052
                    lda       b,x
                    bpl       L1E76
                    lda       <u0061
                    sta       b,x
                    ldx       <u0054
                    ldb       <u0063
                    stb       a,x
                    ldx       <u0052
                    ldb       #$FF
                    stb       a,x
                    bra       L1ED0
L1E9A               ldb       <u0063
                    bpl       L1EB8
                    ldx       <u0068
                    ldb       <u0061
                    lda       $08,x
                    sta       <u0062
                    stb       $08,x
                    ldx       <u0052
                    sta       b,x
                    ldx       <u0054
                    lda       #$FF
                    sta       b,x
                    lda       <u0062
                    stb       a,x
                    bra       L1ED0
L1EB8               ldx       <u0052
                    lda       b,x
                    sta       <u0062
                    lda       <u0061
                    sta       b,x
                    ldb       <u0062
                    stb       a,x
                    ldx       <u0054
                    ldb       <u0063
                    stb       a,x
                    ldb       <u0062
                    sta       b,x
L1ED0               ldx       <u004E
                    ldb       <u0061
                    clr       b,x
                    ldx       <u0056
                    lda       <u0024
                    sta       b,x
                    ldx       <u0050
                    lda       <u004C
                    sta       b,x
                    rts
                    ldb       #$BE
                    bra       L1EED
L1EE7               ldb       #$BF
                    bra       L1EED
                    ldb       #$C3
L1EED               clra
                    lbsr      L1618
                    lbsr      L0673
L1EF4               ldb       #$03
                    bra       L1F0A
L1EF8               ldb       #$05
                    bra       L1F0A
L1EFC               ldb       #$06
                    bra       L1F0A
L1F00               ldb       #$07
                    bra       L1F0A
L1F04               ldb       #$09
                    bra       L1F0A
L1F08               ldb       #$0B
L1F0A               lda       <u0024
                    pshs      a
                    stb       <u0024
                    lbra      L17F0
L1F13               lsr       <u0000
                    bhi       L1F1F
                    oim       #$02,<u000A
                    asr       <u0061
                    inc       <u0008
                    fcb       $8F
L1F1F               tst       <u0009
                    cwai      #$0E
                    rol       <u007D
                    clr       <u000A
                    asr       $02,y
                    dec       <u00DB
                    bls       L1F37
                    sta       $04,y
                    tim       #$33,<u0027
                    tim       #$6F,<u00FF
L1F35               ldb       <u0024
L1F37               pshs      b
                    lda       #$04
                    sta       <u0024
                    pshs      u
                    leau      ,s
                    leax      -$04,s
                    pshs      x
                    ldd       #$0007
                    lbsr      L062A
                    ldd       <u000A
                    pshs      b,a
                    ldd       <-$2C,y
                    subd      <-$2A,y
                    addd      #$0007
                    ble       L1F5F
                    ldb       #$01
                    stb       <-$35,y
L1F5F               ldb       <-$35,y
                    beq       L1F68
                    pshs      y
                    bsr       L1EF4
L1F68               ldd       <-$26,y
                    pshs      b,a
                    ldx       #$0005
                    ldd       $02,y
                    pshs      x,b,a
                    lbsr      L0474
                    ldb       <-$3B,y
                    beq       L1F91
                    clra
                    clrb
                    subd      <-$1C,y
                    pshs      b,a
                    ldx       #$0006
                    ldd       $02,y
                    pshs      x,b,a
                    lbsr      L0474
                    ldb       #$44
                    bra       L1FA6
L1F91               lda       <-$1F,y
                    clrb
                    addd      <-$1E,y
                    pshs      b,a
                    ldx       #$0006
                    ldd       $02,y
                    pshs      x,b,a
                    lbsr      L0474
                    ldb       #$20
L1FA6               pshs      b
                    ldx       #$0001
                    ldd       $02,y
                    pshs      x,b,a
                    lbsr      L039C
                    ldd       <-$6B,y
                    pshs      b,a
                    ldx       #$0003
                    ldd       $02,y
                    pshs      x,b,a
                    lbsr      L0474
                    ldb       #$20
                    pshs      b
                    ldx       #$0001
                    ldd       $02,y
                    pshs      x,b,a
                    lbsr      L039C
                    leax      >-$05FF,y
                    pshs      x
                    ldd       u0007,u
                    subd      <-$28,y
                    addd      #$0010
                    bgt       L1FE3
                    ldd       u0007,u
                    bra       L1FE9
L1FE3               ldd       <-$28,y
                    subd      #$0010
L1FE9               pshs      b,a
                    ldx       #$006E
                    ldd       $02,y
                    pshs      x,b,a
                    lbsr      L03B7
                    ldd       $02,y
                    pshs      b,a
                    lbsr      L025E
                    ldd       <-$2C,y
                    addd      #$0001
                    std       <-$2C,y
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0024
                    leas      $04,s
                    jmp       ,x
                    ldb       <u0024
                    pshs      b
                    lda       #$08
                    sta       <u0024
                    pshs      u
                    leau      ,s
                    leax      <-$7A,s
                    pshs      x
                    ldd       #$0009
                    lbsr      L062A
                    ldd       <u000A
                    pshs      b,a
L2030               ldb       <-$13,y
                    cmpb      #$20
                    bne       L203E
                    pshs      u
                    lbsr      L2674
                    bra       L2030
L203E               cmpb      #$81
                    lbeq      L2477
                    cmpb      #$20
                    blt       L204C
                    cmpb      #$7E
                    ble       L206B
L204C               ldd       #$0030
                    std       -$02,y
                    ldd       #$000F
                    std       -$04,y
                    ldd       #$0016
                    pshs      b,a
                    pshs      y
                    lbsr      L1EFC
                    pshs      u
                    lbsr      L2674
                    lbra      L2643
L2068               lbra      L2166
L206B               cmpb      #$41
                    blt       L2068
                    cmpb      #$5A
                    ble       L207D
                    cmpb      #$61
                    blt       L2068
                    cmpb      #$7A
                    bgt       L2068
                    andb      #$5F
L207D               leax      -$10,y
                    clra
                    bra       L2088
L2082               puls      x,a
                    cmpa      #$08
                    beq       L208B
L2088               stb       a,x
                    inca
L208B               pshs      x,a
                    pshs      u
                    lbsr      L2674
                    ldb       <-$13,y
                    cmpb      #$5F
                    beq       L2082
                    cmpb      #$30
                    blt       L20B5
                    cmpb      #$39
                    ble       L2082
                    cmpb      #$41
                    blt       L20B5
                    cmpb      #$5A
                    ble       L2082
                    cmpb      #$61
                    blt       L20B5
                    cmpb      #$7A
                    bgt       L20B5
                    andb      #$5F
                    bra       L2082
L20B5               puls      x,a
                    sta       -u0001,u
                    clr       -u0002,u
                    cmpa      #$08
                    beq       L20C8
                    ldb       #$20
L20C1               stb       a,x
                    inca
                    cmpa      #$08
                    bne       L20C1
L20C8               ldd       #$0008
                    std       <-$12,y
                    leax      >-$03A9,y
                    ldd       -u0002,u
                    subd      #$0001
                    lslb
                    rola
                    leax      d,x
                    ldd       ,x
                    std       -u0004,u
                    ldd       $02,x
                    subd      #$0001
                    std       <-u0078,u
                    subd      -u0004,u
                    blt       L2158
                    ldd       -u0004,u
                    leax      >-$0397,y
                    subd      #$0001
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    leax      d,x
L20FC               ldd       ,x
                    subd      -$10,y
                    bne       L2147
                    ldd       $02,x
                    subd      -$0E,y
                    bne       L2147
                    ldd       $04,x
                    subd      -$0C,y
                    bne       L2147
                    ldd       $06,x
                    subd      -$0A,y
                    bne       L2147
                    leax      >-$03F1,y
                    ldd       -u0004,u
                    subd      #$0001
                    lslb
                    rola
                    ldd       d,x
                    std       -$02,y
                    ldd       -u0004,u
                    subd      #$0005
                    blt       L2140
                    cmpd      #$0008
                    bgt       L2140
                    leax      <L2137,pcr
                    ldb       b,x
                    bra       L2143
L2137               jmp       <u0007
                    clr       <u000F
                    clr       <u0003
                    lsr       <u000F
                    aim       #$CC,<u0000
                    clr       <u00ED
                    cwai      #$20
                    daa
L2147               ldd       -u0004,u
                    cmpd      <-u0078,u
                    bge       L2158
                    addd      #$0001
                    std       -u0004,u
                    leax      $08,x
                    bra       L20FC
L2158               clra
                    clrb
                    std       -$02,y
                    ldb       #$0F
                    std       -$04,y
                    lbra      L2643
L2163               lbra      L23AA
L2166               cmpb      #$30
                    blt       L2163
                    cmpb      #$39
                    bgt       L2163
                    ldd       #$000F
                    std       -$04,y
                    clrb
                    std       -u0004,u
L2176               ldd       -u0004,u
                    addd      #$0001
                    std       -u0004,u
                    cmpd      #$0064
                    bgt       L218D
                    leax      <-u0075,u
                    leax      d,x
                    ldb       <-$13,y
                    stb       ,x
L218D               pshs      u
                    lbsr      L2674
                    ldb       <-$13,y
                    cmpb      #$5F
                    beq       L218D
                    cmpb      #$30
                    blt       L21A1
                    cmpb      #$39
                    ble       L2176
L21A1               ldb       <-$13,y
                    cmpb      #$2E
                    beq       L21B2
                    cmpb      #$45
                    beq       L21B2
                    cmpb      #$65
                    lbne      L2340
L21B2               ldd       -u0004,u
                    std       -u0002,u
                    ldb       <-$13,y
                    cmpb      #$2E
                    bne       L222A
                    ldd       -u0002,u
                    addd      #$0001
                    std       -u0002,u
                    cmpd      #$0064
                    bgt       L21D4
                    leax      <-u0075,u
                    leax      d,x
                    ldb       <-$13,y
                    stb       ,x
L21D4               pshs      u
                    lbsr      L2674
                    ldb       <-$13,y
                    cmpb      #$2E
                    bne       L21E8
                    ldb       #$81
                    stb       <-$13,y
                    lbra      L2340
L21E8               ldb       <-$13,y
                    cmpb      #$30
                    blt       L21F3
                    cmpb      #$39
                    ble       L21FF
L21F3               ldd       #$001E
                    pshs      b,a
                    pshs      y
                    lbsr      L1EFC
                    bra       L222A
L21FF               ldd       -u0002,u
                    addd      #$0001
                    std       -u0002,u
                    cmpd      #$0064
                    bgt       L2216
                    leax      <-u0075,u
                    leax      d,x
                    ldb       <-$13,y
                    stb       ,x
L2216               pshs      u
                    lbsr      L2674
                    ldb       <-$13,y
                    cmpb      #$5F
                    beq       L2216
                    cmpb      #$30
                    blt       L222A
                    cmpb      #$39
                    ble       L21FF
L222A               ldb       <-$13,y
                    cmpb      #$45
                    beq       L2237
                    cmpb      #$65
                    lbne      L22BC
L2237               ldd       -u0002,u
                    addd      #$0001
                    std       -u0002,u
                    cmpd      #$0064
                    bgt       L224E
                    leax      <-u0075,u
                    leax      d,x
                    ldb       <-$13,y
                    stb       ,x
L224E               pshs      u
                    lbsr      L2674
                    ldb       <-$13,y
                    cmpb      #$2B
                    beq       L225E
                    cmpb      #$2D
                    bne       L227A
L225E               ldd       -u0002,u
                    addd      #$0001
                    std       -u0002,u
                    cmpd      #$0064
                    bgt       L2275
                    leax      <-u0075,u
                    leax      d,x
                    ldb       <-$13,y
                    stb       ,x
L2275               pshs      u
                    lbsr      L2674
L227A               ldb       <-$13,y
                    cmpb      #$30
                    blt       L2285
                    cmpb      #$39
                    ble       L2291
L2285               ldd       #$001E
                    pshs      b,a
                    pshs      y
                    lbsr      L1EFC
                    bra       L22BC
L2291               ldd       -u0002,u
                    addd      #$0001
                    std       -u0002,u
                    cmpd      #$0064
                    bgt       L22A8
                    leax      <-u0075,u
                    leax      d,x
                    ldb       <-$13,y
                    stb       ,x
L22A8               pshs      u
                    lbsr      L2674
                    ldb       <-$13,y
                    cmpb      #$5F
                    beq       L22A8
                    cmpb      #$30
                    blt       L22BC
                    cmpb      #$39
                    ble       L2291
L22BC               ldd       -u0002,u
                    addd      #$0001
                    std       -u0004,u
                    ldd       #$0064
                    std       <-u0078,u
                    cmpd      -u0004,u
                    blt       L22E8
                    leax      <-u0075,u
                    ldd       -u0004,u
                    leax      d,x
L22D5               ldb       #$20
                    stb       ,x+
                    ldd       -u0004,u
                    cmpd      <-u0078,u
                    bge       L22E8
                    addd      #$0001
                    std       -u0004,u
                    bra       L22D5
L22E8               leax      <-u0076,u
                    ldd       #$0007
                    pshs      x,b,a
                    lbsr      L05E0
                    ldd       #$0002
                    std       -$02,y
                    ldx       <-u0076,u
                    clra
                    clrb
                    std       ,x
                    ldd       <-u0076,u
                    std       <-u0078,u
                    addd      #$0002
                    pshs      b,a
                    leas      -$05,s
                    leax      <-u0074,u
                    ldd       #$0064
                    pshs      x,b,a
                    lbsr      L0D64
                    ldx       $05,s
                    ldd       ,s++
                    std       ,x
                    ldd       ,s++
                    std       $02,x
                    ldb       ,s+
                    stb       $04,x
                    leas      $02,s
                    ldd       -u0002,u
                    cmpd      #$0064
                    ble       L2339
                    ldd       #$0020
                    pshs      b,a
                    pshs      y
                    lbsr      L1EFC
L2339               ldd       <-u0076,u
                    std       -$06,y
                    bra       L23A7
L2340               clra
                    clrb
                    std       -$06,y
                    ldd       -u0004,u
                    subd      #$0064
                    ble       L2357
                    ldd       #$0020
                    pshs      b,a
                    pshs      y
                    lbsr      L1EFC
                    bra       L23A7
L2357               ldd       #$0001
                    std       -u0002,u
                    ldd       -u0004,u
                    std       <-u0078,u
                    subd      -u0002,u
                    blt       L23A2
                    leax      <-u0074,u
L2368               ldd       -$06,y
                    cmpd      #$0CCC
                    bgt       L2385
                    lslb
                    rola
                    pshs      b,a
                    lslb
                    rola
                    lslb
                    rola
                    addd      ,s
                    std       ,s
                    ldb       ,x+
                    clra
                    andb      #$0F
                    addd      ,s++
                    bvc       L2391
L2385               ldd       #$0020
                    pshs      b,a
                    pshs      y
                    lbsr      L1EFC
                    bra       L23A2
L2391               std       -$06,y
                    ldd       -u0002,u
                    cmpd      <-u0078,u
                    bge       L23A2
                    addd      #$0001
                    std       -u0002,u
                    bra       L2368
L23A2               ldd       #$0001
                    std       -$02,y
L23A7               lbra      L2643
L23AA               cmpb      #$27
                    lbne      L2439
                    clra
                    clrb
                    std       -$08,y
                    ldb       #$03
                    std       -$02,y
                    ldb       #$0F
                    std       -$04,y
L23BC               pshs      u
                    lbsr      L2674
                    ldd       -$08,y
                    addd      #$0001
                    std       -$08,y
                    cmpd      #$0064
                    bgt       L23D8
                    leax      <-u0075,u
                    leax      d,x
                    ldb       <-$13,y
                    stb       ,x
L23D8               ldb       <-$18,y
                    bne       L23E4
                    ldb       <-$13,y
                    cmpb      #$27
                    bne       L23BC
L23E4               ldb       <-$18,y
                    beq       L23F5
                    ldd       #$001F
                    pshs      b,a
                    pshs      y
                    lbsr      L1EFC
                    bra       L23FA
L23F5               pshs      u
                    lbsr      L2674
L23FA               ldb       <-$13,y
                    cmpb      #$27
                    beq       L23BC
                    ldd       -$08,y
                    subd      #$0001
                    std       -$08,y
                    subd      #$0001
                    bne       L2415
                    ldb       <-u0074,u
                    clra
                    std       -$06,y
                    bra       L2436
L2415               leax      <-u0076,u
                    ldd       #$0009
                    pshs      x,b,a
                    lbsr      L05E0
                    ldd       <-u0076,u
                    pshs      b,a
                    leax      <-u0074,u
                    ldd       -$08,y
                    pshs      x,b,a
                    pshs      y
                    lbsr      L1F00
                    ldd       <-u0076,u
                    std       -$06,y
L2436               lbra      L2643
L2439               cmpb      #$3A
                    bne       L2462
                    ldd       #$000F
                    std       -$04,y
                    pshs      u
                    lbsr      L2674
                    ldb       <-$13,y
                    cmpb      #$3D
                    bne       L245A
                    ldd       #$0011
                    std       -$02,y
                    pshs      u
                    lbsr      L2674
                    bra       L245F
L245A               ldd       #$0010
                    std       -$02,y
L245F               lbra      L2643
L2462               cmpb      #$2E
                    bne       L2493
                    ldd       #$000F
                    std       -$04,y
                    pshs      u
                    lbsr      L2674
                    ldb       <-$13,y
                    cmpb      #$2E
                    bne       L247B
L2477               ldb       #$31
                    bra       L2481
L247B               cmpb      #$29
                    bne       L248B
                    ldb       #$0A
L2481               clra
                    std       -$02,y
                    pshs      u
                    lbsr      L2674
                    bra       L2490
L248B               ldd       #$000E
                    std       -$02,y
L2490               lbra      L2643
L2493               cmpb      #$3C
                    bne       L24C4
                    pshs      u
                    lbsr      L2674
                    ldd       #$0007
                    std       -$02,y
                    ldb       <-$13,y
                    cmpb      #$3D
                    bne       L24AC
                    ldb       #$09
                    bra       L24B2
L24AC               cmpb      #$3E
                    bne       L24BC
                    ldb       #$0C
L24B2               clra
                    std       -$04,y
                    pshs      u
                    lbsr      L2674
                    bra       L24C1
L24BC               ldd       #$0008
                    std       -$04,y
L24C1               lbra      L2643
L24C4               cmpb      #$3E
                    bne       L24ED
                    pshs      u
                    lbsr      L2674
                    ldd       #$0007
                    std       -$02,y
                    ldb       <-$13,y
                    cmpb      #$3D
                    bne       L24E5
                    ldd       #$000A
                    std       -$04,y
                    pshs      u
                    lbsr      L2674
                    bra       L24EA
L24E5               ldd       #$000B
                    std       -$04,y
L24EA               lbra      L2643
L24ED               cmpb      #$28
                    bne       L2557
                    pshs      u
                    lbsr      L2674
                    ldb       <-$13,y
                    cmpb      #$2A
                    bne       L253E
                    pshs      u
                    lbsr      L2674
                    ldb       <-$13,y
                    cmpb      #$24
                    bne       L250E
                    pshs      u
                    lbsr      L1F08
L250E               ldb       <-$13,y
                    cmpb      #$2A
                    beq       L2523
                    ldx       ,y
                    ldb       $0B,x
                    lsrb
                    bcs       L2523
                    pshs      u
                    lbsr      L2674
                    bra       L250E
L2523               pshs      u
                    lbsr      L2674
                    ldb       <-$13,y
                    cmpb      #$29
                    beq       L2536
                    ldx       ,y
                    ldb       $0B,x
                    lsrb
                    bcc       L250E
L2536               pshs      u
                    lbsr      L2674
                    lbra      L2030
L253E               cmpb      #$2E
                    bne       L254B
                    ldd       #$000A
                    std       -$02,y
                    ldb       #$0F
                    bra       L25C5
L254B               ldd       #$0008
                    std       -$02,y
                    ldb       #$0F
                    std       -$04,y
                    lbra      L2643
L2557               cmpb      #$7B
                    bne       L25AF
                    pshs      u
                    lbsr      L2674
                    ldb       <-$13,y
                    cmpb      #$24
                    bne       L256C
                    pshs      u
                    lbsr      L1F08
L256C               ldb       <-$13,y
                    cmpb      #$7D
                    beq       L2536
                    ldx       ,y
                    ldb       $0B,x
                    lsrb
                    bcs       L2536
                    pshs      u
                    lbsr      L2674
                    bra       L256C
                    bpl       L2588
                    neg       <u002B
                    ror       <u0005
                    blt       L258F
                    ror       <u003D
                    asr       <u000D
                    ble       L2594
L258F               oim       #$29,<u0009
                    clr       <u005B
L2594               dec       <u000A
                    tstb
                    tim       #$0F,<u002C
                    inc       <u000F
                    rti
                    tst       <u000F
                    fcb       $5E                 ^
                    clr       <u0000
                    nega
                    clr       <u0000
                    bne       L25AC
                    lbrn      L2BBC
                    bls       L25B3
                    nop
                    neg       <u0030
                    cmpx      #$CFE1
L25B3               anda      #$27
                    lsl       <u0030
                    com       <u00A6
                    anda      #$26
                    ldb       >$2019
                    clra
                    ldb       $01,x
                    std       -$02,y
                    ldb       $02,x
L25C5               std       -$04,y
                    pshs      u
                    lbsr      L2674
                    bra       L2643
L25CE               ldd       #$0030
                    std       -$02,y
                    ldb       #$0F
                    bra       L25C5
                    cmpb      #$24
                    bne       L25CE
                    clra
                    clrb
                    std       -$06,y
                    pshs      u
                    lbsr      L2674
                    ldb       <-$13,y
                    cmpb      #$30
                    blt       L25F9
                    cmpb      #$39
                    ble       L2624
                    andb      #$5F
                    cmpb      #$41
                    blt       L25F9
                    cmpb      #$46
                    ble       L2622
L25F9               ldd       #$0017
                    pshs      b,a
                    pshs      y
                    lbsr      L1EFC
                    bra       L263E
L2605               pshs      u
                    bsr       L2674
                    ldb       <-$13,y
                    cmpb      #$5F
                    beq       L2605
                    cmpb      #$30
                    blt       L263E
                    cmpb      #$39
                    ble       L2624
                    andb      #$5F
                    cmpb      #$41
                    blt       L263E
                    cmpb      #$46
                    bgt       L263E
L2622               subb      #$07
L2624               andb      #$0F
                    stb       <u000A
                    ldd       -$06,y
                    bita      #$F0
                    lbne      L2385
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    addb      <u000A
                    std       -$06,y
                    bra       L2605
L263E               ldd       #$0001
                    std       -$02,y
L2643               puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0024
                    leas      $02,s
                    jmp       ,x
L2653               bra       L267F
                    bpl       L2681
                    bpl       L2679
                    fcb       $45                 E
                    clra
                    rora
                    bra       L26A3
                    fcb       $4E                 N
                    coma
                    clra
                    fcb       $55                 U
                    fcb       $4E                 N
                    lsrb
                    fcb       $45                 E
                    fcb       $52                 R
                    fcb       $45                 E
                    lsra
                    bra       L26BA
                    fcb       $52                 R
                    fcb       $45                 E
                    tsta
                    fcb       $41                 A
                    lsrb
                    fcb       $55                 U
                    fcb       $52                 R
                    fcb       $45                 E
                    inca
                    rolb
L2674               ldb       <u0024
                    pshs      b
                    lda       #$0A
                    sta       <u0024
                    pshs      u
                    leau      ,s
                    leas      -$04,s
                    ldd       <u000A
                    pshs      b,a
L2686               ldx       ,y
                    ldb       $0B,x
                    lsrb
                    bcc       L26AB
                    leax      <L2653,pcr
                    ldd       #$0021
                    pshs      x,b,a
                    pshs      b,a
                    ldd       $02,y
                    pshs      b,a
                    lbsr      L03B7
                    ldd       $02,y
                    pshs      b,a
                    lbsr      L025E
                    clr       <-$13,y
                    lbra      L2792
L26AB               ldb       <-$18,y
                    lbeq      L2772
                    ldd       >-$0145,y
                    beq       L26BD
                    pshs      y
L26BA               lbsr      L1EF8
L26BD               ldx       ,y
                    ldb       $0B,x
                    andb      #$03
                    cmpb      #$02
                    bne       L26CC
                    pshs      x
                    lbsr      L0494
L26CC               clra
                    clrb
                    std       -u0004,u
                    ldx       ,y
                    ldb       $0B,x
                    andb      #$02
                    bne       L2709
                    pshs      u,y
                    ldx       ,y
                    ldd       $02,x
                    std       -u0004,u
                    beq       L26FF
                    leau      >-$05FF,y
                    leax      <$10,x
                    tfr       d,y
                    bitb      #$01
                    beq       L26F7
                    ldb       ,x+
                    stb       ,u+
                    leay      -$01,y
                    beq       L26FF
L26F7               ldd       ,x++
                    std       ,u++
                    leay      -$02,y
                    bne       L26F7
L26FF               puls      u,y
                    ldx       ,y
                    lda       $0B,x
                    ora       #$02
                    sta       $0B,x
L2709               ldd       -u0004,u
                    std       <-$17,y
                    ldd       <-$26,y
                    addd      #$0001
                    std       <-$26,y
                    ldb       >-$075E,y
                    bne       L2737
                    ldb       >-$075F,y
                    beq       L2737
                    ldb       <-$3B,y
                    bne       L2737
                    lbsr      L2E45
                    ldd       #$002C
                    lbsr      L2E6A
                    ldd       <-$26,y
                    lbsr      L2E80
L2737               ldb       >-$05FF,y
                    cmpb      #$24
                    bne       L274E
                    leas      -$01,s
                    ldx       u0005,u
                    pshs      x
                    lbsr      L1F04
                    lsr       ,s+
                    lbcs      L2686
L274E               ldb       <-$37,y
                    beq       L276A
                    ldb       <-$38,y
                    bne       L276A
                    ldx       ,y
                    ldb       $0B,x
                    andb      #$01
                    bne       L276A
                    ldd       <-$17,y
                    pshs      b,a
                    pshs      y
                    lbsr      L1F35
L276A               clra
                    clrb
                    std       <-$1A,y
                    stb       <-$18,y
L2772               ldb       <-$19,y
                    cmpb      <-$16,y
                    blt       L2786
                    ldb       #$01
                    stb       <-$18,y
                    ldb       #$20
                    stb       <-$13,y
                    bra       L2792
L2786               inc       <-$19,y
                    leax      >-$05FF,y
                    ldb       b,x
                    stb       <-$13,y
L2792               puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0024
                    leas      $02,s
                    jmp       ,x
                    ldb       <u0024
                    pshs      b
                    lda       #$0C
                    sta       <u0024
                    pshs      u
                    leau      ,s
                    leas      -$0D,s
                    ldd       <u000A
                    pshs      b,a
                    ldx       u0007,u
                    ldd       ,x
                    std       -u0008,u
                    ldd       $02,x
                    std       -u0006,u
                    ldd       $04,x
                    std       -u0004,u
                    ldd       $06,x
                    std       -u0002,u
                    leax      >-$0141,y
                    ldd       <-$6D,y
                    lslb
                    rola
                    pshs      b,a
                    lslb
                    rola
                    lslb
                    rola
                    addd      ,s++
                    leax      d,x
                    ldd       ,x
                    std       -u000C,u
                    bne       L27E5
                    ldd       u0007,u
                    std       ,x
                    bra       L2837
L27E5               ldx       -u000C,u
L27E7               stx       -u000A,u
                    ldd       ,x
                    subd      -u0008,u
                    bcs       L2815
                    bhi       L281B
                    ldd       $02,x
                    subd      -u0006,u
                    bcs       L2815
                    bhi       L281B
                    ldd       $04,x
                    subd      -u0004,u
                    bcs       L2815
                    bhi       L281B
                    ldd       $06,x
                    subd      -u0002,u
                    bcs       L2815
                    bhi       L281B
                    ldd       #$0065
                    pshs      b,a
                    pshs      y
                    lbsr      L1EFC
                    ldx       -u000A,u
L2815               ldx       $08,x
                    clr       -u000D,u
                    bra       L2821
L281B               ldx       $0A,x
                    ldb       #$01
                    stb       -u000D,u
L2821               stx       -u000C,u
                    bne       L27E7
                    ldb       -u000D,u
                    beq       L2831
                    ldx       -u000A,u
                    ldd       u0007,u
                    std       $0A,x
                    bra       L2837
L2831               ldx       -u000A,u
                    ldd       u0007,u
                    std       $08,x
L2837               ldx       u0007,u
                    clra
                    clrb
                    std       $0A,x
                    std       $08,x
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0024
                    leas      $04,s
                    jmp       ,x
                    leas      -$01,s
                    pshs      u
                    leau      ,s
                    ldx       u0009,u
                    beq       L2883
L2859               ldd       ,x
                    subd      -$10,y
                    bcs       L2879
                    bhi       L287F
                    ldd       $02,x
                    subd      -$0E,y
                    bcs       L2879
                    bhi       L287F
                    ldd       $04,x
                    subd      -$0C,y
                    bcs       L2879
                    bhi       L287F
                    ldd       $06,x
                    subd      -$0A,y
                    bhi       L287F
                    beq       L2883
L2879               ldx       $08,x
                    bne       L2859
                    bra       L2883
L287F               ldx       $0A,x
                    bne       L2859
L2883               stx       [<u0007,u]
                    leas      ,u
                    puls      u
                    ldx       $01,s
                    leas      $09,s
                    jmp       ,x
                    ldb       <u0024
                    pshs      b
                    lda       #$0E
                    sta       <u0024
                    pshs      u
                    leau      ,s
                    leas      -$04,s
                    ldd       <u000A
                    pshs      b,a
                    ldd       <-$6D,y
                    std       <-$6F,y
                    blt       L2920
                    leax      >-$0141,y
                    lslb
                    rola
                    pshs      b,a
                    lslb
                    rola
                    lslb
                    rola
                    addd      ,s++
                    leax      d,x
                    bra       L28C0
L28BC               ldx       -u0004,u
                    leax      -$0A,x
L28C0               stx       -u0004,u
                    ldx       ,x
L28C4               stx       -u0002,u
                    beq       L2913
                    ldd       ,x
                    subd      -$10,y
                    bcs       L290B
                    bhi       L290F
                    ldd       $02,x
                    subd      -$0E,y
                    bcs       L290B
                    bhi       L290F
                    ldd       $04,x
                    subd      -$0C,y
                    bcs       L290B
                    bhi       L290F
                    ldd       $06,x
                    subd      -$0A,y
                    bcs       L290B
                    bhi       L290F
                    ldb       <$11,x
                    bitb      #$F8
                    bne       L28FA
                    leax      >L1061,pcr
                    lda       <u0028,u
                    bita      b,x
                    bne       L2964
L28FA               ldb       <-$3A,y
                    beq       L2909
                    ldd       #$0067
                    pshs      b,a
                    pshs      y
                    lbsr      L1EFC
L2909               ldx       -u0002,u
L290B               ldx       $08,x
                    bra       L28C4
L290F               ldx       $0A,x
                    bra       L28C4
L2913               ldd       <-$6F,y
                    beq       L2920
                    subd      #$0001
                    std       <-$6F,y
                    bra       L28BC
L2920               ldb       <-$3A,y
                    beq       L2964
                    ldd       #$0068
                    pshs      b,a
                    pshs      y
                    lbsr      L1EFC
                    ldb       <u0028,u
                    bitb      #$01
                    beq       L293B
                    ldd       <-$61,y
                    bra       L2962
L293B               bitb      #$04
                    beq       L2944
                    ldd       <-$5D,y
                    bra       L2962
L2944               bitb      #$08
                    beq       L294D
                    ldd       <-$5B,y
                    bra       L2962
L294D               bitb      #$02
                    beq       L2956
                    ldd       <-$5F,y
                    bra       L2962
L2956               bitb      #$10
                    beq       L295F
                    ldd       <-$59,y
                    bra       L2962
L295F               ldd       <-$57,y
L2962               std       -u0002,u
L2964               ldd       -u0002,u
                    std       [<u0007,u]
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0024
                    leas      <$24,s
                    jmp       ,x
                    leas      -$01,s
                    pshs      u
                    leau      ,s
                    clra
                    clrb
                    std       [<u0009,u]
                    std       [<u0007,u]
                    ldx       u000B,u
                    beq       L29B0
                    ldd       $02,x
                    subd      #$0001
                    bne       L299C
                    ldd       $08,x
                    std       [<u0009,u]
                    ldd       $06,x
                    bra       L29AD
L299C               cmpx      <-$4D,y
                    bne       L29A6
                    ldd       #$00FF
                    bra       L29AD
L29A6               ldx       $06,x
                    beq       L29B0
                    ldd       <$12,x
L29AD               std       [<u0007,u]
L29B0               leas      ,u
                    puls      u
                    ldx       $01,s
                    leas      $0B,s
                    jmp       ,x
L29BA               ldb       <u0024
                    pshs      b
                    lda       #$22
                    sta       <u0024
                    pshs      u
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    ldb       u0007,u
                    pshs      b,a
                    ldx       u0005,u
                    pshs      x
                    bsr       L29EE
                    ldb       u0008,u
                    pshs      b,a
                    ldx       u0005,u
                    pshs      x
                    bsr       L29EE
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0024
                    leas      $04,s
                    jmp       ,x
L29EE               ldb       <u0024
                    pshs      b
                    lda       #$21
                    sta       <u0024
                    pshs      u
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    leax      >-$06FF,y
                    ldd       <-$1E,y
                    leax      d,x
                    ldb       u0008,u
                    stb       ,x
                    ldx       <-$1E,y
                    leax      $01,x
                    stx       <-$1E,y
                    cmpx      #$00FF
                    ble       L2A36
                    leax      >-$070F,y
                    pshs      x
                    lbsr      L0262
                    ldx       <-$30,y
                    leax      $01,x
                    stx       <-$30,y
                    ldx       <-$20,y
                    leax      $01,x
                    stx       <-$20,y
                    clra
                    clrb
                    std       <-$1E,y
L2A36               puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0024
                    leas      $04,s
                    jmp       ,x
L2A46               ldb       <u0024
                    pshs      b
                    lda       #$23
                    sta       <u0024
                    pshs      u
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    ldd       <-$1E,y
                    addd      u0007,u
                    subd      #$00FF
                    ble       L2A72
L2A60               ldd       <-$1E,y
                    beq       L2A72
                    ldb       #$3E
                    pshs      b,a
                    ldx       u0005,u
                    pshs      x
                    lbsr      L29EE
                    bra       L2A60
L2A72               puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0024
                    leas      $04,s
                    jmp       ,x
                    ldb       <u0024
                    pshs      b
                    lda       #$26
                    sta       <u0024
                    pshs      u
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    leax      >-$0511,y
                    ldd       u000D,u
                    lslb
                    rola
                    ldd       d,x
                    ldx       u0005,u
                    addd      -$10,x
                    std       -$10,x
                    cmpd      -$0E,x
                    blt       L2AA9
                    std       -$0E,x
L2AA9               ldd       u000D,u
                    cmpd      #$008F
                    bls       L2AB9
                    ldd       #$0459
                    pshs      b,a
                    lbsr      L0671
L2AB9               lslb
                    rola
                    leax      <L2AC2,pcr
                    ldd       d,x
                    jmp       d,x
L2AC2               oim       #$F6,<u0001
                    ldb       >$01F6
                    oim       #$F6,<u0001
                    ldb       >$01F6
                    oim       #$F6,<u0001
                    ldb       >$01F6
                    oim       #$F6,<u0001
                    ldb       >$01F6
                    oim       #$F6,<u0001
                    ldb       >$01F6
                    oim       #$F6,<u0001
                    ldb       >$01F6
                    oim       #$F6,<u0001
                    ldb       >$01F6
                    oim       #$F6,<u0001
                    ldb       >$01F6
                    oim       #$F6,<u0001
                    ldb       >$01F6
                    oim       #$F6,<u0001
                    ldb       >$01F6
                    oim       #$F6,<u0001
                    ldb       >$01F6
                    oim       #$F6,<u0001
                    ldb       >$01F6
                    oim       #$F6,<u0001
                    ldb       >$01F6
                    oim       #$F6,<u0001
                    ldb       >$01F6
                    oim       #$F6,<u0001
                    ldb       >$015D
                    oim       #$F6,<u0001
                    ldb       >$01F6
                    oim       #$20,<u0001
                    bra       L2B26
                    stu       $01,x
                    lsra
                    stu       >$EFFF
                    stu       [>$EFFF]
                    stu       [>$EFFF]
                    stu       $01,x
                    lsra
                    oim       #$44,<u00FF
                    stu       $01,x
                    lsra
                    stu       >$EFFF
                    stu       [>$EF01]
                    clra
                    oim       #$5D,<u00FF
                    stu       $01,x
                    tstb
                    oim       #$5D,<u0001
                    tstb
                    oim       #$69,<u0001
                    rol       $01,x
                    rol       $01,x
                    tstb
                    oim       #$5D,<u0001
                    rol       $01,x
                    suba      $01,x
                    ldb       >$01CF
                    oim       #$F6,<u0001
                    ldb       >$01F6
                    oim       #$FE,<u0001
                    ldb       >$01F6
                    oim       #$F6,<u0001
                    ldu       >$01F6
                    oim       #$F6,<u0001
                    ldb       >$01FE
                    oim       #$F6,<u0001
                    ldb       >$01F6
                    oim       #$FE,<u0001
                    ldb       >$01F6
                    oim       #$F6,<u0001
                    ldu       >$01F6
                    oim       #$F6,<u0001
                    ldb       >$01FE
                    aim       #$0C,<u0002
                    inc       <u0002
                    inc       <u0002
                    sex
                    aim       #$0C,<u0002
                    inc       <u0002
                    inc       <u0002
                    sex
                    aim       #$4A,<u0002
                    rol       >$023F
                    com       <u0002
                    aim       #$4A,<u0002
                    adca      $02,x
                    swi
                    fcb       $03
                    aim       #$02,<u003F
                    aim       #$3F,<u0002
                    swi
                    fcb       $03
                    aim       #$02,<u003F
L2BBC               aim       #$3F,<u0002
                    swi
                    fcb       $03
                    aim       #$02,<u003F
                    com       <u0042
                    aim       #$3F,<u0003
                    aim       #$01,<u00F6
                    oim       #$F6,<u0001
                    ldb       >$01FE
                    stu       >$EF02
                    inc       <u0002
                    ldu       <u0001
                    clra
                    oim       #$F6,<u0001
                    ldb       >$01F6
                    oim       #$F6,<u00AE
                    tsta
                    cmpx      #$0031
                    bne       L2BEE
                    lbsr      L2E49
                    bra       L2BF1
L2BEE               lbsr      L2E45
L2BF1               lbsr      L2E68
                    lbsr      L2E8C
                    ldx       u000D,u
                    cmpx      #$0031
                    beq       L2C01
                    lbsr      L2E64
L2C01               lbsr      L2E60
                    bra       L2C28
                    lbsr      L2E49
                    lbsr      L2E68
                    lbsr      L2E64
                    bra       L2C28
                    lbsr      L2E41
                    lbsr      L2E68
                    lbsr      L2E7E
                    lbsr      L2E7A
                    bra       L2C28
                    lbsr      L2E45
                    lbsr      L2E68
                    lbsr      L2E7E
L2C28               lbra      L2E31
                    lda       u000B,u
                    bne       L2C3E
                    lbsr      L2E49
                    ldb       u000E,u
                    subb      #$10
                    lbsr      L2E6A
                    lbsr      L2E64
                    bra       L2C47
L2C3E               lbsr      L2E45
                    lbsr      L2E68
                    lbsr      L2E7E
L2C47               ldb       u000E,u
                    cmpb      #$48
                    beq       L2C51
                    cmpb      #$4C
                    bne       L2C28
L2C51               ldx       u0005,u
                    ldd       -$10,x
                    addd      u000B,u
                    std       -$10,x
                    cmpd      -$0E,x
                    ble       L2CB5
                    std       -$0E,x
                    bra       L2C28
                    ldx       u000B,u
                    cmpx      #$0020
                    bcc       L2C73
                    lbsr      L2E4D
                    ldb       u000C,u
                    addb      #$90
                    lbra      L2D90
L2C73               cmpx      #$FF80
                    blt       L2C84
                    cmpx      #$0080
                    bge       L2C84
                    lbsr      L2E49
                    ldb       #$36
                    bra       L2CA4
L2C84               lbsr      L2E45
                    ldb       #$4D
                    lbsr      L2E6A
                    lbsr      L2E7E
                    bra       L2CB5
                    ldx       u000B,u
                    cmpx      #$FF80
                    blt       L2CAC
                    cmpx      #$0080
                    bge       L2CAC
                    lbsr      L2E49
                    ldb       u000E,u
                    subb      #$10
L2CA4               lbsr      L2E6A
                    lbsr      L2E64
                    bra       L2CB5
L2CAC               lbsr      L2E45
                    lbsr      L2E68
                    lbsr      L2E7E
L2CB5               lbra      L2E31
                    lbsr      L2E4D
                    lbsr      L2E68
                    bra       L2CB5
                    lbsr      L2E45
                    lbsr      L2E68
                    lbsr      L2E76
                    lbsr      L2E8C
                    bra       L2CB5
                    ldd       #$0004
                    lbsr      L2E50
                    lbsr      L2E68
                    lbsr      L2E64
                    lbsr      L2E7A
                    bra       L2CB5
                    ldd       #$0006
                    lbsr      L2E50
                    lbsr      L2E68
                    lbsr      L2E76
                    lbsr      L2E64
                    lbsr      L2E7A
                    ldb       u000E,u
                    cmpb      #$6B
                    bne       L2CFC
                    lbsr      L2E8C
                    bra       L2CB5
L2CFC               lbsr      L2E95
                    bra       L2CB5
                    lbsr      L2E45
                    lbsr      L2E68
                    lbsr      L2E7A
                    bra       L2CB5
                    ldx       u0009,u
                    cmpx      #$FF80
                    blt       L2D2F
                    cmpx      #$007F
                    bgt       L2D2F
                    lbsr      L2E49
                    ldb       u000E,u
                    cmpb      #$70
                    bne       L2D25
                    ldb       #$35
                    bra       L2D27
L2D25               ldb       #$34
L2D27               lbsr      L2E6A
                    lbsr      L2E60
                    bra       L2D38
L2D2F               lbsr      L2E45
                    lbsr      L2E68
                    lbsr      L2E7A
L2D38               lbra      L2E31
                    lbsr      L2E4D
                    ldx       u0009,u
                    cmpx      #$0009
                    bne       L2D49
                    ldb       #$F0
                    bra       L2D90
L2D49               cmpx      #$0007
                    bne       L2D52
                    ldb       #$F1
                    bra       L2D90
L2D52               cmpx      #$FFFE
                    bgt       L2D60
                    cmpx      #$FFF1
                    blt       L2D60
                    ldb       #$F0
                    bra       L2D8E
L2D60               lbsr      L2E45
                    lbsr      L2E68
                    lbsr      L2E7A
                    bra       L2D38
                    lbsr      L2E4D
                    ldx       u0009,u
                    cmpx      #$0009
                    bne       L2D79
                    ldb       #$D0
                    bra       L2D90
L2D79               cmpx      #$0007
                    bne       L2D82
                    ldb       #$D1
                    bra       L2D90
L2D82               cmpx      #$FFFE
                    bgt       L2D95
                    cmpx      #$FFE1
                    blt       L2D95
                    ldb       #$D0
L2D8E               subb      u000A,u
L2D90               lbsr      L2E6A
                    bra       L2DC2
L2D95               lbsr      L2E45
                    lbsr      L2E68
                    lbsr      L2E7A
                    bra       L2DC2
                    ldx       u0009,u
                    cmpx      #$FF80
                    blt       L2DB9
                    cmpx      #$007F
                    bgt       L2DB9
                    lbsr      L2E49
                    ldb       #$32
                    lbsr      L2E6A
                    lbsr      L2E60
                    bra       L2DC2
L2DB9               lbsr      L2E45
                    lbsr      L2E68
                    lbsr      L2E7A
L2DC2               bra       L2E31
                    lbsr      L2E41
                    lbsr      L2E68
                    lbsr      L2E76
                    lbsr      L2E7A
                    ldb       u000E,u
                    cmpb      #$77
                    beq       L2DDA
                    cmpb      #$83
                    bne       L2DDF
L2DDA               lbsr      L2E95
                    bra       L2E31
L2DDF               cmpb      #$73
                    beq       L2DE7
                    cmpb      #$7F
                    bne       L2DEC
L2DE7               lbsr      L2E8C
                    bra       L2E31
L2DEC               cmpb      #$7B
                    bne       L2E31
                    ldx       u0005,u
                    ldd       -$10,x
                    addd      u0007,u
                    subd      #$0002
                    std       -$10,x
                    cmpd      -$0E,x
                    ble       L2E31
                    std       -$0E,x
                    bra       L2E31
                    bsr       L2E4D
                    ldx       u0009,u
                    bne       L2E0E
                    ldb       #$B1
                    bra       L2E25
L2E0E               cmpx      #$0002
                    bne       L2E17
                    ldb       #$B0
                    bra       L2E25
L2E17               cmpx      #$FFFE
                    bgt       L2E29
                    cmpx      #$FFE0
                    ble       L2E29
                    ldb       #$B0
                    subb      u000A,u
L2E25               bsr       L2E6A
                    bra       L2E31
L2E29               bsr       L2E45
                    ldb       #$81
                    bsr       L2E6A
                    bsr       L2E7A
L2E31               puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0024
                    leas      $0A,s
                    jmp       ,x
L2E41               ldb       #$05
                    bra       L2E4F
L2E45               ldb       #$03
                    bra       L2E4F
L2E49               ldb       #$02
                    bra       L2E4F
L2E4D               ldb       #$01
L2E4F               clra
L2E50               pshs      b,a
                    ldx       u0005,u
                    ldx       $05,x
                    pshs      x
                    lbsr      L2A46
                    rts
                    ldd       u0007,u
                    bra       L2E6A
L2E60               ldd       u0009,u
                    bra       L2E6A
L2E64               ldd       u000B,u
                    bra       L2E6A
L2E68               ldd       u000D,u
L2E6A               pshs      b,a
                    ldx       u0005,u
                    ldx       $05,x
                    pshs      x
                    lbsr      L29EE
                    rts
L2E76               ldd       u0007,u
                    bra       L2E80
L2E7A               ldd       u0009,u
                    bra       L2E80
L2E7E               ldd       u000B,u
L2E80               pshs      b,a
                    ldx       u0005,u
                    ldx       $05,x
                    pshs      x
                    lbsr      L29BA
                    rts
L2E8C               ldx       u0005,u
                    ldd       -$10,x
                    subd      u0007,u
                    std       -$10,x
                    rts
L2E95               ldx       u0005,u
                    ldd       -$10,x
                    addd      u0007,u
                    std       -$10,x
                    cmpd      -$0E,x
                    ble       L2EA4
                    std       -$0E,x
L2EA4               rts
                    emod
eom                 equ       *
