********************************************************************
* RFM - Remote File Manager
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2010/02/20  Aaron Wolfe
* initial version - just sends ops to server

                    nam       RFM
                    ttl       Remote File Manager

                    ifp1
                    use       defsfile
                    use       rfm.d
                    use       drivewire.d
                    endc

tylg                set       FlMgr+Objct
atrv                set       ReEnt+rev
rev                 set       0
edition             equ       1

                    mod       eom,RFMName,tylg,atrv,RFMEnt,size

size                equ       .


RFMName             fcs       /RFM/
                    fcb       edition

******************************
* Sends the RFM Header to the server
*
* The RFM header consists of:
* - Byte 0: OP_RFM
* - Byte 1: RFM transaction code
* - Byte 2: Process ID of the process
* - Byte 3: Path number (0-15)
* - Byte 4: Path descriptor address (MSB)
* - Byte 5: Path descriptor address (LSB)
*
* Entry: B = RFM transaction code
*        Y = Path descriptor
*        U = Caller's registers
SendRFMHeader       pshs      d,x,y,u
                    ldb       PD.PD,y             get PD.PD into B
                    ldx       <D.Proc             get calling process descriptor
                    lda       P$ID,x              get the process ID
                    pshs      d,y
                    ldb       4,s
                    lda       #OP_VFM
                    pshs      d
                    leax      ,s
                    ldy       #6
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       6,u
                    leas      6,s                    
                    puls      d,x,y,u,pc
                    
******************************
*
* file manager entry point
*
RFMEnt              lbra      create              Create path
                    lbra      open                Open path
                    lbra      makdir              Makdir
                    lbra      chgdir              Chgdir
                    lbra      delete              Delete
                    lbra      seek                Seek
                    lbra      read                Read character
                    lbra      write               Write character
                    lbra      readln              ReadLn
                    lbra      writln              WriteLn
                    lbra      getstt              Get Status
                    lbra      setstt              Set Status
                    lbra      close               Close path


******************************
*
* Create - creates a file on the remote device
*
* Entry: Y = Path descriptor pointer
*        U = Callers register stack pointer
*
create              ldb       #DW.create
                    bra       create1


******************************
*
* Open - opens a file on the remote device
*
* Send the RFM Header plus: 
* - Byte 6: Mode byte
* - Byte 7: Pathname length (MSB)
* - Byte 8: Pathname length (LSB)
* - Bytes 9-n: Pathname
*
* Get back:
* error number, 4 bytes
* If error number is = 0, 3 bytes is the unique identifier of the directory.
* If error number is != 0, 3 bytes are ignored.
*
* Entry: Y = Path descriptor pointer
*        U = Callers register stack pointer
*
* Exit:  CC.Carry = 0 (no error), 1 (error)
*        B = error code (if CC.Carry == 1)
*
open                ldb       #DW.open
create1             bsr       SendRFMHeader
                    ldx       PD.DEV,y            ; get ptr to our device memory
                    ldx       V$STAT,x            ; get ptr to our static storage
                    pshs      x,y,u               ; save all on stack

* TODO lets not create multiple buffers when multiple open/create on same path
* get system mem
                    ldd       #256
                    os9       F$SRqMem            ; ask for D bytes (# bytes server said is coming)
                    lbcs      openerr
                    stu       V.BUF,x

* use PrsNam to validate pathlist and count length
                    ldu       4,s                 ; get pointer to caller's registers
                    ldy       R$X,u
                    sty       V.PATHNAME,x
                    tfr       y,x
prsloop             os9       F$PrsNam
                    lbcs      openerr
                    tfr       y,x
                    anda      #$7F
                    cmpa      #PENTIR
                    bne       chkdelim
                    ldb       #E$BPNam
                    bra       openerr
chkdelim            cmpa      #PDELIM
                    beq       prsloop
* at this point X points to the character AFTER the last character in the name
* update callers R$X
                    ldu       4,s                 ; get caller's registers
                    stx       R$X,u

* compute the length of the pathname and save it
                    tfr       x,d
                    ldx       ,s                  ; get the device memory pointer
                    subd      V.PATHNAME,x
                    std       V.PATHNAMELEN,x     ; save the length

* put the mode byte on the stack
                    pshs      cc                  save CC
                    tfr       d,y
                    ldb       R$A,u               get caller's mode byte
                    pshs      b,y
                    leax      ,s                  point X to stack
                    ldy       #3                  send mode byte and pathname length

                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc

                    orcc      #IntMasks
                    jsr       6,u
                    leas      3,s                 clean up the stack

                    ifgt      Level-1
* now send path string
* move from caller to our mem

                    ldx       <D.Proc             get calling proc desc
                    lda       P$Task,x            ; A = callers task # (source)

                    ldb       <D.SysTsk           ; B = system task # (dest)
                    endc

                    ldx       1,s                 ; get device mem ptr
                    ifgt      Level-1
                    ldu       V.BUF,x             ; get destination pointer in U
                    endc
                    ldy       V.PATHNAMELEN,x     ; get count in Y
                    ldx       V.PATHNAME,x        ; get source in X

                    ifgt      Level-1
*  F$Move the bytes (seems to work)
                    pshs      x,y
                    os9       F$Move
                    puls      x,y
                    bcs       moverr
                    endc

                    ifgt      Level-1
                    tfr       u,x
                    else
                    tfr       x,u
                    endc
                    pshs      x,y                   save pointer to pathname and length of pathname on stack

* send to server
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    ldy       #2
                    leax      2,s
                    jsr       6,u
                    puls      x,y
                    jsr       6,u
                    
* read response from server -> B + 3 byte unique ID
                    leas      -4,s
                    leax      ,s
                    ldy       #4
                    jsr       3,u

* pull server's response into B
                    puls      b                   ; PD.PD Regs
                    puls      a,x
moverr              puls      cc
                    tstb
                    bne       openerr
                    ldy       2,s         recover path descriptor pointer
                    sta       PD.FD,y
                    stx       PD.FD+1,y
                    bra       ex@
openerr             coma                          ; set error
ex@                 puls      x,y,u,pc


******************************
*
* MakDir - creates a directory on the remote device
*
* Entry: Y = Path descriptor pointer
*        U = Callers register stack pointer
*
* Exit:  CC.Carry = 0 (no error), 1 (error)
*        B = error code (if CC.Carry == 1)
*
makdir              lda       #DW.makdir
                    lbra      SendRFMHeader

******************************
*
* ChgDir - changes the data/execution directory on the remote device
*
* Entry: Y = Path descriptor pointer
*        U = Callers register stack pointer
*
* Exit:  CC.Carry = 0 (no error), 1 (error)
*        B = error code (if CC.Carry == 1)
*
ChgDir              pshs      y                   preserve path descriptor pointer
                    ifne      H6309
                    oim       #DIR.,PD.MOD,y      ensure the directory bit is set
                    else
                    lda       PD.MOD,y            get mode from caller,
                    ora       #DIR.               add the directory bit,
                    sta       PD.MOD,y            and save back to pd.
                    endc
                    ldb       #DW.chgdir
                    lbsr      create1
                    bcs       Clos2A0             exit on error
                    ldx       <D.Proc             get current process pointer
                    ldu       PD.FD+1,y           get LSW of file descriptor sector #
                    ldb       PD.MOD,y            get current file mode
                    bitb      #UPDAT.             read or write mode?
                    beq       CD30D               no, skip ahead
* Change current data dir
                    ldb       PD.FD,y
                    stb       P$DIO+3,x
                    stu       P$DIO+4,x
CD30D               ldb       PD.MOD,y            get current file mode
                    bitb      #EXEC.              is it execution dir?
                    beq       CD31C               no, skip ahead
* Change current execution directory
                    ldb       PD.FD,y
                    stb       P$DIO+9,x
                    stu       P$DIO+10,x
CD31C               clrb                          clear errors
Clos2A0             puls      y

* Generalized return to system
Rt100Mem            pshs      b,cc                preserve error status
                    ldu       PD.BUF,y            get sector buffer pointer
                    beq       RtMem2CF            none, skip ahead
                    ldd       #$0100              get size of sector buffer
                    os9       F$SRtMem            return the memory to system
RtMem2CF            puls      pc,b,cc             restore error status & return

******************************
*
* Delete - delete a file on the remote device
*
* Entry: Y = Path descriptor pointer
*        U = Callers register stack pointer
*
* Exit:  CC.Carry = 0 (no error), 1 (error)
*        B = error code (if CC.Carry == 1)
*
delete              lda       #DW.delete
                    lbra      SendRFMHeader


******************************
*
* Seek - seeks into a file on the remote device
*
* Entry: Y = Path descriptor pointer
*        U = Callers register stack pointer
*
* Exit:  CC.Carry = 0 (no error), 1 (error)
*        B = error code (if CC.Carry == 1)
*
* Byte 0: OP_VFM
* Byte 1: DW.Seek
* Byte 2: PD Pointer (MSB)
* Byte 3: PD Pointer (LSB)
* Byte 4: Path number
* Byte 5: Bits 31-24 of the seek position
* Byte 6: Bits 23-16 of the seek position
* Byte 7: Bits 15-8 of the seek position
* Byte 8: Bits 7-0 of the seek position
seek                pshs      y,u

                    ldx       R$U,u
                    pshs      x
                    ldx       R$X,u
                    pshs      x
                    lda       PD.PD,y
                    pshs      a
                    pshs      y
                    ldd       #OP_VFM*256+DW.seek
                    pshs      d

                    leax      ,s                  ; point X to stack
                    ldy       #9                  ; 7 bytes to send

* set U to dwsub
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc

* send dw op, rfm op, path #
                    jsr       6,u
                    leas      8,s                 ;clean stack - PD.PD Regs

* read response from server
                    leax      ,s
                    ldy       #1
                    jsr       3,u

                    puls      b
                    tstb
                    beq       ok@
                    coma
                    bra       notok@
ok@                 clrb
notok@              puls      y,u,pc


******************************
*
* Read - reads data from a file on the remote device
*
* Entry: Y = Path descriptor pointer
*        U = Callers register stack pointer
*
* Exit:  CC.Carry = 0 (no error), 1 (error)
*        B = error code (if CC.Carry == 1)
*
read                
                    ldb       #DW.read
                    bra       read1               ; join readln routine



******************************
*
* Write - writes data to a file on the remote device
*
* Entry: Y = Path descriptor pointer
*        U = Callers register stack pointer
*
* Exit:  CC.Carry = 0 (no error), 1 (error)
*        B = error code (if CC.Carry == 1)
*
write               ldb       #DW.write
                    lbra      write1



******************************
*
* ReadLn - reads a line of data from a file on the remote device
*
* Entry: Y = Path descriptor pointer
*        U = Callers register stack pointer
*
* Exit:  CC.Carry = 0 (no error), 1 (error)
*        B = error code (if CC.Carry == 1)
*
readln              ldb       #DW.readln
read1
                    pshs      b
                    ldd       R$Y,u            get bytes to read
* read in increments of no more than 256 bytes
l@                  pshs      d
                    cmpd      #256             greater than max to read?
                    ble       go@
                    ldd       #256
go@                 std       R$Y,u
                    ldb       2,s
                    bsr       readcore
                    bcs       ex2@
                    puls      d
                    subd      R$Y,u
                    cmpd      #0000
                    beq       ex@
                    pshs      d
                    ldd       R$X,u
                    addd      R$Y,u
                    std       R$X,u
                    puls      d
                    bra       l@
ex@                 leas      1,s
                    rts
ex2@                leas      3,s
                    rts
                    
readcore
                    ldx       PD.DEV,y            ; to our static storage
                    ldx       V$STAT,x
                    pshs      x,y,u
* put path # on stack
                    ldx       PD.RGS,y
                    ldx       R$Y,x     get number of bytes to read
                    pshs      x   put on the stack
                    lda       PD.PD,y
                    pshs      a                   ; p# PD.PD Regs
                    pshs      y                   push path descriptor on stack
* put rfm op and DW op on stack

                    lda       #OP_VFM
                    pshs      d                   ; DWOP RFMOP p# PD.PD Regs

                    leax      ,s                  ; point X to stack
                    ldy       #7                  ; 7 bytes to send

* set U to dwsub
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc

* send dw op, rfm op, path #
                    jsr       6,u

                    leas      4,s                 ; leave 3 bytes for server response in next section

* read 1 byte error code and 2 byte read count from the host
                    leax      ,s
                    ldy       #3
                    jsr       3,u

                    puls      b,y               get error in B and count in Y


* check for error
                    tstb                        error code 0?
                    bne       readlnerr         branch if not -- error

* read the data from server if > 0
* load data from server into mem block
                    ldx       2,s                 get path descriptor in X
                    ldx       PD.RGS,x            get caller's registers in X
                    ifgt      Level-1
                    ldx       ,s                  get V$STAT
                    ldx       V.BUF,x             get pointer to our allocated buffer in X
                    else
                    ldx       R$X,x               get caller's X (buffer pointer) in X
                    endc
                    sty       R$Y,x               update read length to caller's Y

* Send ACK byte (doesn't matter what it is, just alerts the server that we're ready to receive the data)
                    lda       #66
                    pshs      a,x,y               save off A (junk), X (buffer pointer), Y (read length)
                    leax      ,s                  point X to the stack to write an ack byte
                    ldy       #1                  write one byte
                    jsr       6,u                 write that byte

* Now read the data                    
                    puls      a,x,y               recover A (junk), X (buffer pointer), Y (read length)
                    jsr       3,u                 read Y bytes

* F$Move
* a = my task #
* b = caller's task #
* X = source ptr
* Y = byte count
* U = dest ptr

* move from our mem to caller

                    ifgt      Level-1
                    ldx       2,s                 get path descriptor in X
                    ldx       PD.RGS,x            get caller's registers in X
                    ldu       R$X,x               get caller's X (buffer pointer) in U
                    ldy       R$Y,x               gert caller's Y (updated read length) in Y

                    lda       <D.SysTsk           ; A = system task #

                    ldx       <D.Proc             get calling proc desc
                    ldb       P$Task,x            ; B = callers task #

                    ldx       ,s                  ; V$STAT     - PD Regs
                    ldx       V.BUF,x

*  F$Move the bytes (seems to work)
                    os9       F$Move
                    endc
                    puls      x,y,u,pc
readlnerr
                    coma
                    puls      x,y,u,pc




******************************
*
* WritLn - writes a line of data to a file on the remote device
*
* Entry: Y = Path descriptor pointer
*        U = Callers register stack pointer
*
* Exit:  CC.Carry = 0 (no error), 1 (error)
*        B = error code (if CC.Carry == 1)
*
writln              ldb       #DW.writln

write1              ldx       PD.DEV,y            ; to our static storage
                    ldx       V$STAT,x
                    pshs      x,y,u               ; Vstat pd regs

* put path # on stack
                    lda       PD.PD,y
                    pshs      cc                  ; cc vstat pd regs
                    pshs      a                   ; p# cc vstat PD Regs

* put rfm op and DW op on stack

                    lda       #OP_VFM
                    pshs      d                   ; DWOP RFMOP p# cc vstat PD.PD Regs

                    leax      ,s                  ; point X to stack
                    ldy       #3                  ; 3 bytes to send

* set U to dwsub
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc

* send dw op, rfm op, path #
                    orcc      #IntMasks
                    jsr       6,u
                    leas      3,s                 ;clean stack - cc vstat PD.PD Regs

* put caller's Y on stack (maximum allowed bytes)
                    ldx       5,s
                    ldx       R$Y,x
                    pshs      x                   ;bytes cc vstat PD.PD Regs

* send 2 bytes from stack
                    leax      ,s
                    ldy       #2
                    jsr       6,u

* move caller's data into our buf

* F$Move
* a = my task #
* b = caller's task #
* X = source ptr
* Y = byte count
* U = dest ptr

                    puls      y                   ;Y = byte count (already set?)  cc vstat PD.PD Regs

                    ifgt      Level-1

                    ldb       <D.SysTsk           ; dst B = us

                    pshs      u                   ; dwsub  cc vstat PD.PD Regs
                    ldx       3,s
                    ldu       V.BUF,x             ; dst U = our v.buf

                    ldx       <D.Proc             get calling proc desc
                    lda       P$Task,x            ; src A = callers task #

                    ldx       7,s                 ; orig U
                    ldx       R$X,x               ; src = caller's X


*  F$Move the bytes
                    os9       F$Move

                    *         send                v.buf to server

                    puls      u                   ;      cc vstat PD.PD Regs
                    ldx       1,s
                    ldx       V.BUF,x
                    else
                    ldx       5,s
                    ldx       R$X,x
                    endc

                    jsr       6,u

                    puls      cc                  ; vstat PD.PD Regs
                    bra       writln2
* error exit?

writln2             puls      x,y,u,pc








******************************
*
* GetStat - obtain status of file on the remote device
*
* Entry: Y = Path descriptor pointer
*        U = Callers register stack pointer
*
* Exit:  CC.Carry = 0 (no error), 1 (error)
*        B = error code (if CC.Carry == 1)
*
getstt
                    lda       PD.PD,y
                    lbsr      sendgstt

                    ldb       R$B,u               get function code
                    beq       GstOPT
                    cmpb      #SS.EOF
                    beq       GstEOF
                    cmpb      #SS.Ready
                    beq       GstReady
                    cmpb      #SS.Size
                    beq       GstSize
                    cmpb      #SS.Pos
                    beq       GstPos
                    cmpb      #SS.FD
                    beq       GstFD
                    cmpb      #SS.FDInf
                    beq       GstFDInf
                    cmpb      #SS.DirEnt
                    beq       GstDirEnt
*               comb
*               ldb       #E$UnkSvc
                    clrb
                    rts

* SS.OPT
* RFM does nothing here, so we do nothing
GstOPT
                    rts

* SS.EOF
* Entry A = path
*       B = SS.EOF
GstEOF
                    rts

* SS.Ready - Check for data available on path
* Entry A = path
*       B = SS.Ready
GstReady
                    clr       R$B,u               always mark no data ready
                    rts

* SS.Size - Return size of file opened on path
* Entry A = path
*       B = SS.SIZ
* Exit  X = msw of files size
*       U = lsw of files size
GstSize             pshs   x,y,u
                    leas   -5,s
                    leax   ,s
                    ldy    #5
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       3,u
                    puls      b
                    tstb
                    bne       err@
                    puls      x,y
                    ldu       4,s
                    stx       R$X,u
                    sty       R$U,u
                    puls   x,y,u,pc
err@                leas   10,s                    
                    coma
                    rts
                    
* SS.Pos - Return the current position in the file
* Entry A = path
*       B = SS.Pos
* Exit  X = msw of pos
*       U = lsw of pos
GstPOS
                    rts

* SS.FD - Return file descriptor sector
* Entry: A = path
*        B = SS.FD
*        X = ptr to 256 byte buffer
*        Y = # of bytes of FD required

* path # and SS.FD already sent to server, so
* send Y, recv Y bytes, get them into caller at X
* Y and U here are still as at entry
GstFD
                    ldx       PD.DEV,y
                    ldx       V$STAT,x
                    pshs      x,y,u

                    *         send                caller's Y (do we really need this to be 16bit?  X points to 256byte buff?
                    ldx       R$Y,u
                    pshs      x
                    leax      ,s
                    ldy       #2

                    *         set                 U to dwsub
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc

                    jsr       6,u

                    *         recv                bytes into v.buf
                    puls      y
                    ldx       ,s                  ; V$STAT
                    ldx       V.BUF,x

                    ifgt      Level-1
                    pshs      x
                    endc

                    jsr       3,u

                    ifgt      Level-1
                    *         move                v.buf into caller

                    ldx       4,s
                    ldu       R$X,x               ; U = caller's X = dest ptr
                    sty       R$Y,x               ; do we need to set this for caller?

                    lda       <D.SysTsk           ; A = system task #

                    ldx       <D.Proc             get calling proc desc
                    ldb       P$Task,x            ; B = callers task #

                    puls      x                   ; V.BUF from earlier

*  F$Move the bytes (seems to work)
                    os9       F$Move

                    else
                    endc

* assume everything worked (not good)
                    clrb

                    puls      x,y,u,pc


* SS.FDInf -
* Entry: A = path
*        B = SS.FDInf
*        X = ptr to 256 byte buffer
*        Y = msb - Length of read
*              lsb - MSB of LSN
*        U = LSW of LSN
GstFDInf
                    rts

* SS.DirEnt -
* Entry: A = path
*        B = SS.DirEnt
*        X = ptr to 64 byte buffer
GstDirEnt
                    ldx       PD.DEV,y
                    ldx       V$STAT,x
                    pshs      x,y,u

                    *         send                caller's Y (do we really need this to be 16bit?  X points to 256byte buff?
                    ldx       R$Y,u
                    pshs      x
                    leax      ,s
                    ldy       #2

                    *         set                 U to dwsub
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc

                    jsr       6,u

                    *         recv                bytes into v.buf
                    puls      y
                    ldx       ,s                  ; V$STAT
                    ldx       V.BUF,x

                    ifgt      Level-1
                    pshs      x
                    endc

                    jsr       3,u

                    ifgt      Level-1
                    *         move                v.buf into caller

                    ldx       4,s
                    ldu       R$X,x               ; U = caller's X = dest ptr
                    sty       R$Y,x               ; do we need to set this for caller?

                    lda       <D.SysTsk           ; A = system task #

                    ldx       <D.Proc             get calling proc desc
                    ldb       P$Task,x            ; B = callers task #

                    puls      x                   ; V.BUF from earlier

*  F$Move the bytes (seems to work)
                    os9       F$Move

                    else
                    endc

* assume everything worked (not good)
                    clrb

                    puls      x,y,u,pc




******************************
*
* SetStat - change status of file on the remote device
*
* Entry: Y = Path descriptor pointer
*        U = Callers register stack pointer
*
* Exit:  CC.Carry = 0 (no error), 1 (error)
*        B = error code (if CC.Carry == 1)
*
setstt
                    lda       #DW.setstt
                    lbsr      SendRFMHeader

                    ldb       R$B,u
                    beq       SstOpt
                    cmpb      #SS.Size
                    beq       SstSize
                    cmpb      #SS.FD
                    beq       SstFD
                    cmpb      #SS.Lock
                    beq       SstLock
                    cmpb      #SS.RsBit
                    beq       SstRsBit
                    cmpb      #SS.Attr
                    beq       SstAttr
                    cmpb      #SS.FSig
                    beq       SstFSig
                    comb
                    ldb       #E$UnkSvc
                    rts

SstOpt
SstSize
                    rts

* Entry: A = path
*        B = SS.FD
*        X = ptr to 256 byte buffer
*        Y = # of bytes of FD to write

* path # and SS.FD already sent to server, so
* send Y, recv Y bytes, get them into caller at X
* Y and U here are still as at entry
SstFD
                    ldx       PD.DEV,y
                    ldx       V$STAT,x
                    pshs      x,y,u

                    *         send                caller's Y (do we really need this to be 16bit?  X points to 256byte buff?
                    ldx       R$Y,u
                    pshs      x
                    leax      ,s
                    ldy       #2

                    *         set                 U to dwsub
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       6,u

                    ifgt      Level-1
* move caller bytes into v.buf

                    puls      y                   ; get number of bytes pushed earlier
                    ldx       4,s
                    ldx       R$X,x               ; U = caller's X = dest ptr
                    ldu       ,s
                    ldu       V.BUF,u

                    ldx       <D.Proc             get calling proc desc
                    lda       P$Task,x            ; A = callers task #

                    ldb       <D.SysTsk           ; B = system task #


*  F$Move the bytes (seems to work)
                    os9       F$Move

* write bytes from v.buf
                    tfr       u,x

                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc

                    else
                    puls      y
                    ldx       4,s
                    ldx       R$X,x
                    endc


                    jsr       6,u

* assume everything worked (not good)
                    clrb

                    puls      x,y,u,pc


SstLock
SstRsBit
SstAttr
SstFSig
PlainRTS
                    rts


******************************
*
* Close - close path to file on the remote device
*
* Entry: Y = Path descriptor pointer
*        U = Callers register stack pointer
*
* Exit:  CC.Carry = 0 (no error), 1 (error)
*        B = error code (if CC.Carry == 1)
*
close
                    tst       PD.CNT,y            any open paths?
                    bne       PlainRTS            yes, return

                    ldb       #DW.close

                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc

* read server response
                    pshs      a
                    leax      ,s
                    ldy       #1
                    jsr       3,u

* free system mem
                    ldd       #256
                    ldx       1,s                 ; orig Y
                    ldx       PD.DEV,x
                    ldx       V$STAT,x
                    ldu       V.BUF,x
                    os9       F$SRtMem

                    puls      b                   ; server sends result code
                    tstb
                    beq       close1
                    coma                          ; set error flag if != 0
close1              puls      u,y,pc


* Byte 0: OP_VFM
* Byte 1: DW.Seek
* Byte 2: PD Pointer (MSB)
* Byte 3: PD Pointer (LSB)
* Byte 4: Path number
* Byte 5: Status code
sendgstt            pshs      x,y,u

                    ldb       R$B,u
                    pshs      d
                    pshs      y
                    lda       #OP_VFM             ; load command
                    ldb       #DW.getstt
                    pshs      d                   ; command store on stack
                    leax      ,s                  ; point X to stack
                    ldy       #6
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc

                    jsr       6,u
                    leas      6,s                 ;clean stack

                    clrb
                    puls      x,y,u,pc

                    emod
eom                 equ       *
                    end

