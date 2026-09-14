                  IFNE    WILDBITS.D-1
WILDBITS.D              set       1

********************************************************************
* WildbitsDefs - NitrOS-9 System Definitions for the Wildbits 6809
*
* This is a high level view of the memory map as setup by
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
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2023/02/07  Boisy G. Pitre
* Started.
*
*          2023/08/16  Boisy G. Pitre
* Modified to address new memory map that Stefany created.
*
*          2026/09/14  Roger Taylor
* Updated to Wildbits V8_RC16 memory map.
*
*          2026/09/23  Codex
* Added rc17_line_5 line-drawer registers and packed-pixel semantics.


********************************************************************
* Ticks per second.
*
TkPerSec            set       60

                    ifeq      Level-1

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
HW.Page             set       $FF                 device descriptor hardware page

                    else

HW.Page             set       $07                 device descriptor hardware page
Bt.Start            set       $EE00               start address of where KRN is in memory

*************************************************
*
* NitrOS-9 Level 2 Section
*
*************************************************

****************************************
* Dynamic Address Translator Definitions
*
DAT.BlCt            equ       8                   DAT blocks/address space
DAT.BlSz            equ       (256/DAT.BlCt)*256  DAT block size
DAT.ImSz            equ       DAT.BlCt*2          DAT image size
DAT.Addr            equ       -(DAT.BlSz/256)     DAT MSB address bits
DAT.Task            equ       $FFA0               task register address
DAT.TkCt            equ       32                  kernel task-table count, not hardware LUT count
DAT.Regs            equ       $FFA8               DAT block registers base address
DAT.Free            equ       $333E               free block number
DAT.BlMx            equ       $3F                 boot-time maximum; krnp2 extends the map
DAT.BMSz            equ       $40                 boot-time map size; not rc16 RAM capacity
DAT.WrPr            equ       0                   no write protect
DAT.WrEn            equ       0                   no write enable
SysTask             equ       0                   system task number
IOBlock             equ       $3F
ROMBlock            equ       $3F
IOAddr              equ       $7F
ROMCount            equ       1                   number of blocks of ROM (high RAM block)
RAMCount            equ       1                   initial blocks of RAM
MoveBlks            equ       DAT.BlCt-ROMCount-2 block numbers used for copies
BlockTyp            equ       1                   check only first bytes of RAM block
ByteType            equ       2                   check entire block of RAM
Limited             equ       1                   check only upper memory for ROM modules
UnLimitd            equ       2                   check all NotRAM for modules
* NOTE: this check assumes any NotRAM with a module will
*       always start with $87CD in first two bytes of block
RAMCheck            equ       BlockTyp            check only beg bytes of block
ROMCheck            equ       Limited             check only upper few blocks for ROM
LastRAM             equ       IOBlock             maximum RAM block number

HW.Page             set       $7                  device descriptor hardware page

* KrnBlk defines the block number of the 8K RAM block that is mapped to
* the top of CPU address space ($E000-$FFFF) for the system process, and
* which holds the Kernel. The top 3 pages of this CPU address space ($FD00-
* $FFFF) have two special properties. First, $FE00-$FFFF contains the I/O space.
* Second, $FD00-$FDFF isn't affected by the DAT mappings but, instead,
* remains constant regardless of what block is mapped in at slot 7.
* When a user process is mapped in, and requests enough memory, it will end up
* with its own block assigned for CPU address space $E000-
* $FFFF but $FD00-$FFFF is unusable by the user process.
KrnBlk              set       $7

                    endc

********************************************************************
* Custom SetStats
*
                    org       $C0
SS.FntLoadM         rmb       1
SS.FntLoadF         rmb       1
SS.FntChar          rmb       1
SS.SOLIRQ           rmb       1
SS.SOLMUTE          rmb       1

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
* MMU definitions
*
MMU_MEM_CTRL        equ       $FFA0

* MMU_IO_CTRL: b0 fixed $FD00 RAM; b1 fixed $FFF0 vector RAM.
* rc16: b2 FLASHDIS maps $40-$9F to SRAM; read b7 = support flag.
* Reset clears b0-b6. Preserve other bits when changing this register.
MMU_FD_RAM          equ       %00000001           enable fixed $FD00-$FDFF RAM
MMU_VEC_RAM         equ       %00000010           enable fixed $FFF0-$FFFF RAM
MMU_FLASHDIS        equ       %00000100           rc16: SRAM instead of flash/cartridge
MMU_HAS_FLASHDIS    equ       %10000000           read-only rc16 capability
MMU_ACT_MASK        equ       %00000011           active hardware LUT selection
MMU_EDIT_MASK       equ       %00110000           edit hardware LUT selection
* rc16 SRAM blocks: $00-$BF and $D0-$EF with FLASHDIS set.
* $C0-$CF and $F0-$FF remain outside the CPU RAM pool.
MMU_BLOCK_SIZE      equ       $2000               bytes per block
MMU_BLOCK_COUNT     equ       $0100               block-number space
MMU_LUT_COUNT       equ       4                   hardware task maps
MMU_RAM_BLOCKS      equ       224                 FLASHDIS RAM pool before allocations
MMU_IO_CTRL         equ       $FFA1
FLASHDIS            equ       %00000100 MMU_IO_CTRL b2: 1 = blocks $40-$9F are RAM (rc16+ cores; see the bits below)
FLASHDIS.OK         equ       %10000000 MMU_IO_CTRL b7: reads 1 on a core that implements FLASHDIS
MMU_SLOT_BASE       equ       $FFA8
MMU_SLOT_0          equ       MMU_SLOT_BASE+0     $0000-$1FFF
MMU_SLOT_1          equ       MMU_SLOT_BASE+1     $2000-$3FFF
MMU_SLOT_2          equ       MMU_SLOT_BASE+2     $4000-$5FFF
MMU_SLOT_3          equ       MMU_SLOT_BASE+3     $6000-$7FFF
MMU_SLOT_4          equ       MMU_SLOT_BASE+4     $8000-$9FFF
MMU_SLOT_5          equ       MMU_SLOT_BASE+5     $A000-$BFFF
MMU_SLOT_6          equ       MMU_SLOT_BASE+6     $C000-$DFFF
MMU_SLOT_7          equ       MMU_SLOT_BASE+7     $E000-$FFFF

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
* $FFA1 has 3 bits (plus one read-only flag):
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
*
*    FFA1[2] = FLASHDIS (cores rc16 and later)
*        1 = MMU blocks $40-$9F are RAM: 768K of the SRAM (chip bytes $08_0000-$13_FFFF) that no
*            block reached before. The kernel sets this once at boot (krnp2) when the core has it.
*        0 = $40-$7F is the flash and $80-$9F the expansion select, as always. RESET clears the bit,
*            so the machine always boots from flash and the FEU trampoline (which runs from flash and
*            stores $00/$02 here) is unaffected.
*        After boot NOBODY may store an absolute value to $FFA1: clearing bit 2 pulls 768K of live
*        RAM out from under the kernel. Read-modify-write (lda MMU_IO_CTRL / ora / sta) only.
*    FFA1[7] = FLASHDIS.OK, read only
*        Reads 1 on a core that implements FLASHDIS, 0 on older cores (they read back what was
*        stored, and nothing stores a 1 there). krnp2 tests it before setting bit 2.
* $FFA1 is readable: a read returns the register.

********************************************************************
* Interrupt definitions
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

INT_PENDING_2       equ       $FE22               IEC bus + module IRQ pins
INT_POLARITY_2      equ       $FE26
INT_EDGE_2          equ       $FE2A
INT_MASK_2          equ       $FE2E

INT_PENDING_3       equ       $FE23               FIFO events: WiFi / K2 keyboard / MIDI / WizNet
INT_POLARITY_3      equ       $FE27
INT_EDGE_3          equ       $FE2B
INT_MASK_3          equ       $FE2F

* Interrupt group 0 flags
INT_VKY_SOF         equ       %00000001           TinyVicky start of frame interrupt
INT_VKY_SOL         equ       %00000010           TinyVicky start of line interrupt
INT_PS2_KBD         equ       %00000100           PS/2 keyboard event
INT_PS2_MOUSE       equ       %00001000           PS/2 mouse event
INT_TIMER_0         equ       %00010000           TIMER0 has reached its target value
INT_TIMER_1         equ       %00100000           TIMER1 has reached its target value
INT_DMA             equ       %01000000           DMA completion; group 0 b6, gated by DMA_CTRL_Int_En
INT_CARTRIDGE       equ       %10000000           Interrupt asserted by the cartridge

* Interrupt group 1 flags
INT_UART            equ       %00000001           UART is ready to receive or send data
INT_RTC             equ       %00010000           event from the real time clock chip
INT_VIA0            equ       %00100000           VIA0 interrupt
INT_VIA1            equ       %01000000           K2 VIA1 mechanical-keyboard adapter
INT_SDC_INS         equ       %10000000           SD-card insertion event

* Interrupt group 2 flags
IEC_DATA_i          equ       %00000001           IEC data in
IEC_CLK_i           equ       %00000010           IEC clock in
IEC_ATN_i           equ       %00000100           IEC ATN in
IEC_SREQ_i          equ       %00001000           IEC SREQ in
INT_NET_PIN         equ       %00010000           network module IRQ pin
INT_WIFI_PIN        equ       %00100000           WiFi module IRQ pin
INT_HDMI_PIN        equ       %01000000           HDMI IRQ pin
* Group 2 bit 7 and group 3 bits 6-7 are not wired.

* Interrupt group 3 flags (per IRQ_Controller_Jr lirq0 bits 24-29)
INT_WIZFI_RX        equ       %00000001           WiFi Rx FIFO went non-empty (edge, INT_PENDING_3)
INT_MIDI_RX         equ       %00000010           MIDI Rx FIFO went non-empty
INT_OPT_KBD         equ       %00000100           K2 optical keyboard FIFO went non-empty (K2 only; Jr2 never wires it)
INT_WIZNET          equ       %00001000           WizNet FIFO event
INT_MIDI_VS_RX      equ       %00010000           MIDI synth (VS) Rx FIFO went non-empty
INT_WIZFI_TX        equ       %00100000           WiFi Tx FIFO drained to empty (edge, INT_PENDING_3)
INT_WIZFI           equ       INT_WIZFI_RX+INT_WIZFI_TX


********************************************************************
* Keyboard definitions
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
* Mouse definitions
* $FEA0-$FEAF
* Mouse Mode is bit 1 of MS_MEN (Mouse Mode-Enable)
* 0=System handles x/y  1=hardware interprets supplied PS/2 bytes
* Enable is bit 0.  1=show mouse pointer 0 = hide mouse pointer
MS_MEN              equ       $FEA0               mouse mode-enable
MS_ENABLE           equ       %00000001           show pointer
MS_PACKET_MODE      equ       %00000010           hardware interprets supplied PS/2 bytes
MS_XH               equ       $FEA2               mouse X bits 11:8
MS_XL               equ       $FEA3               mouse X bits 7:0
MS_YH               equ       $FEA4               mouse Y bits 11:8
MS_YL               equ       $FEA5               mouse Y bits 7:0
MS_PS2B0            equ       $FEA6               mouse PS/2 Byte 0
MS_PS2B1            equ       $FEA7               mouse PS/2 Byte 1
MS_PS2B2            equ       $FEA8               mouse PS/2 Byte 2
MS_SRATE            equ       $28                 mouse sample rate $A,$14,$28,$3C,$50,$64,$C8

********************************************************************
* K2 optical keyboard definitions
*
OKB.Base            equ       $FE10
                    org       0
OKB.Data            rmb       1                   keyboard data
OKB.Stat            rmb       1                   b7 mechanical; b0 FIFO empty (0 = data available)
OKB.CntLo           rmb       1                   FIFO byte count bits 7:0
OKB.CntHi           rmb       1                   FIFO byte count bits 11:8
* Hardware typematic (v8_rc8+ K2 cores; older cores ignore writes and read 0,
* so write-then-readback of OKB.TypDly detects core support)
OKB.TypDly          rmb       1                   initial repeat delay in frames (reset 30)
OKB.TypPer          rmb       1                   repeat period in frames (reset 5)
OKB.TypCtl          rmb       1                   bit 0 = 1 enables hardware key repeat (reset 0)

********************************************************************
* Timer definitions
*
* Timer addresses
T0_CTR              equ       $FE30               timer 0 counter (write)
T0_STAT             equ       $FE30               timer 0 status (read)
T0_VAL              equ       $FE31               timer 0 value (read/write)
T0_CMP_CTR          equ       $FE34               timer 0 compare counter (read/write)
T0_CMP              equ       $FE35               timer 0 compare value (read/write)
T1_CTR              equ       $FE38               timer 1 counter (write)
T1_STAT             equ       $FE38               timer 1 status (read)
T1_VAL              equ       $FE39               timer 1 value (read/write)
T1_CMP_CTR          equ       $FE3C               timer 1 compare counter (read/write)
T1_CMP              equ       $FE3D               timer 1 compare value (read/write)

********************************************************************
* VIA (FPGA via6522) definitions
*
* K2 via6522 adapters: VIA0 joystick PA=J1, PB=J0; PB7=PB_i[8].
* VIA1 mechanical keyboard: PA_io rows, PB_i[7:0] columns.
* OpticalKeyboardScanner shares the pins; its registers use OKB.Base.
* VIA_* offsets apply to either adapter; A/B are ports, not VIA numbers.
VIA0.Base           equ       $FEB0
VIA1.Base           equ       $FFB0
                    org       0
VIA_ORB_IRB         rmb       1                   port b data
VIA_ORA_IRA         rmb       1                   port a data
VIA_DDRB            rmb       1                   port b data direction register
VIA_DDRA            rmb       1                   port a data direction register
VIA_T1CL            rmb       1                   timer 1 counter low
VIA_T1CH            rmb       1                   timer 1 counter high
VIA_T1LL            rmb       1                   timer 1 latch low
VIA_T1LH            rmb       1                   timer 1 latch high
VIA_T2CL            rmb       1                   timer 2 counter low
VIA_T2CH            rmb       1                   timer 2 counter high
VIA_SR              rmb       1                   serial data register
VIA_ACR             rmb       1                   auxiliary control register
VIA_PCR             rmb       1                   peripheral control register
VIA_IFR             rmb       1                   interrupt flag register
VIA_IER             rmb       1                   interrupt enable register
VIA_ORA_IRA_AUX     rmb       1                   port a data (no handshake)

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
* Real-time clock definitions
*
RTC.Base            equ       $FE40
                    org       0
RTC_SEC             rmb       1                   seconds register
RTC_SEC_ALARM       rmb       1                   seconds alarm register
RTC_MIN             rmb       1                   minutes register
RTC_MIN_ALARM       rmb       1                   minutes alarm register
RTC_HRS             rmb       1                   hours register
RTC_HRS_ALARM       rmb       1                   hours alarm register
RTC_DAY             rmb       1                   day register
RTC_DAY_ALARM       rmb       1                   day alarm register
RTC_DOW             rmb       1                   day of week register
RTC_MONTH           rmb       1                   month register
RTC_YEAR            rmb       1                   year register
RTC_RATES           rmb       1                   rates register
RTC_ENABLE          rmb       1                   enables register
RTC_FLAGS           rmb       1                   flags register
RTC_CTRL            rmb       1                   control register
RTC_CENTURY         rmb       1                   century register

RTC_24HR            equ       $02                 12/24 hour flag (1 = 24 Hr, 0 = 12 Hr)
RTC_STOP            equ       $04                 0 = STOP when power off, 1 = run from battery when power off
RTC_UTI             equ       $08                 update transfer inhibit

********************************************************************
* Joystick port definitions
*

* Port A (Joystick Port 1)
JOYA_UP             equ       $01
JOYA_DWN            equ       $02
JOYA_LFT            equ       $04
JOTA_RGT            equ       $08
JOYA_RGT            equ       JOTA_RGT            correctly spelled alias
JOTA_BUT0           equ       $10
JOYA_BUT0           equ       JOTA_BUT0           correctly spelled alias
JOYA_BUT1           equ       $20                 legacy mask; not wired as a K2 joystick button
JOYA_BUT2           equ       $40                 legacy mask; not wired as a K2 joystick button

* Port B (Joystick Port 0)
JOYB_UP             equ       $01
JOYB_DWN            equ       $02
JOYB_LFT            equ       $04
JOTB_RGT            equ       $08
JOYB_RGT            equ       JOTB_RGT            correctly spelled alias
JOTB_BUT0           equ       $10
JOYB_BUT0           equ       JOTB_BUT0           correctly spelled alias
JOYB_BUT1           equ       $20                 legacy mask; not wired as a K2 joystick button
JOYB_BUT2           equ       $40                 legacy mask; not wired as a K2 joystick button

********************************************************************
* UART definition
*
UART.Base           equ       $FE60

********************************************************************
* WM8776 codec bridge definitions
CODEC.Base          equ       $FE70
                    org       0
CODECCmdLo          rmb       1
CODECCmdHi          rmb       1
CODECStat           rmb       1
CODECCtrl           equ       CODECStat


******************************************************************
* Bitmap definitions
*
GAMMA_BLK           equ       $C0

******************************************************************
* Text lookup definitions
*
TEXT_LUT_BLK        equ       $C0
TEXT_LUT_FG         equ       $1700
TEXT_LUT_BG         equ       $1740

********************************************************************
* Font definitions
*
FONT_BLK            equ       $C1
FONT_0_OFFSET       equ       $0000
FONT_1_OFFSET       equ       $0800
FONT_BANK_SIZE      equ       $0800               bytes per font bank
TEXT_RAM_BLK        equ       $C2                 text character page
COLOR_RAM_BLK       equ       $C3                 text attribute page
TEXT_RAM_SIZE       equ       $12C0               4800 bytes per text/attribute page

********************************************************************
* SD card interface definitions
*
SDC0.Base           equ       $FE90
SDC1.Base           equ       $FF00
                    org       0
SDC_STAT            rmb       1
SDC_DATA            rmb       1

* SDC status bits
SPI_BUSY            equ       %10000000
SPI_CLK             equ       %00000010
CS_EN               equ       %00000001

********************************************************************
* Text screen definitions
*
TXT.Base            equ       $FFC0
VKY_LAYER_CTRL_0    equ       $FFC2
VKY_LAYER_CTRL_1    equ       $FFC3
* The following are register offsets based on TXT.Base
                    org       0
MASTER_CTRL_REG_L   rmb       1
MASTER_CTRL_REG_H   rmb       1
VKY_LAYER_CTRL_L    rmb       1
VKY_LAYER_CTRL_H    rmb       1
BORDER_CTRL_REG     rmb       1                   bit[0] - enable (1 by default) bit[4..6]: X scroll offset (will scroll left) (acceptable values: 0..7)
BORDER_COLOR_B      rmb       1
BORDER_COLOR_G      rmb       1
BORDER_COLOR_R      rmb       1
BORDER_X_SIZE       rmb       1                   6-bit border width; reset 16
BORDER_Y_SIZE       rmb       1                   6-bit border height; reset 16
VKY_RESERVED_02     rmb       1
VKY_DRAWLINE_CTRL   equ       VKY_RESERVED_02     b0 drawing-line enable
VKY_DRAWLINE_REG    equ       $FFCA               fixed-address alias of TXT.Base+VKY_DRAWLINE_CTRL
VKY_DRAWLINE_EN     equ       $01                 permits queued line pixels to reach SRAM
VKY_GFX_MODE        rmb       1                   $FFCB (rc14+): b0 HIRES4 = every bitmap plane 640x240 at 4 bits/dot, b3:1 CLUT group
VKY_RESERVED_04     rmb       1
* HIRES4: high nibble is the left dot; group selects a 16-color slice.
* Global and per-plane HIRES4 enables are ORed; tiles/sprites stay 320-wide.
GFX_HIRES4          equ       %00000001           640x240, two 4-bit dots per byte, all bitmap planes
GFX_GROUP           equ       %00001110           global 16-color CLUT group, bits 3:1
VKY_GFX_MODE_REG    equ       $FFCB               fixed-address alias of TXT.Base+VKY_GFX_MODE
* Valid in graphics mode only
BACKGROUND_COLOR_B  rmb       1                   when in graphic mode, if a pixel is "0" then the background pixel is chosen
BACKGROUND_COLOR_G  rmb       1
BACKGROUND_COLOR_R  rmb       1
* Cursor registers
VKY_TXT_CURSOR_CTRL_REG rmb   1                   cursor control; Vky_Cursor_* bits
VKY_TXT_START_ADD_PTR rmb     1                   legacy name; reserved in rc16
VKY_TXT_CURSOR_CHAR_REG rmb   1
VKY_TXT_CURSOR_COLR_REG rmb   1
VKY_TXT_CURSOR_X_REG_H rmb    1
VKY_TXT_CURSOR_X_REG_L rmb    1
VKY_TXT_CURSOR_Y_REG_H rmb    1
VKY_TXT_CURSOR_Y_REG_L rmb    1
; Line interrupt
VKY_LINE_IRQ_CTRL_REG rmb     1                   [0] - enable line 0 - write only
VKY_LINE_CMP_VALUE_HI rmb     1                   write: compare bits 11:8
VKY_LINE_CMP_VALUE_LO rmb     1                   write: compare bits 7:0

VKY_PIXEL_X_POS_HI  equ       VKY_LINE_IRQ_CTRL_REG read: raster X bits 11:8
VKY_PIXEL_X_POS_LO  equ       VKY_LINE_CMP_VALUE_HI read: raster X bits 7:0
VKY_LINE_Y_POS_HI   equ       VKY_LINE_CMP_VALUE_LO read: raster Y bits 11:8
VKY_LINE_Y_POS_LO   rmb       1                   read: raster Y bits 7:0
VKY_VERSION_LO      equ       $1C                 read: core version low byte
VKY_VERSION_HI      equ       $1D                 read: core version high byte
VKY_SUBVER_LO       equ       $1E                 read: core subversion low byte
VKY_SUBVER_HI       equ       $1F                 read: core subversion high byte
* Cursor X/Y writes are big-endian; readback swaps each byte pair.

* Text control bit definitions
Mstr_Ctrl_Text_Mode_En equ    $01                 enable the text mode
Mstr_Ctrl_Text_Overlay equ    $02                 enable the overlay of the text mode on top of graphic mode (the background color is ignored)
Mstr_Ctrl_Graph_Mode_En equ   $04                 enable the graphic mode
Mstr_Ctrl_Bitmap_En equ       $08                 enable the bitmap module in Vicky
Mstr_Ctrl_TileMap_En equ      $10                 enable the tile module in Vicky
Mstr_Ctrl_Sprite_En equ       $20                 enable the sprite module in Vicky
Mstr_Ctrl_GAMMA_En  equ       $40                 this enables the gamma correction - the analog and DVI have different color values; the gamma is great to correct the difference
Mstr_Ctrl_Disable_Vid equ     $80                 this will disable the scanning of the video hence giving 100% bandwidth to the CPU

* Cursor control bit definitions
Vky_Cursor_Enable   equ       $01
Vky_Cursor_Flash_Rate0 equ    $02
Vky_Cursor_Flash_Rate1 equ    $04
Vky_Cursor_Flash_Disable equ  $08

FON_SET             equ       %00100000
MEMTEXT_EN          equ       %01000000           memory-text engine enable
MEMTEXT_BG          equ       %10000000           memory-text background enable
FON_OVLY            equ       %00010000
MON_SLP             equ       %00001000
DBL_Y               equ       %00000100
DBL_X               equ       %00000010
CLK_70              equ       %00000001

* Border control bit definitions
Border_Ctrl_Enable  equ       $01

BITMAP_BLK          equ       $C0
; Bitmap
;BM0
TyVKY_BM0_CTRL_REG  equ       $F000
BM0_Ctrl            equ       $01                 enable the BM0
BM0_LUT0            equ       $02                 LUT0
BM0_LUT1            equ       $04                 LUT1
BM0_HIRES4          equ       $10                 rc14+: this plane alone in 640x240 4-bit (OR'd with GFX_HIRES4)
BM0_GROUP           equ       $E0                 rc14+: this plane's CLUT slice (0-7) when it is HIRES4
TyVKY_BM0_START_ADDY_H equ    $F001
TyVKY_BM0_START_ADDY_M equ    $F002
TyVKY_BM0_START_ADDY_L equ    $F003
;BM1
TyVKY_BM1_CTRL_REG  equ       $F008
BM1_Ctrl            equ       $01                 enable bitmap plane 1
BM1_LUT0            equ       $02                 LUT0
BM1_LUT1            equ       $04                 LUT1
BM1_HIRES4          equ       BM0_HIRES4          plane HIRES4 enable
BM1_GROUP           equ       BM0_GROUP           plane CLUT group mask
TyVKY_BM1_START_ADDY_H equ    $F009
TyVKY_BM1_START_ADDY_M equ    $F00A
TyVKY_BM1_START_ADDY_L equ    $F00B
;BM2
TyVKY_BM2_CTRL_REG  equ       $F010
BM2_Ctrl            equ       $01                 enable bitmap plane 2
BM2_LUT0            equ       $02                 LUT0
BM2_LUT1            equ       $04                 LUT1
BM2_HIRES4          equ       BM0_HIRES4          plane HIRES4 enable
BM2_GROUP           equ       BM0_GROUP           plane CLUT group mask
BM2_LUT2            equ       $08                 LUT2
TyVKY_BM2_START_ADDY_H equ    $F011
TyVKY_BM2_START_ADDY_M equ    $F012
TyVKY_BM2_START_ADDY_L equ    $F013

********************************************************************
* Line drawer (shared K2/Jr2 RTL, rc17_line_5; K2 line_fast_1 candidate).
* Page $C0 offset $1080; addresses below assume page $C0 in slot 7.
* The eight registers mirror through offsets $1080-$10FF.
* X writes are big-endian 10-bit values; Y writes are single bytes.
* 320x240: one 8-bit color per pixel. HIRES4: X=0..639, Y=0..239,
* low color nibble only, even X in the high nibble; neighbor preserved.
* Both modes have a 320-byte row stride. HIRES4 is selected by the
* global GFX_HIRES4 OR the chosen bitmap's BM0/1/2_HIRES4 bit.
* Endpoints, base, color and mode latch at GO. Invalid endpoints do not
* start a line; both valid endpoints are included. No clipping.
* Set VKY_DRAWLINE_EN at $FFCA to drain pixels. Control b0 is retained
* for compatibility but does not gate the current linedraw state machine.
* Hold GO until DONE=1, then clear GO to rearm for another command.
* More lines may be queued while earlier pixels drain; a full FIFO stalls
* generation without dropping pixels. Wait for DONE=1 AND FIFO=0 before
* consuming the completed bitmap. DONE alone does not mean writes landed.
* K2 line_fast_1 doubles the FIFO to 8192 entries and widens its count to
* 14 bits. X-major HIRES4 lines may combine two same-byte pixels in one
* entry: the count measures queued writes, not necessarily pixel count.
* Jr2 line_5 retains 4096 entries and a zero-extended 13-bit count.
* Reset b4 clears the FIFO AND generator; clear it before starting.
TyVKY_LD_BASE       equ       $F080
TyVKY_LD_OFFSET     equ       $1080               offset within MMU page $C0
TyVKY_LD_CTRL       equ       TyVKY_LD_BASE+0     W control; R b7 DONE, b6:0 stored
TyVKY_LD_COLOR      equ       TyVKY_LD_BASE+1     R/W ink byte; HIRES4 uses b3:0
TyVKY_LD_X0_H       equ       TyVKY_LD_BASE+2     W X0 bits 9:8; R FIFO count high
TyVKY_LD_X0_L       equ       TyVKY_LD_BASE+3     W X0 bits 7:0; R FIFO count low
TyVKY_LD_X1_H       equ       TyVKY_LD_BASE+4     W X1 bits 9:8; R X1 LOW byte
TyVKY_LD_X1_L       equ       TyVKY_LD_BASE+5     W X1 bits 7:0; R X1 HIGH byte
TyVKY_LD_Y0         equ       TyVKY_LD_BASE+6     W Y0; R Y1
TyVKY_LD_Y1         equ       TyVKY_LD_BASE+7     W Y1; R Y0
TyVKY_LD_COUNT_H    equ       TyVKY_LD_BASE+2     R FIFO count bits 13:8 (b13 K2 line_fast_1)
TyVKY_LD_COUNT_L    equ       TyVKY_LD_BASE+3     R FIFO count bits 7:0
TyVKY_LD_ENABLE     equ       $01                 legacy bit; use $FFCA b0 to enable writes
TyVKY_LD_GO         equ       $02                 start; clear to rearm after completion
TyVKY_LD_BM_MASK    equ       $0C                 destination bitmap selection
TyVKY_LD_BM0        equ       $00
TyVKY_LD_BM1        equ       $04
TyVKY_LD_BM2        equ       $08                 selection $0C uses fallback base $001000
TyVKY_LD_RESET      equ       $10                 FIFO/generator reset, active high
TyVKY_LD_DONE       equ       $80                 read-only generator done, NOT busy
TyVKY_LD_XMAX8      equ       319
TyVKY_LD_XMAX4      equ       639
TyVKY_LD_YMAX       equ       239
TyVKY_LD_STRIDE     equ       320

* Compatibility names for vtio screen flags; retained for callers.
********************************************************************
* vtio graphics constants
********************************************************************
* Constants used in SS.DScrn to set the display screen type

FX_GAM              equ       %01000000           Gamma Correction On
FX_SPR              equ       %00100000           Sprites On
FX_TIL              equ       %00010000           Tile Maps On
FX_BM               equ       %00001000           Bitmaps On
FX_GRF              equ       %00000100           Graphics Mode On
FX_OVR              equ       %00000010           Overlay Text on Graphics
FX_TXT              equ       %00000001           Text Mode On
FT_FSET             equ       %00100000           Font Set 1 On (0=Font Set 0)
FT_FOVR             equ       %00010000           FG and BG colors displayed when overlay text 0=transparent
FT_MON              equ       %00001000           Turn off monitor sync and sleep monitor
FT_DBX              equ       DBL_X               double-width text
FT_DBY              equ       DBL_Y               double-height text
FT_CLK70            equ       %00000001           70 Hz screen (640x400 txt,320x200 grf)
FX_OMIT             equ       %11111111           Setting for SS.DScrn don't change first byte in MCR
FT_OMIT             equ       %11111111           Setting for SS.DScrn don't change second byte in MCR

* FT_FOVR:  0=display only FG color, all others transparent
*           1=display FG & BG color, only BG color 0 is transparent
* CLK_70:   0=60 Hz screen (640x480 txt, 320x240 grf)
*           1=70 Hz screen (640x400 text, 320x200 graphics)
* End of vtio screen flags.

* Tile registers: page $C0 in slot 7; big-endian writes, reads $33.
TyVKY_TL_CTRL0      equ       $F100
; Bit Field Definition for the Control Register
TILE_Enable         equ       $01
TILE_LUT0           equ       $02
TILE_LUT1           equ       $04
TILE_LUT2           equ       $08
TILE_SIZE           equ       $10                 0 = 16x16; 1 = 8x8 tiles

;
;Tile map layer 0 registers
TL0_CONTROL_REG     equ       $F100               bit[0] - enable, bit[3:1] - LUT select
TL0_START_ADDY_H    equ       $F101               physical map address 23:16
TL0_START_ADDY_M    equ       $F102               physical map address 15:8
TL0_START_ADDY_L    equ       $F103               physical map address 7:0
TL0_MAP_X_SIZE_H    equ       $F104               high byte
TL0_MAP_X_SIZE_L    equ       $F105               low byte
TL0_MAP_Y_SIZE_H    equ       $F106               high byte
TL0_MAP_Y_SIZE_L    equ       $F107               low byte
TL0_MAP_X_POS_H     equ       $F108               high byte
TL0_MAP_X_POS_L     equ       $F109               low byte
TL0_MAP_Y_POS_H     equ       $F10A               high byte
TL0_MAP_Y_POS_L     equ       $F10B               low byte
;Tile MAP Layer 1 Registers
TL1_CONTROL_REG     equ       $F10C               bit[0] - enable, bit[3:1] - LUT select
TL1_START_ADDY_H    equ       $F10D               physical map address 23:16
TL1_START_ADDY_M    equ       $F10E               physical map address 15:8
TL1_START_ADDY_L    equ       $F10F               physical map address 7:0
TL1_MAP_X_SIZE_H    equ       $F110               high byte
TL1_MAP_X_SIZE_L    equ       $F111               low byte
TL1_MAP_Y_SIZE_H    equ       $F112               high byte
TL1_MAP_Y_SIZE_L    equ       $F113               low byte
TL1_MAP_X_POS_H     equ       $F114               high byte
TL1_MAP_X_POS_L     equ       $F115               low byte
TL1_MAP_Y_POS_H     equ       $F116               high byte
TL1_MAP_Y_POS_L     equ       $F117               low byte
;Tile MAP Layer 2 Registers
TL2_CONTROL_REG     equ       $F118               bit[0] - enable, bit[3:1] - LUT select,
TL2_START_ADDY_H    equ       $F119               physical map address 23:16
TL2_START_ADDY_M    equ       $F11A               physical map address 15:8
TL2_START_ADDY_L    equ       $F11B               physical map address 7:0
TL2_MAP_X_SIZE_H    equ       $F11C               high byte
TL2_MAP_X_SIZE_L    equ       $F11D               low byte
TL2_MAP_Y_SIZE_H    equ       $F11E               high byte
TL2_MAP_Y_SIZE_L    equ       $F11F               low byte
TL2_MAP_X_POS_H     equ       $F120               high byte
TL2_MAP_X_POS_L     equ       $F121               low byte
TL2_MAP_Y_POS_H     equ       $F122               high byte
TL2_MAP_Y_POS_L     equ       $F123               low byte
* Window position: bits 13:4 = tile index; low nibble = pixel scroll.


TILE_MAP_ADDY0_CFG  equ       $F180               tileset configuration, low nibble
TILE_MAP_ADDY0_H    equ       $F181               tileset physical address byte
TILE_MAP_ADDY0_M    equ       $F182               tileset physical address byte
TILE_MAP_ADDY0_L    equ       $F183               tileset physical address byte
TILE_MAP_ADDY1      equ       $F184
TILE_MAP_ADDY2      equ       $F188
TILE_MAP_ADDY3      equ       $F18C
TILE_MAP_ADDY4      equ       $F190
TILE_MAP_ADDY5      equ       $F194
TILE_MAP_ADDY6      equ       $F198
TILE_MAP_ADDY7      equ       $F19C


* Integer math: fixed $FEE0-$FEFF, big-endian operands/results.
* Writes ignore A4: do not write result addresses $FEF0-$FEFF.
MATH_MUL_A          equ       $FEE0               w/r unsigned multiply, operand A (16 bit, hi byte first)
MATH_MUL_B          equ       $FEE2               w/r unsigned multiply, operand B (16 bit)
MATH_DIV_SOR        equ       $FEE4               w/r unsigned divide, divisor (16 bit)
MATH_DIV_END        equ       $FEE6               w/r unsigned divide, dividend (16 bit)
MATH_ADD_A          equ       $FEE8               w/r 32-bit adder, operand A (4 bytes, hi first)
MATH_ADD_B          equ       $FEEC               w/r 32-bit adder, operand B (4 bytes)
MATH_MUL_P          equ       $FEF0               r product, 32 bit; MATH_MUL_P+2 is the low 16 bits
MATH_DIV_QUOT       equ       $FEF4               r quotient (16 bit)
MATH_DIV_REM        equ       $FEF6               read: 16-bit remainder; corrected in rc14
MATH_ADD_RES        equ       $FEF8               r sum (32 bit)
* Remainder byte wiring is correct in rc16.
* Floating point unit - FP_Math_Module.v, $FFE0-$FFEF in the FIXED I/O page, both boards.
* IEEE-754 single precision, big endian, pipelined. Operands are written to the same sixteen
* bytes the results are read from, so an operand can never be read back.
* How to drive it, the latencies and the two dead status bits: Wildbits page, Floating-point unit.
FPMATH_CTRL0        equ       $FFE0               w b0/b1 take input 0/1 from the fixed-point converter instead of
*                                          the raw value written; b3 add(0)/subtract(1); b5:4 pick the
*                                          adder's first input, b7:6 its second (00 input0, 01 input1,
*                                          10 multiplier output, 11 divider output)
FPMATH_CTRL1        equ       $FFE1               w b1:0 what the output mux and the float-to-fixed converter see:
*                                          00 multiply, 01 divide, 10 add/sub, 11 the constant 1.0
FPMATH_CTRL2        equ       $FFE2               w input tvalid strobes: b0 converter A, b1 raw input 0,
*                                          b2 converter B, b3 raw input 1
FPMATH_CTRL3        equ       $FFE3               w spare control byte
FPMATH_MUL_ST       equ       $FFE4               r multiply status: b4 tvalid, b3 zero, b2 underflow, b1 overflow,
*                                          b0 NaN
FPMATH_DIV_ST       equ       $FFE5               r divide status: b5 tvalid, b4 divide-by-zero, b3 zero,
*                                          b2 underflow, b1 overflow, b0 NaN
FPMATH_ADD_ST       equ       $FFE6               r add/subtract status: b4 tvalid, b3 zero, b2 underflow,
*                                          b1 overflow, b0 NaN
FPMATH_CNV_ST       equ       $FFE7               r float-to-fixed status: b3 tvalid, b2 underflow, b1 overflow,
*                                          b0 NaN
FPMATH_IN0          equ       $FFE8               w operand 0, 4 bytes, hi first
FPMATH_OUT          equ       $FFE8               r the selected result (see FPMATH_CTRL1), 4 bytes
FPMATH_IN1          equ       $FFEC               w operand 1, 4 bytes
FPMATH_FIXED        equ       $FFEC               r that result converted to 20.12 fixed point, 4 bytes

; Sprite block0
SPRITE_Ctrl_Enable  equ       $01
SPRITE_LUT0         equ       $02
SPRITE_LUT1         equ       $04
SPRITE_DEPTH0       equ       $08                 00 = total front - 01 = in between l0 and l1, 10 = in between l1 and l2, 11 = total back
SPRITE_DEPTH1       equ       $10
SPRITE_SIZE0        equ       $20                 00 = 32x32 - 01 = 24x24 - 10 = 16x16 - 11 = 8x8
SPRITE_SIZE1        equ       $40


* Sprite attribute records: 128 records of 8 bytes in VICKY page $C0 at offsets $1300-$16FF
* (record n at $1300+8*n), BIG-endian fields. Full layout and a worked recipe: Wildbits page,
* sprite chapter. The SPn_* equates further down assume page $C0 is mapped in MMU slot 7
* ($E000 window, the vtio/system-state convention), which puts record 0 at $F300.
* Generic per-record offsets for indexed access:
SPR_CTRL            equ       0                   control byte (SPRITE_* bits above)
SPR_ADDY_H          equ       1                   pixel data physical address 23:16
SPR_ADDY_M          equ       2                   pixel data physical address 15:8
SPR_ADDY_L          equ       3                   pixel data physical address 7:0
SPR_X_H             equ       4                   X 15:8 (screen left = 32)
SPR_X_L             equ       5                   X 7:0
SPR_Y_H             equ       6                   Y 15:8 (screen top = 32)
SPR_Y_L             equ       7                   Y 7:0
SPR_REC_SIZE        equ       8                   bytes per sprite record

* Where the sprite machinery lives (map these VICKY pages via an MMU slot):
SPRITE_BLK          equ       $C0                 VICKY page holding the 128 sprite records
SPRITE_REC_OFF      equ       $1300               page offset of record 0 (records at +n*SPR_REC_SIZE)
GRPH_LUT0_OFF       equ       $1000               graphics LUT0 offset within FONT_BLK ($C1); LUTn at +$400*n, 256 entries x B,G,R,A
GRPH_LUT1_OFF       equ       $1400               graphics LUT1 page offset
GRPH_LUT2_OFF       equ       $1800               graphics LUT2 page offset
GRPH_LUT3_OFF       equ       $1C00               graphics LUT3 page offset
GRPH_LUT_SIZE       equ       $0400               256 BGRA entries

SP0_Ctrl            equ       $F300
SP0_Addy_H          equ       $F301               pixel addr 23:16 (BIG-endian)
SP0_Addy_M          equ       $F302               pixel addr 15:8
SP0_Addy_L          equ       $F303               pixel addr 7:0
SP0_X_H             equ       $F304               X 15:8 - STD here writes X in one op
SP0_X_L             equ       $F305               X 7:0
SP0_Y_H             equ       $F306               Y 15:8 - STD here writes Y in one op
SP0_Y_L             equ       $F307               Y 7:0

SP1_Ctrl            equ       $F308
SP1_Addy_H          equ       $F309               pixel addr 23:16 (BIG-endian)
SP1_Addy_M          equ       $F30A               pixel addr 15:8
SP1_Addy_L          equ       $F30B               pixel addr 7:0
SP1_X_H             equ       $F30C               X 15:8 - STD here writes X in one op
SP1_X_L             equ       $F30D               X 7:0
SP1_Y_H             equ       $F30E               Y 15:8 - STD here writes Y in one op
SP1_Y_L             equ       $F30F               Y 7:0

SP2_Ctrl            equ       $F310
SP2_Addy_H          equ       $F311               pixel addr 23:16 (BIG-endian)
SP2_Addy_M          equ       $F312               pixel addr 15:8
SP2_Addy_L          equ       $F313               pixel addr 7:0
SP2_X_H             equ       $F314               X 15:8 - STD here writes X in one op
SP2_X_L             equ       $F315               X 7:0
SP2_Y_H             equ       $F316               Y 15:8 - STD here writes Y in one op
SP2_Y_L             equ       $F317               Y 7:0

SP3_Ctrl            equ       $F318
SP3_Addy_H          equ       $F319               pixel addr 23:16 (BIG-endian)
SP3_Addy_M          equ       $F31A               pixel addr 15:8
SP3_Addy_L          equ       $F31B               pixel addr 7:0
SP3_X_H             equ       $F31C               X 15:8 - STD here writes X in one op
SP3_X_L             equ       $F31D               X 7:0
SP3_Y_H             equ       $F31E               Y 15:8 - STD here writes Y in one op
SP3_Y_L             equ       $F31F               Y 7:0

SP4_Ctrl            equ       $F320
SP4_Addy_H          equ       $F321               pixel addr 23:16 (BIG-endian)
SP4_Addy_M          equ       $F322               pixel addr 15:8
SP4_Addy_L          equ       $F323               pixel addr 7:0
SP4_X_H             equ       $F324               X 15:8 - STD here writes X in one op
SP4_X_L             equ       $F325               X 7:0
SP4_Y_H             equ       $F326               Y 15:8 - STD here writes Y in one op
SP4_Y_L             equ       $F327               Y 7:0




; PAGE $C1
TyVKY_LUT0          equ       $F000               graphics LUT0, page $C1 in slot 7
TyVKY_LUT1          equ       $F400               graphics LUT1, page $C1 in slot 7
TyVKY_LUT2          equ       $F800               graphics LUT2, page $C1 in slot 7
TyVKY_LUT3          equ       $FC00               graphics LUT3, page $C1 in slot 7


********************************************************************
* Sound definitions (MMU Page $C4)
*
SND.Base            equ       $0000
SIDL.Base           equ       SND.Base+$0000
SIDM.Base           equ       SND.Base+$0080
SIDR.Base           equ       SND.Base+$0100
OPL3.Base           equ       SND.Base+$0180      both boards; writes only, no status/IRQ
OPL3_ADDR0          equ       0                   bank 0 register address
OPL3_DATA0          equ       1                   bank 0 register data
OPL3_ADDR1          equ       2                   bank 1 register address
OPL3_DATA1          equ       3                   bank 1 register data
PSGL.Base           equ       SND.Base+$0200
PSGM.Base           equ       SND.Base+$0208
PSGR.Base           equ       SND.Base+$0210

********************************************************************
* Direct Memory Access (DMA) definitions
*
DMA.Base            equ       $FEC0

* Map corrected 2026-09-09 from the core RTL. THESE ARE THE WRITE ADDRESSES: reads come back
* permuted, so a read-back-and-verify driver needs the permutation. Big endian.
* rc17_dmahandshake fixes CPU HALT/bus handoff; no new control bit.
* Completion IRQ is INT_DMA (INT_PENDING_0 b6) on both K2 and Jr2,
* enabled by DMA_CTRL_Int_En; INT_MASK_0 b6 must also be unmasked.
* How to drive it and the read permutation: Wildbits page, DMA engine.
                    org       0
DMA_CTRL_REG        rmb       1                   fec0 w/r b0 ENABLE, b1 1D(0)/2D(1), b2 fill, b3 IRQ enable,
*                                            b5:4 byte-lane mask - EITHER BIT SET DISABLES THAT LANE and
*                                            the transfer runs to completion writing NOTHING,
*                                            b6 double speed + 16-bit fill, b7 START
DMA_STATUS_REG      rmb       1                   fec1 r b7 transfer in progress; b6:0 hardwired 0, so an idle
*                                            block reads exactly $00
DMA_FILL_BYTE       equ       DMA_STATUS_REG      fec1 w the 8-bit fill value (ctrl b6 clear)
DMA_DATA_2_WRITE    equ       DMA_STATUS_REG      the older name for DMA_FILL_BYTE
DMA_FILL_WORD_H     rmb       1                   fec2 w 16-bit fill, odd/high byte (ctrl b6 SET)
DMA_FILL_WORD_L     rmb       1                   fec3 w 16-bit fill, even/low byte
DMA_UNUSED_0        rmb       1                   fec4 nothing in the engine reads this byte
* Source address, 24 bit.
DMA_SOURCE_ADDR_H   rmb       1                   fec5 w source [23:16]
DMA_SOURCE_ADDR_M   rmb       1                   fec6 w source [15:8]
DMA_SOURCE_ADDR_L   rmb       1                   fec7 w source [7:0]
DMA_UNUSED_1        rmb       1                   fec8 nothing in the engine reads this byte
* Destination address, 24 bit.
DMA_DEST_ADDR_H     rmb       1                   fec9 w destination [23:16]
DMA_DEST_ADDR_M     rmb       1                   feca w destination [15:8]
DMA_DEST_ADDR_L     rmb       1                   fecb w destination [7:0]
* Sizes. In 2D mode X is the row length and Y the row count.
DMA_SIZE_X_H        rmb       1                   fecc w X size [15:8]
DMA_SIZE_X_L        rmb       1                   fecd w X size [7:0]
DMA_SIZE_Y_H        rmb       1                   fece w Y size [15:8] - 2D ONLY, dropped in 1D
DMA_SIZE_Y_L        rmb       1                   fecf w Y size [7:0]
* Strides, 2D only.
DMA_SRC_STRIDE_X_H  rmb       1                   fed0 w source stride [15:8]
DMA_SRC_STRIDE_X_L  rmb       1                   fed1 w source stride [7:0]
DMA_DST_STRIDE_Y_H  rmb       1                   fed2 w destination stride [15:8]
DMA_DST_STRIDE_Y_L  rmb       1                   fed3 w destination stride [7:0]
* fed4 is the LOGIC OP register on cores from rc17_dmaplus_fastervideo (2026-09-22); before that it was a
* dead byte. Read b7 first: 1 = the ops exist, 0 = an older core (the byte then just stores what was written).
DMA_OP_REG          rmb       1                   fed4 w b2:0 op, b3 NOT; r b7 = 1 ops implemented
DMA_DEAD_0          equ       DMA_OP_REG          the old name
* fed5-fed7 read and write as ordinary bytes but drive nothing at all.
DMA_DEAD_1          rmb       1                   fed5
DMA_DEAD_2          rmb       1                   fed6
DMA_DEAD_3          rmb       1                   fed7
* fed8-fedf are decoded but the register array is only 24 entries: writes vanish and reads return $FF.
*
* THE 1D LENGTH IS NOT A CONTIGUOUS FIELD. Controller:210 builds it as
*     Count1D = {VDMA_Y_Size[7:0], VDMA_X_Size}
* so its three bytes are scattered, and DMA_SIZE_Y_H is not part of it. Use these names in 1D mode:
DMA_SIZE_1D_H       equ       DMA_SIZE_Y_L        fecf 1D count [23:16]
DMA_SIZE_1D_M       equ       DMA_SIZE_X_H        fecc 1D count [15:8]
DMA_SIZE_1D_L       equ       DMA_SIZE_X_L        fecd 1D count [7:0]
* DMA_SIZE_Y_H (fece) must still be written, because it is a live 2D register that a previous transfer
* may have left dirty - but its value is ignored while ctrl b1 is clear.

* DMA_CTRL_REG bit definitions
DMA_CTRL_Enable     equ       $01
DMA_CTRL_1D_2D      equ       $02
DMA_CTRL_Fill       equ       $04
DMA_CTRL_Int_En     equ       $08
DMA_CTRL_MaskLSB    equ       $10                 NOT unused - masks the low byte lane (writes nothing)
DMA_CTRL_MaskMSB    equ       $20                 NOT unused - masks the high byte lane
DMA_CTRL_Dbl_Speed  equ       $40                 NOT unused - double speed, and fill takes the 16-bit word
DMA_CTRL_NotUsed0   equ       DMA_CTRL_MaskLSB    old names, kept so existing code still assembles
DMA_CTRL_NotUsed1   equ       DMA_CTRL_MaskMSB
DMA_CTRL_NotUsed2   equ       DMA_CTRL_Dbl_Speed
DMA_CTRL_Start_Trf  equ       $80

* DMA_STATUS_REG bit definitions
DMA_STATUS_TRF_IP   equ       $80                 transfer in progress

* DMA_OP_REG bit definitions (rc17_dmaplus_fastervideo). S = the source byte (a copy) or the fill byte (a fill),
* D = the destination byte before the write. 0 = the plain copy/fill of every earlier core. An op runs
* three bus slots a byte instead of two (S read, D read, write). The lane mask (ctrl b5:4) applies on top.
DMA_OP_COPY         equ       $00                 D = S
DMA_OP_OR           equ       $01                 D = S | D
DMA_OP_AND          equ       $02                 D = S & D
DMA_OP_XOR          equ       $03                 D = S ^ D
DMA_OP_MASK         equ       $04                 per nibble: a source nibble of 0 keeps D's (color 0 = paper)
DMA_OP_NOT          equ       $08                 invert the result (with OR/AND/XOR: NOR/NAND/XNOR)
DMA_OP_Implemented  equ       $80                 read-only: 1 = this core has the ops


* SPLASH FLASH SPI controller
* Reads the serial flash that holds the splash image.  Shares the WiFi
* module's SPI bus pins (SCLK/MISO/MOSI) but has its own chip select, and is
* clocked from 200MHz because the part will take 133MHz.  Present on both
* machines.  Nothing in NitrOS-9 uses it today.
*
* Usage: write the flash command, the 24-bit source address and the transfer
* size, then set bit 0 of the control register to start.  Poll the control
* register while it runs and read bytes out of the data port.
* Control register, on READ:
* Bit[7] = Busy  ( 1 = transfer in progress )
* Bit[6] = Read FIFO Empty ( 1 = Empty, 0 = Data Available )
* Bits[5:0] = the low 6 bits of the control register as written
* Control register, on WRITE:
* Bit[0] = 1 starts the transfer (the engine runs while this bit is set)
* CAUTION: offsets 2 and 3 do NOT read back what was written.  Written they
* are the transfer size, HIGH byte first; read they are the read-FIFO fill
* count, LOW byte first, and only the low 4 bits of the high byte are valid.
SplashSPI.Base      equ       $FF10
SplashSPI.Busy      equ       %10000000           read only: transfer in progress
SplashSPI.RxEmpty   equ       %01000000           read only: read FIFO empty
SplashSPI.Start     equ       %00000001           write: start the transfer
                    org       $0
SPIF_CTRL           rmb       1                   control (write) / status (read), see above
SPIF_CMD            rmb       1                   flash command byte
SPIF_SIZE           rmb       2                   transfer size, high byte first (reads back as FIFO count, low first)
SPIF_RSVD           rmb       1                   register 4 - not used by the datapath
SPIF_ADDR           rmb       3                   flash source address, 24 bit, high byte first
SPIF_DATA           rmb       1                   read FIFO data port (read only)


* WizFi360 Registers
* Two 2K FIFOs, one receive and one transmit - the same FIFO IP that the MIDI
* port uses.  Each reports BOTH a read count and a write count, which is why
* there are four counter pairs below - four counters, not four FIFOs.  Bytes
* waiting in a FIFO = its WR count - its RD count.  Counts are 11 bits, so
* only bits 10:8 of each high byte are valid.
* Wifi_Control_Register:
* Bit[0]: 0 = 115,200 baud; 1 = 921,600 baud (both directions).
* Bit[1] = 0 Default, 1 = Reset FIFO (you need to bring it back to 0) This is directly connected to reset line of the FIFO
* Bit[2] = RX FIFO Empty ( 1 = Empty, 0 = Data Available)  read only
* Bit[3] = TX FIFO Empty ( 1 = Empty, 0 = Data Available)  read only
* Unlike the MIDI port, all four bits work on every shipping core, and both
* directions raise interrupts: INT_WIZFI_RX (group 3, bit 0) when the Rx FIFO
* goes non-empty, INT_WIZFI_TX (group 3, bit 5) when the Tx FIFO drains empty.
WizFi.Base          equ       $FF20
WizFi.TxEmpty       equ       %00001000           Tx FIFO empty (read only)
WizFi.RxEmpty       equ       %00000100           Rx FIFO empty (read only)
WizFi.Reset         equ       %00000010           FIFO reset, active high - clears both FIFOs and both serial ends
WizFi.Rate          equ       %00000001           0 = 115,200 baud, 1 = 921,600 baud
                    org       $0
WizFi_CtrlReg       rmb       1                   control register (bits 2 and 3 read back as status)
WizFi_DataReg       rmb       1                   Rx/Tx FIFO data port (read and write)
WizFi_RxD_RD_Cnt    rmb       2                   RX occupancy, read clock domain; big-endian
WizFi_RxD_WR_Cnt    rmb       2                   RX occupancy, write clock domain; big-endian
WizFi_TxD_RD_Cnt    rmb       2                   TX occupancy, read clock domain; big-endian
WizFi_TxD_WR_Cnt    rmb       2                   TX occupancy, write clock domain; big-endian


* MIDI UART: fixed 31,250 baud; one 2 KB FIFO per direction.
* RD/WR counts are FIFO occupancy in each clock domain, not pointers.
* Control: b1 reset (clear after use), b2 RX empty, b3 TX empty.
* FIFO flags/reset work in rc11+; b0 rate selection is unused.
* RX interrupt is INT_MIDI_RX; TX has no interrupt.
MIDI.Base           equ       $FF30
MIDI.TxEmpty        equ       %00001000           Tx FIFO empty (read only)
MIDI.RxEmpty        equ       %00000100           Rx FIFO empty (read only)
MIDI.Reset          equ       %00000010           FIFO reset only, active high (does not touch the 2695 synthesizer)
MIDI.Rate           equ       %00000001           unused - the core has no rate select on the MIDI port
                    org       $0
MIDI_CTRL           rmb       1                   write control; read includes RX/TX empty flags
MIDI_DATA           rmb       1                   Rx/Tx FIFO data port (read and write) (writes also go to the 2695 MIDI synthesizer)
MIDI_RXD_RD_CNT     rmb       2                   RX occupancy, read clock domain; big-endian
MIDI_RXD_WR_CNT     rmb       2                   RX occupancy, write clock domain; big-endian
MIDI_TXD_RD_CNT     rmb       2                   TX occupancy, read clock domain; big-endian
MIDI_TXD_WR_CNT     rmb       2                   TX occupancy, write clock domain; big-endian


* W6100 ETHERNET bus interface - K2 ONLY
* K2 W6100 bus adapter; the Jr2 does not decode this device.
* Interrupt: INT_WIZNET (group 3, bit 3).
*
* Offsets 0-7 are control registers on WRITE.  Any offset with bit 3 set
* ($FF48-$FF4F) is the FIFO data port: writing pushes the Tx FIFO, reading
* pops the Rx FIFO.
* Control register (offset 0), on WRITE:
* Bit[0] = 1 enables the core
* Bits[3:1] = operation select (000 = single write of the data byte below)
* Bit[5] = 1 starts the transfer
* Control register (offset 0), on READ: bit 7 = Busy, bits 6:0 read back.
* CAUTION: the address bytes read back SWAPPED.  Written, offset 4 is the
* high byte and offset 5 the low byte; read, offset 4 returns the low byte
* and offset 5 the high byte.  The Rx FIFO count is 11 bits (2K) stored high
* byte first at offsets 6 and 7; the Tx count is the low 8 bits only, at
* offset 2, and offsets 1 and 3 read the chip's MR and Rx registers rather
* than what was written there.
W6100.Base          equ       $FF40
W6100.Busy          equ       %10000000           read only: transfer in progress
W6100.Start         equ       %00100000           write: start the transfer
W6100.Enable        equ       %00000001           write: enable the core
                    org       $0
WIZ_CTRL            rmb       1                   control (write) / status (read), see above
WIZ_MR              rmb       1                   W: mode register to write R: chip MR
WIZ_DATA_W          rmb       1                   W: (unused) R: Tx FIFO count, low 8 bits
WIZ_WRVAL           rmb       1                   W: single data byte to write R: chip Rx register
WIZ_ADDR_H          rmb       1                   W: address high byte R: address LOW byte
WIZ_ADDR_L          rmb       1                   W: address low byte R: address HIGH byte
WIZ_RXCNT_H         rmb       1                   R: Rx FIFO count, bits 10:8
WIZ_RXCNT_L         rmb       1                   R: Rx FIFO count, bits 7:0
WIZ_FIFO            rmb       1                   $FF48-$FF4F: W = push Tx FIFO, R = pop Rx FIFO


********************************************************************
* VS1053b audio decoder SPI bridge definitions
*
* Fixed I/O, identical on the K2 and Jr2 (core block VS1053_SPI_Interface,
* CS $FF50-$FF5F; offsets 8-15 mirror 0-7 on read). The bridge runs 32-bit
* SCI transactions over XCSn and streams a 2 KB byte FIFO to SDI over XDCSn
* as DREQ permits; the CPU never sees DREQ. 16-bit pairs are BIG-endian
* (high byte at the lower offset) since the 2026-09-05 core fix - cores
* built before it have VS_DATA and VS_FIFOCNT the other way round.
* SCI write: VS_SCIREG=reg, std VS_DATA, VS_CTRL=0, VS_CTRL=VS_START, wait !VS_BUSY
* SCI read:  VS_SCIREG=reg, VS_CTRL=0, VS_CTRL=VS_START+VS_READ, wait !VS_BUSY, ldd VS_DATA
* Stream:    while !(VS_FIFOSTAT & VS_FIFO_FULL) store bytes to VS_FIFO
VS1053.Base         equ       $FF50
                    org       0
VS_CTRL             rmb       1                   bit0 START (0->1 edge starts an SCI transaction, does not self-clear), bit1 READ, bit2 FAST (rc12), bit3 RESET (rc12), bit7 BUSY (r/o)
VS_SCIREG           rmb       1                   SCI register number in the low nibble (VS_MODE..VS_AICTRL3)
VS_DATA             equ       .                   16-bit SCI data, big-endian: std to send, ldd for the last read result
VS_DATAHI           rmb       1                   high byte
VS_DATALO           rmb       1                   low byte
VS_FIFOSTAT         rmb       1                   bit7 FIFO empty, bit6 FIFO full, bits 2-0 = count bits 10-8; reading it snapshots the count
VS_FIFOCNTL         rmb       1                   count bits 7-0 from that snapshot (ldd VS_FIFOSTAT then anda #VS_FIFO_CNTHI = 11-bit count)
VS_FIFOCNT          equ       VS_FIFOSTAT         16-bit alias for the ldd
                    rmb       1                   reads $00
VS_FIFO             rmb       1                   SDI stream data write: each byte is sent to the chip as DREQ permits
* VS_CTRL bits
VS_START            equ       %00000001
VS_READ             equ       %00000010
VS_FAST             equ       %00000100           rc12+: SPI clock IO_Clk/4 = 6.29 MHz, legal only after CLOCKF is raised (SCI reads need CLKI >= 44 MHz);
*                                       0 (reset default) = IO_Clk/16 = 1.57 MHz, in spec at the chip's boot clock. Pre-rc12 cores ignore the bit.
VS_RESET            equ       %00001000           rc12+: 1 = hold the chip's XRESET low (bit engine idle, SDI FIFO flushed) - the only way back
*                                       for a chip stuck with DREQ low, since every SCI command waits for DREQ. Pre-rc12 cores ignore it.
VS_BUSY             equ       %10000000
* VS_FIFOSTAT bits
VS_FIFO_EMPTY       equ       %10000000
VS_FIFO_FULL        equ       %01000000
VS_FIFO_CNTHI       equ       %00000111
* VS1053b SCI register numbers (for VS_SCIREG)
VS_MODE             equ       $0                  mode control
VS_STATUS           equ       $1                  status
VS_BASS             equ       $2                  bass/treble
VS_CLOCKF           equ       $3                  clock frequency + multiplier
VS_DECODE_TIME      equ       $4                  decode time in seconds
VS_AUDATA           equ       $5                  misc. audio data (sample rate, channels)
VS_WRAM             equ       $6                  RAM read/write
VS_WRAMADDR         equ       $7                  RAM address
VS_HDAT0            equ       $8                  stream header data 0 (read only)
VS_HDAT1            equ       $9                  stream header data 1 (read only)
VS_AIADDR           equ       $A                  application start address
VS_VOL              equ       $B                  volume (left/right attenuation, 0.5dB steps)
VS_AICTRL0          equ       $C                  application control 0
VS_AICTRL1          equ       $D                  application control 1
VS_AICTRL2          equ       $E                  application control 2
VS_AICTRL3          equ       $F                  application control 3


* DIP Switches for Jr/Jr2/K2.. 
K2_DIP_SW.Base      equ       $FF90
DIP_SW.Base         equ       K2_DIP_SW.Base      shared K2/Jr2 address
SW_GAMMA_ON         equ       %10000000
SW_USER2            equ       %01000000
SW_USER1            equ       %00100000
SW_USER0            equ       %00010000
SW_BOOT_MODE3       equ       %00001000
SW_BOOT_MODE2       equ       %00000100
SW_BOOT_MODE1       equ       %00000010
SW_BOOT_MODE0       equ       %00000001


                    endc
