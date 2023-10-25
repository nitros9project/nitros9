********************************************************************
* ReBoot - Reboot into OS-9 or DECB
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      ????/??/??  Alan DeKok
* Started.

                    nam       ReBoot
                    ttl       Reboot into OS-9 or DECB

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+Rev
rev                 set       $00

                    mod       eom,name,tylg,atrv,start,size

*==================================================================
* On boot-up, OS9p2 does (in order)
* an I$ChDir to the directory specified in the Init file
*     this opens an RBF buffer for the device, and at the minimum,
*     allocates:
* $0100 1 page by IOMan for the IRQ/VIRQ polling table
* $0100 1 page by IOMan for the disk driver static storage
* $0100 1 page by IOMan for the disk PD.BUF buffer
* (the path descriptor comes out of memory allocated already by OS9p1
*  from block 0)
*
* Next, OS9p2 does an I$Open to '/term' (or whatever, from the Init module)
* $0100 1 page allocated for '/term' device static storage
* $0100 1 page allocated for '/term' PD.BUF buffer
*
* VTIO does an F$Load to get GrfDrv into memory, and we then have
* $0200 2 pages allocated by IOMan via F$AllPrc, for the F$Load
*-------   total
* $0700   pages UP from $4000, so GrfDrv can load

*==================================================================
* The system's memory map is set up as:
* $0000-$1FFF: block 0, global system memory
* $2000-$3FFF: this block MUST be free: grfdrv is loaded here on boot
*              once booted, process descriptors, etc. get allocated here
* $4000-$46FF: initial data storage for system prior to loading GrfDrv
* $4700-$ECFF: OS9Boot file: $A600 maximum size
* $ED00-$FEFF: kernel, and constant page at $FE00
* $FF00-$FFFF: hardware, and RAM under block $3F that's unused by everyone!
*==================================================================

maxOS9Bt            equ       $A600               max. size of the OS9Boot file

                    org       0
OS9Boot             rmb       maxOS9Bt
Kernel              rmb       $1200               size of the kernel to use
PrcDsc              rmb       $0200               current process descriptor
param.pt            rmb       2                   parameter pointer
os9btsz             rmb       2                   size of the OS9Boot file
rbflag              rmb       2                   -b -r flags
oflag               rmb       1                   OS9Boot reload flag
kflag               rmb       1                   kernel reload flag
gflag               rmb       1                   GrfDrv reload flag
Param               rmb       $C000-.             shift everything up to $C000
Stack               equ       .
GrfDrv              rmb       $2000               so we now have all of the memory full
SIZE                equ       .

*==================================================================
* We'll put all of the 'magic' code in GrfDrv's stack, which doesn't
* care about being uninitialize
*
* Actually, this program puts it at offset $0000 in block $3F,
* which is $E000 when the system is rebooted.  BOOT then copies
* all of the information down to $1C80 before loading in the new OS9Boot
* file, and copying the original BOOT module back to $ED00+$0130
*==================================================================
                    org       $1C80               where memory is ALWAYS mapped in
os9.siz             rmb       2                   size of the os9boot file
grf.flg             rmb       1                   flag: reload GrfDrv?
os9.dat             rmb       16                  DAT image
boot                rmb       $01D0               original BOOT module

NAME                fcs       /ReBoot/
                    fcb       $01

*==================================================================
* Start of the program: Move the stack to lower memory, and
* copy the parameters there, too.
*==================================================================
Start               lds       #stack              point the stack to somewhere safe
                    tfr       d,y                 now Y = size of the parameter area
                    ldu       #param              U=$0000 always in the Coco, so this is OK

s.copy              lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       s.copy

                    clra
                    sta       >oflag              no os9boot
                    sta       >kflag              no kernel
                    sta       >gflag              no GrfDrv
                    sta       >rbflag             default to allowing '-r -b' options

                    ldx       #Param              point to the start of the parameters again
                    stx       >param.pt           save pointer

*==================================================================
* Check for more parameters
*==================================================================
Check               ldx       >param.pt           get the current parameter pointer
check.p             ldd       ,x
                    cmpa      #C$SPAC             skip leading spaces
                    bne       Contin
                    leax      1,x
                    bra       check.p

Contin              cmpa      #C$CR               simply reboot
                    bne       Hy                  check for hyphens
                    tst       >rbflag             are the '-r' '-b' options valid?
                    lbne      Finalize            no, finalize the boot, and reboot
                    lbra      CrashIt             yes, go ahead and crash the system.

Hy                  cmpa      #'-                 hyphen?
                    lbne      Help
                    cmpb      #'?                 help?
                    lbeq      Help
                    andb      #$DF                make uppercase
                    tst       >rbflag             are the '-r' '-b' options valid?
                    bne       o.flag              no, skip ahead to checking other flags
                    cmpb      #'B
                    lbeq      CrashIt

                    cmpb      #'R                 reboot?
                    lbeq      LoadIt

*==================================================================
* Only -L -K -G options are valid here
*==================================================================
o.flag              cmpb      #'L                 load the OS9Boot file?
                    lbeq      load.os9            yes, go load it

                    cmpb      #'K                 load the kernel file?
                    lbeq      load.krn            yes, go load it

                    cmpb      #'G                 load GrfDrv?
                    lbne      Help                no, print out a help message

*==================================================================
* load in GrfDrv
*==================================================================
load.grf            tst       >gflag
                    lbne      Help
                    stb       >gflag
                    ldu       #grfdrv             where to put grfdrv
                    ldy       #$2000              the maximum size it can be
                    bsr       load.fil
                    lbra      Check               check for more options

*==================================================================
* Load in the kernel
*==================================================================
load.krn            tst       >kflag              already loaded the kernel?
                    lbne      Help                yes, print error
                    stb       >kflag              we're loading the kernel
                    ldu       #kernel             where to put the kernel
                    ldy       #$1200              the size of the kernel
                    bsr       load.fil            load in the kernel file
                    lbra      Check               check for more options

*==================================================================
* load the specified file
* Entry: X = parameter pointer
*        Y = maximum size of the file to read
*        U = pointer to load address for the file
*==================================================================
load.fil            stb       >rbflag             don't allow -r -b any more
                    leax      2,x                 skip '-X' option
                    lda       ,x+                 grab the next character
                    cmpa      #C$SPAC             space?
                    lbne      Help                no, print help message

                    pshs      x                   save filename for later
                    lda       #READ.              read-only permissions
                    os9       I$Open              open the file
                    lbcs      fil.err

                    stx       >param.pt           save parameter pointer for later

                    tfr       u,x                 put load address into X
                    os9       I$Read              read in the OS9Boot file
                    lbcs      fil.err
                    puls      x,pc                restore unused X, and exit

*==================================================================
* load a new OS9Boot file
*==================================================================
load.os9            tst       >oflag
                    lbne      Help
                    stb       >oflag              flag we have an OS9Boot file requested
                    stb       >rbflag             and the '-r' or '-b' options are no longer valid

                    ldu       #$0000              where to put the information
                    ldy       #MaxOS9Bt
                    lbsr      load.fil            go load the file into memory
                    sty       >os9btsz            save the size of the OS9Boot file for later
* do some syntax checking on the OS9Boot file...
                    lbra      Check               go check for more parameters

*==================================================================
* finalize the crash of the system
*==================================================================
Finalize            lbsr      Seek                seek /DD to 0
                    os9       F$ID                get my ID and process #
                    ldx       #PrcDsc             point to where to put the process descriptor
                    os9       F$GPrDsc            get it
                    lbcs      Exit
                    leax      P$DATImg,x          point to it's DAT image

                    orcc      #IntMasks           shut off IRQ's
                    lda       #$3F                block $3F
                    sta       >$FFA8              map in block $3F

                    lda       >oflag              do OS9Boot?
                    bne       do.os9bt            yup, skip ahead
                    lda       >gflag              OS9Boot OR GrfDrv?
                    beq       do.kern             neither one, just do the kernel
                    lbra      Help                no OS9Boot, but trying to reload GrfDrv: invalid

* copy our DAT image to block 0
do.os9bt            ldu       #$0000              to the start of block $3F
                    ldd       >os9btsz            get the size of the OS9Boot file
                    std       ,u++                save it for later
                    lda       >gflag              do we reload GrfDrv?
                    sta       ,u+                 save flag for later
                    ldb       #16                 copy the whole DAT image...
dat.lp              lda       ,x+
                    sta       ,u+
                    decb
                    bne       dat.lp

                    lda       >kflag              do we move the kernel over?
                    beq       no.kern             if clear, we don't have a kernel in high memory

do.kern             pshs      u                   save current pointer to $E000+x
                    ldu       #$0D00              where to put the new kernel
                    ldx       #kernel             where the new kernel currently is located
                    ldy       #$1200              the size of the kernel
                    bsr       bt.lp               copy the kernel over a byte at a time
                    puls      u                   restore low memory pointer

                    lda       >oflag
                    ora       >gflag              OS9Boot OR GrfDrv?
                    lbeq      LoadIt.0            nope, just the kernel: reboot quickly

* copy the original BOOT module to block 0
no.kern             ldx       #$0D00+$0130        block 0, offset $0D00+REL
                    bsr       bt.copy
                    leax      eom,pc              point to the end of the module
                    ldu       #$0D00+$0130        over top of the original BOOT module
                    bsr       bt.copy
                    lbra      LoadIt.0            and go re-load the OS9Boot file

bt.copy             ldy       #$01D0
bt.lp               lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       bt.lp
                    rts

*==================================================================
* crash the system
*==================================================================
CrashIt             lbsr      Seek                seek /DD to track 0
                    orcc      #IntMasks           turn off IRQ's
                    clrb
                    stb       >$FFA8              map in block 0
                    stb       >$0071              cold reboot
                    lda       #$38                bottom of DECB block mapping
                    sta       >$FFA8              map in block zero
                    stb       >$0071              and cold reboot here, too
                    ldu       #$0000              force code to go at offset $0000
                    leax      ReBoot,pc           reboot code
                    ldy       #BtSize
cit.loop            lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       cit.loop
                    clr       >$FEED              cold reboot
                    clr       >$FFD8              go to low speed
                    jmp       >$0000              jump to the reset code

*==================================================================
* reboot the system
*==================================================================
ReBoot              ldd       #$3808              block $38, 8 times
                    ldx       #$FFA0              where to put it
Lp                  sta       8,x                 put into map 1
                    sta       ,x+                 and into map 0
                    inca
                    decb                          count down
                    bne       Lp

                    lda       #$4C                standard DECB mapping
                    sta       >$FF90
                    clr       >$FF91              go to map type 0
                    clr       >$FFDE              and to all-ROM mode
                    ldd       #$FFFF
*         clrd               executes as CLRA on a 6809
                    fdb       $104F
                    tstb                          is it a 6809?
                    bne       Reset               yup, skip ahead
*         ldmd  #$00       go to 6809 mode!
                    fcb       $11,$3D,$00
Reset               jmp       [$FFFE]             do a reset
BtSize              equ       *-Reboot

*==================================================================
* reload the OS9Boot file
*==================================================================
LoadIt              lbsr      Seek                seek /DD to track 0
                    orcc      #IntMasks
LoadIt.0            clr       >$FFA8              map in block 0
                    ldu       #$0520              somewhere unused
                    leax      <ReLoad,pc          point to code to reboot the system
                    ldy       #LoadSiz
lit.loop            lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       lit.loop
                    jmp       >$0520              and jump to it

ReLoad              clr       >$FF91              go to map type 0
                    ldx       #$ED00              where REL is located

RLp                 leax      1,x                 to to the next byte (OS...)
                    ldd       ,x
                    cmpd      #M$ID12
                    bne       RLp                 if not the start of a module
                    ldd       M$Exec,x            get execution address of the module (REL)
                    jmp       d,x                 and go to it
LoadSiz             equ       *-ReLoad

*==================================================================
* print out the help message
*==================================================================
Help                leax      HMsg,pc
                    ldy       #HLen
Print               lda       #1                  to STDOUT
                    os9       I$Write
ClnExit             clrb
Exit                os9       F$Exit

HMsg                fcc       /ReBoot: Reboots the system, or returns to DECB./
                    fcb       C$CR,C$LF
                    fcc       / use: reboot [-b] [-r] [-k filename] [-l filename]/
                    fcc       / [-g filename]/
                    fcb       C$CR,C$LF
                    fcc       /   -b = return to DECB (default)/
                    fcb       C$CR,C$LF
                    fcc       /        ( equivalent to <CTRL><ALT><RESET> )/
                    fcb       C$CR,C$LF
                    fcc       /   -r = reload OS9Boot/
                    fcb       C$CR,C$LF
                    fcc       /        ( equivalent to pressing <RESET> )/
                    fcb       C$CR,C$LF
                    fcc       /**  The previous 2 options are mutually exclusive to the/
                    fcc       / next 3.**/
                    fcb       C$CR,C$LF
                    fcc       /   -k [filename] = load in a new kernel track from [filename]/
                    fcb       C$CR,C$LF
                    fcc       /   -l [filename] = reload the OS9Boot file from [filename]/
                    fcb       C$CR,C$LF
                    fcc       /   -g [filename] = load in a new GrfDrv from [filename]/
                    fcb       C$CR,C$LF
                    fcc       /      If you reload GrfDrv, you MUST also reload the/
                    fcc       / OS9Boot file./
                    fcb       C$CR,C$LF
HLen                equ       *-HMsg

DD                  fcs       '/DD'

*==================================================================
* Seek /DD to sector 0... why not?
*==================================================================
Seek                leax      <DD,pc
                    lda       #READ.
                    os9       I$Open
                    bcs       seek.ex
                    ldx       #$0000
                    ldu       #$0000
                    os9       I$Seek              restore head on /DD to track 0
                    os9       I$Close
seek.ex             rts

fil.err             puls      u                   restore pointer to filename we had error with
                    pshs      b,cc                save error code, condition
                    leax      >fil.msg,pc
                    ldy       #fil.len
                    lda       #$02                to STDERR
                    os9       I$Write

* A=$02 still...
                    leax      ,u
fil.lp              ldb       ,u+
                    cmpb      #C$SPAC
                    bhi       fil.lp
                    ldb       #C$CR               get a CR
                    stb       -1,u                save for later

                    ldy       #$0100              maximum amount of junk to write
                    os9       I$WritLn            dump out the filename
                    puls      b,cc                restore error code, condition
                    os9       F$Exit              and exit

fil.msg             fcc       /ReBoot: Error reading file: /
fil.len             equ       *-fil.msg

                    fcc       'MAGIC Boot Module is next!'

                    emod
eom                 equ       *
                    end
