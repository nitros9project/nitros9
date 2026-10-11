                    nam diag
                    ttl WildBits hardware diagnostics

                    ifp1
                    use defsfile
                    endc

                    mod eom,name,Prgrm+Objct,ReEnt+1,start,size

module              equ 0
TestCount           equ 26                  the tests' rows; their letters are in tests (re-lettered 2026-10-10)
* The test rows (2026-10-10, user: "automatic-capable first, then the manual-only modes"; "put RTC test after
* ethernet ... make cpu auto again"): a test's selection number is its row (TestRow0+n); its key is the first
* letter of its entry in tests. The Z run takes rows 0 to TestAuto-1: ... E, T, W, C.
* 2026-10-10 (user: "re-letter the tests so that W is WizFi, E is Ethernet, K is keyboard, P is PS/2 keyboard, M is
* mouse, D is DMA, F is FPU, I is Integer Math, C is CPU, B is bitmap, S is sprites, L is lines (performs both 320
* and 640)"; the rest by Roger's choice: G PSG, V SID, O OPL3, Y MIDI, A memory, N IRQ, T RTC):
*   C X I F G V O Y U S A N L B D H J E W T | P M K 1 2 3   (U PCM added 2026-10-10, H tile map 2026-10-11, J the K2 rc26
*   GPU stages 2026-10-16, user: "add a GPU test", in J's free letter; 2026-10-11, user:
*   "move cpu test to top, move dma test after bitmap", "i needed the order of the tests to follow suite": the Z
*   run takes the rows in order, so W comes before T - the RTC after both network tests that set it)
TestSpeed           equ 0                   C, at the top; its lines are the CPU speed table
TestMmu             equ 1                   X: the Level 2 block map, after C (2026-10-11)
TestMath            equ 2
TestFpu             equ 3
TestPsg             equ 4                   G, V, O and Y: the sound tests
TestMidi            equ 7
SoundTicks          equ 120                 a sound test's main-loop passes (one tick each): about 2 s
TestPcm             equ 8                   U, after the sound tests
* TestSpeech        equ 9                   J: the K2 rc26 core's SP0250 speech - commented out with its row, data and code
*                                            (2026-10-12, user: "comment out the J test and don't allow it's key to invoke the test")
TestSprites         equ 9
TestLines           equ 12                  L: running while its lines are shown
TestBitmap          equ 13                  B: running while the logo is shown
TestDma             equ 14                  D: running while its picture is shown
TestTiles           equ 15                  H: running while tile map 0 scrolls (2026-10-11, user: "factor in tltest")
TestGpu             equ 16                  J: the GPU stages; with stage 3, running while its cube turns (2026-10-16)
TestEther           equ 17                  E
TestWiFi            equ 18                  W (2026-10-10, user: "add WizFi test")
TestRtc             equ 19                  T, after both network tests
WfLines             equ 6                   W's result lines; the module's own lines are logged below them
WfLineMax           equ 74                  a received line's longest (columns 3-76)
TestAuto            equ 20                  rows 0-19 run in the Z run
TestRow0            equ 4                   the first test's row, right under the headings; the rest stacked below it
NoBar               equ $FF                 barsel: no row has the bar
TestNameW           equ 20                  a test row's fields: the name after its key (columns 3-22),
TestStateW          equ 9                   and the result (23-31), up to the divider
TestStateCol        equ 3+TestNameW
TestPS2             equ 20                  P, M and K: the keyboard and mouse tests
TestMouse           equ 21
TestK2Keys          equ 22
TestFlash           equ 23                  1, 2 and 3: onboard flash, cartridge flash and RAM (2026-10-11); manual
TestCartF           equ 24                  only - they write flash, so the Z run leaves them out
TestCartR           equ 25
AutoLoops           equ 150                 Z run: main-loop passes (2-tick naps) a live test runs, about 5 s
GfxSecs             equ 6                   S, B, L, D and H stop themselves when the OS clock has moved this many seconds
*                                            on from the picture's first pass: at least 5 s shown (2026-10-12, user: "make
*                                            it all 5 seconds rather than 4") (2026-10-11, user: "the bitmap test should end after 4
*                                            seconds"; "need to show to *4* seconds, not 1 or 2" - a pass count ran too
*                                            fast); the Z run waits for them (gfxtest)
* Colors (2026-10-09, user: "make diag bg blue, text white, graphical framework like the photo has"): numbers in
* the core's default text palette (wildbits.d TXT_*), which diag loads itself (diagpal.inc) along with its own
* CP437 font (diagfont.inc, phoenixegafont) so the frame looks the same on any system; both restored at exit.
ColText             equ TXT_WHITE
ColBack             equ TXT_BLUE
ColKey              equ TXT_CYAN            key letters and headings, as Procomm's
ColBarFg            equ TXT_BLACK           the selected test's bar
ColBarBg            equ TXT_LTGRAY
ColBarFgG           equ TXT_YELLOW          the bar's text while graphics are under it (its background is not drawn then)
ColLegend           equ TXT_LTGRAY          the legend under the tests, a step brighter than ColNA (2026-10-11)
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
BoxTeeD             equ $CB                 the divider's joints: double down from the top,
BoxTeeU             equ $CA                 double up from the bottom,
BoxCross            equ $D7                 and double through the single title divider
* The frame (2026-10-10, user: "the right border should be at 79, not 78"): the screen's last column. Full screen
* (2026-10-11, user: "Enlarge Diag's frame to touch the bottom row, it needs to be totally full-screen, use the new
* line space for the live view port"): the bottom is row 59, the screen's last, and the key help and its divider
* moved down a row with it, so the live view gained one. The bottom row goes out through the console but for its
* last cell - the screen's last, which both vtios answer by scrolling the whole screen - and that one cell is
* written into text and color memory (framecorner). It is drawn only while diag's terminal is on screen, and a
* Level 2 terminal switch carries the text planes with the terminal.
* Two columns (DIAG 1.2, 2026-10-11, user: "Left-side 50% column for the Key + test name + result, extending to the
* bottom of frame, no bottom frame with short-cut reminder, live view goes to right-side 50% page"; "shrink the left
* column to 40%"; "stack the test list without any extra line spacing"): a double divider at column ColDiv; the
* tests on its left, the live view on its right, both under the title divider.
ScreenCols          equ 80
FrameRight          equ ScreenCols-1
ScreenRows          equ 60
FrameBottom         equ 59                  the frame's bottom row, the screen's last
ColDiv              equ 32                  the double divider: the tests' column 1-31, the live view's 33-78
RowTitleDiv         equ 2                   the single divider under the titles
RowLegend           equ TestRow0+TestCount+1   PASS / LISTEN explained, below the tests
* The live view (2026-10-10, user: "do a CLS of the live view once, and don't cls again unless you're doing the line
* or bitmap tests"; "the view port should SCROLL itself ... do not scroll the frame"): rows ViewTop-ViewBot are a
* log. Each message is a new line; each test reserves its lines (vlines) below the last, and the rows scroll up
* inside the frame when it is full. vbase is the running test's first line. Text starts at ViewCol, one column in;
* a line holds ViewW characters (2026-10-11, user: "all the test output needs to be sized to look nice in its 60%
* column"), and message wraps a longer one.
ViewTop             equ RowTitleDiv+2
ViewBot             equ FrameBottom-1
ViewRows            equ ViewBot-ViewTop+1      the live view's rows
ViewL               equ ColDiv+1               its first column inside the borders
ViewIn              equ FrameRight-ViewL       its columns inside the borders (ViewL to FrameRight-1)
ViewCol             equ ViewL+1                where its lines start
ViewW               equ FrameRight-ViewCol     a line's characters (ViewCol to FrameRight-1)
ChkValCol           equ ViewCol+12             a check line's value, after its label (chkline)
TickSleep           equ 2                   F$Sleep X=2 sleeps one tick; X=1 only yields (fsleep.asm counts down first)
MmLines             equ 21                  X: a blank line, the column offsets, 16 map rows, a blank line, the legend, the counts
DmaSteps            equ 13                  the DMA test's transfer lines (dmasteptab)
DmaPrevOff          equ DmaSteps+1          its preview of the destination, below them
MouseGridOff        equ 2                   the mouse grid's first line
MouseLines          equ 32                  its label, a blank line and 30 grid lines
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
ps2hw               rmb 1                   P on the K2: the PS/2 port's own FIFO is read (ps2poll)
ps2last             rmb 1                   its last byte
ps2count            rmb 1                   and the bytes read
dmaent              rmb 2                   D: the dmasteptab entry being run
dmadpar             rmb 1                   D: the destination's physical address, low byte (the 16-bit fill's lanes)
dmacc               rmb 1                   D: CC as dmalock found it
dmaspin             rmb 1                   D: dmago's outer poll count
dmahi               rmb 1                   D: a bitmap address, bits 23:16
dmatmp              rmb 2                   D: and bits 15:0
dmashow             rmb 1                   D: the picture is up (dmalive moves the box)
dsrow               rmb 1                   D: a fill's top row
dsw                 rmb 1                   D: its width
dsh                 rmb 1                   D: and height
dsx                 rmb 2                   D: the box's left pixel,
dsy                 rmb 2                   its top row
dsdx                rmb 1                   and its steps (signed)
dsdy                rmb 1
tlowned             rmb 1                   H: tile map 0 is diag's (restoretiles puts it back)
tlrow               rmb 1                   H: the row being built
tlblk               rmb 1                   H: pixraw's block
tloff               rmb 2                   H: and its offset in it
tlmcr               rmb 2                   H: the master control as found
tllay               rmb 1                   H: the layer register as found
tlx                 rmb 2                   H: the scroll
tly                 rmb 2
tlsave              rmb 16                  H, Level 1: tile map 0's 12 register bytes and tile set 0's 4, as found
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
msgw                rmb 1                   message: the width of the line being written
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
dhcprx              rmb 1                   datagrams received while waiting for the server (the failure line shows it)
dhcpsr              rmb 1                   socket 0's status when DHCP gave up, read before the close
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
vsk                 rmb 1                   vscroll: the lines to scroll
vsfill              rmb 1                   vsmove: the blank byte
vscol               rmb 1                   vscroll2: the column being compared,
vsfirst             rmb 1                   a row's first
vslast              rmb 1                   and last changed column,
vsold               rmb 2                   the row on the screen
vsnew               rmb 2                   and the row that replaces it (0: blank)
msgn                rmb 1                   message: its lines
fcmode              rmb 1                   1-3: 0 onboard flash, 1 cartridge flash, 2 cartridge RAM
fcchip              rmb 1                   the flash chip's first block ($40 onboard, $80 the cartridge)
fcblk               rmb 1                   the byte's block
fcoff               rmb 2                   and its offset in it
fckind              rmb 1                   the chip's command set: $FF K2 (SST39VF168x), 1 SST39VF0x0, 0 none
fcid                rmb 2                   the chip's ID
fcbyte              rmb 1                   the byte as found
fcwant              rmb 1                   the byte written, which the read-back must return
fcidx               rmb 2                   fprog: the sector byte being programmed
fcsave              rmb 1                   MMU_IO_CTRL as found (fenter)
fccc                rmb 1                   CC as found (fenter)
fcbad               rmb 1                   fprog: a byte that never verified
mmrow               rmb 1                   X: the map row being drawn
mmcol               rmb 1                   its cells left
mmused              rmb 1                   the counts: blocks in use,
mmmod               rmb 1                   holding modules,
mmfree              rmb 1                   free
mmnone              rmb 1                   and not RAM
mmdiag              rmb 1                   diag's own
* spleft            rmb 2                   J: frame bytes left to send (J commented out 2026-10-12)
* spouter           rmb 1                   J: Ready polls left, in 64K units
gfxleft             rmb 2                   S, B, L, D, H: the second (minutes x 60 + seconds) the picture went up; $FFFF not yet
overlay             rmb 1                   the master control's text-overlay bit as diag last set it (gfxmcrset)
vtlive              rmb 1                   Level 2: diag's terminal is on screen (SS.WSig notices, sigtrap)
shtop               rmb 1                   Level 2: the copy's physical row of view row 0 (a ring: shrow)
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
shtext              rmb ViewRows*ViewIn     the view's characters, row by row, columns ViewL to FrameRight-1
shattr              rmb ViewRows*ViewIn     their colors (foreground * 16 + background), right after
glyphsok            rmb 1                   Level 2: diag's frame characters are in (glyphsin)
rowbuf              rmb ViewIn*7+8          one view row with its color changes, for the redraw
                    rmb 512                 process stack, never mapped away
* J the GPU (2026-10-16)
gpuowned            rmb 1                   the GPU is on layer 0: gpurestore puts the display back
gpulay              rmb 1                   layer control 0 as found
gpuswap             rmb 1                   SWAP_COUNT when the last frame went
gpuax               rmb 1                   the cube's angles (256 a turn)
gpuay               rmb 1
gpufrm              rmb 2                   frames sent
gpuid               rmb 1                   the readings: GPU_ID, STATUS after RESET, FIFO_FREE, registers wrong,
gpust               rmb 1                   FENCE_COUNT before and after, STATUS then, the SceneEngine's and the
gpufree             rmb 2                   point pipeline's status
gpubad              rmb 1
gpuf0               rmb 1
gpuf1               rmb 1
gpust2              rmb 1
gpuse               rmb 1
gpupp               rmb 1
gpui                rmb 1                   gpupoints: the point, its coordinates, the turned ones, k, sines
gpux                rmb 1
gpuy                rmb 1
gpuz                rmb 1
gpux1               rmb 1
gpuz1               rmb 1
gpuy2               rmb 1
gpuk                rmb 1
gpusx               rmb 1
gpucx               rmb 1
gpusy               rmb 1
gpucy               rmb 1
gput                rmb 2
gpuv                rmb 32                  the 8 points: X16, Y16 (1/16 dot and row)
size                equ .
name                fcs /Diag/
                    fcb 2                   edition 2 = DIAG 1.2 (2026-10-11, user: "build it for 1.2"; 1.1 2026-10-10)
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
* Level 2 (2026-10-11, user: "a scroll should move memory, not repaint it"; "you seem to know when"): vtio signals
* diag when its terminal goes background or comes forward (SS.WSig; the switch and the signal both come from
* vtio's IRQ path, and the kernel delivers the signal before diag runs on). While it is on screen, diag moves the
* screen's memory itself. diag starts on screen - it runs in the terminal it was typed in. Without the notices it
* never writes the screen's memory.
                    lda #1
                    sta vtlive,u
                    lda #1
                    ldb #SS.WSig
                    ldx #S$WinBg*256+S$WinFg
                    os9 I$SetStt
                    bcc mt_lv1
                    clr vtlive,u
mt_lv1              lbsr setpalette
* initseq holds zero bytes (the window's X and Y), so it goes out by its length, never through putz (2026-10-10:
* putz stopped at the first zero and DWSet took the next writes as its parameters - the cyan first screen)
                    leax initseq,pcr
                    ldy #initlen
                    lbsr conwrite
                    lbsr markna             this machine's N/A tests grayed out and disabled from the start (2026-10-10)
                    lbsr drawpage
                    lbsr banner             the Wildbits name in the live view (2026-10-12)
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
                    lbcs nap
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
                    cmpa #'0                a digit is a key as it is (2026-10-11: tests 1-3)
                    blo kc_up
                    cmpa #'9
                    bls kc_dig
kc_up               anda #$DF
                    cmpa #'R'
                    beq resetpanel
                    cmpa #'Z'               Z: the automatic run (2026-10-10)
                    lbeq autokey
kc_dig              equ *
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
                    lbsr gfxtest            S, B, L, D and H stop themselves after 4 s: the run waits for them
                    beq as9@                (2026-10-11, user: AutoLoops had cut them at about 2.5 s)
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
* autolist: the Z run's order - the rows exactly as listed (2026-10-11, user: "i needed the order of the tests to
* follow suite"). T (the RTC) is listed after both network tests, E (Ethernet, K2) and W (WizFi), which set the
* clock (2026-10-10, user: "rtc should come after either network device"). TestAuto entries.
autolist            fcb 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
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
                    tst lvl2,u              the visibility notices released
                    beq mt_cx1
                    lda #1
                    ldb #SS.WSig
                    ldx #0
                    os9 I$SetStt
mt_cx1              clr >FPMATH_CTRL2
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
* screen, a double divider between the tests and the live view (ColDiv), a single one under the titles
* (RowTitleDiv); headings and key letters in ColKey, the rest ColText on ColBack, and the selected test's row as a
* bar (ColBarFg on ColBarBg) once a test has been chosen.
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
                    lda #FrameBottom
                    sta row,u
                    leax framebot,pcr
                    ldb #ScreenCols-1       all but the screen's last cell: writing it would scroll the screen
                    lbsr hline
                    lbsr framecorner        that cell straight into text and color memory
                    lda #1
                    sta row,u
vertical            lda row,u
                    cmpa #RowTitleDiv
                    beq vnext
                    clrb
                    lbsr at
                    lda #BoxV2
                    lbsr putchar
                    lda row,u
                    ldb #ColDiv
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
                    lbsr machname
                    lbra drawtests
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
                    tstb
                    beq do3@
do1@                tst ,x+                 past one name
                    bne do1@
                    decb
                    bne do1@
do3@                lbra drawtest
* clearrow: A = a live-view row, blanked from ViewCol to the frame; the cursor left at ViewCol. Keeps A, X.
clearrow            pshs a,b,x
                    ldb #ViewCol
                    lbsr at
                    ldb #ViewW
                    lda #' '
clearrow1           lbsr putchar
                    decb
                    bne clearrow1
                    lda ,s
                    ldb #ViewCol
                    lbsr at
                    puls a,b,x,pc
* drawtest: X = the test's name ("K  Name"); row/col = its row and number. Returns X past it.
* The row is written once, left to right, every field padded with spaces to the next (2026-10-10, user: "why is
* the test list being redrawn with clears, there's a pass that's visible"): no blanking pass, so nothing flickers.
drawtest            pshs x
                    lbsr testcolors          the row's colors: the bar, or the page
                    lda row,u
                    ldb #1
                    lbsr at
                    lda #' '                 column 1; the key in column 2
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
* vtio also colors the cell after the one it writes, so the last field's end (column ColDiv-1) turned the divider
* cell to the row's colors: the divider cell is written again in the page colors
                    lda #ColText
                    ldb #ColBack
                    lbsr setcolors
                    lda row,u
                    ldb #ColDiv
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
                    tst overlay,u           graphics under the text: the bar's background is not drawn, its text bright
                    beq tc3@
                    lda #ColBarFgG
tc3@                ldb #ColBarBg
tc1@                lbra setcolors
* barredraw: the bar's row drawn again (gfxmcrset, when the text overlay changes). Keeps row and col.
barredraw           tst hilite,u
                    beq brd_9
                    lda barsel,u
                    cmpa #NoBar
                    beq brd_9
                    ldd row,u
                    pshs d
                    lda barsel,u
                    lbsr drawone
                    puls d
                    std row,u
brd_9               rts
* testna: Z set when test col is N/A on this machine. Keeps D, X and Y.
testna              pshs d,x
                    leax status,u
                    ldb col,u
                    lda b,x
                    cmpa #StateNA
                    puls d,x,pc
* framecorner: the frame's bottom-right cell - the screen's last - written into text and color memory: the console
* scrolls the whole screen when that cell is written (both vtios). Keeps D and X.
framecorner         pshs cc,d,x
                    orcc #IntMasks          Level 2: only while diag's terminal is on screen (checked with IRQs
                    tst lvl2,u              masked: a switch comes from an IRQ)
                    beq fc_1
                    tst vtlive,u
                    beq fc_9
fc_1                lda #TEXT_RAM_BLK
                    lbsr mapio
                    lda #BoxBR
                    sta FrameBottom*ScreenCols+FrameRight,x
                    lbsr unmap
                    lda #COLOR_RAM_BLK
                    lbsr mapio
                    lda #ColText*16+ColBack
                    sta FrameBottom*ScreenCols+FrameRight,x
                    lbsr unmap
fc_9                puls cc,d,x,pc
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
* hline: X = four characters (left, fill, the divider's joint, right) for row row,u from column 0 to FrameRight;
* B = the cells written (ScreenCols)
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
                    lda 3,x
                    sta ,y
                    lda 2,x                 the joint at the divider
                    sta linebuf+ColDiv,u
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
                    suba #ViewL
                    cmpa #ViewIn
                    bhs mt_trn
                    pshs a                  the column
                    tfr b,a
                    lbsr shrow
                    ldb ,s+
                    abx
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
                    clr shtop,u
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
* shrow: A = a view row (0 to ViewRows-1) -> X = its characters in the copy, its colors ViewRows*ViewIn on. The
* copy is a ring (2026-10-11): shtop is the physical row of view row 0, so a scroll moves no bytes. Keeps D, Y.
shrow               pshs d
                    adda shtop,u
                    cmpa #ViewRows
                    blo shr_1
                    suba #ViewRows
shr_1               ldb #ViewIn
                    mul
                    leax shtext,u
                    leax d,x
                    puls d,pc
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
* message: X = a line for the live view, added below the last (the view scrolls when full). A line longer than
* the view is wrapped at its last space that fits (2026-10-11, DIAG 1.2): the rest on the next lines, two columns
* in. The lines are counted first and reserved together, so the view scrolls once for the whole message. Returns
* X past the string and A = the last line's row; keeps B and Y.
message             pshs b,y
                    pshs x                  the start, for the second pass
                    clr msgn,u
                    lda #ViewW
                    sta msgw,u
msg_1               inc msgn,u              the first pass counts the lines
                    lbsr msgcut
                    tfr y,x
                    lda #ViewW-2
                    sta msgw,u
                    tst ,x
                    bne msg_1
                    lda msgn,u
                    lbsr vreserve           A = the first line's row
                    puls x
                    ldb #ViewW
                    stb msgw,u
msg_2               lbsr clearrow           the second writes them
                    ldb msgw,u
                    cmpb #ViewW
                    beq msg_3
                    pshs x
                    leax msgindent,pcr      a continued line
                    lbsr putz
                    puls x
msg_3               lbsr msgcut             B = its characters, Y = the next line's start
                    pshs a,y
                    clra
                    tfr d,y
                    lbsr conwrite
                    puls a,y
                    tfr y,x
                    ldb #ViewW-2
                    stb msgw,u
                    inca
                    tst ,x
                    bne msg_2
                    leax 1,x                past the terminator
                    deca                    the last line's row
                    puls b,y,pc
* msgcut: X = the rest of a message, msgw = the line's width -> B = the characters on this line (all of the rest
* when it fits, else up to the last space that fits, else the width) and Y = the next line's start, the spaces at
* the break skipped (the terminator when this is the last line). Keeps A and X.
msgcut              pshs a
                    clrb                    the rest's length, up to the width + 1
mc_1                tst b,x
                    beq mc_4
                    incb
                    cmpb msgw,u
                    bls mc_1
                    ldb msgw,u              too long: the last space at or before the width
mc_2                lda b,x
                    cmpa #' '
                    beq mc_4
                    decb
                    bne mc_2
                    ldb msgw,u              no space: cut at the width
mc_4                leay b,x
mc_5                lda ,y
                    cmpa #' '
                    bne mc_6
                    leay 1,y
                    bra mc_5
mc_6                puls a,pc
* vreserve: A = lines wanted -> A = the first of them, below the last line used. The view scrolls up as needed,
* all the lines in one go (vscroll A = the count).
vreserve            pshs a
                    lda viewnext,u
                    adda ,s
                    suba #ViewBot+1         the lines past the bottom
                    bls vr2@
                    pshs a
                    lda viewnext,u          no more than the view holds; a longer request starts at its top
                    suba #ViewTop
                    cmpa ,s
                    bhs vr1@
                    sta ,s
vr1@                puls a
                    tsta
                    beq vr2@
                    lbsr vscroll
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
* vscroll: A = lines (1 to ViewRows): the view scrolls up that many, only inside its borders (2026-10-10, user:
* "console delete-line should not be used inside a view port smaller than the screen", "you will SCROLL THE VIEW
* PORT but not outside of it's border lines"). Neither console scrolls part of the screen (vtio's scroll and delete
* line always take the full width), so diag moves the cells itself. vnext and vbase follow.
* Level 1 (2026-10-11, user: "the view port scrolling is terribly slow", "use some spaghetti code for the scroll"):
* straight in text and color memory - one mapping per page, the rows moved by an unrolled copy (vsmove), the
* borders, the tests' column and every row outside the view never written.
* Level 2 does the same while diag's terminal is on screen (vtlive), checked and moved with IRQs masked so no
* switch can come between; its copy of the view then turns its ring (shtop) and blanks the freed rows - no bytes
* moved. In the background the screen's memory is another terminal's, so the view is redrawn through the console
* into diag's own buffer instead (vscroll2).
vscroll             pshs a,b,x,y
                    sta vsk,u
                    tst lvl2,u
                    beq vs_l1
                    pshs cc
                    orcc #IntMasks
                    tst vtlive,u
                    bne vs_l2
                    puls cc
                    lbra vscroll2
vs_l2               bsr vspages
                    puls cc
                    lda shtop,u             the copy's ring turned
                    adda vsk,u
                    cmpa #ViewRows
                    blo vs_r1
                    suba #ViewRows
vs_r1               sta shtop,u
                    lda #ViewRows           and the freed rows blanked
                    suba vsk,u
vs_r2               lbsr shrow
                    ldy #ViewIn
                    pshs a
                    ldd #' '*256+ColText*16+ColBack
vs_r3               sta ,x
                    stb ViewRows*ViewIn,x
                    leax 1,x
                    leay -1,y
                    bne vs_r3
                    puls a
                    inca
                    cmpa #ViewRows
                    blo vs_r2
                    bra vsdone
vs_l1               bsr vspages
vsdone              lda viewnext,u
                    suba vsk,u
                    sta viewnext,u
                    lda vbase,u
                    suba vsk,u
                    sta vbase,u
                    puls a,b,x,y,pc
* vspages: the text page, then the color page (vsmove)
vspages             lda #TEXT_RAM_BLK
                    ldb #' '
                    lbsr vsmove
                    lda #COLOR_RAM_BLK
                    ldb #ColText*16+ColBack
                    lbra vsmove
* vsmove: A = the page (text or color), B = the blank byte: the view's rows moved up vsk rows in it, columns ViewL
* to FrameRight-1 (ViewIn, an even count: two cells a move), and the vsk rows freed at the bottom set to B. IRQs
* are masked for the page (mapio): about 1 ms at 20 Mhz.
vsmove              stb vsfill,u
                    lbsr mapio              X = the page
                    leax ViewTop*ScreenCols+ViewL,x
                    lda vsk,u
                    ldb #ScreenCols
                    mul
                    leay d,x                Y = the row vsk below
                    lda #ViewRows
                    suba vsk,u              the rows moved
                    beq vsm3@
                    sta vsrow,u
vsm1@               equ *
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    ldd ,y++
                    std ,x++
                    leax ScreenCols-ViewIn,x
                    leay ScreenCols-ViewIn,y
                    dec vsrow,u
                    lbne vsm1@
vsm3@               lda vsk,u               the freed rows
                    sta vsrow,u
                    lda vsfill,u
                    tfr a,b
vsm4@               equ *
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    std ,x++
                    leax ScreenCols-ViewIn,x
                    dec vsrow,u
                    bne vsm4@
                    lbra unmap
* vscroll2 (2026-10-11, multiterminal): Level 2 writes no text or color memory - the terminal may be in the
* background, and then that memory is another terminal's screen - so the view is redrawn through the console from
* its own copy (shtext/shattr, kept by track from everything diag sends). Only what changes is sent (2026-10-11,
* user: "terribly slow"): row r becomes row r+vsk (blank past the copy); each row's first and last differing cells
* are found and just that span is written, a color escape only where the colors change. The rows go top down and
* track puts each written span into the copy, so the copy is scrolled by the redraw itself - nothing is moved.
* The colors in force are put back after.
vscroll2            lda tfg,u               the colors in force
                    ldb tbg,u
                    pshs d
                    lsla
                    lsla
                    lsla
                    lsla
                    ora tbg,u
                    sta rattr,u             the console's colors as the spans are built
                    clr vsrow,u
vs2_r               lda vsrow,u             vsold = row r (on the screen), vsnew = row r+vsk or 0 (blank)
                    lbsr shrow
                    stx vsold,u
                    ldx #0
                    adda vsk,u
                    cmpa #ViewRows
                    bhs vs2_n
                    lbsr shrow
vs2_n               stx vsnew,u
                    clr vscol,u             the first difference
vs2_f               lbsr vs2cell
                    bne vs2_g
                    inc vscol,u
                    lda vscol,u
                    cmpa #ViewIn
                    blo vs2_f
                    lbra vs2_x              the row does not change
vs2_g               lda vscol,u
                    sta vsfirst,u
                    lda #ViewIn-1           the last difference
                    sta vscol,u
vs2_h               lbsr vs2cell
                    bne vs2_i
                    dec vscol,u
                    bra vs2_h
vs2_i               lda vscol,u
                    sta vslast,u
                    lda vsrow,u
                    adda #ViewTop
                    ldb vsfirst,u
                    addb #ViewL
                    lbsr at
                    leay rowbuf,u
                    lda vsfirst,u
                    sta vscol,u
vs2_j               lbsr vs2cell            A = the character, B = its colors
                    cmpb rattr,u
                    beq vs2_k
                    stb rattr,u
                    pshs a
                    lda #VT_ESC
                    sta ,y+
                    lda #VT_FCOLOR
                    sta ,y+
                    tfr b,a
                    lsra
                    lsra
                    lsra
                    lsra
                    sta ,y+
                    lda #VT_ESC
                    sta ,y+
                    lda #VT_BCOLOR
                    sta ,y+
                    andb #$0F
                    stb ,y+
                    puls a
vs2_k               sta ,y+
                    lda vscol,u
                    inc vscol,u
                    cmpa vslast,u
                    blo vs2_j
                    tfr y,d                 the span out in one write
                    leax rowbuf,u
                    pshs x
                    subd ,s++
                    tfr d,y
                    lbsr conwrite
vs2_x               inc vsrow,u
                    lda vsrow,u
                    cmpa #ViewRows
                    lblo vs2_r
                    puls d
                    lbsr setcolors
                    lbra vsdone
* vs2cell: vscol = a column -> A = the new character there, B = its colors; Z set when the screen (vsold) already
* holds them
vs2cell             pshs x
                    ldb vscol,u
                    ldx vsnew,u
                    beq vc_1
                    abx
                    lda ,x
                    ldb ViewRows*ViewIn,x
                    bra vc_2
vc_1                lda #' '
                    ldb #ColText*16+ColBack
vc_2                ldx vsold,u
                    pshs b
                    ldb vscol,u
                    abx
                    puls b
                    cmpa ,x
                    bne vc_3
                    cmpb ViewRows*ViewIn,x
vc_3                puls x,pc
* sigtrap: the signal intercept (F$Icpt): B = the signal, U = the data area; noted for the main loop
sigtrap             cmpb #S$WinBg           diag's terminal went background: the screen's memory is not its own
                    bne st_1
                    clr vtlive,u
                    rti
st_1                cmpb #S$WinFg           it came forward
                    bne st_2
                    lda #1
                    sta vtlive,u
                    rti
st_2                stb sigcode,u
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
                    ldb #TestStateCol
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
                    ldd #$FFFF              the graphics tests' clock: not started until the picture is up
                    std gfxleft,u
                    leax dispatch,pcr
                    ldb selection,u
                    lslb
                    ldd b,x
                    jmp d,x
* nowsecs: D = the OS clock's minutes x 60 + seconds (F$Time). Keeps X and Y.
nowsecs             pshs x
                    leax ostime,u
                    os9 F$Time
                    lda ostime+4,u          minutes
                    ldb #60
                    mul
                    addb ostime+5,u
                    adca #0
                    puls x,pc
* gfxtest: Z set when the selection is one of the timed graphics tests (S, B, L, D, H). Keeps every register but CC.
gfxtest             pshs b
                    ldb selection,u
                    cmpb #TestSprites
                    beq gt_9
                    cmpb #TestBitmap
                    beq gt_9
                    cmpb #TestLines
                    beq gt_9
                    cmpb #TestDma
                    beq gt_9
                    cmpb #TestGpu
                    beq gt_9
                    cmpb #TestTiles
gt_9                puls b,pc
livetick            lbsr gfxtest            S, B, L, D and H: their picture comes down after GfxSecs on the OS clock
                    bne lt_go
lt_gfx              ldd gfxleft,u           the first pass with the picture up starts the clock - the
                    cmpd #$FFFF             same for a key and for the Z run (2026-10-12, user: "it should be
                    bne lt_g0               the same whether z runs it or it's a manual run")
                    lbsr nowsecs
                    std gfxleft,u
                    bra lt_go
lt_g0               lbsr nowsecs            seconds since the picture went up (within the hour)
                    subd gfxleft,u
                    bpl lt_g1
                    addd #3600
lt_g1               cmpd #GfxSecs
                    blo lt_go
                    lbsr stopsound
                    lbsr restoresprite
                    lbsr restoregraphics
                    clr running,u
                    rts
lt_go               ldd samples,u
                    addd #1
                    std samples,u
                    ldb selection,u
                    cmpb #TestDma           D moves its box (2026-10-11)
                    lbeq dmalive
                    cmpb #TestGpu           J turns its cube
                    lbeq gpulive
                    cmpb #TestTiles         H scrolls its map
                    lbeq tilelive
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
* vlines: each test's lines in the live view, by selection (C X I F G V O Y U S A N L B D H E W T P M K 1 2 3)
vlines              fcb 8,MmLines,3,1,1,1,1,1,1,0,0,5,1,0,DmaPrevOff+4,1,GpuLines,13,WfLines,4,1,MouseLines,1,3,3,3
nowindowmsg         fcc "diag: no free 8K slot to map hardware blocks through"
                    fcb C$CR,C$LF,0
nocontigmsg         fcc "diag: the 8K scratch buffer is not physically contiguous"
                    fcb C$CR,C$LF,0
enginebusy          fcc "Engine still owns scratch memory: wait/reset."
                    fcb 0
autodone            fcc "Z run done. Tests failed: "
                    fcb 0
autostopped         fcc "Z run stopped."
                    fcb 0
frametop            fcb BoxTL,BoxH2,BoxTeeD,BoxTR
framemid            fcb BoxTeeL,BoxH1,BoxCross,BoxTeeR
framebot            fcb BoxBL,BoxH2,BoxTeeU,BoxBR
msgindent           fcc "  "
                    fcb 0
MachCol             equ 2+17                after "WILDBITS DIAG 1.2"
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
machunknown         fcc "ID $"
                    fcb 0
headings            fcb 1,2
                    fcb VT_ESC,VT_FCOLOR,ColKey     the whole title in the key color (2026-10-10, user)
                    fcc "WILDBITS DIAG 1.3"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcb 0,1,ViewCol
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "LIVE VIEW"
                    fcb VT_ESC,VT_FCOLOR,ColText
                    fcb 0,RowTitleDiv+1,2
                    fcb VT_ESC,VT_FCOLOR,ColKey
                    fcc "TEST"
                    fcb 0,RowTitleDiv+1,TestStateCol
                    fcc "RESULT"
                    fcb VT_ESC,VT_FCOLOR,ColLegend,0,RowLegend,2
                    fcc "PASS=readback LISTEN=by ear"
                    fcb 0,RowLegend+1,2     (2026-10-11, user: "add RUN/STOP/ESC/Q underneath", "a little brighter")
                    fcc "RUN/STOP/ESC/Q"
                    fcb VT_ESC,VT_FCOLOR,ColText,0,$FF
tests               fcc "C  CPU speed"
                    fcb 0
                    fcc "X  MMU map"
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
*                   fcc "J  SP0250 speech"      commented out (2026-10-12): no row, so no J key
*                   fcb 0
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
                    fcc "D  DMA"
                    fcb 0
                    fcc "H  Tile map"
                    fcb 0
                    fcc "J  GPU"
                    fcb 0
                    fcc "E  Ethernet (W6100)"
                    fcb 0
                    fcc "W  WizFi360"
                    fcb 0
                    fcc "T  Real-time clock"
                    fcb 0
                    fcc "P  PS/2 keyboard"
                    fcb 0
                    fcc "M  Mouse"
                    fcb 0
                    fcc "K  K2 keyboard"
                    fcb 0
                    fcc "1  Onboard flash"
                    fcb 0
                    fcc "2  Cart flash"
                    fcb 0
                    fcc "3  Cart RAM"
                    fcb 0
                    emod
eom                 equ *
                    end
