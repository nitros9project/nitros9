********************************************************************
* fuji - FujiNet routines
*
* $Id$
*
* FujiNet speaks a transaction protocol on top of the DriveWire
* wire (see FujiNetWIFI/fujinet-firmware, lib/bus/drivewire):
*
*   1. the client writes OP_FUJI ($E2), a command byte, and any
*      parameters or payload as raw bytes
*   2. the firmware buffers the command's reply
*   3. the client asks for the outcome with FUJI$GetError (one
*      status byte) and for the reply data with FUJI$GetResponse
*
* Replies come back as raw bytes, not as DriveWire virtual channel
* data, so each exchange goes through the scdwv SS.Fuji SetStat,
* which performs the write and the raw read in one IRQ-masked
* window (see level1/modules/scdwv.asm).
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/09/12  Boisy G. Pitre
* Started.
*   2      2026/07/13  Andrew Diller
* Rewritten around the FujiNet transaction protocol.

fbmaxreq            equ       264                 OP_FUJI+cmd+3 params+256 payload, rounded

                    section   bss
fbreq               rmb       fbmaxreq+2          response-length prefix + request
fbsmall             rmb       4                   prefix + [OP_FUJI,command]
fbstat              rmb       1                   FUJI$GetError reply byte
fbtries             rmb       1                   FBReady retry counter
                    endsect

                    section   code

devnam              fcs       "/N"

* NOpen - open a path to the FujiNet/DriveWire network device
*
* Exit:
*        Success: A = path to network device, CC carry clear
*        Failure: B = error code, CC carry set
NOpen               pshs      x
                    lda       #UPDAT.
                    leax      devnam,pcr
                    os9       I$Open
                    puls      x,pc

* FBReady - poll the FujiNet until it reports ready
*
* Entry: A = path to network device
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
FBReady             pshs      a,x,y,u
                    ldb       #16                 give up after this many polls
                    stb       fbtries,u
ready@              leax      fbsmall,u
                    ldd       #1                  expect a one byte reply
                    std       ,x
                    ldd       #OP_FUJI*256+FUJI$Ready
                    std       2,x
                    ldy       #4
                    lda       ,s                  path
                    ldb       #SS.Fuji
                    pshs      u
                    leau      fbstat,u
                    os9       I$SetStt
                    puls      u
                    bcs       retry@              wire timeout, try again
                    lda       fbstat,u
                    bne       ok@                 nonzero means ready
retry@              dec       fbtries,u
                    beq       bad@
                    ldx       #2                  breathe between polls
                    os9       F$Sleep
                    bra       ready@
ok@                 clrb
                    puls      a,x,y,u,pc
bad@                comb
                    ldb       #E$NotRdy
                    puls      a,x,y,u,pc

* FBCmd - send a FujiNet command and confirm the firmware accepted it
*
* Entry: A = path to network device
*        X = raw request, first byte OP_FUJI
*        Y = request length (1..fbmaxreq)
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
*                 (FUJI$E.Err if the firmware rejected the command)
FBCmd               pshs      a,x,y,u
                    ldd       3,s                 request length
                    beq       bad@
                    cmpd      #fbmaxreq
                    bhi       bad@
                    leay      fbreq,u
                    clr       ,y+                 no reply bytes wanted here
                    clr       ,y+
                    leau      d,x                 end of source request
                    pshs      u
copy@               lda       ,x+
                    sta       ,y+
                    cmpx      ,s
                    blo       copy@
                    leas      2,s
                    ldu       5,s                 recover the data area base
                    leax      fbreq,u
                    ldd       3,s
                    addd      #2                  include the prefix
                    tfr       d,y
                    lda       ,s                  path
                    ldb       #SS.Fuji
                    os9       I$SetStt
                    bcs       ex@                 wire error
                    lda       ,s
                    bsr       FBErr               did the firmware like it?
ex@                 puls      a,x,y,u,pc
bad@                comb
                    ldb       #E$IllArg
                    puls      a,x,y,u,pc

* FBErr - fetch the one byte status of the last command
*
* Entry: A = path to network device
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
*                 (the firmware status byte when it is not FUJI$E.OK)
FBErr               pshs      a,x,y,u
                    leax      fbsmall,u
                    ldd       #1
                    std       ,x
                    ldd       #OP_FUJI*256+FUJI$GetError
                    std       2,x
                    ldy       #4
                    lda       ,s                  path
                    ldb       #SS.Fuji
                    pshs      u
                    leau      fbstat,u
                    os9       I$SetStt
                    puls      u
                    bcs       ex@
                    ldb       fbstat,u
                    cmpb      #FUJI$E.OK
                    beq       ok@
                    orcc      #Carry              report the firmware status in B
                    bra       ex@
ok@                 clrb
ex@                 puls      a,x,y,u,pc

* FBRead - fetch the reply data of the last command
*
* Entry: A = path to network device
*        X = response buffer
*        Y = response length (1..FUJI$MaxTran)
* Exit:
*        Success: CC carry clear, buffer filled
*        Failure: CC carry set, B = error code
FBRead              pshs      a,x,y,u
                    leax      fbsmall,u
                    sty       ,x                  reply bytes wanted
                    ldd       #OP_FUJI*256+FUJI$GetResponse
                    std       2,x
                    ldy       #4
                    lda       ,s                  path
                    ldb       #SS.Fuji
                    ldu       1,s                 caller's buffer
                    os9       I$SetStt
                    puls      a,x,y,u,pc

                    endsect
