                    export    _closedir
                    export    _opendir
                    export    _readdir
                    export    _seekdir
                    export    _telldir
                    
* class D external label equates

D001d               equ       $001d
D001e               equ       $001e

                    section   bss

* Uninitialized data (class B)
B0000               rmb       4
B0004               rmb       30
* Initialized Data (class G)

                    endsect

                    section   code

_closedir           ldx       2,s
                    ldd       ,x
                    pshs      d,x
                    lbsr      _close
                    leas      2,s
                    lbsr      _free
                    puls      x,pc
                    
_opendir            pshs      u
                    ldd       #$0022
                    pshs      d
                    lbsr      _malloc
                    std       ,s
                    beq       L0037
                    ldx       #$0081
                    ldd       6,s
                    pshs      d,x
                    lbsr      _open
                    leas      4,s
                    std       [,s]
                    bge       L0037
                    ldd       ,s
                    lbsr      _free
                    clra
                    clrb
                    std       ,s
L0037               puls      d,u,pc

_readdir            pshs      u
                    ldu       4,s
                    leau      2,u
L003f               ldd       #$0020
                    pshs      d
                    ldd       -2,u
                    pshs      d,u
                    lbsr      _read
                    leas      6,s
                    std       -2,s
                    bgt       L0055
                    clra
                    clrb
                    puls      u,pc
L0055               ldb       ,u
                    beq       L003f
                    leax      B0004,y
                    pshs      x,u
                    lbsr      _strhcpy
                    leas      4,s
                    leax      B0000,y
                    clra
                    ldb       D001d,u
                    std       ,x
                    ldd       D001e,u
                    std       2,x
                    tfr       x,d
                    puls      u,pc
                    
_seekdir            clra
                    clrb
                    pshs      d
                    ldd       8,s
                    pshs      d
                    ldd       8,s
                    bra       L008b
                    
_telldir            ldd       #1
                    pshs      d
                    clrb
                    pshs      d
L008b               pshs      d
                    ldd       [8,s]
                    pshs      d
                    lbsr      _lseek
                    leas      8,s
                    rts

                    endsect

