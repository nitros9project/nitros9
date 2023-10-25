********************************************************************
* DMode - Disk descriptor utility
*
* $Id$
*
* RBF descriptor utility similar to xmode.
* Use: dmode </devicename> [options]
*      dmode -<filename>   [options]
*       (allows dmode use on a saved desc)
*       (-filename will use data dir for default)
*      dmode -?  will give bit definitions
* If no options given, just returns desc info.
* All numbers must be in HEX.
* dmode
* dmode /h0 cyl=0200 sas=8 ilv=4
* dmode /d0
* dmode -?
* dmode -/d1/modules/d2.dd cyl=0028
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          1986/09/23  Kevin Darling
* Oversized and kludgy, but works.
* Apologies for lack of comments.
*
*          1986/10/01  Kevin Darling
*
*          1986/10/02  Kevin Darling
* This version will do desc file on disk also.
*
*          1989/08/24  Roger A. Krupski (HARDWAREHACK)
* Fixed "lower case bug", allowed "$" prefix for hex
*
* -------- NitrOS9 DMODE HISTORY -----------------------------------
* 8 / 1    2003/01/31  Boisy G Pitre
* Initial import - added to standard CMDS distribution
*
* 8 / 1    2003/09/04  Boisy G Pitre
* Redid history comments to new format
*
* 1 / 4    2004/02/19  Boisy G Pitre
* Old source replaced by fcb hex dump of new dmode.bin
* May be a back-port from Carl Kreider's dmode for OSK
*
* 2 / 4    2004/02/28  Rodney V. Hamilton
* Disassembled new dmode, added comments and KD/RAK mods.

                    nam       DMode
                    ttl       program module

* Disassembled 2004/02/21 08:59:24 by Disasm v1.5 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $04

                    mod       eom,name,tylg,atrv,start,size

OLDMODS             equ       1                   enable KD/RAK dmode mods if >0

hexcnt              rmb       1                   number of option bytes
dataptr             rmb       2                   current option ptr
hexin               rmb       2                   2 byte hex number
module              rmb       2                   desc address
msize               rmb       2                   module total size (including CRC)
dsize               rmb       2                   descriptor size (hdrs + init tbl)
parmptr             rmb       2                   next name dataptr
path                rmb       1                   file path
txtptr              rmb       2                   option name ptr
buffer              rmb       10                  output buffer
buflen              equ       .-buffer
desc                rmb       80
descmax             equ       .-desc
                    rmb       512                 stack+params
size                equ       .

name                fcs       /DMode/
                    fcb       $02

** Options Table for RBF Device Driver Modules
* entry format: NAME[4] + OFFSET[1] + COUNT[1]
* NAME:   leading space plus 3-char field name
* OFFSET: byte offset to option field in module
* COUNT:  size of option field in bytes
** (if offset bit.7 set, field is ptr to string of length COUNT)
otable              fcc       " nam"
                    fcb       M$Name!$80          ($84) ptr to name of module
                    fcb       3                   max name length=3
nxtopt              equ       *-otable            offset to next option (=6)
optlen              equ       nxtopt-2            length of option name (=4)
optoff              equ       nxtopt-2            offset to option offset (=4)
optsiz              equ       nxtopt-1            offset to option byte count  (-5)
                    fcc       " mgr"
                    fcb       M$FMgr+$80,0        ($89) ptr to name of file manager
                    fcc       " ddr"
                    fcb       M$PDev-$80,0        ($8B) ptr to name of device driver
                    fcc       " hpn"
                    fcb       M$Port,1            ($0E) extended port address
                    fcc       " hpa"
                    fcb       M$Port+1,2          ($0F) base port address
                    fcc       " drv"
                    fcb       IT.DRV,1            ($13) drive number
                    fcc       " stp"
                    fcb       IT.STP,1            ($14) step rate
                    fcc       " typ"
                    fcb       IT.TYP,1            ($15) device type
                    fcc       " dns"
                    fcb       IT.DNS,1            ($16) media density
                    fcc       " cyl"
                    fcb       IT.CYL,2            ($17) number of cylinders (tracks)
                    fcc       " sid"
                    fcb       IT.SID,1            ($19) number of sides
                    fcc       " vfy"
                    fcb       IT.VFY,1            ($1A) verify writes (0-yes)
                    fcc       " sct"
                    fcb       IT.SCT,2            ($1B) default sectors/track
                    fcc       " t0s"
                    fcb       IT.T0S,2            ($1D) default sect/trk for track 0
                    fcc       " ilv"
                    fcb       IT.ILV,1            ($1F) sector interleave factor
                    fcc       " sas"
                    fcb       IT.SAS,1            ($20) minimum segment allocation (sectors)
                    fcc       " wpc"
                    fcb       $25,1               (offset unnamed) write precomp cylinder (HD)
                    fcc       " ofs"
                    fcb       $26,2               (offset unnamed) starting cylinder offset (HD)
                    fcc       " rwc"
                    fcb       $28,2               (offset unnamed) reduced write current cylinder (HD)
otblsiz             equ       (*-otable)/nxtopt
* number of DISPLAYED options - remainder are accepted but not printed
                    ifne      OLDMODS             compatibility
                    fcc       " tos"              alias for t0s (old DMODE compatibility)
                    fcb       IT.T0S,2
                    endc
                    fcb       $80                 end of table

usage               fcb       C$LF
                    fcc       "Usage:  DMode [/<device> || -<pathlist> || -?] [option] [option] [...]"
                    fcb       C$LF
                    fcb       C$LF
                    fcc       "Purpose:  To report or alter current option settings of RBF device"
                    fcb       C$LF
                    fcc       "          descriptors in memory or on disk in single module files."
                    fcb       C$LF
                    fcb       C$LF
                    fcc       "Options:  nam, mgr, ddr, hpn, hpa, drv, stp, typ, dns, cyl, sid, vfy,"
                    fcb       C$LF
                    fcc       "          sct, t0s, ilv, sas, wpc, ofs, rwc."
                    fcb       C$LF
                    fcb       C$LF
                    fcc       "Examples:  dmode /dd"
                    fcb       C$LF
                    fcc       "               Prints the current option settings of the /DD descriptor"
                    fcb       C$LF
                    fcc       "               in memory."
                    fcb       C$LF
                    fcc       "           dmode -modules/h0.dd nam=H1 drv=1 cyl=03FF rwc=ffff"
                    fcb       C$LF
                    fcc       "               Changes the module name in the MODULES/H0.dd file to H1,"
                    fcb       C$LF
                    fcc       "               sets the physical drive number to 1, cylinders to $03FF,"
                    fcb       C$LF
                    fcc       "               and the Reduced Write Current cylinder to $FFFF."
                    fcb       C$LF
                    fcc       "           dmode -?"
                    fcb       C$LF
                    fcc       "               Prints more complete information on all of the options."
                    fcb       C$CR
uselen              equ       *-usage

infomsg             fcb       C$LF
                    fcc       "The NAM option accepts only a legal OS-9 module name with a maximum of"
                    fcb       C$LF
                    fcc       "3 characters.  It is up to the user to ensure that there is adequate"
                    fcb       C$LF
                    fcc       "room for the module name, and if required to rename the disk file to"
                    fcb       C$LF
                    fcc       "suit the new module name.  The MGR and DDR options can't be changed."
                    fcb       C$LF
                    fcc       "All other options require hexadecimal numbers (0 through FFFF).  The"
                    fcb       C$LF
                    fcc       "WPC, OFS, and RWC options are for WDDisk descriptors only."
                    fcb       C$LF
                    fcb       C$LF
                    fcc       "nam  Device Descriptor Name             "
                    fcc       "mgr  File Manager Name"
                    fcb       C$LF
                    fcc       "ddr  Device Driver Name                 "
                    fcc       "hpn  Hardware Page Number"
                    fcb       C$LF
                    fcc       "hpa  Hardware Port Address              "
                    fcc       "drv  Physical Drive Number"
                    fcb       C$LF
                    fcc       "stp  Step Rate Code                     "
                    fcc       "typ  Drive Type"
                    fcb       C$LF
                    fcc       "dns  Drive/Disk Density                 "
                    fcc       "cyl  Drive Cylinders"
                    fcb       C$LF
                    fcc       "sid  Drive Sides (Heads)                "
                    fcc       "vfy  Write Verify Flag"
                    fcb       C$LF
                    fcc       "sct  Sectors Per Track                  "
                    fcc       "t0s  Sectors On Track Zero"
                    fcb       C$LF
                    fcc       "ilv  Sector Interleave Factor           "
                    fcc       "sas  Segment Allocation Size"
                    fcb       C$LF
                    fcc       "wpc  Write Precompensation Code         "
                    fcc       "ofs  Partition Offset Cylinder"
                    fcb       C$LF
                    fcc       "rwc  Reduced Write Current Cylinder"
                    fcb       C$CR
infolen             equ       *-infomsg

equal               fcb       $3D                 "="

rbfmsg              fcb       C$LF
                    fcc       "Not an RBF descriptor!"
cr                  fcb       C$CR
rbflen              equ       *-rbfmsg

sizmsg              fcb       C$LF
                    fcc       "Module size out of range!"
                    fcb       C$CR
sizlen              equ       *-sizmsg

synmsg              fcb       C$LF
                    fcc       "Syntax error:  "
synlen              equ       *-synmsg

*NOTE: --the code begins here--

morehelp            leax      >infomsg,pcr
                    ldy       #infolen
                    bra       helpprnt

toobig              leax      >sizmsg,pcr
                    ldy       #sizlen
                    bra       errprnt

notrbf              leax      >rbfmsg,pcr
                    ldy       #rbflen

errprnt             lda       #2
                    os9       I$WritLn

help                leax      >usage,pcr
                    ldy       #uselen

helpprnt            lda       #2
                    os9       I$WritLn
                    lbra      okayend2

start               equ       *
                    ldd       #0
                    std       <module             zero mod flag
                    sta       <path               zero file flag
                    ldd       ,x+                 check for device name
                    cmpa      #'-                 file option?
                    bne       link
                    cmpb      #'?                 help option?
                    beq       morehelp

* read descriptor from file
                    lda       #UPDAT.             open path to desc file
                    os9       I$Open
                    bcs       help
                    stx       <parmptr
                    sta       <path               save path number
                    ldy       #descmax            max size
                    leax      <desc,u             desc buff
                    os9       I$Read              read the file
                    lbcs      error
                    ldb       <M$Opt,x            init table size
                    clra
                    addd      #M$DTyp             add size of headers
                    std       <dsize              save desc size less CRC
                    ldd       M$Size,x            module size incl CRC
                    cmpd      #descmax            too big for desc buffer?
                    bhi       toobig              ..yes, size error
                    std       <msize              save module size
                    bra       gotit

* read descriptor from memory
link                cmpa      #PDELIM             else must be /<devicename>
                    bne       help
                    pshs      u
                    lda       #Devic              type=device descriptor
                    os9       F$Link              link to descriptor
                    bcs       help
                    stx       <parmptr            update after name
                    tfr       u,x
                    puls      u
                    stx       <module
                    ldb       <M$Opt,x            get desc init table size
                    clra
                    addd      #M$DTyp             add desc header size
                    std       <dsize              save desc size less CRC
                    ldd       M$Size,x            get current module size
                    cmpd      #descmax            too big for desc buffer?
                    lbhi      toobig              ..yes, size error
                    std       <msize              save module size
                    tfr       d,y
                    pshs      u
                    leau      <desc,u
mloop               lda       ,x+                 copy in-memory data
                    sta       ,u+                 to descriptor buffer
                    leay      -1,y
                    bne       mloop
                    puls      u
gotit               ldd       <dsize
                    cmpd      <msize
                    lbcc      toobig
                    leax      <desc,u
                    lda       <IT.DTP,x           test device type
                    cmpa      #1                  RBF?
                    lbne      notrbf              .. no, non-RBF error
                    ldx       <parmptr            reload input parms ptr
                    lbsr      skipspc             skip blanks
                    cmpa      #C$CR               any options?
                    lbeq      info                ..no, give current info
                    leax      -1,x                else find options

* Find and Set Options
* X=param ptr
findopt             lbsr      skipspc             get next input param
                    stx       <parmptr            save for syntax error use
                    cmpa      #C$CR               end?
                    lbeq      verify              ..yes, update desc CRC
                    leay      >(otable-nxtopt),pcr init option table ptr
                    pshs      u
                    ldu       ,x++                get next two chars
                    ora       #'a-'A              force lowercase char 1
                    exg       d,u
                    ora       #'a-'A              -ditto for chars 2&3
                    orb       #'a-'A
                    exg       d,u
flup20              leay      nxtopt,y            next option entry
                    tst       ,y                  end of table?
                    bmi       syntax              ..yes, bad option
                    cmpa      1,y
                    bne       flup20              option name match?
                    cmpu      2,y
                    bne       flup20              ..no, try next
* option found
                    puls      u
                    sty       <txtptr
                    ldd       ,x+
                    cmpa      #'=                 must be followed by "="
                    bne       syntax
                    cmpb      #C$CR
                    beq       syntax
                    cmpb      #C$SPAC
                    beq       syntax
                    ldb       optsiz,y            get # of bytes
                    beq       syntax              cannot modify if length=0
                    stb       <hexcnt
                    ldb       optoff,y            get option size/type
                    bpl       setnum              hi-bit clear, do numeric
* process string option change
                    andb      #$7F                get string ptr offset
                    clra
                    cmpd      <msize              within module?
                    bcc       syntax
                    leay      <desc,u
                    ldd       b,y                 read string ptr
                    cmpd      <msize              within module?
                    bcc       syntax
                    leay      d,y                 point to string field
                    pshs      y
                    os9       F$PrsNam            parse user's input for valid OS9 name
                    puls      y
                    bcs       syntax              bad name syntax
                    cmpa      #C$SPAC             name's trailing delimiter..
                    beq       nameok              must be space
                    cmpa      #C$CR               or end of line
                    bne       syntax
nameok              cmpb      <hexcnt             new name longer than field size?
                    bhi       syntax
ncopy               lda       ,x+                 copy new name to desc
                    sta       ,y+
                    decb
                    bne       ncopy
                    lda       -1,y
                    ora       #$80                and flag last char
                    sta       -1,y
                    lbra      findopt

syntax              leax      >synmsg,pcr
                    ldy       #synlen
                    lda       #2
                    os9       I$Write             print syntax err msg to stderr
                    ldx       <parmptr
                    leax      -1,x                rewind to start of arg
                    pshs      x
                    ldy       #0                  set arg len to 0
slup                leay      1,y                 ..count chars
                    lda       ,x+
                    cmpa      #C$CR               ..until EOL
                    beq       synsay
                    cmpa      #C$SPAC             ..or space
                    bne       slup
synsay              puls      x                   X=arg ptr, Y=arg len
                    lda       #2
                    os9       I$Write             print name of bad arg to stderr
                    lbra      okayend

* process numeric option change
setnum              clra
                    cmpd      <dsize              option within current descriptor?
                    bcc       syntax
                    clr       <hexin              zero hex input field
                    clr       <hexin+1

setloop             lda       ,x+                 get next #
                    ifne      OLDMODS             compatibility
                    cmpa      #'$                 optional hex $?
                    beq       setloop             yes, ignore
                    endc
                    cmpa      #C$SPAC             end of number?
                    beq       setnum2             ..yes, set option, rts
                    cmpa      #C$CR               end of line?
                    beq       setnum1
* hex conversion - inlined code
                    suba      #'0                 make number from ASCII
                    bmi       syntax
                    cmpa      #10                 is it number?
                    bcs       num
                    anda      #$5F                make uppercase
                    suba      #'A-'0-10           make hex $A-$F
                    cmpa      #10                 not hex char?
                    bcs       syntax
                    cmpa      #16                 not hex char?
                    bcc       syntax
num                 ldb       #16                 fancy asl *4
                    mul
                    pshs      b                   save top 4 bits
                    ldd       <hexin
                    rol       ,s
                    rolb
                    rola
                    rol       ,s
                    rolb
                    rola
                    rol       ,s
                    rolb
                    rola
                    rol       ,s
                    rolb
                    rola
                    std       <hexin
                    puls      b
                    bra       setloop             ..loop

setnum1             leax      -1,x                reset so can find <cr>
setnum2             ldb       optoff,y            get option offset
                    leay      <desc,u             point to desc
                    leay      b,y                 point to option
                    ldd       <hexin              pick up hex input
                    dec       <hexcnt
                    beq       setone
                    std       ,y                  set two byte option
                    lbra      findopt

setone              tsta
                    lbne      syntax
                    stb       ,y                  set one byte option
                    lbra      findopt

skipspc             lda       ,x+
                    cmpa      #C$SPAC
                    beq       skipspc
                    rts

* Update Descriptor's CRC
verify              pshs      u
                    leau      <desc,u
                    tfr       u,x                 X is module addr
                    ldy       M$Size,x            Y is module size
                    leay      -3,y                offset of CRC
                    tfr       y,d                 Y is byte count
                    leau      d,u                 U is ptr to CRC
                    lda       #$FF                init CRC value
                    sta       0,u
                    sta       1,u
                    sta       2,u
                    pshs      u
                    os9       F$CRC               calc new CRC
                    puls      u
                    com       ,u+                 store as complement
                    com       ,u+
                    com       ,u
                    lda       <path               was it a file?
                    beq       memmod              ..no, in memory
                    ldx       #0
                    tfr       x,u
                    os9       I$Seek              go back to file begin
                    bcs       error
                    puls      u
                    leax      <desc,u
                    ldy       <msize
                    os9       I$Write             update desc file
                    bra       okayend

memmod              ldu       ,s
                    leax      <desc,u
                    ldy       <msize
                    ldu       <module
move                lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       move
                    puls      u
                    bra       okayend2

okayend             bsr       outcr
okayend2            clrb
error               pshs      b,cc
                    ldu       <module
                    beq       bye
                    os9       F$UnLink
bye                 puls      b,cc
                    os9       F$Exit              end dmode.

outcr               leax      >cr,pcr
                    ldy       #1
                    lda       #1
                    os9       I$WritLn
                    rts

* Output Current Desc Info
info                bsr       outcr
                    ldb       #otblsiz            printable entry count
                    pshs      b
                    leax      >otable,pcr         point to option table
                    stx       <txtptr
ilup                ldx       <txtptr
                    ldy       #optlen
                    lbsr      output              print option name
                    leax      >equal,pcr
                    ldy       #1
                    lbsr      output              and '='
                    ldx       <txtptr
                    ldb       optoff,x            get option type & size
                    bpl       outnum              if numeric, print hex value
* Print String Option Field
                    andb      #$7F                else get string ptr offset
                    clra
                    cmpd      <msize              within module?
                    bcc       inext               ..no, skip to next option
                    leay      <desc,u
                    ldd       b,y                 read string ptr
                    cmpd      <msize              within module?
                    bcc       inext               ..no, skip to next option
                    leay      d,y                 point to string field
                    lda       #buflen
                    leax      <buffer,u
                    clr       <hexcnt
sloop               ldb       ,y+                 copy string chars
                    bpl       scopy               last char?
                    andb      #$7F                ..yes, make printable
                    lda       #1                  ..and set exit count
scopy               stb       ,x+                 to output buffer
                    inc       <hexcnt             counting as we go
                    deca
                    bne       sloop               until buffer full
                    ldb       <hexcnt             get length copied
                    tfr       d,y
                    leax      <buffer,u
                    bsr       output              print the string
                    bra       inext               goto next option

* Print Numeric Option Value
outnum              ldx       <txtptr
                    ldb       optsiz,x            get # of bytes
                    stb       <hexcnt
                    ldb       optoff,x            get field offset
                    clra
                    cmpd      <dsize              within descriptor?
                    bcc       inext               no, skip to next
                    leax      <desc,u
                    abx                           point to number
                    stx       <dataptr
* print <hexcnt> bytes starting at [x] as ASCII Hex
outhex              ldx       <dataptr
                    lda       ,x+                 get next byte
                    stx       <dataptr
                    pshs      a                   print as 2 hex digits
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       outone              print upper
                    puls      a
                    anda      #$0F
                    bsr       outone              print lower
                    dec       <hexcnt
                    bne       outhex
inext               ldx       <txtptr
                    leax      nxtopt,x            point to next option
                    stx       <txtptr
                    dec       ,s                  continue until
                    lbeq      okayend             ..end of printable info
                    ldb       ,s                  if option counter
                    bitb      #$07                ..is a multiple of 8
                    lbne      ilup
                    lbsr      outcr               do a <cr>
                    lbra      ilup                ..and continue

outone              cmpa      #10                 Print 1/2 Byte Hex Char:
                    bcs       number
                    adda      #$11-10             make alpha
number              adda      #'0                 make ASCII
                    sta       <buffer
                    leax      <buffer,u
                    ldy       #1                  print one digit
output              lda       #1
                    os9       I$Write             print the output buffer
                    lbcs      error
                    rts

                    emod
eom                 equ       *
                    end
