********************************************************************
* 
* 
* 
* 
* 
* iss - by Matt Massie
* 
*
* ISS tracker for NitrOS-9 using WizFi360.
*
* connects to api.open-notify.org, requests iss-now.json,
* pulls latitude/longitude out of the JSON body, and prints them to
* stdout in a loop every ~5 seconds. 
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* started  2026/07/29 - 2026/08/25
* rev 1    2026/07/29  first working lat/lon console version
* rev 9    2026/07/30  added -v (verbose) option. By default
*                      the program now prints ONLY the coordinates; all
*                      the WizFi comms chatter (opening/connecting/
*                      sending/waiting banners and the raw /wz response
*                      dump) is suppressed. Run "iss -v" to see the full
*                      diagnostic trace. Gating is central: Diag and
*                      EchoAll both check <verbose, so every banner and
*                      the raw echo are silenced together. Genuine errors
*                      (comms failure, no-fix, cannot-open) still show.
* rev 10   2026/08/25  plot the ISS on the map. New PlotISS
*                      converts the whole-degree part of Lat/Lon into a
*                      sprite position and calls SPPos each good fix:
*                      X = 192 + longitude, Y = 152 - latitude (1 px per
*                      degree, sprite centre 192,152). New ParseInt turns
*                      the ASCII value (e.g. "-51.3821") into a signed
*                      integer, stopping at the '.'. Scratch IntAcc/
*                      IntSign added; X/Y are >255 into the data area so
*                      they use >X,u like SPPos does.
* rev 11   2026/08/25  latitude stuck at one value while
*                      longitude tracked fine. DoReceive reuses RBuffer
*                      without clearing it; when the byte-at-a-time parse
*                      fired the instant longitude (first in this API's
*                      JSON) completed, the latitude value (second) was
*                      still mid-arrival, so ExtractVal ran off the fresh
*                      bytes into the PREVIOUS cycle's leftovers and
*                      returned the old latitude - which then propagated
*                      cycle after cycle. Fix: zero RBuffer at the start
*                      of every DoReceive; ExtractVal stops at a NUL, so a
*                      value is now accepted only once its own closing
*                      quote has actually arrived.
* rev 12   2026/08/25  added -m2 option to select the second
*                      background map (/dd/sys/backgrounds/clutworldmap2)
*                      instead of the default clutworldmap. New map2 flag
*                      set by ParseOpts (which now keeps scanning so -v
*                      and -m2 can be combined in any order); DoPixV picks
*                      PIXON vs PIXON2 from it. Default (no -m2) unchanged.
* rev 13   2026/08/25  Maps physical block $C1, copies
*                      /dd/sys/backgrounds/xtclutnomod into mapped+$1400
*                      ($400 bytes) with one I$Read, then unmaps - the
*                      dpoke word-poke loop is just a byte copy. Called
*                      from Start after DoPixV. 
* rev 14   2026/08/25  longitude now spans the full 320-px map.
*                      Was 1 deg = 1 px (360 px, wider than the screen);
*                      new ScaleLon multiplies longitude by 8/9 (320/360)
*                      so +/-180 maps to screen 0..320 (0 -> 160 centre).
*                      PlotISS runs longitude through ScaleLon before the
*                      176 centre add. Latitude left at 1 deg = 1 px.
* ------------------------------------------------------------------


                    nam       iss
                    ttl       ISS tracker for NitrOS-9 using WizFi360

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

* Standard I/O path numbers (inherited from the shell, never opened)
StdIn               equ       0
StdOut              equ       1

RBufSize            equ       600         Room for headers + JSON body
ReadChunk           equ       256         Max bytes per I$Read (driver packet size)

* --------------------------------------------------------------
* Process data area (addressed via U; small scalars use direct
* page "<name" addressing, buffers use ",u" indexed addressing -
* same convention as ntptime.asm)
* --------------------------------------------------------------
PathNum             rmb       1           /wz path number
BytesCnt            rmb       2           bytes returned by last I$Read
Total               rmb       2           bytes accumulated in RBuffer
timeout             rmb       1           seconds to wait for /wz ready
d.time1             rmb       6           F$Time snapshot (start)
d.time2             rmb       6           F$Time snapshot (now)
BufPtr              rmb       2           scan pointer for pattern search
BufLeft             rmb       2           bytes remaining to scan
PatPtr              rmb       2           pointer to pattern being sought
PatLen              rmb       1           length of that pattern
LatLen              rmb       1           length of extracted latitude text
LonLen              rmb       1           length of extracted longitude text
Quit                rmb       1           nonzero -> exit main loop
verbose             rmb       1           nonzero -> show comms diagnostics (-v)
map2                rmb       1           nonzero -> use second map (-m2)
KeyBuf              rmb       1           single keypress byte
Retry               rmb       1           not-ready retry counter (DoReceive)
IntAcc              rmb       2           ParseInt running value
IntSign             rmb       1           ParseInt sign (0=+, $FF=-)
LatBuf              rmb       16          extracted latitude text
LonBuf              rmb       16          extracted longitude text
pxlblk0             rmb       1
pxlblk              rmb       1
pxlblkaddr          rmb       2
bmblock             rmb       1           bitmap block#
mapaddr             rmb       2
mapaddr2            rmb       2
blkCnt              rmb       1
currPath            rmb       1
offset2             rmb       2
enable              rmb       2
layer               rmb       2
lut                 rmb       2
ssize               rmb       2 
RBuffer             rmb       RBufSize    accumulated HTTP response
mapaddr3            rmb       2           mapped address
offset              rmb       2           calc offset
clutmap             rmb       2           LoadClut mapped block address
clutpath            rmb       1           LoadClut open file path
X                   rmb       2           ISS X
LastX               rmb       2           ISS last X
Y                   rmb       2           ISS Y
LastY               rmb       2           ISS last Y
                    rmb       250         stack space
size                equ       .

                    mod       eom,name,tylg,atrv,start,size

name                fcs       /iss/
                    fcb       edition

* ================================================================
* Start
* ================================================================
Start               lbsr      ParseOpts    scan command line for -v (X = params) 
		            clr	      <pxlblk
                    clr       <pxlblk0     high byte of 16-bit block for ldx <pxlblk0
		            clr       <pxlblkaddr
		            clr	      <pxlblkaddr+1
		            clr	      <bmblock
                    clr       <Quit
                    lbsr      cursoroff
                    lda       #$01         stdout        
                    leax      ScrnInit,pcr 80x60 screen init  
                    ldy       #ScrnInitLen
                    os9       I$Write
                    lda       #$0C         clear screen
                    lbsr      byte1scrn
                    lbsr      SPCreate     setup sprites
                    lbsr      DoPixV       draw map background
                    lbsr      LoadClut     load sprite colour lookup table
                    ldx       #$3F         bitmap, text, sprites
                    ldy       #%11111111   dont change FFC1
                    lda       #0           stdin
                    ldb       #SS.DScrn    display screen with new settings
                    os9       I$SetStt     turn on graphics
                    lda       #30
                    ldb       #1
                    lbsr      CurXY
                    lbsr      nitroslbl
                    leax      ISSTtl,pcr   ISS title banner
                    ldy       #ISSTtlLen   length title
                    lda       #1           stdout
                    os9       I$Write
                    tst       <map2          which background?
                    beq       skip@
                    lda       #2             map2 use black font
                    ldb       #6
                    lbsr      Color
skip@               lda       #18
                    ldb       #58
                    lbsr      CurXY
                    leax      ISSData,pcr  waiting for fata
                    ldy       #ISSDataLen  length 
                    lda       #1           stdout
                    os9       I$Write
                    tst       <map2          which background?
                    beq       skip2@
                    lda       #1             map2 use black font
                    ldb       #6
                    lbsr      Color
skip2@              clrb
                    lda       #5
                    sta       <timeout
                    lda       2
                    ldb       3
                    lbsr      CurXY
                    leax      MsgOpen,pcr  diagnostic: "opening /wz connection"
                    ldy       #MsgOpenLen
                    lbsr      Print

                    leax      DevName,pcr  Point to /wz device name
                    lda       #UPDAT.      Update mode
                    os9       I$Open       Open /wz device
                    lbcs      Error        Fatal - no device, no point continuing
                    sta       <PathNum     Save path number

* ----------------------------------------------------------------
* Main polling loop
* ----------------------------------------------------------------
MainLoop            lbsr      DoConnect
                    lbcs      CommErr
                    lbsr      DoSend
                    lbcs      CommErr
                    lbsr      DoReceive    reads /wz directly, parses as it goes
                    bcs       ParseFail    carry set = never got both coordinates
                    lbsr      redottl      make sure we keep scrn fresh - no error after update
                    lbsr      DisplayResult
                    lbsr      PlotISS      move the ISS sprite to lat/lon
                    bra       AfterDisplay
ParseFail           lbsr      DisplayNoFix
AfterDisplay        lbsr      DoClose

                    lbsr      CheckKey
                    lda       <Quit
                    lbne      Done

                    ldx       #$012C       ~5 seconds @ 60Hz
                    os9       F$Sleep
                    lbra      MainLoop

* Communications hiccup mid-cycle: report it, pause, and just try
* the whole cycle again rather than dying outright.
CommErr             lda       #StdOut
                    leax      CommErrMsg,pcr
                    ldy       #CommErrLen
                    os9       I$WritLn
                    ldx       #$0258       ~10 seconds @ 60Hz
                    os9       F$Sleep
                    lbsr      CheckKey
                    lda       <Quit
                    lbne      Done
                    lbra      MainLoop

Done                lda       <PathNum
                    os9       I$Close
                    lbsr      cursoron
                    lda       #$0C         clear screen
                    lbsr      byte1scrn
                    lbsr      DoPixVoff
                    clrb
                    os9       F$Exit

* Fatal error opening /wz - nothing we can do without it
Error               lda       #StdOut
                    leax      OpenErrMsg,pcr
                    ldy       #OpenErrLen
                    os9       I$WritLn
                    os9       F$Exit

* ================================================================
* DoConnect - open the TCP socket to api.open-notify.org:80
* Returns carry set on communications error
* ================================================================
DoConnect           lda       #5
                    sta       <timeout
                    leax      MsgConn,pcr  diagnostic: "connecting..."
                    ldy       #MsgConnLen
                    lbsr      Diag
                    lda       <PathNum
                    leax      ATConnect,pcr
                    ldy       #ATConnectLen
                    os9       I$Write
                    bcs       dc.err@
                    lbsr      WaitOK
                    bcs       dc.err@
                    andcc     #$FE
                    rts
dc.err@             orcc      #$01
                    rts

* ================================================================
* DoSend - send AT+CIPSEND, wait for its OK, then send the raw
* HTTP GET request, waiting for OK/SEND OK after that too
* ================================================================
DoSend              lda       #5
                    sta       <timeout
                    lda       <PathNum
                    leax      ATSend,pcr
                    ldy       #ATSendLen
                    os9       I$Write
                    bcs       ds.err
                    lbsr      WaitOK       CIPSEND replies "OK\r\n>" - wait for it
                    bcs       ds.err

                    leax      MsgHdr,pcr   diagnostic: "sending header"
                    ldy       #MsgHdrLen
                    lbsr      Diag

                    lda       <PathNum
                    leax      HTTPRequest,pcr
                    ldy       #HTTPLen
                    os9       I$Write
                    bcs       ds.err
* IMPORTANT: no WaitOK here. The old second WaitOK read a chunk from
* /wz that contained "SEND OK" AND the server's +IPD/JSON, found "OK",
* and returned - then DoAccumulate reset Total=0 and read again,
* capturing nothing, so ParseLatLon saw 0 bytes. Letting DoAccumulate
* do all the reading captures the whole response (SEND OK + IPD + JSON)
* with a correct Total.
                    andcc     #$FE
                    rts
ds.err              orcc      #$01
                    rts

* ================================================================
* ReadWz - poll SS.Ready (up to <timeout> seconds) then I$Read into
* RBuffer (offset 0). Exit: carry set on timeout/error; <BytesCnt =
* bytes read. Same pattern as www.asm's proven ReadWz.
* ================================================================
ReadWz              lbsr      WaitReady
                    bcs       rw.ret@
                    lda       <PathNum
                    leax      RBuffer,u
                    ldy       #ReadChunk
                    os9       I$Read
                    bcs       rw.ret@
                    sty       <BytesCnt
                    andcc     #$FE
rw.ret@             rts

* ================================================================
* WaitOK - keep reading until "OK" or "ERROR" shows up anywhere in
* the response (not just a single opportunistic read). Matches the
* proven pattern from www.asm. Carry clear = OK seen, carry set =
* ERROR seen or timeout.
* ================================================================
WaitOK              lbsr      ReadWz
                    bcs       wok.ret@         timeout - real error
                    lbsr      CheckOKAnywhere
                    bcc       wok.ret@         OK found - success
                    lbsr      CheckErrAnywhere
                    bcc       wok.err@         ERROR found - real error
                    bra       WaitOK           neither yet - keep polling
wok.err@            orcc      #$01
wok.ret@            rts

* CheckOKAnywhere / CheckErrAnywhere - scan RBuffer[0..BytesCnt) for
* the substring "OK" / "ERROR" anywhere, not just at the tail.
CheckOKAnywhere     leax      RBuffer,u
                    ldy       <BytesCnt
coa.loop@           cmpy      #2
                    blo       coa.nf@
                    lda       ,x
                    cmpa      #'O'
                    bne       coa.next@
                    lda       1,x
                    cmpa      #'K'
                    beq       coa.found@
coa.next@           leax      1,x
                    leay      -1,y
                    bra       coa.loop@
coa.found@          andcc     #$FE
                    rts
coa.nf@             orcc      #$01
                    rts

CheckErrAnywhere    leax      RBuffer,u
                    ldy       <BytesCnt
cea.loop@           cmpy      #5
                    blo       cea.nf@
                    lda       ,x
                    cmpa      #'E'
                    bne       cea.next@
                    lda       1,x
                    cmpa      #'R'
                    bne       cea.next@
                    lda       2,x
                    cmpa      #'R'
                    bne       cea.next@
                    lda       3,x
                    cmpa      #'O'
                    bne       cea.next@
                    lda       4,x
                    cmpa      #'R'
                    beq       cea.found@
cea.next@           leax      1,x
                    leay      -1,y
                    bra       cea.loop@
cea.found@          andcc     #$FE
                    rts
cea.nf@             orcc      #$01
                    rts

* ================================================================
* DoClose - politely close the TCP socket
* ================================================================
DoClose             lda       #5
                    sta       <timeout
                    leax      MsgClose,pcr diagnostic: "done, closing"
                    ldy       #MsgCloseLen
                    lbsr      Diag
                    lda       <PathNum
                    leax      ATClose,pcr
                    ldy       #ATCloseLen
                    os9       I$Write
                    bcs       dcl.x@
                    lbsr      WaitOK       ignore result - best effort close
dcl.x@              rts

* ================================================================
* DoReceive - read the response one byte at a time.
*
* /wz hands data back in LINE mode: a normal I$Read returns at the
* next $0D. That is fine for the CR-terminated AT preamble and HTTP
* headers, but the JSON body is a single line with NO trailing $0D,
* so a multi-byte I$Read blocks forever waiting for a carriage return
* that never comes - which is where earlier builds stalled, right at
* the part that holds the coordinates.
*
* The cure: read ONE byte per I$Read. A 1-byte request reaches its
* count on the very first character, so it can never wait for a CR,
* and it reads straight through the unterminated JSON. Each read is
* gated by SS.Ready so we never block once the buffer drains; when the
* device goes quiet we try to parse, and finish as soon as both
* coordinates are in hand (or after a short quiet timeout).
*
* Exit: carry clear = both coordinates parsed; carry set = gave up.
* ================================================================
DoReceive           leax      MsgResp,pcr        "--- raw /wz response ---"
                    ldy       #MsgRespLen
                    lbsr      Diag
* Wipe RBuffer before each cycle. ExtractVal stops at a NUL, so a
* zeroed buffer is a hard boundary: a value is accepted only once its
* OWN closing quote has arrived. Without this, when the parse fired
* while the (second) latitude value was still mid-arrival, ExtractVal
* ran on into the PREVIOUS cycle's leftover bytes and returned the old
* latitude - which then propagated forever ("latitude stuck at one
* value while longitude tracked fine").
                    leax      RBuffer,u
                    ldd       #0
                    ldy       #RBufSize/2        clear 600 bytes as 300 words
dr.clr@             std       ,x++
                    leay      -1,y
                    bne       dr.clr@
                    ldd       #0
                    std       <Total
                    lda       #30                ~5s of patience (refills on data)
                    sta       <Retry
                    leax      MsgWait,pcr        "waiting for /wz..."
                    ldy       #MsgWaitLen
                    lbsr      Diag
dr.loop@            lda       <PathNum           is a byte available?
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcc       dr.rd1@            yes - read it
* device quiet: maybe the whole reply is in - try to parse it
                    lbsr      ParseLatLon
                    lbcc      dr.ok@             got both coordinates
                    dec       <Retry             not yet - wait a little for more
                    lbeq      dr.done@
                    ldx       #10
                    os9       F$Sleep
                    bra       dr.loop@
dr.rd1@             ldd       #RBufSize          room left?
                    subd      <Total
                    lbeq      dr.done@           buffer full - stop
                    leax      RBuffer,u
                    ldd       <Total
                    leax      d,x                X = RBuffer + Total
                    lda       <PathNum           path LAST (ldd above clobbers A)
                    ldy       #1                 ONE byte - never waits for a CR
                    os9       I$Read
                    bcs       dr.loop@           transient - re-poll
                    cmpy      #0
                    beq       dr.loop@
                    ldd       <Total             accepted one byte
                    addd      #1
                    std       <Total
                    lda       #30                progress - refill patience
                    sta       <Retry
                    bra       dr.loop@
* out of patience or buffer full: final parse, then report
dr.done@            lbsr      ParseLatLon
                    lbcc      dr.ok@
                    lbsr      EchoAll            show what we captured
                    ldd       <Total
                    lbne      dr.fail@
                    leax      MsgNoData,pcr      never read a single byte
                    ldy       #MsgNoDataLen
                    lbsr      Diag
dr.fail@            orcc      #$01
                    rts
dr.ok@              lbsr      EchoAll            echo the raw response, then done
                    andcc     #$FE
                    rts

* ================================================================
* EchoAll - dump the captured response RBuffer[0..Total) to StdOut so
* you can see exactly what /wz returned (headers + JSON). One write.
* ================================================================
EchoAll             tst       <verbose           quiet mode: no raw dump
                    beq       ea.x@
                    ldd       <Total
                    beq       ea.x@
                    tfr       d,y
                    lda       #StdOut
                    leax      RBuffer,u
                    os9       I$Write
ea.x@               rts

* ================================================================
* WaitReady - waits up to <timeout> seconds for /wz to have data
* ready. Carry clear = ready, carry set = timeout.
* ================================================================
WaitReady           leax      d.time1,u
                    os9       F$Time
wr.loop@            lda       <PathNum
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcc       wr.ready@
                    leax      d.time2,u
                    os9       F$Time
                    ldb       5,x
                    leax      d.time1,u
                    subb      5,x
                    bpl       wr.a@
                    negb
wr.a@               cmpb      <timeout
                    blo       wr.loop@
                    orcc      #$01
                    rts
wr.ready@           andcc     #$FE
                    rts

* ================================================================
* ParseLatLon - scan RBuffer (Total bytes) for the latitude and
* longitude values. Carry clear + LatLen/LonLen nonzero = success.
* ================================================================
ParseLatLon         leax      RBuffer,u
                    stx       <BufPtr
                    ldd       <Total
                    std       <BufLeft
                    leax      LatPattern,pcr
                    stx       <PatPtr
                    lda       #LatPatLen
                    sta       <PatLen
                    lbsr      SearchPat
                    bcs       pl.nolat@
                    ldx       <BufPtr
                    leay      LatBuf,u
                    lbsr      ExtractVal
                    bcs       pl.nolat@    value truncated - not complete yet
                    sta       <LatLen
                    bra       pl.findlon
pl.nolat@           clr       <LatLen

pl.findlon          leax      RBuffer,u
                    stx       <BufPtr
                    ldd       <Total
                    std       <BufLeft
                    leax      LonPattern,pcr
                    stx       <PatPtr
                    lda       #LonPatLen
                    sta       <PatLen
                    lbsr      SearchPat
                    bcs       pl.nolon@
                    ldx       <BufPtr
                    leay      LonBuf,u
                    lbsr      ExtractVal
                    bcs       pl.nolon@    value truncated - not complete yet
                    sta       <LonLen
                    bra       pl.done
pl.nolon@           clr       <LonLen

pl.done             lda       <LatLen
                    beq       pl.fail@
                    lda       <LonLen
                    beq       pl.fail@
                    andcc     #$FE
                    rts
pl.fail@            orcc      #$01
                    rts

* ================================================================
* SearchPat - looks for the PatLen bytes at PatPtr somewhere in the
* next BufLeft bytes starting at BufPtr. On match, BufPtr is left
* pointing just past the matched pattern (i.e. at the value) and
* carry is clear. On no match, carry is set.
* ================================================================
SearchPat           ldd       <BufLeft
                    beq       sp.notfound@
                    ldx       <BufPtr
                    ldy       <PatPtr
                    ldb       <PatLen
sp.cmp@             lda       ,x+
                    cmpa      ,y+
                    bne       sp.nomatch@
                    decb
                    bne       sp.cmp@
                    stx       <BufPtr
                    andcc     #$FE
                    rts
sp.nomatch@         ldx       <BufPtr
                    leax      1,x
                    stx       <BufPtr
                    ldd       <BufLeft
                    subd      #1
                    std       <BufLeft
                    lbra      SearchPat
sp.notfound@        orcc      #$01
                    rts

* ================================================================
* ExtractVal - copies bytes from X into the buffer at Y until a closing
* double-quote, capped at 15 bytes. Returns count in A.
* Carry clear = a real closing quote was found (value is complete).
* Carry set   = hit a null or the 15-byte cap first, i.e. the value is
*               truncated / the rest of the packet hasn't arrived yet.
* This lets DoReceive avoid "parsing" a half-received number.
* ================================================================
ExtractVal          clra
ev.loop@            ldb       ,x+
                    cmpb      #$22         closing quote?
                    beq       ev.done@     complete value
                    tstb
                    beq       ev.trunc@    null -> truncated
                    stb       ,y+
                    inca
                    cmpa      #15
                    blo       ev.loop@
ev.trunc@           orcc      #$01         no closing quote yet
                    rts
ev.done@            andcc     #$FE         found closing quote
                    rts

* ================================================================
* DisplayResult - prints "Latitude: xx   Longitude: yy"
* ================================================================
DisplayResult       tst       <map2          which background?
                    beq       dispres
                    lda       #2             map2 use black font
                    ldb       #6
                    lbsr      Color
dispres             lda       #18
                    ldb       #58
                    lbsr      CurXY
                    lda       #StdOut
                    leax      MsgLat,pcr
                    ldy       #MsgLatLen
                    os9       I$Write

                    leax      LatBuf,u
                    clra
                    ldb       <LatLen
                    tfr       d,y
                    lda       #StdOut
                    os9       I$Write

                    lda       #StdOut
                    leax      MsgLon,pcr
                    ldy       #MsgLonLen
                    os9       I$Write

                    leax      LonBuf,u
                    clra
                    ldb       <LonLen
                    tfr       d,y
                    lda       #StdOut
                    os9       I$Write

                    lda       #StdOut
                    leax      CRLF,pcr
                    ldy       #2
                    os9       I$Write
                    lda       #18
                    ldb       #58
                    lbsr      CurXY          position for error line
                    tst       <map2          which background?
                    beq       done@
                    lda       #1
                    ldb       #6
                    lbsr      Color
done@               rts

* ================================================================
* PlotISS - turn the parsed Lat/Lon into a screen position for the
* ISS sprite and hand it to SPPos.
*
* The map is an equirectangular 320x240 view. Screen centre (0N,0E)
* is (160,120); the 32-px sprite is placed by its top-left corner, so
* the centre offset is (176,136) = (160-16, 120-16 + ...) tuned to the
* map. Longitude is now SCALED so the full 360 degrees spans the
* 320-px width (320/360 = 8/9 px per degree):
*
*     sprite X = 176 + longitude * 8 / 9   (east -> right, west -> left)
*     sprite Y = 136 - latitude            (north -> up,  south -> down)
*
* Longitude is scaled by ScaleLon then added. Latitude is SUBTRACTED
* because screen-Y grows downward while latitude grows upward (north);
* it is still 1 deg = 1 px, which keeps the ISS (lat < ~+/-52) on
* screen. If your map wants matching vertical scale, run the latitude
* through ScaleLon too (it multiplies by 8/9 as well).
*
* Only the whole-degree part is used - ParseInt stops at the '.'.
* Call this only after a good fix, when LatBuf/LonBuf are valid.
* ================================================================
PlotISS             leax      LonBuf,u         longitude ASCII text
                    lbsr      ParseInt         D = signed whole degrees
                    lbsr      ScaleLon         360 deg -> 320 px  (lon * 8/9)
                    addd      #176             X = centre(176) + scaled longitude
                    std       >X,u

                    leax      LatBuf,u         latitude ASCII text
                    lbsr      ParseInt         D = signed whole degrees
* Y = 152 - latitude. Negating D is coma/comb/+1, folded into +153
* here (152 - lat == (NOT lat) + 153). For a flipped map, replace
* these three lines with:  addd #152 / std >Y,u
                    coma
                    comb
                    addd      #137             D = 152 - latitude
                    std       >Y,u
                    lbsr      SPPos            position sprite 0 at X,Y
                    ldd       >LastX,u         get X 
                    subd      #24              sprite pixel shift
cont@               tfr       d,x
                    ldd       >LastY,u         get Y
                    subd      #24              sprite pixel shift
                    tfr       d,y
                    lda       #255             breadcrump color
                    lbsr      writepixel
                    ldd       >X,u             snapshot last values
                    std       >LastX,u
                    ldd       >Y,u
                    std       >LastY,u
skip@               rts

* ================================================================
* ScaleLon - map a signed longitude (D = whole degrees, -180..+180)
* to a signed pixel offset so the whole 360 degrees spans the 320-px
* map:  offset = round(lon * 320 / 360) = round(lon * 8 / 9).
* Sign is handled (divide-by-repeated-subtraction only works on the
* magnitude). Returns the signed offset in D.
*   lon=0 -> 0,  lon=+180 -> +160,  lon=-180 -> -160
* (The same 8/9 scale suits latitude too, if you want to call it there.)
* ================================================================
ScaleLon            cmpd      #0               which sign is the longitude?
                    pshs      cc               stash it across the maths
                    bpl       sl.mul@
                    coma                        D = |lon|  (16-bit negate)
                    comb
                    addd      #1
sl.mul@             lslb                        |lon| * 2
                    rola
                    lslb                        * 4
                    rola
                    lslb                        * 8
                    rola                        D = |lon| * 8
                    addd      #4               + half the divisor (round to nearest)
* --- divide D by 9 by repeated subtraction; quotient -> X ---
                    ldx       #0
sl.div@             cmpd      #9
                    blo       sl.done@
                    subd      #9
                    leax      1,x
                    bra       sl.div@
sl.done@            tfr       x,d              D = |lon| * 8 / 9
                    puls      cc               recover the original sign
                    bpl       sl.ret@          longitude was >= 0
                    coma                        re-apply the minus
                    comb
                    addd      #1
sl.ret@             rts

* ================================================================
* ParseInt - parse the signed whole-number part of an ASCII decimal
* string at X (e.g. "-51.3821" -> -51, "4.8271" -> 4). Reads an
* optional leading '-', then digits, stopping at the first non-digit
* (the '.', the closing quote, a CR, whatever). Returns the signed
* value in D. Uses <IntAcc / <IntSign scratch.
* ================================================================
ParseInt            clr       <IntSign         assume positive
                    ldd       #0
                    std       <IntAcc          running value = 0
                    lda       ,x               peek first character
                    cmpa      #'-              leading minus sign?
                    bne       pin.loop@
                    com       <IntSign         remember negative ($FF)
                    leax      1,x              step past the '-'
pin.loop@           lda       ,x+              next character
                    cmpa      #'0
                    blo       pin.done@        '.', '"', CR ... -> end of integer
                    cmpa      #'9
                    bhi       pin.done@        not a digit -> end
                    suba      #'0              ASCII -> 0..9
                    pshs      a                stash the digit
* IntAcc = IntAcc * 10   (IntAcc*8 + IntAcc*2)
                    ldd       <IntAcc
                    lslb
                    rola                       D = IntAcc * 2
                    pshs      d                keep the *2
                    lslb
                    rola
                    lslb
                    rola                       D = IntAcc * 8
                    addd      ,s++             D = *8 + *2 = *10
                    std       <IntAcc
* IntAcc = IntAcc + digit
                    puls      a                recover the digit
                    tfr       a,b
                    clra                       D = 0:digit
                    addd      <IntAcc
                    std       <IntAcc
                    bra       pin.loop@
pin.done@           ldd       <IntAcc          D = magnitude
                    tst       <IntSign
                    beq       pin.ret@         positive - done
                    coma                       apply the leading '-'
                    comb
                    addd      #1
pin.ret@            rts

DisplayNoFix        lda       #StdOut
                    leax      NoFixMsg,pcr
                    ldy       #NoFixLen
                    os9       I$WritLn
                    rts

* ================================================================
* CheckKey - non-blocking check of stdin for a 'q'/'Q' keypress.
* Sets <Quit nonzero if found.
* ================================================================
CheckKey            lda       #StdIn
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcs       ck.none@    not ready - nothing typed
                    lda       #StdIn
                    leax      KeyBuf,u
                    ldy       #1
                    os9       I$Read
                    bcs       ck.none@
                    lda       KeyBuf,u
                    cmpa      #'q'
                    beq       ck.quit@
                    cmpa      #'Q'
                    bne       ck.none@
ck.quit@            lda       #1
                    sta       <Quit
ck.none@            rts

* ================================================================
* Diag - write a CR-terminated diagnostic banner to StdOut, but ONLY
* in verbose (-v) mode. In the default quiet mode it does nothing, so
* every diagnostic banner routed through Diag is suppressed at once.
* Entry: X = message pointer, Y = length.
* ================================================================
Diag                tst       <verbose
                    beq       dg.skip@
                    lda       #1
                    ldb       #3
                    lbsr      CurXY
                    lda       #StdOut
                    os9       I$WritLn
dg.skip@            rts

Print               lda       #1
                    ldb       #3
                    lbsr      CurXY
                    lda       #StdOut
                    os9       I$WritLn
                    rts

* ================================================================
* ParseOpts - scan the command-line parameters (X = param pointer at
* process entry) for -v or -V and set <verbose accordingly. The list
* is terminated by a CR, per OS-9 convention. Nothing else is an
* error - unknown options are simply ignored.
* ================================================================
ParseOpts           clr       <verbose
                    clr       <map2
po.loop@            lda       ,x+
                    cmpa      #$0D         end of parameter list
                    beq       po.done@
                    cmpa      #'-          start of an option?
                    bne       po.loop@
                    lda       ,x           letter after the dash
                    cmpa      #'v
                    beq       po.setv@
                    cmpa      #'V
                    beq       po.setv@
                    cmpa      #'m
                    beq       po.chkm@
                    cmpa      #'M
                    beq       po.chkm@
                    bra       po.loop@     unknown option - keep scanning
po.setv@            lda       #1
                    sta       <verbose
                    bra       po.loop@     keep scanning (allow -v AND -m2)
po.chkm@            lda       1,x          digit after the 'm' (want '2')
                    cmpa      #'2
                    bne       po.loop@     "-m" alone / -m1 -> leave default map
                    lda       #1
                    sta       <map2
                    bra       po.loop@
po.done@            rts

* DoPixV - fork /dd/cmds/pixview on the selected file (finalpath). pixview
* is a standalone program now: it owns the bitmap/CLUT/graphics work and
* exits when the user presses space, so the FM just forks and waits.
DoPixV              pshs      x,y,u,b,a
                    tst       <map2          which background?
                    bne       dpv.m2@
                    ldb       #PIXONLEN      map 1 (default)
                    leau      PIXON,pcr
                    bra       dpv.go@
dpv.m2@             ldb       #PIXONLEN2     map 2 (-m2)
                    leau      PIXON2,pcr
dpv.go@             clra
                    tfr       d,y            Y = parameter length
                    leax      >PIXVCMD,pcr
                    ldd       #$0100
                    os9       F$Fork
                    bcs       restorestackPV  fork failed - leave bmblock as-is
                    os9       F$Wait
                    stb       <bmblock        pixview -on returns first bitmap page in B
restorestackPV      puls      x,y,u,b,a,pc

* DoPixV - fork /dd/cmds/pixview on the selected file (finalpath). pixview
* is a standalone program now: it owns the bitmap/CLUT/graphics work and
* exits when the user presses space, so the FM just forks and waits.
DoPixVoff           pshs      x,y,u,b,a
                    clra
                    ldb       #PIXOFFLEN
                    tfr       d,y
                    leax      >PIXVCMD,pcr
                    leau      PIXOFF,pcr
                    ldd       #$0100
                    os9       F$Fork
                    bcs       restorestackP  fork failed
                    os9       F$Wait
restorestackP       puls      x,y,u,b,a,pc


********************************************************************
* CurXY
*  a = cursor x - b=cursor y
CurXY               adda      #$20                 add offset $20 to x
                    addb      #$20                 add offset $20 to y
                    pshs      a,b                  preserve x,y  (,s=x  1,s=y)
                    leas      -3,s                 reserve 3-byte buffer (,s..2,s)
                    lda       #$02                 CURXY command
                    sta       ,s                   buf[0]
                    lda       3,s                  saved x
                    sta       1,s                  buf[1]
                    lda       4,s                  saved y
                    sta       2,s                  buf[2]
                    lda       #$01                 stdout
                    ldy       #3                   send all 3 bytes at once
                    tfr       s,x
                    os9       I$Write
                    leas      3,s                  release buffer
                    puls      a,b                  restore x,y
                    rts

********************************************************************
* write 1 byte in a to screen
*
byte1scrn           leas      -1,s          reserve 1 byte for stack
                    sta       ,s
                    lda       #$01          stdout
                    ldy       #1            number of characters to print
                    tfr       s,x
                    os9       I$Write
                    leas      1,s           return stack to normal
                    rts

********************************************************************
* SPPos -  Sprite Position
*
* 
SPPos               pshs      a,b,x,y,u        Put the variables on the stack
                    ldx       #$C0             map page with sprite control reg
                    pshs      u                preserve u
                    ldb       #$01             need 1 block
                    os9       F$MapBlk         map it into process address space
                    lbcs      err@
                    exg       u,x              mapped block to x
                    puls      u
                    stx       >mapaddr3,u      mapped address
* calc offset                    
                    ldd       #0               get sprite #
                    lslb
                    rola                       
                    lslb
                    rola                       
                    lslb
                    rola                       multiply to get offset 8 bytes per sprite                    
                    std       >offset,u        save offset
                    exg       x,d              mapaddr to d
                    addd      #$1300           add offset to sprite register
                    addd      >offset,u        sprite # offset
                    exg       x,d              x = sprite # base address
                    ldd       >X,u             get x position
                    std       4,x              store x value in sprite register
                    ldd       >Y,u             get y position
                    std       6,x              store y value in sprite register
* clrblk
                    ldu       >mapaddr3,u      get mapped address
                    pshs      u                clear MapBlk from DAT Image
                    ldx       #$C0             page to unmap
                    ldb       #1               clearing 1 block
                    os9       F$ClrBlk         remove block from DAT Image
                    clrb
err@                puls      u
                    puls      u,y,x,b,a
                    rts                        return to the caller


********************************************************************
* vtio commands to control cursor/video
*
* cursoroff
* writes $0520 control code to terminal to turn off cursor
*
* cursoron
* writes $0521 control code to terminal to turn off cursor
*
cursoroff           leax      cmdcursoroff,pcr
	                ldy       #2
	                bra       engage@
cursoron            leax      cmdcursoron,pcr
	                ldy       #2
	                bra       engage@
engage@	            pshs      a
	                lda 	  #1
	                os9	      I$Write
	                puls      a,pc

cmdcursoroff        fcb	      $05,$20	  cursor off
cmdcursoron         fcb       $05,$21	  cursor on


nitroslbl           lda       #2
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
                    rts

** a=FG Color - b=BG Color
Color               pshs      a,b                  preserve FG,BG  (,s=FG  1,s=BG)
                    leas      -6,s                 reserve 6-byte buffer (,s..5,s)
                    lda       #$1B                 escape
                    sta       ,s                   buf[0]
                    lda       #$32                 foreground color option
                    sta       1,s                  buf[1]
                    lda       6,s                  saved FG
                    sta       2,s                  buf[2]
                    lda       #$1B                 escape
                    sta       3,s                  buf[3]
                    lda       #$33                 background color option
                    sta       4,s                  buf[4]
                    lda       7,s                  saved BG
                    sta       5,s                  buf[5]
                    lda       #$01                 stdout
                    ldy       #6                   send the whole sequence at once
                    tfr       s,x
                    os9       I$Write
                    leas      6,s                  release buffer
                    puls      a,b                  restore FG,BG
                    rts

********************************************************************
* write pixel
* takes X,Y and color and puts it in the bitmap bmblock
* x=X
* y=Y
* a=color
writepixel          tst       <bmblock              did pixview report a bitmap page?
                    lbeq      wpx.skip              0 = not ready, don't scribble low RAM
                    pshs      a,b,x,y,u
                    leas      -1,s                  add 1 byte to stack for carry
                    clr       ,s                    0=carry,1=color,2=y,3=X
*                   **** D = 320 * gy.
*                   **** 320 = 256 + 64, so use MUL for the lower byte,
*                   **** and then add gy (gy * 256) to the upper byte.
                    lda       6,s                   py     ; 8 bits.
                    ldb       #64
                    mul
                    adda      6,s                   py
                    ror       ,s                    <pcarry  ; Collect the carry bit.
*                   **** D += gx.
                    addd      3,s                   px     ; 16 bits.
                    ror       ,s                    <pcarry  ; Collect the carry bit.
*                   **** Stash the block ID bits.
                    pshs      a

*                   **** Move the lower 13 bits (8191) into a pointer.
                    anda      #31
                    tfr       d,x
*                   **** Restore the carry.
*                   **** This add will set/clear the carry
*                   **** based on the previously collected carry bits.
                    ldb       1,s                   carry bit 
                    addb      #192
*                   **** ror it into the top of the block bits.
                    puls      a
                    rora
*                   **** Shift the block bits to the bottom of A. 
                    lsra
                    lsra
                    lsra
                    lsra
*                   **** A now contains the relative block number,
*                   **** and X contains the block relative offset.xxxxxxxxw
                    pshs      x                   stx pixel offset
                    adda      <bmblock            add start of bitmap (from pixview) to relative
                    cmpa      <pxlblk              is this the currently mapped block?
                    beq       storepixel@         if current block, then just write the pixel
                    tst       <pxlblk              if not, check if mapped block exists, 0 if none
                    beq       mapit@              no mapped block then branch to map it
                    lbsr      fclrblk             have a mapped block, clear it
mapit@              sta       <pxlblk              store the new block we will map
                    ldx       <pxlblk0             load x with mapblock for F$MapBlk
                    ldb       #1                  map 1 block
                    pshs      u                   push u (F$MapBlk returns address in u)
                    os9       F$MapBlk            Map the block
                    lbcc      mapgood@            if successful, finish
                    puls      u,x                 error, clean up and return
                    bra       cleanup@            
mapgood@            stu       <pxlblkaddr         store the logical address
                    puls      u
storepixel@         ldd       <pxlblkaddr
                    puls      x                   pull blk relative offset
                    leax      d,x                 add in logical start of block
                    lda       1,s                 lda with the color
                    sta       ,x                  write the pixel
cleanup@            leas      1,s                 pull carry byte off stack
                    puls      a,b,x,y,u,pc        clean up stack and return
wpx.skip            rts                          bmblock not set - nothing pushed yet


********************************************************************
* fclearblk - clears block for writepixel
fclrblk             pshs      b,u
                    ldu       <pxlblkaddr
                    ldb       #1
                    os9       F$ClrBlk
                    puls      b,u,pc

redottl             lda       #$0C         clear screen
                    lbsr      byte1scrn
                    lda       #30
                    ldb       #1
                    lbsr      CurXY
                    lbsr      nitroslbl
                    leax      ISSTtl,pcr  ISS title banner
                    ldy       #ISSTtlLen   length title
                    lda       #1           stdout
                    os9       I$Write
                    clrb
                    rts

* ================================================================
* LoadClut - load the sprite colour lookup table (CLUT).
*
* Assembly of the Basic09 loadclut1 + dpoke procedures:
*   pg = $C1 : RUN WILD("MapBlk",pg,loc)     -> map block $C1
*   copy /dd/sys/backgrounds/xtclutnomod into loc+$1400 .. loc+$1800
*   RUN WILD("ClrBlk",pg,loc)                -> unmap the block
* dpoke() was just a 16-bit poke (high byte then low), so the GET/dpoke
* loop is a straight byte copy - one I$Read of $400 (1024) bytes does
* the same thing, exactly as SPLoad reads its bitmap into a mapped block.
*
* Best-effort: if the block will not map or the file will not open, it
* skips quietly rather than aborting start-up. Registers preserved.
* ================================================================
LoadClut            pshs      a,b,x,y,u        save caller registers
* --- map physical block $C1 into our address space ---
                    ldx       #$C1             CLUT block to map
                    pshs      u                preserve U (data base)
                    ldb       #$01             need 1 block
                    os9       F$MapBlk         map it in -> U = mapped address
                    lbcs      lc.mf@           map failed - just restore
                    exg       u,x              mapped address -> X
                    puls      u                restore U (data base)
                    stx       >clutmap,u       remember mapped address
* --- open the CLUT file ---
                    lda       #READ.
                    leax      CLUTFILE,pcr
                    os9       I$Open
                    bcs       lc.unmap@        no file - unmap and leave
                    sta       >clutpath,u      save path number
* --- copy $400 (1024) bytes from the file into mapped base + $1400 ---
                    lda       >clutpath,u
                    ldx       >clutmap,u
                    leax      $1400,x          destination = base + $1400
                    ldy       #$0400           1024 bytes ($1400..$1800)
                    os9       I$Read           best effort (ignore short/EOF)
                    lda       >clutpath,u
                    os9       I$Close
* --- unmap the block (CLUT data persists in the physical block) ---
lc.unmap@           ldu       >clutmap,u       mapped address
                    ldx       #$C1             block to unmap
                    ldb       #$01             1 block
                    os9       F$ClrBlk         remove from DAT image
                    puls      u,y,x,b,a        restore caller registers
                    rts
lc.mf@              puls      u                discard preserved U (nothing mapped)
                    puls      u,y,x,b,a        restore caller registers
                    rts

*** SPCreate - Create Spritesheet
*** bm is MMU page to map for Sprite - addr is the mapped address
*** $2B or lower sprites & allows bm0, bm1 to be used for bitmaps
SPCreate            ldx       #$002B           get page to map ex.
                    pshs      u                preserve u
                    ldb       #$01             need 1 block
                    os9       F$MapBlk         map it into process address space
                    lbcs      exiterr@
                    exg       u,x              mapped block to x  
                    puls      u
                    stx       <mapaddr,u         save map address
                    bra       cont@
exiterr@            puls      u                restore u
* SPLOAD
cont@               pshs      a,x,y,u          SPLoad Preserve registers
                    lda       #READ.
                    leax      SPRTFILE,pcr     file to load
                    os9       I$Open
                    lbcs      errcl@
                    sta       <currPath,u      store current path
                    clra
                    sta       <blkCnt,u        store block cnt 
                    ldd       <mapaddr,u       sprite map address
                    lda       <currPath,u      load path
                    ldx       <mapaddr,u       map address in X
                    ldy       #$2000           bytes to load
                    os9       I$Read
                    bcc       noerr@
                    cmpb      #E$EOF
                    beq       loaddone@        load done?
                    lbra      errcl@
noerr@              inc       <blkCnt,u        increment blk cnt
loaddone@           lda       <currPath,u      restore path
                    os9       I$Close
                    bcs       errcl@
errcl@              puls      u,y,x,a
* SPAssign
*** SPAssign - Assign sprite
*** 
*** Example SPCreate 2B - The memory location for MMU page 2B is $05 $60 $00
*** assing 16x16 size next offset would be $05 $61 $00
SPAssign            pshs      a,b,x,y,u        Put the variables on the stack
                    ldx       #$C0             map page with sprite control reg
                    pshs      u                preserve u
                    ldb       #$01             need 1 block
                    os9       F$MapBlk         map it into process address space
                    lbcs      err@
                    exg       u,x              mapped block to x
                    puls      u
                    stx       <mapaddr2,u       mapped address
                    ldd       #0000            get sprite #
                    lslb
                    rola                       
                    lslb
                    rola                       
                    lslb
                    rola                       multiply to get offset 8 bytes per sprite                    
                    std       <offset2,u       save offset
                    tfr       x,d              mapped addr to d
                    addd      #$1300           sprite registers offset
                    addd      <offset2,u        sprite # offset
                    tfr       d,y              y=sprite # base register
                    leax      SPRTADDR,pcr     sprite memory address
                    lda       ,x+              get first byte of 3
                    sta       1,y              store first byte memory addr  H
                    lda       ,x+              get second byte of 3
                    sta       2,y              store second byte memory addr M
                    lda       ,x+              get third byte of memory addr 
                    sta       3,y              store third byte              L
                    puls      u,y,x,b,a
*SPConfig
*** SPConfig - Configure Sprites
***
*** SIZE 0=32x32,1=24x24, 2=16x16, 3=8x8
*** LAYER 0-3
*** LUT 0-3
*** Enable 1=Enabled 0=Disabled
SPConfig            pshs      a,b,x,y,u        Put the variables on the stack
                    ldx       <mapaddr2,u
* config sprite
                    ldd       #0000            sprite #
                    lslb
                    rola                       
                    lslb
                    rola                       
                    lslb
                    rola                       multiply to get offset 8 bytes per sprite                    
                    std       <offset2,u       save offset
                    ldd       #1               sprite enable
                    std       <enable,u
                    ldd       #1                sprite clut #1
                    lslb
                    rola                       need LUT at bits 2-1, bit 0=enable
                    std       <lut,u
                    ldd       #0               sprite layer 0
                    lslb
                    rola                       
                    lslb
                    rola                       
                    lslb
                    rola                       need layer at bits 4-3
                    std       <layer,u
                    ldd       #2               sprite size 2
                    lslb
                    rola                       
                    lslb
                    rola                       
                    lslb
                    rola
                    lslb
                    rola                       need size at bits 6-5                  
                    std       <ssize,u
                    clrd                       d=0
                    addd      <enable,u        setup sprite config byte
                    addd      <lut,u
                    addd      <layer,u
                    addd      <ssize,u
                    std       $fee0
                    exg       x,d              mapaddr to d, sprite config bytes x
                    addd      #$1300           add offset to sprite register
                    addd      <offset2,u       sprite # offset
                    exg       x,d              x calculated offset, sprite config d
                    stb       ,x               store sprite config in sprite register
* clrblk
                    ldu       <mapaddr2,u       get mapped address
                    pshs      u                clear MapBlk from DAT Image
                    ldx       #$C0             page to unmap
                    ldb       #1               clearing 1 block
                    os9       F$ClrBlk         remove block from DAT Image
                    clrb
err@                puls      u
                    puls      u,y,x,b,a
* SPKill
*** SPKill - Sprite Kill - Free sprite memory
***
SPKill              ldx       <mapaddr,u       load map addr in x
                    ldy       #$2B             clear bm block
                    pshs      u                clear MapBlk from DAT Image
                    exg       x,u              put mapaddr in u
                    exg       y,x              page to clear in x
                    ldb       #$01             clearing 1 block
                    os9       F$ClrBlk         remove block from DAT Image
                    puls      u
                    clrb
                    rts                        return to the caller



* ================================================================
* Data area (code space - fixed strings/commands)
* ================================================================
DevName             fcc       "/wz"
                    fcb       $0D

* The device wants standard double-quoted params here. (iss.bas only
* writes single quotes in its own source because BASIC string literals
* can't easily embed a ", then swaps '->" byte-by-byte at send time -
* see its sendcommand() proc: "if b=39 then b=34". The wire format is
* double quotes.)
ATConnect           fcc       /AT+CIPSTART="TCP","api.open-notify.org",80/
                    fcb       $0D,$0A
ATConnectLen        equ       *-ATConnect

* NOTE: the byte count below (57) MUST match HTTPLen further down.
ATSend              fcc       /AT+CIPSEND=57/
                    fcb       $0D,$0A
ATSendLen           equ       *-ATSend

ATClose             fcc       /AT+CIPCLOSE/
                    fcb       $0D,$0A
ATCloseLen          equ       *-ATClose

HTTPRequest         fcc       "GET /iss-now.json HTTP/1.1"
                    fcb       $0D,$0A
                    fcc       "Host: api.open-notify.org"
                    fcb       $0D,$0A,$0D,$0A
HTTPLen             equ       *-HTTPRequest

LatPattern          fcc       /"latitude": "/
LatPatLen           equ       *-LatPattern

LonPattern          fcc       /"longitude": "/
LonPatLen           equ       *-LonPattern

MsgLat              fcc       "Latitude:  "
MsgLatLen           equ       *-MsgLat

MsgLon              fcc       "   Longitude: "
MsgLonLen           equ       *-MsgLon

CRLF                fcb       $0D,$0A

NoFixMsg            fcc       "No ISS fix in response - retrying..."
                    fcb       $0D
NoFixLen            equ       *-NoFixMsg

CommErrMsg          fcc       "WizFi360 communication error - retrying..."
                    fcb       $0D
CommErrLen          equ       *-CommErrMsg

OpenErrMsg          fcc       "Could not open /wz - check WizFi360 module"
                    fcb       $0D
OpenErrLen          equ       *-OpenErrMsg

* ---- diagnostic banners ----
MsgOpen             fcc       "ISS: opening /wz connection"
                    fcb       $0D
MsgOpenLen          equ       *-MsgOpen

MsgConn             fcc       "ISS: connecting to api.open-notify.org:80"
                    fcb       $0D
MsgConnLen          equ       *-MsgConn

MsgHdr              fcc       "ISS: sending header (HTTP GET)"
                    fcb       $0D
MsgHdrLen           equ       *-MsgHdr

MsgResp             fcc       "ISS: --- raw /wz response ---"
                    fcb       $0D
MsgRespLen          equ       *-MsgResp

MsgWait             fcc       "ISS: waiting for /wz..."
                    fcb       $0D
MsgWaitLen          equ       *-MsgWait

MsgNoData           fcc       "ISS: no data from /wz to read"
                    fcb       $0D
MsgNoDataLen        equ       *-MsgNoData

MsgClose            fcc       "ISS: done, closing"
                    fcb       $0D
MsgCloseLen         equ       *-MsgClose

ISSTtl              fcc       " ISS TRACKER"
ISSTtlLen           equ       *-ISSTtl

ISSData             fcc       " Awaiting ISS Data from WizFi360 "
ISSDataLen          equ       *-ISSData

PIXVCMD             fcc       "/dd/cmds/pixview"
                    fcb       C$CR

PIXON               fcc       "-on /dd/sys/backgrounds/clutworldmap"
                    fcb       C$CR
PIXONLEN            equ       *-PIXON

PIXON2              fcc       "-on /dd/sys/backgrounds/clutworldmap2"
                    fcb       C$CR
PIXONLEN2           equ       *-PIXON2

PIXOFF              fcc       "-off"
                    fcb       C$CR
PIXOFFLEN           equ       *-PIXOFF

ScrnInit            fcb       $1B,$20,$04,$00,$00,$00,$00,$01,$06,$00
ScrnInitLen         equ       *-ScrnInit

SPRTADDR            fcb       $05,$60,$00      iss sprite address

SPRTFILE            fcc       "/dd/sys/backgrounds/iss2"
                    fcb       C$CR

CLUTFILE            fcc       "/dd/sys/backgrounds/xtclutnomod"
                    fcb       C$CR

                    emod
eom                 equ       *
                    end
