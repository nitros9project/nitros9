********************************************************************
* sub6 - Sub6 Sub Battle Simulator Utility Routines
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   0      2003/04/10  Paul W. Zibaila
* Disassembly of original distribution.
*

                    nam       sub6
                    ttl       Sub6 Sub Battle Simulator Utility Routines

                    ifp1
                    use       defsfile
                    endc

* I/O path definitions
StdIn               equ       0
StdOut              equ       1
StdErr              equ       2


* class X external label equates
X02A4               equ       $02A4
X02A5               equ       $02A5
X1D3F               equ       $1D3F
X1D40               equ       $1D40
X1D41               equ       $1D41
X1D42               equ       $1D42
X1D43               equ       $1D43
X1D6B               equ       $1D6B
X1D88               equ       $1D88
X1D89               equ       $1D89
X1D8B               equ       $1D8B
X1D8D               equ       $1D8D
X1D8F               equ       $1D8F
X1D90               equ       $1D90
X1D91               equ       $1D91
X1D92               equ       $1D92
X1D93               equ       $1D93
X1D94               equ       $1D94
X1D95               equ       $1D95
X1D96               equ       $1D96
X1DA3               equ       $1DA3
X1DA5               equ       $1DA5
X1DA7               equ       $1DA7
X1DA8               equ       $1DA8
X1DA9               equ       $1DA9
X1DAB               equ       $1DAB
X1DAD               equ       $1DAD
X1DAF               equ       $1DAF
X1DB1               equ       $1DB1
X1DB3               equ       $1DB3
X1DB5               equ       $1DB5
X1DB7               equ       $1DB7
X1DB9               equ       $1DB9
X1DDA               equ       $1DDA
X1DDB               equ       $1DDB
X1DDC               equ       $1DDC
X1DDD               equ       $1DDD
X1DDE               equ       $1DDE
X1DEA               equ       $1DEA
X1DEB               equ       $1DEB
X1DED               equ       $1DED
X1DEF               equ       $1DEF
X1DF0               equ       $1DF0
X1DF1               equ       $1DF1
X1DF2               equ       $1DF2
X1DF3               equ       $1DF3
X1DF4               equ       $1DF4
X1DF5               equ       $1DF5
X1E02               equ       $1E02
X1E04               equ       $1E04
X1E05               equ       $1E05
X1E06               equ       $1E06
X1E08               equ       $1E08
X1E09               equ       $1E09
X1E0B               equ       $1E0B
X1E0C               equ       $1E0C
X4265               equ       $4265               Scratch area
X4266               equ       $4266
X4C75               equ       $4C75
X4CEF               equ       $4CEF
X4CF0               equ       $4CF0
X4CF1               equ       $4CF1
X4CF2               equ       $4CF2
X4CF3               equ       $4CF3
X4CF7               equ       $4CF7
X4CF9               equ       $4CF9
X4CFF               equ       $4CFF
X4D00               equ       $4D00
X4D01               equ       $4D01
X4D02               equ       $4D02



tylg                set       SbRtn+Objct
atrv                set       ReEnt+rev
rev                 set       $01
*edition  set  $01

                    mod       eom,name,tylg,atrv,start,size

* OS9 data area definitions

size                equ       .

name                fcs       "sub6"
*         fcb  edition       not included in original code

*X7228
start               pshs      a,b,x,y,u
loopsb1             ldd       X1DA5
                    cmpd      #$0138
                    bhs       Ex_sub1
                    ldb       #$20
                    lbsr      L0260
                    bra       loopsb1
Ex_sub1             puls      a,b,x,y,u,pc


*X723C
* nothing passed by caller
* uses a.b.u and s
* restores them on exit

L0025               pshs      a,b,x,y,u
                    clr       X1D6B               clear a flag

                    ldd       X1D8B               get a base address
                    addd      #$2B20              add an offset to it
                    std       X1DEB               from address

                    subd      #$02D0              subtract from base+offset
                    std       X1DED               stow that as to address

                    lda       #$09                set up loop counter
                    sta       X1DEA               store the loop counter

                    orcc      #IntMasks           mask interrupts          $50
                    sts       X1DDA               save the current stack pointer

                    ldu       X1DEB               set the from address
                    lds       X1DED               set the to address

L004B               leau      -6,u
                    pulu      d,x,y
                    leau      -12,u
                    pshs      d,x,y

                    pulu      d,x,y
                    leau      -12,u
                    pshs      d,x,y

                    pulu      d,x,y
                    leau      -12,u
                    pshs      d,x,y

                    pulu      d,x,y
                    leau      -12,u
                    pshs      d,x,y

                    pulu      d,x,y
                    leau      -12,u
                    pshs      d,x,y

                    pulu      d,x,y
                    leau      -12,u
                    pshs      d,x,y

                    pulu      d,x,y
                    leau      -12,u
                    pshs      d,x,y

                    pulu      d,x,y
                    leau      -12,u
                    pshs      d,x,y

                    pulu      d,x,y
                    leau      -12,u
                    pshs      d,x,y

                    pulu      d,x,y
                    leau      -9,u
                    pshs      d,x,y

                    pulu      a,x
                    pshs      a,x

                    leau      -20,u
                    leas      -17,s

                    dec       X1DEA               decrement the loop counter
                    bne       L004B               gone 9 times ? nope go again

                    lds       X1DDA               restore the stack pointer
                    andcc     #^IntMasks          un mask interrupts

                    ldd       #$0048              set some values
                    std       X1DA5

                    ldd       #$0082
                    std       X1DA7
                    puls      a,b,x,y,u,pc        and return


*X72C3
N00AC               pshs      a,b,x
                    lbsr      L0025

                    ldd       #$0048
                    std       X1DA5

                    ldd       #$0082
                    std       X1DA7

                    clra
                    ldx       4,s
L00C0               ldb       ,x+
                    beq       L00CA

                    lbsr      L0260

                    inca
                    bra       L00C0

L00CA               cmpa      #$1E
                    bge       L00D8

L00CE               ldb       #$20
                    lbsr      L0260
                    inca
                    cmpa      #$1E
                    blt       L00CE

L00D8               stx       4,s
                    puls      a,b,x,pc


*X72F3
N00DC               pshs      b,x
                    ldx       3,s
L00E0               ldb       ,x+
                    beq       L00E9
                    lbsr      L0260
                    bra       L00E0
L00E9               stx       3,s
                    puls      b,x,pc


*X7304
* argument passed in d converted to digit(s)
* calls L0260 for further handling
hex_to_digits
L00ED               pshs      a,b,x,y,u
                    clr       X4265               clear scratch for digit counter
                    cmpd      #$000A              compare to 10
                    blo       ZeroBase            add '0 to and call screen writer

                    leax      >DecimalTbl,pcr     load table base
Findplc             leax      2,x                 index onto 10K entry (why they didn't load a base and work from there??)
                    cmpd      ,x                  compare input to table value
                    blo       Findplc             less than table value move down one place

Digitcnt            inc       X4265               bump the digit counter
                    subd      ,x                  subtract x from d and store result in d
                    cmpd      ,x                  compare that value to current x
                    bhs       Digitcnt            if d is still greater or equal x go again

Placedone           std       X4266               store remaining value
                    ldb       X4265               get the digit counter value
                    addb      #'0                 and an ascii zero $30
                    lbsr      L0260               process it

                    clr       X4265               clear scratch for digit counter
                    leax      2,x                 index next lower value
                    ldd       #$0000              check if we are at the end of the table
                    cmpd      ,x
                    beq       Ex_h2d              if so exit routine
                    ldd       X4266               otherwise get the remaining value
                    cmpd      ,x                  compare to current x
                    blo       Placedone           less than pocess and move to next place down
                    bra       Digitcnt            greater or equal go get the count

ZeroBase            addb      #'0                 add an ascci zero $30
                    lbsr      L0260               process it
Ex_h2d              puls      a,b,x,y,u,pc


DecimalTbl
L0136               fdb       $0000               0
                    fdb       $2710               10000
                    fdb       $03E8               1000
                    fdb       $0064               100
                    fdb       $000A               10
                    fdb       $0001               1
                    fdb       $0000               0

*X735B
* Change Palette
* PRN,CTN are passed by caller in d
N0144               pshs      x,y
                    ldx       #$4265              scratch area
                    ldy       #$1B31              palette change code
                    sty       ,x                  save it at scratch
                    std       2,x                 save prn,ctn at second word
                    lda       #StdOut             set path to screen
                    ldy       #4                  write four bytes
                    os9       I$Write             write it
                    puls      x,y,pc


*X7374
L015D               pshs      a,b,x,y
                    lda       X1D92
                    ldb       #$50
                    mul
                    ldy       X1D8B
                    leay      d,y
                    ldd       X1D8F
                    lsra
                    rorb
                    lsra
                    rorb
                    leay      d,y
                    leax      ByteTbl7,pcr
                    ldb       X1D90
                    andb      #3
                    lda       ,y
                    anda      b,x
                    pshs      a,b
                    ldb       X1D88
                    leax      ByteTbl5,pcr
                    lda       b,x
                    eora      ,y
                    ldb       1,s
                    leax      ByteTbl6,pcr
                    anda      b,x
                    ora       ,s++
                    sta       ,y
                    puls      a,b,x,y,pc


*X73B3
L019C               pshs      a,b,x
                    ldd       X1D8F
                    cmpd      X1D93
                    bls       L01BC

                    ldx       X1D93
                    std       X1D93

                    stx       X1D8F
                    ldd       X1D91

                    ldx       X1D95
                    std       X1D95

                    stx       X1D91
L01BC               ldd       X1D93
                    subd      X1D8F
                    std       X1DB1

                    ldx       #1
                    ldd       X1D95
                    subd      X1D91
                    bcc       L01D7
                    leax      -2,x
                    coma
                    comb
                    addd      #1
L01D7               stx       X1DB5
                    std       X1DB3
                    cmpd      X1DB1
                    lbgt      L0223

                    ldd       X1DB1
                    lsra
                    rorb
                    std       X1DB7

L01ED               lbsr      L015D

                    ldx       X1D8F
                    cmpx      X1D93
                    lbeq      L025E

                    ldx       X1D8F
                    leax      1,x
                    stx       X1D8F

                    ldd       X1DB7
                    addd      X1DB3
                    std       X1DB7
                    cmpd      X1DB1
                    blt       L01ED
                    subd      X1DB1
                    std       X1DB7

                    ldd       X1D91
                    addd      X1DB5
                    std       X1D91

                    lbra      L01ED

L0223               lsra
                    rorb
                    std       X1DB7
L0228               lbsr      L015D
                    ldx       X1D91
                    cmpx      X1D95
                    lbeq      L025E
                    ldd       X1D91
                    addd      X1DB5
                    std       X1D91
                    ldd       X1DB7
                    addd      X1DB1
                    std       X1DB7
                    cmpd      X1DB3
                    blt       L0228
                    subd      X1DB3
                    std       X1DB7
                    ldx       X1D8F
                    leax      1,x
                    stx       X1D8F
                    lbra      L0228
L025E               puls      a,b,x,pc


*X7477
* receives data in b from caller
* validates value is between $20 and $5F ascii

L0260               pshs      a,x,y
                    subb      #C$SPAC-1           subtract 1 less than a space (unit sep) $1F
                    bls       L02AB               less than or equal time to go

                    cmpb      #'_+1               compare value now to underscore +1 $60
                    bge       L02AB               greater or equal were done it was >=$7F to start with

                    lda       #$08
                    mul                           mul b value times 8 and stow in d
                    ldx       #$4D3F              load a base address
                    leax      d,x                 using our calculated offset adjust x

                    lda       X1DA8               get the value
                    ldb       #$50
                    mul                           multiply it by 80 and stow in d
                    ldy       X1D8B               load a base
                    leay      d,y                 using our calc'ed offset adjust y

                    ldd       X1DA5               get the value
                    lsra                          divide d by 2
                    rorb
                    lsra                          and again by 2 for a total of 4
                    rorb
                    leay      d,y                 using our calc'ed offset adjust y

                    ldb       #$08
                    leau      ByteTbl8,pcr
L028D               lda       ,x+
                    pshs      d
                    lsra
                    lsra
                    lsra
                    lsra
                    ldb       a,u
                    stb       ,y+
                    lda       ,s
                    anda      #$0F
                    ldb       a,u
                    stb       ,y
                    leay      79,y
                    puls      a,b
                    decb
                    lbne      L028D

L02AB               ldx       X1DA5
                    leax      8,x
                    stx       X1DA5
                    puls      a,x,y,pc


*X74CC
N02B5               pshs      a,b
L02B7               ldb       ,x+
                    beq       L02C0
                    lbsr      L0260
                    bra       L02B7
L02C0               puls      a,b,pc


*X74D9
N02C2               pshs      y
                    clr       X1E0B
                    clr       X1E0C
                    ldd       1,y
                    subd      1,u
                    std       X1E06
                    lda       ,y
                    sbca      ,u
                    sta       X1E05
                    bcc       L02EE
                    inc       X1E0B
                    ldd       #0
                    subd      X1E06
                    std       X1E06
                    lda       #0
                    sbca      X1E05
                    sta       X1E05
L02EE               ldd       4,y
                    subd      4,u
                    std       X1E09
                    lda       3,y
                    sbca      3,u
                    sta       X1E08
                    bcc       L0312
                    inc       X1E0C
                    ldd       #0
                    subd      X1E09
                    std       X1E09
                    lda       #0
                    sbca      X1E08
                    sta       X1E08
L0312               ldy       #$1E05
                    ldu       #$1E08
                    lda       ,y
                    cmpa      ,u
                    bhi       L032A
                    bcs       L0328
                    ldd       1,y
                    cmpd      1,u
                    bhi       L032A
L0328               exg       u,y
L032A               lda       ,u
                    lsra
                    sta       X1DDA
                    ldd       1,u
                    rora
                    rorb
                    addd      1,y
                    tfr       d,u
                    lda       X1DDA
                    adca      ,y
                    puls      y,pc
                    ldy       #$1E05
                    ldu       #$1E08
                    tst       ,y
                    bne       L0352
                    tst       ,u
                    bne       L0352
                    leay      1,y
                    leau      1,u
L0352               ldd       ,y
                    cmpd      ,u
                    bcs       L0363
                    ldu       ,u
                    lbsr      L039A
                    negb
                    addb      #$5A
                    bra       L036A
L0363               ldd       ,u
                    ldu       ,y
                    lbsr      L039A
L036A               lslb
                    rola
                    lslb
                    rola
                    tst       X1E0C
                    bne       L0382
                    tst       X1E0B
                    beq       L037E
                    coma
                    comb
                    addd      #$0169
                    rts

*X7595
L037E               addd      #$0168
                    rts


*X7599
L0382               tst       X1E0B
                    bne       L038D
                    coma
                    comb
                    addd      #$0439
                    rts


*X75A4
L038D               addd      #$0438
                    cmpd      #$05A0
                    bcs       L0399
                    ldd       #0
L0399               rts



*X75B1
L039A               cmpu      #0
                    lbeq      L03E9
                    clr       X1DDC
                    std       X1DDA
                    stu       X1DDE
                    lda       #$18
                    sta       X1DEA
                    clra
                    clrb
L03B2               asl       X1DDC
                    rol       X1DDB
                    rol       X1DDA
                    rolb
                    rola
                    cmpd      X1DDE
                    bcs       L03C9
                    subd      X1DDE
                    inc       X1DDC
L03C9               dec       X1DEA
                    bne       L03B2
                    tfr       d,u
                    tst       X1DDA
                    lbne      L03E9
                    ldd       X1DDB
                    addd      #$0080
                    lblo      L03E9
                    tfr       d,u
                    ldd       #$4380
                    lbra      L04A2
L03E9               ldd       #0
                    rts


*X7604
N03ED               sta       X1DDA
                    ldb       X1DF1
                    mul
                    sta       X1DF4
                    clr       X1DF3
                    clr       X1DF2
                    lda       X1DDA
                    ldb       X1DF0
                    mul
                    addd      X1DF3
                    std       X1DF3
                    lda       X1DDA
                    ldb       X1DEF
                    mul
                    addd      X1DF2
                    std       X1DF2
                    lda       X1E04
                    eora      X1DF5
                    beq       L0430
                    ldd       #0
                    subd      X1DF3
                    std       X1DF3
                    lda       #0
                    sbca      X1DF2
                    sta       X1DF2
L0430               rts


*X7648
Set_0_1440
L0431               cmpd      #$059F              compare to 1439
                    bgt       L043E               > 1439 go subtract 1440
                    cmpd      #$0000              compare to zero
                    blt       L0443               < 0 go add 1440
                    rts


*X7655
L043E               subd      #$05A0              subtract 1440
                    bra       L0431               always go test again 1439

L0443               addd      #$05A0
                    bra       L0431


L0448               cmpd      #$02CF              compare to 719
                    bgt       L0455               greater than that subtract 1440
                    cmpd      #$FD30              compare to -720
                    blt       L045A               less than that go add 1440
                    rts


*X766C
L0455               subd      #$05A0
                    bra       L0448

L045A               addd      #$05A0
                    bra       L0448




L045F               rol       X1D3F
                    rol       X1D40
                    ror       X1D41
                    rol       X1D42
                    rol       X1D3F
                    ldd       X1D3F
                    addd      X1D41
                    adda      #5
                    std       X1D3F
                    rts



*X7691
N047A               pshs      a
                    pshs      b
                    lbsr      L045F
                    inca
                    anda      #$7F
                    puls      b
                    andb      #$7F
                    lbsr      L04E0
                    puls      a,pc


*X76A4
N048D               pshs      u
                    cmpd      #0
                    beq       L04A0
                    tfr       d,u
                    lbsr      L045F
                    incb
                    lbsr      L04A2
                    tfr       u,d
L04A0               puls      u,pc


* passed values in d and u by calling routine
*X76B9
L04A2               pshs      x                   save x as we will modify it
                    tfr       u,x                 move current u value into x
                    cmpx      #$0000              is the value zero ?
                    beq       ClrD_U              if so branch to clear d and u and return
*                            otherwise
                    std       X1DDA               save the value in d
                    stu       X1DDC               save the value in u

                    lda       #$10                set up loop counter of 16
                    sta       X1DEA               stow that in a scratch var
                    clra                          clear a,b and cc
                    clrb
*                          multiply the value x 2
L04B8               asl       X1DDB               shift lsb left b7 to cc
                    rol       X1DDA               pick up cc and shift msb left
*                          b7 of msb is now in cc
                    rolb                          pull cc into b0 and push b7 of lsb into cc
                    rola                          pull cc into b0 of msb and push b7 in cc
                    cmpd      X1DDC               compare the value now in d to the original u value
                    blo       L04CC               less then bump counter and go again
                    subd      X1DDC               otherwise subtract original u value from d
                    inc       X1DDB               and add one to the multiplied value
L04CC               dec       X1DEA               dec the loop counter
                    bne       L04B8               not done go again

                    tfr       d,u                 move d to u
                    ldd       X1DDA               load d
                    puls      x,pc                and return


*X76EF
ClrD_U
L04D8               ldd       #$0000              zero both d and u
                    ldu       #$0000
                    puls      x,pc                then return


*X76F7
L04E0               tstb
                    beq       L04FD
                    stb       X1DDB
                    ldb       #8
                    stb       X1DEA
                    clrb
L04EC               asla
                    rolb
                    cmpb      X1DDB
                    bcs       L04F7
                    subb      X1DDB
                    inca
L04F7               dec       X1DEA
                    bne       L04EC
                    rts


*X7714
L04FD               ldd       #0
                    rts



*X7718
L0501               subd      #$0168
                    bpl       L0509
                    addd      #$05A0
L0509               clr       X1E04
                    cmpd      #$02D0
                    bcs       L0518
                    inc       X1E04
                    subd      #$02D0
L0518               cmpd      #$0168
                    bls       L0527
                    std       X1DDA
                    ldd       #$02D0
                    subd      X1DDA
L0527               pshs      x
                    ldx       #$0126
                    lda       d,x
                    puls      x,pc


*X7747
N0530               pshs      a,b,x,y,u
                    sts       X1DDA

                    ldd       #$4252
                    std       X1DEB

                    ldd       X1D8D
                    addd      #$243E
                    std       X1DED

                    lda       #$73
                    sta       X1DEA

                    lda       X1D43
                    cmpa      #2
                    bhi       L0570

                    ldd       X1DB9
                    beq       L0570

                    ldd       X1DEB
                    subd      #$0280
                    std       X1DEB

                    ldd       X1DED
                    subd      #$0280
                    std       X1DED

                    lda       X1DEA
                    suba      #8
                    sta       X1DEA

L0570               orcc      #$50
                    ldu       X1DEB
                    lds       X1DED
L0579               leau      -6,u
                    pulu      d,x,y
                    leau      -12,u
                    pshs      d,x,y
                    pulu      d,x,y
                    leau      -12,u
                    pshs      d,x,y
                    pulu      d,x,y
                    leau      -12,u
                    pshs      d,x,y
                    pulu      d,x,y
                    leau      -12,u
                    pshs      d,x,y
                    pulu      d,x,y
                    leau      -12,u
                    pshs      d,x,y
                    pulu      d,x,y
                    leau      -12,u
                    pshs      d,x,y
                    pulu      d,x,y
                    leau      -12,u
                    pshs      d,x,y
                    pulu      d,x,y
                    leau      -12,u
                    pshs      d,x,y
                    pulu      d,x,y
                    leau      -12,u
                    pshs      d,x,y
                    pulu      d,x,y
                    leau      -7,u
                    pshs      d,x,y
                    pulu      a
                    pshs      a
                    leas      -19,s
                    leau      -20,u

                    dec       X1DEA
                    bne       L0579
                    lds       X1DDA

                    andcc     #$AF
                    puls      a,b,x,y,u,pc


*X77E3
N05CC               pshs      a,b,x,y,u
                    sta       X1DDC
                    sta       X1DDD
                    negb
                    addb      #$74
                    stb       X1DEA
                    sts       X1DDA
                    lda       #$50
                    mul
                    addd      #$1E25
                    orcc      #$50
                    tfr       d,s
                    ldd       X1DDC
                    ldx       X1DDC
                    ldu       X1DDC
                    ldy       X1DDC

L05F7               leas      -19,s
                    pshs      d,x,y,u
                    pshs      d,x,y,u
                    pshs      d,x,y,u
                    pshs      d,x,y,u
                    pshs      d,x,y,u
                    pshs      d,x,y,u
                    pshs      d,x,y,u
                    pshs      a,x,y

                    dec       X1DEA
                    bne       L05F7

                    lds       X1DDA
                    andcc     #$AF
                    puls      a,b,x,y,u,pc


*X782E
* receives a value from caller in b
* so range of input 0-255
* if less that 10 pads with leading zero
format_2_places
L0617               pshs      a,b,x,y,u           save everybody its always safe unless you forget to pull them :-)
                    cmpb      #$09                test input for single digit
                    bgt       No_pad              will be at least 2 places normal processing
                    pshs      b                   otherwise save value
                    ldb       #'0                 load a zero $30
                    lbsr      L0260               process that
                    puls      b                   pull value
No_pad              clra                          clear up anything left hanging around in a
                    lbsr      hex_to_digits       call normal processing  L00ED
                    puls      a,b,x,y,u,pc        we done


*X7843
* apparently no args passed
N062C               pshs      a,b,x,y,u
                    ldd       #$00A2
                    std       X1DA7

                    ldd       #$0112
                    std       X1DA5

                    clra
                    ldb       X4D01               load a value and pass it to
                    lbsr      hex_to_digits

                    ldd       #$0120
                    std       X1DA5

                    ldb       X4CFF               load a value and pass it to
                    lbsr      format_2_places
                    puls      a,b,x,y,u,pc


*X7866
N064F               pshs      a,b,x,y,u
                    ldd       #$00B2
                    std       X1DA7
                    ldd       #$0112
                    std       X1DA5
                    clra
                    ldb       X4D02
                    lbsr      hex_to_digits       L00ED
                    ldd       #$0120
                    std       X1DA5
                    ldb       X4D00
                    lbsr      L0617
                    puls      a,b,x,y,u,pc


*X7889
L0672               pshs      a,b,x               save the ones we will modify
                    pshs      b                   save b as we will use it later

                    ldx       X1D8B
                    stx       X1D89

                    lda       #$03
                    sta       X1D88

                    clr       X1D8F
                    clr       X1D91

                    ldx       #$02AF              load a base address
                    lda       X02A4               we set this to 1 prior to calling in sub
                    asla                          multiply by 2
                    leax      a,x
                    ldd       ,x
                    sta       X1D90
                    stb       X1D92

                    puls      b
                    lbsr      L015D

                    inc       X1D90
                    lbsr      L015D
                    inc       X1D92
                    lbsr      L015D
                    dec       X1D90
                    lbsr      L015D
                    lbsr      L0760
                    ldd       X1D93
                    stb       ,x+
                    std       X1D8F
                    ldd       X1D95
                    stb       ,x
                    std       X1D91
                    lbsr      L015D
                    inc       X1D90
                    lbsr      L015D
                    inc       X1D92
                    lbsr      L015D
                    dec       X1D90
                    lbsr      L015D
                    puls      a,b,x,pc


*X78F0
L06D9               pshs      a,b,x,y,u
                    cmpd      #$0064
                    bge       L06F9
                    pshs      b
                    ldb       #$30
                    lbsr      L0260
                    puls      b
                    cmpd      #$000A
                    bge       L06F9
                    pshs      b
                    ldb       #$30
                    lbsr      L0260
                    puls      b
L06F9               lbsr      hex_to_digits       L00ED
                    puls      a,b,x,y,u,pc


*X7915
L06FE               pshs      a,b,x,y,u
                    lbsr      L0760
                    lda       #3
                    sta       X1D88
                    ldx       X1D8B
                    stx       X1D89
                    ldd       X1D8F
                    subd      #$000C
                    std       X1DA5
                    ldd       X1D91
                    addd      #4
                    std       X1DA7
                    ldu       #$1D8F
                    pulu      d,x
                    pshs      d,x
                    pulu      d,x
                    pshs      d,x
                    lda       X02A4
                    asla
                    ldx       #$02A7
                    leax      a,x
                    ldd       ,x
                    sta       X1D94
                    stb       X1D96
                    lbsr      L019C
                    ldd       X02A5
                    lbsr      L06D9
                    puls      d
                    std       X1D93
                    stb       ,x+
                    puls      d
                    std       X1D95
                    stb       ,x
                    puls      d,x
                    std       X1D8F
                    stx       X1D91
                    lbsr      L019C
                    puls      a,b,x,y,u,pc


*X7977
L0760               pshs      a,b,x,y,u
                    tfr       d,u
                    pshs      b
                    ldx       #$0020
                    stx       X1D8F
                    leax      ByteTbl1,pcr
                    lda       X02A4
                    ldb       a,x
                    clra
                    std       X1D91
                    puls      b
                    leax      WordTbl2,pcr
                    cmpb      #$2C
                    bhi       L07A7
                    lslb
                    pshs      d
                    leax      90,x                last entry in table
                    tfr       x,d
                    subd      ,s++
                    tfr       d,x
                    clra
                    ldb       ,x+
                    addd      X1D8F
                    std       X1D93
                    ldb       ,x
                    pshs      d
                    ldd       X1D91
                    subd      ,s++
                    std       X1D95
                    lbra      L080A
L07A7               cmpb      #$59
                    bhi       L07C2
                    subb      #$2D
                    lslb
                    leax      b,x
                    ldb       ,x+
                    addd      X1D8F
                    std       X1D93
                    ldb       ,x
                    addd      X1D91
                    std       X1D95
                    bra       L080A
L07C2               cmpb      #$86
                    bhi       L07EC
                    subb      #$5A
                    lslb
                    pshs      d
                    leax      90,x
                    tfr       x,d
                    subd      ,s++
                    tfr       d,x
                    clra
                    ldb       ,x+
                    pshs      d
                    ldd       X1D8F
                    subd      ,s++
                    std       X1D93
                    clra
                    ldb       ,x
                    addd      X1D91
                    std       X1D95
                    bra       L080A
L07EC               subb      #$87
                    lslb
                    leax      b,x
                    ldb       ,x+
                    pshs      d
                    ldd       X1D8F
                    subd      ,s++
                    std       X1D93
                    clra
                    ldb       ,x
                    pshs      d
                    ldd       X1D91
                    subd      ,s++
                    std       X1D95
L080A               puls      a,b,x,y,u,pc


*X7A23
N080C               lbsr      L0431
                    std       X4CF3
                    lsra
                    rorb
                    lsra
                    rorb
                    std       X02A5
                    lsra
                    rorb
                    lda       #1
                    sta       X02A4
                    lbra      L06FE

*X7A3A
N0823               std       X4CF1
                    bpl       L082D
                    coma
                    comb
                    addd      #1
L082D               std       X02A5
                    ldb       X4CF2
                    bpl       L0837
                    addb      #$1C
L0837               stb       X1DDA
                    lda       #$73
                    mul
                    sta       X1DDB
                    ldb       X1DDA
                    lda       #6
                    mul
                    addb      X1DDB
                    lda       #2
                    sta       X02A4
                    lbra      L06FE

*X7A68
N0851               std       X4CF9
                    bpl       L0858
                    addb      #$1C
L0858               stb       X1DDA
                    lda       #$73
                    mul
                    sta       X1DDB
                    ldb       X1DDA
                    lda       #6
                    mul
                    addb      X1DDB
                    lda       #2
                    sta       X02A4
                    lbra      L0672

*X7A89
N0872               std       X4CEF
                    std       X02A5
                    lda       #3
                    sta       X02A4
                    lda       X4CF0
                    ldb       #$2E
                    mul
                    pshs      a
                    lda       X4CEF
                    ldb       #$2E
                    mul
                    addb      ,s+
                    lbra      L06FE
                    std       X4CF7
                    lda       #$2E
                    mul
                    pshs      a
                    lda       #3
                    sta       X02A4
                    lda       X4CF7
                    ldb       #$2E
                    mul
                    addb      ,s+
                    lbra      L0672               exits from there

WordTbl2
L08A8               fdb       $1300
                    fdb       $1301
                    fdb       $1301
                    fdb       $1302
                    fdb       $1302
                    fdb       $1203
                    fdb       $1203
                    fdb       $1204
                    fdb       $1204
                    fdb       $1205
                    fdb       $1205
                    fdb       $1106
                    fdb       $1106
                    fdb       $1007
                    fdb       $1007
                    fdb       $1008
                    fdb       $1008
                    fdb       $0F09
                    fdb       $0F09
                    fdb       $0E0A
                    fdb       $0E0A
                    fdb       $0D0B
                    fdb       $0D0B
                    fdb       $0C0B
                    fdb       $0B0C
                    fdb       $0B0C
                    fdb       $0A0D
                    fdb       $0A0D
                    fdb       $090D
                    fdb       $090D
                    fdb       $080E
                    fdb       $070E
                    fdb       $070E
                    fdb       $060E
                    fdb       $060E
                    fdb       $050E
                    fdb       $050E
                    fdb       $040F
                    fdb       $040F
                    fdb       $030F
                    fdb       $030F
                    fdb       $020F
                    fdb       $020F
                    fdb       $010F
                    fdb       $010F
                    fdb       $000F

ByteTbl1
L0904               fcb       $18,$49,$78,$A8


*X7B1F
N0908               pshs      a,b,x,y,u
                    ldd       X1DA3
                    beq       L0953
                    ldx       X1D91
                    cmpx      X1DAB
                    bcs       L0953
                    cmpx      X1DAF
                    bhi       L0953
                    ldd       X1D8F
                    cmpd      X1DAD
                    bgt       L0953
                    addd      X1DA3
                    cmpd      X1DA9
                    blt       L0953
                    ldd       X1D8F
                    subd      X1DA9
                    bpl       L0942
                    addd      X1DA3
                    std       X1DA3
                    ldd       X1DA9
                    std       X1D8F
L0942               ldd       X1DAD
                    subd      X1D8F
                    cmpd      X1DA3
                    bge       L0951
                    std       X1DA3
L0951               bra       L0957
L0953               puls      a,b,x,y,u,pc



*X7B6C
N0955               pshs      a,b,x,y,u
L0957               lda       X1D92
                    ldb       #$50
                    mul
                    ldy       X1D89
                    leay      d,y
                    ldd       X1D8F
                    lsra
                    rorb
                    lsra
                    rorb
                    leay      d,y
                    leau      ByteTbl5,pcr
                    ldb       X1D88
                    lda       b,u
                    sta       X1DDA
                    ldx       X1DA3
                    ldb       X1D90
                    andb      #3
                    beq       L09A8
L0982               leau      ByteTbl6,pcr
                    lda       X1DDA
                    anda      b,u
                    sta       X1DDB
                    leau      ByteTbl7,pcr
                    lda       ,y
                    anda      b,u
                    ora       X1DDB
                    sta       ,y
                    leax      -1,x
                    lbeq      L09DB
                    incb
                    cmpb      #4
                    bne       L0982
                    leay      1,y
L09A8               tfr       x,d
                    stb       X1DDB
                    lsra
                    rorb
                    lsra
                    rorb
                    beq       L09BB
                    lda       X1DDA
L09B6               sta       ,y+
                    decb
                    bne       L09B6
L09BB               ldb       X1DDB
                    andb      #3
                    beq       L09DB
                    leau      ByteTbl3,pcr
                    lda       X1DDA
                    anda      b,u
                    sta       X1DDB
                    leau      ByteTbl4,pcr
                    lda       ,y
                    anda      b,u
                    ora       X1DDB
                    sta       ,y
L09DB               puls      a,b,x,y,u,pc



*X7BF4
N09DD               pshs      a,b,x
                    ldd       X1D91
                    bpl       L09EA
                    ldd       #0
                    std       X1D91
L09EA               ldd       X1D95
                    bpl       L09F5
                    ldd       #0
                    std       X1D95
L09F5               ldd       X1D8F
                    cmpd      X1D93
                    bls       L0A13
                    ldx       X1D93
                    std       X1D93
                    stx       X1D8F
                    ldd       X1D91
                    ldx       X1D95
                    std       X1D95
                    stx       X1D91
L0A13               ldd       X1D93
                    subd      X1D8F
                    std       X1DB1
                    ldx       #1
                    ldd       X1D95
                    subd      X1D91
                    bcc       L0A2E
                    leax      -2,x
                    coma
                    comb
                    addd      #1
L0A2E               stx       X1DB5
                    std       X1DB3
                    cmpd      X1DB1
                    lbgt      L0A7A
                    ldd       X1DB1
                    lsra
                    rorb
                    std       X1DB7
L0A44               lbsr      L0AB7
                    ldx       X1D8F
                    cmpx      X1D93
                    lbeq      L0AB5
                    ldx       X1D8F
                    leax      1,x
                    stx       X1D8F
                    ldd       X1DB7
                    addd      X1DB3
                    std       X1DB7
                    cmpd      X1DB1
                    blt       L0A44
                    subd      X1DB1
                    std       X1DB7
                    ldd       X1D91
                    addd      X1DB5
                    std       X1D91
                    lbra      L0A44
L0A7A               lsra
                    rorb
                    std       X1DB7
L0A7F               lbsr      L0AB7
                    ldx       X1D91
                    cmpx      X1D95
                    lbeq      L0AB5
                    ldd       X1D91
                    addd      X1DB5
                    std       X1D91
                    ldd       X1DB7
                    addd      X1DB1
                    std       X1DB7
                    cmpd      X1DB3
                    blt       L0A7F
                    subd      X1DB3
                    std       X1DB7
                    ldx       X1D8F
                    leax      1,x
                    stx       X1D8F
                    lbra      L0A7F
L0AB5               puls      a,b,x,pc


*X7CCE
L0AB7               pshs      a,b,x,y
                    ldd       X1D91
                    cmpd      X1DAB
                    bcs       L0B12
                    cmpd      X1DAF
                    bhi       L0B12
                    ldd       X1D8F
                    cmpd      X1DA9
                    bcs       L0B12
                    cmpd      X1DAD
                    bhi       L0B12
                    lda       X1D92
                    ldb       #$50
                    mul
                    ldy       X1D8B
                    leay      d,y
                    ldd       X1D8F
                    lsra
                    rorb
                    lsra
                    rorb
                    leay      d,y
                    leax      >ByteTbl7,pcr
                    ldb       X1D90
                    andb      #3
                    pshs      b
                    lda       ,y
                    anda      b,x
                    sta       ,y
                    ldb       X1D88
                    leax      >ByteTbl5,pcr
                    lda       b,x
                    leax      >ByteTbl6,pcr
                    puls      b
                    anda      b,x
                    ora       ,y
                    sta       ,y
L0B12               puls      a,b,x,y,pc


*X7D28
N0B14               pshs      a,b
                    stu       X1E02
                    stb       X1DEF
                    ldd       X1E02
                    lbsr      L0501
                    lbsr      L0B34
                    leay      a,y
                    ldd       X1E02
                    lbsr      L0509
                    lbsr      L0B34
                    leax      a,x
                    puls      a,b,pc
L0B34               ldb       X1DEF
                    mul
                    tst       X1E04
                    beq       L0B3E
                    nega
L0B3E               rts


*X7D56
N0B3F               pshs      a,b,x,y,u
                    inc       X1D6B
                    lda       X1D6B
                    cmpa      #$1E
                    bcs       L0B5C
                    clr       X1D6B
                    lbsr      L0025
                    clra
L0B52               ldb       #$20
                    lbsr      L0260
                    inca
                    cmpa      #$1E
                    blt       L0B52
L0B5C               puls      a,b,x,y,u,pc


*X7D75
* input passed in u from caller is base address
* returns a value in a,b,x and y

N0B5E               ldd       1,u
                    anda      #$7F
                    tfr       d,y
                    ldd       4,u
                    anda      #$7F
                    tfr       d,x
                    lda       4,u
                    ldb       3,u
                    rola
                    rolb
                    rola
                    anda      #1
                    tst       X4C75
                    bne       L0B7D
                    subd      #$004C
                    bra       L0B80
L0B7D               subd      #$0060
L0B80               stb       X1DDA
                    lda       1,u
                    ldb       ,u
                    rola
                    rolb
                    rola
                    anda      #1
                    tst       X4C75
                    bne       L0B96
                    subd      #$0074
                    bra       L0B99
L0B96               subd      #$009C
L0B99               lda       X1DDA
                    rts


*X7DB4
* input passed in a and b from caller
* and uses the first byte on the stack
* modifies a, b, x and u
* restores a, x, and u on exit
* sets b for the return
N0B9D               pshs      a,x,u               save regs to be restored
                    pshs      a                   save the value passed by the caller(again)

                    lda       #$1C                load a with 28
                    mul                           multiply a x b stow in d
                    ldx       #$05CF              load a base address
                    leax      d,x                 using offset calculated reposition x

                    lda       ,s                  using the value passed in a last pushed on the stack
                    lsra                          divide by 2
                    lsra                          and again divide by 2  (by 4)
                    lsra                          and finally by 2 again (by 8 total)
                    leax      a,x                 using that offset calculated reposition x again

                    puls      a                   pop that input off the stack
                    anda      #7                  take the modulo 8 of the value
                    leau      >ByteTbl2,pcr       load the address of an 8 byte table
                    ldb       a,u                 using the modulo val for index select a value
                    andb      ,x                  and that value with the contents of x and save in b
                    puls      a,x,u,pc            clean up the stack and return



ByteTbl2
L0BBE               fcb       $80,$40,$20,$10,$08,$04,$02,$01

ByteTbl3
L0BC6               fcb       $00,$C0,$F0,$FC

ByteTbl4
L0BCA               fcb       $FF,$3F,$0F,$03

ByteTbl5
L0BCE               fcb       $00,$55,$AA,$FF

ByteTbl6
L0BD2               fcb       $C0,$30,$0C,$03

ByteTbl7
L0BD6               fcb       $3F,$CF,$F3,$FC

ByteTbl8
L0BDA               fcb       $00,$03,$0C,$0F,$30,$33
                    fcb       $3C,$3F,$C0,$C3,$CC,$CF
                    fcb       $F0,$F3,$FC,$FF

                    emod
eom                 equ       *
                    end
