                  IFNE    F256.D-1
F256.D              set       1

********************************************************************
* F256Defs - NitrOS-9 System Definitions for the Foenix F256
*
* This is a high level view of the F256 memory map as setup by
* NitrOS-9.
*
*     $0000----> ==================================
*               |                                  |
*               |      NitrOS-9 Globals/Stack      |
*               |                                  |
*     $0500---->|==================================|
*               |                                  |
*                 . . . . . . . . . . . . . . . . .
*               |                                  |
*               |   RAM available for allocation   |
*               |       by NitrOS-9 and Apps       |
*               |                                  |
*                 . . . . . . . . . . . . . . . . .
*               |                                  |
*     $FD00---->|==================================|
*               |    Constant RAM (for Level 2)    |
*     $FE00---->|==================================|
*               |                I/O               |
*               |            &  Vectors            |
*                ==================================
*
* F256 hardware is documented here:
*   https://github.com/pweingar/C256jrManual/blob/main/tex/f256jr_ref.pdf
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2023/02/07  Boisy G. Pitre
* Started.
*
*          2023/08/16  Boisy G. Pitre
* Modified to address new memory map that Stefany created.

********************************************************************
* Ticks per second.
*
TkPerSec            set       60

                  IFEQ    Level-1

********************************************************************
*
* NitrOS-9 Level 1 Section
*
********************************************************************

********************************************************************
* Boot definitions for NitrOS-9 Level 1
*
* These definitions are not strictly for 'Boot', but are for booting the
* system.
*
HW.Page             set       $FF       device descriptor hardware page

                  ELSE

HW.Page             set       $07       device descriptor hardware page
Bt.Start            set       $EE00     start address of where KRN is in memory

*************************************************
*
* NitrOS-9 Level 2 Section
*
*************************************************

****************************************
* Dynamic Address Translator Definitions
*
DAT.BlCt            EQU       8         DAT blocks/address space
DAT.BlSz            EQU       (256/DAT.BlCt)*256 DAT block size
DAT.ImSz            EQU       DAT.BlCt*2 DAT image size
DAT.Addr            EQU       -(DAT.BlSz/256) DAT MSB address bits
DAT.Task            EQU       $FFA0     task register address
DAT.TkCt            EQU       32        number of DAT tasks
DAT.Regs            EQU       $FFA8     DAT block registers base address
DAT.Free            EQU       $333E     free block number
DAT.BlMx            EQU       $3F       maximum block number
DAT.BMSz            EQU       $40       memory block map size
DAT.WrPr            EQU       0         no write protect
DAT.WrEn            EQU       0         no write enable
SysTask             EQU       0         CoCo system task number
IOBlock             EQU       $3F
ROMBlock            EQU       $3F
IOAddr              EQU       $7F
ROMCount            EQU       1         number of blocks of ROM (high RAM block)
RAMCount            EQU       1         initial blocks of RAM
MoveBlks            EQU       DAT.BlCt-ROMCount-2 block numbers used for copies
BlockTyp            EQU       1         check only first bytes of RAM block
ByteType            EQU       2         check entire block of RAM
Limited             EQU       1         check only upper memory for ROM modules
UnLimitd            EQU       2         check all NotRAM for modules
* NOTE: this check assumes any NotRAM with a module will
*       always start with $87CD in first two bytes of block
RAMCheck            EQU       BlockTyp  check only beg bytes of block
ROMCheck            EQU       Limited   check only upper few blocks for ROM
LastRAM             EQU       IOBlock   maximum RAM block number

HW.Page             SET       $7        device descriptor hardware page

* KrnBlk defines the block number of the 8K RAM block that is mapped to
* the top of CPU address space ($E000-$FFFF) for the system process, and
* which holds the Kernel. The top 3 pages of this CPU address space ($FD00-
* $FFFF) have two special properties. First, $FE00-$FFFF contains the I/O space.
* Second, $FD00-$FDFFF isn't affected by the DAT mappings but, instead,
* remains constant regardless of what block is mapped in at slot 7.
* When a user process is mapped in, and requests enough memory, it will end up
* with its own block assigned for CPU address space $E000-
* $FFFF but $FD00-$FFFF is unusable by the user process.
KrnBlk              SET       $7

                  ENDC

********************************************************************
* System control definitions
*
SYS0                equ       $FE00
SYS1                equ       $FE01
RST0                equ       $FE02
RST1                equ       $FE03

SYS_RESET           equ       %10000000
SYS_CAP_EN          equ       %00100000
SYS_BUZZ            equ       %00010000
SYS_L1              equ       %00001000
SYS_L0              equ       %00000100
SYS_SD_L            equ       %00000010
SYS_PWR_L           equ       %00000001

SYS_SD_WP           equ       %10000000
SYS_SD_CD           equ       %01000000
SYS_L1_RATE         equ       %11000000
SYS_L0_RATE         equ       %00110000
SYS_SID_ST          equ       %00001000
SYS_PSG_ST          equ       %00000100
SYS_L1_MN           equ       %00000010
SYS_L0_MN           equ       %00000001

********************************************************************
* F256 MMU definitions
*
MMU_MEM_CTRL        equ       $FFA0
MMU_IO_CTRL         equ       $FFA1
MMU_SLOT_BASE       equ       $FFA8
MMU_SLOT_0          equ       MMU_SLOT_BASE+0 $0000-$1FFF
MMU_SLOT_1          equ       MMU_SLOT_BASE+1 $2000-$3FFF
MMU_SLOT_2          equ       MMU_SLOT_BASE+2 $4000-$5FFF
MMU_SLOT_3          equ       MMU_SLOT_BASE+3 $6000-$7FFF
MMU_SLOT_4          equ       MMU_SLOT_BASE+4 $8000-$9FFF
MMU_SLOT_5          equ       MMU_SLOT_BASE+5 $A000-$BFFF
MMU_SLOT_6          equ       MMU_SLOT_BASE+6 $C000-$DFFF
MMU_SLOT_7          equ       MMU_SLOT_BASE+7 $E000-$FFFF

* MMU_MEM_CTRL bits
EDIT_LUT            equ       %00110000
EDIT_LUT_0          equ       %00000000
EDIT_LUT_1          equ       %00010000
EDIT_LUT_2          equ       %00100000
EDIT_LUT_3          equ       %00110000
ACT_LUT             equ       %00000000
ACT_LUT_0           equ       %00000000
ACT_LUT_1           equ       %00000001
ACT_LUT_2           equ       %00000010
ACT_LUT_3           equ       %00000011

LUT_BANK_0          equ       $0008
LUT_BANK_1          equ       $0009
LUT_BANK_2          equ       $000A
LUT_BANK_3          equ       $000B
LUT_BANK_4          equ       $000C
LUT_BANK_5          equ       $000D
LUT_BANK_6          equ       $000E
LUT_BANK_7          equ       $000F

* MMU_IO_CTRL bits
* $FFA1 has 2 bits:
*    FFA1[0] =
*        1 = Enable internal RAM for segment $FD00-$FDFF.
*        0 = Disable; RAM/FLASH is accessible.
*
*    FFA1[1] =
*        1 = Enable internal RAM for segment $FFF0-$FFFF
*        0 = Disable; RAM/FLASH is accessible.
* When enabled, the areas supersede RAM/flash, but will be disabled by RESET. When the system resets,
* those regions revert to RAM/flash. Also at RESET, the contents of RAM retain the old values until the
* system powers off.

********************************************************************
* F256 interrupt definitions
*
* Interrupt addresses
INT_PENDING_0       equ       $FE20
INT_POLARITY_0      equ       $FE24
INT_EDGE_0          equ       $FE28
INT_MASK_0          equ       $FE2C

INT_PENDING_1       equ       $FE21
INT_POLARITY_1      equ       $FE25
INT_EDGE_1          equ       $FE29
INT_MASK_1          equ       $FE2D

INT_PENDING_2       equ       $FE22     not used
INT_POLARITY_2      equ       $FE26     not used
INT_EDGE_2          equ       $FE2A     not used
INT_MASK_2          equ       $FE2E     not used

INT_PENDING_3       equ       $FE23     not used
INT_POLARITY_3      equ       $FE27     not used
INT_EDGE_3          equ       $FE2B     not used
INT_MASK_3          equ       $FE2F     not used

* Interrupt group 0 flags
INT_VKY_SOF         equ       %00000001 TinyVicky start of frame interrupt
INT_VKY_SOL         equ       %00000010 TinyVicky start of line interrupt
INT_PS2_KBD         equ       %00000100 PS/2 keyboard event
INT_PS2_MOUSE       equ       %00001000 PS/2 mouse event
INT_TIMER_0         equ       %00010000 TIMER0 has reached its target value
INT_TIMER_1         equ       %00010000 TIMER1 has reached its target value
INT_CARTRIDGE       equ       %10000000 Interrupt asserted by the cartridge

* Interrupt group 1 flags
INT_UART            equ       %00000001 UART is ready to receive or send data
INT_RTC             equ       %00010000 event from the real time clock chip
INT_VIA0            equ       %00100000 event from the 65C22 VIA chip
INT_VIA1            equ       %01000000 F256K Only: local keyboard
INT_SDC_INS         equ       %01000000 yser has inserted an SD card

* Interrupt group 2 flags
IEC_DATA_i          equ       %00000001 IEC data in
IEC_CLK_i           equ       %00000010 IEC clock in
IEC_ATN_i           equ       %00000100 IEC ATN in
IEC_SREQ_i          equ       %00001000 IEC SREQ in

********************************************************************
* F256 keyboard definitions
*
PS2_CTRL            equ       $FE50
PS2_OUT             equ       $FE51
KBD_IN              equ       $FE52
MS_IN               equ       $FE53
PS2_STAT            equ       $FE54

MCLR                equ       %00100000
KCLR                equ       %00010000
M_WR                equ       %00001000
K_WR                equ       %00000010

K_AK                equ       %10000000
K_NK                equ       %01000000
M_AK                equ       %00100000
M_NK                equ       %00010000
MEMP                equ       %00000010
KEMP                equ       %00000001

********************************************************************
* F256 mouse definitions
* $FEA0-$FEAF
* Mouse Mode is bit 1 of MS_MEM (Mouse Mode-Enable)
* 0=System handles x/y  1=harware interprets PS/2 packets
* Enable is bit 0.  1=show mouse pointer 0 = hide mouse pointer
MS_MEN		    equ	      $FEA0     mouse mode-enable
MS_XH		    equ	      $FEA2	mouse x low byte
MS_XL		    equ	      $FEA3	mouse x high byte	    
MS_YH		    equ	      $FEA4	mouse y low byte
MS_YL		    equ	      $FEA5	mouse y high byte
MS_PS2B0	    equ	      $FEA6	mouse PS/2 Byte 0
MS_PS2B1	    equ	      $FEA7	mouse PS/2 Byte 1
MS_PS2B2	    equ	      $FEA8	mouse PS/2 Byte 2
MS_SRATE	    equ	      $28	mouse sample rate $A,$14,$28,$3C,$50,$64,$C8


********************************************************************
* F256 timer definitions
*
* Timer addresses
T0_CTR              equ       $FE30     timer 0 counter (write)
T0_STAT             equ       $FE30     timer 0 status (read)
T0_VAL              equ       $FE31     timer 0 value (read/write)
T0_CMP_CTR          equ       $FE34     timer 0 compare counter (read/write)
T0_CMP              equ       $FE35     timer 0 compare value (read/write)
T1_CTR              equ       $FE38     timer 1 counter (write)
T1_STAT             equ       $FE38     timer 1 status (read)
T1_VAL              equ       $FE39     timer 1 value (read/write)
T1_CMP_CTR          equ       $FE3C     timer 1 compare counter (read/write)
T1_CMP              equ       $FE3D     timer 1 compare value (read/write)

********************************************************************
* F256 VIA (W65C22S) definitions
*
* VIA addresses
VIA0.Base           equ       $FEB0
VIA1.Base           equ       $FFB0
                    org       0
VIA_ORB_IRB         rmb       1         port b data
VIA_ORA_IRA         rmb       1         port a data
VIA_DDRB            rmb       1         port b data direction register
VIA_DDRA            rmb       1         port a data direction register
VIA_T1CL            rmb       1         timer 1 counter low
VIA_T1CH            rmb       1         timer 1 counter high
VIA_T1LL            rmb       1         timer 1 latch low
VIA_T1LH            rmb       1         timer 1 latch high
VIA_T2CL            rmb       1         timer 2 counter low
VIA_T2CH            rmb       1         timer 2 counter high
VIA_SR              rmb       1         serial data register
VIA_ACR             rmb       1         auxiliary control register
VIA_PCR             rmb       1         peripheral control register
VIA_IFR             rmb       1         interrupt flag register
VIA_IER             rmb       1         interrupt enable register
VIA_ORA_IRA_AUX     rmb       1         port a data (no handshake)

* ACR control register values
T1_CTRL             equ       %11000000
T2_CTRL             equ       %00100000
SR_CTRL             equ       %00011100
PBL_EN              equ       %00000010
PAL_EN              equ       %00000001

* PCR control register values
CB2_CTRL            equ       %11100000
CB1_CTRL            equ       %00010000
CA2_CTRL            equ       %00001110
CA1_CTRL            equ       %00000001

* IFR control register values
IRQF                equ       %10000000
T1F                 equ       %01000000
T2F                 equ       %00100000
CB1F                equ       %00010000
CB2F                equ       %00001000
SRF                 equ       %00000100
CA1F                equ       %00000010
CA2F                equ       %00000001

* IER control register values
IERSET              equ       %10000000
T1E                 equ       %01000000
T2E                 equ       %00100000
CB1E                equ       %00010000
CB2E                equ       %00001000
SRE                 equ       %00000100
CA1E                equ       %00000010
CA2E                equ       %00000001

********************************************************************
* F256 real-time clock definitions
*
RTC.Base            equ       0xFE40
                    org       0
RTC_SEC             rmb       1         seconds register
RTC_SEC_ALARM       rmb       1         seconds alarm register
RTC_MIN             rmb       1         minutes register
RTC_MIN_ALARM       rmb       1         minutes alarm register
RTC_HRS             rmb       1         hours register
RTC_HRS_ALARM       rmb       1         hours alarm register
RTC_DAY             rmb       1         day register
RTC_DAY_ALARM       rmb       1         day alarm register
RTC_DOW             rmb       1         day of week register
RTC_MONTH           rmb       1         month register
RTC_YEAR            rmb       1         year register
RTC_RATES           rmb       1         rates register
RTC_ENABLE          rmb       1         enables register
RTC_FLAGS           rmb       1         flags register
RTC_CTRL            rmb       1         control register
RTC_CENTURY         rmb       1         century register

RTC_24HR            equ       $02       12/24 hour flag (1 = 24 Hr, 0 = 12 Hr)
RTC_STOP            equ       $04       0 = STOP when power off, 1 = run from battery when power off
RTC_UTI             equ       $08       update transfer inhibit

********************************************************************
* F256 joystick port definitions
*

* Port A (Joystick Port 1)
JOYA_UP             equ       0x01
JOYA_DWN            equ       0x02
JOYA_LFT            equ       0x04
JOTA_RGT            equ       0x08
JOTA_BUT0           equ       0x10
JOYA_BUT1           equ       0x20
JOYA_BUT2           equ       0x40

* Port B (Joystick Port 0)
JOYB_UP             equ       0x01
JOYB_DWN            equ       0x02
JOYB_LFT            equ       0x04
JOTB_RGT            equ       0x08
JOTB_BUT0           equ       0x10
JOYB_BUT1           equ       0x20
JOYB_BUT2           equ       0x40

********************************************************************
* F256 UART definitions
*
UART.Base           equ       0xFE60
                    org       0
UART_TRHB           rmb       1         transmit/receive hold buffer
UART_DLL            equ       UART_TRHB divisor latch low byte
UART_DLH            rmb       1         divisor latch high byte
UART_IER            equ       UART_DLH  interrupt enable register
UART_FCR            rmb       1         FIFO control register
UART_IIR            equ       UART_FCR  interrupt identification register
UART_LCR            rmb       1         line control register
UART_MCR            rmb       1         modem control register
UART_LSR            rmb       1         line status register
UART_MSR            rmb       1         modem status register
UART_SR             rmb       1         scratch register

* FCR register definitions
FCR_RXT_5           equ       0x00
FCR_RXT_6           equ       0x40
FCR_RXT_7           equ       0x80
FCR_RXT_8           equ       0xC0
FCR_FIFO64          equ       0x20
FCR_TXR             equ       0x04
FCR_RXR             equ       0x02
FCR_FIFOE           equ       0x01

* Interrupt enable flags
UINT_LOW_POWER      equ       0x20      enable low power mode (16750)
UINT_SLEEP_MODE     equ       0x10      enable sleep mode (16750)
UINT_MODEM_STATUS   equ       0x08      enable modem status interrupt
UINT_LINE_STATUS    equ       0x04      enable receiver line status interrupt
UINT_THR_EMPTY      equ       0x02      enable transmit holding register empty interrupt
UINT_DATA_AVAIL     equ       0x01      enable receive data available interrupt

* Interrupt identification register codes
IIR_FIFO_ENABLED    equ       0x80      FIFO is enabled
IIR_FIFO_NONFUNC    equ       0x40      FIFO is not functioning
IIR_FIFO_64BYTE     equ       0x20      64 byte FIFO enabled (16750)
IIR_MODEM_STATUS    equ       0x00      modem status interrupt
IIR_THR_EMPTY       equ       0x02      transmit holding register empty interrupt
IIR_DATA_AVAIL      equ       0x04      data available interrupt
IIR_LINE_STATUS     equ       0x06      line status interrupt
IIR_TIMEOUT         equ       0x0C      time-out interrupt (16550 and later)
IIR_INTERRUPT_PENDING equ       0x01      interrupt pending flag

* Line control register codes
LCR_DLB             equ       0x80      divisor latch access bit
LCR_SBE             equ       0x60      set break enable

LCR_PARITY_NONE     equ       0x00      parity: none
LCR_PARITY_ODD      equ       0x08      parity: odd
LCR_PARITY_EVEN     equ       0x18      parity: even
LCR_PARITY_MARK     equ       0x28      parity: mark
LCR_PARITY_SPACE    equ       0x38      parity: space

LCR_STOPBIT_1       equ       0x00      one stop bit
LCR_STOPBIT_2       equ       0x04      1.5 or 2 stop bits

LCR_DATABITS_5      equ       0x00      data bits: 5
LCR_DATABITS_6      equ       0x01      data bits: 6
LCR_DATABITS_7      equ       0x02      data bits: 7
LCR_DATABITS_8      equ       0x03      data bits: 8

LSR_ERR_RECEIVE     equ       0x80      error in received fifo
LSR_XMIT_DONE       equ       0x40      all data has been transmitted
LSR_XMIT_EMPTY      equ       0x20      empty transmit holding register
LSR_BREAK_INT       equ       0x10      break interrupt
LSR_ERR_FRAME       equ       0x08      framing error
LSR_ERR_PARITY      equ       0x04      parity error
LSR_ERR_OVERRUN     equ       0x02      overrun error
LSR_DATA_AVAIL      equ       0x01      data is ready in the receive buffer

********************************************************************
* F256 CODEC definitions
*
CODEC.Base          equ       $FE70
                    org       0
CODECCmdLo          rmb       1
CODECCmdHi          rmb       1
CODECStat           rmb       1
CODECCtrl           equ       CODECStat

******************************************************************
* F256 text lookup definitions
*
TEXT_LUT_FG         equ       $FF00
TEXT_LUT_BG         equ       $FF40

********************************************************************
* F256 SD card interface definitions
*
SDC.Base            equ       $FE90
                    org       0
SDC_STAT            rmb       1
SDC_DATA            rmb       1

* SDC status bits
SPI_BUSY            equ       %10000000
SPI_CLK             equ       %00000010
CS_EN               equ       %00000001

********************************************************************
* F256 text screen definitions
*
TXT.Base            equ       $FFC0
VKY_LAYER_CTRL_0    equ	      $FFC2
VKY_LAYER_CTRL_1    equ       $FFC3
* The following are registers indicies based on TXT.Base
                    org       0
MASTER_CTRL_REG_L   rmb       1
MASTER_CTRL_REG_H   rmb       1
VKY_LAYER_CTRL_L    rmb       1
VKY_LAYER_CTRL_H    rmb       1
BORDER_CTRL_REG     rmb       1         bit[0] - enable (1 by default)  bit[4..6]: X scroll offset (will scroll left) (acceptable values: 0..7)
BORDER_COLOR_B      rmb       1
BORDER_COLOR_G      rmb       1
BORDER_COLOR_R      rmb       1
BORDER_X_SIZE       rmb       1         X values: 0 - 32 (default: 32)
BORDER_Y_SIZE       rmb       1         Y values: 0 - 32 (default: 32)
VKY_RESERVED_02     rmb       1
VKY_RESERVED_03     rmb       1
VKY_RESERVED_04     rmb       1
* Valid in graphics mode only
BACKGROUND_COLOR_B  rmb       1         when in graphic mode, if a pixel is "0" then the background pixel is chosen
BACKGROUND_COLOR_G  rmb       1
BACKGROUND_COLOR_R  rmb       1
* Cursor registers
VKY_TXT_CURSOR_CTRL_REG rmb       1         [0] Enable Text Mode
VKY_TXT_START_ADD_PTR rmb       1         this is an offset to change the starting address of the text mode Buffer (in X)
VKY_TXT_CURSOR_CHAR_REG rmb       1
VKY_TXT_CURSOR_COLR_REG rmb       1
VKY_TXT_CURSOR_X_REG_H rmb       1
VKY_TXT_CURSOR_X_REG_L rmb       1
VKY_TXT_CURSOR_Y_REG_H rmb       1
VKY_TXT_CURSOR_Y_REG_L rmb       1
; Line interrupt
VKY_LINE_IRQ_CTRL_REG rmb       1         [0] - enable line 0 - write only
VKY_LINE_CMP_VALUE_LO rmb       1         write only [7:0]
VKY_LINE_CMP_VALUE_HI rmb       1         write only [3:0]

VKY_PIXEL_X_POS_LO  equ       VKY_LINE_IRQ_CTRL_REG this is where on the video line is the pixel
VKY_PIXEL_X_POS_HI  equ       VKY_LINE_CMP_VALUE_LO or what pixel is being displayed when the register is read
VKY_LINE_Y_POS_LO   equ       VKY_LINE_CMP_VALUE_HI this is the line value of the raster
VKY_LINE_Y_POS_HI   rmb       1

* Text control bit definitions
Mstr_Ctrl_Text_Mode_En equ       $01       enable the text mode
Mstr_Ctrl_Text_Overlay equ       $02       enable the overlay of the text mode on top of graphic mode (the background color is ignored)
Mstr_Ctrl_Graph_Mode_En equ       $04       enable the graphic mode
Mstr_Ctrl_Bitmap_En equ       $08       enable the bitmap module in Vicky
Mstr_Ctrl_TileMap_En equ       $10       enable the tile module in Vicky
Mstr_Ctrl_Sprite_En equ       $20       enable the sprite module in Vicky
Mstr_Ctrl_GAMMA_En  equ       $40       this enables the gamma correction - the analog and DVI have different color values; the gamma is great to correct the difference
Mstr_Ctrl_Disable_Vid equ       $80       this will disable the scanning of the video hence giving 100% bandwidth to the CPU

* Cursor control bit definitions
Vky_Cursor_Enable   equ       $01
Vky_Cursor_Flash_Rate0 equ       $02
Vky_Cursor_Flash_Rate1 equ       $04
Vky_Cursor_Flash_Disable equ       $08

FON_SET             equ       %00100000
FON_OVLY            equ       %00010000
MON_SLP             equ       %00001000
DBL_Y               equ       %00000100
DBL_X               equ       %00000010
CLK_70              equ       %00000001

* Border control bit definitions
Border_Ctrl_Enable  equ       $01

; Bitmap
;BM0
TyVKY_BM0_CTRL_REG  equ       $F000
BM0_Ctrl            equ       $01       enable the BM0
BM0_LUT0            equ       $02       LUT0
BM0_LUT1            equ       $04       LUT1
TyVKY_BM0_START_ADDY_H equ       $F001
TyVKY_BM0_START_ADDY_M equ       $F002
TyVKY_BM0_START_ADDY_L equ       $F003
;BM1
TyVKY_BM1_CTRL_REG  equ       $F008
BM1_Ctrl            equ       $01       enable the BM0
BM1_LUT0            equ       $02       LUT0
BM1_LUT1            equ       $04       LUT1
TyVKY_BM1_START_ADDY_H equ       $F009
TyVKY_BM1_START_ADDY_M equ       $F00A
TyVKY_BM1_START_ADDY_L equ       $F00B
;BM2
TyVKY_BM2_CTRL_REG  equ       $F010
BM2_Ctrl            equ       $01       enable the BM0
BM2_LUT0            equ       $02       LUT0
BM2_LUT1            equ       $04       LUT1
BM2_LUT2            equ       $08       LUT2
TyVKY_BM2_START_ADDY_H equ       $F011
TyVKY_BM2_START_ADDY_M equ       $F012
TyVKY_BM2_START_ADDY_L equ       $F013

**  THESE ARE DUPLICATES, RECONCILE THIS LATER
********************************************************************
* vtio graphics constants
********************************************************************
* Constants used in SS.DScrn to set the display screen type

FX_GAM             equ       %01000000              Gamma Correction On
FX_SPR             equ       %00100000              Sprites On
FX_TIL             equ       %00010000              Tile Maps On
FX_BM              equ       %00001000              Bitmaps On
FX_GRF             equ       %00000100              Graphics Mode On
FX_OVR             equ       %00000010              Overlay Text on Graphics
FX_TXT             equ       %00000001              Text Mode On
FT_FSET            equ       %00100000              Font Set 1 On (0=Font Set 0)
FT_FOVR            equ       %00010000              FG and BG colors displayed when overlay text 0=transparent
FT_MON             equ       %00001000              Turn off monitor sync and sleep monitor
FT_DBX             equ       %00000100              Double-wide text mode characters
FT_DBY             equ       %00000010              Double-high text mode characters
FT_CLK70           equ       %00000001              70 Hz screen (640x400 txt,320x200 grf)
FX_OMIT            equ       %11111111              Setting for SS.DScrn don't change first byte in MCR
FT_OMIT            equ       %11111111              Setting for SS.DScrn don't change second byte in MCR

* FT_FOVR:  0=display only FG color, all others transparent
*           1=display FG & BG color, only BG color 0 is transparent
* CLK_70:   0=60 Hz screen (640x480 txt, 320x240 grf)
*           0=70 Hz screen (640x400 txt, 32
**  END OF DUPLICATE CONSTANTS

; Tile map
TyVKY_TL_CTRL0      equ       $F100
; Bit Field Definition for the Control Register
TILE_Enable         equ       $01
TILE_LUT0           equ       $02
TILE_LUT1           equ       $04
TILE_LUT2           equ       $08
TILE_SIZE           equ       $10       0 -> 16x16, 0 -> 8x8

;
;Tile map layer 0 registers
TL0_CONTROL_REG     equ       $F100     bit[0] - enable, bit[3:1] - LUT select
TL0_START_ADDY_L    equ       $F101     not used right now - starting address to where is the map
TL0_START_ADDY_M    equ       $F102
TL0_START_ADDY_H    equ       $F103
TL0_MAP_X_SIZE_L    equ       $F104     the size X of the map
TL0_MAP_X_SIZE_H    equ       $F105
TL0_MAP_Y_SIZE_L    equ       $F106     the size Y of the map
TL0_MAP_Y_SIZE_H    equ       $F107
TL0_MAP_X_POS_L     equ       $F108     the position X of the map
TL0_MAP_X_POS_H     equ       $F109
TL0_MAP_Y_POS_L     equ       $F10A     the position Y of the map
TL0_MAP_Y_POS_H     equ       $F10B
;Tile MAP Layer 1 Registers
TL1_CONTROL_REG     equ       $F10C     bit[0] - enable, bit[3:1] - LUT select
TL1_START_ADDY_L    equ       $F10D     not used right now - starting address to where is the map
TL1_START_ADDY_M    equ       $F10E
TL1_START_ADDY_H    equ       $F10F
TL1_MAP_X_SIZE_L    equ       $F110     the size X of the map
TL1_MAP_X_SIZE_H    equ       $F111
TL1_MAP_Y_SIZE_L    equ       $F112     the size Y of the map
TL1_MAP_Y_SIZE_H    equ       $F113
TL1_MAP_X_POS_L     equ       $F114     the position X of the map
TL1_MAP_X_POS_H     equ       $F115
TL1_MAP_Y_POS_L     equ       $F116     the position Y of the map
TL1_MAP_Y_POS_H     equ       $F117
;Tile MAP Layer 2 Registers
TL2_CONTROL_REG     equ       $F118     bit[0] - enable, bit[3:1] - LUT select,
TL2_START_ADDY_L    equ       $F119     not used right now - starting address to where is the map
TL2_START_ADDY_M    equ       $F11A
TL2_START_ADDY_H    equ       $F11B
TL2_MAP_X_SIZE_L    equ       $F11C     the size X of the map
TL2_MAP_X_SIZE_H    equ       $F11D
TL2_MAP_Y_SIZE_L    equ       $F11E     the size Y of the map
TL2_MAP_Y_SIZE_H    equ       $F11F
TL2_MAP_X_POS_L     equ       $F120     the position X of the map
TL2_MAP_X_POS_H     equ       $F121
TL2_MAP_Y_POS_L     equ       $F122     the position Y of the map
TL2_MAP_Y_POS_H     equ       $F123


TILE_MAP_ADDY0_L    equ       $F180
TILE_MAP_ADDY0_M    equ       $F181
TILE_MAP_ADDY0_H    equ       $F182
TILE_MAP_ADDY0_CFG  equ       $F183
TILE_MAP_ADDY1      equ       $F184
TILE_MAP_ADDY2      equ       $F188
TILE_MAP_ADDY3      equ       $F18C
TILE_MAP_ADDY4      equ       $F190
TILE_MAP_ADDY5      equ       $F194
TILE_MAP_ADDY6      equ       $F198
TILE_MAP_ADDY7      equ       $F19C


XYMATH_CTRL_REG     equ       $D300     reserved
XYMATH_ADDY_L       equ       $D301     w
XYMATH_ADDY_M       equ       $D302     w
XYMATH_ADDY_H       equ       $D303     w
XYMATH_ADDY_POSX_L  equ       $D304     r/w
XYMATH_ADDY_POSX_H  equ       $D305     r/w
XYMATH_ADDY_POSY_L  equ       $D306     r/w
XYMATH_ADDY_POSY_H  equ       $D307     r/w
XYMATH_BLOCK_OFF_L  equ       $D308     r only - low block offset
XYMATH_BLOCK_OFF_H  equ       $D309     r only - hi block offset
XYMATH_MMU_BLOCK    equ       $D30A     r only - which mmu block
XYMATH_ABS_ADDY_L   equ       $D30B     low absolute results
XYMATH_ABS_ADDY_M   equ       $D30C     mid absolute results
XYMATH_ABS_ADDY_H   equ       $D30D     hi absolute results

; Sprite block0
SPRITE_Ctrl_Enable  equ       $01
SPRITE_LUT0         equ       $02
SPRITE_LUT1         equ       $04
SPRITE_DEPTH0       equ       $08       00 = total front - 01 = in between l0 and l1, 10 = in between l1 and l2, 11 = total back
SPRITE_DEPTH1       equ       $10
SPRITE_SIZE0        equ       $20       00 = 32x32 - 01 = 24x24 - 10 = 16x16 - 11 = 8x8
SPRITE_SIZE1        equ       $40


SP0_Ctrl            equ       $F300
SP0_Addy_L          equ       $F301
SP0_Addy_M          equ       $F302
SP0_Addy_H          equ       $F303
SP0_X_L             equ       $F304
SP0_X_H             equ       $F305
SP0_Y_L             equ       $F306     in the Jr, only the l is used (200 & 240)
SP0_Y_H             equ       $F307     always keep @ zero '0' because in Vicky the value is still considered a 16bits value

SP1_Ctrl            equ       $F308
SP1_Addy_L          equ       $F309
SP1_Addy_M          equ       $F30A
SP1_Addy_H          equ       $F30B
SP1_X_L             equ       $F30C
SP1_X_H             equ       $F30D
SP1_Y_L             equ       $F30E     in the Jr, only the l is used (200 & 240)
SP1_Y_H             equ       $F30F     always keep @ zero '0' because in Vicky the value is still considered a 16bits value

SP2_Ctrl            equ       $F310
SP2_Addy_L          equ       $F311
SP2_Addy_M          equ       $F312
SP2_Addy_H          equ       $F313
SP2_X_L             equ       $F314
SP2_X_H             equ       $F315
SP2_Y_L             equ       $F316     in the Jr, only the l is used (200 & 240)
SP2_Y_H             equ       $F317     always keep @ zero '0' because in Vicky the value is still considered a 16bits value

SP3_Ctrl            equ       $F318
SP3_Addy_L          equ       $F319
SP3_Addy_M          equ       $F31A
SP3_Addy_H          equ       $F31B
SP3_X_L             equ       $F31C
SP3_X_H             equ       $F31D
SP3_Y_L             equ       $F31E     in the Jr, only the l is used (200 & 240)
SP3_Y_H             equ       $F31F     always keep @ zero '0' because in Vicky the value is still considered a 16bits value

SP4_Ctrl            equ       $F320
SP4_Addy_L          equ       $F321
SP4_Addy_M          equ       $F322
SP4_Addy_H          equ       $F323
SP4_X_L             equ       $F324
SP4_X_H             equ       $F325
SP4_Y_L             equ       $F326     in the Jr, only the l is used (200 & 240)
SP4_Y_H             equ       $F327     always keep @ zero '0' because in Vicky the value is still considered a 16bits value




; PAGE $C1
TyVKY_LUT0          equ       $E800     -$d000 - $d3ff
TyVKY_LUT1          equ       $EC00     -$d400 - $d7ff
TyVKY_LUT2          equ       $F000     -$d800 - $dbff
TyVKY_LUT3          equ       $F400     -$dc00 - $dfff


********************************************************************
* F256 sound definitions (MMU Page $C4)
*
SND.Base            equ       $0000
SIDL.Base           equ       SND.Base+$0000
SIDM.Base           equ       SND.Base+$0080
SIDR.Base           equ       SND.Base+$0100
PSGL.Base           equ       SND.Base+$0200
PSGM.Base           equ       SND.Base+$0208
PSGR.Base           equ       SND.Base+$0210

********************************************************************
* F256 Direct Memory Access (DMA) definitions
*
DMA.Base            equ       $FEE0

                    org       0
DMA_CTRL_REG        rmb       1
DMA_STATUS_REG      rmb       1         read only
DMA_DATA_2_WRITE    equ       DMA_STATUS_REG write only
DMA_RESERVED_0      rmb       1
DMA_RESERVED_1      rmb       1
* Source address.
DMA_SOURCE_ADDR_L   rmb       1
DMA_SOURCE_ADDR_M   rmb       1
DMA_SOURCE_ADDR_H   rmb       1
DMA_RESERVED_2      rmb       1
* Destination address.
DMA_DEST_ADDR_L     rmb       1
DMA_DEST_ADDR_M     rmb       1
DMA_DEST_ADDR_H     rmb       1
DMA_RESERVED_3      rmb       1
* Size in 1D mode.
DMA_SIZE_1D_L       rmb       1
DMA_SIZE_1D_M       rmb       1
DMA_SIZE_1D_H       rmb       1
DMA_RESERVED_4      rmb       1
* Size in 1D mode.
DMA_SIZE_X_L        equ       DMA_SIZE_1D_L
DMA_SIZE_X_M        equ       DMA_SIZE_1D_M
DMA_SIZE_Y_L        equ       DMA_SIZE_1D_H
DMA_SIZE_Y_H        equ       DMA_RESERVED_4
* Stride in 2D mode.
DMA_SRC_STRIDE_X_L  rmb       1
DMA_SRC_STRIDE_X_H  rmb       1
DMA_DST_STRIDE_Y_L  rmb       1
DMA_DST_STRIDE_Y_H  rmb       1
DMA_RESERVED_5      rmb       1
DMA_RESERVED_6      rmb       1
DMA_RESERVED_7      rmb       1
DMA_RESERVED_8      rmb       1

* DMA_CTRL_REG bit definitions
DMA_CTRL_Enable     equ       $01
DMA_CTRL_1D_2D      equ       $02
DMA_CTRL_Fill       equ       $04
DMA_CTRL_Int_En     equ       $08
DMA_CTRL_NotUsed0   equ       $10
DMA_CTRL_NotUsed1   equ       $20
DMA_CTRL_NotUsed2   equ       $40
DMA_CTRL_Start_Trf  equ       $80

* DMA_STATUS_REG bit definitions
DMA_STATUS_TRF_IP   equ       $80       transfer in progress

                  ENDC
