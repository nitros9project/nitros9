********************************************************************
* RFM - Remote File Manager
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
                    use       readdir.d
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
* Entry: Y = Path descriptor pointer
*        U = Callers register stack pointer
*
* Exit:  CC.Carry = 0 (no error), 1 (error)
*        B = error code (if CC.Carry == 1)
*
open                ldb       #DW.open
create1
                    ldx       PD.DEV,y            ; get ptr to our device memory
                    ldx       V$STAT,x            ; get ptr to our static storage
                    pshs      x,y,u               ; save all on stack
                    stb       V.DWCMD,x

                    clr       PD.BUF,y
                    clr       PD.BUF+1,y
* One transfer buffer belongs to each system path (Dup shares the path).
* get system mem
                    ldd       #256
                    os9       F$SRqMem            ; ask for D bytes (# bytes server said is coming)
                    lbcs      open2
                    stu       PD.BUF,y

* scan pathlist to find length
                    ldu       4,s                 ; get pointer to caller's registers
                    ldy       R$X,u               ; Y = start of pathname in caller's space
                    sty       V.PATHNAME,x        ; save pathname pointer to V$STAT
                    tfr       y,x                 ; X = current scan position
                    ifgt      Level-1
                    pshs      x                   ; save pathname ptr
                    ldx       <D.Proc
                    ldb       P$Task,x            ; B = caller's task number for F$LDABX
                    puls      x                   ; X = pathname ptr restored
                    endc
                    pshs      x                   ; save pathname ptr
                    ifgt      Level-1
                    os9       F$LDABX             ; A = first pathname byte
                    tsta                          ; F$LDABX doesn't update CC — set N/Z from A
                    else
                    lda       ,x                  ; A = first pathname byte
                    endc
                    puls      x                   ; X = pathname ptr restored
                    ldu       ,s                  ; get device memory pointer
                    ldb       #1
                    cmpa      #PDELIM             ; absolute path?
                    bne       relsave             ; no, remember relative path
                    clrb                          ; yes, do not use current-dir context
relsave            stb       V.RELFLG,u           ; save path type for server context
                    ifgt      Level-1
                    pshs      x                   ; save pathname ptr
                    ldx       <D.Proc
                    ldb       P$Task,x            ; B = caller's task number for F$LDABX
                    puls      x                   ; X = pathname ptr restored
                    endc
                    ldy       #0                  ; Y = length counter
prsloop
                    ifgt      Level-1
                    os9       F$LDABX             ; A = byte at X in caller's task (X not auto-advanced)
                    tsta                          ; F$LDABX doesn't update CC — set N/Z from A
                    else
                    lda       ,x                  ; A = byte at X (lda sets CC naturally)
                    endc
                    bmi       prslastchar         ; high bit set = last char
                    beq       prsdone             ; null terminator
                    cmpa      #C$CR
                    beq       prsdone             ; carriage return
                    cmpa      #C$SPAC
                    beq       prsdone             ; space
                    cmpa      #PENTIR
                    beq       prsdone             ; '@' entire device
                    leax      1,x
                    leay      1,y
                    cmpy      #255
                    lbhi      BadPath
                    bra       prsloop
prslastchar
                    leax      1,x
                    anda      #$7F                ; strip high bit
                    leay      1,y
prsdone
                    cmpy      #0
                    lbeq      BadPath
                    cmpy      #255
                    lbhi      BadPath
                    ldu       4,s                 ; get caller's registers
                    stx       R$X,u
                    ldx       ,s                  ; get device memory pointer
                    sty       V.PATHNAMELEN,x     ; save the length

* put the mode byte on the stack
                    pshs      cc
                    ifgt      Level-1
* now send path string
* move from caller to our mem

                    ldx       <D.Proc             get calling proc desc
                    lda       P$Task,x            ; A = callers task # (source)

                    ldb       <D.SysTsk           ; B = system task # (dest)
                    endc

                    ldx       1,s                 ; get device mem ptr
                    ldu       3,s
                    ldu       PD.BUF,u
                    ldy       V.PATHNAMELEN,x     ; get count in Y
                    ldx       V.PATHNAME,x        ; get source in X

                    ifgt      Level-1
* Copy pathname into owned system storage before starting the transaction.
                    os9       F$Move
                    lbcs      moverr
                    endc

* Add carriage return
                    ifgt      Level-1
                    tfr       u,x
                    else
                    pshs      y,u
copyname            lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       copyname
                    puls      y,u
                    tfr       u,x
                    endc
                    tfr       y,d
                    leau      d,u
                    cmpy      #0
                    beq       pathnamecr
                    lda       -1,u
                    anda      #$7F
                    sta       -1,u
pathnamecr          lda       #C$CR
                    sta       ,u
                    leay      1,y

                    ldy       3,s                 ; get path descriptor pointer
                    lda       PD.MOD,y            ; get mode saved by IOMan
                    pshs      a

* Stable 24-bit directory cookie is copied with P$DIO by F$Fork.
                    ldx       <D.Proc
                    ldu       2,s                 ; device statics
                    clra
                    clrb
                    pshs      d                   ; cookie low word, initially zero
                    clra
                    pshs      a                   ; cookie high byte
                    tst       V.RELFLG,u
                    beq       contextready
                    leau      P$DIO+2,x
                    ldb       3,s                 ; request mode
                    bitb      #PEXEC.+EXEC.
                    beq       contextdata
                    leau      6,u
contextdata         lda       ,u
                    sta       ,s
                    ldd       1,u
                    std       1,s
contextready        lda       P$ID,x
                    pshs      a
                    ldx       6,s                 ; device statics

* put command byte & path # on stack
                    lda       V.DWCMD,x
                    ora       #DW.Context         ; context-aware path protocol
                    ldy       8,s
                    ldb       PD.PD,y
                    pshs      d                   ; p# PD.PD Regs

* put rfm op and DW op on stack
                    lda       #OP_VFM
                    pshs      a                   ; DWOP RFMOP p# PD.PD Regs

                    leax      ,s                  ; point X to stack
                    ldy       #8                  ; extended path header

                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc

                    orcc      #IntMasks
                    lbsr      Send
                    leas      8,s                 ;clean stack   PD.PD Regs

                    ldx       3,s
                    ldx       PD.BUF,x
                    ldy       1,s
                    ldy       V.PATHNAMELEN,y
                    leay      1,y

* send to server
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    lbsr      Send

* read response from server -> B
                    clr       ,-s
                    leax      ,s
                    ldy       #1
                    lbsr      Receive

* pull server's response into B
                    bcc       OpenResponse
                    leas      1,s
                    bra       moverr
OpenResponse        puls      b                   ; PD.PD Regs
                    tstb
                    bne       moverr
                    ldx       1,s                 ; device statics
                    lda       V.DWCMD,x
                    cmpa      #DW.ChgDir
                    bne       moverr
* Success returns an immutable cookie. Commit it only after all bytes arrive.
                    ldx       3,s
                    ldx       PD.BUF,x
                    ldy       #3
                    lbsr      Receive
                    bcs       moverr
                    clrb
moverr              puls      cc
                    tstb
                    beq       openok

openerr             coma                          ; set error
                    ldy       2,s                 ; get path descriptor pointer
                    pshs      b
                    ldu       PD.BUF,y
                    beq       openerrnofree
                    ldd       #256
                    os9       F$SRtMem
                    clr       PD.BUF,y
                    clr       PD.BUF+1,y
openerrnofree
                    puls      b
                    orcc      #1                  ; retain failure after cleanup
                    bra       open2ret

openok              ldx       ,s                  ; get device memory pointer
                    lda       V.DWCMD,x
                    cmpa      #DW.open
                    beq       open2ret
                    cmpa      #DW.create
                    beq       open2ret
                    cmpa      #DW.chgdir
                    bne       openokfree
                    ldy       2,s                 ; get path descriptor pointer
                    ifgt      Level-1
                    ldu       <D.Proc
                    else
                    ldu       >D.Proc
                    endc
                    ldx       PD.BUF,y            ; returned immutable directory cookie
                    ldb       PD.MOD,y            ; get resolved mode bits
                    bitb      #PWRIT.+PREAD.+UPDAT. ; data directory request?
                    beq       chgexec             ; no, test execution directory
                    lda       ,x
                    sta       P$DIO+2,u
                    ldd       1,x
                    std       P$DIO+3,u
                    ldb       PD.MOD,y
chgexec             bitb      #PEXEC.+EXEC.       ; execution directory request?
                    beq       openokfree          ; no, just free temporary buffer
                    lda       ,x
                    sta       P$DIO+8,u
                    ldd       1,x
                    std       P$DIO+9,u
openokfree
                    ldy       2,s                 ; get path descriptor pointer
                    ldu       PD.BUF,y
                    beq       openoknofree
                    ldd       #256
                    os9       F$SRtMem
                    clr       PD.BUF,y
                    clr       PD.BUF+1,y
openoknofree        clrb
                    bra       open2ret

BadPath             ldb       #E$BPNam
                    lbra      openerr
open2               lbra      openerr
open2ret            puls      x,y,u,pc


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
makdir              ldb       #DW.makdir
                    lbra      create1

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
chgdir              ldb       #DW.chgdir
                    lbra      create1

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
delete              ldb       #DW.delete
                    lbra      create1


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
* seek = send dwop, rfmop, path, caller's X + U
* DWIO can poll virtual channels from IRQ context. Mask the entire request /
* reply, not just individual Read/Write calls, so it cannot consume RFM bytes.
seek                pshs      cc
                    orcc      #IntMasks
                    lbsr      SeekTransaction
                    bra       BusReturn
SeekTransaction     pshs      y,u

                    ldx       R$U,u
                    pshs      x
                    ldx       R$X,u
                    pshs      x
                    lda       PD.PD,y
                    pshs      a
                    ldd       #OP_VFM*256+DW.seek
                    pshs      d

                    leax      ,s                  ; point X to stack
                    ldy       #7                  ; 7 bytes to send

* set U to dwsub
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc

* send dw op, rfm op, path #
                    lbsr      Send
                    leas      6,s                 ;clean stack - PD.PD Regs

* read response from server
                    leax      ,s
                    ldy       #1
                    lbsr      Receive

                    bcc       response@
                    leas      1,s
                    orcc      #1
                    puls      y,u,pc
response@           puls      b
                    tstb
                    beq       ok@
                    coma
                    bra       notok@
ok@                 clrb
notok@              puls      y,u,pc

BusReturn           pshs      cc                  ; result condition codes
                    lda       1,s                 ; caller's original masks
                    anda      #IntMasks
                    sta       1,s
                    puls      a
                    anda      #^IntMasks
                    ora       ,s+
                    tfr       a,cc
                    rts


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
* Transfer stack: opcode, remaining, completed, caller pointer, PD, regs, CC.
T.Op                equ       0
T.Left              equ       1
T.Done              equ       3
T.Ptr               equ       5
T.PD                equ       7
T.Regs              equ       9
T.CC                equ       11
T.Size              equ       12
read                ldb       #DW.Read
                    bra       Transfer
readln              ldb       #DW.ReadLn
                    bra       Transfer
write               ldb       #DW.Write
                    bra       Transfer
writln              ldb       #DW.WritLn
Transfer            pshs      cc,y,u
                    ldx       R$X,u
                    pshs      x
                    ldx       #0
                    pshs      x
                    ldx       R$Y,u
                    pshs      x
                    pshs      b
* Rearrange saved tail: pshs cc,y,u places CC, PD, regs after locals.
* Tail offsets are CC=7, PD=8, regs=10 until normalized below.
                    lda       7,s
                    ldy       8,s
                    ldu       10,s
                    sta       T.CC,s
                    sty       T.PD,s
                    stu       T.Regs,s
TransferNext        ldd       T.Left,s
                    lbeq      TransferOK
                    cmpd      #256
                    bls       TransferCount
                    ldd       #256
TransferCount       pshs      d                   ; chunk length
* Stage outgoing bytes before emitting any packet.
                    ldb       T.Op+2,s
                    cmpb      #DW.Write
                    beq       TransferStage
                    cmpb      #DW.WritLn
                    bne       TransferPacket
TransferStage       ldy       ,s
                    ldx       T.Ptr+2,s
                    ldu       T.PD+2,s
                    ldu       PD.BUF,u
                    lbsr      FromCaller
                    lbcs      TransferChunkError
* WritLn stops after the first CR, including CR in returned count.
                    ldb       T.Op+2,s
                    cmpb      #DW.WritLn
                    bne       TransferPacket
                    ldx       T.PD+2,s
                    ldx       PD.BUF,x
                    ldy       ,s
TransferCR
                    lda       ,x+
                    cmpa      #C$CR
                    beq       TransferCRFound
                    leay      -1,y
                    bne       TransferCR
                    bra       TransferPacket
TransferCRFound     lda       T.Op+2,s
                    ora       #$80
                    sta       T.Op+2,s
                    tfr       x,d
                    ldx       T.PD+2,s
                    subd      PD.BUF,x
                    std       ,s
TransferPacket      orcc      #IntMasks           ; own the wire through the reply
                    ldy       T.PD+2,s
                    lda       PD.PD,y
                    ldb       T.Op+2,s
                    andb      #$7F
                    exg       a,b                 ; opcode,path
                    pshs      d
                    lda       #OP_VFM
                    pshs      a
                    leax      ,s
                    ldy       #5                  ; header and chunk length
                    lbsr      Send
                    leas      3,s
                    ldb       T.Op+2,s
                    cmpb      #DW.Read
                    beq       TransferRead
                    cmpb      #DW.ReadLn
                    beq       TransferRead
                    ldx       T.PD+2,s
                    ldx       PD.BUF,x
                    ldy       ,s
                    lbsr      Send
                    lbra      TransferCommit
TransferRead        leas      -2,s                ; returned count
                    leax      ,s
                    ldy       #2
                    lbsr      Receive
                    lbcs      TransferCountError
                    ldd       ,s
                    cmpd      2,s
                    lbhi      TransferBadCount
                    std       2,s
                    leas      2,s
                    cmpd      #0
                    lbeq      TransferEOF
                    tfr       d,y
                    ldx       T.PD+2,s
                    ldx       PD.BUF,x
                    lbsr      Receive
                    lbcs      TransferChunkError
                    ldx       T.PD+2,s
                    ldx       PD.BUF,x
                    ldu       T.Ptr+2,s
                    ldy       ,s
                    ldb       T.Op+2,s
                    cmpb      #DW.ReadLn
                    bne       TransferCopyRead
                    pshs      x
                    tfr       y,d
                    leax      d,x
                    lda       -1,x
                    cmpa      #C$CR
                    puls      x
                    bne       TransferCopyRead
                    lda       T.Op+2,s
                    ora       #$80
                    sta       T.Op+2,s
TransferCopyRead    lda       T.CC+2,s           ; reply fully consumed; allow IRQs
                    anda      #IntMasks
                    tfr       a,cc
                    lbsr      ToCaller
                    lbcs      TransferChunkError
TransferCommit      lda       T.CC+2,s           ; release wire between chunks
                    anda      #IntMasks
                    tfr       a,cc
                    puls      d
                    pshs      d
                    addd      T.Done+2,s
                    std       T.Done+2,s
                    puls      d
                    addd      T.Ptr,s
                    std       T.Ptr,s
* Left is recomputed from original request to avoid cumulative subtraction.
                    ldu       T.Regs,s
                    ldd       R$Y,u
                    subd      T.Done,s
                    std       T.Left,s
* Continue binary reads to the requested count; line reads stop at CR.
                    tst       T.Op,s
                    lbmi      TransferOK
                    lbra      TransferNext
TransferBadCount    ldb       #E$Read
TransferCountError  leas      2,s
TransferChunkError  leas      2,s
                    bra       TransferError
TransferEOF         leas      2,s
                    ldd       T.Done,s
                    lbne      TransferOK
                    ldb       #E$EOF
TransferError       lda       T.CC,s
                    tfr       a,cc
                    orcc      #1
                    bra       TransferReturn
TransferOK          lda       T.CC,s
                    tfr       a,cc
                    clrb
TransferReturn      ldu       T.Regs,s
                    ldy       T.Done,s
                    sty       R$Y,u
                    ldy       T.PD,s
                    leas      T.Size,s
                    rts

* X source, U destination, Y count. Never rely on DWRead's checksum as count.
FromCaller
                    ifgt      Level-1
                    ldd       <D.Proc
                    pshs      x
                    tfr       d,x
                    lda       P$Task,x
                    ldb       <D.SysTsk
                    puls      x
                    os9       F$Move
                    else
                    lbsr      CopyBytes
                    endc
                    rts
ToCaller
                    ifgt      Level-1
                    pshs      x
                    ldx       <D.Proc
                    ldb       P$Task,x
                    lda       <D.SysTsk
                    puls      x
                    os9       F$Move
                    else
                    lbsr      CopyBytes
                    endc
                    rts
CopyBytes           pshs      x,y,u
                    cmpy      #0
                    beq       CopyDone
CopyLoop            lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       CopyLoop
CopyDone            andcc     #$FE
                    puls      x,y,u,pc

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
getstt              pshs      cc
                    orcc      #IntMasks
                    lbsr      GetStatus
                    lbra      BusReturn
GetStatus           ldb       R$B,u
                    lbeq      StatusOptions
                    cmpb      #SS.ReadDir
                    lbeq      StatusReadDir
                    cmpb      #SS.Ready
                    beq       StatusReady
                    cmpb      #SS.EOF
                    beq       StatusGet
                    cmpb      #SS.Size
                    beq       StatusGet
                    cmpb      #SS.Pos
                    beq       StatusGet
                    cmpb      #SS.FD
                    beq       StatusBuffer
                    cmpb      #SS.FDInf
                    beq       StatusGet
                    bra       StatusUnsupported
StatusBuffer        ldx       R$Y,u
                    cmpx      #256
                    bhi       StatusBadSize
StatusGet           lda       PD.PD,y
                    lbsr      sendgstt
                    ldb       R$B,u
                    cmpb      #SS.EOF
                    beq       StatusEOF
                    cmpb      #SS.Size
                    beq       StatusWord
                    cmpb      #SS.Pos
                    beq       StatusWord
                    cmpb      #SS.FDInf
                    lbeq      StatusFDInf
                    lbra      StatusBytes
StatusBadSize       ldb       #E$BPNam
                    orcc      #1
                    rts
* Options are the local path packet, not a server request. copy uses its
* device-type byte to decide whether RBF-only metadata setters are applicable.
StatusOptions       pshs      x,y,u
                    leax      PD.OPT,y
                    ldu       R$X,u
                    ldy       #32
                    lbsr      ToCaller
                    bcs       StatusOptionsDone
                    clrb
StatusOptionsDone   puls      x,y,u,pc
StatusReady         clr       R$B,u
                    clrb
                    rts
StatusUnsupported   ldb       #E$UnkSvc
                    orcc      #1
                    rts
StatusEOF           pshs      x,y,u
                    leas      -1,s
                    leax      ,s
                    ldy       #1
                    lbsr      Receive
                    bcs       StatusEOFError
                    ldb       ,s
                    beq       StatusEOFSuccess
                    ldb       #E$EOF
                    orcc      #1
                    bra       StatusEOFError
StatusEOFSuccess    clrb
StatusEOFError      leas      1,s
                    puls      x,y,u,pc
StatusWord          pshs      x,y,u
                    leas      -4,s
                    leax      ,s
                    ldy       #4
                    lbsr      Receive
                    bcs       StatusWordDone
                    ldu       8,s
                    ldd       ,s
                    std       R$X,u
                    ldd       2,s
                    std       R$U,u
                    clrb
StatusWordDone      leas      4,s
                    puls      x,y,u,pc
* Variable-size FD response; count stays on stack across transport.
StatusBytes         pshs      x,y,u
                    ldx       R$Y,u
                    pshs      x
                    leax      ,s
                    ldy       #2
                    lbsr      Send
                    ldy       ,s
                    bra       StatusReceive
StatusFDInf         pshs      x,y,u
                    ldd       R$U,u
                    pshs      d
                    ldd       R$Y,u
                    pshs      d
                    leax      ,s
                    ldy       #4
                    lbsr      Send
                    leas      4,s
                    ldd       #256
                    pshs      d
                    tfr       d,y
StatusReceive       ldx       4,s                 ; PD
                    ldx       PD.BUF,x
                    lbsr      Receive
                    bcs       StatusBytesDone
                    ldu       6,s                 ; caller register frame
                    ldy       ,s
* FDInf still consumes the existing fixed 256-byte wire reply. Application
* R$Y is LSN high byte / requested length (the layout used by dir -e).
                    ldb       R$B,u
                    cmpb      #SS.FDInf
                    bne       StatusCopy
                    clra
                    ldb       R$Y+1,u
                    tfr       d,y
StatusCopy          ldu       R$X,u
                    lbsr      ToCaller
                    bcs       StatusBytesDone
                    clrb
StatusBytesDone     leas      2,s
                    puls      x,y,u,pc

* Ready handshake prevents sending a size payload to an older server.
* All wire bytes arrive before ToCaller can enable interrupts.
StatusReadDir       ldx       R$Y,u
                    cmpx      #RD.NameSize
                    beq       ReadDirStart
                    cmpx      #RD.Size
                    lbne      StatusBadSize
ReadDirStart        lda       PD.PD,y
                    lbsr      sendgstt
                    pshs      x,y,u
                    pshs      x                   requested count; StatusReceive frame
                    lbsr      ReadDirReply
                    bcc       ReadDirCount
                    cmpb      #E$Read
                    bne       ReadDirDone
                    ldb       #E$UnkSvc
                    bra       ReadDirDone
ReadDirCount        leax      ,s
                    ldy       #2
                    lbsr      Send
                    lbsr      ReadDirReply
                    bcs       ReadDirDone
                    ldy       ,s
                    lbra      StatusReceive
ReadDirDone         orcc      #1
                    lbra      StatusBytesDone
ReadDirReply        leas      -1,s
                    leax      ,s
                    ldy       #1
                    lbsr      Receive
                    bcs       ReadDirReturn
                    ldb       ,s
                    beq       ReadDirReturn
                    orcc      #1
ReadDirReturn       leas      1,s
                    rts

* Unimplemented setters fail before sending anything to the server. The old
* two-byte request omitted path and status and could desynchronize the stream.
setstt              ldb       R$B,u
                    cmpb      #SS.Rename
                    lbne      StatusUnsupported
                    pshs      cc
                    lbsr      RenameStatus
                    lbra      BusReturn
RenameStatus        pshs      x,y,u
                    leas      -64,s
                    ldd       R$Y,u
                    cmpd      #60
                    bne       RenameBad
                    lda       PD.MOD,y
                    anda      #DIR.!WRITE.
                    cmpa      #DIR.!WRITE.
                    bne       RenameDenied
                    lda       #OP_VFM
                    ldb       #DW.SetStt
                    std       ,s
                    lda       PD.PD,y
                    ldb       #SS.Rename
                    std       2,s
                    ldx       R$X,u
                    pshs      y,u
                    leau      8,s
                    ldy       #60
                    lbsr      FromCaller
                    puls      y,u
                    bcs       RenameDone
                    leax      4,s
                    lbsr      RNName
                    bcs       RenameDone
                    lbsr      RNName
                    bcs       RenameDone
* Probe support before sending a payload. Older servers discard unknown
* GetStat codes; their bounded timeout leaves the stream aligned.
                    orcc      #IntMasks
                    lda       #DW.GetStt
                    sta       1,s
                    leax      ,s
                    ldy       #4
                    lbsr      Send
                    leas      -1,s
                    leax      ,s
                    ldy       #1
                    lbsr      Receive
                    bcs       RenameNoServer
                    ldb       ,s
                    leas      1,s
                    tstb
                    bne       RenameError
                    lda       #DW.SetStt
                    sta       1,s
                    leax      ,s
                    ldy       #64
                    lbsr      Send
                    leax      ,s
                    ldy       #1
                    lbsr      Receive
                    bcs       RenameDone
                    ldb       ,s
                    beq       RenameDone
                    orcc      #1
                    bra       RenameDone
RenameNoServer      leas      1,s
                    ldb       #E$UnkSvc
                    bra       RenameError
RenameDenied        ldb       #E$FNA
                    bra       RenameError
RenameBad           ldb       #E$BPNam
RenameError         orcc      #1
RenameDone          leas      64,s
                    puls      x,y,u,pc

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
close               pshs      cc
                    orcc      #IntMasks
                    lbsr      CloseTransaction
                    lbra      BusReturn
CloseTransaction    tst       PD.CNT,y
                    beq       CloseFinal
                    clrb
                    rts
CloseFinal          pshs      cc,x,y,u
                    lda       PD.PD,y
                    ldb       #DW.Close
                    exg       a,b
                    pshs      d
                    lda       #OP_VFM
                    pshs      a
                    leax      ,s
                    ldy       #3
                    lbsr      Send
                    leas      2,s
                    leax      ,s
                    ldy       #1
                    lbsr      Receive
                    bcs       CloseResult
                    ldb       ,s
CloseResult         stb       ,s
                    ldx       4,s                 ; saved PD
                    ldu       PD.BUF,x
                    pshs      cc
                    clr       PD.BUF,x
                    clr       PD.BUF+1,x
                    puls      cc
                    beq       CloseFreed
                    ldd       #256
                    os9       F$SRtMem
CloseFreed          puls      b
                    puls      cc,x,y,u
                    tstb
                    beq       CloseReturn
                    orcc      #1
CloseReturn         rts

* send dwop, rfmop, path, set/getstat op   (path is in A)
sendgstt            pshs      x,y,u

                    ldb       R$B,u
                    pshs      d

                    lda       #OP_VFM             ; load command
                    ldb       #DW.getstt
                    pshs      d                   ; command store on stack
                    leax      ,s                  ; point X to stack
                    ldy       #4                  ; 2 byte to send
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc

                    lbsr      Send
                    leas      4,s                 ;clean stack

                    clrb
                    puls      x,y,u,pc





* Transport entry points preserve the requested count and caller mask state.
* Receive translates the documented DWRead C/Z result to an OS-9 error.
Send                pshs      cc,y,u
                    cmpy      #0
                    beq       SendDone
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       6,u
SendDone            puls      cc,y,u,pc
Receive             pshs      cc,y,u
                    cmpy      #0
                    beq       ReceiveOK
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       3,u
                    bcs       ReceiveFailed
                    bne       ReceiveFailed
ReceiveOK           puls      cc,y,u
                    andcc     #$FE
                    rts
ReceiveFailed       puls      cc,y,u
                    ldb       #E$Read
                    orcc      #1
                    rts

                    use       rename-name.d

                    emod
eom                 equ       *
                    end
