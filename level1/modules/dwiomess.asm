********************************************************************
* dwio - DriveWire I/O Subroutine Module - MESS version
*
* $Id$
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
*   4     2010/04/27   Aaron A. Wolfe
* hacked to use MESS FIFO routines
*
*
                    nam       dwio
                    ttl       DriveWire I/O Subroutine Module - MESS version

                    ifp1
                    use       defsfile
                    use       dwdefs.d
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


name                fcs       /dwio/

* DriveWire subroutine entry table
start               lbra      Init
                    bra       Read
                    nop
                    lbra      Write

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

* Read
*
*  ON ENTRY:
*    X = ADDRESS OF THE RECEIVE BUFFER
*    A = TIMEOUT VALUE (182 = APPROX ONE SECOND @ 0.89 MHz)
*
*  ON EXIT:
*    Y = DATA CHECKSUM
*    D = ACTUAL NUMBER OF BYTES RECEIVED
*    X AND U ARE PRESERVED
*    CC.CARRY IS SET IF A FRAMING ERROR WAS DETECTED
*
Read
                    use       dwrdmess.asm

* Write
*
* Entry:
Write
                    use       dwwrmess.asm

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
                    orcc      #IntMasks
* no init for bitbanger in mess
*               ldx       #PIA1Base           $FF20
*               clr       1,x                 clear CD
*               lda       #%11111110
*               sta       ,x
*               lda       #%00110100
*               sta       1,x
*               lda       ,x

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
                    ;         setup               DWsub command
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
                    jsr       6,u                 ; call DWrite
                    leas      1,s                 ; leave one byte on stack for response

                    ;         read                protocol version response, 1 byte
                    leax      ,s                  ; point X to stack head
                    ldy       #1                  ; 1 byte to retrieve
                    jsr       3,u                 ; call DWRead
                    beq       InstIRQ             ; branch if no error
                    leas      3,s                 ; error, cleanup stack (u and 1 byte from read)
                    lbra      InitEx              ; don't install IRQ handler

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
                    jsr       6,u                 ; call DWrite

                    leas      3,s                 ; clean 3 DWsub args from stack

                    ldx       ,s                  ; pointer to this port's area (from U prior), leave it on stack
                    ldb       RxGrab,x            ; set B to grab bytes
                    clra                          ; 0 in high byte
                    tfr       d,y                 ; set # bytes for DW

                    ldx       RxBufPut,x          ; point X to insert position in this port's buffer
                    ;         receive             response
                    jsr       3,u                 ; call DWRead
                    ;         handle              errors?


                    puls      u
                    ldb       RxGrab,u            ; our grab bytes

                    ;         set                 new RxBufPut
                    ldx       RxBufPut,u          ; current write pointer
                    abx                           ; add b (# bytes) to RxBufPut
                    cmpx      RxBufEnd,u          ; end of Rx buffer?
                    blo       IRQM04              ; no, go keep laydown pointer
                    ldx       RxBufPtr,u          ; get Rx buffer start address
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
                    bne       IRQMulti3           ; continue, we have some space in buffer
                    ;         no                  room in buffer
                    tstb
                    lbne      CkSSig              ;had to lbra
                    lbra      IRQExit             ;had to lbra


; **** IRQ ENTRY POINT
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
                    jsr       6,u                 ; call DWrite

                    ;         receive             response
                    leas      -1,s                ; one more byte to fit response
                    leax      ,s                  ; point X to stack head
                    ldy       #2                  ; 2 bytes to retrieve
                    jsr       3,u                 ; call DWRead
                    beq       IRQSvc2             ; branch if no error
                    leas      2,s                 ; error, cleanup stack 2
                    lbra      IRQExit2            ; don't reset error count on the way out

                    ;         process             response
IRQSvc2
                    ldd       ,s++                ; pull returned status byte into A,data into B (set Z if zero, N if multiread)
                    bne       IRQGotOp            ; branch if D != 0 (something to do)
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
IRQGotOp            pshs      d
                    *         mode                switch on bits 7+6 of A: 00 = vserial, 01 = system, 10 = wirebug?, 11 = ?
                    anda      #$C0                ; mask last 6 bits
                    beq       mode00              ; virtual serial mode
                    ;         future              - handle other modes
                    lbra      IRQExit             ; for now, bail

mode00              lda       ,s                  ; restore A
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
                    beq       IRQPutch            ; branch for read1 if multiread not set

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
                    bne       statcont            ; if A is 0, then this device is not active, so exit
                    lbra      IRQExit

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
* represented by the static storage pointer in U. if so, the S$HUP
* signal is sent to that process
*
* Entry: X = process descriptor to evaluate
*        U = static storage of device we want to check against
RootThrough
                    ldb       #NumPaths
                    leay      P$Path,x
                    pshs      x
loop                decb
                    bmi       out
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
                    bcs       out

                    cmpu      ,x
                    bne       loop

                    ldx       ,s
                    lda       P$ID,x
                    ldb       #S$HUP
                    os9       F$Send

out                 puls      x
                    ldx       P$Queue,x
                    bne       RootThrough
                    rts

statcont            clrb
                    tfr       d,u
* NEW: root through all process descriptors. if any has a path open to this
* device, send then S$HUP
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
                    lbsr      IRQsetFRQ
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
