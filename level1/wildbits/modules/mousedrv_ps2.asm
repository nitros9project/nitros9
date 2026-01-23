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

                    use       defsfile
                    use       wildbits_vtio.d

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       3

MAPSLOT             equ       MMU_SLOT_2
MAPADDR             equ       (MAPSLOT-MMU_SLOT_0)*$2000

                    mod       eom,name,tylg,atrv,start,size

size                equ       V.Last
                    fcb       UPDAT.+EXEC.
name                fcs       /mousedrv/
                    fcb       edition

                   
* mousedrv has three 3-byte entry points:
* - Init                  
* - Term
* - AltISR (called by VTIO at the 60Hz interval)  
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
Init                
* Wildbitgs/Jr PS/2 mouse  initialization                    
* Initialize the registers and send the right codes to the mouse
* $FF - Mouse Reset (should return self test successful $AA and id $00)
* $F3 - sample rate (10,20,40,80,100,200) - use 40 times/sec for Wildbits
*       sample rate defined in MS_SRATE in wildbits.d
* $E8 - Set Resolution $00=1/mm.$01=2/mm.$03=4/mm,$04=8/mm
* $E6 - Scaling 1:1 ($E7=2:1 scaling)
* $F4 - Set mouse to streaming mode. Stream data with interrupts.
* Mouse responds to every command with $FA acknowledge byte
* SendMCode handles receipt of $FA byte
*
* IRQ routine writes X,Y to mouse pointer registers, buttons stored in V.MSButtons
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
                    clr       V.MSButtons,u       clear buttons

* Mode 0 and disable mouse cursor in case there is no mouse connected       
                    lda       #$00
                    sta       MS_MEN              mode=0,en=0
* Check if mouse exists on port 1 or port 2
  	   	    lbsr      SetChMS	          check if mouse is on mouse channel
		    lbsr      MouseExists	  
		    bcc	      MouseInit		  no error=found mouse, init mouse
		    lda	      INT_MASK_0	  load the interrupt mask
		    anda      #INT_PS2_KBD	  and it with the ps/2 kbd bit
		    beq	      nomouse		  if it is zero, interrupt in use for kbd
		    lbsr      SetChKBD		  else check if mouse on kbd channel
		    lbsr      MouseExists
		    bcs	      nomouse             if not there end else if found init mouse
MouseInit           lda       #$F3                set sample rate code
                    lbsr      SendMCode
                    lda       #MS_SRATE           MS_SRATE defined as 40 in wildbits.d
                    lbsr      SendMCode
                    lda       #$E8                set resolution
                    lbsr      SendMCode
                    lda       #$02                $02=4 counts/mm
                    lbsr      SendMCode
                    lda       #$E6                set scaling at 1:1
                    lbsr      SendMCode
*Set up mouse handler, this gets skipped if no mouse is detected                    
                    leax      MSHandler,pcr       get the PS/2 mouse handler routine
                    stx       V.MouseVect,u       and store it as the current handler address
		    lda	      V.MCLR,u            load the right packet depending on whether
		    cmpa      #MCLR               the mouse is on mouse or kbd channel
		    beq	      mousepacket
                    leax      IRQKPckt,pcr        point to the IRQ packet
		    bra	      cont@
mousepacket	    leax      IRQMPckt,pcr        point to the IRQ packet
cont@               ldd       #INT_PENDING_0      get the pending interrupt pending address
                    leay      IRQMSvc,pcr         and the service routine
                    os9       F$IRQ               install the interrupt handler
                    bcs       ErrExit             branch if we have an issue
		    ldb	      V.INT_PS2_MOUSE,u
		    comb
		    pshs      b
                    lda       INT_MASK_0          else get the interrupt mask byte
		    anda      ,s
store@              sta       INT_MASK_0          and save it back
		    leas      1,s
                    lbsr      MakeMSPointer       add pointer graphics for mouse
		    clr	      V.MSByteCnt,u	  clear mouse packet byte counter
* Enable mouse cursor and legacy mode               
                    lda       #$01
                    sta       MS_MEN              show mouse and enable XY mode             
* Enable mouse stream
                    lda       #$F4                enable mouse stream
                    lbsr      SendMCode
		    lda       V.MCLR,u            clear fifo mouse buffer
                    sta       PS2_CTRL
                    clr       PS2_CTRL
nomouse             andcc     #$FE                clear the carry flag
ex@                 rts                           return to the caller
                    
ErrExit             orcc      #Carry              set the carry flag
                    rts                           return to the caller

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
                   
                    ldx       #$0000              we want to remove the IRQ table entry
                    leay      IRQMSvc,pcr         point to the interrupt service routine
                    os9       F$IRQ               call to remove it
                    ldx       >D.OrgAlt           get the original alternate IRQ vector
                    stx       <D.AltIRQ           save it back to the D.AltIRQ address
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
                    lda       V.M_WR,u             load the "write" bit
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
                    anda      V.MEMP,u          
                    bne       timeloop@           branch to timeloop if fifo empty
                    lda       [V.MS_IN,u]         load a byte from the mouse
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
MouseExists         lda       V.MCLR,u           clear FIFO
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
* Set Mouse to be on the Mouse Channel
* Want to set the channel to PS/2 channel 2 
SetChMS	            ldd	      #MS_IN
		    std	      V.MS_IN,u
		    lda	      #MEMP
		    sta	      V.MEMP,u
		    lda	      #M_WR
		    sta	      V.M_WR,u
		    lda	      #MCLR
		    sta	      V.MCLR,u
		    lda	      #INT_PS2_MOUSE
		    sta	      V.INT_PS2_MOUSE,u
		    rts

***********************************************************************************
* Set Mouse to be on the Mouse Channel
* Want to set the channel to PS/2 channel 2 
SetChKBD            ldd	      #KBD_IN
		    std	      V.MS_IN,u
		    lda	      #KEMP
		    sta	      V.MEMP,u
		    lda	      #K_WR
		    sta	      V.M_WR,u
		    lda	      #KCLR
		    sta	      V.MCLR,u
		    lda	      #INT_PS2_KBD
		    sta	      V.INT_PS2_MOUSE,u
		    rts

		    

***********************************************************************************
* IRQ Mouse Service
* Mouse should be reading fifo in series of 3 bytes = 1 packet
* Mouse is on 640x480 grid. Limit coordinates to grid.
* Read in current XY values and adjust for offsets, then write XY back
* Button information is stored in V.MSButtons 4=middle,2=right,1=left (bits 2,1,0)
* V.MSButtons defined in wildbits_vtio.d
* Use getstat to get X,Y and Buttons in a program
* There is an auto-hide timer that has corresponding code in ALTISR in vtio.asm
* Auto-hide timer var is V.MSTimer and is incremented in 1/60 sec increments
* Auto-hides when timer var wraps around to 0 in vtio.asm
* NOTE: Interrupt can trigger before there is a byte in the FIFO to read
*       ALWAYS CHECK if there is a byte to read first
IRQMSvc             pshs      a,b
                    lda       V.INT_PS2_MOUSE,u      get the PS/2 mouse interrupt flag
                    sta       INT_PENDING_0       clear the interrupt
* Enable mouse cursor if it has been auto-hid               
                    lda       #$01
                    sta       MS_MEN              show mouse and enable legacy mode
                    clr       V.MSTimer,u         reset the auto-hide timer (wildbits_vtio.d)
getmpacket          ldb       PS2_STAT            read ps/2 status register detect empty fifo
                    andb      V.MEMP,u            check byte ready in fifo
                    lbne      IRQMExit            exit if empty
		    inc	      V.MSByteCnt,u
                    lda       [V.MS_IN,u]         load byte#0 - buttons, + or -, overflow
		    ldb	      V.MSByteCnt,u	  load the byte counter
		    cmpb      #2		  compare to see which byte we are reading in
		    blo	      byte0@
		    beq	      byte1@
byte2		    sta	      V.MSByte2,u
		    bra	      procpacket
byte0@  	    sta	      V.MSByte0,u
		    bra	      getmpacket
byte1@              sta	      V.MSByte1,u
		    bra       getmpacket
		    
procpacket          lda	      V.MSByte0,u
	            pshs      a                   push a to store +- for xy
                    anda      #%00000111          just get button information
                    sta       V.MSButtons,u       store new button flags
* Compute new X value and store in registers                
computex            lda       ,s
                    anda      #%00010000          check the X sign bit for + or - offset
                    beq       posxvalue           branch if positive
negxvalue           lda       #$FF                if neg, set high bit for 2's complement
                    bra       contx@              neg value is 2's complement
posxvalue           clra                    
contx@              ldb       V.MSByte1,u         load byte#1 - x offet
                    beq       computey            if 0, then skip comps and jump straight to y
                    pshs      d                   not 0, push offset
                    ldd       MS_XH               load current X value
                    addd      ,s                  add offset
                    cmpd      #0                  if <0, handle 0 limiter
                    blt       xzero
                    cmpd      #640                check for 640 limit
                    bgt       x640                if >640, handle 640 limiter
                    bra       storex              if not, then branch to store
xzero               ldd       #0                  handle 0 limiter
                    bra       storex
x640                ldd       #640                handle 640 limiter  
storex              std       MS_XH               store new x value
                    puls      d
* Compute new Y value and store in registers
computey            lda       ,s
                    anda      #%00100000          check the Y sign bit for + or - offser
                    beq       posyvalue           branch if positive
negyvalue           lda       #$FF                if neg, set high bit for 2's complement
                    bra       conty@              neg value is 2's complement
posyvalue           clra                    
conty@              ldb       V.MSByte2,u         load byte#2 - y offet
                    beq       finish@             if 0, then skip comps and jump to end
                    pshs      d                   not 0, push offset
                    ldd       MS_YH               load current Y value
                    subd      ,s                  subtract offset (backwards b/c Y=0 at top of screen)
                    cmpd      #0                  if <0, handle 0 limiter
                    blt       yzero
                    cmpd      #480                if >480, handle 480 limiter
                    bgt       y480
                    bra       storey              if not, branch to store
yzero               ldd       #0                  handle 0 limiter
                    bra       storey
y480                ldd       #480                handle 480 limiter  
storey              std       MS_YH               store new y value
                    puls      d  
finish@             puls      a
		    clr	      V.MSByteCnt,u
		    lbra      getmpacket	  done, go check fifo for more data
IRQMExit            puls      a,b 
ex@                 clrb                          clear error (do we need to clear carry bit?)
ex2@                rts                           return

***********************************************************************************\
* MSHandler
* Not sure we need a mouse handler routine at this point
MSHandler           andcc     #$FE
                    rts
                    
***********************************************************************************
* MakeMSPointer
* This draws the mouse pointer in black and white lines
* The loop specifies the px color in a, and then length in b
* The data in mspointer data is stored as color,length with a
* terminating word of $0000
* Map in block $C0, then $C00 offset
* Mouse pointer is 16x16 at $18_0C00 which is block $C0 at $0C00
MakeMSPointer       pshs      cc,a,x,y,u
*                   **** map in $C0 for Mouse Graphics Registers
                    orcc      #IntMasks
                    lda       MAPSLOT
                    pshs      a
                    lda       #$C0                get the MMU Block for bitmap addresses
                    sta       MAPSLOT             store it in the MMU slot to map it in             
                    ldx       #MAPADDR
                    leax      $C00,x              mouse pointer graphics start at $C00 offset
*                   ****      draw mouse pixels
                    leay      mspointerdata,pcr   load mousedata pointer
mouseloop@          ldd       ,y++                load color,length from data
                    beq       mswritedone@        if d=$0000, then done
                    bsr       mswritepx           write the pixel data
                    bra       mouseloop@          loop if more data
mswritedone@        puls      a
                    sta       MAPSLOT
                    puls      cc,u,y,x,a,pc                 

* a=color,b=length
mswritepx           sta       ,x+
                    decb
                    bne       mswritepx
                    rts

mspointerdata       fcb       255,2,0,14
                    fcb       255,1,1,1,255,1,0,13
                    fcb       255,1,1,2,255,1,0,12
                    fcb       255,1,1,3,255,1,0,11
                    fcb       255,1,1,4,255,1,0,10
                    fcb       255,1,1,5,255,1,0,9
                    fcb       255,1,1,6,255,1,0,8
                    fcb       255,1,1,7,255,1,0,7
                    fcb       255,1,1,8,255,1,0,6
                    fcb       255,1,1,9,255,1,0,5
                    fcb       255,1,1,10,255,1,0,4
                    fcb       255,1,1,6,255,5,0,4
                    fcb       255,1,1,3,255,1,1,3,255,1,0,7
                    fcb       255,1,1,2,255,3,1,2,255,1,0,7
                    fcb       255,1,1,1,255,4,1,2,255,1,0,7
                    fcb       255,2,0,4,255,3,0,7,0,0

emod
eom                 equ       *
                    end
