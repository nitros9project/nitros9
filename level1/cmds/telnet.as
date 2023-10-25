********************************************************************
* telnet - telnet client
*
* $Id$
*
* Notes:
* This utility works in similar fashion to telnet commands on other systems.
* The user can telnet to a location, and once there, press the TELESCAPE key
* to invoke telnet command mode.
*
* Two sets of path options are kept for the standard input.  The first is an
* unmodified copy and the second is a modifable copy.  The second is set up
* for raw mode and is used when communicating with the host.  The first will
* be used when going into telnet command mode or exiting the telnet program.
*
* The signal handler catches the S$HUP signal and shuts down gracefully.  It
* also looks for the ABORT/QUIT characters and relays them to the session.
*
* Reference used: http://www.faqs.org/rfcs/rfc854.html
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2010/01/02  Aaron Wolfe
* Most basic implementation using new DW utility API
*
*   2      2010/01/06  Boisy G. Pitre
* Reformatted and optimized source. Added SS.Opt support, added telnet
* command mode which can be entered by pressing the TELESCAPE key.
*
*   3      2010/01/07  Boisy G. Pitre
* Reworked buffer processing routine.
*
*   4      2010/01/12  Boisy G. Pitre
* We allow host to do echo if it wants, we also now advertise the
* escape character when a connection is successful.
*
*   5      2010/01/15  Boisy G. Pitre
* Modified to be an rma assembled module and use the netlib library.

* Set to 1 if you want to see telnet CTRL chars from host
DEBUG               set       0

                    nam       telnet
                    ttl       program module

                    section   __os9
type                equ       Prgrm
lang                equ       Objct
attr                equ       ReEnt
rev                 equ       $00
edition             equ       5
stack               equ       200
                    endsect

                    section   bss
connected           rmb       1
netdatardy          rmb       1
keydatardy          rmb       1
lastsig             rmb       1
port                rmb       2
hostname            rmb       2
pbuffer             rmb       256
pbufferl            equ       *
pbend               rmb       2
cbuffer             rmb       256
ccount              rmb       1
opts                rmb       32
orgopts             rmb       32
tcmdbufl            equ       32
tcmdbuf             rmb       tcmdbufl
portdev             rmb       10
netpath             rmb       1
outpath             rmb       1
numbyt              rmb       1
state               rmb       1
telctrlbuf          rmb       3
                    endsect

                    section   code

TELESCAPE           equ       'Y-$40              * CTRL-Y

NetSig              equ       32
KeySig              equ       33

SE                  equ       240                 * end of subnegotiation parameters
NOP                 equ       241                 * no operation
DataMark            equ       242                 * the data stream portion of a Synch. This should always be accompanied by a TCP Urgent notification.
Break               equ       243                 * NVT character BRK.
IntProc             equ       244                 * the function IP
AbortOut            equ       245                 * the function AO.
AreUThere           equ       246                 * the function AYT
EraseChar           equ       247                 * the function EC.
EraseLine           equ       248                 * the function EL.
GoAhead             equ       249                 * the GA signal.
SB                  equ       250                 * indicates that what follows is subnegotiation of the indicated option.
WILL                equ       251                 * indicates the desire to begin performing, or confirmation that you are now performing, the indicated option.
WONT                equ       252                 * indicates the refusal to perform, or continue performing, the indicated option.
DO                  equ       253                 * indicates the request that the other party perform, or confirmation that you are expecting the other party to perform, the indicated option.
DONT                equ       254                 * indicates the demand that the other party stop performing, or confirmation that you are no longer expecting the other party to perform, the indicated option.
IAC                 equ       255                 * data byte 255.

* Telnet Options
TO_ECHO             equ       $01

escprompt           fcc       /Escape character is '^/
                    fcb       TELESCAPE+$40
                    fcc       /'./
crlf                fcb       C$CR,C$LF
escpromptl          equ       *-escprompt
tprompt             fcc       /telnet> /
tpromptl            equ       *-tprompt

trying              fcc       /Trying.../
                    fcb       C$CR
tryingl             equ       *-trying

peerclosm           fcc       /Connection closed by foreign host./
                    fcb       C$CR
peerclosml          equ       *-peerclosm

using               fcc       'Using port '
usingl              equ       *-using

defportstr          fcc       '23'
                    fcb       0

peerclosed
                    clr       connected,u
                    lda       #1
                    leax      peerclosm,pcr
                    ldy       #peerclosml
                    os9       I$WritLn
                    lbra      done

* signal intercept routine
sigint
                    stb       lastsig,u           * save our signal received
                    cmpb      #KeySig
                    bne       netchk
                    inc       keydatardy,u
                    rti
netchk              cmpb      #NetSig
                    bne       hupchk
                    inc       netdatardy,u
                    rti
hupchk              cmpb      #S$HUP              * disconnect from peer signal received?
                    beq       peerclosed          * yep, exit nicely
                    lda       #$03                * usual interrupt character
                    cmpb      #S$Intrpt
                    beq       chksig
                    lda       #$05                * usual quit character
                    cmpb      #S$Abort
                    bne       sigex
chksig              tst       connected,u
                    lbeq      done
                    pshs      a
                    leax      ,s
                    ldy       #$0001
                    lda       netpath,u
                    os9       I$Write
                    puls      a
sigex               rti

* save initial parameters
__start             pshs      x
                    clr       connected,u
                    clr       netdatardy,u
                    clr       keydatardy,u

* setup signal intercept
                    leax      sigint,pcr
                    os9       F$Icpt

* get path options (original and modifiable copy)
                    leax      orgopts,u
                    ldd       #SS.Opt
                    os9       I$GetStt
                    lbcs      errex2

                    leax      opts,u
                    ldd       #SS.Opt
                    os9       I$GetStt
                    lbcs      errex2

* set up our path to be raw (we will actually set it later)
                    leax      PD.UPC-PD.OPT,x
                    ldb       #PD.INT-PD.UPC
rawloop             clr       ,x+
                    decb
                    bne       rawloop

* set address as nul terminated string
addrloop
                    ldx       ,s
addrloop2
                    lda       ,x+
                    cmpa      #C$SPAC
                    beq       nilit
                    cmpa      #C$CR
                    beq       nilit
                    bra       addrloop2

nilit               clr       -1,x                nil terminate previous param
                    cmpa      #C$CR               are we at end of command line?
                    beq       defaultport         yep, set default port

skipspc             lda       ,x+
                    cmpa      #C$CR
                    beq       defaultport
                    cmpa      #C$SPAC
                    beq       skipspc
* if here, we have a second parameter... probably port number
                    leay      -1,x
                    bra       parsedone
defaultport         leay      defportstr,pcr
parsedone           puls      x

* X holds pointer to nul terminated address
* Y holds port number string (nil terminated)
* do the open and connect
                    pshs      y
                    std       port,u
                    stx       hostname,u

* announce our attempt to try to connect
                    lda       #1
                    ldy       #tryingl
                    leax      trying,pcr
                    os9       I$WritLn

                    lbsr      TCPOpen
                    puls      y
                    lbcs      errex1
                    sta       netpath,u
                    ldx       hostname,u
                    lbsr      TCPConnectToHost
                    lbcs      errex2
                    lbsr      RawPath

* we're connected...
                    lda       #1
                    sta       connected,u
                    leax      escprompt,pcr
                    ldy       #escpromptl
                    os9       I$WritLn

* make our stdin opts raw
                    leax      opts,u
                    ldd       #SS.Opt
                    os9       I$SetStt
                    lbcs      errex2

* setup data ready signal on stdin
                    clra
                    ldb       #SS.SSig
                    ldx       #KeySig
                    os9       I$SetStt
                    lbcs      errex2

* setup data ready signal on netpath
                    lda       netpath,u
                    ldb       #SS.SSig
                    ldx       #NetSig
                    os9       I$SetStt
                    lbcs      errex2

* response loop
* check for typed characters
rloop
                    pshs      cc                  save interrupt state
                    orcc      #IntMasks           mask interrupts
                    tst       netdatardy,u
                    bne       GetNetData
                    tst       keydatardy,u
                    bne       GetKeyData
* sleep until signal
                    ldx       #$0000
                    os9       F$Sleep
                    puls      cc
                    bra       rloop

GetKeyData          puls      cc
                    dec       keydatardy,u
                    bra       stdinc

GetNetData          puls      cc
                    dec       netdatardy,u
                    lda       netpath,u
                    ldb       #SS.Ready
                    os9       I$GetStt
                    lbcc      serinc              read and print the byte
                    bra       rloop

* telnet command interface
cmdint
* restore original opts for now
                    leax      orgopts,u
                    ldd       #SS.Opt
                    os9       I$SetStt
                    bcs       errex2

* write CR
                    lda       #1
                    leax      crlf,pcr
                    ldy       #$02
                    os9       I$Write

* show prompt
cmdloop
                    lda       #1
                    leax      tprompt,pcr
                    ldy       #tpromptl
                    os9       I$Write

* read command
                    leax      tcmdbuf,u
                    ldy       #tcmdbufl
                    clra
                    os9       I$ReadLn
                    bcs       errex2

* process command
                    lda       ,x
                    anda      #$5F                * make uppercase

                    cmpa      #C$CR
                    beq       ret2tel             * just CR... return to telnet session
                    cmpa      #'Q
                    beq       okex
                    bra       cmdloop

* return to telnet session
ret2tel
                    leax      opts,u
                    ldd       #SS.Opt
                    os9       I$SetStt
                    bcs       errex2

* read one byte from stdin, send to server
stdinc              ldy       #$0001
                    clra
                    leax      numbyt,u
                    os9       I$Read
                    bcs       errex2

* check if it is an escape character
                    lda       ,x
                    cmpa      #TELESCAPE
                    beq       cmdint

outc                ldy       #$0001
                    lda       netpath,u
                    leax      numbyt,u
                    os9       I$Write
                    bcs       errex2

* setup data ready signal on stdin
                    clra
                    ldb       #SS.SSig
                    ldx       #KeySig
                    os9       I$SetStt
                    lbcs      errex2

                    lbra      rloop

done
okex                clrb                          *no errors here
* close port
errex2
                    pshs      b,cc
                    lda       netpath,u
                    lbsr      TCPDisconnect
                    clr       connected,u

                    leax      orgopts,u
                    ldd       #SS.Opt
                    os9       I$SetStt            *restore original path options
                    puls      b,cc

errex1              os9       F$Exit              *goodbye

* read B bytes from serial
serinc              clra
                    tfr       d,y
                    lda       netpath,u
                    leax      pbuffer,u
                    os9       I$Read
                    bcs       errex2

* set buffer
                    tfr       y,d
                    leax      pbuffer,u
                    abx
                    stx       pbend,u             *set end addr
                    clrb
                    leax      pbuffer,u
                    leay      cbuffer,u
                    clr       ccount,u

* call buffer processor
                    bsr       procbuf

* print buffer
                    ldb       ccount,u
                    beq       serincex
                    clra
                    tfr       d,y
                    lda       #1
                    leax      cbuffer,u
                    os9       I$Write
                    bcs       errex2

* return to loop
serincex
* setup data ready signal on netpath
                    lda       netpath,u
                    ldb       #SS.SSig
                    ldx       #NetSig
                    os9       I$SetStt
                    lbcs      errex2

                    lbra      rloop



* buffer processing routine
procbuf             cmpx      pbend,u
                    beq       procbufex
* not at end of buffer, get next char
                    lda       ,x+
* check state to see what we do with this byte
                    tst       state,u
                    bne       telctrl
                    cmpa      #IAC
                    beq       telstate
                    sta       ,y+
                    inc       ccount,u
                    bra       procbuf
procbufex           rts

conv                anda      #$0F
                    cmpa      #$09
                    bgt       alpha
                    adda      #$30
                    fcb       $8C
alpha               adda      #$41-$0A
                    rts

                    ifeq      DEBUG-1
printhex            pshs      d,x,y
                    bsr       conv
                    pshs      a
                    lda       1,s
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       conv
                    pshs      a
                    lda       #'$
                    pshs      a
                    leax      ,s
                    ldy       #$0003
                    lda       #$01
                    os9       I$Write
                    leas      3,s
                    puls      d,x,y,pc
                    endc

telstate            sta       telctrlbuf,u
                    ifeq      DEBUG-1
                    bsr       printhex
                    endc
                    inc       state,u
                    bra       procbuf

clrngo              clr       state,u
                    bra       procbuf

* handles telnet control sequence... A = byte
telctrl
                    ifeq      DEBUG-1
                    bsr       printhex
                    endc
                    ldb       state,u
                    cmpb      #1
                    bne       telctrl2
                    cmpa      #SB
                    ble       clrngo
                    sta       telctrlbuf+1,u
                    inc       state,u
                    bra       procbuf
telctrl2            sta       telctrlbuf+2,u
                    clr       state,u
* here we have a complete telnet control sequence
                    ldd       telctrlbuf+1,u
                    cmpa      #DO
                    beq       dowont
                    cmpa      #WILL
                    lbne      procbuf
                    cmpb      #TO_ECHO
                    bne       dodont
* allow host to echo
                    lda       #DO
                    fcb       $8C
dodont              lda       #DONT
                    fcb       $8C
dowont              lda       #WONT
                    sta       telctrlbuf+1,u
                    pshs      x,y
                    ldy       #3
                    lda       netpath,u
                    leax      telctrlbuf,u
                    os9       I$Write
                    puls      x,y
                    lbra      procbuf

                    endsect
