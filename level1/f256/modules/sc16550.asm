* 6809 CoNect 16550 Fast232 driver- 'short' (less enhanced) version, edition 12
* Does use S(D)ACIA extended attribute byte (XTP) for both # of receive buffer pages
* (256 bytes each) (bits 0-3_, and bit 4 as "Alternate baud rate" table (to access
* higher speeds when using older software that limits the max baud rate setting)
* NOTE: There are some changes in the source that Rick sent (newer edition), but data
* tables are wrong,etc. in their disassembly. Will need to check how optimized it is vs
* this code (Term is a fall through, for example).
* It looks like the default is 256 byte receive buffer, and 188 byte transmit buffer
* NOTE: While static mem is based on XACIA code, it does have some changes


         nam   sc16550
         ttl   os9 device driver    

* Disassembled 2020/05/12 18:50:02 by Disasm v1.6 (C) 1988 by RML

         use   defsfile

Fast232  set   0            Rick's original Fast232 pak (18.432 Mhz crystal)=1
*                           0=29.4912 MHz crystal used in Ed Sniders MegaMiniMPI

* GetStat calls unique to s16550 (move to main defs later)
SS.WrtBf equ   $C1          Return stats on the Transmit buffer
SS.DvrID equ   $D2          Driver ID (returns info on current driver)

* SetStat calls unique to s16550 (move to main defs later)
SS.TxF1R equ   $C2          Clear trasmitter software flow control
SS.TxFlh equ   $C3          Flushes (discards) transmit buffer contents


* NOTE: Will move this to separate .d later, like Jeff did, but keeping handy in main source
* for now to reference faster
********************
* Register offset definitions. Courtesy Jeff Teunissen, and seem to match
* Rick Ulland/Randy Wilson's hardware / software as well.
*
* If DLAB=1:
LDiv	equ	0	Low byte of divisor Latch (DLAB=1)
HDiv	equ	1	High byte of divisor Latch (DLAB=1)

* If DLAB=0:
DataRW	equ	0	Data register (RW) (DLAB=0)
IrEn	equ	1	Interrupt Enable register (RW) (DLAB=0)
IStat	equ	2	Interrupt status register (R)
FCtrl	equ	2	FIFO control register (W)
LCtrl	equ	3	Line control register (RW)
MCtrl	equ	4	Modem control register (RW)
LStat	equ	5	Line status register (R)
MStat	equ	6	Modem status register (R)
SPR	equ	7	Scratchpad register (RW)

* IrEn Interrupt Enable Register bit positions
ERBFI	equ	%00000001	Enable Receive Data Avail Intr.
ETEMT	equ	%00000010	Enable Transmitter Empty Intr.
ELSI	equ	%00000100	Enable Receiver Line Status Intr.
EMSI	equ	%00001000	Enable Modem Status Intr.

* IStat Interrupt Status Register bit positions
IrPend	equ	%00000001	Interrupt pending if 0
IrId	equ	%00001110	Interrupt Identification bits
*	The above three bits can have the following values
IrRcvTO equ %00001100 Received Data Timeout
IrLStat	equ	%00000110	Receiver Line Status change
IrRcvAv	equ	%00000100	Receive Data Available
IrTEMT	equ	%00000010	Transmitter Empty
IrMStat	equ	%00000000	Modem Status change

* FCtrl FIFO Control Register bit positions
FCEn	equ	%00000001	FIFO Enable (1=enable, req'd to set any bits)
FCRR	equ	%00000010	RX FIFO reset (1=clear RX fifo)
FCTR	equ	%00000100	TX FIFO reset (1=clear TX fifo)
FDMA	equ	%00001000	DMA Mode Select
FRT	equ	%11000000	RX trigger levels
*	Values for above FIFO RX Trigger bits
FRT1	equ	%00000000	RX Trigger @ 1 byte
FRT4	equ	%01000000	RX Trigger @ 4 bytes
FRT8	equ	%10000000	RX Trigger @ 8 bytes
FRT14	equ	%11000000	RX Trigger @ 14 bytes

* LCtrl Line Control Register bit positions
WLS	equ	%00000011	Word Length Select bits
*	Values for above Word Length Select bits
WLS5	equ	%00000000	5 bit Word Length 
WLS6	equ	%00000001	6 bit Word Length 
WLS7	equ	%00000010	7 bit Word Length 
WLS8	equ	%00000011	8 bit Word Length 
STB	equ	%00000100	# of Stop bits (0=1 bit, 1=1.5 or 2 bits)
PAR	equ	%00111000	Parity Select bits
*	Values for above Parity Select bits
PARN	equ	%00000000	No Parity
PARO	equ	%00001000	Odd Parity
PARE	equ	%00011000	Even Parity
PARM	equ	%00101000	Mark Parity
PARS	equ	%00111000	Space Parity
SBRK	equ	%01000000	Set Break Bit (1=Break level)
DLAB	equ	%10000000	Divisor Latch Access Bit (DLAB)

* MCtrl Modem Control Register bit positions 
DTR	equ	%00000001	Data Terminal Ready bit
RTS	equ	%00000010	Request to Send bit
OUT1	equ	%00000100	Output 1 
OUT2	equ	%00001000	Output 2
*	OUT2 is commonly used in PC Modems to enable interrupts
LOOP	equ	%00010000	Loopback Mode Bit
ACTS	equ	%00100000	Auto CTS flow control enable
ACTSRTS equ	%00100010	Automatic CTS/RTS	

* LStat Line Status Register bit positions
DR	equ	%00000001	Data Ready
OE	equ	%00000010	Overrun Error
PE	equ	%00000100	Parity Error
FE	equ	%00001000	Framing Error
BI	equ	%00010000	Break Interrupt
THRE	equ	%00100000	Transmitter Holding Register Empty
TEMT	equ	%01000000	Transmitter Empty
FDE	equ	%10000000	FIFO data error

OE_B	equ	1		Overrun Error bit position
PE_B	equ	2		Parity Error bit position
FE_B	equ	3		Framing Error bit position
FDE_B	equ	7		FIFO Data Error bit position

* MStat Modem Status Register bit positions
DCTS	equ	%00000001	Delta CTS
DDSR	equ	%00000010	Delta DSR
TERI	equ	%00000100	Trailing Edge Ring Indicator
DRDCD	equ	%00001000	Delta Receive Data Carrier Detect (DCD)
CTS	equ	%00010000	Clear To Send (CTS)
DSR	equ	%00100000	Data Set Ready (DSR)
RI	equ	%01000000	Ring Indicator (RI)
RDCD	equ	%10000000	Receive Data Carrier Detect (DCD)

tylg     set   Drivr+Objct   
atrv     set   ReEnt+rev
rev      set   $01

         mod   eom,name,tylg,atrv,start,size

* Static mem storage: NOTE: Reassigns to DP for faster access in all driver branch routines
* Based on Bruce Isted's XACIA, although with some changes
         org   V.SCF        Allow for SCF manager data rea
Wrk.Type rmb   1            Copy of parity settings from desc. (IT.PAR) \ Must be
Wrk.Baud rmb   1            Copy of baud rate from desc. (IT.BAU)       / Together
AltBauFl rmb   1            Alternate baud rate table flag (0=normal) Use for older comm programs with new baud rates
u0020    rmb   1
u0021    rmb   1
u0022    rmb   1
u0023    rmb   2
u0025    rmb   2
u0027    rmb   1            Signal code (for send)
u0028    rmb   1
u0029    rmb   1
u002A    rmb   2
u002C    rmb   2
u002E    rmb   2
u0030    rmb   2  
u0032    rmb   2            V.BUFADR
u0034    rmb   1            Receive buffer - current # of bytes in it
u0035    rmb   1
u0036    rmb   2            V.BUFSIZ (# of extra bytes we reserved in static mem >256 SCF gave us)
u0038    rmb   2            Transmit buffer ptr
u003A    rmb   1
u003B    rmb   1
u003C    rmb   2
u003E    rmb   2
u0040    rmb   1
u0041    rmb   2            Size of transmit buffer
u0043    rmb   1
u0044    rmb   188          transmit buffer
u0100    equ   .
size     equ   .

         fcb   $03

name     fcs   /sc16550/

edition  fcb   12

         ifne  CoCo
L0015    fcb   MPI.Slot     Default MPI slot #3 (change to use descriptor later)
         endc
         
start    lbra  Init         Init
         lbra  Read         Read
         lbra  Write        Write
         lbra  GetStat      GetStat
         lbra  SetStat      SetStat
         lbra  Term         Term

* Entry: Y=ptr to device descriptor
*        U=Ptr to device mem area
* Will allocate extra buffer memory if requested in lower 4 bits of XTP byte in device descriptor
*   and there is enough free system mem to do so
Init     clrb               Default to no error
         pshs  dp,b,cc
         lbsr  L0458        Point DP to first 256 bytes of Device mem area
         ldd   <V.PORT      Get ptr to 16550 hardware base address
         addd  #IStat       Point to 16550 Status register
         pshs  y            Save ptr to device descriptor
         leax  >L0675,pcr   Point to 5 byte IRQ packet settings
         leay  >L046D,pcr   Point to IRQ service routine
         os9   F$IRQ        Install ourselves in IRQ polling table
         puls  y            Get device descriptor ptr back
         bcc   L004A        No error installing IRQ, continue
         puls  a,cc         Error, restore regs
         orcc  #$01         Flag error (error code still in B)
         puls  pc,dp        Restore DP & return with error

* Adding ourselves into IRQ polling table work, continue
L004A    lda   <M$Opt,y     Get # of option bytes in descriptor
         cmpa  #IT.XTYP-IT.DTP  ($1C) Is there an Extended Type byte in descriptor?
         bls   L005F        No, skip ahead (and default to one 256 byte buffer page)
         lda   <IT.XTYP,y   Yes, get Extended type byte
         anda  #%00010000   Alternate baud rate table flag only
         sta   <AltBauFl    Save alternate baud table on/off flag
         lda   <IT.XTYP,y   Get extended type byte back
         anda  #%0001111    Keep # of 256 byte buffer pages to use for receive buffer
         bne   L0061        >0, yes, allocate that many
L005F    lda   #$01         Otherwise default to $100 (256) byte buffer page
L0061    clrb
         pshs  u            Save U
         os9   F$SRqMem     Request # of page buffer pages (256 bytes/page from *SYSTEM* RAM)
         tfr   u,x          Move ptr to newly allocated system RAM to X
         puls  u            Restore device mem ptr
         bcc   L007A        We got the memory, continue
         stb   1,s          Couldn't get, save error code into B on stack
         ldx   #$0000       Remove device from IRQ polling table
         os9   F$IRQ        
         puls  dp,b,cc      Restore regs & error #
         orcc  #$01         Return with error
         rts

L007A    stx   <u0032       Save ptr to start of receive buffer
         stx   <u002C       ? Active start ptr?
         stx   <u002E       ? Active end ptr?
         std   <u0036       Save size of receive buffer
         leax  d,x          Point to end of receive buffer
         stx   <u0030       Save end of received buffer ptr 
         tfr   a,b          Move # of 256 byte receive pages to B 
         clra
         orb   #%00000010   $02 ? Force to multiples of 512 bytes
         andb  #%00001110   $0E ? # of 512 byte pages
         lslb               ??? This will always shift out to 0, won't it, since max #pages=15?
         lslb
         lslb
         lslb
         tstb
         bpl   L0096
         ldb   #$80
L0096    pshs  d
         ldd   <u0036       Get size of receive buffer
         subd  ,s++         Subtract ?
         std   <u002A       Save it
         leax  <u0044,u     Point to transmit buffer
         stx   <u003E       Save transmit buffer ptr
         stx   <u0038       ? Save active transmit buffer start ptr?
         stx   <u003A       ? Save active transmit buffer end ptr?
         leax  >u0100,u     Point to end of transmit buffer
         stx   <u003C       Save end of transmit buffer ptr
         ldd   #size-u0044  Size of transmit buffer
         std   <u0041       Save it
         clr   <u0034       (RxBufSiz) Clear Receive buffer size (16 bit) 
         clr   <u0035       (RxBufSiz+1)
         clr   <u0040       Clear transmit buffer size
         ldd   <IT.PAR,y    Get parity & baud rate settings from device descriptor
         std   <Wrk.Type    Save copies in device mem
         lbsr  L0284        Set some stuff up based on the data table at end of driver
         ldx   <V.PORT      Get ptr to 16550 hardware
         lda   LStat,x      5,x - Get Line Status register
         lda   ,x           Get Data register
* Why are reading both into same register?
         lda   LStat,x      5,x - Get Line Status register again
         lda   MStat,x      6,x - Get Modem Status register
         anda  #RDCD+DSR+CTS  $B0 Only keep Receive Data Carrier Detect, Data Set Ready & Clear to Send bits
         sta   <u0020       Save them
         clrb               Clear our "results" register - all 3 of the above off
         bita  #CTS         $10 Is CTS bit set?
         bne   L00D5        No, skip ahead
         orb   #%00000010   $02  Yes, add that bit flag
L00D5    bita  #DSR         $20 Is DSR bit set?
         bne   L00DB        Yes, skip ahead
         orb   #%00000001   $01 No, add that bit flag
L00DB    stb   <u0028       Save flags
         ifne   CoCo
         orcc  #IntMasks    IRQ's off
         lda   >L0015,pcr   Get MPI slot # (should change to come from descriptor)
         bmi   L00E8        Hi bit set=Not using MPI Slot select
         sta   >MPI.Slct    $FF7F  Set MPI Slot #
L00E8    lda   >$FF23       Get control register B from PIA1
         anda  #%11111100   $FC Clear FIRQ polarity to falling edge, disable CART FIRQ
         sta   >$FF23       Save back to control register B on PIA1
         lda   >$FF22       Read PIA1 B side Data register (eat any byte present for read)
         lda   >D.IRQER     $0092 Get copy of GIME IRQ enable register
         ora   #$01         Enable cartridge IRQ
         sta   >$0092       Save OS9's copy
         sta   >$FF92       And to actual GIME itself
         endc
         ifne  f256
* Turn on interrupt controller's interrupt for the UART         
         lda   INT_MASK_1
         anda  #~INT_UART
         sta   INT_MASK_1
         endc
         puls  pc,dp,b,cc   Restore regs, reenable IRQ's & return

* Write
* Entry: A=char to write
Write    clrb
         pshs  dp,b,cc
         lbsr  L0458        Point DP to first 256 bytes of Device mem area
         ldx   <u0038       Get ptr to next empty spot in our transmit buffer
         sta   ,x+          Append the character
         cmpx  <u003C       Have we hit physical end of transmit buffer?
         blo   L0110        No, skip ahead
         ldx   <u003E       Yes, point to physical start of transmit buffer
L0110    orcc  #IntMasks    IRQ's off
         cmpx  <u003A       Have we caught up with beginning in wraparound buffer?
         bne   L012B        No, skip ahead
         pshs  x            Yes, save ptr
         lbsr  L0442        Suspend current process
         puls  x            Get ptr back
         ldu   >D.Proc      Get ptr to current process dsc
         ldb   <P$Signal,u  Get any current signal code
* 6809/6309 - change to beq L0110
         beq   L0129        None, go back
         cmpb  #S$Intrpt    Is it a Keyboard Interrupt,Abort or Wake signal?
         bls   L0131        Yes, restore regs & return
L0129    bra   L0110        No, loop back

L012B    stx   <u0038       Save updated ptr to next free spot in transmit buffer
         inc   <u0040       Increase # of bytes in driver's transmit buffer
         bsr   L0133        Enable all IRQ's on 16550 *including* transmitter empty IRQ
L0131    puls  pc,dp,b,cc

* Enable all 4 16550 IRQ sources
L0133    lda   #EMSI+ELSI+ETEMT+ERBFI $0F Enable Modem Status, Receiver Line Status, Transmitter Empty & Receive Data Available interrupts on 16550
         bra   L0139

* Enable all 16550 IRQ soures *except* transmitter empty
L0137    lda   #EMSI+ELSI+ERBFI  $0D Enable Modem Status, Receiver Line Status & Receive Data Available interrupts on 16550
L0139    ldx   <V.PORT      Get ptr to 16550
         sta   IrEn,x       1,x  Set Interrupt enable register
         rts

* Read
Read     clrb
         pshs  dp,b,cc
         lbsr  L0458        Point DP to first 256 bytes of Device mem area
         orcc  #IntMasks    Shut IRQ's off
         ldd   <u0034       Get # of bytes in receive buffer
         beq   L015C        None, skip ahead
         cmpd  #16          16 bytes ready?
         lbne  L0182        No, skip ahead
         andcc #^IntMasks   IRQ's on
         bsr   L01B0
L0156    orcc  #IntMasks    IRQ's off
         ldd   <u0034
         bne   L0182
L015C    lbsr  L0442        Suspend current process
         ldx   >$0050
         ldb   <$19,x
         beq   L016B
         cmpb  #$03
         bls   L017D
L016B    ldb   $0C,x
         andb  #$02
         bne   L017D
         ldb   <V.ERR       Get error accumulator
         bne   L0199        Was an error, skip ahead
         ldb   <V.WAKE      Get process # to wake up when I/O done
         beq   L0156        None, go back
         orcc  #IntMasks    IRQ's off
         bra   L015C

L017D    puls  dp,a,cc      Exit with error
         orcc  #$01
         rts

L0182    subd  #$0001
         std   <u0034
         ldx   <u002E
         lda   ,x+
         cmpx  <u0030
         bne   L0191
         ldx   <u0032
L0191    stx   <u002E
         andcc #^IntMasks   IRQ's on
         ldb   <V.ERR       Get error accumulator
         beq   L01AE        No errors, restore regs & return
L0199    stb   <$3A,y       Save error accumulator to ???
         clr   <V.ERR       Clear out error accumulator
         puls  dp,a,cc      Restore regs
         bitb  #$20         ? Check if carrier lost?
         beq   L01A9        Yes, exit with CD lost/modem hangup error
         ldb   #E$Read      No, exit with Read error
         orcc  #$01
         rts

L01A9    ldb   #E$HangUp    Exit with CD lost error
         orcc  #$01
         rts

L01AE    puls  pc,dp,b,cc

L01B0    pshs  cc           Save CC (use to restore interrupts)
         ldx   <V.PORT      Get ptr to 16550 hardware
         ldb   <u0028       Get flag bits based on Modem Status
         bitb  #%01110000   $70 ???
         beq   L01CC        If none of the 3 bits are set, turn IRQ's back on & return
         bitb  #%00100000   $20 If bit 5 alone set?
         beq   L01CE        No, skip ahead
         orcc  #IntMasks    Yes, shut IRQ's off
* 6309 - aim #$DF,<u0028
         ldb   <u0028       Get flag bytes back (LCB NOTE: WE STILL HAVE THEM IN B, WHY ARE WE RELOADING?)
         andb  #%11011111   $DF Clear bit 5
         stb   <u0028       Save flags back
* 6309 - oim #RTS,MCtrl,x
         lda   MCtrl,x      4,x - Get modem control register
         ora   #RTS         $02 Set RTS (Request to send) bit
         sta   MCtrl,x      4,x - Save modified modem control register back
L01CC    puls  pc,cc        Turn IRQ's back on & return

L01CE    bitb  #%00010000   $10 bit 4 set?
         beq   L01E2        No, skip ahead
         orcc  #IntMasks    Shut off IRQ's
* 6309 - aim #$EF,<u0028
         ldb   <u0028       Get flags
         andb  #%11101111   $EF Clear bit 4
         stb   <u0028       And write it back
* 6309 - oim #
         lda   MCtrl,x      4,x Get Modem control register
         ora   #DTR         $01 Set DTR (Data Terminal Ready) bit
         sta   MCtrl,x      And write back to 16550
* 6809/6309 - replace with puls pc,cc (same size, 3 cyc faster)
         bra   L01CC        Turn IRQ's back on & return

L01E2    bitb  #%01000000   $40 Bit 6 set?
         beq   L01CC        No, turn IRQ's back on and return
         ldb   <V.XON       Yes, Get XON char
         orcc  #IntMasks    IRQ's off
         stb   <u0043       Save XON char there
         lbsr  L0133        Enable ALL 4 IRQ's on 16550 (including transmit)
* 6309 aim #$BF,<u0028
         ldb   <u0028       Get flags byte again
         andb  #%10111111   $BF Clear bit 6
         stb   <u0028       And write it back
* 6809/6309 - replace with puls pc,cc (same size, 3 cyc faster)
         bra   L01CC        Turn IRQ's back on & return

* GetStat
* Entry: A=GetStat code
*        Y=Path Dsc ptr
GetStat  clrb  
         pshs  dp,b,cc
         lbsr  L0458        Point DP to first 256 bytes of Device mem area
         cmpa  #SS.Ready    Data ready call?
         bne   L0219        No, check next
         ldd   <u0034       Yes, any data ready in driver's receive buffer?
         beq   L0211        No, return with Device not Ready error
         tsta               >255 bytes ready?
         beq   L020A        No, use amount we have
         ldb   #$FF         Yes, return 255 bytes ready to caller (only 8 bits allowed)
L020A    ldx   PD.RGS,y     Get caller's stack ptr
         stb   R$B,x        Save # bytes available to read in caller's B register
* 6809/6309 - replace with puls  pc,dp,b,cc (1 byte smaller, 4 or 5 cycles faster)
         lbra  L0282        Restore regs & return

L0211    puls  b,cc         Return to caller with Device Not Ready error (no data in receive buffer) 
         orcc  #$01
         ldb   #E$NotRdy
         puls  pc,dp

L0219    cmpa  #SS.ComSt    Return serial port configuaration?
         bne   L0241        No, check next
         ldd   <Wrk.Type    Get Parity and Baud settings from device mem (was <u0039 in XACIA)
         tst   <AltBauFl    Is alternate baud table in use?
         beq   L0229        No, leave as is
         bitb  #$04         Yes, if >=2400 baud, values stay the same 
         bne   L0229
         andb  #%11110111   $F7 Force to fit original 3 bit spec (this covers 38400,57600,76800,115200)
L0229    ldx   PD.RGS,y     Get callers register stack ptr from path descriptor
         std   R$Y,x        $06 Save Parity & Baud bytes back to caller in Y
         clrb               Clear reg B return value
         lda   <u0020       Get current DCD, DSR & CTS bit flags from copy of Modem Status register
         bita  #RDCD        $80 Is Carrier Detect enabled?
         bne   L0236        No, skip ahead
         orb   #$10         Yes, set DCD status in bit 5 (for compatibility with older drivers) in reg B
L0236    bita  #DSR         $20 Is Data Set Ready enabled?
         bne   L023C        No, done with B
         orb   #$40         Yes, set DSR status in bit 6 (for compatibility with older drivers) in reg B
L023C    stb   R$B,x        Save special CD/DSR status byte in caller's B
* 6809/6309 - replace with puls  pc,dp,b,cc (1 byte smaller, 4 or 5 cycles faster)
         bra  L0282        Restore regs & return

L0241    cmpa  #SS.EOF      End of File check?
         bne   L0249        No, check next
         clrb               Yes, exit without error
* 6809/6309 - replace with puls  pc,dp,b,cc (1 byte smaller, 4 or 5 cycles faster)
         bra  L0282        Restore regs & return

L0249    cmpa  #SS.DvrID    $D2 Return Driver ID info?
         bne   L0261        No, check next
         ldd   #$0B04       Driver max baud rate is $B (115200 currently), driver/chip type=4 (16550)
         ldy   PD.RGS,y     Get callers register stack ptr from path descriptor
         std   R$D,y        Save max baud & driver/chip types back to caller's D
* The "large" versions should return bits 8,9,10 set as well (SS.BlkRd, SS.BlkWr, SS.TxFlh supported)
         ldd   #$0007       Return that driver supports: SS.Hangup, SS.Break, and signal on CD change
         std   R$X,y        Return which options beyond original ACIAPAK are supported (S/DACIA should be changed
*                            to support this as well) in callers X
         ldd   #$0001       Driver ID#=1 for s16550
         std   R$Y,y        Sae in callers Y
* 6809/6309 - replace with puls  pc,dp,b,cc (1 byte smaller, 4 or 5 cycles faster)
         bra  L0282        Restore regs & return

L0261    cmpa  #SS.ScSiz    Screen size?
         bne   L027A        No, return with Unknown Service Request error
         ldx   PD.RGS,y     Get callers register stack ptr from path descriptor
         ldy   PD.DEV,y     Get ptr to our device's table entry address
         ldy   V$DESC,y     Get ptr to device descriptor itself
         clra               Clear high byte of X,Y sizes)
         ldb   <IT.COL,y    Get # of columns (X size) from descriptor
         std   R$X,x        Save in callers X
         ldb   <IT.ROW,y    Get # of rows (Y size) from descriptor
         std   R$Y,x        Save in callers Y
* 6809/6309 - replace with puls  pc,dp,b,cc (1 byte smaller, 4 or 5 cycles faster)
         bra  L0282        Restore regs & return

L027A    puls  b,cc
         orcc  #$01
         ldb   #E$UnkSvc    Exit with Unknown Service Request error
         puls  pc,dp

* 6809/6309 - Once we change lbra/bra to L0282's to actual puls, this line can be removed
L0282    puls  pc,dp,b,cc

* Entry: B=IT.BAU value from descriptor
L0284    pshs  u            Save U
         tfr   b,a          Dupe baud rate into A
         leau  >L0678,pcr   Point to data table (I think last byte is FIFO Size?)
         ldx   <V.PORT      Get hardware address of 16550
         andb  #$0F         16 entries only in table (max # of baud rates?)
         lslb               4 bytes/entry
         lslb  
         leau  b,u          U=Ptr to entry we want (based on baud rate bits)
         lsra               Shift Stop bits & word length to lowest 3 bits
         lsra  
         lsra  
         lsra  
         lsra  
         eora  #WLS         $03 Invert word length bits
         anda  #WLS         $03 Only keep word length (now set up for least 2 sig bits on LCtrl on 16550)
         pshs  a,cc         Save that and CC
         lda   <Wrk.Type    Get work copy of parity settings
         lsra               Shift out CTS/RTS & DSR/DTR bits
         lsra  
         anda  #PAR         $38 Only keep the 3 parity bits (in right position for LCtrl on 16550)
         ora   1,s          Merge in the word length bits (lowest 2)
         sta   1,s          Save new copy on stack
         ora   #DLAB        $80 Turn on DLAB (Divisor Latch Access bit)
         orcc  #IntMasks    Shut IRQ's off
         sta   LCtrl,x      $03 Set word length & parity, and switch DLAB to 1 (so we can program baud rate)
         ldd   ,u++         Get Divisor Latch value
* Could just change table to have these pre-swapped
         exg   a,b          16550 needs little endian, so swap bytes
         std   ,x           Save LDiv/HDiv (16 bit Divisor Latch) into 16550
         lda   1,s          Get word length/parity byte back
         sta   LCtrl,x      $03 Save onto Line control, but with divisor latch OFF
         ldd   ,u           Get FCtrl register settings & # bytes / receive IRQ from table
         sta   <u0021       Save 1st byte in device static mem
         ora   #FCRR+FCTR   $06 Reset Receive & Transmit FIFO's (clears them)
         sta   FCtrl,x      $02  Send to FIFO control register
         stb   <u0029       Save FIFO size (1,4,8,14) as init counter for receive interrupts
         puls  pc,u,a,cc

* SetStat
SetStat    clrb  
         pshs  dp,b,cc
         lbsr  L0458        Point DP to first 256 bytes of Device mem area
         cmpa  #$28
         bne   L02FC
         ldy   $06,y
         ldd   $06,y
         tst   <AltBauFl
         beq   L02DE
         bitb  #$04
         bne   L02DE
         orb   #$08
L02DE    std   <Wrk.Type
         lbsr  L0284
         clr   <u0022
         tst   <V.QUIT      Is there a keyboard Abort/Quit character defined?
         bne   L02F9        Yes, skip ahead
         tst   <V.INTR      Is there a keyboard interrupt character defined?
         bne   L02F9        Yes, skip ahead
         tst   <V.PCHR      Is there a pause character set?
         bne   L02F9        Yes, skip ahead
         ldb   <Wrk.Type
         bitb  #$04
         bne   L02F9
         inc   <u0022
L02F9    lbra  L03E9

L02FC    cmpa  #$2B
         bne   L0317
         ldx   <V.PORT      Get ptr to 16550
         lda   $04,x
         pshs  x,a
         anda  #$FE
         sta   $04,x
         ldx   #30          Sleep 1/2 a secodnd
         os9   F$Sleep
         puls  x,a
         sta   $04,x
         lbra  L03E9

L0317    cmpa  #$1D
         bne   L0367
         orcc  #IntMasks
         ldx   <V.PORT      Get ptr to 16550
         lda   <u0028
         ora   #$08
         sta   <u0028
         lda   #$0D
         sta   $01,x
         clr   <u0040
         ldd   <u003E
         std   <u003A
         std   <u0038
         lda   <u0021
         ora   #$04
         sta   $02,x
         clra
         sta   ,x
L033A    lda   $05,x
         anda  #$40
         bne   L034C
         andcc #^IntMasks
         ldx   #$0001
         os9   F$Sleep      Sleep for remainder of clock tick
         ldx   <V.PORT      Get ptr to 16550
         bra   L033A

L034C    lda   $03,x
         ora   #$40
         sta   $03,x
         ldx   #30          Sleep for 1/2 a second
         os9   F$Sleep
         ldx   <V.PORT      Get ptr to 16550
         anda  #$BF
         sta   $03,x
         lda   <u0028
         anda  #$F7
         sta   <u0028
         lbra  L03E9

L0367    cmpa  #$1A
         bne   L0384
         lda   $05,y
         ldy   $06,y
         ldb   $05,y
         orcc  #$50
         ldx   <u0034
         bne   L037D
         std   <u0025
         lbra  L03E9

L037D    puls  cc
         os9   F$Send       Send signal
         puls  pc,dp,b

L0384    cmpa  #$1B
         bne   L0395
         lda   $05,y
         cmpa  <u0025
         bne   L0392
         clra
         clrb
         std   <u0025
L0392    lbra  L03E9

L0395    cmpa  #$9A
         bne   L03A4
         lda   $05,y
         ldy   $06,y
         ldb   $05,y
         std   <u0023
         bra   L03E9
L03A4    cmpa  #$9B
         bne   L03B6
         orcc  #IntMasks
         lda   $05,y
         cmpa  <u0023
         bne   L03B4
         clra
         clrb
         std   <u0023
L03B4    bra   L03E9

L03B6    cmpa  #$2A
         lbne  L03D1
         orcc  #IntMasks
         lda   $05,y
         ldx   #$0000
         cmpa  <u0025
         bne   L03C9
         stx   <u0025
L03C9    cmpa  <u0023
         bne   L03CF
         stx   <u0023
L03CF    bra   L03E9

L03D1    cmpa  #$29
         bne   L03E1
         ldx   <V.PORT      Get ptr to 16550
         lda   #$03
         sta   $04,x
         ldb   #$0F
         stb   $01,x
         bra   L03E9

L03E1    puls  b,cc
         orcc  #$01
         ldb   #E$UnkSvc    Exit with Unknown Service Error
         puls  pc,dp

L03E9    puls  pc,dp,b,cc

* Term
Term     clrb
         pshs  dp,b,cc
         lbsr  L0458        Point DP to first 256 bytes of Device mem area
         orcc  #IntMasks    Shut IRQ's off
         clra  
         clrb  
         std   <u0034       Clear receive buffer size to 0
         ldx   <u0032
         stx   <u002C
         stx   <u002E
         pshs  x,d          Save receive buffer size (0) and ? Buffer ptr
         ldb   4,s
         tfr   b,cc
         ldx   >D.Proc      Get current process ptr
         lda   ,x           P$ID Get process ID # for current process
         sta   <V.BUSY      Set device as busy with current process #
         sta   <V.LPRC      Save as last active process #
L040C    orcc  #IntMasks    Shut IRQ's off
         tst   <u0040
         bne   L041C
         ldx   <V.PORT      Get ptr to 16550
         ldb   LStat,x      Get line status register
         eorb  #THRE        ($20) Invert Transmitter holding register empty bit flag
         andb  #THRE        ($20) And only keep that bit
         beq   L042B        Transmit is empty, skip ahead
L041C    orcc  #IntMasks    No empty, shut IRQ's off
         lbsr  L0442        Suspend current process
         ldd   2,s          Get ? buffer ptr
         std   <u002C       Save in static mem
         ldd   ,s           Get receive buffer size
         std   <u0034       Save it into static mem
         bra   L040C        Keep going until transmit buffer is empty

* transmitter holding register on 16550 is empty
L042B    leas  4,s          Eat temp stack
         clr   IrEn,x       1,x - Disable 16550 Interrupt enable
         clr   MCtrl,x      4,x - Clear Modem control register on 16550
         andcc #^IntMasks   Turn IRQ's back on
         ldd   <u0036       Get # of bytes to return to system
         ldu   <u0032       Get ptr to start page address to return RAM to system
         os9   F$SRtMem     Return the RAM to the system
         ldx   #$0000       Flag to remove device from IRQ polling table
         os9   F$IRQ    
         puls  pc,dp,b,cc

* Suspend current process
         ifgt  Level-1
L0442    ldx   >D.Proc      Get current process ptr
         lda   P$ID,x       Get process status
         sta   <V.WAKE      Save process # as one to wake up upon I/O completion
         lda   P$State,x    Get process status
         ora   #Suspend     Set Suspend state
         sta   P$State,x    And save it back
         andcc #^IntMasks   IRQ's on
         ldx   #$0001       Sleep remainder of current time slice
         os9   F$Sleep  
         rts   
         else
L0442    ldx   >D.Proc      Get current process ptr
         lda   P$ID,x
         sta   <V.WAKE      Save process # as one to wake up upon I/O completion
         ldx   #$0001       Sleep remainder of current time slice
         os9   F$Sleep  
         rts   
         endc
         
* Set DP to point to start of device mem (pointed to by U)
L0458    pshs  u            Save our device mem ptr on stack
         puls  dp           Get high byte of device mem ptr into DP
         leas  1,s          Eat low byte (don't need it) & return
         rts   

* Branch table used in L0489. Based on IRQ type received from 16550
L045F    fdb   L05F2-L0492  $0160  %000x IrMStar Modem Status Register change IRQ
         fdb   L05A7-L0492  $0115  %001x IrTEMT Transmitter holding register empty IRQ
         fdb   L04AD-L0492  $001b  %010x IrRcvAv Received Data Ready IRQ
         fdb   L064D-L0492  $01bb  %011x IrLStat Receiver Line Status change IRQ
         fdb   L0496-L0492  $0004  %100x Unused IRQ - try re-reading 16550 IRQ, or unsuspend caller
         fdb   L0496-L0492  $0004  %101x Unused IRQ - try re-reading 16550 IRQ, or unsuspend caller
         fdb   L04BC-L0492  $002a  %110x Received Data Timeout IRQ

* IRQ Service routine
L046D    clrb
         pshs  dp,b,cc
         bsr   L0458        Set DP to start of device mem
         clr   <u0027       ???
         ldy   <V.PORT      Get ptr to 16550
         ldb   IStat,y      $02 Get Interrupt status register
         bitb  #IrPend      $01 Is an interrupt pending?
         beq   L0489        Yes, skip ahead
         tfr   a,b          No, 
         andb  #%00001110   $0E Strip the IRQ Pending bit
         bne   L0489        If any of the 3 bits are set, call 16550 IRQ dispatch table
         puls  cc           All clear, we likely were called in error, return carry set to IOMAN
         orcc  #$01           so that it can continue through the IRQ polling table looking for source
         puls  pc,dp

* Entry: B=16550 Interrupt status register (lowest 4 bits only are used)
* Exit - calls routine based on table entry
L0489    leax  >L045F,pcr   Point to table
         andb  #%00001110   $0E Keep IRQ identification bits only (also makes 2 byte entries)
         abx                X=ptr to entry we need
         tfr   pc,d         Save our current exec address (L0492) to D
L0492    addd  ,x           Add table offset
         tfr   d,pc         Jump to routine

* Unknown IRQ from 16550 - try 2nd time, wake process if no IRQ waiting, or dispatch again if
*    there is
* Entry: Y=ptr to 16550 hardware
L0496    ldb   IStat,y      $02 Get Interrupt status register
         bitb  #IrPend      $01 IRQ pending on 16550?
         beq   L0489        Yes, dispatch to appropriate IRQ service routine
         lda   <V.WAKE      No, Get process # to wake up
         beq   L04AB        None waiting, return
         ifgt  Level-1
         clrb  
         stb   <V.WAKE      Clear process # to wake
         tfr   d,x          X=process dsc. ptr to wake
* 6309 aim #^Suspend,P$State,x
         lda   P$State,x    Get process status 
         anda  #^Suspend    Unsuspend process
         sta   P$State,x    And save that back
         else 
         ldb   <V.Wake
         lda   #S$Wake
         os9   F$Send
         endc
L04AB    puls  pc,dp,b,cc

* Received data ready IRQ from 16550 handler
* Entry: Y=ptr to 16550 hardware
L04AD    ldx   <u002C       Get ptr to where next received byte will go
         lda   LStat,y      $05 Get Line Status register from 16550
         bmi   L04C0        If FDE bit set (FIFO Data error), skip ahead
         ldb   <u0029       Get # of bytes we are expecting to get with each Rcv IRQ from 16550
L04B5    bsr   L04E6
         decb  
         bne   L04B5
         bra   L04BE

L04BC    ldx   <u002C
L04BE    lda   $05,y
L04C0    bita  #$1E
         beq   L04C9
         lbsr  L0654
         bra   L04BE

L04C9    bita  #$01
         beq   L04D1
L04CD    bsr   L04E6
         bra   L04BE

L04D1    tst   <u0027
         bne   L04E2
         ldd   <u0025
         beq   L04E2
         stb   <u0027
         os9   F$Send   
         clra  
         clrb  
         std   <u0025
L04E2    stx   <u002C
         bra   L0496

* B=# bytes expected per Receive IRQ
* Y=16550 base address
* X=Ptr in receive buffer to put next char
L04E6    lda   ,y           Get character from Data register on 16550
         beq   L050E        NUL, append to buffer
         tst   <u0022       ???
         bne   L050E        If set, append char to buffer
         cmpa  <V.QUIT      Was it Keyboard Abort/Quit key? (CTRL-E usually)
         bne   L04F7        No, check next
         lda   #S$Abort     Yes, send Keyboard Abort signal
         lbra  L0592

L04F7    cmpa  <V.INTR      Was it a Keyboard Interrupt signal? (CTRL-C usually)
         bne   L0500        No, check next
         lda   #S$Intrpt    Yes, send Keyboard Interrupt signal
         lbra  L0592

L0500    cmpa  <V.XON       Was it Transmit On char?
         beq   L0578        yes, go do
         cmpa  <V.XOFF      Was it Transmit Off char?
         beq   L0587        yes, go do
         cmpa  <V.PCHR      Was it the pause character?
         lbeq  L059F        Yes, skip ahead
L050E    pshs  b            Save current FIFO bytes left counter
         sta   ,x+          Save char into receive buffer
         cmpx  <u0030
         bne   L0518
         ldx   <u0032
L0518    cmpx  <u002E
         bne   L052C
         ldb   #%00000010   $02 Set 2nd bit in error accumulator
         orb   <V.ERR       Merge with current error accumulator
         stb   <V.ERR       And save it back
         cmpx  <u0032
         bne   L0528
         ldx   <u0030
L0528    leax  -1,x
         bra   L053A

L052C    stx   <u002C
         ldd   <u0034
         addd  #$0001
         std   <u0034
         cmpd  <u002A
         beq   L053C
L053A    puls  pc,b

L053C    ldb   <u0028
         bitb  #$70
         bne   L053A
         lda   <Wrk.Type
         bita  #$02
         beq   L0554
         orb   #$20
         stb   <u0028
         lda   $04,y
         anda  #$FD
         sta   $04,y
         bra   L053A

L0554    bita  #$01
         beq   L0564
         orb   #$10
         stb   <u0028
         lda   $04,y
         anda  #$FE
         sta   $04,y
         bra   L053A

L0564    bita  #$08
         beq   L053A
         orb   #$40
         stb   <u0028
         lda   <V.XOFF      Get Transmit OFF char
         beq   L053A        None, restore B & return
         sta   <u0043
         ldb   #$0F
         stb   $01,y
         bra   L053A

* XON char read
L0578    lda   <u0028
         anda  #$FB
         sta   <u0028
         tst   <u0040
         beq   L0586
         lda   #$0F
         sta   $01,y
L0586    rts   

* XOFF char read
L0587    lda   <u0028
         ora   #$04
         sta   <u0028
         lda   #$0D
         sta   $01,y
         rts   

* Send Signal to last process waiting on current device
* Entry: A=Signal code to send
L0592    pshs  b            Save B
         tfr   a,b          Move signal code to B
         lda   <V.LPRC      Get process # of last process using device
         stb   <u0027       Save signal code
         os9   F$Send       Send signal to last process using device
         puls  pc,b         Restore B & return

* Pause char received
L059F    ldu   <V.DEV2      Get ptr to static mem of echo device
         beq   L05A6        No echo device, return
         sta   <V.PAUS,u    Yes, pause echo device
L05A6    rts   

L05A7    ldx   <u003A
         lda   <u0043
         ble   L05B3
         sta   ,y
         anda  #$80
         sta   <u0043
L05B3    tst   <u0040
         beq   L05EC
         ldb   <u0028
         bitb  #$08
         bne   L05EC
         andb  #$07
         andb  <Wrk.Type
         bne   L05EC
         ldb   <u003B
         negb  
         cmpb  #$0F
         bls   L05CC
         ldb   #$0F
L05CC    cmpb  <u0040
         bls   L05D2
         ldb   <u0040
L05D2    pshs  b
L05D4    lda   ,x+
         sta   ,y
         decb  
         bne   L05D4
         cmpx  <u003C
         bcs   L05E1
         ldx   <u003E
L05E1    stx   <u003A
         ldb   <u0040
         subb  ,s+
         stb   <u0040
L05E9    lbra  L0496
L05EC    lda   #$0D
         sta   $01,y
         bra   L05E9

L05F2    lda   $06,y
         tfr   a,b
         andb  #$B0
         stb   <u0020
         ldb   <u0028
         andb  #$FC
         bita  #$10
         bne   L0604
         orb   #$02
L0604    bita  #$20
         bne   L060A
         orb   #$01
L060A    bita  #$08
         beq   L0644
         bita  #$80
         bne   L062E
         lda   <Wrk.Type
         bita  #$10
         beq   L0626
         ldx   <V.PDLHd     Get open path descriptor's head link for device users
         beq   L0626        None (1 user only?), skip ahead
         lda   #PST.DCD     Flag carrier detect lost
L061E    sta   <PD.PST,x    Set carrier detect lost on current path
         ldx   <PD.PLP,x    Get path descriptor list ptr
         bne   L061E        There is one, flag it and all others in list as carrier lost
L0626    lda   #%00100000   $20 Set bit 5 in error accumulator
         ora   <V.ERR       Merge with current error accumulator
         sta   <V.ERR       And save it back
         andb  #%11111011   $FB Clear bit 2
L062E    tst   <u0027
         bne   L0644
         stb   <u0028
         ldd   <u0023
         tstb  
         beq   L0646
         os9   F$Send   
         stb   <u0027
         clra  
         clrb  
         std   <u0023
         bra   L0646

L0644    stb   <u0028
L0646    lda   #$0F
         sta   $01,y
         lbra  L0496

L064D    lda   $05,y
         bsr   L0654
         lbra  L0496

L0654    pshs  b
         clrb  
         bita  #$02
         beq   L065D
         orb   #$04
L065D    bita  #$04
         beq   L0663
         orb   #$01
L0663    bita  #$08
         beq   L0669
         orb   #$02
L0669    bita  #$10
         bne   L0673
         orb   #%00001000   $08 Set bit 3 in error accumulator
         orb   <V.ERR       Merge with current error accumulator
         stb   <V.ERR       And save it back
L0673    puls  pc,b

* IRQ Packet settings
L0675    fcb   $01          Flip Byte \ 16550 device address+2 is status register, and lowest
         fcb   $01          Mask Byte / bit clear means IRQ needs to be serviced
         fcb   $80          IRQ priority 128
         
* Some other data table. Should be 4 bytes/entry, and 16 entries (0-15). Related to baud rate
* Byte order of each entry:
*   ,0=HDiv (high byte of divisor latch) \ 16550 needs little endian, so we should swap these and
*   ,1=LDiv (low byte of divisor latch)  / remove the exg a,b the calling routine currently uses LCB
*   ,2=FCtrl settings EXCEPT FCRR & FCTR, which are forced on in calling routine
*   ,3=FIFO trigger level ctr - must be 1,4,8 or 14 (used for read loop counters)
* We should IFEQ this, so that we can easily redo this table for different clock implementations
*   (Rick's Fast232 used a 18.432MHz, the MegaMiniMPI uses a 29.4912 MHz crystal)
       ifne  Fast232
* 18.432 MHz crystal based table - CoNect Fast232
L0678    fcb   $28,$e9,FCEn,1        110 baud, 1 byte FIFO, 1 byte counter
         fcb   $0f,$00,FCEn,1        300 baud, 1 byte FIFO, 1 byte counter
         fcb   $07,$80,FCEn+FRT4,4   600 baud, 4 byte FIFO, 4 byte counter
         fcb   $03,$c0,FCEn+FRT8,8   1200 baud, 8 byte FIFO, 8 byte counter
         fcb   $01,$e0,FCEn+FRT14,14 2400 baud, 14 byte FIFO, 14 byte counter
         fcb   $00,$f0,FCEn+FRT14,14 4800 baud, 14 byte FIFO, 14 byte counter
         fcb   $00,$78,FCEn+FRT14,14 9600 baud, 14 byte FIFO, 14 byte counter
         fcb   $00,$3c,FCEn+FRT8,8   19200 baud, 8 byte FIFO, 8 byte counter
         fcb   $00,$1e,FCEn+FRT8,8   38400 baud, 8 byte FIFO, 8 byte counter
         fcb   $00,$14,FCEn+FRT8,8   57600 baud, 8 byte FIFO, 8 byte counter (shouldn't Divs be $000F?)
         fcb   $00,$0f,FCEn+FRT8,8   115200 baud, 8 byte FIFO, 8 byte counter (shouldn't Divs be $0007?)
         fcb   $00,$0a,FCEn+FRT8,8   undefined baud, 8 byte FIFO, 8 byte counter
         fcb   $00,$0a,FCEn+FRT8,8   undefined baud, 8 byte FIFO, 8 byte counter
         fcb   $00,$0a,FCEn+FRT8,8   undefined baud, 8 byte FIFO, 8 byte counter
         fcb   $00,$0a,FCEn+FRT8,8   undefined baud, 8 byte FIFO, 8 byte counter
         fcb   $00,$25,FCEn+FRT8,8   31125 baud, 8 byte FIFO, 8 byte counter (for MIDI)
       else
       ifne    f256
* 25.175 MHz crystal based table - F256
L0678    fcb   $37,$df,FCEn,1        110 baud, 1 byte FIFO, 1 byte counter
         fcb   $14,$7c,FCEn,1        300 baud, 1 byte FIFO, 1 byte counter
         fcb   $0a,$3e,FCEn+FRT4,4   600 baud, 4 byte FIFO, 4 byte counter
         fcb   $05,$1f,FCEn+FRT8,8   1200 baud, 8 byte FIFO, 8 byte counter
         fcb   $02,$8f,FCEn+FRT14,14 2400 baud, 14 byte FIFO, 14 byte counter
         fcb   $01,$47,FCEn+FRT14,14 4800 baud, 14 byte FIFO, 14 byte counter
         fcb   $00,$a3,FCEn+FRT14,14 9600 baud, 14 byte FIFO, 14 byte counter
         fcb   $00,$51,FCEn+FRT8,8   19200 baud, 8 byte FIFO, 8 byte counter
         fcb   $00,$28,FCEn+FRT8,8   38400 baud, 8 byte FIFO, 8 byte counter
         fcb   $00,$1b,FCEn+FRT8,8   57600 baud, 8 byte FIFO, 8 byte counter (shouldn't Divs be $000F?)
         fcb   $00,$0d,FCEn+FRT8,8   115200 baud, 8 byte FIFO, 8 byte counter (shouldn't Divs be $0007?)
         fcb   $00,$0a,FCEn+FRT8,8   undefined baud, 8 byte FIFO, 8 byte counter
         fcb   $00,$0a,FCEn+FRT8,8   undefined baud, 8 byte FIFO, 8 byte counter
         fcb   $00,$0a,FCEn+FRT8,8   undefined baud, 8 byte FIFO, 8 byte counter
         fcb   $00,$0a,FCEn+FRT8,8   undefined baud, 8 byte FIFO, 8 byte counter
         fcb   $00,$32,FCEn+FRT8,8   31125 baud, 8 byte FIFO, 8 byte counter (for MIDI)
       else
* 29.4912 MHz crystal based table - Zippsterzone MegaMiniMPI - Deek's experimental settings.
L0678    fcb   $41,74,$01,01  * 16756
         fcb   $18,00,$01,01  * 6144
         fcb   $0c,00,$41,04  * 3072
         fcb   $06,00,$81,08  * 1536
         fcb   $03,00,$c1,0e  * 768
         fcb   $01,80,$c1,0e  * 384
         fcb   $00,c0,$c1,0e  * 192
         fcb   $00,60,$81,08  * 96
         fcb   $00,30,$81,08  * 48
         fcb   $00,20,$81,08  * 32
         fcb   $00,10,$81,08  * 16
         fcb   $00,08,$81,08  * 8
         fcb   $00,04,$81,08  * 4
         fcb   $00,02,$81,08  * 2
         fcb   $00,01,$81,08  * 1
         fcb   $00,3b,$81,08  * 59
         endc
         endc
         
         emod
eom      equ   *
         end
