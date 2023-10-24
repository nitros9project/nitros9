********************************************************************
* scdwv - DriveWire Virtual Channel Driver
*
* $Id$
*
* How this wildcard /N stuff works:
* A process interested in obtaining a path to a network device
* can open any /Nx descriptor but it may be in use by another process.
* The safest way to obtain a new network device is to open the wildcard
* descriptor /N. This works similarly to the way /W works in the CoCo 3
* VTIO driver.
*
* When /N is open, the INIT routine is called but most of it is bypassed
* because it detects the wildcard device (which has an address of $FFFF).
*
* The SS.Open I$SetStat entry point is called. That routine also detects
* the wildcard is used, so the hunt is on for the next available /Nx
* descriptor (it does this by checking the DW static storage for each /Nx
* in the DW static storage page).  If it finds a free page, it notes the
* offset as a number, then builds a descriptor name (ex: /N4) and then
* F$Links to it.  It then takes the descriptor module address and sticks it
* in the device table entry for /N.  It also takes the V.PORT address and sticks
* it in the static storage memory allocated for /N.
* Afer that, SS.Open does something really sneaky: it branches into the
* Init routine which detects via the static storage that this is not a /N
* descriptor but a /N4 descriptor.  Init then sends the SERINIT and initializes
* the DW static storage for /N4.  Control is returned to the SS.Open code which
* then advertises the SS.Open to the server.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2009/11/30  Aaron Wolfe
* Started
*
*          2009/12/28  Boisy G. Pitre
* Modified so that F$STime is called if we get an error on calling
* F$VIRQ (which means the clock module has not be initialized)
*
*          2009/12/31  Boisy G. Pitre
* Fixed crash in Init where F$Link failure would not clean up stack
*
*          2010/01/03  Boisy G. Pitre
* Moved IRQ stuff into DW3 subroutine module
*
*   2      2010/01/23  Boisy G. Pitre
* Added code in SS.Open to use /N wildcard device (tricky stuff!)
*
*		   2010/05/28  Aaron Wolfe
* Added FASTSERWRITE support
*
                    nam       scdwv
                    ttl       DriveWire Network Driver

                    ifp1
                    use       defsfile
                    use       drivewire.d
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+Rev
rev                 set       $00
edition             set       2

* Note: driver memory defined in dwdefs.d
                    mod       eom,name,tylg,atrv,start,SCFDrvMemSz

* module info
                    fcb       UPDAT.+SHARE.       ;driver access modes
name                fcs       /scdwv/             ;driver name
                    fcb       edition             ;driver edition

* dispatch calls
start               equ       *
                    lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat

***********************************************************************
* Term
*
* shut down the driver.
* should close only the correct port, tell server to close the port,
* and remove irq handler when no ports are left
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
Term                equ       *
                    lda       <V.PORT+1,u         get our port #
                    bmi       termbye             if this is wildcard, skip TERM
                    pshs      a                   port # on stack
* clear statics table entry
                    ifgt      Level-1
                    ldx       <D.DWStat
                    else
                    ldx       >D.DWStat
                    endc
                    beq       tell
* cheat: we know DW.StatTbl is at offset $00 from D.DWStat, do not bother with leax
*	           leax      DW.StatTbl,x
                    clr       a,x                 clear out

* tell server
tell
                    lda       #OP_SERTERM         load command
                    pshs      a                   command store on stack
                    leax      ,s                  point X to stack
                    ldy       #2                  2 bytes to send

                    pshs      u

                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    beq       nosub
                    jsr       6,u                 call DWrite

nosub
                    puls      u
                    leas      2,s                 clean 3 DWsub args from stack
termbye             clrb
                    rts

***********************************************************************
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

Init                equ       *

; link to subroutine module
; has the link already been done?
                    ifgt      Level-1
                    ldx       <D.DWSubAddr
                    else
                    ldx       >D.DWSubAddr
                    endc
                    bne       already             ; if so, do not bother

                    pshs      u                   ; preserve u since os9 link is coming up

                    ifgt      Level-1
                    ldx       <D.Proc
                    pshs      x
                    ldx       <D.SysPrc
                    stx       <D.Proc
                    endc
                    clra

                    leax      dwioname,pcr
                    os9       F$Link
                    ifgt      Level-1
                    puls      x
                    stx       <D.Proc
                    endc
                    bcs       InitEx2
                    ifgt      Level-1
                    sty       <D.DWSubAddr
                    else
                    sty       >D.DWSubAddr
                    endc
                    jsr       ,y                  ; call DW init routine

                    puls      u                   ; restore u

already
; tell DW we have a new port opening (port mode already on stack)
                    ldb       <V.PORT+1,u         ; get our port #
* if /N wildcard, skip advertising via SERINIT
                    bmi       initEx
                    lda       #OP_SERINIT         ; command
                    pshs      d                   ; command + port # on stack
                    leax      ,s                  ; point X to stack
                    ldy       #2                  ; # of bytes to send

                    pshs      u
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       6,u                 ; call DWrite
                    puls      u

; set up local buffer
                    ldb       #RxBufDSz           ; default Rx buffer size
                    leax      RxBuff,u            ; default Rx buffer address
                    stb       RxBufSiz,u          ; save Rx buffer size
                    stx       RxBufPtr,u          ; save Rx buffer address
                    stx       RxBufGet,u          ; set initial Rx buffer input address
                    stx       RxBufPut,u          ; set initial Rx buffer output address
                    abx                           ; add buffer size to buffer start..
                    stx       RxBufEnd,u          ; save Rx buffer end address

                    tfr       u,d                 ; (A = high page of statics)
                    puls      b
                    puls      b                   ; (B = port number)
                    ifgt      Level-1
                    ldx       <D.DWStat
                    else
                    ldx       >D.DWStat
                    endc
; cheat: we know DW.StatTbl is at offset $00 from D.DWStat, do not bother with leax
;		leax      DW.StatTbl,x
                    sta       b,x
InitEx              equ       *
                    rts
InitEx2
                    puls      u
                    rts

; drivewire info
dwioname            fcs       /dwio/


*****************************************************************************
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
*
Write               equ       *
                    pshs      a                   ; character to send on stack
                    lda       <V.PORT+1,u         ; port number into a
                    adda      #128                ; add base of command into A
                    pshs      a
                    leax      ,s
                    ldy       #$0002              ; 3 bytes to send.. ugh.  need WRITEM (data mode)
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       6,u
WriteOK             clrb
WriteExit           puls      x,pc                ; clean stack, return


NotReady            comb
                    ldb       #E$NotRdy
                    rts

*************************************************************************************
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
Read                equ       *
* Check to see if there is a signal-on-data-ready set for this path.
* If so, we return a Not Ready error.
                    lda       <SSigID,u           data ready signal trap set up?
                    bne       NotReady            yes, exit with not ready error
                    pshs      cc,dp               ; save IRQ/Carry status, system DP

ReadChr             orcc      #IntMasks           ; mask interrupts

                    lda       RxDatLen,u          ; get our Rx buffer count
                    beq       ReadSlp             ; no data, go sleep while waiting for new Rx data...

                    ;         we                  have data waiting
                    deca                          ; one less byte in buffer
                    sta       RxDatLen,u          ; save new Rx data count

                    ldx       RxBufGet,u          ; current Rx buffer pickup position
                    lda       ,x+                 ; get Rx character, set up next pickup position

                    cmpx      RxBufEnd,u          ; end of Rx buffer?
                    blo       ReadChr1            ; no, keep pickup pointer
                    ldx       RxBufPtr,u          ; get Rx buffer start address
ReadChr1            stx       RxBufGet,u          ; set new Rx data pickup pointer

                    ;         return              to caller
                    puls      cc,dp,pc            ; recover IRQ/Carry status, system DP, return with character in A

ReadSlp             equ       *

                    ifeq      Level-1
ReadSlp2            lda       <V.BUSY,u
                    sta       <V.WAKE,u           ; store process id in this port's entry in the waiter table
                    lbsr      Sleep0              ; sleep level 1 style
                    else
ReadSlp2            lda       >D.Proc             ; process descriptor address MSB
                    sta       <V.WAKE,u           ; save MSB in V.WAKE
                    clrb
                    tfr       d,x                 ; process descriptor address
                    ifne      H6309
                    oim       #Suspend,P$State,x  ; suspend
                    else
                    ldb       P$State,x
                    orb       #Suspend
                    stb       P$State,x           ; suspend
                    endc
                    bsr       Sleep1              ; sleep level 2 style
                    endc

                    ;         we                  have been awakened..

                    ;         check               for signals
                    ldx       >D.Proc             ; process descriptor address
                    ldb       P$Signal,x          ; pending signal for this process?
                    beq       ChkState            ; no, go check process state...
                    cmpb      #S$HUP              ; (S$HUP or lower)
                    bls       ErrExit             ; yes, go do it...

ChkState            equ       *
                    ;         have                we been condemned to die?
                    ifne      H6309
                    tim       #Condem,P$State,x
                    else
                    ldb       P$State,x
                    bitb      #Condem
                    endc
                    bne       PrAbtErr            ; yes, go do it...

                    ;         check               that our waiter byte was cleared by ISR instance
                    tst       <V.WAKE,u           ; our waiter byte
                    beq       ReadChr             ; 0 = its our turn, go get a character
                    bra       ReadSlp             ; false alarm, go back to sleep

PrAbtErr            ldb       #E$PrcAbt           ; set error code

ErrExit             equ       *
                    ifne      H6309
                    oim       #Carry,,s           ; set carry
                    else
                    lda       ,s
                    ora       #Carry
                    sta       ,s
                    endc
                    puls      cc,dp,pc            ; restore CC, system DP, return

                    ifeq      Level-1
Sleep0              ldx       #$0                 ; sleep till ISR wakes us
                    bra       TimedSlp
                    endc

Sleep1              ldx       #$1                 ; just sleep till end of slice, we are suspended (level 2)
TimedSlp            andcc     #^Intmasks          ; enable IRQs
                    os9       F$Sleep
                    clr       <V.WAKE,u
                    rts                           ; return


**********************************************************************
* GetStat - heavily borrowed from sc6551
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
GetStat
                    clrb                          ; default to no error...
                    pshs      cc,dp               ; save IRQ/Carry status,system DP

                    ldx       PD.RGS,y            ; caller's register stack pointer
                    cmpa      #SS.EOF
                    beq       GSExitOK            ; SCF devices never return EOF

                    cmpa      #SS.Ready
                    bne       Advertise           ; next check

                    ;         SS.Ready
                    lda       RxDatLen,u          ; get Rx data length
                    beq       NRdyErr             ; none, go report error
                    sta       R$B,x               ; set Rx data available in caller's [B]
GSExitOK            puls      cc,dp,pc            ; restore Carry status, system DP, return

NRdyErr             ldb       #E$NotRdy
                    bra       ErrExit             ; return error code

UnSvcErr            ldb       #E$UnkSvc
                    bra       ErrExit             ; return error code

; We advertise all of our SERGETSTAT calls (except SS.Ready) to the server
Advertise
                    ldb       #OP_SERGETSTAT
                    bsr       SendStat

; Note: Here we could somehow obtain the size of the terminal window from the server
GetScSiz            cmpa      #SS.ScSiz
                    bne       GetComSt            ; next check
                    ldu       PD.DEV,y
                    ldu       V$DESC,u            ; device descriptor
                    clra
                    ldb       IT.COL,u            ; return screen size
                    std       R$X,x
                    ldb       IT.ROW,u
                    std       R$Y,x
                    puls      cc,dp,pc            ; restore Carry status, system DP, return

GetComSt            cmpa      #SS.ComSt
                    bne       GetKySns            ; no, we have no more answers, report error
                    ldd       #$0000              ; not used, return $0000
                    std       R$Y,x
                    sta       R$B,x
                    puls      cc,dp,pc            ; restore Carry status, system DP, return

GetKySns
                    cmpa      #SS.KySns
                    bne       GetSSMntr           ; no, we have no more answers, report error
* Get key sense byte from server and return to caller
                    pshs      a,x,u
                    leax      ,s
                    ldy       #$001
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    jsr       DW$Read,u
                    endc
                    puls      a,x,u
                    sta       R$A,x
                    puls      cc,dp,pc            ; restore Carry status, system DP, return

GetSSMntr           cmpa      #SS.Montr
                    bne       UnSvcErr            ; no, we have no more answers, report error
                    ldd       #$0001
                    std       R$X,x
                    puls      cc,dp,pc            ; restore Carry status, system DP, return

* Advertise Stat Code to server
* A = Function Code
* B = OP_SERGETSTAT or OP_SERSETSTAT
SendStat
; advertise our GetStt code to the server
                    pshs      a,y,x,u
                    leas      -3,s
                    leax      ,s
                    stb       ,x
                    sta       2,x
                    ldb       V.PORT+1,u
                    stb       1,x
                    ldy       #$0003
                    ifgt      LEVEL-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       DW$Write,u
                    leas      3,s
                    puls      a,y,x,u,pc

*************************************************************************
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
*
SetStat
                    cmpa      #SS.Open
                    bne       isitcomst
                    bsr       open
                    bcs       ssbye
                    ldd       #SS.Open*256+OP_SERSETSTAT
                    bra       SendStat
isitcomst
                    ldb       #OP_SERSETSTAT
                    bsr       SendStat
                    cmpa      #SS.ComSt
                    beq       comst
                    cmpa      #SS.Close
                    beq       ex
                    cmpa      #SS.SSig
                    beq       ssig
                    cmpa      #SS.Montr
                    beq       ex
                    cmpa      #SS.Relea
                    bne       donebad
relea               lda       PD.CPR,y            get curr proc #
                    cmpa      <SSigID,u           same?
                    bne       ex
                    clr       <SSigID,u           clear process id
ex                  rts
sskysns
                    rts
ssig                pshs      cc
                    orcc      #IntMasks
                    lda       PD.CPR,y            ; get curr proc #
                    ldx       PD.RGS,y
                    ldb       R$X+1,x             ; get user signal code
                    tst       RxDatLen,u          ; get Rx data length
                    beq       ssigsetup           ; branch if no data in buffer
* if here, we have data so send signal immediately
                    os9       F$Send
                    puls      cc,pc
ssigsetup           std       <SSigID,u           ; save process ID & signal
                    puls      cc,pc

donebad             comb
                    ldb       #E$UnkSvc
                    rts

comst               leax      PD.OPT,y
                    ldy       #OPTCNT
                    ifgt      LEVEL-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       DW$Write,u
                    clrb
ssbye               rts

* SS.Open processor
* Entry: X=Register stack pointer
*        U=Static memory pointer
*        Y=Path descriptor pointer
open                tst       <V.PORT+1,u         check if this is $FFFF (wildcard)
                    bpl       ssbye               if not, we have nothing to do
                    pshs      u,y                 preserve registers
                    ldx       PD.DEV,y            get pointer to device table entry
                    ldx       V$DESC,x            get pointer to /N descriptor
                    pshs      x                   save device descriptor pointer
* start at /N1
                    ldb       #1
L0B58               equ       *
                    ifgt      Level-1
                    ldx       <D.DWStat
                    else
                    ldx       >D.DWStat
                    endc
; cheat: we know DW.StatTbl is at offset $00 from D.DWStat, do not bother with leax
;		leax      DW.StatTbl,x
next                cmpb      #DW.StatCnt
                    bge       opexer
                    tst       b,x
                    beq       found
                    incb
                    bra       next
opexer              comb                          set carry
                    ldb       #E$MNF              get module not found error
                    puls      x,y,u,pc            purge stack and return

* Found a free spot
found               pshs      b                   save # of free entry
                    leas      -5,s
                    leay      ,s
                    ldb       #'N                 get netdev name prefix
                    stb       ,y+                 put it in buffer
                    ldb       5,s                 get netdev # that was free
* Convert netdev # in B to ASCII eqivalent with high bit set

                    ifne      H6309
                    clra
                    divd      #10                 divide it by 10
                    else
                    lda       #-1
L0B87b              inca
                    subb      #10
                    bcc       L0B87b
                    addb      #10
                    exg       a,b
                    cmpb      #0
                    endc
                    beq       L0B87               if answer is 0 there is only 1 digit, skip ahead
                    orb       #$30                make first digit ASCII
                    stb       ,y+                 put it in buffer
L0B87               ora       #$B0                make remainder ASCII with high bit set
                    sta       ,y+                 put it in buffer
L0B92               leas      -2,s                make a buffer for process decriptor pointer
                    ifgt      Level-1
                    lbsr      L0238               switch to system process descriptor
                    endc
                    leax      2,s                 Point to calculated dsc. name
                    lda       #Devic+Objct        get module type
                    os9       F$Link              try & link it
                    ifgt      Level-1
                    lbsr      L0244               switch back to current process
                    endc
                    leas      7,s                 purge stack
                    bcc       L0BAB               it's linked, skip ahead
L0BA7               puls      b                   get original number
                    incb
                    bra       L0B58               go find another free space

                    ifgt      Level-1
* Switch to system process descriptor
L0238               pshs      d                   Preserve D
                    ldd       <D.Proc             Get current process dsc. ptr
                    std       4,s                 Preserve on stack
                    ldd       <D.SysPrc           Get system process dsc. ptr
                    std       <D.Proc             Make it the current process
                    puls      d,pc                Restore D & return

* Switch back to current process
L0244               pshs      d                   Preserve D
                    ldd       4,s                 Get current process ptr
                    std       <D.Proc             Make it the current process
                    puls      d,pc                Restore D & return
                    endc

* Got a device descriptor, put into device table & save netdev # into static
L0BAB
                    lda       M$PORT+2,u          get MSB of port byte of newly linked /N? descriptor
                    ldy       3,s                 get path descriptor pointer
                    ldx       PD.DEV,y            get pointer to device table
                    stu       V$DESC,x            save pointer to descriptor into it
                    ldu       1,s                 get pointer to /N descriptor
                    os9       F$UnLink            unlink it from system map
                    ldu       5,s                 get static mem pointer
                    sta       V.PORT+1,u
                    leas      7,s                 purge stack
* Load Y with address of descriptor and U with address of memory area
                    ldy       V$DESC,x
                    pshs      x,y,u
                    lbsr      Init                call Init to setup dw statics
                    puls      x,y,u,pc

                    emod
eom                 equ       *
                    end
