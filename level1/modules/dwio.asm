********************************************************************
* dwio - DriveWire Low Level Subroutine Module
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2008/01/26  Boisy G. Pitre
* Started as a segregated subroutine module.
*
*   2      2010/01/20  Boisy G. Pitre
* Added support for DWNet
*
*   3      2010/01/23  Aaron A. Wolfe
* Added dynamic polling frequency
*
                    nam       dwio
                    ttl       DriveWire 3 Low Level Subroutine Module

                    ifp1
                    use       defsfile
                    use       drivewire.d
                    endc

 ifne wildbits
 use 16550.d
 endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,0

* irq
IRQPckt             fcb       $00,$01,$0A         ;IRQ packet Flip(1),Mask(1),Priority(1) bytes
* Default time packet
DefTime             fcb       109,12,31,23,59,59

* for dynamic poll frequency, number of ticks between firing poller - should we move to dwdefs?
* speed 1 = interactive (typing)
PollSpd1            fcb       3
* speed 2 = bulk transfer (depending on how much processing needs to be done to incoming stream, 5-8 seems good)
PollSpd2            fcb       6
* speed 3 = idle
PollSpd3            fcb       40
* X pollidle -> drop to next slower rate
PollIdle            fcb       60
                    ifne      wildbits
* Tick-poll state machine (2026-09-07, wb/DriveWireCompatible): the handler never waits for the server.
POLL_WAIT           equ       240                 LSR polls per owed byte (~0.5 ms; the bytes of one response are 43 us apart)
POLL_STALL          equ       4                   empty IRQ firings before backing off (reply remains owed)
POLL_HOLD           equ       3                   firings skipped after a reset (server backoff)
POLL_DRAIN          equ       2000                LSR polls the reset drains (~4 ms)
POLL_MAXGRAB        equ       16                  bytes per multi-read: the RX FIFO holds them until the next firing
SETTLE_TRIES        equ       120                 ticks a process waits for an owed response before resetting the line
                    endc


name                fcs       /dwio/

* DriveWire subroutine entry table
start               lbra      Init
                    bra       Read
                    nop
                    ifne      BECKER+ARDUINO
                    bra       Write
                    nop
                    else
                    lbra      Write
                    endc
                    ifne      wildbits
                    lbra      Term                DW$Term = 9
                    lbra      Settle              DW$Settle = 12: a process acquires the link
                    endc

* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Term
                    clrb                          clear Carry
                    rts

Read
                    ifne      atari
                    jmp       [$FFE0]
                    else
                    use       dwread.asm
                    endc

Write
                    ifne      atari
                    jmp       [$FFE2]
                    else
                    use       dwwrite.asm
                    endc

DWInitM
                    ifne      atari
                    use       dwinit/dwinit_none.asm
                    else
                    use       dwinit.asm
                    endc

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
* Initialize the serial device
Init
                    clrb                          clear Carry
                    pshs      y,x,cc              then push CC on stack
                    ifeq      atari
                    bsr       DWInit
                    endc
                    
; allocate DW statics page
                    pshs      u
                    ldd       #$0100
                    os9       F$SRqMem
                    tfr       u,x
                    puls      u
                    lbcs      InitEx
                    ifgt      Level-1
                    stx       <D.DWStat
                    else
                    stx       >D.DWStat
                    endc
; clear out 256 byte page at X
                    clrb
loop@               clr       ,x+
                    decb
                    bne       loop@

* send OP_DWINIT
; setup DWsub command
                    pshs      u
                    ldb       #1                  ; DRIVER VERSION
                    lda       #OP_DWINIT          ; load command
                    pshs      d                   ; command store on stack
                    leax      ,s                  ; point X to stack
                    ldy       #2                  ; 1 byte to send
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       DW$Write,u          ; call DWrite
                    leas      1,s                 ; leave one byte on stack for response

                    ;         read                protocol version response, 1 byte
                    leax      ,s                  ; point X to stack head
                    ldy       #1                  ; 1 byte to retrieve
                    jsr       DW$Read,u           ; call DWRead
                    beq       ChkVer              ; branch if no error
                    leas      3,s                 ; error, cleanup stack (u and 1 byte from read)
                    bra       InitEx              ; don't install IRQ handler

* Check Version
ChkVer
                    lda       ,s                  ; Load value that was gotten back from server
                    cmpa      #4                  ; Check to see if this is version 4 of DriveWire
                    beq       InstIRQ             ; If server is DriveWire 4 then go Install IRQ
                    cmpa      #$ff                ; Check to see if this is pyDriveWire
                    beq       InstIRQ             ; If server is pyDriveWire then go install IRQ
                    leas      3,s                 ; Clean up stack
                    bra       InitEx              ; leave since DriveWire version is not 4.

* install ISR
InstIRQ
                    puls      a,u                 ; a has proto version from server.. not used yet

                    ifgt      Level-1
                    ldx       <D.DWStat
                    else
                    ldx       >D.DWStat
                    endc
                    leax      DW.VIRQPkt,x
                    pshs      u
                    tfr       x,u
                    leax      Vi.Stat,x           ;fake VIRQ status register
                    lda       #$80                ;VIRQ flag clear, repeated VIRQs
                    sta       ,x                  ;set it while we're here...
                    tfr       x,d                 ;copy fake VIRQ status register address
                    leax      IRQPckt,pcr         ;IRQ polling packet
                    leay      IRQSvc,pcr          ;IRQ service entry
                    os9       F$IRQ               ;install
                    puls      u
                    bcs       InitEx              ;exit with error
                    clra
                    ldb       PollSpd3,pcr        ; start at idle
                    ifgt      Level-1
                    ldx       <D.DWStat
                    else
                    ldx       >D.DWStat
                    endc
                    leax      DW.VIRQPkt,x
                    std       Vi.Rst,x            ; reset count
                    tfr       x,y                 ; move VIRQ software packet to Y
tryagain
                    ldx       #$0001              ; code to install new VIRQ
                    os9       F$VIRQ              ; install
                    bcc       IRQok               ; no error, continue
                    cmpb      #E$UnkSvc
                    bne       InitEx
; if we get an E$UnkSvc error, then clock has not been initialized, so do it here
                    leax      DefTime,pcr
                    os9       F$STime
                    bra       tryagain            ; note: this has the slim potential of looping forever
IRQok
                    ifgt      Level-1
                    ldx       <D.DWStat
                    else
                    ldx       >D.DWStat
                    endc
; cheat: we know DW.StatTbl is at offset $00 from D.DWStat, do not bother with leax
                    leax      DW.StatTbl,x
                    tfr       u,d
                    ldb       <V.PORT+1,u         ; get our port #
                    sta       b,x                 ; store in table

InitEx
                    puls      cc,x,y,pc


; ***********************************************************************
; Interrupt handler  - Much help from Darren Atkinson

IRQMulti3           anda      #$0F                ; mask first 4 bits, a is now port #+1
                    deca                          ; we pass +1 to use 0 for no data
                    pshs      a                   ; save port #
                    cmpb      RxGrab,u            ; compare room in buffer to server's byte
                    bhs       IRQM06              ; room left >= server's bytes, no problem

                    stb       RxGrab,u            ; else replace with room left in our buffer

                    ;         also                limit to end of buffer
IRQM06              ldd       RxBufEnd,u          ; end addr of buffer
                    subd      RxBufPut,u          ; subtract current write pointer, result is # bytes left going forward in buff.

IRQM05              cmpb      RxGrab,u            ; compare b (room left) to grab bytes
                    bhs       IRQM03              ; branch if we have room for grab bytes

                    stb       RxGrab,u            ; else set grab to room left

                    ;         send                multiread req
IRQM03              puls      a                   ; port # is on stack
                    ldb       RxGrab,u
                    ifne      wildbits
* The bytes are collected at the next firing (PollStep), so the grab must fit the RX FIFO.
                    cmpb      #POLL_MAXGRAB
                    bls       IRQM03a
                    ldb       #POLL_MAXGRAB
                    stb       RxGrab,u
IRQM03a
                    endc

                    pshs      u

                    ;         setup               DWsub command
                    pshs      d                   ; (a port, b bytes)
                    lda       #OP_SERREADM        ; load command
                    pshs      a                   ; command store on stack
                    leax      ,s                  ; point X to stack
                    ldy       #3                  ; 3 bytes to send

                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       DW$Write,u          ; call DWrite

                    leas      3,s                 ; clean 3 DWsub args from stack
                    ifne      wildbits
* wildbits: the bytes are owed now. PollStep reads them at the next firing (or Settle does, for a
* process that needs the link first) and PollDoneM below finishes the buffer bookkeeping.
                    puls      u                   ; port statics
                    ldx       <D.DWStat
                    lda       #2
                    sta       DW.PollSt,x
                    clr       DW.PollTk,x
                    ldb       RxGrab,u
                    stb       DW.PollNeed,x
                    stu       DW.PollPort,x
                    ldd       RxBufPut,u
                    std       DW.PollDst,x
                    lbra      IRQExit
* PollDoneM - the multi-read bytes are in the port buffer: advance the put pointer, count them and
* wake the reader.  X = D.DWStat.  Runs in an IRQExit frame and leaves through CkSSig.
PollDoneM           pshs      cc,dp
                    orcc      #IntMasks
                    ldu       DW.PollPort,x
                    ldb       RxGrab,u
                    ldx       RxBufPut,u
                    abx
                    cmpx      RxBufEnd,u
                    blo       IRQM04
                    ldx       RxBufPtr,u
                    else

                    ldx       ,s                  ; pointer to this port's area (from U prior), leave it on stack
                    ldb       RxGrab,x            ; set B to grab bytes
                    clra                          ; 0 in high byte
                    tfr       d,y                 ; set # bytes for DW

                    ldx       RxBufPut,x          ; point X to insert position in this port's buffer
                    ;         receive             response
                    jsr       DW$Read,u           ; call DWRead
                    ;         handle              errors?


                    puls      u
                    ldb       RxGrab,u            ; our grab bytes

                    ;         set                 new RxBufPut
                    ldx       RxBufPut,u          ; current write pointer
                    abx                           ; add b (# bytes) to RxBufPut
                    cmpx      RxBufEnd,u          ; end of Rx buffer?
                    blo       IRQM04              ; no, go keep laydown pointer
                    ldx       RxBufPtr,u          ; get Rx buffer start address
                    endc
IRQM04              stx       RxBufPut,u          ; set new Rx data laydown pointer

                    ;         set                 new RxDatLen
                    ldb       RxDatLen,u
                    addb      RxGrab,u
                    stb       RxDatLen,u          ; store new value

                    lbra      CkSSig              ; had to lbra

IRQMulti
                    ;         set                 IRQ freq for bulk
                    pshs      a
                    lda       PollSpd2,pcr
                    lbsr      IRQsetFRQ
                    puls      a

                    ;         initial             grab bytes
                    stb       RxGrab,u

                    ;         limit               server bytes to bufsize - datlen
                    ldb       RxBufSiz,u          ; size of buffer
                    subb      RxDatLen,u          ; current bytes in buffer
                    ifne      wildbits
                    lbne      IRQMulti3            (the poll code in between put the target out of short range)
                    else
                    bne       IRQMulti3           ; continue, we have some space in buffer
                    endc
                    ;         no                  room in buffer
                    tstb
                    lbne      CkSSig              ;had to lbra
                    lbra      IRQExit             ;had to lbra

bad
                    leas      2,s                 ; error, cleanup stack 2
                    lbra      IRQExit2            ; don't reset error count on the way out

; **** IRQ ENTRY POINT
                    ifne      wildbits
* wildbits (2026-09-07): the tick poll is a state machine - nothing in here ever waits for the server.
* A firing either sends OP_SERREAD (state 1) or collects the response owed from the last one and,
* once it is complete, processes it and sends the next request.  A process that needs the link
* calls DW$Settle first; DW.LinkBusy keeps this handler off the UART while it owns the link.
IRQSvc              equ       *
                    pshs      cc,dp               ; save system cc,DP
                    orcc      #IntMasks           ; mask interrupts
                    lda       Vi.Stat,u           ; VIRQ status register
                    anda      #^Vi.IFlag          ; clear flag in VIRQ status register
                    sta       Vi.Stat,u           ; save it...
                    ldx       <D.DWStat
                    tst       DW.LinkBusy,x       a process owns the link: not this firing
                    lbne      IRQExit
                    tst       DW.PollHold,x       backing off after a stalled server
                    beq       IRQs1
                    dec       DW.PollHold,x
                    lbra      IRQExit
IRQs1               tst       DW.PollSt,x
                    bne       IRQs2
                    lbsr      PollSend            nothing owed: ask
                    lbra      IRQExit
IRQs2               lda       #1                  collect what is owed, then ask again
                    lbsr      PollStep
                    lbra      IRQExit

* PollProc - D = a complete OP_SERREAD response (A = status, B = data): the original handler from
* here on, inside an IRQExit frame so that every one of its exits returns to PollStep.
PollProc            pshs      cc,dp
                    orcc      #IntMasks
                    cmpd      #0
IRQSvc2             bne       IRQGotOp            ; branch if D != 0 (something to do)
                    else
IRQSvc              equ       *
                    pshs      cc,dp               ; save system cc,DP
                    orcc      #IntMasks           ; mask interrupts

                    ;         mark                VIRQ handled (note U is pointer to our VIRQ packet in DP)
                    lda       Vi.Stat,u           ; VIRQ status register
                    anda      #^Vi.IFlag          ; clear flag in VIRQ status register
                    sta       Vi.Stat,u           ; save it...

                    ;         poll                server for incoming serial data

                    ;         send                request
                    lda       #OP_SERREAD         ; load command
                    pshs      a                   ; command store on stack
                    leax      ,s                  ; point X to stack
                    ldy       #1                  ; 1 byte to send

                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       DW$Write,u          ; call DWrite

                    ;         receive             response
                    leas      -1,s                ; one more byte to fit response
                    leax      ,s                  ; point X to stack head
                    ldy       #2                  ; 2 bytes to retrieve
                    jsr       DW$Read,u           ; call DWRead
                    bcs       bad
                    bne       bad

                    ;         process             response
IRQSvc2
                    ldd       ,s++                ; pull returned status byte into A,data into B (set Z if zero, N if multiread)
                    bne       IRQGotOp            ; branch if D != 0 (something to do)
                    endc
* this is a NOP response.. do we need to reschedule
                    ifgt      Level-1
                    ldx       <D.DWStat
                    else
                    ldx       >D.DWStat
                    endc
                    lda       DW.VIRQPkt+Vi.Rst+1,x
                    cmpa      PollSpd3,pcr
                    lbeq      IRQExit             ;we are already at idle speed

                    lda       DW.VIRQNOP,x
                    inca
                    cmpa      PollIdle,pcr
                    beq       FRQdown

                    sta       DW.VIRQNOP,x        ;inc NOP count, exit
                    lbra      IRQExit

FRQdown             lda       DW.VIRQPkt+Vi.Rst+1,x
                    cmpa      PollSpd1,pcr
                    beq       FRQd1
                    lda       PollSpd3,pcr
FRQd2
                    sta       DW.VIRQPkt+Vi.Rst+1,x
                    clr       DW.VIRQNOP,x
                    lbra      IRQExit
FRQd1               lda       PollSpd2,pcr
                    bra       FRQd2

; save back D on stack and build our U
IRQGotOp
                    cmpd      #16*256+255
                    beq       do_reboot

                    pshs      d
* mode switch on bits 7+6 of A: 00 = vserial, 01 = vwindow, 10 = wirebug?, 11 = ?

                    anda      #$C0                ; mask last 6 bits
                    beq       mode00              ; virtual serial mode
                    ;         future              - handle other modes
                    cmpa      #%01000000          ; vwindow?
                    beq       mode01
                    lbra      IRQExit             ; for now, bail

* Virtual Window Handler
mode01
                    lda       ,s
                    anda      #%00110000
                    beq       key
                    lbra      IRQExit

key
                    lda       ,s
                    anda      #$0F
                    ora       #$10
                    ifgt      Level-1
                    ldx       <D.DWStat
                    else
                    ldx       >D.DWStat
                    endc
; cheat: we know DW.StatTbl is at offset $00 from D.DWStat, do not bother with leax
;			leax    DW.StatTbl,x
                    lda       a,x
                    clrb
                    tfr       d,u
                    puls      d
                    lbra      IRQPutch

do_reboot
                    lda       #255
                    os9       F$Debug

* Virtual Serial Handler
mode00
                    lda       ,s                  ; restore A
                    anda      #$0F                ; mask first 4 bits, a is now port #+1
                    beq       IRQCont             ; if we're here with 0 in the port, its not really a port # (can we jump straight to status?)
                    deca                          ; we pass +1 to use 0 for no data
; here we set U to the static storage area of the device we are working with
                    ifgt      Level-1
                    ldx       <D.DWStat
                    else
                    ldx       >D.DWStat
                    endc
; cheat: we know DW.StatTbl is at offset $00 from D.DWStat, do not bother with leax
;			leax    DW.StatTbl,x
                    lda       a,x
                    bne       IRQCont             ; if A is 0, then this device is not active, so exit
                    puls      d
                    lbra      IRQExit
IRQCont
                    clrb
                    tfr       d,u

                    puls      d

                    *         multiread/status    flag is in bit 4 of A
                    bita      #$10
                    ifne      wildbits
                    lbeq      IRQPutch            (the poll code in between put the target out of short range)
                    else
                    beq       IRQPutch            ; branch for read1 if multiread not set
                    endc

                    *         all                 0s in port means status, anything else is multiread

                    bita      #$0F                ;mask bit 7-4
                    beq       dostat              ;port # all 0, this is a status response
                    lbra      IRQMulti            ;its not all 0, this is a multiread


                    *         in                  status events, databyte is split, 4bits status, 4bits port #
dostat              bitb      #$F0                ;mask low bits
                    lbne      IRQExit             ;we only implement code 0000, term
                    *         set                 u to port #
                    ifgt      Level-1
                    ldx       <D.DWStat
                    else
                    ldx       >D.DWStat
                    endc
                    lda       b,x
                    ifne      wildbits
                    lbne      statcont            (the poll code in between put the target out of short range)
                    else
                    bne       statcont            ; if A is 0, then this device is not active, so exit
                    endc
                    lbra      IRQExit

                    ifne      wildbits
* PollSend - send OP_SERREAD; two bytes are owed from now (state 1).
PollSend            lda       #OP_SERREAD
                    pshs      a
                    leax      ,s
                    ldy       #1
                    lbsr      DWWrite
                    puls      a
                    ldx       <D.DWStat
                    lda       #1
                    sta       DW.PollSt,x
                    clr       DW.PollTk,x
                    lda       #2
                    sta       DW.PollNeed,x
                    leay      DW.PollResp,x
                    sty       DW.PollDst,x
                    rts

* PollGet - collect the owed bytes that have arrived: up to DW.PollNeed of them into DW.PollDst.
* Each byte may wait POLL_WAIT LSR polls (the bytes of one response arrive back to back).
* Exit: carry clear = all owed bytes are in, carry set = still owed.  X = D.DWStat.  Interrupts
* are the caller's business (masked in the handler, masked per call from Settle).
PollGet             pshs      y,u
PgNext              tst       DW.PollNeed,x
                    beq       PgDone
                    ldy       #POLL_WAIT
PgWait              lda       UART.Base+UART_LSR
                    bita      #LSR_DATA_AVAIL
                    bne       PgByte
                    leay      -1,y
                    bne       PgWait
                    orcc      #Carry              nothing (more) here yet
                    puls      y,u,pc
PgByte              lda       UART.Base+UART_TRHB
                    ldu       DW.PollDst,x
                    sta       ,u+
                    stu       DW.PollDst,x
                    dec       DW.PollNeed,x
                    bra       PgNext
PgDone              andcc     #^Carry
                    puls      y,u,pc

* PollStep - a response is owed: collect it if it is here, process it, and (A non-zero) send the
* next OP_SERREAD. Keep an incomplete response owed even during IRQ backoff:
* forgetting it lets late poll bytes become the next sector header/data.
PollStep            pshs      a
                    ldx       <D.DWStat
                    lbsr      PollGet
                    bcs       PollOwed
                    lda       DW.PollSt,x
                    clr       DW.PollSt,x
                    cmpa      #2
                    beq       PollDoneM2
                    ldd       DW.PollResp,x
                    lbsr      PollProc            may send OP_SERREADM (state 2 again)
PollNext            ldx       <D.DWStat
                    tst       DW.PollSt,x
                    bne       PollX
                    tst       ,s
                    beq       PollX
                    lbsr      PollSend
PollX               puls      a,pc
PollDoneM2          lbsr      PollDoneM
                    bra       PollNext
PollOwed            tst       ,s                  A=0: Settle owns its timed wait budget
                    beq       PollX
                    inc       DW.PollTk,x
                    lda       DW.PollTk,x
                    cmpa      #POLL_STALL
                    blo       PollX
                    clr       DW.PollTk,x
                    lda       #POLL_HOLD
                    sta       DW.PollHold,x       back off WITHOUT discarding the owed reply
                    bra       PollX

* PollPurge - the RX FIFO reset strobe, a short drain, no response owed, POLL_HOLD firings of quiet.
PollPurge           lda       #%11000011          FCR: RX FIFO reset (self-clearing); bit 0 keeps the FIFOs on
                    sta       UART.Base+UART_FCR
                    ldy       #POLL_DRAIN
PpLoop              lda       UART.Base+UART_LSR
                    bita      #LSR_DATA_AVAIL
                    beq       PpNext
                    lda       UART.Base+UART_TRHB
PpNext              leay      -1,y
                    bne       PpLoop
                    ldx       <D.DWStat
                    clr       DW.PollSt,x
                    clr       DW.PollNeed,x
                    clr       DW.PollTk,x
                    lda       #POLL_HOLD
                    sta       DW.PollHold,x
                    rts

* Settle (DW$Settle) - a process acquires the link: mark it busy so the tick poll keeps off the
* UART, then collect any poll response still owed so the first byte the caller reads is its own.
* Sleeps a tick between looks with interrupts on (the keyboard lives); a server that never answers
* costs SETTLE_TRIES ticks once, then the line is reset and the poll backs off.
* Exit: DW.LinkBusy = 1, all registers preserved.  The caller clears DW.LinkBusy when it is done.
Settle              pshs      d,x,y,u,cc
                    ldx       <D.DWStat
                    lda       #1
                    sta       DW.LinkBusy,x
                    ldb       #SETTLE_TRIES
SetLook             tst       DW.PollSt,x
                    beq       SetDone
                    pshs      b,cc
                    orcc      #IntMasks
                    clra                          no request from here
                    lbsr      PollStep
                    puls      b,cc
                    ldx       <D.DWStat
                    tst       DW.PollSt,x
                    beq       SetDone
                    decb
                    beq       SetStall
                    pshs      b
                    ldx       #2                  one timed tick; X=1 only yields
                    os9       F$Sleep
                    puls      b
                    ldx       <D.DWStat
                    bra       SetLook
SetStall            lbsr      PollPurge
SetDone             puls      d,x,y,u,cc,pc
                    endc

* IRQ set freq routine
* sets freq and clears NOP counter
* a = desired IRQ freq
IRQsetFRQ           pshs      x                   ; preserve
                    ifgt      Level-1
                    ldx       <D.DWStat
                    else
                    ldx       >D.DWStat
                    endc
                    sta       DW.VIRQPkt+Vi.Rst+1,x
* +++ BGP +++ added following line so that the counter (which was copied by
* clock before calling us) gets reset to the same value the reset value. Without
* this line, we get called again with the PRIOR Vi.Rst value.
                    sta       DW.VIRQPkt+Vi.Cnt+1,x
                    clr       DW.VIRQNOP,x
                    puls      x
                    rts


* This routine roots through process descriptors in a queue and
* checks to see if the process has a path that is open to the device
* represented by the static storage pointer in U. If so, set the Condem
* bit of the P$State of that process.
*
* Note: we start with path 0 and continue until we get to either (a) the
* last path for that process or (b) a hit on the static storage that we
* are seeking.
*
* Entry: X = process descriptor to evaluate
*        U = static storage of device we want to check against
RootThrough
                    clrb
                    leay      P$Path,x
                    pshs      x
loop                cmpb      #NumPaths
                    beq       out
                    incb
                    lda       ,y+
                    beq       loop
                    pshs      y
                    ifgt      Level-1
                    ldx       <D.PthDBT
                    else
                    ldx       >D.PthDBT
                    endc
                    os9       F$Find64
                    ldx       PD.DEV,y
                    leax      V$STAT,x
                    puls      y
                    bcs       loop                +BGP+ Jul 20, 2012: continue even if error in F$Find64

                    cmpu      ,x
                    bne       loop

                    ldx       ,s

                    ldb       #S$HUP
                    stb       P$Signal,x
                    os9       F$AProc

*			lda   	P$State,x		get state of recipient
*			ora   	#Condem			set condemn bit
*			sta   	P$State,x		and set it back

out                 puls      x
                    ldx       P$Queue,x
                    bne       RootThrough
                    rts

statcont            clrb
                    tfr       d,u
* NEW: root through all process descriptors. if any has a path open to this
* device, condem it
                    ldx       <D.AProcQ
                    beq       dowaitq
                    bsr       RootThrough
dowaitq             ldx       <D.WProcQ
                    beq       dosleepq
                    bsr       RootThrough
dosleepq            ldx       <D.SProcQ
                    beq       CkLPRC
                    bsr       RootThrough

CkLPRC
                    lda       <V.LPRC,u
                    beq       IRQExit             ; no last process, bail
                    ldb       #S$HUP
                    os9       F$Send              ; send signal, don't think we can do anything about an error result anyway.. so
                    bra       CkSuspnd            ; do we need to go check suspend?

; put byte B in port As buffer - optimization help from Darren Atkinson
IRQPutCh
                    ;         set                 IRQ freq for bulk
                    lda       PollSpd1,pcr
                    bsr       IRQsetFRQ
                    ldx       RxBufPut,u          ; point X to the data buffer

; process interrupt/quit characters here
; note we will have to do this in the multiread (ugh)
                    tfr       b,a                 ; put byte in A
                    ldb       #S$Intrpt
                    cmpa      V.INTR,u
                    beq       send@
                    ldb       #S$Abort
                    cmpa      V.QUIT,u
                    bne       store
send@               lda       V.LPRC,u
                    beq       IRQExit
                    os9       F$Send
                    bra       IRQExit

store
                    ;         store               our data byte
                    sta       ,x+                 ; store and increment buffer pointer

                    ;         adjust              RxBufPut
                    cmpx      RxBufEnd,u          ; end of Rx buffer?
                    blo       IRQSkip1            ; no, go keep laydown pointer
                    ldx       RxBufPtr,u          ; get Rx buffer start address
IRQSkip1            stx       RxBufPut,u          ; set new Rx data laydown pointer

                    ;         increment           RxDatLen
                    inc       RxDatLen,u

CkSSig
                    lda       <SSigID,u           ; send signal on data ready?
                    beq       CkSuspnd
                    ldb       <SSigSg,u           ; else get signal code
                    os9       F$Send
                    clr       <SSigID,u
                    bra       IRQExit

                    ;         check               if we have a process waiting for data
CkSuspnd
                    lda       <V.WAKE,u           ; V.WAKE?
                    beq       IRQExit             ; no
                    clr       <V.WAKE,u           ; clear V.WAKE

                    ;         wake                up waiter for read
                    ifeq      Level-1
                    ldb       #S$Wake
                    os9       F$Send
                    else
                    clrb
                    tfr       d,x                 ; copy process descriptor pointer
                    lda       P$State,x           ; get state flags
                    anda      #^Suspend           ; clear suspend state
                    sta       P$State,x           ; save state flags
                    endc

IRQExit
IRQExit2            puls      cc,dp,pc            ; restore interrupts cc,dp, return

                    emod
eom                 equ       *
                    end
