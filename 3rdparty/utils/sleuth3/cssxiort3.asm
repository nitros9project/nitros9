
***************************************
**
xbadr               bsr       xbyte               input four hex char into x
                    sta       baddr,u
                    bsr       xbyte
                    sta       baddr+1,u
                    ldx       baddr,u
                    rts
**
xbyte               pshs      b                   input 2 hex char into a
                    lbsr      xnhex
                    asla
                    asla
                    asla
                    asla
                    pshs      a
                    lbsr      xnhex
                    adda      ,s+
                    puls      b,pc
**
xinee               lda       #$01                normal input (getchr)
                    sta       escswt,u
                    sts       saves,u
                    bsr       xinpt
                    clr       escswt,u
                    rts
**
xinpt               pshs      b,x,y               input one char to a
                    tst       getfl,u             chk get flag
                    beq       xinen
xinpg               leax      axblok,u            get a char from disk
                    lbsr      gnc
                    bcs       xinpe               chk error
                    bvs       xineo               chk eof
                    bra       xineg               ok
xinpe               lda       #$02                error
                    leax      errarz,pcr
                    ldy       #errarl
                    os9       I$WritLn
xineo               lbsr      stopin              reset get flag
                    lda       #$0d                cr for eof
xineg               anda      #$7f                strip parity
                    cmpa      #$0d                chk cr
                    beq       xinef
                    cmpa      #$20                chk printable
                    bls       xinpg               ignore cntrl
                    cmpa      #maxprn
                    bhi       xinef
                    lbsr      xoutet              echo input
                    bra       xinef
xinen               leax      toblok,u            from terminal
                    lbsr      fob                 force output
                    leax      tiblok,u
                    lbsr      gnc
                    bcs       xinep               chk error
                    bvs       xineq               chk eof
                    bra       xinek               ok
xinep               lda       #$02                error
                    leax      errirz,pcr
                    ldy       #errirl
                    os9       I$WritLn
                    bra       xineq
xinek               cmpa      #$03                chk ctrl-c
                    bne       xinef
                    tst       scfwkg+PD.EKO-PD.OPT,u chk for screen I/O
                    beq       xinef
                    tst       noecho,u            chk echo flag
                    bne       xinef
                    clr       escswt,u
                    lbra      askin
xineq               clr       escswt,u            abort
                    lbra      fexeof              force exit
xinef               puls      b,x,y,pc            restore and return
**
xnhex               lbsr      xinee               input 1 hex char to a
xnhe9               cmpa      #$5f
                    bls       xnhe8
                    anda      #$5f                change case
xnhe8               cmpa      #$20                chk for space
                    beq       xnhex               ignore
                    suba      #$30
                    blo       xnhe2
                    cmpa      #$09
                    ble       xnhe1
                    cmpa      #$11
                    blo       xnhe2
                    cmpa      #$16
                    bgt       xnhe2
                    suba      #$07
xnhe1               rts
xnhe2               clr       escswt,u            invalid hex
                    lbsr      stopin              reset get flag
                    lbra      askin               get out
**
xpdaa               bsr       xoute
xpdat               lda       ,x+                 print to $04 from x
                    cmpa      #$04
                    bne       xpdaa
                    rts
**
xothl               lsra                          print left hex digit in a
                    lsra
                    lsra
                    lsra
**
xothr               anda      #$0f                print right hex digit in a
                    adda      #$30
                    cmpa      #$39
                    bls       xoth1
                    adda      #$07
xoth1               bra       xoute
**
xot4h               bsr       xot2h               print 4 hex char from x
**
xot2h               lda       ,x                  print 2 hex char from x
                    bsr       xothl
                    lda       ,x+
                    bra       xothr
**
xot4s               bsr       xot2h               print 4 hex from x & space
**
xot2s               bsr       xot2h               print 2 hex from x & space
**
xouts               lda       #$20                print 1 space
**
xoute               pshs      d,x,y               normal output (putchr)
                    ldb       #$02                set escape switch
                    stb       escswt,u
                    sts       saves,u
                    bsr       xoutp
xoutex              clr       escswt,u
                    puls      d,x,y,pc
**
xcrlf               clr       column,u            crlf
                    lda       #$0d                cr
                    bra       xoute
**
xoutp               pshs      d                   output char in a
                    tst       noecho,u            chk echo flag
                    bne       xotpx
                    tsta
                    beq       xotpx               nulls
                    anda      #$7f
                    cmpa      #$20                chk for cntl
                    blo       xotpd
                    inc       column,u            count printables
xotpa               bsr       xouted              output to disk
xotpb               lbsr      xoutep              output to printer
xotpc               lbsr      xoutet              output to terminal
                    bra       xotpx
xotpd               cmpa      #$0d                chk cr
                    bne       xotpe
                    clr       column,u            clear column number
                    bra       xotpa
xotpe               tsta                          chk ctrls
                    beq       xotpb               nulls ($80)
                    cmpa      #$0a                chk lf
                    beq       xotpc
                    cmpa      #$07                chk bell
                    beq       xotpc
                    bpl       xotpx               other cntls
                    ldb       #$05                chk tabs
                    deca
                    beq       xotpt
                    ldb       #$11
                    deca
                    beq       xotpt
                    ldb       #$17
                    deca
                    beq       xotpt
                    ldb       #$21
                    deca
                    beq       xotpt
                    deca
                    beq       xotpt
                    ldb       #$2e
xotpt               lda       #$20                space
xotpu               inc       column,u
                    lbsr      xoutep
                    bsr       xoutet
                    cmpb      column,u
                    bhi       xotpu
                    bsr       xouted
xotpx               puls      d,pc
**
xouted              tst       dskfl,u             output to disk
                    beq       xoutxd
                    pshs      d,x
                    ldb       comand,u
                    cmpb      #$44                chk d
                    bne       xoutdo
                    cmpa      #$0d                cr
                    beq       xoutdo
                    ldb       column,u
                    cmpb      #$12                chk column
                    blo       xoutdx
xoutdo              leax      otblok,u            put a char
                    lbsr      pnc
                    bcc       xoutdx              chk error
                    lda       #$02                error
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
                    clr       dskfl,u             stop disk output
                    ldb       comand,u
                    cmpb      #$44                chk d
                    bne       xoutdx
                    lds       stkadr,u            abort
                    lbra      ende3
xoutdx              puls      d,x
xoutxd              rts
**
xoutet              pshs      d,x                 output to terminal
                    tst       confl,u
                    beq       xoutxt
                    leax      toblok,u            terminal output
                    lbsr      pnc
                    bcc       xouttx
                    lda       #$02                error
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
                    lbsr      ende3               close files
                    lbsr      stopin              stop auxiliary input
                    clr       escswt,u
                    lbra      askin               abort
xouttx              cmpa      scfwkg+PD.EOR-PD.OPT,u cr
                    bne       xoutxt
                    lbsr      fob
xoutxt              puls      d,x,pc
**
xoutep              pshs      d,x                 output to terminal
                    tst       prtfl,u
                    beq       xoutxp
                    leax      prblok,u            printer output
                    lbsr      pnc
                    bcc       xoutpx
                    lda       #$02                error
                    leax      errprz,pcr
                    ldy       #errprl
                    os9       I$WritLn
                    lbsr      ende3               close files
                    lbsr      stopin              stop auxiliary input
                    clr       escswt,u
                    lbra      askin               abort
xoutpx              cmpa      scfwkg+PD.EOR-PD.OPT,u cr
                    bne       xoutxp
                    lbsr      fob                 force output
xoutxp              puls      d,x,pc
**
xcrlr               tst       escswt,u            esc return point
                    bne       xcrrr
xcrlra              leax      xcrlrb,pcr
                    stx       $0a,s
                    clr       escswt,u            reset escape switch
                    rti
xcrlrb              lbsr      fixesc              fix escape
                    lbra      askin               esc from most places
xcrrr               dec       escswt,u
                    bne       xcrr2
                    leax      xcrrra,pcr
                    stx       $0a,s
                    rti
xcrrra              lbsr      fixesc              fix escape
                    lbra      askin               esc from input
xcrr2               dec       escswt,u
                    bne       xcrr3
                    tst       phase,u             check phase
                    beq       xcrr2b
                    clr       confl,u             reset terminal flag
                    leax      xcrr2a,pcr          abort
                    stx       $0a,s
                    rti
xcrr2a              lbsr      fixesc              fix escape
                    lds       stkadr,u            reset stack
                    lbra      ende3               close files
xcrr2b              lbra      xoutex              esc from output
xcrr3               dec       escswt,u
                    bne       xcrlra
                    leax      xcrr3a,pcr          abort
                    stx       $0a,s
                    rti
xcrr3a              lbsr      fixesc              fix escape
                    lds       stkadr,u            reset stack
                    lbra      doscoy              esc from OS/9 call
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
gnc                 pshs      b,y
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
gncrw               tsta                          check for terminal read
                    bne       gncrt
                    ldy       #$0001              one byte only
gncrt               os9       I$Read              reload buffer raw
gncrd               puls      x
                    bcs       gnc4                if error
                    sty       iobcc,x             save char count
                    beq       gnc3                if eof
                    ldd       iobba,x             reset char pointer
                    std       iobca,x
                    ldd       iobcc,x             d=char count
gnc1                subd      #$0001              count chars
                    std       iobcc,x
                    leay      inblok,u            chk for macro file
                    pshs      y
                    cmpx      ,s++
                    bne       gnc2
                    ldd       inlrec+1,u          compute relative byte address
                    addd      #$0001
                    std       inlrec+1,u
                    lda       inlrec,u
                    adca      #$00
                    sta       inlrec,u
gnc2                ldy       iobca,x             get char
                    lda       ,y+
                    sty       iobca,x             update char pointer
                    clrb                          cc, vc
                    puls      b,y,pc
gnc3                orcc      #$02                vs for eof
                    puls      b,y,pc
gnc4                cmpb      #E$EOF              check error
                    beq       gnc3                for eof
                    orcc      #$01                cs
                    leas      $01,s               remove b
                    puls      y,pc                cs, d=error
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
*puls y,pc cs, d=error
