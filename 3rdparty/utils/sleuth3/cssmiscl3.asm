
***************************************
**
helpme              lbsr      stopin              help routine
                    leax      clrscn,pcr          clear screen
                    lbsr      outcur
                    leax      helps,pcr
helpyu              stx       baddr,u
                    lbsr      xcrlf
                    ldx       baddr,u
                    lbsr      xpdat
                    tst       ,x
                    bne       helpyu
                    rts
**
fcrof               lbsr      xinee               flip cross-assembler flag
                    com       crofl,u
                    rts
**
fequf               lbsr      xinee               flip equ flag
                    com       equfl,u
                    rts
**
fposf               lbsr      xinee               flip pos-ind flag
                    com       posfl,u
                    rts
**
setmod              lbsr      xcrlf               set cpu mode
                    leax      lmode,pcr
                    lbsr      xpdat
                    lbsr      xnhex
setmoi              ldb       #$07                mode mask
                    tsta                          allow only 0,1,2,3,5,8,9
                    bne       setmo0
setmo1              leax      intab0,pcr
                    stx       aintab,u
                    leax      optab0,pcr
                    stx       aoptab,u
                    leax      suftb9,pcr
                    stx       asuftb,u
                    anda      #$01
                    bra       setmox
setmo0              cmpa      #$01
                    beq       setmo1
                    cmpa      #$02
                    bne       setmo2
                    leax      intab2,pcr
                    stx       aintab,u
                    leax      optab2,pcr
                    stx       aoptab,u
                    leax      suftb5,pcr
                    stx       asuftb,u
                    bra       setmom
setmo2              cmpa      #$03
                    beq       setmo1
                    cmpa      #$05
                    bne       setmo5
                    leax      intab5,pcr
                    stx       aintab,u
                    leax      optab5,pcr
                    stx       aoptab,u
                    leax      suftb5,pcr
                    stx       asuftb,u
                    bra       setmom
setmo5              cmpa      #$08
                    beq       setmo1
                    cmpa      #$09
                    bne       setmod
                    leax      intab9,pcr          addr 6809 table
                    stx       aintab,u            save pointer to
                    leax      optab9,pcr          addr 6809 table
                    stx       aoptab,u            save pointer to
                    leax      suftb9,pcr          addr 6809 table
                    stx       asuftb,u            save pointer to
                    lda       #$ff
                    bra       setmox
setmom              ldb       #$0f                set mask
setmox              sta       pmode,u
                    stb       modmsk,u
                    rts
**
newrng              tst       os9flx,u            set dis range
                    beq       newnos
                    tst       infile,u            chk for file
                    beq       newnos
                    lbra      badrg               can't change OS/9 disk module addr
newnos              leax      inam0,u
                    lbsr      gadrs
                    bls       newrag
                    lbsr      badrg
                    bra       newnos
newrag              ldd       inam2,u
                    std       taddr,u
                    ldx       inam0,u
                    stx       faddr,u
                    bne       newaok              check for bad range
                    cmpd      #$ffff
                    bne       newaok
                    ldd       #$fff0              fix bad upper bound
                    std       taddr,u
newaok              clr       os9flx,u            determine if OS/9 or flex
                    ldx       #$0000              clear offset
                    stx       oaddr,u
                    subd      faddr,u
                    cmpd      #objlth+3
                    lbls      sxfer               chk too short
                    leay      objhdr,u            point to header
                    ldx       faddr,u
                    stx       saddr,u
                    ldb       #objlth
newhdr              pshs      b
                    lbsr      getin
                    puls      b
                    sta       ,y+
                    decb
                    bne       newhdr
                    leax      objhdr,u
                    ldd       M$ID,x              chk second byte of header
                    cmpd      #M$ID12             $87CD
                    lbne      sxfer
                    ldy       M$Size,x            chk module length
                    lbeq      sxfer
                    cmpy      M$Name,x            chk name offset > length
                    lblo      sxfer
                    cmpy      M$Exec,x
                    lbls      sxfer               chk xfer > length
                    exg       d,y
                    addd      M$Mem,x             was m$stak,x
                    exg       d,y
                    lbcs      sxfer               chk prog + data > 65k
                    ldb       M$Type,x
                    andb      #LangMask           was lanmsk chk language
                    cmpb      #Objct
                    lbne      sxfer
                    ldb       ,x+                 chk header parity
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    comb
                    bne       sxfer
                    ldy       ,x++                get xfer addr
                    sty       xaddr,u             set xfer addr
                    ldx       faddr,u             get module start addr
                    stx       oaddr,u             set offset addr
                    ldx       #$0000
                    stx       faddr,u             set start addr
                    ldx       obsize,u
                    leax      -$04,x
                    stx       taddr,u
                    dec       os9flx,u            set OS/9 flag
                    lbsr      xcrlf
                    leax      endpr,u             reset table pointers
                    stx       types,u
                    stx       typem,u
                    stx       typee,u
                    lbsr      dmptae              print table
                    ldx       obstor,u            chk storage size
                    beq       newstx
                    lbsr      xouts
                    leax      ldata,pcr           storage
                    lbsr      xpdat
                    leax      lstar,pcr           x-->" start="
                    lbsr      xpdat
                    ldx       #$0000
                    pshs      x
                    tfr       s,x
                    lbsr      xot4h               xxxx
                    leax      lendr,pcr           x-->" end="
                    lbsr      xpdat
                    ldx       obstor,u
                    leax      -$01,x
                    stx       ,s
                    tfr       s,x
                    lbsr      xot4h               xxxx
                    puls      x
newstx              rts
**
sxfer               tst       os9flx,u            chk for OS/9
                    lbne      badrg               can't change OS/9 xfer addr
                    leax      lxfer,pcr           set xfer addr
                    lbsr      xpdat
                    lbsr      xbadr
sxfet               stx       xaddr,u
                    rts
**
oload               tst       os9flx,u            set load offset
                    lbne      badrg               can't change OS/9 offset
                    leax      offil,pcr
                    lbsr      xpdat
                    lbsr      xouts
                    lbsr      xbadr
                    stx       oaddr,u
                    rts
**
fexit               lbsr      xinee               exit
fexeof              leax      clrscn,pcr
                    lbsr      outcur
                    bsr       fmsclo
                    lbsr      lastty              reset tty parameters
                    ldd       #$0000
                    os9       F$Exit              exit
**
doscom              lbsr      stopin              send message to OS/9
                    lbsr      xouts               print prompt
                    lda       #$2b                a "+" sign
                    lbsr      xoute
                    lbsr      xoute
                    lbsr      xoute
                    sts       stkadr,u
                    ldx       typee,u
                    clr       ,x+
                    lbsr      inbufd              get input line
                    cmpa      #$0d
                    beq       doscox              skip if null
                    lda       #$03
                    sta       escswt,u            set escape switch
                    pshs      x
                    lbsr      lastty              reset tty parameters
                    puls      x
                    bsr       doxcom              call OS/9
doscoy              lbsr      fixesc              restore escape
                    lbsr      initty              set up tty parametes
doscox              clr       escswt,u
                    rts
**
fmsclo              leax      prblok,u            close open files
                    lbsr      fob
fmscl0              tst       disif,u             check input file
                    beq       fmscl1
                    clr       infile,u
                    lda       inblok+iobfd+1,u
                    os9       I$Close
                    bcc       fmscl1
                    lda       #$02                error
                    leax      errirz,pcr
                    ldy       #errirl
                    os9       I$WritLn
fmscl1              lbsr      ende3               close printer and disk
fmsclx              rts
**
doxcom              equ       *                   call OS/9
                    sts       saves,u             remember stack
                    pshs      x,y,u               set up fork
                    tfr       x,u                 parameter area
                    tfr       x,y
doxpas              tst       ,y+                 check for end
                    bne       doxpas
                    ldd       #$0d0d              cr cr
                    std       -$01,y
                    tfr       y,d
                    subd      ,s
                    tfr       d,y                 parameter area size
                    leax      vshell,pcr          "shell"
                    clra                          language/type
                    clrb                          size
                    os9       F$Fork              spawn new task
                    puls      x,y,u
                    bcs       doxcer              check for error
                    pshs      a                   save new id
doxcwt              os9       F$Wait              wait for child task
                    bcs       doxcer
                    cmpa      ,s                  right task?
                    bne       doxcwt              wait some more if not
                    puls      a                   restore child task id
                    tstb                          check for child task error
                    beq       doxcox              exit
doxcer              lda       #$02                error path
                    os9       F$PErr
doxcox              lds       saves,u             recall stack
                    rtsox     lds                 saves,u recall stack
