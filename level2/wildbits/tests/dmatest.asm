********************************************************************
* dmatest - TinyVicky II Hardware DMA Engine Diagnostic Suite
*
* Validates:
*  1. 1D Linear DMA Fill (256 bytes with $5A)
*  2. 1D Linear DMA Copy (256 bytes ramp pattern)
*  3. 2D Rectangular Blit with Strides (16x16 block in 32-byte pitch)
*  4. 2D Rectangular Fill with Stride (8x8 box in 32-byte pitch)
*  5. DMA Completion Interrupt Assertion (INT_DMA0 on Group 0, bit 6)
********************************************************************

                    nam       dmatest
                    ttl       DMA Engine Diagnostic

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

* Explicit Hardware Register Equates
DMA_BASE_ADDR       equ       $FEC0
DMA_CTRL            equ       DMA_BASE_ADDR+DMA_CTRL_REG
DMA_STATUS          equ       DMA_BASE_ADDR+DMA_STATUS_REG
DMA_DATA_WRITE      equ       DMA_BASE_ADDR+DMA_DATA_2_WRITE
DMA_SRC_H           equ       DMA_BASE_ADDR+DMA_SOURCE_ADDR_H
DMA_SRC_M           equ       DMA_BASE_ADDR+DMA_SOURCE_ADDR_M
DMA_SRC_L           equ       DMA_BASE_ADDR+DMA_SOURCE_ADDR_L
DMA_DST_H           equ       DMA_BASE_ADDR+DMA_DEST_ADDR_H
DMA_DST_M           equ       DMA_BASE_ADDR+DMA_DEST_ADDR_M
DMA_DST_L           equ       DMA_BASE_ADDR+DMA_DEST_ADDR_L
DMA_SZ_1D_H         equ       DMA_BASE_ADDR+DMA_SIZE_1D_H
DMA_SZ_1D_M         equ       DMA_BASE_ADDR+DMA_SIZE_1D_M
DMA_SZ_1D_L         equ       DMA_BASE_ADDR+DMA_SIZE_1D_L
DMA_SZ_X_H          equ       DMA_BASE_ADDR+DMA_SIZE_X_H
DMA_SZ_X_L          equ       DMA_BASE_ADDR+DMA_SIZE_X_L
DMA_SZ_Y_H          equ       DMA_BASE_ADDR+DMA_SIZE_Y_H
DMA_SZ_Y_L          equ       DMA_BASE_ADDR+DMA_SIZE_Y_L
DMA_STRD_S_H        equ       DMA_BASE_ADDR+DMA_SRC_STRIDE_X_H
DMA_STRD_S_L        equ       DMA_BASE_ADDR+DMA_SRC_STRIDE_X_L
DMA_STRD_D_H        equ       DMA_BASE_ADDR+DMA_DST_STRIDE_Y_H
DMA_STRD_D_L        equ       DMA_BASE_ADDR+DMA_DST_STRIDE_Y_L

                    mod       eom,name,tylg,atrv,start,size

                    ORG       0
pass_count          rmb       1
fail_count          rmb       1
scratch             rmb       1
scratch_mmu         rmb       1
temp_buf            rmb       16
dma_src_buf         rmb       256
dma_dst_buf         rmb       1024
                    rmb       256                 stack
size                equ       .

name                fcs       /dmatest/
                    fcb       edition

start               equ       *
                    clr       <pass_count
                    clr       <fail_count

                    leax      msg_banner,pcr
                    lbsr      PrintStr

* ====================================================================
* TEST 1: 1D Linear DMA Fill (256 bytes with $5A)
* ====================================================================
Test1               leax      msg_t1,pcr
                    lbsr      PrintStr

* Clear destination buffer with $00
                    leax      dma_dst_buf,u
                    ldb       #0
t1_clr              clr       ,x+
                    decb
                    bne       t1_clr

* Destination physical address
                    leax      dma_dst_buf,u
                    lbsr      GetPhysAddr         returns A=H, B=M, scratch=L
                    sta       >DMA_DST_H
                    stb       >DMA_DST_M
                    lda       <scratch
                    sta       >DMA_DST_L

* Fill byte
                    lda       #$5A
                    sta       >DMA_DATA_WRITE

* 1D Size: 256 bytes ($000100)
                    clr       >DMA_SZ_1D_H
                    lda       #$01
                    sta       >DMA_SZ_1D_M
                    clr       >DMA_SZ_1D_L

* Trigger: START=1, 1D=0, FILL=1, ENABLE=1 ($85)
                    lda       #DMA_CTRL_Start_Trf+DMA_CTRL_Fill+DMA_CTRL_Enable
                    lbsr      DmaStartWait
                    lbcs      t1_fail

* Verify destination buffer
                    leax      dma_dst_buf,u
                    ldb       #0
t1_chk              lda       ,x+
                    cmpa      #$5A
                    lbne      t1_fail
                    decb
                    bne       t1_chk

                    inc       <pass_count
                    leax      msg_pass,pcr
                    lbsr      PrintStr
                    lbra      Test2

t1_fail             inc       <fail_count
                    leax      msg_fail,pcr
                    lbsr      PrintStr

* ====================================================================
* TEST 2: 1D Linear DMA Copy (256 bytes ramp pattern)
* ====================================================================
Test2               leax      msg_t2,pcr
                    lbsr      PrintStr

* Initialize source buffer with ramp pattern $00..$FF
                    leax      dma_src_buf,u
                    clra
t2_ramp             sta       ,x+
                    inca
                    bne       t2_ramp

* Clear destination buffer with $00
                    leax      dma_dst_buf,u
                    ldb       #0
t2_clr              clr       ,x+
                    decb
                    bne       t2_clr

* Source physical address
                    leax      dma_src_buf,u
                    lbsr      GetPhysAddr
                    sta       >DMA_SRC_H
                    stb       >DMA_SRC_M
                    lda       <scratch
                    sta       >DMA_SRC_L

* Destination physical address
                    leax      dma_dst_buf,u
                    lbsr      GetPhysAddr
                    sta       >DMA_DST_H
                    stb       >DMA_DST_M
                    lda       <scratch
                    sta       >DMA_DST_L

* 1D Size: 256 bytes ($000100)
                    clr       >DMA_SZ_1D_H
                    lda       #$01
                    sta       >DMA_SZ_1D_M
                    clr       >DMA_SZ_1D_L

* Trigger: START=1, 1D=0, FILL=0, ENABLE=1 ($81)
                    lda       #DMA_CTRL_Start_Trf+DMA_CTRL_Enable
                    lbsr      DmaStartWait
                    lbcs      t2_fail

* Verify destination buffer matches ramp pattern
                    leax      dma_dst_buf,u
                    clra
t2_chk              cmpa      ,x+
                    lbne      t2_fail
                    inca
                    bne       t2_chk

                    inc       <pass_count
                    leax      msg_pass,pcr
                    lbsr      PrintStr
                    lbra      Test3

t2_fail             inc       <fail_count
                    leax      msg_fail,pcr
                    lbsr      PrintStr

* ====================================================================
* TEST 3: 2D Rectangular Block Copy with Strides (16x16 in 32-pitch canvas)
* ====================================================================
Test3               leax      msg_t3,pcr
                    lbsr      PrintStr

* Re-initialize source buffer with ramp pattern $00..$FF
                    leax      dma_src_buf,u
                    clra
t3_init             sta       ,x+
                    inca
                    bne       t3_init

* Clear 1024-byte destination canvas with $EE
                    leax      dma_dst_buf,u
                    ldy       #1024
t3_clr              lda       #$EE
                    sta       ,x+
                    leay      -1,y
                    bne       t3_clr

* Source physical address
                    leax      dma_src_buf,u
                    lbsr      GetPhysAddr
                    sta       >DMA_SRC_H
                    stb       >DMA_SRC_M
                    lda       <scratch
                    sta       >DMA_SRC_L

* Destination physical address
                    leax      dma_dst_buf,u
                    lbsr      GetPhysAddr
                    sta       >DMA_DST_H
                    stb       >DMA_DST_M
                    lda       <scratch
                    sta       >DMA_DST_L

* 2D Dimensions: Width = 16, Height = 16
                    clr       >DMA_SZ_X_H
                    lda       #16
                    sta       >DMA_SZ_X_L
                    clr       >DMA_SZ_Y_H
                    lda       #16
                    sta       >DMA_SZ_Y_L

* 2D Strides: Source = 16, Destination = 32
                    clr       >DMA_STRD_S_H
                    lda       #16
                    sta       >DMA_STRD_S_L
                    clr       >DMA_STRD_D_H
                    lda       #32
                    sta       >DMA_STRD_D_L

* Trigger: START=1, 2D=1, FILL=0, ENABLE=1 ($83)
                    lda       #DMA_CTRL_Start_Trf+DMA_CTRL_1D_2D+DMA_CTRL_Enable
                    lbsr      DmaStartWait
                    lbcs      t3_fail

* Verify 2D geometry:
* For rows 0..15: cols 0..15 must match ramp pattern (row*16 + col),
* and cols 16..31 must remain untouched ($EE).
                    clr       <scratch            scratch = row
t3_row              leax      dma_dst_buf,u
                    lda       <scratch
                    ldb       #32
                    mul                           D = row * 32
                    leax      d,x                 X = &dma_dst_buf[row * 32]
                    clrb                          B = col (0..15)
t3_col              lda       <scratch
                    asla
                    asla
                    asla
                    asla                          A = row * 16
                    pshs      b
                    adda      ,s+                 A = expected ramp byte
                    cmpa      ,x+
                    lbne      t3_fail
                    incb
                    cmpb      #16
                    bne       t3_col

* Check stride margin (cols 16..31 must be $EE)
t3_margin           lda       ,x+
                    cmpa      #$EE
                    lbne      t3_fail
                    incb
                    cmpb      #32
                    bne       t3_margin

                    inc       <scratch
                    lda       <scratch
                    cmpa      #16
                    lbne      t3_row

                    inc       <pass_count
                    leax      msg_pass,pcr
                    lbsr      PrintStr
                    lbra      Test4

t3_fail             inc       <fail_count
                    leax      msg_fail,pcr
                    lbsr      PrintStr

* ====================================================================
* TEST 4: 2D Rectangular Block Fill with Stride (8x8 box in 32-pitch canvas)
* ====================================================================
Test4               leax      msg_t4,pcr
                    lbsr      PrintStr

* Clear 1024-byte destination canvas with $00
                    leax      dma_dst_buf,u
                    ldy       #1024
t4_clr              clr       ,x+
                    leay      -1,y
                    bne       t4_clr

* Destination physical address
                    leax      dma_dst_buf,u
                    lbsr      GetPhysAddr
                    sta       >DMA_DST_H
                    stb       >DMA_DST_M
                    lda       <scratch
                    sta       >DMA_DST_L

* Fill byte
                    lda       #$C3
                    sta       >DMA_DATA_WRITE

* 2D Dimensions: Width = 8, Height = 8
                    clr       >DMA_SZ_X_H
                    lda       #8
                    sta       >DMA_SZ_X_L
                    clr       >DMA_SZ_Y_H
                    lda       #8
                    sta       >DMA_SZ_Y_L

* 2D Stride: Destination = 32
                    clr       >DMA_STRD_D_H
                    lda       #32
                    sta       >DMA_STRD_D_L

* Trigger: START=1, 2D=1, FILL=1, ENABLE=1 ($87)
                    lda       #DMA_CTRL_Start_Trf+DMA_CTRL_1D_2D+DMA_CTRL_Fill+DMA_CTRL_Enable
                    lbsr      DmaStartWait
                    lbcs      t4_fail

* Verify 8x8 box is $C3 and margins are $00
                    clr       <scratch            scratch = row
t4_row              clrb                          B = col
t4_col              leax      dma_dst_buf,u
                    pshs      b
                    lda       <scratch
                    ldb       #32
                    mul                           D = row * 32
                    leax      d,x
                    puls      b
                    cmpb      #8
                    bhs       t4_margin
                    lda       b,x
                    cmpa      #$C3
                    lbne      t4_fail
                    bra       t4_next
t4_margin           lda       b,x
                    tsta
                    lbne      t4_fail
t4_next             incb
                    cmpb      #32
                    bne       t4_col

                    inc       <scratch
                    lda       <scratch
                    cmpa      #8
                    lbne      t4_row

                    inc       <pass_count
                    leax      msg_pass,pcr
                    lbsr      PrintStr
                    lbra      Test5

t4_fail             inc       <fail_count
                    leax      msg_fail,pcr
                    lbsr      PrintStr

* ====================================================================
* TEST 5: Completion Interrupt Assertion (INT_DMA0 on Group 0, bit 6)
* ====================================================================
Test5               leax      msg_t5,pcr
                    lbsr      PrintStr

* Mask CPU interrupts to safely test pending register bit
                    pshs      cc
                    orcc      #IntMasks

* Clear pending INT_DMA0 (write-1-to-clear on $FE20 bit 6)
                    lda       #$40
                    sta       >INT_PENDING_0

* Verify bit is 0 before trigger
                    lda       >INT_PENDING_0
                    bita      #$40
                    lbne      t5_fail

* Destination physical address
                    leax      dma_dst_buf,u
                    lbsr      GetPhysAddr
                    sta       >DMA_DST_H
                    stb       >DMA_DST_M
                    lda       <scratch
                    sta       >DMA_DST_L

                    lda       #$77
                    sta       >DMA_DATA_WRITE

                    clr       >DMA_SZ_1D_H
                    clr       >DMA_SZ_1D_M
                    lda       #16
                    sta       >DMA_SZ_1D_L

* Trigger with Int_En=1: START=1, FILL=1, INT_EN=1, ENABLE=1 ($8D)
                    lda       #DMA_CTRL_Start_Trf+DMA_CTRL_Fill+DMA_CTRL_Int_En+DMA_CTRL_Enable
                    lbsr      DmaStartWait
                    lbcs      t5_fail

* Check if Group 0 pending register ($FE20) bit 6 (INT_DMA0) was asserted
                    lda       >INT_PENDING_0
                    bita      #$40
                    lbeq      t5_fail

* Clear pending bit
                    lda       #$40
                    sta       >INT_PENDING_0

* Verify bit is cleared
                    lda       >INT_PENDING_0
                    bita      #$40
                    lbne      t5_fail

                    puls      cc                  restore caller interrupt masks

                    inc       <pass_count
                    leax      msg_pass,pcr
                    lbsr      PrintStr
                    lbra      Report

t5_fail             lda       #$40
                    sta       >INT_PENDING_0
                    puls      cc
                    inc       <fail_count
                    leax      msg_fail,pcr
                    lbsr      PrintStr

* ====================================================================
* Summary & Exit
* ====================================================================
Report              leax      msg_sep,pcr
                    lbsr      PrintStr

                    leax      msg_summary,pcr
                    lbsr      PrintStr

                    lda       <pass_count
                    adda      #'0
                    lbsr      PrintChar

                    leax      msg_of5,pcr
                    lbsr      PrintStr

                    lda       <fail_count
                    tsta
                    bne       ExitFail

                    leax      msg_success,pcr
                    lbsr      PrintStr
                    clrb                          Exit status 0 = Success
                    os9       F$Exit

ExitFail            leax      msg_error,pcr
                    lbsr      PrintStr
                    ldb       #1                  Exit status 1 = Error
                    os9       F$Exit

* --------------------------------------------------------------------
* GetPhysAddr: Convert logical address in X to 24-bit physical address
* Returns:
*   A = Phys Addr [23:16]
*   B = Phys Addr [15:8]
*   scratch = Phys Addr [7:0]
* --------------------------------------------------------------------
GetPhysAddr         pshs      x,y,cc
                    orcc      #IntMasks
                    lda       >MMU_MEM_CTRL
                    sta       <scratch_mmu
                    tfr       a,b
                    andb      #$03                active LUT (0..3)
                    lslb
                    lslb
                    lslb
                    lslb                          active LUT << 4
                    anda      #$CF                clear edit LUT bits
                    pshs      b
                    ora       ,s+
                    sta       >MMU_MEM_CTRL       EDIT_LUT = ACTIVE_LUT

* Get slot number from logical address X: slot = (X >> 13) & 7
                    tfr       x,d                 A = X_hi, B = X_lo
                    pshs      b                   save X_lo on stack
                    tfr       a,b
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    andb      #$07                B = slot (0..7)
                    ldy       #MMU_SLOT_0
                    ldb       b,y                 B = physical block assigned to slot

* Restore MMU_MEM_CTRL
                    pshs      a,b                 save X_hi (1,s) and Block B (0,s)
                    lda       <scratch_mmu
                    sta       >MMU_MEM_CTRL
                    puls      a,b                 B = physical block, A = X_hi

* B = Physical block P (8-bit)
* A = Logical address high byte (X_hi)
* 0,s = Logical address low byte (X_lo)
* Compute 24-bit address:
* Phys[23:16] = P >> 3
* Phys[15:8]  = ((P << 5) & $E0) | (X_hi & $1F)
* Phys[7:0]   = X_lo
                    pshs      a                   save X_hi
                    tfr       b,a
                    lsra
                    lsra
                    lsra                          A = P >> 3 (Phys[23:16])
                    pshs      a                   save Phys[23:16]

                    lslb
                    lslb
                    lslb
                    lslb
                    lslb                          B = (P << 5) & $E0
                    lda       1,s                 A = X_hi
                    anda      #$1F
                    pshs      a
                    orb       ,s+                 B = Phys[15:8]

                    lda       2,s                 A = X_lo
                    sta       <scratch            scratch = Phys[7:0]

                    puls      a                   A = Phys[23:16]
                    leas      2,s                 pop X_hi and X_lo
                    puls      x,y,cc,pc

* ---- PrintSubroutines ----
PrintStr            pshs      a,y
ps_lp               lda       ,x+
                    beq       ps_done
                    lbsr      PrintChar
                    bra       ps_lp
ps_done             puls      a,y,pc

PrintChar           pshs      a,x,y
                    sta       <temp_buf
                    lda       #1                  stdout (path 1)
                    leax      <temp_buf,u
                    ldy       #1
                    os9       I$Write
                    lda       <temp_buf
                    cmpa      #C$CR
                    bne       pc_ex
                    lda       #C$LF
                    sta       <temp_buf
                    lda       #1
                    leax      <temp_buf,u
                    ldy       #1
                    os9       I$Write
pc_ex               puls      a,x,y,pc

* ---- Message Strings ----
msg_banner          fcc       "=== TINYVICKY II DMA ENGINE DIAGNOSTIC ==="
                    fcb       C$CR,0
msg_t1              fcc       "[TEST 1] 1D Linear Fill (256B with $5A)  "
                    fcb       0
msg_t2              fcc       "[TEST 2] 1D Linear Copy (256B Ramp)      "
                    fcb       0
msg_t3              fcc       "[TEST 3] 2D Rect Copy (16x16, Stride 32) "
                    fcb       0
msg_t4              fcc       "[TEST 4] 2D Rect Fill (8x8, Stride 32)   "
                    fcb       0
msg_t5              fcc       "[TEST 5] Interrupt Assertion (INT_DMA0)  "
                    fcb       0
msg_pass            fcc       "-> [PASS]"
                    fcb       C$CR,0
msg_fail            fcc       "-> [FAIL]"
                    fcb       C$CR,0
msg_sep             fcc       "------------------------------------------"
                    fcb       C$CR,0
msg_summary         fcc       "RESULTS: Passed "
                    fcb       0
msg_of5             fcc       " / 5 tests"
                    fcb       C$CR,0
msg_success         fcc       "ALL TINYVICKY DMA ENGINE TESTS PASSED!"
                    fcb       C$CR,0
msg_error           fcc       "DMA ENGINE HARDWARE MISMATCH DETECTED!"
                    fcb       C$CR,0

* RC16 START is edge triggered. Clear it before every command.
DmaStartWait        pshs      x,y
                    anda      #$7F
                    sta       >DMA_CTRL
                    ora       #DMA_CTRL_Start_Trf
                    sta       >DMA_CTRL
                    ldy       #$0010
                    ldx       #0
dma_poll            lda       >DMA_STATUS
                    bita      #DMA_STATUS_TRF_IP
                    beq       dma_done
                    leax      -1,x
                    bne       dma_poll
                    leay      -1,y
                    bne       dma_poll
                    ldb       #E$NotRdy
                    orcc      #1
                    puls      x,y,pc
dma_done            clr       >DMA_CTRL
                    andcc     #$FE
                    puls      x,y,pc

                    emod
eom                 equ       *
                    end
