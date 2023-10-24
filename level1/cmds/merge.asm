********************************************************************
* Merge - Merge files into one file
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   4      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*
*   5      2003/09/06
* Added -z option to read files from stdin

                    nam       Merge
                    ttl       Merge files into one file

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
param               rmb       2
d.ptr               rmb       2
d.size              rmb       2
d.buff              rmb       128
d.buffer            rmb       2496                should reserve 7k, leaving some room for parameters
* Finally the stack for any PSHS/PULS/BSR/LBSRs that we might do
                    rmb       STACKSZ+PARMSZ
size                equ       .

name                fcs       /Merge/
                    fcb       edition             change to 6, as merge 5 has problems?

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
                    beq       Exit                we have no parameters

                    leay      d.buffer,u          point Y to buffer offset in U
                    stx       <param              and parameter area start
                    tfr       s,d                 place top of stack in D
                    pshs      y                   save Y on stack
                    subd      ,s++                get size of space between buff and X
                    subd      #STACKSZ+PARMSZ     subtract out our stack/param size
                    std       <d.size             save size of data buffer
                    leay      d.buffer,u          point to some data
                    sty       <d.ptr

do.opts             ldx       <param              get first option
do.opts2            lbsr      space

                    cmpa      #C$CR               was the character a CR?
                    beq       do.file             yes, parse files

                    cmpa      #'-                 was the character a dash?
                    beq       do.dash             yes, parse option
                    lbsr      nonspace            else skip nonspace chars

                    cmpa      #C$CR               end of line?
                    beq       do.file             branch if so
                    bra       do.opts2            else continue parsing for options

do.file             ldx       <param
                    lbsr      space

                    cmpa      #C$CR               CR?
                    beq       Exit                exit if so

                    cmpa      #'-                 option?
                    bne       itsfile

                    bsr       nonspace

                    cmpa      #C$CR               CR?
                    beq       Exit                exit if so

itsfile             bsr       readfile
                    bcs       Error
                    bra       do.file

readfile            lda       #READ.
                    os9       I$Open              open the file for reading
                    bcs       read.ex             crap out if error
                    sta       <path               save path number
                    stx       <param              and save new address of parameter area

read.lp             lda       <path               get the current path number
                    ldy       <d.size             and size of data to read
                    ldx       <d.ptr              and pointer to data buffer
                    os9       I$Read              read data into the buffer
                    bcs       chk.err             check errors

                    lda       #$01                to STDOUT
                    os9       I$Write             dump it out in one shot
                    bcc       read.lp             loop if no errors
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

do.dash             leax      1,x                 skip over dash
                    lda       ,x+                 get char after dash
                    cmpa      #C$CR               CR?
                    beq       Exit                yes, exit

                    anda      #$DF                make uppercase
                    cmpa      #'Z                 input from stdin?
                    bne       Exit

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
                    bsr       space               skip space at X
                    cmpa      #C$CR               end of line?
                    beq       Exit                yup, we're done

* X points to a filename...
                    pshs      x
                    bsr       readfile            read contents of file and send to stdout
                    puls      x
                    bcc       do.z                branch if ok
                    bra       Error


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

                    emod
eom                 equ       *
                    end

