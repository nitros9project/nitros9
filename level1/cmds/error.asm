********************************************************************
* Error - Show text error messages
*
* $Id$
*
* By Bob Devries (c) 2003; bdevries@gil.com.au
*
* Released under the GNU public licence
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2003/01/20  Bob Devries
* Rewrote in assembler for size.
*
*          2003/01/21  Bob Devries
* Fixed problem with trailing space.

                    nam       Error
                    ttl       Show text error messags

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

name                fcs       /Error/
                    fcb       edition

                    org       0
path                rmb       1
same                rmb       1
prmptr              rmb       2
prmend              rmb       2
length              rmb       2
parbuff             rmb       256
filbuff             rmb       256
stack               rmb       350
size                equ       .

start               cmpd      #1                  1 char == CR
                    lbeq      help
                    tfr       d,y                 length of parameters
                    bsr       open
                    bcs       exit
                    pshs      u
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
                    bne       entry3
                    leax      1,x
                    bra       rered2
entry3              bsr       strlen              go get string length of first param
                    std       <length             store it
reread              bsr       readlin             read line from errmsg file
                    bcc       rered0
                    cmpb      #E$EOF              did we find end-of-file?
                    lbeq      unknown             yep, tell user we don't know his error num
rered0              bsr       compare             compare user number with 1st 3 chars of line
                    beq       reread              compare returns 0 if failed
                    bsr       print               else go print the errmsg line
                    bcs       exit                exit if I$WritLn problem
rered1              ldd       <length             get length
                    ldx       prmptr              get parameter pointer
                    leax      d,x                 add length to it
                    leax      1,x                 increment past null byte
rered2              clrb
                    cmpx      <prmend
                    bge       exit
                    stx       <prmptr             store it
                    lbsr      seek0               rewind the file
                    bra       entry2              loop around again

exit                os9       F$Exit

open                pshs      x
                    leax      errmsg,pcr          point to file name
                    lda       #READ.              read mode
                    os9       I$Open
                    bcs       open0
                    sta       <path               store path number
open0               puls      x,pc

readlin             pshs      x,y
                    lda       <path               get file path number
                    ldy       #256                read max 256 bytes
                    leax      filbuff,u           into memory pointed to by filbuff
                    os9       I$ReadLn
                    puls      x,y,pc

print               pshs      x,y,a
                    lda       #1                  STDOUT
                    leax      filbuff,u           point to buffer
                    ldy       #256                max of 256 chars
                    os9       I$WritLn
                    puls      x,y,a,pc

strlen              pshs      x,y
                    ldy       #0                  initialise count
strl0               tst       ,x+                 is it a char > null
                    beq       strl1               nope, exit
                    leay      1,y                 yep, increment count
                    bra       strl0               do again
strl1               tfr       y,d                 return with length in D
                    puls      x,y,pc

compare             pshs      x,y
                    clr       <same               comparison indicator
                    ldx       prmptr              get address of next cmd line param
                    leay      filbuff,u           point to file buffer
comp0               lda       ,x+                 get char from cmd line
                    beq       comp1               is it null (end of param)
                    cmpa      ,y+                 compare to file buffer
                    bne       comp2               not same, exit
                    inc       <same               yep, in comparison counter
                    bra       comp0               'round again
comp1               lda       ,y
                    cmpa      #C$SPAC             was it end of number in errmsg file?
                    bne       comp2
                    tst       <same               test indicator
                    puls      x,y,pc
comp2               clr       <same               clear the counter
                    puls      x,y,pc

unknown             leax      unkmsg,pcr          point to message
                    ldy       #unkmsgl            num of chars to print
                    lda       #1                  to STDOUT
                    os9       I$Write
                    lbcs      exit                exit if problem with I$Write
                    ldx       prmptr              put pointer into parameter buffer in X
                    lda       #1                  STDOUT
                    ldy       <length             get length of user's param
                    os9       I$Write
                    lbcs      exit
                    lda       #1                  STDOUT
                    leax      return,pcr          point to CR char
                    ldy       #1                  print 1 char
                    os9       I$WritLn
                    lbcs      exit
                    ldx       prmptr              put point into parameter buffer in X
                    ldd       <length             get length of user's param
                    leax      d,x                 add to X
                    leax      1,x                 increment past null byte
                    clrb
                    cmpx      prmend
                    lbge      exit
                    stx       <prmptr             store X
                    bsr       seek0               rewind file
                    lbra      entry2

seek0               pshs      x,u
                    lda       <path
                    ldx       #0
                    ldu       #0
                    os9       I$Seek
                    puls      x,u,pc

help                leax      hlpmsg,pcr          point to help message
                    lda       #2                  STDERR
                    ldy       #256                max of 256 bytes (arbitrary, really)
                    os9       I$WritLn
                    lbcs      exit
                    leax      hlpmsg2,pcr         2nd line of message
                    lda       #2
                    ldy       #256
                    os9       I$WritLn
                    lbcs      exit
                    clrb
                    lbra      exit

hlpmsg              fcc       /Error  errno [errno...]/
                    fcb       C$CR
hlpmsg2             fcc       /Usage: returns error message for given error numbers/
                    fcb       C$CR
errmsg              fcc       "/DD/SYS/errmsg"
                    fcb       0
unkmsg              fcc       /Unknown error number - /
unkmsgl             equ       *-unkmsg
return              fcb       C$CR

                    emod
eom                 equ       *
                    end
