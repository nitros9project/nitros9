********************************************************************
* StdPats_4 - Standard Patterns for 4 colors
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2003/11/26  Boisy G. Pitre
* Made into source form.

                    nam       StdPats_4
                    ttl       Standard Patterns for 4 colors


                    org       0

dots                fcb       $1B,$2B
                    fcb       $CC                 group #
                    fcb       $01                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0040               bytes

                    fcb       $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
                    fcb       $33,$33,$33,$33,$33,$33,$33,$33
                    fcb       $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
                    fcb       $33,$33,$33,$33,$33,$33,$33,$33
                    fcb       $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
                    fcb       $33,$33,$33,$33,$33,$33,$33,$33
                    fcb       $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
                    fcb       $33,$33,$33,$33,$33,$33,$33,$33

vrtline             fcb       $1B,$2B
                    fcb       $CC                 group #
                    fcb       $02                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0040               bytes

                    fcb       $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
                    fcb       $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
                    fcb       $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
                    fcb       $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
                    fcb       $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
                    fcb       $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
                    fcb       $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
                    fcb       $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC

hrzline             fcb       $1B,$2B
                    fcb       $CC                 group #
                    fcb       $03                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0040               bytes

                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00

xhatch              fcb       $1B,$2B
                    fcb       $CC                 group #
                    fcb       $04                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0040               bytes

                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC

leftslnt            fcb       $1B,$2B
                    fcb       $CC                 group #
                    fcb       $05                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0040               bytes

                    fcb       $30,$30,$30,$30,$30,$30,$30,$30
                    fcb       $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
                    fcb       $03,$03,$03,$03,$03,$03,$03,$03
                    fcb       $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
                    fcb       $30,$30,$30,$30,$30,$30,$30,$30
                    fcb       $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
                    fcb       $03,$03,$03,$03,$03,$03,$03,$03
                    fcb       $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C

rghtslnt            fcb       $1B,$2B
                    fcb       $CC                 group #
                    fcb       $06                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0040               bytes

                    fcb       $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
                    fcb       $03,$03,$03,$03,$03,$03,$03,$03
                    fcb       $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
                    fcb       $30,$30,$30,$30,$30,$30,$30,$30
                    fcb       $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
                    fcb       $03,$03,$03,$03,$03,$03,$03,$03
                    fcb       $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
                    fcb       $30,$30,$30,$30,$30,$30,$30,$30

smalldot            fcb       $1B,$2B
                    fcb       $CC                 group #
                    fcb       $07                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0040               bytes

                    fcb       $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00

largedot            fcb       $1B,$2B
                    fcb       $CC                 group #
                    fcb       $08                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0040               bytes

                    fcb       $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
                    fcb       $C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3
                    fcb       $C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3
                    fcb       $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
                    fcb       $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
                    fcb       $C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3
                    fcb       $C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3
                    fcb       $3C,$3C,$3C,$3C,$3C,$3C,$3C,$3C
