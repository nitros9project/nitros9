* sh_sun.asm - written by tools/flightsim2/sun_tab.py: do not edit. ShTab: per season (vSeason 1-4), the
* hours 0-24: a shadow's ground offset east, north per m of height x 16 (away from the sun; 42 deg north)
ShTab               equ       *
* winter
                    fcb       $00,$A5,$C7,$B9,$AF,$D6,$A7,$ED,$A5,$FF
                    fcb       $A6,$0E,$AA,$1C,$AF,$29,$B8,$37,$D0,$36
                    fcb       $E9,$29,$F6,$24,$00,$23,$0A,$24,$17,$29
                    fcb       $30,$36,$48,$37,$51,$29,$56,$1C,$5A,$0E
                    fcb       $5B,$FF,$59,$ED,$51,$D6,$39,$B9,$00,$A5
* spring
                    fcb       $00,$A5,$DE,$AC,$C5,$BB,$B5,$CE,$AB,$DF
                    fcb       $A7,$F0,$A5,$00,$B0,$0E,$DB,$0E,$EA,$0E
                    fcb       $F4,$0E,$FA,$0E,$00,$0E,$06,$0E,$0C,$0E
                    fcb       $16,$0E,$25,$0E,$50,$0E,$5B,$00,$59,$F0
                    fcb       $55,$DF,$4B,$CE,$3B,$BB,$22,$AC,$00,$A5
* summer
                    fcb       $00,$A5,$E9,$A8,$D4,$B1,$C4,$BC,$B8,$C9
                    fcb       $AF,$D7,$C9,$EE,$E0,$FB,$EB,$00,$F2,$03
                    fcb       $F7,$04,$FC,$05,$00,$05,$04,$05,$09,$04
                    fcb       $0E,$03,$15,$00,$20,$FB,$37,$EE,$51,$D7
                    fcb       $48,$C9,$3C,$BC,$2C,$B1,$17,$A8,$00,$A5
* fall
                    fcb       $00,$A5,$DE,$AC,$C5,$BB,$B5,$CE,$AB,$DF
                    fcb       $A7,$F0,$A5,$00,$B0,$0E,$DB,$0E,$EA,$0E
                    fcb       $F4,$0E,$FA,$0E,$00,$0E,$06,$0E,$0C,$0E
                    fcb       $16,$0E,$25,$0E,$50,$0E,$5B,$00,$59,$F0
                    fcb       $55,$DF,$4B,$CE,$3B,$BB,$22,$AC,$00,$A5
