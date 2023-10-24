* Disassembly by Os9disasm of prof.r

* class D external label equates

D0000               equ       $0000
D0001               equ       $0001
D0020               equ       $0020

* class X external label equates

X2829               equ       $2829

                    section   bss

* Uninitialized data (class B)
B0000               rmb       504
* Initialized Data (class G)
G0000               fdb       B0000
G0002               fdb       B01f8

                    endsect

                    section   code

_prof               pshs      u
                    leau      B0000,y
                    bra       L0018
L0008               ldd       ,u
                    cmpd      4,s
                    bne       L0016
                    leax      4,u
                    lbsr      _linc
                    puls      u,pc
L0016               leau      8,u
L0018               cmpu      G0000,y
                    bcs       L0008
                    ldd       G0000,y
                    cmpd      G0002,y
                    bls       L004a
                    ldd       G0000,y
                    addd      #-8
                    tfr       d,u
                    ldd       2,u
                    beq       L003f
                    leax      >L00b7,pcr
                    tfr       x,d
                    bra       L0041
L003f               ldd       6,s
L0041               std       2,u
                    leax      4,u
                    lbsr      _linc
                    bra       L0071
L004a               ldd       G0000,y
                    addd      #8
                    std       G0000,y
                    subd      #8
                    tfr       d,u
                    ldd       6,s
                    std       2,u
                    ldd       4,s
                    std       ,u
                    leax      4,u
                    pshs      x
                    bsr       L006c
                    neg       D0000
                    neg       D0001
L006c               puls      x
                    lbsr      _lmove
L0071               puls      u,pc
_dumprof            pshs      u
                    lbsr      pflinit
                    leax      _iob+13,y
                    pshs      x
                    lbsr      fflush
                    leas      2,s
                    leau      B0000,y
                    bra       L00aa
L0089               leax      4,u
                    ldd       2,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       2,u
                    pshs      d
                    leax      >L00c0,pcr
                    pshs      x
                    leax      _iob+26,y
                    pshs      x
                    lbsr      fprintf
                    leas      10,s
                    leau      8,u
L00aa               cmpu      G0000,y
                    bcs       L0089
                    bra       L00b5
_trace              pshs      u
L00b5               puls      u,pc
*L00b7 swi
* swi
* swi
* swi
* swi
* swi
* swi
* swi
* neg   D0020
*L00c0 equ *-1
* bcs   L00fb
* com   X2829
* bra   L00ed
* inc   4,s
* tst   D0000

                    endsect

