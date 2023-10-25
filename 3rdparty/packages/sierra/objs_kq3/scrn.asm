********************************************************************
* scrn - Kings Quest III screen module
*
* $Id$
*
* Note the header shows a data size of 0 called from the sierra module
* and accesses data set up in that module.
*
*       Header for : scrn
*       Module size: $7C5  #1989
*       Module CRC : $F3E370 (Good)
*       Hdr parity : $EA
*       Exec. off  : $0012  #18
*       Data size  : $0000  #0
*       Edition    : $00  #0
*       Ty/La At/Rv: $11 $81
*       Prog mod, 6809 Obj, re-ent, R/O
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   0      2003/03/06  Paul W. Zibaila
* Disassembly of original distribution.

                    nam       scrn
                    ttl       Kings Quest III screen module

* Disassembled 00/00/00 00:15:39 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

*  equates for common data used in this module

u0012               equ       $0012               map block value (word)
u001C               equ       $001C
u001E               equ       $001E
u0024               equ       $0024
u002C               equ       $002C
u0030               equ       $0030
u0038               equ       $0038
u003E               equ       $003E
u0040               equ       $0040
u0041               equ       $0041
u0042               equ       $0042               Sierra process descriptor block
u0043               equ       $0043               Sierra 2nd 8K data block
u0045               equ       $0045               flag for palettes in sierra
u0046               equ       $0046               first byte of hi res screen mem addr
u0047               equ       $0047               second byte of hi res screen mem addr
u007E               equ       $007E
u0080               equ       $0080
u0081               equ       $0081
u009E               equ       $009E               busy address here
u009F               equ       $009F
u00A0               equ       $00A0
u00A1               equ       $00A1
u00A2               equ       $00A2
u00A3               equ       $00A3
u00A4               equ       $00A4
u00A5               equ       $00A5
u00A6               equ       $00A6
u00A7               equ       $00A7
u00A8               equ       $00A8
u00A9               equ       $00A9
u00AA               equ       $00AA
u00C0               equ       $00C0
u00C6               equ       $00C6
u00CC               equ       $00CC
u00DE               equ       $00DE
u00E0               equ       $00E0
u00F6               equ       $00F6
u00F8               equ       $00F8
u00FC               equ       $00FC
u00FE               equ       $00FE
u00FF               equ       $00FF

X0100               equ       $0100               pic_visible
X024E               equ       $024E
XFFA9               equ       $FFA9


size                equ       .
name                equ       *
                    fcs       /scrn/
                    fcb       $00

* This module is linked to in sierra
* upon entry
*   a -> type language
*   b -> attributes / revision level
*   x -> address of the last byte of the module name + 1
*   y -> module entry point absolute address
*   u -> module header absolute address

start               equ       *
                    lbra      L015A               twiddles with map blocks ??
                    lbra      L014C               sets up another call to L015A
                    lbra      L009C               whats in D here ? call screen clear
                    lbra      L00B3               sets D to 0000 and call clear screen
                    lbra      L00D2
                    lbra      L0745
                    lbra      L0209
                    lbra      L00C5
                    lbra      L025D
                    lbra      L02A0

* probably was an info directive for an include file
L0030               fcc       'AGI (c) copyright 1988 SIERRA On-Line'
                    fcc       'CoCo3 version by Chris Iden'
                    fcb       $00
Infosz              equ       *-L0030



* map block check and sets
* u0012 is set in code in L015A sub
* entry:
*      a -> value to be tested

L0071               cmpa      <u0012              check MMU block
                    beq       L008B               if block 0  OK to leave
                    orcc      #IntMasks           Turn off interrupts
                    sta       <u0012              store the value passed in by a
                    lda       <u0042              get sierra process descriptor map block
                    sta       >XFFA9              map it in to $2000-$3FFF
                    ldx       <u0043              2nd 8K data block in Sierra
                    lda       <u0012              get mmu block num
                    sta       ,x                  store that
                    stb       $02,x
                    std       >XFFA9              Map it into task 1 block 2
                    andcc     #^IntMasks          turn on interrupts $AF
L008B               rts


* 16 marker bytes for some thing
* coco_view_pal[]     vid_render.c
L008C               fcb       $00
                    fcb       $11
                    fcb       $22
                    fcb       $33
                    fcb       $44
                    fcb       $55
                    fcb       $66
                    fcb       $77
                    fcb       $88
                    fcb       $99
                    fcb       $AA
                    fcb       $BB
                    fcb       $CC
                    fcb       $DD
                    fcb       $EE
                    fcb       $FF


* Clears the area allocated to the screen in sierra
* entry:
*      d -> value to be written to screen
*      x -> may contain a value so we save it
* exit:
*      d -> preserved
*      x -> restored to initial value
*      u -> contains starting address of the screen

L009C               pshs      x                   save the x values as this routine uses it
L009E               ldu       #$D800              end address of high res screen
                    ldx       #$7800              Scrn is from $6000 to $D800
L00A4               std       ,--u                set it to value passed us in d & dec d
                    leax      -$02,x              decrement x
                    bne       L00A4               keep going till all of screen is cleared
                    puls      x                   restore x`
                    rts                           move on

* Loads D to clear screen
L00AD               ldd       #$0000              zeros screen bytes
                    bsr       L009C               go clear it
                    rts

L00B3               bsr       L00AD               clear the screen
                    ldd       #$A8A0
                    pshs      d
                    ldd       #$00A7
                    pshs      d
                    lbsr      L015A
                    leas      $04,s
                    rts

L00C5               lda       >X024E
                    tfr       a,b
                    bsr       L009C
                    ldd       #$0000              clears value at u0040
                    std       <u0040
                    rts

L00D2               ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L01D4
                    leas      $06,s
                    clra
                    ldb       $06,s
                    pshs      d
                    lda       #$01
                    ldb       $07,s
                    subb      #$02
                    pshs      d
                    ldd       $06,s
                    inca
                    decb
                    pshs      d
                    lbsr      L01D4
                    leas      $06,s
                    clra
                    ldb       $06,s
                    pshs      d
                    lda       $06,s
                    suba      #$04
                    ldb       #$01
                    pshs      d
                    ldd       $06,s
                    adda      $09,s
                    suba      #$02
                    subb      #$02
                    pshs      d
                    lbsr      L01D4
                    leas      $06,s
                    clra
                    ldb       $06,s
                    pshs      d
                    lda       #$01
                    ldb       $07,s
                    subb      #$02
                    pshs      d
                    ldd       $06,s
                    inca
                    subb      $08,s
                    addb      #$02
                    pshs      d
                    lbsr      L01D4
                    leas      $06,s
                    clra
                    ldb       $06,s
                    pshs      d
                    lda       $06,s
                    suba      #$04
                    ldb       #$01
                    pshs      d
                    ldd       $06,s
                    inca
                    subb      #$02
                    pshs      d
                    lbsr      L01D4
                    leas      $06,s
                    rts

L014C               ldd       $04,s
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L015A
                    leas      $04,s
                    rts

* first call in module is here
* who put what on the stack for us ?
L015A               pshs      y                   save our y  module entry abs addr

                    ldd       $04,s
                    sta       <u0047
                    incb
                    subb      $06,s
                    lda       #$A0
                    mul
                    addd      <u0046
                    tfr       d,x
                    addd      <u002C
                    tfr       d,y
                    leax      <$40,x
                    ldd       $06,s
                    std       <u009E

                    ldb       #$A0
                    subb      <u009F
                    clra
                    std       <u00A0
                    sta       <u0012              twiddle with the map block value

                    orcc      #IntMasks           turn off interrupts $50
                    lda       <u0042
                    sta       >XFFA9              second block in task 1
                    cmpx      #$A000
                    bcs       L0192

                    ldd       <u001E
                    leax      >-$8000,x
                    bra       L0198
L0192               ldd       <u001C
                    leax      >-$4000,x
L0198               ldu       <u0043
                    sta       ,u
                    stb       $02,u
                    std       >XFFA9              second block in task 1
                    andcc     #^IntMasks          turn on ints $AF

                    leau      >L008C,pcr          point u to the  sequential data bytes
L01A7               ldb       <u009F
L01A9               lda       ,x+
                    anda      #$0F
                    lda       a,u
                    sta       ,y+
                    decb
                    bne       L01A9
                    dec       <u009E
                    beq       L01D1               pull our y and exit routine
                    ldd       <u00A0
                    leay      d,y
                    abx
                    cmpx      #$6000
                    bcs       L01A7

                    orcc      #IntMasks           turn off interrupts $50
                    lda       <u0042
                    sta       >XFFA9              second block in task 1
                    ldd       <u001E
                    leax      >-$4000,x
                    bra       L0198
L01D1               puls      y
                    rts


L01D4               ldd       $02,s
                    sta       <u0047
                    incb
                    subb      $04,s
                    lda       #$A0
                    mul
                    addd      <u0046              Hi res screen mem address ($6000)
                    addd      <u002C
                    tfr       d,x
                    ldd       $04,s
                    std       <u009E
                    ldb       #$A0
                    subb      <u009F
                    stb       <u00A0
                    leau      >L008C,pcr
                    lda       $07,s
                    anda      #$0F
                    lda       a,u

L01F8               ldb       <u009F
L01FA               sta       ,x+
                    decb
                    bne       L01FA

                    dec       <u009E
                    beq       L0208
                    ldb       <u00A0
                    abx
                    bra       L01F8
L0208               rts


L0209               leas      -$04,s
                    ldd       $0A,s
                    std       $02,s
                    ldd       $08,s
                    std       ,s
                    lda       $07,s
                    lsla
                    lsla
                    lsla
                    ldb       #$A0
                    mul
                    std       <u00A2
                    clra
                    ldb       $01,s
                    lslb
                    lslb
                    ldu       <u00A2
                    leau      >$6000,u
                    ldb       $02,s
                    lslb
                    lslb
                    lslb
                    lda       #$A0
                    mul
                    leax      d,u
                    lda       $03,s
                    lsla
                    lsla
                    lsla
                    ldb       $01,s
                    subb      ,s
                    lslb
                    lslb
                    addb      #$03
L023F               pshs      b,a
L0241               lda       b,u
                    sta       b,x
                    decb
                    bpl       L0241
                    puls      b,a
                    leau      >$00A0,u
                    leax      >$00A0,x
                    cmpx      #$D800
                    bcc       L025A
                    deca
                    bne       L023F
L025A               leas      $04,s
                    rts



L025D               leas      -$04,s
                    ldx       $06,s
                    ldu       ,x
L0263               stu       ,s
                    beq       L029D
                    ldu       $04,u
                    stu       $02,s
                    pshs      u
                    lbsr      L02A0
                    leas      $02,s
                    ldu       $02,s
                    lda       $01,u
                    cmpa      ,u
                    bne       L0297
                    ldd       $03,u
                    cmpd      <$1A,u
                    bne       L028C
                    lda       <$25,u
                    ora       #$40
                    sta       <$25,u
                    bra       L0297
L028C               std       <$1A,u
                    lda       <$25,u
                    anda      #$BF
                    sta       <$25,u
L0297               ldu       ,s
                    ldu       ,u
                    bra       L0263
L029D               leas      $04,s
                    rts


L02A0               lda       >X0100              pic_visible
                    lbeq      L0344
                    ldu       $02,s
                    ldd       $08,u
                    lbsr      L0071
                    ldx       <$10,u
                    ldd       ,x
                    std       <u00A0
                    ldd       <$14,u
                    lbsr      L0071
                    ldx       <$12,u
                    ldd       ,x
                    std       <u009E
                    ldd       <$10,u
                    std       <$12,u
                    ldd       $08,u
                    std       <$14,u
                    lda       $04,u
                    ldb       <u00A1
                    cmpa      <$1B,u
                    bcs       L02E1
                    sta       <u00A3
                    stb       <u00A4
                    lda       <$1B,u
                    ldb       <u009F
                    bra       L02EC
L02E1               ldb       <$1B,u
                    stb       <u00A3
                    ldb       <u009F
                    stb       <u00A4
                    ldb       <u00A1
L02EC               stb       <u00A8
                    inca
                    suba      <u00A8
                    ldb       <u00A3
                    incb
                    subb      <u00A4
                    stb       <u00A7
                    cmpa      <u00A7
                    bcs       L02FE
                    lda       <u00A7
L02FE               nega
                    adda      <u00A3
                    inca
                    sta       <u00A4
                    lda       $03,u
                    ldb       <u00A0
                    cmpa      <$1A,u
                    bhi       L0318
                    sta       <u00A2
                    stb       <u00A9
                    lda       <$1A,u
                    ldb       <u009E
                    bra       L0323
L0318               ldb       <$1A,u
                    stb       <u00A2
                    ldb       <u009E
                    stb       <u00A9
                    ldb       <u00A0
L0323               stb       <u00AA
                    adda      <u00AA
                    sta       <u00A6
                    lda       <u00A2
                    adda      <u00A9
                    cmpa      <u00A6
                    bhi       L0333
                    lda       <u00A6
L0333               suba      <u00A2
                    sta       <u00A5
                    ldd       <u00A4
                    pshs      b,a
                    ldd       <u00A2
                    pshs      b,a
                    lbsr      L015A
                    leas      $04,s
L0344               rts

* This jumbled mass of bytes disassembles
* but looks like a data block
* or probably a bit map ???
* L0345 - L0745 is 1024 bytes of data

L0345               fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $7E,$81,$A5,$81
                    fcb       $BD,$99,$81,$7E
                    fcb       $7E,$FF,$DB,$FF
                    fcb       $C3,$E7,$FF,$7E
                    fcb       $6C,$FE,$FE,$FE
                    fcb       $7C,$38,$10,$00
                    fcb       $10,$38,$7C,$FE
                    fcb       $7C,$38,$10,$00
                    fcb       $38,$7C,$38,$FE
                    fcb       $FE,$7C,$38,$7C
                    fcb       $10,$10,$38,$7C
                    fcb       $FE,$7C,$38,$7C
                    fcb       $00,$00,$18,$3C
                    fcb       $3C,$18,$00,$00
                    fcb       $FF,$FF,$E7,$C3
                    fcb       $C3,$E7,$FF,$FF
                    fcb       $00,$3C,$66,$42
                    fcb       $42,$66,$3C,$00
                    fcb       $FF,$C3,$99,$BD
                    fcb       $BD,$99,$C3,$FF
                    fcb       $0F,$07,$0F,$7D
                    fcb       $CC,$CC,$CC,$78
                    fcb       $3C,$66,$66,$66
                    fcb       $3C,$18,$7E,$18
                    fcb       $3F,$33,$3F,$30
                    fcb       $30,$70,$F0,$E0
                    fcb       $7F,$63,$7F,$63
                    fcb       $63,$67,$E6,$C0
                    fcb       $99,$5A,$3C,$E7
                    fcb       $E7,$3C,$5A,$99
                    fcb       $80,$E0,$F8,$FE
                    fcb       $F8,$E0,$80,$00
                    fcb       $02,$0E,$3E,$FE
                    fcb       $3E,$0E,$02,$00
                    fcb       $18,$3C,$7E,$18
                    fcb       $18,$7E,$3C,$18
                    fcb       $66,$66,$66,$66
                    fcb       $66,$00,$66,$00
                    fcb       $7F,$DB,$DB,$7B
                    fcb       $1B,$1B,$1B,$00
                    fcb       $3E,$63,$38,$6C
                    fcb       $6C,$38,$CC,$78
                    fcb       $00,$00,$00,$00
                    fcb       $7E,$7E,$7E,$00
                    fcb       $18,$3C,$7E,$18
                    fcb       $7E,$3C,$18,$FF
                    fcb       $18,$3C,$7E,$18
                    fcb       $18,$18,$18,$00
                    fcb       $18,$18,$18,$18
                    fcb       $7E,$3C,$18,$00
                    fcb       $00,$18,$0C,$FE
                    fcb       $0C,$18,$00,$00
                    fcb       $00,$30,$60,$FE
                    fcb       $60,$30,$00,$00
                    fcb       $00,$00,$C0,$C0
                    fcb       $C0,$FE,$00,$00
                    fcb       $00,$24,$66,$FF
                    fcb       $66,$24,$00,$00
                    fcb       $00,$18,$3C,$7E
                    fcb       $FF,$FF,$00,$00
                    fcb       $00,$FF,$FF,$7E
                    fcb       $3C,$18,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $30,$78,$78,$30
                    fcb       $30,$00,$30,$00
                    fcb       $6C,$6C,$6C,$00
                    fcb       $00,$00,$00,$00
                    fcb       $6C,$6C,$FE,$6C
                    fcb       $FE,$6C,$6C,$00
                    fcb       $30,$7C,$C0,$78
                    fcb       $0C,$F8,$30,$00
                    fcb       $00,$C6,$CC,$18
                    fcb       $30,$66,$C6,$00
                    fcb       $38,$6C,$38,$76
                    fcb       $DC,$CC,$76,$00
                    fcb       $60,$60,$C0,$00
                    fcb       $00,$00,$00,$00
                    fcb       $18,$30,$60,$60
                    fcb       $60,$30,$18,$00
                    fcb       $60,$30,$18,$18
                    fcb       $18,$30,$60,$00
                    fcb       $00,$66,$3C,$FF
                    fcb       $3C,$66,$00,$00
                    fcb       $00,$30,$30,$FC
                    fcb       $30,$30,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$30,$30,$60
                    fcb       $00,$00,$00,$FC
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$30,$30,$00
                    fcb       $06,$0C,$18,$30
                    fcb       $60,$C0,$80,$00
                    fcb       $7C,$C6,$CE,$DE
                    fcb       $F6,$E6,$7C,$00
                    fcb       $30,$70,$30,$30
                    fcb       $30,$30,$FC,$00
                    fcb       $78,$CC,$0C,$38
                    fcb       $60,$CC,$FC,$00
                    fcb       $78,$CC,$0C,$38
                    fcb       $0C,$CC,$78,$00
                    fcb       $1C,$3C,$6C,$CC
                    fcb       $FE,$0C,$1E,$00
                    fcb       $FC,$C0,$F8,$0C
                    fcb       $0C,$CC,$78,$00
                    fcb       $38,$60,$C0,$F8
                    fcb       $CC,$CC,$78,$00
                    fcb       $FC,$CC,$0C,$18
                    fcb       $30,$30,$30,$00
                    fcb       $78,$CC,$CC,$78
                    fcb       $CC,$CC,$78,$00
                    fcb       $78,$CC,$CC,$7C
                    fcb       $0C,$18,$70,$00
                    fcb       $00,$30,$30,$00
                    fcb       $00,$30,$30,$00
                    fcb       $00,$30,$30,$00
                    fcb       $00,$30,$30,$60
                    fcb       $18,$30,$60,$C0
                    fcb       $60,$30,$18,$00
                    fcb       $00,$00,$FC,$00
                    fcb       $00,$FC,$00,$00
                    fcb       $60,$30,$18,$0C
                    fcb       $18,$30,$60,$00
                    fcb       $78,$CC,$0C,$18
                    fcb       $30,$00,$30,$00
                    fcb       $7C,$C6,$DE,$DE
                    fcb       $DE,$C0,$78,$00
                    fcb       $30,$78,$CC,$CC
                    fcb       $FC,$CC,$CC,$00
                    fcb       $FC,$66,$66,$7C
                    fcb       $66,$66,$FC,$00
                    fcb       $3C,$66,$C0,$C0
                    fcb       $C0,$66,$3C,$00
                    fcb       $F8,$6C,$66,$66
                    fcb       $66,$6C,$F8,$00
                    fcb       $FE,$62,$68,$78
                    fcb       $68,$62,$FE,$00
                    fcb       $FE,$62,$68,$78
                    fcb       $68,$60,$F0,$00
                    fcb       $3C,$66,$C0,$C0
                    fcb       $CE,$66,$3E,$00
                    fcb       $CC,$CC,$CC,$FC
                    fcb       $CC,$CC,$CC,$00
                    fcb       $78,$30,$30,$30
                    fcb       $30,$30,$78,$00
                    fcb       $1E,$0C,$0C,$0C
                    fcb       $CC,$CC,$78,$00
                    fcb       $E6,$66,$6C,$78
                    fcb       $6C,$66,$E6,$00
                    fcb       $F0,$60,$60,$60
                    fcb       $62,$66,$FE,$00
                    fcb       $C6,$EE,$FE,$FE
                    fcb       $D6,$C6,$C6,$00
                    fcb       $C6,$E6,$F6,$DE
                    fcb       $CE,$C6,$C6,$00
                    fcb       $38,$6C,$C6,$C6
                    fcb       $C6,$6C,$38,$00
                    fcb       $FC,$66,$66,$7C
                    fcb       $60,$60,$F0,$00
                    fcb       $78,$CC,$CC,$CC
                    fcb       $DC,$78,$1C,$00
                    fcb       $FC,$66,$66,$7C
                    fcb       $6C,$66,$E6,$00
                    fcb       $78,$CC,$E0,$70
                    fcb       $1C,$CC,$78,$00
                    fcb       $FC,$B4,$30,$30
                    fcb       $30,$30,$78,$00
                    fcb       $CC,$CC,$CC,$CC
                    fcb       $CC,$CC,$FC,$00
                    fcb       $CC,$CC,$CC,$CC
                    fcb       $CC,$78,$30,$00
                    fcb       $C6,$C6,$C6,$D6
                    fcb       $FE,$EE,$C6,$00
                    fcb       $C6,$C6,$6C,$38
                    fcb       $38,$6C,$C6,$00
                    fcb       $CC,$CC,$CC,$78
                    fcb       $30,$30,$78,$00
                    fcb       $FE,$C6,$8C,$18
                    fcb       $32,$66,$FE,$00
                    fcb       $78,$60,$60,$60
                    fcb       $60,$60,$78,$00
                    fcb       $C0,$60,$30,$18
                    fcb       $0C,$06,$02,$00
                    fcb       $78,$18,$18,$18
                    fcb       $18,$18,$78,$00
                    fcb       $10,$38,$6C,$C6
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$FF
                    fcb       $30,$30,$18,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$78,$0C
                    fcb       $7C,$CC,$76,$00
                    fcb       $E0,$60,$60,$7C
                    fcb       $66,$66,$DC,$00
                    fcb       $00,$00,$78,$CC
                    fcb       $C0,$CC,$78,$00
                    fcb       $1C,$0C,$0C,$7C
                    fcb       $CC,$CC,$76,$00
                    fcb       $00,$00,$78,$CC
                    fcb       $FC,$C0,$78,$00
                    fcb       $38,$6C,$60,$F0
                    fcb       $60,$60,$F0,$00
                    fcb       $00,$00,$76,$CC
                    fcb       $CC,$7C,$0C,$F8
                    fcb       $E0,$60,$6C,$76
                    fcb       $66,$66,$E6,$00
                    fcb       $30,$00,$70,$30
                    fcb       $30,$30,$78,$00
                    fcb       $0C,$00,$0C,$0C
                    fcb       $0C,$CC,$CC,$78
                    fcb       $E0,$60,$66,$6C
                    fcb       $78,$6C,$E6,$00
                    fcb       $70,$30,$30,$30
                    fcb       $30,$30,$78,$00
                    fcb       $00,$00,$CC,$FE
                    fcb       $FE,$D6,$C6,$00
                    fcb       $00,$00,$F8,$CC
                    fcb       $CC,$CC,$CC,$00
                    fcb       $00,$00,$78,$CC
                    fcb       $CC,$CC,$78,$00
                    fcb       $00,$00,$DC,$66
                    fcb       $66,$7C,$60,$F0
                    fcb       $00,$00,$76,$CC
                    fcb       $CC,$7C,$0C,$1E
                    fcb       $00,$00,$DC,$76
                    fcb       $66,$60,$F0,$00
                    fcb       $00,$00,$7C,$C0
                    fcb       $78,$0C,$F8,$00
                    fcb       $10,$30,$7C,$30
                    fcb       $30,$34,$18,$00
                    fcb       $00,$00,$CC,$CC
                    fcb       $CC,$CC,$76,$00
                    fcb       $00,$00,$CC,$CC
                    fcb       $CC,$78,$30,$00
                    fcb       $00,$00,$C6,$D6
                    fcb       $FE,$FE,$6C,$00
                    fcb       $00,$00,$C6,$6C
                    fcb       $38,$6C,$C6,$00
                    fcb       $00,$00,$CC,$CC
                    fcb       $CC,$7C,$0C,$F8
                    fcb       $00,$00,$FC,$98
                    fcb       $30,$64,$FC,$00
                    fcb       $1C,$30,$30,$E0
                    fcb       $30,$30,$1C,$00
                    fcb       $18,$18,$18,$00
                    fcb       $18,$18,$18,$00
                    fcb       $E0,$30,$30,$1C
                    fcb       $30,$30,$E0,$00
                    fcb       $76,$DC,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$10,$38,$6C
                    fcb       $C6,$C6,$FE,$00

L0745               leas      -$02,s
                    pshs      y
                    ldx       $06,s
                    ldu       #X024E
                    lda       <u0040
                    lsla
                    lsla
                    lsla
                    ldb       #$A0
                    mul
                    tfr       d,y
                    clra
                    ldb       <u0041
                    lslb
                    lslb
                    addd      #$6000
                    leay      d,y
L0762               tst       ,x
                    lbeq      L07B0
                    ldb       ,x+
                    stx       $06,s
                    leax      >L0345,pcr
                    lslb
                    abx
                    abx
                    abx
                    abx
                    lda       #$08
                    sta       $02,s
L0779               ldb       ,x+
                    lda       #$04
                    sta       $03,s
L077F               sex
                    lda       a,u
                    anda      #$F0
                    sta       ,y
                    lslb
                    sex
                    lda       a,u
                    anda      #$0F
                    ora       ,y
                    ora       <u0045              flag for palettes set in sierra
                    sta       ,y+
                    lslb
                    dec       $03,s
                    bne       L077F
                    lda       <u0045              flag for palettes set in sierra
                    beq       L079E
                    coma
                    sta       <u0045              flag for palettes set in sierra
L079E               leay      >$009C,y
                    dec       $02,s
                    bne       L0779
                    ldx       $06,s
                    inc       <u0041
                    leay      >-$04FC,y
                    bra       L0762
L07B0               puls      y
                    leas      $02,s
                    rts

L07B5               fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
L07BD               fcc       /scrn/
L07C1               fcb       $00

                    emod
eom                 equ       *
                    end

