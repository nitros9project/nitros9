                    nam       mach_coco
                    ttl       CoCo machine routines

                    section   code

PIA0Base            equ       $FF00
PIA1Base            equ       $FF20
DAT.Regs            equ       $FFA0

mach_init
* CoCo 3 Initialization Code
                    clr       $FFD9               go into fast mode

* Setup MMU
                    ldx       #DAT.Regs
                    leay      MMUTbl,pcr
                    ldb       #16
MMULoop             lda       ,y+
                    sta       ,x+
                    decb
                    bne       MMULoop

* Setup video
                    leau      CC3Regs,pcr         point to video setup data
                    ldx       #$FF90
Loop1               ldd       ,u++                get the bytes
                    std       ,x++                save in the hardware
                    cmpx      #$FFA0
                    bcs       Loop1

* Set palettes up
                    leau      PalTbl,pcr
                    ldy       #$FFB0              palette register
                    ldb       #16
                    lbsr      CopyRtn

* Initialize PIAs
                    ldx       #PIA1Base           RG - Initialize the PIA 1
                    ldd       #$FF34
                    clr       1,x                 cassette motor off, 0,x is DDR
                    clr       3,x                 2,x is DDR
                    deca                          A = $FE
                    sta       ,x                  cassette bit 0 input, all others output
                    lda       #$F8                bits 7-3 output, bits 2-0 input
                    sta       2,x                 set DDR
                    stb       1,x                 0,x not DDR
                    stb       3,x                 2,x not DDR
                    clr       2,x
                    lda       #$02                RS-232 bit hi
                    sta       ,x                  set it

                    lda       #$FF                all outputs
                    ldx       #PIA0Base
                    clr       1,x                 0,x is DDR
                    clr       3,x                 2,x is DDR
                    clr       ,x                  all inputs
                    sta       2,x                 all outputs
                    stb       1,x                 0,x is not DDR
                    stb       3,x                 2,x is not DDR
                    clr       2,x

                    rts

CopyRtn             clra
                    tfr       d,x
Copy1               ldb       ,u+
                    stb       ,y+
                    leax      -1,x
                    bne       Copy1
                    rts

* MMU
MMUTbl
                    fcb       $38,$39,$3A,$3B,$3C,$3D,$3E,$3F
                    fcb       $38,$39,$3A,$3B,$3C,$3D,$3E,$3F

* GIME register default values
CC3Regs             fcb       $EC                 CC2, MMU, IRQ, Vector page, SCS
                    fcb       $00                 map type 0
                    fcb       $00                 no FIRQ
                    fcb       $00                 no IRQ
                    fdb       $0900               timer
                    fcb       $00                 unused
                    fcb       $00                 unused
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fdb       $0FE0
                    fcb       $00
                    fcb       $00

* Palette register default colors
PalTbl
                    fcb       $12                 green
                    fcb       $36
                    fcb       $09                 blue
                    fcb       $24                 red
                    fcb       $3F                 white
                    fcb       $1B                 cyan
                    fcb       $2D                 magenta
                    fcb       $26
                    fcb       $00                 black
                    fcb       $12                 green
                    fcb       $00                 black
                    fcb       $3F                 white
                    fcb       $00                 black
                    fcb       $12                 green
                    fcb       $00                 black
                    fcb       $26


                    endsect
