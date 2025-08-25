********************************************************************
* StdPtrs - Standard Pointers
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2003/11/26  Boisy G. Pitre
* Made into source form.

                    nam       StdPtrs
                    ttl       Standard Pointers


                    org       0

pointer             fcb       $1B,$2B
                    fcb       $CA                 group #
                    fcb       $01                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0008               xsize
                    fdb       $0008               ysize
                    fdb       $0008               bytes

                    fcb       %11111000
                    fcb       %11110000
                    fcb       %11110000
                    fcb       %11111000
                    fcb       %10011100
                    fcb       %00001110
                    fcb       %00000111
                    fcb       %00000010

pencil              fcb       $1B,$2B
                    fcb       $CA                 group #
                    fcb       $02                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0010               xsize
                    fdb       $000d               ysize
                    fdb       $001a               bytes

                    fcb       %11110000,%00000000
                    fcb       %10101000,%00000000
                    fcb       %11000100,%00000000
                    fcb       %10000010,%00000000
                    fcb       %01000001,%00000000
                    fcb       %00100000,%10000000
                    fcb       %00010000,%01000000
                    fcb       %00001000,%00100000
                    fcb       %00000100,%01010000
                    fcb       %00000010,%10001000
                    fcb       %00000001,%00010000
                    fcb       %00000000,%10100000
                    fcb       %00000000,%01000000

lcross              fcb       $1B,$2B
                    fcb       $CA                 group #
                    fcb       $03                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0010               xsize
                    fdb       $0010               ysize
                    fdb       $0020               bytes

                    fcb       %00000011,%00000000
                    fcb       %00000011,%00000000
                    fcb       %00000011,%00000000
                    fcb       %00000011,%00000000
                    fcb       %00000011,%00000000
                    fcb       %00000011,%00000000
                    fcb       %00000011,%00000000
                    fcb       %11111111,%11111111
                    fcb       %11111111,%11111111
                    fcb       %00000011,%00000000
                    fcb       %00000011,%00000000
                    fcb       %00000011,%00000000
                    fcb       %00000011,%00000000
                    fcb       %00000011,%00000000
                    fcb       %00000011,%00000000
                    fcb       %00000011,%00000000

sleep               fcb       $1B,$2B
                    fcb       $CA                 group #
                    fcb       $04                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0010               xsize
                    fdb       $0010               ysize
                    fdb       $0020               bytes

                    fcb       %11111111,%11111111
                    fcb       %01000000,%00000010
                    fcb       %00100000,%00000100
                    fcb       %00011111,%11111000
                    fcb       %00001111,%11110000
                    fcb       %00000111,%11100000
                    fcb       %00000011,%11000000
                    fcb       %00000001,%10000000
                    fcb       %00000001,%10000000
                    fcb       %00000010,%01000000
                    fcb       %00000101,%10100000
                    fcb       %00001000,%00010000
                    fcb       %00010001,%10001000
                    fcb       %00100011,%11000100
                    fcb       %01000111,%11100010
                    fcb       %11111111,%11111111

illegal             fcb       $1B,$2B
                    fcb       $CA                 group #
                    fcb       $05                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0010               xsize
                    fdb       $000f               ysize
                    fdb       $001e               bytes

                    fcb       %00000111,%11000000
                    fcb       %00011000,%00110000
                    fcb       %00100000,%00001000
                    fcb       %01000000,%00011100
                    fcb       %01000000,%00110100
                    fcb       %10000000,%01100010
                    fcb       %10000000,%11000010
                    fcb       %10000001,%10000010
                    fcb       %10000011,%00000010
                    fcb       %10000110,%00000010
                    fcb       %01001100,%00000100
                    fcb       %01011000,%00000100
                    fcb       %00110000,%00001000
                    fcb       %00011000,%00110000
                    fcb       %00000111,%11000000

textmark            fcb       $1B,$2B
                    fcb       $CA                 group #
                    fcb       $06                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0008               xsize
                    fdb       $0008               ysize
                    fdb       $0008               bytes

                    fcb       %11111111
                    fcb       %00011000
                    fcb       %00011000
                    fcb       %00011000
                    fcb       %00011000
                    fcb       %00011000
                    fcb       %00011000
                    fcb       %11111111

scross              fcb       $1B,$2B
                    fcb       $CA                 group #
                    fcb       $07                 buffer #
                    fcb       $05                 style 640x192x2
                    fdb       $0008               xsize
                    fdb       $0008               ysize
                    fdb       $0008               bytes

                    fcb       %00011000
                    fcb       %00011000
                    fcb       %00011000
                    fcb       %11111111
                    fcb       %00011000
                    fcb       %00011000
                    fcb       %00011000
                    fcb       %00000000

