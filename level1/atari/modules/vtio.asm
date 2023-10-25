********************************************************************
* VTIO - NitrOS-9 Video Terminal I/O driver for Atari XE/XL
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  1       2012/02/20  Boisy G. Pitre
* Started from VTIO for the Atari XE/XL

                    nam       VTIO
                    ttl       NitrOS-9 Video Terminal I/O driver for Atari XE/XL

                    ifp1
                    use       defsfile
                    use       atarivtio.d
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

size                equ       V.Last

                    fcb       UPDAT.+EXEC.

name                fcs       /VTIO/
                    fcb       edition

start               lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term


* The display list sets up the ANTIC chip to display the main screen.
* It is copied to the Atari Screen Area in low memory (see atari.d)
* The size of this code MUST be <= G.DListSize
*DList
*		fcb	$70,$70,$70	3 * 8 blank scanlines
*		fcb	$42			Mode 2 with LMS (Load Memory Scan).  Mode 2 = 40 column hires text, next 2 bytes L/H determine screen origin
*		fdbs	G.ScrStart+(G.Cols*0)		origin
*		fcb	2,2,2,2,2,2,2,2,2,2
*		fcb	2,2,2,2,2,2,2,2,2,2
*		fcb	2,2,2
* 23 extra mode 2 lines for total of 24.  240 scanlines can be used for display area, but a hires line cannot be on scanline 240 due to an Antic bug
*		fcb	$41			this is the end of Display List command JVB (Jump and wait for Vertical Blank)
*         	fdb  $0000
*DListSz	equ	*-DList

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
Init
                    stu       >D.KbdSta           store devmem ptr
                    pshs      u

                    leax      ChkSpc,pcr
                    stx       V.EscVect,u

* setup static vars
                    clra
                    clrb
                    std       V.CurRow,u

* Clear screen memory
                    ldy       #G.ScrEnd
                    pshs      y
                    ldy       #G.ScrStart
                    ldd       #$0000
clearLoop@
                    std       ,y++
                    cmpy      ,s
                    bne       clearLoop@
                    puls      u                   G.DList address is aleady in U

* copy the display list into our memory area to the global location in low RAM
*		leax	DList,pcr
*		ldy	#DListSz
*dlcopy@
*		ldd	,x++
*		std	,u++
*		leay	-2,y
*		bne	dlcopy@
* patch last word to be address of start of DList (byte swap for ANTIC)
*		leau	-DListSz,u
*		tfr	u,d
*		exg	a,b
*		std	DListSz-2,u

* tell the ANTIC where the dlist is
*		std	DLISTL

* tell the ANTIC where the character set is (page aligned, currently in Krn)
*		lda	#G.CharSetAddr>>8
*		sta	CHBASE

* set background color
                    clra
                    sta       COLBK

* set text color
                    lda       #$0F
                    sta       COLPF1
                    lda       #$94
                    sta       COLPF2

* tell ANTIC to start DMA
*		lda	#$22
* 		sta	DMACTL

* tell ANTIC to enable character set 2
*		lda	#$02
* 		sta	CHACTL

* install keyboard ISR
                    ldd       #IRQST              POKEY IRQ status address
                    leay      IRQSvc,pcr          pointer to our service routine
                    leax      IRQPkt,pcr          F$IRQ requires a 3 byte packet
                    ldu       ,s                  use our saved devmem as ISR static
                    os9       F$IRQ               install the ISR
                    bcs       initex

* set POKEY to active
                    lda       #$13
                    sta       SKCTL

* tell POKEY to enable keyboard scanning
                    lda       #(IRQST.BREAKDOWN|IRQST.KEYDOWN)
                    pshs      cc
                    orcc      #IntMasks
                    ora       >D.IRQENSHDW
                    sta       >D.IRQENSHDW
                    puls      cc
                    sta       IRQEN

* clear carry and return
                    clrb
initex              puls      u,pc


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
* clear carry and return
                    clrb
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
Read
                    leax      V.InBuf,u           point X to input buffer
                    ldb       V.IBufT,u           get tail pointer
                    orcc      #IRQMask            mask IRQ
                    cmpb      V.IBufH,u           same as head pointer
                    beq       Put2Bed             if so, buffer is empty, branch to sleep
                    abx                           X now points to curr char
                    lda       ,x                  get char
                    bsr       cktail              check for tail wrap
                    stb       V.IBufT,u           store updated tail
                    andcc     #^(IRQMask+Carry)   unmask IRQ
                    rts

Put2Bed             lda       V.BUSY,u            get calling process ID
                    sta       V.WAKE,u            store in V.WAKE
                    andcc     #^IRQMask           clear interrupts
                    ldx       #$0000
                    os9       F$Sleep             sleep forever
                    clr       V.WAKE,u            clear wake
                    ldx       <D.Proc             get pointer to current proc desc
                    ldb       <P$Signal,x         get signal recvd
                    beq       Read                branch if no signal
                    cmpb      #S$Window           window signal?
                    bcc       Read                branch if so
                    coma
                    rts
* Check if we need to wrap around tail pointer to zero
cktail              incb                          increment pointer
                    cmpb      #KBufSz-1           at end?
                    bls       readex              branch if not
* clear carry and return
                    clrb                          else clear pointer (wrap to head)
readex              rts


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
Write
                    bsr       hidecursor
                    ldx       V.EscVect,u
                    jsr       ,x
                    bra       drawcursor

ChkSpc              cmpa      #C$SPAC             space or greater?
                    bcs       ChkESC              branch if not

wchar               suba      #$20
                    pshs      a
                    lda       V.CurRow,u
                    ldb       #G.Cols
                    mul
                    addb      V.CurCol,u
                    adca      #0
                    ldx       #G.ScrStart
                    leax      d,x
                    puls      a
                    sta       ,x
                    ldd       V.CurRow,u
                    incb
                    cmpb      #G.Cols
                    blt       ok
                    clrb
incrow
                    inca
                    cmpa      #G.Rows
                    blt       clrline
SCROLL              equ       1
                    ifne      SCROLL
                    deca                          set A to G.Rows - 1
                    pshs      d                   save off Row/Col
                    ldx       #G.ScrStart         get start of screen memory
                    ldy       #G.Cols*(G.Rows-1)  set Y to size of screen minus last row
scroll_loop
                    ldd       G.Cols,x            get two bytes on next row
                    std       ,x++                store on this row
                    leay      -2,y                decrement Y
                    bne       scroll_loop         branch if not 0
                    puls      d                   recover Row/Col
                    else
                    clra
                    endc
* clear line
clrline             std       V.CurRow,u
                    bsr       DelLine
                    rts
ok                  std       V.CurRow,u
ret                 rts

* calculates the cursor location in screen memory
* Exit: X = address of cursor
*       All other regs preserved
calcloc
                    pshs      d
                    lda       V.CurRow,u
                    ldb       #G.Cols
                    mul
                    addb      V.CurCol,u
                    adca      #0
                    ldx       #G.ScrStart
                    leax      d,x
                    puls      d,pc

drawcursor
                    bsr       calcloc
                    lda       ,x
                    sta       V.CurChr,u
                    lda       #$80
                    sta       ,x
                    rts

hidecursor
                    pshs      a
                    bsr       calcloc
                    lda       V.CurChr,u
                    sta       ,x
                    puls      a,pc

ChkESC
                    cmpa      #$1B                ESC?
                    lbeq      EscHandler
                    cmpa      #$0D                $0D?
                    bhi       ret                 branch if higher than
                    leax      <DCodeTbl,pcr       deal with screen codes
                    lsla                          adjust for table entry size
                    ldd       a,x                 get address in D
                    jmp       d,x                 and jump to routine

* display functions dispatch table
DCodeTbl            fdb       NoOp-DCodeTbl       $00:no-op (null)
                    fdb       CurHome-DCodeTbl    $01:HOME cursor
                    fdb       CurXY-DCodeTbl      $02:CURSOR XY
                    fdb       DelLine-DCodeTbl    $03:ERASE LINE
                    fdb       ErEOLine-DCodeTbl   $04:CLEAR TO EOL
                    fdb       Do05-DCodeTbl       $05:CURSOR ON/OFF
                    fdb       CurRght-DCodeTbl    $005e  $06:CURSOR RIGHT
                    fdb       NoOp-DCodeTbl       $07:no-op (bel:handled in VTIO)
                    fdb       CurLeft-DCodeTbl    $08:CURSOR LEFT
                    fdb       CurUp-DCodeTbl      $09:CURSOR UP
                    fdb       CurDown-DCodeTbl    $0A:CURSOR DOWN
                    fdb       ErEOScrn-DCodeTbl   $0B:ERASE TO EOS
                    fdb       ClrScrn-DCodeTbl    $0C:CLEAR SCREEN
                    fdb       Retrn-DCodeTbl      $0D:RETURN

DelLine
                    lda       V.CurRow,u
                    ldb       #G.Cols
                    mul
                    ldx       #G.ScrStart
                    leax      d,x
                    lda       #G.Cols
clrloop@            clr       ,x+
                    deca
                    bne       clrloop@
                    rts

ClrScrn
                    clr       V.CurCol,u
                    lda       #G.Rows-1
clrloop@
                    sta       V.CurRow,u
                    pshs      a
                    bsr       DelLine
                    puls      a
                    deca
                    bpl       clrloop@
                    clr       V.CurCol,u
                    rts

ErEOScrn
CurUp
NoOp
CurHome             clr       V.CurCol,u
                    clr       V.CurRow,u
                    rts

CurXY
ErEOLine
Do05
CurRght
                    rts

CurLeft
                    ldd       V.CurRow,u
                    beq       leave
                    decb
                    bpl       erasechar
                    ldb       #G.Cols-1
                    deca
                    bpl       erasechar
                    clra
erasechar
                    std       V.CurRow,u
                    ldb       #G.Cols
                    mul
                    addb      V.CurCol,u
                    adca      #0
                    ldx       #G.ScrStart
                    leax      d,x
                    clr       1,x
leave               rts

CurDown
                    ldd       V.CurRow,u
                    lbra      incrow

Retrn
                    clr       V.CurCol,u
                    rts

EscHandler
                    leax      EscHandler2,pcr
eschandlerout
                    stx       V.EscVect,u
                    rts

EscHandler2
                    sta       V.EscCh1,u
                    leax      EscHandler3,pcr
                    bra       eschandlerout

EscHandler3
                    ldb       V.EscCh1,u
                    cmpb      #$32
                    beq       DoFore
                    cmpb      #$33
                    beq       DoBack
                    cmpb      #$34
                    beq       DoBord
eschandler3out
                    leax      ChkSpc,pcr
                    bra       eschandlerout

DoFore
*		sta		COLPF0
                    sta       COLPF1
*		sta		COLPF3
                    bra       eschandler3out
DoBack
                    sta       COLPF2
                    bra       eschandler3out
DoBord
                    sta       COLBK
                    bra       eschandler3out


* GetStat
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
                    cmpa      #SS.ScSiz
                    bne       gserr
                    ldx       PD.RGS,y
                    ldd       #G.Cols
                    std       R$X,x
                    ldd       #G.Rows
                    std       R$Y,x
* clear carry and return
                    clrb
                    rts
gserr
                    comb
                    ldb       #E$UnkSvc
                    rts


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
* clear carry and return
                    clrb
                    rts


IRQPkt              equ       *
Pkt.Flip            fcb       (IRQST.BREAKDOWN|IRQST.KEYDOWN) flip byte
Pkt.Mask            fcb       (IRQST.BREAKDOWN|IRQST.KEYDOWN) mask byte
                    fcb       $0A                 priority


*
* IRQ routine for keyboard
*
IRQSvc
* check if BREAK key pressed; if so, it's a C$QUIT char
                    ldb       IRQST
                    bitb      #IRQST.BREAKDOWN
                    bne       getcode
                    lda       #C$QUIT
                    bra       noctrl@
getcode
                    ldb       KBCODE              get keyboard code from POKEY
gotcode
                    pshs      b
                    andb      #$7F                mask out potential CTRL key
                    leax      ATASCI,pcr
                    lda       b,x                 fetch character for code
                    tst       ,s+                 CTRL key down?
                    bpl       noctrl@             branch if not
                    cmpa      #$40
                    bcs       noctrl@
                    anda      #$5F
                    suba      #$40
noctrl@
* check for caps lock
                    cmpa      #$82
                    bne       tst4caps@
                    tst       V.CapsLck,u
                    beq       turnon@
                    clra
turnon@             sta       V.CapsLck,u
                    bra       KeyLeave
tst4caps@
                    tst       V.CapsLck,u
                    beq       goon@
                    cmpa      #$61
                    blt       goon@
                    cmpa      #$7a
                    bgt       goon@
                    suba      #$20
goon@
                    ldb       V.IBufH,u           get head pointer in B
                    leax      V.InBuf,u           point X to input buffer
                    abx                           X now holds address of head
                    lbsr      cktail              check for tail wrap
                    cmpb      V.IBufT,u           B at tail?
                    beq       L012F               branch if so
                    stb       V.IBufH,u
L012F               sta       ,x                  store our char at ,X
                    beq       WakeIt              if nul, do wake-up
                    cmpa      V.PCHR,u            pause character?
                    bne       L013F               branch if not
                    ldx       V.DEV2,u            else get dev2 statics
                    beq       WakeIt              branch if none
                    sta       V.PAUS,x            else set pause request
                    bra       WakeIt
L013F               ldb       #S$Intrpt           get interrupt signal
                    cmpa      V.INTR,u            our char same as intr?
                    beq       L014B               branch if same
                    ldb       #S$Abort            get abort signal
                    cmpa      V.QUIT,u            our char same as QUIT?
                    bne       WakeIt              branch if not
L014B               lda       V.LPRC,u            get ID of last process to get this device
                    bra       L0153               go for it
WakeIt              ldb       #S$Wake             get wake signal
                    lda       V.WAKE,u            get process to wake
L0153               beq       L0158               branch if none
                    os9       F$Send              else send wakeup signal
L0158               clr       V.WAKE,u            clear process to wake flag

* Update the shadow register then the real register to disable and
* re-enable the keyboard interrupt
KeyLeave
                    pshs      cc
                    orcc      #IntMasks
                    lda       >D.IRQENShdw
                    tfr       a,b
                    anda      #^(IRQST.BREAKDOWN|IRQST.KEYDOWN)
                    orb       #(IRQST.BREAKDOWN|IRQST.KEYDOWN)
                    sta       IRQEN
                    stb       >D.IRQENShdw
                    stb       IRQEN
                    puls      cc,pc

ATASCI              fcb       $6C,$6A,$3B,$80,$80,$6B,$2B,$2A ;LOWER CASE
                    fcb       $6F,$80,$70,$75,$0D,$69,$2D,$3D

                    fcb       $76,$80,$63,$80,$80,$62,$78,$7A
                    fcb       $34,$80,$33,$36,$1B,$35,$32,$31

                    fcb       $2C,$20,$2E,$6E,$80,$6D,$2F,$81
                    fcb       $72,$80,$65,$79,$7F,$74,$77,$71

                    fcb       $39,$80,$30,$37,$08,$38,$3C,$3E
                    fcb       $66,$68,$64,$80,$82,$67,$73,$61


                    fcb       $4C,$4A,$3A,$80,$80,$4B,$5C,$5E ;UPPER CASE
                    fcb       $4F,$80,$50,$55,$9B,$49,$5F,$7C

                    fcb       $56,$80,$43,$80,$80,$42,$58,$5A
                    fcb       $24,$80,$23,$26,$1B,$25,$22,$21

                    fcb       $5B,$20,$5D,$4E,$80,$4D,$3F,$81
                    fcb       $52,$80,$45,$59,$9F,$54,$57,$51

                    fcb       $28,$80,$29,$27,$9C,$40,$7D,$9D
                    fcb       $46,$48,$44,$80,$83,$47,$53,$41


*		fcb	$0C,$0A,$7B,$80,$80,$0B,$1E,$1F ;CONTROL
*		fcb	$0F,$80,$10,$15,$9B,$09,$1C,$1D

*		fcb	$16,$80,$03,$80,$80,$02,$18,$1A
*		fcb	$80,$80,$85,$80,$1B,$80,$FD,$80

*		fcb	$00,$20,$60,$0E,$80,$0D,$80,$81
*		fcb	$12,$80,$05,$19,$9E,$14,$17,$11

*		fcb	$80,$80,$80,$80,$FE,$80,$7D,$FF
*		fcb	$06,$08,$04,$80,$84,$07,$13,$01

                    emod
eom                 equ       *
                    end
