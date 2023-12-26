_bdos               lda       <C
                    cmpa      #$02
                    lbeq      C_WRITE
                    cmpa      #$06
                    lbeq      C_RAWIO
                    cmpa      #$09
                    lbeq      C_WRITESTR
                    cmpa      #$01
                    lbeq      C_READ
                    cmpa      #$0a
                    lbeq      C_READSTR
                    cmpa      #$1A
                    lbeq      _SETDTA
                    cmpa      #$21
                    lbeq      _RDRND
                    cmpa      #$22
                    lbeq      _WRRND
                    cmpa      #$0f
                    lbeq      _FOPEN
                    cmpa      #$0e
                    lbeq      @LAZero
                    cmpa      #$10
                    lbeq      _FCLOSE
                    cmpa      #$11
                    lbeq      _SFIRST
                    cmpa      #$12
                    lbeq      _SNEXT
                    cmpa      #$13
                    lbeq      _DELETE
                    cmpa      #$14
                    lbeq      _RDSEQ
                    cmpa      #$15
                    lbeq      _WRSEQ
                    cmpa      #$16
                    lbeq      _FMAKE
                    cmpa      #$17
                    lbeq      _RENAME
                    cmpa      #$19
                    lbeq      _CURDRV
                    cmpa      #$0C
                    lbeq      S_BDOSVER
                    cmpa      #$00
                    lbeq      _CBOOT
                    bra       @AZero
@LAZero             clr       <L
@AZero              clr       <A
@end                rts

BIOSTBL2
                    lbra      _CBOOT
                    lbra      _WBOOT
                    lbra      _CONST
                    lbra      _CONIN
                    lbra      _CONOUT
                    lbra      _LIST
                    lbra      _PUNCH
                    lbra      _READER
                    lbra      _HOME2
                    lbra      _SELDSK
                    lbra      _SETTRK
                    lbra      _SETSEC
                    lbra      _SETDMA
                    lbra      _READ2
                    lbra      _WRITE


_bios               leax      BIOSTBL2,pcr
                    jmp       d,x


C_WRITESTR          ldx       <DE
                    pshs      x
                    ldy       #0
@loop               lda       ,x+
                    leay      1,y
                    cmpa      #'$
                    bne       @loop
                    puls      x
                    leay      -1,y
                    lda       #stdout
                    os9       I$Write
                    rts

_CURDRV             lda       #$00                ; default A: drive
                    sta       <A
                    clr       <L
                    rts

_SETDTA
                    ldx       <DE
                    stx       <dta
                    rts

_parsefn            pshs      a,b,y
                    ldb       #8
@loop               lda       ,y+
                    cmpa      #$20
                    beq       @next
                    sta       ,x+
@next               decb
                    bne       @loop
                    lda       ,y
                    cmpa      #20
                    beq       _parsend
                    lda       #'.
                    sta       ,x+

                    ldb       #3
@loop               lda       ,y+
                    cmpa      #$20
                    beq       @next
                    sta       ,x+
@next               decb
                    bne       @loop
_parsend            clr       ,x
                    puls      a,b,y,pc

_unparsefn          pshs      a,b,x,y
                    pshs      x
                    lda       #$20
                    ldb       #11
@clean              sta       ,x+
                    decb
                    bne       @clean
                    puls      x

                    ldb       #8
@loop               lda       ,y+
                    cmpa      #'.
                    beq       @dot
                    cmpa      #$ae
                    beq       @end
@cont               pshs      a
                    anda      #$7f
                    sta       ,x+
                    puls      a
                    bita      #$80
                    bne       @end
                    decb
                    bne       @loop
                    lda       ,y+
                    bita      #$80
                    bne       @end
@dot                leax      b,x
                    ldb       #3
                    bra       @loop
@end                puls      a,b,x,y,pc

Rename              fcc       "RENAME"
                    fcb       C$CR

_RENAME             ldy       <DE
                    leay      1,y
                    leax      filename,u
                    lbsr      _parsefn
                    lda       #$20
                    sta       ,x+
                    pshs      x
                    leay      16,y
                    lda       #0
                    sta       11,y
                    puls      x
                    lbsr      _parsefn
                    lda       #C$CR
                    sta       ,x++
                    leay      filename,u
                    sty       <TMP1
                    tfr       x,d
                    subd      <TMP1
                    tfr       d,y
                    leax      <Rename,pcr
                    lda       #Prgrm+Objct
                    clrb
                    pshs      u
                    leau      <filename,u
                    os9       F$Fork
                    puls      u
                    lbcs      _ferror
                    os9       F$Wait
                    lbcs      _ferror
                    lbra      _fok



_DELETE
                    ldy       <DE
                    leay      1,y
                    leax      filename,u
                    lbsr      _parsefn
                    leax      filename,u
                    os9       I$Delete
                    bcs       _ferror
                    ldx       <DE
                    clr       S1,x                ; S1
                    clr       <A
                    clr       <L
                    rts


_FMAKE
                    ldy       <DE
                    leay      1,y
                    leax      filename,u
                    lbsr      _parsefn
                    leax      filename,u
                    lda       #UPDAT.
                    ldb       #$0b
                    os9       I$Create
                    bcs       _ferror
                    ldx       <DE
                    sta       S1,x                ; S1
                    clr       <A
                    clr       <L
                    rts


_FOPEN
                    ldy       <DE
                    leay      1,y
                    leax      filename,u
                    lbsr      _parsefn
                    leax      filename,u
                    lda       #UPDAT.
                    os9       I$Open
                    bcs       _ferror
                    ldx       <DE
                    sta       S1,x                ; S1
                    clr       S2,x
_fok                clr       <A
                    clr       <L
                    rts

_ferror             lda       #$ff
                    sta       <A
                    sta       <L
                    rts

_FCLOSE
                    ldx       <DE
                    lda       S1,X
                    os9       I$Close
                    clr       S1,x
                    clr       S2,x
                    clr       EX,x
                    clr       CR,x
                    bcs       _ferror
                    lbra      _fok


_mkrnd
                    ldd       #0
                    std       <seekpos
                    std       <seekpos+2
                    ldb       R0,x
                    lda       R1,x
                    clr       <TMP0
                    lsra
                    rorb
                    std       <TMP0+1
                    ldb       #0
                    rorb
                    stb       <TMP1+1
                    ldd       <TMP1
                    addd      <seekpos+2
                    std       <seekpos+2
                    ldd       <TMP0
                    adcb      <seekpos+1
                    adca      <seekpos
                    std       <seekpos
                    lbsr      _unmakespos
                    rts


_isopen             ldx       <DE
                    tst       S1,X
                    bne       @isopen
                    lbsr      _FOPEN
@isopen             rts

_RDRND              bsr       _isopen
                    bsr       _mkrnd
                    lda       S1,x
                    ldx       <seekpos
                    pshs      u
                    ldu       <seekpos+2
                    os9       I$Seek
                    puls      u
                    lbcs      _serror
                    ldx       <dta
                    ldy       #128
                    os9       I$Read
                    bcs       @rderror
                    clr       <A
                    clr       <L
                    cmpy      #128
                    lbne      _fill
                    rts
@rderror            lda       #$01
                    sta       <A
                    sta       <L
                    rts


_WRRND              lbsr      _isopen
                    lbsr      _mkrnd
                    lda       S1,x
                    ldx       <seekpos
                    pshs      u
                    ldu       <seekpos+2
                    os9       I$Seek
                    puls      u
                    lbcs      _serror
                    ldx       <dta
                    ldy       #128
                    os9       I$Write
                    lbcs      _werror
@rok                clr       <A
                    clr       <L
                    rts
_serror             lda       #$06
@set                sta       <A
                    sta       <L
                    rts
_werror             cmpa      #E$PthFul
                    bne       @isfull
                    lda       #5
                    bra       @set
@isfull             cmpa      #E$Full
                    bne       @generic
                    lda       #2
                    bra       @set
@generic            lda       #$ff
                    bra       @set
_rerror             cmpa      #E$EOF
                    lda       #6
                    bra       @set
                    bne       @generic

_unmakespos
                    ldd       <seekpos
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    sta       S2,x
                    ldd       <seekpos+1
                    anda      %00000111
                    andb      %11000000
                    aslb
                    rola
                    aslb
                    rola
                    sta       EX,x
                    ldd       <seekpos+2
                    anda      #$3f
                    aslb
                    rola
                    sta       CR,x
                    rts


_makespos           ldd       #0
                    std       <seekpos
                    std       <seekpos+2
; S2             EX          CR
; 1100 0001 | 0001 1001 | 0110 0001
;	           S2	       EX       CR
;  0000 0|110  : 0000 1|110 : 01|11 0000 : 1|000 0000
;    seekpos		+1	        +2           +3
                    ldb       S2,x
                    lda       #8
                    mul
                    std       <seekpos
                    lda       EX,x
                    clrb
                    asra
                    rora
                    asra
                    rora
                    ora       <seekpos+1
                    sta       <seekpos+1
                    stb       <seekpos+2
                    lda       #128
                    ldb       CR,x
                    mul
                    ora       <seekpos+2
                    sta       <seekpos+2
                    stb       <seekpos+3
                    rts

_increc             lbsr      _makespos
                    ldd       <seekpos+2
                    addd      #128
                    std       <seekpos+2
                    ldd       <seekpos
                    adcb      #0
                    adca      #0
                    std       <seekpos
                    lbsr      _unmakespos
                    rts

_RDSEQ              lbsr      _isopen
                    lbsr      _makespos
                    lda       S1,x
                    ldx       <seekpos
                    pshs      u
                    ldu       <seekpos+2
                    os9       I$Seek
                    puls      u
                    lbcs      @serror
                    ldx       <dta
                    ldy       #128
                    os9       I$Read
                    lbcs      @rerror
                    ldx       <DE
                    bsr       _increc
                    clr       <A
                    clr       <L
                    cmpy      #128
                    lbne      _fill
                    rts
@rerror             lda       #$01                ; end of file
                    bra       @end
@serror             lda       #$09                ; invalid FCB
@end                sta       <A
                    sta       <L
                    rts

_fill               ldx       <dta
                    tfr       y,d
                    leax      d,x
                    stb       <TMP0
                    ldb       #128
                    subb      <TMP0
                    lda       #$1A
@loop               sta       ,x+
                    decb
                    bne       @loop
                    rts

_WRSEQ              lbsr      _isopen
                    lbsr      _makespos
                    lda       S1,x
                    ldx       <seekpos
                    pshs      u
                    ldu       <seekpos+2
                    os9       I$Seek
                    puls      u
                    lbcs      @serror
                    ldx       <dta
                    ldy       #128
                    os9       I$Write
                    lbcs      @werror
                    ldx       <DE
                    lbsr      _increc
                    clr       <A
                    clr       <L
                    rts
@werror             lda       #$02                ; disc full
                    bra       @end
@serror             lda       #$09                ; invalid FCB
@end                sta       <A
                    sta       <L
                    rts

_CBOOT
_WBOOT              lbra      _exit


_findnext
@nextentry          lda       <dirpath
                    ldy       #32
                    leax      <args,u
                    os9       I$Read
                    lbcs      @error
                    cmpy      #0
                    beq       @error
                    tst       <args
                    beq       @nextentry
                    leax      filename,u
                    leay      args,u
                    cmpa      ,x
                    beq       @error
@nextchar           lda       ,x+
                    beq       @hasfound
                    cmpa      #'?
                    beq       @joker
                    ldb       ,y+
                    andb      #$7f
                    stb       <TMP0
                    cmpa      <TMP0
                    bne       @nextentry
                    bra       @nextchar
@joker              ldb       ,y+
                    bitb      #$80
                    bne       @hasfound
                    cmpb      #'.
                    bne       @nextchar
                    leay      -1,y
                    bra       @nextchar
@hasfound           ldb       ,-y
                    bitb      #$80
                    beq       @nextentry
                    clra
                    rts
@error              clra
                    coma
                    rts

curdir              fcn       "."


_SFIRST             ldy       <DE
                    leay      1,y
                    leax      filename,u
                    pshs      x
                    lbsr      _parsefn
                    puls      x
                    lda       <dirpath
                    beq       @open
                    os9       I$Close
@open               leax      curdir,pcr
                    lda       #DIR.+READ.
                    os9       I$Open
                    lbcs      @error
                    sta       <dirpath
                    ldx       #0
                    pshs      u
                    ldu       #$40
                    os9       I$Seek
                    puls      u
                    lbcs      @error
                    lbsr      _findnext
                    bcs       @error
                    ldx       <dta
                    lda       #1
                    sta       ,x+
                    leay      <args,u
                    lbsr      _unparsefn
                    clr       <A
                    clr       <L
                    rts
@error              lda       #$ff
                    sta       <A
                    sta       <L
                    rts

_SNEXT              lbsr      _findnext
                    bcs       @error
                    ldx       <dta
                    lda       #1
                    sta       ,x+
                    leay      <args,u
                    lbsr      _unparsefn
                    clr       <A
                    clr       <L
                    rts
@error              lda       #$ff
                    sta       <A
                    sta       <L
                    rts



C_WRITE             lda       <E
                    leax      <E,u
                    lbra      __CONOUT


_CONST
                    lda       #stdin
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcs       @nready
                    cmpb      #0
                    beq       @nready
                    clr       <A
                    com       <A
                    rts
@nready             clr       <A
                    rts

C_READSTR
                    lbsr      _echo_on
                    ldx       <DE
                    bne       @bufOK
                    ldx       <dta
@bufOK              ldb       ,x++
                    clra
                    tfr       d,y
                    lda       #stdin
                    os9       I$ReadLn
                    tfr       y,d
                    decb
                    stb       -1,x
                    lbsr      _echo_off
                    rts

S_BDOSVER           ldd       #$0022
                    sta       <B
                    sta       <H
                    stb       <A
                    stb       <L
                    rts


_CONIN
                    ldb       <sgn_code
                    cmpb      #S$Abort
                    bne       @read
                    clr       <sgn_code
                    lda       #$05
                    sta       <A
                    sta       <L
                    rts
@read
                    lda       #stdin
                    ldy       #1
                    leax      <A,u
                    os9       I$Read
                    bcs       @esc
                    lda       <A
                    sta       <L
                    rts
@esc                lda       #$1b
                    sta       <A
                    sta       <L
                    rts

C_READ              bsr       _CONIN
                    lda       <A
                    leax      <A,u
                    bra       __CONOUT

C_RAWIO             lda       <E
                    cmpa      #$fe
                    beq       _CONST
                    cmpa      #$fd
                    beq       @read
                    cmpa      #$ff
                    beq       @sense
*			lda     <E
                    sta       <A
                    leax      <A,u
                    bra       __CONOUT
@read
                    lda       <L
                    pshs      a
                    bsr       C_READ
                    puls      a
                    sta       <L
                    rts
@sense
                    lbsr      _CONST
                    tst       <A
                    beq       @end
                    lda       <L
                    pshs      a
                    lbsr      _CONIN
                    puls      a
                    sta       <L
@end                rts


_putchar            lda       #stdout
                    ldy       #1
                    os9       I$Write
                    clr       <escmode
                    rts
@kaypro             lbra      _KAYPRO
@esc                clr       <escmode
                    com       <escmode
                    rts
@putchar            cmpa      #$01
                    bne       _putchar
@curright           clr       <escmode
                    ldb       #$06
                    stb       <escmode
                    leax      escmode,u
                    bra       _putchar
_CONOUT             lda       <C
                    leax      <C,u
__CONOUT            ldb       <term
                    cmpb      #'N
                    beq       _putchar            ; native term
                    cmpa      #$1b                ; esc ?
                    beq       @esc
                    cmpb      #'K
                    lbeq      _KAYPRO             ; kaypro term ?
                    ldb       <escmode            ; vt-52
                    beq       @putchar
                    cmpb      #3
                    lbeq      @movecurY
                    cmpb      #2
                    lbeq      @movecurX
                    cmpa      #'Y
                    lbeq      @movecur
                    cmpa      #'A
                    beq       @curup
                    cmpa      #'B
                    beq       @curdown
                    cmpa      #'C
                    lbeq      @curright
                    cmpa      #'D
                    beq       @curleft
                    cmpa      #'E
                    lbeq      @cls
                    cmpa      #'H
                    lbeq      @home
                    cmpa      #'K
                    lbeq      @delrest
                    cmpa      #'L
                    lbeq      @insline
                    cmpa      #'M
                    lbeq      @delline
                    cmpa      #'J
                    lbeq      @delscreen
                    cmpa      #'q
                    lbeq      @ignore             ; _revoff
                    cmpa      #'p
                    lbeq      @ignore             ; _revon
                    cmpa      #'e
                    lbeq      @curon
                    cmpa      #'f
                    lbeq      @curoff
                    lbra      @ignore
@home               clr       <escmode
                    lbra      _home
@cls                clr       <escmode
                    lbra      _cls
@curon              clr       <escmode
                    lbra      _curon
@curoff             clr       <escmode
                    lbra      _curoff
@delline            clr       <escmode
                    lbra      _delline
@insline            clr       <escmode
                    lbra      _insline
@curup              clr       <escmode
                    ldb       #$09
                    stb       <escmode
                    leax      escmode,u
                    lbra      _putchar
@curdown            clr       <escmode
                    ldb       #$0a
                    stb       <escmode
                    leax      escmode,u
                    lbra      _putchar
@curleft            clr       <escmode
                    ldb       #$08
                    stb       <escmode
                    leax      escmode,u
                    lbra      _putchar
@movecur            ldb       #3
                    stb       <escmode
                    rts
@movecurY           sta       <escmode+2
                    dec       <escmode
                    rts
@movecurX           sta       <escmode+1
                    leax      escmode,u
                    lda       #stdout
                    ldy       #3
                    os9       I$Write
                    clr       <escmode
                    rts
@delrest            ldb       #$04
                    stb       <escmode
                    leax      escmode,u
                    lbra      _putchar
@delscreen          ldb       #$0B
                    stb       <escmode
                    leax      escmode,u
                    lbra      _putchar
@ignore             clr       <escmode
                    rts
_KAYPRO
                    ldb       <escmode
                    bne       @kaycodes
                    cmpa      #$20
                    bcs       @nonchar
@putc               lda       #stdout
                    ldy       #1
                    os9       I$Write
                    clr       <escmode
                    rts
@nonchar            cmpa      #8
                    lbeq      @curleft
                    cmpa      #10
                    lbeq      @curdown
                    cmpa      #11
                    lbeq      @curup
                    cmpa      #12
                    lbeq      @curright
                    cmpa      #26
                    lbeq      _cls
                    cmpa      #23
                    lbeq      @delscreen
                    cmpa      #24
                    lbeq      @delrest
                    cmpa      #30
                    lbeq      @home
                    bra       @putc
@kaycodes
                    cmpb      #3
                    lbeq      @movecurY
                    cmpb      #2
                    lbeq      @movecurX
                    cmpb      #'B
                    lbne      @isClear
                    cmpa      #'4
                    lbeq      @curon
                    lbra      @ignore
@isClear            cmpb      #'C
                    lbne      @cont
                    cmpa      #'4
                    lbeq      @curoff
                    lbra      @ignore
@cont               cmpa      #'E
                    lbeq      @insline
                    cmpa      #'R
                    lbeq      @delline
                    cmpa      #'=
                    lbeq      @movecur
                    cmpa      #'B
                    bne       @isC
                    sta       <escmode
                    rts
@isC                cmpa      #'C
                    lbne      @ignore
                    sta       <escmode
                    rts

_LIST
_PUNCH
_READER
_HOME2
_SELDSK
_SETTRK
_SETSEC
_SETDMA
_READ2
_WRITE              rts
