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

                    nam       PascalN
                    ttl       program module

* Disassembled 02/04/05 10:05:40 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       /dd/defs/os9defs
                    endc
tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $06
                    mod       eom,name,tylg,atrv,start,size
u0000               rmb       1
u0001               rmb       1
u0002               rmb       1
u0003               rmb       1
u0004               rmb       2
u0006               rmb       1
u0007               rmb       1
u0008               rmb       1
u0009               rmb       1
u000A               rmb       1
u000B               rmb       1
u000C               rmb       2
u000E               rmb       2
u0010               rmb       4
u0014               rmb       2
u0016               rmb       2
u0018               rmb       2
u001A               rmb       6
u0020               rmb       2
u0022               rmb       12
u002E               rmb       1
u002F               rmb       1
u0030               rmb       12
u003C               rmb       1
u003D               rmb       1
u003E               rmb       2
u0040               rmb       1
u0041               rmb       1
u0042               rmb       2
u0044               rmb       1
u0045               rmb       1
u0046               rmb       2
u0048               rmb       1
u0049               rmb       5
u004E               rmb       2
u0050               rmb       5
u0055               rmb       10
u005F               rmb       24
u0077               rmb       85
u00CC               rmb       5
u00D1               rmb       12
u00DD               rmb       5
u00E2               rmb       16
u00F2               rmb       1
u00F3               rmb       1
u00F4               rmb       1
u00F5               rmb       1
u00F6               rmb       1
u00F7               rmb       3
u00FA               rmb       3
u00FD               rmb       1
u00FE               rmb       1
u00FF               rmb       4353
size                equ       .
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
name                equ       *
                    fcs       /PascalN/
                    fcb       $06
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $DD                 ]
                    fcb       $CE                 N
                    fcb       $16
                    fcb       $0C
                    fcb       $AF                 /
                    fcb       $35                 5
                    fcb       $06
                    fcb       $A4                 $
                    fcb       $E4                 d
                    fcb       $E4                 d
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0C
                    fcb       $A4                 $
                    fcb       $35                 5
                    fcb       $06
                    fcb       $AA                 *
                    fcb       $E4                 d
                    fcb       $EA                 j
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0C
                    fcb       $99
                    fcb       $35                 5
                    fcb       $06
                    fcb       $A8                 (
                    fcb       $E4                 d
                    fcb       $E8                 h
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0C
                    fcb       $8E
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $27                 '
                    fcb       $16
                    fcb       $0C
                    fcb       $86
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $2A                 *
                    fcb       $16
                    fcb       $0C
                    fcb       $7E
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $2D                 -
                    fcb       $16
                    fcb       $0C
                    fcb       $76                 v
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $30                 0
                    fcb       $16
                    fcb       $0C
                    fcb       $6E                 n
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $33                 3
                    fcb       $16
                    fcb       $0C
                    fcb       $66                 f
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $36                 6
                    fcb       $16
                    fcb       $0C
                    fcb       $5E                 ^
                    fcb       $C6                 F
                    fcb       $05
                    fcb       $A6                 &
                    fcb       $64                 d
                    fcb       $34                 4
                    fcb       $02
                    fcb       $5A                 Z
                    fcb       $26                 &
                    fcb       $F9                 y
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $A0
                    fcb       $16
                    fcb       $0C
                    fcb       $4D                 M
                    fcb       $A6                 &
                    fcb       $64                 d
                    fcb       $88
                    fcb       $01
                    fcb       $A7                 '
                    fcb       $64                 d
                    fcb       $16
                    fcb       $0C
                    fcb       $44                 D
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $18
                    fcb       $16
                    fcb       $0C
                    fcb       $3C                 <
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $9A
                    fcb       $16
                    fcb       $0C
                    fcb       $34                 4
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $1B
                    fcb       $16
                    fcb       $0C
                    fcb       $2C                 ,
                    fcb       $A6                 &
                    fcb       $64                 d
                    fcb       $84
                    fcb       $FE
                    fcb       $A7                 '
                    fcb       $64                 d
                    fcb       $16
                    fcb       $0C
                    fcb       $23                 #
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $9D
                    fcb       $16
                    fcb       $0C
                    fcb       $1B
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $A3                 #
                    fcb       $16
                    fcb       $0C
                    fcb       $13
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $12
                    fcb       $16
                    fcb       $0C
                    fcb       $0B
                    fcb       $31                 1
                    fcb       $21                 !
                    fcb       $16
                    fcb       $0C
                    fcb       $06
                    fcb       $C6                 F
                    fcb       $20
                    fcb       $A6                 &
                    fcb       $E0                 `
                    fcb       $AA                 *
                    fcb       $E8                 h
                    fcb       $1F
                    fcb       $A7                 '
                    fcb       $E8                 h
                    fcb       $1F
                    fcb       $5A                 Z
                    fcb       $26                 &
                    fcb       $F5                 u
                    fcb       $16
                    fcb       $0B
                    fcb       $F6                 v
                    fcb       $C6                 F
                    fcb       $20
                    fcb       $A6                 &
                    fcb       $E0                 `
                    fcb       $43                 C
                    fcb       $A4                 $
                    fcb       $E8                 h
                    fcb       $1F
                    fcb       $A7                 '
                    fcb       $E8                 h
                    fcb       $1F
                    fcb       $5A                 Z
                    fcb       $26                 &
                    fcb       $F4                 t
                    fcb       $16
                    fcb       $0B
                    fcb       $E5                 e
                    fcb       $C6                 F
                    fcb       $20
                    fcb       $A6                 &
                    fcb       $E0                 `
                    fcb       $A4                 $
                    fcb       $E8                 h
                    fcb       $1F
                    fcb       $A7                 '
                    fcb       $E8                 h
                    fcb       $1F
                    fcb       $5A                 Z
                    fcb       $26                 &
                    fcb       $F5                 u
                    fcb       $16
                    fcb       $0B
                    fcb       $D5                 U
                    fcb       $35                 5
                    fcb       $04
                    fcb       $EA                 j
                    fcb       $E4                 d
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0B
                    fcb       $CC                 L
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $0F
                    fcb       $16
                    fcb       $0B
                    fcb       $C5                 E
                    fcb       $EC                 l
                    fcb       $E4                 d
                    fcb       $34                 4
                    fcb       $06
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $11
                    fcb       $16
                    fcb       $0B
                    fcb       $BA                 :
                    fcb       $A6                 &
                    fcb       $E4                 d
                    fcb       $2A                 *
                    fcb       $08
                    fcb       $4F                 O
                    fcb       $5F                 _
                    fcb       $A3                 #
                    fcb       $E4                 d
                    fcb       $29                 )
                    fcb       $05
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0B
                    fcb       $AB                 +
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $C6                 F
                    fcb       $C7                 G
                    fcb       $D7                 W
                    fcb       $D0                 P
                    fcb       $96
                    fcb       $3A                 :
                    fcb       $10
                    fcb       $27                 '
                    fcb       $0B
                    fcb       $9F
                    fcb       $16
                    fcb       $0E
                    fcb       $16
                    fcb       $EC                 l
                    fcb       $62                 b
                    fcb       $A3                 #
                    fcb       $E1                 a
                    fcb       $29                 )
                    fcb       $EB                 k
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0B
                    fcb       $91
                    fcb       $35                 5
                    fcb       $06
                    fcb       $E3                 c
                    fcb       $E4                 d
                    fcb       $29                 )
                    fcb       $E0                 `
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0B
                    fcb       $86
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $14
                    fcb       $16
                    fcb       $0B
                    fcb       $7F
                    fcb       $9E
                    fcb       $16
                    fcb       $D6                 V
                    fcb       $20
                    fcb       $86
                    fcb       $10
                    fcb       $3D                 =
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $EC                 l
                    fcb       $0A
                    fcb       $E3                 c
                    fcb       $A1                 !
                    fcb       $34                 4
                    fcb       $06
                    fcb       $16
                    fcb       $0B
                    fcb       $6D                 m
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $30                 0
                    fcb       $CB                 K
                    fcb       $35                 5
                    fcb       $04
                    fcb       $E7                 g
                    fcb       $84
                    fcb       $16
                    fcb       $0B
                    fcb       $62                 b
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
                    fcb       $0B
                    fcb       $4F                 O
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $E6                 f
                    fcb       $CB                 K
                    fcb       $34                 4
                    fcb       $04
                    fcb       $16
                    fcb       $0B
                    fcb       $46                 F
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
                    fcb       $0B
                    fcb       $33                 3
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $8D
                    fcb       $43                 C
                    fcb       $1F
                    fcb       $10
                    fcb       $E3                 c
                    fcb       $A1                 !
                    fcb       $16
                    fcb       $0B
                    fcb       $28                 (
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $8D
                    fcb       $38                 8
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $E6                 f
                    fcb       $8B
                    fcb       $34                 4
                    fcb       $04
                    fcb       $16
                    fcb       $0B
                    fcb       $1D
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $8D
                    fcb       $2B                 +
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $EC                 l
                    fcb       $8B
                    fcb       $16
                    fcb       $0B
                    fcb       $10
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $8D
                    fcb       $20
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
                    fcb       $0A
                    fcb       $FB
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
                    fcb       $0A
                    fcb       $EE                 n
L0219               fcb       $5D                 ]
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
                    fcb       $0A
                    fcb       $CE                 N
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $8D
                    fcb       $DC                 \
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $30                 0
                    fcb       $8B
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
                    fcb       $0A
                    fcb       $B7                 7
                    fcb       $DC                 \
                    fcb       $14
                    fcb       $20
                    fcb       $16
                    fcb       $35                 5
                    fcb       $06
                    fcb       $20
                    fcb       $12
                    fcb       $E6                 f
                    fcb       $22                 "
                    fcb       $8D
                    fcb       $BD                 =
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
                    fcb       $0A
                    fcb       $76                 v
                    fcb       $E6                 f
                    fcb       $22                 "
                    fcb       $8D
                    fcb       $84
                    fcb       $EC                 l
                    fcb       $23                 #
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $EC                 l
                    fcb       $A4                 $
                    fcb       $31                 1
                    fcb       $25                 %
                    fcb       $20
                    fcb       $10
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
                    fcb       $0A
                    fcb       $53                 S
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $AE                 .
                    fcb       $EB                 k
                    fcb       $8D
                    fcb       $05
                    fcb       $32                 2
                    fcb       $62                 b
                    fcb       $16
                    fcb       $0A
                    fcb       $48                 H
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
                    fcb       $1F
                    fcb       $30                 0
                    fcb       $E3                 c
                    fcb       $A1                 !
                    fcb       $16
                    fcb       $0A
                    fcb       $17
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $20
                    fcb       $07
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $20
                    fcb       $29                 )
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
                    fcb       $09
                    fcb       $EB                 k
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
                    fcb       $09
                    fcb       $C7                 G
                    fcb       $32                 2
                    fcb       $7F
                    fcb       $16
                    fcb       $09
                    fcb       $C2                 B
                    fcb       $32                 2
                    fcb       $7E
                    fcb       $16
                    fcb       $09
                    fcb       $BD                 =
                    fcb       $32                 2
                    fcb       $7B
                    fcb       $16
                    fcb       $09
                    fcb       $B8                 8
                    fcb       $86
                    fcb       $FF
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $50                 P
                    fcb       $32                 2
                    fcb       $EB                 k
                    fcb       $16
                    fcb       $09
                    fcb       $AE                 .
                    fcb       $4F                 O
                    fcb       $5F                 _
                    fcb       $A3                 #
                    fcb       $A1                 !
                    fcb       $32                 2
                    fcb       $EB                 k
                    fcb       $16
                    fcb       $09
                    fcb       $A5                 %
                    fcb       $6A                 j
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $09
                    fcb       $A0
                    fcb       $6C                 l
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $09
                    fcb       $9B
                    fcb       $EC                 l
                    fcb       $E4                 d
                    fcb       $C3                 C
                    fcb       $00
                    fcb       $01
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $09
                    fcb       $91
                    fcb       $A6                 &
                    fcb       $E4                 d
                    fcb       $AB                 +
                    fcb       $A0
                    fcb       $A7                 '
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $09
                    fcb       $88
                    fcb       $A6                 &
                    fcb       $E4                 d
                    fcb       $A0
                    fcb       $A0
                    fcb       $A7                 '
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $09
                    fcb       $7F
                    fcb       $EC                 l
                    fcb       $E4                 d
                    fcb       $A3                 #
                    fcb       $A1                 !
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $09
                    fcb       $76                 v
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $34                 4
                    fcb       $06
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $CD                 M
                    fcb       $35                 5
                    fcb       $06
                    fcb       $E3                 c
                    fcb       $E4                 d
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $09
                    fcb       $64                 d
                    fcb       $32                 2
                    fcb       $61                 a
                    fcb       $E6                 f
                    fcb       $E4                 d
                    fcb       $C4                 D
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $09
                    fcb       $59                 Y
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
                    fcb       $09
                    fcb       $3E                 >
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $9E
                    fcb       $14
                    fcb       $30                 0
                    fcb       $85
                    fcb       $34                 4
                    fcb       $10
                    fcb       $16
                    fcb       $09
                    fcb       $33                 3
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $64                 d
                    fcb       $E0                 `
                    fcb       $25                 %
                    fcb       $02
                    fcb       $31                 1
                    fcb       $AB                 +
                    fcb       $16
                    fcb       $09
                    fcb       $28                 (
                    fcb       $32                 2
                    fcb       $C4                 D
                    fcb       $35                 5
                    fcb       $40                 @
                    fcb       $35                 5
                    fcb       $24                 $
                    fcb       $D7                 W
                    fcb       $20
                    fcb       $32                 2
                    fcb       $62                 b
                    fcb       $20
                    fcb       $39                 9
                    fcb       $32                 2
                    fcb       $C4                 D
                    fcb       $35                 5
                    fcb       $40                 @
                    fcb       $35                 5
                    fcb       $24                 $
                    fcb       $D7                 W
                    fcb       $20
                    fcb       $32                 2
                    fcb       $63                 c
                    fcb       $20
                    fcb       $2D                 -
                    fcb       $32                 2
                    fcb       $C4                 D
                    fcb       $35                 5
                    fcb       $40                 @
                    fcb       $35                 5
                    fcb       $24                 $
                    fcb       $D7                 W
                    fcb       $20
                    fcb       $32                 2
                    fcb       $64                 d
                    fcb       $20
                    fcb       $21                 !
                    fcb       $E6                 f
                    fcb       $A4                 $
                    fcb       $32                 2
                    fcb       $C4                 D
                    fcb       $35                 5
                    fcb       $40                 @
                    fcb       $35                 5
                    fcb       $22                 "
                    fcb       $97
                    fcb       $20
                    fcb       $4F                 O
                    fcb       $32                 2
                    fcb       $EB                 k
                    fcb       $32                 2
                    fcb       $62                 b
                    fcb       $20
                    fcb       $10
                    fcb       $32                 2
                    fcb       $C4                 D
                    fcb       $35                 5
                    fcb       $40                 @
                    fcb       $35                 5
                    fcb       $04
                    fcb       $D7                 W
                    fcb       $20
                    fcb       $EC                 l
                    fcb       $A4                 $
                    fcb       $35                 5
                    fcb       $20
                    fcb       $32                 2
                    fcb       $EB                 k
                    fcb       $32                 2
                    fcb       $62                 b
                    fcb       $D6                 V
                    fcb       $20
                    fcb       $C1                 A
                    fcb       $FF
                    fcb       $27                 '
                    fcb       $0D
                    fcb       $86
                    fcb       $10
                    fcb       $3D                 =
                    fcb       $9E
                    fcb       $16
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $EC                 l
                    fcb       $0E
                    fcb       $10
                    fcb       $27                 '
                    fcb       $08
                    fcb       $D0                 P
                    fcb       $9E
                    fcb       $14
                    fcb       $1E
                    fcb       $12
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $35                 5
                    fcb       $04
                    fcb       $E7                 g
                    fcb       $F1                 q
                    fcb       $16
                    fcb       $08
                    fcb       $C3                 C
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
                    fcb       $08
                    fcb       $B0                 0
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $31                 1
                    fcb       $AB                 +
                    fcb       $16
                    fcb       $08
                    fcb       $A9                 )
                    fcb       $6F                 o
                    fcb       $E2                 b
                    fcb       $16
                    fcb       $08
                    fcb       $A4                 $
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $31                 1
                    fcb       $AB                 +
                    fcb       $35                 5
                    fcb       $06
                    fcb       $58                 X
                    fcb       $49                 I
                    fcb       $EC                 l
                    fcb       $AB                 +
                    fcb       $27                 '
                    fcb       $05
                    fcb       $31                 1
                    fcb       $AB                 +
                    fcb       $16
                    fcb       $08
                    fcb       $93
                    fcb       $17
                    fcb       $04
                    fcb       $44                 D
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $BE                 >
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $9E
                    fcb       $14
                    fcb       $E6                 f
                    fcb       $8B
                    fcb       $34                 4
                    fcb       $04
                    fcb       $16
                    fcb       $08
                    fcb       $82
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $9E
                    fcb       $14
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
                    fcb       $08
                    fcb       $6D                 m
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $9E
                    fcb       $14
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $35                 5
                    fcb       $04
                    fcb       $E7                 g
                    fcb       $84
                    fcb       $16
                    fcb       $08
                    fcb       $62                 b
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $9E
                    fcb       $14
                    fcb       $30                 0
                    fcb       $8B
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
                    fcb       $4D                 M
                    fcb       $35                 5
                    fcb       $10
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $A6                 &
                    fcb       $8B
                    fcb       $34                 4
                    fcb       $02
                    fcb       $16
                    fcb       $08
                    fcb       $42                 B
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
                    fcb       $08
                    fcb       $2D                 -
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
                    fcb       $08
                    fcb       $22                 "
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $08
                    fcb       $1D
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
                    fcb       $08
                    fcb       $10
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
                    fcb       $08
                    fcb       $03
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $07
                    fcb       $FE
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
                    fcb       $07
                    fcb       $F1                 q
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
                    fcb       $07
                    fcb       $E4                 d
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $07
                    fcb       $DF                 _
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
                    fcb       $07
                    fcb       $D2                 R
                    fcb       $35                 5
                    fcb       $02
                    fcb       $A0
                    fcb       $E4                 d
                    fcb       $24                 $
                    fcb       $07
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $07
                    fcb       $C5                 E
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $07
                    fcb       $C0                 @
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
                    fcb       $07
                    fcb       $B3                 3
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
                    fcb       $07
                    fcb       $A6                 &
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $07
                    fcb       $A1                 !
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
                    fcb       $07
                    fcb       $94
                    fcb       $35                 5
                    fcb       $02
                    fcb       $A0
                    fcb       $E4                 d
                    fcb       $23                 #
                    fcb       $07
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $07
                    fcb       $87
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $07
                    fcb       $82
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
                    fcb       $07
                    fcb       $75                 u
                    fcb       $C6                 F
                    fcb       $10
                    fcb       $D7                 W
                    fcb       $0A
                    fcb       $30                 0
                    fcb       $E8                 h
                    fcb       $20
                    fcb       $EC                 l
                    fcb       $83
                    fcb       $A4                 $
                    fcb       $E8                 h
                    fcb       $20
                    fcb       $E4                 d
                    fcb       $E8                 h
                    fcb       $21                 !
                    fcb       $A3                 #
                    fcb       $84
                    fcb       $26                 &
                    fcb       $2E                 .
                    fcb       $0A
                    fcb       $0A
                    fcb       $26                 &
                    fcb       $F0                 p
                    fcb       $20
                    fcb       $1E
                    fcb       $C6                 F
                    fcb       $10
                    fcb       $D7                 W
                    fcb       $0A
                    fcb       $30                 0
                    fcb       $E8                 h
                    fcb       $20
                    fcb       $EC                 l
                    fcb       $83
                    fcb       $A4                 $
                    fcb       $E8                 h
                    fcb       $20
                    fcb       $E4                 d
                    fcb       $E8                 h
                    fcb       $21                 !
                    fcb       $A3                 #
                    fcb       $E8                 h
                    fcb       $20
                    fcb       $26                 &
                    fcb       $14
                    fcb       $0A
                    fcb       $0A
                    fcb       $26                 &
                    fcb       $EF                 o
                    fcb       $20
                    fcb       $04
                    fcb       $8D
                    fcb       $1A
                    fcb       $26                 &
                    fcb       $0A
                    fcb       $32                 2
                    fcb       $E8                 h
                    fcb       $3F                 ?
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $07
                    fcb       $34                 4
                    fcb       $32                 2
                    fcb       $E8                 h
                    fcb       $3F                 ?
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $07
                    fcb       $2C                 ,
                    fcb       $8D
                    fcb       $04
                    fcb       $26                 &
                    fcb       $EA                 j
                    fcb       $20
                    fcb       $F2                 r
                    fcb       $C6                 F
                    fcb       $10
                    fcb       $D7                 W
                    fcb       $0A
                    fcb       $30                 0
                    fcb       $E8                 h
                    fcb       $22                 "
                    fcb       $EC                 l
                    fcb       $83
                    fcb       $A3                 #
                    fcb       $88
                    fcb       $20
                    fcb       $26                 &
                    fcb       $04
                    fcb       $0A
                    fcb       $0A
                    fcb       $26                 &
                    fcb       $F5                 u
                    fcb       $39                 9
                    fcb       $8D
                    fcb       $30                 0
                    fcb       $26                 &
                    fcb       $09
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $32                 2
                    fcb       $63                 c
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $07
                    fcb       $06
                    fcb       $32                 2
                    fcb       $63                 c
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $06
                    fcb       $FF
                    fcb       $8D
                    fcb       $1C
                    fcb       $26                 &
                    fcb       $EC                 l
                    fcb       $20
                    fcb       $F3                 s
                    fcb       $8D
                    fcb       $16
                    fcb       $23                 #
                    fcb       $E6                 f
                    fcb       $20
                    fcb       $ED                 m
                    fcb       $8D
                    fcb       $10
                    fcb       $22                 "
                    fcb       $E0                 `
                    fcb       $20
                    fcb       $E7                 g
                    fcb       $8D
                    fcb       $0A
                    fcb       $24                 $
                    fcb       $DA                 Z
                    fcb       $20
                    fcb       $E1                 a
                    fcb       $8D
                    fcb       $04
                    fcb       $25                 %
                    fcb       $D4                 T
                    fcb       $20
                    fcb       $DB                 [
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
                    fcb       $16
                    fcb       $09
                    fcb       $2C                 ,
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $C1                 A
                    fcb       $3B                 ;
                    fcb       $22                 "
                    fcb       $F7                 w
                    fcb       $58                 X
                    fcb       $30                 0
                    fcb       $8C
                    fcb       $04
                    fcb       $EC                 l
                    fcb       $85
                    fcb       $6E                 n
                    fcb       $8B
                    fcb       $01
                    fcb       $8D
                    fcb       $01
                    fcb       $98
                    fcb       $01
                    fcb       $A4                 $
                    fcb       $01
                    fcb       $B8                 8
                    fcb       $01
                    fcb       $C0                 @
                    fcb       $01
                    fcb       $C8                 H
                    fcb       $02
                    fcb       $39                 9
                    fcb       $01
                    fcb       $CF                 O
                    fcb       $01
                    fcb       $D6                 V
                    fcb       $01
                    fcb       $DE                 ^
                    fcb       $01
                    fcb       $28                 (
                    fcb       $01
                    fcb       $E5                 e
                    fcb       $01
                    fcb       $EC                 l
                    fcb       $01
                    fcb       $F3                 s
                    fcb       $01
                    fcb       $20
                    fcb       $01
                    fcb       $FA                 z
                    fcb       $02
                    fcb       $02
                    fcb       $02
                    fcb       $0A
                    fcb       $02
                    fcb       $34                 4
                    fcb       $02
                    fcb       $11
                    fcb       $02
                    fcb       $19
                    fcb       $02
                    fcb       $20
                    fcb       $02
                    fcb       $28                 (
                    fcb       $02
                    fcb       $2C                 ,
                    fcb       $02
                    fcb       $30                 0
                    fcb       $01
                    fcb       $75                 u
                    fcb       $01
                    fcb       $7D
                    fcb       $02
                    fcb       $40                 @
                    fcb       $00
                    fcb       $AA                 *
                    fcb       $00
                    fcb       $A2                 "
                    fcb       $00
                    fcb       $9B
                    fcb       $01
                    fcb       $30                 0
                    fcb       $00
                    fcb       $94
                    fcb       $00
                    fcb       $8D
                    fcb       $01
                    fcb       $40                 @
                    fcb       $01
                    fcb       $85
                    fcb       $01
                    fcb       $48                 H
                    fcb       $01
                    fcb       $6D                 m
                    fcb       $00
                    fcb       $E0                 `
                    fcb       $00
                    fcb       $E8                 h
                    fcb       $01
                    fcb       $38                 8
                    fcb       $01
                    fcb       $65                 e
                    fcb       $01
                    fcb       $50                 P
                    fcb       $01
                    fcb       $5E                 ^
                    fcb       $01
                    fcb       $57                 W
                    fcb       $01
                    fcb       $00
                    fcb       $00
                    fcb       $F0                 p
                    fcb       $01
                    fcb       $08
                    fcb       $00
                    fcb       $D8                 X
                    fcb       $01
                    fcb       $10
                    fcb       $00
                    fcb       $F8                 x
                    fcb       $01
                    fcb       $18
                    fcb       $00
                    fcb       $D0                 P
                    fcb       $00
                    fcb       $C1                 A
                    fcb       $00
                    fcb       $BA                 :
                    fcb       $00
                    fcb       $C8                 H
                    fcb       $00
                    fcb       $B1                 1
                    fcb       $00
                    fcb       $78                 x
                    fcb       $00
                    fcb       $7F
                    fcb       $00
                    fcb       $86
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $32                 2
                    fcb       $EB                 k
                    fcb       $16
                    fcb       $06
                    fcb       $2D                 -
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $94
                    fcb       $20
                    fcb       $21                 !
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $6C                 l
                    fcb       $20
                    fcb       $1A
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $5D                 ]
                    fcb       $20
                    fcb       $13
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $60                 `
                    fcb       $20
                    fcb       $0C
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $63                 c
                    fcb       $20
                    fcb       $05
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $66                 f
                    fcb       $16
                    fcb       $06
                    fcb       $02
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $69                 i
                    fcb       $20
                    fcb       $F6                 v
                    fcb       $D6                 V
                    fcb       $D0                 P
                    fcb       $4F                 O
                    fcb       $97
                    fcb       $D0                 P
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $20
                    fcb       $ED                 m
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $48                 H
                    fcb       $20
                    fcb       $E6                 f
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $4B                 K
                    fcb       $20
                    fcb       $DF                 _
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $4E                 N
                    fcb       $16
                    fcb       $05
                    fcb       $DC                 \
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $57                 W
                    fcb       $16
                    fcb       $05
                    fcb       $D4                 T
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $5A                 Z
                    fcb       $16
                    fcb       $05
                    fcb       $CC                 L
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $51                 Q
                    fcb       $16
                    fcb       $05
                    fcb       $C4                 D
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $54                 T
                    fcb       $16
                    fcb       $05
                    fcb       $BC                 <
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $45                 E
                    fcb       $16
                    fcb       $05
                    fcb       $B4                 4
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $42                 B
                    fcb       $16
                    fcb       $05
                    fcb       $AC                 ,
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $39                 9
                    fcb       $16
                    fcb       $05
                    fcb       $A4                 $
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $3C                 <
                    fcb       $16
                    fcb       $05
                    fcb       $9C
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $3F                 ?
                    fcb       $16
                    fcb       $05
                    fcb       $94
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $21                 !
                    fcb       $16
                    fcb       $05
                    fcb       $8C
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $24                 $
                    fcb       $16
                    fcb       $05
                    fcb       $84
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $1E
                    fcb       $16
                    fcb       $05
                    fcb       $7C
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $A6                 &
                    fcb       $16
                    fcb       $05
                    fcb       $74                 t
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $EB                 k
                    fcb       $16
                    fcb       $05
                    fcb       $6C                 l
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $EE                 n
                    fcb       $16
                    fcb       $05
                    fcb       $64                 d
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $97
                    fcb       $16
                    fcb       $05
                    fcb       $5C                 \
                    fcb       $35                 5
                    fcb       $04
                    fcb       $D7                 W
                    fcb       $37                 7
                    fcb       $16
                    fcb       $05
                    fcb       $55                 U
                    fcb       $35                 5
                    fcb       $04
                    fcb       $D7                 W
                    fcb       $3A                 :
                    fcb       $16
                    fcb       $05
                    fcb       $4E                 N
                    fcb       $35                 5
                    fcb       $04
                    fcb       $D7                 W
                    fcb       $38                 8
                    fcb       $16
                    fcb       $05
                    fcb       $47                 G
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $E5                 e
                    fcb       $16
                    fcb       $05
                    fcb       $3F                 ?
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $E8                 h
                    fcb       $16
                    fcb       $05
                    fcb       $37                 7
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $D0                 P
                    fcb       $16
                    fcb       $05
                    fcb       $2F                 /
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $DC                 \
                    fcb       $16
                    fcb       $05
                    fcb       $27                 '
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $DF                 _
                    fcb       $16
                    fcb       $05
                    fcb       $1F
                    fcb       $AE                 .
                    fcb       $E0                 `
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $C4                 D
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $05
                    fcb       $14
                    fcb       $AE                 .
                    fcb       $E0                 `
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $C4                 D
                    fcb       $02
                    fcb       $54                 T
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $05
                    fcb       $08
                    fcb       $AE                 .
                    fcb       $E0                 `
                    fcb       $E6                 f
                    fcb       $0B
                    fcb       $C4                 D
                    fcb       $0C
                    fcb       $27                 '
                    fcb       $07
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $04
                    fcb       $F9                 y
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $04
                    fcb       $F4                 t
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $AC                 ,
                    fcb       $16
                    fcb       $04
                    fcb       $EC                 l
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $A9                 )
                    fcb       $16
                    fcb       $04
                    fcb       $E4                 d
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $1A
                    fcb       $16
                    fcb       $04
                    fcb       $DD                 ]
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $06
                    fcb       $16
                    fcb       $04
                    fcb       $D6                 V
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $AF                 /
                    fcb       $16
                    fcb       $04
                    fcb       $CE                 N
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $03
                    fcb       $16
                    fcb       $04
                    fcb       $C7                 G
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $0C
                    fcb       $16
                    fcb       $04
                    fcb       $C0                 @
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $09
                    fcb       $16
                    fcb       $04
                    fcb       $B9                 9
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $84
                    fcb       $16
                    fcb       $04
                    fcb       $B2                 2
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $B2                 2
                    fcb       $16
                    fcb       $04
                    fcb       $AA                 *
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $D9                 Y
                    fcb       $16
                    fcb       $04
                    fcb       $A2                 "
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $1D
                    fcb       $16
                    fcb       $04
                    fcb       $9B
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $B5                 5
                    fcb       $16
                    fcb       $04
                    fcb       $93
                    fcb       $DC                 \
                    fcb       $12
                    fcb       $ED                 m
                    fcb       $F1                 q
                    fcb       $16
                    fcb       $04
                    fcb       $8C
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $D3                 S
                    fcb       $16
                    fcb       $04
                    fcb       $84
                    fcb       $C6                 F
                    fcb       $31                 1
                    fcb       $20
                    fcb       $09
                    fcb       $C6                 F
                    fcb       $2B                 +
                    fcb       $20
                    fcb       $05
                    fcb       $C6                 F
                    fcb       $D0                 P
                    fcb       $20
                    fcb       $01
                    fcb       $5F                 _
                    fcb       $AE                 .
                    fcb       $E4                 d
                    fcb       $E7                 g
                    fcb       $0D
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $17
                    fcb       $16
                    fcb       $04
                    fcb       $6C                 l
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $C1                 A
                    fcb       $16
                    fcb       $04
                    fcb       $64                 d
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
                    fcb       $04
                    fcb       $53                 S
                    fcb       $31                 1
                    fcb       $22                 "
                    fcb       $6F                 o
                    fcb       $E2                 b
                    fcb       $16
                    fcb       $04
                    fcb       $4C                 L
L08BB               fcb       $34                 4
                    fcb       $16
                    fcb       $AE                 .
                    fcb       $64                 d
                    fcb       $AF                 /
                    fcb       $62                 b
                    fcb       $9E
                    fcb       $16
                    fcb       $D6                 V
                    fcb       $20
                    fcb       $86
                    fcb       $10
                    fcb       $3D                 =
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $1F
                    fcb       $20
                    fcb       $A3                 #
                    fcb       $84
                    fcb       $ED                 m
                    fcb       $64                 d
                    fcb       $9E
                    fcb       $04
                    fcb       $35                 5
                    fcb       $86
                    fcb       $E6                 f
                    fcb       $E4                 d
                    fcb       $C4                 D
                    fcb       $FE
                    fcb       $10
                    fcb       $27                 '
                    fcb       $04
                    fcb       $2B                 +
                    fcb       $20
                    fcb       $1D
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
                    fcb       $04
                    fcb       $1D
                    fcb       $8D
                    fcb       $CF                 O
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $B8                 8
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
                    fcb       $04
                    fcb       $0C
                    fcb       $8D
                    fcb       $BE                 >
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $BB                 ;
L0900               fcb       $D1                 Q
                    fcb       $3C                 <
                    fcb       $24                 $
                    fcb       $1C
                    fcb       $D7                 W
                    fcb       $0A
                    fcb       $86
                    fcb       $10
                    fcb       $3D                 =
                    fcb       $9E
                    fcb       $16
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $AE                 .
                    fcb       $0E
                    fcb       $27                 '
                    fcb       $04
                    fcb       $D6                 V
                    fcb       $0A
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $96
                    fcb       $20
                    fcb       $34                 4
                    fcb       $02
                    fcb       $D6                 V
                    fcb       $0A
                    fcb       $D7                 W
                    fcb       $20
                    fcb       $16
                    fcb       $02
                    fcb       $5C                 \
                    fcb       $C6                 F
                    fcb       $DF                 _
                    fcb       $16
                    fcb       $00
                    fcb       $DB                 [
L0925               fcb       $D6                 V
                    fcb       $2F                 /
                    fcb       $27                 '
                    fcb       $16
                    fcb       $D6                 V
                    fcb       $3C                 <
                    fcb       $D7                 W
                    fcb       $0A
                    fcb       $9E
                    fcb       $16
                    fcb       $EE                 n
                    fcb       $08
                    fcb       $27                 '
                    fcb       $05
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $02
                    fcb       $25                 %
                    fcb       $14
                    fcb       $30                 0
                    fcb       $88
                    fcb       $10
                    fcb       $0A
                    fcb       $0A
                    fcb       $26                 &
                    fcb       $F0                 p
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $CA                 J
                    fcb       $DE                 ^
                    fcb       $06
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $02
                    fcb       $25                 %
                    fcb       $01
                    fcb       $5F                 _
                    fcb       $10
                    fcb       $3F                 ?
                    fcb       $06
L094F               fcb       $53                 S
                    fcb       $55                 U
                    fcb       $50                 P
                    fcb       $50                 P
                    fcb       $4F                 O
                    fcb       $52                 R
                    fcb       $D4                 T
start               equ       *
                    stu       <u0002
                    sty       <u0000
                    stx       <u000C
                    leax      -$01,y
                    stx       <u0050
                    leax      <L0925,pcr
                    stx       <u0008
                    leax      <L0900,pcr
                    stx       <u001A
                    lda       #$10
                    sta       <u00D1
                    clra
                    clrb
                    stb       <u002F
                    stb       <u0040
                    stb       <u002E
                    stb       <u0022
                    leax      <L094F,pcr
                    lda       #$21
                    os9       F$Link
                    bcc       L098F
                    cmpb      #$DD
                    bne       L098C
                    os9       F$Load
                    bcc       L098F
L098C               os9       F$Exit
L098F               sty       <u0004
                    stu       <u0006
                    lda       #$01
                    ldx       <u000C
                    os9       I$Open
                    bcc       L09AA
                    cmpb      #$D8
                    bne       L09F0
                    lda       #$21
                    ldx       <u000C
                    os9       I$Open
                    bcs       L09F0
L09AA               sta       <u003D
                    stx       <u004E
                    ldd       <u0000
                    subd      <u0002
                    std       <u003E
                    ldb       #$80
                    stb       <u0041
L09B8               ldd       <u003E
L09BA               adda      <u0041
                    bcs       L09C8
                    std       <u003E
                    os9       F$Mem
                    bcs       L09CE
                    sty       <u0000
L09C8               lsr       <u0041
                    bne       L09B8
                    bra       L09DC
L09CE               cmpb      #$CF
                    bne       L09F0
                    ldd       <u003E
                    suba      <u0041
                    lsr       <u0041
                    bne       L09BA
                    std       <u003E
L09DC               ldd       <u0002
                    addd      #$00D2
                    std       <u0016
                    ldx       <u0016
                    ldy       #$0100
                    lda       <u003D
                    os9       I$Read
                    bcc       L0A06
L09F0               stb       <u002E
                    ldb       #$CB
                    bra       L0A00
L09F6               ldb       #$CC
                    bra       L0A00
L09FA               ldb       #$7F
                    bra       L0A00
L09FE               ldb       #$CD
L0A00               clra
                    ldx       <u0004
                    jsr       <-$3C,x
L0A06               lbsr      L0C0F
                    ldx       <u0016
                    ldd       <$1C,x
                    andb      #$5F
                    subd      #$3144
                    bne       L09FA
                    ldx       <u0016
                    ldd       <$24,x
                    bne       L09FE
                    ldd       <$26,x
                    std       <u0042
                    ldd       <$28,x
                    std       <u0044
                    ldd       <$2A,x
                    std       <u0046
                    ldd       <$2C,x
                    std       <u0048
                    ldd       <$2E,x
                    std       <u0030
                    ldd       <$30,x
                    tsta
                    bne       L09F6
                    pshs      b
                    ldd       <$22,x
                    beq       L09F6
                    tsta
                    bne       L09F6
                    stb       <u003C
                    lda       #$10
                    mul
                    addd      <u0016
                    std       <u0018
                    ldu       <u0016
                    leau      <u0020,u
                    lbsr      L0B37
                    puls      b
                    stb       <u002F
                    ldu       <u0018
                    clrb
L0A5D               stb       ,-u
                    cmpu      <u0016
                    bne       L0A5D
                    ldx       <u0016
                    ldb       <u003C
                    stb       <u000A
L0A6A               pshs      x
                    ldy       #$0020
                    lda       <u003D
                    os9       I$Read
                    lbcs      L09F0
                    puls      x
                    clra
                    clrb
                    std       $08,x
                    leax      <$10,x
                    dec       <u000A
                    bne       L0A6A
                    ldx       <u0004
                    jsr       <-$1E,x
                    clr       <u0049
                    lds       <u0000
                    clr       <u0048
                    clr       <u0049
                    ldu       <u0016
                    ldb       <u003C
                    stb       <u000A
                    ldx       <u0018
L0A9C               ldd       u000E,u
                    beq       L0AA5
                    leau      <u0010,u
                    bra       L0ADF
L0AA5               tfr       x,d
                    addd      u0006,u
                    bsr       L0B2A
                    ldy       u0006,u
                    pshs      u,b,a
                    lbsr      L0B37
                    stx       ,u
                    lda       <u003D
                    os9       I$Read
                    bcs       L0B27
                    puls      u,x
                    leau      u000A,u
                    ldd       u0002,u
                    beq       L0ADD
                    tfr       x,d
                    addd      u0002,u
                    bsr       L0B2A
                    ldy       u0002,u
                    pshs      u,b,a
                    lbsr      L0B37
                    stx       ,u
                    lda       <u003D
                    os9       I$Read
                    bcs       L0B27
                    puls      u,x
L0ADD               leau      u0006,u
L0ADF               dec       <u000A
                    bne       L0A9C
                    tfr       x,d
                    addd      #$010E
                    bsr       L0B2A
                    std       <u0018
                    addd      <u0042
                    bsr       L0B2A
                    addd      <u0044
                    bsr       L0B2A
                    addd      <u0046
                    bsr       L0B2A
                    addd      #$01C5
                    bsr       L0B2A
                    addd      #$00FF
                    clrb
                    bsr       L0B2A
                    tfr       d,s
                    leas      -$01,s
                    subd      <u0002
                    os9       F$Mem
                    bcs       L0B27
                    sty       <u0000
                    lbsr      L0BA5
                    lda       <u003D
                    os9       I$Close
                    bcs       L0B27
                    ldx       <u0004
                    jsr       <-$39,x
                    ldx       <u0016
                    ldy       ,x
                    bra       L0B8C
L0B27               lbra      L09F0
L0B2A               bcs       L0B32
                    cmpd      <u0000
                    bhi       L0B32
                    rts
L0B32               ldb       #$CE
                    lbra      L0A00
L0B37               pshs      u,x,b,a
                    clra
                    ldb       ,u
                    tfr       d,x
                    clrb
                    lda       u0001,u
                    tfr       d,u
                    lda       <u003D
                    os9       I$Seek
                    bcs       L0B27
                    puls      pc,u,x,b,a
                    ldb       ,y+
                    lbsr      L0219
                    pshs      x
                    ldb       ,y+
                    cmpb      <u003C
                    bcc       L0BA2
                    ldx       <u0016
                    lda       #$10
                    mul
                    leax      d,x
                    ldx       $0E,x
                    beq       L0B74
                    sty       <u000A
                    ldb       -$01,y
                    ldy       <u0014
                    jsr       ,x
                    ldy       <u000A
                    lbra      L0D07
L0B74               ldb       -$01,y
                    lda       <u0020
                    stb       <u0020
                    pshs      y,a
                    pshs      u
                    leau      ,s
                    lda       #$10
                    mul
                    ldx       <u0016
                    leax      d,x
                    ldy       ,x
                    beq       L0BA2
L0B8C               stx       <u000C
                    clra
                    clrb
                    subd      $02,x
                    leax      d,s
                    pshs      x
                    ldx       <u000C
                    ldd       $04,x
                    ldx       <u0004
                    jsr       <-$2A,x
                    lbra      L0D07
L0BA2               lbra      L0F75
L0BA5               ldb       <u002F
                    beq       L0BF7
                    stb       <u000A
                    ldu       <u0002
                    leau      <u0030,u
                    lbsr      L0B37
L0BB3               ldx       <u0018
                    ldy       #$0080
                    lda       <u003D
                    os9       I$Read
                    lbcs      L09F0
                    ldx       <u0018
                    leax      $0C,x
                    os9       F$PrsNam
                    bcs       L0C07
L0BCB               stx       <u000C
                    leax      ,y
                    os9       F$PrsNam
                    bcc       L0BCB
                    ldx       <u0018
                    lda       $02,x
                    ldx       <u000C
                    os9       F$Link
                    bcs       L0BF8
L0BDF               ldx       <u0018
                    ldd       ,x
                    leay      d,y
                    ldb       $03,x
                    lda       #$10
                    mul
                    ldx       <u0016
                    leax      d,x
                    sty       $0E,x
                    stu       $08,x
                    dec       <u000A
                    bne       L0BB3
L0BF7               rts
L0BF8               cmpb      #$DD
                    bne       L0C07
                    ldx       <u0018
                    lda       $02,x
                    leax      $0C,x
                    os9       F$Load
                    bcc       L0BDF
L0C07               stb       <u002E
                    ldd       #$00DE
                    lbra      L0A00
L0C0F               ldx       <u0016
                    clra
                    clrb
L0C13               adda      ,x+
                    decb
                    bne       L0C13
                    tsta
                    beq       L0C21
                    ldd       #$00E3
                    lbra      L0A00
L0C21               rts
                    ldx       <u0004
                    jsr       <$15,x
                    lbra      L0D07
                    lda       ,s+
                    lbeq      L0D07
                    lbra      L0F7D
                    leax      <$20,s
                    ldd       ,x
                    tsta
                    bne       L0C56
                    lsrb
                    lsrb
                    lsrb
                    comb
                    lda       b,x
                    ldb       $01,x
                    andb      #$07
                    leax      <L0C5E,pcr
                    bita      b,x
                    beq       L0C56
                    leas      <$21,s
                    ldb       #$01
                    stb       ,s
                    lbra      L0D07
L0C56               leas      <$21,s
                    clr       ,s
                    lbra      L0D07
L0C5E               oim       #$02,<u0004
                    lsl       <u0010
                    bra       L0CA5
                    suba      #$35
                    ror       <u00DD
                    dec       <u00CC
                    neg       <u0000
                    ldx       #$0000
                    pshs      x,b,a
                    pshs      x,b,a
                    pshs      x,b,a
                    pshs      x,b,a
                    pshs      x,b,a
                    pshs      x,b,a
                    pshs      x,b,a
                    pshs      x,b,a
                    ldd       <u000A
                    tsta
                    bne       L0C97
                    leax      <L0C5E,pcr
                    andb      #$07
                    lda       b,x
                    leax      <$20,s
                    ldb       <u000B
                    lsrb
                    lsrb
                    lsrb
                    comb
                    sta       b,x
L0C97               lbra      L0D07
                    ldx       <u0014
                    ldd       $02,x
                    bra       L0D05
                    ldx       <u0014
                    ldd       ,x
                    bra       L0D05
                    ldd       u0009,u
                    bra       L0D05
                    ldd       u0007,u
                    bra       L0D05
                    puls      b,a
                    std       u0009,u
                    bra       L0D07
                    puls      b,a
                    std       u0007,u
                    bra       L0D07
                    ldb       ,y+
                    leax      b,u
                    pshs      x
                    bra       L0D07
                    ldb       ,y+
                    lda       b,u
                    pshs      a
                    bra       L0D07
                    ldb       ,y+
                    puls      a
                    sta       b,u
                    bra       L0D07
                    ldb       #$05
L0CD4               lda       ,y+
                    pshs      a
                    decb
                    bne       L0CD4
                    bra       L0D07
                    ldb       ,y+
                    sex
                    bra       L0D05
                    ldx       <u0014
                    ldb       #$B0
                    subb      -$01,y
                    ldd       b,x
                    bra       L0D05
                    ldb       #$D0
                    subb      -$01,y
                    ldd       b,u
                    bra       L0D05
                    ldb       #$F0
                    subb      -$01,y
                    leax      b,u
                    puls      b,a
                    std       ,x
                    bra       L0D07
                    ldb       -$01,y
                    subb      #$90
                    clra
L0D05               pshs      b,a
L0D07               ldb       ,y+
                    leax      <L0D75,pcr
                    abx
                    abx
                    ldd       ,x
                    jmp       d,x
                    ldb       ,s
                    eorb      #$01
                    stb       ,s
                    bra       L0D07
                    puls      b
                    andb      ,s
                    stb       ,s
                    bra       L0D07
                    ldd       ,y++
                    leax      d,u
                    puls      b,a
                    std       ,x
                    bra       L0D07
                    ldd       ,y++
                    ldd       d,u
                    bra       L0D05
                    ldd       ,s
                    subd      #$0001
                    std       ,s
                    bra       L0D07
                    ldd       ,s
                    addd      ,y++
                    std       ,s
                    bra       L0D07
                    ldb       ,y+
                    pshs      b
                    bra       L0D07
                    ldd       ,y++
                    bra       L0D05
                    ldd       ,y++
                    addd      <u0014
                    bra       L0D05
                    puls      b,a
                    std       [,s++]
                    bra       L0D07
                    ldd       ,y++
                    ldx       <u0014
                    ldd       d,x
                    bra       L0D05
                    ldd       ,y++
                    ldx       <u0014
                    leax      d,x
                    puls      b,a
                    std       ,x
                    bra       L0D07
                    puls      x
                    ldd       ,y++
                    ldd       d,x
                    bra       L0D05
L0D75               addd      >$8CF3
                    ora       <u00F3
                    adca      [w,s]
                    eora      >$F335
                    addd      >$3BF3
                    fcb       $42                 B
                    addd      >$48F3
                    fcb       $4E                 N
                    addd      >$54F3
                    fcb       $5B                 [
                    addd      >$61F3
                    asr       [?????]
                    adcb      #$F2
                    sbcb      <u00F2
                    addb      <u00F3
                    sexw
                    addd      >$9BF3
                    sbca      [,--s]
                    adda      [,--s]
                    anda      >$FF73
                    ldb       >$02F3
                    eorb      #$F3
                    jsr       <u00F3
                    lda       [,--s]
                    ldq       #$FF6FF3D4
                    ldu       >$B7FB
                    lsr       >$FE6F
                    bitb      >$ADF5
L0DB8               suba      >$FF79
                    bitb      >$B1F6
                    bhi       L0DB6
                    bge       L0DB8
                    pshu      pc,u,y,x,b,cc
                    tst       >$F580
                    bitb      >$83FB
                    tim       #$FE,<u005F
                    sbcb      >$84FF
                    fcb       $38                 8
                    ldb       >$8DFB
                    tim       #$FD,<u0077
                    eorb      >$76FE
                    cmpb      [,--s]
L0DDC               brn       L0DDC
                    bitb      [w,s]
                    addb      [w,s]
                    ldd       >$F513
                    bitb      >$37F6
                    andcc     #$F5
                    bsr       L0DE1
                    anda      <u00F5
                    aim       #u00FF,-$0C,u
                    stu       >$16F5
                    ldb       <u00F3
                    subd      <u00FA
                    cmpx      [b,s]
                    eora      <u00FE
                    stb       <u00F6
                    decb
                    ldb       >$64F5
                    addd      <u00F4
                    addb      [,s]
                    std       [a,s]
                    tst       <u00FF
                    leas      [b,s]
                    tst       >$F54C
                    stu       >$3AF5
                    adca      #$FF
                    abx
                    ldb       >$C3F6
                    addd      <u00F2
                    neg       [e,s]
                    adcb      <u00F6
                    orb       <u00F6
                    orb       [?????]
                    neg       [e,s]
                    bitb      [e,s]
                    fcb       $10
L0E27               stb       >$20F2
                    neg       [e,s]
                    adcb      [e,s]
                    beq       L0E27
                    pulu      pc,u,y,x,a
                    neg       [e,s]
                    stb       [e,s]
                    fcb       $3E                 >
                    stb       >$4EF2
                    neg       [e,s]
                    bitb      [a,s]
                    adcb      <u00F6
                    adcb      [?????]
                    neg       [e,s]
                    addb      #$F3
                    bitb      #$F3
                    addd      [,--s]
                    subb      >$F446
                    addd      >$90F3
                    adda      <u00F3
                    anda      [,s]
                    eim       #$F3,<u0045
                    ldu       >$CBF3
                    inca
                    andb      >$4CF3
                    fcb       $5B                 [
                    ldu       >$CDF3
                    neg       [,s]
                    eim       #$F6,<u0055
                    stu       >$06F6
                    incb
                    addd      >$E9F6
L0E6E               bmi       L0E6E
                    sbcb      >$F634
                    andb      >$2CF6
                    eim       #$FE,<u00E2
                    ldb       >$0CF3
                    bitb      <u00F5
                    subb      #$FE
                    andb      <u00F5
                    addd      #$F431
                    bitb      >$29F3
                    fcb       $4B                 K
                    andb      >$5EFA
                    lsr       [e,s]
                    exg       f,v
                    com       <u00F7
                    pshs      pc,u,y,x,b,a,cc
                    lsla
                    ldu       >$6BFE
                    rol       [w,s]
                    asr       [w,s]
                    eim       #$FE,$03,s
                    ldu       >$61FE
                    clrb
                    ldu       >$5DFE
                    fcb       $5B                 [
                    ldu       >$59FE
                    asrb
                    ldu       >$55FE
                    comb
                    ldu       >$51FE
                    clra
                    ldu       >$4DFE
                    fcb       $4B                 K
                    ldu       >$49FE
                    asra
                    ldu       >$45FE
                    coma
                    ldu       >$41FE
                    swi
                    fcb       $FE
                    mul
                    ldu       >$3BFE
                    rts
                    ldu       >$37FE
                    puls      pc,u,y,x,dp,b,a
                    leau      [w,s]
                    leay      [w,s]
L0ED2               ble       L0ED2
                    blt       L0ED3
                    bitb      #$FD
                    adcb      #$FE
                    rol       <u00FE
                    asr       <u00FE
                    eim       #$FE,<u0003
                    ldu       >$01FD
                    stu       >$FDFD
                    std       >$FBFD
                    adcb      >$FDF7
                    std       >$F5FD
                    addd      >$FDF1
                    std       >$EFFD
                    std       [>LFAF7,pcr]
                    adcb      [>LF6FB,pcr]
                    bitb      [>LF2FF,pcr]
                    cmpb      [>LEF03,pcr]
                    std       <u00FD
                    addb      <u00FD
                    adcb      <u00FD
                    stb       <u00FD
                    bitb      <u00FD
                    addd      <u00FD
                    cmpb      <u00FD
                    fcb       $CF                 O
                    std       >$91FD
                    subd      <u00FD
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
                    jsr       >$FDBB
                    std       >$B9FD
                    sta       >$FDB5
                    std       >$B3FD
                    cmpa      >$FDAF
                    std       >$ADFD
                    adda      [>LB943,pcr]
                    sta       [>LB547,pcr]
                    subd      [>LB14B,pcr]
                    stx       <u00FD
                    jsr       <u00FD
                    adda      <u00FD
                    adca      <u00FD
                    rolb
                    std       >$5DFD
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
                    fcb       $87
                    std       >$85FD
                    subd      #$FD81
L0F75               ldb       #$BF
                    bra       L0F83
                    ldb       #$C3
                    bra       L0F83
L0F7D               ldb       #$C5
                    bra       L0F83
                    ldb       #$C7
L0F83               clra
                    lbsr      L08BB
                    jsr       <-$3C,x
                    emod
eom                 equ       *
