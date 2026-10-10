                    nam diag
                    ttl WildBits hardware diagnostics

                    ifp1
                    use defsfile
                    endc

                    mod eom,name,Prgrm+Objct,ReEnt+1,start,size

module              equ 0
TestCount           equ 20                  the tests' rows; their letters are in tests (re-lettered 2026-10-10)
* The test rows (2026-10-10, user: "automatic-capable first, then the manual-only modes"; "put RTC test after
* ethernet ... make cpu auto again"): a test's selection number is its row (TestRow0+n); its key is the first
* letter of its entry in tests. The Z run takes rows 0 to TestAuto-1: ... E, T, W, C.
* 2026-10-10 (user: "re-letter the tests so that W is WizFi, E is Ethernet, K is keyboard, P is PS/2 keyboard, M is
* mouse, D is DMA, F is FPU, I is Integer Math, C is CPU, B is bitmap, S is sprites, L is lines (performs both 320
* and 640)"; the rest by Roger's choice: G PSG, V SID, O OPL3, Y MIDI, A memory, N IRQ, T RTC):
*   D I F G V O Y U S A N L B E T W C | P M K   (U PCM added 2026-10-10)
TestMath            equ 1
TestFpu             equ 2
TestPsg             equ 3                   G, V, O and Y: the sound tests
TestMidi            equ 6
SoundTicks          equ 120                 a sound test's main-loop passes (one tick each): about 2 s
TestPcm             equ 7                   U, after the sound tests
TestSprites         equ 8
TestLines           equ 11                  L: running while its lines are shown
TestBitmap          equ 12                  B: running while the logo is shown
TestEther           equ 13                  E
TestRtc             equ 14                  T, its lines below E's
TestWiFi            equ 15                  W, its lines below T's (2026-10-10, user: "add WizFi test")
WfLines             equ 6                   W's result lines; the module's own lines are logged below them
WfLineMax           equ 74                  a received line's longest (columns 3-76)
TestSpeed           equ 16                  C, its lines below W's; the last of the Z run
TestAuto            equ 17                  rows 0-16 run in the Z run
TestRow0            equ 4                   the first test's row, right under the headings
NoBar               equ $FF                 barsel: no row has the bar
TestNameW           equ 24                  a test row's fields: the name after its key (columns 4-27),
TestStateW          equ 11                  the result (28-38)
TestNoteW           equ 40                  and the note (39-78)
TestPS2             equ 17                  P, M and K: the keyboard and mouse tests
TestMouse           equ 18
TestK2Keys          equ 19
AutoLoops           equ 150                 Z run: main-loop passes (2-tick naps) a live test runs, about 5 s
* Colors (2026-10-09, user: "make diag bg blue, text white, graphical framework like the photo has"): numbers in
* the core's default text palette (wildbits.d TXT_*), which diag loads itself (diagpal.inc) along with its own
* CP437 font (diagfont.inc, phoenixegafont) so the frame looks the same on any system; both restored at exit.
ColText             equ TXT_WHITE
ColBack             equ TXT_BLUE
ColKey              equ TXT_CYAN            key letters and headings, as Procomm's
ColBarFg            equ TXT_BLACK           the selected test's bar
ColBarBg            equ TXT_LTGRAY
ColNA               equ TXT_GRAY            a test this machine cannot run: grayed out, its key ignored (2026-10-10)
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
* The frame (2026-10-10, user: "the right border should be at 79, not 78"): the screen's last column. The frame's
* bottom is row 58 (2026-10-10, user: "do not do direct hardware access if you can avoid it"): its last cell goes out
* through the console like every other - the window is 60 rows, so the cursor wraps to row 59 without a scroll.
* Before, the bottom was the screen's last row and that one cell was poked into text and color memory.
ScreenCols          equ 80
FrameRight          equ ScreenCols-1
ScreenRows          equ 60
FrameBottom         equ 58                  the frame's bottom row; row 59 stays blank
RowTitleDiv         equ 2                   the single dividers: under the title,
RowLiveDiv          equ 25                  above the live view (the footnote row, TestRow0+TestCount, above it)
RowKeyDiv           equ 53                  and above the key help (rows RowKeyDiv+1 to FrameBottom-1)
* The live view (2026-10-10, user: "do a CLS of the live view once, and don't cls again unless you're doing the line
* or bitmap tests"; "the view port should SCROLL itself ... do not scroll the frame"): rows ViewTop-ViewBot are a
* log. Each message is a new line; each test reserves its lines (vlines) below the last, and the rows scroll up
* inside the frame when it is full. vbase is the running test's first line.
ViewTop             equ RowLiveDiv+2
ViewBot             equ RowKeyDiv-1
ViewRows            equ ViewBot-ViewTop+1      the live view's rows
ViewIn              equ ScreenCols-2           its columns inside the borders (1 to FrameRight-1)
TickSleep           equ 2                   F$Sleep X=2 sleeps one tick; X=1 only yields (fsleep.asm counts down first)
DmaPrevOff          equ 7                   the DMA test's preview, below its six operation lines
MouseGridOff        equ 2                   the mouse grid's first line
MouseLines          equ 22                  its label, a blank line and 20 grid lines
StateNA             equ 5                   a test this machine cannot run
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
keycount            rmb 1                   keys read (2026-10-10): P and K draw a line when it changes
kdrawn              rmb 1                   keycount as last drawn
status              rmb TestCount
samples             rmb 2
operand             rmb 2
result              rmb 4
expected            rmb 4
failures            rmb 2
irqidx              rmb 1                   N (2026-10-10): the source's number, its line
irqent              rmb 2                   its irqsources entry
irqgrp              rmb 1                   its IRQ group (0-3)
irqbit              rmb 1                   its bit in the group
irqsave             rmb 2                   the source's registers as found (RTC rates/enables, VIA IER/ACR)
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
oldline             rmb 1
sprmcr              rmb 2                   S: the master control (low, high) as the OS gave it
gfxmcr              rmb 2                   L: the master control as found
gfxbmctl            rmb 1                   L: bitmap 0's control byte as found
gfxalloc            rmb 1                   L: SS.AScrn allocated bitmap 0
gfxblk              rmb 2                   L: bitmap 0's first block
pcmmask             rmb 1                   U: the channels of the tone
pcmhalf             rmb 2                   U: delay loops per half wave
pcmlevel            rmb 2                   U: the sample
paletteowned        rmb 1
spriteon            rmb 1
bgsave              rmb 3                   VICKY's graphics background color (B, G, R) as found
bgowned             rmb 1                   diag's blue is in it (bgset)
sprstate            rmb 32*6                S: x(2) y(2) dx(1) dy(1) for each sprite
sprleft             rmb 2                   S: main-loop passes left
spraddr             rmb 3                   S: the next sprite's pixel address
sprloop             rmb 1                   S: records left to write
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
ntpskip             rmb 1                   E or W: the network time step failed - SKIP, not counted
chkmark             rmb 1                   chkerrs at the start of a result line
ethsave             rmb 2                   registers restored after a write test
hilite              rmb 1                   non-zero: the selected test's row is drawn as the bar
fontsave            rmb FONT_BANK_SIZE      the system's font bank 0, restored at exit
lutsave             rmb TXT_LUT_SIZE*2      the system's text LUTs (foreground, background)
oldfb               rmb 1                   the window's colors on entry (SS.FBRgs), back at exit
rtcregs             rmb RTC_YEAR+1          RTC test (2026-10-10): RTC_SEC..RTC_YEAR as read under UTI
rtcctrl             rmb 1                   RTC_CTRL
rtccent             rmb 1                   RTC_CENTURY
rtcprev             rmb 1                   the second an edge is waited from
rtcticks            rmb 1                   OS ticks until it changed
rtcsecs             rmb 3                   the seconds at the start and the next two edges
ostime              rmb 6                   F$Time: YY MM DD HH MM SS
wfctl               rmb 1                   WizFi test (2026-10-10): the control register as found
wfrst               rmb 1                   the reset register as found
wfbytes             rmb 2                   bytes received since the reset
wfquiet             rmb 2                   ticks since the last byte
wfleft              rmb 2                   ticks left for the step
wfprog              rmb 1                   ticks to the next progress update
wfflags             rmb 1                   what the module has said (WfReadyF ...)
wfshow              rmb 1                   non-zero: complete lines go to the live view
wfshown             rmb 1                   lines shown
wftries             rmb 1                   AT+CIPSNTPTIME? queries left
wflen               rmb 1                   characters in wfline
wfline              rmb WfLineMax+1         the line being received
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
dhcpstage           rmb 1                   the DHCP step reached (DhcpStOpen..DhcpStAck), named when it fails
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
vsrow               rmb 1                   vscroll: the row being moved
wscc                rmb 1                   CC as the CPU speed test found it, put back at its end
sigcode             rmb 1                   a signal caught by sigtrap (0: none)
soundleft           rmb 1                   main-loop passes left before a sound test stops itself
chklabel            rmb 2                   the check line being judged: its label
chkfail             rmb 2                   the first BAD line's label, named in the summary (0: none)
mouseosok           rmb 1                   the OS has the mouse: its position comes from SS.Mouse
barsel              rmb 1                   the test row drawn as the bar (NoBar: none)
vbase               rmb 1                   the running test's first line
sndreg              rmb 1
sndvalue            rmb 1
mousex              rmb 2
mousey              rmb 2
mprevx              rmb 2                   the mouse as last drawn (2026-10-10): only a change is drawn
mprevy              rmb 2
mprevb              rmb 1
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
* Level 2 multiterminal (2026-10-11, user: "make diag comply with multi-term where we write only to vicky shadow
* registers from commit 61d89bd8"): the level, the console tracker and the live view's own copy
lvl2                rmb 1                   running under Level 2 (F$GPrDsc answered)
tstate              rmb 1                   the tracker's escape state (track)
tskip               rmb 1                   parameter bytes still to skip
tgcol               rmb 1                   a cursor move's column, until its row arrives
trow                rmb 1                   the console cursor, as diag has moved it
tcol                rmb 1
tfg                 rmb 1                   the colors in force
tbg                 rmb 1
rattr               rmb 1                   vscroll's redraw: the colors last emitted
lnptr               rmb 2                   L on Level 2: the next line record, and how many are left
lnleft              rmb 1
gfxlay0             rmb 1                   L on Level 2: layer 0's source as found
logoptr             rmb 2                   B: the logo's next run
logooff             rmb 2                   B: the row's offset in bitmap 0
logocnt             rmb 2                   B: pixels left in the row being decoded
loglen              rmb 1                   B: the run's length
logorow             rmb 1                   B: rows drawn
segblk              rmb 1                   B: the bitmap block being written (0-9)
seginoff            rmb 2                   B: the offset in it
segcnt              rmb 2                   B: bytes left to write there
logowin             rmb 2                   B on Level 2: the block's window (F$MapBlk)
shtext              rmb ViewRows*ViewIn     the view's characters, row by row, columns 1 to FrameRight-1
shattr              rmb ViewRows*ViewIn     their colors (foreground * 16 + background), right after
glyphsok            rmb 1                   Level 2: diag's frame characters are in (glyphsin)
rowbuf              rmb ViewIn*7+8          one view row with its color changes, for the redraw
                    rmb 512                 process stack, never mapped away
size                equ .
name                fcs /diag/
                    fcb 1                   edition 1 = DIAG 1.1 (2026-10-10, user: "set diag to 1.1")
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
* Level 2? F$GPrDsc ($18) exists only there (Level 1 answers E$UnkSvc); the 512-byte copy lands in pixraw, unused yet
                    clr lvl2,u
                    os9 F$ID
                    leax pixraw,u
                    os9 $18
                    bcs mt_lv1
                    inc lvl2,u
mt_lv1              lbsr setpalette
* initseq holds zero bytes (the window's X and Y), so it goes out by its length, never through putz (2026-10-10:
* putz stopped at the first zero and DWSet took the next writes as its parameters - the cyan first screen)
                    leax initseq,pcr
                    ldy #initlen
                    lbsr conwrite
                    lbsr markna             this machine's N/A tests grayed out and disabled from the start (2026-10-10)
                    lbsr drawpage
* 2026-10-10 (user: "it has to do with irq bashing/polling ... just use it properly"): the main loop no longer
* reads the IRQ controller on every pass; only N's loopback touches it, once per source
mainloop            tst autoon,u
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
                    inc keycount,u          P and K draw when this changes
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
                    leax status,u           an N/A test is disabled: its key does nothing (2026-10-10, user)
                    ldb a,x
                    cmpb #StateNA
                    beq nap
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
                    lbsr restoregraphics
                    clr running,u
                    lbra mainloop
resetpanel          lbsr resetresults
                    lbsr drawtests
                    lbra mainloop
* resetresults: any test stopped, every result back to PENDING, the failure count cleared, no bar
resetresults        lbsr stopsound
                    lbsr restoresprite
                    lbsr restoregraphics
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
* markna: on a machine other than the K2, E (the W6100) and K (the K2 keyboard) are N/A, grayed out and disabled (2026-10-10, user: "Use
* the Machine ID register to skip tests not possible on that machine")
markna              lda board,u
                    cmpa #MID_K2
                    beq mna1@
                    leax status,u
                    lda #StateNA
                    sta TestEther,x
                    sta TestK2Keys,x
                    ldb board,u             W (the WizFi360) only on the WildBits boards
                    cmpb #MID_JR2
                    beq mna1@
                    sta TestWiFi,x
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
                    lbsr restoregraphics
                    clr running,u
as1@                lda autoidx,u           autolist in order, up to the manual-only rows
                    cmpa #TestAuto
                    beq as8@
                    inc autoidx,u
                    leax autolist,pcr
                    lda a,x                 A = the test's row
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
* autolist: the Z run's order - the rows in order, except that T (the RTC) comes after both network tests, E
* (Ethernet, K2) and W (WizFi), which set the clock (2026-10-10, user: "rtc should come after either network
* device"); before, the Jr2 checked the RTC before W had set it. TestAuto entries.
autolist            fcb 0,1,2,3,4,5,6,7,8,9,10,11,12
                    fcb TestEther,TestWiFi,TestRtc,TestSpeed
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
                    lbsr conwrite
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
                    ldb #ScreenCols
                    lbsr hline
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
                    leax keylayout,pcr
                    lbsr layout
                    lbsr machname
                    lbsr drawtests
                    leax footnotes,pcr
                    lbra layout
* machname (2026-10-10, user: "in the title bar it should show the machine name of the machine"): " - " and the
* name for the machine ID (SYS_MID) after the title, in the title's key color; an unknown ID is shown in hex
machname            lda #ColKey             " - " and the name in the title's color too
                    ldb #ColBack
                    lbsr setcolors
                    lda #1
                    ldb #MachCol
                    lbsr at
                    leax machsep,pcr
                    lbsr putz
                    leax machnames,pcr
mn1@                lda ,x+                 the ID, then its name; MachEnd ends the table
                    cmpa #MachEnd
                    beq mn4@
                    cmpa board,u
                    beq mn3@
mn2@                tst ,x+
                    bne mn2@
                    bra mn1@
mn3@                lbsr putz
                    bra mn5@
mn4@                leax machunknown,pcr
                    lbsr putz
                    lda board,u
                    lbsr hex8
mn5@                lda #ColText
                    ldb #ColBack
                    lbra setcolors
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
                    lda #NoBar              the bar's row as drawn
                    tst hilite,u
                    beq tr1@
                    lda selection,u
tr1@                sta barsel,u
                    rts
* movebar (2026-10-10, user: "you're redrawing the test list WHY"): the bar moves to the selection - the row
* that had it and the selection's row are redrawn, nothing else
movebar             lda barsel,u
                    cmpa selection,u
                    beq mb2@
                    cmpa #NoBar
                    beq mb1@
                    lbsr drawone            the old row, without the bar
mb1@                lda selection,u
                    sta barsel,u
                    lbra drawone
mb2@                rts
* drawone: A = a test's number: its row alone redrawn
drawone             sta col,u
                    tfr a,b
                    adda #TestRow0
                    sta row,u
                    leax tests,pcr
                    leay testnotes,pcr
                    tstb
                    beq do3@
do1@                tst ,x+                 past one name
                    bne do1@
do2@                tst ,y+                 and its note
                    bne do2@
                    decb
                    bne do1@
do3@                lbra drawtest
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
* The row is written once, left to right, every field padded with spaces to the next (2026-10-10, user: "why is
* the test list being redrawn with clears, there's a pass that's visible"): no blanking pass, so nothing flickers.
drawtest            pshs x
                    lbsr testcolors          the row's colors: the bar, or the page
                    lda row,u
                    ldb #1
                    lbsr at
                    lda #' '                 columns 1 and 2
                    lbsr putchar
                    lbsr putchar
                    puls x
                    tst hilite,u            the key letter in ColKey unless it is the bar
                    beq dt2@
                    lda col,u
                    cmpa selection,u
                    beq dt3@
dt2@                lda #ColKey
                    lbsr testna
                    bne dt4@
                    lda #ColNA              an N/A row's key is grayed out with the rest of it
dt4@                ldb #ColBack
                    lbsr setcolors
dt3@                lda ,x+
                    lbsr putchar
                    lbsr testcolors
                    ldb #TestNameW
                    lbsr putpad
                    pshs x
                    leax status,u
                    ldb col,u
                    lda b,x
                    lsla
                    leax states,pcr
                    ldd a,x
                    leax d,x
                    ldb #TestStateW
                    lbsr putpad
                    tfr y,x
                    ldb #TestNoteW
                    lbsr putpad
                    tfr x,y
* vtio also colors the cell after the one it writes, so the last field's end (column FrameRight-1) turned the frame
* cell to the row's colors: the frame cell is written again in the page colors
                    lda #ColText
                    ldb #ColBack
                    lbsr setcolors
                    lda row,u
                    ldb #FrameRight
                    lbsr at
                    lda #BoxV2
                    lbsr putchar
                    puls x,pc
* putpad: X = a string, B = its field's width: the string, then spaces to the field's end. Returns X past the
* string; keeps B and Y.
putpad              pshs b,y
                    tfr x,y
pp1@                tst ,y+
                    bne pp1@
                    tfr y,d
                    pshs x
                    subd ,s++               D = the length + 1
                    decb
                    negb
                    addb ,s                 B = the width - the length
                    lbsr putz
                    tstb
                    ble pp3@
                    lda #' '
pp2@                lbsr putchar
                    decb
                    bne pp2@
pp3@                puls b,y,pc
* testcolors: the bar colors when row col is the highlighted selection, else ColText on ColBack. Keeps X/Y.
testcolors          lda #ColText
                    ldb #ColBack
                    lbsr testna             an N/A row is gray (it never has the bar: it cannot be selected)
                    bne tc2@
                    lda #ColNA
                    bra tc1@
tc2@                tst hilite,u
                    beq tc1@
                    pshs a
                    lda col,u
                    cmpa selection,u
                    puls a
                    bne tc1@
                    lda #ColBarFg
                    ldb #ColBarBg
tc1@                lbra setcolors
* testna: Z set when test col is N/A on this machine. Keeps D, X and Y.
testna              pshs d,x
                    leax status,u
                    ldb col,u
                    lda b,x
                    cmpa #StateNA
                    puls d,x,pc
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
                    lbsr conwrite
                    puls d,x,y,pc
* hline: X = three characters (left, fill, right) for row row,u from column 0 to FrameRight; B = the cells
* written (ScreenCols)
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
                    lbsr conwrite
                    puls b,y,pc
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
                    lbsr conwrite
                    puls d,x,y,pc
* conwrite (2026-10-11, multiterminal): X = the bytes, Y = how many: written to the console (path 1). On Level 2
* track follows them, so the live view's copy holds what the console shows. Keeps D, X and Y.
conwrite            pshs d,x,y
                    lda #1
                    os9 I$Write
                    tst lvl2,u
                    beq mt_cw9
                    ldx 2,s
                    ldy 4,s
                    beq mt_cw9
mt_cw1              lda ,x+
                    lbsr track
                    leay -1,y
                    bne mt_cw1
mt_cw9              puls d,x,y,pc
* track: A = one byte the console was given. The escapes diag sends move the tracked cursor (02 col row), set the
* colors (1B 32 / 1B 33), clear the screen (0C) or are skipped with their parameters (1B 20 window: 8, 1B 60 /
* 1B 61 palette: 5, 05 and 1F: 1); a character inside the view goes into shtext/shattr; the cursor advances and
* wraps at the screen's width as vtio's does. Keeps every register.
track               pshs d,x
                    ldb tstate,u
                    bne mt_trs
                    cmpa #$20
                    lbhs mt_trc
                    cmpa #VT_ESC
                    bne mt_tr1
                    ldb #1
                    bra mt_trset
mt_tr1              cmpa #VT_GOTOXY
                    bne mt_tr2
                    ldb #4
                    bra mt_trset
mt_tr2              cmpa #$0C
                    bne mt_tr3
                    lbsr shclear
                    clr trow,u
                    clr tcol,u
                    bra mt_trx
mt_tr3              cmpa #C$CR
                    bne mt_tr4
                    clr tcol,u
                    bra mt_trx
mt_tr4              cmpa #C$LF
                    bne mt_tr5
                    inc trow,u
                    bra mt_trx
mt_tr5              cmpa #VT_CURSOR
                    beq mt_tr6
                    cmpa #$1F
                    bne mt_trx
mt_tr6              ldb #7                  one parameter byte follows
mt_trset            stb tstate,u
mt_trx              puls d,x,pc
mt_trs              cmpb #1                 after ESC: the code
                    bne mt_ts2
                    ldb #2
                    cmpa #VT_FCOLOR
                    beq mt_trset
                    ldb #3
                    cmpa #VT_BCOLOR
                    beq mt_trset
                    ldb #8
                    cmpa #VT_DWSET
                    beq mt_ts1s
                    ldb #5
                    cmpa #$60
                    beq mt_ts1s
                    cmpa #$61
                    beq mt_ts1s
                    clr tstate,u
                    bra mt_trx
mt_ts1s             stb tskip,u
                    ldb #6
                    bra mt_trset
mt_ts2              cmpb #2
                    bne mt_ts3
                    sta tfg,u
                    bra mt_ts0
mt_ts3              cmpb #3
                    bne mt_ts4
                    sta tbg,u
                    bra mt_ts0
mt_ts4              cmpb #4
                    bne mt_ts5
                    suba #32
                    sta tgcol,u
                    ldb #5
                    bra mt_trset
mt_ts5              cmpb #5
                    bne mt_ts6
                    suba #32
                    sta trow,u
                    lda tgcol,u
                    sta tcol,u
                    bra mt_ts0
mt_ts6              cmpb #6
                    bne mt_ts0
                    dec tskip,u
                    bne mt_trx
mt_ts0              clr tstate,u
                    bra mt_trx
mt_trc              ldb trow,u              a character: in the view?
                    subb #ViewTop
                    blo mt_trn
                    cmpb #ViewRows
                    bhs mt_trn
                    lda tcol,u
                    deca
                    cmpa #ViewIn
                    bhs mt_trn
                    pshs a
                    lda #ViewIn
                    mul
                    addb ,s+
                    adca #0
                    leax shtext,u
                    leax d,x
                    lda ,s                  the character
                    sta ,x
                    lda tfg,u
                    lsla
                    lsla
                    lsla
                    lsla
                    ora tbg,u
                    sta ViewRows*ViewIn,x
mt_trn              inc tcol,u
                    lda tcol,u
                    cmpa #ScreenCols
                    lblo mt_trx
                    clr tcol,u
                    inc trow,u
                    lbra mt_trx
* shclear: the view's copy blank, in the colors in force (the console's clear fills with them)
shclear             pshs d,x,y
                    leax shtext,u
                    lda tfg,u
                    lsla
                    lsla
                    lsla
                    lsla
                    ora tbg,u
                    ldy #ViewRows*ViewIn
mt_shc1             ldb #' '
                    stb ,x
                    sta ViewRows*ViewIn,x
                    leax 1,x
                    leay -1,y
                    bne mt_shc1
                    puls d,x,y,pc
putchar             pshs d,x,y
                    sta outbyte,u
                    leax outbyte,u
                    ldy #1
                    lbsr conwrite
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
                    lbsr conwrite
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
* vscroll (2026-10-10, user: "console delete-line should not be used inside a view port smaller than the screen",
* "you will SCROLL THE VIEW PORT but not outside of it's border lines"): the console's delete line moved every row
* below the view - the key help and the frame's bottom - and they were redrawn after, so the lower section bounced
* (Jr2). Neither console scrolls part of the screen (Level 1 vtio has no window origin and DWSet clears the screen),
* so the view's cells are moved in text and color memory: rows ViewTop+1..ViewBot up one, columns 1 to
* FrameRight-1 only - the border columns and every row outside the view are never written - then the last row's
* inside blanked. One row and one page per mapping, so IRQs are masked for one 78-cell copy at a time. vnext and
* vbase follow.
vscroll             pshs a,b,x,y
                    tst lvl2,u
                    lbne vscroll2
                    lda #ViewTop
                    sta vsrow,u
vsc1@               lda vsrow,u
                    cmpa #ViewBot
                    bhs vsc2@
                    lda #TEXT_RAM_BLK
                    lbsr vsrowcopy
                    lda #COLOR_RAM_BLK
                    lbsr vsrowcopy
                    inc vsrow,u
                    bra vsc1@
vsc2@               lda #TEXT_RAM_BLK
                    ldb #' '
                    lbsr vsrowfill
                    lda #COLOR_RAM_BLK
                    ldb #ColText*16+ColBack
                    lbsr vsrowfill
                    dec viewnext,u
                    dec vbase,u
                    puls a,b,x,y,pc
* vscroll2 (2026-10-11, multiterminal): Level 2 writes no text or color memory - the terminal may be in the
* background, and then that memory is another terminal's screen. The view's own copy (shtext/shattr, kept by
* track from everything diag sends to the console) moves up one row, its last row blanked, and every view row is
* written again through the console at columns 1 to FrameRight-1: the borders and the rows outside the view are
* never written, and a background terminal gets it in its own buffer. The colors in force are put back after.
vscroll2            leay shtext,u           text: rows 1.. up one
                    leax ViewIn,y
                    ldd #(ViewRows-1)*ViewIn
                    lbsr shmove
                    leay shattr,u           colors the same
                    leax ViewIn,y
                    ldd #(ViewRows-1)*ViewIn
                    lbsr shmove
                    leax shtext+(ViewRows-1)*ViewIn,u   the last row: blank, in diag's colors
                    ldb #ViewIn
mt_vs2b             lda #' '
                    sta ,x
                    lda #ColText*16+ColBack
                    sta ViewRows*ViewIn,x
                    leax 1,x
                    decb
                    bne mt_vs2b
                    lda tfg,u               the colors in force, put back after
                    ldb tbg,u
                    pshs d
                    clr vsrow,u
mt_vs2r             lda vsrow,u
                    adda #ViewTop
                    ldb #1
                    lbsr at
                    lda vsrow,u             Y = the row in the copy
                    ldb #ViewIn
                    mul
                    leay shtext,u
                    leay d,y
                    leax rowbuf,u
                    lda #$FF                the first cell always sets its colors
                    sta rattr,u
                    ldb #ViewIn
mt_vs2c             pshs b
                    lda ViewRows*ViewIn,y   its colors
                    cmpa rattr,u
                    beq mt_vs2d
                    sta rattr,u
                    ldb #VT_ESC
                    stb ,x+
                    ldb #VT_FCOLOR
                    stb ,x+
                    tfr a,b
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    stb ,x+
                    ldb #VT_ESC
                    stb ,x+
                    ldb #VT_BCOLOR
                    stb ,x+
                    anda #$0F
                    sta ,x+
mt_vs2d             lda ,y+
                    sta ,x+
                    puls b
                    decb
                    bne mt_vs2c
                    tfr x,d                 the row out in one write
                    leax rowbuf,u
                    pshs x
                    subd ,s++
                    tfr d,y
                    lbsr conwrite
                    inc vsrow,u
                    lda vsrow,u
                    cmpa #ViewRows
                    blo mt_vs2r
                    puls d
                    lbsr setcolors
                    dec viewnext,u
                    dec vbase,u
                    puls a,b,x,y,pc
* shmove: D bytes from X to Y, upward (Y below X)
shmove              pshs d
mt_sm1              lda ,x+
                    sta ,y+
                    ldd ,s
                    subd #1
                    std ,s
                    bne mt_sm1
                    puls d,pc
* vsrowcopy: A = the page (text or color): row vsrow's inside from the row below it. Y is used.
vsrowcopy           lbsr mapio              X = the page
                    lda vsrow,u
                    ldb #ScreenCols
                    mul
                    addd #1                 column 1
                    leax d,x
                    ldy #(FrameRight-1)/2   the inside, two cells a move
vrc1@               ldd ScreenCols,x
                    std ,x++
                    leay -1,y
                    bne vrc1@
                    lbra unmap
* vsrowfill: A = the page, B = the byte: the view's last row's inside set to B. Y is used.
vsrowfill           pshs b
                    lbsr mapio
                    lda #ViewBot
                    ldb #ScreenCols
                    mul
                    addd #1
                    leax d,x
                    puls b
                    ldy #FrameRight-1
vrf1@               stb ,x+
                    leay -1,y
                    bne vrf1@
                    lbra unmap
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
                    lbsr restoregraphics
                    lda #1
                    sta hilite,u            the chosen test's row is the bar from now on
                    clr samples,u
                    clr samples+1,u
                    clr running,u
                    lbsr movebar            only the bar's old and new rows; the live view is kept
* L and B keep the log (2026-10-10, user: "does not clear the live view, bitmap does not clear live view either")
                    leax descriptions,pcr
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
                    cmpb #TestLines
                    lbeq lineslive
                    cmpb #TestBitmap
                    lbeq lineslive
                    cmpb #TestPsg           G, V, O and Y count down their sound (2026-10-10)
                    blo livein
                    cmpb #TestMidi
                    lbls soundlive
livein              lbra inputlive
                    use diag_hw.asm
initseq             fcb VT_ESC,VT_DWSET,VT_80X60,0,0,ScreenCols,ScreenRows,ColText,ColBack,ColBack   border = ColBack
                    fcb VT_CURSOR,VT_CURSOR_OFF
initlen             equ *-initseq
restorewin          fcb VT_ESC,VT_DWSET,VT_80X60,0,0,80,30,0,0,0   type, size and colors filled in at exit
exitseq             fcb VT_CURSOR,VT_CURSOR_ON,0
clearseq            fcb $0C,0
hexchars            fcc "0123456789ABCDEF"
states              fdb state0-states,state1-states,state2-states,state3-states,state4-states,state5-states
state0              fcc "PENDING"             (2026-10-10, user: was "NOT RUN")
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
* vlines: each test's lines in the live view, by selection (D I F G V O Y U S A N L B E T W C P M K)
vlines              fcb DmaPrevOff+4,3,1,1,1,1,1,1,0,0,5,1,0,13,4,WfLines,8,1,MouseLines,1
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
MachCol             equ 3+22+8              after "WILDBITS DIAGNOSTICS: DIAG 1.1"
MachEnd             equ $FF
machsep             fcc " - "
                    fcb 0
machnames           fcb MID_K2
                    fcc "K2"
                    fcb 0,MID_JR2
                    fcc "Jr2"
                    fcb 0,MID_K
                    fcc "F256K"
                    fcb 0,MID_JR
                    fcc "F256Jr"
                    fcb 0,MachEnd
machunknown         fcc "machine ID $"
                    fcb 0
headings            fcb 1,3
                    fcb VT_ESC,VT_FCOLOR,ColKey     the whole title in the key color (2026-10-10, user)
                    fcc "WILDBITS DIAGNOSTICS: DIAG 1.1"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcb 0,RowTitleDiv+1,3   (2026-10-10, user: the "80 x 60" row removed entirely)
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "TEST                     RESULT     TEST NOTES"
                    fcb VT_ESC,VT_FCOLOR,ColText,0,RowLiveDiv+1,3
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "LIVE VIEW / PIXEL READBACK / TEST RESULTS"
                    fcb VT_ESC,VT_FCOLOR,ColText,0,$FF
* keylayout: the key help (drawpage)
keylayout           fcb RowKeyDiv+1,3
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "D"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " DMA     "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "I"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Math    "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "F"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " FPU     "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "G"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " PSG     "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "V"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " SID     "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "O"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " OPL3    "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "Y"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " MIDI"
                    fcb 0,RowKeyDiv+2,3
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "U"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " PCM     "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "S"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Sprites "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "A"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Memory  "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "N"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " IRQ     "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "L"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Lines   "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "B"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Bitmap"
                    fcb 0,RowKeyDiv+3,3
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "E"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Ether   "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "T"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " RTC     "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "W"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " WizFi   "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "C"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " CPU     "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "P"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " PS/2    "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "M"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Mouse   "
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "K"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " K2 keys"
                    fcb 0,RowKeyDiv+4,3
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "Z"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcc " Auto     "
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
footnotes           fcb TestRow0+TestCount,3
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
                    fcc "Audible: left, right, both tones"
                    fcb 0
                    fcc "32 bouncing sprites for 5 s"
                    fcb 0
                    fcc "Owned 8K: walking bits/address patterns"
                    fcb 0
                    fcc "Timers, DMA, RTC, VIA0: each fires once"
                    fcb 0
                    fcc "Line fan in bitmap 0, cleared first"
                    fcb 0
                    fcc "Pattern readback + logo in bitmap 0"
                    fcb 0
                    fcc "K2: link, gateway, ping, NTP -> RTC"
                    fcb 0
                    fcc "BCD time/date ranges + 1 s tick, read"
                    fcb 0
                    fcc "Chip reset, boot text, SNTP -> RTC"
                    fcb 0
                    fcc "7 bus-cycle classes, 1 s IRQ-off windows"
                    fcb 0
                    fcc "Console keys through the OS, read only"
                    fcb 0
                    fcc "OS mouse on a 64 x 20 grid, read only"
                    fcb 0
                    fcc "K2 only: optical FIFO + console keys"
                    fcb 0
tests               fcc "D  DMA"
                    fcb 0
                    fcc "I  Integer math"
                    fcb 0
                    fcc "F  Floating point"
                    fcb 0
                    fcc "G  PSG"
                    fcb 0
                    fcc "V  SID"
                    fcb 0
                    fcc "O  OPL3"
                    fcb 0
                    fcc "Y  MIDI synth"
                    fcb 0
                    fcc "U  PCM stereo"
                    fcb 0
                    fcc "S  Sprites"
                    fcb 0
                    fcc "A  Memory"
                    fcb 0
                    fcc "N  IRQ loopback"
                    fcb 0
                    fcc "L  Lines"
                    fcb 0
                    fcc "B  Bitmap"
                    fcb 0
                    fcc "E  Ethernet (W6100)"
                    fcb 0
                    fcc "T  Real-time clock"
                    fcb 0
                    fcc "W  WizFi360"
                    fcb 0
                    fcc "C  CPU speed"
                    fcb 0
                    fcc "P  PS/2 keyboard"
                    fcb 0
                    fcc "M  Mouse"
                    fcb 0
                    fcc "K  K2 keyboard"
                    fcb 0
                    emod
eom                 equ *
                    end
