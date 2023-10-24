**
**********************************
**                              **
**  CSC OS/9 Asmb X-ref c1982   **
**                              **
** Computer Systems Consultants **
** E. M. (Bud) Pass, Ph.D.      **
** 1454 Latta Lane NW           **
** Conyers, GA 30207            **
**                              **
**********************************
**
                    nam       CSC                 OS/9 Assembler X-ref
**
vn                  equ       $04                 version number
os9lno              equ       $02                 os9 level number ($01=1.1 or $02=1.2/2.x)
coco                equ       $00                 ($00 for coco, $01 for other)

                    use       defsfile

**
                    mod       endmod,namemd,Prgrm+Objct,ReEnt+vn,start,endmem header
**
namemd              fcs       "XRef3"
**
                    fcc       "CSC OS/9 Asmb X-ref c1982"
                    fcb       $0d
                    fcc       "All Rights Reserved by"
                    fcb       $0d
                    fcc       "E. M. (Bud) Pass, Ph.D."
                    fcb       $0d
                    fcc       "Computer Systems Consultants, Inc."
                    fcb       $0d
                    fcc       "1454 Latta Lane, Conyers, GA 30207"
                    fcb       $0d
                    fcc       "Telephone Number 404-483-1717/4570"
                    fcb       $0d
                    fcc       "Updates for OS9 level 2 by Gene Heskett"
                    fcb       $0d
                    fcc       "291 Garton Avenue, Weston, WV 26452"
                    fcb       $0d
                    fcc       "Telephone Number 304-269-4295/623-5555"
                    fcb       $0d
**
iobfc               equ       0                   function code
iobba               equ       1                   buffer address
iobbl               equ       3                   buffer length
iobfd               equ       5                   file descriptor
iobca               equ       7                   next char address
iobcc               equ       9                   char counter
iobfn               equ       16                  file name
ioblen              equ       64                  length of i/o block
fnmlen              equ       ioblen-iobfn        length of file name
buflen              equ       256                 length of i/o buffer
read                equ       1                   read block raw
rdln                equ       2                   read block edited
write               equ       3                   write block raw
wrln                equ       4                   write block edited
*
ht                  equ       $09                 ascii ht
cr                  equ       $0d                 ascii cr
eot                 equ       $04                 ascii eot
tabsiz              equ       $6000               default table size was $4000 by GH
maxnam              equ       $1E                 max name length <=31
dwidth              equ       $50                 default output width
clrscr              equ       $0c                 clear screen, was $1A,$00,$00 by GH
**
                    org       $0000
**
temps               equ       .                   start of work areas
phase               rmb       1                   phase number
count               rmb       1                   character count
maxcnt              rmb       1                   max char count
size                rmb       1                   table entry size
platen              rmb       1                   output max width
column              rmb       1                   current output column
outswt              rmb       1                   std/err output
loops               rmb       1                   loop count
digit               rmb       1                   current digit
chart               rmb       1                   last char scanned
items               rmb       1                   items scanned on curr line
colcnt              rmb       1                   displacement of curr char
colstr              rmb       1                   location of first byte of word
explib              rmb       1                   expand lib/use switch
debugr              rmb       1                   debugging switch
paraln              rmb       2                   parameter line pointer
alimit              rmb       2                   ending table address
iobc                rmb       2                   current iob pointer
iobf                rmb       2                   first iob pointer
iobl                rmb       2                   last iob pointer
iobuf               rmb       2                   current buffer pointer
star                rmb       2                   start pointer
endr                rmb       2                   end pointer
buff                rmb       2                   buffer pointer
tab1                rmb       2                   temp pointer 1
tab2                rmb       2                   temp pointer 2
lines               rmb       2                   line number pointer
linno               rmb       2                   line counter
baddr               rmb       2                   temp
raddr               rmb       2                   temp
**
                    rmb       (((.+$003f)/64)*64)-. adjust to 64 bytes
**
inarea              rmb       64                  input scan area
tiblok              rmb       ioblen              std input iob
toblok              rmb       ioblen              std output iob
teblok              rmb       ioblen              err output iob
iob00               rmb       ioblen              input iob
iob01               rmb       ioblen              lib/use 01 iob
iob02               rmb       ioblen              lib/use 02 iob
iob03               rmb       ioblen              lib/use 03 iob
iob04               rmb       ioblen              lib/use 04 iob
iob05               rmb       ioblen              lib/use 05 iob
iob06               rmb       ioblen              lib/use 06 iob
iob07               rmb       ioblen              lib/use 07 iob
iob08               rmb       ioblen              lib/use 08 iob
iob09               rmb       ioblen              lib/use 09 iob
iob0a               rmb       ioblen              lib/use 0a iob
iob0b               rmb       ioblen              lib/use 0b iob
iob0c               rmb       ioblen              lib/use 0c iob
**
tibuff              rmb       buflen              std input buffer
tobuff              rmb       buflen              std output buffer
tebuff              rmb       buflen              err output buffer
iobf00              rmb       buflen              input buffer
iobf01              rmb       buflen              lib/use 01 buffer
iobf02              rmb       buflen              lib/use 02 buffer
iobf03              rmb       buflen              lib/use 03 buffer
iobf04              rmb       buflen              lib/use 04 buffer
iobf05              rmb       buflen              lib/use 05 buffer
iobf06              rmb       buflen              lib/use 06 buffer
iobf07              rmb       buflen              lib/use 07 buffer
iobf08              rmb       buflen              lib/use 08 buffer
iobf09              rmb       buflen              lib/use 09 buffer
iobf0a              rmb       buflen              lib/use 0a buffer
iobf0b              rmb       buflen              lib/use 0b buffer
iobf0c              rmb       buflen              lib/use 0c buffer
**
buffer              rmb       (tabsiz+$0100)      buffer area
**
endmem              equ       .
**
start               equ       *                   starting addr
**
                    pshs      x
                    leax      temps,u             init
                    ldy       #(buffer+tabsiz-temps)
clear               clr       ,x+
                    leay      -$01,y
                    bne       clear
                    puls      x
                    stx       paraln,u            parameter line pointer
                    leax      -$0100,s            table limit
                    stx       alimit,u
                    lda       #dwidth             default console width
                    suba      #$08
                    sta       platen,u
                    ldx       #$ff7f              put end on table
                    stx       buffer,u
                    leax      buffer+8,u
                    stx       endr,u
                    lda       #read               set up iob's
                    sta       tiblok+iobfc,u
                    lda       #wrln
                    sta       teblok+iobfc,u
                    sta       toblok+iobfc,u
                    lda       #write
                    sta       iob00+iobfc,u
                    ldd       #$0002
                    std       teblok+iobfd,u
                    ldd       #$0001
                    std       toblok+iobfd,u
                    ldd       #buflen
                    std       tiblok+iobbl,u
                    std       teblok+iobbl,u
                    std       teblok+iobcc,u
                    std       toblok+iobbl,u
                    std       toblok+iobcc,u
                    std       iob00+iobbl,u
                    std       iob00+iobcc,u
                    leax      iob00+iobfn,u
                    ldd       #$7872              xref.temp
                    std       ,x++
                    ldd       #$6566
                    std       ,x++
                    ldd       #$2e74
                    std       ,x++
                    ldd       #$656d
                    std       ,x++
                    ldd       #$7000
                    std       ,x++
                    leax      tibuff,u
                    stx       tiblok+iobba,u
                    stx       tiblok+iobca,u
                    leax      tebuff,u
                    stx       teblok+iobba,u
                    stx       teblok+iobca,u
                    leax      tobuff,u
                    stx       toblok+iobba,u
                    stx       toblok+iobca,u
                    leax      iobf00,u
                    stx       iob00+iobba,u
                    stx       iob00+iobca,u
                    stx       iobuf,u             point to first buffer
                    lda       #$01
                    sta       outswt,u            force to crt
                    leax      iob00,u             point to first iob
                    stx       iobc,u
                    stx       iobf,u
                    leax      iob0c,u             point to last iob
                    stx       iobl,u
                    leax      tiblok,u
                    lbsr      gnc                 try to get a char
                    lbcs      headin
                    lbvs      headin
                    pshs      a
                    leax      iob00+iobfn,u       open output temp
                    ldd       #(WRITE.*256)+(READ.+WRITE.)
                    os9       I$Create
                    lbcs      headin
                    clrb
                    exg       a,b
                    std       iob00+iobfd,u
                    puls      a
putget              leax      iob00,u             copy std input
                    lbsr      pnc
                    bcc       putoko
                    lda       #$02                error
                    ldy       #errorl
                    leax      errorz,pcr
                    os9       I$WritLn
                    lbra      headin
putoko              leax      tiblok,u
                    lbsr      gnc
                    bcs       geterr
                    bvc       putget
                    bra       clstmp
geterr              lda       #$02                error
                    ldy       #errirl
                    leax      errirz,pcr
                    os9       I$WritLn
                    lbra      killer
clstmp              leax      iob00,u
                    lbsr      fob
                    lbcs      headin
                    ldd       iob00+iobfd,u
                    tfr       b,a
                    os9       I$Close
                    lbcs      headin
                    leax      iob00+iobfn,u       open input temp
                    ldd       #(READ.*256)
                    os9       I$Open
                    bcs       headin              was lbcs by GH
                    clrb
                    exg       a,b
                    std       iob00+iobfd,u
                    lda       #read
                    sta       iob00+iobfc,u
                    leax      iobf00,u
                    stx       iob00+iobba,u
                    stx       iob00+iobca,u
                    ldd       #buflen
                    std       iob00+iobbl,u
                    ldd       #$0000
                    std       iob00+iobcc,u
                    ldx       paraln,u            look for + parameter
arglop              lda       ,x+                 check next arg
                    cmpa      #$20                space
                    blo       compro
                    cmpa      #$3f                ?
                    bne       argdeb
                    sta       debugr,u            set debugging switch
                    bra       arglop
argdeb              cmpa      #$2b                +
                    bne       arglop
                    sta       explib,u            set lib/use call switch
                    bra       arglop
compro              lbsr      proces              process without messages
comout              leax      teblok,u
                    lbsr      fob
                    leax      toblok,u
                    lbsr      fob
                    bcc       killer
                    lda       #$02                error
                    ldy       #errorl
                    leax      errorz,pcr
                    os9       I$WritLn
killer              ldd       iob00+iobfd,u       close temp
                    tfr       b,a
                    os9       I$Close
                    leax      iob00+iobfn,u       delete temp
                    os9       I$Delete
                    ldd       #$0000              exit
                    os9       F$Exit
**
headin              lda       #clrscr             clear screen
                    lbsr      xoute
                    lbsr      xcrlf               print heading
                    leax      idlin,pcr
helpyu              stx       baddr,u
                    lbsr      xcrlf
                    ldx       baddr,u
                    lbsr      xpdat
                    tst       ,x
                    bne       helpyu
                    leax      beeps,pcr
                    lbsr      xpdat
                    lbsr      xcrlf
                    ldd       #$0000
                    os9       F$Exit
**
scnlib              ldb       #fnmlen             get lib/use file name
                    stx       raddr,u
                    pshs      b,x
scning              clr       ,x+                 clear name area first
                    decb
                    bne       scning
                    puls      b,x
scninm              lbsr      inchrt              get a char
                    cmpa      #$20                chk ctrl
                    blo       scninx
                    bne       scnins              chk leading space
                    cmpx      raddr,u
                    beq       scninm
                    bra       scnint
scnins              sta       ,x+
                    decb
                    bne       scninm
scnint              lbsr      inchrt              scan out line
                    cmpa      #$20
                    bhs       scnint
scninx              clr       ,x                  put null after input
                    rts
**
librar              pshs      d,x                 check for lib/use call
                    tst       explib,u            check switch
                    bmi       libout              off
                    beq       libout
                    lda       count,u             check for count=3
                    cmpa      #$03
                    bne       libout
                    leax      inarea,u            check for use/lib
                    ldd       ,x
                    anda      #$5f
                    andb      #$5f
                    cmpd      #$4c49              LI
                    beq       libcon
                    cmpd      #$5553              US
                    bne       libout
libcon              ldd       $01,x
                    anda      #$5f
                    andb      #$5f
                    cmpd      #$4942              IB
                    beq       libtst
                    cmpd      #$5345              SE
                    bne       libout
libtst              tst       explib,u            test lib/use flag
                    bmi       libout              off
                    beq       libout
                    bsr       libdk               scan for file name
libout              puls      d,x,pc              exit
**
libdk               ldx       iobc,u              try to process lib/use file
                    cmpx      iobl,u              ignore lib/use nest > 12 deep
                    lbhs      libnx
                    ldd       iobc,u              point to next iob
                    addd      #ioblen
                    std       baddr,u
                    tfr       d,x
                    leax      iobfn,x
                    lbsr      scnlib              get lib/use file name
                    cmpb      #fnmlen
                    lbeq      libni               exit if no name
                    ldy       #$0000
                    ldx       baddr,u
                    ldd       #(READ.*256)
                    leax      iobfn,x             lib/use name
                    os9       I$Open
                    bcc       libno
liber               lda       #$02                error
                    ldy       #errlrl
                    leax      errlrz,pcr
                    os9       I$WritLn
                    ldy       #fnmlen             length
                    ldx       baddr,u             lib/use name
                    leax      iobfn,x
                    lda       #$02
                    os9       I$WritLn
                    ldd       #$020d              cr
                    ldy       #$0001
                    pshs      b
                    tfr       s,x
                    os9       I$WritLn
                    puls      b
                    bra       libni
libno               ldx       baddr,u             lib/use name
                    leax      iobfn,x
                    pshs      d
                    lda       #$02
                    ldy       #fnmlen             length
                    os9       I$WritLn
                    ldd       #$020d              cr
                    ldy       #$0001
                    pshs      b
                    tfr       s,x
                    os9       I$WritLn
                    puls      b
                    puls      d
                    ldx       baddr,u             point to new iob
                    stx       iobc,u
                    clrb
                    exg       a,b
                    std       iobfd,x
                    lda       #read
                    sta       iobfc,x
                    ldy       iobuf,u
                    leay      buflen,y
                    sty       iobuf,u
                    sty       iobba,x
                    sty       iobca,x
                    ldd       #buflen
                    std       iobbl,x
                    ldd       #$0000
                    std       iobcc,x
libni               clr       chart,u             reset scanner
                    clr       colcnt,u
                    clr       items,u
libnx               rts
**
inchrt              pshs      b,x                 input a char
inchru              ldx       iobc,u
                    tst       iobfc,x             chk for eof
                    bmi       inchff
                    lbsr      gnc
                    bcs       inchen
                    bvs       inchef
                    cmpa      #$20
                    bhs       inchne
                    cmpa      #cr                 chk cr
                    beq       inchcr
                    cmpa      #ht                 chk ht
                    bne       inchru
                    lda       #$20                ht to space
                    bra       inchne
inchen              lda       #$02
                    ldx       iobc,u
                    cmpx      iobf,u
                    bne       inchel
                    ldy       #errirl
                    leax      errirz,pcr
                    os9       I$WritLn
                    bra       inchef
inchel              ldy       #errlrl
                    leax      errlrz,pcr
                    os9       I$WritLn
inchef              ldx       iobc,u              close the file
                    ldd       iobfd,x
                    tfr       b,a
                    os9       I$Close
                    ldx       iobc,u              mark iob closed
                    lda       #$ff
                    sta       ,x
inchff              cmpx      iobf,u              check for lib/use file
                    beq       inchfe
                    pshs      b
                    ldd       iobuf,u             point to prev buffer
                    subd      #buflen
                    std       iobuf,u
                    ldd       iobc,u              point to prev iob
                    subd      #ioblen
                    std       iobc,u
                    puls      b
                    bra       inchru              back for more
inchfe              lda       #eot                eof
inchcr              clr       items,u             reset counters
                    clr       colcnt,u
                    dec       colcnt,u
inchne              sta       chart,u             remember the char
                    inc       colcnt,u
                    puls      b,x,pc
**
crxref              pshs      a                   enter name and line into table
crxtab              lda       count,u             find max count
                    cmpa      maxcnt,u
                    bls       crxmax
                    sta       maxcnt,u
crxmax              ldb       #$20                clear rest of name
                    ldx       star,u
crxspc              stb       ,x+                 insert spaces
                    inca
                    cmpa      #maxnam
                    bls       crxspc
                    leax      buffer,u            point to buffer
                    stx       buff,u
crxnex              lda       ,x                  check next name
                    sta       size,u
                    leay      inarea,u            point to name
crxcom              leax      $01,x               check next name
                    ldb       ,x
                    cmpb      ,y+
                    bne       crxcrc
                    deca
                    bne       crxcom
                    lda       size,u              check sizes
                    cmpa      count,u
                    beq       crxaeb              check equal
crxcrc              tfr       cc,a
                    stx       tab1,u
                    tfr       a,cc
                    bmi       crxagb              check greater
                    bra       crxalb              check less, was lbra by GH
crxagb              ldx       buff,u              look at next entry
                    lda       size,u
                    adda      #$07
crxage              leax      a,x                 step to next entry
                    stx       buff,u
                    bra       crxnex
crxaeb              tst       phase,u             check for phase 1
                    beq       crxalx
                    lda       size,u              check defining line number
                    ldx       buff,u
                    inca
crxaee              leax      a,x
                    ldy       ,x
                    cmpy      linno,u
                    beq       crxalx
crxaen              stx       tab1,u              enter line number
                    ldx       $04,x
                    beq       crxaez
                    stx       tab2,u              check dup
                    ldy       ,x
                    cmpy      linno,u
                    beq       crxalx
                    bra       crxaeo
crxaez              ldx       tab1,u              link it in
crxaeo              ldy       lines,u
                    cmpy      alimit,u            check for table overflow
                    blo       crxatb
                    leax      tabovf,pcr          table overflow!
                    ldy       #tabovl
                    lda       #$02
                    os9       I$WritLn
                    lbra      killer              terminate
crxatb              sty       $02,x
                    tfr       y,x
                    ldy       linno,u
                    sty       ,x
                    clr       $02,x
                    clr       $03,x
                    stx       tab2,u
                    leax      $04,x
                    stx       lines,u
                    ldx       tab1,u
                    ldy       tab2,u
                    sty       $04,x
crxalx              bra       crxxit
crxalb              tst       phase,u             check for phase 1
                    bne       crxalx
crxaly              ldx       endr,u              make room
                    tfr       x,y
                    lda       count,u
                    adda      #$07
                    leay      a,y                 step over entry
                    sty       endr,u
                    cmpy      alimit,u            check for table overflow
                    blo       crxalp
                    leax      tabovf,pcr          table overflow!
                    ldy       #tabovl
                    lda       #$02
                    os9       I$WritLn
                    lbra      killer              terminate
crxalp              lda       ,-x                 move data
                    sta       ,-y
                    cmpx      buff,u
                    bne       crxalp
crxall              ldb       count,u             insert entry
                    stb       ,x+
                    leay      inarea,u
crxali              lda       ,y+
                    sta       ,x+
                    decb
                    bne       crxali
                    ldy       linno,u             insert line number
                    sty       ,x
                    clr       $02,x               clear pointers
                    clr       $03,x
                    clr       $04,x
                    clr       $05,x
crxxit              puls      a
                    rts
**
proces              clr       phase,u             process data
                    lbsr      xcrlf
                    lbsr      prphas              print phase
                    bra       proacl
proagr              lbsr      inchrt              get a char
proarg              cmpa      #$41                check alpha
                    blo       proacr
                    cmpa      #$5a
                    bls       proalp
                    cmpa      #$61
                    blo       proacr
                    cmpa      #$7a
                    bhi       proacr
                    anda      #$5f                convert to upper case
                    bra       proalp
proacr              cmpa      #eot                check eof
                    beq       proaq1
                    cmpa      #cr                 check cr
                    bne       proagr
proacl              ldx       linno,u             incr line count
                    leax      $01,x
                    stx       linno,u
proaca              lbsr      inchrt              check for *
                    cmpa      #$2a
                    bne       proarg
proarc              lbsr      inchrt              get a char
proarr              cmpa      #eot
proaq1              beq       proap1              was lbeq by GH
                    cmpa      #cr
                    beq       proacl
                    bra       proarc
proalp              leax      inarea,u
                    stx       star,u
                    inc       items,u             update counters
                    ldb       colcnt,u
                    stb       colstr,u
                    ldb       #maxnam             set max name length
                    stb       baddr,u
                    clr       count,u
proall              tst       baddr,u             check count
                    beq       proanl
                    ldx       star,u              save the char
                    sta       ,x+
                    stx       star,u
                    inc       count,u
                    dec       baddr,u
proanl              lbsr      inchrt              get a char
                    cmpa      #$24                check dollar
                    beq       proall
                    cmpa      #$2e                check period
                    beq       proall
                    cmpa      #$30                check numeric
                    bmi       proala
                    cmpa      #$39
                    bls       proall
                    cmpa      #$41                check capital letters
                    bmi       proala
                    cmpa      #$5a
                    bls       proall
                    cmpa      #$5f                check underscore
                    beq       proall
                    cmpa      #$61                check small letters
                    bmi       proala
                    cmpa      #$7a
                    bhi       proala
                    anda      #$5f                convert to upper case
                    bra       proall
proala              ldb       colstr,u            check for label
                    decb
                    bne       proali
                    lbsr      crxref              enter name and line into table
                    bra       proail
proali              ldb       items,u             check for opcode
                    decb
                    bne       proail
                    lbsr      librar              check for lib/use call
                    lda       chart,u
                    bne       proail
                    bra       proaca              was lbra by GH
proail              bra       proarr
proap1              inc       phase,u             end phase 1
                    lbsr      prphas              print phase
                    ldx       endr,u              set line number address
                    stx       lines,u
                    leax      iob00,u             reposition input file
                    stx       iobc,u
                    ldd       iob00+iobfd,u
                    tfr       b,a
                    os9       I$Close
                    leax      iob00+iobfn,u       open input
                    ldd       #(READ.*256)
                    os9       I$Open
                    bcs       prober
                    clrb
                    exg       a,b
                    std       iob00+iobfd,u
                    lda       #read
                    sta       iob00+iobfc,u
                    leax      iobf00,u
                    stx       iob00+iobba,u
                    stx       iob00+iobca,u
                    ldd       #buflen
                    std       iob00+iobbl,u
                    ldd       #$0000
                    std       iob00+iobcc,u
                    bra       probcl
prober              lda       #$02                error
                    ldy       #errirl
                    leax      errirz,pcr
                    os9       I$WritLn
                    lbra      killer
probgr              lbsr      inchrt              get a char
probrg              cmpa      #$41                check alpha
                    blo       probcr
                    cmpa      #$5a
                    bls       problp
                    cmpa      #$61
                    blo       probcr
                    cmpa      #$7a
                    bhi       probcr
                    anda      #$5f                convert to upper case
                    bra       problp
probcr              cmpa      #eot                check eof
                    beq       probq2
                    cmpa      #cr                 check cr
                    bne       probgr
probcl              ldx       linno,u             incr line count
                    leax      $01,x
                    stx       linno,u
probca              lbsr      inchrt              check for *
                    cmpa      #$2a
                    bne       probrg
probrc              lbsr      inchrt              get a char
probrr              cmpa      #eot
probq2              beq       probp2
                    cmpa      #cr
                    beq       probcl
                    bra       probrc
problp              leax      inarea,u
                    stx       star,u
                    inc       items,u             update counters
                    ldb       colcnt,u
                    stb       colstr,u
                    ldb       #maxnam             set max name length
                    stb       baddr,u
                    clr       count,u
probll              tst       baddr,u             check count
                    beq       probnl
                    ldx       star,u              save the char
                    sta       ,x+
                    stx       star,u
                    inc       count,u
                    dec       baddr,u
probnl              lbsr      inchrt              get a char
                    cmpa      #$24                check dollar
                    beq       probll
                    cmpa      #$2e                check period
                    beq       probll
                    cmpa      #$30                check numeric
                    blo       probla
                    cmpa      #$39
                    bls       probll
                    cmpa      #$41                check capital letters
                    blo       probla
                    cmpa      #$5a
                    bls       probll
                    cmpa      #$5f                check underscore
                    beq       probll
                    cmpa      #$61                check small letters
                    blo       probla
                    cmpa      #$7a
                    bhi       probla
                    anda      #$5f                convert to upper case
                    bra       probll
probla              ldb       items,u             check for opcode
                    decb
                    bne       probli
                    lbsr      librar              check for lib/use call
                    lda       chart,u
                    bne       probli
                    bra       probca              was lbra by GH
probli              lbsr      crxref              enter name and line into table
probil              lbra      probcr
probp2              inc       phase,u             end phase 2
                    lbsr      prphas              print phase
                    lbsr      xcrlf
                    lbsr      xcrlf
                    lbsr      xcrlf
                    leax      buffer,u            point to buffer
                    stx       buff,u
proclf              lbsr      xcrlf               do crlf
                    ldx       buff,u              point to entry
                    cmpx      endr,u              check for end
                    beq       prolix
                    lda       ,x                  get count
                    bmi       prolix
                    sta       count,u
                    ldb       maxcnt,u            get max name length
proclp              leax      $01,x               print name
                    lda       ,x
                    lbsr      xoute
                    decb
                    dec       count,u
                    bne       proclp
procsp              tstb                          print spaces
                    beq       procln
                    lbsr      xouts
                    decb
                    bne       procsp
procln              leax      $01,x               print defining line number
                    ldy       ,x++
                    sty       linno,u
                    ldy       ,x++                get front pointer
                    sty       star,u
                    leax      $02,x
                    stx       buff,u
procnx              bsr       prline              print line number
                    ldx       star,u              get next line number
                    beq       proclf
                    ldy       ,x
                    sty       linno,u
                    ldx       $02,x               get next pointer
                    stx       star,u
                    bra       procnx
prolix              lbsr      xcrlf               print crlf
                    rts
**
prline              lda       column,u            print line number
                    cmpa      platen,u            check right margin
                    bmi       prlcok
                    lbsr      xcrlf               print crlf
                    ldb       #maxnam
prlnam              lbsr      xouts               print spaces
                    decb
                    bne       prlnam
prlcok              lbsr      xouts               print a space
                    lda       #$05                set number of scale factors
                    sta       loops,u
                    leax      scaler,pcr          point to convert table
                    lda       #$30                set up digit
                    sta       digit,u
                    ldd       linno,u             look at line number
prlcom              cmpd      ,x                  compare against scale factor
                    bhs       prldig
prlnxd              pshs      d
                    lda       digit,u             print the digit
                    bsr       xoute               was lbsr by GH
                    lda       #$30                set up digit
                    sta       digit,u
                    puls      d
                    dec       loops,u             check for last digit
                    beq       prlend
                    leax      $02,x               point to next scale factor
                    bra       prlcom
prldig              inc       digit,u             incr digit count
                    subd      ,x                  decr line number
                    bra       prlcom
prlend              rts
**
prphas              inc       outswt,u            force to crt
                    leax      lphase,pcr          print phase number
                    bsr       xpdat               was lbsr by GH
                    lda       phase,u
                    adda      #$31
                    bsr       xoute               was lbsr by GH
                    bsr       xcrlf               was lbsr by GH
                    leax      teblok,u
                    lbsr      fob
                    clr       outswt,u            reset outswt
                    ldx       #$0000              reset counters
                    stx       items,u
                    stx       linno,u
                    rts
**
xinee               pshs      b,x                 input one char into a
                    leax      teblok,u
                    lbsr      fob
                    leax      tiblok,u
                    bsr       gnc                 was lbsr by GH
                    bcc       xinef
                    lda       #$02                error
                    ldy       #errirl
                    leax      errirz,pcr
                    os9       I$WritLn
                    ldd       #$0000
                    os9       F$Exit
xinef               puls      b,x,pc
xpdaa               bsr       xoute               print to $04 from a then x
xpdat               lda       ,x+                 print to $04 from x
                    cmpa      #eot
                    bne       xpdaa
                    rts
xouts               lda       #$20                print 1 space
xoute               pshs      d,x                 print char in a
                    leax      toblok,u
                    tst       outswt,u
                    beq       xouto
                    leax      teblok,u
xouto               lbsr      pnc
                    bcc       xoutx
                    lda       #$02                error
                    ldy       #errorl
                    leax      errorz,pcr
                    os9       I$WritLn
                    ldd       #$0000
                    os9       F$Exit
xoutx               inc       column,u            count columns
                    cmpa      #$0d                cr
                    bne       xoutz
                    lbsr      fob
xoutz               puls      d,x,pc
xcrlf               clr       column,u            clear column counter
                    lda       #$0d                cr
                    bra       xoute               print crlf
**
**
*
* blocked i/o routines
*
* gnc - get next char
*
* entry - x=i/o block pointer
*
* exit - cs if error, d=error
*        cc if no error
*        vs if eof
*        if cc and vc, a=char
*
* preserves all other registers
*
gnc                 pshs      b,x,y
                    ldd       iobcc,x             get remaining char count
                    bne       gnc1                if chars left
gnc0                lda       iobfd+1,x           a=file descriptor
                    ldy       iobbl,x             buffer length
                    ldb       iobfc,x             function code
                    pshs      x
                    ldx       iobba,x             buffer address
                    cmpb      #read
                    beq       gncrw
                    os9       I$ReadLn            reload buffer edited
                    bra       gncrd
gncrw               os9       I$Read              reload buffer raw
gncrd               puls      x
                    bcs       gnc4                if error
                    sty       iobcc,x             save char count
                    beq       gnc3                if eof
                    ldd       iobba,x             reset char pointer
                    std       iobca,x
                    ldd       iobcc,x             d=char count
gnc1                subd      #$0001              count chars
                    std       iobcc,x
gnc2                ldy       iobca,x             get char
                    lda       ,y+
                    sty       iobca,x             update char pointer
                    tst       debugr,u            check debugging switch
                    beq       gnc2d
                    leax      teblok,u            output a character
                    bsr       pnc
                    cmpa      #$0d
                    bne       gnc2d
                    leax      teblok,u
                    bsr       fob                 was lbsr by GH
gnc2d               clrb                          cc, vc
                    puls      b,x,y,pc
gnc3                orcc      #$02                vs for eof
                    puls      b,x,y,pc
gnc4                cmpb      #E$EOF              check error
                    beq       gnc3                for eof
                    orcc      #$01                cs
                    leas      $01,s               remove b
                    puls      x,y,pc              cs, d=error
*
* pnc - put next character
*
* entry - a=char,x=i/o block pointer
*
* exit - cc if no error, a=char
*        cs if error, d=error
*
pnc                 pshs      a,b,y
                    ldd       iobcc,x             get remaining count
                    bne       pnc1                if room
                    lda       iobfd+1,x           a=file descriptor
                    ldb       iobfc,x             function code
                    ldy       iobbl,x             buffer length
                    pshs      x
                    ldx       iobba,x             buffer address
                    cmpb      #write
                    beq       pncrw
                    os9       I$WritLn            dump buffer edited
                    bra       pncwt
pncrw               os9       I$Write             dump buffer raw
pncwt               puls      x
                    bcs       pnc3                if error
pnc0                ldd       iobba,x             update char pointer
                    std       iobca,x
                    ldd       iobbl,x             d=new size
pnc1                subd      #$0001              count chars
                    std       iobcc,x             update count
                    ldy       iobca,x             store char
                    puls      a
                    sta       ,y+
                    sty       iobca,x             update char pointer
pnc2                puls      b,y,pc
pnc3                leas      2,s                 remove a and b
                    clra
                    orcc      #$01                cs, error
                    puls      y,pc                cs, d=error
*
* fob - flush output buffer
*
* entry - x=i/o block pointer
*
* exit - cs if error
*
fob                 pshs      d,y
                    ldd       iobbl,x             get buffer size
                    subd      iobcc,x             determine char count
                    beq       fob1                if empty
                    tfr       d,y                 set char count to write
                    lda       iobfd+1,x           a=file descriptor
                    ldb       iobfc,x             function code
                    pshs      x
                    ldx       iobba,x             buffer address
                    cmpb      #write
                    beq       fobrw
                    os9       I$WritLn            dump buffer edited
                    bra       fobwt
fobrw               os9       I$Write             dump buffer raw
fobwt               puls      x
                    bcs       fob2                if error
fob0                ldd       iobba,x             update char pointer
                    std       iobca,x
fob1                ldd       iobbl,x             restore buffer size
                    std       iobcc,x             reset avail counter
                    clra                          clear errors
                    puls      d,y,pc              return
fob2                leas      2,s                 remove a and b
                    clra
                    orcc      #$01                cs, error
                    puls      y,pc                cs, d=error
*
**
errirz              fcc       "error on input file"
                    fcb       $07,$0d
errirl              equ       *-errirz
errlrz              fcc       "error on lib/use file"
                    fcb       $07,$0d
errlrl              equ       *-errlrz
errorz              fcc       "error on output file"
                    fcb       $07,$0d
errorl              equ       *-errorz
**
idlin               fcc       "CSC OS/9 Assembler Cross-Reference v1.0"
                    fcb       $04
                    fcc       " by E. M. (Bud) Pass, Conyers, GA c1982"
                    fcb       $04,$04
                    fcc       "This program performs an assembler"
                    fcb       $04
                    fcc       " cross-reference function under OS/9."
                    fcb       $04,$04
                    fcc       "It uses standard inputs and outputs,"
                    fcb       $04
                    fcc       "so input and output may be piped or"
                    fcb       $04
                    fcc       "either may be entered directly as"
                    fcb       $04
                    fcc       "<input and >output.  LIB and USE calls"
                    fcb       $04
                    fcc       "may be expanded by entering '+'"
                    fcb       $04
                    fcc       "as an OS/9 command line parameter."
                    fcb       $04
                    fcc       "In case of table overflow, the OS/9 command"
                    fcb       $04
                    fcc       "line parameter #nnK may be used to provide"
                    fcb       $04
                    fcc       "more memory space for processing."
                    fcb       $07,$04,$00
lphase              fcc       "phase "
beeps               fcb       $07,$04             bell
tabovf              fcc       "table overflow!"
                    fcb       $07,$0d
tabovl              equ       *-tabovf
scaler              fdb       10000               decimal convert table
                    fdb       1000
                    fdb       100
                    fdb       10
                    fdb       1
**
                    emod
endmod              equ       *
**
                    end
