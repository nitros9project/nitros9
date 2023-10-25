* Standard Multi-Vue scroll bar icons
* This is a linked list.

                    nam       stdmv
                    ttl       Windows Module


* group header data for special multivue scroll bar
* GPLoad 206 decimal
* right arrow
                    org       0
                    fcb       $1B,$2B,$CE
                    fcb       4                   *buffer #
                    fcb       5                   *style 640x192x2
                    fdb       8                   *xsize
                    fdb       8                   *ysize
                    fdb       8                   *bytes
                    fcb       %00000000
                    fcb       %00100000
                    fcb       %00110000
                    fcb       %00111000
                    fcb       %00111000
                    fcb       %00110000
                    fcb       %00100000
                    fcb       %11111111
* left arrow
                    fcb       $1B,$2B,$CE
                    fcb       3                   buffer #
                    fcb       5                   style 640x192x2
                    fdb       8                   xsize
                    fdb       8                   ysize
                    fdb       8                   bytes
                    fcb       %10000000
                    fcb       %10001000
                    fcb       %10011000
                    fcb       %10111000
                    fcb       %10111000
                    fcb       %10011000
                    fcb       %10001000
                    fcb       %11111111
* down arrow
                    fcb       $1B,$2B,$CE
                    fcb       2                   buffer #
                    fcb       5                   style 640x192x2
                    fdb       8                   xsize
                    fdb       8                   ysize
                    fdb       8                   bytes
                    fcb       %10000001
                    fcb       %10000001
                    fcb       %10000001
                    fcb       %11111111
                    fcb       %10111101
                    fcb       %10011001
                    fcb       %10000001
                    fcb       %10000001
* up arrow
                    fcb       $1B,$2B,$CE
                    fcb       1                   buffer #
                    fcb       5                   style 640x192x2
                    fdb       8                   xsize
                    fdb       8                   ysize
                    fdb       8                   bytes
                    fcb       %10000001
                    fcb       %10000001
                    fcb       %10011001
                    fcb       %10111101
                    fcb       %11111111
                    fcb       %10000001
                    fcb       %10000001
                    fcb       %10000001
* vertical box
                    fcb       $1B,$2B,$CE
                    fcb       5                   buffer #
                    fcb       5                   style 640x192x2
                    fdb       7                   xsize
                    fdb       7                   ysize
                    fdb       7                   bytes
                    fcb       %00000011
                    fcb       %00000011
                    fcb       %00000011
                    fcb       %00000011
                    fcb       %00000011
                    fcb       %00000011
                    fcb       %00000011
* horizontal box
                    fcb       $1B,$2B,$CE
                    fcb       6                   buffer #
                    fcb       5                   style 640x192x2
                    fdb       8                   xsize
                    fdb       6                   ysize
                    fdb       6                   bytes
                    fcb       %00000001
                    fcb       %00000001
                    fcb       %00000001
                    fcb       %00000001
                    fcb       %00000001
                    fcb       %11111111

