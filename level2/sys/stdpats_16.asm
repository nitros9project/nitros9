********************************************************************
* StdPats_16 - Standard Patterns for 16 colors
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2003/11/26  Boisy G. Pitre
* Made into source form.

                    nam       StdPats_16
                    ttl       Standard Patterns for 16 colors


                    org       0

dots                fcb       $1B,$2B
                    fcb       $CD                 group #
                    fcb       $01                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0080               bytes

                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
                    fcb       $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
                    fcb       $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
                    fcb       $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
                    fcb       $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F

vrtline             fcb       $1B,$2B
                    fcb       $CD                 group #
                    fcb       $02                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0080               bytes

                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0

hrzline             fcb       $1B,$2B
                    fcb       $CD                 group #
                    fcb       $03                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0080               bytes

                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00

xhatch              fcb       $1B,$2B
                    fcb       $CD                 group #
                    fcb       $04                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0080               bytes

                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
                    fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0

leftslnt            fcb       $1B,$2B
                    fcb       $CD                 group #
                    fcb       $05                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0080               bytes

                    fcb       $0F,$00,$0F,$00,$0F,$00,$0F,$00
                    fcb       $0F,$00,$0F,$00,$0F,$00,$0F,$00
                    fcb       $F0,$00,$F0,$00,$F0,$00,$F0,$00
                    fcb       $F0,$00,$F0,$00,$F0,$00,$F0,$00
                    fcb       $00,$0F,$00,$0F,$00,$0F,$00,$0F
                    fcb       $00,$0F,$00,$0F,$00,$0F,$00,$0F
                    fcb       $00,$F0,$00,$F0,$00,$F0,$00,$F0
                    fcb       $00,$F0,$00,$F0,$00,$F0,$00,$F0
                    fcb       $0F,$00,$0F,$00,$0F,$00,$0F,$00
                    fcb       $0F,$00,$0F,$00,$0F,$00,$0F,$00
                    fcb       $F0,$00,$F0,$00,$F0,$00,$F0,$00
                    fcb       $F0,$00,$F0,$00,$F0,$00,$F0,$00
                    fcb       $00,$0F,$00,$0F,$00,$0F,$00,$0F
                    fcb       $00,$0F,$00,$0F,$00,$0F,$00,$0F
                    fcb       $00,$F0,$00,$F0,$00,$F0,$00,$F0
                    fcb       $00,$F0,$00,$F0,$00,$F0,$00,$F0

rghtslnt            fcb       $1B,$2B
                    fcb       $CD                 group #
                    fcb       $06                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0080               bytes

                    fcb       $00,$F0,$00,$F0,$00,$F0,$00,$F0
                    fcb       $00,$F0,$00,$F0,$00,$F0,$00,$F0
                    fcb       $00,$0F,$00,$0F,$00,$0F,$00,$0F
                    fcb       $00,$0F,$00,$0F,$00,$0F,$00,$0F
                    fcb       $F0,$00,$F0,$00,$F0,$00,$F0,$00
                    fcb       $F0,$00,$F0,$00,$F0,$00,$F0,$00
                    fcb       $0F,$00,$0F,$00,$0F,$00,$0F,$00
                    fcb       $0F,$00,$0F,$00,$0F,$00,$0F,$00
                    fcb       $00,$F0,$00,$F0,$00,$F0,$00,$F0
                    fcb       $00,$F0,$00,$F0,$00,$F0,$00,$F0
                    fcb       $00,$0F,$00,$0F,$00,$0F,$00,$0F
                    fcb       $00,$0F,$00,$0F,$00,$0F,$00,$0F
                    fcb       $F0,$00,$F0,$00,$F0,$00,$F0,$00
                    fcb       $F0,$00,$F0,$00,$F0,$00,$F0,$00
                    fcb       $0F,$00,$0F,$00,$0F,$00,$0F,$00
                    fcb       $0F,$00,$0F,$00,$0F,$00,$0F,$00

smalldot            fcb       $1B,$2B
                    fcb       $CD                 group #
                    fcb       $07                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0080               bytes

                    fcb       $F0,$00,$F0,$00,$F0,$00,$F0,$00
                    fcb       $F0,$00,$F0,$00,$F0,$00,$F0,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$F0,$00,$F0,$00,$F0,$00,$F0
                    fcb       $00,$F0,$00,$F0,$00,$F0,$00,$F0
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $F0,$00,$F0,$00,$F0,$00,$F0,$00
                    fcb       $F0,$00,$F0,$00,$F0,$00,$F0,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$F0,$00,$F0,$00,$F0,$00,$F0
                    fcb       $00,$F0,$00,$F0,$00,$F0,$00,$F0
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00

largedot            fcb       $1B,$2B
                    fcb       $CD                 group #
                    fcb       $08                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0020               xsize
                    fdb       $0008               ysize
                    fdb       $0080               bytes

                    fcb       $0F,$F0,$0F,$F0,$0F,$F0,$0F,$F0
                    fcb       $0F,$F0,$0F,$F0,$0F,$F0,$0F,$F0
                    fcb       $F0,$0F,$F0,$0F,$F0,$0F,$F0,$0F
                    fcb       $F0,$0F,$F0,$0F,$F0,$0F,$F0,$0F
                    fcb       $F0,$0F,$F0,$0F,$F0,$0F,$F0,$0F
                    fcb       $F0,$0F,$F0,$0F,$F0,$0F,$F0,$0F
                    fcb       $0F,$F0,$0F,$F0,$0F,$F0,$0F,$F0
                    fcb       $0F,$F0,$0F,$F0,$0F,$F0,$0F,$F0
                    fcb       $0F,$F0,$0F,$F0,$0F,$F0,$0F,$F0
                    fcb       $0F,$F0,$0F,$F0,$0F,$F0,$0F,$F0
                    fcb       $F0,$0F,$F0,$0F,$F0,$0F,$F0,$0F
                    fcb       $F0,$0F,$F0,$0F,$F0,$0F,$F0,$0F
                    fcb       $F0,$0F,$F0,$0F,$F0,$0F,$F0,$0F
                    fcb       $F0,$0F,$F0,$0F,$F0,$0F,$F0,$0F
                    fcb       $0F,$F0,$0F,$F0,$0F,$F0,$0F,$F0
                    fcb       $0F,$F0,$0F,$F0,$0F,$F0,$0F,$F0
