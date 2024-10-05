********************************************************************
* font - F256 font
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2023/09/24  Boisy G. Pitre
* Created.
*
               nam       font
               ttl       F256 font

               use       defsfile

tylg           set       Data
atrv           set       ReEnt+rev
rev            set       $01

               mod       eom,name,tylg,atrv,start,0

name           fcs       /font/

start


L0000    fcb   $00,$00,$00,$00,$00,$00,$00,$00   ........
L0008    fcb   $7E,$81,$A5,$81,$BD,$99,$81,$7E   ~.%.=..~
L0010    fcb   $3C,$7E,$DB,$FF,$C3,$7E,$3C,$00   <~[.C~<.
L0018    fcb   $00,$EE,$FE,$FE,$7C,$38,$10,$00   .n..|8..
L0020    fcb   $10,$38,$7C,$FE,$7C,$38,$10,$00   .8|.|8..
L0028    fcb   $00,$3C,$18,$FF,$FF,$08,$18,$00   .<......
L0030    fcb   $10,$38,$7C,$FE,$FE,$10,$38,$00   .8|...8.
L0038    fcb   $00,$00,$18,$3C,$18,$00,$00,$00   ...<....
L0040    fcb   $FF,$FF,$E7,$C3,$E7,$FF,$FF,$FF   ..gCg...
L0048    fcb   $00,$3C,$42,$81,$81,$42,$3C,$00   .<B..B<.
L0050    fcb   $FF,$C3,$BD,$7E,$7E,$BD,$C3,$FF   .C=~~=C.
L0058    fcb   $01,$03,$07,$0F,$1F,$3F,$7F,$FF   .....?..
L0060    fcb   $FF,$FE,$FC,$F8,$F0,$E0,$C0,$80   ...xp`@.
L0068    fcb   $04,$06,$07,$04,$04,$FC,$F8,$00   ......x.
L0070    fcb   $0C,$0A,$0D,$0B,$F9,$F9,$1F,$1F   ....yy..
L0078    fcb   $00,$92,$7C,$44,$C6,$7C,$92,$00   ..|DF|..
L0080    fcb   $00,$00,$60,$78,$7E,$78,$60,$00   ..`x~x`.
L0088    fcb   $00,$00,$06,$1E,$7E,$1E,$06,$00   ....~...
L0090    fcb   $18,$7E,$18,$18,$18,$18,$7E,$18   .~....~.
L0098    fcb   $66,$66,$66,$66,$66,$00,$66,$00   fffff.f.
L00A0    fcb   $FF,$B6,$76,$36,$36,$36,$36,$00   .6v6666.
L00A8    fcb   $7E,$C1,$DC,$22,$22,$1F,$83,$7E   ~A\""..~
L00B0    fcb   $00,$00,$00,$7E,$7E,$00,$00,$00   ...~~...
L00B8    fcb   $18,$7E,$18,$18,$7E,$18,$00,$FF   .~..~...
L00C0    fcb   $18,$7E,$18,$18,$18,$18,$18,$00   .~......
L00C8    fcb   $18,$18,$18,$18,$18,$7E,$18,$00   .....~..
L00D0    fcb   $00,$04,$06,$FF,$06,$04,$00,$00   ........
L00D8    fcb   $00,$20,$60,$FF,$60,$20,$00,$00   . `.` ..
L00E0    fcb   $00,$00,$00,$C0,$C0,$C0,$FF,$00   ...@@@..
L00E8    fcb   $00,$24,$66,$FF,$66,$24,$00,$00   .$f.f$..
L00F0    fcb   $00,$00,$10,$38,$7C,$FE,$00,$00   ...8|...
L00F8    fcb   $00,$00,$00,$FE,$7C,$38,$10,$00   ....|8..
L0100    fcb   $00,$00,$00,$00,$00,$00,$00,$00   ........
L0108    fcb   $30,$30,$30,$30,$30,$00,$30,$00   00000.0.
L0110    fcb   $66,$66,$00,$00,$00,$00,$00,$00   ff......
L0118    fcb   $6C,$6C,$FE,$6C,$FE,$6C,$6C,$00   ll.l.ll.
L0120    fcb   $10,$7C,$D2,$7C,$86,$7C,$10,$00   .|R|.|..
L0128    fcb   $F0,$96,$FC,$18,$3E,$72,$DE,$00   p...>r^.
L0130    fcb   $30,$48,$30,$78,$CE,$CC,$78,$00   0H0xNLx.
L0138    fcb   $0C,$0C,$18,$00,$00,$00,$00,$00   ........
L0140    fcb   $10,$60,$C0,$C0,$C0,$60,$10,$00   .`@@@`..
L0148    fcb   $10,$0C,$06,$06,$06,$0C,$10,$00   ........
L0150    fcb   $00,$54,$38,$FE,$38,$54,$00,$00   .T8.8T..
L0158    fcb   $00,$18,$18,$7E,$18,$18,$00,$00   ...~....
L0160    fcb   $00,$00,$00,$00,$00,$00,$18,$70   .......p
L0168    fcb   $00,$00,$00,$7E,$00,$00,$00,$00   ...~....
L0170    fcb   $00,$00,$00,$00,$00,$00,$18,$00   ........
L0178    fcb   $02,$06,$0C,$18,$30,$60,$C0,$00   ....0`@.
L0180    fcb   $7C,$CE,$DE,$F6,$E6,$E6,$7C,$00   |N^vff|.
L0188    fcb   $18,$38,$78,$18,$18,$18,$3C,$00   .8x...<.
L0190    fcb   $7C,$C6,$06,$0C,$30,$60,$FE,$00   |F..0`..
L0198    fcb   $7C,$C6,$06,$3C,$06,$C6,$7C,$00   |F.<.F|.
L01A0    fcb   $0E,$1E,$36,$66,$FE,$06,$06,$00   ..6f....
L01A8    fcb   $FE,$C0,$C0,$FC,$06,$06,$FC,$00   .@@.....
L01B0    fcb   $7C,$C6,$C0,$FC,$C6,$C6,$7C,$00   |F@.FF|.
L01B8    fcb   $FE,$06,$0C,$18,$30,$60,$60,$00   ....0``.
L01C0    fcb   $7C,$C6,$C6,$7C,$C6,$C6,$7C,$00   |FF|FF|.
L01C8    fcb   $7C,$C6,$C6,$7E,$06,$C6,$7C,$00   |FF~.F|.
L01D0    fcb   $00,$30,$00,$00,$00,$30,$00,$00   .0...0..
L01D8    fcb   $00,$30,$00,$00,$00,$30,$20,$00   .0...0 .
L01E0    fcb   $00,$1C,$30,$60,$30,$1C,$00,$00   ..0`0...
L01E8    fcb   $00,$00,$7E,$00,$7E,$00,$00,$00   ..~.~...
L01F0    fcb   $00,$70,$18,$0C,$18,$70,$00,$00   .p...p..
L01F8    fcb   $7C,$C6,$0C,$18,$30,$00,$30,$00   |F..0.0.
L0200    fcb   $7C,$82,$9A,$AA,$AA,$9E,$7C,$00   |..**.|.
L0208    fcb   $7C,$C6,$C6,$FE,$C6,$C6,$C6,$00   |FF.FFF.
L0210    fcb   $FC,$66,$66,$7C,$66,$66,$FC,$00   .ff|ff..
L0218    fcb   $7C,$C6,$C0,$C0,$C0,$C6,$7C,$00   |F@@@F|.
L0220    fcb   $FC,$66,$66,$66,$66,$66,$FC,$00   .fffff..
L0228    fcb   $FE,$62,$68,$78,$68,$62,$FE,$00   .bhxhb..
L0230    fcb   $FE,$62,$68,$78,$68,$60,$F0,$00   .bhxh`p.
L0238    fcb   $7C,$C6,$C6,$C0,$DE,$C6,$7C,$00   |FF@^F|.
L0240    fcb   $C6,$C6,$C6,$FE,$C6,$C6,$C6,$00   FFF.FFF.
L0248    fcb   $3C,$18,$18,$18,$18,$18,$3C,$00   <.....<.
L0250    fcb   $1E,$0C,$0C,$0C,$0C,$CC,$78,$00   .....Lx.
L0258    fcb   $C6,$CC,$D8,$F0,$D8,$CC,$C6,$00   FLXpXLF.
L0260    fcb   $F0,$60,$60,$60,$60,$62,$FE,$00   p````b..
L0268    fcb   $C6,$EE,$FE,$D6,$C6,$C6,$C6,$00   Fn.VFFF.
L0270    fcb   $C6,$E6,$F6,$DE,$CE,$C6,$C6,$00   Ffv^NFF.
L0278    fcb   $7C,$C6,$C6,$C6,$C6,$C6,$7C,$00   |FFFFF|.
L0280    fcb   $FC,$66,$66,$7C,$60,$60,$F0,$00   .ff|``p.
L0288    fcb   $7C,$C6,$C6,$C6,$C6,$C6,$7C,$0C   |FFFFF|.
L0290    fcb   $FC,$66,$66,$7C,$66,$66,$E6,$00   .ff|fff.
L0298    fcb   $7C,$C6,$C0,$7C,$06,$C6,$7C,$00   |F@|.F|.
L02A0    fcb   $7E,$5A,$18,$18,$18,$18,$3C,$00   ~Z....<.
L02A8    fcb   $C6,$C6,$C6,$C6,$C6,$C6,$7C,$00   FFFFFF|.
L02B0    fcb   $C6,$C6,$C6,$C6,$C6,$6C,$38,$00   FFFFFl8.
L02B8    fcb   $C6,$C6,$C6,$C6,$D6,$EE,$C6,$00   FFFFVnF.
L02C0    fcb   $C6,$6C,$38,$38,$38,$6C,$C6,$00   Fl888lF.
L02C8    fcb   $66,$66,$66,$3C,$18,$18,$3C,$00   fff<..<.
L02D0    fcb   $FE,$C6,$0C,$18,$30,$66,$FE,$00   .F..0f..
L02D8    fcb   $1C,$18,$18,$18,$18,$18,$1C,$00   ........
L02E0    fcb   $C0,$60,$30,$18,$0C,$06,$02,$00   @`0.....
L02E8    fcb   $70,$30,$30,$30,$30,$30,$70,$00   p00000p.
L02F0    fcb   $00,$00,$10,$38,$6C,$C6,$00,$00   ...8lF..
L02F8    fcb   $00,$00,$00,$00,$00,$00,$00,$FF   ........
L0300    fcb   $30,$30,$18,$00,$00,$00,$00,$00   00......
L0308    fcb   $00,$00,$7C,$06,$7E,$C6,$7E,$00   ..|.~F~.
L0310    fcb   $C0,$C0,$FC,$C6,$C6,$C6,$FC,$00   @@.FFF..
L0318    fcb   $00,$00,$7C,$C6,$C0,$C6,$7C,$00   ..|F@F|.
L0320    fcb   $06,$06,$7E,$C6,$C6,$C6,$7E,$00   ..~FFF~.
L0328    fcb   $00,$00,$7C,$C6,$FE,$C0,$7C,$00   ..|F.@|.
L0330    fcb   $3C,$66,$60,$F0,$60,$60,$60,$00   <f`p```.
L0338    fcb   $00,$00,$7E,$C6,$C6,$7E,$06,$7C   ..~FF~.|
L0340    fcb   $C0,$C0,$FC,$C6,$C6,$C6,$C6,$00   @@.FFFF.
L0348    fcb   $18,$00,$38,$18,$18,$18,$3C,$00   ..8...<.
L0350    fcb   $00,$0C,$00,$1C,$0C,$0C,$CC,$78   ......Lx
L0358    fcb   $C0,$C0,$C6,$D8,$F0,$D8,$C6,$00   @@FXpXF.
L0360    fcb   $38,$18,$18,$18,$18,$18,$3C,$00   8.....<.
L0368    fcb   $00,$00,$EE,$FE,$D6,$C6,$C6,$00   ..n.VFF.
L0370    fcb   $00,$00,$FC,$C6,$C6,$C6,$C6,$00   ...FFFF.
L0378    fcb   $00,$00,$7C,$C6,$C6,$C6,$7C,$00   ..|FFF|.
L0380    fcb   $00,$00,$FC,$C6,$C6,$FC,$C0,$C0   ...FF.@@
L0388    fcb   $00,$00,$7E,$C6,$C6,$7E,$06,$06   ..~FF~..
L0390    fcb   $00,$00,$DE,$76,$60,$60,$60,$00   ..^v```.
L0398    fcb   $00,$00,$7C,$C0,$7C,$06,$7C,$00   ..|@|.|.
L03A0    fcb   $18,$18,$7E,$18,$18,$18,$1E,$00   ..~.....
L03A8    fcb   $00,$00,$C6,$C6,$C6,$C6,$7E,$00   ..FFFF~.
L03B0    fcb   $00,$00,$C6,$C6,$C6,$6C,$38,$00   ..FFFl8.
L03B8    fcb   $00,$00,$C6,$C6,$D6,$FE,$C6,$00   ..FFV.F.
L03C0    fcb   $00,$00,$C6,$6C,$38,$6C,$C6,$00   ..Fl8lF.
L03C8    fcb   $00,$00,$C6,$C6,$C6,$7E,$06,$7C   ..FFF~.|
L03D0    fcb   $00,$00,$FE,$0C,$18,$60,$FE,$00   .....`..
L03D8    fcb   $0E,$18,$18,$70,$18,$18,$0E,$00   ...p....
L03E0    fcb   $18,$18,$18,$00,$18,$18,$18,$00   ........
L03E8    fcb   $E0,$30,$30,$1C,$30,$30,$E0,$00   `00.00`.
L03F0    fcb   $00,$00,$70,$9A,$0E,$00,$00,$00   ..p.....
L03F8    fcb   $00,$00,$18,$3C,$66,$FF,$00,$00   ...<f...
L0400    fcb   $7C,$C6,$C0,$C0,$C6,$7C,$18,$70   |F@@F|.p
L0408    fcb   $66,$00,$C6,$C6,$C6,$C6,$7E,$00   f.FFFF~.
L0410    fcb   $0E,$18,$7C,$C6,$FE,$C0,$7C,$00   ..|F.@|.
L0418    fcb   $18,$24,$7C,$06,$7E,$C6,$7E,$00   .$|.~F~.
L0420    fcb   $66,$00,$7C,$06,$7E,$C6,$7E,$00   f.|.~F~.
L0428    fcb   $38,$0C,$7C,$06,$7E,$C6,$7E,$00   8.|.~F~.
L0430    fcb   $18,$00,$7C,$06,$7E,$C6,$7E,$00   ..|.~F~.
L0438    fcb   $00,$00,$7C,$C0,$C0,$7C,$18,$70   ..|@@|.p
L0440    fcb   $18,$24,$7C,$C6,$FE,$C0,$7C,$00   .$|F.@|.
L0448    fcb   $66,$00,$7C,$C6,$FE,$C0,$7C,$00   f.|F.@|.
L0450    fcb   $70,$18,$7C,$C6,$FE,$C0,$7C,$00   p.|F.@|.
L0458    fcb   $66,$00,$38,$18,$18,$18,$3C,$00   f.8...<.
L0460    fcb   $18,$24,$38,$18,$18,$18,$3C,$00   .$8...<.
L0468    fcb   $38,$0C,$38,$18,$18,$18,$3C,$00   8.8...<.
L0470    fcb   $66,$00,$7C,$C6,$FE,$C6,$C6,$00   f.|F.FF.
L0478    fcb   $18,$00,$7C,$C6,$FE,$C6,$C6,$00   ..|F.FF.
L0480    fcb   $0E,$18,$FE,$60,$78,$60,$FE,$00   ...`x`..
L0488    fcb   $00,$00,$7C,$1A,$7E,$D8,$7E,$00   ..|.~X~.
L0490    fcb   $7E,$D8,$D8,$DE,$F8,$D8,$DE,$00   ~XX^xX^.
L0498    fcb   $18,$24,$7C,$C6,$C6,$C6,$7C,$00   .$|FFF|.
L04A0    fcb   $66,$00,$7C,$C6,$C6,$C6,$7C,$00   f.|FFF|.
L04A8    fcb   $38,$0C,$7C,$C6,$C6,$C6,$7C,$00   8.|FFF|.
L04B0    fcb   $18,$24,$C6,$C6,$C6,$C6,$7E,$00   .$FFFF~.
L04B8    fcb   $38,$0C,$C6,$C6,$C6,$C6,$7E,$00   8.FFFF~.
L04C0    fcb   $66,$00,$C6,$C6,$C6,$7E,$06,$7C   f.FFF~.|
L04C8    fcb   $66,$7C,$C6,$C6,$C6,$C6,$7C,$00   f|FFFF|.
L04D0    fcb   $C6,$00,$C6,$C6,$C6,$C6,$7C,$00   F.FFFF|.
L04D8    fcb   $18,$7C,$C6,$C0,$C6,$7C,$18,$00   .|F@F|..
L04E0    fcb   $1E,$32,$30,$78,$30,$70,$FE,$00   .20x0p..
L04E8    fcb   $66,$3C,$18,$7E,$18,$3C,$18,$00   f<.~.<..
L04F0    fcb   $FC,$C6,$FC,$C0,$CC,$DE,$CC,$0E   .F.@L^L.
L04F8    fcb   $00,$1C,$32,$30,$FC,$30,$F0,$00   ..20.0p.
L0500    fcb   $0E,$18,$7C,$06,$7E,$C6,$7E,$00   ..|.~F~.
L0508    fcb   $1A,$30,$38,$18,$18,$18,$3C,$00   .08...<.
L0510    fcb   $0E,$18,$7C,$C6,$C6,$C6,$7C,$00   ..|FFF|.
L0518    fcb   $0E,$18,$C6,$C6,$C6,$C6,$7E,$00   ..FFFF~.
L0520    fcb   $66,$98,$FC,$C6,$C6,$C6,$C6,$00   f..FFFF.
L0528    fcb   $66,$98,$E6,$F6,$DE,$CE,$C6,$00   f.fv^NF.
L0530    fcb   $7C,$06,$7E,$C6,$7E,$00,$FE,$00   |.~F~...
L0538    fcb   $7C,$C6,$C6,$C6,$7C,$00,$FE,$00   |FFF|...
L0540    fcb   $18,$00,$18,$30,$60,$C6,$7C,$00   ...0`F|.
L0548    fcb   $00,$00,$FE,$C0,$C0,$C0,$C0,$00   ...@@@@.
L0550    fcb   $00,$00,$FE,$06,$06,$06,$06,$00   ........
L0558    fcb   $C0,$C0,$C0,$DE,$06,$0C,$1E,$00   @@@^....
L0560    fcb   $C0,$C0,$C0,$CC,$1C,$3E,$0C,$00   @@@L.>..
L0568    fcb   $30,$00,$30,$30,$30,$30,$30,$00   0.00000.
L0570    fcb   $00,$36,$6C,$D8,$6C,$36,$00,$00   .6lXl6..
L0578    fcb   $00,$D8,$6C,$36,$6C,$D8,$00,$00   .Xl6lX..
L0580    fcb   $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA   ********
L0588    fcb   $AA,$55,$AA,$55,$AA,$55,$AA,$55   *U*U*U*U
L0590    fcb   $44,$22,$44,$22,$44,$22,$44,$22   D"D"D"D"
L0598    fcb   $18,$18,$18,$18,$18,$18,$18,$18   ........
L05A0    fcb   $18,$18,$18,$F8,$18,$18,$18,$18   ...x....
L05A8    fcb   $18,$18,$18,$F8,$18,$F8,$18,$18   ...x.x..
L05B0    fcb   $36,$36,$36,$F6,$36,$36,$36,$36   666v6666
L05B8    fcb   $00,$00,$00,$FE,$36,$36,$36,$36   ....6666
L05C0    fcb   $00,$00,$00,$F8,$18,$F8,$18,$18   ...x.x..
L05C8    fcb   $36,$36,$36,$F6,$06,$F6,$36,$36   666v.v66
L05D0    fcb   $36,$36,$36,$36,$36,$36,$36,$36   66666666
L05D8    fcb   $00,$00,$00,$FE,$06,$F6,$36,$36   .....v66
L05E0    fcb   $36,$36,$36,$F6,$06,$FE,$00,$00   666v....
L05E8    fcb   $36,$36,$36,$FE,$00,$00,$00,$00   666.....
L05F0    fcb   $18,$18,$18,$F8,$18,$F8,$00,$00   ...x.x..
L05F8    fcb   $00,$00,$00,$F8,$18,$18,$18,$18   ...x....
L0600    fcb   $18,$18,$18,$1F,$00,$00,$00,$00   ........
L0608    fcb   $18,$18,$18,$FF,$00,$00,$00,$00   ........
L0610    fcb   $00,$00,$00,$FF,$18,$18,$18,$18   ........
L0618    fcb   $18,$18,$18,$1F,$18,$18,$18,$18   ........
L0620    fcb   $00,$00,$00,$FF,$00,$00,$00,$00   ........
L0628    fcb   $18,$18,$18,$FF,$18,$18,$18,$18   ........
L0630    fcb   $18,$18,$18,$1F,$18,$1F,$18,$18   ........
L0638    fcb   $36,$36,$36,$37,$36,$36,$36,$36   66676666
L0640    fcb   $36,$36,$36,$37,$30,$3F,$00,$00   66670?..
L0648    fcb   $00,$00,$00,$3F,$30,$37,$36,$36   ...?0766
L0650    fcb   $36,$36,$36,$F7,$00,$FF,$00,$00   666w....
L0658    fcb   $00,$00,$00,$FF,$00,$F7,$36,$36   .....w66
L0660    fcb   $36,$36,$36,$37,$30,$37,$36,$36   66670766
L0668    fcb   $00,$00,$00,$FF,$00,$FF,$00,$00   ........
L0670    fcb   $36,$36,$36,$F7,$00,$F7,$36,$36   666w.w66
L0678    fcb   $18,$18,$18,$FF,$00,$FF,$00,$00   ........
L0680    fcb   $36,$36,$36,$FF,$00,$00,$00,$00   666.....
L0688    fcb   $00,$00,$00,$FF,$00,$FF,$18,$18   ........
L0690    fcb   $00,$00,$00,$FF,$36,$36,$36,$36   ....6666
L0698    fcb   $36,$36,$36,$3F,$00,$00,$00,$00   666?....
L06A0    fcb   $18,$18,$18,$1F,$18,$1F,$00,$00   ........
L06A8    fcb   $00,$00,$00,$1F,$18,$1F,$18,$18   ........
L06B0    fcb   $00,$00,$00,$3F,$36,$36,$36,$36   ...?6666
L06B8    fcb   $36,$36,$36,$FF,$36,$36,$36,$36   666.6666
L06C0    fcb   $18,$18,$18,$FF,$18,$FF,$18,$18   ........
L06C8    fcb   $18,$18,$18,$F8,$00,$00,$00,$00   ...x....
L06D0    fcb   $00,$00,$00,$1F,$18,$18,$18,$18   ........
L06D8    fcb   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF   ........
L06E0    fcb   $00,$00,$00,$00,$FF,$FF,$FF,$FF   ........
L06E8    fcb   $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0   pppppppp
L06F0    fcb   $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F   ........
L06F8    fcb   $FF,$FF,$FF,$FF,$00,$00,$00,$00   ........
L0700    fcb   $00,$00,$77,$98,$98,$77,$00,$00   ..w..w..
L0708    fcb   $1C,$36,$66,$FC,$C6,$C6,$FC,$C0   .6f.FF.@
L0710    fcb   $FE,$62,$60,$60,$60,$60,$60,$00   .b`````.
L0718    fcb   $00,$00,$FF,$66,$66,$66,$66,$00   ...ffff.
L0720    fcb   $FE,$62,$30,$18,$30,$62,$FE,$00   .b0.0b..
L0728    fcb   $00,$00,$3F,$66,$C6,$CC,$78,$00   ..?fFLx.
L0730    fcb   $00,$00,$33,$33,$33,$3E,$30,$F0   ..333>0p
L0738    fcb   $00,$00,$FF,$18,$18,$18,$18,$00   ........
L0740    fcb   $3C,$18,$3C,$66,$66,$3C,$18,$3C   <.<ff<.<
L0748    fcb   $00,$7C,$C6,$FE,$C6,$7C,$00,$00   .|F.F|..
L0750    fcb   $00,$7E,$C3,$C3,$C3,$66,$E7,$00   .~CCCfg.
L0758    fcb   $1E,$19,$3C,$66,$C6,$CC,$78,$00   ..<fFLx.
L0760    fcb   $00,$00,$66,$99,$99,$66,$00,$00   ..f..f..
L0768    fcb   $00,$03,$7C,$CE,$E6,$7C,$C0,$00   ..|Nf|@.
L0770    fcb   $00,$3E,$C0,$FE,$C0,$3E,$00,$00   .>@.@>..
L0778    fcb   $00,$7E,$C3,$C3,$C3,$C3,$00,$00   .~CCCC..
L0780    fcb   $00,$FE,$00,$FE,$00,$FE,$00,$00   ........
L0788    fcb   $18,$18,$7E,$18,$18,$7E,$00,$00   ..~..~..
L0790    fcb   $70,$18,$0C,$18,$70,$00,$FE,$00   p...p...
L0798    fcb   $1C,$30,$60,$30,$1C,$00,$FE,$00   .0`0....
L07A0    fcb   $00,$0E,$1B,$18,$18,$18,$18,$18   ........
L07A8    fcb   $18,$18,$18,$18,$18,$D8,$70,$00   .....Xp.
L07B0    fcb   $00,$18,$00,$7E,$00,$18,$00,$00   ...~....
L07B8    fcb   $00,$76,$DC,$00,$76,$DC,$00,$00   .v\.v\..
L07C0    fcb   $3C,$66,$3C,$00,$00,$00,$00,$00   <f<.....
L07C8    fcb   $00,$18,$3C,$18,$00,$00,$00,$00   ..<.....
L07D0    fcb   $00,$00,$00,$00,$18,$00,$00,$00   ........
L07D8    fcb   $0F,$0C,$0C,$0C,$EC,$6C,$38,$00   ....ll8.
L07E0    fcb   $D8,$EC,$CC,$CC,$00,$00,$00,$00   XlLL....
L07E8    fcb   $F0,$30,$C0,$F0,$00,$00,$00,$00   p0@p....
L07F0    fcb   $00,$00,$00,$3C,$3C,$3C,$3C,$00   ...<<<<.
L07F8    fcb   $00,$00,$00,$00,$00,$00,$00,$00   ........

               emod
eom            equ       *
               end
