********************************************************************
*
* hexed - NitrOS-9 / Wildbits hex editor   (companion to the File Manager)
* by: Matt Massie
*
*
* Edt/Rev  YYYY/MM/DD
* started  2026/06/27-2026/07/13
* ------------------------------------------------------------------

                    nam       hexed
                    ttl       NitrOS-9 Wildbits hex editor

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

********************************************************************
* Data
*
                    org       0
oldbg               rmb       1         caller's bg color (restore on exit)
oldfg               rmb       1         caller's fg color
savedint            rmb       1         saved Ctrl-C interrupt char
savedqut            rmb       1         saved Ctrl-E quit char
key                 rmb       1         last key read
curpath             rmb       1         open file path number
rrow                rmb       1         render: current data row (0..ROWS-1)
bcnt                rmb       1         render: byte within row (0..15)
curbyte             rmb       1         render: byte value being formatted
hexpos              rmb       1         render: column of hex pair in linebuf
rowoff              rmb       2         render: byte offset (in window) of row
addr                rmb       3         render: 24-bit address of row
pageoff             rmb       2         offset within window of current page top
winlen              rmb       2         bytes currently loaded in windowbuf
winbase             rmb       3         24-bit base: file offset, or logical addr in mem view
viewmode            rmb       1         0 = file view, 1 = logical memory view
winptr              rmb       2         where buildrow reads: &windowbuf, or a logical address
mapaddr             rmb       2         address F$MapBlk mapped the page to (mapped mode)
cpcnt               rmb       2         8K copy counter (mapped mode)
tmppage             rmb       1         page value being entered at the Ctrl-B prompt
hexbuf              rmb       2         scratch for the 2-digit page hex in the label
pathlen             rmb       1         length of path (incl CR)
i                   rmb       1         variable i
j                   rmb       1         variable j
k                   rmb       1         variable k
currow              rmb       1         cursor row within page (0..ROWS-1)
curcol              rmb       1         cursor column (0..15)
editph              rmb       1         hex edit: 0 = next digit is high nibble, 1 = low
editval             rmb       1         byte being assembled from the two typed nibbles
candidx             rmb       2         candidate page byte index (cursor move)
cellbyte            rmb       1         byte under the cursor
cellfg              rmb       1         cell paint fg
cellbg              rmb       1         cell paint bg
tmpcol              rmb       1         scratch screen column
cellbuf             rmb       2         scratch: cursor hex pair / ascii char
msx                 rmb       2         mouse x (pixels)
msy                 rmb       2         mouse y (pixels)
msbtn               rmb       1         mouse button state (1 = left)
mslastbtn           rmb       1         previous button state (edge detect)
msrow               rmb       1         clicked data row (0..ROWS-1)
msbyte              rmb       1         clicked byte within row (0..15)
mscol               rmb       1         clicked screen column (msx/8)
msscrn              rmb       1         clicked screen row (msy/8)
popts               rmb       32        device option buffer (SS.Opt)
path                rmb       80        file path from parameter, CR-terminated
linebuf             rmb       80        one rendered display line
windowbuf           rmb       8192      the 8K sliding window
oldchars            rmb    	  104       old font chars
                    rmb       250       stack space
size                equ       .

********************************************************************
* Constants
*
FG                  set       $01         frame foreground  (white)
BG                  set       $06         frame background  (blue)
HDR                 set       $05         header foreground (green)
TXT                 set       $01         hex-pane foreground (white)
TXTBG               set       $00         hex-pane background (black)
OFFS                set       $07         offset (address) foreground
TXTSEL              set       $07         selected text fg
TXTSELBG            set       $02         selected text bg
TLBC                set       $F2         D5         top left border char
TRBC                set       $F3         B8         top right border char
TTLC                set       $F4         top title left char
TTRC                set       $F5         top title right char
TBL                 set       $F6         top border line
SBL                 set       $F7         side border line
BLBC                set       $F8         bottom left border char
BRBC                set       $F9         bottom right border char
SLD                 set       $FA         solid character
UPAR                set       $FD         up arrow
DNAR                set       $FE         down arrow
LFAR                set       $FC         left arrow
RTAR                set       $FB         right arrow

ROWS                equ       32          visible data rows  (32 * 16 = 512/page)
ROWBYTES            equ       16          bytes per row
PAGEBYTES           equ       ROWS*ROWBYTES
WINBYTES            equ       8192        sliding-window size
LINEW               equ       64          rendered line width (6-digit addr)
DLINEW              equ       LINEW+6     data line buffer width incl 2 FG escapes (3 bytes each)

* Screen layout (80x60), pane centered with an 8-col blue margin
PANECOL             equ       8           left column of the pane / lines
TITLEROW            equ       1
HDRROW              equ       3           "Offset ..." column header
DASHROW             equ       4
DATAROW             equ       5           first data row (rows 5..5+ROWS-1)
NITROSROW           equ       DATAROW+ROWS+1
STATUSROW           equ       DATAROW+ROWS+3

* Keys (placeholders - see notes in mainloop; give me the real F256
* PageUp/PageDown codes and I'll add them next to these)
KUP                 equ       $0C        up arrow    (cursor up / Ctrl = page up)
KDOWN               equ       $0A        down arrow  (cursor down / Ctrl = page down)
KLEFT               equ       $08        left arrow  (cursor left)
KRIGHT              equ       $09        right arrow (cursor right)
KQUIT               equ       $11        Ctrl-Q quit
KMEM                equ       $12        Ctrl-R toggles file/memory view
KMAP                equ       $02        Ctrl-B maps a specified physical page into view

CNTLBIT             equ       %00000010  SS.KySns: Ctrl held

                    mod       eom,name,tylg,atrv,start,size
name                fcs       /hexed/

********************************************************************
* start
*
start               lbsr      getscrnsz           save caller fg/bg for restore
* ---- no file name on the command line? print usage and exit. This runs
*      before the screen is taken over or any file is opened, so nothing
*      needs restoring. ----
usksp@              lda       ,x                  skip any leading spaces
                    cmpa      #$20
                    bne       usck@
                    leax      1,x
                    bra       usksp@
usck@               cmpa      #C$CR               nothing but the terminator?
                    bne       cppath@
                    leax      UsageMsg,pcr
                    ldy       #80                 upper bound - the $0D ends it
                    lda       #1                  path 1 = stdout
                    os9       I$WritLn
                    clrb                          B = 0: no error
                    os9       F$Exit
* ---- copy the parameter path (X on entry) into our path buffer ----
cppath@             clr       <pathlen
                    leay      path,u
cp@                 lda       ,x+
                    sta       ,y+
                    inc       <pathlen
                    cmpa      #C$CR               stop at CR (param terminator)
                    beq       cpdone@
                    lda       <pathlen
                    cmpa      #78                 guard buffer
                    blo       cp@
cpdone@             lda       #C$CR               ensure CR-terminated
                    sta       ,y
* ---- init paging state ----
                    clr       <winbase
                    clr       <winbase+1
                    clr       <winbase+2
                    clr       <pageoff
                    clr       <pageoff+1
                    clr       <winlen
                    clr       <winlen+1
                    clr       <viewmode           start in file view
                    clr       <editph             not mid hex-edit
                    clr       <mslastbtn          mouse button starts up

                    lbsr      openfile            open file (errexit on failure)
                    lbsr      loadwindow          read up to 8K into windowbuf

                    lbsr      setupscreen         ScrnInit + echo/break off
                    lbsr      border              draw screen border and title
                    lbsr      winborder
                    lbsr      drawframe           title, header, dashes, status
                    lbsr      renderpage          draw the current 512-byte page
                    lbra      mainloop

********************************************************************
* openfile - open <path> for reading. On failure, restore nothing
* (screen not yet taken over) and exit with the error.
*
openfile            leax      path,u
                    lda       #READ.
                    os9       I$Open
                    bcs       errexit
                    sta       <curpath
                    rts

errexit             leax      OpenErr,pcr
                    ldy       #OpenErrLen
                    lda       #2                  stderr
                    os9       I$WritLn
                    os9       F$Exit

********************************************************************
* loadwindow - seek to winbase, read up to WINBYTES into windowbuf,
* winlen = bytes read. Called for the initial load and on every window
* slide, so files larger than 8K page through one window at a time.
*
* NOTE: assumes I$Read returns the actual byte count in Y (standard
* OS-9 behavior) - a partial read near EOF returns carry clear with the
* short count; carry set means 0 bytes (EOF/error) -> empty window.
*
loadwindow          lda       <viewmode
                    beq       lwfile@             0 = file
                    cmpa      #2
                    lbeq      loadmapped          2 = mapped physical page
                    lbra      loadmem             1 = logical 64K
lwfile@             lbsr      seekwin             position file pointer at winbase
                    lda       <curpath
                    leax      windowbuf,u
                    ldy       #WINBYTES
                    os9       I$Read
                    bcc       lwok@               carry clear: Y = bytes read (incl partial)
                    ldy       #0                  carry set (EOF/error): empty window
lwok@               tfr       y,d
                    std       <winlen
                    leax      windowbuf,u         buildrow reads out of windowbuf
                    stx       <winptr
                    rts

********************************************************************
* loadmem - logical 64K memory view. No mapping and no copy: point the
* row builder straight at logical memory, so buildrow reads the live
* bytes the CPU currently sees at each address - including the I/O and
* vector region at the top of the map. winbase is the logical address of
* the window; the 8K window slides through $0000..$FFFF. A winbase of
* $10000 or more is outside the logical map, which returns an empty
* window so paging stops cleanly at the top.
*
* (Mapping an arbitrary, not-currently-mapped page with F$MapBlk is a
*  separate future mode, not needed for the live view.)
*
loadmem             lda       <winbase            high byte of 24-bit winbase
                    bne       lmempty@            >= $10000: outside logical 64K
                    ldd       <winbase+1          low 16 bits = logical address
                    std       <winptr             buildrow reads directly from there
                    ldd       #WINBYTES
                    std       <winlen
                    rts
lmempty@            ldd       #0                  empty window -> paging reverts
                    std       <winlen
                    rts

********************************************************************
* loadmapped - examine a specific physical page that may NOT be in our
* current logical map. page = winbase >> 13 (winbase was set to page*8192
* when the page was entered, so the address column shows the physical
* address). Map one 8K block with F$MapBlk, copy it into windowbuf,
* release it with F$ClrBlk, then point buildrow at windowbuf. Pages run
* $00-$C5; beyond that (or a failed map) returns an empty window, so
* paging stops cleanly at the ends.
*
* NOTE: F$ClrBlk convention used: B = block count, U = mapped address.
*
loadmapped          ldd       <winbase            page = winbase >> 13
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb                            D = page (B = page, A = 0)
                    cmpd      #$C5
                    bhi       lmpmt@              page > $C5: out of range
                    pshs      u                   preserve data base
                    tfr       d,x                 X = page
                    ldb       #1                  one 8K block
                    os9       F$MapBlk            U = address it was mapped to
                    bcs       lmpfail@
                    stu       <mapaddr
                    puls      u                   restore data base
* copy WINBYTES from the mapped block into windowbuf (2 bytes / pass)
                    ldx       <mapaddr
                    leay      windowbuf,u
                    ldd       #WINBYTES/2
                    std       <cpcnt
lmpcp@              ldd       ,x++
                    std       ,y++
                    ldd       <cpcnt
                    subd      #1
                    std       <cpcnt
                    bne       lmpcp@
* release the mapping
                    pshs      u
                    ldu       <mapaddr
                    ldb       #1
                    os9       F$ClrBlk
                    puls      u
                    leax      windowbuf,u         buildrow reads out of windowbuf
                    stx       <winptr
                    ldd       #WINBYTES
                    std       <winlen
                    rts
lmpfail@            puls      u                   map failed: empty window
lmpmt@              ldd       #0
                    std       <winlen
                    rts

********************************************************************
* seekwin - seek the open file to the 24-bit offset in winbase.
*
* I$Seek convention used here: A=path, X=MS 16 bits, U=LS 16 bits of the
* file position. winbase is 24-bit (winbase[0]=high byte). U is our data
* base, so it's saved/restored around the call. ** If seeking misbehaves
* on hardware, this register pairing is the one spot to adjust. **
*
seekwin             pshs      u                   preserve data base
                    clra
                    ldb       <winbase            high byte (bits 16..23)
                    tfr       d,x                 X = MS word  (00:winbase[0])
                    ldd       <winbase+1          low 16 bits
                    tfr       d,u                 U = LS word
                    lda       <curpath
                    os9       I$Seek
                    puls      u                   restore data base
                    rts

********************************************************************
* winfwd / winback - advance / rewind winbase by one window (24-bit).
*
winfwd              ldd       <winbase+1
                    addd      #WINBYTES
                    std       <winbase+1
                    lda       <winbase
                    adca      #0
                    sta       <winbase
                    rts

winback             ldd       <winbase+1
                    subd      #WINBYTES
                    std       <winbase+1
                    lda       <winbase
                    sbca      #0
                    sta       <winbase
                    rts

********************************************************************
* setupscreen - take over the display the same way the FM does:
* ScrnInit (set window FG/BG, clear), echo off, Ctrl-C/Ctrl-E off.
*
setupscreen         leax      ScrnInit,pcr
                    ldy       #ScrnInitLen
                    lda       #$01
                    os9       I$Write
                    lbsr      getopts
                    lbsr      keyechooff
                    lbsr      breakoff
                    rts

********************************************************************
* drawframe - static chrome: title bar, column header, dash line,
* status line. Frame text is white-on-blue; the header/dash sit in the
* pane (white-on-black) so the whole dump reads as one black panel.
*
drawframe           lda       #FG                 frame color
                    ldb       #BG
                    lbsr      Color
                    lbsr      nitroslbl
                    lda       #PANECOL
                    ldb       #STATUSROW+9
                    leax      Status,pcr
                    ldy       #StatusLen
                    lbsr      putat
                    lda       #PANECOL
                    ldb       #STATUSROW+11
                    leax      Status2,pcr
                    ldy       #StatusLen2
                    lbsr      putat
                    lbsr      drawrefresh        "^F-Refresh Mapped Block" (mapped view only)
                    lda       #TXT
                    ldb       #TXTBG
                    lbsr      Color
                    lda       #PANECOL-2
                    ldb       #STATUSROW+2
                    leax      MMapln,pcr
                    ldy       #MMapLen
                    lbsr      putat
                    lda       #70
                    ldb       #56
                    lbsr      CurXY
                    lda       #1            stdout
                    leax      QuitLn,pcr
                    ldy       #QuitLnLen
                    os9       I$Write
                    lda       #TXT
                    ldb       #TXTBG
                    lbsr      Color
                    lda       #68
                    ldb       #51
                    lbsr      CurXY
                    leax      VerStr,pcr  
                    ldy       #VerStrLen
                    lda       #$01
                    os9       I$Write
                    lbsr      drawrw             " (read-only)" / "(read/write)" line
* header + dashes in pane colors
                    lda       #HDR
                    ldb       #TXTBG
                    lbsr      Color
                    lda       #PANECOL
                    ldb       #HDRROW
                    leax      HdrTxt,pcr
                    ldy       #LINEW
                    lbsr      putat
                    lda       #PANECOL
                    ldb       #DASHROW
                    leax      DashTxt,pcr
                    ldy       #LINEW
                    lbsr      putat
                    lbsr      showpath
                    rts

********************************************************************
* showpath - draw the current file path at (8,56) in selected-text
* colors (TXTSEL/TXTSELBG). Static, called once from drawframe.
*
showpath            lbsr      blankpath
                    lda       #TXTSEL
                    ldb       #TXTSELBG
                    lbsr      Color
                    lda       #8
                    ldb       #56
                    lbsr      CurXY
                    lda       <viewmode
                    beq       spfile@            0 = file
                    cmpa      #2
                    beq       spmap@            2 = mapped page
                    leax      MemMsg,pcr        1 = logical 64K
                    ldy       #MemMsgLen
                    bra       spput@
spfile@             leax      path,u              file view: show the path
                    clra
                    ldb       <pathlen
                    decb                          exclude trailing CR
                    tfr       d,y                 Y = visible length
                    bra       spput@
spmap@              lbsr      showmappg          mapped-page label with current page
                    lbsr      DoATTR
                    rts
spput@              lda       #1                  stdout
                    os9       I$Write
                    lbsr      DoATTR
                    rts

********************************************************************
* showmappg - draw " MAPPED PAGE $XX " on the path line, where XX is the
* current page (winbase >> 13). No fork, so it is cheap enough to refresh
* on every roam from renderpage.
*
showmappg           lda       #TXTSEL
                    ldb       #TXTSELBG
                    lbsr      Color
                    lda       #8
                    ldb       #56
                    lbsr      CurXY
                    leax      MapPfx,pcr          " MAPPED PAGE $"
                    ldy       #MapPfxLen
                    lda       #1
                    os9       I$Write
                    ldd       <winbase            page = winbase >> 13
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb                            B = page
                    tfr       b,a
                    leax      hexbuf,u
                    lbsr      byte2hex            hexbuf = 2 ASCII hex digits
                    leax      hexbuf,u
                    ldy       #2
                    lda       #1
                    os9       I$Write
                    leax      MapSfx,pcr          trailing " "
                    ldy       #MapSfxLen
                    lda       #1
                    os9       I$Write
                    rts

blankpath           lda       #FG
                    ldb       #BG
                    lbsr      Color
                    lda       #8
                    ldb       #56
                    lbsr      CurXY
                    leax      BlnkPath,pcr          memory view: show a label
                    ldy       #BlnkLen
spput@              lda       #1                  stdout
                    os9       I$Write
                    rts

border              lda       #0            re-home cursor to a safe draw origin
                    ldb       #0            (basic09 may leave it scrolled/shifted)
                    lbsr      CurXY
                    lbsr      installchars	
** draw screen
                    leas      -1,s          reserve 1 byte for stack
                    lda       #TLBC
                    sta       ,s
                    lda       #$01          stdout
                    ldy       #1            number of characters to print
                    tfr       s,x
                    os9       I$Write
                    leas      1,s           return stack to normal
                    leax      TopLine,pcr
                    ldy       #TopLineLen
                    os9       I$Write
                    leax      Title,pcr
                    ldy       #TitleLen
                    os9       I$Write
                    leax      TopLine,pcr
                    ldy       #TopLineLen
                    os9       I$Write
                    leas      -1,s          reserve 1 byte for stack
                    lda       #TRBC
                    sta       ,s
                    lda       #$01          stdout
                    ldy       #1            number of characters to print
                    tfr       s,x
                    os9       I$Write       end top title and border
                    leas      1,s           return stack to normal
                    lda       #1            start border on line 1
                    sta       <k  
                    lda       #57           # vertical lines to draw
                    sta       <i            store in i
loop@               clra                    x=0
                    ldb       <k            y=1
                    lbsr      CurXY
                    lbsr      SideBorderL
                    lda       #79           x=79
                    ldb       <k            y=1
                    lbsr      CurXY
                    lbsr      SideBorderR
                    inc       <k
                    dec       <i
                    bne       loop@         side border end
                    lda       #1            x=1
                    ldb       #54           y=54
                    lbsr      CurXY
                    leax      Selected,pcr
                    ldy       #SelectedLen
                    bra       next2@
ffile               leax      SFilename,pcr
                    ldy       #SFileLen
next2@              lda       #1            stdout
                    os9       I$Write
                    leax      Line12,pcr
                    ldy       #Line12Len
                    os9       I$Write
                    leax      AttrLn,pcr
                    ldy       #AttrLnLen
                    os9       I$Write
                    leax      TopLine,pcr
                    ldy       #TopLineLen
                    os9       I$Write
                    leax      Line3,pcr
                    ldy       #Line3Len
                    os9       I$Write       selected attr title bar end
                    lda       #0            x=0
                    ldb       #58           y=58
                    lbsr      CurXY
                    leas      -1,s          reserve 1 byte for stack
                    lda       #BLBC
                    sta       ,s
                    lda       #$01          stdout
                    ldy       #1            number of characters to print
                    tfr       s,x
                    os9       I$Write
                    leas      1,s           return stack to normal
                    lda       #1            stdout
                    leax      TopLine,pcr
                    ldy       #TopLineLen
                    os9       I$Write
                    leax      TopLine,pcr
                    ldy       #TopLineLen
                    os9       I$Write
                    leax      Line12,pcr
                    ldy       #Line12Len
                    os9       I$Write
                    leax      Line4,pcr
                    ldy       #Line4Len
                    os9       I$Write
                    leas      -1,s          reserve 1 byte for stack
                    lda       #BRBC
                    sta       ,s
                    lda       #$01          stdout
                    ldy       #1            number of characters to print
                    tfr       s,x
                    os9       I$Write
                    leas      1,s           return stack to normal
                    rts

********************************************************************
* renderpage - draw ROWS lines starting at pageoff. Each line is built
* in linebuf by buildrow, then written at (PANECOL, DATAROW+rrow).
*
renderpage          lda       #TXT                pane colors
                    ldb       #TXTBG
                    lbsr      Color
                    clr       <currow             cursor home on each fresh page
                    clr       <curcol
                    ldd       <pageoff
                    std       <rowoff             rowoff = pageoff
                    clr       <rrow
rp@                 lbsr      buildrow            fills linebuf from windowbuf[rowoff]
                    lda       #PANECOL
                    ldb       <rrow
                    addb      #DATAROW
                    leax      linebuf,u
                    ldy       #DLINEW
                    lbsr      putat
                    ldd       <rowoff
                    addd      #ROWBYTES
                    std       <rowoff
                    inc       <rrow
                    lda       <rrow
                    cmpa      #ROWS
                    blo       rp@
                    ldd       <winlen             draw the cursor unless the page is empty
                    beq       rpdone@
                    lbsr      curhi
rpdone@             lda       <viewmode           keep "MAPPED PAGE $XX" in step while roaming
                    cmpa      #2
                    bne       rprts@
                    lbsr      showmappg
rprts@              rts

********************************************************************
* buildrow - format one dump line for byte offset <rowoff> into linebuf:
*   AAAAAA HHHH HHHH HHHH HHHH HHHH HHHH HHHH HHHH  cccccccccccccccc
* Bytes at/after winlen are shown blank (spaces) on both sides.
*
buildrow            lda       #$20                fill line with spaces
                    leax      linebuf,u
                    ldb       #DLINEW
bf@                 sta       ,x+
                    decb
                    bne       bf@
* addr = winbase + rowoff  (24-bit)
                    ldd       <rowoff
                    addd      <winbase+1
                    std       <addr+1
                    lda       <winbase
                    adca      #0
                    sta       <addr
* offset color on (1B 32 OFFS), 6-digit address, then color back to TXT
* (1B 32 TXT) for the space + hex + ascii. Built sequentially from the
* start of linebuf; byte2hex advances X past each pair.
*   [0..2] 1B 32 OFFS   [3..8] addr   [9..11] 1B 32 TXT   [12] space ...
                    leax      linebuf,u
                    lda       #$1B
                    sta       ,x+
                    lda       #$32
                    sta       ,x+
                    lda       #OFFS
                    sta       ,x+
                    lda       <addr
                    lbsr      byte2hex
                    lda       <addr+1
                    lbsr      byte2hex
                    lda       <addr+2
                    lbsr      byte2hex
                    lda       #$1B
                    sta       ,x+
                    lda       #$32
                    sta       ,x+
                    lda       #TXT
                    sta       ,x+
* 16 bytes
                    clr       <bcnt
bb@                 ldd       <rowoff             idx = rowoff + bcnt
                    addb      <bcnt
                    adca      #0
                    cmpd      <winlen
                    bhs       bnext@              past data -> leave blanks
                    ldx       <winptr
                    leax      d,x                 X = &winptr[idx]
                    lda       ,x
                    sta       <curbyte
* hexpos = 13 + (bcnt>>1)*5 + (bcnt&1)*2   (+6 for the 2 leading escapes)
                    lda       <bcnt
                    lsra
                    ldb       #5
                    mul
                    addb      #13
                    lda       <bcnt
                    anda      #1
                    beq       he@
                    addb      #2
he@                 stb       <hexpos
                    leax      linebuf,u
                    ldb       <hexpos
                    abx
                    lda       <curbyte
                    lbsr      byte2hex            write 2 hex digits at X
* ascii at linebuf[54+bcnt]   (+6 for the 2 leading escapes)
                    leax      linebuf,u
                    ldb       #54
                    addb      <bcnt
                    abx
                    lda       <curbyte
                    cmpa      #$20
                    blo       np@
                    cmpa      #$7E
                    bhi       np@
                    sta       ,x
                    bra       bnext@
np@                 lda       #'.
                    sta       ,x
bnext@              inc       <bcnt
                    lda       <bcnt
                    cmpa      #ROWBYTES
                    blo       bb@
                    rts

********************************************************************
* mainloop - poll the keyboard. Up/Down arrows page within the loaded
* window; Ctrl-Q quits.
*
* PageUp/PageDown: the F256 likely sends distinct codes for these - tell
* me what they are and I'll add `cmpa #KPGUP/#KPGDN` branches right here
* alongside the arrow handling.
*
mainloop            lbsr      pollmouse
                    lbsr      INKEY
                    sta       <key
                    beq       mlkey@             no key this pass -> leave editph alone
                    lbsr      hexval             hex digit? (A = key)
                    bcc       mlkey@             yes -> keep any half-entered nibble
                    clr       <editph            no -> cancel a half-entered byte
mlkey@              lda       <key
                    cmpa      #KDOWN
                    lbeq      ondown
                    cmpa      #KUP
                    lbeq      onup
                    cmpa      #KLEFT
                    lbeq      curleft
                    cmpa      #KRIGHT
                    lbeq      curright
                    cmpa      #KMEM
                    lbeq      togglemem
                    cmpa      #KMAP
                    lbeq      onmapblk
                    cmpa      #KQUIT
                    lbeq      quit
                    cmpa      #$06          Ctrl-F: refresh the mapped block
                    lbeq      refreshblk
                    lbra      editkey            unhandled -> try a hex-digit edit

* arrow up/down: Ctrl held -> page, otherwise move the cursor
onup                lbsr      ctrlpressed
                    lbne      pageup
                    lbra      curup
ondown              lbsr      ctrlpressed
                    lbne      pagedn
                    lbra      curdown

* togglemem - flip between viewing the file and viewing system memory.
* Restarts the window at offset/page 0 and reloads via loadwindow, which
* branches on viewmode.
togglemem           lda       <viewmode
                    bne       tmfile@             1 or 2 (any memory view) -> file
                    inc       <viewmode           0 -> 1 (logical 64K)
                    bra       tmload@
tmfile@             clr       <viewmode           -> file
tmload@             clr       <winbase            restart at offset/page 0
                    clr       <winbase+1
                    clr       <winbase+2
                    clr       <pageoff
                    clr       <pageoff+1
                    lbsr      loadwindow
                    lbsr      drawframe           refresh title / mode line
                    lbsr      renderpage
                    lbra      mainloop

********************************************************************
* editaddr - X = live logical address of the byte under the cursor:
*   winptr + currow*ROWBYTES + pageoff + curcol
* Only meaningful in the logical view, where winptr IS the address.
* Clobbers A,B,D; sets X.
*
editaddr            lda       <currow
                    ldb       #ROWBYTES
                    mul
                    addd      <pageoff
                    addb      <curcol
                    adca      #0
                    addd      <winptr
                    tfr       d,x
                    rts

********************************************************************
* editkey - a hex digit was pressed. Editing is allowed ONLY in the
* logical memory view (viewmode 1): the file view would corrupt module
* CRCs and the mapped view is just a snapshot copy. This is meant for the
* register I/O at the top of the map ($FF00-$FFFF), though any live
* logical address can be changed - use with care.
*
* Two digits set a byte: the first is the high nibble (echoed on screen
* but NOT written), the second is the low nibble - the whole byte is then
* poked to the live address in one write (atomic, so a register never
* sees a half-updated value) and the cursor advances. Any non-hex key
* cancels a half-entered byte (handled in mainloop).
*
editkey             lbsr      iswritable
                    lbcs      mainloop           read-only view -> ignore edits
                    lda       <key
                    lbsr      hexval             A = nibble; carry set if not hex
                    lbcs      mainloop           ignore non-hex keys
                    tst       <editph
                    bne       edlo@
* --- first digit: stash the high nibble and echo it, no write yet ---
                    lsla
                    lsla
                    lsla
                    lsla                          A = nibble << 4
                    sta       <editval
                    lda       #1
                    sta       <editph
                    lbsr      showedit           preview the pending high nibble
                    lbra      mainloop
* --- second digit: combine, poke the whole byte once, advance ---
edlo@               ora       <editval            A = high nibble | low nibble
                    sta       <editval            editval = the assembled byte
                    lbsr      editaddr           X = winptr + offset
                    lda       <editval
                    sta       ,x                 logical: poke live addr; mapped: snapshot
                    lda       <viewmode
                    cmpa      #2                  mapped view?
                    bne       edadv@
                    lbsr      pokemapped          write the byte through to the physical page
edadv@              clr       <editph
                    lbsr      curright           advance to next byte (redraws it)
                    lbra      mainloop

********************************************************************
* showedit - echo the pending high nibble (editval>>4) in the cursor's
* high-nibble hex cell, in the selection colour, so the first keystroke
* is visible while we wait for the second. A cursor move redraws the cell
* from memory, discarding the preview.
*   screen col = 13 + (curcol>>1)*5 + (curcol&1)*2 + 2
*
showedit            lda       <curcol
                    lsra
                    ldb       #5
                    mul
                    addb      #13
                    lda       <curcol
                    anda      #1
                    beq       se1@
                    addb      #2
se1@                addb      #2                 screen col = hexpos + 2
                    tfr       b,a                A = x
                    ldb       <currow
                    addb      #DATAROW           B = y
                    lbsr      CurXY
                    lda       #TXTSEL
                    ldb       #TXTSELBG
                    lbsr      Color
                    lda       <editval
                    lsra
                    lsra
                    lsra
                    lsra                          A = high nibble
                    cmpa      #10
                    blo       se09@
                    adda      #'A-10
                    bra       seput@
se09@               adda      #'0
seput@              lbsr      byte1scrn
                    rts

********************************************************************
* iswritable - is the current view editable? Carry CLEAR = writable
* (logical memory view, or a mapped page $C0-$C5 which is hardware I/O);
* carry SET = read-only (file view, or a mapped page below $C0).
*
iswritable          lda       <viewmode
                    cmpa      #1
                    beq       iwyes@             logical 64K -> writable
                    cmpa      #2
                    bne       iwno@             file view -> read-only
                    ldd       <winbase           mapped: page = winbase >> 13
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    cmpb      #$40
                    blo       iwyes@             page $00-$3F (512K RAM) -> writable
                    cmpb      #$C0
                    blo       iwno@             page $40-$BF (FLASH/CART) -> read-only
iwyes@              andcc     #$FE              carry clear = writable
                    rts
iwno@               orcc      #$01              carry set = read-only
                    rts

********************************************************************
* pokemapped - write editval through to the physical page currently in
* the mapped view. The window is a copy in windowbuf, so we re-map the
* page, poke the byte at its offset, and release it. Offset within the
* 8K page = currow*ROWBYTES + pageoff + curcol (same as the snapshot).
*
pokemapped          ldd       <winbase           page = winbase >> 13
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    tfr       d,x                 X = page
                    ldb       #1                  one 8K block
                    pshs      u                   preserve data base
                    os9       F$MapBlk            U = address it was mapped to
                    bcs       pmfail@
                    stu       <mapaddr
                    puls      u                   restore data base
* physical byte address = mapaddr + currow*ROWBYTES + pageoff + curcol
                    lda       <currow
                    ldb       #ROWBYTES
                    mul
                    addd      <pageoff
                    addb      <curcol
                    adca      #0
                    addd      <mapaddr
                    tfr       d,x
                    lda       <editval
                    sta       ,x                 write the byte to the live page
* release the mapping
                    pshs      u
                    ldu       <mapaddr
                    ldb       #1
                    os9       F$ClrBlk
                    puls      u
                    rts
pmfail@             puls      u                   map failed: restore data base
                    rts

********************************************************************
* drawrw - show " (read-only)" / "(read/write)" at (PANECOL,STATUSROW+6)
* per the current view. Both strings are the same length so one cleanly
* overwrites the other when the mode changes.
*
drawrw              lda       #TXT
                    ldb       #TXTBG
                    lbsr      Color
                    lbsr      iswritable
                    bcs       drwro@
                    leax      RWStr,pcr
                    ldy       #RWStrLen
                    bra       drwput@
drwro@              leax      ROStr,pcr
                    ldy       #ROStrLen
drwput@             lda       #PANECOL-2
                    ldb       #STATUSROW+4
                    lbsr      putat
                    rts

********************************************************************
* drawrefresh - show "^F-Refresh Mapped Block" just after Status2 while in
* the mapped view; blank that line in any other view. Called from
* drawframe, so it tracks mode changes.
*
drawrefresh         lda       #FG
                    ldb       #BG
                    lbsr      Color
                    lda       <viewmode
                    cmpa      #2
                    bne       drfbl@             not mapped -> blank the option
                    leax      RefreshStr,pcr
                    bra       drfput@
drfbl@              leax      RefreshBlank,pcr
drfput@             ldy       #RefreshStrLen
                    lda       #PANECOL
                    ldb       #STATUSROW+7
                    lbsr      putat
                    rts
                    rts

********************************************************************
* onmapblk - Ctrl-B: prompt for a physical page ($00-$C5) and map it into
* view. winbase = page*8192 so the address column shows the physical
* address; viewmode 2 routes loadwindow to loadmapped.
*
onmapblk            lbsr      getpage             A = page, carry set if cancelled
                    lbcs      ombcncl
* winbase = page << 13  (lo=0, hi=page>>3, mid=(page<<5)&$FF)
                    clr       <winbase+2
                    pshs      a
                    lsra
                    lsra
                    lsra
                    sta       <winbase            hi = page >> 3
                    puls      a
                    lsla
                    lsla
                    lsla
                    lsla
                    lsla
                    sta       <winbase+1          mid = (page << 5) & $FF
                    lda       #2
                    sta       <viewmode           mapped-page mode
                    clr       <pageoff
                    clr       <pageoff+1
                    lbsr      loadwindow          -> loadmapped
                    lbsr      drawframe
                    lbsr      renderpage
                    lbra      mainloop

********************************************************************
* refreshblk - Ctrl-F: re-read the current mapped physical page into the
* 8K window buffer, so edits/hardware changes to a register page (e.g.
* $C0-$C5) can be re-inspected. Only meaningful in the mapped view.
*
refreshblk          lda       <viewmode
                    cmpa      #2
                    lbne      mainloop           only in mapped-block mode
                    lbsr      loadwindow          re-map, re-copy the page (-> loadmapped)
                    lbsr      renderpage          redraw with the fresh values
                    lbra      mainloop
ombcncl             lbsr      showpath            restore the path/label line
                    lbra      mainloop

********************************************************************
* getpage - prompt on the path line and read two hex digits into a page
* value. Returns A = page ($00-$C5), carry clear on success; carry set if
* the input was not valid hex or was out of range (cancel).
*
getpage             lbsr      blankpath
                    lda       #TXTSEL
                    ldb       #TXTSELBG
                    lbsr      Color
                    lda       #8
                    ldb       #56
                    lbsr      CurXY
                    leax      PgPrompt,pcr
                    ldy       #PgPromptLen
                    lda       #1
                    os9       I$Write
                    clr       <tmppage
                    lbsr      getkey              first digit
                    pshs      a
                    lbsr      echochar
                    puls      a
                    lbsr      hexval              A = nibble, C set if not hex
                    bcs       gpbad@
                    lsla
                    lsla
                    lsla
                    lsla
                    sta       <tmppage            high nibble
                    lbsr      getkey              second digit
                    pshs      a
                    lbsr      echochar
                    puls      a
                    lbsr      hexval
                    bcs       gpbad@
                    ora       <tmppage            combine high|low
                    cmpa      #$C5
                    bhi       gpbad@              page out of range
                    andcc     #$FE                clear carry: success
                    rts
gpbad@              orcc      #$01                set carry: cancel
                    rts

* getkey - block until a key is available (INKEY returns 0 when none)
getkey              lbsr      INKEY
                    tsta
                    beq       getkey
                    rts

* echochar - write the character in A at the current cursor position
echochar            pshs      a
                    tfr       s,x                 X -> the pushed char
                    ldy       #1
                    lda       #1                  stdout
                    os9       I$Write
                    puls      a
                    rts

* hexval - A (ascii) -> nibble 0-15 in A, carry clear; carry set if not hex
hexval              cmpa      #'0
                    blo       hvbad@
                    cmpa      #'9
                    bhi       hva@
                    suba      #'0                 '0'-'9'
                    andcc     #$FE
                    rts
hva@                ora       #$20                fold to lower case
                    cmpa      #'a
                    blo       hvbad@
                    cmpa      #'f
                    bhi       hvbad@
                    suba      #'a-10              'a'-'f' -> 10-15
                    andcc     #$FE
                    rts
hvbad@              orcc      #$01
                    rts

* page down: next page within window, else slide window forward
pagedn              lda       <viewmode          logical view: $FE00 wraps down to $0000
                    cmpa      #1
                    bne       pagedn0@
                    lda       <winbase
                    bne       pagedn0@
                    ldd       <winbase+1         current page address = winbase + pageoff
                    addd      <pageoff
                    cmpd      #$FE00
                    bne       pagedn0@           not the last page
                    clr       <winbase           -> $0000
                    ldd       #0
                    std       <winbase+1
                    lbsr      loadwindow
                    ldd       #0
                    std       <pageoff
                    lbsr      renderpage
                    lbra      mainloop
pagedn0@            ldd       <pageoff
                    addd      #PAGEBYTES          np = pageoff + page
                    cmpd      <winlen
                    blo       pdin@               np < winlen: page lives in this window
* page is at/after window end - only slide if the window was full
                    ldd       <winlen
                    cmpd      #WINBYTES
                    blo       pdstay@             partial window => already at EOF
                    lbsr      winfwd              winbase += WINBYTES
                    lbsr      loadwindow          seek + read next window
                    ldd       <winlen
                    bne       pdnew@              got data - show its first page
                    lbsr      winback             empty (EOF on boundary): undo
                    lbsr      loadwindow          reload the window we were on
                    lbra      mainloop
pdnew@              ldd       #0
                    std       <pageoff
                    lbsr      renderpage
                    lbra      mainloop
pdin@               std       <pageoff            D = np
                    lbsr      renderpage
                    lbra      mainloop
pdstay@             lbra      mainloop

* page up: prev page within window, else slide window backward
pageup              lda       <viewmode          logical view: $0000 wraps up to $FE00
                    cmpa      #1
                    bne       pageup0@
                    lda       <winbase
                    ora       <winbase+1
                    ora       <winbase+2
                    bne       pageup0@
                    ldd       <pageoff
                    bne       pageup0@           not at $0000
                    clr       <winbase           -> last 8K window ($E000)
                    ldd       #$E000
                    std       <winbase+1
                    lbsr      loadwindow
                    ldd       #WINBYTES-PAGEBYTES land on its last page ($FE00)
                    std       <pageoff
                    lbsr      renderpage
                    lbra      mainloop
pageup0@            ldd       <pageoff
                    cmpd      #PAGEBYTES
                    bhs       puin@               pageoff >= page: prev page in window
* at top of window - slide back if there is a previous window
                    lda       <winbase
                    ora       <winbase+1
                    ora       <winbase+2
                    beq       pustay@             winbase == 0: at file start
                    lbsr      winback             winbase -= WINBYTES
                    lbsr      loadwindow          seek + read previous (full) window
                    ldd       #WINBYTES-PAGEBYTES
                    std       <pageoff            land on its last page
                    lbsr      renderpage
                    lbra      mainloop
puin@               ldd       <pageoff
                    subd      #PAGEBYTES
                    std       <pageoff
                    lbsr      renderpage
                    lbra      mainloop
pustay@             lbra      mainloop

********************************************************************
* ctrlpressed - test the Ctrl modifier via SS.KySns (same mechanism the
* FM uses for shift+enter). Returns Z=0 (bne) if Ctrl is held.
*
ctrlpressed         lda       #0                  path 0
                    ldb       #SS.KySns
                    os9       I$GetStt            A = key-sense bits
                    bita      #CNTLBIT
                    rts

********************************************************************
* Cursor navigation. The cursor is (currow,curcol) within the page; the
* selected byte is highlighted in TXTSEL/TXTSELBG. Moves are clamped to
* the valid data on the page (Ctrl+Up/Down change the page instead).
*
* curidx  -> D = currow*ROWBYTES + curcol  (page byte index of cursor)
curidx              lda       <currow
                    ldb       #ROWBYTES
                    mul
                    addb      <curcol
                    adca      #0
                    rts

* lastbyte -> D = valid bytes on this page = min(PAGEBYTES, winlen-pageoff)
lastbyte            ldd       <winlen
                    subd      <pageoff
                    bcc       lb1@
                    ldd       #0
                    rts
lb1@                cmpd      #PAGEBYTES
                    blo       lb2@
                    ldd       #PAGEBYTES
lb2@                rts

* setcur - set currow/curcol from a page byte index in D (0..PAGEBYTES-1)
setcur              pshs      d
                    tfr       b,a
                    anda      #$0F
                    sta       <curcol
                    puls      d
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    stb       <currow
                    rts

curup               lda       <currow
                    beq       mlret@              top row - stay
                    lbsr      curlo
                    dec       <currow
                    lbsr      curhi
mlret@              lbra      mainloop

curdown             lda       <currow
                    inca
                    cmpa      #ROWS
                    bhs       mlret@              bottom row - stay
                    ldb       #ROWBYTES
                    mul                           D = (currow+1)*ROWBYTES
                    addb      <curcol
                    adca      #0
                    std       <candidx
                    lbsr      lastbyte
                    cmpd      <candidx
                    bls       mlret@              past valid data - stay
                    lbsr      curlo
                    inc       <currow
                    lbsr      curhi
mlret@              lbra      mainloop

curleft             lbsr      curidx
                    subd      #1
                    bcs       mlret@              already at byte 0 - stay
                    std       <candidx
                    lbsr      curlo
                    ldd       <candidx
                    lbsr      setcur
                    lbsr      curhi
mlret@              lbra      mainloop

curright            lbsr      curidx
                    addd      #1
                    std       <candidx
                    lbsr      lastbyte
                    cmpd      <candidx
                    bls       mlret@              past valid data - stay
                    lbsr      curlo
                    ldd       <candidx
                    lbsr      setcur
                    lbsr      curhi
mlret@              lbra      mainloop

********************************************************************
* Mouse handling
*
* pollmouse runs once per mainloop pass. On a fresh left-button press
* (edge-detected via mslastbtn) over a hex or ASCII cell, it moves the
* cursor/highlight to that byte - the same result as the arrow keys.
* Fonts are 8 pixels, so screen col = x/8 and screen row = y/8; the data
* rows begin at DATAROW.
*
* Mouse - read the pointer. Exit: msbtn=button, msx/msy=pixel position;
* carry set if the status call failed (no mouse present).
*
Mouse               pshs      x,y
                    clra                          path 0
                    ldb       #SS.Mouse
                    os9       I$GetStt            A=button, X=x, Y=y
                    bcs       mrts@
                    sta       <msbtn
                    stx       <msx
                    sty       <msy
mrts@               puls      x,y
                    rts
*
* pollmouse - act only on the 0->1 transition of the left button so a
* held button doesn't repeatedly repaint.
*
pollmouse           lbsr      Mouse
                    bcs       pmdone@             no mouse - nothing to do
                    lda       <msbtn
                    cmpa      #1                  left button down?
                    bne       pmup@
                    lda       <mslastbtn          was it already down?
                    bne       pmdone@             held - ignore (edge only)
                    lda       #1
                    sta       <mslastbtn
                    lbsr      msclick             handle the fresh click
                    bra       pmdone@
pmup@               clr       <mslastbtn          button released
pmdone@             rts
*
* msclick - convert msx/msy to a byte on the page and move the cursor
* there. Clicks outside the hex/ASCII cells, or past the loaded data,
* are ignored (the highlight stays where it was).
*
msclick             ldd       <msx                x -> screen col = x/8
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    tsta                          x off-screen? ignore
                    bne       mscdone@
                    stb       <mscol
                    ldd       <msy                y -> screen row = y/8
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    tsta                          y off-screen? ignore
                    bne       mscdone@
                    stb       <msscrn             B = screen row
* --- Quit button: row 56, columns 70..77 -> run the quit routine ---
                    cmpb      #56
                    bne       msnotq@
                    lda       <mscol
                    cmpa      #70
                    blo       msnotq@
                    cmpa      #77
                    bhi       msnotq@
                    lbra      quit               (quit exits, so no stack unwind)
* --- page strip at col 73, rows 3..36: above the middle of the view pages
*     up, below pages down. pageup/pagedn end in 'lbra mainloop', and we
*     are two lbsr's deep (mainloop->pollmouse->msclick), so drop those two
*     return frames before jumping to them. ---
msnotq@             lda       <mscol
                    cmpa      #73
                    bne       msdata@
                    ldb       <msscrn
                    cmpb      #3
                    blo       msdata@
                    cmpb      #36
                    bhi       msdata@
                    leas      4,s                 unwind pollmouse + msclick returns
                    cmpb      #20                 middle of the hex view = divider
                    lbcs      pageup             above middle -> page up
                    lbra      pagedn             below middle -> page down
* --- data cell selection ---
msdata@             ldb       <msscrn
                    subb      #DATAROW            data row = screenrow - DATAROW
                    bcs       mscdone@            above the data area
                    cmpb      #ROWS
                    bhs       mscdone@            below the data area
                    stb       <msrow
                    ldb       <mscol
                    lbsr      colToByte           A = byte 0..15, carry set if not a cell
                    bcs       mscdone@
                    sta       <msbyte
* candidate page index = msrow*ROWBYTES + msbyte
                    lda       <msrow
                    ldb       #ROWBYTES
                    mul
                    addb      <msbyte
                    adca      #0
                    std       <candidx
                    lbsr      lastbyte            D = valid bytes on this page
                    cmpd      <candidx
                    bls       mscdone@            click past valid data - ignore
                    lbsr      curlo               unhighlight the old cell
                    ldd       <candidx
                    lbsr      setcur              set currow/curcol
                    lbsr      curhi               highlight the new cell
mscdone@            rts
*
* colToByte - B = screen column -> A = byte index 0..15 within the row.
* Carry clear = valid cell; carry set = column is not over a byte.
*   hex pairs:  cols 15..53 (paired; the 1-col gaps fold onto the near byte)
*   ascii:      cols 56..71 (one column per byte)
*
colToByte           cmpb      #56                 ascii field?
                    blo       cbhex@
                    cmpb      #71
                    bhi       cbbad@
                    tfr       b,a
                    suba      #56                 byte = col - 56
                    andcc     #$FE                carry clear = valid
                    rts
cbhex@              cmpb      #15                 hex field?
                    blo       cbbad@
                    cmpb      #53
                    bhi       cbbad@              54,55 = gap before ascii
                    subb      #15                 index 0..38 into the table
                    leax      hexcoltab,pcr
                    lda       b,x
                    andcc     #$FE                carry clear = valid
                    rts
cbbad@              orcc      #$01                carry set = not a cell
                    rts
* (screen col - 15) -> byte index; gap columns fold onto the nearer byte
hexcoltab           fcb       0,0,1,1,1,2,2,3,3,3,4,4,5,5,5,6,6,7,7,7
                    fcb       8,8,9,9,9,10,10,11,11,11,12,12,13,13,13,14,14,15,15

********************************************************************
* curlo / curhi - repaint the cursor cell (its hex pair and ascii char)
* in normal or selected colors. Used to move the highlight: paint old
* cell normal, move, paint new cell selected.
*
curlo               lda       #TXT
                    ldb       #TXTBG
                    bra       paintcell
curhi               lda       #TXTSEL
                    ldb       #TXTSELBG
paintcell           sta       <cellfg
                    stb       <cellbg
* rebuild the cursor's row into linebuf so we have the exact characters
* (so the trailing cell can be redrawn with real content, not a guess)
                    lda       <currow
                    ldb       #ROWBYTES
                    mul
                    addd      <pageoff
                    std       <rowoff
                    lbsr      buildrow
* HX = buffer offset of cursor hex pair = 13 + (curcol>>1)*5 + (curcol&1)*2
                    lda       <curcol
                    lsra
                    ldb       #5
                    mul
                    addb      #13
                    lda       <curcol
                    anda      #1
                    beq       ph@
                    addb      #2
ph@                 stb       <hexpos
* --- hex pair in cell colors ---
                    lda       <cellfg
                    ldb       <cellbg
                    lbsr      Color
                    lda       <hexpos             screen col = buffer offset + 2
                    adda      #2
                    ldb       <currow
                    addb      #DATAROW
                    lbsr      CurXY
                    leax      linebuf,u
                    ldb       <hexpos
                    abx
                    ldy       #2
                    lda       #1
                    os9       I$Write
* trailing cell (buffer HX+2) redrawn normal - absorbs the selection bg
                    lda       #TXT
                    ldb       #TXTBG
                    lbsr      Color
                    leax      linebuf,u
                    ldb       <hexpos
                    addb      #2
                    abx
                    ldy       #1
                    lda       #1
                    os9       I$Write
* --- ascii char in cell colors ---
                    lda       <cellfg
                    ldb       <cellbg
                    lbsr      Color
                    lda       #PANECOL+48
                    adda      <curcol
                    ldb       <currow
                    addb      #DATAROW
                    lbsr      CurXY
                    leax      linebuf,u
                    ldb       #54
                    addb      <curcol
                    abx
                    ldy       #1
                    lda       #1
                    os9       I$Write
* trailing cell: columns 0-14 repaint the next ascii cell in normal colors
* to absorb the selection background that bleeds one cell to the right, so
* only the single ascii character stays highlighted. Column 15 is skipped -
* its bleed lands on the filler cell before the right border (col 73), so we
* leave that in the selection color (highlight meets the border, no revert).
* Moving off byte 15, curlo repaints it normal and its own bleed clears the
* filler again.
                    lda       <curcol
                    cmpa      #15
                    beq       pcret@             last column: don't revert
                    lda       #TXT
                    ldb       #TXTBG
                    lbsr      Color
                    leax      linebuf,u
                    ldb       #55
                    addb      <curcol
                    abx
                    ldy       #1
                    lda       #1
                    os9       I$Write
pcret@              rts

********************************************************************
* quit - close file, restore terminal + screen + caller colors, exit.
*
quit                lda       <curpath
                    os9       I$Close
                    lbsr      keyechoon
                    lbsr      breakon
                    ;leax      ScrnExit,pcr
                    ;ldy       #ScrnExitLen
                    ;lda       #$01
                    ;os9       I$Write
                    lda       <oldfg
                    ldb       <oldbg
                    lbsr      Color
                    leax      ScrnExit,pcr
                    ldy       #ScrnExitLen
                    lda       #$01
                    os9       I$Write
                    clrb
                    os9       F$Exit

********************************************************************
* ===================  shared FM-style utilities  ==================
********************************************************************

* getscrnsz - save the caller's current fg/bg so we can restore them.
getscrnsz           pshs      a,b,x,y,u,cc
                    lda       #0                 path 0
                    ldb       #SS.FBRgs
                    os9       I$GetStt            A = packed fg/bg
                    pshs      a
                    anda      #$0F
                    sta       <oldbg
                    puls      a
                    lsra
                    lsra
                    lsra
                    lsra
                    sta       <oldfg
                    puls      a,b,x,y,u,cc,pc

* putat - A=col B=row X=str ptr Y=len: position cursor, write string.
putat               pshs      x,y
                    lbsr      CurXY               preserves A,B; clobbers X,Y
                    puls      x,y
                    lda       #$01
                    os9       I$Write
                    rts

* CurXY - A=x B=y: move terminal cursor (adds $20 bias). Preserves A,B.
CurXY               adda      #$20
                    addb      #$20
                    pshs      a,b
                    leas      -3,s
                    lda       #$02                CURXY command
                    sta       ,s
                    lda       3,s
                    sta       1,s
                    lda       4,s
                    sta       2,s
                    lda       #$01
                    ldy       #3
                    tfr       s,x
                    os9       I$Write
                    leas      3,s
                    puls      a,b
                    rts

* Color - A=fg B=bg: set terminal fg/bg. Preserves A,B.
Color               pshs      a,b
                    leas      -6,s
                    lda       #$1B
                    sta       ,s
                    lda       #$32
                    sta       1,s
                    lda       6,s
                    sta       2,s
                    lda       #$1B
                    sta       3,s
                    lda       #$33
                    sta       4,s
                    lda       7,s
                    sta       5,s
                    lda       #$01
                    ldy       #6
                    tfr       s,x
                    os9       I$Write
                    leas      6,s
                    puls      a,b
                    rts

* byte2hex - A=byte, X=dest. Writes 2 ASCII hex chars, advances X by 2.
byte2hex            pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       nib@
                    sta       ,x+
                    puls      a
                    anda      #$0F
                    bsr       nib@
                    sta       ,x+
                    rts
nib@                cmpa      #9
                    bls       dig@
                    adda      #'A-10
                    rts
dig@                adda      #'0
                    rts

* getopts / keyechooff / keyechoon - device option (echo) control.
getopts             leax      >popts,u
                    ldb       #SS.Opt
                    clra
                    os9       I$GetStt
                    rts

keyechooff          leax      >popts,u
                    clr       4,x
                    clra
                    ldb       #SS.Opt
                    os9       I$SetStt
                    rts

keyechoon           leax      >popts,u
                    lda       #1
                    sta       4,x
                    clra
                    ldb       #SS.Opt
                    os9       I$SetStt
                    rts

* breakoff / breakon - disable/restore Ctrl-C (16) and Ctrl-E (17).
breakoff            leax      >popts,u
                    lda       16,x
                    sta       savedint,u
                    clr       16,x
                    lda       17,x
                    sta       savedqut,u
                    clr       17,x
                    clra
                    ldb       #SS.Opt
                    os9       I$SetStt
                    rts

breakon             leax      >popts,u
                    lda       savedint,u
                    sta       16,x
                    lda       savedqut,u
                    sta       17,x
                    clra
                    ldb       #SS.Opt
                    os9       I$SetStt
                    rts

* INKEY - non-blocking key read on path 0. Returns A=key, or A=0 if none.
INKEY               clra
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcc       gk@
                    cmpb      #E$NotRdy
                    bne       ik@
                    clra
                    bra       ik@
gk@                 lbsr      FGETC
ik@                 rts

* FGETC - read one char from path 0 into A.
FGETC               pshs      x,y
                    leas      -1,s
                    lda       #0
                    ldy       #1
                    tfr       s,x
                    os9       I$Read
                    lda       ,s
                    leas      1,s
                    puls      x,y,pc
********************************************************************
* installchars
* installs drawing characters into the current font
* this ensures the screen looks the same no matter
* which font is in font0
*
installchars       ldb	      #13
        	       pshs       b
	               leax       oldchars,u  
	               ldy	      #242
loop@	           lda	      #0
	               ldb	      #SS.FntChar
	               os9        I$GetStt
	               bcs	      exit@
	               leax       8,x
	               leay       1,y
	               dec	      ,s
	               bne	      loop@
                   ldb	      #13
;                   pshs       b                   *
	               stb	      ,s
	               leax       topleftbc,pcr
	               ldy	      #242
loop2@	           lda	      #0
	               ldb	      #SS.FntChar
	               os9	      I$SetStt
	               bcs	      exit@
	               leax       8,x
	               leay       1,y
	               dec	      ,s
	               bne        loop2@
exit@	           puls       b,pc

********************************************************************
* restorechars
* if the user exits without making changes, remove
* replace the drawing character with the original
* font characters
*
restorchars        pshs      a,b,x,y,u
                   ldb  	 #13
	               stb  	 ,s
	               leax      oldchars,u
	               ldy  	 #242
loop@	           lda  	 #0
	               ldb  	 #SS.FntChar
	               os9  	 I$SetStt
	               bcs  	 exit@
	               leax      8,x
	               leay      1,y
	               dec  	 ,s
	               bne       loop@
exit@	           puls      a,b,x,y,u,pc		    

SideBorderL    leas      -1,s                 reserve 1 byte for stack
               lda       <k
               cmpa      #54
               bne       cont@
               lda       #TTRC
               bra       cont2@
cont@          lda       #SBL
cont2@         sta       ,s
               lda       #$01          stdout
               ldy       #1            number of characters to print
               tfr       s,x
               os9       I$Write       end top title and border
               leas      1,s           return stack to normal
               rts

SideBorderR    leas      -1,s          reserve 1 byte for stack
               lda       <k
               cmpa      #54
               bne       cont@
               lda       #TTLC
               bra       cont2@
cont@          lda       #SBL
cont2@         sta       ,s
               lda       #$01          stdout
               ldy       #1            number of characters to print
               tfr       s,x
               os9       I$Write       end top title and border
               leas      1,s           return stack to normal
               rts

winborder           lda       #0            fg
                    ldb       #6            gb
                    lbsr      Color
; top left curved
                    lda       #7
                    ldb       #3
                    lbsr      CurXY
                    lda       #$1C
                    lbsr      byte1scrn
                    lda       #3
                    lbsr      byte1scrn
                    lda       #4            start border on line 1
                    sta       <k
cont2@              lda       #7            x
                    ldb       <k
                    lbsr      CurXY
                    leas      -1,s          reserve 1 byte for stack
                    lda       #SLD          solid block
                    sta       ,s
                    lda       #$01          stdout
                    ldy       #1            number of characters to print
                    tfr       s,x
                    os9       I$Write       end top title and border
                    leas      1,s           return stack to normal
                    lda       <k
                    inca
                    sta       <k
                    cmpa      #36
                    bne       cont2@
                    lda       #7
                    ldb       #36
                    lbsr      CurXY
                    lda       #$1C
                    lbsr      byte1scrn
                    lda       #4
                    lbsr      byte1scrn
; right border
                    lda       #0            fg
                    ldb       #6            gb
                    lbsr      Color
                    lda       #73
                    ldb       #3
                    lbsr      CurXY
                    lda       #$1C
                    lbsr      byte1scrn
                    lda       #5
                    lbsr      byte1scrn
                    lda       #4            start border on line 1
                    sta       <k
cont3@              lda       #73           x
                    ldb       <k
                    lbsr      CurXY
                    leas      -1,s          reserve 1 byte for stack
                    lda       #SLD          solid block
                    sta       ,s
                    lda       #$01          stdout
                    ldy       #1            number of characters to print
                    tfr       s,x
                    os9       I$Write       end top title and border
                    leas      1,s           return stack to normal
                    lda       <k
                    inca
                    sta       <k
                    cmpa      #36
                    bne       cont3@
                    lda       #73
                    ldb       #36
                    lbsr      CurXY
                    lda       #$1C
                    lbsr      byte1scrn
                    lda       #6
                    lbsr      byte1scrn
                    rts

nitroslbl           lda       #PANECOL
                    ldb       #NITROSROW
                    lbsr      CurXY
                    lda       #2
                    ldb       #6
                    lbsr      Color
                    lda       #$4E           N
                    lbsr      byte1scrn
                    lda       #8
                    ldb       #6
                    lbsr      Color
                    lda       #$69           i
                    lbsr      byte1scrn
                    lda       #7
                    ldb       #6
                    lbsr      Color
                    lda       #$74           t
                    lbsr      byte1scrn
                    lda       #5
                    ldb       #6
                    lbsr      Color
                    lda       #$72           r
                    lbsr      byte1scrn
                    lda       #1
                    ldb       #6
                    lbsr      Color
                    lda       #$4F           O
                    lbsr      byte1scrn
                    lda       #$53           S 
                    lbsr      byte1scrn
                    lda       #$2D           -
                    lbsr      byte1scrn      
                    lda       #$39           9
                    lbsr      byte1scrn
                    leax      Wild,pcr
                    ldy       #WildLen
                    lda       #$01
                    os9       I$Write
                    rts

** write 1 byte in a to screen
byte1scrn           leas      -1,s          reserve 1 byte for stack
                    sta       ,s
                    lda       #$01          stdout
                    ldy       #1            number of characters to print
                    tfr       s,x
                    os9       I$Write
                    leas      1,s           return stack to normal
                    rts

DoATTR              pshs      x,y,u,b,a
                    lda       #37
                    ldb       #56
                    lbsr      CurXY
                    lda       #TXT
                    ldb       #TXTBG
                    lbsr      Color
                    clra
                    ldb       <pathlen
                    tfr       d,y
                    leax      >ATTRCMD,pcr
                    leau      path,u
                    ldd       #$0100
                    os9       F$Fork
                    bcs       restorestack  fork failed
                    os9       F$Wait
restorestack        puls      x,y,u,b,a,pc

********************************************************************
* Screen control sequences (from the File Manager)
*
ScrnInit            fcb       $05,$20,$1B,$20,$04,$00,$00,$00,$00,FG,BG,$00,$0C
ScrnInitLen         equ       *-ScrnInit
ScrnExit            fcb       $05,$21,$0C
ScrnExitLen         equ       *-ScrnExit

********************************************************************
* Text
*
Title               fcb       TTLC,$20,$20,$48,$45,$58,$20,$45,$44,$49,$54,$4F,$52
                    fcb       $20,$20,TTRC
TitleLen            equ       *-Title
TopLine             fcb       TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL
                    fcb       TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL
TopLineLen          equ       *-TopLine
MMapln              fcc       "$00-$3F-512K RAM  $40-$7F-512K FLASH  $80-$9F-CART  $C0-$C5-Hardware"
MMapLen             equ       *-MMapln
ROStr               fcc       " (read-only)"
ROStrLen            equ       *-ROStr
RWStr               fcc       "(read/write)"
RWStrLen            equ       *-RWStr
RefreshStr          fcc       "^F-Refresh Mapped Block"
RefreshStrLen       equ       *-RefreshStr
RefreshBlank        fcc       "                       "
Status              fcc       "Left/Right/Up/Down/Mouse-Nav  ^Up/^Down-Page  ^Q-Quit"
StatusLen           equ       *-Status
Status2             fcc       "^R-Ram/File View ^B-Map Block View "
StatusLen2           equ       *-Status2

* usage text - $0D-terminated so I$WritLn emits it as one row
UsageMsg            fcc       "Hexed /dd/pathtofile     - view file in hex editor."
                    fcb       C$CR
MemMsg              fcc       " LOGICAL 64K MEMORY "
MemMsgLen           equ       *-MemMsg
MapPfx              fcc       " MAPPED PAGE $"
MapPfxLen           equ       *-MapPfx
MapSfx              fcc       " "
MapSfxLen           equ       *-MapSfx
PgPrompt            fcc       " Map page (00-C5): "
PgPromptLen         equ       *-PgPrompt
BlnkPath            fcc       "                            "
BlnkLen             equ       *-BlnkPath
Wild                fcc       " Wildbits"
WildLen             equ       *-Wild
* 64-char column header and rule (6-digit offset + 8 2-byte groups + ASCII)
HdrTxt              fcc       "Offset 0 1  2 3  4 5  6 7  8 9  A B  C D  E F   0123456789ABCDEF"
DashTxt             fcc       "------ ---- ---- ---- ---- ---- ---- ---- ----  ----------------"
OpenErr             fcc       "hexed: cannot open file"
OpenErrLen          equ       *-OpenErr
Selected            fcb       TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TTLC,$20,$53,$45,$4C,$45,$43,$54,$45,$44,$20,TTRC
SelectedLen         equ       *-Selected
SFilename           fcb       TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TTLC,$20,$46,$49,$4C,$45,$4E,$41,$4D,$45,$20,TTRC
SFileLen            equ       *-SFilename
AttrLn              fcb       TTLC,$20,$41,$54,$54,$52,$20,TTRC
AttrLnLen           equ       *-AttrLn
Line12              fcb       TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL,TBL
Line12Len           equ       *-Line12
Line2               fcb       TBL,TBL
Line2Len            equ       *-Line2
Line3               fcb       TBL,TBL,TBL
Line3Len            equ       *-Line3
Line4               fcb       TBL,TBL,TBL,TBL
Line4Len            equ       *-Line4
QuitLn              fcb       $20,$20,$51,$55,$49,$54,$20
QuitLnLen           equ       *-QuitLn
VerStr              fcc       " MDM V1.0"
VerStrLen           equ       *-VerStr

topleftbc           fcb       $00,$00,$00,$1F,$18,$1F,$18,$18   ........
toprigtbc           fcb       $00,$00,$00,$F8,$18,$F8,$18,$18   ...x.x..
topltc              fcb       $18,$18,$18,$F8,$18,$F8,$18,$18   ...x.x..
toprtc              fcb       $18,$18,$18,$1F,$18,$1F,$18,$18   ........
topbl               fcb       $00,$00,$00,$FF,$00,$FF,$00,$00   ........
sidebl              fcb       $18,$18,$18,$18,$18,$18,$18,$18   ........
btmlftbc            fcb       $18,$18,$18,$1F,$18,$1F,$00,$00   ........
btmrgtbc            fcb       $18,$18,$18,$F8,$18,$F8,$00,$00   ...x.x..
sldchar             fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF   ........
uparr               fcb       $20,$30,$38,$3C,$38,$30,$20,$00   ...@@@.. $1C Left Select
dnarr               fcb       $04,$0C,$1C,$3C,$1C,$0C,$04,$00   .$f.f$.. $1D Right Select
lftarr              fcb       $00,$00,$10,$38,$7C,$FE,$00,$00   ...8|... $1E Up Select
rgtarr              fcb       $00,$00,$00,$FE,$7C,$38,$10,$00   ....|8.. $1F Down Select

ATTRCMD             fcc       "/dd/cmds/attr"
                    fcb       C$CR

                    emod
eom                 equ       *
                    end
