********************************************************************
* Rescue - Rescue On Fractalus Program
*
* $Id$
*
* NOTE:  This code assembles to the EXACT same object code found on
*        the original Rescue on Fractalus disk.
*
*        Header for : RESCUE
*        Module size: $5B18  #23320
*        Module CRC : $C4EB06 (Good)
*        Hdr parity : $6B
*        Exec. off  : $0013  #19
*        Data size  : $6000  #24576
*        Edition    : $30  #48
*        Ty/La At/Rv: $11 $81
*        Prog mod, 6809 Obj, re-ent, R/O
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          1995/07/23  Boisy G. Pitre
* Disassembled at 10:11:57.

                    nam       Rescue
                    ttl       Rescue On Fractalus Program

                    ifp1
                    use       defsfile
                    endc

* standard paths
stdin               equ       0
stdout              equ       1
stderr              equ       2

*** data layout ***
ccpals              set       $537                palettes
palstr              set       $547                temporary spot to write palette cmds.
button              set       $59e                joystick button value (latest)
joyx                set       $59f                joystick X value (latest)
joyy                set       $5a0                joystick Y value (latest)
joyxold             set       $5a1                old joystick X value
joyyold             set       $5a2                old joystick Y value

oldecho             set       $cbb                original echo state of path options
oldpause            set       $cbc                original pause state of path options
scrnnum             set       $cbd                screen number of screen via SS.AScrn
scrnaddr            set       $cbf                screen address of screen via SS.AScrn
mtype               set       $cc9                monitor type (1 == RGB, 0 = CMP)
* path options
tmppath             set       $ccb
pathopts            set       $ccc
echoflg             set       $cd0
pauseflg            set       $cd3
*

rofvbuf             set       $0f43
scorebuf            set       $121c
panelbuf            set       $154f
bodybuf             set       $1761
headsbuf            set       $1af9
larmsbuf            set       $21eb
lipsbuf             set       $2b00

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       1
u0001               rmb       1
u0002               rmb       1
u0003               rmb       1
u0004               rmb       1
u0005               rmb       1
u0006               rmb       1
u0007               rmb       1
u0008               rmb       1
u0009               rmb       1
u000A               rmb       1
u000B               rmb       1
u000C               rmb       1
u000D               rmb       1
u000E               rmb       1
u000F               rmb       1
u0010               rmb       1
u0011               rmb       1
u0012               rmb       1
u0013               rmb       1
u0014               rmb       1
u0015               rmb       2
u0017               rmb       1
u0018               rmb       1
u0019               rmb       2
u001B               rmb       1
u001C               rmb       1
u001D               rmb       1
u001E               rmb       1
u001F               rmb       1
u0020               rmb       1
u0021               rmb       1
u0022               rmb       1
u0023               rmb       1
u0024               rmb       1
u0025               rmb       1
u0026               rmb       1
u0027               rmb       1
u0028               rmb       1
u0029               rmb       3
u002C               rmb       2
u002E               rmb       2
u0030               rmb       1
u0031               rmb       1
u0032               rmb       1
u0033               rmb       1
u0034               rmb       1
u0035               rmb       1
u0036               rmb       1
u0037               rmb       1
u0038               rmb       1
u0039               rmb       1
u003A               rmb       1
u003B               rmb       1
u003C               rmb       1
u003D               rmb       1
u003E               rmb       1
u003F               rmb       1
u0040               rmb       1
u0041               rmb       1
u0042               rmb       1
u0043               rmb       1
u0044               rmb       1
u0045               rmb       1
u0046               rmb       1
u0047               rmb       1
u0048               rmb       1
u0049               rmb       1
u004A               rmb       1
u004B               rmb       1
u004C               rmb       1
u004D               rmb       1
u004E               rmb       1
u004F               rmb       1
u0050               rmb       1
u0051               rmb       1
u0052               rmb       1
u0053               rmb       1
u0054               rmb       1
u0055               rmb       1
u0056               rmb       1
u0057               rmb       1
u0058               rmb       1
u0059               rmb       1
u005A               rmb       1
u005B               rmb       1
u005C               rmb       1
u005D               rmb       1
u005E               rmb       1
u005F               rmb       1
u0060               rmb       1
u0061               rmb       1
u0062               rmb       1
u0063               rmb       1
u0064               rmb       1
u0065               rmb       1
u0066               rmb       1
u0067               rmb       1
u0068               rmb       1
u0069               rmb       1
u006A               rmb       1
u006B               rmb       1
u006C               rmb       1
u006D               rmb       2
u006F               rmb       1
u0070               rmb       1
u0071               rmb       1
u0072               rmb       1
u0073               rmb       1
u0074               rmb       3
u0077               rmb       1
u0078               rmb       1
u0079               rmb       1
u007A               rmb       1
u007B               rmb       1
u007C               rmb       1
u007D               rmb       1
u007E               rmb       1
u007F               rmb       1
u0080               rmb       1
u0081               rmb       1
u0082               rmb       1
u0083               rmb       1
u0084               rmb       1
u0085               rmb       1
u0086               rmb       1
u0087               rmb       2
u0089               rmb       3
u008C               rmb       10
u0096               rmb       3
u0099               rmb       2
u009B               rmb       3
u009E               rmb       1
u009F               rmb       1
u00A0               rmb       1
u00A1               rmb       1
u00A2               rmb       1
u00A3               rmb       1
u00A4               rmb       1
u00A5               rmb       1
u00A6               rmb       1
u00A7               rmb       1
u00A8               rmb       3
u00AB               rmb       3
u00AE               rmb       1
u00AF               rmb       1
u00B0               rmb       1
u00B1               rmb       1
u00B2               rmb       1
u00B3               rmb       1
u00B4               rmb       2
u00B6               rmb       2
u00B8               rmb       1
u00B9               rmb       1
u00BA               rmb       1
u00BB               rmb       1
u00BC               rmb       1
u00BD               rmb       1
u00BE               rmb       1
u00BF               rmb       1
u00C0               rmb       1
u00C1               rmb       1
u00C2               rmb       1
u00C3               rmb       1
u00C4               rmb       1
u00C5               rmb       1
u00C6               rmb       1
u00C7               rmb       1
u00C8               rmb       2
u00CA               rmb       1
u00CB               rmb       1
u00CC               rmb       1
u00CD               rmb       1
u00CE               rmb       2
u00D0               rmb       2
u00D2               rmb       1
u00D3               rmb       1
u00D4               rmb       3
u00D7               rmb       1
u00D8               rmb       1
u00D9               rmb       1
u00DA               rmb       1
u00DB               rmb       1
u00DC               rmb       2
u00DE               rmb       1
u00DF               rmb       1
u00E0               rmb       2
u00E2               rmb       2
u00E4               rmb       2
u00E6               rmb       1
u00E7               rmb       1
u00E8               rmb       1
u00E9               rmb       1
u00EA               rmb       1
u00EB               rmb       1
u00EC               rmb       1
u00ED               rmb       1
u00EE               rmb       1
u00EF               rmb       1
u00F0               rmb       1
u00F1               rmb       1
u00F2               rmb       1
u00F3               rmb       1
u00F4               rmb       1
u00F5               rmb       1
u00F6               rmb       1
u00F7               rmb       1
u00F8               rmb       1
u00F9               rmb       1
u00FA               rmb       1
u00FB               rmb       1
u00FC               rmb       1
u00FD               rmb       1
u00FE               rmb       1
u00FF               rmb       58
u0139               rmb       2
u013B               rmb       6
u0141               rmb       2
u0143               rmb       2
u0145               rmb       68
u0189               rmb       2
u018B               rmb       2
u018D               rmb       4
u0191               rmb       2
u0193               rmb       2
u0195               rmb       68
u01D9               rmb       2
u01DB               rmb       2
u01DD               rmb       323
u0320               rmb       356
u0484               rmb       771
u0787               rmb       634
u0A01               rmb       92
u0A5D               rmb       1
u0A5E               rmb       225
u0B3F               rmb       1
u0B40               rmb       91
u0B9B               rmb       1
u0B9C               rmb       587
u0DE7               rmb       1276
u12E3               rmb       80
u1333               rmb       404
u14C7               rmb       4618
u26D1               rmb       38
u26F7               rmb       779
u2A02               rmb       2974
u35A0               rmb       556
u37CC               rmb       10292
size                equ       .

name                fcs       /RESCUE/

* Genesis!
start               equ       *
* install our signal handler
                    leax      >sighand,pcr        point to the signal handler routine
                    ldu       #$0000              clear U
                    os9       F$Icpt              install the signal handler
                    orcc      #IntMasks           mask interrupts (to load S, apparently)
                    lds       #$5E23              load stack pointer
                    andcc     #^IntMasks          unmask interrupts

* read a character
rdloop              lda       #$04                read one character
                    lbsr      routines            do read routine
                    bcc       rdloop              ...until we get something

* welcome the user to ROF and get monitor type
                    lbsr      Welcome             do welcome message and monitor type

* set the monitor type
                    lda       #stdout             to standard out
                    ldb       #SS.Montr
                    ldx       >mtype              get value of montype flag
                    os9       I$SetStt            set it!

* following code section needs to open a window and get address in 68K
* get a 160x192x16 game screen using SS.AScrn
                    lda       #stdout             to standard out
                    ldb       #SS.AScrn           SS.AScrn is the man!
                    ldx       #$0002              160x192x16 (16k)
                    os9       I$SetStt            set it!
                    lbcs      Rtn3                if error, exit
                    stx       >scrnaddr           save off screen address
                    sty       >scrnnum            save off screen number

* save old pause/echo options then turn them off
                    lda       #stdin              from standard input
                    clrb                          SS.Opt
                    ldx       #pathopts           to this address (NR)
                    os9       I$GetStt            get it!
                    lda       >echoflg            get echo state
                    sta       >oldecho            save it
                    lda       >pauseflg           get pause state
                    sta       >$0CBC              save it
                    clr       >echoflg            we don't want no echo!
                    clr       >pauseflg           we don't want no pause!
                    lda       #$01                ...to standard output
                    clrb                          SS.Opt
* NOTE!  d1 should still be set to SS.Opt here
                    ldx       #pathopts           to this address (NR)
* NOTE!  a0 should still be set to $CCC(a6) here
                    os9       I$SetStt            set it man!


* read in the rtitle.c file into memory
                    ldu       #$1000              address to store title (NR)
                    leax      >rtitle,pcr         file to open (title)
                    lda       #$01                routine to perform (1)
                    lbsr      routines            perform it!

* copy the title into actual display memory
                    lbsr      copyscr

* the following code needs to do a select to the new window
* now display the title on the screen
                    ldy       >scrnnum            get screen number
                    lda       #stdout             to standard out
                    ldb       #SS.DScrn           display screen
                    os9       I$SetStt            show it!
                    lbcs      Rtn3                say bye-bye if error

* now let's set up the palettes
                    ldy       #ccpals             address to store palettes
                    ldd       #$FF0F              A = FF (white), B = offset
palloop             sta       b,y                 store A at B,Y
                    decb                          decrement B
                    bpl       palloop             until B < 0

                    leay      >pals1,pcr          point to new palettes
                    lbsr      setpal              set 'em!

                    clr       >$0CFE
                    clr       >$0CFF
                    clr       >$0D00
                    clr       >$0D01
                    clr       >$05F8
L00B2               clr       >$0CF4
                    lda       #$07
                    sta       >$0CF1
                    ldd       #$3D9A
                    std       >$0CF2

* read in 'rship' file
                    ldu       #$1000              at this address (NR)
                    leax      >rship,pcr          this file
                    lda       #$01                routine 1
                    lbsr      routines            do it!

                    pshs      y                   no. of bytes read
                    lda       #$30
                    sta       >$0CEC
                    lbsr      getjoyxy            joystick routine
                    tst       >$05F8
                    bne       L00DF
                    clra
                    lbsr      L3600
L00DF               lbsr      L019E
                    puls      y
                    lbsr      copyscr

* read the contents of the 'rofvar' file into memory
                    ldu       #rofvbuf            address to store data
                    ldy       #$3002              no. of bytes to read
                    leax      >rofvar,pcr         file to open
                    clra                          routine to perform (0)
                    lbsr      routines            perform it!

* read the contents of the 'panel1' file into memory
                    ldu       #panelbuf           address to store data
                    ldy       #$0212              no. of bytes to read
                    leax      >panel1,pcr         file to open
                    clra                          routine to perform (0)
                    lbsr      routines            perform it!
                    lbsr      L252D

* read the contents of the 'body' file into memory
                    ldu       #bodybuf            address to store data
                    ldy       #$0398              no. of bytes to read
                    leax      >body,pcr           file to open
                    clra                          routine to perform (0)
                    lbsr      routines            perform it!

* read the contents of the 'heads' file into memory
                    ldu       #headsbuf           address to store data
                    ldy       #$06F2              no. of bytes to read
                    leax      >heads,pcr          file to open
                    clra                          routine to perform (0)
                    lbsr      routines            perform it!

* read the contents of the 'larms' file into memory
                    ldu       #larmsbuf           address to store data
                    ldy       #$0915              no. of bytes to read
                    leax      >larms,pcr          file to open
                    clra                          routine to perform (0)
                    lbsr      routines            perform it!

* read the contents of the 'lips' file into memory
                    ldu       #lipsbuf            address to store data
                    ldy       #$0190              no. of bytes to read
                    leax      >lips,pcr           file to open
                    clra                          routine to perform (0)
                    lbsr      routines            perform it!

* read the contents of the 'scores' file into memory
                    leax      >scores,pcr         file to open
                    ldu       #scorebuf           address to store data
                    ldy       #$00B9              no. of bytes to read
                    clra                          routine to perform (0)
                    lbsr      routines            perform it!

                    lda       >$12D4              A = last byte of scores file
                    sta       >$0D02              save A

                    ldu       #$2C90
                    ldx       #$0007
                    ldy       #headsbuf           heads buffer
L0163               sty       ,u++
                    ldd       ,y++
                    mul
                    leay      d,y
                    leax      -$01,x
                    bne       L0163
                    ldu       #$2C9E
                    ldx       #$0005
                    ldy       #larmsbuf           larms buffer
L0179               sty       ,u++
                    ldd       ,y++
                    mul
                    leay      d,y
                    leax      -$01,x
                    bne       L0179
                    ldu       #$2CA8
                    ldx       #$0005
                    ldy       #lipsbuf            lips buffer
L018F               sty       ,u++
                    ldd       ,y++
                    mul
                    leay      d,y
                    leax      -$01,x
                    bne       L018F
                    lbra      L030B

L019E               leay      >pals2,pcr
                    lda       >$0CCA
                    ldb       #$10
                    mul
                    leay      d,y
                    bra       setpal

* loop until a joystick button is pressed (not used?)
L01AC               ldd       #SS.Joy
                    ldx       #$0001
                    os9       I$GetStt
                    tsta
                    beq       L01AC
                    rts

* palette code
* A = color number
* B = palette position (0-15)
writepal            pshs      u,y,x,b,a           save off regs
                    ldx       #ccpals             point to palette address
                    cmpa      b,x                 compare A to B off this address
                    beq       writpal2            if equal, don't bother writing
                    sta       b,x                 else store A at B off this address
                    ldy       #$1B31              palette set code
                    sty       >palstr             save at this address
                    stb       >palstr+2           store palette
                    sta       >palstr+3           store value for palette
                    ldx       #palstr             at this address
                    ldy       #$0004              four bytes
                    lda       #stdout             ...to standard out
                    os9       I$Write             write it!
writpal2            puls      pc,u,y,x,b,a        restore & return


* Y = address of 16 palette entries
setpal              ldb       #15                 set up count
setpal2             lda       b,y                 load B off Y
                    bsr       writepal            set palette
                    decb                          decrement count
                    bpl       setpal2             if > 0, keep on
                    rts

* copy routine:
*    X = source
*    U = destination
*    Y = bytes to copy
copyscr             ldu       >scrnaddr           U = destination (screen address)
                    ldx       #$1000              X = source (screen data) (NR)
                    lbra      rldecode

sighand             rti

* show welcome screen, ask for composite/rgb monitor type
* stay here until we get a legal (C/R) response
Welcome             clr       >mtype              clear high byte of montype flag
welcome2            leax      >welcmess,pcr
                    ldy       #$0061              no. of bytes to write
                    lbsr      WriteOut            write out the welcome message
                    clr       >$0CCA              clear lower byte of montype flag
keyloop             inc       >$0CF0
                    lbsr      Rtn4                read 1 character
                    bcs       keyloop             branch back if not ready
* A = ASCII code of key pressed
                    cmpa      #'c                 'c'?
                    beq       L0220
                    cmpa      #'C                 'C'?
                    beq       L0220
                    inc       >$0CCA
                    cmpa      #'r                 'r'?
                    beq       L0220
                    cmpa      #'R                 'R'?
                    bne       welcome2            key not legal, print welcome again

L0220               lbra      clearscr

                    fcc       "/TERM"
                    fcb       C$CR

rofvar              fcc       "ROFVAR"
                    fcb       C$CR

rtitle              fcc       "RTITLE.C"
                    fcb       C$CR

rship               fcc       "RSHIP.C"
                    fcb       C$CR

panel1              fcc       "PANEL1"
                    fcb       C$CR

body                fcc       "BODY"
                    fcb       C$CR

heads               fcc       "HEADS"
                    fcb       C$CR

larms               fcc       "LARMS"
                    fcb       C$CR

lips                fcc       "LIPS"
                    fcb       C$CR

scores              fcc       "SCORES"
                    fcb       C$CR

legs                fcc       "LEGS"
                    fcb       C$CR

welcmess            fcb       C$FORM,C$CR
                    fcb       C$LF,C$LF,C$LF,C$LF
                    fcc       " WELCOME TO RESCUE ON FRACTALUS"
                    fcb       C$CR,C$LF,C$LF
                    fcc       "  C = COMPOSITE (TV), R = RGB"
                    fcb       C$CR,C$LF
                    fcc       "     MONITOR TYPE (C/R) ? "

pals2
                    fcb       $00,$3f,$38,$07,$00,$02,$12,$01,$1b,$0a,$19,$28,$1f,$34,$04,$04
                    fcb       $00,$3f,$38,$07,$00,$10,$12,$09,$1b,$0a,$19,$28,$1f,$34,$22,$04

pals1
                    fcb       $00,$3f,$38,$07,$1b,$19,$06,$3c,$2e,$26,$24,$20,$36,$32,$31,$04

* standard palettes (restore upon exit)
stdpals
                    fcb       $12,$36,$09,$24,$3f,$1b,$2d,$34,$00,$12,$00,$3f,$00,$12,$00,$34

L030B               ldx       #$0CBB
                    ldu       #$0000
                    clra
                    lbsr      L0896
                    ldy       #$0D03
L0319               ldb       #$C0
L031B               ldx       >scrnaddr           screen address
L031E               stx       ,y++
                    leax      <$50,x
                    decb
                    bne       L031E
                    ldy       #$0E83
                    ldb       #$60
                    ldx       #$5CF7
L032F               stx       ,y++
                    leax      <-$50,x
                    decb
                    bne       L032F
L0337               ldd       >scrnaddr           screen address
                    addd      #$3C00
                    std       >$05A8
                    addd      #$0200
                    std       >$05AA
                    clr       >$0171
                    clr       >$0174
                    clr       >$0117
                    clr       >$011B
L0352               ldx       #$0009
                    ldu       #$0CF5
                    clra
                    lbsr      L0896
                    clr       <u0085
                    lda       #$04
                    sta       <u007A
                    lda       #$01
                    sta       <u00E6
                    lda       #$10
                    sta       >$0CFA
L036B               tst       <u0085
                    bne       L0352
                    clr       <u0070
                    clr       >$017A
                    clr       <u00F6
                    ldx       #$0019
                    ldu       #$00F5
                    clra
                    lbsr      L0896
                    lbsr      getjoyxy
                    clr       <u0079
                    clr       >$011D
                    clr       <u00FB
                    clr       >$0601
                    clr       >$0157
                    clr       >$0616
                    clr       >$0603
                    clr       >$0604
                    lda       #$80
                    sta       >$010F
                    sta       >$0110
                    sta       >$0111
                    sta       >$011E
                    sta       >$0112
                    sta       <u0084
                    lda       #$66
                    sta       >$0177
                    lda       #$FF
                    sta       <u00D8
                    sta       >$05F8
                    lda       >$0D02
                    cmpa      >$0CFA
                    bls       L03C3
                    sta       >$0CFA
L03C3               lda       #$01
                    sta       <u00E6
L03C7               lbsr      L0412
                    lbra      L2D4E
L03CD               rts

L03CE               pshs      a
L03D0               lda       <u005F
                    bne       L03D7
                    lda       ,s+
                    rts

L03D7               bra       L03FF
L03D9               pshs      a
                    lda       #$3C
                    bra       L03E3
L03DF               pshs      a
                    lda       #$01
L03E3               sta       <u005F
                    bne       L03D0
L03E7               pshs      a
                    lda       #$02
                    bra       L03E3
L03ED               pshs      a
                    lda       #$05
                    bra       L03E3
L03F3               pshs      a
                    lda       #$0A
                    bra       L03E3
L03F9               pshs      a
                    lda       #$14
                    bra       L03E3
L03FF               ldb       #$14
L0401               lda       #$73
L0403               deca
                    bne       L0403
                    decb
                    bne       L0401
                    inc       >$019B
                    dec       <u005F
                    bne       L03FF
                    puls      pc,a
L0412               lbsr      L019E
                    lbsr      L3CE2
                    ldy       #$0009
                    lbsr      L3E0A
                    lbsr      L2B0C
                    lda       #$08
                    lbsr      L3E92
                    clr       >$0109
                    clr       >$010A
                    clr       >$0107
                    lbsr      L393A
                    ldx       #$0011
                    lda       #$12
                    sta       <u00CE
                    lbsr      L3E39
L043D               lbsr      L3FFC
                    lbsr      L57C2
                    lbsr      L3AF9
                    lbsr      L57CC
                    lbsr      L3F51
                    lbsr      L3F4E
                    lbra      L56F3
L0452               lda       #$01
                    sta       >$011E
                    ldy       #$0000
                    ldb       #$4F
L045D               clr       ,y+
                    decb
                    bpl       L045D
                    lda       >$0CF0
                    sta       <u0033
                    clr       >$0603
                    clr       >$0604
                    clr       >$05EF
                    clr       >$05F0
                    dec       >$05F0
                    clr       <u0073
                    clr       >$0CFD
                    clr       <u0057
                    lda       #$E8
                    sta       <u003B
                    lda       #$18
                    sta       <u003C
                    clra
                    ldy       #$0896
                    ldx       #$00A0
                    lbsr      L0896
                    lbsr      L37E9
                    tst       <u00F8
                    bne       L04A0
                    lbsr      L0ACE
                    lbsr      L0BDF
                    lbsr      L07C6
L04A0               tst       <u0085
                    bne       L04AC
                    lda       #$14
                    sta       <u0054
                    lda       #$02
                    bra       L04AE
L04AC               lda       #$01
L04AE               sta       <u005C
                    clra
                    lbsr      L2A9A
L04B4               lbsr      L065E
                    lbsr      L107C
                    lbsr      L14E9
                    ldb       <u0072
                    bmi       L04C4
                    lbsr      L3D3E
L04C4               lbsr      L3F61
                    tst       <u0072
                    bpl       L04CE
                    lbsr      L3EA1
L04CE               lbsr      L1AA6
                    lbsr      L23EB
                    lbsr      L279E
                    lbsr      L0614
                    tst       >$08A6
                    beq       L04E2
                    lbsr      L577B
L04E2               tst       >$010E
                    lbne      L06A4
                    lda       <u00FB
                    cmpa      #$0E
                    bcc       L0501
                    tst       <u0085
                    beq       L04F8
                    lbsr      L45B1
                    bra       L0501
L04F8               lda       <u004A
                    cmpa      #$01
                    bne       L0501
                    lbsr      L460D
L0501               tst       <u00FD
                    beq       L0508
                    lbsr      L4522
L0508               lbsr      L5712
                    lda       <u00FB
                    cmpa      #$20
                    bcc       L052B
                    lbsr      L5712
                    lda       <u004F
                    bne       L052B
                    lda       <u00FB
                    beq       L052B
                    tst       <u0071
                    bpl       L052B
                    ldb       <u007E
                    cmpb      #$02
                    beq       L052B
                    lda       #$0A
                    lbsr      L3600
L052B               lbsr      L107C
                    lbsr      L14E9
                    ldb       <u0072
                    bmi       L0538
                    lbsr      L3D3E
L0538               lbsr      L3F61
                    tst       <u0072
                    bpl       L0542
                    lbsr      L3EA1
L0542               lbsr      L1AA6
                    lbsr      L23EB
                    lbsr      L279E
                    lbsr      L0614
                    tst       >$08A6
                    beq       L0556
                    lbsr      L577B
L0556               tst       >$010E
                    lbne      L06A4
                    tst       >$0912
                    beq       L0588
                    tst       >$0911
                    beq       L0588
                    lbsr      L425B
                    tst       <u004A
                    bpl       L0588
                    ldx       #$0011
                    lda       #$12
                    sta       <u00CE
                    lbsr      L3E39
                    lda       #$12
                    ldb       #$11
                    ldx       #$0011
                    stb       <u00CE
                    inc       <u0070
                    lbsr      L3E39
                    dec       <u0070
L0588               lda       >$0911
                    sta       >$0912
                    lda       <u004F
                    sta       >$0911
                    lda       #$01
                    cmpa      <u004F
                    beq       L05BC
                    ldb       <u007E
                    cmpb      #$02
                    beq       L05C4
                    tst       <u004E
                    beq       L05B5
                    lda       #$02
                    sta       <u004E
                    lda       #$0E
                    sta       <u0054
                    ldb       #$10
                    ldx       #$0010
                    stb       <u00CE
                    lbsr      L3E39
L05B5               tst       <u00FD
                    beq       L05BC
                    lbsr      L4522
L05BC               ldb       <u007E
                    cmpb      #$02
                    lbne      L04B4
L05C4               lda       #$03
                    sta       <u005C
                    lda       #$FF
                    sta       <u0077
                    ldb       #$80
                    stb       >$0938
                    stb       >$0939
                    lda       <u0047
                    cmpa      #$40
                    lbcs      L04B4
                    stb       <u0084
                    clr       >$0107
                    clr       >$010B
                    lbsr      L089D
                    clr       <u005C
                    lda       #$08
                    lbsr      L3E92
                    clr       >$0109
                    clr       >$010A
                    clr       >$0107
                    ldb       #$01
                    stb       >$0110
                    lbsr      L393A
                    ldx       #$0011
                    lda       #$12
                    sta       <u00CE
                    lbsr      L3E39
                    lbsr      L043D
                    clr       >$012D
                    clr       <u0057
                    lbra      L03C7
L0614               lda       >$0601
                    beq       L065D
                    cmpa      #$14
                    beq       L063B
                    lbsr      L2A9A
                    lbsr      L35E7
                    lda       >$0116
                    lbsr      L2A9A
                    lda       >$0601
                    cmpa      #$13
                    bne       L065A
                    lda       #$14
                    sta       >$0601
                    lda       #$05
                    sta       >$0614
                    rts

L063B               dec       >$0614
                    beq       L0654
                    lbsr      L56E2
                    anda      #$3F
                    ldb       #$0B
                    lbsr      writepal
                    lbsr      L56E2
                    anda      #$3F
                    ldb       #$0C
                    lbra      writepal
L0654               lda       >$0116
                    lbsr      L2A9A
L065A               clr       >$0601
L065D               rts

L065E               ldb       >$0604
                    beq       L06A3
                    ldy       #$3D5E
                    ldx       #$3D64
                    decb
L066B               lda       b,x
                    cmpa      b,y
                    bne       L06A0
                    decb
                    bpl       L066B
                    ldb       >$0604
                    cmpb      #$06
                    bcs       L06A3
                    bhi       L06A0
                    lbsr      L3341
                    ldd       #$0000
                    lbsr      L23DE
                    ldu       #$3F47
                    leax      >legs,pcr
                    lda       #$05
                    lbsr      routines
                    lbsr      L5564
L0695               lda       #$04
                    lbsr      routines
                    bcs       L0695
                    clrb
                    lbra      Rtn3
L06A0               clr       >$0604
L06A3               rts

L06A4               lda       #$80
                    sta       <u0084
                    clr       <u005C
                    lda       #$10
                    sta       <u00D0
L06AE               dec       <u00D0
                    bne       L06AE
L06B2               lbsr      L3341
                    lda       #$20
                    sta       <u0077
L06B9               lbsr      L56E2
                    anda      #$3F
                    clrb
                    lbsr      writepal
                    lbsr      L35BC
                    ldx       #$0014
                    lbsr      L5819
                    dec       <u0077
                    bne       L06B9
                    lda       #$00
                    clrb
                    lbsr      writepal
                    ldx       #$0064
                    lbsr      L5819
                    ldy       #$0000
L06DF               lda       >$0CF5,y
                    cmpa      >$0CFE,y
                    beq       L06FD
                    bcs       L0705
                    ldy       #$0004
L06EF               lda       >$0CF4,y
                    sta       >$0CFD,y
                    leay      -$01,y
                    bne       L06EF
                    bra       L0705
L06FD               leay      $01,y
                    cmpy      #$0004
                    bcs       L06DF
L0705               lda       #$01
                    sta       >$0127
                    lbsr      L32D5
                    lbra      L00B2
                    lda       #$08
                    sta       <u00D0
L0714               dec       <u00D0
                    bne       L0714
                    clr       <u0052
                    clr       <u0077
                    tst       >$010E
                    lbne      L06A4
                    rts

                    lbsr      L56E2
                    tfr       a,b
                    andb      #$07
                    clra
                    tfr       d,y
                    lda       >$3C17,y
                    tfr       a,b
                    lbsr      L03CD
L0737               lbsr      L56E2
                    anda      #$3F
                    adca      #$60
                    sta       <u0077
                    lbsr      L35BC
                    lbsr      L56E2
                    anda      #$07
                    bne       L0737
                    rts

L074B               lbsr      L0754
                    lbsr      L0799
                    lbra      L06B2
L0754               lda       #$15
                    sta       <u00CA
                    bra       L075F
L075A               lbsr      L56E2
                    bpl       L0765
L075F               anda      #$0F
                    sta       <u00CC
                    inc       <u00CC
L0765               lbsr      L56E2
                    anda      #$0F
                    lsla
                    eora      #$1F
                    lsla
                    sta       <u00CE
                    ldx       #$0004
L0773               ldb       <u00CC
L0775               lda       <u00CE
L0777               deca
                    nop
                    nop
                    nop
                    nop
                    nop
                    bne       L0777
                    decb
                    bne       L0775
                    leax      -$01,x
                    bne       L0773
                    dec       <u00CA
                    bpl       L075A
                    rts

L078B               lbsr      L56E2
                    cmpa      <u0077
                    bcc       L0792
L0792               clra
L0793               deca
                    bne       L0793
                    bmi       L078B
                    rts

L0799               ldd       #$9999
                    lbsr      L23DE
                    lbsr      L23EB
                    lbsr      L279E
                    ldx       #$001E
                    lbsr      L5819
                    ldd       #$AAAA
                    lbsr      L23DE
                    lbsr      L23EB
                    lbsr      L279E
                    ldx       #$001E
                    lbsr      L5819
                    clr       <u0059
                    clr       <u0058
                    clr       <u0057
                    lbra      L236A
L07C6               ldy       #$02BC
                    clrb
L07CB               clr       ,y+
                    decb
                    bne       L07CB
                    ldy       #$0008
                    lda       <u007A
                    cmpa      #$01
                    bne       L07DE
                    ldy       #$0010
L07DE               lbsr      L0813
                    lda       <u007A
                    cmpa      #$04
                    bcs       L07F0
                    ldy       #$0004
                    lda       #$01
                    lbsr      L0815
L07F0               ldx       #$0000
L07F3               lbsr      L56E2
                    cmpa      <u00F1
                    bcc       L0806
                    lda       >$01BC,x
                    bpl       L0806
                    lda       #$64
                    sta       >$02BC,x
L0806               tfr       x,d
                    addb      #$43
                    tfr       d,x
                    bne       L07F3
                    rts

L080F               ldy       #$0001
L0813               lda       #$C8
L0815               sta       >$087D
                    tfr       y,d
                    stb       >$0910
L081D               lbsr      L56E2
                    ldb       <u0032
                    stb       >$090F
                    clra
                    tfr       d,x
L0828               lda       >$01BC,x
                    cmpa      #$30
                    bcc       L084D
                    lda       >$02BC,x
                    bne       L084D
                    ldy       #$002D
L083A               cmpb      >$09D1,y
                    beq       L084D
                    leay      -$01,y
                    bne       L083A
                    lda       >$087D
                    sta       >$02BC,x
                    bra       L0858
L084D               tfr       x,d
                    addb      #$43
                    tfr       d,x
                    cmpb      >$090F
                    bne       L0828
L0858               dec       >$0910
                    bne       L081D
                    rts

L085E               ldx       #$0000
L0861               tfr       x,d
                    stb       >$087F
                    lda       >$02BC,x
                    cmpa      #$01
                    bne       L088B
                    ldx       #$002D
L0871               lda       >$09D1,x
                    cmpa      >$087F
                    beq       L088B
                    leax      -$01,x
                    bne       L0871
                    clra
                    ldb       >$087F
                    tfr       d,x
                    lda       #$80
                    sta       >$02BC,x
                    rts

L088B               clra
                    ldb       >$087F
                    addb      #$43
                    tfr       d,x
                    bne       L0861
                    rts

L0896               sta       ,u+
                    leax      -$01,x
                    bne       L0896
                    rts

L089D               tst       <u0077
                    beq       L08AD
                    lbsr      L35BC
                    lda       <u0077
                    suba      #$10
                    bcc       L08AB
                    clra
L08AB               sta       <u0077
L08AD               inc       >$019B
                    bne       L08B5
                    inc       >$019A
L08B5               dec       >$010C
                    lbeq      L0912
                    ldb       <u0049
                    orb       >$0616
                    beq       L08C6
                    lbsr      L49F0
L08C6               tst       <u005C
                    beq       L08D6
                    dec       <u005D
                    lbsr      L393A
                    lda       <u004C
                    beq       L08D6
                    lbsr      L3BA6
L08D6               lda       >$0103
                    bmi       L08FE
                    dec       >$0103
                    bpl       L0908
                    lda       <u0054
                    bne       L08FE
                    lda       <u0085
                    bne       L08F8
                    lda       <u007E
                    cmpa      #$00
                    bne       L08F3
                    inc       >$0103
                    bra       L0908
L08F3               lbsr      L2B0C
                    bra       L0908
L08F8               ldy       #$0013
                    bne       L0905
L08FE               clra
                    ldb       <u0054
                    tfr       d,y
                    beq       L0908
L0905               lbsr      L41BE
L0908               lda       <u0055
                    beq       L090F
                    lbsr      L41FD
L090F               lbra      L0A45
L0912               lbsr      L3C7C
                    lda       #$02
                    sta       >$010C
                    tst       <u0085
                    beq       L092A
                    tst       >$089D
                    bne       L0940
                    tst       <u005C
                    bne       L0972
L0927               lbra      L09B3
L092A               cmpa      <u005C
                    bne       L0927
                    tst       >$0112
                    bne       L0972
                    lda       <u004F
                    beq       L0940
                    sta       >$0103
                    lda       #$0F
                    sta       <u0054
                    bra       L0972
L0940               lda       #$80
                    sta       <u0078
                    lda       <u0049
                    ora       >$0616
                    bne       L0972
                    lda       #$7E
                    sta       >$08B3
                    clr       >$08EF
                    lda       #$9B
                    suba      >$3A9C
                    sta       >$08B5
                    clr       >$089D
                    lda       #$0C
                    sta       >$08F1
                    lda       #$01
                    sta       >$08F0
                    lda       #$18
                    sta       <u0049
                    clr       >$0616
                    lbsr      L35EF
L0972               lbsr      L3B82
                    lbsr      getjoyxy
                    dec       <u005E
                    bpl       L097E
                    inc       <u005E
L097E               bne       L099D
                    ldb       #$FF
                    stb       >$0112
                    tst       >button
                    beq       L099D
                    clr       >$0112
                    bra       L099D
                    lda       <u007E
                    cmpa      #$00
                    bne       L0999
                    lda       #$95
                    bra       L09AB
L0999               lda       #$4C
                    bra       L09AB
L099D               lbsr      L4019
                    bcs       L09B3
                    lbsr      readch
                    cmpa      #$E0
                    bcs       L09AB
                    anda      #$DF
L09AB               tfr       a,b
                    clra
                    tfr       d,x
                    lbsr      L4046
L09B3               lda       <u005C
                    lbeq      L0A45
                    lbsr      L4B6F
                    lbsr      L0C9D
                    clr       >$0128
                    clrb
                    lda       <u0047
                    suba      #$3C
                    bcs       L09D7
                    lsra
                    lsra
                    lsra
                    tfr       a,b
                    cmpb      #$03
                    bcs       L09D7
                    ldb       #$03
                    inc       >$0128
L09D7               lslb
                    lslb
                    cmpb      >$0617
                    beq       L09E7
                    stb       >$0617
                    lda       >$0116
                    lbsr      L2A9A
L09E7               lda       <u00E7
                    bne       L0A11
                    dec       >$0114
                    bne       L0A11
                    lda       #$80
                    sta       >$0114
                    inc       >$0115
                    ldb       >$0115
                    lsrb
                    lsrb
                    andb      #$0F
                    clra
                    tfr       d,y
                    lda       >$3C1F,y
                    cmpa      >$0116
                    beq       L0A11
                    sta       >$0116
                    lbsr      L2A9A
L0A11               lbsr      L3A13
                    lbsr      L3B4D
                    lbsr      L3866
                    lbsr      L3E04
                    lbsr      L3F61
                    dec       >$0113
                    bne       L0A45
                    lda       >$08AE
                    beq       L0A32
                    dec       >$08AE
                    bne       L0A32
                    lbsr      L460D
L0A32               lda       <u004E
                    bne       L0A40
                    lda       <u0056
                    adda      #$01
                    daa
                    sta       <u0056
                    lbsr      L41FD
L0A40               lda       #$0F
                    sta       >$0113
L0A45               lbsr      L0A66
                    lda       >$0115
                    anda      #$3F
                    cmpa      #$28
                    bne       L0A59
                    lda       <u00F5
                    adda      #$0F
                    bcc       L0A65
                    bra       L0A63
L0A59               cmpa      #$30
                    bne       L0A65
                    lda       <u00F5
                    suba      #$0F
                    bcs       L0A65
L0A63               sta       <u00F5
L0A65               rts

L0A66               tst       >$0CEC
                    bne       L0A6C
                    rts

L0A6C               lda       <u007E
                    cmpa      #$02
                    beq       L0AAD
                    lda       <u0071
                    bmi       L0AAD
                    eora      #$7F
                    lsra
                    lsra
                    suba      #$10
                    sta       >$0CEC
                    lda       >$0887
                    sta       <u00CC
                    lda       >$0888
                    lbsr      L0AB8
                    sta       <u00CA
                    lda       >$088A
                    sta       <u00CC
                    lda       >$088B
                    lbsr      L0AB8
                    adda      <u00CA
                    sta       <u00CA
                    lda       #$0F
                    suba      <u00CA
                    adda      >$0CEC
                    bpl       L0AA5
                    clra
L0AA5               lsra
                    lsra
                    adda      #$02
                    sta       >$0CEC
                    rts

L0AAD               lda       >$019B
                    anda      #$0F
                    bne       L0AB7
                    dec       >$0CEC
L0AB7               rts

L0AB8               lsr       <u00CC
                    rora
                    lsr       <u00CC
                    rora
                    lsr       <u00CC
                    rora
                    lsr       <u00CC
                    rora
                    suba      #$08
                    bpl       L0AC9
                    nega
L0AC9               rts

L0ACA               clr       >$0CEC
                    rts

L0ACE               ldx       #$01BC
                    ldb       #$00
L0AD3               lbsr      L56E2
                    anda      #$3F
                    ora       #$80
                    sta       ,x+
                    decb
                    bne       L0AD3
                    ldb       #$01
                    stb       <u00AE
                    lbsr      L56E2
                    sta       <u00B2
                    tfr       a,b
                    clra
                    tfr       d,x
                    lbsr      L56E2
                    anda      #$3F
                    sta       >$01BC,x
L0AF6               lda       <u00AE
                    sta       <u00AF
                    lbsr      L0B93
                    lda       <u00AE
                    cmpa      <u00AF
                    beq       L0B59
L0B03               lbsr      L56E2
                    lda       <u0032
                    anda      #$40
                    beq       L0B1C
                    tst       <u0032
                    bmi       L0B16
                    lda       #$10
                    ldb       #$FF
                    bra       L0B2A
L0B16               lda       #$F0
                    ldb       #$01
                    bra       L0B2A
L0B1C               tst       <u0032
                    bmi       L0B26
                    lda       #$01
                    ldb       #$10
                    bra       L0B2A
L0B26               lda       #$FF
                    ldb       #$F0
L0B2A               sta       <u00B0
                    stb       <u00B1
                    lbsr      L0B6C
                    bpl       L0B03
                    ldb       <u00B2
                    addb      <u00B0
                    clra
                    tfr       d,x
                    lbsr      L56E2
                    anda      #$3F
                    sta       >$01BC,x
                    tfr       x,d
                    addb      <u00B0
                    tfr       d,x
                    lbsr      L56E2
                    anda      #$3F
                    sta       >$01BC,x
                    tfr       x,d
                    stb       <u00B2
                    lbra      L0AF6
L0B59               dec       <u00AE
                    bne       L0B5E
                    rts

L0B5E               clra
                    ldb       <u00AE
                    tfr       d,x
                    lda       >$0618,x
                    sta       <u00B2
                    lbra      L0AF6
L0B6C               ldb       <u00B2
                    addb      <u00B0
                    clra
                    tfr       d,x
                    lda       >$01BC,x
                    bpl       L0B91
                    tfr       x,d
                    addb      <u00B0
                    tfr       d,y
                    lda       >$01BC,y
                    bpl       L0B91
                    tfr       x,d
                    addb      <u00B1
                    tfr       d,x
                    lda       >$01BC,x
                    bmi       L0B92
L0B91               clra
L0B92               rts

L0B93               lda       #$01
                    sta       <u00B0
                    lda       #$10
                    sta       <u00B1
                    lbsr      L0B6C
                    bpl       L0BA3
                    lbsr      L0BD1
L0BA3               lda       #$FF
                    sta       <u00B0
                    lda       #$F0
                    sta       <u00B1
                    lbsr      L0B6C
                    bpl       L0BB3
                    lbsr      L0BD1
L0BB3               lda       #$10
                    sta       <u00B0
                    lda       #$FF
                    sta       <u00B1
                    lbsr      L0B6C
                    bpl       L0BC3
                    lbsr      L0BD1
L0BC3               lda       #$F0
                    sta       <u00B0
                    lda       #$01
                    sta       <u00B1
                    lbsr      L0B6C
                    bmi       L0BD1
                    rts

L0BD1               clra
                    ldb       <u00AE
                    tfr       d,x
                    lda       <u00B2
                    sta       >$0618,x
                    inc       <u00AE
                    rts

L0BDF               ldb       <u007A
                    decb
                    beq       L0BE9
                    lbsr      L56E2
                    anda      #$07
L0BE9               bne       L0C1D
                    lbsr      L56E2
                    anda      #$70
                    ora       #$80
                    sta       <u00D2
                    ldy       #$0000
L0BF8               tfr       y,d
                    andb      #$80
                    bne       L0C15
                    tfr       y,d
                    andb      #$08
                    bne       L0C15
                    lbsr      L56E2
                    cmpa      <u00D2
                    bcc       L0C15
                    lda       >$01BC,y
                    anda      #$7F
                    sta       >$01BC,y
L0C15               leay      $01,y
                    cmpy      #$0100
                    bne       L0BF8
L0C1D               rts

L0C1E               ldd       >$0909
                    lslb
                    rola
                    rolb
                    rola
                    pshs      a
                    clrb
                    stb       >$0903
                    lda       ,s
                    lsla
                    bcc       L0C33
                    dec       >$0903
L0C33               lsla
                    bcc       L0C37
                    decb
L0C37               eorb      >$0903
                    stb       >$0905
                    ldd       #$0000
                    rolb
                    tfr       d,x
                    puls      a
                    anda      #$3F
                    sta       >$0936
                    sta       >$0937
                    eora      #$3F
                    inca
                    sta       >$0936,x
                    clra
                    ldb       >$0937
                    lslb
                    rola
                    leax      >L59E7,pcr
                    leax      d,x
                    lda       ,x
                    ldb       <u0041
                    lbsr      L1040
                    sta       >$0904
                    tsta
                    bne       L0C70
                    sta       >$0903
L0C70               lda       >$0903
                    beq       L0C78
                    neg       >$0904
L0C78               ldb       >$0936
                    clra
                    lslb
                    rola
                    leax      >L59E7,pcr
                    leax      d,x
                    lda       ,x
                    ldb       <u0041
                    lbsr      L1040
                    sta       >$0906
                    tsta
                    bne       L0C94
                    sta       >$0905
L0C94               lda       >$0905
                    beq       L0C9C
                    neg       >$0906
L0C9C               rts

L0C9D               ldd       >$090B
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       >$09CC
                    std       >$085C
                    std       >$0861
                    ldd       >$090D
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       >$09CE
                    std       >$085E
                    std       >$0863
                    ldd       <u0047
                    cmpa      #$40
                    bcs       L0CCD
                    lda       #$3F
L0CCD               lslb
                    rola
                    lslb
                    rola
                    std       >$09D0
                    lbsr      L0E2D
                    lda       >$0860
                    lsra
                    adca      #$00
                    lsra
                    adca      #$00
                    sta       >$0858
                    lda       #$37
                    suba      >$0858
                    bcc       L0CEB
                    clra
L0CEB               sta       >$087A
                    lda       >$09D0
                    suba      >$0860
                    bcs       L0D02
                    sta       <u007D
                    lda       >$08A2
                    bne       L0D19
                    lbsr      L0F3D
                    bra       L0D19
L0D02               lda       <u007E
                    cmpa      #$00
                    beq       L0D0B
                    lbsr      L0F1E
L0D0B               inc       <u0047
                    clr       <u0048
                    clr       <u007D
                    lda       <u003E
                    bpl       L0D19
                    inc       <u003E
                    clr       <u003F
L0D19               lda       #$37
                    suba      <u0047
                    bcc       L0D2D
                    nega
                    adda      >$087A
                    cmpa      #$38
                    bcs       L0D29
                    lda       #$38
L0D29               sta       >$087A
                    clra
L0D2D               sta       >$087B
                    lbsr      L0D7A
                    lda       >$017A
                    cmpa      #$08
                    bcs       L0D55
                    lda       #$01
                    sta       >$08FC
                    lda       <u0057
                    bne       L0D79
                    lda       #$10
                    sta       <u0057
                    lda       #$10
                    lbsr      L2A9A
                    lbsr      L35E7
                    lda       >$0116
                    lbra      L2A9A
L0D55               tst       >$08FC
                    beq       L0D79
                    cmpa      #$04
                    bcc       L0D79
                    clr       >$08FC
                    clr       <u0052
                    lda       #$10
                    lbsr      L2A9A
                    lbsr      L35E7
                    lda       >$0116
                    lbsr      L2A9A
                    lda       <u0057
                    cmpa      #$20
                    bcc       L0D79
                    clr       <u0057
L0D79               rts

L0D7A               lsr       >$089A
                    bcs       L0D83
                    inc       >$089A
                    rts

L0D83               ldd       >$0869
                    ldy       #$0004
L0D8A               asra
                    rorb
                    leay      -$01,y
                    bne       L0D8A
                    std       >$0865
                    ldd       >$086B
                    ldy       #$0004
L0D9A               asra
                    rorb
                    leay      -$01,y
                    bne       L0D9A
                    std       >$0867
                    lsr       >$0899
                    bcs       L0DEC
                    inc       >$0899
                    ldd       >$0861
                    subd      >$0867
                    std       >$085C
                    ldd       >$0863
                    addd      >$0865
                    std       >$085E
                    lbsr      L0E2D
                    lsr       >$0860
                    lda       >$0860
                    lsra
                    sta       >$0856
                    lda       >$09D0
                    lsra
                    adda      <u0037
                    adda      #$0F
                    suba      >$0860
                    bcc       L0DD8
                    clra
L0DD8               sta       >$0855
                    lda       #$36
                    suba      >$0855
                    bcc       L0DE3
                    clra
L0DE3               sta       >$0896
                    sta       >$08A7
L0DE9               lbra      L3FAC
L0DEC               ldd       >$0861
                    addd      >$0867
                    std       >$085C
                    ldd       >$0863
                    subd      >$0865
                    std       >$085E
                    lbsr      L0E2D
                    lsr       >$0860
                    lda       >$0860
                    lsra
                    sta       >$0857
                    lda       >$09D0
                    lsra
                    suba      <u0037
                    adda      #$0F
                    suba      >$0860
                    bcc       L0E19
                    clra
L0E19               sta       >$0855
                    lda       #$36
                    suba      >$0855
                    bcc       L0E24
                    clra
L0E24               sta       >$0897
                    sta       >$08A8
L0E2A               lbra      L3FAC
L0E2D               lda       >$085E
                    lsla
                    lsla
                    lsla
                    lsla
                    sta       <u006F
                    ldb       >$085C
                    andb      #$0F
                    orb       <u006F
                    clra
                    tfr       d,y
                    lda       >$01BC,y
                    sta       >$084F
                    tfr       y,d
                    incb
                    andb      #$0F
                    orb       <u006F
                    tfr       d,y
                    lda       >$01BC,y
                    sta       >$0850
                    lda       <u006F
                    adda      #$10
                    sta       <u006F
                    ldb       >$085C
                    andb      #$0F
                    orb       <u006F
                    clra
                    tfr       d,y
                    lda       >$01BC,y
                    sta       >$0851
                    tfr       y,d
                    incb
                    andb      #$0F
                    orb       <u006F
                    tfr       d,y
                    lda       >$01BC,y
                    sta       >$0852
                    ldb       >$085D
                    stb       >$0859
                    ldy       #$0008
                    clra
L0E89               lsl       >$0859
                    bcs       L0E9D
                    lsr       >$0850
                    lsr       >$084F
                    adca      >$084F
                    leay      -$01,y
                    bne       L0E89
                    bra       L0EAA
L0E9D               lsr       >$084F
                    lsr       >$0850
                    adca      >$0850
                    leay      -$01,y
                    bne       L0E89
L0EAA               sta       >$0853
                    stb       >$0859
                    ldy       #$0008
                    clra
L0EB5               lsl       >$0859
                    bcs       L0EC9
                    lsr       >$0852
                    lsr       >$0851
                    adca      >$0851
                    leay      -$01,y
                    bne       L0EB5
                    bra       L0ED6
L0EC9               lsr       >$0851
                    lsr       >$0852
                    adca      >$0852
                    leay      -$01,y
                    bne       L0EB5
L0ED6               sta       >$0854
                    lda       >$085F
                    sta       >$085A
                    ldy       #$0008
                    clra
L0EE4               lsl       >$085A
                    bcs       L0EF8
                    lsr       >$0854
                    lsr       >$0853
                    adca      >$0853
                    leay      -$01,y
                    bne       L0EE4
                    bra       L0F05
L0EF8               lsr       >$0853
                    lsr       >$0854
                    adca      >$0854
                    leay      -$01,y
                    bne       L0EE4
L0F05               sta       >$0860
                    lsra
                    lsra
                    lsra
                    lsra
                    pshs      a
                    adda      >$0860
                    sta       >$0860
                    puls      a
                    lsra
                    adca      >$0860
                    sta       >$0860
                    rts

L0F1E               inc       >$017A
                    lda       <u0042
                    ora       #$40
                    sta       >$08FA
                    lda       <u00FB
                    beq       L0F3C
                    ldx       #$0010
                    tfr       x,d
                    stb       <u00CE
                    lbsr      L3E39
                    lda       <u0041
                    beq       L0F3C
                    dec       <u0041
L0F3C               rts

L0F3D               clr       >$017A
                    clr       >$08FA
                    lda       <u004E
                    bne       L0F3C
                    ldx       #$0010
                    lda       #$11
                    sta       <u00CE
                    lbra      L3E39
L0F51               ldd       >$0909
                    lslb
                    rola
                    lslb
                    rola
                    sta       <u007F
                    lda       >$090A
                    lsra
                    lsra
                    lsra
                    anda      #$07
                    sta       >$086D
                    bsr       L0F7A
                    ldd       <u0080
                    std       >$0869
                    lda       <u007F
                    adda      #$40
                    sta       <u007F
                    bsr       L0F7A
                    ldd       <u0080
                    std       >$086B
                    rts

L0F7A               inc       <u007F
                    lbsr      L0FDC
                    ldd       <u0080
                    std       >$0876
                    lda       <u0082
                    sta       >$0878
                    dec       <u007F
                    lbsr      L0FDC
                    ldd       <u0080
                    std       >$0873
                    lda       <u0082
                    sta       >$0875
                    lda       >$086D
                    sta       >$086F
                    ldy       #$0003
L0FA2               lsr       >$086F
                    bcc       L0FB7
                    ldd       <u0081
                    addd      >$0877
                    std       <u0081
                    lda       <u0080
                    adca      >$0876
                    sta       <u0080
                    bra       L0FC5
L0FB7               ldd       <u0081
                    addd      >$0874
                    std       <u0081
                    lda       <u0080
                    adca      >$0873
                    sta       <u0080
L0FC5               lsl       >$0875
                    rol       >$0874
                    rol       >$0873
                    lsl       >$0878
                    rol       >$0877
                    rol       >$0876
                    leay      -$01,y
                    bne       L0FA2
                    rts

L0FDC               clra
                    ldb       <u007F
                    lslb
                    rola
                    lslb
                    rola
                    sta       >$086E
                    lsrb
                    lsrb
                    ldx       #$3C33
                    eorb      a,x
                    clra
                    lslb
                    rola
                    leay      >L59E7,pcr
                    leay      d,y
                    ldx       #$3C2F
                    ldb       >$086E
                    lda       b,x
                    bne       L1007
                    sta       <u0080
                    ldd       ,y
                    std       <u0081
                    rts

L1007               ldd       #$0000
                    subd      ,y
                    std       <u0081
                    lda       #$00
                    sbca      #$00
                    sta       <u0080
                    rts

L1015               sta       <u00C0
                    ldd       <u00BE
                    sta       <u00C1
                    bpl       L1024
                    ldd       #$0000
                    subd      <u00BE
                    std       <u00BE
L1024               lda       <u00C0
                    mul
                    sta       <u00BF
                    lda       <u00C0
                    ldb       <u00BE
                    mul
                    addb      <u00BF
                    adca      #$00
                    std       <u00BC
                    tst       <u00C1
                    bpl       L103F
                    ldd       #$0000
                    subd      <u00BC
                    std       <u00BC
L103F               rts

L1040               mul
                    tstb
                    bpl       L1045
                    inca
L1045               rts

L1046               lsl       <u00C5
                    rol       <u00C4
                    lsl       <u00C3
                    rol       <u00C2
L104E               lda       <u00C2
                    lsla
                    bpl       L1046
                    pshs      x
                    ldx       #$0008
                    ldd       <u00C4
L105A               lslb
                    rola
                    bmi       L1062
                    lsla
                    bpl       L106C
                    rora
L1062               subd      <u00C2
                    bcc       L1071
                    addd      <u00C2
                    andcc     #^Carry             clear carry flag
                    bra       L1073
L106C               rora
                    andcc     #^Carry             clear carry flag
                    bra       L1073
L1071               orcc      #Carry              set carry flag
L1073               rol       <u00C6
                    leax      -$01,x
                    bne       L105A
                    puls      x
                    rts

L107C               lbsr      L1D87
                    lbsr      L12A9
                    lda       <u00A8
                    bmi       L109F
                    rola
                    bmi       L109A
                    ldd       >$09FF
                    std       >$0A01
                    ldd       >$0A5B
                    std       >$0A5D
                    ldd       #$3B15
                    bra       L10AA
L109A               ldd       #$3B42
                    bra       L10AA
L109F               rola
                    bmi       L10A7
                    ldd       #$3AE8
                    bra       L10AA
L10A7               ldd       #$3ABB
L10AA               std       <u009E
                    lda       <u00A3
                    lsla
                    lsla
                    lsla
                    lsla
                    sta       <u00C8
                    ldb       <u00A1
                    andb      #$0F
                    clra
                    tfr       d,x
                    ldy       #$0000
                    clr       >$05AC
L10C2               pshs      y
                    ldy       <u009E
                    ldb       >$05AC
                    lda       b,y
                    puls      y
                    sta       <u00C7
                    bpl       L10EF
                    lda       <u00C8
                    suba      #$10
                    sta       <u00C8
                    ldd       >$09FF,y
                    addd      <u00B4
                    std       >$0A01,y
                    ldd       >$0A5B,y
                    subd      <u00B6
                    std       >$0A5D,y
                    lbra      L114A
L10EF               rol       <u00C7
                    bpl       L110F
                    lda       <u00C8
                    adda      #$10
                    sta       <u00C8
                    ldd       >$09FF,y
                    subd      <u00B4
                    std       >$0A01,y
                    ldd       >$0A5B,y
                    addd      <u00B6
                    std       >$0A5D,y
                    bra       L114A
L110F               rol       <u00C7
                    bpl       L112C
                    leax      -$01,x
                    ldd       >$09FF,y
                    subd      <u00B6
                    std       >$0A01,y
                    ldd       >$0A5B,y
                    subd      <u00B4
                    std       >$0A5D,y
                    lbra      L1180
L112C               rol       <u00C7
                    lbpl      L1180
                    leax      $01,x
                    ldd       >$09FF,y
                    addd      <u00B6
                    std       >$0A01,y
                    ldd       >$0A5B,y
                    addd      <u00B4
                    std       >$0A5D,y
                    bra       L1180
L114A               rol       <u00C7
                    bpl       L1166
                    leax      -$01,x
                    ldd       >$0A01,y
                    subd      <u00B6
                    std       >$0A01,y
                    ldd       >$0A5D,y
                    subd      <u00B4
                    std       >$0A5D,y
                    bra       L1180
L1166               rol       <u00C7
                    bpl       L1180
                    leax      $01,x
                    ldd       >$0A01,y
                    addd      <u00B6
                    std       >$0A01,y
                    ldd       >$0A5D,y
                    addd      <u00B4
                    std       >$0A5D,y
L1180               clra
                    suba      <u00A6
                    sta       <u00C7
                    tfr       x,d
                    andb      #$0F
                    orb       <u00C8
                    lda       #$00
                    tfr       d,x
                    lda       >$01BC,x
                    ldu       #$0B11
                    ldb       >$05AC
                    sta       b,u
                    sbca      <u00A5
                    pshs      cc
                    ldb       <u00C7
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    puls      cc
                    bcc       L11AF
                    ora       #$F0
L11AF               std       >$0AB7,y
                    ldu       #$09D2
                    ldb       >$05AC
                    leau      b,u
                    tfr       x,d
                    stb       ,u
                    lda       >$0A5D,y
                    bmi       L120F
                    bne       L11CF
                    lda       >$0A5E,y
                    cmpa      #$20
                    bcs       L120F
L11CF               lda       >$0A01,y
                    bpl       L11F6
                    clra
                    suba      >$0A02,y
                    sta       <u00C7
                    lda       #$00
                    sbca      >$0A01,y
                    cmpa      >$0A5D,y
                    bcs       L120C
                    bne       L11F2
                    lda       <u00C7
                    cmpa      >$0A5E,y
                    bcs       L120C
L11F2               lda       #$40
                    bra       L1211
L11F6               cmpa      >$0A5D,y
                    bcs       L120C
                    bne       L1208
                    lda       >$0A02,y
                    cmpa      >$0A5E,y
                    bcs       L120C
L1208               lda       #$20
                    bra       L1211
L120C               clra
                    bra       L1211
L120F               lda       #$80
L1211               ldu       #$0BF7
                    ldb       >$05AC
                    sta       b,u
                    inc       >$05AC
                    leay      $02,y
                    cmpy      #$005A
                    lbne      L10C2
                    ldu       #$3B6F
                    ldy       #$0000
                    clr       >$05AC
L1230               clra
                    ldb       ,u
                    tfr       d,x
                    stb       >$093A
                    inc       >$05AC
                    leay      $02,y
                    leau      u0001,u
                    lda       >$0BF7,x
                    bmi       L126A
                    bne       L1299
                    clra
                    ldb       ,u
                    tfr       d,x
                    inc       >$05AC
                    leay      $02,y
                    leau      u0001,u
                    lda       >$0BF7,x
                    bpl       L12A0
                    clr       >$0BF7,x
                    clra
                    lslb
                    tfr       d,x
                    ldd       #$0020
                    std       >$0A5D,x
                    bra       L12A0
L126A               clra
                    ldb       ,u
                    tfr       d,x
                    inc       >$05AC
                    leay      $02,y
                    leau      u0001,u
                    lda       >$0BF7,x
                    bne       L12A0
                    pshs      y
                    clra
                    ldb       >$093A
                    lslb
                    tfr       d,y
                    ldd       #$0020
                    std       >$0A5D,y
                    ldy       #$0BF7
                    ldb       >$093A
                    clr       b,y
                    puls      y
                    bra       L12A0
L1299               inc       >$05AC
                    leau      u0001,u
                    leay      $02,y
L12A0               cmpy      #$0018
                    lbcs      L1230
                    rts

L12A9               ldd       <u00B4
                    std       <u00BE
                    lda       <u00A4
                    lbsr      L1015
                    ldd       <u00BC
                    std       >$09FF
                    ldd       <u00B6
                    std       <u00BE
                    lda       <u00A2
                    lbsr      L1015
                    ldd       >$09FF
                    subd      <u00BC
                    std       >$09FF
                    ldd       <u00B6
                    std       <u00BE
                    lda       <u00A4
                    lbsr      L1015
                    ldd       <u00BC
                    std       >$0A5B
                    ldd       <u00B4
                    std       <u00BE
                    lda       <u00A2
                    lbsr      L1015
                    ldd       <u00BC
                    addd      >$0A5B
                    std       >$0A5B
                    ldd       #$0000
                    subd      >$0A5B
                    std       >$0A5B
                    rts

L12F1               pshs      y
                    tfr       x,d
                    lslb
                    tfr       d,y
                    lda       >$0BF7,x
                    ora       #$10
                    sta       >$0BF7,x
                    clrb
                    lda       >$0A5E,y
                    sta       <u00C3
                    lda       >$0A5D,y
                    sta       <u00C2
                    lda       >$0A01,y
                    bmi       L131F
                    sta       <u00C4
                    lda       >$0A02,y
                    sta       <u00C5
                    bra       L132E
L131F               clra
                    suba      >$0A02,y
                    sta       <u00C5
                    lda       #$00
                    sbca      >$0A01,y
                    sta       <u00C4
L132E               lda       <u00C4
                    cmpa      <u00C2
                    bcs       L1365
                    bne       L133C
                    lda       <u00C5
                    cmpa      <u00C3
                    bcs       L1365
L133C               lsl       <u00C3
                    rol       <u00C2
                    incb
                    cmpb      #$08
                    bne       L132E
                    lda       >$0A01,y
                    bmi       L1358
                    lda       #$40
                    sta       >$0B3F,y
                    clr       >$0B40,y
                    lbra      L13DA
L1358               lda       #$C0
                    sta       >$0B3F,y
                    clr       >$0B40,y
                    lbra      L13DA
L1365               pshs      b
                    lbsr      L104E
                    puls      b
                    decb
                    bmi       L13AF
                    clra
L1370               lsl       <u00C6
                    rola
                    decb
                    bpl       L1370
                    sta       <u00C7
                    lsra
                    pshs      a
                    lda       <u00C6
                    rora
                    adda      <u00C6
                    sta       <u00C6
                    puls      a
                    adca      <u00C7
                    lsra
                    ror       <u00C6
                    lsra
                    ror       <u00C6
                    sta       <u00C7
                    lda       >$0A01,y
                    bmi       L13A1
                    lda       <u00C7
                    ldb       <u00C6
                    addd      #$0080
                    std       >$0B3F,y
                    bra       L13DA
L13A1               ldb       #$80
                    subb      <u00C6
                    lda       #$00
                    sbca      <u00C7
                    std       >$0B3F,y
                    bra       L13DA
L13AF               clr       >$0B3F,y
                    lda       >$0A01,y
                    bmi       L13CA
                    lda       <u00C6
                    lsra
                    orcc      #Carry              set carry flag
                    adca      <u00C6
                    rora
                    lsra
                    ora       #$80
                    sta       >$0B40,y
                    bra       L13DA
L13CA               lda       <u00C6
                    lsra
                    orcc      #Carry              set carry flag
                    adca      <u00C6
                    rora
                    lsra
                    coma
                    adda      #$81
                    sta       >$0B40,y
L13DA               clr       <u00B3
                    ldd       >$0A5D,y
                    std       <u00C2
                    lda       >$0AB7,y
                    bmi       L13F0
                    ldb       >$0AB8,y
                    std       <u00C4
                    bra       L13FF
L13F0               clra
                    suba      >$0AB8,y
                    sta       <u00C5
                    lda       #$00
                    sbca      >$0AB7,y
                    sta       <u00C4
L13FF               lda       <u00C4
                    cmpa      <u00C2
                    bcs       L1433
                    bne       L140D
                    lda       <u00C5
                    cmpa      <u00C3
                    bcs       L1433
L140D               lsl       <u00C3
                    rol       <u00C2
                    inc       <u00B3
                    ldb       <u00B3
                    cmpb      #$08
                    bne       L13FF
                    lda       >$0AB7,y
                    bmi       L1429
                    ldd       #$4000
                    std       >$0B9B,y
                    lbra      L14A8
L1429               ldd       #$C000
                    std       >$0B9B,y
                    lbra      L14A8
L1433               lbsr      L104E
                    dec       <u00B3
                    bmi       L147B
                    clra
L143B               lsl       <u00C6
                    rola
                    dec       <u00B3
                    bpl       L143B
                    sta       <u00C7
                    lsra
                    pshs      a
                    lda       <u00C6
                    rora
                    adda      <u00C6
                    sta       <u00C6
                    puls      a
                    adca      <u00C7
                    lsra
                    ror       <u00C6
                    lsra
                    ror       <u00C6
                    sta       <u00C7
                    lda       >$0AB7,y
                    bmi       L146D
                    lda       <u00C7
                    ldb       <u00C6
                    addd      #$0080
                    std       >$0B9B,y
                    bra       L14A8
L146D               ldb       #$80
                    subb      <u00C6
                    lda       #$00
                    sbca      <u00C7
                    std       >$0B9B,y
                    bra       L14A8
L147B               lda       #$00
                    sta       >$0B9B,y
                    lda       >$0AB7,y
                    bmi       L1498
                    lda       <u00C6
                    lsra
                    orcc      #Carry              set carry flag
                    adca      <u00C6
                    rora
                    lsra
                    adda      #$80
                    sta       >$0B9C,y
                    bra       L14A8
L1498               lda       <u00C6
                    lsra
                    orcc      #Carry              set carry flag
                    adca      <u00C6
                    rora
                    lsra
                    coma
                    adda      #$81
                    sta       >$0B9C,y
L14A8               lda       >$0B3F,y
                    bmi       L14DB
                    bne       L14E2
                    ldb       >$0B40,y
                    lsrb
                    lsrb
                    lsrb
                    clra
                    pshs      y
                    tfr       d,y
                    ldb       >$082B,y
                    puls      y
                    bmi       L14CF
L14C4               clra
                    addd      >$0B9B,y
                    std       >$0B9B,y
                    puls      pc,y
L14CF               lda       #$FF
                    addd      >$0B9B,y
                    std       >$0B9B,y
                    puls      pc,y
L14DB               ldb       >$082B
                    bmi       L14CF
                    bra       L14C4
L14E2               ldb       >$084A
                    bmi       L14CF
                    bra       L14C4
L14E9               clr       <u00DA
                    clr       <u00DB
                    clr       <u00DC
                    clr       <u00DE
                    ldd       >scrnaddr           screen address
                    addd      #$3C00
                    std       >$05A8
                    addd      #$0200
                    std       >$05AA
                    ldd       <u003E
                    std       >$097C
                    lbsr      L1DF4
                    lda       #$80
                    sta       >$0950
                    sta       >$0952
                    sta       >$098E
                    sta       >$0990
                    sta       >$0992
                    sta       >$0994
                    tst       <u00BB
                    bne       L1525
                    sta       >$0956
                    sta       <u0083
L1525               clr       >$095C
                    clr       >$096E
                    clr       >$0970
                    tst       <u0072
                    bmi       L1535
                    inc       >$0970
L1535               ldb       #$50
                    ldx       #$06CC
                    ldy       #$0000
L153E               sty       ,x++
                    decb
                    bne       L153E
                    sty       >$084C
L1548               ldb       >$3B6F,y
                    stb       >$093A
                    leay      $01,y
                    clra
                    tfr       d,x
                    lda       >$0BF7,x
                    lbmi      L15EF
                    anda      #$20
                    lbne      L15EF
                    leay      $01,y
                    sty       >$084C
                    ldb       >$3B6E,y
                    clra
                    tfr       d,x
                    lda       >$0BF7,x
                    bmi       L15F1
                    anda      #$40
                    bne       L15F1
                    lda       >$0BF7,x
                    anda      #$10
                    bne       L158B
                    pshs      x
                    lbsr      L12F1
                    lbsr      L17BF
                    puls      x
L158B               lda       >$0B11,x
                    sta       >$0C9D
                    tfr       x,d
                    lslb
                    tfr       d,x
                    ldd       >$0B3F,x
                    std       >$0C25
                    ldd       >$0B9B,x
                    std       >$0C61
                    ldb       >$093A
                    clra
                    tfr       d,x
                    lda       >$0BF7,x
                    anda      #$10
                    bne       L15BD
                    pshs      x
                    lbsr      L12F1
                    lbsr      L17BF
                    puls      x
L15BD               lda       >$0B11,x
                    sta       <u00A0
                    tfr       x,d
                    lslb
                    tfr       d,x
                    ldd       >$0B3F,x
                    std       >$054B
                    ldd       >$0B9B,x
                    std       >$054D
                    ldx       #$0000
                    lbsr      L1E2C
                    inc       >$0179
                    lda       >$0179
                    anda      #$03
                    bne       L15E9
                    lbsr      L089D
L15E9               ldy       >$084C
                    bra       L15F1
L15EF               leay      $01,y
L15F1               sty       >$084C
                    cmpy      #$0090
                    lbne      L1548
                    lbsr      L2361
                    lbsr      L089D
                    lda       >$0950
                    sta       >$0938
                    lda       >$0952
                    sta       >$0939
                    lda       <u0083
                    bpl       L1618
                    clr       >$010B
                    bra       L162E
L1618               lsra
                    lsra
                    inca
                    cmpa      #$0A
                    bcs       L1621
                    lda       #$09
L1621               sta       >$010B
                    cmpa      >$08A5
                    beq       L162E
                    sta       >$08A5
                    bcc       L162E
L162E               lda       >$098E
                    asra
                    adda      #$80
                    sta       >$08AC
                    lda       >$0990
                    asra
                    asra
                    adda      #$0F
                    sta       >$08AB
                    lda       >$0992
                    sta       >$0996
                    lda       >$098A
                    sta       >$089E
                    lda       >$098C
                    sta       >$08A0
                    tst       <u0085
                    beq       L165A
                    lbsr      L1CFA
L165A               lda       >$0970
                    beq       L1661
                    lda       #$74
L1661               sta       >$08A6
                    ldd       >$09CC
                    std       >$0972
                    ldd       >$09CE
                    std       >$0974
                    ldd       >$09D0
                    std       >$0976
                    ldd       >$0869
                    std       >$0978
                    ldd       >$086B
                    std       >$097A
                    ldd       >$097C
                    std       >$097E
                    ldy       #$0020
L168C               lda       >$083B
                    suba      >$082A,y
                    asra
                    adca      #$00
                    sta       >$08CE,y
                    leay      -$01,y
                    bne       L168C
                    tst       >$096E
                    bne       L16A9
                    orcc      #Carry              set carry flag
                    lda       <u00EC
                    bra       L16DF
L16A9               tst       <u004E
                    beq       L16B0
                    clra
                    bra       L16DD
L16B0               ldd       <u0039
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    sta       <u00D2
                    ldd       >$099C
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    suba      <u00D2
                    bpl       L16C8
                    nega
L16C8               sta       <u00D2
                    lda       >$0902
                    asra
                    asra
                    sta       <u00D3
                    lda       >$09A0
                    asra
                    asra
                    suba      <u00D3
                    bpl       L16DB
                    nega
L16DB               adda      <u00D2
L16DD               andcc     #^Carry             clear carry flag
L16DF               adca      <u0060
                    bpl       L16E5
                    lda       #$7F
L16E5               suba      <u00EC
                    bcc       L16EA
                    clra
L16EA               sta       <u0060
                    ldb       <u0084
                    cmpa      #$20
                    bcs       L16F9
                    tstb
                    bmi       L16FE
                    ldb       #$80
                    bra       L16FE
L16F9               cmpb      #$80
                    bne       L16FE
                    clrb
L16FE               stb       <u0084
                    tst       <u0052
                    beq       L1718
                    lda       <u007A
                    suba      #$06
                    bcs       L1718
                    pshs      a
                    lbsr      L56E2
                    puls      a
                    cmpa      <u0032
                    bcs       L1718
                    lbsr      L085E
L1718               tst       >$08A9
                    beq       L1739
                    ldx       #$0000
                    clr       >$08A9
                    lda       #$F9
L1725               cmpa      >$02BC,x
                    bcc       L1732
                    inc       >$02BC,x
                    inc       >$08A9
L1732               leax      $01,x
                    cmpx      #$0100
                    bne       L1725
L1739               tst       <u0071
                    bpl       L179A
                    tst       <u004E
                    bne       L179A
                    lda       <u00EF
                    beq       L179A
                    dec       <u00F0
                    bne       L179A
                    sta       <u00F0
                    lbsr      L56E2
                    cmpa      #$80
                    bcc       L179A
                    adda      #$4A
                    tfr       a,b
                    clra
                    tfr       d,x
                    lbsr      L56E2
                    anda      #$1F
                    adda      #$6E
                    cmpa      >$0682,x
                    bls       L179A
                    sta       >$088B
                    lda       #$80
                    suba      >$088B
                    lsla
                    adda      #$2C
                    sta       >$088B
                    tfr       x,d
                    subb      #$10
                    stb       >$0888
                    clr       >$0887
                    clr       >$088A
                    clr       >$088E
                    clr       >$0893
                    lbsr      L179B
                    lda       #$7F
                    sta       <u0072
                    sta       <u0071
                    lda       #$01
                    sta       >$0CEC
                    lda       <u0047
                    sta       >$0895
L179A               rts

L179B               lbsr      L56E2
                    sta       >$088F
                    lda       #$00
                    rola
                    ldb       >$0888
                    cmpb      #$50
                    bcc       L17AC
                    coma
L17AC               sta       >$088E
                    clrb
                    lbsr      L56E2
                    suba      #$80
                    bcc       L17B8
                    decb
L17B8               stb       >$0893
                    sta       >$0894
L17BE               rts

L17BF               tfr       x,d
                    lslb
                    tfr       d,u
                    ldb       >$09D2,x
                    clra
                    tfr       d,y
                    tst       >$02BC,y
                    beq       L17BE
                    tst       >u0A5D,u
                    bne       L17DF
                    lda       >u0A5E,u
                    cmpa      #$22
                    bcs       L17BE
L17DF               tfr       x,d
                    stb       >$0944
                    lda       >$01BC,y
                    lbmi      L18B0
                    lda       <u00BB
                    lbne      L19AC
                    lda       >$02BC,y
                    cmpa      #$02
                    lbcs      L19AC
                    cmpa      #$F8
                    lbcc      L19AC
                    lda       >u0A01,u
                    sta       <u006A
                    sta       <u006B
                    lsla
                    bcc       L1815
                    lda       #$FF
                    suba      <u006B
                    sta       <u006B
                    orcc      #Carry              set carry flag
L1815               ror       <u006A
                    bcc       L181B
                    inc       <u006A
L181B               lda       >u0A5D,u
                    sta       >$094A
                    cmpa      <u006B
                    lbcs      L19AC
                    adda      <u006B
                    cmpa      >$0956
                    lbcc      L19AC
                    sta       >$0956
                    lsr       <u006B
                    suba      <u006B
                    sta       <u0083
                    lda       <u006A
                    sta       >$0950
                    lda       >$094A
                    sta       >$0952
                    lda       >$09D2,x
                    sta       >$094E
                    lda       #$64
                    sta       <u0051
                    lda       >u0B3F,u
                    lbne      L18AE
                    lda       >u0B9B,u
                    lbne      L18AE
                    lda       >u0B40,u
                    sta       <u0050
                    lda       >u0B9C,u
                    sta       <u0051
                    sta       <u0086
                    tfr       x,d
                    stb       <u0087
                    lbra      L19AC
L1875               cmpy      #$0050
                    bcs       L18AE
                    cmpy      #$00AF
                    bcc       L18AE
                    tfr       y,d
                    subb      #$50
                    ldu       #$0E83
                    clra
                    lslb
                    rola
                    ldu       d,u
                    tfr       x,d
                    subb      #$30
                    bcs       L18AE
                    cmpb      #$A0
                    bcc       L18AE
                    lda       #$F0
                    lsrb
                    leau      b,u
                    bcc       L189F
                    coma
L189F               sta       <u00AB
                    anda      <u0069
                    pshs      a
                    lda       <u00AB
                    coma
                    anda      ,u
                    ora       ,s+
                    sta       ,u
L18AE               rts

L18AF               rts

L18B0               lda       >u0B9B,u
                    bne       L18AF
                    lda       >u0B3F,u
                    bne       L18AF
                    ldd       #$1427
                    std       >$093C
                    lda       #$66
                    sta       <u0069
                    ldd       >u0A5D,u
                    std       <u0063
                    clra
                    ldb       >u0B9C,u
                    stb       <u0062
                    tfr       d,y
                    ldb       >u0B40,u
                    stb       <u0061
                    ldb       >$09D2,x
                    tfr       d,x
                    lda       >$02BC,x
                    cmpa      #$FA
                    bcs       L18EF
                    lbsr      L1C4A
                    lbra      L194D
L18EF               clra
                    ldb       <u0061
                    tfr       d,x
                    subb      #$30
                    bcs       L1946
                    cmpb      #$A0
                    bcc       L1946
                    tfr       y,d
                    subb      #$50
                    bcs       L1946
                    cmpb      >$069C,x
                    bcs       L1946
                    lda       #$80
                    lbsr      L1959
                    leax      -$01,x
                    lbsr      L1A6A
                    leax      $01,x
                    lda       <u0047
                    cmpa      #$37
                    bhi       L194D
                    lda       #$01
                    sta       >$0970
                    sta       >$096E
                    lda       <u0072
                    bpl       L194D
                    lda       <u004F
                    bne       L194D
                    lbsr      L56E2
                    bpl       L194D
                    lda       >$095C
                    bne       L194D
                    tfr       x,d
                    stb       >$0958
                    tfr       y,d
                    stb       >$095A
                    lda       <u0063
                    sta       >$095C
                    lbra      L194D
L1946               ldb       >$0944
                    clra
                    tfr       d,x
                    rts

L194D               lda       <u0063
                    cmpa      #$0D
                    bcc       L1946
                    clr       >$0940
                    lbra      L1D50
L1959               sta       >$0986
                    lda       <u0061
                    suba      #$80
                    sta       >$0980
                    bpl       L1969
                    clra
                    suba      >$0980
L1969               sta       >$0984
                    lda       #$80
                    suba      <u0062
                    sta       >$0982
                    bpl       L1979
                    clra
                    suba      >$0982
L1979               adda      >$0984
                    bcs       L19AB
                    sta       >$0984
                    adda      <u0063
                    bcs       L19AB
                    cmpa      >$0994
                    bcc       L19AB
                    sta       >$0994
                    lda       >$0984
                    sta       >$0992
                    lda       >$0980
                    sta       >$098E
                    lda       >$0982
                    sta       >$0990
                    lda       >$0986
                    sta       >$098A
                    lda       >$0988
                    sta       >$098C
L19AB               rts

L19AC               lda       >u0B9B,u
                    bne       L19AB
                    lda       >u0B3F,u
                    bne       L19AB
                    ldd       #$151F
                    std       >$093C
                    lda       >$0B11,x
                    anda      #$01
                    sta       >$0988
                    sta       >$0940
                    lda       >u0B40,u
                    sta       <u0061
                    lda       >u0B9C,u
                    sta       <u0062
                    ldd       >u0A5D,u
                    std       <u0063
                    lda       #$77
                    sta       <u0069
                    clra
                    ldb       >$09D2,x
                    tfr       d,y
                    lda       >$02BC,y
                    cmpa      #$FA
                    bcs       L19F2
                    lbsr      L1C4A
L19F2               clra
                    ldb       <u0061
                    subb      #$30
                    bcs       L1A18
                    cmpb      #$A0
                    bcc       L1A18
                    tfr       d,y
                    lda       <u0062
                    suba      #$50
                    bcs       L1A18
                    cmpa      >$06CC,y
                    bcs       L1A18
                    clra
                    lbsr      L1959
                    lda       <u0063
                    cmpa      #$0D
                    bcc       L1A18
                    lbsr      L1D50
L1A18               lda       <u00BB
                    bne       L1A63
                    lda       <u004F
                    bne       L1A63
                    lda       >$010C
                    cmpa      #$01
                    bne       L1A63
                    clra
                    ldb       >$09D2,x
                    tfr       d,y
                    lda       >$02BC,y
                    cmpa      #$02
                    bcs       L1A63
                    cmpa      #$F8
                    bcc       L1A63
                    lda       #$11
                    sta       <u0069
                    clra
                    ldb       >u0B9C,u
                    tfr       d,y
                    ldb       >u0B40,u
                    tfr       d,x
                    lbsr      L1A6A
                    leax      -$01,x
                    leay      -$01,y
                    lbsr      L1A6A
                    leax      -$01,x
                    leay      $01,y
                    lbsr      L1A6A
                    leax      $01,x
                    leay      $01,y
                    lbsr      L1A6A
L1A63               ldb       >$0944
                    clra
                    tfr       d,x
                    rts

L1A6A               cmpx      #$0030
                    bcs       L1AA5
                    cmpx      #$00D0
                    bcc       L1AA5
                    tfr       y,d
                    subb      #$50
                    bcs       L1AA5
                    cmpb      #$5F
                    bcc       L1AA5
                    cmpb      >$069C,x
                    bls       L1AA5
                    pshs      y
                    pshs      b
                    clra
                    ldb       <u00DC
                    tfr       d,y
                    puls      b
                    stb       >$03BC,y
                    tfr       x,d
                    subb      #$30
                    stb       >$03DC,y
                    lda       <u0069
                    sta       >$03FC,y
                    inc       <u00DC
                    puls      y
L1AA5               rts

L1AA6               dec       >$095E
                    bpl       L1AC1
                    lbsr      L56E2
                    anda      <u00F2
                    sta       >$095E
                    lda       >$0886
                    bne       L1ABB
                    lbsr      L524C
L1ABB               clr       <u0052
                    clr       >$095C
L1AC0               rts

L1AC1               bne       L1AC0
                    lda       >$095C
                    beq       L1AC0
                    lda       >$0958
                    sta       >$0960
                    lda       >$095A
                    sta       >$0962
                    lda       #$01
                    sta       >$0964
                    lda       #$80
                    sta       >$0961
                    sta       >$0963
                    sta       >$0965
                    clr       <u006C
                    clr       >$0968
                    lbsr      L56E2
                    lsla
                    sta       <u006D
                    bcc       L1AF3
                    dec       <u006C
L1AF3               lda       >$099C
                    bpl       L1B00
                    cmpa      #$FF
                    bcc       L1B08
                    clr       <u006C
                    bra       L1B08
L1B00               cmpa      #$02
                    bcs       L1B08
                    lda       #$FF
                    sta       <u006C
L1B08               lbsr      L56E2
                    lsla
                    sta       >$0969
                    dec       >$0968
                    lda       <u0084
                    cmpa      #$07
                    beq       L1B2D
                    lda       <u0060
                    coma
                    lsra
                    lsra
                    lsra
                    adda      #$0C
                    sta       >$096B
                    lda       #$55
                    sta       <u0069
                    lbsr      L1B90
                    inc       <u0052
                    rts

L1B2D               lda       #$66
                    sta       <u0057
                    clr       <u006C
                    lda       #$67
                    suba      >$0958
                    lsla
                    sta       <u006D
                    bcc       L1B3F
                    dec       <u006C
L1B3F               lda       #$32
                    suba      >$095A
                    sta       >$096B
                    lda       #$66
                    sta       <u0069
                    lbsr      L1B95
                    lda       #$12
                    sta       >$0601
                    lda       #$10
                    sta       <u004C
                    inc       <u0052
L1B59               ldb       <u003E
                    cmpb      <u003B
                    beq       L1B65
                    decb
                    cmpb      <u003B
                    beq       L1B65
                    decb
L1B65               stb       <u003E
                    ldb       <u0039
                    lbsr      L56E2
                    bpl       L1B7A
                    cmpb      #$FB
                    beq       L1B84
                    decb
                    cmpb      #$FB
                    beq       L1B84
                    decb
                    bra       L1B84
L1B7A               cmpb      #$05
                    beq       L1B84
                    incb
                    cmpb      #$05
                    beq       L1B84
                    incb
L1B84               stb       <u0039
                    lda       <u0041
                    suba      #$08
                    bcc       L1B8D
                    clra
L1B8D               sta       <u0041
                    rts

L1B90               lbsr      L56E2
                    bmi       L1BEF
L1B95               ldd       <u006C
                    subd      #$0040
                    std       <u006C
                    clra
                    ldb       >$0960
                    tfr       d,x
                    ldb       >$0962
                    tfr       d,y
                    cmpy      #$0060
                    bcs       L1BEC
L1BAD               lda       >$0964
                    sta       >$096C
L1BB3               cmpx      #$0030
                    bcs       L1BC0
                    cmpx      #$00D0
                    bcc       L1BC0
                    lbsr      L1875
L1BC0               leax      $01,x
                    dec       >$096C
                    bne       L1BB3
                    ldd       >$0964
                    addd      >$096A
                    std       >$0964
                    ldd       >$0960
                    addd      <u006C
                    std       >$0960
                    tfr       a,b
                    clra
                    tfr       d,x
                    lbsr      L56E2
                    anda      #$03
                    bne       L1BE4
L1BE4               leay      -$01,y
                    cmpy      #$0050
                    bcc       L1BAD
L1BEC               lbra      L35EF
L1BEF               clra
                    ldb       >$0960
                    tfr       d,x
                    ldb       >$0962
                    tfr       d,y
L1BFA               cmpx      #$0030
                    bcs       L1BEC
                    cmpx      #$00D0
                    bcc       L1BEC
                    cmpy      #$0050
                    bcs       L1BEC
                    lda       >$0964
                    sta       >$096C
L1C10               lbsr      L1875
                    leay      -$01,y
                    cmpy      #$0050
                    bcs       L1C20
                    dec       >$096C
                    bne       L1C10
L1C20               ldd       >$096A
                    addd      >$0964
                    std       >$0964
                    ldd       >$0962
                    addd      >$0968
                    std       >$0962
                    tfr       a,b
                    clra
                    tfr       d,y
                    lbsr      L56E2
                    anda      #$03
                    bne       L1C3E
L1C3E               lda       <u006C
                    bmi       L1C46
                    leax      $01,x
                    bra       L1BFA
L1C46               leax      -$01,x
                    bra       L1BFA
L1C4A               tfr       a,b
                    andb      #$03
                    pshs      b
                    clra
                    lslb
                    tfr       d,x
                    ldd       >$1517,x
                    std       >$093C
                    lda       ,s+
                    bne       L1C66
                    clr       <u0069
                    lda       #$11
                    sta       >$0601
L1C66               lsr       <u0063
                    ror       <u0064
                    lsr       <u0063
                    ror       <u0064
                    lda       #$77
                    sta       <u0057
                    rts

L1C73               tst       <u0063
                    bne       L1C7B
                    clr       <u0064
                    inc       <u0063
L1C7B               ldd       #$1000
L1C7E               dec       <u0061
                    subd      <u0063
                    bcc       L1C7E
                    lda       <u0061
                    sta       >$093E
                    clr       <u0067
                    clr       <u0068
L1C8D               clr       <u0065
                    clr       <u0066
                    clra
                    ldb       <u0067
                    lslb
                    rola
                    lslb
                    rola
                    addd      >$093C
                    std       <u00D2
                    lda       >$093E
                    sta       <u0061
L1CA2               ldb       <u0065
                    tst       >$0940
                    beq       L1CAD
                    ldb       #$1F
                    subb      <u0065
L1CAD               clra
                    tfr       d,x
                    lsrb
                    lsrb
                    lsrb
                    tfr       d,y
                    tfr       x,d
                    andb      #$07
                    tfr       d,x
                    tfr       y,d
                    ldy       <u00D2
                    lda       b,y
                    anda      >$3C37,x
                    beq       L1CD9
                    clra
                    ldb       <u0061
                    tfr       d,x
                    ldb       <u0062
                    tfr       d,y
                    lbsr      L1875
                    leay      $01,y
                    lbsr      L1875
L1CD9               inc       <u0061
                    ldd       <u0065
                    addd      <u0063
                    std       <u0065
                    cmpa      #$20
                    bcs       L1CA2
                    dec       <u0062
                    dec       <u0062
                    ldd       <u0067
                    addd      <u0063
                    std       <u0067
                    cmpa      #$0C
                    bcs       L1C8D
                    ldb       >$0944
                    clra
                    tfr       d,x
                    rts

L1CFA               tst       <u0049
                    bne       L1D4F
                    tst       <u005C
                    beq       L1D4F
                    lda       <u0071
                    bpl       L1D24
                    lda       >$098E
                    cmpa      #$0C
                    bcs       L1D11
                    cmpa      #$F5
                    bcs       L1D4C
L1D11               lda       >$0990
                    cmpa      #$0C
                    bcs       L1D1C
                    cmpa      #$F5
                    bcs       L1D4C
L1D1C               clra
                    ldb       >$098A
                    tfr       d,x
                    bra       L1D3D
L1D24               lda       >$0888
                    cmpa      #$48
                    bcs       L1D4C
                    cmpa      #$98
                    bcc       L1D4C
                    lda       >$088B
                    cmpa      #$24
                    bcs       L1D4C
                    cmpa      #$60
                    bcc       L1D4C
                    ldx       #$0001
L1D3D               inc       >$089C
                    lda       >$089C
                    cmpa      #$02
                    bcs       L1D4F
                    tfr       x,d
                    stb       >$089D
L1D4C               clr       >$089C
L1D4F               rts

L1D50               clra
                    ldb       <u00DE
                    tfr       d,y
                    lslb
                    tfr       d,x
                    lda       <u0062
                    sta       >$041C,y
                    lda       <u0061
                    sta       >$043C,y
                    ldd       <u0063
                    std       >$045C,x
                    lda       <u0069
                    sta       >$049C,y
                    ldd       >$093C
                    std       >$04BC,x
                    lda       >$0940
                    sta       >$04FC,y
                    inc       <u00DE
                    ldb       >$0944
                    clra
                    tfr       d,x
                    rts

L1D87               ldd       >$090B
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       <u00A1
                    ldd       >$090D
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       <u00A3
                    ldd       <u0047
                    cmpa      #$40
                    bcs       L1DAD
                    orcc      #Carry              set carry flag
                    lda       #$FF
                    bra       L1DB1
L1DAD               lslb
                    rola
                    rolb
                    rola
L1DB1               std       <u00A5
                    lda       >$0909
                    rola
                    rola
                    sta       <u00A8
                    lbsr      L0F51
                    ldd       >$0869
                    std       <u00B4
                    ldd       >$086B
                    std       <u00B6
                    lda       <u003E
                    sta       <u00BA
                    lda       <u003F
                    rola
                    rol       <u00BA
                    rola
                    rol       <u00BA
                    lda       #$06
                    suba      <u00BA
                    sta       <u00BA
                    ldd       <u0037
                    pshs      a
                    asra
                    rorb
                    std       <u00B8
                    puls      a
                    adda      #$04
                    bpl       L1DEA
                    clra
                    bra       L1DF0
L1DEA               cmpa      #$09
                    bcs       L1DF0
                    lda       #$08
L1DF0               sta       >$0882
                    rts

L1DF4               lda       <u00BA
                    sta       >$083B
                    ldx       #$0001
                    clr       <u00C7
L1DFE               lda       <u00C7
                    adda      <u00B9
                    sta       <u00C7
                    lda       >$083A,x
                    adca      <u00B8
                    sta       >$083B,x
                    leax      $01,x
                    cmpx      #$0010
                    bne       L1DFE
                    clr       <u00C7
L1E17               lda       <u00C7
                    suba      <u00B9
                    sta       <u00C7
                    lda       >$082B,x
                    sbca      <u00B8
                    sta       >$082A,x
                    leax      -$01,x
                    bne       L1E17
                    rts

L1E2C               stx       <u0004
                    lda       >$0C25
                    eora      #$80
                    sta       <u00C7
                    lda       >$054B
                    eora      #$80
                    cmpa      <u00C7
                    bne       L1E44
                    lda       >$054C
                    cmpa      >$0C26
L1E44               bcc       L1EA8
                    ldd       >$0C25
                    std       >$0C5F
                    ldd       >$0C61
                    std       >$0C9B
                    lda       >$0C9D
                    sta       >$0CBA
                    lda       #$14
                    sta       >$084B
                    ldd       #$0000
                    subd      <u0004
                    std       <u0000
                    addd      #$0CBA
                    tfr       d,u
                    ldd       <u0000
                    subd      <u0004
                    std       <u0000
                    addd      #$0C9B
                    tfr       d,y
                    ldd       <u0000
                    addd      #$0C5F
                    tfr       d,x
L1E7B               lda       >$054B
                    bpl       L1EBD
                    dec       >$084B
                    bmi       L1EA8
                    lbsr      L1F8E
                    ldd       >$054F
                    bmi       L1EAB
                    tsta
                    bne       L1E94
                    cmpb      #$30
                    bcs       L1EAB
L1E94               std       ,--x
                    ldd       >$0551
                    std       ,--y
                    lda       <u00A7
                    sta       ,-u
                    lda       <u0005
                    inca
                    sta       <u0005
                    cmpa      #$0F
                    bcs       L1E7B
L1EA8               ldx       <u0004
                    rts

L1EAB               ldd       >$054F
                    std       >$054B
                    ldd       >$0551
                    std       >$054D
                    lda       <u00A7
                    sta       <u00A0
                    bra       L1E7B
L1EBD               ldd       >$054B
                    tsta
                    bne       L1EA8
                    cmpb      #$D0
                    bcc       L1EA8
L1EC7               lda       ,x
                    beq       L1EEF
L1ECB               dec       >$084B
                    bmi       L1EEC
                    lbsr      L1F8E
                    ldd       >$054F
                    std       ,--x
                    ldd       >$0551
                    std       ,--y
                    lda       <u00A7
                    sta       ,-u
                    lda       <u0005
                    inca
                    sta       <u0005
                    cmpa      #$0F
                    bcc       L1EEC
                    bra       L1EC7
L1EEC               ldx       <u0004
                    rts

L1EEF               lda       >$054D
                    bmi       L1EFD
                    bne       L1F0B
                    lda       >$054E
                    cmpa      #$50
                    bcc       L1F0B
L1EFD               lda       ,y
                    bmi       L1F19
                    bne       L1F1C
                    lda       $01,y
                    cmpa      #$50
                    bcs       L1F19
                    bra       L1F1C
L1F0B               lda       ,y
                    bmi       L1F30
                    bne       L1F44
                    lda       $01,y
                    cmpa      #$50
                    bcs       L1F30
                    bra       L1F44
L1F19               lbra      L1F73
L1F1C               ldb       $01,x
                    subb      >$054C
                    cmpb      #$14
                    bcs       L1F44
                    lsrb
                    lsrb
                    negb
                    sex
                    addd      >$054D
                    bpl       L1F44
                    bra       L1ECB
L1F30               ldb       $01,x
                    subb      >$054C
                    cmpb      #$14
                    bcs       L1F44
                    lsrb
                    lsrb
                    negb
                    sex
                    addd      ,y
                    bpl       L1F44
                    lbra      L1ECB
L1F44               lda       >$054D
                    beq       L1F53
                    bmi       L1F4F
                    lda       #$FF
                    bra       L1F50
L1F4F               clra
L1F50               sta       >$054E
L1F53               ldd       ,y
                    tsta
                    beq       L1F61
                    bmi       L1F5E
                    lda       #$FF
                    bra       L1F63
L1F5E               clra
                    bra       L1F63
L1F61               tfr       b,a
L1F63               sta       >$0186
                    ldb       $01,x
                    stb       >$017C
                    lda       ,u
                    sta       >$0190
                    lbsr      L1FD0
L1F73               tst       <u0005
                    beq       L1F8A
                    ldd       ,x++
                    std       >$054B
                    ldd       ,y++
                    std       >$054D
                    lda       ,u+
                    sta       <u00A0
                    dec       <u0005
                    lbra      L1EBD
L1F8A               ldx       #$0000
                    rts

L1F8E               ldd       >$054B
                    addd      ,x
                    asra
                    rorb
                    std       >$054F
                    ldd       >$054D
                    addd      ,y
                    asra
                    rorb
                    std       >$0551
                    lda       <u00A0
                    inca
                    adda      ,u
                    sta       <u00A7
                    bmi       L1FAC
                    rts

L1FAC               bcs       L1FC1
                    ldd       >$054F
                    subd      >$054B
                    asra
                    rorb
                    pshs      b,a
                    ldd       >$0551
                    subd      ,s++
                    std       >$0551
                    rts

L1FC1               ldd       >$054F
                    subd      >$054B
                    asra
                    rorb
                    addd      >$0551
                    std       >$0551
                    rts

L1FD0               lda       >$017C
                    cmpa      #$30
                    bls       L2032
                    cmpa      >$054C
                    bcs       L2032
                    bne       L2033
                    clra
                    ldb       >$017C
                    subb      #$30
                    std       >$0553
                    lda       >$0186
                    suba      #$50
                    bcs       L2032
                    pshs      x,b
                    ldx       >$0553
                    leax      >$06CC,x
                    cmpa      ,x
                    bls       L2030
                    cmpa      #$5F
                    bls       L2001
                    lda       #$5F
L2001               ldb       ,x
                    sta       ,x
                    tstb
                    beq       L2030
                    lda       >$0554
                    anda      #$01
                    bne       L2030
                    ldx       >$05AA
                    stb       ,x+
                    stx       >$05AA
                    lda       >$0554
                    ldx       >$05A8
                    sta       ,x+
                    stx       >$05A8
                    inc       <u00DB
                    bne       L2030
                    lda       <u00DA
                    beq       L202E
                    dec       <u00DB
                    bra       L2030
L202E               inc       <u00DA
L2030               puls      x,b
L2032               rts

L2033               ldd       <u0004
                    std       <u0000
                    pshs      u,y,x
                    ldx       #$017C
                    ldy       #$0186
                    ldu       #$0190
                    clrb
L2044               lda       >$054C
                    cmpa      #$30
                    bcs       L2062
                    sta       <u0001
                    suba      #$30
                    sta       >$0554
                    clr       >$0553
                    ldx       #$017C
                    ldy       #$0186
                    ldu       #$0190
                    lbra      L2106
L2062               adda      ,x
                    rora
                    cmpa      #$30
                    bhi       L20B4
                    sta       >$054C
                    orcc      #Carry              set carry flag
                    lda       <u00A0
                    adda      ,u
                    sta       <u00A0
                    bmi       L2081
                    lda       >$054E
                    adda      ,y
                    rora
                    sta       >$054E
                    bra       L2044
L2081               bcs       L209B
                    lda       ,x
                    suba      >$054C
                    lsra
                    sta       <u00C7
                    lda       >$054E
                    adda      ,y
                    rora
                    suba      <u00C7
                    bcc       L2096
                    clra
L2096               sta       >$054E
                    bra       L2044
L209B               lda       ,x
                    suba      >$054C
                    lsra
                    sta       <u00C7
                    lda       >$054E
                    adda      ,y
                    rora
                    adda      <u00C7
                    bcc       L20AF
                    lda       #$FF
L20AF               sta       >$054E
                    bra       L2044
L20B4               leax      $01,x
                    sta       ,x
                    orcc      #Carry              set carry flag
                    lda       <u00A0
                    adda      ,u+
                    sta       ,u
                    bmi       L20CE
                    lda       >$054E
                    adda      ,y+
                    rora
                    sta       ,y
                    incb
                    lbra      L2044
L20CE               bcs       L20E9
                    lda       ,x
                    suba      >$054C
                    lsra
                    sta       <u00C7
                    lda       >$054E
                    adda      ,y+
                    rora
                    suba      <u00C7
                    bcc       L20E3
                    clra
L20E3               sta       ,y
                    incb
                    lbra      L2044
L20E9               lda       ,x
                    suba      >$054C
                    lsra
                    sta       <u00C7
                    lda       >$054E
                    adda      ,y+
                    rora
                    adda      <u00C7
                    bcc       L20FD
                    lda       #$FF
L20FD               sta       ,y
                    incb
                    lbra      L2044
L2103               puls      u,y,x
                    rts

L2106               lda       <u0001
                    cmpa      #$D0
                    bcc       L2103
                    sta       >$054C
                    suba      b,x
                    cmpa      #$FE
                    lbne      L21CD
                    lda       b,y
                    adda      >$054E
                    rora
                    suba      #$50
                    bcs       L2165
                    pshs      x,b
                    ldx       >$0553
                    leax      >$06CC,x
                    cmpa      ,x
                    bls       L2163
                    cmpa      #$5F
                    bls       L2134
                    lda       #$5F
L2134               ldb       ,x
                    sta       ,x
                    tstb
                    beq       L2163
                    lda       >$0554
                    anda      #$01
                    bne       L2163
                    ldx       >$05AA
                    stb       ,x+
                    stx       >$05AA
                    lda       >$0554
                    ldx       >$05A8
                    sta       ,x+
                    stx       >$05A8
                    inc       <u00DB
                    bne       L2163
                    lda       <u00DA
                    beq       L2161
                    dec       <u00DB
                    bra       L2163
L2161               inc       <u00DA
L2163               puls      x,b
L2165               inc       >$0554
                    lda       b,y
                    sta       >$054E
                    suba      #$50
                    bcs       L21B5
                    pshs      x,b
                    ldx       >$0553
                    leax      >$06CC,x
                    cmpa      ,x
                    bls       L21B3
                    cmpa      #$5F
                    bls       L2184
                    lda       #$5F
L2184               ldb       ,x
                    sta       ,x
                    tstb
                    beq       L21B3
                    lda       >$0554
                    anda      #$01
                    bne       L21B3
                    ldx       >$05AA
                    stb       ,x+
                    stx       >$05AA
                    lda       >$0554
                    ldx       >$05A8
                    sta       ,x+
                    stx       >$05A8
                    inc       <u00DB
                    bne       L21B3
                    lda       <u00DA
                    beq       L21B1
                    dec       <u00DB
                    bra       L21B3
L21B1               inc       <u00DA
L21B3               puls      x,b
L21B5               decb
                    bmi       L21CA
                    lda       <u0001
                    adda      #$02
                    sta       <u0001
                    inc       >$0554
                    incb
                    lda       b,u
                    decb
                    sta       <u00A0
                    lbra      L2106
L21CA               puls      u,y,x
                    rts

L21CD               lbcs      L2231
                    lda       b,y
                    sta       >$054E
                    suba      #$50
                    bcs       L221E
                    pshs      x,b
                    ldx       >$0553
                    leax      >$06CC,x
                    cmpa      ,x
                    bls       L221C
                    cmpa      #$5F
                    bls       L21ED
                    lda       #$5F
L21ED               ldb       ,x
                    sta       ,x
                    tstb
                    beq       L221C
                    lda       >$0554
                    anda      #$01
                    bne       L221C
                    ldx       >$05AA
                    stb       ,x+
                    stx       >$05AA
                    lda       >$0554
                    ldx       >$05A8
                    sta       ,x+
                    stx       >$05A8
                    inc       <u00DB
                    bne       L221C
                    lda       <u00DA
                    beq       L221A
                    dec       <u00DB
                    bra       L221C
L221A               inc       <u00DA
L221C               puls      x,b
L221E               inc       >$0554
                    decb
                    bpl       L2226
                    puls      pc,u,y,x
L2226               inc       <u0001
                    incb
                    lda       b,u
                    decb
                    sta       <u00A0
                    lbra      L2106
L2231               lda       <u0001
                    adda      b,x
                    rora
                    incb
                    sta       b,x
                    decb
                    orcc      #Carry              set carry flag
                    lda       <u00A0
                    adda      b,u
                    incb
                    sta       b,u
                    bmi       L2252
                    decb
                    lda       >$054E
                    adda      b,y
                    rora
                    incb
                    sta       b,y
                    lbra      L2106
L2252               bcs       L226E
                    lda       b,x
                    decb
                    suba      >$054C
                    lsra
                    sta       <u00C7
                    lda       >$054E
                    adda      b,y
                    rora
                    suba      <u00C7
                    bcc       L2268
                    clra
L2268               incb
                    sta       b,y
                    lbra      L2106
L226E               lda       b,x
                    decb
                    suba      >$054C
                    lsra
                    sta       <u00C7
                    lda       >$054E
                    adda      b,y
                    rora
                    adca      <u00C7
                    bcc       L2283
                    lda       #$FF
L2283               incb
                    sta       b,y
                    lbra      L2106
L2289               ldd       <u00DA
                    beq       L22E1
                    std       <u00C8
                    ldx       >scrnaddr           screen address
                    leax      >$3BFF,x
                    leay      >$0200,x
                    sty       >$05AA
L229E               ldy       >$05AA
                    ldd       <u00C8
                    lda       d,x
                    cmpa      #$A0
                    bhi       L22D6
                    pshs      a
                    ldd       <u00C8
                    ldb       d,y
                    cmpb      #$5F
                    bcc       L22D6
                    clra
                    lslb
                    ldu       #$0E83
                    ldu       d,u
                    ldb       ,s
                    lsrb
                    leau      b,u
                    lda       #$F0
                    bcc       L22C5
                    coma
L22C5               sta       >$0556
                    coma
                    anda      ,u
                    pshs      a
                    lda       >$0556
                    anda      #$44
                    ora       ,s+
                    sta       ,u
L22D6               puls      b
                    ldd       <u00C8
                    subd      #$0001
                    std       <u00C8
                    bne       L229E
L22E1               lda       >$0128
                    bne       L2323
                    ldb       <u00DE
                    beq       L2323
                    clra
                    tfr       d,x
                    lslb
                    tfr       d,y
L22F0               pshs      y,x
                    lda       >$04FB,x
                    sta       >$0940
                    ldd       >$04BA,y
                    std       >$093C
                    lda       >$049B,x
                    sta       <u0069
                    ldd       >$045A,y
                    std       <u0063
                    lda       >$043B,x
                    sta       <u0061
                    lda       >$041B,x
                    sta       <u0062
                    lbsr      L1C73
                    puls      y,x
                    leay      -$02,y
                    leax      -$01,x
                    bne       L22F0
L2323               lda       >$0128
                    bne       L2360
                    ldb       <u00DC
                    beq       L2360
                    clra
                    tfr       d,x
L232F               pshs      x
                    ldb       >$03BB,x
                    ldu       #$0E83
                    clra
                    lslb
                    rola
                    ldu       d,u
                    ldb       >$03DB,x
                    lsrb
                    leau      b,u
                    lda       #$F0
                    bcc       L2349
                    coma
L2349               sta       <u00AB
                    coma
                    anda      ,u
                    pshs      a
                    lda       >$03FB,x
                    anda      <u00AB
                    ora       ,s+
                    sta       ,u
                    puls      x
                    leax      -$01,x
                    bne       L232F
L2360               rts

L2361               lbsr      L236A
                    lbsr      L5315
                    lbra      L2289
L236A               lda       <u0057
                    beq       L2370
                    sta       <u0059
L2370               ldb       <u0059
                    stb       >$0124
                    clra
                    tfr       d,y
                    ldx       #$0000
L237B               lda       #$00
                    sta       >$01AC,x
                    leay      $01,y
                    leax      $01,x
                    cmpx      #$0010
                    bcs       L237B
                    lda       <u0057
                    beq       L2392
                    adda      #$10
                    sta       <u0058
L2392               ldb       <u0058
                    clra
                    tfr       d,y
                    ldx       #$0000
L239A               lda       #$77
                    sta       >$019C,x
                    leay      $01,y
                    leax      $01,x
                    cmpx      #$0010
                    bcs       L239A
                    clr       <u0057
                    rts

L23AC               stx       <u0023
                    lsr       <u0024
                    pshs      cc
                    tfr       y,d
                    lda       #$50
                    mul
                    addd      #$3F47
                    addd      <u0023
                    tfr       d,u
                    puls      cc
                    rts

L23C1               sta       >$019C
                    lbsr      L23AC
                    ldb       #$0F
                    bcc       L23CD
                    ldb       #$F0
L23CD               tfr       b,a
                    anda      >$019C
                    sta       >$019C
                    comb
                    andb      ,u
                    orb       >$019C
                    stb       ,u
                    rts

L23DE               ldu       #$3F47
                    ldx       #$0F00
L23E4               std       ,u++
                    leax      -$01,x
                    bne       L23E4
                    rts

L23EB               ldu       #$3F99
                    ldy       #$3FE3
                    ldx       #$0005
L23F5               leau      u0001,u
                    leay      -$01,y
                    ldb       #$0A
L23FB               lda       #$32
                    sta       ,u
                    lda       #$12
                    sta       ,y
                    lda       u0001,u
                    anda      #$0F
                    ora       #$10
                    sta       u0001,u
                    lda       $01,y
                    anda      #$0F
                    ora       #$30
                    sta       $01,y
                    leau      <u0050,u
                    leay      <$50,y
                    decb
                    bne       L23FB
                    leau      >u0320,u
                    leay      >$0320,y
                    leax      -$01,x
                    bne       L23F5
                    ldu       #$42B9
                    ldy       #$4302
                    ldx       #$0004
L2432               leau      u0001,u
                    leay      -$01,y
                    ldb       #$0A
L2438               lda       #$21
                    sta       u0001,u
                    lda       #$23
                    sta       $01,y
                    lda       ,u
                    anda      #$F0
                    ora       #$03
                    sta       ,u
                    lda       ,y
                    anda      #$F0
                    ora       #$01
                    sta       ,y
                    leau      <u0050,u
                    leay      <$50,y
                    decb
                    bne       L2438
                    leau      >u0320,u
                    leay      >$0320,y
                    leax      -$01,x
                    bne       L2432
                    ldy       #$1551
                    ldu       #$5ACE
                    lda       #$08
                    sta       <u00C8
L2470               ldx       #$0021
L2473               ldd       ,y++
                    std       ,u++
                    leax      -$01,x
                    bne       L2473
                    leau      u000E,u
                    dec       <u00C8
                    bne       L2470
                    ldu       #$3F47
                    ldd       #$2211
                    sta       ,u
                    sta       u0001,u
                    stb       u0002,u
                    stb       u0003,u
                    stb       u0004,u
                    stb       <u0050,u
                    stb       <u0051,u
                    stb       <u004B,u
                    stb       <u004C,u
                    stb       <u004D,u
                    sta       <u004E,u
                    sta       <u004F,u
                    stb       >u009E,u
                    stb       >u009F,u
                    ldb       #$22
                    ldu       #$5B67
                    std       u0005,u
                    std       >u00A3,u
                    std       >u00A5,u
                    std       >u0141,u
                    std       >u0143,u
                    std       <u0049,u
                    std       >u00E9,u
                    std       >u00EB,u
                    std       >u018B,u
                    std       >u018D,u
                    ldd       #$3333
                    std       <u0055,u
                    std       >u00F3,u
                    std       >u00F5,u
                    std       >u0145,u
                    std       >u0191,u
                    std       >u0193,u
                    std       >u0195,u
                    std       >u0099,u
                    std       >u0139,u
                    std       >u013B,u
                    std       >u0189,u
                    std       >u01D9,u
                    std       >u01DB,u
                    std       >u01DD,u
                    rts

L2513               pshs      x
                    pshs      u
L2517               std       <u0050,u
                    std       ,u++
                    leax      -$01,x
                    bne       L2517
                    puls      u
                    leau      >u00A0,u
                    puls      x
                    leay      -$01,y
                    bne       L2513
                    rts

L252D               pshs      u,b,a
                    ldu       #$161A
                    ldb       #$1B
                    lda       #$00
L2536               sta       <u0062,u
                    sta       <u0042,u
                    sta       <u0020,u
                    sta       ,u+
                    decb
                    bne       L2536
                    puls      pc,u,b,a
L2546               ldd       #$50C7
                    std       >$0CC1
                    ldd       #$0014
                    std       >$0CC3
                    lda       #$0A
                    sta       >$052F
L2557               lbsr      L2656
                    ldu       #$3F47
                    ldx       #$0028
                    ldy       >$0CC3
                    ldd       #$6666
                    lbsr      L2513
                    ldu       >$0CC1
                    ldx       #$0028
                    ldy       >$0CC3
                    ldd       #$6666
                    lbsr      L2513
                    ldu       #$3FE7
                    ldb       >$0CC4
                    lsrb
                    lbsr      L30FB
                    ldu       >$0CC1
                    leau      >u00A0,u
                    ldb       >$0CC4
                    lsrb
                    lbsr      L30FB
                    lbsr      L23EB
                    lbsr      L279E
                    lbsr      pollkybd
                    ldx       #$0014
                    lbsr      L5819
                    ldd       #$0140
                    addd      >$0CC1
                    std       >$0CC1
                    ldd       >$0CC3
                    subd      #$0002
                    std       >$0CC3
                    dec       >$052F
                    lbne      L2557
                    rts

L25BB               lda       #$08
                    sta       <u00CE
                    lda       #$07
                    sta       <u00CD
                    lda       #$0F
                    sta       <u00CC
                    lbsr      L3E28
                    lbsr      L285E
                    lbsr      L2656
                    lbsr      L23EB
                    lbsr      L279E
                    ldd       #$0480
                    std       >$0CC5
                    leay      >L5AA9,pcr
                    ldb       #$32
                    lbsr      L2723
                    ldy       #$1423
                    ldb       #$09
L25EB               pshs      y,b
                    ldu       #$3F47
                    ldd       ,y++
                    lda       #$50
                    mul
                    leau      d,u
                    ldb       ,y
                    leau      b,u
                    clra
                    ldb       #$28
                    subb      ,y+
                    tfr       d,x
                    ldb       ,y
                    tfr       d,y
                    ldd       #$0000
                    lbsr      L2513
                    lbsr      L288F
                    lbsr      L23EB
                    lbsr      L279E
                    leay      >L5AA9,pcr
                    ldb       ,s
                    decb
                    bsr       L263F
                    ldy       >$0CC5
                    lbsr      L35CD
                    lbsr      pollkybd
                    ldx       #$0004
                    lbsr      L5819
                    ldd       >$0CC5
                    addd      #$0009
                    std       >$0CC5
                    puls      y,b
                    leay      -$04,y
                    decb
                    bne       L25EB
                    rts

L263F               andb      #$03
                    lslb
                    lslb
                    leay      b,y
                    lda       #$04
                    sta       <u00C8
                    ldb       #$09
L264B               lda       ,y+
                    lbsr      writepal
                    incb
                    dec       <u00C8
                    bne       L264B
                    rts

L2656               ldy       #$1403
                    ldb       #$09
L265C               pshs      b
                    ldu       #$3F47
                    lda       ,y+
                    sta       >$0557
                    lda       ,y+
                    ldb       #$50
                    mul
                    leau      d,u
                    clra
                    ldb       ,y
                    leau      b,u
                    ldb       #$28
                    subb      ,y+
                    tfr       d,x
                    ldb       ,y+
                    pshs      y
                    tfr       d,y
                    lda       >$0557
                    ldb       >$0557
                    lbsr      L2513
                    puls      y
                    puls      b
                    decb
                    bne       L265C
                    rts

L268F               ldy       #$0480
                    sty       >$0CC5
                    lbsr      L285E
                    ldd       #$0000
                    lbsr      L23DE
                    lbsr      L288F
                    lbsr      L23EB
                    lbsr      L279E
                    lda       #$00
                    sta       >$0557
                    lbsr      L274D
                    ldy       #$1423
                    ldb       #$09
L26B7               pshs      y,b
L26B9               pshs      b
                    ldu       #$3F47
                    lda       ,y+
                    sta       >$0557
                    ldb       ,y+
                    lda       #$50
                    mul
                    leau      d,u
                    ldb       ,y
                    leau      b,u
                    clra
                    ldb       #$28
                    subb      ,y+
                    tfr       d,x
                    ldb       ,y+
                    pshs      y
                    tfr       d,y
                    lda       >$0557
                    ldb       >$0557
                    lbsr      L2513
                    puls      y
                    puls      b
                    incb
                    cmpb      #$09
                    bcs       L26B9
                    lbsr      L23EB
                    lbsr      L279E
                    ldy       >$0CC5
                    lbsr      L35CD
                    lbsr      pollkybd
                    ldx       #$0014
                    lbsr      L5819
                    ldd       >$0CC5
                    addd      #$0009
                    std       >$0CC5
                    puls      y,b
                    leay      -$04,y
                    decb
                    bne       L26B7
                    leay      >L5AB9,pcr
                    ldb       #$14
                    bsr       L2723
                    lda       #$66
                    sta       >$0557
                    lbra      L274D
L2723               pshs      y,b
                    lbsr      L263F
                    ldy       >$0CC5
                    lbsr      L35CD
                    lbsr      pollkybd
                    lbsr      L3D31
                    clra
                    ldb       ,s
                    incb
                    tfr       d,x
                    lbsr      L5819
                    ldd       >$0CC5
                    addd      #$0009
                    std       >$0CC5
                    puls      y,b
                    decb
                    bne       L2723
                    rts

L274D               ldy       #$1423
                    ldb       #$09
L2753               pshs      y,b
                    ldu       #$3F47
                    ldd       ,y++
                    lda       #$50
                    mul
                    leau      d,u
                    ldb       ,y
                    leau      b,u
                    clra
                    ldb       #$28
                    subb      ,y+
                    tfr       d,x
                    ldb       ,y
                    tfr       d,y
                    lda       >$0557
                    ldb       >$0557
                    lbsr      L2513
                    lbsr      L23EB
                    lbsr      L279E
                    ldy       >$0CC5
                    lbsr      L35CD
                    lbsr      pollkybd
                    ldx       #$0014
                    lbsr      L5819
                    ldd       >$0CC5
                    addd      #$0009
                    std       >$0CC5
                    puls      y,b
                    leay      -$04,y
                    decb
                    bne       L2753
                    rts

L279E               clr       >$0602
                    lda       #$60
                    sta       >$0529
                    orcc      #IntMasks           mask interrupts
                    stx       <u0000
                    stu       <u0004
                    sts       <u0006
                    sty       <u0002
                    lds       #$3F47
                    ldu       >scrnaddr           screen address
                    leau      >u0787,u
L27BD               puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000E,u
                    puls      y,x,dp,b,a
                    pshu      y,x,dp,b,a
                    leau      u000A,u
                    puls      dp,b,a
                    pshu      dp,b,a
                    leau      u000A,u
                    clra
                    tfr       a,dp
                    sts       <u0008
                    lds       <u0006
                    andcc     #^IntMasks          unmask interrupts
                    orcc      #Intmasks           mask interrupts
                    lds       <u0008
                    dec       >$0529
                    bne       L27BD
                    clra
                    tfr       a,dp
                    ldx       <u0000
                    ldy       <u0002
                    ldu       <u0004
                    lds       <u0006
                    andcc     #^IntMasks          unmask interrupts
                    rts

L282A               lbsr      L56E2
                    anda      #$03
                    bne       L285D
                    lda       #$02
                    sta       <u00B3
                    ldx       #$055C
                    ldy       #$057C
                    ldb       #$1F
L283E               lda       b,x
                    cmpa      #$FF
                    bne       L285A
                    lbsr      L56E2
                    anda      #$7F
                    adda      #$10
                    sta       b,x
                    lbsr      L56E2
                    anda      #$01
                    adda      #$5D
                    sta       b,y
                    dec       <u00B3
                    beq       L285D
L285A               decb
                    bpl       L283E
L285D               rts

L285E               ldx       #$055C
                    ldy       #$057C
                    ldb       #$1F
                    lda       #$FF
L2869               sta       b,x
                    sta       b,y
                    decb
                    bpl       L2869
                    lbsr      L56E2
                    anda      #$0F
                    adda      #$10
                    tfr       a,b
L2879               lbsr      L56E2
                    anda      #$7F
                    adda      #$10
                    sta       b,x
                    lbsr      L56E2
                    anda      #$3F
                    adda      #$10
                    sta       b,y
                    decb
                    bpl       L2879
                    rts

L288F               ldx       #$055C
                    ldy       #$057C
                    lda       #$1F
L2898               pshs      y,x,a
                    ldb       a,x
                    cmpb      #$FF
                    beq       L28CC
                    clra
                    tfr       d,x
                    ldb       ,s
                    ldb       b,y
                    tfr       d,y
                    lda       #$50
                    mul
                    addd      #$3F47
                    tfr       d,u
                    tfr       x,d
                    lsrb
                    leau      b,u
                    lda       ,u
                    cmpa      #$00
                    bne       L28CC
                    lbsr      L56E2
                    tfr       a,b
                    lda       #$11
                    cmpb      #$A0
                    bls       L28C9
                    lda       #$22
L28C9               lbsr      L23C1
L28CC               puls      y,x,a
                    deca
                    bne       L2898
                    rts

L28D2               ldx       #$055C
                    ldy       #$057C
                    ldb       #$1F
L28DB               lda       b,y
                    cmpa      #$FF
                    beq       L28ED
                    suba      #$02
                    sta       b,y
                    bcc       L28ED
                    lda       #$FF
                    sta       b,x
                    sta       b,y
L28ED               decb
                    bpl       L28DB
                    rts


* joystick X/Y poll routine
getjoyxy            lda       >joyx               get last X value
                    sta       >joyxold            store in old
                    lda       >joyy               get last Y value
                    sta       >joyyold            store in old
                    clr       >$05A7              ???
                    ldd       #SS.Joy             we want joystick info
                    ldx       #$0001              on left joystick
                    os9       I$GetStt            now!
                    sta       >button             save button info
                    tfr       x,d                 copy joystick X to D
                    stb       >joyx               and save X value
                    lda       #$00                clear A
                    cmpb      #$17                compare joy X against 23
                    bcc       L291B               if X value is greater, branch
                    lda       #$FF                else load A with 0xFF
                    bra       L2921

L291B               cmpb      #$27                compare joy X against 39
                    bls       L2921               if lower or same, branch
                    lda       #$01                load A with 1
L2921               sta       >$05A3              save A
                    cmpa      >$05A5              compare with old A
                    beq       L292F               branch if equal
                    sta       >$05A5              store in old A
                    inc       >$05A7              inc ???
L292F               tfr       y,d                 transfer joystick Y to D
                    stb       >joyy               save in "current" joystick Y
                    lda       #$00                load A with 00
                    cmpb      #$17                compare joystick Y against 23
                    bcc       L293E               if Y value is ??, branch
                    lda       #$01                else load A with $1
                    bra       L2944               and branch
L293E               cmpb      #$27                is joystick Y <= 39?
                    bls       L2944               if so, branch
                    lda       #$FF                else load A with $FF
L2944               sta       >$05A4              save A (either $0, $FF or $1)
                    cmpa      >$05A6              compare against old A
                    beq       L2957               branch if equal
                    sta       >$05A6              save off A to old A
                    lda       >$05A7              load A with ??
                    ora       #$02
                    sta       >$05A7              save it back
L2957               rts

pollkybd            clr       >$0604
                    ldd       #SS.Ready
                    os9       I$GetStt
                    bcs       L2977
                    lbsr      readch              call readch routine (A comes back as char)
                    cmpa      #$20                is it spacebar?
                    bne       L296D               no
                    lbra      readch              else read another character
L296D               cmpa      #$03                is it BREAK key?
                    bne       L2977               no, branch
                    ldd       #$0300              else do routine 3 (exit)
                    lbra      routines            now!
L2977               rts

L2978               ldd       ,y
                    std       <u00CA
                    ldd       $02,y
                    std       <u00CC
                    ldd       $04,y
                    std       >$05ED
                    lda       $06,y
                    sta       >$05EF
                    clr       >$05F1
                    clr       >$05F2
                    lbsr      L2A68
                    lda       >$05EF
                    anda      #$FE
                    beq       L29D3
                    ldb       <u00CB
L299C               pshs      b
                    lbsr      L29DC
                    ldy       #$05CD
                    ldb       >$05F1
                    lda       b,y
                    beq       L29C9
                    ldb       <u00CB
                    addb      >$05F2
                    subb      #$50
                    bcs       L29C9
                    pshs      b
                    ldb       #$5F
                    subb      ,s+
                    ldu       #$0E83
                    clra
                    lslb
                    rola
                    ldu       d,u
                    lbsr      L29FE
                    inc       >$05F2
L29C9               puls      b
                    inc       >$05F1
                    incb
                    cmpb      <u00CD
                    bcs       L299C
L29D3               lda       >$05EF
                    anda      #$FE
                    sta       >$05F0
                    rts

L29DC               ldy       #$05AD
                    ldb       #$08
                    stb       >$05F3
L29E5               lda       ,x+
                    ldb       #$03
L29E9               pshs      a
                    anda      #$03
                    sta       b,y
                    puls      a
                    lsra
                    lsra
                    decb
                    bpl       L29E9
                    leay      $04,y
                    dec       >$05F3
                    bne       L29E5
                    rts

L29FE               pshs      u,x
                    ldx       #$05CD
                    ldy       #$05AD
                    lda       #$F0
                    sta       <u00AB
                    ldb       <u00CA
                    subb      #$30
                    bcc       L2A12
                    clrb
L2A12               lsrb
                    bcc       L2A17
                    com       <u00AB
L2A17               leau      b,u
                    ldb       <u00CA
L2A1B               lda       ,x
                    ora       $01,x
                    beq       L2A39
                    cmpb      #$30
                    bcs       L2A39
                    cmpb      #$D0
                    bcc       L2A39
                    lda       ,x
                    beq       L2A31
                    lda       ,y
                    bsr       L2A45
L2A31               lda       $01,x
                    beq       L2A39
                    lda       $01,y
                    bsr       L2A45
L2A39               leax      $02,x
                    leay      $02,y
                    addb      #$02
                    cmpb      <u00CC
                    bcs       L2A1B
                    puls      pc,u,x
L2A45               tsta
                    beq       L2A5F
                    pshs      y
                    ldy       >$05ED
                    lda       a,y
                    puls      y
                    anda      <u00AB
                    pshs      a
                    lda       <u00AB
                    coma
                    anda      ,u
                    ora       ,s+
                    sta       ,u
L2A5F               com       <u00AB
                    lda       <u00AB
                    bpl       L2A67
                    leau      u0001,u
L2A67               rts

L2A68               pshs      x
                    lda       >$05F0
                    cmpa      >$05EF
                    beq       L2A98
                    ldx       #$05CD
                    ldb       #$20
L2A77               clr       ,x+
                    decb
                    bne       L2A77
                    ldb       >$05EF
                    andb      #$FE
                    beq       L2A98
                    cmpb      #$20
                    bls       L2A89
                    ldb       #$20
L2A89               ldy       #$05CD
                    leax      >L2ACC-1,pcr
L2A91               lda       b,x
                    com       a,y
                    decb
                    bne       L2A91
L2A98               puls      pc,x
L2A9A               pshs      a
                    ldb       >$0617
                    cmpa      #$0F
                    bls       L2AA4
                    clrb
L2AA4               addb      ,s+
                    pshs      b
                    leay      >L5AD9,pcr
                    lda       b,y
                    ldb       #$0B
                    lbsr      writepal
                    ldb       ,s
                    leay      >L5AED,pcr
                    lda       b,y
                    ldb       #$0C
                    lbsr      writepal
                    puls      b
                    leay      >L5B01,pcr
                    lda       b,y
                    ldb       #$04
                    lbra      writepal
L2ACC
                    fdb       $0f10,$0718,$0b14,$031c,$0d12,$011e,$0916,$051a,$0e11
                    fdb       $001f,$0c13,$021d,$0a15,$041b,$0817,$0619

* RLE decoding routine
*   X = source
*   U = destination
*   Y = count
*
* if a byte has its high bit set, then the byte-128 is the number of
* times to copy the next byte.

rldecode            lda       ,x+                 get A (count)
                    bpl       L2AFE               if high bit not set, just copy next byte
                    anda      #$7F                else chop off high bit
                    leay      -$01,y              subtract 1 from y
                    ldb       ,x+                 load B with byte at X and post increment
L2AF7               stb       ,u+                 store B at U and post increment
                    deca                          decrement A
                    bne       L2AF7               if not zero...
                    bra       L2B07
* here, A is a counter
L2AFE               ldb       ,x+                 get byte at X
                    stb       ,u+                 store at U
                    leay      -$01,y              subtract 1 from Y
                    deca                          decrement A
                    bne       L2AFE               if not zero, get next byte at X
L2B07               leay      -$01,y
                    bne       rldecode
                    rts

L2B0C               ldy       #$0000
L2B10               lda       #$00
                    ldb       #$22
L2B14               sta       >$0559
                    stb       >$0558
                    cmpy      #$002D
                    bcc       L2B0C
                    ldb       >rofvbuf,y
                    lda       >$0F70,y
                    tfr       d,y
                    lda       ,y+
                    pshs      a
                    ldb       ,y+
                    ldu       #$0D03
                    clra
                    lslb
                    rola
                    ldu       d,u
                    leau      <u0050,u
                    puls      a
                    leau      a,u
L2B3F               lda       ,y+
                    bne       L2B44
                    rts

L2B44               ldx       #$3D6E
                    ldb       #$2B
L2B49               cmpa      b,x
                    beq       L2B51
                    decb
                    bpl       L2B49
                    incb
L2B51               lda       >$0CF1
                    mul                           D = A*B
                    addd      >$0CF2
                    tfr       d,x
                    pshs      u,y
                    ldy       #$13F6
                    lda       >$0CF1
                    sta       <u00B3
L2B65               ldb       #$03
                    lda       ,x+
                    sta       >$055B
                    bsr       L2B84
                    leau      <u004D,u
                    tst       >$0CF4
                    beq       L2B79
                    leau      <u0050,u
L2B79               dec       <u00B3
                    bne       L2B65
                    puls      u,y
                    leau      u0003,u
                    lbra      L2B3F
L2B84               lda       >$055B
                    anda      #$03
                    lda       a,y
                    sta       <u00C8
                    coma
                    anda      >$0558
                    pshs      a
                    lda       <u00C8
                    anda      >$0559
                    ora       ,s+
                    tst       >$0CF4
                    beq       L2BA2
                    sta       <u0050,u
L2BA2               sta       ,u+
                    lsr       >$055B
                    lsr       >$055B
                    decb
                    bne       L2B84
                    rts

                    pshs      b
                    bsr       L2BC1
                    puls      a
                    bsr       L2BC1
                    rts

L2BB7               cmpa      #$09
                    bhi       L2BBE
                    ora       #$30
                    rts

L2BBE               adda      #$37
                    rts

L2BC1               pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       L2BB7
                    sta       ,x+
                    puls      a
                    anda      #$0F
                    bsr       L2BB7
                    sta       ,x+
                    rts

* this seems to be some routine which gives access to a vector of
* routines based on a value in A
routines            std       <u0000              save A/B
*        move.b d0,u0000(a6)
*        move.b d1,u0001(a6)
                    stu       <u0004              save U
*        move.w a5,u0004(a6)
                    lsla                          multiply x 2 to get offset into table
*        lsl.b  d0
                    leau      >JmpTbl,pcr         point to base of table
*        lea.l JmpTbl(pcr),a5
                    ldd       a,u                 add offset to base
*        move.l a5,d2
*        add.b  d0,d2
                    leau      d,u                 get address of routine
*        lea.l (a5,d2.w),a5
                    pshs      u                   push address of routine on stack
*        movem.l a5,-(sp)
                    ldd       <u0000              restore A/B
*        move.b u0000(a6),d0
*        move.b u0001(a6),d1
                    ldu       <u0004              restore U
*        move.w u0004(a6),a5
                    rts                           rts into the routine
*        rts

* this is the vector table used by 'routines' above
JmpTbl
                    fdb       Rtn0-JmpTbl         * $000c
                    fdb       Rtn1-JmpTbl         * $0028
                    fdb       Rtn2-JmpTbl         * $0062
                    fdb       Rtn3-JmpTbl         * $008c
                    fdb       Rtn4-JmpTbl         * $0111
                    fdb       Rtn5-JmpTbl         * $0044

Rtn0
                    sty       <u0000              save off Y (byte count)
*        move.w a1,u0000(a6)
                    stu       <u0004              save off U (address)
*        move.w a5,u0004(a6)
                    lda       #READ.              open for read mode
*        move.w #Read_,d0
                    os9       I$Open              open it!
*        os9   I$Open
                    bcs       Rtn3                go to Rtn3 if error
*        bcs.s Rtn3
                    ldy       <u0000              retrieve Y (byte count)
*        move.w u0000(a6),a1

L2C03               ldx       <u0004              retrieve X (address)
*        move.l u0004(a6),a0
                    pshs      a                   save A
*        move.w d0,-(sp)
                    os9       I$Read              read Y bytes at X
*        os9   I$Read
                    puls      a                   restore A
*        move.w (sp)+,d0
                    os9       I$Close             close file
                    rts                           return

Rtn1                stu       <u0004              save off U
                    lda       #READ.              open for read
                    os9       I$Open              open it!
                    bcs       Rtn3                go to Rtn3 if error (exit)
                    pshs      a                   save off A
                    ldx       #$0002              at this address
                    ldy       #$0002              this many bytes
                    os9       I$Read              read 'em!
                    puls      a                   restore A
                    ldy       <u0002              restore Y with what we read in A/B (bytes)
                    bra       L2C03

Rtn5                stu       <u0004              save off U
                    lda       #READ.              open for read
                    os9       I$Open              open it!
                    bcs       Rtn3                go to Rtn3 if error
                    pshs      a                   save off A
                    ldx       #$0002              at this address
                    ldy       #$0002              this many bytes
                    os9       I$Read              read 'em!
                    ldd       <u0002              fill A/B with bytes we just read
                    mul                           multiply
                    tfr       d,y                 put product in Y
                    puls      a                   restore A
                    bra       L2C03

* delete and create a new file of the same name
Rtn2                sty       <u0000
                    stu       <u0004
                    pshs      x
                    os9       I$Delete
                    puls      x
                    lda       #WRITE.
                    ldb       #READ.+WRITE.+PREAD.+PWRIT.+SHARE.
                    os9       I$Create
                    bcs       L2C73
                    sta       >tmppath
                    ldx       <u0004
                    ldy       <u0000
                    os9       I$Write
                    bcs       L2C73
                    lda       >tmppath
                    os9       I$Close
                    rts
L2C73               rts

* prepare to exit
Rtn3                pshs      b                   save off B (error code)
* show VDG screen
                    ldy       #$0000              turn off graphics screen
                    lda       #$01                to standard output
                    ldb       #SS.DScrn           display screen
                    os9       I$SetStt            turn it off!
* set standard palettes
                    leay      >stdpals,pcr        point to standard palettes
                    lbsr      setpal              set palettes to standard
* clear screen and give gfx screen memory back
                    bsr       clearscr            clear screen
                    lda       #$01                to standard output
                    ldb       #SS.FScrn           free screen memory
                    ldy       >scrnnum            get screen number
                    os9       I$SetStt            free it!
* check error code and print error message if needed
                    puls      b                   get B (error code)
                    tstb                          is it 0? (no error)
                    beq       byebye              if so, say byebye without alarm
                    pshs      b                   else notify user of error... save B
                    leax      >errmess,pcr        point to error preface string
                    ldy       #$0008              write error preface
                    lda       #$02                ...to standard error
                    os9       I$Write             now!
                    puls      a                   get A (was B/error code)
                    bsr       prnum               print error code
                    bsr       newline

* here we say "byebye" to Rescue on Fractalus
byebye
* first restore old echo/pause options
                    lda       >oldecho
                    sta       >echoflg
                    lda       >$0CBC
                    sta       >pauseflg
                    lda       #$01                standard out
                    clrb                          SS.Opt
                    ldx       #pathopts
                    os9       I$SetStt

* then chain to a shell
                    clra
                    tfr       a,dp
                    lds       #$00FF
                    leax      >shell,pcr
                    ldy       #$0000
                    ldu       #$0000
                    lda       #$11
                    ldb       #$03
                    os9       F$Chain             adieu!

* clear the screen
clearscr            leax      >cls,pcr            point to cls character
                    ldy       #$0001              write 1 byte
                    lda       #$01                ...to standard out
                    os9       I$Write             now!
                    rts

* print a new line to standard output
newline             leax      >nl,pcr             point to nl characters
                    ldy       #$0002              write 2 bytes
                    lda       #$01                ...to standard out
                    os9       I$Write             now!
                    rts

* read one character from standard input if ready
* if carry clear, A holds character
Rtn4                ldd       #SS.Ready           SS.RDY, standard input
                    os9       I$GetStt            get it!
                    bcs       ReadErr             return with carry set if error
                    ldx       #$0000              is this u0000???? I wonder...
                    ldy       #$0001              read 1 character
                    lda       #$00                standard input
                    os9       I$Read
                    lda       <u0000
                    andcc     #^Carry             clear carry flag
ReadErr             rts

* write something to standard output
* X = address of buffer to write
* Y = no. of bytes to write
WriteOut            lda       #$01                standard output
                    os9       I$Write
                    rts

* print a number
prnum               pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       L2D24
                    puls      a
                    anda      #$0F
L2D24               cmpa      #$09
                    bhi       L2D2C
                    ora       #$30
                    bra       L2D2E
L2D2C               adda      #$37
L2D2E               sta       <u0002
                    ldx       #$0002
                    ldy       #$0001
                    lda       #$01
                    os9       I$Write
                    rts

errmess             fcc       "ERROR # "

shell               fcc       "SHELL"
                    fcb       C$CR

cls                 fcb       C$FORM

nl                  fcb       C$CR,C$LF

L2D4E               lbsr      L582F
                    clr       >$051C
                    clr       >$011D
                    clr       >$051D
                    clr       >$051E
                    clr       <u00FB
                    clr       >$0115
                    clr       <u00F5
                    clr       >$010E
L2D67               lda       #$C0
                    sta       >$051F
                    lda       #$FF
                    sta       >$011C
                    lda       <u0079
                    beq       L2D8B
                    lbsr      L2B0C
                    lda       <u00FD
                    beq       L2D85
                    clr       <u00FD
                    ldy       #$0016
                    lbsr      L2B10
L2D85               lbsr      L30C4
                    lbsr      L2B0C
L2D8B               lda       #$FF
                    sta       <u00F4
                    tst       >$0CFC
                    lbeq      L2E76
                    tst       <u0079
                    lbeq      L2E76
                    lda       >$0105
                    lbeq      L2E37
                    suba      >$0106
                    sta       <u00F4
                    bpl       L2DBB
                    clra
                    ldb       >$0106
                    tfr       d,y
                    subb      >$0105
                    stb       >$0106
                    ldb       >$0105
                    bra       L2DC1
L2DBB               clra
                    ldb       >$0106
                    tfr       d,y
L2DC1               stb       <u00C7
                    tfr       y,d
                    tfr       b,a
                    lbsr      L32CC
                    ldy       #$000C
                    lbsr      L2B10
L2DD1               ldd       #$0500
                    std       <u0055
                    lbsr      L32B8
                    dec       <u00C7
                    bne       L2DD1
                    lda       <u00F4
                    bmi       L2E31
                    beq       L2E01
                    lbsr      L03D9
                    lbsr      L32CC
L2DE9               lda       #$10
                    sta       <u0055
                    lda       #$02
                    lbsr      L3600
                    lda       #$02
                    lbsr      L3600
                    lbsr      L03ED
                    lbsr      L32B8
                    dec       <u00F4
                    bne       L2DE9
L2E01               lbsr      L03D9
                    ldy       #$0003
                    lbsr      L2B10
                    lda       <u007A
                    sta       <u00CA
                    cmpa      >$0CFB
                    bls       L2E17
                    sta       >$0CFB
L2E17               lbsr      L32A6
                    tst       <u00F8
                    bne       L2E34
L2E1E               lda       #$02
                    sta       <u00C7
L2E22               lda       <u00D2
                    sta       <u0055
                    lbsr      L32C1
                    dec       <u00C7
                    bne       L2E22
                    dec       <u00CA
                    bne       L2E1E
L2E31               lbsr      L03D9
L2E34               lbsr      L2B0C
L2E37               tst       <u00F4
                    bpl       L2E5B
                    lda       <u007A
                    cmpa      #$05
                    bcc       L2E4F
                    lda       #$01
                    sta       <u00E6
                    lda       #$04
                    sta       >$0CFA
                    inc       >$0129
                    bra       L2E76
L2E4F               sta       >$0CFA
                    suba      #$03
                    sta       <u00E6
                    inc       >$0129
                    bra       L2E76
L2E5B               lda       <u007A
                    sta       <u00E6
                    sta       >$012E
                    inc       <u00E6
                    adda      #$04
                    cmpa      #$64
                    bcs       L2E6C
                    lda       #$63
L2E6C               sta       >$0CFA
                    tst       <u0085
                    bne       L2E76
                    lbsr      L312F
L2E76               clr       >$0523
                    clr       >$051C
                    clr       >$011D
                    clr       >$0105
                    lda       #$C0
                    sta       >$051F
                    lbsr      L56F3
                    lbsr      L2B0C
                    tst       <u0079
                    bne       L2EA7
                    lbsr      L30DD
                    clr       >$0CF5
                    clr       >$0CF6
                    clr       >$0CF7
                    clr       >$0CF8
                    clr       <u00F7
                    clr       <u00F8
                    clr       >$012E
L2EA7               lbsr      L3CE2
                    tst       <u0085
                    bne       L2EF6
                    tst       >$0CFC
                    beq       L2EB8
                    tst       >$0129
                    bne       L2EF6
L2EB8               clr       >$113F
                    clr       >$1140
                    ldy       #$0019
                    lbsr      L2B10
                    ldd       #$01CC
                    std       >$0520
L2ECB               clra
                    lbsr      L3600
                    lda       >button
                    bne       L2EF6
                    lda       >$05A4
                    cmpa      #$FF
                    bne       L2EE7
                    lda       <u007A
                    cmpa      >$0CFA
                    bcc       L2ECB
                    lbsr      L312F
                    bra       L2ECB
L2EE7               cmpa      #$01
                    bne       L2ECB
                    lda       <u007A
                    cmpa      <u00E6
                    bls       L2ECB
                    lbsr      L318E
                    bra       L2ECB
L2EF6               clr       >$0116
                    clr       >$0127
                    clr       >$0129
                    lda       #$01
                    sta       >$0CFC
                    sta       <u0079
                    lbsr      L2B0C
                    ldy       #$000B
                    tst       <u0085
                    beq       L2F15
                    ldy       #$0013
L2F15               lbsr      L2B10
                    tst       <u0085
                    bne       L2F3C
                    ldb       <u007A
                    cmpb      <u00F6
                    pshs      cc
                    stb       <u00F6
                    puls      cc
                    bne       L2F2C
                    inc       <u00F8
                    bra       L2F41
L2F2C               bcc       L2F3C
                    clr       >$0CF5
                    clr       >$0CF6
                    clr       >$0CF7
                    clr       >$0CF8
                    clr       <u00F7
L2F3C               clr       <u00F8
                    lbsr      L31DD
L2F41               lda       #$01
                    lbsr      L3600
                    lbsr      L3C31
                    lbsr      L4221
                    leay      >L5AA9,pcr
                    clrb
                    lbsr      L263F
                    lbsr      L2546
                    lbsr      L25BB
                    lbra      L2F6C
                    sta       >$0524
                    lbsr      L56E2
                    cmpa      >$0524
                    bcc       L2F68
L2F68               rts

                    lbsr      L285E
L2F6C               lda       #$0A
                    sta       <u00CE
                    lda       #$07
                    sta       <u00CD
                    lda       #$0F
                    sta       <u00CC
                    lbsr      L3E28
                    ldb       #$1E
L2F7D               pshs      b
                    ldd       #$0000
                    lbsr      L23DE
                    lbsr      L288F
                    lbsr      L23EB
                    lbsr      L279E
                    lbsr      L28D2
                    lbsr      L282A
                    lbsr      pollkybd
                    lbsr      L3D31
                    clra
                    ldb       ,s
                    lsrb
                    addb      #$0D
                    tfr       d,x
                    lbsr      L5819
                    puls      b
                    decb
                    bne       L2F7D
                    lda       #$0C
                    sta       <u00CE
                    lda       #$07
                    sta       <u00CD
                    lda       #$0F
                    sta       <u00CC
                    lbsr      L3E28
                    ldb       #$09
                    lda       #$34
                    lbsr      writepal
                    ldb       #$0A
                    lda       #$36
                    lbsr      writepal
                    lda       #$72
L2FC9               sta       >$059C
                    ldd       #$0000
                    lbsr      L23DE
                    lbsr      L288F
                    bsr       L3021
                    lbsr      L23EB
                    lbsr      L279E
                    lbsr      L28D2
                    lbsr      L282A
                    lbsr      pollkybd
                    lbsr      L3D31
                    ldx       #$0008
                    lbsr      L5819
                    lda       >$059C
                    suba      #$02
                    bne       L2FC9
L2FF7
                    ldd       #$DDDD
                    lbsr      L23DE
                    lbsr      L23EB
                    lbsr      L279E
                    ldb       #$09
                    lda       #$26
                    lbsr      writepal
                    ldb       #$0A
                    lda       #$22
                    lbsr      writepal
                    ldb       #$0B
                    lda       #$34
                    lbsr      writepal
                    ldb       #$0C
                    lda       #$22
                    lbsr      writepal
                    lbra      L0452
L3021               lda       #$14
                    ldy       #$3F31
                    ldb       >$059C
                    subb      #$14
                    bcc       L3044
                    negb
                    cmpb      #$14
                    lbcc      L30A8
                    pshs      b
                    clra
                    addd      #$3F31
                    tfr       d,y
                    lda       #$14
                    suba      ,s+
                    clrb
                    bra       L3050
L3044               pshs      b
                    lda       #$60
                    suba      ,s+
                    cmpa      #$14
                    bls       L3050
                    lda       #$14
L3050               pshs      a
                    lda       #$50
                    mul
                    addd      #$3F47
                    tfr       d,u
                    puls      b
                    clra
                    tfr       d,x
                    pshs      u,y,x
                    lda       #$AA
L3063               pshs      u
                    ldb       #$28
                    subb      ,y
                    leau      b,u
                    ldb       ,y+
                    lslb
L306E               sta       ,u+
                    decb
                    bne       L306E
                    puls      u
                    leau      <u0050,u
                    leax      -$01,x
                    bne       L3063
                    stu       <u0004
                    puls      u,y,x
                    cmpx      #$0002
                    bls       L30A8
                    leax      -$02,x
                    leau      >u00A0,u
                    lda       #$99
L308D               pshs      u
                    ldb       #$28
                    subb      ,y
                    leau      b,u
                    ldb       ,y+
                    lslb
L3098               sta       ,u+
                    decb
                    bne       L3098
                    puls      u
                    leau      <u0050,u
                    leax      -$01,x
                    bne       L308D
                    stu       <u0004
L30A8               ldb       >$059C
                    cmpb      #$5F
                    bcc       L30C3
                    ldb       #$60
                    subb      >$059C
                    lsrb
                    clra
                    tfr       d,y
                    ldx       #$0028
                    ldu       <u0004
                    ldd       #$9999
                    lbra      L2513
L30C3               rts

L30C4               lda       #$26
                    sta       >$0523
                    lbsr      L043D
                    clrb
                    leay      >L5AB9,pcr
                    lbsr      L263F
                    lbsr      L268F
                    inc       >$0523
                    lbra      L30DD
L30DD               bsr       L30E8
                    lda       #$40
                    sta       >$059D
                    lda       <u007A
                    bra       L3110
L30E8               ldd       #$6666
                    lbsr      L23DE
                    ldu       #$3F47
                    ldb       #$1E
                    bsr       L30FB
                    lbsr      L23EB
                    lbra      L279E
L30FB               tstb
                    beq       L310F
                    lda       #$00
L3100               sta       u000E,u
                    sta       <u0027,u
                    sta       <u0041,u
                    leau      >u00F0,u
                    decb
                    bne       L3100
L310F               rts

L3110               lbsr      L31C9
                    ldx       #$1132
                    lbsr      L2BC1
                    lda       #$1C
                    sta       >$112A
                    lda       >$059D
                    sta       >$112B
                    ldy       #$0017
                    lda       #$00
                    ldb       #$66
                    lbra      L2B14
L312F               ldd       #$0200
                    std       >$0CC5
                    ldd       #$0030
                    std       >$0CC7
                    ldx       #$0009
L313E               pshs      x
                    lda       >$13F9,x
                    adda      >$059D
                    lbsr      L316A
                    puls      x
                    leax      -$01,x
                    bne       L313E
                    inc       <u007A
                    lda       #$10
                    sta       >$059D
                    ldx       #$0006
L315A               pshs      x
                    lda       #$08
                    adda      >$059D
                    bsr       L316A
                    puls      x
                    leax      -$01,x
                    bne       L315A
                    rts

L316A               sta       >$059D
                    lbsr      L30E8
                    lda       <u007A
                    lbsr      L3110
                    ldy       >$0CC5
                    lbsr      L35CD
                    ldd       >$0CC5
                    addd      >$0CC7
                    std       >$0CC5
                    lbsr      pollkybd
                    ldx       #$0014
                    lbra      L5819
L318E               ldd       #$0400
                    std       >$0CC5
                    ldd       #$FFD0
                    std       >$0CC7
                    ldx       #$0009
L319D               pshs      x
                    lda       >$059D
                    suba      >$13F9,x
                    bsr       L316A
                    puls      x
                    leax      -$01,x
                    bne       L319D
                    dec       <u007A
                    lda       #$70
                    sta       >$059D
                    ldx       #$0006
L31B8               pshs      x
                    lda       >$059D
                    suba      #$08
                    lbsr      L316A
                    puls      x
                    leax      -$01,x
                    bne       L31B8
                    rts

L31C9               ldb       #$FF
L31CB               incb
                    suba      #$0A
                    bcc       L31CB
                    adda      #$0A
                    sta       <u00D0
                    lslb
                    lslb
                    lslb
                    lslb
                    orb       <u00D0
                    tfr       b,a
                    rts

L31DD               clra
                    ldb       <u007A
                    tfr       d,x
                    lsrb
                    addb      #$02
                    cmpb      #$14
                    bcs       L31EB
                    ldb       #$14
L31EB               tfr       b,a
                    pshs      a
                    sta       >$0106
                    lbsr      L31C9
                    sta       >$010A
                    puls      a
                    tfr       a,b
                    lsra
                    inca
                    sta       <u00ED
                    tfr       b,a
                    suba      #$05
                    bpl       L3207
                    clra
L3207               sta       <u00EE
                    tfr       x,d
                    cmpb      #$01
                    bne       L3212
                    clrb
                    bra       L321A
L3212               cmpb      #$2B
                    bcs       L3218
                    ldb       #$2B
L3218               lslb
                    lslb
L321A               stb       <u00F1
                    lsr       <u00D0
                    tfr       x,d
                    cmpb      #$04
                    bcc       L3227
                    clrb
                    bra       L3234
L3227               cmpb      #$23
                    bcs       L322D
                    ldb       #$22
L322D               lslb
                    stb       <u00D0
                    ldb       #$30
                    subb      <u00D0
L3234               stb       <u00EF
                    stb       <u00F0
                    tfr       x,d
                    cmpb      #$28
                    bcs       L3240
                    ldb       #$28
L3240               stb       <u00D0
                    lda       #$2C
                    suba      <u00D0
                    lsra
                    sta       <u00F2
                    tfr       x,d
                    stb       <u00D0
                    lda       #$2A
                    suba      <u00D0
                    bmi       L3258
                    lsra
                    cmpa      #$04
                    bcc       L325A
L3258               lda       #$04
L325A               sta       <u00E9
                    lda       #$1A
                    suba      <u00D0
                    bmi       L3263
                    lsra
L3263               sta       <u00EA
                    bmi       L326B
                    cmpa      #$02
                    bcc       L326D
L326B               lda       #$02
L326D               cmpa      #$08
                    bcs       L3275
                    lda       #$FF
                    bra       L327A
L3275               lsla
                    lsla
                    lsla
                    lsla
                    lsla
L327A               sta       <u00EB
                    tfr       x,d
                    lsrb
                    lsrb
                    addb      #$05
                    stb       <u00EC
                    lsr       <u00D0
                    lsr       <u00D0
                    lda       #$08
                    suba      <u00D0
                    bpl       L328F
                    clra
L328F               sta       <u00F3
                    tfr       x,d
                    cmpb      #$10
                    bcs       L32A3
                    subb      #$10
                    cmpb      #$18
                    bcs       L329F
                    ldb       #$17
L329F               stb       >$0115
                    clrb
L32A3               stb       <u00E7
                    rts

L32A6               clr       <u00D2
L32A8               inc       <u00F7
                    lda       <u00D2
                    adda      #$01
                    daa
                    sta       <u00D2
                    lda       <u00F7
                    cmpa      <u007A
                    bne       L32A8
                    rts

L32B8               lda       >$010A
                    adda      #$99
                    daa
                    sta       >$010A
L32C1               lbsr      L41FD
                    lda       #$02
                    lbsr      L3600
                    lbra      L03F3
L32CC               lbsr      L31C9
                    sta       >$010A
                    lbra      L03F9
L32D5               lbsr      L3351
                    lda       >$010E
                    beq       L32E4
                    clr       >$010E
                    lda       #$0B
                    bra       L32E6
L32E4               lda       #$0D
L32E6               lbsr      L3600
                    tst       >$0127
                    beq       L3309
                    lbsr      L330A
                    lbsr      L3400
                    ldy       #$0024
                    lda       #$11
                    ldb       #$00
                    lbsr      L2B14
                    lda       #$0D
                    lbsr      L3600
                    lda       >button
                    beq       L32D5
L3309               rts

L330A               lbsr      L3341
L330D               inc       >$0CF4
                    ldy       #$001F
                    lda       #$11
                    ldb       #$00
                    lbsr      L2B14
                    clr       >$0CF4
                    ldy       #$0020
                    lda       #$77
                    ldb       #$00
                    lbsr      L2B14
                    ldy       #$0025
                    lda       #$99
                    ldb       #$00
L3331               pshs      y,b,a
                    lbsr      L2B14
                    puls      y,b,a
                    leay      $01,y
                    cmpy      #$002C
                    bls       L3331
                    rts

L3341               ldu       >$0CBF              screen address
                    ldx       #$1E00
                    ldd       #$0000
L334A               std       ,u++
                    leax      -$01,x
                    bne       L334A
                    rts

L3351               lbsr      L3341
                    lda       #$0A
                    sta       >$113F
                    lda       #$04
                    sta       >$1140
                    inc       >$0CF4
                    ldy       #$0019
                    lda       #$77
                    ldb       #$00
                    lbsr      L2B14
                    clr       >$0CF4
                    ldy       #$001A
                    lda       #$11
                    ldb       #$00
                    lbsr      L2B14
                    ldx       #$11A2
                    lda       >$0CF5
                    lbsr      L3570
                    lda       >$0CF6
                    lbsr      L3570
                    lda       >$0CF7
                    lbsr      L3570
                    lda       >$0CF8
                    lbsr      L3570
                    ldx       #$11A2
                    lbsr      L33DD
                    ldx       #$11B9
                    lda       >$0CFE
                    lbsr      L3570
                    lda       >$0CFF
                    lbsr      L3570
                    lda       >$0D00
                    lbsr      L3570
                    lda       >$0D01
                    lbsr      L3570
                    ldx       #$11B9
                    lbsr      L33DD
                    ldy       #$001D
                    lda       #$99
                    ldb       #$00
                    lbsr      L2B14
                    ldy       #$001E
                    lda       #$99
                    ldb       #$00
                    lbsr      L2B14
                    ldy       #$0024
                    lda       #$11
                    ldb       #$00
                    lbra      L2B14
L33DD               ldb       #$07
L33DF               lda       ,x
                    cmpa      #$30
                    bne       L33EC
                    lda       #$20
                    sta       ,x+
                    decb
                    bne       L33DF
L33EC               rts

                    lbsr      L32D5
                    lbsr      L3351
                    lda       #$8C
                    sta       >$0118
                    lbsr      L4221
                    lda       <u007A
                    lbra      L3110
L3400               lda       >$0127
                    beq       L3465
                    lbsr      L3528
                    ldx       #$0025
L340B               ldb       >rofvbuf,x
                    lda       >$0F70,x
                    addd      #$0002
                    tfr       d,u
                    stu       <u0027
                    leau      u000C,u
                    ldy       #$000C
L3420               lda       >$12D4,y
                    cmpa      ,u
                    beq       L3451
                    bcs       L345B
                    lda       #$05
                    lbsr      L3600
                    lbsr      L3582
                    pshs      x
                    lbsr      L330D
                    puls      x
                    clr       >$0127
                    ldu       <u0027
                    leau      <u0014,u
                    ldy       #$0014
L3445               lda       >$12D3,y
                    sta       ,-u
                    leay      -$01,y
                    bne       L3445
                    bra       L3466
L3451               leau      u0001,u
                    leay      $01,y
                    cmpy      #$0014
                    bcs       L3420
L345B               leax      $01,x
                    cmpx      #$002C
                    bcs       L340B
                    clr       >$0127
L3465               rts

L3466               lda       >$0F70,x
                    ldb       >rofvbuf,x
                    addd      #$0002
                    tfr       d,u
                    tfr       x,d
                    subb      #$25
                    pshs      u,b
                    lda       #$01
                    lbsr      L3600
                    puls      u,b
                    stb       >$0527
                    ldy       #$0000
L3487               lda       #$5F
                    sta       ,u
                    lbsr      L3500
                    lda       #$20
                    sta       ,u
L3492               lbsr      L4019
                    bcs       L3492
                    lbsr      readch
                    cmpa      #$FF
                    beq       L3514
                    cmpa      #$60
                    bcs       L34A4
                    anda      #$5F
L34A4               cmpa      #$08
                    beq       L3514
                    cmpa      #$0D
                    beq       L34D9
                    cmpy      #$0008
                    beq       L3487
                    cmpa      #$20
                    beq       L34CA
                    cmpa      #$21
                    beq       L34CA
                    cmpa      #$2E
                    beq       L34CA
                    cmpa      #$27
                    bne       L34C6
                    lda       #$27
                    bra       L34CA
L34C6               cmpa      #$41
                    bcs       L3487
L34CA               sta       ,u
                    lbsr      L3500
                    leau      u0001,u
                    leay      $01,y
                    cmpy      #$0009
                    bcs       L3487
L34D9               lbsr      L3500
                    lda       >$0D02              load A with last byte of scores file
                    sta       >$12D4              save in buffer
                    lda       >$0CFA
                    cmpa      >$0D02
                    bcs       wrscores
                    sta       >$0D02
                    sta       >$12D4

* write high scores out to file
wrscores            leax      >scores,pcr         point to scores file
                    ldu       #scorebuf           address of scores buffer
                    ldy       #$00B9              bytes to write
                    lda       #$02                routine (2)
                    lbra      routines            do routine!

L3500               pshs      u,y
                    clra
                    ldb       >$0527
                    addd      #$0025
                    tfr       d,y
                    lda       #$99
                    ldb       #$00
                    lbsr      L2B14
                    puls      pc,u,y
L3514               cmpy      #$0000
                    beq       L351E
                    leau      -u0001,u
                    leay      -$01,y
L351E               lda       #$A0
                    sta       ,u
                    lbsr      L3500
                    lbra      L3487
L3528               ldx       #$0014
                    lda       #$20
L352D               sta       >$12D3,x
                    leax      -$01,x
                    bne       L352D
                    lda       >$012E
                    beq       L354F
                    lbsr      L31C9
                    ldx       #$12DD
                    lbsr      L3570
                    lda       >$12DD
                    cmpa      #$30
                    bne       L354F
                    lda       #$20
                    sta       >$12DD
L354F               lda       >$0CF5
                    ldx       #$12E0
                    lbsr      L3570
                    lda       >$0CF6
                    lbsr      L3570
                    lda       >$0CF7
                    lbsr      L3570
                    lda       >$0CF8
                    lbsr      L3570
                    ldx       #$12E0
                    lbra      L33DD
L3570               sta       <u00D0
                    lsra
                    lsra
                    lsra
                    lsra
                    lbsr      L357D
                    lda       <u00D0
                    anda      #$0F
L357D               adda      #$30
                    sta       ,x+
L3581               rts

L3582               tfr       x,d
                    stb       <u00C7
                    ldx       #$002C
L3589               tfr       x,d
                    cmpb      <u00C7
                    beq       L3581
                    ldb       >rofvbuf,x
                    lda       >$0F70,x
                    addd      #$0002
                    tfr       d,u
                    leax      -$01,x
                    ldb       >rofvbuf,x
                    lda       >$0F70,x
                    addd      #$0002
                    tfr       d,y
                    pshs      x
                    ldx       #$000A
L35B0               ldd       ,y++
                    std       ,u++
                    leax      -$01,x
                    bne       L35B0
                    puls      x
                    bra       L3589

L35BC               pshs      u,y,x,b,a,cc
                    ldy       #$0200              frequency
                    ldx       #$7001
                    ldd       #(stdout*256)+SS.Tone
                    os9       I$SetStt
                    puls      pc,u,y,x,b,a,cc

* Y = frequency
L35CD               pshs      u,y,x,b,a,cc
                    ldx       #$7002
                    ldd       #(stdout*256)+SS.Tone
                    os9       I$SetStt
                    puls      pc,u,y,x,b,a,cc

* Y = frequency
L35DA               pshs      u,y,x,b,a,cc
                    ldx       #$7001
                    ldd       #(stdout*256)+SS.Tone
                    os9       I$SetStt
                    puls      pc,u,y,x,b,a,cc

L35E7               ldb       #$03
L35E9               bsr       L35EF
                    decb
                    bpl       L35E9
                    rts

L35EF               pshs      u,y,x,b,a,cc
                    ldy       #$0500              frequency
                    ldx       #$7001
                    ldd       #(stdout*256)+SS.Tone
                    os9       I$SetStt
                    puls      pc,u,y,x,b,a,cc

L3600               pshs      u,y,x,b
                    sta       >$0CED
                    lsla
                    leay      >L3682,pcr
                    ldd       a,y
                    leau      d,y
                    stu       >$0CEE
                    clr       >button
                    bra       L3619
L3616               clr       >$0CED
L3619               ldu       >$0CEE
L361C               lda       >$0CED
                    beq       L3625
                    cmpa      #$0D
                    bne       L3644
L3625               pshs      u
                    lbsr      getjoyxy
                    puls      u
                    tst       >button
                    bne       L3670
                    lda       >$0CED
                    cmpa      #$0D
                    beq       L3644
                    tst       >$05F8
                    beq       L3644
                    lda       >$05A4
                    cmpa      #$00
                    bne       L3670
L3644               inc       <u0033
                    ldy       ,u
                    beq       L3672
                    cmpy      #$0001
                    beq       L366B
                    cmpy      #$0002
                    beq       L3616
                    lda       #$70
                    ldb       u0002,u
                    tfr       d,x
                    pshs      u
                    ldd       #$0198              SS.Tone
                    os9       I$SetStt
                    puls      u
L3667               leau      u0003,u
                    bra       L361C
L366B               lda       >$0CED
                    beq       L3619
L3670               puls      pc,u,y,x,b
L3672               ldb       u0002,u
                    beq       L3667
L3676               ldx       #$0320
L3679               leax      -$01,x
                    bne       L3679
                    decb
                    bne       L3676
                    bra       L3667

L3682
                    fdb       $001c,$00f0,$00f5,$00fa,$00fa,$00ff,$011c
                    fdb       $00f0,$00f0,$00fa,$00fa,$012a,$00fa,$001c,$0e1d
                    fdb       $180e,$bd04,$0e1d,$040e,$8110,$0e1d,$100e,$8118
                    fdb       $0e1d,$040e,$8104,$0ebd,$2000,$0002,$0ebd,$180e
                    fdb       $8104,$0ebd,$040f,$0010,$0e00,$100e,$8118,$0e00
                    fdb       $040e,$8104,$0ebd,$200e,$8118,$0e00,$040e,$8104
                    fdb       $0ebd,$100e,$8110,$0ebd,$180e,$8104,$0ebd,$040f
                    fdb       $0020,$0000,$020f,$0018,$0ebd,$040f,$0004,$0f29
                    fdb       $100e,$5210,$0f00,$300f,$000c,$0ebd,$040e,$e118
                    fdb       $0e96,$040e,$e104,$0f0e,$180e,$bd08,$0ee1,$180e
                    fdb       $9604,$0ee1,$040f,$0e20,$0ee1,$180e,$9604,$0ee1
                    fdb       $040f,$2910,$0ebd,$100f,$0e18,$0ebd,$040f,$0e04
                    fdb       $0f40,$200e,$e118,$0e96,$040e,$e104,$0f0e,$180e
                    fdb       $bd08,$0ee1,$180e,$9604,$0ee1,$040f,$0e20,$0ee1
                    fdb       $180e,$9604,$0ee1,$040f,$2910,$0ebd,$100f,$4040
                    fdb       $0001,$0ef1,$0200,$0102,$0002,$0001,$0300,$0200
                    fdb       $010d,$7b10,$0de2,$050d,$c205,$0de2,$050e,$6a10
                    fdb       $0ebd,$100e,$d018,$0e6a,$080e,$1d20,$0001,$0f5f
                    fdb       $010f,$7001,$0f78,$010f,$8001,$0001,$0d2c,$100d
                    fdb       $c210,$0da0,$080d,$c208,$0d2c,$100d,$c210,$0da0
                    fdb       $100d,$7b10,$0da0,$100d,$2c10,$0000,$020d,$2c10
                    fdb       $0000,$020d,$2c10,$0000,$0c0e,$5204,$0e38,$2000
                    fdb       $0020,$0001,$0f5f,$0400
                    fcb       $01

L37E9
                    fdb       $171f
                    ldb       <u007F
                    ror       <u0017
                    clr       >$089B
                    lda       #$0E
                    sta       >$087C
                    lda       #$02
                    sta       >$0909
                    sta       >$010C
                    lda       #$CC
                    sta       <u0072
                    lda       #$78
                    sta       <u0041
                    lda       #$4F
                    sta       <u0047
                    lda       #$0F
                    sta       >$0113
                    lbsr      L03F9
                    lda       #$FF
                    sta       <u0071
                    sta       >$0886
                    sta       <u007E
                    sta       <u0083
                    lda       #$C0
                    sta       <u0060
                    lbsr      L3866
                    lbsr      L03F9
                    lda       #$05
                    sta       >$09A2
                    clr       >$09A3
                    lbsr      L3A13
                    lbsr      L03F9
                    clra
                    lbsr      L0DE9
                    lbsr      L0E2A
                    lbsr      L03F9
                    lda       #$F4
                    sta       <u003E
                    lda       #$05
                    ldy       #$0007
L384A               sta       >$0927,y
                    leay      -$01,y
                    bne       L384A
                    lbsr      L56E2
                    cmpa      #$20
                    bcc       L385B
                    inc       <u004A
L385B               lda       #$07
                    sta       >$0112
                    sta       >$09A4
                    lbra      L3E78
L3866               lda       #$66
                    ldb       #$00
                    sta       >$0559
                    stb       >$0558
                    ldy       #$1334
                    ldb       #$08
L3876               clr       >$00A8,y
                    clr       >$0090,y
                    clr       <$78,y
                    clr       <$60,y
                    clr       <$48,y
                    clr       <$30,y
                    clr       <$18,y
                    clr       ,y+
                    decb
                    bne       L3876
                    lda       #$F0
                    ldb       >$089B
                    lsrb
                    bcc       L389B
                    coma
L389B               anda      #$11
                    ldy       #$13DC
                    ldb       #$08
L38A3               sta       ,y+
                    decb
                    bne       L38A3
                    ldy       #$13C4
                    ldb       >$089B
                    beq       L38B7
                    cmpb      #$03
                    beq       L38B7
                    leay      $01,y
L38B7               sta       ,y
                    sta       $02,y
                    sta       $04,y
                    sta       $06,y
                    sta       <-$18,y
                    sta       <-$14,y
                    ldb       >$087C
                    incb
                    andb      #$03
                    lslb
                    lslb
                    addb      >$089B
                    clra
                    ldu       #$1348
                    leau      d,u
                    ldb       >$087C
                    lslb
                    ldy       #$1308
                    ldd       b,y
                    cmpb      #$FF
                    beq       L38F1
                    pshs      b
                    ldb       >$089B
                    cmpb      #$03
                    bne       L38EF
                    lda       ,s
L38EF               puls      b
L38F1               lsla
                    ldy       #$1328
                    ldx       a,y
                    ldy       #$13F6
                    lda       #$07
                    sta       <u00B3
L3900               ldb       #$03
                    lda       ,x+
                    sta       >$055B
                    lbsr      L2B84
                    leau      <u0015,u
                    dec       <u00B3
                    bne       L3900
                    ldy       #$1334
                    ldu       >scrnaddr           screen address
                    leau      >u0484,u
                    ldx       #$0008
L391F               ldd       ,y++
                    std       ,u++
                    ldd       ,y++
                    std       ,u++
                    ldd       ,y++
                    std       ,u++
                    ldd       ,y++
                    std       ,u++
                    leay      <$10,y
                    leau      <u0048,u
                    leax      -$01,x
                    bne       L391F
L3939               rts

L393A               clr       <u00CE
                    clr       <u00D4
                    lda       >$010B
                    pshs      a
                    cmpa      #$01
                    bcs       L395A
                    cmpa      #$03
                    bcc       L395A
                    anda      <u005D
                    bne       L395A
                    lda       <u007E
                    cmpa      #$00
                    beq       L395A
                    lda       #$07
                    lbsr      L3600
L395A               puls      a
                    cmpa      >$0111
                    beq       L3977
                    sta       >$0111
                    lda       #$07
                    lbsr      L3600
                    lda       >$0111
                    ldb       #$47
                    stb       <u00CA
                    ldb       #$85
                    stb       <u00CB
                    lbsr      L39DA
L3977               lda       >$0109
                    cmpa      >$010F
                    beq       L3995
                    sta       >$010F
                    ldb       #$48
                    stb       <u00CC
                    ldb       #$9B
                    stb       <u00CD
                    ldb       #$45
                    stb       <u00CA
                    ldb       #$95
                    stb       <u00CB
                    lbsr      L39CB
L3995               lda       >$0107
                    beq       L39A2
                    lda       #$0C
                    anda      <u005D
                    bne       L39A2
                    dec       <u00CE
L39A2               lda       >$010A
                    ora       <u00CE
                    cmpa      >$0110
                    lbeq      L3939
                    sta       >$0110
                    lda       >$010A
                    ldb       #$46
                    stb       <u00CC
                    ldb       #$AC
                    stb       <u00CD
                    ldb       #$43
                    stb       <u00CA
                    ldb       #$A4
                    stb       <u00CB
                    ldb       >$0107
                    beq       L39CB
                    dec       <u00D4
L39CB               pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    lbsr      L39DC
                    ldd       <u00CC
                    std       <u00CA
                    lda       ,s+
L39DA               anda      #$0F
L39DC               adda      #$30
                    tst       <u00CE
                    beq       L39E4
                    lda       #$20
L39E4               sta       >$11F2
                    ldb       <u00CA
                    stb       >$11F0
                    ldb       <u00CB
                    stb       >$11F1
                    lda       #$09
                    sta       >$0CF1
                    ldd       #$3ECE
                    std       >$0CF2
                    lda       #$66
                    ldb       #$00
                    ldy       #$0021
                    lbsr      L2B14
                    lda       #$07
                    sta       >$0CF1
                    ldd       #$3D9A
                    std       >$0CF2
                    rts

L3A13               lda       >$09A2
                    ldb       >$09A3
                    cmpa      >$08F5
                    bne       L3A25
                    cmpb      >$08F7
                    lbeq      L3ABA
L3A25               ldy       #$3734
                    sta       >$08F5
                    stb       >$08F7
                    bpl       L3A32
                    clrb
L3A32               cmpb      #$1C
                    bls       L3A38
                    ldb       #$1C
L3A38               stb       <u00B3
                    beq       L3A41
                    lda       #$77
                    lbsr      L3ABB
L3A41               ldb       #$1C
                    subb      <u00B3
                    beq       L3A4C
                    lda       #$99
                    lbsr      L3ABB
L3A4C               ldb       <u00B3
                    beq       L3AB8
                    decb
                    lda       #$08
                    mul
                    addd      #$3734
                    tfr       d,y
                    lda       >$09A2
                    cmpa      #$05
                    beq       L3AB8
                    ldb       #$10
                    mul
                    addd      #$3814
                    tfr       d,x
                    ldb       #$08
                    pshs      b
L3A6C               ldb       ,x+
                    beq       L3AAE
                    pshs      y
                    cmpb      <u00B3
                    bls       L3A78
                    ldb       <u00B3
L3A78               lda       #$0F
                    anda      ,y
                    pshs      a
                    lda       #$99
                    anda      #$F0
                    ora       ,s+
                    sta       ,y
                    leay      -$08,y
                    decb
                    bne       L3A78
                    puls      y
                    ldb       ,x+
                    beq       L3AAE
                    pshs      y
                    cmpb      <u00B3
                    bls       L3A99
                    ldb       <u00B3
L3A99               lda       #$F0
                    anda      ,y
                    pshs      a
                    lda       #$99
                    anda      #$0F
                    ora       ,s+
                    sta       ,y
                    leay      -$08,y
                    decb
                    bne       L3A99
                    puls      y
L3AAE               leay      $01,y
                    dec       ,s
                    lbne      L3A6C
                    puls      b
L3AB8               bra       L3B17
L3ABA               rts

L3ABB               sta       ,y+
                    sta       ,y+
                    sta       ,y+
                    sta       ,y+
                    sta       ,y+
                    sta       ,y+
                    sta       ,y+
                    sta       ,y+
                    decb
                    bne       L3ABB
                    rts

L3ACF               ldu       >scrnaddr           screen address
                    leau      >u2A02,u
                    ldx       #$336C
                    ldy       #$34E0
                    lda       #$1F
                    ldb       #$0C
                    lbra      L3B29
L3AE4               ldu       >scrnaddr           screen address
                    leau      >u26F7,u
                    ldx       #$38C4
                    ldy       #$39A4
                    lda       #$1C
                    ldb       #$08
                    lbra      L3B29
L3AF9               ldy       #$3734
                    bsr       L3B0A
                    bra       L3B17
                    ldy       #$39A4
                    bsr       L3B0A
                    lbra      L3AE4
L3B0A               ldx       #$0070
                    ldd       #$7777
L3B10               std       ,y++
                    leax      -$01,x
                    bne       L3B10
                    rts

L3B17               ldu       >scrnaddr           screen address
                    leau      >u26D1,u
                    ldx       #$3654
                    ldy       #$3734
                    lda       #$1C
                    ldb       #$08
L3B29               sta       <u00B3
                    stb       <u00C7
L3B2D               pshs      u
                    ldb       <u00C7
L3B31               lda       ,u
                    anda      ,x
                    pshs      a
                    lda       ,x+
                    coma
                    anda      ,y+
                    ora       ,s+
                    sta       ,u+
                    decb
                    bne       L3B31
                    puls      u
                    leau      <u0050,u
                    dec       <u00B3
                    bne       L3B2D
                    rts

L3B4D               lda       #$77
                    clrb
                    bra       L3B5A
L3B52               pshs      b
                    lbsr      L5738
                    puls      b
                    incb
L3B5A               cmpb      >$087B
                    bcs       L3B52
                    cmpb      >$087A
                    bcc       L3B73
                    lda       #$DD
L3B66               pshs      b
                    lbsr      L5738
                    puls      b
                    incb
                    cmpb      >$087A
                    bcs       L3B66
L3B73               lda       #$EE
L3B75               pshs      b
                    lbsr      L5738
                    puls      b
                    incb
                    cmpb      #$3A
                    bcs       L3B75
                    rts

L3B82               lda       <u007B
                    cmpa      #$01
                    bcs       L3BA2
                    dec       <u007B
                    bne       L3B97
                    lda       #$0F
                    sta       <u007B
                    lda       #$77
                    sta       >$0177
                    bra       L3BA2
L3B97               lda       <u007B
                    cmpa      #$0A
                    bcc       L3BA2
                    lda       #$88
                    sta       >$0177
L3BA2               lda       <u004C
                    beq       L3BAA
L3BA6               dec       <u004C
                    bra       L3BC0
L3BAA               lda       #$08
                    suba      <u007C
                    lsra
                    tst       <u004F
                    bne       L3BB4
                    inca
L3BB4               adda      >$08FA
                    adca      >$08AD
                    sta       >$08AD
                    bcs       L3BC0
                    rts

L3BC0               tst       <u00FB
                    beq       L3BC6
                    dec       <u00FB
L3BC6               bne       L3BF0
                    tst       <u0036
                    beq       L3BDD
                    lda       <u007E
                    cmpa      #$02
                    beq       L3BDD
                    lda       #$10
                    lbsr      L3E94
                    lda       #$32
                    sta       <u0036
                    bra       L3BDF
L3BDD               inc       <u00FB
L3BDF               lda       <u004C
                    ora       >$08FA
                    cmpa      #$01
                    bcs       L3BF0
                    sta       >$010E
                    clr       <u00FB
                    lbsr      L0ACA
L3BF0               lbsr      L3C21
                    lsra
                    lsra
                    lsra
                    pshs      a
                    tfr       a,b
                    lda       #$77
                    lbsr      L5747
                    puls      b
                    cmpb      >$0615
                    beq       L3C20
                    stb       >$0615
                    clra
                    tfr       d,x
                    lda       >$3C0F,x
                    sta       >$0177
                    leay      $01,y
L3C15               lbsr      L5747
                    leay      $01,y
                    cmpy      #$00B4
                    bls       L3C15
L3C20               rts

L3C21               ldb       #$E0
                    subb      <u00FB
                    lsrb
                    lsrb
                    pshs      b
                    addb      #$7B
                    clra
                    tfr       d,y
                    lda       ,s+
                    rts

L3C31               ldx       #$003A
                    bra       L3C5F
L3C36               stx       <u0023
                    lbsr      L5712
                    ldx       <u0023
L3C3D               lda       #$01
                    sta       <u005F
                    lda       #$04
                    adda      <u00FB
                    cmpa      #$E0
                    bcs       L3C5A
                    clr       <u005F
                    lda       #$66
                    pshs      y
                    ldy       #$007B
                    lbsr      L5747
                    puls      y
                    lda       #$E0
L3C5A               sta       <u00FB
                    lbsr      L03CE
L3C5F               lbsr      L3C21
                    pshs      a
                    lda       >$0177
                    leay      $01,y
                    lbsr      L5747
                    ldb       ,s+
                    lsrb
                    lsrb
                    lsrb
                    cmpb      #$06
                    bcc       L3C77
                    clr       <u007B
L3C77               leax      -$01,x
                    bne       L3C3D
                    rts

L3C7C               lda       <u0084
                    bpl       L3C9A
                    cmpa      #$81
                    bcc       L3CC4
                    dec       <u00E8
                    bpl       L3CBE
                    lbsr      L56E2
                    anda      #$07
                    sta       <u00E8
                    cmpa      #$06
                    lbcs      L3D1E
                    anda      #$03
                    lbra      L3D1E
L3C9A               bne       L3CA7
                    sta       <u005A
                    inc       <u0084
                    lda       <u00E9
                    sta       <u00E8
                    lbra      L3CE2
L3CA7               dec       <u00E8
                    bpl       L3CBE
                    ldb       <u00E9
                    stb       <u00E8
                    cmpa      #$07
                    bne       L3CBF               screen address
                    lda       <u005A
                    bne       L3CBE
                    lda       #$01
                    sta       <u005A
                    sta       >$095E
L3CBE               rts

L3CBF               deca
                    inc       <u0084
                    bra       L3CD7
L3CC4               lsr       <u00FC
                    bcs       L3CBE
                    inc       <u00FC
                    anda      #$0F
                    cmpa      #$07
                    bcs       L3CD4
                    lda       #$06
                    dec       <u0084
L3CD4               dec       <u0084
                    deca
L3CD7               pshs      a
                    lda       #$08
                    lbsr      L3600
                    puls      a
                    bra       L3D1E
L3CE2               ldx       #$3C47
                    ldb       #$05
                    lda       #$EE
L3CE9               sta       b,x
                    decb
                    bpl       L3CE9
L3CEE               ldu       >scrnaddr           screen address
                    leau      >u37CC,u
                    ldx       #$3C47
                    ldb       #$05
L3CFA               lda       b,x
                    sta       ,u
                    sta       <u0050,u
                    sta       >u00A0,u
                    anda      #$F0
                    pshs      a
                    lda       #$00
                    anda      #$0F
                    ora       ,s+
                    sta       u0001,u
                    sta       <u0051,u
                    sta       >u00A1,u
                    leau      -u0002,u
                    decb
                    bpl       L3CFA
                    rts

L3D1E               ldx       #$3C47
                    ldb       a,x
                    cmpb      #$EE
                    bne       L3D2B
                    ldb       #$DD
                    bra       L3D2D
L3D2B               ldb       #$EE
L3D2D               stb       a,x
                    bra       L3CEE
L3D31               lbsr      L56E2
                    anda      #$07
                    cmpa      #$06
                    bcs       L3D1E
                    anda      #$03
                    bra       L3D1E
L3D3E               sta       <u0025
                    ldb       <u0025
                    cmpb      #$03
                    bcs       L3D4F
                    lda       #$0C
                    sta       >$0883
                    lda       #$6C
                    bra       L3D75
L3D4F               clra
                    tfr       d,y
                    lda       >$3C4D,y
                    sta       >$0883
                    lda       >$0884
                    cmpa      #$8B
                    bcs       L3D62
                    lda       #$8C
L3D62               suba      #$55
                    bpl       L3D67
                    clra
L3D67               lsra
                    lsra
                    cmpy      #$0081
                    bcc       L3D73
                    lda       #$5E
                    bra       L3D75
L3D73               lda       #$54
L3D75               sta       <u00CE
                    lda       <u0025
                    bpl       L3D7E
                    dec       <u0072
                    rts

L3D7E               lda       >$0884
                    adda      >$0883
                    cmpa      #$D0
                    bcs       L3D89
                    clra
L3D89               sta       >$0157
                    lbeq      L3DE5
                    adda      #$20
                    cmpa      #$D0
                    bls       L3D98
                    lda       #$D0
L3D98               sta       >$0159
                    lda       >$0881
                    adda      #$50
                    cmpa      #$AF
                    bcs       L3DA5
                    clra
L3DA5               sta       >$0158
                    beq       L3DE5
                    pshs      a
                    suba      #$50
                    lsra
                    lsra
                    sta       >$08AB
                    puls      a
                    adda      #$20
                    cmpa      #$AF
                    bls       L3DBD
                    lda       #$AF
L3DBD               sta       >$015A
                    lda       <u0071
                    lsra
                    lsra
                    lsra
                    leay      >L5AC9,pcr
                    lda       a,y
                    sta       >$015D
                    ldd       #$2CC6
                    std       >$015B
                    ldx       #$2CE7
                    ldy       #$0157
                    lbsr      L2978
                    ldy       #$0E00
                    lbsr      L35DA
L3DE5               lda       >$0883
                    adda      >$0884
                    cmpa      #$8E
                    bcs       L3DF3
                    lda       #$8D
                    bra       L3DF9
L3DF3               cmpa      #$6C
                    bcc       L3DF9
                    lda       #$6C
L3DF9               sta       >$08AC
                    lda       #$FF
                    sta       >$089E
                    lbra      L3EA1
L3E04               ldb       <u007D
                    lsrb
                    clra
                    tfr       d,y
L3E0A               cmpy      #$0009
                    bcs       L3E16
                    lda       #$08
                    cmpa      <u00FA
                    beq       L3E38
L3E16               tfr       y,d
                    cmpb      <u00FA
                    beq       L3E38
                    stb       <u00FA
                    stb       <u00CE
                    lda       #$FF
                    sta       <u00CD
                    lda       #$07
                    sta       <u00CC
L3E28               tfr       a,b
                    clra
                    tfr       d,x
                    lbsr      L3E39
                    dec       <u00CC
                    lda       <u00CC
                    cmpa      <u00CD
                    bne       L3E28
L3E38               rts

L3E39               ldy       #$3C76
                    tfr       x,d
                    cmpb      <u00CE
                    bcc       L3E47
                    ldy       #$3C7E
L3E47               cmpb      #$10
                    bcs       L3E4E
                    leay      <$10,y
L3E4E               ldb       >$3C63,x
                    ldu       #$0D03
                    clra
                    lslb
                    rola
                    ldu       d,u
                    ldb       >$3C50,x
                    leau      b,u
                    ldd       ,y++
                    std       ,u
                    ldd       ,y++
                    std       <u0050,u
                    ldd       ,y++
                    std       >u00A0,u
                    ldd       ,y++
                    std       >u00F0,u
                    rts

L3E76               lda       <u007C
L3E78               sta       <u007C
                    pshs      a
                    cmpa      #$08
                    bne       L3E83
                    clra
                    bra       L3E8E
L3E83               adda      <u00F3
                    tfr       a,b
                    clra
                    tfr       d,y
                    lda       >$3C96,y
L3E8E               sta       <u0036
                    puls      a
L3E92               adda      #$08
L3E94               sta       <u00CE
                    lda       #$07
                    sta       <u00CD
                    lda       #$0F
                    sta       <u00CC
                    lbra      L3E28
L3EA1               lbsr      L3F51
                    ldb       >$08AB
                    cmpb      #$1F
                    lbcc      L3F4E
                    lda       >$089E
                    bpl       L3EBD
                    cmpa      #$FF
                    bne       L3EBA
                    lda       #$03
                    bra       L3EC8
L3EBA               clra
                    bra       L3EC8
L3EBD               lda       >$08A0
                    bne       L3EC6
                    lda       #$01
                    bra       L3EC8
L3EC6               lda       #$02
L3EC8               sta       >$089F
                    clr       <u00CA
                    ldb       >$08AC
                    subb      #$6E
                    lbcs      L3F4E
                    cmpb      #$1D
                    lbcc      L3F4E
                    lsrb
                    subb      #$03
                    bcc       L3EE5
                    negb
                    stb       <u00CA
                    clrb
L3EE5               pshs      b
                    lda       #$0C
                    suba      ,s
                    cmpa      #$04
                    bls       L3EF1
                    lda       #$04
L3EF1               sta       <u00CB
                    lda       #$0C
                    ldb       >$08AB
                    mul
                    addd      #$34E0
                    tfr       d,x
                    puls      b
                    leax      b,x
                    ldb       >$089F
                    ldy       #$3305
                    lda       b,y
                    sta       >$0557
                    lslb
                    ldy       #$3309
                    ldy       b,y
                    ldb       <u00CA
                    leay      b,y
                    ldb       <u00CB
                    subb      <u00CA
                    stb       <u00CB
                    lda       #$1F
                    suba      >$08AB
                    cmpa      #$05
                    bls       L3F2B
                    lda       #$05
L3F2B               sta       <u00CA
L3F2D               pshs      y,x
                    ldb       <u00CB
L3F31               lda       ,y
                    anda      >$0557
                    pshs      a
                    lda       ,y+
                    coma
                    anda      ,x
                    ora       ,s+
                    sta       ,x+
                    decb
                    bne       L3F31
                    puls      y,x
                    leax      $0C,x
                    leay      $04,y
                    dec       <u00CA
                    bne       L3F2D
L3F4E               lbra      L3ACF
L3F51               ldx       #$0174
                    ldy       #$34E0
                    lda       #$77
L3F5A               sta       ,y+
                    leax      -$01,x
                    bne       L3F5A
                    rts

L3F61               ldd       #$7777
                    ldx       #$0070
                    ldy       #$39A4
L3F6B               std       ,y++
                    leax      -$01,x
                    bne       L3F6B
                    lda       #$1B
                    suba      >$0939
                    bcs       L3FA9
                    ldb       #$08
                    mul
                    addd      #$39A4
                    tfr       d,y
                    ldb       >$0938
                    addb      #$07
                    bmi       L3FA9
                    cmpb      #$0E
                    bhi       L3FA9
                    lda       #$F0
                    lsrb
                    leay      b,y
                    bcc       L3F93
                    coma
L3F93               sta       <u00AB
                    coma
                    anda      #$77
                    pshs      a
                    lda       #$99
                    anda      <u00AB
                    ora       ,s+
                    sta       ,y
                    ldb       >$0939
                    beq       L3FA9
                    sta       $08,y
L3FA9               lbra      L3AE4
L3FAC               lbsr      L252D
                    ldb       #$36
                    subb      >$0896
                    lda       >$0896
                    lsra
                    ldu       #$161A
                    leau      a,u
                    lsrb
                    bcc       L3FC9
                    lda       #$0F
                    anda      #$99
                    sta       <u0042,u
                    sta       ,u+
L3FC9               tstb
                    beq       L3FD6
                    lda       #$99
L3FCE               sta       <u0042,u
                    sta       ,u+
                    decb
                    bne       L3FCE
L3FD6               ldb       #$36
                    subb      >$0897
                    ldu       #$163A
                    lsrb
                    pshs      cc
                    tstb
                    beq       L3FEE
                    lda       #$99
L3FE6               sta       <u0042,u
                    sta       ,u+
                    decb
                    bne       L3FE6
L3FEE               puls      cc
                    bcc       L3FFB
                    lda       #$F0
                    anda      #$99
                    sta       <u0042,u
                    sta       ,u
L3FFB               rts

L3FFC               ldu       >scrnaddr           screen address
                    leau      >u0484,u
                    ldx       #$0008
                    ldd       #$0000
L4009               std       ,u
                    std       u0002,u
                    std       u0004,u
                    std       u0006,u
                    leau      <u0050,u
                    leax      -$01,x
                    bne       L4009
                    rts

L4019               pshs      u,y,x
                    inc       <u0033
                    ldd       #SS.Ready
                    os9       I$GetStt
                    puls      pc,u,y,x

* read one character from standard input
readch              pshs      u,y,x
                    ldy       #$0001              one character
                    ldx       #$00E0              at this address
                    lda       #$00                standard input
                    os9       I$Read              read it!
                    ldx       >$0603              load word at $603
                    cmpx      #$0007              is it 7?
                    beq       L403E               branch if so
                    inc       >$0604              else inc value
L403E               lda       <u00E0              load char
                    sta       >$3D64,x            save it
                    puls      pc,u,y,x            return


L4046               tfr       x,d
                    stb       <u005B
                    lda       #$0F
                    sta       <u005E
                    ldy       #$0014
L4052               cmpb      >$3CA5,y
                    beq       L405D
                    leay      -$01,y
                    bne       L4052
                    rts

L405D               leay      -$01,y
                    tfr       y,d
                    lsrb
                    tfr       d,y
                    lda       <u0085
                    bne       L406A
                    lda       #$04
L406A               cmpy      #$0006
                    bne       L4079
L4070               lbsr      L03CD
                    inc       >$0127
                    lbra      L036B
L4079               cmpy      #$0008
                    bne       L408B
                    lda       >$0171
                    eora      #$01
                    sta       >$0171
                    lbra      L57C3
L408A               rts

L408B               lda       <u0085
                    bne       L408A
                    cmpy      #$0007
                    bne       L40A9
                    lda       <u00FE
                    bne       L408A
L4099               lbsr      readch
                    cmpa      #$12
                    beq       L4070
                    cmpa      #$20
                    bne       L4099
                    lda       #$04
                    lbra      L3600
L40A9               ldd       #$0300
                    cmpy      #$0009
                    lbeq      routines
                    tfr       y,d
                    cmpb      <u007E
                    beq       L411A
                    cmpy      #$0003
                    bne       L40F4
                    lda       <u004E
                    cmpa      #$02
                    bcs       L411A
                    lda       #$FF
                    sta       >$0103
                    lda       <u004F
                    bne       L40DF
                    inc       <u004F
                    lda       #$11
                    sta       <u00CE
                    ldx       #$0010
                    lbsr      L3E39
                    lda       #$0F
                    bra       L40F1
L40DF               ldb       #$10
                    stb       <u00CE
                    clra
                    tfr       d,x
                    lbsr      L3E39
                    clr       >$08FC
                    lbsr      L41F4
                    lda       #$0E
L40F1               sta       <u0054
                    rts

L40F4               cmpy      #$0001
                    bne       L4138
                    lda       <u00FD
                    beq       L4106
                    ldy       #$0011
                    lda       #$09
                    bra       L4132
L4106               lda       <u004F
                    beq       L411A
                    lda       <u004D
                    beq       L411B
                    bmi       L411A
                    dec       <u004D
                    lda       #$13
                    ldy       #$000A
                    bra       L4122
L411A               rts

L411B               inc       <u004D
                    clra
                    ldy       #$0001
L4122               sta       <u00CE
                    sty       <u0021
                    ldx       #$0012
                    lbsr      L3E39
                    ldy       <u0021
                    lda       #$06
L4132               lbsr      L3600
                    lbra      L41BE
L4138               cmpy      #$0002
                    lbeq      L41CC
                    lda       <u00FB
                    beq       L411A
                    cmpy      #$0004
                    bne       L4176
                    ldb       #$FF
                    stb       <u007E
                    lda       <u004E
                    beq       L4168
                    lda       >$0912
                    bne       L4159
                    sta       <u0054
L4159               lbsr      L41ED
                    clr       <u0039
                    clr       <u003A
                    lda       #$07
                    lbsr      L3E78
                    lbra      L2B0C
L4168               lda       <u007C
                    lbeq      L2B0C
                    dec       <u007C
                    lbsr      L3E76
                    lbra      L2B0C
L4176               lda       <u004E
                    bne       L411A
                    cmpy      #$0005
                    bne       L4194
                    lda       #$FF
                    sta       <u007E
                    lda       #$06
                    cmpa      <u007C
                    lbcs      L2B0C
                    inc       <u007C
                    lbsr      L3E76
                    lbra      L2B0C
L4194               cmpy      #$0000
                    bne       L41BA
                    lda       <u007D
                    cmpa      #$64
                    bcs       L41AD
                    lda       #$0A
                    lbsr      L3600
                    ldy       #$0005
                    lda       #$FF
                    bra       L41E9
L41AD               lda       #$08
                    lbsr      L3E78
                    lda       #$00
                    ldy       #$0004
                    bra       L41E9
L41BA               tfr       y,d
                    stb       <u007E
L41BE               lda       <u0054
                    sta       <u0053
                    clr       <u0054
                    lda       #$20
                    sta       >$0103
                    lbra      L2B10
L41CC               lda       <u004A
                    bmi       L41DB
                    lda       #$0A
                    lbsr      L3600
                    ldy       #$000D
                    bra       L41EB
L41DB               bsr       L41ED
                    lda       #$F4
                    sta       <u003B
                    lda       #$0C
                    sta       <u003C
                    tfr       y,d
                    tfr       b,a
L41E9               sta       <u007E
L41EB               bra       L41BE
L41ED               tst       >$0898
                    bne       L41F4
                    clr       <u004E
L41F4               clr       <u004F
                    clr       >$0911
                    clr       >$0912
                    rts

L41FD               lda       >$0CF8
                    adda      <u0056
                    daa
                    sta       >$0CF8
                    lda       >$0CF7
                    adca      <u0055
                    daa
                    sta       >$0CF7
                    lda       >$0CF6
                    adca      #$00
                    daa
                    sta       >$0CF6
                    lda       >$0CF5
                    adca      #$00
                    daa
                    sta       >$0CF5
L4221               clr       <u0055
                    clr       <u0056
                    ldx       #$1138
                    lda       >$0CF6
                    lbsr      L2BC1
                    lda       >$0CF7
                    lbsr      L2BC1
                    lda       >$0CF8
                    lbsr      L2BC1
                    lda       #$3C
                    sta       >$1136
                    clr       >$1137
                    ldx       #$1138
                    ldb       #$05
L4247               lda       ,x
                    cmpa      #$30
                    bne       L4254
                    lda       #$20
                    sta       ,x+
                    decb
                    bne       L4247
L4254               ldy       #$0018
                    lbra      L2B10
L425B               clr       >$05FB
                    lda       #$03
                    sta       >$05FC
                    lda       #$01
                    sta       >$05FE
                    nega
                    sta       >$05FF
                    lda       #$80
                    sta       <u0084
                    sta       <u0060
                    sta       >$0898
                    sta       >$08FD
                    lda       <u0083
                    bpl       L4280
                    ldb       #$08
                    bra       L428C
L4280               cmpa      #$08
                    bcs       L4288
                    ldb       #$07
                    bra       L428C
L4288               ldb       #$06
                    inc       <u004E
L428C               stb       <u0054
                    lda       <u004E
                    cmpa      #$03
                    bcs       L42E6
                    clr       >$010B
                    clr       <u0064
                    clr       >$0125
                    lda       <u0083
                    inca
                    sta       <u0063
                    suba      #$13
                    coma
                    lsla
                    sta       >$08FE
                    lda       #$14
                    sta       >$08FF
                    lda       #$0F
                    sta       >$0900
                    sta       >$0179
                    lda       #$80
                    sta       >$0938
                    sta       >$0939
                    sta       <u0083
                    lda       #$01
                    sta       >$087E
                    ldb       >$094E
                    clra
                    tfr       d,x
                    lda       >$02BC,x
                    cmpa      #$80
                    beq       L42D5
                    dec       >$087E
L42D5               inc       <u0052
                    ldb       #$11
                    cmpa      #$C9
                    bne       L42E3
                    lda       #$15
                    sta       <u0054
                    ldb       #$68
L42E3               stb       >$0176
L42E6               lbsr      L4635
                    lbsr      L03ED
                    lda       <u00FD
                    beq       L4307
                    lda       >$019B
                    anda      #$08
                    beq       L4304
                    lda       >$08AA
                    bne       L4307
                    inc       >$08AA
                    lbsr      L4522
                    bra       L4307
L4304               sta       >$08AA
L4307               lda       <u004F
                    bne       L4341
                    tst       <u004D
                    beq       L4312
                    lbsr      L450A
L4312               ldb       <u004E
                    clr       >$0898
                    clr       <u004E
                    clr       <u0052
                    clr       <u0039
                    clr       <u003A
                    cmpb      #$04
                    beq       L4328
                    cmpb      #$03
                    beq       L4328
                    rts

L4328               lda       >$087E
                    bne       L4337
                    lda       #$09
                    sta       <u0054
                    lbsr      L4595
                    lbra      L45F0
L4337               lda       #$16
                    sta       <u0054
                    lbsr      L45DE
                    lbra      L45F0
L4341               lda       <u004E
                    cmpa      #$03
                    bcs       L42E6
                    cmpa      #$04
                    beq       L43C7
                    bhi       L42E6
                    lda       <u0063
                    sta       >$0954
                    lbsr      L56E2
                    sta       <u006B
                    lda       <u0051
                    nega
                    cmpa      #$50
                    bcs       L4363
                    lbsr      L56E2
                    bra       L4364
L4363               clra
L4364               sta       >$094C
L4367               lda       <u0050
                    lsla
                    ror       <u006B
                    lsr       >$094C
                    lsr       >$0954
                    bne       L4367
                    lda       <u0063
                    cmpa      #$01
                    bne       L43B3
                    lda       <u006B
                    ora       #$40
                    sta       <u006B
                    lda       <u0064
                    bne       L43AB
                    lda       <u0051
                    nega
                    cmpa      #$50
                    bcc       L43A7
                    nega
                    sta       >$019B
                    lbsr      L56E2
                    rora
                    lsra
                    lsra
                    adca      >$019B
                    tst       >$087E
                    beq       L439F
                    adca      #$20
L439F               sta       >$019B
                    sta       >$08FD
                    inc       <u004E
L43A7               lda       #$FF
                    bra       L43B0
L43AB               lda       >$094C
                    ora       #$80
L43B0               sta       >$094C
L43B3               lda       <u004E
                    cmpa      #$04
                    beq       L43C7
                    bhi       L43C4
                    lda       <u0053
                    cmpa      #$0F
                    beq       L43C4
                    lbsr      L4688
L43C4               lbra      L42E6
L43C7               lda       >$08FD
                    beq       L43DB
                    lbsr      L56E2
                    anda      #$3F
                    adda      #$40
                    sta       <u005F
                    lbsr      L03CE
                    clr       >$08FD
L43DB               lda       >$087E
                    beq       L43F8
                    lbsr      L03D9
                    lda       <u004D
                    bne       L43F2
                    sta       <u0052
                    sta       >$08FD
                    lbsr      L47C3
                    lbra      L42E6
L43F2               lda       #$80
                    sta       <u004D
                    bra       L4409
L43F8               tst       <u004D
                    bne       L4402
                    lbsr      L442E
                    lbra      L42E6
L4402               lbsr      L03E7
                    lda       #$FF
                    sta       <u004D
L4409               lbsr      L44D4
                    lbsr      L2B0C
                    lbsr      L03E7
                    lda       <u004D
                    cmpa      #$80
                    bne       L4421
                    lbsr      L45D1
                    sta       <u00FD
                    lda       #$10
                    bra       L4426
L4421               lbsr      L4555
                    lda       #$0A
L4426               lbsr      L450C
                    inc       <u004E
                    lbra      L42E6
L442E               dec       >$0179
                    beq       L4434
                    rts

L4434               clr       >$08FD
                    lda       >$0900
                    sta       <u005F
                    lbsr      L03CE
                    clra
                    ldb       >$08FE
                    tfr       d,y
                    bne       L445C
                    dec       >$08FE
                    lda       #$02
                    lbsr      L3600
                    lsl       >$0900
                    lbsr      L03DF
                    lda       #$02
                    lbsr      L3600
                    bra       L44CD
L445C               bpl       L4470
                    lbsr      L4595
                    lda       #$02
                    sta       <u004E
                    ldy       #$0009
                    ldb       #$09
                    stb       <u0054
                    lbra      L41BE
L4470               lbsr      L56E2
                    tfr       a,b
                    andb      #$07
                    cmpb      #$03
                    bcc       L447D
                    orb       #$03
L447D               cmpy      #$0007
                    bcc       L4484
                    lsrb
L4484               clra
                    tfr       d,y
                    tstb
                    bne       L448E
                    leay      $01,y
                    bra       L44AC
L448E               lda       >$0900
                    sta       <u00CA
L4493               lda       <u004D
                    bne       L44AC
                    lda       #$02
                    lbsr      L3600
                    clra
                    ldb       <u00CA
                    tfr       d,x
L44A1               lbsr      L03DF
                    lda       <u004F
                    beq       L44D3
                    leax      -$01,x
                    bne       L44A1
L44AC               lda       >$08FE
                    beq       L44B4
                    dec       >$08FE
L44B4               cmpa      #$0F
                    bcc       L44C6
                    inc       >$0900
                    inc       >$0900
                    lda       >$08FF
                    adda      #$06
                    sta       >$08FF
L44C6               lbsr      L4635
                    leay      -$01,y
                    bne       L4493
L44CD               lda       >$08FF
                    sta       >$0179
L44D3               rts

L44D4               ldy       #$0006
L44D8               lbsr      L4635
                    clra
                    ldb       >$0900
                    tfr       d,x
                    cmpx      #$000A
                    bcc       L44E9
                    ldx       #$000A
L44E9               lbsr      L03E7
                    lda       <u004F
                    beq       L44FE
                    leax      -$01,x
                    bne       L44E9
                    lda       #$0C
                    lbsr      L3600
                    leay      -$01,y
                    bne       L44D8
                    rts

L44FE               lbsr      L4595
                    lda       #$02
                    sta       <u004E
                    lda       #$09
                    sta       <u0054
                    rts

L450A               lda       #$0A
L450C               sta       <u0054
                    lda       #$13
                    sta       <u00CE
                    ldx       #$0012
                    lbsr      L3E39
                    clr       <u004D
                    lbsr      L03F9
                    lda       #$06
                    lbra      L3600
L4522               lbsr      L56E2
                    bpl       L4554
                    anda      #$0F
                    beq       L4543
                    tst       <u004A
                    bmi       L4533
                    ldb       #$0D
                    stb       <u0054
L4533               anda      #$03
                    beq       L4543
                    anda      #$01
                    sta       >$08A3
                    ldb       #$10
                    stb       <u0054
                    lbsr      L1B59
L4543               lda       <u007E
                    cmpa      #$02
                    beq       L454F
                    lda       <u004C
                    adda      #$04
                    sta       <u004C
L454F               lda       #$02
                    lbra      L3600
L4554               rts

L4555               lda       >$010A
                    tst       >$0107
                    bne       L4561
                    adda      #$99
                    bra       L4563
L4561               adda      #$01
L4563               daa
                    sta       >$010A
                    bne       L456C
                    inc       >$0107
L456C               inc       >$0105
                    lda       <u00F8
                    bne       L457A
                    lda       >$0105
                    cmpa      <u00ED
                    bcs       L457D
L457A               lbsr      L45B1
L457D               clr       <u0056
                    lda       #$02
                    ldx       #$0008
                    ldb       >$0176
                    cmpb      #$68
                    bne       L4590
                    ldx       #$0010
                    lda       #$20
L4590               sta       <u0055
                    lbsr      L3C36
L4595               lbsr      L45D1
L4598               ldb       <u00EE
                    beq       L45B0
                    cmpb      #$01
                    bne       L45AB
                    ldy       #$0001
                    lda       #$C9
                    lbsr      L0815
                    bra       L45AE
L45AB               lbsr      L080F
L45AE               dec       <u00EE
L45B0               rts

L45B1               tst       <u004A
                    bmi       L45D0
                    tst       >$08AE
                    bne       L45D0
                    lbsr      L56E2
                    ora       #$08
                    anda      #$3F
                    tst       <u0085
                    bne       L45CC
                    tst       >$0107
                    beq       L45CD
                    lsra
                    lsra
L45CC               lsra
L45CD               sta       >$08AE
L45D0               rts

L45D1               clra
                    ldb       >$094E
                    tfr       d,x
                    lda       #$01
                    sta       >$02BC,x
                    rts

L45DE               lbsr      L45D1
L45E1               ldd       #$0100
                    std       <u0055
L45E6               lda       >$0109
                    adda      #$01
                    daa
                    sta       >$0109
                    rts

L45F0               lbsr      L4635
                    lda       #$00
                    sta       <u0057
                    lda       #$12
                    lbsr      L2A9A
                    ldy       #$0008
L4600               lbsr      L35EF
                    leay      -$01,y
                    bne       L4600
                    lda       >$0116
                    lbra      L2A9A
L460D               lda       #$FF
                    sta       <u004A
                    tst       <u0085
                    beq       L4619
                    lda       #$02
                    sta       <u007E
L4619               lda       #$12
                    sta       <u0054
                    ldx       #$0011
                    ldb       #$11
                    stb       <u00CE
                    inc       <u0070
                    lbsr      L3E39
                    dec       <u0070
                    lda       #$FF
                    sta       >$0103
                    lda       #$01
                    lbra      L3600
L4635               pshs      y,x
                    dec       <u005D
                    inc       >$019B
                    bne       L4641
                    inc       >$019A
L4641               lbsr      L57CD
                    tst       <u004C
                    beq       L464B
                    lbsr      L3BA6
L464B               tst       <u004F
                    beq       L467D
                    lda       #$11
                    sta       <u00CE
                    ldx       #$0010
                    lbsr      L3E39
                    tst       <u004A
                    bpl       L467D
                    lda       >$0126
                    anda      #$03
                    bne       L467D
                    ldx       #$0011
                    ldy       #$0012
                    ldb       #$12
                    lda       >$0125
                    eora      #$01
                    sta       >$0125
                    bne       L4678
                    decb
L4678               stb       <u00CE
                    lbsr      L3E39
L467D               dec       >$0126
                    lbsr      L3C7C
                    lbsr      L393A
                    puls      pc,y,x
L4688               clr       >$09A6
L468B               lda       <u0063
                    cmpa      #$01
                    beq       L4694
                    lbsr      L03E7
L4694               lda       >$09A6
                    cmpa      #$03
                    bne       L46A7
                    lbsr      L4635
                    lda       <u0063
                    cmpa      #$01
                    beq       L46A7
                    lbsr      L03E7
L46A7               ldb       >$09A6
                    cmpb      #$01
                    bne       L46B3
                    lda       #$03
                    lbsr      L3600
L46B3               lda       <u006B
                    bmi       L46C5
                    adda      <u006A
                    sta       <u006A
                    bcc       L46D1
                    inc       <u0050
                    bne       L46D1
                    dec       <u0050
                    bne       L46D1
L46C5               adda      <u006A
                    sta       <u006A
                    bcs       L46D1
                    lda       <u0050
                    beq       L46D1
                    dec       <u0050
L46D1               lda       <u0050
                    sta       <u0061
                    lda       >$094A
                    adda      >$094C
                    sta       >$094A
                    bcc       L46E6
                    lda       <u0051
                    beq       L46E6
                    dec       <u0051
L46E6               lda       <u0051
                    sta       <u0062
                    tst       <u0064
                    bne       L46F4
                    lda       <u0063
                    cmpa      #$01
                    beq       L4700
L46F4               ldd       <u0063
                    subd      #$0010
                    std       <u0063
                    tsta
                    bne       L4700
                    inc       <u0063
L4700               clra
                    ldb       <u0087
                    lslb
                    tfr       d,x
                    tst       >$0A5D,x
                    bne       L4714
                    lda       >$0A5E,x
                    cmpa      #$22
                    bcs       L4717
L4714               lbsr      L472B
L4717               tst       <u004F
                    beq       L472A
                    inc       >$09A6
                    lda       >$09A6
                    anda      #$03
                    sta       >$09A6
                    lbne      L468B
L472A               rts

L472B               ldd       <u0063
                    std       >$05F6
                    ldd       <u0061
                    std       >$05F4
                    lbsr      L2361
                    ldd       >$05F6
                    std       <u0063
                    ldd       >$05F4
                    std       <u0061
                    lda       <u0050
                    cmpa      #$30
                    bcc       L4749
                    clra
L4749               cmpa      #$D0
                    bcs       L474E
                    clra
L474E               sta       >$0169
                    beq       L47BD
                    adda      #$20
                    cmpa      #$D0
                    bls       L475B
                    lda       #$D0
L475B               sta       >$016B
                    lda       <u0051
                    nega
                    cmpa      #$AF
                    bcs       L4766
                    clra
L4766               sta       >$016A
                    beq       L47BD
                    adda      #$20
                    cmpa      #$AF
                    bcs       L4773
                    lda       #$AF
L4773               sta       >$016C
                    ldd       <u0063
                    subd      #$0100
                    bcc       L4780
                    clra
                    bra       L478C
L4780               lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    cmpa      #$1E
                    bls       L478C
                    lda       #$1E
L478C               pshs      a
                    lda       #$1E
                    suba      ,s+
                    sta       >$016F
                    ldx       #$2CD6
                    lda       >$087E
                    bne       L47AA
                    ldx       #$2CCE
                    lda       >$0176
                    cmpa      #$68
                    bne       L47AA
                    ldx       #$2CD2
L47AA               stx       >$016D
                    lda       >$09A6
                    lsla
                    ldx       #$2EFD
                    ldx       a,x
                    ldy       #$0169
                    lbsr      L2978
L47BD               lbsr      L23EB
                    lbra      L279E
L47C3               lbsr      L56E2
                    anda      #$03
                    adda      <u00EA
                    bpl       L47CD
                    clra
L47CD               adda      #$02
                    sta       >$09C4
                    lda       #$03
                    sta       >$0600
                    lda       #$0C
                    sta       >$05F9
                    lbsr      L4879
                    lbsr      L4879
                    lbsr      L4879
L47E5               lbsr      L4899
                    lbsr      L56E2
                    anda      #$07
                    cmpa      #$06
                    bls       L47F2
                    clra
L47F2               sta       >$05FA
                    lbsr      L56E2
                    anda      #$07
                    cmpa      #$04
                    bls       L4800
                    anda      #$01
L4800               sta       >$05FD
                    lda       >$05FB
                    adda      >$05FE
                    bpl       L4810
                    lda       #$01
                    sta       >$05FE
L4810               sta       >$05FB
                    cmpa      >$0600
                    bne       L481B
                    neg       >$05FE
L481B               lda       >$05FC
                    adda      >$05FF
                    bpl       L4828
                    lda       #$01
                    sta       >$05FF
L4828               sta       >$05FC
                    cmpa      >$0600
                    bne       L4833
                    neg       >$05FF
L4833               lbsr      L48B1
                    lbsr      L48D6
                    lbsr      L48FE
                    lbsr      L4924
                    lbsr      L494F
                    lbsr      L23EB
                    lbsr      L279E
                    lda       >$0600
                    cmpa      >$05FB
                    beq       L4855
                    cmpa      >$05FC
                    bne       L486F
L4855               ldy       #$0002
L4859               lbsr      L35EF
                    leay      -$01,y
                    bne       L4859
                    dec       >$09C4
                    bpl       L486A
                    clr       <u005C
                    lbra      L074B
L486A               bne       L486F
                    inc       >$0600
L486F               lbsr      L57CD
                    lda       <u004F
                    lbne      L47E5
                    rts

L4879               bsr       L4899
                    lbsr      L48B1
                    lbsr      L48D6
                    lbsr      L48FE
                    lbsr      L4924
                    lbsr      L494F
                    lbsr      L23EB
                    lbsr      L279E
                    lda       >$05F9
                    suba      #$04
                    sta       >$05F9
                    rts

L4899               ldd       <u0063
                    std       >$05F6
                    ldd       <u0061
                    std       >$05F4
                    lbsr      L2361
                    ldd       >$05F6
                    std       <u0063
                    ldd       >$05F4
                    std       <u0061
                    rts

L48B1               ldb       #$22
                    addb      >$05F9
                    pshs      b
                    ldb       #$5F
                    subb      ,s+
                    ldu       #$0E83
                    clra
                    lslb
                    rola
                    ldu       d,u
                    ldb       #$1F
                    leau      b,u
                    ldy       #$1763
                    lda       #$11
                    ldb       #$36
                    subb      >$05F9
                    lbra      L497A
L48D6               lda       >$05FA
                    lsla
                    ldx       #$2C90
                    ldy       a,x
                    ldb       #$22
                    addb      >$05F9
                    subb      $01,y
                    pshs      b
                    ldb       #$5F
                    subb      ,s+
                    ldu       #$0E83
                    clra
                    lslb
                    rola
                    ldu       d,u
                    ldb       #$21
                    leau      b,u
                    ldd       ,y++
                    lbra      L497A
L48FE               lda       >$05FD
                    lsla
                    ldx       #$2CA8
                    ldy       a,x
                    ldb       #$20
                    addb      >$05F9
                    pshs      b
                    ldb       #$5F
                    subb      ,s+
                    ldu       #$0E83
                    clra
                    lslb
                    rola
                    ldu       d,u
                    ldb       #$24
                    leau      b,u
                    ldd       ,y++
                    lbra      L497A
L4924               lda       >$05FB
                    lsla
                    ldx       #$2C9E
                    ldy       a,x
                    ldx       #$2CB2
                    leax      a,x
                    ldb       $01,x
                    addb      >$05F9
                    pshs      b
                    ldb       #$5F
                    subb      ,s+
                    ldu       #$0E83
                    clra
                    lslb
                    rola
                    ldu       d,u
                    ldb       ,x
                    leau      b,u
                    ldd       ,y++
                    lbra      L497A
L494F               lda       >$05FC
                    lsla
                    ldx       #$2C9E
                    ldy       a,x
                    ldx       #$2CBC
                    leax      a,x
                    ldb       $01,x
                    addb      >$05F9
                    pshs      b
                    ldb       #$5F
                    subb      ,s+
                    ldu       #$0E83
                    clra
                    lslb
                    rola
                    ldu       d,u
                    ldb       ,x
                    leau      b,u
                    ldd       ,y++
                    lbra      L49AD
L497A               std       <u00CA
L497C               pshs      u
                    ldb       <u00CA
L4980               lda       ,y
                    beq       L499C
                    anda      #$F0
                    bne       L498C
                    lda       ,u
                    anda      #$F0
L498C               pshs      a
                    lda       ,y
                    anda      #$0F
                    bne       L4998
                    lda       ,u
                    anda      #$0F
L4998               ora       ,s+
                    sta       ,u
L499C               leau      u0001,u
                    leay      $01,y
                    decb
                    bne       L4980
                    puls      u
                    leau      <u0050,u
                    dec       <u00CB
                    bne       L497C
                    rts
L49AD               std       <u00CA
L49AF               pshs      u,y
                    ldb       <u00CA
                    leay      b,y
L49B5               lda       ,-y
                    beq       L49DD
                    anda      #$0F
                    bne       L49C3
                    lda       ,u
                    anda      #$F0
                    bra       L49C7
L49C3               lsla
                    lsla
                    lsla
                    lsla
L49C7               pshs      a
                    lda       ,y
                    anda      #$F0
                    bne       L49D5
                    lda       ,u
                    anda      #$0F
                    bra       L49D9
L49D5               lsra
                    lsra
                    lsra
                    lsra
L49D9               ora       ,s+
                    sta       ,u
L49DD               leau      u0001,u
                    decb
                    bne       L49B5
                    puls      u,y
                    ldb       <u00CA
                    leay      b,y
                    leau      <u0050,u
                    dec       <u00CB
                    bne       L49AF
                    rts

L49F0               lda       >$0602
                    beq       L49F8
                    lbsr      L4B2E
L49F8               lda       <u0078
                    suba      #$04
                    sta       <u0078
                    clr       >$08F3
                    lda       >$08B3
                    tfr       a,b
                    anda      #$03
                    sta       >$08CD
                    lsrb
                    lsrb
                    subb      #$10
                    bcc       L4A16
                    lda       >$08CF
                    bra       L4A34
L4A16               cmpb      #$1F
                    bcs       L4A1F
                    lda       >$08EE
                    bra       L4A34
L4A1F               clra
                    tfr       d,y
                    ldb       #$03
L4A24               adda      >$08CF,y
                    cmpb      >$08CD
                    bne       L4A2F
                    leay      $01,y
L4A2F               decb
                    bpl       L4A24
                    asra
                    asra
L4A34               sta       >$08CE
                    ldb       <u0049
                    ldy       #$3A84
                    lda       b,y
                    adda      >$08B5
                    adca      >$08CE
                    sta       >$0162
                    lda       >$08B3
                    anda      #$FE
                    cmpa      #$30
                    bcc       L4A52
                    clra
L4A52               cmpa      #$D0
                    bcs       L4A57
                    clra
L4A57               sta       >$0161
                    lbeq      L4A8F
                    adda      #$08
                    cmpa      #$D0
                    bls       L4A66
                    lda       #$D0
L4A66               sta       >$0163
                    lda       >$0162
                    cmpa      #$50
                    bcc       L4A71
                    clra
L4A71               cmpa      #$AF
                    bcs       L4A76
                    clra
L4A76               sta       >$0162
                    lbeq      L4A8F
                    adda      #$08
                    cmpa      #$AF
                    bls       L4A85
                    lda       #$AF
L4A85               sta       >$0164
                    lda       <u0049
                    sta       >$0167
                    bsr       L4A9E
L4A8F               dec       <u0049
                    bpl       L4A95
                    clr       <u0049
L4A95               lda       >$0616
                    beq       L4A9D
                    dec       >$0616
L4A9D               rts

L4A9E               ldy       #$2CDA
                    lda       >$0616
                    beq       L4AA9
                    adda      #$03
L4AA9               pshs      a
                    ldb       a,y
                    stb       >$0165
                    lda       #$01
                    sta       >$0602
                    clra
                    ldb       >$0167
                    cmpb      #$18
                    bne       L4AC1
                    lda       #$06
                    bra       L4ACF
L4AC1               cmpb      #$17
                    bne       L4AC9
                    lda       #$04
                    bra       L4ACF
L4AC9               cmpb      #$16
                    bne       L4ACF
                    lda       #$02
L4ACF               adda      ,s
                    adda      ,s+
                    ldy       #$2DE7
                    ldy       a,y
                    ldx       #$2EDD
                    ldb       >$0162
L4AE0               pshs      y,b
                    subb      #$50
                    bcs       L4B0A
                    cmpb      #$57
                    bcc       L4B0A
                    ldu       #$0D33
                    clra
                    lslb
                    rola
                    ldu       d,u
                    ldb       >$0161
                    subb      #$30
                    lsrb
                    leau      b,u
                    ldb       >$0161
L4AFD               lda       ,u
                    sta       ,x+
                    bsr       L4B15
                    addb      #$02
                    cmpb      >$0163
                    bcs       L4AFD
L4B0A               puls      y,b
                    leay      $04,y
                    incb
                    cmpb      >$0164
                    bcs       L4AE0
                    rts

L4B15               lda       ,y
                    beq       L4B29
                    lda       ,y
                    anda      >$0165
                    pshs      a
                    lda       ,y
                    coma
                    anda      ,u
                    ora       ,s+
                    sta       ,u
L4B29               leay      $01,y
                    leau      u0001,u
                    rts

L4B2E               ldx       #$2EDD
                    ldb       >$0162
L4B34               pshs      b
                    subb      #$50
                    bcs       L4B5C
                    cmpb      #$57
                    bcc       L4B5C
                    ldu       #$0D33
                    clra
                    lslb
                    rola
                    ldu       d,u
                    ldb       >$0161
                    subb      #$30
                    lsrb
                    leau      b,u
                    ldb       >$0161
L4B51               lda       ,x+
                    sta       ,u+
                    addb      #$02
                    cmpb      >$0163
                    bcs       L4B51
L4B5C               puls      b
                    incb
                    cmpb      >$0164
                    bcs       L4B34
                    clr       >$0602
                    rts

                    lda       #$80
                    sta       <u0078
                    clr       <u0049
                    rts

L4B6F               clr       <u003D
                    clr       <u0035
                    lda       <u005C
                    cmpa      #$02
                    bne       L4BB2
                    tst       <u004F
                    bne       L4BB2
                    lbsr      getjoyxy
                    ldb       >joyx
                    ldx       #$0000
                    lbsr      L52FB
                    lda       <u007E
                    cmpa      #$00
                    bne       L4B9D
                    lda       <u0043
                    cmpa      #$03
                    bcs       L4B99
                    cmpa      #$FD
                    bcs       L4B9D
L4B99               clr       <u0043
                    clr       <u0044
L4B9D               clrb
                    tst       >$099A
                    beq       L4BA8
                    ldb       #$3F
                    subb      >joyy
L4BA8               ldx       #$0002
                    lbsr      L52FB
                    lsl       <u0046
                    rol       <u0045
L4BB2               tst       <u0085
                    beq       L4BB9
                    lbsr      L5282
L4BB9               lda       <u007E
                    cmpa      #$02
                    bne       L4BD6
                    lda       #$70
                    sta       <u003D
                    ldd       <u0039
                    lslb
                    rola
                    lslb
                    rola
                    nega
                    sta       <u0035
                    lda       #$F0
                    sta       <u0036
                    clra
                    lbsr      L3E92
                    bra       L4BEC
L4BD6               tst       <u004E
                    bne       L4BEC
                    cmpa      #$00
                    bne       L4BE3
                    lbsr      L5013
                    bra       L4BEC
L4BE3               lda       #$01
                    lbsr      L5274
                    ldd       <u0039
                    std       <u0037
L4BEC               tst       <u004F
                    beq       L4BF1
                    rts

L4BF1               tst       <u0035
                    bne       L4C30
                    ldy       #$0000
                    ldd       <u0039
                    subd      <u0043
                    stb       <u00CB
                    tsta
                    bpl       L4C0E
                    leay      -$01,y
                    cmpa      #$F8
                    bcc       L4C0C
                    clr       <u00CB
                    lda       #$F8
L4C0C               bne       L4C18
L4C0E               cmpa      #$08
                    bcs       L4C18
                    lda       #$FF
                    sta       <u00CB
                    lda       #$07
L4C18               pshs      a
                    tfr       y,d
                    puls      a
                    stb       <u00CA
                    ldb       #$04
L4C22               lsl       <u00CB
                    rola
                    decb
                    bne       L4C22
                    sta       <u00CB
                    ldd       <u0039
                    subd      <u00CA
                    std       <u0039
L4C30               tst       <u003D
                    bne       L4C6D
                    ldy       #$0000
                    ldd       <u003E
                    subd      <u0045
                    stb       <u00CB
                    tsta
                    bpl       L4C4D
                    leay      -$01,y
                    cmpa      #$E0
                    bcc       L4C4B
                    clr       <u00CB
                    lda       #$E0
L4C4B               bra       L4C57
L4C4D               cmpa      #$20
                    bcs       L4C57
                    lda       #$FF
                    sta       <u00CB
                    lda       #$1F
L4C57               pshs      a
                    tfr       y,d
                    puls      a
                    stb       <u00CA
                    lsl       <u00CB
                    rola
                    lsl       <u00CB
                    rola
                    sta       <u00CB
                    ldd       <u003E
                    subd      <u00CA
                    std       <u003E
L4C6D               ldy       #$0001
                    lda       <u0036
                    bne       L4C7B
                    ldy       #$0005
                    bra       L4C9C
L4C7B               suba      <u003E
                    sbca      <u003E
                    sta       <u00CB
                    lda       <u0036
                    lsra
                    ora       #$07
                    pshs      a
                    lbsr      L56E2
                    puls      b
                    andb      <u0032
                    adcb      <u00CB
                    bcc       L4C95
                    ldb       #$FF
L4C95               clra
                    lslb
                    rola
                    addd      <u0041
                    std       <u0041
L4C9C               tst       >$099A
                    beq       L4CD2
                    lda       <u0041
                    adda      #$02
                    sta       <u00CB
                    lda       #$00
                    rola
                    sta       <u00CA
                    lda       <u0042
L4CAE               lsla
                    rol       <u00CB
                    rol       <u00CA
                    leay      -$01,y
                    bne       L4CAE
                    ldd       <u00CA
                    addd      #$0001
                    std       <u00CA
                    ldd       <u0041
                    subd      <u00CA
                    std       <u0041
                    bcc       L4CD2
                    clr       <u0041
                    clr       <u0042
                    tst       >$0120
                    beq       L4CD2
                    lbsr      L5274
L4CD2               lda       <u003A
                    adda      <u0035
                    sta       <u003A
                    tst       <u0035
                    bpl       L4CE2
                    bcs       L4CE6
                    dec       <u0039
                    bra       L4CE6
L4CE2               bcc       L4CE6
                    inc       <u0039
L4CE6               lda       <u0039
                    bmi       L4CF6
                    cmpa      #$05
                    bcs       L4CFE
                    lda       #$FF
                    sta       <u003A
                    lda       #$04
                    bra       L4CFE
L4CF6               cmpa      #$FB
                    bcc       L4CFE
                    clr       <u003A
                    lda       #$FB
L4CFE               sta       <u0039
                    lda       <u003F
                    adda      <u003D
                    sta       <u003F
                    tst       <u003D
                    bpl       L4D10
                    bcs       L4D14
                    dec       <u003E
                    bra       L4D14
L4D10               bcc       L4D14
                    inc       <u003E
L4D14               lda       <u003E
                    bmi       L4D25
                    cmpa      <u003C
                    bcs       L4D2D
                    lda       #$FF
                    sta       <u003F
                    lda       <u003C
                    deca
                    bra       L4D2D
L4D25               cmpa      <u003B
                    bcc       L4D2D
                    clr       <u003F
                    lda       <u003B
L4D2D               sta       <u003E
                    ldb       <u003F
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    sta       <u0034
                    bcc       L4D3C
                    nega
L4D3C               ldb       <u0041
                    lbsr      L1040
                    clrb
                    tst       <u0034
                    bpl       L4D4B
                    decb
                    nega
                    bne       L4D4B
                    incb
L4D4B               exg       a,b
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    std       >$0907
                    ldd       <u0039
                    stb       <u00CB
                    ldb       #$04
L4D5C               asra
                    ror       <u00CB
                    decb
                    bne       L4D5C
                    sta       <u00CA
                    ldd       >$0909
                    addd      <u00CA
                    anda      #$3F
                    std       >$0909
                    lbsr      L0C1E
                    ldd       >$090B
                    addd      >$0903
                    std       >$090B
                    ldd       >$090D
                    addd      >$0905
                    std       >$090D
                    clra
                    ldb       <u007E
                    tfr       d,y
                    ldd       <u0047
                    addd      >$0907
                    stb       <u0048
                    cmpa      #$FF
                    bne       L4D94
                    clra
L4D94               cmpa      #$50
                    bcs       L4DAD
                    ldb       #$FF
                    cmpy      #$0002
                    bne       L4DA9
                    cmpa      #$60
                    bcs       L4DAD
                    stb       >$08A1
                    bra       L4DAD
L4DA9               stb       <u0048
                    lda       #$4F
L4DAD               sta       <u0047
                    lda       <u003F
                    lsla
                    lda       <u003E
                    adca      #$0C
                    sta       >$08F6
                    lda       <u0038
                    lsla
                    lda       <u0037
                    adca      #$05
                    sta       >$08F4
                    lda       #$38
                    tst       >$08A3
                    bne       L4DCF
                    suba      >$0909
                    bra       L4DD2
L4DCF               suba      >$019B
L4DD2               anda      #$3F
                    pshs      a
                    anda      #$03
                    sta       >$089B
                    puls      a
                    lsra
                    lsra
                    sta       >$087C
                    ldy       #$0002
                    lda       <u0036
                    cmpa      #$F0
                    beq       L4E0F
                    lda       <u00FB
                    bne       L4E0A
                    sta       >$099A
                    ldb       >$0998
                    beq       L4E2B
                    dec       >$0998
                    pshs      a
                    lbsr      L56E2
                    puls      a
                    cmpb      <u0032
                    bcs       L4E2B
                    lda       #$FF
                    bra       L4E0F
L4E0A               lda       #$FF
                    sta       >$0998
L4E0F               sta       >$099A
                    lda       <u0036
                    beq       L4E2B
                    cmpa      #$F0
                    bcc       L4E1E
                    lda       #$04
                    bra       L4E2B
L4E1E               lda       <u0047
                    lsra
                    lsra
                    lsra
                    eora      #$0F
                    cmpa      #$04
                    bcc       L4E2B
                    lda       #$04
L4E2B               sta       >$011F,y
                    ldd       >$099C
                    asra
                    rorb
                    std       >$08B7
                    ldy       #$0000
                    lda       >$09A0
                    sta       >$08BA
                    bpl       L4E45
                    leay      -$01,y
L4E45               tfr       y,d
                    tfr       b,a
                    ldb       #$03
L4E4B               lsl       >$08BA
                    rola
                    decb
                    bne       L4E4B
                    sta       >$08B9
                    ldy       #$0000
                    lda       >$099C
                    asra
                    bpl       L4E61
                    leay      -$01,y
L4E61               adda      >$088F
                    sta       >$088F
                    tfr       y,d
                    adcb      >$088E
                    stb       >$088E
                    ldy       #$0000
                    lda       >$09A0
                    asra
                    asra
                    asra
                    bpl       L4E7D
                    leay      -$01,y
L4E7D               adda      >$0894
                    sta       >$0894
                    tfr       y,d
                    adcb      >$0893
                    stb       >$0893
                    lda       <u0049
                    beq       L4EAF
                    bmi       L4E9D
                    cmpa      #$18
                    bne       L4E9A
                    lbsr      L504D
                    bra       L4E9D
L4E9A               lbsr      L50BF
L4E9D               ldd       >$08B3
                    subd      >$08B7
                    std       >$08B3
                    ldd       >$08B5
                    addd      >$08B9
                    std       >$08B5
L4EAF               ldb       <u0071
                    bmi       L4EEB
                    decb
                    stb       <u0071
                    bpl       L4EC9
                    lda       >$0886
                    pshs      a
                    lbsr      L524C
                    lda       ,s+
                    beq       L4EEB
                    lbsr      L4FE0
                    bra       L4EEB
L4EC9               tfr       b,a
                    lsra
                    lsra
                    sta       <u0072
                    cmpb      #$5A
                    beq       L4EE5
                    lda       <u007A
                    cmpa      #$1F
                    bcs       L4EE8
                    cmpb      #$3C
                    beq       L4EE5
                    cmpa      #$3D
                    bcs       L4EE8
                    cmpb      #$28
                    bne       L4EE8
L4EE5               lbsr      L179B
L4EE8               lbsr      L4F47
L4EEB               ldb       >$09A4
                    incb
                    cmpb      #$07
                    bcs       L4EF4
                    clrb
L4EF4               clra
                    stb       >$09A4
                    tfr       d,y
                    lda       >$0913,y
                    sta       >$099D
                    lda       <u003A
                    sta       >$0913,y
                    lda       >$091A,y
                    sta       >$099C
                    lda       <u0039
                    sta       >$091A,y
                    lda       >$0921,y
                    sta       >$09A0
                    lda       <u003F
                    suba      <u0040
                    sta       >$0902
                    sta       >$0921,y
                    lda       <u003F
                    sta       <u0040
                    lda       >$0928,y
                    sta       >$09A2
                    lda       >$08F4
                    sta       >$0928,y
                    lda       >$092F,y
                    sta       >$09A3
                    lda       >$08F6
                    sta       >$092F,y
                    rts

L4F47               ldd       >$0888
                    subd      >$08B7
                    std       >$0888
                    lda       >$08B7
                    bpl       L4F5C
                    bcs       L4F61
                    inc       >$0887
                    bra       L4F61
L4F5C               bcc       L4F61
                    dec       >$0887
L4F61               ldd       >$088B
                    addd      >$08B9
                    std       >$088B
                    lda       >$08B9
                    bmi       L4F76
                    bcc       L4F7B
                    inc       >$088A
                    bra       L4F7B
L4F76               bcs       L4F7B
                    dec       >$088A
L4F7B               ldd       >$0888
                    subd      >$088E
                    std       >$0888
                    lda       >$088E
                    bpl       L4F90
                    bcs       L4F95
                    inc       >$0887
                    bra       L4F95
L4F90               bcc       L4F95
                    dec       >$0887
L4F95               ldd       >$088B
                    addd      >$0893
                    std       >$088B
                    lda       >$0893
                    bmi       L4FAA
                    bcc       L4FAF
                    inc       >$088A
                    bra       L4FAF
L4FAA               bcs       L4FAF
                    dec       >$088A
L4FAF               lda       >$0887
                    bne       L4FDC
                    lda       >$088A
                    bne       L4FDC
                    leax      >L5967,pcr
                    clra
                    ldb       <u0071
                    lda       d,x
                    ldb       >$0895
                    cmpb      #$30
                    bcs       L4FCA
                    clra
L4FCA               cmpb      #$20
                    bcs       L4FCF
                    asra
L4FCF               adda      >$088B
                    sta       >$0881
                    lda       >$0888
                    sta       >$0884
                    rts

L4FDC               clr       >$0884
                    rts

L4FE0               tst       >$0887
                    bne       L5012
                    tst       >$088A
                    bne       L5012
                    lda       >$0888
                    cmpa      #$34
                    bcs       L5012
                    cmpa      #$AC
                    bcc       L5012
                    lda       >$088B
                    cmpa      #$1A
                    bcs       L5012
                    cmpa      #$6A
                    bcc       L5012
                    lda       #$20
                    sta       <u004C
                    lbsr      L0ACA
                    lbsr      L1B59
                    lda       #$13
                    sta       >$0601
                    inc       >$012A
L5012               rts

L5013               tst       <u0037
                    bpl       L5023
                    ldd       <u0037
                    addd      #$0014
                    bmi       L502D
                    ldd       #$0000
                    bra       L502D
L5023               ldd       <u0037
                    subd      #$0014
                    bcc       L502D
                    ldd       #$0000
L502D               std       <u0037
                    tst       <u007D
                    beq       L503B
                    ldd       <u0047
                    subd      #$0048
                    std       <u0047
L503A               rts

L503B               tst       <u004E
                    bne       L503A
                    ldd       #$0000
                    std       <u0037
                    inc       <u004E
                    lda       <u0071
                    bmi       L503A
                    lbra      L524C
L504D               ldd       >$0972
                    std       >$08BB
                    clr       >$08BD
                    ldd       >$0974
                    std       >$08BE
                    clr       >$08C0
                    lda       >$0977
                    sta       >$08C2
                    lda       >$0976
                    adda      #$08
                    bcc       L506E
                    lda       #$FF
L506E               sta       >$08C1
                    ldy       #$0000
                    ldd       >$0978
                    std       >$08C4
                    tsta
                    bpl       L5080
                    leay      -$01,y
L5080               tfr       y,d
                    lsl       >$08C5
                    rol       >$08C4
                    rolb
                    lsl       >$08C5
                    rol       >$08C4
                    rolb
                    stb       >$08C3
                    ldy       #$0000
                    ldd       >$097A
                    std       >$08C7
                    tsta
                    bpl       L50A2
                    leay      -$01,y
L50A2               tfr       y,d
                    lsl       >$08C8
                    rol       >$08C7
                    rolb
                    lsl       >$08C8
                    rol       >$08C7
                    rolb
                    stb       >$08C6
                    ldd       >$097E
                    asra
                    rorb
                    deca
                    std       >$08C9
                    rts

L50BF               ldd       >$08BC
                    addd      >$08C4
                    std       >$08BC
                    sta       >$085D
                    lda       >$08BB
                    adca      >$08C3
                    anda      #$0F
                    sta       >$08BB
                    sta       >$085C
                    sta       <u00CC
                    ldd       >$08BF
                    addd      >$08C7
                    std       >$08BF
                    sta       >$085F
                    lda       >$08BE
                    adca      >$08C6
                    anda      #$0F
                    sta       >$08BE
                    sta       >$085E
                    lda       >$08C2
                    adda      >$08CA
                    sta       >$08C2
                    lda       >$08C1
                    adca      >$08C9
                    bcc       L510F
                    tst       >$08C9
                    bmi       L5115
                    lda       #$FF
                    bra       L5115
L510F               tst       >$08C9
                    bpl       L5115
                    clra
L5115               sta       >$08C1
                    lda       <u0071
                    bmi       L511F
                    lbsr      L51F6
L511F               lda       >$08BF
                    lsla
                    lda       >$08BE
                    adca      #$00
                    lsla
                    lsla
                    lsla
                    lsla
                    sta       <u00CA
                    lda       >$08BC
                    lsla
                    ldb       >$08BB
                    adcb      #$00
                    andb      #$0F
                    orb       <u00CA
                    stb       >$08CB
                    clra
                    tfr       d,y
                    lda       >$02BC,y
                    beq       L516C
                    lda       >$01BC,y
                    adda      #$10
                    bcc       L5151
                    lda       #$FF
L5151               cmpa      >$08C1
                    bcs       L516C
                    lda       >$08BC
                    cmpa      #$30
                    bcs       L5161
                    cmpa      #$D0
                    bcs       L516C
L5161               lda       >$08BF
                    cmpa      #$30
                    bcs       L5192
                    cmpa      #$D0
                    bcc       L5192
L516C               lbsr      L0E2D
                    lda       >$0860
                    cmpa      >$08C1
                    bcc       L5178
                    rts

L5178               lda       >$08BC
                    cmpa      #$30
                    bcs       L5185
                    cmpa      #$D0
                    lbcs      L51E6
L5185               lda       >$08BF
                    cmpa      #$30
                    bcs       L5192
                    cmpa      #$D0
                    lbcs      L51E6
L5192               clra
                    ldb       >$08CB
                    tfr       d,y
                    lda       >$02BC,y
                    lbeq      L51E6
                    cmpa      #$F8
                    lbcc      L51E6
                    pshs      a
                    lda       #$FC
                    sta       >$02BC,y
                    sta       >$08A9
                    lbsr      L5256
                    puls      a
                    cmpa      #$64
                    bcs       L51E6
                    bne       L51CB
                    lbsr      L45E1
                    lda       #$28
                    sta       <u0060
                    lda       <u0084
                    ora       #$80
                    sta       <u0084
                    bra       L51E6
L51CB               cmpa      #$80
                    bne       L51D8
                    lbsr      L45E1
                    ldy       #$0016
                    bra       L51DF
L51D8               lbsr      L4598
                    ldy       #$0009
L51DF               tfr       y,d
                    stb       <u0054
                    lbsr      L41BE
L51E6               lda       #$07
                    sta       >$0616
                    clr       <u0049
                    lda       #$40
                    cmpa      <u0077
                    bcs       L51F5
                    sta       <u0077
L51F5               rts

L51F6               lda       >$0886
                    lbeq      L5255
                    lda       <u0072
                    adda      #$04
                    suba      <u0049
                    bcc       L5206
                    nega
L5206               cmpa      #$04
                    bcc       L5255
                    lda       >$08B3
                    suba      #$0C
                    sbca      >$0884
                    bcc       L5215
                    nega
L5215               sta       <u00CA
                    lda       >$08B5
                    adda      #$42
                    suba      >$0881
                    bcc       L5222
                    nega
L5222               adda      <u00CA
                    rora
                    lsra
                    pshs      a
                    clra
                    ldb       <u0049
                    tfr       d,x
                    puls      a
                    cmpa      >$3D08,x
                    bcc       L5255
                    clr       >$0886
                    lbsr      L0ACA
                    lbsr      L51E6
                    lbsr      L5256
                    ldd       #$0250
                    std       <u0055
                    lbsr      L45E6
                    lbra      L179B
L524C               lda       #$FF
                    sta       <u0072
                    sta       <u0071
                    sta       >$0886
L5255               rts

L5256               inc       <u0052
                    lda       #$77
                    sta       <u0057
                    lda       #$12
                    lbsr      L2A9A
                    lbsr      L35E7
                    lda       >$0116
                    lbsr      L2A9A
                    lda       #$02
                    sta       >$095E
                    lda       #$80
                    sta       <u0077
                    rts

L5274               sta       >$0120
                    sta       >$0122
                    sta       >$0123
                    ldy       #$0003
                    rts

L5282               clr       <u0045
                    clr       <u0046
                    clr       <u0043
                    clr       <u0044
                    lda       >$0856
                    suba      >$0857
                    sta       <u0035
                    lda       >$0856
                    adda      >$0857
                    lsra
                    cmpa      <u0047
                    bcc       L52A8
                    lda       <u0035
                    bpl       L52A2
                    nega
L52A2               cmpa      #$10
                    bcc       L52A8
                    clr       <u0035
L52A8               lda       >$099A
                    bne       L52B2
                    lda       #$C8
                    sta       <u003D
                    rts

L52B2               ldb       #$38
                    lda       <u007D
                    cmpa      #$2A
                    bcs       L52BB
                    clrb
L52BB               stb       <u003D
                    lda       <u0047
                    cmpa      #$2A
                    bcs       L52CB
                    lda       <u003E
                    bmi       L52CB
                    lda       #$C8
                    bra       L52D3
L52CB               lda       #$20
                    suba      <u0047
                    asra
                    bmi       L52D3
                    clra
L52D3               adda      <u003D
                    sta       <u003D
                    lda       >$098E
                    cmpa      #$30
                    bcs       L52E3
                    cmpa      #$D1
                    bcc       L52E3
                    rts

L52E3               lsla
                    adda      <u0035
                    sta       <u0035
                    lda       >$0990
                    cmpa      #$20
                    bcs       L52F4
                    cmpa      #$E1
                    bcc       L52F4
                    rts

L52F4               lsla
                    coma
                    adda      <u003D
                    sta       <u003D
                    rts

L52FB               leay      >L5A69,pcr
                    ldb       b,y
                    subb      #$80
                    clra
                    lslb
                    bcc       L530A
                    leay      -$01,y
                    deca
L530A               rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    std       <$43,x
                    rts

L5315               ldx       #$076C
                    ldu       #$0775
                    ldy       #$07C5
                    bsr       L5343
                    ldx       #$0776
                    ldy       #$0816
                    bsr       L535F
                    ldx       #$07C6
                    ldy       #$0820
                    bsr       L5391
                    lda       >$082A
                    ldb       #$09
                    ldu       #$0816
L533B               sta       b,u
                    decb
                    bpl       L533B
                    lbra      L53B4
L5343               ldb       #$50
L5345               lda       ,-x
                    cmpa      ,-x
                    bcc       L5355
                    sta       b,u
                    lda       ,x
                    sta       b,y
                    decb
                    bne       L5345
                    rts

L5355               sta       b,y
                    lda       ,x
                    sta       b,u
                    decb
                    bne       L5345
                    rts

L535F               lda       #$5F
                    sta       >$082A
                    lda       #$0A
                    sta       <u0005
L5368               lda       #$5F
                    sta       ,y
                    lda       #$04
                    sta       <u0004
L5370               ldd       ,x++
                    cmpa      ,y
                    bcc       L5378
                    sta       ,y
L5378               cmpb      ,y
                    bcc       L537E
                    stb       ,y
L537E               dec       <u0004
                    bne       L5370
                    lda       ,y+
                    cmpa      >$082A
                    bcc       L538C
                    sta       >$082A
L538C               dec       <u0005
                    bne       L5368
                    rts

L5391               lda       #$0A
                    sta       <u0005
L5395               clr       ,y
                    lda       #$04
                    sta       <u0004
L539B               ldd       ,x++
                    cmpa      ,y
                    bls       L53A3
                    sta       ,y
L53A3               cmpb      ,y
                    bls       L53A9
                    stb       ,y
L53A9               dec       <u0004
                    bne       L539B
                    leay      $01,y
                    dec       <u0005
                    bne       L5395
                    rts

L53B4               bsr       L53BF
                    lbsr      L5431
                    lbsr      L54A2
                    lbra      L54FD
L53BF               lda       >$082A
                    cmpa      #$5F
                    bcc       L53CF
                    ldb       #$5F
                    stb       >$0529
                    ldb       #$BB
                    bsr       L53DC
L53CF               lda       >$082A
                    lbeq      L5430
                    sta       >$0529
                    clra
                    ldb       #$CC
L53DC               sta       >$052B
                    nega
                    adda      >$0529
                    inca
                    sta       >$0529
                    orcc      #IntMasks           mask interrupts
                    sts       <u0006
                    stb       >$052F
                    ldb       >$052B
                    clra
                    lslb
                    rola
                    lds       #$0E83
                    lds       d,s
                    leas      <$50,s
                    lda       >$052F
                    sta       >$0530
                    ldb       >$052F
                    ldx       >$052F
                    ldy       >$052F
                    ldu       >$052F
L5412               pshs      u,y,x,b,a
                    pshs      u,y,x,b,a
                    pshs      u,y,x,b,a
                    pshs      u,y,x,b,a
                    pshs      u,y,x,b,a
                    pshs      u,y,x,b,a
                    pshs      u,y,x,b,a
                    pshs      u,y,x,b,a
                    pshs      u,y,x,b,a
                    pshs      u,y,x,b,a
                    dec       >$0529
                    bne       L5412
                    lds       <u0006
                    andcc     #^IntMasks          unmask interrupts
L5430               rts

L5431               ldx       #$082A
                    ldy       #$0815
                    ldb       #$CC
                    stb       >$0557
                    lda       #$0A
L543F               ldb       ,x
                    cmpb      a,y
                    bcc       L5456
                    pshs      y,x,a
                    sta       >$0533
                    stb       >$0529
                    lda       a,y
                    ldb       >$0557
                    bsr       L545A
                    puls      y,x,a
L5456               deca
                    bne       L543F
                    rts

L545A               stb       >$052F
                    stb       >$0530
                    suba      >$0529
                    sta       >$052B
                    orcc      #IntMasks           mask interrupts
                    sts       <u0006
                    ldb       >$0529
                    lds       #$0E83
                    leas      b,s
                    lds       b,s
                    ldb       >$052B
                    lda       >$0533
                    lsla
                    lsla
                    lsla
                    leas      a,s
                    lda       >$052F
                    ldx       >$052F
                    ldy       >$052F
                    ldu       >$052F
                    tfr       a,dp
L5491               pshs      u,y,x,dp,a
                    leas      <-$48,s
                    decb
                    bpl       L5491
                    clra
                    tfr       a,dp
                    lds       <u0006
                    andcc     #^IntMasks          unmask interrupts
                    rts

L54A2               ldu       #$081F
                    ldy       #$0775
                    ldb       #$CC
                    stb       >$0557
                    lda       #$50
                    ldx       #$0008
L54B3               ldb       ,u
                    cmpb      a,y
                    bcc       L54CA
                    pshs      u,y,x,a
                    sta       >$0533
                    stb       >$0529
                    lda       a,y
                    ldb       >$0557
                    bsr       L54D7
                    puls      u,y,x,a
L54CA               leax      -$01,x
                    bne       L54D3
                    leau      -u0001,u
                    ldx       #$0008
L54D3               deca
                    bne       L54B3
                    rts

L54D7               stb       >$052F
                    suba      >$0529
                    pshs      a
                    ldb       >$0529
                    ldu       #$0E83
                    leau      b,u
                    ldu       b,u
                    ldb       >$0533
                    decb
                    leau      b,u
                    puls      b
                    lda       >$052F
L54F4               sta       ,u
                    leau      <-u0050,u
                    decb
                    bpl       L54F4
                    rts

L54FD               lda       #$CC
                    ldy       #$076C
                    ldx       #$07C6
                    sta       >$0557
                    lda       #$0F
                    sta       >$0529
                    lda       #$50
                    sta       >$0533
L5513               lda       ,-y
                    cmpa      ,-x
                    bls       L551F
                    tfr       a,b
                    subb      ,x
                    bsr       L5537
L551F               com       >$0529
                    lda       ,-y
                    cmpa      ,x
                    bls       L552E
                    tfr       a,b
                    subb      ,x
                    bsr       L5537
L552E               com       >$0529
                    dec       >$0533
                    bne       L5513
                    rts

L5537               ldu       #$0E83
                    leau      a,u
                    ldu       a,u
                    lda       >$0533
                    deca
                    leau      a,u
                    lda       >$0529
                    sta       >$0556
                    anda      >$0557
                    sta       >$052F
                    com       >$0556
L5553               lda       ,u
                    anda      >$0556
                    ora       >$052F
                    sta       ,u
                    leau      <u0050,u
                    decb
                    bne       L5553
                    rts

L5564               ldu       #$3F47
                    ldd       #$004F
                    sta       >$0612
                    stb       >$0613
                    ldy       #$0060
L5574               lbsr      L5680
                    tsta
                    beq       L5592
                    pshs      u,y,b,a
                    bsr       L55AB
                    ldx       #$1C00
L5581               leax      -$01,x
                    bne       L5581
                    puls      u,y,b,a
                    pshs      u,y,b,a
                    bsr       L55AB
                    puls      u,y,b,a
                    lbsr      L5666
                    bra       L5574
L5592               ldd       #$004F
                    sta       >$0612
                    stb       >$0613
                    leau      <u0050,u
                    leay      -$01,y
                    bne       L5574
                    ldx       #$0032
                    lbsr      L5819
                    lbra      L56A2
L55AB               lslb
                    stb       >$0609
                    tfr       y,d
                    pshs      b
                    ldb       #$78
                    subb      ,s+
                    stb       >$060B
                    lda       #$50
                    sta       >$0605
                    lda       #$00
                    sta       >$0607
                    clr       >$0611
                    lda       >$0605
                    cmpa      >$0609
                    bls       L55E4
                    ldb       >$0609
                    sta       >$0609
                    stb       >$0605
                    lda       >$0607
                    ldb       >$060B
                    sta       >$060B
                    stb       >$0607
L55E4               lda       >$0609
                    suba      >$0605
                    sta       >$060D
                    lda       >$060B
                    suba      >$0607
                    bcc       L55F8
                    dec       >$0611
L55F8               sta       >$060E
                    lda       #$80
                    sta       >$0606
                    sta       >$0608
                    lda       >$0605
                    sta       >$060F
                    lda       >$0607
                    sta       >$0610
L560F               lda       >$0605
                    ldb       >$0607
                    lbsr      L564C
L5618               clra
                    ldb       >$060D
                    addd      >$0605
                    std       >$0605
                    lda       >$0611
                    ldb       >$060E
                    addd      >$0607
                    std       >$0607
                    ldb       >$0605
                    cmpa      >$0610
                    bne       L563B
                    cmpb      >$060F
                    beq       L5618
L563B               stb       >$060F
                    sta       >$0610
                    cmpb      >$0609
                    bcs       L560F
                    cmpa      >$060B
                    bne       L560F
                    rts

L564C               pshs      a
                    ldu       #$0D03
                    clra
                    lslb
                    rola
                    ldu       d,u
                    puls      b
                    lda       #$F0
                    lsrb
                    bcc       L565F
                    lda       #$0F
L565F               anda      #$77
                    eora      b,u
                    sta       b,u
                    rts

L5666               pshs      y,b,a
                    tfr       y,d
                    pshs      b
                    ldb       #$78
                    subb      ,s+
                    lda       #$50
                    mul
                    addd      >scrnaddr           screen address
                    tfr       d,y
                    lda       ,s
                    ldb       $01,s
                    sta       b,y
                    puls      pc,y,b,a
L5680               clra
L5681               ldb       >$0612
                    cmpb      >$0613
                    beq       L5690
                    inc       >$0612
                    lda       b,u
                    beq       L5681
L5690               rts

                    clra
L5692               ldb       >$0613
                    cmpb      >$0612
                    beq       L56A1
                    dec       >$0613
                    lda       b,u
                    beq       L5692
L56A1               rts

L56A2               lda       #$F0
                    sta       >$0556
                    ldb       #$04
L56A9               pshs      b
                    ldu       #$3F47
                    decb
                    lsrb
                    leau      b,u
                    ldy       #$0060
L56B6               ldb       #$28
L56B8               lda       >$0556
                    anda      #$00
                    pshs      a
                    lda       >$0556
                    coma
                    anda      ,u
                    ora       ,s+
                    sta       ,u++
                    decb
                    bne       L56B8
                    leay      -$01,y
                    bne       L56B6
                    lbsr      L279E
                    ldx       #$001E
                    lbsr      L5819
                    com       >$0556
                    puls      b
                    decb
                    bne       L56A9
                    rts

L56E2               pshs      x,b
                    inc       <u0033
                    ldb       <u0033
                    leax      >L5867,pcr
                    abx
                    lda       ,x
                    sta       <u0032
                    puls      pc,x,b

L56F3               ldd       >scrnaddr           screen address
                    addd      #$2670
                    tfr       d,u
                    ldb       #$3A
                    lda       #$77
L56FF               sta       <u001D,u
                    sta       <u001E,u
                    sta       <u0030,u
                    sta       <u0031,u
                    leau      <u0050,u
                    decb
                    bne       L56FF
                    rts

L5712               lda       >$0177
                    sta       >$0557
                    ldu       >scrnaddr           screen address
                    leau      >u35A0,u
                    ldb       #$09
                    lda       >$0557
L5724               lda       ,u
                    cmpa      #$77
                    beq       L5731
                    lda       >$0557
                    sta       ,u
                    sta       u0001,u
L5731               leau      <u0050,u
                    decb
                    bne       L5724
                    rts

L5738               pshs      a
                    clr       <u0021
                    stb       <u0022
                    addb      #$7B
                    clra
                    tfr       d,y
                    lda       #$1D
                    bra       L574E

L5747               pshs      a
                    sty       <u0021
                    lda       #$30
L574E               sta       <u0025
                    cmpy      #$007B
                    bcs       L5774
                    cmpy      #$00B4
                    bhi       L5774
                    tfr       y,d
                    ldu       #$0D03
                    clra
                    lslb
                    rola
                    ldu       d,u
                    ldb       <u0025
                    leau      b,u
                    lda       ,s+
                    sta       ,u
                    sta       u0001,u
                    ldy       <u0021
                    rts

L5774               lda       ,s+
                    ldy       <u0021
                    rts
                    rts

L577B               ldu       >scrnaddr           screen address
                    leau      >u0DE7,u
                    ldb       #$0C
                    lbsr      L57B0
                    ldu       >scrnaddr           screen address
                    leau      >u14C7,u
                    ldb       #$0C
                    lbsr      L57B0
                    ldu       >scrnaddr           screen address
                    leau      >u12E3,u
                    lbsr      L57A4
                    ldu       >scrnaddr           screen address
                    leau      >u1333,u
L57A4               ldb       #$04
                    lda       #$11
L57A8               sta       u0005,u
                    sta       ,u+
                    decb
                    bne       L57A8
                    rts

L57B0               lda       #$11
L57B2               sta       ,u
                    leau      <u0050,u
                    decb
                    bne       L57B2
                    rts

                    ldb       #$09
                    lda       #$00
                    clr       <u0057
                    rts

L57C2               rts

L57C3               lda       >$0CEC
                    eora      #$80
                    sta       >$0CEC
                    rts

L57CC               rts

L57CD               pshs      y
                    lbsr      getjoyxy            get joystick X/Y
                    lda       >button             get button value
                    beq       L57DB               if none pressed, branch
                    lda       #$3E
                    bra       L57E3
L57DB               lbsr      L4019
                    bcs       L57EB
                    lbsr      readch
L57E3               tfr       a,b
                    clra
                    tfr       d,x
                    lbsr      L4046
L57EB               lda       <u0054
                    bne       L5806
                    lda       >$0103
                    bmi       L5806
                    dec       >$0103
                    bpl       L5810
                    lda       <u004F
                    bne       L5803
                    lda       #$0E
                    sta       <u0054
                    bra       L5806
L5803               lbsr      L2B0C
L5806               clra
                    ldb       <u0054
                    beq       L5810
                    tfr       d,y
                    lbsr      L41BE
L5810               lda       <u0055
                    beq       L5817
                    lbsr      L41FD
L5817               puls      pc,y
L5819               ldy       #$01F4
L581D               leay      -$01,y
                    bne       L581D
                    leax      -$01,x
                    bne       L5819
                    rts

                    lda       #$80
                    lbsr      L582B
L582B               deca
                    bne       L582B
                    rts

L582F               clr       >$011E
                    lbra      L57C3
                    lbsr      L4019
                    bcs       L5865
                    lbsr      readch
                    cmpa      #$E0
                    bcs       L5843
                    anda      #$DF
L5843               cmpa      #$12
                    bne       L5859
                    lbsr      L03CD
                    tst       <u0079
                    beq       L5851
                    sta       >$0127
L5851               lda       #$01
L5853               sta       >$0CFC
                    lbra      L036B
L5859               cmpa      #$13
                    bne       L5865
                    lda       >$0171
                    eora      #$01
                    sta       >$0171
L5865               rts
                    rts

L5867
                    fcb       $af,$5b,$c1,$97,$d4,$cc,$30,$31,$51,$b8,$f3,$d0,$d4,$89,$ed
                    fcb       $1c,$1b,$86,$b3,$8b,$72,$ad,$fe,$58,$0c,$42,$7b,$73,$38,$b0
                    fcb       $f9,$1b,$a2,$87,$36,$9e,$8f,$44,$86,$4b,$b7,$7a,$89,$61,$64
                    fcb       $36,$cf,$fc,$7a,$da,$7c,$01,$da,$4c,$dd,$0f,$8c,$8f,$ef,$cb,$fc
                    fdb       $ac59,$90e4,$27f3,$b126,$975f,$a315
                    fdb       $2031,$a1a7,$473c,$28e7,$97c3,$d05b,$3b24,$9401
                    fdb       $b155,$fee6,$f549,$9e74,$bc46,$ac47,$55a4,$d900
                    fdb       $e9fe,$606a,$6980,$6a8e,$68b1,$dcf9,$a5e3,$7665
                    fdb       $11fd,$5a22,$e1c2,$54b8,$47cd,$7096,$7267,$0acf
                    fdb       $eec3,$c104,$4173,$846b,$9585,$ed5d,$763a,$fcc9
                    fdb       $bc16,$6606,$1dd0,$372c,$ff5b,$28e0,$9351,$dd96
                    fdb       $c2dc,$4ac9,$3edc,$db9c,$3f32,$4432,$7bb7,$6740
                    fdb       $648e,$f513,$0b91,$a187,$c3bb,$d82c,$eb7d,$5f37
                    fdb       $ec1d,$8a15,$1fd4,$9a6c,$13fc,$2a11,$66e7,$77e6
                    fdb       $d81c,$5ffd,$f967,$a2d9,$8148,$a505,$4207,$7cc7
                    fdb       $9a73,$e9cb,$afd0,$62f9,$16b1,$b1bf,$6381,$c633
                    fdb       $235d,$5e93,$729b
                    fcb       $19
L5967
                    fcb       $00
                    fdb       $0000,$0000,$0000,$0000
                    fdb       $0000,$0000,$0000,$ffff,$ffff,$ffff,$ffff,$ffff
                    fdb       $ffff,$fffe,$fefe,$fefe,$fefe,$fefe,$fefe,$fdfd
                    fdb       $fdfd,$fdfd,$fdfd,$fdfc,$fcfc,$fcfc,$fcfc,$fbfb
                    fdb       $fbfb,$fbfb,$fafa,$fafa,$faf9,$f9f9,$f9f8,$f8f8
                    fdb       $f7f7,$f7f6,$f6f6,$f5f5,$f4f4,$f4f3,$f3f2,$f2f1
                    fdb       $f1f0,$f0ef,$efee,$eeed,$ecec,$ebeb,$eae9,$e9e8
                    fdb       $e7e7,$e6e5,$e5e4,$e3e2,$e2e1,$e0df,$dede,$dddc
                    fdb       $dbda,$d9d9,$d8d7
                    fcb       $d6

L59E7
                    fcb       $00
                    fdb       $0006,$420c,$8312,$c218
                    fdb       $fe1f,$3625,$6a2b,$9831,$bf37,$de3d,$f544,$034a

                    fdb       $054f,$fd55,$e85b,$c561,$9567,$566d,$0672,$a678
                    fdb       $347d,$b083,$1888,$6c8d,$ab92,$d497,$e79c,$e2a1
                    fdb       $c5a6,$8fab,$3faf,$d5b4,$4fb8,$aebc,$f1c1,$16c5
                    fdb       $1ec9,$07cc,$d1d0,$7bd4,$06d7,$70da,$b8dd,$dfe0
                    fdb       $e3e3,$c5e6,$84e9,$1feb,$96ed,$e9f0,$17f2,$21f4
                    fdb       $05f5,$c3f7,$5bf8,$cdfa,$19fb,$3efc,$3dfd,$15fd
                    fdb       $c5fe,$4ffe,$b1fe,$ecff
                    fcb       $00
L5A69
                    fcb       $00
                    fdb       $0000,$0000,$0000
                    fdb       $0004,$0c14,$1c24,$2c34,$3c43,$494f,$555b,$6167
                    fdb       $6d72,$767a,$7d7f,$7f7f,$7f80,$8080,$8081,$8387
                    fdb       $8b8f,$959b,$a1a7,$adb3,$b9bf,$c7cf,$d7df,$e7ef
                    fdb       $f7ff,$ffff,$ffff,$ffff
                    fcb       $ff
L5AA9
                    fcb       $21
                    fdb       $2426,$2e2e,$2124
                    fdb       $2626,$2e21,$2424,$262e
                    fcb       $21
L5AB9               fcb       $01
                    fdb       $0a19,$1f1f,$010a
                    fdb       $1919,$1f01,$0a0a,$191f
                    fcb       $01
L5AC9               fcb       $20
                    fdb       $110d,$0b09,$0705
                    fdb       $0404,$0404,$0404,$0404
                    fcb       $04
L5AD9
                    fcb       $34
                    fdb       $2624,$0034,$2624
                    fdb       $0034,$2624,$0034,$2624,$002e,$1d02
                    fcb       $12
L5AED
                    fcb       $22
                    fdb       $0400
                    fdb       $0026,$2204,$0034,$2624,$0034,$2624,$0005,$0a10
                    fcb       $12
L5B01
                    fdb       $0000,$0000,$2204,$0000,$2622,$0400,$3426,$2400
                    fdb       $3f3f,$3f3f

                    emod
eom                 equ       *
                    end
