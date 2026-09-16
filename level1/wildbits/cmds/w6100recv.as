********************************************************************
* w6100recv - receive a file over W6100 Ethernet (TCP) into a
*             NitrOS-9 disk file.
*
*   Usage:  w6100recv <filename>
*
* The Wildbits K2 opens TCP SOCKET 0 as a CLIENT and connects to a
* Python "file server". The server sends a 4-byte big-endian length
* followed by that many payload bytes; w6100recv writes the payload
* to <filename> and reports the byte count.
*
* NETWORK CONFIGURATION
* ---------------------
* At startup w6100recv reads its IP settings from a plain-text file
*   /DD/SYS/w6100ipconfig   (see CfgPath below to change)
* so end users configure the network WITHOUT reassembling. If the
* file is missing/unreadable, the built-in defaults (Def* below) are
* used. Recognised keywords (one per line, "key value" or "key=value",
* '#' or '*' begins a comment):
*   ip       192.168.8.222
*   mask     255.255.255.0     (aliases: subnet, netmask)
*   gateway  192.168.8.1       (alias: gw)
*   server   192.168.8.181
*   mac      02:00:00:12:34:56
*   port     6809
* Any key omitted keeps its built-in default.
*
* Wire protocol (server -> K2):
*   [ len3 len2 len1 len0 ]   4-byte big-endian unsigned length L
*   [ L bytes of file data ]
*
* Built on the bridge protocol proven by w6100eth.as. Block-select
* bytes for IDM_BSR (confirmed vs WIZnet io6Library BUS_INDIR path):
*   common regs $00 ; SOCKET0 regs $08 ; SOCKET0 RX buf $18.
********************************************************************

                    nam       w6100recv
                    ttl       Receive a file over W6100 Ethernet

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

*-----------------------------------------------------------
* K2 <-> W6100 bridge registers (same as w6100eth.as)
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
BSR.S0RX            equ       $18

* Common register offsets (block $00)
CIDR0               equ       $0000
NETLCKR             equ       $41F5
NETUNLCK            equ       $3A
SHAR0               equ       $4120
GAR0                equ       $4130
SUBR0               equ       $4134
SIPR0               equ       $4138

* SOCKET0 register offsets (block $08)
Sn_MR               equ       $0000
Sn_CR               equ       $0010
Sn_IR               equ       $0020
Sn_SR               equ       $0030
Sn_PORT0            equ       $0114
Sn_DIPR0            equ       $0120
Sn_DPRT0            equ       $0140
Sn_RXRSR0           equ       $0224
Sn_RXRD0            equ       $0228

CMD.OPEN            equ       $01
CMD.CONNECT         equ       $04
CMD.DISCON          equ       $08
CMD.CLOSE           equ       $10
CMD.RECV            equ       $40
MR.TCP4             equ       $01

S.CLOSED            equ       $00
S.INIT              equ       $13
S.ESTAB             equ       $17
S.CLOSEWAIT         equ       $1C
IR.TIMEOUT          equ       $08

CHR.SP              equ       $20
CHR.CR              equ       $0D
BUFSZ               equ       200

* config value types
T.IP4               equ       1
T.MAC               equ       2
T.PORT              equ       3

*=====================================================================
* Client (K2) source port. Everything else (ip/mask/gw/server/mac/
* server port) comes from /DD/SYS/w6100ipconfig or the Def* table.
*=====================================================================
MYPORT              equ       $C000

                    mod       eom,name,tylg,atrv,start,size

*-----------------------------------------------------------
* Process data area. DP-addressed scratch stays < 256; the big
* buffers (Buf/Hdr/ConfBuf) are only ever accessed U-relative.
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
dptr                rmb       2
fpath               rmb       1
NamePtr             rmb       2
Remain              rmb       4
Total               rmb       4
Num                 rmb       4
rem                 rmb       1
want                rmb       1
gotcnt              rmb       1
digcnt              rmb       1
OutBuf              rmb       8
* --- config parser scratch ---
cfptr               rmb       2
cfend               rmb       2
kwptr               rmb       2
destp               rmb       2
ptype               rmb       1
acc                 rmb       2
octet               rmb       1
cfpn                rmb       1
* --- live network config (defaults copied in, then file overrides) ---
* keep these six contiguous & in this order (CopyDefaults block-copies)
CfgMAC              rmb       6
CfgIP               rmb       4
CfgMask             rmb       4
CfgGW               rmb       4
CfgSrv              rmb       4
CfgPort             rmb       2
* --- large buffers (U-relative only) ---
Buf                 rmb       BUFSZ
Hdr                 rmb       4
ConfBuf             rmb       512
                    rmb       300       stack
size                equ       .

name                fcs       /w6100recv/
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

* --- load network config (file or built-in defaults) ---
                    lbsr      LoadConfig

* --- confirm the W6100 answers ---
                    ldx       #CIDR0
                    lbsr      CRegRdB
                    cmpb      #$61
                    lbne      ChipFail

* --- unlock and load MAC/GW/SUBNET/IP from Cfg* ---
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

* --- create the output file (overwrite if present) ---
                    ldx       <NamePtr
                    ldd       #(WRITE.*256)+UPDAT.
                    os9       I$Create
                    bcc       FileOK
                    ldx       <NamePtr
                    os9       I$Delete
                    ldx       <NamePtr
                    ldd       #(WRITE.*256)+UPDAT.
                    os9       I$Create
                    lbcs      FileErr
FileOK              sta       <fpath

* --- open SOCKET0 as TCP, source port, OPEN, wait INIT ---
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

* --- destination IP/port from Cfg*, then CONNECT ---
                    lda       #BSR.S0REG
                    sta       <BsrVal
                    leax      CfgSrv,u
                    ldy       #Sn_DIPR0
                    ldb       #4
                    lbsr      BlkWr
                    ldx       #Sn_DPRT0
                    ldd       <CfgPort
                    lbsr      SRegWr16

                    leax      MsgConn,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF

                    ldb       #CMD.CONNECT
                    lbsr      SockCmd
                    lbsr      WaitEstab
                    lbcs      ConnErr

                    leax      MsgRcv,pcr
                    lbsr      PrStr
                    ldx       <NamePtr
                    lbsr      PrName
                    lbsr      PrCRLF

* --- read the 4-byte length header ---
                    leax      Hdr,u
                    ldb       #4
                    lbsr      ReadExact
                    lbcs      RcvErr

                    ldd       Hdr,u
                    std       <Remain
                    ldd       Hdr+2,u
                    std       <Remain+2
                    clra
                    clrb
                    std       <Total
                    std       <Total+2

*=====================================================================
* Receive loop
*=====================================================================
RxLoop              lbsr      RemainZero
                    lbeq      RxDone
                    lbsr      CalcWant
                    leax      Buf,u
                    ldb       <want
                    lbsr      WSockGetBlk
                    lbcs      RxTrunc
                    stb       <gotcnt
                    clra
                    ldb       <gotcnt
                    tfr       d,y
                    lda       <fpath
                    leax      Buf,u
                    os9       I$Write
                    lbcs      FileWErr
                    lbsr      AddTotal
                    lbsr      SubRemain
                    bra       RxLoop

*=====================================================================
* exits
*=====================================================================
RxDone              ldb       #CMD.DISCON
                    lbsr      SockCmd
                    ldb       #CMD.CLOSE
                    lbsr      SockCmd
                    lda       <fpath
                    os9       I$Close
                    leax      MsgWrote,pcr
                    lbsr      PrStr
                    lbsr      PrTotal
                    leax      MsgBytes,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF
                    clrb
                    os9       F$Exit

RxTrunc             ldb       #CMD.CLOSE
                    lbsr      SockCmd
                    lda       <fpath
                    os9       I$Close
                    leax      MsgTrunc,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF
                    leax      MsgGot,pcr
                    lbsr      PrStr
                    lbsr      PrTotal
                    leax      MsgBytes,pcr
                    lbsr      PrStr
                    lbsr      PrCRLF
                    bra       ExitErr

RcvErr              lda       <fpath
                    os9       I$Close
                    ldb       #CMD.CLOSE
                    lbsr      SockCmd
                    leax      MsgNoData,pcr
                    bra       ErrPrint
FileWErr            lda       <fpath
                    os9       I$Close
                    leax      MsgDiskW,pcr
                    bra       ErrPrint
ConnErr             leax      MsgConnF,pcr
                    bra       CloseSockErr
SockErr             leax      MsgSockF,pcr
CloseSockErr        pshs      x
                    ldb       #CMD.CLOSE
                    lbsr      SockCmd
                    lda       <fpath
                    os9       I$Close
                    puls      x
                    bra       ErrPrint
FileErr             leax      MsgFileF,pcr
                    bra       ErrPrint
ChipFail            leax      MsgChipF,pcr
                    bra       ErrPrint
Usage               leax      MsgUsage,pcr
ErrPrint            lbsr      PrStr
                    lbsr      PrCRLF
ExitErr             ldb       #$01
                    os9       F$Exit

*=====================================================================
* LoadConfig - copy defaults, then apply /DD/SYS/w6100ipconfig if
*              present, then display the resulting settings.
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
                    addd      ,s++            D = ConfBuf + bytes read
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

* CopyDefaults - Def* (ROM) -> Cfg* (RAM), 24 contiguous bytes
CopyDefaults        leax      DefMAC,pcr
                    leay      CfgMAC,u
                    ldb       #24
CD.lp               lda       ,x+
                    sta       ,y+
                    decb
                    bne       CD.lp
                    rts

* ShowCfg - print the active IP/GW/mask and server:port
ShowCfg             leax      MsgLip,pcr
                    lbsr      PrStr
                    leax      CfgIP,u
                    lbsr      PrIP4
                    leax      MsgLgw,pcr
                    lbsr      PrStr
                    leax      CfgGW,u
                    lbsr      PrIP4
                    leax      MsgLmask,pcr
                    lbsr      PrStr
                    leax      CfgMask,u
                    lbsr      PrIP4
                    lbsr      PrCRLF
                    leax      MsgLsrv,pcr
                    lbsr      PrStr
                    leax      CfgSrv,u
                    lbsr      PrIP4
                    lda       #':
                    sta       OutBuf,u
                    leax      OutBuf,u
                    lda       #1
                    ldy       #1
                    os9       I$Write
                    clra
                    clrb
                    std       <Num
                    ldd       <CfgPort
                    std       <Num+2
                    lbsr      PrDec32
                    lbsr      PrCRLF
                    rts

*=====================================================================
* ParseConfig - parse ConfBuf[cfptr..cfend) into Cfg* fields
*=====================================================================
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
                    cmpa      #$0A
                    beq       SkipLine
                    lbsr      MatchKw
                    bcs       SkipLine
                    lda       <ptype
                    cmpa      #T.IP4
                    beq       DoIP4
                    cmpa      #T.MAC
                    beq       DoMAC
                    cmpa      #T.PORT
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
                    cmpa      #$0A
                    beq       TN.eol
                    bra       TN.lp
TN.eol              cmpx      <cfend
                    bhs       TN.dn
                    ldb       ,x
                    cmpb      #$0A
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
                    cmpa      #$0A
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
* ReadExact - read exactly B bytes into (X). Carry set on early close.
*=====================================================================
ReadExact           stb       <tmp
                    stx       <dptr
RE.lp               lda       <tmp
                    beq       RE.ok
                    ldx       <dptr
                    ldb       <tmp
                    lbsr      WSockGetBlk
                    bcs       RE.fail
                    pshs      b
                    clra
                    addd      <dptr
                    std       <dptr
                    lda       <tmp
                    suba      ,s+
                    sta       <tmp
                    bra       RE.lp
RE.ok               andcc     #$FE
                    rts
RE.fail             orcc      #$01
                    rts

*=====================================================================
* WSockGetBlk - blocking read of up to B bytes from SOCKET0 into (X).
*   Exit: B = count (>=1), carry clear; carry set on EOF/timeout.
*=====================================================================
WSockGetBlk         pshs      x
                    stb       <gotcnt
                    ldy       #1200
WGB.lp              ldx       ,s
                    ldb       <gotcnt
                    lbsr      WSockGet
                    tstb
                    bne       WGB.got
                    ldx       #Sn_SR
                    lbsr      SRegRdB
                    cmpb      #S.CLOSEWAIT
                    beq       WGB.eof
                    cmpb      #S.CLOSED
                    beq       WGB.eof
                    ldx       #1
                    os9       F$Sleep
                    leay      -1,y
                    bne       WGB.lp
WGB.eof             puls      x
                    orcc      #$01
                    rts
WGB.got             puls      x
                    andcc     #$FE
                    rts

*=====================================================================
* WSockGet - non-blocking read up to B bytes from SOCKET0 RX into (X).
*            Exit B = count actually read (0 if none).
*=====================================================================
WSockGet            pshs      x
                    stb       <getn
                    ldx       #Sn_RXRSR0
                    lbsr      SRegRd16
                    cmpd      #0
                    bne       WG.have
                    puls      x
                    clrb
                    rts
WG.have             tsta
                    bne       WG.max
                    cmpb      <getn
                    bhs       WG.max
                    stb       <getn
WG.max              ldx       #Sn_RXRD0
                    lbsr      SRegRd16
                    std       <rdptr
                    clr       <ix
                    ldx       ,s
WG.cp               lda       <ix
                    cmpa      <getn
                    beq       WG.done
                    ldd       <rdptr
                    addb      <ix
                    adca      #0
                    pshs      x
                    tfr       d,x
                    lda       #BSR.S0RX
                    sta       <BsrVal
                    lbsr      WRd1
                    puls      x
                    stb       ,x+
                    inc       <ix
                    bra       WG.cp
WG.done             ldd       <rdptr
                    addb      <getn
                    adca      #0
                    ldx       #Sn_RXRD0
                    lbsr      SRegWr16
                    ldb       #CMD.RECV
                    lbsr      SockCmd
                    ldb       <getn
                    puls      x
                    rts

*=====================================================================
* SockCmd - issue command B to Sn_CR, wait for it to clear
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

*=====================================================================
* WRd1 / WWr1 - single-byte read/write via the bridge. X=offset,
*               <BsrVal=block. WRd1 exits B=data. Both keep X.
*=====================================================================
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
* 32-bit helpers on Remain / Total (MSB-first)
*=====================================================================
RemainZero          lda       <Remain
                    ora       <Remain+1
                    ora       <Remain+2
                    ora       <Remain+3
                    rts
CalcWant            lda       <Remain
                    ora       <Remain+1
                    ora       <Remain+2
                    bne       CW.max
                    ldb       <Remain+3
                    cmpb      #BUFSZ
                    bhs       CW.max
                    stb       <want
                    rts
CW.max              ldb       #BUFSZ
                    stb       <want
                    rts
SubRemain           ldb       <Remain+3
                    subb      <gotcnt
                    stb       <Remain+3
                    ldb       <Remain+2
                    sbcb      #0
                    stb       <Remain+2
                    ldb       <Remain+1
                    sbcb      #0
                    stb       <Remain+1
                    ldb       <Remain
                    sbcb      #0
                    stb       <Remain
                    rts
AddTotal            ldb       <Total+3
                    addb      <gotcnt
                    stb       <Total+3
                    ldb       <Total+2
                    adcb      #0
                    stb       <Total+2
                    ldb       <Total+1
                    adcb      #0
                    stb       <Total+1
                    ldb       <Total
                    adcb      #0
                    stb       <Total
                    rts

*=====================================================================
* Output helpers
*=====================================================================
PrTotal             ldd       <Total
                    std       <Num
                    ldd       <Total+2
                    std       <Num+2
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

* PrIP4 - print 4 bytes at X as dotted decimal
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

* PrName - print filename at X up to space/CR
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
* Built-in default network config (used if the file is absent).
* Keep these 24 bytes contiguous & ordered MAC,IP,MASK,GW,SRV,PORT
* to match the Cfg* fields (CopyDefaults block-copies them).
*=====================================================================
DefMAC              fcb       $02,$00,$00,$12,$34,$56
DefIP               fcb       192,168,1,222
DefMask             fcb       255,255,255,0
DefGW               fcb       192,168,1,254
DefSrv              fcb       192,168,1,100     server ip
DefPort             fdb       6809

* config file pathlist (edit to relocate the config file)
CfgPath             fcc       "/DD/SYS/w6100ipconfig"
                    fcb       $0D

*=====================================================================
* keyword table: fcb type ; fdb Cfg-offset ; fcc name ; fcb 0 ; $FF end
*=====================================================================
KwTab               fcb       T.MAC
                    fdb       CfgMAC
                    fcc       /mac/
                    fcb       0
                    fcb       T.IP4
                    fdb       CfgIP
                    fcc       /ip/
                    fcb       0
                    fcb       T.IP4
                    fdb       CfgMask
                    fcc       /mask/
                    fcb       0
                    fcb       T.IP4
                    fdb       CfgMask
                    fcc       /netmask/
                    fcb       0
                    fcb       T.IP4
                    fdb       CfgMask
                    fcc       /subnet/
                    fcb       0
                    fcb       T.IP4
                    fdb       CfgGW
                    fcc       /gateway/
                    fcb       0
                    fcb       T.IP4
                    fdb       CfgGW
                    fcc       /gw/
                    fcb       0
                    fcb       T.IP4
                    fdb       CfgSrv
                    fcc       /server/
                    fcb       0
                    fcb       T.PORT
                    fdb       CfgPort
                    fcc       /port/
                    fcb       0
                    fcb       $FF

*-----------------------------------------------------------
* Messages
*-----------------------------------------------------------
MsgBanner           fcc       /w6100recv - W6100 TCP file receive/
                    fcb       0
MsgCfgF             fcc       "Config: /DD/SYS/w6100ipconfig"
                    fcb       0
MsgCfgD             fcc       "Config: built-in defaults (no /DD/SYS/w6100ipconfig)"
                    fcb       0
MsgLip              fcc       /  ip /
                    fcb       0
MsgLgw              fcc       /  gw /
                    fcb       0
MsgLmask            fcc       /  mask /
                    fcb       0
MsgLsrv             fcc       /  server /
                    fcb       0
MsgConn             fcc       /Connecting to server.../
                    fcb       0
MsgRcv              fcc       /Connected. Receiving /
                    fcb       0
MsgWrote            fcc       /Wrote /
                    fcb       0
MsgGot              fcc       /Received /
                    fcb       0
MsgBytes            fcc       / bytes/
                    fcb       0
MsgTrunc            fcc       "Connection closed before all data arrived"
                    fcb       0
MsgUsage            fcc       /Usage: w6100recv <filename>/
                    fcb       0
MsgChipF            fcc       "W6100 not responding (CIDR0 != $61)"
                    fcb       0
MsgFileF            fcc       "Cannot create output file"
                    fcb       0
MsgSockF            fcc       "Socket open failed"
                    fcb       0
MsgConnF            fcc       "Connect failed - check server, IP config and cabling"
                    fcb       0
MsgNoData           fcc       "No data received (connection closed)"
                    fcb       0
MsgDiskW            fcc       "Disk write error"
                    fcb       0
CRLF                fcb       $0D,$0A

                    emod
eom                 equ       *
                    end
