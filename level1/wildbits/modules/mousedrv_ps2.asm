********************************************************************
* mousedrv - Mouse subroutine module for Wildbits 6809
*
* 
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  1       2024/08/26 John Federico
* Started.
*
*  4       2026/10/12 John Federico
* State in GrfMem (gr.MsDrv) instead of the first terminal's static: F$IRQ
* gets U = gr.MsDrv, so the buttons and the auto-hide timer are one copy
* every terminal reads, the IRQ entry is the driver's own (IOMan removes
* by U, and the keyboard was registered with the same static), and closing
* the first terminal no longer frees memory the IRQ still uses.  Term
* removes the IRQ, masks it and hides the pointer.
*
*  5       2026/10/17 John Federico
* The wheel: the IntelliMouse knock (rates 200, 100, 80) and ID 3 switch a
* wheel mouse to 4-byte packets; the 4th byte goes to MD.Wheel
* (SS.MsWheel).  A first byte without bit 3 is dropped (resync).  Sample rate 100.
* Only a packet that moves or changes a button shows the pointer and
* restarts auto-hide.  The pointer image moves to grfdrv256 (GF.InitDisp),
* one MsMove routine clamps X and Y, SetCh fills the channel from a table,
* and the state moves to $1080 (gr.MsDrv).  SS.MsCfg MC.Off: a terminal
* set to always off is not shown on movement.  732 -> 614 bytes, wheel
* included.
*

                    use       defsfile
                    use       wildbits_vtio.d

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       5


                    mod       eom,name,tylg,atrv,start,size

size                equ       V.Last
                    fcb       UPDAT.+EXEC.
name                fcs       /mousedrv/
                    fcb       edition

                   
* mousedrv has three 3-byte entry points:
* - Init                  
* - Term
* - AltISR (called by VTIO at the 60Hz interval)  
* vtio calls Init and Term with U = its device static; the driver uses
* gr.MsDrv (wildbits_vtio.d) instead, and so does its IRQ.
start               lbra      Init
                    lbra      Term
                    lbra      AltISR

AltISR              rts

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
Init                pshs      u                   vtio's static: not ours
                    ldu       #gr.MsDrv           the driver's block (MD.*)
                    bsr       MsInit
                    puls      u,pc                CC and B from MsInit

MsInit
* Wildbitgs/Jr PS/2 mouse  initialization                    
* Initialize the registers and send the right codes to the mouse
* $FF - Mouse Reset (should return self test successful $AA and id $00)
* $F3 - sample rate (10,20,40,60,80,100,200) - use 100 times/sec for Wildbits
*       sample rate defined in MS_SRATE in wildbits.d
* $E8 - Set Resolution $00=1/mm.$01=2/mm.$03=4/mm,$04=8/mm
* $E6 - Scaling 1:1 ($E7=2:1 scaling)
* $F4 - Set mouse to streaming mode. Stream data with interrupts.
* Mouse responds to every command with $FA acknowledge byte
* SendMCode handles receipt of $FA byte
*
* IRQ routine writes X,Y to mouse pointer registers, buttons stored in MD.Buttons
* MS_MEN is the mouse enable Bit1 Mode:1-hardware,0-setxy Bit0:1-show cursor,0-hide cursor
*
* PS/2 Registers are $FE50. Mouse relevant registers are: (defined in wildbits.d)
* |wildbits.d |  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |  ADDR
* |PS2_CTRL   |     |     |MCLR |KCLR |M_WR |     |K_WR |     | $FE50
* |PS2_OUT    | Data to send to keyboard or mouse             | $FE51
* |KBD_IN     | Data in from Mouse                            | $FE52
* |MS_IN      | Data in from Mouse                            | $FE53
* |PS2_STAT   |K_AK |K_NK |M_AK |M_NK |           |MEMP |KEMP | $FE54
*
* Mouse Registers are $FEA0
* |MS_MEN     |     |     |     |     |     |     |MODE |EN   | $FEA0
* |MS_XH      | X15 | X14 | X13 | X12 | X11 | X10 | X9  | X8  | $FEA2
* |MS_XL      | X7  | X6  | X5  | X4  | X3  | X2  | X1  | X0  | $FEA3
* |MS_YH      | Y15 | Y14 | Y13 | Y12 | Y11 | Y10 | Y9  | Y8  | $FEA4
* |MS_YL      | Y7  | Y6  | Y5  | Y4  | Y3  | Y2  | Y1  | Y0  | $FEA5
* 
                    clr       MD.Buttons,u       clear buttons
                    clr       MD.Wheel,u         no wheel steps yet

* Mode 0 and disable mouse cursor in case there is no mouse connected       
                    lda       #$00
                    sta       MS_MEN              mode=0,en=0
* Check if mouse exists on port 1 or port 2
                    leax      ChMouse,pcr         check if mouse is on mouse channel
                    lbsr      SetCh
		    lbsr      MouseExists	  
		    bcc	      MouseInit		  no error=found mouse, init mouse
		    lda	      INT_MASK_0	  load the interrupt mask
		    anda      #INT_PS2_KBD	  and it with the ps/2 kbd bit
		    lbeq      nomouse		  if it is zero, interrupt in use for kbd
                    leax      ChKbd,pcr           else check if mouse on kbd channel
                    lbsr      SetCh
		    lbsr      MouseExists
		    lbcs      nomouse             if not there end else if found init mouse
* Wheel: the IntelliMouse knock - sample rates 200, 100, 80 - asks for the
* wheel; a mouse that has one then identifies as 3 and sends 4-byte packets,
* the 4th byte the wheel movement (signed).  Any other ID: 3-byte packets.
* The sample rate is set for real below, after the knock.
MouseInit           lda       #3
                    sta       MD.PktLen,u
                    leax      WheelKnock,pcr
                    ldb       #6                  three F3 commands, each with its rate
knock@              lda       ,x+
                    lbsr      SendMCode           (keeps A and X; B only on failure)
                    bcs       nowheel@
                    decb
                    bne       knock@
                    lda       #$F2                identify
                    lbsr      SendMCode
                    bcs       nowheel@
                    lbsr      ReadMPS2            A = the ID
                    bcs       nowheel@
                    cmpa      #3                  IntelliMouse: has a wheel
                    bne       nowheel@
                    lda       #4
                    sta       MD.PktLen,u
nowheel@            lda       #$F3                set sample rate code
                    lbsr      SendMCode
                    lda       #MS_SRATE           MS_SRATE defined as 100 in wildbits.d
                    lbsr      SendMCode
                    lda       #$E8                set resolution
                    lbsr      SendMCode
                    lda       #$02                $02=4 counts/mm
                    lbsr      SendMCode
                    lda       #$E6                set scaling at 1:1
                    lbsr      SendMCode
                    lda       #MS.SpdDef          which is speed 5 (SS.MsCfg high byte)
                    sta       >gr.MsSpeed
*Set up mouse handler, this gets skipped if no mouse is detected                    
                    lda       #1
                    sta       MD.Found,u          a mouse: vtio may show the pointer (SS.MsCfg)
		    lda	      MD.MCLR,u            load the right packet depending on whether
		    cmpa      #MCLR               the mouse is on mouse or kbd channel
		    beq	      mousepacket
                    leax      IRQKPckt,pcr        point to the IRQ packet
		    bra	      cont@
mousepacket	    leax      IRQMPckt,pcr        point to the IRQ packet
cont@               ldd       #INT_PENDING_0      get the pending interrupt pending address
                    leay      IRQMSvc,pcr         and the service routine
                    os9       F$IRQ               install the interrupt handler
                    bcs       ErrExit             branch if we have an issue
		    ldb	      MD.IntBit,u
		    comb
		    pshs      b
                    lda       INT_MASK_0          else get the interrupt mask byte
		    anda      ,s
store@              sta       INT_MASK_0          and save it back
		    leas      1,s
* The pointer's image and its first showing are grfdrv256's (GF.InitDisp):
* grfdrv is not loaded yet, and until the image is drawn the pointer stays
* hidden.
		    clr	      MD.ByteCnt,u	  clear mouse packet byte counter
* Enable mouse stream
                    lda       #$F4                enable mouse stream
                    lbsr      SendMCode
		    lda       MD.MCLR,u            clear fifo mouse buffer
                    sta       PS2_CTRL
                    clr       PS2_CTRL
nomouse             andcc     #$FE                clear the carry flag
ex@                 rts                           return to the caller
                    
ErrExit             orcc      #Carry              set the carry flag
                    rts                           return to the caller

* the IntelliMouse knock: set sample rate 200, 100, 80
WheelKnock          fcb       $F3,200,$F3,100,$F3,80

***********************************************************************************
* The F$IRQ packet for the mouse channel.
IRQMPckt            equ       *
Pkt.Flip            fcb       %00000000           the flip byte
Pkt.Mask            fcb       INT_PS2_MOUSE       the mask byte
                    fcb       $F1                 the priority byte

***********************************************************************************
* The F$IRQ packet for the keyboard channel.
IRQKPckt            equ       *
Pkt.KFlip           fcb       %00000000           the flip byte
Pkt.KMask           fcb       INT_PS2_KBD         the mask byte
                    fcb       $F1                 the priority byte
                    
***********************************************************************************
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
* Mouse termination
*                    
                    pshs      u                   vtio's static: not ours
                    ldu       #gr.MsDrv           F$IRQ removes the entry registered with this U
                    tst       MD.Found,u
                    beq       noirq@              no mouse: nothing was installed
                    lda       INT_MASK_0          mask the mouse's interrupt again
                    ora       MD.IntBit,u
                    sta       INT_MASK_0
                    clr       MS_MEN              hide the pointer
                    clr       MD.Found,u
                    ldx       #$0000              we want to remove the IRQ table entry
                    leay      IRQMSvc,pcr         point to the interrupt service routine
                    os9       F$IRQ               call to remove it
noirq@              puls      u                   (vtio's Term puts D.AltIRQ back)
                    clrb                          clear the carry
                    rts                           return to the caller

***********************************************************************************
* Send byte to Mouse via PS/2 interface
* this is a raw call used by SendMcode
* use SendMCode to sent byte to Mouse
* Load the byte in PS/2 OUT, then set CTRL register to write it to the mouse
* then clear the control register
SendMPS2            clr       PS2_CTRL            clear control register
                    sta       PS2_OUT             send the byte out to the mouse
                    lda       MD.M_WR,u             load the "write" bit
                    sta       PS2_CTRL            send it to the control register
                    clr       PS2_CTRL            then clear the bit in the control register
                    rts

***********************************************************************************
* Read Byte from PS/2 Mouse
* read one byte from ps/2 mouse fifo
* built in time out of 1000x10 in case too close to send or interrupt
* really should never time out if mouse is working
* Exit:  A = value from mouse, Carry bit = error code
ReadMPS2            pshs      b,x
                    ldb       #$0A                set 10 outer loops
timerstart          ldx       #$3000              wait up to $1000 cycles to read from mouse
timeloop@           leax      -1,x                decrement counter
                    beq       time1out@           timout at 0, give up - no data to read
                    lda       PS2_STAT            read ps/2 status register detect empty fifo
                    anda      MD.MEMP,u          
                    bne       timeloop@           branch to timeloop if fifo empty
                    lda       [MD.MS_IN,u]         load a byte from the mouse
                    andcc     #$FE                clear carry bit
                    bra       exit@
timeout@            comb                          set carry bit
exit@               puls      x,b,pc
time1out@           decb
                    beq       timeout@            if outer loop is 0, then timeout - no data
                    bra       timerstart


***********************************************************************************
* Send Byte to PS/2 Mouse
* Try to send byte to mouse 3 times, if fails, return error with carry flag
* Check potential return codes: $FA=Ack, $FE=resend, $FC=error
* Fail if receipt of acknowledge byte ($FA) times out
SendMCode           pshs      a,x
                    ldx       #4
sendloop@           leax      -1,x
                    beq       sendfail@           tried to send 3 times and failed
                    lda       ,s
                    lbsr      SendMPS2            send it to the mouse
                    lbsr      ReadMPS2            read the response
                    bcs       sendfail@           response timed out, probably no mouse
                    cmpa      #$FC                check for error
                    beq       sendloop@           try again - resend code if error
                    cmpa      #$FE                check for resend code
                    beq       sendloop@           try again - resend code
                    cmpa      #$FA                check for acknowledge byte
                    bne       sendloop@           if not acknowledge, try to resend
                    andcc     #$FE                clear carry bit and branch to return
                    bra       exit@
sendfail@           comb                          error, set error code and return
exit@               puls      a,x,pc



***********************************************************************************
* Mouse Exists?
* Check to see if mouse exists, return error if no mouse found 
* Clear Mouse FIFO
MouseExists         lda       MD.MCLR,u           clear FIFO
                    sta       PS2_CTRL
                    clr       PS2_CTRL
* Initialize Mouse                  
                    lda       #$F5                put in command mode
                    lbsr      SendMCode           send it to the mouse
                    bcs       mNotFound@          if $F5 not sucessfully sent, then likely no mouse
		    lda       #$F2                load the identify command
                    lbsr      SendMCode           send it to the mouse
                    bcs       mNotFound@          if $F2 not sucessfully sent, then likely no mouse
                    lbsr      ReadMPS2            read the response
                    bcs       mNotFound@          response timed out, probably no mouse
		    anda      #%11110000	  and to get top bype Mouse=$0X kbd=$AX
		    beq	      mFound              result is $00, then mouse found
mNotFound@	    comb			  set carry bit for error
mFound		    rts
		    

***********************************************************************************
* SetCh - point the driver at a PS/2 channel: copy its 6 bytes from the
* table at X into MD.MEMP, MD.MS_IN, MD.M_WR, MD.MCLR and MD.IntBit (in
* that order in wildbits_vtio.d).  ChMouse is channel 2, ChKbd channel 1.
                    ifne      MD.IntBit-MD.MEMP-5
                    error     SetCh: MD.MEMP..MD.IntBit are not 6 bytes in a row
                    endc
SetCh               leay      MD.MEMP,u
                    ldb       #6
sc@                 lda       ,x+
                    sta       ,y+
                    decb
                    bne       sc@
                    rts
ChMouse             fcb       MEMP
                    fdb       MS_IN
                    fcb       M_WR,MCLR,INT_PS2_MOUSE
ChKbd               fcb       KEMP
                    fdb       KBD_IN
                    fcb       K_WR,KCLR,INT_PS2_KBD

***********************************************************************************
* IRQ Mouse Service
* Mouse should be reading fifo in series of 3 bytes = 1 packet
* Mouse is on 640x480 grid. Limit coordinates to grid.
* Read in current XY values and adjust for offsets, then write XY back
* Button information is stored in MD.Buttons 4=middle,2=right,1=left (bits 2,1,0)
* MD.Buttons defined in wildbits_vtio.d
* Use getstat to get X,Y and Buttons in a program
* There is an auto-hide timer that has corresponding code in ALTISR in vtio.asm
* Auto-hide timer var is MD.Timer and is incremented in 1/60 sec increments
* Auto-hides when timer var wraps around to 0 in vtio.asm
* NOTE: Interrupt can trigger before there is a byte in the FIFO to read
*       ALWAYS CHECK if there is a byte to read first
IRQMSvc             pshs      a,b
                    lda       MD.IntBit,u      get the PS/2 mouse interrupt flag
                    sta       INT_PENDING_0       clear the interrupt
* The pointer is shown and the auto-hide timer restarted in procpacket, only
* for a packet that moves or changes a button: an interrupt or a packet
* with neither (some mice send them) must not keep the pointer up.
getmpacket          ldb       PS2_STAT            read ps/2 status register detect empty fifo
                    andb      MD.MEMP,u            check byte ready in fifo
                    lbne      IRQMExit            exit if empty
		    inc	      MD.ByteCnt,u
                    lda       [MD.MS_IN,u]         load byte#0 - buttons, + or -, overflow
		    ldb	      MD.ByteCnt,u	  load the byte counter
		    cmpb      #2		  compare to see which byte we are reading in
		    blo	      byte0@
		    beq	      byte1@
		    cmpb      #3
		    bhi       byte3@              the 4th byte: the wheel
byte2		    sta	      MD.Byte2,u
		    cmpb      MD.PktLen,u         a wheel mouse has one more byte to come
		    blo       getmpacket
		    bra	      procpacket
byte3@              adda      MD.Wheel,u          add the step to the count
		    bvc       wheel@
		    lda       #$7F                past the end: hold at +127 ...
		    tst       MD.Wheel,u
		    bpl       wheel@
		    lda       #$80                ... or -128
wheel@              sta       MD.Wheel,u
		    bra       procpacket
* A packet's first byte (buttons and signs) always has bit 3 set.  A first
* byte without it means the stream slipped - a byte lost or one extra - so
* drop it and wait for one that starts a packet; counting blindly would read
* movement as buttons for good.  (rc25's framer applies the same rule, but
* only to 3-byte packets, so it cannot serve a wheel mouse.)
byte0@              bita      #%00001000
		    beq       resync@
		    sta	      MD.Byte0,u
		    bra	      getmpacket
resync@             clr       MD.ByteCnt,u        not a first byte: drop it
		    bra       getmpacket
byte1@              sta	      MD.Byte1,u
		    bra       getmpacket
		    
procpacket          lda	      MD.Byte0,u
	            pshs      a                   push a to store +- for xy
                    anda      #%00000111          just get button information
                    cmpa      MD.Buttons,u        a button changed?
                    bne       active@
                    ldb       MD.Byte1,u          or any movement?
                    orb       MD.Byte2,u
                    beq       quiet@
active@             clr       MD.Timer,u          restart the auto-hide timer
* Show the pointer - unless the live terminal has SS.MsCfg MC.Off (its
* gr.MsTbl row), which keeps it hidden.  A holds the new buttons.
                    ldb       >gr.LiveTerm
                    cmpb      #G.TermMax
                    bhs       show@               no live terminal
                    lslb                          b = id * 8, the row
                    lslb
                    lslb
                    pshs      x
                    ldx       #gr.MsTbl
                    abx
                    ldb       MT.Cfg,x
                    puls      x
                    bitb      #MC.Off
                    bne       quiet@
show@               ldb       #$01
                    stb       MS_MEN              show mouse and enable legacy mode
quiet@              sta       MD.Buttons,u       store new button flags
* X: byte 1, sign in bit 4 of byte 0, added.
                    ldb       MD.Byte1,u
                    beq       computey            no X movement
                    lda       ,s
                    anda      #%00010000          the X sign bit
                    beq       xpos@
                    lda       #$FF                negative: D = $FFxx
xpos@               ldx       #MS_XH
                    ldy       #640
                    bsr       MsMove
* Y: byte 2, sign in bit 5, subtracted (Y = 0 at the top of the screen).
computey            ldb       MD.Byte2,u
                    beq       finish@             no Y movement
                    lda       ,s
                    anda      #%00100000          the Y sign bit
                    beq       ypos@
                    lda       #$FF
ypos@               coma                          negate D
                    comb
                    addd      #1
                    ldx       #MS_YH
                    ldy       #480
                    bsr       MsMove
finish@             puls      a
		    clr	      MD.ByteCnt,u
		    lbra      getmpacket	  done, go check fifo for more data
IRQMExit            puls      a,b 
ex@                 clrb                          clear error (do we need to clear carry bit?)
ex2@                rts                           return

* MsMove - add D (signed) to the 16-bit pointer register at X, held to
* 0..Y.  X and Y clobbered.
MsMove              addd      ,x
                    bpl       mm1@
                    clra                          below 0: 0
                    clrb
mm1@                pshs      y
                    cmpd      ,s++
                    ble       mm2@
                    tfr       y,d                 past the edge: the edge
mm2@                std       ,x
                    rts

                    emod
eom                 equ       *
                    end
