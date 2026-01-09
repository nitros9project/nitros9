********************************************************************
* sc16550 - 16550 Driver
*
* Comments from Deek's driver at https://github.com/Deek/MMSerial
* were added on January 4, 2025.
*
* Symbols that affect assembly:
* - wildbits: Wildbits 6809
* - coco: CoCo (all models)
* - coco3: CoCo 3
* - fast232: Rick Ulland's Fast232 packet
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  13      2026/01/03  Boisy G. Pitre
* Fixed a number of issues in the driver and verified it works on the Wildbits.

 nam sc16550
 ttl 16550 device driver

 use defsfile
 use 16550.d

* GetStat calls unique to sc16550 (move to main defs later)
SS.WrtBf equ $C1 return stats on the transmit buffer
SS.DvrID equ $D2 driver ID (returns info on current driver)

* SetStat calls unique to sc16550 (move to main defs later)
SS.TxF1R equ $C2 clear transmitter software flow control
SS.TxFlh equ $C3 flushes (discards) transmit buffer contents

tylg set Drivr+Objct   
atrv set ReEnt+rev
rev set $01

* V.ERR bit definitions
DCDLstEr equ %00100000 DCD lost error
BrkEr equ %00001000 break error
OvrFloEr equ %00000100 Rx data overrun or Rx buffer overflow error
FrmingEr equ %00000010 Rx data framing error
ParityEr equ %00000001 Rx data parity error

* OS-9 IT.PAR flow control bit settings
Parity equ %11100000 parity bits
FCTXSW equ %00001000 Rx data software (XON/XOFF) flow control
FCRXSW equ %00000100 Tx data software (XON/XOFF) flow control
FCCTSRTS equ %00000010 CTS/RTS hardware flow control
FCDSRDTR equ %00000001 DSR/DTR hardware flow control
* these names are from xACIA
MdmKill equ %00010000 modem kill option
ForceDTR equ	%10000000 don't drop DTR in Term

* Our own TxFloCtl bit settings
* Free bits: %10000000
TXF.Mask equ %01110000
TXF.XOFF equ %01000000 xon/xoff software control
TXF.RTS equ %00100000 cts/rts hardware control
TXF.DTR equ %00010000 dsr/dtr hybrid control
* Below are reasons we're _not_ sending
TXF.NBRK equ %00001000 sending break signal
* For various reasons, these must be identical to the bits in ITPARCopy
TXF.NXON equ %00000100 currently waiting for XON
TXF.NCTS equ %00000010 waiting for CTS to go back up
TXF.NDSR equ %00000001 waiting for DSR to go back up

 mod eom,name,tylg,atrv,start,size

* Static memory storage.
* NOTE: We reassign to DP for faster access in all driver branch routines
* Based on Bruce Isted's XACIA, although with some changes
 org V.SCF allow for SCF manager data read
ITPARCopy rmb 1 copy of parity settings from descriptor (IT.PAR) \ must be
ITBAUCopy rmb 1 copy of baud rate from descriptor (IT.BAU)       / together
altBauFl rmb 1 alternate baud rate table flag (0=normal); use for older comm programs with new baud rates
msrCopy rmb 1 copy of MSR register
fcrCopy rmb 1 copy of FCR register
fcRXSWFlag rmb 1
pathDescCPR rmb 1 process to receive signal (from path descriptor)
pathDescSignal rmb 1 signal to send (from path descriptor)
ssSigCPR rmb 1 process to receive signal (set by SS.SSig)
ssSigSignal rmb 1 signal to send (set by SS.SSig)
sigCode rmb 1  signal code (for send)
TxFloCtl rmb 1 modem status flags
fifoSize rmb 1 16550 FIFO size
u002A rmb 2
rxNextAddressForIncomingByte rmb 2 pointer to the next place in the rx buffer to place incoming data
rxNextAddressForOutgoingByte rmb 2 pointer to next place in the rx buffer to get data from
rxBufEnd rmb 2 pointer to the end of the rx buffer
rxBufStrt rmb 2 rx buffer start pointer
rxBufCnt rmb 2 rx buffer - current number of bytes in it
rxBuffSize rmb 2 V.BUFSIZ (# of extra bytes we reserved in static memory >256 SCF gave us)
outNxt rmb 2 pointer to the next place in the tx buffer to place outgoing data
txBufPos rmb 2 pointer to next place in the tx buffer to get data from
txBufEnd rmb 2 pointer to the end of the tx buffer
txBufStrt rmb 2 tx buffer start pointer
txBufCnt rmb 1 tx buffer - current number of bytes in it
txBuffAllocedSize rmb 2 allocated size of transmit buffer
txNow rmb 1 if set non-negative, this will be sent before buffer
txBuff rmb 256-. transmit buffer
size equ .

 fcb READ.+WRITE.

name fcs /sc16550/

edition fcb 13

 ifne coco+coco3
MPISlot fcb MPI.Slot default MPI slot #3 (change to use descriptor later)
 endc

start
 lbra Init
 lbra Read
 lbra Write
 lbra GetStat
 lbra SetStat
 lbra Term

* Init
*
* Entry: Y = address of device descriptor
*        U = address of device static memory area
*
* Exit:  CC = carry set on error
*        B  = error code
*
* This routine allocates extra buffer memory IF requested in lower 4 bits of
* the XTP byte in the device descriptor AND there is enough free system memory
* to do so. 
Init clrb default to no error
 pshs dp,b,cc
 lbsr SetDPShortcut point DP to first 256 bytes of device memory area
 lda <M$Opt,y get number of option bytes in descriptor
 cmpa #IT.XTYP-IT.DTP is there an extended type byte in descriptor?
 bls alloc@ no, skip ahead (and default to one 256 byte buffer page)
 lda <IT.XTYP,y else get the extended type byte
 anda #%00010000 alternate baud rate table flag only
 sta <altBauFl save alternate baud table on/off flag
 lda <IT.XTYP,y get extended type byte back
 anda #%00001111 keep number of 256 byte buffer pages to use for receive buffer
 bne clrlow@ if >0 then allocate that many
alloc@ lda #$01 otherwise default to $100 (256) byte buffer page
clrlow@ clrb
 pshs u save U
 os9 F$SRqMem request # of page buffer pages (256 bytes/page from SYSTEM RAM)
 tfr u,x move pointer to newly allocated system RAM to X
 puls u restore device memory pointer
 bcc cont2@ we now have the memory; continue
* Code here is in case of alloc error -- cleanup and return with error
 stb 1,s couldn't get the memory, so save error code into B on stack
 puls dp,b,cc restore registers and error number
 orcc #Carry return with error
 rts
* D = size of allocated buffer in bytes
cont2@ stx <rxBufStrt save pointer to start of receive buffer
 stx <rxNextAddressForIncomingByte save pointer to next incoming byte location
 stx <rxNextAddressForOutgoingByte save poniter to next outgoing byte location
 std <rxBuffSize save size of receive buffer
 leax d,x point to end of receive buffer
 stx <rxBufEnd save end of receive buffer pointer
 tfr a,b move number of 256 byte receive pages to B 
 clra
 orb #%00000010 force to multiples of 512 bytes
 andb #%00001110 number of 512 byte pages
 lslb this will always shift out to 0, won't it, since max #pages=15?
 lslb
 lslb
 lslb
 tstb
 bpl cont3@
 ldb #$80
cont3@ pshs d
 ldd <rxBuffSize get size of receive buffer
 subd ,s++ subtract ?
 std <u002A save it
 leax <txBuff,u point to transmit buffer
 stx <txBufStrt save to transmit buffer start pointer
 stx <outNxt save to active transmit buffer start pointer
 stx <txBufPos save to active transmit buffer end pointer
 leax >256,u advance to end of transmit buffer
 stx <txBufEnd save to transmit buffer end pointer
 ldd #size-txBuff size of transmit buffer
 std <txBuffAllocedSize save it
 clr <rxBufCnt (RxBufSiz) Clear Receive buffer size (16 bit) 
 clr <rxBufCnt+1 (RxBufSiz+1)
 clr <txBufCnt clear transmit buffer size
 ldd <IT.PAR,y get parity & baud rate settings from device descriptor
 std <ITPARCopy save copies in device memory
 lbsr SetBaud set some stuff up based on the data table at end of driver
 ldx <V.PORT get pointer to 16550 hardware
* Read our ports to clear any crap out
 lda UART_LSR,x get line status register
 lda UART_TRHB,x get data register
 lda UART_LSR,x get line status register again
 lda UART_MSR,x get modem status register
 anda #MSR_CD+MSR_DSR+MSR_CTS only keep receive data carrier detect, data set ready, and clear to send bits
 sta <msrCopy save them
 clrb clear our "results" register - all 3 of the above off
 bita #MSR_CTS is CTS bit set?
 bne cont4@ yes, skip ahead
 orb #FCCTSRTS else add that bit flag
cont4@ bita #MSR_DSR is DSR bit set?
 bne cont5@ yes, skip ahead
 orb #FCDSRDTR else add that bit flag
cont5@ stb <TxFloCtl save flags
 ldd <V.PORT get pointer to 16550 hardware base address
 addd #UART_FCR point to 16550 status register
 leax >IRQPckt,pcr point to 5 byte IRQ packet settings
 leay >IRQSvc,pcr point to IRQ service routine
 os9 F$IRQ install ourselves in IRQ polling table
* System-dependent interrupt behavior goes here
 ifne wildbits
* Wildbits: Turn on interrupt controller's interrupt for the UART         
 lda INT_MASK_1
 anda #~INT_UART
 sta INT_MASK_1
 else
* CoCo: set MPI select
 orcc #IntMasks
 lda >MPISlot,pcr
 bmi cont6@
 sta >MPI.Slct
cont6@ lda >PIA1Base+3 fetch PIA1 CR B
 anda #%11111100 disable *CART FIRQ
 sta >PIA1Base+3 save it back
 lda >PIA1Base+2 read any data out of PIA1
 ifne coco3
* CoCo 3: turn on interrupts in GIME 
 lda >D.IRQER  read the GIME IRQ enable register copy
 ora #$01 enable GIME *CART IRQ
 sta >D.IRQER save it to the system...
 sta >IrqEnR ...and the GIME itself.
 endc
 endc
* Enable all 16550 IRQ sources *except* transmitter empty
 lda #UINT_MODEM_STATUS+UINT_LINE_STATUS+UINT_DATA_AVAIL enable modem status, receiver line status, and receive data available interrupts on 16550
 bsr SetIRQSources
 puls pc,dp,b,cc restore registers, reenable IRQs, and return

* Write
*
* Entry:
*    A  = character to write
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
Write clrb
 pshs dp,b,cc
 lbsr SetDPShortcut point DP to first 256 bytes of device memory area
 ldx <outNxt get pointer to next empty spot in our transmit buffer
 sta ,x+ append the character
 cmpx <txBufEnd have we hit physical end of transmit buffer?
 blo cont1@ no, skip ahead
 ldx <txBufStrt yes, point to physical start of transmit buffer
cont1@ orcc #IntMasks IRQs off
 cmpx <txBufPos have we caught up with beginning in wraparound buffer?
 bne cont3@ no, skip ahead
 pshs x else save pointer
 lbsr SuspendProc suspend current process
 ldx >D.Proc get pointer to current process descriptor
 ldb <P$Signal,x  get any current signal code
 puls x recover pointer
* 6809/6309 - change to beq cont1@
 beq cont2@ no signal, go back
 cmpb #S$Intrpt is it a Keyboard Interrupt, Abort, or Wake signal?
 bls cont4@ yes, restore registers and return
cont2@ bra cont1@ else loop back
cont3@ stx <outNxt save updated pointer to next free spot in transmit buffer
 inc <txBufCnt increase number of bytes in driver's transmit buffer
 bsr EnableIRQSources enable all IRQ's on 16550 *including* transmitter empty IRQ
cont4@ puls pc,dp,b,cc 
* Enable all 4 16550 IRQ sources
EnableIRQSources lda #UINT_MODEM_STATUS+UINT_LINE_STATUS+UINT_THR_EMPTY+UINT_DATA_AVAIL enable modem status, receiver line status, transmitter empty & receive data available interrupts on 16550
SetIRQSources ldx <V.PORT get pointer to 16550
 sta UART_IER,x set interrupt enable register
 rts

* Read
*
* Entry:
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    A  = character read
*    CC = carry set on error
*    B  = error code
*
Read clrb clear carry
 pshs dp,b,cc save registers (B's position on the stack will be used as A (character return))
 lbsr SetDPShortcut point DP to first 256 bytes of device memory area
 orcc #IntMasks turn IRQs off
 ldd <rxBufCnt get number of bytes in receive buffer
 beq suspend@ none, so go suspend process
 cmpd #16 is buffer count 16?
 lbne getchar@ no, go receive
 andcc #^IntMasks turn IRQs on
 bsr setirqs@
chkfreebuff@ orcc #IntMasks turn IRQs off
 ldd <rxBufCnt get receive buffer free count
 bne getchar@ branch if not zero
suspend@ lbsr SuspendProc suspend current process
 ldx >D.Proc get the current process descriptor
 ldb <P$Signal,x get possible pending signal
 beq chkcondem@ branch if none
 cmpb #S$Intrpt interrupt signal?
 bls errexit@ branch if same or lower
chkcondem@ ldb P$State,x
 andb #Condem process condemned?
 bne errexit@ branch if so
 ldb <V.ERR get error accumulator
 bne saveerr@ was an error, skip ahead
 ldb <V.WAKE get process number to wake up when I/O done
 beq chkfreebuff@ none, go back
 orcc #IntMasks turn IRQs off
 bra suspend@ suspend the process
errexit@ puls dp,a,cc exit with error
 orcc #Carry
 rts
getchar@ subd #$0001 subtract receive buffer free count
 std <rxBufCnt and save it back
 ldx <rxNextAddressForOutgoingByte get address of next byte in RX buffer to read
 lda ,x+ get that byte and increment X
 cmpx <rxBufEnd are we at the end of the RX buffer?
 bne geterr@ branch if not
 ldx <rxBufStrt else wrap around to start of RX buffer
geterr@ stx <rxNextAddressForOutgoingByte save updated pointer
 andcc #^IntMasks turn IRQs on
 ldb <V.ERR get error accumulator
 beq exit2@ no errors, restore registers and return
saveerr@ stb <PD.ERR,y save error accumulator to path descriptor
 clr <V.ERR clear out error accumulator
 puls dp,a,cc restore registers
 bitb #DCDLstEr check if carrier lost
 beq hangup@ yes, exit with CD lost/modem hangup error
 ldb #E$Read else exit with read error
 orcc #Carry
 rts
hangup@ ldb #E$HangUp exit with CD lost error
 orcc #Carry
 rts
exit2@ puls pc,dp,b,cc
setirqs@ pshs cc save CC (use to restore interrupts)
 ldx <V.PORT get pointer to 16550 hardware
 ldb <TxFloCtl get flag bits based on modem status
 bitb #TXF.Mask XOFF|RTS|DTR
 beq exit@ if none of the 3 bits are set, turn IRQs back on and return
 bitb #TXF.RTS RTS?
 beq cont1@ no, skip ahead
 orcc #IntMasks else turn IRQs off
* 6309 - aim #$DF,<TxFloCtl
 ldb <TxFloCtl get flag bytes back (LCB NOTE: WE STILL HAVE THEM IN B, WHY ARE WE RELOADING?)
 andb #^TXF.RTS ^RTS
 stb <TxFloCtl save flags back
* 6309 - oim #RTS,UART_MCR,x
 lda UART_MCR,x get modem control register
 ora #MCR_RTS set RTS (request to send) bit
 sta UART_MCR,x save modified modem control register back
exit@ puls pc,cc turn IRQs back on and return
cont1@ bitb #TXF.DTR DTR bit set?
 beq cont2@ no, skip ahead
 orcc #IntMasks shut off IRQs
* 6309 - aim #$EF,<TxFloCtl
 ldb <TxFloCtl get flags
 andb #^TXF.DTR ^DTR
 stb <TxFloCtl and write it back
* 6309 - oim #
 lda UART_MCR,x get modem control register
 ora #MCR_DTR set DTR (data terminal ready) bit
 sta UART_MCR,x and write back to 16550
* 6809/6309 - replace with puls pc,cc (same size, 3 cyc faster)
 bra exit@ turn IRQs back on and return
cont2@ bitb #TXF.XOFF XOFF bit set?
 beq exit@ no, turn IRQs back on and return
 ldb <V.XON else get XON char
 orcc #IntMasks turn IRQs off
 stb <txNow save XON char
 lbsr EnableIRQSources enable ALL 4 IRQs on 16550 (including transmit)
* 6309 aim #$BF,<TxFloCtl
 ldb <TxFloCtl get flags byte again
 andb #^TXF.XOFF ^XOFF
 stb <TxFloCtl and write it back
* 6809/6309 - replace with puls pc,cc (same size, 3 cyc faster)
 bra exit@ turn IRQs back on and return

* GetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*    X  = pointer to callers register stack
*
* Exit:
*    CC = carry set on error
*    B  = error code
*    Other registers depend on function code
*
* Extra Info:
*      ANY codes not defined by IOMan or SCF are passed to the device driver.
*
*      The address of the registers at the time F$GetStt was called is in
*      PD.RGS, in the path descriptor (PD.RGS,Y)
*
*      From there, R$(CC|D|A|B|DP|X|Y|U|PC) get you the appropriate register value.
GetStat clrb  
 pshs dp,b,cc
 lbsr SetDPShortcut point DP to first 256 bytes of device memory area
 cmpa #SS.Ready data ready call?
 bne chkcomstt@ no, check next
 ldd <rxBufCnt else any data ready in driver's receive buffer?
 beq notready@ no, return with device not ready error
 tsta >255 bytes ready?
 beq ready@ no, use amount we have
 ldb #255 else return 255 bytes ready to caller (only 8 bits allowed)
ready@ ldx PD.RGS,y get caller's stack pointer
 stb R$B,x save number bytes available to read in caller's B register
* 6809/6309 - replace with puls  pc,dp,b,cc (1 byte smaller, 4 or 5 cycles faster)
 lbra restoreandreturn@ restore registers and return
notready@ puls b,cc return to caller with device not ready error (no data in receive buffer) 
 orcc #Carry
 ldb #E$NotRdy
 puls pc,dp
chkcomstt@ cmpa #SS.ComSt return serial port configuaration?
 bne chkeof@ no, check next
 ldd <ITPARCopy get parity and baud settings from device memory
 tst <altBauFl is alternate baud table in use?
 beq  chcomstt1@ no, leave as is
 bitb #$04 else if IT.BAU copy >=2400 baud, values stay the same 
 bne  chcomstt1@
 andb #%11110111 force to fit original 3 bit spec (this covers 38400,57600,76800,115200)
chcomstt1@ ldx PD.RGS,y get callers register stack pointer from path descriptor
 std R$Y,x save parity and baud bytes back to caller in Y
 clrb clear return value
 lda <msrCopy get current DCD, DSR & CTS bit flags from copy of modem status register
 bita #MSR_CD is carrier detect enabled?
 bne chkcomstt2@ no, skip ahead
 orb #$10 else set DCD status in bit 5 (for compatibility with older drivers) in B
chkcomstt2@ bita #MSR_DSR is data set ready enabled?
 bne chkcomstt3@ yes, done with B
 orb #$40 else set DSR status in bit 6 (for compatibility with older drivers) in B
chkcomstt3@ stb R$B,x save special CD/DSR status byte in caller's B
* 6809/6309 - replace with puls  pc,dp,b,cc (1 byte smaller, 4 or 5 cycles faster)
 bra restoreandreturn@ restore registers and return
chkeof@ cmpa  #SS.EOF end of file check?
 bne chkdvrid@ no, check next
 clrb else exit without error
* 6809/6309 - replace with puls  pc,dp,b,cc (1 byte smaller, 4 or 5 cycles faster)
 bra  restoreandreturn@ restore registers and return
********************
* GSDvrID
********************
* Interrogates the driver for its capabilities.
*
* Entry:
*.     A = $D2
* Exit:
*      A = Maximum baud rate code supported
*		This is not the number of baud rates, but the highest
*		permitted OS-9 baud rate code (currently $0B)
*	B = Type of UART supported
*		$01	6551/6551A
*		$02	6552
*		$04	16550 and derivatives
*	X = Bit field of driver capabilities:
*		$0001	Supports SS.HngUp (modem hangup via DTR)
*		$0002	Supports SS.Break (send break signal)
*		$0004	Supports SS.CDSig (signal on DCD drop)
*		$0100	Supports SS.RdBlk (block read) command
*		$0200	Supports SS.WrBlk (block write) command
*		$0400	Supports SS.TxClr (clear transmit buffer) command
*	Y = Driver's identification number (this driver returns 1)
*
chkdvrid@ cmpa #SS.DvrID return driver ID info?
 bne chkscsiz@ no, check next
 ldd #$0B04 driver max baud rate is $B (115200 currently), driver/chip type=4 (16550)
 ldy PD.RGS,y get callers register stack pointer from path descriptor
 std R$D,y save max baud & driver/chip types back to caller's D
* The "large" versions should return bits 8,9,10 set as well (SS.BlkRd, SS.BlkWr, SS.TxFlh supported)
 ldd #$0007 return that driver supports: SS.Hangup, SS.Break, and signal on CD change
 std R$X,y return which options beyond original ACIAPAK are supported in callers X
 ldd #$0001 driver ID#=1 for sc16550
 std R$Y,y save in callers Y
* 6809/6309 - replace with puls  pc,dp,b,cc (1 byte smaller, 4 or 5 cycles faster)
 bra restoreandreturn@ restore registers and return
chkscsiz@ cmpa #SS.ScSiz screen size?
 bne unksvc@ no, return with unknown service request error
 ldx PD.RGS,y get caller's register stack pointer from path descriptor
 ldy PD.DEV,y get pointer to our device's table entry address
 ldy V$DESC,y get pointer to device descriptor itself
 clra clear high byte of X,Y sizes
 ldb <IT.COL,y get # of columns (X size) from descriptor
 std R$X,x save in caller's X
 ldb <IT.ROW,y get number of rows (Y size) from descriptor
 std R$Y,x save in caller's Y
* 6809/6309 - replace with puls  pc,dp,b,cc (1 byte smaller, 4 or 5 cycles faster)
 bra restoreandreturn@ restore registers and return
unksvc@ puls b,cc
 orcc #Carry
 ldb #E$UnkSvc exit with unknown service request error
 puls pc,dp
* 6809/6309 - Once we change lbra/bra to restoreandreturn@'s to actual puls, this line can be removed
restoreandreturn@ puls pc,dp,b,cc

* Entry: B=IT.BAU value from descriptor
SetBaud pshs u save U
 tfr b,a dupe baud rate into A
 leau >BaudTable,pcr point to data table (I think last byte is FIFO size?)
 ldx <V.PORT get hardware address of 16550
 andb #$0F 16 entries only in table (max # of baud rates?)
 lslb 4 bytes/entry
 lslb  
 leau b,u U=pointer to entry we want (based on baud rate bits)
 lsra shift stop bits & word length to lowest 3 bits
 lsra  
 lsra  
 lsra  
 lsra  
 eora #LCR_DATABITS_MASK invert word length bits
 anda #LCR_DATABITS_MASK oly keep word length (now set up for least 2 sig bits on UART_LCR on 16550)
 pshs a,cc save that and CC
 lda <ITPARCopy get work copy of parity settings
 lsra shift out CTS/RTS & DSR/DTR bits
 lsra  
 anda #LCR_PARITY_MASK only keep the 3 parity bits (in right position for UART_LCR on 16550)
 ora 1,s merge in the word length bits (lowest 2)
 sta 1,s save new copy on stack
 ora #LCR_DLB turn on LCR_DLB (Divisor Latch Access bit)
 orcc #IntMasks turn IRQs off
 sta  UART_LCR,x set word length & parity, and switch LCR_DLB to 1 (so we can program baud rate)
 ldd ,u++ get divisor latch value
* Could just change table to have these pre-swapped
 exg a,b 16550 needs little endian, so swap bytes
 std ,x save LDiv/HDiv (16 bit divisor latch) into 16550
 lda 1,s get word length/parity byte back
 sta UART_LCR,x save onto line control, but with divisor latch OFF
 ldd ,u get UART_FCR register settings & # bytes / receive IRQ from table
 sta <fcrCopy save 1st byte in device static memory
 ora #FCR_RXR+FCR_TXR reset receive & transmit FIFO's (clears them)
 sta UART_FCR,x send to FIFO control register
 stb <fifoSize save FIFO size (1,4,8,14) as init counter for receive interrupts
 puls pc,u,a,cc

* SetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*    Other registers depend on function code
*
* Extra Info:
*      ANY codes not defined by IOMan or SCF are passed to the device driver.
*
*      The address of the registers at the time F$GetStt was called is in
*      PD.RGS, in the path descriptor (PD.RGS,Y)
*
*      From there, R$(CC|D|A|B|DP|X|Y|U|PC) get you the appropriate register value.
SetStat clrb  
 pshs dp,b,cc
 lbsr SetDPShortcut point DP to first 256 bytes of device memory area
 cmpa #SS.ComSt is it com stat?
 bne chkhngup@ branch if not
* SS.ComStt
 ldy PD.RGS,y get caller's registers pointer
 ldd R$Y,y get Y (high byte: parity, low byte: baud rate)
 tst <altBauFl get alternate baud rate table flag
 beq cont1@ branch if clear (use regular baud rate table)
 bitb #$04 check if >=2400 baud
 bne cont1@ branch if clear
 orb #$08
cont1@ std <ITPARCopy save parity & baud rate settings
 lbsr SetBaud go set the baud rate
 clr <fcRXSWFlag assume tx sw flow mode
 tst <V.QUIT is there a keyboard abort/quit character defined?
 bne cont2@ yes, skip ahead
 tst <V.INTR is there a keyboard interrupt character defined?
 bne cont2@ yes, skip ahead
 tst <V.PCHR is there a pause character set?
 bne cont2@ yes, skip ahead
 ldb <ITPARCopy get parity byte
 bitb #FCRXSW is tx sw flow set?
 bne cont2@ branch if so
 inc <fcRXSWFlag set tx sw flow flag
cont2@ lbra RestoreAndExit
chkhngup@ cmpa #SS.HngUp hangup?
 bne chkbreak@ branch if not
* SS.HngUp 
 ldx <V.PORT get pointer to 16550
 lda UART_MCR,x get modem control register value
 pshs x,a save it and port address
 anda #^MCR_DTR invert DTR bit
 sta UART_MCR,x store it in register
 ldx #30 sleep 1/2 a second
 os9 F$Sleep
 puls x,a restore registers
 sta UART_MCR,x store original value in register
 lbra RestoreAndExit
chkbreak@ cmpa #SS.Break break?
 bne chkssig@ branch if not
* SS.Break 
 orcc #IntMasks
 ldx <V.PORT get pointer to 16550
 lda <TxFloCtl
 ora #TXF.NBRK stop transmit, sending break
 sta <TxFloCtl
 lda #UINT_MODEM_STATUS+UINT_LINE_STATUS+UINT_DATA_AVAIL
 sta UART_IER,x
 clr <txBufCnt
 ldd <txBufStrt
 std <txBufPos
 std <outNxt
 lda <fcrCopy
 ora #$04
 sta UART_FCR,x
 clra
 sta UART_TRHB,x
loop@ lda UART_LSR,x
 anda #LSR_XMIT_DONE
 bne cont3@
 andcc #^IntMasks
 ldx #$0001
 os9 F$Sleep      Sleep for remainder of clock tick
 ldx <V.PORT      Get pointer to 16550
 bra loop@
cont3@ lda UART_LCR,x
 ora #LSR_XMIT_DONE
 sta UART_LCR,x
 ldx #30          Sleep for 1/2 a second
 os9 F$Sleep
 ldx <V.PORT      Get pointer to 16550
 anda #^LSR_XMIT_DONE
 sta UART_LCR,x
 lda <TxFloCtl
 anda #^TXF.NBRK no longer sending break, we can transmit again
 sta <TxFloCtl
 lbra RestoreAndExit
chkssig@ cmpa #SS.SSig
 bne chkrelea@
* SS.SSig
 lda PD.CPR,y
 ldy PD.RGS,y
 ldb R$X+1,y
 orcc #IntMasks
 ldx <rxBufCnt
 bne sendsig@
 std <ssSigCPR save SS.SSig current process and signal code to send
 lbra RestoreAndExit
sendsig@ puls cc
 os9 F$Send send signal
 puls pc,dp,b
chkrelea@ cmpa #SS.Relea release?
 bne chkcdsig@
* SS.Relea
 lda PD.CPR,y
 cmpa <ssSigCPR
 bne ssrelea@
 clra clear SS.SSig process
 clrb clear SS.SSig signal
 std <ssSigCPR save to our variables
ssrelea@ lbra RestoreAndExit
chkcdsig@ cmpa #SS.CDSig CD signal?
 bne chkcdrel@ branch if not
* SS.CDSig 
 lda PD.CPR,y else get current process from path descriptor
 ldy PD.RGS,y get caller register stack pointer
 ldb R$X+1,y get signal to send from caller's stack
 std <pathDescCPR save CPR and signa from path descriptor
 bra RestoreAndExit
chkcdrel@ cmpa  #SS.CDRel CD release?
 bne chkclose@ branch if not
* SS.CDRel
 orcc #IntMasks mask interupts
 lda PD.CPR,y get current process from path descriptor
 cmpa <pathDescCPR same as saved?
 bne sscdrel@ branch if not
 clra else clear current process
 clrb and signal to send
 std <pathDescCPR update saved values
sscdrel@ bra RestoreAndExit
chkclose@ cmpa #SS.Close close?
 lbne chkopen@ branch if not
* SS.Close
 orcc #IntMasks mask interrupts
 lda PD.CPR,y get current process from path descriptor
 ldx #$0000
 cmpa <ssSigCPR same as process from SS.SSig?
 bne ssclose@ no
 stx <ssSigCPR clear SS.SSig process and signal
ssclose@ cmpa <pathDescCPR same as process from path descriptor
 bne ssclose1@ no 
 stx <pathDescCPR clear path descriptor process and signal
ssclose1@ bra RestoreAndExit
chkopen@ cmpa #SS.Open open?
 bne unksvc@ branch if not
* SS.Open
 ldx <V.PORT get pointer to 16550
 lda #MCR_RTS+MCR_DTR assert DTR & RTS
 sta UART_MCR,x
 ldb #UINT_MODEM_STATUS+UINT_LINE_STATUS+UINT_THR_EMPTY+UINT_DATA_AVAIL enable all interrupts
 stb UART_IER,x
 bra RestoreAndExit
unksvc@ puls b,cc
 orcc #Carry
 ldb #E$UnkSvc exit with unknown service error
 puls pc,dp
RestoreAndExit puls pc,dp,b,cc

* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
Term clrb
 pshs dp,b,cc
 lbsr SetDPShortcut point DP to first 256 bytes of device memory area
 orcc #IntMasks turn IRQs off
 ldx #$0000 remove device from IRQ polling table
 os9 F$IRQ
 clra  
 clrb  
 std <rxBufCnt set receive buffer size to 0
 ldx <rxBufStrt
 stx <rxNextAddressForIncomingByte
 stx <rxNextAddressForOutgoingByte
 pshs x,d save receive buffer size (0) and ? buffer pointer
 ldb 4,s
 tfr b,cc
 ldx >D.Proc get current process descriptor
 lda P$ID,x get process ID for current process
 sta <V.BUSY set device as busy with current process
 sta <V.LPRC save as last active process
loop@ orcc #IntMasks turn IRQs off
 tst <txBufCnt
 bne cont0@
 ldx <V.PORT get pointer to 16550
 ldb UART_LSR,x get line status register
 eorb #UERR_THRE invert transmitter holding register empty bit flag
 andb #UERR_THRE and only keep that bit
 beq cont1@ it transmit is empty, skip ahead
cont0@ orcc #IntMasks else turn IRQs off
 lbsr SuspendProc suspend current process
 ldd 2,s get ? buffer pointer
 std <rxNextAddressForIncomingByte save in static memory
 ldd ,s get receive buffer size
 std <rxBufCnt save it into static memory
 bra loop@ keep going until transmit buffer is empty
* transmitter holding register on 16550 is empty
cont1@ leas 4,s eat temporary stack
 clr UART_IER,x disable 16550 interrupt enable
 clr UART_MCR,x clear modem control register on 16550
 andcc #^IntMasks turn IRQs back on
 ldd <rxBuffSize get number of bytes to return to system
 ldu <rxBufStrt get pointer to start page address to return RAM to system
 os9 F$SRtMem return the RAM to the system
 puls pc,dp,b,cc

* Suspend current process
SuspendProc 
 ifeq Level-1
TimedSleep equ 0 
 lda <V.BUSY
 sta <V.WAKE
 else
TimedSleep equ 1
 ldx >D.Proc get current process descriptor pointer
 tfr x,d Level 2 - upper 8 bits of process descriptor are stored in V.WAKE
 sta <V.WAKE save process as one to wake up upon I/O completion
 lda P$State,x get process status
 ora #Suspend set suspend state
 sta P$State,x and save it back
 endc
 ldx #TimedSleep sleep
 pshs cc
 andcc #^IntMasks turn IRQs on
 os9 F$Sleep  
 puls cc,pc
         
* Set DP to point to start of device mem ry (pointed to by U)
SetDPShortcut pshs u save our device memory pointer on stack
 puls dp get high byte of device memory pointer into DP
 leas 1,s eat low byte (don't need it) and return
 rts   

* Branch table used in BranchForIRQ. Based on IRQ type received from 16550
* Y = 16550 base address
IRQBranchTable fdb ModemStatusIRQ-BranchForIRQJump %000x IrMStar modem status register change IRQ
 fdb EmptyTxIRQ-BranchForIRQJump %001x IrTEMT transmitter holding register empty IRQ
 fdb RxReadyIRQ-BranchForIRQJump %010x IrRcvAv received data ready IRQ
 fdb RxLineChangeIRQ-BranchForIRQJump %011x IrLStat receiver line status change IRQ
 fdb UnkIRQ-BranchForIRQJump %100x unused IRQ - try re-reading 16550 IRQ, or unsuspend caller
 fdb UnkIRQ-BranchForIRQJump %101x unused IRQ - try re-reading 16550 IRQ, or unsuspend caller
 fdb RxDataTimeoutIRQ-BranchForIRQJump %110x received data timeout IRQ

* IRQ Service routine
IRQSvc clrb clear carry
 pshs dp,b,cc save registers
 bsr SetDPShortcut set DP to start of device memory
 clr <sigCode ???
 ldy <V.PORT get pointer to 16550
 ldb UART_IIR,y get interrupt identification register
 bitb #IIR_INTERRUPT_PENDING is an interrupt pending?
 beq BranchForIRQ yes, skip ahead
 tfr a,b copy value of UART_FCR passed to ISR to B for analysis
 andb #IIR_INTID_MASK strip the IRQ pending bit
 bne BranchForIRQ if any of the 3 bits are set, call 16550 IRQ dispatch table
 puls cc all clear, we likely were called in error, return carry set to IOMAN
 orcc #Carry so that it can continue through the IRQ polling table looking for source
 puls pc,dp,b restore registers and return

* Entry: B=16550 interrupt status register (lowest 4 bits only are used)
* Exit - calls routine based on table entry
BranchForIRQ leax >IRQBranchTable,pcr point to table
 andb #IIR_INTID_MASK keep IRQ identification bits only (also makes 2 byte entries)
 abx X=pointer to entry we need
 tfr pc,d save our current exec address (BranchForIRQJump) to D
BranchForIRQJump addd ,x add table offset
 tfr d,pc jump to routine

* Unknown IRQ from 16550 - try 2nd time, wake process if no IRQ waiting, or dispatch again if there is.
* Entry: Y=pointer to 16550 hardware
UnkIRQ ldb UART_IIR,y get interrupt identification register
 bitb #IIR_INTERRUPT_PENDING IRQ pending on 16550?
 beq BranchForIRQ yes, dispatch to appropriate IRQ service routine
 lda <V.WAKE no, get process to wake up
 beq bye@ none waiting, return
 ifgt Level-1
 clrb clear lower 8 bits
 stb <V.WAKE clear process to wake
 tfr d,x X=process descriptor to wake
* 6309 aim #^Suspend,P$State,x
 lda P$State,x get process status 
 anda #^Suspend unsuspend process
 sta P$State,x and save that back
 else 
 clr <V.WAKE
 ldb #S$Wake
 os9 F$Send
 endc
bye@ puls pc,dp,b,cc

* Received data ready IRQ from 16550 handler
* Entry: Y=pointer to 16550 hardware
RxReadyIRQ ldx <rxNextAddressForIncomingByte get pointer to where next received byte will go
 lda UART_LSR,y get line status register from 16550
 bmi ChkErrs if FDE bit set (FIFO data error), skip ahead
 ldb <fifoSize get number of bytes we are expecting to get with each receive IRQ from 16550
loop@ bsr GetNextRXByte
 decb  
 bne loop@
 bra RxDataLoop

RxDataTimeoutIRQ ldx <rxNextAddressForIncomingByte get pointer to where next received byte will go
RxDataLoop lda UART_LSR,y get byte from line status register
ChkErrs bita #LSR_ERR_MASK mask out all but error bits
 beq ckavail@ branch if no error
 lbsr HandleLSRErrors else go update error accumulator
 bra RxDataLoop
ckavail@ bita #LSR_DATA_AVAIL is data available?
 beq chksig@ no, skip ahead
 bsr GetNextRXByte
 bra RxDataLoop
chksig@ tst <sigCode is there a signal code pending?
 bne cont1@ branch if so
 ldd <ssSigCPR
 beq cont1@
 stb <sigCode
 os9 F$Send   
 clra  
 clrb  
 std <ssSigCPR
cont1@ stx <rxNextAddressForIncomingByte
 bra UnkIRQ

* B=number of bytes expected per receive IRQ
* Y=16550 base address
* X=pointer in receive buffer to put next character
GetNextRXByte lda UART_TRHB,y get character from data register on 16550
 beq SaveChar NUL, append to buffer
 tst <fcRXSWFlag are we in tx sw flow mode?
 bne SaveChar yes, append character to buffer
 cmpa <V.QUIT was it keyboard abort/quit key? (CTRL-E usually)
 bne ckintr@ no, check next
 lda #S$Abort else send keyboard abort signal
 lbra SendSignalToLastProcess
ckintr@ cmpa <V.INTR was it a keyboard interrupt signal? (CTRL-C usually)
 bne ckxon@ no, check next
 lda #S$Intrpt else send keyboard interrupt signal
 lbra SendSignalToLastProcess
ckxon@ cmpa <V.XON was it transmit on character?
 beq DoXON yes, go do
 cmpa <V.XOFF was it transmit off character?
 beq DoXOFF yes, go do
 cmpa <V.PCHR was it the pause character?
 lbeq DoPause yes, skip ahead
SaveChar pshs b save current FIFO bytes left counter
 sta ,x+ save character into receive buffer
 cmpx <rxBufEnd
 bne cont0@
 ldx <rxBufStrt
cont0@ cmpx <rxNextAddressForOutgoingByte are we at the next outgoing byte?
 bne cont2@ nope, skip ahead
 ldb #FrmingEr else buffer is full... set 2nd bit in error accumulator
 orb <V.ERR merge with current error accumulator
 stb <V.ERR and save it back
 cmpx <rxBufStrt
 bne cont1@
 ldx <rxBufEnd
cont1@ leax -1,x
 bra ex@
cont2@ stx <rxNextAddressForIncomingByte get address of next incoming byte
 ldd <rxBufCnt get number of bytes in buffer
 addd #$0001 increment
 std <rxBufCnt save it back
 cmpd <u002A
 beq cont3@ branch if equal
ex@ puls pc,b
cont3@ ldb <TxFloCtl get status flags
 bitb #%01110000 any of these bits set?
 bne ex@ branch if so
 lda <ITPARCopy get copy of IT.PAR
 bita #FCCTSRTS is this bit set?
 beq cont4@ branch if not
 orb #%00100000 update with RTS flow bit
 stb <TxFloCtl save status flags
 lda UART_MCR,y get modem control register
 anda #^MCR_RTS force RTS high
 sta UART_MCR,y save to modem control register
 bra ex@ exit
cont4@ bita #FCDSRDTR is this bit set?
 beq cont5@ branch if not
 orb #%00010000 update with DSR flow bit
 stb <TxFloCtl save status flags
 lda UART_MCR,y get modem control register
 anda #^MCR_DTR force DTR high
 sta UART_MCR,y save to modem control register
 bra ex@ exit
cont5@ bita #FCTXSW is this bit set?
 beq ex@ branch if not
 orb #%01000000 update with Rx sw flow bit
 stb <TxFloCtl save status flags
 lda <V.XOFF get transmit OFF character
 beq ex@ none, restore B and return
 sta <txNow save to sw flow character
 ldb #UINT_MODEM_STATUS+UINT_LINE_STATUS+UINT_THR_EMPTY+UINT_DATA_AVAIL
 stb UART_IER,y
 bra ex@

* XON char received
DoXON lda <TxFloCtl
 anda #^FCRXSW turn off tx sw flow flag
 sta <TxFloCtl
 tst <txBufCnt test tx buffer size
 beq ex@ branch if empty
 lda #UINT_MODEM_STATUS+UINT_LINE_STATUS+UINT_THR_EMPTY+UINT_DATA_AVAIL else set interrupts
 sta UART_IER,y
ex@ rts   

* XOFF char received
DoXOFF lda <TxFloCtl
 ora #FCRXSW
 sta <TxFloCtl
 lda #UINT_MODEM_STATUS+UINT_LINE_STATUS+UINT_DATA_AVAIL
 sta UART_IER,y
 rts   

* Send Signal to last process waiting on current device
* Entry: A=Signal code to send
SendSignalToLastProcess pshs b save B
 tfr a,b move signal code to B
 lda <V.LPRC get process of last process using device
 stb <sigCode save signal code
 os9 F$Send send signal to last process using device
 puls pc,b restore B and return

* Pause char received
DoPause ldu <V.DEV2 get pointer to static memory of echo device
 beq ex@ no echo device, return
 sta <V.PAUS,u yes, pause echo device
ex@ rts   

* Handle empty TX IRQ by feeding outgoing data to the 16550
EmptyTxIRQ ldx <txBufPos get pointer to end of tx buffer
 lda <txNow get XON character
 ble cont@ branch if is software flow character nul or high bit set
 sta UART_TRHB,y else send software flow character to 16550
 anda #$80 set high bit
 sta <txNow save it back to statics
cont@ tst <txBufCnt check tx buffer size
 beq cont2@ branch if buffer is empty
 ldb <TxFloCtl get modem status flags from statics
 bitb #FCTXSW test for Rx software flow control
 bne cont2@ branch if set
 andb #(TXF.NXON!TXF.NCTS!TXF.NDSR) are we waiting for flow contgrol?
 andb <ITPARCopy do we care?
 bne cont2@ yes, don't send
 ldb <txBufPos+1 otherwise, start transmitting -- get lower 8 bits of end pointer
 negb negate to get the remaining amount (256 - (txBufPos+1))
 cmpb #15 compare against 15
 bls cont1@ branch if lower or same
 ldb #15 else cap at 15
cont1@ cmpb <txBufCnt compare against number of tx bytes ready
 bls cont3@ branch if lower or same
 ldb <txBufCnt else cap at number of tx bytes ready
cont3@ pshs b save the count to the stack
loop@ lda ,x+ get the next available byte
 sta UART_TRHB,y store it in the register
loop1@ lda UART_LSR,y get value of line status register
 bita #LSR_XMIT_DONE is xmit done?
 beq loop1@ branch if not
 decb decrement the count
 bne loop@ branch if 
 cmpx <txBufEnd
 bcs cont4@
 ldx <txBufStrt
cont4@ stx <txBufPos
 ldb <txBufCnt
 subb ,s+
 stb <txBufCnt
cont5@ lbra UnkIRQ
cont2@ lda #UINT_MODEM_STATUS+UINT_LINE_STATUS+UINT_DATA_AVAIL
 sta UART_IER,y update 16550 hardware
 bra cont5@

* Handle modem status IRQ
ModemStatusIRQ lda UART_MSR,y get modem status register
 tfr a,b copy to B
 andb #MSR_CD+MSR_DSR+MSR_CTS save CD/DSR/CTS states
 stb <msrCopy and put into statics
 ldb <TxFloCtl get modem status flags
 andb #^(TXF.NCTS!TXF.NDSR) the bits we might change
 bita #MSR_CTS CTS up?
 bne cont0@ branch if so
 orb #TXF.NCTS no, start waiting for it
cont0@ bita #MSR_DSR DSR up?
 bne cont1@ yes, skip ahead
 orb #TXF.NDSR no, wait for it
cont1@ bita #MSR_DDCD change in DCD?
 beq cont4@ no, skip ahead
 bita #MSR_CD CD set?
 bne cont3@ yes, skip ahead
 lda <ITPARCopy
 bita #MdmKill modem kill?
 beq cont2@ no, skip ahead
 ldx <V.PDLHd get open path descriptor's head link for device users
 beq cont2@ none (1 user only?), skip ahead
 lda #PST.DCD flag carrier detect lost
loop@ sta <PD.PST,x set carrier detect lost on current path
 ldx <PD.PLP,x get path descriptor list pointer
 bne loop@ there is one, flag it and all others in list as carrier lost
cont2@ lda #DCDLstEr set DCD lost error in error accumulator
 ora <V.ERR merge with current error accumulator
 sta <V.ERR and save it back
 andb #^FCRXSW clear bit for tx sw flow
cont3@ tst <sigCode is there a signal code pending?
 bne cont4@ branch if so
 stb <TxFloCtl else save off flags
 ldd <pathDescCPR get current process and signal
 tstb signal zero?
 beq cont5@ branch if so
 os9 F$Send else send the signal  
 stb <sigCode save the signal code we sent
 clra clear D
 clrb  
 std <pathDescCPR clear off path descriptor and current process
 bra cont5@
cont4@ stb <TxFloCtl save flags
cont5@ lda #UINT_MODEM_STATUS+UINT_LINE_STATUS+UINT_THR_EMPTY+UINT_DATA_AVAIL load interrupts we want
 sta UART_IER,y set interrupts in 16550
 lbra UnkIRQ handle unknown IRQ

RxLineChangeIRQ lda UART_LSR,y get the line status register
 bsr HandleLSRErrors handle any errors
 lbra UnkIRQ handle unknown IRQ

* Updates the V.ERR field in the static storage
* A = LSR error bits
HandleLSRErrors pshs b save error code
 clrb clear B
 bita #LSR_ERR_OVERRUN is overrun error?
 beq ckpar@ branch if not
 orb #OvrFloEr set bit for V.ERR
ckpar@ bita #LSR_ERR_PARITY is parity error?
 beq ckframe@ branch if not
 orb #ParityEr set bit for V.ERR
ckframe@ bita #LSR_ERR_FRAME is framing error?
 beq ckbreak@
 orb #FrmingEr
ckbreak@ bita #LSR_BREAK_INT is break
 bne ex@ branch if so
 orb #BrkEr set bit for V.ERR
 orb <V.ERR merge with current error accumulator
 stb <V.ERR and save it back
ex@ puls pc,b

* IRQ Packet settings
IRQPckt fcb $01 flip byte 16550 device address+2 is status register, and lowest
 fcb $01 mask byte bit clear means IRQ needs to be serviced
 fcb $80 IRQ priority
         
brate macro
 fdb ClkRate/16/\1,((FCR_FIFOE!FRT_\2)*256)+\2
 endm
 
* Baud Rate Table. 4 bytes/entry, and 16 entries (0-15).
* Byte order of each entry:
*   ,0=HDiv (high byte of divisor latch) \ 16550 needs little endian, so we should swap these and
*   ,1=LDiv (low byte of divisor latch)  / remove the exg a,b the calling routine currently uses LCB
*   ,2=UART_FCR settings EXCEPT FCR_RXR & FCR_TXR, which are forced on in calling routine
*   ,3=FIFO trigger level ctr - must be 1,4,8 or 14 (used for read loop counters)
*
* Deek's convenience macro assists with easy conversion.
BaudTable
 ifne wildbits
* 25.175 MHz crystal - Wildbits
ClkRate set 25175000
 else
 ifne Fast232
 else
* 18.432 MHz crystal - CoNect Fast232
ClkRate set 18432000
 endc
* 29.4912 MHz crystal - Zippsterzone MegaMiniMPI - Deek's experimental settings
ClkRate set 29491200
 endc

 brate 110,1
 brate 300,1
 brate 600,4
 brate 1200,8
 brate 2400,14
 brate 4800,14
 brate 9600,14
 brate 19200,8
 brate 38400,8
 brate 57600,8
 brate 115200,8
 brate 230400,8
 brate 230400,8
 brate 460800,8
 brate 921600,8
 brate 31125,8
 
 emod
eom equ *
 end
