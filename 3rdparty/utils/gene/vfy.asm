* vfy.asm, module file verification tool
* Copyright (C) 1993-2014  Gene Heskett
* License: GPLv2
* See vfy.doc for more licensing information

                    opt       w                   86
                    nam       vfy                 Edition 17
                    ttl       A new verify, finds, fixes modules in files
*************************************************
* This verify will search thru any file to find a
* valid module header in the $87CD format, get that
* modules size, do a header parity/crc check on it,
* and if the -f option is on, will update the header
* parity and CRC bytes in the file too. It then
* resumes the search of the named file for more
* modules and loops till <eof>. If it finds <eof>
* while doing the crc, the error is reported as such.
* 2/18/93 version 7
* The housekeeping was pretty well complete, so it
* wasn't very much trouble to add the file split
* ability to this, now we can even split out the
* kernal track modules, plus head and tail too! Ver 8
* 11.24.93 GH Ver 9Adding some stuffs from "fixmod" here
* Now have total control over its vebosity 11/24/93 GH Ver 10
* 11/24/93 GH, -ua,-ur,-ut,-ul=$hexval installed
* 11/26-27/93 GH fine tuning the above GH Ver 11
* 01/25/94 GH another minor mod so it doesn't complain
* if the header parity is correct even if told to fix GH Ver 12
* 11/11/94 GH Ver 13. bug smashing, didn't update datasize
* if header parity was ok. Wrong branch at hdr parity check,
* if good it skipped the header update! Shame on me. :-(
* 11/14/94 GH Now it beeps and updates the header even if
* theres nothing wrong if the -f option is on. It doesn't
* hurt anything except the speed, but looking to fix
* it anyway. Now it does a header/datasize update
* independantly of the crc fixes, fixing only the
* header of the named file for one of the header
* fix variables, and the crc of that named file.
* If the -f option is on, it will fix the crc's
* and headers all thru the file. A good way to
* clean up after ded when working on hand patches
* in the kernal track.
* 05/04/95 GH, wasn't showing the correct info from the
* INIT module. Several minor changes there. Now ed #15
* 05/10/95 GH, adding the ability to change one module
* in a file via the name match, -n=modname
* also put verbose control in (finally), now edition 16
* Seeing if its possible to make it split a $62CD library
* after looking over the header format for an ROF file,
* it might be better to do a whole new "libsplit"
                    ifp1
                    use       os9.d
                    endc
ver                 set       17
atrev               set       reent+1
*
                    mod       len,name,prgrm+objct,atrev,entry,dsiz

crcacc              rmb       1                   for new crc's
crcac2              rmb       1
crcac3              rmb       1
filecrc1            rmb       1                   for the actual crc
filecrc2            rmb       1
filecrc3            rmb       1
numptr              rmb       2                   ptr to src
linptr              rmb       2                   ptr to linbuff
linbuff             rmb       8                   max len for printables

**** the modules header directly loaded ****
modid1              rmb       1                   the $87
modid2              rmb       1                   the $CD
modlen              rmb       2                   for the modules length
modname             rmb       2                   offset ptr to module name
typelang            rmb       1
modatrev            rmb       1
checksum            rmb       1
execptr1            rmb       1                   the exec offset in the header
execptr2            rmb       1                   more exec address
pdatasz1            rmb       1                   the permanent data size from the header
pdatasz2            rmb       1                   more data size or IRQ Poll count
dvtblent            rmb       1                   the device table entries value for INIT
***** the above loaded directly from the file ****

modhstrt            rmb       2                   set by sethead at start of
modlstrt            rmb       2                   module being checked
lmnscrc             rmb       2                   length minus crc for seeks
flenms16            rmb       2                   overall file size ms16
flenls16            rmb       2                   ditto             ls16
filesiz             rmb       2                   size of individual module
modpos              rmb       2                   where in module now
seekms16            rmb       2                   for seeks
seekls16            rmb       2                   ditto
moddone             rmb       1                   flag for last read
seperat             rmb       1                   flag for seperations
kernal              rmb       1                   flag to save it all
kbptrms             rmb       1                   msb of int
kbptr               rmb       1                   ptr to krnlbuf location
exdir               rmb       1                   for defining the access attributes
inpath              rmb       1                   for pathnum
outpath             rmb       1                   flag and output paths
kpath               rmb       1                   for kernal extras path
fixit               rmb       1                   tally for fix it
fixname             rmb       1                   fix only this name
fixty               rmb       1                   tally for individual fix
fixla               rmb       1                   ditto
fixat               rmb       1                   ditto
fixrv               rmb       1                   ditto
sizyet              rmb       1                   size not displayed yet if set
exectyp             rmb       1                   is executable
lftnbbl             rmb       1                   controls left-right nibble processing
verbose             rmb       1                   do we wanta see the results
updtrv              rmb       1                   update revision nibble
updtat              rmb       1                   update the attr nibble
updtty              rmb       1                   update the modules type nibble
updtla              rmb       1                   update the modules language nibble
updtdtsz            rmb       2                   update modules memsize integer
updthead            rmb       1                   controls the re-write of the header
cmpname             rmb       32                  to hold wanted name
datsiz              equ       .                   memory from 0 to here gets cleared
mdlname             rmb       32                  room for name
krnlbuf             rmb       64                  enough for what I've seen
buffer              rmb       256                 save the disk buffer
params              rmb       200
stack               rmb       200
dsiz                equ       .
*
name                fcs       /VFY/
                    fcb       ver
helpmsg             fcb       $0D,$0A
                    fcc       'Syntax: vfy [-options] [-options] /path/filename'
                    fcb       $0D,$0A
                    fcc       / Options -> -f  =fix (whole file) IF CRC is bad./
                    fcb       $0D,$0A
                    fcc       /         -> -v  =work silently./
                    fcb       $0D,$0A
                    fcc       /         -> -n=name fix or adjust only "name" module./
                    fcb       $0D,$0A
                    fcc       /         -> -x  =file is in EXEC dir./
                    fcb       $0D,$0A
                    fcc       /         -> -s  =seperate MERGED file./
                    fcb       $0D,$0A
                    fcc       /         -> -sk =seperate KERNAL file./
                    fcb       $0D,$0A
                    fcc       /         -> -ua=$hexchar -ur=$hexchar -ut=$hexchar -ul=$hexchar/
                    fcb       $0D,$0A
                    fcc       / a=att nibl, r=rev nibl, t=type nibl, l=lang nibl, "$" required/
                    fcb       $0D,$0A
                    fcc       /         -> -ud=$hexint to add (modulo $10000) data size./
                    fcb       $0D,$0A
                    fcc       /       if -u, -f is enabled for first file encountered./
                    fcb       $0D,$0A
                    fcc       /       if -n, -f is enabled for named file encountered./
                    fcb       $0D,$0A
cpyrit              fcc       /  VFY (c) 1993, 1994, 1995 by Maurice E.(Gene) Heskett/
                    fcb       $0D,$0A
msgsiz              equ       *
advise0             fcc       /A header file called /
kernal0             fcc       /KernalHead/
                    fcb       $0D                 put cr on name
krnlhsz             equ       *
advise1             fcc       /A tail file called /
kernal1             fcc       /KernalTail/
                    fcb       $0D                 put cr on name
krnltsz             equ       *
advlen              fcc       / with a length of $/
advend              fcc       / has been made./
hednamsg            fcc       /Header for    : /
hedckmsg            fcc       /Header parity : $/
ckbadsiz            equ       *
fixxmsg             fcc       / Repaired to: $/
newln               fcb       $0d,$0a
hdgdsiz             equ       *
modlnmsg            fcc       /Module size   : $/
crcmsg              fcc       /Module CRC is : $/
crcmsiz             equ       *
gdmsg               fcc       / (good)/
                    fcb       $0d,$0a
gdsiz               equ       *
shdabeen            fcc       ' S/B $'
badmsg              fcc       / (bad)/
                    fcb       $07,$07,$07,$07,$07
badsiz              equ       *
mdoffset            fcc       /Module found at offset $/
mdoffend            fcc       / in this file/
mdoffnln            fcb       $0d,$0a
ftopmem             fcc       /Top of free ram $/
ftopsiz             equ       *-ftopmem
ptabent             fcc       /, IRQ poll table entries $/
ptabsiz             equ       *-ptabent
dvtabent            fcc       /, Device table entries $/
dvtabsiz            equ       *-dvtabent
flenmsg             fcc       /Length of file: $/
howmany             fcc       /Bytes read    : $/
execoff             fcc       /Exec. off     : $/
datasiz             fcc       /Data Size     : $/
vertion             fcc       /Edition       : $/
tplgatrv            fcc       'Ty/La At/Rv   : $'

******** The lookup table for TYPE
typelook            equ       *
typunksz            fdb       sstmod-unktyp       zero is not defined
typunkst            fdb       unktyp-*
typprgsz            fdb       sbrutn-prgtyp       1 is program
typprgst            fdb       prgtyp-*
typsubsz            fdb       mltmod-sbrutn       2 is subroutine
typsubst            fdb       sbrutn-*
typmltsz            fdb       dtmtyp-mltmod       3 is multi-mod
typmltst            fdb       mltmod-*            whatever that is
typdatsz            fdb       unktyp-dtmtyp
typdatst            fdb       dtmtyp-*
typ5siz             fdb       sstmod-unktyp
typ5str             fdb       unktyp-*
typ6siz             fdb       sstmod-unktyp
typ6str             fdb       unktyp-*
typ7siz             fdb       sstmod-unktyp
typ7str             fdb       unktyp-*
typ8siz             fdb       sstmod-unktyp
typ8str             fdb       unktyp-*
typ9siz             fdb       sstmod-unktyp
typ9str             fdb       unktyp-*
typAsiz             fdb       sstmod-unktyp
typAstr             fdb       unktyp-*
typBsiz             fdb       sstmod-unktyp
typBstr             fdb       unktyp-*
typCsiz             fdb       fmntyp-sstmod
typCstr             fdb       sstmod-*
typDsiz             fdb       ddrtyp-fmntyp
typDstr             fdb       fmntyp-*
typEsiz             fdb       ddstyp-ddrtyp
typEstr             fdb       ddrtyp-*
typFsiz             fdb       ddssiz-ddstyp
typFstr             fdb       ddstyp-*

*********** The type defines ***********
typstrs             equ       *
prgtyp              fcc       /Program module/
sbrutn              fcc       /Subroutine/
mltmod              fcc       /Multi-Mod/
dtmtyp              fcc       /Data module/
unktyp              fcc       /Unknown type/      from 5 to B
sstmod              fcc       /System module/
fmntyp              fcc       /File manager/
ddrtyp              fcc       /Device driver/
ddstyp              fcc       /Device descriptor/
ddssiz              equ       *

*********** The lookup table for LANG
langlook            equ       *
lan0siz             fdb       std809-sysdat       0 is data
lan0str             fdb       sysdat-*
lan1siz             fdb       b09typ-std809       1 is 6809 object
lan1str             fdb       std809-*
lan2siz             fdb       pastyp-b09typ       2 is Basic09 I-code
lan2str             fdb       b09typ-*
lan3siz             fdb       ftntyp-pastyp       3 is Pascal P-code
lan3str             fdb       pastyp-*
lan4siz             fdb       ccityp-ftntyp       4 is Fortran I-code
lan4str             fdb       ftntyp-*
lan5siz             fdb       cbltyp-ccityp       5 is C I-code, in .r mods maybe
lan5str             fdb       ccityp-*
lan6siz             fdb       obj309-cbltyp       6 is Cobol I-code
lan6str             fdb       cbltyp-*
lan7siz             fdb       unklan-obj309       7 is 6309 object (NATIVE mode)
lan7str             fdb       obj309-*
lan8siz             fdb       unklsz-unklan       8 undefined
lan8str             fdb       unklan-*
lan9siz             fdb       unklsz-unklan       9 undefined
lan9str             fdb       unklan-*
lanAsiz             fdb       unklsz-unklan       10 undefined
lanAstr             fdb       unklan-*
lanBsiz             fdb       unklsz-unklan       11 undefined
lanBstr             fdb       unklan-*
lanCsiz             fdb       unklsz-unklan       12 undefined
lanCstr             fdb       unklan-*
lanDsiz             fdb       unklsz-unklan       13 undefined
lanDstr             fdb       unklan-*
lanEsiz             fdb       unklsz-unklan       14 undefined
lanEstr             fdb       unklan-*
lanFsiz             fdb       unklsz-unklan       15 undefined
lanFstr             fdb       unklan-*

*********** The language defines *********
lanstrs             equ       *
sysdat              fcc       /, Data/
std809              fcc       /, 6809 object/
b09typ              fcc       /, Basic09 I-code/
pastyp              fcc       /, Pascal P-code/
ftntyp              fcc       /, Fortran I-code/
ccityp              fcc       /, C I-code/
cbltyp              fcc       /, Cobol I-code/
obj309              fcc       /, 6309 object/
unklan              fcc       /, Unknown language/
unklsz              equ       *

********** The attr defines ************
rent1               fcc       /, Re-enterable/
rdonly              fcc       ', R/O'
rwattr              fcc       ', R/W'
ntv309              fcc       /, NATIVE MODE!/
ntvend              equ       *

******* Beginning of some subroutines *******
* SKEQDLR - skip the = and $
*  or detect a cmndline error
skeqdlr             lda       ,x+
                    decb
                    cmpa      #'=
                    lbne      help
                    lda       ,x+
                    decb
                    cmpa      #'$
                    lbne      help
                    lda       ,x+                 get next char as value to use
                    decb
                    rts                           and return to sender

***********************************
* A switchable showit routine
showit              pshs      a,cc
                    tst       <verbose
                    beq       showend
                    lda       #$02                stderr
                    os9       I$Write
showend             puls      a,cc
                    rts

**********************************
* A switchable newlnfd, exits thru showend
newlnfd             pshs      a,cc
                    tst       <verbose
                    beq       showend
                    lda       #$02
                    os9       I$Writln
                    bra       showend

****** the display subroutine ******
* entry - offset into lookup table in B
* entry - address of lookup table in X
tylandis            clra                          just in case
                    abx                           1st string location in x, add only!
                    ldy       ,x++                get size to print
                    ldd       ,x                  get offset to object itself
                    pshs      x                   save pointer
                    addd      ,s++                add offset & puls x
                    tfr       d,x                 back to x
                    bsr       showit
                    rts                           thats all for now folks

*********************************
* dfinemd - a subroutine to display
* the modules header defined data
*  first, set the tallies as to what it is
dfinemd             leax      exectyp,u
                    clra
                    ldb       #verbose-exectyp
dfinclr             sta       ,x+
                    decb
                    bne       dfinclr
                    ldb       <typelang
                    andb      #$F0                get type define
                    lsrb                          b/2
                    lsrb                          b/4 so increment thru list=4 bytes
                    leax      typelook,pcr        top of type string list
                    bsr       tylandis
                    ldb       <typelang
                    andb      #$0F
                    beq       dfn1
                    inc       <exectyp
dfn1                aslb                          b*2
                    aslb                          b*4 see reason above on b/4
                    leax      langlook,pcr        top of language string list
                    bsr       tylandis
att0                ldb       <modatrev
                    bitb      #$80
                    beq       att1
                    leax      rent1,pcr
                    ldy       #rdonly-rent1
                    bsr       showit
                    ldb       <modatrev
att1                bitb      #$40                gimix module write protect
                    bne       att2
                    leax      rdonly,pcr
                    ldy       #rwattr-rdonly
                    bsr       showit
                    ldb       <modatrev
                    bra       att3
att2                leax      rwattr,pcr
                    ldy       #ntv309-rwattr
                    lbsr      showit
                    ldb       <modatrev
att3                bitb      #$20
                    beq       dis0
                    leax      ntv309,pcr
                    ldy       #ntvend-ntv309
                    lbsr      showit
dis0                leax      newln,pcr
                    ldy       #2
                    lbsr      newlnfd
                    tst       <exectyp
                    beq       dis2                not executable code!
                    ldb       <typelang           testing for DESCR module
                    cmpb      #$F1                a device descriptor?
                    beq       dis3                no, skip the Exec,Data reports
                    leax      execoff,pcr         to msg
                    ldy       #datasiz-execoff
                    lbsr      showit              'Exec offset :$'
                    leax      execptr1,u
                    stx       <numptr
                    ldb       #$02
                    lbsr      printit             show num
                    leax      newln,pcr
                    ldy       #2
                    lbsr      newlnfd
* numptr pointing at data size in module
skdatup             leax      datasiz,pcr
                    ldy       #vertion-datasiz
                    lbsr      showit              'Data size  :$'
                    ldb       #$02
                    lbsr      printit             perm data size
                    leax      newln,pcr
                    lbsr      newlnfd             newline it
                    bra       dis3
dis2                ldb       <typelang           testing for INIT module
                    cmpb      #$C0                is it system+data=INIT?
                    bne       dis3                no, go
                    leax      execptr1,u          get it started at the right place
                    stx       <numptr
                    leax      ftopmem,pcr
                    ldy       #ftopsiz
                    lbsr      showit
                    ldb       #$03
                    lbsr      printit
                    leax      ptabent,pcr
                    ldy       #ptabsiz
                    lbsr      showit
                    ldb       #$01
                    lbsr      printit
                    leax      dvtabent,pcr
                    ldy       #dvtabsiz
                    lbsr      showit
                    ldb       #$01
                    lbsr      printit
                    leax      newln,pcr
                    lbsr      newlnfd
dis3                clr       <sizyet
                    rts

*******************************
* A routine to make ascii->hex
* ENTRY:  valid data in a
* EXIT :  hex in a
ascihex             cmpa      #'0
                    lblo      help                wrong!
                    cmpa      #'9
                    bls       ascinum
** no numbers get thru here **
                    cmpa      #'Z
                    blo       asciup
                    anda      #$DF
asciup              cmpa      #'F
                    lbhi      help
                    suba      #$07
ascinum             suba      #'0                 ok sub the first $30
shiftit             tst       <lftnbbl
                    beq       asciret
                    lsla
                    lsla
                    lsla
                    lsla                          if lftnbbl shift it to left nibble
asciret             rts                           should be ok, but Murphy is watching!

********************************
* The REAL start of this program!
* ENTRY: a command line full of data
* pointed to by regs.x
entry               pshs      d,x,y               save possible params
                    leax      crcacc,u            clear some memory
                    ldb       #datsiz             out for us.
                    clra
clrloop             sta       ,x+
                    decb
                    bne       clrloop
                    lda       #READ.              setup for data dir
                    sta       <exdir
                    sta       <verbose            to enable it unless shut off
                    puls      d,x,y
                    decb                          arguments?
                    lbeq      help                no,go
                    incb                          back to right count!

* and fall thru to setup, my command line checker with
* syntax relaxations, can take vfy -x -f filename,
* or vfy -fx (-xf) filename, also -s, -sk, -k alone illegal
* also -v now works to shut it up GH
setup               lda       ,x+                 get a char from cmnd line
                    decb                          track cmndline chars left
                    lbeq      help
setret              cmpa      #$20                a space?
                    beq       setup               yup, go get next char
                    cmpa      #'-                 is "-"?
                    beq       setup1              yup, go do the options
                    leax      -1,x                not space or -, rtn ptr
                    incb                          to restore count
                    lbra      openit              godoit, our other exit from here

setup1              lda       ,x+
                    decb
                    cmpa      #$41                is regs.a<#'A alpha char?
                    bmi       setret              wasn't, go
                    anda      #$df                else make uppercase

***** Edition 16 addition *****
                    cmpa      #'V
                    bne       setfix
                    clr       <verbose            shut it up
                    bra       setup1

setfix              cmpa      #'F
                    bne       setx                nope, go
                    sta       <fixit              to nz it
                    lda       #UPDAT.+SHARE.      we don't wanna share
setatts             ora       <exdir              if we're fixing it
                    sta       <exdir
                    bra       setup1
setx                cmpa      #'X
                    bne       setsepU
                    lda       #EXEC.
                    bra       setatts

************ setsepU ************
* added to pick up args for "fixmod"
* like operations
setsepU             cmpa      #'U
                    lbne      setsepS
                    lda       ,x+                 get next char to tell us what to do
                    decb                          track data
                    lbeq      help                can't be out here
                    anda      #$DF                make uppercase
                    cmpa      #'A                 change attr nibble?
                    bne       setsepR
setSepA             lbsr      skeqdlr             checks errs, returns good char
                    sta       <lftnbbl            to nz it so ascihex will shift
                    sta       <fixat              to tally new data avail
                    lbsr      ascihex             go make it a hexval
                    sta       <updtat
                    clr       <lftnbbl            cancel the order
                    inc       <updthead
                    bra       setup

setsepR             cmpa      #'R                 change rev nibble?
                    bne       setsepT             nope, maybe its Type
                    lbsr      skeqdlr
                    sta       <fixrv              to tally new data avail
                    lbsr      ascihex
                    sta       <updtrv
                    inc       <updthead
                    bra       setup

setsepT             cmpa      #'T
                    bne       setsepL             maybe its Language nibble?
                    lbsr      skeqdlr
                    sta       <lftnbbl            to nz it
                    sta       <fixty              to tally new data avail
                    lbsr      ascihex
                    sta       <updtty             new Type value in left nibble
                    clr       <lftnbbl            shut down the shifter
                    inc       <updthead
                    lbra      setup

setsepL             cmpa      #'L                 is it change lang nibble?
                    bne       setsepD             might be data size
                    lbsr      skeqdlr
                    sta       <fixla              to tally new data avail
                    lbsr      ascihex
                    sta       <updtla
                    inc       <updthead
                    lbra      setup

*************** setsepD ***************
* if more than 4 valid hex digits are entered
* on cmnd line, it will keep on looping,
* keeping the last 4 in updtdtsz. You can add
* as little as one byte with this retriever or
* subtract since the addition is modulo $8000,
* use -ud=$FFFE to subtract one byte!
setsepD             lbsr      skeqdlr             see if right syntax used
setdtsz             lbsr      ascihex             returns val in reg.a
                    pshs      b                   we want this order on the stack
                    pshs      a                   save the nibble on the stack
                    ldd       <updtdtsz
                    lslb
                    rola                          times 2 now
                    lslb
                    rola                          times 4 now
                    lslb
                    rola                          times 8 now
                    lslb
                    rola                          updtdtsz now *16
                    orb       ,s+                 least sig nibble dummy!
                    std       <updtdtsz
                    puls      b                   thats why we wanted this order
                    lda       ,x+
                    decb                          tryin to track cmdln data used
                    lbeq      help                better be more data here!
                    cmpa      #$20
                    lbeq      setup               oops, out of data but ok
                    lbmi      help                real probs, no filename!
                    inc       <updthead
                    bra       setdtsz

************** setsepS ***************
* sets it up to seperate a merged file,
* the kernal to be specific, but works
* on os9boot files too.
setsepS             cmpa      #'S
                    bne       SetName             this was to help
                    sta       <seperat            make nz to enable
                    lda       ,x+
                    decb                          obscure bug fixing
                    anda      #$DF
                    cmpa      #'K
                    bne       setsep1
                    lda       #$30                a zero
                    sta       <kernal             to nz it and furnish number
                    lbra      setup1
setsep1             leax      -1,x
                    incb                          bug fixing
                    lbra      setup1

****** Edition 16 addition ******
SetName             cmpa      #'N
                    lbne      help
                    lda       ,x+
                    cmpa      #'=
                    lbne      help
                    pshs      y                   we're gonna diddle it, save it
                    leay      cmpname,u
NameSave            lda       ,x+
                    cmpa      #32
                    bls       EndNmSv             must be done, back out
                    cmpa      #'9
                    bls       noupcase
                    anda      #$DF                name uppercase
* ok, lets see what its doing
noupcase            sta       ,y+                 and save it
                    bra       NameSave
EndNmSv             clr       ,y                  zero mark end of name
                    inc       <fixname
                    puls      y
                    bra       setsep1

**** end of setup, openit start ****
openit              decb                          filename there yet?
                    lbeq      help                no, go squawk
                    lda       <fixat
                    adda      <fixrv
                    adda      <fixla
                    adda      <fixty
                    adda      <fixname
                    adda      <updthead
                    beq       openatok
                    lda       #UPDAT.+SHARE.
                    ora       <exdir
                    sta       <exdir
* first, if named, get rid of updthead silliness
openatok            tst       <fixname            did we name a module?
                    beq       openit1             no, skip this
                    clr       <updthead           one or the other bud!
openit1             lda       <exdir              get attributes
                    os9       I$Open
                    lbcs      help                oh-oh, file not avail
                    sta       <inpath
                    lbsr      getsiz              get overall size
                    lbsr      seekmod             start at 0, old readit lbl
readit              lbsr      readabyt            opens head/tail files too
                    lda       ,x
readit1             cmpa      #$87                look for 1st byte
                    bne       readit
                    sta       <modid1
readit2             lbsr      readabyt            updates filepos via addseek
                    lda       ,x
                    cmpa      #$CD
                    bne       readit1
                    sta       <modid2             we found a file!
                    ldx       #$0002              we've got 2 bytes of
                    stx       <modpos             a module, record it
                    dec       <kbptr              cancel 2 outa non-mod buf
                    dec       <kbptr
                    beq       readit3             no use if zero
                    tst       <kernal             are we saving all
                    beq       readit3
                    lbsr      openkern            makes filepath
                    lbsr      clskrnl             writes kbptr size buffer and closes up
readit3             clr       <kbptr              so's it don't accumulate
                    lda       <inpath             get rest of header
                    leax      modlen,u
                    ldy       #$000C              get dev table entries too
                    os9       I$read              get those 12 bytes
                    lbsr      addsect             those 12 bytes to total len
                    ldd       <modlen
                    subd      #$03
                    std       <lmnscrc
                    lbsr      sethead             ->GETNAM->SEEKMOD
                    leax      mdoffset,pcr
                    ldy       #mdoffend-mdoffset
                    lbsr      showit
                    leax      modhstrt,u
                    stx       <numptr
                    ldb       #$04
                    lbsr      printit
                    leax      mdoffend,pcr
                    ldy       #ftopmem-mdoffend
                    lbsr      showit
initcrc             leax      crcacc,u
                    ldb       #6
                    lda       #$FF
psetcrc             sta       ,x+
                    decb
                    bne       psetcrc
                    lbsr      chkhead             go check/fix ty/la at/rv, parity, pdatasz
                    ldy       #$0E                (was $D)Because parity fixed in mem,
                    leax      modid1,u            crc displayed is right IF
                    os9       F$CRC               we do crc of 1st 14 bytes in mem
* after chkhead! It should arrive here with modpos=14
                    tst       <seperat
                    beq       docrc0
                    lbsr      openout
docrc0              inc       <sizyet
docrc               leax      buffer,u
                    ldd       <lmnscrc            module length-crcbytes
                    subd      <modpos
                    cmpd      #$100
                    bhi       getmore
                    tfr       d,y
                    inc       <moddone
                    bra       getlast
getmore             ldy       #$100               get a sectors worth
getlast             lda       <inpath
                    os9       I$Read
                    lbsr      addsect             doesn't chg x,y
                    tst       <sizyet
                    beq       getcont
                    pshs      d,x,y               save count
                    lbsr      dfinemd
                    puls      d,x,y
getcont             leax      buffer,u            the data
                    pshs      x,y                 save the pointer and quantity
                    os9       F$Crc               U already points at crcacc!
                    puls      x,y                 restore
                    lda       <outpath
                    beq       doneyet             we're not spliting it
                    os9       I$Write
                    lbcs      help                report error and quit
doneyet             tst       <moddone
                    beq       docrc
                    pshs      y
                    ldd       <crcacc             now copy crc to filecrc
                    coma                          and make valid
                    comb
                    std       <filecrc1           in case its bad
                    ldb       <crcac3             ditto
                    comb
                    stb       <filecrc3           ditto
                    bcc       donyet2
                    comb                          clear any carry
donyet2             tfr       x,d
                    addd      ,s++                puls the Y
                    tfr       d,x                 x now=crc location in buffer
                    pshs      x                   save it
                    lda       <inpath
                    ldy       #$03                the 3 crc bytes
                    os9       I$Read
                    lbsr      addsect             add to filepos
                    puls      x                   retrieve crc addr, y still=3
                    os9       F$CRC               whole modules crc now in crcacc
                    lbsr      chkcrc              go check, correct it
                    lda       <outpath
                    beq       dunyet              if zero, no path
                    leax      filecrc1,u          put good one out
                    ldy       #3
                    os9       I$Write
                    os9       I$Close
                    clr       <outpath
dunyet              clr       <moddone
                    lbra      readit              see if more file

*************************************
* The EOF is found, close up, go home
cleanup             bcc       cleanup1
                    comb                          we get here with the carry set
cleanup1            pshs      x,u                 save so's the tail is right
                    lda       <inpath
                    ldu       <flenls16           go back to real end of file
                    ldx       <flenms16
                    os9       I$Seek              to end of file
                    puls      x,u                 recover tail pointers
                    os9       I$Close             and close up w/o len change
                    tst       <kernal             are we saveing a kernal?
                    beq       cleanup2            if 0, nothing to write!
                    lbsr      openkern            go open a path
                    lbsr      clskrnl             write and close it
                    bcc       cleanup2
                    comb                          clear error flag
cleanup2            leax      howmany,pcr
                    ldy       #execoff-howmany
                    lbsr      showit              print the string
                    leax      seekms16,u          point at total length
                    stx       numptr              of file
                    ldb       #$04                bytes to print
                    lbsr      printit             convert to ascii and print
                    leax      newln,pcr           hang a newline on it
                    lbsr      newlnfd
alldun              clrb
                    os9       F$Exit              all done folks!

*************************************
* CHKHEAD - checks, fixes header checksum
*    entry: header in memory at modid1,u
chkhead             leax      hednamsg,pcr
                    ldy       #hedckmsg-hednamsg
                    lbsr      showit              'Header for: '
                    leax      mdlname,u
                    ldy       #$20                maxlength
                    lbsr      newlnfd             show the filename with cr
                    leax      hedckmsg,pcr
                    ldy       #ckbadsiz-hedckmsg
                    lbsr      showit              Header parity : $
                    ldb       #$01                only one byte to convert
                    leax      checksum,u          pass address of checksum
                    stx       <numptr
                    lbsr      printit             the parity byte

***********************************
* see if we got anything to fix
* check attr,rev,typ,lang,dsize
* and update the memory image
                    lda       <updthead           will be 1 if right module
                    adda      <fixit
                    beq       psetpar             nothin to fix
                    tst       <fixat              else
                    beq       revchk
atchk               lda       <modatrev
                    anda      #$0F                clear the attrib nibble
                    ora       <updtat             add in the attrib nibble
                    sta       <modatrev
                    clr       <fixat
revchk              tst       <fixrv
                    beq       tychk
                    lda       <modatrev
                    anda      #$F0                leave at nibble alone
                    ora       <updtrv
                    sta       <modatrev
                    clr       <fixrv
tychk               tst       <fixty
                    beq       langchk
                    lda       <typelang
                    anda      #$0F                clear out the type
                    ora       <updtty
                    sta       <typelang
                    clr       <fixty
langchk             tst       <fixla
                    beq       chkdtsz
                    lda       <typelang
                    anda      #$F0                leave upper nibble alone
                    ora       <updtla
                    sta       <typelang
                    clr       <fixla
chkdtsz             ldd       <updtdtsz
                    cmpd      #$0000              anything there?
                    beq       psetpar
                    ldd       <pdatasz1
                    addd      <updtdtsz           we're not saveing the carry folks!
                    std       <pdatasz1
                    clra
                    clrb
                    std       <updtdtsz           to make it one time only!
psetpar             lda       #$FF                pset parity accumulator
                    ldb       #$08
                    leax      modid1,u
headchk             eora      ,x+                 and check the checksum
                    decb
                    bne       headchk
                    cmpa      ,x                  s/b equal
                    beq       fxittst             go see if data needs updt
                    pshs      a,x                 else save a few things
                    leax      badmsg,pcr          show its bad
                    ldy       #badsiz-badmsg
                    lbsr      showit              ' (bad)'
                    puls      a,x                 a had correct parity
                    sta       ,x                  else fix in memory
                    stx       <numptr             point at it
                    leax      shdabeen,pcr
                    ldy       #badmsg-shdabeen
                    lbsr      showit              ' S/B $'
                    ldb       #$01                only one byte to convert
                    lbsr      printit             numptr already has src
fxittst             lda       <updthead           either will trigger fix
                    adda      <fixit              if neither one is on, go
                    beq       okmsg               leave it alone

*******************************************
* enableing the files fix, its now good in memory
                    pshs      u
                    ldx       <modhstrt
                    ldu       <modlstrt
                    lda       <inpath
                    os9       I$Seek              back up to $87CD bytes
                    puls      u
                    leax      modid1,u
                    ldy       #$0D                bytes to write
                    lda       <inpath
                    os9       I$Write             insert ty/la at/rv,parity,exec,pdatasz in file
                    lbcs      help
                    lbsr      seekmod             to restore the file pointer
                    leax      fixxmsg,pcr
                    ldy       #newln-fixxmsg
                    lbsr      showit              ' Repaired to $'
                    leax      checksum,u
                    stx       <numptr
                    ldb       #$01                numptr already set
                    lbsr      printit
okmsg               leax      gdmsg,pcr
                    ldy       #gdsiz-gdmsg
                    lbsr      newlnfd             ' (Good)\n'
                    lbsr      seekmod             to reset file ptr
headout             leax      modlnmsg,pcr
                    ldy       #crcmsg-modlnmsg
                    lbsr      showit              'Module size   : $'
                    leax      modlen,u            point to size in header
                    stx       <numptr
                    ldb       #$02
                    lbsr      printit
                    leax      newln,pcr
                    lbsr      newlnfd             finish this up
                    leax      vertion,pcr
                    ldy       #tplgatrv-vertion
                    lbsr      showit              'Edition      : $'
                    leax      mdlname,u
fndend              lda       ,x+
                    cmpa      #$0D
                    bne       fndend
                    stx       <numptr             is -> at edition now
                    ldb       #$01                one hex byte only
                    lbsr      printit             show it
                    leax      newln,pcr
                    ldy       #hdgdsiz-newln
                    lbsr      newlnfd
                    leax      tplgatrv,pcr
                    ldy       #typelook-tplgatrv
                    lbsr      showit
                    leax      typelang,u
                    stx       <numptr
                    ldb       #$01
                    lbsr      printit
                    ldx       <linptr
                    lda       #$20                space it out for the
                    sta       ,x+                 following atrev byte
                    sta       ,x+
                    sta       ,x+                 3 spaces
                    lda       #'$                 and a $ sign
                    sta       ,x
                    ldx       <linptr
                    ldy       #$04
                    lbsr      showit              show '   $'
                    ldb       #$01                the prev call inc'ed numptr
                    lbsr      printit             to the atrv byte!
                    leax      newln,pcr
                    ldy       #$02
                    lbsr      newlnfd
                    rts

*************************************
* CHKCRC of module
* when called, it expects to see the $800FE3
* (seed polynomial) in the crc accumulator
chkcrc              pshs      x                   save ptr to modules crc
                    leax      crcmsg,pcr
                    ldy       #crcmsiz-crcmsg
                    lbsr      showit              Modules CRC is: $
                    puls      x
* Now, x still points at the modules crc bytes!
* so we don't need a seperate number buffer
                    pshs      x                   we need it later
                    stx       <numptr
                    ldb       #$03                three bytes to display
                    lbsr      printit
                    puls      x
                    ldd       <crcacc             now do the check
                    cmpd      #$800F              first two bytes
                    bne       badcrc
                    lda       <crcac3
                    cmpa      #$E3                third
                    bne       badcrc
                    pshs      x                   save it again
crcdun              leax      gdmsg,pcr
                    ldy       #gdsiz-gdmsg
                    lbsr      showit
                    leax      newln,pcr           extra linefeed
                    ldy       #$02                to seperate reports
                    lbsr      newlnfd
                    clr       <updthead           stop this silliness
                    puls      x                   fergot it once, major crash!
                    rts

*************************************
* BADCRC - display results, check for
* fixit orders and fixit if told
badcrc              pshs      x                   save that pointer!
                    leax      badmsg,pcr
                    ldy       #badsiz-badmsg
                    lbsr      newlnfd
                    leax      shdabeen,pcr
                    ldy       #badmsg-shdabeen
                    lbsr      showit              Write ' S/B $'
                    leax      filecrc1,u          show actual crc
                    stx       <numptr
                    ldb       #$03
                    lbsr      printit
                    lda       <fixit              is valid whole file
                    adda      <updthead           one module only
                    beq       crcdun              wasn't told to fix it

********* enabling the fix **********
fixenbl             leax      seekls16,u          we're gonna write
                    ldd       ,x                  to the file, seek to
                    subd      #$03                crc start again
                    std       ,x
                    bcc       msigok
                    ldx       <seekms16           if borrow, dec hi int
                    leax      -1,x                of addrress
                    stx       <seekms16
msigok              lbsr      seekmod
                    leax      filecrc1,u
                    stx       <numptr             for later printout
                    ldy       #$03
                    lda       <inpath
                    os9       I$Write             and update the file!
                    lbcs      help
                    leax      fixxmsg,pcr
                    ldy       #newln-fixxmsg
                    lbsr      showit
                    ldy       #$03
                    leax      seekms16,u
                    bsr       addseek             to restore file ptr
                    ldb       #$03                digits to print
                    lbsr      printit             numptr already set
                    clr       <updthead           to stop it at one module
                    lbra      crcdun              go clean up end of crc display

**************************************
* ADDSECT - add reg.Y to length of module & file
* ENTRY   Y bytes to add to present file size
*         X location of 4 byte accumulator (seekms16,u)
addsect             pshs      y                   first inc modpos
                    ldd       <modpos
                    addd      ,s++
                    std       <modpos

* and fall thru to ---- ADDSEEK
* ENTRY   Y bytes to add to position in file
* EXIT    updated seekms16-seekls16 accumulator
addseek             pshs      x                   save present buffer addr
                    pshs      y                   updt passed file/seek pos
                    leax      seekms16,u
                    ldd       2,x                 seekls16
                    addd      ,s++
                    std       2,x
                    bcc       addout
                    ldd       ,x                  seekms16 works but cumbersome
                    adcb      #$00                methodology
                    std       ,x                  seekms16
                    bcc       addout
                    adca      #$00
                    std       ,x                  seekms16
addout              puls      x
                    rts

***************************************************
* SETHEAD - we've found an $87CD, reset modlstrt and
* modhstrt to offset 0000 of module for name finding
* also potential bugfixing. The previous usage of the
* leau -9,u didn't set a borrow if it occurred.
* This method does. Returning just to call getname
* was extra code, so now it falls thru since all we
* were doing is giving getname an anchor point.
sethead             ldd       <seekls16
                    ldx       <seekms16
                    subd      <modpos
                    std       <modlstrt           record starting pos
                    bcc       noborw
                    leax      -1,x
noborw              stx       <modhstrt           so we can recover
* and fall thru to getname
getname             ldd       <modlstrt           our reference location
                    pshs      d                   this pshs and ,s++
                    ldd       <modname            cancel
                    addd      ,s++                each other
                    std       <seekls16
                    bcc       nocari
                    leax      1,x                 add carry to hi int
nocari              stx       <seekms16
getit               bsr       seekmod
                    leax      mdlname,u
gtbyt               lda       <inpath
                    ldy       #$01
                    os9       I$Read
                    ldb       ,x+
                    bpl       gtbyt
                    andb      #$7F                cancel set msb
                    stb       -1,x
                    ldb       #$0d                add a cr
                    stb       ,x+                 to stop writln
                    lda       <inpath             and get edition byte!
                    ldy       #$01
                    os9       I$Read

***** Edition 16 addition ********************
* NAMECMP - controls middle of file
* fixit by name function
* Entry:  nz in "fixname"
*         module name in "cmpname"
* Exit:   nz in updthead, zero in fixname if match
* match is toupper of input name and saved name
* till cr matches zero of saved name
* by zeroing fixname, once done, don't waste
* more time by continuing to look at following mods
namecmp             tst       <fixname            if a name, it won't be zero
                    beq       noname              don't have a name to look for
                    pshs      y                   save it
                    leay      cmpname,u
                    leax      mdlname,u
namecmp1            lda       ,x+                 get modules name
                    cmpa      #$0D                till the cr we stashed
                    beq       chkmatch
                    cmpa      #'9                 this might not be the right cmp!
                    bls       nocaseup
                    anda      #$DF                make upcase
nocaseup            cmpa      ,y+                 against upcased saved name
                    bne       nomatch             ifne, no match found here
                    bra       namecmp1
chkmatch            tst       ,y                  ifeq, was end of saved name!
                    bne       nomatch
                    inc       <updthead
                    clr       <fixname            zero the snooper flag
nomatch             puls      y

* continue on with the previous code
noname              ldx       <modhstrt           now restore file ptr
                    ldd       <modlstrt           to byte after parity
                    pshs      d                   in header
                    ldd       <modpos
                    addd      ,s++
                    std       <seekls16
                    bcc       ncri
                    leax      1,x
ncri                stx       <seekms16
* and fall through to SEEKMOD

**************************************
* SEEKMOD - positions file r/w pointer
* Entry = valid pathnum in inpath
* presumes valid size in seekls16,seekms16
seekmod             lda       <inpath
                    pshs      u
                    ldx       <seekms16
                    ldu       <seekls16
                    os9       I$Seek
                    puls      u
                    bcs       oops
                    rts

**************************************
* READABYT get one byte from the file
readabyt            lda       <inpath
                    ldy       #1
                    leax      buffer,u
                    os9       I$Read
                    bcs       oops
                    pshs      x
                    leax      seekms16,u
                    lbsr      addseek             add y to file position
readout             puls      x                   but not to modpos just yet!
                    tst       <kernal             saving it all?
                    beq       readrts             no, go
                    pshs      b,x                 else save in 64 byte buffer
                    leax      krnlbuf,u
                    ldb       <kbptr
                    leax      b,x
                    lda       buffer,u
                    sta       ,x
                    incb
                    stb       <kbptr
                    cmpb      #buffer-krnlbuf
                    lbeq      helpnbf
                    puls      b,x                 and restore
readrts             rts

oops                cmpb      #E$EOF
                    lbeq      cleanup
                    lbra      help

***************************************************
* GETSIZ - function to get overall size of the file
* ENTRY valid pathum in 'inpath'
getsiz              pshs      u
                    lda       <inpath
                    ldb       #SS.Size
                    os9       I$Getstt
                    bcs       help
                    stx       <flenms16
                    stu       <flenls16
                    leax      flenmsg,pcr
                    ldy       #howmany-flenmsg
                    lbsr      showit
skppr20             puls      u                   it needs U restored
                    leax      flenms16,u          so this works
                    stx       <numptr
                    ldb       #$04
                    bsr       printit
                    leax      newln,pcr
                    ldy       #$02
                    lbsr      newlnfd
                    lbsr      newlnfd
                    rts

************************************
* PRINTIT - a front end for hextoasc
* ENTRY:  address of src data in numptr
*         regs.B=number of bytes to convert
printit             pshs      d,x,y
                    leax      linbuff,u
                    pshs      x
                    stx       <linptr
                    tfr       b,a                 save # to print
                    lsla                          dbl it
                    pshs      a
                    clr       ,-s                 so we can puls y later
                    bsr       hextoasc
                    puls      y                   get y back
                    puls      x                   and linebuff->
                    lbsr      showit              display the number
                    puls      d,x,y
                    rts

*********************************************
* HEXTOASC - routine to print hex numbers
* ENTRY regs.b:#of chars to print,
* variable location numptr set to src of data
* variable location linptr someplace in linbuff
hextoasc            ldx       <numptr             defined in host routine
                    lda       ,x+
                    stx       <numptr             save new ptr to next byte
                    pshs      b                   save your counter
                    bsr       hxbtoasc
                    ldx       <linptr             also defined in host routine
                    std       ,x++
                    stx       <linptr             save new pos in output buffer
                    puls      b
                    decb
                    bne       hextoasc            till hex num all converted!
                    rts                           and go print it

*************************************************************
* routine written up in the Rainbow  (11/92) by Tim Kientzle.
* It will convert the value passed in the A register to a
* pair of ascii characters in A:B which are the directly
* printable ASCII representations of the original contents
* of A. Load A with byte of src num, call, store A nd B in
* order in the print buffer on return.  Neat routine Tim!
* I shrank it by 4 lines & 6 bytes though (GH).
hxbtoasc            tfr       a,b                 Make copy of a
                    anda      #$0F                mask off lower digit
                    bsr       nbltoasc
                    exg       a,b                 stash in b, get a back
                    lsra                          getting high nibble
                    lsra                          into position to
                    lsra                          convert it
                    lsra
nbltoasc            adda      #$90                repeat for high nibble
                    daa                           generate carry if a>9
                    adca      #$40
                    daa
                    rts                           returns a:b=two hexidecimal characters

wphlp               comb
                    ldb       #$D6                no permission to write to it
                    bra       help
helpnbf             comb
                    ldb       #$BF                E$BufferToDamnSmall!

***********************************
* HELP an error exit with prompting
* Entry   error in B,carry set
help                pshs      b,cc                save stats for exit
                    inc       <verbose            make sure the msg gets out
                    leax      helpmsg,pcr
                    ldy       #msgsiz-helpmsg
                    lbsr      showit
                    puls      b,cc                recover error
out                 os9       F$Exit              and report the error

*************************************
* OPENOUT - opens path for std module
*
openout             lda       #READ.+WRITE.
                    ldb       #READ.+WRITE.
                    leax      mdlname,u           point at name
                    os9       I$Create            and attempt to make it
                    bcc       outhead             made it ok, go
                    cmpb      #218                oops, what error
                    bne       help                nope, not already exist, go
                    lda       #READ.+WRITE.
                    leax      mdlname,u
                    os9       I$Open
                    bcs       help
outhead             sta       <outpath            save pathnum
                    leax      modid1,u
                    ldy       #14                 write (repaired) module header w/exec & datsiz
                    os9       I$Write
                    bcs       help
                    rts                           thats all for now, folks

*****************************************
* OPENKERN - to open extra bytes files
* pretty much self-contained
openkern            pshs      cc,a,x
                    lda       <kernal
                    beq       kerrts
                    cmpa      #$30                head or tail?
                    bne       opentail
                    leax      advise0,pcr
                    ldy       #krnlhsz-advise0-1
                    lbsr      showit
                    ldb       <kbptr
                    bls       kerrts              if zero or less, go
                    leax      kernal0,pcr
kopen               lda       #UPDAT.
                    ldb       #UPDAT.
                    os9       I$Create
                    bcc       kcont
                    cmpb      #218                if exists, its ok
                    bne       help                else go yelp
                    bcc       kopen1
                    comb                          to clear that damned error
kopen1              ldb       #UPDAT.
                    os9       I$Open
                    bcs       help
kcont               sta       <kpath
krts                inc       <kernal             we been here, tally it
kerrts              puls      cc,a,x
                    rts

opentail            bcc       opntail
                    comb                          carry set?
opntail             cmpa      #$31                skip boot, os9p1
                    bne       krts
                    leax      advise1,pcr
                    ldy       #krnltsz-advise1-1
                    lbsr      showit
                    leax      kernal1,pcr
                    bra       kopen

***********************************
* CLSKRNL - write & close extras
* valid size in kbptrms*256+kbptr
clskrnl             pshs      d,x,y
                    tst       <kernal
                    beq       clsoops             shouldn't 'av come here
                    lda       <kpath
                    ldy       <kbptrms            size to write
                    leax      krnlbuf,u           saved data
                    os9       I$Write
                    lbcs      help
                    lda       <kpath
                    ldb       #$05                get file pos
                    pshs      x,u
                    os9       I$GetStt
                    lbcs      help
                    ldb       #$02                set as new size
                    os9       I$SetStt
                    lbcs      help
                    stu       <kbptrms
                    puls      x,u
                    os9       I$Close
                    lbcs      help
                    leax      kbptrms,u           point at filesize data
                    stx       <numptr             save the filesize
                    leax      advlen,pcr          now point at "with a size of $"
                    ldy       #advend-advlen      get length to write
                    lbsr      showit
                    ldb       #$02
                    lbsr      printit
                    leax      advend,pcr
                    ldy       #hednamsg-advend
                    lbsr      showit
                    leax      newln,pcr
                    ldy       #2
                    lbsr      newlnfd
                    clr       <kpath              kill pathnum
                    clr       <kbptr              reset
                    clr       <kbptrms
clsoops             puls      d,x,y
                    rts
                    emod
len                 equ       *
                    end

