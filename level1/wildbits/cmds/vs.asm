********************************************************************
* vs - vs1053b music chip controller
* by Roger Taylor
*
* use vs -?  for help
*
* Jr2 note: one PCB run tied the chip's GPIO1 (pin 34) to VCC, so the chip
* booted as a real-time MIDI synthesizer and decoded nothing. While a fix
* exists requiring modification of the PCB (bridge chip pins 33-34), the
* preferred fix is to have this command install a software patch that forces
* the chip into decoder mode when it detects that GPIO1 is tied to VCC.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* ------------------------------------------------------------------
*   10      2026/09/07  Roger Taylor
*           First release. Tested on the K2 and Jr2 core (V8_RC12)
*   11      2026/09/07  module edition 11: DefClk (the -c default) scanned the
*           file name with X and left it there, so -s without -c wrote
*           CLOCKF into the parameter area instead of the bridge: the name
*           was overwritten (I$Open error 216) and the chip kept 1.0x.
*           DefClk now preserves X.
*   3      2026/09/07  module edition 12: the -s clock by file type (ClkTab:
*           mp3 ogg wav $60, aac wma m4a mp4 $70, mid $A0, else $60); -c
*           still overrides. C0 (4.5x, the CLKI limit) cut an MP3 short.
*

                    nam       vs
                    ttl       VS1053 Controller-Player

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       12

                    mod       eom,name,tylg,atrv,start,size

FIFOSIZE            equ       2048                bridge SDI FIFO depth
BURST               equ       255                 bytes written per room check
BUFSIZE             equ       1024                file read buffer

                    org       0
secs                rmb       2                   seconds per tone
ticks               rmb       2                   secs x 60
tmp                 rmb       2
exp                 rmb       2                   expected readback
pptr                rmb       2                   plugin pointer
pcnt                rmb       2                   plugin words left
rcnt                rmb       2                   run length
fname               rmb       2                   -s: pathname pointer
bcount              rmb       2                   -s: bytes left in the buffer
bytes               rmb       2                   -s: bytes sent modulo 1024
kb                  rmb       2                   -s: KB sent
step                rmb       1                   step in progress, as an ASCII digit/letter
path                rmb       1                   output path for the Put* helpers
mode                rmb       1                   0 chain, 1 -t sine, 2 -s stream, 3 -m memtest, 4 -? help, 5 -r reset, 6 -i info, 7 -l load, 8 -u dump, 9 -n synth on, 10 -o synth off
daddr               rmb       2                   -u: first instruction address
dcnt                rmb       2                   -u: words to dump
first               rmb       1                   -s: first buffer seen
fpath               rmb       1                   -s: file path number
stallt              rmb       2                   -s: ticks without the chip consuming a byte
lastcnt             rmb       2                   -s: FIFO count at the last look ($FFFF = unknown)
keyhit              rmb       1                   -s: a key ended the stream
noted               rmb       1                   -s: the 30 s notice was printed
fillb               rmb       1                   -s: the chip's endFillByte
ccnt                rmb       1                   -s: SM_CANCEL tries left
bg                  rmb       1                   1 = -b: never touch the terminal
sigflag             rmb       1                   a signal arrived (intercept)
share               rmb       1                   1 = -x: MODE base $0C00 (SM_SDISHARE) instead of $0800
dbg                 rmb       1                   1 = -d: the -s readouts (file, format, KB, DECODE_TIME, end status)
quiet               rmb       1                   1 = drop stdout (-s without -d); stderr always goes out
long                rmb       1                   1 = -s end sequence: SCI waits up to 60 s and a key ends them
vol                 rmb       1                   VOL attenuation, 0.5 dB steps, both channels
volset              rmb       1                   1 = -v given
clk                 rmb       1                   -s: CLOCKF high byte
clkset              rmb       1                   1 = -c given
gbuf                rmb       1                   1 = -g: STATUS $0440 (VCM buffer off) instead of $0040
hexbuf              rmb       8
rbuf                rmb       BUFSIZE             -s: file read buffer
stack               rmb       256                 room for the system calls
size                equ       .

name                fcs       "vs"
                    fcb       edition

lb1                 fcc       "STATUS            "
lb1l                equ       *-lb1
nt1                 fcc       "  ($0048 = VS1053b, drivers off)"
nt1l                equ       *-nt1
lb2                 fcc       "STATUS  <- $0040  "
lb2l                equ       *-lb2
nt2                 fcc       "  analog drivers on"
nt2l                equ       *-nt2
lb3                 fcc       "VOL     <- "
lb3l                equ       *-lb3
nt3                 fcc       "  both channels"
nt3l                equ       *-nt3
lb4                 fcc       "AICTRL3 <- $A55A  "
lb4l                equ       *-lb4
nt4                 fcc       "  16-bit SCI echo"
nt4l                equ       *-nt4
lb5                 fcc       "SDI sine 1 kHz (data path): "
lb5l                equ       *-lb5
lb6                 fcc       "SCI sine L 440 Hz - R 880 Hz (no data path): "
lb6l                equ       *-lb6
lb7                 fcc       "CLOCKF  <- $A000  "
lb7l                equ       *-lb7
nt7                 fcc       "  4.0x = 49.2 MHz"
nt7l                equ       *-nt7
lb8                 fcc       "FAST read CLOCKF  "
lb8l                equ       *-lb8
nt8                 fcc       "  bridge FAST SPI"
nt8l                equ       *-nt8
lb9                 fcc       "RT-MIDI piano note (plugin + MIDI over SDI): "
lb9l                equ       *-lb9
lba                 fcc       "memory test HDAT0 "
lbal                equ       *-lba
nta                 fcc       "  (reset follows)"
ntal                equ       *-nta
lbs                 fcc       "streaming "
lbsl                equ       *-lbs
nts                 fcc       "  (any key stops)"
ntsl                equ       *-nts
lbk                 fcc       "stopped by key after "
lbkl                equ       *-lbk
lbsg                fcc       "stopped by signal after "
lbsgl               equ       *-lbsg
lbe                 fcc       "end of file after "
lbel                equ       *-lbe
kbmsg               fcc       " KB"
kbmsgl              equ       *-kbmsg
lbmh                fcc       "MIDI file: format "
lbmhl               equ       *-lbmh
lbmt                fcc       ", tracks "
lbmtl               equ       *-lbmt
ntm                 fcc       "  (chip plays format 0 only)"
ntml                equ       *-ntm
lbmf                fcc       "vs: MIDI format "
lbmfl               equ       *-lbmf
ntmf                fcc       ": the chip plays format 0 only"
ntmfl               equ       *-ntmf
lbdt                fcc       "decoded by the chip: "
lbdtl               equ       *-lbdt
ntdt                fcc       " s (DECODE_TIME)"
ntdtl               equ       *-ntdt
ntcok               fcc       "decoder finished cleanly (SM_CANCEL cleared)"
ntcokl              equ       *-ntcok
ntcx                fcc       "SM_CANCEL never cleared - software reset"
ntcxl               equ       *-ntcx
lbse                fcc       "STATUS at end = $"
lbsel               equ       *-lbse
ntov                fcc       "  VCM OVERLOAD (b11): GBUF loaded - try -g"
ntovl               equ       *-ntov
ntok                fcc       "  no VCM overload"
ntokl               equ       *-ntok
lbh                 fcc       "HDAT1 = $"
lbhl                equ       *-lbh
nth                 fcc       "  (0 = clean end; $FFEx while file plays)"
nthl                equ       *-nth
lbi0                fcc       "vs -i: the chip as found (no reset)"
lbi0l               equ       *-lbi0
lbi1                fcc       "STATUS       "
lbi1l               equ       *-lbi1
lbi2                fcc       "MODE         "
lbi2l               equ       *-lbi2
lbi3                fcc       "CLOCKF       "
lbi3l               equ       *-lbi3
lbi4                fcc       "AIADDR       "
lbi4l               equ       *-lbi4
lbi5                fcc       "HDAT0        "
lbi5l               equ       *-lbi5
lbi6                fcc       "HDAT1        "
lbi6l               equ       *-lbi6
lbi7                fcc       "DECODE_TIME  "
lbi7l               equ       *-lbi7
lbi8                fcc       "GPIO DDR   ($C017) "
lbi8l               equ       *-lbi8
lbi9                fcc       "GPIO IN    ($C018) "
lbi9l               equ       *-lbi9
nti9                fcc       "  GPIO1 = 1: RT-MIDI strap (synth) - vs -o or any reset switches it"
nti9l               equ       *-nti9
nti9n               fcc       "  GPIO1 = 0: normal boot (stream decoder)"
nti9nl              equ       *-nti9n
nti9s               fcc       "  GPIO0 = 1: SPI-boot strap, decoder (RT-MIDI cancelled)"
nti9sl              equ       *-nti9s
lbia                fcc       "GPIO OUT   ($C019) "
lbial               equ       *-lbia
lbib                fcc       "AUDATA       "
lbibl               equ       *-lbib
lbsw                fcc       "GPIO1 strap: switcher loaded, AUDATA "
lbswl               equ       *-lbsw
lbsn                fcc       "MIDI synth on: AUDATA "
lbsnl               equ       *-lbsn
lbso                fcc       "MIDI synth off: AUDATA "
lbsol               equ       *-lbso
ntdec               fcc       "  = stream decoder"
ntdecl              equ       *-ntdec
ntsyn               fcc       "  = real-time MIDI synth"
ntsynl              equ       *-ntsyn
errsw               fcc       "vs: the switcher failed - the chip is still a MIDI synth"
errswl              equ       *-errsw
erro                fcc       "vs: cannot open "
errol               equ       *-erro
erre                fcc       " (error #"
errel               equ       *-erre
errf                fcc       ")"
errfl               equ       *-errf
errr                fcc       "vs: read error"
errp                fcc       "vs: the plugin file ends inside a record"
errpl               equ       *-errp
errw                fcc       "vs: write error"
errwl               equ       *-errw
lbld                fcc       "loaded "
lbldl               equ       *-lbld
lbl2                fcc       ": "
lbl2l               equ       *-lbl2
lbl3                fcc       " words, "
lbl3l               equ       *-lbl3
lbl4                fcc       " SCI writes"
lbl4l               equ       *-lbl4
lbdu                fcc       "dumped "
lbdul               equ       *-lbdu
lbd2                fcc       " words from I:$"
lbd2l               equ       *-lbd2
lbd3                fcc       " into "
lbd3l               equ       *-lbd3
errrl               equ       *-errr
stl1                fcc       "no data in 30 s (after "
stl1l               equ       *-stl1
stl2                fcc       " KB; MIDI plays from its buffer)"
stl2l               equ       *-stl2
secmsg              fcc       " s"
secmsgl             equ       *-secmsg
sp2                 fcc       "  "
* -? help: one CR-terminated line each, none over 63 columns
HelpTxt             fcc       "vs - VS1053 sound chip player"
                    fcb       C$CR
                    fcc       "vs [seconds]    test chain: STATUS, MODE, analog on, VOL,"
                    fcb       C$CR
                    fcc       "                16-bit echo, SDI 1 kHz sine, SCI stereo sine,"
                    fcb       C$CR
                    fcc       "                CLOCKF 4.0x, FAST bridge read, RT-MIDI piano"
                    fcb       C$CR
                    fcc       "                note; N seconds per tone (default 5)"
                    fcb       C$CR
                    fcc       "vs -t [seconds] sine wave test only (steps 1-6 + SDI sine)"
                    fcb       C$CR
                    fcc       "vs -s <file>    play a file: mp3, ogg, wav, aac, wma, mid;"
                    fcb       C$CR
                    fcc       "                any key stops it; silent unless -d"
                    fcb       C$CR
                    fcc       "vs -m           memory self-test, then a hardware reset"
                    fcb       C$CR
                    fcc       "vs -v hh        volume: hex attenuation in 0.5 dB steps,"
                    fcb       C$CR
                    fcc       "                both channels: 00 = 0 dB, 10 = -8 dB, FE ="
                    fcb       C$CR
                    fcc       "                -127 dB; -s defaults to 00, the tests to 10"
                    fcb       C$CR
                    fcc       "vs -c hh        clock for -s: CLOCKF high byte, 60 = 3.0x, 80 = 3.5x,"
                    fcb       C$CR
                    fcc       "                A0 = 4.0x, C0 = 4.5x (the chip's limit); default by"
                    fcb       C$CR
                    fcc       "                file type: mp3 ogg wav 60, aac wma m4a 70, mid A0"
                    fcb       C$CR
                    fcc       "vs -g           GBUF buffer (VCM) off - try it if distorted"
                    fcb       C$CR
                    fcc       "vs -b           with -s and &: no key polling; kill <id> stops"
                    fcb       C$CR
                    fcc       "vs -x           shared chip select (SM_SDISHARE): no XDCS"
                    fcb       C$CR
                    fcc       "vs -d           with -s: report the file, MIDI format, KB sent,"
                    fcb       C$CR
                    fcc       "                DECODE_TIME and end status (else -s is silent)"
                    fcb       C$CR
                    fcc       "vs -r           hardware-reset the chip and show its STATUS"
                    fcb       C$CR
                    fcc       "vs -i           chip state, no reset: SCI regs, GPIO pins"
                    fcb       C$CR
                    fcc       "vs -l <file>    send a VLSI .plg (SYS/VSPLUGINS) to the chip"
                    fcb       C$CR
                    fcc       "                over SCI with no reset before or after"
                    fcb       C$CR
                    fcc       "vs -u aaaa nnnn <file>  dump nnnn instruction words (hex)"
                    fcb       C$CR
                    fcc       "                from I:aaaa (WRAM window) into <file>, no reset"
                    fcb       C$CR
                    fcc       "vs -n           MIDI synth on: VLSI's start plugin, no reset"
                    fcb       C$CR
                    fcc       "vs -o           MIDI synth off: the switcher, no reset; the"
                    fcb       C$CR
                    fcc       "                decoder stays even with the GPIO1 strap"
                    fcb       C$CR
                    fcc       "vs -?           this help"
                    fcb       C$CR
                    fcc       "Options combine: vs -v 08 -s /sd/song.mp3"
                    fcb       C$CR
                    fcc       "Every run resets the chip. Error 246 = chip stopped answering."
                    fcb       C$CR
                    fcc       "Plays format 0 MIDI files only."
                    fcb       C$CR
                    fcc       "GPIO1 strap (synth at boot)? vs loads the switcher after every reset."
                    fcb       C$CR
HelpEnd             equ       *
okmsg               fcc       "  OK"
okmsgl              equ       *-okmsg
badmsg              fcc       "  BAD (expect $"
badmsgl             equ       *-badmsg
rparen              fcc       ")"
msg3                fcc       "VS1053: no response at step "
msg3l               equ       *-msg3
msg4                fcc       ": CTRL=$"
lg1                 fcc       "steps 1 STATUS 2 MODE 3-4 STATUS 5-6 VOL 7-8 AICTRL3 9 sine-on"
                    fcb       C$CR
                    fcc       "A sine-exit B drain C SCI-sine D reset E-G MODE-STATUS-VOL"
                    fcb       C$CR
                    fcc       "H-I CLOCKF J FAST-read K plugin L MIDI M reset N MODE O memtest"
                    fcb       C$CR
                    fcc       "P HDAT0 Q reset S stream L load U dump W switcher Y synth Z decoder"
                    fcb       C$CR
lgend               equ       *
msg4l               equ       *-msg4
msg5                fcc       " FIFOSTAT=$"
msg5l               equ       *-msg5
msg6                fcc       " DATA=$"
msg6l               equ       *-msg6

* SDI test sequences
SineOn              fcb       $53,$EF,$6E,$44,$00,$00,$00,$00
SineOff             fcb       $45,$78,$69,$74,$00,$00,$00,$00
MemTest             fcb       $4D,$EA,$6D,$54,$00,$00,$00,$00
* MIDI (real-time mode): program change 0 (piano) + note on C4, then note off
MidiOn              fcb       $C0,$00,$90,$3C,$7F
MidiOnl             equ       *-MidiOn
MidiOff             fcb       $80,$3C,$00
MidiOffl            equ       *-MidiOff
* VLSI real-time MIDI start plugin for the VS1053b (28 words): records of
* SCI register, word count (bit 15 = run-length), values; ends by writing
* AIADDR = $0050, which starts the loaded code.
Plugin              fdb       $0007,$0001,$8050,$0006,$0014,$0030,$0715,$B080
                    fdb       $3400,$0007,$9255,$3D00,$0024,$0030,$0295,$6890
                    fdb       $3400,$0030,$0495,$3D00,$0024,$2908,$4D40,$0030
                    fdb       $0200,$000A,$0001,$0050
Plugin_end          equ       *
* The switcher (ed.10; wildbits-buildkit tools/mkswitcher.py, the same words as SYS/VSPLUGINS/
* switcher.plg): VLSI's patches-package restart prologue (IRAM $300-$31B of the loaded package,
* verbatim), then LE = $3FB7, LS = the stub, LC = 1 and j $3F84 with a fresh stack; the stub re-arms
* LC and jumps to $3FD5, past the ROM's real-time MIDI start. 80 words; AIADDR = $0050 runs it.
Switch              fdb       $0007,$0001,$8050,$0006,$0048,$0030,$0055,$B080
                    fdb       $1402,$0FDF,$FFC1,$0007,$9257,$B212,$3C00,$3D00
                    fdb       $4024,$0006,$0097,$3F10,$0024,$3F00,$0024,$0030
                    fdb       $0297,$3F00,$0024,$0007,$9017,$3F00,$0024,$0007
                    fdb       $81D7,$3F10,$0024,$C090,$3C00,$0006,$0297,$B080
                    fdb       $3C00,$0000,$0401,$000A,$1055,$0006,$0017,$3F10
                    fdb       $3401,$000A,$2795,$3F00,$3401,$0001,$6AD7,$F400
                    fdb       $55C0,$0000,$0817,$B080,$57C0,$000F,$EDCF,$0000
                    fdb       $1C4E,$0000,$004D,$280F,$E100,$0006,$2016,$0000
                    fdb       $004D,$280F,$F540,$0000,$0024,$000A,$0001,$0050
Switch_end          equ       *

* NOTE: branch targets that cross an os9 call are global on purpose - the
* os9 macro breaks @-local label scope in lwasm (same trap as keydrv_k2).
start               lbsr      GetArgs             switches and numbers from the parameter list
                    lda       #1
                    sta       path,u
                    tst       dbg,u               -s is silent unless -d asks for the readouts (errors always print)
                    bne       StartQ
                    lda       mode,u
                    cmpa      #2
                    bne       StartQ
                    inc       quiet,u
StartQ              lda       mode,u
                    cmpa      #4
                    lbeq      Help
                    cmpa      #6
                    lbeq      Info                -i looks, never touches: no reset
                    cmpa      #7
                    lbeq      LoadFile            -l: no reset either side, the chip keeps its state
                    cmpa      #8
                    lbeq      DumpRom             -u: read-only through the WRAM window, no reset
                    cmpa      #9
                    lbeq      SynthOn             -n: VLSI's start plugin on the chip as it is, no reset
                    cmpa      #10
                    lbeq      SynthOff            -o: the switcher on the chip as it is, no reset
                    lbsr      HardReset           every run starts from a freshly reset chip
                    lbsr      AutoSwitch          a GPIO1-strapped chip booted as a synth: switch it now
                    lbcs      NoResp
                    lbsr      DefVol              0 dB for -s, $10 for the tests, unless -v said
                    lda       mode,u
                    cmpa      #2
                    lbeq      Stream
                    cmpa      #3
                    lbeq      MemTst
                    cmpa      #5
                    lbeq      ResetOnly
* 1 STATUS as found
                    lda       #'1
                    sta       step,u
                    ldx       #VS1053.Base
                    lda       #VS_STATUS
                    lbsr      SCIRead
                    lbcs      NoResp
                    pshs      d
                    leax      lb1,pcr
                    ldy       #lb1l
                    lbsr      PutStr
                    puls      d
                    lbsr      PutDollar4
                    leax      nt1,pcr
                    ldy       #nt1l
                    lbsr      PutLine
* 2 MODE
                    lda       #'2
                    sta       step,u
                    ldx       #VS1053.Base
                    lda       #$20                SM_TESTS
                    lbsr      ModeY               Y = MODE base | flags
                    lda       #VS_MODE
                    lbsr      SCIWrite
                    lbcs      NoResp
* 3-4 STATUS = $0040 (analog drivers on; $0440 with -g) and read back
                    lda       #'3
                    sta       step,u
                    lbsr      StatOn
                    lbcs      NoResp
                    lda       #'4
                    sta       step,u
                    lda       #VS_STATUS
                    lbsr      SCIRead
                    lbcs      NoResp
                    pshs      d
                    leax      lb2,pcr
                    ldy       #lb2l
                    lbsr      PutStr
                    puls      d
                    lbsr      PutRes
                    leax      nt2,pcr
                    ldy       #nt2l
                    lbsr      PutLine
* 5-6 VOL and read back
                    lda       #'5
                    sta       step,u
                    lbsr      SetVol              VOL = vol,u on both channels; exp,u = the word
                    lbcs      NoResp
                    lda       #'6
                    sta       step,u
                    ldx       #VS1053.Base
                    lda       #VS_VOL
                    lbsr      SCIRead
                    lbcs      NoResp
                    pshs      d
                    leax      lb3,pcr
                    ldy       #lb3l
                    lbsr      PutStr
                    ldd       exp,u
                    lbsr      PutDollar4
                    leax      sp2,pcr
                    ldy       #2
                    lbsr      PutStr
                    puls      d
                    lbsr      PutRes
                    leax      nt3,pcr
                    ldy       #nt3l
                    lbsr      PutLine
                    tst       mode,u
                    lbne      Step9               -t: straight to the sine wave test
* 7-8 AICTRL3 echo
                    lda       #'7
                    sta       step,u
                    ldx       #VS1053.Base
                    lda       #VS_AICTRL3
                    ldy       #$A55A
                    lbsr      SCIWrite
                    lbcs      NoResp
                    lda       #'8
                    sta       step,u
                    ldd       #$A55A
                    std       exp,u
                    lda       #VS_AICTRL3
                    lbsr      SCIRead
                    lbcs      NoResp
                    pshs      d
                    leax      lb4,pcr
                    ldy       #lb4l
                    lbsr      PutStr
                    puls      d
                    lbsr      PutRes
                    leax      nt4,pcr
                    ldy       #nt4l
                    lbsr      PutLine
* 9 SDI sine on, tone, A exit, B drain
Step9               lda       #'9
                    sta       step,u
                    ldx       #VS1053.Base
                    leay      SineOn,pcr
                    lbsr      SendSeq
                    lbcs      NoResp
                    leax      lb5,pcr
                    ldy       #lb5l
                    lbsr      PutSecs
                    ldx       ticks,u
                    os9       F$Sleep
                    lda       #'A
                    sta       step,u
                    ldx       #VS1053.Base
                    leay      SineOff,pcr
                    lbsr      SendSeq
                    lbcs      NoResp
                    lda       #'B
                    sta       step,u
                    lbsr      WaitEmpty
                    lbcs      NoResp
                    tst       mode,u
                    lbne      ToneDone            -t: tests off and out
* C SCI-only stereo sine
                    lda       #'C
                    sta       step,u
                    lda       #VS_AUDATA
                    ldy       #$BB81              48000 Hz, stereo
                    lbsr      SCIWrite
                    lbcs      NoResp
                    lda       #VS_AICTRL0
                    ldy       #$0259              440 Hz x 65536 / 48000, left
                    lbsr      SCIWrite
                    lbcs      NoResp
                    lda       #VS_AICTRL1
                    ldy       #$04B1              880 Hz, right
                    lbsr      SCIWrite
                    lbcs      NoResp
                    lda       #VS_AIADDR
                    ldy       #$4020              start the sine generator
                    lbsr      SCIWrite
                    lbcs      NoResp
                    leax      lb6,pcr
                    ldy       #lb6l
                    lbsr      PutSecs
                    ldx       ticks,u
                    os9       F$Sleep
* D software reset, E-G back up (tests off, drivers on, volume)
                    lda       #'D
                    sta       step,u
                    lbsr      SoftReset
                    lbcs      NoResp
                    lbsr      AutoSwitch          the straps were sampled again
                    lbcs      NoResp
                    lda       #'E
                    sta       step,u
                    ldx       #VS1053.Base
                    clra
                    lbsr      ModeY
                    lda       #VS_MODE
                    lbsr      SCIWrite
                    lbcs      NoResp
                    lda       #'F
                    sta       step,u
                    lbsr      StatOn
                    lbcs      NoResp
                    lda       #'G
                    sta       step,u
                    lbsr      SetVol
                    lbcs      NoResp
* H-I CLOCKF 4.0x and read back
                    lda       #'H
                    sta       step,u
                    lda       #VS_CLOCKF
                    ldy       #$A000              SC_MULT 4.0x, no add
                    lbsr      SCIWrite
                    lbcs      NoResp
                    ldx       #6                  let the PLL settle
                    os9       F$Sleep
                    lda       #'I
                    sta       step,u
                    ldd       #$A000
                    std       exp,u
                    ldx       #VS1053.Base
                    lda       #VS_CLOCKF
                    lbsr      SCIRead
                    lbcs      NoResp
                    pshs      d
                    leax      lb7,pcr
                    ldy       #lb7l
                    lbsr      PutStr
                    puls      d
                    lbsr      PutRes
                    leax      nt7,pcr
                    ldy       #nt7l
                    lbsr      PutLine
* J the same read with the bridge in FAST mode
                    lda       #'J
                    sta       step,u
                    ldx       #VS1053.Base
                    lda       #VS_CLOCKF
                    lbsr      SCIReadFast
                    lbcs      NoResp
                    pshs      d
                    leax      lb8,pcr
                    ldy       #lb8l
                    lbsr      PutStr
                    puls      d
                    lbsr      PutRes
                    leax      nt8,pcr
                    ldy       #nt8l
                    lbsr      PutLine
* K real-time MIDI plugin, L a piano note over SDI
                    lda       #'K
                    sta       step,u
                    lbsr      LoadPlugin
                    lbcs      NoResp
                    ldx       #3                  let the MIDI code start
                    os9       F$Sleep
                    lda       #'L
                    sta       step,u
                    ldx       #VS1053.Base
                    leay      MidiOn,pcr
                    ldb       #MidiOnl
                    lbsr      SendMidi
                    lbcs      NoResp
                    leax      lb9,pcr
                    ldy       #lb9l
                    lbsr      PutSecs
                    ldx       ticks,u
                    os9       F$Sleep
                    ldx       #VS1053.Base
                    leay      MidiOff,pcr
                    ldb       #MidiOffl
                    lbsr      SendMidi
                    lbcs      NoResp
                    lbsr      WaitEmpty
                    lbcs      NoResp
                    ldx       #15                 let the note release
                    os9       F$Sleep
* M software reset - end of the chain
                    lda       #'M
                    sta       step,u
                    lbsr      SoftReset
                    lbcs      NoResp
                    lbsr      AutoSwitch          the straps were sampled again
                    lbcs      NoResp
                    clrb
                    os9       F$Exit

* MemTst (-m) - N tests on, O memory test, P HDAT0, Q software reset
MemTst              lda       #'N
                    sta       step,u
                    ldx       #VS1053.Base
                    lda       #$20
                    lbsr      ModeY
                    lda       #VS_MODE
                    lbsr      SCIWrite
                    lbcs      NoResp
                    lda       #'O
                    sta       step,u
                    leay      MemTest,pcr
                    lbsr      SendSeq
                    lbcs      NoResp
                    lbsr      WaitEmpty
                    lbcs      NoResp
                    ldx       #12                 ~200 ms for the test to run
                    os9       F$Sleep
                    lda       #'P
                    sta       step,u
                    ldd       #$83FF
                    std       exp,u
                    ldx       #VS1053.Base
                    lda       #VS_HDAT0
                    lbsr      SCIRead
                    lbcs      NoResp
                    pshs      d
                    leax      lba,pcr
                    ldy       #lbal
                    lbsr      PutStr
                    puls      d
                    lbsr      PutRes
                    leax      nta,pcr
                    ldy       #ntal
                    lbsr      PutLine
* Q software reset and out
                    lda       #'Q
                    sta       step,u
                    lbsr      HardReset           the datasheet's hardware reset after the memory test
                    clrb
                    os9       F$Exit

* LoadFile (-l) - stream a VLSI plugin file to the chip: raw big-endian words in VLSI's record format,
* [SCI register][count, bit 15 = a run of one value][value(s)], written over SCI as they are read.  No chip
* reset before or after, so the chip keeps whatever state it is in - a plugin can be tried on a running
* synthesizer.  VLSI's files end with an AIADDR record that starts the loaded code.  Prints the word and
* write counts, gives a restart a few ticks, exits 0.  Errors: cannot open, a file that ends mid-record.
LoadFile            lda       #'L
                    sta       step,u
                    ldx       fname,u
                    lda       #READ.
                    os9       I$Open
                    lbcs      OpenErr
                    sta       fpath,u
                    clra
                    clrb
                    std       bcount,u            buffer empty
                    std       kb,u                words read
                    std       bytes,u             SCI writes done
LfRec               lbsr      NextWord            the SCI register of the next record
                    lbcs      LfDone              the file ends between records: finished
                    stb       fillb,u
                    lbsr      NextWord            the count
                    lbcs      LfShort
                    tsta
                    bpl       LfCopy
                    anda      #$7F                a run: one value, repeated
                    std       rcnt,u
                    lbsr      NextWord
                    lbcs      LfShort
                    tfr       d,y
LfRun               ldd       rcnt,u
                    lbeq      LfRec
                    subd      #1
                    std       rcnt,u
                    lbsr      SciOut              Y = the value, fillb,u = the register
                    bra       LfRun
LfCopy              std       rcnt,u              a copy: count consecutive values
LfCp1               ldd       rcnt,u
                    lbeq      LfRec
                    subd      #1
                    std       rcnt,u
                    lbsr      NextWord
                    lbcs      LfShort
                    tfr       d,y
                    lbsr      SciOut
                    bra       LfCp1
LfShort             lda       #2
                    sta       path,u
                    leax      errp,pcr
                    ldy       #errpl
                    lbsr      PutLine
                    lda       fpath,u
                    os9       I$Close
                    ldb       #E$EOF
                    os9       F$Exit
LfDone              lda       fpath,u
                    os9       I$Close
                    leax      lbld,pcr
                    ldy       #lbldl
                    lbsr      PutStr
                    lbsr      PutName
                    leax      lbl2,pcr
                    ldy       #lbl2l
                    lbsr      PutStr
                    ldd       kb,u
                    lbsr      PutDec
                    leax      lbl3,pcr
                    ldy       #lbl3l
                    lbsr      PutStr
                    ldd       bytes,u
                    lbsr      PutDec
                    leax      lbl4,pcr
                    ldy       #lbl4l
                    lbsr      PutLine
                    ldx       #6                  a plugin that restarts the firmware needs a moment
                    os9       F$Sleep
                    clrb
                    os9       F$Exit

* SciOut - Y = value to the SCI register in fillb,u; counts the write in bytes,u.  A timeout ends the run.
SciOut              ldx       #VS1053.Base
                    lda       fillb,u
                    lbsr      SCIWrite            Y preserved
                    lbcs      NoResp
                    ldd       bytes,u
                    addd      #1
                    std       bytes,u
                    rts

* NextWord - D = the next big-endian word of the open file (rbuf refilled as it empties); kb,u counts the
* words.  Carry = end of file (or a read error).
NextWord            ldd       bcount,u
                    bne       NwHave
                    lda       fpath,u
                    leax      rbuf,u
                    ldy       #BUFSIZE
                    os9       I$Read
                    bcs       NwEOF
                    cmpy      #2
                    blo       NwEOF
                    sty       bcount,u
                    leax      rbuf,u
                    stx       pptr,u
NwHave              ldx       pptr,u
                    ldd       ,x++
                    stx       pptr,u
                    ldx       bcount,u
                    leax      -2,x
                    stx       bcount,u
                    pshs      d
                    ldd       kb,u
                    addd      #1
                    std       kb,u
                    puls      d
                    andcc     #^Carry
                    rts
NwEOF               orcc      #Carry
                    rts

* DumpRom (-u aaaa nnnn file) - nnnn instruction words from I:aaaa through the WRAM window: WRAMADDR = $8000 +
* aaaa once, then two WRAM reads per word (high half first, the chip's pointer auto-increments), into the file
* as big-endian 32-bit words.  No chip reset.  The datasheet lists only the RAM windows but says other areas
* can be accessed, so this is the way to read the ROM.
DumpRom             lda       #'U
                    sta       step,u
                    ldx       fname,u
                    lda       #WRITE.
                    ldb       #READ.+WRITE.
                    os9       I$Create
                    lbcs      OpenErr
                    sta       fpath,u
                    ldd       daddr,u
                    ora       #$80                the instruction-space window
                    tfr       d,y
                    ldx       #VS1053.Base
                    lda       #VS_WRAMADDR
                    lbsr      SCIWrite
                    lbcs      NoResp
                    clra
                    clrb
                    std       bcount,u            bytes waiting in rbuf
                    std       kb,u                words done
DrLoop              ldd       dcnt,u
                    lbeq      DrDone
                    subd      #1
                    std       dcnt,u
                    ldx       #VS1053.Base
                    lda       #VS_WRAM
                    lbsr      SCIRead             high half
                    lbcs      NoResp
                    lbsr      PutBuf
                    ldx       #VS1053.Base
                    lda       #VS_WRAM
                    lbsr      SCIRead             low half
                    lbcs      NoResp
                    lbsr      PutBuf
                    ldd       kb,u
                    addd      #1
                    std       kb,u
                    bra       DrLoop
DrDone              lbsr      FlushBuf
                    lda       fpath,u
                    os9       I$Close
                    leax      lbdu,pcr
                    ldy       #lbdul
                    lbsr      PutStr
                    ldd       kb,u
                    lbsr      PutDec
                    leax      lbd2,pcr
                    ldy       #lbd2l
                    lbsr      PutStr
                    ldd       daddr,u
                    lbsr      PutHex4
                    leax      lbd3,pcr
                    ldy       #lbd3l
                    lbsr      PutStr
                    lbsr      PutName
                    lbsr      PutCR
                    clrb
                    os9       F$Exit

* PutBuf - D into rbuf (big-endian), the buffer written to the file when full.  FlushBuf - write what waits.
PutBuf              pshs      d
                    leax      rbuf,u
                    ldd       bcount,u
                    leax      d,x
                    puls      d
                    std       ,x
                    ldd       bcount,u
                    addd      #2
                    std       bcount,u
                    cmpd      #BUFSIZE
                    blo       PbX
FlushBuf            ldd       bcount,u
                    beq       PbX
                    tfr       d,y
                    lda       fpath,u
                    leax      rbuf,u
                    os9       I$Write
                    lbcs      WrErr
                    clra
                    clrb
                    std       bcount,u
PbX                 rts
WrErr               pshs      b
                    lda       #2
                    sta       path,u
                    leax      errw,pcr
                    ldy       #errwl
                    lbsr      PutLine
                    lda       fpath,u
                    os9       I$Close
                    puls      b
                    os9       F$Exit

* PutName - the pathname at fname,u, counted like OpenErr does (stops at a space, a CR, a control byte or 40)
PutName             ldx       fname,u
                    ldy       #0
pn1@                lda       ,x+
                    cmpa      #C$SPAC
                    bls       pn2@
                    leay      1,y
                    cmpy      #40
                    blo       pn1@
pn2@                cmpy      #0
                    beq       pn9@
                    ldx       fname,u
                    lbsr      PutStr
pn9@                rts

* ResetOnly (-r) - the reset already happened at the start; show that the chip answers
ResetOnly           lda       #'1
                    sta       step,u
                    ldx       #VS1053.Base
                    lda       #VS_STATUS
                    lbsr      SCIRead
                    lbcs      NoResp
                    pshs      d
                    leax      lb1,pcr
                    ldy       #lb1l
                    lbsr      PutStr
                    puls      d
                    lbsr      PutDollar4
                    leax      nt1,pcr
                    ldy       #nt1l
                    lbsr      PutLine
                    clrb
                    os9       F$Exit

* AutoSwitch - right after a reset.  The ROM's session routine (I:$3F84) reads the GPIO pins at $3FB3
* and, when GPIO & 3 = 2 (GPIO1 high, GPIO0 low), starts the real-time MIDI synth: a strapped chip
* decodes nothing.  So the switcher goes in (the Jr2 note up top) and AUDATA must then read $1F40,
* the idle decoder.  Silent under -s without -d like everything else; a switch that fails is an
* error (E$BMode).  Carry = no response.
AutoSwitch          lda       #'W
                    sta       step,u
                    ldy       #$C018              GPIO_IDATA
                    lbsr      ReadWram
                    bcs       AsX
                    andb      #$03
                    cmpb      #$02
                    bne       AsOK                not strapped: nothing to do
                    lbsr      LoadSwitch
                    bcs       AsX
                    ldx       #6                  the restart needs a moment
                    os9       F$Sleep
                    leax      lbsw,pcr
                    ldy       #lbswl
                    lbsr      Verdict             the line; D = AUDATA
                    bcs       AsX
                    cmpd      #$1F40
                    beq       AsOK
                    lda       #2
                    sta       path,u
                    leax      errsw,pcr
                    ldy       #errswl
                    lbsr      PutLine
                    ldb       #E$BMode
                    os9       F$Exit
AsOK                andcc     #^Carry
AsX                 rts

* SynthOn (-n) / SynthOff (-o) - the chip as it is, no reset: VLSI's start plugin or the switcher,
* then the AUDATA verdict.
SynthOn             lda       #'Y
                    sta       step,u
                    lbsr      LoadPlugin
                    lbcs      NoResp
                    ldx       #3                  let the MIDI code start
                    os9       F$Sleep
                    leax      lbsn,pcr
                    ldy       #lbsnl
                    bra       SwDone
SynthOff            lda       #'Z
                    sta       step,u
                    lbsr      LoadSwitch
                    lbcs      NoResp
                    ldx       #6
                    os9       F$Sleep
                    leax      lbso,pcr
                    ldy       #lbsol
SwDone              lbsr      Verdict
                    lbcs      NoResp
                    clrb
                    os9       F$Exit

* Verdict - X/Y = label: prints "label $xxxx" + "  = stream decoder" ($1F40, the idle decoder's
* rate) or "  = real-time MIDI synth" ($AC45, 44100 Hz stereo, what the synth sets; a decoded
* 44.1 kHz stereo file shows the same, so the verdict is only for a fresh switch) and ends the
* line.  D = AUDATA on return; carry = timeout.
Verdict             lbsr      PutStr
                    ldx       #VS1053.Base
                    lda       #VS_AUDATA
                    lbsr      SCIRead
                    bcs       VdX
                    pshs      d
                    lbsr      PutDollar4
                    ldd       ,s
                    cmpd      #$1F40
                    bne       Vd1
                    leax      ntdec,pcr
                    ldy       #ntdecl
                    lbsr      PutStr
                    bra       Vd9
Vd1                 cmpd      #$AC45
                    bne       Vd9
                    leax      ntsyn,pcr
                    ldy       #ntsynl
                    lbsr      PutStr
Vd9                 lbsr      PutCR
                    puls      d
                    andcc     #^Carry
VdX                 rts

* Info (-i) - the chip as found: seven SCI registers, then the GPIO pins through WRAM ($C018 bit 1 is
* GPIO1, the real-time MIDI boot strap; bit 0 GPIO0 the SPI-boot strap, which wins: GPIO0 = 1 means the chip
* tried an SPI boot and runs the decoder whatever GPIO1 says).  Nothing is written but WRAMADDR.
Info                leax      lbi0,pcr
                    ldy       #lbi0l
                    lbsr      PutLine
                    lda       #'1
                    sta       step,u
                    lda       #VS_STATUS
                    leax      lbi1,pcr
                    ldy       #lbi1l
                    lbsr      InfoReg
                    lbcs      NoResp
                    lda       #VS_MODE
                    leax      lbi2,pcr
                    ldy       #lbi2l
                    lbsr      InfoReg
                    lbcs      NoResp
                    lda       #VS_CLOCKF
                    leax      lbi3,pcr
                    ldy       #lbi3l
                    lbsr      InfoReg
                    lbcs      NoResp
                    lda       #VS_AIADDR
                    leax      lbi4,pcr
                    ldy       #lbi4l
                    lbsr      InfoReg
                    lbcs      NoResp
                    lda       #VS_HDAT0
                    leax      lbi5,pcr
                    ldy       #lbi5l
                    lbsr      InfoReg
                    lbcs      NoResp
                    lda       #VS_HDAT1
                    leax      lbi6,pcr
                    ldy       #lbi6l
                    lbsr      InfoReg
                    lbcs      NoResp
                    lda       #VS_DECODE_TIME
                    leax      lbi7,pcr
                    ldy       #lbi7l
                    lbsr      InfoReg
                    lbcs      NoResp
                    lda       #VS_AUDATA
                    leax      lbib,pcr
                    ldy       #lbibl
                    lbsr      InfoReg
                    lbcs      NoResp
                    lda       #'2
                    sta       step,u
                    ldd       #$C017              GPIO_DDR
                    std       tmp,u
                    leax      lbi8,pcr
                    ldy       #lbi8l
                    lbsr      InfoRam
                    lbcs      NoResp
                    lbsr      PutCR
                    ldd       #$C018              GPIO_IDATA: the pins as the chip sees them
                    std       tmp,u
                    leax      lbi9,pcr
                    ldy       #lbi9l
                    lbsr      InfoRam
                    lbcs      NoResp
                    lbsr      PutCR               the verdict on its own line (B preserved)
                    bitb      #$01                GPIO0 first: high = SPI boot tried, decoder whatever GPIO1 says
                    beq       InfoStrap1
                    leax      nti9s,pcr
                    ldy       #nti9sl
                    lbsr      PutLine
                    lbra      InfoStrapD
InfoStrap1          bitb      #$02                GPIO1 as the chip sees it (D = the value)
                    beq       InfoStrap0
                    leax      nti9,pcr
                    ldy       #nti9l
                    lbsr      PutLine
                    lbra      InfoStrapD
InfoStrap0          leax      nti9n,pcr
                    ldy       #nti9nl
                    lbsr      PutLine
InfoStrapD          ldd       #$C019              GPIO_ODATA
                    std       tmp,u
                    leax      lbia,pcr
                    ldy       #lbial
                    lbsr      InfoRam
                    lbcs      NoResp
                    lbsr      PutCR
                    clrb
                    os9       F$Exit

* InfoReg - A = SCI register, X/Y = label: prints "label $xxxx" and ends the line.  Carry = timeout.
InfoReg             pshs      a
                    lbsr      PutStr
                    puls      a
                    ldx       #VS1053.Base
                    lbsr      SCIRead
                    bcs       InfoRegX
                    lbsr      PutDollar4
                    lbsr      PutCR
                    andcc     #^Carry
InfoRegX            rts

* InfoRam - tmp,u = chip address, X/Y = label: prints "label $xxxx" (no line end).  Carry = timeout.
InfoRam             lbsr      PutStr
                    ldx       #VS1053.Base
                    lda       #VS_WRAMADDR
                    ldy       tmp,u
                    lbsr      SCIWrite
                    bcs       InfoRamX
                    lda       #VS_WRAM
                    lbsr      SCIRead
                    bcs       InfoRamX
                    lbsr      PutDollar4
                    andcc     #^Carry
InfoRamX            rts

* ToneDone (-t) - leave the chip in normal mode
ToneDone            lda       #'D
                    sta       step,u
                    ldx       #VS1053.Base
                    clra                          tests off
                    lbsr      ModeY
                    lda       #VS_MODE
                    lbsr      SCIWrite
                    lbcs      NoResp
                    clrb
                    os9       F$Exit

********************************************************************
* Stream (-s) - bring the decoder up and feed it the file
Stream              lda       #'S
                    sta       step,u
                    clr       sigflag,u
                    leax      Icpt,pcr            any signal ends the stream like a key (kill <id> from the shell)
                    os9       F$Icpt
                    ldx       #VS1053.Base
                    clra                          SM_SDINEW only
                    lbsr      ModeY
                    lda       #VS_MODE
                    lbsr      SCIWrite
                    lbcs      NoResp
                    lbsr      StatOn              analog drivers on ($0440 with -g)
                    lbcs      NoResp
                    lbsr      DefClk              CLOCKF high byte: -c, else $80, or $C0 for a .mid
                    lda       clk,u
                    clrb
                    tfr       d,y
                    lda       #VS_CLOCKF
                    lbsr      SCIWrite
                    lbcs      NoResp
                    ldx       #6
                    os9       F$Sleep
                    lbsr      SetVol              0 dB unless -v said otherwise
                    lbcs      NoResp
* open the file; I$Open leaves X past the pathname, which gives its length
                    ldx       fname,u
                    lda       #READ.
                    os9       I$Open
                    lbcs      OpenErr
                    sta       fpath,u
                    tfr       x,d
                    subd      fname,u
                    pshs      d                   name length
                    leax      lbs,pcr
                    ldy       #lbsl
                    lbsr      PutStr
                    puls      y
                    ldx       fname,u
                    lbsr      PutStr
                    leax      nts,pcr
                    ldy       #ntsl
                    lbsr      PutLine
                    clra
                    clrb
                    std       bytes,u
                    std       kb,u
                    std       stallt,u
                    sta       keyhit,u
                    sta       first,u
                    sta       noted,u
                    ldd       #$FFFF
                    std       lastcnt,u
StrLoop             lda       fpath,u
                    leax      rbuf,u
                    ldy       #BUFSIZE
                    os9       I$Read
                    lbcs      StrEOF
                    sty       bcount,u
                    tst       first,u
                    bne       StrPush
                    inc       first,u
                    lbsr      MidiHdr             a Standard MIDI File announces its format and track count
StrPush             lbsr      PushBuf             rbuf -> FIFO (waits for room; notice and key inside)
                    tst       keyhit,u
                    bne       StrKey
                    lbsr      ChkKey
                    bcs       StrLoop
* StrKey - a key or a signal: say so, silence the chip at once (a MIDI file would play on for minutes) and leave
StrKey              lda       fpath,u
                    os9       I$Close
                    leax      lbk,pcr
                    ldy       #lbkl
                    tst       sigflag,u
                    beq       StrKey2
                    leax      lbsg,pcr
                    ldy       #lbsgl
StrKey2             lbsr      PutStr
                    ldd       kb,u
                    lbsr      PutDec
                    leax      kbmsg,pcr
                    ldy       #kbmsgl
                    lbsr      PutLine
                    lbsr      HardReset
                    clrb
                    os9       F$Exit
StrEOF              cmpb      #E$EOF
                    beq       StrDone
                    pshs      b
                    lda       #2
                    sta       path,u
                    leax      errr,pcr
                    ldy       #errrl
                    lbsr      PutLine
                    lda       fpath,u
                    os9       I$Close
                    puls      b
                    os9       F$Exit
StrDone             leax      lbe,pcr
                    ldy       #lbel
* StrEnd - X/Y = "stopped..." or "end of file..." text; flush, drain, report, reset
StrEnd              lbsr      PutStr
                    ldd       kb,u
                    lbsr      PutDec
                    leax      kbmsg,pcr
                    ldy       #kbmsgl
                    lbsr      PutLine
                    lda       fpath,u
                    os9       I$Close
* From here every SCI command may find DREQ low for a long time: the chip still plays what it holds, and a
* MIDI file is consumed at its tempo (the last events can be seconds apart), so WaitIdle now allows 60 s
* per command and lets a key or a signal end the wait (ed.5; ed.2 reported error 246 here at the end of a
* .mid, "no response at step S", after the song had all but finished).
                    inc       long,u
* The end, the datasheet way (10.5.1): 2052 endFillBytes push the last frames through the decoder, at the file's
* own pace (a MIDI file is consumed at its tempo, so this can take minutes; the notice and the key still apply)
                    ldx       #VS1053.Base
                    lda       #VS_WRAMADDR
                    ldy       #$1E06              parameter RAM: endFillByte
                    lbsr      SCIWrite
                    lbcs      NoResp
                    lda       #VS_WRAM
                    lbsr      SCIRead
                    lbcs      NoResp
                    stb       fillb,u
                    leax      rbuf,u
                    ldy       #BUFSIZE
StrFillB            stb       ,x+
                    leay      -1,y
                    bne       StrFillB
                    ldb       #FIFOSIZE/BUFSIZE
StrFill             pshs      b
                    ldd       #BUFSIZE
                    std       bcount,u
                    lbsr      PushBuf
                    puls      b
                    tst       keyhit,u
                    lbne      StrKey
                    decb
                    bne       StrFill
                    ldd       #4                  2048 + 4 = 2052
                    std       bcount,u
                    lbsr      PushBuf
                    tst       keyhit,u
                    lbne      StrKey
                    lbsr      DrainFifo           every fill byte is inside the chip: the song bytes before them are decoded
* the chip's own count of seconds decoded
                    ldx       #VS1053.Base
                    lda       #VS_DECODE_TIME
                    lbsr      SCIRead
                    lbcs      NoResp
                    pshs      d
                    leax      lbdt,pcr
                    ldy       #lbdtl
                    lbsr      PutStr
                    puls      d
                    lbsr      PutDec
                    leax      ntdt,pcr
                    ldy       #ntdtl
                    lbsr      PutLine
* SM_CANCEL, then 32 fill bytes at a time until the decoder drops the bit (64 tries)
                    ldx       #VS1053.Base
                    lda       #VS_MODE
                    lbsr      SCIRead
                    lbcs      NoResp
                    orb       #$08                SM_CANCEL
                    tfr       d,y
                    lda       #VS_MODE
                    lbsr      SCIWrite
                    lbcs      NoResp
                    lda       #64
                    sta       ccnt,u
StrCancel           ldd       #32
                    std       bcount,u
                    lbsr      PushBuf
                    tst       keyhit,u
                    lbne      StrKey
                    lbsr      DrainFifo
                    ldx       #VS1053.Base
                    lda       #VS_MODE
                    lbsr      SCIRead
                    lbcs      NoResp
                    bitb      #$08
                    beq       StrCancelled
                    dec       ccnt,u
                    bne       StrCancel
                    leax      ntcx,pcr
                    ldy       #ntcxl
                    lbsr      PutLine
                    bra       StrTail
StrCancelled        leax      ntcok,pcr
                    ldy       #ntcokl
                    lbsr      PutLine
StrTail             ldx       #10                 let the DAC buffer play out
                    os9       F$Sleep
                    ldx       #VS1053.Base
                    lda       #VS_STATUS
                    lbsr      SCIRead
                    lbcs      NoResp
                    pshs      d
                    leax      lbse,pcr
                    ldy       #lbsel
                    lbsr      PutStr
                    puls      d
                    lbsr      PutHex4             D preserved
                    bita      #$08                bit 11 = SS_VCM_OVERLOAD (high byte bit 3)
                    beq       StrNoOvl
                    leax      ntov,pcr
                    ldy       #ntovl
                    lbsr      PutLine
                    bra       StrHd
StrNoOvl            leax      ntok,pcr
                    ldy       #ntokl
                    lbsr      PutLine
StrHd               ldx       #VS1053.Base
                    lda       #VS_HDAT1
                    lbsr      SCIRead
                    lbcs      NoResp
                    pshs      d
                    leax      lbh,pcr
                    ldy       #lbhl
                    lbsr      PutStr
                    puls      d
                    lbsr      PutHex4
                    leax      nth,pcr
                    ldy       #nthl
                    lbsr      PutLine
                    lbsr      SoftReset
                    lbcs      NoResp
                    lbsr      AutoSwitch          the straps were sampled again
                    lbcs      NoResp
                    clrb
                    os9       F$Exit

* DrainFifo - wait until the bridge FIFO is empty; the 30 s notice and the key apply (a key leaves via StrKey)
DrainFifo           ldd       #$FFFF
                    std       lastcnt,u
DfLoop              ldx       #VS1053.Base
                    ldd       VS_FIFOSTAT,x
                    bita      #VS_FIFO_EMPTY
                    bne       DfDone
                    bita      #VS_FIFO_FULL
                    beq       DfCnt
                    ldd       #FIFOSIZE
                    bra       DfWait
DfCnt               anda      #VS_FIFO_CNTHI
DfWait              lbsr      Progress
                    bcc       DfW2
                    lbsr      StallNote
DfW2                lbsr      ChkKey
                    lbcc      StrKey
                    ldx       #1
                    os9       F$Sleep
                    bra       DfLoop
DfDone              rts

* StallNote - 30 s without a byte taken: one notice, then carry on (a hung chip is silent and the key resets it)
StallNote           tst       noted,u
                    bne       StallDone
                    inc       noted,u
                    pshs      x,y
                    leax      stl1,pcr
                    ldy       #stl1l
                    lbsr      PutStr
                    ldd       kb,u
                    lbsr      PutDec
                    leax      stl2,pcr
                    ldy       #stl2l
                    lbsr      PutLine
                    puls      x,y
StallDone           rts

* OpenErr - "vs: cannot open <name> (error #nnn)" on stderr, then exit with the error.  The name is
* printed with a counted I$Write, never I$WritLn: ed.2 handed I$WritLn 40 bytes and trusted the CR that
* ends the parameter area, so a damaged name ran the write on past the parameters into whatever the map
* held there (junk with control codes, cursor homed).  The scan stops at a space, a CR, any control
* byte, or 40 characters, and the OS-9 error number says why the open failed (216 = not found,
* 214 = bad path name).
OpenErr             pshs      b                   the error code
                    lda       #2
                    sta       path,u
                    leax      erro,pcr
                    ldy       #errol
                    lbsr      PutStr
                    ldx       fname,u
                    ldy       #0
oe1@                lda       ,x+
                    cmpa      #C$SPAC
                    bls       oe2@                space, CR or any control byte ends the name
                    leay      1,y
                    cmpy      #40
                    blo       oe1@
oe2@                cmpy      #0
                    beq       oe3@
                    ldx       fname,u
                    lbsr      PutStr              Y = the counted length
oe3@                leax      erre,pcr
                    ldy       #errel
                    lbsr      PutStr
                    clra
                    ldb       ,s                  the error code, in decimal
                    lbsr      PutDec
                    leax      errf,pcr
                    ldy       #errfl
                    lbsr      PutLine             ")" and the line end, on stderr
                    puls      b
                    os9       F$Exit

* MidiHdr - if rbuf starts with "MThd": format 0 = the -d info line; any other format = an error line on
* stderr, quiet mode or not (the chip plays format 0 only, so expect silence), then the stream goes on
MidiHdr             leax      rbuf,u
                    ldd       ,x
                    cmpd      #$4D54              "MT"
                    bne       MidiHdrX
                    ldd       2,x
                    cmpd      #$6864              "hd"
                    bne       MidiHdrX
                    ldd       rbuf+8,u            format
                    beq       MidiHdr0
                    lda       #2                  stderr: this one gets through the quiet gate
                    sta       path,u
                    leax      lbmf,pcr
                    ldy       #lbmfl
                    lbsr      PutStr
                    ldd       rbuf+8,u
                    lbsr      PutDec
                    leax      lbmt,pcr
                    ldy       #lbmtl
                    lbsr      PutStr
                    ldd       rbuf+10,u           tracks
                    lbsr      PutDec
                    leax      ntmf,pcr
                    ldy       #ntmfl
                    lbsr      PutLine
                    lda       #1
                    sta       path,u
                    rts
MidiHdr0            leax      lbmh,pcr
                    ldy       #lbmhl
                    lbsr      PutStr
                    ldd       rbuf+8,u            format
                    lbsr      PutDec
                    leax      lbmt,pcr
                    ldy       #lbmtl
                    lbsr      PutStr
                    ldd       rbuf+10,u           tracks
                    lbsr      PutDec
                    leax      ntm,pcr
                    ldy       #ntml
                    lbsr      PutLine
MidiHdrX            rts

* PushBuf - bcount,u bytes from rbuf into the SDI FIFO, BURST bytes per room check; sleeps a
* tick while there is no room (30 s without a byte taken prints a notice once).
* keyhit,u set (bytes left unsent) = a key ended the stream.  Carry is always clear.
PushBuf             leay      rbuf,u
pbNext              ldd       bcount,u
                    lbeq      pbOK
pbRoom              ldx       #VS1053.Base
                    ldd       VS_FIFOSTAT,x       flags + 11-bit count in one read (rc12 bridge)
                    bita      #VS_FIFO_FULL
                    beq       pbCnt
                    ldd       #FIFOSIZE           full: the count field has rolled over
                    bra       pbWait
pbCnt               anda      #VS_FIFO_CNTHI
                    cmpd      #FIFOSIZE-BURST
                    bls       pbGo
pbWait              lbsr      Progress            D = count: has the chip taken anything since the last look?
                    bcc       pbW2
                    lbsr      StallNote           30 s without a byte: say so once, keep waiting
pbW2                lbsr      ChkKey
                    bcc       pbKey
                    ldx       #1
                    os9       F$Sleep
                    bra       pbRoom
pbKey               inc       keyhit,u
                    lbra      pbOK
pbGo                ldd       #$FFFF
                    std       lastcnt,u           a burst goes in: the next look starts fresh
                    ldd       bcount,u
                    cmpd      #BURST
                    bls       pbLen
                    ldd       #BURST
pbLen               pshs      d
                    ldd       bcount,u
                    subd      ,s
                    std       bcount,u
                    ldd       bytes,u
                    addd      ,s
                    cmpd      #1024
                    blo       pbKb
                    subd      #1024
                    pshs      d
                    ldd       kb,u
                    addd      #1
                    std       kb,u
                    puls      d
pbKb                std       bytes,u
                    puls      d
pbByte              lda       ,y+
                    sta       VS_FIFO,x
                    decb
                    bne       pbByte
                    bra       pbNext
pbOK                andcc     #^Carry
                    rts

* Progress - D = the FIFO count just read.  Lower than at the last look = the chip is consuming:
* the watchdog restarts.  Otherwise it counts ticks; carry set after 30 s without a byte taken.
Progress            cmpd      lastcnt,u
                    bhs       pg1@
                    std       lastcnt,u
                    clr       stallt,u
                    clr       stallt+1,u
                    andcc     #^Carry
                    rts
pg1@                std       lastcnt,u
                    ldd       stallt,u
                    addd      #1
                    std       stallt,u
                    cmpd      #1800               30 s
                    bhs       pg9@
                    andcc     #^Carry
                    rts
pg9@                orcc      #Carry
                    rts

* ChkKey - carry clear if a signal arrived or a key is waiting on stdin (swallowed); X and Y preserved.
* With -b the terminal is never touched, so a backgrounded vs cannot steal the shell's keys.
ChkKey              pshs      x,y
                    tst       sigflag,u
                    beq       ChkKey2
                    andcc     #^Carry
                    puls      x,y,pc
ChkKey2             tst       bg,u
                    bne       KeyNo
                    lda       #0
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcs       KeyNo
                    lda       #0
                    leax      hexbuf,u
                    ldy       #1
                    os9       I$Read
                    andcc     #^Carry
                    puls      x,y,pc
KeyNo               orcc      #Carry
                    puls      x,y,pc

* Icpt - signal intercept (installed by -s): everything but a wake-up sets the flag the stream loop polls
Icpt                cmpb      #S$Wake
                    beq       IcptDone
                    inc       sigflag,u
IcptDone            rti

* NoResp - "no response at step N (...): CTRL=$xx FIFOSTAT=$xx DATA=$xxxx" on stderr, exit 246
NoResp              tst       keyhit,u            a key or a signal ended a long SCI wait: not a chip failure
                    lbne      StrKey
                    lda       #2
                    sta       path,u
                    leax      msg3,pcr
                    ldy       #msg3l
                    lbsr      PutStr
                    leax      step,u
                    ldy       #1
                    lbsr      PutStr
                    leax      msg4,pcr
                    ldy       #msg4l
                    lbsr      PutStr
                    ldx       #VS1053.Base
                    lda       VS_CTRL,x
                    lbsr      PutHex2
                    leax      msg5,pcr
                    ldy       #msg5l
                    lbsr      PutStr
                    ldx       #VS1053.Base
                    lda       VS_FIFOSTAT,x
                    lbsr      PutHex2
                    leax      msg6,pcr
                    ldy       #msg6l
                    lbsr      PutStr
                    ldx       #VS1053.Base
                    ldd       VS_DATA,x
                    lbsr      PutHex4
                    lbsr      PutCR
                    leax      lg1,pcr             the step legend, one line at a time
NrLeg               leay      lgend,pcr
                    pshs      y
                    cmpx      ,s++
                    bhs       NrDone
                    ldy       #64
                    lda       #2
                    os9       I$WritLn
                    bcs       NrDone
                    tfr       y,d
                    leax      d,x
                    bra       NrLeg
NrDone              ldb       #E$NotRdy
                    os9       F$Exit

********************************************************************
* GetArgs - parameter list at X: "-t" sets mode 1; "-s <file>" sets mode 2 and keeps the
* pathname pointer; a decimal number is the seconds per tone -> secs,u, ticks,u = secs x 60.
* No number, or 0, means 5 s; anything above 999 is clipped to 999.
GetArgs             clra
                    clrb
                    std       secs,u
                    sta       mode,u
                    sta       volset,u
                    sta       clkset,u
                    sta       gbuf,u
                    sta       bg,u
                    sta       share,u
                    sta       dbg,u
                    sta       quiet,u
                    sta       long,u
gs1@                lda       ,x+
                    cmpa      #C$SPAC
                    lbeq      gs1@
                    cmpa      #'-
                    lbne      gs2@
                    lda       ,x+
                    cmpa      #$3F                '?'
                    lbne      gsU@
                    lda       #4
                    sta       mode,u
                    lbra      gs1@
gsU@                anda      #$DF                upper case
                    cmpa      #'T
                    lbne      gsR@
                    lda       #1
                    sta       mode,u
                    lbra      gs1@
gsR@                cmpa      #'R
                    lbne      gsG@
                    lda       #5
                    sta       mode,u
                    lbra      gs1@
gsG@                cmpa      #'G
                    lbne      gsB@
                    inc       gbuf,u
                    lbra      gs1@
gsB@                cmpa      #'B
                    lbne      gsX@
                    inc       bg,u
                    lbra      gs1@
gsX@                cmpa      #'X
                    lbne      gsI@
                    inc       share,u
                    lbra      gs1@
gsI@                cmpa      #'I
                    lbne      gsD@
                    lda       #6
                    sta       mode,u
                    lbra      gs1@
gsD@                cmpa      #'D
                    lbne      gs5@
                    inc       dbg,u
                    lbra      gs1@
gs5@                cmpa      #'M
                    lbne      gs7@
                    lda       #3
                    sta       mode,u
                    lbra      gs1@
gs7@                cmpa      #'V
                    lbne      gsC@
                    lbsr      GetHex              the next token as a hex byte
                    sta       vol,u
                    inc       volset,u
                    lbra      gs1@
gsC@                cmpa      #'C
                    lbne      gsL@
                    lbsr      GetHex
                    sta       clk,u
                    inc       clkset,u
                    lbra      gs1@
gsL@                cmpa      #'L
                    lbne      gsDm@
                    lda       #7
                    sta       mode,u
                    lbra      gs6@                the file name follows
gsDm@                cmpa      #'U
                    lbne      gsN2@
                    lda       #8
                    sta       mode,u
                    lbsr      GetHex4             first instruction address
                    std       daddr,u
                    lbsr      GetHex4             word count
                    std       dcnt,u
                    lbra      gs6@                then the file name
gsN2@               cmpa      #'N
                    lbne      gsO@
                    lda       #9
                    sta       mode,u
                    lbra      gs1@
gsO@                cmpa      #'O
                    lbne      gsS@
                    lda       #10
                    sta       mode,u
                    lbra      gs1@
gsS@                cmpa      #'S
                    lbne      gs1@                unknown option: ignore it
                    lda       #2
                    sta       mode,u
gs6@                lda       ,x+
                    cmpa      #C$SPAC
                    lbeq      gs6@
                    leax      -1,x
                    stx       fname,u             the pathname (I$Open finds its end)
gsN@                lda       ,x+                 skip the name so more switches may follow it
                    cmpa      #C$SPAC
                    lbeq      gs1@
                    cmpa      #C$CR
                    lbne      gsN@
                    lbra      gs9@
gs2@                cmpa      #'0
                    blo       gs9@
                    cmpa      #'9
                    bhi       gs9@
                    suba      #'0
                    sta       tmp+1,u             the digit
                    ldd       secs,u
                    lslb                          x2
                    rola
                    pshs      d
                    lslb                          x4
                    rola
                    lslb                          x8
                    rola
                    addd      ,s++                x10
                    addb      tmp+1,u
                    adca      #0
                    std       secs,u
                    cmpd      #999
                    bls       gs3@
                    ldd       #999
                    std       secs,u
gs3@                lda       ,x+
                    cmpa      #C$SPAC
                    lbeq      gs1@                more tokens may follow the number
                    lbra      gs2@
gs9@                ldd       secs,u
                    lbne      gs4@
                    ldd       #5
                    std       secs,u
gs4@                lslb                          x2
                    rola
                    lslb                          x4
                    rola
                    std       tmp,u
                    lslb                          x8
                    rola
                    lslb                          x16
                    rola
                    lslb                          x32
                    rola
                    lslb                          x64
                    rola
                    subd      tmp,u               x60
                    std       ticks,u
                    rts

* GetHex - skip spaces at X, then up to two hex digits -> A (0 if none); X past them.
GetHex              clr       tmp,u
gh1@                lda       ,x+
                    cmpa      #C$SPAC
                    beq       gh1@
                    leax      -1,x
                    ldb       #2
gh2@                lda       ,x
                    lbsr      HexVal
                    bcs       gh9@
                    leax      1,x
                    pshs      a
                    lda       tmp,u
                    lsla
                    lsla
                    lsla
                    lsla
                    ora       ,s+
                    sta       tmp,u
                    decb
                    bne       gh2@
gh9@                lda       tmp,u
                    rts
* GetHex4 - X = parameter text: skip spaces, then up to four hex digits -> D (and tmp,u); X past them
GetHex4             clr       tmp,u
                    clr       tmp+1,u
                    lda       #4
                    sta       rcnt+1,u
gh4a@               lda       ,x+
                    cmpa      #C$SPAC
                    beq       gh4a@
                    leax      -1,x
gh4b@               lda       ,x
                    lbsr      HexVal
                    bcs       gh4x@
                    leax      1,x
                    pshs      a
                    ldd       tmp,u
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    orb       ,s+
                    std       tmp,u
                    dec       rcnt+1,u
                    bne       gh4b@
gh4x@               ldd       tmp,u
                    rts
* HexVal - A = ASCII hex digit -> A = 0..15; carry set if it is not one
HexVal              cmpa      #'0
                    blo       hv9@
                    cmpa      #'9
                    bhi       hv1@
                    suba      #'0
                    andcc     #^Carry
                    rts
hv1@                anda      #$DF
                    cmpa      #'A
                    blo       hv9@
                    cmpa      #'F
                    bhi       hv9@
                    suba      #'A-10
                    andcc     #^Carry
                    rts
hv9@                orcc      #Carry
                    rts

********************************************************************
* SCIWrite - A = SCI register, Y = 16-bit value, X = VS1053.Base.
* The core's data pair is big-endian, so one sty does it.  Carry = timeout.
* clr VS_CTRL also clears VS_FAST, so the bridge runs at its boot-safe rate.
SCIWrite            sta       VS_SCIREG,x
                    sty       VS_DATA,x
                    clr       VS_CTRL,x           START is edge-triggered: make sure it is low first
                    lda       #VS_START
                    sta       VS_CTRL,x
                    lbra      WaitIdle

* SCIRead - A = SCI register, X = base.  Returns D = value; carry = timeout.
SCIRead             sta       VS_SCIREG,x
                    clr       VS_CTRL,x
                    lda       #VS_START+VS_READ
                    sta       VS_CTRL,x
                    lbsr      WaitIdle
                    bcs       rd@
                    ldd       VS_DATA,x
rd@                 rts

* SCIReadFast - as SCIRead with the bridge's FAST bit (SPI 6.29 MHz; needs CLKI >= 44 MHz).
SCIReadFast         sta       VS_SCIREG,x
                    clr       VS_CTRL,x
                    lda       #VS_START+VS_READ+VS_FAST
                    sta       VS_CTRL,x
                    lbsr      WaitIdle
                    bcs       rf@
                    ldd       VS_DATA,x
rf@                 clr       VS_CTRL,x           back to the slow rate for everything else
                    rts

* Help (-?) - the switch summary, one I$WritLn per line (every line ends in CR, none over 63 columns)
Help                leax      HelpTxt,pcr
HelpLoop            leay      HelpEnd,pcr
                    pshs      y
                    cmpx      ,s++
                    bhs       HelpDone
                    ldy       #64
                    lda       #1
                    os9       I$WritLn
                    bcs       HelpDone
                    tfr       y,d
                    leax      d,x
                    bra       HelpLoop
HelpDone            clrb
                    os9       F$Exit

* StatOn - STATUS = $0040 (SS_VER kept, analog drivers on), or $0440 with -g (VCM buffer disabled);
* exp,u = the word written.  Carry = timeout.
StatOn              ldd       #$0040
                    tst       gbuf,u
                    beq       so1@
                    ldd       #$0440
so1@                std       exp,u
                    tfr       d,y
                    ldx       #VS1053.Base
                    lda       #VS_STATUS
                    lbra      SCIWrite

* ModeY - Y = the MODE word: $0800 (SM_SDINEW), or $0C00 with -x (SM_SDISHARE too), plus the flags in A
ModeY               pshs      a
                    lda       #$08
                    tst       share,u
                    beq       ModeY1
                    lda       #$0C
ModeY1              ldb       ,s+
                    tfr       d,y
                    rts

* SetVol - VOL = vol,u on both channels (0.5 dB attenuation steps); exp,u = the word.  Carry = timeout.
SetVol              lda       vol,u
                    tfr       a,b
                    std       exp,u
                    tfr       d,y
                    ldx       #VS1053.Base
                    lda       #VS_VOL
                    lbra      SCIWrite

* DefClk - unless -c was given, the CLOCKF high byte for the file type (ClkTab, by the last three
* characters after a '.'; $60 when there is no such extension or it is not in the table).  The
* caller keeps X = the bridge base.
DefClk              pshs      x,y
                    tst       clkset,u
                    bne       dc9@
                    lda       #$60
                    sta       clk,u
                    ldx       fname,u
dc1@                ldb       ,x+                 find the end of the name
                    cmpb      #C$SPAC
                    beq       dc2@
                    cmpb      #C$CR
                    bne       dc1@
dc2@                leax      -5,x                the '.' of a three-character extension
                    cmpx      fname,u
                    blo       dc9@                shorter than ".xxx"
                    lda       ,x+
                    cmpa      #'.
                    bne       dc9@                no three-character extension
                    leay      hexbuf,u            the extension, upper case, into hexbuf
                    ldb       #3
dcu@                lda       ,x+
                    cmpa      #'a
                    blo       dcs@
                    cmpa      #'z
                    bhi       dcs@
                    suba      #$20
dcs@                sta       ,y+
                    decb
                    bne       dcu@
                    leay      ClkTab,pcr
dc3@                tst       ,y                  end of the table: keep $80
                    beq       dc9@
                    sty       tmp,u
                    leax      hexbuf,u
                    ldb       #3
dc4@                lda       ,y+
                    cmpa      ,x+
                    bne       dc5@
                    decb
                    bne       dc4@
                    lda       ,y                  matched: the clock byte follows the name
                    sta       clk,u
                    bra       dc9@
dc5@                ldy       tmp,u
                    leay      4,y                 next entry
                    bra       dc3@
dc9@                puls      x,y,pc

* ClkTab - extension (upper case, three characters) and the CLOCKF high byte for it.  MP3, Ogg
* and WAV: 3.0x, the datasheet's typical clock and the default here (4.5x, the chip's limit, cut an
* MP3 short on the bench).  AAC and WMA: 3.0x plus the 1.5x adder those decoders raise by
* themselves when a file needs it (HE-AAC wants 4.5x).  MIDI: 4.0x, the synthesizer is the
* chip's heaviest job.
ClkTab              fcc       "MP3"
                    fcb       $60
                    fcc       "OGG"
                    fcb       $60
                    fcc       "WAV"
                    fcb       $60
                    fcc       "AAC"
                    fcb       $70
                    fcc       "M4A"
                    fcb       $70
                    fcc       "MP4"
                    fcb       $70
                    fcc       "WMA"
                    fcb       $70
                    fcc       "MID"
                    fcb       $A0
                    fcb       0

* DefVol - unless -v was given: 0 dB ($00) for -s, -8 dB ($10) for everything else
DefVol              tst       volset,u
                    bne       dv9@
                    lda       #$10
                    ldb       mode,u
                    cmpb      #2
                    bne       dv1@
                    clra
dv1@                sta       vol,u
dv9@                rts

* HardReset - CTRL bit 3 (rc12+ cores): drive the chip's XRESET low for two ticks, release it,
* then give it three ticks to boot and raise DREQ.  Pre-rc12 cores ignore the bit.
HardReset           ldx       #VS1053.Base
                    lda       #VS_RESET
                    sta       VS_CTRL,x
                    ldx       #2
                    os9       F$Sleep
                    ldx       #VS1053.Base
                    clr       VS_CTRL,x
                    ldx       #3
                    os9       F$Sleep
                    rts

* SoftReset - MODE = SM_SDINEW | SM_RESET, then wait for the chip to come back.  Carry = timeout.
* (It re-samples the boot straps, which are the board's business: see the Jr2 note up top.)
SoftReset           ldx       #VS1053.Base
                    lda       #$04                SM_RESET
                    lbsr      ModeY
                    lda       #VS_MODE
                    lbsr      SCIWrite
                    bcs       SoftResetX
                    ldx       #3                  DREQ drops and returns within a few ms
                    os9       F$Sleep
                    andcc     #^Carry
SoftResetX          rts

* ReadWram - Y = chip address (RAM or I/O space), D = the word there.  Carry = timeout.
ReadWram            ldx       #VS1053.Base
                    lda       #VS_WRAMADDR
                    lbsr      SCIWrite
                    bcs       ReadWramX
                    lda       #VS_WRAM
                    lbsr      SCIRead
ReadWramX           rts

* WaitIdle - wait for BUSY to clear: a short spin (a few ms at any CPU speed), then one look per
* tick for up to 2 s, so turbo or a faster CPU cannot shorten the wait.  Carry = still busy.
WaitIdle            pshs      y
                    ldy       #4096
WiSpin              lda       VS_CTRL,x
                    bita      #VS_BUSY
                    beq       WiOK
                    leay      -1,y
                    bne       WiSpin
                    ldy       #120                2 s
                    tst       long,u              the -s end sequence: the chip may hold DREQ low for many
                    beq       WiTick              seconds while it plays out (a MIDI file at its tempo)
                    ldy       #3600               60 s, and a key or a signal ends the wait
WiTick              pshs      x,y
                    ldx       #1
                    os9       F$Sleep
                    puls      x,y
                    lda       VS_CTRL,x
                    bita      #VS_BUSY
                    beq       WiOK
                    tst       long,u
                    beq       WiNext
                    lbsr      ChkKey              carry clear = a key or a signal (X and Y preserved)
                    bcs       WiNext
                    inc       keyhit,u            NoResp hands a key to StrKey: silence the chip, no error
                    bra       WiFail
WiNext              leay      -1,y
                    bne       WiTick
WiFail              puls      y
                    orcc      #Carry
                    rts
WiOK                puls      y
                    andcc     #^Carry
                    rts

* WaitEmpty - wait for the SDI FIFO to drain, the same way.  Carry = never drained (2 s).
WaitEmpty           pshs      y
                    ldy       #4096
WeSpin              lda       VS_FIFOSTAT,x
                    bita      #VS_FIFO_EMPTY
                    bne       WeOK
                    leay      -1,y
                    bne       WeSpin
                    ldy       #120
WeTick              pshs      x,y
                    ldx       #1
                    os9       F$Sleep
                    puls      x,y
                    lda       VS_FIFOSTAT,x
                    bita      #VS_FIFO_EMPTY
                    bne       WeOK
                    leay      -1,y
                    bne       WeTick
                    puls      y
                    orcc      #Carry
                    rts
WeOK                puls      y
                    andcc     #^Carry
                    rts

* SendSeq - push the 8-byte sequence at Y into the SDI FIFO.  Carry = FIFO stuck full.
SendSeq             ldb       #8
sq@                 pshs      b
                    lda       ,y+
                    lbsr      SDIWrite
                    puls      b
                    bcs       sqx@
                    decb
                    bne       sq@
                    andcc     #^Carry
sqx@                rts

* SDIWrite - A = byte, X = base.  Wait while the FIFO is full (spin, then a tick per look for up
* to 2 s), then store.  Carry = stuck full.
SDIWrite            pshs      y
                    ldy       #4096
SdSpin              ldb       VS_FIFOSTAT,x
                    bitb      #VS_FIFO_FULL
                    beq       SdOK
                    leay      -1,y
                    bne       SdSpin
                    ldy       #120
SdTick              pshs      a,x,y
                    ldx       #1
                    os9       F$Sleep
                    puls      a,x,y
                    ldb       VS_FIFOSTAT,x
                    bitb      #VS_FIFO_FULL
                    beq       SdOK
                    leay      -1,y
                    bne       SdTick
                    puls      y
                    orcc      #Carry
                    rts
SdOK                sta       VS_FIFO,x
                    puls      y
                    andcc     #^Carry
                    rts

* SendMidi - B bytes at Y, each sent over SDI as 00, byte (real-time MIDI format).  Carry = FIFO stuck.
SendMidi            pshs      b
sm1@                lda       ,y+
                    pshs      a
                    clra
                    lbsr      SDIWrite
                    puls      a
                    bcs       sm9@
                    lbsr      SDIWrite
                    bcs       sm9@
                    dec       ,s
                    bne       sm1@
                    andcc     #^Carry
sm9@                puls      b,pc

* LoadPlugin - VLSI's real-time MIDI start plugin (Plugin) to the chip over SCI; LoadSwitch - the
* switcher (Switch).  LoadTable - Y = table, D = word count: records [register][count | $8000 =
* run][value(s)].  Carry = timeout.
* Records: SCI register word, count word (bit 15 = run of one repeated value), values.  Carry = timeout.
LoadPlugin          leay      Plugin,pcr
                    ldd       #(Plugin_end-Plugin)/2
                    bra       LoadTable
LoadSwitch          leay      Switch,pcr
                    ldd       #(Switch_end-Switch)/2
LoadTable           sty       pptr,u
                    std       pcnt,u
lpnext              ldd       pcnt,u
                    lbeq      lpdone
                    subd      #2
                    std       pcnt,u
                    ldy       pptr,u
                    lda       1,y                 the SCI register (low byte of the address word)
                    sta       tmp,u
                    ldd       2,y                 the count word
                    leay      4,y
                    sty       pptr,u
                    bita      #$80
                    beq       lpcopy
* run: one value, repeated
                    anda      #$7F
                    std       rcnt,u
                    ldd       pcnt,u
                    subd      #1
                    std       pcnt,u
                    ldy       pptr,u
                    leay      2,y
                    sty       pptr,u
lprun               ldd       rcnt,u
                    lbeq      lpnext
                    subd      #1
                    std       rcnt,u
                    ldy       pptr,u
                    ldy       -2,y                the repeated value
                    ldx       #VS1053.Base
                    lda       tmp,u
                    lbsr      SCIWrite
                    lbcs      lpfail
                    lbra      lprun
* copy: count consecutive values
lpcopy              std       rcnt,u
lpcp1               ldd       rcnt,u
                    lbeq      lpnext
                    subd      #1
                    std       rcnt,u
                    ldd       pcnt,u
                    subd      #1
                    std       pcnt,u
                    ldy       pptr,u
                    ldd       ,y++
                    sty       pptr,u
                    tfr       d,y
                    ldx       #VS1053.Base
                    lda       tmp,u
                    lbsr      SCIWrite
                    lbcs      lpfail
                    lbra      lpcp1
lpdone              andcc     #^Carry
                    rts
lpfail              orcc      #Carry
                    rts

********************************************************************
* Output helpers - all write to the path in path,u (1 = stdout, 2 = stderr).  With quiet,u set
* (-s without -d) stdout is dropped here, so the stream code stays as written and the error
* paths, which switch path,u to stderr first, always reach the screen.
* PutStr - X = text, Y = length
PutStr              tst       quiet,u
                    beq       PutStr1
                    lda       path,u
                    cmpa      #2
                    beq       PutStr1
                    andcc     #^Carry
                    rts
PutStr1             lda       path,u
                    os9       I$Write
                    rts
* PutLine - X = text, Y = length, then end the line
PutLine             lbsr      PutStr
* PutCR - end the line.  I$WritLn, not I$Write: on the wildbits terminal a bare
* CR through I$Write only returns the cursor, so lines overprint each other.
PutCR               tst       quiet,u
                    beq       PutCR1
                    lda       path,u
                    cmpa      #2
                    beq       PutCR1
                    andcc     #^Carry
                    rts
PutCR1              leax      hexbuf,u
                    lda       #C$CR
                    sta       ,x
                    ldy       #1
                    lda       path,u
                    os9       I$WritLn
                    rts
* PutSecs - X = label, Y = length; prints "label N s" as a line
PutSecs             lbsr      PutStr
                    ldd       secs,u
                    lbsr      PutDec
                    leax      secmsg,pcr
                    ldy       #secmsgl
                    lbra      PutLine
* PutRes - D = value read, exp,u = expected: "$vvvv  OK" or "$vvvv  BAD (expect $eeee)"
PutRes              pshs      d
                    lbsr      PutDollar4
                    ldd       ,s
                    cmpd      exp,u
                    bne       pr1@
                    leax      okmsg,pcr
                    ldy       #okmsgl
                    lbsr      PutStr
                    puls      d,pc
pr1@                leax      badmsg,pcr
                    ldy       #badmsgl
                    lbsr      PutStr
                    ldd       exp,u
                    lbsr      PutHex4
                    leax      rparen,pcr
                    ldy       #1
                    lbsr      PutStr
                    puls      d,pc
* PutDollar4 - "$" + D as four hex digits (no CR); D preserved
PutDollar4          pshs      d
                    leax      hexbuf,u
                    lda       #'$
                    sta       ,x+
                    lda       ,s
                    lbsr      HexByte
                    lda       1,s
                    lbsr      HexByte
                    leax      hexbuf,u
                    ldy       #5
                    lbsr      PutStr
                    puls      d,pc
* PutHex4 - D as four hex digits (no CR); D preserved
PutHex4             pshs      d
                    leax      hexbuf,u
                    lda       ,s
                    lbsr      HexByte
                    lda       1,s
                    lbsr      HexByte
                    leax      hexbuf,u
                    ldy       #4
                    lbsr      PutStr
                    puls      d,pc
* PutHex2 - A as two hex digits (no CR)
PutHex2             pshs      d
                    leax      hexbuf,u
                    lbsr      HexByte
                    leax      hexbuf,u
                    ldy       #2
                    lbsr      PutStr
                    puls      d,pc
* PutDec - D (0..65535) in decimal, no leading zeros
PutDec              pshs      d
                    leax      hexbuf,u
                    ldd       #10000
                    std       tmp,u
                    ldd       ,s
                    lbsr      DecDigit
                    pshs      d
                    ldd       #1000
                    std       tmp,u
                    puls      d
                    lbsr      DecDigit
                    pshs      d
                    ldd       #100
                    std       tmp,u
                    puls      d
                    lbsr      DecDigit
                    pshs      d
                    ldd       #10
                    std       tmp,u
                    puls      d
                    lbsr      DecDigit
                    addb      #'0
                    stb       ,x+
                    leax      hexbuf,u
                    ldy       #5
pd1@                cmpy      #1
                    beq       pd9@
                    lda       ,x
                    cmpa      #'0
                    bne       pd9@
                    leax      1,x
                    leay      -1,y
                    bra       pd1@
pd9@                lbsr      PutStr
                    puls      d,pc
* DecDigit - D = value, tmp,u = divisor: one ASCII digit at X (advanced); D = remainder
DecDigit            pshs      d
                    lda       #'0-1
                    sta       ,x
                    puls      d
dd1@                inc       ,x
                    subd      tmp,u
                    bcc       dd1@
                    addd      tmp,u
                    leax      1,x
                    rts

* HexByte - A as two hex digits at X, X advanced by 2.
HexByte             pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    lbsr      HexNib
                    puls      a
                    anda      #$0F
* HexNib - low nibble of A as one hex digit at X, X advanced.
HexNib              adda      #'0
                    cmpa      #'9
                    bls       hn@
                    adda      #7
hn@                 sta       ,x+
                    rts

                    emod
eom                 equ       *
                    end
