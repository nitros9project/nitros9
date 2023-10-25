********************************************************************
* debug - 6809/6309 debugger
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   6      ????/??/??
* From Tandy OS-9 Level Two VR 02.00.01.
*
*   9      2003/01/03  Boisy G. Pitre
* From Tandy OS-9 Level Two Development System, back-ported to
* OS-9 Level One.
*
*  10      2003/01/05  Boisy G. Pitre
* Start of optimizations, works under NitrOS-9.
*
*  11      2004/06/23  Boisy G. Pitre
* Verbose error messages, added System Debug code for potential
* system-state debugger talking to an A6551 at $FF68.

                    nam       debug
                    ttl       6809/6309 debugger

* Disassembled 02/07/06 13:05:58 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

* Changable settings
NumBrkPt            equ       12                  number of breakpoints
BuffSiz             equ       $145
UnknSiz             equ       80

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       11

L0000               mod       eom,name,tylg,atrv,start,size

                    org       0
curraddr            rmb       2
regstack            rmb       2
u0004               rmb       2
buffptr             rmb       2
u0008               rmb       2
prevaddr            rmb       2
bptable             rmb       2
isnarrow            rmb       1
* extra memory allocated at start
                    rmb       (NumBrkPt*3)
                    rmb       UnknSiz
                    rmb       BuffSiz
                    rmb       R$Size
                    rmb       44
size                equ       .

* Debugger Errors
E$BadCnt            equ       0                   illegal constant
E$ZerDiv            equ       1                   divide by zero
E$MulOvf            equ       2                   product > 65535
E$OpMsng            equ       3                   operator not follwed by legal operand
E$RParen            equ       4                   right paren missing
E$RBrckt            equ       5                   right bracket missing
E$RABrkt            equ       6                   right angle bracket > missing
E$IllReg            equ       7                   illegal register
E$BytOvf            equ       8                   value > 255 for byte
E$CmdErr            equ       9                   illegal command
E$NotRAM            equ       10                  memory is ROM
E$BPTFull           equ       11                  breakpoint table full
E$NoBkPt            equ       12                  breakpoint not found
E$BadSWI            equ       13                  Illegal SWI

name                equ       *
                    ifeq      SYSDEBUG-1
                    fcc       /sys/
                    endc
                    fcs       /debug/
                    fcb       edition

* Convert word in D to Hex string at X and add space
Word2HexSpc
                    bsr       Word2Hex
                    bra       L0019
L0017               bsr       Byte2Hex
L0019               pshs      a
                    lda       #C$SPAC
                    sta       ,x+
                    puls      pc,a

* Convert word in D to Hex string at X
Word2Hex            exg       a,b                 swap A/B
                    bsr       Byte2Hex            work on upper 16 bits (now in B)
                    tfr       a,b                 and work on B
* Convert byte in B to Hex string at X
Byte2Hex            pshs      b                   save copy of B on stack
                    andb      #$F0                mask upper nibble
                    lsrb                          and bring to lower nibble
                    lsrb
                    lsrb
                    lsrb
                    bsr       Nibl2Hex            convert byte in B to ASCII
                    puls      b                   get saved B
                    andb      #$0F                do lower nibble
* Convert lower nibble in B to Hex character at X
Nibl2Hex            cmpb      #$09                9?
                    bls       n@                  branch if lower/same
                    addb      #$07                else add 7
n@                  addb      #'0                 and ASCII 0
                    stb       ,x+                 save B
                    rts

* Convert byte in B to Decimal string at X (3 places)
Word2Dec3
                    pshs      u,y,b
                    clra
                    leau      <DeciTbl+4,pcr      point to deci-table
                    ldy       #$0003              number of decimal places
                    bra       w1
* Convert word in D to Decimal string at X (5 places)
Word2Dec5
                    pshs      u,y,b
                    leau      <DeciTbl,pcr        point to deci-table
                    ldy       #$0005              number of decimal places
w1                  clr       ,s                  clear byte on stack
w2                  subd      ,u                  subtract current place from D
                    bcs       w3                  branch if negative
                    inc       ,s                  else increment place
                    bra       w2                  and continue
w3                  addd      ,u++                re-normalize D
                    pshs      b                   save B
                    ldb       $01,s               get saved B
                    addb      #'0                 add ASCII 0
                    stb       ,x+                 and save
                    puls      b                   retrieve saved B
                    leay      -$01,y              subtract Y
                    bne       w1                  branch if not done
                    puls      pc,u,y,b

DeciTbl             fdb       10000,1000,100,10,1

* Evaluate number specifier at X
EvalSpec            lbsr      EatSpace            skip spaces
                    leax      $01,x               point after byte in A
                    cmpa      #'#                 decimal specifier?
                    beq       DoDec               branch if so
                    cmpa      #'%                 binary specifier?
                    beq       DoBin               branch if so
                    cmpa      #'$                 hex specifier?
                    beq       DoHex               branch if so
                    leax      -$01,x              back up

* Make hex number
DoHex               leas      -$04,s              make room on stack for hex
                    bsr       Clr4                clear bytes on stack
L0086               bsr       AtoInt              get integer value at ,X
                    bcc       L00A0               branch if ok
                    cmpb      #'A                 may be hex digit.. check for
                    lbcs      L0110               branch if not
                    cmpb      #'F                 check upperbound
                    bls       L009E               branch if ok
                    cmpb      #'a                 now check lowercase
                    bcs       L0110               branch if not
                    cmpb      #'f                 check upperbound
                    bhi       L0110               branch if not ok
                    subb      #$20                else make uppercase
L009E               subb      #$37                and get value
L00A0               stb       ,s                  save value on stack
                    ldd       $02,s               get two bytes from stack
                    bita      #$F0                upper nibble set?
                    bne       L0123               branch if so
                    ifne      H6309
                    lsld
                    lsld
                    lsld
                    lsld
                    else
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    endc
                    addb      ,s
                    adca      #$00
                    std       $02,s
                    inc       $01,s
                    bra       L0086

* Make decimal number
DoDec               leas      -$04,s              make room on stack
                    bsr       Clr4                clear it
L00BE               bsr       AtoInt              convert ASCII char in A
                    bcs       L0110
                    stb       ,s                  save integer char
                    ldd       $02,s               get word on stack
                    ifne      H6309
                    lsld
                    else
                    lslb
                    rola                          D * 2
                    endc
                    std       $02,s               save
                    ifne      H6309
                    lsld
                    lsld
                    else
                    lslb
                    rola                          D * 4
                    lslb
                    rola                          D * 8
                    endc
                    bcs       L0123
                    addd      $02,s               add to word on stack
                    bcs       L0123
                    addb      ,s
                    adca      #$00
                    bcs       L0123
                    std       $02,s
                    inc       $01,s
                    bra       L00BE

* Make binary number
DoBin               leas      -$04,s              make room on stack
                    bsr       Clr4                clear it
L00E4               ldb       ,x+                 get char at X
                    subb      #'0                 subtract ASCII 0
                    bcs       L0110               branch if lower
                    lsrb                          divide by 2
                    bne       L0110               branch if not zero
                    rol       $03,s               multiply 2,s * 2
                    rol       $02,s
                    bcs       L0123               branch if carry set
                    inc       $01,s
                    bra       L00E4               get next char

* Clear 4 bytes on stack
* Exit:
*   A,B = 0
Clr4                equ       *
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       $02,s
                    std       $04,s
                    rts

* ASCII to Integer
* Entry:
*   X = address where byte is
* Exit:
*   X = address + 1
*   Carry = clear: B = integer
*   Carry = set: B = ASCII char value
AtoInt              ldb       ,x+                 get char at X
                    cmpb      #'0                 zero?
                    bcs       L0108               branch if lower
                    cmpb      #'9                 9?
                    bls       L010B               branch if lower/same
L0108               orcc      #Carry              else set carry
                    rts                           and return
L010B               subb      #'0                 get real value
                    andcc     #^Carry             clear carry
                    rts                           return

L0110               leax      -$01,x              back up X by 1
                    tst       $01,s
                    beq       L011C
                    ldd       $02,s
                    andcc     #^Carry
                    bra       L0120
L011C               orcc      #Zero
L011E               orcc      #Carry
L0120               leas      $04,s
                    rts
L0123               andcc     #^Zero
                    bra       L011E

* Eat spaces
EatSpace            lda       ,x+
                    cmpa      #C$SPAC
                    beq       EatSpace
                    leax      -$01,x
                    rts

* Multiply B,X * A
MulAxBX             pshs      x,b,a
                    lda       $03,s               get bits 7-0 of X
                    mul                           multiply * b
                    pshs      b,a                 store product on stack
                    lda       $02,s               get A on stack
                    ldb       $04,s               and bits 15-8 of X
                    mul                           multiply
                    pshs      b,a                 store product
                    lda       $04,s               get A on stack
                    ldb       $07,s               and bits 7-0 of X
                    bsr       L0157
                    lda       $05,s
                    ldb       $06,s
                    bsr       L0157
                    andcc     #^Carry
                    ldd       $02,s
                    ldx       ,s
                    beq       L0154
                    orcc      #Carry
L0154               leas      $08,s
                    rts
L0157               mul
                    addd      $03,s
                    std       $03,s
                    bcc       L0160
                    inc       $02,s
L0160               rts
L0161               pshs      y,x,b,a
                    ldd       ,s
                    bne       L016B
                    orcc      #Carry
                    bra       L018B
L016B               ldd       #$0010
                    stb       $04,s
                    clrb
L0171               lsl       $03,s
                    rol       $02,s
                    rolb
                    rola
                    subd      ,s
                    bmi       L017F
                    inc       $03,s
                    bra       L0181
L017F               addd      ,s
L0181               dec       $04,s
                    bne       L0171
                    tfr       d,x
                    ldd       $02,s
                    andcc     #^Carry
L018B               leas      $06,s
                    rts

* Copy from Y to X until byte zero is encountered
l@                  sta       ,x+
CopyY2X             lda       ,y+
                    bne       l@
                    rts

L0195               pshs      u,y
                    tfr       s,u
                    bsr       L01A7
                    andcc     #^Carry
                    puls      pc,u,y

L019F               tfr       u,s
                    orcc      #Carry
                    puls      pc,u,y

L01A5               leax      $01,x
L01A7               bsr       L01C9
                    pshs      b,a
L01AB               bsr       L021D
                    cmpa      #'-                 subtract?
                    bne       L01B9
                    bsr       L01C7
                    nega
                    negb
                    sbca      #$00
                    bra       L01BF
L01B9               cmpa      #'+                 add?
                    bne       L01C5
                    bsr       L01C7
L01BF               addd      ,s
                    std       ,s
                    bra       L01AB
L01C5               puls      pc,b,a
L01C7               leax      $01,x
L01C9               bsr       L01FD
                    pshs      b,a
L01CD               bsr       L021D
                    cmpa      #'*                 multiply?
                    bne       L01E2
                    bsr       L01FB
                    pshs      x
                    ldx       $02,s
                    lbsr      MulAxBX
                    bcc       L01F5
                    ldb       #E$MulOvf
                    bra       L019F
L01E2               cmpa      #'/                 divide?
                    bne       L01C5
                    bsr       L01FB
                    pshs      x
                    ldx       $02,s
                    lbsr      L0161
                    bcc       L01F5
                    ldb       #E$ZerDiv
                    bra       L019F
L01F5               puls      x
                    std       ,s
                    bra       L01CD
L01FB               leax      $01,x
L01FD               bsr       L0222
                    pshs      b,a
L0201               bsr       L021D
                    cmpa      #'&                 logical and?
                    bne       L020F
                    bsr       L0220
                    andb      $01,s
                    anda      ,s
                    bra       L0219
L020F               cmpa      #'!                 logical or?
                    bne       L01C5
                    bsr       L0220
                    orb       $01,s
                    ora       ,s
L0219               std       ,s
                    bra       L0201
L021D               lbra      EatSpace
L0220               leax      $01,x
L0222               bsr       L021D
                    cmpa      #'^                 logical not?
                    bne       L022E
                    bsr       ParsExp
                    comb                          not B
                    coma                          not A
                    bra       L0238
L022E               cmpa      #'-                 negate?
                    bne       L023B
                    bsr       ParsExp
                    nega
                    negb
                    sbca      #$00
L0238               rts

ParsExp             leax      $01,x
L023B               bsr       L021D
                    cmpa      #'(                 open paren?
                    bne       L0250
                    lbsr      L01A5
                    pshs      b,a
                    bsr       L021D
                    cmpa      #')                 close paren?
                    beq       L0282
                    ldb       #E$RParen
                    bra       L0265
L0250               cmpa      #'[
                    bne       L026A
                    lbsr      L01A5
                    tfr       d,y
                    ldd       ,y
                    pshs      b,a
                    bsr       L021D
                    cmpa      #']
                    beq       L0282
                    ldb       #E$RBrckt
L0265               leas      $02,s
L0267               lbra      L019F
L026A               cmpa      #'<
                    bne       L0286
                    lbsr      L01A5
                    tfr       d,y
                    clra
                    ldb       ,y
                    pshs      b,a
                    bsr       L021D
                    cmpa      #'>
                    beq       L0282
                    ldb       #E$RABrkt
                    bra       L0265
L0282               leax      $01,x
                    puls      pc,b,a

L0286               cmpa      #C$PERD
                    bne       L028F
                    ldd       <curraddr
                    leax      $01,x
                    rts

L028F               cmpa      #''                 ASCII byte?
                    bne       L0297
                    ldd       ,x++
                    clra
                    rts

L0297               cmpa      #'"                 ASCII word?
                    bne       L02A0
                    leax      $01,x               point past quote char
                    ldd       ,x++
                    rts

L02A0               cmpa      #':
                    bne       L02B4
                    leax      $01,x
                    bsr       GetReg              get register that follows :
                    bcs       L0267               branch if error
                    tsta                          is this byte or word register?
                    bmi       L02B1               branch if word
                    clra                          else clear hi byte
                    ldb       ,y                  and get byte at offset
                    rts
L02B1               ldd       ,y                  get word at offset
L02B3               rts                           return

L02B4               lbsr      EvalSpec            evaluate number specifier
                    bcc       L02B3
                    beq       L02BF
                    ldb       #E$OpMsng
                    bra       L0267
L02BF               ldb       #E$BadCnt
                    bra       L0267

* Parse individual register
* Entry:
*   X = address of register to find
* Exit:
*   A = register offset value in table
*   Y = ptr to register offset in stack
GetReg              ldb       #RegEnts            get number of register entries
                    pshs      b
                    ldd       ,x                  get first two chars in D
                    cmpd      #$7370              sp?
                    beq       L02D5               branch if so
                    cmpd      #$5350              SP?
                    bne       L02E2               branch if not
L02D5               leax      $02,x               move past two chars
                    ldd       #$0002
                    tfr       dp,a
                    tfr       d,y
                    lda       #$80
                    bra       L0314
L02E2               leay      >RegList,pcr
L02E6               lda       ,y                  get first char of register entry
                    ldb       $01,y               get second char of register entry
                    bne       L02F8               branch if two chars
                    cmpa      ,x                  same as user input?
                    beq       L0307               yes, a match
                    adda      #$20                make lowercase
                    cmpa      ,x                  same as user input?
                    beq       L0307               yes, a match
                    bra       L0318
L02F8               cmpd      ,x                  same as user input?
                    beq       L0305               yes, a match
                    addd      #$2020              make uppercase
                    cmpd      ,x                  same as user input?
                    bne       L0318               branch if not
L0305               leax      $01,x               point X to next char
L0307               leax      $01,x               point X to next char
                    lda       $02,y               get offset
                    tfr       a,b                 transfer to B
                    andb      #$0F                mask off hi nibble
                    ldy       <regstack           get stack in Y
                    leay      b,y                 move Y to offset in stack
L0314               andcc     #^Carry             clear carry
                    puls      pc,b                return

L0318               leay      $03,y
                    dec       ,s
                    bne       L02E6
                    orcc      #Carry
                    puls      pc,b

* Register list for 6809/6309
RegList             fcc       "CC"
                    fcb       R$CC
                    fcc       "DP"
                    fcb       R$DP
                    fcc       "PC"
                    fcb       $80+R$PC
                    fcc       "A"
                    fcb       $00,R$A
                    fcc       "B"
                    fcb       $00,R$B
                    fcc       "D"
                    fcb       $00,$80+R$A
                    ifne      H6309
                    fcc       "E"
                    fcb       $00,R$E
                    fcc       "F"
                    fcb       $00,R$F
                    fcc       "W"
                    fcb       $00,$80+R$E
                    endc
                    fcc       "X"
                    fcb       $00,$80+R$X
                    fcc       "Y"
                    fcb       $00,$80+R$Y
                    fcc       "U"
                    fcb       $00,$80+R$U
RegEnts             equ       (*-RegList)/3

start
                    ifeq      SYSDEBUG-1
                    lbsr      Init
                    endc
                    leas      >size,u             point S to end of memory
                    leas      -R$Size,s           back off size of register stack
                    sts       <regstack           save off
                    sts       <u0004
                    leay      >DefBrk,pcr
                    sty       R$PC,s
                    lda       #Entire
                    sta       R$CC,s
                    tfr       s,x                 X = size-R$Size
                    leax      >-BuffSiz,x         back off appropriate byte count
                    stx       <buffptr            and save off ptr for line buffer
                    leax      <-UnknSiz,x         back off more
                    stx       <u0008
                    leax      <-NumBrkPt*3,x
                    stx       <bptable            save pointer to breakpoint table
                    clr       <curraddr
                    clr       <curraddr+1
                    clr       <isnarrow
                    ifeq      SYSDEBUG
                    pshs      y,x,b,a
                    lda       #$01                stdout
                    ldb       #SS.ScSiz           get screen size
                    os9       I$GetStt            do it!
                    bcc       L0380
                    cmpb      #E$UnkSvc
                    beq       L0387
                    puls      x,y,b,a
                    lbra      L0735
L0380               cmpx      #51                 51 columns?
                    bge       L0387               branch if so
                    inc       <isnarrow
L0387               puls      x,y,b,a
                    endc

* Clear breakpoint table
L036A               clr       ,x+
                    cmpx      <buffptr
                    bcs       L036A
                    leax      >IcptRtn,pcr
                    lda       #$01                SSWI Vector 1
                    os9       F$SSWi              set software interrupt routine
                    os9       F$Icpt              set intercept routine
                    lbsr      WritCR              write carriage return
                    ldx       <buffptr
                    leay      >Title,pcr          point to title
*         bsr  L03C2		print it
                    lbsr      CopyY2X             print it
                    lbsr      WritLnOut

* Show prompt and get input from standard input to process
GetInput            leay      >Prompt,pcr         point to prompt
                    lbsr      PrintY              print it
                    lbsr      ReadLine            read line from std input
                    leay      >CmdTbl,pcr         point to command table
                    lda       ,x                  get character from read buffer
                    cmpa      #'a                 compare against lowercase a
                    bcs       L03A2               branch if lower
                    suba      #$20                make uppercase
                    sta       ,x                  and save
L03A2               leay      $03,y               walk through table
                    lda       ,y                  get char to compare against in A
                    beq       SyntxErr            branch if done
                    cmpa      ,x                  same?
                    bne       L03A2               if not, get next
* Here we have a command match, dispatch it
                    leax      $01,x               move past char
                    ldd       $01,y               get handle address
                    leau      >L0000,pcr          point to start of module
                    jsr       d,u                 and branch to subroutine
                    bra       GetInput

* Command wasn't recognized
SyntxErr            ldb       #E$CmdErr
                    bsr       ShowErr
                    bra       GetInput

ShowErr
                    cmpb      #E$BadSWI
                    bhi       ShowErrNum

                    leay      ETable,pcr          point to error string table
                    lslb                          multiply index by 2
                    ldd       b,y                 and get address in X
                    leay      d,y
                    ldx       <buffptr
                    lbsr      CopyY2X
                    lbra      WritLnErr

ShowErrNum
                    ifeq      SYSDEBUG
                    os9       F$PErr
                    rts
                    else
                    pshs      b
                    leay      ErrMsg,pcr
                    ldx       <buffptr
                    lbsr      CopyY2X
                    puls      b
                    lbsr      Word2Dec3
                    lbra      WritLnErr

ErrMsg              fcc       /ERROR #/
                    fcb       0
                    endc

ETable              fdb       E0-ETable
                    fdb       E1-ETable
                    fdb       E2-ETable
                    fdb       E3-ETable
                    fdb       E4-ETable
                    fdb       E5-ETable
                    fdb       E6-ETable
                    fdb       E7-ETable
                    fdb       E8-ETable
                    fdb       E9-ETable
                    fdb       E10-ETable
                    fdb       E11-ETable
                    fdb       E12-ETable
                    fdb       E13-ETable

E0                  fcc       "Illegal constant"
                    fcb       0
E1                  fcc       "Divide by zero"
                    fcb       0
E2                  fcc       "Multiply overflow"
                    fcb       0
E3                  fcc       "Illegal operand"
                    fcb       0
E4                  fcc       ") missing"
                    fcb       0
E5                  fcc       "} missing"
                    fcb       0
E6                  fcc       "] missing"
                    fcb       0
E7                  fcc       "Illegal register"
                    fcb       0
E8                  fcc       "Byte overflow"
                    fcb       0
E9                  fcc       "Illegal command"
                    fcb       0
E10                 fcc       "ROM Memory"
                    fcb       0
E11                 fcc       "Breakpoint table full"
                    fcb       0
E12                 fcc       "Breakpoint not found"
                    fcb       0
E13                 fcc       "Illegal SWI"
                    fcb       0


*L03C2    lbra  CopyY2X

* Show byte at current memptr
DotCmd              lda       ,x                  get byte after cmd byte
                    cmpa      #C$PERD             is it a period?
                    bne       L03CF               branch if not
                    ldd       <prevaddr           else get previous address
                    bra       L03DC
L03CF               cmpa      #C$CR               cr?
                    bne       L03D7               branch if not
L03D3               ldd       <curraddr
                    bra       L03DC
L03D7               lbsr      L0195
                    lbcs      ShowErr
L03DC               ldx       <curraddr           get current memory loc
                    stx       <prevaddr           store in previous memory loc
                    std       <curraddr           and save D in new memory loc
                    pshs      b,a
                    bsr       L0415
                    ldd       ,s
                    lbsr      Word2HexSpc
                    puls      y
                    ldb       ,y
                    lbsr      Byte2Hex
                    lbra      WritLnOut

* Show previous byte
PrevByte            ldd       <curraddr           get current memory address
                    ifne      H6309
                    decd
                    else
                    subd      #$0001              subtract 1
                    endc
                    bra       L03DC

* Set byte at current location
SetLoc              bsr       L043F
                    lbcs      ShowErr
                    ldx       <curraddr
                    stb       ,x                  store byte at curraddr
                    cmpb      ,x                  compare (in case it is ROM)
                    beq       NextByte            branch if equal
                    ldb       #E$NotRAM           else load B with error
                    lbsr      ShowErr             and show it
                    bra       L03D3

* Show next byte
NextByte            ldd       <curraddr           get current memory address
                    ifne      H6309
                    incd
                    else
                    addd      #$0001              add one to it
                    endc
                    bra       L03DC
L0415               ldx       <buffptr            load X with buffer pointer
                    pshs      b,a
                    leay      >Spaces,pcr         point to spaces
*         bsr   L03C2
                    lbsr      CopyY2X
                    puls      pc,b,a

* Calc expression
Calc                lbsr      L0195
                    lbcs      ShowErr
                    bsr       L0415
                    pshs      b,a
                    lda       #'$                 hex prefix
                    sta       ,x+
                    lda       ,s
                    lbsr      Word2HexSpc
                    lda       #'#                 decimal prefix
                    sta       ,x+
                    puls      b,a
                    lbsr      Word2Dec5
                    lbra      WritLnOut
L043F               lbsr      L0195
                    bcs       L044B
                    tsta
                    beq       L044B
                    ldb       #E$BytOvf
                    orcc      #Carry
L044B               rts

* Show all registers
ShowRegs            lbsr      L0512
                    beq       L04AF
                    lbsr      GetReg
                    lbcs      ShowErr
                    pshs      y,a                 save pointer to register and offset
                    lbsr      L0512
                    bne       L0475
                    bsr       L0415
                    puls      y,a                 retreive pointer to register and offset
                    tsta                          test A
                    bpl       L046D               branch if positive, means one byte3
                    ldd       ,y                  load D with two bytes
                    lbsr      Word2Hex
                    bra       L0472
L046D               ldb       ,y                  load B with one byte
                    lbsr      Byte2Hex
L0472               lbra      WritLnOut
L0475               lda       ,s+
                    bpl       L0485
                    lbsr      L0195
                    puls      y
                    lbcs      L054E
                    std       ,y
                    rts
L0485               bsr       L043F
                    puls      y
                    lbcs      L054E
                    stb       ,y
                    rts

ShrtHdr             fcc       "PC="
                    fcb       $00
                    fcc       "A="
                    fcb       $00
                    fcc       "B="
                    fcb       $00
                    ifne      H6309
                    fcc       "E="
                    fcb       $00
                    fcc       "F="
                    fcb       $00
                    endc
                    fcc       "CC="
                    fcb       $00
                    fcc       "DP="
                    fcb       $00
                    fcc       "SP="
                    fcb       $00
                    fcc       "X="
                    fcb       $00
                    fcc       "Y="
                    fcb       $00
                    fcc       "U="
                    fcb       $00

L04AF               tst       <isnarrow           wide screen?
                    beq       WidRegs             branch if so
                    pshs      u                   save U
                    ldx       <buffptr            point to buffer
                    leay      <ShrtHdr,pcr
                    ldu       <regstack
                    lbsr      CopyY2X
                    ldd       R$PC,u
                    ifne      H6309
                    lbsr      L0505
                    else
                    bsr       L0505
                    endc
                    lbsr      CopyY2X
                    ldb       R$A,u
                    ifne      H6309
                    lbsr      L050F
                    else
                    bsr       L050F
                    endc
                    lbsr      CopyY2X
                    ldb       R$B,u
                    ifne      H6309
                    lbsr      L050F
                    else
                    bsr       L050F
                    endc
                    lbsr      CopyY2X
                    ifne      H6309
                    ldb       R$E,u
                    bsr       L050F
                    lbsr      CopyY2X
                    ldb       R$F,u
                    bsr       L050F
                    pshs      y
                    lbsr      WritLnOut
                    puls      y
                    lbsr      CopyY2X
                    endc
                    ldb       R$CC,u
                    bsr       L050F
                    lbsr      CopyY2X
                    ldb       R$DP,u
                    bsr       L050F
                    ifeq      H6309
                    pshs      y
                    lbsr      WritLnOut
                    puls      y
                    endc
                    lbsr      CopyY2X
                    tfr       u,d
                    bsr       L0505
                    lbsr      CopyY2X
                    ldd       R$X,u
                    bsr       L0505
                    ifne      H6309
                    pshs      y
                    lbsr      WritLnOut
                    puls      y
                    endc
                    lbsr      CopyY2X
                    ldd       R$Y,u
                    bsr       L0505
                    lbsr      CopyY2X
                    ldd       R$U,u
                    bsr       L0505
                    lbsr      WritLnOut
                    puls      pc,u
* Show registers in wide form
WidRegs             lbsr      L0415
                    leay      >RegHdr,pcr
                    lbsr      CopyY2X
                    lbsr      WritLnOut
                    lbsr      L0415
                    ldd       <regstack
                    bsr       L0505               show SP
                    ldy       <regstack
                    bsr       L050D               show CC
                    bsr       L050D               show A
                    bsr       L050D               show B
                    ifne      H6309
                    bsr       L050D               show E
                    bsr       L050D               show F
                    endc
                    bsr       L050D               show DP
                    bsr       L0550               show X
                    bsr       L0550               show Y
                    bsr       L0550               show U
                    bsr       L0550               show PC
                    lbra      WritLnOut

L0550               ldd       ,y++
L0505               lbra      Word2HexSpc
L0508               ldd       ,y++
                    lbra      Word2Hex
L050D               ldb       ,y+
L050F               lbra      L0017

* Eat spaces and compare char with CR
L0512               lbsr      EatSpace
                    cmpa      #C$CR
                    rts

* Set/show breakpoints
SetBkpt             bsr       L0512               any parameters?
                    bne       L0538               branch if so
* Here we show all breakpoints
                    lbsr      L0415
                    ldy       <bptable            get breakpoints base
                    ldb       #NumBrkPt           get breakpoint count
                    pshs      b                   save on stack
L0526               ldd       ,y                  empty?
                    beq       L052D               branch if so
                    lbsr      Word2HexSpc         else show breakpoint at Y
L052D               leay      $03,y
                    dec       ,s                  dec breakpoint count
                    bne       L0526               continue searching
                    leas      $01,s               kill byte on stack
                    lbra      WritLnOut
* Set breakpoint here
L0538               lbsr      L0195
                    bcs       L054E
                    pshs      b,a                 save desired breakpoint address
                    bsr       SrchBkpt            search to see if it is already in table
                    beq       L0551               if duplicate, just exit
                    ifne      H6309
                    clrd                          else load D with empty address
                    else
                    ldd       #$0000              else load D with empty address
                    endc
                    bsr       SrchBkpt            search for empty
                    beq       L0551               branch if found
                    ldb       #E$BPTFull          else table is full
                    leas      $02,s               clean up stack
L054E               lbra      ShowErr             and show error
L0551               puls      b,a                 get breakpoint address off stack
                    std       ,y                  and save it at breakpoint entry
                    rts                           then return

* Search for existing breakpoint that matches address in D
SrchBkpt            pshs      u                   save U
                    tfr       d,u                 transfer addr to search in U
                    ldb       #NumBrkPt           get number of breakpoints
                    ldy       <bptable            point Y to base of breakpoints
L055F               cmpu      ,y                  match?
                    beq       L056D               branch if so
                    leay      $03,y               else move to next entry
                    decb                          dec couner
                    bne       L055F               if not 0, continue search
                    ldb       #E$NoBkPt
                    andcc     #^Zero
L056D               puls      pc,u

* Kill breakpoint(s)
KillBkpt            bsr       L0512               any parameters?
                    beq       KillAll             branch if none
                    lbsr      L0195               else get parameter
                    bcs       L054E               branch if error
                    bsr       SrchBkpt
                    bne       L054E
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       ,y
                    rts
* Kill all breakpoints
KillAll             ldy       <bptable
                    ldb       #NumBrkPt*3
L0586               clr       ,y+
                    decb
                    bne       L0586
                    rts

* Go at address
GoPC                bsr       L0512               any parameters?
                    beq       L059A               branch if none
                    lbsr      L0195
                    bcs       L054E
                    ldy       <regstack           get execution stack
                    std       R$PC,y              save new PC
* Now we set up all breakpoints in memory
L059A               ldy       <bptable
                    ldb       #R$Size             get register size
                    ldx       <regstack           point to registers
                    ldx       R$PC,x              get PC
L05A3               ldu       ,y                  get breakpoint at entry
                    beq       L05B3               branch if empty
                    lda       ,u                  get byte at breakpoint address
                    sta       $02,y               save in breakpoint entry
                    cmpx      ,y                  is breakpoint same as PC?
                    beq       L05B3               branch if so
                    lda       #$3F                else take SWI instruction
                    sta       ,u                  and store it at address of breakpoint
L05B3               leay      $03,y               move to next breakpoint entry
                    decb                          decrement
                    bne       L05A3               branch if not complete
                    lds       <regstack           get execution stack
                    rti                           run program

MemDump             bsr       L0613
                    bcs       L054E
                    tst       <isnarrow
                    bne       L0615
                    orb       #$0F
                    bra       L0617
L0615               orb       #$07
L0617               exg       d,u
                    tst       <isnarrow
                    bne       L0621
                    andb      #$F0
                    bra       L0623
L0621               andb      #$F8
L0623               pshs      u,b,a
                    cmpd      $02,s
                    bcc       L05D9
L05CD               ldy       ,s
                    leay      -$01,y
                    cmpy      $02,s
                    leay      $01,y
                    bcs       L05DB
L05D9               puls      pc,u,b,a
L05DB               ldx       <buffptr
                    tfr       y,d
                    lbsr      Word2HexSpc
                    tst       <isnarrow
                    bne       L0647
                    ldb       #8
                    bra       L0649
L0647               ldb       #4
L0649               pshs      b
L05E6               tst       <isnarrow
                    bne       L0654
                    lbsr      L0550
                    bra       L0657
L0654               lbsr      L0508
L0657               dec       ,s
                    bne       L05E6
                    tst       <isnarrow
                    bne       L0663
                    ldb       #16
                    bra       L0668
L0663               lbsr      L0019
                    ldb       #8
L0668               stb       ,s
                    ldy       $01,s
L05F7               lda       ,y+
                    cmpa      #'~
                    bhi       L0601
                    cmpa      #C$SPAC
                    bcc       L0603
L0601               lda       #'.
L0603               sta       ,x+
                    dec       ,s
                    bne       L05F7
                    leas      $01,s
                    sty       ,s
                    lbsr      WritLnOut
                    bra       L05CD
L0613               lbsr      L0195
                    bcs       L061D
                    tfr       d,u
                    lbsr      L0195
L061D               rts

ClearMem            bsr       L0613
                    lbcs      ShowErr
                    pshs      b,a                 save fill word
L0626               cmpu      ,s
                    bls       L062D
                    puls      pc,b,a
L062D               ldd       #$8008
                    sta       ,u
L0632               cmpa      ,u
                    bne       L063E
                    lsra
                    lsr       ,u
                    decb
                    bne       L0632
                    bra       L064E
L063E               lbsr      L0415
                    ldd       #$2D20              dash, space
                    std       ,x++
                    tfr       u,d
                    lbsr      Word2Hex
                    lbsr      WritLnOut
L064E               leau      1,u
                    bra       L0626

* Intercept routine
IcptRtn             equ       *
                    ifne      H6309
                    tfr       0,dp
                    else
                    clra
                    tfr       a,dp
                    endc
                    ifeq      Level-1
                    ldx       <D.Proc             get curr proc ptr
                    lda       P$ADDR,x            get hi word of user addr
                    tfr       a,dp                transfer it to DP
                    endc
                    sts       <regstack
                    ldd       R$PC,s
                    ifne      H6309
                    decd
                    else
                    subd      #$0001
                    endc
                    std       R$PC,s
                    lds       <u0004
                    lbsr      SrchBkpt
                    beq       L0672
                    ldb       #E$BadSWI
                    lbsr      ShowErr
* Clear breakpoints in memory
L0672               ldy       <bptable            point to break point table
                    ldb       #NumBrkPt           get number of entries
L0677               ldx       ,y                  get address in entry
                    beq       L067F               branch if empty
                    lda       $02,y               get saved byte
                    sta       ,x                  restore it
L067F               leay      $03,y               move to next entry
                    decb                          dec counter
                    bne       L0677               continue if not zero
                    lbsr      WritCR
                    lbsr      L0415
                    leay      >BkPtHdr,pcr
                    lbsr      CopyY2X
                    lbsr      WritLnOut
                    lbsr      L04AF
                    lbra      GetInput

LinkMod             bsr       LinkIt              link to module
                    lbcs      ShowErr             branch if error
                    ldx       <buffptr
                    tfr       u,d
                    pshs      u
                    lbsr      L03DC
                    lbsr      WritLnOut
                    puls      u
                    bra       L06CC

LinkIt              lbsr      EatSpace            skip over blank spaces at X
*         lda   #$00
                    clra
                    os9       F$Link              link to module name at X
                    rts

* Prepare module for execution
PrepMod             bsr       LinkIt
                    lbcs      ShowErr
                    ldd       M$Mem,u             get memory requirements
                    addd      #512                add an extra 512 bytes
                    os9       F$Mem               allocate, Y = upperbound
                    bcc       UnlinkIt            branch if ok
                    lbsr      ShowErr             show error
L06CC               equ       *
                    ifeq      Level-1
                    os9       F$UnLink
                    endc
                    rts                           and return

UnlinkIt            os9       F$UnLink            unlink module
                    pshs      u,y,x               save u,y,x
L06D5               lda       ,x+                 get next parameter char
                    cmpa      #C$CR               carriage return?
                    bne       L06D5               branch if not
                    clrb                          start at zero
L06DC               lda       ,-x                 get parameter char
                    sta       ,-y                 store in buffer
                    incb                          continue
                    cmpx      ,s                  reached start of parameter?
                    bhi       L06DC               branch if not
                    sty       -R$U,y
                    leay      -R$Size,y
                    sty       <regstack
                    clra
                    std       R$A,y
                    puls      u,x,b,a
                    stx       R$Y,y
                    ldd       M$Exec,u            get exec offset in D
                    leax      d,u                 point X to execution address
                    stx       R$PC,y              save at PC
                    tfr       cc,a
                    ora       #Entire
                    sta       R$CC,y
                    tfr       dp,a
                    adda      #$02
                    clrb
                    std       R$U,y
                    sta       R$DP,y
                    lbra      L04AF

* Fork program (default is shell)
ForkPrg             lbsr      EatSpace            skip leading spaces
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    tfr       x,u                 move param ptr to U
                    tfr       d,y
L0715               leay      $01,y
                    lda       ,x+
                    cmpa      #C$CR
                    bne       L0715
                    clra
                    leax      <ShellNam,pcr
                    os9       F$Fork              fork shell plus any parameters
                    bcs       L0729               branch if error
                    os9       F$Wait              wait for shell to finish
L0729               lbcs      ShowErr             branch if error
                    rts                           and return

ShellNam            fcc       "shell"
                    fcb       $00

* Exit without error
ExitOk              clrb
L0735               os9       F$Exit

* Search for byte or word from . to end address
* Syntax: S endaddr byte
*         S endaddr word
SrchMem             lbsr      L0613
                    lbcs      ShowErr
                    pshs      u
                    ldx       <curraddr
                    tsta                          byte or word?
                    bne       L0750               branch if word
L0746               cmpb      ,x+                 byte in B match byte at ,X?
                    beq       L075C               branch if so
                    cmpx      ,s                  is X equal to end?
                    bne       L0746               branch if not
                    puls      pc,u                else we're done
L0750               cmpd      ,x+                 byte in B match byte at ,X?
                    beq       L075C               branch if so
                    cmpx      ,s
                    bne       L0750               branch if not
                    puls      pc,u
L075C               leax      -$01,x              back up to mem location found
                    tfr       x,d                 put memory location in D
                    leas      $02,s               wipe out stack
                    lbra      L03DC

DefBrk              swi

Title               fcc       "Interactive "
                    ifeq      SYSDEBUG-1
                    fcc       "System "
                    endc
                    fcc       "Debugger"
                    fcb       $00

Prompt
                    ifeq      SYSDEBUG-1
                    fcc       "S"
                    endc
                    fcc       "DB: "
                    fcb       $00
Spaces              fcc       "    "
                    fcb       $00

                    ifne      H6309
RegHdr              fcc       " SP  CC  A  B  E  F DP  X    Y    U    PC"
                    else
RegHdr              fcc       " SP  CC  A  B DP  X    Y    U    PC"
                    endc
                    fcb       $00

BkPtHdr             fcc       "BKPT"
CmdTbl              fcc       ": "
                    fcb       $00
                    fcc       /./
                    fdb       DotCmd
                    fcc       /=/
                    fdb       SetLoc
                    fcb       C$CR
                    fdb       NextByte
                    fcb       C$SPAC
                    fdb       Calc
                    fcc       /-/
                    fdb       PrevByte
                    fcc       /:/
                    fdb       ShowRegs
                    fcc       /K/
                    fdb       KillBkpt
                    fcc       /M/
                    fdb       MemDump
                    fcc       /C/
                    fdb       ClearMem
                    fcc       /B/
                    fdb       SetBkpt
                    fcc       /G/
                    fdb       GoPC
                    fcc       /L/
                    fdb       LinkMod
                    fcc       /E/
                    fdb       PrepMod
                    fcc       /$/
                    fdb       ForkPrg
                    fcc       /Q/
                    fdb       ExitOk
                    fcc       /S/
                    fdb       SrchMem
                    fcb       $00

******** INPUT/OUTPUT ROUTINES ********
*
* WritCR - Write CR to stdout
WritCR              ldx       <buffptr
* Append CR to <buffptr and write to stdout
WritLnOut
                    bsr       cr@
                    bra       llwout
WritLnErr
                    bsr       cr@
                    bra       llwerr
cr@                 lda       #C$CR
                    sta       ,x+
                    ldx       <buffptr
                    ldy       #81
                    rts

PrintY              tfr       y,x
                    tfr       y,u
                    ldy       #$0000
PrintYL             ldb       ,u+                 get next char
                    beq       llwout              write it
                    leay      $01,y               increase Y
                    bra       PrintYL             get more

                    ifeq      SYSDEBUG
llwerr              lda       #$02
                    fcb       $8C
* Write To Standard Output
* Entry:
*    X = address of buffer to write
* Exit:
*    X = address of program's buffptr
llwout              lda       #$01                stdout
                    os9       I$WritLn            write it!
                    ldx       <buffptr
                    rts

* Read From To Standard Input
* Exit:
*    X = address of buffer to data read
ReadLine            ldx       <buffptr            point to buffer
                    ldy       #80                 read up to 80 chars
                    clra                          from stdin
                    os9       I$ReadLn            do it!
                    ldx       <buffptr            reload X with line
                    rts

                    else

* 6551 Parameters
ADDR                equ       $FF68

A_RXD               equ       ADDR+$00
A_TXD               equ       ADDR+$00
A_STATUS            equ       ADDR+$01
A_RESET             equ       ADDR+$01
A_CMD               equ       ADDR+$02
A_CTRL              equ       ADDR+$03

* Baud rates
_B2400              equ       $1A                 2400 bps, 8-N-1
_B4800              equ       $1C                 4800 bps, 8-N-1
_B9600              equ       $1E                 9600 bps, 8-N-1
_B19200             equ       $1F                 19200 bps, 8-N-1

BAUD                equ       _B9600

* Init - Initialize
* Exit: Carry = 0: Init success; Carry = 1; Init failed
Init
                    sta       A_RESET             soft reset (value not important)
* Set specific modes and functions:
* - no parity, no echo, no Tx interrupt
* no Rx interrupt, enable Tx/Rx
                    lda       #$0B
                    sta       A_CMD               save to command register
                    lda       #BAUD
                    sta       A_CTRL              select proper baud rate
* Read any junk rx byte that may be in the register
                    lda       A_RXD
                    rts

* Read - Read one character
* Exit:  A = character that was read
Read
r@                  lda       A_STATUS            get status byte
                    anda      #$08                mask rx buffer status flag
                    beq       r@                  loop if rx buffer empty
                    lda       A_RXD               get byte from ACIA data port
                    rts

* Write - Write one character
* Entry: A = character to write
Write
                    pshs      a                   save byte to write
w@                  lda       A_STATUS            get status byte
                    anda      #$10                mask tx buffer status flag
                    beq       w@                  loop if tx buffer full
                    puls      a                   get byte
                    sta       A_TXD               save to ACIA data port
                    rts

* Term - Terminate
Term
                    rts


* llwout - Write an entire string
* llwerr - Write an entire string
llwerr
llwout
                    pshs      a
l@                  lda       ,x+
                    cmpa      #C$CR
                    beq       e@
                    leay      -1,y
                    beq       f@
                    bsr       Write
                    bra       l@
e@                  bsr       Write
                    lda       #C$LF
                    bsr       Write
f@                  ldx       <buffptr
                    clrb
                    puls      a,pc

* ReadLine - Read an entire string, up to CR
* Entry: X = address to place string being read (CR terminated)
*        Y = maximum number of bytes to read (including nul byte)
ReadLine
                    ldx       <buffptr
                    pshs      y,x,a
                    ldy       #80
l@                  bsr       Read                read 1 character
                    cmpa      #C$CR               carriage return?
                    beq       e@                  branch if so...
                    cmpa      #$08                backspace?
                    beq       bs@
                    cmpy      #$0000              anymore room?
                    beq       l@
                    leay      -1,y                back up one char
                    sta       ,x+                 and save in input buffer
m@                  bsr       Write               echo back out
                    bra       l@
e@                  sta       ,x
                    bsr       Write
                    lda       #C$LF
                    bsr       Write
                    clrb
                    puls      a,x,y,pc
bs@                 cmpx      1,s                 are we at start
                    beq       l@                  if so, do nothing
                    clr       ,-x                 else erase last byte
                    lbsr      Write               write backspace
                    lda       #C$SPAC             a space...
                    lbsr      Write               write it
                    leay      1,y                 count back up free char
                    lda       #$08                another backspace
                    bra       m@

                    endc

                    emod
eom                 equ       *
                    end
