
********************************************************************
* SOLdrv
* Foenix Start of Line Driver
* This driver sends a user defined signal to a process when the
* hardware starts to draw a desinated line on the screen.
* This handles up to 8 SOL interrupts.
*
* by John Federico
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  1       2025/01/02  John Federico
*  Initial version - this was originally part of vtio.  However,
*  F$IRQ requires a unique U address to be able to remove an IRQ.
*  This made clean up difficult, since vtio already uses 2 IRQs.
*  The solution was to either give the IRQ a different static mem
*  address or make it an independent driver.  Decided to make it
*  a separate driver.  May have to revisit this decision later.
*

                    nam       SOLdrv
                    ttl       Foenix Start of Line Driver

                    ifp1
                    use       defsfile
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       V.SCF
* Start of Line Interrupt Handling
V.SOLCurr           RMB       1                 current SOL for interrupt
V.SOLMax            RMB       1                 # of installed SOLIRQs (max 8)
V.SOLTable          RMB       40                
***********************************************************************************
* The V,SOLTable is a table (max 8) of the installed IRQs of 5 byte rows.
* The table is set up:
* |   8 bits   |  8 bits |    16 bits    | 8 bits |
* | Process Id |  Signal | Line# for IRQ |  Mute  |
*
* After entries are added, the interrupt routine will deal with the
* current line#, send the signal to the Process Id, then go to the next
* row in the table and set the line# for the next IRQ.  The table is
* created in order from largest to smallest line number.  The IRQ then
* starts at V.SOLMax and iterates backwards (smallest to largest) through
* the table to the 0 entry.
* When it gets to 0, it starts again at V.SOLMax.  This way all the SOLs
* are set in order.
***********************************************************************************

                    RMB       128               stack space

size                equ       .
***********************************************************************************
* This next line set up the permitted modes.  The modes are set here in the driver and
* in the device descriptor.  The mode needs to match in both.  When you call I$Open on
* the driver, I$Open will only permit these modes.
***********************************************************************************
                    fcb       UPDAT.+SHARE.     these are the supported modes.
name                fcs       /SOLdrv/
                    fcb       edition

start               lbra      Init              |SCF jump table
                    lbra      Read              |
                    lbra      Write             |
                    lbra      GetSta            |
                    lbra      SetSta            |I$Open requires certain SetStats
                    lbra      Term


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
* Initialize driver to off.  We don't need to set up an SOL or IRQ
* until a user requests to set up one.
Init                lda       #$FF
                    sta       V.SOLMax,u         initialize driver to off (-1)
                    clrb
                    rts


***********************************************************************************
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
* Nothing to read, just return
Read                clra
                    ldb   #E$EOF
                    rts


***********************************************************************************
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
* Nothing to write, just return
Write               clrb
                    rts


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
Term                clrb
                    rts


***********************************************************************************
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
****************************
* Get status entry point
* Entry: A=Function call #
* There are no getstat calls, just return
GetSta              clrb
                    rts


***********************************************************************************
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
SetSta              ldx         PD.RGS,y        load location for caller shadow registers
                    cmpa        #SS.SOLIRQ      main call to add/remove SOL IRQs
                    lbeq        SSOLIRQ
                    cmpa        #SS.SOLMUTE
                    lbeq        SSOLMUTE
                    clrb
                    rts

***********************************************************************************
* IRQs must be turned on and the SOL enabled for SOL to work
*
* Bit 1 of INT_MASK_0 must be set to enable SOL IRQ
*
*     BIT    |   7  |    6     |   5    |    4   |    3     |   2    |  1  |  0  | 
* INT_MASK_0 | CART | RESERVED | TIMER1 | TIMER0 | PS2MOUSE | PS2KBD | SOL | SOF |
*
* $FFD9 is the SOL Register for the line number to trigger IRQ
* $FFD8 bit 0 must be set to enable SOL
*
* ADDR |   DESC    |  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0   |
* FFD8 | LINT_CTRL |                                         |ENABLE|
* FFD9 | LINT_L    |  L7 |  L6 |  L5 |  L4 |  L3 |  L2 |  L1 |  L0  |
* FFDA | LINT_L    |                       | L11 | L10 |  L9 |  L8  |
*
***********************************************************************************
* SS.SOLIRQ
*
* Start of Line Interrupt
*
* Add or Remove Start of Line Interrupt (max of 8) that will send a signal
* to a process at the start of a line on the screen
*
* Entry: R$Y = Value for signal should be greater than 128 ($80)
*              If signal=0 procedure will remove Line# from table
*                Signals should be > 128, system defines signals <= 128
*        R$X = Line # that triggers Interrupt (0-479 for 60hz)
*
* Exit:  B = non-zero error code
*       CC = carry flag clear to indicate success

SSOLIRQ             ldy       R$Y,x
                    lbeq      SOLremoveval        if signal is 0, then remove from list
                    ldb       V.SOLMax,u          load max table index
                    lbmi      SOL_TurnOn          first SOL? need to init and turn on IRQ
                    cmpb      #35                 max table is 8 entries, last is offset 35
                    bne       cont@               continue if < 35
                    ldb       #204                else: Device Table Full error
                    comb                          set carry flag
                    lbra      ErrExit@
*  Continue and add entry to table.  Multiply Max x4 to get table index             
cont@               ldy       R$X,x               line# passed by caller
                    pshs      x,y                 store PD.RGS and Line#
                    leay      V.SOLTable,u
                    leay      b,y                 addr of last entry in table
                    addb      #5                  increase offset to add new row
                    stb       V.SOLMax,u          store max offset
*  Search through list and insert in order from greatest to least line
*  Interrupt will start at the end of the list and work backwards to
*  set the next line for the  interrupt.  This part of the routine
*  just sets up the list.  The lines are handled in SOL_IRQSvc.
search@             ldx       ,y                  get PID & Signal from last row
*                   *** duplicate current row in next row                   
                    stx       5,y                 copy to new row
                    lda       4,y                 load mute value
                    sta       9,y                 store mute value in new row
                    ldx       2,y                 get line# from last row
                    stx       7,y                 copy to new row
                    cmpx      2,s                 compare with line# to insert
                    ble       next@               table value > new value, skip
                    leay      5,y                 get next row address
                    bra       insertval@          insert new into higher row if line# lower
next@               subb      #5                  dec row counter 
                    beq       insertval@          insert into existing row
                    leay      -5,y                decrement address to lower row
                    bra       search@             continue search for insert location
insertval@          bsr       SOLinsertval        location has been found or is 0 row
                    puls      x,y                 pull Line# & PD.RGS
                    andcc     #$FE                clear carry
                    rts
* SOL_TurnOn
* Installs the IRQ for the SOL              
SOL_TurnOn          pshs      cc
                    orcc      #IntMasks
                    ldy       R$X,x
                    pshs      x,y
                    leay      V.SOLTable,u
                    bsr       SOLinsertval
                    clr       V.SOLMax,u
                    clr       V.SOLCurr,u
                    ldd       #INT_PENDING_0      get the pending interrupt pending address
                    leax      SOL_Pckt,pcr        point to the IRQ packet
                    leay      SOL_IRQSvc,pcr         and the service routine
                    os9       F$IRQ               install the interrupt handler
                    bcc       irqsuccess@         branch if success
                    os9       F$PErr
irqsuccess@         lda       INT_MASK_0          else get the interrupt mask byte
                    anda      #^INT_VKY_SOL        set the SOL interrupt
                    sta       INT_MASK_0          and save it back
                    puls      x,y
SOL_ON              ldd       R$X,x
*                   exg       a,b
                    std       $FFD9
                    lda       #1
                    sta       $FFD8
                    puls      cc
ErrExit@            rts

***********************************************************************************
*  SOLinsertval
*  Inserts new values into table row located in y
*  Stack has PC,X,Y on entry
*
SOLinsertval        ldx       4,s                 get line# stack=pc,x,y
                    stx       2,y                 store line# in table
                    ldx       2,s                 restore x pointer
                    ldd       R$Y,x               get signal, puts signal in b  
                    pshs      y                   
                    ldy       >D.Proc             location of calling proc pd
                    lda       P$ID,y              put pid in a
                    puls      y
                    std       ,y                  store pid & signal in table
                    clr       4,y                 clear the mute value
                    rts
                    
***********************************************************************************
*  SOLremoveval
*  Removes value from a table if signal is 0
*
SOLremoveval        pshs      cc                  mask interrupts while we remove
                    orcc      #IntMasks           
                    clrb                          Start counter at 0 and increment to max
                    ldy       R$X,x               get line# from caller
                    pshs      y                   pshs line # to store for compare
                    leay      V.SOLTable,u        load table
remsearch@          ldx       2,y                 load line#
                    cmpx      ,s                  compare to caller line#
                    beq       remove@             if equal, remove
                    leay      5,y                 else, increase to next row
                    addb      #5                  increment counter
                    cmpb      V.SOLMax,u          compare to max
                    ble       remsearch@          if less or equal, then keep searching
notfound@           leas      2,s                 if not found, clean stack and end     
                    bra       end@
*  remove a row by  moving all subsequent rows down                 
remove@             cmpb      V.SOLMax,u          compare to max
                    bpl       remdone@            if equals max, then done
                    ldx       5,y                 copy values from next row to this row
                    stx       ,y
                    ldx       7,y
                    stx       2,y
                    lda       9,y
                    sta       4,y
                    addb      #5                  Go to next row
                    leay      5,y                 else go to next row
                    bra       remove@             and keep searching
remdone@            puls      y                   done, clean stack
                    subb      #5
                    stb       V.SOLMax,u          decrement max
                    stb       V.SOLCurr,u         
                    bge       end@                if curr/max >=0 then end
*  if V.SOLMax < 0 then turn off interrupt and remove IRQ
                    lda       INT_MASK_0          get the interrupt mask byte
                    ora       #INT_VKY_SOL        deactivate the SOL interrupt
                    sta       INT_MASK_0          and save it back
                    ldd       #INT_PENDING_0      get the pending interrupt pending address
                    ldx       #0                  removing irq, set x=0
                    leay      SOL_IRQSvc,pcr      and the service routine
                    os9       F$IRQ               remove the interrupt handler
                    bcc       irqsuccess@
                    os9       F$Perr
irqsuccess@         clr       $FFD8               disable line interrupt
                    ldb       #-1                 V.SOLMax = -1 = empty table
                    stb       V.SOLMax,u
end@                puls      cc
                    rts
                    

***********************************************************************************
* SS.SOLMUTE
*
* Mute or Unmute Signals.  Use to temporarily disable signals to applications
*
* Entry: R$X = mute flag (0= unmute, 1=mute) 
*
* Exit:  B = non-zero error code
*       CC = carry flag clear to indicate success
SSOLMUTE            ldd       R$X,x               load flag 0=unmute, 1=mute
                    pshs      b                   store on stack
                    ldb       V.SOLMax,u          load max table offset
                    ldy       >D.Proc             location of calling proc pd
                    lda       P$ID,y              put pid in a
                    leay      V.SOLTable,u        get the address of the table
loop@               leay      b,y                 y = current row
                    cmpa      ,y                  if pid=table row pid. change mute
                    bne       next@               else go to next row
                    pshs      a                   store a
                    lda       1,s                 lda with mute value
                    sta       4,y                 store new mute value in row
                    puls      a                   restore a
next@               subb      #5                  set up for next row
                    bpl       loop@               loop if b >=0
                    puls      b                   clean stack
                    rts


***********************************************************************************
* SOL_IRQSvc
*
* IRQ service routine.  Send signal to process, then queue up next signal
*
* $FFD9 is the SOL Register for the line number to trigger IRQ
*
* ADDR |   DESC    |  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0   |
* FFD8 | LINT_CTRL |                                         |ENABLE|
* FFD9 | LINT_L    |  L7 |  L6 |  L5 |  L4 |  L3 |  L2 |  L1 |  L0  |
* FFDA | LINT_L    |                       | L11 | L10 |  L9 |  L8  |
*
SOL_IRQSvc          lda       #INT_VKY_SOL        clear pending interrupt
                    sta       INT_PENDING_0
                    lda       V.SOLMax,u
                    bmi       end@                safety check: Max should never be <0
                    ldb       V.SOLCurr,u         get current SOL index
                    leay      V.SOLTable,u        get the table
                    leay      b,y
                    lda       4,y
                    bne       nosenderr@          skip send if mute bit set
                    ldd       ,y                  load the current entry
                    os9       F$Send              Send it to the process
nosenderr@          ldb       V.SOLCurr,u
                    subb      #5
                    stb       V.SOLCurr,u         decrement the current index
                    bpl       cont@               if >=0 cont
                    ldb       V.SOLMax,u          else: reset to Max
                    stb       V.SOLCurr,u
cont@               leay      V.SOLTable,u
                    leay      b,y                 load next line value
                    ldd       2,y
                    std       $FFD9               write to SOL register
end@                rts


***********************************************************************************
* SS.SOLIRQ F$IRQ packet.
*
SOL_Pckt            equ       *
SOLPkt.Flip         fcb       %00000000           the flip byte
SOLPkt.Mask         fcb       INT_VKY_SOL         the mask byte
                    fcb       $F1                 the priority byte


                    emod
eom                 equ       *
                    end