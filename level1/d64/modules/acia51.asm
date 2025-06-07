         nam ACIA51
         ttl Interrupt-Driven Acia driver for Rockwell 6551

* Copyright 1982 by Microware Systems Corporation
* Reproduced Under License

* This source code is the proprietary confidential property of
* Microware Systems Corporation, and is provided to licensee
* solely  for documentation and educational purposes. Reproduction,
* publication, or distribution in any form to any party other than
* the licensee is strictly prohibited!


 ifp1
         use  defsfile
 endc

Edition  equ  4          Current Edition

***************
* Interrupt-driven Acia Device Driver

INPSIZ   set  80         input  buffer size (<=256)
OUTSIZ   set  140        output buffer size (<=256)


DataReg  equ  0
StatReg  equ  1
CmndReg  equ  2
CtrlReg  equ  3

IRQReq   set  %10000000  Interrupt Request
NOTDSR   set  %01000000  not data set ready
DCDLST   set  %00100000  data carrier lost
TDRE     set  %00010000  transmitter data register empty
RDRF     set  %00001000  Rx data register Full
OVERUN   set  %00000100  overrun error bit
FRAME    set  %00000010  framing error bit
PARITY   set  %00000001  parity error bit

DTRRDY   equ  %00000001  data terminal ready
IRQOUT   equ  %00000100  transmitter interrupt

INPERR   set  NOTDSR+DCDLST

tylg     set  Drivr+Objct
atrv     set  ReEnt+rev
rev      set  $01
         mod  ACIEND,ACINAM,tylg,atrv,ACIENT,ACIMEM


**********
* Static storage offsets
*
         org  V.SCF      room for scf variables
INXTI    rmb  1          input  buffer next-in  ptr
INXTO    rmb  1          input  buffer next-out ptr
INCNT    rmb  1          input char count
ONXTI    rmb  1          output buffer next-in  ptr
ONXTO    rmb  1          output buffer next-out ptr
HALTED   rmb  1          output IRQ's disabled when non-zero
INHALT   rmb  1          input halted
RDYSGNL  rmb  2          first byte process id, second signal code
ERRSTAT  rmb  1
INPBUF   rmb  INPSIZ     input  buffer
OUTBUF   rmb  OUTSIZ     output buffer
ACIMEM   equ  .

* HALTED state conditions
H.XOFF   equ  1          V.XOFF char has been received; awaiting V.XON
H.EMPTY  equ  2          Output buffer is empty

         fcb  UPDAT.
ACINAM   fcs  "ACIA51"

         fcb  Edition    Current Revision


ACIENT   lbra INIT
         lbra READ
         lbra WRITE
         lbra GETSTA
         lbra PUTSTA
         lbra TRMNAT

ACMASK   fcb  0          no flip bits
         fcb  IRQReq     Irq polling mask
         fcb  10         (higher) priority

         ttl INTERRUPT-DRIVEN Acia device routines
         pag
***************
* Init
*   Initialize (Terminal) Acia
*
INIT     ldx  V.PORT,U   I/o port address
         stb  StatReg,x  reset acia
         ldb  #H.EMPTY
         stb  HALTED,U   output IRQ's disabled; buffer empty
         ldd  <$26,y  IT.PAR  a=Parity and b=baud rate
         andb #$0F       mask lower 4 bits of IT.BAU
         leax <BAUDTBL,pcr
         ldb  b,x
         anda #$F0
         sta  V.TYPE,u
         ldx  V.PORT,u
         std  CmndReg,x  configure both command and ctrl register
         lda  DataReg,x
         lda  DataReg,x
         tst  StatReg,x  interrupt gone?
         lbmi ErrNtRdy   ..No; abort
         clra
         clrb
         std  INXTI,U    Initialize buffer ptrs
         std  ONXTI,U
         sta  INHALT,U   flag input not halted
         sta  INCNT,U    clear in char count
         std  <RDYSGNL,U clear signal process
         ldd  V.PORT,U
         addd #StatReg   Add location of status register
         leax ACMASK,PCR
         leay ACIRQ,PCR  address of interrupt service routine
         OS9  F$IRQ      Add to IRQ polling table
         bcs  INIT9      Error - return it
         ldx  V.PORT,U
         ldb  V.TYPE,U
         orb  #DTRRDY
         stb  CmndReg,x
         clrb
INIT9    rts

*
BAUDTBL  fcb  $13        110 baud
         fcb  $16        300 baud
         fcb  $17        600 baud
         fcb  $18        1200 baud
         fcb  $1A        2400 baud
         fcb  $1C        4800 baud
         fcb  $1E        9600 baud
         fcb  $1F        19200 baud

*****************************
* READ
*  read a byte from Uart
*  Entry: U = Address of device static Storage
*         Y = Address of the path Descriptor
*  Output A = character read
*
READ00   bsr  ACSLEP
READ     lda  INHALT,U   is input halted?
         ble  Read.a     branch if not
         ldb  INCNT,U    get input character count
         cmpb #10        less than 10 chars in buffer?
         bhi  Read.a     branch if not
         ldb  V.XON,U    get X-ON char
         orb  #Sign      set sign bit
         stb  INHALT,U   flag input resume
         ldb  V.TYPE,U   get control value
         orb  #IRQOUT!DTRRDY enable input & output IRQs
         ldx  V.PORT,u
         stb  CmndReg,x
Read.a   tst  <RDYSGNL,u read while waiting for ready?
         bne  ErrNtRdy
         ldb  <INXTO,u
         leax INPBUF,U   address of input buffer
         orcc #IntMasks  calm interrupts
         cmpb INXTI,U    any data available?
         beq  READ00
         abx
         lda  0,X        the char
         dec  INCNT,U    decrement char count
         incb            ADVANCE Next-out ptr
         cmpb #INPSIZ-1  end of circular buffer?
         bls  READ10     ..no
         clrb            reset ptr to start of buffer
READ10   stb  INXTO,U    save updated buffer ptr
         clrb
         ldb  V.ERR,U    Transmission error?
         beq  READ90     ..no; return
         stb  PD.ERR,Y   return error bits in pd
         clr  V.ERR,U
         comb            return carry set
         ldb  #E$Read    signal read error
READ90   andcc #^IntMasks enable IRQ requests
         rts

ErrNtRdy comb
         ldb  #E$NotRdy
         rts

**********
* Acslep - Sleep for I/O activity
*  This version Hogs Cpu if signal pending
*
* Passed: (cc)=Irq's Must be disabled
*         (U)=Global Storage
*         V.Busy,U=current proc id
* Destroys: possibly Pc

ACSLEP   pshs D,X
         lda  V.BUSY,U   get current process id
         sta  V.Wake,U   arrange wake up signal
         andcc #^IntMasks interrupts ok now
         ldx  #0
         OS9  F$Sleep    wait for input data
         ldx  D.Proc
         ldb  P$Signal,X signal present?
         beq  ACSL90     ..no; return
         cmpb #S$Intrpt  Deadly signal?
         bls  ACSLER     ..yes; return error
ACSL90   clra            clear carry
         lda  P$State,X  check process state flags
         bita #Condem    has process died?
         bne  ACSLER     ..Yes; return error
         puls D,X,PC     return

ACSLER   leas 6,S        Exit to caller's caller
         coma            return carry set
         rts

***************
* Write
*   Write char Through Acia
*
* Passed: (A)=char to write
*         (Y)=Path Descriptor
*         (U)=Static Storage address
* returns: CC=Set If Busy (output buffer Full)
*
WRIT00   bsr  ACSLEP     sleep a bit
WRITE    leax OUTBUF,U   output buffer address
         ldb  ONXTI,U    (output) next-out ptr
         abx
         sta  0,X        Put char in buffer
         incb            ADVANCE the ptr
         cmpb #OUTSIZ-1  end of circular buffer?
         bls  WRIT10     ..no
         clrb            reset ptr to start of buffer
WRIT10   orcc #IntMasks  disable interrupts
         cmpb ONXTO,U    buffer full?
         beq  WRIT00     ..yes; sleep and retry
         stb  ONXTI,U    save updated next-in ptr
         lda  HALTED,U   output already enabled?
         beq  Write80    ..yes; don't re-enable
         anda #^H.EMPTY  no longer halted due to empty
         sta  HALTED,U
         bne  Write80    ..Still HALTED; don't enable IRQ
         lda  V.TYPE,U   Parity control
         ora  #IRQOUT!DTRRDY enable input & output IRQs
         ldx  V.PORT,u
         sta  CmndReg,x
Write80  andcc #^IntMasks Allow I and F interrupts
Write90  clrb
         rts

***************
* Getsta/Putsta
*   Get/Put Acia Status
*
* Passed: (A)=Status Code
*         (Y)=Path Descriptor
*         (U)=Static Storage address
* returns: varies
GETSTA   cmpa #SS.Ready  Ready status?
         bne  GETS10     ..no
         ldb  INCNT,U    get input character count
         beq  ErrNtRdy   ..No; return not ready error
         ldx  PD.RGS,Y
         stb  R$B,X      return bytecount to caller (!)
STATUS99 clrb
         rts

GETS10   cmpa #SS.EOF    End of file?
         beq  Write90    ..yes; return carry clear

UNKSVC   comb            return carry set
         ldb  #E$UnkSvc  Unknown service code
         rts
**************************
* PUTSTA
*  Set device Status
* (U) = Address of device static storage

PUTSTA   cmpa #SS.SSig   Send signal on data ready
         bne  SetRel
         lda  PD.CPR,y
         ldx  PD.RGS,y
         ldb  R$X+1,x    Signal code
         orcc #IntMasks  Block I and F interrupts
         tst  <INCNT,u data ready already?
         bne  PUTS10     ..Yes
         std  <RDYSGNL,u
         bra  Write80
PUTS10   andcc #^IntMasks Allow I and F interrupts
         lbra SendSig    send code to process
SetRel   cmpa #SS.Relea
         bne  UNKSVC
         lda  PD.CPR,y
         cmpa <RDYSGNL,u
         bne  STATUS99
         clr  <RDYSGNL,u
         rts

***************
* Subroutine TRMNAT
*   Terminate Acia processing
*
* Passed: (U)=Static Storage
* returns: Nothing
*
TRMN00   lbsr ACSLEP     wait for I/O activity
TRMNAT   ldx  D.Proc
         lda  P$ID,X
         sta  V.BUSY,U
         sta  V.LPRC,U
         ldb  ONXTI,U
         orcc #IntMasks  disable interrupts
         cmpb ONXTO,U    output done?
         bne  TRMN00     ..no; sleep a bit
         lda  V.TYPE,U
         ldx  V.PORT,u
         sta  CmndReg,x
         andcc #^IntMasks enable interrupts
         ldx  #0
         OS9  F$IRQ      remove acia from polling tbl
         rts

***************
* AcIRQ
*   process Interrupt (input or output) from Acia
*
* Passed: (U)=Static Storage addr
*         (X)=Port address
*         (A)=polled status
* Returns: Nothing
*
ACIRQ    ldx  V.PORT,U   get port address
         tfr  A,B        copy status
         andb #INPERR    mask status error bits
         cmpb ERRSTAT,U  compare to saved
         beq  OutIRQ     nothing changed
         stb  ERRSTAT,U  save error status
         bitb #INPERR    inout error?
         lbne InXOFF     ..yes; stop
         lbra InXON

OutIRQ   bita #RDRF      receiver data register full?
         bne  InIRQ      ..yes
         lda  INHALT,U   send X-ON or X-OFF?
         bpl  OutI.a     branch if not
         anda #^Sign     clear sign bit
         sta  DataReg,X  send character
         eora V.XON,U    get zero if X-ON
         sta  INHALT,U   mark it sent
         lda  HALTED,U   is output halted?
         bne  OutIRQ3    branch if so
         clrb            clear carry
         rts
OutI.a   leay OUTBUF,U   output buffer ptr
         ldb  ONXTO,U    (output) next-out ptr
         cmpb ONXTI,U    output buffer already empty?
         beq  OutIRQ2    ..yes; disable output IRQ, return
         clra
         lda  D,Y        next output char
         incb            ADVANCE Next-out ptr
         cmpb #OUTSIZ-1  end of circular buffer?
         bls  OutIRQ1    ..no
         clrb
OutIRQ1  stb  ONXTO,U    save updated next-out ptr
         sta  DataReg,X  Write the char
         cmpb ONXTI,U    last char in output buffer?
         bne  WAKEUP     ..no
OutIRQ2  lda  <HALTED,u
         ora  #H.EMPTY
         sta  HALTED,U
OutIRQ3  ldb  V.TYPE,u
         orb  #DTRRDY    set data terminal ready
         stb  CmndReg,x

WAKEUP   ldb  #S$Wake    Wake up signal
         lda  V.Wake,U   Owner waiting?
Wake10   beq  Wake90     ..no; return
         clr  V.Wake,U
SendSig  OS9  F$Send     send signal
Wake90   clrb            return carry clear
         rts

InIRQ    bita #OVERUN!FRAME!PARITY check for errors
         beq  InIRQ0     ..none
         tfr  a,b
         tst  ,x
         anda #OVERUN!FRAME!PARITY
         ora  V.ERR,u
         sta  V.ERR,u
         lda  $02,x
         sta  $01,x
         sta  $02,x
         bra  Wake90

***************
* Inacia
*   process Acia input Interrupt
*
* Passed: (A)=Acia Status Register data
*         (X)=Acia port address
*         (U)=Static Storage address
*
InIRQ0   lda  DataReg,X  Read input char
         beq  InIRQ1     ..NULL, impossible Ctl Chr
         cmpa V.INTR,U   keyboard Interrupt?
         beq  InAbort    ..Yes
         cmpa V.QUIT,U   keyboard Quit?
         beq  InQuit     ..Yes
         cmpa V.PCHR,U   keyboard Pause?
         beq  InPause    ..Yes
         cmpa V.XON,U    X-ON continue?
         beq  InXON      ..Yes
         cmpa V.XOFF,U   X-OFF Immediate Pause request?
         lbeq InXOFF     ..Yes

InIRQ1   leax INPBUF,U   input buffer
         ldb  INXTI,U    (input) next-in ptr
         abx
         sta  0,X        save char in buffer
         incb            update Next-in ptr
         cmpb #INPSIZ-1  end of circular buffer?
         bls  InIRQ2     ..no
         clrb
InIRQ2   cmpb INXTO,U    input overrun?
         bne  InIRQ30    ..no; good
         ldb  #OVERUN    mark overrun error
         orb  V.ERR,U
         stb  V.ERR,U
         bra  WAKEUP     throw away character

InIRQ30  stb  INXTI,U    update next-in ptr
         inc  INCNT,U
         tst  <RDYSGNL,u process waiting for signal?
         beq  InIRQ4     ..no
         ldd  <RDYSGNL,u
         clr  <RDYSGNL,u
         bra  SendSig

InIRQ4   lda  V.XOFF,U   get X-OFF char
         beq  WAKEUP     branch if not enabled
         ldb  INCNT,U    get input count
         cmpb #INPSIZ-10 is buffer almost full?
         blo  WAKEUP     bra if not
         ldb  INHALT,U   have we sent XOFF?
         bne  WAKEUP     yes then don't send it again
         anda #^Sign     insure sign clear
         sta  V.XOFF,U
         ora  #Sign      set sign bit
         sta  INHALT,U   flag input halt
         ldb  V.TYPE,U   get control value
         orb  #IRQOUT!DTRRDY enable input & output IRQs
         ldx  V.PORT,U
         stb  CmndReg,X
         lbra WAKEUP

InPause  ldx  V.DEV2,u
         beq  InIRQ1     ..None; buffer char, exit
         sta  V.PAUS,X   request pause
         bra  InIRQ1     buffer char, exit

InAbort  ldb  #S$Intrpt  keyboard INTERRUPT signal
         bra  InQuit10

InQuit   ldb  #S$Abort   Abort signal
InQuit10 pshs A          save input char
         lda  V.LPRC,U   last process id
         lbsr Wake10     Send error signal
         puls A          restore input char
         bra  InIRQ1     buffer char, exit

InXON    lda  <HALTED,u
         anda #^H.XOFF
         sta  HALTED,U   enable output
         bne  InXON99    ..exit if otherwise disabled
         lda  V.TYPE,U   parity control
         ora  #IRQOUT!DTRRDY enable input & output IRQs
         sta  CmndReg,X
InXON99  clrb
         rts

InXOFF   lda  HALTED,U
         bne  InXOFF10   ..already halted, continue
         ldb  V.TYPE,U   get acia control code
         orb  #DTRRDY
         stb  CmndReg,X
InXOFF10 ora  #$01       set bit 1
         sta  HALTED,U   restrict output
         clrb
         rts

         emod            Module Crc
ACIEND   equ  *
