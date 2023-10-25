* Disassembly by Os9disasm of pwent.r

* class D external label equates

D0000               equ       $0000

* class X external label equates

X7377               equ       $7377
X7973               equ       $7973

                    section   bss

* Uninitialized data (class B)
B0000               rmb       133
B0085               rmb       16
* Initialized Data (class G)
G0000               fcb       $00
                    fcb       $00
_pwdelim            fcb       $61

                    endsect

                    section   code

getpwent            pshs      d,u
                    ldd       G0000,y
                    bne       L0020
                    ldd       #1
                    pshs      d
                    leax      L0229,pcr
                    pshs      x
                    lbsr      open
                    leas      4,s
                    std       G0000,y
                    lble      L0223
L0020               ldd       #$0084
                    pshs      d
                    leax      B0000,y
                    pshs      x
                    ldd       G0000,y
                    pshs      d
                    lbsr      readln
                    leas      6,s
                    std       -2,s
                    lble      L0223
                    leax      B0000,y
                    stx       ,s
                    bra       L0050
L0044               ldx       ,s
                    leax      1,x
                    stx       ,s
                    ldb       -1,x
                    stb       _pwdelim,y
L0050               ldb       [,s]
                    cmpb      #$0d
                    beq       L0066
                    ldb       _pwdelim,y
                    cmpb      #$2c
                    beq       L0066
                    ldb       _pwdelim,y
                    cmpb      #$3a
                    bne       L0044
L0066               ldb       [,s]
                    cmpb      #$0d
                    lbeq      L0223
                    leax      B0085,y
                    pshs      x
                    leax      B0000,y
                    pshs      x
                    bsr       L00c4
                    leas      4,s
                    lbra      L0225
setpwent            pshs      u
                    ldd       G0000,y
                    beq       L009e
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       G0000,y
                    pshs      d
                    lbsr      lseek
                    leas      8,s
L009e               puls      u,pc
endpwent            pshs      u
                    ldd       G0000,y
                    beq       L00b9
                    ldd       G0000,y
                    pshs      d
                    lbsr      close
                    leas      2,s
                    clra
                    clrb
                    std       G0000,y
L00b9               puls      u,pc
getpwdlm            pshs      u
                    ldb       _pwdelim,y
                    sex
                    puls      u,pc
L00c4               pshs      u
                    clra
                    clrb
                    ldx       6,s
                    std       8,x
                    ldd       4,s
                    std       [6,s]
                    ldb       _pwdelim,y
                    sex
                    pshs      d
                    ldd       6,s
                    pshs      d
                    lbsr      index
                    leas      4,s
                    std       4,s
                    tfr       d,x
                    clra
                    clrb
                    stb       ,x
                    ldd       4,s
                    addd      #1
                    std       4,s
                    ldx       6,s
                    std       2,x
                    ldb       _pwdelim,y
                    sex
                    pshs      d
                    ldd       6,s
                    pshs      d
                    lbsr      index
                    leas      4,s
                    std       4,s
                    tfr       d,x
                    clra
                    clrb
                    stb       ,x
                    ldd       4,s
                    addd      #1
                    std       4,s
                    ldx       6,s
                    std       4,x
                    ldb       _pwdelim,y
                    sex
                    pshs      d
                    ldd       6,s
                    pshs      d
                    lbsr      index
                    leas      4,s
                    std       4,s
                    tfr       d,x
                    clra
                    clrb
                    stb       ,x
                    ldd       4,s
                    addd      #1
                    std       4,s
                    ldx       6,s
                    std       6,x
                    ldb       _pwdelim,y
                    sex
                    pshs      d
                    ldd       6,s
                    pshs      d
                    lbsr      index
                    leas      4,s
                    std       4,s
                    tfr       d,x
                    clra
                    clrb
                    stb       ,x
                    ldb       _pwdelim,y
                    cmpb      #$3a
                    bne       L017d
                    ldd       4,s
                    addd      #1
                    std       4,s
                    ldx       6,s
                    std       8,x
                    ldb       _pwdelim,y
                    sex
                    pshs      d
                    ldd       6,s
                    pshs      d
                    lbsr      index
                    leas      4,s
                    std       4,s
                    tfr       d,x
                    clra
                    clrb
                    stb       ,x
L017d               ldd       4,s
                    addd      #1
                    std       4,s
                    ldx       6,s
                    std       10,x
                    ldb       _pwdelim,y
                    sex
                    pshs      d
                    ldd       6,s
                    pshs      d
                    lbsr      index
                    leas      4,s
                    std       4,s
                    tfr       d,x
                    clra
                    clrb
                    stb       ,x
                    ldd       4,s
                    addd      #1
                    std       4,s
                    ldx       6,s
                    std       12,x
                    ldb       _pwdelim,y
                    sex
                    pshs      d
                    ldd       6,s
                    pshs      d
                    lbsr      index
                    leas      4,s
                    std       4,s
                    tfr       d,x
                    clra
                    clrb
                    stb       ,x
                    ldd       4,s
                    addd      #1
                    std       4,s
                    ldx       6,s
                    std       14,x
                    ldd       #$000d
                    pshs      d
                    ldd       6,s
                    pshs      d
                    lbsr      index
                    leas      4,s
                    tfr       d,x
                    clra
                    clrb
                    stb       ,x
                    ldd       6,s
                    puls      u,pc
getpwuid            pshs      d,u
                    bra       L01fa
L01ea               ldx       ,s
                    ldd       4,x
                    pshs      d
                    lbsr      atoi
                    leas      2,s
                    cmpd      6,s
                    beq       L0218
L01fa               lbsr      getpwent
                    std       ,s
                    bne       L01ea
                    bra       L0223
getpwnam            pshs      d,u
                    bra       L021c
L0207               ldd       [,s]
                    pshs      d
                    ldd       8,s
                    pshs      d
                    lbsr      strucmp
                    leas      4,s
                    std       -2,s
                    bne       L021c
L0218               ldd       ,s
                    bra       L0225
L021c               lbsr      getpwent
                    std       ,s
                    bne       L0207
L0223               clra
                    clrb
L0225               leas      2,s
                    puls      u,pc
*L0229 ble   L028f
* lsr   15,y
* com   X7973
* ble   L02a2
* fcb $61
* com   X7377
* clr   -14,s
* fcb $64
* fcb $00

                    endsect

