********************************************************************
* w6100tel - telnet client over W6100 Ethernet (TCP), with DNS.
*
*   Usage:  w6100tel <host> [port]
*
*   <host>  a dotted-decimal IPv4 address (used directly) OR a
*           hostname (resolved via DNS using the "dns" server from
*           /DD/SYS/w6100ipconfig).
*   [port]  optional TCP port (decimal). Defaults to 23.
*
* Type Ctrl-] ($1D) to close the session and exit.
*
* NETWORK CONFIGURATION  (/DD/SYS/w6100ipconfig - same file & parser
* as w6100eth / w6100recv / w6100send). Keywords, one per line,
* "key value" or "key=value", '#'/'*' start a comment:
*   ip  mask(subnet,netmask)  gateway(gw)  server  port  mac  dns
* The "dns" keyword (new here) sets the DNS resolver; if omitted the
* built-in default (8.8.8.8) is used. "server"/"port" are unused by
* the telnet client (the host/port come from the command line) but
* are still accepted so one config file serves every tool.
*
* IMPLEMENTATION NOTES / verification status
* ------------------------------------------
* Reuses the bridge + TCP socket code proven by w6100eth/recv/send,
* the identical w6100ipconfig parser, and the TX path from w6100send.
* New here: a UDP path for DNS and a bidirectional telnet loop.
*   - DNS query build + response parse (labels, name compression,
*     CNAME-then-A chains), the telnet IAC negotiation state machine,
*     and the dotted-IP detector were all unit-tested in a 6809
*     emulator against real DNS packets and byte streams.
*   - The W6100 UDP register sequencing (open UDP, sendto, the
*     [2-byte info][4 peer IP][2 peer port][payload] RX framing) and
*     the terminal read/write path follow WIZnet io6Library and OS-9
*     conventions but must be confirmed on real K2 hardware.
*   - Terminal input is read a character at a time via SS.Ready +
*     I$Read on the standard input path. For a clean full-duplex
*     session the input path should be in a raw/no-echo mode; on a
*     cooked terminal input will be line-buffered with local echo.
*
* W6100 constants confirmed against WIZnet io6Library w6100.h:
*   Sn_MR_UDP4=$02  SOCK_UDP=$22  RECV=$40
*   Sn_TX_FSR=$0204 Sn_TX_WR=$020C  Sn_RX_RSR=$0224 Sn_RX_RD=$0228
********************************************************************

                    nam       w6100tel
                    ttl       Telnet client over W6100 Ethernet

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

*-----------------------------------------------------------
* K2 <-> W6100 bridge registers
*-----------------------------------------------------------
W.CTRL              equ       $FF40
W.MR                equ       $FF41
W.DATA              equ       $FF43
W.BSR               equ       $FF44
W.ARL               equ       $FF45

CTL.START           equ       %00100000
CTL.GO.WRSINGLE     equ       %00000001
CTL.GO.WRMR         equ       %00000101
CTL.GO.RDSINGLE     equ       %00001001

BSR.COMMON          equ       $00
BSR.S0REG           equ       $08
BSR.S0TX            equ       $10
BSR.S0RX            equ       $18

CIDR0               equ       $0000
NETLCKR             equ       $41F5
NETUNLCK            equ       $3A
SHAR0               equ       $4120
GAR0                equ       $4130
SUBR0               equ       $4134
SIPR0               equ       $4138

Sn_MR               equ       $0000
Sn_CR               equ       $0010
Sn_IR               equ       $0020
Sn_IRCLR            equ       $0028
Sn_SR               equ       $0030
Sn_PORT0            equ       $0114
Sn_DIPR0            equ       $0120
Sn_DPRT0            equ       $0140
Sn_TXFSR0           equ       $0204
Sn_TXWR0            equ       $020C
Sn_RXRSR0           equ       $0224
Sn_RXRD0            equ       $0228

CMD.OPEN            equ       $01
CMD.CONNECT         equ       $04
CMD.DISCON          equ       $08
CMD.CLOSE           equ       $10
CMD.SEND            equ       $20
CMD.RECV            equ       $40
MR.TCP4             equ       $01
MR.UDP4             equ       $02

S.CLOSED            equ       $00
S.INIT              equ       $13
S.ESTAB             equ       $17
S.CLOSEWAIT         equ       $1C
S.UDP               equ       $22
IR.SENDOK           equ       $10
IR.TIMEOUT          equ       $08

* telnet protocol
T.IAC               equ       255
T.DONT              equ       254
T.DO                equ       253
T.WONT              equ       252
T.WILL              equ       251
T.SB                equ       250
T.SE                equ       240
O.ECHO              equ       1
O.SGA               equ       3
KEY.QUIT            equ       $1D       Ctrl-] closes the session

CHR.SP              equ       $20
CHR.CR              equ       $0D
CHR.LF              equ       $0A
BUFSZ               equ       200
DNSPORT             equ       53
MYPORT              equ       $C000     TCP source port
DNSPORTSRC          equ       $C002     UDP source port for DNS
DNS.RETRY           equ       3
DNS.WAIT            equ       200       poll iterations per try

* config value types
CT.IP4              equ       1
CT.MAC              equ       2
CT.PORT             equ       3

                    mod       eom,name,tylg,atrv,start,size

*-----------------------------------------------------------
* Process data area. Everything DP-addressed with "<" stays below
* 256; the large buffers are only ever reached U-relative.
*-----------------------------------------------------------
BsrVal              rmb       1
RegHi               rmb       1
RegLo               rmb       1
RegData             rmb       1
BusyTO              rmb       1
soff                rmb       2
sval                rmb       2
getn                rmb       1
rdptr               rmb       2
ix                  rmb       1
tmp                 rmb       1
tmpw                rmb       2
* --- telnet state ---
tstate              rmb       1
tverb               rmb       1
feedp               rmb       2
feedn               rmb       1
gotcnt              rmb       1
want16              rmb       2
* --- DNS parse/build ---
msgbase             rmb       2
cp                  rmb       2
ancnt               rmb       2
qdcnt               rmb       2
rdlen               rmb       2
lenpos              rmb       2
lcount              rmb       1
ipout               rmb       2
msgend              rmb       2
qlen                rmb       2
soff2               rmb       2
rcount              rmb       2
total16             rmb       2
dnslen              rmb       2
h0                  rmb       1
h1                  rmb       1
dnstry              rmb       1
* --- decimal / IP parse ---
octet               rmb       1
acc                 rmb       2
digcnt              rmb       1
Num                 rmb       4
rem                 rmb       1
* --- command line ---
HostPort            rmb       2
NamePtr             rmb       2
HostIP              rmb       4         connect target (literal or resolved)
OutByte             rmb       1
* --- config parser scratch ---
cfptr               rmb       2
cfend               rmb       2
kwptr               rmb       2
destp               rmb       2
ptype               rmb       1
cfpn                rmb       1
* --- live network config: keep 28 bytes contiguous & in this order
*     (CopyDefaults block-copies MAC,IP,MASK,GW,SRV,PORT,DNS) ---
CfgMAC              rmb       6
CfgIP               rmb       4
CfgMask             rmb       4
CfgGW               rmb       4
CfgSrv              rmb       4
CfgPort             rmb       2
CfgDNS              rmb       4
* --- buffers (U-relative only) ---
OutBuf              rmb       8
NegBuf              rmb       3
KbBuf               rmb       1
QueryBuf            rmb       64
Buf                 rmb       BUFSZ
DnsBuf              rmb       520
ConfBuf             rmb       512
                    rmb       300
size                equ       .

name                fcs       /w6100tel/
                    fcb       edition

*=====================================================================
* start
*=====================================================================
start
Skip                lda       ,x
                    cmpa      #CHR.SP
                    bne       HaveName
                    leax      1,x
                    bra       Skip
HaveName            cmpa      #CHR.CR
                    lbeq      Usage
                    stx       <NamePtr

                    leax      MsgBanner,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF

* --- parse optional [port] after the host ---
                    ldd       #23
                    std       <HostPort
                    ldx       <NamePtr
CL.eoh              lda       ,x                  find end of host token
                    beq       CL.dfl
                    cmpa      #CHR.SP
                    beq       CL.port
                    cmpa      #CHR.CR
                    beq       CL.dfl
                    leax      1,x
                    bra       CL.eoh
CL.port             leax      1,x                 skip spaces before port
                    lda       ,x
                    cmpa      #CHR.SP
                    beq       CL.port
                    cmpa      #'0
                    blo       CL.dfl
                    cmpa      #'9
                    bhi       CL.dfl
                    ldd       #0
                    std       <acc
CL.pl               lda       ,x
                    suba      #'0
                    bcs       CL.pdn
                    cmpa      #9
                    bhi       CL.pdn
                    tfr       a,b
                    lbsr      Acc10Add
                    leax      1,x
                    bra       CL.pl
CL.pdn              ldd       <acc
                    std       <HostPort
CL.dfl              equ       *

* --- load network config (file or built-in defaults) ---
                    lbsr      LoadConfig

* --- confirm the W6100 answers ---
                    ldx       #CIDR0
                    lbsr      CRegRdB
                    cmpb      #$61
                    lbne      ChipFail

* --- unlock and load identity from Cfg* ---
                    ldx       #NETLCKR
                    ldb       #NETUNLCK
                    lbsr      CRegWrB
                    lda       #BSR.COMMON
                    sta       <BsrVal
                    leax      CfgMAC,u
                    ldy       #SHAR0
                    ldb       #6
                    lbsr      BlkWr
                    leax      CfgGW,u
                    ldy       #GAR0
                    ldb       #4
                    lbsr      BlkWr
                    leax      CfgMask,u
                    ldy       #SUBR0
                    ldb       #4
                    lbsr      BlkWr
                    leax      CfgIP,u
                    ldy       #SIPR0
                    ldb       #4
                    lbsr      BlkWr

* --- resolve host: literal IP -> use directly, else DNS ---
                    ldx       <NamePtr
                    leay      HostIP,u
                    lbsr      TryParseIP
                    bcc       HaveIP
                    leax      MsgResolv,pcr
                    lbsr      PrStr
                    ldx       <NamePtr
                    lbsr      PrName
                    lbsr      PrCRLF
                    lbsr      DnsResolve
                    lbcs      DnsFail
HaveIP              leax      MsgUsing,pcr
                    lbsr      PrStr
                    leax      HostIP,u
                    lbsr      PrIP4
                    lda       #':
                    lbsr      PrCh
                    ldd       <HostPort
                    std       <Num
                    ldd       #0
                    std       <Num+2                (Num is 4 bytes; port is low word)
                    ldd       <HostPort
                    clra
                    clrb
                    std       <Num
                    ldd       <HostPort
                    std       <Num+2
                    lbsr      PrDec32
                    lbsr      PrCRLF

* --- open TCP SOCKET0 and connect to the host ---
                    ldx       #Sn_MR
                    ldb       #MR.TCP4
                    lbsr      SRegWrB
                    ldx       #Sn_PORT0
                    ldd       #MYPORT
                    lbsr      SRegWr16
                    ldb       #CMD.OPEN
                    lbsr      SockCmd
                    lbsr      WaitInit
                    lbcs      SockErr

                    lda       #BSR.S0REG
                    sta       <BsrVal
                    leax      HostIP,u
                    ldy       #Sn_DIPR0
                    ldb       #4
                    lbsr      BlkWr
                    ldx       #Sn_DPRT0
                    ldd       <HostPort
                    lbsr      SRegWr16
                    ldb       #CMD.CONNECT
                    lbsr      SockCmd
                    lbsr      WaitEstab
                    lbcs      ConnErr

                    leax      MsgConn,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF

                    clr       <tstate

*=====================================================================
* Telnet main loop: drain socket -> terminal, terminal -> socket,
* until the peer closes or the user presses Ctrl-].
*=====================================================================
TelLoop             ldx       #Sn_RXRSR0
                    lbsr      SRegRd16
                    cmpd      #0
                    beq       TL.nodata
* have RX data: read a chunk and feed it through the telnet parser
                    lbsr      TcpRecvChunk
                    leax      Buf,u
                    stx       <feedp
                    lda       <gotcnt
                    sta       <feedn
TL.feed             lda       <feedn
                    beq       TL.kb
                    ldx       <feedp
                    lda       ,x+
                    stx       <feedp
                    lbsr      TelnetByte
                    dec       <feedn
                    bra       TL.feed
TL.nodata           ldx       #Sn_SR
                    lbsr      SRegRdB
                    cmpb      #S.ESTAB
                    beq       TL.kb
                    lbra      TL.done             peer closed (or closing, no data)
* poll keyboard (std in, path 0), non-blocking via SS.Ready
TL.kb               clra
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcs       TL.idle
                    clra
                    leax      KbBuf,u
                    ldy       #1
                    os9       I$Read
                    bcs       TL.idle
                    lda       KbBuf,u
                    cmpa      #KEY.QUIT
                    lbeq      TL.done
                    cmpa      #CHR.CR
                    beq       TL.sendcr
                    sta       KbBuf,u
                    leax      KbBuf,u
                    ldb       #1
                    lbsr      SockSend
                    lbcs      TL.done
                    lbra      TelLoop
TL.sendcr           lda       #CHR.CR             send CR as CR,LF (telnet NVT)
                    sta       KbBuf,u
                    lda       #CHR.LF
                    sta       KbBuf+1,u
                    leax      KbBuf,u
                    ldb       #2
                    lbsr      SockSend
                    lbcs      TL.done
                    lbra      TelLoop
TL.idle             ldx       #1
                    os9       F$Sleep             yield to OS-9
                    lbra      TelLoop

TL.done             ldb       #CMD.DISCON
                    lbsr      SockCmd
                    ldb       #CMD.CLOSE
                    lbsr      SockCmd
                    leax      MsgBye,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF
                    clrb
                    os9       F$Exit

*=====================================================================
* error exits
*=====================================================================
DnsFail             leax      MsgDnsF,pcr
                    bra       ErrPrint
ConnErr             leax      MsgConnF,pcr
                    bra       CloseAll
SockErr             leax      MsgSockF,pcr
CloseAll            pshs      x
                    ldb       #CMD.CLOSE
                    lbsr      SockCmd
                    puls      x
                    bra       ErrPrint
ChipFail            leax      MsgChipF,pcr
                    bra       ErrPrint
Usage               leax      MsgUsage,pcr
ErrPrint            lbsr      PrStr
                    lbsr      PrCRLF
                    ldb       #$01
                    os9       F$Exit

*=====================================================================
* DnsResolve - resolve <NamePtr> host into HostIP via UDP DNS.
*   carry clear on success (HostIP filled), carry set on failure.
*=====================================================================
DnsResolve          ldx       #Sn_MR
                    ldb       #MR.UDP4
                    lbsr      SRegWrB
                    ldx       #Sn_PORT0
                    ldd       #DNSPORTSRC
                    lbsr      SRegWr16
                    ldb       #CMD.OPEN
                    lbsr      SockCmd
                    lbsr      WaitUdp
                    lbcs      DR.fail
                    lda       #BSR.S0REG
                    sta       <BsrVal
                    leax      CfgDNS,u
                    ldy       #Sn_DIPR0
                    ldb       #4
                    lbsr      BlkWr
                    ldx       #Sn_DPRT0
                    ldd       #DNSPORT
                    lbsr      SRegWr16
                    ldx       <NamePtr
                    leay      QueryBuf,u
                    lbsr      DnsBuildQuery
                    std       <qlen
                    lda       #DNS.RETRY
                    sta       <dnstry
DR.try              leax      QueryBuf,u
                    ldb       <qlen+1
                    lbsr      SockSend
                    bcs       DR.next
                    ldy       #DNS.WAIT
DR.wait             ldx       #Sn_RXRSR0
                    lbsr      SRegRd16
                    cmpd      #8
                    bhs       DR.got
                    ldx       #2
                    os9       F$Sleep
                    leay      -1,y
                    bne       DR.wait
                    bra       DR.next
DR.got              lbsr      WUdpRecv
                    bcs       DR.next
                    leax      DnsBuf,u
                    leax      8,x                 skip UDP info+addr+port
                    ldd       <dnslen
                    leay      HostIP,u
                    lbsr      DnsParseResp
                    bcs       DR.next
                    ldb       #CMD.CLOSE
                    lbsr      SockCmd
                    andcc     #$FE
                    rts
DR.next             dec       <dnstry
                    bne       DR.try
DR.fail             ldb       #CMD.CLOSE
                    lbsr      SockCmd
                    orcc      #$01
                    rts

*=====================================================================
* WUdpRecv - read one UDP packet from SOCKET0 RX into DnsBuf.
*   RX layout: [2 info][4 peer IP][2 peer port][payload].
*   info: (b0 & $07)<<8 | b1 = payload length.
*   On success: DnsBuf holds the whole packet, <dnslen> = payload len,
*   RX read pointer advanced, RECV issued. carry set if no packet.
*=====================================================================
WUdpRecv            ldx       #Sn_RXRSR0
                    lbsr      SRegRd16
                    cmpd      #8
                    blo       WU.none
                    ldx       #Sn_RXRD0
                    lbsr      SRegRd16
                    std       <rdptr
                    lda       #BSR.S0RX
                    sta       <BsrVal
                    ldx       <rdptr
                    lbsr      WRd1
                    stb       <h0
                    ldx       <rdptr
                    leax      1,x
                    lbsr      WRd1
                    stb       <h1
                    lda       <h0
                    anda      #$07
                    ldb       <h1
                    std       <dnslen             payload length
                    ldd       <dnslen
                    addd      #8
                    std       <total16
                    leay      DnsBuf,u
                    ldd       <rdptr
                    std       <soff2
                    ldd       <total16
                    std       <rcount
WU.rdlp             ldd       <rcount
                    beq       WU.rddone
                    lda       #BSR.S0RX
                    sta       <BsrVal
                    ldx       <soff2
                    lbsr      WRd1
                    stb       ,y+
                    ldd       <soff2
                    addd      #1
                    std       <soff2
                    ldd       <rcount
                    subd      #1
                    std       <rcount
                    bra       WU.rdlp
WU.rddone           ldd       <rdptr
                    addd      <total16
                    ldx       #Sn_RXRD0
                    lbsr      SRegWr16
                    ldb       #CMD.RECV
                    lbsr      SockCmd
                    andcc     #$FE
                    rts
WU.none             orcc      #$01
                    rts

*=====================================================================
* TcpRecvChunk - read up to BUFSZ bytes of TCP data from SOCKET0 RX
*   into Buf; advance RX read pointer + RECV. <gotcnt> = byte count.
*=====================================================================
TcpRecvChunk        ldx       #Sn_RXRSR0
                    lbsr      SRegRd16
                    cmpd      #BUFSZ
                    blo       TR.small
                    ldd       #BUFSZ
TR.small            std       <want16
                    ldx       #Sn_RXRD0
                    lbsr      SRegRd16
                    std       <rdptr
                    ldb       <want16+1
                    stb       <gotcnt
                    leay      Buf,u
                    clr       <ix
TR.lp               lda       <ix
                    cmpa      <gotcnt
                    beq       TR.dn
                    ldd       <rdptr
                    addb      <ix
                    adca      #0
                    pshs      y
                    tfr       d,x
                    lda       #BSR.S0RX
                    sta       <BsrVal
                    lbsr      WRd1
                    puls      y
                    stb       ,y+
                    inc       <ix
                    bra       TR.lp
TR.dn               ldd       <rdptr
                    addb      <gotcnt
                    adca      #0
                    ldx       #Sn_RXRD0
                    lbsr      SRegWr16
                    ldb       #CMD.RECV
                    lbsr      SockCmd
                    rts

*=====================================================================
* SockSend - send B bytes from (X) over SOCKET0 (TCP or UDP).
*   carry clear on success; carry set on timeout / peer gone.
*=====================================================================
SockSend            pshs      x
                    stb       <getn
SS.wait             ldx       #Sn_TXFSR0
                    lbsr      SRegRd16
                    tsta
                    bne       SS.room
                    cmpb      <getn
                    bhs       SS.room
                    ldx       #Sn_SR
                    lbsr      SRegRdB
                    cmpb      #S.ESTAB
                    bne       SS.err
                    ldx       #1
                    os9       F$Sleep
                    bra       SS.wait
SS.room             ldx       #Sn_TXWR0
                    lbsr      SRegRd16
                    std       <rdptr
                    clr       <ix
                    ldx       ,s
SS.cp               lda       <ix
                    cmpa      <getn
                    beq       SS.cpdone
                    ldb       ,x+
                    stb       <sval
                    ldd       <rdptr
                    addb      <ix
                    adca      #0
                    pshs      x
                    tfr       d,x
                    ldb       <sval
                    lda       #BSR.S0TX
                    sta       <BsrVal
                    lbsr      WWr1
                    puls      x
                    inc       <ix
                    bra       SS.cp
SS.cpdone           ldd       <rdptr
                    addb      <getn
                    adca      #0
                    ldx       #Sn_TXWR0
                    lbsr      SRegWr16
                    ldx       #Sn_IRCLR
                    ldb       #IR.SENDOK+IR.TIMEOUT
                    lbsr      SRegWrB
                    ldb       #CMD.SEND
                    lbsr      SockCmd
                    ldy       #2000
SS.wsend            ldx       #Sn_IR
                    lbsr      SRegRdB
                    bitb      #IR.SENDOK
                    bne       SS.sent
                    bitb      #IR.TIMEOUT
                    bne       SS.err
                    ldx       #1
                    os9       F$Sleep
                    leay      -1,y
                    bne       SS.wsend
                    bra       SS.err
SS.sent             ldx       #Sn_IRCLR
                    ldb       #IR.SENDOK
                    lbsr      SRegWrB
                    puls      x
                    andcc     #$FE
                    rts
SS.err              puls      x
                    orcc      #$01
                    rts

*=====================================================================
* TelnetByte - feed one received byte through the telnet NVT state
*   machine. Displayable bytes go to the terminal (EmitDisplay);
*   option negotiations are answered on the socket (SendResp3).
*=====================================================================
TelnetByte          ldb       <tstate
                    cmpb      #0
                    beq       TBnorm
                    cmpb      #1
                    beq       TBiac
                    cmpb      #2
                    lbeq      TBopt
                    cmpb      #3
                    beq       TBsb
                    bra       TBsbiac
TBnorm              cmpa      #T.IAC
                    bne       TBemit
                    ldb       #1
                    stb       <tstate
                    rts
TBemit              lbsr      EmitDisplay
                    rts
TBiac               cmpa      #T.IAC
                    bne       TBiac2
                    lda       #$FF
                    lbsr      EmitDisplay
                    clr       <tstate
                    rts
TBiac2              cmpa      #T.SB
                    bne       TBiac3
                    ldb       #3
                    stb       <tstate
                    rts
TBiac3              cmpa      #T.WILL
                    blo       TBiacx
                    cmpa      #T.DONT
                    bhi       TBiacx
                    sta       <tverb
                    ldb       #2
                    stb       <tstate
                    rts
TBiacx              clr       <tstate
                    rts
TBopt               clr       <tstate
                    ldb       <tverb
                    cmpb      #T.DO
                    beq       TBgDO
                    cmpb      #T.DONT
                    beq       TBgDONT
                    cmpb      #T.WILL
                    beq       TBgWILL
                    ldb       #T.DONT             answer WONT x with DONT x
                    lbsr      SendResp3
                    rts
TBgDO               cmpa      #O.SGA              DO SGA -> WILL SGA; else WONT
                    bne       TBdoW
                    ldb       #T.WILL
                    lbsr      SendResp3
                    rts
TBdoW               ldb       #T.WONT
                    lbsr      SendResp3
                    rts
TBgDONT             ldb       #T.WONT
                    lbsr      SendResp3
                    rts
TBgWILL             cmpa      #O.ECHO             WILL ECHO/SGA -> DO; else DONT
                    beq       TBwDo
                    cmpa      #O.SGA
                    beq       TBwDo
                    ldb       #T.DONT
                    lbsr      SendResp3
                    rts
TBwDo               ldb       #T.DO
                    lbsr      SendResp3
                    rts
TBsb                cmpa      #T.IAC
                    bne       TBsbi
                    ldb       #4
                    stb       <tstate
                    rts
TBsbi               rts
TBsbiac             cmpa      #T.SE
                    bne       TBsbn
                    clr       <tstate
                    rts
TBsbn               ldb       #3
                    stb       <tstate
                    rts

* EmitDisplay - write byte A to standard output (path 1)
EmitDisplay         sta       OutByte,u
                    pshs      x,y
                    leax      OutByte,u
                    lda       #1
                    ldy       #1
                    os9       I$Write
                    puls      x,y
                    rts

* SendResp3 - send IAC,verb(B),option(A) to the socket
SendResp3           pshs      a,b
                    lda       #T.IAC
                    sta       NegBuf,u
                    ldb       1,s
                    stb       NegBuf+1,u
                    lda       ,s
                    sta       NegBuf+2,u
                    leas      2,s
                    leax      NegBuf,u
                    ldb       #3
                    lbsr      SockSend
                    rts

*=====================================================================
* DnsBuildQuery - X=host ptr, Y=out buffer. Returns D=query length.
* (Emulator-verified against a real "example.com A" query.)
*=====================================================================
DnsBuildQuery       pshs      y
                    lda       #$12
                    sta       ,y+
                    lda       #$34
                    sta       ,y+
                    lda       #$01
                    sta       ,y+
                    clr       ,y+
                    clr       ,y+
                    lda       #1
                    sta       ,y+
                    clr       ,y+
                    clr       ,y+
                    clr       ,y+
                    clr       ,y+
                    clr       ,y+
                    clr       ,y+
BQseg               sty       <lenpos
                    leay      1,y
                    clr       <lcount
BQch                lda       ,x
                    beq       BQsegend
                    cmpa      #CHR.SP
                    beq       BQsegend
                    cmpa      #CHR.CR
                    beq       BQsegend
                    cmpa      #'.
                    beq       BQdot
                    sta       ,y+
                    leax      1,x
                    inc       <lcount
                    bra       BQch
BQdot               leax      1,x
                    ldb       <lcount
                    pshs      x
                    ldx       <lenpos
                    stb       ,x
                    puls      x
                    bra       BQseg
BQsegend            ldb       <lcount
                    beq       BQempty
                    pshs      x
                    ldx       <lenpos
                    stb       ,x
                    puls      x
                    bra       BQfin
BQempty             ldy       <lenpos
BQfin               clr       ,y+
                    clr       ,y+
                    lda       #1
                    sta       ,y+
                    clr       ,y+
                    lda       #1
                    sta       ,y+
                    tfr       y,d
                    subd      ,s++
                    rts

*=====================================================================
* DnsParseResp - X=DNS msg, D=msg length, Y=IP out (4). carry=fail.
* (Emulator-verified: direct A and CNAME-then-A, with compression.)
*=====================================================================
DnsParseResp        stx       <msgbase
                    sty       <ipout
                    addd      <msgbase
                    std       <msgend
                    ldx       <msgbase
                    lda       3,x
                    anda      #$0F
                    lbne      PRfail
                    ldd       6,x
                    std       <ancnt
                    lbeq      PRfail
                    ldd       4,x
                    std       <qdcnt
                    leax      12,x
                    stx       <cp
PRqloop             ldd       <qdcnt
                    beq       PRqdone
                    lbsr      SkipName
                    ldx       <cp
                    leax      4,x
                    stx       <cp
                    ldd       <qdcnt
                    subd      #1
                    std       <qdcnt
                    bra       PRqloop
PRqdone             equ       *
PRaloop             ldd       <ancnt
                    lbeq      PRfail
                    lbsr      SkipName
                    ldx       <cp
                    ldd       ,x
                    cmpd      #1
                    beq       PRisA
                    ldd       8,x
                    std       <rdlen
                    leax      10,x
                    tfr       x,d
                    addd      <rdlen
                    std       <cp
                    ldd       <ancnt
                    subd      #1
                    std       <ancnt
                    bra       PRaloop
PRisA               ldx       <cp
                    ldd       8,x
                    cmpd      #4
                    bne       PRskipA
                    leax      10,x
                    ldy       <ipout
                    lda       ,x+
                    sta       ,y+
                    lda       ,x+
                    sta       ,y+
                    lda       ,x+
                    sta       ,y+
                    lda       ,x+
                    sta       ,y+
                    andcc     #$FE
                    rts
PRskipA             ldx       <cp
                    ldd       8,x
                    std       <rdlen
                    leax      10,x
                    tfr       x,d
                    addd      <rdlen
                    std       <cp
                    ldd       <ancnt
                    subd      #1
                    std       <ancnt
                    bra       PRaloop
PRfail              orcc      #$01
                    rts

* SkipName - advance <cp past a DNS name (labels / compression ptr)
SkipName            ldx       <cp
SNlp                lda       ,x
                    beq       SNend0
                    tfr       a,b
                    andb      #$C0
                    cmpb      #$C0
                    beq       SNptr
                    leax      1,x
                    pshs      a
                    tfr       x,d
                    addb      ,s+
                    adca      #0
                    tfr       d,x
                    bra       SNlp
SNend0              leax      1,x
                    stx       <cp
                    rts
SNptr               leax      2,x
                    stx       <cp
                    rts

*=====================================================================
* TryParseIP - X=host, Y=out(4). carry clear if a valid dotted IPv4.
* (Emulator-verified against valid/invalid/overflow/5-octet cases.)
*=====================================================================
TryParseIP          clr       <octet
TPlp                lbsr      TPByte
                    bcs       TPno
                    stb       ,y+
                    inc       <octet
                    lda       <octet
                    cmpa      #4
                    beq       TPlast
                    lda       ,x
                    cmpa      #'.
                    bne       TPno
                    leax      1,x
                    bra       TPlp
TPlast              lda       ,x
                    beq       TPyes
                    cmpa      #CHR.SP
                    beq       TPyes
                    cmpa      #CHR.CR
                    beq       TPyes
TPno                orcc      #$01
                    rts
TPyes               andcc     #$FE
                    rts

TPByte              ldd       #0
                    std       <acc
                    lda       ,x
                    suba      #'0
                    bcs       TPBno
                    cmpa      #9
                    bhi       TPBno
TPBlp               lda       ,x
                    suba      #'0
                    bcs       TPBok
                    cmpa      #9
                    bhi       TPBok
                    sta       <tmp
                    ldd       <acc
                    aslb
                    rola
                    std       <tmpw
                    ldd       <acc
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      <tmpw
                    addb      <tmp
                    adca      #0
                    std       <acc
                    lda       <acc
                    bne       TPBno
                    leax      1,x
                    bra       TPBlp
TPBok               ldb       <acc+1
                    andcc     #$FE
                    rts
TPBno               orcc      #$01
                    rts

*=====================================================================
* LoadConfig / parser  (identical to w6100recv/send, plus "dns" key)
*=====================================================================
LoadConfig          lbsr      CopyDefaults
                    leax      CfgPath,pcr
                    lda       #READ.
                    os9       I$Open
                    bcs       LC.def
                    sta       <cfpn
                    lda       <cfpn
                    leax      ConfBuf,u
                    ldy       #512
                    os9       I$Read
                    bcs       LC.rderr
                    leax      ConfBuf,u
                    stx       <cfptr
                    tfr       x,d
                    pshs      y
                    addd      ,s++
                    std       <cfend
                    lda       <cfpn
                    os9       I$Close
                    lbsr      ParseConfig
                    leax      MsgCfgF,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF
                    bra       LC.show
LC.rderr            lda       <cfpn
                    os9       I$Close
LC.def              leax      MsgCfgD,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF
LC.show             lbsr      ShowCfg
                    rts

CopyDefaults        leax      DefMAC,pcr
                    leay      CfgMAC,u
                    ldb       #28
CD.lp               lda       ,x+
                    sta       ,y+
                    decb
                    bne       CD.lp
                    rts

ShowCfg             leax      MsgLip,pcr
                    lbsr      PrStr
                    leax      CfgIP,u
                    lbsr      PrIP4
                    leax      MsgLgw,pcr
                    lbsr      PrStr
                    leax      CfgGW,u
                    lbsr      PrIP4
                    leax      MsgLdns,pcr
                    lbsr      PrStr
                    leax      CfgDNS,u
                    lbsr      PrIP4
                    lbsr      PrCRLF
                    rts

ParseConfig
NextLine            ldd       <cfptr
                    cmpd      <cfend
                    lbhs      PC.done
                    lbsr      SkipBlanks
                    ldx       <cfptr
                    cmpx      <cfend
                    bhs       PC.done
                    lda       ,x
                    cmpa      #'#
                    beq       SkipLine
                    cmpa      #'*
                    beq       SkipLine
                    cmpa      #CHR.CR
                    beq       SkipLine
                    cmpa      #CHR.LF
                    beq       SkipLine
                    lbsr      MatchKw
                    bcs       SkipLine
                    lda       <ptype
                    cmpa      #CT.IP4
                    beq       DoIP4
                    cmpa      #CT.MAC
                    beq       DoMAC
                    cmpa      #CT.PORT
                    beq       DoPort
                    bra       SkipLine
DoIP4               lbsr      ParseIP4
                    bra       SkipLine
DoMAC               lbsr      ParseMAC
                    bra       SkipLine
DoPort              lbsr      ParsePort
                    bra       SkipLine
SkipLine            lbsr      ToNextLine
                    bra       NextLine
PC.done             rts

SkipBlanks          ldx       <cfptr
SB.lp               cmpx      <cfend
                    bhs       SB.dn
                    lda       ,x
                    cmpa      #CHR.SP
                    beq       SB.adv
                    cmpa      #$09
                    beq       SB.adv
                    bra       SB.dn
SB.adv              leax      1,x
                    bra       SB.lp
SB.dn               stx       <cfptr
                    rts

ToNextLine          ldx       <cfptr
TN.lp               cmpx      <cfend
                    bhs       TN.dn
                    lda       ,x+
                    cmpa      #CHR.CR
                    beq       TN.eol
                    cmpa      #CHR.LF
                    beq       TN.eol
                    bra       TN.lp
TN.eol              cmpx      <cfend
                    bhs       TN.dn
                    ldb       ,x
                    cmpb      #CHR.LF
                    beq       TN.skip
                    cmpb      #CHR.CR
                    beq       TN.skip
                    bra       TN.dn
TN.skip             leax      1,x
TN.dn               stx       <cfptr
                    rts

MatchKw             leax      KwTab,pcr
                    stx       <kwptr
MK.entry            ldx       <kwptr
                    ldb       ,x
                    cmpb      #$FF
                    beq       MK.nomatch
                    stb       <ptype
                    ldd       1,x
                    leay      d,u
                    sty       <destp
                    leax      3,x
                    ldy       <cfptr
MK.cmp              lda       ,x+
                    beq       MK.kwend
                    ldb       ,y+
                    cmpb      #'A
                    blo       MK.nolc
                    cmpb      #'Z
                    bhi       MK.nolc
                    addb      #$20
MK.nolc             pshs      a
                    cmpb      ,s+
                    beq       MK.cmp
                    bra       MK.next
MK.kwend            cmpy      <cfend
                    bhs       MK.matched
                    lda       ,y
                    cmpa      #CHR.SP
                    beq       MK.matched
                    cmpa      #$09
                    beq       MK.matched
                    cmpa      #'=
                    beq       MK.matched
                    cmpa      #CHR.CR
                    beq       MK.matched
                    cmpa      #CHR.LF
                    beq       MK.matched
                    bra       MK.next
MK.matched          sty       <cfptr
                    lbsr      SkipToValue
                    andcc     #$FE
                    rts
MK.next             ldx       <kwptr
                    leax      3,x
MK.skn              lda       ,x+
                    bne       MK.skn
                    stx       <kwptr
                    bra       MK.entry
MK.nomatch          orcc      #$01
                    rts

SkipToValue         ldx       <cfptr
STV.lp              cmpx      <cfend
                    bhs       STV.dn
                    lda       ,x
                    cmpa      #CHR.SP
                    beq       STV.adv
                    cmpa      #$09
                    beq       STV.adv
                    cmpa      #'=
                    beq       STV.adv
                    bra       STV.dn
STV.adv             leax      1,x
                    bra       STV.lp
STV.dn              stx       <cfptr
                    rts

ParseIP4            ldy       <destp
                    clr       <octet
PI.lp               lbsr      ParseDecByte
                    bcs       PI.dn
                    stb       ,y+
                    inc       <octet
                    lda       <octet
                    cmpa      #4
                    beq       PI.dn
                    ldx       <cfptr
                    cmpx      <cfend
                    bhs       PI.dn
                    lda       ,x
                    cmpa      #'.
                    bne       PI.dn
                    leax      1,x
                    stx       <cfptr
                    bra       PI.lp
PI.dn               rts

ParsePort           lbsr      ParseDecByte
                    bcs       PP.dn
                    ldy       <destp
                    ldd       <acc
                    std       ,y
PP.dn               rts

ParseDecByte        ldx       <cfptr
                    clra
                    clrb
                    std       <acc
                    ldb       ,x
                    subb      #'0
                    bcs       PDB.nd
                    cmpb      #9
                    bhi       PDB.nd
PDB.lp              ldb       ,x
                    subb      #'0
                    bcs       PDB.end
                    cmpb      #9
                    bhi       PDB.end
                    lbsr      Acc10Add
                    leax      1,x
                    bra       PDB.lp
PDB.end             stx       <cfptr
                    ldb       <acc+1
                    andcc     #$FE
                    rts
PDB.nd              stx       <cfptr
                    orcc      #$01
                    rts

Acc10Add            pshs      b
                    ldd       <acc
                    aslb
                    rola
                    std       <tmpw
                    ldd       <acc
                    aslb
                    rola
                    aslb
                    rola
                    aslb
                    rola
                    addd      <tmpw
                    addb      ,s+
                    adca      #0
                    std       <acc
                    rts

ParseMAC            ldy       <destp
                    clr       <octet
PM.lp               lbsr      ParseHexByte
                    bcs       PM.dn
                    stb       ,y+
                    inc       <octet
                    lda       <octet
                    cmpa      #6
                    beq       PM.dn
                    ldx       <cfptr
                    cmpx      <cfend
                    bhs       PM.dn
                    lda       ,x
                    cmpa      #':
                    beq       PM.sep
                    cmpa      #'-
                    beq       PM.sep
                    bra       PM.dn
PM.sep              leax      1,x
                    stx       <cfptr
                    bra       PM.lp
PM.dn               rts

ParseHexByte        ldx       <cfptr
                    lda       ,x
                    lbsr      HexNib
                    bcs       PHB.nd
                    aslb
                    aslb
                    aslb
                    aslb
                    stb       <tmp
                    leax      1,x
                    lda       ,x
                    lbsr      HexNib
                    bcs       PHB.one
                    pshs      b
                    ldb       <tmp
                    orb       ,s+
                    leax      1,x
                    stx       <cfptr
                    andcc     #$FE
                    rts
PHB.one             ldb       <tmp
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    stx       <cfptr
                    andcc     #$FE
                    rts
PHB.nd              stx       <cfptr
                    orcc      #$01
                    rts

HexNib              cmpa      #'0
                    blo       HN.bad
                    cmpa      #'9
                    bhi       HN.af
                    tfr       a,b
                    subb      #'0
                    andcc     #$FE
                    rts
HN.af               anda      #$DF
                    cmpa      #'A
                    blo       HN.bad
                    cmpa      #'F
                    bhi       HN.bad
                    tfr       a,b
                    subb      #'A-10
                    andcc     #$FE
                    rts
HN.bad              orcc      #$01
                    rts

*=====================================================================
* Register access helpers
*=====================================================================
CRegRdB             lda       #BSR.COMMON
                    sta       <BsrVal
                    lbsr      WRd1
                    rts
CRegWrB             pshs      b
                    lda       #BSR.COMMON
                    sta       <BsrVal
                    puls      b
                    lbsr      WWr1
                    rts
SRegRdB             lda       #BSR.S0REG
                    sta       <BsrVal
                    lbsr      WRd1
                    rts
SRegWrB             pshs      b
                    lda       #BSR.S0REG
                    sta       <BsrVal
                    puls      b
                    lbsr      WWr1
                    rts
SRegRd16            stx       <soff
                    lda       #BSR.S0REG
                    sta       <BsrVal
                    ldx       <soff
                    lbsr      WRd1
                    stb       <sval
                    ldx       <soff
                    leax      1,x
                    lbsr      WRd1
                    stb       <sval+1
                    ldd       <sval
                    rts
SRegWr16            stx       <soff
                    std       <sval
                    lda       #BSR.S0REG
                    sta       <BsrVal
                    ldx       <soff
                    ldb       <sval
                    lbsr      WWr1
                    ldx       <soff
                    leax      1,x
                    ldb       <sval+1
                    lbsr      WWr1
                    rts

BlkWr               pshs      x,y
                    stb       <tmp
BW.lp               lda       <tmp
                    beq       BW.dn
                    ldb       ,x+
                    pshs      x
                    tfr       y,x
                    lbsr      WWr1
                    puls      x
                    leay      1,y
                    dec       <tmp
                    bra       BW.lp
BW.dn               puls      x,y,pc

WRd1                pshs      x
                    tfr       x,d
                    sta       <RegHi
                    stb       <RegLo
                    lda       <RegHi
                    lbsr      WSetARH
                    lda       <BsrVal
                    sta       W.BSR
                    lda       <RegLo
                    sta       W.ARL
                    lda       #CTL.GO.RDSINGLE
                    sta       W.CTRL
                    ora       #CTL.START
                    sta       W.CTRL
                    lbsr      WWaitBusy
                    ldb       W.DATA
                    puls      x,pc

WWr1                pshs      x
                    stb       <RegData
                    tfr       x,d
                    sta       <RegHi
                    stb       <RegLo
                    lda       <RegHi
                    lbsr      WSetARH
                    lda       <BsrVal
                    sta       W.BSR
                    lda       <RegLo
                    sta       W.ARL
                    lda       <RegData
                    sta       W.DATA
                    lda       #CTL.GO.WRSINGLE
                    sta       W.CTRL
                    ora       #CTL.START
                    sta       W.CTRL
                    lbsr      WWaitBusy
                    puls      x,pc

WSetARH             sta       W.MR
                    lda       #CTL.GO.WRMR
                    sta       W.CTRL
                    ora       #CTL.START
                    sta       W.CTRL
                    lbsr      WWaitBusy
                    rts

WWaitBusy           pshs      x
                    ldx       #$FFFF
WB.lp               lda       W.CTRL
                    bpl       WB.dn
                    leax      -1,x
                    bne       WB.lp
                    lda       #1
                    sta       <BusyTO
                    puls      x
                    rts
WB.dn               clr       <BusyTO
                    puls      x
                    rts

*=====================================================================
* SockCmd / WaitInit / WaitEstab / WaitUdp
*=====================================================================
SockCmd             pshs      b
                    ldx       #Sn_CR
                    lbsr      SRegWrB
                    puls      b
                    ldx       #$4000
SC.w                pshs      x
                    ldx       #Sn_CR
                    lbsr      SRegRdB
                    puls      x
                    tstb
                    beq       SC.dn
                    leax      -1,x
                    bne       SC.w
SC.dn               rts

WaitInit            ldy       #200
WI.lp               ldx       #Sn_SR
                    lbsr      SRegRdB
                    cmpb      #S.INIT
                    beq       WI.ok
                    ldx       #1
                    os9       F$Sleep
                    leay      -1,y
                    bne       WI.lp
                    orcc      #$01
                    rts
WI.ok               andcc     #$FE
                    rts

WaitEstab           ldy       #600
WE.lp               ldx       #Sn_SR
                    lbsr      SRegRdB
                    cmpb      #S.ESTAB
                    beq       WE.ok
                    tstb
                    beq       WE.fail
                    ldx       #Sn_IR
                    lbsr      SRegRdB
                    bitb      #IR.TIMEOUT
                    bne       WE.fail
                    ldx       #1
                    os9       F$Sleep
                    leay      -1,y
                    bne       WE.lp
WE.fail             orcc      #$01
                    rts
WE.ok               andcc     #$FE
                    rts

WaitUdp             ldy       #200
WU.lp               ldx       #Sn_SR
                    lbsr      SRegRdB
                    cmpb      #S.UDP
                    beq       WUok
                    ldx       #1
                    os9       F$Sleep
                    leay      -1,y
                    bne       WU.lp
                    orcc      #$01
                    rts
WUok                andcc     #$FE
                    rts

*=====================================================================
* Output helpers
*=====================================================================
PrCh                sta       OutByte,u
                    pshs      x,y,a
                    leax      OutByte,u
                    lda       #1
                    ldy       #1
                    os9       I$Write
                    puls      a,y,x
                    rts

PrDec32             clr       <digcnt
PD.lp               lbsr      Div10Num
                    addb      #'0
                    pshs      b
                    inc       <digcnt
                    lda       <Num
                    ora       <Num+1
                    ora       <Num+2
                    ora       <Num+3
                    bne       PD.lp
PD.pr               puls      b
                    stb       OutBuf,u
                    leax      OutBuf,u
                    lda       #1
                    ldy       #1
                    os9       I$Write
                    dec       <digcnt
                    bne       PD.pr
                    rts

Div10Num            clra
                    ldb       <Num
                    bsr       D10s
                    stb       <Num
                    ldb       <Num+1
                    bsr       D10s
                    stb       <Num+1
                    ldb       <Num+2
                    bsr       D10s
                    stb       <Num+2
                    ldb       <Num+3
                    bsr       D10s
                    stb       <Num+3
                    tfr       a,b
                    rts
D10s                ldx       #0
D10s.lp             cmpd      #10
                    blo       D10s.dn
                    subd      #10
                    leax      1,x
                    bra       D10s.lp
D10s.dn             stx       <tmpw
                    tfr       b,a
                    ldb       <tmpw+1
                    rts

PrIP4               ldb       ,x+
                    pshs      x
                    lbsr      PrOctet
                    puls      x
                    lbsr      PrDot
                    ldb       ,x+
                    pshs      x
                    lbsr      PrOctet
                    puls      x
                    lbsr      PrDot
                    ldb       ,x+
                    pshs      x
                    lbsr      PrOctet
                    puls      x
                    lbsr      PrDot
                    ldb       ,x+
                    pshs      x
                    lbsr      PrOctet
                    puls      x
                    rts
PrOctet             pshs      b
                    clra
                    clrb
                    std       <Num
                    std       <Num+2
                    puls      b
                    stb       <Num+3
                    lbsr      PrDec32
                    rts
PrDot               pshs      x,y,a
                    lda       #'.
                    sta       OutBuf,u
                    leax      OutBuf,u
                    lda       #1
                    ldy       #1
                    os9       I$Write
                    puls      a,y,x,pc

PrName              pshs      x
PN.lp               lda       ,x
                    cmpa      #CHR.CR
                    beq       PN.dn
                    cmpa      #CHR.SP
                    beq       PN.dn
                    sta       OutBuf,u
                    pshs      x
                    leax      OutBuf,u
                    lda       #1
                    ldy       #1
                    os9       I$Write
                    puls      x
                    leax      1,x
                    bra       PN.lp
PN.dn               puls      x,pc

PrStr               pshs      x,y,a,b
                    tfr       x,y
                    ldd       #0
                    std       <tmpw
PS.len              lda       ,x+
                    beq       PS.go
                    ldd       <tmpw
                    addd      #1
                    std       <tmpw
                    bra       PS.len
PS.go               tfr       y,x
                    ldy       <tmpw
                    lda       #1
                    os9       I$Write
                    puls      b,a,y,x,pc

PrCRLF              pshs      x,y,a
                    leax      CRLF,pcr
                    lda       #1
                    ldy       #2
                    os9       I$Write
                    puls      a,y,x,pc

*=====================================================================
* Built-in default network config (28 bytes: MAC,IP,MASK,GW,SRV,PORT,DNS)
*=====================================================================
DefMAC              fcb       $02,$00,$00,$12,$34,$56
DefIP               fcb       192,168,8,222
DefMask             fcb       255,255,255,0
DefGW               fcb       192,168,8,1
DefSrv              fcb       192,168,8,181
DefPort             fdb       6809
DefDNS              fcb       8,8,8,8

CfgPath             fcc       "/DD/SYS/w6100ipconfig"
                    fcb       $0D

*=====================================================================
* keyword table: fcb type ; fdb Cfg-offset ; fcc name ; fcb 0 ; $FF end
*=====================================================================
KwTab               fcb       CT.MAC
                    fdb       CfgMAC
                    fcc       /mac/
                    fcb       0
                    fcb       CT.IP4
                    fdb       CfgIP
                    fcc       /ip/
                    fcb       0
                    fcb       CT.IP4
                    fdb       CfgMask
                    fcc       /mask/
                    fcb       0
                    fcb       CT.IP4
                    fdb       CfgMask
                    fcc       /netmask/
                    fcb       0
                    fcb       CT.IP4
                    fdb       CfgMask
                    fcc       /subnet/
                    fcb       0
                    fcb       CT.IP4
                    fdb       CfgGW
                    fcc       /gateway/
                    fcb       0
                    fcb       CT.IP4
                    fdb       CfgGW
                    fcc       /gw/
                    fcb       0
                    fcb       CT.IP4
                    fdb       CfgSrv
                    fcc       /server/
                    fcb       0
                    fcb       CT.IP4
                    fdb       CfgDNS
                    fcc       /dns/
                    fcb       0
                    fcb       CT.PORT
                    fdb       CfgPort
                    fcc       /port/
                    fcb       0
                    fcb       $FF

*-----------------------------------------------------------
* Messages
*-----------------------------------------------------------
MsgBanner           fcc       /w6100tel - W6100 telnet client/
                    fcb       0
MsgCfgF             fcc       "Config: /DD/SYS/w6100ipconfig"
                    fcb       0
MsgCfgD             fcc       "Config: built-in defaults (no /DD/SYS/w6100ipconfig)"
                    fcb       0
MsgLip              fcc       /  ip /
                    fcb       0
MsgLgw              fcc       /  gw /
                    fcb       0
MsgLdns             fcc       /  dns /
                    fcb       0
MsgResolv           fcc       /Resolving /
                    fcb       0
MsgUsing            fcc       /Connecting to /
                    fcb       0
MsgConn             fcc       /Connected. Ctrl-] to quit./
                    fcb       0
MsgBye              fcc       /Connection closed./
                    fcb       0
MsgUsage            fcc       /Usage: w6100tel <host> [port]/
                    fcb       0
MsgChipF            fcc       "W6100 not responding (CIDR0 != $61)"
                    fcb       0
MsgDnsF             fcc       "DNS resolution failed"
                    fcb       0
MsgSockF            fcc       "Socket open failed"
                    fcb       0
MsgConnF            fcc       "Connect failed - check host, IP config and cabling"
                    fcb       0
CRLF                fcb       $0D,$0A

                    emod
eom                 equ       *
                    end
