********************************************************************
* MakDir - Create directory file
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   4      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*
*   5      ????/??/??  Alan DeKok
* Makes multiple directories from a single pathlist.

                    nam       Makdir
                    ttl       Create directory file

* Disassembled 94/12/08 21:42:56 by Alan DeKok

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       5

                    mod       eom,name,tylg,atrv,start,size

                    org       0
param               rmb       2                   parameter area
mflag               rmb       1                   made a directory yet from this pathlist?
                    rmb       200                 stack space
size                equ       .

name                fcs       /MakDir/
                    fcb       edition

Sk.1                leax      1,x                 go on to the next character
Skip                lda       ,x                  get a character
                    cmpa      #C$SPAC             space?
                    beq       Sk.1                if so, skip it
                    rts

* Any pathnames at all?
* Exit with error if none
Start               bsr       Skip                skip the first bit, if applicable
                    cmpa      #C$SPAC             is it a CR?
                    bne       start2              no, go ahead and make directories
                    comb                          set carry
                    ldb       #E$BPNam            a CR is a bad pathname...
                    bra       Exit                and go exit

* skip leading spaces or '/' and setup pointers
start1              bsr       Skip                skip any non-zero characters, if applicable
start2              ldb       #$FF                a non-zero value
                    stb       <mflag              we haven't made a directory from this pathname yet
                    stx       <param              save in the parameter area
                    cmpa      #PDELIM             leading slash?
                    bne       S.020               if not, go get the name

* find the pseudo-end of the pathname, stopping at space, cr, '/'
S.010               leax      1,x
S.020               lda       ,x
                    cmpa      #C$SPAC             space?
                    beq       S.030
                    cmpa      #C$CR               cr?
                    beq       S.030
                    cmpa      #PDELIM             slash?
                    bne       S.010               if none of these, then skip this character

* force the pathname to be a subset of the full pathname
S.030               pshs      a,x                 save byte found, where we found it
                    lda       #C$CR               force it to be a CR
                    sta       ,x

*try to open it for reading, i.e. does it already exists?
                    ldx       <param              get the start address of this pathname
                    lda       #DIR.+READ.         open the directory for reading
                    os9       I$Open              check if the directory already exists
                    bcs       S.040               if there was an error opening it, go make it
                    os9       I$Close             close the path to the file
                    bra       S.050               skip making this directory

* The partial pathname doesn't exist, so create it
S.040               ldx       <param              get the start address of this pathname
                    ldb       #^SHARE.            everything but SHARE.
                    os9       I$MakDir
                    bcs       Error
                    clr       <mflag              clear the flag: we've successfully made a directory

* make pathname full again, and continue
S.050               puls      a,x                 restore byte, address
                    sta       ,x                  restore it
                    cmpa      #PDELIM             was it a slash?
                    beq       S.010               yes, make pathname full again, and find next one

* searched this pathname, have we made a directory from it?
                    tst       <mflag              have we made a directory?
                    bne       CEF                 if not, error out with fake E$CEF

* check for end/continue flag
                    cmpa      #C$SPAC             was it a space?
                    beq       start1              yup, go get another pathname to create

ClnExit             clrb                          no error
Exit                os9       F$Exit              and exit

CEF                 comb                          set carry
                    ldb       #E$CEF              we've just tried to create an existing file
Error               pshs      b,cc                save error code

                    lda       #2                  to STDERR
                    leax      EMsg,pc             to error found string
                    ldy       #Elen
                    os9       I$Write

                    ldx       <param              get pathname we're trying to open
                    ldy       #200                a _very_ long pathname
                    os9       I$WritLn            we're sure that the name ends in a CR...
                    puls      b,cc                restore error code, condition
                    bra       Exit

EMsg                fcc       /makdir: error creating /
ELen                equ       *-EMsg

                    emod
eom                 equ       *
                    end
