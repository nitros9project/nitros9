********************************************************************
* net - network routines
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2010/01/08  Boisy G. Pitre
* Started.

                    section   bss
nbufferl            equ       128
nbuffer             rmb       nbufferl
                    endsect

                    section   code

space               fcb       C$SPAC
devnam              fcs       "/N"

getopts             leax      nbuffer,u
                    ldb       #SS.Opt
                    os9       I$GetStt
                    rts

setopts             leax      nbuffer,u
                    ldb       #SS.Opt
                    os9       I$SetStt
                    rts

* Set Echo On
*
* Entry: A = path to network device
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
SetEchoOn           pshs      a,x
                    bsr       getopts
                    bcs       rawex
                    ldb       #1
                    stb       PD.EKO-PD.OPT,x
                    bsr       setopts
                    puls      a,x,pc


* Set Echo Off
*
* Entry: A = path to network device
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
SetEchoOff          pshs      a,x
                    bsr       getopts
                    bcs       rawex
                    clr       PD.EKO-PD.OPT,x
                    bsr       setopts
                    puls      a,x,pc


* Set Auto Linefeed On
*
* Entry: A = path to network device
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
SetAutoLFOn         pshs      a,x
                    bsr       getopts
                    bcs       rawex
                    ldb       #1
                    stb       PD.ALF-PD.OPT,x
                    bsr       setopts
                    puls      a,x,pc


* Set Auto Linefeed Off
*
* Entry: A = path to network device
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
SetAutoLFOff        pshs      a,x
                    bsr       getopts
                    bcs       rawex
                    clr       PD.ALF-PD.OPT,x
                    bsr       setopts
                    puls      a,x,pc


* Put the path passed in A in raw mode
*
* Entry: A = path to network device
*
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
RawPath             pshs      a,x
                    bsr       getopts
                    bcs       rawex
                    leax      PD.UPC-PD.OPT,x
                    ldb       #PD.QUT-PD.UPC
rawloop             clr       ,x+
                    decb
                    bpl       rawloop
                    bsr       setopts
rawex               puls      a,x,pc


* Attempts to open and setup a path to the TCP server
*
* Exit:
*        Success: A = path to network device, CC carry clear
*        Failure: B = error code, CC carry set
TCPOpen             pshs      x,y
                    lda       #UPDAT.
                    leax      devnam,pcr
                    os9       I$Open
                    bcs       openerr
                    bsr       SetEchoOff
                    bsr       SetAutoLFOff
openerr
                    puls      x,y,pc


* Informs the server that we are killing a session
*
* Entry: A = path to network device
*        Y = pointer to token string (nul terminated)
*
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
TCPKill             pshs      a,x,y
                    leax      tcpkill,pcr
                    ldy       #tcpkilll
                    os9       I$Write
                    lbcs      connectex
                    bra       writeport

* Informs the server that we are joining a session
*
* Entry: A = path to network device
*        Y = pointer to token string (nul terminated)
*
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
TCPJoin             pshs      a,x,y
                    leax      tcpjoin,pcr
                    ldy       #tcpjoinl
                    os9       I$Write
                    lbcs      connectex
                    bra       writeport

* Attempts to connect to a TCP/IP host via the server
*
* Entry: A = path to network device
*        X = pointer to host name string (nul terminated)
*        Y = pointer to port string (nul terminated)
*
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
TCPConnectToHost
                    pshs      a,x,y
                    leax      tcpconnect,pcr
                    ldy       #tcpconnectl
                    os9       I$Write
                    bcs       connectex
                    ldx       1,s
                    lbsr      STRLEN
                    tfr       d,y
                    lda       ,s
                    os9       I$Write
* write space
                    leax      space,pcr
                    ldy       #1
                    os9       I$Write
* write port (we worry about response later)
writeport           ldx       3,s                 get original Y on stack
                    pshs      a
                    lbsr      STRLEN
                    tfr       d,y
                    puls      a
                    os9       I$Write
                    leax      acr,pcr
                    ldy       #1
                    os9       I$WritLn

* read response from server
* Entry: A = path
readresponse
                    leax      nbuffer,u
                    ldy       #nbufferl
                    os9       I$ReadLn
                    bcs       connectex
                    lda       ,x
                    cmpa      #'F
                    bne       connectex
* failure case: read number and return it with carry set
                    leax      5,x                 skip over "FAIL "
                    lbsr      DEC_BIN             error will fit in B
                    coma                          set carry
connectex           puls      a,x,y,pc

acr                 fcb       C$CR

* Requests to listen on a port
*
* Entry: A = path to network device
*        X = pointer to parameter string (nul terminated)
*
* Exit:
*        Success: CC carry clear
*        Failure: CC carry set, B = error code
TCPListen           pshs      a,x,y
                    leax      tcplisten,pcr
                    ldy       #tcplistenl
                    os9       I$Write
                    bcs       connectex
                    ldx       1,s
                    lbsr      STRLEN
                    tfr       d,y
                    lda       ,s
                    os9       I$Write
                    leax      acr,pcr
                    ldy       #1
                    os9       I$WritLn
                    bra       readresponse

* Disconnects the TCP/IP host via the server
*
* Entry: A = path to network device
*
* Exit:
*        Success: CC carry clear
*        Failure: B = error code, CC carry set
TCPDisconnect       os9       I$Close
                    rts

tcpconnect          fcc       'tcp connect '
tcpconnectl         equ       *-tcpconnect

tcplisten           fcc       'tcp listen '
tcplistenl          equ       *-tcplisten

tcpjoin             fcc       'tcp join '
tcpjoinl            equ       *-tcpjoin

tcpkill             fcc       'tcp kill '
tcpkilll            equ       *-tcpkill

                    endsect
