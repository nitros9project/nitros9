********************************************************************
* Basic09 Banner
* 2024/01/2024-02-16-2024
* Matt Massie
********************************************************************

		     nam	basban
		     use	../defsfile
		     * DATA SECTION
		     org   0
MMUST               rmb       1
MMUSL1              rmb       1
         	     rmb   50
STACK	             equ   .-1
DATMEM		     equ   .
		     * PROGRAM SECTION
         	     mod ENDPRG,NAME,$11,$81,ENTRY,DATMEM
NAME     	     fcs  /Basban/
ENTRY    	     equ   *
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
                    leax      BASL3,pcr
                    ldy       #BASLEN3
                    lda       #1
                    os9       I$Write
                    bcs       ERROR
DONE                ldb       #0
ERROR               os9       F$Exit
OUTSTR              fcb       $1B,$32,$07,$DE,$DB,$DB,$DB,$DB,$DB,$B7
                    fcb       $1B,$32,$06,$DB,$DB,$1B,$32,$08,$B3,$DB
                    fcb       $DB,$DB,$BC,$1B,$32,$06,$DB,$DB,$1B,$32
                    fcb       $04,$B5,$DB,$DB,$DB,$DB,$DB,$B7,$1B,$32
                    fcb       $06,$DB,$1B,$32,$0E,$DB,$DD,$1B,$32,$06
                    fcb       $DB,$1B,$32,$05,$B5,$DB,$DB,$DB,$DB,$B7
                    fcb       $1B,$32,$06,$DB,$DB,$1B,$32,$0F,$B3,$DB
                    fcb       $DB,$DB,$DB,$DB,$BC,$1B,$32,$06,$DB,$DB
                    fcb       $1B,$32,$01,$B5,$DB,$DB,$DB,$DB,$B7,$1B
                    fcb       $32,$06,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb       $DB,$DB,$1B,$32,$01
STRLEN              equ       *-OUTSTR
OUTSTR2             fcc       /F256 Jr./
                    fcb       $0D
STRLEN2             equ       *-OUTSTR2
OUTSTR3             fcc       /F256 K/
                    fcb       $0D
STRLEN3             equ       *-OUTSTR3
BASL2               fcb       $1B,$32,$07,$DE,$DB,$1B,$32,$06,$DB,$DB
                    fcb       $DB,$1B,$32,$07,$DE,$DB,$1B,$32,$06,$DB
                    fcb       $1B,$32,$08,$B3,$DB,$B4,$1b,$32,$06,$DB
                    fcb       $1b,$32,$08,$BB,$DB,$BC,$1B,$32,$06,$DB
                    fcb       $1B,$32,$04,$DB,$DD,$1b,$32,$06,$DB,$DB
                    fcb       $DB,$DB,$DB,$DB,$1B,$32,$0E,$DB,$DD,$1B,$32,$06,$DB,$1B
                    fcb       $32,$05,$DB,$DD,$1B,$32,$06,$DB,$DB,$DB
                    fcb       $DB,$DB,$DB,$1B,$32,$0F,$DB,$BE,$1B
                    fcb       $32,$06,$DB,$1B,$32,$0F,$B3,$B4,$C1
                    fcb       $DB,$1B,$32,$06,$DB,$DB,$1B,$32,$01,$DB,$DD
                    fcb       $1B,$32,$06,$DB,$DB,$1B,$32,$01,$DE,$DB
                    fcb       $1B,$32,$06,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb       $DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb       $DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb       $DB,$DB,$DB
                    fcb       $13
BASLEN2             equ       *-BASL2
BASL3               fcb       $1B,$32,$07,$DE,$DB,$DB,$DB,$DB,$DB,$BD
                    fcb       $1B,$32,$06,$DB,$1B,$32,$08,$DB,$DB,$DB
                    fcb       $DB,$DB,$DB,$DB,$1B,$32,$06,$DB,$1B,$32
                    fcb       $04,$B6,$DB,$DB,$DB,$DB,$DB,$B7,$1B,$32
                    fcb       $06,$DB,$1B,$32,$0E,$DB,$DD,$1B,$32,$06,$DB,$1B,$32,$05
                    fcb       $DB,$DD,$1B,$32,$06,$DB,$DB,$DB,$DB,$DB
                    fcb       $DB,$1B,$32,$0F,$DB,$DD
                    fcb       $1B,$32,$0F,$B3,$DB,$B4
                    fcb       $DE,$DB,$1B,$32,$06,$DB,$DB,$1B
                    fcb       $32,$01,$B6,$DB,$DB,$DB,$DB,$DB,$1B,$32
                    fcb       $06,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb       $DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb       $DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb       $1B,$32,$07,$DE,$DB,$1B,$32,$06,$DB,$DB
                    fcb       $DB,$1B,$32,$07,$DE,$DB,$1B,$32,$06,$DB
                    fcb       $1B,$32,$08,$DB,$DB,$1B,$32,$06,$DB,$DB
                    fcb       $DB,$1B,$32,$08,$DB,$DB,$1B,$32,$06,$DB
                    fcb       $DB,$DB,$DB,$DB,$DB,$1B,$32,$04,$DE,$DB
                    fcb       $1B,$32,$06,$DB,$1B,$32,$0E,$DB,$DD,$1B,$32,$06,$DB,$1B
                    fcb       $32,$05,$DB,$DD,$1B,$32,$06,$DB,$DB
                    fcb       $DB,$DB,$DB,$DB,$1B,$32,$0F,$DB,$C0,$B3
                    fcb       $B4,$1B,$32,$06,$DB,$1B,$32,$0F,$BF
                    fcb       $DB,$1B,$32,$06,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb       $1B,$32,$01,$DE,$DB
                    fcb       $1B,$32,$06,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb       $DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb       $DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb       $DB,$DB
                    fcb       $1B,$32,$07,$DE,$DB,$DB,$DB,$DB,$DB,$B8
                    fcb       $1B,$32,$06,$DB,$1B,$32,$08,$DB,$B4
                    fcb       $1B,$32,$06,$DB,$DB,$DB,$1B,$32,$08,$BB
                    fcb       $DB,$1B,$32,$06,$DB,$1B,$32,$04,$B9,$DB
                    fcb       $DB,$DB,$DB,$DB,$B8,$1B,$32,$06,$DB,$1B
                    fcb       $32,$0E,$DB,$DD,$1B,$32,$06,$DB,$1B,$32
                    fcb       $05,$B6,$DB,$DB,$DB,$DB,$B8,$1B,$32,$06
                    fcb       $DB,$DB,$1B,$32,$0F,$BB,$DB,$DB,$DB,$DB
                    fcb       $DB,$B4,$1B,$32,$06,$DB,$DB,$1B,$32
                    fcb       $01,$B9,$DB,$DB,$DB,$DB,$B8,$1B,$32,$06,$DB
                    fcb       $1B,$32,$01
BASLEN3	equ	*-BASL3
NEWLN		fcb	$1B,$33,$06,$0C,$0D
NEWLNLEN	equ	*-NEWLN
FONTS               fcb        $01,$03,$07,$0F,$1F,$3F,$7F,$FF		char 179 Left forward slant
                    fcb        $FF,$FE,$FC,$F8,$F0,$E0,$C0,$80		char 180 right forward slant
                    fcb        $07,$1F,$3F,$7F,$7F,$FF,$FF,$FF		char 181 left top rounded
                    fcb        $FF,$FF,$FF,$7F,$7F,$3F,$1F,$07		char 182 left bottom rounded
                    fcb        $E0,$F8,$FC,$FE,$FE,$FF,$FF,$FF		char 183 right top rounded
                    fcb        $FF,$FF,$FF,$FE,$FE,$FC,$F8,$E0		char 184 right bottom rounded
                    fcb        $0F,$1F,$3F,$7F,$7F,$3F,$1F,$0F		char 185 left end cap
                    fcb        $FF,$FE,$FC,$F8,$F0,$E0,$C0,$80		char 186 right forward slant
                    fcb        $FF,$7F,$3F,$1F,$0F,$07,$03,$01		char 187 left reverse slant
                    fcb        $80,$C0,$E0,$F0,$F8,$FC,$FE,$FF		char 188 right reverse slant
                    fcb        $FF,$FF,$FE,$FC,$FC,$FE,$FF,$FF		Char 189 BD B right notch
                    fcb        $FF,$FE,$FC,$F8,$F0,$F0,$F0,$F0               Char 190 BE Left inside Zero
                    fcb        $0F,$0F,$0F,$0F,$1F,$3F,$7F,$FF               Char 191 BF Right inside Zero
                    fcb        $F0,$F0,$F0,$f0,$F8,$FC,$FE,$FF               Char 192 C0 Left bottom inside Zero
                    fcb        $FF,$7F,$3F,$1F,$0F,$0F,$0F,$0F               Char 193 C1 Right Top inside Zero
		    emod
ENDPRG		    equ	*
		    end
		
