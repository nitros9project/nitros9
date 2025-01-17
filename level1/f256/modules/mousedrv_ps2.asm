********************************************************************
* mousedrv - Mouse subroutine module for F256 VTIO
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
                    use       f256vtio.d

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
* F256 Jr. PS/2 mouse  initialization                    
* Initialize the registers and send the right codes to the mouse
* $FF - Mouse Reset (should return self test successful $AA and id $00)
* $F3 - sample rate (10,20,40,80,100,200) - use 40 times/sec for F256
*       sample rate defined in MS_SRATE in f256.d
* $E8 - Set Resolution $00=1/mm.$01=2/mm.$03=4/mm,$04=8/mm
* $E6 - Scaling 1:1 ($E7=2:1 scaling)
* $F4 - Set mouse to streaming mode. Stream data with interrupts.
* Mouse responds to every command with $FA acknowledge byte
* SendMCode handles receipt of $FA byte
*
* IRQ routine writes X,Y to mouse pointer registers, buttons stored in V.MSButtons
* MS_MEN is the mouse enable Bit1 Mode:1-hardware,0-setxy Bit0:1-show cursor,0-hide cursor
*
* PS/2 Registers are $FE50. Mouse relevant registers are: (defined in f256.d)
* |f256.d     |  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |  ADDR
* |PS2_CTRL   |     |     |MCLR |KCLR |M_WR |     |K_WR |     | $FE50
* |PS2_OUT    | Data to send to keyboard or mouse             | $FE51
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
* Clear Mouse FIFO                  
                    lda       #MCLR               clear FIFO
                    sta       PS2_CTRL
                    clr       PS2_CTRL
* Initialize Mouse                  
                    lda       #$FF                load the RESET command
                    lbsr      SendMCode           send it to the mouse
                    bcs       nomouse             if $FF not sucessfully sent, then likely no mouse
                    lbsr      ReadMPS2            read the response
                    bcs       nomouse             response timed out, probably no mouse
                    cmpa      #$AA                look for self test success
                    bne       nomouse             no success = no mouse
                    lbsr      ReadMPS2
                    cmpa      #$00                id=0 (need different codes if intellimouse)
                    bne       nomouse
                    lda       #$F3                set sample rate code
                    lbsr      SendMCode
                    lda       #MS_SRATE           MS_SRATE defined as 40 in f256.d
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
                    ldd       #INT_PENDING_0      get the pending interrupt pending address
                    leax      IRQMPckt,pcr        point to the IRQ packet
                    leay      IRQMSvc,pcr         and the service routine
                    os9       F$IRQ               install the interrupt handler
                    bcs       ErrExit             branch if we have an issue
                    lda       INT_MASK_0          else get the interrupt mask byte
                    anda      #^INT_PS2_MOUSE     set the PS/2 mouse interrupt
                    sta       INT_MASK_0          and save it back
                    lbsr      MakeMSPointer       add pointer graphics for mouse
* Enable mouse cursor and legacy mode               
                    lda       #$01
                    sta       MS_MEN              show mouse and enable XY mode             
* Enable mouse stream
                    lda       #MCLR
                    sta       PS2_CTRL
                    clr       PS2_CTRL
                    lda       #$F4                enable mouse stream
                    lbsr      SendMCode
nomouse             andcc     #$FE                clear the carry flag
ex@                 rts                           return to the caller
                    
ErrExit             orcc      #Carry              set the carry flag
                    rts                           return to the caller

***********************************************************************************
* The F$IRQ packet.
IRQMPckt            equ       *
Pkt.Flip            fcb       %00000000           the flip byte
Pkt.Mask            fcb       INT_PS2_MOUSE       the mask byte
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
* F256K mouse termination
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
                    lda       #M_WR               load the "write" bit
                    sta       PS2_CTRL            send it to the control register
                    clr       PS2_CTRL            then clear the bit in the control register
                    rts

***********************************************************************************
* Read Byte from PS/2 Mouse
* read one byte from ps/2 mouse fifo
* built in time out of FFFFx10 in case too close to send or interrupt
* really should never time out if mouse is working
* Exit:  A = value from mouse, Carry bit = error code
ReadMPS2            pshs      b,x
                    ldb       #$0A                set 10 outer loops
timerstart          ldx       #$FFFF              wait up to FFFF cycles to read from mouse
timeloop@           leax      -1,x                decrement counter
                    beq       time1out@           timout at 0, give up - no data to read
                    lda       PS2_STAT            read ps/2 status register detect empty fifo
                    anda      #%00000010          
                    bne       timeloop@           branch to timeloop if fifo empty
                    lda       MS_IN               load a byte from the mouse
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
* IRQ Mouse Service
* Mouse should be reading 3 packets on interrupt
* Mouse is on 640x480 grid. Limit coordinates to grid.
* Read in current XY values and adjust for offsets, then write XY back
* Button information is stored in V.MSButtons 4=middle,2=right,1=left (bits 2,1,0)
* V.MSButtons defined in f256vtio.d
* Use getstat to get X,Y and Buttons in a program
* There is an auto-hide timer that has corresponding code in ALTISR in vtio.asm
* Auto-hide timer var is V.MSTimer and is incremented in 1/60 sec increments
* Auto-hides when timer var wraps around to 0 in vtio.asm
* When first initialized there is sometimes an extra acknowledge byte ($FA) sent
* before the packet. This will check for the $FA (acknowledge) byte.
* NOTE: Interrupt can trigger before there is a byte in the FIFO to read
*       ALWAYS CHECK if there is a byte to read first
IRQMSvc             pshs      a,b
                    lda       #INT_PS2_MOUSE      get the PS/2 mouse interrupt flag
                    sta       INT_PENDING_0       clear the interrupt
* Enable mouse cursor if it has been auto-hid               
                    lda       #$01
                    sta       MS_MEN              show mouse and enable legacy mode
                    clr       V.MSTimer,u         reset the auto-hide timer (f256vtio.d)
getmpacket          ldb       PS2_STAT            read ps/2 status register detect empty fifo
                    andb      #%00000010          check byte ready in fifo
                    lbne      IRQMExit            branch to timeloop if fifo empty
                    lda       MS_IN               load byte#0 - buttons, + or -, overflow
                    pshs      a                   push a to store +- for xy
                    cmpa      #$FA                check for extra $FA - just in case
                    lbeq      finish@         
                    anda      #%00000111          just get button information
                    sta       V.MSButtons,u       store new button flags
* Compute new X value and store in registers                
computex            ldb       PS2_STAT            read ps/2 status register detect empty fifo
                    andb      #%00000010          
                    bne       computex            branch to timeloop if fifo empty
                    lda       ,s
                    anda      #%00010000          check the X sign bit for + or - offset
                    beq       posxvalue           branch if positive
negxvalue           lda       #$FF                if neg, set high bit for 2's complement
                    bra       contx@              neg value is 2's complement
posxvalue           clra                    
contx@              ldb       MS_IN               load byte#1 - x offet
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
computey            ldb       PS2_STAT            read ps/2 status register detect empty fifo
                    andb      #%00000010          
                    bne       computey            branch to timeloop if fifo empty
                    lda       ,s
                    anda      #%00100000          check the Y sign bit for + or - offser
                    beq       posyvalue           branch if positive
negyvalue           lda       #$FF                if neg, set high bit for 2's complement
                    bra       conty@              neg value is 2's complement
posyvalue           clra                    
conty@              ldb       MS_IN               load byte#2 - y offet
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
                    lda       #MCLR               clear FIFO
                    sta       PS2_CTRL
                    clr       PS2_CTRL
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
