                    nam       Basic09Runtime

                    ifp1
                    use       defsfile
                    endc

* RunB from BASICBOOST from Chris Dekker - 6309'ized version of RunB
* Created a proper jump table at L204 R.G. 03/05/13

edition             equ       1
membase             equ       $00
memsize             equ       $02
moddir              equ       $04
ResTop              equ       $08                 top of reserved space
freemem             equ       $0C
table1              equ       $0E
table2              equ       $10
table3              equ       $12
table4              equ       $14
extnum              equ       $18
Vsys                equ       $20
Vinkey              equ       $22
holdnum             equ       $25
errpath             equ       $2E
PGMaddre            equ       $2F                 starting address program
WSbase              equ       $31                 base address workspace
errcode             equ       $36
DATApoin            equ       $39                 address DATA item
VarAddr             equ       $3C                 address of variable
fieldsiz            equ       $3E                 it's max. size
ArrBase             equ       $42
SStop               equ       $44                 top of string space area
userSP              equ       $46                 subroutine stackpointer
exprSP              equ       $48                 current expression
exprBase            equ       $4A                 expr.stack's base
callex              equ       $5D
callcode            equ       $5F
VarPtrba            equ       $62
vectorba            equ       $66
excoffse            equ       $6A                 module exec.offset
excEnd              equ       $6C
expneg              equ       $75
digits              equ       $76
decpoint            equ       $77
negativ             equ       $78
decimals            equ       $79
charcoun            equ       $7D                 length output string
IOpath              equ       $7F
Sstack              equ       $80                 start of current string
Spointer            equ       $82                 end of current string
subrcode            equ       $85
fieldwid            equ       $86
justify             equ       $87
BUPaddr             equ       $FB
BUPsize             equ       $FD

MODMEM              equ       $2000

                    mod       MODEND,MODNAM,Prgrm+Objct,$82,ENTRY,MODMEM

MODNAM              fcs       /RunB/
                    fcb       edition

* interrupt processing *
L93                 lda       5,s                 native mode
                    bra       L95

L94                 lda       3,S                 emulation mode
L95                 tfr       A,DP
                    stb       <$35
*          oim   #$80,<$34
                    fcb       1,$80,$34
                    rti

*  Check for processor type?
procID              pshs      d
                    comd                          Will only do COMA on 6809
                    cmpb      1,s
                    beq       L6809
                    puls      pc,d

L6809               leax      <L6810,pc
                    lbsr      prnterr
                    clrb
                    os9       F$Exit

L6810               fcc       /  6809 detected: can not proceed/
                    fcb       10,10,13

*  adjust parameter format *
chprm               tfr       x,y
                    lbsr      skpblank
                    leax      -256,x
                    ldb       #2
L133                lda       ,y+
                    sta       ,x+                 copy mod.name
                    incb
                    cmpa      #32                 Space?
                    bne       L133
                    ldf       #$28                '('
                    stf       ,x+
                    ldf       #$2C                ,
L136                clre
                    lbsr      skpblank
                    lbsr      ISnum
                    bcc       L135                number
                    lde       #$22                "
                    ste       ,x+                 string
                    incb
L135                lda       ,y+
                    cmpa      #34                 " ??
                    beq       L135                skip it
                    incb
                    cmpa      #13
                    beq       L139                end of list
                    cmpa      #32                 space ??
                    bne       L138
                    bsr       quote               yes!!
                    stf       ,x+
                    bra       L136                check if string

L138                sta       ,x+
                    bra       L135

L139                bsr       quote
                    ldf       #$29                )
                    stf       ,x+
                    sta       ,x                  new string complete
                    ldw       -2,x                Get last 2 chars
* NOTE: Was originally CMPW >$2829, changed since seemed wrong
*           cmpw  #'(*256+')     Just ()?
                    cmpw      $2829
                    bne       L141                No, go process parameters
                    leax      -2,x
                    sta       ,x                  delete empty string
                    subb      #2
L141                clre
                    tfr       b,f                 string length
                    leay      -1,y
                    tfm       x-,y-               copy -> org. position
                    leax      1,y
                    rts

quote               tste
                    beq       L137
                    ste       ,x+
                    incb
L137                rts

ENTRY               lbsr      procID              check processor
                    tfr       u,d
                    ldw       #256
                    clr       ,-s
                    tfm       s,u+
                    leau      ,X
                    std       membase
                    inca
                    sta       <$D9
                    std       Sstack
                    std       Spointer
                    inca
                    inca
                    std       userSP
                    std       SStop
                    inca
                    tfr       D,S
                    std       moddir
                    inca
                    std       ResTop
                    std       exprBase
                    tfr       x,y
                    lbsr      skpblank
L90                 lda       ,y+
                    cmpa      #32
                    beq       L89
                    cmpa      #13
                    beq       L97                 no params
                    bra       L90                 skip modulename

L89                 lbsr      skpblank
                    cmpa      #40                 left par.??
                    beq       L97                 format OK
                    lbsr      L302                check char
                    bcc       L99                 = letter or number
                    cmpa      #45                 = -
                    beq       L99
                    cmpa      #47                 = /
                    bne       L97                 do not adjust format
L99                 lbsr      chprm
L97                 tfr       X,D
                    subd      membase
                    std       memsize
                    ldb       #1                  default errpath
                    stb       <$2E
                    lda       #3                  Close all paths 4-16
L92                 os9       I$Close
                    inca
                    cmpa      #$10
                    blo       L92
                    clr       <$35
                    pshs      X,DP
                    pshs      x,y                 Setup up a stack big enough for 6309 RTI
                    pshs      u,y,x,dp,d,cc
                    leax      <ckexit,pc          Point to routine below
                    stx       10,s                Save as return address from RTI for both 6809
                    stx       12,s                & 6309 stacks
                    stw       6,s
                    rti                           Pull all regs & return

ckexit              leax      ,x                  X pointing to where it is supposed to?
                    beq       ntive               Yes, we are in native mode
                    lda       #7                  beep to signal
                    pshs      a                   emulation mode
                    leax      ,s
                    ldy       #1
                    lda       #1
                    os9       I$Write
                    leas      3,s                 clear stack
                    leax      L94,pc
                    bra       L96

ntive               leax      L93,PC
L96                 puls      dp
                    os9       F$Icpt
                    ldx       moddir
                    ldw       ResTop
                    subr      x,w
                    clr       ,-s
                    tfm       s,x+                clear module dir
                    leas      1,s
                    tfr       DP,A
                    ldb       #$50
                    leax      L1382,PC
                    ldw       #17
                    tfm       x+,d+               init RND & syscall
                    leax      L710,PC
                    stx       table1
                    leax      L1386,PC
                    stx       table2
                    leax      L1388,PC
                    stx       table3
                    lda       #$7E
                    sta       table4
                    leax      L1390,PC
                    stx       <table4+1
                    ldx       #$FFFF              init links
                    stx       Vsys
                    stx       Vinkey
                    puls      Y
                    bsr       L102
                    ldx       moddir
                    ldd       ,X
                    std       PGMaddre
                    bsr       L134
L102                leax      <L106,PC
                    puls      U
                    bsr       L108
                    pshs      U
                    clr       <$34
                    ldd       membase
                    addd      memsize
                    subd      ResTop
                    std       freemem
                    leau      2,S
                    stu       userSP
                    stu       SStop
                    leas      >-$FE,S
                    jmp       [-2,U]

err43               ldb       #$2B
L118                lbsr      PRerror
L116                lds       <$B7
                    puls      d
                    std       <$B7
ClrSstac            lde       #1
                    ste       charcoun
                    ldw       Sstack
                    stw       Spointer
                    rts

L108                ldd       <$B7
                    pshs      d
                    sts       <$B7
                    ldd       2,S
                    stx       2,S
                    tfr       D,PC
L106                bsr       L102
                    bra       BYE

* ----------------------- *
L134                lbsr      skpblank
                    lbsr      link
                    bcs       err43
                    ldx       ,X
                    stx       PGMaddre
                    lda       6,X
                    beq       L144
                    anda      #$0F
                    cmpa      #2                  B09 program?
                    bne       err51
                    bra       L148

L144                lda       <$17,X              BASIC09 program has no errors?
                    rora
                    bcs       err51               Errors, report it
L148                lbsr      L230                check prmlist
                    ldy       exprBase
                    ldb       ,Y
                    cmpb      #$3D
                    beq       err51
                    sty       excoffse
                    ldx       <$AB
                    stx       excEnd
                    ldx       PGMaddre
                    lda       <$17,X
                    rora
                    bcs       err51
                    leas      >$0102,S
                    ldd       membase
                    addd      memsize
                    tfr       D,Y
                    std       userSP
                    std       SStop
                    ldu       #0
                    stu       WSbase
                    stu       <$B3
                    inc       <$B4
                    clr       errcode
                    ldd       exprBase
                    ldx       freemem
                    pshs      X,d
                    leax      <L154,PCR
                    bsr       L108
                    ldx       exprBase
                    lbsr      L670                set up prm stack
                    lbsr      ClrSstac
                    ldx       PGMaddre
                    lbsr      L676                execute module
                    lbra      L116

L154                puls      X,d
                    std       exprBase
                    stx       freemem
                    lbra      L116

err51               ldb       #$33
                    lbra      L118

* ----------------------- *
BYE                 bsr       unlink
                    clrb
                    os9       F$Exit

*
KILL                jsr       table4
                    ldy       1,Y
                    pshs      X
                    lbsr      skpblank
                    pshs      y
                    lbsr      ISlett
                    bcs       L164                invalid string
                    leay      1,Y
L304                lda       ,Y+
                    lbsr      L302                number/letter?
                    bcc       L304
*           oim   #$80,-2,y
                    fcb       $61,$80,$3e
                    puls      y
                    bsr       L166                in moddir?
                    bcs       L164
                    ldu       ,x++                module address
                    os9       F$UnLink
* update module directory *
                    leay      -2,x
L176                ldd       ,X++
L178                std       ,Y++
                    bne       L176
                    cmpd      ,Y
                    bne       L178                clear old data
                    puls      PC,X

L164                comb
                    ldb       #$2B                error 43
                    puls      pc,x

unlink              ldy       Spointer
                    lda       #$2A                = *
                    sta       ,Y
                    sta       <$35
                    clr       PGMaddre
                    ldx       moddir
L172                ldu       ,X++                module address
                    beq       L175
                    os9       F$Unlink
                    bra       L172                next module

* clear module dir *
L175                tfr       x,w
                    ldd       moddir
                    subr      d,w                 w=length of moddir
                    tfm       x,d+
                    rts

L166                pshs      U,Y
                    ldx       moddir
L182                ldy       ,S
                    ldu       ,X++                module address
                    beq       L180                end of directory
                    ldd       4,U                 name offset
                    leau      D,U                 address of name
L184                lda       ,U+
                    eora      ,Y+
                    anda      #$DF
                    bne       L182                next module
                    tst       -1,U
                    bpl       L184                next char
                    clra                          found          it!
L186                leax      -2,X
                    puls      PC,U,d

L180                coma
                    bra       L186

link                bsr       L166
                    bcs       L188                not in mod.dir.
                    rts

L188                pshs      U,Y,X
                    ldb       1,S
                    cmpb      #$FE
                    blo       L190
                    ldb       #32                 error 32
                    lbra      L118

L190                leax      ,Y
                    clrd
                    os9       F$Link
                    bcc       L192
                    ldx       2,S                 module not in mem.
                    clrd
                    os9       F$Load
                    bcs       L194
L192                stx       2,S
                    stu       [,S]                add to moddir
L194                puls      PC,U,Y,X

PRerror             os9       F$PErr
                    rts

L650                pshs      X,d
L208                leax      <L204,PC
                    lda       ,Y+
L206                cmpa      ,X++
                    blo       L206
                    ldb       ,-X
                    jmp       B,X

*  embedded jumptable
*  do not change until L264
L204                fcb       $F2
                    fcb       LA2-*
                    fcb       $92
                    fcb       LA4-*
                    fcb       $91
                    fcb       LA2-*
                    fcb       $90
                    fcb       L210-*
                    fcb       $8f
                    fcb       LA1-*
                    fcb       $8e
                    fcb       LA2-*
                    fcb       $8d
                    fcb       LA3-*
                    fcb       $55
                    fcb       LA2-*
                    fcb       $4b
                    fcb       LA4-*
                    fcb       $3e
                    fcb       L21C-*
                    fcb       $00
                    fcb       LA4-*
LA1                 leay      3,Y
LA2                 leay      1,Y
LA3                 leay      1,Y
LA4                 bra       L208

L210                tst       ,Y+
                    bpl       L210
                    bra       L208
L21C                puls      PC,X,d

* check param list for:
                    fcb       0,7,3
L264                fcb       L272-L270,75,12,172 ,
                    fcb       L272-L270,77,12,168 (
                    fcb       L272-L270,78,12,169 )
                    fcb       L18-L270,137,12,174 "
                    fcb       L17-L270,144,6,162  .
                    fcb       0,145,6,164         $
                    fcb       L272-L270,63,2,141  %

* error: print problem statement
*   and point to error
L236                lda       #12
L252                pshs      A
                    ldx       <$A7                strip high order bits
                    lda       #$0D
L218                fcb       $62,$7f,$84
*L218       aim   #$7F,,x
                    cmpa      ,X+
                    bne       L218
                    ldx       <$A7
                    bsr       prnterr
                    ldd       <$B9
                    subd      <$A7
                    tfr       b,f
                    clre
                    ldx       <$AF
                    stx       <$AB
                    ldy       <$A7
                    lda       #$3D
                    lbsr      L222
                    lda       #$3F
                    lbsr      L222
                    lda       #$20                Bunch of spaces
                    pshs      a
                    ldx       Sstack
                    tfm       s,x+
                    ldd       #$5E0D              ^ + CR
                    std       -1,X
                    ldx       Sstack
                    bsr       prnterr
                    puls      D
                    lbsr      PRerror
                    ldx       userSP
                    stx       SStop
                    lbra      L116

prnterr             ldy       #$0100
                    lda       errpath
                    os9       I$WritLn
                    rts

**** decode parameters passed ***
L230                sty       <$A7
                    ldx       exprBase
                    stx       <$AF
                    stx       <$AB
                    inc       <$A0
                    bsr       L232
                    bsr       L234
                    clr       <$A0
                    lda       <$A3
                    cmpa      #$3F                % ??
                    bne       L236                error 12
                    lbra      L222

L234                cmpa      #$4D                ( ??
                    bne       L238                no params
L246                lbsr      L222
                    ldd       <$AB
                    bsr       L242
                    ldb       <$A4
                    cmpb      #6                  . or $ ??
                    bne       L238
                    bsr       L232
                    bsr       L244
                    beq       L246
                    pshs      A
                    bra       L248

L238                rts
L232                bsr       L242
                    ldx       <$AD
                    stx       <$AB
                    lda       <$A3
                    rts

L244                lda       <$A3
                    cmpa      #$4B                , ??
L250                rts

L254                lda       <$A3
                    cmpa      #$4E                ) ??
                    beq       L250                end of list
                    lda       #$25                error 37
L256                lbra      L252

L248                bsr       L254
                    puls      A
                    lbsr      L222
                    bra       L232

err10               lda       #$0A
                    bra       L256

L242                ldd       <$AB
                    std       <$AD
                    lbsr      skpblank
                    sty       <$B9
                    lda       ,Y
                    lbsr      ISnum
                    bcc       L262
                    leax      L264,PCR
                    lda       #$80
                    lbsr      L266                ill. chars in prmlist?
                    beq       err10               yes!!
                    ldb       ,X
                    leau      <L270,PC
                    jmp       B,U

L272                ldd       1,X
                    stb       <$A4
                    sta       <$A3
                    lbra      L222

L18                 lda       ,Y
                    lbsr      ISnum
                    bcs       L272                NO!!
                    leay      -1,Y
L262                bsr       L274
                    bne       L276
                    ldd       #$8F05
L282                sta       <$A3
                    tfr       d,w
                    clre
                    pshs      u
                    ldu       <$AB
                    addr      u,w
                    subw      exprBase
                    cmpf      #$FF
                    bcc       err13
                    tfr       d,w
                    clre
L280                sta       ,u+
                    lda       ,X+
                    decf
                    bpl       L280
                    stu       <$AB
                    puls      u
                    lda       #6
                    sta       <$A4
                    rts

L276                ldd       #$8E02
                    tst       ,X
                    bne       L282
                    ldd       #$8D01
                    leax      1,X
                    bra       L282

L270                leay      -1,Y
                    bsr       L274
                    ldd       #$9102
                    bra       L282

L274                bsr       skpblank
                    leax      ,Y
                    ldy       SStop
                    lbsr      AtoITR              string -> number
                    exg       X,Y
                    bcs       err22
                    lda       ,X+
                    cmpa      #2
                    rts

err22               lda       #$16
                    bra       L288

L17                 bsr       L272
                    bra       L290

L294                bsr       L222
L290                lda       ,Y+
                    cmpa      #$0D
                    beq       err41
                    cmpa      #$22                " ??
                    bne       L294
                    cmpa      ,Y+
                    beq       L294
                    leay      -1,Y
                    lda       #$FF
L278                bra       L222

err41               lda       #$29
L288                lbra      L252

                    lda       #$31                error 49 (HOW DOES IT GET HERE?)
                    bra       L288

L222                pshs      X,D
                    ldx       <$AB
                    sta       ,X+
                    stx       <$AB
                    ldd       <$AB
                    subd      exprBase
                    cmpb      #$FF
                    bcc       err13
                    clra
                    puls      PC,X,D

err13               lda       #$0D
                    lbsr      PRerror
                    lbra      L116

*
skpblank            lda       ,Y+
                    cmpa      #$20
                    beq       skpblank            skip blanks
                    cmpa      #$0A
                    beq       skpblank            and LF's
                    leay      -1,Y
                    rts

L302                bsr       ISlett
                    bcc       L308
ISnum               cmpa      #$30                0 ??
                    bcs       L308
                    cmpa      #$39                9 ??
                    bls       L310
                    bra       L312

ISlett              anda      #$7F
                    cmpa      #$41                A ??
                    bcs       L308
                    cmpa      #$5A                Z ??
                    bls       L310
                    cmpa      #$5F                _ ??
                    beq       L308
                    cmpa      #$61                a ??
                    bcs       L308
                    cmpa      #$7A                z ??
                    bls       L310
L312                orcc      #1                  NO
                    rts

L310                andcc     #$FE                YES
L308                rts

* search prm list for special chars *
L266                pshs      U,Y,X,A
                    ldu       -3,X
                    ldb       -1,X
L326                stx       1,S
                    cmpu      #0                  USE CMPR 0,U (SAME SPEED, 2 BYTES SHORTER)
                    beq       L320
                    leau      -1,U
                    ldy       3,S
                    leax      B,X
L328                lda       ,X+
                    eora      ,Y+
                    beq       L322
                    cmpa      ,S
                    beq       L322
                    leax      -1,X
L324                lda       ,X+
                    bpl       L324
                    bra       L326

L322                tst       -1,X
                    bpl       L328
                    sty       3,S
L320                puls      PC,U,Y,X,A

L710                fdb       L1900-L710          table @ L204
                    fdb       L1900-L710          PARAM
                    fdb       L1900-L710          TYPE
                    fdb       L1900-L710          DIM
                    fdb       L1900-L710          DATA
                    fdb       STOP-L710
                    fdb       BYE-L710
                    fdb       L386-L710           TRON
                    fdb       L386-L710           TROFF
                    fdb       L386-L710           PAUSE
                    fdb       DEG-L710
                    fdb       RAD-L710
                    fdb       RETURN-L710
                    fdb       L370-L710
                    fdb       LET-L710
                    fdb       POKE-L710
                    fdb       IF-L710
                    fdb       GOTO-L710           = ELSE
                    fdb       ENDIF-L710
                    fdb       FOR-L710
                    fdb       NEXT-L710           table @ L388
                    fdb       UNTIL-L710          = WHILE
                    fdb       GOTO-L710           = ENDWHILE
                    fdb       L370-L710           = REPEAT
                    fdb       UNTIL-L710
                    fdb       L370-L710           = LOOP
                    fdb       GOTO-L710           = ENDLOOP
                    fdb       UNTIL-L710          = EXITIF
                    fdb       GOTO-L710           = ENDEXIT
                    fdb       ON-L710
                    fdb       ERROR-L710
                    fdb       errs51-L710
                    fdb       GOTO-L710
                    fdb       errs51-L710
                    fdb       GOSUB-L710
                    fdb       RUN-L710
                    fdb       KILL-L710
                    fdb       INPUT-L710
                    fdb       PRINT-L710
                    fdb       CHD-L710
                    fdb       CHX-L710
                    fdb       CREATE-L710
                    fdb       OPEN-L710
                    fdb       SEEK-L710
                    fdb       READ-L710
                    fdb       WRITE-L710
                    fdb       GET-L710
                    fdb       PUT-L710
                    fdb       CLOSE-L710
                    fdb       RESTORE-L710
                    fdb       DELETE-L710
                    fdb       CHAIN-L710
                    fdb       SHELL-L710
                    fdb       BASE0-L710
                    fdb       BASE1-L710
                    fdb       386-L710            REM
                    fdb       386-L710
                    fdb       END-L710
* From here on is added from original BASIC09 table @ L1D60
                    fdb       L1943-L710          go to next instruction
                    fdb       L1943-L710
                    fdb       L1944-L710          jump to [regs.x]
                    fdb       errs51-L710
                    fdb       L386-L710           RTS
                    fdb       L386-L710
                    fdb       CpMbyte-L710
                    fdb       CpMint-L710
                    fdb       CpMreal-L710
                    fdb       CpMbyte-L710
                    fdb       CpMstrin-L710
                    fdb       CpMarray-L710
L448                fcc       /STOP Encountered/
                    fcb       10,255

*
* setup workspace for module
L676                lda       $17,X
                    bita      #1
                    beq       L346
                    lbra      errs51

L346                tfr       S,D
                    deca
                    cmpd      Sstack
                    bcc       L350
                    ldb       #$39                error 57 (system stack overflow)
                    bra       L348

L350                ldd       freemem
                    subd      $0B,X
                    bcs       err32
                    cmpd      #$0100
                    bcc       L354
err32               ldb       #$20
L348                lbra      L356

L354                std       freemem
                    tfr       Y,D
                    subd      $0B,X
                    exg       D,U
                    sts       5,U
                    std       7,U
                    stx       3,U
L344                ldd       #1                  default:base 1
                    std       ArrBase
                    sta       1,U                 default: radians
                    sta       <$13,U
                    stu       $14,U
                    bsr       L358
                    ldd       <$13,X
                    beq       L360
                    addd      excoffse
L360                std       DATApoin
                    ldw       $0B,X
                    ldd       <$11,X
                    leay      D,U
                    subr      d,w
                    bls       L362
                    clr       ,-s
                    tfm       s,y+
                    leas      1,S
L362                ldx       PGMaddre
                    ldd       excoffse
                    addd      <$15,X
                    tfr       D,X
                    bra       L366                start execution

*
L358                stx       PGMaddre
                    stu       WSbase
                    ldd       $0D,X
                    addd      PGMaddre
                    std       VarPtrba
                    ldd       $0F,X
                    addd      PGMaddre
                    std       vectorba
                    std       excEnd
                    ldd       9,X
                    addd      PGMaddre
                    std       excoffse
                    ldd       $14,U
                    std       userSP
                    std       SStop
                    rts

*** MAIN LOOP
L372                lda       <$34                Check if signal received
                    bpl       L368                No, execute next instruction
                    anda      #$7F                flag signal received
                    sta       <$34
                    ldb       <$35
                    bne       L348                process it
L368                bsr       L370
L366                cmpx      excEnd
                    bcs       L372
                    bra       L374

*
END                 ldb       ,X
                    lbsr      nextinst
                    beq       L374
                    lbsr      PRINT
L374                ldu       WSbase
                    lds       5,U
                    ldu       7,U
L386                rts

L1943               leax      2,X
L370                ldb       ,X+
                    bpl       L382
                    addb      #$40
L382                aslb
                    clra
                    ldu       table1              = L710
                    ldd       D,U
                    jmp       D,U                 go to instruction

*
IF                  jsr       table4              if....
                    tst       2,Y
                    beq       GOTO                = FALSE
                    leax      3,X                 THEN
                    ldb       ,X
                    cmpb      #$3B
                    bne       L386
                    leax      1,X                 ELSE
GOTO                ldd       ,X
                    addd      excoffse
                    tfr       D,X
                    rts

ENDIF               leax      1,X
                    rts

UNTIL               jsr       table4
                    tst       2,Y
                    beq       GOTO                = FALSE
                    leax      3,X
                    rts

*
L388                fdb       L70-L388            int. step 1
                    fdb       L71-L388            int. step x
                    fdb       L72-L388            real step 1
                    fdb       L73-L388            real step x

*
NEXT                leay      <L388,PC
L414                ldb       ,X+
                    aslb
                    ldd       B,Y
                    ldu       WSbase
                    jmp       D,Y

L75                 ldd       ,X
                    leay      D,U
                    bra       L390

L76                 ldd       ,X
                    leay      D,U
                    ldd       4,X
                    lda       D,U
                    bpl       L390
                    bra       L392

*  FOR .. NEXT  /integer  *
L70                 ldd       ,X                  offset counter
                    leay      D,U                 address counter
                    ldd       ,Y
                    incd                          increment counter
                    std       ,Y
L390                ldd       2,X                 offset target
                    leax      6,X
                    ldd       D,U                 target value
                    cmpd      ,Y
                    bge       GOTO                loop again
                    leax      3,X
                    rts

*  FOR .. NEXT .. STEP  /integer *
L71                 ldd       ,X
                    leay      D,U
                    ldd       4,X
                    ldd       D,U
                    tfr       a,e
                    addd      ,Y                  update counter
                    std       ,Y
                    tste
                    bpl       L390                incrementing
L392                ldd       2,X
                    leax      6,X
                    ldd       D,U
                    cmpd      ,Y
                    ble       GOTO                loop again
                    leax      3,X
                    rts

L77                 ldy       userSP
                    clrb
                    bsr       L394
                    bra       L396

L78                 ldy       userSP
                    clrb
                    bsr       L394
                    ldd       4,X
                    addd      #4
                    ldu       WSbase
                    lda       D,U
                    lsra                          examine        sign
                    bcc       L396
                    bra       L398

*  FOR .. NEXT   /real  *
L72                 ldy       userSP
                    clrb
                    bsr       L394
                    leay      -6,Y
                    ldd       #$0180              step 1 (save in temp var)
                    std       1,Y
                    clrd
                    std       3,Y
                    sta       5,Y
                    lbsr      RLADD
                    ldq       1,Y
                    stq       ,U
                    lda       5,Y
                    sta       4,U
L396                ldb       #2                  incrementing
                    bsr       L394
                    leax      6,X
                    lbsr      RLCMP
                    lble      GOTO                loop again
                    leax      3,X
                    rts

L394                ldd       B,X                 copy number
                    addd      WSbase
                    tfr       D,U
                    leay      -6,Y
                    lda       #2
                    ldb       ,U
                    std       ,Y
                    ldq       1,U
                    stq       2,Y
                    rts

*  FOR .. NEXT .. STEP /real  *
L73                 ldy       userSP
                    clrb
                    bsr       L394
                    stu       <$D2
                    ldb       #4
                    bsr       L394
                    lda       4,U
                    sta       <$D1
                    lbsr      RLADD               incr. counter
                    ldu       <$D2
                    ldq       1,Y
                    stq       ,U
                    lda       5,Y
                    sta       4,U
                    lsr       <$D1                check sign
                    bcc       L396
L398                ldb       #2                  decrementing
                    bsr       L394
                    leax      6,X
                    lbsr      RLCMP
                    lbge      GOTO                loop again
                    leax      3,X
                    rts

******* table for FOR ********
L412                fdb       L75-L412            int. step 1
                    fdb       L76-L412            int. step x
                    fdb       L77-L412            real step 1
                    fdb       L78-L412            real step x

*
FOR                 ldb       ,X+
                    cmpb      #$82
                    beq       L405
                    bsr       CpMint
                    bsr       L410
                    ldb       -1,X
                    cmpb      #$47
                    bne       L408
                    bsr       L410
L408                lbsr      GOTO
                    leay      <L412,PC
                    lbra      L414
L410                ldd       ,X++
                    addd      WSbase
                    pshs      d
                    jsr       table4
                    ldd       1,Y
                    std       [,S++]
                    rts

L405                bsr       CpMreal
                    bsr       L418
                    ldb       -1,X
                    cmpb      #$47
                    bne       L408
                    bsr       L418
                    bra       L408

L418                ldd       ,X++
                    addd      WSbase
                    pshs      d
                    jsr       table4
                    bra       L420

LET                 jsr       table4              get var. type
L422                cmpa      #4
                    bcs       L442
                    pshs      U
                    ldu       fieldsiz
L442                pshs      U,A
                    leax      1,X
                    jsr       table4
L516                puls      A
                    asla
                    leau      <L424,PC
                    jmp       A,U                 copy

L424                bra       L426                byte
                    bra       L428                integer
                    bra       L420                real
                    bra       L426                boolean
                    bra       L430                string
                    bra       L432                array

CpMbyte             ldd       ,X
                    addd      WSbase
                    pshs      D
                    leax      3,X
                    jsr       table4
L426                ldb       2,Y
                    stb       [,S++]
                    rts

CpMint              ldd       ,X
                    addd      WSbase
                    pshs      d
                    leax      3,X
                    jsr       table4
L428                ldd       1,Y
                    std       [,S++]
                    rts

CpMreal             ldd       ,X
                    addd      WSbase
                    pshs      d
                    leax      3,X
                    jsr       table4
L420                puls      U
                    ldq       1,Y
                    stq       ,U
                    lda       5,Y
                    sta       4,U
                    rts

CpMstrin            ldd       ,X
                    addd      vectorba
                    tfr       D,U
                    ldq       ,U
                    addd      WSbase
                    pshs      D
                    pshsw
                    leax      3,X
                    jsr       table4
L430                puls      U,D                 D=Max Size of string to copy
                    ldw       3,y
                    stw       BUPsize
                    incw                          Allow for $FF terminator
                    cmpr      d,w                 Other string big enough?
                    bls       L431                Yes, copy
                    tfr       d,w                 No, only copy smaller size
                    stw       BUPsize
L431                ldd       1,y                 Get address of string to copy
                    std       exprSP              Save it
                    stu       BUPaddr             Save address of destination string
                    tfm       d+,u+               Copy (ignore $FF?)
                    clra                          clear carry
                    rts

CpMarray            lbsr      L728
                    lbra      L422

L432                puls      U,D
                    ldw       3,y
                    cmpr      d,w
                    bls       L444
                    tfr       d,w
L444                ldd       1,y
                    tfm       d+,u+
                    rts

POKE                jsr       table4
                    ldd       1,Y
                    pshs      d
                    jsr       table4
                    ldb       2,Y
                    stb       [,S++]
                    rts

STOP                lbsr      PRINT
                    lda       errpath
                    sta       IOpath
                    leax      L448,PC
                    lbsr      Sprint
                    lbra      L116                exit

GOSUB               ldd       ,X
                    leax      3,X
L464                ldy       WSbase
                    ldu       $14,Y
                    cmpu      exprBase
                    bhi       L456
                    ldb       #$35                error 53
                    lbra      L356

L456                stx       ,--U                pshs x (pshu x?)
                    stu       $14,Y
                    stu       userSP
                    addd      excoffse
                    tfr       D,X                 address subroutine
                    rts

RETURN              ldy       WSbase
                    cmpy      $14,Y
                    bhi       L458
                    ldb       #$36                error 54
                    lbra      L356

L458                ldu       $14,Y
                    ldx       ,U++                puls x  (pulu x)
                    stu       $14,Y
                    stu       userSP
                    rts

ON                  ldd       ,X
                    cmpa      #$1E
                    beq       L460                set trap
                    jsr       table4
                    ldd       ,X
                    asld
                    asld
                    incd
                    incd
                    leau      D,X
                    pshs      U
                    ldd       1,Y
                    ble       L462
                    cmpd      ,X++
                    bhi       L462
                    decd
                    asld
                    asld
                    incd
                    ldd       D,X
                    pshs      d
                    ldb       ,X
                    cmpb      #$22
                    puls      X,d
                    beq       L464
                    addd      excoffse
                    tfr       D,X
                    rts

L462                puls      PC,X

L460                ldu       WSbase
                    cmpb      #$20
                    bne       L466                clear trap
                    ldd       2,X
                    addd      excoffse
                    std       <$11,U
                    lda       #1
                    sta       <$13,U
                    leax      5,X
                    rts

L466                clr       <$13,U
                    leax      2,X
                    rts

CREATE              bsr       L468
                    ldb       #$0B                R/W/PR
                    os9       I$Create
                    bra       L470

OPEN                bsr       L468
                    os9       I$Open
L470                lbcs      L356                error
                    puls      U,B
                    cmpb      #1
                    bne       L472                store as byte
                    clr       ,U+                 integer
L472                sta       ,U                  path number
                    puls      PC,X

L468                leax      1,X
                    lbsr      getvar
                    leax      1,X
                    jsr       table4
                    lda       #3                  default: UPDATE
                    cmpb      #$4A
                    bne       L476
                    lda       ,X++                access mode
L476                ldu       3,S
                    stx       3,S
                    ldx       1,Y
                    jmp       ,U                  = RTS

SEEK                lbsr      setpath
                    jsr       table4
                    lbsr      setFP               set filepointer
                    lbcs      errman
                    rts

L500                fcc       /? /
                    fcb       255

L514                fcc       /** Input error - reenter **/
                    fcb       13,255

INPUT               lda       errpath
                    lbsr      setpath
                    lda       #$2C
                    sta       <$DD
                    pshs      X
L508                ldx       ,S
                    ldb       ,X
                    cmpb      #$90
                    bne       L498                use default
                    jsr       table4
                    pshs      Y,X
                    ldx       1,Y                 get prompt
                    ldy       3,y
                    bra       L490

L498                pshs      Y,X
                    leax      <L500,PC            default prompt
                    ldy       #2
L490                lda       IOpath
                    os9       I$WritLn
                    puls      Y,X
                    lda       IOpath
                    cmpa      errpath
                    bne       L502
                    lda       <$2D
                    sta       IOpath
L502                lbsr      READLN
                    bcc       L504                NO error
                    cmpb      #3
                    lbne      errman
                    lbsr      L506                BREAK pressed
                    clr       errcode
                    bra       L508

L504                bsr       L510                check input
                    bcc       L512
                    leax      <L514,PC            input error
                    bsr       Sprint
                    bra       L508                try again

L512                ldb       ,X+
                    cmpb      #$4B
                    beq       L504                more items!!
                    puls      PC,d

L510                bsr       getvar
                    ldb       ,S
                    addb      #7
                    ldy       userSP
                    lbsr      L46
                    lbcc      L516
L518                leas      3,S                 clear stack
                    coma                          signal         an error
                    rts

*print a message
Sprint              pshs      y,x
                    ldy       Sstack
L473                lda       ,x+
                    sta       ,y+
                    cmpa      #$FF
                    bne       L473
                    leay      -1,y
                    sty       <$Spointer
                    lbsr      WRITLN
                    puls      pc,y,x

getvar              lda       ,X+
                    cmpa      #$0E                vectored variable?
                    bne       L520
                    jsr       table4
                    bra       L522

L520                suba      #$80
                    cmpa      #4
                    bcs       L524                byte,int,real
                    beq       L526                string
                    lbsr      L728                array
                    bra       L522

L526                ldd       ,X++
                    addd      vectorba
                    tfr       D,U
                    ldq       ,U
                    stw       fieldsiz
                    bra       L528

L524                ldd       ,X++
L528                addd      WSbase
                    tfr       D,U
                    lda       -3,X
                    suba      #$80
L522                puls      Y
                    cmpa      #4
                    bcs       L530
                    pshs      U
                    ldu       fieldsiz
L530                pshs      U,A
                    jmp       ,Y                  = RTS

* set IO path
* called by #path statement
setpath             ldb       ,X
                    cmpb      #$54                path number given?
                    bne       L532
                    leax      1,X
                    jsr       table4
                    cmpb      #$4B                string follows?
                    beq       L534
                    leax      -1,X
L534                lda       2,Y
L532                sta       IOpath
                    rts

READ                ldb       ,X
                    cmpb      #$54
                    bne       L536                read from DATA statement
                    bsr       setpath
                    clr       <$DD
                    cmpb      #$4B
                    bne       L538
                    leax      -1,X
L538                lbsr      READLN
                    bcc       L540
                    cmpb      #$E4                error 228 ?
                    beq       L538
L542                lbra      errman

L544                lbsr      L510                check input
                    bcs       L542
L540                ldb       ,X+
                    cmpb      #$4B
                    beq       L544                more items
                    rts

L536                bsr       nextinst
                    beq       L546                literal data
* process data statements that are expressions
L550                bsr       L548
                    ldb       ,X+
                    cmpb      #$4B
                    beq       L550
                    rts

L548                lbsr      getvar
                    bsr       L552                get data item
                    lda       ,S
                    bne       L554
                    inca
L554                cmpa      ,Y
                    lbeq      L516
                    cmpa      #2
                    bcs       L556                byte,integer
                    beq       L558                real numbers
err71               ldb       #$47
                    bra       L560

L556                lda       ,Y
                    cmpa      #2
                    bne       err71
                    lbsr      FIX
                    lbra      L516

L558                cmpa      ,Y
                    bcs       err71
                    lbsr      FLOAT
                    lbra      L516

*
L546                leax      1,X
L552                pshs      X
                    ldx       DATApoin
                    bne       L568
                    ldb       #$4F                error 79
L560                lbra      L356

L568                jsr       table4
                    cmpb      #$4B
                    beq       L570
                    ldd       ,X
                    addd      excoffse
                    tfr       D,X
L570                stx       DATApoin
                    puls      PC,X

* instruction delimiters
nextinst            cmpb      #$3F                = end of line
                    beq       L572
                    cmpb      #$3E                = "back slash"
L572                rts

PRINT               lda       errpath
                    lbsr      setpath
                    ldd       Sstack
                    std       Spointer
                    ldb       ,X+
                    cmpb      #$49                print using
                    beq       L574
L584                bsr       nextinst
                    beq       L576
L586                cmpb      #$4B                comma separator?
                    beq       L578
                    cmpb      #$51                semi-colon?
                    beq       L580
                    leax      -1,X
                    jsr       table4              get variable address
                    ldb       ,Y
                    incb
                    lbsr      L46                 copy to Sstack
                    lbcs      errman
                    ldb       -1,X
                    bra       L584

L578                lbsr      L2012               print spaces
                    lbcs      errman
L580                ldb       ,X+
                    bsr       nextinst
                    bne       L586
                    bra       L588

L576                lbsr      Strterm
                    lbcs      errman
L588                lbsr      WRITLN
                    lbcs      errman
                    rts

L574                jsr       table4
                    ldd       exprBase
                    std       <$8E
                    std       <$8C
                    ldu       userSP
                    pshs      U,d
                    ldd       exprSP
                    std       exprBase
L598                ldb       -1,X
                    bsr       nextinst
                    beq       L594
                    ldb       ,X+
                    bsr       nextinst
                    beq       L596
                    leax      -1,X
                    lbsr      PRNTUSIN
                    bcc       L598
                    puls      U,d                 error encountered
                    std       exprBase
                    stu       userSP
                    lbra      errman

L596                leay      <L588,PC
                    bra       L600

L594                leay      <L576,PC
L600                puls      U,d
                    std       exprBase
                    stu       userSP
                    jmp       ,Y

WRITE               lda       errpath
                    lbsr      setpath
                    ldu       Sstack
                    stu       Spointer
                    ldb       ,X+
                    lbsr      nextinst
                    beq       L602
                    cmpb      #$4B                comma separator?
                    beq       L604
                    leax      -1,X
                    bra       L604

L606                clra
                    lbsr      L1632
                    lbcs      errman
L604                jsr       table4
                    ldb       ,Y
                    incb
                    lbsr      L46
                    lbcs      errman
                    ldb       -1,X
                    lbsr      nextinst
                    bne       L606
L602                lbra      L576

GET                 bsr       L608
                    stx       BUPaddr
                    os9       I$Read
                    sty       BUPsize
                    bra       L610

PUT                 bsr       L608
                    os9       I$Write
L610                leax      ,U
                    bcc       L612
L620                lbra      L356

L608                lbsr      setpath
                    lbsr      getvar
                    leau      ,X
                    puls      A
                    cmpa      #4
                    bcs       L609
                    puls      y
                    bra       L618

L609                leax      L616,PC
                    ldb       A,X
                    clra
                    tfr       D,Y
L618                puls      X
                    lda       IOpath
L612                rts

CLOSE               lbsr      setpath
                    os9       I$Close
                    bcs       L620
                    cmpb      #$4B
                    beq       CLOSE               multiple paths
                    rts

RESTORE             ldb       ,X+
                    cmpb      #$3B
                    beq       L624                to line ...
                    ldu       PGMaddre
                    ldd       <$13,U              rewind
L626                addd      excoffse
                    std       DATApoin
                    rts

L624                ldd       ,X
                    incd
                    leax      3,X
                    bra       L626

DELETE              jsr       table4
                    pshs      X
                    ldx       1,Y
                    os9       I$Delete
L628                bcs       L620
                    puls      PC,X

CHD                 jsr       table4
                    lda       #3                  read & write
L630                pshs      X
                    ldx       1,Y
                    os9       I$ChgDir
                    bra       L628

CHX                 jsr       table4
                    lda       #4                  execute
                    bra       L630

CHAIN               jsr       table4
                    ldy       1,Y
                    pshs      U,Y,X
                    lbsr      unlink
                    puls      U,Y,X
                    bsr       L634                set up registers
                    sts       <$B1                Save stack ptr
                    lds       Sstack
                    os9       F$Chain
                    lds       <$B1                If gets this far, chain failed
                    bra       L356

SHELL               jsr       table4
                    pshs      U,X
                    ldy       1,Y
                    bsr       L634                set up registers
                    os9       F$Fork
                    bcs       L356
                    pshs      A                   Save child's process #
L636                os9       F$Wait              Wait for child to die
                    cmpa      ,S                  Our child?
                    bne       L636                No, wait for next death
                    leas      1,S
                    tstb
                    bne       L356
                    puls      PC,U,X

L638                fcc       /SHELL/
                    fcb       13

L634                ldx       exprSP
                    lda       #$0D
                    sta       -1,X
                    leau      ,y
                    subr      y,x
                    tfr       X,Y
                    leax      <L638,PC
                    clrd
                    rts

ERROR               jsr       table4
                    ldb       2,Y
L356                stb       errcode
errman              ldu       WSbase
                    beq       L640                not running subroutine
                    tst       <$13,U
                    beq       L642                no error trap
                    lds       5,U
                    ldx       <$11,U
                    ldd       $14,U
                    std       userSP
                    lbra      L372                process error

L642                bsr       L506
                    lbra      L116                exit

L640                lbsr      PRerror
                    lbra      L116                exit

L646                fcb       14,255              Force text mode in VDGINT
L506                leax      <L646,PC
                    lbsr      Sprint
                    lbsr      unlink
                    ldb       errcode
                    os9       F$Exit
BASE0               clrb
                    bra       L648

BASE1               ldb       #1
L648                clra
                    std       ArrBase
                    leax      1,X
                    rts

L1944               exg       X,PC
                    rts

L1900               leay      ,X
                    lbsr      L650                jumptable @ L204
                    leax      ,Y
                    rts

errs51              ldb       #$33
                    bra       L356

DEG                 lda       #1
                    bra       L652

RAD                 clra
L652                ldu       WSbase
                    sta       1,U
                    leax      1,X
                    rts

INKEY               leax      2,x
                    ldd       ,x++
                    cmpd      #$4D0E              marker
                    lbne      err56
                    clre                          default        path: 0
                    jsr       table4
                    cmpa      #4                  = string
                    beq       L383                use default path
                    cmpa      #2
                    lbhs      err56               invalid type
                    ldw       ,u
                    tsta
                    beq       L383                path = byte
                    tfr       f,e
L383                pshsw
                    bsr       L391
                    cmpa      #4                  string ??
                    lbne      err56               wrong type
                    pulsw
                    pshs      x
                    leax      ,u
                    ldf       #$FF
                    stf       ,x                  null string
                    ldd       fieldsiz
                    cmpd      #2
                    blo       L385
                    stf       1,x                 terminate string
L385                tfr       e,a                 path number
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcs       L387                no key
                    ldy       #1
                    os9       I$Read
                    bra       L389                returns error status

L387                cmpb      #$F6                not ready ??
                    beq       L389                carry = clear
                    coma                          signal an error
L389                puls      pc,x

L391                ldd       ,x++
                    cmpd      #$4B0E
                    lbne      err56               param missing
                    jsr       table4
L393                ldb       ,x+
                    cmpb      #$4E
                    bne       L393
                    leax      1,x                 -> next instruction
                    rts

SYSCALL             ldd       2,x
                    cmpa      #$4D                marker
                    lbne      err56
                    cmpb      #$0E
                    bne       L401
                    leax      4,x                 callcode = variable
                    jsr       table4
                    lda       ,u
                    sta       callcode
                    bra       L403

L401                lda       5,x                 callcode = static
                    sta       callcode
                    leax      6,x
L403                bsr       L391
                    ldd       fieldsiz
                    cmpd      #10
                    lbne      err56               wrong data structure
                    pshs      x
                    pshs      u
                    ldd       1,u                 u -> data
                    ldx       4,u
                    ldy       6,u
                    ldu       8,u
                    jsr       <callex
                    tfr       u,w
                    puls      u
                    leau      8,u
                    pshu      y,x,dp,d,cc         store returns
                    stw       8,u
                    puls      pc,x

RUN                 ldd       ,x
                    cmpd      Vsys
                    beq       syscall
                    cmpd      Vinkey
                    lbeq      inkey
                    lbsr      L728                get address of name
                    pshs      X
                    ldb       <$CF
                    cmpb      #$A0                mod. name ?
                    beq       L658                name found
                    ldy       exprSP
                    ldw       fieldsiz
L662                lda       ,U+                 copy name
                    decw
                    beq       L660
                    sta       ,Y+
                    cmpa      #$FF
                    bne       L662
                    lda       ,--Y
L660                ora       #$80                terminate it
                    sta       ,Y
                    ldy       exprSP
                    lbsr      link
                    bcs       errs43
                    leau      ,X
L658                ldd       ,U
                    bne       L668                mod. in addr.space
                    ldy       <$D2
                    leay      3,Y
                    ldd       Vsys
                    cmpd      #$FFFF
                    bne       L661
                    lbsr      ISsyscal
L661                ldd       Vinkey
                    cmpd      #$FFFF
                    bne       L663
                    lbsr      ISinkey
L663                lbsr      link
                    bcs       errs43
                    ldd       ,X
                    std       ,U
L668                ldx       ,S
                    std       ,S
                    ldu       WSbase
                    lda       <$34
                    sta       ,U
                    ldb       <$43
                    stb       2,U
                    ldd       exprBase
                    ldw       <$40
                    stq       $0D,U
                    ldd       DATApoin
                    std       9,U
                    lbsr      L670                prm stack
                    stx       $0B,U               next instruction
                    stw       BUPaddr             clear address
                    puls      X
                    lda       6,X                 module type??
                    beq       B09subr
                    cmpa      #$22
                    beq       B09subr
                    cmpa      #$21
                    beq       MLsubr
errs43              ldb       #$2B
                    lbra      L356

MLsubr              ldd       5,U
                    pshs      B,A
                    sts       5,U
                    leas      ,Y                  -> prmstack
                    ldd       <$40
                    subr      y,d                 stacksize
                    lsrd
                    lsrd
                    pshs      d                   number of elements
                    ldd       9,X
                    leay      L676,PC
                    jsr       D,X                 run ML subroutine
                    ldu       WSbase
                    lds       5,U
                    puls      X
                    stx       5,U
                    bcc       L678                no error on exit
                    lbra      L356

* run Basic09 subroutine *
B09subr             fcb       2,$7f,$34
*          aim   #$7F,<$34
                    ldd       #$FFFF
                    std       Vsys                clear links
                    std       Vinkey
                    lbsr      L676
                    lda       ,U
                    bita      #1
                    beq       L678                no error on exit
                    lda       ,U
                    sta       <$34
L678                ldq       $0D,U               reset DP pointers
                    std       exprBase
                    stw       <$40
                    ldd       9,U
                    std       DATApoin
                    ldb       2,U
                    sex
                    std       ArrBase
                    ldx       3,U
                    lbsr      L358
                    ldx       $0B,U
                    ldd       SStop
                    subd      exprBase
                    std       freemem
                    ldd       #$FFFF
                    std       Vinkey
                    std       Vsys
                    rts

ISinkey             leax      <L613,pc
                    bra       L677

ISsyscal            leax      <L615,pc
L677                pshs      y
L679                lda       ,x+
                    eora      ,y+
                    anda      #$DF
                    bne       L681                = RTS
                    lda       -1,x
                    bpl       L679                next char
                    puls      u,y                 clear stack
                    puls      x
                    leax      -2,x
                    ldw       ,x
                    cmpa      #$EC                l ??
                    bne       L683
                    stw       Vsys
                    lbra      syscall

L683                stw       Vinkey
                    lbra      inkey

L681                puls      pc,y                no match

L613                fcs       /inkey/
L615                fcs       /SysCall/

L616                fcb       1,2,5,1

* assemble parameter stack
L670                pshs      U
                    leay      <L616,pc
                    ldb       ,X+
                    clra
                    pshs      Y,X,A
                    cmpb      #$4D
                    bne       L684                no params
                    leay      ,S
L696                pshs      Y
                    ldb       ,X
                    cmpb      #$0E
                    beq       L686                variable: any type
                    jsr       table4              variable type ?
                    leax      -1,X
                    cmpa      #2
                    beq       L688                real
                    cmpa      #4
                    beq       L690                string
                    ldd       1,Y
                    std       4,Y                 others
                    lda       ,Y
L688                ldb       #6
                    leau      <L616,PC
                    subb      A,U
                    leau      B,Y
                    stu       userSP
                    bra       L692

L690                ldu       1,Y
                    ldd       3,y
                    std       fieldsiz
                    ldd       exprSP
                    std       exprBase
                    lda       #4
                    bra       L692

L686                leax      1,X
                    jsr       table4              variables
L692                puls      Y
                    inc       ,Y                  param count
                    cmpa      #4
                    bcs       L693
                    ldd       fieldsiz
                    bra       L694

L693                ldw       3,y                 address L616
                    tfr       a,b
                    clra
                    addr      d,w
                    ldb       ,w
L694                pshs      U,D                 address + size
                    ldb       ,X+
                    cmpb      #$4B
                    beq       L696                get next item
                    leax      1,X                 end of list
                    stx       1,Y                 = PSHS X
                    ldu       userSP
                    stu       <$40
                    ldf       ,y
                    clre
                    rolw
L700                puls      d
                    std       ,--U
                    decw
                    bne       L700
                    leay      ,U                  -> stack
                    bra       L704

L684                ldy       userSP
                    sty       <$40
L704                tfr       Y,D
                    subd      exprBase
                    lbcs      err32
                    std       freemem
                    puls      x,a
                    puls      PC,U,D

*********************************
                    fdb       MID$-L1386
                    fdb       LEFT$-L1386
                    fdb       RIGHT$-L1386
                    fdb       CHR$-L1386
                    fdb       STR$int-L1386
                    fdb       STR$rl-L1386
                    fdb       DATE$-L1386
                    fdb       TAB-L1386
                    fdb       FIX-L1386
                    fdb       fixN1-L1386
                    fdb       fixN2-L1386
                    fdb       FLOAT-L1386
                    fdb       float2-L1386
                    fdb       LNOTB-L1386
                    fdb       NEGint-L1386
                    fdb       NEGrl-L1386
                    fdb       LANDB-L1386
                    fdb       LORB-L1386
                    fdb       LXORB-L1386
                    fdb       Igt-L1386
                    fdb       Rgt-L1386
                    fdb       Sgt-L1386
                    fdb       Ilo-L1386
                    fdb       Rlo-L1386
                    fdb       Slo-L1386
                    fdb       Ine-L1386
                    fdb       Rne-L1386
                    fdb       Sne-L1386
                    fdb       Bne-L1386
                    fdb       Ieq-L1386
                    fdb       Req-L1386
                    fdb       Seq-L1386
                    fdb       Beq-L1386
                    fdb       Ige-L1386
                    fdb       Rge-L1386
                    fdb       Sge-L1386
                    fdb       Ile-L1386
                    fdb       Rle-L1386
                    fdb       Sle-L1386
                    fdb       INTADD-L1386
                    fdb       RLADD-L1386
                    fdb       STRconc-L1386
                    fdb       INTSUB-L1386
                    fdb       RLSUB-L1386
                    fdb       INTMUL-L1386
                    fdb       RLMUL-L1386
                    fdb       INTDIV-L1386
                    fdb       RLDIV-L1386
                    fdb       POWERS-L1386
                    fdb       POWERS-L1386
                    fdb       DIM-L1386
                    fdb       DIM-L1386
                    fdb       DIM-L1386
                    fdb       DIM-L1386
                    fdb       PARAM-L1386
                    fdb       PARAM-L1386
                    fdb       PARAM-L1386
                    fdb       PARAM-L1386
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0

*******************************
L1386               fdb       BCPVAR-L1386
                    fdb       ICPVAR-L1386
                    fdb       L2102-L1386         copy real number
                    fdb       BlCPVAR-L1386
                    fdb       SCPVAR-L1386
                    fdb       L2105-L1386         copy DIM array
                    fdb       L2105-L1386
                    fdb       L2105-L1386
                    fdb       L2105-L1386
                    fdb       L2106-L1386         copy PARAM array
                    fdb       L2106-L1386
                    fdb       L2106-L1386
                    fdb       L2106-L1386
                    fdb       BCPCNST-L1386
                    fdb       ICPCNST-L1386
                    fdb       RCPCNST-L1386
                    fdb       SCPCNST-L1386
                    fdb       ICPCNST-L1386
                    fdb       ADDR-L1386
                    fdb       ADDR-L1386
                    fdb       SIZE-L1386
                    fdb       SIZE-L1386
                    fdb       POS-L1386
                    fdb       ERR-L1386
                    fdb       MODint-L1386
                    fdb       MODrl-L1386
                    fdb       RND-L1386
                    fdb       PI-L1386
                    fdb       SUBSTR-L1386
                    fdb       SGNint-L1386
                    fdb       SGNrl-L1386
                    fdb       L2122-L1386         transc. functions
                    fdb       L2123-L1386
                    fdb       L2124-L1386
                    fdb       L2125-L1386
                    fdb       L2126-L1386
                    fdb       L2127-L1386
                    fdb       EXP-L1386
                    fdb       ABSint-L1386
                    fdb       ABSrl-L1386
                    fdb       LOG-L1386           ln
                    fdb       LOG10-L1386
                    fdb       SQRT-L1386
                    fdb       SQRT-L1386
                    fdb       FLOAT-L1386
                    fdb       INTrl-L1386
                    fdb       L1058-L1386         RTS
                    fdb       FIX-L1386
                    fdb       FLOAT-L1386
                    fdb       L1058-L1386         RTS
                    fdb       SQint-L1386
                    fdb       SQrl-L1386
                    fdb       PEEK-L1386
                    fdb       LNOTI-L1386
                    fdb       VAL-L1386
                    fdb       LEN-L1386
                    fdb       ASC-L1386
                    fdb       LANDI-L1386
                    fdb       LORI-L1386
                    fdb       LXORI-L1386
                    fdb       equTRUE-L1386
                    fdb       equFALSE-L1386
                    fdb       EOF-L1386
                    fdb       TRIM$-L1386

*****************************
L1388               fdb       BtoI-L1388
                    fdb       INTCPY-L1388
                    fdb       RCPVAR-L1388
                    fdb       L13-L1388
                    fdb       L14-L1388
                    fdb       L15-L1388

*****************************
L1390               ldy       userSP              = table4
                    ldd       exprBase
                    std       exprSP              clear expr.stack
                    bra       L724

L726                aslb
                    ldu       table2              -> L1386
                    ldd       B,U
                    jsr       D,U
L724                ldb       ,X+
                    bmi       L726                next part
                    clra                          clear          carry
                    lda       ,Y
                    rts                           instruction done

* get size of DIM array
L2105               bsr       L728
L732                pshs      PC,U
                    ldu       table3              -> L1388
                    asla
                    ldd       A,U
                    leau      D,U
                    stu       2,S
                    puls      PC,U

* get size of PARAM array
L2106               bsr       L730
                    bra       L732

DIM                 leas      2,S
                    lda       #$F2
                    bra       L734

PARAM               leas      2,S
                    lda       #$F6
                    bra       L736

L730                lda       #$89
L736                sta       <$A3
                    clr       <$3B
                    bra       L738

L728                lda       #$85
L734                sta       <$A3
                    sta       <$3B
L738                ldd       ,X++
                    addd      VarPtrba
                    std       <$D2
                    ldu       <$D2                points to var. marker
                    lda       ,U
                    anda      #$E0
                    sta       <$CF
                    eora      #$80
                    sta       <$CE
                    lda       ,U
                    anda      #7
                    ldb       -3,X
                    subb      <$A3
                    pshs      d
                    lda       ,U
                    anda      #$18
                    lbeq      L740
                    ldd       1,U
                    addd      vectorba
                    tfr       D,U
                    ldd       ,U
                    std       VarAddr
                    lda       1,S
                    bne       L742                first access
                    lda       #5
                    sta       ,S
                    ldd       2,U
                    std       fieldsiz
                    clrd
                    bra       L744

L742                leay      -6,Y
                    clrd
                    std       1,Y
                    leau      4,U
                    bra       L746

L754                ldd       ,U                  should be able to change to raw MULD?
                    std       1,Y
                    lbsr      INTMUL
L746                ldd       7,Y
                    subd      ArrBase             adjust to base 0
                    cmpd      ,U++
                    blo       L750
                    ldb       #$37                error 55
                    lbra      L356

L750                addd      1,Y
                    std       7,Y
                    dec       1,S
                    bne       L754                next element
                    lda       ,S
                    beq       L756                bytes
                    cmpa      #2
                    bcs       L758                integers
                    beq       L760                real numbers
                    cmpa      #4
                    bcs       L756                boolean
                    ldd       ,U                  string
                    std       fieldsiz
                    bra       L762

L756                ldd       7,Y                 number of elements
                    bra       L764

L758                ldd       7,Y
                    asld                          x              2
L764                leay      $0C,Y
                    bra       L744

L760                ldd       #5
L762                std       1,Y
                    lbsr      INTMUL              x 5   (change to internal MULD)
                    ldd       1,Y                 array size
                    leay      6,Y                 Eat temp var
L744                tst       <$CE
                    bne       L766
                    ldw       VarAddr
                    addw      WSbase
                    cmpw      <$40
                    bcc       err56               too big!
                    tfr       W,U
                    cmpd      2,U
                    bhi       err56               too big!
                    addd      ,U
                    bra       L770

L766                addd      VarAddr
                    tst       <$3B
                    bne       L772
L776                addd      1,Y
                    leay      6,Y
                    bra       L770

L740                lda       ,S
                    cmpa      #4
                    ldd       1,U
                    bcs       L774
                    addd      vectorba
                    tfr       D,U
                    ldq       ,U
                    stw       fieldsiz
L774                tst       <$3B
                    beq       L776                PARAM
                    addd      WSbase
                    tfr       D,U
                    tst       <$CE
                    bne       L778
                    cmpd      <$40
                    bcc       err56               too big!
                    ldd       fieldsiz
                    cmpd      2,U
                    blo       L780
                    ldd       2,U
                    std       fieldsiz            reset fieldwidth
L780                ldu       ,U
                    bra       L778

L772                addd      WSbase
L770                tfr       D,U
L778                clra
                    puls      PC,d

err56               ldb       #$38
                    lbra      L356

BCPCNST             leau      ,X+
                    bra       BtoI

BCPVAR              ldd       ,X++
                    addd      WSbase
                    tfr       D,U
BtoI                ldb       ,U
                    clra
                    leay      -6,Y
                    std       1,Y
                    lda       #1
                    sta       ,Y
                    rts

ICPCNST             leau      ,X++
                    bra       INTCPY

ICPVAR              ldd       ,X++
                    addd      WSbase
                    tfr       D,U
INTCPY              ldd       ,U
                    leay      -6,Y
                    std       1,Y
                    lda       #1
                    sta       ,Y
                    rts

NEGint              clrd
                    subd      1,Y
                    std       1,Y
                    rts

INTADD              ldd       7,Y
                    addd      1,Y
                    leay      6,Y
                    std       1,Y
                    rts

INTSUB              ldd       7,Y
                    subd      1,Y
                    leay      6,Y
                    std       1,Y
                    rts

INTMUL              ldd       7,Y
                    beq       L786
                    muld      1,y
                    stw       7,y
L786                leay      6,Y
                    rts

INTDIV              clre
                    ldd       1,y
                    bne       L801
                    ldb       #$2D                error 45
                    lbra      L356

L801                cmpd      #1
                    beq       L803
                    bpl       L800
                    come
                    negd
                    std       1,y
L800                cmpd      #2
                    bne       L810
                    ldd       7,Y                 divide by 2
                    beq       L803
                    bpl       L802
                    negd
                    come
L802                ste       ,y
                    clrw
                    asrd
                    rolw
                    bra       L806

L810                ldd       7,y
                    bne       L812
L803                clrd                          always 0
                    std       9,Y
                    leay      6,Y
                    rts

L812                bpl       L814
                    come
                    negd
L814                ste       ,y
                    tfr       d,w
                    clrd
                    divq      1,y
                    exg       d,w
L806                tst       ,y
                    bpl       L820                answer = pos.
                    negd
                    comw
                    incw
L820                stq       7,Y
L822                leay      6,Y
                    rts

RCPCNST             leay      -6,Y
                    ldb       ,X+
                    lda       #2
                    std       ,Y
                    ldq       ,X
                    stq       2,Y
                    leax      4,x
                    rts

L2102               ldd       ,X++
                    addd      WSbase
                    tfr       D,U
RCPVAR              leay      -6,Y
                    lda       #2
                    ldb       ,U
                    std       ,Y
                    ldq       1,U
                    stq       2,Y
                    rts

* invert sign of real number
NEGrl               fcb       $62,1,$25
*          eim   #1,5,y
                    rts

RLSUB               fcb       $62,1,$25
*          eim   #1,5,y
RLADD               tst       2,Y
                    beq       L824                = +0
                    tst       8,Y
                    bne       L826
L830                ldq       1,Y                 = 0+x
                    stq       7,Y
                    lda       5,Y
                    sta       $0B,Y
L824                leay      6,Y
                    rts

* compare exponents
L826                lda       7,Y
                    suba      1,Y
                    bvc       L828
                    bpl       L830
                    bra       L824

L828                bmi       L832
                    cmpa      #$1F
                    ble       L834
                    bra       L824                change insignif.

L832                cmpa      #$E1
                    blt       L830                change insignif.
                    ldb       1,Y
                    stb       7,Y
* calc. sign of answer
L834                ldb       $0B,Y
                    andb      #1
                    stb       ,Y
                    eorb      5,Y
                    andb      #1
                    stb       1,Y                 sign of answer
* clear original signs
*          aim   #$FE,11,y
*          aim   #$FE,5,y
                    fcb       $62,$fe,$2b
                    fcb       $62,$fe,$25
* calc. answer
                    tsta
                    beq       L836
                    tfr       y,w
                    bpl       L838
                    nega
                    addw      #6
                    bsr       L840
                    tst       1,Y
                    beq       L842
* substract mantissas
L848                subw      4,Y
                    sbcd      2,Y
                    bcc       L844
                    comd
                    comw
                    addw      #1
                    adcd      #0
L846                dec       ,Y
                    bra       L844

L838                bsr       L840
                    stq       2,Y
L836                ldq       8,Y
                    tst       1,Y
                    bne       L848
* add mantissas
L842                addw      4,Y
                    adcd      2,Y
                    bcc       L844
                    rord
                    rorw
                    inc       7,Y
L844                tsta
                    bmi       L850
                    andcc     #^Carry             clear carry
L854                dec       7,Y                 shift to proper form
                    bvs       equ0
                    rolw
                    rold
                    bpl       L854
L850                addw      #1
                    adcd      #0
                    bcc       L856
                    rora
                    inc       7,Y
L856                std       8,Y
                    tfr       W,D
                    lsrb
                    lslb
                    orb       ,y                  add sign
L858                std       $0A,Y
                    leay      6,Y
                    rts

L840                suba      #$10
                    bcs       L860
                    suba      #8
                    bcs       L862
                    pshs      A
                    clra
                    ldb       2,W
                    bra       L864

L862                adda      #8
                    pshs      A
                    ldd       2,W
L864                clrw
                    tst       ,S
                    beq       L866
                    exg       d,w
                    bra       L872
L860                adda      #8
                    bcc       L870
                    pshs      A
                    clra
                    ldb       2,W
                    ldw       3,W
                    tst       ,S
                    bne       L872
                    bra       L866

L870                adda      #8
                    pshs      A
                    ldq       2,W
L872                lsrd
                    rorw
                    dec       ,S
                    bne       L872
L866                leas      1,S
                    rts

RLMUL               lda       2,Y
                    bpl       equ0
                    lda       8,Y
                    bmi       L876
equ0                clrd
                    clrw
                    stq       7,Y
                    sta       $0B,Y
                    leay      6,Y
                    rts

L876                lda       1,Y
                    adda      7,Y
                    bvc       L878
L916                bpl       equ0
                    ldb       #$32                error 50
                    lbra      L356

L878                sta       7,Y
                    ldb       $0B,Y
                    eorb      5,Y
                    andb      #1
                    stb       ,Y
                    lda       $0B,Y
                    anda      #$FE
                    sta       $0B,Y
                    ldb       5,Y
                    andb      #$FE
                    stb       5,Y
                    mul
                    clrw
                    clr       extnum
                    tfr       a,f
                    lda       $0B,Y
                    ldb       4,Y
                    mul
                    addr      d,w
                    bcc       L880
                    inc       extnum
L880                lda       $0A,Y
                    ldb       5,Y
                    mul
                    addr      d,w
                    bcc       L882
                    inc       extnum
L882                tfr       e,f
                    lde       extnum
                    clr       extnum
                    lda       $0B,Y
                    ldb       3,Y
                    mul
                    addr      d,w
                    bcc       L884
                    inc       extnum
L884                lda       $0A,Y
                    ldb       4,Y
                    mul
                    addr      d,w
                    bcc       L886
                    inc       extnum
L886                lda       9,Y
                    ldb       5,Y
                    mul
                    addr      d,w
                    bcc       L888
                    inc       extnum
L888                tfr       e,f
                    lde       extnum
                    clr       extnum
                    lda       $0B,Y
                    ldb       2,Y
                    mul
                    addr      d,w
                    bcc       L890
                    inc       extnum
L890                lda       $0A,Y
                    ldb       3,Y
                    mul
                    addr      d,w
                    bcc       L892
                    inc       extnum
L892                lda       9,Y
                    ldb       4,Y
                    mul
                    addr      d,w
                    bcc       L894
                    inc       extnum
L894                lda       8,Y
                    ldb       5,Y
                    mul
                    addr      d,w
                    bcc       L896
                    inc       extnum
L896                stf       11,y
                    tfr       e,f
                    lde       extnum
                    clr       extnum
                    lda       $0A,Y
                    ldb       2,Y
                    mul
                    addr      d,w
                    bcc       L898
                    inc       extnum
L898                lda       9,Y
                    ldb       3,Y
                    mul
                    addr      d,w
                    bcc       L900
                    inc       extnum
L900                lda       8,Y
                    ldb       4,Y
                    mul
                    addr      d,w
                    bcc       L902
                    inc       extnum
L902                stf       10,y
                    tfr       e,f
                    lde       extnum
                    clr       extnum
                    lda       9,Y
                    ldb       2,Y
                    mul
                    addr      d,w
                    bcc       L904
                    inc       extnum
L904                lda       8,Y
                    ldb       3,Y
                    mul
                    addr      d,w
                    bcc       L906
                    inc       extnum
L906                lda       8,Y
                    ldb       2,Y
                    mul
                    tfr       w,u
                    tfr       e,f
                    lde       extnum
                    exg       d,u
                    addr      u,w
                    bmi       L908
                    asl       11,y
                    rol       10,y
                    rolb
                    rolw
                    dec       7,Y
                    lbvs      L916
L908                tfr       b,a
                    ldb       $0A,Y
                    exg       d,w
                    addw      #1
                    adcd      #0
                    bne       L914
                    rora
                    inc       7,Y
L914                exg       d,w
                    lsrb
                    lslb
                    orb       ,Y
                    std       $0A,Y
                    stw       8,y
                    leay      6,Y
                    rts

RLDIV               tst       2,Y
                    bne       L920
                    ldb       #$2D                error 45
                    lbra      L356

L920                tst       8,Y
                    lbeq      equ0
                    lda       7,Y
                    suba      1,Y
                    lbvs      L916
                    sta       7,Y
                    lda       #$21
                    ldb       5,Y
                    eorb      $0B,Y
                    andb      #1
                    std       ,Y
                    ldq       2,y
                    lsrd
                    rorw
                    stq       2,y
                    ldq       8,Y
                    lsrd
                    rorw
                    clr       $0B,Y
L932                subw      4,Y
                    sbcd      2,y
                    beq       L926
                    bmi       L928
L936                orcc      #1
L938                dec       ,Y
                    beq       L930
                    rol       $0B,Y
                    rol       $0A,Y
                    rol       9,Y
                    rol       8,Y
                    andcc     #^Carry
                    rolw
                    rold
                    bcc       L932
                    addw      4,Y
                    adcd      2,y
                    beq       L926
                    bpl       L936
L928                andcc     #$FE
                    bra       L938

L926                tstw
                    bne       L936
                    ldb       ,Y
                    decb
                    subb      #$10
                    blt       L940
                    subb      #8
                    blt       L942
                    stb       ,Y
                    lda       $0B,Y
                    ldb       #$80
                    andcc     #^Carry
                    bra       L946

L942                addb      #8
                    stb       ,Y
                    ldw       #$8000
                    ldd       $0A,Y
                    andcc     #^Carry
                    bra       L946

L940                addb      #8
                    blt       L948
                    stb       ,Y
                    ldq       9,Y
                    ldf       #$80
                    andcc     #^Carry
                    bra       L946

L948                addb      #7
                    stb       ,Y
                    ldq       8,Y
                    orcc      #1
L950                rolw
                    rold
L946                dec       ,Y
                    bpl       L950
                    tsta
                    bra       L952

L930                ldq       8,Y
L952                bmi       L954
                    rolw
                    rold
                    dec       7,Y
                    lbvs      equ0
L954                addw      #1
                    adcd      #0
                    bcc       L956
                    rora
                    inc       7,Y
                    lbvs      equ0
L956                std       8,Y
                    tfr       W,D
                    lsrb
                    lslb
                    orb       1,Y
                    std       $0A,Y
                    inc       7,Y
                    lbvs      L916
L958                leay      6,Y
                    rts

POWERS              ldd       7,Y
                    beq       L958
                    ldw       1,Y
                    bne       L960
                    leay      6,Y
L1152               ldd       #$0180
                    clrw
                    stq       1,Y
                    ste       5,y
                    rts

L960                std       1,Y
                    stw       7,Y
                    ldd       9,Y
                    ldw       3,Y
                    std       3,Y
                    stw       9,Y
                    lda       $0B,Y
                    ldb       5,Y
                    sta       5,Y
                    stb       $0B,Y
                    lbsr      LOG                 = ln
                    lbsr      RLMUL
                    lbra      EXP

BlCPVAR             ldd       ,X++
                    addd      WSbase
                    tfr       D,U
L13                 ldb       ,U
                    clra
                    leay      -6,Y
                    std       1,Y
                    lda       #3
                    sta       ,Y
                    rts

LANDB               ldb       8,Y
                    andb      2,Y
                    bra       L968

LORB                ldb       8,Y
                    orb       2,Y
                    bra       L968

LXORB               ldb       8,Y
                    eorb      2,Y
L968                leay      6,Y
                    std       1,Y
                    rts

LNOTB               com       2,Y
                    rts

StrCMP              pshs      Y,X
                    ldx       1,Y
                    ldy       7,Y
                    sty       exprSP
L972                lda       ,Y+
                    cmpa      ,X+
                    bne       L970
                    cmpa      #$FF
                    bne       L972
L970                inca
                    inc       -1,X
                    cmpa      -1,X
                    puls      PC,Y,X

Slo                 bsr       StrCMP
                    blo       L976
                    bra       L978

Sle                 bsr       StrCMP
                    bls       L976
                    bra       L978

Seq                 bsr       StrCMP
                    beq       L976
                    bra       L978

Sne                 bsr       StrCMP
                    bne       L976
                    bra       L978

Sge                 bsr       StrCMP
                    bhs       L976
                    bra       L978

Sgt                 bsr       StrCMP
                    bhi       L976
                    bra       L978

Ilo                 ldd       7,Y
                    subd      1,Y
                    blt       L976
                    bra       L978

Ile                 ldd       7,Y
                    subd      1,Y
                    ble       L976
                    bra       L978

Ine                 ldd       7,Y
                    subd      1,Y
                    bne       L976
                    bra       L978

Ieq                 ldd       7,Y
                    subd      1,Y
                    beq       L976
                    bra       L978

Ige                 ldd       7,Y
                    subd      1,Y
                    bge       L976
                    bra       L978

Igt                 ldd       7,Y
                    subd      1,Y
                    ble       L978
L976                ldb       #$FF
                    bra       L980

L978                clrb
L980                clra
                    leay      6,Y
                    std       1,Y
                    lda       #3
                    sta       ,Y
                    rts

Beq                 ldb       8,Y
                    cmpb      2,Y
                    beq       L976
                    bra       L978

Bne                 ldb       8,Y
                    cmpb      2,Y
                    bne       L976
                    bra       L978

Rlo                 bsr       RLCMP
                    blo       L976
                    bra       L978

Rle                 bsr       RLCMP
                    bls       L976
                    bra       L978

Rne                 bsr       RLCMP
                    bne       L976
                    bra       L978

Req                 bsr       RLCMP
                    beq       L976
                    bra       L978

Rge                 bsr       RLCMP
                    bhs       L976
                    bra       L978

Rgt                 bsr       RLCMP
                    bhi       L976
                    bra       L978

RLCMP               pshs      Y
                    lda       $0B,Y               Get sign of 2nd #
                    anda      #1
                    ldb       5,y                 Get sign of 1st #
                    andb      #1
                    cmpr      a,b                 Same sign?
                    bne       L996                No, skip ahead
L988                leau      6,Y                 signs are the same
                    tsta
                    beq       L994                positive numbers
                    exg       U,Y                 invert them
L994                ldq       1,U
                    cmpd      1,Y
                    bne       L993
                    cmpw      3,Y
                    bne       L996
                    lda       5,U
                    cmpa      5,Y
L996                puls      PC,Y

L993                pshs      cc
                    eora      1,y
                    bpl       L992                no/both fractions
                    tstb
                    beq       L992                n1 = 0
                    tst       2,y
                    beq       L992                n2 = 0
*          eim   #1,0,s
                    fcb       $65,1,$60
L992                puls      pc,y,cc

* copy string
SCPCNST             clrb
                    ldu       exprSP
                    leay      -6,Y
                    stu       1,Y                 starting address
                    sty       SStop
L1004               cmpr      y,u
                    bcc       err47
                    lda       ,X+
                    sta       ,U+
                    cmpa      #$FF
                    beq       L1001
                    incb
                    bne       L1004
                    lda       #$FF
                    sta       ,U+
L1001               clra
                    std       3,y                 size of string
L1002               stu       exprSP
                    lda       #4
                    sta       ,Y                  type: string
                    rts

err47               ldb       #$2F
                    lbra      L356

L14                 tfr       u,d
                    ldw       fieldsiz
                    bra       L1007
* copy string to expression stack
SCPVAR              ldd       ,X++
                    addd      vectorba
                    tfr       D,U                 array vector
                    ldq       ,U                  address,size target
                    addd      WSbase
                    stw       fieldsiz
L1007               ldu       exprSP
                    leay      -6,y
                    stu       1,y                 starting address
                    sty       SStop
                    cmpd      BUPaddr
                    beq       L1009
                    addr      w,u
                    cmpr      y,u
                    bhs       err47               too big
                    ldu       1,y
                    pshs      x
                    tfr       d,x                 origin
                    stx       BUPaddr
L1003               lda       ,x+
                    sta       ,u+
                    cmpa      #$FF
                    beq       L1005
                    decw
                    bne       L1003
                    lda       #$FF
                    sta       ,u+
L1005               comw                          negate         left-over
                    incw
                    addw      fieldsiz
                    stw       3,y                 size of string
                    stw       BUPsize
                    puls      x
                    bra       L1002

L1009               ldw       BUPsize
                    stw       3,y
                    tfm       d+,u+
                    lda       #$FF
                    sta       ,u+
                    bra       L1002

STRconc             ldu       1,Y
                    ldw       3,y
                    incw
                    tfr       u,d
                    decd
                    tfm       u+,d+
                    std       exprSP
                    ldd       3,y
                    leay      6,y
                    addd      3,y
                    std       3,y                 length new string
                    rts

L15                 ldd       fieldsiz
                    leay      -6,Y
                    std       3,Y
                    stu       1,Y
                    lda       #5
                    sta       ,Y
                    rts

FLOAT               clrd
                    std       4,Y
                    ldd       1,Y
                    bne       L1012
                    stb       3,Y
                    lda       #2
                    sta       ,Y
                    rts

L1012               ldw       #$0210
                    tsta
                    bpl       L1014
                    negd
                    inc       5,Y
L1014               tsta
                    bne       L1016
                    ldw       #$0208
                    exg       A,B
L1016               tsta
                    bmi       L1018
L1020               decw
                    asld
                    bpl       L1020
L1018               std       2,Y
                    stw       ,Y
                    rts

float2              leay      6,Y
                    bsr       FLOAT
                    leay      -6,Y
                    rts

FIX                 ldw       1,y
                    ldd       4,y
                    tste
                    bgt       L1024
                    bmi       L1026
                    tstf
                    bpl       L1026
                    ldw       #1
                    bra       L1028

L1026               clrw
                    bra       L1030

L1024               sube      #$10
                    bhi       err52
                    bne       L1034
                    ldw       2,Y
                    rorb
                    bcc       L1030
                    cmpw      #$8000
                    bne       err52
                    tsta
                    bpl       L1030
                    bra       err52

L1034               pshs      b
                    tfr       e,b
                    ldw       2,y
                    cmpb      #$F8
                    bhi       L1036
                    tfr       f,a
                    tfr       e,f
                    clre
                    addb      #8
                    beq       L1038
L1036               lsrw
                    rora
                    incb
                    bne       L1036
L1038               puls      b
                    tsta
                    bpl       L1028
                    incw
                    bvc       L1028
err52               ldb       #$34
                    lbra      L356

L1028               rorb
                    bcc       L1030
                    comw
                    incw
L1030               stw       1,Y
                    std       4,y
                    lda       #1
                    sta       ,Y
                    rts

fixN1               leay      6,Y
                    bsr       FIX
                    leay      -6,Y
                    rts

fixN2               leay      $0C,Y
                    bsr       FIX
                    leay      -$0C,Y
                    rts

ABSrl               fcb       $62,$fe,$25
*          AIM   #$FE,5,y
                    rts

ABSint              ldd       1,Y
                    bpl       L1042
                    negd
                    std       1,Y
L1042               rts

PEEK                clra
                    ldb       [1,Y]
                    std       1,Y
                    rts

SGNrl               lda       2,Y
                    beq       L1044
                    lda       5,Y
                    anda      #1
                    bne       L1046
L1050               ldb       #1
                    bra       L1048

SGNint              ldd       1,Y
                    bmi       L1046
                    bne       L1050
L1044               clrb
                    bra       L1048

L1046               ldb       #$FF
L1048               sex
                    bra       L1052

ERR                 ldb       errcode
                    clr       errcode
L1054               clra
                    leay      -6,Y
L1052               std       1,Y
                    lda       #1
                    sta       ,Y
L1058               rts

POS                 ldb       charcoun
                    bra       L1054

SQRT                ldb       5,Y
                    asrb
                    lbcs      err67
                    ldb       #$1F
                    stb       <$6E
                    ldd       1,Y
                    beq       L1058
                    inca
                    asra
                    sta       1,Y
                    ldq       2,Y
                    bcs       L1060
                    lsrd
                    rorw
L1060               stq       -4,Y
                    clrd
                    clrw
                    stq       2,Y
                    stq       -8,Y
                    bra       L1064

L1070               orcc      #1
                    ldq       2,y
                    rolw
                    rold
                    dec       <$6E
                    beq       L1066
                    stq       2,y
                    bsr       L1068
L1064               ldb       -4,Y
                    subb      #$40
                    stb       -4,Y
                    ldd       -6,Y
                    sbcd      4,Y
                    std       -6,Y
                    ldd       -8,Y
                    sbcd      2,Y
                    std       -8,Y
                    bpl       L1070
L1072               andcc     #$FE
                    ldq       2,y
                    rolw
                    rold
                    dec       <$6E
                    beq       L1066
                    stq       2,y
                    bsr       L1068
                    ldb       -4,Y
                    addb      #$C0
                    stb       -4,Y
                    ldd       -6,Y
                    adcd      4,Y
                    std       -6,Y
                    ldd       -8,Y
                    adcd      2,Y
                    std       -8,Y
                    bmi       L1072
                    bra       L1070

L1066               andcc     #^Carry
                    bra       L1074

L1076               dec       1,Y
                    lbvs      equ0
L1074               rolw
                    rold
                    bpl       L1076
                    stq       2,Y
                    rts

L1068               ldq       -8,y
                    asl       -1,Y
                    rol       -2,Y
                    rol       -3,Y
                    rol       -4,Y
                    rolw
                    rold
                    asl       -1,y
                    rol       -2,y
                    rol       -3,y
                    rol       -4,y
                    rolw
                    rold
                    stq       -8,y
                    rts

MODint              lbsr      INTDIV
                    ldd       3,Y
                    std       1,Y
                    rts

MODrl               leau      -$0C,Y
                    ldw       #12
                    tfm       y+,u+
                    leay      -$0C,U
                    lbsr      RLDIV
                    bsr       INTrl
                    lbsr      RLMUL
                    lbra      RLSUB

INTrl               lda       1,Y
                    bgt       L1090
                    clrd
                    clrw
                    stq       1,Y
                    stb       5,Y
L1092               rts

L1090               cmpa      #$1F
                    bcc       L1092
                    leau      6,Y
                    ldb       -1,U
                    andb      #1
                    pshs      U,B
                    leau      1,Y
L1094               leau      1,U
                    suba      #8
                    bcc       L1094
                    beq       L1096
                    ldb       #$FF
L1098               aslb
                    inca
                    bne       L1098
                    andb      ,U
                    stb       ,U+
                    bra       L1100

L1096               leau      1,U
L1102               sta       ,U+
L1100               cmpu      1,S
                    bne       L1102
                    puls      U,B
                    orb       5,Y
                    stb       5,Y
                    rts

SQint               leay      -6,Y                If embedding, skip LEAY -6,y
                    ldd       7,Y                 Get # to square
                    std       1,Y                 Multiply it by itself (could embed MULD)
                    lbra      INTMUL

SQrl                leay      -6,Y
                    ldq       8,Y
                    stq       2,Y
                    ldd       6,Y
                    std       ,Y
                    lbra      RLMUL

VAL                 ldd       Sstack
                    ldu       Spointer
                    pshs      U,D
                    ldd       1,Y
                    std       Sstack
                    std       Spointer
                    std       exprSP
                    leay      6,Y
                    lbsr      L2008
                    puls      U,D
                    std       Sstack
                    stu       Spointer
                    lbcs      err67
                    rts

ADDR                lbsr      L724
                    leay      -6,Y
                    stu       1,Y
L1112               lda       #1
                    sta       ,Y
                    leax      1,X
                    rts

* Table of var type sizes
L1108               fcb       1,2,5,1

SIZE                lbsr      L724
                    leay      -6,y
                    cmpa      #4
                    bcc       L1106
                    leau      <L1108,PC
                    ldb       A,U
                    clra
                    bra       L1110

L1106               ldd       fieldsiz
L1110               std       1,Y
                    bra       L1112

equTRUE             ldd       #$FF
                    bra       L1114

equFALSE            clrd
L1114               leay      -6,Y
                    std       1,Y
                    lda       #3
                    sta       ,Y
                    rts

LNOTI               com       1,Y
                    com       2,Y
                    rts

LANDI               ldd       1,Y
                    andd      7,Y
                    bra       L1116

LXORI               ldd       1,Y
                    eord      7,Y
                    bra       L1116

LORI                ldd       1,Y
                    ord       7,Y
L1116               std       7,Y
                    leay      6,Y
                    rts

L1118               fcb       255,222,91,216,170
LOG10               bsr       LOG
                    leau      <L1118,PC
                    lbsr      RCPVAR
                    lbra      RLMUL

LOG                 pshs      X
                    ldb       5,Y
                    asrb
                    lbcs      err67
                    ldd       1,Y
                    lbeq      err67
                    pshs      A
                    ldb       #1
                    stb       1,Y
                    leay      <-$1A,Y
                    leax      <$1B,Y
                    leau      ,Y
                    lbsr      cprXU
                    lbsr      L1124
                    clrd
                    clrw
                    stq       <$14,Y
                    sta       <$18,Y
                    leax      L1126,PC
                    stx       <$19,Y
                    lbsr      L1128
                    leax      <$14,Y
                    leau      <$1B,Y
                    lbsr      cprXU
                    lbsr      L1130
                    leay      <$1A,Y
                    ldb       #2
                    stb       ,Y
*          oim   #1,5,y
                    fcb       $61,1,$25
                    puls      B
                    bsr       L1132
                    puls      X
                    lbra      RLADD

L1138               fcb       0,177,114,23,248

L1132               sex
                    bpl       L1136
                    negb
L1136               anda      #1
                    pshs      D
                    leau      <L1138,PC
                    lbsr      RCPVAR
                    ldb       5,Y
                    lda       1,S
                    cmpa      #1
                    beq       L1140
                    mul
                    stb       5,Y
                    ldb       4,Y
                    sta       4,Y
                    lda       1,S
                    mul
                    addb      4,Y
                    adca      #0
                    stb       4,Y
                    ldb       3,Y
                    sta       3,Y
                    lda       1,S
                    mul
                    addb      3,Y
                    adca      #0
                    stb       3,Y
                    ldb       2,Y
                    sta       2,Y
                    lda       1,S
                    mul
                    addb      2,Y
                    adca      #0
                    beq       L1142
                    ldw       3,y
L1144               inc       1,Y
                    lsrd
                    rorw
                    ror       5,Y
                    tsta
                    bne       L1144
                    stw       3,y
L1142               stb       2,Y
                    ldb       5,Y
L1140               andb      #$FE
                    orb       ,S
                    stb       5,Y
                    puls      PC,D

EXP                 pshs      X
                    ldb       1,Y
                    beq       L1146
                    cmpb      #7
                    ble       L1148
                    ldb       5,Y
                    rorb
                    rorb
                    eorb      #$80
                    lbra      L1150

L1148               cmpb      #$E4
                    lble      L1152
                    tstb
                    bpl       L1154
L1146               clr       ,-S
                    ldb       5,Y
                    andb      #1
                    beq       L1156
                    bra       L1158

L1154               lda       #$71
                    mul
                    adda      1,Y
                    ldb       5,Y
                    andb      #1
                    pshs      B,A
                    eorb      5,Y
                    stb       5,Y
                    ldb       ,S
L1162               lbsr      L1132
                    lbsr      RLSUB
                    ldb       1,Y
                    ble       L1160
                    addb      ,S
                    stb       ,S
                    ldb       1,Y
                    bra       L1162

L1160               puls      D
                    pshs      A
                    tstb
                    beq       L1156
                    nega
                    sta       ,S
                    orb       5,Y
                    stb       5,Y
L1158               leau      L1138,PC
                    lbsr      RCPVAR
                    lbsr      RLADD
                    dec       ,S
                    ldb       5,Y
                    andb      #1
                    bne       L1158
L1156               leay      <-$1A,Y
                    leax      <$1B,Y
                    leau      <$14,Y
                    lbsr      cprXU
                    lbsr      L1124
                    ldd       #$1000
                    clrw
                    stq       ,Y
                    stb       4,Y
                    leax      L1164,PC
                    stx       <$19,Y
                    bsr       L1128
                    leax      ,Y
                    leau      <$1B,Y
                    lbsr      cprXU
                    lbsr      L1130
                    leay      <$1A,Y
                    puls      B
                    addb      1,Y
                    bvs       L1150
                    lda       #2
                    std       ,Y
                    puls      PC,X

L1128               lda       #1
                    sta       <$9A
                    leax      L1166,PC
                    stx       <$95
                    leax      <$5F,X
                    stx       <$97
                    lbra      L1168

L1150               leay      -6,Y
                    puls      x
                    lbra      L916                0 or ovf

L2125               pshs      X
                    bsr       L1170
                    ldd       1,Y
                    lbeq      L1172
                    cmpd      #$0180
                    bgt       L1174               error 67
                    bne       L1176
                    ldd       3,Y
                    bne       L1174               error 67
                    lda       5,Y
                    lbeq      L1178
L1174               lbra      err67

L1176               lbsr      L1180
                    leay      <-$14,Y
                    leax      <$15,Y
                    leau      ,Y
                    lbsr      cprXU
                    lbsr      L1124
                    leax      <$1B,Y
                    lbra      L1182

L1170               ldb       5,Y
                    andb      #1
                    stb       <$6D
                    eorb      5,Y
                    stb       5,Y
                    rts

L2126               leau      <L1184,PC
                    pshs      U,X
                    bsr       L1170
                    ldd       1,Y
                    lbeq      L1178
                    cmpd      #$0180
                    bgt       L1174               error 67
                    bne       L1186
                    ldd       3,Y
                    bne       L1174               error 67
                    lda       5,Y
                    bne       L1174               error 67
                    lda       <$6D
                    bne       L1188
                    clrb
                    std       1,Y
                    puls      PC,U,X

L1188               leay      6,Y
                    puls      U,X
                    lbra      PI

L1186               bsr       L1180
                    leay      <-$14,Y
                    leax      <$1B,Y
                    leau      ,Y
                    lbsr      cprXU
                    lbsr      L1124
                    leax      <$15,Y
                    lbra      L1182

L1184               lda       5,Y
                    bita      #1
                    beq       L1192
                    ldu       WSbase
                    tst       1,U
                    beq       L1194
                    leau      <L1196,PC
                    lbsr      RCPVAR
                    bra       L1198

L1194               lbsr      PI
L1198               lbra      RLADD

L1192               rts

L1196               fcb       8,180,0,0,0

L1180               lda       <$6D
                    pshs      A
                    leay      -18,Y
                    ldd       #$0201
                    std       $0C,Y
                    lda       #$80
                    clrb
                    std       $0E,Y
                    clra
                    std       $10,Y
                    ldq       <$12,Y
                    stq       ,Y
                    stq       6,Y
                    ldd       <$16,Y
                    std       4,Y
                    std       $0A,Y
                    lbsr      RLMUL
                    lbsr      RLSUB
                    lbsr      SQRT
                    puls      A
                    sta       <$6D
                    rts

L2127               pshs      X
                    lbsr      L1170
                    ldb       1,Y
                    cmpb      #$18
                    blt       L1204
L1178               leay      6,Y
                    lbsr      PI
                    dec       1,Y
                    bra       L1206

L1204               leay      <-$1A,Y
                    ldd       #$1000
                    clrw
                    stq       ,Y
                    stb       4,Y
                    lda       ,y
                    ldb       <$1B,Y
                    ldw       1,y
                    bra       L1208

L1210               asra
                    rorw
                    ror       3,Y
                    ror       4,Y
                    decb
L1208               cmpb      #2
                    bgt       L1210
                    sta       ,y
                    stw       1,y
                    stb       <$1B,Y
                    leax      <$1B,Y
L1182               leau      $0A,Y
                    lbsr      cprXU
                    lbsr      L1124
                    clrd
                    clrw
                    stq       <$14,Y
                    sta       <$18,Y
                    leax      L1212,PC
                    stx       <$19,Y
                    lbsr      L1214
                    leax      <$14,Y
                    leau      <$1B,Y
                    lbsr      cprXU
                    lbsr      L1130
                    leay      <$1A,Y
L1206               lda       5,Y
                    ora       <$6D
                    sta       5,Y
                    ldu       WSbase
                    tst       1,U
                    beq       L1172
                    leau      L1216,PC
                    lbsr      RCPVAR
                    lbsr      RLMUL
                    bra       L1172

L2122               pshs      X
                    lbsr      L1218
                    leax      $0A,Y
                    bsr       L1220
                    lda       5,Y
L1230               eora      <$9C
L1224               sta       5,Y
L1172               lda       #2
                    sta       ,Y
                    puls      PC,X

L1220               leau      <$1B,Y
                    lbsr      cprXU
                    lbsr      L1130
                    leay      <$14,Y
                    leax      L1222,PC
                    leau      1,Y
                    lbsr      cprXU
                    lbra      RLMUL

L2123               pshs      X
                    bsr       L1218
                    leax      ,Y
                    bsr       L1220
                    lda       5,Y
                    eora      <$9B
                    bra       L1224

L2124               pshs      X
                    bsr       L1218
                    leax      $0A,Y
                    leau      <$1B,Y
                    lbsr      cprXU
                    lbsr      L1130
                    leax      ,Y
                    leay      <$14,Y
                    leau      1,Y
                    lbsr      cprXU
                    lbsr      L1130
                    ldd       1,Y
                    bne       L1226
                    leay      6,Y
                    ldd       #$7FFF
L1232               std       1,Y
                    lda       #$FF
                    std       3,Y
                    deca
                    bra       L1228

L1226               lbsr      RLDIV
                    lda       5,Y
L1228               eora      <$9B
                    bra       L1230

L1231               fcb       2,201,15,218,162

L1238               fcb       251,142,250,53,18

L1216               fcb       6,229,46,224,212

PI                  leau      <L1231,PC
                    lbra      RCPVAR

L1218               ldu       WSbase
                    tst       1,U
                    beq       L1236               radians
                    leau      <L1238,PC
                    lbsr      RCPVAR
                    lbsr      RLMUL               -> degrees
L1236               clr       <$9B
                    ldb       5,Y
                    andb      #1
                    stb       <$9C
                    eorb      5,Y
                    stb       5,Y
                    bsr       PI
                    inc       1,Y
                    lbsr      RLCMP
                    blt       L1240
                    lbsr      MODrl
                    bsr       PI
                    bra       L1244

L1240               dec       1,Y
L1244               lbsr      RLCMP
                    blt       L1246
                    inc       <$9B
*           eim   #1,$9C
                    fcb       5,1,$9c
                    lbsr      RLSUB
                    bsr       PI
L1246               dec       1,Y
                    lbsr      RLCMP
                    ble       L1248
*           eim   #1,$9B
                    fcb       5,1,$9c
                    inc       1,Y
*           oim   #1,11,y
                    fcb       $61,1,$2b
                    lbsr      RLADD
                    leay      -6,Y
L1248               leay      -$14,Y
                    leax      L1250,PC
                    stx       <$19,Y
                    leax      <$1B,Y
                    leau      <$14,Y
                    bsr       cprXU
                    lbsr      L1124
                    ldd       #$1000
                    clrw
                    stq       ,Y
                    clra
                    sta       4,Y
                    stq       $0A,Y
                    sta       $0E,Y
L1214               leax      L1252,PC
                    stx       <$95
                    leax      <$41,X
                    stx       <$97
                    clr       <$9A
L1168               ldb       #$25
                    stb       <$99
                    clr       <$9D
L1264               leau      <$1B,Y
                    ldx       <$95
                    cmpx      <$97
                    bcc       L1254
                    bsr       cprXU
                    leax      5,X
                    stx       <$95
                    bra       L1256

L1254               ldq       ,u
                    asrd
                    rorw
                    stq       ,u
                    ror       4,u
L1256               leax      ,Y
                    leau      5,Y
                    bsr       L1260
                    tst       <$9A
                    bne       L1262
                    leax      $0A,Y
                    leau      $0F,Y
                    bsr       L1260
L1262               jsr       [$19,Y]
                    inc       <$9D
                    dec       <$99
                    bne       L1264
                    rts

cprXU               ldq       1,X
                    stq       1,U
                    lda       ,X
                    sta       ,U
                    rts

L1260               ldb       ,X
                    sex
                    ldb       <$9D
                    lsrb
                    lsrb
                    lsrb
                    bcc       L1266
                    incb
L1266               pshs      B
                    beq       L1268
L1270               sta       ,U+
                    decb
                    bne       L1270
L1268               ldb       #5
                    subb      ,S+
                    beq       L1272
L1274               lda       ,X+
                    sta       ,U+
                    decb
                    bne       L1274
L1272               leau      -5,U
                    ldb       <$9D
                    andb      #7
                    beq       L1276
                    ldw       1,u
                    cmpb      #4
                    bcs       L1258
                    subb      #8
                    lda       ,X
L1278               asla
                    rol       4,U
                    rol       3,U
                    rolw
                    rol       ,U
                    incb
                    bne       L1278
                    stw       1,u
                    rts

L1258               asr       ,U
                    rorw
                    ror       3,U
                    ror       4,U
                    decb
                    bne       L1258
                    stw       1,u
L1276               rts

L1212               lda       $0A,Y
                    eora      ,Y
                    coma
                    bra       L1280

L1250               lda       <$14,Y
L1280               tsta
                    bpl       L1282
                    leax      ,Y
                    leau      $0F,Y
                    bsr       L1284
                    leax      $0A,Y
                    leau      5,Y
                    bsr       L1286
                    leax      <$14,Y
                    leau      <$1B,Y
                    bra       L1284

L1282               leax      ,Y
                    leau      $0F,Y
                    bsr       L1286
                    leax      $0A,Y
                    leau      5,Y
                    bsr       L1284
                    leax      <$14,Y
                    leau      <$1B,Y
                    bra       L1286

L1164               leax      <$14,Y
                    leau      <$1B,Y
                    bsr       L1286
                    bmi       L1284
                    bne       L1288
                    ldd       1,X
                    bne       L1288
                    ldd       3,X
                    bne       L1288
                    ldb       #1
                    stb       <$99
L1288               leax      ,Y
                    leau      5,Y
                    bra       L1284

L1126               leax      ,Y
                    leau      5,Y
                    bsr       L1284
                    cmpa      #$20
                    bcc       L1286
                    leax      <$14,Y
                    leau      <$1B,Y
L1284               ldq       1,x
                    addw      3,u
                    adcd      1,u
                    stq       1,X
                    lda       ,X
                    adca      ,U
                    sta       ,X
                    rts

L1286               ldq       1,x
                    subw      3,u
                    sbcd      1,u
                    stq       1,X
                    lda       ,X
                    sbca      ,U
                    sta       ,X
                    rts

L1124               ldb       ,U
                    clr       ,U
                    clra
                    ldw       1,u
                    addb      #4
                    bge       L1294
                    negb
                    lbra      L1258

L1296               asl       4,U
                    rol       3,U
                    rolw
                    rola
                    decb
L1294               bne       L1296
                    sta       ,u
                    stw       1,u
                    rts

L1130               lda       ,U
                    bpl       L1298
                    clrd
                    clrw
                    stq       ,U
                    sta       4,U
                    rts

L1298               ldq       ,u
                    beq       L1304
                    pshs      x
                    ldx       #4
L1302               leax      -1,x
                    asl       4,u
                    rolw
                    rold
                    bpl       L1302
L1300               std       1,u
                    exg       d,w
                    tfr       x,w
                    stf       ,u
                    puls      x
                    addd      #1
                    andb      #$FE
                    std       3,U
                    bcc       L1304
                    inc       2,U
                    bne       L1304
                    inc       1,U
                    bne       L1304
                    ror       1,U
                    inc       ,U
L1304               rts

L1252               fcb       12,144,253,170,34
                    fcb       7,107,25,193,88
                    fcb       3,235,110,191,38
                    fcb       1,253,91,169,171
                    fcb       0,255,170,221,185
                    fcb       0,127,245,86,239
                    fcb       0,63,254,170,183
                    fcb       0,31,255,213,86
                    fcb       0,15,255,250,171
                    fcb       0,7,255,255,85
                    fcb       0,3,255,255,235
                    fcb       0,1,255,255,253
                    fcb       0,1,0,0,0
L1222               fcb       0,155,116,237,168
L1166               fcb       11,23,33,127,126
                    fcb       6,124,200,251,48
                    fcb       3,145,254,248,243
                    fcb       1,226,112,118,227
                    fcb       0,248,81,134,1
                    fcb       0,126,10,108,58
                    fcb       0,63,129,81,98
                    fcb       0,31,224,42,107
                    fcb       0,15,248,5,81
                    fcb       0,7,254,0,170
                    fcb       0,3,255,128,21
                    fcb       0,1,255,224,3
                    fcb       0,0,255,248,0
                    fcb       0,0,127,254,0
                    fcb       0,0,63,255,128
                    fcb       0,0,31,255,224
                    fcb       0,0,15,255,248
                    fcb       0,0,7,255,254
                    fcb       0,0,4,0,0
L1382               fcb       14,18,20,162,187,64
                    fcb       230,45,54,25,98,233
                    fcb       0,16,63,0,57

RND                 clrw
                    stw       <$4C
                    clr       ,-s
                    lda       2,Y
                    beq       L1312
                    ldb       5,Y
                    bitb      #1
                    bne       L1314
                    com       ,S
                    bra       L1312

L1314               addb      #$FE
                    addb      1,Y
                    lda       4,Y
                    std       <$52
                    ldd       2,Y
                    std       <$50
L1312               lda       <$53
                    ldb       <$57
                    mul
                    std       <$4E
                    tfr       a,f
                    lda       <$52
                    ldb       <$57
                    mul
                    addr      d,w
                    bcc       L1316
                    inc       <$4C
L1316               lda       <$53
                    ldb       <$56
                    mul
                    addr      d,w
                    bcc       L1318
                    inc       <$4C
L1318               stw       <$4D
                    ldw       <$4C
                    lda       <$51
                    ldb       <$57
                    mul
                    addr      d,w
                    lda       <$52
                    ldb       <$56
                    mul
                    addr      d,w
                    lda       <$53
                    ldb       <$55
                    mul
                    addr      d,w
                    lda       <$50
                    ldb       <$57
                    mul
                    addr      b,e
                    lda       <$51
                    ldb       <$56
                    mul
                    addr      b,e
                    lda       <$52
                    ldb       <$55
                    mul
                    addr      b,e
                    lda       <$53
                    ldb       <$54
                    mul
                    addr      b,e
                    ldd       <$4E
                    addd      <$5A
                    exg       d,w
                    adcd      <$58
                    stq       <$50
                    tst       ,S+
                    bne       L1320
L1326               clr       1,Y
                    sta       2,y
                    lda       #$1F
                    pshs      A
                    lda       2,y
                    bmi       L1322
                    andcc     #^Carry
L1324               dec       ,S
                    beq       L1322
                    dec       1,Y
                    rolw
                    rold
                    bpl       L1324
L1322               stq       2,Y
*          aim   #$FE,5,y
                    fcb       $62,$fe,$25
                    puls      PC,B

L1320               leay      -6,y
                    rorw
                    clr       ,y
                    rolw                          sign           now +
                    bsr       L1326
                    lbra      RLMUL

LEN                 ldq       1,Y
                    std       exprSP
L1328               stw       1,Y
                    lda       #1
                    sta       ,Y
                    rts

ASC                 ldd       1,Y
                    std       exprSP
                    ldf       [1,Y]
                    clre
                    bra       L1328

CHR$                ldd       1,Y
                    tsta
                    lbne      err67
                    ldu       exprSP
                    stu       1,Y
                    stb       ,U+
                    lbsr      L1366
                    ldd       #1
                    std       3,y
                    sty       SStop
                    cmpr      y,u
                    lbcc      err47
                    rts

LEFT$               ldd       1,Y
                    ble       isNull
                    addd      7,Y
                    tfr       D,U                 address new end
                    cmpd      exprSP
                    bcc       L1334
                    bsr       L1336               shorten current string
                    ldd       1,y
                    std       9,y
L1334               leay      6,Y
                    rts

isNull              leay      6,Y
                    ldu       1,Y
                    clrd
                    std       3,y
                    bra       L1336

RIGHT$              ldw       1,Y
                    ble       isNull
                    ldd       exprSP
                    subr      w,d
                    decd      new                 starting address
                    cmpd      7,Y                 current start address
                    bls       L1338
                    stw       9,y
                    incw                          terminate      also
                    ldu       7,Y
                    tfm       d+,u+
                    stu       exprSP
L1338               leay      6,Y
                    rts

MID$                ldd       1,Y                 size of piece
                    ble       L1342
                    ldd       7,Y                 it's starting offset
                    bgt       L1344
L1342               ldd       1,Y                 = LEFT$
                    leay      6,Y
                    std       1,Y
                    bra       LEFT$

L1344               decd
                    beq       L1342
                    addd      $0D,Y               start address piece
                    cmpd      exprSP
                    bcs       L1348               piece exists
                    leay      6,Y
                    bra       isNull

L1348               clrw
                    ldf       2,y
                    leay      $0C,Y
                    stw       3,y
                    ldu       1,Y
                    tfm       d+,u+
                    bra       L1337

TRIM$               ldu       exprSP
                    ldw       3,y
                    incw                          adjust for loop struct.
                    leau      -1,U
L1354               decw
                    beq       L1336
                    lda       ,-U
                    cmpa      #$20
                    beq       L1354
                    leau      1,U
L1336               stw       3,y
L1337               lda       #$FF
                    sta       ,U+
                    stu       exprSP
                    rts

SUBSTR              pshs      Y,X
                    ldw       exprSP
                    subw      1,Y
                    addw      7,Y
                    incw
                    ldx       7,Y
                    ldy       1,Y
                    bra       L1356

* compare strings *
L202                pshs      Y,X
L200                lda       ,X+
                    cmpa      #$FF
                    beq       L198
                    cmpa      ,Y+
                    beq       L200
                    puls      Y,X
                    leay      1,Y
L1356               cmpr      W,Y
                    bls       L202
                    clrd                          no             match
                    bra       L1360

L198                puls      Y,X
                    tfr       Y,D
                    ldx       2,S
                    subd      1,X
                    incd                          starting offset
L1360               puls      Y,X
                    leay      6,Y
                    std       1,Y
                    lda       #1
                    sta       ,Y
                    rts

STR$int             ldb       #2
                    bra       L1362

STR$rl              ldb       #3
L1362               lda       charcoun
                    ldu       Spointer
                    pshs      U,X,A
                    lbsr      L46
                    bcs       err67
                    ldx       3,S
                    ldu       exprSP
                    leay      -6,y
                    stu       1,y
                    sty       SStop
                    ldw       Spointer
                    subr      x,w
                    tfr       w,d                 string length
                    addr      u,d
                    cmpr      y,d
                    lbcc      err47               string too long
                    stw       3,y
                    tfm       x+,u+               copy to expression stack
                    lda       #$FF
                    sta       ,U+
L1361               stu       exprSP
                    lda       #4
                    sta       ,y
                    puls      U,X,A               reset pointers
                    sta       charcoun
                    stu       Spointer
                    rts

err67               ldb       #$43
                    lbra      L356

TAB                 ldw       1,Y
                    blt       err67
                    sty       SStop
                    ldu       exprSP
                    stu       1,Y
                    ldb       charcoun
                    clra
                    subr      d,w                 W = number spaces
                    bhi       L1365
                    clrw
L1365               stw       3,y
                    beq       L1366
                    tfr       u,d
                    addr      w,d
                    cmpr      y,d
                    lbcc      err47               too big
                    lda       #$20
                    pshs      a
                    tfm       s,u+                assemble string
                    leas      1,s
L1366               lda       #$FF
                    sta       ,U+
                    stu       exprSP
                    lda       #4
                    sta       ,Y
                    rts

DATE$               pshs      X
                    leay      -6,Y
                    leax      -6,Y
                    ldu       exprSP
                    stu       1,Y
                    ldd       #17
                    std       3,y
                    os9       F$Time
                    bcs       L1371
                    bsr       L1370
                    lda       #$2F
                    bsr       L1372
                    lda       #$2F
                    bsr       L1372
                    lda       #$20
                    bsr       L1372
                    lda       #$3A
                    bsr       L1372
                    lda       #$3A
                    bsr       L1372
L1371               puls      x
                    bra       L1366

L1372               sta       ,U+
* byte to ascii
L1370               lda       ,X+
                    ldb       #$2F
L1374               incb
                    suba      #$0A
                    bcc       L1374
                    stb       ,U+
                    ldb       #$3A
L1376               decb
                    inca
                    bne       L1376
                    stb       ,U+
                    rts

EOF                 lda       2,Y
                    ldb       #6
                    os9       I$GetStt
                    bcc       L1378
                    cmpb      #$D3
                    bne       L1378
                    ldb       #$FF
                    bra       L1380

L1378               ldb       #0
L1380               clra
                    std       1,Y
                    lda       #3
                    sta       ,Y
                    rts

L46                 pshs      PC,X,D
                    aslb
                    leax      <L1398,PC
                    ldd       B,X
                    leax      D,X
                    stx       4,S
                    puls      PC,X,D

* table
L1398               fdb       WRITLN-L1398
                    fdb       PRintg-L1398
                    fdb       PRintg-L1398
                    fdb       PRreal-L1398
                    fdb       PRbool-L1398
                    fdb       PRstring-L1398
                    fdb       READLN-L1398
                    fdb       L2006-L1398
                    fdb       L2007-L1398
                    fdb       L2008-L1398
                    fdb       L2009-L1398
                    fdb       L2010-L1398
                    fdb       Strterm-L1398
                    fdb       L2012-L1398
                    fdb       setFP-L1398
                    fdb       err48-L1398
                    fdb       L2015-L1398
                    fdb       PRNTUSIN-L1398
                    fdb       L1632-L1398
                    fdb       L2018-L1398

*
L1540               fcb       6,2,39,16,3,232,0,100,0,10
L1490               fcb       4,160,0,0,0
                    fcb       7,200,0,0,0
                    fcb       10,250,0,0,0
                    fcb       14,156,64,0,0
                    fcb       17,195,80,0,0
                    fcb       20,244,36,0,0
                    fcb       24,152,150,128,0
                    fcb       27,190,188,32,0
                    fcb       30,238,107,40,0
                    fcb       34,149,2,249,0
                    fcb       37,186,67,183,64
                    fcb       40,232,212,165,16
                    fcb       44,145,132,231,42
                    fcb       47,181,230,32,244
                    fcb       50,227,95,169,50
                    fcb       54,142,27,201,192
                    fcb       57,177,162,188,46
                    fcb       60,222,11,107,58
L1486               fcb       64,138,199,35,4
L1668               fcc       /True/
                    fcb       255
L1672               fcc       /False/
                    fcb       255

AtoITR              pshs      U
                    leay      -6,Y
* clear negative,decpoint,digits
                    clrd
                    clrw
                    stq       expneg
                    sta       decimals
                    stq       2,Y
                    sta       1,Y
                    lbsr      L1418               check string
                    bcc       L1420
                    leax      -1,X
                    cmpa      #$2C                , ??
                    bne       err59
                    bra       L1424

L1420               cmpa      #$24                hex number?
                    lbeq      L1426
                    cmpa      #$2B                + ??
                    beq       L1428
                    cmpa      #$2D                - ??
                    bne       L1430
                    inc       negativ
L1428               lda       ,X+
L1430               cmpa      #$2E                . ??
                    bne       L1432
                    tst       decpoint
                    bne       err59               only one allowed
                    inc       decpoint
                    bra       L1428

L1432               lbsr      L1434
                    bcs       L1436               not a number
                    pshs      A
                    inc       digits
                    ldq       2,Y
                    bita      #$E0
                    bne       L1440
                    rolw
                    rold
                    stq       2,Y
                    rolw
                    rold
                    rolw
                    rold
                    addw      4,Y
                    adcd      2,Y
                    bcs       L1440
                    addf      ,S+
                    bcc       L1442
                    adde      #1
                    bcc       L1442
                    incd
                    beq       err60
L1442               stq       2,Y
                    tst       decpoint
                    beq       L1428
                    inc       decimals
                    bra       L1428

L1440               leas      1,S
err60               ldb       #$3C
                    bra       L1448

err59               ldb       #$3B
L1448               stb       errcode
                    coma
                    puls      PC,U

L1436               eora      #$45                = E
                    anda      #$DF
                    beq       L1450               exp. number
                    leax      -1,X
                    tst       digits
                    beq       err59
                    tst       decpoint
                    bne       L1454               real number
                    ldd       2,Y
                    bne       L1454               large number
L1424               ldd       4,Y
                    bmi       L1454               large number
                    tst       negativ
                    beq       L1456
                    negd
L1456               std       1,Y                 integer number
L1504               lda       #1
                    lbra      L1458

* exponential numbers *
L1450               lda       ,X
                    cmpa      #$2B                + ??
                    beq       L1460
                    cmpa      #$2D                - ??
                    bne       L1462
                    inc       expneg
L1460               leax      1,X
L1462               lbsr      number
                    bcs       err59
                    tfr       A,B
                    lbsr      number
                    bcc       L1466
                    leax      -1,X
                    bra       L1468
L1466               pshs      A
                    lda       #$0A
                    mul                           D*10
                    addb      ,S+
L1468               tst       expneg
                    bne       L1470
                    negb
L1470               addb      decimals
                    stb       decimals
* real numbers *
L1454               ldb       #$20
                    stb       1,Y
                    ldq       2,Y
                    bne       L1472               refers to regs.d
                    tstw
                    bne       L1472
                    sta       1,Y                 zero!!
                    bra       L1474
L1472               tsta
                    bmi       L1476
                    andcc     #^Carry
L1478               dec       1,Y
                    rolw
                    rold
                    bpl       L1478
                    stq       2,y
L1476               clr       expneg
                    ldb       decimals
                    beq       L1480               whole number
                    bpl       L1482
                    negb
                    inc       expneg
L1482               cmpb      #$13
                    bls       L1484
                    subb      #$13
                    pshs      B
                    leau      L1486,PCR
                    bsr       L1488
                    puls      B
                    lbcs      err60
L1484               decb
                    lda       #5
                    mul
                    leau      L1490,PCR
                    leau      B,U
                    bsr       L1488
                    lbcs      err60
L1480               lda       5,Y                 add sign
                    anda      #$FE
                    ora       negativ
                    sta       5,Y
L1474               lda       #2                  real number
L1458               sta       ,Y
                    andcc     #$FE
                    puls      PC,U
L1488               leay      -6,Y
                    ldq       ,U
                    stq       1,Y
                    ldb       4,U
                    stb       5,Y
                    lda       expneg
                    lbeq      RLDIV
                    lbra      RLMUL
* convert hex to decimal *
L1426               lbsr      number
                    bcc       L1496               0-9
                    anda      #$DF
                    cmpa      #$41                A ??
                    bcs       L1500
                    cmpa      #$46                F ??
                    bhi       L1500
                    suba      #$37                conversion
L1496               inc       digits
                    tfr       a,e
                    ldd       1,y
                    bita      #$F0
                    lbne      err60
                    asld
                    asld
                    asld
                    asld
                    addr      e,b
                    std       1,y
                    bra       L1426
L1500               leax      -1,X
                    tst       digits
                    lbeq      err59
                    lbra      L1504
* ----------------- *
L2008               pshs      X
                    ldx       Spointer
                    lbsr      AtoITR
                    bcc       L1508
L1518               puls      PC,X
L1508               cmpa      #2
                    beq       L1510
                    lbsr      FLOAT
L1510               lbsr      L1514
                    bcs       L1516
                    ldb       #$3D                error 61
                    stb       errcode
                    coma
                    puls      PC,X
L1516               stx       Spointer
                    clra
                    puls      PC,X
L2006               pshs      X
                    ldx       Spointer
                    lbsr      AtoITR
                    bcs       L1518
                    cmpa      #1
                    bne       err58
                    tst       1,Y
                    beq       L1510
                    bra       err58
L2007               pshs      X
                    ldx       Spointer
                    lbsr      AtoITR
                    bcs       L1518
                    cmpa      #1
                    beq       L1510
err58               ldb       #$3A
                    stb       errcode
                    coma
                    puls      PC,X
*  verify string  *
L2010               pshs      U,X
                    leay      -6,Y
                    ldu       exprBase
                    stu       1,Y
                    lda       #4
                    sta       ,Y
                    clrb
                    ldx       Spointer
L1526               lda       ,X+
                    bsr       L1522
                    bcs       L1524
                    sta       ,U+
                    incb
                    bra       L1526
L1524               stx       Spointer
                    lda       #$FF
                    sta       ,U+
                    stu       exprSP
                    clra
                    std       3,y
                    puls      PC,U,X
* Boolean -> internal repr. *
L2009               pshs      X
                    leay      -6,Y
                    lda       #3
                    sta       ,Y
                    clr       2,Y
                    ldx       Spointer
                    bsr       L1418
                    bcs       L1528
                    leax      3,x
                    anda      #$DF
                    cmpa      #$54                = T(rue)
                    beq       L1530
                    leax      1,x
                    eora      #$46                = F(alse)
                    beq       L1532
                    bra       err58
L1530               com       2,Y
L1532               bsr       L1418
L1528               stx       Spointer
                    clra
                    puls      PC,X
* validate characters *
L1514               lda       ,X+
                    cmpa      #$20                = space?
                    bne       L1522
                    bsr       L1418
                    bcc       L1534
                    bra       L1536
L1418               lda       ,X+
                    cmpa      #$20                = space?
                    beq       L1418               skip them
L1522               cmpa      <$DD
                    beq       L1536
                    cmpa      #$0D                = CR?
                    beq       L1534
                    cmpa      #$FF                = end of string?
                    beq       L1534
                    andcc     #$FE
                    rts
L1534               leax      -1,X
L1536               orcc      #1
                    rts

* integer to ASCII *
ItoA                pshs      U,X
                    clrw
                    ste       digits
                    ste       negativ
                    lda       #4
                    sta       <$7E
                    ldd       1,Y
                    bpl       L1538
                    negd
                    inc       negativ
L1538               leau      L1540,PC
L1552               clrf
                    leau      2,U
L1544               subd      ,U
                    bcs       L1542
                    incf
                    bra       L1544

L1542               addd      ,U
                    tstw
                    beq       L1548
L1546               ince
                    addf      #$30                convert to ASCII
                    stf       ,x+
                    inc       digits
L1548               dec       <$7E
                    bne       L1552
                    orb       #$30                convert to ASCII
                    stb       ,x
                    inc       digits
                    leay      6,Y
                    puls      PC,U,X

* real to ASCII *
RtoA                pshs      U,X
                    clrw
                    stw       expneg              + digits
                    stw       negativ             + decimals
                    stw       <$7B
                    leau      ,X
                    ldb       #$30                ASCII 0
                    pshs      b
                    ldw       #10                 Fill buffer with 10 of them
                    tfm       s,u+
                    leas      1,s
                    ldd       1,Y
                    bne       L1556
                    inca
                    lbra      L1558

L1556               ldb       5,Y
                    bitb      #1
                    beq       L1560
                    stb       negativ
                    andb      #$FE
                    stb       5,Y
L1560               ldd       1,Y
                    bpl       L1562
                    inc       expneg
                    nega
L1562               cmpa      #3
                    bls       L1564
                    ldb       #$9A
                    mul
                    lsra
                    tfr       A,B
                    tst       expneg
                    beq       L1566
                    negb
L1566               stb       decimals
                    cmpa      #$13
                    bls       L1568
                    pshs      A
                    leau      L1486,PC
                    lbsr      L1488
                    puls      A
                    suba      #$13
L1568               leau      L1490,PC
                    deca
                    ldb       #5
                    mul
                    leau      D,U
                    lbsr      L1488
L1564               ldq       2,Y
                    tst       1,Y
                    beq       L1580
                    bpl       L1572
L1574               lsrd
                    rorw
                    ror       <$7C
                    inc       1,Y
                    bne       L1574
                    bra       L1580

L1572               andcc     #^Carry
                    rolw
                    rold
                    rol       <$7B
                    dec       1,Y
                    bne       L1572
                    sta       2,Y
                    inc       decimals
                    lda       <$7B
                    bsr       L1550
                    lda       2,Y
L1580               clr       <$7B
                    rolw
                    rold
                    rol       <$7B
                    stq       2,Y
                    lda       <$7B
                    sta       <$7C
                    lda       2,y
                    rolw
                    rold
                    rol       <$7B
                    rolw
                    rold
                    rol       <$7B
                    addw      4,Y
                    adcd      2,Y
                    pshs      A
                    lda       <$7B
                    adca      <$7C
                    bsr       L1550
                    lda       digits
                    cmpa      #9
                    puls      A
                    beq       L1578
                    tstd
                    bne       L1580
                    tstw
                    bne       L1580
L1578               sta       ,Y
                    lda       digits
                    cmpa      #9
                    bcs       L1582
                    ldb       ,Y
                    bpl       L1582
L1584               lda       ,-X
                    inca
                    sta       ,X
                    cmpa      #$39                = 9?
                    bls       L1582
                    lda       #$30                =0
                    sta       ,X
                    cmpx      ,S
                    bne       L1584
                    inc       ,X
                    inc       decimals
L1582               lda       #9
L1558               sta       digits
                    leay      6,Y
                    puls      PC,U,X

L1550               ora       #$30                to ASCII
                    sta       ,X+
                    inc       digits
                    rts

READLN              pshs      Y,X
                    ldx       Sstack
                    stx       Spointer
                    lda       #1
                    sta       charcoun
                    ldy       #$0100
                    lda       IOpath
                    os9       I$ReadLn
                    bra       L1586

WRITLN              pshs      Y,X
                    ldx       Sstack
                    ldy       Spointer
                    subr      x,y
                    beq       L1588
                    stx       Spointer
                    lda       IOpath
                    os9       I$WritLn
L1586               bcc       L1588
                    stb       errcode
L1588               puls      PC,Y,X

setFP               pshs      U,X
                    ldd       ,Y                  type of filepointer
                    cmpa      #2
                    beq       L1590               real
                    ldu       1,Y                 integer
                    bra       L1592

L1590               tstb                          If exponent is <=0, Seek to 0
                    bgt       L1594               Positive value, go calculate longint for SEEK
                    ldu       #0                  seek #0
L1592               ldx       #0
                    bra       L1596

L1594               subb      #$20                Only up to 2^32 allowed
                    bcs       L1597               Good, continue
                    ldb       #$4E                error 78 (seek error)
                    coma
                    bra       L1600

L1597               lda       #$FF                Force Value to -1 to -32
                    tfr       d,x                 Move into X for counter
                    ldq       2,y                 Get mantissa
L1598               lsrd                          Calculate to power of exponent
                    rorw
                    leax      1,x                 Do until done
                    bne       L1598
                    tfr       d,x                 Move 32 bit result to proper regs for SEEK
                    tfr       w,u
L1596               lda       IOpath              Do the seek
                    os9       I$Seek
                    bcc       L1602
L1600               stb       errcode
L1602               puls      PC,U,X

* print real numbers *
PRreal              pshs      U,X
                    leas      -10,S
                    leax      ,S
                    lbsr      RtoA
                    pshs      X
                    lda       #9
                    leax      9,X
L1608               ldb       ,-X
                    cmpb      #$30
                    bne       L1606
                    deca
                    cmpa      #1
                    bne       L1608               skip 0s
L1606               sta       digits
                    puls      X
                    ldb       decimals
                    bgt       L1610
                    negb
                    tfr       B,A
                    cmpb      #9
                    bhi       L1612
                    addb      digits
                    cmpb      #9
                    bhi       L1612
*  0 < x < 1  *
                    pshs      A
                    lbsr      L1614
                    clra
                    lbsr      L1616
                    puls      B
                    tstb
                    beq       L1618
                    lbsr      L1620
L1618               lda       digits
                    bra       L1622

*  real number  *
L1610               cmpb      #9
                    bhi       L1612
                    lbsr      L1614
                    tfr       B,A
                    bsr       L1624
                    lbsr      L1616
                    lda       digits
                    suba      decimals
                    bls       L1626
L1622               bsr       L1624
L1626               leas      10,S
                    clra
                    puls      PC,U,X

*  exponential number  *
L1612               lbsr      L1614
                    lda       #1
                    bsr       L1624
                    bsr       L1616
                    lda       digits
                    deca
                    bne       L1628
                    inca
L1628               bsr       L1624
                    bsr       L1630
                    bra       L1626

*  exponent  *
L1630               lde       #$45                = E
                    lda       decimals
                    deca
                    pshs      A
                    bpl       L1634
                    neg       ,S
                    ldf       #$2D                = -
                    bra       L1638

L1634               ldf       #$2B                = +
L1638               puls      B
                    clra
L1644               subb      #$0A
                    bcs       L1642
                    inca
                    bra       L1644
L1642               addb      #$0A                exp. in D
                    addd      #$3030              -> ASCII
                    pshs      d
                    pshsw     exp.                on stack
                    ldb       #4
                    bsr       L1650
                    cmpw      #4                  space left to print it?
                    beq       L1646
                    leas      4,s                 no, clean up stack
                    rts

L1646               tfm       s+,d+
                    std       Spointer
                    rts

*
L1624               tfr       A,B
L1625               tstb
                    beq       L1648
                    bsr       L1650
                    tfm       x+,d+
L1649               std       Spointer
L1648               rts

*
L1650               tfr       s,w
                    subw      #64
                    subw      Spointer            w holds max. length
                    clra
                    cmpr      w,d
                    bhs       L1651               too long: truncate
                    tfr       d,w
L1651               ldb       charcoun
                    addr      f,b                 update counter
                    stb       charcoun
                    ldd       Spointer            destination
                    rts

* ---------------- *
L1660               lda       #$20                = space
                    bra       L1632

L1616               lda       #$2E                = .
L1632               pshs      U,A
                    leau      <-$40,S
                    cmpu      Spointer
                    bhi       L1652               space left!!
                    cmpa      #$0D                CR ??
                    beq       L1652
                    lda       #47                 error 47
                    sta       errcode
                    coma
                    bra       L1654

L1652               ldu       Spointer
                    sta       ,U+
                    stu       Spointer
                    inc       charcoun
L1654               puls      PC,U,A

*
spacing             lda       #$20                = space
L1662               tstb                          0 chars?
                    beq       L1656               Yes, return
                    pshs      a
                    bsr       L1650
                    tfm       s,d+
                    leas      1,s
                    std       Spointer
L1656               rts

* NOTE: Should use LDA <negative, faster, and A not required
L1800               tst       negativ
                    beq       L1660
L1614               tst       negativ
                    beq       L1656
L1636               lda       #$2D                = -
                    bra       L1632

L1640               lda       #$2B                = +
                    bra       L1632

L1620               lda       #$30                = 0
                    bra       L1662

*  print string  *
PRstring            pshs      X
                    ldx       1,Y
                    ldd       3,y
L1670               bsr       L1625
                    clra
                    puls      PC,X

* value of boolean variable *
PRbool              pshs      X
                    leax      L1668,PC            = TRUE
                    ldb       #4                  # chars to print
                    lda       2,Y
                    bne       L1670
                    leax      L1672,PC            = FALSE
                    incb                          5 chars to print
                    bra       L1670

* print integers *
PRintg              pshs      X
                    ldx       #$26                var.space in DP
                    lbsr      ItoA
                    tst       negativ             NOTE: USE LDB instead
                    beq       L1711
                    lda       #$2D                = -
                    sta       ,-x
                    inc       digits
L1711               ldb       digits
                    bra       L1670

* pad with spaces (TAB) *
L2015               tfr       A,B
L1712               subb      charcoun
                    bls       L1676
                    bsr       spacing
L1676               clra
                    rts

* pad field with spaces *
L2012               lda       charcoun
                    anda      #$0F
                    ldb       #17                 16 chars/field
                    subr      a,b
                    bra       spacing

* terminate string *
Strterm             lda       #$0D                /CR/
                    clr       charcoun
                    lbsr      L1632
L1680               clra
                    rts

* justification of print using
L1744               clrb
                    stb       justify
                    cmpa      #$3C                = <
                    beq       L1688
                    cmpa      #$3E                = >
                    bne       L1690
                    incb
                    bra       L1688

L1690               cmpa      #$5E                = ^
                    bne       ckmarker
                    decb
L1688               stb       justify
                    lda       ,X+
ckmarker            cmpa      #$2C                = ,
                    beq       L1694
                    cmpa      #$FF
                    bne       L1696
                    lda       <$94
                    beq       L1698
                    leax      -1,X
                    bra       L1700

L1698               ldx       <$8E
                    tst       <$DC
                    beq       L1702
                    clr       <$DC
                    bra       L1694

L1696               cmpa      #$29                = )
                    beq       L1704
L1702               orcc      #1
                    rts

L1704               lda       <$94
                    beq       L1702
L1700               dec       <$92
                    bne       L1706
                    ldu       userSP
                    pulu      Y,A
                    sta       <$92
                    sty       <$90
                    stu       userSP
                    lda       ,X+
                    dec       <$94
                    bra       ckmarker

L1706               ldx       <$90
L1694               stx       <$8C
                    andcc     #$FE
                    rts

* chars recognized by PRINT USING
L1726               fcb       73                  Integer
                    fdb       L2050-L1726
L2051Bas            equ       *
                    fcb       72                  Hexadecimal
                    fdb       L2051
L2052Bas            equ       *
                    fcb       82                  Real
                    fdb       L2052
L2053Bas            equ       *
                    fcb       69                  Exponential
                    fdb       L2053
L2054Bas            equ       *
                    fcb       83                  String
                    fdb       L2054
L2055Bas            equ       *
                    fcb       66                  Boolean
                    fdb       L2055
L2056Bas            equ       *
                    fcb       84                  Tab
                    fdb       L2056
L2057Bas            equ       *
                    fcb       88                  X - space
                    fdb       L2057
L2058Bas            equ       *
                    fcb       39                  ' - literal string
                    fdb       L2058
                    fcb       0                   end of table

* Tab function
L2056               equ       *-L2056Bas
                    bsr       ckmarker
                    bcs       err63
                    ldb       fieldwid
                    lbsr      L1712
                    bra       L1714

* print spaces (X) *
L2057               equ       *-L2057Bas
                    bsr       ckmarker
                    bcs       err63
                    ldb       fieldwid
                    lbsr      spacing
                    bra       L1714

* print literal string *
L2058               equ       *-L2058Bas
                    pshs      x
                    clrb
L1718               cmpa      #$FF
                    beq       err63
                    cmpa      #$27                = '
                    beq       L1716
                    incb
                    lda       ,X+
                    bra       L1718
L1716               puls      x
                    leax      -1,x
                    lbsr      L1625
                    leax      1,x
                    lda       ,X+
                    lbsr      ckmarker
                    bcs       err63
                    bra       L1714

PRNTUSIN            pshs      Y,X
                    clr       <$DC
                    inc       <$DC
L1714               ldx       <$8C
                    bsr       L1720
                    bcs       L1722
                    cmpa      #$28
                    bne       err62
                    lda       <$92
                    stb       <$92
                    beq       err62
                    inc       <$94
                    ldu       userSP
                    ldy       <$90
                    pshu      Y,A
                    stu       userSP
                    stx       <$90
                    lda       ,X+
L1722               leay      <L1726,PC
                    clrb
L1730               pshs      A
                    eora      ,Y
                    anda      #$DF
                    puls      A
                    beq       L1728
                    leay      3,Y
                    incb
                    tst       ,Y
                    bne       L1730
err63               ldb       #$3F
                    bra       L1732

err62               ldb       #$3E
L1732               stb       errcode
                    coma
                    puls      PC,Y,X

L1728               stb       subrcode
                    ldd       1,Y
                    leay      D,Y
                    bsr       L1720
                    bcc       L1734
                    ldb       #1
L1734               stb       fieldwid
                    jmp       ,Y

* calculate field width
L1720               bsr       number
                    bcs       L1736
                    tfr       A,B
                    bsr       number
                    bcs       L1738
                    bsr       L1740
                    bsr       number
                    bcs       L1738
                    bsr       L1740
                    tsta
                    beq       L1742
                    clrb
L1742               lda       ,X+
                    bra       L1738

number              lda       ,X+
L1434               cmpa      #$30                = 0?
                    bcs       L1736
                    cmpa      #$39                = 9?
                    bhi       L1736
                    suba      #$30                ASCII -> dec.
L1738               andcc     #$FE
                    rts

L1736               orcc      #1
                    rts

L1740               pshs      A
                    lda       #10
                    mul                           10*B+A
                    addb      ,S+
                    adca      #0
                    rts

L2052               equ       *-L2052Bas
L2053               equ       *-L2053Bas
                    cmpa      #$2E                format as real or exp.
                    bne       err63
                    bsr       L1720
                    bcs       err63
                    stb       <$89

L2051               equ       *-L2051Bas
L2054               equ       *-L2054Bas
L2055               equ       *-L2055Bas
L2050               lbsr      L1744               Int, Hex, String, Boolean
                    bcs       err63
                    puls      Y,X
                    inc       <$DC
L2018               ldb       subrcode
                    lbeq      FMTint
                    decb
                    beq       FMThex
                    decb
                    lbeq      FMTreal
                    decb
                    lbeq      FMTexp
                    decb
                    lbeq      FMTstr
                    lbra      FMTbool

FMThex              jsr       table4
                    pshs      y
                    cmpa      #4
                    bcs       L1758
                    ldu       1,Y                 source: string
                    ldd       3,y
                    bra       L1686

L1758               leau      1,Y
                    lda       ,Y
                    cmpa      #2
                    bne       L1764
                    ldb       #5                  source: real number
                    bra       L1686

L1764               cmpa      #1
                    bne       L1766
                    ldb       #2                  source: integer
                    cmpb      fieldwid
                    bcs       L1768
L1766               ldb       #1                  byte, boolean
                    leau      1,U
L1768               tfr       B,A
                    asla
                    cmpa      fieldwid
                    bls       L1686
                    anda      #$0F
                    cmpa      #9
                    bls       L1784
                    adda      #7
L1784               lbsr      L1646
                    dec       fieldwid
                    bra       L1782

L1686               tst       justify
                    pshs      b
                    beq       L1776               left justify
                    bmi       L1774               center digits
                    aslb                          right          justify
                    pshs      B
                    ldb       fieldwid
                    subb      ,S+
                    bcs       L1776
                    bra       L1778

L1774               aslb
                    pshs      B
                    ldb       fieldwid
                    subb      ,S+
                    bcs       L1776
                    asrb
L1778               lda       fieldwid
                    subr      b,a
                    sta       fieldwid
                    lbsr      spacing
L1776               ldb       fieldwid
                    lbsr      L1650
                    tfr       d,y
                    puls      B
L1772               lda       ,U
                    lsra
                    lsra
                    lsra
                    lsra
                    cmpa      #9
                    bls       L1773
                    adda      #7
L1773               adda      #$30
                    sta       ,y+
                    decw
                    beq       L1782
L1770               lda       ,U+
                    anda      #15
                    cmpa      #9
                    bls       L1771
                    adda      #7
L1771               adda      #$30
                    sta       ,y+
                    decw
                    beq       L1782
                    decb
                    bne       L1772
                    lda       #$20                Space
                    pshs      a
                    tfm       s,y+
                    leas      1,s
L1782               sty       Spointer
                    puls      y
                    clra
                    sta       fieldwid
                    rts

L1788               coma
                    rts

FMTint              jsr       table4
                    cmpa      #2
                    bcs       L1786
                    bne       L1788               wrong var. type
                    lbsr      FIX
L1786               pshs      U,X
                    leas      -5,S
                    leax      ,S
                    lbsr      ItoA
                    ldb       fieldwid
                    decb
                    subb      digits
                    bpl       L1792
                    leas      5,S
                    puls      U,X
                    lbra      ovflow

L1792               tst       justify
                    beq       L1796               left justify
                    bmi       L1798               leading zeroes
                    lbsr      spacing             right justify
                    lbsr      L1800
                    bra       L1802

L1796               lbsr      L1800
                    pshs      B
                    lda       digits
                    lbsr      L1624
                    puls      B
                    lbsr      spacing
                    bra       L1804

L1798               lbsr      L1800
                    lbsr      L1620
L1802               lda       digits
                    lbsr      L1624
L1804               leas      5,S
                    clra
                    puls      PC,U,X

FMTbool             jsr       table4
                    cmpa      #3
                    bne       L1788               wrong type
                    pshs      U,X
                    leax      L1668,PC
                    ldb       #4
                    lda       2,Y
                    bne       L1806
                    leax      L1672,PC
                    ldb       #5
                    bra       L1806

FMTstr              jsr       table4
                    cmpa      #4
                    bne       L1788               wrong type
                    pshs      U,X
                    ldx       1,Y
                    ldd       3,y
                    tsta
                    bne       L1808
L1806               cmpb      fieldwid
                    bls       L1810
L1808               ldb       fieldwid
L1810               tfr       B,A
                    negb
                    addb      fieldwid
                    tst       justify
                    beq       L1812               left justify
                    bmi       L1814               center text
                    pshs      A                   right justify
                    lbsr      spacing
                    puls      A
                    lbsr      L1624
                    bra       L1816

L1812               pshs      B
                    bra       L1818

L1814               lsrb
                    bcc       L1820
                    incb
L1820               pshs      d
                    lbsr      spacing
                    puls      A
L1818               lbsr      L1624
                    puls      B
                    lbsr      spacing
L1816               clra
                    puls      PC,U,X

FMTreal             jsr       table4
                    cmpa      #2
                    beq       L1822
                    lbcc      L1788               wrong type
                    lbsr      FLOAT
L1822               pshs      U,X
                    leas      -$0A,S
                    leax      ,S
                    lbsr      RtoA
                    lda       decimals
                    cmpa      #9
                    bgt       L1824
                    lbsr      L1826
                    lda       fieldwid
                    suba      #2
                    bmi       L1824
                    suba      <$89
                    bmi       L1824
                    suba      <$8A
                    bpl       L1828
L1824               leas      $0A,S
                    puls      U,X
                    bra       ovflow

L1828               sta       <$88
                    leax      ,S
                    ldb       justify
                    beq       L1830               left justify
                    bmi       L1832               fin. format
                    bsr       L1834               right justify
                    bsr       L1836
                    bra       L1838

L1830               bsr       L1836
                    bsr       L1834
                    bra       L1838

L1832               bsr       L1834
                    bsr       L1840
                    lbsr      L1800
L1838               leas      $0A,S
                    clra
                    puls      PC,U,X

L1836               lbsr      L1800
L1840               lda       <$8A
                    lbsr      L1624
                    lbsr      L1616
                    ldb       decimals
                    bpl       L1842
                    negb
                    cmpb      <$89
                    bls       L1844
                    ldb       <$89
L1844               pshs      B
                    lbsr      L1620
                    ldb       <$89
                    subb      ,S+
                    stb       <$89
                    lda       <$8B
                    cmpa      <$89
                    bls       L1846               NOTE: SHOULD BE BLS L1848
                    lda       <$89
L1846               bra       L1848

L1834               ldb       <$88
                    lbra      spacing
L1862               lbsr      L1800
                    lda       <$8A
                    lbsr      L1624
                    lbsr      L1616
L1842               lda       <$8B
L1848               lbsr      L1624
                    ldb       <$89
                    subb      <$8B
                    ble       L1850
                    lbra      L1620

ovflow              ldb       fieldwid
                    lda       #$2A                = *
                    lbsr      L1662
                    clra
L1850               rts

FMTexp              jsr       table4
                    cmpa      #2
                    beq       L1852
                    lbcc      L1788               wrong type
                    lbsr      FLOAT
L1852               pshs      U,X
                    leas      -$0A,S
                    leax      ,S
                    lbsr      RtoA
                    lda       decimals
                    pshs      A
                    lda       #1
                    sta       decimals
                    bsr       L1826
                    puls      A
                    ldb       decimals
                    cmpb      #1
                    beq       L1854
                    inca
L1854               ldb       #1
                    stb       <$8A
                    sta       decimals
                    lda       fieldwid
                    suba      #6
                    bmi       L1856
                    suba      <$89
                    bmi       L1856
                    suba      <$8A
                    bpl       L1858
L1856               leas      $0A,S
                    puls      U,X
                    bra       ovflow

L1858               sta       <$88
                    ldb       justify
                    beq       L1860               left justify
                    bsr       L1834               right justify
                    bsr       L1862
                    lbsr      L1630
                    bra       L1864

L1860               bsr       L1862
                    lbsr      L1630
L1864               lbra      L1838

L1826               pshs      X
                    lda       decimals
                    adda      <$89
                    bne       L1866
                    lda       ,X
                    cmpa      #$35
                    bcc       L1868
L1866               deca
                    bmi       L1870
                    cmpa      #7
                    bhi       L1870
                    leax      A,X
                    ldb       1,X
                    cmpb      #$35
                    bcs       L1870
L1872               inc       ,X
                    ldb       ,X
                    cmpb      #$39
L1310               bls       L1870
L1868               ldb       #$30
                    stb       ,X
                    leax      -1,X
                    cmpx      ,S
                    bcc       L1872
                    ldx       ,S
                    leax      8,X
L1874               lda       ,-X
                    sta       1,X
                    cmpx      ,S
                    bhi       L1874
                    lda       #$31
                    sta       ,X
                    inc       decimals
L1870               puls      X
                    lda       decimals
                    bpl       L1876
                    clra
L1876               sta       <$8A
                    nega
                    adda      #9
                    bpl       L1878
                    clra
L1878               cmpa      <$89
                    bls       L1880
                    lda       <$89
L1880               sta       <$8B
                    rts

err48               ldb       #$30
                    stb       errcode
                    coma
                    rts

                    emod
MODEND              equ       *
                    end

