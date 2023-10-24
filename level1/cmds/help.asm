********************************************************************
* Help - Show help
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   6      2003/01/21  Boisy G. Pitre
*
*   7      2003/05/30  Rodney V. Hamilton
* Fixed showlist partial line bug, do auto list.

                    nam       Help
                    ttl       Show help

                    ifp1
                    use       defsfile
                    endc

COLWIDTH            set       10

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       7

                    mod       eom,name,tylg,atrv,start,size

name                fcs       /Help/
                    fcb       edition

                    org       0
exitvec             rmb       2
ncols               rmb       1
colcopy             rmb       1
bufptr              rmb       2
path                rmb       1
same                rmb       1
prmptr              rmb       2
prmend              rmb       2
length              rmb       2
colbuff             rmb       128
userbuf             rmb       128
parbuff             rmb       256
filbuff             rmb       256
stack               rmb       350
size                equ       .

* Ask user for subjects
askuser             leax      askusr2,pcr
                    stx       <exitvec
                    leax      prompt1,pcr
                    lda       #1
                    ldy       #128
                    os9       I$WritLn
* Show topics (if user enters nothing at prompt)
showlist            lda       #1
                    leax      >avail,pcr
                    ldy       #128
                    os9       I$WritLn
                    lbsr      seek0               rewind the file
                    bra       resetcl

doeol               sty       <bufptr
                    lda       #C$CR
                    sta       ,y
                    leax      colbuff,u
                    lda       #1
                    ldy       #128
                    os9       I$WritLn
resetcl             lda       <ncols
                    sta       <colcopy
                    leax      colbuff,u
                    stx       <bufptr
readlp              lbsr      readlin
                    bcc       readlp2
                    lda       <colcopy            check for partial line
                    cmpa      <ncols
                    blt       doeol               and print it
askusr2             leax      prompt2,pcr
                    lda       #1
                    ldy       #prompt2l
                    os9       I$Write
                    clra
                    ldy       #127
                    leax      userbuf,u
                    os9       I$ReadLn
                    lbcs      exiteof
                    lda       ,x
                    cmpa      #C$CR
                    beq       showlist
                    lbsr      seek0               rewind the file
                    lbra      entrya

readlp2             leax      filbuff,u
                    lda       ,x+
                    cmpa      #'@
                    bne       readlp
                    ldy       <bufptr
strcpy              clra
                    clrb
                    pshs      d
strc0               lda       ,x+
                    cmpa      #C$SPAC
                    ble       strc1
                    sta       ,y+
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    bra       strc0               do again
strc1               puls      d
                    dec       <colcopy
                    beq       doeol
                    cmpb      #COLWIDTH
                    bge       onesp
                    pshs      b
                    ldb       #COLWIDTH
                    subb      ,s+
                    fcb       $8C
onesp               ldb       #1
                    lda       #C$SPAC
spacelp             sta       ,y+
                    decb
                    bne       spacelp
                    sty       <bufptr
                    bra       readlp

start               pshs      d,x,y
                    lda       #8
                    sta       <ncols              assume 8 columns
                    lda       #1
                    ldb       #SS.ScSiz
                    os9       I$GetStt
                    bcs       start2
                    cmpx      #9
                    ble       start1              A = 1 here
                    tfr       x,d
                    clra
* Divide screen X by COLWIDTH to determine number of columns
Div10               subb      #COLWIDTH
                    bcs       start1
                    inca
                    bra       Div10
start1              sta       <ncols
start2              leax      exit,pcr
                    stx       <exitvec
                    puls      d,x,y
                    tfr       d,y                 length of parameters
open                pshs      x
                    leax      helpfile,pcr        point to file name
                    lda       #READ.              read mode
                    os9       I$Open
                    puls      x
                    bcs       exit
                    sta       <path               store path number
                    cmpy      #$0001              no parameters?
                    lbeq      askuser
entrya              pshs      u
                    leau      parbuff,u           point to buffer
entry0              lda       ,x+
                    cmpa      #C$SPAC             is it a space (between parameters?)
                    beq       entry1
                    cmpa      #C$CR
                    bne       nocr
entry1              clra                          yes, null it
nocr                sta       ,u+                 store in buffer
                    leay      -1,y                decrement length counter
                    bne       entry0
                    clr       ,u
                    tfr       u,y
                    puls      u
                    sty       <prmend             store end of all parameters
                    leax      parbuff,u           load address of parbuff into X
                    stx       <prmptr             save parameter pointer
entry2              lda       ,x
                    bne       strlen
                    leax      1,x
                    bra       rered2
strlen              pshs      x
                    ldy       #0                  initialise count
strl0               lda       ,x+                 is it a char > null
                    cmpa      #C$SPAC
                    ble       strl1               nope, exit
                    leay      1,y                 yep, increment count
                    bra       strl0               do again
strl1               puls      x
                    sty       <length             store it

reread              bsr       readlin             read line from helpfile file
                    bcc       rered0
                    cmpb      #E$EOF              did we find end-of-file?
                    lbeq      unknown             yep, tell user we don't know his command
rered0              bsr       compare             compare user number with 1st 3 chars of line
                    beq       reread              compare returns 0 if failed
                    bsr       print               else go print the helpfile line
                    bcc       rered1              exit if I$WritLn problem
                    cmpb      #E$EOF
                    bcs       exit
rered1              ldd       <length             get length
                    ldx       prmptr              get parameter pointer
                    leax      d,x                 add length to it
                    leax      1,x                 increment past null byte
rered2              clrb
                    cmpx      <prmend
                    blt       rered25
                    jmp       [exitvec,u]
rered25             stx       <prmptr             store it
rered3              lbsr      seek0               rewind the file
                    bra       entry2              loop around again

exiteof             cmpb      #E$EOF
                    bne       exit
exitok              clrb
exit                os9       F$Exit

readlin             pshs      x,y
                    lda       <path               get file path number
                    ldy       #256                read max 256 bytes
                    leax      filbuff,u           into memory pointed to by filbuff
                    os9       I$ReadLn
                    puls      x,y,pc

print               pshs      x,y,a
print2              bsr       readlin
                    bcs       printout
print3              lda       ,x
                    cmpa      #'@
                    beq       printout
                    lda       #1                  STDOUT
                    leax      filbuff,u           into memory pointed to by filbuff
                    ldy       #256                max of 256 chars
                    os9       I$WritLn
                    bra       print2
printout            lda       #1
                    leax      return,pcr
                    ldy       #256                max of 256 chars
                    os9       I$WritLn
                    puls      x,y,a,pc

compare             pshs      x,y
                    clr       <same               comparison indicator
                    leay      filbuff,u           point to file buffer
                    lda       ,y+                 get first char
                    cmpa      #'@                 @ sign?
                    bne       comp2               branch if not
                    ldx       prmptr              get address of next cmd line param
comp0               lda       ,x+                 get char from cmd line
                    beq       comp1               is it null (end of param)
                    ldb       ,y+
                    anda      #$DF
                    andb      #$DF
                    pshs      a
                    cmpb      ,s+
                    bne       comp2               not same, exit
                    inc       <same               yep, in comparison counter
                    bra       comp0               'round again
comp1               lda       ,y
                    cmpa      #C$CR               was it end of string in helpfile file?
                    bne       comp2
                    tst       <same               test indicator
                    puls      x,y,pc
comp2               clr       <same               clear the counter
                    puls      x,y,pc

unknown             ldx       prmptr              put pointer into parameter buffer in X
                    lda       #1                  STDOUT
                    ldy       <length             get length of user's param
                    os9       I$Write
                    bcs       exit
                    leax      unkmsg,pcr          point to message
                    ldy       #unkmsgl            num of chars to print
                    lda       #1                  to STDOUT
                    os9       I$WritLn
                    lbcs      exit                exit if problem with I$Write
                    ldx       prmptr              put point into parameter buffer in X
                    ldd       <length             get length of user's param
                    leax      d,x                 add to X
                    leax      1,x                 increment past null byte
                    clrb
                    cmpx      prmend
                    blt       unk2
                    jmp       [exitvec,u]
unk2                stx       <prmptr             store X
                    bsr       seek0               rewind file
                    lbra      entry2

seek0               pshs      x,u
                    lda       <path
                    ldx       #0
                    ldu       #0
                    os9       I$Seek
                    puls      x,u,pc

helpfile            fcc       "/DD/SYS/helpmsg"
                    fcb       0
unkmsg              fcc       /: no help available/
return              fcb       C$CR
unkmsgl             equ       *-unkmsg
prompt1             fcc       /Hit [ESC] to exit/
                    fcb       C$CR
prompt2             fcc       /What Subject(s)? /
prompt2l            equ       *-prompt2
avail               fcc       /Help available on:/
                    fcb       C$CR

                    emod
eom                 equ       *
                    end
