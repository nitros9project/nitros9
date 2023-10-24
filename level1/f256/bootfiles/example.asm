                    use       ../defsfile


IEC_OUTPUT_PORT     equ       0xFE81
IEC_DATA_o          equ       0x01
IEC_CLK_o           equ       0x02
IEC_ATN_o           equ       0x10
IEC_RST_o           equ       0x40
IEC_SREQ_o          equ       0x80
; CODEC
CODEC_LOW           equ       0xFE70
CODEC_HI            equ       0xFE71
CODEC_CTRL          equ       0xFE72
; PSG
PSG_INT_L_PORT      equ       0xE200              ; Control register for the SN76489
PSG_INT_R_PORT      equ       0xE210              ; Control register for the SN76489

mapaddr             equ       $FFA9
mapstart            equ       (mapaddr-$FFA8)*$2000

origin              equ       $D000
                    org       origin
start               andcc     #0xFE               ; Clear Carry
                    orcc      #0x50               ; MASK IRQ & FIRQ
                    lds       #0x0200             ; Set the System Stack to 0x0200
                    ldu       #0x0400             ; Sthe the User Stack to 0x0400
                    jsr       Set_ATN_Hi
                    jsr       Set_Data_Hi         ; Data is how the Slave Response so, no forcing
                    jsr       Set_Clk_Lo          ; Just keep Clk Low, The Jr is the Master
                    jsr       Set_SREQ_Hi         ;

                    lda       #0xFF
                    sta       INT_EDGE_0
                    sta       INT_EDGE_1
                    ;         Mask                all Interrupt @ This Point
                    sta       INT_MASK_0
                    sta       INT_MASK_1
                    lda       INT_PENDING_0
                    sta       INT_PENDING_0
                    lda       INT_PENDING_1
                    sta       INT_PENDING_1
                    jsr       INIT_CODEC          ; Make sure to setup the CODEC Very early
                    jsr       PSG_MUTE            ; Make sure the PSG dont create all king of shenanigans @ boot
                    jsr       SetIOPageC1         ; Call Page $C1
                    jsr       UpdateFONTSet       ; Import a New Font Set
                    jsr       TinyVky_Init
                    jsr       Init_Text_LUT
                    ;         Set                 the Backgroud Color
                    jsr       SetIOPageC3         ; Call Page $C3	(Color for Text)
                    lda       #0x02               ; Blue C64 Color
                    jsr       Fill_Text_Buffer
                    ;         Fill                the Screen with Spaces
                    jsr       SetIOPageC2         ; Call Page $C2	(Color for Text)
                    lda       #0x20
                    jsr       Fill_Text_Buffer    ;
                    jsr       SplashText
                    lda       #0x0C
                    sta       RTC_CTRL
                    lda       RTC_CTRL
                    lda       #0x11
                    sta       RTC_SEC
                    lda       #0x04
                    sta       RTC_CTRL
                    lda       RTC_SEC

                    ;         Set                 the VIA in Input (prolly the mode it is already in)
                    lda       #00
                    sta       VIA_DDRB
                    sta       VIA_DDRA
                    lda       VIA_ORB_IRB
                    lda       #0x55
                    sta       UART_SR
                    lda       UART_SR
                    jsr       INIT_SERIAL
                    lda       #'J
                    jsr       UART_PUTC
                    lda       #'R
                    jsr       UART_PUTC
                    lda       #'.
                    jsr       UART_PUTC

                    jsr       RemoveMMUPage_FromSlot7

Loop4ever           jmp       Loop4ever


                    rts

;
; Turn off both PSG "chips"
;
PSG_MUTE            jsr       SetIOPageC4
                    lda       #0x9f               ; Mute channel #0 (1001111)
                    sta       PSG_INT_L_PORT
                    sta       PSG_INT_R_PORT

                    lda       #0xbf               ; Mute channel #2 (1011111)
                    sta       PSG_INT_L_PORT
                    sta       PSG_INT_R_PORT

                    lda       #0xdf               ; Mute channel #3 (1101111)
                    sta       PSG_INT_L_PORT
                    sta       PSG_INT_R_PORT

                    lda       #0xff               ; Mute channel #4 (1111111)
                    sta       PSG_INT_L_PORT
                    sta       PSG_INT_R_PORT

                    rts
;/////////////////////////
;// CODEC
;/////////////////////////
;CODEC_LOW        = $FE70
;CODEC_HI         = $FE71
;CODEC_CTRL       = $FE72
INIT_CODEC
                    lda       #%00000000
                    sta       CODEC_LOW
                    lda       #%00011010
                    sta       CODEC_HI
                    lda       #0x01
                    sta       CODEC_CTRL          ;
                    jsr       CODEC_WAIT_FINISH
                    ;         LDA                 #%0010101000000011       ;R21 - Enable All the Analog In
                    lda       #%00000011
                    sta       CODEC_LOW
                    lda       #%00101010
                    sta       CODEC_HI
                    lda       #1
                    sta       CODEC_CTRL          ;
                    jsr       CODEC_WAIT_FINISH
                    ;         LDA                 #%0010001100000001      ;R17 - Enable All the Analog In
                    lda       #%00000001
                    sta       CODEC_LOW
                    lda       #%00100011
                    sta       CODEC_HI
                    lda       #1
                    sta       CODEC_CTRL          ;
                    jsr       CODEC_WAIT_FINISH
                    ;         LDA                 #%0010110000000111      ;R22 - Enable all Analog Out
                    lda       #%00000111
                    sta       CODEC_LOW
                    lda       #%00101100
                    sta       CODEC_HI
                    lda       #1
                    sta       CODEC_CTRL          ;
                    jsr       CODEC_WAIT_FINISH
                    ;         LDA                 #%0001010000000010      ;R10 - DAC Interface Control
                    lda       #%00000010
                    sta       CODEC_LOW
                    lda       #%00010100
                    sta       CODEC_HI
                    lda       #1
                    sta       CODEC_CTRL          ;
                    jsr       CODEC_WAIT_FINISH
                    ;         LDA                 #%0001011000000010      ;R11 - ADC Interface Control
                    lda       #%00000010
                    sta       CODEC_LOW
                    lda       #%00010110
                    sta       CODEC_HI
                    lda       #1
                    sta       CODEC_CTRL          ;
                    jsr       CODEC_WAIT_FINISH
                    ;         LDA                 #%0001100111010101      ;R12 - Master Mode Control
                    lda       #%01000101
                    sta       CODEC_LOW
                    lda       #%00011000
                    sta       CODEC_HI
                    lda       #1
                    sta       CODEC_CTRL          ;
                    jsr       CODEC_WAIT_FINISH
                    rts

CODEC_WAIT_FINISH
CODEC_Not_Finished
                    lda       CODEC_CTRL
                    anda      #1
                    cmpa      #1
                    beq       CODEC_Not_Finished
                    rts

;/////////////////////////
;// SERIAL
;/////////////////////////
INIT_SERIAL

                    ;         Init                Baud Rate
                    lda       UART_LCR
                    ora       #LCR_DLB
                    sta       UART_LCR
                    lda       UART_LCR

                    lda       #0
                    sta       UART_DLH
                    lda       #13                 ; (25.125Mhz / (16 * 115200)) = 13.65 (internal speed of Devices inside FPGA is 25.175Mhz (not 6Mhz))
                    sta       UART_DLL

                    lda       UART_LCR
                    eora      #LCR_DLB
                    sta       UART_LCR
                    ;         Init                Serial Parameters
                    lda       #LCR_PARITY_NONE|LCR_STOPBIT_1|LCR_DATABITS_8
                    anda      #0x7F
                    sta       UART_LCR

                    lda       #%11000001          ; FIFO Mode is always On and it has only 14Bytes
                    sta       UART_FCR
                    rts
;
; Send a byte to the UART
;
; Inputs:
;   A = the character to print
;
UART_PUTC
; Wait for the transmit FIFO to free up
                    pshu      a
wait_putc           lda       UART_LSR
                    anda      #LSR_XMIT_EMPTY
                    beq       wait_putc
                    pulu      a
                    sta       UART_TRHB
                    rts

TinyVky_Init
                    lda       #Mstr_Ctrl_Text_Mode_En ;
                    sta       MASTER_CTRL_REG_L
                    lda       MASTER_CTRL_REG_L
                    lda       #Border_Ctrl_Enable
                    sta       BORDER_CTRL_REG
                    lda       #0x00               ;AAFFEE
                    sta       BORDER_COLOR_B
                    lda       #0xD2               ;AAFFEE
                    sta       BORDER_COLOR_G
                    lda       #0x30
                    sta       BORDER_COLOR_R
                    lda       #16
                    sta       BORDER_X_SIZE
                    sta       BORDER_Y_SIZE
                    lda       #Vky_Cursor_Enable|Vky_Cursor_Flash_Rate1|Vky_Cursor_Flash_Disable
                    sta       VKY_TXT_CURSOR_CTRL_REG
                    lda       #0x8C
                    sta       VKY_TXT_CURSOR_CHAR_REG
                    lda       #0
                    sta       VKY_TXT_CURSOR_X_REG_L
                    sta       VKY_TXT_CURSOR_X_REG_H
                    sta       VKY_TXT_CURSOR_Y_REG_H
                    lda       #7
                    sta       VKY_TXT_CURSOR_Y_REG_L
                    rts

; Inititalize Text Mode LUT
Init_Text_LUT
                    ldx       #fg_color_lut
                    ldy       #TEXT_LUT_FG
Text_LUT_Init_Loop
                    lda       ,X+
                    sta       ,Y+
                    cmpx      #fg_color_lut+0x80
                    bne       Text_LUT_Init_Loop
                    rts

; Fill the Text Screen with color so we can see something
; We are in Page 3, the color Page
Fill_Text_Buffer
                    ldx       #mapstart
Fill_Buffer_Loop
                    sta       ,X+
                    cmpx      #mapstart+(80*60)   ; 80x60
                    bne       Fill_Buffer_Loop
                    rts

; Write some Stuff on the boot screen
SplashText
                    ldx       #Text2Display
                    ldy       #mapstart           ; Start of Text Buffer
SplashTextLoop
                    lda       ,X+
                    cmpa      #0x00
                    beq       SplashTextLoop_Done
                    sta       ,Y+
                    jmp       SplashTextLoop
SplashTextLoop_Done
                    rts

UpdateFONTSet
                    ldx       #FONTSet
                    ldy       #mapstart           ; Start of FONT Buffer
FONTSet_Upload_Loop
                    lda       ,X+
                    sta       ,Y+
                    cmpy      #mapstart+0x800
                    bne       FONTSet_Upload_Loop
                    rts

; The MMU Registers were move from $0000 to $FFA0
RemoveMMUPage_FromSlot7 lda       #0x00               ; I am working off the MMU Page 0
                    sta       0xFFA0              ; Load Page Control Register
                    lda       #0x07
                    sta       mapaddr             ; Putting Page $C0 in Slot 7 - 0xFFA8 - Slot 0, 0xFFAF - Slot 7
                    rts

SetIOPageC0         lda       #0x00               ; I am working off the MMU Page 0
                    sta       0xFFA0              ; Load Page Control Register
                    lda       #0xC0
                    sta       mapaddr             ; Putting Page $C0 in Slot 7 - 0xFFA8 - Slot 0, 0xFFAF - Slot 7
                    rts

SetIOPageC1         lda       #0x00               ; I am working off the MMU Page 0
                    sta       0xFFA0              ; Load Page Control Register
                    lda       #0xC1
                    sta       mapaddr             ; Putting Page $C0 in Slot 7 - 0xFFA8 - Slot 0, 0xFFAF - Slot 7
                    rts

SetIOPageC2         lda       #0x00               ; I am working off the MMU Page 0
                    sta       0xFFA0              ; Load Page Control Register
                    lda       #0xC2
                    sta       mapaddr             ; Putting Page $C0 in Slot 7 - 0xFFA8 - Slot 0, 0xFFAF - Slot 7
                    rts

SetIOPageC3         lda       #0x00               ; I am working off the MMU Page 0
                    sta       0xFFA0              ; Load Page Control Register
                    lda       #0xC3
                    sta       mapaddr             ; Putting Page $C0 in Slot 7 - 0xFFA8 - Slot 0, 0xFFAF - Slot 7
                    rts

SetIOPageC4         lda       #0x00               ; I am working off the MMU Page 0
                    sta       0xFFA0              ; Load Page Control Register
                    lda       #0xC4
                    sta       mapaddr             ; Putting Page $C0 in Slot 7 - 0xFFA8 - Slot 0, 0xFFAF - Slot 7
                    rts


Set_ATN_Hi
                    lda       IEC_OUTPUT_PORT     ; Read Write Port's Value
                    ora       #IEC_ATN_o          ; Clear ATN to 0
                    sta       IEC_OUTPUT_PORT     ;
                    rts

; Release the Bus to its Pull-up State
Set_Data_Hi
                    lda       IEC_OUTPUT_PORT     ; Read Write Port's Value
                    ora       #IEC_DATA_o         ; Set Data to 1
                    sta       IEC_OUTPUT_PORT     ;
                    rts

; Force the Clk Line to LOw
Set_Clk_Lo
                    lda       IEC_OUTPUT_PORT     ; Read Write Port's Value
                    anda      #~IEC_CLK_o         ; Clear Clk to 0
                    sta       IEC_OUTPUT_PORT     ;
                    rts

; Release the Attention Pin to its Pull-Up State
Set_SREQ_Hi
                    lda       IEC_OUTPUT_PORT     ; Read Write Port's Value
                    ora       #IEC_SREQ_o         ; Set SREQ to 1
                    sta       IEC_OUTPUT_PORT     ;
                    rts


; DATA
                    align     16
fg_color_lut        fcb       0x00,0x00,0x00,0xFF
                    fcb       0x00,0x00,0x80,0xFF
                    fcb       0x00,0x80,0x00,0xFF
                    fcb       0x80,0x00,0x00,0xFF
                    fcb       0x00,0x80,0x80,0xFF
                    fcb       0x80,0x80,0x00,0xFF
                    fcb       0x80,0x00,0x80,0xFF
                    fcb       0x80,0x80,0x80,0xFF
                    fcb       0x00,0x45,0xFF,0xFF
                    fcb       0x13,0x45,0x8B,0xFF
                    fcb       0x00,0x00,0x20,0xFF
                    fcb       0x00,0x20,0x00,0xFF
                    fcb       0x20,0x00,0x00,0xFF
                    fcb       0x20,0x20,0x20,0xFF
                    fcb       0xFF,0x80,0x00,0xFF
                    fcb       0xFF,0xFF,0xFF,0xFF

bg_color_lut        fcb       0x00,0x00,0x00,0xFF ;BGRA
                    fcb       0xAA,0x00,0x00,0xFF
                    fcb       0x00,0x80,0x00,0xFF
                    fcb       0x00,0x00,0x80,0xFF
                    fcb       0x00,0x20,0x20,0xFF
                    fcb       0x20,0x20,0x00,0xFF
                    fcb       0x20,0x00,0x20,0xFF
                    fcb       0x20,0x20,0x20,0xFF
                    fcb       0x1E,0x69,0xD2,0xFF
                    fcb       0x13,0x45,0x8B,0xFF
                    fcb       0x00,0x00,0x20,0xFF
                    fcb       0x00,0x20,0x00,0xFF
                    fcb       0x40,0x00,0x00,0xFF
                    fcb       0x10,0x10,0x10,0xFF
                    fcb       0x40,0x40,0x40,0xFF
                    fcb       0xFF,0xFF,0xFF,0xFF

Text2Display        .ascii    "DISK               EXTENDED COLOR BASIC 1.1                                                   "
                    .ascii    "COPYRIGHT          (C) 1982 BY TANDY                                                     "
                    .ascii    "UNDER              LICENSE FROM MICROSOFT                                                    "
                    .ascii    "                   "
                    .ascii    "FOENIX             RETRO SYSTEM - F256Jr/F256K - FNX6809 CPU Support                        "
                    .ascii    "                   "
                    .ascii    "OK"
                    fcb       0
                    align     16

FONTSet

L0000               fcb       $06,$09,$10,$3C,$10,$21,$7E,$00 ...<.!~.
L0008               fcb       $00,$00,$00,$00,$00,$00,$FF,$FF ........
L0010               fcb       $00,$00,$00,$00,$00,$FF,$FF,$FF ........
L0018               fcb       $00,$00,$00,$00,$FF,$FF,$FF,$FF ........
L0020               fcb       $00,$00,$00,$FF,$FF,$FF,$FF,$FF ........
L0028               fcb       $00,$00,$FF,$FF,$FF,$FF,$FF,$FF ........
L0030               fcb       $00,$FF,$FF,$FF,$FF,$FF,$FF,$FF ........
L0038               fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ........
L0040               fcb       $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00 ........
L0048               fcb       $FF,$FF,$FF,$FF,$FF,$FF,$00,$00 ........
L0050               fcb       $FF,$FF,$FF,$FF,$FF,$00,$00,$00 ........
L0058               fcb       $FF,$FF,$FF,$FF,$00,$00,$00,$00 ........
L0060               fcb       $FF,$FF,$FF,$00,$00,$00,$00,$00 ........
L0068               fcb       $FF,$FF,$00,$00,$00,$00,$00,$00 ........
L0070               fcb       $FF,$00,$00,$00,$00,$00,$00,$00 ........
L0078               fcb       $08,$00,$22,$00,$08,$00,$02,$00 ..".....
L0080               fcb       $88,$00,$22,$00,$88,$00,$22,$00 .."...".
L0088               fcb       $8A,$00,$2A,$00,$8A,$00,$2A,$00 ..*...*.
L0090               fcb       $AA,$00,$AA,$00,$AA,$00,$AA,$00 *.*.*.*.
L0098               fcb       $AA,$05,$AA,$11,$AA,$05,$AA,$11 *.*.*.*.
L00A0               fcb       $AA,$5F,$AA,$77,$AA,$5F,$AA,$77 *_*w*_*w
L00A8               fcb       $AA,$FF,$AA,$FF,$AA,$FF,$AA,$FF *.*.*.*.
L00B0               fcb       $AF,$FF,$BB,$FF,$AF,$FF,$BB,$FF /.;./.;.
L00B8               fcb       $77,$FF,$DD,$FF,$77,$FF,$DD,$FF w.].w.].
L00C0               fcb       $7F,$FF,$DF,$FF,$77,$FF,$DF,$FF .._.w._.
L00C8               fcb       $FF,$FF,$DF,$FF,$77,$FF,$DD,$FF .._.w.].
L00D0               fcb       $BB,$FF,$EE,$FF,$AA,$FF,$AA,$FF ;.n.*.*.
L00D8               fcb       $AA,$FF,$AA,$77,$AA,$DD,$AA,$55 *.*w*]*U
L00E0               fcb       $AA,$55,$22,$55,$88,$55,$00,$55 *U"U.U.U
L00E8               fcb       $AA,$00,$AA,$00,$88,$00,$22,$00 *.*...".
L00F0               fcb       $33,$99,$CC,$66,$33,$99,$CC,$66 3.Lf3.Lf
L00F8               fcb       $CC,$99,$33,$66,$CC,$99,$33,$66 L.3fL.3f
L0100               fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
L0108               fcb       $08,$08,$08,$08,$00,$00,$08,$00 ........
L0110               fcb       $24,$24,$24,$00,$00,$00,$00,$00 $$$.....
L0118               fcb       $24,$24,$7E,$24,$7E,$24,$24,$00 $$~$~$$.
L0120               fcb       $08,$1E,$28,$1C,$0A,$3C,$08,$00 ..(..<..
L0128               fcb       $00,$62,$64,$08,$10,$26,$46,$00 .bd..&F.
L0130               fcb       $30,$48,$48,$30,$4A,$44,$3A,$00 0HH0JD:.
L0138               fcb       $08,$08,$08,$00,$00,$00,$00,$00 ........
L0140               fcb       $04,$08,$10,$10,$10,$08,$04,$00 ........
L0148               fcb       $20,$10,$08,$08,$08,$10,$20,$00 ..... .
L0150               fcb       $00,$2A,$1C,$3E,$1C,$2A,$00,$00 .*.>.*..
L0158               fcb       $00,$08,$08,$3E,$08,$08,$00,$00 ...>....
L0160               fcb       $00,$00,$00,$00,$00,$08,$08,$10 ........
L0168               fcb       $00,$00,$00,$7E,$00,$00,$00,$00 ...~....
L0170               fcb       $00,$00,$00,$00,$00,$18,$18,$00 ........
L0178               fcb       $00,$02,$04,$08,$10,$20,$40,$00 ..... @.
L0180               fcb       $3C,$42,$46,$5A,$62,$42,$3C,$00 <BFZbB<.
L0188               fcb       $08,$18,$08,$08,$08,$08,$1C,$00 ........
L0190               fcb       $3C,$42,$02,$3C,$40,$40,$7E,$00 <B.<@@~.
L0198               fcb       $3C,$42,$02,$1C,$02,$42,$3C,$00 <B...B<.
L01A0               fcb       $04,$44,$44,$44,$7E,$04,$04,$00 .DDD~...
L01A8               fcb       $7E,$40,$40,$7C,$02,$02,$7C,$00 ~@@|..|.
L01B0               fcb       $3C,$40,$40,$7C,$42,$42,$3C,$00 <@@|BB<.
L01B8               fcb       $7E,$42,$04,$08,$10,$10,$10,$00 ~B......
L01C0               fcb       $3C,$42,$42,$3C,$42,$42,$3C,$00 <BB<BB<.
L01C8               fcb       $3C,$42,$42,$3E,$02,$02,$3C,$00 <BB>..<.
L01D0               fcb       $00,$00,$08,$00,$00,$08,$00,$00 ........
L01D8               fcb       $00,$00,$08,$00,$00,$08,$08,$10 ........
L01E0               fcb       $08,$10,$20,$40,$20,$10,$08,$00 .. @ ...
L01E8               fcb       $00,$00,$7E,$00,$7E,$00,$00,$00 ..~.~...
L01F0               fcb       $10,$08,$04,$02,$04,$08,$10,$00 ........
L01F8               fcb       $3C,$42,$02,$0C,$10,$00,$10,$00 <B......
L0200               fcb       $3C,$42,$4E,$52,$4E,$40,$3C,$00 <BNRN@<.
L0208               fcb       $3C,$42,$42,$7E,$42,$42,$42,$00 <BB~BBB.
L0210               fcb       $7C,$42,$42,$7C,$42,$42,$7C,$00 |BB|BB|.
L0218               fcb       $3C,$42,$40,$40,$40,$42,$3C,$00 <B@@@B<.
L0220               fcb       $7C,$42,$42,$42,$42,$42,$7C,$00 |BBBBB|.
L0228               fcb       $7E,$40,$40,$78,$40,$40,$7E,$00 ~@@x@@~.
L0230               fcb       $7E,$40,$40,$78,$40,$40,$40,$00 ~@@x@@@.
L0238               fcb       $3C,$42,$40,$4E,$42,$42,$3C,$00 <B@NBB<.
L0240               fcb       $42,$42,$42,$7E,$42,$42,$42,$00 BBB~BBB.
L0248               fcb       $1C,$08,$08,$08,$08,$08,$1C,$00 ........
L0250               fcb       $0E,$04,$04,$04,$04,$44,$38,$00 .....D8.
L0258               fcb       $42,$44,$48,$70,$48,$44,$42,$00 BDHpHDB.
L0260               fcb       $40,$40,$40,$40,$40,$40,$7E,$00 @@@@@@~.
L0268               fcb       $41,$63,$55,$49,$41,$41,$41,$00 AcUIAAA.
L0270               fcb       $42,$62,$52,$4A,$46,$42,$42,$00 BbRJFBB.
L0278               fcb       $3C,$42,$42,$42,$42,$42,$3C,$00 <BBBBB<.
L0280               fcb       $7C,$42,$42,$7C,$40,$40,$40,$00 |BB|@@@.
L0288               fcb       $3C,$42,$42,$42,$4A,$44,$3A,$00 <BBBJD:.
L0290               fcb       $7C,$42,$42,$7C,$48,$44,$42,$00 |BB|HDB.
L0298               fcb       $3C,$42,$40,$3C,$02,$42,$3C,$00 <B@<.B<.
L02A0               fcb       $3E,$08,$08,$08,$08,$08,$08,$00 >.......
L02A8               fcb       $42,$42,$42,$42,$42,$42,$3C,$00 BBBBBB<.
L02B0               fcb       $41,$41,$41,$22,$22,$14,$08,$00 AAA""...
L02B8               fcb       $41,$41,$41,$49,$55,$63,$41,$00 AAAIUcA.
L02C0               fcb       $42,$42,$24,$18,$24,$42,$42,$00 BB$.$BB.
L02C8               fcb       $41,$22,$14,$08,$08,$08,$08,$00 A"......
L02D0               fcb       $7F,$02,$04,$08,$10,$20,$7F,$00 ..... ..
L02D8               fcb       $3C,$20,$20,$20,$20,$20,$3C,$00 <     <.
L02E0               fcb       $00,$40,$20,$10,$08,$04,$02,$00 .@ .....
L02E8               fcb       $3C,$04,$04,$04,$04,$04,$3C,$00 <.....<.
L02F0               fcb       $00,$08,$14,$22,$00,$00,$00,$00 ..."....
L02F8               fcb       $00,$00,$00,$00,$00,$00,$00,$FF ........
L0300               fcb       $10,$08,$04,$00,$00,$00,$00,$00 ........
L0308               fcb       $00,$00,$3C,$02,$3E,$42,$3E,$00 ..<.>B>.
L0310               fcb       $40,$40,$7C,$42,$42,$42,$7C,$00 @@|BBB|.
L0318               fcb       $00,$00,$3C,$40,$40,$40,$3C,$00 ..<@@@<.
L0320               fcb       $02,$02,$3E,$42,$42,$42,$3E,$00 ..>BBB>.
L0328               fcb       $00,$00,$3C,$42,$7E,$40,$3C,$00 ..<B~@<.
L0330               fcb       $0C,$10,$10,$7C,$10,$10,$10,$00 ...|....
L0338               fcb       $00,$00,$3E,$42,$42,$3E,$02,$3C ..>BB>.<
L0340               fcb       $40,$40,$7C,$42,$42,$42,$42,$00 @@|BBBB.
L0348               fcb       $08,$00,$18,$08,$08,$08,$08,$00 ........
L0350               fcb       $04,$00,$0C,$04,$04,$04,$04,$38 .......8
L0358               fcb       $40,$40,$44,$48,$50,$68,$44,$00 @@DHPhD.
L0360               fcb       $18,$08,$08,$08,$08,$08,$1C,$00 ........
L0368               fcb       $00,$00,$76,$49,$49,$49,$49,$00 ..vIIII.
L0370               fcb       $00,$00,$7C,$42,$42,$42,$42,$00 ..|BBBB.
L0378               fcb       $00,$00,$3C,$42,$42,$42,$3C,$00 ..<BBB<.
L0380               fcb       $00,$00,$7C,$42,$42,$7C,$40,$40 ..|BB|@@
L0388               fcb       $00,$00,$3E,$42,$42,$3E,$02,$02 ..>BB>..
L0390               fcb       $00,$00,$5C,$60,$40,$40,$40,$00 ..\`@@@.
L0398               fcb       $00,$00,$3E,$40,$3C,$02,$7C,$00 ..>@<.|.
L03A0               fcb       $10,$10,$7C,$10,$10,$10,$0C,$00 ..|.....
L03A8               fcb       $00,$00,$42,$42,$42,$42,$3E,$00 ..BBBB>.
L03B0               fcb       $00,$00,$42,$42,$42,$24,$18,$00 ..BBB$..
L03B8               fcb       $00,$00,$41,$49,$49,$49,$36,$00 ..AIII6.
L03C0               fcb       $00,$00,$42,$24,$18,$24,$42,$00 ..B$.$B.
L03C8               fcb       $00,$00,$42,$42,$42,$3E,$02,$3C ..BBB>.<
L03D0               fcb       $00,$00,$7E,$04,$18,$20,$7E,$00 ..~.. ~.
L03D8               fcb       $0C,$10,$10,$20,$10,$10,$0C,$00 ... ....
L03E0               fcb       $10,$10,$10,$10,$10,$10,$10,$00 ........
L03E8               fcb       $30,$08,$08,$04,$08,$08,$30,$00 0.....0.
L03F0               fcb       $00,$00,$30,$49,$06,$00,$00,$00 ..0I....
L03F8               fcb       $08,$04,$04,$08,$10,$10,$08,$00 ........
L0400               fcb       $02,$02,$02,$02,$02,$02,$02,$02 ........
L0408               fcb       $04,$04,$04,$04,$04,$04,$04,$04 ........
L0410               fcb       $08,$08,$08,$08,$08,$08,$08,$08 ........
L0418               fcb       $10,$10,$10,$10,$10,$10,$10,$10 ........
L0420               fcb       $20,$20,$20,$20,$20,$20,$20,$20
L0428               fcb       $40,$40,$40,$40,$40,$40,$40,$40 @@@@@@@@
L0430               fcb       $80,$80,$80,$80,$80,$80,$80,$80 ........
L0438               fcb       $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0 @@@@@@@@
L0440               fcb       $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0 ````````
L0448               fcb       $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0 pppppppp
L0450               fcb       $F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8 xxxxxxxx
L0458               fcb       $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC ........
L0460               fcb       $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE ........
L0468               fcb       $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F ........
L0470               fcb       $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F ????????
L0478               fcb       $1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F ........
L0480               fcb       $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F ........
L0488               fcb       $07,$07,$07,$07,$07,$07,$07,$07 ........
L0490               fcb       $03,$03,$03,$03,$03,$03,$03,$03 ........
L0498               fcb       $01,$01,$01,$01,$01,$01,$01,$01 ........
L04A0               fcb       $00,$00,$00,$00,$00,$00,$FF,$00 ........
L04A8               fcb       $00,$00,$00,$00,$00,$FF,$00,$00 ........
L04B0               fcb       $00,$00,$00,$00,$FF,$00,$00,$00 ........
L04B8               fcb       $00,$00,$00,$FF,$00,$00,$00,$00 ........
L04C0               fcb       $00,$00,$FF,$00,$00,$00,$00,$00 ........
L04C8               fcb       $00,$FF,$00,$00,$00,$00,$00,$00 ........
L04D0               fcb       $08,$08,$08,$08,$0F,$08,$08,$08 ........
L04D8               fcb       $00,$00,$00,$00,$FF,$08,$08,$08 ........
L04E0               fcb       $08,$08,$08,$08,$FF,$08,$08,$08 ........
L04E8               fcb       $08,$08,$08,$08,$FF,$00,$00,$00 ........
L04F0               fcb       $08,$08,$08,$08,$F8,$08,$08,$08 ....x...
L04F8               fcb       $81,$42,$24,$18,$18,$24,$42,$81 .B$..$B.
L0500               fcb       $00,$00,$00,$00,$0F,$08,$08,$08 ........
L0508               fcb       $00,$00,$00,$00,$F8,$08,$08,$08 ....x...
L0510               fcb       $08,$08,$08,$08,$0F,$00,$00,$00 ........
L0518               fcb       $08,$08,$08,$08,$F8,$00,$00,$00 ....x...
L0520               fcb       $18,$18,$18,$1F,$1F,$18,$18,$18 ........
L0528               fcb       $00,$00,$00,$FF,$FF,$18,$18,$18 ........
L0530               fcb       $18,$18,$18,$FF,$FF,$18,$18,$18 ........
L0538               fcb       $18,$18,$18,$FF,$FF,$00,$00,$00 ........
L0540               fcb       $18,$18,$18,$F8,$F8,$18,$18,$18 ...xx...
L0548               fcb       $00,$00,$00,$1F,$1F,$18,$18,$18 ........
L0550               fcb       $00,$00,$00,$F8,$F8,$18,$18,$18 ...xx...
L0558               fcb       $18,$18,$18,$1F,$1F,$00,$00,$00 ........
L0560               fcb       $18,$18,$18,$F8,$F8,$00,$00,$00 ...xx...
L0568               fcb       $00,$00,$00,$FF,$FF,$00,$00,$00 ........
L0570               fcb       $18,$18,$18,$18,$18,$18,$18,$18 ........
L0578               fcb       $00,$00,$00,$00,$03,$07,$0F,$0F ........
L0580               fcb       $00,$00,$00,$00,$C0,$E0,$F0,$F0 ....@`pp
L0588               fcb       $0F,$0F,$07,$03,$00,$00,$00,$00 ........
L0590               fcb       $F0,$F0,$E0,$C0,$00,$00,$00,$00 pp`@....
L0598               fcb       $00,$3C,$42,$42,$42,$42,$3C,$00 .<BBBB<.
L05A0               fcb       $00,$3C,$7E,$7E,$7E,$7E,$3C,$00 .<~~~~<.
L05A8               fcb       $00,$7E,$7E,$7E,$7E,$7E,$7E,$00 .~~~~~~.
L05B0               fcb       $00,$00,$00,$18,$18,$00,$00,$00 ........
L05B8               fcb       $00,$00,$00,$00,$08,$00,$00,$00 ........
L05C0               fcb       $FF,$7F,$3F,$1F,$0F,$07,$03,$01 ..?.....
L05C8               fcb       $FF,$FE,$FC,$F8,$F0,$E0,$C0,$80 ...xp`@.
L05D0               fcb       $80,$40,$20,$10,$08,$04,$02,$01 .@ .....
L05D8               fcb       $01,$02,$04,$08,$10,$20,$40,$80 ..... @.
L05E0               fcb       $00,$00,$00,$00,$03,$04,$08,$08 ........
L05E8               fcb       $00,$00,$00,$00,$E0,$10,$08,$08 ....`...
L05F0               fcb       $08,$08,$08,$04,$03,$00,$00,$00 ........
L05F8               fcb       $08,$08,$08,$10,$E0,$00,$00,$00 ....`...
L0600               fcb       $00,$00,$00,$00,$00,$00,$00,$55 .......U
L0608               fcb       $00,$00,$00,$00,$00,$00,$AA,$55 ......*U
L0610               fcb       $00,$00,$00,$00,$00,$55,$AA,$55 .....U*U
L0618               fcb       $00,$00,$00,$00,$AA,$55,$AA,$55 ....*U*U
L0620               fcb       $00,$00,$00,$55,$AA,$55,$AA,$55 ...U*U*U
L0628               fcb       $00,$00,$AA,$55,$AA,$55,$AA,$55 ..*U*U*U
L0630               fcb       $00,$55,$AA,$55,$AA,$55,$AA,$55 .U*U*U*U
L0638               fcb       $AA,$55,$AA,$55,$AA,$55,$AA,$55 *U*U*U*U
L0640               fcb       $AA,$55,$AA,$55,$AA,$55,$AA,$00 *U*U*U*.
L0648               fcb       $AA,$55,$AA,$55,$AA,$55,$00,$00 *U*U*U..
L0650               fcb       $AA,$55,$AA,$55,$AA,$00,$00,$00 *U*U*...
L0658               fcb       $AA,$55,$AA,$55,$00,$00,$00,$00 *U*U....
L0660               fcb       $AA,$55,$AA,$00,$00,$00,$00,$00 *U*.....
L0668               fcb       $AA,$55,$00,$00,$00,$00,$00,$00 *U......
L0670               fcb       $AA,$00,$00,$00,$00,$00,$00,$00 *.......
L0678               fcb       $80,$00,$80,$00,$80,$00,$80,$00 ........
L0680               fcb       $80,$40,$80,$40,$80,$40,$80,$40 .@.@.@.@
L0688               fcb       $A0,$40,$A0,$40,$A0,$40,$A0,$40 @ @ @ @
L0690               fcb       $A0,$50,$A0,$50,$A0,$50,$A0,$50 P P P P
L0698               fcb       $A8,$50,$A8,$50,$A8,$50,$A8,$50 (P(P(P(P
L06A0               fcb       $A8,$54,$A8,$54,$A8,$54,$A8,$54 (T(T(T(T
L06A8               fcb       $AA,$54,$AA,$54,$AA,$54,$AA,$54 *T*T*T*T
L06B0               fcb       $2A,$55,$2A,$55,$2A,$55,$2A,$55 *U*U*U*U
L06B8               fcb       $7E,$81,$9D,$A1,$A1,$9D,$81,$7E ~..!!..~
L06C0               fcb       $2A,$15,$2A,$15,$2A,$15,$2A,$15 *.*.*.*.
L06C8               fcb       $0A,$15,$0A,$15,$0A,$15,$0A,$15 ........
L06D0               fcb       $0A,$05,$0A,$05,$0A,$05,$0A,$05 ........
L06D8               fcb       $02,$05,$02,$05,$02,$05,$02,$05 ........
L06E0               fcb       $02,$01,$02,$01,$02,$01,$02,$01 ........
L06E8               fcb       $00,$01,$00,$01,$00,$01,$00,$01 ........
L06F0               fcb       $00,$00,$03,$06,$6C,$38,$10,$00 ....l8..
L06F8               fcb       $7E,$81,$BD,$A1,$B9,$A1,$A1,$7E ~.=!9!!~
L0700               fcb       $00,$00,$3C,$3C,$3C,$3C,$00,$00 ..<<<<..
L0708               fcb       $00,$3C,$42,$5A,$5A,$42,$3C,$00 .<BZZB<.
L0710               fcb       $00,$00,$18,$3C,$3C,$18,$00,$00 ...<<...
L0718               fcb       $FF,$81,$81,$81,$81,$81,$81,$FF ........
L0720               fcb       $01,$03,$07,$0F,$1F,$3F,$7F,$FF .....?..
L0728               fcb       $80,$C0,$E0,$F0,$F8,$FC,$FE,$FF .@`px...
L0730               fcb       $3F,$1F,$0F,$07,$03,$01,$00,$00 ?.......
L0738               fcb       $FC,$F8,$F0,$E0,$C0,$80,$00,$00 .xp`@...
L0740               fcb       $00,$00,$01,$03,$07,$0F,$1F,$3F .......?
L0748               fcb       $00,$00,$80,$C0,$E0,$F0,$F8,$FC ...@`px.
L0750               fcb       $0F,$07,$03,$01,$00,$00,$00,$00 ........
L0758               fcb       $F0,$E0,$C0,$80,$00,$00,$00,$00 p`@.....
L0760               fcb       $00,$00,$00,$00,$01,$03,$07,$0F ........
L0768               fcb       $00,$00,$00,$00,$80,$C0,$E0,$F0 .....@`p
L0770               fcb       $03,$01,$00,$00,$00,$00,$00,$00 ........
L0778               fcb       $C0,$80,$00,$00,$00,$00,$00,$00 @.......
L0780               fcb       $00,$00,$00,$00,$00,$00,$01,$03 ........
L0788               fcb       $00,$00,$00,$00,$00,$00,$80,$C0 .......@
L0790               fcb       $00,$00,$00,$00,$0F,$0F,$0F,$0F ........
L0798               fcb       $00,$00,$00,$00,$F0,$F0,$F0,$F0 ....pppp
L07A0               fcb       $0F,$0F,$0F,$0F,$00,$00,$00,$00 ........
L07A8               fcb       $F0,$F0,$F0,$F0,$00,$00,$00,$00 pppp....
L07B0               fcb       $F0,$F0,$F0,$F0,$0F,$0F,$0F,$0F pppp....
L07B8               fcb       $0F,$0F,$0F,$0F,$F0,$F0,$F0,$F0 ....pppp
L07C0               fcb       $00,$00,$00,$3E,$1C,$08,$00,$00 ...>....
L07C8               fcb       $00,$00,$08,$18,$38,$18,$08,$00 ....8...
L07D0               fcb       $00,$00,$10,$18,$1C,$18,$10,$00 ........
L07D8               fcb       $00,$00,$08,$1C,$3E,$00,$00,$00 ....>...
L07E0               fcb       $36,$7F,$7F,$7F,$3E,$1C,$08,$00 6...>...
L07E8               fcb       $08,$1C,$3E,$7F,$3E,$1C,$08,$00 ..>.>...
L07F0               fcb       $08,$1C,$3E,$7F,$7F,$1C,$3E,$00 ..>...>.
L07F8               fcb       $08,$1C,$2A,$77,$2A,$08,$1C,$00 ..*w*...

                    fill      0,$FFFE-*

                    fdb       origin
