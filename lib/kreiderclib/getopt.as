* Disassembly by Os9disasm of getopt.r

* class D external label equates

D0000               equ       $0000
D003a               equ       $003a

* class X external label equates

X2061               equ       $2061
X7469               equ       $7469

                    section   bss

* Uninitialized data (class B)
optopt              rmb       2
optarg              rmb       2
* Initialized Data (class G)
opterr              fcb       $00
                    fcb       $01
optind              fcb       $00
                    fcb       $01
G0004               fdb       L0156

                    endsect

                    section   code

getopt              pshs      u
                    ldb       [G0004,y]
                    bne       L004f
                    ldd       optind,y
                    cmpd      4,s
                    bge       L004a
                    ldd       optind,y
                    lslb
                    rola
                    ldx       6,s
                    leax      d,x
                    ldd       ,x
                    std       G0004,y
                    tfr       d,x
                    ldb       ,x
                    cmpb      #$2d
                    bne       L004a
                    ldx       G0004,y
                    leax      1,x
                    stx       G0004,y
                    ldb       ,x
                    beq       L004a
                    ldb       [G0004,y]
                    cmpb      #$2d
                    bne       L004f
                    ldd       optind,y
                    addd      #1
                    std       optind,y
L004a               ldd       #-1
                    puls      u,pc
L004f               ldx       G0004,y
                    leax      1,x
                    stx       G0004,y
                    ldb       -1,x
                    sex
                    std       optopt,y
                    cmpd      #$003a
                    beq       L007b
                    ldd       optopt,y
                    pshs      d
                    ldd       10,s
                    pshs      d
                    lbsr      strchr
                    leas      4,s
                    tfr       d,u
                    stu       -2,s
                    bne       L00a8
L007b               ldb       [G0004,y]
                    bne       L008c
                    ldd       optind,y
                    addd      #1
                    std       optind,y
L008c               leax      _iob+26,y
                    pshs      x
                    ldd       [8,s]
                    pshs      d
                    lbsr      fputs
                    leas      4,s
                    leax      _iob+26,y
                    pshs      x
                    leax      L0157,pcr
                    bra       L0100
L00a8               leau      1,u
                    ldb       ,u
                    cmpb      #$3a
                    beq       L00c1
                    clra
                    clrb
                    std       optarg,y
                    ldb       [G0004,y]
                    lbne      L0150
                    lbra      L0145
L00c1               ldb       [G0004,y]
                    beq       L00ce
                    ldd       G0004,y
                    lbra      L0139
L00ce               ldd       optind,y
                    addd      #1
                    std       optind,y
                    cmpd      4,s
                    blt       L012d
                    leax      L016c,pcr
                    stx       G0004,y
                    leax      _iob+26,y
                    pshs      x
                    ldd       [8,s]
                    pshs      d
                    lbsr      fputs
                    leas      4,s
                    leax      _iob+26,y
                    pshs      x
                    leax      >L016d,pcr
L0100               pshs      x
                    lbsr      fputs
                    leas      4,s
                    leax      _iob+26,y
                    pshs      x
                    ldd       optopt,y
                    pshs      d
                    lbsr      putc
                    leas      4,s
                    leax      _iob+26,y
                    pshs      x
                    ldd       #$000d
                    pshs      d
                    lbsr      putc
                    leas      4,s
                    ldd       #$003f
                    puls      u,pc
L012d               ldd       optind,y
                    lslb
                    rola
                    ldx       6,s
                    leax      d,x
                    ldd       ,x
L0139               std       optarg,y
                    leax      >L018f,pcr
                    stx       G0004,y
L0145               ldd       optind,y
                    addd      #1
                    std       optind,y
L0150               ldd       optopt,y
                    puls      u,pc
* neg   D003a
*L0157 equ *-1
* bra   L01c3
* inc   12,s
* fcb $65
* asr   1,s
* fcb $6c
* bra   L01d1
* neg   X7469
* clr   14,s
* bra   L0196
* blt   L018b
* neg   D0000
*L016c equ *-1
*L016d abx
* bra   L01df
* neg   X7469
* clr   14,s
* bra   L01e9
* fcb $65
* fcb $71
* fcb $75
* rol   -14,s
* fcb $65
* com   X2061
* fcb $6e
* bra   L01e4
* fcb $72
* asr   -11,s
* tst   5,s
* jmp   -12,s
* bra   L01b9
*L018b equ *-1
* blt   L01ae
* neg   D0000

                    endsect

