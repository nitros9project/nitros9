********************************************************************
* PipeMan - OS-9 Pipe File Manager
*
* $Id: pipeman.asm,v 1.4 2003/08/27 23:44:50 boisy Exp $
*
* Some tests under NitrOS-9:
*
* 'show grf.3.a | eat'  (eat is cat, but just does a I$ReadLn, and not I$WritLn)
* April 10, 1996  14:05:15
* April 10, 1996  14:07:47
*          15.2 seconds per iteration
*          i.e. everything but the screen writes
*
* fast SCF+fast pipe
* 'show grf.3.a | cat', 10 times
* April 10, 1996  13:17:54
* April 10, 1996  13:21:57
*          24.3 seconds per iteration
*          9.1 solely for pipes
*
* fast SCF+old slow pipe
* April 10, 1996  13:30:24
* April 10, 1996  13:38:04
*          46.0 seconds per iteration
*          30.8 solely for pipes
*
*          speedup percent is (30.8-9.1)/30.8 = 70%
*
*          Pipes are more than doubled in speed!
*
* 32 byte read and write buffers
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   4      ????/??/??  Alan DeKok
* Enhanced and re-written.
*
*   5r0    2003/08/27  Boisy G. Pitre
* Back-ported from OS-9 Level Two to OS-9 Level One.
*   5r1    2020/11/12  L. Curtis Boyle
* Slight optimizations

                    nam       PipeMan
                    ttl       OS-9 Pipe File Manager

                    ifp1
                    use       defsfile
                    use       pipe.d
                    use       scf.d
                    endc

tylg                set       FlMgr+Objct
Rev                 set       $01
atrv                set       ReEnt+Rev
edition             set       5

                    mod       eom,name,tylg,atrv,start,size

                    rmb       $0000
size                equ       .


                    org       $0000
P.CPR               rmb       1                   process ID
P.CNT               rmb       1                   count
P.SIG               rmb       1                   signal code
P.FLAG              rmb       1                   raw/edit flag

name                fcs       /PipeMan/
                    fcb       edition

start               bra       Create
                    nop
                    bra       Open
                    nop
                    bra       MakDir
                    nop
                    bra       ChgDir
                    nop
                    bra       Delete
                    nop
Seek                clrb                          Seek returns with no error
                    rts
                    nop
                    bra       Read
                    nop
                    lbra      Write
                    bra       ReadLn
                    nop
                    lbra      WritLn
GetStt              clrb                          GetStt returns with no error
                    rts
                    nop
SetStt              clrb                          SetStt returns with no error
                    rts
                    nop
* Fall through to CLOSE here
Close               lda       PD.CNT,y            Get # of open images
                    bne       L008E               we have some, skip ahead
                    ldu       PD.BUF,y            if no one's using it, get it' buffer ptr
                    clrb                          D=$100 (256 bytes)
                    inca
                    os9       F$SRtMem            return the memory
                    clrb
                    rts

L008E               leax      PD.Read,y           Point to start of pipe READ vars ($A)
                    cmpa      PD.Read+P.CNT,y     is the read count zero?
                    beq       L009C               Yes, skip ahead
                    cmpa      PD.Writ+P.CNT,y     No, is the write count zero?
                    bne       L00A9               No, can't close yet, return w/o error
                    leax      PD.Writ,y           Point to start of pipe WRITE vars ($E)
L009C               lda       P.CPR,x             get process ID that's reading/writing
                    beq       L00A9               Exit w/o error if none
                    ldb       P.SIG,x             get signal code
                    beq       L00A9               none, return w/o error
                    clr       P.SIG,x             Clear signal code
                    os9       F$Send              send a wake-up signal to the process
L00A9               clrb
                    rts

* I$MakDir/I$ChgDir/I$Delete Entry Points
MakDir              equ       *
ChgDir
Delete
                    comb                          Exit with Unknown Service error
                    ldb       #E$UnkSvc
                    rts

*
* I$Create / I$Open entry Point
* Entry: A = access mode desired
*        X = address of the pathlist
*
* Exit:  A = pathnum
*        X = last byte of pathlist address
*
* Error: CC Carry set
*        B = errcode
*
Create              equ       *
Open                ldx       R$X,u               get address of filename to open
                    pshs      y                   save PD pointer
                    os9       F$PrsNam            parse /pipe
                    bcs       L007B               exit on error
                    IFGT      Level-1
                    ldx       <D.Proc             Get current process ptr
                    ldb       P$Task,x            get task number for call, below
                    leax      -1,y                back up one character
                    os9       F$LDABX             get last character of the filename
                    tsta                          check the character
                    ELSE
                    lda       -1,y
                    ENDC
                    bmi       L0060               if high bit set, it's OK
                    leax      ,y                  point to next bit
                    os9       F$PrsNam            else parse name
                    bcc       L007B               if no error, it's a sub-dir, and we error out
L0060               sty       R$X,u               save new pathname ptr
                    puls      y                   restore PD pointer
                    ldd       #$0100
                    os9       F$SRqMem            request one page (256 bytes) for the pipe
                    bcs       L007A               exit on error
                    stu       PD.BUF,y            save ptr to the buffer
                    stu       <PD.NxtI,y          save initial write position pointer
                    stu       <PD.NxtO,y          and initial read position pointer
                    leau      d,u                 point to the end of the buffer
                    stu       <PD.End,y           save as end ptr & return
L007A               rts

L007B               comb
                    ldb       #E$BPNam            bad path name
                    puls      pc,y

* I$ReadLn Entry Point
* Entry: Y = Path descriptor ptr
* Exit:
* Error: CC Carry set
*        B = errcode
*
ReadLn              ldb       #C$CR
                    fcb       $21                 skip one byte (BRN opcode)
* I$Read Entry Point
* Entry: Y = Path Dsc Ptr
* Exit:
* Error: CC Carry set
*        B = errcode
*
Read                clrb                          Flag not looking for CR line ends
                    stb       PD.Read+P.FLAG,y    Save read type flag
                    leax      PD.Read,y           Point to start of Read vars
                    lbsr      L0160               send wakeup signals to process
                    bcs       L0100               on error, wake up writing process
                    ldx       R$Y,u               Get # of bytes to Read
                    beq       L0100               If none,
                    ldd       R$X,u               start address to read from
                    leax      d,x                 add in number of bytes: end address
* NOTE: PD.RGS,Y will change as the processes read/write the pipe,
* and sleep.
                    pshs      u                   save current caller's register stack
                    leas      -32,s               reserve a 32-byte buffer on the stack
                    leau      ,s                  point to the start of the buffer
                    pshs      d,x                 save start, end to read
                    clrb                          no bytes read to user yet
                    puls      x                   restore number of data bytes read, read address
L00DB               bsr       L01F2               are we blocked?
                    bcs       L00C8               yes, send a signal
                    sta       b,u                 store the byte in the internal read buffer
                    leax      1,x                 go up by one byte
                    incb                          one more byte in the buffer
                    cmpb      #32                 reached maximum size of the buffer?
                    blo       L00E0               no, continue
                    bsr       read.out            read 32 bytes of data to the caller

L00E0               tst       PD.Read+P.FLAG,Y    was it a raw read?
                    beq       L00ED               skip ahead if raw
                    cmpa      #C$CR               was the character a CR?
                    beq       L00F1               yes, we're done: flush and exit
L00ED               cmpx      ,s                  or at end of data to read?
                    blo       L00DB               no, keep reading

L00F1               bsr       read.out            flush the rest of the pipe buffer to the user
L00F2               tfr       x,d                 this is how far we got
                    subd      ,s++                take out start of buffer
                    leas      32,s                kill our on-stack buffer
                    puls      u                   restore caller's register stack ptr: NOT PD.RGS,Y
                    addd      R$Y,u               add in number of bytes
                    std       R$Y,u               save bytes read
                    bne       L00FF               if not zero
                    ldb       #E$EOF              zero bytes read:EOF error
                    fcb       $21                 skip one byte (BRN)
L00FF               clrb                          no errors
L0100               leax      PD.Read,y           read data ptr
                    lbra      L01BD               signal other it's OK to go ahead

read.out            pshs      a,x,y,u             save registers
                    tstb                          any data to write?
                    beq       read.ex             no, skip ahead
                    IFGT      Level-1
                    clra                          make 16-bit data length
                    tfr       d,y                 number of data bytes to read to user
                    negb                          make it negative
                    leax      b,x                 back up TO pointer
                    pshs      x                   save it
                    leax      ,u                  point to the start of the buffer
                    ldu       <D.Proc             current process pointer
                    ldb       P$Task,u            A=$00 from above, already
                    puls      u                   restore TO pointer
                    os9       F$Move              move the data over
                    clrb                          no bytes read to the caller yet
                    ELSE
                    tfr       b,a                 copy byte count to A
                    nega                          make it negative
                    leax      a,x                 back up TO pointer
ReadLoop            lda       ,u+
                    sta       ,x+
                    decb
                    bne       ReadLoop
                    ENDC
read.ex             puls      a,x,y,u,pc          restore registers and exit

L00C8               pshs      x                   save read pointer
                    bsr       read.out            dump data out to the user
                    pshs      b                   save number of bytes read
                    leax      PD.Read,y           read data area ptr
                    lbsr      L018B               setup for signal
                    puls      x,b                 restore registers: note B=$00, but we CANNOT do a
                    bcc       L00DB               clrb, because this line needs CC.C!
                    bra       L00F2               don't write data out again, but exit

* Check if we're blocked
L01F2               lda       <PD.RFlg,y          we blocked?
                    bne       L01F9               no, skip ahead
                    coma                          set flag: blocked
                    rts                           and return to the caller

L01F9               pshs      x                   save read ptr
                    ldx       <PD.NxtO,y          where to read from in the buffer
                    lda       ,x+                 get a byte
                    cmpx      <PD.End,y           at the end of the buffer?
                    blo       L0207               no, skip ahesd
                    ldx       PD.BUF,y            yes, go to start
L0207               stx       <PD.NxtO,y          save new read ptr
                    cmpx      <PD.NxtI,y          caught up to the write pointer yet?
                    bne       L0212               no, skeip ahead
                    clr       <PD.RFlg,y          yes, set read is blocked
L0212               andcc     #^Carry             no errors
                    puls      pc,x                restore regs and exit

* ? (Attempt to add new pipe, or signal process that is using current pipe?)
L0160               lda       P.CPR,x             get current pipe process #
                    beq       L0185               None, copy process # to current pipe process #
                    cmpa      PD.CPR,y            Is current pipe process # same as paths process?
                    beq       L0189               No, return w/o error
                    inc       P.CNT,x             one more process using this pipe
                    ldb       P.CNT,x             Get # processes using this pipe
                    cmpb      PD.CNT,y            same as the number for this path?
                    bne       L0173               no, skip ahead
                    lbsr      L009C               yes, send a wake-up signal
L0173               os9       F$IOQu              and insert it in the others IO queue
                    dec       P.CNT,x             decrement # processes using this pipe
                    pshs      x                   Save current pipe vars ptr
                    ldx       <D.Proc             current process ptr
                    ldb       <P$Signal,x         Get it's signal code
                    puls      x                   Restore current pipe vars ptr
                    beq       L0160               if no signal code sent, do another process
                    coma                          otherwise return CC.C set, and B=signal code
                    rts

L0185               ldb       PD.CPR,y            grab current path's process #
                    stb       P.CPR,x             save as current current pipe's process #
L0189               clrb                          no errors & return
                    rts

L01CC               pshs      b,x                 save regs
                    ldx       <PD.NxtI,y
                    ldb       <PD.RFlg,y          0=READ, 1=WRITE
                    beq       L01DE               was reading, set to write and continue
                    cmpx      <PD.NxtO,y          caught up to the read pointer yet?
                    bne       L01E3
                    comb
                    puls      pc,x,b

L01DE               inc       <PD.RFlg,y          set to writing into the pipe
L01E3               sta       ,X+                 save the byte
                    cmpx      <PD.End,y           if at the end of the buffer
                    blo       L01EC
                    ldx       PD.BUF,y            reset to the beginning
L01EC               stx       <PD.NxtI,y
                    clrb
                    puls      pc,x,b

* Start of write routines
write.in            pshs      a,x,y               save registers
                    leau      -32,u               point to the start of the buffer again
                    IFGT      Level-1
                    ldx       <D.Proc             current process pointer
                    lda       P$Task,x            get FROM task number for this process
                    ldx       1,s                 get FROM pointer
                    ldy       #32                 16 bytes to grab
                    clrb                          TO the system task
                    os9       F$Move
                    ELSE
                    ldb       #31
WritLoop            lda       b,x
                    sta       b,u
                    decb
                    bpl       WritLoop
                    ENDC
                    ldb       #32                 16 bytes in the buffer
                    puls      a,x,y,pc

*
* I$WritLn Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
WritLn              ldb       #$0D
                    fcb       $21                 skip one byte

*
* I$Write Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
Write               clrb
                    stb       <PD.Writ+P.FLAG,y
                    leax      PD.Writ,y
                    bsr       L0160               make sure it's OK
                    bcs       L015C
                    ldx       R$Y,u               get number of bytes to write
                    beq       L015C
                    ldd       R$X,u               start address
                    leax      d,x                 add in number of bytes
                    pshs      u
                    leau      ,s                  point to the end of the buffer
                    leas      -32,s
                    pshs      d,x                 save start, end
                    ldx       ,s                  get initial start pointer
                    bsr       write.in            fill the write buffer
                    puls      x
L0137               lda       ,u
                    bsr       L01CC               save it in the buffer
                    bcs       L0124               caught up to reading process yet?
                    leax      1,x                 up by one byte
                    leau      1,u
                    decb
                    bne       L0138
                    bsr       write.in            fill the buffer again
L0138               tst       <PD.Writ+P.FLAG,y
                    beq       L014B
                    cmpa      #C$CR               at the end of a line to output?
                    beq       L014F
L014B               cmpx      ,S                  at end yet?
                    blo       L0137               if not, read more data
L014F               clrb                          clear carry and error
L0150               ldu       2+32,s              skip END, 32-byte write buffer, get U
                    pshs      b,cc
                    tfr       x,d
                    subd      $02,s               take out end address
                    addd      R$Y,u               add in number of bytes
                    std       R$Y,u               save bytes written
                    puls      x,b,cc
                    leas      32,s                kill write buffer
                    puls      u
L015C               leax      PD.Writ,y           Point to Write vars for current pipe
* can probably lose saving 'U' in next few lines... but only minor difference
* Signal read/write it's OK to go ahead
L01BD               pshs      u,b,cc
                    clr       P.CPR,x             Flag NO process currently using this device
                    bsr       Other               Swap read/write role, and signal that process
                    puls      pc,u,b,cc

L0124               pshs      x,b
                    leax      PD.Writ,y
                    bsr       L018B               send signal to other
                    tfr       b,a                 save error code, if applicable
                    puls      x,b                 restore pointer, byte count
                    bcc       L0137               continue if OK
                    tfr       a,b                 otherwise restore error code
                    bra       L0150               exit, returning the error code to the user

* Set up for signal
L018B               ldb       P.CNT,x
                    incb
                    cmpb      PD.CNT,y
                    beq       L01B9
                    stb       P.CNT,x
                    ldb       #$01
                    stb       P.SIG,x
                    clr       PD.CPR,y
                    pshs      x
                    bsr       Other
                    ldx       #$0000              make X=0
                    os9       F$Sleep             sleep forever
                    ldx       <D.Proc
                    ldb       <P$Signal,x         get signal code
                    puls      x
                    dec       P.CNT,x
                    tstb
                    bne       L01BB               if a signal, we can't wake up
                    clrb                          the writing process
                    rts

L01B9               ldb       #E$Write            write error
L01BB               coma
                    rts

* Swap ptr in X between PD.Writ and PD.Read
* (since 4 bytes apart, & always even 256 byte page, just flip bit in address)
Other               exg       x,d
                    eorb      #$04                if r/w go to w/r
                    exg       d,x
                    lbra      L009C

                    emod
eom                 equ       *
                    end
