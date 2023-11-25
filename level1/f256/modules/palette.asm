********************************************************************
* palette - F256 palette
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2023/09/24  Boisy G. Pitre
* Created.
*
               nam       palette
               ttl       F256 palette

               use       defsfile

tylg           set       Data
atrv           set       ReEnt+rev
rev            set       $01

               mod       eom,name,tylg,atrv,start,0

name           fcs       /palette/

start
               fcb       $00,$00,$00,$00
               fcb       $ff,$ff,$ff,$00
               fcb       $00,$00,$88,$00
               fcb       $ee,$ff,$aa,$00
               fcb       $cc,$4c,$cc,$00
               fcb       $55,$cc,$00,$00
               fcb       $aa,$00,$00,$00
               fcb       $77,$dd,$dd,$00
               fcb       $55,$88,$dd,$00
               fcb       $00,$44,$66,$00
               fcb       $77,$77,$ff,$00
               fcb       $33,$33,$33,$00
               fcb       $77,$77,$77,$00
               fcb       $66,$ff,$aa,$00
               fcb       $ff,$88,$00,$00
               fcb       $bb,$bb,$bb,$00


               emod
eom            equ       *
               end
