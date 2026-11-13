* Wildbits native-block backend, ABI 1. No RBF deblocking or RBSuper statics.
* SD SPI protocol: SD Association Physical Layer Simplified Specification,
* sections 5 (CSD) and 7 (SPI). Supports SDSC and SDHC/SDXC, not MMC/SDUC.
                    use       defsfile  ; include shared definitions or implementation
                    use       blkdrv.d  ; include shared definitions or implementation
                    org       0         ; set storage origin
S.Port              rmb       2         ; reserve storage
S.Request           rmb       2         ; reserve storage
S.LBA               rmb       4         ; reserve storage
S.Buffer            rmb       2         ; reserve storage
S.Write             rmb       1         ; reserve storage
S.HC                rmb       1         ; reserve storage
S.Ready             rmb       1         ; reserve storage
S.Control           rmb       1         ; reserve storage
S.Retry             rmb       2         ; reserve storage
S.Last              rmb       4         ; reserve storage
S.Command           rmb       6         ; reserve storage
S.CSD               rmb       16        ; reserve storage
S.Len               equ       .         ; define constant or offset
                    mod       eom,name,Sbrtn+Objct,ReEnt+1,start,0 ; emit OS-9 module header
name                fcs       /llwbsdblk/         ; module name or literal text
                    fcb       1         ; emit byte data
start               lbra      Init      ; continue unconditionally Init
                    lbra      Read      ; continue unconditionally Read
                    lbra      Write     ; continue unconditionally Write
                    lbra      Info      ; continue unconditionally Info
                    lbra      Flush     ; continue unconditionally Flush
                    lbra      Term      ; continue unconditionally Term
                    fdb       BD.Magic  ; emit word data
                    fcb       BD.Version,BH.Len ; emit byte data
                    fdb       S.Len     ; emit word data

* All external entries preserve X/Y/U. U points at private allocated state.
Init                pshs      x,y,u     ; preserve x,y,u on stack
                    clr       S.Ready,u ; clear S.Ready,u
                    clr       S.HC,u    ; clear S.HC,u
                    lda       BC.Unit,y ; load A from BC.Unit,y
                    lbne      UnitError ; branch when unequal or nonzero UnitError
                    ldx       BC.Port,y ; load X from BC.Port,y
                    stx       S.Port,u  ; save X in S.Port,u
                    lda       #SPI_CLK  ; load A from #SPI_CLK
                    sta       S.Control,u ; save A in S.Control,u
                    lbsr      Present   ; call helper Present
                    lbcs      Exit      ; branch on carry or error Exit
* At least 74 clocks with CS deasserted, then select at slow clock.
                    lda       #SPI_CLK  ; load A from #SPI_CLK
                    sta       SDC_STAT,x ; save A in SDC_STAT,x
                    ldb       #10       ; load B from #10
clock1@             lbsr      Receive   ; call helper Receive
                    lbcs      Exit      ; branch on carry or error Exit
                    decb                ; decrement accumulator B
                    bne       clock1@   ; branch when unequal or nonzero clock1@
                    lda       #SPI_CLK|CS_EN ; load A from #SPI_CLK|CS_EN
                    sta       SDC_STAT,x ; save A in SDC_STAT,x
                    ldd       #256      ; bounded warm-reset CMD0 retries
                    std       S.Retry,u ; retry budget
reset1@             lda       #$40      ; cmd0 returns card to idle
                    lbsr      CommandZero ; call helper CommandZero
                    lda       #$95      ; load A from #$95
                    sta       S.Command+5,u ; save A in S.Command+5,u
                    lbsr      SendCommand ; call helper SendCommand
                    bcs       resetretry@ ; busy cards may time out during warm reset
                    cmpa      #1        ; idle response
                    beq       resetready@ ; begin initialization
resetretry@         ldd       S.Retry,u ; remaining attempts
                    subd      #1        ; consume one attempt
                    std       S.Retry,u ; save retry budget
                    bne       reset1@   ; retry bounded command
                    lbra      NotReady  ; no idle response
resetready@         lda       #$48      ; load A from #$48
                    lbsr      CommandZero ; call helper CommandZero
                    lda       #1        ; load A from #1
                    sta       S.Command+3,u ; save A in S.Command+3,u
                    lda       #$AA      ; load A from #$AA
                    sta       S.Command+4,u ; save A in S.Command+4,u
                    lda       #$87      ; load A from #$87
                    sta       S.Command+5,u ; save A in S.Command+5,u
                    lbsr      SendCommand ; call helper SendCommand
                    lbcs      Exit      ; branch on carry or error Exit
                    cmpa      #5        ; idle + illegal command: SD v1
                    beq       old1@     ; branch when equal or zero old1@
                    cmpa      #1        ; compare A with #1
                    lbne      BadMode   ; branch when unequal or nonzero BadMode
                    lbsr      Receive   ; call helper Receive
                    lbcs      Exit      ; branch on carry or error Exit
                    tsta                ; test accumulator A
                    lbne      BadMode   ; branch when unequal or nonzero BadMode
                    lbsr      Receive   ; call helper Receive
                    lbcs      Exit      ; branch on carry or error Exit
                    tsta                ; test accumulator A
                    lbne      BadMode   ; branch when unequal or nonzero BadMode
                    lbsr      Receive   ; call helper Receive
                    lbcs      Exit      ; branch on carry or error Exit
                    cmpa      #1        ; compare A with #1
                    lbne      BadMode   ; branch when unequal or nonzero BadMode
                    lbsr      Receive   ; call helper Receive
                    lbcs      Exit      ; branch on carry or error Exit
                    cmpa      #$AA      ; compare A with #$AA
                    lbne      BadMode   ; branch when unequal or nonzero BadMode
                    lda       #$40      ; hcs for ACMD41
                    sta       S.HC,u    ; save A in S.HC,u
old1@               ldd       #4096     ; load D from #4096
                    std       S.Retry,u ; save D in S.Retry,u
activate1@          lda       #$77      ; load A from #$77
                    lbsr      CommandZero ; call helper CommandZero
                    lbsr      SendCommand ; call helper SendCommand
                    lbcs      Exit      ; branch on carry or error Exit
                    cmpa      #1        ; compare A with #1
                    lbhi      BadMode   ; branch when unsigned higher BadMode
                    lda       #$69      ; load A from #$69
                    lbsr      CommandZero ; call helper CommandZero
                    lda       S.HC,u    ; load A from S.HC,u
                    sta       S.Command+1,u ; save A in S.Command+1,u
                    lbsr      SendCommand ; call helper SendCommand
                    lbcs      Exit      ; branch on carry or error Exit
                    tsta                ; test accumulator A
                    beq       ocr1@     ; branch when equal or zero ocr1@
                    cmpa      #1        ; compare A with #1
                    lbne      BadMode   ; branch when unequal or nonzero BadMode
                    ldd       S.Retry,u ; load D from S.Retry,u
                    subd      #1        ; subtract from D: #1
                    std       S.Retry,u ; save D in S.Retry,u
                    bne       activate1@ ; branch when unequal or nonzero activate1@
                    lbra      NotReady  ; continue unconditionally NotReady
ocr1@               lda       #$7A      ; load A from #$7A
                    lbsr      CommandZero ; call helper CommandZero
                    lbsr      SendCommand ; call helper SendCommand
                    lbcs      Exit      ; branch on carry or error Exit
                    tsta                ; test accumulator A
                    lbne      BadMode   ; branch when unequal or nonzero BadMode
                    lbsr      Receive   ; call helper Receive
                    lbcs      Exit      ; branch on carry or error Exit
                    bita      #$80      ; power-up complete
                    lbeq      NotReady  ; branch when equal or zero NotReady
                    anda      #$40      ; ccs: block addressing
                    sta       S.HC,u    ; save A in S.HC,u
                    ldb       #3        ; consume ALL remaining OCR bytes
ocrbytes1@          lbsr      Receive   ; call helper Receive
                    lbcs      Exit      ; branch on carry or error Exit
                    decb                ; decrement accumulator B
                    bne       ocrbytes1@ ; branch when unequal or nonzero ocrbytes1@
                    tst       S.HC,u    ; test S.HC,u
                    bne       csd1@     ; branch when unequal or nonzero csd1@
                    lda       #$50      ; sdsc: SET_BLOCKLEN 512
                    lbsr      CommandZero ; call helper CommandZero
                    lda       #2        ; load A from #2
                    sta       S.Command+3,u ; save A in S.Command+3,u
                    lbsr      SendCommand ; call helper SendCommand
                    lbcs      Exit      ; branch on carry or error Exit
                    tsta                ; test accumulator A
                    lbne      BadMode   ; branch when unequal or nonzero BadMode
csd1@               lda       #$49      ; load A from #$49
                    lbsr      CommandZero ; call helper CommandZero
                    lbsr      SendCommand ; call helper SendCommand
                    lbcs      Exit      ; branch on carry or error Exit
                    tsta                ; test accumulator A
                    lbne      BadMode   ; branch when unequal or nonzero BadMode
                    lbsr      Token     ; call helper Token
                    lbcs      Exit      ; branch on carry or error Exit
                    leay      S.CSD,u   ; point Y at S.CSD,u
                    ldb       #16       ; load B from #16
csdbyte1@           lbsr      Receive   ; call helper Receive
                    lbcs      Exit      ; branch on carry or error Exit
                    sta       ,y+       ; save A in ,y+
                    decb                ; decrement accumulator B
                    bne       csdbyte1@ ; branch when unequal or nonzero csdbyte1@
                    lbsr      Receive   ; discard CRC16 (SPI CRC disabled)
                    lbcs      Exit      ; branch on carry or error Exit
                    lbsr      Receive   ; call helper Receive
                    lbcs      Exit      ; branch on carry or error Exit
                    lbsr      Capacity  ; call helper Capacity
                    lbcs      Exit      ; branch on carry or error Exit
                    clr       S.Control,u ; fast SPI from here on
                    inc       S.Ready,u ; increment S.Ready,u
                    clrb                ; clear accumulator B and carry
                    lbra      Exit      ; continue unconditionally Exit

* CSD v2: last LBA = (C_SIZE << 10) | 1023 (avoids 2^32 overflow).
* CSD v1: blocks = (C_SIZE+1) << (READ_BL_LEN+C_SIZE_MULT-7).
Capacity            lda       S.CSD,u   ; load A from S.CSD,u
                    anda      #$C0      ; mask A with #$C0
                    cmpa      #$40      ; compare A with #$40
                    lbeq      v22@      ; branch when equal or zero v22@
                    tsta                ; test accumulator A
                    lbne      CapacityBad ; branch when unequal or nonzero CapacityBad
                    tst       S.HC,u    ; test S.HC,u
                    lbne      CapacityBad ; branch when unequal or nonzero CapacityBad
                    lda       S.CSD+5,u ; load A from S.CSD+5,u
                    anda      #15       ; mask A with #15
                    cmpa      #9        ; compare A with #9
                    lblo      CapacityBad ; branch when unsigned lower CapacityBad
                    cmpa      #11       ; compare A with #11
                    lbhi      CapacityBad ; branch when unsigned higher CapacityBad
                    suba      #7        ; subtract from A: #7
                    pshs      a         ; preserve a on stack
                    lda       S.CSD+9,u ; load A from S.CSD+9,u
                    anda      #3        ; mask A with #3
                    lsla                ; shift or rotate accumulator A
                    ldb       S.CSD+10,u ; load B from S.CSD+10,u
                    lslb                ; shift or rotate accumulator B
                    adca      #0        ; add to A with carry: #0
                    adda      ,s+       ; add to A: ,s+
                    pshs      a         ; shift count 2..11
                    lda       S.CSD+6,u ; load A from S.CSD+6,u
                    anda      #3        ; mask A with #3
                    ldb       S.CSD+7,u ; load B from S.CSD+7,u
                    lslb                ; shift or rotate accumulator B
                    rola                ; shift or rotate accumulator A
                    lslb                ; shift or rotate accumulator B
                    rola                ; shift or rotate accumulator A
                    std       S.Last+2,u ; save D in S.Last+2,u
                    lda       S.CSD+8,u ; load A from S.CSD+8,u
                    lsra                ; shift or rotate accumulator A
                    lsra                ; shift or rotate accumulator A
                    lsra                ; shift or rotate accumulator A
                    lsra                ; shift or rotate accumulator A
                    lsra                ; shift or rotate accumulator A
                    lsra                ; shift or rotate accumulator A
                    ora       S.Last+3,u ; merge A with S.Last+3,u
                    sta       S.Last+3,u ; save A in S.Last+3,u
                    ldd       S.Last+2,u ; load D from S.Last+2,u
                    addd      #1        ; add to D: #1
                    std       S.Last+2,u ; save D in S.Last+2,u
                    clr       S.Last,u  ; clear S.Last,u
                    clr       S.Last+1,u ; clear S.Last+1,u
shift12@            lsl       S.Last+3,u ; shift left S.Last+3,u
                    rol       S.Last+2,u ; rotate left through carry S.Last+2,u
                    rol       S.Last+1,u ; rotate left through carry S.Last+1,u
                    rol       S.Last,u  ; rotate left through carry S.Last,u
                    dec       ,s        ; decrement ,s
                    bne       shift12@  ; branch when unequal or nonzero shift12@
                    leas      1,s       ; point S at 1,s
                    ldd       S.Last+2,u ; load D from S.Last+2,u
                    subd      #1        ; subtract from D: #1
                    std       S.Last+2,u ; save D in S.Last+2,u
                    ldd       S.Last,u  ; load D from S.Last,u
                    sbcb      #0        ; subtract from B with borrow: #0
                    sbca      #0        ; subtract from A with borrow: #0
                    std       S.Last,u  ; save D in S.Last,u
* Byte addressing must fit in a 32-bit SD command argument.
                    cmpd      #$007F    ; compare D with #$007F
                    bhi       CapacityBad ; branch when unsigned higher CapacityBad
                    clrb                ; clear accumulator B and carry
                    rts                 ; return to caller
v22@                tst       S.HC,u    ; test S.HC,u
                    beq       CapacityBad ; branch when equal or zero CapacityBad
                    clr       S.Last,u  ; clear S.Last,u
                    lda       S.CSD+7,u ; load A from S.CSD+7,u
                    anda      #$3F      ; mask A with #$3F
                    sta       S.Last+1,u ; save A in S.Last+1,u
                    ldd       S.CSD+8,u ; load D from S.CSD+8,u
                    std       S.Last+2,u ; save D in S.Last+2,u
                    ldb       #10       ; load B from #10
shift22@            lsl       S.Last+3,u ; shift left S.Last+3,u
                    rol       S.Last+2,u ; rotate left through carry S.Last+2,u
                    rol       S.Last+1,u ; rotate left through carry S.Last+1,u
                    rol       S.Last,u  ; rotate left through carry S.Last,u
                    decb                ; decrement accumulator B
                    bne       shift22@  ; branch when unequal or nonzero shift22@
                    lda       S.Last+2,u ; load A from S.Last+2,u
                    ora       #3        ; merge A with #3
                    sta       S.Last+2,u ; save A in S.Last+2,u
                    lda       #$FF      ; load A from #$FF
                    sta       S.Last+3,u ; save A in S.Last+3,u
                    clrb                ; clear accumulator B and carry
                    rts                 ; return to caller
CapacityBad         ldb       #E$BMode  ; load B from #E$BMode
                    coma                ; complement A and set carry
                    rts                 ; return to caller

Info                pshs      x,y,u     ; preserve x,y,u on stack
                    lbsr      CheckReady ; call helper CheckReady
                    lbcs      Return    ; branch on carry or error Return
                    lda       BC.Unit,y ; load A from BC.Unit,y
                    sta       BI.Unit,x ; save A in BI.Unit,x
                    lda       #BF.Removable|BF.Flush ; load A from #BF.Removable|BF.Flush
                    ldb       SYS0      ; load B from SYS0
                    bitb      #SYS_SD_WP ; test B against #SYS_SD_WP
                    beq       writable3@ ; branch when equal or zero writable3@
                    ora       #BF.ReadOnly ; merge A with #BF.ReadOnly
writable3@          ldb       S.CSD+14,u ; load B from S.CSD+14,u
                    bitb      #$30      ; permanent/temporary CSD write protection
                    beq       flags3@   ; branch when equal or zero flags3@
                    ora       #BF.ReadOnly ; merge A with #BF.ReadOnly
flags3@             sta       BI.Flags,x ; save A in BI.Flags,x
                    ldd       #512      ; load D from #512
                    std       BI.BlockSize,x ; save D in BI.BlockSize,x
                    ldd       #127      ; load D from #127
                    std       BI.MaxCount,x ; save D in BI.MaxCount,x
                    ldd       S.Last,u  ; load D from S.Last,u
                    std       BI.Last,x ; save D in BI.Last,x
                    ldd       S.Last+2,u ; load D from S.Last+2,u
                    std       BI.Last+2,x ; save D in BI.Last+2,x
                    clrb                ; clear accumulator B and carry
                    lbra      Return    ; continue unconditionally Return
Flush               pshs      x,y,u     ; preserve x,y,u on stack
                    lbsr      CheckReady ; call helper CheckReady
                    lbcs      Return    ; branch on carry or error Return
                    lbsr      Select    ; call helper Select
                    lbsr      WaitReady ; call helper WaitReady
                    lbra      Exit      ; continue unconditionally Exit
Term                pshs      x,y,u     ; preserve x,y,u on stack
                    clr       S.Ready,u ; clear S.Ready,u
                    ldx       S.Port,u  ; load X from S.Port,u
                    clr       SDC_STAT,x ; clear SDC_STAT,x
                    clrb                ; clear accumulator B and carry
                    lbra      Return    ; continue unconditionally Return

Read                clra                ; clear accumulator A and carry
                    bra       Transfer  ; continue unconditionally Transfer
Write               lda       #1        ; load A from #1
Transfer            pshs      x,y,u     ; preserve x,y,u on stack
                    sta       S.Write,u ; save A in S.Write,u
                    stx       S.Request,u ; save X in S.Request,u
                    lbsr      CheckReady ; call helper CheckReady
                    lbcs      Return    ; branch on carry or error Return
                    tst       S.Write,u ; test S.Write,u
                    beq       setup4@   ; branch when equal or zero setup4@
                    lda       SYS0      ; load A from SYS0
                    bita      #SYS_SD_WP ; test A against #SYS_SD_WP
                    lbne      WriteProtected ; branch when unequal or nonzero WriteProtected
                    lda       S.CSD+14,u ; load A from S.CSD+14,u
                    bita      #$30      ; test A against #$30
                    lbne      WriteProtected ; branch when unequal or nonzero WriteProtected
setup4@             ldd       BR.LBA,x  ; load D from BR.LBA,x
                    std       S.LBA,u   ; save D in S.LBA,u
                    ldd       BR.LBA+2,x ; load D from BR.LBA+2,x
                    std       S.LBA+2,u ; save D in S.LBA+2,u
                    ldd       BR.Buffer,x ; load D from BR.Buffer,x
                    std       S.Buffer,u ; save D in S.Buffer,u
                    lbsr      Select    ; call helper Select
block4@             lbsr      Present   ; call helper Present
                    lbcs      Exit      ; branch on carry or error Exit
                    lbsr      WaitReady ; call helper WaitReady
                    lbcs      Exit      ; branch on carry or error Exit
                    lda       #$51      ; load A from #$51
                    tst       S.Write,u ; test S.Write,u
                    beq       command4@ ; branch when equal or zero command4@
                    lda       #$58      ; load A from #$58
command4@           lbsr      CommandZero ; call helper CommandZero
                    ldd       S.LBA,u   ; load D from S.LBA,u
                    std       S.Command+1,u ; save D in S.Command+1,u
                    ldd       S.LBA+2,u ; load D from S.LBA+2,u
                    std       S.Command+3,u ; save D in S.Command+3,u
                    tst       S.HC,u    ; test S.HC,u
                    bne       send4@    ; branch when unequal or nonzero send4@
                    ldb       #9        ; sdsc uses byte addresses
shift4@             lsl       S.Command+4,u ; shift left S.Command+4,u
                    rol       S.Command+3,u ; rotate left through carry S.Command+3,u
                    rol       S.Command+2,u ; rotate left through carry S.Command+2,u
                    rol       S.Command+1,u ; rotate left through carry S.Command+1,u
                    lbcs      SectorError ; branch on carry or error SectorError
                    decb                ; decrement accumulator B
                    bne       shift4@   ; branch when unequal or nonzero shift4@
send4@              lbsr      SendCommand ; call helper SendCommand
                    lbcs      Exit      ; branch on carry or error Exit
                    tsta                ; test accumulator A
                    lbne      TransferError ; branch when unequal or nonzero TransferError
                    ldy       S.Buffer,u ; load Y from S.Buffer,u
                    tst       S.Write,u ; test S.Write,u
                    bne       put4@     ; branch when unequal or nonzero put4@
                    lbsr      Token     ; call helper Token
                    lbcs      Exit      ; branch on carry or error Exit
                    ldb       #0        ; load B from #0
get4@               lbsr      Receive   ; call helper Receive
                    lbcs      Exit      ; branch on carry or error Exit
                    sta       ,y+       ; save A in ,y+
                    lbsr      Receive   ; call helper Receive
                    lbcs      Exit      ; branch on carry or error Exit
                    sta       ,y+       ; save A in ,y+
                    decb                ; decrement accumulator B
                    bne       get4@     ; branch when unequal or nonzero get4@
                    lbsr      Receive   ; call helper Receive
                    lbcs      Exit      ; branch on carry or error Exit
                    lbsr      Receive   ; call helper Receive
                    lbcs      Exit      ; branch on carry or error Exit
                    bra       completed4@ ; continue unconditionally completed4@
put4@               lbsr      Receive   ; call helper Receive
                    lbcs      Exit      ; branch on carry or error Exit
                    lda       #$FE      ; load A from #$FE
                    lbsr      Exchange  ; call helper Exchange
                    lbcs      Exit      ; branch on carry or error Exit
                    ldb       #0        ; load B from #0
putbyte4@           lda       ,y+       ; load A from ,y+
                    lbsr      Exchange  ; call helper Exchange
                    lbcs      Exit      ; branch on carry or error Exit
                    lda       ,y+       ; load A from ,y+
                    lbsr      Exchange  ; call helper Exchange
                    lbcs      Exit      ; branch on carry or error Exit
                    decb                ; decrement accumulator B
                    bne       putbyte4@ ; branch when unequal or nonzero putbyte4@
                    lbsr      Receive   ; dummy CRC16
                    lbcs      Exit      ; branch on carry or error Exit
                    lbsr      Receive   ; call helper Receive
                    lbcs      Exit      ; branch on carry or error Exit
                    pshs      y         ; preserve y on stack
                    ldy       #256      ; load Y from #256
response4@          lbsr      Receive   ; call helper Receive
                    bcs       responseend4@ ; branch on carry or error responseend4@
                    cmpa      #$FF      ; compare A with #$FF
                    bne       responsegot4@ ; branch when unequal or nonzero responsegot4@
                    leay      -1,y      ; point Y at -1,y
                    bne       response4@ ; branch when unequal or nonzero response4@
                    coma                ; complement A and set carry
                    bra       responseend4@ ; continue unconditionally responseend4@
responsegot4@       andcc     #$FE      ; clear selected CC bits with #$FE
responseend4@       puls      y         ; restore y from stack
                    lbcs      TransferError ; branch on carry or error TransferError
                    anda      #$1F      ; mask A with #$1F
                    cmpa      #5        ; accepted data-response token
                    lbne      TransferError ; branch when unequal or nonzero TransferError
                    lbsr      WaitReady ; wait for programming completion
                    lbcs      Exit      ; branch on carry or error Exit
                    lda       #$4D      ; cmd13: check programming status
                    lbsr      CommandZero ; call helper CommandZero
                    lbsr      SendCommand ; call helper SendCommand
                    lbcs      Exit      ; branch on carry or error Exit
                    tsta                ; test accumulator A
                    lbne      TransferError ; branch when unequal or nonzero TransferError
                    lbsr      Receive   ; second byte of R2
                    lbcs      Exit      ; branch on carry or error Exit
                    tsta                ; test accumulator A
                    lbne      TransferError ; branch when unequal or nonzero TransferError
completed4@         sty       S.Buffer,u ; save Y in S.Buffer,u
                    ldy       S.Request,u ; load Y from S.Request,u
                    ldd       BR.Done,y ; load D from BR.Done,y
                    addd      #1        ; add to D: #1
                    std       BR.Done,y ; save D in BR.Done,y
                    cmpd      BR.Count,y ; compare D with BR.Count,y
                    beq       complete4@ ; branch when equal or zero complete4@
                    ldd       S.LBA+2,u ; load D from S.LBA+2,u
                    addd      #1        ; add to D: #1
                    std       S.LBA+2,u ; save D in S.LBA+2,u
                    ldd       S.LBA,u   ; load D from S.LBA,u
                    adcb      #0        ; add to B with carry: #0
                    adca      #0        ; add to A with carry: #0
                    std       S.LBA,u   ; save D in S.LBA,u
                    lbra      block4@   ; continue unconditionally block4@
complete4@          clrb                ; clear accumulator B and carry
                    bra       Exit      ; continue unconditionally Exit

UnitError           ldb       #E$Unit   ; load B from #E$Unit
                    coma                ; complement A and set carry
                    lbra      Return    ; continue unconditionally Return
WriteProtected      ldb       #E$WP     ; load B from #E$WP
                    bra       Error     ; continue unconditionally Error
SectorError         ldb       #E$Sect   ; load B from #E$Sect
                    bra       Error     ; continue unconditionally Error
TransferError       ldb       #E$Read   ; load B from #E$Read
                    tst       S.Write,u ; test S.Write,u
                    beq       Error     ; branch when equal or zero Error
                    ldb       #E$Write  ; load B from #E$Write
                    bra       Error     ; continue unconditionally Error
BadMode             ldb       #E$BMode  ; load B from #E$BMode
                    bra       Error     ; continue unconditionally Error
NotReady            ldb       #E$NotRdy ; load B from #E$NotRdy
Error               coma                ; complement A and set carry
* Deselect after every transaction, preserving the original error.
Exit                pshs      d,cc      ; preserve d,cc on stack
                    ldx       S.Port,u  ; load X from S.Port,u
                    lda       S.Control,u ; load A from S.Control,u
                    sta       SDC_STAT,x ; save A in SDC_STAT,x
                    lbsr      Receive   ; trailing clocks, bounded
                    puls      d,cc      ; restore d,cc from stack
Return              puls      x,y,u,pc  ; restore x,y,u,pc from stack

CheckReady          tst       S.Ready,u ; test S.Ready,u
                    beq       absent4@  ; branch when equal or zero absent4@
Present             lda       SYS0      ; load A from SYS0
                    bita      #SYS_SD_CD ; test A against #SYS_SD_CD
                    bne       absent4@  ; branch when unequal or nonzero absent4@
                    andcc     #$FE      ; clear selected CC bits with #$FE
                    rts                 ; return to caller
absent4@            equ       *         leave initialized state intact for detect retry
                    ldb       #E$NotRdy ; load B from #E$NotRdy
                    coma                ; complement A and set carry
                    rts                 ; return to caller
Select              ldx       S.Port,u  ; load X from S.Port,u
                    lda       S.Control,u ; load A from S.Control,u
                    ora       #CS_EN    ; merge A with #CS_EN
                    sta       SDC_STAT,x ; save A in SDC_STAT,x
                    rts                 ; return to caller

* Every hardware wait is bounded, including the SPI byte-transfer busy bit.
* Preserve B/Y on success so callers can use them as counters/cursors.
Receive             lda       #$FF      ; load A from #$FF
Exchange            pshs      y         ; preserve y on stack
                    sta       SDC_DATA,x ; save A in SDC_DATA,x
                    ldy       #$FFFF    ; load Y from #$FFFF
poll5@              tst       SDC_STAT,x ; test SDC_STAT,x
                    bpl       ready5@   ; branch when nonnegative ready5@
                    leay      -1,y      ; point Y at -1,y
                    bne       poll5@    ; branch when unequal or nonzero poll5@
                    ldb       #E$NotRdy ; load B from #E$NotRdy
                    coma                ; complement A and set carry
                    puls      y,pc      ; restore y,pc from stack
ready5@             lda       SDC_DATA,x ; load A from SDC_DATA,x
                    andcc     #$FE      ; clear selected CC bits with #$FE
                    puls      y,pc      ; restore y,pc from stack
WaitReady           pshs      y         ; preserve y on stack
                    ldy       #$FFFF    ; load Y from #$FFFF
wait6@              bsr       Receive   ; call helper Receive
                    bcs       end6@     ; branch on carry or error end6@
                    cmpa      #$FF      ; compare A with #$FF
                    beq       good6@    ; branch when equal or zero good6@
                    leay      -1,y      ; point Y at -1,y
                    bne       wait6@    ; branch when unequal or nonzero wait6@
                    ldb       #E$NotRdy ; load B from #E$NotRdy
                    coma                ; complement A and set carry
                    bra       end6@     ; continue unconditionally end6@
good6@              andcc     #$FE      ; clear selected CC bits with #$FE
end6@               puls      y,pc      ; restore y,pc from stack
Token               pshs      y         ; preserve y on stack
                    ldy       #$FFFF    ; load Y from #$FFFF
wait7@              bsr       Receive   ; call helper Receive
                    bcs       end7@     ; branch on carry or error end7@
                    cmpa      #$FE      ; compare A with #$FE
                    beq       good7@    ; branch when equal or zero good7@
                    cmpa      #$FF      ; compare A with #$FF
                    bne       bad7@     ; branch when unequal or nonzero bad7@
                    leay      -1,y      ; point Y at -1,y
                    bne       wait7@    ; branch when unequal or nonzero wait7@
bad7@               ldb       #E$Read   ; load B from #E$Read
                    coma                ; complement A and set carry
                    bra       end7@     ; continue unconditionally end7@
good7@              andcc     #$FE      ; clear selected CC bits with #$FE
end7@               puls      y,pc      ; restore y,pc from stack
CommandZero         sta       S.Command,u ; save A in S.Command,u
                    clr       S.Command+1,u ; clear S.Command+1,u
                    clr       S.Command+2,u ; clear S.Command+2,u
                    clr       S.Command+3,u ; clear S.Command+3,u
                    clr       S.Command+4,u ; clear S.Command+4,u
                    lda       #$FF      ; load A from #$FF
                    sta       S.Command+5,u ; save A in S.Command+5,u
                    rts                 ; return to caller
SendCommand         pshs      y         ; preserve y on stack
                    leay      S.Command,u ; point Y at S.Command,u
                    lbsr      Receive   ; call helper Receive
                    bcs       end9@     ; branch on carry or error end9@
                    ldb       #6        ; load B from #6
byte9@              lda       ,y+       ; load A from ,y+
                    lbsr      Exchange  ; call helper Exchange
                    bcs       end9@     ; branch on carry or error end9@
                    decb                ; decrement accumulator B
                    bne       byte9@    ; branch when unequal or nonzero byte9@
                    ldb       #16       ; load B from #16
response9@          lbsr      Receive   ; call helper Receive
                    bcs       end9@     ; branch on carry or error end9@
                    bita      #$80      ; test A against #$80
                    beq       good9@    ; branch when equal or zero good9@
                    decb                ; decrement accumulator B
                    bne       response9@ ; branch when unequal or nonzero response9@
                    ldb       #E$NotRdy ; load B from #E$NotRdy
                    coma                ; complement A and set carry
                    bra       end9@     ; continue unconditionally end9@
good9@              andcc     #$FE      ; clear selected CC bits with #$FE
end9@               puls      y,pc      ; restore y,pc from stack
                    emod      ;         finish module and CRC
eom                 equ       *         ; define constant or offset
                    end       ;         end assembly source
