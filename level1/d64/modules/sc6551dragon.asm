*
* Dragon 64/Alpha 6551 serial port driver
*
* Disassembled 2005/04/25 00:12:02 by Disasm v1.5 (C) 1988 by RML
*
* The Dragon 64 and Dragon Alpha have a hardware serial port driven
* by a Rockwell 6551, mapped from $FF04-$FF07.
*
* Communication between the read/write routines and the ACIA, is buffered
* using a pair of ring buffers, when disassembling labels have been assigned
* so that bytes are placed into the Rx/Tx queue Tail, and removed from the
* head. When the queues become full the calling process is put to sleep
* while it awiaits Rx/Tx from the remote device.
*
* 2005-05-01, P.Harvey-Smith.
*	Initial disassembly.
*
* 2005-10-24, P.Harvey-Smith.
*	Code clean up/commenting.
*

                    nam       sc6551
                    ttl       os9 device driver

                    ifp1
                    use       defsfile
                    endc

* Following definitions borrowed from sc6551.asm

* Status bit definitions
Stat.IRQ            equ       %10000000           IRQ occurred
Stat.DSR            equ       %01000000           DSR level (clear = active)
Stat.DCD            equ       %00100000           DCD level (clear = active)
Stat.TxE            equ       %00010000           Tx data register Empty
Stat.RxF            equ       %00001000           Rx data register Full
Stat.Ovr            equ       %00000100           Rx data Overrun error
Stat.Frm            equ       %00000010           Rx data Framing error
Stat.Par            equ       %00000001           Rx data Parity error

Stat.Err            equ       Stat.Ovr!Stat.Frm!Stat.Par Status error bits
Stat.Flp            equ       $00                 all Status bits active when set
Stat.Msk            equ       Stat.IRQ!Stat.RxF   active IRQs

* Control bit definitions
Ctl.Stop            equ       %10000000           stop bits (set=two, clear=one)
Ctl.DBit            equ       %01100000           see data bit table below
Ctl.RxCS            equ       %00010000           Rx clock source (set=baud rate, clear=external)
Ctl.Baud            equ       %00001111           see baud rate table below

* data bit table
DB.8                equ       %00000000           eight data bits per character
DB.7                equ       %00100000           seven data bits per character
DB.6                equ       %01000000           six data bits per character
DB.5                equ       %01100000           five data bits per character

* baud rate table
                    org       $00
BR.ExClk            rmb       1                   16x external clock (not supported)
                    org       $11
BR.00050            rmb       1                   50 baud (not supported)
BR.00075            rmb       1                   75 baud (not supported)
BR.00110            rmb       1                   109.92 baud
BR.00135            rmb       1                   134.58 baud (not supported)
BR.00150            rmb       1                   150 baud (not supported)
BR.00300            rmb       1                   300 baud
BR.00600            rmb       1                   600 baud
BR.01200            rmb       1                   1200 baud
BR.01800            rmb       1                   1800 baud (not supported)
BR.02400            rmb       1                   2400 baud
BR.03600            rmb       1                   3600 baud (not supported)
BR.04800            rmb       1                   4800 baud
BR.07200            rmb       1                   7200 baud (not supported)
BR.09600            rmb       1                   9600 baud
BR.19200            rmb       1                   19200 baud

* Command bit definitions
Cmd.Par             equ       %11100000           see parity table below
Cmd.Echo            equ       %00010000           local echo (set=activated)
Cmd.TIRB            equ       %00001100           see Tx IRQ/RTS/Break table below
Cmd.RxI             equ       %00000010           Rx IRQ (set=disabled)
Cmd.DTR             equ       %00000001           DTR output (set=enabled)

* parity table
Par.None            equ       %00000000
Par.Odd             equ       %00100000
Par.Even            equ       %01100000
Par.Mark            equ       %10100000
Par.Spac            equ       %11100000

* Tx IRQ/RTS/Break table
TIRB.Off            equ       %00000000           RTS & Tx IRQs disabled
TIRB.On             equ       %00000100           RTS & Tx IRQs enabled
TIRB.RTS            equ       %00001000           RTS enabled, Tx IRQs disabled
TIRB.Brk            equ       %00001100           RTS enabled, Tx IRQs disabled, Tx line Break

* V.ERR bit definitions
DCDLstEr            equ       %00100000           DCD lost error
OvrFloEr            equ       %00000100           Rx data overrun or Rx buffer overflow error
FrmingEr            equ       %00000010           Rx data framing error
ParityEr            equ       %00000001           Rx data parity error

* FloCtlRx bit definitions
FCRxSend            equ       %10000000           send flow control character
FCRxSent            equ       %00010000           Rx disabled due to XOFF sent
FCRxDTR             equ       %00000010           Rx disabled due to DTR
FCRxRTS             equ       %00000001           Rx disabled due to RTS

* FloCtlTx bit definitions
FCTxXOff            equ       %10000000           due to XOFF received
FCTxBrk             equ       %00000010           due to currently transmitting Break

* Wrk.Type bit definitions
Parity              equ       %11100000           parity bits
MdmKill             equ       %00010000           modem kill option
RxSwFlow            equ       %00001000           Rx data software (XON/XOFF) flow control
TxSwFlow            equ       %00000100           Tx data software (XON/XOFF) flow control
RTSFlow             equ       %00000010           CTS/RTS hardware flow control
DSRFlow             equ       %00000001           DSR/DTR hardware flow control

* Wrk.Baud bit definitions
StopBits            equ       %10000000           number of stop bits code
WordLen             equ       %01100000           word length code
BaudRate            equ       %00001111           baud rate code

* Wrk.XTyp bit definitions
SwpDCDSR            equ       %10000000           swap DCD+DSR bits (valid for 6551 only)
ForceDTR            equ       %01000000           don't drop DTR in term routine
RxBufPag            equ       %00001111           input buffer page count

* End of borrowed stuff :)

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $01
                    mod       eom,name,tylg,atrv,start,size

RxQueueTailOffset   rmb       1                   ; Tail of Rx queue, Rx inturrupt inserts here
RxQueueHeadOffset   rmb       1                   ; Head of Rx queue, read call fetches from here
u001F               rmb       1
TxQueueTailOffset   rmb       1                   ; Tail of Tx queue, write call inserts here
TxQueueHeadOffset   rmb       1                   ; Head of Tx queue, Tx inturrupt fetches here
u0022               rmb       1
u0023               rmb       1                   ; something to do with XON/XOFF
u0024               rmb       2
SavedDSRDCD         rmb       1                   ; Saved DSR and DCD ststus
RxQueue             rmb       80                  ; Rx Queue
RxQueueLen          equ       *-RxQueue           ; Rx queue length

TxQueue             rmb       140                 ; Tx Queue
TxQueueLen          equ       *-TxQueue           ; Tx Queue length

size                equ       .

                    fcb       $03

name                equ       *
                    fcs       /sc6551/
                    fcb       $04

start               equ       *

                    lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetSta
                    lbra      SetSta
                    lbra      Term

IRQPkt
                    fcb       $00                 ; Normal bits (flip byte)
                    fcb       $80                 ; Bit 1 is interrupt request flag (Mask byte)
                    fcb       $0A                 ; Priority byte


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

Init                ldx       V.PORT,U            ; 1,U Get port address $FF04
                    stb       AciaStat,x          ; Write to status reg, this resets ACIA
                    ldb       #$02
                    stb       <u0022,u
                    ldd       <IT.PAR,y           ; Get parity & baud rate <$26,y

                    andb      #$0F
                    leax      <BaudRateTable,pcr  ; Calculate baud rate values for Acia
                    ldb       b,x

                    anda      #$F0
                    sta       V.TYPE,u            ; Save parity bits for later use
                    ldx       V.PORT,u            ; Get port address $FF04
                    std       AciaCmd,x           ; Setup Command (A), Control (B,Baud rates).
                    lda       ,x
                    lda       ,x
                    tst       AciaStat,x          ; Get status
                    lbmi      ErrorExit           ; Error if int occoured

                    clra                          ; Init some static storage
                    clrb
                    std       <RxQueueTailOffset,u ; Init Rx queue
                    std       <TxQueueTailOffset,u ; Init Tx queue
                    sta       <u0023,u
                    sta       <u001F,u
                    std       <u0024,u

                    ldd       V.PORT,u            ; Get port address $FF04
                    addd      #$0001              ; Setup V$IRQ on status reg changes
                    leax      >IRQPkt,pcr         ; Point to packet
                    leay      >IRQService,pcr     ; Point to handler
                    os9       F$IRQ               ; Install it !
                    bcs       InitExit            ; Error : Exit

                    ldx       V.PORT,u            ; Get port address $FF04
                    ldb       V.TYPE,u            ; Get device parity settings
                    orb       #Cmd.DTR            ; SET DTR, flag us as ready
                    stb       AciaCmd,x
                    clrb                          ; Flag no error
InitExit
                    rts

;
; Baud rate table, all baud rates use external clock.
;

BaudRateTable
                    fcb       Ctl.RxCS+BR.00110
                    fcb       Ctl.RxCS+BR.00300
                    fcb       Ctl.RxCS+BR.00600
                    fcb       Ctl.RxCS+BR.01200
                    fcb       Ctl.RxCS+BR.02400
                    fcb       Ctl.RxCS+BR.04800
                    fcb       Ctl.RxCS+BR.09600
                    fcb       Ctl.RxCS+BR.19200

PutProcToSleep
                    bsr       DoPutProcToSleep

*
* Input	U = Address of device static data storage
*	Y = Address of path descriptor module
*
* Output
*	A = Character read
*	CC = carry set on error, clear on none
*	B = error code if CC.C set.
*


Read                lda       <u0023,u
                    ble       L00A1

                    ldb       <u001F,u
                    cmpb      #$0A
                    bhi       L00A1

                    ldb       V.XON,u
                    orb       #$80
                    stb       <u0023,u

                    ldb       V.TYPE,u            ; Get prity settings
                    orb       #TIRB.On+Cmd.DTR    ; Enable tranmitter inturrupt & DTR ($05)
                    ldx       V.PORT,u            ; Get port address $FF04
                    stb       AciaCmd,x           ; Write to ACIA

L00A1               tst       <u0024,u
                    bne       ErrorExit

                    ldb       <RxQueueHeadOffset,u ; Get queue head ptr
                    leax      <RxQueue,u          ; Get Rx Queue address

                    orcc      #$50                ; Disable Inturrupts
                    cmpb      <RxQueueTailOffset,u ; Is Head=Tail, and therefore queue empty ?
                    beq       PutProcToSleep      ; Yes : sleep and await input from remote device

                    abx                           ; Calculate pos in queue for next char
                    lda       ,x                  ; Get byte from read queue
                    dec       <u001F,u
                    incb
                    cmpb      #RxQueueLen-1       ; Reached end of queue area ?
                    bls       L00BF               ; no : continue

                    clrb                          ; Wrap tail pointer to the beginning of queue space
L00BF               stb       <RxQueueHeadOffset,u ; save new queue pointer
                    clrb
                    ldb       V.ERR,u
                    beq       L00CF               ; No error : exit

                    stb       <$3A,y
                    clr       V.ERR,u
                    comb                          ; Flag and return error
                    ldb       #$F4
L00CF               andcc     #$AF                ; Enable inturrupts
                    rts

ErrorExit
                    comb                          ; Flag error & return
                    ldb       #$F6
                    rts

;
; Put calling process to sleep while we await input or output from remote device.
;

DoPutProcToSleep
                    pshs      x,b,a
                    lda       V.BUSY,u            ; Get busy process
                    sta       V.WAKE,u            ; Store in proc to wake
                    andcc     #$AF                ; Enable inturrupts
                    ldx       #$0000              ; Sleep indefinatly
                    os9       F$Sleep             ; Put caller to sleep

                    ldx       <D.Proc             ; Get current proces descriptor addr
                    ldb       <P$Signal,x         ; Get signal code of proc
                    beq       L00EF

                    cmpb      #$03
                    bls       L00F8

L00EF               clra
                    lda       P$State,x           ; Get process state
                    bita      #Condem             ; Process condemed ? (being killed ?)
                    bne       L00F8               ; yes : error, exit

                    puls      pc,x,b,a            ; Return

L00F8               leas      $06,s
                    coma
                    rts

L00FC               bsr       DoPutProcToSleep

*
* Input	U = Address of device static data storage
*	Y = Address of path descriptor module
*	A = Character to write
*
* Output
*	CC = carry set on error, clear on none
*	B = error code if CC.C set.
*

Write               leax      <TxQueue,u          ; Get pointer to transmit queue
                    ldb       <TxQueueTailOffset,u ; Get offset of end of TX queue
                    abx                           ; Calculate next free queue slot
                    sta       ,x                  ; Put byte to transmit in queue
                    incb                          ; Increment queue tail ptr
                    cmpb      #TxQueueLen-1       ; End of Queue area ?
                    bls       L010D               ; no, continue
                    clrb                          ; Point at begining of queue area

L010D               orcc      #$50                ; Disable inturrupts
                    cmpb      <TxQueueHeadOffset,u ; is Head=Tail therefore queue full ?
                    beq       L00FC               ; Yes : sleep process until room in queue

                    stb       <TxQueueTailOffset,u ; Re-save tail pointer
                    lda       <u0022,u
                    beq       L012B

                    anda      #$FD
                    sta       <u0022,u
                    bne       L012B

                    lda       V.TYPE,u            ; Get parity bits
                    ora       #TIRB.On+Cmd.DTR    ; Enable tranmitter inturrupt & DTR ($05)
                    ldx       V.PORT,u            ; Get port address $FF04
                    sta       AciaCmd,x           ; Write to ACIA

L012B               andcc     #$AF                ; Enable Inturrupts
L012D               clrb                          ; Flag no error
                    rts

*
* Input	U = Address of device static data storage
*	Y = Address of path descriptor module
*	A = Status code
*
* Output
*	Depends on status code.
*

GetSta              cmpa      #SS.Ready           ; Device ready ? ($01)
                    bne       L013E

                    ldb       <u001F,u
                    beq       ErrorExit

                    ldx       $06,y
                    stb       $02,x
L013C               clrb
                    rts

L013E               cmpa      #SS.EOF             ; EOF ? ($06)
                    beq       L012D

L0142               comb                          ; Flag error
                    ldb       #$D0
                    rts

*
* Input	U = Address of device static data storage
*	Y = Address of path descriptor module
*	A = Status code
*
* Output
*	Depends on status code.
*

SetSta              cmpa      #SS.SSig            ; Send signal on data ready ? ($1A)
                    bne       L0161

                    lda       PD.CPR,y            ; Get caller's process id
                    ldx       PD.RGS,y            ; Get caller's Regs
                    ldb       $05,x               ; Get lower half of X ????

                    orcc      #$50                ; Disable inturrupts
                    tst       <u001F,u
                    bne       L015C

                    std       <u0024,u
                    bra       L012B

L015C               andcc     #$AF
                    lbra      L01F8

L0161               cmpa      #SS.Relea           ; Release device ? ($1B)
                    bne       L0142

                    lda       PD.CPR,y            ; Get calling process ID
                    cmpa      <u0024,u            ; Same process ?
                    bne       L013C               ; no !

                    clr       <u0024,u            ; Yes : release
                    rts

L0170               lbsr      DoPutProcToSleep

*
* Input	U = Address of device static data storage
*
* Output
*	CC = carry set on error, clear on none
*	B = error code if CC.C set.
*

Term                ldx       <D.Proc             ; Get current process descriptor addr
                    lda       P$ID,x              ; Get process ID
                    sta       V.BUSY,u            ; Save it in busy and last processs
                    sta       V.LPRC,u

                    ldb       <TxQueueTailOffset,u ; Check we have sent all bytes ?
                    orcc      #$50
                    cmpb      <TxQueueHeadOffset,u
                    bne       L0170               ; Still bytes left to send, wait to send them

                    lda       V.TYPE,u            ; Get Parity settings
                    ldx       V.PORT,u            ; Get port address $FF04
                    sta       AciaCmd,x           ; Set parity in ACIA
                    andcc     #$AF                ; Enable inturrupts

                    ldx       #$0000              ; Remove IRQ handler
                    os9       F$IRQ
                    rts

*
* F$IRQ handler,
*
* Input :
*	A	= Status byte XOR flip
*	U	= our data area
*
* In this case, since flip byte is zero, and any value XOR zero
* remains uncahanged, A contains the contents of the ACIA status
* register ($FF05)
*

IRQService
                    ldx       V.PORT,u            ; Get port address $FF04
                    tfr       a,b                 ; Take a copy of status
                    andb      #Stat.DSR+Stat.DCD  ; Mask all but DSR & DCD ($60)
                    cmpb      <SavedDSRDCD,u      ; Compare to saved
                    beq       L01AB               ; not changed, check other bits

                    stb       <SavedDSRDCD,u      ; Save DSR & DCD values
                    bitb      #$60                ; Was either set ???
                    lbne      L02AE               ; yes
                    lbra      L029C

L01AB               bita      #Stat.RxF           ; Rx register full ? ($08)
                    bne       L01FD               ; yes

                    lda       <u0023,u
                    bpl       L01C4

                    anda      #$7F
                    sta       ,x
                    eora      V.XON,u
                    sta       <u0023,u
                    lda       <u0022,u
                    bne       L01EA

                    clrb
                    rts

L01C4               leay      <TxQueue,u          ; Point to transmit queue
                    ldb       <TxQueueHeadOffset,u ; Check that there are bytes to transmit
                    cmpb      <TxQueueTailOffset,u
                    beq       L01E2               ; no : skip

                    clra
                    lda       d,y                 ; Get byte to transmit
                    incb                          ; Increment head offset ptr
                    cmpb      #TxQueueLen-1       ; Head at end of Queue area ?
                    bls       L01D8

                    clrb                          ; Yes : point it at beginning
L01D8               stb       <TxQueueHeadOffset,u ; Save it
                    sta       AciaData,x          ; Transmit byte
                    cmpb      <TxQueueTailOffset,u ; Head=Tail therefore Tx queue empty ?
                    bne       L01F0               ; no : skip ahead

L01E2               lda       <u0022,u
                    ora       #$02
                    sta       <u0022,u

L01EA               ldb       V.TYPE,u            ; Get parity settings
                    orb       #Cmd.DTR            ; Enable DTR, ready
                    stb       AciaCmd,x           ; Write to ACIA

L01F0               ldb       #S$Wake             ; Wake up calling process
                    lda       V.WAKE,u            ; Get proc ID to wake
L01F4               beq       L01FB

                    clr       V.WAKE,u            ; Clear saved wake proc ID
L01F8               os9       F$Send              ; send wakeup signal
L01FB               clrb                          ; Flag no error
                    rts

L01FD               bita      #Stat.Par+Stat.Frm+Stat.Ovr ; Check for Parity/Framing/Overrun errors ($07)
                    beq       L0213               ; No Error detected, do read

                    tfr       a,b                 ; Copy status
                    tst       ,x
                    anda      #$07
                    ora       V.ERR,u
                    sta       V.ERR,u
                    lda       $02,x
                    sta       $01,x
                    sta       $02,x
                    bra       L01FB

L0213               lda       ,x                  ; Read byte from ACIA
                    beq       L022E               ; zero, branch ahead

                    cmpa      V.INTR,u            ; Inturrupt char ?
                    beq       L028B

                    cmpa      V.QUIT,u            ; Quit char ?
                    beq       L028F

                    cmpa      V.PCHR,u            ; Pause char ?
                    beq       L0283

                    cmpa      V.XON,u             ; Xon char ?
                    beq       L029C

                    cmpa      <V.XOFF,u           ; Xoff char ?
                    lbeq      L02AE

;
; If we reach here, char is nothing special, so just put it in queue
;

L022E               leax      <RxQueue,u          ; Point to receive queue
                    ldb       <RxQueueTailOffset,u ; Get tail offset
                    abx                           ; Calculate address
                    sta       ,x                  ; Put char in queue
                    incb                          ; increment tail ptr
                    cmpb      #RxQueueLen-1       ; End of queue area ?
                    bls       L023D               ; no : continue

                    clrb                          ; point to begining of Rx queue area
L023D               cmpb      <RxQueueHeadOffset,u ; Same as head of queue ?
                    bne       L024A               ; no :

                    ldb       #$04
                    orb       V.ERR,u             ; accumulated errors
                    stb       V.ERR,u
                    bra       L01F0

L024A               stb       <RxQueueTailOffset,u ; Save tail ptr
                    inc       <u001F,u
                    tst       <u0024,u
                    beq       L025D

                    ldd       <u0024,u
                    clr       <u0024,u
                    bra       L01F8

L025D               lda       <V.XOFF,u
                    beq       L01F0

                    ldb       <u001F,u
                    cmpb      #$46
                    bcs       L01F0

                    ldb       <u0023,u
                    bne       L01F0

                    anda      #$7F
                    sta       <V.XOFF,u
                    ora       #$80
                    sta       <u0023,u

                    ldb       V.TYPE,u            ; Get parity settings
                    orb       #TIRB.On+Cmd.DTR    ; Enable tranmitter inturrupt & DTR ($05)
                    ldx       V.PORT,u            ; Get port address $FF04
                    stb       AciaCmd,x           ; Write to acia

                    lbra      L01F0
L0283               ldx       V.DEV2,u
                    beq       L022E

                    sta       $08,x
                    bra       L022E

L028B               ldb       #$03
                    bra       L0291

L028F               ldb       #$02
L0291               pshs      a

                    lda       V.LPRC,u            ; Get last active proc ID
                    lbsr      L01F4               ; Wake process
                    puls      a
                    bra       L022E

L029C               lda       <u0022,u
                    anda      #$FE
                    sta       <u0022,u
                    bne       L02AC

                    lda       V.TYPE,u            ; Get parity settings
                    ora       #TIRB.On+Cmd.DTR    ; Enable tranmitter inturrupt & DTR ($05)
                    sta       AciaCmd,x           ; Write to ACIA
L02AC               clrb                          ; Flag no error
                    rts

L02AE               lda       <u0022,u
                    bne       L02B9

                    ldb       V.TYPE,u            ; Get parity settings
                    orb       #Cmd.DTR            ; Enable DTR
                    stb       AciaCmd,x           ; Write to ACIA

L02B9               ora       #$01
                    sta       <u0022,u
                    clrb
                    rts

                    emod
eom                 equ       *
                    end
