**************************************************
* System Call: F$AllPrc
*
* Function: Allocate process descriptor
*
* Input:  None
*
* Output: U = Process descriptor pointer
*
* Error:  CC = C bit set; B = error code
*
FAllPrc             pshs      u         ; preserve register stack pointer
                    bsr       AllPrc    ; try & allocate descriptor
                    bcs       L02E8     ; can't do, return
                    ldx       ,s        ; get register stack pointer
                    stu       R$U,x     ; save pointer to new descriptor
L02E8               puls      u,pc      ; restore & return
* Allocate a process desciptor
* Entry: None
AllPrc              ldx       <D.PrcDBT ; get pointer to process descriptor block table
L02EC               lda       ,x+       ; get a process block #
                    bne       L02EC     ; used, keep looking
                    leax      -1,x      ; point to it again
                    tfr       x,d       ; move it to D
                    subd      <D.PrcDBT ; subtract pointer to table (gives actual prc. ID)
                    tsta                ; id valid?
                    beq       L02FE     ; yes, go on
                    comb                ; set carry
                    ldb       #E$PrcFul ; get error code
                    rts                 ; return with error

L02FE               pshs      b         ; save process #
                    ldd       #P$Size   ; get size of descriptor
                    os9       F$SRqMem  ; request the memory for it
                    puls      a         ; restore process #
                    bcs       L032F     ; exit if error from mem call
                    sta       P$ID,u    ; save ID to descriptor
                    tfr       u,d       ; transfer register value u,d
                    sta       ,x        ; save ID to process descriptor table
* Clear out process descriptor through till stack
                  IFNE    H6309   ; begin conditional assembly for H6309
                    leay      <Null3,pc ; point to 0 byte
                    leax      P$PID,u   ; point to start of part to clear
                    ldw       #$0100    ; 256 bytes to clear
Null3               equ       *-1       ; define assembler symbol Null3
                    tfm       y,x+      ; transfer memory block using y,x+
                  ELSE
* LCB - 6809 optimization- ldd #$80 / ldx #$0000
                    leay      P$PID,u   ; 5 Point to start of process descriptor
                    ldb       #$80      ; 2 # of 2 byte sets to clear
                    ldx       #$0000    ; 3 Value to clear with
LChinese            stx       ,y++      ; 8 \                Clear 2 bytes
                    decb                ; 2  > 1664 cycles   dec ctr
                    bne       LChinese  ; 3 /                Keep going until done

* original code:
*         clra               2
*         clrb               2
*         leax   P$PID,u     5
*         ldy    #$80        4
*LChinese std    ,x++        8 \
*         leay   -1,y        5  > 2048 cycles
*         bne   LChinese     3 /
                  ENDC

***************************************************************************
* OS-9 L2 Upgrade Enhancement: Stamp current date/time for start of process
*         ldy    <D.Proc        get current process descriptor
*         ldx    <D.SysProc    get system process descriptor
*         stx    <D.Proc        make system process current
*         leax   P$DatBeg,u    new proc desc creation date/time stamp
*         os9    F$Time        ignore any error...
*         sty    <D.Proc        restore current proc desc address
***************************************************************************

                    lda       #SysState ; set process to system state
                    sta       P$State,u ; store A at P$State,u
* Empty out DAT image
                    ldb       #DAT.BlCt ; # of double byte writes
                    ldx       #DAT.Free ; empty block marker
                    leay      P$DATImg,u ; compute P$DATImg,u into Y
L0329               stx       ,y++      ; store X at ,y++
                    decb                ; done?
                    bne       L0329     ; no, keep going
                    clrb                ; clear carry
L032F               rts                 ; return

**************************************************
* System Call: F$DelPrc
* Function: Deallocate Process Descriptor
* Input:  A = Process ID
* Output: None
* Error:  CC = C bit set; B = error code
*
FDelPrc             lda       R$A,u     ; get process #
                    bra       L0386     ; delete it


**************************************************
* System Call: F$Wait
*
* Function: Wait for child process to die
*
* Notes:
* Checks all children to see if any died (done through linked
* child process list through P$CID for 1st one & P$SID for rest)
* Will stick process into Wait Queue until either Waiting process
* receives signal or until child dies. Child dying does NOT send
* signal to parent.
*
* Input:  None
*
* Output: A = Deceased child process' process ID
*         B = Child process' exit status code
*
* Error:  CC = C bit set; B = error code
*
FWait               ldx       <D.Proc   ; get current process
                    lda       P$CID,x   ; any children?
                    beq       L0368     ; no, exit with error
L033A               lbsr      L0B2E     ; get pointer to child process dsc. into Y
                  IFNE    H6309   ; begin conditional assembly for H6309
                    tim       #Dead,P$State,y ; is child dead?
                  ELSE
                    lda       P$State,y ; load A from P$State,y
                    bita      #Dead     ; test bits in A against #Dead
                  ENDC
                    bne       L036C     ; yes, send message to parent
                    lda       P$SID,y   ; no, check for another child (thru sibling list)
                    bne       L033A     ; yes there is another child, go see if it is dead
* NOTE: MAY WANT TO ADD IN CLRB, CHANGE TO STD R$A,u
                    sta       R$A,u     ; no child has died, clear out process # & status
                    sta       R$B,u     ; code in caller's A&B regs
                    pshs      cc        ; preserve CC
                    orcc      #IntMasks ; shut off interrupts
                    lda       <P$Signal,x ; any signals pending?
                    beq       L035D     ; no, skip ahead
* No Child died, but received signal
                    deca                ; yes, is it a wakeup signal?
                    bne       L035A     ; no, wake it up with proper signal
                    sta       <P$Signal,x ; clear out signal code
L035A               lbra      L071B     ; go wake it up (no signal will be sent)

* No dead child & no signal...execute next F$Waiting process in line
L035D               ldd       <D.WProcQ ; get ptr to head of waiting process line
                    std       P$Queue,x ; save as next process in line from current one
                    stx       <D.WProcQ ; save curr. process as new head of waiting process line
                    puls      cc        ; restore interupts
                    lbra      L0780     ; go activate next process in line

L0368               comb                ; exit with No Children error
                    ldb       #E$NoChld ; load B from #E$NoChld
                    rts                 ; return to caller

* Child has died
* Entry: Y=Ptr to child process that died
*        U=Ptr to caller's register stack
L036C               lda       P$ID,y    ; get process ID of dead child
                    ldb       <P$Signal,y ; get signal code that child received (if any)
                    std       R$D,u     ; save in caller's D
                    leau      ,y        ; point U to child process dsc.
                    leay      P$CID-P$SID,x ; bump Y up by 1 for 1st loop so P$SID below
*                             actually references P$CID
                    bra       L037C     ; skip ahead

* Update linked list of sibling processes to exclude dead child
L0379               lbsr      L0B2E     ; get pointer to process
L037C               lda       P$SID,y   ; get Sibling ID (or Child ID on 1st run)
                    cmpa      P$ID,u    ; same as Dying process ID?
                    bne       L0379     ; no, go get ptr to Sibling process & do again
                    ldb       P$SID,u   ; yes, wrapped to our own, get Sibling ID from child
                    stb       P$SID,y   ; save as sibling process id # in other sibling
L0386               pshs      d,x,u     ; preserve regs
                    cmpa      WGlobal+G.AlPID ; does dying process have an alarm set up?
                    bne       L0393     ; no, go on
                  IFNE    H6309   ; begin conditional assembly for H6309
                    clrd                ; faster than 2 memory clears
                  ELSE
                    clra                ; clear A
                    clrb                ; clear B
                  ENDC
                    std       WGlobal+G.AlPID ; clear alarm ID & signal
L0393               ldb       ,s        ; get dying process # back
                    ldx       <D.PrcDBT ; get ptr to process descriptor block table
                    abx                 ; offset into table
                    lda       ,x        ; get MSB of process dsc. ptr
                    beq       L03AC     ; if gone already, exit
                    clrb                ; clear B
                    stb       ,x        ; clear out entry in block table
                    tfr       d,x       ; move process dsc. ptr to X
                    os9       F$DelTsk  ; remove task # for this process
                    leau      ,x        ; point U to start of Dead process dsc.
                    ldd       #P$Size   ; size of a process dsc.
                    os9       F$SRtMem  ; deallocate process dsc. from system memory pool
L03AC               puls      d,x,u,pc  ; restore regs & return
