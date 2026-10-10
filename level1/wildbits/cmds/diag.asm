* diag - WildBits Level 1 hardware diagnostics, 80 columns x 60 rows.
* Owned buffers only. No flash writes, IRQ acknowledgement or FIFO theft.
* All MMU windows exclude this module, its data and its stack. IRQs are
* masked only while that window is borrowed, never during waits/output.
                    nam diag
                    ttl WildBits hardware diagnostics
                    ifp1
                    use defsfile
                    endc
                    mod eom,name,Prgrm+Objct,ReEnt+1,start,size
module              equ 0
TestCount           equ 19                  A-P, T Ethernet, S CPU speed (2026-10-09), W RTC (2026-10-10)
* The test rows (2026-10-10, user: "automatic-capable first, then the manual-only modes"; "put RTC test after
* ethernet ... make cpu auto again"): a test's selection number is its row (TestRow0+n); its key is the first
* letter of its entry in tests. The Z run takes rows 0 to TestAuto-1: ... T, W, S.
TestMath            equ 1
TestFpu             equ 2
TestPsg             equ 3                   D-G: the sound tests
TestMidi            equ 6
SoundTicks          equ 120                 a sound test's main-loop passes (one tick each): about 2 s
TestSprites         equ 7
TestIrq             equ 9
TestEther           equ 13                  T
TestRtc             equ 14                  W, its lines below T's
TestSpeed           equ 15                  S, its lines below W's; the last of the Z run
TestAuto            equ 16                  rows 0-15 run in the Z run
TestRow0            equ 5                   the first test's row, right under the headings
TestPS2             equ 16                  H, I and J: the keyboard and mouse tests
TestMouse           equ 17
TestK2Keys          equ 18
AutoLoops           equ 150                 Z run: main-loop passes (2-tick naps) a live test runs, about 5 s
* Colors (2026-10-09, user: "make diag bg blue, text white, graphical framework like the photo has"): numbers in
* the core's default text palette (wildbits.d TXT_*), which diag loads itself (diagpal.inc) along with its own
* CP437 font (diagfont.inc, phoenixegafont) so the frame looks the same on any system; both restored at exit.
ColText             equ TXT_WHITE
ColBack             equ TXT_BLUE
ColKey              equ TXT_CYAN            key letters and headings, as Procomm's
ColBarFg            equ TXT_BLACK           the selected test's bar
ColBarBg            equ TXT_LTGRAY
* CP437 box drawing (the font diag loads): a double frame, single dividers
BoxTL               equ $C9
BoxTR               equ $BB
BoxBL               equ $C8
BoxBR               equ $BC
BoxH2               equ $CD
BoxV2               equ $BA
BoxH1               equ $C4
BoxTeeL             equ $C7                 double vertical, single to the right
BoxTeeR             equ $B6
* The frame (2026-10-10, user: "the right border should be at 79, not 78"): the screen's last column. Column
* FrameRight of the bottom row is written into text memory directly (framecorner): the console would scroll.
ScreenCols          equ 80
FrameRight          equ ScreenCols-1
FrameBottom         equ 59                  the frame's bottom row, the screen's last
RowTitleDiv         equ 3                   the single dividers: under the title,
RowLiveDiv          equ 25                  above the live view
RowKeyDiv           equ 54                  and above the key help
CornerOff           equ FrameBottom*ScreenCols+FrameRight
* The live view (2026-10-10, user: "do a CLS of the live view once, and don't cls again unless you're doing the line
* or bitmap tests"; "the view port should SCROLL itself ... do not scroll the frame"): rows ViewTop-ViewBot are a
* log. Each message is a new line; each test reserves its lines (vlines) below the last, and the rows scroll up
* inside the frame when it is full. vbase is the running test's first line.
ViewTop             equ RowLiveDiv+2
ViewBot             equ RowKeyDiv-1
TickSleep           equ 2                   F$Sleep X=2 sleeps one tick; X=1 only yields (fsleep.asm counts down first)
DmaPrevOff          equ 7                   the DMA test's preview, below its six operation lines
MouseGridOff        equ 2                   the mouse grid's first line
MouseLines          equ 22                  its label, a blank line and 20 grid lines
StateNA             equ 5                   a test this machine cannot run
TestLines320        equ 10                  N, O and P draw over the whole view: it is cleared for them
TestBitmap          equ 12
                    org 0
* The CPU speed test's variables first: its chunk loop reaches them in the direct page (DP = the data page), as
* wildspeed does - the cycle counts behind its factors assume direct addressing.
wsscratch           rmb 1                   the RAM byte of the read/write classes
wsstart             rmb 1                   the RTC second at the aligned start (BCD)
wstarget            rmb 1                   the BCD second that ends a window
wschunks            rmb 2                   chunks completed in a window
wsresult            rmb 14                  MHz*100 per class
wsacc               rmb 4                   the blend accumulator
wsmula              rmb 2
wsmulb              rmb 2
wsprod              rmb 4
wsrem               rmb 1
wsdec               rmb 2                   two ASCII digits
wsint               rmb 2                   the integer part's digits
wsguard             rmb 1                   wsalign's outer count (2026-10-10)
options             rmb OPTCNT
rawopts             rmb OPTCNT
oldcols             rmb 2
oldrows             rmb 2
optvalid            rmb 1
selection           rmb 1
running             rmb 1
key                 rmb 1
lastkey             rmb 1
status              rmb TestCount
samples             rmb 2
operand             rmb 2
result              rmb 4
expected            rmb 4
failures            rmb 2
irqseen             rmb 4
irqnow              rmb 4
irqmasks             rmb 4
board               rmb 1
mapreg              rmb 2
mapbase             rmb 2
savedmap            rmb 1
savedslot           rmb 1
savedcc             rmb 1
phys                rmb 3
physical            rmb 3
windowend           rmb 2
codebegin           rmb 2
codeend             rmb 2
dataend             rmb 2
coord               rmb 3
row                 rmb 1
col                 rmb 1
linebuf             rmb 80
outbyte             rmb 1
waitcount           rmb 2
mode                rmb 1
oldgfx              rmb 1
oldline             rmb 1
oldmaster           rmb 1
oldbm               rmb 4
oldsprite           rmb 8
oldlut              rmb 4
paletteowned        rmb 1
spriteon            rmb 1
spritepos           rmb 2
gfxowned            rmb 1
pixbase             rmb 2
pixelcount          rmb 2
px                  rmb 2
py                  rmb 1
xend                rmb 2
yend                rmb 1
linecase            rmb 1
missing             rmb 2
extra               rmb 2
dmaop               rmb 1
soundon             rmb 1
soundchoice         rmb 1
ethlo               rmb 1                   Ethernet test (2026-10-09): a register's low address byte
ethval              rmb 1                   the byte for ethwrite / the last register read
ethpat              rmb 1                   the walking-bit pattern
ethcount            rmb 1                   walking-bit mismatches
ethbusy             rmb 1                   adapter transfers that never finished
chkerrs             rmb 1                   failed checks (the Ethernet and RTC tests)
chkmark             rmb 1                   chkerrs at the start of a result line
ethsave             rmb 2                   registers restored after a write test
hilite              rmb 1                   non-zero: the selected test's row is drawn as the bar
fontsave            rmb FONT_BANK_SIZE      the system's font bank 0, restored at exit
lutsave             rmb TXT_LUT_SIZE*2      the system's text LUTs (foreground, background)
oldfb               rmb 1                   the window's colors on entry (SS.FBRgs), back at exit
vkysave             rmb 6                   VICKY border and background colors (B,G,R each), back at exit
prevacc             rmb 2                   pixelpreview: the bytes-per-cell accumulator
rtcregs             rmb RTC_YEAR+1          RTC test (2026-10-10): RTC_SEC..RTC_YEAR as read under UTI
rtcctrl             rmb 1                   RTC_CTRL
rtccent             rmb 1                   RTC_CENTURY
rtcprev             rmb 1                   the second an edge is waited from
rtcticks            rmb 1                   OS ticks until it changed
rtcsecs             rmb 3                   the seconds at the start and the next two edges
ostime              rmb 6                   F$Time: YY MM DD HH MM SS
* the Ethernet ping (2026-10-10): the w6100 tools' network settings, in their file's order, and work space
ethblk              rmb 1                   IDM_BSR for ethread and ethwrite
netcfg              equ .
netmac              rmb 6
netip               rmb 4
netmask             rmb 4
netgw               rmb 4
netdns              rmb 4
netsrv              rmb 4                   the ping target ("server", w6100eth's)
nettz               rmb 1                   hours from UTC (signed), "tz" in the file
NetCfgLen           equ .-netcfg
NetMACLen           equ netip-netmac
NetIPLen            equ netmask-netip
nethost             rmb 4                   google.com's address
netsrcmsg           rmb 2                   netconfig: "(w6100ipconfig)" or "(default)"
netdhcpok           rmb 1                   the settings came from DHCP
netsendn            rmb 2                   netsend: bytes left
DhcpLen             equ 300                 a DHCP request, zero-padded (BOOTP's minimum); before its rmb (2026-10-10:
*                                            a size defined later made lwasm repeat its passes, and once hang)
dhcpbuf             rmb DhcpLen             the DHCP request sent
dhcpip              rmb 4                   the address offered
dhcpserver          rmb 4                   the DHCP server
dhcpmask            rmb 4                   the reply's mask, router and DNS server
dhcprouter          rmb 4
dhcpdns             rmb 4
dhcptype            rmb 1                   the reply's message type
dhcpwant            rmb 1
dhcpleft            rmb 1
dhcpolen            rmb 1                   an option's length
dhcpend             rmb 2                   the reply's end
dhcpbase            rmb 2                   and its start
netq                rmb 2                   netresolve: the query,
netqlen             rmb 1                   its length
netout              rmb 2                   and where the address goes
netcand             rmb 4                   the address the scan is trying
ntphost             rmb 4                   pool.ntp.org's address
ntpsecs             rmb 4                   the NTP answer: seconds since 1900
ntpnum              rmb 4                   ntpdiv: dividend, then quotient
ntpden              rmb 4                   divisor
ntprem              rmb 4                   remainder
ntpcnt              rmb 1
ntpdays             rmb 2                   days since 1900, then into the year and month
ntpspan             rmb 2                   a year's or month's days; the zone's seconds
ntpyear             rmb 2
ntpleap             rmb 1
ntpcent             rmb 1                   the result: century,
ntpyy               rmb 1                   year of the century,
ntpmon              rmb 1                   month,
ntpmday             rmb 1                   day of the month,
ntpdow              rmb 1                   day of the week (1 = Sunday),
ntphh               rmb 1                   hours,
ntpmm               rmb 1                   minutes
ntpss               rmb 1                   and seconds
ntptime             rmb 6                   F$STime: YY MM DD HH MM SS
netwait             rmb 2                   ticks left
netptr              rmb 2                   the config file: the parse position,
netend              rmb 2                   its end,
netkw               rmb 2                   the keyword entry tried,
netdest             rmb 2                   the field it sets
nettype             rmb 1                   and its value type
netpath             rmb 1
netoctet            rmb 1
netacc              rmb 2
nettmpw             rmb 2
nettmp              rmb 1
netprev             rmb 2                   netrd16's first read
netsval             rmb 1
netrd               rmb 2                   a socket buffer pointer
netlen              rmb 2                   a UDP payload's length
nettotal            rmb 2                   with its header
netcount            rmb 2
nettry              rmb 1
dnsout              rmb 2                   netparsedns: the address out,
dnsend              rmb 2                   the answer's end,
dnscp               rmb 2                   the position,
dnsan               rmb 2                   answers left
dnsqd               rmb 2                   and questions left
NetBufSize          equ 600                 a DHCP reply (up to 548) with its UDP header
netbuf              rmb NetBufSize          the config file, then a DNS answer with its UDP header
autoon              rmb 1                   Z run (2026-10-10): non-zero while it runs
autoidx             rmb 1                   the next autolist entry
autoleft            rmb 2                   main-loop passes left for the running test
viewnext            rmb 1                   the live view's next free line
wscc                rmb 1                   CC as the CPU speed test found it, put back at its end
sigcode             rmb 1                   a signal caught by sigtrap (0: none)
soundleft           rmb 1                   main-loop passes left before a sound test stops itself
chklabel            rmb 2                   the check line being judged: its label
chkfail             rmb 2                   the first BAD line's label, named in the summary (0: none)
vbase               rmb 1                   the running test's first line
sndreg              rmb 1
sndvalue            rmb 1
mousex              rmb 2
mousey              rmb 2
memphase            rmb 1
mempos              rmb 2
memgot              rmb 1
mismatch            rmb 2
source              rmb 256
destination         rmb 256
reference           rmb 256
exitmsg             rmb 2                   why diag could not run, printed at exit (0: it ran)
* pixraw starts the data area's second block (2026-10-10): one whole 8K block is always physically contiguous,
* whatever blocks the process was given (1.3's larger variables moved it across a block edge)
                    rmb $2000-.
pixraw              rmb 8192
                    rmb 512                 process stack, never mapped away
size                equ .
name                fcs /diag/
                    fcb 1
start               leax options,u
                    ldy #size-512
                    clra
initzero            sta ,x+
                    leay -1,y
                    bne initzero
                    lda >SYS0+7             machine ID: K2=$16, Jr2=$1A
                    sta board,u
* keyboard signals caught (2026-10-10, user: "Jr2 copy is not exiting or aborting tests"): the PS/2 driver turns
* Esc into BREAK ($05) and sends the abort signal for it; uncaught, that killed diag mid-test. sigtrap notes it
* and the main loop treats it as Esc.
                    leax sigtrap,pcr
                    os9 F$Icpt
* the window's colors first (2026-10-10): every exit after SS.Opt restores the window with them - read later, an
* early exit left black on black
                    lda #TXT_WHITE*16+TXT_BLACK  in case SS.FBRgs is not answered
                    sta oldfb,u
                    lda #1
                    ldb #SS.FBRgs
                    pshs u
                    os9 I$GetStt
                    puls u
                    bcs keepfb
                    sta oldfb,u
keepfb              lda #1
                    ldb #SS.ScSiz
                    pshs u
                    os9 I$GetStt
                    puls u
                    lbcs earlyexit
                    stx oldcols,u
                    sty oldrows,u
                    clra
                    ldb #SS.Opt
                    leax options,u
                    os9 I$GetStt
                    lbcs earlyexit
                    inc optvalid,u
                    leax options,u
                    leay rawopts,u
                    ldb #OPTCNT
copyopt             lda ,x+
                    sta ,y+
                    decb
                    bne copyopt
                    clr rawopts+PD.EKO-PD.OPT,u
                    clr rawopts+PD.PAU-PD.OPT,u
                    clr rawopts+PD.INT-PD.OPT,u
                    clr rawopts+PD.QUT-PD.OPT,u
                    clra
                    ldb #SS.Opt
                    leax rawopts,u
                    os9 I$SetStt
                    lbcs earlyexit
                    lbsr findwindow
                    lbcs nowindow
                    leax pixraw,u
                    stx pixbase,u
                    lbsr physicaladdr
                    ldd phys+1,u
                    std physical+1,u
                    lda phys,u
                    sta physical,u
                    lbsr checkcontiguous
                    lbcs nocontig
                    lbsr setpalette
* initseq holds zero bytes (the window's X and Y), so it goes out by its length, never through putz (2026-10-10:
* putz stopped at the first zero and DWSet took the next writes as its parameters - the cyan first screen)
                    leax initseq,pcr
                    ldy #initlen
                    lda #1
                    os9 I$Write
                    lbsr drawpage
mainloop            lbsr captureirq
                    tst autoon,u
                    beq mainlive
                    lbsr autostep
mainlive            tst running,u
                    beq getchoice
                    lbsr livetick
getchoice           tst sigcode,u           a keyboard signal (Esc on the Jr2) is Esc
                    beq getkey
                    clr sigcode,u
                    lda #KEY_ESC
                    sta key,u
                    lbra stopkey
getkey              clra
                    ldb #SS.Ready
                    os9 I$GetStt
                    bcs nap
                    clra
                    leax key,u
                    ldy #1
                    os9 I$Read
                    lbcs cleanup
                    lda key,u
                    sta lastkey,u
                    cmpa #KEY_RUNSTOP       off the K2 BREAK ($05) is the PS/2 Esc key (keydrv_ps2): Esc there
                    bne keyesc
                    ldb board,u
                    cmpb #MID_K2
                    beq keyesc
                    lda #KEY_ESC
                    sta key,u
keyesc              equ *
* 2026-10-09 (user: 'add cpu speed test (wildspeed) to the diag as "S" option, instead of "S" to stop tests, use
* ESC or TAB'): ESC, TAB or RUN/STOP (the K2 sends BREAK) stop a running test; ESC with nothing running exits.
                    cmpa #KEY_ESC
                    beq stopkey
                    cmpa #KEY_TAB
                    beq stopkey
                    cmpa #KEY_RUNSTOP
                    beq stopkey
                    cmpa #'q'
                    lbeq cleanup
                    cmpa #'Q'
                    lbeq cleanup
                    anda #$DF
                    cmpa #'R'
                    beq resetpanel
                    cmpa #'Z'               Z: the automatic run (2026-10-10)
                    lbeq autokey
* a test's key is the first letter of its entry in tests; B counts the entries to the one that matches
                    leax tests,pcr
                    clrb
testkey             cmpa ,x
                    beq testfound
testskip            tst ,x+
                    bne testskip
                    incb
                    cmpb #TestCount
                    blo testkey
                    bra nap
testfound           tfr b,a
testsel             tst running,u
                    bne nap                 typed test keys belong to live input test
                    sta selection,u
                    lbsr starttest
nap                 ldx #2
                    os9 F$Sleep
                    lbra mainloop
stopkey             tst autoon,u            a Z run: it ends, and its running test stops
                    beq stopidle
                    clr autoon,u
                    tst running,u
                    bne stoptest
                    leax autostopped,pcr
                    lbsr message
                    lbra nap
stopidle            tst running,u           a test running: stop it; else ESC leaves and TAB/RUN-STOP do nothing
                    bne stoptest
                    lda key,u
                    cmpa #KEY_ESC
                    lbeq cleanup
                    lbra nap
stoptest            lbsr stopsound
                    lbsr restoresprite
                    clr running,u
                    lbsr drawtests
                    lbra mainloop
resetpanel          lbsr resetresults
                    lbsr drawtests
                    lbra mainloop
* resetresults: any test stopped, every result back to NOT RUN, the failure count cleared, no bar
resetresults        lbsr stopsound
                    lbsr restoresprite
                    clr running,u
                    leax status,u
                    ldb #TestCount
                    clra
resetstatuses       sta ,x+
                    decb
                    bne resetstatuses
                    clr failures,u
                    clr failures+1,u
                    clr hilite,u
* markna: on a machine other than the K2, T (the W6100) and J (the K2 keyboard) are N/A (2026-10-10, user: "Use
* the Machine ID register to skip tests not possible on that machine")
markna              lda board,u
                    cmpa #MID_K2
                    beq mna1@
                    leax status,u
                    lda #StateNA
                    sta TestEther,x
                    sta TestK2Keys,x
mna1@               rts
* The Z run (2026-10-10, user: "diag should have an automatic mode ... that cycles through each non-keyboard,
* non-mouse tests"): the results reset, then every autolist test in turn; a live or audible test runs for
* AutoLoops main-loop passes and is stopped as Esc stops it. Esc, Tab or RUN/STOP end the run.
autokey             lbsr resetresults
                    clr autoidx,u
                    lda #1
                    sta autoon,u
                    lbra mainloop
autostep            tst running,u
                    beq as1@
                    ldd autoleft,u
                    subd #1
                    std autoleft,u
                    bne as9@
                    lbsr stopsound
                    lbsr restoresprite
                    clr running,u
as1@                lda autoidx,u           the rows in order, up to the manual-only ones
                    cmpa #TestAuto
                    beq as8@
                    inc autoidx,u
                    leax status,u           not this machine's: skipped
                    ldb a,x
                    cmpb #StateNA
                    beq as1@
                    sta selection,u
                    ldd #AutoLoops
                    std autoleft,u
                    lbra starttest
as8@                clr autoon,u
                    leax autodone,pcr
                    lbsr message
                    lda failures+1,u
                    lbra netdec
as9@                rts
* All cleanup paths retain owned memory until engines have stopped.
cleanup             lda >DMA.Base+DMA_STATUS_REG
                    lbmi cannotexit
                    tst gfxowned,u
                    beq safeexit
                    lbsr lineidle
                    lbcs cannotexit
safeexit            lbsr stopsound
                    tst soundon,u
                    lbne cannotexit
                    lbsr restoresprite
                    lbsr restoregraphics
                    lbsr restorepalette
                    clr >FPMATH_CTRL2
                    tst optvalid,u
                    lbeq earlyexit
                    clra
                    ldb #SS.Opt
                    leax options,u
                    os9 I$SetStt
                    leax exitseq,pcr
                    lbsr putz
                    leax restorewin,pcr
                    leay linebuf,u
                    ldb #10
restseq             lda ,x+
                    sta ,y+
                    decb
                    bne restseq
                    lda #4
                    ldx oldcols,u
                    cmpx #40
                    bne rest80
                    lda #3
rest80              ldy oldrows,u
                    cmpy #30
                    bne resttype
                    suba #2
resttype            sta linebuf+2,u
                    stb linebuf+3,u           B=0 from loop: starting x
                    stb linebuf+4,u
                    tfr x,d
                    stb linebuf+5,u
                    tfr y,d
                    stb linebuf+6,u
                    lda oldfb,u             the window's own colors (2026-10-10), not fixed ones
                    lsra
                    lsra
                    lsra
                    lsra
                    sta linebuf+7,u
                    lda oldfb,u
                    anda #$0F
                    sta linebuf+8,u
                    sta linebuf+9,u
                    leax linebuf,u
                    ldy #10
                    lda #1
                    os9 I$Write
                    ldx exitmsg,u           why diag could not run, on the restored window
                    beq exitquiet
                    lbsr putz
exitquiet           clrb
                    os9 F$Exit
earlyexit           os9 F$Exit
* diag cannot run (2026-10-10): the reason is kept for the exit, which prints it on the restored window
nowindow            leax nowindowmsg,pcr
                    bra noexit
nocontig            leax nocontigmsg,pcr
noexit              stx exitmsg,u
                    lbra cleanup
cannotexit          leax enginebusy,pcr
                    lbsr message
                    clr running,u
                    lbra mainloop
* The page (2026-10-09, user: "graphical framework like the photo has"): a double CP437 frame round the whole
* screen, single dividers under the title (RowTitleDiv), above the live view (RowLiveDiv) and the key help
* (RowKeyDiv); headings and key letters in ColKey, the rest ColText on ColBack, and
* the selected test's row as a bar (ColBarFg on ColBarBg) once a test has been chosen.
drawpage            lda #ViewTop            the live view starts empty
                    sta viewnext,u
                    lda #ColText            the colors first: the clear fills every cell with them (2026-10-10)
                    ldb #ColBack
                    lbsr setcolors
                    leax clearseq,pcr
                    lbsr putz
                    clr row,u
                    leax frametop,pcr
                    ldb #ScreenCols
                    lbsr hline
                    lda #RowTitleDiv
                    sta row,u
                    leax framemid,pcr
                    ldb #ScreenCols
                    lbsr hline
                    lda #RowLiveDiv
                    sta row,u
                    leax framemid,pcr       hline leaves X at linebuf: every row names its own ends (2026-10-10)
                    ldb #ScreenCols
                    lbsr hline
                    lda #RowKeyDiv
                    sta row,u
                    leax framemid,pcr
                    ldb #ScreenCols
                    lbsr hline
                    lda #FrameBottom
                    sta row,u
                    leax framebot,pcr
                    ldb #ScreenCols-1       the last cell would scroll the screen: framecorner writes it
                    lbsr hline
                    lbsr framecorner
                    lda #1
                    sta row,u
vertical            lda row,u
                    cmpa #RowTitleDiv
                    beq vnext
                    cmpa #RowLiveDiv
                    beq vnext
                    cmpa #RowKeyDiv
                    beq vnext
                    clrb
                    lbsr at
                    lda #BoxV2
                    lbsr putchar
                    lda row,u
                    ldb #FrameRight
                    lbsr at
                    lda #BoxV2
                    lbsr putchar
vnext               inc row,u
                    lda row,u
                    cmpa #FrameBottom
                    blo vertical
                    leax headings,pcr
                    lbsr layout
                    lbsr drawtests
                    leax footnotes,pcr
                    lbra layout
* drawtests: every test row, the selected one as the bar
drawtests           leax tests,pcr
                    leay testnotes,pcr
                    lda #TestRow0
                    sta row,u
                    clr col,u
testrow             lbsr drawtest
                    inc row,u
                    inc col,u
                    lda col,u
                    cmpa #TestCount
                    blo testrow
                    rts
* clearrow: A = a live-view row, blanked from column 3 to the frame; the cursor left at column 3. Keeps A, X.
clearrow            pshs a,b,x
                    ldb #3
                    lbsr at
                    ldb #FrameRight-3
                    lda #' '
clearrow1           lbsr putchar
                    decb
                    bne clearrow1
                    lda ,s
                    ldb #3
                    lbsr at
                    puls a,b,x,pc
* drawtest: X = the test's name ("K  Name"), Y = its note; row/col = its row and number. Returns X and Y past both.
drawtest            pshs x
                    lbsr testcolors          the bar for the selected row, else the page colors
                    lda row,u               the row's inside blanked in its colors (2026-10-10: a row that
*                                            lost the bar kept the gray between its words)
                    ldb #1
                    lbsr at
                    lda #' '
                    ldb #FrameRight-1
dtbar@              lbsr putchar
                    decb
                    bne dtbar@
* vtio also colors the cell after the one it writes, so the last blank (column FrameRight-1) turned the frame
* cell gray: the frame cell is written again in the page colors (2026-10-10)
                    lda #ColText
                    ldb #ColBack
                    lbsr setcolors
                    lda row,u
                    ldb #FrameRight
                    lbsr at
                    lda #BoxV2
                    lbsr putchar
                    lbsr testcolors
dt1@                lda row,u
                    ldb #3
                    lbsr at
                    puls x
                    tst hilite,u            the key letter in ColKey unless it is the bar
                    beq dt2@
                    lda col,u
                    cmpa selection,u
                    beq dt3@
dt2@                lda #ColKey
                    ldb #ColBack
                    lbsr setcolors
dt3@                lda ,x+
                    lbsr putchar
                    lbsr testcolors
                    lbsr putz
                    pshs x
                    leax status,u
                    ldb col,u
                    lda b,x
                    lsla
                    leax states,pcr
                    ldd a,x
                    leax d,x
                    lda row,u
                    ldb #28
                    lbsr at
                    lbsr putz
                    lda row,u
                    ldb #39
                    lbsr at
                    tfr y,x
                    lbsr putz
                    tfr x,y
                    puls x
                    lda #ColText
                    ldb #ColBack
                    lbra setcolors
* testcolors: the bar colors when row col is the highlighted selection, else ColText on ColBack. Keeps X/Y.
testcolors          lda #ColText
                    ldb #ColBack
                    tst hilite,u
                    beq tc1@
                    pshs a
                    lda col,u
                    cmpa selection,u
                    puls a
                    bne tc1@
                    lda #ColBarFg
                    ldb #ColBarBg
tc1@                lbra setcolors
* setcolors: A = the foreground color number, B = the background. Keeps X, Y and D.
setcolors           pshs d,x,y
                    leax linebuf,u
                    ldy #VT_ESC*256+VT_FCOLOR
                    sty ,x
                    sta 2,x
                    sty 3,x
                    lda #VT_BCOLOR
                    sta 4,x
                    stb 5,x
                    ldy #6
                    lda #1
                    os9 I$Write
                    puls d,x,y,pc
* hline: X = three characters (left, fill, right) for row row,u from column 0 to FrameRight; B = the cells
* written (ScreenCols, or one fewer on the bottom row, whose last cell framecorner writes)
hline               pshs b,x
                    lda row,u
                    clrb
                    lbsr at
                    puls b,x
                    pshs b,y                stack +0: the cells to write
                    leay linebuf,u
                    lda ,x
                    sta ,y+
                    lda 1,x
                    ldb #FrameRight-1
hfill               sta ,y+
                    decb
                    bne hfill
                    lda 2,x
                    sta ,y
                    leax linebuf,u
                    ldb ,s
                    clra
                    tfr d,y
                    lda #1
                    os9 I$Write
                    puls b,y,pc
* framecorner: the frame's bottom-right cell straight into text and color memory (writing it through the
* console moves the cursor past the last row, which scrolls the screen)
framecorner         lda #TEXT_RAM_BLK
                    lbsr mapio
                    lda #BoxBR
                    sta CornerOff,x
                    lbsr unmap
                    lda #COLOR_RAM_BLK
                    lbsr mapio
                    lda #ColText*16+ColBack
                    sta CornerOff,x
                    lbra unmap
layout              lda ,x+
                    cmpa #$FF
                    beq layoutdone
                    ldb ,x+
                    pshs x
                    lbsr at
                    puls x
                    lbsr putz
                    bra layout
layoutdone          rts
* at: A=row, B=column; preserves X,Y,D across OS call.
at                  pshs d,x,y
                    adda #32
                    addb #32
                    stb coord+1,u
                    sta coord+2,u
                    lda #2
                    sta coord,u
                    leax coord,u
                    ldy #3
                    lda #1
                    os9 I$Write
                    puls d,x,y,pc
putchar             pshs d,x,y
                    sta outbyte,u
                    leax outbyte,u
                    ldy #1
                    lda #1
                    os9 I$Write
                    puls d,x,y,pc
* putz: X zero-terminated string, returns X after terminator.
putz                pshs d,y
                    tfr x,y
strlen              tst ,y+
                    bne strlen
                    pshs y                  stack +0: next-string pointer
                    tfr y,d
                    subd #1
                    pshs x                  stack +0: start, +2: next pointer
                    subd ,s++
                    tfr d,y
                    lda #1
                    os9 I$Write
                    puls x
                    puls d,y,pc
hex8                pshs a
                    lsra
                    lsra
                    lsra
                    lsra
                    lbsr nibble
                    puls a
                    anda #15
nibble              pshs x
                    leax hexchars,pcr
                    lda a,x
                    lbsr putchar
                    puls x,pc
hex16               pshs b
                    lbsr hex8
                    puls a
                    lbra hex8
* message: X = a line for the live view, added below the last (the view scrolls when full)
message             pshs x
                    lda #1
                    lbsr vreserve
                    lbsr clearrow
                    puls x
                    lbra putz
* vreserve: A = lines wanted -> A = the first of them, below the last line used; the view scrolls up as needed
vreserve            pshs a
vr1@                lda viewnext,u
                    adda ,s
                    cmpa #ViewBot+1
                    bls vr2@
                    lda viewnext,u
                    cmpa #ViewTop
                    bls vr2@                more than the view holds: from its top
                    lbsr vscroll
                    bra vr1@
vr2@                lda viewnext,u
                    adda ,s
                    cmpa #ViewBot+1
                    bls vr3@
                    lda #ViewBot+1
vr3@                sta viewnext,u
                    suba ,s+
                    bcc vr4@
                    lda #ViewTop
vr4@                cmpa #ViewTop
                    bhs vr5@
                    lda #ViewTop
vr5@                rts
* vscroll: the view's rows move up one inside the frame (text and color memory), its last row blanked;
* vnext and vbase follow. The frame columns move with their rows: they are the same on every view row.
vscroll             pshs a,b,x,y
                    lda #TEXT_RAM_BLK
                    lbsr mapio
                    ldb #' '
                    bsr vscroll1
                    lbsr unmap
                    lda #COLOR_RAM_BLK
                    lbsr mapio
                    ldb #ColText*16+ColBack
                    bsr vscroll1
                    lbsr unmap
                    dec viewnext,u
                    dec vbase,u
                    puls a,b,x,y,pc
* vscroll1: X = the mapped page, B = the blank's byte: rows ViewTop+1..ViewBot to ViewTop..ViewBot-1, the last
* row's inside (columns 1 to FrameRight-1) set to B
vscroll1            pshs b
                    leay ViewTop*ScreenCols,x
                    ldx #(ViewBot-ViewTop)*ScreenCols/2
vs1@                ldd ScreenCols,y
                    std ,y++
                    leax -1,x
                    bne vs1@
                    leay 1,y                Y = the last row, column 1
                    ldx #FrameRight-1
                    puls b
vs2@                stb ,y+
                    leax -1,x
                    bne vs2@
                    rts
* vclear: the view's rows blanked inside the frame; the log starts again at its top
vclear              lda #ViewTop
vc1@                lbsr clearrow
                    inca
                    cmpa #ViewBot+1
                    blo vc1@
                    lda #ViewTop
                    sta viewnext,u
                    rts
* sigtrap: the signal intercept (F$Icpt): B = the signal, U = the data area; noted for the main loop
sigtrap             stb sigcode,u
                    rti
* tick: sleep one OS tick (2026-10-10: F$Sleep X=1 returns at once in this kernel, so every "ldx #1" wait
* was a burst of polls - the PING4 reply, the RTC second and the DHCP offer were all missed)
tick                pshs x
                    ldx #TickSleep
                    os9 F$Sleep
                    puls x,pc
setpass             lda #1
                    bra setstatus
setfail             ldd failures,u
                    addd #1
                    std failures,u
                    lda #2
setstatus           leax status,u
                    ldb selection,u
                    sta b,x
                    pshs d,x,y
                    adda #0                 A=status, build relative string offset
                    lsla
                    leax states,pcr
                    ldd a,x
                    leax d,x
                    pshs x                  stack +0: state string pointer
                    lda selection,u
                    sta col,u
                    adda #TestRow0
                    ldb #28
                    lbsr at
                    lbsr testcolors         the bar's colors on the selected row (2026-10-09)
                    puls x
                    lbsr putz
                    lda #ColText
                    ldb #ColBack
                    lbsr setcolors
                    puls d,x,y
                    rts
captureirq          ldx #INT_PENDING_0
                    leay irqnow,u
                    ldb #4
irqcap              lda ,x+
                    sta ,y
                    ora -4,y                irqseen immediately precedes irqnow
                    sta -4,y
                    leay 1,y
                    decb
                    bne irqcap
                    ldx #INT_MASK_0
                    leay irqmasks,u
                    ldd ,x
                    std ,y
                    ldd 2,x
                    std 2,y
                    rts
* Pick a window not overlapping the code, statics OR stack.
findwindow          leax module,pcr
                    stx codebegin,u
                    leax eom,pcr
                    stx codeend,u
                    leax size,u
                    stx dataend,u
                    ldx #MMU_SLOT_0
                    stx mapreg,u
                    clra
                    clrb
windowtry           std mapbase,u
                    addd #$2000
                    std windowend,u
                    cmpd codebegin,u
                    bls windowdata
                    ldd mapbase,u
                    cmpd codeend,u
                    blo windownext
windowdata          ldd windowend,u
                    pshs u                  stack +0: data-area start
                    cmpd ,s++
                    bls windowfound
                    ldd mapbase,u
                    cmpd dataend,u
                    bhs windowfound
windownext          ldx mapreg,u
                    leax 1,x
                    stx mapreg,u
                    cmpx #MMU_SLOT_7
                    beq windowbad
                    ldd windowend,u
                    bra windowtry
windowfound         andcc #$FE
                    rts
windowbad           ldb #E$MemFul
                    orcc #1
                    rts
* mapio: A=block. Saved CC lives in static storage, not under the mapping.
mapio               sta outbyte,u
                    tfr cc,a
                    sta savedcc,u
                    orcc #IntMasks
                    lda >MMU_MEM_CTRL
                    sta savedmap,u
                    lbsr editactive
                    ldx mapreg,u
                    lda ,x
                    sta savedslot,u
                    lda outbyte,u
                    sta ,x
                    ldx mapbase,u
                    rts
unmap               ldx mapreg,u
                    lda savedslot,u
                    sta ,x
                    lda savedmap,u
                    sta >MMU_MEM_CTRL
                    lda savedcc,u
                    tfr a,cc
                    rts
editactive          tfr a,b
                    andb #3
                    lslb
                    lslb
                    lslb
                    lslb
                    anda #$CF
                    pshs b                  stack +0: active-map edit bits
                    ora ,s+
                    sta >MMU_MEM_CTRL
                    rts
* physicaladdr: X=owned CPU pointer -> phys (24-bit), X preserved.
physicaladdr        pshs cc,d,x,y
                    orcc #IntMasks
                    lda >MMU_MEM_CTRL
                    pshs a                  stack +0: complete MMU control byte
                    lbsr editactive
                    tfr x,d
                    anda #$1F
                    std phys+1,u            offset within block
                    tfr x,d
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    ldy #MMU_SLOT_0
                    ldb a,y
                    lda ,s+
                    sta >MMU_MEM_CTRL
                    tfr b,a
                    lsra
                    lsra
                    lsra
                    sta phys,u
                    andb #7
                    lslb
                    lslb
                    lslb
                    lslb
                    lslb
                    orb phys+1,u
                    stb phys+1,u
                    puls cc,d,x,y,pc
starttest           lbsr stopsound
                    lbsr restoresprite
                    lda #1
                    sta hilite,u            the chosen test's row is the bar from now on
                    clr samples,u
                    clr samples+1,u
                    clr running,u
                    lbsr drawtests          the bar moves; the live view is kept
                    lda selection,u
                    cmpa #TestLines320
                    blo stgo
                    cmpa #TestBitmap
                    bhi stgo
                    lbsr vclear
stgo                leax descriptions,pcr
                    ldb selection,u
                    lslb
                    ldd b,x
                    leax d,x
                    lbsr message
                    leax vlines,pcr         the test's own lines below its description
                    ldb selection,u
                    lda b,x
                    lbsr vreserve
                    sta vbase,u
                    leax dispatch,pcr
                    ldb selection,u
                    lslb
                    ldd b,x
                    jsr d,x
                    rts
livetick            ldd samples,u
                    addd #1
                    std samples,u
                    ldb selection,u
                    cmpb #TestMath
                    lbeq mathlive
                    cmpb #TestFpu
                    lbeq fpulive
                    cmpb #TestMouse
                    lbeq mouselive
                    cmpb #TestSprites
                    lbeq spritelive
                    cmpb #TestIrq
                    lbeq irqlive
                    cmpb #TestPsg           D-G count down their sound (2026-10-10)
                    blo livein
                    cmpb #TestMidi
                    lbls soundlive
livein              lbra inputlive
                    use diag_hw.asm
initseq             fcb VT_ESC,VT_DWSET,VT_80X60,0,0,ScreenCols,FrameBottom+1,ColText,ColBack,ColBack
                    fcb VT_CURSOR,VT_CURSOR_OFF
initlen             equ *-initseq
restorewin          fcb VT_ESC,VT_DWSET,VT_80X60,0,0,80,30,0,0,0   type, size and colors filled in at exit
exitseq             fcb VT_CURSOR,VT_CURSOR_ON,0
clearseq            fcb $0C,0
hexchars            fcc "0123456789ABCDEF"
states              fdb state0-states,state1-states,state2-states,state3-states,state4-states,state5-states
state0              fcc "NOT RUN"
                    fcb 0
state1              fcc "PASS   "
                    fcb 0
state2              fcc "FAIL   "
                    fcb 0
state3              fcc "LIVE   "
                    fcb 0
state4              fcc "LISTEN "
                    fcb 0
state5              fcc "N/A    "
                    fcb 0
* vlines: each test's lines in the live view, by selection (A B C D E F G K L M N O P T W S H I J)
vlines              fcb DmaPrevOff+4,3,1,1,1,1,1,0,0,4,PrevRows+1,PrevRows+1,PrevRows+1,13,4,8,1,MouseLines,1
blankmsg            fcc "                                                                        "
                    fcb 0
nowindowmsg         fcc "diag: no free 8K slot to map hardware blocks through"
                    fcb C$CR,C$LF,0
nocontigmsg         fcc "diag: the 8K scratch buffer is not physically contiguous"
                    fcb C$CR,C$LF,0
enginebusy          fcc "Engine still owns scratch memory. Wait for idle or reset the machine."
                    fcb 0
autodone            fcc "Z run done. Tests failed: "
                    fcb 0
autostopped         fcc "Z run stopped."
                    fcb 0
frametop            fcb BoxTL,BoxH2,BoxTR
framemid            fcb BoxTeeL,BoxH1,BoxTeeR
framebot            fcb BoxBL,BoxH2,BoxBR
headings            fcb 1,3
                    fcc "WILDBITS DIAGNOSTICS: "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "DIAG 1.1"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcb 0,2,3
                    fcc "80 x 60 | Fixed I/O + Longview FC-FF | Owned-memory hardware tests"
                    fcb 0,4,3
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "TEST                     RESULT     TEST NOTES"
                    fcb VT_ESC,VT_FCOLOR,ColText,0,26,3
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "LIVE VIEW / PIXEL READBACK / TEST RESULTS"
                    fcb VT_ESC,VT_FCOLOR,ColText,0,55,3
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "A"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " DMA       "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "B"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Math      "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "C"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " FPU       "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "D"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " PSG       "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "E"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " SID       "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "F"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " OPL3"
                    fcb 0,56,3
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "G"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " MIDI      "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "K"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Sprites   "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "L"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Memory    "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "M"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " IRQ       "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "N"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Lines 320 "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "O"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Lines 640"
                    fcb 0,57,3
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "P"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Bitmap    "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "T"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Ethernet  "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "W"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " RTC       "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "S"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " CPU speed "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "H"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " PS/2 keys "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "I"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Mouse"
                    fcb 0,58,3
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "J"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " K2 keys   "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "Z"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Auto      "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "Esc/Tab/RUN-STOP"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Stop  "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "R"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Reset  "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "Q"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " or idle "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "Esc"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Exit"
                    fcb 0,$FF
footnotes           fcb 24,3
                    fcc "PASS = measured readback. LISTEN = confirm by ear. IRQ sampling can miss."
                    fcb 0,$FF
* testnotes: one per test, in the order of tests below (column 39)
testnotes           fcc "Copy/fill + OR/AND/XOR/MASK readback"
                    fcb 0
                    fcc "Animated multiply/divide/add results"
                    fcb 0
                    fcc "IEEE-754 multiply/divide/add checks"
                    fcb 0
                    fcc "Audible: 2 s, then silenced"
                    fcb 0
                    fcc "Audible: 2 s, then silenced"
                    fcb 0
                    fcc "Audible: 2 s, then silenced"
                    fcb 0
                    fcc "MIDI OUT + SAM2695; no RX FIFO drain"
                    fcb 0
                    fcc "One moving 8x8 sprite, state restored"
                    fcb 0
                    fcc "Owned 8K: walking bits/address patterns"
                    fcb 0
                    fcc "Pending/mask/observed, no ack writes"
                    fcb 0
                    fcc "Real line engine, 320 x 24 scratch"
                    fcb 0
                    fcc "Real line engine, 640 x 24 scratch"
                    fcb 0
                    fcc "8/4-bit patterns + text pixel preview"
                    fcb 0
                    fcc "K2: link, gateway, ping, NTP -> RTC"
                    fcb 0
                    fcc "BCD time/date ranges + 1 s tick, read"
                    fcb 0
                    fcc "7 bus-cycle classes, ~28 s, IRQs off"
                    fcb 0
                    fcc "Console key + PS/2 FIFO status"
                    fcb 0
                    fcc "Mouse position + PS/2 RX status plot"
                    fcb 0
                    fcc "K2 only: optical FIFO + console keys"
                    fcb 0
tests               fcc "A  DMA"
                    fcb 0
                    fcc "B  Integer math"
                    fcb 0
                    fcc "C  Floating point"
                    fcb 0
                    fcc "D  PSG"
                    fcb 0
                    fcc "E  SID"
                    fcb 0
                    fcc "F  OPL3"
                    fcb 0
                    fcc "G  MIDI synth"
                    fcb 0
                    fcc "K  Sprites"
                    fcb 0
                    fcc "L  Memory"
                    fcb 0
                    fcc "M  IRQ registers"
                    fcb 0
                    fcc "N  Lines 320"
                    fcb 0
                    fcc "O  Lines 640"
                    fcb 0
                    fcc "P  Bitmap"
                    fcb 0
                    fcc "T  Ethernet (W6100)"
                    fcb 0
                    fcc "W  Real-time clock"
                    fcb 0
                    fcc "S  CPU speed"
                    fcb 0
                    fcc "H  PS/2 keyboard"
                    fcb 0
                    fcc "I  Mouse"
                    fcb 0
                    fcc "J  K2 keyboard"
                    fcb 0
                    emod
eom                 equ *
                    end
