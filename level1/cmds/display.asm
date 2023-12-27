********************************************************************
* Display - Character display utility
*
* $Id: display.asm,v 1.5 2003/09/04 23:06:16 boisy Exp $
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   2      ????/??/??
* Original Tandy/Microware version.
*
*   3      ????/??/??  Alan DeKok
* Added decimal, text features.
*   4      2020/07/04  L.Curtis Boyle
* Fixed bug with '0' characters in decimal conversion

                    nam       Display
                    ttl       Character display utility

* Disassembled 94/12/10 12:27:37 by Alan DeKok

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       4

                    mod       eom,name,tylg,atrv,Start,size

                    org       0
T.Delim             rmb       1                   text delimiter
D.Len               rmb       1                   length of decimal bytes: 0=1 byte, 1=2 bytes
D.Word              rmb       2                   decimal byte to output
                    rmb       200                 room for the stack
size                equ       .

name                fcs       /Display/
                    fcb       edition

Start               pshs      x                   save start address of text to output
                    leay      ,x                  destination buffer=input buffer (always shrinks it)
                    leau      <Hex,pcr            point to routine to ouput hex characters

Loop                jsr       ,u                  grab a character
                    bcs       S.01                if error, dump it
                    stb       ,x+                 save character in internal buffer
                    bra       Loop                and get another one

S.01                tfr       x,d                 get current pointer into D
                    subd      ,s                  take out start address
                    tfr       d,y                 length of the data to print
                    puls      x                   restore start address

                    lda       #$01                to STDOUT
                    os9       I$Write             dump it out
                    bcs       Exit                exit if error

ClnExit             clrb                          no error
Exit                os9       F$Exit              and exit

Do.Hex              leau      <Hex,pcr            point to main hex routine
Hex                 ldb       ,y+                 grab a character
                    cmpb      #C$COMA             comma?
                    bne       Hex.2               nope, do more checks

Hex.1               ldb       ,y+                 grab another character
Hex.2               cmpb      #C$SPAC             space?
                    beq       Hex.1               yup, skip it

                    cmpb      #'/                 slash?
                    beq       Do.Text             yes, go output straight text
                    cmpb      #'\                 back-slash?
                    beq       Do.Text             yes, output straight text
                    cmpb      #'"                 double-quote?
                    beq       Do.Text             yes, output straight text

                    cmpb      #C$PERD             period?
                    beq       Decimal             yes, do a one-time output of decimal byte(s)

                    leay      -1,y
                    bsr       Nibble              turn character in B into a nibble
                    bcs       OK.2
                    pshs      b                   save high nibble
                    bsr       Nibble              get current character
                    bcs       Hex.3               skip move if next character is not a number
                    lsl       ,s                  move low nibble into high nibble
                    lsl       ,s
                    lsl       ,s                  - can't do it before now, because hex number
                    lsl       ,s                  might be 1 digit long

                    addb      ,s                  add high nibble to low nibble
                    stb       ,s                  save it
Hex.3               clrb                          no error
                    puls      b,pc                restore byte to output, and exit

Nibble              ldb       ,y                  get the current character
                    cmpb      #C$CR               end of parameters?
                    beq       Error               yes, exit

                    cmpb      #'0                 error if B<'0'
                    blo       Error

                    cmpb      #'9
                    bls       OK                  allow '0' to '9' inclusive

                    cmpb      #'A                 error if B<'A'
                    blo       Error

                    andb      #$DF                make the character lowercase
                    cmpb      #'F
                    bhi       Error               error if B>'F'

                    subb      #$07                map 'A' down to $0A
OK                  subb      #$30                take out ascii zero, now B=nibble 0-F

OK.0                leay      1,y
OK.1                clra                          set to no error
OK.2                rts

Error               comb                          set carry
                    rts

Do.Text             leau      <Text,pcr
                    stb       <T.Delim            save text delimiter
Text                ldb       ,y+                 grab a character
                    cmpb      <T.Delim            text delimiter again?
                    beq       T.Check             check for some stuff
                    cmpb      #C$CR               end of text?
                    beq       Error               yes, signal it
                    bra       OK.1                otherwise allow the character

T.Check             lda       ,y                  get the next character after the delimiter
                    cmpa      <T.Delim            is it the same, i.e. 2 delimiters in a row?
                    beq       OK.0                yes, skip the second and output the first
                    bra       Do.Hex              otherwise go to hex mode again

Decimal             lda       ,y                  get next character
                    anda      #$DF                make it uppercase
                    cmpa      #'W                 force a word?
                    bne       D.One               no, do a straight decimal conversion
                    leay      1,y                 skip the 'w' character
                    lda       #1                  force 2 bytes
                    fcb       $21                 skip the 'clra' following

D.One               clra                          force 1 byte (may expand to 2)
                    sta       <D.Len              save length of the decimal character

                    clra                          start off at zero
                    clrb
                    std       <D.Word             sav starting value of the decimal word to output

D.Read              lda       ,y+                 grab a decimal digit
                    cmpa      #C$CR               done the list?
                    beq       D.CR                yes, output the characters and then exit

                    cmpa      #'0                 smaller than zero?
* BUG FIX 07/04/2020 LCB - was bls
                    blo       D.Done0             yes, we're done this decimal digit
                    cmpa      #'9
                    bhi       Error
                    suba      #'0                 convert ascii to number

                    pshs      a                   save the character for later
                    ldd       <D.Word             get the current word
                    aslb
                    rola                          N*2
                    aslb
                    rola                          N*4
                    aslb
                    rola                          N*8
                    addd      <D.Word             N*8+N=N*9
                    addd      <D.Word             N*9+N=N*10
                    addb      ,s+                 add in our latest character
                    adca      #0                  make it 16-bit
                    std       <D.Word
                    bra       D.Read              go get another character

D.Done0             leay      -1,y                point to character we've tried to convert to dec.
D.Done              ldd       <D.Word             get the byte(s) to output
                    tst       <D.Len              check length flag
                    bne       D.Two               if forcing 2 bytes, output them
                    tst       <D.Word             is high byte zero?
                    beq       D.Exit              yes, only output low order byte

D.Two               sta       ,x+                 save high byte in the output buffer
D.Exit              clra
                    rts

D.CR                leau      <Error,pcr          point to error routine: no more characters
                    bra       D.Done              output these characters, and the exit

                    emod
eom                 equ       *
                    end

