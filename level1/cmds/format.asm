********************************************************************
* Format - RBF Disk format program
*
* $Id$
*
* Notes:
*   1. If the TYP.DSQ bit in IT.TYP is clear, then the total number
*      of sectors is NOT multiplied by the bytes per sector.  This
*      means that descriptors using partition offsets will need to
*      fill IT.CYL, IT.SID and IT.SCT with values that reflect the
*      number of 256 byte sectors on the disk.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  22      ????/??/??
* From Tandy OS-9 Level Two VR 02.00.01.
*
*  23      2003/01/06  JC
* Format incorrect/clusters summary: now, specifying cluster size works.
* Fixed bug where format showed an improper number of sectors formatted
* at the summary if the number of sectors was a large number.
* This was most notable when formatting large disks, such as hard drives.
*
*  24      2004/07/20  Boisy G. Pitre
* Revamped to display summary similar to OS-9/68K. Also, format now
* checks the TYPH.DSQ bit in order to query the drive for its size.
* A rolling track counter that stays on the same line is now used
* instead of the scrolling track counter, and 4 byte track numbers
* are now shown instead of 3 byte track numbers.
* Also, if a cluster size is not specified on the command line,
* the best one is automatically calculated.
*
*       2005-10-25  P.Harvey-Smith.
* Added support for formatting Dragon floppies, this is required because
* dragon floppies are aranged thus :-
*	LSN	Purpose
*	0	Standard LSN0
*	1	Blockmap
*	2-17	Boot area (as on track 35 of CoCo disk).
*	18	Begining of root dir
*	19+	Continuation of root dir ? and data sectors.
*
* Note as a limitation of this scheme, is that disks with more than 2048
* sectors, need to have a cluster size of 2 as only one sector is available
* for the block map.
*
* To format a floppy with dragon format, you need to use the command line
* parameter 'FD' (format, Dragon).
*
*       2005-10-26  P.Harvey-Smith
* Determined the purpose and commented some of the unknown memory vars,
* also renamed others to more closeley represent their purpose, e.g.
* there where two 'cluster size' vars, one was inface number of bytes in
* bitmap, so that got renamed :)
* Format can now correctly build a DragonData OS-9 compatible disk
* that can have (under OS-9) cobbler run on it, and will subsequently then
* boot.
*
*  25   2005-10-26  Boisy G. Pitre
* Fixed an issue where the bitmap sector wasn't being properly set up
* due to some incorrect assumptions.  The result was that copying a file
* to a newly formatted hard drive would, in cases where the drive was
* large, wipe out the bitmap sector and root directory area.
*
*       2020-01-05  David Ladd
* Added enhanced sector data for the special 20 sector per track on
* floppy disks.  Added new option E to allow using this enhanced
* sector data.

                    nam       Format
                    ttl       RBF Disk format program

* Disassembled 02/07/17 11:00:13 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

DOHELP              set       0
DOROLL              set       0

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       25

                    mod       eom,name,tylg,atrv,start,size

********************************************************************
* begin our data area, starts on direct page
********************************************************************


savedu              rmb       2                   save the u register
totsects            rmb       3
tmpnum              rmb       4
sectmode            rmb       1
diskpath            rmb       1                   disk path number
currtrak            rmb       2                   current track on
currside            rmb       2
currsect            rmb       1                   current sector on
sectcount           rmb       2                   counted sectors
trk0data            rmb       2                   track 0 data pointer
trkdata             rmb       2                   track !0 data pointer
u000E               rmb       2
mfm                 rmb       1                   denisity (double/single)
maxmfm              rmb       1
tpi                 rmb       1
numsides            rmb       1
ncyls               rmb       2                   total number of cylinders
u0017               rmb       1
u0018               rmb       1
sectors             rmb       2                   total number of sectors
sectors0            rmb       2                   total number of sectors
bps                 rmb       1                   bytes per sector (returned from SS.DSize)
dtype               rmb       1                   disk device type (5", 8", hard disk)
dns                 rmb       1                   density byte
sas                 rmb       1                   density byte
ready               rmb       1                   ready to proceed, skip warning
dresult             rmb       2                   decimal number in binary
interlv             rmb       1                   sector interleave value
u0022               rmb       2
clustsiz            rmb       1                   cluster size (specified or default)
clustspecified      rmb       1                   cluster size specified on command line
NumBitmapBytes      rmb       2                   Number of bytes in cluster allocation bitmap
u002A               rmb       1
clustcnt            rmb       1
NoRootFDSecs        rmb       1                   Number of sectors in Root FD (normally 8 ?)
NoSysSectors        rmb       2                   Number of Sectors at beginning of disk reserved for system
NoSysClusters       rmb       2                   Number of system Clusters to allocate
u0030               rmb       1
u0031               rmb       1
u0032               rmb       1
u0033               rmb       1
u0034               rmb       1
u0035               rmb       1
oksects             rmb       3
u0038               rmb       2
u003A               rmb       2
u003C               rmb       1
u003D               rmb       2
u003F               rmb       2
u0041               rmb       2
u0043               rmb       1
u0044               rmb       1
dovfy               rmb       1
dtentry             rmb       2
u0048               rmb       1
toffs               rmb       1                   track offset (derived from PD.SToff)
soffs               rmb       1                   sector offset (derived from PD.SToff)
t0sngdns            rmb       1                   track 0 single density flag
cocofmt             rmb       1                   COCO disk format flag (1 = yes)
dolog               rmb       1                   logical format
prmbuf              rmb       2
u0051               rmb       4
u0055               rmb       15
u0064               rmb       7
u006B               rmb       4
dskname             rmb       32                  quoted delimited disk name buffer
u008F               rmb       40
IsDragon            rmb       1                   Is this a dragon disk ?
IsSpec20            rmb       1                   Is this a special fmt data for 20 sector per track floppy disks
SaveRootLSN         rmb       3                   Saved copy of DD.DIR
AddedSysSecs        rmb       2                   Additional system sectors (0 for CoCo, $10 for Dragon boot area)
LSN0                rmb       256                 LSN0 build buffer
optbuf              rmb       256
numbuf              rmb       32
fdtbuf1             rmb       3
fdtbuf2             rmb       9924
u297E               rmb       451
size                equ       .

name                fcs       /Format/
                    fcb       edition

*val1     fdb   $0000
*val2     fdb   $0000
*val3     fdb   $0000

* Hard drive sector data: 128 bytes of $E5, and another 128 bytes of $E5
hdsdat              fdb       $80E5,$80E5,$0000

* Single Density Floppy Track Data
sgtdat              fdb       $0100,$28FF,$0600,$01FC,$0CFF,$0000
* Single Density Sector Data
sgsdat              fdb       $0600,$01FE,$0400,$01F7,$0AFF,$0600
                    fdb       $01FB,$80E5,$80E5,$01F7,$0AFF,$0000
                    fcb       $FF
sgfidp              fdb       $0043
sgsize              fdb       $0128

* Double Density Floppy Track Data
dbtdat              fdb       $504E,$0C00,$03F6,$01FC,$204E,$0000
* Double Density Sector Data
dbsdat              fdb       $0C00,$03F5,$01FE,$0400,$01F7,$164E
                    fdb       $0C00,$03F5,$01FB,$80E5,$80E5,$01F7
                    fdb       $164E,$0000
                    fcb       $4E
dbfidp              fdb       $0090
dbsize              fdb       $0152

* Double Density Color Computer Format
dctdat              fdb       $204E,$0000,$0C00,$03F5,$01FE,$0400
                    fdb       $01F7,$164E,$0C00,$03F5,$01FB,$80E5
                    fdb       $80E5,$01F7,$184E,$0000
                    fcb       $4E
dcfidp              fdb       $0030
dcsize              fdb       $0154

* Special Double Density Color Computer Format 20 SPT
ectdat              fdb       $084E,$0000,$0800,$03F5,$01FE,$0400
                    fdb       $01F7,$0100,$1B00,$03F5,$01FB,$80E5
                    fdb       $80E5,$01F7,$0100,$0000
                    fcb       $4E
ecfidp              fdb       $0014
ecsize              fdb       $0133

DragonFlag          equ       'd                  Flag that we are formatting dragon formatted disk.
DragonRootSec       equ       $12                 Dragon root sector is always LSN 18
DragonBootSize      equ       $10                 Size of dragon boot area

********************************************************************
* format module execution start address
********************************************************************

start               stu       <savedu             save our data pointer
                    bsr       ClrWork             clear the work area
                    bsr       OpenDev             get device name and open it
                    lbsr      Default             handle all the options
                    lbsr      GetDTyp             initialize the device
                    lbsr      Proceed
                    lbsr      Format              physically format device
                    lbsr      InitLSN0            initialize LSN0
                    lbsr      ReadLSN0            attempt to read back LSN0
                    lbsr      MkBMap              make bitmap sectors
                    lbsr      MkRootFD            file descriptor
                    ldu       <dtentry            device table entry
                    os9       I$Detach            detach the device
                    clrb                          flag no error
Exit                os9       F$Exit              exit module

********************************************************************
* clear our working memory area
********************************************************************

ClrWork             leay      diskpath,u          point to work area
                    pshs      y                   save that
                    leay      >LSN0,u             get size of area
ClrOne              clr       ,-y                 clear it down
                    cmpy      ,s                  at begin?
                    bhi       ClrOne              not yet,
                    clr       IsDragon,u          Assume we are not formatting a dragon disk
                    clr       IsSpec20,u          Assume we are not formatting using special 20
                    clr       AddedSysSecs,u      Clear aditional system sectors
                    clr       AddedSysSecs+1,u
                    puls      pc,y                done

********************************************************************
* get rbf device name and open it
********************************************************************

OpenDev             lda       ,x+                 get char at X
                    cmpa      #PDELIM             pathlist delimiter?
                    beq       PrsPrm              branch if so
BadPath             ldb       #E$BPNam            else set bad pathname
                    lbra      PrtError            and print error
PrsPrm              os9       F$PrsNam            parse pathname
                    lbcs      PrtError            branch if illegal (has additional pathlist element)
                    lda       #PDELIM             get pathlist name separator
                    cmpa      ,y                  another pathlist separator?
                    beq       BadPath             yes, set bad pathname
                    sty       <u0022              no, save end of pathname
                    leay      <prmbuf,u           point to pathname buffer
MovNam              sta       ,y+                 save pathname character
                    lda       ,x+                 get next pathname character
                    decb                          decrement pathname size
                    bpl       MovNam              got full pathname?
                    leax      <prmbuf+1,u         get pathname for I$Attach
                    lda       #C$SPAC             space character
                    sta       ,y                  delimit pathname
                    clra                          get access mode
                    os9       I$Attach            attach the rbf device
                    lbcs      PrtError            if error print error and exit
                    stu       <dtentry            save device table entry
                    ldu       <savedu             get data pointer
                    lda       #PENTIR             delimit pathname
                    ldb       #C$SPAC             for os9 I$Open
                    std       ,y                  do it now
                    lda       #WRITE.             get access mode
                    leax      <prmbuf,u           get pathname
                    os9       I$Open              open the rbf device
                    bcs       Exit                exit if could not open it
                    sta       <diskpath           save path number
                    rts                           return

********************************************************************
* get geometry and options, proceed (Y/N)
********************************************************************

Default             bsr       Geometry
                    lbsr      DoOpts
*         lbsr  Proceed
                    rts

********************************************************************
* get rbf device geometry
********************************************************************

ssztbl              fcb       $1,$2,$4,$8

Geometry            leax      >optbuf,u           status packet address
                    clrb                          SS.OPT function
                    os9       I$GetStt            get status packet
                    lbcs      Exit                exit if error
                    ldb       PD.SID-PD.OPT,x     number of surfaces
                    stb       <numsides           save it
                    ldb       PD.SToff-PD.OPT,x   get track/sector offset values
                    beq       L0143               branch if they are zero
                    tfr       b,a                 yes, make copy
                    anda      #$0F                isolate track offset (lower 4 bits)
                    sta       <toffs              save it
                    lsrb
                    lsrb
                    lsrb
                    lsrb                          isolate sector offset
                    stb       <soffs              save it
L0143               ldb       PD.DNS-PD.OPT,x     density capability
                    stb       <dns
*         pshs  b                save it
                    andb      #DNS.MFM            check double-density
                    stb       <mfm                save double-density (Yes/No)
                    stb       <maxmfm             save it again as maximum mfm
                    ldb       <dns                get saved PD.DNS byte
                    lsrb                          now 96 TPI bit is in bit pos 0
                    pshs      b                   save it
                    andb      #$01                tpi (0=48/135, 1=96)
                    stb       <tpi                save it
                    puls      b                   get byte with bit shifted right once
                    lsrb                          shift original bit #2 into bit #0
                    andb      <maxmfm             AND with mfm bit (1 = MFM, 0 = FM)
                    stb       <t0sngdns           save as track 0 single density flag
*         puls  b		get original PD.DNS byte
* NOTE: We check the TYP.CCF at this point
                    ldb       PD.TYP-PD.OPT,x     disk device type
                    stb       <dtype
                    andb      #TYP.CCF
                    stb       <cocofmt            store it
                    beq       L0169               branch if not CoCo format
                    ldb       #$01
                    stb       <soffs              CoCo has a sector offset of 1
                    clr       <toffs              and no track offset
L0169               ldd       PD.CYL-PD.OPT,x     number of cylinders
                    std       <ncyls              save it
*         ldb   PD.TYP-PD.OPT,x  disk device type
                    ldb       <dtype              get IT.TYP byte
                    andb      #TYPH.SSM           mask out all but sector size
                    leay      ssztbl,pcr
                    ldb       b,y
                    stb       <bps                and save bytes per sector
                    ldd       PD.SCT-PD.OPT,x     default sectors/track
                    std       <sectors            save it
                    ldd       PD.T0S-PD.OPT,x     default sectors/track tr00,s0
                    std       <sectors0           save it
                    ldb       PD.ILV-PD.OPT,x     sector interleave offset
                    stb       <interlv            save it
                    ldb       PD.SAS-PD.OPT,x     minimum sector allocation
                    stb       <sas                save it
                    ldb       #$01                default cluster size
                    stb       <clustsiz           save it
                    stb       <sectmode           and sector mode
*** ADDED CODE -- BGP.  CHECK FOR PRESENCE OF SS.DSIZE
                    lda       <dtype              get type byte
                    bita      #TYPH.DSQ           drive size query bit set?
                    beq       nogo@               no, don't bother querying the drive for its size
                    lda       <diskpath           get disk path number
                    ldb       #SS.DSize           disk size getstat
                    os9       I$GetStt            attempt
                    bcs       err@
                    sta       <bps                save bytes/sector
                    stb       <sectmode
                    tstb                          LBA mode?
                    bne       chs@
                    tfr       x,d
                    stb       <totsects           save result...
                    sty       <totsects+1
                    bra       nogo@
chs@
                    stx       <ncyls              save cylinders
                    stb       <numsides           save sides
                    sty       <sectors            save sectors/track
                    sty       <sectors0           save sectors/track 0
nogo@
                    clrb                          no error
                    rts                           return
err@                pshs      b
                    leax      CapErr,pcr
                    lda       #$02
                    ldy       #100
                    os9       I$WritLn
                    puls      b
                    lbra      PrtError

********************************************************************
* find a option and call, until all options are processed
********************************************************************

DoOpts              ldx       <u0022              option buffer
L0185               leay      >OptTbl,pcr         point to table
                    bsr       L019C               check for match?
                    bcs       L01A5               no, match
                    pshs      b,a                 save d register
                    ldd       $02,y               get offset value
                    leay      d,y                 make function address
                    puls      b,a                 restore d register
                    jsr       ,y                  call function
                    bcc       L0185               finished good?
                    lbra      Exit                no, exit
L019C               lda       ,x+                 get option character
L019E               cmpa      ,y                  is it in the table?
                    bne       L01A6               no, try the next one
                    ldb       $01,y               get return value
                    clra                          flag good
L01A5               rts                           return
L01A6               leay      $04,y               get next table location
                    tst       ,y                  is it the end of the table?
                    bne       L019E               no, try next location
                    coma                          yes, flag bad
                    rts                           return

********************************************************************
* option command table
********************************************************************

OptTbl
opt.1               fcc       /R/
                    fcc       /Y/
                    fdb       DoReady-opt.1
opt.2               fcc       /r/
                    fcc       /Y/
                    fdb       DoReady-opt.2
opt.3               fcc       /S/
                    fcc       / /
                    fdb       DoDsity-opt.3
opt.4               fcc       /s/
                    fcc       / /
                    fdb       DoDsity-opt.4
opt.5               fcc       /D/
                    fcc       /M/
                    fdb       DoDsity-opt.5
opt.6               fcc       /d/
                    fcc       /M/
                    fdb       DoDsity-opt.6
opt.7               fcc       /"/
                    fcb       $00
                    fdb       DoQuote-opt.7
opt.8               fcc       /:/
                    fcb       $00
                    fdb       DoColon-opt.8
opt.9               fcc       "/"
                    fcb       $00
                    fdb       DoClust-opt.9
opt.10              fcc       /1/
                    fcb       $01
                    fdb       Do1-opt.10
opt.11              fcc       /2/
                    fcb       $02
                    fdb       Do2-opt.11
opt.12              fcc       /'/
                    fcb       0
                    fdb       DoSQuote-opt.12
opt.13              fcc       /L/
                    fcb       $01
                    fdb       DoL-opt.13
opt.14              fcc       /l/
                    fcb       01
                    fdb       DoL-opt.14
opt.15              fcc       /(/
                    fcb       $00
                    fdb       DoLParen-opt.15
opt.16              fcc       /)/
                    fcb       $00
                    fdb       DoRParen-opt.16
opt.17              fcc       /,/
                    fcb       $00
                    fdb       DoComa-opt.17
opt.18              fcb       C$SPAC
                    fcb       00
                    fdb       DoSpace-opt.18

opt.19              fcb       'F
                    fcb       '                   '
                    fdb       DoFormat-opt.19
opt.20              fcb       'f
                    fcb       '                   '
                    fdb       DoFormat-opt.20
opt.21              fcc       /E/
                    fcb       $01
                    fdb       DoEnhanced-opt.21
opt.22              fcc       /e/
                    fcb       $01
                    fdb       DoEnhanced-opt.22


                    fcb       $00

********************************************************************
* S/D - density; single or double
********************************************************************

DoDsity             cmpb      <maxmfm             compare against maximum
                    bgt       OptAbort            if greater than, abort
                    cmpb      <t0sngdns
                    blt       OptAbort
                    stb       <mfm
                    clrb

********************************************************************
* skip white space
********************************************************************

DoComa
DoRParen
DoLParen
DoSpace             rts

********************************************************************
* set ready flag - skip warn messages
********************************************************************

DoReady             stb       <ready              set and save ready
                    rts                           return

********************************************************************
* 1/2 - number of sides
********************************************************************

Do2
Do1                 cmpb      <numsides
                    bgt       OptAbort
                    stb       <numsides
                    clrb
                    rts

********************************************************************
* only do a logical format on the rbf device
********************************************************************

DoL                 stb       <dolog              do a logical format
                    clrb                          did option
                    rts                           return

********************************************************************
* not a option - show abort message and exit
********************************************************************

OptAbort            leax      >AbortOp,pcr        Option not allowed message
                    lbra      PExit               print message and exit

********************************************************************
* double quoted option "disk name" save name in dskname
********************************************************************

DoQuote             leay      <dskname,u          delimited buffer
                    ldb       #C$SPAC             delimited size
koQuote             lda       ,x+                 delimited character
                    cmpa      #'"                 is end quote?
                    beq       L0221               must be done
                    sta       ,y+                 no, save character
                    decb                          decrement name size
                    bne       KoQuote             get all 32 of them or quote
L0215               ldb       ,x+                 next delimited character
                    cmpb      #'"                 find end quote?
                    beq       L0227               yes, back up and mark it
                    cmpb      #C$SPAC             skip space character?
                    bcc       L0215               yes, get next one
                    bra       L0227               no, mark it's end
L0221               lda       #C$SPAC             get space character
                    cmpb      #C$SPAC             any delimited characters?
                    beq       L022B               no, mark it's end
L0227               leay      -$01,y              yes, back up
                    lda       ,y                  get saved character
L022B               adda      #$80                make it negative
                    sta       ,y                  mark it's end
                    clrb                          did option
                    rts                           return

********************************************************************
* single quoted option 'number of cylinders' save number in ncyls
********************************************************************

DoSQuote            lbsr      Decimal             procces number of cylinders
                    ldd       <dresult            get it
                    std       <ncyls              save it
                    rts                           return

********************************************************************
* colon quoted option :interleave value: save value in interlv
********************************************************************

DoColon             lbsr      Decimal             proccess interleave value
                    ldd       <dresult            get it
                    tsta                          answer out of bounds?
                    beq       L0243               no, save it
                    ldb       #$01                yes, default size
L0243               stb       <interlv            save it
                    rts                           return

********************************************************************
* Format option : formatting a CoCo or a Dragon disk ?
********************************************************************

DoFormat
                    lda       ,x+                 Get next char
                    cmpa      #'D                 Do a dragon disk ?
                    beq       DoFmtDragon
                    cmpa      #'d
                    beq       DoFmtDragon
                    clr       IsDragon,u          Mark it as a normal CoCo (or other) disk
                    clrb
                    rts

DoFmtDragon
                    lda       #DragonFlag         Mark as Dragon disk
                    sta       IsDragon,u

                    ldd       #DragonBootSize     Setup additional system sectors
                    std       AddedSysSecs,u

                    clrb
                    rts

********************************************************************
* quoted option /cluster size/ save size in clustsiz
* cluster size is in decimal. The number of sectors
* in a cluster must be a power of 2 and the number
* should max out at 32 for coco os9
********************************************************************

DoClust             lbsr      Decimal             proccess cluster size
                    ldd       <dresult            get it
                    tsta                          answer out of bounds?
                    beq       L0250               no, save it
                    ldb       #$01                yes, default size
L0250               stb       <clustsiz           save it
                    stb       <clustspecified     save fact that cluster was specified
                    negb                          get two's complement
                    decb                          power of 2
                    andb      <clustsiz           in range?
                    beq       L025C               yes, skip ahead
                    ldb       #$01                no, default size
                    stb       <clustsiz           save it
L025C               clrb                          did option
L025D               rts                           return


DoEnhanced
                    stb       <IsSpec20
                    rts

********************************************************************
* print title, format (Y/N), and get response
********************************************************************

Proceed
*         leax  >Title,pcr       coco formatter message
*         lbsr  PrintLn          print it
                    tst       <dtype              disk type...
                    bmi       h@
                    lbsr      FloppySummary
                    bra       n@
h@                  lbsr      HDSummary
n@                  leay      >optbuf,u           point to option buffer
                    ldx       PD.T0S-PD.OPT,y     default sectors/track tr00,s0
                    tst       <mfm                double-density?
                    beq       L0271               no,
                    ldx       PD.SCT-PD.OPT,y     default sectors/track
L0271               stx       <sectors            save it
                    lbsr      LineFD
                    leax      >FmtMsg,pcr         formatting drive message
                    ldy       #FmtMLen            length of message
                    lbsr      Print               print it
                    leax      <prmbuf,u           input buffer
                    tfr       x,y                 put it in y
L0283               lda       ,y+                 get input
                    cmpa      #PENTIR             proceed (y/n)?
                    bne       L0283               no, wait for yes
                    pshs      y                   save input pointer
                    lda       #C$CR               carriage return
                    sta       -$01,y              store it over input
                    lbsr      PrintLn             print line
                    puls      y                   get pointer
                    lda       #PENTIR
                    sta       -$01,y
                    lda       <ready              ok to proceed? ready
                    bne       L02BC               yes, were ready skip ahead
*         tst   <dtype           is this a floppy or hard drive?
*         bpl   L02AB            it is a floppy
*         leax  >HDFmt,pcr       it is a hard drive
*         ldy   #$002A           length of message
*         lbsr  Print            print message
L02AB               leax      >Query,pcr          query message
                    ldy       #QueryLen           length of message
                    lbsr      Input               show it and get response (Y/N)
                    anda      #$DF                make it upper case
                    cmpa      #'Y                 answered yes?
                    bne       L02D5               no, check for no?
L02BC               tst       <dtype              formatting hard drive?
                    bpl       L025D               no, return skip hard disk warn message
                    leax      >HDFmt,pcr          show hard disk warn message
                    ldy       #HDFmtLen           size of the message
                    lbsr      Input               show it and get response (Y/N)
                    anda      #$DF                make it upper case
                    cmpa      #'Y                 answered yes?
                    beq       L025D               yes, return
                    clrb                          clear error
                    lbra      Exit                exit
L02D5               clrb                          clear error
                    cmpa      #'N                 answered no?
                    lbeq      Exit                yes, exit
                    bra       L02AB               no, get a (Y/N) answer

********************************************************************
* print usage message and return
********************************************************************

LineFD              leax      >CrRtn,pcr          point to line feed
PrintLn             ldy       #80                 size of message
Print               lda       #$01                standard output path
                    os9       I$WritLn            print line
                    rts                           return

********************************************************************
* print message and get response
* entry: x holds data address y holds data size
*  exit: a holds response (ascii character)
********************************************************************

Input               pshs      u,y,x,b,a           save registers
                    bsr       Print               print line
                    leax      ,s                  get data address
                    ldy       #$0001              data size
                    clra                          standard input
                    os9       I$Read              read it
                    lbcs      Exit                exit on error
                    bsr       LineFD              print line feed
                    puls      u,y,x,b,a           restore stack
                    anda      #$7F                make it ascii
                    rts                           return

********************************************************************
* get capability of the rbf device
********************************************************************

GetDTyp             leax      >hdsdat,pcr         assume hard drive data for now
                    stx       <trk0data           sector data pointer
                    ldb       <dtype              get disk drive type
                    bitb      #TYP.HARD+TYP.NSF   hard disk or non-standard type?
                    bne       L0323               yes, branch
                    tst       <cocofmt            is this a COCO formatted disk?
                    beq       L031B               branch if not
                    tst       <IsSpec20           is this a special coco formatted disk?
                    beq       cocodct
                    leax      >ectdat,pcr         point to enhanced CoCo track data
                    bra       L032D
cocodct             leax      >dctdat,pcr         point to COCO track data
                    bra       L032D
L031B               leax      >sgtdat,pcr         point to single density track data
                    tst       <mfm                double-density?
                    beq       L032D               no, save off X
L0323               stx       <trk0data
                    leax      >dbtdat,pcr
                    tst       <t0sngdns           track 0 is single density?
                    beq       L032F               branch if so
L032D               stx       <trk0data           save as track 0 data
L032F               stx       <trkdata            and !0 track data
                    tst       <sectmode           LBA values already in place?
                    beq       ack@
* Compute total sectors from C/H/S
                    clra
                    ldb       <numsides           get number of sides
                    tfr       d,y
                    clrb                          D = 0
                    ldx       <ncyls
                    bsr       Mulbxty             multiply B,X*Y
* B,X now is numsides * numcyls
* Subtract one from B,X because t0s will be added later
                    exg       d,x
                    subd      #$0001
                    bcc       L0344
                    leax      -$01,x
L0344               exg       d,x
                    ldy       <sectors
                    bsr       Mulbxty             multiply B,X*Y
* B,X now is numsides * numcyls * sectors
                    exg       d,x
* Add in sectors/track0
                    addd      <sectors0
                    std       <totsects+1
                    exg       d,x
                    adcb      #$00
                    stb       <totsects
ack@
                    lda       <dtype              get type byte
                    bita      #TYPH.DSQ           drive size query bit set?
                    beq       mlex                branch if so (we don't take bps into account here)
**** We now multiply totsects * the bytes per sector
                    dec       <bps                decrement bytes per sector (8=7,4=3,2=1,1=0)
                    beq       mlex                exit out ofloop if zero
ml@                 lsl       <totsects+2         else multiply by 2
                    rol       <totsects+1
                    rol       <totsects
                    lsr       <bps                shift out bits
                    tst       <bps
                    bne       ml@

************************************************
* Calculates the correct cluster size & size of bitmap in bytes

mlex                lda       #$08
                    pshs      a
                    ldx       <totsects+1
                    ldb       <totsects
                    bsr       Div24by8            divide totsects by 8
                    lda       <clustsiz           get current cluster size
                    pshs      a                   save it as divisor
                    bsr       Div24by8
                    tstb                          B = 0? (more than $FFFF bytes required ?)
                    beq       L0374               branch if so

* Too small a cluster size comes here
                    tst       <clustspecified     did user specify cluster on command line?
                    bne       u@                  branch if so (show error message)
                    lsl       <clustsiz           multiply by 2
                    bcs       u@                  if carry set to stop
                    leas      2,s                 else eat stack
                    bra       mlex                and continue trying
u@                  leax      >ClustMsg,pcr       cluster size mismatch message
                    lbsr      PrintLn             print mismatch message
                    lbra      L05B1               abort message and exit
L0374               leas      $02,s
                    stx       <NumBitmapBytes     Save Size of bitmap in bytes
                    rts                           return

********************************************************************
* multiply (mlbxty B:X * Y)
********************************************************************

Mulbxty             lda       #$08                make stack space
MulClr              clr       ,-s                 clear the space
                    deca                          cleared?
                    bne       MulClr              no,
                    sty       ,s
                    stb       $02,s
                    stx       $03,s
MulLoop             ldd       ,s                  we done?
                    beq       MulZer              yes, clean up
                    lsra
                    rorb
                    std       ,s
                    bcc       MulNoC
                    ldd       $03,s
                    addd      $06,s
                    std       $06,s
                    lda       $02,s
                    adca      $05,s
                    sta       $05,s
MulNoC              ldd       $03,s
                    lslb
                    rola
                    std       $03,s
                    lda       $02,s
                    rola
                    sta       $02,s
                    bra       MulLoop             continue rest
MulZer              leas      $05,s               clean up space
                    puls      pc,x,b              pop results, return

********************************************************************
* 24 bit divide (2,s = divisor, B:X = dividend, result in B:X)
********************************************************************

L03AE               pshs      x,b                 save X,B on stack
                    lsr       ,s                  divide B:X by 2
                    ror       $01,s
                    ror       $02,s
                    puls      x,b                 retrieve B:X
                    exg       d,x                 exchange bits 15-0 in D,X
                    adcb      #$00
                    adca      #$00
                    exg       d,x
                    adcb      #$00
Div24by8            lsr       $02,s
                    bne       L03AE
                    rts

********************************************************************
* format rbf device
********************************************************************

Format              tst       <dolog              doing a logical format?
                    bne       L03E4               yes, don't do this then
                    tst       <dtype              test for hard drive from PD.TYP
                    bpl       L03E5               branch if floppy
                    leax      >Both,pcr           PHYSICAL and LOGICAL? message
                    ldy       #BothLen            length of message
                    lbsr      Input               print and get input
                    anda      #$DF                make it upper case
                    cmpa      #'Y                 is it yes?
                    beq       L03E5               yes,
                    cmpa      #'N                 is it no?
                    bne       Format              no,
L03E4               rts                           return
L03E5               lda       <diskpath           device path number
                    ldb       #SS.Reset           reset device
                    os9       I$SetStt            at track zero
                    lbcs      Exit                exit if error
                    ldd       #$0000              get current track
                    std       <currtrak           save it
                    inca                          get current sector
                    sta       <currsect           save it
L03F8               clr       <currside           clear current side
L03FA               bsr       L045C
                    leax      >LSN0,u             point to our LSN0 buffer
                    ldd       <currtrak
                    addd      <u0048
                    tfr       d,u
                    clrb
                    tst       <cocofmt            do we format this as a COCO disk?
                    bne       L041B               branch if so
                    tst       <mfm                single density?
                    beq       L041D               branch if so
                    tst       <t0sngdns           track 0 single density?
                    bne       L041B               branch if not
                    tst       <currtrak+1         is current track 0?
                    bne       L041B               branch if not
                    tst       <currside           side is zero?
                    beq       L041D               branch if 0
L041B               orb       #$02                else set side 1
L041D               tst       <tpi                48 tpi?
                    beq       L0423               branch if so
                    orb       #$04                else set 96 tpi bit
L0423               lda       <currside           get current side
                    beq       L0429               branch if 0
                    orb       #$01
L0429               tfr       d,y                 get side/density bits
                    lda       <diskpath           rbf device path number
                    ldb       #SS.WTrk            format (write) track
                    os9       I$SetStt            do format it
                    lbcs      Exit                exit if error
                    ldu       <savedu             get u pointer
                    ldb       <currside           get current side
                    incb                          increment
                    stb       <currside           and store
                    cmpb      <numsides           compare against number of sides
                    bcs       L03FA               branch if greater than
                    ldd       <currtrak           get current track
                    addd      #$0001              increment it
                    std       <currtrak           save it
                    cmpd      <ncyls              did all tracks?
                    bcs       L03F8               no,
                    rts                           yes, return

********************************************************************
* Writes AA bytes of BB to X (byte pairs are in tables above)
********************************************************************

L044E               ldy       <u000E
L0451               ldd       ,y++                get two bytes at Y
                    beq       L046B               branch if zero (end)
L0455               stb       ,x+                 store B at X and post increment
                    deca                          decrement count
                    bne       L0455               continue if not done
                    bra       L0451               else get next byte pair
L045C               lda       <dtype              get drive's PD.TYP
                    bita      #TYP.HARD+TYP.NSF   hard disk or non-standard format?
                    beq       L046C               branch if neither
                    ldy       <trkdata            point Y to track data
                    leax      >LSN0,u             point to the LSN0 buffer
                    bsr       L0451               build LSN0 sector
L046B               rts

********************************************************************
*
********************************************************************

L046C               ldy       <trkdata            grab normal track data
                    ldb       <sectors+1          get sector
                    tst       <currtrak+1         track 0?
                    bne       L047E               branch if not
                    tst       <currside           side 0?
                    bne       L047E               branch if not
                    ldy       <trk0data
*         ldb   <u001C
                    ldb       <sectors0+1         get sectors in track 0
L047E               sty       <u000E
                    stb       <sectcount+1
                    stb       <u0018
                    bsr       L04EC
                    leax      >LSN0,u
                    bsr       L0451
                    sty       <u000E
L0490               bsr       L044E
                    dec       <sectcount+1
                    bne       L0490
                    lda       ,y+
                    sty       <u000E
                    stx       <u003D
                    leay      >u297E,u
                    sty       <dresult
                    tfr       a,b
L04A6               std       ,x++
                    cmpx      <dresult
                    bcs       L04A6
                    ldy       <u000E
                    ldd       ,y++
                    std       <u003F
                    ldd       ,y
                    std       <u0041
                    clr       <sectcount+1
                    leax      >LSN0,u
                    ldd       <u003F
                    leay      >u008F,u
L04C3               leax      d,x
                    ldd       <currtrak+1
                    adda      <toffs              add in track offset
                    std       ,x
                    ldb       <sectcount+1
                    lda       b,y
                    incb
                    stb       <sectcount+1
                    ldb       <currsect
                    adda      <soffs              add in sector offset
                    bcs       L04E5
                    std       $02,x
                    lda       <sectcount+1
                    cmpa      <u0018
                    bcc       L04E4
                    ldd       <u0041
                    bra       L04C3
L04E4               rts

********************************************************************
*
********************************************************************

L04E5               leax      >AbortSct,pcr       sector number out of range message
                    lbra      PExit               print message and exit

********************************************************************
*
********************************************************************

L04EC               pshs      y,b
                    tfr       b,a
                    ldb       <currtrak+1
                    cmpb      #$01
                    bhi       L0518
                    leax      >u008F,u
                    leay      a,x
                    ldb       <interlv
                    bne       L0507
L0500               leax      >AbortIlv,pcr       Interleave out of range message
                    lbra      PExit               print message and exit
L0507               cmpb      <u0018
                    bhi       L0500
                    nega
                    pshs      y,x,b,a
                    clra
L050F               sta       ,x
                    inca
                    cmpa      <u0018
                    bne       L051A
                    leas      $06,s
L0518               puls      pc,y,b
L051A               ldb       <interlv
                    abx
                    cmpx      $04,s
                    bcs       L0525
                    ldb       ,s
                    leax      b,x
L0525               cmpx      $02,s
                    bne       L050F
                    leax      $01,x
                    stx       $02,s
                    bra       L050F

********************************************************************
* initialize sector 0
********************************************************************

InitLSN0            lbsr      ClrBuf              clear the sector buffer
                    ldd       <totsects+1         get total sectors bits 15-0
                    std       DD.TOT+1,x          save
                    ldb       <totsects           get bits 23-16
                    stb       DD.TOT,x            save
                    ldd       <sectors            get sectors/track
                    std       <DD.SPT,x           save
                    stb       DD.TKS,x            save
                    lda       <clustsiz           get cluster size
                    sta       DD.BIT+1,x          save

                    clra
                    ldb       <NumBitmapBytes     Calculate number of bitmap sectors needed
                    tst       <NumBitmapBytes+1   Exact multiple of sector size ?
                    beq       L054F               Yes no extra sectors needed
                    addd      #$0001              Add extra sector for bytes at end
L054F               addd      #$0001
                    addd      AddedSysSecs,u      Add additional system sectors (usually 0)
                    std       DD.DIR+1,x          save directory sector

                    clra
                    tst       <mfm                single density?
                    beq       L0561               branch if so
                    ora       #FMT.DNS            else set double density bit
                    tst       <t0sngdns           track 0 is single density?
                    beq       L0561               branch if so
*         ora   #FMT.T0DN
                    ora       #$08
L0561               ldb       <numsides           get number of sides
                    cmpb      #$01                just 1?
                    beq       L0569               branch if so
                    ora       #FMT.SIDE           else set double-sided bit
L0569               tst       <tpi                48tpi?
                    beq       L056F               branch if so
                    ora       #FMT.TDNS           else set 96 tpi
L056F               sta       <DD.FMT,x           save
                    ldd       <NumBitmapBytes     get size of bitmap in bytes
                    std       DD.MAP,x            save number of bytes in allocation bit map
                    lda       #$FF                attributes
                    sta       DD.ATT,x            save
                    leax      >LSN0+DD.DAT,u      point to time buffer
                    os9       F$Time              get current time
                    leax      >LSN0+DD.NAM,u
                    leay      <dskname,u          quote delimited disk name buffer
                    tst       ,y                  name in buffer?
                    beq       L0594               branch if not
L058C               lda       ,y+                 get character of name
                    sta       ,x+                 and save in name area of LSN0
                    bpl       L058C
                    bra       L05C7
* Here we prompt for a disk name
L0594               leax      >DName,pcr
                    ldy       #DNameLen
                    lbsr      Print               print disk name prompt
                    leax      >LSN0+DD.NAM,u      point to new name
                    ldy       #33                 read up to 33 characters
                    clra
                    os9       I$ReadLn            from standard input
                    bcc       L05B8               branch if ok
                    cmpa      #E$EOF              end of file?
                    bne       L0594               branch if not
L05B1               leax      >Aborted,pcr        format aborted message
                    lbra      PExit               print message and exit
L05B8               tfr       y,d                 copy number of chars entered into D
                    leax      d,x                 point to last char + 1
                    clr       ,-x
                    decb                          decrement chars typed
                    beq       L0594               branch if zero (go ask again)
                    lda       ,-x                 get last character
                    ora       #$80                set hi bit
                    sta       ,x                  and save
L05C7               leax      >LSN0+DD.DAT,u      point to time
                    leay      <$40,x
                    pshs      y
                    ldd       #$0000
L05D3               addd      ,x++
                    cmpx      ,s
                    bcs       L05D3
                    leas      $02,s
                    std       >LSN0+DD.DSK,u      save disk ID

                    lda       IsDragon,u          Do we need to fixup for dragon ?
                    cmpa      #DragonFlag
                    bne       Nofixup
                    bsr       FixForDragon        Adjust for Dragon disk format

NoFixup
* Not sure what this code is for...
*         ldd   >val1,pcr
*         std   >u01A7,u
*         ldd   >val2,pcr
*         std   >u01A9,u
*         ldd   >val3,pcr
*         std   >u01AB,u
                    lda       <diskpath
                    ldb       #SS.Opt
                    leax      >LSN0+DD.OPT,u      point to disk options
                    os9       I$GetStt            get options
                    ldb       #SS.Reset           reset head to track 0
                    os9       I$SetStt            do it!
                    lbcs      Exit                branch if error
                    leax      >LSN0,u             point to LSN0
                    lbra      WritSec             and write it!


********************************************************************
* Adjust LSN0 values so we make a Dragon OS-9 compatible disk
********************************************************************

FixForDragon
                    pshs      x
                    leax      LSN0,u              Point at LSN0

                    lda       dtype,u             Get disk type
                    bita      #TYP.CCF            CoCo/Dragon format disk ?
                    beq       DgnNoFix            Nope, don't adjust

                    ldd       DD.MAP,x            Fixup map
                    cmpd      #$ff                Dragon disks have only one bitmap sector
                    bls       DgnMapOK            only using 1, don't adjust
                    lsra                          Divide map count by 2
                    rorb
                    std       DD.MAP,x
                    inc       DD.BIT+1,x          Increment cluster size to 2

                    stb       <clustsiz           Update local cluster size var

DgnMapOK
DgnNoFix
                    puls      x,pc


********************************************************************
* read in sector 0 of device
********************************************************************

ReadLSN0            lda       <diskpath           get disk path
                    os9       I$Close             close it
                    leax      <prmbuf,u           point to device name
                    lda       #READ.
                    os9       I$Open              open for read
                    lbcs      BadSect             branch if problem
                    sta       <diskpath           save new disk path
                    leax      >LSN0,u
                    ldy       #256
                    os9       I$Read              read first sector
                    lbcs      BadSect             branch if problem
                    lda       <diskpath           get disk path
                    os9       I$Close             close path to device
                    leax      <prmbuf,u           re-point to device name
                    lda       #UPDAT.
                    os9       I$Open              open in read/write mode
                    lbcs      BadSect             branch if error
                    sta       <diskpath           else save new disk path

* Save location of start of root directory, for later use
                    leax      LSN0,u              point to LSN0
                    lda       DD.DIR,x            Get location of root
                    ldx       DD.DIR+1,x
                    sta       SaveRootLSN,u       Save a copy for later use
                    stx       SaveRootLSN+1,u
                    rts                           and return

********************************************************************
* Make Bitmap Sectors
********************************************************************

MkBMap              lda       <dtype              get device type in A
                    clr       <dovfy              clear verify flag
                    bita      #TYP.HARD           hard drive?
                    beq       nothd               branch if not
* Hard drives are asked for physical verification here
askphys             leax      >Verify,pcr
                    ldy       #VerifyL
                    lbsr      Input               prompt for physical verify of hard drive
                    anda      #$DF
                    cmpa      #'Y                 yes?
                    beq       nothd               branch if so
                    cmpa      #'N                 no?
                    bne       askphys             not not, ask again
                    sta       <dovfy              else flag that we don't want physical verify
nothd               ldd       <sectors0           get sectors/track at track 0
                    std       <u0017              save
                    clra                          D = 0
                    clrb
                    sta       <oksects            clear OK sectors
                    std       <oksects+1
                    std       <currtrak           clear current track
                    std       <sectcount          clear counted sectors
                    std       <u0032
                    stb       <u0031
                    sta       <u003C
                    leax      >optbuf,u
                    stx       <u0038
                    lbsr      ClrSec
                    leax      256,x
                    stx       <u003A
                    clra
                    ldb       #$01                D = 1
                    std       <u0034
                    lda       <clustsiz           get cluster size
                    sta       <clustcnt           store in cluster counter
                    clr       <u002A

* Calculate the number of reserved clusters at begining of disk, from
* number of reserved sectors
                    clra
                    ldb       <NumBitmapBytes     Get no of sectors used by bitmap
                    tst       <NumBitmapBytes+1   Exact number of sectors in bitmap ?
                    beq       L069D               Yes : skip
                    addd      #$0001              No : round up sector count
L069D               addd      #$0009              Add 8 sectors for root FD (IT.SAS) + 1 sector for LSN0
                    addd      AddedSysSecs,u      Add additional system sectors (if any)
                    std       <NoSysSectors
                    std       <NoSysClusters
                    lda       <clustsiz           get cluster size

* Since cluster sizes can only be a power of 2 (1,2,4,8,16 etc) we divide block count
* by 2 until we get a carry, this gives us the cluster count

L06A4               lsra
                    bcs       L06B5               First calculate number of system clusters
                    lsr       <NoSysClusters
                    ror       <NoSysClusters+1
                    bcc       L06A4
                    inc       <NoSysClusters+1
                    bne       L06A4
                    inc       <NoSysClusters
                    bra       L06A4

L06B5
                    ldd       <NoSysSectors
*         ldd   <NoSysSectors
*         std   <NoSysClusters	Save No of clusters
*         lda   <clustsiz        get cluster size
*         mul   			Now work out number of system sectors
*         std   <NoSysSectors	Save it

                    subd      #$0001              Calculate number of sectors in root FD ?
                    subd      AddedSysSecs,u      Remove additional system sectors (if any)
                    subb      <NumBitmapBytes
                    sbca      #$00
                    tst       <NumBitmapBytes+1
                    beq       L06CC
                    subd      #$0001

L06CC               stb       <NoRootFDSecs

L06CE               tst       <dovfy              do we verify?
                    bne       OutScrn             no, output screen display
                    lda       <diskpath           yes, get rbf device path
                    leax      >LSN0,u             get sector buffer
                    ldy       #256                sector size
                    os9       I$Read              read of sector successful?
                    bcc       OutScrn             yes, output screen display
                    os9       F$PErr              no, print error message
                    lbsr      NextSec             get next sector
                    lda       #$FF
                    sta       <u002A
                    tst       <u0031
                    bne       OutScrn             output screen display
                    ldx       <u0032
                    cmpx      <NoSysSectors
                    bhi       OutScrn             output screen display
BadSect             leax      >BadSectM,pcr       bad system sector message
PExit               lbsr      PrintLn             print message
                    clrb                          clear error
                    lbra      Exit                exit no error

********************************************************************
* output screen display scrolling track counter
********************************************************************

OutScrn             ldd       <sectcount          get counted sectors
                    addd      #$0001              increment it
                    std       <sectcount          save counted sectors
                    cmpd      <u0017              good sector count?
                    bcs       L0745               next segment
                    clr       <sectcount          clear counted sectors
                    clr       <sectcount+1
                    tst       <dovfy              are we verifying?
                    bne       L073A               no,
                    lda       #C$SPAC             yes, get space
                    pshs      a                   save it
                    lda       <currtrak+1         track high byte
                    lbsr      HexDigit            make it ascii
L0724               pshs      b,a                 save two ascii digits
                    lda       <currtrak           track low byte
                    lbsr      HexDigit            make it ascii
                    pshs      b,a                 save two ascii digits
                    lda       #C$CR               get CR
                    pshs      a
                    tfr       s,x                 get output from stack
                    ldy       #$0006              length of output
*         lbsr  Print            print it
                    lda       #$01
                    os9       I$Write
*         lda   $02,s
*         cmpa  #$46             end of line?
*         bne   L0738            skip line feed
*         lbsr  LineFD           print linefeed
L0738               leas      $06,s               pop output off stack
L073A               ldd       <currtrak           get current track
                    addd      #$0001              increment it
                    std       <currtrak           save it back
                    ldd       <sectors            get number of sectors
                    std       <u0017              save it
L0745               dec       <clustcnt           decrement cluster counter
                    bne       L075B
                    bsr       L0784
                    tst       <u002A
                    bne       L0755
                    ldd       <oksects+1          increment good sectors
                    addd      #$0001
                    std       <oksects+1
                    bcc       L0755
                    inc       <oksects
L0755               clr       <u002A
                    lda       <clustsiz           get cluster size
                    sta       <clustcnt           save in cluster counter
L075B               ldb       <u0031
                    ldx       <u0032
                    leax      $01,x
                    bne       L0764
                    incb
L0764               cmpb      <totsects
                    bcs       L076C
                    cmpx      <totsects+1
                    bcc       L0773
L076C               stb       <u0031
                    stx       <u0032
                    lbra      L06CE
L0773               lda       #$FF
                    sta       <u002A
                    leay      >optbuf,u
L077B               cmpy      <u0038
                    beq       GoodSect            number of good sectors summary
                    bsr       L0784
                    bra       L077B
L0784               ldx       <u0038
                    lda       <u002A
                    rora
                    rol       ,x+
                    inc       <u003C
                    lda       <u003C
                    cmpa      #$08
                    bcs       L07A6
                    clr       <u003C
                    stx       <u0038
                    cmpx      <u003A
                    bne       L07A6
                    bsr       WrtSecs
                    leax      >optbuf,u
                    stx       <u0038
                    lbsr      ClrSec
L07A6               rts                           return

********************************************************************
* convert byte to ascii hexadecimal and return it in d register
********************************************************************

HexDigit            tfr       a,b                 get byte again
                    lsra                          shift upper digit
                    lsra
                    lsra
                    lsra
                    andb      #$0F                mask lower digit
                    addd      #$3030              make it ascii
                    cmpa      #$39                upper digit > 9
                    bls       L07B8               no,
                    adda      #$07                yes, make hexadecimal
L07B8               cmpb      #$39                lower digit > 9
                    bls       L07BE               no,
                    addb      #$07                yes, make hexadecimal
L07BE               rts                           return

********************************************************************
* number of good sectors message
********************************************************************

GoodSect            lbsr      LineFD              print line feed
                    leax      >NumGood,pcr        number of good sectors
                    ldy       #NGoodLen           length of message
                    lbsr      Print               print it
                    ldb       <clustsiz           get cluster size
                    lda       <oksects            get  24 bit counter
                    ldx       <oksects+1
                    pshs      x,a                 save 24 bit counter
L07D4               lsrb                          carry set 0xxx xxxx  ->  X ?
                    bcs       L07DF               yes,
                    lsl       $02,s               <u0036 1  X  <- nnnn nnnn  X  <- xxxx xxx0
                    rol       $01,s               <u0036 2  N  <- nnnn nnnX  N  <- xxxx xxx0
                    rol       ,s                  <u0036 3  N  <- nnnn nnnN
                    bra       L07D4               did all sectors?
L07DF               puls      x,a                 get counted sectors
                    ldb       #C$CR
                    pshs      b                   save enter
                    tfr       d,y                 get size
                    tfr       x,d                 get
                    tfr       b,a                 get convert byte
                    bsr       HexDigit            convert it BYTE 1
                    pshs      b,a                 save in buffer
                    tfr       x,d                 get convert byte
                    bsr       HexDigit            convert it BYTE 2
                    pshs      b,a                 save in buffer
                    tfr       y,d                 get convert byte
                    bsr       HexDigit            convert it BYTE 3
                    pshs      b,a                 save it buffer
                    tfr       s,x                 get output buffer
                    lbsr      PrintLn             print it
                    leas      $07,s               fix stack
                    rts                           return

********************************************************************
* get allocation bit map and write sectors
********************************************************************

WrtSecs
                    pshs      y                   save register
                    clra                          set number
                    ldb       #$01                bits to set
                    cmpd      <u0034              map sector?
                    bne       L081E               yes, write sector
                    leax      >optbuf,u           allocation bit map
                    clra                          get number
                    ldy       <NoSysClusters      system sectors
*         tfr   d,y              into register
                    clrb                          first bit to set
                    os9       F$AllBit            set allocation bit map
                    lbcs      BadSect             if there a error
L081E               lbsr      GetSec              get sector
                    leax      >optbuf,u           allocation bit map
                    lbsr      WritSec             write sector
                    ldd       <totsects           get total sectors
                    cmpd      <u0031              lsn sector count?
                    bcs       AdvSec              advance to mapped sectors
                    bhi       NxtSec              get next sector
                    ldb       <totsects+2         get LSB total sectors
                    cmpb      <u0033              good sector count?
                    bcc       AdvSec              advance to mapped sectors
NxtSec              lbsr      NextSec             skip to next sector
AdvSec              ldd       <u0034              get mapped sectors
                    addd      #$0001              count from one
                    std       <u0034              save mapped sectors count
                    puls      pc,y                restore and return

********************************************************************
* create root directory file descriptor
********************************************************************

MkRootFD            lbsr      GetSec              get sector
                    leax      >fdtbuf1,u          sector buff
                    lbsr      ClrSec              clear sector
                    leax      >fdtbuf2,u          get date last modified
                    os9       F$Time              get system time
                    leax      >fdtbuf1,u          get file descriptor
                    lda       #DIR.+PEXEC.+PWRIT.+PREAD.+EXEC.+UPDAT.
                    sta       FD.ATT,x            save in FD.ATT
                    lda       #$02                get link count
                    sta       FD.LNK,x            save in FD.LNK
                    clra                          directory size
                    ldb       #DIR.SZ*2           directory entries (DIR.SZ*2)
                    std       FD.SIZ+2,x          save it           (FD.SIZ+2)
                    ldb       <NoRootFDSecs
                    decb
                    stb       <FD.SEG+FDSL.B+1,x  save it  (c+FDSL.B+1)
*         ldd   <u0034

                    ldd       SaveRootLSN+1,u     Get saved root dir LSN

                    addd      #$0001
                    std       <FD.SEG+FDSL.A+1,x  save it  (FD.SEG+FDSL.A+1)
                    bsr       SeekRootLSN
                    bsr       WritSec
                    bsr       ClrBuf
                    ldd       #$2EAE              (#'.*256+'.+128)
                    std       DIR.NM,x            (DIR.NM)
                    stb       <DIR.SZ+DIR.NM,x    (DIR.NM+DIR.SZ)
*         ldd   <u0034

                    ldd       SaveRootLSN+1,u     Get saved root dir LSN

                    std       <DIR.FD+1,x
                    std       <DIR.SZ+DIR.FD+1,x
                    bsr       WritSec
                    bsr       ClrBuf
                    ldb       <NoRootFDSecs
                    decb                          make zero offset (0 - 255)
NextCnt             decb                          decrement sector count
                    bne       NextWrt             if more to do
                    rts                           else return
NextWrt             pshs      b                   save sector count
                    bsr       WritSec             write the sector
                    puls      b                   get count back
                    bra       NextCnt             do until done

********************************************************************
* Get root dir first LSN
********************************************************************

*GetRootLSN
*	 pshs	x		Retrieve start of Dir from LSN0
*	 leax	LSN0,u
*	 ldd	DD.DIR+1,x
*	 puls	x
*
*	rts

********************************************************************
* Seek to Root LSN
********************************************************************

SeekRootLSN
                    pshs      d,x,u

                    ldx       SaveRootLSN,u       msw of pos
                    lda       SaveRootLSN+2,u     lsw
                    clrb
                    tfr       d,u
                    lbsr      SeekSec

                    puls      d,x,u,pc

********************************************************************
* clear the 256 byte sector buffer
********************************************************************

ClrBuf              leax      >LSN0,u             sector buffer
ClrSec              clra                          store mask
                    clrb                          sector count
ClrLop              sta       d,x                 clear the buffer
                    decb                          decrement sector count
                    bne       ClrLop              clear sector buffer
                    rts                           return when done

********************************************************************
* write physical 256 byte sector to the diskette
********************************************************************

WritSec             lda       <diskpath           get path number
                    ldy       #256                get sector size
                    os9       I$Write             write the sector
                    lbcs      Exit                exit on error
                    rts                           return

********************************************************************
* get sector file position
********************************************************************

GetSec              clra
                    ldb       <u0034              get map sectors high word
                    tfr       d,x                 save it
                    lda       <u0035
                    clrb                          get map sectors low  word
                    tfr       d,u                 save it

********************************************************************
* seek to physical sector
********************************************************************

SeekSec             lda       <diskpath           get path number
                    os9       I$Seek              seek to sector
                    ldu       <savedu             get data pointer
                    lbcs      Exit                exit if error
                    rts                           return

********************************************************************
* skip to the next sector
********************************************************************

NextSec             ldx       <u0031              lsn count
                    lda       <u0033              good sector count
                    clrb                          add this
                    addd      #$0100              sector
                    tfr       d,u                 lsn count
                    bcc       SeekSec             seek it?
                    leax      $01,x               next sector
                    bra       SeekSec             seek it

********************************************************************
* the format module never gets to this code?
********************************************************************

                    ldd       ,y
                    leau      >LSN0,u
                    leax      >dcnums,pcr         decimal number conversion table
                    ldy       #$2F20

********************************************************************
*
********************************************************************

L08E6               leay      >$0100,y
                    subd      ,x
                    bcc       L08E6
                    addd      ,x++
                    pshs      b,a
                    ldd       ,x
                    tfr       y,d
                    beq       L090E
                    ldy       #$2F30
                    cmpd      #$3020
                    bne       L0908
                    ldy       #$2F20
                    tfr       b,a
L0908               sta       ,u+
                    puls      b,a
                    bra       L08E6
L090E               sta       ,u+
                    lda       #C$CR
                    sta       ,u
                    ldu       <savedu
                    leas      $02,s
                    leax      >LSN0,u
                    lbsr      PrintLn
                    rts

dcnums              fdb       10000,1000,100,10,1,0

********************************************************************
*  process decimal number input (65535)
********************************************************************

Decimal             ldd       #$0000              start at zero
L092F               bsr       DecBin              get first digit
                    bcs       L0939               if overflow
                    bne       L092F               get next digit
                    std       <dresult            save decimal as binary
                    bne       L093E               if no error return
L0939               ldd       #$0001              flag error
                    std       <dresult            save it
L093E               rts                           return

********************************************************************
* process decimal number into it's binary representation
* return with binary in the d register
********************************************************************

DecBin              pshs      y,b,a               save registers
                    ldb       ,x+                 get digit
                    subb      #$30                make it binary
                    cmpb      #$0A                bla bla bla!
                    bcc       L095D
                    lda       #$00
                    ldy       #$000A
L094F               addd      ,s
                    bcs       L095B
                    leay      -$01,y
                    bne       L094F
                    std       ,s
                    andcc     #^Zero
L095B               puls      pc,y,b,a
L095D               orcc      #Zero
                    puls      pc,y,b,a

********************************************************************
* print error, usage message, and exit
********************************************************************

PrtError            lda       #$02                standard error
                    os9       F$PErr              print error
                    ifne      DOHELP
                    leax      <HelpMsg,pcr        point to usage
                    ldy       #HelpLen            usage size
                    lda       #$02                standard error
                    os9       I$WritLn            print usage
                    endc
                    clrb                          no error
                    os9       F$Exit              exit module

********************************************************************
* messages
********************************************************************

*Title    fcb   C$LF
*         fcc   "COLOR COMPUTER FORMATTER"
*HelpCR   fcb   C$CR
                    ifne      DOHELP
HelpMsg             fcc       "Use: FORMAT /devname <opts>"
                    fcb       C$LF
                    fcc       "  opts: R   - Ready"
                    fcb       C$LF
                    fcc       "        S/D - density; single or double"
                    fcb       C$LF
                    fcc       "        L   - Logical format only"
                    fcb       C$LF
                    fcc       /        "disk name"/
                    fcb       C$LF
                    fcc       "        1/2 - number of sides"
                    fcb       C$LF
                    fcc       "        'No. of cylinders'   (in decimal)"
                    fcb       C$LF
                    fcc       "        :Interleave value:   (in decimal)"
                    fcb       C$LF
                    fcc       "        /Cluster size/       (in decimal)"
                    fcb       C$LF
                    fcc       "        FD - Dragon format disk"
                    fcb       C$CR
                    fcc       "        E  - Enhanced CoCo 20 SPT"
                    fcb       C$CR
HelpLen             equ       *-HelpMsg
                    endc
FmtMsg              fcc       "Formatting device: "
FmtMLen             equ       *-FmtMsg
Query
*         fcc   "y (yes) or n (no)"
*         fcb   C$LF
                    fcc       "Ready?  "
QueryLen            equ       *-Query
CapErr              fcc       "ABORT can't get media capacity"
                    fcb       C$CR
AbortIlv            fcc       "ABORT Interleave value out of range"
                    fcb       C$CR
AbortSct            fcc       "ABORT Sector number out of range"
                    fcb       C$CR
AbortOp             fcc       "ABORT Option not allowed on Device"
                    fcb       C$CR
DName               fcc       "Disk name: "
DNameLen            equ       *-DName
                    fcc       "How many Cylinders (Tracks?) : "
BadSectM            fcc       "Bad system sector, "
Aborted             fcc       "FORMAT ABORTED"
                    fcb       C$CR
ClustMsg            fcc       "Cluster size mismatch"
CrRtn               fcb       C$CR
*         fcc   "Double density? "
*         fcc   "Track 0 Double density? "
*TPIChg   fcc   "Change from 96tpi to 48tpi? "
*DSided   fcc   "Double sided? "
NumGood             fcc       "Number of good sectors: $"
NGoodLen            equ       *-NumGood
HDFmt               fcc       "This is a HARD disk - are you sure? "
*HDFmt    fcc   "WARNING: You are formatting a HARD Disk.."
*         fcb   C$LF
*         fcc   "Are you sure? "
HDFmtLen            equ       *-HDFmt
Both                fcc       "Both PHYSICAL and LOGICAL format? "
BothLen             equ       *-Both
Verify              fcc       "Physical Verify desired? "
VerifyL             equ       *-Verify
SUMH
                    fcb       C$CR,C$LF
                    fcc       "      NitrOS-9 RBF Disk Formatter"
                    fcb       C$CR,C$LF
                    fcc       "------------  Format Data  ------------"
                    fcb       C$CR,C$LF
*         fcb   C$CR,C$LF
*         fcc   "Fixed values:"
                    fcb       C$CR,C$LF
SUMHL               equ       *-SUMH
FMT                 fcc       "      Floppy Disk Format: "
FMTL                equ       *-FMT
TOF                 fcc       "            Track Offset: "
TOFL                equ       *-TOF
SOF                 fcc       "           Sector Offset: "
SOFL                equ       *-SOF
PFS                 fcc       "    Physical floppy size: "
PFSL                equ       *-PFS
DC                  fcc       "           Disk capacity: "
DCL                 equ       *-DC
CSZ                 fcc       "            Cluster size: "
CSZL                equ       *-CSZ
*SSZ      fcc   "             Sector size: "
*SSZL     equ   *-SSZ
SST                 fcc       "           Sectors/track: "
SSTL                equ       *-SST
TZST                fcc       "     Track zero sect/trk: "
TZSTL               equ       *-TZST
*LSNOF    fcc   "              LSN offset: $"
*LSNOFL   equ   *-LSNOF
TPC                 fcc       "Total physical cylinders: "
TPCL                equ       *-TPC
MSA                 fcc       " Minimum sect allocation: "
MSAL                equ       *-MSA
RF                  fcc       "        Recording format: "
RFL                 equ       *-RF
TD                  fcc       "    Track density in TPI: "
TDL                 equ       *-TD
NLC                 fcc       "Number of log. cylinders: "
NLCL                equ       *-NLC
NS                  fcc       "      Number of surfaces: "
NSL                 equ       *-NS
SI                  fcc       "Sector interleave offset: "
SIL                 equ       *-SI
SCTS                fcc       " sectors"
                    fcb       C$CR
SPPR                fcc       "                         ("
SPPRL               equ       *-SPPR
PRSP                fcc       " bytes)"
                    fcb       C$CR
PRSPL               equ       *-PRSP
_CoCo               fcc       !CoCo!
                    fcb       C$CR
_Dragon             fcc       !Dragon!
                    fcb       C$CR
Standard            fcc       !Standard OS-9!
                    fcb       C$CR
Three5              fcc       !3 1/2"!
                    fcb       C$CR
FiveQ               fcc       !5 1/4"!
                    fcb       C$CR
_MFM                fcc       /M/
FM                  fcc       /FM/
                    fcb       C$CR
TPI48               fcc       /48/
                    fcb       C$CR
TPI96               fcc       !96!
                    fcb       C$CR
TPI135              fcc       !135!
                    fcb       C$CR


HDSummary
                    bsr       ShowHeader
                    lbsr      ShowDiskCapacity
                    ldb       <dtype
                    andb      #TYPH.DSQ
                    bne       o@
                    lbsr      ShowSectorsTrack
                    lbsr      ShowSectorsTrackZero
                    lbsr      ShowNumberSurfaces
                    lbsr      ShowTotalPhysCylinders
o@                  lbsr      ShowClusterSize
                    lbsr      ShowSAS
                    rts

FloppySummary
                    bsr       ShowHeader
                    bsr       ShowDiskType
                    bsr       ShowPhysFloppy
                    lbsr      ShowSectorsTrack
                    lbsr      ShowSectorsTrackZero
                    lbsr      ShowTotalPhysCylinders
                    lbsr      ShowTrackOffset
                    lbsr      ShowSectorOffset
                    lbsr      ShowSAS
                    lbsr      ShowRecordingFormat
                    lbsr      ShowTrackDensity
                    lbsr      ShowNumberLogCylinders
                    lbsr      ShowNumberSurfaces
                    lbsr      ShowSectorInterleaveOffset
                    rts

ShowHeader
                    lda       #$01
                    leax      SUMH,pcr
                    ldy       #SUMHL
                    os9       I$Write
                    rts

ShowDiskType
                    leax      FMT,pcr
                    ldy       #FMTL
                    os9       I$Write
                    ldb       <dtype
                    leax      _CoCo,pcr
                    bitb      #TYP.CCF
                    bne       n@
t@                  leax      Standard,pcr
                    bra       s@
n@                  ldb       IsDragon,u          Get dragon flag
                    cmpb      #DragonFlag         Dragon disk ?
                    bne       s@
                    leax      _Dragon,pcr
s@                  ldy       #80
                    os9       I$WritLn
                    rts

ShowPhysFloppy
                    leax      PFS,pcr
                    ldy       #PFSL
                    os9       I$Write
                    ldb       <dtype
                    leax      FiveQ,pcr
                    bitb      #TYP.3
                    beq       n@
t@                  leax      Three5,pcr
n@                  ldy       #80
                    os9       I$WritLn
                    rts

ShowDiskCapacity
                    leax      DC,pcr
                    ldy       #DCL
                    os9       I$Write
                    clra
                    ldb       <totsects
                    std       <tmpnum
                    ldd       <totsects+1
                    std       <tmpnum+2
                    leax      <tmpnum,u
                    leay      numbuf,u
                    lbsr      itoa
* X points to buffer, Y holds size
                    pshs      x
                    tfr       y,d
                    leax      d,x
* X points at character after last member
                    leay      SCTS,pcr
go@                 lda       ,y+
                    sta       ,x+
                    cmpa      #C$CR
                    bne       go@
                    puls      x
                    ldy       #80
                    lda       #$01
                    os9       I$WritLn
* Put out leading spaces and (
                    leax      SPPR,pcr
                    ldy       #SPPRL
                    os9       I$Write
* Copy number from totsects
                    clra
                    ldd       totsects,u
                    std       tmpnum,u
                    lda       totsects+2,u
                    clrb
                    std       tmpnum+2,u
                    leax      <tmpnum,u
                    leay      numbuf,u
                    lbsr      itoa
* X points to the ASCII number
* Y holds length
                    lda       #$01
                    os9       I$Write
                    leax      PRSP,pcr
                    ldy       #PRSPL
                    os9       I$WritLn
                    rts

ShowSectorsTrack
                    leax      SST,pcr
                    ldy       #SSTL
                    os9       I$Write
                    ldd       <sectors
                    lbra      PrintNum

ShowTrackOffset
                    leax      TOF,pcr
                    ldy       #TOFL
                    os9       I$Write
                    clra
                    ldb       <toffs
                    lbra      PrintNum

ShowSectorOffset
                    leax      sOF,pcr
                    ldy       #SOFL
                    os9       I$Write
                    clra
                    ldb       <soffs
                    lbra      PrintNum

ShowSectorsTrackZero
                    leax      TZST,pcr
                    ldy       #TZSTL
                    os9       I$Write
                    ldd       <sectors0
                    lbra      PrintNum

ShowTotalPhysCylinders
                    leax      TPC,pcr
                    ldy       #TPCL
                    os9       I$Write
                    ldd       <ncyls
                    lbra      PrintNum

ShowClusterSize
                    leax      CSZ,pcr
                    ldy       #CSZL
                    os9       I$Write
                    clra
                    ldb       <clustsiz
                    lbra      PrintNum

ShowSAS
                    leax      MSA,pcr
                    ldy       #MSAL
                    os9       I$Write
                    clra
                    ldb       <sas
                    lbra      PrintNum

ShowRecordingFormat
                    leax      RF,pcr
                    ldy       #RFL
                    os9       I$Write
                    leax      _MFM,pcr
                    tst       <mfm
                    bne       n@
                    leax      FM,pcr
n@                  ldy       #80
                    os9       I$WritLn
                    rts

ShowTrackDensity
                    leax      TD,pcr
                    ldy       #TDL
                    os9       I$Write
                    leax      TPI135,pcr
                    ldb       <dtype
                    lsrb
                    bcs       n@
x@                  leax      TPI48,pcr
                    ldb       <dns
                    bitb      #DNS.DTD
                    beq       n@
                    leax      TPI96,pcr
n@                  ldy       #80
                    os9       I$WritLn
                    rts

ShowNumberLogCylinders
                    leax      NLC,pcr
                    ldy       #NLCL
                    os9       I$Write
                    ldd       <ncyls
                    lbra      PrintNum

ShowNumberSurfaces
                    leax      NS,pcr
                    ldy       #NSL
                    os9       I$Write
                    clra
                    ldb       <numsides
                    bra       PrintNum

ShowSectorInterleaveOffset
                    leax      SI,pcr
                    ldy       #SIL
                    os9       I$Write
                    clra
                    ldb       <interlv
                    bra       PrintNum

* Output decimal number to stdout with CR tacked at end
* Entry: B = number
* Leading zeros are NOT printed
PrintNum
                    pshs      d
                    clr       ,-s
                    clr       ,-s
                    leax      ,s
                    leay      numbuf,u
                    bsr       itoa
                    lda       #$01
                    os9       I$Write
                    leas      4,s
                    lbra      LineFd

Base                fcb       $3B,$9A,$CA,$00     1,000,000,000
                    fcb       $05,$F5,$E1,$00     100,000,000
                    fcb       $00,$98,$96,$80     10,000,000
                    fcb       $00,$0f,$42,$40     1,000,000
                    fcb       $00,$01,$86,$a0     100,000
                    fcb       $00,$00,$27,$10     10,000
                    fcb       $00,$00,$03,$e8     1,000
                    fcb       $00,$00,$00,$64     100
                    fcb       $00,$00,$00,$0a     10
                    fcb       $00,$00,$00,$01     1

* Entry:
* X = address of 24 bit value
* Y = address of buffer to hold hexadecimal number
* Exit:
* X = address of buffer holding hexadecimal number
* Y = length of number string in bytes (always 6)
*i24toha  pshs  y
*         ldb   #3
*         pshs  b
*a@       lda   ,x
*         anda  #$F0
*         lsra
*         lsra
*         lsra
*         lsra
*         cmpa  #10
*         blt   o@
*         adda  #$41
*o@       sta   ,y+
*         lda   ,x+
*         anda  #$0F
*         cmpa  #10
*         blt   p@
*         adda  #$41
*p@       sta   ,y+
*         dec   ,s
*         bne   a@
*         leas  1,s
*         ldy   #0006
*         puls  x,pc

* Entry:
* X = address of 32 bit value
* Y = address of buffer to hold number
* Exit:
* X = address of buffer holding number
* Y = length of number string in bytes
itoa                pshs      u,y
                    tfr       y,u
                    ldb       #10                 max number of numbers (10^9)
                    pshs      b                   save count on stack
                    leay      Base,pcr            point to base of numbers
s@                  lda       #$30                put #'0
                    sta       ,u                  at U
s1@                 bsr       Sub32               ,X=,X-,Y
                    inc       ,u
                    bcc       s1@                 if X>0, continue
                    bsr       Add32               add back in
                    dec       ,u+
                    dec       ,s                  decrement counter
                    beq       done@
                    lda       ,s
                    cmpa      #$09
                    beq       comma@
                    cmpa      #$06
                    beq       comma@
                    cmpa      #$03
                    bne       s2@
comma@              ldb       #',
                    stb       ,u+
s2@                 leay      4,y                 point to next
                    bra       s@
done@               leas      1,s
* 1,234,567,890
                    ldb       #14                 length of string with commas + 1
                    ldx       ,s++                get pointer to buffer
a@                  decb
                    beq       ex@
                    lda       ,x+                 get byte
                    cmpa      #'0
                    beq       a@
                    cmpa      #',
                    beq       a@
                    clra
                    tfr       d,y                 transfer count into Y
v@                  leax      -1,x
                    puls      u,pc
ex@                 ldy       #0001
                    bra       v@

* Entry:
* X = address of 32 bit minuend
* Y = address of 32 bit subtrahend
* Exit:
* X = address of 32 bit difference
Sub32               ldd       2,x
                    subd      2,y
                    std       2,x
                    ldd       ,x
                    sbcb      1,y
                    sbca      ,y
                    std       ,x
                    rts


* Entry:
* X = address of 32 bit number
* Y = address of 32 bit number
* Exit:
* X = address of 32 bit sum
Add32               ldd       2,x
                    addd      2,y
                    std       2,x
                    ldd       ,x
                    adcb      1,y
                    adca      ,y
                    std       ,x
                    rts


                    ifne      DOROLL
RollMsg             fcc       "        Recording Format:  FM/MFM"
                    fcb       C$LF
                    fcc       "    Track density in TPI:  48/96"
                    fcb       C$LF
                    fcc       "     Number of Cylinders:  0000"
                    fcb       C$LF
                    fcc       "      Number of Surfaces:  0000"
                    fcb       C$LF
                    fcc       "Sector Interleave Offset:  0000"
                    fcb       C$LF
                    fcc       "               Disk type:  0000"
                    fcb       C$LF
                    fcc       "         Sectors/Cluster:  0000"
                    fcb       C$LF
                    fcc       "           Sectors/Track:  0000"
                    fdb       $0A0A
                    fcc       "Sector: 00  Track: 00  Side: 00"
RollLen             equ       *-RollMsg
                    endc

                    emod
eom                 equ       *
                    end
