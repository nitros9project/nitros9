********************************************************************
* Basic09 Banner
* 2024/01/2024-03-04-2024
* Matt Massie
********************************************************************

                    nam      basban
                    use      ../defsfile
		     * DATA SECTION
                    org   0
MMUST               rmb       1
MMUSL1              rmb       1
                    rmb   50
STACK               equ   .-1
DATMEM              equ   .
                    * PROGRAM SECTION
                    mod ENDPRG,NAME,$11,$81,ENTRY,DATMEM
NAME                fcs  /Basban/
ENTRY               equ   *
                    lda       MMU_MEM_CTRL        get current MLUT -  MMU_MEM_CTRL $FFA0
                    sta       MMUST,u             store MMU State
                    ldb       MMU_SLOT_1          get current MMU SLOT 1 - MMU_SLOT_1 $FFA9
                    stb       MMUSL1,u            store MMU Slot 1
                    lda       MMU_SLOT_7          get MMU slot 7 $FFAF
                    cmpa      #$07                is it Ram mode
                    beq       ram@			
                    lda       #$11                enable editing Flash mode MLUT 1
                    bra       cont@
ram@                lda       #$00                enable editing Ram mode MLUT 0
cont@               sta       MMU_MEM_CTRL        update $FFA0
                    lda       #$C1                MMU Page $C1 to SLOT 1 - font memory
                    sta       MMU_SLOT_1          update $FFA9
                    leax      FONTS,pcr           point to custom FONTS
                    ldy       #$2598              point to character 179	
                    ldb       #$78                FONT byte count
L1                  lda       ,x+                 load font byte
                    sta       ,y+                 update font glyph
                    decb                          decrement count
                    bne       L1
                    ldb       MMUSL1,u            restore MMU Slot 1 #$01
                    stb       MMU_SLOT_1	    update MMU SLOT 1 $FFA9
                    lda       MMUST,u             restore MLUT #$00
                    sta       MMU_MEM_CTRL        update MMU $FFA0
                    leax      NEWLN,pcr
                    ldy       #NEWLNLEN
                    lda       #1
                    os9       I$Writln
                    bcs       ERROR
                    leax      OUTSTR,pcr
                    ldy       #STRLEN
                    lda       #1
                    os9       I$Write
                    bcs       ERROR
                    ldx       #SYS0
                    lda       7,x
                    cmpa      #$02
                    bne       isItF256K
                    leax      OUTSTR2,pcr
                    ldy       #STRLEN2
                    lda       #1
                    os9       I$Writln
                    bcs       ERROR
                    bra       CONT
isItF256K           cmpa      #$12
                    bne       ERROR
                    leax      OUTSTR3,pcr
                    ldy       #STRLEN3
                    lda       #1
                    os9       I$Writln
                    bcs       ERROR
CONT                leax      BASL2,pcr
                    ldy       #BASLEN2
                    lda       #1
                    os9       I$Write
                    bcs       ERROR
DONE                ldb       #0
ERROR               os9       F$Exit
OUTSTR              fcb       $1b,$32,$07,$de,$db,$db,$db,$db,$db,$b7
                    fcb       $1b,$32,$06,$db,$db,$1b,$32,$08,$b3,$db
                    fcb       $db,$db,$bc,$1b,$32,$06,$db,$db,$1b,$32
                    fcb       $04,$b5,$db,$db,$db,$db,$db,$b7,$1b,$32
                    fcb       $06,$db,$1b,$32,$0e,$db,$dd,$1b,$32,$06
                    fcb       $db,$1b,$32,$05,$b5,$db,$db,$db,$db,$b7
                    fcb       $1b,$32,$06,$db,$db,$1b,$32,$0f,$b3,$db
                    fcb       $db,$db,$db,$db,$bc,$1b,$32,$06,$db,$db
                    fcb       $1b,$32,$01,$b5,$db,$db,$db,$db,$b7,$1b
                    fcb       $32,$06,$db,$db,$db,$db,$db,$db,$db,$db
                    fcb       $db,$db,$1b,$32,$01
STRLEN              equ       *-OUTSTR
OUTSTR2             fcc       /F256 Jr./
                    fcb       $0D
STRLEN2             equ       *-OUTSTR2
OUTSTR3             fcc       / F256 K/
                    fcb       $0D
STRLEN3             equ       *-OUTSTR3
BASL2               fcb       $1b,$32,$07,$de,$db,$1b,$32,$06,$db,$db
                    fcb       $db,$1b,$32,$07,$de,$db,$1b,$32,$06,$db
                    fcb       $1b,$32,$08,$b3,$db,$b4,$1b,$32,$06,$db
                    fcb       $1b,$32,$08,$bb,$db,$bc,$1b,$32,$06,$db
                    fcb       $1b,$32,$04,$db,$dd,$1b,$32,$06,$db,$db
                    fcb       $db,$db,$db,$db,$1b,$32,$0e,$db,$dd,$1b
                    fcb       $32,$06,$db,$1b,$32,$05,$db,$dd,$1b,$32
                    fcb       $06,$db,$db,$db,$db,$db,$db,$1b,$32,$0f
                    fcb       $db,$be,$1b,$32,$06,$db,$1b,$32,$0f,$b3
                    fcb       $b4,$c1,$db,$1b,$32,$06,$db,$db,$1b,$32
                    fcb       $01,$db,$dd
                    fcb       $1b,$32,$06,$db,$db,$1b,$32,$01,$de,$db
                    fcb       $1b,$32,$06,$db,$db,$db,$db,$db,$db,$db
                    fcb       $db,$db,$db,$db,$db,$db,$db,$db,$db,$db
                    fcb       $db,$db,$db,$db,$db,$db,$db,$db,$db,$db
                    fcb       $db,$db,$db
                    fcb       $1b,$32,$07,$de,$db,$db,$db,$db,$db,$bd
                    fcb       $1b,$32,$06,$db,$1b,$32,$08,$db,$db,$db
                    fcb       $db,$db,$db,$db,$1b,$32,$06,$db,$1b,$32
                    fcb       $04,$b6,$db,$db,$db,$db,$db,$b7,$1b,$32
                    fcb       $06,$db,$1b,$32,$0e,$db,$dd,$1b,$32,$06
                    fcb       $db,$1b,$32,$05,$db,$dd,$1b,$32,$06,$db
                    fcb       $db,$db,$db,$db,$db,$1b,$32,$0f,$db,$dd
                    fcb       $1b,$32,$0f,$b3,$db,$b4,$de,$db,$1b,$32
                    fcb       $06,$db,$db,$1b,$32,$01,$b6,$db,$db,$db
                    fcb       $db,$db,$1b,$32,$06,$db,$db,$db,$db,$db
                    fcb       $db,$db,$db,$db,$db,$1b,$32,$01,$40,$4d
                    fcb       $72,$50,$69,$74,$72,$65,$1b,$32,$06,$db
                    fcb       $db
                    fcb       $db,$db,$db,$db,$db,$db,$db,$db,$db,$db
                    fcb       $1b,$32,$07,$de,$db,$1b,$32,$06,$db,$db
                    fcb       $db,$1b,$32,$07,$de,$db,$1b,$32,$06,$db
                    fcb       $1b,$32,$08,$db,$db,$1b,$32,$06,$db,$db
                    fcb       $db,$1b,$32,$08,$db,$db,$1b,$32,$06,$db
                    fcb       $db,$db,$db,$db,$db,$1b,$32,$04,$de,$db
                    fcb       $1b,$32,$06,$db,$1b,$32,$0e,$db,$dd,$1b
                    fcb       $32,$06,$db,$1b,$32,$05,$db,$dd,$1b,$32
                    fcb       $06,$db,$db,$db,$db,$db,$db,$1b,$32,$0f
                    fcb       $db,$c0,$b3,$b4,$1b,$32,$06,$db,$1b,$32
                    fcb       $0f,$bf,$db,$1b,$32,$06,$db,$db,$db,$db
                    fcb       $db,$db,$1b,$32,$01,$de,$db
                    fcb       $1b,$32,$06,$db,$db,$db,$db,$db,$db,$db
                    fcb       $db,$db,$db,$db,$1b,$32,$01,$40,$4a,$46
                    fcb       $65,$64,$1b,$32,$06,$db,$db,$db,$db,$db
                    fcb       $db,$db,$db,$db,$db,$db,$db,$db,$db
                    fcb       $1b,$32,$07,$de,$db,$db,$db,$db,$db,$b8
                    fcb       $1b,$32,$06,$db,$1b,$32,$08,$db,$b4
                    fcb       $1b,$32,$06,$db,$db,$db,$1b,$32,$08,$bb
                    fcb       $db,$1b,$32,$06,$db,$1b,$32,$04,$b9,$db
                    fcb       $db,$db,$db,$db,$b8,$1b,$32,$06,$db,$1b
                    fcb       $32,$0e,$db,$dd,$1b,$32,$06,$db,$1b,$32
                    fcb       $05,$b6,$db,$db,$db,$db,$b8,$1b,$32,$06
                    fcb       $db,$db,$1b,$32,$0f,$bb,$db,$db,$db,$db
                    fcb       $db,$b4,$1b,$32,$06,$db,$db,$1b,$32
                    fcb       $01,$b9,$db,$db,$db,$db,$b8,$1b,$32,$06
                    fcb       $db,$db,$db
                    fcb       $db,$db,$db,$db,$db,$1b,$32,$01,$40,$4d
                    fcb       $61,$74,$74,$20,$4d,$61,$73,$73,$69,$65
                    fcb       $1b,$32,$01
BASLEN2             equ       *-BASL2
NEWLN               fcb       $1B,$33,$06,$0C,$0D
NEWLNLEN            equ	*-NEWLN
FONTS               fcb       $01,$03,$07,$0f,$1f,$3f,$7f,$ff          char 179 left forward slant
                    fcb       $ff,$fe,$fc,$f8,$f0,$e0,$c0,$80          char 180 right forward slant
                    fcb       $07,$1f,$3f,$7f,$7f,$ff,$ff,$ff          char 181 left top rounded
                    fcb       $ff,$ff,$ff,$7f,$7f,$3f,$1f,$07          char 182 left bottom rounded
                    fcb       $e0,$f8,$fc,$fe,$fe,$ff,$ff,$ff          char 183 right top rounded
                    fcb       $ff,$ff,$ff,$fe,$fe,$fc,$f8,$e0          char 184 right bottom rounded
                    fcb       $0f,$1f,$3f,$7f,$7f,$3f,$1f,$0f          char 185 left end cap
                    fcb       $ff,$fe,$fc,$f8,$f0,$e0,$c0,$80          char 186 right forward slant
                    fcb       $ff,$7f,$3f,$1f,$0f,$07,$03,$01          char 187 left reverse slant
                    fcb       $80,$c0,$e0,$f0,$f8,$fc,$fe,$ff          char 188 right reverse slant
                    fcb       $ff,$ff,$fe,$fc,$fc,$fe,$ff,$ff          char 189 bd b right notch
                    fcb       $ff,$fe,$fc,$f8,$f0,$f0,$f0,$f0          char 190 be left inside zero
                    fcb       $0f,$0f,$0f,$0f,$1f,$3f,$7f,$ff          char 191 bf right inside zero
                    fcb       $f0,$f0,$f0,$f0,$f8,$fc,$fe,$ff          char 192 c0 left bottom inside zero
                    fcb       $ff,$7f,$3f,$1f,$0f,$0f,$0f,$0f          char 193 c1 right top inside zero
                    emod
ENDPRG              equ       *
                    end
		
