********************************************************************
* font - f256standard font
*
* Original by Micah at https://github.com/WartyMN/Foenix-Fonts
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024-09-28  Port from by John Federico
* Created.
*   2      2025-01-07  Added custom NitrOS-9 and Basic09 custom fonts $01-15
*          by Matt Massie

               nam       f256standardfont
               ttl       f256 standard font

               use       defsfile

tylg           set       Data
atrv           set       ReEnt+rev
rev            set       $01

               mod       eom,name,tylg,atrv,start,0

name           fcs       /f256standardfont/

start

               fcb $00,$00,$00,$00,$00,$00,$00,$00
               fcb $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
               fcb $C0,$C0,$C0,$C0,$C0,$C0,$C0,$FF
               fcb $07,$1F,$3F,$7F,$7F,$FF,$FF,$FF
               fcb $FF,$FF,$FF,$7F,$7F,$3F,$1F,$07
               fcb $E0,$F8,$FC,$FE,$FE,$FF,$FF,$FF
               fcb $FF,$FF,$FF,$FE,$FE,$FC,$F8,$E0
               fcb $0F,$1F,$3F,$7F,$7F,$3F,$1F,$0F
               fcb $FF,$FE,$FC,$F8,$F0,$E0,$C0,$80
               fcb $FF,$7F,$3F,$1F,$0F,$07,$03,$01
               fcb $80,$C0,$E0,$F0,$F8,$FC,$FE,$FF
               fcb $FF,$FF,$FE,$FC,$FC,$FE,$FF,$FF
               fcb $FF,$FE,$FC,$F8,$F0,$F0,$F0,$F0
               fcb $0F,$0F,$0F,$0F,$1F,$3F,$7F,$FF
               fcb $F0,$F0,$F0,$F0,$F8,$FC,$FE,$FF
               fcb $FF,$7F,$3F,$1F,$0F,$0F,$0F,$0F
               fcb $01,$03,$07,$0F,$1F,$3F,$7F,$FF
               fcb $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               fcb $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
               fcb $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
               fcb $FF,$FF,$FF,$FF,$00,$00,$00,$00
               fcb $FF,$FE,$FC,$F8,$F0,$E0,$C0,$80     end
               fcb $00,$00,$00,$00,$00,$00,$00,$FF
               fcb $AF,$FF,$BB,$FF,$AF,$FF,$BB,$FF
               fcb $77,$FF,$DD,$FF,$77,$FF,$DD,$FF
               fcb $7F,$FF,$DF,$FF,$77,$FF,$DF,$FF
               fcb $FF,$FF,$DF,$FF,$77,$FF,$DD,$FF
               fcb $BB,$FF,$EE,$FF,$AA,$FF,$AA,$FF
               fcb $AA,$FF,$AA,$77,$AA,$DD,$AA,$55
               fcb $AA,$55,$22,$55,$88,$55,$00,$55
               fcb $AA,$00,$AA,$00,$88,$00,$22,$00
               fcb $00,$00,$00,$00,$00,$FF,$FF,$FF
               fcb $00,$00,$00,$00,$00,$00,$00,$00
               fcb $08,$08,$08,$08,$00,$00,$08,$00
               fcb $24,$24,$24,$00,$00,$00,$00,$00
               fcb $24,$24,$7E,$24,$7E,$24,$24,$00
               fcb $08,$1E,$28,$1C,$0A,$3C,$08,$00
               fcb $00,$62,$64,$08,$10,$26,$46,$00
               fcb $30,$48,$48,$30,$4A,$44,$3A,$00
               fcb $08,$08,$08,$00,$00,$00,$00,$00
               fcb $04,$08,$10,$10,$10,$08,$04,$00
               fcb $20,$10,$08,$08,$08,$10,$20,$00
               fcb $00,$2A,$1C,$3E,$1C,$2A,$00,$00
               fcb $00,$08,$08,$3E,$08,$08,$00,$00
               fcb $00,$00,$00,$00,$00,$08,$08,$10
               fcb $00,$00,$00,$7E,$00,$00,$00,$00
               fcb $00,$00,$00,$00,$00,$18,$18,$00
               fcb $00,$02,$04,$08,$10,$20,$40,$00
               fcb $3C,$42,$46,$5A,$62,$42,$3C,$00
               fcb $08,$18,$08,$08,$08,$08,$1C,$00
               fcb $3C,$42,$02,$3C,$40,$40,$7E,$00
               fcb $3C,$42,$02,$1C,$02,$42,$3C,$00
               fcb $04,$44,$44,$44,$7E,$04,$04,$00
               fcb $7E,$40,$40,$7C,$02,$02,$7C,$00
               fcb $3C,$40,$40,$7C,$42,$42,$3C,$00
               fcb $7E,$42,$04,$08,$10,$10,$10,$00
               fcb $3C,$42,$42,$3C,$42,$42,$3C,$00
               fcb $3C,$42,$42,$3E,$02,$02,$3C,$00
               fcb $00,$00,$08,$00,$00,$08,$00,$00
               fcb $00,$00,$08,$00,$00,$08,$08,$10
               fcb $08,$10,$20,$40,$20,$10,$08,$00
               fcb $00,$00,$7E,$00,$7E,$00,$00,$00
               fcb $10,$08,$04,$02,$04,$08,$10,$00
               fcb $3C,$42,$02,$0C,$10,$00,$10,$00
               fcb $3C,$42,$4E,$52,$4E,$40,$3C,$00
               fcb $3C,$42,$42,$7E,$42,$42,$42,$00
               fcb $7C,$42,$42,$7C,$42,$42,$7C,$00
               fcb $3C,$42,$40,$40,$40,$42,$3C,$00
               fcb $7C,$42,$42,$42,$42,$42,$7C,$00
               fcb $7E,$40,$40,$78,$40,$40,$7E,$00
               fcb $7E,$40,$40,$78,$40,$40,$40,$00
               fcb $3C,$42,$40,$4E,$42,$42,$3C,$00
               fcb $42,$42,$42,$7E,$42,$42,$42,$00
               fcb $1C,$08,$08,$08,$08,$08,$1C,$00
               fcb $0E,$04,$04,$04,$04,$44,$38,$00
               fcb $42,$44,$48,$70,$48,$44,$42,$00
               fcb $40,$40,$40,$40,$40,$40,$7E,$00
               fcb $41,$63,$55,$49,$41,$41,$41,$00
               fcb $42,$62,$52,$4A,$46,$42,$42,$00
               fcb $3C,$42,$42,$42,$42,$42,$3C,$00
               fcb $7C,$42,$42,$7C,$40,$40,$40,$00
               fcb $3C,$42,$42,$42,$4A,$44,$3A,$00
               fcb $7C,$42,$42,$7C,$48,$44,$42,$00
               fcb $3C,$42,$40,$3C,$02,$42,$3C,$00
               fcb $3E,$08,$08,$08,$08,$08,$08,$00
               fcb $42,$42,$42,$42,$42,$42,$3C,$00
               fcb $41,$41,$41,$22,$22,$14,$08,$00
               fcb $41,$41,$41,$49,$55,$63,$41,$00
               fcb $42,$42,$24,$18,$24,$42,$42,$00
               fcb $41,$22,$14,$08,$08,$08,$08,$00
               fcb $7F,$02,$04,$08,$10,$20,$7F,$00
               fcb $3C,$20,$20,$20,$20,$20,$3C,$00
               fcb $00,$40,$20,$10,$08,$04,$02,$00
               fcb $3C,$04,$04,$04,$04,$04,$3C,$00
               fcb $00,$08,$14,$22,$00,$00,$00,$00
               fcb $00,$00,$00,$00,$00,$00,$00,$FF
               fcb $10,$08,$04,$00,$00,$00,$00,$00
               fcb $00,$00,$3C,$02,$3E,$42,$3E,$00
               fcb $40,$40,$7C,$42,$42,$42,$7C,$00
               fcb $00,$00,$3C,$40,$40,$40,$3C,$00
               fcb $02,$02,$3E,$42,$42,$42,$3E,$00
               fcb $00,$00,$3C,$42,$7E,$40,$3C,$00
               fcb $0C,$10,$10,$7C,$10,$10,$10,$00
               fcb $00,$00,$3E,$42,$42,$3E,$02,$3C
               fcb $40,$40,$7C,$42,$42,$42,$42,$00
               fcb $08,$00,$18,$08,$08,$08,$08,$00
               fcb $04,$00,$0C,$04,$04,$04,$04,$38
               fcb $40,$40,$44,$48,$50,$68,$44,$00
               fcb $18,$08,$08,$08,$08,$08,$1C,$00
               fcb $00,$00,$76,$49,$49,$49,$49,$00
               fcb $00,$00,$7C,$42,$42,$42,$42,$00
               fcb $00,$00,$3C,$42,$42,$42,$3C,$00
               fcb $00,$00,$7C,$42,$42,$7C,$40,$40
               fcb $00,$00,$3E,$42,$42,$3E,$02,$02
               fcb $00,$00,$5C,$60,$40,$40,$40,$00
               fcb $00,$00,$3E,$40,$3C,$02,$7C,$00
               fcb $10,$10,$7C,$10,$10,$10,$0C,$00
               fcb $00,$00,$42,$42,$42,$42,$3E,$00
               fcb $00,$00,$42,$42,$42,$24,$18,$00
               fcb $00,$00,$41,$49,$49,$49,$36,$00
               fcb $00,$00,$42,$24,$18,$24,$42,$00
               fcb $00,$00,$42,$42,$42,$3E,$02,$3C
               fcb $00,$00,$7E,$04,$18,$20,$7E,$00
               fcb $0C,$10,$10,$20,$10,$10,$0C,$00
               fcb $10,$10,$10,$10,$10,$10,$10,$00
               fcb $30,$08,$08,$04,$08,$08,$30,$00
               fcb $00,$00,$30,$49,$06,$00,$00,$00
               fcb $08,$04,$04,$08,$10,$10,$08,$00
               fcb $02,$02,$02,$02,$02,$02,$02,$02
               fcb $04,$04,$04,$04,$04,$04,$04,$04
               fcb $08,$08,$08,$08,$08,$08,$08,$08
               fcb $10,$10,$10,$10,$10,$10,$10,$10
               fcb $20,$20,$20,$20,$20,$20,$20,$20
               fcb $40,$40,$40,$40,$40,$40,$40,$40
               fcb $80,$80,$80,$80,$80,$80,$80,$80
               fcb $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
               fcb $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
               fcb $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
               fcb $F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8
               fcb $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC
               fcb $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE
               fcb $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
               fcb $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F
               fcb $1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F
               fcb $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
               fcb $07,$07,$07,$07,$07,$07,$07,$07
               fcb $03,$03,$03,$03,$03,$03,$03,$03
               fcb $01,$01,$01,$01,$01,$01,$01,$01
               fcb $00,$00,$00,$00,$00,$00,$FF,$00
               fcb $00,$00,$00,$00,$00,$FF,$00,$00
               fcb $00,$00,$00,$00,$FF,$00,$00,$00
               fcb $00,$00,$00,$FF,$00,$00,$00,$00
               fcb $00,$00,$FF,$00,$00,$00,$00,$00
               fcb $00,$FF,$00,$00,$00,$00,$00,$00
               fcb $08,$08,$08,$08,$0F,$08,$08,$08
               fcb $00,$00,$00,$00,$FF,$08,$08,$08
               fcb $08,$08,$08,$08,$FF,$08,$08,$08
               fcb $08,$08,$08,$08,$FF,$00,$00,$00
               fcb $08,$08,$08,$08,$F8,$08,$08,$08
               fcb $81,$42,$24,$18,$18,$24,$42,$81
               fcb $00,$00,$00,$00,$0F,$08,$08,$08
               fcb $00,$00,$00,$00,$F8,$08,$08,$08
               fcb $08,$08,$08,$08,$0F,$00,$00,$00
               fcb $08,$08,$08,$08,$F8,$00,$00,$00
               fcb $18,$18,$18,$1F,$1F,$18,$18,$18
               fcb $00,$00,$00,$FF,$FF,$18,$18,$18
               fcb $18,$18,$18,$FF,$FF,$18,$18,$18
               fcb $18,$18,$18,$FF,$FF,$00,$00,$00
               fcb $18,$18,$18,$F8,$F8,$18,$18,$18
               fcb $00,$00,$00,$1F,$1F,$18,$18,$18
               fcb $00,$00,$00,$F8,$F8,$18,$18,$18
               fcb $18,$18,$18,$1F,$1F,$00,$00,$00
               fcb $18,$18,$18,$F8,$F8,$00,$00,$00
               fcb $00,$00,$00,$FF,$FF,$00,$00,$00
               fcb $18,$18,$18,$18,$18,$18,$18,$18
               fcb $00,$00,$00,$00,$03,$07,$0F,$0F
               fcb $00,$00,$00,$00,$C0,$E0,$F0,$F0
               fcb $0F,$0F,$07,$03,$00,$00,$00,$00
               fcb $F0,$F0,$E0,$C0,$00,$00,$00,$00
               fcb $00,$3C,$42,$42,$42,$42,$3C,$00
               fcb $00,$3C,$7E,$7E,$7E,$7E,$3C,$00
               fcb $00,$7E,$7E,$7E,$7E,$7E,$7E,$00
               fcb $00,$00,$00,$18,$18,$00,$00,$00
               fcb $00,$00,$00,$00,$08,$00,$00,$00
               fcb $FF,$7F,$3F,$1F,$0F,$07,$03,$01
               fcb $FF,$FE,$FC,$F8,$F0,$E0,$C0,$80
               fcb $80,$40,$20,$10,$08,$04,$02,$01
               fcb $01,$02,$04,$08,$10,$20,$40,$80
               fcb $00,$00,$00,$00,$03,$04,$08,$08
               fcb $00,$00,$00,$00,$E0,$10,$08,$08
               fcb $08,$08,$08,$04,$03,$00,$00,$00
               fcb $08,$08,$08,$10,$E0,$00,$00,$00
               fcb $00,$00,$00,$00,$00,$00,$00,$55
               fcb $00,$00,$00,$00,$00,$00,$AA,$55
               fcb $00,$00,$00,$00,$00,$55,$AA,$55
               fcb $00,$00,$00,$00,$AA,$55,$AA,$55
               fcb $00,$00,$00,$55,$AA,$55,$AA,$55
               fcb $00,$00,$AA,$55,$AA,$55,$AA,$55
               fcb $00,$55,$AA,$55,$AA,$55,$AA,$55
               fcb $AA,$55,$AA,$55,$AA,$55,$AA,$55
               fcb $AA,$55,$AA,$55,$AA,$55,$AA,$00
               fcb $AA,$55,$AA,$55,$AA,$55,$00,$00
               fcb $AA,$55,$AA,$55,$AA,$00,$00,$00
               fcb $AA,$55,$AA,$55,$00,$00,$00,$00
               fcb $AA,$55,$AA,$00,$00,$00,$00,$00
               fcb $AA,$55,$00,$00,$00,$00,$00,$00
               fcb $AA,$00,$00,$00,$00,$00,$00,$00
               fcb $80,$00,$80,$00,$80,$00,$80,$00
               fcb $80,$40,$80,$40,$80,$40,$80,$40
               fcb $A0,$40,$A0,$40,$A0,$40,$A0,$40
               fcb $A0,$50,$A0,$50,$A0,$50,$A0,$50
               fcb $A8,$50,$A8,$50,$A8,$50,$A8,$50
               fcb $A8,$54,$A8,$54,$A8,$54,$A8,$54
               fcb $AA,$54,$AA,$54,$AA,$54,$AA,$54
               fcb $2A,$55,$2A,$55,$2A,$55,$2A,$55
               fcb $7E,$81,$9D,$A1,$A1,$9D,$81,$7E
               fcb $2A,$15,$2A,$15,$2A,$15,$2A,$15
               fcb $0A,$15,$0A,$15,$0A,$15,$0A,$15
               fcb $0A,$05,$0A,$05,$0A,$05,$0A,$05
               fcb $02,$05,$02,$05,$02,$05,$02,$05
               fcb $02,$01,$02,$01,$02,$01,$02,$01
               fcb $00,$01,$00,$01,$00,$01,$00,$01
               fcb $00,$00,$03,$06,$6C,$38,$10,$00
               fcb $7E,$81,$BD,$A1,$B9,$A1,$A1,$7E
               fcb $00,$00,$3C,$3C,$3C,$3C,$00,$00
               fcb $00,$3C,$42,$5A,$5A,$42,$3C,$00
               fcb $00,$00,$18,$3C,$3C,$18,$00,$00
               fcb $FF,$81,$81,$81,$81,$81,$81,$FF
               fcb $01,$03,$07,$0F,$1F,$3F,$7F,$FF
               fcb $80,$C0,$E0,$F0,$F8,$FC,$FE,$FF
               fcb $3F,$1F,$0F,$07,$03,$01,$00,$00
               fcb $FC,$F8,$F0,$E0,$C0,$80,$00,$00
               fcb $00,$00,$01,$03,$07,$0F,$1F,$3F
               fcb $00,$00,$80,$C0,$E0,$F0,$F8,$FC
               fcb $0F,$07,$03,$01,$00,$00,$00,$00
               fcb $F0,$E0,$C0,$80,$00,$00,$00,$00
               fcb $00,$00,$00,$00,$01,$03,$07,$0F
               fcb $00,$00,$00,$00,$80,$C0,$E0,$F0
               fcb $03,$01,$00,$00,$00,$00,$00,$00
               fcb $C0,$80,$00,$00,$00,$00,$00,$00
               fcb $00,$00,$00,$00,$00,$00,$01,$03
               fcb $00,$00,$00,$00,$00,$00,$80,$C0
               fcb $00,$00,$00,$00,$0F,$0F,$0F,$0F
               fcb $00,$00,$00,$00,$F0,$F0,$F0,$F0
               fcb $0F,$0F,$0F,$0F,$00,$00,$00,$00
               fcb $F0,$F0,$F0,$F0,$00,$00,$00,$00
               fcb $F0,$F0,$F0,$F0,$0F,$0F,$0F,$0F
               fcb $0F,$0F,$0F,$0F,$F0,$F0,$F0,$F0
               fcb $00,$00,$00,$3E,$1C,$08,$00,$00
               fcb $00,$00,$08,$18,$38,$18,$08,$00
               fcb $00,$00,$10,$18,$1C,$18,$10,$00
               fcb $00,$00,$08,$1C,$3E,$00,$00,$00
               fcb $36,$7F,$7F,$7F,$3E,$1C,$08,$00
               fcb $08,$1C,$3E,$7F,$3E,$1C,$08,$00
               fcb $08,$1C,$3E,$7F,$7F,$1C,$3E,$00
               fcb $08,$1C,$2A,$77,$2A,$08,$1C,$00

               emod
eom            equ       *
               end
