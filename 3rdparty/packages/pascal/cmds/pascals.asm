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

                    nam       PascalS
                    ttl       program module

* Disassembled 02/04/05 10:05:53 by Disasm v1.6 (C) 1988 by RML

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
u0004               rmb       1
u0005               rmb       1
u0006               rmb       1
u0007               rmb       1
u0008               rmb       1
u0009               rmb       1
u000A               rmb       1
u000B               rmb       1
u000C               rmb       4
u0010               rmb       4
u0014               rmb       2
u0016               rmb       2
u0018               rmb       2
u001A               rmb       6
u0020               rmb       2
u0022               rmb       5
u0027               rmb       7
u002E               rmb       1
u002F               rmb       1
u0030               rmb       12
u003C               rmb       1
u003D               rmb       1
u003E               rmb       2
u0040               rmb       1
u0041               rmb       1
u0042               rmb       2
u0044               rmb       2
u0046               rmb       2
u0048               rmb       1
u0049               rmb       5
u004E               rmb       2
u0050               rmb       9
u0059               rmb       1
u005A               rmb       1
u005B               rmb       2
u005D               rmb       1
u005E               rmb       1
u005F               rmb       2
u0061               rmb       2
u0063               rmb       2
u0065               rmb       2
u0067               rmb       2
u0069               rmb       2
u006B               rmb       1
u006C               rmb       1
u006D               rmb       2
u006F               rmb       1
u0070               rmb       1
u0071               rmb       1
u0072               rmb       1
u0073               rmb       1
u0074               rmb       1
u0075               rmb       1
u0076               rmb       2
u0078               rmb       1
u0079               rmb       1
u007A               rmb       1
u007B               rmb       81
u00CC               rmb       5
u00D1               rmb       12
u00DD               rmb       21
u00F2               rmb       2
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
                    fcs       /PascalS/
                    fcb       $06
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $DD                 ]
                    fcb       $CE                 N
                    fcb       $16
                    fcb       $0D
                    fcb       $96
                    fcb       $35                 5
                    fcb       $06
                    fcb       $A4                 $
                    fcb       $E4                 d
                    fcb       $E4                 d
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0D
                    fcb       $8B
                    fcb       $35                 5
                    fcb       $06
                    fcb       $AA                 *
                    fcb       $E4                 d
                    fcb       $EA                 j
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0D
                    fcb       $80
                    fcb       $35                 5
                    fcb       $06
                    fcb       $A8                 (
                    fcb       $E4                 d
                    fcb       $E8                 h
                    fcb       $61                 a
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0D
                    fcb       $75                 u
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $27                 '
                    fcb       $16
                    fcb       $0D
                    fcb       $6D                 m
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $2A                 *
                    fcb       $16
                    fcb       $0D
                    fcb       $65                 e
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $2D                 -
                    fcb       $16
                    fcb       $0D
                    fcb       $5D                 ]
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $30                 0
                    fcb       $16
                    fcb       $0D
                    fcb       $55                 U
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $33                 3
                    fcb       $16
                    fcb       $0D
                    fcb       $4D                 M
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $36                 6
                    fcb       $16
                    fcb       $0D
                    fcb       $45                 E
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
                    fcb       $0D
                    fcb       $34                 4
                    fcb       $A6                 &
                    fcb       $64                 d
                    fcb       $88
                    fcb       $01
                    fcb       $A7                 '
                    fcb       $64                 d
                    fcb       $16
                    fcb       $0D
                    fcb       $2B                 +
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $18
                    fcb       $16
                    fcb       $0D
                    fcb       $23                 #
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $9A
                    fcb       $16
                    fcb       $0D
                    fcb       $1B
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $1B
                    fcb       $16
                    fcb       $0D
                    fcb       $13
                    fcb       $A6                 &
                    fcb       $64                 d
                    fcb       $84
                    fcb       $FE
                    fcb       $A7                 '
                    fcb       $64                 d
                    fcb       $16
                    fcb       $0D
                    fcb       $0A
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $9D
                    fcb       $16
                    fcb       $0D
                    fcb       $02
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $A3                 #
                    fcb       $16
                    fcb       $0C
                    fcb       $FA                 z
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $12
                    fcb       $16
                    fcb       $0C
                    fcb       $F2                 r
                    fcb       $31                 1
                    fcb       $21                 !
                    fcb       $16
                    fcb       $0C
                    fcb       $ED                 m
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
                    fcb       $0C
                    fcb       $DD                 ]
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
                    fcb       $0C
                    fcb       $CC                 L
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
                    fcb       $0C
                    fcb       $BC                 <
                    fcb       $35                 5
                    fcb       $04
                    fcb       $EA                 j
                    fcb       $E4                 d
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0C
                    fcb       $B3                 3
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $0F
                    fcb       $16
                    fcb       $0C
                    fcb       $AC                 ,
                    fcb       $EC                 l
                    fcb       $E4                 d
                    fcb       $34                 4
                    fcb       $06
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $11
                    fcb       $16
                    fcb       $0C
                    fcb       $A1                 !
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
                    fcb       $0C
                    fcb       $92
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
                    fcb       $0C
                    fcb       $86
                    fcb       $16
                    fcb       $11
                    fcb       $89
                    fcb       $EC                 l
                    fcb       $62                 b
                    fcb       $A3                 #
                    fcb       $E1                 a
                    fcb       $29                 )
                    fcb       $EB                 k
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0C
                    fcb       $78                 x
                    fcb       $35                 5
                    fcb       $06
                    fcb       $E3                 c
                    fcb       $E4                 d
                    fcb       $29                 )
                    fcb       $E0                 `
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0C
                    fcb       $6D                 m
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $14
                    fcb       $16
                    fcb       $0C
                    fcb       $66                 f
                    fcb       $9E
                    fcb       $16
                    fcb       $D6                 V
                    fcb       $20
                    fcb       $86
                    fcb       $0E
                    fcb       $3D                 =
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $D7                 W
                    fcb       $5C                 \
                    fcb       $97
                    fcb       $5D                 ]
                    fcb       $E6                 f
                    fcb       $07
                    fcb       $D7                 W
                    fcb       $5B                 [
                    fcb       $2B                 +
                    fcb       $1A
                    fcb       $9E
                    fcb       $61                 a
                    fcb       $A1                 !
                    fcb       $85
                    fcb       $27                 '
                    fcb       $17
                    fcb       $25                 %
                    fcb       $12
                    fcb       $9E
                    fcb       $63                 c
                    fcb       $E6                 f
                    fcb       $85
                    fcb       $2B                 +
                    fcb       $0C
                    fcb       $D7                 W
                    fcb       $5B                 [
                    fcb       $9E
                    fcb       $61                 a
                    fcb       $A6                 &
                    fcb       $85
                    fcb       $91
                    fcb       $5D                 ]
                    fcb       $27                 '
                    fcb       $05
                    fcb       $25                 %
                    fcb       $EE                 n
                    fcb       $17
                    fcb       $0E
                    fcb       $F8                 x
                    fcb       $96
                    fcb       $6C                 l
                    fcb       $26                 &
                    fcb       $0F
                    fcb       $D6                 V
                    fcb       $59                 Y
                    fcb       $34                 4
                    fcb       $04
                    fcb       $96
                    fcb       $5B                 [
                    fcb       $97
                    fcb       $59                 Y
                    fcb       $17
                    fcb       $0E
                    fcb       $BF                 ?
                    fcb       $35                 5
                    fcb       $04
                    fcb       $D7                 W
                    fcb       $59                 Y
                    fcb       $DC                 \
                    fcb       $5B                 [
                    fcb       $9B
                    fcb       $69                 i
                    fcb       $34                 4
                    fcb       $06
                    fcb       $16
                    fcb       $0C
                    fcb       $18
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $30                 0
                    fcb       $CB                 K
                    fcb       $35                 5
                    fcb       $04
                    fcb       $E7                 g
                    fcb       $84
                    fcb       $16
                    fcb       $0C
                    fcb       $0D
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
                    fcb       $FA                 z
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $E6                 f
                    fcb       $CB                 K
                    fcb       $34                 4
                    fcb       $04
                    fcb       $16
                    fcb       $0B
                    fcb       $F1                 q
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
                    fcb       $DE                 ^
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
                    fcb       $D3                 S
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
                    fcb       $C8                 H
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
                    fcb       $BB                 ;
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
                    fcb       $0B
                    fcb       $A6                 &
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
                    fcb       $0B
                    fcb       $99
L0255               fcb       $5D                 ]
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
                    fcb       $0B
                    fcb       $79                 y
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
                    fcb       $0B
                    fcb       $62                 b
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
                    fcb       $0B
                    fcb       $21                 !
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
                    fcb       $FE
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
                    fcb       $F3                 s
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
                    fcb       $C2                 B
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
                    fcb       $0A
                    fcb       $96
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
                    fcb       $0A
                    fcb       $72                 r
                    fcb       $32                 2
                    fcb       $7F
                    fcb       $16
                    fcb       $0A
                    fcb       $6D                 m
                    fcb       $32                 2
                    fcb       $7E
                    fcb       $16
                    fcb       $0A
                    fcb       $68                 h
                    fcb       $32                 2
                    fcb       $7B
                    fcb       $16
                    fcb       $0A
                    fcb       $63                 c
                    fcb       $86
                    fcb       $FF
                    fcb       $E6                 f
                    fcb       $A0
                    fcb       $50                 P
                    fcb       $32                 2
                    fcb       $EB                 k
                    fcb       $16
                    fcb       $0A
                    fcb       $59                 Y
                    fcb       $4F                 O
                    fcb       $5F                 _
                    fcb       $A3                 #
                    fcb       $A1                 !
                    fcb       $32                 2
                    fcb       $EB                 k
                    fcb       $16
                    fcb       $0A
                    fcb       $50                 P
                    fcb       $6A                 j
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0A
                    fcb       $4B                 K
                    fcb       $6C                 l
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0A
                    fcb       $46                 F
                    fcb       $EC                 l
                    fcb       $E4                 d
                    fcb       $C3                 C
                    fcb       $00
                    fcb       $01
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0A
                    fcb       $3C                 <
                    fcb       $A6                 &
                    fcb       $E4                 d
                    fcb       $AB                 +
                    fcb       $A0
                    fcb       $A7                 '
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0A
                    fcb       $33                 3
                    fcb       $A6                 &
                    fcb       $E4                 d
                    fcb       $A0
                    fcb       $A0
                    fcb       $A7                 '
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0A
                    fcb       $2A                 *
                    fcb       $EC                 l
                    fcb       $E4                 d
                    fcb       $A3                 #
                    fcb       $A1                 !
                    fcb       $ED                 m
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0A
                    fcb       $21                 !
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
                    fcb       $0A
                    fcb       $0F
                    fcb       $32                 2
                    fcb       $61                 a
                    fcb       $E6                 f
                    fcb       $E4                 d
                    fcb       $C4                 D
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $0A
                    fcb       $04
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
                    fcb       $E9                 i
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
                    fcb       $DE                 ^
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
L0455               fcb       $D6                 V
                    fcb       $20
                    fcb       $C1                 A
                    fcb       $FF
                    fcb       $27                 '
                    fcb       $0B
                    fcb       $86
                    fcb       $0E
                    fcb       $3D                 =
                    fcb       $9E
                    fcb       $16
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $EC                 l
                    fcb       $0C
                    fcb       $27                 '
                    fcb       $06
                    fcb       $9E
                    fcb       $14
                    fcb       $1E
                    fcb       $12
                    fcb       $6E                 n
                    fcb       $84
                    fcb       $1F
                    fcb       $20
                    fcb       $97
                    fcb       $5D                 ]
                    fcb       $97
                    fcb       $5E                 ^
                    fcb       $D7                 W
                    fcb       $5A                 Z
                    fcb       $E6                 f
                    fcb       $06
                    fcb       $D7                 W
                    fcb       $59                 Y
                    fcb       $2B                 +
                    fcb       $0A
                    fcb       $9E
                    fcb       $61                 a
                    fcb       $A1                 !
                    fcb       $85
                    fcb       $10
                    fcb       $27                 '
                    fcb       $0B
                    fcb       $F7                 w
                    fcb       $22                 "
                    fcb       $73                 s
                    fcb       $16
                    fcb       $0B
                    fcb       $F0                 p
                    fcb       $EC                 l
                    fcb       $A1                 !
                    fcb       $31                 1
                    fcb       $AB                 +
                    fcb       $1F
                    fcb       $20
                    fcb       $96
                    fcb       $5E                 ^
                    fcb       $DD                 ]
                    fcb       $7C
                    fcb       $E3                 c
                    fcb       $E4                 d
                    fcb       $E3                 c
                    fcb       $E1                 a
                    fcb       $97
                    fcb       $5D                 ]
                    fcb       $D7                 W
                    fcb       $5A                 Z
                    fcb       $91
                    fcb       $5E                 ^
                    fcb       $27                 '
                    fcb       $19
                    fcb       $97
                    fcb       $5E                 ^
                    fcb       $D6                 V
                    fcb       $59                 Y
                    fcb       $9E
                    fcb       $63                 c
                    fcb       $E6                 f
                    fcb       $85
                    fcb       $D7                 W
                    fcb       $59                 Y
                    fcb       $2B                 +
                    fcb       $0A
                    fcb       $9E
                    fcb       $61                 a
                    fcb       $A6                 &
                    fcb       $85
                    fcb       $91
                    fcb       $5D                 ]
                    fcb       $27                 '
                    fcb       $05
                    fcb       $25                 %
                    fcb       $EE                 n
                    fcb       $17
                    fcb       $0B
                    fcb       $F8                 x
                    fcb       $9E
                    fcb       $59                 Y
                    fcb       $DC                 \
                    fcb       $69                 i
                    fcb       $EC                 l
                    fcb       $8B
                    fcb       $27                 '
                    fcb       $08
                    fcb       $D3                 S
                    fcb       $7C
                    fcb       $97
                    fcb       $5D                 ]
                    fcb       $D7                 W
                    fcb       $5A                 Z
                    fcb       $20
                    fcb       $21                 !
                    fcb       $DC                 \
                    fcb       $7C
                    fcb       $34                 4
                    fcb       $06
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $BE                 >
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
                    fcb       $09
                    fcb       $13
                    fcb       $1F
                    fcb       $20
                    fcb       $96
                    fcb       $5E                 ^
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $1F
                    fcb       $10
                    fcb       $97
                    fcb       $5D                 ]
                    fcb       $D7                 W
                    fcb       $5A                 Z
                    fcb       $96
                    fcb       $5D                 ]
                    fcb       $97
                    fcb       $5E                 ^
                    fcb       $D6                 V
                    fcb       $59                 Y
                    fcb       $9E
                    fcb       $61                 a
                    fcb       $A1                 !
                    fcb       $85
                    fcb       $10
                    fcb       $27                 '
                    fcb       $0B
                    fcb       $8A
                    fcb       $25                 %
                    fcb       $14
                    fcb       $9E
                    fcb       $63                 c
                    fcb       $E6                 f
                    fcb       $85
                    fcb       $D7                 W
                    fcb       $59                 Y
                    fcb       $2B                 +
                    fcb       $1E
                    fcb       $9E
                    fcb       $61                 a
                    fcb       $A6                 &
                    fcb       $85
                    fcb       $91
                    fcb       $5D                 ]
                    fcb       $27                 '
                    fcb       $19
                    fcb       $25                 %
                    fcb       $EE                 n
                    fcb       $20
                    fcb       $12
                    fcb       $9E
                    fcb       $65                 e
                    fcb       $E6                 f
                    fcb       $85
                    fcb       $D7                 W
                    fcb       $59                 Y
                    fcb       $2B                 +
                    fcb       $0A
                    fcb       $9E
                    fcb       $61                 a
                    fcb       $A6                 &
                    fcb       $85
                    fcb       $91
                    fcb       $5D                 ]
                    fcb       $27                 '
                    fcb       $05
                    fcb       $22                 "
                    fcb       $EE                 n
                    fcb       $16
                    fcb       $0B
                    fcb       $57                 W
                    fcb       $16
                    fcb       $0B
                    fcb       $56                 V
                    fcb       $35                 5
                    fcb       $04
                    fcb       $E7                 g
                    fcb       $F1                 q
                    fcb       $16
                    fcb       $08
                    fcb       $C4                 D
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
                    fcb       $B1                 1
                    fcb       $6F                 o
                    fcb       $E2                 b
                    fcb       $16
                    fcb       $08
                    fcb       $AC                 ,
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
                    fcb       $A1                 !
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
                    fcb       $8C
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
                    fcb       $81
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
                    fcb       $6C                 l
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
                    fcb       $61                 a
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
                    fcb       $4C                 L
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
                    fcb       $41                 A
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $08
                    fcb       $3C                 <
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
                    fcb       $2F                 /
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
                    fcb       $27                 '
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
                    fcb       $25                 %
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
                    fcb       $2D                 -
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
                    fcb       $24                 $
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
                    fcb       $2C                 ,
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
                    fcb       $22                 "
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
                    fcb       $2E                 .
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
                    fcb       $23                 #
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
                    fcb       $2F                 /
                    fcb       $F5                 u
                    fcb       $C6                 F
                    fcb       $01
                    fcb       $E7                 g
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $07
                    fcb       $94
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
                    fcb       $53                 S
                    fcb       $32                 2
                    fcb       $E8                 h
                    fcb       $3F                 ?
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $07
                    fcb       $4B                 K
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
                    fcb       $25                 %
                    fcb       $32                 2
                    fcb       $63                 c
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $07
                    fcb       $1E
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
                    fcb       $0B
                    fcb       $D7                 W
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
                    fcb       $4C                 L
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
                    fcb       $21                 !
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
                    fcb       $FB
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $57                 W
                    fcb       $16
                    fcb       $05
                    fcb       $F3                 s
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $5A                 Z
                    fcb       $16
                    fcb       $05
                    fcb       $EB                 k
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $51                 Q
                    fcb       $16
                    fcb       $05
                    fcb       $E3                 c
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $54                 T
                    fcb       $16
                    fcb       $05
                    fcb       $DB                 [
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $45                 E
                    fcb       $16
                    fcb       $05
                    fcb       $D3                 S
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $42                 B
                    fcb       $16
                    fcb       $05
                    fcb       $CB                 K
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $39                 9
                    fcb       $16
                    fcb       $05
                    fcb       $C3                 C
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $3C                 <
                    fcb       $16
                    fcb       $05
                    fcb       $BB                 ;
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $3F                 ?
                    fcb       $16
                    fcb       $05
                    fcb       $B3                 3
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $21                 !
                    fcb       $16
                    fcb       $05
                    fcb       $AB                 +
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $24                 $
                    fcb       $16
                    fcb       $05
                    fcb       $A3                 #
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $1E
                    fcb       $16
                    fcb       $05
                    fcb       $9B
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $A6                 &
                    fcb       $16
                    fcb       $05
                    fcb       $93
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $EB                 k
                    fcb       $16
                    fcb       $05
                    fcb       $8B
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $EE                 n
                    fcb       $16
                    fcb       $05
                    fcb       $83
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $97
                    fcb       $16
                    fcb       $05
                    fcb       $7B
                    fcb       $35                 5
                    fcb       $04
                    fcb       $D7                 W
                    fcb       $37                 7
                    fcb       $16
                    fcb       $05
                    fcb       $74                 t
                    fcb       $35                 5
                    fcb       $04
                    fcb       $D7                 W
                    fcb       $3A                 :
                    fcb       $16
                    fcb       $05
                    fcb       $6D                 m
                    fcb       $35                 5
                    fcb       $04
                    fcb       $D7                 W
                    fcb       $38                 8
                    fcb       $16
                    fcb       $05
                    fcb       $66                 f
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $E5                 e
                    fcb       $16
                    fcb       $05
                    fcb       $5E                 ^
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $E8                 h
                    fcb       $16
                    fcb       $05
                    fcb       $56                 V
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $D0                 P
                    fcb       $16
                    fcb       $05
                    fcb       $4E                 N
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $DC                 \
                    fcb       $16
                    fcb       $05
                    fcb       $46                 F
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $DF                 _
                    fcb       $16
                    fcb       $05
                    fcb       $3E                 >
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
                    fcb       $33                 3
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
                    fcb       $27                 '
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
                    fcb       $05
                    fcb       $18
                    fcb       $6F                 o
                    fcb       $E4                 d
                    fcb       $16
                    fcb       $05
                    fcb       $13
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $AC                 ,
                    fcb       $16
                    fcb       $05
                    fcb       $0B
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $A9                 )
                    fcb       $16
                    fcb       $05
                    fcb       $03
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $1A
                    fcb       $16
                    fcb       $04
                    fcb       $FC
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $06
                    fcb       $16
                    fcb       $04
                    fcb       $F5                 u
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $AF                 /
                    fcb       $16
                    fcb       $04
                    fcb       $ED                 m
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $03
                    fcb       $16
                    fcb       $04
                    fcb       $E6                 f
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $0C
                    fcb       $16
                    fcb       $04
                    fcb       $DF                 _
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $09
                    fcb       $16
                    fcb       $04
                    fcb       $D8                 X
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $84
                    fcb       $16
                    fcb       $04
                    fcb       $D1                 Q
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $B2                 2
                    fcb       $16
                    fcb       $04
                    fcb       $C9                 I
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $D9                 Y
                    fcb       $16
                    fcb       $04
                    fcb       $C1                 A
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $1D
                    fcb       $16
                    fcb       $04
                    fcb       $BA                 :
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $B5                 5
                    fcb       $16
                    fcb       $04
                    fcb       $B2                 2
                    fcb       $DC                 \
                    fcb       $12
                    fcb       $ED                 m
                    fcb       $F1                 q
                    fcb       $16
                    fcb       $04
                    fcb       $AB                 +
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $D3                 S
                    fcb       $16
                    fcb       $04
                    fcb       $A3                 #
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
                    fcb       $8B
                    fcb       $9E
                    fcb       $04
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $C1                 A
                    fcb       $16
                    fcb       $04
                    fcb       $83
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
                    fcb       $72                 r
                    fcb       $31                 1
                    fcb       $22                 "
                    fcb       $6F                 o
                    fcb       $E2                 b
                    fcb       $16
                    fcb       $04
                    fcb       $6B                 k
L0983               fcb       $34                 4
                    fcb       $16
                    fcb       $AE                 .
                    fcb       $64                 d
                    fcb       $AF                 /
                    fcb       $62                 b
                    fcb       $1F
                    fcb       $20
                    fcb       $96
                    fcb       $5E                 ^
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
                    fcb       $53                 S
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
                    fcb       $45                 E
                    fcb       $8D
                    fcb       $D8                 X
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
                    fcb       $34                 4
                    fcb       $8D
                    fcb       $C7                 G
                    fcb       $AD                 -
                    fcb       $88
                    fcb       $BB                 ;
L09BF               fcb       $D1                 Q
                    fcb       $3C                 <
                    fcb       $24                 $
                    fcb       $1C
                    fcb       $D7                 W
                    fcb       $0A
                    fcb       $86
                    fcb       $0E
                    fcb       $3D                 =
                    fcb       $9E
                    fcb       $16
                    fcb       $30                 0
                    fcb       $8B
                    fcb       $AE                 .
                    fcb       $0C
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
                    fcb       $68                 h
                    fcb       $C6                 F
                    fcb       $DF                 _
                    fcb       $16
                    fcb       $00
                    fcb       $F3                 s
L09E4               fcb       $D6                 V
                    fcb       $2F                 /
                    fcb       $27                 '
                    fcb       $15
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
                    fcb       $13
                    fcb       $30                 0
                    fcb       $0E
                    fcb       $0A
                    fcb       $0A
                    fcb       $26                 &
                    fcb       $F1                 q
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
L0A0D               fcb       $53                 S
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
                    leax      <L09E4,pcr
                    stx       <u0008
                    leax      <L09BF,pcr
                    stx       <u001A
                    lda       #$0E
                    sta       <u00D1
                    clra
                    clrb
                    stb       <u002F
                    stb       <u0040
                    stb       <u002E
                    stb       <u0022
                    leax      <L0A0D,pcr
                    lda       #$21
                    os9       F$Link
                    bcc       L0A4D
                    cmpb      #$DD
                    bne       L0A4A
                    os9       F$Load
                    bcc       L0A4D
L0A4A               os9       F$Exit
L0A4D               sty       <u0004
                    stu       <u0006
                    lda       #$01
                    ldx       <u000C
                    os9       I$Open
                    bcc       L0A68
                    cmpb      #$D8
                    bne       L0AC7
                    lda       #$21
                    ldx       <u000C
                    os9       I$Open
                    bcs       L0AC7
L0A68               sta       <u003D
                    stx       <u004E
                    ldd       <u0000
                    subd      <u0002
                    std       <u003E
                    ldb       #$80
                    stb       <u0041
L0A76               ldd       <u003E
L0A78               adda      <u0041
                    bcs       L0A86
                    std       <u003E
                    os9       F$Mem
                    bcs       L0A8C
                    sty       <u0000
L0A86               lsr       <u0041
                    bne       L0A76
                    bra       L0A9A
L0A8C               cmpb      #$CF
                    bne       L0AC7
                    ldd       <u003E
                    suba      <u0041
                    lsr       <u0041
                    bne       L0A78
                    std       <u003E
L0A9A               ldd       <u0002
                    addd      #$00D2
                    std       <u005F
                    addd      #$0080
                    std       <u0061
                    addd      #$0080
                    std       <u0063
                    addd      #$0080
                    std       <u0065
                    addd      #$0080
                    std       <u0067
                    addd      #$0080
                    std       <u0016
                    ldx       <u0016
                    ldy       #$0100
                    lda       <u003D
                    os9       I$Read
                    bcc       L0ADD
L0AC7               stb       <u002E
                    ldb       #$CB
                    bra       L0AD7
L0ACD               ldb       #$CC
                    bra       L0AD7
L0AD1               ldb       #$7F
                    bra       L0AD7
L0AD5               ldb       #$CD
L0AD7               clra
                    ldx       <u0004
                    jsr       <-$3C,x
L0ADD               lbsr      L0CF6
                    ldx       <u0016
                    ldd       <$1C,x
                    andb      #$5F
                    subd      #$3144
                    bne       L0AD1
                    ldx       <u0016
                    ldd       <$24,x
                    bne       L0AD5
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
                    bne       L0ACD
                    pshs      b
                    ldd       <$22,x
                    beq       L0ACD
                    tsta
                    bne       L0ACD
                    stb       <u003C
                    lda       #$0E
                    mul
                    addd      <u0016
                    addd      #$00FF
                    clrb
                    std       <u0069
                    std       <u0018
                    ldu       <u0016
                    leau      <u0020,u
                    lbsr      L0BF5
                    puls      b
                    stb       <u002F
                    ldu       <u0069
                    clrb
L0B3A               stb       ,-u
                    cmpu      <u005F
                    bne       L0B3A
                    ldx       <u0016
                    ldb       <u003C
                    stb       <u000A
L0B47               pshs      x
                    ldy       #$0020
                    lda       <u003D
                    os9       I$Read
                    lbcs      L0AC7
                    puls      x
                    clra
                    clrb
                    std       $08,x
                    ldd       $0E,x
                    std       $0C,x
                    lda       #$FF
                    sta       $06,x
                    sta       $07,x
                    leax      $0E,x
                    dec       <u000A
                    bne       L0B47
                    ldx       <u0004
                    jsr       <-$1E,x
                    clr       <u0049
                    lds       <u0000
                    lda       <u0048
                    sta       <u006C
                    clrb
                    addd      <u0069
                    bsr       L0BE8
                    std       <u0018
                    ldx       <u0063
                    ldb       <u0048
                    lda       #$01
L0B87               sta       ,x+
                    inca
                    decb
                    bne       L0B87
                    lda       #$FF
                    sta       -$01,x
                    ldd       <u0018
                    addd      #$010E
                    bsr       L0BE8
                    std       <u0018
                    addd      <u0042
                    bsr       L0BE8
                    addd      <u0044
                    bsr       L0BE8
                    addd      <u0046
                    bsr       L0BE8
                    addd      #$01C5
                    bsr       L0BE8
                    addd      #$00FF
                    clrb
                    bsr       L0BE8
                    tfr       d,s
                    leas      -$01,s
                    subd      <u0002
                    os9       F$Mem
                    bcs       L0BE5
                    sty       <u0000
                    lbsr      L0C8C
                    ldx       <u0004
                    jsr       <-$39,x
                    ldx       <u0016
                    clra
                    clrb
                    sta       <u006B
                    sta       <u005D
                    sta       <u005A
                    sta       <u005E
                    subd      $02,x
                    leax      d,s
                    pshs      x
                    ldx       <u0016
                    ldd       $04,x
                    ldx       <u0004
                    jsr       <-$2A,x
                    lbra      L1077
L0BE5               lbra      L0AC7
L0BE8               bcs       L0BF0
                    cmpd      <u0000
                    bhi       L0BF0
                    rts
L0BF0               ldb       #$CE
                    lbra      L0AD7
L0BF5               pshs      u,x,b,a
                    clra
                    ldb       ,u
                    tfr       d,x
                    clrb
                    lda       u0001,u
                    tfr       d,u
                    lda       <u003D
                    os9       I$Seek
                    bcs       L0BE5
                    puls      pc,u,x,b,a
                    ldb       ,y+
                    lbsr      L0255
                    pshs      x
                    ldb       ,y+
                    cmpb      <u003C
                    bcc       L0C89
                    ldx       <u0016
                    lda       #$0E
                    mul
                    leax      d,x
                    ldx       $0C,x
                    beq       L0C35
                    tfr       y,d
                    lda       <u005E
                    std       <u000A
                    ldb       -$01,y
                    ldy       <u0014
                    jsr       ,x
                    ldy       <u000A
                    lbra      L0455
L0C35               ldb       -$01,y
                    lda       <u0020
                    pshs      a
                    stb       <u0020
                    tfr       y,d
                    lda       <u005E
                    tfr       d,y
                    puls      a
                    pshs      y,a
                    pshs      u
                    leau      ,s
                    lda       #$0E
                    ldb       <u0020
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
                    ldx       <u0004
                    jsr       <-$2A,x
                    clra
                    sta       <u005A
                    sta       <u005E
                    sta       <u005D
                    ldb       <u0020
                    lda       #$0E
                    mul
                    ldx       <u0016
                    leax      d,x
                    ldb       $06,x
                    bmi       L0C86
                    ldx       <u0061
                    lda       b,x
                    bne       L0C86
                    stb       <u0059
                    lbra      L1079
L0C86               lbra      L1077
L0C89               lbra      L12E8
L0C8C               ldb       <u002F
                    beq       L0CDE
                    stb       <u000A
                    ldu       <u0002
                    leau      <u0030,u
                    lbsr      L0BF5
L0C9A               ldx       <u0018
                    ldy       #$0080
                    lda       <u003D
                    os9       I$Read
                    lbcs      L0AC7
                    ldx       <u0018
                    leax      $0C,x
                    os9       F$PrsNam
                    bcs       L0CEE
L0CB2               stx       <u000C
                    leax      ,y
                    os9       F$PrsNam
                    bcc       L0CB2
                    ldx       <u0018
                    lda       $02,x
                    ldx       <u000C
                    os9       F$Link
                    bcs       L0CDF
L0CC6               ldx       <u0018
                    ldd       ,x
                    leay      d,y
                    ldb       $03,x
                    lda       #$0E
                    mul
                    ldx       <u0016
                    leax      d,x
                    sty       $0C,x
                    stu       $08,x
                    dec       <u000A
                    bne       L0C9A
L0CDE               rts
L0CDF               cmpb      #$DD
                    bne       L0CEE
                    ldx       <u0018
                    lda       $02,x
                    leax      $0C,x
                    os9       F$Load
                    bcc       L0CC6
L0CEE               stb       <u002E
                    ldd       #$00DE
                    lbra      L0AD7
L0CF6               ldx       <u0016
                    clra
                    clrb
L0CFA               adda      ,x+
                    decb
                    bne       L0CFA
                    tsta
                    beq       L0D08
                    ldd       #$00E3
                    lbra      L0AD7
L0D08               rts
                    ldx       <u0004
                    jsr       <$15,x
                    lbra      L0DEE
                    lda       ,s+
                    lbeq      L0DEE
                    lbra      L12F0
                    leax      <$20,s
                    ldd       ,x
                    tsta
                    bne       L0D3D
                    lsrb
                    lsrb
                    lsrb
                    comb
                    lda       b,x
                    ldb       $01,x
                    andb      #$07
                    leax      <L0D45,pcr
                    bita      b,x
                    beq       L0D3D
                    leas      <$21,s
                    ldb       #$01
                    stb       ,s
                    lbra      L0DEE
L0D3D               leas      <$21,s
                    clr       ,s
                    lbra      L0DEE
L0D45               oim       #$02,<u0004
                    lsl       <u0010
                    bra       L0D8C
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
                    bne       L0D7E
                    leax      <L0D45,pcr
                    andb      #$07
                    lda       b,x
                    leax      <$20,s
                    ldb       <u000B
                    lsrb
                    lsrb
                    lsrb
                    comb
                    sta       b,x
L0D7E               lbra      L0DEE
                    ldx       <u0014
                    ldd       $02,x
                    bra       L0DEC
                    ldx       <u0014
                    ldd       ,x
                    bra       L0DEC
                    ldd       u0009,u
                    bra       L0DEC
                    ldd       u0007,u
                    bra       L0DEC
                    puls      b,a
                    std       u0009,u
                    bra       L0DEE
                    puls      b,a
                    std       u0007,u
                    bra       L0DEE
                    ldb       ,y+
                    leax      b,u
                    pshs      x
                    bra       L0DEE
                    ldb       ,y+
                    lda       b,u
                    pshs      a
                    bra       L0DEE
                    ldb       ,y+
                    puls      a
                    sta       b,u
                    bra       L0DEE
                    ldb       #$05
L0DBB               lda       ,y+
                    pshs      a
                    decb
                    bne       L0DBB
                    bra       L0DEE
                    ldb       ,y+
                    sex
                    bra       L0DEC
                    ldx       <u0014
                    ldb       #$B0
                    subb      -$01,y
                    ldd       b,x
                    bra       L0DEC
                    ldb       #$D0
                    subb      -$01,y
                    ldd       b,u
                    bra       L0DEC
                    ldb       #$F0
                    subb      -$01,y
                    leax      b,u
                    puls      b,a
                    std       ,x
                    bra       L0DEE
                    ldb       -$01,y
                    subb      #$90
                    clra
L0DEC               pshs      b,a
L0DEE               ldb       ,y+
                    leax      <L0E5C,pcr
                    abx
                    abx
                    ldd       ,x
                    jmp       d,x
                    ldb       ,s
                    eorb      #$01
                    stb       ,s
                    bra       L0DEE
                    puls      b
                    andb      ,s
                    stb       ,s
                    bra       L0DEE
                    ldd       ,y++
                    leax      d,u
                    puls      b,a
                    std       ,x
                    bra       L0DEE
                    ldd       ,y++
                    ldd       d,u
                    bra       L0DEC
                    ldd       ,s
                    subd      #$0001
                    std       ,s
                    bra       L0DEE
                    ldd       ,s
                    addd      ,y++
                    std       ,s
                    bra       L0DEE
                    ldb       ,y+
                    pshs      b
                    bra       L0DEE
                    ldd       ,y++
                    bra       L0DEC
                    ldd       ,y++
                    addd      <u0014
                    bra       L0DEC
                    puls      b,a
                    std       [,s++]
                    bra       L0DEE
                    ldd       ,y++
                    ldx       <u0014
                    ldd       d,x
                    bra       L0DEC
                    ldd       ,y++
                    ldx       <u0014
                    leax      d,x
                    puls      b,a
                    std       ,x
                    bra       L0DEE
                    puls      x
                    ldd       ,y++
                    ldd       d,x
                    bra       L0DEC
L0E5C               sbcb      >$A5F2
                    subd      >$F2C2
                    ldu       >$B8F2
                    fcb       $4E                 N
                    sbcb      >$54F2
                    fcb       $5B                 [
                    sbcb      >$61F2
                    asr       [?????]
                    tst       [?????]
                    lsr       >$F27A
                    sbcb      >$80F1
                    sbcb      [,s++]
                    addb      [,s++]
                    andb      >$F22D
                    sbcb      >$B4F2
                    adda      >$F2C4
                    sbcb      >$CDFF
                    com       >$F557
                    sbcb      >$E1F2
                    lda       >$F2BF
                    sbcb      >$E6FF
                    clr       [?????]
                    std       [w,s]
                    sta       >$FB4C
                    ldu       >$6FF5
                    aim       #$F5,<u0005
                    stu       >$79F5
                    ror       <u00F5
                    inc       [b,s]
                    ror       >$F580
                    andb      >$D2F4
                    bitb      <u00F4
                    eorb      <u00FA
                    addd      [w,s]
                    clrb
                    cmpb      >$9DFF
                    fcb       $38                 8
                    ldb       >$85FA
                    addd      [>L5DB7,pcr]
                    asrb
                    ldu       >$E1F2
                    abx
                    ldu       >$E5FE
                    addb      [w,s]
                    ldd       >$F468
                    andb      >$8CF5
L0ECF               ror       [,s]
                    sbcb      [,s]
                    adcb      [,s]
L0ED5               sta       >$FF54
                    oim       #$84,<u00F5
                    bmi       L0ECF
                    cmpx      [f,s]
                    bsr       L0ED5
                    std       [w,s]
                    stb       <u00F5
                    addb      [b,s]
                    cmpa      [b,s]
                    addb      [,s]
                    nega
                    andb      >$42F5
                    asrb
                    stu       >$32F4
                    sbcb      <u00F4
                    cmpa      [>$3AF4]
                    ldu       <u00FF
                    abx
                    ldb       >$A4F6
                    anda      >$F179
                    stb       >$BAF6
                    adda      >$F6CB
                    cmpb      >$79F7
                    ldb       #$F6
                    cmpb      >$F701
                    cmpb      >$79F7
                    orb       #$F7
                    lsl       <u00F7
                    fcb       $18
                    cmpb      >$79F7
                    eorb      #$F7
                    tfr       f,v
                    ble       L0F12
                    rol       >$F7C6
                    ldb       >$BAF6
                    orb       #$F1
                    rol       >$F7AC
                    addd      >$1AF3
                    fcb       $38                 8
                    addd      >$45F3
                    adda      <u00F2
                    bitb      [?????]
                    subb      >$F2F9
                    addd      >$5AF2
                    ora       <u00FE
                    addb      #$F2
                    cmpa      [,--s]
                    cmpa      [?????]
                    suba      >$FECD
                    sbcb      >$B5F3
                    decb
                    ldb       >$36FF
                    ror       <u00F6
                    mul
                    addd      >$3EF6
                    inc       <u00FE
                    sbcb      >$F615
L0F5A               addd      >$81F5
                    ldb       [w,s]
                    sbcb      [b,s]
                    std       [,--s]
                    bpl       L0F5A
                    stx       >$FED4
                    bitb      >$C2F3
                    lda       #$F4
                    jmp       >$F2A0
                    addd      >$B3FA
                    cwai      #$F6
                    stu       >$F6E4
                    stb       >$15F7
L0F7B               bvs       L0F7B
                    tim       #$FE,$09,s
                    ldu       >$67FE
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
L0FB9               ble       L0FB9
                    blt       L0FBA
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
                    std       [>LFBDE,pcr]
                    adcb      [>LF7E2,pcr]
                    bitb      [>LF3E6,pcr]
                    cmpb      [>LEFEA,pcr]
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
                    adda      [>LBA2A,pcr]
                    sta       [>LB62E,pcr]
                    subd      [>LB232,pcr]
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
                    clr       <u005A
                    ldb       <u0059
                    lda       <u005E
                    inca
                    sta       <u005D
                    sta       <u005E
                    ldx       <u0063
                    lda       b,x
                    bmi       L1077
                    sta       <u0059
                    ldx       <u0061
                    lda       a,x
                    cmpa      <u005D
                    beq       L1079
L1077               bsr       L10AE
L1079               lda       <u006C
                    bne       L107F
                    bsr       L1088
L107F               ldd       <u0059
                    adda      <u0069
                    tfr       d,y
                    lbra      L0DEE
L1088               clrb
                    ldx       <u005F
L108B               lda       b,x
                    cmpb      <u0059
                    beq       L10A1
                    tsta
                    beq       L1099
                    deca
                    sta       b,x
                    bne       L109B
L1099               inc       <u006C
L109B               incb
                    cmpb      <u0048
                    bne       L108B
                    rts
L10A1               inca
                    beq       L109B
                    cmpa      #$01
                    bne       L10AA
                    dec       <u006C
L10AA               sta       b,x
                    bra       L109B
L10AE               lda       #$FE
                    bra       L10B4
                    lda       #$FF
L10B4               sta       <u0075
                    lda       <u006B
                    bmi       L1101
                    sta       <u0070
                    clrb
                    adda      <u0069
                    std       <u006D
                    ldx       <u0063
                    ldb       <u006B
                    lda       b,x
                    sta       <u006B
                    lbra      L11AA
L10CC               ldb       <u006F
                    lda       #$0E
                    mul
                    ldx       <u0016
                    leax      d,x
                    stx       <u000C
L10D7               ldb       $07,x
                    bmi       L114E
                    ldx       <u0063
                    cmpb      <u0070
                    bne       L10EC
                    ldb       <u0070
                    lda       b,x
                    ldx       <u000C
                    sta       $07,x
                    lbra      L11AA
L10EC               stb       <u0072
                    ldb       b,x
                    bmi       L114E
                    cmpb      <u0070
                    bne       L10EC
                    ldb       <u0070
                    lda       b,x
                    ldb       <u0072
                    sta       b,x
                    lbra      L11AA
L1101               lda       #$FF
                    sta       <u0073
                    sta       <u0074
                    lda       <u0020
                    ldb       #$0E
                    mul
                    ldx       <u0016
                    leax      d,x
                    lda       $07,x
                    sta       <u0027
                    clr       <u0070
L1116               ldb       <u0070
                    ldx       <u005F
                    lda       b,x
                    cmpa      <u0073
                    bhi       L1142
                    cmpb      <u0059
                    beq       L1142
                    std       <u000A
                    ldx       <u0067
                    lda       b,x
                    cmpa      <u0020
                    bne       L113C
                    lda       <u0027
                    bmi       L113C
                    ldx       <u0063
L1134               cmpa      <u000B
                    beq       L1142
                    lda       a,x
                    bpl       L1134
L113C               ldd       <u000A
                    sta       <u0073
                    stb       <u0074
L1142               inc       <u0070
                    ldb       <u0070
                    cmpb      <u0048
                    bne       L1116
                    ldb       <u0074
                    bpl       L1154
L114E               ldd       #$00CF
                    lbra      L0AD7
L1154               ldx       <u0067
                    stb       <u0070
                    lda       b,x
                    sta       <u006F
                    tfr       b,a
                    clrb
                    adda      <u0069
                    std       <u006D
                    ldb       <u006F
                    lda       #$0E
                    mul
                    ldx       <u0016
                    leax      d,x
                    stx       <u000C
                    ldb       $06,x
                    lbmi      L10D7
                    ldx       <u0063
                    cmpb      <u0070
                    bne       L118C
                    ldb       <u0070
                    ldb       b,x
                    ldx       <u000C
                    stb       $06,x
                    bmi       L11AA
                    ldx       <u0065
                    lda       #$FF
                    sta       b,x
                    bra       L11AA
L118C               stb       <u0072
                    ldb       b,x
                    lbmi      L10CC
                    cmpb      <u0070
                    bne       L118C
                    ldx       <u0063
                    ldb       <u0070
                    lda       b,x
                    ldb       <u0072
                    sta       b,x
                    bmi       L11AA
                    ldx       <u0065
                    ldb       <u0072
                    stb       a,x
L11AA               ldb       <u0020
                    lda       #$0E
                    mul
                    ldx       <u0016
                    leax      d,x
                    stx       <u0076
                    lda       <u0075
                    cmpa      #$FF
                    bne       L11C5
                    ldd       $0A,x
                    addb      <u005D
                    adca      #$00
                    std       <u0079
                    bra       L11CD
L11C5               ldd       ,x
                    addb      <u005D
                    adca      #$00
                    std       <u0079
L11CD               clra
                    sta       <u0078
                    sta       <u007B
                    ldx       <u005F
                    ldb       <u0070
                    lda       b,x
                    bne       L11DC
                    dec       <u006C
L11DC               pshs      u,y
                    ldx       <u0078
                    ldu       <u007A
                    lda       <u003D
                    os9       I$Seek
L11E7               ldu       ,s
                    lbcs      L0AC7
                    ldx       <u006D
                    ldy       #$0100
                    lda       <u003D
                    os9       I$Read
                    bcs       L11E7
                    puls      u,y
                    lda       #$FF
                    sta       <u0072
                    lda       <u0075
                    cmpa      #$FF
                    bne       L125F
                    lda       <u0070
                    sta       <u005B
                    ldx       <u0076
                    ldb       $07,x
                    bpl       L121F
                    ldb       <u0070
                    stb       $07,x
                    ldx       <u0063
                    lda       #$FF
                    sta       b,x
                    lbra      L12D3
L121D               tfr       a,b
L121F               ldx       <u0061
                    lda       b,x
                    cmpa      <u005D
                    bhi       L123C
                    stb       <u0072
                    ldx       <u0063
                    lda       b,x
                    bpl       L121D
                    lda       <u0070
                    sta       b,x
                    ldx       <u0063
                    ldb       #$FF
                    stb       a,x
                    lbra      L12D3
L123C               ldb       <u0072
                    bpl       L124F
                    ldx       <u0076
                    ldb       <u0070
                    lda       $07,x
                    stb       $07,x
                    ldx       <u0063
                    sta       b,x
                    lbra      L12D3
L124F               ldx       <u0063
                    lda       b,x
                    sta       <u0071
                    lda       <u0070
                    sta       b,x
                    ldb       <u0071
                    stb       a,x
                    bra       L12D3
L125F               lda       <u0070
                    sta       <u0059
                    ldx       <u0076
                    ldb       $06,x
                    bpl       L127B
                    lda       <u0070
                    sta       $06,x
                    ldx       <u0063
                    ldb       #$FF
                    stb       a,x
                    ldx       <u0065
                    stb       a,x
                    bra       L12D3
L1279               tfr       a,b
L127B               ldx       <u0061
                    lda       b,x
                    cmpa      <u005D
                    bhi       L129D
                    stb       <u0072
                    ldx       <u0063
                    lda       b,x
                    bpl       L1279
                    lda       <u0070
                    sta       b,x
                    ldx       <u0065
                    ldb       <u0072
                    stb       a,x
                    ldx       <u0063
                    ldb       #$FF
                    stb       a,x
                    bra       L12D3
L129D               ldb       <u0072
                    bpl       L12BB
                    ldx       <u0076
                    ldb       <u0070
                    lda       $06,x
                    sta       <u0071
                    stb       $06,x
                    ldx       <u0063
                    sta       b,x
                    ldx       <u0065
                    lda       #$FF
                    sta       b,x
                    lda       <u0071
                    stb       a,x
                    bra       L12D3
L12BB               ldx       <u0063
                    lda       b,x
                    sta       <u0071
                    lda       <u0070
                    sta       b,x
                    ldb       <u0071
                    stb       a,x
                    ldx       <u0065
                    ldb       <u0072
                    stb       a,x
                    ldb       <u0071
                    sta       b,x
L12D3               ldx       <u005F
                    ldb       <u0070
                    lda       #$FF
                    sta       b,x
                    ldx       <u0067
                    lda       <u0020
                    sta       b,x
                    ldx       <u0061
                    lda       <u005D
                    sta       b,x
                    rts
L12E8               ldb       #$BF
                    bra       L12F6
                    ldb       #$C3
                    bra       L12F6
L12F0               ldb       #$C5
                    bra       L12F6
                    ldb       #$C7
L12F6               clra
                    lbsr      L0983
                    jsr       <-$3C,x
                    emod
eom                 equ       *
