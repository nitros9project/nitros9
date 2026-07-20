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
*   $FFC4-$FFC5   Virtual MC6850 ACIA (serial console)
*   $FFC6-$FFC7   Virtual MC6850 ACIA (auxiliary)
*   $FFC8-$FFC9   Virtual 50Hz tick timer (fires IRQ)
*   $FFF0-$FFFF   6809 hardware vectors (provided by Pico)
*
* DAT Structure:
*   The 256-byte DAT RAM is indexed by {task_reg[4:0], addr[15:13]}.
*   - task_reg: 5-bit task number (0-31), held in Pico register at $FFC0
*   - addr[15:13]: top 3 bits of 6809 address select one of 8 page slots
*   - Each byte is the 8-bit physical page number (0-255)
*   - Task 0 base: DAT.Regs + 0*8 = $FE00
*   - Task 1 base: DAT.Regs + 1*8 = $FE08  (matches CoCo3's DAT.Regs+8)
*   - Task 2 base: DAT.Regs + 2*8 = $FE10
*   - ... etc
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2025       Initial version

picothing           SET       1         conditional assembly symbol
TkPerSec            SET       50        ticks per second (50Hz timer)

*
* Physical address space
*
HW.Page             EQU       $FF       high byte of I/O address space
IO.Base             EQU       HW.Page*256 base of I/O address space

*
* DAT (Dynamic Address Translator)
*
DAT.BlCt            EQU       8         blocks per address space
DAT.BlSz            EQU       (256/DAT.BlCt)*256 block size
DAT.ImSz            EQU       DAT.BlCt*2 16 bytes per DAT image (2 bytes per block, low byte = page)
DAT.Task            EQU       IO.Base+$C0 task register (Pico)
DAT.Regs            EQU       $FE00     DAT RAM base address
DAT.TkCt            EQU       32        number of task slots
DAT.BlMx            EQU       $FE       max user-allocatable block number
DAT.Free            EQU       $33FF     free block marker (page $FF = no RAM in hardware)
DAT.BMSz            EQU       $100      block map size
DAT.WrPr            EQU       0         write protect (not supported)
DAT.WrEn            EQU       0         write enable (not supported)
KrnBlk              SET       $FF       physical page number of the kernel

*
* Virtual MC6850 ACIA — console (via Pico at $FFC4-$FFC5)
*
ACIABase            EQU       IO.Base+$C4 console 6850 base address
ACIA.Ctrl           EQU       ACIABase+0 status (read) / control (write)
ACIA.Data           EQU       ACIABase+1 receive (read) / transmit (write)

*
* Virtual MC6850 ACIA — auxiliary (via Pico at $FFC6-$FFC7)
*
AuxBase             EQU       IO.Base+$C6 auxiliary 6850 base address
Aux.Ctrl            EQU       AuxBase+0 status (read) / control (write)
Aux.Data            EQU       AuxBase+1 receive (read) / transmit (write)

*
* Virtual 50 Hz Tick Timer (via Pico at $FFC8-$FFC9)
*
* Minimal tick timer using Pico SDK hardware alarm.
* Fires IRQ at 50Hz.  Reading the status register acknowledges the IRQ.
*
TICK.Ctrl           EQU       IO.Base+$C8 write: bit 0 = enable (1) / disable (0)
TICK.Stat           EQU       IO.Base+$C9 read: bit 7 = IRQ pending; cleared on read

*
* SystemWatchpoint control (Pico at $FFCA)
*
* Writing a non-zero value arms the vector watchpoint: the $FFF0-$FFFF
* vector region becomes read-only and any write there traps via NMI.
* Writing zero disarms it.
*
WatchCtl            EQU       IO.Base+$CA hardware vector watchpoint control

*
* PATA Hard Disk (in I/O space $FF00-$FFBF)
*
* Note: the Pico maps the 16-bit ATA data word at PTIDEBase+0, shifting
* all other task-file registers up by one vs standard ATA.  Use
* defs/ide_picothing.d (not ide.d) for register offsets.
*
PTIDEBase           EQU       IO.Base+$00 PATA base address

*
* Boot
*
                  IFEQ    Level-1
* Level 1 boot definitions
* The os9kernel blob (krn + krnp2 + init + boot) is pre-loaded here and
* scanned by the kernel cold-start, so it must hold all four modules
* (~3.9KB). $EC00-$FDFF = 4.5KB, leaving room; $EC00 also matches where
* Level 2 places krn.
Bt.Start            EQU       $EC00     kernel starts here
Bt.Size             EQU       $1200     kernel area ($EC00-$FDFF)
                  ELSE
* Level 2 boot definitions
Bt.Start            EQU       $E800     boot_picothing at $E800 (padded to 1024), krn at $EC00
                  ENDC
SHIFTBIT            EQU       0         no shift key on serial console

*
* Debug monitor entry points always present in kernel space
*
DBG.PrintChar       EQU       $FC00     print character in A
DBG.Print2Hex       EQU       $FC03     print byte in A as 2 hex digits
DBG.Print4Hex       EQU       $FC06     print D as 4 hex digits
DBG.PrintStr        EQU       $FC09     print null-terminated string at X
DBG.PrintCR         EQU       $FC0C     print CR+LF
DBG.PrintRegs       EQU       $FC0F     print CC,A,B,DP,X,Y,U,S
DBG.IllegalOp       EQU       $FC12     6309 illegal opcode trap (does not return)

                  ENDC

