* Wildbits native-block backend, ABI 1. No RBF deblocking or RBSuper statics.
* SD SPI protocol: SD Association Physical Layer Simplified Specification,
* sections 5 (CSD) and 7 (SPI). Supports SDSC and SDHC/SDXC, not MMC/SDUC.
                    use       defsfile
                    use       blkdrv.d
                    org       0
S.Port              rmb       2
S.Request           rmb       2
S.LBA               rmb       4
S.Buffer            rmb       2
S.Write             rmb       1
S.HC                rmb       1
S.Ready             rmb       1
S.Control           rmb       1
S.Retry             rmb       2
S.Last              rmb       4
S.Command           rmb       6
S.CSD               rmb       16
S.Len               equ       .
                    mod       eom,name,Sbrtn+Objct,ReEnt+1,start,0
name                fcs       /llwbsdblk/
                    fcb       1
start               lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      Info
                    lbra      Flush
                    lbra      Term
                    fdb       BD.Magic
                    fcb       BD.Version,BH.Len
                    fdb       S.Len

* All external entries preserve X/Y/U. U points at private allocated state.
Init                pshs      x,y,u
                    clr       S.Ready,u
                    clr       S.HC,u
                    lda       BC.Unit,y
                    lbne      UnitError
                    ldx       BC.Port,y
                    stx       S.Port,u
                    lda       #SPI_CLK
                    sta       S.Control,u
                    lbsr      Present
                    lbcs      Exit
* At least 74 clocks with CS deasserted, then select at slow clock.
                    lda       #SPI_CLK
                    sta       SDC_STAT,x
                    ldb       #10
clock1@             lbsr      Receive
                    lbcs      Exit
                    decb
                    bne       clock1@
                    lda       #SPI_CLK|CS_EN
                    sta       SDC_STAT,x
                    lda       #$40
                    lbsr      CommandZero
                    lda       #$95
                    sta       S.Command+5,u
                    lbsr      SendCommand
                    lbcs      Exit
                    cmpa      #1
                    lbne      NotReady
                    lda       #$48
                    lbsr      CommandZero
                    lda       #1
                    sta       S.Command+3,u
                    lda       #$AA
                    sta       S.Command+4,u
                    lda       #$87
                    sta       S.Command+5,u
                    lbsr      SendCommand
                    lbcs      Exit
                    cmpa      #5        ; idle + illegal command: SD v1
                    beq       old1@
                    cmpa      #1
                    lbne      BadMode
                    lbsr      Receive
                    lbcs      Exit
                    tsta
                    lbne      BadMode
                    lbsr      Receive
                    lbcs      Exit
                    tsta
                    lbne      BadMode
                    lbsr      Receive
                    lbcs      Exit
                    cmpa      #1
                    lbne      BadMode
                    lbsr      Receive
                    lbcs      Exit
                    cmpa      #$AA
                    lbne      BadMode
                    lda       #$40      ; hcs for ACMD41
                    sta       S.HC,u
old1@               ldd       #4096
                    std       S.Retry,u
activate1@          lda       #$77
                    lbsr      CommandZero
                    lbsr      SendCommand
                    lbcs      Exit
                    cmpa      #1
                    lbhi      BadMode
                    lda       #$69
                    lbsr      CommandZero
                    lda       S.HC,u
                    sta       S.Command+1,u
                    lbsr      SendCommand
                    lbcs      Exit
                    tsta
                    beq       ocr1@
                    cmpa      #1
                    lbne      BadMode
                    ldd       S.Retry,u
                    subd      #1
                    std       S.Retry,u
                    bne       activate1@
                    lbra      NotReady
ocr1@               lda       #$7A
                    lbsr      CommandZero
                    lbsr      SendCommand
                    lbcs      Exit
                    tsta
                    lbne      BadMode
                    lbsr      Receive
                    lbcs      Exit
                    bita      #$80      ; power-up complete
                    lbeq      NotReady
                    anda      #$40      ; ccs: block addressing
                    sta       S.HC,u
                    ldb       #3        ; consume ALL remaining OCR bytes
ocrbytes1@          lbsr      Receive
                    lbcs      Exit
                    decb
                    bne       ocrbytes1@
                    tst       S.HC,u
                    bne       csd1@
                    lda       #$50      ; sdsc: SET_BLOCKLEN 512
                    lbsr      CommandZero
                    lda       #2
                    sta       S.Command+3,u
                    lbsr      SendCommand
                    lbcs      Exit
                    tsta
                    lbne      BadMode
csd1@               lda       #$49
                    lbsr      CommandZero
                    lbsr      SendCommand
                    lbcs      Exit
                    tsta
                    lbne      BadMode
                    lbsr      Token
                    lbcs      Exit
                    leay      S.CSD,u
                    ldb       #16
csdbyte1@           lbsr      Receive
                    lbcs      Exit
                    sta       ,y+
                    decb
                    bne       csdbyte1@
                    lbsr      Receive   ; discard CRC16 (SPI CRC disabled)
                    lbcs      Exit
                    lbsr      Receive
                    lbcs      Exit
                    lbsr      Capacity
                    lbcs      Exit
                    clr       S.Control,u ; fast SPI from here on
                    inc       S.Ready,u
                    clrb
                    lbra      Exit

* CSD v2: last LBA = (C_SIZE << 10) | 1023 (avoids 2^32 overflow).
* CSD v1: blocks = (C_SIZE+1) << (READ_BL_LEN+C_SIZE_MULT-7).
Capacity            lda       S.CSD,u
                    anda      #$C0
                    cmpa      #$40
                    lbeq      v22@
                    tsta
                    lbne      CapacityBad
                    tst       S.HC,u
                    lbne      CapacityBad
                    lda       S.CSD+5,u
                    anda      #15
                    cmpa      #9
                    lblo      CapacityBad
                    cmpa      #11
                    lbhi      CapacityBad
                    suba      #7
                    pshs      a
                    lda       S.CSD+9,u
                    anda      #3
                    lsla
                    ldb       S.CSD+10,u
                    lslb
                    adca      #0
                    adda      ,s+
                    pshs      a         ; shift count 2..11
                    lda       S.CSD+6,u
                    anda      #3
                    ldb       S.CSD+7,u
                    lslb
                    rola
                    lslb
                    rola
                    std       S.Last+2,u
                    lda       S.CSD+8,u
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    ora       S.Last+3,u
                    sta       S.Last+3,u
                    ldd       S.Last+2,u
                    addd      #1
                    std       S.Last+2,u
                    clr       S.Last,u
                    clr       S.Last+1,u
shift12@            lsl       S.Last+3,u
                    rol       S.Last+2,u
                    rol       S.Last+1,u
                    rol       S.Last,u
                    dec       ,s
                    bne       shift12@
                    leas      1,s
                    ldd       S.Last+2,u
                    subd      #1
                    std       S.Last+2,u
                    ldd       S.Last,u
                    sbcb      #0
                    sbca      #0
                    std       S.Last,u
* Byte addressing must fit in a 32-bit SD command argument.
                    cmpd      #$007F
                    bhi       CapacityBad
                    clrb
                    rts
v22@                tst       S.HC,u
                    beq       CapacityBad
                    clr       S.Last,u
                    lda       S.CSD+7,u
                    anda      #$3F
                    sta       S.Last+1,u
                    ldd       S.CSD+8,u
                    std       S.Last+2,u
                    ldb       #10
shift22@            lsl       S.Last+3,u
                    rol       S.Last+2,u
                    rol       S.Last+1,u
                    rol       S.Last,u
                    decb
                    bne       shift22@
                    lda       S.Last+2,u
                    ora       #3
                    sta       S.Last+2,u
                    lda       #$FF
                    sta       S.Last+3,u
                    clrb
                    rts
CapacityBad         ldb       #E$BMode
                    coma
                    rts

Info                pshs      x,y,u
                    lbsr      CheckReady
                    lbcs      Return
                    lda       BC.Unit,y
                    sta       BI.Unit,x
                    lda       #BF.Removable|BF.Flush
                    ldb       SYS0
                    bitb      #SYS_SD_WP
                    beq       writable3@
                    ora       #BF.ReadOnly
writable3@          ldb       S.CSD+14,u
                    bitb      #$30      ; permanent/temporary CSD write protection
                    beq       flags3@
                    ora       #BF.ReadOnly
flags3@             sta       BI.Flags,x
                    ldd       #512
                    std       BI.BlockSize,x
                    ldd       #127
                    std       BI.MaxCount,x
                    ldd       S.Last,u
                    std       BI.Last,x
                    ldd       S.Last+2,u
                    std       BI.Last+2,x
                    clrb
                    lbra      Return
Flush               pshs      x,y,u
                    lbsr      CheckReady
                    lbcs      Return
                    lbsr      Select
                    lbsr      WaitReady
                    lbra      Exit
Term                pshs      x,y,u
                    clr       S.Ready,u
                    ldx       S.Port,u
                    clr       SDC_STAT,x
                    clrb
                    lbra      Return

Read                clra
                    bra       Transfer
Write               lda       #1
Transfer            pshs      x,y,u
                    sta       S.Write,u
                    stx       S.Request,u
                    lbsr      CheckReady
                    lbcs      Return
                    tst       S.Write,u
                    beq       setup4@
                    lda       SYS0
                    bita      #SYS_SD_WP
                    lbne      WriteProtected
                    lda       S.CSD+14,u
                    bita      #$30
                    lbne      WriteProtected
setup4@             ldd       BR.LBA,x
                    std       S.LBA,u
                    ldd       BR.LBA+2,x
                    std       S.LBA+2,u
                    ldd       BR.Buffer,x
                    std       S.Buffer,u
                    lbsr      Select
block4@             lbsr      Present
                    lbcs      Exit
                    lbsr      WaitReady
                    lbcs      Exit
                    lda       #$51
                    tst       S.Write,u
                    beq       command4@
                    lda       #$58
command4@           lbsr      CommandZero
                    ldd       S.LBA,u
                    std       S.Command+1,u
                    ldd       S.LBA+2,u
                    std       S.Command+3,u
                    tst       S.HC,u
                    bne       send4@
                    ldb       #9        ; sdsc uses byte addresses
shift4@             lsl       S.Command+4,u
                    rol       S.Command+3,u
                    rol       S.Command+2,u
                    rol       S.Command+1,u
                    lbcs      SectorError
                    decb
                    bne       shift4@
send4@              lbsr      SendCommand
                    lbcs      Exit
                    tsta
                    lbne      TransferError
                    ldy       S.Buffer,u
                    tst       S.Write,u
                    bne       put4@
                    lbsr      Token
                    lbcs      Exit
                    ldb       #0
get4@               lbsr      Receive
                    lbcs      Exit
                    sta       ,y+
                    lbsr      Receive
                    lbcs      Exit
                    sta       ,y+
                    decb
                    bne       get4@
                    lbsr      Receive
                    lbcs      Exit
                    lbsr      Receive
                    lbcs      Exit
                    bra       completed4@
put4@               lbsr      Receive
                    lbcs      Exit
                    lda       #$FE
                    lbsr      Exchange
                    lbcs      Exit
                    ldb       #0
putbyte4@           lda       ,y+
                    lbsr      Exchange
                    lbcs      Exit
                    lda       ,y+
                    lbsr      Exchange
                    lbcs      Exit
                    decb
                    bne       putbyte4@
                    lbsr      Receive   ; dummy CRC16
                    lbcs      Exit
                    lbsr      Receive
                    lbcs      Exit
                    pshs      y
                    ldy       #256
response4@          lbsr      Receive
                    bcs       responseend4@
                    cmpa      #$FF
                    bne       responsegot4@
                    leay      -1,y
                    bne       response4@
                    coma
                    bra       responseend4@
responsegot4@       andcc     #$FE
responseend4@       puls      y
                    lbcs      TransferError
                    anda      #$1F
                    cmpa      #5        ; accepted data-response token
                    lbne      TransferError
                    lbsr      WaitReady ; wait for programming completion
                    lbcs      Exit
                    lda       #$4D      ; cmd13: check programming status
                    lbsr      CommandZero
                    lbsr      SendCommand
                    lbcs      Exit
                    tsta
                    lbne      TransferError
                    lbsr      Receive   ; second byte of R2
                    lbcs      Exit
                    tsta
                    lbne      TransferError
completed4@         sty       S.Buffer,u
                    ldy       S.Request,u
                    ldd       BR.Done,y
                    addd      #1
                    std       BR.Done,y
                    cmpd      BR.Count,y
                    beq       complete4@
                    ldd       S.LBA+2,u
                    addd      #1
                    std       S.LBA+2,u
                    ldd       S.LBA,u
                    adcb      #0
                    adca      #0
                    std       S.LBA,u
                    lbra      block4@
complete4@          clrb
                    bra       Exit

UnitError           ldb       #E$Unit
                    coma
                    lbra      Return
WriteProtected      ldb       #E$WP
                    bra       Error
SectorError         ldb       #E$Sect
                    bra       Error
TransferError       ldb       #E$Read
                    tst       S.Write,u
                    beq       Error
                    ldb       #E$Write
                    bra       Error
BadMode             ldb       #E$BMode
                    bra       Error
NotReady            ldb       #E$NotRdy
Error               coma
* Deselect after every transaction, preserving the original error.
Exit                pshs      d,cc
                    ldx       S.Port,u
                    lda       S.Control,u
                    sta       SDC_STAT,x
                    lbsr      Receive   ; trailing clocks, bounded
                    puls      d,cc
Return              puls      x,y,u,pc

CheckReady          tst       S.Ready,u
                    beq       absent4@
Present             lda       SYS0
                    bita      #SYS_SD_CD
                    bne       absent4@
                    andcc     #$FE
                    rts
absent4@            clr       S.Ready,u
                    ldb       #E$NotRdy
                    coma
                    rts
Select              ldx       S.Port,u
                    lda       S.Control,u
                    ora       #CS_EN
                    sta       SDC_STAT,x
                    rts

* Every hardware wait is bounded, including the SPI byte-transfer busy bit.
* Preserve B/Y on success so callers can use them as counters/cursors.
Receive             lda       #$FF
Exchange            pshs      y
                    sta       SDC_DATA,x
                    ldy       #$FFFF
poll5@              tst       SDC_STAT,x
                    bpl       ready5@
                    leay      -1,y
                    bne       poll5@
                    ldb       #E$NotRdy
                    coma
                    puls      y,pc
ready5@             lda       SDC_DATA,x
                    andcc     #$FE
                    puls      y,pc
WaitReady           pshs      y
                    ldy       #$FFFF
wait6@              bsr       Receive
                    bcs       end6@
                    cmpa      #$FF
                    beq       good6@
                    leay      -1,y
                    bne       wait6@
                    ldb       #E$NotRdy
                    coma
                    bra       end6@
good6@              andcc     #$FE
end6@               puls      y,pc
Token               pshs      y
                    ldy       #$FFFF
wait7@              bsr       Receive
                    bcs       end7@
                    cmpa      #$FE
                    beq       good7@
                    cmpa      #$FF
                    bne       bad7@
                    leay      -1,y
                    bne       wait7@
bad7@               ldb       #E$Read
                    coma
                    bra       end7@
good7@              andcc     #$FE
end7@               puls      y,pc
CommandZero         sta       S.Command,u
                    clr       S.Command+1,u
                    clr       S.Command+2,u
                    clr       S.Command+3,u
                    clr       S.Command+4,u
                    lda       #$FF
                    sta       S.Command+5,u
                    rts
SendCommand         pshs      y
                    leay      S.Command,u
                    lbsr      Receive
                    bcs       end9@
                    ldb       #6
byte9@              lda       ,y+
                    lbsr      Exchange
                    bcs       end9@
                    decb
                    bne       byte9@
                    ldb       #16
response9@          lbsr      Receive
                    bcs       end9@
                    bita      #$80
                    beq       good9@
                    decb
                    bne       response9@
                    ldb       #E$NotRdy
                    coma
                    bra       end9@
good9@              andcc     #$FE
end9@               puls      y,pc
                    emod
eom                 equ       *
                    end
