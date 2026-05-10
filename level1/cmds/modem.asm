                    nam       Modem
                    ttl       Modem Command/Response Utility

********************************************************************
* Modem - Modem Response Handler
* Will evolve into a full AT command issuer and response parser.
*

* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2025/07/13  R Taylor
* Added -R option to reset the FIFO
*
*          2025/12/23  R Taylor
* Added -L option to specify # of lines to read from device
*
*          2026/02/25  R Taylor
* Added delay before closing modem device after last string char is sent
*
*          2026/04/12  R Taylor
* Test: Changed command to read-only from /device
* Use Echo >/dev for writing

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       8

* Here are some tweakable options
STACKSZ             set       256                 estimated stack size in bytes
PARMSZ              set       256                 estimated parameter size in bytes

                    mod       eom,name,tylg,atrv,start,size

                    org       0
path                rmb       1
cfgpath             rmb       1
param               rmb       2
d.linestoread       rmb       1
linestoread         rmb       1
d.ptr               rmb       2
d.size              rmb       2
timeout             rmb       1
d.timeout           rmb       1
d.time1             rmb       6
d.time2             rmb       6
d.buff              rmb       128
d.pathname          rmb       128                 custom filename using aliasdir
d.buffer            rmb       2496                should reserve 7k, leaving some room for parameters
* Finally the stack for any PSHS/PULS/BSR/LBSRs that we might do
                    rmb       STACKSZ+PARMSZ
size                equ       .

name                fcs       /Modem/
                    fcb       edition             change to 6, as merge 5 has problems?

devicestr           fcs       "/wz"
crlf                fcb       13,10,0
aliasdir            fcs       "/dd/sys/modem.conf"

* Here's how registers are set when this process is forked:
*
*   +-----------------+  <--  Y          (highest address)
*   !   Parameter     !
*   !     Area        !
*   +-----------------+  <-- X, SP
*   !   Data Area     !
*   +-----------------+
*   !   Direct Page   !
*   +-----------------+  <-- U, DP       (lowest address)
*
*   D = parameter area size
*  PC = module entry point abs. address
*  CC = F=0, I=0, others undefined

* The start of the program is here.
start               subd      #$0001              if this becomes zero,
                    lbeq       Exit               we have no parameters

                *     clra
                *     clrb
                *     std       <d.device           |
                *     std       <d.device+2         | clear device name string space (5 chars)
                *     stb       <d.device+4         |
                
                    ldb       #1
                    stb       <d.linestoread
                    ldb       #1
                    stb       <d.timeout
                    leay      d.buffer,u          point Y to buffer offset in U
                    stx       <param              and parameter area start
                    tfr       s,d                 place top of stack in D
                    pshs      y                   save Y on stack
                    subd      ,s++                get size of space between buff and X
                    subd      #STACKSZ+PARMSZ     subtract out our stack/param size
                    std       <d.size             save size of data buffer
                    leay      d.buffer,u          point to some data
                    sty       <d.ptr
                    bra       do.opts

quote               lda       ,x+                 grab a character
                    cmpa      #34                 Double Quote?
                    beq       quote               yes, skip it
                    leax      -1,x                otherwise point to last non-space
                    rts

space               lda       ,x+                 grab a character
                    cmpa      #C$SPAC             space?
                    beq       space               yes, skip it
                    leax      -1,x                otherwise point to last non-space
                    rts

nonspace            lda       ,x+                 grab a character
                    cmpa      #C$CR               cr?
                    beq       nospacex            yes, skip it
                    cmpa      #C$SPAC             nonspace?
                    bne       nonspace            yes, skip it
nospacex            leax      -1,x                otherwise point to last space
                    rts


********************************************************************
do.opts             ldx       <param              get first option
do.opts2            lbsr      space
                    stx       <param

                    cmpa      #$00
                    lbeq      Exit

                    cmpa      #C$CR               Was the character a CR?
                    lbeq      Exit                Yes

                    cmpa      #'-                 Was the character a dash?
                    lbne      do.readfile         No, assume is devicename

                    leax      1,x                 skip over dash
                    lda       ,x+                 get char after dash
                    anda      #$DF                make uppercase
*                    cmpa      #'L
*                    beq       do.l
                    cmpa      #'W
                    beq       do.w
                    cmpa      #'T
                    beq       do.t
                    cmpa      #'R
                    beq       do.reset
                    cmpa      #'Z                 input from stdin?
                    lbeq      do.z
                    ldb       #187              Bad argument
                    lbra      Error

do.w                clr       <d.timeout         Make sure the listener waits forever for input
                    bra       do.opts2           update opts pointer and go to next

do.t                lbsr      ASC2Int            get timeout seconds
                    stb       <d.timeout
                    bra       do.opts2           update opts pointer and go to next

do.l                lbsr      ASC2Int            get # of lines to read 0-255
                    tstb
                    bne       do.l1
                    ldb       #1
do.l1               stb       <d.linestoread
                    bra       do.opts2           update opts pointer and go to next

do.reset            lda       WizFi.Base
                    ora       #WizFi.Reset
                    sta       WizFi.Base
                    exg       a,a
                    exg       a,a
                    anda      #^WizFi.Reset
                    sta       WizFi.Base
                    bra       do.opts2           update opts pointer and go to next

do.string           leax      1,x
                    pshs      x
                    leax      devicestr,pcr
                    lda       #WRITE.
                    os9       I$Open              open the file for reading
                    lbcs      read.ex             crap out if error
                    sta       <path
                    puls      x
do.sw               ldd       ,x
                    cmpd      #$2222
                    beq       do.esc
                    cmpa      #34
                    beq       do.sx
                    cmpa      #$00
                    lbeq      do.sx
                    cmpa      #C$CR
                    lbeq      do.sx
                    cmpa      #'\
                    bne       do.chr
do.esc              leax      1,x
do.chr              ldy       #1
                    lda       <path
                    os9       I$Write
                    lbcs      read.ex             crap out if error
                    leax      1,x
                    bra       do.sw
do.sx               leax      crlf,pcr
                    ldy       #2
                    lda       <path
                    os9       I$Write
                    lbcs      read.ex             crap out if error
                    ldx       #0
do.delay            mul
                    leax      -1,x
                    bne       do.delay
                    lda       <path               get the current path number
                    os9       I$Close             close it
                    lbra      Exit

do.readfile         lbsr      space
                    ldb       <d.timeout
                    stb       <timeout
                    ldx       <param
                    lda       #READ.
                    os9       I$Open              open the file for reading
                    lbcs      read.ex             crap out if error
                    sta       <path               save path number
                    stx       <param              and save next address on command line
do.readfile2        bsr       do.listen           Go listen for string
                    lbcs      Error
                    lda       <path               get the current path number
                    os9       I$Close             close it
                    lbra      do.opts             Pick back up just after the device name which is updated earlier

do.listen           tst       <timeout            Wait forever for 1st byte?
                    bne       do.gather           No, go into timeout-based loop
                    lda       <path               get the current path number
                    ldb       #SS.Ready
                    pshs      x
                    os9       I$GetStt
                    puls      x
                    bcs       do.listen           Loop until we see first char
                    bra       d@                  Go send 1st char to stdout and listen for rest of string
do.gather           ldx       #4096
l@                  lda       <path               get the current path number
                    ldb       #SS.Ready
                    pshs      x
                    os9       I$GetStt
                    puls      x
                    bcc       d@                  got data, branch to read it
rfdel               leax      -1,x
                    bne       l@
                    dec       <timeout
                    bne       do.gather
                    clrb
                    bra       read.ex
d@                  lda       <path
                    ldy       #1                  Read 1 byte
                    ldx       <d.ptr              from device into data buffer
                    os9       I$Read              Go read byte
                    bcs       read.ex
                    ldy       #1                  Write 1 byte
                    lda       #$01                to STDOUT
                    ldx       <d.ptr              from data buffer
                    os9       I$Write
                    bcc       do.gather
read.ex             rts

chk.err             cmpb      #E$EOF              end of the file?
                    bne       read.ex             no, error out

                    lda       <path               otherwise get the current path number
                    os9       I$Close             close it
                    rts                           return to caller

Error               coma                          set carry
                    fcb       $21                 skip next byte
Exit                clrb
                    os9       F$Exit              and exit

********************************************************************
* read from stdin until eof or blank line
* skip lines that begin with * (these are comments)
do.z                leax      d.buff,u
                    ldy       #127
                    clra                          stdin
                    os9       I$ReadLn
                    bcc       do.z2
                    cmpb      #E$EOF              end-of-file?
                    beq       Exit                nope, exit with error
                    bra       Error
do.z2               lda       ,x
                    cmpa      #'*                 asterisk? (comment)
                    beq       do.z                yep, ignore and get next line
                    lbsr      space               skip space at X
                    cmpa      #C$CR               end of line?
                    beq       Exit                yup, we're done
* X points to a filename...
                    pshs      x
                    lbsr      do.readfile         read contents of file and send to stdout
                    puls      x
                    bcc       do.z                branch if ok
                    bra       Error

********************************************************************
* ASC2Int
*   Convert Ascii Number (0-255) to Binary
*
* In:  (X)=Ascii String ptr
* Out: (A)=next char After Number
*      (B)=Number
*      (X)=updated Past Number
*      CC=set if Error
*
ASC2Int             clrb
shgn10              lda       ,x+
                    suba      #'0                 convert ascii to binary
                    cmpa      #9                  valid decimal digit?
                    bhi       shgn20              ..no; end of number
                    pshs      a                   save digit
                    lda       #10
                    mul                           MULTIPLY Partial result times 10
                    addb      ,s+                 add in next digit
                    bcc       shgn10              get next digit if no overflow
shgn20              rts


                    emod
eom                 equ       *
                    end

