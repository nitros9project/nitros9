
********************************************************************
* WizFi360 Hub
* Goal: Master driver responsible for the connection.
* and virtual ports
*
* Reg0 = RxD channel/connection# (a device cannot claim this port unless this matches its device channel#)
* Reg1 = RxD data
* Reg2-3 = RxD bytes ready in the FIFO
*
* Reg4 = TxD channel/connection#
* Reg5 = TxD data
* Reg6-7 = TxD FIFO bytes left (a device cannot claim this port until this is zero)
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  1       2025/06/11  Roger Taylor
*  Initial version - concept testing

                    nam       WizFiHub
                    ttl       Foenix WizFi360 Hub

                    ifp1
                    use       defsfile
                    endc

WIZFI_INTERRUPT     equ       INT_TIMER_0         Convenience placement
VIRQCNT             equ       1
WORK_SLOT	    equ       MMU_SLOT_2
MMU_WINDOW          equ       $4000

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

* Being tweaked for goldilox
TRATE equ 300
*TRATE equ 800 * choppy response but output is fast

* Need to put these in defs folder since hub and driver need to both match
* Offsets into virtual port packet
 org $00
RxPending rmb 1         bit 7 is RxD Ready bit   bits 2..0 is channel #
RxData rmb 1            The byte ready to be read by the device who knows its theirs
RxSize rmb 2            Bytes left in the RxD FIFO
TxPending rmb 1         bit 7 is TxD Ready bit (1=ready)   bits 2..0 is channel #
TxData rmb 1
TxSize rmb 2


*============================================================================
Mask_SocketDev            equ       %00001000
IRQ_State_ListenByte      equ       $01
IRQ_State_ListenPkt       equ       $02
IRQ_State_ListenConnect   equ       $03
IRQ_State_WritePacket     equ       $04
IRQ_State_ListenPktPrompt equ       $05
IRQ_State_ListenPktVerify equ       $06

*============================================================================

* Globals Page Definitions (must be 256 bytes max)
* WizFi.StatCnt          equ       15+16
*                        org       $00
* D.WizFi                rmb       4
* WizFi.StatTbl          rmb       WizFi.StatCnt          page pointers for terminal device static storage



* static data area definitions
                    org       V.SCF               allow for SCF manager data area
Cpy.Stat            rmb       1                   Status register copy
CpyDCDSR            rmb       1                   DSR+DCD status copy
Mask.DCD            rmb       1                   DCD status bit mask (MUST immediately precede Mask.DSR)
Mask.DSR            rmb       1                   DSR status bit mask (MUST immediately follow Mask.DCD)
CDSigPID            rmb       1                   process ID for CD signal
CDSigSig            rmb       1                   CD signal code
FloCtlRx            rmb       1                   Rx flow control flags
FloCtlTx            rmb       1                   Tx flow control flags
RxBufEnd            rmb       2                   end of Rx buffer
RxBufGet            rmb       2                   Rx buffer output pointer
RxBufMax            rmb       2                   Send XOFF (if enabled) at this point
RxBufMin            rmb       2                   Send XON (if XOFF sent) at this point
RxBufPtr            rmb       2                   pointer to Rx buffer
RxBufPut            rmb       2                   Rx buffer input pointer
RxBufSiz            rmb       2                   Rx buffer size
RxDatLen            rmb       2                   current length of data in Rx buffer
WxDatLen            rmb       2
SigSent             rmb       1                   keyboard abort/interrupt signal already sent
SSigPID             rmb       1                   SS.SSig process ID
SSigSig             rmb       1                   SS.SSig signal code
WritFlag            rmb       1                   initial write attempt flag
Wrk.Type            rmb       1                   type work byte (MUST immediately precede Wrk.Baud)
Wrk.Baud            rmb       1                   baud work byte (MUST immediately follow Wrk.Type)
Wrk.XTyp            rmb       1                   extended type work byte
VIRQBF              rmb       5                   buffer for VIRQ
LastRxCount         rmb       1

*============================================================================
MasterRxDget        rmb       2
MasterRxDput        rmb       2
MasterRxDBlock      rmb       1

*============================================================================
ind_ControlReg      rmb       2
ind_DataReg         rmb       2
ind_RxD_RD_CountReg rmb       2
ind_RxD_WR_CountReg rmb       2
ind_TxD_RD_CountReg rmb       2
ind_TxD_WR_CountReg rmb       2

*== INTERUPT SERVICE ROUTINE ================================================
IRQ_State           rmb       1
PendingByte         rmb       1
LastRxD             rmb       1
IpdLen              rmb       2
PktReadPos             rmb       1
IpdLenChar          rmb       1
DeviceMode          rmb       1		          Mode of the device descriptor (0 = no packets)
DeviceChannel       rmb       1                  Connection # of the device descriptor (0-3)
PacketChannel       rmb       1

*== WRITING PACKETS =========================================================
WritePos            rmb       1
WritePacketTimer    rmb       1
OutPktLaydown       rmb       1
OutPktPickup        rmb       1
strDecimal5         rmb       5

*============================================================================
* sc6551 residuals
DataReg             rmb       1                   receive/transmit Data (read Rx / write Tx)
StatReg             rmb       1                   status (read only)
PRstReg             equ       StatReg             programmed reset (write only)
CmdReg              rmb       1                   command (read/write)
CtlReg              rmb       1                   control (read/write)

*============================================================================
                    ifeq      Level-1
orgDFIRQ            rmb       2
                    endc
*============================================================================
RxBufDSz            equ       256-.               default Rx buffer gets remainder of page...
RxBuff              rmb       RxBufDSz            default Rx buffer
OutPktBuf           rmb       256


MemSize             equ       .


                    mod       eom,name,tylg,atrv,start,size

                    org       V.SCF

size                equ       .
                    fcb       UPDAT.+SHARE.     these are the supported modes.
name                fcs       /WizFiHub/
                    fcb       edition

start               lbra      Init              |SCF jump table
                    lbra      Read              |
                    lbra      Write             |
                    lbra      GetStat            |
                    lbra      SetStat            |I$Open requires certain SetStats
                    lbra      Term


strConnect          fcc       "0,CONNECT"
strCipSend          fcc       "AT+CIPSEND="
                    fcb       0

***********************************************************************************
* F$IRQ packet.
*
IRQ_Pckt            equ       *
IRQ_Pckt.Flip       fcb       %00000000           the flip byte
IRQ_Pckt.Mask       fcb       WIZFI_INTERRUPT     the mask byte
                    fcb       $F1                 the priority byte


Read
Write
GetStat
SetStat
Term
 clrb
 rts


***********************************************************************************
* Init              
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Init                clrb
                    pshs cc,dp,y
 orcc #IntMasks
 lbsr ShowHex
* Set up INT_TIMER_0 (25.175Mhz-based timer)
* Fast
* 25,175,000 / 11520 Bytes Per Second  = 2185 ticks @ 25.175Mhz (8, 137)
* 25,175,000 / 23040 Bytes Per Second  = 1092 ticks @ 25.175Mhz (4,  68)
* 25,175,000 / 92160 Bytes Per Second  =  273 ticks @ 25.175Mhz (1,  17)
*
* rates and results
* 273 = startup purger idled out
* 380 = startup purger finished

                    ldd       #TRATE
                    sta       T0_VAL+0            registers are still Little Endian?
                    stb       T0_VAL+1
                    clr       T0_VAL+2

                    lda       #%00000001
                    sta       >T0_CTR
                    lda       #%00000010          Timer reloads Value, for continuous run
                    sta       >T0_CMP_CTR

                    ldd       #INT_PENDING_0      get the pending interrupt pending address
                    leax      IRQ_Pckt,pcr        point to the IRQ packet
                    leay      iService,pcr       and the service routine
                    os9       F$IRQ               install the interrupt handler
*                    bcc       g@                  branch if success
*                    os9       F$PErr
                    lda       >INT_MASK_0          else get the interrupt mask byte
                    anda      #^WIZFI_INTERRUPT   set the interrupt
                    sta       >INT_MASK_0          and save it back

                    pshs      u
                    ldd       #$0100
                    os9       F$SRqMem
                    tfr       u,x
                    puls      u
                    bcs       InitExit
                    stx       <D.WizFi            We want WizFi devices to be able to access this memory


                    clrb
c@                  clr       ,x+
                    decb
                    bne       c@

InitExit            puls      cc,dp,y,pc            recover IRQ/Carry status, system DP, return



RxCRead             pshs      y,b,cc
                    orcc      #IntMasks
                    ldd       MasterRxDget,u
                    addd      #$0001              To be optimized later into  incb, bcc, inca  incrementer
                    anda      #$07                2K circular buffer
                    std       MasterRxDget,u
                    adda      #$40                Buffer pointer between $4000-$5FFF
                    tfr       d,y
                    ldb       >WORK_SLOT
                    lda       MasterRxDBlock,u
                    sta       >WORK_SLOT
                    lda       ,y
                    stb       >WORK_SLOT
x@                  puls      cc,b,y,pc


RxCWrite            pshs      y,b,a,cc
                    orcc      #IntMasks
                    ldd       MasterRxDput,u
                    addd      #$0001
                    anda      #$07                2K circular buffer
                    std       MasterRxDput,u
                    adda      #$40                Buffer pointer between $4000-$5FFF
                    tfr       d,y
                    ldb       >WORK_SLOT
                    lda       MasterRxDBlock,u
                    sta       >WORK_SLOT
                    lda       1,s
                    sta       ,y
                    stb       >WORK_SLOT
x@                  puls      cc,a,b,y,pc


RxFRead             pshs      cc,b
                    orcc      #IntMasks
                    ldb       >WORK_SLOT
                    lda       #$C5		Bank where the WizFi registers are
                    sta       >WORK_SLOT
                    lda       [ind_DataReg,u]
                    stb       >WORK_SLOT
                    puls      b,cc
                    rts

GetDeviceChannel
                    ldb       V.PORT+1,u
                    tfr       b,a
                    anda      #MASK_SOCKETDEV
                    sta       DeviceMode,u
                    andb      #3
                    stb       DeviceChannel,u
                    rts

iRxFCheck           lda       [ind_RxD_WR_CountReg,u]
                    tfr       a,b
                    clra
                    cmpd      #$0000
                    rts

RxCCheck
                    ldb       PendingByte,u
                    rts




iService            pshs      cc,dp,x
*                    tfr       u,d                 setup our DP
*                    tfr       a,dp
*                    bsr       GetDeviceChannel
                    ldb       >WORK_SLOT
                    pshs      b
                    lda       #$C5		  Map in the WizFi registers
                    sta       >WORK_SLOT

                    lda       #WIZFI_INTERRUPT    clear pending interrupt
                    sta       INT_PENDING_0

 ldx <D.WizFi
 lda RxPending,x
 anda #$80
                    lbne      iExit
                    lbsr      iRxFCheck
                    lbeq      iSendPkt         Send pending TxD packets only if no RxD

                    lda       [ind_DataReg,u]
                    sta       LastRxD,u

                    ldb       DeviceMode,u        Device descriptor has the Packets bit set
                    lbeq      iBroadcastNew

                    ldb       IRQ_State,u
                    cmpb      #IRQ_State_ListenPkt
                    beq       iListenPkt

                    ldx       IpdLen,u
                    bne       x@
                    ldb       #IRQ_State_ListenPkt
                    stb       IRQ_State,u
                    clr       PktReadPos,u
                    lbra      iExit
x@                  leax      -1,x
                    stx       IpdLen,u

                    ldb       PacketChannel,u
                    cmpb      DeviceChannel,u
                    lbeq      iBroadCastNew
                    lbra      iExit

iListenPkt          leax      strIPD,pcr          point to start of IPD string constant
                    ldb       PktReadPos,u           what character position are we at?  +  P  D  ,   ?  0-3
                    cmpb      #4
                    bls       mc@                 go match exact chars "+IPD,"
                    cmpb      #5
                    beq       ms@                 go match a digit "0" - "3" for the socket #
                    cmpb      #6
                    bls       mc@                 go match exact char ","
                    cmpa      #58                 match ":" terminator for +IPD string
                    beq       t@                  terminating character
                    sta       IpdLenChar,u        match length digits
                    ldd       IpdLen,u
                    lbsr      DecBin
                    std       IpdLen,u
m@                  inc       PktReadPos,u
x@                  lbra      iExit             Exit with no data
strIPD              fcc       "+IPD,$,#####:"
t@                  clr       PktReadPos,u
                    clr       IRQ_State,u        Switch to data mode for the next cycle
                    bra       x@
mc@                 cmpa      b,x                 Match exact char from RxD FIFO
                    beq       m@
                    clr       PktReadPos,u           Match failed, quit parsing the IPD and start again
                    bra       x@
ms@                 clr       PacketChannel,u
                    cmpa      #'0
                    blo       m@
                    cmpa      #'3
                    bhi       m@
                    suba      #'0                 get connection # in ASCII "0" - "3"
                    sta       PacketChannel,u
                    clr       IpdLen,u
                    clr       IpdLen+1,u
                    bra       m@
iSendPkt
*                    inc       WritePacketTimer,u
*                    ldb       WritePacketTimer,u
*                    anda      #127
*                    andb      #7
*                    lbne      iExit
                    ldb       OutPktLaydown,u
                    subb      OutPktPickup,u
                    lbeq      iExit
                    bpl       n@
                    negb
n@                  clra
                    tfr       d,y
                    leax      strCipSend,pcr
s@                  lda       ,x+
                    beq       c@
                    lbsr      SendByte
                    bra       s@
c@                  lda       DeviceChannel,u
                    adda      #'0
                    lbsr      SendByte
                    lda       #',
                    lbsr      SendByte

                    leax      strDecimal5,u
                    tfr       y,d
                    lbsr      Word2Dec3           We also have Word2Dec5 routine for 5-digit packet size for outgoing
                    ldb       #3
d@                  lda       ,x+
                    lbsr      SendByte
                    decb
                    bne       d@
                    lda       #$0d
                    lbsr      SendByte
                    lda       #$0a
                    lbsr      SendByte
wsp@                lbsr      iRxFCheck
                    beq       wsp@
                    lda       [ind_DataReg,u]
                    cmpa      #32
                    bne       wsp@
r@                  inc       OutPktPickup,u
                    ldb       OutPktPickup,u
                    leax      OutPktBuf,u
                    abx
                    lda       ,x
	            lbsr      SendByte
                    leay      -1,y
                    bne       r@
                    ldy       #4                  Wait for 4 CRLF terminated AT responses
pl@                 lbsr      iRxFCheck           There is no dead loop prevention at this time
                    beq       pl@
                    lda       [ind_DataReg,u]
                    cmpa      #10
                    bne       pl@
                    leay      -1,y
                    bne       pl@
                    bra       iExit
*                    bra       iWake
SendByte            pshs      cc,a,b
                    orcc      #IntMasks           disable IRQs during error and Tx disable checks
                    ldb       >WORK_SLOT
                    lda       #$c5
                    sta       >WORK_SLOT
                    lda       1,s
                    sta       [ind_DataReg,u]
                    stb       >WORK_SLOT
                    puls      cc,a,b,pc

iBroadcastNew
 ldx <D.WizFi
 lda RxPending,x
 ora #$80
 sta RxPending,x
                    lda       LastRxD,u
                    sta       RxData,x
                    ldd       IpdLen,u
                    std       RxSize,x

* Always update virtual ports
iExit
                    ldx       <D.WizFi
                    ldb       RxPending,x
                    andb      #%11111000
                    orb       PacketChannel,u
                    stb       RxPending,x

                    puls      b
                    stb       >WORK_SLOT

                    puls      cc,dp,x,pc               recover system DP, return...



* Convert byte in B to Decimal string at X (3 places)
Word2Dec3
                    pshs      u,y,x,b
                    clra
                    leau      <DeciTbl+4,pcr      point to deci-table
                    ldy       #$0003              number of decimal places
                    bra       w1
* Convert word in D to Decimal string at X (5 places)
Word2Dec5
                    pshs      u,y,x,b
                    leau      <DeciTbl,pcr        point to deci-table
                    ldy       #$0005              number of decimal places
w1                  clr       ,s                  clear byte on stack
w2                  subd      ,u                  subtract current place from D
                    bcs       w3                  branch if negative
                    inc       ,s                  else increment place
                    bra       w2                  and continue
w3                  addd      ,u++                re-normalize D
                    pshs      b                   save B
                    ldb       $01,s               get saved B
                    addb      #'0                 add ASCII 0
                    stb       ,x+                 and save
                    puls      b                   retrieve saved B
                    leay      -$01,y              subtract Y
                    bne       w1                  branch if not done
                    puls      pc,u,y,x,b

DeciTbl             fdb       10000,1000,100,10,1


* For debugging, shows the Rx Packet size in the upper corner of the text screen

DecBin              pshs      y,b,a               save registers
                    ldb       IpdLenChar,u                 get digit
                    subb      #$30                make it binary
                    cmpb      #$0A                bla bla bla!
                    bcc       L095D
                    lda       #$00
                    ldy       #$000A
L094F               addd      ,s
                    bcs       L095B
                    leay      -$01,y
                    bne       L094F
                    std       ,s
                    andcc     #^Zero
L095B               puls      pc,y,b,a
L095D               orcc      #Zero
                    puls      pc,y,b,a



* Phased out, or on pause


* * debug
*         pshs d,x
*         clrb
*         tfr	d,x
*         lbsr	ShowHex
*         puls d,x,pc


ShowHex             pshs      cc,d
                    orcc      #IntMasks
                    ldb       >WORK_SLOT
                    pshs      b
                    ldb       #$C2                Text screen block #
                    stb       >WORK_SLOT 
                    tfr       x,d
                    lsra                          Do cheap binary to 4-digit HEX ASCII string
                    lsra
                    lsra
                    lsra
                    bsr       Bin2AscHex
                    sta       >MMU_WINDOW+(80*20)+76
                    tfr       x,d
                    anda      #$0f
                    bsr       Bin2AscHex
                    sta       >MMU_WINDOW+(80*20)+77
                    tfr       x,d
                    tfr       b,a
                    lsra                          Do cheap binary to 4-digit HEX ASCII string
                    lsra
                    lsra
                    lsra
                    bsr       Bin2AscHex
                    sta       >MMU_WINDOW+(80*20)+78
                    tfr       x,d
                    tfr       b,a
                    anda      #$0f
                    bsr       Bin2AscHex
                    sta       >MMU_WINDOW+(80*20)+79
                    puls      b
                    stb       >WORK_SLOT
                    puls      cc,d,pc

Bin2AscHex          anda      #$0f
                    cmpa      #9
                    bls       d@
                    suba      #10
                    adda      #'A'
                    bra       x@
d@                  adda      #'0'
x@                  rts


* RxCCheck
*                    pshs      cc
*                    orcc      #IntMasks
* Method 1
*                    ldd       MasterRxDput,u
*                    cmpd      MasterRxDget,u
*                    bhs       p@
*                    ldd       MasterRxDget,u
*                    subd      MasterRxDput,u
*                    bra       r@
* p@                 subd      MasterRxDget,u
* r@
*                    puls      cc
* Method 2
*                    cmpd      #$0000
*                    rts



* * Transfer RxD from FIFO into Connection Buffer

* ISRPurger           lbsr      iRxFCheck
*                     beq       ISRWatcher
*                     tfr       d,y                 <------  Copying all FIFO to 8k Buffer "doesn't work out"  -------->
*                     ldy       #1                  <------  Copying only 1 byte, RxD works but is super slow  ------->

* p@                  lbsr      RxFRead             Hardware FIFO buffer
*                     lbsr      RxCWrite            Circular buffer, keeps track of size
*                     leay      -1,y
*                     bne       p@
*                     bra       iWake

* ISRWatcher          lbsr      RxCCheck
*                     beq       ISRExit

* ListenForConnect  for /n# devices only
* 	leax	strConnect,pcr
* 	ldb	PktReadPos,u
* 	cmpa	b,x
* 	beq	m@
* 	clr	PktReadPos,u
* 	bra	x@
* m@	incb
* 	stb	PktReadPos,u
*         cmpb    #9		total match
*         blo     x@
* 	clr	PktReadPos,u
* 	ldb	#State_ListenPacket
* 	stb	IRQ_State,u
* x@	bra	ReadExit



                    emod
eom                 equ       *
                    end