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

* TODO lets not create multiple buffers when multiple open/create on same path
* get system mem
                    ldd       #256
                    os9       F$SRqMem            ; ask for D bytes (# bytes server said is coming)
                    lbcs      open2
                    stu       V.BUF,x

* scan pathlist to find length — F$PrsNam cannot be used here because it rejects
* valid OS-9 path elements like '.' and '..' as first characters
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
                    bra       prsloop
prslastchar
                    leax      1,x
                    anda      #$7F                ; strip high bit
                    leay      1,y
prsdone
                    ldu       4,s                 ; get caller's registers
                    stx       R$X,u
                    ldx       ,s                  ; get device memory pointer
                    sty       V.PATHNAMELEN,x     ; save the length

* put the mode byte on the stack
                    pshs      cc
                    lda       R$A,u
                    pshs      a

* push parent process ID, then process ID
                    ifgt      Level-1
                    ldx       <D.Proc
                    else
                    ldx       >D.Proc
                    endc
                    lda       P$PID,x             ; parent process ID
                    pshs      a
                    lda       P$ID,x              ; process ID
                    pshs      a
* reload vstat ptr (trashed by D.Proc access)
                    ldx       4,s

* put command byte & path # on stack
                    lda       V.DWCMD,x
                    ldy       6,s
                    ldb       PD.PD,y
                    pshs      d                   ; p# PD.PD Regs

* put rfm op and DW op on stack
                    lda       #OP_VFM
                    pshs      a                   ; DWOP RFMOP p# PD.PD Regs

                    leax      ,s                  ; point X to stack
                    ldy       #6                  ; 6 bytes to send

                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc

                    orcc      #IntMasks
                    jsr       6,u
                    leas      6,s                 ;clean stack   PD.PD Regs

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
                    os9       F$Move
                    bcs       moverr
                    endc

* Add carriage return
                    ifgt      Level-1
                    tfr       u,x
                    else
                    tfr       x,u
                    endc
                    tfr       y,d
                    leau      d,u
                    lda       #C$CR
                    sta       ,u
                    leay      1,y

* send to server
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       6,u

* read response from server -> B
                    clr       ,-s
                    leax      ,s
                    ldy       #1
                    jsr       3,u

* pull server's response into B
                    puls      b                   ; PD.PD Regs
moverr              puls      cc
                    tstb
                    beq       open2

openerr             coma                          ; set error
open2               puls      x,y,u,pc


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
seek                pshs      y,u

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
                    jsr       6,u
                    leas      6,s                 ;clean stack - PD.PD Regs

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
read                ldb       #DW.read
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
read1               ldx       PD.DEV,y            ; to our static storage
                    ldx       V$STAT,x
                    pshs      x,y,u

* put path # on stack
                    lda       PD.PD,y
                    pshs      cc
                    pshs      a                   ; p# PD.PD Regs

* put rfm op and DW op on stack

                    lda       #OP_VFM
                    pshs      d                   ; DWOP RFMOP p# PD.PD Regs

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
                    leas      3,s                 ;clean stack - PD.PD Regs

* put caller's Y on stack (maximum allowed bytes)
                    ldx       5,s
                    ldx       R$Y,x
                    pshs      x

* send 2 bytes from stack
                    leax      ,s
                    ldy       #2
                    jsr       6,u

*                    leas      -2,s                ; leave 2 bytes for server response

* read # bytes coming (0 = eof) from server — 2-byte big-endian count
                    leax      ,s
                    ldy       #2
                    jsr       3,u

* store size
                    puls      d                   ; D = byte count from server


* check for 0
                    cmpd      #0
                    beq       readln1             ; 0 bytes = EOF

* read the data from server if > 0
go_on               pshs      d                   ;xfersz PD.PD Regs

* load data from server into mem block
                    ifgt      Level-1
                    ldx       3,s                 ; V$STAT
                    ldx       V.BUF,x
                    else
                    ldx       7,s                 ; caller regs
                    std       R$Y,x
                    ldx       R$X,x
                    endc
                    ldy       ,s                  ;xfersz
                    jsr       3,u

* F$Move
* a = my task #
* b = caller's task #
* X = source ptr
* Y = byte count
* U = dest ptr

* move from our mem to caller

                    puls      y                   ;Y = byte count (already set?)    -  PD.PD Regs
                    puls      cc

                    ifgt      Level-1
                    ldx       4,s
                    ldu       R$X,x               ; U = caller's X = dest ptr
                    sty       R$Y,x

                    lda       <D.SysTsk           ; A = system task #

                    ldx       <D.Proc             get calling proc desc
                    ldb       P$Task,x            ; B = callers task #

                    ldx       ,s                  ; V$STAT     - PD Regs
                    ldx       V.BUF,x

*  F$Move the bytes (seems to work)
                    os9       F$Move
                    endc
* assume everything worked (not good)
                    clrb
                    bra       readln2

readln1
                    puls      cc
                    comb
                    ldb       #E$EOF
readln2             puls      x,y,u,pc




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
                    lbeq       GstFDInf
                    cmpb      #SS.DirEnt
                    lbeq       GstDirEnt
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
* Exit  CC.Carry = 0 if not at EOF, 1 if at EOF
*       B = E$EOF if at EOF, 0 otherwise
* Server returns 1 byte: 0 = not at EOF, non-zero = at EOF
GstEOF
                    ldx       PD.DEV,y
                    ldx       V$STAT,x
                    pshs      x,y,u

                    clr       ,-s                 ; 1-byte receive buffer
                    leax      ,s
                    ldy       #1
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       3,u                 ; recv 1 byte from server
                    puls      b                   ; B = 0 (not EOF) or non-zero (EOF)
                    tstb
                    bne       gsteof_e
                    clrb
                    puls      x,y,u,pc
gsteof_e            ldb       #E$EOF
                    coma                          ; set carry = error
                    puls      x,y,u,pc

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
* Server returns 4 bytes big-endian: [MSW_hi, MSW_lo, LSW_hi, LSW_lo]
GstSize
                    ldx       PD.DEV,y
                    ldx       V$STAT,x
                    pshs      x,y,u

                    leas      -4,s                ; 4-byte receive buffer
                    leax      ,s
                    ldy       #4
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       3,u                 ; recv 4 bytes
                    ldd       ,s                  ; D = MSW
                    ldu       2,s                 ; U = LSW
                    leas      4,s                 ; free buffer
                    ldx       4,s                 ; X = caller register stack
                    std       R$X,x               ; R$X = MSW of size
                    stu       R$U,x               ; R$U = LSW of size
                    clrb
                    puls      x,y,u,pc

* SS.Pos - Return the current position in the file
* Entry A = path
*       B = SS.Pos
* Exit  X = msw of pos
*       U = lsw of pos
* Server returns 4 bytes big-endian: [MSW_hi, MSW_lo, LSW_hi, LSW_lo]
GstPOS
                    ldx       PD.DEV,y
                    ldx       V$STAT,x
                    pshs      x,y,u

                    leas      -4,s                ; 4-byte receive buffer
                    leax      ,s
                    ldy       #4
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc
                    jsr       3,u                 ; recv 4 bytes
                    ldd       ,s                  ; D = MSW
                    ldu       2,s                 ; U = LSW
                    leas      4,s                 ; free buffer
                    ldx       4,s                 ; X = caller register stack
                    std       R$X,x               ; R$X = MSW of position
                    stu       R$U,x               ; R$U = LSW of position
                    clrb
                    puls      x,y,u,pc

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
*
* sendgstt already sent [OP_VFM, DW.getstt, path#, SS.FDInf].
* Now send R$Y + R$U (4 bytes: len, LSN[0], LSN[1], LSN[2]),
* receive 256 bytes into V.BUF, then F$Move to caller's X buffer.
GstFDInf
                    ldx       PD.DEV,y
                    ldx       V$STAT,x
                    pshs      x,y,u               ; [S+0..1]=V$STAT, [S+2..3]=path_desc, [S+4..5]=caller_regs

* build 4-byte send packet: [Y_hi=len, Y_lo=LSN_MSB, U_hi=LSN_mid, U_lo=LSN_lo]
                    ldy       R$U,u               ; Y = caller's U (LSN_LSW)
                    pshs      y                   ; push U (2 bytes)
                    ldx       R$Y,u               ; X = caller's Y (len|LSN_MSB)
                    pshs      x                   ; push Y (2 bytes): stack=[Y_hi,Y_lo,U_hi,U_lo,...]

                    leax      ,s
                    ldy       #4

                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc

                    jsr       6,u                 ; send 4 bytes
                    leas      4,s                 ; clean stack

* receive 256 bytes into V.BUF
                    ldx       ,s                  ; V$STAT
                    ldx       V.BUF,x
                    ldy       #256

                    ifgt      Level-1
                    pshs      x                   ; save V.BUF ptr for F$Move
                    endc

                    jsr       3,u                 ; recv 256 bytes

                    ifgt      Level-1
* F$Move 256 bytes from V.BUF (system task) to caller's X (caller's task)
                    ldx       6,s                 ; caller_regs
                    ldu       R$X,x               ; U = caller's X = dest buffer
                    sty       R$Y,x               ; update caller's Y

                    lda       <D.SysTsk           ; A = system task (source)
                    ldx       <D.Proc
                    ldb       P$Task,x            ; B = caller's task (dest)
                    puls      x                   ; X = V.BUF
                    ldy       #256
                    os9       F$Move
                    else
                    endc

                    clrb
                    puls      x,y,u,pc

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
                    lbsr      sendit

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
                    pshs      y,u

* put path # on stack
                    lda       PD.PD,y
                    pshs      a

* put rfm op and DW op on stack
                    ldb       #DW.close
                    lda       #OP_VFM
                    pshs      d

                    leax      ,s                  ; point X to stack
                    ldy       #3                  ; 3 bytes to send
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc

                    jsr       6,u
                    leas      2,s                 ;clean stack (leave 1 byte)

* read server response
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

                    jsr       6,u
                    leas      4,s                 ;clean stack

                    clrb
                    puls      x,y,u,pc





* just send OP_VMF + vfmop
sendit              pshs      a,x,y,u

                    lda       #OP_VFM             ; load command
                    pshs      a                   ; command store on stack
                    leax      ,s                  ; point X to stack
                    ldy       #2                  ; 2 byte to send
                    ifgt      Level-1
                    ldu       <D.DWSubAddr
                    else
                    ldu       >D.DWSubAddr
                    endc

                    jsr       6,u
                    leas      2,s                 ;clean stack

                    clrb
                    puls      x,y,u,pc

                    emod
eom                 equ       *
                    end

