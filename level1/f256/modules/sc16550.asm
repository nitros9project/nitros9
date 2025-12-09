 nam sc16550
 ttl 16550 device driver

 use defsfile

* GetStat calls unique to sc16550 (move to main defs later)
SS.WrtBf equ $C1 return stats on the transmit buffer
SS.DvrID equ $D2 driver ID (returns info on current driver)

* SetStat calls unique to sc16550 (move to main defs later)
SS.TxF1R equ $C2 clear transmitter software flow control
SS.TxFlh equ $C3 flushes (discards) transmit buffer contents

tylg set Drivr+Objct   
atrv set ReEnt+rev
rev set $01

 mod eom,name,tylg,atrv,start,size

* Static memory storage.
* NOTE: We reassign to DP for faster access in all driver branch routines
* Based on Bruce Isted's XACIA, although with some changes
 org V.SCF allow for SCF manager data read
wrkType rmb 1 copy of parity settings from descriptor (IT.PAR) \ must be
wrkBaud rmb 1 copy of baud rate from descriptor (IT.BAU)       / together
altBauFl rmb 1 alternate baud rate table flag (0=normal); use for older comm programs with new baud rates
msrCopy rmb 1 copy of MSR register
fcrCopy rmb 1 copy of FCR register
rawMode rmb 1
pathDescCPR rmb 1 process to receive signal (from path descriptor)
pathDescSignal rmb 1 signal to send (from path descriptor)
ssSigCPR rmb 1 process to receive signal (set by SS.SSig)
ssSigSignal rmb 1 signal to send (set by SS.SSig)
sigCode rmb 1  signal code (for send)
mstatFlags rmb 1
fifoSize rmb 1 16550 FIFO size
u002A rmb 2
rxNextAddressForIncomingByte rmb 2 pointer to the next place in the RX buffer to place incoming data
rxNextAddressForOutgoingByte rmb 2 pointer to next place in the RX buffer to get data from
rxAddressOfEndOfBuffer rmb 2 pointer to the end of the RX buffer
rxBuffStartPtr rmb 2 receive buffer start pointer
rxBuffNumBytes rmb 2 receive buffer - current number of bytes in it
rxBuffSize rmb 2 V.BUFSIZ (# of extra bytes we reserved in static memory >256 SCF gave us)
txBuffNextEmpty rmb 2 transmit buffer pointer
txBuffEndPtr rmb 2 transmit buffer end pointer
txBuffPhyEndPtr rmb 2 physical end of transmit buffer
txBuffPhyStartPtr rmb 2 physical start of transmit buffer
txBuffSize rmb 1 transmit buffer size
txBuffAllocedSize rmb 2 allocated size of transmit buffer
xonChar rmb 1
txBuff rmb 188 transmit buffer
size equ .

 fcb $03

name fcs /sc16550/

edition fcb 12

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
 ldd <V.PORT get pointer to 16550 hardware base address
 addd #UART_FCR point to 16550 status register
 pshs y save pointer to device descriptor
 leax >IRQPckt,pcr point to 5 byte IRQ packet settings
 leay >IRQSvc,pcr point to IRQ service routine
 os9 F$IRQ install ourselves in IRQ polling table
 puls y get device descriptor pointer back
 bcc cont@ no error installing IRQ, continue
 puls a,cc error, restore regs
 orcc #Carry flag error (error code still in B)
 puls pc,dp restore DP & return with error
* Add ourselves into IRQ polling table work, continue
cont@ lda <M$Opt,y get number of option bytes in descriptor
 cmpa #IT.XTYP-IT.DTP ($1C) is there an extended type byte in descriptor?
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
 stb 1,s couldn't get the memory, so save error code into B on stack
 ldx #$0000 remove device from IRQ polling table
 os9 F$IRQ        
 puls dp,b,cc restore registers and error number
 orcc #Carry return with error
 rts
cont2@ stx <rxBuffStartPtr save pointer to start of receive buffer
 stx <rxNextAddressForIncomingByte save pointer to next incoming byte location
 stx <rxNextAddressForOutgoingByte save poniter to next outgoing byte location
 std <rxBuffSize save size of receive buffer
 leax d,x point to end of receive buffer
 stx <rxAddressOfEndOfBuffer save end of receive buffer pointer
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
 stx <txBuffPhyStartPtr save transmit buffer pointer
 stx <txBuffNextEmpty ?save active transmit buffer start pointer?
 stx <txBuffEndPtr ?save active transmit buffer end pointer?
 leax >256,u point to end of transmit buffer
 stx <txBuffPhyEndPtr save end of transmit buffer pointer
 ldd #size-txBuff size of transmit buffer
 std <txBuffAllocedSize save it
 clr <rxBuffNumBytes (RxBufSiz) Clear Receive buffer size (16 bit) 
 clr <rxBuffNumBytes+1 (RxBufSiz+1)
 clr <txBuffSize clear transmit buffer size
 ldd <IT.PAR,y get parity & baud rate settings from device descriptor
 std <wrkType save copies in device memory
 lbsr SetBaud set some stuff up based on the data table at end of driver
 ldx <V.PORT get pointer to 16550 hardware
 lda UART_LSR,x get line status register
 lda ,x get data register
* Why are reading both into same register?
 lda UART_LSR,x get line status register again
 lda UART_MSR,x get modem status register
 anda #UCTRL_RDCD+UCTRL_DSR+UCTRL_CTS only keep receive data carrier detect, data set ready, and clear to send bits
 sta <msrCopy save them
 clrb clear our "results" register - all 3 of the above off
 bita #UCTRL_CTS is CTS bit set?
 bne cont4@ no, skip ahead
 orb #%00000010 else add that bit flag
cont4@ bita #UCTRL_DSR is DSR bit set?
 bne cont5@ yes, skip ahead
 orb #%00000001 else add that bit flag
cont5@ stb <mstatFlags save flags
* Turn on interrupt controller's interrupt for the UART         
 lda INT_MASK_1
 anda #~INT_UART
 sta INT_MASK_1
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
 ldx <txBuffNextEmpty get pointer to next empty spot in our transmit buffer
 sta ,x+ append the character
 cmpx <txBuffPhyEndPtr have we hit physical end of transmit buffer?
 blo cont1@ no, skip ahead
 ldx <txBuffPhyStartPtr yes, point to physical start of transmit buffer
cont1@ orcc #IntMasks IRQs off
 cmpx <txBuffEndPtr have we caught up with beginning in wraparound buffer?
 bne cont3@ no, skip ahead
 pshs x else save pointer
 lbsr SuspendProc suspend current process
 puls x recover pointer
 ldu >D.Proc get pointer to current process descriptor
 ldb <P$Signal,u  get any current signal code
* 6809/6309 - change to beq cont1@
 beq cont2@ no signal, go back
 cmpb #S$Intrpt is it a Keyboard Interrupt, Abort, or Wake signal?
 bls cont4@ yes, restore registers and return
cont2@ bra cont1@ else loop back
cont3@ stx <txBuffNextEmpty save updated pointer to next free spot in transmit buffer
 inc <txBuffSize increase number of bytes in driver's transmit buffer
 bsr EnableIRQSources enable all IRQ's on 16550 *including* transmitter empty IRQ
cont4@ puls pc,dp,b,cc 
* Enable all 4 16550 IRQ sources
EnableIRQSources lda #UINT_MODEM_STATUS+UINT_LINE_STATUS+UINT_THR_EMPTY+UINT_DATA_AVAIL enable modem status, receiver line status, transmitter empty & receive data available interrupts on 16550
 bra cont5@
* Enable all 16550 IRQ sources *except* transmitter empty
 lda #UINT_MODEM_STATUS+UINT_LINE_STATUS+UINT_DATA_AVAIL enable modem status, receiver line status, and receive data available interrupts on 16550
cont5@ ldx <V.PORT get pointer to 16550
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
 ldd <rxBuffNumBytes get number of bytes in receive buffer
 beq suspend@ none, so go suspend process
 cmpd #16 expected bytes ready?
 lbne getchar@ no, skip ahead
 andcc #^IntMasks turn IRQs on
 bsr setirqs@
chkfreebuff@ orcc #IntMasks turn IRQs off
 ldd <rxBuffNumBytes get receive buffer free count
 bne getchar@ branch if not zero
suspend@ lbsr SuspendProc suspend current process
 ldx >D.Proc get the current process descriptor
 ldb <P$Signal,x get possible pending signal
 beq chkcondem@ branc if none
 cmpb #S$INTRPT interrupt signal?
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
 std <rxBuffNumBytes and save it back
 ldx <rxNextAddressForOutgoingByte get address of next byte in RX buffer to read
 lda ,x+ get that byte and increment X
 cmpx <rxAddressOfEndOfBuffer are we at the end of the RX buffer?
 bne geterr@ branch if not
 ldx <rxBuffStartPtr else wrap around to start of RX buffer
geterr@ stx <rxNextAddressForOutgoingByte save updated pointer
 andcc #^IntMasks turn IRQs on
 ldb <V.ERR get error accumulator
 beq exit2@ no errors, restore registers and return
saveerr@ stb <PD.ERR,y save error accumulator to path descriptor
 clr <V.ERR clear out error accumulator
 puls dp,a,cc restore registers
 bitb #$20 check if carrier lost
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
 ldb <mstatFlags get flag bits based on modem status
 bitb #%01110000 ???
 beq exit@ if none of the 3 bits are set, turn IRQs back on and return
 bitb #%00100000 is bit 5 alone set?
 beq cont1@ no, skip ahead
 orcc #IntMasks else turn IRQs off
* 6309 - aim #$DF,<mstatFlags
 ldb <mstatFlags get flag bytes back (LCB NOTE: WE STILL HAVE THEM IN B, WHY ARE WE RELOADING?)
 andb #%11011111 clear bit 5
 stb <mstatFlags save flags back
* 6309 - oim #RTS,UART_MCR,x
 lda UART_MCR,x get modem control register
 ora #MCR_RTS set RTS (request to send) bit
 sta UART_MCR,x save modified modem control register back
exit@ puls pc,cc turn IRQs back on and return
cont1@ bitb #%00010000 bit 4 set?
 beq cont2@ no, skip ahead
 orcc #IntMasks shut off IRQs
* 6309 - aim #$EF,<mstatFlags
 ldb <mstatFlags get flags
 andb #%11101111 clear bit 4
 stb <mstatFlags and write it back
* 6309 - oim #
 lda UART_MCR,x get modem control register
 ora #MCR_DTR set DTR (data terminal ready) bit
 sta UART_MCR,x and write back to 16550
* 6809/6309 - replace with puls pc,cc (same size, 3 cyc faster)
 bra exit@ turn IRQs back on and return
cont2@ bitb #%01000000 bit 6 set?
 beq exit@ no, turn IRQs back on and return
 ldb <V.XON else get XON char
 orcc #IntMasks turn IRQs off
 stb <xonChar save XON char
 lbsr EnableIRQSources enable ALL 4 IRQs on 16550 (including transmit)
* 6309 aim #$BF,<mstatFlags
 ldb <mstatFlags get flags byte again
 andb #%10111111 clear bit 6
 stb <mstatFlags and write it back
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
GetStat clrb  
 pshs dp,b,cc
 lbsr SetDPShortcut point DP to first 256 bytes of device memory area
 cmpa #SS.Ready data ready call?
 bne chkcomstt@ no, check next
 ldd <rxBuffNumBytes else any data ready in driver's receive buffer?
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
 ldd <wrkType get parity and baud settings from device memory
 tst <altBauFl is alternate baud table in use?
 beq  chcomstt1@ no, leave as is
 bitb #$04 else if >=2400 baud, values stay the same 
 bne  chcomstt1@
 andb #%11110111 force to fit original 3 bit spec (this covers 38400,57600,76800,115200)
chcomstt1@ ldx PD.RGS,y get callers register stack pointer from path descriptor
 std R$Y,x save parity and baud bytes back to caller in Y
 clrb clear return value
 lda <msrCopy get current DCD, DSR & CTS bit flags from copy of modem status register
 bita #UCTRL_RDCD is carrier detect enabled?
 bne chkcomstt2@ no, skip ahead
 orb #$10 else set DCD status in bit 5 (for compatibility with older drivers) in B
chkcomstt2@ bita #UCTRL_DSR is data set ready enabled?
 bne chkcomstt3@ no, done with B
 orb #$40 else set DSR status in bit 6 (for compatibility with older drivers) in B
chkcomstt3@ stb R$B,x save special CD/DSR status byte in caller's B
* 6809/6309 - replace with puls  pc,dp,b,cc (1 byte smaller, 4 or 5 cycles faster)
 bra restoreandreturn@ restore registers and return
chkeof@ cmpa  #SS.EOF end of file check?
 bne chkdvrid@ no, check next
 clrb else exit without error
* 6809/6309 - replace with puls  pc,dp,b,cc (1 byte smaller, 4 or 5 cycles faster)
 bra  restoreandreturn@ restore registers and return
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
 leau >L0678,pcr point to data table (I think last byte is FIFO size?)
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
 lda <wrkType get work copy of parity settings
 lsra shift out CTS/RTS & DSR/DTR bits
 lsra  
 anda #LCR_PARITY_MASK only keep the 3 parity bits (in right position for UART_LCR on 16550)
 ora 1,s merge in the word length bits (lowest 2)
 sta 1,s sve new copy on stack
 ora #LCR_DLB turn on LCR_DLB (Divisor Latch Access bit)
 orcc #IntMasks turn IRQs off
 sta  UART_LCR,x set word length & parity, and switch LCR_DLB to 1 (so we can program baud rate)
 ldd ,u++ get divisorlLatch value
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
SetStat clrb  
 pshs dp,b,cc
 lbsr SetDPShortcut point DP to first 256 bytes of device memory area
 cmpa #SS.ComSt is it com stat?
 bne chkhngup@ branch if not
 ldy PD.RGS,y get caller's registers pointer
 ldd R$Y,y get Y (high byte: parity, low byte: baud rate)
 tst <altBauFl get alternate baud rate table flag
 beq cont1@ branch if clear (use regular baud rate table)
 bitb #$04 check if >=2400 baud
 bne cont1@ branch if clear
 orb #$08
cont1@ std <wrkType save parity & baud rate settings
 lbsr SetBaud go set the baud rate
 clr <rawMode assume no raw mode
 tst <V.QUIT is there a keyboard abort/quit character defined?
 bne cont2@ yes, skip ahead
 tst <V.INTR is there a keyboard interrupt character defined?
 bne cont2@ yes, skip ahead
 tst <V.PCHR is there a pause character set?
 bne cont2@ yes, skip ahead
 ldb <wrkType get parity byte
 bitb #$04
 bne cont2@
 inc <rawMode set raw mode
cont2@ lbra RestoreAndExit
chkhngup@ cmpa #SS.HngUp hangup?
 bne chkbreak@ branch if not
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
 orcc #IntMasks
 ldx <V.PORT get pointer to 16550
 lda <mstatFlags
 ora #$08
 sta <mstatFlags
 lda #$0D
 sta UART_IER,x
 clr <txBuffSize
 ldd <txBuffPhyStartPtr
 std <txBuffEndPtr
 std <txBuffNextEmpty
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
 lda <mstatFlags
 anda #$F7
 sta <mstatFlags
 lbra RestoreAndExit
chkssig@ cmpa #SS.SSig
 bne chkrelea@
 lda PD.CPR,y
 ldy PD.RGS,y
 ldb R$X+1,y
 orcc #IntMasks
 ldx <rxBuffNumBytes
 bne sendsig@
 std <ssSigCPR save SS.SSig current process and signal code to send
 lbra RestoreAndExit
sendsig@ puls cc
 os9 F$Send send signal
 puls pc,dp,b
chkrelea@ cmpa #SS.Relea release?
 bne chkcdsig@
 lda PD.CPR,y
 cmpa <ssSigCPR
 bne L0392
 clra clear SS.SSig process
 clrb clear SS.SSig signal
 std <ssSigCPR save to our variables
L0392 lbra RestoreAndExit
chkcdsig@ cmpa #SS.CDSig CD signal?
 bne chkcdrel@ branch if not
 lda PD.CPR,y else get current process from path descriptor
 ldy PD.RGS,y get caller register stack pointer
 ldb R$X+1,y get signal to send from caller's stack
 std <pathDescCPR save CPR and signa from path descriptor
 bra RestoreAndExit
chkcdrel@ cmpa  #SS.CDRel CD release?
 bne chkclose@ branch if not
 orcc #IntMasks mask interupts
 lda PD.CPR,y get current process from path descriptor
 cmpa <pathDescCPR same as saved?
 bne L03B4 branch if not
 clra else clear current process
 clrb and signal to send
 std <pathDescCPR update saved values
L03B4 bra RestoreAndExit
chkclose@ cmpa #SS.Close close?
 lbne chkopen@ branch if not
 orcc #IntMasks mask interrupts
 lda PD.CPR,y get current process from path descriptor
 ldx #$0000
 cmpa <ssSigCPR same as process from SS.SSig?
 bne L03C9 no
 stx <ssSigCPR clear SS.SSig process and signal
L03C9 cmpa <pathDescCPR same as process from path descriptor
 bne L03CF no 
 stx <pathDescCPR clear path descriptor process and signal
L03CF bra RestoreAndExit
chkopen@ cmpa  #SS.Open open?
 bne unksvc@ branch if not
 ldx <V.PORT get pointer to 16550
 lda #$03
 sta UART_MCR,x
 ldb #$0F
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
 clra  
 clrb  
 std <rxBuffNumBytes set receive buffer size to 0
 ldx <rxBuffStartPtr
 stx <rxNextAddressForIncomingByte
 stx <rxNextAddressForOutgoingByte
 pshs x,d save receive buffer size (0) and ? buffer pointer
 ldb 4,s
 tfr b,cc
 ldx >D.Proc get current process descriptor
 lda P$ID,x get process ID for current process
 sta <V.BUSY set device as busy with current process
 sta <V.LPRC save as last active process
L040C orcc #IntMasks turn IRQs off
 tst <txBuffSize
 bne L041C
 ldx <V.PORT get pointer to 16550
 ldb UART_LSR,x get line status register
 eorb #UERR_THRE invert transmitter holding register empty bit flag
 andb #UERR_THRE and only keep that bit
 beq L042B it transmit is empty, skip ahead
L041C orcc #IntMasks else turn IRQs off
 lbsr SuspendProc suspend current process
 ldd 2,s get ? buffer pointer
 std <rxNextAddressForIncomingByte save in static memory
 ldd ,s get receive buffer size
 std <rxBuffNumBytes save it into static memory
 bra L040C keep going until transmit buffer is empty
* transmitter holding register on 16550 is empty
L042B leas 4,s eat temporary stack
 clr UART_IER,x disable 16550 interrupt enable
 clr UART_MCR,x clear modem control register on 16550
 andcc #^IntMasks turn IRQs back on
 ldd <rxBuffSize get number of bytes to return to system
 ldu <rxBuffStartPtr get pointer to start page address to return RAM to system
 os9 F$SRtMem return the RAM to the system
 ldx #$0000 flag to remove device from IRQ polling table
 os9 F$IRQ    
 puls pc,dp,b,cc

* Suspend current process
SuspendProc ldx >D.Proc get current process pointer
 lda P$ID,x get process status
 sta <V.WAKE save process as one to wake up upon I/O completion
 ifgt Level-1
 lda P$State,x get process status
 ora #Suspend set suspend state
 sta P$State,x and save it back
 andcc #^IntMasks turn IRQs on
 endc
 ldx #$0001 sleep remainder of current time slice
 os9 F$Sleep  
 rts   
         
* Set DP to point to start of device memory (pointed to by U)
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
IRQSvc clrb
 pshs dp,b,cc
 bsr SetDPShortcut set DP to start of device memory
 clr <sigCode ???
 ldy <V.PORT get pointer to 16550
 ldb UART_IIR,y get interrupt identification register
 bitb #IIR_INTERRUPT_PENDING is an interrupt pending?
 beq BranchForIRQ yes, skip ahead
* tfr a,b
 andb #IIR_INTID_MASK strip the IRQ pending bit
 bne BranchForIRQ if any of the 3 bits are set, call 16550 IRQ dispatch table
 puls cc all clear, we likely were called in error, return carry set to IOMAN
 orcc #Carry so that it can continue through the IRQ polling table looking for source
 puls pc,dp

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
 clrb  
 stb <V.WAKE clear process to wake
 tfr d,x X=process descriptor to wake
* 6309 aim #^Suspend,P$State,x
 lda P$State,x get process status 
 anda #^Suspend unsuspend process
 sta P$State,x and save that back
 else 
 ldb <V.Wake
 lda #S$Wake
 os9 F$Send
 endc
bye@ puls pc,dp,b,cc

* Received data ready IRQ from 16550 handler
* Entry: Y=pointer to 16550 hardware
RxReadyIRQ  ldx <rxNextAddressForIncomingByte get pointer to where next received byte will go
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
 beq getbyte@
 bsr GetNextRXByte
 bra RxDataLoop
getbyte@ tst <sigCode is there a signal code pending?
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
 beq L050E NUL, append to buffer
 tst <rawMode are we in raw mode?
 bne L050E if so, append character to buffer
 cmpa <V.QUIT was it keyboard abort/quit key? (CTRL-E usually)
 bne ckintr@ no, check next
 lda #S$Abort else send keyboard abort signal
 lbra SendSignalToLastProcess
ckintr@ cmpa <V.INTR was it a keyboard interrupt signal? (CTRL-C usually)
 bne ckxon@ no, check next
 lda #S$Intrpt else send keyboard interrupt signal
 lbra SendSignalToLastProcess
ckxon@ cmpa <V.XON was it transmit on character?
 beq L0578 yes, go do
 cmpa <V.XOFF was it transmit off character?
 beq L0587 yes, go do
 cmpa <V.PCHR was it the pause character?
 lbeq L059F yes, skip ahead
L050E pshs b save current FIFO bytes left counter
 sta ,x+ save character into receive buffer
 cmpx <rxAddressOfEndOfBuffer
 bne L0518
 ldx <rxBuffStartPtr
L0518 cmpx <rxNextAddressForOutgoingByte are we at the next outgoing byte?
 bne L052C nope, skip ahead
 ldb #%00000010 else buffer is full... set 2nd bit in error accumulator
 orb <V.ERR merge with current error accumulator
 stb <V.ERR and save it back
 cmpx <rxBuffStartPtr
 bne L0528
 ldx <rxAddressOfEndOfBuffer
L0528 leax -1,x
 bra L053A
L052C stx <rxNextAddressForIncomingByte get address of next incoming byte
 ldd <rxBuffNumBytes get number of bytes in buffer
 addd #$0001 increment
 std <rxBuffNumBytes save it back
 cmpd <u002A
 beq L053C branch if equal
L053A puls pc,b
L053C ldb <mstatFlags
 bitb #$70
 bne L053A
 lda <wrkType
 bita #$02
 beq L0554
 orb #$20
 stb <mstatFlags
 lda UART_MCR,y
 anda #^MCR_RTS
 sta UART_MCR,y
 bra L053A

L0554 bita #$01
 beq L0564
 orb #$10
 stb <mstatFlags
 lda UART_MCR,y
 anda #^MCR_DTR
 sta UART_MCR,y
 bra L053A

L0564 bita #$08
 beq L053A
 orb #$40
 stb <mstatFlags
 lda <V.XOFF get transmit OFF character
 beq L053A none, restore B and return
 sta <xonChar
 ldb #$0F
 stb UART_IER,y
 bra L053A

* XON char read
L0578 lda <mstatFlags
 anda #$FB
 sta <mstatFlags
 tst <txBuffSize
 beq L0586
 lda #$0F
 sta UART_IER,y
L0586 rts   

* XOFF char read
L0587 lda <mstatFlags
 ora #$04
 sta <mstatFlags
 lda #$0D
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
L059F ldu <V.DEV2 get pointer to static memory of echo device
 beq L05A6 no echo device, return
 sta <V.PAUS,u yes, pause echo device
L05A6 rts   

EmptyTxIRQ ldx <txBuffEndPtr
 lda <xonChar
 ble L05B3
 sta UART_TRHB,y
 anda #$80
 sta <xonChar
L05B3 tst <txBuffSize
 beq L05EC
 ldb <mstatFlags
 bitb #$08
 bne L05EC
 andb #$07
 andb <wrkType
 bne L05EC
 ldb <txBuffEndPtr+1
 negb  
 cmpb #$0F
 bls L05CC
 ldb #$0F
L05CC cmpb <txBuffSize
  bls L05D2
  ldb <txBuffSize
L05D2 pshs b
L05D4 lda ,x+
 sta UART_TRHB,y
 decb  
 bne L05D4
 cmpx <txBuffPhyEndPtr
 bcs L05E1
 ldx <txBuffPhyStartPtr
L05E1 stx <txBuffEndPtr
 ldb <txBuffSize
 subb ,s+
 stb <txBuffSize
L05E9 lbra UnkIRQ
L05EC lda #UINT_MODEM_STATUS+UINT_LINE_STATUS+UINT_DATA_AVAIL
 sta UART_IER,y
 bra L05E9

ModemStatusIRQ lda UART_MSR,y
 tfr a,b
 andb #UCTRL_RDCD+UCTRL_DSR+UCTRL_CTS
 stb <msrCopy
 ldb <mstatFlags
 andb #$FC
 bita #UCTRL_CTS
 bne L0604
 orb #$02
L0604 bita #UCTRL_DSR
 bne L060A
 orb #$01
L060A bita #$08
 beq L0644
 bita #$80
 bne L062E
 lda <wrkType
 bita #$10
 beq L0626
 ldx <V.PDLHd get open path descriptor's head link for device users
 beq L0626 none (1 user only?), skip ahead
 lda #PST.DCD flag carrier detect lost
L061E sta <PD.PST,x set carrier detect lost on current path
 ldx <PD.PLP,x get path descriptor list pointer
 bne L061E there is one, flag it and all others in list as carrier lost
L0626 lda #%00100000 set bit 5 in error accumulator
 ora <V.ERR merge with current error accumulator
 sta <V.ERR and save it back
 andb #%11111011 clear bit 2
L062E tst <sigCode
 bne L0644
 stb <mstatFlags
 ldd <pathDescCPR
 tstb  
 beq L0646
 os9 F$Send   
 stb <sigCode
 clra  
 clrb  
 std <pathDescCPR
 bra L0646

L0644 stb <mstatFlags
L0646 lda #$0F
 sta UART_IER,y
 lbra UnkIRQ

RxLineChangeIRQ lda UART_LSR,y
 bsr HandleLSRErrors
 lbra UnkIRQ

* A = LSR error bits
HandleLSRErrors pshs b save error code
 clrb clear B
 bita #LSR_ERR_OVERRUN is overrun error?
 beq ckpar@ branch if so
 orb #$04 set bit for V.ERR
ckpar@ bita #LSR_ERR_PARITY is parity error?
 beq ckframe@ branch if so
 orb #$01 et bit for V.ERR
ckframe@ bita #LSR_ERR_FRAME is framing error?
 beq ckbreak@
 orb #$02
ckbreak@ bita #LSR_BREAK_INT is break
 bne ex@ branch if not
 orb #$08 et bit for V.ERR
 orb <V.ERR merge with current error accumulator
 stb <V.ERR and save it back
ex@ puls pc,b

* IRQ Packet settings
IRQPckt fcb $01 flip byte 16550 device address+2 is status register, and lowest
 fcb $01 mask byte bit clear means IRQ needs to be serviced
 fcb $80 IRQ priority
         
* Some other data table. Should be 4 bytes/entry, and 16 entries (0-15). Related to baud rate
* Byte order of each entry:
*   ,0=HDiv (high byte of divisor latch) \ 16550 needs little endian, so we should swap these and
*   ,1=LDiv (low byte of divisor latch)  / remove the exg a,b the calling routine currently uses LCB
*   ,2=UART_FCR settings EXCEPT FCR_RXR & FCR_TXR, which are forced on in calling routine
*   ,3=FIFO trigger level ctr - must be 1,4,8 or 14 (used for read loop counters)
* 25.175 MHz crystal based table - F256
L0678 fcb $37,$df,FCR_FIFOE,1 110 baud, 1 byte FIFO, 1 byte counter
 fcb $14,$7c,FCR_FIFOE,1 300 baud, 1 byte FIFO, 1 byte counter
 fcb $0a,$3e,FCR_FIFOE+FCR_RXT_6,4 600 baud, 4 byte FIFO, 4 byte counter
 fcb $05,$1f,FCR_FIFOE+FCR_RXT_7,8 1200 baud, 8 byte FIFO, 8 byte counter
 fcb $02,$8f,FCR_FIFOE+FCR_RXT_8,14 2400 baud, 14 byte FIFO, 14 byte counter
 fcb $01,$47,FCR_FIFOE+FCR_RXT_8,14 4800 baud, 14 byte FIFO, 14 byte counter
 fcb $00,$a3,FCR_FIFOE+FCR_RXT_8,14 9600 baud, 14 byte FIFO, 14 byte counter
 fcb $00,$51,FCR_FIFOE+FCR_RXT_7,8 19200 baud, 8 byte FIFO, 8 byte counter
 fcb $00,$28,FCR_FIFOE+FCR_RXT_7,8 38400 baud, 8 byte FIFO, 8 byte counter
 fcb $00,$1b,FCR_FIFOE+FCR_RXT_7,8 57600 baud, 8 byte FIFO, 8 byte counter (shouldn't Divs be $000F?)
 fcb $00,$0d,FCR_FIFOE+FCR_RXT_7,8 115200 baud, 8 byte FIFO, 8 byte counter (shouldn't Divs be $0007?)
 fcb $00,$0a,FCR_FIFOE+FCR_RXT_7,8 undefined baud, 8 byte FIFO, 8 byte counter
 fcb $00,$0a,FCR_FIFOE+FCR_RXT_7,8 undefined baud, 8 byte FIFO, 8 byte counter
 fcb $00,$0a,FCR_FIFOE+FCR_RXT_7,8 undefined baud, 8 byte FIFO, 8 byte counter
 fcb $00,$0a,FCR_FIFOE+FCR_RXT_7,8 undefined baud, 8 byte FIFO, 8 byte counter
 fcb $00,$32,FCR_FIFOE+FCR_RXT_7,8 31125 baud, 8 byte FIFO, 8 byte counter (for MIDI)
 
 emod
eom equ *
 end
