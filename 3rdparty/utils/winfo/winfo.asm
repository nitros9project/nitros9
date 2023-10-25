                    nam       WInfo
                    ttl       OS9 Level II sub to get window information - Ron Lammardo

*
* 11/22/87 - Edition #1 - for OS9 Level II V02.00.01
* 12/22/95 - Edition #2 - for ALL versions of OS-9 by Alan DeKok
* 01/20/2010 - Edition #3 - for vtio instead of cc3io Willard Goosey
*

                    ifp1
                    use       defsfile
                    endc

typelang            set       sbrtn+objct
attrev              set       reent+revision
revision            set       1

                    mod       Eom,Mname,Typelang,Attrev,Start,Datend

mname               fcs       /WInfo/
edition             fcb       3                   edition

                    org       0
                    use       winfodefs

                    org       0
stackadr            rmb       2                   stack address for return
de                  rmb       1                   device table entry #
sctype              rmb       1                   screen type
offset              rmb       2                   screen start offset in block
datimg              rmb       2                   address of sys DAT image in sysprc
datadr              rmb       2                   address of sys DAT in system
entry               rmb       2                   address of currently proccessed window entry
wnum                rmb       1                   window entry number
scrblock            rmb       1                   block # containing screen mem
blockcnt            rmb       1                   # of blocks in screen
wstart              rmb       2                   x,y coordinates of window start on screen
wsize               rmb       2                   x,y size of window
cwstart             rmb       2                   x,y coordinates of current working area
cwsize              rmb       2                   x,y size of current working area
paramadr            rmb       2                   address of window name to dump
paramln.            rmb       1
paramln             rmb       1                   size of window name to dump
vdgadr              rmb       2                   address of vdg screen
vdgflag             rmb       1                   vdg screen flag (1=yes)
scrnaddr            rmb       2                   address of screen
d$devtbl            rmb       2                   address of device table
mdname              rmb       2                   adress of module name
drvnam              rmb       2                   address of device driver name
buffaddr            rmb       2                   address of return packet
buffln.             rmb       1                   dummy byte
buffln              rmb       1                   length of return packet..must be > WI$size
weaddr              rmb       2                   logical address of window entry insys map  (debugging only)
devmaddr            rmb       2                   device static storage entry in sys map  (debugging only)
fgc                 rmb       1                   foreground color
bgc                 rmb       1                   background color
bdc                 rmb       1                   border color
curx                rmb       1                   x coordinate of cursor
cury                rmb       1                   y coordinate of cursor
bpr                 rmb       2                   bytes per row
stymark             rmb       1                   screen type marker byte
paltaddr            rmb       2                   address of palette registers
msb                 rmb       1                   working field - msb for 2 digit mults
lsb                 rmb       1                   working field - lsb for 2 digit mults
lset                rmb       1                   logic set #
psetgb              rmb       2                   pset group/buffer
fontgb              rmb       2                   font group/buffer
gcurgb              rmb       2                   gfx cursor group/buffer
minidat             rmb       2                   temp dat for cpymem
bfngrp              rmb       2                   buffer #/group return
drawcrsr            rmb       4                   draw cursor position - xxyy
sysdat              rmb       16                  system DAT image
devname             rmb       5                   device descriptor name
devtable            rmb       9                   device table entry
devmem              equ       .                   device memory copy
sc                  rmb       32                  screen table
we                  rmb       64                  window entry
                    rmb       32                  filler so we got 128 bytes for dev memory
datend              equ       .

E$Param             equ       $38                 bad Parameter error

vtio                fcs       /VTIO/              used to compare device driver name
vtiolen             equ       *-vtio

tmpdat              fcb       0,0                 mini-dat image for block 0 data fetches

blnkpalt            fcb       $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
                    fcb       $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

stytable            fcb       $01,$03,$03,$0f
blktable            fcb       1,1,0,0,2,2,4,4

errmsg1             equ       *
                    fcc       /Requested device not in device table/
errm1ln             equ       *-errmsg1
errmsg2             fcc       /Requested device is not VTIO/
errm2ln             equ       *-errmsg2
errmsg3             fcc       /Can not access window until written to/
errm3ln             equ       *-errmsg3

start               equ       *
                    pshs      u,dp                save registers
                    tfr       s,d                 put in 'd' for computations
                    clrb                          clear lsb
                    suba      #1                  bump down page to make sure we don't conflict
                    tfr       a,dp                now set direct page
                    tfr       d,u                 and set u register
                    sts       <stackadr           save address of stack
                    leax      stackadr+2,u        start adrress of bytes to init
                    ldb       #devtable           end addr..# of bytes to clear
                    lda       #$ff                fill character
                    lbsr      zapblock            init the characters

* get passed parameters

                    ldx       5,s                 # of parameters
                    cmpx      #2                  do we have two params?
                    lbne      badparms            no...error
                    ldx       7,s                 1st param addr (window name addr)
                    stx       <paramadr           save the window name addr
                    os9       F$PrsNam            get end of name
                    lbcs      exit                exit on error
                    clra                          clear msb
                    std       <paramln.           save window name length
                    ldx       11,s                2nd param addr (buffer addr)
                    stx       <buffaddr           save the buffer address
                    ldx       13,s                2nd param length
                    stx       <buffln.            save the buffer length address
                    cmpx      #WI$Size            check if buffer big enough
                    lblo      smllbuff            no..send buffer to small status

* clear return buffer

                    ldx       <buffaddr           address of return buffer
                    ldb       #WI$ermsg           end address to init
                    lda       #$ff                fill char
                    lbsr      zapblock            zap the block
                    ldb       #40                 # of bytes to init
                    lda       #$20                space fill
                    lbsr      zapblock            zap the message

* get system process descriptor for sys DAT image

                    leax      tmpdat,pcr          addr of sys mini-dat
                    tfr       x,d                 put it in d
                    ldx       #$004C              Addr of dat image in system direct page
                    ldy       #2                  2 bytes to get
                    pshs      u                   save u
                    leau      datadr,u            addr of receiver
                    os9       F$CpyMem            get it
                    puls      u                   restore u
                    lbcs      exit                exit on error
                    leax      tmpdat,pcr          addr of sys mini-data
                    tfr       x,d                 put it in d
                    ldx       datadr,u            physical addr of sys DAT in sys addr map
                    pshs      u                   save u
                    leay      sysdat,u            addr of receiver
                    sty       <datimg             save it for later
                    tfr       y,u                 put in u for call
                    ldy       #16+16+1            16 bytes to get in image
                    os9       F$CpyMem            get it
                    puls      u                   restore u
                    lbcs      exit                and exit on error

                    ldx       <datimg             get ptr to system DAT image
                    lda       16+16,x             grab Level III SCF map info
                    beq       not.l3
                    sta       3,x
                    inca
                    sta       5,x

* get offset in system map to device tables
not.l3              ldy       #2                  2 bytes to get
                    ldd       <datimg             addr of sys DAT image
                    ldx       #D.DevTbl           addr of device table addr
                    pshs      u                   save u
                    leau      d$devtbl,u          addr of reciever
                    os9       F$Cpymem            get it
                    puls      u                   restore u
                    lbcs      exit                exit on error
                    clr       <de                 clear device table entry #
                    ldx       d$devtbl,u          addr of device table
                    leax      -$0D,x              back off one entry for increment in loop
                    stx       d$devtbl,u          and save it again
                    leax      devtable,u          get the addr of our copy of devtable
                    stx       <entry              save the entry addr for later

* just do an I$Attach instead of rooting through the device table

                    lda       #READ.              read-only permissions
                    ldx       <paramadr           point to window name
                    pshs      u                   save for later
                    os9       I$Attach            get U=address of device table entry
                    puls      x                   kill end of device name pointer
                    lbcs      error1              exit on error

                    os9       I$Detach            so link count is correct
                    exg       x,u                 now U=memory, and X=ptr to device table entry

                    leay      devtable,u          addr of reciever
                    pshs      u                   save u
                    tfr       y,u                 put reciever addr in u
                    ldy       #9                  copy table entry
                    ldd       <datimg             addr of sys DAT image
                    os9       F$Cpymem            get it
                    puls      u                   restore u
                    lbcs      exit                exit on error
                    leax      devtable,u
                    lda       V$USRS,x            test for entry in use
                    lbeq      error3              if not in use...give out error saying so

* Alan DeKok's mod: lots of code removed here

* get driver name offset

                    ldx       <entry              get device entry address
                    ldx       V$DRIV,x            get driver module start addr
                    leax      M$Name,x            get addr of module name
                    ldy       #2                  get 2 bytes
                    ldd       <datimg             addr of sys DAT image
                    pshs      u                   save u
                    leau      mdname,u            addr of reciever
                    os9       F$CpyMem            get it
                    puls      u                   restore u
                    lbcs      exit                exit on error

* now get actual driver name

                    ldx       <entry              addr of deice entry
                    ldd       V$DRIV,x            driver module start addr
                    addd      mdname,u            + module offset to driver name
                    tfr       d,x                 put it in x so we can grab it
                    ldy       #vtiolen            length of name
                    ldd       <datimg             addr of sys DAT image
                    pshs      u                   save u
                    leau      devname,u           addr of receiver
                    os9       F$CpyMem            get it
                    puls      u                   restore u
                    lbcs      exit                exit on error

* we got the requested device...now see if its vtio

                    ldb       #vtiolen            N bytes to compare
                    leax      vtio,pcr            get addr of 'VTIO'
                    leay      devname,u           get addr of the driver nam
                    os9       F$CmpNam            see if they're the same
                    lbcs      error2              if not-skip to next entry

* get the device static storage

                    ldx       <entry              addr of device entry
                    ldd       V$STAT,x            addr of static storage
                    tfr       d,x                 put in x so we can get it
                    stx       <devmaddr           save device mem addr
                    ldd       <datimg             addr of sys DAT image
                    ldy       #$80                bytes to get
                    pshs      u                   save u
                    leau      devmem,u            addr of receiver
                    os9       F$CpyMem            get it
                    puls      u                   restore u
                    lbcs      exit                exit on error

* get the window entry number

                    leax      devmem,u            addr of device mem
                    lda       $35,x               offset to window entry #
                    sta       wnum,u              save it

* check if its a vdg screen

                    clr       <vdgflag            else clear the flag
                    leax      devmem,u            addr of device memory
                    lda       6,x                 offset to window type
                    anda      #$80                check the high bit
                    lbeq      vdgscrn             if not set,its a vdg screen so jump

* get actual window entry

                    lda       wnum,u              window entry #
                    ldb       #64                 window entry size
                    mul                           find offset
                    addd      #$1280              add it to start of window entrys
                    std       <weaddr             save window entry address
                    tfr       d,x                 put in x so we can get it
                    ldy       #64                 64 bytes to get in window entry
                    ldd       <datimg             addr of sys DAT image
                    pshs      u                   save u
                    leau      we,u                addr of receiver
                    os9       F$CpyMem            get it
                    puls      u                   restore u
                    lbcs      exit                exit on error


* check if window ok

                    lda       we,u                check msb of screen table address
                    cmpa      #$ff                is it valid ???
                    lbeq      error3              send error message

* get screen table entry

                    ldx       we,u                address of screen table
                    ldy       #32                 32 bytes in screen table
                    ldd       <datimg             addr of sys DAT image
                    pshs      u                   save u
                    leau      sc,u                addr of receiver
                    os9       F$CpyMem            get it
                    puls      u                   restore u
                    lbcs      exit                exit on error
                    leax      sc,u                address of screen table
                    ldb       5,x                 border prn
                    stb       <bdc                save it
                    ldb       ,x                  screen type
                    stb       <stymark

* remove bias to get actual screen type

                    cmpb      #$80
                    bls       lowtype
                    ldb       #4                  4 = 16 colors possible
                    stb       <stymark            make that the screen type marker
                    ldb       #$87
                    subb      ,x
                    bra       getblock
lowtype             equ       *
                    addb      #4
getblock            equ       *
                    stb       <sctype             save the screen type
                    decb                          decrement for indexing
                    leax      blktable,pcr        address of block count table
                    lda       b,x                 get block count (via indexing table)
                    sta       <blockcnt           save it
                    leax      sc,u                address of screen table
                    lda       1,x                 get first block used
                    sta       <scrblock           save it
                    leax      16,x                address of palettes
                    stx       <paltaddr           save it for later
                    leax      we,u                addr of window entry

* get screen start in block

                    leax      $34,x               screen start
                    lda       ,x+                 get msb
                    suba      #$80                ?????
                    ldb       ,x+                 get lsb
                    std       <offset             save screen offset
                    ldy       ,x++                get screen start coordinates
                    sty       <wstart             save them
                    ldd       ,x++                get screen size (x,y)
                    std       <wsize              save it
                    leax      we,u                get start of window entry
                    leax      5,x                 addr of cwarea start
                    ldy       ,x++                working area start coordinates
                    sty       <cwstart            save them
                    ldd       ,x++                working area size coordinates
                    std       <cwsize             save them
                    cmpd      <wsize              see if its same as total window size
                    beq       getbpr              if it is,skip next section

* adjust block offset to take change working area into account

                    clr       <msb                clear temp area
                    lda       <cwstart            x offset of area
                    lsla                          multiply by 2 for attribute bytes
                    sta       <lsb                save it
                    lda       <cwstart+1          y offset of area
                    lsla                          multiply by 2 for attribute bytes
                    ldb       <wsize              x-size of window
                    mul                           mulitply
                    addd      <msb                add x offset of area
                    addd      <offset             add original block offset
                    std       <offset             save new block offset

* get # of bytes per row and cursor coordinates

getbpr              equ       *
                    ldx       #$1075              address of gfx table start pointer
                    ldy       #2                  # of bytes to get
                    ldd       <datimg             addr of sys DAT image
                    pshs      u                   save u
                    leau      msb,u               addr of receiver
                    os9       F$Cpymem            get it
                    puls      u                   restore u
                    lbcs      exit                exit on error
                    lda       <wnum               get window entry number
                    ldb       #$12                size of gfx table entry
                    mul                           get the offset to start of our gfx window entry
                    addd      #1                  add 1 for draw cursor start
                    ldx       <msb                load addr of table start
                    leax      d,x                 and add offset
                    ldy       #4                  get 4 bytes
                    ldd       <datimg             addr of sys DAT image
                    pshs      u                   save u
                    leau      drawcrsr,u          addr of receiver
                    os9       F$Cpymem            get it
                    puls      u                   restore u
                    lbcs      exit                exit on error

                    clr       <curx               clear fields
                    clr       <cury
                    leax      we,u                address of window entry
                    ldd       $14,x               butes per row
                    std       <bpr                save bytes per row

* get foreground/background prn's

                    leay      stytable,pcr        addr of screen type mask table
                    ldb       <stymark            get sty marker byte
                    decb                          decrement for indexing
                    leay      b,y                 addr of mask (via indexing)
                    ldd       $16,x               get fore/back palette #'s
                    anda      ,y                  strip of bias againt mask
                    andb      ,y
                    sta       <fgc                save foreground prn
                    stb       <bgc                save background prn

                    lda       $1A,x               logic set #
                    sta       <lset               save it
                    lda       $1B,x               block # of font
                    ldy       $1C,x               block offset of font
                    lbsr      fetchit             get group/buffer of font
                    std       <fontgb             save it
                    lda       $1E,x               block # of pset
                    ldy       $1F,x               block offset of pset
                    leay      -$20,y              back off to get header start of pset
                    lbsr      fetchit             get group/buffer of pset
                    std       <psetgb             save it
                    lda       $28,x               block # of gfx cursor
                    ldy       $29,x               block offset of gfx cursor
                    lbsr      fetchit             get group/buffer of gfx cursor
                    std       <gcurgb             save it

                    ldd       $0B,x               cursor logical address
                    subd      3,x                 subtract screen logical start
                    lbra      getcrps             get x,y cursor coords

* get block number and offset in block for VDG type screen

vdgscrn             equ       *
                    leax      blnkpalt,pcr        address of $ff's for vdg palettes
                    stx       <paltaddr           save the addr
                    lda       #$ff                fill char
                    sta       <fgc                no palettes for vdg screen
                    sta       <bgc
                    sta       <bdc
                    lda       #1                  vdgflag=1
                    sta       <vdgflag
                    sta       <blockcnt           1 block in screen
                    clra
                    clrb
                    std       <wstart             window starts at 0,0
                    std       <cwstart
                    clr       <sctype             screentype = 0
                    leax      devmem,u            address of device memory
                    ldd       $38,x               logical screen start addr
                    std       vdgadr,u            msb of vdg address
                    lsra                          divide by 16
                    lsra
                    lsra
                    lsra
                    lsra                          divide by 2
                    inca                          add 1
                    lsla                          multiply by 2
                    deca                          subtract 1
                    ldx       <datimg             addr of sys DAT image
                    ldb       a,x                 add on block # in map and get the physical block
                    stb       <scrblock           save it
                    ldd       vdgadr,u            get the physical screen address
                    anda      #%00011111          strip off block # bias
                    std       <offset             save offset within block
                    ldd       #$2010              32 * 16 screen
                    std       <cwsize             save it
                    std       <wsize              save it
                    clr       <curx               clear cursor offset counters
                    clr       <cury
                    ldd       #$0020              32 bytes/row
                    std       <bpr                save it
                    leax      devmem,u            address of device memory
                    ldd       $3C,x               cursor address
                    subd      $38,x               screen address

getcrps             equ       *
                    cmpd      <bpr                are we done getting row?
                    blo       gotycur             yes..skip this
                    subd      <bpr                subtract bytes/row
                    inc       <cury               increment row #
                    bra       getcrps             and check for more

gotycur             equ       *
                    stb       <curx               save y cursor pos
                    tst       <vdgflag            is it vdg screen??
                    bne       savexcur            yes..more processing
                    lda       <sctype             get screen type to determine divisor
                    cmpa      #5                  is it type 5 screen???
                    beq       gotxcur             go save x cursor position
                    lsrb                          divide by two to get actual offset
                    cmpa      #8                  is it type 7 screen???
                    bne       gotxcur             go save x cursor position
                    lsrb                          divide by two again

gotxcur             equ       *
                    stb       <curx               save y cursor pos
                    lbra      retbuffr            go return buffer

savexcur            equ       *
                    leax      devmem,u            address of device mem
                    lda       $37,x               screen # on display
                    bne       chkmedrs            if not 0 then its medium or hi res
                    tst       $45,x               test med-res flag
                    lbeq      retbuffr            its not hi-res gfx

chkmedrs            equ       *
                    ldb       #3                  3 bytes per screen table entry
                    mul                           get screen table offset
                    leax      $4A,x               start of screen tables
                    leax      b,x                 offset for screen #
                    inc       <vdgflag            =2 for med-res gfx
                    clr       <offset             screen starts at begin of block
                    clr       <offset+1
                    lda       ,x+                 get start block
                    sta       <scrblock           save it
                    lda       ,x+                 get block count
                    lbne      vdghires            if there its a hi-res
                    ldx       #$0180              BPR for med-res vdg screen
                    stx       <bpr                save it for later
                    lda       #%00010000          default mode of 1
                    leax      devmem,u            get start of device mem again
                    tst       $3f,x               screen mode
                    bpl       vdgtyp1             if its is..go save it
                    clra                          make the mode=0

vdgtyp1             equ       *
                    ora       $66,x               foreground color
                    sta       <sctype             thats our screen type
                    lbra      retbuffr            go return buffer

* hi res vdg screen

vdghires            equ       *
                    sta       <blockcnt           save the block count
                    lda       ,x                  get the screen type
                    sta       <sctype             save it
                    ldy       #$2818              sizex/sizey for screen type 0,1,2
                    ldx       #$0280              BPR for screen type 0,1,2
                    cmpa      #2                  is screen type <= 2
                    bls       vdgbpr              if yes..go save BPR
                    ldy       #$5018              BPR for screen types 3,4
                    ldx       #$0500              BPR for screen types 3,4

vdgbpr              equ       *
                    sty       <wsize              save the size
                    sty       <cwsize             same for current working size
                    stx       <bpr                save the bytes per row
                    leax      devmem,u            get address of device mem again
                    leax      $6B,x               address of palettes
                    stx       <paltaddr           save it for later
                    inc       <vdgflag            =3 (hi res vdg)
                    lbra      retbuffr

* dump the screen

retbuffr            equ       *
                    ldx       <buffaddr           address of return buffer
                    clra
                    sta       WI$stat,x           status is ok (=0)
                    lda       <vdgflag
                    sta       WI$vdg,x
                    lda       <sctype
                    sta       WI$sty,x
                    lda       <scrblock
                    sta       WI$block,x
                    lda       <blockcnt
                    sta       WI$blcnt,x
                    ldd       <offset
                    std       WI$offst,x
                    lda       <wstart
                    sta       WI$cpx,x
                    lda       <wstart+1
                    sta       WI$cpy,x
                    lda       <wsize
                    sta       WI$szx,x
                    lda       <wsize+1
                    sta       WI$szy,x
                    lda       <cwstart
                    sta       WI$cwcpx,x
                    lda       <cwstart+1
                    sta       WI$cwcpy,x
                    lda       <cwsize
                    sta       WI$cwszx,x
                    lda       <cwsize+1
                    sta       WI$cwszy,x
                    lda       <curx
                    sta       WI$curx,x
                    lda       <cury
                    sta       WI$cury,x
                    ldd       <bpr
                    std       WI$bpr,x
                    leay      we,u
                    lda       $19,y
                    sta       WI$cbsw,x
                    lda       <bdc
                    sta       WI$bdprn,x
                    lda       <fgc
                    sta       WI$fgprn,x
                    lda       <bgc
                    sta       WI$bgprn,x
                    lda       <lset
                    sta       WI$Lset,x
                    ldd       <fontgb
                    sta       WI$FntGr,x
                    stb       WI$FntBf,x
                    ldd       <psetgb
                    sta       WI$PstGr,x
                    stb       WI$PstBf,x
                    ldd       <gcurgb
                    sta       WI$GcrGr,x
                    stb       WI$GcrBf,x
                    ldd       <drawcrsr
                    std       WI$DrCrx,x
                    ldd       <drawcrsr+2
                    std       WI$DrCry,x
                    lda       edition,pcr
                    sta       WI$Edtn,x
                    ldd       <weaddr
                    std       WI$weadr,x
                    ldd       <devmaddr
                    std       WI$devm,x
                    leay      WI$pregs,x          addr of where to move palettes to
                    ldx       <paltaddr           addr of palettes
                    ldd       #16                 16 bytes to move
                    lbsr      u$movexy            move it
                    bra       clrexit             done so return from sub

badparms            equ       *
                    ldb       #E$Param            bad parameter error
                    bra       exit                go return it

clrexit             clrb                          no error..clear b reg
exit                equ       *
                    lds       <stackadr           restore stack
                    puls      u,dp                restore u and dp registers
                    clra                          clear carry bit
                    tstb
                    beq       return
                    coma                          set carry bit
return              equ       *
                    rts

zapblock            equ       *
                    sta       ,x+
                    decb
                    bne       zapblock
                    rts

* fetch 2 bytes from block [a] at offset [y]+3



fetchit             equ       *
                    clr       <minidat
                    sta       <minidat+1
                    bne       fetchok             jump if valid block #
                    clra                          else clear group #
                    clrb                          clear buffer #
                    rts

fetchok             equ       *
                    pshs      x                   save x
                    leax      3,y                 poistion to group #
                    tfr       x,d                 put in d for arithmetic
                    anda      #%00011111          strip off hig order bytes
                    tfr       d,x                 and put back in x
                    leay      minidat,u           adr of temp DAT image
                    tfr       y,d                 put in d for os9 call
                    ldy       #2                  bytes to get
                    pshs      u                   save u
                    leau      bfngrp,u            addr of receving field
                    os9       F$Cpymem            get it
                    puls      u                   restore u
                    lbcs      exit                exit on error
                    ldd       <bfngrp             put it in d for return
                    puls      x                   restore x
                    rts

* move [d] bytes from [x] to [y]

u$movexy            pshs      u
                    tfr       d,u
movexy10            lda       ,x+
                    sta       ,y+
                    leau      -1,u
                    cmpu      #0
                    bne       movexy10
                    puls      u,pc

error1              equ       *
                    ldb       #1                  error number
                    pshs      b                   save error #
                    leax      errmsg1,pcr         address of error msg
                    ldd       #errm1ln            length of error message
                    bra       moverr              go move it

error2              equ       *
                    ldb       #2                  error number
                    pshs      b                   save error #
                    leax      errmsg2,pcr         address of error msg
                    ldd       #errm2ln            length of error message
                    bra       moverr              go move it

error3              equ       *
                    ldb       #3                  error number
                    pshs      b                   save error #
                    leax      errmsg3,pcr         address of error msg
                    ldd       #errm3ln            length of error message
                    bra       moverr              go move it

moverr              equ       *
                    ldy       <buffaddr           address of return buffer
                    leay      WI$ErMsg,y          address of error message
                    lbsr      u$movexy
                    puls      b

storstat            equ       *
                    ldy       <buffaddr           address of return buffer
                    stb       WI$Stat,y           save the status byte
                    lbra      clrexit             done


smllbuff            equ       *
                    ldb       #$ff                buffer too small status #
                    bra       storstat            go store status # and exit


                    emod
eom                 equ       *

