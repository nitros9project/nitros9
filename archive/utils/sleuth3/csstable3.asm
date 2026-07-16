
***************************************
**
* optabx represents 680x&6502 opcode names as three
* 5-bit fields packed together and also contains
* a 1-bit flag for special operations.
optab0              equ       *                   6800/1 opcodes
                    fcb       $08,$80,$09,$06,$09,$08,$0b,$88
                    fcb       $0c,$c0,$0c,$d8,$0c,$e4,$10,$c0
                    fcb       $11,$62,$11,$ca,$11,$e8,$12,$00
                    fcb       $12,$68,$13,$00,$13,$0a,$13,$28
                    fcb       $13,$40,$13,$8a,$14,$00,$14,$80
                    fcb       $14,$e4,$15,$80,$18,$80,$1b,$00
                    fcb       $1b,$24,$1b,$60,$1b,$da,$1c,$00
                    fcb       $20,$40,$21,$40,$21,$46,$2b,$e4
                    fcb       $4b,$80,$4b,$86,$53,$60,$54,$e4
                    fcb       $61,$00,$61,$02,$64,$e4,$6d,$40
                    fcb       $71,$4e,$73,$e0,$7c,$82,$84,$d0
                    fcb       $85,$58,$93,$c0,$93,$d8,$93,$e4
                    fcb       $95,$00,$98,$80,$98,$86,$99,$40
                    fcb       $9d,$00,$9d,$02,$9d,$44,$9d,$c0
                    fcb       $a0,$40,$a0,$60,$a0,$80,$a4,$00
                    fcb       $a4,$c0,$a4,$e8,$a6,$00,$b8,$40
optab2              equ       *                   6502 opcodes
                    fcb       $09,$06,$0b,$88,$0c,$d8,$10,$c6
                    fcb       $10,$e6,$11,$62,$12,$68,$13,$52
                    fcb       $13,$8a,$14,$18,$14,$96,$15,$86
                    fcb       $15,$a6,$1b,$06,$1b,$08,$1b,$12
                    fcb       $1b,$2c,$1b,$60,$1c,$30,$1c,$32
                    fcb       $21,$46,$21,$70,$21,$72,$2b,$e4
                    fcb       $4b,$86,$4b,$b0,$4b,$b2,$53,$60
                    fcb       $54,$e4,$61,$02,$61,$30,$61,$32
                    fcb       $64,$e4,$73,$e0,$7c,$82,$82,$02
                    fcb       $82,$20,$83,$02,$83,$20,$93,$d8
                    fcb       $93,$e4,$95,$12,$95,$26,$98,$86
                    fcb       $99,$46,$99,$48,$99,$52,$9d,$02
                    fcb       $9d,$30,$9d,$32,$a0,$70,$a0,$72
                    fcb       $a4,$f0,$a6,$02,$a6,$26,$a6,$42
optab5              equ       *                   [14]6805 opcodes
                    fcb       $09,$06,$09,$08,$0b,$88,$0c,$e4
                    fcb       $10,$c6,$10,$e6,$11,$62,$12,$06
                    fcb       $12,$12,$12,$50,$12,$58,$12,$68
                    fcb       $13,$26,$13,$46,$13,$52,$13,$66
                    fcb       $13,$8a,$14,$18,$14,$82,$14,$9c
                    fcb       $14,$e4,$1b,$06,$1b,$12,$1b,$24
                    fcb       $1b,$60,$1b,$da,$1c,$30,$21,$46
                    fcb       $2b,$e4,$4b,$86,$53,$60,$54,$e4
                    fcb       $61,$02,$61,$30,$64,$d8,$64,$e4
                    fcb       $71,$4e,$73,$e0,$7c,$82,$93,$d8
                    fcb       $93,$e4,$94,$e0,$95,$12,$95,$26
                    fcb       $98,$86,$99,$46,$99,$52,$99,$68
                    fcb       $9d,$02,$9d,$1e,$9d,$30,$9d,$44
                    fcb       $9d,$d2,$a0,$70,$a4,$e8,$a6,$02
                    fcb       $b8,$52
optab9              equ       *                   6809 opcodes
                    fcb       $08,$b0,$09,$06,$09,$08,$0b,$88
                    fcb       $0c,$d8,$0c,$e4,$10,$c6,$10,$e6
                    fcb       $11,$62,$11,$ca,$11,$e8,$12,$12
                    fcb       $12,$68,$13,$0a,$13,$26,$13,$28
                    fcb       $13,$52,$13,$8a,$14,$18,$14,$82
                    fcb       $14,$9c,$14,$e4,$15,$86,$15,$a6
                    fcb       $1b,$24,$1b,$60,$1b,$da,$1d,$c3
                    fcb       $20,$42,$21,$46,$2b,$e4,$2e,$0f
                    fcb       $4b,$86,$53,$60,$54,$e4,$61,$00
                    fcb       $61,$42,$64,$e4,$6d,$58,$71,$4e
                    fcb       $73,$e0,$7c,$80,$84,$d1,$85,$59
                    fcb       $93,$d8,$93,$e4,$95,$12,$95,$26
                    fcb       $98,$86,$99,$70,$9d,$00,$9d,$44
                    fcb       $9d,$d2,$9e,$5c,$a1,$a5,$a4,$e8
* suftax contains 680x suffixes for instr names
suftb5              fcb       $00,$00,$61,$00,$63,$00,$73,$00 nu a  c  s
                    fcb       $70,$00,$74,$00,$78,$00,$79,$00 p  t  x  y
suftb9              fcb       $00,$00,$61,$00,$62,$00,$63,$00 nu a  b  c
                    fcb       $63,$63,$64,$00,$69,$00,$6c,$00 cc d  i  l
                    fcb       $73,$00,$75,$00,$78,$00,$79,$00 s  u  x  y
                    fcb       $4e,$00,$32,$00,$33,$00,$76,$00 n  2  3  v
* tfrexc contains 6809 reg names for tfr and exc
tfrexc              fcb       $64,$00,$78,$00,$79,$00,$75,$00 d  x  y  u
                    fcb       $73,$00,$70,$63,$00,$00,$00,$00 s  pc nu nu
                    fcb       $61,$00,$62,$00,$63,$63,$64,$70 a  b  cc dp
* intab0 represents 6800 instructions
* as 2-byte fields, as followso
* byte 1 bits 0-5: pointer to optab0
*        bits 6-7  length
* byte 2 bits 0-3: suffix
*                  (sp,a,b,cc,d,i,l,s,u,x,y,1,2,3)
*        bit 4:    6801 flag
*        bits 5-7: mode (inh,dir,ext,imm,inx,rel)
intab0              equ       *
                    fcb       $00,$00,$a5,$01,$00,$00,$00,$00 00
                    fcb       $99,$59,$15,$59,$e5,$01,$ed,$11 04
                    fcb       $81,$a1,$75,$a1,$5d,$f1,$cd,$f1 08
                    fcb       $5d,$31,$cd,$31,$5d,$61,$cd,$61 0c
                    fcb       $c5,$11,$59,$11,$00,$00,$00,$00 10
                    fcb       $00,$00,$00,$00,$e1,$21,$e9,$11 14
                    fcb       $00,$00,$71,$11,$00,$00,$01,$11 18
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00 1c
                    fcb       $4e,$16,$4e,$ce,$2e,$66,$36,$86 20
                    fcb       $1e,$36,$1e,$86,$46,$06,$22,$06 24
                    fcb       $56,$36,$56,$86,$4a,$76,$42,$66 28
                    fcb       $26,$06,$3e,$06,$2a,$06,$3a,$06 2c
                    fcb       $f1,$a1,$81,$81,$b1,$11,$b1,$21 30
                    fcb       $75,$81,$f9,$81,$ad,$11,$ad,$21 34
                    fcb       $b1,$a9,$c1,$81,$01,$a9,$c1,$61 38
                    fcb       $ad,$a9,$9d,$79,$fd,$61,$dd,$61 3c
                    fcb       $a1,$11,$00,$00,$00,$00,$69,$11 40
                    fcb       $99,$11,$00,$00,$bd,$11,$19,$11 44
                    fcb       $15,$11,$b9,$11,$79,$11,$00,$00 48
                    fcb       $85,$11,$f5,$11,$00,$00,$61,$11 4c
                    fcb       $a1,$21,$00,$00,$00,$00,$69,$21 50
                    fcb       $99,$21,$00,$00,$bd,$21,$19,$21 54
                    fcb       $15,$21,$b9,$21,$79,$21,$00,$00 58
                    fcb       $85,$21,$f5,$21,$00,$00,$61,$21 5c
                    fcb       $a2,$05,$00,$00,$00,$00,$6a,$05 60
                    fcb       $9a,$05,$00,$00,$be,$05,$1a,$05 64
                    fcb       $12,$75,$b6,$75,$76,$35,$00,$00 68
                    fcb       $82,$35,$f6,$05,$8a,$05,$62,$05 6c
                    fcb       $a3,$03,$00,$00,$00,$00,$6b,$03 70
                    fcb       $9b,$03,$00,$00,$bf,$03,$1b,$03 74
                    fcb       $13,$73,$b7,$73,$77,$33,$00,$00 78
                    fcb       $83,$33,$f7,$03,$8b,$03,$63,$03 7c
                    fcb       $da,$14,$66,$14,$ca,$14,$db,$54 80
                    fcb       $0e,$14,$32,$14,$96,$14,$00,$00 84
                    fcb       $7e,$14,$06,$14,$aa,$14,$0a,$14 88
                    fcb       $6f,$a4,$52,$06,$93,$84,$00,$00 8c
                    fcb       $da,$12,$66,$12,$ca,$12,$da,$5a 90
                    fcb       $0e,$12,$32,$12,$96,$12,$d6,$12 94
                    fcb       $7e,$12,$06,$12,$aa,$12,$0a,$12 98
                    fcb       $6e,$a2,$8e,$0a,$92,$82,$d2,$82 9c
                    fcb       $da,$15,$66,$15,$ca,$15,$da,$5d a0
                    fcb       $0e,$15,$32,$15,$96,$15,$d6,$15 a4
                    fcb       $7e,$15,$06,$15,$aa,$15,$0a,$15 a8
                    fcb       $6e,$a5,$8e,$05,$92,$85,$d2,$85 ac
                    fcb       $db,$13,$67,$13,$cb,$13,$db,$5b b0
                    fcb       $0f,$13,$33,$13,$97,$13,$d7,$13 b4
                    fcb       $7f,$13,$07,$13,$ab,$13,$0b,$13 b8
                    fcb       $6f,$a3,$8f,$03,$93,$83,$d3,$83 bc
                    fcb       $da,$24,$66,$24,$ca,$24,$0b,$5c c0
                    fcb       $0e,$24,$32,$24,$96,$24,$00,$00 c4
                    fcb       $7e,$24,$06,$24,$aa,$24,$0a,$24 c8
                    fcb       $93,$5c,$00,$00,$93,$a4,$00,$00 cc
                    fcb       $da,$22,$66,$22,$ca,$22,$0a,$5a d0
                    fcb       $0e,$22,$32,$22,$96,$22,$d6,$22 d4
                    fcb       $7e,$22,$06,$22,$aa,$22,$0a,$22 d8
                    fcb       $92,$5a,$d2,$5a,$92,$a2,$d2,$a2 dc
                    fcb       $da,$25,$66,$25,$ca,$25,$0a,$5d e0
                    fcb       $0e,$25,$32,$25,$96,$25,$d6,$25 e4
                    fcb       $7e,$25,$06,$25,$aa,$25,$0a,$25 e8
                    fcb       $92,$5d,$d2,$5d,$92,$a5,$d2,$a5 ec
                    fcb       $db,$23,$67,$23,$cb,$23,$0b,$53 f0
                    fcb       $0f,$23,$33,$23,$97,$23,$d7,$23 f4
                    fcb       $7f,$23,$07,$23,$ab,$23,$0b,$23 f8
                    fcb       $93,$5b,$d3,$5b,$93,$a3,$d3,$a3 fc
* intab2 represents 6502 instructions
* as 2-byte fields, as follows:
* byte 1 bits 0-5: pointer to optab2
*        bits 6-7  length
* byte 2 bits 0-3: suffix (sp,a,c,s,p,t,x,y)
*        bits 5-7: mode (inh,dir,ext,imm,
*                        inx,rel,ixi,ini)
intab2              equ       *
                    fcb       $29,$01,$8a,$67,$00,$00,$00,$00 00
                    fcb       $00,$00,$8a,$02,$0a,$02,$00,$00 04
                    fcb       $91,$01,$8a,$04,$09,$01,$00,$00 08
                    fcb       $00,$00,$8b,$03,$0b,$03,$00,$00 0c
                    fcb       $26,$06,$8a,$78,$00,$00,$00,$00 10
                    fcb       $00,$00,$8a,$62,$0a,$62,$00,$00 14
                    fcb       $35,$01,$8b,$73,$00,$00,$00,$00 18
                    fcb       $00,$00,$8b,$63,$0b,$63,$00,$00 1c
                    fcb       $73,$03,$06,$67,$00,$00,$00,$00 20
                    fcb       $1a,$02,$06,$02,$9e,$02,$00,$00 24
                    fcb       $99,$01,$06,$04,$9d,$01,$00,$00 28
                    fcb       $1b,$03,$07,$03,$9f,$03,$00,$00 2c
                    fcb       $1e,$06,$06,$78,$00,$00,$00,$00 30
                    fcb       $00,$00,$06,$62,$9e,$62,$00,$00 34
                    fcb       $b1,$01,$07,$73,$00,$00,$00,$00 38
                    fcb       $00,$00,$07,$63,$9f,$63,$00,$00 3c
                    fcb       $a5,$01,$5e,$67,$00,$00,$00,$00 40
                    fcb       $00,$00,$5e,$02,$82,$02,$00,$00 44
                    fcb       $8d,$01,$5e,$04,$81,$01,$00,$00 48
                    fcb       $6f,$03,$5f,$03,$83,$03,$00,$00 4c
                    fcb       $2e,$06,$5e,$78,$00,$00,$00,$00 50
                    fcb       $00,$00,$5e,$62,$82,$62,$00,$00 54
                    fcb       $3d,$01,$5f,$73,$00,$00,$00,$00 58
                    fcb       $00,$00,$5f,$63,$83,$63,$00,$00 5c
                    fcb       $a9,$01,$02,$67,$00,$00,$00,$00 60
                    fcb       $00,$00,$02,$02,$a2,$02,$00,$00 64
                    fcb       $95,$01,$02,$04,$a1,$01,$00,$00 68
                    fcb       $6f,$08,$03,$03,$a3,$03,$00,$00 6c
                    fcb       $32,$06,$02,$78,$00,$00,$00,$00 70
                    fcb       $00,$00,$02,$62,$a2,$62,$00,$00 74
                    fcb       $b9,$01,$03,$73,$00,$00,$00,$00 78
                    fcb       $00,$00,$03,$63,$a3,$63,$00,$00 7c
                    fcb       $00,$00,$be,$67,$00,$00,$00,$00 80
                    fcb       $c6,$02,$be,$02,$c2,$02,$00,$00 84
                    fcb       $59,$01,$00,$00,$d5,$01,$00,$00 88
                    fcb       $c7,$03,$bf,$03,$c3,$03,$00,$00 8c
                    fcb       $0e,$06,$be,$78,$00,$00,$00,$00 90
                    fcb       $c6,$62,$be,$62,$c2,$72,$00,$00 94
                    fcb       $dd,$01,$bf,$73,$d9,$01,$00,$00 98
                    fcb       $00,$00,$bf,$63,$00,$00,$00,$00 9c
                    fcb       $7e,$04,$76,$67,$7a,$04,$00,$00 a0
                    fcb       $7e,$02,$76,$02,$7a,$02,$00,$00 a4
                    fcb       $cd,$01,$76,$04,$c9,$01,$00,$00 a8
                    fcb       $7f,$03,$77,$03,$7b,$03,$00,$00 ac
                    fcb       $12,$06,$76,$78,$00,$00,$00,$00 b0
                    fcb       $7e,$62,$76,$62,$7a,$72,$00,$00 b4
                    fcb       $41,$01,$77,$73,$d1,$01,$00,$00 b8
                    fcb       $7f,$63,$77,$63,$7b,$73,$00,$00 bc
                    fcb       $4e,$04,$46,$67,$00,$00,$00,$00 c0
                    fcb       $4e,$02,$46,$02,$52,$02,$00,$00 c4
                    fcb       $69,$01,$46,$04,$55,$01,$00,$00 c8
                    fcb       $4f,$03,$47,$03,$53,$03,$00,$00 cc
                    fcb       $22,$06,$46,$78,$00,$00,$00,$00 d0
                    fcb       $00,$00,$46,$62,$52,$62,$00,$00 d4
                    fcb       $39,$01,$47,$73,$00,$00,$00,$00 d8
                    fcb       $00,$00,$47,$63,$53,$63,$00,$00 dc
                    fcb       $4a,$04,$ae,$67,$00,$00,$00,$00 e0
                    fcb       $4a,$02,$ae,$02,$62,$02,$00,$00 e4
                    fcb       $65,$01,$ae,$04,$85,$01,$00,$00 e8
                    fcb       $4b,$03,$af,$03,$63,$03,$00,$00 ec
                    fcb       $16,$06,$ae,$78,$00,$00,$00,$00 f0
                    fcb       $00,$00,$ae,$62,$62,$62,$00,$00 f4
                    fcb       $b5,$01,$af,$73,$00,$00,$00,$00 f8
                    fcb       $00,$00,$af,$63,$63,$63,$00,$00 fc
* intab5 represents [14]6805 instructions
* as 2-byte fields, as follows:
* byte 1 bits 0-5: pointer to optab5
*        bits 6-7  length
* byte 2 bits 0-3: suffix (sp,a,c,s,p,t,x,y)
*        bits 4-7: mode (inh,dir,ext,imm,ixi,
*                        rel,ix0,ix2,btb,bsc)
intab5              equ       *
                    fcb       $bf,$09,$5f,$09,$bf,$09,$5f,$09 00
                    fcb       $bf,$09,$5f,$09,$bf,$09,$5f,$09 04
                    fcb       $bf,$09,$5f,$09,$bf,$09,$5f,$09 08
                    fcb       $bf,$09,$5f,$09,$bf,$09,$5f,$09 0c
                    fcb       $be,$0a,$5e,$0a,$be,$0a,$5e,$0a 10
                    fcb       $be,$0a,$5e,$0a,$be,$0a,$5e,$0a 14
                    fcb       $be,$0a,$5e,$0a,$be,$0a,$5e,$0a 18
                    fcb       $be,$0a,$5e,$0a,$be,$0a,$5e,$0a 1c
                    fcb       $4a,$06,$4e,$06,$22,$06,$32,$06 20
                    fcb       $12,$06,$16,$06,$42,$06,$1a,$06 24
                    fcb       $1e,$26,$1e,$36,$46,$06,$3a,$06 28
                    fcb       $36,$06,$3e,$06,$2a,$06,$26,$06 2c
                    fcb       $92,$02,$00,$00,$00,$00,$66,$02 30
                    fcb       $8e,$02,$00,$00,$a2,$02,$0e,$02 34
                    fcb       $8a,$02,$9e,$02,$6e,$02,$00,$00 38
                    fcb       $76,$02,$da,$02,$00,$00,$5e,$02 3c
                    fcb       $91,$11,$00,$00,$00,$00,$65,$11 40
                    fcb       $8d,$11,$00,$00,$a1,$11,$0d,$11 44
                    fcb       $89,$11,$9d,$11,$6d,$11,$00,$00 48
                    fcb       $75,$11,$d9,$11,$00,$00,$5d,$11 4c
                    fcb       $91,$61,$00,$00,$00,$00,$65,$61 50
                    fcb       $8d,$61,$00,$00,$a1,$61,$0d,$61 54
                    fcb       $89,$61,$9d,$61,$6d,$61,$00,$00 58
                    fcb       $75,$61,$d9,$61,$00,$00,$5d,$61 5c
                    fcb       $92,$05,$00,$00,$00,$00,$66,$05 60
                    fcb       $8e,$05,$00,$00,$a2,$05,$0e,$05 64
                    fcb       $8a,$05,$9e,$05,$6e,$05,$00,$00 68
                    fcb       $76,$05,$da,$05,$00,$00,$5e,$05 6c
                    fcb       $91,$07,$00,$00,$00,$00,$65,$07 70
                    fcb       $8d,$07,$00,$00,$a1,$07,$0d,$07 74
                    fcb       $89,$07,$9d,$07,$6d,$07,$00,$00 78
                    fcb       $75,$07,$d9,$07,$00,$00,$5d,$07 7c
                    fcb       $a9,$01,$ad,$01,$00,$00,$d1,$01 80
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00 84
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00 88
                    fcb       $00,$00,$00,$00,$c5,$41,$e1,$51 8c
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00 90
                    fcb       $00,$00,$00,$00,$00,$00,$d5,$01 94
                    fcb       $55,$01,$b5,$01,$59,$01,$b9,$01 98
                    fcb       $a5,$01,$95,$01,$00,$00,$dd,$01 9c
                    fcb       $ce,$04,$62,$04,$b2,$04,$6a,$04 a0
                    fcb       $0a,$04,$2e,$04,$82,$04,$00,$00 a4
                    fcb       $72,$04,$02,$04,$9a,$04,$06,$04 a8
                    fcb       $00,$00,$52,$06,$86,$04,$00,$00 ac
                    fcb       $ce,$02,$62,$02,$b2,$02,$6a,$02 b0
                    fcb       $0a,$02,$2e,$02,$82,$02,$c2,$02 b4
                    fcb       $72,$02,$02,$02,$9a,$02,$06,$02 b8
                    fcb       $7a,$02,$7e,$02,$86,$02,$ca,$02 bc
                    fcb       $cf,$03,$63,$03,$b3,$03,$6b,$03 c0
                    fcb       $0b,$03,$2f,$03,$83,$03,$c3,$03 c4
                    fcb       $73,$03,$03,$03,$9b,$03,$07,$03 c8
                    fcb       $7b,$03,$7f,$03,$87,$03,$cb,$03 cc
                    fcb       $cf,$08,$63,$08,$b3,$08,$6b,$08 d0
                    fcb       $0b,$08,$2f,$08,$83,$08,$c3,$08 d4
                    fcb       $73,$08,$03,$08,$9b,$08,$07,$08 d8
                    fcb       $7b,$08,$7f,$08,$87,$08,$cb,$08 dc
                    fcb       $ce,$05,$62,$05,$b2,$05,$6a,$05 e0
                    fcb       $0a,$05,$2e,$05,$82,$05,$c2,$05 e4
                    fcb       $72,$05,$02,$05,$9a,$05,$06,$05 e8
                    fcb       $7a,$05,$7e,$05,$86,$05,$ca,$05 ec
                    fcb       $cd,$07,$61,$07,$b1,$07,$69,$07 f0
                    fcb       $09,$07,$2d,$07,$81,$07,$c1,$07 f4
                    fcb       $71,$07,$01,$07,$99,$07,$05,$07 f8
                    fcb       $79,$07,$7d,$07,$85,$07,$c9,$07 fc
* intab9 represents 6809 instructions
* as 2- or 3-byte fields, as follows:
* byte 1 bits 0-5: pointer to optab9
*        bits 6-7  length (-1 for page 2/3)
* byte 2 bits 0-3: suffix
*                  (sp,a,b,cc,d,i,l,s,u,x,y,1,2,3)
*        bit 4:    page-3 flag
*        bits 5-7: mode (inh,dir,ext,imm,inx,rel)
* byte 3 bits 0-7: opcode (page 2/3 only)
intab9              equ       *
                    fcb       $9e,$02,$00,$00,$00,$00,$6a,$02 00
                    fcb       $96,$02,$00,$00,$b6,$02,$16,$02 04
                    fcb       $12,$02,$b2,$02,$76,$02,$00,$00 08
                    fcb       $82,$02,$de,$02,$86,$02,$62,$02 0c
                    fcb       $ff,$00,$ff,$08,$a1,$01,$d5,$31 10
                    fcb       $00,$00,$00,$00,$4f,$76,$57,$76 14
                    fcb       $00,$00,$71,$01,$a6,$44,$00,$00 18
                    fcb       $0e,$44,$c5,$01,$7e,$01,$da,$01 1c
                    fcb       $4e,$06,$52,$06,$2e,$06,$3a,$06 20
                    fcb       $1a,$06,$1e,$06,$46,$06,$22,$06 24
                    fcb       $5a,$06,$5e,$06,$4a,$06,$42,$06 28
                    fcb       $26,$06,$3e,$06,$2a,$06,$36,$06 2c
                    fcb       $92,$a5,$92,$b5,$92,$85,$92,$95 30
                    fcb       $aa,$81,$ae,$81,$aa,$91,$ae,$91 34
                    fcb       $00,$00,$bd,$01,$01,$01,$b9,$01 38
                    fcb       $6e,$61,$99,$01,$00,$00,$d1,$01 3c
                    fcb       $9d,$11,$00,$00,$00,$00,$69,$11 40
                    fcb       $95,$11,$00,$00,$b5,$11,$15,$11 44
                    fcb       $11,$11,$b1,$11,$75,$11,$00,$00 48
                    fcb       $81,$11,$dd,$11,$00,$00,$61,$11 4c
                    fcb       $9d,$21,$00,$00,$00,$00,$69,$21 50
                    fcb       $95,$21,$00,$00,$b5,$21,$15,$21 54
                    fcb       $11,$21,$b1,$21,$75,$21,$00,$00 58
                    fcb       $81,$21,$dd,$21,$00,$00,$61,$21 5c
                    fcb       $9e,$05,$00,$00,$00,$00,$6a,$05 60
                    fcb       $96,$05,$00,$00,$b6,$05,$16,$05 64
                    fcb       $12,$05,$b2,$05,$76,$05,$00,$00 68
                    fcb       $82,$05,$de,$05,$86,$05,$62,$05 6c
                    fcb       $9f,$03,$00,$00,$00,$00,$6b,$03 70
                    fcb       $97,$03,$00,$00,$b7,$03,$17,$03 74
                    fcb       $13,$03,$b3,$03,$77,$03,$00,$00 78
                    fcb       $83,$03,$df,$03,$87,$03,$63,$03 7c
                    fcb       $ce,$14,$66,$14,$c2,$14,$cf,$54 80
                    fcb       $0e,$14,$32,$14,$8e,$14,$00,$00 84
                    fcb       $7a,$14,$06,$14,$a6,$14,$0a,$14 88
                    fcb       $67,$a4,$56,$06,$8f,$a4,$00,$00 8c
                    fcb       $ce,$12,$66,$12,$c2,$12,$ce,$52 90
                    fcb       $0e,$12,$32,$12,$8e,$12,$ca,$12 94
                    fcb       $7a,$12,$06,$12,$a6,$12,$0a,$12 98
                    fcb       $66,$a2,$8a,$02,$8e,$a2,$ca,$a2 9c
                    fcb       $ce,$15,$66,$15,$c2,$15,$ce,$55 a0
                    fcb       $0e,$15,$32,$15,$8e,$15,$ca,$15 a4
                    fcb       $7a,$15,$06,$15,$a6,$15,$0a,$15 a8
                    fcb       $66,$a5,$8a,$05,$8e,$a5,$ca,$a5 ac
                    fcb       $cf,$13,$67,$13,$c3,$13,$cf,$53 b0
                    fcb       $0f,$13,$33,$13,$8f,$13,$cb,$13 b4
                    fcb       $7b,$13,$07,$13,$a7,$13,$0b,$13 b8
                    fcb       $67,$a3,$8b,$03,$8f,$a3,$cb,$a3 bc
                    fcb       $ce,$24,$66,$24,$c2,$24,$0b,$54 c0
                    fcb       $0e,$24,$32,$24,$8e,$24,$00,$00 c4
                    fcb       $7a,$24,$06,$24,$a6,$24,$0a,$24 c8
                    fcb       $8f,$54,$00,$00,$8f,$94,$00,$00 cc
                    fcb       $ce,$22,$66,$22,$c2,$22,$0a,$52 d0
                    fcb       $0e,$22,$32,$22,$8e,$22,$ca,$22 d4
                    fcb       $7a,$22,$06,$22,$a6,$22,$0a,$22 d8
                    fcb       $8e,$52,$ca,$52,$8e,$92,$ca,$92 dc
                    fcb       $ce,$25,$66,$25,$c2,$25,$0a,$55 e0
                    fcb       $0e,$25,$32,$25,$8e,$25,$ca,$25 e4
                    fcb       $7a,$25,$06,$25,$a6,$25,$0a,$25 e8
                    fcb       $8e,$55,$ca,$55,$8e,$95,$ca,$95 ec
                    fcb       $cf,$23,$67,$23,$c3,$23,$0b,$53 f0
                    fcb       $0f,$23,$33,$23,$8f,$23,$cb,$23 f4
                    fcb       $7b,$23,$07,$23,$a7,$23,$0b,$23 f8
                    fcb       $8f,$53,$cb,$53,$8f,$93,$cb,$93 fc
intpg9              equ       *
                    fcb       $53,$76,$21,$2f,$76,$22 page 2
                    fcb       $3b,$76,$23,$1b,$76,$24
                    fcb       $1f,$76,$25,$47,$76,$26
                    fcb       $23,$76,$27,$5b,$76,$28
                    fcb       $5f,$76,$29,$4b,$76,$2a
                    fcb       $43,$76,$2b,$27,$76,$2c
                    fcb       $3f,$76,$2d,$2b,$76,$2e
                    fcb       $37,$76,$2f,$d1,$d1,$3f
                    fcb       $67,$54,$83,$67,$b4,$8c
                    fcb       $8f,$b4,$8e,$66,$52,$93
                    fcb       $66,$b2,$9c,$8e,$b2,$9e
                    fcb       $ca,$b2,$9f,$66,$55,$a3
                    fcb       $66,$b5,$ac,$8e,$b5,$ae
                    fcb       $ca,$b5,$af,$67,$53,$b3
                    fcb       $67,$b3,$bc,$8f,$b3,$be
                    fcb       $cb,$b3,$bf,$8f,$84,$ce
                    fcb       $8e,$82,$de,$ca,$82,$df
                    fcb       $8e,$85,$ee,$ca,$85,$ef
                    fcb       $8f,$83,$fe,$cb,$83,$ff
                    fcb       $d1,$e9,$3f,$67,$9c,$83 page 3
                    fcb       $67,$8c,$8c,$66,$9a,$93
                    fcb       $66,$8a,$9c,$66,$9d,$a3
                    fcb       $66,$8d,$ac,$67,$9b,$b3
                    fcb       $67,$8b,$bc
intpx9              equ       *
* svctab contains OS/9 svc code names.
* if more codes are added, insert
*    them into the table, in the proper place.
* invalids are blank or beyond end of table.
svctab              equ       *
* ifeq (os9lno-$01)
* fcc 'F$Link  ' 00 link to module
* fcc 'F$Load  ' 01 load module
* fcc 'F$UnLink' 02 unlink module
* fcc 'F$Fork  ' 03 fork process
* fcc 'F$Wait  ' 04 wait for child
* fcc 'F$Chain ' 05 chain process
* fcc 'F$Exit  ' 06 exit process
* fcc 'F$Mem   ' 07 set memory size
* fcc 'F$Send  ' 08 send program intr
* fcc 'F$Icpt  ' 09 catch program intr
* fcc 'F$Sleep ' 0a sleep
* fcc 'F$SSpd  ' 0b suspend process
* fcc 'F$Id    ' 0c return process id
* fcc 'F$SPrior' 0d set priority
* fcc 'F$SSWI  ' 0e set swi vector
* fcc 'F$PErr  ' 0f print error message
* fcc 'F$PrsNam' 10 parse pathlist
* fcc 'F$CmpNam' 11 compare names
* fcc 'F$SchBit' 12 search bit map
* fcc 'F$AllBit' 13 allocate bit map
* fcc 'F$DelBit' 14 deallocate bit map
* fcc 'F$Time  ' 15 get time
* fcc 'F$STime ' 16 set current time
* fcc 'F$CRC   ' 17 generate crc
* fcc '                                ' 18-1b
* fcc '                                ' 1c-1f
* fcc '                                ' 20-23
* fcc '                                ' 24-27
* fcc 'F$SRqMem' 28 find sys memory
* fcc 'F$SRtMen' 29 release sys memory
* fcc 'F$IRQ   ' 2a enter irq queue
* fcc 'F$IOQu  ' 2b enter i/o queue
* fcc 'F$AProc ' 2c enter active queue
* fcc 'F$NProc ' 2d start process
* fcc 'F$VModul' 2e validate process
* fcc 'F$Find64' 2f find 64 byte block
* fcc 'F$All64 ' 30 alloc 64 byte block
* fcc 'F$Ret64 ' 31 return 64 byte block
* fcc 'F$SSvc  ' 32 install fcn request
* fcc 'F$IODel ' 33 delete i/o module
* fcc '                                ' 34-37
* fcc '                                ' 38-3b
* fcc '                                ' 3c-3f
* fcc '                                ' 40-43
* fcc '                                ' 44-47
* fcc '                                ' 48-4b
* fcc '                                ' 4c-4f
* fcc '                                ' 50-53
* fcc '                                ' 54-57
* fcc '                                ' 58-5b
* fcc '                                ' 5c-5f
* fcc '                                ' 60-63
* fcc '                                ' 64-67
* fcc '                                ' 68-6b
* fcc '                                ' 6c-6f
* fcc '                                ' 70-73
* fcc '                                ' 74-77
* fcc '                                ' 78-7b
* fcc '                                ' 7c-7f
* fcc 'I$Attach' 80 attach i/o device
* fcc 'I$Detach' 81 detach i/o device
* fcc 'I$Dup   ' 82 duplicate path
* fcc 'I$Create' 83 create new file
* fcc 'I$Open  ' 84 open path to file
* fcc 'I$MakDir' 85 make directory file
* fcc 'I$ChgDir' 86 change directory
* fcc 'I$Delete' 87 delete file
* fcc 'I$Seek  ' 88 seek to byte in file
* fcc 'I$Read  ' 89 read data
* fcc 'I$Write ' 8a write data
* fcc 'I$ReadLn' 8b read line
* fcc 'I$WritLn' 8c write line
* fcc 'I$GetStt' 8d get device status
* fcc 'I$SetStt' 8e set device status
* fcc 'I$Close ' 8f read line
* fcc 'I$DeletX' 90 delete from current exec dir
* endc
** ifeq (os9lno-$02)
                    fcc       'F$Link  '          00 link to module
                    fcc       'F$Load  '          01 load module
                    fcc       'F$UnLink'          02 unlink module
                    fcc       'F$Fork  '          03 fork process
                    fcc       'F$Wait  '          04 wait for child
                    fcc       'F$Chain '          05 chain process
                    fcc       'F$Exit  '          06 exit process
                    fcc       'F$Mem   '          07 set memory size
                    fcc       'F$Send  '          08 send program intr
                    fcc       'F$Icpt  '          09 catch program intr
                    fcc       'F$Sleep '          0a sleep
                    fcc       'F$SSpd  '          0b suspend process
                    fcc       'F$ID    '          0c return process id
                    fcc       'F$SPrior'          0d set priority
                    fcc       'F$SSWI  '          0e set swi vector
                    fcc       'F$PErr  '          0f print error message
                    fcc       'F$PrsNam'          10 parse pathlist
                    fcc       'F$CmpNam'          11 compare names
                    fcc       'F$SchBit'          12 search bit map
                    fcc       'F$AllBit'          13 allocate bit map
                    fcc       'F$DelBit'          14 deallocate bit map
                    fcc       'F$Time  '          15 get time
                    fcc       'F$STime '          16 set current time
                    fcc       'F$CRC   '          17 generate crc
                    fcc       'F$GPrDsc'          18 get processor descriptor copy
                    fcc       'F$GBlkMp'          19 get system block map copy
                    fcc       'F$GModDr'          1a get module directory copy
                    fcc       'F$CpyMem'          1b copy external memory
                    fcc       'F$SUser '          1c set user id
                    fcc       'F$UnLoad'          1d unlink module by name
                    fcc       'F$Alarm '          1e added by color comp level 2
                    fcc       '        '          1f invalid
                    fcc       '        '          20 invalid
                    fcc       'F$NMLink'          21 added by color comp level 2
                    fcc       'F$NMLoad'          22 added by color comp level 2
                    fcc       'F$Debug '          23 invalid
                    fcc       '        '          24 invalid
                    fcc       'F$TPS   '          25 invalid
                    fcc       'F$TimAlm'          26 invalid
                    fcc       'F$VIRQ  '          27 added by color comp level 2
                    fcc       'F$SRqMem'          28 find sys memory
                    fcc       'F$SRtMem'          29 release sys memory
                    fcc       'F$IRQ   '          2a enter irq queue
                    fcc       'F$IOQu  '          2b enter i/o queue
                    fcc       'F$AProc '          2c enter active queue
                    fcc       'F$NProc '          2d start process
                    fcc       'F$VModul'          2e validate process
                    fcc       'F$Find64'          2f find 64 byte block
                    fcc       'F$All64 '          30 alloc 64 byte block
                    fcc       'F$Ret64 '          31 rel 64 byte block
                    fcc       'F$SSvc  '          32 install fcn request
                    fcc       'F$IODel '          33 delete i/o module
                    fcc       'F$SLink '          34 system link
                    fcc       'F$Boot  '          35 bootstrap system
                    fcc       'F$BtMem '          36 bootstrap memory
                    fcc       'F$GProcP'          37 get process ptr
                    fcc       'F$Move  '          38 move data low bound first
                    fcc       'F$AllRAM'          39 allocate ram blocks
                    fcc       'F$AllImg'          3a allocate image ram blocks
                    fcc       'F$DelImg'          3b deallocate image ram blocks
                    fcc       'F$SetImg'          3c set process dat image
                    fcc       'F$FreeLB'          3d get free low block
                    fcc       'F$FreeHB'          3e get free high block
                    fcc       'F$AllTsk'          3f allocate process task number
                    fcc       'F$DelTsk'          40 deallocate process task number
                    fcc       'F$SetTsk'          41 set process dat registers
                    fcc       'F$ResTsk'          42 reserve process task numbers
                    fcc       'F$RelTsk'          43 release task number
                    fcc       'F$DATLog'          44 convert data block/offset to logical
                    fcc       'F$DATTmp'          45 make temporary dat image
                    fcc       'F$LDAXY '          46 load a,[x,[y]]
                    fcc       'F$LDAXYP'          47 load a,[x+,[y]]
                    fcc       'F$LDDDXY'          48 load d [d+x,[y]]
                    fcc       'F$LDABX '          49 load a from 0,x in task b
                    fcc       'F$STABX '          4a store a in 0,x in task b
                    fcc       'F$AllPrc'          4b allocate process descriptor
                    fcc       'F$DelPrc'          4c deallocate process descriptor
                    fcc       'F$ELink '          4d link using module directory entry
                    fcc       'F$FModul'          4e find module directory entry
                    fcc       'F$MapBlk'          4f added by color comp level 2
                    fcc       'F$ClrBlk'          50 added by color comp level 2
                    fcc       'F$DelRAM'          51 added by color comp level 2
                    fcc       'F$GCMDir'          52 added by color comp level 2
                    fcc       'F$AlHRAM'          53 added by color comp level 2
                    fcc       'F$ReBoot'          54 Reboot machine (reload OS9Boot) or drop to RSDOS
                    fcc       'F$CRCMod'          55 CRC mode, toggle or report current status
                    fcc       'F$XTime '          56 Get Extended time packet from RTC (fractions of second)
                    fcc       'F$VBlock'          57 Verify modules in a block of memory, add to module directory
                    fcc       '                                ' 58-5b
                    fcc       '                                ' 5c-5f
                    fcc       '                                ' 60-63
                    fcc       '                                ' 64-67
                    fcc       '                                ' 68-6b
                    fcc       '                                ' 6c-6f
                    fcc       'F$RegDmp'          70
                    fcc       'F$NVRAM '          71
                    fcc       '        '          72
                    fcc       '        '          73
                    fcc       '                                ' 74-77
                    fcc       '                                ' 78-7b
                    fcc       '                                ' 7c-7f
                    fcc       'I$Attach'          80 attach i/o device
                    fcc       'I$Detach'          81 detach i/o device
                    fcc       'I$Dup   '          82 duplicate path
                    fcc       'I$Create'          83 create new file
                    fcc       'I$Open  '          84 open path to file
                    fcc       'I$MakDir'          85 make directory file
                    fcc       'I$ChgDir'          86 change directory
                    fcc       'I$Delete'          87 delete file
                    fcc       'I$Seek  '          88 seek to byte in file
                    fcc       'I$Read  '          89 read data
                    fcc       'I$Write '          8a write data
                    fcc       'I$ReadLn'          8b read line
                    fcc       'I$WritLn'          8c write line
                    fcc       'I$GetStt'          8d  get device status
                    fcc       'I$SetStt'          8e set device status
                    fcc       'I$Close '          8f read line
                    fcc       'I$DeletX'          90 added by color comp level 1.1 version 2.00
* endc
svcend              equ       *                   end of svc table
