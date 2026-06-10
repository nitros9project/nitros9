* Wrapper for dw3dos.asm — defines symbols normally inside ifp1 block
* so they are available when lwasm skips that conditional.
IntMasks equ   $50
Carry    equ   1
PIA0Base equ   $FF00
PIA1Base equ   $FF20
DAT.Regs equ   $FFA0
E$NotRdy equ   246
Vi.PkSz  equ   0
V.SCF    equ   0
         use   /Users/boisy/Projects/coco-shelf/toolshed/hdbdos/dwdefs.d
         use   /Users/boisy/Projects/coco-shelf/toolshed/dwdos/dw3dos.asm
