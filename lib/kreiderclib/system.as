                    export    _system
                    
                    section   code

* class D external label equates

D0000               equ       $0000

                    export    _system
                    
* class X external label equates

X6865               equ       $6865

_system             pshs      u
                    ldd       #$ff5a
*                    lbsr      _stkcheck
                    leas      -86,s
                    ldd       #$0051
                    ldu       90,s
                    leax      ,s
                    pshs      d
                    pshs      x,u
                    lbsr      _strncpy
                    leas      6,s
                    clr       80,s
                    leax      >L0066,pcr
                    pshs      d,x
                    lbsr      _strcat
                    leas      4,s
                    clra
                    clrb
                    pshs      d
                    incb
                    pshs      d
                    pshs      d
                    leax      6,s
                    pshs      x
                    pshs      x
                    lbsr      strlen
                    std       ,s
                    leax      >L0061,pcr
                    pshs      x
                    lbsr      _os9fork
                    leas      12,s
                    std       82,s
L004c               leax      84,s
                    pshs      x
                    lbsr      _wait
                    leas      2,s
                    cmpd      82,s
                    bne       L004c
                    leas      84,s
                    puls      d,u,pc
                    
L0061               fcc       /shell/
L0066               fcb       $7D,$00,$0

                    endsect

