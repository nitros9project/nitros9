                    ifp1
                    use       defsfile
                    endc

ty                  set       Prgrm+Objct
at                  set       ReEnt+rev
rev                 set       0
                    mod       eom,name,ty,at,start,size
                    org       0
filepath            rmb       1
wzpath              rmb       1
savedcom            rmb       2                   /wz SS.ComSt type/baud word, restored at exit
tapms               rmb       2                   reset tap length in ms (wizupdate ### file)
tapticks            rmb       2                   the same in 60 Hz ticks, rounded up
blocknum            rmb       1
crcmode             rmb       1
tries               rmb       1
seconds             rmb       1
lastsec             rmb       1
checksum            rmb       1
crch                rmb       1
crcl                rmb       1
iobyte              rmb       1
started             rmb       1
resetcap            rmb       1
timebuf             rmb       6
escbuf              rmb       ESCCHUNK            ESC bytes for the stream
packet              rmb       133
size                equ       .+512
name                fcs       /wizupdate/
                    fcb       3

* The transfer runs through /wz (the raw WizFi device): SS.ComSt sets 115,200, I$Write sends, SS.Ready and
* I$Read receive. The driver has no reset call, so the chip reset and the FIFO flush use the WizFi reset register
* directly (WizFi.HasReset reads 1 when it exists). No other process may hold /wz0-/wz3 open: their readers poll
* the same receive FIFO and would take the boot ROM's replies.
* Entry to the W600 boot ROM's download mode: ESC streams continuously; the chip reset is tapped (held for the
* tap length, default DEFTAPMS) in the middle of the stream; the stream keeps running after the release until
* the ROM answers C (CRC) or NAK.
ChipReset           equ       WizFi.Base+WizFi_ResetReg
TxWrCnt             equ       WizFi.Base+WizFi_TxD_WR_Cnt
SOH                 equ       1
EOT                 equ       4
ACK                 equ       6
NAK                 equ       $15
CAN                 equ       $18
ESC                 equ       $1B
DEFTAPMS            equ       100                 default reset tap, ms
ESCCHUNK            equ       64                  ESCs per write (5.6 ms at 115,200)
ESCLOW              equ       192                 top the TX FIFO up below this (17 ms queued: a tick's sleep)
HSSECS              equ       10                  seconds to wait for C/NAK after an automatic tap
HSMANUAL            equ       30                  seconds when the user taps the reset by hand

start               lda       #$FF
                    sta       filepath,u
                    sta       wzpath,u
                    sta       savedcom,u          $FFxx: no rate saved yet, none to restore
                    clr       started,u
                    clr       resetcap,u
                    ldd       #DEFTAPMS
                    std       tapms,u
                    leay      escbuf,u
                    ldb       #ESCCHUNK
                    lda       #ESC
esc1@               sta       ,y+
                    decb
                    bne       esc1@
                    lbsr      skipspaces
                    cmpa      #C$CR
                    lbeq      usage
* An all-digit first word followed by a space is the tap length in ms (1-9999); anything else is the file name.
                    leay      ,x
                    clra
                    clrb
                    pshs      d                   ,s = the value so far
                    clr       ,-s                 ,s = digit count  1,s = the value
num1@               ldb       ,y
                    subb      #'0
                    cmpb      #9
                    bhi       num2@               not a digit
                    inc       ,s
                    pshs      b                   ,s = the digit  1,s = count  2,s = value
                    ldd       2,s
                    lslb
                    rola                          x2
                    pshs      d
                    lslb
                    rola
                    lslb
                    rola                          x8
                    addd      ,s++                x10
                    addb      ,s+                 + the digit
                    adca      #0
                    std       1,s
                    leay      1,y
                    bra       num1@
num2@               lda       ,s+                 A = digit count
                    puls      d                   D = the value
                    tsta                          any digits?
                    beq       filename            no: a file name
                    pshs      a
                    lda       ,y
                    cmpa      #C$SPAC
                    puls      a
                    bne       filename            digits run into a name ("2file"): a file name
                    cmpa      #4
                    lbhi      usage               more than 9999
                    cmpd      #0
                    lbeq      usage
                    std       tapms,u
                    leax      ,y
                    lbsr      skipspaces
                    cmpa      #C$CR
                    lbeq      usage
filename            lda       ,x
                    cmpa      #C$CR
                    lbeq      usage
* ms -> 60 Hz ticks, rounded up: ticks = ceil(ms * 3 / 50)
                    ldd       tapms,u
                    pshs      d
                    lslb
                    rola
                    addd      ,s++                ms * 3 (at most 29,997)
                    ldy       #0
tk1@                leay      1,y
                    subd      #50
                    bhi       tk1@
                    sty       tapticks,u
                    lda       #READ.
                    os9       I$Open
                    lbcs      exiterror
                    sta       filepath,u
                    leax      wzname,pcr
                    lda       #UPDAT.
                    os9       I$Open
                    lbcs      closefile
                    sta       wzpath,u
                    ldb       #SS.ComSt
                    os9       I$GetStt            Y = the path's type/baud word
                    lbcs      fail
                    sty       savedcom,u
                    tfr       y,d
                    ldb       #WizFi.Baud115200   the boot ROM listens at 115,200 whatever AT+UART_DEF set
                    tfr       d,y
                    lda       wzpath,u
                    ldb       #SS.ComSt
                    os9       I$SetStt
                    lbcs      fail
                    lda       ChipReset
                    bita      #WizFi.HasReset
                    beq       manualreset
                    lda       #WizFi.FifoRst+WizFi.UartRst  flush both FIFOs and both serial ends
                    sta       ChipReset
                    clr       ChipReset
                    inc       resetcap,u
                    leax      tapmsg,pcr
                    lbsr      say
* The tap: the stream is already running when the reset goes on and still running when it comes off.
                    lbsr      escfill
                    lbcs      fail
                    lda       #WizFi.ChipRst
                    sta       ChipReset
tap1@               lbsr      escfill
                    lbcs      fail
                    ldx       #1
                    os9       F$Sleep             one tick (16.7 ms); the queue covers it
                    ldd       tapticks,u
                    subd      #1
                    std       tapticks,u
                    bne       tap1@
                    lbsr      escfill
                    lbcs      fail
                    clr       ChipReset           released into a running ESC stream
                    lda       #HSSECS
                    bra       bootwait
manualreset         leax      manualmsg,pcr
                    lbsr      say
                    lda       #HSMANUAL
bootwait            sta       seconds,u
                    leax      waitingmsg,pcr
                    lbsr      say
                    lbsr      getsec
                    lbcs      fail
                    sta       lastsec,u
* No sleeping here: keep the TX FIFO topped up with ESC (a continuous stream) and watch for the reply.
handshake           lbsr      escfill
                    lbcs      fail
                    lbsr      rxpoll
                    bcs       hs2@                nothing waiting
                    cmpa      #'C
                    beq       usecrc
                    cmpa      #NAK
                    beq       usesum
                    cmpa      #CAN
                    lbeq      cancelled
                    bra       handshake           anything else (boot text, ESC echo) is ignored
hs2@                lbsr      elapsed
                    lbcs      fail
                    tst       seconds,u
                    bne       handshake
                    lbra      timedout
usecrc              lda       #1
                    sta       crcmode,u
                    bra       transfer
usesum              clr       crcmode,u
* Drop the ESCs still queued so the first block starts the line, not a tail of ESCs.
transfer            tst       resetcap,u
                    beq       xfer1@
                    lda       #WizFi.FifoRst
                    sta       ChipReset
                    clr       ChipReset
xfer1@              inc       started,u
                    lda       #1
                    sta       blocknum,u
nextblock           leax      packet+3,u
                    ldy       #128
                    lda       #$1A
padloop             sta       ,x+
                    leay      -1,y
                    bne       padloop
                    leax      packet+3,u
                    ldy       #128
                    lda       filepath,u
                    os9       I$Read
                    bcc       gotblock
                    cmpb      #E$EOF
                    lbeq      sendeot
                    lbra      fail
gotblock            cmpy      #0
                    lbeq      sendeot
                    lda       #SOH
                    sta       packet,u
                    lda       blocknum,u
                    sta       packet+1,u
                    coma
                    sta       packet+2,u
                    clr       checksum,u
                    clr       crch,u
                    clr       crcl,u
                    leax      packet+3,u
                    ldy       #128
crcloop             lda       ,x+
                    pshs      a                   Stack: payload byte for checksum
                    adda      checksum,u
                    sta       checksum,u
                    puls      a
                    eora      crch,u
                    sta       crch,u
                    ldb       #8
crcbit              lsl       crcl,u
                    rol       crch,u
                    bcc       crcnext
                    lda       crch,u
                    eora      #$10
                    sta       crch,u
                    lda       crcl,u
                    eora      #$21
                    sta       crcl,u
crcnext             decb
                    bne       crcbit
                    leay      -1,y
                    bne       crcloop
* The trailer follows the 131-byte header + payload in the same buffer: CRC high/low, or the checksum.
                    tst       crcmode,u
                    beq       sumtrailer
                    lda       crch,u
                    sta       packet+131,u
                    lda       crcl,u
                    sta       packet+132,u
                    bra       trailerset
sumtrailer          lda       checksum,u
                    sta       packet+131,u
trailerset          lda       #10
                    sta       tries,u
retryblock          leax      packet,u
                    ldy       #133
                    tst       crcmode,u
                    bne       sendblock
                    ldy       #132
sendblock           lbsr      wzwrite
                    lbcs      fail
                    lbsr      waitreply
                    bcs       retrytimeout
                    cmpa      #ACK
                    beq       accepted
                    cmpa      #CAN
                    lbeq      cancelled
retrytimeout        dec       tries,u
                    bne       retryblock
                    lbra      timedout
accepted            inc       blocknum,u
                    leax      dotmsg,pcr
                    ldy       #1
                    lda       #1
                    os9       I$Write
                    lbcs      fail
                    lbra      nextblock
sendeot             lda       #10
                    sta       tries,u
eotretry            lda       #EOT
                    lbsr      transmit
                    lbcs      fail
                    lbsr      waitreply
                    bcs       eotagain
                    cmpa      #ACK
                    beq       success
                    cmpa      #CAN
                    beq       cancelled
eotagain            dec       tries,u
                    bne       eotretry
                    bra       timedout
success             leax      donemsg,pcr
                    lbsr      say
                    clrb
                    bra       cleanup
cancelled           ldb       #253                ; undefined E$Abort
                    bra       fail
timedout            ldb       #E$NotRdy
fail                pshs      b                   Stack: original failure code
                    tst       started,u
                    beq       nocancel
                    lda       #CAN
                    lbsr      transmit
                    lda       #CAN
                    lbsr      transmit
nocancel            puls      b
cleanup             pshs      b                   Stack: exit code across the closes
                    tst       resetcap,u
                    beq       resetreleased
                    clr       ChipReset
resetreleased       lda       wzpath,u
                    cmpa      #$FF
                    beq       wzclosed
                    ldb       savedcom,u
                    cmpb      #$FF
                    beq       wzclose@            the rate was never read
                    ldy       savedcom,u
                    ldb       #SS.ComSt
                    os9       I$SetStt            the rate the path had before
wzclose@            lda       wzpath,u
                    os9       I$Close
wzclosed            puls      b
closefile           pshs      b                   Stack: exit code across I$Close
                    lda       filepath,u
                    os9       I$Close
                    puls      b
exiterror           os9       F$Exit

* X/Y preserved by helpers. U always remains this module's static base.
skipspaces          lda       ,x
                    cmpa      #C$SPAC
                    bne       skipsdone
                    leax      1,x
                    bra       skipspaces
skipsdone           rts
say                 pshs      d,y
                    lda       #1
                    ldy       #256
                    os9       I$WritLn
                    puls      d,y,pc
getsec              pshs      x,b
                    leax      timebuf,u
                    os9       F$Time
                    bcs       getsecerr@          keep F$Time's error code in B
                    lda       timebuf+5,u
                    puls      b,x,pc
getsecerr@          leas      1,s                 drop the saved B
                    puls      x,pc
pause               pshs      x
                    ldx       #2                  Yield with a full tick wait; IRQs stay enabled
                    os9       F$Sleep
                    puls      x,pc
elapsed             lbsr      getsec
                    bcs       elapsedout
                    cmpa      lastsec,u
                    beq       elapsedok
                    sta       lastsec,u
                    dec       seconds,u
elapsedok           andcc     #$FE                no error: cmpa left carry set when the second wrapped 59 -> 0
elapsedout          rts
* escfill: top the TX FIFO up with ESCCHUNK more ESCs whenever fewer than ESCLOW are queued (read-only
* occupancy check). Carry set, B = error on a failed write. D is not preserved.
escfill             pshs      x,y
                    ldd       TxWrCnt
                    cmpd      #ESCLOW
                    bhs       ef9@
                    leax      escbuf,u
                    ldy       #ESCCHUNK
                    bsr       wzwrite
                    puls      x,y,pc
ef9@                andcc     #$FE
                    puls      x,y,pc
* transmit: A = one byte to /wz. Carry set, B = error on failure.
transmit            pshs      x,y
                    sta       iobyte,u
                    leax      iobyte,u
                    ldy       #1
                    bsr       wzwrite
                    puls      x,y,pc
* wzwrite: X = buffer, Y = byte count, to /wz. Carry set, B = error on failure.
wzwrite             pshs      a
                    lda       wzpath,u
                    os9       I$Write
                    puls      a,pc
* rxpoll: A = the next received byte, carry clear; carry set when nothing is waiting (or on an error).
rxpoll              pshs      x,y
                    lda       wzpath,u
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcs       rxp9@               E$NotRdy: nothing waiting
                    leax      iobyte,u
                    ldy       #1
                    lda       wzpath,u
                    os9       I$Read
                    bcs       rxp9@
                    lda       iobyte,u
rxp9@               puls      x,y,pc
* waitreply: A = the next byte within five seconds; carry set, B = E$NotRdy when none came.
waitreply           lda       #5
                    sta       seconds,u
                    lbsr      getsec
                    bcs       receivedout
                    sta       lastsec,u
receive             lbsr      rxpoll
                    bcc       receivedout
                    lbsr      pause
                    lbsr      elapsed
                    bcs       receivedout
                    tst       seconds,u
                    bne       receive
                    ldb       #E$NotRdy
                    orcc      #1
receivedout         rts
usage               leax      usagemsg,pcr
                    lbsr      say
                    ldb       #E$BPNam
                    os9       F$Exit
wzname              fcc       '/wz'
                    fcb       C$CR
usagemsg            fcc       'Usage: wizupdate [ms] firmware.img  (reset tap ms, default 100;'
                    fcb       C$LF
                    fcc       '       close /wz0-/wz3 first)'
                    fcb       C$CR
tapmsg              fcc       'Tapping the WizFi reset inside an ESC stream...'
                    fcb       C$CR
manualmsg           fcc       'No chip-reset register: tap the WizFi reset by hand now (ESC streaming).'
                    fcb       C$CR
waitingmsg          fcc       'Waiting for XMODEM C/NAK at 115200 baud...'
                    fcb       C$CR
dotmsg              fcc       '.'
donemsg             fcb       C$CR
                    fcc       'XMODEM upload acknowledged.'
                    fcb       C$CR
                    emod
eom                 equ       *
                    end
