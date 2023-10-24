********************************************************************
* JoyDrv - Joystick Driver for CoCo 3 Hi-Res Mouse
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   6      1998/10/09  Robert Gault
* Added annotations to the L2 Upgrade distribution version
*
*   7      2003/08/28  Robert Gault
* Contains routine for H6309 from VTIO

                    nam       JoyDrv
                    ttl       Joystick Driver for CoCo 3 Hi-Res Mouse

* Disassembled 98/09/09 09:07:45 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    use       cocovtio.d
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       7

                    mod       eom,name,tylg,atrv,start,size
size                equ       .

name                fcs       /JoyDrv/
                    fcb       edition

start               lbra      Init                setup for special button state & clear buttons
                    lbra      Term                clear button but don't change special flag
                    lbra      SSMsBtn             read and process button values
                    lbra      SSMsXY              read joystick values; with processing
                    lbra      SSJoyBtn            clear keyboard input and return raw button info

SSJoyXY             pshs      y,x,b,a             read joystick values
                    pshs      x,b,a
                    ldx       #PIA0Base           point to PIA#1
                    lda       <$23,x              read sound enable state?
                    ldb       <$20,x              read 6-bit DAC
                    pshs      b,a                 save current states
                    anda      #%11110111          clear sound enable
                    sta       <$23,x              set switch
                    lda       $01,x               read MUX SEL#1
                    ldb       $03,x               read MUX SEL#2
                    pshs      b,a                 save current state
                    orb       #$08                set SEL#2
                    lda       $08,s               read ?what?
                    anda      #$02                keep only left or right joystick
                    bne       L0047               if left then don't
                    andb      #%11110111          clear SEL#2
L0047               stb       $03,x               enable SEL#2 value
                    leay      <L0097,pcr          point to high res routine
                    ldb       $0D,s               flag for high/low res
                    bne       L0054
                    leay      >L010F,pcr          point to low res routine
L0054               lda       ,s
                    ora       #$08                set MUX SEL#1
                    jsr       ,y                  read pot
                    tst       $0D,s               here the same byte seems to be used for x/y flag??
                    beq       L0060
                    bsr       L00DB               convert from width to height value
L0060               std       $06,s               return joystick value
                    lda       ,s                  now read the other direction
                    anda      #$F7                flip the MUX SEL#1 bit
                    jsr       ,y                  read the second pot
                    std       $04,s               save the other value
                    puls      b,a
                    sta       $01,x
                    stb       $03,x
                    puls      b,a
                    stb       <$20,x              reset the DAC and sound selector
                    sta       <$23,x
                    puls      y,x
                    lda       ,s                  flag for double button?
                    cmpa      #$01
                    bne       L0094
                    ldb       #$80                minimum flag
                    lda       $05,s
                    bne       L008B
                    cmpx      #32                 minimum joystick value
                    bcc       L0092
L008B               cmpx      #320                maximum joystick value
                    bcc       L0092               if less than don't change flag
                    ldb       #$C0                maximum flag
L0092               stb       ,u                  save max/min flag value
L0094               leas      $06,s
                    rts
L0097               pshs      cc                  high res routine
                    sta       $01,x               select x/y pot
                    lda       #$FF                full DAC value
                    sta       <$20,x              store in DAC to charge capacitor
                    ifne      H6309
                    lda       #$80
                    else
                    lda       #$5A                timing loop; wait for voltage to settle
                    endc
L00A2               deca
                    bne       L00A2               wait
                    ifne      H6309
                    ldd       #$2F0
                    lde       #2
                    else
                    ldd       #$329
                    pshs      a
                    lda       #$02
                    endc
                    orcc      #IntMasks           kill interrupts
                    ifne      H6309
                    ste       <$20,x
                    else
                    sta       <$20,x              clear DAC; mask RS-232; start cap. discharge
                    endc
L00B1               equ       *
                    ifne      H6309
                    lde       ,x
                    else
                    lda       ,x                  test comparator
                    endc
                    bmi       L00C0
                    ifne      H6309
                    decd
                    else
                    decb                          counter
                    endc
                    bne       L00B1               loop until state change
                    ifne      H6309
                    ldd       #MaxRows-1          Too big, force to highest possible coord
                    puls      cc,pc
                    else
                    dec       ,s                  3 -> 0
                    bpl       L00B1               loop again
                    puls      a
                    bra       L00D6               branch to maximum value
L00C0               puls      a
                    endc
                    ifne      H6309
L00C0               equ       *
                    endc
                    decb
                    ifne      H6309
                    ldw       #MaxRows            Max coord
                    subr      d,w                 Subtract the timing ramp value we got
                    bhs       L0A11               If didn't wrap, we're fine
                    clrd                          If went negative, force to 0 coord
                    puls      cc,pc               Turn interrupts back on & return
L0A11               tfr       w,d                 Move to proper exit register for now
                    cmpd      #MaxRows-1          Past maximum X coordinate?
                    blo       L0A1A               No, leave it alone
                    ldd       #MaxRows-1          Don't let it get past end of screen
L0A1A               puls      pc,cc
                    else
                    pshs      b,a
                    ldd       #640
                    subd      ,s++                convert from 640 -> 0 to 0 -> 640
                    bcc       L00D0
                    clra                          minimum value is $00
                    clrb
                    puls      pc,cc
L00D0               cmpd      #639
                    bcs       L00D9
L00D6               ldd       #639                maximum value
L00D9               puls      pc,cc
                    endc
* This routine converts a pot value from width (640) to height (192) to match
* possible screen values; ie. value divided by 3.33
L00DB               pshs      a
                    lda       #$09
                    pshs      a
                    lda       #$03
                    mul
                    pshs      b,a
                    lda       $03,s
                    ldb       #$03
                    mul
                    exg       b,a
                    addd      ,s++
L00EF               clr       $01,s
                    cmpa      #$0A
                    bcs       L00F9
                    inc       $01,s
                    suba      #$0A
L00F9               lsr       $01,s
                    rolb
                    rola
                    dec       ,s
                    bne       L00EF
                    cmpb      #$BF
                    beq       L010B
                    cmpa      #$0A
                    bcs       L010B
                    addb      #$01
L010B               clra
                    leas      $02,s
                    rts
* Low res binary tree search for joystick value
L010F               sta       $01,x               set MUX SEL#1
                    lda       #$7F                DAC value
                    ldb       #$40
                    bra       L0122
L0117               lsrb                          reset DAC offset value
                    cmpb      #$01
                    bhi       L0122
                    lsra
                    lsra
                    tfr       a,b
                    clra
                    rts                           return with voltage
L0122               pshs      b
                    sta       <$20,x              set DAC
                    tst       ,x                  test comparator
                    bpl       L012F
                    adda      ,s+                 adjust binary tree search
                    bra       L0117
L012F               suba      ,s+                 adjust binary tree search
                    bra       L0117

SSMsXY              leay      ,y                  get flag??
                    lbne      SSJoyXY             go read joystick pots
                    lbsr      SSJoyXY             go read joystick pots and then convert values
                    tfr       x,d                 multiply regX by 10 and regY by 3
                    lda       #$0A
                    mul
                    tfr       d,x
                    cmpx      #630
                    bcs       L014B
                    ldx       #634                maximum limit on regX
*	may be an error and could be 639
L014B               tfr       y,d
                    lda       #$03
                    mul
                    tfr       d,y
                    rts

Init                ldb       #$80
                    stb       ,u

Term                clr       $01,u
                    rts

SSJoyBtn            ldx       #PIA0Base           PIA#1 base address
                    clrb
                    comb
                    stb       $02,x               clear PIA#1 key strobe lines
                    ldb       ,x                  read data lines
                    comb                          only buttons and comparator valid
                    andb      #$0F                only buttons; 0=off 1=on
                    rts

SSMsBtn             bsr       SSJoyBtn
                    tfr       b,a
                    anda      #%11111010          regA=left buttons; should be $0A not $FA
                    pshs      a                   save left button values
                    andb      #$05                regB=right buttons
                    orb       $01,u               ORB with previous state??
                    leax      <L0187,pcr          point to sequential switch table possibilities
                    lda       b,x
                    anda      #%00001010          keep only left values
                    sta       $01,u               save for change test
                    ldb       b,x                 repeat
                    andb      #%10000101          keep flag and right values
                    bpl       L0184
                    ldb       ,u                  previous min/max state
L0184               orb       ,s+                 ORB with current left values and pop stack
                    rts
L0187               fcb       $00,$03,$00,$03,$08,$06,$02,$06,$80,$02,$00,$02,$08,$06,$0a,$06

                    emod
eom                 equ       *
                    end

