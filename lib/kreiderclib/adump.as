* Disassembly by Os9disasm of adump.r

                    section   code

* class X standard named label equates

D.Tasks             equ       $0020

* class D external label equates

D0000               equ       $0000
D000d               equ       $000d
D0020               equ       $0020

_dump               pshs      u
                    leas      -5,s
                    ldd       9,s
                    pshs      d
                    leax      L0192,pcr
                    pshs      x
                    leax      _iob+26,y
                    pshs      x
                    lbsr      fprintf
                    leas      6,s
                    leax      L0197,pcr
                    pshs      x
                    leax      _iob+26,y
                    pshs      x
                    lbsr      fprintf
                    leas      4,s
                    clra
                    clrb
                    std       2,s
                    ldu       11,s
                    bra       L005a
L0032               stu       ,s
                    tfr       u,d
                    clra
                    andb      #$0f
                    pshs      d
                    leax      L019e,pcr
                    pshs      x
                    leax      _iob+26,y
                    pshs      x
                    lbsr      fprintf
                    leas      6,s
                    ldd       2,s
                    addd      #1
                    std       2,s
                    subd      #1
                    tfr       u,d
                    leau      1,u
L005a               ldd       2,s
                    cmpd      #$0010
                    blt       L0032
                    leax      L01a4,pcr
                    pshs      x
                    leax      _iob+26,y
                    pshs      x
                    lbsr      fprintf
                    leas      4,s
                    clra
                    clrb
                    std       2,s
                    ldu       11,s
                    bra       L00a3
L007b               stu       ,s
                    tfr       u,d
                    clra
                    andb      #$0f
                    pshs      d
                    leax      L01a6,pcr
                    pshs      x
                    leax      _iob+26,y
                    pshs      x
                    lbsr      fprintf
                    leas      6,s
                    ldd       2,s
                    addd      #1
                    std       2,s
                    subd      #1
                    tfr       u,d
                    leau      1,u
L00a3               ldd       2,s
                    cmpd      #$0010
                    blt       L007b
                    leax      _iob+26,y
                    pshs      x
                    ldd       #$000d
                    pshs      d
                    lbsr      putc
                    leas      4,s
                    leax      L01aa,pcr
                    pshs      x
                    leax      _iob+26,y
                    pshs      x
                    lbsr      fprintf
                    leas      4,s
                    lbra      L0178
L00cf               ldd       11,s
                    pshs      d
                    leax      L01f3,pcr
                    pshs      x
                    leax      _iob+26,y
                    pshs      x
                    lbsr      fprintf
                    leas      6,s
                    clra
                    clrb
                    std       2,s
                    ldu       11,s
                    bra       L0109
L00ec               ldb       ,u+
                    clra
                    pshs      d
                    leax      L01fa,pcr
                    pshs      x
                    leax      _iob+26,y
                    pshs      x
                    lbsr      fprintf
                    leas      6,s
                    ldd       2,s
                    addd      #1
                    std       2,s
L0109               ldd       2,s
                    cmpd      #$0010
                    blt       L00ec
                    leax      L0200,pcr
                    pshs      x
                    leax      _iob+26,y
                    pshs      x
                    lbsr      fprintf
                    leas      4,s
                    clra
                    clrb
                    std       2,s
                    ldu       11,s
                    bra       L0157
L012a               ldb       ,u+
                    clra
                    andb      #$7f
                    stb       4,s
                    cmpb      #$20
                    blt       L013a
                    ldb       4,s
                    sex
                    bra       L013d
L013a               ldd       #$002e
L013d               pshs      d
                    leax      L0202,pcr
                    pshs      x
                    leax      _iob+26,y
                    pshs      x
                    lbsr      fprintf
                    leas      6,s
                    ldd       2,s
                    addd      #1
                    std       2,s
L0157               ldd       2,s
                    cmpd      #$0010
                    blt       L012a
                    leax      _iob+26,y
                    pshs      x
                    ldd       #$000d
                    pshs      d
                    lbsr      putc
                    leas      4,s
                    stu       11,s
                    ldd       13,s
                    subd      #$0010
                    std       13,s
L0178               ldd       13,s
                    lbgt      L00cf
                    leax      _iob+26,y
                    pshs      x
                    ldd       #$000d
                    pshs      d
                    lbsr      putc
                    leas      4,s
                    leas      5,s
                    puls      u,pc
*L0192 bcs   L0207
* tst   D000d
* neg   D0020
*L0197 equ *-1
* bra   L01ba
* bra   L01bc
* bra   L019e
*L019e bra   L01c5
* leay  -8,s
* bra   L01a4
*L01a4 bra   L01a6
*L01a6 bcs   L01d9
* asl   D.Tasks
*L01aa equ *-1
* bra   L01cd
* bra   L01cf
* bra   L01de
* blt   L01d3
* blt   L01e2
* bra   L01e4
* blt   L01d9
* blt   L01e8
*L01ba equ *-1
* bra   L01ea
*L01bc equ *-1
* blt   L01df
* blt   L01ee
* bra   L01f0
* blt   L01e5
*L01c5 blt   L01f4
* bra   L01f6
* blt   L01eb
* blt   L01fa
*L01cd bra   L01fc
*L01cf blt   L01f1
* blt   L0200
*L01d3 bra   L0202
* blt   L01f7
* blt   L0206
*L01d9 bra   L0208
* blt   L01fd
* blt   L020c
*L01de equ *-1
*L01df bra   L0201
* blt   L0210
*L01e2 equ *-1
* blt   L0212
*L01e4 equ *-1
*L01e5 blt   L0214
* blt   L0216
*L01e8 equ *-1
* blt   L0218
L01ea               equ       *-1
*L01eb blt   L021a
* blt   L021c
*L01ee equ *-1
* blt   L021e
*L01f0 equ *-1
*L01f1 tst   D0000
*L01f3 bcs   L0225
*L01f4 equ *-1
* pshs  dp,x,y,u
*L01f6 equ *-1
*L01f7 abx
* bra   L01fa
*L01fa bcs   L022c
*L01fc leas  -8,s
*L01fd equ *-1
* bra   L0200
*L0200 bra   L0202
*L0201 equ *-1
*L0202 bcs   L0267
* fcb $00
*
                    endsect

