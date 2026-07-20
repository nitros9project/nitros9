****************************************************************************
*
* dashboard.a - draw the dashboard
*
*

                    section   bss
numbuf              rmb       24
                    endsect


white               equ       $00
blue                equ       $01
black               equ       $02
green               equ       $03
red                 equ       $04
yellow              equ       $05
magenta             equ       $06
cyan                equ       $07


inshlgt             equ       blue
insfill             equ       cyan
txtclr              equ       $03                 green

                    section   code

* byte stream to send to window to make dashboard
dash
                    fdb       WScaleSw
                    fcb       $01                 turn on scaling

***** TITLE *****
                    fdb       WFont
                    fdb       $C801
                    fcb       WPosCur,$20+17,$20+1
                    fdb       WFColor
                    fcb       red
                    fdb       WBoldSw
                    fcb       $01
                    fcc       /COYOTA!/
                    fdb       WFont
                    fdb       $C802
                    fdb       WBoldSw
                    fcb       $00

                    fdb       WFColor
                    fcb       inshlgt

***** SPEEDOMETER *****
                    fdb       WSetDPtr
                    fdb       320,96
                    fdb       WCircle
                    fdb       128
                    fdb       WCircle
                    fdb       136
                    fdb       WCircle
                    fdb       32
                    fdb       WCircle
                    fdb       38
                    fdb       WFColor
                    fcb       insfill
                    fdb       WRSetDPtr
                    fdb       0,-17
                    fdb       WFFill
                    fdb       WRSetDPtr
                    fdb       0,-50
                    fdb       WFFill

* draw 0MPH marker
                    fdb       WFColor
                    fcb       insfill
                    fdb       WSetDPtr
                    fdb       227,132
                    fdb       WRLine              draw the tick mark
                    fdb       5,-4
                    fcb       WPosCur,$20+20,$20+15
                    fdb       WFColor
                    fcb       txtclr
                    fcc       /0/

* draw 60MPH marker
                    fdb       WFColor
                    fcb       insfill
                    fdb       WSetDPtr
                    fdb       320,32
                    fdb       WRLine              draw the mid-speed tick mark
                    fdb       0,5
                    fcb       WPosCur,$20+26,$20+5
                    fdb       WFColor
                    fcb       txtclr
                    fcc       /60/
                    fdb       WFColor
                    fcb       insfill

* draw 120MPH marker
                    fdb       WSetDPtr
                    fdb       413,132
                    fdb       WRLine              draw the tick mark
                    fdb       -5,-4
                    fcb       WPosCur,$20+31,$20+15
                    fdb       WFColor
                    fcb       txtclr
                    fcc       /120/
                    fdb       WFColor
                    fcb       inshlgt

***** ENGINE TEMPERATURE (UPPER LEFT) *****
                    fdb       WSetDPtr
                    fdb       104,52
                    fdb       WCircle
                    fdb       66
                    fdb       WCircle
                    fdb       72
                    fdb       WRSetDPtr
                    fdb       0,-34
                    fdb       WFColor
                    fcb       insfill
                    fdb       WFFill

***** FUEL GAUGE (UPPER RIGHT) *****
                    fdb       WFColor
                    fcb       inshlgt
                    fdb       WSetDPtr
                    fdb       536,52
                    fdb       WCircle
                    fdb       66
                    fdb       WCircle
                    fdb       72
                    fdb       WRSetDPtr
                    fdb       0,-34
                    fdb       WFColor
                    fcb       insfill
                    fdb       WFFill

***** DATE/TIME (LOWER LEFT) *****
                    fdb       WFColor
                    fcb       inshlgt
                    fdb       WSetDPtr
                    fdb       104,192-52
                    fdb       WCircle
                    fdb       66
                    fdb       WCircle
                    fdb       72
                    fdb       WRSetDPtr
                    fdb       0,-34
                    fdb       WFColor
                    fcb       insfill
                    fdb       WFFill

***** ???? (LOWER LEFT) *****
                    fdb       WFColor
                    fcb       inshlgt
                    fdb       WSetDPtr
                    fdb       536,192-52
                    fdb       WCircle
                    fdb       66
                    fdb       WCircle
                    fdb       72
                    fdb       WRSetDPtr
                    fdb       0,-34
                    fdb       WFColor
                    fcb       insfill
                    fdb       WFFill

* finally, draw text color from now now
                    fdb       WFColor
                    fcb       txtclr              set text draw color

dashL               equ       *-dash

* entry point
dashboard
* draw the dashboard
Scrn                leax      dash,pcr
                    ldy       #dashL
                    lda       #1
                    os9       I$Write
                    rts

speedtag
                    fcb       WPosCur,$20+25,$20+11
                    fdb       WFColor
                    fcb       yellow
                    fcb       $00

speedtag2
                    fcb       WPosCur,$20+25,$20+12
                    fcc       /MPH./
                    fdb       WFColor
                    fcb       txtclr
                    fcb       $00


* Show Speed
speed
                    leax      <speedtag,pcr
                    lbsr      PUTS
                    lbsr      getspeed            get speed in D
                    leax      numbuf,u
                    lbsr      BIN_DEC
                    lbsr      PUTS
                    leax      <speedtag2,pcr
                    lbsr      PUTS
                    rts


odomtag             fcb       WPosCur,$20+23,$20+18
                    fdb       WBColor
                    fcb       red
                    fcb       $00
odomtag2
                    fdb       WBColor
                    fcb       black
                    fcb       $00
odomtag2l           equ       *-odomtag2

odometer
                    leax      <odomtag,pcr
                    lbsr      PUTS
                    lbsr      getmileage          get odometer in D,X
                    pshs      d,x
                    leax      numbuf,u
                    leay      ,s
                    lda       #$01
                    lbsr      BIN_DEC32
                    lbsr      PUTS
                    leas      4,s
                    leax      <odomtag2,pcr
                    ldy       #odomtag2l
                    lda       #$01
                    os9       I$Write
                    rts

etemptag            fcb       WPosCur,$20+7,$20+8
                    fcb       $00

engtemp
                    leax      <etemptag,pcr
                    lbsr      PUTS
                    lbsr      getengtemp          get engine temperature in D
                    leax      numbuf,u
                    lbsr      BIN_DEC
                    lbsr      PUTS
                    rts

fueltag             fcb       WPosCur,$20+44,$20+8
                    fcb       $00

fuelgauge
                    leax      <fueltag,pcr
                    lbsr      PUTS
                    lbsr      getfuel             get fuel in D
                    leax      numbuf,u
                    lbsr      BIN_DEC
                    lbsr      PUTS
                    rts

timetag             fcb       WPosCur,$20+18,$20+23
                    fcb       $00

systime
                    leax      <timetag,pcr
                    lbsr      PUTS
                    leax      numbuf,u
                    lbsr      STIMESTR            get fuel in D
                    lbsr      PUTS
                    rts

                    endsect
