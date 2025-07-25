                    nam       Modem
                    ttl       Modem Command/Response Utility

********************************************************************
* Modem - Similar to the MERGE command at this time,
* but aimed at Telnet/WIFI Modem devices.
* Will evolve into a full AT command issuer and response parser.
*

* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2025/07/13  R Taylor
* Added -r option to reset the FIFO


                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       5

* Here are some tweakable options
STACKSZ             set       128                 estimated stack size in bytes
PARMSZ              set       256                 estimated parameter size in bytes

                    mod       eom,name,tylg,atrv,start,size

                    org       0
path                rmb       1
cfgpath             rmb       1
param               rmb       2
d.ptr               rmb       2
d.size              rmb       2
timeout             rmb       1
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
crlf                fcb       13,10
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

                    leay      d.buffer,u          point Y to buffer offset in U
                    stx       <param              and parameter area start
                    tfr       s,d                 place top of stack in D
                    pshs      y                   save Y on stack
                    subd      ,s++                get size of space between buff and X
                    subd      #STACKSZ+PARMSZ     subtract out our stack/param size
                    std       <d.size             save size of data buffer
                    clr       <timeout
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

                    cmpa      #C$CR               was the character a CR?
                    lbeq      do.file             yes, parse files

                    cmpa      #'-                 was the character a dash?
                    beq       do.dash             yes, parse option

                    cmpa      #34
                    beq       do.string

                    bsr       nonspace            else skip nonspace chars
                    cmpa      #C$CR               end of line?
                    lbeq      do.file             branch if so

                    bra       do.opts2            else continue parsing for options

********************************************************************
do.dash             leax      1,x                 skip over dash
                    lda       ,x+                 get char after dash
                    cmpa      #C$CR               CR?
                    lbeq      Exit                yes, exit
                    anda      #$DF                make uppercase
                    cmpa      #'T
                    beq       do.t
                    cmpa      #'R
                    beq       do.reset
                    cmpa      #'Z                 input from stdin?
                    lbeq      do.z
                    lbra      Exit

********************************************************************
do.t                ldb       #3                  -t option sets default 3-second timeout
                    stb       <timeout
                    bra       do.opts2            do more args

********************************************************************
do.reset            lda       WizFi.Base
                    pshs      a
                    ora       #WizFi.Reset
                    sta       WizFi.Base
                    exg       a,a
                    exg       a,a
                    puls      a
                    anda      #^WizFi.Reset
                    sta       WizFi.Base
                    bra       do.opts2

********************************************************************
do.string           leax      1,x
                    stx       <param
                    leax      devicestr,pcr
                    lda       #WRITE.
                    os9       I$Open              open the file for reading
                    lbcs      read.ex             crap out if error
                    sta       <path
do.sw               ldx       <param
                    lda       ,x
                    cmpa      #34
                    beq       do.sx
                    cmpa      #'\
                    bne       do.chr
do.esc              leax      1,x
                    stx       <param
                    lda       ,x

do.chr              cmpa      #$00
                    lbeq      Exit
                    cmpa      #C$CR
                    lbeq      Exit
                    ldy       #1
*                    ldx       <param
                    lda       <path
                    os9       I$WritLn
                    lbcs      read.ex             crap out if error
                    ldx       <param
                    leax      1,x
                    stx       <param
                    bra       do.sw
do.sx               leax      1,x
                    stx       <param
                    leax      crlf,pcr
                    ldy       #2
                    lda       <path
                    os9       I$WritLn
                    lbcs      read.ex             crap out if error
                    lda       <path               get the current path number
                    os9       I$Close             close it
                    lbra      do.opts2

********************************************************************
do.file             ldx       <param
                    lbsr      space

                    cmpa      #C$CR               CR?
                    lbeq      Exit                exit if so

                    cmpa      #'-                 option?
                    bne       itsfile

                    lbsr      nonspace

                    cmpa      #C$CR               CR?
                    lbeq      Exit                exit if so

itsfile             bsr       readfile
                    lbcs      Error
                    bra       do.file

readfile            lda       #UPDAT.
                    os9       I$Open              open the file for reading
                    lbcs      read.ex             crap out if error
                    sta       <path               save path number
                    stx       <param              and save new address of parameter area
                    leax      d.time1,u
                    os9       F$Time
l@                  lda       <path               get the current path number
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcc       d@
                    ldb       <timeout
                    beq       l@                  no, loop until data is available
                    leax      d.time2,u           use timeout for response
                    os9       F$Time
                    ldb       5,x
                    leax      d.time1,u
                    subb      5,x
                    bpl       a@
                    negb
a@                  cmpb      <timeout
                    bhs       read.ex
                    bra       l@
d@                  lda       <path
                    ldy       #1
                    ldy       #$0001              Up to 256 bytes to be read
                    ldx       <d.ptr              and pointer to data buffer
                    os9       I$Read              Go read byte
                    bcs       chk.err             check errors
                    ldy       #1
                    lda       #$01                to STDOUT
                    ldx       <d.ptr              and pointer to data buffer
                    os9       I$Write             dump it out in one shot
                    bcs       read.ex             abort
                    ldx       <d.ptr
                    lda       ,x
                    cmpa      #$0a
                    bne       l@
                    lda       <path               get the current path number
                    os9       I$Close             close it
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
                    lbsr      readfile            read contents of file and send to stdout
                    puls      x
                    bcc       do.z                branch if ok
                    bra       Error


                    emod
eom                 equ       *
                    end

