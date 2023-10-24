********************************************************************
* KeyDrv - Keyboard Driver for CoCo 3
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   4      1998/10/10  Robert Gault
* L2 Upgrade distribution version with annotations by Robert Gault.

                    nam       KeyDrv
                    ttl       Keyboard Driver for CoCo 3

* Disassembled 98/09/09 09:02:10 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    use       cocovtio.d
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             equ       4

                    mod       eom,name,tylg,atrv,entry,size
size                equ       .

name                fcs       /KeyDrv/
                    fcb       edition

entry               equ       *

* Init - Initialize keyboard
                    lbra      Init

* Term - Terminate keyboard
                    lbra      Term

* Function - Test for function keys
                    lbra      FuncKeys

* Read - read keys if pressed
* Exit: A = key pressed
ReadKys             ldu       <D.CCMem            Get VTIO global memory into U
                    ldx       #PIA0Base           base address of PIA #0
                    ldb       #$FF
                    stb       $02,x               clear all row strobes
                    ldb       ,x                  read Joystick buttons
                    comb                          invert bits so 1=pressed
                    andb      #%00001111          keep only buttons
                    bne       L0059               branch if button pushed; error routine
                    clr       $02,x               enable all strobe lines
                    lda       ,x                  read PIA #0
                    coma
* Check to see if ANY key is down
                    anda      #%01111111          mask only the joystick comparator
                    beq       NoKey               branch if no keys pressed
* Here, a key is down on the keyboard
                    pshs      dp                  save our DP
                    tfr       u,d                 move statics ptr to D
                    tfr       a,dp                set DP to the address in regU
                    bsr       EvalMatrix          evaluate the found key matrix
                    puls      dp                  return to system DP
                    bpl       L005B               valid key
NoKey               clra                          regA    would have been the found key
                    ldb       <G.CapLok,u         CapsLock/SysRq key down flag
                    bne       L0056               branch if down
                    clr       <G.KTblLC,u         Key table entry# last checked (1-3)
                    ifne      H6309
                    comd
                    else
                    coma
                    comb
                    endc
                    sta       <G.LKeyCd,u         last keyboard code
                    sta       <G.2Key1,u          2nd key table storage; $FF=none
                    std       <G.2Key2,u          format (Row/Column)
L0056               clr       <G.CapLok,u         see above
L0059               ldb       #$FF
L005B               rts


* Evaluates the keyboard matrix for a key
EvalMatrix
                    ldx       #PIA0Base           base value of PIA #0
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       <G.ShftDn           shift/CTRL flag; 0=NO $FF=YES
                    std       <G.KeyFlg           PIA bits/ALT flag
*	%00000111-Column # (Output, 0-7)
*	%00111000-Row # (Input, 0-6)
                    ifne      H6309
                    comd                          set D to $FFFF
                    else
                    coma
                    comb                          set primary key table
                    endc
                    std       <G.Key1             key 1&2 flags $FF=none
                    sta       <G.Key3             key 3     "
                    deca                          ie. lda #%11111110
                    sta       $02,x               strobe one column
L006E               lda       ,x                  read PIA #0 row states
                    coma                          invert bits so 1=key pressed
                    anda      #$7F                keep only keys, bit 0=off 1=on
                    beq       L0082               no keys pressed, try next column
                    ldb       #$FF                preset counter to -1
L0077               incb
                    lsra                          bit test regA
                    bcc       L007E               no key so branch
                    lbsr      L010E               convert column/row to matrix value and store it
L007E               cmpb      #$06                max counter
                    blo       L0077               loop if more bits to test
L0082               inc       <G.KeyFlg           counter; used here for column
                    orcc      #Carry              bit marker; disable strobe
                    rol       $02,x               shift to next column
                    bcs       L006E               not finished with columns so loop
                    lbsr      L0166               simultaneous check; recover key matrix value
                    bmi       L00F5               invalid so go
                    cmpa      <G.LKeyCd           last keyboard code
                    bne       L0095
                    inc       <G.KySame           same key flag ?counter?
L0095               sta       <G.LKeyCd           setup for last key pressed
                    beq       L00B5               if @ key, use lookup table
                    suba      #$1A                the key value (matrix) of Z
                    bhi       L00B5               not a letter so go
                    adda      #$1A                restore regA
                    ldb       <G.CntlDn           CTRL flag
                    bne       L00E0               CTRL is down so go
                    adda      #$40                convert to ASCII value; all caps
                    ldb       <G.ShftDn           shift key flag
                    ldy       <G.CurDev           get current device static memory pointer
                    eorb      <V.ULCase,y         caps lock and keyboard mouse flags
                    andb      #CapsLck            test caps flag
                    bne       L00E0               not shifted so go
                    adda      #$20                convert to ASCII lower case
                    bra       L00E0
* not a letter key, use the special keycode lookup table at L01DC.
* Entry: regA = table index (matrix scancode-26)
L00B5               ldb       #$03                three entries per key (normal,shift,ctrl)
                    mul                           convert index to table offset
                    lda       <G.ShftDn           shift key flag
                    beq       L00BF               not shifted so go
                    incb                          adjust offset for SHIFTed entry
                    bra       L00C5
L00BF               lda       <G.CntlDn           CTRL flag
                    beq       L00C5               adjust offset for CONTROL entry
                    addb      #$02
L00C5               ldx       <G.CurDev           point X to device's static memory
                    lda       <V.KySnsFlg,x       key sense flag
                    beq       L00D0               not set so go
                    cmpb      #$11                spacebar
                    ble       L00F3               must be an arrow so go
L00D0               cmpb      #$4B                ALT key? (was cmpb #$4C)
                    blt       L00D8               not ALT, CTRL, F1, F2, or SHIFT so go
                    inc       <G.AltDwn           flag special keys (ALT,CTRL)
                    subb      #$06                and adjust offset to skip them
L00D8               leax      >L01DC,pcr          decode table
                    lda       b,x
                    bmi       L00F6               if regA = $81 - $84, special key
* several entries to this routine from any key press; regA is already ASCII
L00E0               ldb       <G.AltDwn           was ALT flagged?
                    beq       L00F0               no so go
                    cmpa      #$3F                ?
                    bls       L00EE               # or code
                    cmpa      #$5B                [
                    bhs       L00EE               capital letter so go
                    ora       #$20                convert to lower case
L00EE               ora       #$80                set for ALT characters
L00F0               andcc     #^Negative          not negative
                    rts
L00F3               orcc      #Negative           set negative
L00F5               rts
* Flag that a special key was hit
L00F6               inc       <G.CapLok           caps lock/SysRq
                    inc       <G.Clear            one shot caps lock/SysRq
                    bra       L00F0
* Calculate arrow keys for key sense byte
L00FC               pshs      b,a                 convert column into power of 2
                    clrb
                    orcc      #Carry
                    inca
L0102               rolb
                    deca
                    bne       L0102
*         bra   L0108      WHY IS THIS HERE??
L0108               orb       <G.KySns            previous value of column
                    stb       <G.KySns
                    puls      pc,b,a
* Check special keys (Shift, Cntrl, Alt)
L010E               pshs      b,a
                    cmpb      #$03                is it row 3?
                    bne       L011C
                    lda       <G.KeyFlg           get column #
                    cmpa      #$03                is it column 3?; ie up arrow
                    blt       L011C               if lt must be a letter
                    bsr       L00FC               its a non letter so bsr
L011C               lslb                          B*8  8 keys per row
                    lslb
                    lslb
                    addb      <G.KeyFlg           add in the column #
                    cmpb      #$33                ALT
                    bne       L012B
                    inc       <G.AltDwn           ALT down flag
                    ldb       #$04
                    bra       L0108
L012B               cmpb      #$34                CTRL
                    bne       L0135
                    inc       <G.CntlDn           CTRL down flag
                    ldb       #$02
                    bra       L0108
L0135               cmpb      #$37                SHIFT key
                    bne       L013F
                    com       <G.ShftDn           SHIFT down flag
                    ldb       #$01
                    bra       L0108
* check how many key (1-3) are currently being pressed
L013F               pshs      x
                    leax      <$2D,u              1st key table
                    bsr       L014A
                    puls      x
                    puls      pc,b,a
L014A               pshs      a
                    lda       ,x
                    bpl       L0156
                    stb       ,x
                    ldb       #$01
                    puls      pc,a
L0156               lda       $01,x
                    bpl       L0160
                    stb       $01,x
                    ldb       #$02
                    puls      pc,a
L0160               stb       $02,x
                    ldb       #$03
                    puls      pc,a
* simultaneous key test
L0166               pshs      y,x,b
                    ldb       <G.KTblLC           key table entry #
                    beq       L019D
                    leax      <$2A,u              point to 2nd key table
                    pshs      b
L0171               leay      <$2D,u              1st key table
                    ldb       #$03
                    lda       ,x                  get key #1
                    bmi       L018F               go if invalid? (no key)
L017A               cmpa      ,y                  is it a match?
                    bne       L0184               go if not a matched key
                    clr       ,y
                    com       ,y                  set value to $FF
                    bra       L018F
L0184               leay      $01,y
                    decb
                    bne       L017A
                    lda       #$FF
                    sta       ,x
                    dec       <G.KTblLC           key table entry#
L018F               leax      $01,x
                    dec       ,s                  column counter
                    bne       L0171
                    leas      $01,s
                    ldb       <G.KTblLC           key table entry (can test for 3 simul keys)
                    beq       L019D
                    bsr       L01C4
L019D               leax      <$2D,u              1st key table
                    lda       #$03
L01A2               ldb       ,x+
                    bpl       L01B5
                    deca
                    bne       L01A2
                    ldb       <G.KTblLC           key table entry (can test for 3 simul keys)
                    beq       L01C0
                    decb
                    leax      <$2A,u              2nd key table
                    lda       b,x
                    bra       L01BE
L01B5               tfr       b,a
                    leax      <$2A,u              2nd key table
                    bsr       L014A
                    stb       <G.KTblLC
L01BE               puls      pc,y,x,b
L01C0               orcc      #Negative           flag negative
                    puls      pc,y,x,b
* Sort 3 byte packet @ G.2Key1 according to sign of each byte
* so that positive #'s are at beginning & negative #'s at end
L01C4               leax      <$2A,u              2nd key table
                    bsr       L01CF               sort bytes 1 & 2
                    leax      $01,x
                    bsr       L01CF               sort bytes 2 & 3
                    leax      -$01,x              sort 1 & 2 again (fall thru for third pass)
L01CF               ldb       ,x                  get current byte
                    bpl       L01DB               positive - no swap
                    lda       $01,x               get next byte
                    bmi       L01DB               negative - no swap
                    std       ,x                  swap the bytes
L01DB               rts

* Special Key Codes Table : 3 entries per key - Normal, Shift, Control
* They are in COCO keyboard scan matrix order; the alphabetic and meta
* control keys are handled elsewhere.  See INSIDE OS9 LEVEL II p.4-1-7
L01DC               fcb       $40,$60,$00         '@,'`,null
                    fcb       $0c,$1c,$13         UP ARROW:    FF, FS,DC3
                    fcb       $0a,$1a,$12         DOWN ARROW:  LF,SUB,DC2
                    fcb       $08,$18,$10         LEFT ARROW:  BS,CAN,DLE
                    fcb       $09,$19,$11         RIGHT ARROW: HT, EM,DC1
                    fcb       $20,$20,$20         SPACEBAR
                    fcb       $30,$30,$81         '0,'0,$81 (caps lock toggle)
                    fcb       $31,$21,$7c         '1,'!,'|
                    fcb       $32,$22,$00         '2,'",null
                    fcb       $33,$23,$7e         '3,'#,'~
                    fcb       $34,$24,$1d         '4,'$,GS (was null)
                    fcb       $35,$25,$1e         '5,'%,RS (was null)
                    fcb       $36,$26,$1f         '6,'&,US (was null)
                    fcb       $37,$27,$5e         '7,'','^
                    fcb       $38,$28,$5b         '8,'(,'[
                    fcb       $39,$29,$5d         '9,'),']
                    fcb       $3a,$2a,$00         ':,'*,null
                    fcb       $3b,$2b,$7f         ';,'+,DEL
                    fcb       $2c,$3c,$7b         ',,'<,'{
                    fcb       $2d,$3d,$5f         '-,'=,'_
                    fcb       $2e,$3e,$7d         '.,'>,'}
                    fcb       $2f,$3f,$5c         '/,'?,'\
                    fcb       $0d,$0d,$0d         ENTER key
                    fcb       $82,$83,$84         CLEAR key (NextWin, PrevWin, KbdMouse toggle)
                    fcb       $05,$03,$1b         BREAK key (ENQ,ETX,ESC)
                    fcb       $31,$33,$35         F1 key (converts to $B1,$B3,$B5)
                    fcb       $32,$34,$36         F2 key (converts to $B2,$B4,$B6)

*L01DC    fdb   $4060,$000c,$1c13,$0a1a,$1208,$1810,$0919,$1120
*         fdb   $2020,$3030,$8131,$217c,$3222,$0033,$237e,$3424
*         fdb   $0035,$2500,$3626,$0037,$275e,$3828,$5b39,$295d
*         fdb   $3a2a,$003b,$2b7f,$2c3c,$7b2d,$3d5f,$2e3e,$7d2f
*         fdb   $3f5c,$0d0d,$0d82,$8384,$0503,$1b31,$3335,$3234
*         fcb   $36

* Init and Term do nothing for this CoCo keyboard subroutine module
Init
Term                clrb
                    rts

* This entry point tests for the F1/F2 function keys on a CoCo 3
* keyboard.
* Exit: A = Function keys pressed (Bit 0 = F1, Bit 2 = F2)
FuncKeys            ldu       <D.CCMem            get VTIO global mem pointer into U
                    ldx       #PIA0Base           get address of PIA #0
                    clra                          clear A
                    ldb       #%11011111          strobe column #6 of PIA #0
                    stb       $02,x
                    ifne      H6309
                    tim       #%01000000,0,x      F1 down?
                    else
                    ldb       ,x                  read PIA #0
                    bitb      #%01000000          test for F1 function key
                    endc
                    bne       CheckF2             branch if set (key not down)
                    inca                          flag F1 as down
CheckF2             ldb       #%10111111          strobe column #7 PIA #0
                    stb       $02,x
                    ifne      H6309
                    tim       #%01000000,0,x      F2 down?
                    else
                    ldb       ,x                  read PIA #0
                    bitb      #%01000000          test for F2 function key
                    endc
                    bne       L024C
                    ora       #$04                flag F2 as down
L024C               rts

                    emod
eom                 equ       *
                    end
