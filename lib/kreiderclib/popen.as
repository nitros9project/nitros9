* Disassembly by Os9disasm of popen.r

* class D external label equates

D0000               equ       $0000
D000d               equ       $000d

                    section   bss

* Uninitialized data (class B)
B0000               rmb       32
* Initialized Data (class G)

                    endsect

                    section   code

popen               pshs      u
                    leas      -14,s
                    ldu       18,s
                    ldb       [20,s]
                    cmpb      #$77
                    bne       L0012
                    clra
                    clrb
                    bra       L0015
L0012               ldd       #1
L0015               std       6,s
                    ldd       #3
                    pshs      d
                    leax      L01fb,pcr
                    pshs      x
                    lbsr      open
                    leas      4,s
                    std       4,s
                    cmpd      #-1
                    lbeq      L019d
                    ldd       4,s
                    std       2,s
                    ldd       6,s
                    pshs      d
                    lbsr      dup
                    leas      2,s
                    std       ,s
                    cmpd      #-1
                    beq       L0070
                    ldd       6,s
                    pshs      d
                    lbsr      close
                    leas      2,s
                    ldd       4,s
                    pshs      d
                    lbsr      dup
                    leas      2,s
                    cmpd      #-1
                    bne       L0080
                    ldd       ,s
                    pshs      d
                    lbsr      dup
                    leas      2,s
                    ldd       ,s
                    pshs      d
                    lbsr      close
                    leas      2,s
L0070               ldd       4,s
                    pshs      d
                    lbsr      close
                    leas      2,s
                    lbra      L019d
                    bra       L0080
L007e               leau      1,u
L0080               ldb       ,u
                    cmpb      #$20
                    beq       L008a
                    ldb       ,u
                    bne       L007e
L008a               ldb       ,u
                    cmpb      #$20
                    bne       L0092
                    leau      1,u
L0092               pshs      u
                    lbsr      strlen
                    leas      2,s
                    std       8,s
                    addd      #2
                    pshs      d
                    lbsr      malloc
                    leas      2,s
                    std       12,s
                    pshs      u
                    ldd       14,s
                    pshs      d
                    lbsr      strcpy
                    leas      4,s
                    leax      L0201,pcr
                    pshs      x
                    ldd       14,s
                    pshs      d
                    lbsr      strcat
                    leas      4,s
                    ldd       2,s
                    lslb
                    rola
                    leax      B0000,y
                    leax      d,x
                    pshs      x
                    clra
                    clrb
                    pshs      d
                    ldd       #1
                    pshs      d
                    ldd       #1
                    pshs      d
                    ldd       20,s
                    pshs      d
                    ldd       18,s
                    addd      #1
                    pshs      d
                    ldd       30,s
                    pshs      d
                    lbsr      os9fork
                    leas      12,s
                    std       [,s++]
                    cmpd      #-1
                    bne       L012a
                    ldd       12,s
                    pshs      d
                    lbsr      free
                    leas      2,s
                    ldd       6,s
                    pshs      d
                    lbsr      close
                    leas      2,s
                    ldd       ,s
                    pshs      d
                    lbsr      dup
                    leas      2,s
                    ldd       ,s
                    pshs      d
                    lbsr      close
                    leas      2,s
                    ldd       4,s
                    pshs      d
                    lbsr      close
                    leas      2,s
                    lbra      L018f
L012a               ldd       12,s
                    pshs      d
                    lbsr      free
                    leas      2,s
                    ldd       6,s
                    pshs      d
                    lbsr      close
                    leas      2,s
                    ldd       ,s
                    pshs      d
                    lbsr      dup
                    leas      2,s
                    ldd       ,s
                    pshs      d
                    lbsr      close
                    leas      2,s
                    ldd       20,s
                    pshs      d
                    ldd       6,s
                    pshs      d
                    lbsr      fdopen
                    leas      4,s
                    std       10,s
                    bne       L01a1
                    ldd       4,s
                    pshs      d
                    lbsr      close
                    leas      2,s
L0169               clra
                    clrb
                    pshs      d
                    lbsr      wait
                    leas      2,s
                    std       8,s
                    pshs      d
                    ldd       4,s
                    lslb
                    rola
                    leax      B0000,y
                    leax      d,x
                    ldd       ,x
                    cmpd      ,s++
                    beq       L018f
                    ldd       8,s
                    cmpd      #-1
                    bne       L0169
L018f               ldd       2,s
                    lslb
                    rola
                    leax      B0000,y
                    leax      d,x
                    clra
                    clrb
                    std       ,x
L019d               clra
                    clrb
                    bra       L01a3
L01a1               ldd       10,s
L01a3               leas      14,s
                    puls      u,pc
pclose              pshs      d,x,u
                    ldx       8,s
                    ldd       8,x
                    std       2,s
                    ldd       8,s
                    pshs      d
                    lbsr      fclose
                    leas      2,s
L01b8               leax      ,s
                    pshs      x
                    lbsr      wait
                    leas      2,s
                    tfr       d,u
                    pshs      u
                    ldd       4,s
                    lslb
                    rola
                    leax      B0000,y
                    leax      d,x
                    ldd       ,x
                    cmpd      ,s++
                    beq       L01dc
                    cmpu      #-1
                    bne       L01b8
L01dc               ldd       2,s
                    lslb
                    rola
                    leax      B0000,y
                    leax      d,x
                    clra
                    clrb
                    std       ,x
                    cmpu      #-1
                    bne       L01f5
                    ldd       #-1
                    bra       L01f7
L01f5               ldd       ,s
L01f7               leas      4,s
                    puls      u,pc
*L01fb ble   L026d
* rol   -16,s
* fcb $65
* neg   D000d
*L0201 equ *-1
* fcb $00

                    endsect

