                    nam       dEd                 OS-9 Disk Editor Version 2.06
                    ttl       Copyright 1987 Doug DeMartinis
*******************************************************
* Copyright 1987 Doug DeMartinis; All Rights Reserved *
*                CIS:    72245,1400                   *
*                Delphi: DOUGLASD                     *
* Personal use and uploading of code, source and docs *
* to BBS's, as well as customization of the terminal  *
* display codes, is permitted only if the copyright   *
* notice and docs remain intact.                      *
*                                                     *
* 10/87 Various mods & fixes by Bruce Isted (BRI)     *
* 11/87 Added Diddle, Find, Push, Remove routines.    *
*       Fixed bug throwing stack off by going in and  *
*        out of various error routines.               *
*                                                     *
*******************************************************
* Further provenance is unknown but there has been at *
* least some modifications by Marie-Louis Marcoux.    *
* The program now reports position in the allocation  *
* map and which sectors the bytes represent when      *
* editing the map. It appears to also contain the     *
* patches indicated below.                            *
* The Rev Ed is 2.05 which would be consistant with   *
* the Marcoux dEd on RTSI as dEd_Plus_1and2_Patch.lzh *
* but the CRC does not match. RG                      *
*******************************************************
*                                                     *
* Mods by Roger A. Krupski (HARDWAREHACK)             *
*                                                     *
* 02/88 -Added "enter" command which cleans up the    *
*        screen by running the REDO subroutine. (RAK) *
*                                                     *
* 01/90 -Added a check for the break key which allows *
*        aborting the <F>ind function. (RAK)          *
*       -Added a check for null filename in OUTFILE:  *
*        and bypass I$Create if so.                   *
*       -Other minor bugs fixed / errors trapped.     *
*******************************************************
* 06/01/11  Robert Gault                              *
*        Corrected BAM to sector calculation.         *
*        No attempt has been made to comment code.    *
*******************************************************
* 08/05/27  Robert Gault                              *
*        Corrected BAM presentation with drives having*
*        more than $##0000 sectors and/or DD.BIT >1.  *
*        Converted all u and L addressing to normal   *
*        lables.                                      *
*        Added cluster/sector toggle.                 *
*******************************************************
* 11/09/20  Robert Gault                              *
*        Corrected BAM presentation in sector mode    *
*        when DD.BIT>1.                               *
*******************************************************
* Disassembled 2006/01/10 00:57:52 by Disasm v1.5 (C) 1988 by RML and RG


                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $02
top                 mod       eom,name,tylg,atrv,start,size
inpath              rmb       1
outpath             rmb       1
lsn                 rmb       3
oldlsn              rmb       3
offset              rmb       2
cursor              rmb       4
hexcol              rmb       1
rownum              rmb       1
asciicol            rmb       1
lastflag            rmb       1
buffptr             rmb       2
edbufptr            rmb       2
edpos               rmb       1
hexascii            rmb       1
zeroflag            rmb       1
oldecho             rmb       1
echobyte            rmb       1
Usave               rmb       2
Ssave               rmb       2
seclen              rmb       2
vmodlen             rmb       2
lmodlen             rmb       2
fileln              rmb       2
bytsread            rmb       2
crc                 rmb       3
modnmlen            rmb       1
wrtflag             rmb       1
xprtflag            rmb       1
FHexAsc             rmb       1
TargLen             rmb       1
findstr             rmb       17
findptr             rmb       2
FBytes              rmb       1
HexBuff             rmb       4
FileLen             rmb       4
infile              rmb       30                  linked module name
outfile             rmb       30                  output filename
CrsrCnt             rmb       1
CrsrFlg             rmb       1
SgnlCode            rmb       1
rawflg              rmb       1
clustflg            rmb       1                   flag for cluster/sector
ddmap               rmb       2
mappags             rmb       2                   sectors per Allocation Map
ddbit               rmb       2                   copy of DD.BIT
ddbitcalc           rmb       2                   calculation of sectors per map page
newBAM              rmb       3
nBAMstp             rmb       3
BAMstart            rmb       3
BAMstop             rmb       3
u009D               rmb       8
StackCnt            rmb       1
Stack               rmb       48
inbuff              rmb       256
i.o.buff            rmb       320
size                equ       .
cls                 fcb       $0C                 clear screen
revvid              fcb       $1F,$20,0           reverse video on
normvid             fcb       $1F,$21,0           reverse video off
eraselin            fcb       $04                 erase from current character to end of line
erasescr            fcb       $0B                 erase from current character to end of screen
curon               fcb       $05,$21,0           turns on cursor
curoff              fcb       $05,$20,0           turns off cursor
name                equ       *
                    fcs       /dEd/
                    fcb       $06
                    fcc       /Copyright 1987 Doug DeMartinis/
lsntitle            fcs       /LSN=$/
sect                fcs       /SECTOR = $/
header              fcc       /      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F/
                    fcc       /    0 2 4 6 8 A C E /
                    fcb       $0D
command             fcs       /CMD: /
edprompt            fcc       "<BREAK> toggles HEX/ASCII edit modes     "
                    fcs       /<ENTER> exits edit mode/
zaprompt            fcs       /Zap /
byte                fcs       /byte: /
char                fcs       /char: /
sure                fcs       "Are you sure? (Y/N) "
writing             fcs       /Writing sector.../
out$                fcs       /OUTFILE: /
vrfymess            fcs       /Verifying.../
verrmess            fcs       /Verify aborted.../
shell$              fcs       /shell/
linkmess            fcs       /Link to which module? /
linkhdr             fcc       /Off  Len  Name/
                    fcb       $0A
                    fcc       /---- ---- ----/
                    fcb       $0D
modnmhdr            fcs       /MODULE:  /
offmess             fcs       /OFFSET: $/
xprtmess            fcb       $1F,$24             blink on
                    fcc       /- Expert Mode -/
                    fcb       $1F,$25+$80         blink off
findbyte            fcs       /Find byte string $/
findchar            fcs       /Find char string: /
srchmess            fcs       /Searching.../
lenmess             fcs       /Current File Length $/
newmess             fcs       /New Length? $/
bootmess            fcs       /** RESTART, Enter pathname: /
BAMmess1            fcs       /BAM: From Sector:$       to $       /
BAMmess2            fcs       /BAM: From Cluster:$       to $       /
BITmess             fcs       /Bits:/
bell                fcb       $07
fullmess            fcs       /Sector Stack Full /
helper              fcc       "   Up/Down Arrows  Read & display Next/Previous sector"
                    fcb       $0A
                    fcc       / <CR> Clean up the screen display/
                    fcb       $0A
                    fcc       /   *  Restart/
                    fcb       $0A
                    fcc       "   !  Toggle BAM Cluster/Sector"
                    fcb       $0A
                    fcc       /   $  Fork a SHELL (Ctrl-BREAK to return)/
                    fcb       $0A
                    fcc       /   A  Append displayed sector to output file/
                    fcb       $0A
                    fcc       /   C  Close output file/
                    fcb       $0A
                    fcc       /   D  Diddle (adjust) file length/
                    fcb       $0A
                    fcc       /   E  Edit the displayed sector/
                    fcb       $0A
                    fcc       /   F  Find a byte or text string (BREAK aborts)/
                    fcb       $0A
                    fcc       /   H  Help screen (also use '?')/
                    fcb       $0A
                    fcc       /   L  Link to a module - List all modules/
                    fcb       $0A
                    fcc       /   N  Next occurrence of byte(s) or string (Find)/
                    fcb       $0A
                    fcc       /   O  Open a file for output (use with Append)/
                    fcb       $0A
                    fcc       /   P  Push current sector onto stack/
                    fcb       $0A
                    fcc       /   Q  Quit dEd - Exit to OS9/
                    fcb       $0A
                    fcc       /   R  Remove and display a sector from stack/
                    fcb       $0A
                    fcc       /   S  Skip to given sector (sector # in hex)/
                    fcb       $0A
                    fcc       /   U  Unlink from module/
                    fcb       $0A
                    fcc       /   V  Verify all modules in file/
                    fcb       $0A
                    fcc       /   W  Write the sector back to the disk/
                    fcb       $0A
                    fcc       "   X  eXpert mode toggle on/off"
                    fcb       $0A
                    fcc       /   Z  Zap (fill in) the sector displayed/
                    fcb       $0A
                    fcb       $0A
                    fcc       /      (Press any key to return to command prompt):/
helpchrs            equ       *-helper
usemess             fcc       /Use:  dEd <pathlist>/
                    fcb       $0D
decimals            fcb       $98,$96,$80         decimal 10,000,000
                    fcb       $0F,$42,$40         decimal  1,000,000
                    fcb       $01,$86,$A0         decimal    100,000
                    fcb       $00,$27,$10         decimal     10,000
                    fcb       $00,$03,$E8         decimal      1,000
                    fcb       $00,$00,$64         decimal        100
                    fcb       $00,$00,$0A         decimal         10
                    fcb       $00,$00,$01         decimal          1
* Command jump table
commands            fcb       $0C                 up arrow
                    fdb       nxtsec
                    fcb       $0A                 down arrow
                    fdb       prevsec
                    fcb       '*
                    fdb       restart             Restart program with new file/disk
                    fcb       '!
                    fdb       togCS               Toggle cluster/sector
                    fcb       '$                  shell
                    fdb       goshell
                    fcb       $0D                 CR
                    fdb       cReturn
                    fcb       's                  LSN change
                    fdb       changLSN
                    fcb       'z                  Zap
                    fdb       zap
                    fcb       'w                  Write sector
                    fdb       writesec
                    fcb       'o                  Open output file
                    fdb       openout
                    fcb       'a                  Append to file
                    fdb       append
                    fcb       'c                  Close output file
                    fdb       closeout
                    fcb       'e                  Edit sector
                    fdb       edit
                    fcb       'q                  Quit
                    fdb       quit
                    fcb       'v                  Verify
                    fdb       verify
                    fcb       'l                  Link
                    fdb       linker
                    fcb       'u                  Unlink
                    fdb       unlinker
                    fcb       'x                  eXpert mode
                    fdb       expert
                    fcb       'h                  help
                    fdb       help
                    fcb       '?                  help
                    fdb       help
                    fcb       'f                  Find
                    fdb       find
                    fcb       'n                  Next find
                    fdb       next
                    fcb       'd                  Diddle length
                    fdb       diddle
                    fcb       'p                  Push
                    fdb       push
                    fcb       'r                  Restore (Pop)
                    fdb       restore
                    fcb       $00

* Intercept signals
* modification by BRI
icept               stb       SgnlCode,u
                    rti
* end modification

restart             lds       <Ssave
                    ldu       <Usave
                    com       <echobyte
                    lbsr      echo
                    lbsr      movecmd
                    leax      bootmess,pcr
                    lbsr      pstring
                    lbsr      clrline
                    leax      i.o.buff,u
                    stx       <inbuff
                    ldy       #$50
                    clra
                    os9       I$ReadLn
                    lbcs      error
                    cmpy      #1
                    bne       newdata
                    clr       <echobyte
                    lbsr      echo
                    lbra      getcmd
newdata             lda       <inpath
                    os9       I$Close
                    bra       softstrt

start               equ       *
                    stx       <inbuff             pointer to param
                    leax      >icept,pcr          intercept routine addr
                    os9       F$Icpt
                    lbcs      error
* Initialize data area
softstrt            clra
                    ldb       #inbuff
                    leax      ,u                  point to data area
init                sta       ,x+                 clear memory
                    decb
                    bne       init
                    com       clustflg            set default to show clusters
                    stu       <Usave
                    sts       <Ssave
                    ldd       #$0002              cursor move code
                    std       <cursor             store it for output
                    leas      <-$20,s             make room for terminal options
                    leax      ,s                  point regX to temp buffer
                    clra                          stdin path#
                    clrb                          SS.OPT
                    os9       I$GetStt
                    lbcs      error
                    lda       $04,x               get echo status byte
                    sta       <oldecho
                    leas      <$20,s              reset stack
* Open file
                    ldx       <inbuff             point to file name
                    pshs      x
                    clr       <rawflg             raw disk edit open flag
opfLoop             lda       ,x+                 find CR
                    cmpa      #$0D
                    beq       noraw               @ not found
                    cmpa      #'@                 open raw option
                    bne       opfLoop
                    com       <rawflg             flag the option
noraw               puls      x
                    lda       #$03                update mode
                    os9       I$Open
                    bcc       openOK
                    cmpb      #$D7                bad pathname
                    lbeq      hints
                    cmpb      #$D6                no permission
                    lbne      bye                 exit with error
                    ldx       <inbuff             point to file name
                    lda       #$83                mode=Dir + Update
                    os9       I$Open
                    lbcs      bye                 exit with error
openOK              sta       <inpath             path#
                    ldb       #$02                ss.size
                    os9       I$GetStt
                    stx       <FileLen            msw of file size (in bytes?)
                    stu       <FileLen+2          lsw
                    ldu       <Usave
                    clr       <echobyte
                    lbsr      echo                set no echo
                    lbsr      clrscr              clear the screen
                    tst       <rawflg
                    beq       readloop            go if not raw
                    lbsr      seeksec             read LSN0 of disk
                    ldx       <buffptr            point regX to sector image
* Get DD.BIT RG
                    ldd       6,x                 get DD.BIT
                    std       <ddbit              save new data
                    ldd       4,x                 get DD.MAP
                    std       <ddmap              save copy
* Next line converts DD.MAP to base0 numbering.
* (DD.MAP-1)/$100+1=sectors in map. Original was DD.MAP/$100+1  RG
                    subd      #1                  needed to correctly convert DD.MAP to sectors in allocation, RG
                    tfr       d,x
                    ldd       #$100               bytes per sector of map
                    lbsr      mul16B
                    leax      1,x
                    stx       <mappags            pages in allocation map
readloop            lbsr      seeksec
                    sty       <seclen             either $100 or number of bytes left in file
                    ldd       <lsn                get lsn just read
                    std       <oldlsn
                    lda       <lsn+2
                    sta       <oldlsn+2
                    ldd       #0                  signal Next
                    std       <findptr
disploop            lbsr      display             display the sector
getcmd              lbsr      movecmd             move cursor to
                    leax      >command,pcr        CMD:
                    bsr       pstring
                    leax      >erasescr,pcr       erase to end of string
                    ldy       #$0001              era2chrs
                    os9       I$Write
                    lbcs      error
                    leax      >i.o.buff,u
                    lbsr      read1               read one char
                    lda       ,x
                    cmpa      #'A                 is it ascii?
                    bcs       srchtabl            if not skip
                    ora       #$20                upper -> lower
srchtabl            leax      >commands,pcr       point to command table
findcmd             cmpa      ,x+                 found it?
                    beq       gotcmd              go if yes
                    leax      $02,x               else
                    tst       ,x                  end of table?
                    bne       findcmd             loop
                    bra       getcmd              invalid key
gotcmd              tst       <xprtflag           using expert mode?
                    beq       jmpcmd              no, then go
                    tst       <wrtflag            are we writing?
                    beq       jmpcmd              n, then go
                    pshs      x,a
                    lbsr      xprtwrt             write sector
                    puls      x,a
jmpcmd              ldd       ,x                  get address offset
                    leax      top,pcr             start of module
                    jmp       d,x                 jump to address
* Print string of characters in fcs mode
pstring             leay      >i.o.buff,u
                    clrb                          counter
xfer                incb
                    lda       ,x+                 get shar
                    bmi       lstchar             if bit7 set,go
                    sta       ,y+                 put in buffer
                    bra       xfer
lstchar             anda      #$7F                clear bit7
                    sta       ,y                  put in buffer
                    leax      >i.o.buff,u         point to string
                    clra
                    tfr       d,y                 length of string to print
                    bra       writeout
wrtlin1             ldy       #$78                #bufsiz 120 chars max
writeout            lda       #$01                stdout
wrtlin2             os9       I$WritLn
                    lbcs      error
                    rts
readlin3            ldy       #3                  chars to read
readlin             clra                          stdin
                    os9       I$ReadLn            get 2 chars + CR
                    lbcs      error
                    rts
movecmd             ldd       #$2036              #cmdpos
movecurs            leax      cursor,u            cursor move code
                    std       2,x                 row/col
                    ldy       #4                  # chars
                    bra       writeout

* Set reverse video code
revdisp             leax      >revvid,pcr
                    ldy       #2                  chars to write
                    bra       writeout

* Set normal video code
normdisp            leax      >normvid,pcr
                    ldy       #2                  normchrs
                    bra       writeout

clrline             leax      >eraselin,pcr
                    ldy       #1
                    bra       writeout

clrscr              leax      >cls,pcr
                    ldy       #1                  eraschrs
                    bra       writeout

seeksec             bsr       lsnseek             seek to sector
                    leax      >inbuff,u
                    stx       <buffptr
                    tst       <infile             is module linked?
                    beq       read256             on not linked
                    ldd       <lmodlen            get module length
                    suba      <lsn+2              are more than $100 bytes left?
                    bne       read256             yes, then go
                    tfr       d,y                 no so setup smaller read
                    bra       readsome
read256             ldy       #$100               256 bytes
readsome            lda       <inpath
                    os9       I$Read
                    lbcs      error
                    rts

******************************
* changed to ignore errors 01/09/90 (RAK)
*
read1               clra                          stdin
                    ldy       #1
                    os9       I$Read
                    rts
*********************** End of mod
lsnseek             tst       <infile             is module linked?
                    bne       offchk              yes so go
                    ldx       <lsn
                    lda       <lsn+2
                    clrb
lsnseek1            tfr       d,u
                    lda       <inpath
                    os9       I$Seek
                    lbcs      error
                    ldu       <Usave
lsnrts              rts

offchk              ldd       <lmodlen            linked module length
                    subd      #1                  base0 on sector
                    cmpa      <lsn+2              reading past last sector?
                    bcc       offseek             no then go
                    ldb       #$D3                e$eof
                    lbra      error
* If module is 'linked' add offset for good seek
offseek             ldd       <offset
                    adda      <lsn+2
                    ldx       #0
                    bra       lsnseek1

display             ldd       #$2020
                    lbsr      movecurs
                    leax      >lsntitle,pcr
                    lbsr      pstring
                    bsr       clrline
                    lbsr      convert3            hex to ascii for lsn
                    leax      >i.o.buff,u
                    lbsr      wrtlin1
                    tst       <infile             link test
                    beq       nolink
                    lbsr      prntmod
nolink              tst       <outpath            is an output path open
                    beq       noout               no, then go
                    lbsr      prntout             display name
noout               ldd       #$2022              hedrpos
                    lbsr      movecurs
                    leax      >revvid,pcr         reverse video code
                    ldy       #2                  # of revchrs
                    lbsr      wrtlin2
                    leax      >header,pcr
                    lbsr      wrtlin1
                    leax      >normvid,pcr        normal video code
                    ldy       #2                  normchrs
                    lbsr      wrtlin2
disp                lbsr      dsplylin
                    lda       <rownum             get row #
                    adda      #$10                next row
                    sta       <rownum
                    bne       disp                do 16 rows
                    leax      >inbuff,u
                    stx       <buffptr            reset buffer pointer
                    tst       <rawflg             edit flag
                    beq       contin              if not raw
* New lines handle disks with $xx0000 sectors where xx>00. RG
                    tst       <lsn                look at LSN msb
                    bne       contin              we're not looking at the map if not $00
                    ldd       <lsn+1              get LSN lsw
                    cmpd      #1                  first page of map?
                    bcs       contin              go if lsn0
                    cmpd      <mappags
                    bhi       contin              lsnrts, go if not map
*        ldd   <lsn+1       we don't need this as it already is loaded. RG
                    subd      #1                  setup to calc first sector
* Big error as it ignores DD.BIT  New lines added. RG
                    ldx       #$800               8 bits/byte x $100 bytes per page if DD.BIT=1

                    tst       clustflg
                    bne       csf1                no calc if in cluster mode
                    pshs      d                   save LSN
                    ldd       <ddbit              sectors per bit
                    lbsr      mulDbyX             mul regD * regX
                    stu       <ddbitcalc          sectors per page of allocation map, hope for no overflow
                    tfr       u,x                 !!!!!!!!!!!!!!!!!!!
                    puls      d                   recover LSN

csf1                lbsr      mulDbyX             mul regD*regX = value first sector on this page allocation map
                    tfr       y,d
                    stb       <newBAM             msb
                    stu       <newBAM+1           lsw
*        leau  >$7FF,u  this assumes DD.BIT = 1

                    tst       clustflg
                    bne       csf2                no calc if in cluster mode
                    pshs      d
                    bsr       ddbitfix            calculate -sectors per map byte
                    addd      <ddbitcalc          regD = value of last bit on first allocation map page
                    leau      d,u                 add starting value of page
                    puls      d
                    bra       csf3
csf2                leau      $7ff,u              this is fixed in cluster mode
csf3                cmpu      <FileLen+1          file length times $100
                    bls       notshort
                    cmpb      <FileLen            file length times $100
                    bcs       notshort
                    ldu       <FileLen+1
                    tst       clustflg
                    bne       csf4                no calc in cluster mode
                    bsr       ddbitfix            calc -sectors per map byte
                    leau      d,u
                    bra       csf5
csf4                leau      -1,u                fixed in cluster mode

csf5                ldb       <FileLen
notshort            stb       <nBAMstp
                    stu       <nBAMstp+1
                    ldu       <Usave
                    ldx       <newBAM
                    ldb       <newBAM+2
                    stx       <BAMstart
                    stb       <BAMstart+2
                    ldx       <nBAMstp
                    ldb       <nBAMstp+2
                    stx       <BAMstop
                    stb       <BAMstop+2
                    lbsr      prntBAM
                    bra       moredisp

ddbitfix            clra                          does a   neg(ddbit)
                    clrb
                    subd      <ddbit
                    rts
* End of BAM mod

* Continue the normal display.
contin              ldd       #$2034              clear BAM line
                    lbsr      movecurs
                    lbsr      clrline
moredisp            tst       <xprtflag
                    lbeq      lsnrts              go if not expert
                    ldd       #$5933              xprtpos
                    lbsr      movecurs
                    leax      >xprtmess,pcr
                    lbra      pstring
convert3            ldd       <lsn
                    com       <zeroflag           to suppress leading zeros
                    leay      >i.o.buff,u
                    bsr       convert1
                    tfr       b,a
                    bsr       convert1
                    clr       <zeroflag           print leading zeros
                    lda       <lsn+2
                    bsr       convert1
                    ldd       #$2020              space space
                    std       ,y++                move to buffer
                    ldd       #8                  8 decimal digits
                    pshs      b,a
                    com       <zeroflag           suppress leading zeros
                    leax      >decimals,pcr       conversion table pointer
initsub1            clr       ,s
subdec1             ldd       <lsn+1
                    subd      $01,x               lsb from table
                    pshs      cc                  save carry
                    std       <lsn+1
                    lda       <lsn
                    clrb                          flag
                    suba      ,x                  -msb of lsn
                    bcc       LSBorrow
                    incb
LSBorrow            puls      cc
                    bcc       savemsb
                    suba      #$01
savemsb             sta       <lsn
                    bcc       chekenuf
                    incb                          set flag
chekenuf            tstb                          enough?
                    bne       enufsub1            go if yes
                    inc       ,s
                    bra       subdec1
enufsub1            ldd       <lsn+1              get lsw
                    addd      1,x                 make it positive
                    std       <lsn+1              lsn+1
                    lda       <lsn
                    bcc       addmsb
                    inca                          get the carry
addmsb              adda      ,x                  make rest of remainder positive
                    sta       <lsn
                    leax      3,x                 point to next table entry
                    bsr       decascii
                    dec       $01,s               8 digits?
                    beq       getCR               go if 8
                    lda       1,s                 get last two digits?
                    cmpa      #2
                    bne       initsub1            if no then loop
                    clr       <zeroflag           enable leading zeros
                    bra       initsub1

getCR               lda       #$0D
                    sta       ,y                  put into out string
                    ldd       <oldlsn+1
                    std       <lsn+1
                    lda       <oldlsn
                    sta       <lsn
                    puls      d,pc

* Convert hex byte in regA to ascii and put in buffer
convert1            pshs      a                   hex to ascii
                    lsra                          shift msn to lsnibble
                    lsra
                    lsra
                    lsra
                    bsr       objasc
                    puls      a                   recover byte
                    anda      #$0F                mask off msnibble
                    bsr       objasc
                    rts
objasc              cmpa      #$09                is a digit?
                    ble       asciify
                    adda      #$07
asciify             adda      #$30                add '0
                    sta       ,y+                 put it into buffer
                    tst       <zeroflag
                    beq       convdone            go if not
                    cmpa      #'0
                    beq       suppres0            erase if yes
                    clr       <zeroflag           stop suppression
convdone            rts
suppres0            leay      -$01,y
                    rts

* Convert decimal# on stack to ascii and add to buffer
decascii            pshs      a
                    lda       $03,s               get decimal counter
                    bsr       asciify
                    puls      pc,a

dsplylin            leay      >i.o.buff,u
                    leax      >revvid,pcr
                    lbsr      transfer            reverse video code
                    lda       <seclen+1
                    beq       notlast
                    anda      #$F0                mask off lsn
                    cmpa      <rownum
                    bne       notlast
                    lda       #$FF
                    sta       <lastflag
notlast             lda       <rownum
                    bsr       convert1            make it hex
                    lda       #':
                    sta       ,y+
                    leax      >normvid,pcr
                    bsr       transfer
                    ldd       #$2020              2 spaces
                    std       ,y++
                    ldx       <buffptr
                    ldb       #$10                16 bytes
                    tst       <lastflag
                    beq       cnvtbyt             go if not
                    ldb       <seclen+1
                    andb      #$0F                regB= bytes for last line
                    beq       noline
                    pshs      b
cnvtbyt             lda       ,x+
                    bsr       convert1
                    lda       #$20                space
                    sta       ,y+
                    decb
                    bne       cnvtbyt
                    tst       <lastflag
                    beq       addspc2
                    ldd       #$310               regB=max bytes per line
                    subb      ,s                  regB=bytes to null out
                    mul                           3 spaces per byte
                    lda       #$20                space
addspc1             sta       ,y+
                    decb
                    bne       addspc1
addspc2             ldb       #$20
                    std       ,y++
                    sta       ,y+
                    ldx       <buffptr
                    asrb                          regB=15
                    tst       <lastflag
                    beq       ascichar
                    ldb       ,s
ascichar            lda       ,x+
                    anda      #$7F                clear bit7
                    cmpa      #$20                32
                    bcc       printabl
notascii            lda       #$2E                notascii '.
printabl            sta       ,y+
                    decb
                    bne       ascichar
                    stx       <buffptr
                    tst       <lastflag
                    beq       addCR
                    ldb       #$10                max bytes per line
                    subb      ,s+                 regB=bytes to null
                    lda       #$20                space
addspc3             sta       ,y+                 put in buffer
                    decb
                    bne       addspc3
                    lda       #$F0                last row
                    sta       <rownum
                    bsr       addCR               display line
resetlst            clr       <lastflag
                    leax      >erasescr,pcr       erase to end of screen code
                    ldy       #1                  era2chrs
                    lbra      writeout
addCR               lda       #$0D                CR
                    sta       ,y
                    leax      >i.o.buff,u
                    lbra      wrtlin1

transfer            lda       ,x+
                    beq       trandone
                    sta       ,y+
                    bra       transfer
trandone            rts

noline              lda       #$F0                signal last row
                    sta       <rownum
                    bra       resetlst

* Point to net LSN in file
nxtsec              ldd       <lsn+1              nxtsec
                    addd      #1
                    std       <lsn+1
                    bne       readsec
                    inc       <lsn
readsec             lbra      readloop

* Point to previous LSN unless at LSN0
prevsec             ldd       <lsn+1
                    bne       notfirst
                    tst       <lsn
                    lbeq      getcmd
notfirst            subd      #1
                    std       <lsn+1
                    cmpd      #$FFFF              borrow if LSN was $xx0000
                    bne       readsec
                    dec       <lsn
                    bra       readsec

* Change LSN
changLSN            lbsr      movecmd
                    leax      sect,pcr
                    lbsr      pstring
                    ldy       #7
                    bsr       MakeHex
                    bcs       BadLSN
                    ldd       <HexBuff+2
                    std       <lsn+1
                    lda       <HexBuff+1
                    sta       <lsn
                    lbra      readloop

BadLSN              lbsr      beep
                    bra       changLSN

MakeHex             pshs      y                   save # of bytes to read
                    clr       <echobyte
                    com       <echobyte
                    lbsr      echo
                    puls      y
                    leax      >i.o.buff,u
                    lbsr      readlin
                    clr       <echobyte
                    lbsr      echo
                    leay      -$01,y
                    beq       ExitHex
                    tfr       y,d
CheckHex            lda       ,x+
                    bsr       hexdigit
                    bcs       invalid
                    decb
                    bne       CheckHex
                    sty       <HexBuff
getascii            lda       #'0
                    ldb       ,-x
                    leay      -1,y
                    beq       convrt2
                    lda       ,-x
                    leay      -1,y
convrt2             bsr       asciihex
                    pshs      b
                    cmpy      #0
                    bne       getascii
                    ldb       <HexBuff+1
                    incb                          prep for badfind
                    lsrb                          # of hex bytes
                    clra                          leading 0
                    leax      <HexBuff,u
                    cmpb      #4                  four bytes on stack?
                    beq       hexstack
                    sta       ,x+
                    cmpb      #3
                    beq       hexstack
                    sta       ,x+
                    cmpb      #2
                    beq       hexstack
                    sta       ,x+
hexstack            puls      a
                    sta       ,x+
                    decb
                    bne       hexstack
                    clrb
                    rts

invalid             lbsr      beep
ExitHex             leas      2,s
                    lbra      readloop

hexdigit            cmpa      #'0
                    bcs       nothex
                    cmpa      #'9
                    bls       ishex
                    anda      #$5F                lower to upper
                    cmpa      #'F
                    bhi       nothex
                    cmpa      #'A
                    bcs       nothex
ishex               clra
                    rts
nothex              coma
                    rts

asciihex            bsr       hexnib
                    pshs      b
                    tfr       a,b
                    bsr       hexnib
                    lslb
                    lslb
                    lslb
                    lslb
                    orb       ,s+
                    rts

hexnib              subb      #$30
                    cmpb      #9
                    bls       nowhex
                    andb      #$5F
                    subb      #$07
nowhex              rts

* Zap sector
zap                 clr       <echobyte
                    com       <echobyte
                    lbsr      echo
                    lbsr      movecmd
                    lbsr      clrline
                    leax      >zaprompt,pcr
                    lbsr      pstring
                    tst       <hexascii
                    bne       zapascii
                    leax      >byte,pcr
                    lbsr      pstring
                    ldy       #3
                    bsr       zapread
                    bsr       hexobjct
                    bcs       exitzap
zapstart            leax      >inbuff,u
                    stx       <buffptr
                    clrb                          counter
zapbuff             sta       ,x+
                    decb
                    bne       zapbuff
                    clr       <echobyte
                    lbsr      echo
                    inc       <wrtflag
                    lbra      disploop

zapread             clra
                    leax      >i.o.buff,u
                    os9       I$ReadLn
                    bcs       cheksig1
                    rts
cheksig1            cmpb      #2                  break key signal
                    lbne      error
                    com       <hexascii
                    leas      2,s
                    bra       zap

exitzap             clr       <echobyte
                    lbsr      echo
                    lbra      getcmd

zapascii            leax      >char,pcr
                    lbsr      pstring
                    ldy       #2
                    bsr       zapread
                    lda       ,x
                    cmpa      #$20
                    bcs       exitzap
                    bra       zapstart

* Convert 2 hex chars in buffer (x) to object byte
hexobjct            bsr       cnvrtnib
                    bcs       badrts
                    tfr       a,b
                    bsr       cnvrtnib
                    bcs       badrts
                    lslb
                    lslb
                    lslb
                    lslb
                    pshs      b
                    ora       ,s+
                    bra       goodhex

cnvrtnib            bsr       isithex
                    bcs       badrts
                    bra       cnvrthex

isithex             lda       ,x+
                    cmpa      #'0
                    bcs       badhex
                    cmpa      #'9
                    bls       goodhex
                    anda      #$5F                lower to upper
                    cmpa      #'A
                    bcs       badhex
                    cmpa      #'F
                    bhi       badhex
goodhex             andcc     #$FE
                    rts
badhex              orcc      #1
badrts              rts

cnvrthex            suba      #$30
                    cmpa      #9
                    bls       nowobjct
                    suba      #7
nowobjct            bra       goodhex

* Write current sector back to disk
writesec            tst       <xprtflag           is expert mode on
                    lbne      getcmd              yes, then go
                    bsr       rusure              no, are you sure
                    lbne      getcmd              Y or N
                    lbsr      movecmd
                    lbsr      clrline
                    lbsr      movecmd
                    leax      >writing,pcr
                    lbsr      pstring
xprtwrt             lbsr      lsnseek             seek to start of sector
                    lda       <inpath             path#
                    lbsr      write100            write 256 bytes
                    tst       <xprtflag
                    beq       opendone
                    clr       <wrtflag            clear auto-write
                    rts

* Ask  Are you sure?  And get response
rusure              lbsr      movecmd
rusure10            clr       <echobyte
                    com       <echobyte
                    lbsr      echo
                    leax      >sure,pcr
                    lbsr      pstring
                    lbsr      clrline
                    leax      >i.o.buff,u
                    lbsr      read1
                    clr       <echobyte
                    lbsr      echo
                    lda       ,x
                    anda      #$5F                lower to upper
                    cmpa      #'Y
                    rts

* Open output file
openout             tst       <outpath
                    bne       opendone
                    clr       <echobyte
                    com       <echobyte
                    lbsr      echo
                    lbsr      movecmd
                    leax      >out$,pcr
                    lbsr      pstring
                    lbsr      clrline
                    leax      >i.o.buff,u
                    ldy       #30                 29 char + CR
                    lbsr      readlin
                    clr       <echobyte
                    lbsr      echo
***********************************************
* Return to command prompt if no filename given
* Added 01/09/90 (RAK)
*
                    cmpy      #1
                    beq       opendone
********************************** END modification
                    pshs      x
                    leay      <outfile,u
savname             lda       ,x+                 get name
                    sta       ,y+
                    cmpa      #$20                space
                    bhi       savname
                    lda       #$0D                CR
                    sta       -1,y                delimit
                    puls      x
                    lda       #2                  write
                    ldb       #$0B                attributes read+write
                    os9       I$Create
                    bcs       error
                    sta       <outpath
                    bsr       prntout
opendone            lbra      getcmd

* move cursor & print 'Outout pathlist'
prntout             ldd       #$3021              out position
                    lbsr      movecurs
                    leax      >out$,pcr
                    lbsr      pstring
                    leax      <outfile,u
                    lbra      wrtlin1

* Write out a sector
write100            leax      >inbuff,u
                    ldy       <seclen
                    os9       I$Write
                    bcs       error
                    rts

* Close output file
closeout            lda       <outpath
                    beq       opendone
                    os9       I$Close
                    bcs       error
                    ldd       #$3021
                    lbsr      movecurs
                    lbsr      clrline
                    clr       <outpath
closed              bra       opendone

* Append sector to output file
append              lda       <outpath
                    beq       closed
                    bsr       write100
                    lbra      nxtsec

* main error routine
error               pshs      b
* modification by BRI
                    clr       <SgnlCode
* end modification
                    ldd       <oldlsn
                    std       <lsn
                    lda       <oldlsn+2
                    sta       <lsn+2
                    puls      b
                    lds       <Ssave
                    cmpb      #2                  break
                    beq       error2
                    cmpb      #3                  shift break
                    bne       eofchk
                    clr       <wrtflag
                    bra       error2
eofchk              cmpb      #$D3
                    bne       truerr
error2              lbra      exitzap

truerr              cmpb      #$CD                bad module ID
                    bne       othererr
* If module is linked, BMID error must come from trying to Verify modules
* use standard error reporting routine. Otherwise BMID error occurs when
* trying to link (or list names of) modules; need to clear screen after these.
                    tst       <infile             module linked?
                    bne       othererr            yes, use standard error
                    bsr       prterr              display error #
                    leax      >cls,pcr
                    ldy       #1
                    lbsr      writeout
                    lbra      disploop
othererr            pshs      b
                    lbsr      movecmd
                    lbsr      clrline
                    puls      b
                    bsr       prterr
                    lbra      getcmd

* display error #
prterr              lda       #$02                error path
                    os9       F$PErr
                    clr       <echobyte
                    lbsr      echo
                    leax      >i.o.buff,u
                    lbra      read1

* use with   ded   and no path list
hints               lda       #2                  Now this is used
                    leax      >usemess,pcr
                    ldy       #$78
                    lbsr      wrtlin2
                    clrb
                    bra       bye

* Exit to OS-9
quit                lbsr      rusure
                    lbne      getcmd
                    lbsr      clrscr
                    lda       <oldecho
                    sta       <echobyte
                    lbsr      echo
                    clrb
bye                 os9       F$Exit

* Edit sector
edit                lbsr      movecmd
                    leax      >edprompt,pcr
                    lbsr      pstring
topleft             leax      >inbuff,u
                    stx       <edbufptr
                    lda       #1
                    sta       <edpos
                    lda       #$23                top row code
                    sta       <rownum
                    lda       #$25                hex dump col#
                    sta       <hexcol
                    lda       #$58                ascii dump col#
                    sta       <asciicol
revbyte             lbsr      revdisp
                    lbsr      eddisply
edinput             lda       <hexcol
                    ldb       <rownum
                    tst       <hexascii
                    beq       hexin
                    lda       <asciicol
hexin               tst       <rawflg
                    lbeq      edcont
                    ldx       <lsn+1
                    cmpx      #$0001
                    lbcs      edcont              not BAM
                    cmpx      <mappags
                    lbhi      edcont              not BAM
                    pshs      b,a
                    ldx       <newBAM
                    ldb       <newBAM+2
                    stx       <BAMstart
                    stb       <BAMstart+2
                    ldx       <nBAMstp
                    ldb       <nBAMstp+2
                    stx       <BAMstop
                    stb       <BAMstop+2
                    clra                          calc byte to cluster
                    ldb       <rownum
                    subb      #$23
                    lda       #$10
                    mul
                    pshs      b,a
                    clra
                    ldb       <hexcol
                    subb      #$25
                    beq       hexin2
                    tfr       d,x
                    ldd       #$0003
                    lbsr      mul16B
                    tfr       x,d
hexin2              addd      ,s++
                    ldx       <lsn+1
                    cmpx      <mappags
                    bcs       hexin3              edit inside of BAM range
                    pshs      b,a
                    ldd       <ddmap
                    clra
                    tfr       d,x
                    puls      b,a
                    leax      -$01,x
                    pshs      x
                    cmpd      ,s++
                    bhi       hexin4              edit outside of BAM range
hexin3              ldx       #$0008
                    tst       clustflg            using clusters or sectors
                    bne       csf6                go if clusters
                    pshs      d
                    ldd       ddbit
                    lbsr      mulDbyX
                    tfr       u,x
                    puls      d
csf6                lbsr      mulDbyX
                    tfr       u,d
                    addd      <BAMstart+1
                    std       <BAMstart+1
                    tst       clustflg
                    bne       csf7                go if cluster mode
                    pshs      d
                    ldx       #7
                    ldd       ddbit
                    lbsr      mulDbyX
                    tfr       u,d
                    addd      ,s++
                    bra       csf8
csf7                addd      #$0007              fixed if clusters
csf8                cmpd      <nBAMstp+1
                    bls       hexin5
                    ldd       <nBAMstp+1
hexin5              std       <BAMstop+1
                    bra       hexin6
hexin4              clr       <BAMstop
                    clr       <BAMstop+1
                    clr       <BAMstop+2
hexin6              ldu       <Usave
                    lbsr      normdisp
                    tst       <BAMstop+2
                    bne       prtbmess
                    tst       <BAMstop+1
                    bne       prtbmess
                    tst       <BAMstop
                    bne       prtbmess
                    ldd       #$2034
                    lbsr      movecurs
                    lbsr      clrline
                    bra       hexin7
prtbmess            lbsr      prntBAM
                    ldd       #$4934
                    lbsr      movecurs
                    leax      >BITmess,pcr        Bits:
                    lbsr      pstring
                    leax      >u009D,u
                    lda       [<edbufptr,u]
                    ldb       #8
                    pshs      x,a
bmess2              lsl       ,s
                    bcs       bmess3
                    lda       #'0
                    bra       bmess4
bmess3              lda       #'1
bmess4              sta       ,x+
                    decb
                    bne       bmess2
                    puls      x,a
                    ldy       #8
                    lbsr      writeout
hexin7              lbsr      revdisp
                    puls      b,a
************ End of BAM mod
edcont              lbsr      movecurs
                    leax      >i.o.buff,u
                    tst       <hexascii           test for hex/ascii mode
                    lbne      inputchr
* modification by BRI
* bra inputbyt
                    lbra      inputbyt
* end mod
eddisply            lda       <hexcol
                    ldb       <rownum
                    lbsr      movecurs
                    leay      >i.o.buff,u
                    lda       [<edbufptr,u]
                    pshs      a
                    lbsr      convert1
                    leax      -2,y
                    ldy       #2
                    lda       #1
                    lbsr      wrtlin2
                    lda       <asciicol
                    ldb       <rownum
                    lbsr      movecurs
                    puls      a
                    anda      #$7F
                    cmpa      #$20
                    bcc       prntabl1
                    lda       #$2E
prntabl1            leax      >i.o.buff,u
                    sta       ,x
                    ldy       #1
                    lbra      writeout

* read in char, check for break key
* modification by BRI
* toggles cursor on/off if enabled, checks for character
*readit ldy #1 1 char
readit              pshs      x,b
CFlash1             clra
                    ldb       #1
                    os9       I$GetStt
                    bcc       CFExit
                    cmpb      #$F6                not ready
                    bne       CrsrErr
                    ldx       #1
                    os9       F$Sleep
                    bcs       CrsrErr
                    dec       <CrsrCnt
                    lda       <CrsrCnt
                    eora      <CrsrFlg
                    anda      #$40                keep active counter bit
                    beq       SigChk
                    com       <CrsrFlg
                    beq       CrsrOff
                    bsr       CrsrOn
                    bra       SigChk
CrsrOff             leax      >curoff,pcr
                    ldy       #2
                    bsr       WritCrsr
SigChk              ldb       <SgnlCode
                    cmpb      #2                  abort code
                    beq       CrsrErr
                    cmpb      #$03                shift break
                    bne       CFlash1
CrsrErr             stb       ,s
                    bsr       CrsrOn
                    puls      x,b
                    bra       cheksig2
CrsrOn              leax      >curon,pcr
                    ldy       #2                  cursor on number of bytes
WritCrsr            lda       #1
                    os9       I$Write
                    clrb
                    rts
CFExit              bsr       CrsrOn
                    puls      x,b
                    ldy       #1
* end of mod
                    clra
                    os9       I$Read
                    bcs       cheksig2
                    rts

* modification by BRI
* clears old signal, traps BREAK,
* cleans up before reporting other errors
* (fixes shift-BREAK/control-BREAK in edit mode and
* error report stack clean up bugs)
* cheksig2 cmpb #2 BREAK key signal?
* lbne error no, process error
* com hexascii yes, toggle hex/ascii flag
* leas 2,s pull return addr off stack
* bra edinput loop back
cheksig2            leas      $02,s
                    clr       <SgnlCode
                    cmpb      #2                  break key
                    beq       TrapSgnl
                    pshs      b
                    lbsr      reset
                    clr       <rownum
                    puls      b
                    lbra      error
TrapSgnl            com       <hexascii
                    lbra      edinput
* end of mod

* input a hex byte
inputbyt            bsr       readit
                    bsr       digit
                    bcs       edcurs
                    lbsr      writeout
                    ldb       ,x
* modification by BRI
* bsr readit read another char
                    lbsr      readit
* end modification
                    bsr       digit
                    bcs       edcurs
                    exg       a,b
                    lbsr      asciihex
                    stb       [<edbufptr,u]
                    lda       #1
                    sta       <wrtflag
                    bra       movert

* Check to see if char is valid hex digit.
* Exit with Carry set if not valid.
digit               lda       ,x
                    cmpa      #'0
                    bcs       notdig
                    cmpa      #'9
                    bls       gotdig
                    anda      #$5F                lower to upper
                    cmpa      #'F
                    bhi       notdig
                    cmpa      #'A
                    bcs       notdig
gotdig              andcc     #$FE
                    rts
notdig              orcc      #1
                    rts

* Input single ASCII character

* modification by BRI
*inputchr bsr readit read char
inputchr            lbsr      readit
* end of mod
                    lda       ,x
                    cmpa      #$20
                    bcs       edcurs
                    sta       [<edbufptr,u]
                    lda       #1
                    sta       <wrtflag
                    bra       movert

* check if char is an arrow
edcurs              cmpa      #9                  right arrow
                    beq       movert
                    cmpa      #8                  left arrow
                    beq       movelt
                    cmpa      #$0C                up arrow
                    lbeq      moveup
                    cmpa      #$0A                down arrow
                    lbeq      movedn
                    cmpa      #$0D                CR
                    lbne      edinput
* exit edit routine
                    lbsr      reset
                    ldd       #$4934
                    lbsr      movecurs
                    lbsr      clrline
                    clr       <rownum
                    lbra      getcmd

* move to next screen byte
movert              lbsr      reset
                    tst       <seclen+1
                    beq       rtptr
                    lda       <edpos
                    cmpa      <seclen+1
                    lbeq      topleft
rtptr               ldd       <edbufptr
                    addd      #1
                    std       <edbufptr
                    inc       <edpos
displyrt            inc       <asciicol
                    lda       <asciicol
                    cmpa      #$68                end of row
                    bcc       rowdn
                    lda       <hexcol
                    adda      #3                  3 columns used per byte
                    sta       <hexcol
                    lbra      revbyte
rowdn               inc       <rownum
                    lda       <rownum
                    cmpa      #$32
                    lbhi      topleft
                    lda       #$25
                    sta       <hexcol
                    lda       #$58
                    sta       <asciicol
                    lbra      revbyte

* move to previous byte
movelt              bsr       reset
                    ldd       <edbufptr
                    subd      #1
                    std       <edbufptr
                    dec       <edpos
                    dec       <asciicol
                    lda       <asciicol
                    cmpa      #$58
                    bcs       rowup
                    lda       <hexcol
                    suba      #3
                    sta       <hexcol
                    lbra      revbyte
rowup               dec       <rownum
                    lda       #$52
                    sta       <hexcol
                    lda       #$67
                    sta       <asciicol
                    lda       <rownum
                    cmpa      #$23
                    bcs       gobot
                    lbra      revbyte
gobot               ldx       <edbufptr
                    ldb       <seclen+1
                    beq       botptr
                    stb       <edpos
                    clra
                    leax      d,x
                    decb
                    pshs      b
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    addb      #$23
                    stb       <rownum
                    lda       ,s+
                    anda      #$0F
                    pshs      a
                    adda      #$58
                    sta       <asciicol
                    puls      a
                    ldb       #3
                    mul
                    addb      #$25
                    stb       <hexcol
                    bra       savebot
botptr              lda       #$32                bottom row
                    sta       <rownum
                    leax      $100,x
savebot             stx       <edbufptr
                    lbra      revbyte

* reset from reverse video to normal
reset               lbsr      normdisp
                    lbra      eddisply

* move up a row
moveup              bsr       reset
                    ldb       <seclen+1
                    beq       moveup1
                    lda       <rownum
                    cmpa      #$23
                    beq       moveup2
moveup1             ldd       <edbufptr
                    subd      #$10
                    std       <edbufptr
                    ldb       <edpos
                    subb      #$10
                    stb       <edpos
                    dec       <rownum
                    lda       <rownum
                    cmpa      #$23
                    bcc       updone
                    lda       #$32
                    sta       <rownum
                    ldd       <edbufptr
                    addd      #$100
                    std       <edbufptr
updone              lbra      revbyte

moveup2             andb      #$F0
                    lda       <seclen+1
                    anda      #$0F
                    cmpa      <edpos
                    bcc       moveup3
                    subb      #$10
moveup3             clra
                    pshs      b,a
                    ldd       <edbufptr
                    addd      ,s+
                    std       <edbufptr
                    ldb       <edpos
                    addb      ,s
                    stb       <edpos
                    puls      b
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    addb      #$23
                    stb       <rownum
                    bra       updone

movedn              bsr       reset
                    ldb       <seclen+1
                    beq       movedn1
                    subb      <edpos
                    cmpb      #$10
                    bcs       movedn2
movedn1             ldd       <edbufptr
                    addd      #$0010
                    std       <edbufptr
                    lda       <edpos
                    adda      #$10
                    sta       <edpos
                    inc       <rownum
                    lda       <rownum
                    cmpa      #$32
                    lbls      revbyte
                    ldd       <edbufptr
                    subd      #$100
                    std       <edbufptr
topptr              lda       #$23
                    sta       <rownum
                    lbra      revbyte
movedn2             clra
                    ldb       <edpos
                    decb
                    andb      #$F0
                    pshs      b,a
                    ldd       <edbufptr
                    subd      ,s+
                    std       <edbufptr
                    ldb       <edpos
                    subb      ,s+
                    stb       <edpos
                    bra       topptr

* start a temporary shell
goshell             lbsr      clrscr
                    lda       <oldecho
                    sta       <echobyte
                    bsr       echo
                    leax      >shell$,pcr
                    ldy       #$10
                    leau      >i.o.buff,u
                    lda       #$0D
                    sta       ,u
                    ldd       #0
                    os9       F$Fork
                    lbcs      error
                    os9       F$Wait
                    ldu       <Usave
                    leax      >inbuff,u
                    stx       <buffptr
                    clr       <echobyte
                    bsr       echo
cReturn             lbsr      clrscr
                    lbra      disploop

* read in option section of path and toggle echo
echo                pshs      x
                    leas      <-$20,s
                    leax      ,s
                    clra
                    clrb
                    os9       I$GetStt
                    lbcs      error
                    lda       <echobyte
                    sta       $04,x
                    clra
                    os9       I$SetStt
                    lbcs      error
                    leas      <$20,s
                    puls      pc,x

* verify CRC if valid module
verify              lbsr      movecmd
                    leax      >vrfymess,pcr
                    lbsr      pstring
                    ldu       #0
                    ldx       #0
                    stx       <fileln
                    lda       <inpath
                    os9       I$Seek
                    lbcs      error
                    ldu       <Usave
initCRC             ldd       #$FFFF
                    std       <crc
                    stb       <crc+2
                    leax      >i.o.buff,u
                    ldy       #8
                    lda       <inpath
                    os9       I$Read
                    lbcs      error
                    cmpy      #8
                    lbne      verr
                    ldd       ,x
                    cmpa      #$87                module sync byte
                    lbne      verr
                    cmpb      #$CD                ""
                    lbne      verr
                    ldd       2,x
                    cmpd      #$0F                minimum module length
                    lbls      verr
                    subd      #3                  omit old CRC
                    std       <vmodlen
                    addd      <fileln
                    std       <fileln
* check header parity
                    clra
                    ldb       #8
hedpar              eora      ,x+
                    decb
                    bne       hedpar
                    coma
                    sta       ,x
                    ldy       #1
                    lda       <inpath
                    os9       I$Write
                    lbcs      error
                    ldd       <vmodlen
                    subd      #9
                    std       <vmodlen
                    leax      >i.o.buff,u
                    ldy       #9
                    bsr       CRCcal
bytsleft            lda       <inpath
                    ldy       #$78
                    cmpy      <vmodlen
                    bls       readmod
                    ldy       <vmodlen
readmod             os9       I$Read
                    bcs       verr
                    sty       <bytsread
                    bsr       CRCcal
                    ldd       <vmodlen
                    subd      <bytsread
                    std       <vmodlen
                    bne       bytsleft
* compare current position with header to
* prevent overwriting next module
                    lda       <inpath
                    ldb       #5
                    os9       I$GetStt
                    tfr       u,d
                    ldu       <Usave
                    cmpd      <fileln
                    bne       verr
                    com       <crc
                    com       <crc+1
                    com       <crc+2
                    leax      <crc,u
                    ldy       #3
                    lda       <inpath
                    os9       I$Write
                    lbcs      error
                    ldd       #3
                    addd      <fileln
                    std       <fileln
                    ldb       #6                  test for EOF
                    lda       <inpath
                    os9       I$GetStt
                    lbcc      initCRC
                    cmpb      #$D3                EOF
                    lbne      error
* redisplay LSN
                    lbsr      seeksec
                    lbra      disploop

* calculate CRC, regY=# of bytes to use for CRC
CRCcal              leau      <crc,u
                    os9       F$CRC
                    lbcs      error
                    ldu       <Usave
                    rts

* error with verify
verr                ldd       #$2036              cmd position
                    lbsr      movecurs
                    leax      >verrmess,pcr
                    lbsr      pstring
                    ldb       #$CD
                    lbsr      prterr
                    lbra      getcmd

* Link to a module or display all in merged file
linker              tst       <infile
                    lbne      getcmd
                    ldd       #0
                    std       <fileln
                    std       <lmodlen
                    clr       <echobyte
                    com       <echobyte
                    lbsr      echo
                    lbsr      movecmd
                    lbsr      clrline
                    leax      >linkmess,pcr
                    lbsr      pstring
                    leax      <infile,u
                    ldy       #$1E
                    lbsr      readlin
                    clr       <echobyte
                    lbsr      echo
                    cmpy      #1
                    lbne      parsmod
                    lbsr      clrscr
                    clr       <infile             list all module names
                    leax      >linkhdr,pcr
                    lbsr      wrtlin1
nxtmod              ldd       <lmodlen
                    addd      <fileln
                    std       <fileln
                    tfr       d,u
                    ldx       #0
                    lda       <inpath
                    os9       I$Seek
                    bcs       moderr
                    ldu       <Usave
                    leax      >i.o.buff,u
                    ldy       #6
                    os9       I$Read
                    bcs       moderr
                    ldd       ,x++
                    cmpa      #$87
                    bne       moderr1
                    cmpb      #$CD
                    bne       moderr1
                    leay      >i.o.buff,u
                    ldd       ,x++
                    std       <lmodlen
                    ldd       ,x++
                    pshs      d
                    ldd       <fileln
                    bsr       convert2
                    lda       #$20
                    sta       ,y+
                    ldd       <lmodlen
                    bsr       convert2
                    lda       #$20
                    sta       ,y+
                    ldd       <fileln
                    addd      ,s++
                    tfr       d,u
                    ldx       #0
                    lda       <inpath
                    os9       I$Seek
                    lbcs      error
                    ldu       <Usave
                    tfr       y,x
                    ldy       #$1D
                    lda       <inpath
                    os9       I$Read
                    lbcs      error
namend              lda       ,x+
                    bpl       namend
                    anda      #$7F                look for fcs delimiter
                    sta       -1,x
                    lda       #$0D                CR
                    sta       ,x
                    leax      >i.o.buff,u
                    lbsr      wrtlin1
                    bra       nxtmod

convert2            lbsr      convert1
                    tfr       b,a
                    lbra      convert1

moderr2             cmpb      #$D3                e$e0f
                    bne       moderr
                    ldb       #$DD                module not found
                    bra       moderr
moderr1             ldb       #$CD                bad module ID
moderr              clr       <infile
                    cmpb      #$D3                end of file
                    lbne      error
                    lbsr      read1
                    leax      >inbuff,u
                    stx       <buffptr
                    lbra      cReturn

parsmod             os9       F$PrsNam
                    lbcs      error
                    stb       <modnmlen
                    decb
                    lda       b,x
                    ora       #$80                fcs format
                    sta       b,x
                    stx       <crc
                    ldu       #0
modloop             ldx       #0
                    lda       <inpath
                    os9       I$Seek
                    lbcs      error
                    ldu       <Usave
                    leax      >i.o.buff,u
                    ldy       #6
                    os9       I$Read
                    bcs       moderr2
                    ldd       ,x++
                    cmpa      #$87                module sync code
                    bne       moderr1
                    cmpb      #$CD                ""
                    bne       moderr1
                    ldd       ,x++
                    std       <lmodlen
                    ldd       ,x
                    addd      <fileln
                    tfr       d,u
                    ldx       #0
                    lda       <inpath
                    os9       I$Seek
                    bcs       moderr2
                    ldu       <Usave
                    leax      >i.o.buff,u
                    ldy       #$1D
                    os9       I$Read
                    bcs       moderr2
                    tfr       x,y
                    ldx       <crc
                    ldb       <modnmlen
                    os9       F$CmpNam
                    bcc       newbase
                    ldd       <lmodlen
                    addd      <fileln
                    std       <fileln
                    tfr       d,u
                    bra       modloop

* set offset to module so effective LSN is $00
newbase             lda       #$0D                CR
                    sta       b,x                 delimit name
                    decb
                    lda       b,x                 last character
                    anda      #$7F                clear marker
                    sta       b,x
                    ldd       <fileln
                    std       <offset
                    ldd       #6
                    leax      lsn,u
nbloop              sta       ,x+
                    decb
                    bne       nbloop
                    lbra      readloop

* display module name and offset
prntmod             ldd       #$3020              mod position
                    lbsr      movecurs
                    leax      >modnmhdr,pcr
                    lbsr      pstring
                    leax      <infile,u
                    lbsr      wrtlin1
                    ldd       #$5820              offset position
                    lbsr      movecurs
                    leax      >offmess,pcr
                    lbsr      pstring
                    leay      >i.o.buff,u
                    ldd       <offset
                    lbsr      convert2
                    lda       #$0D                CR
                    sta       ,y
                    lbra      writeout

* unlink module and restore LSN to that of file
unlinker            tst       <infile
                    lbeq      getcmd
                    ldd       #8
                    leax      lsn,u
unloop              sta       ,x+
                    decb
                    bne       unloop
                    ldd       #$3020              mod position
                    lbsr      movecurs
                    lbsr      clrline
                    lbsr      clrline
                    clr       <infile
                    lbra      readloop

* toggle expert mode - edits and zaps are auto-written
expert              tst       <xprtflag
                    beq       xprton              turn flag on if not on
                    clr       <xprtflag
                    ldd       #$5933              expert position
                    lbsr      movecurs
                    lbsr      clrline
xprtout             lbra      getcmd
xprton              lbsr      rusure
                    bne       xprtout
                    com       <xprtflag
                    ldd       #$5933              expert position
                    lbsr      movecurs
                    leax      >xprtmess,pcr       display EXPERT
                    lbsr      pstring
                    bra       xprtout

help                lbsr      clrscr
                    leax      >helper,pcr
                    ldy       #helpchrs
                    lbsr      wrtlin2
                    leax      >i.o.buff,u
                    lbsr      read1
                    lbra      cReturn

find                clr       <echobyte
                    com       <echobyte
                    lbsr      echo
                    lbsr      movecmd
                    lbsr      clrline
                    tst       <FhexAsc            hex or ascii mode?
                    bne       charfind            go if ascii
                    leax      >findbyte,pcr
                    lbsr      pstring
                    ldy       #$21
                    lbsr      FRead
                    cmpy      #1
                    lbeq      exitfind
                    leay      -1,y
                    tfr       y,d
                    lsrb
                    lbcs      badfind
                    stb       <TargLen
                    leau      <findstr,u
* convert 2 bytes pointed to by regX, store in regA
FConvert            lbsr      hexobjct
                    lbcs      badfind
                    sta       ,u+
                    leay      -2,y
                    bne       FConvert
                    ldu       <Usave
                    bra       gofind

* input string of ascii chars
charfind            leax      >findchar,pcr
                    lbsr      pstring
                    ldy       #$11
                    lbsr      FRead
                    cmpy      #1
                    lbeq      exitfind
                    tfr       y,d
                    decb                          dump CR
                    stb       <TargLen
                    leay      <findstr,u
find20              lda       ,x+
                    sta       ,y+
                    decb
                    bne       find20

* Check if byte from target string matches byte in buffer by EOR'ing the two.
*  If they match exactly, result is 0. If in 'char' search mode, EOR results
*  in bits 5 and/or 7 being set if 2 bytes differ only by case or bit 7 status

*****************************
* Added 01/08/90 (RAK)
*
*        clr   echobyte   echo off
*        lbsr  echo
*
* END of modification
*****************************
gofind              clr       <echobyte
                    lbsr      echo
                    leax      >inbuff,u
find30              ldb       <seclen+1
                    leay      <findstr,u
find50              lda       ,y
                    eora      ,x+
                    lbeq      found1
                    tst       <FHexAsc
                    beq       find60
                    bita      #$5F                %01011111
                    lbeq      found1
find60              decb
find70              bne       find50              no match in this sector
* Modification (addition) by RAK 01/08/90
* Read a character from std in to catch a break
* key which allows aborting a <F>IND.
* Note: "finderr2" resets the stack.
                    pshs      y,x,b,a
                    clra
                    ldb       #1                  SS.Ready
                    os9       I$GetStt
                    bcs       NoKey
                    leax      >i.o.buff,u
                    lbsr      read1
                    lda       ,x
                    cmpa      #5                  catch key to abort find
                    beq       finderr2
NoKey               puls      y,x,b,a
* end of mod
                    bsr       FNxtSec
                    bra       find30

FNxtSec             tst       <infile
                    beq       find75
                    ldd       <lmodlen
                    subd      #1
                    cmpa      <lsn+2
                    beq       finderr2
find75              ldd       <lsn+1
                    addd      #1
                    std       <lsn+1
                    bne       find80
                    inc       <lsn
find80              lbsr      lsnseek
                    leax      >inbuff,u
                    stx       <buffptr
                    tst       <infile
                    beq       find256
                    ldd       <lmodlen
                    suba      <lsn+2
                    bne       find256
                    tfr       d,y
                    bra       FRdSome
find256             ldy       #$100
FRdSome             lda       <inpath
                    os9       I$Read
                    bcs       finderr
                    sty       <seclen
                    rts

* Get byte/char to find
FRead               leax      >i.o.buff,u
                    clra
                    os9       I$ReadLn
                    bcs       cheksig3
                    rts
cheksig3            leas      2,s
                    clr       <SgnlCode
                    cmpb      #2                  break key?
                    lbne      error
                    com       <FHexAsc
                    lbra      find
badfind             ldu       <Usave
                    bsr       beep
                    lbra      find

* make a beep
beep                leax      >bell,pcr
                    ldy       #1
                    lbra      writeout

* If error reading next sector was EOF, then find was unsuccessful.
* Re-read original sector and return to CMD: prompt
finderr             cmpb      #$D3                EOF
                    lbne      error
finderr2            lds       <Ssave
                    ldd       <oldlsn
                    std       <lsn
                    lda       <oldlsn+2
                    sta       <lsn+2
                    lbsr      seeksec
                    sty       <seclen
                    bsr       beep
exitfind            lbra      exitzap

found1              pshs      b
                    decb
                    stb       <Fbytes
* Save pointer (X) to next byte in buffer for search to resume if this search
*  is unsuccessful or for 'Next' command
                    stx       <findptr
                    ldb       <TargLen
find90              decb
                    beq       matched
                    dec       ,s
                    beq       find130
find100             leay      1,y
                    lda       ,y
                    eora      ,x+
                    beq       find90
                    tst       <FHexAsc
                    beq       find110
                    bita      #$5F
                    beq       find90
find110             leas      1,s
* Restore buffer pointer (X) to byte after 1st byte found that matched in
* search just completed (unsuccessfully). Restore B to # bytes left in
* sector at that point. Y = start of target string.
                    ldx       <findptr
find120             leay      <findstr,u
                    ldb       <FBytes
                    lbra      find70
* Read in next sector to complete test for match
find130             leas      1,s
                    pshs      y,b
                    lbsr      FNxtSec
                    puls      y,b
                    lda       <seclen+1
                    pshs      a
                    bra       find100

* Successful Find
*  Must determine whether target string starts in last LSN read or
*  next-to-last, for display
matched             leas      1,s
                    lda       <lsn+2
                    cmpa      <oldlsn+2
                    beq       match40
                    cmpx      <findptr
                    bcc       match30
                    ldd       <lsn+1
                    subd      #1
                    std       <lsn+1
                    cmpd      #$FFFF
                    bne       match20
                    dec       <lsn
match20             lbsr      seeksec
                    sty       <seclen
match30             ldd       <lsn
                    std       <oldlsn
                    lda       <lsn+2
                    sta       <oldlsn+2
match40             lbsr      display
* Get offset of found string from beginning of LSN
                    ldd       <findptr
                    subd      #1
                    std       <edbufptr
                    subd      <buffptr
* Now LS nib of B = col #, MS nib = row # for display
                    pshs      b
                    andb      #$0F
                    pshs      b
                    addb      #$58
                    stb       <asciicol
                    puls      b
                    lda       #$03
                    mul
                    addb      #$25
                    stb       <hexcol
                    puls      b
                    andb      #$F0
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    addb      #$23
                    stb       <rownum
                    lbsr      revdisp
                    lbsr      eddisply
                    lbsr      normdisp
                    clr       <rownum
*** This line changed from 'lbra getcmd' in Version 2.0 ***
                    lbra      exitfind

* Next Search starts from Find unless LSN changed
next                tst       <TargLen
                    lbeq      getcmd
                    lbsr      movecmd
                    leax      >srchmess,pcr
                    lbsr      pstring
                    ldx       <findptr
                    lbeq      gofind
                    lbra      find120

* Display/change file size
diddle              lbsr      movecmd
                    leax      >lenmess,pcr
                    lbsr      pstring
                    com       <zeroflag
                    leay      >i.o.buff,u
                    ldd       <FileLen
                    lbsr      convert1            nibble to ascii
                    tfr       b,a
                    lbsr      convert1            second nibble
                    ldd       <FileLen+2
                    lbsr      convert1            third nibble
                    clr       <zeroflag
                    tfr       b,a
                    lbsr      convert1
                    ldd       #$2020
                    std       ,y++
                    std       ,y++
                    leax      >i.o.buff,u
                    stx       <bytsread
                    tfr       y,d
                    subd      <bytsread           chars to display
                    tfr       d,y
                    lbsr      writeout
                    leax      >newmess,pcr
                    lbsr      pstring
                    ldy       #9
                    lbsr      MakeHex
                    bcs       diddle
                    ldd       #$2037              command1 position
                    lbsr      movecurs
                    lbsr      rusure10
                    lbne      getcmd
                    ldx       <HexBuff
                    ldu       <HexBuff+2
                    ldb       #2                  size
                    lda       <inpath
                    os9       I$SetStt
                    lbcs      error
                    stx       <FileLen
                    stu       <FileLen+2
                    ldu       <Usave
* Make sure LSN displayed is still within file (in case file shortened).
* If not, reset display to show last LSN with new file length.
                    lda       <FileLen
                    cmpa      <lsn
                    bcs       RstLSN
                    bne       diddled
                    ldd       <FileLen+1
                    cmpd      <lsn+1
                    bls       RstLSN10
diddled             lbra      readloop

RstLSN              sta       <lsn
                    ldd       <FileLen+1
RstLSN10            tst       <FileLen+3
                    bne       RstLSN20
                    subd      #1
RstLSN20            std       <lsn+1
                    cmpd      #$FFFF
                    bne       diddled
                    dec       <lsn
                    bra       diddled

push                lda       <StackCnt
                    cmpa      #$10
                    bcc       full
                    ldb       #$03
                    mul
                    leax      >Stack,u
                    leax      b,x
                    ldd       <lsn
                    std       ,x++
                    lda       <lsn+2
                    sta       ,x
* Now that LSN is on stack, check to make sure it isn't the last one
* pushed, as well. If so, don't increment StackCnt, which effectively
* cancels the Push operation.
                    tst       <StackCnt
                    beq       pushOK
                    cmpa      -$03,x
                    bne       pushOK
                    ldd       <lsn
                    cmpa      -5,x
                    beq       pushed
pushOK              inc       <StackCnt
pushed              lbra      getcmd

* Stack is full - display message
full                lbsr      movecmd
                    leax      >bell,pcr
                    lbsr      pstring             full message
                    lbsr      read1
                    bra       pushed

restore             lda       <StackCnt
                    beq       pushed
                    ldb       #3
                    mul
                    subb      #3
                    leax      >Stack,u
                    leax      b,x
                    ldd       ,x++
                    std       <lsn
                    lda       ,x
                    sta       <lsn+2
                    dec       <StackCnt
                    lbra      readloop

* This is a general purpose 16x16 bit multiplication.
* regD is first number, regX is second number.
* Returns answer in regY and regU.
mulDbyX             pshs      u,y,x,b,a
                    clr       4,s
                    lda       3,s                 lower word of regX times regB
                    mul
                    std       6,s
                    ldd       1,s                 upper word of regX times regB
                    mul
                    addb      6,s
                    adca      #$00
                    std       5,s
                    ldb       ,s                  original regA
                    lda       3,s                 upper word regX
                    mul
                    addd      5,s
                    std       5,s
                    bcc       mulDX2              L171D
                    inc       4,s
mulDX2              lda       ,s
                    ldb       2,s
                    mul
                    addd      4,s
                    std       4,s
                    puls      pc,u,y,x,b,a

* Looks like 16*regX
mul16B              pshs      x,b,a
                    lda       #$10
                    pshs      a
                    clra
                    clrb
mul16B2             lsl       4,s
                    rol       3,s
                    rolb
                    rola
                    cmpd      1,s
                    bcs       mul16B3
                    subd      1,s
                    inc       4,s
mul16B3             dec       ,s
                    bne       mul16B2
                    ldx       3,s
                    leas      5,s
                    rts

prntBAM             ldd       #$2034
                    lbsr      movecurs
                    tst       clustflg
                    bne       csf9
                    leax      BAMmess1,pcr
                    bra       csf10
csf9                leax      BAMmess2,pcr
csf10               lbsr      pstring
                    leay      >i.o.buff,u
                    pshs      y
                    ldd       <BAMstart           get 3 byte address and display it
                    lbsr      convert1            convert hex to ascii
                    tfr       b,a
                    lbsr      convert1            convert hex to ascii
                    lda       <BAMstart+2
                    lbsr      convert1            convert hex to ascii
                    lda       ,-y
                    ora       #$80
                    sta       ,y
                    ldd       #$3234
                    lbsr      movecurs
                    ldx       ,s
                    lbsr      pstring
                    ldy       ,s
                    ldd       <BAMstop
                    lbsr      convert1
                    tfr       b,a
                    lbsr      convert1
                    lda       <BAMstop+2
                    lbsr      convert1
                    lda       ,-y
                    ora       #$80
                    sta       ,y
                    ldd       #$3D34
                    lbsr      movecurs
                    puls      x
                    lbsr      pstring
                    rts

togCS               com       <clustflg
                    lbra      cReturn

                    emod
eom                 equ       *

                    end
