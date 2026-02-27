                  IFNE    PICOTHING.D-1

PICOTHING.D         SET       1

********************************************************************
* picothing.d - Pico-Thing MC6809 Board Hardware Definitions
*
* Custom MC6809 board with:
*   - 2MB RAM in 8kB pages (256 physical pages)
*   - 256-byte DAT RAM at $FE00-$FEFF for address translation
*   - Pi Pico providing virtual peripherals at $FFC0-$FFFF
*
* Memory Map:
*   $0000-$FDFF   RAM (DAT-translated)
*   $FE00-$FEFF   DAT RAM (32 tasks * 8 regs * 1 byte = 256 bytes)
*   $FF00-$FFBF   I/O space (PATA HD, etc.)
*   $FFC0         Task register (Pico)
*   $FFC3-$FFC4   Virtual MC6850 ACIA (serial console)
*   $FFC8-$FFCF   Virtual MC6840 PTM (timer/clock, fires IRQ)
*   $FFF0-$FFFF   6809 hardware vectors (provided by Pico)
*
* DAT Structure:
*   The 256-byte DAT RAM is indexed by {task_reg[4:0], addr[15:13]}.
*   - task_reg: 5-bit task number (0-31), held in Pico register at $FFC0
*   - addr[15:13]: top 3 bits of 6809 address select one of 8 page slots
*   - Each byte is the 8-bit physical page number (0-255)
*   - Task 0 base: DAT.Regs + 0*8 = $FE00
*   - Task 1 base: DAT.Regs + 1*8 = $FE08  (matches CoCo3's DAT.Regs+8)
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2025       Initial version

picothing           SET       1         conditional assembly symbol
TkPerSec            SET       50        ticks per second (50Hz timer)

*
* DAT (Dynamic Address Translator)
*
DAT.BlCt            EQU       8         blocks per address space
DAT.BlSz            EQU       (256/DAT.BlCt)*256 8KB block size
DAT.ImSz            EQU       DAT.BlCt  8 bytes per DAT image (1 byte per block)
DAT.Task            EQU       $FFC0     task register (Pico)
DAT.Regs            EQU       $FE00     DAT RAM base address
DAT.TkCt            EQU       32        number of task slots
DAT.BlMx            EQU       $FE       max user-allocatable block number
DAT.Free            EQU       $FF       free block marker (sentinel, never allocated)
DAT.BMSz            EQU       $100      block map size (256 physical pages)
DAT.WrPr            EQU       0         write protect (not supported)
DAT.WrEn            EQU       0         write enable (not supported)
KrnBlk              SET       $07       physical page number of the kernel (page 7)
HW.Page             EQU       $FF       high byte of I/O address space

*
* Virtual MC6850 ACIA (serial console, via Pico at $FFC3-$FFC4)
*
ACIABase            EQU       $FFC3     6850 base address
ACIA.Ctrl           EQU       ACIABase+0 status (read) / control (write)
ACIA.Data           EQU       ACIABase+1 receive (read) / transmit (write)

*
* Virtual MC6840 PTM (programmable timer module, via Pico at $FFC8-$FFCF)
*
* Note: this virtual timer fires the 6809 IRQ line (not FIRQ).
* NitrOS-9's timeslicing infrastructure is built around IRQ; connecting
* the timer to IRQ is required for proper process scheduling.
*
PTMBase             EQU       $FFC8     6840 base address
PTM.CR              EQU       PTMBase+0 control/status register
PTM.CR2             EQU       PTMBase+1 control register 2
PTM.CR1             EQU       PTMBase+2 control register 1
PTM.T3MSB           EQU       PTMBase+3 timer 3 MSB
PTM.T3LSB           EQU       PTMBase+4 timer 3 LSB
PTM.T2MSB           EQU       PTMBase+5 timer 2 MSB
PTM.T2LSB           EQU       PTMBase+6 timer 2 LSB
PTM.T1MSB           EQU       PTMBase+7 timer 1 MSB

*
* PATA Hard Disk (in I/O space $FF00-$FFBF)
*
* Note: the Pico maps the 16-bit ATA data word at PTIDEBase+0, shifting
* all other task-file registers up by one vs standard ATA.  Use
* defs/ide_picothing.d (not ide.d) for register offsets.
*
PTIDEBase           EQU       $FF00     PATA base address

*
* Boot
*
Bt.Start            EQU       $EC00     boot_picothing at $EC00 (padded to 512), krn at $EE00
SHIFTBIT            EQU       0         no shift key on serial console

*
* MC6840 PTM control register bits
*
PTM.IRQEn           EQU       %01000000 interrupt enable bit (CR bit 6)
PTM.IRQFlag         EQU       %10000000 interrupt flag bit (status register bit 7)
PTM.T1En            EQU       %00000001 timer 1 enable (CR1 bit 0)
PTM.ClkSrc          EQU       %00000010 clock source select (internal)
PTM.CntMode         EQU       %00001000 continuous mode (repeat)

                  ENDC

