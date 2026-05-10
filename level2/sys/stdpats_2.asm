********************************************************************
* StdPats_2 - Standard Patterns for 2 colors
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2003/11/26  Boisy G. Pitre
* Made into source form.

                    nam       StdPats_2
                    ttl       Standard Patterns for 2 colors


                    org       0

dots                fcb       $1B,$2B
                    fcb       $CB                 group #
                    fcb       $01                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0020               bytes

                    fcb       $AA,$AA,$AA,$AA
                    fcb       $55,$55,$55,$55
                    fcb       $AA,$AA,$AA,$AA
                    fcb       $55,$55,$55,$55
                    fcb       $AA,$AA,$AA,$AA
                    fcb       $55,$55,$55,$55
                    fcb       $AA,$AA,$AA,$AA
                    fcb       $55,$55,$55,$55

vrtline             fcb       $1B,$2B
                    fcb       $CB                 group #
                    fcb       $02                 buffer #
                    fcb       $05                 style
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0020               bytes

                    fcb       $88,$88,$88,$88
                    fcb       $88,$88,$88,$88
                    fcb       $88,$88,$88,$88
                    fcb       $88,$88,$88,$88
                    fcb       $88,$88,$88,$88
                    fcb       $88,$88,$88,$88
                    fcb       $88,$88,$88,$88
                    fcb       $88,$88,$88,$88

hrzline             fcb       $1B,$2B
                    fcb       $CB                 group #
                    fcb       $03                 buffer #
                    fcb       $05                 style
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0020               bytes

                    fcb       $FF,$FF,$FF,$FF
                    fcb       $00,$00,$00,$00
                    fcb       $FF,$FF,$FF,$FF
                    fcb       $00,$00,$00,$00
                    fcb       $FF,$FF,$FF,$FF
                    fcb       $00,$00,$00,$00
                    fcb       $FF,$FF,$FF,$FF
                    fcb       $00,$00,$00,$00

xhatch              fcb       $1B,$2B
                    fcb       $CB                 group #
                    fcb       $04                 buffer #
                    fcb       $05                 style
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0020               bytes

                    fcb       $FF,$FF,$FF,$FF
                    fcb       $88,$88,$88,$88
                    fcb       $FF,$FF,$FF,$FF
                    fcb       $88,$88,$88,$88
                    fcb       $FF,$FF,$FF,$FF
                    fcb       $88,$88,$88,$88
                    fcb       $FF,$FF,$FF,$FF
                    fcb       $88,$88,$88,$88

leftslnt            fcb       $1B,$2B
                    fcb       $CB                 group #
                    fcb       $05                 buffer #
                    fcb       $05                 style
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0020               bytes

                    fcb       $44,$44,$44,$44
                    fcb       $88,$88,$88,$88
                    fcb       $11,$11,$11,$11
                    fcb       $22,$22,$22,$22
                    fcb       $44,$44,$44,$44
                    fcb       $88,$88,$88,$88
                    fcb       $11,$11,$11,$11
                    fcb       $22,$22,$22,$22

rghtslnt            fcb       $1B,$2B
                    fcb       $CB                 group #
                    fcb       $06                 buffer #
                    fcb       $05                 style
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0020               bytes

                    fcb       $22,$22,$22,$22
                    fcb       $11,$11,$11,$11
                    fcb       $88,$88,$88,$88
                    fcb       $44,$44,$44,$44
                    fcb       $22,$22,$22,$22
                    fcb       $11,$11,$11,$11
                    fcb       $88,$88,$88,$88
                    fcb       $44,$44,$44,$44

smalldot            fcb       $1B,$2B
                    fcb       $CB                 group #
                    fcb       $07                 buffer #
                    fcb       $05                 style
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0020               bytes

                    fcb       $88,$88,$88,$88
                    fcb       $00,$00,$00,$00
                    fcb       $22,$22,$22,$22
                    fcb       $00,$00,$00,$00
                    fcb       $88,$88,$88,$88
                    fcb       $00,$00,$00,$00
                    fcb       $22,$22,$22,$22
                    fcb       $00,$00,$00,$00

largedot            fcb       $1B,$2B
                    fcb       $CB                 group #
                    fcb       $08                 buffer #
                    fcb       $05                 style
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0020               bytes

                    fcb       $66,$66,$66,$66
                    fcb       $99,$99,$99,$99
                    fcb       $99,$99,$99,$99
                    fcb       $66,$66,$66,$66
                    fcb       $66,$66,$66,$66
                    fcb       $99,$99,$99,$99
                    fcb       $99,$99,$99,$99
                    fcb       $66,$66,$66,$66

