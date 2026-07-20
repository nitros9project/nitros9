************************************************
**
* lead1 & lead2 should contain the hex ascii
* value of the leadin character(s) of multiple
* character control sequences such as those used
* on heath h-19 or swtpc ct-82 terminals.
* if multiple char. sequences are not required
* set leadin, lead1, & lead2 all to zero.
* if only one leadin char is required, set lead2 to zero.
*
leadin              equ       0                   number of leadin char in control sequence
lead1               equ       $00                 leadin char 1
lead2               equ       $00                 leadin char 2
maxprn              equ       $7e                 max printable char
**
clrscn              fcb       $0c,$00,$00
homeup              fcb       $01,$00,$00
upcur               fcb       $09,$00,$00
dncur               fcb       $0a,$00,$00
lfcur               fcb       $08,$00,$00
rtcur               fcb       $06,$00,$00
curson              fcb       $00,$00,$00
**rson fcb $00,$00,$00
