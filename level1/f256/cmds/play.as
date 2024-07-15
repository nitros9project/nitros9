********************************************************************
* play - F256 PSG player
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/01/08  Boisy Gene Pitre
* Created.

                    section   __os9
type                equ       Prgrm
lang                equ       Objct
attr                equ       ReEnt
rev                 equ       $00
edition             equ       1
stack               equ       200
                    endsect

                    section   bss
filepath      rmb 1
filebuf             rmb       2
fmemupper           rmb       2
fmemsize            rmb       2
filesize            rmb       2
                    endsect

                    section   code
                    
* save initial parameters
__start
                    clra
                    clrb
                    os9       F$Mem
                    bcs       err
                    sty       fmemupper,u
                    std       fmemsize,u
                    
                    lda       #READ.
                    os9       I$Open
                    bcs       err
                    sta       filepath,u
                    ldb       #SS.Size
                    pshs      u
                    os9       I$GetStt
                    tfr       u,x
                    puls      u
                    bcs       err
                    stx       filesize,u
                    tfr       x,d
                    addd      fmemsize,u
                    os9       F$Mem
                    bcs       err
                    sty       fmemupper,u
                    std       fmemsize,u          
                    ldd       fmemupper,u
                    subd      filesize,u
                    tfr       d,x
                    ldy       filesize,u
                    lda       filepath,u
                    os9       I$Read
                    bcs       err
                    
                    pshs x
                    leax IntSvc,pcr
                    os9 F$Icpt
                    puls x
n@
              lbsr      PSG_INIT
                                  bsr   PLAYSNG
                  lbsr PSG_INIT

bye                    clrb
err                 os9       F$Exit


PLAYSNG	
 lda	,x+		move past header
	leax	a,x

	ldb	,x+
                    pshs b
 lbsr PUTS
 puls b
 abx
     lbsr PUTCR


	ldb	,x+
                    pshs b
 lbsr PUTS
  puls b
 abx
     lbsr PUTCR
 
 pshs cc
 orcc #IntMasks

.1?
 pshs x
 ldx #$1
 bsr Delay
 puls x
	lda	,x+
	beq	.1?
	cmpa	#$ff
	beq	.3?
.2?	ldb	,x+
	lbsr PSG_WRITE
 pshs x
 ldx #$2000
 bsr Delay
 puls x
	deca
	bne	.2?
	bra	.1?
.3?	
 puls cc,pc

Delay 
l@ leax -1,x
 cmpx #$0000
 bne l@
 rts
 
IntSvc
  lbsr PSG_INIT
  os9 F$Exit
  rti 
                    endsect
