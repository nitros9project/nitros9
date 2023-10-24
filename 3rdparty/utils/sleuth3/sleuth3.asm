******************************************
**
                    nam       CSC                 OS/9 Super Sleuth c1982
**
******************************************
**                                      **
**   CSC OS/9 Super Sleuth    c1982     **
**                                      **
** Computer Systems Consultants, Inc.   **
** E. M. Pass, Ph.D.                    **
** 1454 Latta Lane NW                   **
** Conyers, GA 30207                    **
**                                      **
******************************************
** Updates for OS9 Level 2 1990-1995
** M. E. (Gene) Heskett
** 291 Garton Avenue
** Weston, WV 26452
******************************************
** More Updates for NitrOS9 Level 2
** Bill Pierce 04/2016
** ooogalapasooo@aol.com
******************************************
**
vn                  equ       $04                 version number
**
********************** OS/9 uses *************************
* this module is for OS/9 library definitions
                    use       defsfile
**
                    mod       endmod,namemd,Prgrm+Objct,ReEnt+vn,start,endmem
**
namemd              fcs       "Sleuth3"
                    fcb       $0d
**
                    fcc       "CSC OS/9 Super Sleuth  c1982 v"
                    fcb       vn+$30
                    fcb       $0d
                    fcc       "All Rights Reserved by"
                    fcb       $0d
                    fcc       "E. M. (Bud) Pass, Ph.D."
                    fcb       $0d
                    fcc       "Computer Systems Consultants, Inc."
                    fcb       $0d
                    fcc       "1454 Latta Lane, Conyers, GA 30207"
                    fcb       $0d
                    fcc       "Telephone Number 404-483-1717/4570"
                    fcb       $0d
                    fcc       "Updates for OS9 level 2 by Gene Heskett"
                    fcb       $0d
                    fcc       "291 Garton Avenue, Weston, WV 26452"
                    fcb       $0d
                    fcc       "Telephone Number 304-269-4295/623-5555"
                    fcb       $0d
                    fcc       "Updates for NitrOS9 level 2 by Bill Pierce"
                    fcb       $0d
                    fcc       "570 Sandy Bend Rd., Rocky Point, North Carolina 28457"
                    fcb       $0d
                    fcc       "Email: ooogalapasooo@aol.com"
                    fcb       $0d
******************** cssvarbl ****************************
* this module contains variables used by the disassembler
* in performing its requested operations; of the entire
* disassembler, the only portions which should vary during
* execution are the variables in this module.
                    ttl       *** cssvarbl ***
***************************************
**
                    org       $0000
**
tabsiz              equ       $4000               default table space
**
prermb              equ       .                   see cssconst for these variables
fcbxx               rmb       7
fccxx               rmb       6
inst1               rmb       1
inst2               rmb       1
inst3               rmb       1
inst4               rmb       1
inst5               rmb       33
fdbxx               rmb       6
zlabel              rmb       2
ulabel              rmb       2
xlabel              rmb       2
lnames              rmb       10
names               rmb       37
loptes              rmb       10
optes               rmb       37
pshpul              rmb       16
prelen              equ       (.-prermb)
**
temps               equ       .                   start of work areas
baddr               rmb       2                   output of xbadr
caddr               rmb       2                   current addr
daddr               rmb       2                   hold addr
eaddr               rmb       2                   end addr
gaddr               rmb       2                   hold addr
iaddr               rmb       2                   instr save area ptr
maddr               rmb       2                   hold addr
oaddr               rmb       2                   offset addr
paddr               rmb       2                   hold addr
qaddr               rmb       2                   hold addr
raddr               rmb       2                   hold addr
saddr               rmb       2                   curr mem addr
xaddr               rmb       2                   xfer addr
zaddr               rmb       2                   hold addr
rmblth              rmb       2                   rmb length
faddr               rmb       2                   start addr
taddr               rmb       2                   end addr
types               rmb       2                   type table start
typee               rmb       2                   type table end
typem               rmb       2                   map table end
addre               rmb       2                   addr table end
stkadr              rmb       2                   stack hold addr
saves               rmb       2                   s-reg hold area
savew               rmb       2                   hold area for write routine
savex               rmb       2                   x-reg hold area
aoptab              rmb       2                   optabx addr
aintab              rmb       2                   intabx addr
asuftb              rmb       2                   suftbx addr
adrptr              rmb       2                   address ptr
alimit              rmb       2                   limit addr ptr
mystk               rmb       2                   top of stack
**
insbeg              equ       .                   first instr field
fllth               rmb       1                   length
fllts               rmb       1                   length from table
flopc               rmb       1                   instr
flsuf               rmb       1                   suffix
flmod               rmb       1                   mode
flspc               rmb       1                   special flag
flimm               rmb       1                   immediate
flinx               rmb       1                   indexed
flind               rmb       1                   indirect
flpls               rmb       1                   plus count
flmin               rmb       1                   minus count
flreg               rmb       1                   reg id
flamf               rmb       1                   addr mode field
floff               rmb       1                   offset id
flisw               rmb       1                   instr save switch
flabl               rmb       1                   labelled
flpos               rmb       1                   pos-ind flag
worka               rmb       1                   work area
instd               rmb       1                   default type
instr               rmb       1                   instr byte
instx               rmb       1                   type
insty               rmb       1                   type
instz               rmb       1                   type hold
**
insxx               equ       .                   name
inam0               rmb       1                   name letter 0
inam1               rmb       1                   name letter 1
inam2               rmb       1                   name letter 2
inam3               rmb       1                   name letter 3
inam4               rmb       1                   name letter 4
inam5               rmb       1                   name letter 5
insend              equ       .                   last instr field
inamx               rmb       1                   eot
**
cchar               rmb       1                   curr char
horptr              rmb       1                   horizontal pos
vrtptr              rmb       1                   vertical pos
phase               rmb       1                   phase number
pmode               rmb       1                   cpu mode
maxln               rmb       1                   max number items/line
escswt              rmb       1                   escape return switch
modmsk              rmb       1                   mode mask
posfl               rmb       1                   pos-ind switch
crtfl               rmb       1                   console switch
prnfl               rmb       1                   printer switch
disif               rmb       1                   disk input switch
disof               rmb       1                   disk output switch
getfl               rmb       1                   alt input switch
noecho              rmb       1                   no-echo flag
confl               rmb       1                   console flag
prtfl               rmb       1                   printer flag
dskfl               rmb       1                   disk flag
equfl               rmb       1                   equ flag
crofl               rmb       1                   cross-assembler flag
dorgs               rmb       1                   org flag
comand              rmb       1                   command character
column              rmb       1                   column number
defalt              rmb       1                   default memory type
**
objhdr              equ       .                   object module header
obiden              rmb       2                   ident ($87cd)
obsize              rmb       2                   size
obname              rmb       2                   name offset
obtyla              rmb       1                   type and language
obatre              rmb       1                   attributes and revision
obpari              rmb       1                   header parity check (xor)
obxfer              rmb       2                   xfer address
obstor              rmb       2                   storage address
objlth              equ       .-objhdr            object header length
**
crcacc              rmb       3                   crc accumulator
svcflg              rmb       1                   svc(ff)/none(00) indicator
os9flx              rmb       1                   os9(ff)/flex(00) indicator
lauorz              rmb       1                   u/z temp label name prefix
zulabe              rmb       1                   u/z label name prefix
objos9              equ       .-objhdr            object header length
**
inlrec              rmb       3                   random record index
curmod              rmb       3                   index of current module
nxtmod              rmb       3                   index of next module
scfopg              rmb       1                   pause flag
scfopp              rmb       1                   pause flag
ttyswt              rmb       1                   tty initialization switch
**
*
* buffers and I/O blocks
*
iobfc               equ       0                   function code
iobba               equ       1                   buffer address
iobbl               equ       3                   buffer length
iobfd               equ       5                   path descriptor
iobca               equ       7                   next char address
iobcc               equ       9                   char counter
ioblen              equ       16                  length of i/o block
buflen              equ       512                 length of i/o buffer
bufaux              equ       256                 length of auxiliary i/o buffer
buftrm              equ       256                 length of terminal i/o buffer
fnmlen              equ       128                 length of path name
read                equ       1                   read block raw
rdln                equ       2                   read block edited
write               equ       3                   write block raw
wrln                equ       4                   write block edited
**
                    rmb       ((((.+$00ff)/$100)*$100)-.) round to 256 bytes
**
inbuff              rmb       buflen              input buffer
oarea               equ       .                   temp screen area
otbuff              rmb       buflen              output buffer
harea               equ       .                   temp screen area
prbuff              rmb       buflen              printer buffer
axbuff              rmb       bufaux              auxiliary input buffer
tibuff              rmb       buftrm              terminal input buffer
tobuff              rmb       buftrm              terminal output buffer
**
infile              rmb       fnmlen              input path name
inblok              rmb       ioblen              input path rb
otfile              rmb       fnmlen              output path name
otblok              rmb       ioblen              output path rb
prfile              rmb       fnmlen              printer path name
prblok              rmb       ioblen              printer path rb
axfile              rmb       fnmlen              auxiliary path name
axblok              rmb       ioblen              auxiliary path rb
tiblok              rmb       ioblen              terminal input rb
toblok              rmb       ioblen              terminal output rb
**
scfolg              rmb       32                  scfman orig get options
scfolp              rmb       32                  scfman orig put options
scfwkg              rmb       32                  scfman work get options
scfwkp              rmb       32                  scfman work put options
**
locstk              rmb       512                 local save area
**
endpr               equ       .                   end program storage
                    rmb       tabsiz              reserve area for tables
tempe               equ       .                   end of tables
endprg              equ       .                   end of program
**
scrnwd              equ       12+4                screen width 4,8,16
scrbyt              equ       (scrnwd*16)         screen byte count
scrwid              equ       scrnwd              screen data width
scrhex              equ       (scrnwd*2-1)        screen hex end
scrals              equ       (scrnwd*2)          screen alpha start
scrale              equ       (scrnwd*3-2)        screen alpha end

endmem              equ       .
******************** cssinitz ****************************
* this module contains the external address table,
* the initialization routines, the command interpreter.
                    ttl       *** cssinitz ***
                    fcc       "*** cssinitz ***"
***************************************
**
start               equ       *                   starting address
**
initz               leax      temps,u             clear work area
                    ldy       #(tempe-temps)
clear               clr       ,x+
                    leay      -$01,y
                    bne       clear
                    leax      predef,pcr          init data
                    leay      prermb,u
                    ldb       #prelen
cleard              lda       ,x+
                    sta       ,y+
                    decb
                    bne       cleard
**
clears              sts       mystk,u             beginning stack pointer
                    leax      -$0200,s            table address limit
                    stx       alimit,u
                    lbsr      fixesc              fix escape addr, pg 7
                    lbsr      initty              initialize tty paras, pg 7
                    lbsr      inifil              initialize file buffers, pg 8
                    lda       #$09                set 6809 mode
                    lbsr      setmoi              set cpu mode, pg 10
                    lbsr      maprt               fix addrs, pg 10
                    inc       confl,u             set crt flag
                    lbsr      xcrlf               print heading, pg 83
                    leax      clrscn,pcr
                    lbsr      outcur              clear the screen, pg24
                    leax      idlin,pcr
                    lbsr      xpdat               output logo, pg 83
                    lda       #$30+vn
                    lbsr      xoute               output version, pg 83
                    lbsr      helpyu              output rest of heading, pg 10
**
askin               lds       mystk,u             look at input
                    tst       ttyswt,u            check tty switch
                    beq       askin0
                    bsr       initty              initialize tty params, pg 7
askin0              lbsr      inrtty              reset tty paras
                    lbsr      xcrlf               ,pg 83
                    leax      beeps,pcr           beep bell
                    lbsr      xpdat               , pg 83
                    lda       #$3f                print a ?
                    lbsr      xoute               , pg 83
askin1              lbsr      xinee               read command, pg 81
                    cmpa      #$20                chk cntrl char
                    bgt       askin2              its printable
                    cmpa      #$0d                chk cr
                    bne       askin
                    tst       getfl,u             chk get flag
                    bne       askin1              ignore if so
                    bra       askin
askin2              leax      coman,pcr           command table
                    anda      #$5f                to upper case
                    sta       comand,u
                    pshs      a                   offset
                    clrb
                    cmpa      #'A                 A?
                    blo       rdjmp
                    cmpa      #'Z                 Z?
                    bhi       rdjmp
                    tfr       a,b
                    subb      #$40                sub ascii bias
                    aslb                          dbl it
rdjmp               ldd       b,x                 jump to routine
                    leax      d,x
                    puls      a                   get offset back
                    jsr       ,x
                    bra       askin               end of this routine
**
fixesc              equ       *                   fix escape action
                    leax      xcrlr,pcr           interrupt handler
                    os9       F$Icpt              catch interrupts
                    rts
**
initty              ldd       #$0000              set up tty paras
                    leax      scfolg,u            point to scf orig area
                    os9       I$GetStt            get tty info
                    ldd       #$0100              set up tty paras
                    leax      scfolp,u            point to scf orig area
                    os9       I$GetStt            get tty info
                    lda       scfolg+PD.PAU-PD.OPT,u
                    ldb       scfolp+PD.PAU-PD.OPT,u
                    sta       scfopg,u
                    stb       scfopp,u
                    clr       scfolg+PD.PAU-PD.OPT,u
                    clr       scfolp+PD.PAU-PD.OPT,u
                    clr       ttyswt,u            clear tty switch
                    bra       inrtty              set up tty paras
**
wtftty              lda       #write              reset write paras
                    sta       toblok+iobfc,u
                    rts
**
wlftty              lda       #wrln               reset write paras
                    sta       toblok+iobfc,u
                    rts
**
scstty              lda       #write              reset write paras
                    sta       toblok+iobfc,u
                    bra       fcstty
**
csctty              bsr       ingtty              copy tty paras
                    clr       scfwkg+PD.BSP-PD.OPT,u
                    clr       scfwkg+PD.DEL-PD.OPT,u
                    clr       scfwkg+PD.EOF-PD.OPT,u
                    clr       scfwkg+PD.RPR-PD.OPT,u
                    clr       scfwkg+PD.DUP-PD.OPT,u
                    clr       scfwkg+PD.INT-PD.OPT,u
                    clr       scfwkg+PD.QUT-PD.OPT,u
                    clr       scfwkg+PD.EKO-PD.OPT,u echo
                    lda       #wrln               reset write paras
                    sta       toblok+iobfc,u
**
fcstty              com       scfwkg+PD.EKO-PD.OPT,u echo
**
instty              ldd       #$0000              set tty paras
                    leax      scfwkg,u            point to scf work
                    os9       I$SetStt            set tty info
                    rts
**
lastty              lda       scfopg,u            restore pause
                    ldb       scfopp,u
                    sta       scfolg+PD.PAU-PD.OPT,u
                    stb       scfolp+PD.PAU-PD.OPT,u
                    lda       #$ff                set tty switch
                    sta       ttyswt,u
**
inrtty              lda       #read               reset read paras
                    sta       tiblok+iobfc,u
**
inftty              lda       #wrln               reset write paras
                    sta       toblok+iobfc,u
**
fintty              ldd       #$0000              final reset tty paras
                    leax      scfolg,u            point to scf orig area
                    os9       I$SetStt            set tty info
                    ldd       #$0100              reset tty paras
                    leax      scfolp,u            point to scf orig
                    os9       I$SetStt            set tty info
**
ingtty              ldd       #$0000              get tty paras
                    leax      scfwkg,u            point to scf work
                    os9       I$GetStt            get tty info
                    ldd       #$0100              get tty paras
                    leax      scfwkp,u            point to scf work
                    os9       I$GetStt            get tty info
                    rts
**
inbtty              lda       #rdln               set tty paras for buffer
                    sta       tiblok+iobfc,u
                    bra       inftty
**
inifil              lda       #read               set up i/o blocks
                    sta       inblok+iobfc,u
                    sta       tiblok+iobfc,u
                    lda       #write
                    sta       otblok+iobfc,u
                    lda       #wrln
                    sta       prblok+iobfc,u
                    sta       toblok+iobfc,u
                    ldd       #buftrm
                    std       tiblok+iobbl,u
                    std       toblok+iobbl,u
                    std       toblok+iobcc,u
                    ldd       #buflen
                    std       inblok+iobbl,u
                    std       otblok+iobbl,u
                    std       otblok+iobcc,u
                    std       prblok+iobbl,u
                    std       prblok+iobcc,u
                    ldd       #$0001
                    std       toblok+iobfd,u
                    incb
                    leax      inbuff,u
                    stx       inblok+iobba,u
                    stx       inblok+iobca,u
                    leax      otbuff,u
                    stx       otblok+iobba,u
                    stx       otblok+iobca,u
                    leax      tibuff,u
                    stx       tiblok+iobba,u
                    stx       tiblok+iobca,u
                    leax      tobuff,u
                    stx       toblok+iobba,u
                    stx       toblok+iobca,u
                    leax      prbuff,u
                    stx       prblok+iobba,u
                    stx       prblok+iobca,u
                    ldd       #$0000
                    std       inlrec,u
                    sta       inlrec+2,u
                    ldd       #$ffff
                    std       curmod,u
                    std       nxtmod,u
                    sta       curmod+2,u
                    sta       nxtmod+2,u
                    rts
******************** cssmiscl ****************************
* this module contains several utility-type routines,
* generally called from the command interpreter.
                    ttl       *** cssmiscl ***
                    fcc       "*** cssmiscl ***"
***************************************
**
helpme              lbsr      stopin              help routine
                    leax      clrscn,pcr          clear screen
                    lbsr      outcur
                    leax      helps,pcr
helpyu              stx       baddr,u
                    lbsr      xcrlf
                    ldx       baddr,u
                    lbsr      xpdat
                    tst       ,x
                    bne       helpyu
                    rts
**
fcrof               lbsr      xinee               flip cross-assembler flag
                    com       crofl,u
                    rts
**
fequf               lbsr      xinee               flip equ flag
                    com       equfl,u
                    rts
**
fposf               lbsr      xinee               flip pos-ind flag
                    com       posfl,u
                    rts
**
setmod              lbsr      xcrlf               set cpu mode
                    leax      lmode,pcr
                    lbsr      xpdat
                    lbsr      xnhex
setmoi              ldb       #$07                mode mask
                    tsta                          allow only 0,1,2,3,5,8,9
                    bne       setmo0
setmo1              leax      intab0,pcr
                    stx       aintab,u
                    leax      optab0,pcr
                    stx       aoptab,u
                    leax      suftb9,pcr
                    stx       asuftb,u
                    anda      #$01
                    bra       setmox
setmo0              cmpa      #$01
                    beq       setmo1
                    cmpa      #$02
                    bne       setmo2
                    leax      intab2,pcr
                    stx       aintab,u
                    leax      optab2,pcr
                    stx       aoptab,u
                    leax      suftb5,pcr
                    stx       asuftb,u
                    bra       setmom
setmo2              cmpa      #$03
                    beq       setmo1
                    cmpa      #$05
                    bne       setmo5
                    leax      intab5,pcr
                    stx       aintab,u
                    leax      optab5,pcr
                    stx       aoptab,u
                    leax      suftb5,pcr
                    stx       asuftb,u
                    bra       setmom
setmo5              cmpa      #$08
                    beq       setmo1
                    cmpa      #$09
                    bne       setmod
                    leax      intab9,pcr          addr 6809 table
                    stx       aintab,u            save pointer to
                    leax      optab9,pcr          addr 6809 table
                    stx       aoptab,u            save pointer to
                    leax      suftb9,pcr          addr 6809 table
                    stx       asuftb,u            save pointer to
                    lda       #$ff
                    bra       setmox
setmom              ldb       #$0f                set mask
setmox              sta       pmode,u
                    stb       modmsk,u
                    rts
**
newrng              tst       os9flx,u            set dis range
                    beq       newnos
                    tst       infile,u            chk for file
                    beq       newnos
                    lbra      badrg               can't change OS/9 disk module addr
newnos              leax      inam0,u
                    lbsr      gadrs
                    bls       newrag
                    lbsr      badrg
                    bra       newnos
newrag              ldd       inam2,u
                    std       taddr,u
                    ldx       inam0,u
                    stx       faddr,u
                    bne       newaok              check for bad range
                    cmpd      #$ffff
                    bne       newaok
                    ldd       #$fff0              fix bad upper bound
                    std       taddr,u
newaok              clr       os9flx,u            determine if OS/9 or flex
                    ldx       #$0000              clear offset
                    stx       oaddr,u
                    subd      faddr,u
                    cmpd      #objlth+3
                    lbls      sxfer               chk too short
                    leay      objhdr,u            point to header
                    ldx       faddr,u
                    stx       saddr,u
                    ldb       #objlth
newhdr              pshs      b
                    lbsr      getin
                    puls      b
                    sta       ,y+
                    decb
                    bne       newhdr
                    leax      objhdr,u
                    ldd       M$ID,x              chk second byte of header
                    cmpd      #M$ID12             $87CD
                    lbne      sxfer
                    ldy       M$Size,x            chk module length
                    lbeq      sxfer
                    cmpy      M$Name,x            chk name offset > length
                    lblo      sxfer
                    cmpy      M$Exec,x
                    lbls      sxfer               chk xfer > length
                    exg       d,y
                    addd      M$Mem,x             was m$stak,x
                    exg       d,y
                    lbcs      sxfer               chk prog + data > 65k
                    ldb       M$Type,x
                    andb      #LangMask           was lanmsk chk language
                    cmpb      #Objct
                    lbne      sxfer
                    ldb       ,x+                 chk header parity
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    comb
                    bne       sxfer
                    ldy       ,x++                get xfer addr
                    sty       xaddr,u             set xfer addr
                    ldx       faddr,u             get module start addr
                    stx       oaddr,u             set offset addr
                    ldx       #$0000
                    stx       faddr,u             set start addr
                    ldx       obsize,u
                    leax      -$04,x
                    stx       taddr,u
                    dec       os9flx,u            set OS/9 flag
                    lbsr      xcrlf
                    leax      endpr,u             reset table pointers
                    stx       types,u
                    stx       typem,u
                    stx       typee,u
                    lbsr      dmptae              print table
                    ldx       obstor,u            chk storage size
                    beq       newstx
                    lbsr      xouts
                    leax      ldata,pcr           storage
                    lbsr      xpdat
                    leax      lstar,pcr           x-->" start="
                    lbsr      xpdat
                    ldx       #$0000
                    pshs      x
                    tfr       s,x
                    lbsr      xot4h               xxxx
                    leax      lendr,pcr           x-->" end="
                    lbsr      xpdat
                    ldx       obstor,u
                    leax      -$01,x
                    stx       ,s
                    tfr       s,x
                    lbsr      xot4h               xxxx
                    puls      x
newstx              rts
**
sxfer               tst       os9flx,u            chk for OS/9
                    lbne      badrg               can't change OS/9 xfer addr
                    leax      lxfer,pcr           set xfer addr
                    lbsr      xpdat
                    lbsr      xbadr
sxfet               stx       xaddr,u
                    rts
**
oload               tst       os9flx,u            set load offset
                    lbne      badrg               can't change OS/9 offset
                    leax      offil,pcr
                    lbsr      xpdat
                    lbsr      xouts
                    lbsr      xbadr
                    stx       oaddr,u
                    rts
**
fexit               lbsr      xinee               exit
fexeof              leax      clrscn,pcr
                    lbsr      outcur
                    bsr       fmsclo
                    lbsr      lastty              reset tty parameters
                    ldd       #$0000
                    os9       F$Exit              exit
**
doscom              lbsr      stopin              send message to OS/9
                    lbsr      xouts               print prompt
                    lda       #$2b                a "+" sign
                    lbsr      xoute
                    lbsr      xoute
                    lbsr      xoute
                    sts       stkadr,u
                    ldx       typee,u
                    clr       ,x+
                    lbsr      inbufd              get input line
                    cmpa      #$0d
                    beq       doscox              skip if null
                    lda       #$03
                    sta       escswt,u            set escape switch
                    pshs      x
                    lbsr      lastty              reset tty parameters
                    puls      x
                    bsr       doxcom              call OS/9
doscoy              lbsr      fixesc              restore escape
                    lbsr      initty              set up tty parametes
doscox              clr       escswt,u
                    rts
**
fmsclo              leax      prblok,u            close open files
                    lbsr      fob
fmscl0              tst       disif,u             check input file
                    beq       fmscl1
                    clr       infile,u
                    lda       inblok+iobfd+1,u
                    os9       I$Close
                    bcc       fmscl1
                    lda       #$02                error
                    leax      errirz,pcr
                    ldy       #errirl
                    os9       I$WritLn
fmscl1              lbsr      ende3               close printer and disk
fmsclx              rts
**
doxcom              equ       *                   call OS/9
                    sts       saves,u             remember stack
                    pshs      x,y,u               set up fork
                    tfr       x,u                 parameter area
                    tfr       x,y
doxpas              tst       ,y+                 check for end
                    bne       doxpas
                    ldd       #$0d0d              cr cr
                    std       -$01,y
                    tfr       y,d
                    subd      ,s
                    tfr       d,y                 parameter area size
                    leax      vshell,pcr          "shell"
                    clra                          language/type
                    clrb                          size
                    os9       F$Fork              spawn new task
                    puls      x,y,u
                    bcs       doxcer              check for error
                    pshs      a                   save new id
doxcwt              os9       F$Wait              wait for child task
                    bcs       doxcer
                    cmpa      ,s                  right task?
                    bne       doxcwt              wait some more if not
                    puls      a                   restore child task id
                    tstb                          check for child task error
                    beq       doxcox              exit
doxcer              lda       #$02                error path
                    os9       F$PErr
doxcox              lds       saves,u             recall stack
                    rts
******************** cssauxil ****************************
* this module contains routines which control auxiliary
* input and output; auxiliary input is handled by fooling
* the character input routine by making it read from the
* auxiliary file rather than from the terminal; auxiliary
* output is handled by formatting a file with data
* simulating command interpreter input.
                    ttl       *** cssauxil ***
                    fcc       "*** cssauxil ***"
***************************************
**
auxino              lbsr      xcrlf               get aux file info
                    leax      altnm,pcr
                    lbsr      xpdat
                    leax      disim,pcr
                    lbsr      xpdat
                    leax      axfile,u
                    lbsr      inbufr              get file name to line buffer
                    cmpa      #$0d
                    bne       strtin              process input aux file
                    lbsr      xcrlf
                    leax      altnm,pcr
                    lbsr      xpdat
                    leax      disom,pcr
                    lbsr      xpdat
                    leax      otfile,u
                    lbsr      inbufr              get file name to line buffer
                    cmpa      #$0d
                    lbne      statoa              process output aux file
                    rts
**
strtin              bsr       stopin              start aux input file
                    lda       #READ.              open input axfile
                    clrb
                    leax      axfile,u
                    os9       I$Open
                    bcs       strtie
                    exg       a,b
                    std       axblok+iobfd,u      file desc
                    ldd       #bufaux             buffer length
                    std       axblok+iobbl,u
                    ldd       #$0000
                    std       axblok+iobcc,u
                    leax      axbuff,u
                    stx       axblok+iobba,u
                    stx       axblok+iobca,u
                    lda       #READ.              mode
                    sta       axblok+iobfc,u
                    inc       getfl,u             set aux flag
                    bra       strtix
strtie              lda       #$02                error
                    leax      errarz,pcr
                    ldy       #errarl
                    os9       I$WritLn
                    clr       axfile,u
                    ldd       #$0000
                    std       axblok+iobfd,u      file desc
strtix              rts
**
stopin              pshs      x                   stop aux input
                    tst       getfl,u
                    beq       stopix
                    clr       getfl,u             reset aux flag
                    clr       axfile,u            close file
                    lda       axblok+iobfd+1,u    file desc
                    os9       I$Close
                    bcc       stopie
                    lda       #$02                error
                    leax      errarz,pcr
                    ldy       #errarl
                    os9       I$WritLn
stopie              ldd       #$0000
                    std       axblok+iobfd,u
stopix              puls      x,pc
**
statoa              leax      otfile,u            open output otfile
                    ldd       #(WRITE.*256)+(READ.+WRITE.+PREAD.) access and attributes
                    os9       I$Create
                    bcc       statof
                    cmpb      #218                files exists?
                    bne       stater
                    ldd       #(WRITE.*256)+(UPDAT.+PREAD.) about the same attr's
                    os9       I$Open
                    bcc       statof
* lda #$02 error
* leax errarz,pcr
* ldy #errarl
* os9 I$WritLn
stater              os9       F$PErr
                    clr       otfile,u
                    rts
statof              clrb                          file desc
                    exg       a,b
                    std       otblok+iobfd,u
                    ldd       #buflen             buffer length
                    std       otblok+iobbl,u
                    std       otblok+iobcc,u
                    ldd       otblok+iobba,u      buffer addr
                    std       otblok+iobca,u
                    clr       confl,u             don't output to console
                    inc       dskfl,u             output to disk
statra              lda       #$73                #'s=partial reset
                    lbsr      xoute
                    lbsr      xouts
                    lbsr      xcrlf
                    lda       #$6f                #'o offset
                    lbsr      xoute
                    lbsr      xouts
                    tst       os9flx,u            chk for OS/9
                    beq       stata1
                    lda       #$30                #'0
                    lbsr      xoute
                    lbsr      xoute
                    lbsr      xoute
                    lbsr      xoute
                    bra       stata2
stata1              leax      oaddr,u
                    lbsr      xot4h
stata2              tst       disif,u             chk for input file
                    beq       statrb
                    lbsr      xcrlf
                    lda       #$73                an s
                    lbsr      xoute
                    lbsr      xouts
                    leax      infile,u
                    lbsr      dmptav
statrb              ldx       typem,u
statrc              cmpx      typee,u
                    bhs       statre
statrd              stx       caddr,u             output a line
                    lbsr      xcrlf
                    ldx       caddr,u
                    lda       ,x
                    cmpa      #'Z                 was #$5a chk 'Z
                    beq       statr2
                    ora       #$20
                    lbsr      xoute               type
                    lbsr      xouts               space
                    leax      $01,x
                    lbsr      xot4s               start
                    lbsr      xot4s               end
                    leax      $01,x
statr1              leax      $02,x
                    bra       statrc
statr2              ldd       $01,x               chk start/end
                    cmpd      $03,x
                    bne       statr4
                    lda       #$6d                make 'm
                    lbsr      xoute               type
                    lbsr      xouts               space
                    leax      $03,x
statr3              lbsr      xot4s               end
                    lbsr      xot2s               value
                    bra       statr1
statr4              lda       #$74                make 't
                    lbsr      xoute               type
                    lbsr      xouts               space
                    leax      $01,x
                    lbsr      xot4s               start
                    bra       statr3
statre              lbsr      xcrlf               print parms
                    ldx       faddr,u
                    leax      $01,x
                    beq       statrf
                    tst       os9flx,u            chk for OS/9
                    beq       state1
                    tst       infile,u            chk for file
                    bne       statrf
state1              lda       #$6e                make 'n
                    lbsr      xoute
                    lbsr      xouts
                    tst       os9flx,u
                    beq       state2
                    leax      oaddr,u             OS/9
                    lbsr      xot4s
                    ldd       taddr,u
                    addd      oaddr,u
                    pshs      d
                    tfr       s,x
                    lbsr      xot4s
                    puls      d
                    bra       state9
state2              leax      faddr,u             flex
                    lbsr      xot4s
                    lbsr      xot4s
                    leax      xaddr,u
                    lbsr      xot4h
state9              lbsr      xcrlf
statrf              tst       equfl,u
                    beq       statrh
                    lda       #$65                #'e
                    lbsr      xoute
                    lbsr      xcrlf
statrh              tst       posfl,u
                    beq       statri
                    lda       #$70                #'p
                    lbsr      xoute
                    lbsr      xcrlf
statri              lda       #$7a                #'z
                    lbsr      xoute
                    lbsr      xouts
                    lda       pmode,u
                    bpl       statrj
                    lda       #$09
statrj              adda      #$30                #'0
                    lbsr      xoute
                    lbsr      xcrlf
statrk              tst       crofl,u
                    bne       statcl
                    lda       #$62                b
                    lbsr      xoute
                    lbsr      xcrlf
statcl              inc       confl,u             output to console
                    clr       dskfl,u             don't output to disk
                    leax      otblok,u            force output
                    lbsr      fob
                    bcc       static
                    lda       #$02                error
                    leax      errarz,pcr
                    ldy       #errarl
                    os9       I$WritLn
static              lda       otblok+iobfd+1,u    file desc
                    os9       I$Close
                    bcc       statie
                    lda       #$02                error
                    leax      errarz,pcr
                    ldy       #errarl
                    os9       I$WritLn
statie              ldd       #$0000
                    std       otblok+iobfd,u
statrx              rts
******************** cssdmptb ****************************
* this module contains the routine which lists internal
* control tables to the output device.
                    ttl       *** cssdmptb ***
                    fcc       "*** cssdmptb ***"
***************************************
**
dmptab              lbsr      xcrlf               dump tables
                    ldx       typem,u
dmptac              cmpx      typee,u
                    bhs       dmptae
dmptad              stx       caddr,u             print a line
                    lbsr      xcrlf
                    ldx       caddr,u
                    lda       ,x
                    cmpa      #$5a                chk 'Z
                    beq       dmpta2
                    ora       #$20
                    lbsr      xoute               type
                    lbsr      xouts               space
                    leax      $01,x
                    lbsr      xot4s               start
                    lbsr      xot4s               end
                    leax      $01,x
dmpta1              leax      $02,x
                    bra       dmptac
dmpta2              ldd       $01,x               chk start/end
                    cmpd      $03,x
                    bne       dmpta4
                    lda       #$6d                make m
                    lbsr      xoute               type
                    lbsr      xouts               space
                    leax      $03,x
dmpta3              lbsr      xot4s               end
                    lbsr      xot2s               value
                    bra       dmpta1
dmpta4              lda       #$74                make 't
                    lbsr      xoute               type
                    lbsr      xouts               space
                    leax      $01,x
                    lbsr      xot4s               start
                    bra       dmpta3
dmptae              lbsr      xcrlf               print parms
                    ldx       faddr,u
                    leax      $01,x
                    beq       dmptag
                    leax      loss9,pcr           OS/9 or Flex
                    tst       os9flx,u
                    bne       dmpte1
                    leax      lflex,pcr
dmpte1              lbsr      xpdat
                    leax      lstar,pcr           x-->" start="
                    lbsr      xpdat
                    leax      faddr,u
                    lbsr      xot4h
                    leax      lendr,pcr           x-->" end="
                    lbsr      xpdat
                    leax      taddr,u
                    lbsr      xot4h
dmptaf              ldx       xaddr,u
                    leax      $01,x
                    beq       dmptag
                    leax      lxfer,pcr           x-->" xfer="
                    lbsr      xpdat
                    leax      xaddr,u
                    lbsr      xot4h
dmptag              lbsr      xcrlf
                    ldx       oaddr,u
                    beq       dmptah
                    tst       os9flx,u            chk for OS/9
                    bne       dmptah
                    leax      offil,pcr           offset
                    lbsr      xpdat
                    lbsr      xouts
                    leax      oaddr,u
                    lbsr      xot4h
                    lbsr      xcrlf
dmptah              leax      equil,pcr           equ flag
                    lbsr      xpdat
                    leax      lon,pcr
                    tst       equfl,u
                    bne       dmptai
                    leax      loff,pcr
dmptai              lbsr      xpdat
                    lbsr      xcrlf
                    leax      cpuil,pcr           cpu mode
                    lbsr      xpdat
                    lbsr      xouts
                    lda       #$36
                    lbsr      xoute
                    ldb       pmode,u
                    bpl       dmptaj
                    ldb       #$09
dmptaj              addb      #$30
                    lda       #$38
                    cmpb      #$32                chk 2
                    bne       dmptak
                    lda       #$35
dmptak              lbsr      xoute
                    lda       #$30
                    lbsr      xoute
                    tfr       b,a
                    lbsr      xoute
                    lbsr      xcrlf
                    leax      posil,pcr           position flag
                    lbsr      xpdat
                    leax      lon,pcr
                    tst       posfl,u
                    bne       dmptal
                    leax      loff,pcr
dmptal              lbsr      xpdat
                    lbsr      xcrlf
                    leax      croil,pcr           cross-assembler flag
                    lbsr      xpdat
                    leax      lon,pcr
                    tst       crofl,u
                    bne       dmptan
                    leax      loff,pcr
dmptan              lbsr      xpdat
                    lbsr      xcrlf
                    tst       disif,u             chk for input file
                    beq       dmptaw
                    leax      disim,pcr
                    lbsr      xpdat
                    leax      infile,u
dmptav              lda       ,x+                 print file info
                    cmpa      #$20
                    blo       dmptaw
                    lbsr      xoute
                    bra       dmptav
dmptaw              rts                           exit
******************** cssshowc ****************************
* this module contains routines which implement the full
* screen display and modification of object program code;
* the specific nature of a given system and terminal is
* provided by other library files which must be included
* by the user to suit a given situation.
                    ttl       *** cssshowc ***
                    fcc       "*** cssshowc ***"
***************************************
**
showaa              ldx       faddr,u             show object program
                    stx       saddr,u
                    leax      $01,x
                    bne       showab
                    rts
showab              lbsr      stopin              clear aux input
                    clr       saddr+1,u
                    lda       #$04
                    sta       inst1+scrnwd,u
                    sta       flisw,u
showac              lbsr      csctty              set tty parameters
showad              lbsr      wlftty              change function code
                    lbsr      xcrlf               print heading
                    leax      oarea-1,u           init pointers
                    stx       iaddr,u
                    leax      harea-1,u
                    stx       gaddr,u
                    leax      clrscn,pcr
                    lbsr      outcur              clear screen
                    ldb       #scrwid             format screen
                    cmpb      #$08
                    blt       showa2
                    leax      shotab,pcr
                    lbsr      xpdat
                    cmpb      #$08
                    beq       showa1
                    lbsr      xpdat
showa1              leax      shota1,pcr
                    lbsr      xpdat
                    cmpb      #$08
                    beq       showa2
                    lbsr      xpdat
showa2              leax      shota2,pcr
                    stx       eaddr,u
showae              ldx       eaddr,u             get next byte
                    lda       ,x
                    bne       showaf
                    lbsr      wtftty              change function code
                    lbra      showba              null=end
showaf              leax      $01,x
                    stx       eaddr,u
                    cmpa      #$2f
                    beq       showaj              /=line
                    cmpa      #$3c
                    bne       showag              <=start
                    leax      faddr,u
                    bra       showah
showag              cmpa      #$3e
                    bne       showai              >=end
                    leax      taddr,u
showah              lbsr      xot4h               xxxx
                    bra       showae
showai              lbsr      xoute
                    bra       showae
showaj              leax      shota2+1,pcr        print data line
                    cmpx      eaddr,u
                    bne       showja
                    ldb       #scrwid
                    cmpb      #$04
                    beq       showjj
showja              lbsr      xcrlf
showjj              leax      saddr,u
                    lbsr      xot4s
                    leax      inst1,u
                    stx       raddr,u
                    ldb       #scrwid             loop scrwid times
showak              pshs      b                   print hex
                    lbsr      getin
                    ldx       gaddr,u
                    leax      $01,x
                    sta       ,x
                    stx       gaddr,u
                    leax      instr,u
                    lbsr      xot2h
                    lda       insty,u
                    ora       #$40
                    suba      #$20
                    cmpa      #$32                chk for rmb
                    bne       showal
                    lda       #$22                change to "
showal              lbsr      xoute
                    lda       instr,u
                    anda      #$7f
                    ldx       raddr,u
                    cmpa      #$1f
                    bls       showam
                    cmpa      #maxprn
                    bls       showao
showam              lda       #$2e                .
showao              sta       ,x+
                    stx       raddr,u
                    puls      b
                    decb
                    bne       showak
                    lbsr      xouts
                    leax      inst1,u
                    lbsr      xpdat               print alpha
                    lbsr      xouts
                    lbra      showae
showba              lbsr      xinee               get command
                    cmpa      #$5f
                    bls       showby
                    anda      #$5f                fix case
showby              cmpa      #$51
                    bne       showbc              q=quit
showbz              clr       flisw,u             clear switch
                    lbra      inrtty              reset paras and exit
showbc              cmpa      #$50
                    bne       showbd              p=prev
                    ldd       saddr,u
                    subd      #(scrbyt*2)
                    bra       showbq
showbd              cmpa      #$53
                    bne       showbg              s=screen
                    ldd       saddr,u
                    subd      #scrbyt
                    std       saddr,u
                    leax      toblok,u            force output
                    lbsr      fob
                    lbsr      fulscr              full screen edit
                    lbra      showac
showbg              cmpa      #$2f
                    bhi       showbj              space=next
showbi              ldd       saddr,u             chk for end
                    cmpd      taddr,u
                    bhi       showbz
                    lbra      showad              back for more
showbj              cmpa      #$3a
                    blo       showbl              num
                    cmpa      #$41
                    blo       showbi              :-@
                    cmpa      #$47
                    blo       showbl              alpha
showbk              bra       showbi              rest
showbl              lbsr      xnhe9               addr
                    asla
                    asla
                    asla
                    asla
                    tfr       a,b
                    lbsr      xnhex
                    pshs      b
                    adda      ,s+
showbq              cmpa      faddr,u             chk addr
                    bcs       showbi
                    cmpa      taddr,u
                    bhi       showbi
                    sta       saddr,u             change addr
                    lbra      showad              back for more
**
* output cursor control string (1-3 chars)
outcur              pshs      b,x                 save b
                    ldb       #$03                set counter
outcr1              lda       ,x+                 get char
                    lbsr      xoutet              output char
                    decb                          dec the count
                    bne       outcr1              loop til done
                    leax      clrscn,pcr          chk clr screen
                    cmpx      $01,s
                    bne       outcr2
                    lda       ,x                  chk for adm-3
                    cmpa      #$1a
                    bne       outcr2
                    lda       #$80                delay
                    lbsr      xoutet
                    lbsr      xoutet
                    lbsr      xoutet
                    lbsr      xoutet
outcr2              leax      toblok,u            force output
                    lbsr      fob
                    puls      b,x,pc              restore and return
**
* find start of cursor control string
cmpcur              pshs      b                   save b-reg
                    leax      clrscn+leadin,pcr   point into table
cmp1                cmpa      ,x                  correct entry?
                    beq       cmp2                yes
                    leax      $03,x               no, bump to next entry
                    bra       cmp1                and try again
cmp2                ldb       #leadin
                    beq       cmp4
cmp3                leax      -$01,x              backup to 1st byte
                    decb
                    bne       cmp3
cmp4                puls      b,pc                restore and return
**
fulscr              lbsr      scstty              full screen edit
fulsc1              clr       horptr,u            reset parameters
                    clr       vrtptr,u
                    leax      harea,u             init screen
                    stx       adrptr,u
                    leax      homeup,pcr
                    bsr       outcur
                    leax      rtcur,pcr
                    bsr       outcur
                    bsr       outcur
                    bsr       outcur
                    bsr       outcur
                    bsr       outcur
                    ldb       #scrwid
                    cmpb      #$04
                    beq       fulsrc
                    leax      dncur,pcr
                    bsr       outcur
fulsrc              leax      curson,pcr          turn on cursor if off
                    lbsr      outcur
fulbel              lda       beeps,pcr           bell
fulout              lbsr      xoutet
fulgnx              clrb                          use b as flag register
fulg1               lbsr      inchrt              get a character
                    sta       cchar,u             save it
                    cmpa      #lead1              is it leadin char #1
                    bne       fulg2               no, see if it's 2nd or 3rd char in sequence
                    incb                          count as first char
                    bra       fulg1               and go get another
fulg2               tstb                          is this the 1st char?
                    beq       fulg4               yes, then it's not an escape sequence
                    cmpa      #lead2              no, then is it 2nd leadin char
                    bne       fulctl              no, then it must bea 2-char control sequence
                    incb                          count as 2nd char
                    bra       fulg1               and go geta 3rd char
fulg4               cmpa      #$80                is it an 8-bit control character?
                    bls       fulg5               no, check for 7-bit control char
                    bra       fulctl              go process
fulg5               cmpa      #$1f                is it a 7-bit control char
                    bls       fulctl              yes, go process
                    lbra      fulnct              no, then process as alpha
fulctl              cmpa      homeup+leadin,pcr   check home
                    beq       fulsc1
fulnhm              cmpa      clrscn+leadin,pcr   check clear
                    beq       fulsc1
fulncl              ldb       vrtptr,u
                    cmpa      upcur+leadin,pcr    check up-cursor
                    bne       fulnup
                    tstb
                    beq       fulbel
                    dec       vrtptr,u
                    ldd       adrptr,u
                    subd      #scrwid
                    std       adrptr,u
                    leax      upcur,pcr           point to cursor string
                    bra       fulecc
fulnup              cmpa      dncur+leadin,pcr    check down-cursor
                    bne       fulndn
                    cmpb      #$0e
                    bhi       fulbeb
                    inc       vrtptr,u
                    ldd       adrptr,u
                    addd      #scrwid
                    std       adrptr,u
                    leax      dncur,pcr           point to string
fulecc              lbsr      outcur
                    bra       fulgnx
fulbeb              bra       fulbel              bell
fulndn              ldb       horptr,u
                    cmpa      lfcur+leadin,pcr    check left-cursor
                    bne       fulnlf
fullf1              tstb
                    beq       fulbeb
                    decb
                    pshs      b
                    stb       horptr,u
                    cmpb      #scrhex
                    bne       fullf3
                    ldd       adrptr,u
                    addd      #scrwid
fullf2              std       adrptr,u
fullf3              puls      b
                    cmpb      #scrhex
                    bhi       fulinx
                    bitb      #$01
                    bne       fulecb
                    lbsr      cmpcur              get start of cursor string to x
                    bra       fulecc
fulecb              lda       cchar,u
                    lbsr      cmpcur              find table entry
                    lbsr      outcur
                    cmpb      #scrhex
                    bne       fulinx
                    lbsr      outcur
fulinx              ldx       adrptr,u
                    lda       cchar,u
                    cmpa      rtcur+leadin,pcr
                    bne       fuldex
                    leax      $01,x
                    bra       fulxix
fuldex              leax      -$01,x
fulxix              stx       adrptr,u
                    lbsr      cmpcur              get start of cursor string to x
fulech              bra       fulecc
fulnlf              cmpa      rtcur+leadin,pcr    check right-cursor
                    bne       fulnrt
fulrt1              cmpb      #scrale
                    bhi       fulbeb
                    pshs      b
                    incb
                    stb       horptr,u
                    cmpb      #scrals
                    bne       fullf3
                    ldd       adrptr,u
                    subd      #scrwid
                    bra       fullf2
fulnrt              cmpa      #$0d
                    beq       fulcre              chk cr
fulbec              lbra      fulbel              bell
fulcre              ldx       saddr,u             chk for changes
                    stx       eaddr,u
                    ldx       #scrbyt
                    stx       savew,u
                    leax      harea,u
                    stx       daddr,u
                    leax      oarea-1,u
                    stx       iaddr,u
fulnxc              ldx       daddr,u
                    lda       ,x+
                    stx       daddr,u
                    ldx       iaddr,u
                    leax      $01,x
                    stx       iaddr,u
                    cmpa      ,x
                    beq       fulnxn
                    ldx       typee,u
                    ldb       #$5a                z
                    stb       ,x+
                    ldy       eaddr,u
                    sty       ,x++                xxxx
                    sty       ,x++                xxxx
                    sta       ,x+                 cc
                    ldd       #$0000
                    std       ,x++
                    stx       typee,u
fulnxn              inc       eaddr+1,u           next byte
                    ldx       savew,u
                    leax      -$01,x
                    stx       savew,u
                    bne       fulnxc
                    leax      toblok,u            force output
                    lbra      fob                 and exit
fulbed              lbra      fulbel              bell
fulnct              ldx       adrptr,u            non-controls
                    anda      #$7f                remove parity
                    ldb       horptr,u
                    cmpb      #scrhex
                    bhi       fulalp
                    cmpa      #$5f
                    bls       fullow
                    anda      #$5f                change case
fullow              suba      #$30                chk hex
                    blo       fulbed
                    cmpa      #$09
                    bls       fulhex
                    cmpa      #$11
                    blo       fulbed
                    cmpa      #$16
                    bgt       fulbed
                    suba      #$07
fulhex              andb      #$01
                    beq       fulhev
                    ldb       ,x
                    andb      #$f0
                    bra       fulhez
fulhev              ldb       ,x
                    andb      #$0f
                    asla
                    asla
                    asla
                    asla
fulhez              pshs      b
                    adda      ,s+
fulalp              sta       ,x                  store char
                    lda       cchar,u
                    lbsr      xoutet              echo it
                    leax      lfcur,pcr           cursor left
                    lbsr      outcur
                    lda       rtcur+leadin,pcr    correct cursor
                    sta       cchar,u
                    ldb       horptr,u
                    lbra      fulrt1
**
inchrt              pshs      x                   input routine
                    leax      toblok,u            force output
                    lbsr      fob
                    leax      tiblok,u            get a char
                    lbsr      gnc
                    bcc       inchr1
                    lda       #$0d                cr if error
inchr1              equ       *
**** delete next line if terminal requires 8 bit ascii
                    anda      #$7f                masks parity
                    puls      x,pc
******************** cssdkdsk ****************************
* this module provides routines which obtain the input
* and output file names from the input device.
                    ttl       *** cssdkdsk ***
                    fcc       "*** cssdkdsk ***"
***************************************
**
diskd               lbsr      xcrlf               input file name
                    leax      disim,pcr
                    lbsr      xpdat
                    leax      locstk,u
                    lbsr      inbufr              get file name
                    cmpa      #$2a                chk for *
                    bne       dikkd
                    tst       os9flx,u            chk for OS/9
                    beq       dikkd
                    tst       disif,u             chk input flag
                    beq       dikkd
                    ldy       nxtmod+1,u          set up seek
                    sty       curmod+1,u
                    ldb       nxtmod,u
                    stb       curmod,u
                    clra
                    tfr       d,x
                    lda       inblok+iobfd+1,u    file desc
                    pshs      u
                    tfr       y,u
                    os9       I$Seek              seek
                    puls      u                   reset stack
                    lbcc      dikib               get next module
                    lda       #$02                error
                    leax      errirz,pcr
                    ldy       #errirl
                    os9       I$WritLn
                    lbra      dikfc               error exit
dikkd               pshs      a
                    clr       defalt,u
                    ldd       #$ffff              reset indices
                    std       curmod,u
                    std       nxtmod,u
                    std       inlrec,u
                    sta       curmod+2,u
                    sta       nxtmod+2,u
                    sta       inlrec+2,u
                    lbsr      maprt
                    puls      a
                    cmpa      #$0d                chk first char in buffer
                    lbeq      dikii               no file name entered
                    tst       disif,u             chk input flag
                    beq       dikia               already open?
                    clr       disif,u             clr input flag
                    lda       inblok+iobfd+1,u
                    os9       I$Close
dikia               leax      locstk,u            copy file name
                    leay      infile,u
dikco               lda       ,x+
                    sta       ,y+
                    bne       dikco
                    leax      infile,u            open input infile
                    lda       #READ.              was #(read.+exec.)=error
                    clrb
                    os9       I$Open
                    bcc       dikok
                    pshs      d,cc
                    os9       F$PErr
                    pshs      x
                    ldx       #$00FF
                    os9       F$Sleep
                    puls      x
                    puls      d,cc                restore it too
dikok               exg       a,b
                    bcc       dikib
                    clr       infile,u            error
                    lda       #$02
                    leax      errirz,pcr
                    ldy       #errirl
                    os9       I$WritLn
                    ldd       #$0000
                    std       inblok+iobfd,u
                    rts
dikib               std       inblok+iobfd,u      file desc
                    ldd       #buflen             buffer length
                    std       inblok+iobbl,u
                    ldd       #$0000
                    std       inblok+iobcc,u
                    ldd       inblok+iobba,u      buffer addr
                    std       inblok+iobca,u
                    ldd       curmod,u            reset log rec ctr
                    std       inlrec,u
                    lda       curmod+2,u
                    sta       inlrec+2,u
dikre               lbsr      mapdk               open, map it
                    bcc       dikti               chk error
dikfc               lbsr      fmsclo              close it and exit
dikie               lbra      stopin              turn off aux input
dikti               lda       #$4b                default type=k
                    sta       defalt,u
                    inc       disif,u
                    ldx       typee,u             set map addr
                    stx       typem,u
dikii               rts
**
dikni               lbsr      xcrlf               output file name
                    clr       disof,u
                    leax      disom,pcr
                    lbsr      xpdat
                    leax      otfile,u
                    lbsr      inbufr              get file name into line buffer
                    cmpa      #$0d                get first char in buffer
                    beq       dikno               no file name was entered
                    ldd       #$0000
                    sta       -$01,y              change cr to null
                    std       otblok+iobfd,u      file desc
                    inc       disof,u
dikno               rts
******************** cssinput ****************************
* this module provides a routine which stores an address
* range and type in a table, a routine which scans and
* verifies such a range, and a routine which obtains an
* entire input line from an input device.
                    ttl       *** cssinput ***
                    fcc       "*** cssinput ***"
***************************************
**
gtype9              tst       os9flx,u            chk for OS/9 rmb/kill
                    bne       badrg
gtype               ldx       typee,u             get type and range
                    cmpx      alimit,u            chk for overflow
                    bhs       tabovf
                    sta       ,x+
                    bsr       gadrs               get range
                    bhi       badrg
                    lda       comand,u            chk for t
                    cmpa      #$54                check for a T
                    beq       gotyx
gotyp               lbsr      xinee               end of line
gotyx               ldx       eaddr,u             update pointer
                    clr       ,x+                 clear map locns
                    clr       ,x+
                    clr       ,x+
                    stx       typee,u
                    rts
**
tablab              lbsr      ende3               terminate disassembly
tabovf              lbsr      xcrlf               table overflow
                    leax      tabov,pcr
                    lbsr      xpdat
                    lbsr      stopin              reset get flag
                    lbsr      xcrlf
                    lbra      askin
**
badrg               lbsr      xcrlf               bad range
                    leax      invrg,pcr
                    lbsr      xpdat
                    lbsr      stopin              reset get flag
                    lbra      xcrlf
**
gadrs               stx       eaddr,u             get addr range
                    leax      lstar,pcr           print start=
                    lbsr      xpdat
                    lbsr      xbadr               read low limit
                    ldx       eaddr,u
                    ldd       baddr,u
                    std       ,x++
                    stx       eaddr,u
                    pshs      d
                    leax      lendr,pcr           print end=
                    lbsr      xpdat
                    lbsr      xbadr               read high limit
                    ldx       eaddr,u
                    ldd       baddr,u
                    std       ,x++
                    stx       eaddr,u
                    puls      d                   chk negative range
                    cmpd      -$02,x
                    rts
**
rdline              bsr       inbufr              get input line
rdlinx              lda       #$04                put eot after input
                    leax      -$01,y
                    sta       ,x
                    stx       raddr,u
                    rts
**
inbufr              tfr       x,y                 input buffer
                    lbsr      inbtty              set tty parameters
                    tfr       y,x
                    ldb       #fnmlen             was $1e
                    bra       inbuf1
inbufd              tfr       x,y                 input command
                    lbsr      inbtty              set tty parameters
                    tfr       y,x
                    ldb       #$fe
inbuf1              lbsr      xinee               drop leading spaces
                    cmpa      #$20
                    beq       inbuf1
                    bra       inbuf5
inbuf3              lbsr      xinee               scan test to cr
inbuf5              cmpa      #$0d
                    beq       inbufx
                    cmpa      #$03                chk for cntrl-c
                    beq       inbuf7
                    cmpa      #$20
                    blo       inbuf3
                    tstb
                    beq       inbuf3
                    sta       ,y+
                    decb
                    bra       inbuf3
inbuf7              tfr       x,y                 reset buffer
inbufx              clr       ,y+                 ending null
                    pshs      x
                    lbsr      inrtty              reset tty parameters
                    puls      x
                    lda       ,x
                    bne       inbufz
                    lda       #$0d                fake a cr
inbufz              rts
******************** csszapcd ****************************
* this module contains routines to assist in the editing
* and decoding an object module; two routines allow the
* inquiry and modification of the object program contents;
* modifications are stored in a table, rather than being
* actually applied to the program; one routine allows the
* locating of strings of hex characters within the object
* program; another routine outputs a OS/9-formatted
* object program from the current object program, possibly
* with user-specified modifications.
                    ttl       *** csszapcd ***
                    fcc       "*** csszapcd ***"
***************************************
**
fillup              lda       #$5a                fill program code
                    ldy       typee,u             save table pointer
                    pshs      y
                    lbsr      gtype               get range
                    puls      y
                    sty       typee,u
                    pshs      x
                    leax      lvalue,pcr          value=
                    lbsr      xpdat
                    lbsr      xbyte
                    sta       [eaddr,u]           store it
                    lbsr      xinee
                    puls      x                   restore pointer
                    stx       typee,u
                    lbhs      tabovf
                    rts
**
writem              ldx       faddr,u             write new program code file
                    leax      $01,x
                    bne       writxf
                    lbsr      newrng              get range
writxf              ldx       xaddr,u             chk xfer addr
                    leax      $01,x
                    bne       writfx
                    lbsr      sxfer               get xfer addr
writfx              lbsr      dikni               get output file name
                    tst       disof,u
                    bne       writgf
                    rts                           return if no file name
writgf              clr       flabl,u             reset flag
                    lbsr      xcrlf
writop              leax      otfile,u            open output otfile
                    ldd       #(WRITE.*256)+(READ.+WRITE.+EXEC.+PEXEC.) access and attributes
                    os9       I$Create
                    lbcs      writer              error
                    clrb
                    exg       a,b
                    std       otblok+iobfd,u      file desc
                    ldd       #buflen             buffer length
                    std       otblok+iobbl,u
                    std       otblok+iobcc,u
                    ldd       otblok+iobba,u      buffer addr
                    std       otblok+iobca,u
                    ldx       faddr,u             set addrs
                    stx       saddr,u
                    tst       disif,u             chk for input file
                    bne       writft
                    ldd       obsize,u            chk for OS/9
                    bne       wrios9              OS/9
writft              tst       os9flx,u            chk for OS/9 format
                    lbeq      writst              flex
wrios9              ldb       #objlth             save header
                    leay      locstk,u
                    leax      objhdr,u
wriuhd              lda       ,x+
                    sta       ,y+
                    decb
                    bne       wriuhd
                    ldd       #$ffff              init crc accum
                    std       crcacc,u
                    sta       crcacc+2,u
                    clrb
                    leay      objhdr,u
wriusa              lda       b,y                 output header
                    leax      otblok,u
                    lbsr      crcalc              crc
                    lbsr      pnc
                    lbcs      writur
                    incb
                    cmpb      #objlth
                    blo       wriusa
                    leax      ltext,pcr           module
                    lbsr      xpdat
                    leax      lstar,pcr           start=
                    lbsr      xpdat
                    ldd       #$0000
                    pshs      d
                    tfr       s,x
                    lbsr      xot4h               xxxx
                    leax      lendr,pcr           end=
                    lbsr      xpdat
                    ldd       obsize,u
                    subd      #$0004
                    std       savew,u
                    leax      savew,u
                    lbsr      xot4h               xxxx
                    lbsr      xcrlf
                    leax      toblok,u
                    lbsr      fob
                    ldd       obstor,u            chk storage length
                    beq       wriusc
                    leax      ldata,pcr           storage
                    lbsr      xpdat
                    leax      lstar,pcr           start=
                    lbsr      xpdat
                    ldd       #$0000
                    std       ,s
                    tfr       s,x
                    lbsr      xot4h               xxxx
                    leax      lendr,pcr           end=
                    lbsr      xpdat
                    ldd       obstor,u
                    subd      #$0001
                    std       ,s
                    tfr       s,x
                    lbsr      xot4h               xxxx
                    lbsr      xcrlf
                    leax      toblok,u
                    lbsr      fob
wriusc              puls      d
                    ldx       #objlth             first program address
                    stx       saddr,u
wriusr              lbsr      getin               get a byte
                    leax      otblok,u
                    lbsr      crcalc              crc
                    lbsr      pnc                 put contiguous bytes
                    lbcs      writur
                    ldx       daddr,u
                    cmpx      savew,u
                    bne       wriusr
                    leax      otblok,u
                    lda       crcacc,u            output crc
                    coma
                    lbsr      pnc
                    lbcs      writur
                    lda       crcacc+1,u          output crc
                    coma
                    lbsr      pnc
                    lbcs      writur
                    lda       crcacc+2,u          output crc
                    coma
                    lbsr      pnc
                    lbcs      writur
                    leax      lxfer+1,pcr         xfer=
                    lbsr      xpdat
                    leax      obxfer,u
                    lbsr      xot4h               xxxx
                    lbsr      xcrlf
                    leax      toblok,u
                    lbsr      fob
                    lbsr      writrh              restore header
                    lbra      writcl
writst              ldx       typee,u             set up flex segment
                    lda       #$02
                    sta       ,x
                    ldd       saddr,u
                    std       $01,x
                    std       savew,u
                    stx       caddr,u
                    clr       worka,u
writgc              ldd       saddr,u             chk addrs
                    cmpd      taddr,u
writca              bhi       writeb              skip if end
                    lbsr      getin               get next byte
                    ldb       insty,u             get type
                    cmpb      #$4b                chk ign
                    beq       writeb
                    cmpb      #$52                chk rmb
                    beq       writeb
                    ldx       caddr,u             store it
                    sta       $04,x
                    leax      $01,x
                    stx       caddr,u
                    lda       worka,u
                    inca
                    sta       worka,u
                    cmpa      #$f8                check number of bytes
                    bne       writgc
writeb              lda       worka,u             write segment
                    beq       writlt
                    leax      lxtnt,pcr           extent start=
                    lbsr      xpdat
                    leax      savew,u
                    lbsr      xot4h               xxxx
                    ldx       saddr,u
                    leax      -$01,x
                    stx       savew,u
                    leax      lendr,pcr           end=
                    lbsr      xpdat
                    leax      savew,u
                    lbsr      xot4h               xxxx
                    lbsr      xcrlf
                    leax      toblok,u
                    lbsr      fob
                    ldx       typee,u
                    lda       worka,u
                    sta       $03,x               set count
                    adda      #$04
                    sta       worka,u
                    stx       caddr,u
writby              ldx       caddr,u             output segment
                    lda       ,x+
                    stx       caddr,u
                    leax      otblok,u            put a bute
                    lbsr      pnc
                    lbcs      writer
                    dec       worka,u
                    bne       writby
                    lda       #$01                set flag
                    sta       flabl,u
writlt              ldd       saddr,u             chk addrs
                    cmpd      taddr,u
writla              bhi       writxa              skip if end
                    lbra      writst
writxa              ldx       xaddr,u             output xfer addr
                    leax      $01,x
                    beq       writcl              skip if $ffff
                    tst       flabl,u
                    beq       writcl              skip if no code
                    leax      lxfer+1,pcr         xfer=
                    lbsr      xpdat
                    leax      xaddr,u             xxxx
                    lbsr      xot4h
                    lbsr      xcrlf
                    ldx       typee,u
                    lda       #$16
                    sta       ,x
                    ldd       xaddr,u
                    std       $01,x
                    lda       #$03
                    sta       worka,u
                    stx       caddr,u
writta              ldx       caddr,u
                    lda       ,x+
                    stx       caddr,u
                    leax      otblok,u            put a byte
                    lbsr      pnc
                    bcs       writer
                    dec       worka,u
                    bne       writta
                    bra       writcl
writrh              ldb       #objlth             restore header
                    leax      locstk,u
                    leay      objhdr,u
writri              lda       ,x+
                    sta       ,y+
                    decb
                    bne       writri
                    rts
writur              bsr       writrh              restore header
writer              lda       #$02                report error
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
writcl              leax      otblok,u            force output
                    lbsr      fob
                    bcc       writcx
                    lda       #$02                report error
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
writcx              lda       otblok+iobfd+1,u    close file
                    os9       I$Close
                    bcc       writex
                    lda       #$02                report error
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
writex              clr       disof,u             reset flag
                    clr       otfile,u
                    rts
**
crcalc              pshs      cc,d,dp,x,y,u       calc OS/9 crc
                    leax      $01,s
                    ldy       #$0001
                    leau      crcacc,u
                    os9       F$CRC
                    rti
**
findst              leax      inam0,u             find hex string
                    lbsr      gadrs
                    lbhi      badrg               bad range
findar              leax      lvalue,pcr          value=
                    lbsr      xpdat
                    clr       worka,u             get pattern
                    leax      inst1,u             point to match area
findhx              lbsr      xinee               get char
                    cmpa      #$5f
                    bls       findxh
                    anda      #$5f                change case
findxh              cmpa      #$2f                check for hex
                    bls       findot
                    cmpa      #$39
                    bls       findin
                    cmpa      #$40
                    bls       findot
                    cmpa      #$46
                    bhi       findot
findin              lbsr      xnhe9
                    asla
                    asla
                    asla
                    asla
                    tfr       a,b
                    lbsr      xnhex
                    pshs      b
                    adda      ,s+
                    sta       ,x+                 save it
                    lda       worka,u
                    inca
                    sta       worka,u
                    cmpa      #$1f
                    bls       findhx
findot              tst       worka,u             got string
                    beq       findxt
findsr              ldx       inam0,u             set up search
                    stx       saddr,u
                    ldx       inam2,u             end addr
                    leax      $01,x
                    bne       findrs
                    leax      -$02,x              fix if $ffff
                    stx       inam2,u
findrs              lbsr      xcrlf
                    lda       #$0b                10 addrs per line
                    sta       flabl,u
                    ldx       typee,u             establish circular buffer
                    stx       baddr,u
                    inc       baddr,u
                    ldx       baddr,u
                    stx       caddr,u
findiz              clr       baddr+1,u           reset addrs
                    clr       caddr+1,u
                    lda       worka,u             load buffer
                    sta       inam5,u
findrd              ldd       saddr,u             chk end addr
                    cmpd      inam2,u
findre              bls       findra
findxt              bra       findex              found end
findra              lbsr      getin               get instr
                    ldb       insty,u             get type
                    cmpb      #$4b                chk ign
                    beq       findiz
                    cmpb      #$52                chk rmb
                    beq       findiz
                    sta       [caddr,u]           save instr
                    inc       caddr+1,u
                    dec       inam5,u
                    bgt       findrd
findoc              ldb       worka,u             set up compare
                    ldx       baddr,u
                    stx       raddr,u
                    leax      inst1,u
findcl              lda       [raddr,u]           compare data
                    cmpa      ,x+
                    bne       findne              skip if no match
                    inc       raddr+1,u
                    decb
                    bne       findcl
findma              dec       flabl,u             print address
                    bne       findnl
                    lbsr      xcrlf               new line
                    lda       #$0a                10 addrs per line
                    sta       flabl,u
findnl              ldb       worka,u             back up addr
                    negb
                    sex
                    ldx       saddr,u
                    leax      d,x
                    stx       inam4,u
                    leax      inam4,u             output addr
                    lbsr      xot4s
                    leax      toblok,u            force output
                    lbsr      fob
findne              inc       baddr+1,u           get next instr
                    clr       inam5,u
                    bra       findrd
findex              rts
**
examin              leax      lstar,pcr           examine/change program code
                    lbsr      xpdat               start=
                    lbsr      xbadr               xxxx
                    stx       saddr,u
examcr              lbsr      xcrlf
                    leax      saddr,u
                    lbsr      xot4s               print addr
                    lbsr      getin               get instr
                    leax      instr,u
                    lbsr      xot2s               print byte
examhx              lbsr      xinee               get char
                    cmpa      #$5f
                    bls       examxh
                    anda      #$5f                change case
examxh              cmpa      #$20                chk space
                    beq       examhx
                    cmpa      #$0d                chk cr
                    bne       examnc
                    rts                           return
examnc              cmpa      #$5e                up arrow
                    bne       examna
                    ldx       saddr,u             back up
                    leax      -$02,x
                    stx       saddr,u
examot              bra       examcr              go back for more
examna              cmpa      #$2f                check for hex
                    bls       examot
                    cmpa      #$39
                    bls       examto
                    cmpa      #$40
                    bls       examot
                    cmpa      #$46
                    bhi       examot
examto              lbsr      xnhe9
                    asla
                    asla
                    asla
                    asla
                    tfr       a,b
                    lbsr      xnhex
                    pshs      b
                    adda      ,s+
                    ldx       typee,u             store in table
                    cmpx      alimit,u            chk for overflow
                    lbhs      tabovf
                    ldb       #$5a                z
                    stb       ,x+
                    ldy       daddr,u             xxxx
                    sty       ,x++
                    sty       ,x++
                    sta       ,x+                 xx
                    ldd       #$0000
                    std       ,x++
                    stx       typee,u
                    bra       examcr              go back for more
******************** cssdisas ****************************
* this module contains routines which disassemble the
* object program; the source of the object program must
* already be known; the destination is determined by these
* routines; actual formatting of the disassembled listing
* and disk output is done by other modules.
                    ttl       *** cssdisas ***
                    fcc       "*** cssdisas ***"
***************************************
**
disas               ldx       faddr,u             disassemble program code
                    leax      $01,x
                    bne       disro
                    lbsr      newrng              get range
disro               lda       #$24                $
                    sta       ulabel,u
                    sta       xlabel,u
                    sta       zlabel,u
                    sta       zulabe,u
                    lda       comand,u            chk view
                    cmpa      #$56                v
                    beq       disvx
                    lda       #$75                u
                    sta       ulabel,u
                    lda       #$7a                z
                    sta       zlabel,u
                    sta       zulabe,u
                    sta       xlabel,u
                    lda       pmode,u             chk for 6809
                    bpl       disxz
                    tst       os9flx,u            chk for OS/9
                    beq       disxz
                    lda       #$78                x
                    sta       xlabel,u
disxz               ldx       xaddr,u             chk xfer addr
                    leax      $01,x
                    bne       disxf
                    lbsr      sxfer               get xfer addr
disxf               lbsr      dikni               get output file name
disvx               lda       #$04                fix nam and opt
                    sta       names+5,u
                    sta       optes+5,u
                    lbsr      xcrlf               get options
                    clr       crtfl,u
                    clr       prnfl,u
                    leax      lenter,pcr          enter p(printer), etc.
                    lbsr      xpdat
                    lbsr      xinee
                    anda      #$5f
                    cmpa      #$42                b
                    beq       disqb
                    cmpa      #$50                p
                    beq       disqp
                    cmpa      #$54                t
                    beq       disqt
                    tst       disof,u             chk disk output
                    beq       disqt               t by default
                    bra       disor
disqb               inc       crtfl,u             both t and p
disqp               inc       prnfl,u             p
                    lbsr      xcrlf
                    leax      prtnm,pcr           get printer file name
                    lbsr      xpdat
                    leax      prfile,u
                    lbsr      inbufr
                    cmpa      #$0d
                    bne       disor
                    clr       prnfl,u             no file name
                    clr       prfile,u
                    bra       disor
disqt               inc       crtfl,u             t
disor               lbsr      xcrlf               get nam and opt
                    tst       disof,u             chk disk output
                    bne       disxn
                    lda       comand,u            chk view
                    cmpa      #$56                v
                    beq       disp0
                    tst       prnfl,u             chk printer
                    beq       disp0
disxn               leax      lnames,u
                    lbsr      xpdat
                    leax      names+5,u
                    lbsr      rdline
                    lbsr      xcrlf
disxo               leax      loptes,u
                    lbsr      xpdat
                    leax      optes+5,u
                    lbsr      rdline
                    lbsr      xcrlf
disp0               ldx       taddr,u             set addrs
                    stx       eaddr,u
                    ldx       typee,u
                    stx       addre,u
                    sts       stkadr,u
                    lbsr      dmptae              print parms
                    tst       disof,u             chk output file
                    beq       dis0b
                    leax      otfile,u            open output otfile
                    ldd       #(WRITE.*256)+(READ.+WRITE.+PREAD.) access and attributes
                    os9       I$Create
                    bcc       dis0a
                    lda       #$02                error
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
                    clr       otfile,u
                    clr       disof,u
                    clr       prfile,u
                    clr       prtfl,u
                    rts                           could not open
dis0a               clrb                          file desc
                    exg       a,b
                    std       otblok+iobfd,u      file desc
                    ldd       #buflen             buffer length
                    std       otblok+iobbl,u
                    std       otblok+iobcc,u
                    ldd       otblok+iobba,u      buffer addr
                    std       otblok+iobca,u
dis0b               tst       prnfl,u             chk printer file
                    beq       disp1
                    leax      prfile,u            open output prfile
                    ldd       #(WRITE.*256)+(READ.+WRITE.+PREAD.) access and attributes
                    os9       I$Create
                    bcc       dis0d
                    lda       #$02                error
                    leax      errprz,pcr
                    ldy       #errprl
                    os9       I$WritLn
                    tst       disof,u             chk output file
                    beq       dis0c
                    lda       otblok+iobfd+1,u
                    clr       otblok+iobfd,u
                    clr       otblok+iobfd+1,u
                    os9       I$Close
                    clr       otfile,u
                    clr       disof,u
dis0c               clr       prfile,u
                    clr       prnfl,u
                    rts                           could not open
dis0d               clrb                          file desc
                    exg       a,b
                    std       prblok+iobfd,u      file desc
                    ldd       #buflen             buffer length
                    std       prblok+iobbl,u
                    std       prblok+iobcc,u
                    ldd       prblok+iobba,u      buffer addr
                    std       prblok+iobca,u
disp1               clr       phase,u             phase 1
                    clr       svcflg,u
                    lbsr      lastty              restore pause option
                    lda       comand,u            chk view
                    cmpa      #$56                v
                    beq       disp2
                    lbsr      reset
                    ldd       faddr,u             label program entry addr
                    lbsr      adal0
                    tst       os9flx,u            chk for OS/9
                    beq       dis1a
                    ldd       #$0000              label program start addr
                    lbsr      adal0
                    ldd       obstor,u            chk for storage
                    beq       dis1a
                    ldd       #$0000              label storage start addr
                    lbsr      adalu
dis1a               bsr       ckend               chk end
                    bhi       dis1b
                    bsr       decod               decode instruction
                    tst       flabl,u             chk label
                    beq       dis1a
                    lbsr      adald               add a label
                    bra       dis1a
dis1b               ldd       xaddr,u             chk xfer addr
                    cmpd      #$ffff
                    beq       disp2
                    lbsr      adal0               enter into label table
disp2               inc       phase,u             phase 2
                    lbsr      reset
                    lbsr      headr               output nam/opt/data/mod
dis2a               bsr       ckend               chk end
                    bhi       disp3
                    bsr       decod               decode instruction
                    lbsr      ckequ               chk equ's
                    lbsr      outpt               print instruction
                    bra       dis2a
disp3               lbra      ender               put out end
**
ckend               ldd       daddr,u             chk for higher than end
                    cmpd      eaddr,u
                    bhi       ckenz
                    ldd       faddr,u             chk for less than start
                    cmpd      daddr,u
ckenz               rts
**
decod               leax      insbeg,u            decode instruction
                    lda       instr,u             remember instr
                    ldb       insty,u             remember type
                    ldy       #(insend-insbeg)
decoe               clr       ,x+                 clear variables
                    leay      -$01,y
                    bne       decoe
                    sta       instr,u             restore instr
                    sta       inst1,u
                    sta       flopc,u
                    stb       insty,u             restore type
                    stb       instx,u
                    leax      inst1,u
                    stx       iaddr,u
                    ldx       saddr,u
                    leax      -$01,x
                    stx       caddr,u             current instruction addr
                    cmpb      #$43                chk fcc
                    bne       pnfcc
                    ldb       #$20                32 byte limit
                    lbra      iafcc
pnfcc               cmpb      #$48                chk fcb
                    bne       pnfcb
                    ldb       #$08                8 byte limit
                    lbra      iafcc
pnfcb               cmpb      #$4b                chk ign
                    lbeq      next2
                    cmpb      #$52                chk rmb
                    lbeq      iafcc
pnins               inc       flisw,u             start saving bytes
                    cmpb      #$41                chk fdb
                    bne       pnfdb
                    lbsr      getin
                    lbra      inpie
pnfdb               tfr       a,b                 compute addr of opcode
                    clra
                    aslb
                    rola
                    addd      aintab,u
                    std       raddr,u
                    tfr       d,x
                    lda       zlabel,u            init label prefix z
                    sta       zulabe,u
insp9               lda       ,x                  get table entry
                    beq       yecc9               chk for invalid optr
                    cmpa      #$ff                chk for page 2/3
                    beq       inspg
                    tfr       a,b
                    lsra
                    anda      #$7e
                    sta       worka,u             optabx pointer
                    andb      #$03
                    tst       pmode,u             chk cpu mode
                    bpl       insx9
                    lda       inst1,u             chk for page 2/3
                    anda      #$fe
                    cmpa      #$10
                    bne       insx9
                    incb
insx9               stb       fllts,u             length
                    lda       $01,x
                    tfr       a,b
                    lsra
                    lsra
                    lsra
                    lsra
                    sta       flsuf,u             suffix
                    tfr       b,a
                    anda      modmsk,u
                    sta       flmod,u             mode
                    tst       pmode,u             chk cpu mode
                    bne       insnv
                    andb      #$08                chk 6801 instruction
                    bne       yecc9
                    bra       insnv
inspg               ldb       $01,x               page 2/3
                    andb      #$08
                    stb       flmod,u
                    lbsr      getin               next instruction
                    sta       flopc,u
                    leax      intpg9,pcr          point to page 2/3 table
                    ldy       #(intpx9-intpg9)
inpal               cmpa      $02,x               look up in page 2/3 table
                    bne       inpar
                    ldb       $01,x               chk page 2/3
                    andb      #$08
                    cmpb      flmod,u             check for proper page
                    bne       inpar
                    bra       insp9               found match
inpar               leax      $03,x
                    leay      -$03,y
                    bne       inpal
yecc9               lbra      yecch               invalid optr
insnv               lbsr      insnm               get instruction name
                    tst       pmode,u             chk for 6809
                    bpl       inpww
                    ldd       inam3,u             chk for swi2
                    cmpd      #$6932              i2
                    bne       inpww
                    tst       os9flx,u            chk for OS/9
                    beq       inpww
                    ldb       #$ff
                    stb       svcflg,u            set svc flag
                    inc       fllts,u             get call number
inpww               ldb       fllts,u             get fixed portion of instruction
                    decb
                    cmpb      fllth,u
                    beq       inpwx
                    lbsr      getin
                    bra       inpww
inpwx               ldx       iaddr,u             point to last instruction byte
                    ldb       ,x
                    stb       flinx,u
                    tst       svcflg,u            check for OS/9 call
                    lbmi      inswi3              handle it
                    lda       flmod,u             chk addr mode
inpn0               cmpa      #$01                chk inh
                    bne       inpn1
                    tst       flspc,u             chk special flag
                    beq       inpwz
                    lda       flopc,u             retrieve op code
                    cmpa      #$20
                    bpl       inpwz               not tfr or exg
                    tfr       b,a
                    anda      #$88                chk reg numbers
                    beq       inpi1
                    cmpa      #$88
                    beq       inpi1
inpyc               lbra      yecch               bad codes
inpi1               tfr       b,a                 chk dest reg
                    anda      #$0f
                    cmpa      #$06
                    bmi       inpi2
                    cmpa      #$08
                    bmi       inpyc
                    cmpa      #$0c
                    bpl       inpyc
inpi2               tfr       b,a                 chk source regs
                    anda      #$f0
                    cmpa      #$60
                    bmi       inpwz
                    cmpa      #$80
                    bmi       inpyc
                    cmpa      #$c0
                    bpl       inpyc
inpwz               lbra      next2               ok, exit
inpn1               cmpa      #$02                chk dir
                    bne       inpn2
                    tst       os9flx,u            chk for OS/9
                    beq       inp1x
                    tst       pmode,u             chk for 6809
                    bpl       inp1x
                    lda       xlabel,u            change to x
                    sta       zulabe,u
inp1x               lbra      dirct
inpn2               cmpa      #$03                chk ext
                    bne       inpn3
inpie               leax      -$01,x              point to addr
                    lda       pmode,u             chk cpu mode
                    cmpa      #$02
                    bne       inpif
                    ldd       ,x                  rev ext addr for 6502
                    exg       a,b
                    bra       inpih
inpif               bpl       inpig               chk for 6809
                    lda       os9flx,u            chk for OS/9
                    beq       inpig
                    lda       xlabel,u            change to x
                    sta       zulabe,u
inpig               ldd       ,x                  get ext addr
inpih               lbra      nextd
inpn3               cmpa      #$04                chk imm
                    bne       inpn4
                    lda       pmode,u             chk cpu mode
                    cmpa      #$05
                    beq       inpq4
                    lda       inam4,u             chk suffix
                    cmpa      #$64                for 'd'
                    blt       inpq4
                    bne       inpie
                    dec       flabl,u
                    bra       inpie
inpq4               tfr       b,a
                    clrb
                    dec       flabl,u
                    lbra      nextd
inpn4               cmpa      #$05                chk inx
                    beq       inpx1
                    lbra      inpn5
inpx1               lda       pmode,u             chk cpu mode
                    bmi       inpx5
                    cmpa      #$05                chk 6805
                    bne       inpxy
                    lbra      dirct               force direct
inpx5               tfr       b,a                 addr mode
                    anda      #$0f
                    sta       flamf,u
                    tfr       b,a                 indir addr
                    anda      #$10
                    sta       flind,u
                    tfr       b,a                 reg
                    anda      #$60
                    lsra
                    lsra
                    lsra
                    lsra
                    sta       flreg,u             reg*2
                    cmpa      #$04                chk for u
                    bne       inpxu
                    tst       os9flx,u            chk for OS/9
                    beq       inpxu
                    ldb       flamf,u             chk addr mode
                    cmpb      #$0c
                    beq       inpxu
                    cmpb      #$0d
                    beq       inpxu
                    ldb       ulabel,u            set label prefix u
                    stb       zulabe,u
inpxu               ldb       ,x                  chk postfix first bit
                    bmi       inpx2
                    tst       os9flx,u            chk for OS/9
                    beq       inpxy
                    andb      #$f0
                    cmpb      #$40                chk for +n,u
                    bne       inpxy
                    ldb       flamf,u             get offset
                    clra
                    lbra      nextd               label it
inpx2               lda       flind,u
                    andb      #$0f                chk amf
                    cmpb      #$07
                    bne       inpx7
inpxg               lbra      yecch               bad amf
inpx7               cmpb      #$0a
                    beq       inpxg
                    cmpb      #$0e
                    beq       inpxg
                    cmpb      #$01
                    beq       inpxy
                    cmpb      #$03
                    bne       inpx3
                    tsta                          chk indir
                    bne       inpxg
inpxy               lbra      next2               ok, exit
inpx3               cmpb      #$0f
                    bne       inpxf
                    tsta                          chk indir
                    beq       inpxg
                    tst       flreg,u             chk register
                    bne       inpxg
inpxf               cmpb      #$08                chk for more bytes
                    bmi       inpxy
                    beq       inpx8
                    cmpb      #$0b
                    beq       inpxy
                    cmpb      #$0c
                    beq       inpx8
                    pshs      b
                    lbsr      getin               need two
                    puls      b
inpx8               pshs      b
                    lbsr      getin               need one or two
                    puls      b
                    cmpb      #$0f
                    lbeq      inpie               ext addr
inpxe               cmpb      #$0c
                    bne       inpxc
                    tfr       a,b                 pc+-8bits
                    lbra      reltv
inpxc               cmpb      #$0d
                    bne       inpxd
                    tfr       a,b                 pc+-16bits
                    lda       ,-x
                    lbra      relad
inpxd               cmpb      #$09
                    bne       inpx9
                    tfr       a,b                 r+-16bits
                    lda       ,-x
                    tst       os9flx,u            chk for OS/9
                    beq       inpxz
                    tst       pmode,u             chk for 6809
                    bpl       inpxz
                    pshs      a
                    lda       flreg,u             chk for u-reg
                    cmpa      #$04
                    puls      a
                    lbeq      nextd               label it
inpxz               dec       flabl,u             don't label it
                    lbra      nextd
inpx9               cmpb      #$08
                    bne       inpxh
                    tfr       a,b                 r+-8bits
                    tst       os9flx,u            chk for OS/9
                    beq       inpxz
                    tst       pmode,u             chk for 6809
                    bpl       inpxz
                    tstb                          chk for positive
                    bmi       inpxz
                    pshs      a
                    lda       flreg,u             chk for u-reg
                    cmpa      #$04
                    puls      a
                    bne       inpxz
                    clra
                    lbra      nextd               label it
inpxh               bra       yecch               bad
inpn5               cmpa      #$06                chk rel
                    beq       relat
                    ldb       pmode,u             chk cpu mode
                    cmpb      #$02
                    bmi       yecch
                    bne       inpn7
                    lda       inst1,u             check for lbra (ind)
                    cmpa      #$6c
                    bne       inpyd               6502 ixi,ini
                    lbra      inpie
inpn7               cmpb      #$05
                    bne       yecch
                    cmpa      #$07                chk ix0
                    beq       next2
                    cmpa      #$08                chk ix2
                    bne       inpn8
                    lbra      inpie
inpn8               cmpa      #$09                chk btb
                    bne       inpn9
                    ldb       inst3,u             comp rel addr
                    sex
inpyr               addd      saddr,u
                    std       zaddr,u             save it
                    lda       comand,u            chk for view only
                    cmpa      #$56                v
                    beq       inpyd
                    tst       phase,u             chk phase
                    bne       inpyd
                    ldd       zaddr,u
                    lbsr      adal0               add label
inpyd               ldb       inst2,u             restore dir addr
                    bra       dirct
inpn9               cmpa      #$0a                chk bsc
                    beq       inpyd
**
yecch               com       instx,u             invalid opcode
yeccc               clr       fllth,u             back pointers up
                    ldx       caddr,u
                    stx       daddr,u
                    leax      $01,x
                    stx       saddr,u
                    bra       next2               make inv optr into fcb
**
dirct               clra                          dir
                    bra       nextd
relat               lda       inam0,u             chk long branch
                    cmpa      #$6c                l
                    bne       reltv
                    ldx       iaddr,u             long branch
                    lda       ,-x
                    bra       relad
reltv               sex                           compute rel addr
relad               addd      saddr,u
nextd               std       raddr,u
nextl               inc       flabl,u             labelled
**
next2               clr       flisw,u             reset instruction save switch
                    lbra      getin               get next instruction
**
insnm               ldd       aoptab,u            get instruction name
                    addb      worka,u
                    adca      #$00
                    tfr       d,x
                    lda       ,x
                    lsra
                    lsra
                    lsra
                    ora       #$60
                    sta       inam1,u
                    ldd       ,x
                    rolb
                    rolb
                    rolb
                    andb      #$03
                    asla
                    asla
                    anda      #$1f
                    ora       #$60
                    pshs      b
                    adda      ,s+
                    sta       inam2,u
                    clrb
                    lda       $01,x
                    lsra
                    rorb
                    stb       flspc,u             special flag
                    anda      #$1f
                    beq       insns
                    ora       #$60
                    sta       inam3,u
insns               ldb       flsuf,u             get suffix
                    aslb
                    clra
                    addd      asuftb,u
                    tfr       d,x
                    ldd       ,x
                    std       inam4,u
                    ldb       pmode,u             chk cpu mode
                    bpl       inpwk
                    cmpa      #$6c                chk 6809 l.branch
                    bne       inpkw
                    clr       inam4,u
                    sta       inam0,u             put l first
                    bra       inpkw
inpwk               cmpb      #$02                chk 6502
                    bne       inpkl
                    sta       inam5,u             fix 6502 suffix
                    suba      #$78                x
                    asla
                    sta       flreg,u
                    lda       #$04
                    sta       inam4,u
                    bra       inpkw
inpkl               cmpb      #$05                chk 6805
                    bne       inpkw
                    lda       inst1,u             fix 6805 instructions
                    cmpa      #$1f
                    bhi       inpkw
                    ldb       #$62                b
                    stb       inam0,u
                    cmpa      #$0f
                    bhi       inpkw
                    ldx       inam2,u
                    stx       inam3,u
                    lda       inam1,u
                    sta       inam2,u
                    lda       #$72                r
                    sta       inam1,u
inpkw               lda       #$04
                    sta       inamx,u
                    rts
**
inswi3              ldb       #(4+(2*2))          handle os9 call
                    mul                           get index into table
                    leax      svctab,pcr
                    leax      d,x
                    clr       flmod,u             remember count
                    stx       flinx,u             remember pointer to name
inswr3              ldd       #$6f73              change swi2 to os9
                    std       inam1,u
                    ldd       #$3904
                    std       inam3,u
                    tst       phase,u             chk phase
                    bne       inswx3
                    ldb       #$0f                fix svc flag
                    stb       svcflg,u
inswx3              lbra      next2               get next instruction
**
reset               ldx       faddr,u             reset addrs
                    tst       os9flx,u            chk for OS/9
                    beq       resos
                    leax      M$Mem+2,x           was m$stak+2,x skip module header
resos               stx       saddr,u
                    stx       daddr,u
                    clr       dorgs,u
                    clr       flisw,u
                    lbsr      xcrlf
                    lda       comand,u            chk view
                    cmpa      #$56                v
                    beq       resex
                    leax      phace,pcr           print phase
                    lbsr      xpdat
                    lda       phase,u
                    adda      #$31
                    lbsr      xoute
resex               leax      toblok,u            force text out
                    lbsr      fob
                    bra       getin
******************** cssgetcd ****************************
* this module contains routines which return the object
* program byte and type at a given address; if the address
* is outside of the specified address range or is in an
* ignored range of addresses, zero is returned.
                    ttl       *** cssgetcd ***
                    fcc       "*** cssgetcd ***"
***************************************
**
getin               pshs      y                   get next instr
                    ldx       #$ffff
                    stx       maddr,u
                    lbsr      getty               get type
                    clra                          clear instr
                    cmpb      #$4b                chk ign
                    lbeq      getjk
                    cmpb      #$52                chk rmb
                    lbeq      getjk
                    ldx       maddr,u             chk for m/z
                    tst       disif,u             chk source
                    bne       getdk
                    cmpx      #$ffff              from memory
                    beq       getmz
                    lda       $05,x               get desired data
                    ldb       ,x                  chk type
                    cmpb      #$5a                for z
                    lbeq      getjk
getmz               ldd       saddr,u             compute addr
                    addd      oaddr,u             offset
                    lbra      getid
getdk               cmpx      #$ffff              from disk
                    lbeq      getjk
                    lda       $05,x               get desired locn/data
                    ldb       ,x                  chk type
                    cmpb      #$5a
                    lbeq      getjk               skip if z
                    ldd       saddr,u             data addr
                    subd      $01,x               start addr
                    addd      $06,x               add extent byte address
                    tfr       a,b
                    lda       $05,x
                    adca      #$00
                    andb      #$fe                truncate to 512 bytes
                    cmpd      inlrec,u            chk curr locn
                    beq       getsl
getss               std       inlrec,u            set curr locn
                    pshs      y,u
                    exg       a,b
                    tfr       d,x
                    clrb                          byte addr=0
                    tfr       d,y
                    tfr       x,d
                    clra
                    tfr       d,x
                    lda       inblok+iobfd+1,u    file desc
                    tfr       y,u
                    os9       I$Seek              seek
                    puls      u,y                 reset stack
                    bcc       getts
geter               lda       #$02                return error
                    leax      errirz,pcr
                    ldy       #errirl
                    os9       I$WritLn
                    lbsr      ende3               close files
                    lbsr      stopin              stop input
                    clr       escswt,u
                    lbra      askin               abort
getts               ldx       inblok+iobba,u      read the block
                    ldy       #buflen
                    lda       inblok+iobfd+1,u
                    os9       I$Read
                    bcs       geter               error
                    cmpy      #$0000
                    bcs       geter               eof
                    ldx       maddr,u             restore map ptr
getsl               ldd       saddr,u             data addr
                    subd      $01,x               start addr
                    addd      $06,x               disk byte address
                    anda      #$01                mask to 512 bytes
                    leax      inbuff,u            input buffer addr
                    pshs      x
                    addd      ,s++
getid               std       maddr,u             disk and memory
                    lda       [maddr,u]
getjk               ldx       saddr,u             update pointers
                    stx       daddr,u
                    leax      $01,x
                    stx       saddr,u
                    sta       instr,u
                    inc       fllth,u             update length
                    tst       flisw,u             save instrs?
                    beq       getxx
                    ldx       iaddr,u
                    leax      $01,x
                    sta       ,x
                    stx       iaddr,u
getxx               puls      y,pc
**
getty               pshs      y                   return memory type
                    ldx       types,u
                    lda       defalt,u            default type
                    sta       insty,u
                    ldd       saddr,u
getnx               cmpx      typee,u
                    beq       gettx
                    cmpd      $01,x
                    beq       getn4
getn1               bls       getix
getn2               cmpd      $03,x
                    beq       getn4
getn3               bhi       getix
getn4               pshs      b                   have table hit
                    ldb       ,x
                    cmpb      #$4d                chk m
                    bne       getn5
                    stx       maddr,u             save table location
                    clrb                          and set type
                    bra       getn9
getn5               cmpb      #$5a                chk z
                    bne       getn9
                    stx       maddr,u             save table location
                    ldb       insty,u             chk type
                    cmpb      #$4b
                    bne       getn9
                    clrb
getn9               stb       insty,u
                    puls      b
getix               leax      $08,x
                    bra       getnx
gettx               ldb       insty,u
                    puls      y,pc
******************** cssiafcb ****************************
* this module contains routines used by the disassembler
* routine to assist in disassembly of the object program;
* one handles case of memory with character and hex types;
* two determine if a given address has been or is to be
* labelled; several routines handle equ and org statements
* as required by object program code and memory types;
* two routines provide logic to handle the beginning and
* ending of the disassembly output.
                    ttl       *** cssiafcb ***
                    fcc       "*** cssiafcb ***"
***************************************
**
iafcc               stb       maxln,u             fcc,fcb,rmb
                    tst       phase,u             chk phase and
                    beq       iafcx               exit if 1
                    leax      inst1,u
                    stx       gaddr,u
iafc0               ldb       instx,u
                    cmpb      #$43                fcc
                    bne       iafc5
                    anda      #$7f                mask off parity bit
                    cmpa      #$1f                control chars
                    bls       iafc2
                    cmpa      #maxprn             max printable
                    bhi       iafc2
                    cmpa      #$22                "
                    bne       iafc8
iafc2               ldb       instx,u
                    leax      inst1,u
                    cmpx      gaddr,u
                    bne       iafc3
                    cmpb      #$43                c
                    bne       iafcx
                    ldb       #$48                fcc->fcb
                    stb       instx,u
iafcx               lbra      next2               get next and return
iafc3               ldx       gaddr,u
                    cmpb      #$43
                    bne       iafc4
                    ldd       #$2204              fcc/fcs "..."
                    std       ,x
iafc4               rts                           return for fcc
iafc5               cmpb      #$52                r
                    bne       iafc8
                    ldd       saddr,u
                    pshs      d
iafc6               lbsr      getin               get next byte
                    ldb       insty,u
                    cmpb      #$52                r
                    bne       iafc7
                    ldy       daddr,u             chk labeled
                    lbsr      adalx
                    bcs       iafc7
                    lbsr      ckend               chk end of program
                    bls       iafc6
iafc7               ldd       saddr,u             end of rmb range
                    subd      ,s++
                    std       rmblth,u            set rmb length
                    rts
iafc8               leax      inst1,u
                    cmpx      gaddr,u
                    beq       iafc9
                    ldy       daddr,u
                    lbsr      adalx               chk label
                    bcs       iafc2
iafc9               ldx       gaddr,u
                    sta       ,x+
                    stx       gaddr,u
                    cmpa      instr,u             check for fcs
                    beq       iafca
                    lda       fccxx+3,u           c->s
                    ora       #$10
                    sta       fccxx+3,u           fcs
                    lbsr      getin
                    lbra      iafc2
iafca               lbsr      getin
                    ldb       fllth,u
                    cmpb      maxln,u
                    lbeq      iafc2
                    ldb       instx,u
                    cmpb      insty,u
                    lbne      iafc2
                    lbra      iafc0
**
adald               ldd       raddr,u             add a data label
adale               pshs      a                   flag as data
                    lda       zulabe,u            prefix u/z
                    sta       lauorz,u
                    puls      a
                    bra       adalv
adalw               ldd       raddr,u             add a data label
adalu               pshs      a                   flag as data
                    lda       ulabel,u            prefix u
                    sta       lauorz,u
                    puls      a
                    bra       adalv
adalb               ldd       raddr,u             add a prog label
adal0               pshs      a                   flag as label
                    lda       zlabel,u            prefix z
                    sta       lauorz,u
                    puls      a
adalv               pshs      d,y
                    tfr       d,y
                    bsr       adall               chk labels
                    bcs       adatx               branch if there
                    lda       lauorz,u
                    ldx       addre,u
                    cmpx      alimit,u            chk for overflow
                    lbhs      tablab
                    sty       ,x++                add to list
                    sta       ,x+
                    stx       addre,u
                    leax      -$03,x              bubble sort
adal1               cmpx      typee,u             back up
                    bls       adatx
                    leax      -$03,x
adal2               ldy       ,x                  compare
                    lda       $02,x
                    cmpy      $03,x
                    bls       adatx
                    pshs      a,y
                    ldy       $03,x               swap
                    lda       $05,x
                    sty       ,x
                    sta       $02,x
                    puls      a,y
                    sty       $03,x
                    sta       $05,x
                    bra       adal1
adatx               puls      d,y,pc
**
adalx               pshs      a                   chk prog labels
                    lda       zlabel,u            prefix z
                    sta       lauorz,u
                    puls      a
                    bra       adall
adaly               pshs      a                   chk data labels
                    lda       ulabel,u            prefix u
                    sta       lauorz,u
                    puls      a
adall               ldx       typee,u             chk labels
                    pshs      d
                    lda       lauorz,u
adalp               cmpx      addre,u
                    bhs       adanf
                    leax      $03,x
                    cmpy      -$03,x
                    bne       adaix
                    cmpa      -$01,x
                    bne       adalp
adafo               orcc      #$01                successful, c=1
                    leax      -$03,x              back up
                    puls      d,pc
adaix               bhi       adalp
adanf               andcc     #$fe                unsuccessful, c=0
                    puls      d,pc
**
ckequ               lda       instx,u             chk org's
                    cmpa      #$4b
                    beq       cktno
                    tst       dorgs,u
                    beq       cktno
                    clr       dorgs,u
ckeqw               tst       os9flx,u            chk for OS/9
                    bne       cktno
                    leax      caddr,u             xxxx
                    lbsr      xot4h
                    leax      orges,pcr           org $
                    lbsr      xpdat
                    leax      caddr,u             xxxx
                    lbsr      xot4h
                    lbsr      xcrlf
cktno               ldx       daddr,u             chk equ's
                    clr       baddr,u
                    dec       fllth,u
                    lda       fllth,u
                    ldb       instx,u
                    cmpb      #$43                c
                    beq       ckeqa
                    cmpb      #$48                h
                    beq       ckeqa
                    cmpb      #$52                r
                    bne       ckeso
ckeqa               ldx       caddr,u
                    clra
ckesx               stx       gaddr,u
                    sta       worka,u
                    ldy       gaddr,u
                    lbsr      adalx
                    bcc       ckenf
                    tst       worka,u             chk offset
                    beq       ckexo
                    leax      gaddr,u             xxxx
                    lbsr      xot4h
                    lda       #$02
                    lbsr      xoute
                    lda       zlabel,u            z
                    lbsr      xoute
                    leax      gaddr,u             xxxx
                    lbsr      xot4h
                    leax      bequb,pcr           equ
                    lbsr      xpdat
                    lbsr      xpdat               *+
                    lda       worka,u             x
                    adda      #$30
                    lbsr      xoute
                    lbsr      xcrlf
ckenf               lda       worka,u
                    beq       ckext
                    ldx       gaddr,u
                    deca
ckeso               leax      -$01,x
                    bra       ckesx
ckexo               ldb       instx,u             chk ign
                    cmpb      #$4b
                    bne       ckexe
                    leax      gaddr,u
                    lda       zlabel,u            prefix z
                    lbra      gnpea               xxxx zxxxx equ $xxxx
ckexe               tst       equfl,u             check equ flag
                    beq       ckexs
                    leax      caddr,u             xxxx
                    lbsr      xot4h
                    lda       #$02
                    lbsr      xoute
                    lda       zlabel,u            z
                    lbsr      xoute
                    leax      caddr,u             xxxx
                    lbsr      xot4h
                    leax      bequb,pcr           equ
                    lbsr      xpdat
                    lda       #$2a                *
                    lbsr      xoute
                    lbsr      xcrlf
                    bra       ckext
ckexs               inc       baddr,u
ckext               lda       instx,u             chk ign
                    cmpa      #$4b                k
                    beq       ckexz
                    leax      caddr,u             xxxx
                    lbsr      xot4h
                    lda       instx,u             chk rmb
                    cmpa      #$52                r
                    beq       ckexy
                    lda       #$01                hex object
                    lbsr      xoute
                    lda       fllth,u
                    inca
                    beq       ckexy
                    cmpa      #$06
                    blo       ckexu
                    lda       #$05
ckexu               sta       worka,u
                    leax      inst1,u
ckexv               lbsr      xot2h
                    dec       worka,u
                    bne       ckexv
ckexy               lda       #$02                label tab
                    lbsr      xoute
                    tst       baddr,u
                    beq       ckexz
                    lda       zlabel,u            z
                    lbsr      xoute
                    leax      caddr,u             xxxx
                    lbsr      xot4h
ckexz               rts
**
headr               lbsr      xcrlf               start program file
                    ldx       crtfl,u
                    stx       confl,u
                    lda       disof,u
                    sta       dskfl,u
                    lda       names+5,u           chk nam
                    cmpa      #$04
                    beq       headc
                    leax      names,u             nam
                    lbsr      xpdat
                    lbsr      xcrlf
headc               lda       optes+5,u           chk opt
                    cmpa      #$04
                    beq       headg
                    leax      optes,u             opt
                    lbsr      xpdat
                    lbsr      xcrlf
headg               clr       column,u
                    tst       os9flx,u            chk for OS/9
                    lbeq      headt
                    lda       comand,u            chk view
                    cmpa      #$56                v
                    lbeq      headt
                    leax      sysdef,pcr          system definitions
                    lbsr      xpdat
                    lda       obatre,u            version
                    lbsr      xothr
                    lbsr      xcrlf
                    ldd       obname,u            module name offset
                    lbsr      adal0
                    leax      lmodul,pcr          mod endmod,namemd,
                    lbsr      xpdat
                    lda       obtyla,u            type and language
                    anda      #$f0
                    lsra
                    leax      ltypes,pcr          type
                    leax      a,x
                    lbsr      xpdat
                    leax      llangs,pcr          +objct,
                    lbsr      xpdat
                    lda       obatre,u            attributes and version
                    bpl       headq
                    leax      lreent,pcr          reent+
                    lbsr      xpdat
headq               leax      lversi,pcr          version,xferad,endmem
                    lbsr      xpdat
                    lbsr      xcrlf
                    ldd       #$0000              xxxx
                    pshs      d
                    tfr       s,x
                    lbsr      xot4h
                    leax      orges,pcr           org $0000 for storage
                    lbsr      xpdat
                    tfr       s,x
                    lbsr      xot4h               xxxx
                    puls      d
                    lbsr      xcrlf
                    lbsr      gendat              generate data rmb's and equ's
headh               leax      lemmod,pcr          module header
                    lbsr      xpdat               endmem
                    lbsr      xpdat               equ .
                    lbsr      xcrlf
                    lda       names+5,u           chk nam
                    cmpa      #$04
                    beq       headn
                    leax      names,u             nam
                    lbsr      xpdat
                    lbsr      xcrlf
headn               ldx       #$ffff              gen absolute equ's
                    stx       caddr,u
                    ldx       #$0000
                    stx       raddr,u
                    lda       xlabel,u            prefiz x
                    sta       zulabe,u
                    lbsr      gnequ
                    ldx       #$000c              gen equ's in header
                    stx       caddr,u
                    ldx       #$0000
                    stx       raddr,u
                    lda       zlabel,u            prefiz z
                    sta       zulabe,u
                    lbsr      gnequ
                    lda       ulabel,u            prefiz u
                    sta       zulabe,u
headt               ldd       curmod,u            reset curr locn
                    std       inlrec,u            zap curr locn
                    lda       curmod+2,u
                    sta       inlrec+2,u
                    ldx       faddr,u             gen out-of-range equ's
                    beq       headx
                    leax      -$01,x
                    stx       caddr,u
                    ldx       #$0000
                    stx       raddr,u
                    lda       zlabel,u            prefiz z
                    sta       zulabe,u
                    lbsr      gnequ
headx               inc       dorgs,u
                    rts
**
gendat              equ       *                   generate data rmb's and equ's
                    lda       ulabel,u            prefix u
                    sta       zulabe,u
                    ldx       obstor,u
                    lbeq      gendeq
                    leax      -$01,x
                    stx       caddr,u
                    ldx       #$0000
                    stx       raddr,u
                    stx       zaddr,u
                    ldx       typee,u             gen data rmb's
genrm1              stx       gaddr,u
                    cmpx      addre,u
                    beq       genrm5
                    bhi       gendeq
                    ldy       $00,x
                    cmpy      raddr,u
                    beq       genrm6
genrm2              blo       genrm4
                    cmpy      caddr,u
genrm3              bls       genrm6
genrm4              leax      $03,x
                    bra       genrm1
genrm5              ldy       obstor,u            force last rmb
                    bra       genrm7
genrm6              lda       zulabe,u            prefix u/z
                    cmpa      $02,x
                    bne       genrm8
genrm7              stx       gaddr,u
                    tfr       y,d
                    subd      zaddr,u             compute rmb offset
                    bls       genrm8              chk for non-positive
                    pshs      d
                    leax      zaddr,u             xxxx
                    lbsr      xot4h
                    lda       #$02
                    lbsr      xoute
                    lda       zulabe,u            prefix u
                    lbsr      xoute
                    leax      zaddr,u             xxxx
                    lbsr      xot4h
                    leax      rmbes,pcr           rmb $
                    lbsr      xpdat
                    tfr       s,x
                    lbsr      xot4h
                    lbsr      xcrlf
                    puls      d
                    sty       zaddr,u             remember current address
genrm8              ldx       gaddr,u             get next label
                    bra       genrm4
gendeq              ldx       obstor,u            gen out-of-range data equ's
                    stx       raddr,u
                    ldx       #$ffff
                    stx       caddr,u
                    lbsr      gnequ
                    rts
**
ender               ldx       daddr,u             end text file
                    beq       ende0               gen out-of-range equ's
                    stx       raddr,u
                    ldx       #$ffff
                    stx       caddr,u
                    lda       zlabel,u            prefix z
                    sta       zulabe,u
                    lbsr      gnequ
ende0               lda       comand,u            chk view
                    cmpa      #$56                v
                    beq       ende3
                    tst       os9flx,u            chk for OS/9
                    beq       ende1
                    leax      endos9,pcr          emod
                    lbsr      xpdat               endmod equ *
                    leax      lnamem,pcr          namemd equ
                    lbsr      xpdat
                    lda       zlabel,u            z
                    lbsr      xoute               z/$
                    leax      obname,u
                    lbsr      xot4h               xxxx
                    lbsr      xcrlf
                    leax      lxfera,pcr          xferad equ
                    lbsr      xpdat
                    lda       zlabel,u            z
                    lbsr      xoute               z/$
                    leax      obxfer,u            xfer offset
                    lbsr      xot4h               xxxx
                    lbsr      xcrlf
ende1               leax      endes,pcr           end
                    lbsr      xpdat
                    tst       os9flx,u            chk for OS/9
                    bne       ende2
                    ldx       xaddr,u             chk xfer addr
                    leax      $01,x
                    beq       ende2
                    lda       zlabel,u            z
                    lbsr      xoute
                    leax      xaddr,u             xxxx
                    lbsr      xot4h
ende2               lbsr      xcrlf
**
ende3               lda       #$01                reset flags and close files
                    sta       confl,u
                    clr       phase,u
                    tst       prtfl,u             chk for printer output
                    beq       endep
                    clr       prtfl,u             close printer file
                    clr       prfile,u
                    leax      prblok,u            force last block
                    lbsr      fob
                    bcc       endpe
                    lda       #$02                error
                    leax      errprz,pcr
                    ldy       #errprl
                    os9       I$WritLn
endpe               lda       prblok+iobfd+1,u    close it
                    clr       prblok+iobfd,u
                    clr       prblok+iobfd+1,u
                    os9       I$Close
                    bcc       endep
                    lda       #$02
                    leax      errprz,pcr
                    ldy       #errprl
                    os9       I$WritLn
endep               tst       dskfl,u             chk for disk output
                    beq       endex
                    clr       disof,u             close output file
                    clr       dskfl,u
                    clr       otfile,u
                    leax      otblok,u            force last block
                    lbsr      fob
                    bcc       endxe
                    lda       #$02                error
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
endxe               lda       otblok+iobfd+1,u    close it
                    clr       otblok+iobfd,u
                    clr       otblok+iobfd+1,u
                    os9       I$Close
                    bcc       endex
                    lda       #$02
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
endex               lbra      xcrlf
**
gnequ               ldx       typee,u             out-of-range equ's
gneq1               stx       gaddr,u
                    cmpx      addre,u
                    beq       gneqx
                    ldd       $00,x
                    cmpd      raddr,u
                    beq       gneq6
gneq2               blo       gneq4
                    cmpd      caddr,u
gneq3               bls       gneq6
gneq4               leax      $03,x
                    bra       gneq1
gneq6               stx       gaddr,u
                    lda       zulabe,u            prefix u/z
                    cmpa      $02,x
                    bne       gneq7
                    bsr       gnpea
gneq7               ldx       gaddr,u
                    bra       gneq4
gneqx               rts
**
gnpea               pshs      a                   gen xxxx zxxxx equ $xxxx
                    stx       baddr,u             xxxx
                    lbsr      xot4h
                    lda       #$02
                    lbsr      xoute
                    puls      a                   label prefix
                    lbsr      xoute
                    ldx       baddr,u             xxxx
                    lbsr      xot4h
                    leax      bequb,pcr           equ
                    lbsr      xpdat
                    lda       #$24                $
                    lbsr      xoute
                    ldx       baddr,u             xxxx
                    lbsr      xot4h
                    lbra      xcrlf
**
******************** cssmapdk ****************************
* this module maps an input object program on disk; the
* program code is not brought into memory from disk except
* one sector at a time; this routine builds the table
* entries to allow the location of any byte of a program
* in terms of relative byte displacement in file.
                    ttl       *** cssmapdk ***
                    fcc       "*** cssmapdk ***"
***************************************
**
mapdk               lbsr      maprt               map flex or OS/9 binary file
                    lbsr      xcrlf
mapnx               leax      inblok,u            look for leadin code
                    lbsr      gnc
                    lbcs      maper
                    lbvs      mapef
                    cmpa      #$02                chk $02
                    lbeq      mapmt
                    cmpa      #$16                chk $16
                    lbeq      mapmt
                    cmpa      #M$ID12/256         chk $87
                    bne       mapnx
map87               leax      inbuff,u            look at buffer
                    ldb       M$ID+1,x            chk second byte of header
                    cmpd      #M$ID12             chk $87cd
                    lbne      mapmt
                    ldy       M$Size,x            chk module length
                    lbeq      mapmt
                    cmpy      M$Name,x            chk name offset > length
                    lblo      mapmt
                    cmpy      M$Exec,x
                    lbls      mapmt               chk xfer > length
                    exg       d,y
                    addd      M$Mem,x
                    exg       d,y
                    lbcs      mapmt               chk prog + data > 64k
                    ldb       M$Type,x
                    andb      #LangMask           was lanmsk chk language
                    cmpb      #Objct
                    lbne      mapmt
                    ldb       ,x+                 chk header parity
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    comb
                    lbne      mapmt
mapun               dec       os9flx,u            OS9 binary file
                    leay      objhdr,u            get OS9 header
                    ldb       #objlth
maphh               sta       ,y+
                    leax      inblok,u            get a char
                    lbsr      gnc
                    lbcs      maper
                    lbvs      mapef
                    decb
                    bne       maphh
                    ldx       obxfer,u            xfer address
                    stx       xaddr,u
                    ldx       typee,u             put module into table
                    lda       #$4d                m
                    sta       ,x
                    ldd       #$0000              module start addr
                    std       $01,x
                    std       faddr,u
                    std       oaddr,u             zero offset addr
                    ldd       obsize,u            module end addr
                    subd      #$0004
                    std       taddr,u
                    std       $03,x               end addr
                    ldd       curmod+1,u          curr module start
                    addd      #$0001
                    std       $06,x
                    lda       curmod,u
                    adca      #$00
                    sta       $05,x
                    pshs      x
                    leax      ltext,pcr           module
                    lbsr      xpdat
                    leax      lstar,pcr           start=
                    lbsr      xpdat
                    puls      x
                    leax      $01,x
                    lbsr      xot4h               xxxx
                    pshs      x
                    leax      lendr,pcr           end=
                    lbsr      xpdat
                    puls      x
                    lbsr      xot4h               xxxx
                    leax      $03,x
                    stx       typee,u
                    lbsr      xcrlf
                    leax      ldata,pcr           storage
                    lbsr      xpdat
                    leax      lstar,pcr           start=
                    lbsr      xpdat
                    ldx       #$0000
                    pshs      x
                    tfr       s,x
                    lbsr      xot4h               xxxx
                    leax      lendr,pcr           end=
                    lbsr      xpdat
                    ldx       obstor,u
                    beq       mapst
                    leax      -$01,x
mapst               stx       ,s
                    tfr       s,x
                    lbsr      xot4h               xxxx
                    puls      x
                    lbsr      xcrlf
                    leax      toblok,u
                    lbsr      fob
                    ldy       obsize,u            length
                    leay      -(objlth+1),y
mapue               leax      inblok,u            scan extent contents
                    lbsr      gnc
                    lbcs      maper
                    lbvs      mapim               eof means short extent
                    leay      -$01,y
                    bne       mapue
                    ldd       inlrec+1,u          disk address of next module
                    std       nxtmod+1,u
                    lda       inlrec,u
                    sta       nxtmod,u
                    lbra      mapef
maprd               leax      inblok,u            look for $02 or $16 - flex
                    lbsr      gnc
                    lbcs      maper
                    lbvs      mapef
                    cmpa      #$02                chk $02
                    beq       mapmt
                    cmpa      #$16                chk $16
                    bne       maprd
mapmt               sta       worka,u             have $02 or $16
                    leax      inblok,u            get hi addr
                    lbsr      gnc
                    lbcs      maper
                    lbvs      mapef
                    sta       baddr,u             hold it
                    leax      inblok,u            get lo addr
                    lbsr      gnc
                    lbcs      maper
                    lbvs      mapef
                    tfr       a,b
                    lda       worka,u             chk for xfer addr
                    cmpa      #$02
                    beq       map02
map16               lda       baddr,u             xfer addr
                    std       xaddr,u
                    bra       maprd
map02               lda       baddr,u             offset addr
                    addd      oaddr,u
                    std       baddr,u
                    leax      inblok,u
                    lbsr      gnc                 get length
                    lbcs      maper
                    lbvs      mapef
                    sta       worka,u
                    leax      inblok,u            get a byte
                    lbsr      gnc
                    lbcs      maper
                    lbvs      mapef
                    ldx       typee,u             put into table
                    lda       #$4d                m
                    sta       ,x                  type
                    ldd       baddr,u             start=end addr in table
                    std       $01,x
                    std       $03,x
                    ldd       inlrec,u            curr locn
                    std       $05,x
                    std       caddr,u
                    lda       inlrec+2,u
                    sta       $07,x
                    ldd       baddr,u             update start addr
mapnb               cmpd      faddr,u
                    bhi       mapff
                    std       faddr,u
mapff               cmpd      taddr,u             update end addr
                    bls       mapgg
                    std       taddr,u
mapgg               dec       worka,u             count data bytes
                    beq       mapmm
                    leax      inblok,u            get a byte
                    lbsr      gnc
                    bcs       maper
                    lbvs      mapim               eof means short extent
                    ldd       baddr,u
                    addd      #$0001
                    std       baddr,u
                    ldx       typee,u             update end addr in table
                    std       $03,x
                    bra       mapnb
mapmm               leax      lxtnt,pcr           extent start=
                    lbsr      xpdat
                    ldx       typee,u
                    leax      $01,x
                    lbsr      xot4h               xxxx
                    pshs      x
                    leax      lendr,pcr           end=
                    lbsr      xpdat
                    puls      x
                    lbsr      xot4h               xxxx
                    leax      $03,x
                    stx       typee,u             complete table entry
                    lbsr      xcrlf
                    leax      toblok,u
                    lbsr      fob
                    ldx       typee,u             chk for table overflow
                    cmpx      alimit,u
                    lblo      maprd
                    lbsr      xcrlf
                    leax      tabov,pcr           table overflow
                    lbsr      xpdat
                    lbsr      xcrlf
                    bra       maprt
maper               lda       #$02                error
                    leax      errirz,pcr
                    ldy       #errirl
                    os9       I$WritLn
maprt               leax      endpr,u             reset table pointers
                    stx       types,u
                    stx       typee,u
                    stx       typem,u
                    ldb       #objos9             clear OS/9 header info
                    leax      objhdr,u
mapri               clr       ,x+
                    decb
                    bne       mapri
                    ldd       #$ffff
                    std       crcacc,u
                    sta       crcacc+2,u
                    std       maddr,u
                    std       xaddr,u
                    std       faddr,u
                    sta       crofl,u
                    addd      #$0001
                    std       taddr,u             reset end addr
                    sta       posfl,u             clear switches
                    sta       equfl,u
                    orcc      #$01                set error flag
mapex               rts
mapef               ldx       typee,u             eof - chk for valid map
                    cmpx      types,u
                    bne       mapok
mapim               leax      badfil,pcr          not a valid binary file
                    lbsr      xpdat
                    bra       maprt
mapok               leax      -$08,x              chk for rmb only
                    cmpx      types,u
                    bne       map0f
                    lda       ,x
                    cmpa      #$52                r
                    beq       mapim
map0f               ldx       faddr,u             check for $0000-$ffff
                    bne       mapko
                    ldx       taddr,u
                    leax      $01,x
                    bne       mapko
                    ldx       #$fff0              change upper bound
                    stx       taddr,u
mapko               lbsr      dmptae              valid map
                    andcc     #$fe                reset error flag
                    rts
******************** cssoutcd ****************************
* this module formats the disassembled output listing and
* disk file; although the listing contains hex address,
* object code, and formatting spaces, only the actual
* disassembled source code is placed on the disk output.
                    ttl       *** cssoutcd ***
                    fcc       "*** cssoutcd ***"
***************************************
**
outpt               lda       instx,u             output instr
                    cmpa      #$4b                chk ign
                    bne       outor
                    sta       dorgs,u             set org flag
                    rts
outor               lda       instx,u             chk type
                    bmi       outfc
                    cmpa      #$48                h
                    bne       outnh
outfc               leax      fcbxx,u             gen fcb stmt
                    lbsr      xpdat
                    leax      inst1,u
                    ldb       fllth,u
outhw               beq       outhx
                    lbsr      xot2h               xx
                    lda       #$2c                ,
                    lbsr      xoute
                    lda       #$24                $
                    lbsr      xoute
                    decb
                    bra       outhw
outhx               lbsr      xot2h               xx
                    tst       instx,u
                    bpl       outhy
                    lbra      outi7
outhy               lbra      xcrlf
outnh               cmpa      #$41
                    bne       outnb
                    leax      fdbxx,u             gen fdb stmt
                    lbsr      xpdat
                    lda       zlabel,u            prefix z
                    tst       pmode,u             chk for 6809
                    bpl       outzx
                    tst       os9flx,u            chk for OS/9
                    beq       outzx
                    lda       xlabel,u            prefix x
outzx               lbsr      xoute               z/x
                    leax      raddr,u
                    lbsr      xot4h               xxxx
                    bra       outhy
outnb               cmpa      #$43                c
                    bne       outna
                    leax      fccxx,u             gen fcc stmt
                    lbsr      xpdat
                    lda       fccxx+3,u           fcs->fcc
                    anda      #$ef
                    sta       fccxx+3,u
                    bra       outhy
outna               cmpa      #$52                r
                    bne       outnr
                    leax      rmbes,pcr           gen rmb stmt
                    lbsr      xpdat
                    leax      rmblth,u            xxxx
                    lbsr      xot4h
                    bra       outhy
outnr               lda       #$03                gen instruction
                    lbsr      xoute
                    tst       posfl,u             chk pos-ind switch
                    beq       outad
                    tst       flabl,u             chk labelled
                    beq       outad
                    lda       pmode,u             chk cpu mode
                    cmpa      #$05
                    beq       outad
                    cmpa      #$02
                    beq       outad
                    ldd       raddr,u             chk addr for within range
                    cmpd      eaddr,u
outab               bhi       outad
                    cmpd      faddr,u
outac               bls       outag
outad               lbra      outgi               not pos-ind
outag               lda       flmod,u             addr mode
                    cmpa      #$02
                    blt       outad
                    cmpa      #$04
                    bgt       outad
                    beq       outaj
outai               inc       flpos,u             set pos-ind flag
                    bra       outad
outaj               ldb       inam4,u             chk suffix
                    cmpb      #$73                for s,u,x,y
                    blt       outad
                    lda       inam1,u             chk name
                    cmpa      #$63                for 'c'
                    beq       outam
                    cmpa      #$6c                for 'l'
                    bne       outad
                    ldx       #$6561              ld? #addr -> lea? addr,pcr
                    stx       inam2,u             (cc affected)
                    bra       outai
outam               cmpb      #$73                chk for suffix 's'
                    beq       outas
                    leax      lposr,pcr           suffix u,x,y
                    bra       outat
outas               leax      lposs,pcr           suffix s
outat               lda       ,x                  gen pos-ind code for imm
                    beq       outaz               null=quit
                    stx       baddr,u             save place
                    cmpa      #$2a                *=reg
                    beq       outau
                    cmpa      #$21                !=zxxxx
                    beq       outav
                    cmpa      #$25                %=crlf
                    beq       outaw
                    cmpa      #$5b                [=$03
                    bne       outan
                    lda       #$03
                    bra       outax
outan               cmpa      #$5d                ]=$05
                    bne       outax
                    lda       #$05
outax               lbsr      xoute               output
outay               ldx       baddr,u             remember place
                    leax      $01,x
                    bra       outat
outau               tfr       b,a                 reg name
                    bra       outax
outav               lda       zulabe,u            z/u
                    lbsr      xoute
                    leax      raddr,u             xxxx
                    lbsr      xot4h
                    bra       outay
outaw               lbsr      xcrlf               crlf
                    bra       outay
outaz               lbra      outi6               exit
outgi               leax      insxx,u             instr name
                    lbsr      xpdat
                    lda       #$05                tab
                    lbsr      xoute
                    tst       svcflg,u            check for OS/9 call
                    bpl       ousw3
                    leax      svcend,pcr          check for table overflow
                    cmpx      flinx,u
                    bhi       ousb3
ousa3               lda       #$24                $ invalid
                    leax      inst3,u             second byte
                    lbsr      xot2h               xx
                    bra       ousd3
ousb3               ldx       flinx,u             point to name table
                    lda       ,x
                    cmpa      #$20                check validity
                    beq       ousa3
                    ldb       #(4+(2*2))
ousc3               lda       ,x+
                    cmpa      #$20
                    bls       ousd3
                    lbsr      xoute
                    decb
                    bne       ousc3
ousd3               lda       svcflg,u            reset flag
                    anda      #$0f
                    sta       svcflg,u
                    lbra      outi6               exit
ousw3               lda       flmod,u             addr mode
                    ldb       flinx,u             instr variant byte
                    cmpa      #$01                chk inh
                    lbne      outb1
outa1               tst       flspc,u             chk special
                    beq       outj1
                    lda       flopc,u             instr
                    cmpa      #$20                chk exg/tfr
                    bpl       outf1
                    pshs      b
                    andb      #$f0                source reg
                    lsrb
                    lsrb
                    lsrb
                    clra
                    pshs      u
                    leau      tfrexc,pcr
                    pshs      u
                    addd      ,s++
                    puls      u
                    tfr       d,x
                    ldx       ,x
                    stx       inam1,u
                    puls      b
                    andb      #$0f                dest reg
                    aslb
                    clra
                    pshs      u
                    leau      tfrexc,pcr
                    pshs      u
                    addd      ,s++
                    puls      u
                    tfr       d,x
                    ldx       ,x
                    stx       inam4,u
                    lda       #$2c                ,
                    sta       inam3,u
                    leax      inam1,u             output source,dest
                    lbsr      xpdat
                    bra       outh1
outj1               lda       pmode,u             chk cpu mode
                    cmpa      #$02
                    bne       outh1               exit if not 6502
                    lda       inst1,u             chk instr
                    anda      #$9f
                    cmpa      #$0a
                    bne       outh1               for $0a,$2a,$4a,$6a
                    lda       #$61                accum instr
                    lbsr      xoute
outh1               lbra      outi6               exit
outf1               cmpa      #$3c                chk cwai
                    bne       outk1
                    clr       inam4,u             fake 8-bit imm
                    stb       raddr,u
                    lbra      outd4
outk1               lda       inam4,u             psh/pul
                    eora      #$06                exg s and u
                    leax      pshpul,u
                    sta       $02,x               fix table
outl1               aslb                          carry=sign bit
                    bcc       outm1
                    stx       raddr,u
                    ldx       ,x
                    stx       inam4,u             reg name
                    leax      inam4,u
                    lbsr      xpdat               output name
                    ldx       raddr,u
                    tstb
                    beq       outx1
                    lda       #$2c                ,
                    lbsr      xoute
outm1               leax      $02,x               chk for more
                    tstb
                    bne       outl1
outx1               lbra      outi6               exit
outb1               cmpa      #$02                chk dir
                    bne       outb2
outa2               tst       flpos,u             chk pos-ind flag
                    bne       outd2
                    lda       #$3c                force dir with <
outc2               ldb       pmode,u             chk cpu mode
                    orb       crofl,u             and x-asmb flag
                    bpl       outd2
                    lbsr      xoute               force mode
outd2               lda       zulabe,u            z/u
                    lbsr      xoute
                    leax      raddr,u             xxxx
                    lbsr      xot4h
                    tst       flpos,u             chk pos-ind flag
                    beq       outx2
                    leax      lcpcr,pcr           ,pcr
                    lbsr      xpdat
                    bra       outz2
outx2               lda       pmode,u             chk cpu mode
                    cmpa      #$02
                    bne       outz2
outw2               ldb       flmod,u             chk mode
                    cmpb      #$08
                    bne       outy2
                    lda       #$29                )
                    lbsr      xoute
outy2               tst       inam5,u             chk x/y
                    beq       outz2
                    lda       #$2c                ,
                    lbsr      xoute
                    lda       inam5,u             x/y
                    lbsr      xoute
                    cmpb      #$07
                    bne       outz2
                    lda       #$29                )
                    lbsr      xoute
outz2               lbra      outi6               exit
outb2               cmpa      #$03                chk ext
                    bne       outb3
                    tst       posfl,u             chk pos-ind switch
                    bne       outd3
                    lda       #$3e                force ext with >
outc3               bra       outc2
outd3               bra       outd2
outb3               cmpa      #$04                chk imm
                    bne       outb4
outa4               tst       flpos,u             chk pos-ind flag
                    bne       outd3
outd4               lda       #$23                #
                    lbsr      xoute
                    ldb       inam4,u             chk suffix
                    cmpb      #$73                for 's'
                    bge       outd3
                    lda       #$24                $
                    lbsr      xoute
                    leax      raddr,u
                    lbsr      xot2h               xx
                    cmpb      #$64                chk for 'd'
                    bne       outf4
                    lbsr      xot2h               xx
outf4               lbra      outi6               exit
outb4               cmpa      #$05                chk inx
                    lbne      outb5
outa5               tst       pmode,u             chk cpu mode
                    bpl       outc5
                    tstb
                    lbmi      outd5               chk inx type
                    andb      #$1f                r+-5bits
                    bitb      #$10                chk neg
                    bne       outg5
                    tst       os9flx,u            chk for OS/9
                    beq       outc5
                    tst       pmode,u             chk for 6809
                    bpl       outc5
                    lda       flreg,u             chk for u-reg
                    cmpa      #$04
                    bne       outc5
                    lda       #$3c                <
                    lbra      oux3v
outg5               lda       #$2d                -
                    lbsr      xoute
                    orb       #$f0
                    negb
                    andb      #$0f
                    bne       outc5               chk $10
                    ldb       #$10
outc5               stb       raddr,u
                    clr       flind,u
                    lda       pmode,u             chk cpu mode
                    cmpa      #$05
                    bne       oupt0
                    tst       crofl,u             chk x-asmb flag
                    beq       outf5
                    lda       #$3c                <
                    lbsr      xoute
outf5               lda       zulabe,u            z/u
                    lbsr      xoute
                    lda       #$30                0
                    lbsr      xoute
                    bra       oupta
oupt0               lda       #$24                $
oupta               lbsr      xoute
                    leax      raddr,u             xx
                    lbsr      xot2h
oupt1               lda       #$2c                ,
                    lbsr      xoute
                    tst       flmin,u             chk auto-decr
                    beq       oupt3
oupt2               lda       #$2d                -
                    lbsr      xoute
                    dec       flmin,u
                    bne       oupt2
oupt3               ldb       flreg,u             reg name
                    clra
                    pshs      u
                    leau      tfrexc,pcr
                    pshs      u
                    addd      ,s++
                    puls      u
                    tfr       d,x
                    ldx       $02,x
                    stx       inam4,u
oupt4               leax      inam4,u
                    lbsr      xpdat               output reg name
                    tst       flpls,u             chk auto-incr
                    beq       oupt6
oupt5               lda       #$2b                +
                    lbsr      xoute
                    dec       flpls,u
                    bne       oupt5
oupt6               tst       flind,u             chk indir
                    beq       oupt9
                    lda       #$5d                ]
                    lbsr      xoute
oupt9               lbra      outi6               exit
outd5               tst       flind,u             chk indir
                    beq       oute5
                    lda       #$5b                [
                    lbsr      xoute
oute5               andb      #$0f                addr mode field
                    bne       oux0z               ,r+
oux0a               inc       flpls,u
                    bra       oupt1
oux0z               cmpb      #$01
                    bne       oux1z               ,r++
oux1a               inc       flpls,u
                    bra       oux0a
oux1z               cmpb      #$02
                    bne       oux2z               ,-r
oux2a               inc       flmin,u
                    bra       oupt1
oux2z               cmpb      #$03
                    bne       oux3z               ,--r
oux3a               inc       flmin,u
                    bra       oux2a
oux3z               cmpb      #$04
                    bne       oux4z               ,r
                    ldx       #$0000
                    stx       raddr,u
                    lda       #$3c                <
oux3u               tst       os9flx,u            chk for OS/9
                    beq       oux3y
                    tst       pmode,u             chk for 6809
                    bpl       oux3y
                    ldb       flreg,u             chk for u-reg
                    cmpb      #$04
                    bne       oux3y
oux3v               tst       crofl,u             chk x-asmb flag
                    beq       oux3x
                    tst       os9flx,u            chk for OS/9
                    beq       oux3x
                    tst       pmode,u             chk for 6809
                    bpl       oux3x
                    ldb       flreg,u             chk for u-reg
                    cmpb      #$04
                    beq       oux3x
                    tst       flind,u             chk for [ and </>
                    bne       oux3x
                    lbsr      xoute               < or >
oux3x               lda       zulabe,u            z/u
                    lbsr      xoute
                    leax      raddr,u
                    lbsr      xot4h               xxxx
oux3y               lbra      oupt1
oux4z               cmpb      #$05
                    bne       oux5z               b,r
oux5a               lda       #$62
oux5b               lbsr      xoute
                    lbra      oupt1
oux5z               cmpb      #$06
                    bne       oux6z               a,r
oux6a               lda       #$61
                    bra       oux5b
oux6z               cmpb      #$08
                    bne       oux8z               r+-8bits
oux8a               tst       raddr,u             chk neg
                    bpl       oux8c
                    lda       #$2d                -
                    lbsr      xoute
                    neg       raddr,u
oux8b               lbra      oupt0
oux8c               tst       os9flx,u            chk for OS/9
                    beq       oux8b
                    tst       pmode,u             chk for 6809
                    bpl       oux8b
                    lda       flreg,u             chk for u-reg
                    cmpa      #$04
                    bne       oux8b
                    lda       #$3c                <
                    bra       oux3v
oux8z               cmpb      #$09
                    bne       oux9z               r+-16bits
oux9c               tst       os9flx,u            chk for os/9
                    beq       oux9a
                    tst       pmode,u             chk for 6809
                    bpl       oux9a
                    lda       flreg,u             chk for u-reg
                    cmpa      #$04
                    bne       oux9a
                    lda       #$3e                >
                    lbra      oux3v
oux9a               lda       #$24                $
oux9b               lbsr      xoute
                    leax      raddr,u             xxxx
                    lbsr      xot4h
                    lbra      oupt1
oux9z               cmpb      #$0b
                    bne       ouxbz               d,r
ouxba               lda       #$64                d
                    bra       oux5b
ouxbz               cmpb      #$0c
                    bne       ouxcz               pcr+-8bits
                    lda       #$3c                <
ouxca               tst       crofl,u             chk x-asmb flag
                    beq       ouxcb
                    tst       posfl,u             chk pos-ind flag
                    bne       ouxcb
                    lbsr      xoute
ouxcb               lda       zulabe,u            z/u
                    lbsr      xoute
                    leax      raddr,u             xxxx
                    lbsr      xot4h
                    leax      lcpcr,pcr           ,pcr
                    lbsr      xpdat
                    lbra      oupt6
ouxcz               cmpb      #$0d
                    bne       ouxdz               pcr+-16bits
                    lda       #$3e                >
                    bra       ouxca
ouxdz               cmpb      #$0f
                    bne       ouxfz               ext ind
ouxfa               lda       zulabe,u            z/u
                    lbsr      xoute
                    leax      raddr,u             xxxx
                    lbsr      xot4h
                    lbra      oupt6
ouxfz               bra       outi6               exit
outb5               cmpa      #$06                chk rel
                    lbeq      outd2
outb6               ldb       pmode,u             chk cpu mode
                    cmpb      #$02
                    bne       outc6
                    lda       #$28                (
                    lbsr      xoute
                    lbra      outd2
outc6               cmpa      #$07                chk ix0
                    lbeq      oupt1
outb7               cmpa      #$08                chk ix2
                    bne       outb8
                    tst       crofl,u             chk x-asmb flag
                    beq       outf7
                    lda       #$3e                >
                    lbsr      xoute
outf7               lda       zulabe,u            z/u
                    lbra      oux9b
outb8               cmpa      #$0b                chk btb,bsc
                    bpl       outi6
                    tfr       a,b
                    lda       flopc,u             get bit number
                    anda      #$0f
                    lsra
                    adda      #$30                add ascii 0
                    lbsr      xoute
                    lda       #$2c                ,
                    lbsr      xoute
                    lda       zulabe,u            z/u
                    lbsr      xoute
                    lda       #$30                00
                    lbsr      xoute
                    lbsr      xoute
                    leax      inst2,u             xx
                    lbsr      xot2h
                    lda       flmod,u             chk mode
                    cmpa      #$0a
                    beq       outi6
                    lda       #$2c                ,
                    lbsr      xoute
                    lda       zulabe,u            z/u
                    lbsr      xoute
                    leax      zaddr,u             xxxx
                    lbsr      xot4h
outi6               lda       instx,u             chk print ascii
                    cmpa      #$4a
                    bne       outi9
outi7               lda       #$06                print characters
                    lbsr      xoute
                    leax      inst1,u
                    ldb       fllth,u
outi8               lda       ,x+                 print printables
                    anda      #$7f
                    cmpa      #$1f
                    bls       pral1
                    cmpa      #maxprn
                    bls       pral2
pral1               lda       #$2e                .
pral2               lbsr      xoute
                    decb
                    bpl       outi8
outi9               lbra      xcrlf
******************** cssxiort ****************************
* this module contains the i/o handlers which interface
* with the primitive OS/9 i/o routines; they are
* necessary in order to control the diversion of input and
* output from and to disk terminal.
                    ttl       *** cssxiort ***
                    fcc       "*** cssxiort ***"
***************************************
**
xbadr               bsr       xbyte               input four hex char into x
                    sta       baddr,u
                    bsr       xbyte
                    sta       baddr+1,u
                    ldx       baddr,u
                    rts
**
xbyte               pshs      b                   input 2 hex char into a
                    lbsr      xnhex
                    asla
                    asla
                    asla
                    asla
                    pshs      a
                    lbsr      xnhex
                    adda      ,s+
                    puls      b,pc
**
xinee               lda       #$01                normal input (getchr)
                    sta       escswt,u
                    sts       saves,u
                    bsr       xinpt
                    clr       escswt,u
                    rts
**
xinpt               pshs      b,x,y               input one char to a
                    tst       getfl,u             chk get flag
                    beq       xinen
xinpg               leax      axblok,u            get a char from disk
                    lbsr      gnc
                    bcs       xinpe               chk error
                    bvs       xineo               chk eof
                    bra       xineg               ok
xinpe               lda       #$02                error
                    leax      errarz,pcr
                    ldy       #errarl
                    os9       I$WritLn
xineo               lbsr      stopin              reset get flag
                    lda       #$0d                cr for eof
xineg               anda      #$7f                strip parity
                    cmpa      #$0d                chk cr
                    beq       xinef
                    cmpa      #$20                chk printable
                    bls       xinpg               ignore cntrl
                    cmpa      #maxprn
                    bhi       xinef
                    lbsr      xoutet              echo input
                    bra       xinef
xinen               leax      toblok,u            from terminal
                    lbsr      fob                 force output
                    leax      tiblok,u
                    lbsr      gnc
                    bcs       xinep               chk error
                    bvs       xineq               chk eof
                    bra       xinek               ok
xinep               lda       #$02                error
                    leax      errirz,pcr
                    ldy       #errirl
                    os9       I$WritLn
                    bra       xineq
xinek               cmpa      #$03                chk ctrl-c
                    bne       xinef
                    tst       scfwkg+PD.EKO-PD.OPT,u chk for screen I/O
                    beq       xinef
                    tst       noecho,u            chk echo flag
                    bne       xinef
                    clr       escswt,u
                    lbra      askin
xineq               clr       escswt,u            abort
                    lbra      fexeof              force exit
xinef               puls      b,x,y,pc            restore and return
**
xnhex               lbsr      xinee               input 1 hex char to a
xnhe9               cmpa      #$5f
                    bls       xnhe8
                    anda      #$5f                change case
xnhe8               cmpa      #$20                chk for space
                    beq       xnhex               ignore
                    suba      #$30
                    blo       xnhe2
                    cmpa      #$09
                    ble       xnhe1
                    cmpa      #$11
                    blo       xnhe2
                    cmpa      #$16
                    bgt       xnhe2
                    suba      #$07
xnhe1               rts
xnhe2               clr       escswt,u            invalid hex
                    lbsr      stopin              reset get flag
                    lbra      askin               get out
**
xpdaa               bsr       xoute
xpdat               lda       ,x+                 print to $04 from x
                    cmpa      #$04
                    bne       xpdaa
                    rts
**
xothl               lsra                          print left hex digit in a
                    lsra
                    lsra
                    lsra
**
xothr               anda      #$0f                print right hex digit in a
                    adda      #$30
                    cmpa      #$39
                    bls       xoth1
                    adda      #$07
xoth1               bra       xoute
**
xot4h               bsr       xot2h               print 4 hex char from x
**
xot2h               lda       ,x                  print 2 hex char from x
                    bsr       xothl
                    lda       ,x+
                    bra       xothr
**
xot4s               bsr       xot2h               print 4 hex from x & space
**
xot2s               bsr       xot2h               print 2 hex from x & space
**
xouts               lda       #$20                print 1 space
**
xoute               pshs      d,x,y               normal output (putchr)
                    ldb       #$02                set escape switch
                    stb       escswt,u
                    sts       saves,u
                    bsr       xoutp
xoutex              clr       escswt,u
                    puls      d,x,y,pc
**
xcrlf               clr       column,u            crlf
                    lda       #$0d                cr
                    bra       xoute
**
xoutp               pshs      d                   output char in a
                    tst       noecho,u            chk echo flag
                    bne       xotpx
                    tsta
                    beq       xotpx               nulls
                    anda      #$7f
                    cmpa      #$20                chk for cntl
                    blo       xotpd
                    inc       column,u            count printables
xotpa               bsr       xouted              output to disk
xotpb               lbsr      xoutep              output to printer
xotpc               lbsr      xoutet              output to terminal
                    bra       xotpx
xotpd               cmpa      #$0d                chk cr
                    bne       xotpe
                    clr       column,u            clear column number
                    bra       xotpa
xotpe               tsta                          chk ctrls
                    beq       xotpb               nulls ($80)
                    cmpa      #$0a                chk lf
                    beq       xotpc
                    cmpa      #$07                chk bell
                    beq       xotpc
                    bpl       xotpx               other cntls
                    ldb       #$05                chk tabs
                    deca
                    beq       xotpt
                    ldb       #$11
                    deca
                    beq       xotpt
                    ldb       #$17
                    deca
                    beq       xotpt
                    ldb       #$21
                    deca
                    beq       xotpt
                    deca
                    beq       xotpt
                    ldb       #$2e
xotpt               lda       #$20                space
xotpu               inc       column,u
                    lbsr      xoutep
                    bsr       xoutet
                    cmpb      column,u
                    bhi       xotpu
                    bsr       xouted
xotpx               puls      d,pc
**
xouted              tst       dskfl,u             output to disk
                    beq       xoutxd
                    pshs      d,x
                    ldb       comand,u
                    cmpb      #$44                chk d
                    bne       xoutdo
                    cmpa      #$0d                cr
                    beq       xoutdo
                    ldb       column,u
                    cmpb      #$12                chk column
                    blo       xoutdx
xoutdo              leax      otblok,u            put a char
                    lbsr      pnc
                    bcc       xoutdx              chk error
                    lda       #$02                error
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
                    clr       dskfl,u             stop disk output
                    ldb       comand,u
                    cmpb      #$44                chk d
                    bne       xoutdx
                    lds       stkadr,u            abort
                    lbra      ende3
xoutdx              puls      d,x
xoutxd              rts
**
xoutet              pshs      d,x                 output to terminal
                    tst       confl,u
                    beq       xoutxt
                    leax      toblok,u            terminal output
                    lbsr      pnc
                    bcc       xouttx
                    lda       #$02                error
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
                    lbsr      ende3               close files
                    lbsr      stopin              stop auxiliary input
                    clr       escswt,u
                    lbra      askin               abort
xouttx              cmpa      scfwkg+PD.EOR-PD.OPT,u cr
                    bne       xoutxt
                    lbsr      fob
xoutxt              puls      d,x,pc
**
xoutep              pshs      d,x                 output to terminal
                    tst       prtfl,u
                    beq       xoutxp
                    leax      prblok,u            printer output
                    lbsr      pnc
                    bcc       xoutpx
                    lda       #$02                error
                    leax      errprz,pcr
                    ldy       #errprl
                    os9       I$WritLn
                    lbsr      ende3               close files
                    lbsr      stopin              stop auxiliary input
                    clr       escswt,u
                    lbra      askin               abort
xoutpx              cmpa      scfwkg+PD.EOR-PD.OPT,u cr
                    bne       xoutxp
                    lbsr      fob                 force output
xoutxp              puls      d,x,pc
**
xcrlr               tst       escswt,u            esc return point
                    bne       xcrrr
xcrlra              leax      xcrlrb,pcr
                    stx       $0a,s
                    clr       escswt,u            reset escape switch
                    rti
xcrlrb              lbsr      fixesc              fix escape
                    lbra      askin               esc from most places
xcrrr               dec       escswt,u
                    bne       xcrr2
                    leax      xcrrra,pcr
                    stx       $0a,s
                    rti
xcrrra              lbsr      fixesc              fix escape
                    lbra      askin               esc from input
xcrr2               dec       escswt,u
                    bne       xcrr3
                    tst       phase,u             check phase
                    beq       xcrr2b
                    clr       confl,u             reset terminal flag
                    leax      xcrr2a,pcr          abort
                    stx       $0a,s
                    rti
xcrr2a              lbsr      fixesc              fix escape
                    lds       stkadr,u            reset stack
                    lbra      ende3               close files
xcrr2b              lbra      xoutex              esc from output
xcrr3               dec       escswt,u
                    bne       xcrlra
                    leax      xcrr3a,pcr          abort
                    stx       $0a,s
                    rti
xcrr3a              lbsr      fixesc              fix escape
                    lds       stkadr,u            reset stack
                    lbra      doscoy              esc from OS/9 call
**
**
*
* blocked i/o routines
*
* gnc - get next char
*
* entry - x=i/o block pointer
*
* exit - cs if error, d=error
*        cc if no error
*        vs if eof
*        if cc and vc, a=char
*
* preserves all other registers
*
gnc                 pshs      b,y
                    ldd       iobcc,x             get remaining char count
                    bne       gnc1                if chars left
gnc0                lda       iobfd+1,x           a=file descriptor
                    ldy       iobbl,x             buffer length
                    ldb       iobfc,x             function code
                    pshs      x
                    ldx       iobba,x             buffer address
                    cmpb      #read
                    beq       gncrw
                    os9       I$ReadLn            reload buffer edited
                    bra       gncrd
gncrw               tsta                          check for terminal read
                    bne       gncrt
                    ldy       #$0001              one byte only
gncrt               os9       I$Read              reload buffer raw
gncrd               puls      x
                    bcs       gnc4                if error
                    sty       iobcc,x             save char count
                    beq       gnc3                if eof
                    ldd       iobba,x             reset char pointer
                    std       iobca,x
                    ldd       iobcc,x             d=char count
gnc1                subd      #$0001              count chars
                    std       iobcc,x
                    leay      inblok,u            chk for macro file
                    pshs      y
                    cmpx      ,s++
                    bne       gnc2
                    ldd       inlrec+1,u          compute relative byte address
                    addd      #$0001
                    std       inlrec+1,u
                    lda       inlrec,u
                    adca      #$00
                    sta       inlrec,u
gnc2                ldy       iobca,x             get char
                    lda       ,y+
                    sty       iobca,x             update char pointer
                    clrb                          cc, vc
                    puls      b,y,pc
gnc3                orcc      #$02                vs for eof
                    puls      b,y,pc
gnc4                cmpb      #E$EOF              check error
                    beq       gnc3                for eof
                    orcc      #$01                cs
                    leas      $01,s               remove b
                    puls      y,pc                cs, d=error
*
* pnc - put next character
*
* entry - a=char,x=i/o block pointer
*
* exit - cc if no error, a=char
*        cs if error, d=error
*
pnc                 pshs      a,b,y
                    ldd       iobcc,x             get remaining count
                    bne       pnc1                if room
                    lda       iobfd+1,x           a=file descriptor
                    ldb       iobfc,x             function code
                    ldy       iobbl,x             buffer length
                    pshs      x
                    ldx       iobba,x             buffer address
                    cmpb      #write
                    beq       pncrw
                    os9       I$WritLn            dump buffer edited
                    bra       pncwt
pncrw               os9       I$Write             dump buffer raw
pncwt               puls      x
                    bcs       pnc3                if error
pnc0                ldd       iobba,x             update char pointer
                    std       iobca,x
                    ldd       iobbl,x             d=new size
pnc1                subd      #$0001              count chars
                    std       iobcc,x             update count
                    ldy       iobca,x             store char
                    puls      a
                    sta       ,y+
                    sty       iobca,x             update char pointer
pnc2                puls      b,y,pc
pnc3                leas      2,s                 remove a and b
                    clra
                    orcc      #$01                cs, error
                    puls      y,pc                cs, d=error
*
* fob - flush output buffer
*
* entry - x=i/o block pointer
*
* exit - cs if error
*
fob                 pshs      d,y
                    ldd       iobbl,x             get buffer size
                    subd      iobcc,x             determine char count
                    beq       fob1                if empty
                    tfr       d,y                 set char count to write
                    lda       iobfd+1,x           a=file descriptor
                    ldb       iobfc,x             function code
                    pshs      x
                    ldx       iobba,x             buffer address
                    cmpb      #write
                    beq       fobrw
                    os9       I$WritLn            dump buffer edited
                    bra       fobwt
fobrw               os9       I$Write             dump buffer raw
fobwt               puls      x
                    bcs       fob2                if error
fob0                ldd       iobba,x             update char pointer
                    std       iobca,x
fob1                ldd       iobbl,x             restore buffer size
                    std       iobcc,x             reset avail counter
                    clra                          clear errors
                    puls      d,y,pc              return
fob2                leas      2,s                 remove a and b
                    clra
                    orcc      #$01                cs, error
                    puls      y,pc                cs, d=error
*
******************** cssconst ****************************
* this module consists of most constants used by the
* disassembler during its processing of object code; it
* also contains text for the menu and the address table
* used by the command interpreter to vector single-letter
* commands to the corresponding routines.
                    ttl       *** cssconst ***
                    fcc       "*** cssconst ***"
***************************************
**
idlin               fcc       "OS/9 Super Sleuth (CC) "
                    fcb       $04
                    fcc       " c1982 by CSC, Conyers GA 30207"
                    fcb       $04
                    fcc       " enter ? for help"
                    fcb       $04,$00
helps               fcc       " operational commands:"
                    fcb       $04
                    fcc       "  d/v-disassemble/view program"
                    fcb       $04
                    fcc       "  f-exit to OS/9"
                    fcb       $04
                    fcc       "  q/m-query/modify object code"
                    fcb       $04
                    fcc       "  t-fill addresses with value"
                    fcb       $04
                    fcc       "  u-enter OS/9 command"
                    fcb       $04
                    fcc       "  w-write new object code path"
                    fcb       $04
                    fcc       "  y-find hex string in code"
                    fcb       $04
                    fcc       " address range commands:"
                    fcb       $04
                    fcc       "  a=fdb,c=fcc,h=fcb,i=instr,"
                    fcc       "j=instr+chr,k=kill,r=rmb"
                    fcb       $04
                    fcc       " mode change commands:"
                    fcb       $04
croil               equ       *+8
                    fcc       "  b-flip x-assembler switch"
                    fcb       $04
equil               equ       *+8
                    fcc       "  e-flip separate-label switch"
                    fcb       $04
posil               equ       *+8
                    fcc       "  p-flip position-ind. switch"
                    fcb       $04
cpuil               equ       *+10
                    fcc       "  z-change cpu mode"
                    fcb       $04
                    fcc       " miscellaneous commands:"
                    fcb       $04
                    fcc       "  g-specify auxiliary i/o path"
                    fcb       $04
                    fcc       "  l-list control information"
                    fcb       $04
                    fcc       "  n-new range or memory module"
                    fcb       $04
offil               equ       *+7
                    fcc       "  o-set offset load value "
                    fcb       $04
disim               equ       *+11
                    fcc       "  s-specify input path "
                    fcb       $07,$04
lxfer               equ       *+7
                    fcc       "  x-set xfer-address "
                    fcb       $07,$04,$00
shotab              fcc       "     "
                    fcc       ".0 .1 .2 .3 .4 .5 .6 .7 "
                    fcb       $04
                    fcc       ".8 .9 .a .b .c .d .e .f "
                    fcb       $04
shota1              fcc       " 01234567"
                    fcb       $04
                    fcc       "89abcdef"
                    fcb       $04
shota2              fcc       "/start/=</end/=>"
                    fcc       "/adr=!/chr=#/hex=(/ins=)/inc=*/kil=+/rmb="
                    fcb       $22
                    fcc       "/scrn/quit/prev/addr/ ?"
                    fcb       $00
loss9               fcc       " OS/9"
                    fcb       $04
lflex               fcc       " Flex"
                    fcb       $04
phace               fcc       " Phase "
                    fcb       $07,$04
disom               fcc       " output path name "
                    fcb       $07,$04
prtnm               fcc       " printer path name "
                    fcb       $07,$04
altnm               fcc       " auxiliary"
                    fcb       $07,$04
lenter              fcc       " enter"
                    fcc       " p(printer), t(terminal),"
                    fcc       " b(both), n(no output) "
                    fcb       $07,$04
lmode               fcc       " 0=6800/2/8,1=6801/3,2=6502,5=[14]6805,9=6809 "
                    fcb       $04
lon                 fcc       " on"
                    fcb       $04
loff                fcc       " off"
                    fcb       $04
ltext               fcc       "module "
                    fcb       $04
ldata               fcc       "storage"
                    fcb       $04
lxtnt               fcc       "extent "
lstar               fcc       " start="
                    fcb       $04
lendr               fcc       " end="
                    fcb       $04
lvalue              fcc       " value="
                    fcb       $04
vshell              fcs       "shell"
badfil              fcc       " bad format!"
                    fcb       $07,$04
tabov               fcc       " table overflow!"
                    fcb       $07,$04
invrg               fcc       " bad range!"
beeps               fcb       $07,$04             bell
errirz              fcc       "error on input path"
errirl              equ       *-errirz+1
                    fcb       $07,$04
errorz              fcc       "error on output path"
errorl              equ       *-errorz+1
                    fcb       $07,$04
errarz              fcc       "error on auxiliary path"
errarl              equ       *-errarz+1
                    fcb       $07,$04
errprz              fcc       "error on printer path"
errprl              equ       *-errprz+1
                    fcb       $07,$04
errexc              fcc       "error in OS/9 call"
errexl              equ       *-errexc+1
                    fcb       $07,$04
bequb               fcb       $03
                    fcc       "equ"
                    fcb       $05,$04
bequa               fcc       "*+"
                    fcb       $04
orges               fcb       $03
                    fcc       "org"
                    fcb       $05,$24,$04         $
rmbes               fcb       $03
                    fcc       "rmb"
                    fcb       $05,$24,$04         $
sysdef              fcb       $03
                    fcc       "ifp1"
                    fcb       $0d,$03
                    fcc       "use"
                    fcb       $05
                    fcc       "/DD/DEFS/"
                    fcc       "defsfile"          level 1.2/2.x
                    fcb       $0d,$03
                    fcc       "endc"
                    fcb       $0d,$03
                    fcc       "ttl Code by CSC OS/9 Super Sleuth3 "
                    fcb       $0d
lverso              fcb       $02
                    fcc       "verson"
                    fcb       $03
                    fcc       "equ"
                    fcb       $05,$24,$30,$04     $0
lnamem              fcb       $02
                    fcc       "namemd"
                    fcb       $03
                    fcc       "equ"
                    fcb       $05,$04
lxfera              fcb       $02
                    fcc       "xferad"
                    fcb       $03
                    fcc       "equ"
                    fcb       $05,$04
lmodul              fcc       "0000"
                    fcb       $03
                    fcc       "mod"
                    fcb       $05
                    fcc       "endmod,namemd,"
                    fcb       $04
llangs              fcc       "+Objct,"
                    fcb       $04
lreent              fcc       "ReEnt+"
                    fcb       $04
lversi              fcc       "verson,xferad,endmem"
                    fcb       $04
lemmod              fcb       $02
                    fcc       "endmem"
                    fcb       $04,$03
                    fcc       "equ"
                    fcb       $05,$2e,$04         .
endos9              fcb       $03
                    fcc       "emod"
                    fcb       $0d,$02
                    fcc       "endmod equ"
                    fcb       $05,$2a,$0d,$04     *
endes               fcb       $03
                    fcc       "end"
                    fcb       $05,$04
lcpcr               fcc       ",pcr"              ,pcr
                    fcb       $04
lposr               fcc       "pshs]*,a,b%"
                    fcc       "[lea*](($ffff-(!))+1),pcr%"
                    fcc       "[tfr]*,d%"
                    fcc       "[addd]2,s%"
                    fcc       "[puls]*,a,b"
                    fcb       $00
lposs               fcc       "pshs]u,a,b%"
                    fcc       "[leau]($fffa-(!)),pcr%"
                    fcc       "[pshs]u%"
                    fcc       "[tfr]s,d%"
                    fcc       "[addd],s++%"
                    fcc       "[puls]u,a,b"
                    fcb       $00
ltypes              fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcc       "Prgrm"
                    fcb       $04,$04,$04
                    fcc       "Sbrtn"
                    fcb       $04,$04,$04
                    fcc       "Multi"
                    fcb       $04,$04,$04
                    fcc       "Data"
                    fcb       $04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcc       "Systm"
                    fcb       $04,$04,$04
                    fcc       "FlMgr"
                    fcb       $04,$04,$04
                    fcc       "Drivr"
                    fcb       $04,$04,$04
                    fcc       "Devic"
                    fcb       $04
**
predef              equ       *
pfcbxx              fcb       $03
                    fcc       "fcb"
                    fcb       $05,$24,$04         $
pfccxx              fcb       $03
                    fcc       "fcc"
                    fcb       $05,$22             "
pinst1              fcb       $00,$00,$00,$00,$00
                    fcc       "                                "
pfdbxx              fcb       $03
                    fcc       "fdb"
                    fcb       $05,$04
pzlabel             fcb       $7a,$04             z
pulabel             fcb       $75,$04             u
pxlabel             fcb       $78,$04             x
plnames             fcc       " title   "
                    fcb       $04
pnames              fcb       $03
                    fcc       "nam"
                    fcb       $05
                    fcc       "                                "
ploptes             fcc       " options "
                    fcb       $04
poptes              fcb       $03
                    fcc       "opt"
                    fcb       $05
                    fcc       "                                "
* pshpul contains 6809 reg names for psh and pul
ppshpu              fcb       $70,$63,$73,$00,$79,$00,$78,$00 pc s  y  x
                    fcb       $64,$70,$62,$00,$61,$00,$63,$63 dp b  a  cc
preend              equ       *
* ifeq h6309-1
* wpshpu cintains 6309 reg name for pshxw and pulxw
*wpshpu
* fcb $77,$00 w
*wpshend equ *
* ldst309 contains reg names for 6309 load store ops
*ldst309 fcb $77,$00,$71,$00,$66,$00,$65,$00 w q f e
*ldstend equ *
* endc
*
** command table for command interpreter
coman               equ       *                   command table
                    fdb       helpme-coman        ?
                    fdb       gtype-coman         a
                    fdb       fcrof-coman         b
                    fdb       gtype-coman         c
                    fdb       disas-coman         d
                    fdb       fequf-coman         e
                    fdb       fexit-coman         f
                    fdb       auxino-coman        g
                    fdb       gtype-coman         h
                    fdb       gtype-coman         i
                    fdb       gtype-coman         j
                    fdb       gtype9-coman        k
                    fdb       dmptab-coman        l
                    fdb       examin-coman        m
                    fdb       newrng-coman        n
                    fdb       oload-coman         o
                    fdb       fposf-coman         p
                    fdb       showaa-coman        q
                    fdb       gtype9-coman        r
                    fdb       diskd-coman         s
                    fdb       fillup-coman        t
                    fdb       doscom-coman        u
                    fdb       disas-coman         v
                    fdb       writem-coman        w
                    fdb       sxfer-coman         x
                    fdb       findst-coman        y
                    fdb       setmod-coman        z
**
******************** cssparam ****************************
* this module must be selected by the user to provide the
* details of the terminal to be used; comments in the
* module provide the required information to be entered.
                    ttl       *** cssparam ***
                    fcc       "*** cssparam ***"
************************************************
**
* lead1 & lead2 should contain the hex ascii
* value of the leadin character(s) of multiple
* character control sequences such as those used
* on heath h-19 or swtpc ct-82 terminals.
* if multiple char. sequences are not required
* set leadin, lead1, & lead2 all to zero.
* if only one leadin char is required, set lead2 to zero.
*
leadin              equ       0                   number of leadin char in control sequence
lead1               equ       $00                 leadin char 1
lead2               equ       $00                 leadin char 2
maxprn              equ       $7e                 max printable char
**
clrscn              fcb       $0c,$00,$00
homeup              fcb       $01,$00,$00
upcur               fcb       $09,$00,$00
dncur               fcb       $0a,$00,$00
lfcur               fcb       $08,$00,$00
rtcur               fcb       $06,$00,$00
curson              fcb       $00,$00,$00
**
******************** csstable ****************************
* this module contains the tables used by the disassembler
* in order to decode the operation codes and to associate
* the mnemonic names with them.
                    ttl       *** csstable ***
                    fcc       "*** csstable ***"
***************************************
**
* optabx represents 680x&6502 opcode names as three
* 5-bit fields packed together and also contains
* a 1-bit flag for special operations.
optab0              equ       *                   6800/1 opcodes
                    fcb       $08,$80,$09,$06,$09,$08,$0b,$88
                    fcb       $0c,$c0,$0c,$d8,$0c,$e4,$10,$c0
                    fcb       $11,$62,$11,$ca,$11,$e8,$12,$00
                    fcb       $12,$68,$13,$00,$13,$0a,$13,$28
                    fcb       $13,$40,$13,$8a,$14,$00,$14,$80
                    fcb       $14,$e4,$15,$80,$18,$80,$1b,$00
                    fcb       $1b,$24,$1b,$60,$1b,$da,$1c,$00
                    fcb       $20,$40,$21,$40,$21,$46,$2b,$e4
                    fcb       $4b,$80,$4b,$86,$53,$60,$54,$e4
                    fcb       $61,$00,$61,$02,$64,$e4,$6d,$40
                    fcb       $71,$4e,$73,$e0,$7c,$82,$84,$d0
                    fcb       $85,$58,$93,$c0,$93,$d8,$93,$e4
                    fcb       $95,$00,$98,$80,$98,$86,$99,$40
                    fcb       $9d,$00,$9d,$02,$9d,$44,$9d,$c0
                    fcb       $a0,$40,$a0,$60,$a0,$80,$a4,$00
                    fcb       $a4,$c0,$a4,$e8,$a6,$00,$b8,$40
optab2              equ       *                   6502 opcodes
                    fcb       $09,$06,$0b,$88,$0c,$d8,$10,$c6
                    fcb       $10,$e6,$11,$62,$12,$68,$13,$52
                    fcb       $13,$8a,$14,$18,$14,$96,$15,$86
                    fcb       $15,$a6,$1b,$06,$1b,$08,$1b,$12
                    fcb       $1b,$2c,$1b,$60,$1c,$30,$1c,$32
                    fcb       $21,$46,$21,$70,$21,$72,$2b,$e4
                    fcb       $4b,$86,$4b,$b0,$4b,$b2,$53,$60
                    fcb       $54,$e4,$61,$02,$61,$30,$61,$32
                    fcb       $64,$e4,$73,$e0,$7c,$82,$82,$02
                    fcb       $82,$20,$83,$02,$83,$20,$93,$d8
                    fcb       $93,$e4,$95,$12,$95,$26,$98,$86
                    fcb       $99,$46,$99,$48,$99,$52,$9d,$02
                    fcb       $9d,$30,$9d,$32,$a0,$70,$a0,$72
                    fcb       $a4,$f0,$a6,$02,$a6,$26,$a6,$42
optab5              equ       *                   [14]6805 opcodes
                    fcb       $09,$06,$09,$08,$0b,$88,$0c,$e4
                    fcb       $10,$c6,$10,$e6,$11,$62,$12,$06
                    fcb       $12,$12,$12,$50,$12,$58,$12,$68
                    fcb       $13,$26,$13,$46,$13,$52,$13,$66
                    fcb       $13,$8a,$14,$18,$14,$82,$14,$9c
                    fcb       $14,$e4,$1b,$06,$1b,$12,$1b,$24
                    fcb       $1b,$60,$1b,$da,$1c,$30,$21,$46
                    fcb       $2b,$e4,$4b,$86,$53,$60,$54,$e4
                    fcb       $61,$02,$61,$30,$64,$d8,$64,$e4
                    fcb       $71,$4e,$73,$e0,$7c,$82,$93,$d8
                    fcb       $93,$e4,$94,$e0,$95,$12,$95,$26
                    fcb       $98,$86,$99,$46,$99,$52,$99,$68
                    fcb       $9d,$02,$9d,$1e,$9d,$30,$9d,$44
                    fcb       $9d,$d2,$a0,$70,$a4,$e8,$a6,$02
                    fcb       $b8,$52
optab9              equ       *                   6809 opcodes
                    fcb       $08,$b0,$09,$06,$09,$08,$0b,$88
                    fcb       $0c,$d8,$0c,$e4,$10,$c6,$10,$e6
                    fcb       $11,$62,$11,$ca,$11,$e8,$12,$12
                    fcb       $12,$68,$13,$0a,$13,$26,$13,$28
                    fcb       $13,$52,$13,$8a,$14,$18,$14,$82
                    fcb       $14,$9c,$14,$e4,$15,$86,$15,$a6
                    fcb       $1b,$24,$1b,$60,$1b,$da,$1d,$c3
                    fcb       $20,$42,$21,$46,$2b,$e4,$2e,$0f
                    fcb       $4b,$86,$53,$60,$54,$e4,$61,$00
                    fcb       $61,$42,$64,$e4,$6d,$58,$71,$4e
                    fcb       $73,$e0,$7c,$80,$84,$d1,$85,$59
                    fcb       $93,$d8,$93,$e4,$95,$12,$95,$26
                    fcb       $98,$86,$99,$70,$9d,$00,$9d,$44
                    fcb       $9d,$d2,$9e,$5c,$a1,$a5,$a4,$e8
* suftax contains 680x suffixes for instr names
suftb5              fcb       $00,$00,$61,$00,$63,$00,$73,$00 nu a  c  s
                    fcb       $70,$00,$74,$00,$78,$00,$79,$00 p  t  x  y
suftb9              fcb       $00,$00,$61,$00,$62,$00,$63,$00 nu a  b  c
                    fcb       $63,$63,$64,$00,$69,$00,$6c,$00 cc d  i  l
                    fcb       $73,$00,$75,$00,$78,$00,$79,$00 s  u  x  y
                    fcb       $4e,$00,$32,$00,$33,$00,$76,$00 n  2  3  v
* tfrexc contains 6809 reg names for tfr and exc
tfrexc              fcb       $64,$00,$78,$00,$79,$00,$75,$00 d  x  y  u
                    fcb       $73,$00,$70,$63,$00,$00,$00,$00 s  pc nu nu
                    fcb       $61,$00,$62,$00,$63,$63,$64,$70 a  b  cc dp
* intab0 represents 6800 instructions
* as 2-byte fields, as followso
* byte 1 bits 0-5: pointer to optab0
*        bits 6-7  length
* byte 2 bits 0-3: suffix
*                  (sp,a,b,cc,d,i,l,s,u,x,y,1,2,3)
*        bit 4:    6801 flag
*        bits 5-7: mode (inh,dir,ext,imm,inx,rel)
intab0              equ       *
                    fcb       $00,$00,$a5,$01,$00,$00,$00,$00 00
                    fcb       $99,$59,$15,$59,$e5,$01,$ed,$11 04
                    fcb       $81,$a1,$75,$a1,$5d,$f1,$cd,$f1 08
                    fcb       $5d,$31,$cd,$31,$5d,$61,$cd,$61 0c
                    fcb       $c5,$11,$59,$11,$00,$00,$00,$00 10
                    fcb       $00,$00,$00,$00,$e1,$21,$e9,$11 14
                    fcb       $00,$00,$71,$11,$00,$00,$01,$11 18
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00 1c
                    fcb       $4e,$16,$4e,$ce,$2e,$66,$36,$86 20
                    fcb       $1e,$36,$1e,$86,$46,$06,$22,$06 24
                    fcb       $56,$36,$56,$86,$4a,$76,$42,$66 28
                    fcb       $26,$06,$3e,$06,$2a,$06,$3a,$06 2c
                    fcb       $f1,$a1,$81,$81,$b1,$11,$b1,$21 30
                    fcb       $75,$81,$f9,$81,$ad,$11,$ad,$21 34
                    fcb       $b1,$a9,$c1,$81,$01,$a9,$c1,$61 38
                    fcb       $ad,$a9,$9d,$79,$fd,$61,$dd,$61 3c
                    fcb       $a1,$11,$00,$00,$00,$00,$69,$11 40
                    fcb       $99,$11,$00,$00,$bd,$11,$19,$11 44
                    fcb       $15,$11,$b9,$11,$79,$11,$00,$00 48
                    fcb       $85,$11,$f5,$11,$00,$00,$61,$11 4c
                    fcb       $a1,$21,$00,$00,$00,$00,$69,$21 50
                    fcb       $99,$21,$00,$00,$bd,$21,$19,$21 54
                    fcb       $15,$21,$b9,$21,$79,$21,$00,$00 58
                    fcb       $85,$21,$f5,$21,$00,$00,$61,$21 5c
                    fcb       $a2,$05,$00,$00,$00,$00,$6a,$05 60
                    fcb       $9a,$05,$00,$00,$be,$05,$1a,$05 64
                    fcb       $12,$75,$b6,$75,$76,$35,$00,$00 68
                    fcb       $82,$35,$f6,$05,$8a,$05,$62,$05 6c
                    fcb       $a3,$03,$00,$00,$00,$00,$6b,$03 70
                    fcb       $9b,$03,$00,$00,$bf,$03,$1b,$03 74
                    fcb       $13,$73,$b7,$73,$77,$33,$00,$00 78
                    fcb       $83,$33,$f7,$03,$8b,$03,$63,$03 7c
                    fcb       $da,$14,$66,$14,$ca,$14,$db,$54 80
                    fcb       $0e,$14,$32,$14,$96,$14,$00,$00 84
                    fcb       $7e,$14,$06,$14,$aa,$14,$0a,$14 88
                    fcb       $6f,$a4,$52,$06,$93,$84,$00,$00 8c
                    fcb       $da,$12,$66,$12,$ca,$12,$da,$5a 90
                    fcb       $0e,$12,$32,$12,$96,$12,$d6,$12 94
                    fcb       $7e,$12,$06,$12,$aa,$12,$0a,$12 98
                    fcb       $6e,$a2,$8e,$0a,$92,$82,$d2,$82 9c
                    fcb       $da,$15,$66,$15,$ca,$15,$da,$5d a0
                    fcb       $0e,$15,$32,$15,$96,$15,$d6,$15 a4
                    fcb       $7e,$15,$06,$15,$aa,$15,$0a,$15 a8
                    fcb       $6e,$a5,$8e,$05,$92,$85,$d2,$85 ac
                    fcb       $db,$13,$67,$13,$cb,$13,$db,$5b b0
                    fcb       $0f,$13,$33,$13,$97,$13,$d7,$13 b4
                    fcb       $7f,$13,$07,$13,$ab,$13,$0b,$13 b8
                    fcb       $6f,$a3,$8f,$03,$93,$83,$d3,$83 bc
                    fcb       $da,$24,$66,$24,$ca,$24,$0b,$5c c0
                    fcb       $0e,$24,$32,$24,$96,$24,$00,$00 c4
                    fcb       $7e,$24,$06,$24,$aa,$24,$0a,$24 c8
                    fcb       $93,$5c,$00,$00,$93,$a4,$00,$00 cc
                    fcb       $da,$22,$66,$22,$ca,$22,$0a,$5a d0
                    fcb       $0e,$22,$32,$22,$96,$22,$d6,$22 d4
                    fcb       $7e,$22,$06,$22,$aa,$22,$0a,$22 d8
                    fcb       $92,$5a,$d2,$5a,$92,$a2,$d2,$a2 dc
                    fcb       $da,$25,$66,$25,$ca,$25,$0a,$5d e0
                    fcb       $0e,$25,$32,$25,$96,$25,$d6,$25 e4
                    fcb       $7e,$25,$06,$25,$aa,$25,$0a,$25 e8
                    fcb       $92,$5d,$d2,$5d,$92,$a5,$d2,$a5 ec
                    fcb       $db,$23,$67,$23,$cb,$23,$0b,$53 f0
                    fcb       $0f,$23,$33,$23,$97,$23,$d7,$23 f4
                    fcb       $7f,$23,$07,$23,$ab,$23,$0b,$23 f8
                    fcb       $93,$5b,$d3,$5b,$93,$a3,$d3,$a3 fc
* intab2 represents 6502 instructions
* as 2-byte fields, as follows:
* byte 1 bits 0-5: pointer to optab2
*        bits 6-7  length
* byte 2 bits 0-3: suffix (sp,a,c,s,p,t,x,y)
*        bits 5-7: mode (inh,dir,ext,imm,
*                        inx,rel,ixi,ini)
intab2              equ       *
                    fcb       $29,$01,$8a,$67,$00,$00,$00,$00 00
                    fcb       $00,$00,$8a,$02,$0a,$02,$00,$00 04
                    fcb       $91,$01,$8a,$04,$09,$01,$00,$00 08
                    fcb       $00,$00,$8b,$03,$0b,$03,$00,$00 0c
                    fcb       $26,$06,$8a,$78,$00,$00,$00,$00 10
                    fcb       $00,$00,$8a,$62,$0a,$62,$00,$00 14
                    fcb       $35,$01,$8b,$73,$00,$00,$00,$00 18
                    fcb       $00,$00,$8b,$63,$0b,$63,$00,$00 1c
                    fcb       $73,$03,$06,$67,$00,$00,$00,$00 20
                    fcb       $1a,$02,$06,$02,$9e,$02,$00,$00 24
                    fcb       $99,$01,$06,$04,$9d,$01,$00,$00 28
                    fcb       $1b,$03,$07,$03,$9f,$03,$00,$00 2c
                    fcb       $1e,$06,$06,$78,$00,$00,$00,$00 30
                    fcb       $00,$00,$06,$62,$9e,$62,$00,$00 34
                    fcb       $b1,$01,$07,$73,$00,$00,$00,$00 38
                    fcb       $00,$00,$07,$63,$9f,$63,$00,$00 3c
                    fcb       $a5,$01,$5e,$67,$00,$00,$00,$00 40
                    fcb       $00,$00,$5e,$02,$82,$02,$00,$00 44
                    fcb       $8d,$01,$5e,$04,$81,$01,$00,$00 48
                    fcb       $6f,$03,$5f,$03,$83,$03,$00,$00 4c
                    fcb       $2e,$06,$5e,$78,$00,$00,$00,$00 50
                    fcb       $00,$00,$5e,$62,$82,$62,$00,$00 54
                    fcb       $3d,$01,$5f,$73,$00,$00,$00,$00 58
                    fcb       $00,$00,$5f,$63,$83,$63,$00,$00 5c
                    fcb       $a9,$01,$02,$67,$00,$00,$00,$00 60
                    fcb       $00,$00,$02,$02,$a2,$02,$00,$00 64
                    fcb       $95,$01,$02,$04,$a1,$01,$00,$00 68
                    fcb       $6f,$08,$03,$03,$a3,$03,$00,$00 6c
                    fcb       $32,$06,$02,$78,$00,$00,$00,$00 70
                    fcb       $00,$00,$02,$62,$a2,$62,$00,$00 74
                    fcb       $b9,$01,$03,$73,$00,$00,$00,$00 78
                    fcb       $00,$00,$03,$63,$a3,$63,$00,$00 7c
                    fcb       $00,$00,$be,$67,$00,$00,$00,$00 80
                    fcb       $c6,$02,$be,$02,$c2,$02,$00,$00 84
                    fcb       $59,$01,$00,$00,$d5,$01,$00,$00 88
                    fcb       $c7,$03,$bf,$03,$c3,$03,$00,$00 8c
                    fcb       $0e,$06,$be,$78,$00,$00,$00,$00 90
                    fcb       $c6,$62,$be,$62,$c2,$72,$00,$00 94
                    fcb       $dd,$01,$bf,$73,$d9,$01,$00,$00 98
                    fcb       $00,$00,$bf,$63,$00,$00,$00,$00 9c
                    fcb       $7e,$04,$76,$67,$7a,$04,$00,$00 a0
                    fcb       $7e,$02,$76,$02,$7a,$02,$00,$00 a4
                    fcb       $cd,$01,$76,$04,$c9,$01,$00,$00 a8
                    fcb       $7f,$03,$77,$03,$7b,$03,$00,$00 ac
                    fcb       $12,$06,$76,$78,$00,$00,$00,$00 b0
                    fcb       $7e,$62,$76,$62,$7a,$72,$00,$00 b4
                    fcb       $41,$01,$77,$73,$d1,$01,$00,$00 b8
                    fcb       $7f,$63,$77,$63,$7b,$73,$00,$00 bc
                    fcb       $4e,$04,$46,$67,$00,$00,$00,$00 c0
                    fcb       $4e,$02,$46,$02,$52,$02,$00,$00 c4
                    fcb       $69,$01,$46,$04,$55,$01,$00,$00 c8
                    fcb       $4f,$03,$47,$03,$53,$03,$00,$00 cc
                    fcb       $22,$06,$46,$78,$00,$00,$00,$00 d0
                    fcb       $00,$00,$46,$62,$52,$62,$00,$00 d4
                    fcb       $39,$01,$47,$73,$00,$00,$00,$00 d8
                    fcb       $00,$00,$47,$63,$53,$63,$00,$00 dc
                    fcb       $4a,$04,$ae,$67,$00,$00,$00,$00 e0
                    fcb       $4a,$02,$ae,$02,$62,$02,$00,$00 e4
                    fcb       $65,$01,$ae,$04,$85,$01,$00,$00 e8
                    fcb       $4b,$03,$af,$03,$63,$03,$00,$00 ec
                    fcb       $16,$06,$ae,$78,$00,$00,$00,$00 f0
                    fcb       $00,$00,$ae,$62,$62,$62,$00,$00 f4
                    fcb       $b5,$01,$af,$73,$00,$00,$00,$00 f8
                    fcb       $00,$00,$af,$63,$63,$63,$00,$00 fc
* intab5 represents [14]6805 instructions
* as 2-byte fields, as follows:
* byte 1 bits 0-5: pointer to optab5
*        bits 6-7  length
* byte 2 bits 0-3: suffix (sp,a,c,s,p,t,x,y)
*        bits 4-7: mode (inh,dir,ext,imm,ixi,
*                        rel,ix0,ix2,btb,bsc)
intab5              equ       *
                    fcb       $bf,$09,$5f,$09,$bf,$09,$5f,$09 00
                    fcb       $bf,$09,$5f,$09,$bf,$09,$5f,$09 04
                    fcb       $bf,$09,$5f,$09,$bf,$09,$5f,$09 08
                    fcb       $bf,$09,$5f,$09,$bf,$09,$5f,$09 0c
                    fcb       $be,$0a,$5e,$0a,$be,$0a,$5e,$0a 10
                    fcb       $be,$0a,$5e,$0a,$be,$0a,$5e,$0a 14
                    fcb       $be,$0a,$5e,$0a,$be,$0a,$5e,$0a 18
                    fcb       $be,$0a,$5e,$0a,$be,$0a,$5e,$0a 1c
                    fcb       $4a,$06,$4e,$06,$22,$06,$32,$06 20
                    fcb       $12,$06,$16,$06,$42,$06,$1a,$06 24
                    fcb       $1e,$26,$1e,$36,$46,$06,$3a,$06 28
                    fcb       $36,$06,$3e,$06,$2a,$06,$26,$06 2c
                    fcb       $92,$02,$00,$00,$00,$00,$66,$02 30
                    fcb       $8e,$02,$00,$00,$a2,$02,$0e,$02 34
                    fcb       $8a,$02,$9e,$02,$6e,$02,$00,$00 38
                    fcb       $76,$02,$da,$02,$00,$00,$5e,$02 3c
                    fcb       $91,$11,$00,$00,$00,$00,$65,$11 40
                    fcb       $8d,$11,$00,$00,$a1,$11,$0d,$11 44
                    fcb       $89,$11,$9d,$11,$6d,$11,$00,$00 48
                    fcb       $75,$11,$d9,$11,$00,$00,$5d,$11 4c
                    fcb       $91,$61,$00,$00,$00,$00,$65,$61 50
                    fcb       $8d,$61,$00,$00,$a1,$61,$0d,$61 54
                    fcb       $89,$61,$9d,$61,$6d,$61,$00,$00 58
                    fcb       $75,$61,$d9,$61,$00,$00,$5d,$61 5c
                    fcb       $92,$05,$00,$00,$00,$00,$66,$05 60
                    fcb       $8e,$05,$00,$00,$a2,$05,$0e,$05 64
                    fcb       $8a,$05,$9e,$05,$6e,$05,$00,$00 68
                    fcb       $76,$05,$da,$05,$00,$00,$5e,$05 6c
                    fcb       $91,$07,$00,$00,$00,$00,$65,$07 70
                    fcb       $8d,$07,$00,$00,$a1,$07,$0d,$07 74
                    fcb       $89,$07,$9d,$07,$6d,$07,$00,$00 78
                    fcb       $75,$07,$d9,$07,$00,$00,$5d,$07 7c
                    fcb       $a9,$01,$ad,$01,$00,$00,$d1,$01 80
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00 84
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00 88
                    fcb       $00,$00,$00,$00,$c5,$41,$e1,$51 8c
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00 90
                    fcb       $00,$00,$00,$00,$00,$00,$d5,$01 94
                    fcb       $55,$01,$b5,$01,$59,$01,$b9,$01 98
                    fcb       $a5,$01,$95,$01,$00,$00,$dd,$01 9c
                    fcb       $ce,$04,$62,$04,$b2,$04,$6a,$04 a0
                    fcb       $0a,$04,$2e,$04,$82,$04,$00,$00 a4
                    fcb       $72,$04,$02,$04,$9a,$04,$06,$04 a8
                    fcb       $00,$00,$52,$06,$86,$04,$00,$00 ac
                    fcb       $ce,$02,$62,$02,$b2,$02,$6a,$02 b0
                    fcb       $0a,$02,$2e,$02,$82,$02,$c2,$02 b4
                    fcb       $72,$02,$02,$02,$9a,$02,$06,$02 b8
                    fcb       $7a,$02,$7e,$02,$86,$02,$ca,$02 bc
                    fcb       $cf,$03,$63,$03,$b3,$03,$6b,$03 c0
                    fcb       $0b,$03,$2f,$03,$83,$03,$c3,$03 c4
                    fcb       $73,$03,$03,$03,$9b,$03,$07,$03 c8
                    fcb       $7b,$03,$7f,$03,$87,$03,$cb,$03 cc
                    fcb       $cf,$08,$63,$08,$b3,$08,$6b,$08 d0
                    fcb       $0b,$08,$2f,$08,$83,$08,$c3,$08 d4
                    fcb       $73,$08,$03,$08,$9b,$08,$07,$08 d8
                    fcb       $7b,$08,$7f,$08,$87,$08,$cb,$08 dc
                    fcb       $ce,$05,$62,$05,$b2,$05,$6a,$05 e0
                    fcb       $0a,$05,$2e,$05,$82,$05,$c2,$05 e4
                    fcb       $72,$05,$02,$05,$9a,$05,$06,$05 e8
                    fcb       $7a,$05,$7e,$05,$86,$05,$ca,$05 ec
                    fcb       $cd,$07,$61,$07,$b1,$07,$69,$07 f0
                    fcb       $09,$07,$2d,$07,$81,$07,$c1,$07 f4
                    fcb       $71,$07,$01,$07,$99,$07,$05,$07 f8
                    fcb       $79,$07,$7d,$07,$85,$07,$c9,$07 fc
* intab9 represents 6809 instructions
* as 2- or 3-byte fields, as follows:
* byte 1 bits 0-5: pointer to optab9
*        bits 6-7  length (-1 for page 2/3)
* byte 2 bits 0-3: suffix
*                  (sp,a,b,cc,d,i,l,s,u,x,y,1,2,3)
*        bit 4:    page-3 flag
*        bits 5-7: mode (inh,dir,ext,imm,inx,rel)
* byte 3 bits 0-7: opcode (page 2/3 only)
intab9              equ       *
                    fcb       $9e,$02,$00,$00,$00,$00,$6a,$02 00
                    fcb       $96,$02,$00,$00,$b6,$02,$16,$02 04
                    fcb       $12,$02,$b2,$02,$76,$02,$00,$00 08
                    fcb       $82,$02,$de,$02,$86,$02,$62,$02 0c
                    fcb       $ff,$00,$ff,$08,$a1,$01,$d5,$31 10
                    fcb       $00,$00,$00,$00,$4f,$76,$57,$76 14
                    fcb       $00,$00,$71,$01,$a6,$44,$00,$00 18
                    fcb       $0e,$44,$c5,$01,$7e,$01,$da,$01 1c
                    fcb       $4e,$06,$52,$06,$2e,$06,$3a,$06 20
                    fcb       $1a,$06,$1e,$06,$46,$06,$22,$06 24
                    fcb       $5a,$06,$5e,$06,$4a,$06,$42,$06 28
                    fcb       $26,$06,$3e,$06,$2a,$06,$36,$06 2c
                    fcb       $92,$a5,$92,$b5,$92,$85,$92,$95 30
                    fcb       $aa,$81,$ae,$81,$aa,$91,$ae,$91 34
                    fcb       $00,$00,$bd,$01,$01,$01,$b9,$01 38
                    fcb       $6e,$61,$99,$01,$00,$00,$d1,$01 3c
                    fcb       $9d,$11,$00,$00,$00,$00,$69,$11 40
                    fcb       $95,$11,$00,$00,$b5,$11,$15,$11 44
                    fcb       $11,$11,$b1,$11,$75,$11,$00,$00 48
                    fcb       $81,$11,$dd,$11,$00,$00,$61,$11 4c
                    fcb       $9d,$21,$00,$00,$00,$00,$69,$21 50
                    fcb       $95,$21,$00,$00,$b5,$21,$15,$21 54
                    fcb       $11,$21,$b1,$21,$75,$21,$00,$00 58
                    fcb       $81,$21,$dd,$21,$00,$00,$61,$21 5c
                    fcb       $9e,$05,$00,$00,$00,$00,$6a,$05 60
                    fcb       $96,$05,$00,$00,$b6,$05,$16,$05 64
                    fcb       $12,$05,$b2,$05,$76,$05,$00,$00 68
                    fcb       $82,$05,$de,$05,$86,$05,$62,$05 6c
                    fcb       $9f,$03,$00,$00,$00,$00,$6b,$03 70
                    fcb       $97,$03,$00,$00,$b7,$03,$17,$03 74
                    fcb       $13,$03,$b3,$03,$77,$03,$00,$00 78
                    fcb       $83,$03,$df,$03,$87,$03,$63,$03 7c
                    fcb       $ce,$14,$66,$14,$c2,$14,$cf,$54 80
                    fcb       $0e,$14,$32,$14,$8e,$14,$00,$00 84
                    fcb       $7a,$14,$06,$14,$a6,$14,$0a,$14 88
                    fcb       $67,$a4,$56,$06,$8f,$a4,$00,$00 8c
                    fcb       $ce,$12,$66,$12,$c2,$12,$ce,$52 90
                    fcb       $0e,$12,$32,$12,$8e,$12,$ca,$12 94
                    fcb       $7a,$12,$06,$12,$a6,$12,$0a,$12 98
                    fcb       $66,$a2,$8a,$02,$8e,$a2,$ca,$a2 9c
                    fcb       $ce,$15,$66,$15,$c2,$15,$ce,$55 a0
                    fcb       $0e,$15,$32,$15,$8e,$15,$ca,$15 a4
                    fcb       $7a,$15,$06,$15,$a6,$15,$0a,$15 a8
                    fcb       $66,$a5,$8a,$05,$8e,$a5,$ca,$a5 ac
                    fcb       $cf,$13,$67,$13,$c3,$13,$cf,$53 b0
                    fcb       $0f,$13,$33,$13,$8f,$13,$cb,$13 b4
                    fcb       $7b,$13,$07,$13,$a7,$13,$0b,$13 b8
                    fcb       $67,$a3,$8b,$03,$8f,$a3,$cb,$a3 bc
                    fcb       $ce,$24,$66,$24,$c2,$24,$0b,$54 c0
                    fcb       $0e,$24,$32,$24,$8e,$24,$00,$00 c4
                    fcb       $7a,$24,$06,$24,$a6,$24,$0a,$24 c8
                    fcb       $8f,$54,$00,$00,$8f,$94,$00,$00 cc
                    fcb       $ce,$22,$66,$22,$c2,$22,$0a,$52 d0
                    fcb       $0e,$22,$32,$22,$8e,$22,$ca,$22 d4
                    fcb       $7a,$22,$06,$22,$a6,$22,$0a,$22 d8
                    fcb       $8e,$52,$ca,$52,$8e,$92,$ca,$92 dc
                    fcb       $ce,$25,$66,$25,$c2,$25,$0a,$55 e0
                    fcb       $0e,$25,$32,$25,$8e,$25,$ca,$25 e4
                    fcb       $7a,$25,$06,$25,$a6,$25,$0a,$25 e8
                    fcb       $8e,$55,$ca,$55,$8e,$95,$ca,$95 ec
                    fcb       $cf,$23,$67,$23,$c3,$23,$0b,$53 f0
                    fcb       $0f,$23,$33,$23,$8f,$23,$cb,$23 f4
                    fcb       $7b,$23,$07,$23,$a7,$23,$0b,$23 f8
                    fcb       $8f,$53,$cb,$53,$8f,$93,$cb,$93 fc
intpg9              equ       *
                    fcb       $53,$76,$21,$2f,$76,$22 page 2
                    fcb       $3b,$76,$23,$1b,$76,$24
                    fcb       $1f,$76,$25,$47,$76,$26
                    fcb       $23,$76,$27,$5b,$76,$28
                    fcb       $5f,$76,$29,$4b,$76,$2a
                    fcb       $43,$76,$2b,$27,$76,$2c
                    fcb       $3f,$76,$2d,$2b,$76,$2e
                    fcb       $37,$76,$2f,$d1,$d1,$3f
                    fcb       $67,$54,$83,$67,$b4,$8c
                    fcb       $8f,$b4,$8e,$66,$52,$93
                    fcb       $66,$b2,$9c,$8e,$b2,$9e
                    fcb       $ca,$b2,$9f,$66,$55,$a3
                    fcb       $66,$b5,$ac,$8e,$b5,$ae
                    fcb       $ca,$b5,$af,$67,$53,$b3
                    fcb       $67,$b3,$bc,$8f,$b3,$be
                    fcb       $cb,$b3,$bf,$8f,$84,$ce
                    fcb       $8e,$82,$de,$ca,$82,$df
                    fcb       $8e,$85,$ee,$ca,$85,$ef
                    fcb       $8f,$83,$fe,$cb,$83,$ff
                    fcb       $d1,$e9,$3f,$67,$9c,$83 page 3
                    fcb       $67,$8c,$8c,$66,$9a,$93
                    fcb       $66,$8a,$9c,$66,$9d,$a3
                    fcb       $66,$8d,$ac,$67,$9b,$b3
                    fcb       $67,$8b,$bc
intpx9              equ       *
* svctab contains OS/9 svc code names.
* if more codes are added, insert
*    them into the table, in the proper place.
* invalids are blank or beyond end of table.
svctab              equ       *
* ifeq (os9lno-$01)
* fcc 'F$Link  ' 00 link to module
* fcc 'F$Load  ' 01 load module
* fcc 'F$UnLink' 02 unlink module
* fcc 'F$Fork  ' 03 fork process
* fcc 'F$Wait  ' 04 wait for child
* fcc 'F$Chain ' 05 chain process
* fcc 'F$Exit  ' 06 exit process
* fcc 'F$Mem   ' 07 set memory size
* fcc 'F$Send  ' 08 send program intr
* fcc 'F$Icpt  ' 09 catch program intr
* fcc 'F$Sleep ' 0a sleep
* fcc 'F$SSpd  ' 0b suspend process
* fcc 'F$Id    ' 0c return process id
* fcc 'F$SPrior' 0d set priority
* fcc 'F$SSWI  ' 0e set swi vector
* fcc 'F$PErr  ' 0f print error message
* fcc 'F$PrsNam' 10 parse pathlist
* fcc 'F$CmpNam' 11 compare names
* fcc 'F$SchBit' 12 search bit map
* fcc 'F$AllBit' 13 allocate bit map
* fcc 'F$DelBit' 14 deallocate bit map
* fcc 'F$Time  ' 15 get time
* fcc 'F$STime ' 16 set current time
* fcc 'F$CRC   ' 17 generate crc
* fcc '                                ' 18-1b
* fcc '                                ' 1c-1f
* fcc '                                ' 20-23
* fcc '                                ' 24-27
* fcc 'F$SRqMem' 28 find sys memory
* fcc 'F$SRtMen' 29 release sys memory
* fcc 'F$IRQ   ' 2a enter irq queue
* fcc 'F$IOQu  ' 2b enter i/o queue
* fcc 'F$AProc ' 2c enter active queue
* fcc 'F$NProc ' 2d start process
* fcc 'F$VModul' 2e validate process
* fcc 'F$Find64' 2f find 64 byte block
* fcc 'F$All64 ' 30 alloc 64 byte block
* fcc 'F$Ret64 ' 31 return 64 byte block
* fcc 'F$SSvc  ' 32 install fcn request
* fcc 'F$IODel ' 33 delete i/o module
* fcc '                                ' 34-37
* fcc '                                ' 38-3b
* fcc '                                ' 3c-3f
* fcc '                                ' 40-43
* fcc '                                ' 44-47
* fcc '                                ' 48-4b
* fcc '                                ' 4c-4f
* fcc '                                ' 50-53
* fcc '                                ' 54-57
* fcc '                                ' 58-5b
* fcc '                                ' 5c-5f
* fcc '                                ' 60-63
* fcc '                                ' 64-67
* fcc '                                ' 68-6b
* fcc '                                ' 6c-6f
* fcc '                                ' 70-73
* fcc '                                ' 74-77
* fcc '                                ' 78-7b
* fcc '                                ' 7c-7f
* fcc 'I$Attach' 80 attach i/o device
* fcc 'I$Detach' 81 detach i/o device
* fcc 'I$Dup   ' 82 duplicate path
* fcc 'I$Create' 83 create new file
* fcc 'I$Open  ' 84 open path to file
* fcc 'I$MakDir' 85 make directory file
* fcc 'I$ChgDir' 86 change directory
* fcc 'I$Delete' 87 delete file
* fcc 'I$Seek  ' 88 seek to byte in file
* fcc 'I$Read  ' 89 read data
* fcc 'I$Write ' 8a write data
* fcc 'I$ReadLn' 8b read line
* fcc 'I$WritLn' 8c write line
* fcc 'I$GetStt' 8d get device status
* fcc 'I$SetStt' 8e set device status
* fcc 'I$Close ' 8f read line
* fcc 'I$DeletX' 90 delete from current exec dir
* endc
** ifeq (os9lno-$02)
                    fcc       'F$Link  '          00 link to module
                    fcc       'F$Load  '          01 load module
                    fcc       'F$UnLink'          02 unlink module
                    fcc       'F$Fork  '          03 fork process
                    fcc       'F$Wait  '          04 wait for child
                    fcc       'F$Chain '          05 chain process
                    fcc       'F$Exit  '          06 exit process
                    fcc       'F$Mem   '          07 set memory size
                    fcc       'F$Send  '          08 send program intr
                    fcc       'F$Icpt  '          09 catch program intr
                    fcc       'F$Sleep '          0a sleep
                    fcc       'F$SSpd  '          0b suspend process
                    fcc       'F$ID    '          0c return process id
                    fcc       'F$SPrior'          0d set priority
                    fcc       'F$SSWI  '          0e set swi vector
                    fcc       'F$PErr  '          0f print error message
                    fcc       'F$PrsNam'          10 parse pathlist
                    fcc       'F$CmpNam'          11 compare names
                    fcc       'F$SchBit'          12 search bit map
                    fcc       'F$AllBit'          13 allocate bit map
                    fcc       'F$DelBit'          14 deallocate bit map
                    fcc       'F$Time  '          15 get time
                    fcc       'F$STime '          16 set current time
                    fcc       'F$CRC   '          17 generate crc
                    fcc       'F$GPrDsc'          18 get processor descriptor copy
                    fcc       'F$GBlkMp'          19 get system block map copy
                    fcc       'F$GModDr'          1a get module directory copy
                    fcc       'F$CpyMem'          1b copy external memory
                    fcc       'F$SUser '          1c set user id
                    fcc       'F$UnLoad'          1d unlink module by name
                    fcc       'F$Alarm '          1e added by color comp level 2
                    fcc       '        '          1f invalid
                    fcc       '        '          20 invalid
                    fcc       'F$NMLink'          21 added by color comp level 2
                    fcc       'F$NMLoad'          22 added by color comp level 2
                    fcc       'F$Debug '          23 invalid
                    fcc       '        '          24 invalid
                    fcc       'F$TPS   '          25 invalid
                    fcc       'F$TimAlm'          26 invalid
                    fcc       'F$VIRQ  '          27 added by color comp level 2
                    fcc       'F$SRqMem'          28 find sys memory
                    fcc       'F$SRtMem'          29 release sys memory
                    fcc       'F$IRQ   '          2a enter irq queue
                    fcc       'F$IOQu  '          2b enter i/o queue
                    fcc       'F$AProc '          2c enter active queue
                    fcc       'F$NProc '          2d start process
                    fcc       'F$VModul'          2e validate process
                    fcc       'F$Find64'          2f find 64 byte block
                    fcc       'F$All64 '          30 alloc 64 byte block
                    fcc       'F$Ret64 '          31 rel 64 byte block
                    fcc       'F$SSvc  '          32 install fcn request
                    fcc       'F$IODel '          33 delete i/o module
                    fcc       'F$SLink '          34 system link
                    fcc       'F$Boot  '          35 bootstrap system
                    fcc       'F$BtMem '          36 bootstrap memory
                    fcc       'F$GProcP'          37 get process ptr
                    fcc       'F$Move  '          38 move data low bound first
                    fcc       'F$AllRAM'          39 allocate ram blocks
                    fcc       'F$AllImg'          3a allocate image ram blocks
                    fcc       'F$DelImg'          3b deallocate image ram blocks
                    fcc       'F$SetImg'          3c set process dat image
                    fcc       'F$FreeLB'          3d get free low block
                    fcc       'F$FreeHB'          3e get free high block
                    fcc       'F$AllTsk'          3f allocate process task number
                    fcc       'F$DelTsk'          40 deallocate process task number
                    fcc       'F$SetTsk'          41 set process dat registers
                    fcc       'F$ResTsk'          42 reserve process task numbers
                    fcc       'F$RelTsk'          43 release task number
                    fcc       'F$DATLog'          44 convert data block/offset to logical
                    fcc       'F$DATTmp'          45 make temporary dat image
                    fcc       'F$LDAXY '          46 load a,[x,[y]]
                    fcc       'F$LDAXYP'          47 load a,[x+,[y]]
                    fcc       'F$LDDDXY'          48 load d [d+x,[y]]
                    fcc       'F$LDABX '          49 load a from 0,x in task b
                    fcc       'F$STABX '          4a store a in 0,x in task b
                    fcc       'F$AllPrc'          4b allocate process descriptor
                    fcc       'F$DelPrc'          4c deallocate process descriptor
                    fcc       'F$ELink '          4d link using module directory entry
                    fcc       'F$FModul'          4e find module directory entry
                    fcc       'F$MapBlk'          4f added by color comp level 2
                    fcc       'F$ClrBlk'          50 added by color comp level 2
                    fcc       'F$DelRAM'          51 added by color comp level 2
                    fcc       'F$GCMDir'          52 added by color comp level 2
                    fcc       'F$AlHRAM'          53 added by color comp level 2
                    fcc       'F$ReBoot'          54 Reboot machine (reload OS9Boot) or drop to RSDOS
                    fcc       'F$CRCMod'          55 CRC mode, toggle or report current status
                    fcc       'F$XTime '          56 Get Extended time packet from RTC (fractions of second)
                    fcc       'F$VBlock'          57 Verify modules in a block of memory, add to module directory
                    fcc       '                                ' 58-5b
                    fcc       '                                ' 5c-5f
                    fcc       '                                ' 60-63
                    fcc       '                                ' 64-67
                    fcc       '                                ' 68-6b
                    fcc       '                                ' 6c-6f
                    fcc       'F$RegDmp'          70
                    fcc       'F$NVRAM '          71
                    fcc       '        '          72
                    fcc       '        '          73
                    fcc       '                                ' 74-77
                    fcc       '                                ' 78-7b
                    fcc       '                                ' 7c-7f
                    fcc       'I$Attach'          80 attach i/o device
                    fcc       'I$Detach'          81 detach i/o device
                    fcc       'I$Dup   '          82 duplicate path
                    fcc       'I$Create'          83 create new file
                    fcc       'I$Open  '          84 open path to file
                    fcc       'I$MakDir'          85 make directory file
                    fcc       'I$ChgDir'          86 change directory
                    fcc       'I$Delete'          87 delete file
                    fcc       'I$Seek  '          88 seek to byte in file
                    fcc       'I$Read  '          89 read data
                    fcc       'I$Write '          8a write data
                    fcc       'I$ReadLn'          8b read line
                    fcc       'I$WritLn'          8c write line
                    fcc       'I$GetStt'          8d  get device status
                    fcc       'I$SetStt'          8e set device status
                    fcc       'I$Close '          8f read line
                    fcc       'I$DeletX'          90 added by color comp level 1.1 version 2.00
* endc
svcend              equ       *                   end of svc table
********************
                    emod
endmod              equ       *
                    end
