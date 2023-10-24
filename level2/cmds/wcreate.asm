********************************************************************
* WCreate - Create a window
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   3      ????/??/??
* Original Tandy/Microware version.

                    nam       WCreate
                    ttl       Create a window

* Disassembled 98/09/11 18:26:55 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

DOHELP              set       0

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       3

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       2
u0002               rmb       1
u0003               rmb       7
newtype             rmb       1
winpath             rmb       1
u000C               rmb       1
zflag               rmb       1
u000E               rmb       480
size                equ       .

name                fcs       /WCreate/
                    fcb       edition

                    ifne      DOHELP
HelpMsg             fcb       C$CR
                    fcb       C$LF
                    fcc       "WCreate <windpath> [-s=stype] xpos ypos width height fcol bcol [bord]"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "Use: Create a new window"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "Options: -s=stype  place the window on a new screen, must also"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "                   include the border color."
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "         -z        receive commands from standard input"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "         -?        receive help message"
                    fcb       C$CR
                    fcb       C$LF
                    endc

CurOn               fdb       $1B21

start               clr       <zflag
                    clra
                    coma
                    sta       <u000C
                    lbsr      skipspc             skip spaces
                    lda       ,x                  get next character
                    cmpa      #PDELIM             path delimiter?
                    bne       L015D               branch if not
                    bsr       L01B2
                    bra       Exit
L015D               cmpa      #'-
                    lbne      ShowHelp
                    leax      1,x
                    lda       ,x+
                    ifne      DOHELP
                    cmpa      #'?
                    lbeq      ShowHelp
                    endc
                    cmpa      #'z
                    beq       L0177
                    cmpa      #'Z
                    lbne      ShowHelp
L0177               lda       #$01
                    sta       <zflag
L017B               clra
                    leax      u000E,u
                    ldy       #80
                    os9       I$ReadLn
                    bcs       L019C
                    lda       ,x
                    cmpa      #$2A
                    beq       L0177
                    lbsr      skipspc             skip spaces
                    lda       ,x
                    cmpa      #C$CR
                    beq       L01A0
                    bsr       L01B5
                    bcs       Exit
                    bra       L017B
L019C               cmpb      #E$EOF
                    bne       Exit
L01A0               lda       #$01
                    lbsr      cursoron            turn on text cursor
                    lda       <u000C
                    bmi       ExitOk
                    os9       I$Close
                    bcs       Exit
ExitOk              clrb
Exit                os9       F$Exit

L01B2               lbsr      skipspc             skip spaces
L01B5               clr       <newtype
                    clr       <u0002
                    lda       ,x                  get character at X
                    cmpa      #PDELIM             pathlist delimiter?
                    lbne      Exiting             branch if not
                    lda       #UPDAT.
                    pshs      u,x,a
                    leax      1,x                 point past pathlist delimiter
                    os9       I$Attach            attach device
                    puls      u,x,a
                    lbcs      L0253               branch if error
                    os9       I$Open              open device
                    bcs       L0253               branch if error
                    sta       <winpath            save path
                    lbsr      skipspc             skip spaces
                    lda       ,x+
                    cmpa      #'-
                    bne       Get6
                    lda       ,x+
                    cmpa      #'s
                    beq       L01EA
                    cmpa      #'S
                    bne       Exiting
L01EA               lda       ,x+
                    cmpa      #'=
                    bne       Exiting
                    leay      u0002,u
                    lbsr      asc2num
                    bcs       Exiting
                    inc       <newtype
                    ldb       #$07                get 7 numbers (last one is border)
                    bra       L0203
Get6                leay      u0003,u
                    ldb       #$06                get 6 numbers
                    leax      -1,x
L0203               bsr       asc2num
                    bcs       Exiting
                    decb
                    bne       L0203
                    leax      ,u
                    lda       #$1B
                    sta       ,x
                    lda       #$20
                    sta       1,x
                    tst       <newtype
                    beq       L021E
                    ldy       #$000A
                    bra       L0222
L021E               ldy       #$0009
L0222               lda       <winpath
                    os9       I$Write
                    bcs       L0253
                    tst       <zflag
                    beq       L024E
                    tst       <newtype
                    beq       L024E
                    tst       <u000C
                    bpl       L0239
                    lda       #$01
                    bsr       cursoron            turn on text cursor
L0239               lda       <winpath
                    bsr       cursoron            turn on text cursor
                    bcs       L0253
                    tst       <u000C
                    bmi       L0248
                    lda       <u000C
                    os9       I$Close
L0248               lda       <winpath
                    sta       <u000C
                    bra       L0253
L024E               lda       <winpath
                    os9       I$Close
L0253               rts

cursoron            leax      >CurOn,pcr
                    ldy       #$0002
                    os9       I$Write
                    rts

skipspc             lda       ,x+
                    cmpa      #C$SPAC
                    beq       skipspc
                    leax      -1,x
                    rts

Exiting             leas      $02,s
ShowHelp            equ       *
                    ifne      DOHELP
                    lda       #$01
                    leax      >HelpMsg,pcr
                    ldy       #$0133
                    os9       I$Write
                    endc
                    lbra      ExitOk

* Entry: X = address of ASCII string to convert
*        Y = location to store byte
* Exit:  B = converted value
asc2num             pshs      b
                    clrb
                    stb       ,y
L0280               lda       ,x+
                    cmpa      #'0
                    blt       L029B
                    cmpa      #'9
                    bhi       L029B
                    suba      #'0
                    pshs      a
                    lda       #10
                    ldb       ,y
                    mul
                    addb      ,s+
                    stb       ,y
                    bvs       L02A7
                    bra       L0280
L029B               cmpa      #C$CR
                    beq       L02AA
                    cmpa      #C$SPAC
                    bsr       skipspc             skip spaces
                    bra       L02AA
                    bne       L02A7
L02A7               comb
                    bra       L02AD
L02AA               clrb
                    leay      $01,y
L02AD               puls      pc,b

                    emod
eom                 equ       *
                    end

